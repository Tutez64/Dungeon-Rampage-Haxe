#Requires -Version 5.1
<#
.SYNOPSIS
  Export FRESteamWorks ANE scripts, then convert AS3 to Haxe with ax4.
#>
[CmdletBinding()]
param(
    [string]$Ax4 = $env:AX4_DIR,
    [string]$Decompiled = $env:DECOMPILED_DIR,
    [string]$Ffdec = $env:FFDEC_HOME,
    [string]$AirSdk = $env:AIR_SDK,
    [string]$Ane,
    [switch]$NoBuildAx4,
    [switch]$PrepareOnly,
    [switch]$KeepTmp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ScriptDir = $PSScriptRoot
$Template = Join-Path $ScriptDir "config.json"
$TmpDir = Join-Path $ScriptDir ".tmp"
$AneSrc = Join-Path $TmpDir "ane-src"
$AneExport = Join-Path $TmpDir "ane-export"
$RuntimeConfig = Join-Path $TmpDir "config.json"
$AirglobalTmp = Join-Path $TmpDir "airglobal.swc"
$LibrarySwf = Join-Path $TmpDir "library.swf"

function Get-RelativePath([string]$Path, [string]$Base) {
    $baseUri = [Uri]((Resolve-Path -LiteralPath $Base).Path.TrimEnd('\') + '\')
    $pathUri = [Uri](Resolve-Path -LiteralPath $Path).Path
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('\', '/')
}

function Find-Sibling([string]$Name) {
    $candidate = Join-Path (Split-Path -Parent $Root) $Name
    if (Test-Path -LiteralPath $candidate -PathType Container) {
        return (Resolve-Path -LiteralPath $candidate).Path
    }
    return $null
}

function Find-Ax4Dir {
    if ($Ax4) {
        if (-not (Test-Path -LiteralPath $Ax4 -PathType Container)) { throw "ax4 directory not found: $Ax4" }
        return (Resolve-Path -LiteralPath $Ax4).Path
    }
    $found = Find-Sibling "ax4"
    if (-not $found) { throw "ax4 not found. Pass -Ax4 / AX4_DIR." }
    return $found
}

function Find-DecompiledDir {
    if ($Decompiled) {
        if (-not (Test-Path -LiteralPath $Decompiled -PathType Container)) { throw "Decompiled directory not found: $Decompiled" }
        return (Resolve-Path -LiteralPath $Decompiled).Path
    }
    $found = Find-Sibling "Dungeon-Rampage-Decompiled"
    if (-not $found) { throw "Dungeon-Rampage-Decompiled not found. Pass -Decompiled / DECOMPILED_DIR." }
    return $found
}

function Find-Ffdec {
    $files = @()
    if ($Ffdec) {
        if (Test-Path -LiteralPath $Ffdec -PathType Leaf) {
            $files += $Ffdec
        }
        else {
            $files += @(
                (Join-Path $Ffdec "ffdec.bat"),
                (Join-Path $Ffdec "ffdec-cli.exe"),
                (Join-Path $Ffdec "dist\ffdec.jar"),
                (Join-Path $Ffdec "dist\ffdec-cli.jar"),
                (Join-Path $Ffdec "ffdec.jar")
            )
        }
    }
    $jpexs = Find-Sibling "jpexs-decompiler"
    if ($jpexs) {
        $files += @(
            (Join-Path $jpexs "dist\ffdec.jar"),
            (Join-Path $jpexs "dist\ffdec-cli.jar")
        )
    }
    $cmd = Get-Command ffdec.bat, ffdec-cli.exe, ffdec -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { $files += $cmd.Source }
    $files += @(
        "C:\Program Files (x86)\FFDec\ffdec.bat",
        "C:\Program Files\FFDec\ffdec.bat",
        "C:\Program Files (x86)\FFDec\ffdec-cli.exe",
        "C:\Program Files\FFDec\ffdec-cli.exe"
    )
    foreach ($file in $files) {
        if ($file -and (Test-Path -LiteralPath $file -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $file).Path
        }
    }
    throw "JPEXS FFDec not found. Prefer the dev branch of https://github.com/Tutez64/jpexs-decompiler. Pass -Ffdec / FFDEC_HOME."
}

function Invoke-Ffdec {
    param(
        [string]$FfdecPath,
        [string[]]$FfdecArgs
    )
    $env:FFDEC_MEMORY = "2048m"
    if ($FfdecPath -like "*.jar") {
        $java = Get-Command java -ErrorAction SilentlyContinue
        if (-not $java) { throw "java is required to run ffdec.jar" }
        & $java.Source -Xmx2048m -jar $FfdecPath @FfdecArgs
    }
    else {
        & $FfdecPath @FfdecArgs
    }
    if ($LASTEXITCODE -ne 0) {
        throw "FFDec failed with exit code $LASTEXITCODE"
    }
}

function Find-Airglobal([string]$Ax4Abs) {
    $sdk = $AirSdk
    if (-not $sdk) {
        $lime = Get-Command haxelib -ErrorAction SilentlyContinue
        if ($lime) {
            $sdk = (& haxelib run lime config AIR_SDK 2>$null | Out-String).Trim()
        }
    }
    $candidates = @()
    if ($sdk) { $candidates += (Join-Path $sdk "frameworks\libs\air\airglobal.swc") }
    foreach ($file in $candidates) {
        if ($file -and (Test-Path -LiteralPath $file -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $file).Path
        }
    }
    throw "airglobal.swc not found. Pass -AirSdk / AIR_SDK, or set lime config AIR_SDK."
}

function Find-Ane([string]$DecompiledAbs) {
    if ($Ane) {
        if (-not (Test-Path -LiteralPath $Ane)) { throw "ANE path not found: $Ane" }
        return (Resolve-Path -LiteralPath $Ane).Path
    }
    $ane = Join-Path $DecompiledAbs "extensions\FRESteamWorks.ane"
    if (Test-Path -LiteralPath $ane) {
        return (Resolve-Path -LiteralPath $ane).Path
    }
    throw "FRESteamWorks.ane not found in $DecompiledAbs\extensions. Run the decompiled repo sync, or pass -Ane."
}

function Convert-CopiedFiles([string]$Path) {
    $textExt = @('.as', '.hx', '.xml', '.json', '.txt', '.md')
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $items = @()
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $items = @(Get-Item -LiteralPath $Path)
    }
    elseif (Test-Path -LiteralPath $Path -PathType Container) {
        $items = @(Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue)
    }
    else {
        return
    }
    foreach ($file in $items) {
        if ($textExt -notcontains $file.Extension.ToLowerInvariant()) { continue }
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        if ($bytes -notcontains [byte]13) { continue }
        $text = $utf8.GetString($bytes)
        $converted = $text.Replace("`r`n", "`n").Replace("`r", "`n")
        [System.IO.File]::WriteAllBytes($file.FullName, $utf8.GetBytes($converted))
    }
}

function Get-FileSha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Expand-AneTo([string]$AnePath, [string]$Dest) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    if (Test-Path -LiteralPath $AnePath -PathType Container) {
        Copy-Item -Path (Join-Path $AnePath '*') -Destination $Dest -Recurse -Force
        return
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($AnePath, $Dest)
}

function Get-AneRelativeFiles([string]$Dir) {
    Get-ChildItem -LiteralPath $Dir -Recurse -File -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            $_.FullName.Substring($Dir.Length).TrimStart('\', '/').Replace('\', '/')
        } |
        Where-Object { $_ -ne 'mimetype' } |
        Sort-Object
}

function Test-AneTreesMatch([string]$A, [string]$B) {
    $fa = @(Get-AneRelativeFiles -Dir $A)
    $fb = @(Get-AneRelativeFiles -Dir $B)
    if (($fa -join '|') -ne ($fb -join '|')) {
        return $false
    }
    foreach ($rel in $fa) {
        $pa = Join-Path $A ($rel.Replace('/', '\'))
        $pb = Join-Path $B ($rel.Replace('/', '\'))
        if ((Get-FileSha256 $pa) -ne (Get-FileSha256 $pb)) {
            return $false
        }
    }
    return $true
}

function Test-AnePayloadsMatch([string]$Src, [string]$Dest) {
    if (-not (Test-Path -LiteralPath $Dest)) { return $false }
    if ((Test-Path -LiteralPath $Src -PathType Leaf) -and (Test-Path -LiteralPath $Dest -PathType Leaf)) {
        if ((Get-FileSha256 $Src) -eq (Get-FileSha256 $Dest)) { return $true }
    }
    $srcStage = Join-Path ([System.IO.Path]::GetTempPath()) ("drh-ane-src-" + [guid]::NewGuid().ToString("n"))
    $destStage = Join-Path ([System.IO.Path]::GetTempPath()) ("drh-ane-dst-" + [guid]::NewGuid().ToString("n"))
    try {
        Expand-AneTo $Src $srcStage
        Expand-AneTo $Dest $destStage
        return (Test-AneTreesMatch $srcStage $destStage)
    }
    finally {
        if (Test-Path -LiteralPath $srcStage) { Remove-Item -LiteralPath $srcStage -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $destStage) { Remove-Item -LiteralPath $destStage -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Get-RelativeDataFiles([string]$Dir) {
    $root = (Resolve-Path -LiteralPath $Dir).Path.TrimEnd('\', '/')
    Get-ChildItem -LiteralPath $Dir -Recurse -File -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
        } |
        Sort-Object
}

function Test-TreesMatch([string]$A, [string]$B) {
    $fa = @(Get-RelativeDataFiles $A)
    $fb = @(Get-RelativeDataFiles $B)
    if (($fa -join '|') -ne ($fb -join '|')) { return $false }
    foreach ($rel in $fa) {
        $pa = Join-Path $A ($rel.Replace('/', '\'))
        $pb = Join-Path $B ($rel.Replace('/', '\'))
        if ((Get-FileSha256 $pa) -ne (Get-FileSha256 $pb)) { return $false }
    }
    return $true
}

function Install-OfficialTree([string]$From, [string]$To, [string]$Label) {
    if (-not (Test-Path -LiteralPath $From -PathType Container)) {
        throw "Decompiled $Label not found: $From"
    }
    if ((Test-Path -LiteralPath $To -PathType Container) -and (Test-TreesMatch $From $To)) {
        Write-Host "$Label unchanged, keeping $To"
        return
    }
    if (Test-Path -LiteralPath $To) { Remove-Item -LiteralPath $To -Recurse -Force }
    Copy-Item -LiteralPath $From -Destination $To -Recurse -Force
    Convert-CopiedFiles $To
    Write-Host "Updated $Label"
}

function Install-GameData([string]$DecompiledAbs) {
    Install-OfficialTree (Join-Path $DecompiledAbs "data\DbConfiguration") (Join-Path $Root "DbConfiguration") "DbConfiguration"
    Install-OfficialTree (Join-Path $DecompiledAbs "data\Resources") (Join-Path $Root "Resources") "Resources"
}

function Install-Ane([string]$AnePath) {
    $packed = Join-Path $Root "extensions\FRESteamWorks.ane"
    $unpacked = Join-Path $Root "extensions\adl\FRESteamWorks.Unpacked.ane"
    if (Test-AnePayloadsMatch $AnePath $packed) {
        Write-Host "ANE payloads unchanged, keeping $packed"
        if (-not (Test-Path -LiteralPath $unpacked)) {
            Expand-AneTo $packed $unpacked
            Convert-CopiedFiles $unpacked
        }
        return
    }
    New-Item -ItemType Directory -Path (Join-Path $Root "extensions\adl") -Force | Out-Null
    if (Test-Path -LiteralPath $unpacked) { Remove-Item -LiteralPath $unpacked -Recurse -Force }
    if (Test-Path -LiteralPath $AnePath -PathType Container) {
        Copy-Item -LiteralPath $AnePath -Destination $unpacked -Recurse -Force
        Convert-CopiedFiles $unpacked
        return
    }
    $srcFull = (Resolve-Path -LiteralPath $AnePath).Path
    $destFull = $packed
    if (Test-Path -LiteralPath $packed) { $destFull = (Resolve-Path -LiteralPath $packed).Path }
    if ($srcFull -ne $destFull) {
        Copy-Item -LiteralPath $AnePath -Destination $packed -Force
    }
    Expand-AneTo $AnePath $unpacked
    Convert-CopiedFiles $unpacked
}

function Extract-LibrarySwf([string]$AnePath, [string]$Dest) {
    if (Test-Path -LiteralPath $AnePath -PathType Container) {
        $lib = Join-Path $AnePath "library.swf"
        if (-not (Test-Path -LiteralPath $lib -PathType Leaf)) { throw "library.swf not found in $AnePath" }
        Copy-Item -LiteralPath $lib -Destination $Dest -Force
        return
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($AnePath)
    try {
        $entry = $zip.Entries | Where-Object { $_.FullName -eq "library.swf" -or $_.FullName.EndsWith("/library.swf") } | Select-Object -First 1
        if (-not $entry) { throw "no library.swf in $AnePath" }
        if (Test-Path -LiteralPath $Dest) { Remove-Item -LiteralPath $Dest -Force }
        $out = [System.IO.File]::Open($Dest, [System.IO.FileMode]::Create)
        try {
            $entry.Open().CopyTo($out)
        }
        finally {
            $out.Dispose()
        }
    }
    finally {
        $zip.Dispose()
    }
}

function Install-AsTree([string]$ExportDir, [string]$Dest) {
    $scripts = Join-Path $ExportDir "scripts"
    if (-not (Test-Path -LiteralPath $scripts -PathType Container)) { $scripts = $ExportDir }
    if (Test-Path -LiteralPath $Dest) { Remove-Item -LiteralPath $Dest -Recurse -Force }
    New-Item -ItemType Directory -Path $Dest | Out-Null
    $files = @(Get-ChildItem -LiteralPath $scripts -Recurse -File -Filter *.as -ErrorAction SilentlyContinue)
    if ($files.Count -eq 0) { throw "FFDec produced no ActionScript files under $ExportDir" }
    $scriptsFull = (Resolve-Path -LiteralPath $scripts).Path.TrimEnd('\')
    foreach ($file in $files) {
        $rel = $file.FullName.Substring($scriptsFull.Length).TrimStart('\')
        $target = Join-Path $Dest $rel
        $parent = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force
    }
}

function Write-RuntimeConfig([string]$DecompiledAbs, [string]$Ax4Abs) {
    $cfg = Get-Content -LiteralPath $Template -Raw | ConvertFrom-Json
    $gameSrcRel = Get-RelativePath (Join-Path $DecompiledAbs "src") $Root
    $cfg.src = @($gameSrcRel, (Get-RelativePath $AneSrc $Root))
    $cfg.hxout = "src"
    $cfg.copy = @(@{ unit = (Get-RelativePath (Join-Path $Ax4Abs "compat") $Root); to = "compat" })
    $cfg.swc = @(Get-RelativePath $AirglobalTmp $Root)

    $json = $cfg | ConvertTo-Json -Depth 10
    # Windows PowerShell 5.1 utf8 encoding writes a BOM; Haxe JsonParser rejects it.
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($RuntimeConfig, $json, $utf8)
}

$Ax4Abs = Find-Ax4Dir
$DecompiledAbs = Find-DecompiledDir
$FfdecPath = Find-Ffdec
$AneAbs = Find-Ane $DecompiledAbs
$AirglobalAbs = Find-Airglobal $Ax4Abs
$Jar = Join-Path $Ax4Abs "converter.jar"

if (-not (Get-Command java -ErrorAction SilentlyContinue)) { throw "java is required to run ax4" }

New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null
Copy-Item -LiteralPath $AirglobalAbs -Destination $AirglobalTmp -Force

Write-Host "ax4:        $Ax4Abs"
Write-Host "Decompiled: $DecompiledAbs"
Write-Host "FFDec:      $FfdecPath"
Write-Host "ANE:        $AneAbs"
Write-Host "airglobal:  $AirglobalAbs"

Write-Host "Updating extensions/ ..."
Install-Ane $AneAbs

Write-Host "Updating DbConfiguration/ and Resources/ ..."
Install-GameData $DecompiledAbs

Write-Host "Extracting library.swf ..."
Extract-LibrarySwf $AneAbs $LibrarySwf

if (Test-Path -LiteralPath $AneExport) { Remove-Item -LiteralPath $AneExport -Recurse -Force }
New-Item -ItemType Directory -Path $AneExport | Out-Null
Write-Host "Decompiling ANE library.swf ..."
Invoke-Ffdec -FfdecPath $FfdecPath -FfdecArgs @(
    "-config", "paramNamesEnable=true",
    "-exportTimeout", "1800",
    "-export", "script",
    $AneExport,
    $LibrarySwf
)

Install-AsTree $AneExport $AneSrc
Write-RuntimeConfig $DecompiledAbs $Ax4Abs
Write-Host "Wrote $RuntimeConfig"

if ($PrepareOnly) {
    Write-Host "Prepare-only: stopping before ax4."
    if (-not $KeepTmp) {
        Remove-Item -LiteralPath $TmpDir -Recurse -Force
    }
    exit 0
}

# ax4 does not track converter.jar: build it so it matches the ax4 commit the stamp records.
if (-not $NoBuildAx4) {
    $hxml = Join-Path $Ax4Abs "build.hxml"
    if (-not (Test-Path -LiteralPath $hxml)) { throw "ax4 build.hxml not found in $Ax4Abs" }
    Write-Host "Building ax4 ..."
    Push-Location $Ax4Abs
    try { npx haxe build.hxml } finally { Pop-Location }
}
if (-not (Test-Path -LiteralPath $Jar -PathType Leaf)) { throw "converter.jar not found in $Ax4Abs. Drop -NoBuildAx4." }

Write-Host "Converting with ax4 ..."
Push-Location $Root
try {
    & java -jar $Jar (Get-RelativePath $RuntimeConfig $Root)
    if ($LASTEXITCODE -ne 0) { throw "ax4 failed with exit code $LASTEXITCODE" }
}
finally { Pop-Location }

Write-Host "Moving com.amanitadesign to src-steam ..."
$steamDest = Join-Path $Root "src-steam\com"
New-Item -ItemType Directory -Path $steamDest -Force | Out-Null
$steamOut = Join-Path $steamDest "amanitadesign"
if (Test-Path -LiteralPath $steamOut) { Remove-Item -LiteralPath $steamOut -Recurse -Force }
$steamSrc = Join-Path $Root "src\com\amanitadesign"
if (-not (Test-Path -LiteralPath $steamSrc)) { throw "conversion did not produce src\com\amanitadesign" }
Move-Item -LiteralPath $steamSrc -Destination $steamOut
Convert-CopiedFiles $steamOut

if (-not $KeepTmp) {
    Remove-Item -LiteralPath $TmpDir -Recurse -Force
}

Write-Host "Done."

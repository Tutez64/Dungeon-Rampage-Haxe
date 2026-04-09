$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$resourcesRoot = Join-Path $projectRoot "Resources"
$outputPath = Join-Path $projectRoot "generated_swf_libraries.xml"
$preloadRulesPath = Join-Path $PSScriptRoot "swf_preload.txt"
$generateRulesPath = Join-Path $PSScriptRoot "swf_generate.txt"

function Get-Rules([string]$path) {
    if (!(Test-Path $path)) {
        return @()
    }

    return Get-Content $path |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
}

function Should-Preload([string]$relativePath, [string[]]$preloadRules) {
    foreach ($rule in $preloadRules) {
        if ($relativePath -like $rule) {
            return $true
        }
    }

    return $false
}

function Get-LibraryId([string]$relativePath) {
    $normalized = $relativePath.Replace('\', '/')
    if ($normalized.StartsWith('./')) {
        $normalized = $normalized.Substring(2)
    }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append("ax4_swf_")

    foreach ($char in $normalized.ToLowerInvariant().ToCharArray()) {
        if (($char -ge 'a' -and $char -le 'z') -or ($char -ge '0' -and $char -le '9')) {
            [void]$builder.Append($char)
        } else {
            [void]$builder.Append('_')
        }
    }

    $id = $builder.ToString()
    while ($id.Contains("__")) {
        $id = $id.Replace("__", "_")
    }

    return $id.TrimEnd('_')
}

$preloadRules = Get-Rules $preloadRulesPath
$generateRules = Get-Rules $generateRulesPath

$libraries = Get-ChildItem $resourcesRoot -Recurse -Filter *.swf |
    Sort-Object FullName |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($projectRoot.Length + 1)
        $relativePath = $relativePath.Replace('\', '/')
        [PSCustomObject]@{
            Path = $relativePath
            Id = Get-LibraryId $relativePath
            Preload = Should-Preload $relativePath $preloadRules
            Generate = Should-Preload $relativePath $generateRules
        }
    }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('<?xml version="1.0" encoding="utf-8"?>')
$lines.Add('<project>')
foreach ($library in $libraries) {
    $preloadValue = if ($library.Preload) { "true" } else { "false" }
    $generateValue = if ($library.Generate) { "true" } else { "false" }
    $lines.Add("`t<library path=""$($library.Path)"" id=""$($library.Id)"" preload=""$preloadValue"" generate=""$generateValue"" />")
}
$lines.Add('</project>')

$directory = Split-Path -Parent $outputPath
if (!(Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}

Set-Content -Path $outputPath -Value $lines -Encoding UTF8
Write-Host "Generated $($libraries.Count) SWF libraries in $outputPath"

# Passation — optimisation mémoire et GC

État au 28 juillet 2026. Ce document résume le travail effectué afin de pouvoir
reprendre l'enquête sans reconstruire le contexte depuis les anciennes
conversations.

## Objectif et constat initial

Le problème à traiter est le coût croissant du GC de DRH, principalement dans
les dungeons :

- les collectes deviennent plus longues au fil d'une partie ;
- après un certain temps, elles deviennent aussi plus fréquentes ;
- sur les machines modestes, le problème peut être sensible beaucoup plus tôt ;
- la RAM de DRH partait d'environ 1 Gio et pouvait gagner plusieurs Gio, contre
  environ 300 Mio au démarrage et généralement moins de 1 Gio en partie pour
  le client AS3/AIR original.

Résumé `HXCPP_GC_SUMMARY` d'une ancienne partie longue :

```text
Total time     : 2303228.70ms
Collecting time: 18925.57ms
Max Stall time : 232.71ms
Fraction       : 0.82%
```

Sur une autre machine et une partie de 1 h 50, le maximum avait atteint
1687,73 ms et la fraction 2,16 %. Les machines et parties n'étant pas
comparables, ces valeurs établissent le symptôme, pas un benchmark A/B.

La priorité a été donnée aux défauts structurels de hxcpp, SWF et OpenFL plutôt
qu'aux micro-ajustements dans le code du jeu.

Issue DRH liée : `#6`, « Quick RAM/VRAM growth resulting in FPS drops ». Les
commits utilisent `Related to #6` et ne doivent pas fermer l'issue :
le travail apporte de gros progrès, mais l'objectif global n'est pas terminé.

## État courant des dépôts

### DRH

- Dépôt : `/home/tutez/Projets/Personnels/Haxe/DungeonRampageHaxe`
- Branche : `master`
- HEAD : `09450f2 Enable the generational garbage collector`
- `origin/master` pointe actuellement sur le même commit.

Defines importants dans `project.xml` :

```xml
<haxedef name="HXCPP_GC_BIG_BLOCKS" />
<haxedef name="HXCPP_GC_GENERATIONAL" />
<haxedef name="HXCPP_GC_SUMMARY" />
<haxedef name="analyzer-optimize" />
<haxedef name="swf_compact_animate_timelines" />
<haxedef name="swf_hardware_bitmap_cache" />
```

Pointeurs de submodules enregistrés dans le HEAD DRH :

| Submodule | Branche de travail | Commit |
|---|---|---|
| hxcpp | `master` | `c4487bf3` |
| OpenFL | `develop` | `5a358a004` |
| SWF | `master` | `21ca8b6` |
| Lime | `develop` | `83191c70` |
| SteamWrap | `master` | `91d36186` |


### Instrumentation hxcpp (ponctuelle)

L’instrumentation GC de diagnostic n’est **pas** commitée sur le tip hxcpp des
releases. Elle est conservée comme patch :

```text
tools/profiling/patches/hxcpp_gc_timeline_census_retention.patch
```

Fichiers touchés une fois le patch appliqué :

- `docs/build_xml/Defines.md`
- `include/hx/GC.h`
- `src/hx/gc/Immix.cpp`
- `toolchain/common-defines.xml`

Defines ajoutés :

- `HXCPP_GC_TIMELINE` : une ligne CSV par collecte, avec mode `gen`/`std`,
  cause, pause, phases, mémoire et taille du remembered set ;
- `HXCPP_GC_CENSUS` : recensement des classes et buffers vivants pendant
  certains scans complets ;
- `HXCPP_GC_RETENTION_TRACE` et variantes ciblées : chemins de rétention.

Appliquer uniquement pour un build `gc-*`, puis retirer avant toute release.
Voir `tools/profiling/PROFILING.md`. Ces defines ne sont pas activés dans
`project.xml` de la release. Le census et les traces alourdissent les collectes
ciblées : leurs pauses ne sont jamais des mesures de release.

Les outils de session (`tools/run_gc_session.sh`,
`tools/analyze_gc_session.py`, docs et scripts sous `tools/profiling/`) sont
destinés à être commités dans DRH.

## Corrections actuellement intégrées

### 1. Débordement de la mémoire de travail Immix

- hxcpp : `2ff8c23e Fix Immix working memory overflow with big blocks`
- Branche PR : `bugfix/immix-big-blocks-working-memory-overflow`
- Premier pointeur DRH : `599103a`

Avec `HXCPP_GC_BIG_BLOCKS`, un calcul intermédiaire en `int` débordait lorsque
le tas régulier approchait 2 Gio. Cela pouvait provoquer épuisement mémoire,
collectes prématurées ou pauses extrêmement longues. La correction emploie
`GetWorkingMemory()`, des seuils en `size_t` et `strtoull`.

### 2. Sémantique éphemeron des WeakMap

- hxcpp : `6944113e Fix weak-key hash ephemeron semantics`
- Branche PR : `fix/weakmap-ephemeron-values`
- DRH : `331ca03 Update hxcpp with WeakMap ephemeron GC fix`

Les valeurs d'une table à clés faibles pouvaient conserver indirectement leur
propre clé. Elles sont maintenant traitées comme des éphemerons pendant le
marquage. Le commit contient des tests hxcpp dédiés.

La run `gc-20260725_080456`, volontairement proche de
`gc-20260725_072626`, a confirmé une baisse nette de la croissance et des
pauses. La référence utilisait cependant une instrumentation de rétention :
elle ne doit pas servir de benchmark temporel rigoureux.

### 3. Stockage compact des commandes de formes Animate

- SWF : plage `9879582..97420fe`, dont
  `45910f1 Optimize Animate shape command storage`
- Branche PR : `optimize/compact-animate-shape-commands`
- DRH : `d4c792e Update SWF submodule to reduce Animate shape GC pressure`

Les commandes de formes Animate sont stockées sous une forme compacte, ce qui
réduit fortement le nombre d'objets survivants et le graphe à marquer.
`gc-20260725_234317` n'a montré aucune anomalie visuelle.

La branche a également reçu le correctif de compatibilité Haxe 3
`97420fe`, nécessaire aux tests AIR/Neko historiques.

### 4. Cache matériel des bitmaps Animate

- SWF : `47a241c Add opt-in hardware cache for Animate bitmaps`
- Correctif : `71321ca Preserve readable data for shared Animate bitmaps`
- Branche PR : `optimize/animate-hardware-bitmap-cache`
- PR SWF connue : `#56`
- DRH :
  - `3f42c4d` active `swf_hardware_bitmap_cache` ;
  - `496cfcf` prend le correctif des bitmaps partagés.

Le premier prototype libérait trop tôt certaines données lisibles : quelques
assets devenaient des rectangles noirs, notamment une barre de chargement.
Après correction, `gc-20260726_042442` était visuellement correcte.

Un autre crash avec des bitmaps Animate partagés est apparu dans
`gc-20260726_084320`. `71321ca` l'a corrigé et
`gc-20260726_191609` a confirmé que le gain restait présent.

Les runs réelles, pas parfaitement contrôlées, indiquaient environ 350 Mio de
moins. Par exemple :

- avant ce cache, `gc-20260726_024918` (24 min) : pic RSS 1991 Mio, vivant
  final 896 Mio ;
- avec le cache, `gc-20260726_065716` (20,5 min) : pic RSS 1635 Mio, vivant
  final 598 Mio.

### 5. Timelines Animate compactes

- SWF : `21ca8b6 Add compact Animate timeline storage`
- Branche PR : `optimize/compact-animate-timelines`
- DRH : `296d4f6 Update SWF to compact Animate timeline storage`
- Define : `swf_compact_animate_timelines`

Les événements sérialisés restent compacts jusqu'à leur utilisation, afin de
réduire les métadonnées et le coût de marquage. Les runs
`gc-20260726_202611` et `gc-20260726_204818` étaient visuellement correctes.

### 6. États de rendu OpenFL alloués paresseusement

Les trois corrections sont dans le fork OpenFL et dans son `develop` :

| Changement | Commit OpenFL | Branche PR | Commit DRH | Validation |
|---|---|---|---|---|
| État shader de `Graphics` | `e3cee7c94` puis tests `47c8ea32f` | `perf/lazy-graphics-shader-state` | `d3a310b` | `gc-20260727_003755` |
| Transformations de rendu de `Graphics` | `058260a2f` | `perf/lazy-graphics-render-state` | `8003a47` | `gc-20260727_015704` |
| Transformations de rendu de `DisplayObject` | `b1191aa20` | branche de validation `validation/lazy-displayobject-render-state` | `26bb883` | `gc-20260727_041516` |

Les tests shader natifs avaient été exécutés sur AIR et signalés comme tests
sans assertions. `47c8ea32f` les exclut correctement de Flash/AIR.

Le premier build de l'allocation paresseuse `DisplayObject` plantait au
démarrage après une fenêtre noire (`gc-20260727_031114`). Le commit final
initialise l'état aux frontières des renderers ; `gc-20260727_041516` démarre
et s'affiche correctement.

Ces changements sont simples et structurellement utiles, mais leur impact GC
isolé reste inférieur aux optimisations SWF et hxcpp.

### 7. Copy-on-write indépendant des flux DrawCommandBuffer

- OpenFL : `5a358a004 Allocate DrawCommandBuffer streams independently`
- Branche PR : `perf/draw-command-buffer-stream-cow`
- DRH : `678012b Update OpenFL for per-stream graphics command COW`

Une commande simple ne matérialise plus les sept tableaux internes d'un
`Graphics` : seuls les flux effectivement écrits sont détachés.

`gc-20260727_062859` : 6 floors, environ 210 s de jeu effectif, aucune
régression visuelle. Par rapport à `gc-20260727_053411`, en retirant la
collection 31 volontairement ralentie par le traceur, le coût pendant les
floors passait approximativement de 7,63 à 6,52 ms/s (-15 %) et le volume
récupéré de 16,63 à 15,39 Mio/s (-7 %). Ce sont des runs réelles, pas un
benchmark parfaitement contrôlé ; les tests et le repro établissent séparément
le gain structurel.

### 8. GC générationnel et compatibilité Haxe 4.3.7

- hxcpp : `c4487bf3 Fix generational GC builds with Haxe 4.3.7`
- DRH : `09450f2 Enable the generational garbage collector`
- Define désormais actif : `HXCPP_GC_GENERATIONAL`

Haxe 4.3.7 génère à tort une barrière d'écriture pour `cpp.Function`, puis
accède à `_hx_v.mPtr`, qui n'existe pas. Le shim hxcpp expose, uniquement avec
le GC générationnel, un `mPtr` statique nul. La barrière devient donc un no-op
sans modifier la taille ni l'ABI de `cpp::Function`.

Le repro a compilé et s'est exécuté avec Haxe officiel 4.3.7, le fork hxcpp et
`HXCPP_GC_GENERATIONAL` :

```text
/home/tutez/Projets/Personnels/Haxe/repros/hxcpp-generational-cpp-function
```

La correction propre du générateur Haxe existe également :

- fork : `/home/tutez/Projets/Personnels/Haxe/haxe`
- branche : `fix-cpp-function-generational-barrier`
- commit : `b62aa1ec1`
- PR Haxe : `HaxeFoundation/haxe#13002`

Une branche 4.3.7 pure a été créée dans
`/home/tutez/Projets/Personnels/Haxe/haxe-4.3.7-drh` :

- branche `drh-4.3.7`
- commit `a2cd8e248`
- tag `4.3.7-drh.1`

Elle n'est plus nécessaire pour DRH grâce au shim hxcpp. Les essais de
distribution de compilateurs personnalisés ont été abandonnés et les
workflows DRH sont revenus à Haxe officiel 4.3.7. La branche technique
`ci/drh-4.3.7-register` et son worktree `/tmp/haxe-drh-ci-register` peuvent
être ignorés ou nettoyés plus tard.

## Résultat actuel de HXCPP_GC_GENERATIONAL

La run générationnelle de référence est `gc-20260727_173931`. Elle a 6 floors
et se compare raisonnablement à `gc-20260727_062859`, qui contient toutes les
optimisations précédentes mais pas le define générationnel. La comparaison
reste approximative.

| Mesure | Non générationnel `062859` | Générationnel `173931` |
|---|---:|---:|
| Durée jusqu'au dernier GC | 230,4 s | 268,6 s |
| Collections | 58 | 91 |
| Temps GC cumulé | 1674,4 ms | 1372,5 ms |
| Coût GC global | 7,27 ms/s | 5,11 ms/s |
| Fraction instrumentée | 0,693 % | 0,496 % |
| Pause médiane | 30,72 ms | 13,36 ms |
| p95 | 49,23 ms | 26,23 ms |
| Maximum | 124,04 ms | 139,36 ms |
| Vivant final / pic | 315,7 / 466,5 Mio | 606,1 / 905,3 Mio |
| Réservé final | 521,5 Mio | 775,9 Mio |
| Grosses allocations finales | 192,8 Mio | 443,3 Mio |
| RSS final | 1200,1 Mio | 1359,4 Mio |

Interprétation :

- malgré une run environ 16 % plus longue et davantage de collectes, le coût
  GC par seconde baisse d'environ 30 % ;
- la médiane baisse d'environ 56 % et le p95 d'environ 47 % ;
- les collectes générationnelles elles-mêmes restent courtes ;
- les scans complets occasionnels portent toujours les plus grosses pauses ;
- le prix actuel est surtout un tas vivant/réservé et des grosses allocations
  sensiblement plus élevés.

Détail de `gc-20260727_173931` :

| Mode | Nombre | Temps cumulé | Médiane | p95 | Maximum |
|---|---:|---:|---:|---:|---:|
| `gen` | 74 | 942,2 ms | 13,37 ms | 19,21 ms | 24,09 ms |
| `std` | 17 | 430,2 ms | 8,52 ms | 91,33 ms | 139,36 ms |

Remembered set des collectes générationnelles : médiane 1582, p95 3060,
maximum 12173 références.

Le define est donc déjà utile. L'objectif suivant n'est pas de le retirer,
mais de conserver ce coût GC faible tout en ramenant la RAM vers le niveau de
la version non générationnelle.

## Prochaine piste : `TODO - include large too?`

Point de reprise exact dans :

```text
submodules/libhxcpp/src/hx/gc/Immix.cpp
```

Autour de la ligne 5638 :

```cpp
#ifdef HXCPP_GC_GENERATIONAL
if (generational)
{
   // TODO - include large too?
   int retained = mRowsInUse - oldRowsInUse;
   int space = mAllBlocks.size()*IMMIX_USEFUL_LINES - oldRowsInUse;
   if (space<retained)
      space = retained;

   mGenerationalRetainEstimate = (double)retained/(double)space;
}
```

Le choix de la prochaine collecte (`gcmGenerational` ou `gcmFull`) estime
actuellement la rétention et le remplissage uniquement à partir des lignes
Immix. Il ignore les grosses allocations, alors qu'elles dominent maintenant
une grande partie du tas :

- dans `gc-20260727_173931`, elles terminent à 443,3 Mio sur 606,1 Mio de
  vivant total ;
- le collecteur peut donc continuer à choisir des passes générationnelles
  alors que la pression réelle, surtout dans les gros buffers, justifierait
  plus tôt un scan standard.

Hypothèse de travail : intégrer proprement les grosses allocations à
`mGenerationalRetainEstimate` et/ou au ratio de remplissage devrait déclencher
les scans complets à un meilleur moment, faire baisser le pic et le niveau
final de RAM, tout en gardant la majorité des collectes courtes.

Points à décider et instrumenter avant de figer la formule :

1. Travailler dans une unité commune, de préférence les octets, au lieu de
   mélanger lignes Immix et tailles de gros buffers.
2. Distinguer les grosses allocations gérées par le GC
   (`mLargeListAllocated`) de la mémoire native/externe
   (`mLargeAllocated - mLargeListAllocated`).
3. Mémoriser une base fiable à la fin de la collecte précédente afin de
   séparer vieux volume, nouveaux octets et nouveaux octets survivants.
4. Protéger les soustractions contre les underflows et le dénominateur nul.
5. Ajouter temporairement à la timeline :
   - l'estimation de rétention ;
   - le ratio prédit après une passe générationnelle ;
   - les gros octets avant/après ;
   - la raison du choix du prochain mode.
6. Ne pas simplement forcer davantage de scans complets : chercher le point
   où la RAM redescend sans réintroduire les longues pauses fréquentes.

Le code vient à l'origine de `07b49230 Try to estimate if it is worth doing a
generational collection or not` (2017), et le TODO est présent depuis ce
commit. Vérifier également la voie de secours vers un marquage standard quand
le remplissage des blocs dépasse 85 %, autour de `filled > 0.85`.

## Plan de validation recommandé

L'utilisateur vérifie d'abord en détail que l'ensemble des changements actuels
est bénéfique et sans régression. Ne commencer la modification de l'estimateur
qu'après cette validation.

Ensuite :

1. Conserver `gc-20260727_173931` comme référence générationnelle actuelle et
   `gc-20260727_062859` comme repère non générationnel.
2. Construire une variante ne modifiant que la prise en compte des grosses
   allocations.
3. Rejouer le même dungeon statique, en solo, si possible avec le même
   personnage, équipement et 6 floors.
4. Comparer :
   - coût GC en ms/s et fraction ;
   - nombre de `gen` et `std` ;
   - médiane, p95 et maximum séparés par mode ;
   - vivant, réservé, grosses allocations et RSS ;
   - remembered set ;
   - valeur et décisions du nouvel estimateur.
5. Vérifier visuellement chaque floor et le retour en town.
6. Si le résultat court est bon, faire une partie plus longue pour vérifier
   que les scans complets restent suffisamment espacés et que la RAM se
   stabilise.

Ne pas surinterpréter :

- deux parties normales non contrôlées ;
- les pauses des builds avec trace de rétention ;
- une différence VRAM isolée, qui dépend fortement des assets rencontrés ;
- le RSS seul sans le rapprocher du tas hxcpp réservé et des gros buffers.

## Outils et sessions

Documentation détaillée : `tools/profiling/PROFILING.md`.

Lancer une session :

```bash
DRH_PROFILE_BINARY="$PWD/bin/gc-generational/linux/bin/Dungeon Rampage Haxe" \
  tools/run_gc_session.sh
```

Réanalyser :

```bash
python3 tools/analyze_gc_session.py profiling/gc-AAAAMMJJ_HHMMSS
```

Chaque dossier contient normalement :

- `session.txt` et le hash du binaire ;
- `game.log` ;
- `memory.csv` ;
- `events.csv` et `game_events.csv` ;
- `gc_timeline.csv` ;
- les census éventuels ;
- `analysis.md` et `timeline.svg`.

Le bug de marqueur lié à la locale française (`printf: 32.809534: nombre non
valable`) est corrigé dans `tools/run_gc_session.sh` par des calculs `awk` sous
`LC_ALL=C`.

Sessions particulièrement utiles :

| Session | Usage |
|---|---|
| `gc-20260725_041952` | première longue session instrumentée, 21,9 min, RSS final 3577 Mio, médiane GC 104 ms |
| `gc-20260725_055249` | session initiale plus longue, 32,5 min, pic RSS 4267 Mio |
| `gc-20260725_080456` | validation WeakMap éphemeron |
| `gc-20260726_024918` | référence longue avant cache matériel Animate |
| `gc-20260726_065716` | run plus comparable avec cache matériel |
| `gc-20260726_191609` | validation après correction du crash des bitmaps partagés |
| `gc-20260727_053411` | trace du graphe vivant ; collection 31 volontairement lente |
| `gc-20260727_054912` | cache de mesure texte désactivé, piste rejetée |
| `gc-20260727_062859` | COW DrawCommandBuffer, meilleure référence non générationnelle récente |
| `gc-20260727_173931` | référence générationnelle actuelle |

## Pistes écartées ou secondaires

### Désactiver le cache de mesure du texte

`gc-20260727_054912` supprime les `ShapeCache` sans problème visuel, mais ne
réduit pas les `GlyphPosition`, principalement détenus par les
`TextLayoutGroup.positions` actifs. Aucun gain RAM ou GC mesurable : ne pas
conserver `openfl_disable_text_measurement_cache`.

### Modifier directement le jeu

Des rétentions de gameplay restent visibles dans le census, mais l'objectif de
ce chantier est d'abord de corriger les bibliothèques et le collecteur, car le
client original ne présente pas le problème avec la même ampleur. Ne revenir au
code du jeu que si les mesures identifient une rétention spécifique et
indépendante des différences AS3/Haxe.

### Incidents à ne pas confondre avec le GC

- `gc-20260725_211258` s'est terminée lors de la tentative de rejoindre un
  second dungeon à cause d'un crash déjà connu et distinct.
- Les gels des builds `gc-retention-*` sont intentionnels pendant les
  collections tracées.
- Les rectangles noirs et le crash des bitmaps partagés appartenaient au
  prototype du cache matériel et sont corrigés dans l'état courant.
- Le crash de démarrage `gc-20260727_031114` appartenait au prototype de l'état
  `DisplayObject` paresseux et est corrigé dans l'état courant.

## Critère de succès à long terme

Le résultat recherché n'est pas seulement une baisse de la pause maximale
d'une courte run. Il faut :

- garder un coût GC global inférieur à la version non générationnelle ;
- maintenir des pauses typiques nettement plus courtes ;
- empêcher le vivant, le réservé et le RSS de croître sans borne ;
- éviter que les scans complets deviennent de plus en plus longs et fréquents ;
- conserver le rendu, les dungeons longs et le retour en town sans régression ;
- confirmer ensuite sur une partie longue et, si possible, une machine plus
  faible.

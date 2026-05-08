# Profiling natif C++

Le binaire [`bin/linux/bin/Dungeon Rampage Haxe`](/home/tutez/Projets/Personnels/Haxe/DungeonRampageHaxe/bin/linux/bin/DungeonBustersProject) n'est pas strippe, donc `perf` peut deja remonter les symboles Haxe/hxcpp.

## Session recommandeee

1. Lancer le jeu normalement.
2. Recuperer son PID:

```bash
pidof "Dungeon Rampage Haxe"
```

3. Demarrer l'echantillonnage memoire:

```bash
tools/profile_native_memory.sh <pid> profiling/run1/memory.csv 0.5
```

4. Dans un autre terminal, demarrer la capture CPU:

```bash
tools/profile_native_perf.sh <pid> profiling/run1
```

5. Reproduire un scenario court et precis, par exemple:
   - ecran de chargement -> town
   - ouverture d'un ecran UI lourd
   - entree en donjon
   - 20-30 secondes de gameplay

6. Arreter `perf` avec `Ctrl+C`, puis analyser:

```bash
tools/report_native_perf.sh profiling/run1/perf.data
```

## Conseils

- Faire des captures courtes et ciblees. Une session par scenario.
- Noter l'heure exacte des chutes d'IPS ou des pics RAM pour les croiser avec `memory.csv`.
- Si `perf` montre surtout du rendu bas niveau sans remonter assez loin vers Haxe, la prochaine etape sera une build `-Dtelemetry` avec `hxtelemetry`/HxScout.

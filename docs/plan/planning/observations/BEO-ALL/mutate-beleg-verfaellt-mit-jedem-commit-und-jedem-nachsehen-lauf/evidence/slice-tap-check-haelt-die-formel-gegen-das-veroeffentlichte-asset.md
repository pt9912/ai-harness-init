**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** Der `make mutate`-Beleg des Slice gilt für den Baum vor dem Verifikationsbericht und den
Closure-Commits: der Schlüssel hängt an allen Dateien außer `.harness/state` und `.git`
(`ISOLATION_EXCLUDES` in `harness/tools/mutate.sh`), und jeder dieser Commits ändert ihn. Der Verifier
las die Schlüsseldatei und die Fall-Zahl, berechnete den Schlüssel nicht neu und hielt einen Restzweifel
fest; die Closure fährt keinen zweiten vollen Lauf und belegt die Unveränderung des Prüfgegenstands über
`git diff --name-only 90be56c9..HEAD` (nur der Bericht)
(`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
§1, V-1 und Ü-2).

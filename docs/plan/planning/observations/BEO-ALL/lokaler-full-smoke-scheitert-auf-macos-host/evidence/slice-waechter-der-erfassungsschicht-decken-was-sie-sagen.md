**Vorgang:** slice-waechter-der-erfassungsschicht-decken-was-sie-sagen
**Fund:** §5 Closure-Trigger dieses Slice musste den lokalen `make mutate`-Beleg für die Fälle
382–393 durch den CI-Beleg (`workflow_dispatch` auf `.github/workflows/mutate.yml`) ersetzen, weil
`make mutate` auf diesem macOS-Devhost strukturell nicht läuft — erster Slice, der auf diese
Randbedingung stößt und schließt.

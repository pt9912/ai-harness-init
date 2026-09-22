**Vorgang:** slice-leser-und-aufraeum-waechter-decken-was-sie-sagen
**Fund:** §5 Closure-Trigger dieses Slice musste den lokalen `make mutate`-Beleg für die Fälle 187
und 394 erneut durch den CI-Beleg (`workflow_dispatch` auf `.github/workflows/mutate.yml`)
ersetzen, weil `make mutate` auf diesem macOS-Devhost weiterhin strukturell nicht läuft — zweiter
Slice, der auf diese Randbedingung stößt.

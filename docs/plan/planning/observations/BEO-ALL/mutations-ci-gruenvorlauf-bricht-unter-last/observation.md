# Mutations-CI-Grün-Vorlauf bricht unter Last

**Sub-Area:** `*` (gesamtes Repo)

Der grüne Vorlauf der Mutations-Probe ([`MR-091`](../../../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt))
bricht unter infrastruktureller Last, bevor ein Fall urteilt: Vorlauf-Abbrüche der CI-Versuche
unter paralleler Last und ein Docker-Build-Rennen der parallelen `test-go`-Exports — die
Vorlauf-Schicht verliert, nicht der Fall.

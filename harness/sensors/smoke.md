# `make smoke` — Tier-2-Emit-Smoke

## Vertrag

Emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real
laufen — host-orchestriert ([`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)):
das Produkt-Binary entsteht je Lauf am Host (`make host-bin`, `SMOKE_ARTIFACT_TARGET` wählt
darüber die opt-in Docker-Formen), print-mk und das emittierte docs-check laufen am
d-check-Carrier (`DCHECK_CARRIER` oder die fetched Ablage, `make dcheck-fetch` — Netz an
genau diesem Aufruf), die Baseline kommt per Netz. Verfügbar, **nicht** in `make gates` — wie
`regelwerk-check`/`baseline-freshness`.

## Grenze — was das Grün nicht abdeckt

Host + Netz an den fetchenden Stufen → nicht offline-schlank ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
gehört an DoD-Verify/CI/Wellen-Closure. Prüft nur die Bootstrap-**Schritte** einzeln
(Templates emittiert, docs-check-Config valide + 0 Befunde, Go-Gates getrennt) — die
**zusammengeführte** `make gates`-Sicht eines Adopters prüft [`make full-smoke`](full-smoke.md).
Details, Schritte und Belege stehen im Kopf von `harness/tools/smoke.sh`.

## Sperren

Eine: fehlt der d-check-Carrier (`DCHECK_CARRIER` und die fetched Ablage), bricht der Lauf
vor seinem ersten Schritt als Umgebungs-Befund ab — laut, nicht als `smoke: FEHLER`.
Jeder weitere Abbruch liegt in einem Schritt und nennt ihn (`smoke: FEHLER — …`);
`harness/tools/smoke.sh` läuft unter `set -euo pipefail`.

## Bindung

Kein Gate-Versprechen.

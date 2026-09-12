# `make smoke` — Tier-2-Emit-Smoke

## Vertrag

Emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real
laufen (Host-Docker, ggf. Netz-Pull). Verfügbar, **nicht** in `make gates` — wie
`regelwerk-check`/`baseline-freshness`.

## Grenze — was das Grün nicht abdeckt

Host-Docker + Netz-Pull → nicht offline-schlank ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
gehört an DoD-Verify/CI/Wellen-Closure. Prüft nur die Bootstrap-**Schritte** einzeln
(Templates emittiert, docs-check-Config valide + 0 Befunde, Go-Gates getrennt) — die
**zusammengeführte** `make gates`-Sicht eines Adopters prüft [`make full-smoke`](full-smoke.md).
Details, Schritte und Belege stehen im Kopf von `harness/tools/smoke.sh`.

## Bindung

Kein Gate-Versprechen.

# `make full-smoke` — Voll-E2E-Smoke

## Vertrag

Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates`
([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check +
Go-Gates in einem Lauf) — der Happy-Path-Beweis
([`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch
gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die
[`make smoke`](smoke.md) mit seinen getrennten Schritten nicht nimmt). Host-Docker + ggf.
Netz-Pull → nicht in `make gates`; gehört an DoD-Verify/CI/Wellen-Closure.

## Grenze — was das Grün nicht abdeckt

**Sein Grün sagt das eine, sein Rot sagt zwei Dinge:** der Lauf fragt je Durchgang fremde
Registries nach gepinnten Bildern und macht jede dieser Anfragen zur Bedingung seines Grüns.
Bricht ein Abschnitt ab, ordnet `harness/tools/full-smoke-ausgang.sh` ihn einem von zwei
Ausgängen zu — `AUSGANG LEITUNG` (eine ausgehende Anfrage nach einem gepinnten Artefakt wurde
nicht mit 2xx beantwortet) oder `AUSGANG BAUM` (keine der geführten Formen steht in den
gelesenen Zeilen, der Fehlschlag wird dem geprüften Baum zugerechnet). Der Exit-Code
unterscheidet die zwei bewusst nicht — ein eigener Code lüde dazu ein, den Leitungs-Fall
durchzuwinken, und das wäre die Schwellen-Senkung, die [`AGENTS.md`](../../AGENTS.md) §3.5 an
ein ADR bindet.

Abgedeckt ist **jeder Abschnitt, der ein Bild anfordern kann** — ein Kriterium, keine
Fundstellen-Liste; die mechanische Abgrenzung, ihre Gleichung und die drei Formen, die
nachprüfbar **kein** Bild anfordern (Trockenlauf, `make span-clean`, der Hook-Wrapper) stehen
im Kopf von `harness/tools/full-smoke.sh`. Die Ausgangs-Muster, ihre Messung und ihre weiteren
Grenzen (Paketquellen der C++-Kette fallen in den Baum-Fall) stehen im Kopf von
`harness/tools/full-smoke-ausgang.sh`; `test/full-smoke-ausgang.bats` fährt beide Richtungen
über Ausschnitten echter Läufe.

## Bindung

Kein Gate-Versprechen; slice-024, [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).

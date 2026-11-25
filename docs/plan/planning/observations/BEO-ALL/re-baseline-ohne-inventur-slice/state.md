**Stand:** verkörpert

Die Regel liegt in der **Delta-Tafel der Welle `welle-baseline-sprung-v7-0-0`**
(§4 — als Kennung adressiert, nicht als Pfad: die Welle-Plan-Datei wandert bei
ihrer Closure per `git mv` nach `done/`,
[`AGENTS.md`](../../../../../../AGENTS.md) §3.11): die Inventur eines
Baseline-Sprungs läuft als read-only Lesung **vor** dem Tausch, und die Tafel
bündelt die Form-Pflichten je Befundzeile mit Ausgang (Cluster-Slice-Kennung als
geordneter Vorschlag, Ablehnung mit Grund, Bestand mit Zeiger). Der
Herkunfts-Anker steht wörtlich in
[`done/slice-baseline-delta-lesung-v7-0-0.md`](../../../done/slice-baseline-delta-lesung-v7-0-0.md)
§7 — `grep -c 'seit slice-baseline-delta-lesung-v7-0-0'
docs/plan/planning/done/slice-baseline-delta-lesung-v7-0-0.md` → 1, gelesen
2026-11-25 ([`MR-051`](../../../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
kein Erwartungswert).

**Grenze der Verkörperung, benannt.** Kein Enforcement-Ort trägt die Regel: kein
Modul der [`.d-check.yml`](../../../../../../.d-check.yml) liest die Tafel gegen
die Cluster-Kennungen, und `make register-ausgang` prüft das Stand-Wort, nicht
die Tafel-Deckung (Grenze im Kopf von
[`harness/tools/register-ausgang.sh`](../../../../../../harness/tools/register-ausgang.sh)).
Träger bleibt der Plan-Workflow; die dritte Lesung lief zudem **außerhalb** der
Slice-Ablage (read-only Auftraggeber-Auftrag) und ihr Träger-Slice schloss ohne
Lieferung — künftige Sprünge wiederholen die Tafel-Form im Sichtungs-Schritt (§8)
ihres Sprung-Slices.

**Was passieren müsste, damit die Regel bricht:** ein Sprung-Slice, das den
Tausch ohne vorgelagerte Lesung eröffnet.

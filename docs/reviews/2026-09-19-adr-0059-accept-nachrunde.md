# Reviewer-Runde: ADR-0059 — Accept-Nachrunde (ADR-Konsistenz)

* **Datum:** 2026-09-19
* **Rolle:** Reviewer, frischer Kontext; erste Runde, die die ADR selbst prüft — die drei
  Slice-Runden prüften den Diff gegen Plan und ADRs, keine davon die ADR
  ([`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 gilt hier nicht als Re-Runde, denn keine vorige Runde meldete einen
  blockierenden Befund gegen diese Datei)
* **Gegenstand:** [`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  (`Proposed`) — die ADR selbst, kein Neu-Review des Slices
* **Prüfauftrag:** Festlegung 2 (Wand-Kriterium und seine Sonde) · Festlegungen 1 und 3
  gegen den realen Stand · Teil-Ablösung (Form gegen
  [`ADR-0055`](../plan/adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)/[`ADR-0032`](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md)) ·
  Geschichte-Zeile ([`AGENTS.md`](../../AGENTS.md) §3.7) · Re-Evaluierungs-Trigger
* **Geprüft gegen:** ADR-0058, ADR-0055, ADR-0032, ADR-0040, `MR-007`, `AGENTS.md` §3.7

## Summary

**Kein blockierender Befund.** Zwei MEDIUM und ein LOW — alle drei im `Proposed`-Fenster
behebbar, keiner berührt eine der sechs Festlegungen. **Annahmefähig: ja — sobald die drei
Befunde vor dem Umschlag behoben sind.**

## Befunde

### F-1 (MEDIUM) — Die Sonde der Festlegung 2 misst die Vorlage, nicht das Binary

* **kategorie:** MEDIUM
* **quelle:** ADR-0059 Festlegung 2 vs. §Fitness Function
* **pfad:** `docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md:241`
  (Fitness-Zeile 1)
* **befund:** Festlegung 2 benennt das **Binary** als Prüfgegenstand („Das Binary trägt keinen
  Wert, der vom Bau-Ergebnis abhängt“); die Fitness-Tabelle misst ausschließlich die
  Fragment-Vorlage (`grep -c 'TRAEGER_SHA256' …traeger.mk` → 0). Am Binary ist die messbare
  Form eine andere: der String `TRAEGER_SHA256` steht dort 5× — Variablennamen der
  eingebetteten Fetch-Logik, kein Verstoß (Verifikations-Lauf; hier am Helfer nachgezählt:
  `grep -c 'TRAEGER_SHA256' harness/tools/traeger-fetch.sh` → 5, Wert-Zuweisungen → 0) —,
  das Kriterium ist die Wert-Zuweisung `TRAEGER_SHA256[A-Z_]* ?= [64hex]` → 0 und die
  `TRAEGER_TAG`-Zeile → 1. Ohne die binäre Sonde fehlt der Zusage ihr Wächter am Binary; ein
  Lauf, der die Vorlagen-Sonde am Binary anwendet, liest 5 und meldet einen Verstoß, den
  keiner ist.
* **verifizierbar:** ja — Build + die zwei Greps am Binary (z. B. als Stufe in der
  `make full-smoke`-Kette, wo ein Binary ohnehin entsteht)
* **klasse:** Sonde misst die Vorlage statt das Binary, das die Festlegung benennt

**Nachschärfe (Vorschlag):** Fitness-Zeile ergänzen —
`grep -oaE 'TRAEGER_SHA256[A-Z_]*[[:space:]]*\?=[[:space:]]*[0-9a-f]{64}' <binary> | wc -l` → 0 ·
die Tag-Zeile im Binary → 1 (Wert-frei gegen das Fragment-Tag gehalten, kein eingefrorener
Tag) · und die Aussage, dass bare `TRAEGER_SHA256`-Treffer aus der Fetch-Logik kein
Festlegung-2-Verstoß sind.

### F-2 (MEDIUM) — Index-Zusatz an der ADR-0058-Zeile steht vor dem Accept, und die Folgepflicht, die ihn anordnet, fehlt

* **kategorie:** MEDIUM
* **quelle:** ADR-0055 Folgepflicht · ADR-0032 Folgepflicht 2
* **pfad:** `docs/plan/adr/README.md:65` · ADR-0059 §Konsequenzen
* **befund:** Die Status-Zelle von ADR-0058 trägt bereits „Emissions-Hälfte von Festlegung 1
  abgelöst durch ADR-0059“, während ADR-0059 `Proposed` ist — ADR-0055 Folgepflicht:
  „Beide Änderungen sind ein Commit: **kein Stand führt den Index mit einer noch `Proposed`
  geführten ADR als der revidierenden**.“ Zugleich führt ADR-0059 die Folgepflicht, die den
  Zusatz anordnet, nicht — ihre zwei Form-Vorbilder tragen beide eine solche (ADR-0032
  Folgepflicht 2: „Der Index trägt ihn nur, wo eine `Accepted`-ADR ihn anordnet — diese ADR
  ordnet ihn an“).
* **verifizierbar:** ja — `git grep 'abgelöst durch' docs/plan/adr/README.md` am Stand vor
  dem Accept-Commit
* **klasse:** Index-Zusatz vor dem Accept der revidierenden ADR

**Behebung:** Zusatz aus der Index-Zeile ziehen (eigener Commit, vor dem Umschlag);
Folgepflicht in §Konsequenzen ergänzen — der annehmende Lauf setzt den Zusatz im selben
Commit wie den Accept-Umschlag.

### F-3 (LOW) — Folgepflicht 2 nennt eine Test-Datei, die den Gegenstand nicht hält

* **kategorie:** LOW
* **quelle:** ADR-0059 Folgepflicht 2
* **pfad:** `docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md:219`
* **befund:** Die Rest-Kopplung ist mit „Text-Kopplung, Test-Klasse
  `test/sources-pin.bats`“ benannt; sie steht in `test/traeger-fetch.bats` (Test
  „pin-kopplung“, :118–128: Tag an beiden Stellen, Fragment ohne Digest-Variablen,
  sechs 64-Hex-Einzeldigests), während `test/sources-pin.bats` keine TRAEGER-Zeile führt
  (`grep -c TRAEGER test/sources-pin.bats` → 0). Ein Lauf, der der Folgepflicht folgt,
  sucht an der falschen Datei.
* **verifizierbar:** ja — die zwei Greps
* **klasse:** Folgepflicht nennt eine Test-Datei, die den Gegenstand nicht hält

**Behebung:** `test/traeger-fetch.bats` nennen.

## Anmerkung an den annehmenden Lauf (kein Befund)

Der §Kontext trägt den datierten Zustand „Der `v0.2.1`-Schnitt pausiert auf dem
Entscheidungs-Bezug dieser Datei“ — der Schnitt ist inzwischen vollzogen (Messung unten).
Kein Befund am Text eines datierten Kontexts; die Accept-Zeile nennt nach
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1 neben der **Kennung** dieses Reports (Kennung, kein Pfad-Link) den Vollzug der
Folgepflichten 1/3/5.

## Geprüft, ohne Befund

* **Festlegung 1 gegen den realen Stand** — Release `v0.2.1`: 7 Assets, `SHA256SUMS` als
  siebtes (`gh release view v0.2.1 --json assets --jq '.assets | length'` → 7; Namen
  gelesen). SUMS-Zeile == gemessener Hash == Makefile-Pin für **darwin-arm64 und
  windows-amd64, selbst gefahren** (linux/amd64 trägt der Orchestrierer);
  `d8b8c7a2…`/`b8353e27…` deckungsgleich in allen drei Stellen. Form `<sha256>␣␣<name>` wie
  festgelegt. Generator `harness/tools/release-sums.sh` (generate/verify),
  `make release-artifacts` erzeugt die SUMS am selben Ort, Publikations-Seite
  `cd dist && sha256sum -c SHA256SUMS` im publish-Job, beides gehalten von
  `test/release-matrix.bats` (:317–375).
* **Festlegung 3 (Kanal-Split der Dogfood-Hälfte)** — `harness/tools/traeger-fetch.sh`:
  exportierte `TRAEGER_SHA256_*` → Verifizierung gegen den Makefile-Pin (Git-Kanal); keine
  exportiert → Manifest-Modus (Ziel, Release-Kanal); teilweise exportiert bricht laut statt
  still in den Manifest-Kanal zu fallen. Makefile-Kommentar (:36–46) und Fragment-Vorlage
  tragen dieselbe Zweiteilung; das Fragment führt nur den Tag (`grep -c TRAEGER_SHA256`
  → 0), `TRAEGER_TAG ?= v0.2.1` an beiden Stellen.
* **Teil-Ablösung, Aufzählung** — die fortgeltenden Festlegungen sind wörtlich benannt und
  existieren alle in ADR-0058: Festlegungen 1 (Dogfood-Hälfte) bis 5, der gemessene
  Fehlt-Fall, die E2E-Zusage; die zwei Digest-Beine der Fitness-Zeile 1 („Emitter-Default“,
  „Fragment-Default“) und die Reichweite ihrer Folgepflicht 1 sind korrekt gezogen; die
  Festlegung 2 von ADR-0058 ist bestätigt und mit der Wand-Messung verschärft, nicht
  abgelöst. **Kopf-Marken in ADR-0058: nach der Haus-Form korrekt nicht gesetzt** —
  ADR-0055 (§Kontext: „kein Byte der einen“) und ADR-0042 Festlegung 2 nehmen die
  `Accepted`-ADR vom Nachzug aus; der Zeiger ist der Index-Zusatz (ADR-0032 Folgepflicht 2),
  dessen *Zeitpunkt* F-2 ist.
* **Geschichte-Zeile** — Zustand (Proposed) in der Ereignis-Spalte; die Verweis-Spalte
  trägt die Haus-Form der drei Vorgänger-ADRs (Prosa samt Anlass, „Der Acceptance-Trigger
  steht unten“ als Zeiger); Ziel-Form des Baseline-Templates
  (`NNNN-titel.template.md` :118–123, Spalten Datum|Ereignis|Verweis) getroffen. Keine
  Chronik jenseits der Haus-Form.
* **Re-Evaluierungs-Trigger** — vier Trigger, jeder ein beobachtbarer Moment, kein Datum
  als Trigger: Signier-Schritt (Festlegung 1: Kanal-Split-Verlust) · Kopplungs-Drift
  Makefile↔Manifest (Folgepflicht 2) · Emission-Netz (Festlegung 4, Alternative B) ·
  Release-Kanal-Wechsel (Form des Manifests). ADR-0058s eigene Trigger binden laut
  Supersedes-Aufzählung fort.
* **Acceptance-Trigger und MR-007-Vergleich** — Runde gegen ADR-0058, ADR-0055 und
  `MR-007` gefahren; das Vorbild trägt (Manifest reist mit dem Gelieferten, ein zweiter
  Wächter hält die Herkunft, wo einer existiert — `make baseline-verify` gegen
  `SHA256SUMS` im vendored Baum).

## Verdikt

**Annahmefähig: ja** — nach Behebung von F-1, F-2, F-3 vor dem Umschlag. Keiner der drei
Befunde ändert eine der sechs Festlegungen; keiner ist blockierend im Sinne von ADR-0040
Festlegung 2. Die Accept-Zeile nennt als Beleg die **Kennung** dieses Reports
(`2026-09-19-adr-0059-accept-nachrunde`) und platziert den Index-Zusatz im selben Commit
wie den Umschlag (F-2).
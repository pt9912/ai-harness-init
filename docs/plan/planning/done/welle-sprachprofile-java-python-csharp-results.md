# Welle welle-sprachprofile-java-python-csharp — Sprachprofile java, python und csharp — Closure-Notiz

> **Zitier-Form** *(bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieses
> Artefakt friert ein; was es zitiert, bewegt sich weiter. Deshalb: **Kennung,
> nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>`
> statt eines Links auf die Sensor-Datei, eine Baseline-Stelle als
> `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link
> (Baseline-Regelwerk `grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — beim Ausfüllen mit dem adoptierten Tag schreiben).

**Welle:** welle-sprachprofile-java-python-csharp
**Abschluss:** 2026-10-20
**Verantwortlich:** pt9912

## Was wurde geliefert?

- `add-lang` rendert Java, Python und C# als Sprachskelett mit Code-Gate und Guard
  ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)):
  `slice-java-skelett` ([ADR-0094](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md)),
  `slice-python-skelett` ([ADR-0095](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md)),
  `slice-csharp-skelett` ([ADR-0096](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md)).
- `hexslice` je Sprache mit emittiertem Arch-Gate und `core-impurity`-Zahn
  ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)):
  `slice-java-hexslice-layout`, `slice-python-hexslice-layout`, `slice-csharp-hexslice-layout`
  ([ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) für die C#-Schreibweise).
- Das *Mehr*: `make full-smoke` trägt die Stufen 15 bis 19 und 25 (Java, Python, C#) neben Go, C++ und
  Kotlin, `make gates` grün auf demselben Commit (§Verifikation). Release `v0.10.0` liefert die drei Sprachen
  (außerhalb der Welle, Out-of-Scope §6).

## Was hat funktioniert?

- Die Kante Skelett vor Layout hielt: jeder Layout-Slice startete auf dem Gerüst seines Vorgängers.
- Das rote Gegenbeispiel (`core-impurity`) steht je Sprache als Stufe im E2E; der Verifier las die Meldung im
  lokalen Lauf und im `ci`-Log.
- Der Architect-Weg über Verdikt-Reports (Audit-Vorlage → Verdikt) trug vier Zählentscheidungen ohne
  Norm-Änderung.

## Was ging anders als geplant?

- **Schritt 4 nicht ausgeführt:** kein `done/*/archiv.zip`; `archive-welle` sperrt fail-closed an `[untergrenze]`
  (Ausgang unter *Verifikation*), die Welle schließt ohne Schritt 4.
- **Zwei Sensoren benannt, beide brauchen einen neuen Slice:** vorgeschlagen, **Entscheidung des Auftraggebers
  offen**, nicht geschnitten:
  `slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten` (Verdikt V-1) und
  `slice-mutate-branch-worker-wartet-die-publikation-ab` (V-2, dazu eine Pflichtzeile in `docs/user/releasing.md`).
- **Offen beim Auftraggeber, kein Slice:** die Behebung der macOS-Lage (der Treiber wählt auf Darwin selbst
  `artifact-host`) und der Change Request an [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (`slice-lh-qa-02-messmethode-bekommt-ihren-change-request` in `open/`).
- **[ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) Trigger 1 nicht eingetreten, kein Messauftrag** (Verdikt V-5): Der Pin-Zug auf a-check `v0.23.2`
  trägt keine Aussage zur Schreibweise; **Planner-Zusage, noch nicht gesetzt:** jeder künftige a-check-Pin-Slice
  bekommt in seine DoD *„Messung 2 von [ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) wiederholt: `Ports/Inbound` mit Hinweis oder ohne"*. Ein
  offener oder nächster a-check-Pin-Slice existiert nicht (`ls docs/plan/planning/{open,next,in-progress}`), die
  Zeile entsteht mit dem Slice-Plan.
- **Zählentscheidungen** (Verdikt `2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt`):
  Lesart *„nach der Verkörperung zählen"* (V-3); `lokaler-full-smoke-scheitert-auf-macos-host` greift nicht;
  `kosten-einer-emittierten-pruefung-im-ziel-ungemessen`: [`MR-089`](../../../../harness/conventions.md#mr-089) befolgt, kein Sensor (V-4).
- **Bestands-Lese-Schritt — Vorschläge, nichts stillgelegt:** `slice-messzahl-der-dod-liegt-im-lieferstand`,
  `slice-lh-qa-02-messmethode-bekommt-ihren-change-request`, `slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen`,
  `slice-113-co-001-ist-faellig`, `slice-141-co-001-aufloesung-ist-vorher-entschieden` und
  `slice-151-spec-straten-haben-eine-schreibende-rolle` bestätigt; Mutations- und Spezifikations-Gruppe bleiben
  offen (im Verdikt nicht gelesen).

## Steering-Loop-Einträge

Kein Eintrag erreicht im Fenster erstmals 3× ohne Ausgang; kein Zielort-Feld. Verkörperung oder Ausgang je
Eintrag laut Verdikt:

- **Sensor benannt, Slice vorgeschlagen:** `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`
  (11 Belege, Unterklasse Pin des realen `Makefile` vor der Publikation; nach der Publikation Sensor, davor
  keiner möglich). Stand wechselt auf *geplant*, sobald der Auftraggeber den Slice freigibt.
- **Neue Möglichkeit, Slice vorgeschlagen:** `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`
  (5 Belege, `make release-warten` im Worker-Vorlauf).
- **Zählregel, greift nicht:** `BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host` (1 Beleg nach der
  Verkörperung); `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` (3 Belege, einer nach der
  Verkörperung, kein viertes Auftreten); `BEO-ALL/pin-digest-ohne-waechter`,
  `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`.
- **Regel befolgt, kein Sensor:** `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`
  (kalter Wert im `ci`-Log).
- **Ausgang gesetzt, unberührt:** `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke` (verkörpert),
  `BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` und
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` (geplant).

## Beobachtungs-Register (Zeiger)

- Ablage: [`../observations/`](../observations/README.md). Lese-Schritt: `make register-ausgang` →
  `268 Eintraege, 78 ueber der Schwelle, 0 Befund(e)` (vor dem Self-Close-Commit). `state.md` ergänzt in den
  vier Einträgen `waechter-misst-die-fixture-statt-der-realen-quelle`,
  `ci-rennt-gegen-die-publikation-des-gepinnten-releases`, `lokaler-full-smoke-scheitert-auf-macos-host`,
  `kosten-einer-emittierten-pruefung-im-ziel-ungemessen`; ein neuer Eintrag entstand nicht.
- **Paarungen nach dem Move:** siehe *Paarungen* unten.

## Folge-Slices

Kein Folge-Slice angelegt. Die zwei vorgeschlagenen (siehe *Was ging anders als geplant?*) stehen als Text; sie
entstehen erst nach der Entscheidung des Auftraggebers. Übrige *geplant*-Ausgänge tragen
`slice-messzahl-der-dod-liegt-im-lieferstand` und `slice-lh-qa-02-messmethode-bekommt-ihren-change-request`
(beide in `open/`).

## Verifikation

- Schritt 1: Verifier-Beleg `docs/reviews/2026-10-20-welle-sprachprofile-java-python-csharp-trigger.md` auf
  `449eaeff` — die sechs Slices in `done/`; `make gates` Exit 0 (184 s); `make full-smoke-host` Exit 0 (415 s,
  warm); `ci` auf `449eaeff` und `d5f25549` success; je Sprache eine [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)-Stufe mit der Sprache in der
  Kurzbeschreibung (Java 15 und 25, Python 16 und 17, C# 18 und 19). Ein Replay-Set führt dieses Repo nicht.
- Schritt 2: `CO-001` *Auflösung fällig* (`slice-113`, `slice-141`), `CO-002` permanent, kein bootstrap-aware
  Gate; [ADR-0094](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md) bis
  [ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) ohne eingetretenen Trigger (Audit-Vorlage
  `docs/reviews/2026-10-20-welle-sprachprofile-java-python-csharp-audit-vorlage.md`, Verdikt
  `docs/reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md`).
- Schritt 4: `archive-welle --vorschau welle-sprachprofile-java-python-csharp` bricht fail-closed an zwei
  Sperren: `[untergrenze]` (kein `done/*/archiv.zip`, `ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l`
  → 0) und `[haenger]` (ein Review-Report soll verschwinden, auf den noch verwiesen wird, erstes Beispiel ein
  Beleg unter `BEO-ALL/neuer-waechter-ohne-mutations-fall` auf den Report zu `slice-sprung-auf-v6180-wird-vollzogen`).
  Die Welle schließt **ohne Schritt 4**; die Archivierung des Altbestands ist ein eigener Vorgang
  (`archive-welle altbestand`), `[haenger]` bleibt Sperre.
- `make docs-check` nach dem Move: 0 Befunde (erst nach dem Link-Nachzug; im Move-Commit selbst 17). Der Move
  nannte keinen Pfad in einer `Accepted`-ADR, [ADR-0092](../../adr/0092-aufgeloeste-welle-zieht-per-move-nach-done-die-adresse-folgt-im-zeitdokument.md)
  Trigger 3 ist nicht eingetreten; der einzige externe Pfad-Fund war `slice-benutzerhandbuch-fuehrt-java-python-csharp`.

## Paarungen

Geprüft am 2026-10-20 nach dem Move:

- **(a) Anker:** diese Notiz trägt kein Zielort-Feld. Im Fenster trägt `slice-python-hexslice-layout` in §7 ein
  `liegt in`, Zielort `AGENTS.md §3.6`; der Zielort existiert und trägt `seit slice-python-hexslice-layout`
  (`grep -n 'seit slice-python-hexslice-layout' AGENTS.md` → Zeile 165). Die Paarungs-Zeile des Slice selbst nennt
  *„kein Eintrag trägt das Feld"* — die Messung hier ist maßgeblich.
- **(b) Folge-Slice:** jeder genannte Slice existiert genau einmal im Lifecycle
  (`ls docs/plan/planning/{open,next,in-progress,done}/<kennung>.md | wc -l` → 1 für `slice-113`, `slice-141`
  (`next/`), `slice-151` (`next/`), `slice-messzahl-der-dod-liegt-im-lieferstand`,
  `slice-lh-qa-02-messmethode-bekommt-ihren-change-request`, `slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen`).
  Die zwei vorgeschlagenen Slices sind als Text genannt, kein Folge-Slice-Feld.
- **(c) Register:** erste Hälfte: jede genannte `BEO-ALL/<slug>` existiert mit 3 bis 16 Belegen. Register-Paarung
  (c), zweite Hälfte: 1 Verzeichnis ohne Beleg, namentlich `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`;
  nicht als getragen behauptet
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`).
  `make register-ausgang` → `268 Eintraege, 78 ueber der Schwelle, 0 Befund(e)`.

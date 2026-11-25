# Welle <welle-id>: <Titel>

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-baseline-sprung-v7-0-0-results.md`). Der Zustand ist
die Verzeichnis-Position — kein Status-Feld.

**Zielmeilenstein:** kein Meilenstein-Bezug (Betriebs-Welle: der adoptierte Stand, keine Nutzer-Fähigkeit).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-11-25.

---

## 1. Welle-Ziel

**Der adoptierte Baseline-Stand wandert `v6.18.1` → `v7.0.0` — committet vendored
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Form),
alle fünf Pin-Stellen fail-closed gekoppelt gezogen, und am Ende trägt der
Bestand die Delta-Adaption über der Adaptions-Block-Form; `make gates` ist grün.**

Der Sprung ist ein **Major** — der Delta-Umfang ist zu diesem Zeitpunkt nicht
geschätzt, und die Welle schneidet ihn deshalb nicht vorab: Ein Slice
vendorisiert, der zweite liest den neuen Baum gegen den Bestand und erzeugt
Befunde mit Schätzung; die **Cluster-Slices der Adaption** werden aus der Lesung
geschnitten und hier in §4 nachgetragen ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form
auch für sie). Zwischen dem Vendorier-Slice und der geschlossenen Adaption ist
der Voll-Gate-Lauf **erwartbar rot** — Befund-Zustand unter dem neuen
Regelwerk, geheilt von den Folgeslices **derselben Welle**, nicht mit Carveout
verklebt (ein Carveout wäre hier die falsche Antwort: der Zwischenzustand ist
geplant, nicht geduldet).

**Warum eine Welle.** Es gibt eine Closure-Bedingung, die mehr beobachtet, als
die DoDs ihrer Slices schon belegen (`modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht): `make gates` grün ist hier eine Aussage über den **Gesamt-Baum
nach allen Delta-Änderungen**, nicht über den Ausschnitt eines Slices; der
Replay-Lauf `make full-smoke` über ein frisch gebootstrapptes Ziel am neuen
Stand belegt die emittierte Ebene, die keine einzelne DoD trägt; und der
Bestands-Lese-Schritt liest die offenen Slices unter `open/` gegen die
geschlossene Welle. Keiner dieser drei Belege steht in einer einzelnen DoD.

## 2. Trigger (Welle startet)

- **Start-Trigger: der Slice `slice-gates-fastpfad-ueber-stempel` liegt in `done/`.**
  Beobachtbar: [`slice-gates-fastpfad-ueber-stempel`](done/slice-gates-fastpfad-ueber-stempel.md)
  führt `ls docs/plan/planning/in-progress/` nicht mehr — er liegt in `done/`.
  Er liegt in keiner
  Slice-Liste dieser Welle — er ist kein Ergebnis
  derselben. Zum Eröffnungs-Moment (Datum oben) liegt er noch in
  `in-progress/`: die Eröffnung folgt dem **Auftrag des
  Auftraggebers**, der sie vor dem Slice-Abschluss entschieden hat; die Slices
  dieser Welle übernehmen die Arbeit erst nach seinem Eintreten (ihr §4-Trigger).

## 3. Closure-Trigger (Welle schließt)

- Alle Slices dieser Welle (§4) in `done/`.
- `make gates` grün — über dem **Gesamt-Baum am neuen Stand** , nach der
  geschlossenen Delta-Adaption; die Zwischen-Rots aus §1 sind sie nicht.
- `make full-smoke` grün — der Replay des emittierten Bootstrap: das frisch
  gebootstrappte Ziel bootstrapt out-of-the-box am neuen Baseline-Stand
  ([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)); der
  Lauf ist der Beleg, den der Vendorier-Slice allein nicht trägt.
- Closure-Notiz in `welle-baseline-sprung-v7-0-0-results.md` mit
  Steering-Loop-Eintrag; der **Bestands-Lese-Schritt** der Welle-Closure liest
  die bestehenden offenen Slices unter `open/`, die diese Closure
  unverändert übersteht (Modul 6 §Wellen-Closure-Prozedur, Schritt 3).

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| [`slice-baseline-vendorung-v7-0-0`](open/slice-baseline-vendorung-v7-0-0.md) | Vendorierung + Pin-Kopplung | [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [`slice-baseline-delta-lesung-v7-0-0`](open/slice-baseline-delta-lesung-v7-0-0.md) | Delta-Lesung mit Schätzung | [`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist), [`MR-037`](../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst) |

**Reihenfolge.** Erst die Vendorierung (Baum + Pins), dann die Lesung (Befunde
am neuen Stand); die Cluster-Slices der Adaption werden aus der Lesung geschnitten
und hier ergänzt — sie stehen bis dahin nicht in der Tabelle, und die Tabelle
behauptet nichts über sie.

### Delta-Befunde (Les-Stand, geführt von slice-baseline-delta-lesung-v7-0-0)

Die Tafel entsteht mit der Lesung in dieser Datei (Klasse-1-Begründung in deren
§1). Konsument sind die Cluster-Slices: **je Befundzeile** trägt eine
Cluster-Slice-Kennung (Slice-Datei in `open/`), eine ausdrückliche
**Ablehnung mit Grund** oder die **Deckung durch Bestand mit Zeiger** — keine
Zeile nur mit Schätzung. Stand vor der Lesung: nicht geführt.

## 5. Abhängigkeiten

- **Blockiert:** nichts. Die offene Welle
  [`welle-09`](welle-09-modul-15-konformitaet.md) führt einen getrennten
  Gegenstand (Modul-15-Konformität); beide Wellen stehen getrennt.
- **Wird blockiert von:** dem Start-Trigger (§2); werkzeugseitig von der
  Verfügbarkeit des `v7.0.0`-Release-Assets — `make vendor-baseline` braucht
  Netz an genau diesem Aufruf ( [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Form).

## 6. Out-of-Scope für diese Welle

- **Der d-check-Pin-Sprung (v0.93.0)** — er läuft als **wellenloser Slice
  daneben**, nicht hier: die Werkzeug-Fassung ist ein anderer Vorgang
  (d-check-Mechanik `d-check.mk`-Pin, [`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-012`](../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)-Linie)
  und berührt den Adoptierungs-Gegenstand dieser Welle — den Regelwerk-Baum —
  nicht.
- **Änderungen am emittierten Werkzeug-Verhalten, die nicht aus dem v7-Delta
  folgen** — ein anderer Vorgang: sie gehen aus einzelnen Befund-Arten hervor
  (Futter für einzelne Slices, kein Welle-Gegenstand); die Welle nimmt nur, was
  das Delta verlangt.
- **Das Bestands-Audit der offenen Slices unter `open/`** — es liegt
  an einem **anderen Punkt**: beim Lese-Schritt der **Welle-Closure** (Modul 6
  §Wellen-Closure-Prozedur, Schritt 3 — *„Was den Bestand überlebt hat, bekommt
  denselben Lese-Schritt"*). Hier ausdrücklich dorthin gelegt, nicht still
  fallen gelassen.
- **CI-Workflow-Änderungen** — kein eigener Gegenstand: die CI ruft
  ausschließlich `make`-Targets ([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) und
  folgt den Gates, sie führt sie nicht. Nur falls das v7-Delta sie verlangt,
  wird sie ein Befund der Lesung — kein eigener Slice vor der Lesung.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen; Verweis auf
welle-baseline-sprung-v7-0-0-results.md (Geschwister im Ruheort done/) und das
Beobachtungs-Register (eine Ebene über dem Ruheort). -->

# Slice slice-der-mutations-treiber-sieht-bindung-und-abdeckung: Der Mutations-Treiber sieht, welche Zusicherung ein Fall bindet und welcher Wächter keinen Fall hat

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`AGENTS.md`](../../../../AGENTS.md) §3.6,
[`MR-002`](../../../../harness/conventions.md#mr-002),
[`MR-071`](../../../../harness/conventions.md#mr-071).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `harness/tools/mutate.sh` prüft je Fall die Zusicherung, die er bindet, statt nur den
Wächter-Namen, und zählt die Wächter, die kein Fall nennt, mit ihrer Bezugsmenge. Beide Hälften lesen
dasselbe Kopf-Feld `# expect:` und gehen deshalb in einen Zug — zwei Slices hießen zwei Parser.

**Übernimmt:** `slice-069-zahn-bindet-zusicherung`, `slice-119-zusage-ohne-fall-wird-sichtbar`.
Ihre Ist-Messungen, die fünf historischen Instanzen (069 §1) und die Fragen A–C (119 §3) bleiben in
`done/` lesbar; dieser Plan zitiert sie und schreibt sie nicht ab.

**Stand vor dem Slice** (keine Erwartungswerte): `grep -c 'fails-at' harness/tools/mutate.sh` → 0.
Der Greift-Modus `make mutate-greift` (`slice-mutations-anker-greift-in-den-gates`) prüft, ob die
Mutation eines Falls greift; welche Zusicherung sie bindet und welcher Wächter keinen Fall hat, prüft
er nicht. Keiner der beiden Gegenstände ist damit erledigt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Fehlende Fälle für Pin-Kopplung und `sync` — Folge-Slice
  `slice-pin-kopplung-und-sync-tragen-ihre-mutations-faelle` (Instanzen, kein Treiber-Code).
- Nacharbeit am Bestand, den der Zähler nennt — Bestand bleibt stehen; der Slice liefert Sichtbarkeit
  und Schnitt, sonst ist er in einer Review-Sitzung nicht prüfbar.
- Prüfbereich von `make comment-claims` — `slice-070-comment-claims-pruefbereich`.
- Die Norm-Fassung der Entscheidungen aus DoD (3) — Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice liefert die Übergabe.

## 2. Definition of Done

- [ ] **(1) Der Fall bindet seine Zusicherung.** Der Treiber prüft je Fall den erwarteten
      Fehlschlag-Text, nicht nur den Wächter-Namen; ob das Feld `# expect:` ersetzt oder ergänzt,
      entscheidet der Implementer gegen das Risiko *zweite Wahrheit* (§6). **Rot:** ein falscher Text
      ergibt einen Befund; mindestens eine der fünf Instanzen aus `slice-069-zahn-bindet-zusicherung`
      §1 ist nachgestellt und wird Befund; ein Fall in `test/mutations/` hebelt das neue Feld aus.
- [ ] **(2) Der Treiber zählt Wächter ohne Fall** — *„N von M"* mit Nenner in derselben Zeile, über
      bats-Titel und Go-Testfunktionen oder mit begründeter Wahl einer Schicht; ein Schritt an einem
      vorhandenen Ziel, kein neues `make`-Ziel. **Rot:** ein von einem Fall genannter Titel wird
      umbenannt und steht danach in der Liste; eine Instanz aus `slice-117-lauf-ohne-ende-faerbt-rot`
      wird benannt; ein Fall über dem Zähl-Schritt.
- [ ] **(3) Migration und Schnitt sind entschieden, nicht angefangen.** Ob der Bestand das Feld aus
      (1) rückwirkend bekommt und welcher Schnitt die Zählung aus (2) trägt (Stichtag ·
      fail-closed-Zusage · reiner Zähler), steht begründet im Plan; wird eine Adaption daraus, liegt
      die Übergabe an den Architect vor
      ([`MR-002`](../../../../harness/conventions.md#mr-002)). **Rot:** eine Fassung ohne Schnitt ist
      über dem Bestand dauerhaft rot.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: `harness/sensors/mutate.md` nennt Zusicherungs-Prüfung, Zählung und deren Grenze.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Kopf-Parsing und Bedingung 4 auf Zusicherung (1); Zähl-Schritt (2) |
| `test/mutate-driver.bats` | update | Fälle für (1) und (2), dazu der Vorlauf-Zweig mit unbekanntem `# verify:`-Modus (069 §3) |
| `test/mutations/` | neu | je ein Zahn für (1) und (2), Anker nach [`MR-071`](../../../../harness/conventions.md#mr-071) |
| `harness/sensors/mutate.md` | update | Vertrag und Grenze |
| `harness/conventions.md` | nur Übergabe | Entscheidungen aus (3), falls eine Adaption folgt |

- Reihenfolge (1) vor (2): der Zähl-Schritt liest das Kopf-Feld in der Form, die (1) festlegt.

## 4. Trigger

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice, der Slice ist priorisiert.

**Rückführungen:**

- `in-progress` → `next`: die Bestands-Migration sprengt den Slice — dann trennt ein Re-Slice Mechanik
  von Migration.
- `in-progress` → `open`: jeder tragfähige Schnitt verlangt eine Adaption, die noch nicht steht, oder
  der Fehlschlag-Text ist je Sensor-Modus zu verschieden für ein Feld.

## 5. Closure-Trigger

DoD (1)–(3) mit gelesenen roten Läufen; je eine historische Instanz aus beiden übernommenen Slices
reproduziert; Review konform, Verifikation bestätigt; `make gates` grün; Closure-Notiz mit
Lerneintrag.

## 6. Risiken und offene Punkte

- Ein zweites Kopf-Feld driftet gegen `# expect:`. — **Ausgang:** bei Closure.
- Der Fehlschlag-Text hängt an der Formulierung eines Tests; Umformulierung meldet laut. — **Ausgang:** bei Closure.
- Der Bestand ist groß (`ls test/mutations/*.sh | wc -l`); eine Teil-Migration darf nicht wie Vollständigkeit aussehen. — **Ausgang:** bei Closure.
- Der Treiber bewacht sich nur teilweise (`failure_form`, nicht alle `run_case`-Zweige). — **Ausgang:** bei Closure.
- Ein Zähler ohne Schwelle wird ignoriert. — **Ausgang:** bei Closure.
- Ein Schnitt gegen `git` bricht in Kopien ohne `.git`. — **Ausgang:** bei Closure.
- Der Zähl-Schritt ist selbst ein Wächter ohne Fall, solange (2) ihn nicht hält. — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `harness/tools/` (`TOOLS`) und `*` (`ALL`, für `test/` und
`harness/sensors/`); beide erfüllen die Schwelle (eigene Regel-Form, eigener Prüfbereich, eigene
Fehlermodi). `CODEX` nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** vier Einträge stehen `geplant` auf diesem Slice
(Zähler: `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, 2026-10-09, keine
Erwartungswerte): `neuer-waechter-ohne-mutations-fall` (19),
`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` (6, Klasse),
`zusage-nennt-zwei-kanten-der-sensor-deckt-eine` (6),
`zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` (9). Alle über der Schwelle, Ausgang
gesetzt; kein weiterer Folge-Slice.

**Modus:** alle berührten Sub-Areas GF.

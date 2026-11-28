# Slice slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen: Emittierte Dateien tragen nur Kennungen, die im Ziel auflösen, und ein Wächter hält die Menge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-057`](../../../../harness/conventions.md#mr-057), [`MR-059`](../../../../harness/conventions.md#mr-059).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner (Gruppierungs-Durchgang, `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3). **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Kein emittierter Kommentar und keine emittierte Meldung trägt eine Kennung (`ADR-NNNN`,
`LH-XX-NN`, `MR-NNN` mit Ziffern), die im Ziel nicht auflöst; die Zusage steht in Worten, die Meldung
nennt den Satz, nach dem der Anwender handelt — und ein Go-Test in `cmd/ai-harness-init/` hält die
Eigenschaft über die reale Emission; nur über `run()` sieht er auch die Emission aus `internal/gen`.
Gebunden sind die emittierten **Dateien**; die Laufzeit-Meldungen des Binärs nicht (§6).

**Übernimmt:** `slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung`,
`slice-emittierte-dateien-tragen-keine-nicht-aufloesende-kennung`. Geteilte Ursache: dieselbe
Fundmenge unter demselben Kommando; der Schnitt in Träger-Familie und Rest erzwang eine Reihenfolge
(der Wächter durfte erst nach dem Träger-Slice grün starten), die hier entfällt.

**Lage** (keine Erwartungswerte):
`git grep -cE '\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3})\b' -- 'internal/emit/templates' ':!*_test.go'`
und dasselbe Muster über `internal/emit/*.go` — dort zählt es auch die Quell-Kommentare des
Werkzeugs mit, die nicht emittiert werden; maßgeblich ist darum die Fundmenge über der **realen**
Emission, die der Wächter (Liefer-Punkt 2) misst. Zwei Zeilen sind funktionale Nutzlast — der
Default-Commit-Text der Selbstprüfung (`SELBSTPRUEFUNG_MSG_GRUEN`) in `selbstpruefung.sh` und
`selbstpruefung.mk` muss ein Kennungs-Muster des Ziels treffen
(`git grep -n 'SELBSTPRUEFUNG_MSG_GRUEN' -- internal/emit/templates`) — und bleiben als namentliche Ausnahme.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kennungen, die das Ziel selbst führt** (Platzhalter-Form, emittierte Register). *Bestand bleibt:*
  sie lösen im Ziel auf.
- **Prosa-Verweise ohne Ziffernform** und die Frage, ob ein Ersatz-Wortlaut die Zusage trägt.
  *Anderer Vorgang:* Urteil des Reviews, kein Sensor.
- **Dogfood-Skripte und Quell-Kommentare des Werkzeugs.** *Anderer Vorgang:* Dogfood-Ebene
  ([`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1). Ausgenommen
  `harness/tools/traeger-fetch.sh`: er zieht als erzwungene Folge mit, weil
  `test/traeger-fetch.bats` (Fall *„transport-skript: der Dogfood-Zwilling ist byte-gleich mit dem
  emittierten"*, `cmp`) ihn byte-gleich zur Vorlage hält.
- **Namensform-Kennungen** (`slice-<name>`). *Bestand bleibt:* mit einem einfachen Muster nicht von
  Werkzeugnamen (`slice-mv`) trennbar; `GRENZE` im Testkopf, Register (§7).
- **Zweige, die der Test nicht fährt** (nicht gesetzte Flag-Kombinationen). *Bestand bleibt:* benannte
  Lücke.

## 2. Definition of Done

- [x] **1 — Wortlaut statt Kennung:** die Kommentare und Meldungen aller emittierten Dateien
      (Träger-Familie `traeger-fetch.sh`/`traeger.mk` und die übrigen) tragen keine Kennung außer den
      zwei Nutzlast-Zeilen; Tests, die eine Meldung zitieren (`grep -rn '<präfix>:' internal test`),
      ziehen mit und halten die Aussage statt der Kennung.
      **Rot-Werkzeug:** der Wächter aus Liefer-Punkt 2, zuerst über dem unveränderten Bestand
      gefahren (`make test-go`): rot, und seine Meldung nennt je Datei die Fundmenge; nach dem
      Nachzug grün mit genau den zwei Nutzlast-Zeilen.
- [x] **2 — Wächter:** ein Go-Test in `cmd/ai-harness-init/` (über `run()`, damit auch die
      `internal/gen`-Emission) emittiert jede Lauf-Variante (Sprache,
      `--arch`, mit/ohne Erfassung) in ein Temp-Verzeichnis und vergleicht die Fundmenge mit der
      namentlichen Liste *Datei → Kennungs-Menge* auf Gleichheit in beide Richtungen, über die
      **reale** Emission. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), beide
      Richtungen: eine erfundene Kennung in einer Vorlage → rot mit Dateiname; eine Ausnahme aus der
      Liste gestrichen → rot. **Rot-Werkzeug:** zwei Fälle in `test/mutations/` (`verify: test-go`,
      `sed`-Anker gegen den Quell-Bestand, [`MR-071`](../../../../harness/conventions.md#mr-071)):
      einer setzt eine erfundene Kennung in eine emittierte Vorlage, einer streicht eine Nutzlast-Zeile
      aus der Ausnahme-Liste des Tests; `make mutate MUTATE_CASES=<nr>` meldet beide gebunden, die
      Fehlermeldung ist gelesen und als `expect:` eingetragen.
- [x] `make gates` grün; `make mutate` für die zwei neuen Fälle ohne Befund.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/**`, `internal/emit/*.go` (Meldungs-Strings) | update | Liefer-Punkt 1 |
| Tests, die eine geänderte Meldung zitieren | update | Liefer-Punkt 1 |
| `internal/gen/*.go` (Kommentare der generierten Dateien) | update | Liefer-Punkt 1 |
| `harness/tools/traeger-fetch.sh` | update | Folge der Byte-Gleichheit mit der Vorlage (`test/traeger-fetch.bats`) |
| `cmd/ai-harness-init/kennungen_test.go` (neuer Wächter), `test/mutations/` | neu | Liefer-Punkt 2 — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der Meldungs-Nachzug zieht mehr Tests nach, als eine Review-Sitzung trägt —
  dann zuerst Liefer-Punkt 1 je Datei-Familie schneiden, der Wächter folgt.
- `in-progress` → `open`: eine Meldung braucht die Kennung als Nutzlast über die zwei bekannten hinaus
  — Übergabe an den Architect, ob die Ausnahme-Menge wächst.

## 5. Closure-Trigger

1. `make gates` grün, beide Mutations-Fälle als gebunden gemeldet.
2. Die Fundmenge des Wächters ist gleich der Ausnahme-Liste (zwei Nutzlast-Zeilen), gelesen in §7.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Eine Meldung verliert mit der Kennung die einzige Fundstelle für den Anwender.** — **Ausgang:**
  weiter offen — in den emittierten Dateien nennt jede Meldung weiter, was fehlt (Review (a)); die
  Laufzeit-Meldungen des Binärs tragen weiter Kennungen, die im Ziel nicht auflösen (Review INFO-1):
  Register
  [`BEO-ALL/laufzeit-meldung-traegt-im-ziel-nicht-aufloesende-kennung`](../observations/BEO-ALL/laufzeit-meldung-traegt-im-ziel-nicht-aufloesende-kennung/observation.md).
- **Eine Lauf-Variante emittiert eine Datei, die der Test nicht fährt.** — **Ausgang:** entfallen —
  add-lang im Unterverzeichnis per Probe ohne Fund (Review (b)); die nicht gefahrenen
  Flag-Kombinationen sind §1-Ausschluss und als `GRENZE` im Testkopf benannt.
- **Der Ersatz-Wortlaut trägt die Zusage nicht.** — **Ausgang:** entfallen — alle geänderten Zeilen
  gelesen, keine Zusage verloren (Review (a)).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-08

- **Was hat funktioniert:** DoD 1 und 2 bestätigt
  ([Verifikation](../../../reviews/2026-10-07-kennungen-verifikation.md)); DoD 1 rot am realen
  Vorzustand (`internal/` auf `c5bc8656^`, 16 Dateien mit Fundmenge), danach grün mit genau den zwei
  Nutzlast-Zeilen. Fälle 558, 559, 560 binden (`make mutate MUTATE_CASES=…` → ok, 0 Befund(e)).
- **Was ging anders als geplant:** HIGH-1 des [Reviews](../../../reviews/2026-10-07-kennungen-review.md)
  (Formen-Grenze ungenannt) behoben in `78dd879f`: das Muster erkennt zusätzlich `SPEC-`, `CO-`,
  `slice-NNN`, `welle-NN`. Testort `cmd/` statt `internal/emit/` und die Mitänderung von
  `harness/tools/traeger-fetch.sh` standen in keinem Plan-Text; §1/§2/§3 nachgezogen.
- **Steering-Loop-Eintrag:** neuer Sensor —
  `TestEmittierteDateienTragenNurImZielAufloesendeKennungen` in `cmd/ai-harness-init/kennungen_test.go`
  hält die Kennungen der realen Emission (sieben Lauf-Varianten) gegen die namentliche Ausnahme-Liste.
  Grenze: Laufzeit-Meldungen, Namensform-Kennungen, `d-check.mk` als Fixture.
- **Beobachtungs-Register (`../observations/`):** neu
  [`BEO-ALL/laufzeit-meldung-traegt-im-ziel-nicht-aufloesende-kennung`](../observations/BEO-ALL/laufzeit-meldung-traegt-im-ziel-nicht-aufloesende-kennung/observation.md)
  und
  [`BEO-ALL/namensform-kennung-in-emittierter-datei-ohne-sensor`](../observations/BEO-ALL/namensform-kennung-in-emittierter-datei-ohne-sensor/observation.md)
  (je 1 Beleg).
- **Folge-Slices:** keine.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR: kein
  Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine entfernt.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-08** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  nichts zu prüfen. (b) *Folge-Slice*: keiner genannt. (c) *Register*: die zwei genannten Pfade
  existieren, `evidence/` trägt je 1 Datei. Zweite Hälfte über das ganze Register: 3 Verzeichnisse
  ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`internal/emit/`, `test/`); `TOOLS` und
`CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert) — benachbarte
Klasse, nicht dieselbe: dort reicht die Zusage weiter als die Wirkung, hier zeigt die Adresse ins Leere.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).


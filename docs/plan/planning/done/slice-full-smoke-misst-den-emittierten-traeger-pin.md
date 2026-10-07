# Slice slice-full-smoke-misst-den-emittierten-traeger-pin: `full-smoke` misst den emittierten Träger-Pin unter Adopter-Bedingung

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

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 1). Anlass: Review-Finding F4 zu
`slice-full-smoke-erkennt-unveroeffentlichtes-artefakt` ([Review](../../../reviews/2026-10-07-404-review.md)).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Stufe `make traeger-fetch im frischen Klon` liest `TRAEGER_TAG` aus dem emittierten
`traeger.mk` des Ziels statt aus dem Dogfood-Export; ein falscher Variablenname im Fragment färbt
einen Wächter rot, und Stufe 5 der E2E-Sicht nennt, was sie misst.

**Lage** (keine Erwartungswerte): `grep -n 'export TRAEGER_TAG' Makefile` zeigt den Export, den
`make full-smoke` vererbt; `grep -n 'TRAEGER_TAG' internal/emit/templates/enforce/traeger.mk` die
`?=`-Zuweisung, die ihm nachgibt; `grep -n 'traeger-fetch' harness/tools/full-smoke.sh` den Aufruf
`make -C "$klon" traeger-fetch` in Stufe 5, der den Export erbt; `pin_wert` in
`test/traeger-fetch.bats` greift per Präfix (`grep "^$2"`: `TRAEGER_TAGX ?= v0.5.0` liefert
`v0.5.0`). `test/mutations/553-…` setzt `=` statt `?=`, gerade weil der Export einen `?=`-Wert
überdeckt — sein Kopfkommentar beschreibt damit die Lage, die dieser Slice aufhebt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Kopplung des Pin-Werts.** *Bestand bleibt:* der Fall `pin-kopplung` hält beide Stellen in
  `make gates` gegen das Literal.
- **Das Rennen gegen die Publikation.** *Folge-Slice:* `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`.
- **Andere geerbte Dogfood-Exporte** (`TRAEGER_CARRIER`, `TRAEGER_SHA256_*`, Zeile 53 des
  `Makefile`). *Anderer Vorgang:* gemessen wird hier nur `TRAEGER_TAG`; ein weiterer Fund geht ins
  Register (§6).
- **Der Export im Dogfood-`Makefile`.** *Bestand bleibt:* `make traeger-fetch` im Dogfood braucht
  ihn; entkoppelt wird am Aufruf im Ziel, nicht an der Quelle.

## 2. Definition of Done

- [x] **1 — Adopter-Bedingung:** jeder `make -C "$klon" traeger-fetch`-Aufruf in Stufe 5 läuft
      ohne geerbten `TRAEGER_TAG` (`env -u TRAEGER_TAG`; eine Kommandozeilen-Zuweisung über
      `MAKEFLAGS` erreicht den Klon ebenso nicht), der Tag kommt aus dem emittierten `traeger.mk`.
      **Rot gesehen** an der realen Quelle, `make mutate MUTATE_CASES=…`: ein neuer Fall
      (`verify: full-smoke`) benennt in `internal/emit/templates/enforce/traeger.mk` die Zeile
      `TRAEGER_TAG ?=` in `TRAEGER_TAGX ?=` um — gebunden, die FEHLER-Zeile der Stufe gelesen
      („nicht gesetzt" ist ihr Grund); und die Gegenprobe ohne `env -u` bleibt grün. Fall 553 fährt
      wieder `?=` statt `=`, sein Kopfkommentar nennt die neue Lage, und er bleibt gebunden.
- [x] **2 — Namens-Bindung:** `pin_wert` liest genau `^<name> ?=` (kein Präfix-Treffer); ein Fall
      (`verify: test-bats`) mit derselben Umbenennung in `traeger.mk` färbt `pin-kopplung` rot,
      gegen `pin_wert` in der heutigen Präfix-Form bleibt er grün (Gegenprobe gelesen).
- [x] **3 — E2E-Sicht:** die Stufen-Deklaration von Stufe 5 nennt, dass der Pin des Laufs der des
      emittierten Fragments ist; `make e2e-abdeckung` zieht
      [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) nach.
- [x] `make gates` grün.
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
| `harness/tools/full-smoke.sh` | update | Stufe ohne geerbten Pin, Stufen-Deklaration (Liefer-Punkte 1, 3) |
| `test/traeger-fetch.bats` | update | `pin_wert` mit exaktem Namen (Liefer-Punkt 2) |
| `test/mutations/` | neu + update | zwei Fälle `TRAEGER_TAGX` im Fragment (`full-smoke`, `test-bats`); 553 auf `?=` — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: eine andere Stufe braucht den geerbten Export, und das Entkoppeln zieht sie
  mit — dann die Stufen einzeln schneiden.
- `in-progress` → `open`: die Adopter-Bedingung verlangt Netz an einer weiteren Stelle — Übergabe an
  den Architect.

## 5. Closure-Trigger

1. `make gates` und `make full-smoke` grün, die zwei neuen Fälle und 553 als gebunden gemeldet.
2. Die FEHLER-Zeile des Namens-Falls gelesen (§7).

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Weitere Stufen erben Dogfood-Exporte** — dieselbe Klasse an anderem Pin. — **Ausgang:** offen bis
  zur Closure. — **Ausgang:** eingetreten: `slice-full-smoke-faehrt-den-adopter-pfad-ueber-sha256sums`
  (Stufe 5 erbt `TRAEGER_SHA256_*` und fährt den Pin-Kanal statt `SHA256SUMS`, Review LOW-1).
- **Netz:** die `full-smoke`-Fälle brauchen Netz und laufen fast voll durch (Kopf von 553) — ohne
  Netz kein Rot-Beleg für Punkt 1. — **Ausgang:** entfallen — der Rot-Beleg zu Fall 554 liegt mit
  Netz vor, samt Gegenprobe ([Verifikation](../../../reviews/2026-10-07-traeger-pin-verifikation.md)).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** DoD 1–3 bestätigt; Fall 554 an der realen Quelle rot mit der
  FEHLER-Zeile „nicht gesetzt", ohne `env -u` grün; `make full-smoke` grün
  ([Verifikation](../../../reviews/2026-10-07-traeger-pin-verifikation.md)). Review 0 HIGH/MEDIUM
  ([Review](../../../reviews/2026-10-07-traeger-pin-review.md)).
- **Was ging anders als geplant:** Der Laufzeit-Satz im Kopf von 553/554 („fast voll") trifft nicht
  zu, der Lauf bricht nach rund 18 s an der Stufe ab (Review INFO-1) — Bestand, Korrektur geht mit dem
  Folge-Slice, der dieselben Fälle anfasst. `-u MAKEFLAGS -u MFLAGS` über den Plan hinaus, vom DoD-Text
  gedeckt.
- **Steering-Loop-Eintrag:** benannte Sensor-Lücke — kein E2E-Lauf fährt den Verifizierungs-Kanal des
  Adopters über `SHA256SUMS`; `full-smoke` erbt die Digest-Pins, `smoke` fetcht nicht. Gezählt, nicht
  verkörpert; Adresse ist der Folge-Slice.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  Beleg `evidence/slice-full-smoke-misst-den-emittierten-traeger-pin.md` ergänzt, Stand unverändert
  (verkörpert).
- **Folge-Slices:** `slice-full-smoke-faehrt-den-adopter-pfad-ueber-sha256sums` — Datei in `open/`.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR:
  [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) umgesetzt, kein
  Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-07** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  nichts zu prüfen. (b) *Folge-Slice*: `ls docs/plan/planning/*/<kennung>.md` nennt eine Datei in
  `open/`. (c) *Register*: der genannte Pfad existiert, `evidence/` trägt 11 Dateien. Zweite Hälfte
  über das ganze Register: 3 Verzeichnisse ohne Beleg, namentlich
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `TOOLS` (`harness/tools/full-smoke.sh`) und `*`
(`test/`, `docs/user/`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert; Beleg aus dem
Anlass-Slice ergänzt) — Liefer-Punkt 3 trägt die Teilmessung.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).


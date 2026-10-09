# Slice slice-kotlin-freshness: freshness-kotlin meldet einen neueren Gradle-Image-Tag

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-kotlin-skelett](welle-kotlin-skelett.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make freshness-kotlin` meldet, ob für den gepinnten `gradle:<ver>-jdk<NN>`-Tag ein neuerer
existiert — kein Gate, wie `freshness-cpp`.

**Ausdrücklich NICHT in diesem Slice:**

- Den Pin heben — anderer Vorgang; das Werkzeug meldet nur.
- Kotlin-Plugin- und Lint-Version im Gerüst — sie stehen per Version im Gerüst, nicht im Image-Tag;
  ein Sensor dafür wäre ein eigener Schnitt.

## 2. Definition of Done

- [x] `kotlin-freshness.sh` unter `harness/tools/` + `make freshness-kotlin`; Zeile in `harness/README.md`
      §Werkzeuge mit `kein Gate`.
- [x] bats-Fall: veralteter Pin → Meldung, aktueller → still; das Rot einmal gesehen.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`; nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `kotlin-freshness.sh` unter `harness/tools/`, `Makefile` | neu / update | Werkzeug und Ziel |
| `harness/README.md` | update | Werkzeug-Zeile |
| `test/kotlin-freshness.bats` | neu | beide Richtungen |
| `.github/workflows/upstream-drift.yml` | update | Aufrufer im Nachtlauf, wie `freshness-cpp`; der Gate-Lauf bleibt netzlos (§6) |
| `test/mutations/` | neu | je Zusage des Skripts ein Fall mit Gegenprobe |
| `.d-check.yml` | update | `exempt-targets` führt das neue Ziel; folgt aus der Werkzeug-Zeile (nachgezogen bei Closure) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-flaches-skelett` liegt in `done/` (der Pin existiert).

**Rückführungen:**

- `in-progress` → `next`: die Tag-Liste des Image-Registers trennt Gradle- und JDK-Achse nicht — Schnitt
  je Achse.
- `in-progress` → `open`: das Register ist netzlos nicht erreichbar und braucht einen anderen Träger.

## 5. Closure-Trigger

DoD vollständig, bats-Fall grün und einmal rot gesehen, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Das Werkzeug braucht Netz; ein Ausfall des Registers darf keinen Gate-Lauf blockieren — **Ausgang:** entfallen — `freshness-kotlin` läuft nur nächtlich, außerhalb
  von `gates`/`record-gates`; ein Fetch-Ausfall endet in `FETCH-FEHLER (kein Freshness-Urteil)`,
  Exit 2 (Verifikation `2026-10-09-slice-kotlin-freshness-verifikation`).

## 7. Closure-Notiz

- **Was hat funktioniert:** Keine Rückführung aus §4 trat ein; die Tag-Liste trennt die Achsen über
  den Filter `name=jdk21`. Der Verifier fuhr den echten Pin aus `DefaultKotlinVersion` in drei Zweigen
  live (aktuell · VERALTET · KEIN URTEIL) und trug den Rot-Beleg für DoD 2 nach (`head`/`tail`-Mutation
  → Fall 2 rot, invertierter Vergleicher → Fall 3 rot); `make mutate` über 629–634 → `6 ok, 0 Befund(e)`.
- **Was ging anders als geplant:** Review LOW-1 — ein Pin über allen gelieferten Tags meldete
  `aktuell`; seit `440a1ac6` gibt er `KEIN URTEIL`, Exit 2. `.d-check.yml` war geändert, ohne in §3 zu
  stehen (INFO-V2); §3 nachgezogen.
- **Steering-Loop-Eintrag:** geschärfte Regel, gezählt, nicht verkörpert — die Laufzeit-Meldung eines
  Freshness-Werkzeugs nennt die Grenze ihrer Eingabe (eine Seite, sortiert nach `last_updated`) im
  Ausgabetext, nicht nur im Skript-Kopf; `aktuell`/`VERALTET` des gemeinsamen Vergleichers und der
  `##`-Hilfetext tragen sie nicht (INFO-V1, hingenommen, kein weiterer Implementer-Zyklus). Beleg in
  `BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben`, Ausgang dort geplant
  (`slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`).
- **Beobachtungs-Register (`../observations/`):** Belege in
  `BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben` (LOW-1 und INFO-V1, ein Vorgang, geplant) ·
  `BEO-ALL/plan-abweichung-landet-im-commit-bericht-statt-im-plan` (INFO-V2, verkörpert). Benannt,
  nicht gezählt: Review INFO-2 — `freshness-kotlin` und die übrigen `freshness-*` stehen in
  verschiedenen `exempt-targets`-Gruppen, und `harness/sensors/docs-check.md` nennt „heute 40“ neben
  einem Kommando, das 49 ausgibt; Bestand, vom Diff nicht berührt. Kein Eintrag erreicht mit diesem
  Slice 3× ohne Ausgang.
- **Folge-Slices:** keine.
- **Paarungen geprüft am 2026-10-09:** (a) kein Eintrag in §7 trägt das Zielort-Feld · (b) keine
  Folge-Slices genannt; die Register-Kennung `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`
  liegt unter `open/` · (c) die zwei hier genannten `BEO-ALL/…` existieren, `evidence/*.md` 8 bzw. 7;
  zweite Hälfte über das Register: 2 Verzeichnisse ohne Beleg, namentlich
  `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` und
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet (Kommando:
  Schleife über `BEO-ALL/*/evidence/*.md`, `close-welle.md` Schritt 3).
- **Risiken aus §6:** Ausgang steht in §6.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-09):
`neuer-waechter-ohne-mutations-fall` — 19, geplant; jeder neue Kotlin-Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 4, geplant; Kotlin pinnt per Tag ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2) ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — offen; trifft das Kotlin-Image gleich ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 2, offen; neue full-smoke-Stufen erben ihn.

**Modus:** alle berührten Sub-Areas GF.

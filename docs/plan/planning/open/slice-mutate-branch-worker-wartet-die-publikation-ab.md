# Slice slice-mutate-branch-worker-wartet-die-publikation-ab: Der Worker des Mutations-CI-Branches wartet die Publikation des gepinnten Releases ab, und der Release-Bericht nennt Fälle ohne Ergebnis

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (derselbe Lauf, dasselbe Ergebnis — nicht abhängig von der Reihenfolge zweier Workflows),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (laut-Bruch statt Ausweichen),
[`MR-014`](../../../../harness/conventions.md#mr-014) (CI ruft nur `make`-Ziele), [`MR-091`](../../../../harness/conventions.md#mr-091) (Mutations-Probe über einen CI-Branch).
Auslöser: Auftrag des Auftraggebers nach Verdikt V-2 ([`docs/reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md`](../../../reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md)).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-20.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Workflow `mutate-branch` fährt `make release-warten` als eigenen Schritt, bevor der Grün-Vorlauf `make full-smoke` des Workers den Träger holt, und `docs/user/releasing.md` trägt die Pflichtzeile, dass der Release-Bericht Fälle ohne Ergebnis nennt — heute hat der Worker keinen Warte-Schritt, und sein Vorlauf fiel am Schnitt `v0.10.0` für 9 von 31 Fällen an einem 404 auf das unveröffentlichte Asset (Verdikt V-2).

**Ausgangslage (gemessen am Stand HEAD 343fc457, `grep -n 'release-warten' .github/workflows/mutate-branch.yml` findet nichts):** `make release-warten` steht im `ci`-Job `full-smoke`, nicht in `.github/workflows/mutate-branch.yml`; der Job `plan` schreibt die Ausgabe seines Schritts `lauf` per `>> "$GITHUB_OUTPUT"`. Das gepinnte Release `v0.10.0` (`TRAEGER_TAG` im `Makefile`) ist veröffentlicht und sein Asset abrufbar: der 404-Zustand des Anlasses liegt **vor** der Publikation und besteht am realen Pin nicht mehr. `release-warten.sh` urteilt nicht und endet bei bereits veröffentlichtem Release nach einem Versuch (Skriptkopf).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Die Zeitschranke selbst (`STALL_SECONDS`, 900 s) bleibt unverändert — der Befund *Fall 445 riss die Schranke im Worker* steht als Beobachtung im Register (`BEO-ALL/mutate-zeitschranke-trifft-den-full-smoke-fall-in-der-ci`, 1×) und wartet auf die 3×-Schwelle; hier wird nur ein Kommentar auf das gemessene Verhalten gebracht.
- Keine Änderung an `release-warten.sh` und seiner Grenze — die Möglichkeit ist so, wie sie steht, baubar (Verdikt V-2); ein anderes Maß wäre ein anderer Gegenstand.
- Keine Behebung der benannten Grenze *Tag-Push nach Ablauf der Grenze* — sie bleibt; ihr Träger ist die Prozedur in `docs/user/releasing.md`, und die Pflichtzeile ist deren Teil.
- Kein Nachholen der 9 Fälle von `v0.10.0` — der nächtliche `mutate`-Vollsweep holt sie nach; sie sind kein Gegenstand eines Plans.
- Keine Hard Rule, kein `MR` — die Regel bindet den Release-Schnitt, nicht jeden Lauf (Verdikt V-2 nach [`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) Festlegung 7).
- Kein Warten im lokalen `make mutate` — der Rennfall ist ein Push von `main` und Tag nebeneinander; ein lokaler Lauf hat keinen parallelen `release`-Workflow.

## 2. Definition of Done

- [ ] **L1 — Warte-Schritt im Worker-Vorlauf:** `.github/workflows/mutate-branch.yml` fährt `make release-warten` als **eigenen** Schritt (nicht innerhalb von `lauf`, dessen stdout nach `$GITHUB_OUTPUT` geht) vor dem Grün-Vorlauf. Den Ort — einmal im Job `plan` vor der Matrix oder je Shard — wählt der Slice nach Messung (Wartezeit bei veröffentlichtem Release, Shard-Startzeiten im `ci`-Log) und nennt Wahl und Messwert im Workflow-Kommentar; ein Warten je Shard bezahlt jeden Shard. Die Zusage nennt, was sie trägt: der Schritt urteilt nicht (Exit 0 auch nach der Grenze), das Urteil fällt weiter im Vorlauf.
- [ ] **L2 — Wächter und Zahn:** `test/mutate-auswahl.bats` oder ein eigener Fall hält, dass der Schritt `make release-warten` im Workflow vor dem Vorlauf und getrennt von `lauf` steht (Text-Wächter über der Workflow-Datei); `test/mutations/<nächste freie Nummer>-mutate-branch-worker-ohne-release-warten.sh` nimmt den Schritt weg und färbt ihn rot; `make mutate-greift` grün, `MUTATE_CASES=<Nr>` einmal rot gesehen. Die Zusage nennt die Grenze: der Text-Wächter hält die Verdrahtung, **nicht** die Wirkung gegen ein unveröffentlichtes Release; die Wirkung belegt ein einmaliger Branch-Lauf (`mutate/<kennung>-<sha8>`) mit `TRAEGER_WARTEN_GRENZE=0` im Log (`release-warten: GRENZE ERREICHT`), und nur dort. Weil `v0.10.0` veröffentlicht ist, läuft er nur über einen **abgeleiteten** Pin: ein Wegwerf-Branch, dessen `TRAEGER_TAG` einen nicht veröffentlichten Tag nennt — nicht der reale Pin im Zustand vor der Publikation. Er belegt, dass der Schritt im Worker läuft und meldet; dass der Worker ein später veröffentlichtes Release **abwartet**, belegt er nicht (Grenze 0). Ist er nicht herstellbar, steht die Lücke in §7 benannt.
- [ ] **L3 — Pflichtzeile in der Prozedur:** `docs/user/releasing.md` trägt im Schritt zur Meldung des vollzogenen Schnitts die Zeile, dass der Bericht die Mutations-Fälle **ohne Ergebnis** nennt (Zahl und Kommando, das sie liefert) und mit der benannten Lücke schließt oder die Probe nach der Publikation fährt; `harness/sensors/mutate.md` nennt den Warte-Schritt am Ort der Grenze. Ein Wächter existiert nicht für die Pflichtzeile: kein Sensor liest den Bericht gegen die Zeile; Träger ist der Release-Schnitt. Im selben Punkt: der Kommentar an `STALL_SECONDS` in `harness/tools/mutate.sh` (Satz „NICHT gedeckt: … Heute gibt es keinen") nennt das gemessene Verhalten — der CI-Lauf auf `mutate/…-7cc9f961` hatte einen Fall, der die 900-s-Schranke im Worker riss (Fall 445; Fall 444 brauchte 862 s); die Zusage nach `AGENTS.md` §3.6/§3.7 nennt Fälle und Messort im Indikativ, ohne Chronik, und ändert nicht den Wert. Ein Wächter existiert nicht: kein Sensor liest den Kommentar gegen die CI-Laufzeit.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.github/workflows/mutate-branch.yml` | update | eigener Schritt `make release-warten`, Ortswahl im Kommentar — L1 |
| `test/mutate-auswahl.bats` (oder eigener Fall) | update | Schritt steht vor dem Vorlauf und getrennt von `lauf` — L2 |
| `test/mutations/<nächste freie Nummer>-mutate-branch-worker-ohne-release-warten.sh` | neu | Schritt entfernt, Wächter wird rot — L2 |
| `harness/tools/mutate.sh` | update | Kommentar an `STALL_SECONDS` auf das gemessene Verhalten, Wert unverändert — L3 |
| `docs/user/releasing.md`, `harness/sensors/mutate.md` | update | Pflichtzeile im Bericht-Schritt, Warte-Schritt am Ort der Grenze — L3 |

## 4. Trigger

**Start** (`next` → `in-progress`): keine Abhängigkeit; Reihenfolge nach Auftraggeber: nach `slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten`.

**Rückführungen:**

- `in-progress` → `next`: der Warte-Schritt verlangt eine Änderung an `release-warten.sh` oder am Matrix-Aufbau von `mutate-auswahl.sh` (dritte Schicht oder mehr als drei Liefer-Punkte).
- `in-progress` → `open`: `actionlint` (`make ci-lint`) lehnt die Schrittfolge ab und die Ursache liegt in der Workflow-Form selbst, nicht im Schritt.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review- und Verifier-Report liegen vor, Closure-Notiz mit Lerneintrag in Form eines neuen Sensors (Text-Wächter samt Mutations-Fall) und der benannten Wirkungs-Lücke.

## 6. Risiken und offene Punkte

- Der Warte-Schritt je Shard bezahlt jeden Shard bis zur Grenze (900 s Default) — **Ausgang:** entfallen: Die Ortswahl nach Messung (L1) legt den Ort fest; je Shard gilt nur, wenn die Messung unterschiedliche Startzeiten der Shards zeigt, sonst einmal im Job `plan`.
- Die Ausgabe von `release-warten` landet in `$GITHUB_OUTPUT`, wenn der Aufruf im Schritt `lauf` steht — **Ausgang:** entfallen: L1 verlangt einen eigenen Schritt, L2 hält die Trennung.
- Tag-Push nach Ablauf der Grenze bleibt unbehoben — **Ausgang:** weiter offen → `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` im Register.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`, die einzige deklarierte Sub-Area der Beobachtungen); sie erfüllt die Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`ls -d docs/plan/planning/observations/BEO-ALL/*/`, gelesen am Stand HEAD 0f5d67c0). Treffer: `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` (5 Belege, `verkörpert`; die Grenze am Worker steht dort auf *geplant* mit dieser Kennung) und `BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last` (1 Beleg, `offen`, plus zwei Nachträge ohne Beleg, zuletzt Nacht-Lauf 2026-10-20 — betrifft denselben Worker-Vorlauf; zeigt die Messung in L1 eine zusätzliche Last durch den Schritt, wäre es der zweite Beleg). Kein Eintrag erreicht mit diesem Slice 3×.

alle berührten Sub-Areas GF


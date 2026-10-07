# Slice slice-anwender-targets-leben-in-repo-mk: Die eigenen Targets des Anwenders leben in `repo.mk`

**Welle:** ohne Welle.

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 1–5, [ADR-0007](../../adr/0007-bootstrap-phasen.md) (Klasse skip-if-present).

**Berührte Spec-Stellen:** —

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein gebootstrapptes Ziel hat mit `repo.mk` an seiner Wurzel einen Ort für eigene `make`-Targets, den der Re-Lauf nicht anfasst und den `make gates` über `GATE_CHECKS +=` erreicht; das Handbuch nennt ihn statt „keinen zugesicherten Ort".

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- `repo.mk` in `makefiles:` des emittierten `.d-check.yml` und Fitness-Zeile 3 der ADR — Folge-Slice `slice-targets-modul-im-emittierten-doc-gate` ([ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 5); das emittierte Doc-Gate fährt heute kein `targets`.
- Umzug bestehender Repo-Fragmente aus `harness/mk/` in bestehenden Zielen — Bestand bleibt bewusst stehen: der Glob nimmt sie weiter mit, ein Lauf löscht nie ([ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 4, akzeptiertes Negativ: kein Sensor meldet sie). <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
- Reklassifikation von `harness/mk/.gitattributes` — Bestand, [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 4 lässt sie stehen. <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
- Das `Makefile` dieses Repos — Ebene ist allein das Emittierte ([ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) §Schärft); der Dogfood führt seinen Aggregator von Hand.
- Eine `.gitattributes` an der Wurzel des Ziels für `repo.mk` — anderer Vorgang; die Wurzel bekommt keine (Register `emittierte-wurzel-dateien-ohne-zeilenenden-attribut`), `repo.mk` ist dort eine Adopter-Datei wie die übrigen.

## 2. Definition of Done

- [x] Der Aggregator trägt `-include repo.mk` direkt nach `include harness/mk/*.mk` und vor `record-gates: $(GATE_CHECKS)`; der Bootstrap legt `repo.mk` an freiem Pfad mit dem Kopfkommentar aus [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 2 an (Klasse skip-if-present in der Klassentabelle, keine Targets); `SelbstpruefungVorgabeOrt` und jeder Kopf, der den Ort nennt, zeigen auf `repo.mk`. Go-Tests halten Klasse, Zeilen-Reihenfolge und Ort; je Zusage eine rot gesehene Mutation ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [x] Eine `full-smoke`-Stufe im Ziel misst [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Fitness 1–2: eine vorab geschriebene `repo.mk` mit Target `eigen` ist nach dem Re-Lauf byte-gleich (`cmp`) und `make eigen` läuft; ein eigenes Gate über `GATE_CHECKS +=` läuft in `make gates`; ohne `repo.mk` legt der Lauf den Startinhalt an und `make gates` ist grün. Rot gesehen: Klasse konvergent bzw. `-include` → `include` mit gelöschter Datei; die Stufe steht in der E2E-Abdeckungs-Sicht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] `docs/user/benutzerhandbuch.md` nennt `repo.mk` als Ort für eigene Targets (Hinweise beim Aufsetzen, FAQ zum Re-Lauf, Klassentabelle „nur bei fehlender Datei", Zeilenenden-Absatz zur Wurzel) — Ist-Zustand, keine Chronik.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/makefile.go` | update | `-include repo.mk` zwischen Glob-Include und `record-gates` (Festlegung 3) |
| `internal/emit/enforce.go` (Klassentabelle) + `internal/emit/templates/enforce/repo.mk` | update / neu | Startinhalt, Klasse `SkipIfPresent` (Festlegung 2); die Tabelle ist die eine Stelle der Klasse |
| `internal/emit/selbstpruefung.go`, `templates/enforce/{selbstpruefung,e2e-abdeckung}.{mk,sh}` | update | Vorgabe-Ort `harness/mk/vorgaben.mk` → `repo.mk` (Festlegung 4); die Köpfe nennen ihn | <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
| `internal/emit/{makefile,enforce,selbstpruefung}_test.go` | update | `TestMakefile_HasOrderEdge`, `TestEnforce_EmitsAllMechanicFiles`, `TestEnforce_IdempotenzKlasseJePfad`, `TestSelbstpruefung_DerGenannteVorgabeOrtWirdVonKeinemLaufGeschrieben` — der letzte kehrt sich um: der Ort wird jetzt vom Lauf **an freiem Pfad** geschrieben; die Zusage heißt dann „nie überschrieben" |
| `internal/emit/baumaussage.go` und jede Liste emittierter Dateien | prüfen | hält eine Aussage die Zahl oder Liste der Dateien im Ziel, wandert sie mit |
| `test/mutations/` (neu; 450 prüfen) | neu / update | Fall je Zusage; 450 nennt `vorgaben.mk` im Kommentar |
| `harness/tools/full-smoke.sh` + `docs/user/e2e-abdeckung.md` | update | neue Stufe mit Stufen-Kopfzeile (Fitness 1–2), Sicht per `make e2e-abdeckung` neu erzeugt |
| `docs/user/benutzerhandbuch.md` | update | Hinweise beim Aufsetzen, FAQ Re-Lauf, Klassentabelle, Zeilenenden-Absatz Wurzel |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers (2026-10-07); [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) `Accepted` — erfüllt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Vorgabe-Ort-Umzug verlangt mehr als die Konstante und die drei Köpfe (etwa eine Migrationsmeldung für bestehende `vorgaben.mk`) — dann eigener Slice.
- `in-progress` → `open` (blockiert): `make` im Ziel verträgt `-include` nach dem Glob nicht wie in Festlegung 3 zugesagt (Vorgabe-Reihenfolge der `?=`-Variablen), oder ein emittierter Sensor (d-check `structure`/`links`) meldet `repo.mk` — dann zurück an den Architect.

## 5. Closure-Trigger

DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Ein bestehendes Ziel hat `harness/mk/vorgaben.mk`; nach dem Umzug nennen die Köpfe einen anderen Ort, die Datei wirkt weiter über den Glob — **Ausgang:** *entfallen* — die Reihenfolge ist fest (Glob vor `-include repo.mk`, gehalten von `TestMakefile_HasOrderEdge`), ein doppelt gesetzter Wert entscheidet deterministisch für `repo.mk` und kippt nicht ([Review](../../../reviews/2026-10-07-repo-mk-review.md) §Kommandos: `repo.mk` überschreibt das `?=` der Fragmente). <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->
- Ein Adopter löscht `repo.mk`; der nächste Lauf legt sie neu an (Festlegung 3), bis dahin fehlt sie `makefiles:` des Folge-Slice — **Ausgang:** *eingetreten* → Folge-Slice `slice-targets-modul-im-emittierten-doc-gate` (`repo.mk` steht heute in keinem emittierten `makefiles:`, [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 5).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** DoD 1–5 bestätigt ([Verifikation](../../../reviews/2026-10-07-repo-mk-verifikation.md));
  die Stufe `repo_mk_im_ziel` wurde dreifach an der realen Quelle rot gesehen, je mit der
  behaupteten Ursache (`include` statt `-include`, gestrichene Zeile, Klasse `Konvergent`).
  Closure-Trigger: `make full-smoke` auf `da914b2e` (Baum sauber) rc=0; `make gates` am Ende dieser Closure.
- **Was ging anders als geplant:** Die Klassen-Änderung von `repo.mk` machte drei benachbarte
  Aussagen über die Klassenmenge falsch („der eine Pfad", „der eine Eintrag", ein umbenannter
  Testkommentar); [Review](../../../reviews/2026-10-07-repo-mk-review.md) L1–L4, behoben in `7c9f27fb`.
- **Steering-Loop-Eintrag:** *Geschärfte Regel*: Wer die Klasse eines emittierten Pfads ändert,
  misst vor dem Commit jede Aussage über die Menge dieser Klasse, nicht nur die Zeile des Pfads.
  Gezählt, nicht verkörpert; Auslöser `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`.
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-anwender-targets-leben-in-repo-mk.md`
  in [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  ergänzt (Review-Klasse L1–L3); Stand bleibt `geplant` (`slice-153`). L4 ist ein Einzelbefund
  ohne wiederkehrende Klasse und nicht registriert. `emittierter-stand-laeuft-dem-dogfood-voraus`
  zählt nicht: `repo.mk` ist ein Ort, keine im Ziel schärfer gefasste Regel.
- **Folge-Slices:** keiner neu; `slice-targets-modul-im-emittierten-doc-gate` (`open/`) trägt
  Festlegung 5 und Risiko 2.
- **Trigger-Audit:** Carveouts, Bootstrap-aware Gates, Hard Rules: keine berührt.
  [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) `Accepted`, kein Trigger fällig.
- **Risiken aus §6:** jede Zeile trägt ihren Ausgang.
- **Archivierung:** keine bei dieser Closure — das Repo fährt Wellen, die nächste Welle-Closure
  sammelt den Slice ein ([`MR-078`](../../../../harness/conventions.md#mr-078)).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-07, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`: `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` → 6 (verkörpert; die Handbuch-Zeile nennt nur, was die Stufe misst), `emittierter-stand-laeuft-dem-dogfood-voraus` → 2 (der Slice ist nur emittiert, [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) §Schärft; ein drittes Auftreten wäre Beleg, kein Folge-Slice-Zwang dieses Plans), `zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung` → 1 (Handbuch-Stellen über Anker/Abschnitt nennen, nicht über Zeilen), `emittierte-wurzel-dateien-ohne-zeilenenden-attribut` → 1 (`repo.mk` liegt an der Wurzel ohne `.gitattributes`; §1 grenzt aus).

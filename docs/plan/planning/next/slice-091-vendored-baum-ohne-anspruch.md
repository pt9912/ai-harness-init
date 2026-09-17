# Slice slice-091: Der mitgelieferte Baum stellt keine `make`-Ansprüche an das Ziel, und eine lebende Zeile sagt es

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-11](../welle-11-traeger-aussage.md) — er setzt den Wert für die Regelblöcke, die
im Ziel einen `make`-Anspruch **ohne Gegenstand** tragen; ohne ihn bliebe das Closure-Kriterium für
fünf Regelwerk-Dateien unbelegt.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (*„Jeder
emittierte Gate-Target läuft auf frischem Checkout"* — dieselbe Klasse eine Ebene weiter: hier
behauptet nicht der Tisch ein Ziel, sondern ein mitgeliefertes Dokument, aus dem der Adopter
kopiert),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk geht
vollständig ins Ziel — mit seinen Beispiel-Kommandos),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
zweiklassige Ablage: die wiederkehrenden Vorlagen bleiben im vendored Baum und werden je Artefakt
kopiert — genau der Weg, auf dem der Anspruch weiterwandert),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(referenziert statt kopiert — die Adaption, die diesen Weg zur Regel macht),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der Baum ist byte-verifiziert; er ist kein Reparatur-Ort),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(hier als Gegenkraft: *laut falsch* hilft nur, wenn der Adopter am Befund ablesen kann, dass er
einer ist).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Eine lebende Zeile des gebootstrappten Repos sagt, dass der mitgelieferte Baum Kurs-Inhalt ist
und seine `make`-Namen Beispiele sind, keine Ziele dieses Repos — als Eigenschaft, nicht als
Namensliste.**

**Der Befund, an einem Sonden-Repo gemessen.** Der mitgelieferte Baum nennt `make`-Ziele, die in
**keiner** Bootstrap-Variante existieren. Gefahren am 2026-08-22 über zwei Sonden-Repos
(sprachlos und `--lang go`), Anspruchs-Menge gegen Regel-Menge:

```
# Anspruchs-Menge (im Sonden-Repo) — OHNE die drei Vorlagen, aus denen die lebenden
# Doku-Tische entstehen: die gehoeren slice-087, nicht diesem Slice.
grep -rhoE 'make [a-z][a-z0-9-]+' .harness/baseline/v5.18.0/ \
  --exclude=AGENTS.template.md --exclude=README.template.md \
  --exclude=closure-note-reviewer.template.md | sed 's/^make //' | sort -u
# Regel-Menge derselben Variante
grep -hoE '^[a-zA-Z][a-zA-Z0-9_.-]*:' Makefile harness/mk/*.mk d-check.mk | tr -d ':' | sort -u
# Differenz beider Dateien: comm -23
```

Übrig bleiben `arch-check`, `coverage-gate-critical`, `fullbuild`, `test-determinism`, `verify` —
**fünf** benannte Ziele (dazu das Muster-Fragment `verify-`), nachgemessen gegen `v5.18.0`
([slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)): dieselben sechs Einträge, unverändert.
Ihre Fundorte:

| Fundort im mitgelieferten Baum | Anspruch | warum er im Ziel nichts trifft |
|---|---|---|
| `regelwerk/modul-13-quality-gates.md` | `fullbuild`, `arch-check` | das emittierte Arch-Gate heißt `a-check`; `fullbuild` existiert in keiner Variante |
| `regelwerk/modul-07-carveouts.md` | `coverage-gate-critical` | Beispiel eines Carveout-Gegenstands, kein Ziel dieses Repos |
| `regelwerk/modul-11-verification.md` | `verify`, `verify-` | das Ziel führt keinen `verify:`-Block — die Lücke, die [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 5(c) benennt |
| `regelwerk/modul-15-observability.md` | `fullbuild` | dasselbe |
| `regelwerk/grundlagen-konventionen.md` | `verify`, `test-determinism` | dasselbe |
| `templates/docs/plan/planning/welle.template.md` | `fullbuild` | **wandert weiter**: die Vorlage wird nach [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) je Welle in ein **lebendes** Plan-Dokument kopiert |
| `templates/docs/plan/adr/NNNN-titel.template.md` | `arch-check` | dasselbe, je ADR |

Kommando für die Zeilen 1–5: `grep -rlE 'make (arch-check|coverage-gate|coverage-gate-critical|fullbuild|test-determinism|verify)\b' .harness/baseline/v5.18.0/regelwerk/ | wc -l` → **5** (nachgemessen gegen `v5.18.0`, unverändert; einer der fünf Fundorte trägt einen anderen Namen als die Tabelle — `grundlagen-konventionen.md` existiert im gepinnten Baum nicht, `grundlagen-referenz-richtung.md` trägt dort `verify`/`test-determinism` — die Fundort-Tabelle oben zählt Dateien nach altem Namen und ist damit eine eigene, engere Frage als diese Zahl).

**Warum das ein Problem ist und nicht bloß Kosmetik.** Die letzten zwei Zeilen sind der teure Fall:
`cp` aus dem vendored Baum ist die **vorgeschriebene** Art, ein Plan-Artefakt anzulegen. Wer sie
befolgt, trägt `make fullbuild` in sein Welle-Closure-Kriterium und `make arch-check` in seine ADR
— einen Anspruch auf ein Ziel, das sein Repo nicht hat. Das ist dieselbe
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse
eine Ebene weiter, und [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(e)
benennt sie ausdrücklich als offen: *„ohne einen Griff, der sie schlösse, solange der Baum
unverändert mitgeht."*

**Warum der Griff Text ist und keine Korrektur im Baum.** Der Baum ist auf beiden Ebenen
byte-verifiziert (`make baseline-verify` gegen `SHA256SUMS`, hier wie im Ziel, wo das emittierte
Fragment das Rezept an `GATE_CHECKS` hängt). Wer den Anspruch dort heilte, färbte den Gate rot. Der
Griff liegt daneben: **eine Zeile im Ziel, die den Baum als das ausweist, was er ist** — derivativer
Kurs-Inhalt, im Ziel nicht repo-autoritativ, aus demselben Grund von beiden Doku-Gates per
`scan.ignore` ausgenommen.

**Die Zeile nennt eine Eigenschaft, keine Aufzählung.** Eine Liste der fünf Namen wäre beim nächsten
Baseline-Sprung falsch, ohne dass am Gegenstand etwas bricht — genau die Form von Erwartungswert,
die [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 ausschließt. Die Aussage lautet daher: *die `make`-Namen dieses Baums sind Kurs-Beispiele;
maßgeblich ist `make help` dieses Repos.* Sie überlebt den Tausch.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt — bei (2) steht dabei, dass
keines existiert (Modul 5 §Ziel-Form: ≤ 3; [`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Das frisch gebootstrappte Ziel weist den mitgelieferten Baum als Kurs-Inhalt aus** und
      sagt, dass dessen `make`-Namen keine Ziele dieses Repos sind — mit dem Zeiger auf die
      maßgebliche Quelle (`make help`), in beiden Bootstrap-Varianten.
      **Rot:** `make full-smoke` — Marker-Prüfung gegen `tmprepo` **und** `tmprepo_doc`
      ([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)); einmal rot
      gesehen durch emit-seitige Rücknahme der Zeile.
- [ ] **(2) Die Aussage ist eine Eigenschaft, keine Namensliste** — sie überlebt einen
      Baseline-Sprung ohne Nachzug.
      **Kein Kommando färbt das rot,** und das gehört dazu: es ist ein Urteil beim Schreiben, kein
      Muster ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2 zieht dieselbe Grenze). Der nächste Baseline-Sprung ist die Probe: bleibt die Zeile
      unangetastet richtig, hat sie getragen. Prüfbar bleibt die **Gegenrichtung** — dass die Zeile
      keinen `make`-Namen nennt, den das Ziel nicht hat: `grep -oE 'make [a-z-]+'` über die
      geänderte Vorlage gegen die Regel-Menge des Sonden-Repos.
- [ ] **(3) Der emittierte Datei-Satz wächst nicht, und der vendored Baum bleibt unberührt.**
      **Rot:** `make gates` — `baseline-verify` prüft den Baum gegen `SHA256SUMS` und fällt bei
      jeder Änderung; und `make test` über die Ziel-Pfad-Liste in
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go)
      (`TestTemplates_Layout`), die ein zusätzlicher Pfad rot färbt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit`](../../../../internal/emit) — der Schritt, der die Zeile in ein bereits emittiertes Dokument trägt | update | Präzedenz: `NeutralizeRoadmap` in [`internal/emit/templates.go`](../../../../internal/emit/templates.go) bearbeitet eine vendored Vorlage emit-seitig nach. Die Zeile gehört dorthin, wo der Adopter den Baum zum ersten Mal liest — das ist die Baseline-Aussage seiner `harness/conventions.md` bzw. §1 seiner `AGENTS.md`; welche von beiden, entscheidet der Implementer am Bestand |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | Marker-Prüfung über beide Varianten (DoD 1) |
| `test/mutations/` — ein Fall für den neuen Marker <!-- d-check:ignore (geplante Datei) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6 |
| `.harness/baseline/` | **unberührt** | byte-verifiziert; eine Korrektur dort färbt `baseline-verify` rot (DoD 3) |

## 4. Trigger

**`open` → `next`:** [welle-11](../welle-11-traeger-aussage.md) ist eingetreten, also liegt
[welle-10](../done/welle-10-re-baseline.md) in `done/` — und damit auch slice-087, der dieselbe
Fehlerklasse in den **lebenden** Doku-Tischen räumt. **`next` → `in-progress`:** WIP-Limit frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn die Messung nach dem Baum-Tausch
mehr als eine Aussage verlangt (etwa weil die neue Fassung Ansprüche in einer zweiten Form trägt) —
dann ist der Schnitt zu grob. `in-progress` → `open`, wenn sich zeigt, dass die Zeile nur in einem
Dokument Platz hat, das der Adopter selbst besitzt und das emit-seitig *skip-if-present* ist: dann
erreicht sie bestehende Repos nicht, und die Reichweite ist eine Architektur-Frage.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün,
Closure-Notiz in §7 mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Der Baum wird getauscht, die Anspruchs-Menge wandert mit.** Deshalb ist die Zeile eine
  Eigenschaft (DoD 2) und deshalb liegt der Slice hinter
  [welle-10](../done/welle-10-re-baseline.md). Die **Zahl fünf** in §1 ist ein Ist-Stand vom
  2026-08-22, **kein Erwartungswert** — sie bewegt sich mit dem Baum, ohne dass am Gegenstand
  etwas bricht.
  — **Ausgang: eingetreten** → `slice-das-ziel-sagt-was-sein-vendored-baum-ist`. Der Nehmer nimmt
  den Punkt als **Eigenschaft** an: Sein Liefer-Punkt (2) verlangt ausdrücklich eine Zeile, die
  den Baum als Kurs-Inhalt ausweist, *„als Eigenschaft, nicht als Namensliste"*. Die Ist-Zahl aus
  §1 wandert damit weiter, ohne dass am Gegenstand etwas bricht.
- **Die Zeile deckt den Fall nicht, in dem der Adopter die Vorlage schon kopiert hat.** Sie
  erreicht ihn beim Lesen, nicht rückwirkend in seinen Plan-Dateien. Ein Sensor, der das fände,
  wäre der `targets`-Träger über dem Plan-Verzeichnis des Ziels — er hängt an
  [welle-09](../welle-09-modul-15-konformitaet.md) und ist hier ausdrücklich nicht Gegenstand.
  — **Ausgang: eingetreten** → derselbe Nehmer. Er zieht dieselbe Grenze und schreibt sie in §1
  als Ausschluss aus: *Die Aktivierung von `doc-targets` im Ziel* gehört welle-09, hier steht für
  diesen Regelblock nur der Wert *liegt bei, nicht verdrahtet*. Der Fall des Adopters, der die
  Vorlage schon kopiert hat, bleibt damit adressiert und unbewacht — benannt, nicht geschlossen.
- **Abgrenzung, die beim Ändern zählt:** dieser Slice fasst **nur** den vendored Baum an. Die
  Ansprüche der lebenden emittierten Doku-Tische (`AGENTS.md`, `harness/README.md`,
  `.harness/skills/closure-note-reviewer.md`) gehören slice-087. Wer beide Mengen in einem Lauf
  bearbeitet, macht den Befund unentscheidbar — das ist der Grund für den `--exclude` im Sweep
  oben.
  — **Ausgang: entfallen.** Der Ausschluss hing daran, dass **dieser** Slice in den vendored Baum
  eingreift; der Nehmer tut das nicht — seine Zusage ist eine **lebende** Zeile (Liefer-Punkt 2),
  und `make baseline-verify` hielte den Baum ohnehin gegen `SHA256SUMS`. Die Verwechslungsgefahr
  mit den lebenden Doku-Tischen, gegen die der Ausschluss stand, hat damit keinen Gegenstand mehr.

## 7. Closure-Notiz (nach `done/`)

**Gegenstand:** übernommen von `slice-das-ziel-sagt-was-sein-vendored-baum-ist`.

**Stillgelegt ohne Lieferung** — Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice,
dessen Gegenstand ein anderer übernimmt. Die drei Liefer-Punkte in §2 bleiben **leer**: Dieser
Slice hat nichts geliefert, und ein Haken behauptete es. `Verantwortlich:` bleibt stehen.

**Die Adresse nimmt an.** Der Nehmer liegt in `open/`, ist nicht geschlossen und nennt in §1
unter `Übernimmt:` diese Kennung. Er führt den Gegenstand als Liefer-Punkt (2): *Eine lebende
Zeile weist den mitgelieferten Baum als Kurs-Inhalt aus, dessen `make`-Namen keine Ziele dieses
Repos sind* — als Eigenschaft, nicht als Namensliste.

**Die Wellen-Zugehörigkeit ist bereits gewandert.** Der Kopf nennt
[welle-11](../welle-11-traeger-aussage.md); sie ist aufgelöst, der Nehmer steht ohne Welle, und
die Umplanung trägt das Drift-Log der Roadmap (Eintrag vom 2026-09-17, er nennt diese drei Geber
und den Nehmer). Diese Closure fasst weder die Welle-Datei noch das Drift-Log an.

**Was hat funktioniert:** Der Slice hatte seine Zusage schon als **Eigenschaft** formuliert (§2
Punkt 2, *„keine Namensliste"*), und genau diese Formulierung ist im Nehmer wörtlich
wiederzufinden. Der Gegenstand hat den Schnitt überlebt, weil er nicht an einer Aufzählung hing.

**Was ging anders als geplant:** Geprüft hat den Schnitt keine Implementation, sondern erst die
Gruppierung — das Muster *tote Slices* aus `modul-05-planning-harness.md` §Regeln gegen typische
Fehlannahmen. Der Plan stand von seinem Schnitt am 2026-08-22 an unbeansprucht in `next/`.

**Steering-Loop-Eintrag:** **gezählt, nicht verkörpert** — kein Zielort, darum **kein**
`liegt in`-Feld (`grundlagen-traceability.md` §Herkunfts-Anker). Die Form der Stilllegung steht
seit `v6.9.0` in der adoptierten Baseline; eine zweite Fassung daneben driftete.

**Beobachtungs-Register** (`../observations/`): zitiert, nicht neu formuliert —
[`BEO-ALL/geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md).
**Keine zweite Beleg-Datei:** Dieser Geber steht dort unter *Benannt, nicht gezählt*; er ist ein
Fund **derselben** Gelegenheit wie `slice-090-freshness-audit-im-ziel`, und der Zähler misst
Wiederholung über Vorgänge hinweg, nicht die Zahl der Funde (`modul-06-roadmap.md` §Das
Beobachtungs-Register). Der Stand bleibt `offen`, unter der Schwelle.

**Lese-Schritt** (Repo ohne Wellen-Betrieb, `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht): Kein Eintrag erreicht mit dieser Closure 3×, und kein Eintrag über der Schwelle steht
ohne Ausgang — dasselbe Kommando wie in
[`slice-090`](slice-090-freshness-audit-im-ziel.md) §7, Ausgabe leer.

**Die drei Paarungen.** (a) Anker-Paarung: kein Eintrag trägt `liegt in`, sie hat keinen
Gegenstand. (b) Folge-Slice-Paarung: kein Folge-Slice genannt. (c) Register-Paarung: die zitierte
Beobachtung existiert als Verzeichnis und trägt einen Beleg.

**Was diese Closure nicht trägt:** Review und Verifikation am Gegenstand — es gibt keinen Diff,
den sie prüfen könnten. Geprüft ist die **Form** der Stilllegung durch `make docs-check` (Modul
`structure`, `open-tasks-require-marker`) und der Gesamtstand durch `make gates`.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

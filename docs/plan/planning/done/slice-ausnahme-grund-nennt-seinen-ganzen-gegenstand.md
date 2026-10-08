# Slice slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand: Die Begründung neben einem Ausnahme-Eintrag nennt den ganzen Gegenstand, den ihr Schlüssel stumm schaltet

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** `welle-emittiertes-doc-gate`.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Ausnahme-Eintrag nimmt eine Fläche aus der Prüfung; wer seine Begründung als vollständig liest,
hält einen Ausschnitt für den Bestand),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — die emittierte Hälfte dieses Slice liegt in ihrem
Geltungsbereich),
[`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
(der `scan.ignore`-Zensus dieses Repos und sein dritter Grund — der Bestand, gegen den die Regel
sich messen lassen muss).

**Berührte Spec-Stellen:** — Der Slice ändert keine Spec-Stelle; er betrifft zwei
Gate-Konfigurationen und den Ort der Regel darüber.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die Begründung, die neben einem Ausnahme-Eintrag einer Gate-Konfiguration steht, nennt
den **ganzen** Gegenstand, den ihr Schlüssel stumm schaltet — in der Konfiguration dieses Repos und
in der, die das Werkzeug in ein Zielrepo schreibt —, und die Regel darüber hat einen Ort, an dem
der nächste Lauf sie liest.

**Der Auslöser, gemessen:** Der Eintrag
[`config-kommentar-nennt-anderen-bereich-als-der-eintrag`](../observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/observation.md)
des Beobachtungs-Registers hat die Schwelle erreicht; den Stand liefert
`ls docs/plan/planning/observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/evidence/ | wc -l`,
den Ausgang seine `state.md`. Die drei Belege treffen beide Ebenen: zweimal die Konfiguration
dieses Repos, einmal die emittierte.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Nicht die Frage, was eine deklarierte Ausnahmeliste jenseits von Existenz und Form schuldet.**
  Sie hängt an [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 3, die auf `Proposed` steht und keinen Träger hat; ihr Ausgang ist der Gegenstand von
  `slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung` — ein **Folge-Slice mit Kennung**, der
  ihn in §1 auch führt. Dieser Slice setzt keine Berechtigungs-Prüfung voraus: er fragt nicht, ob
  ein Eintrag sein darf, sondern ob sein Grund seinen Gegenstand nennt.
- **Keine neue Ausnahme, keine entfernte, keine gelockerte Schwelle.** Jede Änderung an der Menge
  der Einträge wäre eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und damit ein
  **anderer Vorgang** mit eigener ADR.
- **Kein Zensus-Ausbau.** Was [`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  über den dritten Grund des `scan.ignore`-Zensus setzt, bleibt als **Bestand bewusst stehen**; der
  Slice ändert die Zählung nicht, nur den Text neben dem Eintrag.
- **Den Norm-Text schreibt der Architect.** Ein Eintrag des Adaptions-Blocks oder eine Hard Rule
  entsteht im Architect-Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice liefert das
  **Übergabe-Artefakt** und den Sensor — **Schicht-Abgrenzung** zwischen Entscheidung und
  Durchsetzung.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte**, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Jeder Ausnahme-Eintrag der erfassten Schlüssel** (`scan.ignore`, `*.exempt-paths`,
      `codepaths.ignore-refs`, `ignore-refs.in`) in beiden Gate-Konfigurationen — `.d-check.yml`
      dieses Repos und die Vorlage, die das Werkzeug ins Ziel schreibt — trägt eine Begründung, die
      jeden Baum nennt, den sein Schlüssel trifft; gemessen je Eintrag gegen den Ist-Bestand. Nicht
      erfasste Schlüssel und Mess-Grenzen stehen im Kopf von `internal/ausnahmegrund/ausnahmegrund.go`.
      **Rot:** `make mutate` über die Fälle `579`, `580`, `581` in `test/mutations/` → `3 ok, 0 Befund(e)`
      (Verifikation); für die
      Anführungszeichen- und `scan.ignore`-Block-Form besteht kein Fall (§7).
- [x] **(2) Ein Wächter hält die Zusage**, und seine Grenze steht neben ihm: er prüft, ob die
      Begründung die Bäume nennt, die der Schlüssel trifft — nicht, ob sie *stimmt*.
      **Rot:** `make test` über den Fällen aus (1); die gelesene Meldung nennt den Eintrag und den
      fehlenden Gegenstand.
- [x] **(3) Die Regel hat einen Ort:** [`AGENTS.md`](../../../../AGENTS.md) §3.5, Architect-Commit
      `03f14601`, Anker `seit slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand`, *permanent*; der
      Register-Eintrag trägt den Ausgang *verkörpert*. **Kein Sensor färbt die Anker-Paarung rot**
      (die `.d-check.yml` führt kein Modul dafür); geprüft per Hand in der Closure (§7).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: entfällt — die emittierte Konfiguration ändert nur Kommentarzeilen, ihre Form
      bleibt (`git diff 748c0180 33ba1221 -- internal/emit/templates/d-check.yml`).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` (Begründungen der Ausnahme-Einträge) | update | die Hälfte dieses Repos; zwei der drei Belege liegen hier |
| [`internal/emit/templates/`](../../../../internal/emit/templates) (Gate-Vorlage des Ziels) | update | die emittierte Hälfte; der dritte Beleg liegt hier |
| [`internal/ausnahmegrund/`](../../../../internal/ausnahmegrund) (neu) | neu | die Regel des Wächters aus DoD 2 als ein Paket für beide Ebenen: Ausnahme-Einträge lesen, Gegenstand messen (Glob-Treffer bzw. Inline-Code-Zitate im Prüfbereich), Nennung der Bäume prüfen; dazu der Fall über der `.d-check.yml` dieses Repos |
| [`cmd/ai-harness-init/`](../../../../cmd/ai-harness-init) (Test) | neu | der Fall über der emittierten Konfiguration: er fährt den realen Bootstrap (netzlos, drei Lauf-Varianten) und misst das Ziel — die Orte unter `.harness/` legt nur `run()` an, ein Test in `internal/emit/` sähe sie nicht |
| [`test/mutations/`](../../../../test/mutations) | neu | je Ebene ein Fall aus DoD 1, `# verify: test-go`; dazu der Fall `581` (der Parser übergeht eine unbekannte Form in einer Block-Liste still → `TestEintraege_UnbekannteFormFailClosed` rot) |
| [`.dockerignore`](../../../../.dockerignore) | update | der Fall über der `.d-check.yml` dieses Repos misst im Go-Test-Build Glob-Treffer und Zitate im Prüfbereich; der Build-Kontext trägt dafür den Markdown-Baum und `.harness/skills/`, von `.harness/` bleiben nur die vendored Baseline und der Lauf-Zustand außen |
| `internal/emit/templates.go`, `internal/emit/templates_test.go`, `internal/archive/stub_test.go` (Kommentare) | update | drei Kommentare sagten, `.harness/` liege ganz außerhalb des Build-Kontexts; sie nennen jetzt `.harness/baseline/` und die Ausnahme `.harness/skills/` nach `.dockerignore` |

**Fortgeschrieben im Implementierungs-Lauf:** Der Wächter sitzt nicht in `internal/emit/`, sondern
im neuen Paket und in `cmd/ai-harness-init/` (Begründung in der Tabelle). Gemessen vor den
Begründungen: in der emittierten Konfiguration nennt `scan.ignore` weder `.harness/baseline/` noch
`.harness/skills/`; in der dieses Repos tragen die sieben Einträge unter `codepaths.ignore-refs`
keine eigene Begründung, und die gemeinsame nannte für den siebten Klassen, die er heute nicht
mehr trifft, und `**/*.template.md`/`.tmp/**` unter `scan.ignore` hatten keinen Satz. Alle übrigen
Ausnahme-Einträge nennen ihren Gegenstand bereits — die meisten über ihren eigenen Wert.

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Der Reihenfolge nach: erst die Menge der Einträge und ihrer Bäume messen, dann den Wächter, dann
  die Begründungen ziehen. Umgekehrt misst der Wächter die Texte, die derselbe Lauf geschrieben hat.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei. Der Slice hängt an
keinem anderen: Die Berechtigungs-Frage aus §1 ist ausgeschlossen, nicht vorausgesetzt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die zwei Ebenen — eigene und emittierte
  Konfiguration — verlangen getrennte Wächter, und der zweite ist nicht in derselben Sitzung
  prüfbar. Dann behält dieser Slice die emittierte Hälfte, aus der er entstand.
- `in-progress` → `open` (blockiert — Carveout?): Der Gegenstand eines Schlüssels ist selbst
  strittig (ein Glob trifft mehr, als irgendeine Quelle nennt) — dann fehlt eine Entscheidung, und
  die gehört vor die Arbeit.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und jeder Ausnahme-Eintrag beider Konfigurationen ist im Umsetzungs-Commit
   mit seinem Gegenstand und seiner Begründung aufgeführt.
2. Der Rot-Beleg aus DoD 2 steht mit gelesener Ausgabe im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Wächter misst die Form der Begründung statt ihres Gegenstands** — er zählt Wörter oder
   Muster und gibt damit ein Muster als Kriterium aus ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
   — **Ausgang:** **entfallen** — der Wächter leitet die Bäume aus dem Schlüssel ab (Glob-Treffer
   bzw. Inline-Code-Zitate im Prüfbereich) und hält sie gegen den Text; die Zusage ist auf das
   Nennen eingeschränkt, nicht auf das Stimmen (Grenze im Paketkopf).
2. **DoD 3 hängt an einer fremden Rolle.** — **Ausgang:** **entfallen** — der Architect hat die
   Regel in [`AGENTS.md`](../../../../AGENTS.md) §3.5 gesetzt (`03f14601`).
3. **Ein Glob trifft mehr, als seine Begründung je nennen kann** (`**`-Muster über einem wachsenden
   Baum). — **Ausgang:** **entfallen** — gemessen werden die getroffenen Bäume, nicht Einzelpfade;
   die Rückführung nach §4 wurde nicht gezogen. Was der Repo-Fall nicht sieht (Treffer unter
   `.harness/baseline/`, emittiert nur die Baseline-Fixture), steht als Grenze am Sensor.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang:
Review- und Verifikations-Report vom 2026-10-08, Architect-Commit `03f14601`.

- **Was hat funktioniert:** Erst die Menge gemessen, dann der Wächter, dann die Texte (§3) — die
  Begründungen wurden gegen einen Sensor geschrieben, der sie nicht selbst erzeugt hat. Der
  emittierte Fall fährt den realen Bootstrap statt einer nachgebauten Konfiguration.
- **Was ging anders als geplant:** Review F-1 (HIGH): der Paketkopf nannte Formen als gelesen, die
  still nichts maßen (Block-Item in `'…'`, `scan.ignore` als Block-Liste); behoben in `e7cebd16`
  samt fail-closed für unbekannte Formen (Fall `581`). F-2/F-3 (MEDIUM): Positiv-Beleg über der
  gemessenen Menge und Build-Kontext (`.dockerignore`), behoben in `e7cebd16`/`33ba1221`, die
  Kommentare nachgezogen in `72a06601`. DoD 1 ist auf die erfassten Schlüssel eingeschränkt.
- **Offen, benannt:** Für die Anführungszeichen- und die `scan.ignore`-Block-Hälfte von F-1 besteht
  kein Fall in `test/mutations/`; ihre Haltbarkeit trägt allein `TestEintraege_Schreibformen` und
  der Repo-Fall. Kein neuer Slice — gezählt im Register (unten). Die Anker-Paarung aus DoD 3 hat
  keinen Sensor; per Hand geprüft (unten).
- **Steering-Loop-Eintrag:** Regel geschärft: die Begründung neben einem Ausnahme-Eintrag nennt
  jeden Baum, den ihr Schlüssel stumm schaltet; Wächter `internal/ausnahmegrund/` und
  `cmd/ai-harness-init/ausnahmegrund_test.go` in `make test` — liegt in `AGENTS.md §3.5`.
  Auslöser: `BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag` (slice-177,
  slice-197, slice-das-ziel-sagt-was-sein-vendored-baum-ist — 3×).
- **Beobachtungs-Register (`../observations/`):**
  [`config-kommentar-nennt-anderen-bereich-als-der-eintrag`](../observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/observation.md)
  → Stand *verkörpert* (Zielort `AGENTS.md` §3.5), kein neuer Beleg — dieser Slice ist sein
  Ausgang, kein weiteres Auftreten.
  `evidence/slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand.md` in
  [`zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/observation.md)
  ergänzt (Stand bleibt *verkörpert*). Den Zähler liefert
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`; kein Erwartungswert.
- **Folge-Slices:** keine.
- **Risiken aus §6:** alle drei *entfallen* (§6).

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `.d-check.yml` und `internal/emit/` samt
seinen Vorlagen — beide liegen in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind
nicht berührt. Die Sub-Area erfüllt das Inklusionskriterium; ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`config-kommentar-nennt-anderen-bereich-als-der-eintrag`](../observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/observation.md) | 3 | geplant | der Auslöser — dieser Slice ist sein Ausgang |
| [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md) | 4 | geplant | benachbart, ausgeschlossen in §1 — dort ist `slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung` die Adresse |
| [`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md) | 2 | offen | DoD 2 — die Grenze des Wächters steht neben ihm, statt in Prosa weiter zu reichen |
| [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) | 1 | offen | die emittierte Hälfte aus §1 liegt in seiner Richtung |

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

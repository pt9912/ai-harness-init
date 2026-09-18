# Slice slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand: Die Begründung neben einem Ausnahme-Eintrag nennt den ganzen Gegenstand, den ihr Schlüssel stumm schaltet

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Closure-Trigger unten beobachtet nichts, was die DoD nicht belegt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

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

- [ ] **(1) Jeder Ausnahme-Eintrag der beiden Gate-Konfigurationen** — `.d-check.yml` dieses Repos
      und die Vorlage, die das Werkzeug ins Ziel schreibt — trägt eine Begründung, die jeden Baum
      nennt, den sein Schlüssel trifft. Gemessen je Eintrag gegen den Ist-Bestand, nicht gegen eine
      notierte Liste. **Rot:** ein Fall in `test/mutations/`, der einen Gegenstand aus einer
      Begründung streicht, färbt den Wächter aus (2) rot.
- [ ] **(2) Ein Wächter hält die Zusage**, und seine Grenze steht neben ihm: er prüft, ob die
      Begründung die Bäume nennt, die der Schlüssel trifft — nicht, ob sie *stimmt*.
      **Rot:** `make test` über dem Fall aus (1); die gelesene Meldung nennt den Eintrag und den
      fehlenden Gegenstand.
- [ ] **(3) Die Regel hat einen Ort.** Entweder liegt sie als Architect-Artefakt vor (ein Eintrag
      des Adaptions-Blocks oder eine Hard Rule) oder die Ablehnung steht mit Grund in §7; der
      Register-Eintrag trägt danach den Ausgang *verkörpert* mit Zielort und Herkunfts-Anker
      `seit slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand`. **Rot:** `make docs-check` —
      die Anker-Paarung fällt, wenn der genannte Zielort den Anker nicht trägt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: berührt ist die Begründung neben den Gate-Einträgen; ein öffentlicher Vertrag
      ist nur berührt, wenn die emittierte Konfiguration ihre Form ändert.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
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
| [`internal/emit/`](../../../../internal/emit) (Wächter über der Vorlage) | update | der Wächter aus DoD 2, hermetisch neben der Vorlage |
| [`test/mutations/`](../../../../test/mutations) | neu | der Fall aus DoD 1, `# verify: test-go` |

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
   *Absehbar:* entfallen, wenn der Wächter die Bäume aus dem Schlüssel ableitet und gegen den Text
   hält; sonst eingetreten, und die Zusage wird auf das eingeschränkt, was er hält.
2. **DoD 3 hängt an einer fremden Rolle.** Der Norm-Ort ist Architect-Arbeit; bleibt die
   Entscheidung aus, steht der Register-Ausgang weiter auf *geplant*. *Absehbar:* entfallen, wenn
   das Übergabe-Artefakt beantwortet ist; sonst weiter offen im Register.
3. **Ein Glob trifft mehr, als seine Begründung je nennen kann** (`**`-Muster über einem wachsenden
   Baum). *Absehbar:* entfallen, wenn die Begründung die *Klassen* statt der Pfade nennt; sonst
   Rückführung nach §4.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

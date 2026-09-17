# Slice slice-das-ziel-sagt-was-sein-vendored-baum-ist: Das gebootstrappte Repo sagt, was sein mitgelieferter Baum ist, was er nicht verspricht und welche seiner Regeln dort einen Träger haben

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Die Wellen-Zugehörigkeit wandert zwar mit dem Gegenstand (Baseline-Regelwerk
`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt) — nur bündelte
[welle-11](../welle-11-traeger-aussage.md) danach **einen** Slice, und der Test aus
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht fällt negativ aus: Ihr Closure-Trigger
beobachtet nichts, was die DoD unten nicht belegt — `make gates`, `make full-smoke` und die Inventur
gegen den Laufzeit-Nenner stehen dort, und das Trigger-Audit trägt im Repo ohne Wellen-Betrieb die
Slice-Closure. **Die Welle ist aufgelöst**; Begründung, gesperrter Ortswechsel und die benannte
Lücke stehen in ihrem §4, die Umplanung im Drift-Log der Roadmap.

**Bezug:**
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk geht
vollständig ins Ziel — diese drei Aussagen sagen, was davon dort trägt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nichts
behaupten, was nicht läuft — hier auch auf die Abwesenheit angewandt),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (die Schranke, an
der ein mitgelieferter Freshness-Sensor scheitert: der hiesige Träger fährt `curl`),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Mechanik — sie wächst hier nicht),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(committet-vendored statt gefetcht — die Adaption, die alle drei Aussagen nötig macht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — der Nenner der Inventur wird zur Laufzeit gelesen, nicht notiert),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (*Accepted* — sie trägt den Wert des
Doku-Konsistenz-Blocks),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (*Accepted* — sie
setzt für Erfassung, Token-Attribution, Cache-Counter und Rollen-Typen den Wert *geht mit*; solange
ihre Emission nicht liegt, ist sie der Auflösungs-Trigger dieser Zellen, nicht ihr Zellwert).

**Berührte Spec-Stellen:** — Der Slice ändert keine Spec-Stelle; er füllt die emittierte
Doku-Schicht des Ziels.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Das frisch gebootstrappte Repo sagt in seiner **lebenden** Schicht drei Dinge über den
vendored Baum, den es mitbekommt: dass dieser Baum still altert und wer den Freshness-Audit
schuldet, dass seine `make`-Namen Kurs-Beispiele und keine Ziele dieses Repos sind, und welche
seiner Regeln dort einen Träger haben — je Regelblock genau einer von drei Werten.

**Übernimmt:** `slice-090-freshness-audit-im-ziel`, `slice-091-vendored-baum-ohne-anspruch`,
`slice-092-traeger-inventur`.

**Warum die drei ein Slice sind.** Sie haben denselben Adressaten (den Adopter), denselben Ort
(Dokumente, die das Ziel ohnehin bekommt), denselben Gegenstand (den mitgelieferten Baum) und
denselben Wächter-Zugang (`make full-smoke` über beide Bootstrap-Varianten, dazu ein hermetischer
Go-Test). Getrennt fassen sie dieselbe emittierte Datei dreimal nacheinander an — der
Schicht-Schnitt, vor dem Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice warnt.

**Der Befund gehört gefahren, nicht zitiert.** Die Kommandos stehen hier, ihre Zahlen nicht: Sie
werden an zwei Sonden-Repos genommen (`ai-harness-init --name Probe` sowie `--lang go`, je in ein
leeres `git init`-Verzeichnis), und ein Sonden-Repo entsteht erst im Lauf
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Im Sonden-Repo gefahren:

```sh
# (1) sagt die lebende Schicht etwas über das Altern des Baums?
grep -rni 'freshness' --exclude-dir=.git --exclude-dir=baseline . | wc -l
# (2) welche make-Namen des mitgelieferten Baums trifft keine Regel des Ziels?
comm -23 \
  <(grep -rhoE 'make [a-z][a-z0-9-]+' .harness/baseline/*/ | sed 's/^make //' | sort -u) \
  <(grep -hoE '^[a-zA-Z][a-zA-Z0-9_.-]*:' Makefile harness/mk/*.mk d-check.mk | tr -d ':' | sort -u)
# (3) der Nenner der Inventur — zur Laufzeit gelesen, nicht notiert
ls .harness/baseline/*/regelwerk/*.md | wc -l
```

**Der Wert-Vorrat der Inventur ist geschlossen, drei Werte:** *Träger kommt mit* · *liegt bei,
nicht verdrahtet* · *kommt nicht mit* — letzterer mit Grund und Dauer, also mit Zeiger auf eine
permanente Entscheidung oder mit dem Auflösungs-Trigger, an dem die Zelle kippt. Die Zelle sagt den
Zustand des Ziel-Repos, nicht den Stand der Entscheidung; für einen Träger, der beschlossen und
nicht abgelegt ist, wäre *geht mit* die Falschaussage, die dieser Slice verhindert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Freshness-Sensor im Ziel.** Er bräuchte `curl` und läge damit außerhalb von
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); zugleich wäre er
  ein neues Artefakt in der Aufzählung von
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren). Beides
  zusammen ist ein Change Request nach
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  — ein **anderer Vorgang**.
- **Der vendored Baum wird nicht angefasst.** Er ist byte-verifiziert (`make baseline-verify` gegen
  `SHA256SUMS`); wer den Anspruch dort heilte, färbte das Gate rot. Der **Bestand bleibt bewusst
  stehen**, die Aussage liegt daneben.
- **Der emittierte Datei-Satz wächst nicht.** Die drei Aussagen landen in Dokumenten, die das Ziel
  ohnehin bekommt; ein zusätzlicher Pfad wäre eine Erweiterung von
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
  gehört in den Vorgang, der den Vertrag ändert — **Schicht-Abgrenzung**.
- **Kein Sensor, der Träger und Regel automatisch aufeinander abbildet.** Der Nenner ist
  mechanisch, die Zuordnung ist ein Urteil; sie mechanisch auszugeben hieße, ein Muster als
  Kriterium auszugeben ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — **anderer Vorgang**, falls je
  einer entsteht.
- **Die Aktivierung von `doc-targets` im Ziel.** Sie ist Gegenstand von welle-09; hier steht für
  diesen Regelblock nur der Wert *liegt bei, nicht verdrahtet* — **Schicht-Abgrenzung**.

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

- [ ] **(1) Das Ziel nennt den Freshness-Audit als geschuldete Handlung** — mit dem gepinnten Tag,
      der Release-**Listen**-Quelle und der Aussage, dass kein Sensor mitkommt, weil er `curl`
      bräuchte. **Rot:** `make full-smoke` — eine Marker-Prüfung über `tmprepo` **und**
      `tmprepo_doc`, die [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)
      beide fährt; rot gesehen, indem die Zeile emit-seitig zurückgenommen wird.
- [ ] **(2) Eine lebende Zeile weist den mitgelieferten Baum als Kurs-Inhalt aus**, dessen
      `make`-Namen keine Ziele dieses Repos sind — als **Eigenschaft**, nicht als Namensliste.
      **Rot:** derselbe `make full-smoke`-Lauf für die Anwesenheit der Zeile. Dass sie eine
      Eigenschaft nennt, färbt **kein** Kommando rot; das ist ein Urteil beim Schreiben, und es
      steht hier, statt sich hinter (1) zu verstecken. Prüfbar bleibt die Gegenrichtung: die Zeile
      nennt keinen `make`-Namen, den das Ziel nicht führt.
- [ ] **(3) Jeder Abschnitt des mitgelieferten Regelwerks trägt genau einen der drei Träger-Werte**
      — keine leere Zelle, und keine Zelle behauptet die Abwesenheit eines Trägers, den derselbe
      Lauf ablegt. **Rot (hermetisch):** `make test` — ein Go-Test hält die Einträge gegen die
      `*.md` des committeten `regelwerk/`-Verzeichnisses und gegen die Emit-Pfad-Listen; dazu je
      ein `test/mutations/`-Fall mit `# verify: test-go`. **Rot (real):** `make full-smoke` gegen
      den zur Laufzeit gelesenen Nenner des Ziels — nur dieser Lauf fängt den Fall, in dem das Ziel
      einen anderen Baum bekommt, als dieses Repo führt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: berührt ist die emittierte Doku-Schicht selbst — sie **ist** der Gegenstand.
      Der emittierte Datei-Satz bleibt dabei unverändert (DoD 3, Ziel-Pfad-Liste in
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go)).
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
| [`internal/emit/`](../../../../internal/emit) (Erzeugung der drei Aussagen) | update | die Aussagen entstehen dort, wo das Ziel seine Dokumente herbekommt |
| [`internal/emit/templates/`](../../../../internal/emit/templates) (betroffene Vorlage) | update | Trägerdokument der drei Aussagen; kein neuer Pfad |
| [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go) | update | die Ziel-Pfad-Liste bleibt unverändert — der Datei-Satz wächst nicht |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | Marker-Prüfung über `tmprepo` **und** `tmprepo_doc`, Inventur gegen den Laufzeit-Nenner |
| [`test/mutations/`](../../../../test/mutations) | neu | je ein Fall mit `# verify: test-go` für die zwei Richtungen aus DoD 3 |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Der Reihenfolge nach: erst die Aussage aus DoD 3 (sie legt fest, wo die drei Aussagen stehen),
  dann die zwei Sätze aus DoD 1 und 2 im selben Dokument. Umgekehrt entstünde ein Trägerdokument
  zweimal.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei und die drei
übernommenen Slices liegen in `done/`. Eine Welle-Zugehörigkeit ist keine Bedingung mehr — der
Slice läuft wellenlos (Kopf).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): DoD 3 füllt allein eine Review-Sitzung —
  erkennbar daran, dass die Einträge je Regelblock stehen, während DoD 1 und 2 noch nicht begonnen
  sind. Dann wird die Inventur eigens geschnitten, und dieser Slice behält die zwei Sätze.
- `in-progress` → `open` (blockiert — Carveout?): Eine Zelle der Inventur verlangt einen Wert, den
  keine angenommene ADR setzt — dann fehlt eine Entscheidung, und die gehört vor die Arbeit.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` und `make full-smoke` sind grün, und die drei Aussagen sind in **beiden**
   Bootstrap-Varianten belegt.
2. Jeder der drei Liefer-Punkte ist mit seinem Rot-Kommando einmal rot gesehen; die **gelesene**
   Ausgabe steht im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **DoD 3 sprengt die Review-Sitzung.** Die Inventur trägt einen Eintrag je Regelblock; der Nenner
   ist das `regelwerk/`-Verzeichnis. *Absehbar:* entfallen, wenn der Review den Slice in einer
   Sitzung durchgeht; sonst eingetreten mit der Rückführung aus §4 als Ausgang.
2. **Eine Zelle verlangt einen Wert, den keine ADR setzt.** *Absehbar:* entfallen, wenn
   [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) und
   [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) jede offene
   Zelle decken; sonst Übergabe an den Architect und Folge-Slice.
3. **Der Marker hängt nur an einer Bootstrap-Variante**, und die zweite fällt still durch.
   *Absehbar:* entfallen, wenn die Prüfung in beiden Varianten einmal rot gesehen wurde.
4. **Die drei Aussagen finden in keinem vorhandenen Dokument Platz**, und der Datei-Satz wächst
   doch. *Absehbar:* entfallen, wenn die Ziel-Pfad-Liste unverändert bleibt; sonst ist es eine
   Vertragsfrage nach
   [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
   damit ein anderer Vorgang.

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
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/emit/` samt seinen Vorlagen,
`test/mutations/` und `harness/tools/full-smoke.sh`. Die ersten zwei liegen in `*`; der dritte
liegt in `harness/tools/` (`TOOLS`). `.codex/` (`CODEX`) ist nicht berührt. Beide berührten
Sub-Areas erfüllen das Inklusionskriterium (eigene Konventions-Linie, eigener Änderungsrhythmus,
eigener Prüfbereich); ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die
`state.md` des Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md) | 16 | verkörpert | der Nenner der Inventur wird zur Laufzeit gelesen, nicht notiert (§1) |
| [`baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md) | 4 | verkörpert | die Aussage aus DoD 1 nennt den gepinnten Tag |
| [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | 28 | geplant | DoD 2 — eine Namensliste überlebte den nächsten Baseline-Sprung nicht |
| [`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md) | 2 | offen | DoD 3 misst eine Richtung über einer Teilmenge; §6 Risiko 1 |

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

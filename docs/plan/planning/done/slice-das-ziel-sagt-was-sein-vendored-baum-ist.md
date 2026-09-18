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

- [x] **(1) Das Ziel nennt den Freshness-Audit als geschuldete Handlung** — mit dem gepinnten Tag,
      der Release-**Listen**-Quelle und der Aussage, dass kein Sensor mitkommt, weil er `curl`
      bräuchte. **Rot:** `make full-smoke` — eine Marker-Prüfung über `tmprepo` **und**
      `tmprepo_doc`, die [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)
      beide fährt; rot gesehen, indem die Zeile emit-seitig zurückgenommen wird.
- [x] **(2) Eine lebende Zeile weist den mitgelieferten Baum als Kurs-Inhalt aus**, dessen
      `make`-Namen keine Ziele dieses Repos sind — als **Eigenschaft**, nicht als Namensliste.
      **Rot:** derselbe `make full-smoke`-Lauf für die Anwesenheit der Zeile. Dass sie eine
      Eigenschaft nennt, färbt **kein** Kommando rot; das ist ein Urteil beim Schreiben, und es
      steht hier, statt sich hinter (1) zu verstecken. Prüfbar bleibt die Gegenrichtung: die Zeile
      nennt keinen `make`-Namen, den das Ziel nicht führt.
- [x] **(3) Jeder Abschnitt des mitgelieferten Regelwerks trägt genau einen der drei Träger-Werte**
      — keine leere Zelle, und keine Zelle behauptet die Abwesenheit eines Trägers, den derselbe
      Lauf ablegt. **Rot (hermetisch):** `make test` — ein Go-Test hält die Einträge gegen die
      `*.md` des committeten `regelwerk/`-Verzeichnisses und gegen die Emit-Pfad-Listen; dazu je
      ein `test/mutations/`-Fall mit `# verify: test-go`. **Rot (real):** `make full-smoke` gegen
      den zur Laufzeit gelesenen Nenner des Ziels — nur dieser Lauf fängt den Fall, in dem das Ziel
      einen anderen Baum bekommt, als dieses Repo führt.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: berührt ist die emittierte Doku-Schicht selbst — sie **ist** der Gegenstand.
      Der emittierte Datei-Satz bleibt dabei unverändert (DoD 3, Ziel-Pfad-Liste in
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go)).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
   Sitzung durchgeht; sonst eingetreten mit der Rückführung aus §4 als Ausgang. — **Ausgang:**
   **entfallen** — die Rückführung `in-progress → next` wurde nicht gezogen, und jede der fünf
   Runden liegt als je *ein* Report vor. Die Inventur blieb bei drei Liefer-Punkten und einer
   Trägerdatei; kein Punkt wurde nachgeschoben. **Was die Sitzung dennoch kostete, gehört in den
   Ausgang:** fünf Runden statt einer, davon drei über Nacharbeit an derselben Klasse (§7).
2. **Eine Zelle verlangt einen Wert, den keine ADR setzt.** *Absehbar:* entfallen, wenn
   [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) und
   [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) jede offene
   Zelle decken; sonst Übergabe an den Architect und Folge-Slice. — **Ausgang:** **entfallen** —
   keine Zelle steht ohne Wert, und die zwei Zellen, die eine Entscheidung brauchen, sind gedeckt:
   der Doku-Konsistenz-Block durch [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md)
   Festlegung 4 (*liegt bei, nicht verdrahtet*), die Erfassungs-Zelle durch
   [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7.
   Ein Folge-Slice entstand daraus nicht. **Die Zelle blieb trotzdem angreifbar** — nicht wegen des
   fehlenden Wertes, sondern wegen der fehlenden Bedingung (Review F-3 und R3-1); das ist die
   Beobachtung dieses Slice, nicht dieses Risiko.
3. **Der Marker hängt nur an einer Bootstrap-Variante**, und die zweite fällt still durch.
   *Absehbar:* entfallen, wenn die Prüfung in beiden Varianten einmal rot gesehen wurde. —
   **Ausgang:** **entfallen, mit benannter Einschränkung.** Beide Varianten laufen und melden
   getrennt: `make full-smoke` gibt die Stufe zweimal aus, mit eigenem Etikett und eigenem Nenner
   (`--lang go` und `sprachlos`), und die Funktion ist an jeder ihrer fünf Bedingungen
   fail-closed — vom Verifier selbst gemessen. **Rot gesehen ist der zweite Aufruf nicht:** was ihn
   deckt, ist `test/mutations/367` samt der gelesenen Ausgabe im Umsetzungs-Commit `d47c7c57` (der
   erste Aufruf meldet Erfolg, der zweite fällt) — und die Struktur-Aussage des Verifikations-Laufs
   über den `sed`-Anker. Ein Rot aus der Hand des Verifiers steht nicht dagegen; der Fall kostet je
   Lauf einen vollen E2E. Die Einschränkung ist damit benannt statt weggelassen; ihre Klasse zählt
   das Register (§7, `zusage-ohne-herstellbares-gegenbeispiel` ist es **nicht** — der Fall ist
   herstellbar und wurde einmal hergestellt, nur nicht vom prüfenden Lauf wiederholt).
4. **Die drei Aussagen finden in keinem vorhandenen Dokument Platz**, und der Datei-Satz wächst
   doch. *Absehbar:* entfallen, wenn die Ziel-Pfad-Liste unverändert bleibt; sonst ist es eine
   Vertragsfrage nach
   [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
   damit ein anderer Vorgang. — **Ausgang:** **entfallen** — der Block wird in die vorhandene
   emittierte `harness/conventions.md` injiziert; keine neue Ziel-Adresse im Diff, die
   Schlüsselmenge der Fixture unverändert, die oberste Gliederungs-Ebene der emittierten Datei
   unangetastet. [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
   bleibt unberührt; eine Vertragsfrage ist nicht entstanden.

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

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang
sind die fünf Review-Reports und der Verifikations-Report, alle vom 2026-09-18. Maßstab sind
Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln und
`modul-06-roadmap.md` §Das Beobachtungs-Register.

- **Was hat funktioniert:**
  - **Die drei Aussagen kosteten keinen neuen Pfad.** Sie werden emit-seitig in ein Dokument
    injiziert, das das Ziel ohnehin bekommt; der vendored Baum bleibt byte-verifiziert und die
    Ziel-Pfad-Liste unverändert. Damit hielt der Slice die drei Ausschlüsse aus §1, die genau das
    verboten hätten — der Verifikations-Report hat jeden einzeln gegen den Diff gehalten.
  - **Der Nenner wird zur Laufzeit gelesen, nicht notiert.** Die Inventur misst gegen das
    `regelwerk/`-Verzeichnis **des Ziels**, und die Stufen-Meldung erzeugt ihre Zahl im Lauf
    ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
    Setzung 2). Ein Ziel mit anderem Baum fällt damit auf, statt still eine fremde Zahl zu erben.
  - **Zwei Wächter statt eines, in zwei Härten.** Hermetisch (Go-Test über der Deckung und über der
    Abwesenheits-Richtung, dazu `test/baum-inventur.bats`) und real
    (`make full-smoke` über beide Bootstrap-Varianten). Zwei Mutations-Fälle hat der Verifier selbst
    rot gefahren und **die Meldung gelesen** — sie nennt in beiden Fällen den behaupteten Grund.
  - **Fünf Review-Runden haben ihre Befunde weitergetragen:** F-1 bis F-6, R3-1 bis R3-4, R4-1 und
    R4-2 behoben; jede Behebung prüfte die Folgerunde mit einem selbst gefahrenen Kommando nach.
    Die Runden 4 und 5 haben dabei zweimal die **Zusage verengt**, statt den Slice über seine
    Schicht hinauszutreiben — der Satz sagt am Ende, was der Lauf tut, und nicht mehr.
- **Was ging anders als geplant:**
  - **§3 deckt den berührten Datei-Satz in beide Richtungen nicht** (Verifikation V-2, Review F-7).
    *Gebaut, nicht geplant:* [`test/baum-inventur.bats`](../../../../test/baum-inventur.bats) — der
    Wächter, der die Nenner-Hälfte trägt — und die Regeneration von
    [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md). *Geplant, nicht gebaut:*
    die Zeile `internal/emit/templates/` *(betroffene Vorlage)* mit Änderungs-Art **update**; unter
    diesem Pfad berührt der Diff keine Datei. Der gewählte Weg — Injektion in die Zeichenkette des
    Dokuments statt Änderung einer Vorlage — ist der richtige, und §1 schließt das Anfassen des
    vendored Baums ausdrücklich aus; die Plan-Zeile hätte so nicht dastehen dürfen.
    **§3 bleibt trotzdem, wie er ist:** Der Plan ist das Artefakt *vor* dem Code, und ein
    nachgetragener Plan behauptete Voraussicht, die es nicht gab. Der Befund steht hier, die Klasse
    ist unten gezählt.
  - **Fünf Runden statt einer, und drei davon trugen dieselbe Klasse.** F-3, R3-1 und R4-1 sind
    derselbe Fehler an drei Stellen: eine Aussage über das Ziel, die weiter reicht als der Zweig des
    Emitters, den sie nicht nennt. Keine davon fand ein Gate; gefunden hat sie jedes Mal der
    Abgleich der emittierten Zeile mit dem Code, der sie erzeugt. Das ist die Beobachtung dieses
    Slice.
  - **Zwei Fragen gehören einer anderen Rolle** und sind darum nicht hier beantwortet — Übergabe
    unten.
- **Entscheidungen zu den Befunden, die offen in die Closure kamen:**
  - **V-1 (MEDIUM, behoben):** Die Roadmap-Zelle nannte eine Adresse, die im Ziel nicht existiert.
    Geheilt in `63618fb6`, **und die Richtung hat seitdem einen Wächter** — das ist der Lerneintrag
    unten. Die Klasse ist als eine der vier Instanzen der neuen Beobachtung gezählt: Sie ist
    dieselbe Richtung wie F-3/R3-1/R4-1, nur an der Adresse statt an der Bedingung.
  - **V-2 (LOW) / F-7 (LOW):** oben festgehalten; §3 bleibt. Klasse gezählt.
  - **V-3 und V-4 (INFO):** kein Beleg, kein Eintrag. Beide sagen, dass der emittierte Text an
    dieser Stelle **genauer** ist als der Wortlaut der DoD (`curl` ist der Träger *dieses* Repos,
    nicht des Ziels) bzw. dass der Tag als Route statt als zweite eingefrorene Fassung dasteht —
    die Anwendung von [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
    Setzung 2, nicht ihre Verletzung.
  - **F-8 (INFO):** **Register**, [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
    Der Grund, warum kein eigener Vorgang daraus wird: Die erzeugte Sicht führt **Stufen**, nicht
    Zähne, und die neue Prüfung eröffnet keine — sie läuft in zweien
    (`harness/tools/full-smoke.sh:363` und `:1784`). Was dabei stehen blieb, ist die *Deklaration*
    dieser zwei Stufen: Ihr Inhalt ist gewachsen, ihre Kennungs-Zeile nicht. Genau diese Klasse
    zählt der Eintrag; wer die Stufen-Deklaration das nächste Mal anfasst, zieht sie nach.
  - **R2-2 (INFO):** **Register**, [`config-kommentar-nennt-anderen-bereich-als-der-eintrag`](../observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/observation.md)
    — der Eintrag erreicht damit die Schwelle; sein Ausgang steht unten beim Lese-Schritt.
  - **R5-1 (INFO):** **Register**, [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
    Die Aussage ist heute wahr und vom Reviewer über alle drei skip-if-present-Gruppen nachgezählt;
    was fehlt, ist der Wächter für ihre **Abgrenzung**. Kein eigener Vorgang: Der Sensor wäre ein
    Go-Test über der Zahl der skip-if-present-Einträge mit echtem Melde-Kanal, und er gehört zu dem
    Kanal-Ausbau, den §1 als Schicht-Abgrenzung ausschließt — solange der Kanal so bleibt, ist die
    Aussage eine Messung mit gelesenem Beleg und keine Zusage ohne Deckung.
- **Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)** — keine Bedingung dieses
  Slice, beide aus dem Review:
  - **R2-1 (LOW):** [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
    Konventions-Quellen zählt *„Fünf Stellen"*, die den Baseline-Tag pinnen; mit `InventurMessTag`
    ist eine sechste entstanden, fail-closed gekoppelt und in `make gates` laufend. Zu entscheiden
    ist die Lesart (*Stellen, die Tag **samt** sha256 pinnen* — dann bleibt es bei fünf) und
    gegebenenfalls der Nachtrag. Der Absatz gehört dem Architect; dieser Lauf fasst ihn nicht an.
  - **Klassenfrage aus F-5:** Darf ein emittiertes **skip-if-present**-Dokument eine abgeleitete
    Namensliste über einer konvergenten Quelle tragen, und woran hängt ihre Grenze? Hier ist sie
    mit dem Mess-Tag beantwortet (in der Form von [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)); ob das die Regel für die Klasse ist, ist eine
    Entscheidung und keine Umsetzung.
- **Steering-Loop-Eintrag:** **Neuer Sensor.** Jede Adresse, die eine Zelle der Träger-Inventur
  nennt, wird gegen die Adressen gehalten, die der Emit wirklich schreibt — hermetisch in
  `internal/emit/baumaussage_test.go` (`make test`), dazu die Nenner-Deckung in
  [`test/baum-inventur.bats`](../../../../test/baum-inventur.bats) und die reale Gegenprobe in
  [`make full-smoke`](../../../../harness/sensors/full-smoke.md) über beide Bootstrap-Varianten.
  - **Ohne Anker-Feld.** Der Sensor entstand aus einem Verifikations-Befund (V-1), nicht aus dem
    3×-Übertritt des Registers; `grundlagen-traceability.md` §Herkunfts-Anker bindet den Anker eng
    an die Schwelle, und `liegt in` steht deshalb hier nicht.
  - **Was er zieht:** Eine Zelle kann keine Adresse mehr nennen, die im Ziel nicht entsteht — die
    Richtung, die vor ihm nur ein Leser fand, der die Tabelle Zeile für Zeile gegen eine Sonde hielt.
  - **Was er nicht erreicht:** die **Bedingung** eines Trägers. Gelingens-Zweig, skip-if-present und
    Melde-Kanal liest er nicht, und `make full-smoke` auch nicht — dort entsteht jedes Ziel im
    Gelingens-Zweig und auf leerem Grund. Genau dort liegt die neue Beobachtung unten; sie ist
    **gezählt, nicht verkörpert**.
- **Beobachtungs-Register (`../observations/`):**
  - Der Beleg heißt in jedem Fall `evidence/slice-das-ziel-sagt-was-sein-vendored-baum-ist.md`.
    Den Zähler liefert `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, die
    Zahl der Belege aus diesem Vorgang
    `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-das-ziel-sagt-was-sein-vendored-baum-ist.md | wc -l`.
    Keine der Zahlen ist ein Erwartungswert.
  - **Ein neues Verzeichnis**,
    [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md).
    Kein vorhandener Eintrag trägt die Klasse: Der nächste,
    [`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md),
    misst eine Prosa-Zusage gegen den Prüfumfang eines **benannten Gates** — hier nennt keine
    Aussage ein Gate, und der Maßstab ist der bedingte Zweig des Emitters. Die zwei weiteren
    Abgrenzungen stehen im Eintrag selbst.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) | Review F-3, R3-1, R4-1; Verifikation V-1 | 1 | offen |
  | [`config-kommentar-nennt-anderen-bereich-als-der-eintrag`](../observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/observation.md) | Runde 2, R2-2 | 3 | geplant |
  | [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | Review F-5, F-7, F-8; Runde 5, R5-1; Verifikation V-2 | 29 | geplant |
  | [`baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md) | Review F-5, zweite Hälfte | 5 | verkörpert |

  **Lese-Schritt.** **Ein** Eintrag erreicht mit diesem Slice zum ersten Mal 3×:
  `config-kommentar-nennt-anderen-bereich-als-der-eintrag`. Sein Ausgang ist **geplant**, mit
  Kennung: [`slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand`](../open/slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand.md)
  — er schreibt die Regel, dass die Begründung neben einem Ausnahme-Eintrag den ganzen Gegenstand
  ihres Schlüssels nennt, und deckt beide Ebenen (diese Gate-Konfiguration und die emittierte).
  *Verkörpert* war hier nicht zu setzen: Der Norm-Text gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und ein Ausgang, der auf einen ungeschriebenen Ort
  zeigt, wäre die Form ohne die Sache.
  **Die Nachbar-Adresse nimmt ihn nicht an:** `slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung`
  trägt [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md)
  und entscheidet, **ob** ein Eintrag sein darf; hier geht es darum, **worüber** seine Begründung
  spricht. Ihn dort einzuhängen hieße, einen Ausgang auf einen Träger zu setzen, der ihn nicht führt.
  Repo-weit trägt danach kein Eintrag mit mindestens drei Belegen den Stand `offen` — in der Closure
  gemessen, je Verzeichnis die Zahl der Belege gegen die erste Zeile der `state.md`.
- **Folge-Slices:** **einer, neu** —
  [`slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand`](../open/slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand.md)
  (Die Begründung neben einem Ausnahme-Eintrag nennt den ganzen Gegenstand, den ihr Schlüssel stumm
  schaltet) — eine Datei in `open/`, angelegt aus der vendored Vorlage. Er ist der Ausgang des
  Lese-Schritts und trägt keinen der übrigen Befunde.
  **Kein weiterer, und der nächstliegende ausdrücklich nicht:** Ein Melde-Kanal für `Templates`,
  `RootReadme` und `DocGate` (der Rest aus R4-1) wäre eine **Verhaltens**-Änderung des Bootstraps
  statt einer Aussage über ihn — §1 grenzt das als Schicht ab, und die Runde 5 hat diese
  Abgrenzung eigens geprüft. Wer den Kanal will, eröffnet den Vorgang dafür; diese Closure
  erfindet ihn nicht.
- **Risiken aus §6:** vier, jedes mit genau **einem** Ausgang, alle *entfallen* — Risiko 3 mit der
  Einschränkung, die dort ausgeschrieben steht (der zweite Varianten-Aufruf ist durch
  `test/mutations/367` und die gelesene Ausgabe in `d47c7c57` gedeckt, nicht durch ein Rot aus der
  Hand des prüfenden Laufs).
- **Drei Paarungen** (Repo ohne Wellen-Betrieb, geprüft zur Closure):
  - **Anker:** kein Gegenstand — der Steering-Loop-Eintrag trägt kein Feld `liegt in`, weil mit
    diesem Slice keine 3×-Regel verkörpert wurde.
  - **Folge-Slice:** `slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand` liegt als Datei im
    Planning-Lifecycle (`open/`).
  - **Register:** jede hier genannte Beobachtung existiert als Verzeichnis unter
    `observations/BEO-ALL/`, und jedes dieser Verzeichnisse trägt mindestens einen Beleg.
    Repo-weit trägt **ein** Verzeichnis keinen —
    [`einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md);
    sein einziges Vorkommen steht dort unter *Benannt, nicht gezählt*, und die Lesart dazu
    entscheidet `slice-beleglose-register-eintraege-bekommen-eine-lesart`. Benannte Lücke mit
    Adresse, kein Fund dieser Closure.
- **Trigger-Audit** (bei der Slice-Closure, weil dieses Repo ohne Wellen-Betrieb arbeitet):
  - **Carveout:** [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) steht auf *Aktiv —
    Auflösung fällig*, seine Adresse ist `slice-141-co-001-aufloesung-ist-vorher-entschieden` in
    `next/`; [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) steht auf *Permanent*.
    Dieser Slice berührt keine ihrer Bedingungen — er nennt `CO-002` nur als Vorbedingung einer
    Inventur-Zelle, wie es [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) vorsieht.
  - **Bootstrap-aware Gate:** keines in diesem Repo.
  - **ADR:** [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) — kein Re-Evaluierungs-Trigger
    eingetreten: Der Erfassungs-Block entsteht im Ziel nicht neu, die Hook-Oberfläche ist unberührt,
    und die Frage hinter `CO-002` bleibt offen. [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
    — ebenfalls keiner: kein Latenz-Befund, kein Adopter-Bestand mit Verbrauchs-Zählern, keine
    geänderte Hook-Oberfläche; Festlegung 7 ist von zwei Zellen **zitiert**, nicht bewegt.
    [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) — keiner: Das
    Werkzeug entscheidet die Herkunft des Pfades weiterhin nicht, und die zwei Sonden dieses Laufs
    sind leere Ziele, keine Stichprobe gebauter Ziele ohne fremden Träger. Der Slice **beschreibt**
    die Klasse im Ziel, er wägt sie nicht neu.
  - **Adaptions-Einträge, die dieser Slice fährt:**
    [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
    (der vendored Baum bleibt byte-verifiziert — `make baseline-verify` in beiden Sonden grün),
    [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
    Setzung 2 (der Nenner zur Laufzeit),
    [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
    (der Mess-Tag des Inventur-Blocks, fail-closed an den gefetchten Stand gekoppelt) und
    [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
    (die `modul-14`-Zelle zeigt auf `d-check.mk`, statt eine zweite Fassung zu führen). Keiner ihrer
    Auflösungs-Trigger ist eingetreten; die Reichweiten-Frage an
    [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
    steht als R2-1 beim Architect.
    [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel):
    nicht berührt — kein Modul geht neu ins emittierte Doc-Gate.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.

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

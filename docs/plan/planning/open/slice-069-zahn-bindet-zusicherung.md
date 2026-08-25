# Slice slice-069: Ein Zahn bindet eine ZUSICHERUNG, nicht einen Wächter-Namen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung) — die Klasse ist bei
[slice-060](../done/slice-060-rollen-achse.md) fünfmal aufgetreten, betrifft aber
`harness/tools/mutate.sh` und damit jeden Slice.

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel — die Regel, deren Sensor hier zu eng greift),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
(die Sensor-Mechanik dieses Repos),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) —
ausdrücklich als **Analogie benannt, nicht als Bezug beansprucht**: die Anforderung gilt für
*emittierte* Gate-Targets, dieser Slice für den Dogfood-Sensor. Der Fehler hat dieselbe Form
(ein Gate ist grün und belegt nicht, was sein Name sagt), die Ebene ist die andere.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-30.

---

## 1. Ziel

**`make mutate` soll belegen, dass der genannte Fall die genannte EIGENSCHAFT bindet — nicht
nur, dass er irgendeinen roten Wächter erzeugt.**

Der Treiber bindet je Fall **einen Wächter-NAMEN**: Bedingung 4 sucht den Wert aus `# expect:`
in der Fehlschlag-Ausgabe (`harness/tools/mutate.sh`, `report_fail "rot, aber '$expect' faellt
nicht — falscher Grund"`). Ein Wächter mit *N* Zusicherungen kann über Zusicherung 1 rot
werden, während Plan, Kommentar oder Adaption behaupten, der Fall binde Zusicherung 7. Der
Treiber meldet **ok**, das Gate bleibt grün, und die Zuschreibung ist trotzdem falsch.

**Fünf gemessene Instanzen in einer einzigen Slice-Familie** (jede von einem unabhängigen
Review gefunden, keine von einem Gate): `110` sollte `tool` bewachen und mutierte
`tool_use_id` · `127` band die Grenz-Zusicherung nicht, weil er aus zwei Gründen rot wurde ·
`131` nannte `TestAgentGetsNoArgumentFields`, band aber dessen `"tool":"Agent"`-Gegenprobe
statt B1 · `134` galt als Sensor für die Abwesenheit von `spawned_role` und mutiert
`input_tokens` · derselbe Wächter-Eintrag war anschließend von **keinem** der vier Fälle
gebunden, die ihn nennen.

**Warum das kein Fleiß-Problem ist:** die Zuschreibung ist an jeder Stelle plausibel, und
`make comment-claims` fängt sie bauartbedingt nicht — es prüft, dass ein genannter **Test
existiert**, nie ob ein genannter **Fall die genannte Zusicherung bindet**. Fall-Köpfe,
`_test.go`-Kommentare und `harness/conventions.md` liegen zudem alle außerhalb seines
Prüfbereichs ([slice-070](slice-070-comment-claims-pruefbereich.md)).

## 2. Definition of Done

- [ ] **(1) Der Fall-Kopf trägt die ZUSICHERUNG, nicht nur den Wächter-Namen.** Ein neues
  Kopf-Feld — Arbeitstitel `# fails-at:` — nennt den erwarteten **Fehlschlag-TEXT**, gegen den
  der Treiber die Ausgabe prüft (Beispiel: `# fails-at: "spawned_role" steht in der
  Span-Zeile`). Damit hebt sich Bedingung 4 von **Wächter**- auf **Zusicherungs**-Granularität.
  **Bewusst kein Zeilennummern-Feld:** Zeilennummern altern bei jeder eingefügten Zeile, der
  Fehlschlag-Text nicht.
- [ ] **(2) Der Zahn des Sensors ist der Sensor selbst.** Ein Mutations-Fall, der *das neue
  Kopf-Feld* aushebelt, muss rot werden — sonst hat die Schärfung dieselbe Krankheit wie das,
  was sie heilt. **Zweiseitig zu belegen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): mit
  intaktem Feld `ok`, mit falschem `fails-at` ein **Befund**. Mindestens eine der fünf
  historischen Instanzen ist nachzustellen und muss unter dem neuen Treiber **rot** werden —
  ein Sensor, der seine eigene Fund-Geschichte nicht reproduziert, ist unbelegt.
- [ ] **(3) Die Migration der Bestands-Fälle ist ENTSCHIEDEN, nicht angefangen.** Drei
  Wege stehen offen: rückwirkend für alle, nur für neue Fälle, oder ein Vollständigkeits-Zähler
  („N von M Fällen tragen `fails-at`"). Die Wahl gehört begründet in
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  — samt der ehrlichen Größe: **ein Feld je Fall über den gesamten Bestand von
  `test/mutations/`**, dessen Umfang beim Entscheiden ausgezählt wird. Wird nicht rückwirkend
  migriert, ist das eine **deklarierte Abweichung mit Auflösungs-Trigger**, keine stille
  Teilmenge.
- [ ] `make gates` grün; der Vollauf `make mutate` grün über die CI (`.github/workflows/ci.yml`,
  frischer Runner — der lokale Host-Speicher-Ausschluss gilt dort nicht).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Kopf-Parsing um das neue Feld, Bedingung 4 auf den Fehlschlag-Text. **Zugewiesener Kommentar-Nachzug** ([`AGENTS.md`](../../../../AGENTS.md) §3.7): der Kommentar über dem Abbruch-Zweig des Grün-Vorlaufs sagt *„Woran er lag, steht in den Zeilen darunter"* und verspricht damit, was `tail -n 12` nicht hält — bei einem Abbruch mitten in einem Docker-Build steht die Ursache nicht zwangsläufig in den letzten zwölf Zeilen. Der Satz gehört auf das eingeschränkt, was der Tail trägt; er steht an derselben Datei, die dieser Slice ohnehin anfasst |
| `test/mutate-driver.bats` | update | die neue Bedingung als bats-Fall — der Treiber ist heute nur teilweise bewacht, und das steht in seinem eigenen Kopf. Dazu ein Fall für den Vorlauf-Zweig, der einen unbekannten `# verify:`-Modus meldet: `grep -n 'green_prerun' test/mutate-driver.bats` → **1** Aufrufer, und er ruft mit dem bekannten Modus `test`; der Meldezweig wird von keinem Fall erreicht |
| `test/mutations/` | neu + ggf. update | der Zahn aus DoD (2); der Umfang der Bestands-Migration entscheidet DoD (3). Dazu der Anker von `test/mutations/72-mutate-isolation-im-repo.sh` (siehe unten) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die Festlegung aus DoD (3) in [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) |

**Ist-Messung vor dem Code** (Modul 9 §4), zwei Fragen an denselben Bestand: **(a)** wie viele
Fälle nennen einen Wächter, der **mehr als eine** Zusicherung trägt? Das ist die Größe des realen
Risikos — heute geschätzt, nicht gezählt. **(b)** wie viele Fälle tragen einen `sed`-Anker, der
**mehr als eine** Zeile trifft? Diese zweite Frage ist die Spiegelseite der ersten: dort deckt der
Wächter mehr ab, als der Fall behauptet, hier bewegt der Eingriff mehr, als der Fall behauptet.

**Ein Fall des Bestands trägt (b) bereits belegt.**
`test/mutations/72-mutate-isolation-im-repo.sh` sedet den Anker `^      return 1$` und nennt ihn
im Kommentar *„einmalig, geprueft"*; er trifft **3** Stellen
(`grep -c '^      return 1$' harness/tools/mutate.sh`). Der Fall bleibt für seinen eigenen Zweck
grün — seine Bedingung 4 verlangt nur den erwarteten Wächter in der Fehlschlag-Ausgabe —, aber die
Einmaligkeit war ein Bestandszufall: sechs Leerzeichen sind Verschachtelungstiefe, keine
Eigenschaft des bewachten Verhaltens, und die nächste Verzweigung auf dieser Tiefe bricht sie
erneut. `test/mutations/77-mutate-abbruch.sh` macht im selben Verzeichnis die
haltbare Form vor: er bindet seinen Anker an einen **Bereich** statt an ein Layout. Auf Fall 72
übertragen ist das `/^isolation_path()/,/^}/` als Adressbereich des `sed`; darin trifft derselbe
Anker genau **1** Stelle
(`sed -n '/^isolation_path()/,/^}/p' harness/tools/mutate.sh | grep -c '^      return 1$'`), und
zwar weil die Funktion die Grenze zieht — nicht, weil der Bestand gerade so aussieht.

## 4. Trigger

**`open` → `next`:** [slice-060](../done/slice-060-rollen-achse.md) ist **done**. Grund
ist nicht Abhängigkeit, sondern WIP-Limit und Konfliktfläche: slice-060 legt weiter Fälle an.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls die Ist-Messung zeigt, dass die Bestands-Migration den Slice
  sprengt — dann trennt ein Re-Slice Mechanik von Migration.
- `in-progress` → `open`: falls sich zeigt, dass der Fehlschlag-Text je Sensor-Modus
  (`test`, `test-go`, `smoke`, `ci-lint`) zu verschieden ist, um ein einziges Feld zu tragen.
  Dann ist erst die Form zu entscheiden.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates`
grün und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein zweites Kopf-Feld ist eine zweite Stelle, die driften kann.** `# expect:` und
  `# fails-at:` können auseinanderlaufen. Der Entwurf ist deshalb daraufhin zu prüfen, ob das
  neue Feld das alte **ersetzt** statt es zu ergänzen — das wäre die Fassung ohne zweite
  Wahrheit.
- **Der Fehlschlag-Text ist an die Formulierung eines Tests gebunden.** Wird eine
  Fehlermeldung umformuliert, meldet der Treiber „rot, aber falscher Grund" — laut statt still,
  also fail-closed und richtig herum, aber es ist laufende Pflege.
- **Der Bestand ist dreistellig.** Die ehrliche Größe steht in DoD (3); sie zu verschweigen wäre der
  Weg, auf dem eine Teilmenge wie eine Vollständigkeit aussieht.
- **Der Treiber bewacht sich selbst nur teilweise** — das steht in seinem eigenen Kopf
  (`test/mutate-driver.bats` + Fall 09 decken `failure_form`, nicht die übrigen
  `run_case`-Zweige). Dieser Slice fasst genau diesen Bereich an.
- **Nicht in diesem Slice:** der Prüfbereich von `comment-claims`
  ([slice-070](slice-070-comment-claims-pruefbereich.md)) und die Frage, ob jeder Wächter
  überhaupt gelistet ist (Roadmap-Kandidat *Vollständigkeits-Wächter für kuratierte Listen* —
  die **andere** Richtung: Inventar gegen Abdeckung, nicht Bindung).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und `test/`
gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

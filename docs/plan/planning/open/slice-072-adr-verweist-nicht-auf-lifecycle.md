# Slice slice-072: Eine ADR verweist nicht auf einen Slice oder eine Welle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) **Bündel?** Nein — eine Konfigurations-Regel und ihr Zahn landen zusammen oder gar nicht;
es gibt keinen zweiten Slice, der mitlanden müsste. (2) **Gemeinsames Closure-Kriterium?** Nein —
jedes denkbare wäre die Abschrift der DoD. (3) **Reaktiv oder gewollt?** **Reaktiv:** Auslöser
ist eine Messung an vorhandenen Dokumenten, nicht der Wunsch nach einer Fähigkeit. Damit
**nicht** in der Roadmap geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2) — der Zustand ist das Verzeichnis.

**Bezug:** [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) (die Doc-Gate-Schärfung, die `matrix` überhaupt aktiviert hat, und
die Linie „Gate-*Anheben* → Steering-Loop"),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (ADRs sind nach Accepted immutabel — die Eigenschaft,
aus der der Schaden folgt **und** die ihn begrenzt), §3.5 (Gates nicht ohne ADR lockern — die
Grenze, an der die Bestands-Behandlung gemessen wird), §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
— **als Analogie benannt, nicht als Bezug beansprucht**: die Adaption regelt *emittierte*
Prüfbereiche, hier gilt ihr Fehlerbild („laut falsch schlägt leise falsch") für die Frage, ob eine
**neue** ADR standardmäßig innerhalb oder außerhalb der Regel liegt.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-31.

---

## 1. Ziel

**Der Doc-Gate soll rot werden, wenn eine ADR einen Slice oder eine Welle nennt.**

Eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Slices und Wellen
tragen ihren Zustand als Verzeichnis-Position und wandern per `git mv`; sie werden neu geschnitten
und umnummeriert. Ein Verweis vom Unveränderlichen auf das Wandernde veraltet deshalb nicht
gelegentlich, sondern **zwangsläufig** — und weil die ADR-Seite nicht korrigierbar ist, kostet jede
Instanz einen Umdeutungs-Anker in
[`harness/conventions.md`](../../../../harness/conventions.md) statt einer Korrektur.

**Die Regel ist im Repo längst geschrieben — sie steht im Kommentar über dem `matrix`-Block
selbst** (`.d-check.yml`: „Provenance nur in den Historie-/Geschichte-Tabellen (ausgenommen)").
Durchgesetzt wird sie nur für die Spec-Straten; für ADRs gilt sie im
inferential-feedforward-Quadranten. Dieser Slice gibt ihr ihren Feedback-Quadranten.

**Ist-Messung.** Die Regel färbt beim Anschalten **sieben** ADRs rot, **27 Befunde** — je Achse
getrennt gezählt, weil `slice-NNN` und `welle-NN` zwei Achsen sind und nicht eine Summe:

| ADR | Status | Befunde slice | Befunde welle |
|---|---|---|---|
| 0002 | Superseded | 5 | – |
| 0003 | Accepted | 2 | – |
| 0006 | Accepted | – | 1 |
| 0007 | Accepted | 7 | 1 |
| 0009 | Accepted | 2 | 1 |
| 0010 | Accepted | 1 | – |
| 0011 | Accepted | 4 | 3 |

**Sechs davon sind Accepted.** Die Roh-Zählung über `grep` ergibt **34** Nennungen
(`grep -ohE 'slice-[0-9]{3}' docs/plan/adr/[0-9]*.md | wc -l` → 25;
`grep -ohiE 'welle-[0-9]{2}' docs/plan/adr/[0-9]*.md | wc -l` → 9). Die Differenz zu 27 hat
**zwei** Ursachen, nicht eine: **sechs** Nennungen liegen unter `Historie`/`Geschichte`, das
`exclude-sections` schon heute ausnimmt — und **eine** ist eine Zeilen-Dublette, bei der Linktext
und Linkziel dieselbe Kennung tragen und der Gate einen Befund daraus macht. `grep` ist hier also
**weiter** als der Gate, und zwar genau um den Bereich, in dem Provenance legitim wohnt.

## 2. Definition of Done

- [ ] **(1) Die Regel sieht Kennungen, nicht nur Links — und der Bestand wird durch eine
  Klassen-Vorschaltung geführt, nicht durch eine Ausnahme.** `.d-check.yml` bekommt die Klasse
  `welle`, beide Ziel-Klassen im **Token-Modus** (`token:`) und die Regeln
  `{from: adr, to: slice}` · `{from: adr, to: welle}` · `{from: spec-straten, to: welle}`, alle
  `allow: false`. Der Bestand wird über eine **vorgeschaltete Klasse** der sieben betroffenen
  ADRs geführt (Klassen-Zuordnung ist **first-match**, gemessen), **nicht** über
  `matrix.exempt-paths`. Der Unterschied ist gemessen: `exempt-paths` nimmt
  die Datei aus **allen** Matrix-Regeln und löscht damit den heute aktiven
  `matrix-inactive`-Wächter über **52** ADR→ADR-Links; die Vorschaltung lässt ihn stehen. Damit
  **schrumpft nichts** → reine Anhebung, Steering-Loop nach
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), kein ADR nach [`AGENTS.md`](../../../../AGENTS.md) §3.5. Die offene
  `adr`-Klasse bleibt darunter stehen, damit eine **neue** ADR ohne Zutun gebunden ist
  (fail-closed; eine Nummern-Schwelle wäre weiter als die Frage und ließe die heute noch
  änderbare [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) frei).
  `make docs-check` grün.
- [ ] **(2) Der Zahn ist dauerhaft, und er kostet den Mutations-Sensor eine Zeile.** Heute kann
  **kein** Fall in `test/mutations/` einen `docs-check`-Wächter binden: `failure_form` in
  `harness/tools/mutate.sh` kennt nur `test`/`test-go`/`test-bats`/`smoke`/`ci-lint` und meldet
  jedes andere `# verify:` als Befund. Der Modus `docs-check` kommt hinzu (Fehlschlag-Muster:
  die Befund-Art selbst), dann trägt ein neuer Fall eine Slice-Kennung in eine **lebende** ADR
  und muss `make docs-check` rot färben. **Beide Richtungen sind zu zeigen**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6): mit Regel rot — und ohne Regel grün, **obwohl**
  die Verletzung im Baum liegt. Die zweite Richtung ist der heutige Zustand und damit schon
  belegt; sie gehört trotzdem in den Beleg, sonst behauptet der Fall mehr als er zeigt.
- [ ] **(3) Was die Regel nicht fängt, steht dort, wo die Regel steht.** Ein Eintrag in
  [`harness/conventions.md`](../../../../harness/conventions.md) hält fest: die Regel greift auf
  **Kennungen** (Token und Link); die Bezugnahme in **Prosa ohne Kennung** — „der Slice, der die
  Bilanz baut", „der Auswertungs-Slice" — bleibt unsichtbar, ebenso der Verweis auf einen
  **nummerierten DoD-Punkt**, dessen Gegenstand sich ohne Nummernwechsel ändert. Dazu die
  Bestands-Liste als **benannte** Liste mit Auflösungs-Trigger, und der Grund, warum sie nur
  schrumpfen kann.
- [ ] `make gates` grün; `make mutate` grün über die CI (`.github/workflows/ci.yml`, frischer
  Runner).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` | update | Klasse `welle`; `token:` auf beiden Ziel-Klassen; vorgeschaltete Klasse der sieben Bestands-ADRs; drei neue Regeln |
| `docs/plan/planning/done/welle-01-offline-kern.md` | update | ein Nebenbefund, s. u. — nach dem im Repo etablierten Muster, nicht mit einer neuen Config-Zeile |
| `harness/tools/mutate.sh` | update | `failure_form` bekommt den Modus `docs-check`; ohne ihn ist jeder Doc-Gate-Wächter bauartbedingt unbewacht |
| `test/mutations/` | neu | der Zahn aus DoD (2) |
| `test/mutate-driver.bats` | update | der neue `failure_form`-Zweig ist selbst eine Zusage und braucht seinen Fall |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | der Eintrag aus DoD (3) |
| [`harness/README.md`](../../../../harness/README.md) | update | die `docs-check`-Zeile nennt heute „links/anchors/ids/codepaths" und lässt `matrix` weg — der Vertrag wächst hier, also wächst die Zeile mit |

**Nebenbefund, der zum Schnitt gehört:** die neue `welle`-Klasse macht
Welle-Pläne zu Matrix-**Quellen**, und damit greift die schon aktive `status`-Regel auch dort.
Genau ein Dokument fällt darunter — `done/welle-01-offline-kern.md` verlinkt in seiner
Trigger-Zeile eine ADR, die inzwischen superseded ist. Die Zeile war wahr, als sie geschrieben
wurde; sie umzuschreiben wäre eine Fälschung des Trigger-Belegs. Das Repo hat für genau diesen
Fall ein Muster (ein `done/`-Slice trägt es in seiner Bezug-Zeile bereits): der Link wird zur
Kennung in Inline-Code plus begründetem Zeilen-Marker. **Kein** neuer Config-Eintrag — gemessen
ist auch, dass der Marker für die Befund-Art `matrix-inactive` **nicht** greift, für die
`ids`-Linkpflicht dagegen schon; deshalb ist der Weg über die Link-Form der einzige, der ohne
Carveout auskommt.

**Was die Umsetzung zuerst nachmisst** (Modul 9 §4): die sieben ADRs und die 27 Befunde neu
zählen, bevor die Bestands-Liste geschrieben wird — die Zahlen oben altern mit jedem Commit an
einer ADR. Eine eingefrorene Liste, die einen achten Fall übersieht, wäre still fail-open.

## 4. Trigger

**`open` → `next`:** keine Abhängigkeit — die Änderung berührt `.d-check.yml`,
`harness/tools/mutate.sh` und `test/mutations/`. Die Konfliktfläche liegt bei
[slice-060](../done/slice-060-rollen-achse.md), das laufend neue Mutations-Fälle anlegt;
Grund für die Reihung ist damit WIP-Limit und Konfliktfläche, nicht Reihenfolge-Zwang.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls die Nachmessung zeigt, dass die Bestands-Behandlung und der
  `docs-check`-Modus des Mutations-Treibers zwei Arbeiten sind — dann trennt ein Re-Schnitt die
  Regel vom Sensor-Ausbau.
- `in-progress` → `open`: falls sich zeigt, dass die Klassen-Vorschaltung eine andere aktive
  Prüfung verliert als die eine, die hier gemessen wurde. Dann ist erst zu klären, was `matrix`
  je Klasse tatsächlich noch prüft, bevor die Regel scharf gestellt wird.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün
und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Bestands-Liste ist eine kuratierte Liste, und kuratierte Listen altern.** Sie kann
  allerdings nur **schrumpfen**: ihre Einträge sind unveränderliche Dateien, die keine neue
  Kennung mehr aufnehmen. Wächst sie je, hat die Regel geleckt — das ist der Auflösungs-Trigger
  ihres Eintrags, kein Wartungs-Versprechen.
- **`token:` sieht die Kennung überall, auch in Inline-Code.** Über den Spec-Straten ist das
  gemessen unschädlich (ihre Slice-Nennungen liegen sämtlich unter `## 7. Historie`, das
  ausgenommen ist). Über ADRs ist es gewollt. Über einer künftigen dritten Quell-Klasse ist es
  ungeprüft — wer eine anlegt, misst neu.
- **Die Regel verspricht weniger, als der Anlass braucht.** Sie fängt Kennungen. Die Bezugnahme
  in Prosa ohne Kennung fängt sie nicht, und eine ADR, die konsequent umschreibt, ist unter dieser
  Regel grün und trotzdem an ein wanderndes Artefakt gebunden. DoD (3) schreibt das hin; **dieser
  Slice schließt es nicht**. Ein Sensor dafür müsste Bedeutung lesen, nicht Zeichen.
- **Ein neuer `failure_form`-Modus ist ein neuer Zweig im Treiber.** Er trifft jeden künftigen
  Fall, nicht nur diesen. Sein eigener Wächter gehört deshalb in denselben Slice und nicht in
  einen Folge-Slice.
- **Nicht in diesem Slice:** die Frage, ob ein Mutations-Fall die *genannte Zusicherung* bindet
  ([slice-069](slice-069-zahn-bindet-zusicherung.md)) und der Prüfbereich von `comment-claims`
  ([slice-070](slice-070-comment-claims-pruefbereich.md)). Beide gehören derselben Familie an —
  Zusagen, die heute kein Sensor prüft —, hängen aber weder von diesem Slice ab noch er von
  ihnen. Ebenfalls **nicht** hier: die umgekehrte Richtung (ein Slice verweist auf eine ADR) —
  die ist erlaubt und soll es bleiben.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.d-check.yml`,
`harness/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration
von [`harness/conventions.md`](../../../../harness/conventions.md).

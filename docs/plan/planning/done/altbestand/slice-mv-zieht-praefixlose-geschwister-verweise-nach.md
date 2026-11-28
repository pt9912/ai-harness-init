# Slice slice-mv-zieht-praefixlose-geschwister-verweise-nach: `make slice-mv` zieht die präfixlosen Verweise aus den Geschwistern der bewegten Datei nach

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (was der Nachzug
ersetzen darf), [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (die Kanten
`open → done` und `next → done` kommen mit `v6.9.0`).

**Berührte Spec-Stellen:** —

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

**Ziel:** Nach einem Wechsel mit `make slice-mv` löst jeder Verweis auf die bewegte Datei auf,
auch der präfixlose Verweis `](<ziel>)` aus einer unbewegten Geschwister-Datei im
Ausgangsverzeichnis. Er wird zu `](../<TO>/<ziel>)`, im Nachzug-Commit des Werkzeugs. Das ist die
eingehende Hälfte der präfixlosen Form. Die ausgehende Hälfte zieht das Werkzeug schon nach, die
eingehende führt der Skriptkopf als Grenze 3.

**Warum jetzt.** Der Folge-Vorgang, der die 13 Go-Slices gruppiert, nutzt `open → done` und
`next → done` in Serie. Ohne diesen Slice wird jeder solche Verweis auf einen stillgelegten Slice
rot. **Dieser Slice läuft vor der Gruppierung** (§4).

### Der Befund, gemessen

`slice-stilllegungs-kanten-sind-gemessen` hat die zwei Kanten am Werkzeug gemessen
([`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze, `### Kanten
open → done und next → done`). Ein Wechsel `open → done` hinterließ 6 × `target-missing` in 5
Geschwister-Dateien unter `open/`; alle anderen Verweise hatte das Werkzeug nachgezogen.

**Messaufbau.** Das Mess-Skript jenes Laufs liegt nicht im Repo; der Aufbau ist dieser:

```sh
git archive HEAD | tar -x -C <kopie>; cd <kopie>; git init -q; git add -A; git commit -qm basis
make slice-mv SLICE=<slice-in-open-mit-geschwister-verweisen> TO=done
make docs-check      # die target-missing aus Geschwistern unter open/ sind der Befund
```

Die Kopie läuft ohne `core.hooksPath` (die Werkzeug-Commits tragen keine Kennung,
[`harness/README.md`](../../../../harness/README.md) §Traceability).

**Umfang:** Das Zählkommando aus der Sensor-Datei, wörtlich übernommen:

```sh
P=docs/plan/planning; for d in open next; do n=0; for f in "$P/$d"/*.md; do
  for t in $(grep -ohE '\]\(slice-[0-9a-z][^)/#]*' "$f" | cut -c3-); do
    [ -f "$P/$d/$t" ] && n=$((n+1)); done; done; echo "$d: $n"; done
```

Am Stand `b97bc8e1` gibt es `open: 56` und `next: 8` aus; das ist kein Erwartungswert. Jeder
dieser Verweise bricht, sobald sein Ziel das Verzeichnis verlässt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Bestand der gezählten Verweise wird nicht umgeschrieben.** *Bestand bleibt bewusst
  stehen:* Heute lösen alle auf. Sie werden erst falsch, wenn ihr Ziel wandert, und dann zieht
  das Werkzeug sie nach.
- **Kein Wächter, der die zwei Kanten mit `git` in der bats-Stufe oder als Fall in
  `make full-smoke` hält.** *Anderer Vorgang am Werkzeug*, so benannt in
  `slice-stilllegungs-kanten-sind-gemessen` §3. Dieser Slice bewacht die Ersetzungs-Funktion
  ohne Repository, wie die vorhandenen Fälle es tun.
- **Die Form der Stilllegung prüft das Werkzeug weiterhin nicht** (leere Liefer-Punkte, Zeile
  `Gegenstand:`). *Anderer Vorgang:* Die Anforderung geht an das d-check-Repo.
- **Keine Gruppierung der Go-Slices.** *Anderer Vorgang*, er folgt diesem Slice.
- **Kein Eingriff in `make archive-welle`.** *Schicht-Abgrenzung:* Sein Verweis-Nachzug ist ein
  eigener Träger ([`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)).

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

Drei Liefer-Punkte auf zwei Ebenen: Dogfood-Werkzeug und emittierte Fassung.

- [x] **1 — `harness/tools/slice-mv.sh` zieht die präfixlosen Geschwister-Verweise nach.** Im
      Ausgangsverzeichnis wird in jeder unbewegten Datei `](<ziel>)` zu `](../<TO>/<ziel>)`, und
      zwar im Nachzug-Commit. Die Zeile der Werkzeug-Ausgabe zählt diese Verweise mit.
      - Der Messaufbau aus §1 läuft für **beide** Kanten, `open → done` und `next → done`. Je
        Kante endet der Wechsel mit Exit 0, der Move-Commit ist ein reiner Rename, und
        `make docs-check` meldet keinen `target-missing` mehr aus einer Geschwister-Datei. Die
        Zahlen stehen mit Kommando im Umsetzungs-Commit. Die Tabelle der Kanten in
        [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) ist damit für das
        geänderte Werkzeug neu gemessen, bevor die Gruppierung die Kanten nimmt. Bis
        `slice-mv-kanten-nach-done-sind-bewacht` schließt, hält kein Wächter sie.
      - Grenze 3 im Skriptkopf ist so gefasst, wie das Werkzeug jetzt ist.

      **Beleg:** Die Zahlen je Kante stehen mit Kommando in `da1f3419`. Die Verifikation vom
      2026-09-17 hat beide Kanten an Wegwerf-Kopien neu gemessen: je Kante Exit 0, ein
      Move-Commit mit `0 0` und kein `target-missing` aus einer Geschwister-Datei. Die Gegenprobe
      am alten Blob zeigt die Befunde mit der behaupteten Ursache (§2 dort). Die Tabelle in
      [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Kanten nennt den
      gemessenen Blob `7e53bd7` (`7104be2c`), und
      `git rev-parse --short=7 HEAD:harness/tools/slice-mv.sh` gibt am Stand dieser Closure
      denselben Blob aus. Grenze 3 ist gegen den Code gehalten (Verifikation §4).
- [x] **2 — Die emittierte Fassung `internal/emit/templates/enforce/slice-mv.sh` ist
      gleichgezogen, und der Rumpf-Vergleich deckt die Änderung.** Ist die Ersetzung eine neue
      Funktion, nimmt die Liste `KERN` in `test/slice-mv.bats` sie auf. Ist sie eine Änderung
      einer vorhandenen Funktion, vergleicht der Test sie schon mit. `make test` ist grün.
      **Beleg:** `KERN` nennt `rewrite_incoming_bare_in_file` (`grep -n '^KERN=' test/slice-mv.bats`),
      und Mutation 346 färbt den Kopplungs-Fall rot (Verifikation §3). Außerhalb von Kommentaren
      sind die zwei Fassungen im Diff wortgleich, und `make test` ist als Teil von `make gates`
      grün (Verifikation §1).
- [x] **3 — Die Zusage hat Zähne** ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      - Ein Fall in `test/slice-mv.bats` ruft die Ersetzung ohne Repository auf und prüft den
        vollständigen Ist-Bestand der Datei: den ersetzten Link, dazu unverändert einen
        Code-Span und einen Tree-Operanden (`<sha>:<pfad>`) mit demselben Namen.
      - Ein Fall unter `test/mutations/` nimmt die Ersetzung zurück, und dieser Fall wird rot.
        Das ist mit `make mutate` gesehen, die Meldung ist gelesen.

      **Beleg:** Der Fall *„eingehend praefixlos: …"* prüft den vollständigen Ist-Bestand der
      Probe (Verifikation §1). Der Fall
      `test/mutations/363-slice-mv-eingehend-verliert-geschwister-ersetzung.sh` ist mit
      `make mutate` rot gesehen, der Lauf endet mit `mutate: 349 ok, 0 Befund(e)` und EXIT 0
      (Verifikation §3). Die Meldung mit den unersetzten Links haben Implementer und Review
      gelesen.
- [x] `make gates` grün. **Beleg:** EXIT 0 über `f6ae7ffd` (Verifikation §1). Den Stand ab
      `7104be2c` und die Closure-Commits deckt der Lauf, der nach ihnen fährt.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). **Beleg:** zwei
      Reports vom 2026-09-17 unter `docs/reviews/`. Runde 2 lautet „bereit".
- [x] Doku-Update: [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze
      (`### Kanten …`) trägt die neue Messung. Der Satz „nachgezogen werden sie von Hand" und die
      Adresse der Lücke entfallen. **Beleg:** Die Tabelle §Kanten trägt die neue Messung.
      `grep -c 'von Hand' harness/sensors/slice-mv.md` → 0 und
      `grep -c 'Adresse der Lücke' harness/sensors/slice-mv.md` → 0.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit; §7 prüft sie zusätzlich hier.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/slice-mv.sh` | update | Ersetzung im Ausgangsverzeichnis, Ausgabe-Zeile, Grenze 3 (DoD 1) |
| `internal/emit/templates/enforce/slice-mv.sh` | update | über den Rumpf-Vergleich gekoppelte Fassung (DoD 2) |
| `test/slice-mv.bats` | update | `KERN`-Liste, Fall für die Ersetzung ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); DoD 3) |
| `test/mutations/363-slice-mv-eingehend-verliert-geschwister-ersetzung.sh` | neu | Mutation gegen die Ersetzung (DoD 3) |
| [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) | update | neue Messung, Grenze gezogen |
| `test/mutations/346-lifecycle-ersetzung-nur-in-einer-fassung.sh` | update | `expect` folgt dem Kopplungs-Fall, dessen Name die Liste `KERN` statt einer Zahl nennt (DoD 2) |
| `.claude/commands/implement-slice.md` | update | nennt die präfixlose Eingehend-Form so, wie das Werkzeug sie erkennt |
| `internal/emit/templates/commands/implement-slice.md` | update | dasselbe in der emittierten Anleitung (DoD 2) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | der Satz über Geschwister-Befunde nach einer Stilllegungs-Kante |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei. Keine Abhängigkeit hält den Start.
**Die Gruppierung der Go-Slices startet erst, wenn dieser Slice in `done/` liegt.**

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Ersetzung lässt sich nicht als
  eine Funktion beider Fassungen schreiben, und die Kopplung verlangt eine zweite Vergleichsform.
  Dann wird die emittierte Fassung eigens geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Eine präfixlose Form lässt sich nicht von
  einem gleichnamigen Code-Span oder Tree-Operanden trennen, ohne einen Markdown-Parser
  einzuführen. Die Werkzeug-Entscheidung liegt dann beim Architect.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Der Messaufbau aus §1 meldet nach `open → done` und nach `next → done` keinen `target-missing` aus einer
   Geschwister-Datei.
2. Der Mutations-Fall aus DoD 3 ist rot gesehen, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Die Ersetzung trifft einen gleichnamigen Tree-Operanden oder Code-Span.** Das Register
   führt die Klasse bei 2× (`verweis-nachzug-bricht-tree-operand`). *Absehbar:* entfallen, wenn
   nur die Link-Form ersetzt wird und DoD 3 die zwei Gegenformen prüft; sonst eingetreten, und
   der dritte Beleg macht den Eintrag zur Lücke. — **Ausgang: entfallen.** Ersetzt wird nur die
   Link-Form `](<datei>)` und `](<datei>#…)`. Der Fall *„eingehend praefixlos: …"* in
   `test/slice-mv.bats` hält einen Code-Span mit dem bloßen Namen und einen Tree-Operanden mit
   demselben Namen unverändert (Verifikation §1). Steht die Link-Syntax selbst in einem
   Code-Span, wird sie mitersetzt. Das ist keine gleichnamige Gegenform, sondern die Link-Form
   als Zitat, und Grenze 3 im Skriptkopf nennt es. Der Eintrag
   `verweis-nachzug-bricht-tree-operand` bekommt keinen Beleg.
2. **Der Rumpf-Vergleich sieht die neue Funktion nicht.** Er vergleicht nur die Funktionen in
   `KERN`. *Absehbar:* entfallen durch DoD 2; sonst eingetreten, mit Beleg in
   `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`. — **Ausgang: entfallen.** `KERN`
   nennt die neue Funktion, und Mutation 346 färbt den Kopplungs-Fall rot (DoD 2). Der Eintrag
   `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` bekommt keinen Beleg.
3. **Die Gruppierung läuft vorher.** Dann bleibt jeder präfixlose Verweis auf einen
   stillgelegten Slice rot und wird von Hand nachgezogen. *Absehbar:* entfallen durch den
   Start-Satz in §4. — **Ausgang: entfallen.** Seit dem Claim hat kein Slice `open/` oder
   `next/` in Richtung `done/` verlassen
   (`git log --format=%s 12c1ed0e..7104be2c | grep -cE '^slice-mv: .* (open|next)/ -> done/'`
   → 0). Mit dieser Closure liegt der Slice in `done/`. Damit ist die Bedingung aus §4 erfüllt,
   bevor die Gruppierung beginnt.
4. **Ein Geschwister im Ausgangsverzeichnis ist eingefroren.** Unter `open/`, `next/` und
   `in-progress/` liegt kein eingefrorenes Artefakt; `done/` ist kein Ausgangsverzeichnis einer
   Lifecycle-Kante. *Absehbar:* entfallen, wenn der Nachzug auf diese drei Verzeichnisse
   beschränkt ist ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)). —
   **Ausgang: weiter offen.** Die Bedingung für *entfallen* ist nicht erfüllt: `make slice-mv`
   nimmt `done` als Ausgangsverzeichnis an, und die präfixlose Ersetzung schreibt dann in flache
   `done/`-Geschwister (Review F-2, dort am Wechsel `done → open` gemessen). Im Repo ist das
   Risiko nicht eingetreten, denn kein Werkzeug-Commit hat `done/` verlassen
   (`git log --format=%s | grep -c '^slice-mv: .* done/ -> '` → 0). Auch die Begründung aus der
   Umsetzung trägt *entfallen* nicht.
   [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 deckt
   das Schreiben in `done/` nur für einen vom Prozess vorgeschriebenen Ortswechsel, und aus
   `done/` führt keine Kante (Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md`
   §Lifecycle als State Machine). Dass die Präfix-Ersetzung dort schon vorher schrieb, ist
   Bestand, keine Entscheidung. Ob das Werkzeug diesen Ausgang sperrt oder ob Festlegung 1 auch
   diese Kante deckt, entscheidet der Architect (§7, Übergaben). Eine Beschränkung im Code wäre
   ein Folge-Slice und setzt dieses Verdikt voraus. Grenze 3 im Skriptkopf zählt die anderen
   Schreibweisen über die Ausgangsverzeichnisse der Lifecycle-Kanten. Über die Eingaben, die das
   Werkzeug annimmt, sagt sie nichts, und ihr Wortlaut bleibt (Verifikation §5). Der Beleg steht
   in
   [`BEO-ALL/werkzeug-nimmt-einen-ortswechsel-an-den-der-lifecycle-nicht-fuehrt`](../observations/BEO-ALL/werkzeug-nimmt-einen-ortswechsel-an-den-der-lifecycle-nicht-fuehrt/observation.md).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), über
dem Umsetzungs-Stand `7104be2c`. Maßstab sind Baseline-Regelwerk `v6.9.0` ·
`modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln und `modul-06-roadmap.md` §Wann
Arbeit eine Welle braucht, dort die Tabelle der Träger im Repo ohne Wellen.

- **Was hat funktioniert:**
  - Das Rot am realen Vorzustand hat die behauptete Ursache. Am alten Blob `d1bda5b` stehen je
    Kante genau so viele `target-missing` in Geschwister-Dateien, wie das Zählkommando
    präfixlose Links nennt (6, dann 9). Am neuen Werkzeug ist es keiner (Verifikation §2).
  - Die Kopplung der zwei Fassungen griff sofort: Die neue Funktion steht in `KERN`, und
    Mutation 346 färbt den Kopplungs-Fall rot.
  - Den HIGH-Befund F-1 fand der Review vor der Closure, und Runde 2 bestätigte die Behebung
    (`7348e55c`). Den Wortlaut von DoD 3 („mit `make mutate` gesehen") hat die Verifikation mit
    einem eigenen Lauf eingelöst.
- **Was ging anders als geplant:**
  - **Die Bedingung aus §6 Risiko 4 hat kein Lauf gebaut** (Review F-2). Der Plan knüpfte
    *entfallen* an eine Beschränkung im Code, nannte sie aber in keinem Liefer-Punkt. Der
    Implementer hat die Abweichung offen übergeben und den Plan nicht umgeschrieben
    (Verifikation §5). Den Ausgang setzt diese Closure (§6).
  - **Die Adresse für F-4 trug nur einen Teil des Befunds.**
    `slice-mv-kanten-nach-done-sind-bewacht` deckte die Auswahl in `main()` über die Auflösung
    ab, die Einfach-Zählung aber nicht. Die Closure hat dessen DoD geschärft (`7d3f66e5`).
  - **Zwei Aussagen in Sensor-Dateien gingen weiter als ihr Beleg** (Verifikation V-1 und V-2).
    Eine Blob-Angabe blieb nach einer Änderung stehen, die nur Kommentare betraf. Ein Satz über
    Geschwister-Befunde traf am Bestand zu, folgt aber nicht aus dem Code. Beides ist in
    `7104be2c` behoben.
  - **§3 wuchs im ausführenden Kontext um vier Zeilen.** Das deckt
    `.claude/commands/implement-slice.md`. DoD, §1, §5 und §6 blieben unverändert
    (Verifikation §5).
- **Steering-Loop-Eintrag:** **Neuer Sensor.** Der präfixlose Eingehend-Nachzug von
  `make slice-mv` hat einen Zahn: den Fall *„eingehend praefixlos: …"* in `test/slice-mv.bats`,
  den Mutations-Fall `363-slice-mv-eingehend-verliert-geschwister-ersetzung` und die Kopplung
  über `KERN`. Er schließt die Lücke, die
  [`verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
  als Grenze ihrer Verkörperung `seit slice-144` nannte. Die `state.md` dort nennt jetzt die
  verbleibende Grenze. **Kein `liegt in`-Feld:** Die Verkörperung ist die vorhandene, und eine
  neue Regel verkörpert dieser Slice nicht. Den Lese-Schritt trägt der Eintrag unten, der zum
  ersten Mal 3× erreicht.
- **Beobachtungs-Register (`../observations/`):** Der Beleg heißt in jedem Fall
  `evidence/slice-mv-zieht-praefixlose-geschwister-verweise-nach.md`. Den Zähler liefert
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, die Zahl der Belege aus
  diesem Vorgang
  `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-mv-zieht-praefixlose-geschwister-verweise-nach.md | wc -l`
  (→ 5). Keine der Zahlen ist ein Erwartungswert.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md) | F-1 (wiederkehrende Klasse laut Review) | 12 | verkörpert |
  | [`ausgang-nennt-traeger-der-nicht-traegt`](../observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md) | F-4 | 3, zum ersten Mal | geplant |
  | [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | V-1 | 2 | offen |
  | [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | V-2 | 2 | offen |
  | [`werkzeug-nimmt-einen-ortswechsel-an-den-der-lifecycle-nicht-fuehrt`](../observations/BEO-ALL/werkzeug-nimmt-einen-ortswechsel-an-den-der-lifecycle-nicht-fuehrt/observation.md) | F-2; §6 Risiko 4 | 1, neu | offen |

  **Lese-Schritt.** `ausgang-nennt-traeger-der-nicht-traegt` erreicht mit diesem Slice zum
  ersten Mal 3× (`slice-177`, `slice-182` und dieser Slice). Ausgang: **geplant**, Kennung
  `slice-ausgang-auf-einen-folge-slice-prueft-dessen-dod` (`d79d4ec0`, in `open/`). Für die
  Verkörperung braucht es das Verdikt des Architect zu Zielort und schreibender Rolle
  (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b).
  Das trägt jener Slice, nicht diese Closure. `kommentar-nennt-…` stand schon über der Schwelle.
  Der Fall tritt dort innerhalb der benannten Grenze wieder auf, denn
  [`AGENTS.md`](../../../../AGENTS.md) §3.7 sagt selbst *„Ein Wächter existiert nicht"*. Der
  Ausgang bleibt. Einen Beleg bekommt `verweise-brechen-beim-ortswechsel` nicht, denn gebrochene
  Verweise gab es nur an Kopien.

  **Nicht getragen, mit Urteil:**
  - `plan-bedingung-im-ausfuehrenden-kontext-umgedeutet` (F-2): Umgedeutet wurde nichts. Der
    Implementer hat die offene Bedingung als Frage übergeben, und §6 blieb unverändert.
  - `bedingung-ohne-traeger-im-lauf-den-sie-bindet` (F-2): Die Bedingung stand im Plan, also im
    Eingang des gebundenen Laufs. Ihr fehlte ein Liefer-Punkt, nicht der Eingang.
  - `verweis-nachzug-bricht-tree-operand` und
    `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`: §6 Risiko 1 und 2 sind
    entfallen.
  - `neuer-waechter-ohne-mutations-fall`: Der neue Fall hat mit 363 seine Mutation.
  - `slice-plan-umfang-waechst-ueber-umsetzung-hinaus`: §3 wuchs um Dateien, die die Umsetzung
    berührt, nicht um Beweisführung.
  - `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: Claim und Closure ziehen den
    Ruhe-Marker in eigenen Commits nach, der Claim mit `9cdebb28`, die Closure mit dem Commit
    nach ihrem Move.
  - F-3 bekommt keinen Eintrag: Der Befund war ein mehrdeutiger Bezug in einem Satz, und der
    Review nennt keine wiederkehrende Klasse. F-5 bekommt keinen Eintrag: Die Verifikation hat
    ihn mit einem eigenen Lauf geschlossen.
- **Trigger-Audit** (wellenlos, bei der Slice-Closure):
  - **Carveout:** `CO-001` steht auf *Auflösung fällig*, die Adresse ist
    `slice-113-co-001-ist-faellig` in `open/`. `CO-002` steht auf *permanent*. Dieser Slice
    berührt keine ihrer Bedingungen.
  - **Bootstrap-aware Gate:** keines vorhanden
    (`grep -n -i 'bootstrap-aware' Makefile *.mk harness/mk/*.mk` → kein Treffer).
  - **ADR:**
    - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md): Keiner der vier
      Re-Evaluierungs-Trigger feuert. Zu Trigger 1: Dieser Slice bewegt die Baseline nicht. Zu
      Trigger 2: Der gepinnte d-check ist unverändert
      (`git log --format=%h 0ea7e148..7104be2c -- d-check.mk | wc -l` → 0); den Trigger prüft
      der Lauf, der den Pin hebt, an dessen neuem Stand. Zu Trigger 3: Die präfixlose Ersetzung
      liest keine ADR und schneidet nicht nach Status, sie sucht nur flach im
      Ausgangsverzeichnis. Zu Trigger 4: Keine Aussage ist nachweislich falsch geworden. Auf den
      Kanten des Prozesses trifft die mitersetzte Link-Syntax im Code-Span nur lebende Dateien.
      Auf der Kante aus `done/` träfe sie ein Zeitdokument, und genau diese Kante ist die offene
      Frage aus §6 Risiko 4. Festlegung 2 hält, denn keine Kante berührt den ADR-Baum
      (Verifikation §6).
    - [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md): Keiner ihrer Trigger
      ist berührt, denn dieser Slice führt keinen Sprung aus.
- **Folge-Slices:**
  - `slice-ausgang-auf-einen-folge-slice-prueft-dessen-dod` (`d79d4ec0`) aus dem Lese-Schritt.
  - `slice-mv-kanten-nach-done-sind-bewacht`, vorhanden in `open/`, mit der in `7d3f66e5`
    geschärften DoD: F-4.
  - Für §6 Risiko 4 gibt es keinen Folge-Slice. Eine Beschränkung im Code setzt das Verdikt
    unten voraus.
- **Übergaben:**
  - **An den Architect:** Deckt
    [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 den
    Nachzug auch auf einer Kante aus `done/`, die der Lifecycle nicht führt, oder sperrt
    `make slice-mv` diesen Ausgang? Die Frage trägt der Registereintrag
    `werkzeug-nimmt-einen-ortswechsel-an-den-der-lifecycle-nicht-fuehrt`, den §8 jeder
    Slice-Planung liest.
  - **An den Lauf, der den d-check-Pin hebt:** Trigger 2 von
    [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) am neuen Stand
    prüfen.
- **Risiken aus §6:** Jedes hat genau einen Ausgang: 1, 2 und 3 sind entfallen, 4 bleibt weiter
  offen.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.
- **Drei Paarungen**, die die nächste Welle-Closure ebenfalls prüft (§2):
  - (a) Kein Gegenstand, denn diese Notiz führt kein `liegt in`-Feld.
  - (b) Getragen: Beide genannten Folge-Slices liegen als Datei in `open/`.
  - (c) Getragen: Jede genannte Beobachtung existiert als Verzeichnis, und jedes trägt
    mindestens einen Beleg.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Der Gegenstand liegt in `harness/tools/` (`TOOLS`), dem
Werkzeug. Die emittierte Fassung, der Test und die Sensor-Datei liegen außerhalb davon, also in
`*`. `.codex/` (`CODEX`) ist nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist deshalb nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md) | 6 | verkörpert in `harness/tools/slice-mv.sh`, `seit slice-144` | der Gegenstand selbst: Die Verkörperung lässt die eingehende präfixlose Form offen (Grenze 3), dieser Slice schließt sie |
| `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | 20 | geplant, `slice-ortswechsel-zieht-sein-zustandsfeld-nach` | nicht berührt: Der Slice zieht Pfade nach, keine Zustandssätze |
| `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` | 14 | verkörpert | §6, Risiko 4 |
| `neuer-waechter-ohne-mutations-fall` | 8 | verkörpert | DoD 3 |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |
| `verweis-nachzug-bricht-tree-operand` | 2 | offen | §6, Risiko 1 |
| `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` | 2 | offen | §6, Risiko 2 |

**Zwei Einträge bei 2× träfe der Slice nur auf einem Weg, den DoD 2 und DoD 3 ausschließen.**
Tritt einer doch auf, ist er bei 3× eine Lücke mit eigenem Folge-Slice. Die Einträge ab 3× tragen
`verkörpert` oder `geplant`, und jede genannte Kennung liegt als Datei in `open/`.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

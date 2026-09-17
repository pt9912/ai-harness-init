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

**Verantwortlich:** —

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

- [ ] **1 — `harness/tools/slice-mv.sh` zieht die präfixlosen Geschwister-Verweise nach.** Im
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
- [ ] **2 — Die emittierte Fassung `internal/emit/templates/enforce/slice-mv.sh` ist
      gleichgezogen, und der Rumpf-Vergleich deckt die Änderung.** Ist die Ersetzung eine neue
      Funktion, nimmt die Liste `KERN` in `test/slice-mv.bats` sie auf. Ist sie eine Änderung
      einer vorhandenen Funktion, vergleicht der Test sie schon mit. `make test` ist grün.
- [ ] **3 — Die Zusage hat Zähne** ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      - Ein Fall in `test/slice-mv.bats` ruft die Ersetzung ohne Repository auf und prüft den
        vollständigen Ist-Bestand der Datei: den ersetzten Link, dazu unverändert einen
        Code-Span und einen Tree-Operanden (`<sha>:<pfad>`) mit demselben Namen.
      - Ein Fall unter `test/mutations/` nimmt die Ersetzung zurück, und dieser Fall wird rot.
        Das ist mit `make mutate` gesehen, die Meldung ist gelesen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze
      (`### Kanten …`) trägt die neue Messung. Der Satz „nachgezogen werden sie von Hand" und die
      Adresse der Lücke entfallen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
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
| `harness/tools/slice-mv.sh` | update | Ersetzung im Ausgangsverzeichnis, Ausgabe-Zeile, Grenze 3 (DoD 1) |
| `internal/emit/templates/enforce/slice-mv.sh` | update | über den Rumpf-Vergleich gekoppelte Fassung (DoD 2) |
| `test/slice-mv.bats` | update | `KERN`-Liste, Fall für die Ersetzung ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); DoD 3) |
| `test/mutations/<nnn>-slice-mv-…` | neu | Mutation gegen die Ersetzung (DoD 3) |
| [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) | update | neue Messung, Grenze gezogen |

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
   der dritte Beleg macht den Eintrag zur Lücke. — **Ausgang:** <offen>
2. **Der Rumpf-Vergleich sieht die neue Funktion nicht.** Er vergleicht nur die Funktionen in
   `KERN`. *Absehbar:* entfallen durch DoD 2; sonst eingetreten, mit Beleg in
   `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`. — **Ausgang:** <offen>
3. **Die Gruppierung läuft vorher.** Dann bleibt jeder präfixlose Verweis auf einen
   stillgelegten Slice rot und wird von Hand nachgezogen. *Absehbar:* entfallen durch den
   Start-Satz in §4. — **Ausgang:** <offen>
4. **Ein Geschwister im Ausgangsverzeichnis ist eingefroren.** Unter `open/`, `next/` und
   `in-progress/` liegt kein eingefrorenes Artefakt; `done/` ist kein Ausgangsverzeichnis einer
   Lifecycle-Kante. *Absehbar:* entfallen, wenn der Nachzug auf diese drei Verzeichnisse
   beschränkt ist ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)). —
   **Ausgang:** <offen>

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

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** offen bis zur Closure.

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

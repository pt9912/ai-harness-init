# Slice slice-131: Eine Präsens-Aussage über die Baseline ist gegen den gepinnten Stand gemessen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — ihr Ziel-Satz ist wörtlich der Gegenstand
dieses Slice: *„die adoptierte Baseline steht auf `v5.12.0`, **und jede Aussage dieses Repos über
sie ist gegen diesen Stand gemessen**"*. Ihre Closure-Bedingung ist von dieser DoD verschieden.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist
die Reproduzierbarkeits-Klammer; eine Messung, deren Operand gewechselt hat, reproduziert nichts),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 regelt den Beleg im
**unveränderlich werdenden** Artefakt; für das lebende sagt sie *„der Bump zieht ihn nach"* — die
Lücke, die dieser Slice füllt),
[`ADR-0023`](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) (Folgepflicht 3: die
Klassen sind eine **Sortier-Aufgabe je Treffer**, keine Liste),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 1 — jede Zahl steht neben dem Kommando, das genau sie ausgibt; genau diese Kopplung ist
hier zerrissen),
[`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** `—`. Der Slice bewegt Plan-Artefakte und keine Spec-Stelle; die
Verweis-**Form** entscheidet eine ADR, nicht ein Spec-Stratum.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Keine lebende Plandatei behauptet mehr etwas über die vendored Baseline, das gegen den gepinnten
Stand nicht mehr stimmt — und die Sortier-Regel, die das entscheidet, steht danach an einem Ort,
statt in jedem Lauf neu erfunden zu werden.**

### Die Klasse, die keine der bisherigen ist: die Adresse hält, die Folgerung bricht

[slice-081](../in-progress/slice-081-baum-tauschen-pin-ziehen.md) §1 nennt seine Klassen fest —
nachgezogen · byte-gleich · Adresse entfällt · Operand bleibt stehen. **Alle fragen nach der
Auflösbarkeit eines Pfades.** Der Tausch hat eine Frage gestellt, die keine von ihnen beantwortet:
**was der Satz neben dem Pfad behauptet.** Die Klasse trägt hier deshalb keine Ordnungszahl,
sondern ihre Eigenschaft — dieselbe Regel, die
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) und
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) eine Ebene tiefer ziehen.

Drei Fälle in `slice-114` haben sie sichtbar gemacht, und keiner war mit dem Ziehen der Adresse
erledigt:

| Fall | Adresse | Was neben ihr stand |
|---|---|---|
| Pflichtgliederung des Einstiegs | Datei umbenannt, Anker hält | die Vorlage führt **acht** statt sieben Abschnitte — aus *„genau einer fehlt"* werden **zwei** |
| Form des Konventionsspeichers | Datei umbenannt, Anker hält, Zitat **verbatim** vorhanden | derselbe Abschnitt nennt die Verzeichnis-Form am gepinnten Stand als **Default** |
| Schnitt-Regel für Slices | Datei und Anker halten | das Zitat lautet dort `≤ 3 Liefer-Punkte`, nicht `≤ 3 DoD-Punkte`, und die Regel zählt jetzt selbst ab, was **nicht** zählt |

Der erste und dritte Fall wären von einem mechanischen Tag-Tausch **grün** durchgelassen worden:
Datei und Anker lösen auf, der Satz daneben ist falsch. Das ist genau die Verwandlung, die
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) in ihrer Option C verwirft — *„der
Alias verwandelte einen toten Link in ein falsches Zitat, also einen lauten Fehler in einen
stummen"* —, dort aber nur für das **unveränderlich werdende** Artefakt entschieden. Für das
lebende sagt Festlegung 2 *„der Bump zieht ihn nach"* und setzt damit voraus, was hier nicht gilt:
dass der Pfad ein reiner Navigations-Zeiger ist.

### Der Rest ist gemessen, und er ist zur Hälfte falsch

Außerhalb von `slice-114` stehen **11** Nennungen des abgelösten Tags in **6** lebenden
Plandateien. **Die Menge wandert mit jedem Schnitt und ist kein Erwartungswert**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie wird beim Lauf neu erhoben, nicht hier übernommen:

```
git grep -n '\.harness/baseline/v3\.5\.2/' \
  -- docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress \
     'docs/plan/planning/welle-*.md' | grep -v slice-083
```

`slice-083` steht nicht darin und bleibt es: er nennt den alten Tag als **Tree-Operanden der
Vor-Tausch-Seite** — genau die Adresse, die der Tausch nicht anfassen darf
([welle-10](../welle-10-re-baseline.md) §5).

**Jede der 11 ist ein Kommando mit zitiertem Ergebnis, und jede spricht im Präsens über den Baum,
den dieses Repo ausliefert.** Sechs davon gegen den gepinnten Stand nachgefahren — vier Ergebnisse
bewegen sich:

| Behauptung im Plan | alt | gegen `v5.12.0` |
|---|---|---|
| Dateien mit *freshness* im Regelwerk (`slice-090`, `welle-11`) | 2 | **4** |
| Regelwerk-Dateien mit einem nicht existierenden `make`-Ziel (`slice-091`, `welle-11`) | 5 | 5 |
| Treffer für *replay* in `modul-06-roadmap.md` (`slice-112`) | 5 | **6** |
| `### Ziel-Form`-Überschriften im Regelwerk (`welle-11`) | 7 | **11** |
| Treffer für *rot gesehen*/*gegenbeispiel* im Baum (`welle-11`) | 1 | 1 |
| *dreimaligem gleichem Finding* in `modul-10-review-harness.md` (`slice-101`) | 1 | 1 |

**Vier falsche Zahlen bei grünem Gate**, weil keine von ihnen in einem Markdown-Link steht: die
stille Hälfte, die [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) im Kontext benennt
und ausdrücklich unbewacht lässt.

### Was dieser Slice nicht tut

Er heilt **keine** Zeitdokumente (`docs/reviews/**`, `docs/plan/planning/done/**`) — sie sind die
richtige Aussage über ihren Stand ([welle-10](../welle-10-re-baseline.md) §6) — und er fasst
**keine** Accepted-ADR an ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Er schreibt auch keine
Verweis-Regel: ob die lebende Hälfte von
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) eine eigene Entscheidung braucht, ist
eine Architect-Frage und steht in §4 als Start-Bedingung, nicht als Liefer-Punkt.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Jede Nennung des abgelösten Tags in einer lebenden Plandatei ist sortiert, und die
      Sortierung ist je Treffer belegt.** Die Menge wird beim Lauf mit dem Kommando aus §1 erhoben,
      nicht aus §1 übernommen. Drei Ausgänge, und nur diese drei: **nachgemessen** (Pfad gezogen
      **und** Ergebnis neu gefahren, mit dem Kommando daneben) · **Tree-Operand** (der Satz spricht
      über die Vor-Tausch-Seite; die Adresse bleibt und der Grund steht dabei) · **entfallen** (die
      Aussage hat ihren Gegenstand verloren, mit Begründung, nicht durch Streichen). Danach gibt
      dasselbe Kommando **nur noch** Tree-Operanden aus.
- [ ] **(2) Keine Zahl ist mitgewandert.** Für jede nachgemessene Aussage steht das Ergebnis, das
      ihr Kommando gegen den gepinnten Stand **wirklich** ausgibt — nicht die alte Ziffer unter
      neuem Pfad. Rot färbt das kein Gate: der Nachweis ist, dass im Diff jede geänderte Pfadzeile
      eine geänderte oder ausdrücklich bestätigte Ergebniszeile neben sich hat
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 1). Wo eine bewegte Zahl die **Folgerung** des Absatzes umstößt, wird die Folgerung
      gezogen, nicht die Zahl gerundet.
- [ ] **(3) Die Sortier-Regel steht danach an einem Ort.** Die drei Ausgänge aus (1) sind als Regel
      formuliert — dort, wo die Verweis-Form dieses Repos entschieden wird, und nicht in einem
      Slice-Plan, den kein zweiter Lauf liest. **Welcher Ort das ist, entscheidet dieser Slice
      nicht**: ist die Antwort eine ADR, ist sie Architect-Sache
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und dieser Punkt wird zur Übergabe mit benanntem
      Adressaten. Ein Punkt, der auf „steht im Plan" endet, ist nicht erfüllt.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-/Reconciliation-Register: das Repo führt keines von beiden; das Item entfällt
      mit diesem Grund und wird in §7 notiert, nicht still übergangen.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die
      [welle-10](../welle-10-re-baseline.md)-Closure, nicht dieser Slice — das Repo fährt
      Wellen-Betrieb.

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [slice-090](slice-090-freshness-audit-im-ziel.md), [slice-091](slice-091-vendored-baum-ohne-anspruch.md), [slice-101](slice-101-norm-postens-bekommen-einen-termin.md), [slice-112](slice-112-replay-schritt-hat-keinen-referenten.md) | update | je eine bis zwei Präsens-Aussagen über den vendored Baum; zwei von ihnen bewegen sich nachweislich (§1) |
| [welle-09](../welle-09-modul-15-konformitaet.md), [welle-11](../welle-11-traeger-aussage.md) | update | lebende Welle-Pläne; `welle-11` trägt allein **5** der 11 Nennungen und die größte bewegte Zahl (7 → 11) |
| [slice-083](slice-083-form-vergleich-pflichtfelder.md) | **unverändert** | Tree-Operand der Vor-Tausch-Seite; das Ziehen zerstörte die Messung ([welle-10](../welle-10-re-baseline.md) §5) |
| `docs/plan/adr/**` | **unverändert** | Accepted und damit unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4); die Verweis-Form dort regelt [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 1, und sie heilt den Bestand nicht |
| `docs/reviews/**`, `docs/plan/planning/done/**` | **unverändert** | Zeitdokumente — die richtige Aussage über ihren Stand |
| [`harness/conventions.md`](../../../../harness/conventions.md), [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | **unverändert** | Architect-Eigentum bzw. Rang 2; ihre Nennungen zieht [slice-081](../in-progress/slice-081-baum-tauschen-pin-ziehen.md), nicht dieser Slice |
| Ort der Sortier-Regel (ADR oder Adaptions-Eintrag) | **Übergabe** | wer die Verweis-Form schreibt, steht in [`AGENTS.md`](../../../../AGENTS.md) §3.8 — nicht der Implementer dieses Slice |

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-081](../in-progress/slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/` — vorher steht
der Stand, gegen den nachgemessen wird, nicht fest.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn eine nachgemessene Zahl nicht nur
  ihren Wert, sondern die **Folgerung** eines ganzen Abschnitts umstößt und der Abschnitt dadurch
  neu zu schneiden ist — das ist Plan-Arbeit an einem anderen Slice, nicht Nachzug in diesem. Der
  Fall ist real: die Ziel-Form-Zählung in [welle-11](../welle-11-traeger-aussage.md) trägt eine
  Matrix-Zeile.
- `in-progress` → `open` (blockiert — Carveout?): wenn DoD (3) ergibt, dass die Sortier-Regel eine
  **ADR** braucht. Dann wartet dieser Slice auf sie, statt sie im Implementations-Kontext zu
  schreiben ([`AGENTS.md`](../../../../AGENTS.md) §3.8); die Punkte (1) und (2) bleiben davon
  unberührt und können vorher fallen.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **das Erhebungs-Kommando aus §1 gibt nur noch
Tree-Operanden aus**, und **`make gates` ist grün**. Dazu die Closure-Notiz mit
Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang. Der Lerneintrag hat
hier eine benennbare Form: die vierte Verweis-Klasse ist entweder als Regel verkörpert
(DoD 3) oder als **benannte Spec-Lücke** übergeben — beides zählt, „steht im Plan“ nicht.

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nachzug erzeugt genau die Klasse, gegen die er antritt.** Wer 11 Kommandos neu
  fährt, ist versucht, das Ergebnis zu übernehmen, das im Text steht. — **Ausgang:**
  <entfallen: je Treffer ist die Ausgabe im Diff sichtbar | eingetreten: slice-NNN mit
  einem Sensor über Kommando-Ergebnis-Paare>
- **Kein Gate sieht diese Klasse.** `docs-check` prüft Auflösbarkeit, nicht Wahrheit; die
  11 Nennungen tragen keinen Markdown-Link und lagen deshalb bei grünem Gate falsch da. —
  **Ausgang:** <weiter offen: Beobachtung, sobald das Repo ein Register führt |
  eingetreten: slice-NNN, der einen Sensor baut>
- **Die Regel aus DoD (3) hat keinen Eigentümer, solange die ADR-Frage offen ist.**
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) ist Accepted und damit
  unveränderlich; die lebende Hälfte braucht eine eigene Entscheidung oder eine
  ausdrückliche Feststellung, dass keine nötig ist. — **Ausgang:** <eingetreten: Übergabe
  an den Architect, ADR-Nummer nachtragen | entfallen: die Regel passt in einen
  Adaptions-Eintrag, und der ist beantragt>
- **`welle-11` ist ein lebender Welle-Plan mit einer Matrix, die auf einer der bewegten
  Zahlen steht** (7 → 11 `Ziel-Form`-Überschriften). Der Nachzug kann dort mehr treffen
  als eine Zeile. — **Ausgang:** <eingetreten: Rückführung nach §4, eigener Schnitt |
  entfallen: die Matrix-Zeile trägt die neue Zahl unverändert>

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist genau eine Sub-Area — `docs/plan/`
(eigener Zuschnitt, eigene Ziel-Formen, eigene Lifecycle-Mechanik: drei von drei Achsen).
Sie ist nicht zu grob: der Slice fasst innerhalb von ihr nur lebende Plandateien an und
lässt `adr/`, `carveouts/` und die Zeitdokumente ausdrücklich stehen (§3).

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein**
Beobachtungs-Register — eine `observations.md` unter `docs/plan/planning/` existiert nicht. Keine
Treffer, und der Grund ist die fehlende Datei, nicht ein leeres Register; ob sie entsteht,
hängt an [slice-130](slice-130-emitter-entscheidet-jedes-neue-template.md) und einer
Dogfood-Frage daneben.

Alle berührten Sub-Areas GF: `docs/` gehört zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md). Der
Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz oben.

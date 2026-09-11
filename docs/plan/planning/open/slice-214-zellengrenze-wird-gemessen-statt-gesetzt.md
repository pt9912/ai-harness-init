# Slice slice-214: Die Zellengrenze des Review-Reports wird gemessen, nicht gesetzt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD dieses
Slice. Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die Gate-Konfiguration **dieses** Repos.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Grenzwert ohne Bezugsmenge ist kein Gate, sondern eine Behauptung über eine Praxis, die es noch
nicht gibt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Messung läuft gegen
den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, netzlos),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — kein ADR; [`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet
Senkungen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(der Grenzwert, den dieser Slice setzt, steht neben dem Kommando, das ihn liefert — das ist sein
ganzer Zweck),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (die
Spalten, über denen gemessen wird, gehören der Reviewer-Rolle).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist eine
Gate-Konfiguration).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-11.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Zellen der Review-Reports, die in der Tabellen-Form geschrieben sind, werden
**gemessen**, und aus dieser Messung entsteht je Regel ein `cell-max-chars` in
[`.d-check.yml`](../../../../.d-check.yml) — die Grenze steht dann neben dem Kommando, das sie
liefert.

**Warum dieser Slice getrennt von
[slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) steht.** Die Ziel-Form
sagt es selbst; der Kommentar im Findings-Abschnitt der Report-Vorlage lautet:

> „Absichtlich (noch) nicht gate-geprüft: d-check `structure`
> (`table.column[].cell-max-chars`) könnte die Spalten `Befund`/`Klasse`
> zellenlängen-prüfen, **sobald genug reale Reports zeigen, welche Grenze die gelebte Praxis
> trägt** — verfrüht gesetzt, bricht sie am ersten gründlichen Befund."

Die Bezugsmenge, aus der eine solche Grenze zu messen wäre, entsteht erst durch slice-213:

```sh
grep -lE '^\| *ID *\| *Kategorie *\| *Befund *\|' docs/reviews/*.md | wc -l   # 0
```

**Kein Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit jedem Report in der neuen Form; tragend ist, dass sie **heute
null** ist. **Das Kommando ist an den Spaltenschnitt gebunden**, den slice-213 DoD (1) festlegt; ist
er ein anderer, zählt der Trigger mit dem dann geltenden Kopfzeilen-Muster. Ein Slice, der auf diese
Anhäufung wartete, bliebe in `in-progress/` liegen und besetzte das WIP-Limit — deshalb wartet
stattdessen **dieser Plan** in `open/`, auf einen beobachtbaren Start-Trigger (§4).

**Die Einheit der Messung ist die Zelle, nicht der Report.** Der Trigger zählt Reports, weil das
beobachtbar ist; gemessen wird über die Zellen, die in ihnen stehen. Ein Report trägt mehrere
Findings, also mehrere Zellen — die Bezugsmenge des Grenzwerts ist deshalb deutlich größer als die
Zahl im Trigger.

### Ausdrücklich NICHT in diesem Slice — je Punkt mit Begründung

- **Keine Änderung an der Tabellen-Form und keine an
  [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md).** Die Form liegt mit
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) vor und ist
  Reviewer-Eigentum ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
  dieser Slice misst über ihr und ändert sie nicht. *(Klasse: Schicht-Abgrenzung, andere Rolle.)*
- **Keine Grenze auf einer Spalte, die eine Konstante trägt.** Die Negativbefund-Tabelle führt in
  `Ergebnis` das feste Literal *„geprüft, ohne Befund"* — eine Grenze darüber misst eine Konstante.
  Wenn dort überhaupt eine steht, dann auf `Bereich`; **ob** sie dort hingehört, ist §3a Wahl 2.
  *(Klasse: Bestand bleibt bewusst stehen — die Form komprimiert bei zwei Spalten schon von
  selbst.)*
- **Keine Nachbesserung des Cutoffs.** Der `exempt-paths`-Block aus slice-213 nimmt den Bestand in
  der alten Form aus; dieser Slice erbt ihn unverändert. Wächst der Bestand in der **neuen** Form,
  wächst er in den Prüfbereich hinein — das ist gewollt. *(Klasse: Bestand bleibt bewusst stehen.)*
- **Keine Änderung an der emittierten Doc-Gate-Startkonfiguration.** Ebene Dogfood; die emittierte
  Modul-Menge hängt an
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel).
  *(Klasse: Schicht-Abgrenzung, Dogfood gegen emittiert.)*

## 2. Definition of Done

Zwei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Ein dritter wäre erfunden — die Form steht
bereits, dieser Slice fügt ihr eine Zahl hinzu.

- [ ] **(1) Die Verteilung der Zellenlängen ist gemessen, mit Kommando und benannter Bezugsmenge.**
      Über die Reports in der Tabellen-Form, je geprüfter Spalte: Zahl der Zellen, Maximum und die
      Lage des gewählten Werts darin. Die Messung steht im Umsetzungs-Commit und der gewählte Wert
      **neben dem Kommando, das ihn liefert**
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
      Der Wert liegt **über** dem gemessenen Maximum der gelebten Praxis — eine Grenze, die den
      Bestand schon beim Setzen bricht, ist keine Grenze, sondern ein Rückbau.
- [ ] **(2) `cell-max-chars` steht in [`.d-check.yml`](../../../../.d-check.yml), grüner Start und
      rotes Gegenbeispiel im Repo.** `make docs-check` ist über dem unveränderten Report-Bestand
      grün; eine Zelle über der Grenze färbt ihn rot (`section-cell-oversized`, Spaltenname und
      Zeichenzahl in der Meldung), die Datei bleibt nicht liegen, und der `test/mutations/`-Fall aus
      slice-213 ist um den Grenzwert erweitert oder bekommt einen eigenen.

Standard-Punkte der Vorlage (nicht slice-eigen, zählen nicht zur Zwei):

- [ ] `make gates` grün · `make mutate` ohne Befund.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor — kein Self-Review (Modul 8).
- [ ] Doku-Update: der `structure`-Absatz in [`harness/README.md`](../../../../harness/README.md)
      nennt die Grenze und ihre Bezugsmenge; die Grenzen-Aussage aus slice-213 (*„die Form ist
      bewacht, das Volumen nicht"*) wird **abgelöst**, nicht ergänzt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder *keine Beobachtung
      angefallen* in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — Repo ohne Wellen-Betrieb,
      also hier geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | DoD (2): `cell-max-chars` je geprüfter Spalte |
| `test/mutations/` | update **oder** neu | DoD (2): der Zahn über dem Grenzwert |
| [`harness/README.md`](../../../../harness/README.md) | update | die Grenzen-Aussage aus slice-213 wird abgelöst |
| [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | **unverändert** | Reviewer-Eigentum, und die Form steht bereits (§1 Abgrenzung) |

## 3a. Umsetzungsplan

> Wie in [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) §3a: ein
> Abschnitt außerhalb der Vorlage, angeordnet am 2026-09-11. Die Schwelle dieses Repos für eine Norm
> liegt bei 3×.

### Offene Wahlen

**Wahl 1 — welche Spalte(n) der Findings-Tabelle bekommen eine Grenze?** Die Ziel-Form nennt
`Befund`/`Klasse`.

- **Nur `Befund`.** *Erreicht:* die Spalte, die das Volumen trägt. *Sieht nicht:* eine `Klasse`, die
  statt einer Kurz-Bezeichnung einen Absatz trägt — die Ziel-Form nennt sie ausdrücklich mit.
- **`Befund` und `Klasse`.** *Erreicht:* beide Spalten, die die Ziel-Form benennt, mit je eigenem,
  gemessenem Wert — `Klasse` ist eine *stabile Kurz-Bezeichnung* und trägt naturgemäß eine viel
  engere Grenze. *Sieht nicht:* zwei Werte statt einem, beide zu pflegen.

**Entscheidung: `Befund` und `Klasse`, je mit eigenem Wert.** Die Ziel-Form nennt beide; einen
davon wegzulassen wäre eine Abweichung von ihr ohne Begründung, und der Messaufwand ist derselbe
Lauf.

**Wahl 2 — bekommt die Negativbefund-Tabelle eine Grenze?**

- **Ja, auf `Bereich`.** *Erreicht:* auch dort kann keine Zelle zum Absatz werden. *Sieht nicht:*
  eine Bereichs-Angabe ist ein Pfad oder ein Name — die Kompression kommt bei zwei Spalten schon aus
  der Form, und die Bezugsmenge wäre klein.
- **Nein.** *Erreicht:* keine Grenze ohne Not; `Ergebnis` ist ohnehin eine Konstante. *Sieht nicht:*
  ein `Bereich`, der die Begründung mitträgt, statt den Bereich zu nennen.

**Entscheidung: bleibt offen, bis die Messung aus DoD (1) vorliegt.** Sie ist die einzige
Entscheidungsgrundlage, die dieser Slice anerkennt — genau die Zurückhaltung, die die Ziel-Form für
die Findings-Spalten verlangt, gilt hier auch. Zeigt die Messung eine Spreizung in `Bereich`,
bekommt sie eine Grenze; zeigt sie keine, steht die Begründung im Closure-Eintrag. **Das ist eine
Wahl mit Entscheidungszeitpunkt, kein Vorsatz:** DoD (1) liefert den Befund, und §6 trägt den
Ausgang.

**Wahl 3 — wie wird der Wert aus der Verteilung gewonnen?**

- **Maximum plus Reserve.** *Erreicht:* kein Report der gelebten Praxis bricht am Tag des Setzens.
  *Sieht nicht:* der Ausreißer definiert die Grenze — wenn genau die zu lange Zelle den Anlass gab,
  schreibt sie sich selbst fest.
- **Ein Quantil unterhalb des Maximums.** *Erreicht:* die Grenze trifft die Ausreißer, die gemeint
  sind. *Sieht nicht:* sie färbt beim Setzen rot, und der Bestand ist ein Zeitdokument, das niemand
  nachzieht — jeder Befund wäre unbehebbar.

**Entscheidung: Maximum plus Reserve.** Ein Gate, das beim Einschalten über einem unveränderlichen
Bestand rot ist, erzieht dazu, Rot zu überlesen — dieselbe Begründung, die in slice-213 den Cutoff
trägt. Dass der Wert damit der Praxis folgt statt sie zu formen, ist die Absicht der Ziel-Form
(*„welche Grenze die gelebte Praxis trägt"*) und keine Schwäche.

### Was ausdrücklich keine Wahl ist

- **Dass gemessen und nicht gesetzt wird.** Das ist die Aussage der Ziel-Form und der Grund für die
  Existenz dieses Slice.
- **Kein ADR für diese Anhebung** — [`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen;
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  führt *„Gate-Anheben → Steering-Loop"*.
- **Die Spalten selbst.** Sie stehen im Anweisungssatz; dieser Slice misst über ihnen.

## 4. Trigger

**Start** (`next` → `in-progress`): **20** Review-Reports in der Tabellen-Form liegen in
`docs/reviews/` —

```sh
grep -lE '^\| *ID *\| *Kategorie *\| *Befund *\|' docs/reviews/*.md | wc -l
```

— **und** [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) liegt in
`done/`. Beides ist beobachtbar und **kein Ergebnis dieses Slice**.

**Warum 20, und was die Zahl ist.** Sie ist eine **Trigger-Setzung**, keine Messung — begründet,
nicht gemessen: Die Vorab-Messung, die diesen ganzen Vorgang auslöste, charakterisierte das
Report-Volumen über **die 20 jüngsten Reports**; dieselbe Stichprobengröße macht die neue Messung
mit der alten vergleichbar, über derselben Grundgesamtheit. Kleiner gewählt, dominierte der Stil
weniger Läufe die Verteilung; größer gewählt, feuerte der Trigger noch später ohne besseren Beleg.
**Erweist sich der Schnitt als zu weit**, ist das Nachsetzen eine Änderung an *diesem* Plan in
`open/` und kostet nichts — er blockiert währenddessen kein WIP-Limit.

**Rückführungen — vorab benannt:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung je Spalte eigene
  Cutoff-Durchgänge verlangt und der Slice dadurch über mehr als eine Review-Sitzung wächst —
  Schnitt dann je Spalte einer.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Messung zeigt, dass **keine** Grenze über
  dem Bestand grün startet, ohne den Zweck zu verfehlen (Maximum so hoch, dass die Grenze nichts
  mehr trifft). Dann ist die Antwort nicht ein gesenkter Wert im Stillen, sondern ein Carveout oder
  die begründete Feststellung, dass die Tabellen-Form allein trägt.

## 5. Closure-Trigger

Zwei beobachtbare Kriterien und ein Lerneintrag:

1. `make gates` ist grün mit gesetztem `cell-max-chars` über dem unveränderten Report-Bestand, und
   `make mutate` meldet keinen Befund.
2. Das Rot ist im Repo gesehen (`section-cell-oversized`), Lauf im Umsetzungs-Commit protokolliert,
   und der Mutations-Fall über dem Grenzwert fällt, wenn ihm die Zähne genommen werden.
3. Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

- **Der Trigger feuert nie.** Werden weniger Reviews geschrieben als erwartet, bleibt der Plan in
  `open/` liegen — sichtbar, aber wirkungslos, und die Volumen-Grenze bleibt dauerhaft aus.
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: Register>
- **Die Bezugsmenge ist stilistisch einseitig.** Entstehen die 20 Reports überwiegend in wenigen
  Läufen derselben Art, misst die Verteilung eher deren Stil als die gelebte Praxis — die Klasse,
  die [`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
  benennt. Die Messung aus DoD (1) muss ihre Bezugsmenge deshalb nennen, nicht nur ihre Zahl.
  — **Ausgang:** <…>
- **Maximum plus Reserve schreibt den Ausreißer fest.** Die Entscheidung aus §3a Wahl 3 kauft den
  grünen Start damit, dass der längste bestehende Befund die Grenze mitdefiniert.
  — **Ausgang:** <…>
- **Die Grenze trifft die Zelle, nicht den Report.** Auch mit gesetztem Wert bleibt Prosa um die
  Tabellen herum ungeregelt — die Grenze aus slice-213 §6 bleibt bestehen, sie wird nur kleiner.
  — **Ausgang:** <…>
- **Der Spaltenschnitt kann sich zwischen slice-213 und diesem Slice bewegen.** Er gehört der
  Reviewer-Rolle; ändert sie ihn, zeigt das Trigger-Kommando in §4 auf ein Kopfzeilen-Muster, das
  es nicht mehr gibt, und der Trigger feuert still nicht. — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<…>`. Auslöser: `<BEO-ALL/<slug>>`.
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen.** Berührt werden
[`.d-check.yml`](../../../../.d-check.yml), `test/mutations/` und
[`harness/README.md`](../../../../harness/README.md). Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (`ALL`), `harness/tools/`
(`TOOLS`) und `.codex/` (`CODEX`); keiner der berührten Pfade liegt in den zwei engeren. Die
Berührung ist `*` (`ALL`), Schwelle ≥ 2 von 3 gehalten wie in
[slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) §8 — Achse 1 und 2
tragen, Achse 3 für `*` naturgemäß nicht
([`grundlagen-bootstrap.md`](../../../../.harness/baseline/v6.5.0/regelwerk/grundlagen-bootstrap.md#was-ist-eine-sub-area)).

**Vorgelagert — offene Beobachtungen sichten.** Das Register führt

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l   # 93
```

Verzeichnisse (**kein Erwartungswert**). **Drei** berühren diesen Slice unmittelbar; Zähler-Stände,
gemessen:

```sh
cd docs/plan/planning/observations/BEO-ALL
for d in zahl-ohne-kommando-trifft-ihren-gegenstand-nicht neuer-waechter-ohne-mutations-fall \
         zusage-nennt-sensor-der-form-nicht-sieht; do
  printf '%s\t%s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
#    4  zahl-ohne-kommando-trifft-ihren-gegenstand-nicht
#    4  neuer-waechter-ohne-mutations-fall
#   11  zusage-nennt-sensor-der-form-nicht-sieht
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure.

- **`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` (4×, Stand `offen`).** Über der Schwelle und
  der Kern dieses Slice: Der Grenzwert ist genau eine solche Zahl. Konsequenz: DoD (1) verlangt
  Kommando **und** Bezugsmenge, nicht nur den Wert.
- **`neuer-waechter-ohne-mutations-fall` (4×, Stand `offen`).** Über der Schwelle, ohne Sensor.
  Konsequenz: DoD (2) verlangt den Mutations-Fall über dem Grenzwert als Bedingung.
- **`zusage-nennt-sensor-der-form-nicht-sieht` (11×, Stand `geplant`, Träger
  [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md)).** Weit über der
  Schwelle und adressiert. Konsequenz: Das Doku-Update **löst** die Grenzen-Aussage aus slice-213
  ab, statt sie danebenstehen zu lassen — zwei Aussagen über denselben Sensor driften.

**Erreicht mit diesem Slice eine dieser Beobachtungen 3×**, ist sie keine Notiz mehr, sondern eine
Lücke und braucht einen eigenen Folge-Slice — geprüft wird das bei der Closure, nicht hier.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF; ein Begründungsblock entfällt
damit. Die Sub-Area `*` (`ALL`) ist in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area als
**Greenfield** deklariert.

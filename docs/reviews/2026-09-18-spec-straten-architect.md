# Architect-Verdikt: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18

**Rolle:** Architect (Modul 8). Die Frage ist *„trägt die ADR-Lage diesen Plan?"* — geprüft wird
der **Plan**, bevor Code existiert. Nicht die des Reviewers (Diff gegen Plan, ADR und Hard Rules)
und nicht die des Verifiers (gegen DoD und Spec).

**Eingang:** der Slice-Plan `slice-spec-straten-zeigen-nicht-nach-aussen` samt seinem `LH-FA-03`-
und `LH-QA-01`-Bezug, die drei Fragen aus seinem §4, die Einträge `MR-054`, `MR-055`, `MR-017`,
`MR-001`, `MR-021`, `AGENTS.md` §3.4/§3.5/§3.6/§3.11, `ADR-0013` und die zwei `matrix:`-Blöcke in
`.d-check.yml` und `internal/emit/templates/d-check.yml`.

**Ausgang:** bestätigter ADR-Bezug, **keine Folge-ADR**. Je Frage steht unten, warum keine fehlt.

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt
> sich weiter. Deshalb **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `MR-*`/`ADR-*`/`LH-*` als Inline-Code. Ortsfeste Ablagen
> (`.d-check.yml`, `docs/plan/planning/observations/`) stehen als Pfad, weil der Prozess sie nicht
> bewegt (`AGENTS.md` §3.11).

**Modell:** claude-opus-5 · **Datum:** 2026-09-18 · **Baseline:** `v6.9.0`.

---

## Verdikt in drei Sätzen

- **(a) Nein** — `MR-054` bindet die **Modul-Zusammensetzung**, nicht die Positionen innerhalb
  eines aktiven Moduls; `matrix` ist im emittierten Gate bereits aktiv, und was die Regel-Änderung
  dort bindet, sind `MR-017` und `AGENTS.md` §3.6.
- **(b) Nicht per se** — und die Frage wird nicht über die **Menge**, sondern über das
  **Verhalten** beantwortet: Zwei der drei Pfade nehmen nichts weg, `docs/plan/planning/done/**`
  in dieser Weite nimmt **195 heute klassifizierte Dateien** aus der Status-Prüfung und wäre damit
  eine Senkung; die enge Fassung auf die Welle-Dateien vermeidet sie ohne Verlust.
- **(c) Er bleibt in der Spezifikation** — `ADR-0013` Festlegung 1 und 2 ziehen die Linie bereits,
  und `MR-021` nennt die sechs erklärten Abweichungen dort namentlich als Zielort; nur ihr
  Abwärts-Zeiger fällt.

---

## (a) Bindet `MR-054` auch die Regel-Änderung in einem aktiven Modul?

**Antwort: nein.** `MR-054` zieht seine Grenze selbst, im Feld `Geltungsbereich`:

> **Nicht** die Positionen *innerhalb* eines aktivierten Moduls — welche Klassen, welche Regeln
> und welche Abschnitts-Ausnahme der `matrix`-Block trägt, setzt dieser Eintrag nicht; das ist
> eine eigene Entscheidung mit eigenem Träger.

Derselbe Satz steht ein zweites Mal in Setzung 1: *„Kriterium 1 bindet auf **Modul**-Ebene, nicht
auf die Positionen innerhalb eines Moduls."* Das Modul ist längst drin:

```sh
grep -m1 '^modules:' internal/emit/templates/d-check.yml   # modules: [links, anchors, ids, matrix, spans]
grep -m1 '^modules:' .d-check.yml                          # die Liste dieses Repos, sie führt matrix ebenso
```

**Keine Erwartungswerte** (`MR-025` Setzung 2) — beide Listen wachsen. Tragend ist, dass `matrix`
in der linken steht: Die Zulassungs-Entscheidung, die `MR-054` regelt, ist für dieses Modul
gefallen. `MR-055` hebt drei **Folgerungen** jenes Eintrags auf, keine seiner Setzungen und nicht
seinen Geltungsbereich; der zitierte Satz bindet unverändert.

**Was stattdessen bindet — und es kostet den Implementer nichts.** Auf der Emissions-Ebene gilt
`MR-017` ohne Einschränkung: sein Geltungsbereich ist *„jede vom Tool **emittierte**
Gate-Konfiguration, die ein Adopter danach selbst pflegt"*, und darunter fällt jede Position in
ihr, nicht nur die Modul-Liste. Dazu `AGENTS.md` §3.6: eine Zusage ist erst fertig, wenn ihr
Gegenbeispiel rot gesehen ist. Die zwei zusammen verlangen genau das, was DoD 2 ohnehin fordert —
grüner Start des frischen Ziels und ein im Ziel rot gesehenes Gegenbeispiel. **Die Antwort
verschiebt die Quelle, nicht die Arbeit.**

**Keine ADR nötig:** Die Abgrenzung steht wörtlich im Eintrag, und die Ersatz-Bindung steht in
einem zweiten. Eine Entscheidung darüber wäre eine dritte Fassung derselben Aussage, und zwei
Fassungen derselben Regel driften.

**Grenze dieses Punktes:** Sie gilt, solange der Slice **kein Modul aktiviert**. Nähme er eines in
`modules:` der emittierten Datei auf, bänden die drei Kriterien aus `MR-054` Setzung 1 vollständig
— Erprobung im Dogfood, grüner Start, rotes Gegenbeispiel im Ziel.

---

## (b) Ist `exempt-paths` eine Senkung nach `AGENTS.md` §3.5?

**Antwort: nicht per se — die Frage wird je Pfad und über das Gate-**Verhalten** beantwortet.**
Zwei Einträge dieses Repos tragen das Kriterium bereits, beide für Nachbar-Positionen derselben
Datei:

- `MR-001` zu `scan.ignore`: *„beide sind **Scoping**, keine Gate-Lockerung nach `AGENTS.md` §3.5,
  denn der Prüfumfang schrumpft nicht um Bestand, den dieses Repo autoritativ schreibt"*.
- Der Kommentar am `MR`-Muster in `.d-check.yml` (`ids.exempt-paths`): *„KEINE Senkung: jedes
  Byte, das hier ausgenommen ist, lag vorher in der Index-Datei und war dort ebenso ausgenommen"*.

Beide messen dieselbe Größe: die **Differenz zum Zustand vorher**, nicht die Länge der Liste. Das
auf `matrix.exempt-paths` anzuwenden ist **Anwendung, keine neue Regel** — deshalb steht dazu
nichts im Adaptions-Block und in keiner ADR.

**Die Menge ist dabei nur die Anzeige, nicht die Antwort.** Das Beobachtungs-Register führt
`BEO-ALL/senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens` (Risiko 5 des Plans): Eine
Senkungs-Frage, die über Inhalts-Mengen beantwortet wird, beantwortet vollständig und richtig eine
**andere** Frage als die gestellte; widerlegbar ist sie *„nur durch eine **Sonde**: derselbe
konstruierte Zustand über beiden Ständen, einmal zurückgewiesen und einmal durchgelassen"*. Das
Verdikt übernimmt das als Form.

### Die Prüf-Form, verbindlich je Pfad

Für jeden Pfad in `exempt-paths` gilt: Konstruiere einen Zustand, den die neue Klasse `aussen`
zurückweisen würde, und fahre ihn **zweimal** — gegen die heutige Konfiguration und gegen die
vorgeschlagene. **Senkung genau dann, wenn der heutige Stand zurückweist und der vorgeschlagene
durchlässt.** Weist keiner zurück, nimmt die Ausnahme nichts weg; weisen beide zurück, ebenso
wenig.

### Die drei Pfade, gemessen an diesem Baum

Die heutigen Klassen stehen in `.d-check.yml`: `spec-straten` (drei Dateien), `adr` als
`docs/plan/adr/[0-9]*.md`, `slice` als `docs/plan/planning/**/slice-*.md`. Die Status-Prüfung
trifft nach der Sonde in §1 des Plans **jede klassifizierte Quelle**, unabhängig von den Regeln.

| Pfad | heute klassifiziert? | Urteil |
|---|---|---|
| `docs/plan/adr/README.md` | nein — `[0-9]*.md` trifft `README.md` nicht | **keine Senkung** |
| `docs/reviews/*.md` | nein — keine Klasse nennt das Verzeichnis | **keine Senkung** |
| `docs/plan/planning/done/**` | **ja** — `slice` trifft dort heute | **Senkung, so nicht** |

Die dritte Zeile ist der Befund dieses Verdikts. Die Zahl dazu:

```sh
find docs/plan/planning/done -maxdepth 1 -name 'slice-*.md' | wc -l   # 195
```

**Kein Erwartungswert** — sie wächst mit jeder Closure. Diese 195 Dateien sind **heute** Quellen
der Klasse `slice` und stehen **heute** unter der Status-Prüfung; ein `done/**` nähme sie heraus.
Die enge Pfad-Liste aus §1, Schärfung 1 ändert daran nichts: Sie nennt die vier
Lifecycle-Verzeichnisse ausdrücklich, und `done/` ist eines davon.

**Dass heute keine dieser Dateien einen Befund auslöst, ist kein Gegenargument** — gemessen:

```sh
SUP=$(grep -l '^\*\*Status:\*\* \(Superseded\|Deprecated\)' docs/plan/adr/[0-9]*.md | sed 's|.*/||;s|\.md$||')
for a in $SUP; do grep -rln "adr/$a" docs/plan/planning/done --include='slice-*.md'; done | sort -u | wc -l   # 0
```

Eine Senkung misst die **geprüfte Fläche**, nicht den Befund-Stand: Supersession ist einseitig,
die Zahl kann nur steigen, und eine eingefrorene Datei kann sich nicht wehren. Genau dieses
Argument trägt Schärfung 3 des Plans für `docs/reviews/*.md`; es gilt hier gegen die weite
Fassung.

### Der Weg, der trägt — und er kostet eine Zeile

Der gesamte `done/`-Baum bringt **eine** Datei mit, die die neue Klasse aktiv werden ließe, und
sie ist keine Slice-Datei:

```sh
SUP=$(grep -l '^\*\*Status:\*\* \(Superseded\|Deprecated\)' docs/plan/adr/[0-9]*.md | sed 's|.*/||;s|\.md$||')
for a in $SUP; do grep -rln "adr/$a" docs/plan/planning/done; done | sort -u
# docs/plan/planning/done/welle-01-offline-kern.md
```

**Kein Erwartungswert.** Eine Ausnahme, die die Welle-Dateien in `done/` nennt statt des ganzen
Baums, nimmt damit **nur, was die neue Klasse hinzufügt** — die Welle-Dateien tragen heute keine
Klasse (`welle` gibt es nur in der emittierten Hälfte). Mit dieser Fassung ist das Ensemble aus
Klasse, Regel und Ausnahme netto eine **Verschärfung**, und eine Verschärfung braucht kein ADR:
`AGENTS.md` §3.5 gilt für Senkungen, `MR-001` sagt es für dieselbe Datei — *„Gate-*Anheben* →
Steering-Loop, kein ADR nötig"*.

**Verbindlich für den Implementer:** Jeder Pfad in `exempt-paths` trägt (1) die Sonde oben, am
gepinnten Stand gefahren und im Umsetzungs-Commit belegt, und (2) seinen Grund als Kommentar an
der Zeile — das verlangt DoD 1 ohnehin. Ergibt die Sonde für einen Pfad *heute zurückgewiesen,
nachher durchgelassen*, ist dieser Pfad eine Senkung: Dann **nicht** verengen und weiterlaufen,
sondern die Rückführung `in-progress` → `open` aus §4 ziehen und das Verdikt hier neu einholen —
eine Senkung ist eine ADR-Frage, und die entscheidet nicht der bauende Lauf.

**Nicht berührt:** `exempt-paths` ist nicht `ignore-refs`. `AGENTS.md` §3.11 hält jedes weitere
`ignore-refs`-Paar als Senkung mit eigener ADR fest; dieses Verdikt erweitert diese Grenze nicht
und der Plan schließt solche Paare ohnehin aus.

---

## (c) Bleibt der Abweichungs-Abschnitt in der Spezifikation?

**Antwort: er bleibt.** Es fällt nur sein Zeiger nach außen, nicht sein Ort. Die Entscheidung ist
gefallen und `Accepted` — `ADR-0013`, Festlegung 1:

> Die Feldtabelle der Span-Erfassung (Feld · Pflicht/Optional · Incident-Frage) und die je
> Abweichung vom Pflicht-Minimum geschuldete Begründung leben in §5

und Festlegung 2 zieht die Gegenlinie:

> Die **Begründung** einer Entscheidung bleibt in der Entscheidung; die **Abweichung von der
> Baseline** bleibt im Adaptions-Block

Beide zusammen ergeben den Schnitt, nach dem die Frage verlangt: Was das Repo **technisch
festlegt** — welche Felder erfasst werden, was davon fehlt und warum — ist eine fortschreibbare
technische Festlegung und gehört ins Technik-Stratum. Was eine **Baseline-Regel ersetzt** — die
vierte Spalte `Sensor` gegen die drei Spalten der Ziel-Form — ist die Abweichung und liegt bereits
im Adaptions-Block, als `MR-021` mit der Fortschreibung in `MR-044`. Die sechs Abweichungen sind
dort schon namentlich zugewiesen: `MR-021` führt *„die sechs erklärten Abweichungen"* in der
Liste der Posten, deren Zielort `spec/spezifikation.md` §5 ist.

**`ADR-0013` steht auf `Accepted`** (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0013-technik-stratum-als-zielort.md`).
Nach `AGENTS.md` §3.4 überschreibt sie niemand; ein Umzug des Abschnitts verlangte eine Folge-ADR
mit `Supersedes` und **neue Evidenz**. Die liegt nicht vor: Der Abschnitt ersetzt keine
Baseline-Regel, er erfüllt eine — das Observability-Modul verlangt, jede Abweichung zu benennen
statt sie wegzulassen, und genau das tut er an dem Ort, den die ADR ihm zuweist.

**Was der Slice an ihm ändert, ist der Zeiger — und das ist dieselbe ADR.** Festlegung 3 lautet:

> Die Aufwärts-Regel gilt ab der ersten Zeile. Der bindende Text des Stratums trägt **keine**
> Entscheidungs- und keine Planungs-Kennung; Provenienz lebt allein in seiner Historie-Tabelle.

Für `ADR-` und Slice-Kennungen ist der Slice damit die **mechanische Durchsetzung einer
bestehenden Festlegung**, kein neuer Beschluss. Für `MR-`-Kennungen reicht die Setzung des
Auftraggebers vom 2026-09-16 einen Schritt weiter als Festlegung 3 — sie ist eine **Verschärfung**
in dieselbe Richtung und braucht darum kein ADR (`AGENTS.md` §3.6 spricht denselben Satz für sich
selbst aus). Die Gegenrichtung bleibt offen: `MR-021` und `MR-044` dürfen weiter auf §5 zeigen.
**Der Zeiger geht nicht verloren, er dreht sich um.**

**Operative Folge, und sie trifft Risiko 1:** Wo ein Satz in §5 seine einzige Quelle im
gestrichenen Verweis hatte — die Sonden und Gegenproben in `MR-021` —, nennt der Satz danach, was
er behauptet, oder er behauptet weniger. Was er nicht darf, ist ein Rückbezug ohne Ziel (*„wie
dort gemessen"*); das ist der Befund F-5, den dieser Slice mit übernimmt.

---

## Auftrag an den Implementer

1. **`MR-054` nicht zitieren, wo `MR-017` bindet.** Die Regel-Änderung im emittierten
   `matrix`-Block läuft unter `MR-017` und `AGENTS.md` §3.6. DoD 2 bleibt unverändert:
   `make full-smoke` grün, Gegenbeispiel im Ziel rot gesehen. Aktivierst du ein **Modul**, gilt
   `MR-054` voll — dann zurück zum Architect.
2. **`exempt-paths` eng fassen und die Sonde fahren.** `docs/plan/planning/done/**` nicht in
   dieser Weite; nimm die Welle-Dateien des `done/`-Baums in der Form, die der gepinnte Stand
   verlangt. Je Pfad die Zwei-Stand-Sonde (heute / vorgeschlagen), Beleg im Umsetzungs-Commit,
   Grund als Kommentar an der Zeile.
3. **Weist die Sonde für einen Pfad einen heute zurückgewiesenen Zustand durch, ist Schluss.**
   Rückführung `in-progress` → `open` nach §4, Verdikt neu einholen. Nicht selbst entscheiden und
   nicht stillschweigend verengen, bis es grün ist.
4. **Der Abweichungs-Abschnitt bleibt in `spec/spezifikation.md` §5.** Entfernt werden die
   Referenzen, nicht der Abschnitt und nicht seine Aussagen. Sätze ohne Quelle werden auf das
   zurückgeschnitten, was sie ohne sie halten.
5. **Die Historie-Zeile beider Spec-Dateien nennt den Zustand, nicht die Chronik** (`AGENTS.md`
   §3.7). `ADR-0013` Festlegung 3 lässt Provenienz allein dort zu — also bleibt sie dort auch
   zulässig.
6. **Risiko 5 hat damit sein Kriterium.** Bei der Closure ist sein Ausgang an der Sonde zu
   messen, nicht an einer Mengen-Differenz.

## Was dieses Verdikt nicht entscheidet

- **DoD 3** — welcher der zwei Wege die bloße Kennung fängt (`token`-Klassen oder der Nachweis
  über `ids` mit `link-policy: always`). Das ist eine **Messung am gepinnten Stand**, keine
  Entscheidung; beide Wege liegen innerhalb aktiver Module und damit innerhalb des Rahmens, den
  (a) und (b) hier abstecken. Braucht der erste Weg eine eigene Klasse für den Adaptions-Block vor
  `aussen`, ist auch das eine Position innerhalb eines aktiven Moduls.
- **Die Historie-Ausnahme im emittierten Template** — DoD 2 misst sie am Ziel; eine Entscheidung
  vorab wäre ohne Messung.
- **Die schreibende Rolle der Spec-Straten** (Risiko 4) — dafür ist
  `slice-151-spec-straten-haben-eine-schreibende-rolle` die Adresse, und dieser Lauf greift ihr
  nicht vor.
- **Wird `make full-smoke` rot, weil eine vendored Spec-Vorlage im Ziel nach außen zeigt**, ist
  das die zweite Rückführung aus §4 und kommt hierher zurück.

## Akzeptierte Negative

- **Kein Eintrag im Adaptions-Block zur Senkungs-Frage.** Das Kriterium — *Differenz zum Zustand
  vorher, gemessen am Verhalten* — steht bereits zweimal in diesem Repo (`MR-001` für
  `scan.ignore`, der Kommentar am `MR`-Muster für `ids.exempt-paths`). Es auf
  `matrix.exempt-paths` anzuwenden ist Anwendung; eine dritte Fassung derselben Aussage würde
  gegen die zwei vorhandenen driften. **Das ist entschieden, nicht übersehen.**
- **Kein Beobachtungs-Beleg aus diesem Lauf.** Der Befund zu `done/**` ist genau die Klasse, die
  `BEO-ALL/senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens` bereits führt, und sein
  Beleg gehört an den Vorgang, der ihn abschließt — die Closure dieses Slice, nicht dieses
  Verdikt. Ein zweiter Beleg für denselben Vorgang zählte doppelt, was einmal geschah.
- **Keine Folge-ADR.** Für alle drei Fragen liegt die Festlegung vor: `MR-054` grenzt sich selbst
  ab, `AGENTS.md` §3.5 samt seiner zwei gelebten Anwendungen beantwortet die zweite, `ADR-0013`
  die dritte. Eine ADR, die nur bestätigt, was `Accepted` dasteht, macht die Lage nicht
  verbindlicher — sie verdoppelt sie.

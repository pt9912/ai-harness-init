# Review: ADR-0037 — Konsistenz-Review, Runde 7

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Nacharbeit-Commit `4afbde8` (Diff `4afbde8^..4afbde8` = `1b6500f..4afbde8`,
**eine** Datei: die ADR, **2 Zeilen** — eine ersetzt, eine neu).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message von `4afbde8`, aus dem Slice-Plan oder aus der ADR übernommen.
Die drei Selbstmeldungen des Architect sind am Ist-Stand nachgeprüft, nicht am Änderungsbericht.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `4afbde8` gegen `4afbde8^` = `1b6500f`. **Der Arbeitsbaum ruhte über die ganze
  Strecke.** Gemessen zu Beginn und am Ende: `git log --oneline -1` → `4afbde8` in beiden Fällen,
  `git status --porcelain` bis zum Schreiben dieses Reports leer. Eigene Messung, nicht die
  übernommene Zusage des Auftrags.
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Absatz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  alle fünf `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4, §3.5, §3.6, §3.8, §3.9,
  §3.10, §3.11. Dazu [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-06-adr-0037-konsistenz-review.md) (0 HIGH · 5 MEDIUM · 4 LOW · 3 INFO),
  [Runde 2](2026-09-06-adr-0037-konsistenz-review-runde-2.md) (0 HIGH · 2 MEDIUM · 4 LOW · 5 INFO),
  [Runde 3](2026-09-06-adr-0037-konsistenz-review-runde-3.md) (0 HIGH · 3 MEDIUM · 1 LOW · 2 INFO),
  [Runde 4](2026-09-06-adr-0037-konsistenz-review-runde-4.md) (0 HIGH · 1 MEDIUM · 1 LOW · 2 INFO),
  [Runde 5](2026-09-06-adr-0037-konsistenz-review-runde-5.md) (0 HIGH · 1 MEDIUM · 0 LOW · 1 INFO)
  und [Runde 6](2026-09-06-adr-0037-konsistenz-review-runde-6.md) (0 HIGH · 1 MEDIUM · 0 LOW ·
  1 INFO), alle sechs *Konsistenz NICHT BESTÄTIGT*.
- **Slice-Plan:** `slice-190` — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.
  Seine Verzeichnis-Position steht hier bewusst nicht als Pfad
  ([`AGENTS.md`](../../AGENTS.md) §3.11); die Kommandos unten adressieren ihn über den Glob
  `docs/plan/planning/*/slice-190-*.md`, der in diesem Lauf **genau eine** Datei trifft
  (`ls -1 docs/plan/planning/*/slice-190-*.md | wc -l` → **1**, kein Erwartungswert).

**Gate-Lauf, Docker-only (§3.9).** `make docs-check` über diesem Baum →
`d-check: 890 Datei(en) geprüft, 0 Befund(e)`, EXIT 0.

**Messumgebung — sie ist diesmal Teil des Befunds.** In der interaktiven Sitzung ist `grep` eine
**Shell-Funktion**, die auf `ugrep 7.8.4` umleitet (`type grep` → *„grep ist eine Funktion"*).
Jedes Kommando dieses Reports ist deshalb unter **GNU grep 3.11** in einer Shell ohne diese
Funktion gefahren (`env -u BASH_ENV PATH=/usr/bin:/bin /usr/bin/bash --noprofile --norc`); die
vom Architect zugesagte Übereinstimmung beider Maschinen ist zusätzlich **beidseitig** geprüft
und steht in N-1.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### INFO-1 — Das verankerte Zähl-Muster ist auf dem heutigen Baum exakt; seine Genauigkeit hängt an einer Report-Konvention, nicht an einer Mechanik

- `kategorie`: **INFO** (blockiert **nicht** — Begründung unten und im Verdikt)
- `quelle`: Maintainability ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (erfüllt — der Posten benennt eine Grenze, keinen Verstoß)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:769` (die in `4afbde8`
  ersetzte Geschichte-Zeile zu Runde 5)
- `befund`: Das neue Muster `^- .klasse.:.*Stand eines fremden Artefakts` keilt auf die **Form**
  einer `klasse`-Zeile — Zeilenanfang, ein Trennzeichen, `klasse`, ein Trennzeichen, Doppelpunkt.
  Es unterscheidet damit einen Report, der ein Finding dieser Klasse **trägt**, von einem, der die
  Klasse nur **nennt** — aber nicht einen, der eine fremde `klasse`-Zeile in genau dieser
  Bullet-Form **zitiert**. Dass heute keiner der sieben Reports das tut, ist eine Konvention der
  Report-Form, keine Eigenschaft des Musters.
- **Warum das trotzdem die richtige Wahl ist, und zwar gemessen:** Das engere Muster
  (`Stand eines fremden Artefakts` statt nur `fremden`) ist gegenüber meiner Vorrunden-Empfehlung
  die **haltbarere** Wahl. `fremden` allein träfe jede künftige Klasse, die das Wort führt; das
  engere trifft genau diese. Beide liefern auf dem heutigen Baum **4** — die Enge kostet heute
  nichts und deckt morgen mehr.
- **Warum INFO und nicht MEDIUM — der Unterschied zu Runde-6-M-1 ist der Gegenbeispiel-Test
  ([`AGENTS.md`](../../AGENTS.md) §3.6):** Runde-6-M-1 war **rot zu sehen** — das abgedruckte
  Kommando lieferte über dem realen Baum **5**, während die Zeile **4** behauptete. Für den
  Rest hier lässt sich das Gegenbeispiel über dem realen Baum **nicht** herstellen; ich habe es
  nur **synthetisch** erzeugen können (N-1, dritter Block). Ein Posten, dessen Gegenbeispiel ich
  fabrizieren muss, ist eine benannte Grenze und keine gebrochene Zusage.
- **Failure-Szenario (benannt, damit es nicht als ausgeschlossen gilt):** Ein späterer Report
  zitiert die `klasse`-Zeile einer Vorrunde als eigene Bullet-Zeile; der Zähler steigt, ohne dass
  die Klasse aufgetreten wäre. Nach `Accepted` ist die Zeile durch
  [`AGENTS.md`](../../AGENTS.md) §3.4 gesperrt, die Korrektur kostete dann eine Folge-ADR.
- `verifizierbar`: **nein** — kein Gate hält ein abgedrucktes Kommando gegen seinen abgedruckten
  Wert; die ADR sagt das inzwischen selbst (§Fitness Function, dritte Lücke).
- `klasse`: *Verankertes Zähl-Muster hängt an einer Report-Konvention statt an einer Mechanik*

---

## Negativbefunde (geprüft, ohne Befund)

### N-1 — Runde-6-M-1 ist behoben; das Instrument ist auf diesem Baum nicht nur richtig, sondern exakt

Drei Prüfungen, alle bestanden. **Erstens** die Zählung selbst, beide Formen nebeneinander:

```sh
G='docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md'
grep -lE '^- .klasse.:.*Stand eines fremden Artefakts' $G | wc -l   # 4 — die neue, abgedruckte Form
grep -l  'klasse.*fremden Artefakts'                    $G | wc -l   # 5 — die ersetzte Form
comm -13 <(grep -lE '^- .klasse.:.*Stand eines fremden Artefakts' $G | sort) \
         <(grep -l  'klasse.*fremden Artefakts'                    $G | sort)
# docs/reviews/2026-09-06-adr-0037-konsistenz-review-runde-6.md
```

**Keine Erwartungswerte.** **Zweitens — und das geht über die Selbstmeldung hinaus:** Das Muster
ist nicht nur *auf die richtige Zahl* verankert, sondern auf die *richtigen Dateien*. Es benennt
Runde 1, 2, 4 und 5 — genau die vier Runden, die ein Finding dieser Klasse tragen; Runde 3 und
Runde 6 tragen keines. Gegengeprüft am vollständigen Bestand aller `klasse`-Zeilen:

```sh
for f in docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md; do
  printf '%s %s\n' "${f##*/}" "$(grep -cE '^- .klasse.:' "$f")"
done
# review.md 12 · runde-2 11 · runde-3 6 · runde-4 4 · runde-5 2 · runde-6 2
```

**Keine Erwartungswerte.** In den 37 `klasse`-Zeilen der sechs Reports trägt genau **vier** Mal
eine den Wortlaut dieser Klasse, je Report höchstens einmal. Der Zähler misst damit *Vorgänge*,
wie ihn Modul 6 §Das Beobachtungs-Register verlangt (*„Ein Vorgang zählt einmal"*), und nicht
Fundstellen.

**Drittens die beiden Richtungen isoliert** — die Selbstmeldung des Architect, unabhängig
nachgebaut. Über einer Datei, die die Klasse **nur zitiert** (vier Zitat-Formen, darunter das
abgedruckte Kommando selbst), und über einer Datei mit **einer echten** `klasse`-Zeile:

```sh
# zitat-nur.md: Prosa-Nennung, das abgedruckte Kommando, **Klasse:**-Bullet, "die Klasse:"-Bullet
grep -c  'klasse.*fremden Artefakts'                    zitat-nur.md     # 1 — alte Form greift
grep -cE '^- .klasse.:.*Stand eines fremden Artefakts'  zitat-nur.md     # 0 — neue Form nicht
grep -cE '^- .klasse.:.*Stand eines fremden Artefakts'  echte-klasse.md  # 1 — und greift hier
```

**Und unter beiden Maschinen gleich**, wie zugesagt: dieselben drei Werte `1`/`0`/`1` und dieselbe
Repo-Zählung `4` gegen `5` unter **GNU grep 3.11** und unter **ugrep 7.8.4**. Die Zusage des
Architect ist damit unabhängig bestätigt — sie war prüfpflichtig, weil die interaktive Sitzung
dieses Repos `grep` auf `ugrep` umleitet und ein Regex-Dialekt-Unterschied genau hier durchgeschlagen
wäre.

### N-2 — Die Fundmengen-Aussage über die eigenen Kommandos trägt, mechanisch nachgezählt

Der Architect meldet, die Klasse habe **genau ein** Vorkommen. Das ist selbst eine Zusage über eine
Fundmenge — die Klasse, die diese Rundenreihe getragen hat —, und ich habe sie deshalb nicht
stichprobenartig, sondern **vollständig** geprüft: alle Kommandos der Datei extrahiert und jeden
Suchraum klassifiziert.

```sh
A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
grep -cE '^[[:space:]]*```sh$' "$A"   # 19 — sh-Zäune
# Kommandos in den Zäunen, Fortsetzungszeilen zusammengefasst (awk-Extraktion) → 48
# Inline-Kommandos, absatzweise extrahiert                                      →  6
```

**Keine Erwartungswerte.** **54 Kommandos** gesamt. Über der Gesamtliste:

```sh
grep -c 'docs/reviews'  /tmp/allcmds.txt   # 1
grep -c 'docs/plan/adr' /tmp/allcmds.txt   # 1
```

**Die zweite Zahl ist kein Gegenbeleg, und das ist der Grund, warum ich sie hier hinschreibe
statt sie wegzulassen.** Ihr einziger Treffer ist
`.harness/baseline/v6.0.0/templates/docs/plan/adr/README.template.md` — eine **Vorlagen**-Datei im
vendored Baum, nicht das ADR-Verzeichnis dieses Repos. Kein Kommando der Datei durchsucht
`docs/plan/adr/`. Die drei rekursiven Suchen wurzeln in `internal/emit/templates/commands/`,
`internal/ cmd/` (mit `--include='*.go'`) und `.harness/baseline/v6.0.0/templates`; keine erreicht
`docs/`. Die übrigen Suchräume sind einzelne Baseline-, Spec- oder Quelldateien plus der
`slice-190`-Glob. **Die Aussage des Architect trifft zu.**

**Eine Methoden-Falle ist mir dabei zugestoßen und steht hier statt stillschweigend korrigiert.**
Mein erster Extraktions-Versuch fügte den Text zu **einem** Strom zusammen und paarte die
Backticks darüber. Das lieferte 267 Spans und **null** Kommandos — weil die Datei eine
**ungerade** Zahl Backticks trägt: Ab dem ersten unpaarigen Zeichen verschiebt sich jede weitere
Paarung um eins.

```sh
BT=$(printf '\140')
grep -o "$BT" docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md | wc -l   # 675
```

**Kein Erwartungswert.** Erst absatzweises Zusammenfügen resynchronisiert. Zeilenweise Extraktion
wiederum **verfehlt** ein Kommando — das `git log --oneline --follow`-Inline bricht über einen
Zeilenumbruch. Beide Fehler zeigen in verschiedene Richtungen; die abgedruckte Zahl 6 ist die, auf
der beide Verfahren nach Korrektur übereinstimmen. **Dass die Zahl ungerade ist, hat mich in
diesem Report ein zweites Mal eingeholt**: Der erste Entwurf trug das Kommando oben als
Inline-Span mit einem echten Backtick darin und brach damit seine eigene Span-Paarung — gefunden
hat es `make docs-check` (`span-unclosed`), nicht ich.

### N-3 — Alle 54 abgedruckten Kommandos reproduzieren

Gefahren in der Reihenfolge der Datei, jedes gegen seinen abgedruckten Wert. **48 in den Zäunen:**
`1`·`1` · `1`·`1` · `3`·`2` · `3`·`2` · die vierzeilige Klammer-Ausgabe · die einzeilige
Lifecycle-Klammer · `4`·`3` · `| 0.8.0 | 2026-07-21`·`2026-09-03` · `0` · `1`·`0` · `1`·`1`·`1` ·
`0`·`3` · `1`·`1` · `1`·`0` · die `.gitkeep`-Satz-Ausgabe · `2`·`1`· die zweizeilige Link-Ausgabe ·
`1`·`1` · `0`·`1`·`1`·`1`·`1` · `0`·`1`·`1`·`1`·`1`·`1`·`1`·`1`·`1`·`1` (der `slice-190`-Block).
**6 inline:** `2` Zeilen `git log --follow` · die `modules:`-Ablesestelle ohne Wert · `2`
(Register-Zähler) · `6` (Risiken ohne Ausgang) · `4` (Klassen-Zähler) · `1` (die neue §8-Zeile).
**Keine Abweichung.**

Die vier Klassen-Klammern aus [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
kommen dabei vollständig heraus — `(authored-once: …)`, `(ADR · slice · welle · carveout ·
review-report)`, `(ADR-/ Carveout-Index)`, `(Lifecycle- Ordner, ADR-/Carveout-/Reviews-Ordner)` —,
und die vierte ist die ausgelegte. Der `slice-190`-Glob trifft **eine** Datei.

### N-4 — Die Nicht-Aufnahme von Runde-6-INFO-1 trägt, und die Beobachtung dahinter stimmt

Der Architect begründet sie mit einer Beobachtung, die schärfer ist als der Vorrunden-Report:
Die vom Literal `carveouts/done` getroffenen Stellen und die von der ADR benannten
Kollisionsstellen seien **nicht dieselben vier**. Nachgemessen — sie stimmt:

```sh
P='docs/plan/planning/*/slice-190-*.md'
grep -c 'carveouts/done' $P                                    # 4
awk '/^## /{sec=$0} /carveouts\/done/{print sec}' $P | sort -u  # §1, §2, §3, §6
```

**Keine Erwartungswerte.** Die vier **benannten** Kollisionsstellen sind DoD (1), DoD (3), §1 und
die `structureGitkeeps`-Zeile in §3. Der Abgleich Zeile für Zeile:

- **DoD (1)** trägt das Literal (im Fließtext des Punktes).
- **DoD (3)** trägt es **nicht** — der Punkt lautet *„Gemessen: `codepaths` über dem frischen Ziel
  meldet 6 → 3 Befunde …"*.
- **Die `structureGitkeeps`-Zeile in §3** trägt es **nicht** — sie sagt *„die zwei fehlenden
  Verzeichnisse"*.
- **§1**: Der benannte Satz *„Nur die ersten zwei sind unstrittig"* trägt es nicht; das Literal
  steht in der Tabellenzeile darüber.

Und **umgekehrt** sind zwei der vier Literal-Treffer gerade **keine** Kollisionsstellen: der
§3-Change-Request-Satz, den die ADR ausdrücklich für unberührt erklärt, und das §6-Risiko, das der
Plan selbst offenhält. **Zwei Mengen, vier zu vier, und beide Richtungen weichen ab** — ein
Muster-Lauf ist über diesem Gegenstand kein Kriterium. Die Nicht-Schließungs-Klausel beschreibt
damit eine reale Grenze; einen fünften Eintrag in eine ausdrücklich offene Menge zu setzen,
schlösse sie nicht.

**Der zweite Grund trägt ebenfalls, und ich habe ihn am Ort geprüft, nicht am Zitat.** Die
§8-Stelle steht im Bullet zu `emittierte-vorlagen-klassifikation-ohne-traeger`; der Satz *„Den
Stand setzt der Lese-Schritt der Closure, nicht dieser Plan"* ist die **unmittelbar folgende
Aussage desselben Bullets** und regiert damit genau die Stelle, um die es geht — nicht eine
andere. Nach Modul 6 §Das Beobachtungs-Register ist *Stand* der Oberbegriff der drei Ausgänge
(*„Der Stand wird dabei zu einem von drei Ausgängen"*), sodass der Satz die vorangehende
Ausgangs-Zuweisung deckt. Das ist Closure-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10) und
dieselbe Grenze, an der Folgepflicht 3 die Risiko-Ausgänge liegen lässt.

**Kein Satz der ADR wird durch die §8-Stelle falsch** — die Datei schließt die Menge ausdrücklich
nicht und weist die Vollständigkeitsmessung dem Planner zu.

### N-5 — Die neue Geschichte-Zeile, Aussage für Aussage

Sie ist der einzige neue Text des Commits und damit prüfpflichtig — genau die Lehre, die der
Vorrunden-Report zog. Geprüft, alle bestanden: die Summary `0 HIGH · 1 MEDIUM · 0 LOW · 1 INFO`
stimmt mit dem Runde-6-Report überein · *„in sechs Runden kein Befund"* gegen die Entscheidung
stimmt · die Wiedergabe der Rang-1-Prüfung entspricht dem Negativbefund jenes Reports · die
M-1-Beschreibung ist zutreffend und in N-1 unabhängig nachgemessen · die INFO-1-Begründung ist in
N-4 nachgemessen · das neue §8-Kommando reproduziert (`1`) und nennt den Plan über den Glob
(§3.11).

**Der Satz *„Ein neuer Vollständigkeits-Anspruch entsteht hier nicht"* hält.** Ich habe die Zeile
darauf abgesucht: Die einzige Mengen-Aussage darin ist *„Zwei Gründe tragen das"* — die Gründe des
Schreibenden für seine eigene Entscheidung, kein Messwert über fremden Text. Die Klausel über die
vier Stellen ist unverändert und weiter als nicht geschlossen gekennzeichnet.

### N-6 — Sonstiges, geprüft ohne Befund

- **Gegen die Entscheidung selbst steht in sieben Läufen kein Befund.** Die zwei
  Kern-Argumentationen halten dem Volltext stand: [ADR-0007](../plan/adr/0007-bootstrap-phasen.md)
  beantwortet *wie* eine emittierte Datei beim Re-Lauf behandelt wird (*„im Zweifel gilt
  `skip-if-present`"*, am Volltext gelesen — die Formulierung bricht über zwei Zeilen um), nicht
  *ob* sie entsteht; [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 schreibt *„`README.md` und je Beobachtung einem Verzeichnis"* vor. Der emittierte
  Selbstwiderspruch ist erneut gemessen (`3` Anweisungssätze, `2` davon namentlich, `3`
  Go-Fundstellen, keine schreibend — die dritte setzt tatsächlich einen **Link** in einen Stub,
  wie die ADR sagt).
- **Die drei Bedingungen sind für beide aufgenommenen Orte belegt.** Für `harness/conventions/`
  steht der Beleg je Bedingung einzeln in Festlegung 1; für `docs/plan/planning/observations/`
  verteilt über §Kontext — (a) die zwei Indikativ-Zitate, (b) *„Ein Emissionspfad, der die Ablage
  anlegte, existiert nicht"*, (c) §*Warum die Datei kein „Fülle-wenn-Inhalt-da"-Fall ist*.
  Folgepflicht 1 verlangt vom umsetzenden Lauf ausdrücklich die Einzel-Nennung je Ort; die
  Asymmetrie ist damit adressiert, nicht offen.
- **`structureGitkeeps()` heute gegen die Rang-1-Klammer.** Der Emitter hält sechs Orte —
  `docs/plan/adr`, `docs/plan/carveouts`, `docs/reviews` und drei Lifecycle-Ordner —, bedient die
  Klammer *„ADR-/Carveout-/Reviews-Ordner"* also vollständig. Festlegung 4 verengt sie nicht: Die
  Datei liest den Rang-1-Satz als **Träger**-Regel (welches `.gitkeep` ein *leeres*
  Struktur-Verzeichnis hält), und Festlegung 1 sagt über die Klammer nur, dass sie die Menge der
  anzulegenden Orte nicht **schließt**. Zwei Fragen, kein Widerspruch — *„Keine Anforderung wird
  geändert"* bleibt wahr.
- **[`AGENTS.md`](../../AGENTS.md) §3.11 gewahrt.** `grep -c 'slice-190-bootstrap'` → **0** (kein
  Pfad-Link auf die wandernde Plandatei). Die zwei `docs/plan/planning/done/`-Treffer adressieren
  ein **Verzeichnis**, der eine `docs/reviews/…*.md`-Treffer ist ein **Glob** — beide Formen
  erklärt §3.11 ausdrücklich für ortsfest und als Pfad zulässig.
- **§3.8 — Commit-Zuschnitt korrekt.** `git show --pretty=format: --name-only 4afbde8` gibt
  **eine** Datei, die ADR; die Message trägt das Rollen-Präfix. Der ADR-Index braucht keinen
  Nachzug: Titel, Status `Proposed` und die **sechzehn** Bezugs-IDs stimmen in Bestand und
  Reihenfolge mit dem `Bezug`-Kopf überein (`docs/plan/adr/README.md:44`).
- **§3.4 nicht verletzt.** Die Datei steht auf `Proposed`; Überarbeitungen sind in diesem Fenster
  zulässig. **§3.5** — keine Gate-Lockerung, kein Schwellwert, kein `ignore`-Eintrag berührt.
  **§3.10 gewahrt** — der Commit berührt kein Planner-Artefakt, schlägt für keine Kollisionsstelle
  einen Wortlaut vor und setzt keinen Risiko-Ausgang.
- **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  ist an keiner Stelle mehr verletzt** — der Posten, der Runde 6 trug, war der letzte. Jede
  Messwert-Zahl steht neben dem Kommando, das genau sie liefert, und ist als kein Erwartungswert
  gekennzeichnet. **[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  gewahrt** — jede Baseline-Aussage nennt `v6.0.0`.
  **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage)** — kein Adaptions-Eintrag
  fällig; die Entscheidung stellt Baseline-Konformität her.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein
  halluziniertes Gate.** `TestTemplates_EmittierterBestandVollstaendig` existiert, `make full-smoke`
  ist als Nicht-Gate ausgewiesen, die drei nicht gebauten Deckungen sind benannt statt behauptet.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft: Status · Datum · Autor · Bezug · Schärft (`ARC-003` existiert in
  [`spec/architecture.md`](../../spec/architecture.md), zwei Zeilen) · Regeln · Kontext ·
  Entscheidung · Verglichene Alternativen (fünf, *nichts tun* dabei) · Konsequenzen ·
  Fitness Function · Re-Evaluierungs-Trigger (sechs, alle mit Ablesestelle) · Geschichte ·
  Immutabilitäts-Schluss.
- **Ein toter Zeiger neben dem Gegenstand — geprüft und bereits geführt, darum kein Finding.**
  `internal/archive/stub.go` baut Beobachtungs-Kennungen als Link auf `../../observations.md`,
  eine Datei, die es seit der Verzeichnis-Form nicht mehr gibt
  (`ls docs/plan/planning/observations.md` → nicht gefunden). Das ist **kein** Befund gegen diese
  ADR — sie beschreibt jene Stelle zutreffend als *„setzt einen Link in einen Stub"* —, und es ist
  bereits als eigener Slice geführt (`slice-188`, in `open/`). Ich nenne es, weil ein Reviewer,
  der eine tote Adresse sieht und schweigt, schlechter ist als einer, der sie einordnet.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain; alles über `make`, `git`,
  `grep`, `sed`, `awk`, `tr`, `comm`, `ls`, `find`, `bash`.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext, anderes Prüf-Artefakt.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klasse dieses Laufs:** *Verankertes Zähl-Muster hängt an einer Report-Konvention statt an
einer Mechanik*

**Die Klasse der Runden 1–5 findet in dieser Runde keine Instanz und steht weiter bei 4** — und
**dieser Report bewegt die Zahl nachweislich nicht.** Das ist die Probe, die der Auftrag verlangt
hat; sie ist nach dem Schreiben dieser Datei über dem Baum gefahren, der sie enthält, und sie ist
zugleich der nachträgliche Beleg, dass Runde-6-M-1 einen realen Defekt traf:

```sh
G='docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md'
ls -1 $G | wc -l                                                     # 7 — mit diesem Report
grep -lE '^- .klasse.:.*Stand eines fremden Artefakts' $G | wc -l    # 4 — die abgedruckte Form
grep -l  'klasse.*fremden Artefakts'                    $G | wc -l    # 6 — die ersetzte Form
grep -cE '^- .klasse.:.*Stand eines fremden Artefakts' \
  docs/reviews/2026-09-06-adr-0037-konsistenz-review-runde-7.md      # 0 — trifft diesen Report nicht
grep -c  'klasse.*fremden Artefakts' \
  docs/reviews/2026-09-06-adr-0037-konsistenz-review-runde-7.md      # 12 — die alte Form schon
```

**Keine Erwartungswerte**, unter GNU grep und ugrep gleich. Die verankerte Form bleibt bei **4**,
obwohl dieser Report die Klasse zwölfmal nennt; die ersetzte Form wäre über drei Runden von **4**
auf **6** gewandert, ohne dass die Klasse ein einziges Mal aufgetreten wäre.

**Was sich gegenüber Runde 6 verschoben hat.** Sechs Runden lang stand am Ende ein blockierender
Posten, und viermal davon lag er in der Nacharbeit der Vorrunde — dreimal im **Argument**, einmal
im **Protokoll**. Diese Runde findet keinen. Die Nacharbeit zu M-1 hat den Posten nicht verschoben,
sondern geschlossen: Sie hat das Instrument verankert, ohne eine Festlegung, einen Bezug oder eine
Zahl zu bewegen, und sie hat dabei kein neues Protokoll erzeugt, das seinerseits eine ungedeckte
Zusage trüge.

---

## Verdikt

**Konsistenz BESTÄTIGT — 0 HIGH, 0 MEDIUM, 0 LOW, 1 INFO als benannte Grenze.**

**Der Baseline-Trigger *„ADR-Review-Runde abgeschlossen → bindend"* kann mit diesem Verdikt
feuern.** Er steht in der Acceptance-Trigger-Zeile der Vier-Trigger-Klassen-Tabelle (Baseline
`v6.0.0`, `grundlagen-bootstrap.md`,
`grep -c 'ADR-Review-Runde abgeschlossen → bindend' .harness/baseline/v6.0.0/regelwerk/grundlagen-bootstrap.md`
→ **1**, kein Erwartungswert) und setzt eine **abgeschlossene** Runde voraus. Diese Runde schließt
ohne blockierenden Befund; damit steht dem `Accepted`-Übergang von meiner Seite nichts entgegen.
**Über den Übergang entscheidet dieser Report nicht** — das ist Architect-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.8); er stellt fest, dass ihm kein Posten mehr entgegensteht.

**Die drei aufgetragenen Prüfungen, ausdrücklich beantwortet:**

1. **M-1 ist behoben, und die engere Musterwahl war die bessere.** Beide Richtungen isoliert
   nachgefahren, unter GNU grep **und** ugrep gleich, und darüber hinaus: das Muster benennt nicht
   nur die richtige *Zahl*, sondern die richtigen *vier Dateien* — Runde 1, 2, 4, 5 — bei je
   höchstens einer Zeile pro Report. Die Verengung auf `Stand eines fremden Artefakts` kostet heute
   nichts (beide Formen liefern 4) und schützt gegen eine künftige Klasse, die `fremden` führt. Ich
   nehme meine Vorrunden-Empfehlung insoweit zurück.
2. **Die Fundmengen-Aussage trägt.** Vollständig gezählt statt stichprobenartig: 54 Kommandos,
   genau eines durchsucht `docs/reviews/*`, keines das ADR-Verzeichnis dieses Repos, keine
   rekursive Suche erreicht `docs/`. Der eine `docs/plan/adr`-Treffer ist eine Vorlagen-Datei im
   vendored Baum.
3. **Die INFO-1-Beobachtung stimmt und trägt die Entscheidung.** Die zwei Vierer-Mengen weichen in
   **beide** Richtungen ab: zwei benannte Stellen tragen das Literal nicht, und zwei
   Literal-Treffer sind keine Kollisionsstellen. Über einem Gegenstand, den kein Muster
   identifiziert, ist eine geschlossene Zahl der Fehler und die offene Menge die richtige Form —
   dieselbe Konstruktion, die [`AGENTS.md`](../../AGENTS.md) §3.7 für sich selbst wählt.

**Warum INFO-1 dieser Runde den Übergang nicht hält, in der vom Auftrag verlangten Unterscheidung.**
Er liegt **nicht** in der Wahrheit: Keine Aussage der Datei ist unzutreffend, das abgedruckte
Kommando liefert über diesem Baum genau die Zahl, die daneben steht. Er liegt **nicht** im
Argument: Keine der vier Festlegungen und keine ihrer Begründungen hängt an ihm. Er liegt in der
**Haltbarkeit** eines Instruments unter einer künftigen Report-Form, die es heute nicht gibt und
die ich nur synthetisch herstellen konnte. Ein Posten, dessen Gegenbeispiel nicht am realen Baum rot
zu sehen ist, ist nach [`AGENTS.md`](../../AGENTS.md) §3.6 eine **benannte Grenze** und keine
gebrochene Zusage — er reist mit.

**Was ich ausdrücklich nicht getan habe.** Ich habe kein Finding herabgestuft, weil dies die
siebte Runde ist. Der Konflikt-Pfad aus
[Modul 8](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md) nennt das
Herabstufen wegen Widerspruchs als den vierten, falschen Pfad; Runden-Müdigkeit wäre dessen
Variante. Ich habe stattdessen die drei Selbstmeldungen des Architect **nicht** übernommen,
sondern nachgefahren — und in zwei Fällen (N-1 zweiter Block, N-2 Vollzählung) über das hinaus,
was er gemeldet hat. Der Grund, warum diese Runde ohne blockierenden Posten schließt, ist nicht
Nachsicht, sondern dass die zwei geänderten Zeilen keinen neuen ungedeckten Satz enthalten.

**Zur Baumlage.** `git log --oneline -1` zu Beginn und am Ende dieses Laufs → beide Male
`4afbde8`; `git status --porcelain` war bis zum Schreiben dieses Reports leer. **Der Prüfgegenstand
war über die Strecke stabil** — eigene Messung, nicht die übernommene Zusage des Auftrags.

**Übergabe.** Der eine INFO geht an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. Er trägt **keine** Kante an den Planner: Die Folgerung aus der Kollision für Schnitt und
Abnahmekriterien von `slice-190` ist als Folgepflicht 4 verdrahtet und bleibt Planner-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.10). Die Zuordnung der Finding-Klassen dieser Rundenreihe zu
einer `BEO-ALL/<slug>` fällt bei der Slice-Closure, nicht hier (§3.10).

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).

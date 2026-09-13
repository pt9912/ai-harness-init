# Review slice-224 — Der Delta-Nachweis `v6.0.0..v6.7.2` und der Planungs-Nachzug

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Commit:** `92c3140b` (4 Dateien, +57/−12) ·
**Plan:** [`slice-224`](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md) ·
**Constraints:** [`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (Festlegung 1 + §Konsequenzen, Vorgabe des Auftraggebers) ·
[`ADR-0043`](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 ·
[`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4 ·
[`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ·
**Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4 · §3.5 · §3.6 · §3.7 · §3.8 · §3.10 ·
**Bezug:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) ·
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
[`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum) ·
[`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) ·
**Vorherige Findings am gleichen Modul:** [`2026-09-12-slice-223-…`](2026-09-12-slice-223-baum-tausch-v672-pins-ziehen.md) MEDIUM-1/MEDIUM-2/INFO-1/INFO-2

Alle Zahlen unten stehen neben dem Kommando, das sie liefert, gefahren über `92c3140b` bzw. im
Kurs-Klon `/Development/KI/ai-harness-course` über die Tags `v6.0.0`/`v6.7.2`. **Keine
Erwartungswerte** — sie wandern mit Baum und Klon.

**Prüfmethode: Stichprobe, ausdrücklich als solche.** Von 42 Posten habe ich **19** am Diff des
Kurs-Klons gegengeprüft (§Was ich nicht geprüft habe nennt die Auswahl und die Lücke). Die
Vollständigkeit der Postenmenge ist dagegen **vollständig** geprüft, nicht stichprobenweise.

---

## Findings

### HIGH-1 — Der Posten, an dem das Delta die Antwort nicht vorgibt, ist als „schon erfüllt" gebucht — und der Beleg zitiert eine Stelle, die derselbe Posten entkräftet

`quelle` [`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen
(*Vorgabe des Auftraggebers … trifft genau **einen** der fünf Ausgänge — „widerspricht"*),
`v6.7.2` · `modul-02-harness-bootstrap.md` §Freshness-Audit (Schritt 2),
[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) ·
`pfad` `docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md:465` ·
`verifizierbar` nein — kein Gate liest den Nachweis; [`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md)
§Fitness Function sagt das selbst (*„Gebaut: keine"*) ·
`klasse` Beleg zitiert eine Stelle, die derselbe Delta-Posten entkräftet

`befund` Die Zeile zu `lab/regelwerk/grundlagen-source-precedence.md` antwortet **schon erfüllt**
und begründet: *„§Vergabe erlaubt Namen **oder** Nummern als Kennung und verlangt nur eine
**Deklaration** im Repo … unser `MR-000` hält bereits an dichten Nummern … fest — das bleibt eine
gültige, bereits getroffene Wahl"*. Die Ziel-Fassung sagt an dieser Stelle etwas anderes:

> **Welle- und Slice-Kennungen sind Namen, nicht Nummern — unabhängig von der Schreiberzahl.**
> (`.harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md:360`)

Der Halbsatz *„unabhängig von der Schreiberzahl"* benennt und verwirft genau den Grund, auf dem
`MR-000` steht. Und der Absatz, der in `v6.0.0` dichte Nummern ausdrücklich lizenzierte — *„Ein
Repo mit einem schreibenden Menschen braucht kein Segment — dichte Nummern sind dort billiger und
lesbarer"* —, ist **von diesem Posten gelöscht** worden; stehen geblieben ist allein der nackte
Einzeiler *„Welche Form gilt, deklariert das Repo"*, der in der neuen Fassung hinter dem
Bereichssegment-Absatz für ADR/Carveout steht. Der Beleg liest die überlebende Zeile als Lizenz und
nennt die gestrichene nicht.

Das ist nicht ein Posten unter 42. **23 der 42 Posten sind Folgeerscheinungen genau dieser Regel** —
sie tragen die neue Kennungs-Form ein:

```sh
cd /Development/KI/ai-harness-course
for f in $(git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/); do
  git diff v6.0.0..v6.7.2 -- "$f" | grep -qE '^\+.*(<Kennung>|slice-kennung|Namen, nicht Nummern)' && echo "$f"
done | wc -l          # 23
git show v6.7.2:lab/templates/docs/plan/planning/observation.template.md | tail -2
#   Der Dateiname **ist** die Kennung: `slice-audit-log-hardening.md`, nicht `beleg-3.md`.
```

Der Nachweis behandelt alle 23 als **Platzhalter-Kosmetik** (`slice-<NNN>` → `slice-<Kennung>`) und
beantwortet die Regel dahinter mit *schon erfüllt*. Der Nachfolge-Text sagt dagegen dreimal
dasselbe: `grundlagen-traceability.md` — *„Die Kennung **ist** der Dateiname — er löst über
`done/slice-<Kennung>.md` §7 auf, kein Glob mehr nötig"*; `grundlagen-harness-dateien.md` —
`docs/plan/planning/open/<slice-kennung>.md`; `observation.template.md` — das Beispiel oben.

**Failure-Szenario.** Der Ausgang *widerspricht* ist laut
[`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen der einzige,
für den der Auftraggeber vorab entschieden hat, und zwar auf **übernehmen**; der Fall *übernehmen
wollen und noch nicht können* ist dort ausdrücklich ein **Carveout mit Auflösungs-Trigger**, keine
Adaption. Als *schon erfüllt* gebucht, fällt der Posten durch beide Netze: Er ist nicht hier
vollzogen, er ist an niemanden übergeben, und er ist auch in
[slice-225](../plan/planning/in-progress/slice-225-gate-index-steht-einmal.md) nicht erreichbar — dessen
Liefer-Punkt 3 filtert die Adaptions-Einträge nach ihrem Auflösungs-Trigger, und `MR-000` trägt
`permanent`:

```sh
cd /Development/KI/ai-harness-init
for f in harness/conventions/MR-*.md; do
  awk '/^- \*\*Auflösungs-Trigger:\*\*/{p=1} p{print} p&&/^- \*\*(Datum|Wirksamkeits-Anlass|Geltungsbereich|Ersetzt)/&&!/Auflösungs/{exit}' "$f" \
    | grep -qiE 'baseline|regelwerk|kurs-|upstream|adoptiert|Ziel-Fassung' && basename "$f"
done | grep -c MR-000        # 0 — MR-000 liegt ausserhalb der 21 Kandidaten
```

Dabei sagt das Freshness-Audit der regierenden Fassung ausdrücklich: *„**Auch `permanent`-Einträge
werden mitgeprüft:** *permanent* heißt ‚kein automatischer Auflösungs-Trigger', nicht
‚unauflösbar'."*

**Was hier nicht behauptet wird:** dass die Umbenennung aller Slices und Wellen in diesem Slice
stattfinden müsste. Der Befund ist, dass die **Entscheidung** nicht gefallen ist — weder
*übernommen*, noch Carveout, noch Meldung an den Auftraggeber, die der Plan-Kopf für genau diese
Lage vorsieht.

---

### MEDIUM-1 — Das Beleg-Kommando, auf das zehn Zeilen sich stützen, kann die Behauptung nicht widerlegen

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Ein Test, dessen Name eine Eigenschaft behauptet,
muss die Eigenschaft messen"*) · `pfad`
`docs/plan/planning/in-progress/slice-224-…md:459` (Definition des Kommandos), `:460`, `:463`,
`:468`, `:472`, `:475`, `:476`, `:478`, `:480` (*„dieselbe Prüfung"*) ·
`verifizierbar` ja, ohne Gate: die zwei Kommandos unten ·
`klasse` Beleg-Kommando misst nicht die behauptete Eigenschaft

`befund` Zehn Zeilen antworten *schon erfüllt* mit der Begründung *„ausschließlich
Tabellen-Reformatierung, keine Inhaltsänderung"* und stützen sich auf das in `:459` ausgeschriebene
Kommando `… | grep -E '^[+-][^+-]' | grep -vE '^[+-]\|'`. Dieses Kommando hat zwei Blindstellen,
die der geprüfte Korpus flächendeckend trifft: Es **filtert Tabellenzeilen ausdrücklich heraus**
(zweiter `grep -v`), sieht also keine geänderte oder **neu hinzugefügte** Tabellenzeile; und sein
`^[+-][^+-]` trifft keine Markdown-Listenzeile, weil deren zweites Zeichen wieder `-` ist.

Beides schlägt real durch:

```sh
cd /Development/KI/ai-harness-course
# behauptet: "keine Inhaltsänderung" — gemessen mit dem Beleg-Kommando:
git diff v6.0.0..v6.7.2 -- lab/regelwerk/grundlagen-begriffe.md \
  | grep -E '^[+-][^+-]' | grep -vE '^[+-]\|' | wc -l                       # 0
# gemessen nach Whitespace-Normalisierung, also gegen die Behauptung selbst:
diff <(git show v6.0.0:lab/regelwerk/grundlagen-begriffe.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
     <(git show v6.7.2:lab/regelwerk/grundlagen-begriffe.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
  | grep -c '^>'                                                            # 3
```

Die drei sind **neue Glossar-Einträge**: `Plan (vor Code)`, `RTM` und
`harness/sensors/<target>.md`. Die Zeile sagt *„ausschließlich Markdown-Tabellen-Reformatierung
(Spaltenbreiten), keine Inhaltsänderung"* — das ist beobachtbar falsch.

Zweite Blindstelle, gemessen:

```sh
git diff v6.0.0..v6.7.2 -- lab/regelwerk/modul-16-produktiver-betrieb.md \
  | grep -E '^[+-][^+-]' | grep -vE '^[+-]\|' | wc -l                       # 0
git diff v6.0.0..v6.7.2 -- lab/regelwerk/modul-16-produktiver-betrieb.md \
  | grep -cE '^[+-]- \*\*Freigabe-Eintrag'                                  # 2
```

`modul-16` ist als *„ausschließlich Tabellen-Reformatierung"* gebucht; geändert wurde eine
**Listenzeile** (`done/welle-NN-closure.md` → `done/welle-<Kennung>-closure.md`) — kein Tabellenrest
im Spiel. Dasselbe bei `modul-08-agentenrollen.md`, wo die zwei geänderten Zellen ebenfalls die
Kennungs-Notation tragen, also genau den Gegenstand dieses Slice.

**Failure-Szenario.** Die Antwort *schon erfüllt* ist die einzige der zwei, die keinen Empfänger
erzeugt. Ein Posten, dessen Inhaltsänderung das Beleg-Kommando strukturell nicht sehen kann, wird
mit einem grünen Kommando zugedeckt — die Form, die
[`AGENTS.md`](../../AGENTS.md) §3.6 als *stilles Grün* führt, eine Ebene unter dem Gate.

**Kontext-Eskalation:** dritte Instanz derselben Klasse in diesem Lauf (`grundlagen-begriffe`,
`modul-08`, `modul-16`) — nach `.harness/skills/reviewer.md` §Kontext-Eskalation ein
Steering-Loop-Signal, nicht nur eine Meldung.

---

### MEDIUM-2 — Der größte Zuwachs des Postens `grundlagen-traceability.md` hat keinen Beleg, und der Glossar-Eintrag derselben Sache wird als „keine Inhaltsänderung" verneint

`quelle` [`slice-224`](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md)
§2 Liefer-Punkt 1 (*„tragen je eine der zwei Antworten … mit Beleg"*) ·
`pfad` `docs/plan/planning/in-progress/slice-224-…md:466` und `:459` ·
`verifizierbar` nein · `klasse` Datei-granulare Antwort verdeckt einen Teil-Posten

`befund` Die Zeile zu `grundlagen-traceability.md` antwortet **übernommen** und belegt
ausschließlich die Herkunfts-Anker-**Notation** in zwei Dateien. Der Posten trägt **62** Plus-Zeilen
(`git diff v6.0.0..v6.7.2 -- lab/regelwerk/grundlagen-traceability.md | grep -cE '^\+'`), und die
Mehrzahl davon ist eine **neue Sektion** `#### Die zweite Richtung: Anforderung → Beleg` (RTM) mit
einer eigenen Setzungspflicht: *„Was eine Anforderung entlastet, ist eine Setzung — und sie gehört
aufgeschrieben … Ein Repo, das das anders schneidet …, trifft eine legitime andere Wahl und
**deklariert sie**, wie jede Abweichung von der Baseline."* Weder die Sektion noch die Frage, ob
dieses Repo eine solche Deklaration braucht, kommt im Nachweis vor.

Verschärfend: Derselbe Gegenstand taucht als **zweiter** Posten auf — der neue Glossar-Eintrag
`RTM` in `grundlagen-begriffe.md` —, und dort verneint der Beleg jede Inhaltsänderung (MEDIUM-1).
Die einzige Stelle, an der die Sektion hätte auffallen müssen, und die einzige, an der ihr
Glossar-Eintrag hätte auffallen müssen, decken sich gegenseitig zu.

---

### MEDIUM-3 — DoD-2 sagt eine Leere zu, die ihr eigenes Kommando nicht liefert (Punkt 3 der Anfrage)

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.6 · `pfad`
`docs/plan/planning/in-progress/slice-224-…md:208-217` · `verifizierbar` ja, ohne Gate ·
`klasse` Zusage nennt einen Prüfbereich, den ihr eigenes Kommando nicht schneidet

`befund` DoD-2 sagt zu: *„nach dem Lauf liefert [das Kommando] **nur noch Treffer in
`implement-slice.md`**"*. Wörtlich gefahren über `92c3140b`:

```sh
cd /Development/KI/ai-harness-init
git grep -nE 'slice-<NNN>|welle-<NN>' -- docs/plan/planning .claude/commands ':!docs/plan/planning/done' | wc -l   # 15
git grep -lE 'slice-<NNN>|welle-<NN>' -- docs/plan/planning .claude/commands ':!docs/plan/planning/done' | wc -l   # 3
```

**15 Treffer in 3 Dateien** — `implement-slice.md` (3, zugesagt) sowie die Plandateien von
slice-224 (10) und slice-225 (2).

**Urteil, ausdrücklich:** Das ist **keine legitime Ausnahme, sondern eine zu weite Zusage** — und
zusätzlich eine Mess-Schwäche. Zwei Gründe, und der erste allein trägt:

1. **Eine Ausnahme, die niemand erklärt hat, ist keine.** Der Prüfbereich in DoD-2 ist
   aufgezählt und nennt die zwei Plandateien nicht als ausgenommen; das Kommando darunter nennt
   sie ebenfalls nicht. Eine legitime Ausnahme hätte die Form *„ausgenommen die Pläne, die die
   Umstellung beschreiben"* — sie steht nirgends. Was ohne sie bleibt, ist eine Zusage, deren
   eigenes Kommando sie widerlegt.
2. **Das Kommando kann Nennung nicht von Verwendung trennen.** Alle 12 zusätzlichen Treffer sind
   **Erwähnungen** der alten Form (in `git grep`-Kommandos, in „alte Form → neue Form"-Sätzen, in
   Beleg-Zellen), keine Verwendungen als Platzhalter. Ein `grep` auf ein Muster, über einen
   Bereich, der die Dokumente der Umstellung enthält, misst das nie.

**Was daraus nicht folgt:** dass der Nachzug fehlt. Die Sach-Zusage ist erfüllt — die §9-Zeile zu
`grundlagen-traceability.md` behauptet die **engere**, wahre Aussage (*„zeigt beide Dateien danach
nicht mehr"*), und die stimmt. Falsch ist allein die DoD-Formulierung. Ihre Korrektur ist
Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10: die ausführende Rolle schreibt ihr eigenes
Abnahmekriterium nicht um) — der Lauf hat richtig gehandelt, indem er sie stehen ließ und meldete.

---

### MEDIUM-4 — Die emittierte Ebene wird mit Schicht-Abgrenzung ausgeschlossen, aber mit drei Adressen dekoriert, die den Gegenstand je ausschließen

`quelle` Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice (*„Die Adresse muss die
Sendung annehmen: Ein Folge-Slice, der den verwiesenen Punkt selbst ausschließt …, ist keine"*) ·
`pfad` `docs/plan/planning/in-progress/slice-224-…md:163-174` ·
`verifizierbar` ja, ohne Gate · `klasse` genannte Adresse nimmt die Sendung nicht an

`befund` Der §1-Ausschluss nennt die **6** gemessenen Vorkommen der alten Notation unter
`internal/emit/templates/commands/` und schreibt daneben, slice-210/211/212 *„liegen dafür in
`open/`"*. Keiner der drei hat diesen Gegenstand: slice-210 und slice-211 entscheiden über die
Modul-Zusammensetzung des **emittierten Doc-Gates** (`planning`, `codepaths`), slice-212 über einen
Adaptions-Eintrag zur Modul-Aktivierung — und schließt die Sache wörtlich aus:

```sh
cd /Development/KI/ai-harness-init
git grep -cE 'slice-<NNN>|welle-<NN>' -- internal/emit/templates       # commands/close-welle.md:2, commands/implement-slice.md:4
grep -n 'Kein Nachzug der emittierten Startkonfiguration' docs/plan/planning/open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md   # 112
git grep -clE 'slice-<NNN>|welle-<NN>|Kennungs-Notation' -- docs/plan/planning/open/slice-21[012]-*.md   # 0
```

Die gewählte Ausschluss-Klasse — *Schicht-Abgrenzung* — braucht keine Kennung und trägt für sich.
Der Defekt ist die Kombination: Drei Kennungen stehen im selben Satz und lesen sich als Adresse.
**Failure-Szenario:** Der nächste Lauf liest *„liegen dafür in `open/`"*, öffnet die drei, findet
nichts zur Notation, und die 6 Vorkommen reisen in jedes gebootstrappte Zielrepo — die
`implement-slice.md`, die ein Adopter bekommt, führt dann eine Notation, die die Baseline
zurückgezogen hat.

---

### MEDIUM-5 — Die Sendung an die Implementer-Rolle hat keinen terminierten Träger, und die an die Reviewer-Rolle erzeugt §9 gar nicht

`quelle` Baseline-Regelwerk `modul-08-agentenrollen.md` §Die neun Übergaben und ihre Artefakte
(*„Ohne jedes dieser Artefakte gibt es keinen Rollenwechsel"*),
[`slice-224`](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md) §2
Liefer-Punkt 3 · `pfad` `docs/plan/planning/in-progress/slice-224-…md:218-228` gegen `:473`, `:474` ·
`verifizierbar` nein · `klasse` Übergabe an eine Rolle ohne terminierten Träger

`befund` Drei Empfänger-Klassen stehen in Liefer-Punkt 3: slice-225, Implementer, Reviewer. Nur die
erste ist ein **Vorgang** — eine Datei in `open/`, die die Sendung in ihrer DoD-2 wörtlich annimmt
(*„jede Zeile des Nachweises mit Ziel `slice-225`"*). Die anderen zwei sind **Rollen**, und eine
Rolle ist keine Warteschlange:

- **Implementer** (`modul-09-implementierung.md`, Zeile `:473`): Das Übergabe-Artefakt ist die
  §9-Zeile selbst. Diese Zeile steht in einem Plan, der bei der Closure zum Zeitdokument wird; nach
  `grundlagen-traceability.md` §Der Fluss *„kommt der Volltext eines geschlossenen Slice in keinem
  lesenden Knoten vor"*. Damit endet die Sendung mit der Closure, ohne dass ein Lauf sie je
  aufnimmt. Für den Architect hat dieselbe Planungsrunde den Träger geschnitten (slice-225); für
  den Implementer nicht.
- **Reviewer:** §9 erzeugt **keine** Zeile mit diesem Empfänger — `modul-10-review-harness.md`
  (`:474`) steht auf *schon erfüllt · slice-224*. Liefer-Punkt 3 behauptet eine Sendung, die der
  Nachweis nicht produziert.

Die zweite Hälfte hat einen konkreten, heute wirksamen Ausgang: Der Review-Report zu slice-223 hat
den Posten ausdrücklich hierher adressiert (*„Der Posten liegt bei slice-224, das … diese Datei
ausdrücklich führt"*, INFO-2), und §1 dieses Plans schließt Schreibzugriff auf
`.harness/skills/reviewer.md` aus, während §9 keinen Empfänger nennt. Der Kopf des Skills steht
damit weiter auf einem Tag, den der Checkout nicht führt:

```sh
cd /Development/KI/ai-harness-init
grep -n '^\*\*Version:\*\*\|Baseline:' .harness/skills/reviewer.md | head -2   # "Baseline: … v6.0.0 (Kurs-Welle 116)"
ls .harness/baseline/                                                          # v6.7.2
```

**Failure-Szenario, real eingetreten:** Dieser Review-Lauf liest seine eigene Urteilsgrundlage als
*gegen `v6.0.0` gemessen* und findet den Baum nicht, gegen den sie gemessen wurde. Dieselbe Klasse
steht in `docs/user/benutzerhandbuch.md:174` (*„Baseline v6.0.0 vendored"*) — beide sind
[`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)-Fälle
ohne einen der drei Ausgänge.

---

### LOW-1 — Der Kopf erklärt die Antwort-Menge für geschlossen, die Tabelle führt vier Werte

`quelle` [`slice-224`](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md)
Kopf (*„Je Delta-Posten gibt es faktisch **zwei** Antworten"*) · `pfad`
`docs/plan/planning/in-progress/slice-224-…md:456-499` · `verifizierbar` ja · `klasse` geschlossene
Menge im Kopf, offene Menge in der Tabelle

`befund`

```sh
cd /Development/KI/ai-harness-init
sed -n '/^| Posten (Datei im Kurs-Klon)/,$p' docs/plan/planning/in-progress/slice-224-*.md \
  | grep -E '^\| `lab/' | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//' | sort | uniq -c
#   30 schon erfüllt · 10 übernommen · 1 übernommen (teilweise) · 1 übernommen (Übergabe)
```

Die zwei Zusätze sind lesbar und nützlich, aber sie sind nicht die zwei Werte, die der Kopf
deklariert. Bei `übernommen (teilweise)` (`grundlagen-harness-dateien.md`) trägt die Zeile zudem
nur einen Beleg für den **offenen** Teil; welche Hälfte *erfüllt* ist und wodurch, steht als
Aufzählung ohne eigene Antwort daneben. (Die dem Reviewer genannte Verteilung *32 × schon erfüllt /
10 × übernommen* trifft damit nicht zu; es sind **30/12**, davon **8** Übergaben, nicht 6.)

---

### LOW-2 — Zwischen §1 und DoD-2 von slice-225 läuft eine Naht, durch die die „Grenzen-Pflicht je Gate" fällt

`quelle` Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice · `pfad`
`docs/plan/planning/in-progress/slice-224-…md:477` gegen
`docs/plan/planning/in-progress/slice-225-gate-index-steht-einmal.md` §1 · `verifizierbar` nein ·
`klasse` Adresse nimmt an einer Stelle an und schließt an einer anderen aus

`befund` Die §9-Zeile zu `modul-13-quality-gates.md` nennt als Inhalt der Sendung unter anderem die
**Grenzen-Pflicht je Gate** (*„Ein Gate ohne seine Grenze behauptet ebenfalls zu viel … mit dem
Kommando, das den Ausschnitt zeigt, nicht mit einer eingefrorenen Zahl"*). Deren Bestand sind die
**15** Dateien unter `harness/sensors/` (`ls harness/sensors/*.md | wc -l`). §1 von slice-225
schließt jeden Posten aus, der außerhalb von `AGENTS.md`, `harness/README.md`, `.d-check.yml` und
`harness/conventions/` landet; DoD-2 desselben Plans nimmt ihn wieder auf (*„Die Liste in diesem
Plan ist nicht die Grenze — die Grenze ist §9 von slice-224"*). Die Adresse nimmt an — aber nur,
wenn man DoD-2 gegen §1 liest. Der Befund liegt an slice-225 und ist dort noch änderbar (`open/`).

---

### INFO-1 — 50 von 69 lebenden Slice-Plänen tragen die alte §1/§8-Gliederung; die Zeile belegt das richtige Ergebnis mit dem falschen Grund

`quelle` [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) ·
`pfad` `docs/plan/planning/in-progress/slice-224-…md:493` · `verifizierbar` ja · `klasse`
Stellen-Messung (n = 1) als Aussage über eine Menge

`befund` Die Zeile zu `slice.template.md` antwortet *schon erfüllt*, weil §1/§8 *„in **diesem
eigenen Slice-Plan** bereits verkörpert"* seien. Das ist eine Messung an **einer** Datei:

```sh
cd /Development/KI/ai-harness-init
grep -rhE '^## 1\. ' docs/plan/planning/{open,next,in-progress} | sort | uniq -c   # 50 "## 1. Ziel" · 19 "## 1. Ziel und Abgrenzung"
grep -rhE '^## 8\. ' docs/plan/planning/{open,next,in-progress} | sort | uniq -c   # 50 alt · 19 neu
```

Die **Antwort** ist trotzdem richtig, nur aus einem anderen Grund: Das Freshness-Audit der
regierenden Fassung sagt für wiederkehrende Templates *„Neue Instanzen folgen der neuen Form,
bestehende werden nicht rückwirkend umgeschrieben"*. Genannt ist dieser Grund nicht — und ohne ihn
liest der nächste Lauf eine Bestands-Aussage, die der Bestand mit 50 : 19 widerlegt.

---

## Negativbefunde (geprüft, ohne Befund)

- **Vollständigkeit der Postenmenge** — die 42 Tabellenzeilen sind die 42 Dateien des Deltas, in
  identischer Reihenfolge, keine erfunden, keine fehlend:
  `diff <(cd /Development/KI/ai-harness-course && git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/) <(sed -n '/^| Posten/,$p' docs/plan/planning/in-progress/slice-224-*.md | grep -E '^\| `lab/' | sed -E 's/^\| `([^`]+)`.*/\1/')`
  → leer, EXIT 0.
- **Die drei geänderten Nicht-Plan-Dateien** (`observations/README.md`, `welle-13-…md`,
  `close-welle.md`) — je eine reine Notations-Ersetzung `<NN>`/`<NNN>` → `<Kennung>`, kein
  Sinnverlust, kein abgebrochener Satz, keine Chronik in einem Zustandsfeld
  ([`AGENTS.md`](../../AGENTS.md) §3.7 geprüft, sauber).
- **Kein `AGENTS.md`, kein `.d-check.yml`, kein `harness/conventions*`, keine ADR im Diff** —
  [`AGENTS.md`](../../AGENTS.md) §3.8 und §3.4 sind eingehalten; `git show --stat 92c3140b`
  zeigt vier Dateien, alle in Planner-/Implementer-Eigentum. Der Commit nennt die Rolle und trägt
  die Traceability-Kennung `slice-224`.
- **Kein Produkt-Code, keine emittierte Vorlage im Diff** — die Schicht-Abgrenzung aus §1 ist
  eingehalten.
- **Belege, die ich nachgefahren habe und die tragen:** `modul-07-carveouts` (`grep -n 'CO-[0-9]'
  harness/README.md` → leer) · `gate.template.md` (15 Sensor-Dateien, **jede** mit Index-Zeile in
  `harness/README.md`; Sektionsfolge Vertrag/Grenze/[Ausgabe]/[Sperren]/Bindung deckt sich mit der
  Vorlage) · `lab/templates/Makefile` (`grep -n 'Targets in AGENTS.md' Makefile` → leer) ·
  `reconciliation.template.md` (Datei existiert nicht) · `archiv-stub-*.template.md` (kein
  archivierter Stub) · `roadmap.template.md` (Platzhalter-Reste in `roadmap.md` → leer) ·
  `README.template.md` (planning) (`done/<welle-id>-results.md`, kein `NN`) ·
  `carveouts/*.template.md` (keine Platzhalter-Form im Bestand) · `lab/regelwerk/README.md`
  (`harness/conventions.md` §Baseline nennt tatsächlich `Kurs-Welle 134 · 2026-09-12`, und
  `sed -n '3p' .harness/baseline/v6.7.2/regelwerk/README.md` bestätigt es).
- **Die reinen Reformatierungs-Behauptungen, soweit sie tragen:** für `grundlagen-bootstrap`,
  `grundlagen-klassifikation`, `modul-04`, `modul-11`, `modul-12`, `modul-14` und
  `grundlagen-durchsetzungsschicht` ist der whitespace-normalisierte Diff **leer** — dort stimmt
  *„keine Inhaltsänderung"* auch gegen die schärfere Messung (Kommando siehe MEDIUM-1, `grep -c
  '^>'` bzw. `wc -l` → 0).
- **Die Sendung an slice-225** — sein DoD-2 nimmt jede §9-Zeile mit Ziel `slice-225` ausdrücklich
  an, sein §1 ist der Spiegel dieses §1, und sein DoD-1 nennt genau die `targets.authority`-Frage,
  die die zwei größten Posten (`grundlagen-harness-dateien`, `modul-13`) tragen. Die Adresse nimmt
  die Sendung an (Einschränkung: LOW-2).
- **Die Sendung an slice-213/214** — `review-report.template.md` ist dort Gegenstand; slice-213 §1
  gibt die Kennungs-Notation ausdrücklich an die Adoption der Vorlage ab, und dieser Slice nimmt
  sie an. Beide liegen in `open/`, schließen also nicht vor dem verweisenden Slice. Trägt.
- **Risiken §6 gegen den Ist-Stand** — die fünf Register-Zähler in §6/§8 sind nachgefahren und
  stimmen (3× · 2× · 2× · 2× · 2×, Kommandos stehen im Plan). Die Sichtung nennt 98 Verzeichnisse;
  `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` bestätigt sie.

## Was ich nicht geprüft habe

- **23 der 42 Posten habe ich nicht am Kurs-Diff gegengelesen.** Gegengeprüft sind **19**:
  `grundlagen-begriffe`, `grundlagen-bootstrap`, `grundlagen-durchsetzungsschicht`,
  `grundlagen-harness-dateien`, `grundlagen-klassifikation`, `grundlagen-source-precedence`,
  `grundlagen-traceability`, `modul-04`, `modul-05`, `modul-08`, `modul-09`, `modul-10`, `modul-11`,
  `modul-12`, `modul-13`, `modul-14`, `modul-16`, `roadmap.template.md`,
  `observation.template.md`. Für die übrigen — darunter `.d-check.yml` (+32/−0),
  `AGENTS.template.md` (+15/−20), `harness/README.template.md` (+56/−0),
  `welle-results.template.md` (+21/−13), `slice.template.md` (+60/−19),
  `gate.template.md` (+81/−0) — habe ich nur die **Zuordnung** (`landet in`) gegen §1 des
  Empfängers gehalten, nicht ihren Inhalt gegen unseren Bestand. **Die Stichprobe ist nach
  Änderungsgröße und nach den vier Fragen des Auftrags gewählt, nicht zufällig** — eine
  Verallgemeinerung auf die Komplementärmenge trägt sie nicht.
- **Die `Kurs-Welle`-Spalte** (Spalte 2 aller 42 Zeilen) habe ich nicht gegen `git log` verifiziert.
- **Keine DoD-Abhakung, kein Gate-Lauf.** `make gates` EXIT 0 über `92c3140b` ist mir als gegeben
  übergeben; ich habe es nicht nachgefahren (Verifier-Rolle). Gefahren habe ich ausschließlich
  lesende `git`-, `grep`- und `diff`-Kommandos, keines davon schreibend.
- **Die Stichprobe gegen den Bestand**, die die regierende Fassung als siebte Eigenschaft des
  Freshness-Audits verlangt (*„ein Abschnitt pro Audit, rotierend"*, Komplementärmenge zum Delta),
  habe ich weder gefahren noch im Plan gesucht. Ob sie in diesem Durchgang fällig ist oder
  woanders hängt, ist offen und **kein** Finding dieses Reports.
- **Die 50 Slice-Pläne mit alter §1/§8-Gliederung** habe ich nur gezählt, nicht inhaltlich gegen
  die neue Ziel-Form gehalten (INFO-1).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Beleg zitiert eine Stelle, die derselbe Delta-Posten entkräftet |
| MEDIUM | 5 | Beleg-Kommando misst nicht die behauptete Eigenschaft (3×, Steering-Loop-Signal) · datei-granulare Antwort verdeckt Teil-Posten · Zusage weiter als ihr Kommando · genannte Adresse nimmt die Sendung nicht an · Übergabe an eine Rolle ohne terminierten Träger |
| LOW | 2 | geschlossene Menge im Kopf, offene in der Tabelle · Adresse nimmt an einer Stelle an und schließt an anderer aus |
| INFO | 1 | Stellen-Messung als Aussage über eine Menge |

## Verdikt

**Blockierend — wegen HIGH-1, und nur wegen HIGH-1.**

Der Slice liefert, was er verspricht, in der Form, in der er es verspricht: Die Postenmenge ist
vollständig und deckungsgleich mit dem Delta, die Zuordnungen an slice-225 und slice-213/214 sind
belastbar, der Notations-Nachzug im eigenen Prüfbereich ist sachlich erledigt, und die
Rollen-Grenzen sind eingehalten. Das ist der größere Teil des Ergebnisses.

Blockierend ist der eine Posten, an dem der Nachweis eine **Entscheidung** durch eine **Feststellung**
ersetzt hat. `grundlagen-source-precedence.md` §Vergabe ist genau der Ausgang *widerspricht*, für
den [`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen die Wahl
des Auftraggebers vorab verbucht hat; als *schon erfüllt* gebucht, verlässt er den Prozess ohne
Adresse — und er ist die Regel, aus der 23 der 42 Posten folgen. Er braucht eine der drei Antworten,
die der Plan-Kopf selbst vorsieht: *übernommen* mit Empfänger, Carveout mit Auflösungs-Trigger,
oder Meldung an den Auftraggeber.

**Kein zweiter Durchgang über alles.** Die fünf MEDIUM und die drei LOW/INFO sind Korrekturen an
Belegzellen derselben §9-Tabelle, an einem DoD-Satz und an einem §1-Absatz; sie gehören in
**dieselbe** Runde wie HIGH-1, nicht in eine eigene. Zwei davon liegen ohnehin nicht in diesem
Slice: MEDIUM-3 (DoD-Wortlaut) und LOW-2 (slice-225 §1) sind Planner-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.10), MEDIUM-5 verlangt einen Träger-Schnitt, keinen Text.

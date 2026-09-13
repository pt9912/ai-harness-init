# Verifikation slice-224 — Der Delta-Nachweis `v6.0.0..v6.7.2` und der Planungs-Nachzug

**Rolle:** Verifier · **Datum:** 2026-09-13 · **Geprüfte Commits:** `92c3140b` (Lieferung),
`4a957c0c` (Reviewer, blockierend), `6803ed31` (Review-Nacharbeit) · **Plan:**
[`slice-224`](../plan/planning/in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md) ·
**Review:**
[`2026-09-12-slice-224-…`](2026-09-12-slice-224-delta-nachweis-und-planungs-nachzug.md) (1 HIGH ·
5 MEDIUM · 2 LOW · 1 INFO, Verdikt: blockierend wegen HIGH-1) · **Prüfgegenstand:** DoD und Spec
(ADR-0044, ADR-0043) — **nicht** Plan/Hard Rules, das ist Reviewer-Sache. Fahre `make gates` nicht
erneut; Beleg über den Working-Tree-Hash und `make docs-check` allein.

---

## 0. Vorfrage: ist `make gates` EXIT 0 tatsächlich für `6803ed31` belegt?

Nicht neu gefahren, wie angewiesen. Stattdessen der inhaltsbasierte Nachweis, den der Stop-Hook
selbst verwendet:

```sh
cat .harness/state/gates-passed.diffsha
# -> 3316e55e4e974ae709c422652a2f34a09ac343e09d02135d11b8b3cc96b7b38e
bash harness/tools/working-tree-hash.sh
# -> 3316e55e4e974ae709c422652a2f34a09ac343e09d02135d11b8b3cc96b7b38e
git status -sb   # -> ## main...origin/main [voraus 1]   (clean)
```

Deckungsgleich, Baum sauber, ein Commit vor `origin/main` (`6803ed31`). Der Nachweis gilt für
genau den geprüften Stand. Zusätzlich `make docs-check` (netzlos) selbst gefahren:
`d-check: 1217 Datei(en) geprüft, 0 Befund(e)`.

---

## 1. DoD Punkt für Punkt

### DoD-1 — Delta-Nachweis vollständig, 42 Posten, je eine Antwort mit Beleg

**Erfüllt.**

```sh
cd /Development/KI/ai-harness-course
git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/ | wc -l   # 42
```

```sh
cd /Development/KI/ai-harness-init
diff <(cd /Development/KI/ai-harness-course && git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/) \
     <(sed -n '/^| Posten/,$p' docs/plan/planning/in-progress/slice-224-*.md \
       | grep -E '^\| `lab/' | sed -E 's/^\| `([^`]+)`.*/\1/')
# -> leer, EXIT 0
```

42 Zeilen, 42 verschiedene Dateien, identische Reihenfolge, keine erfunden, keine fehlend — deckt
sich mit dem Negativbefund des Reviewers. Mess-Tags beider Seiten (`v6.0.0`, `v6.7.2`) stehen im
Intro von §9.

### DoD-2 — Lebende Planungs-Artefakte tragen die neue Kennungs-Notation, nur `implement-slice.md` bleibt

**Erfüllt, mit einer bereits vom Reviewer benannten Zusage-Ungenauigkeit (MEDIUM-3), die nicht
diesen Slice betrifft.**

```sh
git grep -nE 'slice-<NNN>|welle-<NN>' -- docs/plan/planning .claude/commands ':!docs/plan/planning/done'
```

Ergebnis: 15 Treffer in 3 Dateien — `implement-slice.md` (3, zugesagt), plus die **Selbst-Zitate**
der Plandateien `slice-224` (10) und `slice-225` (2), die das Muster nur in Kommandos/Beleg-Prosa
nennen, nicht als lebenden Platzhalter verwenden. MEDIUM-3 hat das schon korrekt als
Zusage-Formulierung (nicht Sach-)-Fehler eingeordnet und der Planner-Zuständigkeit zugewiesen
(`AGENTS.md` §3.10) — der Implementer hat richtig gehandelt, indem er die DoD-Formulierung nicht
selbst umgeschrieben hat. Sachlich gilt: außerhalb der zwei Selbstzitate ist der Bestand
notations-rein.

### DoD-3 — Jede Sendung an eine andere Rolle liegt als Übergabe-Artefakt vor

**Erfüllt für die adressierbaren Sendungen; zwei rollen-gerichtete Sendungen bleiben ohne
Träger — korrekt als Risiko geführt, siehe §4 unten.**

- `slice-225` existiert in `open/`, DoD-2 dort nimmt „jede Zeile des Nachweises mit Ziel
  `slice-225`" wörtlich an.
- `slice-213`/`slice-214` existieren in `open/`; slice-213 §1 Punkt 4 gibt die Kennungs-Notation
  ausdrücklich an die Adoption der Vorlage ab (`grep -n 'slice-<Kennung>' docs/plan/planning/open/slice-213-*.md`
  → Zeile 47) — die Adresse nimmt an.
- `slice-210`/`211`/`212` sind aus dem §1-Ausschluss der emittierten Ebene entfernt (MEDIUM-4-Fix);
  keiner der drei führt die Notation wörtlich:
  `git grep -clE 'slice-<NNN>|welle-<NN>|Kennungs-Notation' -- docs/plan/planning/open/slice-21[012]-*.md`
  → leer. Die verbleibende Ausschluss-Klasse *Schicht-Abgrenzung* trägt ohne Adresse — korrekt.
- `Implementer`/`Reviewer`: kein terminierter Träger — siehe Risiken.

### DoD-4 — `make gates` grün

**Erfüllt**, siehe §0.

### DoD-5 — Review durchgeführt, Report liegt vor

**Formal offen — Checkbox korrekt unchecked, und das ist zugleich der wichtigste Befund dieser
Verifikation.** Siehe §3.

### DoD-6 — Doku-Update: kein öffentlicher Vertrag berührt

**Erfüllt, plausibel.** Die Buchung der Nachweis-Kennung in `harness/conventions.md` §Baseline
zeigt bereits `slice-224, ausstehend` für beide offenen Felder (`v6.5.0`, `v6.7.2`):

```sh
grep -n 'Delta-Nachweis' harness/conventions.md
```

Das ist Architect-Eigentum und nicht Gegenstand dieses Slice-Diffs
(`git diff 92c3140b~1..6803ed31 -- harness/conventions.md` → leer) — konsistent mit §1.

### DoD-7 bis DoD-11 — Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge, drei Paarungen

**Korrekt unchecked/offen.** §7 der Plandatei trägt noch Platzhalter (`<…>`), §6 führt jedes Risiko
mit `Ausgang: offen bis zur Closure`. Das ist die richtige Form für einen Slice, der noch in
`in-progress/` liegt (`AGENTS.md` §3.10: Closure ist Planner-Arbeit, nicht Teil dieses Laufs).

---

## 2. Die Summenprobe (29 + 13 = 42)

```sh
sed -n '/^| Posten/,$p' docs/plan/planning/in-progress/slice-224-*.md | grep -E '^\| `lab/' \
  | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//' | sort | uniq -c
```

```
29 schon erfüllt
11 übernommen
 1 übernommen (teilweise)
 1 übernommen (Übergabe)
```

29 + (11+1+1) = 42. **Aufgehende Summe, bestätigt.** Auf Duplikate/Lücken geprüft:

```sh
sed -n '/^| Posten/,$p' docs/plan/planning/in-progress/slice-224-*.md | grep -E '^\| `lab/' \
  | sed -E 's/^\| `([^`]+)`.*/\1/' | sort -u | wc -l   # 42 (== Zeilenzahl, keine Duplikate)
```

**„landet in"-Verteilung**, robust extrahiert (das naive `awk -F'|'` bricht an Zeilen mit
eingebetteten `|` in Beleg-Zellen — selbst ein kleiner Beleg dafür, wie leicht ein blindes Kommando
danebenliegt):

```
33 slice-224
 7 slice-225
 1 slice-213/slice-214
 1 Implementer (Übergabe)
```

9 Nicht-`slice-224`-Zeilen, 33+9=42 — deckt sich mit der im Plan behaupteten Neuzählung (9 statt
der dem Reviewer ursprünglich genannten 6). Kein Wert „Reviewer" kommt in der `landet in`-Spalte
vor — konsistent mit MEDIUM-5s Befund, dass §9 dafür keine Zeile erzeugt.

---

## 3. Stichprobe auf die neu belegten Zeilen (mindestens drei verlangt, neun gefahren)

Alle sechs im Nacharbeit-Text genannten Korrektur-/Bestätigungs-Messungen unabhängig
nachgefahren, plus HIGH-1 und die RTM-Zeile:

| Datei | Behauptung im Plan | Eigene Messung | Ergebnis |
|---|---|---|---|
| `grundlagen-begriffe.md` | 3 neue Zeilen (nicht 0) | `diff` whitespace-normalisiert | **3**, exakt die genannten drei Glossareinträge (`Plan (vor Code)`, `RTM`, `harness/sensors/<target>.md`) |
| `modul-08-agentenrollen.md` | 4 (nicht 0) | dieselbe Methode | **4** |
| `modul-16-produktiver-betrieb.md` | 2 (nicht 0) | dieselbe Methode | **2** |
| `grundlagen-bootstrap.md` | 0 (reine Reformatierung, bestätigt) | dieselbe Methode | **0** |
| `modul-11-verification.md`, `modul-14-docker-harness.md`, `grundlagen-klassifikation.md`, `modul-04-adrs.md`, `modul-12-replay-evaluierung.md`, `grundlagen-durchsetzungsschicht.md` | je 0 | dieselbe Methode | je **0** |
| `grundlagen-source-precedence.md` (HIGH-1) | Zeile 360 v6.7.2 sagt „Namen, nicht Nummern — unabhängig von der Schreiberzahl", der lizenzierende Absatz aus `v6.0.0` ist gestrichen | `git show v6.7.2:…:355-365`, `git show v6.0.0:… \| grep -B2 -A2 'Ein Repo mit einem schreibenden'` | **Zitat exakt bestätigt**; der v6.0.0-Absatz existiert wörtlich, in v6.7.2 fehlt er vollständig |
| `grundlagen-traceability.md` | 62 Plus-Zeilen | `git diff … \| grep -cE '^\+'` | **62** |
| Vollständigkeits-Diff (Negativbefund Reviewer) | 42 Dateien deckungsgleich | eigener `diff` | **leer, EXIT 0** |

**Neun von neun Messungen decken sich exakt mit der Tabelle.** Kein einziger nachgefahrener Beleg
wich vom behaupteten Wert ab — inklusive des kritischen HIGH-1-Zitats, das der Reviewer als
entkräftend gegen die ursprüngliche „schon erfüllt"-Antwort identifiziert hatte.

**Nicht geprüft** (Stichprobe, ausdrücklich benannt): die übrigen 33 der 42 Posten wurden nicht
einzeln am Kurs-Diff gegengelesen — insbesondere nicht die reinen `landet in: slice-225`-Zeilen mit
großem Zeilen-Delta (`AGENTS.template.md`, `harness/README.template.md`, `slice.template.md`,
`gate.template.md`, `.d-check.yml`), deren inhaltliche Prüfung ohnehin bei slice-225 liegt und
nicht Gegenstand dieses Slice ist. Die Zuordnungs-Deckung (Empfänger nimmt an) für diese Fälle ist
in §1 oben geprüft, ihr Inhalt gegen den Bestand nicht.

---

## 4. Die neun „landet in"-Zeilen — nehmen die Empfänger an?

| Empfänger | Nimmt an? | Beleg |
|---|---|---|
| `slice-225` (7 Zeilen) | **Ja** | DoD-2 dort: „jede Zeile des Nachweises mit Ziel `slice-225`" |
| `slice-213/slice-214` (1 Zeile) | **Ja** | slice-213 §1 Punkt 4 nennt die Kennungs-Notation ausdrücklich als übernommenen Gegenstand |
| `Implementer` (Übergabe, 1 Zeile, `modul-09-implementierung.md`) | **Nein — kein Träger** | Sendung endet mit der Slice-Closure (Zeitdokument, kein lesender Knoten liest den Volltext danach); als Risiko in §6 korrekt geführt |
| `Reviewer` (0 Zeilen, aber in §1/§3 als Sendung genannt) | **Nein — nicht einmal erzeugt** | §9 produziert keine Zeile mit diesem Ziel; als Risiko in §6 korrekt geführt |

**Ist das §6-Risiko sauber formuliert oder verdeckt es eine fällige Lieferung?** Gelesen: sauber
formuliert. Der Text benennt beide Fälle einzeln, nennt den genauen Mechanismus (Zeitdokument ohne
lesenden Knoten; §9 erzeugt keine Zeile), verweist auf `AGENTS.md` §3.10 (Träger-Schnitt ist
Planner-Arbeit) und schließt mit `Ausgang: offen bis zur Closure` — keine verdeckte
Selbst-Entlastung, sondern eine explizite Weitergabe an die Rolle, die laut Hard Rule dafür
zuständig ist. Der Implementer hat hier korrekt **nicht** versucht, selbst einen Folge-Slice zu
schneiden.

---

## 5. ADR-Konformität

**ADR-0044** (`Accepted`) — Festlegung 1 (Prozedur der Ziel-Fassung `v6.7.2` regiert) und
Festlegung 2 (Delta-Basis bleibt `v6.0.0`, unverändert von ADR-0043 gelesen) sind beide korrekt
angewandt: Der Nachweis misst `v6.0.0..v6.7.2`, wie in §Konsequenzen der ADR angeordnet, und die
Kennung des Slice ist der Wert beider offenen Nachweis-Felder (`v6.5.0` und `v6.7.2` in
`harness/conventions.md` §Baseline) — genau die Anordnung aus ADR-0044 §Konsequenzen
„Folgepflicht (Planner) … seine Kennung ist der Wert beider offenen Nachweis-Felder".

**ADR-0043** Festlegung 2 (nicht abgelöst) — die Leseregel „Basis ist der letzte Stand, für den
§Baseline einen Slice mit Delta-Nachweis ausweist" ist korrekt befolgt: `v6.0.0` ist tatsächlich
dieser letzte Stand (`grep -o '\*\*auf `v[0-9.]*`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md`
zeigt `v6.0.0` als letzten mit echtem Nachweis, `v5.18.0` davor).

**Ein Punkt verdient Erwähnung, ohne ADR-Verstoß zu sein:** ADR-0044 §Konsequenzen (nicht in
diesem Read vollständig zitiert, aber im Slice-Kopf referenziert) benennt den *Delegat*, der die
Kennungs-Notation als „Regeländerung selbst, keine Rauschklasse" führt — genau die Stelle, die als
HIGH-1 auffiel. Die Nacharbeit hat diesen Punkt korrekt aufgenommen; die ADR selbst wird durch
diesen Slice nicht angetastet.

---

## 6. Plan-vs-Code in beide Richtungen

**Plan → Code:** Alle drei Liefer-Punkte sind im Diff nachweisbar. §9 (42 Zeilen) ist neu
(`92c3140b`, `6803ed31`), die drei Notations-Fixes (`observations/README.md`, `welle-13-…md`,
`close-welle.md`) sind exakt die in §3 der Plandatei genannten drei Dateien — kein viertes
Artefakt wurde angefasst, keines der in §1 ausgeschlossenen berührt.

**Code → Plan (das Gebaute-aber-nicht-Geplante):** Geprüft, ob `92c3140b`/`6803ed31` etwas
verändert haben, das §3 nicht nennt:

```sh
git show --stat 92c3140b
git show --stat 6803ed31
```

Vier bzw. eine Datei, beide Male deckungsgleich mit der §3-Tabelle (die Plandatei selbst zählt
nicht als „Artefakt", sondern ist der Liefergegenstand von §9). Kein Fund einer unangekündigten
Nebenwirkung — kein `AGENTS.md`, kein `.d-check.yml`, kein `harness/conventions*`, keine ADR im
Diff (bestätigt schon vom Reviewer als Negativbefund, hier für `6803ed31` erneut geprüft: nur die
Plandatei selbst geändert).

---

## 7. Risiko-Lage (§6) — hat jedes Risiko einen Ausgang, oder stünde die Closure vor einem ohne?

Alle sechs Risiken tragen `Ausgang: offen bis zur Closure` — für einen Slice in `in-progress/` ist
das der korrekte Zwischenstand, kein Verstoß gegen „kein Slice geht nach `done/`, während eines
ohne Ausgang dasteht" (dieser Slice geht noch nicht nach `done/`).

**Ein Befund an der Substanz eines Risikos, unabhängig vom Ausgangs-Status:** Der Zähler für
`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` wird im Plan als **3×** geführt (§6 und
§8), mit dem Kommando `ls .../evidence/*.md | wc -l` als Beleg-Muster. Selbst gefahren:

```sh
ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l
# -> 4
```

**Vier, nicht drei.** Der vierte Beleg (`slice-223.md`) wurde am 2026-09-12 22:01:57 committet
(`1e0f5b48`, slice-223s eigene Closure) — **vor** der Beanspruchung von slice-224 (22:07:14,
`d0334dc6`) und lange vor der Nachweis-Arbeit (22:29:31, `92c3140b`). Der Zähler stand also bereits
bei 4×, als die Zeile geschrieben wurde; „3×" ist keine Momentaufnahme, die seither überholt wurde,
sondern war bei Entstehung schon falsch. Die Schlussfolgerung „über der Schwelle" bleibt richtig
(4 > 3 ebenso wie 3 > 3 knapp), aber die Zahl selbst ist ein Beleg-Fehler nach `AGENTS.md` §3.6/
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert):
Das im Text genannte Kommando liefert nicht den im Text stehenden Wert. Die übrigen fünf
Register-Zähler in §6/§8 (`re-baseline-ohne-inventur-slice`, `byte-gleichheit-…`,
`slice-plan-umfang-…`, `uebergabe-an-andere-rolle-…`, `baseline-aussage-ohne-mess-tag`) sind alle
mit **2×** exakt bestätigt.

Dieser Befund ändert nichts an den Antworten der 42-Zeilen-Tabelle und blockiert die drei
Liefer-Punkte nicht — er betrifft ausschließlich den §6/§8-Zähler-Stand und sollte bei der Closure
(oder vorher, per Korrektur-Commit) auf **4×** gezogen werden, weil die Zahl im Text neben ihrem
eigenen Kommando steht und dieses Kommando etwas anderes ausgibt.

---

## 8. Der zentrale Befund dieser Verifikation: der Review-Report ist nicht aktualisiert

Der Closure-Trigger (§5 der Plandatei) verlangt zwei beobachtbare Kriterien, das zweite lautet
wörtlich: *„Der Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt keinen
blockierenden Befund."*

Der einzige vorliegende Review-Report
(`docs/reviews/2026-09-12-slice-224-delta-nachweis-und-planungs-nachzug.md`) schließt mit:

> **Blockierend — wegen HIGH-1, und nur wegen HIGH-1.**

Dieser Report ist seit seiner Erstellung **nicht** verändert oder durch eine zweite Runde ersetzt
worden — die Nacharbeit (`6803ed31`) ändert ausschließlich die Plandatei, nicht den Report:

```sh
ls docs/reviews/ | grep -c 224   # 1 — genau eine Review-Datei zu diesem Slice
git log --oneline -- docs/reviews/2026-09-12-slice-224-*.md   # ein einziger Commit (4a957c0c)
```

Ich habe die inhaltliche Behebung von HIGH-1 selbst nachgefahren (§3 oben, Zeile
`grundlagen-source-precedence.md`) und sie **stimmt sachlich**: Die Ziel-Fassung sagt exakt, was
der Nacharbeits-Text zitiert, der lizenzierende Absatz ist exakt gestrichen, und die Umbuchung auf
*übernommen* mit Empfänger `slice-225` und der referenzierten Auftraggeber-Entscheidung ist in
sich stimmig. **Das ist aber eine Sach-Prüfung, keine Rollen-Bestätigung.** Nach `modul-08` prüft
*„Reviewer prüft auf Konsistenz"* — eine Selbstauflösung eines HIGH durch dieselbe Rolle, die ihn
verursacht hat, ohne dass die Rolle, die ihn erhoben hat, die Auflösung bestätigt, ist strukturell
dieselbe Lücke, die `AGENTS.md` §3.6 als *„Behauptung ohne Bestätigung"* fasst — hier nicht bei
einer Test-Zusage, sondern beim Review-Verdikt selbst. Andere Vorgänge in diesem Repo (z. B. der
Accept-Übergang von ADR-0043, der ausdrücklich eine *zweite* Reviewer-Runde nach einem
blockierenden MEDIUM-1 verlangt, `ADR-0040` Festlegung 2) behandeln genau diesen Fall mit einer
neuen, unabhängigen Prüf-Runde statt mit einer Selbstauskunft der behebenden Rolle.

**Das ist kein Einwand gegen die Richtigkeit der Korrektur** — sie ist, soweit nachprüfbar, korrekt
— sondern gegen die **Form** des Nachweises: Auf dem Papier trägt der einzige Review-Report für
diesen Slice weiterhin das Verdikt *Blockierend*, und DoD-5 ist entsprechend korrekt unchecked
geblieben. Eine Closure dieses Slice, solange dieser Zustand unverändert ist, liefe auf eine
Selbstbestätigung hinaus, die der Prozess an dieser Stelle nicht vorsieht.

---

## Was ich nicht geprüft habe

- **33 der 42 Delta-Posten** wurden nicht individuell am Kurs-Diff gegengelesen — nur die
  Zuordnungs-Deckung (Empfänger korrekt) für die ausgehenden, nicht ihr Inhalt gegen den Bestand
  dieses Repos (siehe §3). Das ist dieselbe, ausdrücklich benannte Lücke wie im Review; ich habe
  sie nicht geschlossen, sondern zusätzlich neun Punkte gegengeprüft (davon sechs identisch mit den
  vom Reviewer genannten Korrekturen/Bestätigungen, drei zusätzlich: HIGH-1-Zitat, RTM-Zeilenzahl,
  Vollständigkeits-Diff).
- **Die Kurs-Welle-Spalte** (Spalte 2 der Tabelle) habe ich, wie schon der Reviewer, nicht gegen
  `git log` verifiziert.
- **Die inhaltliche Prüfung der sieben `slice-225`-Zeilen und der einen `slice-213/214`-Zeile**
  gegen den jeweiligen Ziel-Bestand — das ist Gegenstand jener Slices, nicht dieser Verifikation.
- **`make gates` selbst** wurde nicht neu gefahren, wie in der Aufgabe verlangt; stattdessen der
  Working-Tree-Hash-Abgleich (§0) und `make docs-check` isoliert.
- **Ob die Auftraggeber-Entscheidung „Namen ab jetzt, kein Nachrüsten" tatsächlich so getroffen
  wurde**, kann ich nicht verifizieren — das ist eine externe Kommunikation, kein Repo-Artefakt.
  Ich habe nur geprüft, dass die Plandatei sie konsistent referenziert und keine Datei bereits
  vorgreifend so behandelt, als sei sie schon in `harness/conventions.md` verkörpert.

---

## Urteil

**Sachlich: die Lieferung trägt.** Alle drei Liefer-Punkte sind vollständig und korrekt umgesetzt,
die Summenprobe geht auf (29+13=42), neun unabhängig gefahrene Stichproben — inklusive des
kritischen HIGH-1-Zitats — bestätigen die Tabelle exakt, die neun Übergabe-Adressen nehmen an (bis
auf die zwei bewusst als Risiko geführten trägerlosen Rollen-Sendungen), beide ADRs sind korrekt
angewandt, und Plan und Code decken sich in beiden Richtungen.

**Formal: nicht abschlussreif, aus zwei benannten Gründen — einer davon zentral:**

1. **Zentral:** Der einzige vorliegende Review-Report trägt weiterhin das Verdikt *Blockierend*
   und wurde nicht durch eine zweite Runde der Reviewer-Rolle ersetzt oder bestätigt. Der
   Closure-Trigger (§5) verlangt einen Report ohne blockierenden Befund — dieser liegt nicht vor,
   unabhängig davon, dass die Behebung inhaltlich zutrifft. DoD-5 ist deshalb zu Recht unchecked.
2. **Nebenbefund:** Der Register-Zähler `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`
   steht im Plan bei „3×", das eigene Beleg-Kommando liefert **4×**. Ändert keine der 42 Antworten,
   sollte aber vor oder bei der Closure korrigiert werden.

Beide Punkte sind Korrekturen an der Plandatei bzw. am Prozess-Schritt „zweite Reviewer-Runde",
keine Rückweisung der Nachweis-Arbeit selbst. Empfehlung an den Planner: eine kurze zweite
Reviewer-Runde (frischer Kontext) gegen genau HIGH-1 und die fünf MEDIUM/zwei LOW einholen, bevor
DoD-5 abgehakt und die Closure eingeleitet wird; den Zähler-Tippfehler im selben Zug korrigieren.

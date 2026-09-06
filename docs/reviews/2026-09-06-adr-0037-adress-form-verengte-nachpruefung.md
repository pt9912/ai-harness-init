# Verengte Nachprüfung — ADR-0037, Adress-Form vor dem Accept-Übergang

**Rolle:** Reviewer · **Datum:** 2026-09-06 · **Skill:** `reviewer.md` 1.7.0
**Art:** verengte Nachprüfung, **keine** Runde 8 — der Prüfgegenstand ist ein einzelner
Nacharbeits-Commit, nicht die Datei.

## Kopf-Metadaten

- **Prüfgegenstand:** `5fb156fa` gegen `4afbde8`
  (`git diff 4afbde8 5fb156fa`), Gegenstand `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`,
  Status `Proposed`.
- **Anlass:** Accept-Vorprüfung des Architect; der Übergang wurde verweigert statt vollzogen.
  Runde 7 (`2026-09-06-adr-0037-konsistenz-review-runde-7.md`) hatte *Konsistenz BESTÄTIGT*
  gemeldet, 0 HIGH/MEDIUM/LOW.
- **Auftrag:** drei Punkte — (1) trägt die neue Adress-Form nach `ADR-0016` Festlegung 2,
  (2) die **Messung** der Klasse, nicht nur ihr Ergebnis, (3) Rot- und Grün-Nachweis. Dazu die
  Trage-Frage: hat der Commit irgendetwas außerhalb dieser Klasse bewegt.
- **Eingangs-Kontext (Skill §Eingangs-Kontext):** Diff/Commit-Range ✓ · Hard Rules
  (`AGENTS.md` §3.4/§3.6/§3.9/§3.11) ✓ · referenzierte aktive ADRs (`ADR-0016`, `ADR-0034`,
  `ADR-0017`, `ADR-0033`) ✓ · `LH-*` (`LH-FA-02`, `LH-QA-01`, `LH-QA-02`) ✓ · vorherige Findings
  am gleichen Modul (Runden 1–7) ✓. **Nicht erhalten und hier benannt:** der Slice-Plan
  `slice-190`; die Aussagen dieser Datei über ihn liegen ausdrücklich außerhalb meines Auftrags.
- **Nicht mein Gegenstand:** die inhaltlichen Festlegungen (sieben Runden ohne Befund gegen die
  Entscheidung) und der zweite Architect-Fund zur Adress-Form in den Reports selbst — zur Kenntnis
  genommen, dieser Report ist ohne die Konstruktion geschrieben.
- **Umgebung:** alle Gate-Läufe über `make docs-check` im gepinnten Bild (`AGENTS.md` §3.9);
  Kalibrierung am ruhenden Baum `d-check: 891 Datei(en) geprüft, 0 Befund(e)`, EXIT 0.

## Findings

### M-1 — die Bezugsmenge des Zählers *12* steht nicht dabei, und die naheliegende Lesart liefert 26

- **kategorie:** MEDIUM
- **quelle:** `MR-025` Setzung 1 (fortbindend nach `MR-051`)
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:771`
- **befund:** Die neue Geschichte-Zeile trägt den Satz *„Alle **107** Markdown-Links fallen auf
  **12** eindeutige Ziele, und keines bewegt der Prozess"*. Die **12** ist der Träger der
  Erschöpfungs-Aussage — über genau diese Menge läuft die anschließende Einzelprüfung —, und sie
  ist die einzige Zahl der Zeile **ohne** Kommando: für **107** stehen drei da, für **19**, für
  **11** und für beide Nullen je eines. Sie ist zudem zweideutig, und die zwei Lesarten geben
  verschiedene Werte: über die Ziel-*Zeichenkette* gezählt sind es **26**, erst nach dem Strippen
  des Ankers **12**. Welche der beiden gemeint ist, sagt der Text nicht.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -oE '\]\([^)]+\)' "$D" | sed -E 's/^\]\(//; s/\)$//'           | sort -u | wc -l   # 26
  grep -oE '\]\([^)]+\)' "$D" | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u | wc -l   # 12
  ```

  **Keine Erwartungswerte.** Der **Wert 12 ist wahr** — die zwölf Ziel-Dateien sind unten einzeln
  geprüft und keine von ihnen wandert. Bestritten ist das Instrument, nicht die Zahl: derselbe
  Zuschnitt, an dem Runde-6-M-1 hing.
- **verifizierbar:** ja — die zwei Kommandos oben über derselben Datei; kein Gate-Lauf, denn kein
  Modul der `.d-check.yml` liest Prosa-Zahlen (`grep -n '^modules:' .d-check.yml`).
- **klasse:** Messwert ohne Kommando, dessen Bezugsmenge zwei Lesarten trägt
- **warum blockierend:** Der Satz friert mit dem `Accepted`-Übergang ein (`AGENTS.md` §3.4). Genau
  diesen Preis benennt `ADR-0016` Festlegung 3 (a) als Grund, die Form **vor** die Annahme zu
  legen — *„nach der Annahme ist derselbe Satz durch §3.4 unerreichbar, und der Preis steigt von
  einer Zeile auf eine Folge-ADR"*. Die ADR liegt im Geltungsbereich von `MR-025`
  (`git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | grep -c '^docs/plan/adr/0037-'`
  → **1**, kein Erwartungswert), und der Cutoff bindet die Zahl, **die geschrieben wird** — diese
  ist am 2026-09-06 neu geschrieben.

### L-1 — *„11 Belege"* zählt eine Vorlagen-Nennung als Beleg mit

- **kategorie:** LOW
- **quelle:** `ADR-0016` Festlegung 2
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:771`
- **befund:** Die Zeile rezitiert die drei Teile eines Belegs — *„Tag, Datei- und Abschnittsname
  sowie Zitat"* — und sagt im selben Satz *„damit tragen **11** Belege sie"*. Von den elf
  Fundstellen tragen **zehn** alle drei Teile; die elfte, die neu hinzugekommene
  Vorlagen-Nennung in Zeile 521, trägt Tag und Dateinamen, **keinen** Abschnittsnamen und **kein**
  Zitat. Das gezählte Merkmal ist die *Form* (Tag genannt, Pfad baseline-relativ, Inline-Code) und
  nicht die Beleg-Eigenschaft; das Wort `Belege` trägt weiter, als die Messung reicht.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -cE 'Baseline .v6\.0\.0.,' "$D"                              # 11
  git show 4afbde8:"$D" | grep -cE 'Baseline .v6\.0\.0.,'           # 10
  grep -nE 'Baseline .v6\.0\.0.,' "$D"                              # Zeile 521 ist die neue
  ```

  **Keine Erwartungswerte.**
- **verifizierbar:** ja — die drei Kommandos oben plus Sichtprüfung der zehn Fundstellen; kein
  Gate-Lauf.
- **klasse:** Zähl-Merkmal und Bezeichnung der gezählten Menge fallen auseinander

### INFO-1 — mit dem Link ist auch der einzige Wächter dieses Pfades gegangen, und *„allein"* nennt ihn nicht

- **kategorie:** INFO
- **quelle:** `AGENTS.md` §3.6; `ADR-0016` §Verglichene Alternativen, Option G
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:771`
- **befund:** Die Zeile sagt *„**Verloren geht allein die Navigierbarkeit**"* und begründet das
  zweifach: sie zähle nicht zum Beleg, und sie wäre beim nächsten Sprung ohnehin verfallen. Die
  zweite Begründung trägt für den mechanischen Anteil nicht: Der Link war **gate-sichtbar**, und
  sein Wächter wäre beim Sprung nicht *verfallen*, sondern **rot geworden**. Gemessen als
  Gegenbeispiel-Paar am selben Baum, je ein Lauf mit verfälschtem Pfad:

  | Form in Zeile 521 | Pfad | `make docs-check` |
  |---|---|---|
  | alte Link-Form | `…/GIBTESNICHT.template.md` | **891 Datei(en), 1 Befund** — `target-missing`, EXIT 1 |
  | neue Inline-Code-Form | `…/GIBTESNICHT.template.md` | **891 Datei(en), 0 Befund(e)** — EXIT 0 |

  **Keine Erwartungswerte.** Der Pfad ist heute richtig
  (`ls .harness/baseline/v6.0.0/templates/docs/plan/planning/reconciliation.template.md` liefert
  die Datei), also ist nichts falsch geworden — **unbewacht** ist es. Und die Zeile rechnet den
  neuen unbewachten Ort ihrer eigenen Aufstellung **nicht** zu: die dort benannte *stille Hälfte*
  umfasst **19** Nennungen, und Zeile 521 ist keine davon, weil ihr Pfad das Präfix
  `.harness/baseline/` gar nicht trägt.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  sed -E 's/\]\([^)]*\)//g' "$D" | grep -n '\.harness/baseline/v[0-9]' | cut -d: -f1 | tr '\n' ' '
  # 92 94 197 230 293 297 334 336 398 400 514 515 534 536 571 574 576 578 579  -> 19, ohne 521
  ```

  **Kein Erwartungswert.**
- **verifizierbar:** ja — die zwei Läufe der Tabelle, beide reproduziert.
- **klasse:** Erschöpfungs-Wort über eine Verlust-Menge, die einen gemessenen Posten auslässt
- **warum nicht blockierend:** Dieselbe Tabellenzeile protokolliert den mechanischen Sachverhalt
  offen — *„meldete **vorher** genau **1** `target-missing` und **nachher 0**"* —, ein Leser wird
  über den Wächter also nicht getäuscht. Und `ADR-0016` benennt den Verlust als beschlossenen
  Preis der gewählten Option: *„die stille Hälfte bleibt unbewacht, und diese ADR baut den Sensor
  nicht"*. Der Posten gehört in eine Folge-Entscheidung, nicht in eine Blockade.

## Negativbefunde

Je eine Zeile pro betrachtetem Bereich — sonst ist *keine Findings* nicht von *nicht geprüft* zu
unterscheiden.

- **Commit-Umfang — geprüft, ohne Befund.** `git show --stat 5fb156fa` → **1 Datei, 3
  Einfügungen, 2 Löschungen**; genau zwei Hunks. `git diff --word-diff=plain 4afbde8 5fb156fa`
  zeigt im Inhalts-Hunk **allein** die Klammer `(Vorlage: …)` als ersetzt, jedes andere Wort des
  Absatzes steht unverändert; der zweite Hunk ist eine reine Zeilen-Ergänzung an der
  Geschichte-Tabelle. **Nichts außerhalb der Klasse bewegt.**
- **Deckung von Runde 7 — geprüft, ohne Befund.** `git show --stat de5f40dd` → **1 Datei**, allein
  der Report; die ADR wurde dort nicht angefasst. Der von Runde 7 bestätigte Text **ist** der Stand
  `4afbde8`, und ihr Verdikt behält seinen Gegenstand vollständig.
- **`ADR-0016` Festlegung 3 (a) als Träger — geprüft, ohne Befund.** Der Träger existiert im
  Wortlaut (*„Bevor der Status eines ADR auf *Accepted* wechselt, werden seine Baseline-Belege in
  die Form aus Festlegung 2 gebracht"*) und deckt ausdrücklich das noch nicht angenommene ADR
  (*„Ein Proposed-Artefakt ist **kein Bestand**, sondern wird geschrieben"*). Die Vorprüfung war
  damit fällig, nicht erfunden.
- **Form nach Festlegung 2 — geprüft, ohne Befund.** Was Festlegung 2 **ausschließt**, ist der
  lokale Präfix `.harness/baseline/<tag>/`; genau er ist entfallen. Der Tag bleibt, der Pfad ist
  baseline-relativ, die Nennung steht in Inline-Code. Das in der Zeile abgedruckte Zitat aus
  Festlegung 2 ist verbatim mit markierter Auslassung: mit wieder eingesetztem Präfix trifft es
  die Quelle whitespace-normalisiert **1**×.

  ```sh
  tr '\n' ' ' < docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md | tr -s ' ' \
    | grep -cF 'dazu gehören der lokale Präfix'   # 1
  ```

  **Kein Erwartungswert.**
- **`MR-033` — geprüft, ohne Befund.** Die alte Form trug den Tag nur in der Link-*Adresse*, also
  außerhalb des gerenderten Satzes; die neue nennt ihn im sichtbaren Text. Ein Verlust auf dieser
  Achse ist ausgeschlossen, ein Gewinn plausibel. `MR-033` Setzung 2 verlangt ohnehin *keine*
  bestimmte Verweis-Form und verweist für einfrierende Artefakte auf `ADR-0016` Festlegung 2.
- **Klassen-Messung, Ergebnis — geprüft, ohne Befund.** Die drei Zählungen stimmen überein und
  reproduzieren: **107 · 107 · 107**, Klasse **0**.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -oE '[]][(]' "$D" | wc -l                                       # 107
  grep -oE '\]\([^)]+\)' "$D" | wc -l                                  # 107
  tr '\n' ' ' < "$D" | grep -oE '\]\([^)]+\)' | wc -l                  # 107
  grep -oE '\]\([^)]*\.harness/baseline/v[0-9][^)]*\)' "$D" | wc -l    #   0
  ```

  **Keine Erwartungswerte.**
- **Klassen-Messung, Methode — geprüft, ohne Befund; zusätzlich mit stärkerem Instrument
  gegengefahren.** Die zwei Sonden treffen ihren eigenen Abdruck tatsächlich nicht: in beiden
  abgedruckten Mustern steht die gesuchte Folge nicht. Meine eigene, **nicht** so gehärtete Sonde
  auf Referenz-Stil-Links lieferte prompt genau diesen Fehler — **1** Treffer, und der lag im
  Inline-Code der Sonde selbst. Nach Entfernen der Code-Fences **und** der Inline-Code-Spans steht:

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  awk 'BEGIN{f=0} /^[[:space:]]*```/{f=!f; next} !f' "$D" \
    | sed -E 's/``[^`]*``//g; s/`[^`]*`//g' > "$SCRATCH/stripped.md"
  grep -oE '\]\([^)]+\)' "$SCRATCH/stripped.md" | wc -l                        # 107  kein Link lebte in Code
  grep -cE '\]\[[^]]+\]' "$SCRATCH/stripped.md"                                #   0  Referenz-Stil
  grep -cE '^[[:space:]]*\[[^]]+\]:[[:space:]]' "$SCRATCH/stripped.md"         #   0  Referenz-Definitionen
  grep -c '<a ' "$SCRATCH/stripped.md"                                         #   0  <a href>
  grep -oE '<[a-zA-Z][a-zA-Z0-9+.-]*:[^ >]*>' "$SCRATCH/stripped.md" | wc -l   #   0  Autolinks
  grep -oE '\.harness/baseline/v[0-9]' "$SCRATCH/stripped.md" | wc -l          #   0  ausserhalb von Code
  ```

  **Keine Erwartungswerte.** Die letzte Zeile ist die stärkere Aussage: **jede** tag-gepinnte
  Baseline-Nennung der Datei liegt in Code, keine in einer Adresse — unabhängig davon gemessen, ob
  ein Link-Muster sie fände.
- **Erschöpfung durch Zählungs-Gleichheit — geprüft, ohne Befund.** Die Begründung trägt: ein Ziel
  mit einer schließenden Klammer im Pfad ließe Zählung 1 und 2 auseinanderfallen, ein umbrechender
  Link Zählung 2 und 3. Beide Klassen sind im Ist-Stand leer, was die Gleichheit
  **107 = 107 = 107** belegt.
- **Die zwölf Ziele einzeln — geprüft, ohne Befund.** `AGENTS.md` §3.11 bindet, was *auf Anweisung
  wandert*. Von den zwölf Ziel-Dateien liegen fünf im flachen ADR-Baum
  (`ls -d docs/plan/adr/*/ 2>/dev/null | wc -l` → **0** Unterverzeichnisse, kein Erwartungswert),
  fünf sind ortsfeste Rang-Dokumente (`AGENTS.md`, `harness/conventions.md`,
  `spec/lastenheft.md`, `spec/architecture.md`, das Benutzerhandbuch), und zwei sind
  `observation.md`-Dateien in Verzeichnissen der Register-Ablage, die `ADR-0034` Festlegung 5
  ausdrücklich ortsfest stellt (*„Ortsfest und als Pfad zulässig sind nach dem Sprung die
  **Ablage** `observations` unter `docs/plan/planning/` und die Verzeichnisse darin"*). In den
  Planning-Lifecycle und nach `docs/reviews/**` — die zwei Bäume, die der Prozess wirklich bewegt —
  zeigt **kein** Link:

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -oE '\]\([^)]+\)' "$D" \
    | grep -cE 'planning/(open|next|in-progress|done)/|docs/reviews/|\.\./reviews/'   # 0
  ```

  **Kein Erwartungswert.**
- **Gegenprüfung am Werkzeug statt am Wortlaut — geprüft, ohne Befund.** `Einsammeln` in
  `internal/archive/collect.go` liest genau zwei Orte — `docs/plan/planning/done` und, über
  `Reviews`, `docs/reviews` —; `observations` kommt in `internal/archive/` nur in drei
  Test-/Stub-Zeilen als **Link-Text** vor, in keiner Bewegungs-Operation. `harness/tools/slice-mv.sh`
  bewegt ausschließlich zwischen `LIFECYCLE="open next in-progress done"` unter
  `PLANNING="docs/plan/planning"`. **Kein Werkzeug dieses Repos bewegt etwas unter
  `observations/`.**
- **Rot-Richtung — reproduziert.** Vorzustand `4afbde8`, `v6.0.0` → `v6.1.0` **allein** auf Zeile
  521, `make docs-check`:
  `docs/plan/adr/0037-…:521 … target-missing Linkziel existiert nicht` ·
  `d-check: 891 Datei(en) geprüft, 1 Befund(e)`, EXIT 1. Genau **ein** Befund, genau die Zeile.
- **Grün-Richtung — reproduziert.** Ist-Stand, dieselbe Ersetzung über die **ganze** Datei,
  `make docs-check` → `d-check: 891 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Die **34** Stellen der
  Übergabe reproduzieren als **33** Klartext-Vorkommen plus **1** regex-maskiertes
  (`grep -o 'v6\.0\.0' <datei> | wc -l` → 33; `grep -oE 'v6[\\.]+0[\\.]+0' <datei> | wc -l` → 34);
  nach der Ersetzung stehen **35** Vorkommen von `v6.1.0` — die 34 ersetzten plus das eine, das die
  Geschichte-Zeile selbst schon führte. **Keine Erwartungswerte.**
- **Rücksetzung — geprüft, ohne Befund.** Nach jedem der vier Simulationsläufe byte-exakt
  zurückgesetzt: `sha256sum -c` → `OK`, `git status --porcelain` leer. Der Baum, den dieser Report
  beschreibt, ist der committete.
- **Übrige Zahlen der neuen Zeile — geprüft, ohne Befund.** `19` (stille Hälfte) reproduziert;
  `11`/`10` (Beleg-Form nachher/vorher) reproduzieren; `0` (ADR-Unterverzeichnisse) reproduziert;
  `0` (Reports, die die Fundstelle nennen) reproduziert. Zusätzlich unabhängig gemessen und
  **wahr**, obwohl ohne eigenes Kommando in der Zeile: es sind **7** `ADR-0037`-Konsistenz-Reports,
  und **alle 7** führen `AGENTS.md` §3.11 in ihrem Eingangs-Kontext
  (`ls docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md | wc -l` → 7;
  `grep -l '3\.11' docs/reviews/2026-09-06-adr-0037-konsistenz-review*.md | wc -l` → 7, keine
  Erwartungswerte).
- **Hard Rules — geprüft, ohne Befund.** §3.3 (kein `git mv` im Commit) · §3.4 (der Status steht
  weiter auf `Proposed`, es wurde kein eingefrorenes Artefakt überschrieben) · §3.5 (keine
  Gate-Senkung; insbesondere **kein** neues `ignore-refs`-Paar in `.d-check.yml`,
  `grep -c '^  - in: ' .d-check.yml` → **4**, in `4afbde8` ebenfalls **4**, keine
  Erwartungswerte) · §3.8 (eigener Commit, Rolle in der Message, ausschließlich ein
  Architect-Artefakt) · §3.9 (alle Läufe über `make`) · §3.11 (die neue Zeile nennt Reports und
  Plandateien bei der Kennung, nicht als Pfad).
- **Nicht geprüft, weil außerhalb des Auftrags:** die inhaltlichen Festlegungen 1–4, die Aussagen
  über `slice-190`, §Fitness Function und §Re-Evaluierungs-Trigger, sowie die Adress-Form der
  Review-Reports selbst.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | Messwert ohne Kommando, dessen Bezugsmenge zwei Lesarten trägt |
| LOW | 1 | Zähl-Merkmal und Bezeichnung der gezählten Menge fallen auseinander |
| INFO | 1 | Erschöpfungs-Wort über eine Verlust-Menge, die einen gemessenen Posten auslässt |

Die Klasse von M-1 ist die **zweite** ihrer Art in dieser Reihe — Runde-6-M-1 trug denselben
Zuschnitt (ein Zähler, dessen Instrument nicht ausgibt, was danebensteht). Zwei Instanzen sind
Symptom, nicht Lücke; die Register-Zuordnung fällt bei der Slice-Closure, nicht hier
(`AGENTS.md` §3.10).

## Verdikt

**Der `Accepted`-Übergang ist noch nicht möglich.** Genau **ein** Posten blockiert: **M-1**.

**Er liegt im Protokoll**, nicht im Argument und nicht in der Wahrheit — dieselbe Einordnung, die
die Nacharbeit zu Runde 6 für sich selbst getroffen hat.

- **Das Argument trägt.** `ADR-0016` Festlegung 3 (a) legt die Beleg-Form vor den Accept-Übergang
  und deckt das Proposed-Artefakt ausdrücklich; Festlegung 2 schließt den lokalen Präfix aus, und
  genau er ist entfallen. Die Navigierbarkeit gehört nicht zum Beleg. Der Einwand, die neue Form
  sei kein vollständiger Drei-Teile-Beleg, greift nicht: der Beleg der Aussage steht im **nächsten**
  Satz und trägt Tag, Abschnittsname und Zitat.
- **Die Wahrheit trägt.** Der Commit hat nichts außerhalb der Klasse bewegt — zwei Hunks, im
  Word-Diff nachgefahren; Runde 7 behält ihren Gegenstand vollständig, weil der Report-Commit die
  ADR nicht anfasste. Beide Richtungen des Gegenbeispiels reproduzieren exakt (1 `target-missing`
  vorher, 0 nachher), die Klassen-Messung reproduziert und hält zusätzlich einem strengeren
  Instrument stand, und die zwölf Ziele wandern nachweislich nicht — am Werkzeug gemessen, nicht
  am Wortlaut.
- **Das Protokoll trägt nicht.** Der Zähler **12**, auf dem die Erschöpfungs-Aussage ruht, steht
  ohne das Kommando, das ihn ausgibt, und die naheliegende Lesart derselben Worte liefert **26**.
  Der Wert ist richtig, das Instrument fehlt — und mit der Annahme wird der Satz nach
  `AGENTS.md` §3.4 unerreichbar.

L-1 und INFO-1 blockieren nicht und sind ohne Vorgriff auf die Nacharbeit notiert; ob sie
mitgezogen werden, entscheidet der Architect.

**Prüfgegenstand stabil.** `git log` zu Beginn: HEAD `5fb156fa`, Arbeitsbaum leer. Am Ende
derselbe Stand — die vier Simulationsläufe sind byte-exakt zurückgenommen und per `sha256sum -c`
und `git status --porcelain` als zurückgenommen belegt. Zwischen Beginn und Ende dieses Laufs hat
sich am Prüfgegenstand nichts bewegt.

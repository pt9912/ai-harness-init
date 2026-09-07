# Review — ADR-0038 (Die Ziel-Fassung regiert auch den Sprung `v6.0.0` → `v6.5.0`)

**Rolle:** Reviewer (Modul 8) · **Datum:** 2026-09-07 · **Modell:** claude-opus-5[1m]

**Gegenstand:** [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md), `Proposed`,
eingebracht mit `d1646e6c` (Ahne von `a938b822`; der Commit trägt die ADR und die Index-Zeile,
sonst nichts).

**Baum beim Lauf:** `a938b822`, Arbeitsbaum sauber vor und nach dem Review.
`make gates` → EXIT 0; `make docs-check` → `912 Datei(en) geprüft, 0 Befund(e)`.

> **Zitier-Form** *(dieser Block bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieser Report
> friert ein; was er zitiert, bewegt sich weiter. Deshalb **Kennung statt Adresse** —
> `slice-193` statt seines Lifecycle-Pfads, `make <target>` statt eines Links auf ein Rezept,
> eine Baseline-Stelle als Tag **und** Pfad in Inline-Code statt als Link. Das `pfad`-Feld auf
> den geprüften Gegenstand hält den Stand des Laufs fest und darf ihn nennen.

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Diff/Commit `d1646e6c` ·
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
aktive ADRs [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
[ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) ·
Hard Rules [`AGENTS.md`](../../AGENTS.md) §3 · vorherige Findings am gleichen Modul: die
Review-Runden zu ADR-0037 und die Runden zu den Vorgänger-Entscheidungen derselben Linie ·
Plan-Verweis: `slice-193`.

**Auflage dieses Laufs, im Report festgehalten, weil sie vom Default abweicht:** Eine Runde;
Accept-Kriterium ist **kein HIGH**, nicht kein Befund. Der Reviewer-Skill §Ablage setzt als
Default *„HIGH und MEDIUM blockieren typischerweise; Abweichungen werden im Report begründet"* —
die Abweichung ist hiermit begründet und benannt: MEDIUM und darunter halten die Annahme nicht
auf und gehen an den umsetzenden Lauf.

---

## Findings

### HIGH-1 — Die Festlegung deckt den Sprung nicht, den der abhängige Plan führt

- **kategorie:** HIGH
- **quelle:** [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) (Scope-Bauart,
  hier übernommen), eigene Konsequenz-Aussage der ADR, `slice-193` §4 Start-Bedingung 1
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:286` (Festlegung),
  `:236` (Aussage über `slice-193`), `:368` (Konsequenz), `:428` (Scope-Schluss)
- **befund:** Die Festlegung ist ausdrücklich geschlossen — *„Diese Festlegung gilt **nur** für
  `v6.0.0` → `v6.5.0`"*. Die Start-Bedingung 1 von `slice-193` verlangt aber *„Die Entscheidung
  über die regierende Fassung des Sprungs `v6.0.0` → `v6.3.1` liegt als angenommene ADR vor"*.
  Der Plan nennt `v6.3.1` an 20 Stellen und `v6.5.0` an keiner; die ADR nennt `v6.3.1` an keiner.
  Damit ist die Konsequenz *„Der Schnitt von `slice-193` und der Adaptions-Durchgang danach haben
  eine benannte, zitierte Quelle"* für den Sprung, den jener Plan führt, nicht eingelöst — die
  Start-Bedingung bleibt unerfüllt, und die ADR trägt zugleich die Aussage *„der Baum-Tausch steht
  als `slice-193` noch aus"*, ohne dass beide vom selben Ziel-Tag sprechen.
- **verifizierbar:** **nein** — kein Gate hält den Ziel-Tag einer Entscheidung gegen den eines
  abhängigen Plans; `.d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans, planning`,
  und `matrix.status` verbietet allein `superseded`/`deprecated`. Nachfahrbar von Hand:
  `grep -c 'v6\.3\.1' docs/plan/planning/open/slice-193-*.md` → 20,
  `grep -c 'v6\.5\.0' docs/plan/planning/open/slice-193-*.md` → 0,
  `grep -c 'v6\.3\.1' docs/plan/adr/0038-*.md` → 0.
- **klasse:** Ziel-Tag zwischen Entscheidung und abhängigem Plan verschieden

**Material für den umsetzenden Lauf, damit die Reichweite nicht geschätzt werden muss.** Der
tragende Grund der ADR — der Delegat mit dem Delta hat gewechselt — hält für `v6.0.0` → `v6.3.1`
ebenfalls: Der Freshness-Audit ist auch dort byte-gleich (123 Zeilen), §Konventionsspeicher steht
netto bei 0, §harness/README.md als Einstiegspunkt bei **79** statt 109, und die
Sensor-Datei-Klasse ist bereits vorhanden (`grep -c 'Ein Gate je Datei'` → 1). **Nicht** übertragbar
ist der Abschnitt zur §3.11-Frage: `Einfrierend sind die Zeitdokumente`, `Ausnahme-Ventil im
Prüfbereich` und der Zitier-Form-Block der Vorlagen treffen in `v6.3.1` je 0-mal. Kommandos:
Baum je Tag über `git -C <kurs-klon> archive <tag> lab/regelwerk lab/templates`, dann derselbe
`norm()`/`sec()`-Vergleich wie in der ADR. **Keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge wandern mit den Tags.

### HIGH-2 — Der Zielstand `v6.5.0` ist im Repo nirgends gesetzt

- **kategorie:** HIGH
- **quelle:** [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Wer den
  Zielstand bewegt; [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:1` (Titel), `:58`
  (Kontext), `:286` (Festlegung)
- **befund:** Die ADR setzt den Sprung `v6.0.0` → `v6.5.0` als gegeben voraus. `v6.5.0` kommt in
  den lebenden Markdown-Artefakten dieses Repos ausschließlich in dieser ADR und in ihrer
  Index-Zeile vor; §Baseline von `harness/conventions.md` führt keine Setzung darauf, und der
  einzige Plan für den Baum-Tausch nennt `v6.3.1`.
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) reserviert diesen Akt der
  **Setzung des Auftraggebers** und begründet das damit, dass *„kein Lauf im Repo den Zielstand
  einer Release-Liste nachführt — der stille Auto-Bump eine Ebene höher"*. Die Verschiebung von
  `v6.3.1` auf `v6.5.0` folgt der Release-Liste (`v6.4.0` und `v6.5.0` sind nach dem Schnitt von
  `slice-193` erschienen) und wird in der ADR weder als Verschiebung benannt noch belegt — während
  dieselbe ADR den Satz *„Ein neuer Tag löst einen Review aus …, keinen stillen Auto-Bump."* als
  ihren eigenen Stufe-(a)-Beleg zitiert.
- **verifizierbar:** **nein** — kein Gate liest, welcher Zielstand gesetzt ist. Nachfahrbar:
  `git grep -ln 'v6\.5\.0' -- '*.md' ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'`
  → zwei Dateien (die ADR und der ADR-Index); `sed -n '/^## Baseline/,/^\*\*Was das Feld/p' harness/conventions.md | grep -c 'v6\.5\.0'`
  → 0. **Keine Erwartungswerte.**
- **klasse:** Zielstand aus der Release-Liste übernommen statt gesetzt

## MEDIUM

### MEDIUM-1 — Die Zahlen in Option C liefert das danebenstehende Kommando nicht

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (die ADR führt sie selbst im Bezug)
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:361`
- **befund:** Die Contra-Spalte von Option C nennt *„73 Verweis-Vorkommen aus 14 lebenden Dateien"*
  und stellt das Kommando daneben. Über dem Baum, in dem die Zahl steht, liefert dieses Kommando
  **92** Vorkommen aus **15** Dateien — die ADR selbst trägt 18 solcher Verweise, ihre Index-Zeile
  einen. 73/14 ist der Stand des Eltern-Commits `d1646e6c^`, also des Baums *ohne* die ADR.
  MR-025 Setzung 1 verlangt das Kommando, das **genau** die Zahl ausgibt, gefahren über dem Baum,
  von dem sie spricht. Die Selbstauskunft *„beide wandern und sind keine Erwartungswerte"* deckt
  Drift über die Zeit, nicht die Differenz am eigenen Commit. Die Richtung der Abweichung stützt
  das Argument, sie widerlegt es nicht.
- **verifizierbar:** **teilweise** — kein Gate deckt es
  ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Kein Wächter: `make comment-claims` hat keine Markdown-Datei im Prüfbereich). Die Gegenprobe ist
  mechanisch: dasselbe Kommando gegen `d1646e6c` statt `d1646e6c^`.
- **klasse:** Zahl gegen den Baum vor dem eigenen Commit gemessen

### MEDIUM-2 — Eine `Proposed`-ADR wird als bindend geführt, ohne dass ihr Status genannt ist

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (Bindung ab `Accepted`);
  Beobachtung `BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger`
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:17` (Bezug), `:38`
  (Kopplung), `:390` (Folgepflicht)
- **befund:** Der Bezug sagt zu
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md), ihre
  Festlegung 2 *„bindet die Buchung, die mit dem Baum-Tausch entsteht"*, und die Folgepflicht
  schreibt die Drei-Teil-Form daraus fest. ADR-0031 steht auf `Proposed`, trägt anders als
  ADR-0036 und diese ADR **keinen** Acceptance-Trigger in der Datei, und ihr Träger `slice-171`
  liegt in `open/`. Der Status wird an keiner Stelle der ADR genannt. `matrix.status` verbietet
  nur `superseded`/`deprecated`, also meldet kein Gate etwas. Dieselbe Auslassung trägt bereits
  ADR-0036 gegenüber derselben Quelle — die Klasse ist im Beobachtungs-Register geführt.
- **verifizierbar:** **nein** — kein Modul hält Status und Bindungs-Behauptung zusammen.
  Nachfahrbar: `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-*.md` → `Proposed`;
  `grep -c 'Acceptance-Trigger' docs/plan/adr/0031-*.md` → 0.
- **klasse:** Proposed-ADR als bindend zitiert, Status ungenannt

### MEDIUM-3 — §Baseline nennt für diesen Sprung keine regierende Fassung, und die Kopplung erklärt nur die halbe Auslassung

- **kategorie:** MEDIUM
- **quelle:** [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2; eigene Zweck-Aussage der ADR
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:38` (Kopplung), `:390`
  (Folgepflicht)
- **befund:** Die Kopplung meldet *„keine im Vollzug dieses Laufs"* und begründet das damit, dass
  der Slice mit dem Delta-Nachweis noch nicht existiert. Für die **Buchung** trägt das: Festlegung 2
  schließt die Form auf drei Teile und verbietet einen vierten, ohne den Slice-Zeiger ist sie nicht
  schreibbar. §Baseline trägt daneben aber eine **zweite**, davon unabhängige Aussage — welche
  Fassung den jeweiligen Sprung regiert; sie steht dort heute für die Sprünge auf `v5.12.0`,
  `v5.18.0` und `v6.0.0`, und für den letzten wurde sie im selben Commit gesetzt, der jene ADR als
  `Proposed` einbrachte. Für diesen Sprung fehlt sie, und die ADR schiebt sie mit der Buchung auf
  den Baum-Tausch. Bis dahin findet ein Lauf, der über `harness/README.md` nach §Baseline einsteigt,
  keinen Zeiger auf die regierende Entscheidung — gegen die erklärte Absicht, dem Durchgang *„eine
  benannte, zitierte Quelle, bevor das erste Konformitäts-Urteil fällt"* zu geben. Festlegung 2
  **verlangt** diesen Zeiger nicht; die Abweichung von der eigenen Präzedenz wird nur nicht benannt.
- **verifizierbar:** **nein** — kein Gate fordert einen solchen Zeiger. Nachfahrbar:
  `sed -n '/^## Baseline/,/^\*\*Was das Feld/p' harness/conventions.md | grep -c 'Prozedur des Sprungs\|stellt die Ziel-Fassung'`
  gegen die Zahl der geführten Sprünge.
- **klasse:** Regierende Fassung ohne Zeiger im lebenden Register

## LOW

### LOW-1 — Ein Zitat wird vier Vorlagen zugeschrieben und ist in dreien verbatim

- **kategorie:** LOW
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2;
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:328`
- **befund:** Die ADR schreibt, `v6.5.0` lege einen Träger *„in vier Vorlagen"* ab, *„deren
  Zitier-Form-Block sich selbst als »bleibt stehen — Norm, kein Ausfüll-Hinweis« ausweist"*. Vier
  Vorlagen tragen den Block; die Zeichenkette steht in dreien. Die vierte — die Review-Report-Vorlage
  — schreibt *„dieser Block bleibt stehen — er ist Norm, kein Ausfüll-Hinweis; die `<Platzhalter>`
  darin sind Formbeispiele"*. Unter ADR-0016 F2 (*Wortlaut ohne Auszeichnung, Whitespace
  normalisiert*) ist das kein verbatim-Treffer, sondern eine Kürzung. Die Zahl *vier* steht zudem
  ohne das Kommando, das sie ausgibt; sie ist richtig.
- **verifizierbar:** **nein** — `citations` ist opt-out (0 `d-check:cite`-Direktiven). Nachfahrbar
  gegen den Kurs-Klon: `grep -rlc 'Norm, kein Ausfüll-Hinweis' <baum>/templates` → 3 Dateien,
  `grep -rl 'Zitier-Form' <baum>/templates` → 4.
- **klasse:** Zitat einer Menge zugeschrieben, in der es nicht überall verbatim steht

### LOW-2 — Der Slice-Zeiger ist innerhalb der ADR einmal der zweite und einmal der dritte Teil

- **kategorie:** LOW
- **quelle:** [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:38` gegen `:393`
- **befund:** Die Kopplung zählt *„mit drei Teilen — Ziel-Tag und Datum, der Slice mit dem
  Delta-Nachweis, sonst nichts"* — dort ist der Slice der zweite. Die Folgepflicht schreibt *„Ihr
  dritter Teil — der Slice mit dem Delta-Nachweis"*. Beide Zählungen existieren im Repo (die
  Bullet-Liste in ADR-0031 macht ihn zum zweiten, die Fließtext-Aufzählung in §Baseline zum
  dritten); die ADR übernimmt beide nebeneinander. Der Teil ist benannt, also nicht mehrdeutig.
- **verifizierbar:** **nein** — kein Gate zählt Aufzählungs-Ordinale.
- **klasse:** Zwei Zählweisen derselben geschlossenen Form im selben Dokument

## INFO

### INFO-1 — „sechs Releases" trägt kein Kommando

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (Grenzfall: Zahlen ohne Messwert-Rolle bindet sie nicht)
- **pfad:** `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:86`
- **befund:** *„Der Sprung überspannt sechs Releases"* steht über einem Kommando, das Dateien und
  Zeilen ausgibt, nicht die Zahl der Releases. Die Zahl ist richtig
  (`git -C <kurs-klon> tag --list 'v6.*' | sort -V | awk '/^v6\.0\.0$/{f=1;next} f' | wc -l` → 6).
  Ob sie eine Messwert-Rolle trägt oder Kontext ist, ist ein Urteil; hier festgehalten, nicht
  entschieden.
- **verifizierbar:** **nein.**
- **klasse:** Zahl neben einem Kommando, das eine andere Zahl ausgibt

---

## Negativbefunde — geprüft, ohne Befund

Jede Zahl unten ist nachgefahren, nicht übernommen. `v6.0.0` ist aus dem Arbeitsbaum gelesen, jede
`v6.x`-Seite darüber hinaus aus dem lokalen Kurs-Klon — eine Host-Voraussetzung, wie die ADR sie
selbst ausweist. **Keine Erwartungswerte.**

- **Die Achse.** Der vendored Baum ist byte-gleich mit `lab/regelwerk` + `lab/templates` am Tag:
  `diff -r -x SHA256SUMS .harness/baseline/v6.0.0 <archiv von v6.0.0>` ist leer, Exit 0. Die
  Warnung trägt: `kurs/de` führt denselben Modul-Text als zweite Fassung, ein Vergleich dorthin
  misst einen anderen Gegenstand.
- **Umfang des Sprungs.** `32 Dateien +624 −153` reproduziert.
- **Stufe (a).** Die Überschrift steht in `v6.0.0` · `regelwerk/modul-02-harness-bootstrap.md`
  genau einmal; die gepinnte Fassung führt die Prozedur. Der zweite Fall aus ADR-0018 Festlegung 3
  greift, nicht der erste.
- **Stufe (b).** Der Abschnitt ist über den Tausch byte-gleich (123/123 Zeilen, `diff` leer), führt
  sieben Eigenschaften (`grep -c '^\* \*\*'` → 7) und benennt selbst *„Dann **fünf Ausgänge**"*.
- **Delegat-Verteilung.** Neun Verweise in vier Dateien, Verteilung 3/2/1/1/1/1 wie angegeben.
- **Netto je Delegat.** `roh/netto` = 137/111, 5/3, 12/0, 36/0 exakt reproduziert.
- **Der Delegat-Wechsel — die tragende Messung.** §harness/README.md als Einstiegspunkt netto
  **109**, §harness/conventions.md als Konventionsspeicher netto **0**, die übrigen vier Sektionen
  0/2/0/0. Zusätzlich geprüft, weil ein leerer Extrakt hier still grün wäre: der `sec()`-Extraktor
  liefert für **jede** der sechs Sektionen nicht-leere Ausgaben auf beiden Seiten (u. a. 57 → 164
  Zeilen), und die sechs Sektions-Nettos summieren sich auf 111 — genau das Datei-Netto. Der
  Extraktor deckt die Datei also ab, und die Null bei §Konventionsspeicher ist eine Messung, keine
  Lücke. **Die Folge trägt ebenfalls:** die Häufigkeits-Begründung der Vorgänger-ADR ist damit
  widerlegt, und die Entscheidung steht auf einem Grund — der zweite Grund jener ADR ist real nicht
  verfügbar (`ls -1 .harness/baseline/` → `v6.0.0`). Die ADR nimmt ihn ausdrücklich nicht in
  Anspruch und bucht die Einbeinigkeit als Negativ-Konsequenz; das ist konsistent.
- **Die neue Artefakt-Klasse ist wirklich neu.** *„Ein Gate je Datei, sobald sein Vertrag mehr
  braucht als einen Satz"* trifft in `v6.5.0` einmal und in `v6.0.0` keinmal; die `## Sensors`-Zeile
  der Pflichtgliederung gewinnt die zweite Kommentarzeile *„Prosa je Gate unter
  harness/sensors/<target>.md"*. Die Zitier-Form-Blöcke sind in `v6.0.0` an 0 Vorlagen und in
  `v6.5.0` an 4 vorhanden.
- **Die Tabellenform als Rauschklasse.** 17 von 25 im letzten Release-Schritt berührten Dateien
  ändern nur die Tabellenform — reproduziert. **Eine Prämisse aus dem Auftrag korrigiert sich
  dabei:** ein naiver Whitespace-Test findet hier nicht 2, sondern ebenfalls **17** (`diff -w`
  über dieselbe Dateiliste), denn die Separator-Zeile wechselt `|---|` → `| --- |` bei
  gleichbleibender Strichzahl und ist damit sehr wohl eine reine Whitespace-Differenz. Die
  Normalisierung der ADR ist gleichwohl das **engere** Instrument — sie greift nur um Pipes auf
  Tabellenzeilen und kann eine echte Prosa-Änderung nicht verschlucken; kein Befund, sondern die
  sicherere Wahl.
- **Der Herkunfts-Kommentar trägt null.** Für alle vier Delegate reproduziert.
- **Die Meta-Frage.** 13 hinzugefügte Zeilen über die dreizehn Suchbegriffe, reproduziert; keine
  davon ist eine Meta-Regel. Die selbst benannte Grenze (Negativ aus aufgezählten Zeichenketten)
  steht in der ADR.
- **Die Wirkung am Bestand.** 80 Zeilen, 13 Tabellenzeilen, kein `harness/sensors`-Verzeichnis —
  reproduziert.
- **Zitat-Treue.** Vier Zitate gegen `v6.5.0` gehalten, alle unter ADR-0016 F2 (Wortlaut ohne
  Auszeichnung, Whitespace normalisiert) korrekt — einschließlich der **Verortung** des
  delegierenden Satzes: *„Ob ein Feld Pflicht ist …"* liegt im Abschnitt §Freshness-Audit und nicht
  daneben. Die Ausnahme ist LOW-1.
- **Die Abgrenzung zur §3.11-Frage ist sauber und versteckt keine Entscheidung.** `v6.5.0` ·
  `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt nennt für die
  Reparatur einer eingefrorenen Adresse **zwei** Wege — das Artefakt doch anfassen oder ein
  Ausnahme-Ventil — und wählt zwischen ihnen nicht. Die Charakterisierung der ADR trifft das. Die
  benannte Spannung besteht real: das `exempt-paths` des `codepaths`-Blocks nimmt `docs/reviews/**`
  aus und begründet das mit veraltenden Lifecycle-Pfaden, während `make slice-mv` genau diese
  Verweise dort nachzieht — beide sprechen über dieselbe Referenz-Klasse im selben Baum. Dass die
  Auflösung nach [`AGENTS.md`](../../AGENTS.md) §3.5 eine eigene Entscheidung ist, trägt. Die ADR
  bucht sie als Folgepflicht, statt sie beiläufig mitzunehmen.
- **Form der ADR.** Alle MADR-Abschnitte vorhanden; Index-Zeile gesetzt; keine referenzierte ADR
  ist `superseded` oder `deprecated`.
- **§3.11 an der ADR selbst.** Kein Link in `.harness/baseline/**`, kein Link auf einen
  Planning-Lifecycle-Pfad; `slice-193` steht als Kennung. Für ein Dokument, das ab `Accepted`
  einfriert, ist das die verlangte Form.
- **Nicht geprüft, weil nicht Reviewer-Sache:** DoD-Abhakung und Verifikations-Urteil über
  `slice-193`.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 2 | Ziel-Tag zwischen Entscheidung und abhängigem Plan verschieden · Zielstand aus der Release-Liste übernommen statt gesetzt |
| MEDIUM | 3 | Zahl gegen den Baum vor dem eigenen Commit gemessen · Proposed-ADR als bindend zitiert, Status ungenannt · Regierende Fassung ohne Zeiger im lebenden Register |
| LOW | 2 | Zitat einer Menge zugeschrieben, in der es nicht überall verbatim steht · Zwei Zählweisen derselben geschlossenen Form im selben Dokument |
| INFO | 1 | Zahl neben einem Kommando, das eine andere Zahl ausgibt |

**Wiederkehrende Klasse für den Steering-Loop-Zähler:** *Proposed-ADR als bindend zitiert, Status
ungenannt* trifft die im Register geführte Beobachtung
`BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger`; die Zuordnung und der Beleg gehören in
die Slice-Closure, nicht hierher.

---

## Verdikt

**Nicht annahmefähig in dieser Runde — zwei HIGH.**

Das Accept-Kriterium dieses Laufs ist *kein HIGH*. Beide HIGH treffen es im engen Sinn: HIGH-1
macht eine Konsequenz-Aussage der ADR unzutreffend und lässt den Vorgang, den sie entsperren soll,
gesperrt; HIGH-2 nimmt eine Voraussetzung als gegeben, die im Repo nicht gesetzt ist, und tut das
über denselben Mechanismus, den die ADR im eigenen Beleg als unzulässig zitiert. Beide hängen an
**einer** Ursache — der Ziel-Tag des Sprungs — und sind zusammen aufzulösen, nicht einzeln.

**Die Messungen selbst tragen.** Achse, beide Stufen, Delegat-Verteilung, Netto je Delegat und je
Sektion, die Tabellenform als zweite Rauschklasse und das Negativ zur Meta-Frage sind vollständig
reproduziert; die Sektions-Messung hält auch der Prüfung auf ein stilles Grün im Extraktor stand.
Die Argumentation ist gegenüber den Vorgänger-Entscheidungen konsistent, und die Einbeinigkeit ist
korrekt benannt statt verdeckt. Der Befund liegt nicht in der Beweisführung, sondern in dem
Fassungspaar, über das sie geführt wurde.

Die drei MEDIUM und die zwei LOW halten die Annahme nach der Auflage dieses Laufs nicht auf und
gehen an den Lauf, der die HIGH auflöst. Der Acceptance-Trigger der ADR verlangt einen Report
*„ohne blockierenden Befund"* — dieser Report ist es nicht; er blockiert an HIGH-1 und HIGH-2 und
an nichts sonst.

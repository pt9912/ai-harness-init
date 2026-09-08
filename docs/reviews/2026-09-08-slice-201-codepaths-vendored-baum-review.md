# Review-Report — slice-201: `codepaths` erreicht den vendored Baum nicht

**Rolle:** Reviewer · **Datum:** 2026-09-08 · **Runde:** 1

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `50b4d4c3..f5189bba` — drei Commits: `96c0ada2` (reiner `git mv`
  `next/` → `in-progress/`), `99109d33` (Verweis-Nachzug) und `f5189bba` (die Umsetzung:
  [`harness/README.md`](../../harness/README.md), der Slice-Plan, die Roadmap).
  [`.d-check.yml`](../../.d-check.yml) ist unberührt.
- **Betroffene `LH-*`:**
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
  dessen Beschreibung über eine Fläche spricht, die es nicht prüft) und
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Verwerfungs-Messung muss
  ein Nachfolger reproduzieren können).
- **Referenzierte aktive ADRs:**
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (`Accepted`, im
  Slice-Kopf als Abgrenzung geführt),
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  (`Accepted`, für die Roadmap-Zelle).
- **Aktive `MR-*`:** [`MR-001`](../../harness/conventions.md#mr-001),
  [`MR-009`](../../harness/conventions.md#mr-009), [`MR-025`](../../harness/conventions.md#mr-025),
  [`MR-051`](../../harness/conventions.md#mr-051), [`MR-053`](../../harness/conventions.md#mr-053).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.1, §3.3, §3.5, §3.6, §3.7,
  §3.9, §3.10, §3.11.
- **Vorherige Findings am gleichen Modul:**
  [2026-09-08 · slice-197](2026-09-08-slice-197-ventil-eingefrorene-baseline-adresse-review.md)
  (1 HIGH / 3 MEDIUM / 4 LOW / 2 INFO). Dessen INFO-1 (*„Der Ruhe-Marker wird im
  Implementations-Kontext nachgezogen, und dazwischen steht `planning-drift`"*) tritt unten als
  LOW-2 erneut auf — dieselbe Klasse, unmittelbar der nächste Slice. Dazu
  [2026-09-07 · slice-193](2026-09-07-slice-193-baum-tausch-v650-review.md), dessen DoD 2 die hier
  vermessene Lücke vorab benannt hatte.
- **Slice-Plan (Repo-Ergänzung):** `slice-201`, gelesen in `in-progress/`.

**Zustand des Baums vor dem Lauf:** `git status --porcelain` leer; `main` deckungsgleich mit
`origin/main` (`git rev-parse HEAD origin/main | uniq -c` → eine Zeile mit Zähler 2).

**Instrumente dieses Laufs.** Docker-only ([`AGENTS.md`](../../AGENTS.md) §3.9): der in
[`d-check.mk`](../../d-check.mk) gepinnte Digest `sha256:e31a372b…` (Tag `v0.74.1`) über
synthetischen Sonden-Repos und über lokalen `git clone --local --no-hardlinks`-Kopien, alle
außerhalb des Arbeitsbaums, alle mit `--network none`. Der Arbeitsbaum ist dabei nicht angefasst
worden.

**Nachgefahren, bevor geurteilt wurde.** Die drei Fixtures des Slice reproduzieren:

```sh
# Sonden-Repo: docs/probe.md mit drei erfundenen Inline-Pfaden,
# .d-check.yml des Repos, modules: [codepaths]
docker run --rm --network none -v "$P:/repo:ro" ghcr.io/pt9912/d-check@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641
# roots: [spec, docs, harness]           -> 6 Datei(en) geprüft, 1 Befund(e)
# roots: [spec, docs, harness, .harness] -> 6 Datei(en) geprüft, 3 Befund(e)
```

Die Kontrolle trägt: der Pfad **ohne** `/baseline`-Segment (`.harness/does-not-exist-201-c.md`)
bleibt im ersten Lauf ebenfalls stumm und färbt im zweiten rot — `scan.ignore` scheidet damit als
Ursache aus, `roots` als Präfix-Zeichenkette ist es. Die Diagnose des Slice ist **bestätigt**.

---

## Findings

### HIGH-1 — Die Zahl **122** gibt das danebenstehende Kommando über dem Baum, in dem sie steht, nicht aus

- `kategorie`: HIGH
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025) Setzung 1;
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `harness/README.md:99` (der Kommentar `# 122` im Codeblock) und `harness/README.md:102`
  (der Fließtext „**122** zusätzliche Befunde")
- `befund`: Das im selben Absatz stehende Kommando liefert über dem Baum, der den Absatz enthält,
  **128**, nicht 122. Gemessen mit genau dem abgedruckten Kommando über einem frischen Klon von
  `f5189bba`:

  ```sh
  DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
  git clone --local --no-hardlinks . /tmp/probe-fresh
  sed -i 's/roots: \[spec, docs, harness\]/roots: [spec, docs, harness, .harness]/' /tmp/probe-fresh/.d-check.yml
  docker run --rm --network none -v /tmp/probe-fresh:/repo:ro "ghcr.io/pt9912/d-check@${DIGEST}" \
    | grep -c codepath-missing        # 128
  ```

  Derselbe Lauf über `f5189bba^` liefert **122**. Die Differenz von sechs entsteht **im
  schreibenden Commit selbst**: der neue README-Absatz nennt `.harness/cache/` und
  `.harness/state/` als Inline-Code (2 Befunde), der umgeschriebene Slice-Plan weitere vier
  (dreimal `.harness/state/`, einmal `.harness/cache/`, einmal der erfundene Sonden-Pfad, minus
  eine bereits vorher gezählte Zeile). Die Zahl war über dem Vorgänger-Baum richtig und ist über
  dem Baum, von dem sie spricht, falsch. Die Kennzeichnung „kein Erwartungswert, wandert mit dem
  Bestand" erfüllt Setzung 2, hebt Setzung 1 nicht auf.
- `verifizierbar`: nein — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) hält
  eine Zahl in Prosa gegen einen Lauf; [`MR-025`](../../harness/conventions.md#mr-025) §Kein
  Wächter stellt das für sich selbst fest. Der Befund ist **reproduzierbar**, aber nicht
  gate-gedeckt.
- `klasse`: Zahl ohne Kommando trifft ihren Gegenstand nicht

### HIGH-2 — Der Verwerfungs-Beleg zählt fünf Instanzen genau der gesuchten Bug-Klasse zu den „drei Klassen, die kein Bug sind"

- `kategorie`: HIGH
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  Slice-Plan §1, dritter Ausschluss (*„Der Bestand toter Baseline-Pfade. Findet die Messung welche,
  sind sie nachzuziehen — findet sie viele, ist das ein eigener Vorgang."*)
- `pfad`: `harness/README.md:102-116`
- `befund`: Der Absatz sagt „**122** zusätzliche Befunde, **fast alle** aus drei Klassen, die kein
  Bug sind" und führt als erste Klasse „content-gefrorene Verweise auf abgelöste Baseline-Tags **in
  den einzelnen `harness/conventions/`-Einträgen**". Über der Fundmenge desselben Laufs gemessen:

  ```sh
  L=/tmp/lauf-c.txt   # Ausgabe des Kommandos aus HIGH-1
  grep codepath-missing $L | awk -F'\t' '$2 ~ /^\.harness\/(baseline|state|cache)/' | wc -l   # 102
  grep codepath-missing $L | awk -F'\t' '$2 !~ /^\.harness\/(baseline|state|cache)/' | wc -l  #  26
  grep codepath-missing $L | awk -F'\t' '$2 ~ /^\.harness\/baseline\//{split($1,a,":"); print a[1]}' \
    | grep -vE '^(harness/conventions/|docs/plan/adr/)' | sort                                #   5 Quellen
  ```

  102 von 128 liegen in den drei genannten Klassen, **26 außerhalb**. Und von den 30
  Baseline-Tag-Treffern liegen **fünf** weder in `harness/conventions/` noch in einer nach
  [`AGENTS.md`](../../AGENTS.md) §3.4 eingefrorenen ADR, sondern in **lebenden** Artefakten:
  je einer in den offenen Slice-Plänen `slice-114`, `slice-151` und im offenen Welle-Plan
  `welle-09`, zwei in `slice-134`; alle nennen `.harness/baseline/v5.18.0/…` bzw.
  `.harness/baseline/v5.12.0/…`, während `ls .harness/baseline/` genau `v6.5.0` ausgibt. Das ist
  wörtlich der Fall, den derselbe Absatz zwei Sätze weiter oben als den tragenden benennt („Ein
  toter Inline-Baseline-Pfad in einem **lebenden** Artefakt … bleibt darum dauerhaft
  gate-unsichtbar"). Ein sechster Treffer derselben Klasse steht in einem anderen Baum:
  `.harness/skills/reviewer.md` nennt `.harness/skills/reviewer.template.md`, und diese Datei
  existiert nicht (`ls .harness/skills/` → `reviewer.md`). Die Messung hat damit den Bestand
  gefunden, den §1 als Bedingung genannt hatte — der Text verbucht ihn als Rauschen, statt ihn
  nachzuziehen oder als eigenen Vorgang zu benennen. Wer den Absatz liest, um die Verwerfung zu
  prüfen, bekommt „alles Rauschen"; die Fundmenge sagt etwas anderes.
- `verifizierbar`: ja — die drei Kommandos oben über der Ausgabe aus HIGH-1; kein Gate-Lauf des
  Repos deckt ihn, weil `codepaths` genau diese Fläche nicht sieht.
- `klasse`: Zusammenfassung stärker als ihre Quelle

### HIGH-3 — Neun von elf DoD-Zeilen sind im Implementations-Commit ersetzt, sechs Häkchen darin gesetzt

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10 (Hard Rule)
- `pfad`: `docs/plan/planning/in-progress/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md`
  §2, Commit `f5189bba`
- `befund`: §3.10 zählt *„die DoD-Häkchen"* ausdrücklich zum Abschluss und bindet ihn an einen
  eigenen Commit, der ausschließlich Closure-Artefakte berührt und die Rolle nennt. Gemessen:

  ```sh
  F=docs/plan/planning/in-progress/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md
  git show f5189bba -- $F | grep -c '^+- \[x\]'   # 6  neu gesetzte Haekchen
  git show f5189bba -- $F | grep -c '^-- \[ \]'   # 9  ersetzte DoD-Zeilen
  git show f5189bba:$F   | grep -c '^- \['        # 11 DoD-Zeilen gesamt
  git show --pretty=format: --name-only f5189bba  # 3 Dateien: Plan, roadmap.md, harness/README.md
  ```

  Der Commit trägt die Arbeit **und** die Abnahme. Über die vom Auftrag genannten sechs Häkchen
  hinaus sind vier Änderungen **Abnahme-verschiebend** im Sinne des §3.10-Absatzes *„die
  ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um"*: (a) Liefer-Punkt 2 verliert
  seine Schutzklausel *„Ein dritter Ausgang existiert nicht: Wird weder geprüft noch benannt,
  bleibt eine Vollständigkeits-Zeile stehen, die mehr behauptet als sie trägt"*; (b) die
  Bedingungszeile *„Doku-Update für <Schnittstelle X> falls öffentlicher Vertrag berührt"* ist
  durch die Beschreibung des Ergebnisses ersetzt, das Kriterium ist damit nicht mehr lesbar;
  (c) der Reconciliation-Punkt verliert die Begründung, warum sein Pfad als **Kommando-Operand**
  steht — ausgerechnet die Stelle, die die Achse beschreibt, auf der `codepaths` greift; (d) vier
  Punkte bekommen die Zuschreibung „**Planner-Arbeit**", einer davon zusätzlich das Urteil „keine
  neue Beobachtung". Die Zuschreibungen sind der Sache nach richtig; geschrieben hat sie die
  Rolle, deren Abnahme sie regeln.
- `verifizierbar`: nein — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) liest
  Commits, und `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt; §3.10 stellt
  das für sich selbst fest. Die Kommandos oben sind reproduzierbar, ein Gate-Lauf deckt sie nicht.
- `klasse`: fremdes Rollen-Artefakt im Implementations-Kontext

### MEDIUM-1 — Die Gate-Tabellen-Zeile für `make docs-check` trägt die Einschränkung nicht

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  die Form-Vorlage steht in derselben Datei
- `pfad`: `harness/README.md:46`
- `befund`: Die Zeile lautet unverändert *„Doku-Referenzen grün (links/anchors/ids/codepaths),
  netzlos"*. Zwölf Zeilen darunter trägt die Zeile für `make comment-claims` genau den Zusatz, den
  dieser Fall verlangt: *„— **im Prüfbereich**, und der ist enger als der Gate-Stempel (s. u.)"*.
  Der neue Absatz steht 50+ Zeilen weiter unten im Fließtext. Wer die Tabelle liest — die Stelle,
  an der das Gate seine Zusage macht —, sieht eine uneingeschränkte Zusage; die Einschränkung
  findet nur, wer den Fließtext ganz liest. Die Frage *„ist die Grenze am richtigen Ort benannt"*
  ist damit für den Fließtext bejaht und für die Zusage-Zeile verneint.
- `verifizierbar`: nein — kein Modul hält die Gate-Tabelle gegen den Fließtext; `slice-124` führt
  die fehlende Tabellen-Deckung als eigenen offenen Vorgang.
- `klasse`: Vollständigkeits-Zusage misst falsche Ebene

### MEDIUM-2 — Die benannte Grenze verweist auf einen Folge-Slice ohne Kennung, obwohl §8 den Ausgang für diesen Slice zugesagt hatte

- `kategorie`: MEDIUM
- `quelle`: Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice, Ausschluss-Klasse 1
  (*„Ein Folge-Slice übernimmt es — mit Kennung. Das macht aus ‚später‘ eine Adresse."*);
  Slice-Plan §8
- `pfad`: `harness/README.md:116`
- `befund`: Der Absatz endet mit *„bleibt gate-unsichtbar, bis ein Folge-Slice diese drei
  Ausnahme-Klassen einzeln trägt"* — ohne Kennung. Im Lifecycle existiert keine solche Adresse:
  `git grep -ln 'slice-201' -- 'docs/plan/planning/open' 'docs/plan/planning/next'` ist leer
  (Exit 1), und keiner der 60 Titel in `open/` (`ls docs/plan/planning/open/*.md | wc -l` → 60)
  nennt den Gegenstand. §8 desselben Plans hatte das ausdrücklich anders zugesagt: der Eintrag
  [`BEO-ALL/benannte-luecke-ohne-ausgang`](../plan/planning/observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md)
  ist dort als *„gesichtet und hier relevant"* geführt mit dem Satz *„sie bekommt ihren Ausgang mit
  demselben Slice, nicht später"*. Zugleich wächst genau die Datei, die jener Eintrag misst:
  `git show f5189bba^:harness/README.md | wc -c` → 44661, `git show f5189bba:harness/README.md | wc -c`
  → 47768 (+3107 B); der Eintrag beziffert dieselbe Datei zum Zeitpunkt seiner Anlage mit 39427 B
  und hält fest, dass alle drei Anweisungssätze sie in ihrem ersten Schritt lesen.
- `verifizierbar`: nein — die Register-Paarung prüft zitierte Kennungen, nicht die Existenz eines
  versprochenen Folge-Slice; ein Gate über Prosa-Zusagen führt das Repo nicht.
- `klasse`: benannte Lücke ohne Ausgang

### MEDIUM-3 — Die Messung widerlegt zwei Sätze im lebenden Beobachtungs-Register, und die Widerlegung hat nur ein Zeitdokument als Träger

- `kategorie`: MEDIUM
- `quelle`: Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register;
  [`AGENTS.md`](../../AGENTS.md) §3.7 *Dieselbe Regel für Zustandsfelder*
- `pfad`:
  [`BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht`](../plan/planning/observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/observation.md)
  und dessen `state.md`
- `befund`: Die `observation.md` führt zwei Ursachen: *„`codepaths` führt `roots: [spec, docs,
  harness]` … und `scan.ignore` nimmt `.harness/baseline/**` als Ziel ohnehin aus."* Die zweite ist
  durch die Sonde widerlegt — mit `roots: [spec, docs, harness, .harness]` färbt
  `.harness/baseline/v6.0.0/regelwerk/does-not-exist-201.md` rot, obwohl `scan.ignore` unverändert
  steht, und im selben Lauf lösen 30 **existierende** Ziele unter `.harness/baseline/` stumm auf.
  Die `state.md` sagt zudem *„`codepaths` erreicht die **Quell-Dateien** nicht"*; gemessen ist das
  Gegenteil — die Quelldatei wird gelesen, nicht erkannt wird das **Ziel**. Die Widerlegung steht
  heute nur in DoD 1 des Slice-Plans, also in einem Artefakt, das mit der Closure zum Zeitdokument
  wird; das lebende Register behält den widerlegten Satz. `observation.md` ist ab Anlage
  unveränderlich, `state.md` nicht — der Ort für die Korrektur existiert also.
- `verifizierbar`: ja — das Sonden-Paar oben; kein Gate-Lauf des Repos prüft die Sachaussagen eines
  Register-Eintrags.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### MEDIUM-4 — Die Werkzeug-Aussage im lebenden Artefakt nennt den Stand nicht, gegen den sie gemessen ist

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit);
  [`MR-053`](../../harness/conventions.md#mr-053) Setzung 2 **als Analogie** — sein
  Geltungsbereich sind die Einträge des Adaptions-Blocks, `harness/README.md` fällt nicht darunter
- `pfad`: `harness/README.md:97-100`
- `befund`: Der abgedruckte Ablauf gewinnt den Digest zur Laufzeit aus
  [`d-check.mk`](../../d-check.mk) — das ist die richtige Antwort auf Setzung 1 (keine zweite
  Fassung des lebenden Pins) und ist hier **kein** Befund. Was fehlt, ist die andere Hälfte: der
  Absatz nennt nirgends, unter welchem Werkzeug-Stand die Zahl entstanden ist. Zieht der Pin
  weiter, misst dasselbe Kommando mit einem anderen Werkzeug, und kein Leser kann unterscheiden,
  ob eine abweichende Zahl vom Baum oder vom Werkzeug kommt. Der Slice-Plan macht es an derselben
  Stelle richtig (*„`sha256:e31a372b…`"* in DoD 1) — das lebende Artefakt, das den Pin-Wechsel
  überleben muss, hat die Angabe nicht, das einfrierende hat sie. Setzung 1 erlaubt die zulässige
  Form ausdrücklich: der Stand als **Mess-Operand** (*„über `v0.74.1` gemessen"*).
- `verifizierbar`: nein — das Modul mit diesem Vertrag (`versions`) liegt im gepinnten Bild und ist
  nicht in `modules:` aktiviert (`grep -n '^modules:' .d-check.yml`).
- `klasse`: Aussage über das gepinnte Werkzeug ohne Blick in seinen Stand

### MEDIUM-5 — Die Commit-Message trägt eine Messwert-Zahl ohne Kommando und mit falschem Wert

- `kategorie`: MEDIUM
- `quelle`: [`MR-051`](../../harness/conventions.md#mr-051) Setzung 1 (aktiv seit 2026-09-05,
  Cutoff ab dem Eintrag)
- `pfad`: Commit-Message `f5189bba`, Absatz 1
- `befund`: Die Message behauptet *„auf einem frischen Klon meldet sie 122 zusaetzliche Befunde"*.
  Setzung 1 verlangt, dass die Message das Kommando **im Klartext** trägt und dass es über dem
  Baum gefahren wurde, von dem sie spricht — beides fehlt: kein Kommando steht in der Message, und
  der Wert über dem Baum dieses Commits ist 128 (HIGH-1). Die Message ist gepusht
  (`git rev-parse HEAD origin/main | uniq -c` → eine Zeile) und damit nach dem eigenen Wortlaut
  des Eintrags unerreichbar.
- `verifizierbar`: nein — ein Sensor, der eine Message vor dem Commit gegen ihre Behauptungen
  hält, ist als Auflösungs-Trigger von [`MR-051`](../../harness/conventions.md#mr-051) benannt und
  existiert nicht; `slice-121`/`slice-126` führen ihn als offenen Vorgang.
- `klasse`: Zahl ohne Kommando trifft ihren Gegenstand nicht

### LOW-1 — Ein im Implementations-Commit gesetzter Verweis bricht beim vorgeschriebenen Closure-Move

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.11 (*„Und der Ortswechsel wird entschieden, bevor er
  vollzogen wird"*); `harness/tools/slice-mv.sh` §Grenze 3
- `pfad`: Slice-Plan §2, DoD-Zeile `make gates` grün — der Verweis `](roadmap.md)`
- `befund`: Von allen Linkzielen des Plans ist dies das einzige, das aus `in-progress/` auflöst und
  aus `done/` nicht:

  ```sh
  F=docs/plan/planning/in-progress/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md
  grep -ohE '\]\(([^)#]+)(#[^)]*)?\)' $F | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u \
   | while read -r t; do case "$t" in http*|"") continue;; esac
       a=$(realpath -m --relative-to=. "docs/plan/planning/in-progress/$t")
       b=$(realpath -m --relative-to=. "docs/plan/planning/done/$t")
       [ -e "$a" ] && [ ! -e "$b" ] && echo "$t"; done      # roadmap.md
  ```

  `make slice-mv` fängt die Form nicht: `rewrite_outgoing_bare_in_file` greift ausschließlich das
  Muster `](slice-[0-9]…)` (`grep -n "slice-\[0-9\]" harness/tools/slice-mv.sh`). Der Closure-Move
  färbt damit `docs-check` rot, und zwar im Lauf des Planners. Die Klasse steht im Register als
  [`BEO-ALL/verweise-brechen-beim-ortswechsel`](../plan/planning/observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
  auf `verkörpert` — der verkörperte Träger hat an dieser Form ein Loch.
- `verifizierbar`: ja — `make docs-check` nach dem `git mv` nach `done/`; heute noch grün, weil der
  Move aussteht.
- `klasse`: Verweis bricht beim Ortswechsel

### LOW-2 — Zwei Commits lang stand `planning-drift` auf dem Hauptzweig

- `kategorie`: LOW (im Vorlauf INFO; dieselbe Klasse unmittelbar wieder — Kontext-Eskalation)
- `quelle`: Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine (der
  Move landet auf dem Hauptzweig, vor der Arbeit); Slice-Plan §4 Start-Trigger (*„`make gates` ist
  grün"*)
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:11`, Commits `96c0ada2` und `99109d33`
- `befund`: Über frischen Klonen der fünf Commits gemessen (derselbe gepinnte Digest):
  `7caaa867` 1 Befund (`target-missing`, die bekannte Zwei-Commit-Form des `slice-mv`),
  `50b4d4c3` 976/0, `96c0ada2` **3 Befunde**, `99109d33` **1 Befund** (`planning-drift`),
  `f5189bba` 976/0. Der Ruhe-Marker gehört zum Lifecycle-Move, nicht zur Arbeit; nachgezogen hat
  ihn der Implementations-Commit. Die Folge: der Slice hat auf einem roten Baum begonnen — genau
  die Lage, gegen die §4 seinen eigenen Start-Trigger begründet (*„Auf rotem Baum ist nicht
  unterscheidbar, ob die neue Fläche rot färbt oder die alte"*). Die Klasse steht als
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  bei 4× auf `offen`
  (`ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l`
  → 4, kein Erwartungswert) — über der Schwelle und ohne Ausgang.
- `verifizierbar`: ja — die fünf Klon-Läufe oben; der heutige `make docs-check` ist grün und zeigt
  den Zwischenzustand nicht.
- `klasse`: Lifecycle-Move macht ein bewachtes Zustandsfeld falsch

### INFO-1 — Eine Grenze hat keinen roten Zustand; was rot gesehen wurde, ist die Kontrolle

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: Slice-Plan §2, Liefer-Punkt 3 (*„Das Gegenbeispiel ist rot gesehen"*)
- `befund`: §3.6 bindet eine **Zusage** an ihr rot gesehenes Gegenbeispiel. Die gelieferte Aussage
  ist eine Grenze — *„bleibt gate-unsichtbar"* —, und sie kann konstruktionsgemäß nicht rot werden.
  Rot gesehen wurde die **Kontrolle** (`harness/does-not-exist-201.md` färbt `codepath-missing`);
  sie belegt, dass das Instrument lief, und erst zusammen mit der gemessenen Stille belegt sie das
  Loch. Das ist die richtige Beleglage und die Überschrift des Punktes benennt sie falsch. Der
  Punkt stammt aus dem Planner-Text; die Umsetzung erfüllt die Fassung, die derselbe Punkt für den
  Ausgang *Grenze* vorgibt (*„eine benannte Grenze ohne gemessenes Loch ist eine Behauptung"*).
  Kein Verstoß, ein Benennungs-Befund.
- `verifizierbar`: nein — §3.6 hat für diese Achse keinen Sensor.
- `klasse`: Zusage ohne herstellbares Gegenbeispiel

### INFO-2 — `make mutate` nicht gefahren: im Umfang richtig, der Beleg-Slot ist trotzdem entwertet

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §4; `harness/tools/mutate.sh` §Beleg-Schlüssel
- `pfad`: —
- `befund`: Die Begründung trägt: der Diff berührt drei Markdown-Dateien, und kein Fall unter
  `test/mutations/` hat `harness/README.md` als Mutations-Ziel
  (`grep -l 'harness/README\.md' test/mutations/*.sh` liefert zwei Dateien, beide nennen den Pfad
  nur im Kommentar); [`.d-check.yml`](../../.d-check.yml) ist unberührt, `make mutate` steht in
  keiner Gate-Kette, und CI fährt ihn pro Push. Zwei Beobachtungen daneben: die Bezugsmenge des
  Beleg-Schlüssels ist der ganze Baum außer `.harness/state` (`ISOLATION_EXCLUDES=(./.harness/state)`),
  also entwertet **jede** getrackte Änderung den Slot — der nächste Lauf ist ein voller, unabhängig
  vom Dateityp. Und `test/planning-modul-wiring.bats` sowie `test/full-smoke-ausgang.bats` lesen
  `harness/README.md`; sie sind über `make gates` grün gefahren, die Einfügung hat dort nichts
  gebrochen.
- `verifizierbar`: ja — `make gates` (grün, s. u.).
- `klasse`: —

---

## Negativbefunde (geprüft, ohne Befund)

- **Ursachen-Diagnose des Slice.** Sonden-Paar nachgefahren, drei Fixtures, Kontrolle inbegriffen:
  1 Befund gegen 3 Befunde, der `/baseline`-lose Pfad verhält sich wie der `/baseline`-tragende.
  `roots` als Präfix-Zeichenkette ist die Ursache, `scan.ignore` nicht. **Bestätigt.**
- **Die Präfix-Aussage `./`/`../`.** Der README-Satz *„nur existenzgeprüft, wenn er mit einem
  dieser drei Strings oder mit `./`/`../` beginnt"* ist im Slice **nicht** gemessen worden; in
  diesem Lauf nachgeholt: eine vierte Fixture mit `./does-not-exist-201-d.md`,
  `../does-not-exist-201-e.md`, `internal/does-not-exist-201-f.go` und
  `does-not-exist-201-g.md` liefert genau zwei Befunde, die beiden punkt-präfigierten. **Aussage
  trägt.**
- **Der gewählte Ausgang als solcher.** *Benannte Grenze* statt *Prüfer* ist durch die Fundmenge
  gedeckt: eine Aufnahme von `.harness` in `roots` färbt heute rot, und die Mehrzahl der Treffer
  liegt in nach [`AGENTS.md`](../../AGENTS.md) §3.4 bzw. append-only eingefrorenen Artefakten, für
  die dieselbe Ausnahme-Apparatur wie in
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) nötig wäre. Die
  **Entscheidung** ist tragfähig; beanstandet ist in HIGH-2 ihre Darstellung, nicht ihr Ergebnis.
- **[`.d-check.yml`](../../.d-check.yml) unberührt.** `git show --name-only f5189bba` nennt sie
  nicht; damit keine Gate-Lockerung, kein ADR-Bedarf nach [`AGENTS.md`](../../AGENTS.md) §3.5.
- **[`AGENTS.md`](../../AGENTS.md) §3.3.** Move und Inhalt liegen in getrennten Commits
  (`96c0ada2` rein, `99109d33`/`f5189bba` Inhalt) — eingehalten.
- **[`AGENTS.md`](../../AGENTS.md) §3.5.** Keine Schwellen-Senkung: kein `ignore-refs`-Paar, kein
  `scan.ignore`-Eintrag, keine Modul-Deaktivierung.
- **[`AGENTS.md`](../../AGENTS.md) §3.7.** Keine Code-, Config- oder Skript-Kommentare im Diff.
  Das einzige berührte Zustandsfeld ist der Ruhe-Marker der Roadmap; seine Entfernung ist der
  korrekte Zustand (`in-progress/` trägt einen Slice) und trägt keine Chronik. Markdown-Fließtext
  liegt außerhalb des §3.7-Geltungsbereichs.
- **[`AGENTS.md`](../../AGENTS.md) §3.8.** Keine Hard Rule, kein Adaptions-Eintrag, kein ADR-Index
  im Diff.
- **[`AGENTS.md`](../../AGENTS.md) §3.9.** Alle Kommandos des neuen Absatzes sind `git`, `grep`,
  `sed` und `docker run` mit gepinntem Digest — keine Host-Toolchain, kein Paketmanager.
- **[`AGENTS.md`](../../AGENTS.md) §3.11.** Der neue README-Absatz verlinkt den Slice-Plan als Pfad
  — zulässig, `harness/README.md` friert nicht ein, und der Move zieht den Pfad nach. Der Rest der
  §3.11-Prüfung fällt unter LOW-1.
- **Superseded ADRs.** Der Slice referenziert
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) — `Accepted`; keine
  abgelöste Entscheidung im Bezugsfeld.
- **`§1` Out-of-Scope-Disziplin.** Vier Ausschlüsse, je mit Begründung, drei davon mit Adresse
  (`slice-197`, die Phase-3-Stufung, die emittierte Ebene). Der vierte — *„Der Bestand toter
  Baseline-Pfade"* — ist die Bedingung, die HIGH-2 auslöst.
- **Anker und Links des Diffs.** `make docs-check` über `f5189bba`: 976 Dateien, 0 Befunde
  (frischer Klon, gepinnter Digest).
- **Kein Stil-Befund gemeldet.** Formatierung und Wortwahl des neuen Absatzes folgen der Form des
  `comment-claims`-Nachbarabsatzes; kein Konventions-Anker verletzt.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 3 | Zahl ohne Kommando trifft ihren Gegenstand nicht · Zusammenfassung stärker als ihre Quelle · fremdes Rollen-Artefakt im Implementations-Kontext |
| MEDIUM | 5 | Vollständigkeits-Zusage misst falsche Ebene · benannte Lücke ohne Ausgang · Zusage neben geänderter Ableitung bleibt stehen · Aussage über das gepinnte Werkzeug ohne Blick in seinen Stand · Zahl ohne Kommando trifft ihren Gegenstand nicht |
| LOW | 2 | Verweis bricht beim Ortswechsel · Lifecycle-Move macht ein bewachtes Zustandsfeld falsch |
| INFO | 2 | Zusage ohne herstellbares Gegenbeispiel · — |

**Wiederkehrende Klassen für die Slice-Closure §7.** Drei Findings tragen eine Klasse, die im
Register bereits geführt wird und mit diesem Vorgang einen weiteren Beleg bekäme:
`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` (HIGH-1 und MEDIUM-5 sind **ein** Vorgang und
zählen einmal; Stand vor diesem Slice 2×, mit ihm 3× — die Schwelle),
`zusammenfassung-staerker-als-ihre-quelle` (2× → 3×, die Schwelle) und
`fremdes-rollen-artefakt-im-implementations-kontext` (6× → 7×, längst über der Schwelle und auf
`verkörpert` mit ausdrücklich benannter Deckungslücke außerhalb der Closure). Die Zähler sind mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` abgelesen und sind keine
Erwartungswerte. Das Eintragen ist Planner-Arbeit bei der Closure, nicht Sache dieses Reports.

---

## Verdikt

**Blockiert.** Drei HIGH und fünf MEDIUM.

Die **Sache** des Slice trägt: die Diagnose ist gemessen statt gelesen, das Sonden-Paar ist
hermetisch und reproduzierbar, die Kontrolle schließt `scan.ignore` als Ursache aus, und der
Ausgang *benannte Grenze* ist die richtige Wahl für einen Slice dieser Größe. Beanstandet ist
nicht die Entscheidung, sondern ihr **Beleg** und ihre **Ablage**: die tragende Zahl stimmt über
dem Baum, in dem sie steht, nicht (HIGH-1); die Zusammenfassung der Fundmenge verbucht fünf
Instanzen genau der gesuchten Bug-Klasse als Rauschen (HIGH-2); und die Abnahme ist im Lauf
geschrieben worden, der die Arbeit tat (HIGH-3).

HIGH-1 und HIGH-2 sind in `harness/README.md` behebbar. HIGH-3 ist es nicht mehr vollständig — der
Commit ist gepusht; was bleibt, ist die Übergabe an den Planner: die neun ersetzten DoD-Zeilen und
die vier Rollen-Zuschreibungen sind vom Planner zu prüfen, bevor der Slice nach `done/` geht, und
die vier Punkte, die HIGH-3 (a)–(d) nennt, sind Übergabe-Artefakte und keine erledigte Arbeit.
MEDIUM-5 ist nicht mehr behebbar und steht als Beleg.

Für die Closure liegen damit zwei Posten beim Planner, die kein Finding dieses Reports erledigt:
der Ausgang für die neu erzeugte benannte Lücke (MEDIUM-2) und die Korrektur des
`state.md`-Satzes im Register-Eintrag (MEDIUM-3).

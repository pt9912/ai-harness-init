# Review (nachträglich): slice-178 — die regierende Fassung des Sprungs `v5.18.0` → `v6.0.0`

**Rolle:** Unabhängiger Reviewer (Harness Modul 10) — Diff gegen Plan + ADRs + Hard Rules
(**nicht** DoD; das ist Verifier-Rolle).

**Datum:** 2026-09-05 · **Reviewer:** Claude, frischer Kontext, keines der geprüften Artefakte
selbst geschrieben.

**Besonderheit dieses Laufs.** Der Slice liegt bereits in `done/`. Er wurde in einem isolierten
Worktree von einem Architect-Lauf bearbeitet **und von demselben Lauf geschlossen** — ohne die
Übergaben `I→R` und `R→I` aus Modul 8. Dieser Report holt die Reviewer-Runde **nachträglich** nach.
Er blockiert keinen Merge (der ist vollzogen); sein Gegenstand ist die Konsistenz-Runde, die
[`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) §Der Acceptance-Trigger
selbst als Bedingung ihres Umschlags auf `Accepted` nennt.

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `798459d~1..HEAD` — der Worktree-Strang (`798459d` … `2eaa885`), der Merge
  `e0ff54f` und die zwei Nacharbeits-Commits `df86429`, `de07232`. Tragende Commits:
  `9ad297a` (ADR-0036 + ADR-Index + `harness/conventions.md`), `ce47aaa` (Closure-Notiz,
  Risiko-Ausgänge, zwei Registerzeilen), `e0ff54f` (Merge-Konfliktlösung: Registerzeilen in die
  Verzeichnis-Form), `de07232` (tote Links, Pfadtiefen).
- **`LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (kein Gate liest, nach welcher Fassung ein Durchgang lief),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag als
  Reproduzierbarkeits-Klammer).
- **Referenzierte ADRs:** [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md)
  (`Accepted`), [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  (`Proposed`), [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
  [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
  [`ADR-0030`](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md).
  Keine der referenzierten ADRs ist `Superseded` oder `Deprecated` — `matrix.status` in
  [`.d-check.yml`](../../.d-check.yml) verbietet genau diese zwei.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (ADR ab `Accepted`
  immutabel), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (ein Kommentar/Zustandsfeld
  beschreibt, was da ist), §3.8 (Architect-Commit-Zuschnitt), §3.9 (Docker-only).
  Dazu [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und 2.
- **Vorherige Findings am gleichen Modul:** die Review-Runde zu `slice-182` vom selben Tag
  ([`2026-09-05-slice-182-baum-tausch-v600-review.md`](2026-09-05-slice-182-baum-tausch-v600-review.md))
  meldete **dreimal** dieselbe Klasse — MEDIUM-2 *„Die Provenienz- und Inventur-Zahlen der
  Commit-Messages halten der Nachmessung nicht stand"*, LOW-1 *„Zahl ohne Kommando"*, LOW-2
  *„… aus dem Text nicht reproduzierbar"*. Im Register läuft sie als
  [`BEO-015`](../plan/planning/observations/BEO-015/zahl-neben-nie-gefahrenem-kommando/observation.md)
  und steht dort auf **3×** (Belege `slice-147`, `slice-148`, `slice-182`), Schwelle erreicht.
- **Slice-Plan:** [`docs/plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md`](../plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md).

**Gate-Lauf:** `make gates` → **EXIT 0** (Docker-only, §3.9). Darin `d-check: 774 Datei(en) geprüft, 0 Befund(e)` und `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`; `span-check` als letzte Stufe grün. Zweimal gefahren — vor und nach dem Schreiben dieses Reports, beide Male EXIT 0.

---

## Findings

### HIGH-1 — Die Kosten-Zahl in Option C wird von dem Kommando, das neben ihr steht, nicht ausgegeben

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:284` (§Verglichene
  Alternativen, Option C)
- **befund:** Die Zeile behauptet *„eine ADR, auf die **62** Verweis-Vorkommen aus **16** lebenden
  Dateien zeigen"* und druckt das Kommando daneben. Über dem Baum, in dem die Zahl steht, gibt das
  Kommando **80** Vorkommen aus **17** Dateien aus (Commit `9ad297a`, der die Datei anlegt); heute
  gibt es **77** aus **16** aus. **62** entstand am Commit **davor** (`ec0862a`) — also über einem
  Baum ohne diese Datei; ihre eigenen **17** Verweise auf `ADR-0018` sind die Differenz.
  MR-025 Setzung 1 verlangt, dass das Kommando *„über dem Baum gefahren"* wurde, *„von dem sie
  spricht"*; die Setzung-2-Klausel daneben (*„beide wandern"*) deckt eine wandernde Zahl, nicht
  eine, die in ihrem eigenen Baum nie gefallen ist.
- **verifizierbar:** **nein** — kein Gate-Modul liest Zahlen (`.d-check.yml` führt
  `links, anchors, ids, matrix, codepaths, spans`). Reproduzierbar per Kommando:
  ```sh
  for c in ec0862a 9ad297a HEAD; do
    printf '%s ' "$c"
    git grep -oE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' "$c" \
      -- ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
  done            # -> ec0862a 62 · 9ad297a 80 · HEAD 77
  grep -c '0018-ziel-fassung-regiert-die-migration\.md' \
    docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md   # 17 eigene Verweise
  ```
- **klasse:** *Zahl neben nie gefahrenem Kommando* — deckungsgleich mit
  [`BEO-015`](../plan/planning/observations/BEO-015/zahl-neben-nie-gefahrenem-kommando/observation.md).
- **Warum HIGH und nicht MEDIUM.** Drei Verstärker, jeder einzeln benannt: (a) die Klasse steht im
  Register auf **3×** und wurde von diesem Slice weder in §8 gesichtet noch in §7 erhöht — die
  Sichtung führt `BEO-019`, `BEO-027`, `BEO-016` und nicht `BEO-015`; (b) dieselbe Klasse war in der
  Vorrunde zu `slice-182` dreimal Befund (Kontext-Eskalation, Reviewer-Skill §Kategorien); (c) mit
  dem Umschlag auf `Accepted` friert [`AGENTS.md`](../../AGENTS.md) §3.4 den Satz ein — der Preis
  der Korrektur springt dann von einer Zeile auf eine Folge-ADR mit `Supersedes`, genau die
  Kostenrechnung, die [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) für
  Proposed-Artefakte ausspricht.
- **Nebenbefund derselben Klasse, nicht Gegenstand dieses Slice:**
  [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Option C druckt
  `39`/`13` neben demselben Kommando; an ihrem Commit `7699001` gibt es **60**/`13` aus. Träger ist
  `slice-171`, nicht dieser Report.

### MEDIUM-1 — „Und die 11 treffen die delegierte Frage" trägt für 9 der 11 Zeilen

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage misst die Eigenschaft, nicht ihre Nähe)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:101` (§Stufe (b), Tabelle)
  und `:120` (der Satz darüber)
- **befund:** Die Tabelle ordnet die Zahl **11** der Zieldatei *„`grundlagen-harness-dateien.md`
  §Konventionsspeicher"* zu, der Satz darunter sagt *„Und die 11 treffen die delegierte Frage"*.
  Gemessen liegen **9** der 11 Netto-Zeilen in §harness/conventions.md als Konventionsspeicher
  (Zeilen 295–301 der neuen Fassung, die Kürzel-Spalten-Prosa) und **2** in §Verzeichniskonvention
  (Zeile 14, Planning-Layout `observations.md` → `observations/`) — einem Abschnitt, in den der
  §Freshness-Audit **nicht** delegiert (seine neun Verweise zeigen auf
  `#harnessconventionsmd-als-konventionsspeicher`, `#harnessreadmemd-als-einstiegspunkt`,
  `modul-07-carveouts.md`, `modul-04-adrs.md`, `grundlagen-bootstrap.md`). Die Zahl ist
  **datei**-skopiert, ihr Etikett **sektions**-skopiert.
- **verifizierbar:** **nein** (kein Gate); reproduzierbar:
  ```sh
  git show d75cd8c^:.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md > /tmp/ghd.alt
  diff -u /tmp/ghd.alt .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | grep '^@@'
  # -> @@ -1,5 +1,5 @@ (Herkunfts-Kommentar) · @@ -11,7 +11,7 @@ · @@ -292,8 +292,13 @@
  grep -n '^### ' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
  # -> §Verzeichniskonvention ab 4 · §harness/conventions.md als Konventionsspeicher ab 219
  ```
- **klasse:** *Mess-Skopus der Zahl weicht vom Skopus ihres Etiketts ab*
- **Was davon nicht fällt:** Der tragende Grund 1 der Entscheidung ist file-skopiert formuliert
  (*„die einzige der vier Zieldateien mit einem Regel-Delta"*) und bleibt richtig; die 9 Zeilen in
  der delegierten Sektion sind genau der Kippsatz *„Die Spalte ist nicht bedingt."* Die Festlegung
  trägt, die Zahl daneben nicht.

### MEDIUM-2 — Der `BEO-040`-Befund verengt nicht nur einen Satz des Kontexts von ADR-0031

- **kategorie:** MEDIUM
- **quelle:** Maintainability (Fundort statt Fundmenge) · Baseline-Regelwerk
  `modul-06-roadmap.md` §Das Beobachtungs-Register (der Eintrag ist die Grundlage des Lese-Schritts)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:167–174`
  (§*Was daraus folgt und was nicht*) sowie wortgleich
  `docs/plan/planning/observations/BEO-040/regel-delta-zaehlt-herkunfts-kommentar-mit/state.md`
- **befund:** Beide sagen, der Netto-Befund *„verengt einen Satz ihres **Kontexts**, nicht ihre
  Festlegung"*, und benennen als Fundort
  [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) §Kontext.
  Die beanstandete Mehrzahl steht dort aber **dreimal**, davon einmal in der **Entscheidung** als
  tragender Grund von Festlegung 1: *„sie delegiert vier Fragen in Abschnitte, die ein Delta haben"*
  (Zeile 154), dazu §Kontext Zeile 65 und §Konsequenzen Zeile 215. Wer die Verengung nach dieser
  Beschreibung ausführt, fasst §Kontext an und lässt den Satz in §Entscheidung stehen.
- **verifizierbar:** **nein** (kein Gate); reproduzierbar:
  ```sh
  grep -n -e 'die haben ein Delta' -e 'Delegate haben ein Delta' \
       docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md   # 65, 215
  sed -n '153,155p' docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md
  # -> "... sie delegiert vier Fragen in Abschnitte, die ein Delta / haben, ..." (Sektion: ## Entscheidung)
  ```
- **klasse:** *Befund nennt einen Fundort, wo eine Fundmenge steht*
- **Was davon nicht fällt:** Die **Festlegung 1** von ADR-0031 bleibt tragfähig — ein Delegat hat
  ein echtes Regel-Delta, und ihr zweiter Grund (Baum nicht mehr vendored) trägt unabhängig. Die
  Aussage *„bleibt unberührt"* stimmt für das Ergebnis; falsch ist die Ortsangabe des Defekts, und
  die liest `slice-171` als Zuschnitt seiner Arbeit — bevor jene Datei nach `Accepted` einfriert.

### MEDIUM-3 — §Kopplung beschreibt einen Zustand, den derselbe Commit aufgehoben hat

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*„Beschrieben wird die Stelle … im Indikativ über
  den Zustand"*) · §3.4 (Einfrieren ab `Accepted`)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:31–33`
- **befund:** §Kopplung sagt *„§Baseline von `harness/conventions.md` führt **heute** den Zustand
  *offen* für die regierende Fassung dieses Sprungs. Die Folgepflicht unten wechselt diesen
  Zustand."* Der Vermerk *offen* stand nur bis `9ad297a^`; derselbe Commit `9ad297a` ersetzt ihn
  durch *„Die Prozedur des Sprungs auf `v6.0.0` stellt die Ziel-Fassung"*. §Konsequenzen derselben
  Datei sagt es ausdrücklich: *„Folgepflicht (Architect), **im selben Commit eingelöst**"*. Die
  Datei widerspricht sich damit über ihren eigenen Kopplungs-Gegenstand.
- **verifizierbar:** **nein** (kein Gate); reproduzierbar:
  ```sh
  git show 9ad297a^:harness/conventions.md | grep -c 'ist offen'   # 1
  grep -c 'ist offen' harness/conventions.md                       # 0
  ```
- **klasse:** *Präsens-Aussage über ein lebendes Artefakt in einem einzufrierenden Text* —
  deckungsgleich mit
  [`BEO-024`](../plan/planning/observations/BEO-024/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md)
  (1×, offen), das genau diese Fehlerrichtung führt: *„die Aussage altert nach dem Einfrieren, und
  niemand darf sie mehr korrigieren"*.

### MEDIUM-4 — Der Closure-Commit trägt das Architect-Label über Planner-Artefakten

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für einen Slice
  (`I→R→Vf→P`, *„Closure in `done/` + Lerneintrag"* beim Planner) und §Rollen-Regeln
  (*„kein Rollenwechsel ohne Übergabe-Artefakt"*)
- **pfad:** Commit `ce47aaa` („Rolle Architect: slice-178 — Closure-Notiz, drei Risiko-Ausgaenge,
  zwei neue Registerzeilen"): `done/slice-178-…md`, `docs/plan/planning/observations.md`,
  `docs/plan/planning/welle-15-re-baseline.md`
- **befund:** Derselbe Kontext, der die Norm schrieb (`9ad297a`), hat den Slice auch geschlossen —
  Closure-Notiz, Risiko-Ausgänge, Registerzeilen und §5 des Welle-Plans —, und danach den `git mv`
  nach `done/` gefahren (`8e5f18f`). Zwischen Implementation und Closure liegt kein
  Übergabe-Artefakt; die Kanten `I→R` und `R→I` fehlen ganz. Der Welle-Plan ist zudem kein
  Architect-Artefakt: Modul 8 §Rollen-Sequenz für eine Welle weist alle Welle-Plan-Schritte dem
  Planner zu.
- **verifizierbar:** **nein** — kein Gate liest Commits (`.d-check.yml` führt kein Commit-Modul,
  `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt; das benennt
  [`AGENTS.md`](../../AGENTS.md) §3.8 selbst). Ablesbar an `git show --stat ce47aaa`.
- **klasse:** *Rollenwechsel ohne Übergabe-Artefakt*
- **Abgrenzung, damit die Quelle stimmt:** [`AGENTS.md`](../../AGENTS.md) §3.8 ist **nicht**
  verletzt — sie bindet Commits, die Hard Rules oder den Adaptions-Block berühren, und `ce47aaa`
  berührt keines von beiden. [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)
  ist ebenfalls **nicht** verletzt: sie sagt über andere Norm-Artefakte als diese zwei ausdrücklich
  *„**keine** Aussage"*. Träger dieses Befundes ist allein die adoptierte Baseline, Modul 8.
  (Die Zuschreibung *„fremdes Eigentum (Planner,
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md))"* in ADR-0031 Option F ist
  von jener ADR nicht gedeckt — Nebenbefund für `slice-171`, nicht für diesen Slice.)

### LOW-1 — Die Merge-Konfliktlösung behandelt vier gleichartige Register-Verweise auf zwei Arten

- **kategorie:** LOW
- **quelle:** [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4
  (analog angewandt, so wie `de07232` sie selbst zitiert) · die in `ed0a661` erklärte
  Migrationsregel *„Zeitdokumente … haben die Adresse verloren und den Text behalten"*
- **pfad:** `docs/plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md:140` und `:242`
- **befund:** `slice-178` liegt in `done/` und ist damit Zeitdokument. Zwei seiner vier
  Register-Verweise wurden im Merge auf `[Register](../observations/README.md)` **umgehängt**
  (Zeilen 140, 242), die zwei anderen in `de07232` **entlinkt** (Zeilen 161, 195). Es ist die
  einzige Datei unter `done/`, die eine lebende Adresse auf das Register trägt.
- **verifizierbar:** **nein** — `make docs-check` ist in beiden Formen grün (das Ziel löst auf).
  Reproduzierbar: `grep -rn 'observations/README\.md' docs/plan/planning/done/` → zwei Treffer,
  beide in dieser Datei.
- **klasse:** *Korrektur nennt einen Fundort, nicht die Fundmenge*

### LOW-2 — `BEO-041` führt „Benannt, nicht gezählt" in `state.md` statt in `observation.md`

- **kategorie:** LOW
- **quelle:** Ziel-Form
  [`observation.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/planning/observation.template.md)
  (§`observation.md` — die Identität trägt `## Benannt, nicht gezählt`) ·
  `modul-06-roadmap.md` §Das Beobachtungs-Register (drei Dateien, drei Lebensdauern)
- **pfad:** `docs/plan/planning/observations/BEO-041/proposed-adr-annahme-ohne-repo-internen-traeger/state.md`
- **befund:** Bei der Überführung aus der flachen Tabelle ist der Absatz *„**Benannt, nicht
  gezählt:** dieselbe Lage führen die Closure-Notizen von slice-163 … und der Nachbarfall
  slice-152"* in `state.md` gelandet. Die Vorlage weist ihn `observation.md` zu — der
  unveränderlichen Datei. Der Inhalt steht damit in der Datei mit der falschen Lebensdauer:
  ein späterer Ausgang überschreibt `state.md`, und die benannten Vorkommen verschwinden mit ihm.
  Es ist das einzige `state.md` des Registers mit dieser Überschrift, und kein `observation.md`
  trägt sie.
- **verifizierbar:** **nein** (kein Gate liest die Ablage-Form).
  `grep -rl 'Benannt, nicht gezählt' docs/plan/planning/observations/*/*/state.md | wc -l` → 1;
  dieselbe Abfrage über `observation.md` → 0.
- **klasse:** *Migration verteilt Feld auf die falsche Lebensdauer*

### LOW-3 — Der zitierte Nachweis „wer annimmt, sagt keine Quelle" reproduziert seine Zahlen nicht mehr

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (mittelbar — die Zahl steht in der eingefrorenen ADR-0018, der Verweis darauf in dieser)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:273–276`
  (§Der Acceptance-Trigger)
- **befund:** Die Datei stützt *„Wer annimmt, sagt keine Quelle dieses Repos"* auf die Messung in
  [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Geschichte (*„**eine** Datei,
  **3** Zeilen"*) und sagt, sie werde *„hier nicht gedoppelt"*. Heute gibt dasselbe Kommando **vier**
  Dateien mit **zehn** Zeilen aus, darunter eine im vendored Baum `v6.0.0`. Inhaltlich hält die
  Aussage — alle vier Treffer gehören zur Change-Request-Familie um das Lastenheft, die
  Baseline-Zeile spricht vom *annehmenden Akt* eines CR, nicht von der ADR-Statuszeile —, aber wer
  den zitierten Nachweis nachfährt, landet zuerst auf einem scheinbaren Widerspruch im Regelwerk.
- **verifizierbar:** **nein** (kein Gate); reproduzierbar:
  ```sh
  git grep -cniE -e 'annehmend' -e 'Accept-Akteur' -e 'nimmt die ADR an' -e 'setzt den Status' \
    -- spec AGENTS.md CLAUDE.md harness README.md docs/plan/adr/README.md .harness/baseline
  # -> 4 Dateien (grundlagen-source-precedence.md:1, MR-015:3, MR-036:3, MR-042:3)
  sed -n '199,201p' .harness/baseline/v6.0.0/regelwerk/grundlagen-source-precedence.md
  ```
- **klasse:** *Zitierter Nachweis altert, ohne dass die zitierende Stelle ihn nachhält*

### INFO-1 — `BEO-041` bucht einen abgeschlossenen Vorgang als „benannt, nicht gezählt"

- **kategorie:** INFO
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
- **pfad:** `docs/plan/planning/observations/BEO-041/proposed-adr-annahme-ohne-repo-internen-traeger/state.md`
- **befund:** Die Regel reserviert *„benannt, nicht gezählt"* für ein *„Vorkommen **ohne**
  abgeschlossenen Vorgang"*. `slice-163` liegt in `done/`, ist also einer; nur `slice-152` liegt in
  `open/`. Der Eintrag steht deshalb auf **1×**, wo die Regel **2×** zuließe. Die Begründung
  (*„rückwirkende Belege vergibt dieser Lauf nicht"*) ist eine bewusste Entscheidung und dokumentiert;
  sie kostet den Zähler aber genau einen Schritt Richtung Schwelle.
- **verifizierbar:** **nein**; ablesbar an
  `ls docs/plan/planning/observations/BEO-041/*/evidence/` → `slice-178.md` und
  `ls docs/plan/planning/done/slice-163-*` → vorhanden.
- **klasse:** *Zähler bleibt unter der Schwelle, weil ein zählfähiger Vorgang als „benannt" gebucht wird*

### INFO-2 — Eine normative Pflicht wird einer `Proposed`-ADR entnommen

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (bindet ab `Accepted`)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:13–16` (§Bezug)
- **befund:** *„ihr erster Re-Evaluierungs-Trigger **verlangt** für diesen Sprung die zweistufige
  Messung, auf der diese Entscheidung steht"* — der Trigger steht in
  [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md), Status
  `Proposed`. Die einzige `Accepted`-Quelle,
  [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3, verlangt nur
  Stufe (a). Stufe (b) ist damit mehr Sorgfalt als gefordert — kein Verstoß —, aber das Wort
  *„verlangt"* nennt als Quelle der Pflicht ein noch nicht angenommenes Dokument.
- **verifizierbar:** **nein**; ablesbar an
  `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-*.md` → `Proposed`.
- **klasse:** *Pflicht mit unangenommener Quelle*

### INFO-3 — Der vierte Re-Evaluierungs-Trigger von ADR-0031 ist ungeprüft geblieben

- **kategorie:** INFO
- **quelle:** [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  §Re-Evaluierungs-Trigger, vierter Punkt
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:246–248`
  (*„deren Festlegung 2 … gilt unverändert"*)
- **befund:** ADR-0036 prüft die Trigger 1 und 3 jener ADR namentlich, den dritten sogar mit
  Kommando. Der vierte lautet *„Wenn §Baseline von `harness/conventions.md` seinen Ort verlässt —
  etwa weil der Adaptions-Block auf die Verzeichnis-Form umgestellt wird … **(beobachtbar daran,
  dass die Einträge je eine eigene Datei bekommen)**"*. Die genannte Beobachtung **ist eingetreten**
  ([`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form),
  `slice-166`; `ls harness/conventions/MR-*.md | wc -l` → 47). Die eigentliche Bedingung ist es
  **nicht** — §Baseline steht unverändert in `harness/conventions.md` (`grep -n '^## Baseline'` → 8),
  und die Buchungszeile liegt dort. Die Festlegung trägt also; ungeprüft geblieben ist, dass sie es
  tut.
- **verifizierbar:** **nein**; die zwei Kommandos oben sind der Beleg.
- **klasse:** *Trigger-Audit nennt eine Teilmenge der fälligen Trigger*

---

## Negativbefunde (geprüft, ohne Befund)

- **`BEO-040`, die Messung selbst — vollständig nachgefahren, alle Werte reproduzieren.**
  §Freshness-Audit byte-gleich (123 = 123 Zeilen, `diff` leer, 7 Eigenschaften); Delegat-Deltas
  `13/2 · 2/2 · 2/2 · 2/2` für diesen Sprung und `17/2 · 2/2 · 2/2 · 2/2` für den davor; die je
  zwei Zeilen bei drei Delegaten **sind** ausschließlich der Herkunfts-Kommentar (URL → relativer
  Pfad, im `diff` sichtbar); `26` Regelwerks-Dateien, `25` mit genau einem `<!-- Quelle:`, 8 in
  Zeile 2 und 17 in Zeile 3; die neun Verweise verteilen sich `3+1` auf
  `grundlagen-harness-dateien.md`, `2+1` auf `modul-07-carveouts.md`, `1` auf `modul-04-adrs.md`,
  `1` auf `grundlagen-bootstrap.md`; `ls -1 .harness/baseline/` → `v6.0.0`; die dreizehn
  Suchbegriffe über das vendored Delta → **0**; `grep -c 'Eine Festlegung'` → **1**. Die Behauptung
  des Befundes stimmt.
- **Kreuzprobe gegen `slice-176` §9.** Die dort am Kurs-Klon erhobenen Netto-Werte
  (`11 · 0 · 0 · 0`) und die hier über die vendored Bäume erhobenen (`13−2 · 2−2 · 2−2 · 2−2`)
  fallen zusammen. Zwei unabhängige Instrumente, ein Ergebnis.
- **Konsistenz gegen ADR-0018 — kein Widerspruch.** Festlegung 3 ist korrekt angewandt: Stufe (a)
  misst die **gepinnte** Fassung (`v5.18.0`, aus `d75cd8c^`), findet die Prozedur, verwirft damit
  den ersten Fall und wählt den zweiten (*„die Wahl ist offen und begründet zu entscheiden"*).
  Festlegung 2 ist nicht umgangen, sondern für beendet erklärt, und das trifft zu (der Tausch liegt
  vor dem Durchgang). Festlegung 4 (fünf Ausgänge / einzelner Adaptions-Eintrag) bleibt ausdrücklich
  unangetastet. Option C (*„stets die Ziel-Fassung"*) bleibt verworfen. Kein `Supersedes` fällig.
- **Konsistenz gegen ADR-0031 — die Festlegungen fallen nicht.** Festlegung 1 ist auf ihren Sprung
  geschlossen und wird nicht angefasst; ihr Ergebnis trägt weiter, weil ein Delegat ein echtes
  Regel-Delta hat und ihr zweiter Grund unabhängig steht. Festlegung 2 hat ihren Zielort noch
  (§Baseline in `harness/conventions.md`), und die Buchungszeile für `v6.0.0` liegt dort in der
  vorgeschriebenen Drei-Teile-Form (Ziel-Tag `v6.0.0`, Datum `2026-09-04`, Delta-Nachweis
  `slice-176`). Was zu prüfen bleibt, steht als MEDIUM-2 und INFO-3.
- **Status `Proposed` — tragfähig begründet.** Der Acceptance-Trigger steht **in** der Datei statt in
  einem dritten Slice unter `open/` (`git grep -l 'adr/0036-' -- docs/plan/planning/open` → leer),
  und die Begründung *„der Umschlag ist ein Vollzug in der Architect-Rolle auf eine Entscheidung des
  Auftraggebers hin"* deckt sich mit dem, was der Bestand zeigt: sechs ADRs stehen auf `Proposed`,
  und die Accepted-Zeilen von `ADR-0024`, `ADR-0028` und `ADR-0034` führen denselben Vollzugs-Modus.
  `matrix.status` verbietet nur `superseded`/`deprecated`, nicht `Proposed`. Einzig die Alterung des
  zitierten Nachweises ist LOW-3.
- **Commit-Zuschnitt des Norm-Commits `9ad297a` — sauber.** Berührt sind ausschließlich
  `docs/plan/adr/0036-…md`, `docs/plan/adr/README.md` und `harness/conventions.md`; alle drei sind
  Architect-Artefakte ([`AGENTS.md`](../../AGENTS.md) §3.8, der Index über
  [`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
  Die Message nennt die Rolle. Kein fremdes Artefakt reist mit.
- **Merge-Konfliktlösung, inhaltliche Vollständigkeit — in Ordnung.** Beide Registerzeilen aus
  `ce47aaa` sind vollständig in die Verzeichnis-Form überführt: `observation.md` trägt Bezeichnung,
  `Sub-Area` und den Beschreibungstext **wörtlich**; `state.md` trägt den vollständigen Stand-Text
  mit korrekt umgeschriebenen Adressen; `evidence/slice-178.md` gibt je Eintrag genau einen Beleg
  und damit den Zähler `1×`, den die alte Tabellenzelle nannte. Die Struktur entspricht den
  39 übrigen Einträgen des Registers (`ls -d docs/plan/planning/observations/BEO-*/ | wc -l` → 41). Die Pfadtiefen stimmen nach `de07232` (sechs `../` in
  `observation.md`/`state.md`, sieben in `evidence/`) — nachgerechnet und über `make docs-check`
  gedeckt. Formale Restpunkte stehen als LOW-2 und INFO-1.
- **Nacharbeits-Commit `df86429`** — die drei Adaptions-Einträge zeigen auf einen existierenden
  Pfad; die Aussage der Einträge ist nicht angefasst, nur die Adresse. Deckt sich mit
  [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 für lebende Artefakte.
- **Kein halluziniertes Gate.** ADR-0036 §Fitness Function sagt *„Gebaut: keine"* und begründet je
  Kandidaten, warum er nicht misst; die Netto-Frage ist ausdrücklich als *„teilweise
  mechanisierbar, hier nicht gebaut"* markiert. `make comment-claims` hat tatsächlich keine
  Markdown-Datei im Prüfbereich. [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  ist gewahrt.
- **Docker-only.** Kein Host-Paketmanager und keine Host-Toolchain in diesem Review-Lauf; alle
  Gate-Läufe über `make`. Für den geprüften Diff gilt dasselbe — er enthält keine Skript- oder
  Makefile-Änderung.
- **`make gates` → EXIT 0.**
- **Nicht geprüft (fremde Rolle):** die DoD-Abhakung und die Plan-vs-Code-Konformität. Das ist
  Verifikation, getrennter Kontext, anderes Prüf-Artefakt — und für diesen Slice ebenfalls noch
  offen.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Zahl neben nie gefahrenem Kommando (`BEO-015`, dort bereits 3×) |
| MEDIUM | 4 | Mess-Skopus ≠ Etikett-Skopus · Fundort statt Fundmenge · Präsens-Aussage im einzufrierenden Text (`BEO-024`) · Rollenwechsel ohne Übergabe-Artefakt |
| LOW | 3 | Korrektur nennt Fundort statt Fundmenge · Migration verteilt Feld auf falsche Lebensdauer · zitierter Nachweis altert |
| INFO | 3 | Zähler unter Schwelle durch „benannt"-Buchung · Pflicht mit unangenommener Quelle · Trigger-Audit unvollständig |

**Wiederkehrende Klasse dieser Runde:** *„eine Aussage nennt einen Fundort, wo eine Fundmenge
steht"* tritt dreimal auf (MEDIUM-2, LOW-1, und als Mechanismus hinter MEDIUM-1). Nach
Reviewer-Skill §Kontext-Eskalation ist die dritte Wiederholung ein Steering-Loop-Signal; im
Register hat sie heute keine eigene Kennung — `BEO-039` trifft die Nachbarklasse (*Ausgang nennt
Träger, der nicht trägt*), nicht diese. Die Vergabe gehört in die Closure, nicht in diesen Report.

---

## Verdikt

**Blockierend für den Umschlag auf `Accepted`: ja — HIGH-1, und die drei MEDIUM an der ADR selbst
(MEDIUM-1, MEDIUM-2, MEDIUM-3).**

Die **Entscheidung** von ADR-0036 ist tragfähig. Beide Mess-Stufen sind in diesem Review
unabhängig nachgefahren und reproduzieren; die Anwendung von
[`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 auf die Messung
aus `slice-176` §9 ist korrekt; die Abgrenzung gegen
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) ist im Ergebnis
richtig; kein `Supersedes` fällig; kein Widerspruch zu einer aktiven ADR oder einer Hard Rule in
der Sache. Der Befund `BEO-040` stimmt, und er ist der eigentliche Ertrag des Laufs.

Was blockiert, sind **vier Sätze der Begründung, nicht die Festlegung**. Alle vier sind heute mit
je einer Zeile korrigierbar; nach dem Umschlag verbietet [`AGENTS.md`](../../AGENTS.md) §3.4 genau
das und macht aus jedem von ihnen eine Folge-ADR mit `Supersedes` — auf ein Dokument, auf das
bereits 77 Verweis-Vorkommen zeigen. Der Zeitpunkt für die Korrektur ist deshalb **vor** der
Annahme und nicht danach.

**Anlass, ADR-0036 vor der Annahme inhaltlich zu ändern: ja**, an vier Stellen — Option C
(HIGH-1), §Stufe (b) Tabelle und der Satz darüber (MEDIUM-1), §*Was daraus folgt und was nicht*
plus die wortgleiche Stelle in `BEO-040/state.md` (MEDIUM-2), §Kopplung (MEDIUM-3). Das ist eine
**Folge-Konsequenz für einen Architect-Lauf**, kein Selbst-Fix: Dieser Report hat kein Artefakt
angefasst.

MEDIUM-4 (Rollen-Disziplin) trifft nicht die Datei, sondern den Vorgang; sein Ausgang gehört in die
Closure des Slice und nicht in die ADR. LOW-1 bis LOW-3 und die drei INFO blockieren nicht.

**Nicht abgedeckt von diesem Report:** die Verifikation (DoD, Plan-vs-Code) und die Frage, ob die
zwei Nebenbefunde an
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) — die Zahl
`39`/`13` und die ADR-0015-Zuschreibung in Option F — in `slice-171` aufgehen. Beide sind hier
benannt, damit jener Lauf sie nicht neu finden muss.

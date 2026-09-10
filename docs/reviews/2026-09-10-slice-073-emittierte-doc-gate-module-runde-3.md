# Review-Report — slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 3 (Bestätigungs-Runde, enger Umfang)

> Jede Zahl in diesem Report steht neben dem Kommando, das genau sie ausgibt
> ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
> Keine ist ein Erwartungswert. Die d-check-Sonden liefen gegen ein **real gebootstrapptes**
> Ziel außerhalb des Repos, netzlos, Mount `:ro`, über dem in [`d-check.mk`](../../d-check.mk)
> gepinnten Digest. **Kein Grün-Satz dieses Reports stützt sich auf einen Bericht des
> Implementers** — die sieben Herkunfts-Behauptungen sind einzeln nachgemessen, nicht
> übernommen.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `b68db4a5..b323363c` — ein Commit, **2** Dateien
  (`git show --stat b323363c`): `internal/emit/emit.go`, `internal/emit/templates/d-check.yml`.
  Arbeitsbaum sauber (`git status --porcelain` → leer; `--untracked-files=all` → **0**).
  **Der übergebene Baum-Schnappschuss war 27 Commits alt** (`git rev-list --count 3fd42cc4..HEAD`
  → 27) und nannte slice-140; geprüft ist der reale HEAD `b323363c`, 3 Commits vor `origin/main`.
- **Slice-Plan (Repo-Ergänzung):**
  [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md), §2 DoD (1).
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte ADRs, mit selbst gelesenem Status:**
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) — `Accepted`, normativ
  (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0007-*.md` → `3:**Status:** Accepted`);
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) für den
  `mutate`-Beleg.
- **Aktive `MR-*`:** MR-017, MR-020, MR-025, MR-051.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.9, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-10-slice-073-emittierte-doc-gate-module.md) · [Runde 2](2026-09-10-slice-073-emittierte-doc-gate-module-runde-2.md).
  Jeder Runde-2-Befund ist unten einzeln gehalten.

## Stand der Runde-2-Befunde

| Runde-2-Befund | Ausgang in Runde 3 |
|---|---|
| HIGH-1 — Kommentar behauptet eine Messung, die die Quelle nicht trägt | **behoben, alle sieben Behauptungen selbst nachgemessen** → N-1 |
| MEDIUM-1 — „jede Position" an zwei Stellen uneingelöst | **behoben; Begründung selbst nachgemessen und tragfähig** → N-2 |
| MEDIUM-2 — Ursprungs-Repo-Vergleich | **behoben** → N-3 (Rest-Instanz als INFO-1) |
| LOW-1 — `emit.go:47` veraltete Modulliste | **behoben** → N-4 |
| LOW-2 — harter Tag `v6.5.0` | **behoben, Platzhalter im Ziel auflösbar** → N-5 |
| INFO-1 / INFO-2 | unverändert → INFO-2 |

**Der neu geschriebene Block schließt HIGH-1 und führt einen neuen Fehler derselben Klasse ein** —
an einer anderen Stelle desselben Absatzes (HIGH-1 unten).

## Findings

### HIGH-1 — Die Begründung für `exclude-sections` nennt die zwei Klassen, die im frischen Ziel leer sind, und lässt die einzige aus, die der Schlüssel nachweislich schützt

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7,
  [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md) DoD (1),
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
- **pfad:** `internal/emit/templates/d-check.yml:30-33`
- **befund:** Der neue Block begründet den Schlüssel mit *„weil die ADR-/Slice-Vorlagen einen
  Geschichte-/Historie-Abschnitt fuehren, in dem eine legitime rueckwaertige Erwaehnung sonst
  faelschlich als Verstoss zaehlte."* Von den zwei genannten Vorlagen trägt nur die ADR-Vorlage
  einen solchen Abschnitt; die Slice-Vorlage führt **keines der beiden Wörter**, und eine
  Slice-Datei ist Quelle von **null** `matrix`-Regeln — `exclude-sections` kann auf sie nie
  wirken. Die drei Schlüssel-Werte `Historie`/`7. Historie`/`Geschichte` stammen zur Hälfte aus
  `spec/lastenheft.template.md` und `spec/spezifikation.template.md`; genau diese Klasse
  (`spec-straten`) ist im frischen Ziel die **einzige nicht leere**, und sie wird im Kommentar
  nicht genannt.
- **verifizierbar:** ja — dreifach, netzlos:

  ```sh
  # (a) die genannten Vorlagen
  B=.harness/baseline/v6.5.0/templates
  grep -c 'Geschichte\|Historie' "$B"/docs/plan/planning/slice.template.md   # 0  — Slice-Vorlage
  grep -n '^## Geschichte' "$B"/docs/plan/adr/NNNN-titel.template.md         # 118 — ADR-Vorlage
  grep -ln '^#\{1,6\} .*7\. Historie' "$B"/spec/*.template.md                # lastenheft + spezifikation
  # (b) Slice ist Quelle von null Regeln
  grep -c '{from: slice' internal/emit/templates/d-check.yml                  # 0
  ```

  **(c) die Wirkung, an einem real gebootstrappten Ziel gemessen** — derselbe Baum, eine legitime
  rückwärtige Erwähnung in `## 7. Historie` von `spec/lastenheft.md`, einmal mit und einmal ohne
  den Schlüssel:

  ```text
  MIT  exclude-sections:  20 Datei(en) geprüft, 0 Befund(e)
  OHNE exclude-sections:  20 Datei(en) geprüft, 2 Befund(e)
    spec/lastenheft.md:99  ../docs/plan/adr/0001-test.md  matrix-forbidden  Referenz spec-straten → adr
    spec/lastenheft.md:99  slice-001                      matrix-forbidden  Token-Referenz spec-straten → slice
  ```

  Beide Befunde liegen auf einer **Spec**-Datei. Klassen-Bestand desselben Ziels:
  `spec-straten` **3** Dateien, `adr` **0**, `slice` **0**, `welle` **0**. Und die Gegenprobe für
  die Slice-Hälfte: eine Slice-Datei mit rückwärtiger Erwähnung in `## Geschichte` liefert
  ausschließlich `id-unlinked` (aus `ids`), das `exclude-sections` gar nicht regiert — **kein**
  `matrix`-Befund, in keiner Richtung.
  Kein Gate fängt es: `make comment-claims` erreicht `internal/emit/templates/` dauerhaft nicht,
  und `codepaths` liest Markdown, keine YAML-Kommentare.
- **klasse:** Kommentar behauptet eine Messung, die die von ihm genannte Quelle nicht trägt

**Warum das HIGH ist und kein Wortstreit — das Versagen ist im realen Emit auslösbar.** Jedes
frische Ziel hat null ADR- und null Slice-Dateien; das ist der Auslieferungszustand, nicht ein
Randfall. Ein Adopter, der die Begründung liest, prüft seinen Baum, findet keine der zwei
genannten Datei-Klassen und schließt, der Schlüssel sei bei ihm wirkungslos — und entfernt ihn.
Damit verliert er die einzige Unterdrückung, die seine **Spec**-Dateien brauchen. Der Rückfall
ist keine Hypothese: der emittierte `## 7. Historie`-Abschnitt fordert den Adopter in seinem
eigenen Text auf, dort *„eine Zeile hier, mit dem CR unter ‚Verweis'"* zu führen — also genau die
rückwärtigen Verweise, die der Schlüssel ausnimmt. Die erste angenommene Vertragsänderung färbt
sein Gate rot, mit zwei `matrix-forbidden`-Befunden, und die Begründung im Baum sagt ihm, das
könne nicht sein. Dazu kommt der Weg, den Runde 2 schon benannte: Der Architect schreibt aus
diesem Block einen **append-only** Eintrag
([`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)),
dessen Rumpf nachträglich nicht korrigiert wird.

### MEDIUM-1 — Der Paket-Kommentar derselben Datei führt die Modul-Liste weiter, die dieser Slice abgelöst hat, und begründet sie als LH-QA-01-Garantie

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7,
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `internal/emit/emit.go:7-9`
- **befund:** Der Paket-Kommentar sagt: *„.d-check.yml — vom Tool AUTORIERTE minimale Config (nur
  links/anchors; ids/codepaths auskommentiert). Ihre Minimalitaet ist die LH-QA-01-Garantie (kein
  Modul aktiv, das im frischen Repo brechen wuerde)."* Drei Teilaussagen, zwei davon falsch: die
  Liste führt fünf Module, und `ids` ist nicht auskommentiert, sondern aktiv. Die dritte ist eine
  **normative Aussage** — sie macht die Minimalität zum Träger der LH-QA-01-Garantie, während
  dieser Slice die Garantie ausdrücklich auf einen gemessenen Grün-Lauf umstellt. Der Zustand war
  vor `bcf652b9` wahr; **derselbe Slice hat ihn abgelöst** — dieselbe Begründung, mit der Runde-2-
  LOW-1 vierzig Zeilen tiefer in **derselben Datei** behoben wurde.
- **verifizierbar:** ja — die Ablösung ist an ihrem eigenen Commit ablesbar:

  ```sh
  git show bcf652b9^:internal/emit/templates/d-check.yml | grep '^modules:'   # modules: [links, anchors]
  git show bcf652b9:internal/emit/templates/d-check.yml  | grep '^modules:'   # modules: [links, anchors, ids, matrix, spans]
  git show bcf652b9^:internal/emit/emit.go | sed -n '7,9p'                    # wortgleich mit heute
  grep -n 'link-policy' internal/emit/templates/d-check.yml                   # 13 -> ids ist aktiv
  ```

  Kein Gate: `make comment-claims` deckt `internal/**/*.go` im Prüfbereich, prüft aber nur, ob ein
  **genannter Sensor existiert**, nicht, ob die Aussage stimmt.
- **klasse:** Kommentar beschreibt den vom eigenen Slice abgelösten Zustand

**Zur ausdrücklichen Abgrenzung des Implementers.** Sie trägt für zwei der drei benannten
Fundstellen und für diese nicht — die Trennlinie ist messbar, nicht geschmacklich (N-7). §3.10
stützt die Auslassung nicht: die Sektion regelt, wer den **Abschluss** schreibt, nicht welchen
Kommentar ein Implementations-Lauf nachzieht.

### MEDIUM-2 — Die Commit-Message erklärt den `mutate`-Beleg für tragend; gemessen trägt er nicht

- **kategorie:** MEDIUM
- **quelle:** [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md),
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
  [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `b323363c` (Commit-Message, letzter Absatz)
- **befund:** Die Message sagt *„make mutate und make full-smoke nicht erneut gefahren (Beleg aus
  Runde 2 traegt)"*. Der hinterlegte Beleg-Schlüssel und der über dem heutigen Baum berechnete
  stimmen **nicht** überein. `internal/emit/templates/d-check.yml` liegt in der Bezugsmenge
  (`isolation_key_files` → 1 Treffer), und `fingerprint_of_list` hasht **Inhalte**
  (`xargs -0 sha256sum`) — eine reine Kommentar-Änderung bewegt den Schlüssel deshalb ebenso wie
  eine Logik-Änderung.
- **verifizierbar:** ja — am realen, sauberen Baum, zweimal stabil gemessen:

  ```sh
  bash -c 'source harness/tools/mutate.sh; isolation_key'   # 2641b4ce0002…41a68e
  cat .harness/state/mutate-passed.key                      # 9fbf951e58da…631d3f
  bash -c 'source harness/tools/mutate.sh; isolation_key_files | grep -c internal/emit/templates/d-check.yml'   # 1
  ```

  **Instrument-Warnung, weil sie hier zählt:** `harness/tools/mutate.sh:122` setzt `REPO` aus
  `BASH_SOURCE` und überschreibt eine von außen gesetzte Variable. Ein Vergleich zweier
  ausgepackter Stände über die `mutate.sh` des Arbeitsbaums misst darum **zweimal denselben Baum**
  und liefert zwangsläufig Gleichheit; und ein `git archive` trägt die untrackten Dateien nicht,
  die in den Schlüssel eingehen. Belastbar ist allein die Messung am realen Baum — die oben.
- **klasse:** Abdeckungs-Behauptung, die die von ihr genannte Beleg-Quelle nicht trägt

**Verhältnismäßig eingeordnet.** Die **Entscheidung** ist richtig: der Diff berührt keine
Zeile außerhalb eines Kommentars (N-6), also kann kein Mutations-Verdikt kippen, und der
Mechanismus ist fail-closed — der nächste `make mutate` fährt den vollen Satz, statt still grün
zu überspringen. Falsch ist die **Begründung**: sie beruft sich auf einen Beleg, der am heutigen
Baum nicht mehr gilt, statt auf das Argument, das ohne ihn trägt. Gemeldet wird das, weil
[`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
die Commit-Message ausdrücklich an dieselbe Mess-Disziplin bindet wie den Artefakt-Text — und weil
ein Verifier auf genau diesen Satz hin den Lauf auslässt.

### INFO-1 — Der Ursprungs-Repo-Bezug ist als Wort verschwunden, als Kennung nicht

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7,
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- **pfad:** `internal/emit/templates/d-check.yml:7`
- **befund:** *„Dogfood"* ist restlos weg (N-3). In derselben Datei steht weiterhin
  *„gefetchtes Sprachskelett-Staging, **slice-004a**"* — eine Slice-Kennung dieses Repos in einem
  Artefakt, das ein fremdes Repo bekommt und in dem sie gegen nichts auflöst. Das ist dieselbe
  Adressaten-Klasse, die Runde-2-MEDIUM-2 führte, in anderer Form.
- **verifizierbar:** ja — `grep -n 'slice-[0-9]' internal/emit/templates/d-check.yml` → Zeile 7,
  einziger Treffer.
- **klasse:** Emittiertes Artefakt nennt eine Kennung des Ursprungs-Repos

**Kein Befund höherer Stufe, und das ist begründet:** Die Zeile ist **Bestand** — `b323363c` fasst
sie nicht an —, und der Cutoff in [`AGENTS.md`](../../AGENTS.md) §3.7 bindet ausdrücklich nur den
Kommentar, der geschrieben oder geändert wird. Festgehalten, damit die Klasse nicht mit Runde 2
als erledigt verfällt.

### INFO-2 — Die zwei INFO-Befunde aus Runde 2 stehen unverändert

- **kategorie:** INFO
- **quelle:** [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `internal/emit/templates/d-check.yml:43,52` · `harness/README.md:287`
- **befund:** Die `welle`-Positionen haben im frischen Ziel weiterhin einen leeren Prüfbereich
  (`welle` **0** Dateien, s. HIGH-1) — kein `matrix-inactive`, kein Gate-Bruch. Und die
  CI-Beschreibung nennt weiterhin drei Targets, während `.github/workflows/ci.yml` sechs Jobs
  führt. Beide außerhalb dieses Diffs; hier nur festgehalten, damit sie nicht verfallen.
- **verifizierbar:** ja — s. Runde 2, INFO-1/INFO-2.
- **klasse:** Emittierte Klasse mit im Default leerem Prüfbereich · Deckungs-Aussage über einen Nicht-Gate-Sensor

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Runde-2-HIGH-1 ist behoben, und ich habe alle sieben Herkunfts-Behauptungen einzeln
  nachgemessen statt sie zu übernehmen.** Der Selbstwiderspruch ist weg; jede Aussage trägt:

  | # | Behauptung | gemessen |
  |---|---|---|
  | 1 | `order:`/`direction: no-downward` auf der Spec-Klasse | Vorlage Z. 24-25 ✓ |
  | 2 | `token: 'slice-\d{3}'` auf `slice` | Vorlage Z. 31 ✓ |
  | 3 | `{from: adr, to: slice}` | Vorlage Z. 35 ✓ |
  | 4 | `welle` geht über die Vorlage hinaus | `grep -c 'welle'` → **0** ✓ |
  | 5 | `exclude-sections` — Vorlage spricht negativ | Vorlage Z. 37 *„Ohne `exclude-sections`"* ✓ |
  | 6 | `token: 'ADR-\d{4}'` steht in der Vorlage, nicht im Ziel | Vorlage Z. 28; emittiertes YAML **0** ✓ |
  | 7 | `ids` trägt `link-policy: always` für ADR, nichts für `slice` | emittiert Z. 13; Slice-Muster **0** ✓ |

  Zu (4) eine Präzisierung, die den Befund nicht kippt: `grep -ic welle` liefert **1** — der
  Treffer ist *„Welle 119"* in Zeile 72, eine Kurs-Wellen-Nummer im Kommentar des
  `reviews`-Moduls, keine Klasse. Zu (6): ein roher `grep "token: 'ADR"` über die emittierte Datei
  liefert **1**, nämlich die Erwähnung im Kommentar selbst; im YAML sind es **0**
  (`grep -v ':[[:space:]]*#'`). Die Behauptung hält in beiden Fällen.
- **N-2 — Runde-2-MEDIUM-1 ist behoben, und die Begründung trägt — selbst gemessen, nicht
  geglaubt.** Der Block nennt jetzt beide zuvor ausgelassenen Positionen und benennt die
  Asymmetrie ausdrücklich. Die Frage aus dem Auftrag — *fängt `ids` wirklich denselben Fall oder
  einen benachbarten?* — ist an einem realen Ziel entschieden:

  ```text
  blosse ADR-Kennung im normalen Rumpf:            spec/lastenheft.md:18  id-unlinked
  blosse ADR-Kennung im ausgenommenen Historie-§:  spec/lastenheft.md:99  id-unlinked
  verlinkte ADR-Referenz im normalen Rumpf:        matrix-forbidden (Runde 2, reproduziert)
  verlinkte ADR-Referenz im Historie-§:            0 Befund(e)
  ```

  Die Kette schließt: bare → `id-unlinked` → der Adopter verlinkt (der einzige Weg, den `ids`
  annimmt) → `matrix` entscheidet dann abschnittsabhängig richtig. Ein `token: 'ADR-\d{4}'` auf
  der `adr`-Klasse fügte dem außerhalb des Historie-Abschnitts einen **zweiten** Befund für
  dieselbe Zeile hinzu und innerhalb gar nichts (dort ist `matrix` ausgenommen, `ids` nicht). Das
  Wort *redundant* ist damit gedeckt, und die Entscheidung — `token:` bleibt für `slice`, nicht
  für `adr` — ist die richtige. **Eine Lücke bleibt nicht offen**; die zwei Module sind nicht
  deckungsgleich, aber in der einzigen Richtung, auf die es ankommt (`spec-straten → adr`), ist
  jeder Fall gefangen.
- **N-3 — Runde-2-MEDIUM-2 ist behoben, auch in der Umschreibungs-Achse.**
  `grep -ic dogfood internal/emit/templates/d-check.yml` → **0**, über den gesamten
  Emissions-Baum ebenfalls **0**. Die vom Auftrag verlangte Suche nach sinngleichen Formulierungen
  ohne das Wort (`dieses repo`, `anders als bei uns`, `hier`, `unser`, `ursprungs`) liefert genau
  einen Treffer: Zeile 1, *„emittiert von ai-harness-init (Adopter-Baseline)"* — eine
  Erzeuger-Kennzeichnung, die dem Adopter sagt, woher die Datei stammt, und kein Vergleich mit dem
  Ursprungs-Repo. Kein Befund. (Die Kennungs-Form derselben Klasse steht als INFO-1.)
- **N-4 — Runde-2-LOW-1 ist behoben, ohne die Liste zu verdoppeln.** `emit.go:47-48` zeigt jetzt
  auf die Datei, die die Modul-Liste führt, statt sie zu wiederholen — die Bauform, die eine
  zweite driftende Fassung gar nicht erst anlegt. (Dass die **gleiche** Aussage vierzig Zeilen
  höher stehen blieb, ist MEDIUM-1 und kein Einwand gegen diese Behebung.)
- **N-5 — Runde-2-LOW-2 ist behoben, und der Platzhalter bleibt im Ziel zu Recht stehen.** Die
  vom Auftrag gestellte Gegenfrage — *wird `<tag>` beim Emit ersetzt, und wäre ein stehender
  Platzhalter schlechter als die harte Zahl?* — ist gemessen und mit **nein** beantwortet:
  `emit.go:107` schreibt `dcheckConfig` roh, es findet **keine** Ersetzung statt, und im real
  gebootstrappten Ziel steht Zeile 24 literal mit `<tag>`. Das ist die Hausform, nicht ein
  Versehen: **15** `<tag>`-Vorkommen im Emissions-Baum gegen **0** harte `v6.5.0`
  (`grep -ro '<tag>' internal/emit/templates/ | wc -l`; `grep -rn 'v6\.5\.0' internal/emit/templates/ | wc -l`),
  darunter die mitemittierten Workflow-Commands und `baseline-verify.sh`. Und er ist im Ziel
  **eindeutig auflösbar**: das Ziel trägt genau **1** Verzeichnis unter `.harness/baseline/`, und
  das emittierte `baseline-verify.sh` erzwingt diese Eindeutigkeit selbst (*„mehr als ein
  `<tag>`-Verzeichnis"* → Fehler). Kein Gate bricht daran: `scan.ignore` nimmt `.harness/**` aus,
  `codepaths` ist aus, und eine YAML-Kommentarzeile liegt ohnehin außerhalb. Die harte Zahl wäre
  hier die schlechtere Wahl — sie zeigte nach dem nächsten Bump in jedem neuen Ziel ins Leere.
- **N-6 — Der Diff-Umfang ist wie berichtet, mit eigenem Filter geprüft — und `full-smoke` durfte
  darum ausbleiben.** Nicht der Bericht, sondern der Baum:

  ```sh
  git show b323363c -U0 | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vE '^[+-][[:space:]]*(#|//)'
  # (leer — jede geaenderte Zeile ist eine Kommentarzeile)
  diff <(git show b323363c^:internal/emit/templates/d-check.yml | grep -vE '^[[:space:]]*#|^[[:space:]]*$') \
       <(git show b323363c:internal/emit/templates/d-check.yml  | grep -vE '^[[:space:]]*#|^[[:space:]]*$')
  # (leer — kein YAML-Wert beruehrt)
  ```

  Dieselbe Probe über `emit.go` ohne `//`-Zeilen ist ebenfalls leer. Der YAML-Rumpf ist byte-gleich
  geblieben, also kann kein `full-smoke`-Zahn ein anderes Verdikt liefern; die Auslassung ist
  richtig. **Gegenprobe zur Behauptung selbst:** hätte der Filter eine YAML-Zeile gefunden, wäre
  der Bericht falsch und `full-smoke` fällig gewesen — er findet keine.
- **N-7 — Zwei der drei vom Implementer benannten, nicht angefassten Fundstellen sind zulässige
  Abgrenzung; die dritte ist es nicht.** Die Trennlinie ist messbar: `enforce.go:21` und
  `baseline.go:11` tragen *„genau wie die minimale .d-check.yml"* — **ein Adjektiv** in einem
  Vergleich, das durch das Aktivieren von fünf der d-check-Module nicht falsch wird (`codepaths`,
  `planning`, `vcs`, `sources`, `versions`, `reviews` bleiben aus; die emittierte Config ist
  weiterhin die minimale gegenüber der des Dogfoods). `emit.go:7-9` dagegen trägt eine
  **Aufzählung** und eine **Garantie-Zuschreibung**, beide von diesem Slice widerlegt — das ist
  MEDIUM-1. Der Umfangs-Verweis trägt also zu zwei Dritteln.
- **N-8 — Der Konjunktiv *„waere redundant"* ist geprüft und ist kein §3.7-Verstoß.**
  [`AGENTS.md`](../../AGENTS.md) §3.7 verwirft den Konjunktiv über die **verworfene Alternative**
  („Ohne dieses Feld behauptete …"). Hier trägt der Satz die Klasse **Abgrenzung** — er sagt,
  welche Position bewusst *nicht* mitgeht und woran das hängt; das ist eine der fünf zulässigen
  Klassen, und Runde-2-MEDIUM-1 hat diese Aussage ausdrücklich eingefordert. Sie zu beanstanden
  hieße, die Behebung des eigenen Vorbefunds zu bestrafen. Kein Finding.
- **N-9 — Was im Emissions-Baum steht, steht im Ziel.** `diff internal/emit/templates/d-check.yml
  <ziel>/.d-check.yml` ist leer — der geprüfte Text ist der ausgelieferte Text, nicht eine Vorstufe
  davon. Der Basislauf desselben Ziels: `19 Datei(en) geprüft, 0 Befund(e)`.
- **N-10 — Der übergebene Baum-Zustand war veraltet und ist ersetzt, nicht übernommen.** Der
  Auftrags-Schnappschuss nannte drei modifizierte Dateien und slice-140-Commits; real ist der Baum
  **sauber** (`git status --porcelain --untracked-files=all` → 0 Zeilen) und `3fd42cc4` liegt
  **27** Commits zurück (`git rev-list --count 3fd42cc4..HEAD`). Geprüft ist der reale HEAD.
- **N-11 — Nicht geprüft (fremde Rolle):** die DoD-Abhakung (`grep -c '^- \[x\]'` → **0** bei
  `grep -c '^- \[ \]'` → **5**, also unberührt — was §3.10 verlangt), die Gate-Lauf-Bestätigung
  (`make gates`, `docs-check`, `comment-claims`) und der Gate-Stempel. Das ist Verifikation
  (Modul 11); der Reviewer-Skill nimmt sie ausdrücklich aus.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Kommentar behauptet eine Messung, die die von ihm genannte Quelle nicht trägt |
| MEDIUM | 2 | Kommentar beschreibt den vom eigenen Slice abgelösten Zustand · Abdeckungs-Behauptung, die die von ihr genannte Beleg-Quelle nicht trägt |
| LOW | 0 | — |
| INFO | 2 | Emittiertes Artefakt nennt eine Kennung des Ursprungs-Repos · Emittierte Klasse mit leerem Prüfbereich / Deckungs-Aussage über einen Nicht-Gate-Sensor |

**Wiederkehrende Klasse für den Steering-Loop-Zähler.** Eine Klasse erreicht mit dieser Runde die
**dritte** Wiederholung und ist damit nach
dem Baseline-Regelwerk `grundlagen-klassifikation.md` §Steering Loop
(1× notieren · 2× Symptom · 3× Lücke) keine Notiz mehr, sondern eine Lücke — sie gehört bei der
Slice-Closure ins Beobachtungs-Register
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)):

> *Eine Aussage über die Ziel-Form steht als Behauptung im Artefakt, statt gemessen zu sein.*
> Runde 1: die Ziel-Form gilt für drei Positionen und für eine vierte nicht. Runde 2: sie gilt
> angeblich für alle, und die Aufzählung ist an einer Stelle falsch. Runde 3: die Aufzählung
> stimmt vollständig — und die **Begründung** daneben nennt zwei Artefakt-Klassen, von denen eine
> die Eigenschaft nicht hat und beide im Ziel leer sind. Die Klasse wandert innerhalb desselben
> Absatzes weiter, statt zu verschwinden.

**Und ein zweiter Zähler steht jetzt bei zwei:** *Eine Abdeckungs-Behauptung beruft sich auf eine
Beleg-Quelle, die sie nicht trägt* (Runde 2: `make comment-claims`/`codepaths` als angeblich
deckend; Runde 3: der `mutate`-Beleg, MEDIUM-2). Bemerkenswert ist, dass beide Male die genannte
Quelle **existiert** und nur ihre Reichweite nicht geprüft wurde.

## Verdikt

**Blockierender Befund — ja.** Ein HIGH und zwei MEDIUM.

**Was in dieser Runde gut ist und nicht kleingeredet gehört.** Der Kern von Runde-2-HIGH-1 ist
wirklich behoben, nicht umetikettiert: Alle **sieben** Herkunfts-Behauptungen halten meiner
eigenen Messung stand, einzeln, mit den Zeilennummern, die der Implementer nennt — das ist die
Sorgfalt, die Runde 2 vermisste, und sie ist diesmal geleistet. Runde-2-MEDIUM-1 ist nicht nur
formal geschlossen, sondern inhaltlich richtig entschieden: Ich habe die Deckungsfrage an einem
realen Ziel in vier Sonden durchgespielt, und `ids` fängt den Fall tatsächlich, den `matrix`
fangen würde. MEDIUM-2 ist restlos weg, auch in der Umschreibungs-Achse, die der Auftrag eigens
verlangte. Der Diff hält, was er verspricht — keine einzige Nicht-Kommentarzeile —, und damit war
das Auslassen von `full-smoke` korrekt.

**Warum es trotzdem nicht durchgeht.** Derselbe Absatz, der die Aufzählung repariert hat, trägt
jetzt eine **Begründung**, die die zwei im Ziel leeren Klassen nennt und die einzige nicht leere
ausspart — und für die eine der genannten Klassen ist die behauptete Eigenschaft dreifach
widerlegt (die Vorlage führt das Wort nicht, die Klasse ist Quelle von null Regeln, und die
Messung am Ziel liefert keinen `matrix`-Befund). Das ist im realen Emit auslösbar, und zwar auf
dem Auslieferungszustand: Ein Adopter ohne ADRs und ohne Slices liest, der Schlüssel schütze
Datei-Klassen, die er nicht hat, entfernt ihn, und die erste Vertragsänderung in dem
`## 7. Historie`-Abschnitt, den ihm dieselbe Emission mitgibt, färbt sein Gate rot. Damit fällt
der Befund genau unter die vom Auftrag gesetzte Schwelle und nicht unter *theoretisch*.

**Reif für den Verifier — nein.** Aus demselben Grund wie in Runde 2, und der Grund ist nicht der
Umfang: DoD (1) verlangt ausdrücklich, dass *„die Autorität für alle Positionen dieses Blocks
dieselbe"* ist. Die **Aufzählung** erfüllt das jetzt; die **Begründung** daneben behauptet über
`exclude-sections` etwas, das die Ziel-Form nicht trägt und die Messung widerlegt. Ein Verifier,
der DoD (1) abhakt, hätte denselben Satz gelesen wie ich. Dazu kommt, dass MEDIUM-2 ihm eine
Abdeckung zusagt, die er beim ersten `make mutate` widerlegt sieht.

**Kein Rollen-Konflikt-Pfad ausgelöst.** Modul 8 verlangt die Konflikt-Sequenz ab *HIGH mit
Rollen-Widerspruch*. Ein Widerspruch liegt nicht vor: Der Implementer hat keiner Entscheidung
widersprochen; die Begründung ist eine Messung, keine Meinung, und sie ist an einem realen Ziel in
Minuten nachprüfbar. Wird HIGH-1 bestritten, ist der Konflikt-Pfad zu eröffnen — herabgestuft wird
er nicht.

**Was nicht in die Behebung gehört.** Die Adaptions-Einträge und der Adaptions-Block bleiben
Architect-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.8); die DoD-Haken und die Closure-Notiz
bleiben Planner-Arbeit (§3.10). Ob `exclude-sections` überhaupt mitgeht, ist längst entschieden
und wird hier **nicht** wieder aufgemacht — DoD (1) verlangt den Schlüssel, und die Messung oben
zeigt, dass er trägt. Beanstandet ist allein, womit der Kommentar ihn begründet.

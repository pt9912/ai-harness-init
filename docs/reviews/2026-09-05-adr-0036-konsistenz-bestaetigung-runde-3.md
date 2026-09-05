# Review: ADR-0036 — Konsistenz-Bestätigung, Runde 3

**Rolle:** Unabhängiger Reviewer (Harness Modul 10) — Diff gegen Plan + ADRs + Hard Rules
(**nicht** DoD; das ist Verifier-Rolle).

**Datum:** 2026-09-05 · **Reviewer:** Claude, frischer Kontext, keines der geprüften Artefakte
selbst geschrieben, an keinem etwas geändert.

**Gegenstand und Zuschnitt — diesmal breit statt punktuell.** Drei Teile: (A) ob `8f40677` die
zwei von Runde 2 benannten Fundorte auf den Ist-Zustand zieht; (B) eine **vollständige** Durchsicht
der Datei nach jeder Präsens-Aussage über einen lebenden Repo-Zustand, jede einzeln gegen den
Ist-Zustand gemessen — die Fehlerklasse, die in Runde 1 und Runde 2 je zweimal auftrat; (C) die
Register-Frage zur Fix-Historie. Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf
selbst gefahren; **nichts** ist aus einer Commit-Message oder aus einem Vorbericht übernommen.

**Trigger-Bezug.** [`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)
§Der Acceptance-Trigger macht genau diesen Report zur Bedingung ihres Umschlags auf `Accepted`:
*„wenn eine Reviewer-Runde sie gegen ADR-0018 und ADR-0031 auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund in `docs/reviews/` liegt"*.

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `8f40677` gegen `8f40677^` = `477b326`. `8f40677` ist zugleich `HEAD`; der
  Arbeitsbaum ist sauber (`git status --porcelain` leer). Kein Commit liegt zwischen Fix und
  Prüfung.
- **`LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (kein Gate liest, nach welcher Fassung ein Durchgang lief),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag als
  Reproduzierbarkeits-Klammer).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0015 0016 0018 0030 0031 0034 0036; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  ADR-0015 `Accepted`, ADR-0016 `Accepted`, ADR-0018 `Accepted`, ADR-0030 `Accepted`,
  ADR-0031 `Proposed`, ADR-0034 `Accepted`, ADR-0036 `Proposed`. Keine `Superseded`/`Deprecated` —
  nur diese zwei verbietet `matrix.status` in [`.d-check.yml`](../../.d-check.yml) Zeile 141
  (`status: {forbidden: [superseded, deprecated]}`, selbst gelesen).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (ADR ab `Accepted`
  immutabel), §3.6, §3.7 samt Geltungsbereich, §3.8 (Architect-Commit-Zuschnitt), §3.9
  (Docker-only). Dazu
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  und [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-05-adr-0036-konsistenz-bestaetigung.md) (0 HIGH, 2 blockierende MEDIUM),
  [Runde 2](2026-09-05-adr-0036-konsistenz-bestaetigung-runde-2.md) (0 HIGH, 2 blockierende
  MEDIUM, 1 LOW, 2 INFO) und der davor liegende
  [Nachträglich-Review](2026-09-05-slice-178-nachtraeglich-review.md) (1 HIGH, 4 MEDIUM). Die dort
  als wiederkehrend markierte Klasse: *„eine Korrektur nennt einen Fundort, wo eine Fundmenge
  steht"*.
- **Slice-Plan:** [`slice-178`](../plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md).

**Gate-Lauf:** `make gates` → **EXIT 0** (Docker-only, §3.9; in diesem Lauf selbst gefahren).
`d-check: 797 Datei(en) geprüft, 0 Befund(e)`. Kein Nebenbefund wie in Runde 1 — `git worktree
list` zeigt nur den Hauptbaum.

---

## Teil A — Was `8f40677` erreicht

`git show --pretty=format: --name-only 8f40677` gibt **eine** Datei aus, die ADR — der Zuschnitt,
den [`AGENTS.md`](../../AGENTS.md) §3.8 für Architect-Artefakte verlangt.

### Runde-2-M-2 (Option-B-Contra-Zelle, `:302`) — **behoben, ohne Restbefund**

Die beanstandete Indikativ-Präsens-Aussage *„die Kürzel-Spalten-Stelle im Konventionsspeicher
wäre grün, wo der adoptierte Stand rot ist"* ist ersetzt durch *„Zum Entscheidungszeitpunkt wäre
die Kürzel-Spalten-Stelle im Konventionsspeicher nach `v5.18.0` grün gelesen worden, während sie
nach der Ziel-Fassung rot war — inzwischen durch die Folgepflicht von ADR-0034 aufgelöst, aber ein
Durchgang nach B hätte diese Auflösung nie gefordert"*. Alle drei Tatsachen-Anteile halten, selbst
gemessen:

```sh
ls -1 .harness/baseline/                                                   # v6.0.0  (einzige Zeile)
grep -c 'Eine Kürzel-Spalte führt diese Tabelle nicht' harness/conventions.md   # 0
grep -n '^| Sub-Area | Kürzel' harness/conventions.md                      # 214
git log --oneline -1 -S'Eine Kürzel-Spalte führt diese Tabelle nicht' -- harness/conventions.md
# -> 655c2df Rolle Architect: Modus-Deklaration bekommt die Kuerzel-Spalte (ADR-0034 Festlegung 3, Folgepflicht 2)
grep -n 'Folgepflicht 2' docs/plan/adr/0034-*.md                           # 359
```

ADR-0034 §Folgepflicht 2 lautet verbatim *„die Kürzel-Spalte und der Ersatz des Absatzes, der ihre
Leere begründet, in `harness/conventions.md`"* — der Verweis trifft. **Kein Restbefund.**

### Runde-2-M-1 (§*Die Wirkung …*, `:185–203`) — **vier von fünf Teil-Aussagen gezogen, eine steht**

Runde-2-M-1 benannte vier Präsens-Aussagen (i)–(iv) plus eine invertierte Richtungsaussage.
Ist-Stand, Aussage für Aussage:

| Teil-Aussage aus Runde-2-M-1 | Ist-Stand nach `8f40677` |
|---|---|
| (i) Überschrift *„sie steht **heute** im Konventionsspeicher"* | gezogen: *„sie stand zum Entscheidungszeitpunkt …"* |
| (ii) *„beginnt mit dem Satz …"* | gezogen: *„begann …"* |
| (iii) *„begründet ihn … (der Absatz nennt …)"* | gezogen: *„begründete … (der Absatz nannte …)"* |
| (iv) *„dieses Repo vergibt keine Kennung mit Bereichssegment"* | **unverändert Präsens** → M-1 unten |
| Richtungsaussage *„liest … grün / rot"* | gezogen: *„las … grün, … rot"* |

Die drei gezogenen Vergangenheits-Aussagen sind gegen den Entscheidungszeitpunkt nachgemessen und
treffen zu:

```sh
git log --oneline --diff-filter=A -- docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md  # 9ad297a
git show 9ad297a:harness/conventions.md | sed -n '/^## Modus-Deklaration pro Sub-Area/,/^| Sub-Area/p' | head -8
# -> "**Eine Kürzel-Spalte führt diese Tabelle nicht.** … (adoptierter Stand `v5.18.0`,
#     .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md
#     §harness/conventions.md als Konventionsspeicher). Dieses Repo zählt ohne Segment …"
```

Der neu eingefügte Satz *„Die Folgepflicht von ADR-0034 Festlegung 3 hat den Fund inzwischen
aufgelöst — ein eigener Architect-Commit hat die Kürzel-Spalte nachgetragen"* trifft ebenfalls
(`655c2df`, Kommando oben). Zu seinem Locator siehe LOW-1.

---

## Teil B — Findings dieses Laufs

### M-1 — Die vierte Teil-Aussage aus Runde-2-M-1 steht unverändert im Präsens und ist heute falsch

- **kategorie:** MEDIUM (blockierend)
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.4 (mit dem Umschlag auf
  `Accepted` wird der Satz unkorrigierbar) · Klassen-Anker:
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (`Stand: offen`, 1 Beleg)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:191–192`
- **befund:** Der Satz lautet *„Gegen die gepinnte Pflichtgliederung war das richtig — dieses Repo
  **vergibt** keine Kennung mit Bereichssegment."* Das Verb steht im Präsens, während jedes andere
  Verb desselben Absatzes von `8f40677` ins Präteritum gezogen wurde. Am Ist-Stand ist die Aussage
  falsch: Das Repo führt **45** Kennungen der Form `BEO-ALL/<slug>`, deren erstes Segment das
  Sub-Area-Kürzel ist. Dieselbe Datei behauptet 59 Zeilen darüber (`:133–134`) das Gegenteil im
  selben Tempus — *„… und damit jedes Repo mindestens eine Kennungsklasse mit Segment führt"* —,
  und `harness/conventions.md` §Modus-Deklaration pro Sub-Area sagt heute ebenfalls im Präsens
  *„Seit `v6.0.0` trägt jedoch eine andere Kennungsklasse ein Segment: Die Identität einer
  Beobachtung im Beobachtungs-Register **ist** der Pfad `BEO-<KUERZEL>/<slug>`"*. Zum
  Entscheidungszeitpunkt war die Aussage wahr — das Register lag damals flach —, und genau diese
  Zeitbindung fehlt ihr als einzigem Satz des Absatzes.
- **Failure-Szenario:** Nach dem Umschlag auf `Accepted` sperrt
  [`AGENTS.md`](../../AGENTS.md) §3.4 den Satz. Ein Leser, der die Aussage an ihrer eigenen Adresse
  nachschlägt, findet 45 segmenttragende Kennungen und zwei Sätze derselben Datei, die einander
  widersprechen; er kann nicht entscheiden, ob die ADR über ihr eigenes Repo irrte oder ob der
  Zustand sich bewegt hat — und die eine Zeile, die das klärte, ist dann nur noch über eine
  Folge-ADR mit `Supersedes` erreichbar.
- **verifizierbar:** **nein** — kein Gate-Modul liest, was ein Satz über eine andere Datei
  behauptet ([`.d-check.yml`](../../.d-check.yml) Zeile 29 führt
  `modules: [links, anchors, ids, matrix, codepaths, spans]`; `make comment-claims` hat keine
  Markdown-Datei im Prüfbereich; `make gates` steht in diesem Lauf auf EXIT 0). Reproduzierbar:
  ```sh
  sed -n '191,192p' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md
  # -> "gepinnte Pflichtgliederung war das richtig — dieses Repo vergibt keine Kennung mit"
  #    "Bereichssegment. Gegen die Ziel-Fassung war es falsch, denn dort ist die Spalte unbedingt."
  sed -n '133,134p' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md   # die Gegen-Aussage
  ls -1d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                      # 45
  git ls-tree --name-only 9ad297a:docs/plan/planning/ | grep -i observ           # observations.md  (damals flach)
  ls -1 docs/plan/planning/ | grep -i observ                                     # observations     (heute Verzeichnis)
  ```
- **klasse:** *Korrektur nennt einen Fundort, wo eine Fundmenge steht* — hier: eine Korrektur
  nennt einen **Satz**, wo eine Aussagen-Menge steht. `8f40677` zieht vier von fünf benannten
  Teil-Aussagen und behauptet in seiner Message *„ganzer Abschnitt auf Praeteritum gezogen"*.
  Sekundär: *Präsens-Aussage über ein lebendes Artefakt in einem einzufrierenden Text*.
- **Was davon nicht fällt:** Die **Festlegung** und ihre zwei tragenden Gründe sind unberührt und
  in diesem Lauf vollständig nachgemessen (Negativbefunde unten). Der Befund betrifft einen
  Nebensatz einer Beleg-Sektion.

### LOW-1 — Der einzige Zeilennummer-Locator der Datei zeigt in ein lebendes Artefakt

- **kategorie:** LOW
- **quelle:** Maintainability (*latente Wartungsfalle — hart verdrahteter Wert*) · Klassen-Anker:
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form`
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:200`
- **befund:** `8f40677` fügt den Beleg *„ein eigener Architect-Commit hat die Kürzel-Spalte
  nachgetragen (`harness/conventions.md:214`)"* ein. Zeile 214 trägt heute tatsächlich die
  Kürzel-Spalte, die Aussage stimmt also. Es ist zugleich der **einzige** Zeilennummer-Locator der
  Datei — jeder andere Verweis nennt Datei plus Abschnitt. `harness/conventions.md` ist die
  Index-Datei des Adaptions-Blocks und wächst mit jedem Eintrag; eine oberhalb eingefügte Zeile
  verschiebt das Ziel, ohne dass ein Gate es meldet, und §3.4 sperrt die Korrektur ab `Accepted`.
- **Warum nicht HIGH:** [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2
  nennt *„die Zeilennummer als alleiniger Locator"* ausdrücklich als unzulässige Form — bindet
  aber nach ihrem eigenen Wortlaut den **Beleg einer Regelwerks-Aussage**, und
  `harness/conventions.md` ist keine. Diese Grenze ist nicht meine Auslegung, sie steht im Repo:
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/state.md` führt sie als eine der
  drei Nachbarklassen, die den Fall gerade **offen** lassen. Ein Verstoß gegen eine aktive ADR
  liegt damit nicht vor; die Begründung jener Festlegung (*„die andere [verfällt] schon bei einer
  eingefügten Zeile"*) trifft den Fall wörtlich.
- **verifizierbar:** **nein**. Reproduzierbar:
  ```sh
  grep -nE '\.md:[0-9]+' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md   # nur 200
  sed -n '214p' harness/conventions.md   # "| Sub-Area | Kürzel | Modus | Begründung | Graduation |"
  ```
- **klasse:** *Zeilennummer als Locator in einem einzufrierenden Text*

### LOW-2 — Der zweite Fundort der Klasse aus Runde-2-LOW-1

- **kategorie:** LOW
- **quelle:** Maintainability (kein Hard-Rule-Anker: [`AGENTS.md`](../../AGENTS.md) §3.7 bindet
  ausweislich seines §Geltungsbereich *„Code, Konfiguration, Skripte und die Zustandsfelder der
  lebenden Register"* — ADR-Fließtext ist keines davon)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:178–179` (neben dem in
  Runde 2 gemeldeten `:111`)
- **befund:** Runde-2-LOW-1 nannte `:110–112` (*„nur ihre Zuordnung … **war** zu grob"*). Die
  vollständige Fundmenge derselben Klasse in dieser Datei umfasst **zwei** Stellen: `:111` und
  `:179` (*„… nicht nur in ihrem §Kontext, wie eine **frühere Fassung dieses Absatzes** den Fundort
  benannt hatte"*). Beide sprechen über einen Text, der nur noch in `git` steht; ein Leser nach dem
  Einfrieren kann nicht entscheiden, ob die beschriebene Vorgänger-Aussage aus diesem Dokument oder
  aus einer der zitierten Quellen stammt.
- **verifizierbar:** **nein**. Reproduzierbar:
  ```sh
  grep -nE 'frühere Fassung|war zu grob' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md   # 111, 179
  ```
- **klasse:** *Text beschreibt seine eigene Entstehung statt seinen Gegenstand* — und, eine Ebene
  darüber, erneut *Fundort statt Fundmenge*.

### INFO-1 — Die Zählkonvention hinter „9 … (Zeilen 295–301)" steht weiterhin nicht daneben

- **kategorie:** INFO (unverändert aus Runde 2, hier nachgemessen)
- **pfad:** `:102` und `:109`
- **befund:** **9** und **2** sind `diff`-Zeilen über **beide** Bäume, die Klammer-Angaben
  *„Zeilen 295–301"* und *„Zeile 14"* adressieren nur den **neuen** Baum. Wer bei 295–301 nachzählt,
  findet sieben Zeilen. Selbst gemessen: Hunk `@@ -292,8 +292,13 @@` = 2 entfernt + 7 hinzugefügt
  = 9; Hunk `@@ -11,7 +11,7 @@` = 1 + 1 = 2. Beide Ortsangaben sind für den neuen Baum korrekt.
- **verifizierbar:** **nein**.
- **klasse:** *Zahl und Ortsangabe messen verschiedene Bezugsmengen*

### INFO-2 — Register-Beleg für diesen Vorgang fehlt, und die Slice-Route ist verbraucht

- **kategorie:** INFO
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
- **befund:** Die Frage, ob die drei Fix-Commits an einer noch-`Proposed`-ADR ein neues
  belegwürdiges Auftreten sind, ist in Teil C unten ausgeführt. Kurzfassung: **Commits sind keine
  Vorgänge** und tragen keinen Beleg; belegfähig sind `slice-178` (liegt in `done/`, seine Closure
  ist vorbei) und die drei Review-Reports. Keiner der beiden passenden Register-Einträge trägt
  einen davon.
- **verifizierbar:** **nein** (die maschinelle Hälfte der Register-Paarung prüft Deckung, nicht
  Vollständigkeit — *„Nicht geprüft wird die Umkehrung «jede Zeile ist irgendwo zitiert»"*).
- **klasse:** *Befund ohne Route in den Zähler*

---

## Teil C — Die Register-Frage zur Fix-Historie

**Ist die Fix-Historie ein neuer belegwürdiger Vorgang?** Als *Commit-Folge* nein.
`modul-06-roadmap.md` §Das Beobachtungs-Register bindet den Beleg an die Form
*„der Dateiname **ist** die Kennung eines abgeschlossenen **Vorgangs**"* und sagt für alles andere:
*„Ein Vorkommen **ohne** abgeschlossenen Vorgang bekommt keinen Beleg und bewegt den Zähler nicht;
es gehört trotzdem in den Eintrag — benannt, nicht gezählt."* Drei Commits an einer offenen ADR
sind ein solches Vorkommen.

**Belegfähig sind hier zwei Klassen von Vorgängen**, beide von derselben Sektion genannt
(*„auch eine Welle und ein Review-Report sind abgeschlossene Vorgänge und taugen als Beleg"*):
`slice-178` und die drei Review-Reports dieses Gegenstands. Für `slice-178` ist die Route
verbraucht — es liegt in `done/`, und eingetragen wird *bei* der Slice-Closure.

**Ist es anderswo erfasst? Teilweise, aber nicht für diese Klasse.** Selbst gemessen:

```sh
find docs/plan/planning/observations -name 'slice-178.md'
# -> BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger/evidence/slice-178.md
#    BEO-ALL/regel-delta-zaehlt-herkunfts-kommentar-mit/evidence/slice-178.md
ls -1 docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/ | wc -l   # 12
ls -1 docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/ | tail -1 # slice-182.md
grep -m1 '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/state.md   # geplant
ls -1 docs/plan/planning/observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/evidence/     # slice-145.md
grep -m1 '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/state.md   # offen
ls -1d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                                                          # 45
```

`slice-178` trägt also Belege in **zwei** Beobachtungen — in keiner der beiden, die zu den Funden
der drei Runden passen. Von diesen beiden steht
`zusage-neben-geaenderter-ableitung-bleibt-stehen` bei **12** Belegen mit `Stand: geplant`
(Kennung `slice-153`), und sein `state.md` nennt die hier einschlägige Unterklasse ausdrücklich als
weiter offen: *„Offen bleibt jede Unterklasse, in der die Zusage kein Anker ist — Skript-Ausgabe,
Testname, Prosa-Zahl, **Präsens-Satz** …"*. `praesens-aussage-in-einzufrierendem-artefakt-ohne-form`
steht bei **1** Beleg, `Stand: offen` — also unter der Schwelle, obwohl die Klasse in drei
aufeinanderfolgenden Review-Läufen an demselben Artefakt aufgetreten ist.

**Was daraus folgt und was nicht.** Es folgt, dass für diesen Vorgang ein Beleg aussteht und die
naheliegende Route (Slice-Closure) verbraucht ist; die verbleibende zulässige Trägerform ist der
Review-Report als eigener Vorgang. Es folgt **nicht**, dass ich ihn vergebe: Eingetragen wird bei
der Closure, und das Urteil *ist das dieselbe Beobachtung?* fällt beim Schreiben. Beide Vorrunden
haben denselben Schluss gezogen und ihn ebenfalls nicht selbst vollzogen. Der Posten gehört an den
Planner, nicht in diesen Report — und er **blockiert die Annahme der ADR nicht**.

---

## Negativbefunde (geprüft, ohne Befund)

**Vollständige Durchsicht auf Präsens-Aussagen über lebende Repo-Zustände.** Alle folgenden
Aussagen sind einzeln gegen den Ist-Stand gemessen und treffen zu — außer der einen in M-1:

- **`:31–34` Kopplungs-Feld.** §Baseline liegt in `harness/conventions.md` Zeile 8 und zeigt auf
  ADR-0036 (*„Die Prozedur des Sprungs auf `v6.0.0` stellt die Ziel-Fassung — ADR-0036, einzige
  Festlegung, `Proposed` mit Acceptance-Trigger in der Datei"*); der Vermerk *offen* ist weg
  (`grep -c 'ist offen' harness/conventions.md` → 0, am Anlage-Commit → 1). Architect-Eigentum
  deckt [`AGENTS.md`](../../AGENTS.md) §3.8. Die Re-Baseline-Zeile selbst behält die Drei-Teile-Form
  aus ADR-0031 Festlegung 2 (Ziel-Tag, Datum, `slice-176`); der ADR-Zeiger steht als eigener Satz
  daneben — *„kein neues Feld"* trifft.
- **`:52` „Die zweistufige Messung liegt in `slice-176` §9".** §9 beginnt bei Zeile 290 und ist die
  letzte Sektion; Stufe (a) steht dort ab Zeile 384, Stufe (b) ab 399
  (`grep -n '^## ' …slice-176….md`, `grep -n 'Stufe (a)\|Stufe (b)' …`).
- **`:56–63` Stufe (a).** Die drei Zitate stehen in der **gepinnten** Fassung aus `d75cd8c^`:
  *„Der Freshness-Audit hat sieben Eigenschaften"* (Zeile 203), *„fünf Ausgänge"* (226),
  *„keinen stillen Auto-Bump"* (318).
- **`:65–78` Stufe (b) — vollständig reproduziert.** `wc -l` → `123 123`, `diff` leer bei Exit 0,
  `grep -c '^\* \*\*'` → 7.
- **`:80–93` Neun Verweise in vier Dateien.** Verteilung selbst gefahren: `3 / 2 / 1 / 1 / 1 / 1`,
  Summe **9**, exakt die abgedruckte Ausgabe.
- **`:100–125` Delegat-Deltas.** `grundlagen-harness-dateien: roh=13 herkunfts-kommentar=2`,
  die drei übrigen je `roh=2 herkunfts-kommentar=2` — Zeichen für Zeichen die abgedruckten Werte.
  Die 9/2-Aufteilung stimmt: Hunk bei 292 liegt in §Konventionsspeicher (219–315), Hunk bei 11/14
  in §Verzeichniskonvention (4–25), und die geänderte Zeile 14 ist die
  `observations.md` → `observations/`-Zeile. Der Freshness-Audit delegiert nicht in
  §Verzeichniskonvention (Verweisliste oben).
- **`:127–135` Die Tabellenzeile ist byte-gleich, die Prosa kippt.** Zeile 236 in **beiden**
  Fassungen, `diff` der Einzelzeile leer. Beide Zitate verbatim im Hunk: *„Wo Kennungen **kein**
  Segment tragen, entfällt die Spalte"* (alt) → *„**Die Spalte ist nicht bedingt.**"* (neu), samt
  der `BEO-<KUERZEL>/<slug>`-Begründung.
- **`:137–155` Herkunfts-Kommentar.** `26` Regelwerks-Dateien, `25` mit genau einem
  `<!-- Quelle:`, `8` in Zeile 2 und `17` in Zeile 3, `README.md` ohne. Die Form-Aussage stimmt:
  `v5.18.0` trägt die `<tag>`-gescopte URL, `v6.0.0` den relativen Pfad (an
  `modul-04-adrs.md` Kopf gegengelesen).
- **`:157–172` Sprung davor.** `17/2 · 2/2 · 2/2 · 2/2` — die abgedruckten Werte.
- **`:174–183` Der Fundort in ADR-0031.** Die Mehrzahl-Aussage steht dort an **drei** Stellen:
  `:64–65` (§Kontext), `:153–154` (§Entscheidung, ab Zeile 143), `:215` (§Konsequenzen, ab 210);
  die vierte Fundstelle `:259` ist die **Frage** des Re-Evaluierungs-Triggers, keine Behauptung.
  Das Zitat *„sie delegiert vier Fragen in Abschnitte, die ein Delta haben"* deckt sich verbatim
  (Umbruch nach *Delta*) — zulässig nach [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md)
  Festlegung 2, *„der Wortlaut ohne Auszeichnung, Whitespace normalisiert"*. `slice-171` als
  eigener Träger existiert und liegt in `open/`.
- **`:205–214` Verfügbarkeit und Reihenfolge.** `ls -1 .harness/baseline/` → genau `v6.0.0`; der
  Tausch-Slice `slice-182` liegt in `done/`, der Durchgang `slice-185` in `open/`. Das
  AGENTS-Zitat *„ist der **Checkout kaputt**"* steht verbatim in
  [`AGENTS.md`](../../AGENTS.md) Zeile 41.
- **`:216–232` Der dritte Trigger von ADR-0031 ist nicht gefeuert.** Der Dreizehn-Begriff-Lauf über
  das vendored Delta gibt in diesem Lauf **0**. ADR-0031 führt die Meta-Frage tatsächlich als
  **dritten** Re-Evaluierungs-Trigger.
- **`:234–257` Die Festlegung und ihre zwei Gründe.** Grund 1 ist datei-skopiert formuliert und
  durch die Messung gedeckt; sein Nachtrags-Satz ist nach `8f40677` durchgehend
  Vergangenheit/Perfekt. Grund 2 ist an `ls -1 .harness/baseline/` und der Slice-Reihenfolge
  gemessen.
- **`:259–276` Kein `Supersedes` fällig.** ADR-0018 Festlegung 3 gibt zwei Fälle im gelesenen
  Wortlaut; der zweite greift. Das Konsequenz-Zitat *„Künftige Sprünge erben eine Pflicht ohne
  Antwort"* steht in ADR-0018 Zeile 335 (mit Auszeichnung, nach ADR-0016 Festlegung 2 zulässig).
  Festlegung 4 nennt die fünf Ausgänge und den Adaptions-Block einzeln — genau die zwei Punkte, die
  ADR-0036 dorthin zurückgibt. Option C ist in ADR-0018 Zeile 319 verworfen; Option D dort ist der
  Misch-Fall, dessen Contra *„eine Erfindung dieses Repos"* die Parallele in ADR-0036 `:304` trägt.
  ADR-0031 Festlegung 2 hat ihren Zielort noch (`grep -n '^## Baseline' harness/conventions.md`
  → 8) und ist für `v6.0.0` vollzogen.
- **`:278–295` Acceptance-Trigger.** Das Regelwerks-Zitat *„ADR-Änderung: Architect schreibt;
  Reviewer prüft auf Konsistenz; Implementer liest als Constraint"* steht verbatim in
  `modul-08-agentenrollen.md` Zeile 145–146. `slice-152` und `slice-171` liegen beide in `open/`.
  Der Verweis auf ADR-0018 §Geschichte trifft — die Messung *„eine Datei, 3 Zeilen"* steht dort.
- **`:297–305` Alternativen.** Option A: `slice-185` §4 Start-Bedingung 2 nennt tatsächlich
  *„die dort entstandene ADR steht auf `Accepted`"*. Option C: das abgedruckte Kommando liefert
  heute `76`/`15` statt `77`/`16`; die Zelle deklariert die Wanderung selbst
  ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2), und am Schreib-Baum `ec3343a` gibt dasselbe Kommando `77`/`16` — Setzung 1 erfüllt.
  `matrix.status` existiert und verbietet `superseded`/`deprecated`.
- **`:307–330` Konsequenzen und Folgepflicht.** Der Folgepflicht-Satz *„Darüber hinaus ändert diese
  ADR keine Datei außer sich selbst und dem ADR-Index"* trifft: `9ad297a` berührt genau drei
  Dateien — die ADR, `docs/plan/adr/README.md` und `harness/conventions.md` (die Folgepflicht
  selbst).
- **`:332–350` Fitness Function — kein halluziniertes Gate.** `make baseline-verify` bricht
  ausweislich `harness/tools/baseline-verify.sh` bei null **und** bei mehr als einem
  `<tag>`-Verzeichnis ab und prüft `SHA256SUMS` auf Integrität und Vollständigkeit — *„genau einer,
  integer, vollständig"* trifft. `make comment-claims` hat laut [`AGENTS.md`](../../AGENTS.md) §4
  keine Markdown-Datei im Prüfbereich. Die Netto-Frage ist ausdrücklich als *„teilweise
  mechanisierbar, hier nicht gebaut"* markiert. `LH-QA-01` gewahrt.
- **`:373–383` Geschichte.** Die Tabelle trägt eine Zeile (`Proposed`). Die Ziel-Form
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  §Geschichte verlangt genau zwei Zeilen (Proposed, Accepted) und keine Zwischenzeilen; dass
  ADR-0018 solche führt, ist Bestand und keine Norm. **Kein Befund.**

**Weitere geprüfte Achsen:**

- **ADR-0016 Festlegung 2 (Form eines Belegs) — erfüllt.** Alle **13** Vorkommen von
  `.harness/baseline/v…` stehen innerhalb von Codeblöcken, also als Kommando-Operand, nicht als
  Beleg-Adresse (`awk`-Lauf über die Datei mit Codeblock-Zähler → leere Ausgabe außerhalb).
- **ADR-0030 Festlegung 3 — erfüllt.** `grep -noE '\]\([^)]*planning/[^)]*\)'` über die Datei ist
  leer; alle fünf Slice-Nennungen (`152`, `171`, `176`, `178`, `185`) stehen als Kennung in
  Inline-Code ohne Pfad-Adresse, und ihre Lage im Lifecycle stimmt.
- **`ids`-Link-Pflicht — kein Befund.** `ADR-0034` steht an zwei Stellen unverlinkt; die
  `link-policy: always`-Regel für `ADR-\d{4}` hat `target: docs/plan/adr/`, und dort ist die blanke
  Kennung zu Hause. `make docs-check` bestätigt es mit 0 Befunden.
- **ADR-Index — gepflegt.** `docs/plan/adr/README.md` Zeile 43 führt ADR-0036 mit Titel, Status
  `Proposed` und der Bezugs-Liste des Kopfes.
- **Umbenannte Sektionsüberschrift — kein toter Anker.** `8f40677` benennt
  §*Die Wirkung ist nicht hypothetisch* in §*Die Wirkung war nicht hypothetisch* um; `d-check`
  (`anchors`) meldet 0 Befunde über 797 Dateien.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `diff`, `sed`, `awk`, `ls`.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext, anderes Prüf-Artefakt.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 (M-1) | Korrektur nennt einen Fundort, wo eine Fundmenge steht |
| LOW | 2 (LOW-1, LOW-2) | Zeilennummer als Locator in einem einzufrierenden Text · Text beschreibt seine eigene Entstehung |
| INFO | 2 (INFO-1, INFO-2) | Zahl und Ortsangabe messen verschiedene Bezugsmengen · Befund ohne Route in den Zähler |

**Wiederkehrende Klasse, zum sechsten Mal:** *„eine Korrektur nennt einen Fundort, wo eine
Fundmenge steht"* — dreimal im Nachträglich-Review, einmal in Runde 1, einmal in Runde 2, hier
erneut. Die Kontext-Eskalation des Reviewer-Skills (*„die dritte Wiederholung derselben Klasse ist
ein Steering-Loop-Signal — Guide/Sensor nachziehen statt nur melden"*) ist damit weit überschritten;
die Vergabe des Belegs gehört in die Closure (Teil C), das Nachziehen des Trägers an den Planner.

---

## Verdikt

**Blockierender Befund: ja — ein MEDIUM (M-1), und es ist ein einziger Nebensatz.**

Von den zwei MEDIUM aus Runde 2 ist **eines ganz und eines zu vier Fünfteln** geschlossen:
Runde-2-M-2 (Option-B-Zelle) ist behoben und in diesem Lauf nachgemessen richtig. Runde-2-M-1 ist
an vier seiner fünf benannten Teil-Aussagen behoben; die fünfte —
*„dieses Repo vergibt keine Kennung mit Bereichssegment"* (`:191–192`) — steht unverändert im
Präsens, ist heute falsch (**45** `BEO-ALL/<slug>`-Kennungen) und widerspricht einer
Präsens-Aussage derselben Datei 59 Zeilen darüber.

**Die Entscheidung selbst ist tragfähig, und das ist in diesem Lauf breiter belegt als in den
Vorrunden.** Beide Mess-Stufen, die Verweis-Verteilung, alle acht Delegat-Delta-Werte über beide
Sprünge, die Herkunfts-Kommentar-Zählung, die Byte-Gleichheit der Tabellenzeile, der
Dreizehn-Begriff-Lauf, die Verfügbarkeits- und Reihenfolge-Aussagen, alle Zitate aus ADR-0018,
ADR-0031, ADR-0034, ADR-0016, dem Regelwerk und `AGENTS.md`, sowie die Konformität mit ADR-0016
Festlegung 2 und ADR-0030 Festlegung 3 reproduzieren vollständig. Kein `Supersedes` fällig, kein
Widerspruch zu einer aktiven ADR oder einer Hard Rule in der Sache, kein halluziniertes Gate.

**Anlass, ADR-0036 vor der Annahme zu ändern: ja**, an **einer** Stelle — `:191`, ein Verb. Das ist
eine **Folge-Konsequenz für einen Architect-Lauf**, kein Selbst-Fix: Dieser Report hat kein
Artefakt außer sich selbst angefasst. Nach dem Umschlag auf `Accepted` kostet dieselbe Korrektur
eine Folge-ADR mit `Supersedes` — genau die Kosten-Asymmetrie, mit der
[`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihren
Accept-Übergang begründet.

`make gates` → **EXIT 0**, `d-check: 797 Datei(en) geprüft, 0 Befund(e)`. LOW-1, LOW-2, INFO-1 und
INFO-2 blockieren nicht.

# Review slice-194 — Runde 2 (Schlussrunde über dem Auflösungs-Diff)

**Rolle:** Reviewer · **Datum:** 2026-09-11 · **Skill:** `.harness/skills/reviewer.md` 1.7.0

**Prüfgegenstand:** `git diff 1aecf91d..2200a822`, und davon allein die Dateien des
Implementer-Commits `2200a822`. Der Architect-Commit `b4d021d8`
(`harness/conventions.md`, MR-054, MR-055) liegt in der Range, ist aber Eigentum einer anderen
Rolle und ausdrücklich nicht Gegenstand — gemessen, dass die zwei Commits sich keine Datei teilen:

```sh
comm -12 <(git show --pretty=format: --name-only b4d021d8 | sort -u) \
         <(git show --pretty=format: --name-only 2200a822 | sort -u)   # leer
```

**Vorrunde:** [`2026-09-11-slice-194-bootstrap-legt-den-register-ort-an.md`](2026-09-11-slice-194-bootstrap-legt-den-register-ort-an.md)
(1 HIGH · 5 MEDIUM · 3 LOW · 2 INFO, blockierend, zwölf Negativbefunde). Diese Runde prüft
**nicht** den Slice, sondern ob dieser Diff ihn an den Verifier übergehen lässt.

**Baum-Stand beim Lauf.** HEAD `2200a822`. Der Arbeitsbaum war beim Start sauber und ist
**während dieses Laufs unsauber geworden** — ohne Zutun des Reviewers:

```sh
git status --porcelain        # " M test/mutations/299-observations-readme-fehlt.sh"
```

Die Änderung ist die Reparatur von HIGH-1 unten. Sie ist **nicht committet** und liegt damit
außerhalb des Prüfgegenstands; der Befund wird gegen `2200a822` geführt und die Reparatur am
Ende des Befundes als Zustand benannt.

**Betriebs-Auflage eingehalten:** kein `make gates` / `make mutate` / `make full-smoke` /
`make test` / `make smoke` / `docker build`. Auch kein `docker run` — für keinen Befund dieser
Runde war ein d-check-Lauf das entscheidende Instrument. Geschrieben wurde allein diese Datei
unter `docs/`; die Sonden liefen über Kopien im Scratchpad außerhalb des Repos.

---

## Findings

### HIGH-1 — Die `bytes.Clone`-Änderung aus LOW-3 zieht dem Mutations-Fall 299 sein Ziel weg; der Patch greift nicht mehr

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (der Mutations-Sensor ist der benannte
  Feedback-Träger der Regel); DoD-Punkt „`make mutate` grün" des Slice-Plans
- **pfad:** `test/mutations/299-observations-readme-fehlt.sh:11` gegen
  `internal/emit/templates.go:409`, beide im Stand `2200a822`
- **befund:** Der Fall ankert per `sed` auf der vollen Zeile mit `$`-Ende:
  `/^\tout\[observationsReadmeTarget\] = observationsReadme$/d`. Derselbe Commit macht daraus
  `out[observationsReadmeTarget] = bytes.Clone(observationsReadme)`. Das Muster trifft damit
  **null** Zeilen; der mutierte Baum ist mit dem unmutierten identisch. Der Treiber fängt das
  fail-closed in Bedingung 2 (`harness/tools/mutate.sh:677`, *„Mutation hat nicht gegriffen
  bei: … — Patch veraltet?"*) und färbt den Lauf rot. Gemessen über einer Kopie außerhalb des
  Repos, ohne den Arbeitsbaum zu berühren:

  ```sh
  cp internal/emit/templates.go "$SP/probe299/" && cd "$SP/probe299"
  sha256sum templates.go                      # 44bc183c…3f3f
  sed -i '/^\tout\[observationsReadmeTarget\] = observationsReadme$/d' templates.go
  sha256sum templates.go                      # 44bc183c…3f3f  — unveraendert
  ```

  **Fundmenge, gemessen statt geschätzt.** Betroffen ist genau **ein** Fall von 286. Geprüft
  wurden alle Fälle, deren `# files:` eine in diesem Diff geänderte Datei nennt — 24 auf
  `internal/emit/templates.go`, 4 auf `internal/emit/templates/d-check.yml`, 3 auf
  `internal/emit/templates_test.go`; von diesen ankert allein Fall 299 auf einer Zeile, die
  dieser Diff verändert:

  ```sh
  for f in $(git diff --name-only 2200a822^ 2200a822); do grep -l "^# files:.*$f" test/mutations/*.sh; done | sort -u | wc -l
  ```

- **verifizierbar:** ja — `make mutate`, Fall `299-observations-readme-fehlt`. Das ist genau der
  Lauf, der laut Übergabe gerade fährt; er entscheidet den Befund und hat ihn offenbar bereits
  entschieden (siehe Zustand unten).
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen`
- **Zustand beim Abschluss dieses Reviews:** Der Arbeitsbaum trägt eine **uncommittete**
  Reparatur — das Muster ankert jetzt auf dem Map-Eintrag statt auf der vollen Zeile
  (`/^\tout\[observationsReadmeTarget\] = /d`) und ein Kommentarblock begründet die Verkürzung.
  Sie ist korrekt und trennscharf: ein Treffer, und die Zeile verschwindet.

  ```sh
  grep -c '^	out\[observationsReadmeTarget\] = ' internal/emit/templates.go   # 1
  ```

  Der Befund bleibt damit **gegen `2200a822` bestehen** und ist erst mit dem Commit dieser
  Reparatur erledigt. Für das Verdikt zählt der Stand, den der Verifier bekäme.

### MEDIUM-1 — Der ausführende Lauf schreibt §3 des Slice-Plans auf den Ist-Stand um; der Plan-vs-Code-Diff des Verifiers ist damit vorab geglättet

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.10 (*„die ausführende Rolle schreibt ihr eigenes
  Abnahmekriterium nicht um"*); Baseline-Regelwerk `modul-08-agentenrollen.md` §Die neun
  Übergaben (*Verifier→Planner: DoD-/ADR-Konformitätsbericht + **Plan-vs-Code-Diff***)
- **pfad:** Slice-Plan `slice-194`, Abschnitt 3 („Plan (vor Code)"), Tabellenzeilen der
  Betroffene-Dateien-Liste (Kennung statt Pfad nach [`AGENTS.md`](../../AGENTS.md) §3.11 — die
  Datei verlässt `in-progress/` beim Abschluss)
- **befund:** Die Zeile für die emittierte Gate-Konfiguration trug `**unverändert**` und trägt
  jetzt `update, Modul-Liste **unverändert**`; drei Zeilen sind hinzugekommen, die festhalten,
  was diese Runde tatsächlich geändert hat (`observations/README.md`, `emit_test.go`,
  `smoke.sh`, die zwei Mutations-Fälle). Der Abschnitt heißt „Plan (**vor Code**)"; nach der
  Umschrift enthält er den Code. Die nächste Station ist der Verifier, dessen benanntes
  Übergabe-Artefakt der Plan-vs-Code-Diff ist — er vergleicht jetzt eine Liste, die die geprüfte
  Partei nach dem Code geschrieben hat, und findet erwartungsgemäß keine Abweichung.
- **Abgrenzung, damit der Befund nicht mehr behauptet als er trägt:** §3.10 bindet den
  *Abschluss*; §3 ist weder DoD (§2) noch Ziel/Abgrenzung (§1), und **kein DoD-Häkchen ist
  gesetzt** (`grep -c '^- \[x\]'` über den Plan → 0). Die Bewegung ist auch nicht still: die
  Commit-Message nennt sie. Der Befund ist deshalb **kein** Hard-Rule-Verstoß nach dem
  Wortlaut, sondern die Sache, für die §3.10 den Ausgang *Übergabe-Artefakt an den Planner*
  vorsieht — die Entscheidung, ob der Plan nachgezogen wird, gehört dem Planner.
- **verifizierbar:** nein, durch keinen Lauf — kein Modul des Doku-Gates liest Commits
  (`grep -n '^modules:' .d-check.yml`), und `make mutate` kennt keine Fehlschlag-Form für einen
  Rollen-Zuschnitt; beide Lücken stellt [`AGENTS.md`](../../AGENTS.md) §3.10 für sich selbst
  fest. Entscheidbar an `git show 2200a822 -- <Plan-Datei>`.
- **klasse:** `fremdes-rollen-artefakt-im-implementations-kontext` — im Register bereits
  **verkörpert** (Zielort `AGENTS.md` §3.10) mit acht Belegen
  (`ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md | wc -l`
  → 8, kein Erwartungswert). Die Regel steht; was fehlt, ist ihr Wächter — genau die Grenze, die
  ihr `state.md` benennt.

### LOW-1 — Die emittierte README lässt in der Verzeichnis-Form eine „Zeile" wandern, die sie zwei Abschnitte vorher ausgeschlossen hat

- **kategorie:** LOW
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register; `ADR-0034`
  Festlegung 1 (die Ablage ist `README.md` plus je Beobachtung ein Verzeichnis)
- **pfad:** `internal/emit/templates/observations/README.md:54-55` gegen `:8`
- **befund:** Der neue Satz lautet *„fällt die Ursache vorher weg, wandert die Zeile mit
  Begründung dorthin, unabhängig vom Zähler."* Zeile 8 derselben Datei sagt: *„Eine Beobachtung
  ist ein Verzeichnis, keine Tabellenzeile."* Es gibt in der emittierten Form weder eine Zeile,
  die wandern kann, noch ein „dorthin" — die Baseline-Vorlage schickt sie in einen Abschnitt
  *§Gestrichene Einträge*, den die Verzeichnis-Form nicht führt. Ein Adopter, dessen Beobachtung
  bei 1× gegenstandslos wird, liest eine Anweisung, deren Objekt sein Register nicht hat; die
  tatsächliche Handlung (`state.md` auf `gestrichen` mit Begründung) steht erst zwei Sätze
  später und ohne Bezug auf diesen Satz. Die Formulierung ist **neu in diesem Diff**, wörtlich
  aus der Baseline übernommen, deren Wortlaut noch die abgelöste Tabellen-Form trägt.
- **Über-Zusage — Ausgang:** **umformulieren**, nicht streichen. Die Aussage (der Ausgang
  `gestrichen` hängt nicht an der Schwelle) ist richtig und war der Auftrag von MEDIUM-3; nur
  ihr Träger — „Zeile"/„dorthin" — gehört auf die Form gebracht, die dieselbe Datei sonst führt.
- **verifizierbar:** nein, durch keinen Lauf: `ADR-0037` §Konsequenzen benennt selbst, dass die
  emittierte README eine zweite Fassung einer Regelwerks-Aussage ist und kein Gate die zwei
  zusammenhält. Entscheidbar am Textvergleich innerhalb der Datei.
- **klasse:** `emittierte-zweitfassung-erbt-die-form-ihrer-quelle`

### LOW-2 — Die Aliasing-Zusage aus LOW-3 nennt keinen Sensor, und keiner sitzt darauf

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/emit/templates.go:407-408`
- **befund:** Der Kommentar sagt zu: *„der Plan-Wert ist eigenstaendig und teilt sich das
  Backing-Array nicht mit dem eingebetteten Paket-Global."* Kein Test und kein Mutations-Fall
  würde rot, wenn `bytes.Clone(` wieder entfiele — die 286 Fälle enthalten keinen auf dieser
  Eigenschaft, und `make comment-claims` schweigt, weil keines seiner Trigger-Wörter
  (`harness/tools/comment-claims.sh:31`) vorkommt. Gemessen:

  ```sh
  git grep -n 'bytes.Clone\|Backing-Array\|aliasier\|Aliasing' -- internal/ test/ cmd/
  # nur internal/emit/templates.go:407,408,409 — Kommentar und Zeile selbst, kein Waechter
  ```

- **Warum nicht höher:** Die Zusage steht **an** der Anweisung, die sie hält, und `bytes.Clone`
  hält sie per Standardbibliothek; sie kann vom Code nicht wegdriften, ohne dass genau diese
  Zeile angefasst wird. Das unterscheidet sie von der skip-if-present-Zusage aus MEDIUM-2 der
  Vorrunde, die über eine Funktionsgrenze hinweg galt.
- **Über-Zusage — Ausgang:** weder streichen noch umformulieren; die Zusage ist am Ort wahr.
  Was fehlt, ist der Zahn, und ob er gebaut wird, ist eine Abwägung und kein Befund.
- **verifizierbar:** ja, negativ — ein Mutations-Fall, der `bytes.Clone(` entfernt, bliebe heute
  grün; das ist das Gegenbeispiel, das §3.6 verlangt und das nicht existiert.
- **klasse:** `zusage-ohne-herstellbares-gegenbeispiel`

---

## Negativbefunde

- **N-1 — HIGH-1 der Vorrunde ist an der vollen Fundmenge gestrichen, nicht am genannten
  Fundort.** Beide Stellen tragen jetzt denselben Tatsachen-Satz; die widerlegte Begründung
  kommt im lebenden Bestand nicht mehr vor:
  `git grep -n 'im frischen Ziel fehlt' -- internal/ cmd/ test/ harness/` → keine Treffer.
- **N-2 — Keine Aussage im lebenden Bestand behauptet noch das Fehlen der Datei.** Gemessen
  über `git grep -nE 'observations' -- ':!docs/reviews' ':!docs/plan/planning/done'
  ':!.harness/baseline' | grep -iE 'fehlt|existiert nicht|nicht vorhanden|entsteht erst'`: die
  verbleibenden fünf Treffer sind eine eingefrorene ADR-Alternativen-Tabelle, ein datierter
  Historie-Eintrag des Benutzerhandbuchs über die **flache** Altform, ein offener Slice-Plan
  über die flache Altform **dieses** Repos und die Kopf-Erklärung des Mutations-Falls 299 im
  Präteritum — keiner behauptet die Abwesenheit im emittierten Ziel.
- **N-3 — Die Streichung hat nichts mitgerissen.** In `internal/emit/templates/d-check.yml`
  steht der Rest-Satz direkt über dem auskommentierten `codepaths:`-Block, und die
  Aktivierungs-Bedingung, die der gestrichene Absatz trug, steht weiterhin im Kopf derselben
  Datei (Zeilen 3-4: *„ids/codepaths erst aktivieren, wenn Targets/roots existieren"*) — der
  Adopter verliert keine Handlungsanweisung. In `internal/emit/emit_test.go` ist der
  zusammengezogene Absatz vollständig; keine Teilersetzung bricht mitten im Satz ab. Der
  Kommentar in `internal/emit/templates.go:406` sagt weiterhin *„nennen den **Ort**"* und nicht
  „die Datei" — er deckt sich mit der LOW-1-Korrektur der Vorrunde (zwei auf die Datei, einer
  auf das Verzeichnis).
- **N-4 — Der neue Test misst die Eigenschaft, nicht die Implementierung.**
  `TestTemplates_ObservationsReadmeSkipIfPresent` legt ein Sentinel-Exemplar an den Zielpfad,
  ruft **die öffentliche Schnittstelle** `emit.Templates(courseSet(), dir, "X")` — denselben
  Eingang wie jeder Aufrufer — und vergleicht den Dateiinhalt danach byte-genau gegen das
  Sentinel. Er inspiziert weder die Plan-Map noch die Weichen-Variable `write`; eine Umstellung
  der Implementierung, die die Eigenschaft hält, lässt ihn grün.
- **N-5 — Mutations-Fall 300 trifft die Stelle des Aufrufers und baut nichts nach.** Sein
  `sed`-Muster trifft `write := writeSkipIfPresent` **genau einmal**
  (`grep -c 'write := writeSkipIfPresent' internal/emit/templates.go` → 1), und zwar in der
  Schreib-Schleife von `Templates()`, die der Test über die öffentliche Schnittstelle
  durchläuft. Über einer Kopie außerhalb des Repos angewandt, entsteht ein vollständiger
  `if`-Block vor der bestehenden Skills-Weiche; beide eingesetzten Bezeichner
  (`writeFileMode`, `observationsReadmeTarget`) sind Paket-Deklarationen und im Gültigkeitsbereich.
  Beide `# expect:`-Namen existieren als Go-Test
  (`git grep -n 'func TestTemplates_\(EmittierterBestandVollstaendig\|ObservationsReadmeSkipIfPresent\)('`).
  **Grenze dieser Prüfung, benannt:** Dass der mutierte Baum *übersetzt*, ist hier durch
  Bezeichner-Gültigkeit belegt, nicht durch einen Compiler-Lauf — `docker build` war für diese
  Runde ausgeschlossen. Der Lauf, der das entscheidet, ist `make mutate`, Fall 300.
- **N-6 — MEDIUM-3 ist gegen die Baseline korrekt nachgezogen.** `modul-06-roadmap.md` §Das
  Beobachtungs-Register: *„Nur zwei der drei hängen an der Schwelle: verkörpert und geplant sind
  ihre Antwort. Gestrichen ist an sie nicht gebunden."* Der neue Text sagt genau das, die
  Abschnitts-Überschrift hat ihr falsches „ab 3×" verloren, und die Zuordnung der zwei
  schwellen-gebundenen Ausgänge ist unverändert richtig. Die Formulierungs-Frage daran ist
  LOW-1, nicht die Aussage.
- **N-7 — MEDIUM-5 ist aufgelöst und führt keine neue messbare Behauptung ein.** Die vendored
  Ziel-Form (`.harness/baseline/v6.5.0/templates/harness/conventions.template.md`,
  §Modus-Deklaration) sagt weiterhin *„Die Kürzel-Spalte tragen nur Repos, deren Kennungen ein
  Bereichssegment führen … wer ohne Segment zählt, streicht sie"*; dieselbe Emission schreibt
  diese Datei ins Ziel (`harness/conventions.md` steht in der `want`-Liste von
  `TestTemplates_EmittierterBestandVollstaendig`). Der neue README-Satz nimmt dem Adopter genau
  die Fehl-Lesart und folgt dabei derselben Ableitung, die dieses Repo für sich selbst getroffen
  hat: die Kennung einer Beobachtung **ist** der Pfad mit Segment, die Bedingung ist also
  erfüllt, nicht aufgehoben. Er behauptet nichts über ADR-/Slice-Kennungen und braucht deshalb
  keine dritte Runde.
- **N-8 — `bytes.Clone` beseitigt die Aliasing-Gefahr, und die Fundmenge ist vollständig.** Von
  den drei Zuweisungen in `planTemplates` erzeugen zwei ohnehin frische Slices
  (`[]byte(body)`, `[]byte{}`); die dritte war die einzige, die ein `//go:embed`-Global
  weiterreichte, und ist die geänderte. `grep -n 'out\[' internal/emit/templates.go` nennt keine
  vierte. Kein zweiter Fundort blieb stehen.
- **N-9 — Die Stichprobe in `harness/tools/smoke.sh` ist korrekt erweitert.** Der neue Eintrag
  trifft den realen Zielpfad, liegt in derselben Existenz-Schleife und kann nur rot werden, wenn
  die Datei im Ziel fehlt. Der begleitende Kommentar nennt die dritte Klasse und ihre Herkunft
  im Indikativ. Dass die Schleife fünf Pfade für drei Klassen führt, war schon vor diesem Diff
  so (vier Pfade, zwei Klassen) und trägt keine falsche Aussage: „je ein Vertreter" ist als
  *mindestens einer je Klasse* erfüllt.
- **N-10 — Die Rollen-Grenze zu MEDIUM-1 der Vorrunde ist eingehalten.** Der Implementer-Commit
  berührt `harness/conventions.md` und `harness/conventions/**` nicht (Messung im Kopf dieses
  Reports); die Auflösung liegt vollständig im Architect-Commit.
- **N-11 — Der neue generische Text bleibt frei von Chronik und Repo-Kennungen.**
  `grep -nE 'ADR-[0-9]{4}|LH-[A-Z]+-[0-9]+|MR-[0-9]{3}|slice-[0-9]+|welle-[0-9]+'
  internal/emit/templates/observations/README.md` → keine Treffer. Die neuen Code-Kommentare
  stehen im Indikativ über die Stelle und tragen Kopplung bzw. Abgrenzung; keine Befund-Kennung,
  kein Lauf-Protokoll ([`AGENTS.md`](../../AGENTS.md) §3.7).
- **N-12 — Die zwölf Negativbefunde der Vorrunde sind durch diesen Diff nicht entwertet.** Der
  Diff berührt keine der dort gemessenen Flächen mit einer Änderung, die ihre Aussage umkehrt;
  geprüft an den in N-1…N-12 der Vorrunde genannten Pfaden.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 1 | MEDIUM-1 |
| LOW | 2 | LOW-1, LOW-2 |
| INFO | 0 | — |

**Wiederkehrende Klasse, und sie ist die Pointe dieser Runde.**
`zusage-neben-geaenderter-ableitung-bleibt-stehen` steht im Register mit 19 Belegen und dem
Stand `geplant` (`slice-153`). Die Vorrunde zählte sie dreimal in diesem Slice; HIGH-1 dieser
Runde ist das vierte Vorkommen — **erzeugt von der Reparatur des dritten**. Die LOW-3-Korrektur
hat eine Ableitung geändert und die Zusage daneben stehen lassen, diesmal als `sed`-Anker in
einem Mutations-Fall. Das ist derselbe Vorgang und damit **eine** Gelegenheit für den Zähler,
keine weitere; die Beobachtung selbst — dass eine Befund-Auflösung die nächste Instanz derselben
Klasse erzeugt, und dass der offene Ausgang `slice-153` die Unterklasse *Anker in einem
Mutations-Fall* nicht abdeckt — gehört in die Closure-Notiz.

---

## Verdikt

**Blockierender Befund: ja.**

HIGH-1 blockiert: Im Stand `2200a822` ist `make mutate` rot, und der Slice-Plan führt
„`make mutate` grün" als DoD-Punkt. Ein Mutations-Fall, dessen Patch nicht greift, misst nichts —
das ist die Regel aus [`AGENTS.md`](../../AGENTS.md) §3.6 eine Ebene tiefer, angewandt auf den
Sensor, der sie trägt. Der Befund ist **klein und eng**: ein `sed`-Anker, eine Zeile, und die
Reparatur liegt bereits uncommittet im Arbeitsbaum; sobald sie committet ist und `make mutate`
über dem neuen Stand grün meldet, ist HIGH-1 erledigt.

MEDIUM-1 blockiert nicht den Merge, sondern die **Übergabe an den Verifier**: dessen benanntes
Artefakt ist der Plan-vs-Code-Diff, und der ist im ausführenden Kontext vorab geglättet worden.
Nach [`AGENTS.md`](../../AGENTS.md) §3.10 ist das kein Implementer-Schritt zum Nachbessern,
sondern ein Übergabe-Artefakt an den Planner — er entscheidet, ob §3 den Nachzug behält.

LOW-1 und LOW-2 blockieren nicht. LOW-1 ist eine Formulierung im ausgelieferten Adopter-Text und
kann in diesem Slice mitgenommen oder benannt liegen bleiben; LOW-2 ist eine benannte Lücke, kein
Defekt.

**Übergabe an den Verifier: noch nicht.** Zwei Bedingungen, beide klein: der Commit der
299-Reparatur mit einem grünen `make mutate` darüber, und die Planner-Entscheidung zu §3. Eine
dritte Review-Runde braucht es dafür nicht — beide Ausgänge sind an einem Lauf bzw. an einer
Rollen-Entscheidung ablesbar, nicht an einem weiteren Urteil.

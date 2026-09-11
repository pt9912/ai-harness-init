# Verifikation — slice-194: Der Bootstrap legt den Register-Ort an

- **Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-11
- **Eingang:** DoD-Bestätigung des Implementers (Commits `19bfcc1f`, `2200a822`, `02098fc4`) plus
  zwei Review-Runden (`docs/reviews/2026-09-11-slice-194-bootstrap-legt-den-register-ort-an.md`,
  `…-runde-2.md`, beide Verdikt „keine dritte Runde nötig").
- **Prüfgegenstand:** `docs/plan/planning/in-progress/slice-194-bootstrap-legt-den-register-ort-an.md`
  gegen den Baum bei `HEAD=5516daa5`. Baum sauber (`git status --porcelain` leer), kein anderer
  `make`-Lauf hielt Docker (`pgrep -af 'make '` zeigte nur fremde Prozesse in einem Nachbar-Repo).
- **Frage dieser Rolle:** Bauen wir es richtig — gegen Plan und DoD. Nicht Gegenstand: ob der
  Diff dem Plan folgt (Reviewer, bereits zweimal gelaufen), ob das Ziel den realen Bedarf trifft
  (Validator, hier nicht vorgesehen).
- **Nicht mein Prüfgegenstand:** Commit `b4d021d8` (Architect, MR-054/MR-055) und die
  Planner-Commits `308797dc`/`b5bd6eb4`/`5516daa5` (Priorisierung, welle-11). Gemessen, dass
  keiner der vier eine Datei mit Bezug zu `slice-194` berührt (`git show --pretty=format:
  --name-only <commit> | grep -i 194` → leer, alle vier).

---

## 1. Ist der Sensor gelaufen? — ja, und ich habe ihn selbst noch einmal gefahren

Die Übergabe nennt Zahlen aus fremden Läufen. Ich übernehme sie nicht, sondern habe die
tragenden Sensoren selbst gegen den aktuellen Baum gefahren:

- **`make gates`** — selbst gefahren, EXIT 0. `d-check: 1091 Datei(en) geprüft, 0 Befund(e)`,
  `comment-claims: 57 Datei(en) geprueft, 0 Befund(e)`, `baseline-verify: v6.5.0 OK — 54 Dateien`,
  `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben`.
- **`make mutate`** — lokal angestoßen, aber auf diesem (mit einem parallelen Fremd-Build
  geteilten) Host zu langsam für einen vollen Lauf in dieser Sitzung; abgebrochen nach 28/286
  grünen Fällen ohne Befund. Autoritativ herangezogen stattdessen: der **frische CI-Lauf auf
  genau `HEAD=5516daa5`** (`gh run view 34564086916`, Job `mutate`, 29m23s, ✓). Sein Log
  (`gh run view --job=103152562996 --log`) zeigt die Schlusszeile `mutate: 286 ok, 0 Befund(e)`
  und **beide** neuen Fälle einzeln:
  ```
  299-observations-readme-fehlt    OK (11.39 s) -> TestTemplates_EmittierterBestandVollstaendig rot
  300-observations-readme-clobbert OK (13.02 s) -> TestTemplates_ObservationsReadmeSkipIfPresent rot
  ```
  Das ist der Beleg, den Runde-2-HIGH-1 verlangt hat: Fall 299 greift wieder, auf einem Runner,
  der mit dem Implementer-Lauf nichts teilt.
- **`make full-smoke`**, **`make smoke`**, **`adr-immutable`** — derselbe CI-Lauf, alle vier
  Jobs ✓ (`full-smoke` 4m2s, `smoke` 1m20s, `gates` 2m28s, `adr-immutable` 8s).
- **DoD (2), die codepaths-Messung 3→0** — **selbst nachgemessen**, nicht übernommen. Zwei
  frische Bootstraps außerhalb des Repos, je mit dem für den jeweiligen Stand gebauten
  `host-bin`:
  - gegen `4a54eeb3` (der Stand vor diesem Slice, aus einem `git worktree`):
    `d-check: 19 Datei(en) geprüft, 3 Befund(e)` — dieselben drei Fundstellen
    (`.claude/commands/close-welle.md:60`, `implement-slice.md:153`, `plan-welle.md:46`), die
    auch die Implementer-Commit-Message nennt.
  - gegen `HEAD=5516daa5`: `d-check: 20 Datei(en) geprüft, 0 Befund(e)`.

  Kein Sensor ist unbelegt geblieben; jede der drei tragenden Zahlen (`gates`, `mutate`,
  `codepaths` 3→0) ist in dieser Sitzung selbst erzeugt worden, nicht nur gelesen.

## 2. Deckt der Sensor die Zusage? — ja, an den zwei Stellen, wo es zählt

- **DoD (1), Vollständigkeit:** `TestTemplates_EmittierterBestandVollstaendig` vergleicht den
  ganzen emittierten Baum auf Mengengleichheit; Fall 299 hat sein Gegenbeispiel **rot gesehen**
  (Implementer-Commit-Message, jetzt auf einem fremden Runner reproduziert) — vor dem
  Round-2-Fix griff das `sed`-Muster nicht mehr (LOW-3 änderte die rechte Seite der Zuweisung),
  der Treiber fing das fail-closed ab (Review Runde 2, HIGH-1), und `02098fc4` ankert das Muster
  jetzt auf der linken Seite. Das ist die geforderte Eigenschaft — *„der emittierte Bestand ist
  vollständig"* —, nicht eine Implementierungs-Zeile.
- **DoD (1), Skip-if-present:** `TestTemplates_ObservationsReadmeSkipIfPresent` legt ein
  Sentinel an den Zielpfad, ruft die **öffentliche** Schnittstelle `emit.Templates(...)` und
  vergleicht danach byte-genau — Fall 300 (Weiche auf `writeFileMode` umgebogen) ist sein rot
  gesehenes Gegenbeispiel. Beide Zähne sitzen an der Eigenschaft, nicht an der heutigen
  Formulierung des Codes (§3.6-Test bestanden — die Reviewer-Negativbefunde N-4/N-5 der Runde 2
  kommen zum selben Ergebnis, hier unabhängig nachvollzogen).
- **DoD (2):** Zusage ist „codepaths meldet 3→0", nicht „codepaths meldet weniger als vorher".
  Beide Zahlen selbst gemessen (oben) — die Zusage ist exakt gedeckt, nicht nur plausibel.
- **Was ich nicht als Zusage werte:** MR-017 (fail-closed-Default für emittierte Prüfbereiche)
  ist hier nicht berührt — `codepaths` bleibt im emittierten `d-check.yml` weiterhin
  auskommentiert (`git diff 4a54eeb3..HEAD -- internal/emit/templates/d-check.yml` ändert nur
  den Kommentartext, nicht die Modul-Liste). Dieser Slice aktiviert nichts; er räumt nur die
  Vorbedingung, die eine künftige Aktivierung (slice-073, MR-054) erst zulässig macht. Kein
  MR-054-Verstoß, weil keine Aktivierung stattfindet.

## 3. Sagt der Plan, was der Code tut? — Plan-vs-Code-Diff gegen den unverfälschten Stand

Grundlinie ist `git show 4a54eeb3:…/slice-194-….md` (§3 trug vier Zeilen), **nicht** der heutige
Planstand — der Implementer hat §3 während der Arbeit erweitert, und ein Diff gegen den
selbstgeschriebenen Endstand prüft nichts.

| Baseline-Zeile (4a54eeb3) | Heutiger Code | Urteil |
|---|---|---|
| `templates.go` — update: README als neuer Emissions-Eintrag | `planTemplates` schreibt `out[observationsReadmeTarget] = bytes.Clone(observationsReadme)`, `//go:embed` neu | **Deckt sich.** |
| `templates_test.go` (want-Listen) — update: Mengen-Vergleich nachgezogen | `want`-Listen in `TestTemplates_EmittierterBestandVollstaendig` **und** `TestTemplates_MinimalQuelle` erweitert; **zusätzlich** neuer Test `TestTemplates_ObservationsReadmeSkipIfPresent` | **Deckt sich, plus eine zulässige Erweiterung.** Der neue Test ist Reaktion auf Review-MEDIUM-2 (Runde 1) — Zusage ohne Zahn — und damit genau das Wachstum, das die Vorlage für „der Implementer-Agent erweitert die Liste" vorsieht. |
| `d-check.yml` — **unverändert** | Kommentartext geändert (die falsche Begründung „im frischen Ziel fehlt …" gestrichen, ersetzt durch den Tatsachen-Satz „codepaths bleibt aus — ihre Aktivierung ist eine eigene Entscheidung"); **Modul-Liste unverändert** | **Weicht ab — begründet und bereits benannt.** Der ursprüngliche Plan hat nicht vorgesehen, dass diese Datei angefasst wird; Review Runde 1 HIGH-1 hat einen Selbstwiderspruch gefunden (dieselbe Datei begründete ein abgeschaltetes Modul mit dem Fehlen genau der Datei, die dieser Slice jetzt schreibt), und der Implementer hat ihn beseitigt. Das ist **keine** Verkleinerung der Zusage und **keine** verdeckte Scope-Erweiterung (die Modul-Entscheidung selbst bleibt bei slice-073) — es ist ein während der Arbeit gefundener Fehler, korrekt behoben. Dass §3 danach den Ist-Stand statt der Vorher-Prognose trägt, ist Review-Runde-2-MEDIUM-1: kein Implementer-Fehler, sondern ein **Übergabe-Artefakt an dich, den Planner** (`AGENTS.md` §3.10) — ob die Zeile in dieser Form stehen bleibt oder auf die Baseline-Fassung zurückgesetzt wird, ist deine Entscheidung, nicht meine. |
| Register-Ablage **dieses** Repos — unverändert | unverändert (`git diff 4a54eeb3..HEAD -- docs/plan/planning/observations/` außerhalb der neu emittierten Vorlage-Datei leer) | **Deckt sich.** |

**Zusätzlich, nicht in der Baseline-Tabelle, aber im heutigen §3 als neue Zeilen geführt** — alle
vier direkt aus Review-Findings dieses Slice, keine aus eigenem Antrieb hinzugefügte Arbeit:

- `internal/emit/templates/observations/README.md` (neu, 64 Zeilen) — die emittierte Datei
  selbst. **Fehlte in der Baseline-Tabelle ganz**, obwohl DoD (1) sie explizit fordert — das ist
  eine Lücke im *ursprünglichen* Plan, keine im Code; der Implementer hat sie beim Schreiben
  nachgetragen. Inhaltlich zweimal gegen `modul-06-roadmap.md` §Das Beobachtungs-Register
  korrigiert (MEDIUM-3: `gestrichen` nicht an die 3×-Schwelle gebunden; MEDIUM-5: Kürzel-Spalte
  gilt unabhängig vom Segment des Adopters) — beide Korrekturen habe ich gegen den Wortlaut des
  Regelwerks selbst gehalten, nicht nur gegen die Review-Behauptung, und sie decken sich
  (`grep` unten).
- `internal/emit/emit_test.go` — dieselbe gestrichene Falschbehauptung stand dort ein zweites
  Mal (Review Runde 2 hat die volle Fundmenge genannt, nicht nur den einen im Runde-1-Report
  genannten Fundort — Negativbefund N-1 der Runde 2 bestätigt das).
- `harness/tools/smoke.sh` — dritter Stichproben-Vertreter für die neue Herkunfts-Klasse.
- `test/mutations/299…`/`300…` — die zwei rot färbenden Gegenbeispiele zu DoD (1), siehe §1/§2
  oben.

**Ergebnis des Diffs:** Der Code deckt die ursprüngliche Plan-Absicht vollständig und geht in
genau vier Punkten darüber hinaus — alle vier sind Reaktion auf während der Arbeit gefundene
Defekte an genau diesem Liefergegenstand, keine über den Slice-Umfang hinauswachsende Arbeit
(§1 Abgrenzung bleibt gehalten: die Modul-Liste, die Register-Ablage dieses Repos und jeder
Migrationspfad für Altbestand bleiben unberührt). Die einzige Stelle, an der der Plan nach der
Arbeit etwas **anderes** sagt als vorher geplant (die `d-check.yml`-Zeile), ist bereits als
Übergabe-Artefakt benannt und wartet auf deine Entscheidung, nicht auf weitere Implementer-Arbeit.

**Textliche Gegenprobe der beiden README-Korrekturen** (nicht nur Review-Zitat übernommen):

```sh
grep -n "Nur zwei der drei hängen an der Schwelle" \
  .harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md
# → "Nur zwei der drei hängen an der Schwelle: verkörpert und geplant sind ihre Antwort."
grep -n "gestrichen.*nicht gebunden" internal/emit/templates/observations/README.md
# → "`gestrichen` ist an diese Schwelle nicht gebunden"
```

Deckt sich. Die Kürzel-Aussage im emittierten Text (*„Diese Spalte trägt jedes Repo für diesen
Zweck — unabhängig davon, ob seine ADR- oder Slice-Kennungen selbst ein Bereichssegment
führen"*) entspricht der Ableitung, die dieses Repo für sich selbst in
`harness/conventions.md` §Modus-Deklaration bereits vollzogen hat (ADR-0034 Festlegung 3: die
Kennung einer Beobachtung *ist* der segmentierte Pfad).

## 4. ADR-Konformität

- **ADR-0037 Festlegung 2** (Ort **und** Träger: Datei mit Inhalt statt `.gitkeep`, tool-autoriert
  ohne Baseline-Vorlage): erfüllt — `//go:embed templates/observations/README.md` liegt neben dem
  Emitter, nicht im gefetchten Kurs-Baum; der Text ist generisch (0 Treffer für
  `ADR-\d{4}|LH-[A-Z]+-\d+|MR-\d{3}|slice-\d+|welle-\d+`, selbst nachgeprüft).
- **ADR-0037 Festlegung 3** (Idempotenz-Klasse `skip-if-present`): erfüllt — `Templates()` wählt
  `writeFileMode` ausschließlich für den Präfix `.harness/skills/`; der Zielpfad
  `docs/plan/planning/observations/README.md` fällt auf den Default `writeSkipIfPresent`
  (`internal/emit/templates.go:309-313`, selbst gelesen). Mutations-Fall 300 hält das jetzt auch
  gegen Regression.
- **ADR-0034 Festlegung 1** (Ablage = `README.md` + je Beobachtung ein Verzeichnis): Der
  Bootstrap legt nur die `README.md` an, kein `BEO-…`-Verzeichnis — korrekt, eine leere Ablage
  trägt laut Regelwerk genau diese eine Datei.
- **ADR-0007** (*skip-if-present* als Default im Zweifel): konsistent angewandt, s. o.
- **ADR-0006** (Tool als Quelle ohne Baseline-Vorlage): Der vendored Baum führt für diese Datei
  keine Vorlage (`find .harness/baseline/v6.5.0/templates -iname 'README.md' -path
  '*observations*'` → leer) — die Herkunfts-Klasse stimmt.
- **MR-017** (fail-closed-Default für emittierte Prüfbereiche): nicht berührt, s. §2 oben —
  keine Aktivierung, keine Lockerung, kein Konflikt.

## 5. Hält die emittierte README, was sie sagt?

Gelesen gegen `modul-06-roadmap.md` §Das Beobachtungs-Register, nicht nur gegen die
Review-Behauptung (Ergebnis s. §3 oben — beide Korrekturen decken sich mit dem Regelwerk-Wortlaut).
**Ein offener Punkt bleibt unverändert stehen, nicht blockierend:** LOW-1 der Runde 2 — der Satz
*„wandert die Zeile mit Begründung dorthin"* verwendet noch das Tabellen-Vokabular der
Baseline-Vorlage, obwohl dieselbe Datei zwei Abschnitte vorher ausdrücklich sagt *„Eine
Beobachtung ist ein Verzeichnis, keine Tabellenzeile."* Selbst nachgelesen — der Satz steht
tatsächlich noch so in `internal/emit/templates/observations/README.md`. Das ist eine
Formulierungs-Inkonsistenz im ausgelieferten Adopter-Text, keine Falschaussage über *dieses*
Repo (die Aussage — `gestrichen` hängt nicht an der Schwelle — bleibt richtig), und kein
DoD-Punkt hängt daran. Ich übernehme das Verdikt des Reviewers: nicht blockierend, kann als
benannte Lücke stehen bleiben oder in einem Folge-Slice mitgenommen werden.

## 6. Register- und Risiko-Lage — was noch aussteht, ist Planner-Arbeit, kein Defekt

Alle vier in §8 des Plans zitierten `BEO-ALL`-Verzeichnisse existieren
(`emittierte-vorlagen-klassifikation-ohne-traeger`,
`idempotente-anlage-erreicht-den-bestand-nicht`,
`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`,
`zusage-neben-geaenderter-ableitung-bleibt-stehen`). Keiner trägt bereits einen
`evidence/slice-194…`-Beleg, und §7 der Plan-Datei steht noch mit `<…>`-Platzhaltern — **das ist
kein Befund**, sondern der nach `AGENTS.md` §3.10 vorgesehene Zustand vor der Closure: Diese
Schritte (Closure-Notiz, Risiko-Ausgänge, Register-Fortschreibung, die drei Paarungen, `git mv`
nach `done/`) sind Planner-Arbeit und laufen erst jetzt an. Ich stelle nur fest, dass nichts davon
technisch blockiert ist: alle Zieldateien für die Belege existieren, alle drei referenzierten
Risiken aus §6 sind an konkrete, existierende `BEO`-Pfade gebunden.

## Kein Rollen-Selbstverifiziert

Dieser Lauf trägt eigenen, frisch gefahrenen Sensor-Beleg (nicht die Implementer-Zahlen
übernommen): `make gates` selbst ausgeführt, `codepaths` 3→0 an zwei selbst gebauten Bootstraps
(`4a54eeb3` und `HEAD`) selbst gemessen, `make mutate` über den unabhängigen CI-Lauf auf
`HEAD=5516daa5` verifiziert (Fälle 299/300 einzeln im Log geprüft), die zwei README-Korrekturen
gegen den Regelwerk-Wortlaut selbst nachgezogen statt zitiert.

---

## Verdikt

**DoD erfüllt: ja**, mit einer Anmerkung, die den Planner betrifft, nicht die Implementierung:

- DoD (1) — Bootstrap legt `observations/README.md` an, tool-autoriert, generisch,
  `skip-if-present`: **erfüllt**, beide Zähne (299/300) rot gesehen und auf fremdem Runner grün
  bestätigt.
- DoD (2) — `codepaths` 3→0: **erfüllt**, selbst nachgemessen an beiden Ständen.
- `make gates` / `make full-smoke` / `make mutate` grün: **erfüllt** (gates selbst gefahren;
  full-smoke/mutate über den frischen CI-Lauf auf exakt diesem HEAD bestätigt).
- Closure-Notiz, Register-Fortschreibung, Risiko-Ausgänge, drei Paarungen: **noch offen** — das
  ist regelkonform, das ist deine Arbeit als Planner nach `AGENTS.md` §3.10, kein Implementer-
  oder Verifier-Defekt.

**Die eine Anmerkung:** Die `d-check.yml`-Zeile in §3 zeigt jetzt den Ist-Stand
(„update, Modul-Liste unverändert") statt der ursprünglichen Vorher-Prognose („unverändert").
Der Wechsel selbst ist inhaltlich korrekt und durch einen echten Review-Fund gedeckt (Runde 1
HIGH-1) — meine eigene Prüfung des Diffs bestätigt, dass die Änderung genau das tut, was sie
behauptet, und nichts mehr. Was offen bleibt, ist eine Formfrage nach §3.10: Ob diese
retroaktive Umschrift der Vorher-Prognose so im Plan stehen bleibt (dein Urteil, wie im
Runde-2-Review vorgemerkt), nicht ob sie sachlich zutrifft (das habe ich geprüft: sie tut).

**Kann der Planner den Slice schließen: ja** — nach Erledigung der in §6 genannten,
noch ausstehenden Closure-Schritte (Closure-Notiz, Register-Belege, Risiko-Ausgänge, drei
Paarungen, `git mv` nach `done/`) und nach deiner eigenen Entscheidung zur §3-Anmerkung oben.
Kein technischer, sensor-gestützter Grund hält den Slice zurück.

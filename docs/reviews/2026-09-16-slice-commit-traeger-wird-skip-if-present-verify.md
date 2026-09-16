# Verifikation `slice-commit-traeger-wird-skip-if-present` — die DoD trägt an jeder ihrer drei Liefer-Hälften

**Rolle:** Verifier · **Datum:** 2026-09-16 · **Geprüfter Stand:** `fb6996dc` —
`git rev-parse HEAD` → `fb6996dc050b0316a497633323dfa776c82a151a`; `git status --porcelain` → keine
Zeile, vor und nach jeder Messung.

**Prüfgegenstand:** §2 **Definition of Done gegen den tatsächlichen Stand**, dazu §1, §3, §5, §6 —
**nicht** der Plan gegen sich selbst (das war der Reviewer), **nicht** die Findings der zwei
Review-Runden erneut. Geprüft ist der **vereinigte** Stand der Läufe auf diesen Gegenstand; die
Implementer-Hälfte liegt in **zwei** divergenten Zügen, die beide denselben Betreff tragen —
`2f82b466` (19 Dateien) und `d7fd8227` (2 Dateien, die den Fragment-Text des ersten nachziehen) —,
dazu `65b78423` (vier Mutations-Anker) und die zwei Architect-Züge zu `ADR-0055`.

```sh
git diff --name-only 77b927c7..HEAD | wc -l      # 28 — der ganze Vorgang ab dem Planner-Anspruch
git diff --stat     77b927c7..HEAD | tail -1     # 28 files changed, 1385 insertions(+), 121 deletions(-)
```

**Vorgeschichte, nicht neu gemessen — als Zeitdokumente zitiert.** Die zwei Review-Reports zu diesem
Gegenstand (Runde 1: 1 HIGH · 2 MEDIUM · 2 LOW · 1 INFO, blockierend **F-1**; Nachprüfung: F-1, F-2,
F-4, F-5 behoben, F-3 offen beim Planner, F-6 unberührt) und der Konsistenz-Report zu `ADR-0055`
liegen vor. **F-1 ist nach Auftrag nicht erneut gefahren** (vier entwaffnete Mutations-Fälle,
repariert in `65b78423`, jeder mit seinem `# expect:`-Wächter).

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an **keiner** Datei
des Gegenstands etwas verfasst: kein Satz, kein Kommentar, kein Testfall, keine Mutation, kein
DoD-Häkchen, kein Risiko-Ausgang, kein Register-Beleg, kein Review-Befund, keine ADR. Er hat
gelesen, Sensoren gefahren und Mutations-Kopien in `/tmp` gelegt.

**Offengelegt — was dieser Lauf am Baum getan hat.** Am Repo ist **keine** Datei geändert worden;
alles mit Wirkung lag in `/tmp`:

- `/tmp/vf-358`, `/tmp/vf-359`, `/tmp/vf-360`, `/tmp/vf-361`, `/tmp/vf-49` (je `git archive HEAD`):
  ein Mutations-Fall, dann `make test-go` — die Rot-Belege in §2.2 und §2.3, von mir gelesen.
- `/tmp/vf-mut` (angelegt für die Anker-Probe, §2.4).

Im Repo selbst liefen `make test` (EXIT 0), `make gates` (EXIT 0) und `make full-smoke` (EXIT 0).
**`make mutate` ist nicht gefahren** — Post-integration, nächtlich
([`.github/workflows/mutate.yml`](../../.github/workflows/mutate.yml), `cron: '17 2 * * *'`), und
`Makefile:127` führt es als *„NICHT in gates"*.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die **Closure** (§7, Beobachtungs-Register,
die §6-Ausgänge, die drei Paarungen, `git mv`) ist Planner-Arbeit nach [`AGENTS.md`](../../AGENTS.md)
§3.10. Die **fünf unteren DoD-Zeilen sind damit nicht fällig — nicht unerfüllt**: Closure-Notiz,
Register-Fortschreibung, Risiko-Ausgänge, Doku-/Index-Nachzug der Closure, die drei Paarungen.
Ebenfalls ausgenommen: `docs/plan/adr/**` (Architect-Eigentum; gelesen, nicht bewertet) und die
Führung des Beobachtungs-Registers.

---

## Ergebnis in einer Tabelle

| # | DoD-Punkt (§2) | Verdikt | Beleg (Sensor · Exit · gelesen) |
|---|---|---|---|
| 1 | Ein Pfad, eine Klasse, die Klasse an **einer** Stelle | **erfüllt** | `make test` EXIT 0; gelesen: `enforceFiles()` trägt `class` je Eintrag, `writeEnforceFile` verzweigt darauf und fällt ohne Klasse aus, `PathClass` liest dieselbe Aufzählung. Selbst rot gesehen: `358`, `361`, `49` (§2.2) |
| 2 | Skip-if-present heißt dreierlei, jede Richtung gelesen | **erfüllt** | `make full-smoke` EXIT 0, die **gefahrene Ausgabe** im gebootstrappten Ziel gelesen (§1.2, §2.3). Selbst rot gesehen: `358`, `359` |
| 3 | Die Sätze am Pfad sind gezogen | **erfüllt** (die vier genannten Stellen gelesen) | kein Sensor; die vier Stellen in §2.4 im Wortlaut geprüft. Rot-Gegenbeispiel `360` selbst gesehen |
| 4 | `make gates` grün | **erfüllt** | EXIT 0 (§1.1) |
| 5 | Review durchgeführt, Report unter `docs/reviews/` | **erfüllt** | zwei Reports, beide in Reviewer-Commits (`e03205f9`, `fb7574f3`) |
| 6 | Doku-Update: die Prosa nennt Klasse **und** Ausgang des belegten Pfades | **erfüllt** | `harness/README.md` §Traceability in §2.4 gelesen |
| 7–11 | Closure-Notiz · Register · Risiko-Ausgänge · die drei Paarungen | **nicht fällig** | Planner, [`AGENTS.md`](../../AGENTS.md) §3.10 — nicht Gegenstand dieses Laufs |

**Verbleibende DoD-Verletzungen: keine.** Die gefundenen Grenzen stehen getrennt als **V-1 bis V-3**
(§4) — sie sind Verifier-Klasse, keine DoD-Verletzung.

---

## 1. Ist der Sensor gelaufen?

### 1.1 `make test` und `make gates` — **EXIT 0**

```sh
make test   # EXIT 0 — bats: 1..305, 0 Zeilen "not ok"; go test: acht Pakete ok
make gates  # EXIT 0
#  baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#  d-check: 1464 Datei(en) geprüft, 0 Befund(e)
#  comment-claims: 63 Datei(en) geprueft, 0 Befund(e)
#  span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
#  dazu im Lauf: golangci-lint-, build-, shellcheck- und actionlint-Stufe ohne Fehlerzeile
```

`make test` ist der in DoD 1 **namentlich** geforderte Beleg und läuft in `make gates` mit: die
Zusage des Punktes hängt damit am Push-Pfad und nicht an einem Beleg außerhalb.

### 1.2 `make full-smoke` — **EXIT 0**, und der Abschnitt der DoD 2 ist gefahren

DoD 2 verlangt die **gefahrene Ausgabe im gebootstrappten Ziel** — nicht die Zeile, die die Meldung
baut. Die Zeile, die ich im Lauf gelesen habe:

```text
full-smoke: Klasse des Commit-Traegers — belegter Pfad in tmprepo_doc, dann der sprachlose Re-Lauf ...
ai-harness-init: .githooks/commit-msg liegt bereits — die Datei bleibt unberuehrt (skip-if-present).
  Die mitgelieferte Pruefung tools/harness/commit-msg-traceability.sh liegt daneben bereit;
  ein eigener Traeger kann sie von dort aufrufen.
full-smoke: Klasse im Ziel: der belegte .githooks/commit-msg blieb unberuehrt, und der Lauf nennt ihn
  samt der mitgelieferten Pruefung:
full-smoke: OK — KLASSE DES COMMIT-TRAEGERS (ADR-0054 Festlegung 1 und 3): der Traeger liegt
  skip-if-present und die Pruefung daneben konvergent — ein FREIER Pfad bekommt den Traeger des
  Werkzeugs (er liegt ausfuehrbar im Ziel und ruft die Pruefung daneben), ein BELEGTER bleibt Byte
  fuer Byte unberuehrt und der Lauf nennt Pfad und mitgelieferte Pruefung; die Drift der Pruefung
  heilte der naechste Lauf, die des Traegers blieb stehen.
```

Drei Dinge sind daran ablesbar und nicht behauptet: der **belegte** Pfad wird **byteweise** gegen den
gepflanzten Adopter-Träger verglichen (kein Exit-Code), die **Meldung** wird aus der gefahrenen
Ausgabe gelesen, und die **Prüfung daneben** heilt ihre Drift im zweiten Init-Lauf
(`grep -qF -- '# adopter-drift'` auf `tools/harness/commit-msg-traceability.sh`). Die
Frei-Pfad-Richtung liest derselbe Lauf an einem **leeren** Ziel: der Träger liegt ausführbar und
delegiert an die Prüfung daneben.

### 1.3 Was ich deshalb **nicht** gefahren habe

`make mutate` (Post-integration), `make smoke` (nicht Gegenstand — DoD 2 verlangt das gebootstrappte
Ziel, nicht den Tier-2-Emit), die vier F-1-Fälle (`157`, `164`, `50`, `354` — nach Auftrag nicht
erneut) und der ganze übrige Bestand des Mutations-Sets.

---

## 2. Deckt der Sensor die Zusage?

### 2.1 DoD 1 — **erfüllt**

Gelesen am Baum, jede Hälfte an einer Stelle:

- die **Klasse steht am Eintrag**: `commitMsgHookFile()` → `class: SkipIfPresent`,
  `commitMsgCheckFile()` und `hooksInstallMkFile()` → `class: Konvergent` — drei getrennte
  Konstruktoren, nicht eine Gruppen-Zeile;
- **kein zweiter Schreibpfad**: `writeEnforceFile` verzweigt auf `f.class`; `writeSkipIfPresent` und
  `writeFileMode` erreichen den Träger nicht mehr (der Träger-Pfad geht durch
  `writeSkipIfPresentTold`, den einzigen Writer mit Meldung);
- **keine zweite Klassen-Angabe**: `git grep -n 'CommitMsgHookPath\|CommitMsgCheckPath\|HooksInstallMkPath' -- '*.go'`
  nennt je Pfad **genau einen** `enforceFile`-Konstruktor; `PathClass` liest `enforceFiles()`, die
  Aufzählung, die `Enforce` fährt;
- **fail-closed**: `case Konvergent / SkipIfPresent` mit anschließendem `return fmt.Errorf(… keine
  Idempotenz-Klasse (unbestimmt) — ein Pfad ohne Klasse faellt aus …)`;
- **kein Nachbar behauptet für den Träger die konvergente Klasse**: der Sweep über die zwei Formen
  (`git grep -n 'konvergent' -- internal/ harness/`, `git grep -n 'kanonisch neu' -- internal/
  harness/ spec/`) liefert **keinen** Treffer mehr, der den Träger als konvergent führt — jeder
  Treffer gilt einer anderen Datei oder ausdrücklich der **Prüfung**.

**Und rot gesehen** (§3.6, in `/tmp`-Kopien, Ausgabe gelesen):

```text
358 (Traeger wieder konvergent) -> FAIL TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
     commitmsg_test.go:189: .githooks/commit-msg wurde ueberschrieben (skip-if-present verletzt)
     (+ TestEnforce_IdempotenzKlasseJePfad: enforce_test.go:393: kein Pfad der Klasse skip-if-present
        in der Aufzaehlung — die Richtung dieser Klasse misst nichts)
361 (Traeger ohne Klasse)       -> FAIL (Enforce bricht ab) u. a.
     archivierung_test.go:91: .githooks/commit-msg: keine Idempotenz-Klasse (unbestimmt) — ein Pfad
     ohne Klasse faellt aus, statt konvergent zu gelten
```

### 2.2 Die zwei Zusagen sind **nicht** breiter als ihre Sensoren — mit einer Grenze

Gelesen in `TestEnforce_IdempotenzKlasseJePfad`: die Richtung je Pfad kommt aus `PathClass`, die
Vorbedingung *beide Klassen besetzt* steht als `t.Fatalf`, der Modus wird mitgezogen (Löschen +
verstellt Neuanlegen), und der erste Lauf dient als kanonischer Stand — die Zusage *„die Klasse steht
an einer Stelle"* wird damit **verhaltensmäßig** gehalten.

**Die Grenze, gemessen:** weil der Test die Erwartung aus derselben Aufzählung ableitet, die der
Writer liest, kann er eine **zweite** Klassen-Liste daneben nicht sehen — und eine Klassen-Umkehr am
Träger fällt ihm nicht über die Richtung, sondern nur über die **Vorbedingung** auf (mein `358`-Lauf
zeigt genau das: `enforce_test.go:393`, nicht eine Richtungs-Zeile). Die Richtungs-Aussage des
Trägers trägt allein `TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet`. Das ist keine
DoD-Verletzung — der Zustand *„keine zweite Fassung daneben"* ist heute wahr und gemessen —, aber die
Hälfte *„keine zweite Fassung entsteht"* hängt an **Konstruktion und Lesen**, nicht an einem Sensor
(**V-1**).

### 2.3 DoD 2 — **erfüllt**, in eigener Messung, jede der drei Richtungen

| Richtung | Beleg | gelesen |
|---|---|---|
| Pfad **frei** → Träger wird geschrieben | `full-smoke` §COMMIT-KENNUNG (leeres Ziel): Hook liegt, ist ausführbar, ruft die Prüfung daneben über sein eigenes Verzeichnis | ja — der Lauf bricht ab, wenn eines fehlt |
| Pfad **belegt** → bleibt unberührt **und der Lauf sagt es** | `full-smoke` §Klasse des Commit-Traegers: Inhalt gegen den gepflanzten Träger verglichen; die drei Sätze `skip-if-present`, `.githooks/commit-msg`, `tools/harness/commit-msg-traceability.sh` in der Ausgabe gesucht | ja — die Meldung steht oben im Wortlaut |
| die **Prüfung** selbst bleibt konvergent | `full-smoke`: die Drift `# adopter-drift` in `tools/harness/commit-msg-traceability.sh` ist nach dem Re-Lauf weg; `TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet` Teil 3 | ja |

Dazu die zwei Rot-Belege, die ich **selbst** gefahren habe (nicht aus einem Report übernommen):

```text
359 (Meldung ohne Pruefpfad)  -> FAIL TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
     commitmsg_test.go:195: die Meldung nennt "tools/harness/commit-msg-traceability.sh" nicht
49  (konvergenter Zweig uebersprungen) -> FAIL TestEnforce_IdempotenzKlasseJePfad
     (+ TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
        commitmsg_test.go:211: tools/harness/commit-msg-traceability.sh wurde nicht kanonisch neu
        geschrieben (konvergent verletzt))
```

`49` ist damit der gelistete Gegenbeispiel-Träger der **dritten** Richtung (die Prüfung bleibt
konvergent), und die Zusage des DoD 2 hat für jede ihrer drei Richtungen einen Fall, der sie rot
färbt. **Nicht** gefahren: der repo-weite `make mutate`-Satz (§1.3).

### 2.4 DoD 3 — **erfüllt**, die vier genannten Stellen gelesen

| Stelle | Wortlaut heute | Verdikt |
|---|---|---|
| Kopf des Aktivierungs-Fragments | *„DIE KLASSE DES TRAEGERS IST SKIP-IF-PRESENT (ADR-0054). Der Name ist von git fixiert und das Verzeichnis gehoert dem Repo: das Werkzeug legt seinen Traeger nur ab, WO DER PFAD FREI IST. Fuehrt das Repo dort schon einen eigenen, bleibt er unberuehrt und der Lauf sagt es …“* | gezogen |
| Fehlermeldung des Fragments | *„… dieses Fragment aktiviert einen commit-msg-Traeger dieses Verzeichnisses; das Werkzeug legt seinen eigenen nur ab, wo der Pfad frei ist, und laesst einen bereits liegenden unberuehrt (skip-if-present, ADR-0054).“* | gezogen — sie behauptet keine Urheberschaft mehr |
| Commit-Absatz des emittierten Anweisungssatzes | *„**An diesem Pfad ist das Werkzeug ein Gast** — … der Bootstrap legt seinen Träger **nur ab, wo der Pfad frei ist**. Führt dieses Repo dort schon einen eigenen, bleibt er unberuehrt … die mitgelieferte Prüfung … liegt in beiden Fällen daneben (sie wird bei jedem Lauf kanonisch neu geschrieben)“* | gezogen |
| `harness/README.md` §Traceability | *„Seine Prüfung reist als `tools/harness/commit-msg-traceability.sh` mit dem Klon; den Träger `.githooks/commit-msg` legt der Lauf daneben nur an einem freien Pfad ab … **Die zwei Nachbarn tragen zwei verschiedene Klassen** … der **Träger dagegen nur dort, wo der Pfad frei ist** (skip-if-present) … der Lauf nennt ihm den Pfad und die mitgelieferte Prüfung“* | gezogen |

Rot-Gegenbeispiel selbst gesehen: `360` löscht den Klassen-Satz aus dem Fragment →
`FAIL TestHooksInstallFragment_TraegtDieKlasseSeinesPfades` mit `fuehrt "SKIP-IF-PRESENT" nicht`,
`fuehrt "WO DER PFAD FREI IST" nicht`, `fuehrt "unberuehrt und der Lauf sagt es" nicht`.

**Die fünfte Stelle, die der Plan nicht nannte, aber dieselbe Klasse trug, ist mitgezogen** — ohne
daß der Plan sie forderte: der frühere Satz *„beide schreibt der Bootstrap kanonisch neu“* steht
nicht mehr. Das ist der DoD-3-Hälfte zuträglich, nicht ein Zuviel.

---

## 3. Sagt der Plan, was der Code tut?

**Geplant und gebaut** — jede Zeile der §3-Tabelle hat ihr Gegenstück im Diff: `enforce.go`
(Aufzählung + Schreib-Pfad), `commitmsg.go` (die zwei Klassen), `hooks-install.mk` (Kopf + Meldung),
`implement-slice.md` (Commit-Absatz), `harness/README.md`, `enforce_test.go` (der Ganz-Mengen-Test
auf beide Klassen gezogen, mit beiden Richtungen), `test/mutations/*` (vier neue Fälle) und
`harness/tools/full-smoke.sh` (die zwei Richtungen im gebootstrappten Ziel).

**Gebaut, aber nicht in §3** — sechs Stellen, jede mit einem Grund, keine ein Zuviel:

| Datei | Was | Warum sie nicht Zuviel ist |
|---|---|---|
| `internal/emit/agents.go`, `commands.go`, `archivierung.go`, `erfassung.go`, `slicemv.go` | ihre Einträge nennen ihre Klasse jetzt als Feld | Folge des fail-closed-Writers: ohne `class` fällt der Emit aus. Die **Klasse selbst ist unverändert** — keine zweite Fassung, sondern das Feld für die bestehende |
| `internal/emit/commitmsg_test.go` | der belegte Pfad als Go-Test (drei Richtungen) | §3 nennt `test/…` als *neu*; die Go-Hälfte desselben Belegs stand dort nicht |
| `internal/emit/fieldlist_test.go` | Namens-Verweis auf den umbenannten Test | Nachzug, keine Aussage |
| `test/mutations/{157,164,50,354}` | Anker-Nachzug | Folge aus Review-F-1 (Review-Zug `65b78423`) |

**Geplant und nicht gebaut: nichts.** Was §3 als *neu* führt (`test/… + test/mutations/*`), ist da;
die §3-Zeile zu `full-smoke.sh` nennt den Beleg, der im Lauf tatsächlich gefahren wird.

**§1-Ausschlüsse halten** — am vereinigten Diff gemessen:
`git diff d7fd8227^..HEAD --stat -- cmd/ internal/gen internal/wire spec/lastenheft.md
spec/spezifikation.md spec/architecture.md internal/emit/templates/commands/close-welle.md` → keine
Zeile. Die zwei Nachbar-Dateien des Trägers bleiben konvergent, die Erkennungs-Seite des
Identifiers ist unangetastet (`git log -1 -- internal/emit/templates/enforce/commit-msg-traceability.sh`
nennt den Vorgänger-Slice, nicht diesen), die Feststellungs-Zeile im emittierten `close-welle.md`
steht wörtlich.

**§5 / §6:** der Closure-Trigger setzt die vollständige DoD **plus** die gelesene Ausgabe des
belegten Pfades — beides liegt vor; die Closure-Notiz selbst ist Planner-Arbeit und damit **nicht
fällig** (§3.10). Die vier §6-Risiken stehen weiter auf `<…>` — ihr **Ausgang** gehört in die
Closure und ist hier ausdrücklich **nicht** geprüft.

---

## 4. Befunde eigener Klasse (Verifier — **keine** DoD-Verletzung)

### V-1 (INFO) — die Hälfte „keine zweite Fassung daneben“ hängt an Konstruktion, nicht an einem Sensor

`TestEnforce_IdempotenzKlasseJePfad` leitet die erwartete Richtung aus `PathClass` ab — derselben
Aufzählung, die `Enforce` fährt. Das macht ihn für die **Wirkung** je Pfad belastbar und für eine
**zweite Liste daneben** blind; eine Klassen-Umkehr am Träger erreicht ihn nur über die
Vorbedingung, nicht über die Richtung (gemessen: `358` → `enforce_test.go:393`). Der DoD-Punkt ist
als **Zustand** erfüllt (gemessen: ein `enforceFile`-Konstruktor je Träger-Pfad), seine belegte
Hälfte ist aber enger als sein Wortlaut. Kein Nachrüsten vorgeschlagen; die Grenze gehört benannt,
nicht geheilt.

### V-2 (INFO) — die Prosa-Hälfte von DoD 3 hat keinen Wächter, und das ist keine Panne

`grep -n '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans, planning,
targets` — kein Modul liest eine Prosa-Aussage über eine Idempotenz-Klasse, und
`make comment-claims` hat keine Markdown-Datei in seinem Prüfbereich. Daß die README-Zusage
**bedingt** formuliert ist, ist deshalb allein durch Lesen belegt (Review-F-4 wurde genauso
gefunden, nicht von einem Gate). Der heutige Zustand trägt; ein später **neu** hinzukommender Satz,
der am Pfad die Urheberschaft des Werkzeugs behauptet, färbt nichts rot. Zuständig für einen Träger
wäre der Architect — hier nur benannt.

### V-3 (INFO) — das Restrisiko der zwei reparierten Textanker, in eigener Messung bestätigt

```sh
grep -c '{src: "templates/enforce/span-emit.sh",' internal/emit/enforce.go   # 1  (Fall 157)
grep -c 'class: SkipIfPresent,' internal/emit/agents.go                       # 1  (Fall 164)
```

Beide Anker greifen an der **heutigen** Form, genau einmal. Fällt die Form weg, meldet
`harness/tools/mutate.sh:736` *„Mutation hat nicht gegriffen bei: … — Patch veraltet?“* — **laut**,
aber **nur nächtlich** (`cron: '17 2 * * *'`), und im Push-Pfad ungewächtert (`make gates` ruft
`mutate` nicht). Die Reparatur aus `65b78423` ist damit belegt und **nicht robust gegen die nächste
Formänderung**; ein Wächter dafür wird nicht behauptet und existiert nicht. Als Grenze
aufgenommen, nicht als offener Befund.

---

## 5. Was dieser Lauf nicht prüfen konnte

- **`make mutate` repo-weit** (Post-integration, nächtlich): der Bestand der 347 Fälle ist **nicht**
  gemessen. Gefahren sind fünf einzelne Fälle (`358`, `359`, `360`, `361`, `49`) in `/tmp`-Kopien —
  die vier neuen des Slice plus der Fall des konvergenten Zweigs.
- **Die vier F-1-Reparaturen** (`157`, `164`, `50`, `354`): nach Auftrag nicht erneut gefahren; sie
  sind über die Nachprüfung belegt, nicht von mir.
- **Die sprachlose Bootstrap-Variante im E2E**: `full-smoke` fährt `--lang go`; daß die drei
  Träger-Dateien auch sprachlos entstehen, trägt der Go-Test (so auch im Kommentar des
  Smoke-Abschnitts deklariert) — ich habe die sprachlose Variante nicht selbst gebootstrappt.
- **Semantik der Prosa**: „liest sich der Satz noch als Zusage an den Überflieger“ ist Urteil; ich
  habe die vier Stellen **gelesen** und gegen `ADR-0054` Festlegung 1 und 3 gehalten, nicht gemessen.
- **Die `ADR-0055`-Hälfte** (Teil-`Supersedes`, Index-Zusatz an der Status-Zelle der `ADR-0054`):
  nur als Eingang gelesen — der Zusatz steht in demselben Commit wie der Umschlag
  (`git show --stat fb6996dc` → `docs/plan/adr/0055-…md`, `docs/plan/adr/README.md`), und ihr
  Verfahren ist Konsistenzrunde der Architect-Rolle, nicht Verifikation.
- **Die Closure**: §7, Register, Risiko-Ausgänge, Paarungen, `git mv` — Planner.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| DoD-Verletzung | **0** |
| Verifier-Befund (INFO, Grenze) | 3 (V-1 · V-2 · V-3) |

**Verdikt:** Die drei Liefer-Punkte des §2 tragen am Stand `fb6996dc`; `make gates` ist EXIT 0 mit
dem namentlich geforderten `make test` darin, die zwei Richtungen des belegten Pfades und die
Konvergenz der Prüfung sind in der **gefahrenen** Ausgabe des gebootstrappten Ziels gelesen, und die
vier Sätze am Pfad sind gezogen. Die fünf unteren DoD-Zeilen sind **nicht fällig** (Planner,
[`AGENTS.md`](../../AGENTS.md) §3.10) und damit auch nicht unerfüllt. Offen bleiben die drei
benannten Grenzen (V-1 bis V-3) und der Ausgang der vier §6-Risiken — beides adressiert, nichts
davon blockiert den Handoff an den Planner.

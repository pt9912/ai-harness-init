# Verifikation `slice-lifecycle-move-geht-ins-ziel` — drei Liefer-Punkte tragen, der Doku-Punkt nicht

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `540c1657` (Umsetzung
`6d8401e3`, `89bc30f3`, `9915d99c`, Nachzug `9c2e11d7`; am selben Gegenstand eine
Planner-Korrektur `195ff371`, die den Fragment-Satz des DoD-Punkts 1 gezogen hat) — der Arbeitsbaum
war vor und nach jeder Messung leer (`git status --porcelain` → keine Zeile; `git rev-parse HEAD` →
`540c1657`) · **Prüfgegenstand:** §2 Definition of Done gegen den **tatsächlichen Stand**, dazu §1,
§3, §5, §6, §8 — **nicht** der Plan gegen sich selbst (das war der Reviewer) · **Reviews:**
`2026-09-15-slice-lifecycle-move-geht-ins-ziel` (Runde 1: 1 HIGH · 3 MEDIUM · 2 LOW · 1 INFO) und
dieselbe Kennung `-runde-2` (0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO); die eine LOW der Runde 2 (N-2) und
die INFO (N-1) sind in §4 als **Grenzen** geprüft, nicht als Verletzungen.

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an keinem der vier
Umsetzungs-Commits, an keiner der zwei Review-Runden und an keiner Datei des Slice etwas verfasst —
kein Kommentar, kein Testfall, kein Fragment, kein Plan-Satz, kein Review-Befund. Er hat gelesen und
Sensoren gefahren.

**Offengelegt — was dieser Lauf am Baum getan hat.** Zwei Mutations-Fälle (`344`, `345`) sind über
`make test-go` in **zwei `/tmp`-Kopien** des Baums gefahren worden (`tar`-Kopie ohne `.git`, jede
Kopie trug genau ihren Fall); am Repo ist **keine** Mutation angewandt worden. `make gates` und
`make full-smoke` liefen im Hauptbaum über `540c1657`. Die Glob-Probe des §2.1 lief in
`/tmp/globprobe/`, nicht im Repo. Nach allen Läufen: `git status --porcelain` ohne Zeile.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die **Closure** (§7,
Beobachtungs-Register, §6-Ausgänge, `git mv` — Planner-Arbeit nach
[`AGENTS.md`](../../AGENTS.md) §3.10), das zweite Wellen-Mitglied `slice-kennungs-waechter-geht-ins-ziel`
und die Closure der Welle `welle-emittierte-werkzeuge`. **F-7** (die überholte Fundliste in
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
§Grenze) ist dem Architect übergeben und kein Gegenstand dieses Laufs.

**Zitier-Form:** Kennung statt Adresse für alles, was der Prozess bewegt (der Slice, die Welle, die
Geschwister-Slices); ortsfeste Code-Pfade als Inline-Code, ortsfeste Ziele als Link. Der geprüfte
Gegenstand wird über seinen **Stand** festgehalten, nicht über seinen Lifecycle-Pfad. Eine
Baseline-Stelle steht als **Tag + Pfad in Inline-Code** (`v6.8.0` · `regelwerk/<datei>.md` §…).

---

## Ergebnis in einer Tabelle

| §2 DoD-Punkt | Verdikt |
|---|---|
| **Liefer-Punkt 1** — der emittierte Anweisungssatz nennt für Schritt 9 und Schritt 24 das Werkzeug statt des `git mv` von Hand, die repo-spezifischen Stellen bleiben adaptierbare Marker | **erfüllt** (§2.1) |
| **Liefer-Punkt 2** — das Ziel führt das Werkzeug, es zieht Verweise in beiden Richtungen nach, der Move bleibt ein reiner Commit | **erfüllt** (§2.2) |
| **Liefer-Punkt 3** — fehlt eine Voraussetzung, sagt das Werkzeug das und committet nichts; die zwei Pfad-Ausnahmen sind als Repo-Politik markiert | **erfüllt** (§2.3) |
| `make gates` grün | **erfüllt** (§2.4) |
| Review durchgeführt, Report unter `docs/reviews/` liegt vor | **erfüllt** (§2.5) |
| Doku-Update: die Aufzählung der emittierten Werkzeuge, soweit dieser Slice sie wachsen lässt | **nicht erfüllt** — keine lebende Doku des Repos angefasst (§2.6) |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **nicht fällig** — Planner ([`AGENTS.md`](../../AGENTS.md) §3.10) |
| Beobachtungs-Register (`../observations/`) fortgeschrieben | **nicht fällig** — Planner |
| Jedes Risiko aus §6 trägt einen Ausgang | **nicht fällig** — Planner; die drei Ausgangs-Platzhalter stehen unverändert |
| Die drei Paarungen sind getragen | **nicht fällig** — im Wellen-Repo die Welle-Closure (Modul 6) |

**DoD-Verletzung: genau eine.** Der Doku-Punkt — Fundort `slice-lifecycle-move-geht-ins-ziel` §2
gegen `harness/sensors/slice-mv.md`: dort steht kein Satz zum emittierten Zwilling, und der Diff
fasst **keine** lebende Doku dieses Repos an. Sie ist **bedingt** und hat eine zweite Lesart; beide
stehen samt Messung in §2.6, zu entscheiden hat sie der **Planner**.

**Befunde eigener Klasse (Verifier, keine DoD-Verletzung): drei** — §5.1 der Umfang von N-2, §5.2
die Aufzählung in N-2, §5.3 die Lesart-Hälfte des gezogenen DoD-Satzes. Dazu zwei Adress-Notizen im
Plan-vs-Artefakt-Diff (§3), die die Geschwister derselben Welle ebenso führen.

---

## 1. Ist der Sensor gelaufen?

Drei Sensoren tragen diese DoD: `make full-smoke` (Liefer-Punkte 2 und 3 im gebootstrappten Ziel),
die Go-Stufe (`make test-go`, die zwei Textwächter des Paares) und die bats-Stufe (`make test-bats`,
der Kopplungs-Fall der zwei Fassungen). Alle drei sind **gelaufen**, dazu zwei Mutationsfälle
einzeln. Kein Sensor ist ausgelassen; keiner ist aus einem Bericht übernommen.

### 1.1 `make full-smoke` — **EXIT 0**, die neuen Aussagen gefahren

```sh
make full-smoke   # EXIT 0, 0 Zeilen `full-smoke: FEHLER`
```

Wörtlich aus dem Lauf, die vier Zeilen des neuen Abschnitts und sein Abschluss:

```text
slice-mv ok: slice-smoke-move.md  open/ -> next/
  Commit 1 (reiner Move): open/slice-smoke-move.md -> next/slice-smoke-move.md
  eingehend: 1 Datei(en) mit Verweisen nachgezogen
  ausgehend: 1 praefixloses Ziel(e) in der bewegten Datei auf ../open/ umgehaengt
  Commit 2 (Inhalt, getrennt vom Move): 1 eingehend, 1 ausgehend
full-smoke: Lifecycle-Wechsel im Ziel (golang): make slice-mv bewegt slice-smoke-move.md nach next/, legt den reinen Move als eigenen Commit an (0 insertions/0 deletions) und zieht den Verweis-Nachzug getrennt davon nach — eingehend die Nachbar-Datei, ausgehend das praefixlose Geschwister; die ADR bleibt nach der Repo-Politik des Fragments unberuehrt.
full-smoke: Voraussetzung (golang): make slice-mv bricht ueber einem unsauberen Arbeitsbaum ab, nennt den Grund und bewegt nichts:
full-smoke:   slice-mv: Arbeitsbaum nicht sauber — erst committen oder stashen (das Skript committet selbst, siehe Skriptkopf VORAUSSETZUNG)
full-smoke: ohne Verweise (golang): make slice-mv bewegt slice-smoke-einsam.md und laesst es beim einen Move-Commit — kein zweiter Commit ohne Inhaltsaenderung.
full-smoke: ohne Werkzeug (golang): make slice-mv bricht LAUT ab und nennt die fehlende Datei:
full-smoke:   slice-mv: tools/harness/slice-mv.sh liegt nicht — das Fragment ruft das Werkzeug, das dieser Bootstrap schreibt; ein erneuter Lauf des Werkzeugs legt es ab.
full-smoke: OK — LIFECYCLE-WECHSEL IM ZIEL: make slice-mv ist kein Gate und steht in keiner gates-Kette; der Aufruf bewegt den Slice, legt den reinen Move als eigenen Commit an (0 insertions/0 deletions gegen den Verweis-Nachzug getrennt) und zieht beide Richtungen nach — den eingehenden Praefix-Verweis der Nachbar-Datei und das praefixlose Geschwister-Ziel in der bewegten Datei; eine ADR bleibt nach der Repo-Politik des Fragments unberuehrt; ueber einem unsauberen Arbeitsbaum bricht der Aufruf ab, nennt es und bewegt nichts; ohne jeden Verweis bleibt es beim einen Move-Commit; und ohne das Werkzeug bricht das Ziel laut ab, statt still auf ein fehlendes Programm zu zeigen.
```

### 1.2 `make gates` — **EXIT 0**

```sh
make gates        # EXIT 0
#  baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#  d-check: 1437 Datei(en) geprüft, 0 Befund(e)
#  1..295 · 0 Zeilen `not ok` in der bats-Stufe
#  comment-claims: 62 Datei(en) geprueft, 0 Befund(e)
```

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Dateizahlen wandern mit dem Baum (die zwei Review-Reports dieses Slice haben sie
selbst verschoben); tragend sind die Nullen und das `OK`.

### 1.3 Zwei Mutationsfälle selbst gefahren — Rot gelesen, mit gelesener Ursache

Je Fall eine eigene `/tmp`-Kopie (`tar`-Kopie ohne `.git`), Fall angewandt, `make test-go`:

```sh
# /tmp/verify-344 : sed -i '/^\t\tsliceMvShFile(),$/d' internal/emit/enforce.go
make test-go      # EXIT 2
#  --- FAIL: TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen (0.00s)
#      slicemv_test.go:73: tools/harness/slice-mv.sh liegt nicht im Ziel:
#        stat /tmp/TestSliceMvWerkzeug_…/001/tools/harness/slice-mv.sh: no such file or directory

# /tmp/verify-345 : sed -i 's/make slice-mv/git mv/g' internal/emit/templates/commands/implement-slice.md
make test-go      # EXIT 2
#  --- FAIL: TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen (0.00s)
#      slicemv_test.go:288: Schritt 9 (Eintritt nach in-progress) nennt den Aufruf `make slice-mv SLICE=…`
#        nicht in seinem Text — der Lifecycle-Wechsel steht dort als Handarbeit
#      slicemv_test.go:291: Schritt 24 (Closure nach done) nennt den Aufruf `make slice-mv SLICE=… TO=done`
#        nicht in seinem Text — die Closure steht dort als Handarbeit
```

**Beide Meldungen tragen die behauptete Ursache**, und beide sind die des **benannten** Wächters
(je `# expect:`-Zeile des Falls), nicht „irgendwie rot“. Die zwei Fälle sind die, die **kein**
früherer Lauf dieses Gegenstands gefahren hat — die Reviews haben `343` (Runde 1) und `346`
(Runde 2) rot gelesen, `344` und `345` ausdrücklich nicht (§Was dieser Lauf nicht prüfen konnte,
dort).

### 1.4 Worauf sich der Slice an Tests beruft — und was die Zahl trägt

Der Gegenstand beruft sich auf **sieben** Wächter in `internal/emit/slicemv_test.go` (fünf aus
`6d8401e3`, zwei aus `9c2e11d7`; `grep -c '^func Test' internal/emit/slicemv_test.go` → `7`) und auf
den bats-Kopplungs-Fall in `test/slice-mv.bats`, dazu auf **vier** neue Mutationsfälle
(`test/mutations/343`…`346`):

```sh
git diff --name-only --diff-filter=A 6d8401e3~1..HEAD -- test/mutations/ | wc -l   # 4
git diff --name-only --diff-filter=A bfa870c7~1..HEAD -- test/mutations/ | wc -l   # 22 (seit der Wellen-Eröffnung)
```

**Eine Zahl „fünfzehn“ ist nicht reproduzierbar** — weder in diesem Diff noch über der Welle; was
der Baum trägt, steht oben mit den zwei Kommandos (siehe §Was dieser Lauf nicht prüfen konnte).
Angewandt auf die Zusage heißt das: der Gegenstand ist über vier Fälle gedeckt, und die Zuordnung
Wächter → Fall ist **für drei der sieben** gegeben (§5.1).

---

## 2. Deckt der Sensor die Zusage?

### 2.1 Liefer-Punkt 1 — **erfüllt**

An der **Vorlage selbst** gelesen (nicht am Test): `internal/emit/templates/commands/implement-slice.md`

- **Schritt 9** (Zeilen 63-80) schreibt den Wechsel als
  ``**Jeder dieser Übergänge läuft über `make slice-mv SLICE=slice-<Kennung> TO=<next|in-progress>`**``
  vor und nennt die zwei Richtungen, den reinen Move-Commit und die Bedingung „auf dem Hauptzweig,
  vor der Arbeit“.
- **Schritt 24** (Zeilen 157-165) schreibt die Closure als
  ``**`make slice-mv SLICE=slice-<Kennung> TO=done`**, derselbe Aufruf wie in Schritt 9`` vor.
- **Keine Handarbeit mehr an den zwei Stellen:** `grep -c 'git mv' …` → `2`, und beide Vorkommen
  beschreiben das Werkzeug, statt es zu ersetzen (Zeile 34 im ANPASSEN-Block der Gates-Achse,
  Zeile 68 „das Werkzeug bewegt die Datei per `git mv`“).
- **Der Marker ist adaptierbar, und das ist gemessen:** der ANPASSEN-Block an Schritt 9 ist ein
  HTML-Kommentar, und die Commands werden **SKIP-IF-PRESENT** geschrieben
  (`internal/emit/commands.go` §`Commands` — „die Commands tragen den ANPASSEN-Marker, der Adopter
  adaptiert sie“; `test/commands_test.go` hält es). Ein Adopter-Edit überlebt den Re-Lauf damit
  wirklich; die Datei ist keine kanonisch überschriebene.

**Der gezogene Satz („was am Fragment frei ist“) trägt — beide Hälften, jede an ihrem Mechanismus
gemessen:**

| Hälfte des gezogenen Satzes | Messung |
|---|---|
| „die **Datei** ist frei (der Aggregator bindet `harness/mk/*.mk` per Glob ein)“ | `include harness/mk/*.mk` steht im emittierten Aggregator (`internal/emit/makefile.go`); Probe in `/tmp/globprobe/`: ein Fragment unter `harness/mk/` mit **beliebigem** Namen (`voellig-beliebiger-name.mk`) trägt sein Ziel in den Lauf — `make -n fremd` druckt es |
| „der **Ziel-Name** darin ist es **nicht** — er kommt aus einem tool-eigenen Fragment, das jeder Bootstrap kanonisch neu schreibt“ | `Enforce()` schreibt **jeden** Eintrag aus `enforceFiles()` unbedingt über `writeFileMode` (`internal/emit/enforce.go` §`Enforce`); das Fragment liegt an einem festen Zielort (`SliceMvMkPath = "harness/mk/slice-mv.mk"`, `internal/emit/slicemv.go`, dort als konvergent dokumentiert). Ein umbenanntes Ziel überlebt den nächsten Bootstrap nicht |

Der Marker der Vorlage führt dieselben zwei Hälften, und die zweite **wortgleich** zur DoD:
„Der Ziel-NAME `slice-mv` ist es nicht — er kommt aus einem tool-eigenen Fragment, das jeder
Bootstrap kanonisch neu schreibt.“ Die erste Hälfte heißt im Marker „der Weg zum Werkzeug“ statt
„die Datei“; die Lesart-Differenz steht als V-3 in §5.

**Kein DoD-Widerspruch:** der Punkt verlangt Marker, nicht eine bestimmte Fassung des Markers; die
gewählte folgt der Form, die der Schwester-Slice `slice-174-archivierung-emittieren` im **selben**
Anweisungssatz-Bestand führt (`internal/emit/templates/commands/close-welle.md`, Abschnitt zum
Träger).

### 2.2 Liefer-Punkt 2 — **erfüllt**

Die vier Teilsätze, jeder im gebootstrappten Ziel **gefahren** (§1.1) und nicht im Emit-Code
behauptet:

| Teilsatz | Beleg im Lauf |
|---|---|
| das Ziel **führt** das Werkzeug | `make slice-mv SLICE=… TO=next` im tmp-Repo endet mit 0 und meldet `slice-mv ok: …`; das Werkzeug liegt ausführbar (`tools/harness/slice-mv.sh`), das Fragment (`harness/mk/slice-mv.mk`) im Glob-Verzeichnis des Ziels |
| **eingehend** — jede Präfix-Form auf die bewegte Datei | die Nachbar-Datei trägt danach `../next/slice-smoke-move.md`; die Regel ist ein Wortgrenzen-Anker statt einer Formenliste (`rewrite_incoming_in_file`), und `test/slice-mv.bats` fährt **neun** Präfix-Tiefen über **beide** Fassungen |
| **ausgehend** — präfixlose Ziele innerhalb der bewegten Datei | das Geschwister-Ziel steht danach als `](../open/slice-smoke-bleibt.md)`; fünf bats-Fälle, ebenfalls über beide Fassungen |
| der Move bleibt ein **reiner** Commit, getrennt von der Inhaltsänderung; **fiel keine an, bleibt es beim einen** | `git log -2` trägt zwei `slice-mv:`-Betreffe, und `git show --numstat` des ersten ist **eine** Zeile `0 0`; der Zweig „ohne Verweise“ prüft über `git log -1`, dass die Spitze der Move-Commit **ist** (also kein zweiter entstand) |

**Die zwei Richtungen sind im Ziel belegt, nicht im Emit-Code.** Der E2E läuft die Kette
Aggregator → Fragment → abgelegtes Skript → `git` real durch; die Go-Stufe liest nur den Text von
Fragment und Skript, und genau das sagt ihr Kommentar über sich selbst.

### 2.3 Liefer-Punkt 3 — **erfüllt**

- **Die Voraussetzung greift vor jeder Bewegung.** `internal/emit/templates/enforce/slice-mv.sh`
  prüft den Arbeitsbaum in `main()` **vor** dem ersten `git mv` (die Prüfung steht bei
  `` `git diff --quiet` ``/`--cached`, der Move folgt danach) und endet mit Exit 2 und der Meldung
  „Arbeitsbaum nicht sauber — erst committen oder stashen“. **Committet nichts:** vor der Prüfung
  läuft kein `git`-Schreibkommando.
- **Rot gesehen, und zwar in jedem Smoke-Lauf:** der Fall wird im Ziel **hergestellt** (ein
  Nachtrag in einer getrackten Datei), das Kommando gefahren, Exit-Code, Meldung **und** die Probe
  „nichts bewegt“ gelesen — das Ziel bleibt in `next/`, es entsteht keine Datei in `done/`
  (`harness/tools/full-smoke.sh`, Abschnitt (e); Zeile aus dem Lauf in §1.1). Die Gegenrichtung —
  die Kante entfernt — ist in der Review-Runde 2 an einer Kopie rot gelesen und liegt hier nicht
  als eigene Messung vor.
- **Die zwei Pfad-Ausnahmen sind markiert, nicht versteckt:** als **REPO-POLITIK** im Skriptkopf
  (`:!.harness/baseline :!docs/plan/adr` mit Begründung: Fremdtext und die Hard Rule für
  `Accepted`-ADRs) und im Fragment; sie stehen als **setzbare** Variable
  (`SLICE_MV_AUSGENOMMENE_PFADE`), ausgelesen über die reine Funktion
  `eingehend_ausgenommene_pfade()`, und ein Go-Wächter hält genau diese Markierung fest. Der Beleg
  dafür, daß ein Repo sie **setzen** kann, stand schon in der Runde 2 (§5 der Messungen dort).

### 2.4 `make gates` grün — **erfüllt**

§1.2: **EXIT 0**, `d-check: 1437 Datei(en) geprüft, 0 Befund(e)`, bats `1..295` mit **0** `not ok`,
`baseline-verify: v6.8.0 OK`, `comment-claims: 62 Datei(en) geprueft, 0 Befund(e)`.

### 2.5 Review durchgeführt, Report liegt vor — **erfüllt**

Zwei Reports unter `docs/reviews/` (Runde 1 und `-runde-2`), in zwei eigenen
`Rolle Reviewer`-Commits (`e0bfe6ee`, `540c1657`), getrennt von den vier
`Rolle Implementer`-Commits. Runde 1 war blockierend (1 HIGH, 3 MEDIUM), Runde 2 ist
0 HIGH · 0 MEDIUM. **Nicht mechanisch prüfbar und darum nicht behauptet:** daß die zwei
Review-Läufe in einem anderen Kontext als die Umsetzung liefen (Modul 8) — das steht als Aussage
in den Reports, kein Sensor dieses Repos liest es.

### 2.6 Doku-Update: die Aufzählung der emittierten Werkzeuge — **nicht erfüllt**

**Was der Diff anfasst** (beide Richtungen, gemessen):

```sh
git diff --name-only 6d8401e3~1..HEAD | grep -E '\.md$'
#  docs/plan/planning/in-progress/slice-lifecycle-move-geht-ins-ziel.md   (Planner-Korrektur)
#  docs/reviews/2026-09-15-slice-lifecycle-move-geht-ins-ziel.md          (Review Runde 1)
#  docs/reviews/2026-09-15-slice-lifecycle-move-geht-ins-ziel-runde-2.md  (Review Runde 2)
#  internal/emit/templates/commands/implement-slice.md                    (die emittierte Vorlage)
```

Keine **lebende Doku** dieses Repos ist darunter — kein `harness/README.md`, keine Sensor-Prosa,
`README.md` nicht, `docs/user/` nicht. Der Slice läßt die Menge der emittierten Werkzeuge um **eins**
wachsen (ein neues Ziel samt Werkzeug im Ziel), und der Punkt ist bedingt formuliert: „soweit dieser
Slice sie wachsen lässt“.

**Der Träger dieses Satzes in dieser Welle, gemessen:** der Schwester-Slice
`slice-vorlauf-waechter-geht-ins-ziel` trägt den **wortgleichen** DoD-Punkt; sein Umsetzungs-Commit
`59fd546c` hat `harness/sensors/history-range-guard.md` um **20 Zeilen** wachsen lassen, und der
Abschnitt heißt `## Im gebootstrappten Ziel` (heute Zeile 55): „Dieselbe Logik reist als emittiertes
Werkzeug mit — `tools/harness/history-range-guard.sh` … und hängt dort an **beiden** history-lesenden
Targets“. Sein Verifier hat den Punkt über genau diese Stelle als **erfüllt** gelesen
(`2026-09-15-slice-vorlauf-waechter-geht-ins-ziel-verify.md` §2.6), und die Planner-Closure hat den
Punkt mit Häkchen geschlossen. Die Form ist im Wellenbestand also **einmal angewandt und abgenommen**.

**Die Analogstelle für diesen Slice** ist `harness/sensors/slice-mv.md` (die Prosa des Ziels, das
dieser Slice ins Ziel trägt) — sie trägt **keinen** Satz über die emittierte Fassung: ihr Vertrag
beschreibt die Dogfood-Fassung, ihre Grenze verweist für „Details und Beleg“ auf den Kopf von
`harness/tools/slice-mv.sh`, und die zwei Fassungen sind seit diesem Slice nicht mehr eine, sondern
zwei. Der Diff dieses Slice faßt die Datei nicht an.

**Die zweite Lesart — und sie ist ernst zu nehmen.** Versteht man „die Aufzählung der emittierten
Werkzeuge“ als ein Artefakt, das die emittierten Werkzeuge **auflistet**, dann existiert es in diesem
Repo nicht — gemessen über denselben Weg, den der Schwester-Verifier von
`slice-174-archivierung-emittieren` gegangen ist (`harness/README.md` und `README.md` nennen keinen
emittierten Zielpfad einzeln; `harness/README.md` §Sensors/§Werkzeuge führt die Ziele **dieses**
Repos). Dann hat der Punkt keinen Gegenstand und ist **nicht fällig** statt verletzt. Was dagegen
spricht, ihn so zu lesen: mit dieser Lesart hätte der wortgleiche Punkt des Schwester-Slice
**nicht** erfüllt sein können, und die Welle hat ihn dort über die Sensor-Prosa erfüllt und
abgenommen.

**Ich melde ihn als nicht erfüllt**, weil die Welle denselben Satz einmal so gelesen hat und der
Träger dort ein Ort ist, an dem dieser Slice **etwas zu schreiben hätte** — ein Satz genügt. Die
Entscheidung „nachziehen oder *nicht fällig* sprechen“ gehört nach
[`AGENTS.md`](../../AGENTS.md) §3.10 in die Hand des **Planners**, nicht in einen Nachzug der
Umsetzung; deshalb steht hier kein Auftrag an den Implementer.

**Nicht der Träger des Punktes ist Liefer-Punkt 1:** die emittierte `implement-slice.md` ist eine
Vorlage für das **Ziel** und nennt dort das Werkzeug; sie zählt die Werkzeuge **dieses** Repos nicht
auf. Zwei Punkte, zwei Gegenstände.

---

## 3. Sagt der Plan, was der Code tut?

§3 des Plans gegen den Diff, **beide** Richtungen; dazu §1 (Abgrenzung) und §8.

### 3.1 Geplant und gebaut

| §3-Zeile | Diff | Wort |
|---|---|---|
| `internal/emit/templates/commands/implement-slice.md` — update | `git diff --numstat 6d8401e3~1..HEAD -- internal/emit/templates/commands/implement-slice.md` → `22 7` | trägt |
| `internal/emit/templates/enforce/` bzw. ein Fragment im emittierten Fragment-Verzeichnis — neu/update | `templates/enforce/slice-mv.mk` und `slice-mv.sh` (neu) | trägt |
| `Makefile` (`full-smoke`) — update | die Änderung liegt in `harness/tools/full-smoke.sh` — `git diff --numstat 6d8401e3~1..HEAD -- harness/tools/full-smoke.sh` → `286 0` (netto) | **Adresse eine Ebene zu hoch** — das Rezept des Ziels ruft genau dieses Skript, die Wirkung ist die geplante. Der Schwester-Slice hat denselben Versatz in seiner §7 als „Was ging anders als geplant“ notiert (Nr. 2) |
| `test/…` — neu/update, „die zwei Ersetzungsrichtungen und der unsaubere Baum“ | `test/slice-mv.bats`, `internal/emit/slicemv_test.go`, `test/mutations/343`…`346` | trägt |

### 3.2 Gebaut, aber nicht im Plan genannt

- **`internal/emit/slicemv.go` (neu; `wc -l internal/emit/slicemv.go` → `42`)** — die zwei Zielorte und ihre Idempotenz-Klasse.
  Die §3-Zeile nennt „neu/update“ für die Vorlagen und „bzw. ein Fragment im emittierten
  Fragment-Verzeichnis“, aber **kein** Go-Artefakt; die Schwester-Slices nennen ihres
  (`internal/emit/emit.go`). Kein Defekt, eine fehlende Adresse.
- **`internal/emit/enforce.go` (`git diff --numstat 6d8401e3~1..HEAD -- internal/emit/enforce.go` → `8 0`)** — die Verdrahtung der zwei Dateien in `enforceFiles()`.
- **`test/mutations/346`** — aus der Review-Runde 2 (der Schwester-Befund F-2), im Plan nicht
  vorhersehbar; die anderen drei Fälle deckt die `test/…`-Zeile.

### 3.3 §1-Abgrenzung — am Diff geprüft, keine Berührung

| Ausgeschlossen laut §1 | Messung |
|---|---|
| der Anweisungssatz **dieses** Repos (Dogfood) | `.claude/commands/implement-slice.md` steht **nicht** in der Range; die Datei des Gegenstands ist die Vorlage unter `internal/emit/templates/` |
| der Zug am **Dogfood**-Werkzeug | `harness/tools/slice-mv.sh` steht nicht in der Range (`git diff --name-only 6d8401e3~1..HEAD`) |
| die dritte Hälfte eines Ortswechsels (Zustandsfeld) | kein Zug an einem Zustandsfeld; kein Move in der Range |
| der Produkt-Code | `internal/emit/` ist berührt — das ist die **Emission**, §1 grenzt „Produkt-Code“ auf den Laufzeitpfad ab, und `cmd/`/`internal/gen`/`internal/wire` stehen nicht in der Range |

Dazu die zwei Grenzen aus dem Auftrag: **`MR-057` ist nicht angefaßt** (`harness/conventions/**`
steht in keiner Datei-Liste der vier Commits — der Befund F-7 bleibt beim Architect), das zweite
Wellen-Mitglied (`docs/plan/planning/open/slice-kennungs-waechter-geht-ins-ziel.md`) ebenso wenig,
und **`make hooks-install` ist nicht gelaufen**: `git config --get core.hooksPath` ist leer, unter
`.git/hooks/` liegen nur die `.sample`-Dateien.

### 3.4 §8 — zwei Zahlen und eine Sub-Area, die der Plan nicht nennt

- Der **Sichtungs-Schritt** nennt zwei Treffer mit ihren Zähler-Ständen (24× und 6×) und das
  Kommando, das sie liefert. Nachgemessen in diesem Lauf: `zusage-neben-geaenderter-ableitung-bleibt-stehen`
  **25** Dateien unter `evidence/`, `verweise-brechen-beim-ortswechsel` **6**. Die erste Zahl ist seit
  dem Schreiben des Plans gewandert — der Plan nennt sein Kommando, der Wert ist damit eine datierte
  Messung und keine Zusage (kein Befund, der Beleg steht in der Zeile).
- Die **Sub-Area-Wahl** nennt allein `*` (gesamtes Repo). Der Diff berührt aber auch
  `harness/tools/full-smoke.sh` — das liegt in der **deklarierten** Sub-Area `harness/tools/`
  (`TOOLS`, GF). Die Folgerung des §8 („alle berührten Sub-Areas GF“) trägt weiter, die Aufzählung
  ist unvollständig; der Schwester-Slice führt dieselbe Form.

---

## 4. Die zwei Befunde der Runde 2 — als **Grenzen** geprüft

Beide sind am Bestand **wahr** und keine Verletzung; geprüft ist, ob sie so benannt sind, wie sie
sind.

### 4.1 N-2 — ein Wächter mit Zähnen, aber ohne Fall im Set

Die Aussage trifft zu: `TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch` hat keinen Fall in
`test/mutations/` (`grep -rl 'expect: TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch'
test/mutations/` → kein Treffer). Seine Zähne sind von der Runde 2 **rot gelesen** worden (dort
§7 der Messungen), und `make mutate` wird ihn nicht vermissen, solange der Fall fehlt — genau das
sagt der Befund. **Der Umfang der Klasse ist größer als der Befund** (V-1, §5.1).

### 4.2 N-1 — `schritteIn` schlüsselt über die Nummer und überschreibt bei Wiederholung

Die Aussage trifft zu, und sie ist eine **Code-Tatsache**, nicht eine Messung: in
`internal/emit/slicemv_test.go` §`schritteIn` setzt das Wiedersehen einer Nummer den Schlüssel auf
`""` zurück und füllt ihn danach mit der **späteren** Stelle. Damit verschiebt eine am Dateiende
angehängte Zeile `9. …` den Anker, und der Wächter wird grün, während Schritt 9 die Handarbeit
vorschreibt — die Runde 2 hat genau das gemessen. Die zwei Begleit-Aussagen des Befunds sind
ebenfalls reproduziert:

```sh
grep -cE '^[0-9]+\. ' internal/emit/templates/commands/implement-slice.md   # 25 Nummern
grep -oE '^[0-9]+\. ' internal/emit/templates/commands/implement-slice.md | sort | uniq -d | wc -l   # 0 Dubletten
```

Die Annahme *eindeutige Nummern* steht in keiner Zusage des Tests, ihre Verletzung ist still, und
der heutige Bestand verletzt sie nicht. **INFO ist die richtige Kategorie.** Für die Closure heißt
das: der Befund ist als **Grenze** in §7 zu führen (er beschreibt, was der Anker nicht deckt), nicht
als Nachzug der Umsetzung.

---

## 5. Befunde eigener Klasse (Verifier — **keine** DoD-Verletzung)

### 5.1 V-1 (INFO) — N-2 nennt einen von vier Wächtern ohne Fall

Von den **sieben** Wächtern, die dieser Slice in `internal/emit/slicemv_test.go` anlegt, sind
**drei** über einen Mutationsfall gedeckt und **vier** nicht:

```sh
for g in $(grep -oE '^func Test[A-Za-z_]+' internal/emit/slicemv_test.go | sed 's/func //'); do \
  printf '%s  %s\n' "$(grep -rl "expect: $g" test/mutations/ | wc -l)" "$g"; done
#  1  TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette        (343)
#  1  TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen        (344)
#  0  TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert
#  0  TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch             ← N-2
#  0  TestSliceMvFragment_TraegtDieFailClosedKante
#  1  TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen               (345)
#  0  TestSliceMvWerkzeug_IstNichtDerDogfoodPfad
```

N-2 ist **nicht falsch**, aber es nennt eine Teilmenge: `Ausnahmen_SindAlsRepoPolitikMarkiert`,
`TraegtDieFailClosedKante` und `IstNichtDerDogfoodPfad` stehen ebenso ohne Fall da. Für
`TraegtDieFailClosedKante` trägt der E2E (h) die rote Richtung ausdrücklich (sie ist **rot gelesen**,
§2.3); die zwei anderen haben ihre rote Richtung nicht vorgeführt. Die Klasse steht als
`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`-Nachbarin ohnehin im Register —
sie gehört als **Grenze** in die Closure-Notiz, mit dieser Aufzählung statt mit einem Namen.

### 5.2 V-2 (INFO) — die Aufzählung in N-2 trifft den Bestand nicht

N-2 schreibt: „Die fünf Fälle mit `slice-mv`-Bezug zeigen auf 315, 343, 344, 345 und 346“. Gemessen
über die `# files:`-Zeilen führen **vier** Fälle auf eine `slice-mv`-Datei des Repos, zwei weitere
auf die emittierte Vorlage, und einer (`344`) auf `internal/emit/enforce.go`:

```sh
for f in test/mutations/*.sh; do grep -q 'slice-mv' <<<"$(grep -m1 '^# files:' $f)" && basename $f; done
# 313 · 315 · 316 · 343 · 345 · 346   (Fälle auf harness/tools/… bzw. templates/enforce/slice-mv.sh)
```

Die Fundmenge ist also größer als die genannte Liste und ihr Zuschnitt ein anderer (`313`/`316`
fehlen, `344` gehört nur über seinen `# expect:` dazu). **Der Befund trägt unverändert** — keiner
dieser Fälle zeigt auf `TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch` —, aber die
Aufzählung ist ein Fundort, nicht die Fundmenge. Als eigene Klasse notiert, damit sie nicht als
Vollständigkeit gelesen wird.

### 5.3 V-3 (INFO) — „der Weg zum Werkzeug“ und „die Datei“ sind zwei verschiedene Freiheiten

Der gezogene DoD-Satz nennt als freie Hälfte **die Datei** und begründet sie mit dem Glob. Der
Marker in der Vorlage nennt als freie Hälfte **„den Weg zum Werkzeug“**. Beides ist **wahr**, aber
es ist nicht dasselbe: der Glob macht einen **adopter-eigenen** `.mk`-Träger beliebig benennbar
(§2.1, gemessen), während der Weg zum Werkzeug über die Variable `SLICE_MV` gesetzt wird; die
**emittierte** Fragmentdatei selbst ist wie ihr Zielname kanonisch überschrieben und darum **nicht**
umbenennbar, und das sagt weder der eine noch der andere Satz. Ein Leser, der „die Datei ist frei“
auf das emittierte Fragment bezieht, plant eine Umbenennung, die der nächste Bootstrap zurücknimmt.
Die zwei Hälften des Markers sind unter sich stimmig (die zweite Hälfte sagt ausdrücklich, was nicht
frei ist); die Differenz liegt zwischen DoD-Satz und Marker. **Benannt, nicht geschlossen** — die
Auflösung ist eine Zeile, wenn der Planner sie zieht.

---

## Was dieser Lauf nicht prüfen konnte

- **Kein voller `make mutate`** (Weisung des Auftrags): gefahren sind zwei Fälle einzeln (`344`,
  `345`) mit gelesener Ursache; `343` und `346` sind von den zwei Review-Runden rot gelesen, ihre
  Läufe habe ich nicht wiederholt.
- **Die Zahl „fünfzehn neue Mutationsfälle“** konnte ich **nicht** reproduzieren: der Diff dieses
  Slice trägt **vier** neue Fälle (`343`…`346`), die Welle seit ihrer Eröffnung **22**
  (§1.4, je mit Kommando). Was immer die Zahl meint — über den Baum ist sie nicht zu holen, und
  darum ist sie hier auch nicht als Beleg geführt.
- **Die Kontext-Trennung der zwei Review-Läufe** (Modul 8) — kein Sensor dieses Repos liest sie;
  geprüft ist, daß es zwei eigene `Rolle Reviewer`-Commits gibt und die Reports nicht vom
  Implementer stammen.
- **Die sprachlose Bootstrap-Variante des neuen E2E-Abschnitts.** Gefahren ist das `--lang-go`-Ziel
  (der E2E sagt das über sich selbst); die sprachlose Variante ist über die Go-Stufe gedeckt, nicht
  über einen zweiten Bootstrapp.
- **Die Closure** — §7, Register, die drei §6-Ausgänge, der `git mv`, die DoD-Häkchen: Planner
  ([`AGENTS.md`](../../AGENTS.md) §3.10). Die drei Ausgangs-Platzhalter des §6 stehen unverändert im
  Plan; ob sie als *eingetreten* / *entfallen* / *weiter offen* ausgehen, entscheidet er.
- **Der zweite Wellen-Mitglied und die Wellen-Closure** — nicht Gegenstand.
- **Die Kopfhälfte der zwei Fassungen.** Der bats-Kopplungs-Fall vergleicht die **Rümpfe** der drei
  Ersetzungs-Funktionen (`KERN=(re_escape rewrite_incoming_in_file rewrite_outgoing_bare_in_file)`),
  nicht die Skript-Köpfe: die vier Grenzen, der REPO-POLITIK-Block und der Usage-Text der
  emittierten Fassung können vom Dogfood abweichen, ohne daß ein Sensor färbt. Die Klasse ist im
  Register benachbart (`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`); sie ist
  **keine** Zusage dieses Slice und darum hier nur benannt.

## Verdikt

**Die drei Liefer-Punkte tragen — gefahren, nicht übernommen.** `make full-smoke` ist **EXIT 0** und
trägt jede der drei Zusagen im gebootstrappten Ziel: das Werkzeug läuft dort, beide Nachzug-Richtungen
wirken, der Move bleibt ein reiner Commit und ohne Verweise beim einen, der unsaubere Arbeitsbaum
bricht laut ab, ohne zu bewegen, und ohne Werkzeug endet das Ziel laut statt still. `make gates` ist
**EXIT 0** über dem benannten Stand. Zwei Mutationsfälle hat dieser Lauf selbst gefahren und die
Meldung **gelesen**; beide fällt ihr benannter Wächter mit der behaupteten Ursache.

**Eine DoD-Verletzung steht: der Doku-Punkt.** Der Diff läßt die Menge der emittierten Werkzeuge um
eins wachsen und faßt **keine** lebende Doku dieses Repos an; nach der Form, die die Welle für den
wortgleichen Punkt einmal angewandt und abgenommen hat, ist der Träger die Prosa des Werkzeugs
(`harness/sensors/slice-mv.md`) — ein Satz zum emittierten Zwilling. Sie ist **bedingt**, die zweite
Lesart (*kein Artefakt führt die Aufzählung* → nicht fällig) steht in §2.6, und entscheiden muß sie
der **Planner**: die ausführende Rolle schreibt ihr Abnahmekriterium nicht um
([`AGENTS.md`](../../AGENTS.md) §3.10). Solange sie steht, ist der Punkt *DoD vollständig* des
§5-Closure-Triggers **nicht erfüllt** — der zweite und dritte §5-Satz (*`make full-smoke` grün und
die beiden Richtungen dort belegt*, *`make gates` grün*) sind es.

**Die zwei Befunde der Runde 2 sind Grenzen, keine Verletzungen** (§4): N-2 trifft zu und ist als
Fall-Lücke im Mutations-Set richtig verortet, N-1 ist eine Code-Tatsache über den Anker und im
heutigen Bestand unwirksam (0 Dubletten, 25 Nummern). Drei Befunde eigener Klasse stehen daneben
(§5.1–§5.3), alle INFO: der weitere Umfang der Fall-Lücke, die Aufzählung in N-2, und die zwei
Freiheiten des gezogenen DoD-Satzes.

Dieser Report ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen und ersetzt
keine Closure (Modul 11).

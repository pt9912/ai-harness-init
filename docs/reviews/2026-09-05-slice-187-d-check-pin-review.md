# Review — slice-187: Der d-check-Pin springt `v0.65.0` → `v0.74.1`

## Kopf-Metadaten

- **Rolle:** Reviewer (Modul 8/10), frischer Kontext, kein Selbst-Review.
  Skill: [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) `1.7.0`.
- **Datum:** 2026-09-05 · **Runde:** 1
- **Gegenstand:** [slice-187](../plan/planning/in-progress/slice-187-d-check-pin-v0741.md) —
  noch **nicht** geschlossen (`in-progress/`).
- **Umsetzungs-Commit:** `9a1a22f` — drei Dateien, 43+/32−
  (`git show --stat 9a1a22f`): [`d-check.mk`](../../d-check.mk) 69 Zeilen,
  [`internal/emit/emit.go`](../../internal/emit/emit.go) 4, [`Makefile`](../../Makefile) 2.
  Die sechs Commits davor (`5c85147`, `a5d190e`, `fc2b8e9`, `bd51497`, `81a2749`, `a10de4a`)
  sind Lifecycle-Bewegung; ihr Verweis-Nachzug ist hier nur dort Gegenstand, wo er einen
  Zustand hinterlassen hat (LOW-2).
- **Arbeitsbaum:** sauber, `main` **voraus 1** gegen `origin/main` (`git status -sb`) —
  `9a1a22f` liegt **nicht** auf dem Hauptzweig.
- **Berührte `LH-*`:**
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Digest-Pin ist die
  Reproduzierbarkeits-Zusage) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (die Target-Aufzählung, die *behauptet* von *advisory* trennt) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (alle Läufe dieses
  Reports über `make`/`docker`/`git`, keine Host-Toolchain).
- **Referenzierte ADRs:** der Slice-Plan und `9a1a22f` nennen **keine**
  (`grep -oE 'ADR-[0-9]{4}' <plan>` → leer). Damit auch keine superseded referenziert.
- **Referenzierte Adaptions-Einträge** (`grep -oE 'MR-[0-9]{3}' <plan> | sort -u`): `MR-001`, `MR-009`,
  `MR-010`, `MR-011`, `MR-012`, `MR-017`,
  `MR-024`, `MR-025`, `MR-027`, `MR-037`.
- **Hard Rules geprüft:** [`AGENTS.md`](../../AGENTS.md) §3.1, §3.2, §3.3, §3.4, §3.5, §3.6,
  §3.7, §3.8, §3.9.
- **Vorherige Findings am gleichen Modul (d-check-Pin-Linie):**
  [`2026-08-22-slice-088-review.md`](2026-08-22-slice-088-review.md) (HIGH-1 *Kopf sagt über
  sechs Recipes, was für fünf gilt*; **MEDIUM-2** *`MR-010` §Setzung 2 zählt die
  advisory-Targets abschließend, der Diff macht die Liste unvollständig*; MEDIUM-3
  *§3.5-Antwort ruht auf einem 0→0-Trockenlauf*) ·
  [`2026-08-28-slice-122-review.md`](2026-08-28-slice-122-review.md) (HIGH-1 *Marker-Tabelle
  am Bestand widerlegt*; **MEDIUM-4** *die zwei Kopplungstests haben keinen Fall in
  `test/mutations/`*; LOW-1 *`d-check.mk:2` zieht die Version, lässt den Rang-Zeiger stehen*) ·
  [`2026-08-28-slice-128-review.md`](2026-08-28-slice-128-review.md) (HIGH-1 *der neue Kopf
  beschreibt den Text, der bis zu diesem Commit an seiner Stelle stand*).
  **Drei dieser Klassen kehren wieder** — MEDIUM-1, LOW-1 und LOW-2 unten; **zwei sind hier
  ausdrücklich erledigt** (slice-088 HIGH-1 und slice-122 HIGH-1, siehe N-4 und N-6).

### Selbst gefahrene Sensoren

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT 0** |
| darin `make docs-check` | `d-check: 821 Datei(en) geprüft, 0 Befund(e)` |
| darin `make comment-claims` | `55 Datei(en) geprueft, 0 Befund(e)` |
| darin `make span-check` | `Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert` |
| `make freshness-dcheck` | `d-check: aktuell — gepinnt und latest sind beide v0.74.1.`, EXIT 0 |
| `MUTATE_FORCE=1 make mutate` | **`250 ok, 0 Befund(e)`**, EXIT 0 (§Nachtrag — der *unerzwungene* Lauf ist ein Beleg-Übersprung und misst nichts) |
| `make -C <kopie> test-go` mit zurückgesetztem `emit.go` | EXIT 2, beide Kopplungstests `--- FAIL:` — das DoD-(1)-Gegenbeispiel selbst rot gesehen (N-1) |
| `make docs-check` mit diesem Report im Baum | `822 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 |

**Was dieser Report nicht ist:** kein Verifier. DoD-Abhakung, Plan-vs-Code-Konformitätsbericht
und die Bestätigung, dass die Rot-Läufe aus §3.6 *stattgefunden haben*, gehören Modul 11.
Geprüft ist hier, ob die Zusagen **tragen** und ob ein stiller Grün-Pfad besteht.

---

## Findings

### MEDIUM-1 — `MR-010` §Setzung 2 ist mit diesem Commit an drei Stellen falsch, und die Reihenfolge-Annahme, die das auffangen sollte, ist nicht eingetreten

- **kategorie:** MEDIUM
- **quelle:** [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Setzung 2 · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  Slice-Plan §6 *Übergabe 2* und §6 letztes Risiko
- **pfad:** `harness/conventions/MR-010-d-check-gate-fragment-tool-generiert.md:37-47`
  gegen [`d-check.mk`](../../d-check.mk) auf `9a1a22f`
- **befund:** Setzung 2 trägt drei Aussagen, die am Stand nach `9a1a22f` nicht mehr zutreffen.
  (a) *„`d-check.mk` führt **zwölf** Targets (`grep -cE '^docs?-[a-z-]+:' d-check.mk` → **12**)"* —
  dasselbe Kommando liefert jetzt **13**. (b) *„`make doc-help` listet dieselben zwölf"* —
  `make doc-help` listet **13**, `doc-usage` mit. (c) Die abschließende Aufzählung der
  *„übrigen **elf**"* advisory-Targets nennt `doc-usage` nicht; Setzung 2 sagt über genau
  diesen Fall selbst: *„Die Aufzählung **ist** die Grenzziehung: ein Target, das in ihr fehlt,
  ist weder als behauptet noch als advisory ausgewiesen."* `doc-usage` existiert damit an HEAD
  in keiner der zwei Klassen, die [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  auseinanderhält.
  Der Slice-Plan hat das gesehen und als **Übergabe 2** an den Architect gestellt, mit dem
  Satz *„Das ist kein optionaler Posten: Er ist die Bedingung dafür, dass die Aufzählung nach
  dem Umsetzungs-Commit noch stimmt."* Sein letztes §6-Risiko schreibt dafür den Ausgang
  *„entfallen: der Architect-Lauf liegt **vor** dem Umsetzungs-Lauf"*. Er liegt nicht davor:
  `git log --oneline -12` zeigt zwischen `5c85147` (Planner) und `9a1a22f` (Implementation)
  keinen Architect-Commit, und
  `grep -rln 'v0\.74\.1\|e31a372b' harness/ AGENTS.md docs/user/` ist leer. Der Implementer hat
  [`AGENTS.md`](../../AGENTS.md) §3.8 dabei **korrekt** eingehalten — `git show --pretty=format: --name-only 9a1a22f`
  führt genau `Makefile`, `d-check.mk`, `internal/emit/emit.go` und kein Architect-Artefakt.
  Der Befund ist nicht, dass jemand das Falsche geschrieben hat, sondern dass der Zustand an
  HEAD eine falsche Aussage in einem lebenden Norm-Artefakt stehen lässt und der einzige
  benannte Auffang-Mechanismus seine Vorbedingung verloren hat.
- **verifizierbar:** ja, selbst gefahren:
  `grep -cE '^docs?-[a-z-]+:' d-check.mk` → **13** (gegen `git show 9a1a22f^:d-check.mk` → **12**);
  `make doc-help` listet 13 Zeilen, `doc-usage` darunter;
  `grep -n 'zwölf' harness/conventions/MR-010-*.md` → Zeile 38.
  Kein Gate meldet es: `.d-check.yml` führt `[links, anchors, ids, matrix, codepaths, spans]`,
  keines davon hält eine Prosa-Zahl gegen ein `grep` — was
  [`MR-027`](../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
  §*Kein Wächter über einer Versions-Nennung in Prosa* selbst festhält.
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen`
  ([Register](../plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  **13×**, Stand `geplant`/`slice-153`) — und zwar in der Unterklasse, die `state.md` dort
  ausdrücklich als **offen** ausweist: *„jede Unterklasse, in der die Zusage kein Anker ist —
  Skript-Ausgabe, Testname, **Prosa-Zahl**, Präsens-Satz"*.
- **Nachbar-Kontext:** Genau diese Klasse an genau dieser Stelle ist
  [`2026-08-22-slice-088-review.md`](2026-08-22-slice-088-review.md) **MEDIUM-2**
  (*„`MR-010` §Setzung 2 zählt und benennt die advisory-Targets abschließend; der Diff macht
  die Liste unvollständig"*). Damals ging sie **elf → zwölf**, jetzt **zwölf → dreizehn**.

### MEDIUM-2 — `MR-034` erklärt sich selbst zum „geltenden Stand" und nennt den überholten Pin; er steht in keinem der vier Übergabe-Posten

- **kategorie:** MEDIUM
- **quelle:** [`MR-034`](../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
  §Adaption und §*Löst auf* · Slice-Plan §6 *Übergabe an den Architect* ·
  [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `harness/conventions/MR-034-das-geteilte-referenz-ventil-traegt-am-gepinnten-stand.md:27-28`
- **befund:** Der Eintrag schreibt im Indikativ: *„**Adaption — der Sachstand, mit den
  Kommandos, die ihn ausgeben.** Der gepinnte d-check ist `ghcr.io/pt9912/d-check:v0.65.0`
  unter dem Digest in `d-check.mk`."* Nach `9a1a22f` ist der gepinnte d-check `v0.74.1`. Der
  Eintrag ist nicht bloß datiert: Sein Titel lautet *„… trägt **am gepinnten Stand**"*, und
  sein §*Löst auf* grenzt sich gegen die abgelösten Einträge mit dem Satz ab *„ihr Rumpf ist
  die richtige Aussage über den Tag ihres Datums, und **hier** steht der geltende Stand."*
  Er beansprucht damit ausdrücklich die Rolle, die er nach diesem Commit nicht mehr ausfüllt.
  Die Übergabe an den Architect im Slice-Plan §6 zählt **vier** Posten (neuer Eintrag ·
  `MR-010`-Target-Zahl · §Baseline-Zeile · vier Fähigkeiten) und nennt `MR-034` in keinem.
  Der Posten hat damit keinen Zuständigen: Der Implementer darf ihn nach §3.8 nicht schreiben,
  der Architect erfährt nicht davon.
- **verifizierbar:** ja, selbst gefahren:
  `git grep -ln 'v0\.65\.0\|5ea03abe' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!docs/plan/planning/in-progress' ':!docs/plan/planning/open'`
  → **neun** Dateien. Von ihnen tragen genau zwei eine **Präsens**-Aussage über den lebenden
  Pin: `MR-010` (MEDIUM-1) und `MR-034` (hier). Die übrigen sieben sind unverändert wahr —
  `ADR-0026`, `ADR-0032` und `CO-005` sind eingefroren bzw. Zeitdokument, `harness/conventions.md:149`
  trägt `v0.65.0` allein im **Titel** der `MR-027`-Indexzeile, `MR-027` ist die Aufzeichnung
  seines eigenen Sprungs, und `welle-13` nennt `v0.65.0` als Mess-Tag samt der Auflage, §1 und §6
  *„gegen `v0.74.1` neu fahren"*. Ein Grenzfall bleibt: `MR-025:136` sagt *„die Vorfrage ist am
  **neuen** Tag wiederholt … über `v0.65.0`"* — der Tag ist genannt (und damit
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)-konform),
  aber „neu" ist er nach diesem Commit nicht mehr; das ist schwächer als die zwei oben und hier
  nur benannt. `grep -c 'MR-034' <slice-plan>` → **0**.
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen` — dieselbe wie MEDIUM-1.
  Nach Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register (*„Zwei Funde im
  selben Vorgang sind eine Gelegenheit"*) zählen MEDIUM-1, MEDIUM-2 und LOW-2 zusammen als
  **ein** Beleg, nicht als drei.

### MEDIUM-3 — Der neu geschriebene Kopf-Satz beschreibt den Vorgang seiner Entstehung statt der Stelle

- **kategorie:** MEDIUM (zur Nicht-Einstufung als HIGH siehe unten)
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*„Beschrieben wird die Stelle, nicht der
  Vorgang, der sie erzeugt hat"*; *„Ein Sensor-Name ist keine Herkunft … das Protokoll seines
  Laufs gehört nicht dazu"*)
- **pfad:** [`d-check.mk:22-23`](../../d-check.mk) und `d-check.mk:48`
- **befund:** Zwei Stellen des in diesem Commit **neu geschriebenen** Kopfes sprechen über die
  Entstehung des Textes statt über den gepinnten Stand.
  (a) `d-check.mk:22-23`: *„VERENGTES MARKER-VERHALTEN, an einer frischen Sonde unter v0.74.1
  gemessen **statt vom Vorgaenger-Pin geerbt**"* — der Nebensatz ist das Protokoll eines
  einmaligen Laufs im Partizip Perfekt plus die ausdrücklich verworfene Alternative. Die Sonde
  ist kein stehender Sensor: Sie existiert im Repo nicht (`git grep -n 'd-check:ignore' -- 'test/*' 'harness/tools/*'`
  → leer; `test/`, `harness/tools/` führen
  keine), sie lief einmal außerhalb des Baums. Damit greift die Ausnahme *„ein Sensor-Name
  gehört zur Zusage"* nicht.
  (b) `d-check.mk:48`: *„kein Skript dieses Repos tut das heute (**gemessen, nicht vermutet**)"* —
  eine Aussage über die eigene Herkunft neben einer Mengen-Behauptung, für die im Absatz kein
  Kommando steht. Wer die Zeile ändert, erfährt weder, welche Menge geprüft wurde, noch womit.
- **verifizierbar:** nein durch ein Gate — und das ist der Punkt. `make comment-claims` prüft,
  *ob ein genannter Sensor existiert*, nicht, *worüber ein Kommentar spricht*, und `d-check.mk`
  liegt ohnehin außerhalb seiner vier Pfad-Muster (`55 Datei(en) geprueft` im gates-Lauf,
  `d-check.mk` nicht darunter). [`AGENTS.md`](../../AGENTS.md) §3.7 sagt das selbst: *„Ein
  Wächter existiert nicht."* Nachweisbar ist der Befund am Text: `sed -n '22,23p;48p' d-check.mk`.
- **Warum MEDIUM und nicht HIGH.** Der Reviewer-Skill führt *„Kommentar trägt keine der fünf
  Kommentar-Klassen"* unter HIGH, und `d-check.mk` liegt im Gate-Pfad (Kontext-Eskalation).
  Herabgestuft wird hier begründet, nicht aus Nachsicht: Die **tragende** Aussage des Blocks —
  die Marker-Tabelle und die Vier-Spalten-Zusage — ist eine Zusage im Indikativ, sie ist
  vollständig, und sie ist von mir unabhängig nachgemessen und **richtig** (N-4, N-5). Der
  Verstoß sitzt in zwei adverbialen Einschüben, die nichts behaupten, was falsch wäre; sie
  sagen nur etwas, das an dieser Stelle nicht hingehört. Die drei HIGH-Beispiele des Skills
  (verworfene Alternative im Konjunktiv · abwesender Text · abgebrochener Satz) treffen keiner
  wörtlich. Wird der Einstufung widersprochen, ist das ein Kategorisierungs-Streit im Sinn des
  Skills (*„Streit über eine Kategorisierung ⇒ Regel hier schärfen"*), kein Konflikt-Pfad.
- **klasse:** `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` — im
  [Register](../plan/planning/observations/README.md) heute nicht geführt;
  `adaptions-block-spricht-ueber-sich-selbst` (3×) ist der nächste Nachbar und deckt den Fall
  nicht (er handelt vom Adaptions-Block, nicht von Kommentaren in Code/Konfiguration).
- **Nachbar-Kontext:** [`2026-08-28-slice-128-review.md`](2026-08-28-slice-128-review.md)
  HIGH-1 traf denselben Kopf in derselben Klasse (*„beschreibt den Text, der bis zu diesem
  Commit an seiner Stelle stand"*). Die damalige Form ist hier **behoben** — die
  `v0.62.0`-Spalte ist weg (N-3) —, die Klasse ist es nicht.

### LOW-1 — Die zwei Kopplungstests, auf denen DoD (1) ihr Rot erzeugt, haben weiterhin keinen Fall in `test/mutations/`

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„gelistet heißt: wer keinen Fall in
  `test/mutations/` hat, ist unbewacht"*) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `test/mutations/` gegen `internal/emit/emit_test.go:30` und `:42`
- **befund:** DoD (1) stützt ihr Rot ausschließlich auf
  `TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical`. Beide haben keinen
  Mutations-Fall; ihr Nachbar, die Baseline-Pin-Kopplung, hat einen
  (`test/mutations/01-baseline-pin-kopplung.sh`, `expect: TestDefaultBaselineSHA256_MatchesMakefile`).
  Versagens-Szenario: Ein späterer Umbau des Hilfsstücks `mkVar` oder der Vergleiche lässt beide
  Tests grün, ohne noch zu koppeln — `make mutate` bliebe stumm, weil es nur **gelistete**
  Wächter prüft, und der nächste Pin-Sprung lieferte einen `emit.go`-Default, der von
  `d-check.mk` abweicht.
- **verifizierbar:** ja.
  `grep -rln 'DefaultDigest\|DefaultImage\|DCHECK_DIGEST\|MatchesCanonical' test/mutations/` → leer;
  `grep -n 'expect:' test/mutations/01-baseline-pin-kopplung.sh` → die Schwester-Kopplung.
- **klasse:** `kopplungstest-ohne-mutations-fall` — im Register heute nicht geführt.
- **Nachbar-Kontext:** identisch zu
  [`2026-08-28-slice-122-review.md`](2026-08-28-slice-122-review.md) **MEDIUM-4**. Der Befund
  ist seit dem Vorgänger-Sprung unverändert offen; er ist **nicht** von diesem Slice erzeugt und
  darum hier LOW statt MEDIUM.

### LOW-2 — `welle-13:112` nennt slice-187 als „`open/`", während der Link desselben Satzes nach `in-progress/` zeigt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 *Zustandsfelder* · Baseline-Regelwerk
  `modul-05-planning-harness.md` §Lifecycle als State Machine (*„Der Zustand ist das
  Verzeichnis"*)
- **pfad:** `docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md:111-112`
- **befund:** Die Zeile lautet
  *„`[slice-187](in-progress/slice-187-d-check-pin-v0741.md)` (wellenlos, `open/`) zieht den
  d-check-Pin …"* (Ziel als Inline-Code zitiert — der geschriebene relative Pfad löst aus `docs/plan/planning/` auf, aus `docs/reviews/` nicht). `slice-mv` hat die **Adresse** korrekt nach `in-progress/` gezogen
  (`81a2749`), das **Zustandswort** daneben nicht. Link (Zeile 111) und Zustandswort (Zeile 112) desselben Satzes sagen damit
  zwei verschiedene Verzeichnisse. `welle-13` liegt flach, ist also eine offene Welle und ein
  lebendes Artefakt, kein Zeitdokument.
- **verifizierbar:** ja.
  `sed -n '111,112p' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md` gegen
  `ls docs/plan/planning/in-progress/`. Kein Gate sieht es: `slice-mv.sh` zieht Adressen nach,
  keine Zustandswörter; `matrix`/`links` prüfen Ziele, nicht Prosa.
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen` — dieselbe wie MEDIUM-1/-2,
  hier mit dem Verzeichnis als Ableitung.

### LOW-3 — Die Tag-Zerlegung in §1 des Plans geht nicht auf: neun Minors + zwei Patches + ein toter Tag sind nicht zwölf

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 · Slice-Plan §6 *Übergabe 1* (die Zahlen wandern in den neuen `MR`-Eintrag)
- **pfad:** `docs/plan/planning/in-progress/slice-187-d-check-pin-v0741.md:86-88`
- **befund:** *„Auf den gepinnten Stand folgen **zwölf** Tags — neun Minors, dazu zwei
  Patch-Releases und der bekannte tote Tag `v0.66.0`."* Die **zwölf** stimmt und steht neben
  ihrem Kommando. Die Zerlegung daneben trägt kein Kommando und geht nicht auf: Gezählt sind
  neun Minors (`v0.66.0` … `v0.74.0`) und **drei** Patches (`v0.66.1`, `v0.71.1`, `v0.74.1`);
  `v0.66.0` ist einer der neun Minors und kein dreizehnter Posten. Die Aufzählung addiert sich
  zu zwölf nur, weil sie `v0.66.0` doppelt führt und einen Patch verschweigt. Auch die zweite mögliche
  Lesart geht nicht auf: Zählt man `v0.66.0` **nur** als toten Tag, bleiben **acht** Minors und
  **drei** Patches — dann stimmt die Neun nicht.
- **verifizierbar:** ja, selbst gefahren am Klon:
  `git -C /Development/d-check for-each-ref --sort=v:refname --format='%(refname:short)' 'refs/tags/v0.6[5-9]*' 'refs/tags/v0.7[0-9].*'`
  → `v0.65.0 v0.66.0 v0.66.1 v0.67.0 v0.68.0 v0.69.0 v0.70.0 v0.71.0 v0.71.1 v0.72.0 v0.73.0 v0.74.0 v0.74.1`.
- **klasse:** `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`
  ([Register](../plan/planning/observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md),
  **1×**, Stand `offen`).

### INFO-1 — Der `docs-check`-Hilfetext nennt vier der sechs aktiven Module

- **kategorie:** INFO
- **quelle:** [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 (Handgriff 3)
- **pfad:** [`d-check.mk:72`](../../d-check.mk), gespiegelt in [`AGENTS.md`](../../AGENTS.md) §4
- **befund:** *„Doku-Referenzen prüfen (Befund-Gate; links/anchors/ids/codepaths laut
  .d-check.yml)"* — `.d-check.yml` führt sechs Module (`matrix` und `spans` kommen dazu). Die
  Zeile ist von diesem Commit **nicht** bewegt worden (`diff` gegen `9a1a22f^` zeigt nur die
  geänderte Zeilennummer), sie ist Teil von Handgriff 3 und wurde als solche verbatim
  wiederangewandt — richtig nach `MR-010`, aber die Aussage bleibt eine Teilmenge. Kein
  Handlungsbedarf in diesem Slice; benannt, weil derselbe Halbsatz in `AGENTS.md` §4 steht.
- **verifizierbar:** ja: `grep -m1 '^modules:' .d-check.yml` gegen `grep -m1 '^docs-check:' d-check.mk`.
- **klasse:** dieselbe wie MEDIUM-1, Unterklasse *Aufzählung statt Zahl*; hier ohne
  Auslöser in diesem Commit.

### INFO-2 — Das Vier-Hunk-Kriterium aus DoD (2) hat keinen stehenden Wächter, und der `mutate`-Beleg-Übersprung verbirgt das

- **kategorie:** INFO
- **quelle:** Slice-Plan §6 Risiko 1 · [`ADR-0035`](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
- **pfad:** [`d-check.mk`](../../d-check.mk) gegen `docker run … --print-mk`
- **befund:** Der Slice-Plan nennt es selbst: *„Kein Modul dieses Repos hält das Fragment gegen
  die Tool-Ausgabe."* Der §6-Ausgang *„entfallen: DoD (2) misst die Hunk-Zahl gegen eine frische
  Ausgabe"* beschreibt eine **einmalige Handlung**, keinen Wächter — für diesen Slice trägt er
  (ich habe die vier Hunks selbst gemessen, N-2), für den nächsten Pin nicht.
  Daneben: Ein unerzwungenes `make mutate` über unverändertem Prüfgegenstand **misst nichts**
  und gibt den früheren Beleg aus. Wer die Zeile *„make mutate (250 ok, 0 Befund(e))"* aus der
  Commit-Message als eigenen Lauf liest, kann daneben liegen. Hier liegt sie nicht daneben —
  der Schlüssel deckt `d-check.mk` und `internal/emit/emit.go`
  (`ISOLATION_EXCLUDES=(./.harness/state)`, `ISOLATION_KEY_EXEMPT=(./.git)`), der Beleg ist also
  über dem geänderten Baum entstanden. Ich habe trotzdem `MUTATE_FORCE=1` gefahren (§Nachtrag),
  weil ein geerbter Beleg keine eigene Messung ist.
- **verifizierbar:** ja: `make mutate` → *„Beleg für Prüfgegenstand 07e601b8… liegt vor … Kein
  Fall-Lauf."*; `sed -n '278,289p' harness/tools/mutate.sh` für die Bezugsmenge.
- **klasse:** `zusage-ohne-stehenden-waechter` — benannt, nicht gezählt (kein eigener Vorgang).

---

## Negativbefunde — geprüft, ohne Befund

- **N-1 — Der Digest ist an allen drei Beinen richtig, und beide gekoppelten Stellen tragen ihn
  zeichengleich.** Selbst gefahren:
  `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.74.1` → `Digest: sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`;
  `docker image inspect --format '{{index .RepoDigests 0}}' …:v0.74.1` → derselbe Wert;
  `grep -rn 'e31a372b' /Development/d-check --include='*.md'` → **1** Zeile
  (`docs/user/benutzerhandbuch.md:99`, Fremdquelle). `d-check.mk:59-60` und
  `internal/emit/emit.go:33-34` tragen Tag und Digest zeichengleich. Kein stiller Grün-Pfad im
  Kopplungstest: `mkVar` bricht auf **beiden** Fehlerpfaden mit `t.Fatalf` ab (Datei unlesbar ·
  Variable nicht gefunden), und `TestDefaultDigest_MatchesCanonical` prüft zusätzlich das
  `sha256:`-Präfix — zwei leere Zeichenketten können nicht gegeneinander grün werden. Das Paket
  läuft im `gates`-Lauf grün: `#14 3.804 ok  github.com/pt9912/ai-harness-init/internal/emit 0.127s`
  aus der Dockerfile-`test`-Stufe. **Das Gegenbeispiel ist selbst rot gesehen**, nicht nur am
  Code hergeleitet: Kopie außerhalb des Repos (`git archive HEAD`), darin
  `internal/emit/emit.go` auf `9a1a22f^` zurückgesetzt, `d-check.mk` neu belassen, dann
  `make -C <kopie> test-go` → EXIT 2 mit genau den zwei Zeilen, die die Commit-Message nennt:
  `--- FAIL: TestDefaultDigest_MatchesCanonical` (*„… `sha256:5ea03abe…` != kanonische Pin-Quelle
  `sha256:e31a372b…` (Drift)"*) und `--- FAIL: TestDefaultImage_MatchesCanonical` (*„…
  `…:v0.65.0` != kanonische Quelle `…:v0.74.1` (Tag-Drift)"*). Beide Meldungen nennen die
  auseinanderlaufenden Werte, wie [`AGENTS.md`](../../AGENTS.md) §3.6 es verlangt.
- **N-2 — Das Fragment ist re-adaptiert, nicht nachgebessert, und die Neuerungen stammen Wort
  für Wort vom Werkzeug.** `diff <(docker run --rm --network none <v0.74.1-digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
  → **4**; dieselbe Zeile über `git show 9a1a22f^:d-check.mk` → **9**. Die vier Hunks sind
  exakt die vier Handgriffe aus `MR-010` Setzung 1 (`1,13c1,58` Adopter-Kopf · `15c60`
  `DCHECK_DIGEST` · `26,27c71,72` `doc-check`→`docs-check` · `75,76c120,121` `doc-help`-Grep) —
  kein fünfter. Daraus folgt, dass **alles übrige** byte-gleich vom Werkzeug stammt,
  einschließlich der sechs `--disable workflows --disable reviews`-Recipes (`grep -c` → **6**
  in Tool-Ausgabe **und** `d-check.mk`) und des `doc-usage`-Blocks (`diff` der drei Zeilen leer).
- **N-3 — Der Kopf trägt keinen Rest des alten Stands.**
  `grep -c 'v0\.65\.0\|5ea03abe' d-check.mk` → **0** (vorher **10**);
  `grep -c 'v0\.65\.0\|5ea03abe\|v0\.62\.0' d-check.mk` → **0**; `grep -n 'v0\.65\.0' Makefile`
  → leer. Beide Rot-Formen aus DoD (3) (a) sind damit erfüllt.
- **N-4 — Die vierte Ausgabe-Spalte stimmt, und sie ist auf einer Nicht-Null-Basis gemessen.**
  Eigene Kopie außerhalb des Repos (`git archive HEAD`), alle Marker in getracktem Markdown
  außerhalb der vendored Baseline entwertet (**174** Dateien / **334** Zeilen vorher,
  Restzähler **0**), dann beide Digests: **beide** `d-check: 825 Datei(en) geprüft, 85 Befund(e)`,
  Exit 1. `awk -F'\t' '{print NF}'` über den Befundzeilen → **3** unter `v0.65.0`, **4** unter
  `v0.74.1`. `diff` der beiden Mengen über Datei/Zeile/Ziel/Grund-Code ist **leer**; die
  Verteilung ist beidseitig `15 codepath-missing`, `38 id-unlinked`, `32 target-missing`. Die
  vierte Spalte trägt genau die drei Klartexte, die der Kopf zusagt — `target-missing` →
  *„Linkziel existiert nicht"*. Die Zahlen `825/85` und `15/38/32` der Commit-Message sind
  damit unabhängig reproduziert.
- **N-5 — Die Marker-Tabelle im Kopf ist gemessen, nicht abgeschrieben.** Eigene Sonde
  außerhalb des Repos (`modules: [codepaths]`, ein toter Inline-Code-Pfad je Lage). Unter
  `v0.74.1`: Lage A `<!-- d-check:ignore -->` **unterdrückt**, Lage B blanke Prosa **meldet**,
  Lage C Kommentar in Inline-Code **meldet**, Lage D ohne Marker **meldet** — `3 Befund(e)`,
  Exit 1, genau die vier Zeilen des Kopfes. Zweite Sonde über `modules: [ids]` mit unverlinkter
  Kennung: dasselbe Bild, und damit trägt auch der unveränderte Falsifizierbarkeits-Satz
  (`d-check.mk:34-36`) unter dem neuen Pin. Unter `v0.65.0` sind beide Sonden identisch — die
  Semantik hat sich über die Spanne **nicht** bewegt, wie die Commit-Message sagt. Damit ist
  die Klasse aus [`2026-08-28-slice-122-review.md`](2026-08-28-slice-122-review.md) HIGH-1
  (*Tabelle am Bestand widerlegt*) hier **nicht** eingetreten.
- **N-6 — Die „fünf von sechs"-Aussage des Kopfes stimmt diesmal.**
  `grep -c -- '--disable citations' d-check.mk` → **6**;
  `grep -c -- '--disable citations --disable sources --disable structure --disable workflows --disable reviews' d-check.mk`
  → **5**; das sechste Recipe ist `doc-structure` und `--enable`t sein eigenes Modul (**1**).
  Die Klasse aus [`2026-08-22-slice-088-review.md`](2026-08-22-slice-088-review.md) HIGH-1
  (*Kopf sagt über sechs, was für fünf gilt*) ist hier **nicht** eingetreten.
- **N-7 — Die Strenge-Bilanz trägt, und §3.5 verlangt keinen ADR.** Selbst am Klon gefahren:
  `git diff --numstat v0.65.0..v0.74.1 -- internal/hexagon/core/rules/{links,anchors,ids,matrix,codepaths,spans}.go`
  → **leer**. Gegen das falsche Negativ geprüft: `git ls-tree --name-only <tag> internal/hexagon/core/rules/`
  führt unter **beiden** Tags alle sechs Dateien unter denselben Pfaden — keine Umbenennung.
  Die Verhaltens-Gegenprobe (N-4) liefert identische Befundmengen auf einer Basis, auf der ein
  Wegfall sichtbar geworden wäre. Keine Senkung, kein ADR fällig. Der eine Breaking Change der
  Spanne (`[0.66.1]`, `structure`-Tabellenschlüssel unter `table.*`) und der eine entfallene
  Grund-Code (`[0.67.0]`, `uses-local-perms-unreadable` in `workflows`) liegen in nicht
  aktivierten Modulen — am CHANGELOG des Klons nachgelesen und über `grep -c 'structure' .d-check.yml`
  → **0** gegengeprüft.
- **N-8 — `.d-check.yml` ist unverändert, keine der vier neuen Fähigkeiten ist aktiviert.**
  `git show --pretty=format: --name-only 9a1a22f` führt sie nicht;
  `grep -n '^modules:' .d-check.yml` → `modules: [links, anchors, ids, matrix, codepaths, spans]`,
  Zeile 29, unverändert seit `729b967` (slice-177). Weder `workflows` noch `reviews`,
  `planning` noch `planning.observations.dir` erscheinen darin. Die Modul-Zahl der Ausgabe
  wächst dabei real: `grep -oE '\-\-disable [a-z]+' … | sort -u | wc -l` → **20** über den
  alten Stand, **22** über die frische Ausgabe, neu sind genau `reviews` und `workflows`. Die
  Versions-Zuordnung des Kopfes (`workflows` 21./`v0.67.0`, `reviews` 22./`v0.73.0`) ist am
  CHANGELOG des Klons gegengeprüft (*„Neues Modul `workflows`"* in `[0.67.0]`, *„Neues Modul
  `reviews`"* in `[0.73.0]`).
- **N-9 — Kein Architect-Artefakt ist im Implementations-Commit bewegt (§3.8).**
  `git show --pretty=format: --name-only 9a1a22f` → genau `Makefile`, `d-check.mk`,
  `internal/emit/emit.go`. Weder [`harness/conventions.md`](../../harness/conventions.md) noch
  `harness/conventions/*.md` noch [`AGENTS.md`](../../AGENTS.md) noch `docs/plan/adr/` sind
  berührt. Der Slice-Plan stellt die vier Posten als Übergabe und schreibt keinen Regeltext —
  das ist die richtige Rollen-Disziplin, und die zwei MEDIUM oben sind ihre **Folge**, nicht
  ihr Widerspruch.
- **N-10 — Die `AdaptMK`-Anker halten über der frischen Ausgabe, die Fixture bleibt zu Recht
  liegen.** Über `--print-mk` von `v0.74.1` je **1**: `DCHECK_IMAGE ?=`, `^\.PHONY: doc-check$`,
  `^doc-check:`, `^DCHECK_DIGEST \?=$` und literal `'^doc-[a-z-]+:`. `AdaptMK` bricht auf drei
  der vier Handgriffe hart ab (`errors.New`), es gibt also keinen halb-adaptierten Emissions-Pfad.
  Die Fixture `internal/emit/testdata/raw-print-mk.txt` (**64** Zeilen) trägt dieselben vier
  Anker je einmal; ihre Zeilenzahl ist nach `MR-010` §Auflösungs-Trigger kein Kriterium.
- **N-11 — Die emittierte Seite bricht nicht.** Die emittierte Starter-Config
  (`internal/emit/templates/d-check.yml`, `modules: [links, anchors]`) ist unverändert und läuft
  unter `v0.74.1` sauber durch (eigene Probe, `2 Datei(en) geprüft, 0 Befund(e)`, Exit 0) — der
  Breaking Change der Spanne trifft sie nicht. `adopterHeader` in `emit.go` nennt keine Version
  und driftet darum nicht mit.
- **N-12 — Die Vier-Spalten-Zusage stimmt für den heutigen Bestand.** Kein Skript zerlegt eine
  d-check-Befundzeile spaltenweise: `git grep -nE "awk +-F'?\\\\t|cut +-f|\\\$NF" -- 'harness/tools/*' 'test/*' '.claude/hooks/*' 'Makefile' 'd-check.mk'`
  trifft nur `comment-claims.sh` und `mutate.sh` über **deren eigenem** Zeilenformat. Der eine
  Leser einer d-check-Befundzeile, `harness/tools/full-smoke.sh:286`, greift mit
  `grep -qE "$FELDLISTE_REL:[0-9]+.*target-missing"` über die **ganze** Zeile und bleibt von
  der vierten Spalte unberührt — an einer echten Befundzeile beider Digests gemessen, nicht
  geschlossen: dasselbe Muster matcht die 3-Spalten- wie die 4-Spalten-Form, während
  `awk -F'\t' '{print $NF}'` über derselben Zeile ab `v0.74.1` „Linkziel existiert nicht"
  statt `target-missing` liefert. `smoke.sh:128` prüft die Summenzeile auf `geprüft`.
- **N-13 — Hard Rules einzeln.** §3.1 kein neuer Gate behauptet (`docs-check` bleibt der
  einzige, `AGENTS.md` §4 und `harness/README.md` nennen keinen `doc-*`-Target —
  `grep -rn 'doc-help\|doc-structure\|doc-trace\|doc-usage\|doc-targets' harness/README.md docs/user/*.md`
  → leer) · §3.2 keine Suppression im Diff · §3.3 die zwei Lifecycle-Moves sind rein (`git show --stat --find-renames a5d190e bd51497` → je
  `1 file changed, 0 insertions(+), 0 deletions(-)`), keine Inhaltsänderung im selben
  Commit · §3.4 keine ADR berührt · §3.5 keine Senkung (N-7) · §3.6 die drei DoD-Punkte tragen
  je ein Rot-Kommando; das von DoD (1) ist selbst rot gesehen und hat keinen stillen Grün-Pfad
  (N-1), das von DoD (2) und (3) selbst nachgemessen (N-2, N-5) · §3.7
  siehe MEDIUM-3 · §3.8 siehe N-9 · §3.9 alle Läufe dieses Reports über `make`, `docker`, `git`.
- **N-14 — `make gates` selbst gefahren: EXIT 0**, darin `d-check: 821 Datei(en) geprüft,
  0 Befund(e)`, `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün, 218
  bats-Fälle `ok`. `make freshness-dcheck` → *„aktuell — gepinnt und latest sind beide v0.74.1"*,
  EXIT 0.
- **N-15 — Der Zeiger von `slice-135` steht.** `grep -n 'slice-187' docs/plan/planning/open/slice-135-d-check-pin-v0661.md`
  → drei Zeilen, alle mit korrektem `../in-progress/`-Pfad. Die Datei ist nicht gelöscht, wie
  §1 des Plans es begründet.
- **N-16 — Nicht geprüft (fremde Rolle oder außerhalb der Reichweite dieses Laufs):** die
  DoD-Abhakung und der Plan-vs-Code-Konformitätsbericht (Modul 11) · das Rot der DoD-(3)-Sonde
  in ihrer *dokumentierten* Fassung (ich habe eine **eigene** Sonde gebaut und gefahren, N-5 —
  ob der Implementer dieselbe fuhr, sagt nur seine Message) · `make smoke`/`make full-smoke`
  (nicht in `make gates`, brauchen Netz; die emittierte Seite ist stattdessen über N-10, N-11
  und N-12 geprüft) · der Sicherheits-Grund des Releases (`[0.74.1]` CHANGELOG, Fremdquelle,
  hier nicht nachgemessen — der Plan weist ihn selbst so aus) · die vier ab diesem Pin
  verfügbaren Fähigkeiten inhaltlich (sie sind nicht aktiviert, N-8; ihre Bewertung gehört in
  den Aktivierungs-Schnitt).

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | **0** | — |
| MEDIUM | **3** | `zusage-neben-geaenderter-ableitung-bleibt-stehen` (2×) · `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` |
| LOW | **3** | `kopplungstest-ohne-mutations-fall` · `zusage-neben-geaenderter-ableitung-bleibt-stehen` · `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` |
| INFO | **2** | Aufzählung statt Zahl · `zusage-ohne-stehenden-waechter` |

**Für die Closure (§7):** Die wiederkehrende Klasse dieses Laufs ist
`zusage-neben-geaenderter-ableitung-bleibt-stehen` — dreimal getroffen (MEDIUM-1, MEDIUM-2,
LOW-2), aber **ein** Vorgang und damit **eine** Gelegenheit (Baseline-Regelwerk
`modul-06-roadmap.md` §Das Beobachtungs-Register). Der Eintrag steht bei **13×** mit Stand
`geplant`/`slice-153`, und alle drei Instanzen liegen in der Unterklasse, die sein `state.md`
als **offen** ausweist (Prosa-Zahl, Präsens-Satz, Zustandswort). Zwei Klassen sind im Register
heute nicht geführt: `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` (MEDIUM-3)
und `kopplungstest-ohne-mutations-fall` (LOW-1, zweite Nennung nach slice-122 MEDIUM-4).

---

## Verdikt

**Blockierend — 3 MEDIUM offen. Kein HIGH.**

**Das Sachurteil des Slice trägt, und es trägt besser als bei beiden Vorgänger-Sprüngen.** Die
drei Dinge, an denen die zwei Vorgänger-Sprünge Befunde bekamen — zwei HIGH (slice-088 HIGH-1,
slice-122 HIGH-1) und ein MEDIUM (slice-088 MEDIUM-3 / slice-122 MEDIUM-1) —, sind hier richtig: Die
Marker-Tabelle ist an einer eigenen Sonde gemessen und stimmt an allen vier Lagen (N-5), die
„fünf von sechs"-Aussage über die Recipes stimmt (N-6), und die Strenge-Bilanz steht auf beiden
Beinen — leere Quell-Differenz **mit** Prüfung gegen das falsche Negativ **und** eine
Verhaltens-Gegenprobe auf einer Nicht-Null-Basis, die eine echte Verhaltensänderung gefunden
hat (N-4, N-7). Die Fragment-Re-Adaption ist keine Behauptung: vier Hunks gegen neun, und aus
der Vier folgt, dass das neue Target und die sechs Recipe-Zeilen **byte-gleich** vom Werkzeug
stammen (N-2). Der Digest ist an drei unabhängigen Beinen richtig und in beiden gekoppelten
Stellen zeichengleich (N-1). Der Kopf trägt keinen Rest des alten Stands (N-3).

Blockierend sind die drei MEDIUM aus zwei verschiedenen Gründen:

- **MEDIUM-1 und MEDIUM-2** sind keine Implementations-Fehler — der Implementer hat §3.8 exakt
  eingehalten (N-9). Sie sind der **Zustand an HEAD**: Zwei lebende Norm-Artefakte behaupten im
  Indikativ etwas über den Pin, das seit `9a1a22f` falsch ist, und einer davon (`MR-034`) steht
  in keinem der vier Übergabe-Posten. Kein Gate dieses Repos sieht das — `MR-027` hält diese
  Lücke selbst fest. Der Slice-Plan hat den einen Fall gesehen und seinen Auffang an die
  Annahme geknüpft, der Architect-Lauf liege **vor** dem Umsetzungs-Lauf; die Annahme ist
  nicht eingetreten. Damit steht sein letztes §6-Risiko auf *eingetreten*, nicht auf
  *entfallen* — der Plan nennt für diesen Fall selbst den Weg (*„Folge-Slice nach dem Muster von
  slice-128"*). Die Closure hat damit **zwei** zulässige Wege und nicht null: Architect-Lauf vor
  der Closure, oder Ausgang *eingetreten* mit einer Folge-Slice-Kennung, die beide Einträge
  einsammelt. Was sie **nicht** darf, ist der Ausgang *entfallen* (DoD: *„Jedes Risiko aus §6 trägt einen
  Ausgang"*) — er wäre am Bestand widerlegt. `MR-034` braucht in jedem Fall einen fünften
  Übergabe-Posten, denn er steht heute in keinem.
- **MEDIUM-3** trifft den Gate-Pfad selbst. Er ist bewusst **nicht** als HIGH geführt, und die
  Begründung steht im Finding: Die tragende Zusage ist vollständig und nachgemessen richtig,
  der Verstoß sitzt in zwei adverbialen Einschüben. Wer die Einstufung anders sieht, hat nach
  dem Reviewer-Skill den Weg *Regel schärfen*, nicht den Konflikt-Pfad.

**Kein HIGH:** kein stilles Grün in einem Gate (N-1, N-10), kein halluziniertes Gate (N-13),
keine Hard Rule verletzt außer der in MEDIUM-3 benannten Teil-Verletzung, keine aktive ADR
verletzt, keine superseded ADR referenziert, keine Gate-Lockerung ohne ADR (N-7), keine Norm nur
im Template-Kommentar, kein Zustandsfeld mit Chronik. `make gates` ist selbst gefahren und grün
(EXIT 0, `d-check` 821/0).

**Konflikt-Pfad:** MEDIUM-1 und MEDIUM-2 berühren einen Rollen-Zuschnitt (Architect-Eigentum).
Sie sind **kein** Widerspruch zur Implementation und brauchen deshalb keine Konflikt-Sequenz —
sie brauchen einen Architect-Lauf. Wird ihnen dennoch widersprochen, gilt
[`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md)
§Konflikt-Pfad als Rollen-Sequenz: drei legitime Verdikte mit Übergabe-Artefakt, nicht die
Herabstufung, weil der schreibende Lauf anderer Meinung ist.

---

## Nachtrag — `MUTATE_FORCE=1 make mutate`

Der **unerzwungene** Lauf misst nichts: Er fand den Beleg für Prüfgegenstand `07e601b8…` vor
(`.harness/state/mutate-passed.key`, 2026-09-05 19:10:45) und übersprang den Fall-Satz. Der
Schlüssel deckt `d-check.mk` und `internal/emit/emit.go`, der Beleg des Implementers ist also
über dem geänderten Baum entstanden — aber ein geerbter Beleg ist keine eigene Messung. Der
erzwungene Lauf über **250** Fälle auf vier Workern ist während der Erstellung dieses Reports
gefahren; sein Ergebnis steht unten und ist der letzte Eintrag dieses Reports.

**Ergebnis: `mutate: 250 ok, 0 Befund(e)`, EXIT 0.** Untere Schranke jeder Parallelisierung
= längster Einzelfall **84,03 s** (`199-mutate-zeitschranke-greift-nie`), Fall-Arbeit gesamt
**4826,1 s**. Kein gelisteter Wächter hat seine Zähne verloren; die Zahl der Commit-Message ist
damit unabhängig reproduziert. Was der Lauf **nicht** deckt, sagt er selbst: die zwei
Kopplungstests aus DoD (1) sind nicht gelistet (LOW-1).

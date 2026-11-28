# ADR-0113: Der E2E-Stempel wird je Variante gestempelt — sieben full-smoke-Schlüssel über Vorlagen-Mengen, CI skippt je gedeckter Variante

**Status:** Accepted

**Datum:** 2026-11-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Revidiert (Teil-Supersede):** die Festlegung 4 von
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
(*„der E2E-Stempel ist eine committete Datei `.harness/state/full-smoke-passed.key` … zwei Zeilen:
`baum-hash` … und `varianten <n>`*"). Die übrigen Festlegungen von
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) bleiben **Accepted** und
unberührt: die committed-Key-Klasse samt gitignore-Form und Hash-Ausnahmen (Festlegung 1 — hier je
dieser ADR **erweitert** am selben Ort, Festlegung 5, kein Widerruf), das Vertrauens-Modell
(Festlegung 2, Skip nur auf `main`), die zwei gitignored Gesamt-Dateien (Festlegung 3),
die Schreiber-Kette mit `make` der nicht committiert (Festlegung 5). Der Grund der Revision ist
die Bindungsbreite derselben Eigenschaft, die [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 4 in der Abwägung D schon nannte — dort zur Verwerfung zugunsten der kleinen Form; der
Auftraggeber hat sie reingeholt. §3.5 bindet auch diese Revision: der je-Variante-Skip fährt
**weniger**, und jede Grenz-Senkung ist diese ADR, kein PR-Kommentar.

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (dieselbe Form am Host und
auf CI — Frisch-Rechnung gegen Transport über denselben Satzerzeuger, kein zweiter Maßstab),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein SKIP
behauptet nur, was der Schlüssel deckt — mit der Varianten-Menge deckt er genau die
Vorlagen-Mengen, über die der Stempel-Lauf fuhr),
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) (die Transport-Form, die hier
feingranularisiert wird),
[ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) (die Tafel-Mengen-Form des
Satzerzeugers — hier je Variante statt je Check),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4 (der
benannte Rest — je Schlüssel unverändert),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(fail-closed je Zweifel),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der Mutations-Fälle)

**Schärft:** — Prozess-ADR ohne Spec-Stratum; dieselbe Lesart wie
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md), dieselbe Ordnungskante
[`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
unberührt.

---

## Kontext

Die Festlegung 4 von [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) bindet den
E2E-Stempel an den Gesamt-Baum-Hash. Der Auftraggeber-Befund: die E2E fährt sieben Varianten
(sprachlos, je `--lang go/cpp/kotlin/java/python/csharp` — dieselbe Menge wie die
Handbuch-Baum-Schleife in `full-smoke.sh`), und ein Edit in **einer** Sprache (etwa
`internal/gen/kotlin.go`) rotiert den einen Schlüssel und entwertet die ganze E2E — 45–60 Minuten je
Drift, obwohl nur eine Variante driften kann. Die `varianten <n>`-Zeile trägt überdies die
Zähl-Basis als offene Lesart (wer zählt, welche Abschnitte?). Die feingranulare Form ist die
spiegelbildliche der je-Check-Keys: je Variante ihr Prüfgegenstand, je Drift nur der gedriftete
Anteil.

## Entscheidung

Wir wählen: **Sieben committete Stempel-Dateien, je Variante eine, je gebunden an den Hash der
Vorlagen-Menge dieser Variante; der CI-Griff konsultiert je Variante; die Drift-Fahrt ist je
Variante einzeln anforderbar.** Sechs Festlegungen:

**1. Je-Variante-Stempel-Dateien — die Klasse ersetzt die eine Datei.**
Die Stempel-Klasse ist `.harness/state/full-smoke-passed-<variante>.key`, `<variante>` ∈
`sprachlos go cpp kotlin java python csharp` (sieben Dateien, dieselbe Menge wie die
Varianten-Schleife des Treibers), je zwei Zeilen: `variante <name>` (Form- und Selbst-Bindung —
der Name der Datei wird gegen diese Zeile gelesen; ein fremdes Feld, eine falsche Zeile, ein
Datei-Name ohne Zeile ist unformal) und `mengen-hash <64-hex>`. Der Feld-Name ist nicht mehr
`baum-hash`: der Wert ist kein Baum-Hash, sondern der Hash der Vorlagen-Menge der Variante — ein
Feld-Name, der den Umfang fälschte, ließe den SKIP mehr behaupten, als der Schlüssel deckt
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Keine
Commit-SHA-Stelle (zirkulär, Festlegung 3 von ADR-0111), kein Datumsfeld (die Chronik trägt
`git`). Die `varianten <n>`-Zeile entfällt mit der einen Datei — die Varianten-Menge steht als
Tafel des Satzerzeugers und als Verzeichnis der Stempel-Dateien. Der Satzerzeuger
`full-smoke-varianten.sh` (neu; Ablage wie der Satzerzeuger [`gates-keys.sh`](../../../harness/tools/gates-keys.sh)) trägt
sie (Form [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)/`gates-keys.sh`): `menge
<variante>` (Dateien zeilenweise), `hash <variante>` (64 hex), `alle` (je Variante der Hash), je
Form der Hermetik-Form (`--wurzel` für Fixtures). **Übergangs-Fakt:** die eine Datei von ADR-0111
Festlegung 4 ist bis zum Implementations-Zug nicht committet (der Schreiber steht im Treiber, der
committende Zug fehlt); der Zug committet direkt die sieben — die eine Datei wird nie ein
Bestand und wird entfallen, statt migriert zu werden.

**2. Die Mengen-Zuordnung — je Variante der Wirkungs-Schnitt am Emit-Ergebnis.**
Eine Tafel im Satzerzeuger, je Variante aus zwei Teilen. **Gemeinsame Menge (alle sieben):** die
Traeger-Quelle (`cmd/**` und `internal/**`, ohne `*_test.go` und ohne `testdata/**`, abzüglich der
je-Sprachigen Profil-Dateien der Tafel unten), die eingebetteten Emit-Vorlagen (Teil der
`internal/emit/**`-Fassung — sie reisen als Build-Quelle im Binary), die vendored Baseline
(`.harness/baseline/**`, die jedem Ziel-Bootstrap nachfährt) und die Treiber
[`harness/tools/full-smoke.sh`](../../../harness/tools/full-smoke.sh),
[`full-smoke-skip.sh`](../../../harness/tools/full-smoke-skip.sh),
[`handbuch-baum.sh`](../../../harness/tools/handbuch-baum.sh) — sie tragen die Messung selbst, ein
Treiber-Edit kann jedes Varianten-Verdikt drehen, und sie aus den Mengen zu nehmen wäre eine
Senkung nach §3.5. **Je-Sprache-Teil:** `go` → `internal/gen/golang.go` · `cpp` →
`internal/gen/cpp.go` · `kotlin` → `internal/gen/kotlin.go` + `internal/gen/jvm.go` · `java` →
`internal/gen/java.go` + `internal/gen/java_hexslice.go` + `internal/gen/jvm.go` · `python` →
`internal/gen/python.go` + `internal/gen/python_hexslice.go` · `csharp` →
`internal/gen/csharp.go` + `internal/gen/csharp_hexslice.go` · `sprachlos` →
`internal/gen/golang.go` (die Sprachlose bootstrapt kein Skelett, fährt aber den add-lang-Zug —
slice-037, [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); ihr Verdikt hängt
am Go-Profil). Nicht größer: Dateien, die das Varianten-Verdikt nicht tragen kann, treiben keinen
Schlüssel (Tests, Doku, Planning, Mutations-Anlagen — sie fielen am Ein-Schlüssel mit und treten
hier aus). Nicht kleiner: jede nicht-Test-Quelle von `internal/gen/` liegt in mindestens einer
Tafel-Zeile, und der Wächter hält genau das — **eine nicht zugeordnete neue Gen-Datei färbt rot**
(fail-closed, [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)),
denn eine Menge, die eine Quelle still vergisst, verleugnet den Schlüssel ihren Prüfgegenstand.
Die gemeinsame Menge ist damit bewusst **schmaler als der Baum-Hash, größer als die Vorlagen allein**:
das Binary ist eines, und sein Verhalten trägt jedes Varianten-Verdikt — die Sprach-Trennung
greift genau am Profil-Schnitt ([ADR-0005](0005-ziel-repo-distribution.md)-Fassung: Layout-Wissen
ist tool-eigen je Profil, `gen.go`/`arch.go` sind der gemeinsame Renderer, `jvm.go` der
Gemeinsam-Knoten der zwei JVM-Sprache).

**3. Der Skip-Konsum je Variante.** Der CI-Griff (Umgebung
`FULL_SMOKE_SKIP_KONSULT=1`, gesetzt nur vom push-`main`-Job — Festlegung 2 von ADR-0111
unverändert) konsultiert die sieben Dateien je gegen die Frisch-Rechnung des Satzerzeugers: SKIP
nur, wenn **alle sieben** decken. Je Variante fehlend, unformal, fremd oder Satzerzeuger-Zweifel →
voller Lauf, fail-closed. Die SKIP-Meldung nennt je den benannten Rest ihrer Festlegung 4 —
Traeger-Release-Verfügbarkeit, Registry-/Netz-Zustände, Runner-Fassung — und diese Liste bleibt je
Schlüssel dieselbe; ein Netz-Zug kann in keinem Baum-abgeleiteten Schlüssel liegen
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4). Der
Vertrauens-Modell-Rest steht unverändert: Skip nur auf `main`, PR-Jobs fahren voll, die
Schreiber-Kette trägt die Integrität der Kette.

**4. Die serialisierte Stufe trennt sich nicht — der Drift-Anteil wird je Variante fahrbar.**
Bis die Einzel-Varianten-Fahrt existiert, bleibt `full-smoke.sh` die serialisierte Form über allen
sieben Varianten; am grünen Ende schreibt sie **alle sieben** Keys (je Frisch-Rechnung am
Ende — der Lauf ändert den Baum nicht: die tmp-Repos liegen außerhalb, die Stempel-Klasse ist
Hash-Ausnahme, der Schreibzug rotiert damit keinen getragenen Vergleichswert). Die Einzelfahrt
(`VARIANTE=<name> bash full-smoke.sh`) ist Pflicht des Implementations-Zugs: der Lauf fährt genau
die Stufen der einen Variante und stempelt genau ihren Key; jede Stufe des Treibers trägt ihre
Varianten-Zuordnung in der Tafel des Treibers, und **eine Stufe ohne Zuordnung färbt den Wächter
rot** — der cut ist vollständig oder er ist kein Schnitt. Erst mit dieser Einzelfahrt wird der
CI-Skip je gedeckter Variante zur Kosteneinsparung; bis dahin fährt jeder Drift den vollen
serialisierten Lauf — die fail-closed-Richtung, bezahlt in Minuten, nicht in Behauptungen.

**5. Der gitignore-/Hash-Ausnahme-Nachzug,** je Form der
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegungen 1/4: die
[`.gitignore`](../../../.gitignore)-Ausnahme wird zur Glob-Klasse
`!.harness/state/full-smoke-passed-*.key` (die exakte Zeile der einen Datei entfällt mit ihr), die
`HASH_AUSNAHMEN` von [`working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh)
bekommt denselben Glob anstelle des exakten Eintrags. Der Grund steht am Eintrag
(ADR-0103-Fassung): *ein Stempel-Commit rotiert keinen Baum-Hash und keinen Key* — derselbe Grund,
der je-Check-Keys und Ein-Schlüssel galt, je-Klasse weitergetragen. Die fail-closed-Klausel
(nicht deklarierter committeter Inhalt unter `.harness/state/` → rot) bleibt unberührt; der Glob
deckt genau die Stempel-Klasse, und der Streit um ein falsches Namensmuster ist an derselben
Klausel sichtbar.

**6. Implementations-Slice-Skizze, Kennung `slice-full-smoke-jevariante-stempel-v1`.**
Drei Liefer-Punkte, je zwei Schichten (Harness-Mechanik + Stempel-Form): (a) der Satzerzeuger
`full-smoke-varianten.sh` (neu im Implementations-Zug) mit der Tafel nach
Festlegung 2, der Mengen-Vollständigkeits-Wächter (Gen-Quellen je zugeordnet; Treiber-Stufen je
zugeordnet — Festlegung 4) und die Ausnahmen-Migration (gitignore, `HASH_AUSNAHMEN`, ADR-Index-Nachzug);
(b) der Schreiber-Zug am Treiber: sieben Keys am grünen Ende der serialisierten Form, die
`varianten`-Zeile entfällt, die Einzelfahrt `VARIANTE=<name>` samt Stufen-Tafel; (c) der CI-Griff
erweitert (je-Variante-Konsultation, SKIP-Nachricht mit Varianten-Menge und Rest) samt
hermetischem Wächter `test/full-smoke-varianten-keys.bats` und Mutations-Fällen je
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit):
(a-1) der Konsum liest ein fremdes Feld oder einen falschen Varianten-Namen → rot; (a-2) die
gitignore-/Hash-Ausnahme fällt still weg → rot; (b-1) der Schreiber schreibt den
Baum-Hash statt der Mengen-Rechnung → rot am Wächter, der die Menge gegen die Satzerzeuger-Rechnung
hält. Die README-Zellen [`make full-smoke`](../../../harness/sensors/full-smoke.md) und der
Full-E2E-Skip nennen den je-Variante-Konsum (Form der Folgepflicht von ADR-0111 Festlegung 6).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Ein-Schlüssel, [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) F4 weiter) | eine Datei, eine Frisch-Rechnung, kleinste Oberfläche | jeder Sprach-Edit rotiert die ganze E2E (45–60 min je Drift, eine Sprache trifft alle sieben); die `varianten`-Zeile trägt die Zähl-Basis als offene Lesart |
| B — nur die Zähl-Basis der `varianten`-Zeile festlegen | kleinster Aufwand | kein Drift-Nutzen, der Ein-Schlüssel bleibt; die Lesart ist geheilt, die bindende Eigenschaft nicht |
| C — ein Schlüssel je `--lang` × `--arch`-Kombination | schärfer als die sieben | die E2E fährt keine separaten `--arch`-Züge — ein Schlüssel über einer ungefahren Menge behauptet ein Verdikt, das kein Lauf trug ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| D — die Sprach-Profile in je-einer Menge allein (ohne gemeinsame Binary-Quelle) | schmaler, größeres Skip-Fenster | das Binary ist eines — ein Edit am gemeinsamen Kern verließe die Keys gedeckt, ohne dass ein Lauf fuhr; die schmale Menge verleugnet den Prüfgegenstand |

**Gewählt (E):** sieben Keys über zwei-Teil-Mengen (Festlegung 2), Konsum je Variante
(Festlegung 3), Einzelfahrt als Zug (Festlegung 4).

## Konsequenzen

- Positiv: ein Sprach-Profil-Edit driftet genau die Sprach-Keys; die übrigen Varianten bleiben
  gedeckt und behaupten genau das, was der Stempel-Lauf über ihren Mengen fuhr. Die Zähl-Lesart
  entfällt; der SKIP-Namensbereich ist die exakte Datei-Menge der Messung.
- Negativ: der gemeinsame Teil ist groß (Binary-Quelle, Emit, Baseline, Treiber) — ein
  Treiber-Edit driftet alle sieben, richtig (er berührt jede Messung), aber er zahlt wieder den
  vollen serialisierten Lauf, solange die Einzelfahrt fehlt. Die Kosteneinsparung der Kante tritt
  erst mit Festlegung 4 ein; die engere Bindung tritt sie schon.
- Negativ: sieben Stempel-Dateien statt einer — Verwaltungslast am committenden Zug; der
  Satzerzeuger trägt sie, der Bestand wird nicht groß.
- **Kein Eintrag im Adaptions-Block**, dieselbe Lesart wie
  [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) (der Transport-Konsum hat in
  der adoptierten Baseline kein Gegenstück — [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).
- Folgepflicht (Implementations-Zug): die README-Zellen von `make full-smoke` und der Full-E2E-Skip
  nennen den je-Variante-Konsum; die SKIP-Meldung nennt Rest je Variante.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, `test/full-smoke-varianten-keys.bats` (neu, hermetisch über `--wurzel`-Fixture) | **Happy:** `hash <variante>` liefert 64 hex, deterministisch über zwei Läufe; ein Inhalt-Edit **innerhalb** der Menge dreht den Key, einer außerhalb dreht ihn nicht; alle sieben gedeckt → SKIP-Meldung mit Varianten-Menge und benanntem Rest. **Negative:** Stempel fehlt · unformal (`variante`-Zeile passt nicht zum Datei-Namen) · fremder `mengen-hash` → voller Lauf. **Boundary:** eine nicht zugeordnete nicht-Test-Quelle unter `internal/gen/` färbt den Mengen-Wächter rot; eine Treiber-Stufe ohne Varianten-Zuordnung dito | `make test` (in `make gates`) |
| Mutations-Fälle, `test/mutations/` (drei, Festlegung 6) | je [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit): falsches Feld im Konsum · still weggefallene Ausnahme · Baum-Hash statt Mengen-Rechnung im Schreiber | `make mutate` (`MUTATE_CASES`) |

**Was hier nicht behauptet wird:** der Rot-Beleg entsteht im Implementations-Zug, nicht in dieser
ADR ([`AGENTS.md`](../../../AGENTS.md) §3.6-Form); die CI-Verdrahtung je-Variante belegt der
reale CI-Lauf, nicht ein lokaler Wächter. **Was kein Wächter hält:** die Integrität der
Schreiber-Kette am `main`-Push (unverändert der Rest der
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 5) und die
Kosteneinsparung der Kante vor der Einzelfahrt — Träger ist der Zug der Festlegung 4.

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **Die Einzelfahrt trennt nicht sauber** — Stufen des Treibers sind über Varianten hinweg
   nicht zuzuordnen (Interleaving) — dann ist der Schnitt neu zu wägen, bevor CI weiter je
   Drift urteilt; im Extremfall per Folge-ADR mit `Supersedes ADR-0113` (die serialisierte Form
   mit je-Variante-Keys trägt dann eine enge Bindung ohne Kosteneffekt — ein Befund, kein stiller
   Zustand).
2. **Eine neue E2E-Variante tritt ein** (weitere Sprache, Arch-Zug als eigene Fahrt) — dann
   braucht die Tafel vor dem ersten Stempel eine Menge: über einer ungefahren Menge wird kein
   Key gestempelt ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
3. **Der gemeinsame Teil dominiert die Drift-Menge** (Treiber-Edits zählen die
   Varianten-Edits nieder) — dann ist der Mengen-Schnitt neu zu schneiden; er misst den
   tatsächlichen Drift-Anteil, nicht die Vorlagen-Struktur.
4. **Ein emittiertes Ziel oder ein Adopter-Target bekommt die je-Variante-Stempel-Form** —
   einzeln entschieden, eigene Deckungs-Messung (Form der
   [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Trigger 4).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-28 | **Accepted** | Architektur-Übergabe-Artefakt auf die Auftraggeber-Entscheidung (*„die Je-Variante-Fassung des full-smoke-Stempels — kein Ein-Schlüssel-Aggregat“*); Annahme am 2026-11-28 |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0113` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

# Slice slice-058: `--arch hexagonal` für Go — das Layout, das die Familie wirklich baut

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle. Nach [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Frage 1/2 ist es **kein Bündel**: dieser Slice ist für Go allein lieferbar, und die zweite Sprache
(cpp) hat kein gemeinsames Closure-Kriterium mit ihm — sie erbt nur die Achse. Frage 3 ist der
Grenzfall: der Auslöser ist ein **gemeldeter Bedarf**, nicht eine gewollte Fähigkeits-Erweiterung
auf Vorrat. Wird beim cpp-Schnitt sichtbar, dass beide zusammen landen müssen, ist das ein
Wellen-Signal — dann wird nachgeschnitten, nicht rückwirkend umgedeutet.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (die Achse
trägt seit CR **0.17.0** drei Architekturen),
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (das Arch-Gate
folgt dem Layout), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate ohne rot gesehenes Gegenbeispiel),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (`flat` und `hexslice`
bleiben unberührt), [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) (die
HexSlice-Realisierung, von der dieses Layout **abgegrenzt** wird),
[`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) (**Accepted**, vier
Proposed-Runden — Schichten, Rollen, Kanten und Verdrahtungsort dieses Layouts sind dort
festgelegt; dieser Slice setzt sie um und erfindet sie nicht neu).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

`add-lang go <pfad> --arch hexagonal` legt ein Go-Modul mit den **vier geprüften Schichten** an —
`core` / `ports` / `driven` / `driving`, verdrahtet in `cmd/**` —, und das Arch-Gate prüft sie.
Maßstab ist die **gelebte Konvention der Werkzeug-Familie**, nicht das Lehrbuch und nicht das
`--print-config`-Gerüst; [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) hält
fest, wo wir ihr folgen (die Pfade) und wo nicht (die Verdrahtungsstelle).

## 2. Definition of Done

- [x] **(1) `add-lang go <pfad> --arch hexagonal` legt das geschichtete Modul an — samt Gate.**
  Exit 0, mit **genau** dem Layout aus [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md)
  Festlegung 1: `internal/hexagon/core` (`role: app`), `internal/hexagon/port` (`role: port`,
  importfrei), `internal/adapter/driven` und `internal/adapter/driving` (beide `role: adapter`,
  explizit — die Namen inferieren keine Rolle), `composition_root: ["cmd/**"]`; Kanten
  `core→ports`, `driven→ports`, `driven→core`, `driving→core` und **keine** weiteren. **Nicht** das
  `--print-config`-Gerüst (`internal/core` …). Die **Verdrahtung liegt in `cmd/**`** — dort
  entsteht der getriebene Adapter, wird in die Use-Case injiziert und diese an die treibende CLI
  übergeben; die CLI importiert **keinen** Adapter. Dazu Rollen-Vokabular, geöffnete Achse und
  `.a-check.yml`.
  **Voraussetzung, die der Plan-Review als HIGH gefunden hat:** die Geschichtet-Erkennung wird von
  **Namen auf Struktur** gehoben. Heute entscheidet `archLayered` an `roleDomain` und der
  Kopplungs-Wächter an `strings.Contains(rel, "hexagon/domain/")` — beides ist hexslice-Vokabular.
  Unverändert übernommen hieße: `archLayered("hexagonal")` = false → **kein Arch-Gate emittiert**,
  und der Wächter bliebe dabei **grün**
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  Der Umbau berührt `hexslice` mit und ist deshalb Teil **dieses** Punktes, nicht ein Anhang:
  *geschichtet* heißt künftig „das Layout trägt mindestens eine Rolle, die weder Entry-Point noch
  Test noch Composition Root ist". **Der Kopplungs-Wächter darf dabei nicht dieselbe Funktion
  befragen, die er bewacht** — sonst ist er tautologisch; er leitet *geschichtet* aus dem
  **gerenderten Baum** ab. Gegenprobe: `flat` und `hexslice` bleiben **byte-identisch**, und für
  beide bleibt die Gate-Entscheidung unverändert (rot gesehen: die neue Erkennung einmal so
  brechen, dass `hexslice` sein Gate verliert).
- [x] **(2) Das Gate hat Zähne — an beiden tragenden Regeln, mit Regel-Namen.** Zwei
  Gegenbeispiele werden im realen Ziel **rot gesehen**, nicht nur „Exit ≠ 0": ein
  `core → driven`-Import als **`app-impurity`** (der Kern trägt `role: app` und darf keinen Adapter
  sehen) und ein `driving → driven`-Import als **`lateral-adapter`** — Letzterer ist die tragende
  Regel dieses Layouts und **keine Kante**, also fängt ihn kein Kanten-Wächter
  ([`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) Folgepflicht 7). Die Kante
  **`driven → core`** ist Teil der emittierten Config — im Gerüst nur auskommentiert, in der Familie
  real geführt — und bekommt einen Mutations-Fall, sonst „räumt" sie später jemand weg (die Lehre
  aus slice-054/Fall 96).
- [x] **(3) Die Abgrenzung zu `hexslice` ist mechanisch, nicht nur beschrieben.** Ein Test hält
  fest, dass die beiden Layouts **disjunkte Verzeichnisnamen** tragen (`core` vs `domain`, `port`
  vs `application/**/ports`, `adapter/driven` vs `adapters/outbound`); sonst verschmelzen sie beim
  nächsten Aufräumen zu einem Layout mit zwei Kanten-Mengen — genau das, was CR 0.17.0 ausschließt.
  Im selben Zug hält ein Test die **Zyklenfreiheit** der emittierten Kanten-Menge fest: `core→ports`
  **und** `ports→core` zusammen wären in einer einzigen Kern-Schicht ein Import-Zyklus, den die
  Sprache ausschließt — der Grund, aus dem [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md)
  `ports→core` nicht führt.
- [x] `make gates` grün, `make mutate` ohne Befund, `make full-smoke` grün.
- [x] Doku-Update: [Handbuch](../../../user/benutzerhandbuch.md) und
  [`README.md`](../../../../README.md) nennen die dritte Bauform — **erst wenn (1) und (2) grün
  sind** (die Reihenfolge aus slice-054).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-27, live):**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | Die Achse kennt zwei Werte | `grep -n "archFlat\|archHexslice" internal/gen/arch.go` → `flat`, `hexslice` |
| 2 | Das Rollen-Vokabular ist hexslice-geprägt | `roleDomain`, `rolePorts`, `roleAppSlice`, `roleAdapters`, `roleCompositionRoot`, `roleEntrypoint`, `roleTest` — für `core`/`port`/`adapter-driven` gibt es **keine** Rollen |
| 3 | Die Familien-Konvention weicht vom Gate-Gerüst ab | `a-check --print-config` → `internal/core`, `internal/ports`, `internal/adapters`; die realen Repos → `internal/hexagon/core`, `internal/hexagon/port`, `internal/adapter/driven` |
| 4 | Die Kante `adapters → core` wird real geführt | im Referenz-Repo gesetzt; im `--print-config`-Gerüst nur als Kommentar |
| 5 | Ein Adopter verfeinert die Config selbst | das zweite Referenz-Repo teilt den Kern in `model`/`rules`/`app`/`coretest` — unsere `.a-check.yml` ist skip-if-present, das Modell trägt |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/arch.go` | update | `archHexagonal`-Konstante, Layout (`archLayout`), Rollen für `core`/`port`/`adapter`; `archGateConfigs` um den go-Eintrag |
| `internal/gen/gen.go` | update | `langArchs()["go"] += archHexagonal` |
| `internal/gen/golang.go` | update | Rollen-Renderer für das neue Layout + die `.a-check.yml` der Familie |
| `internal/gen/*_test.go` | update/neu | Datei-Satz, Config-gegen-Skelett, Disjunktheit der Layouts, `flat`/`hexslice` unverändert |
| `harness/tools/full-smoke.sh` | update | `add-lang go <pfad> --arch hexagonal` + **zwei** Zähne: `core → driven` (`app-impurity`) und `driving → driven` (`lateral-adapter`) |
| `test/mutations/` | neu | Rollen-Abdeckung (die expliziten `role:`-Einträge) · `driven → core`-Kante · Disjunktheit |
| [`spec/architecture.md`](../../../../spec/architecture.md) §5 | update | die normative Heimat der Layout-Regeln nennt heute **nur** `hexslice` (6 Treffer gegen 0) — ein zweites schichten-tragendes Layout gehört dorthin, nicht nur ins Handbuch (Plan-Review F-3, slice-053-Lehre) |
| `internal/gen/arch.go` (`archLayered`) + `internal/gen/archgate_test.go` | update | Geschichtet-Erkennung von Namen auf Struktur (Plan-Review F-1) — berührt `hexslice` mit |
| Handbuch, [`README.md`](../../../../README.md) | update | dritte Bauform — **nach** den Sensoren |

## 3a. ADR-Frage (Plan-Review F-2) — **entschieden**

Der Plan-Review verlangte für dieses Layout dieselbe Klasse Entscheidung, die `hexslice` in
[`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) bekommen hat. Sie steht jetzt in
[`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) (**Accepted**, 2026-07-27) und
band vier Proposed-Runden — jede fing, was die vorige eingebaut hatte:

| Runde | was sie entschied |
|---|---|
| 1 | die treibende Seite fehlte ganz; die Familie löst sie **uneinheitlich** |
| 2 | sie wurde ergänzt — und öffnete dabei einen ungeprüften Bereich unter `driving/` |
| 3 | `driving/**` wird **Schicht** statt Ausnahme; daraus die Regel *bei Unkenntnis der Adopter ist der Default fail-closed* |
| 4 | die Folgen davon: explizite Rollen, Kanten-Menge ohne `ports→core` (Zyklus), **Verdrahtung in `cmd/**`** |

**Für diesen Slice heißt das:** Schichten, Rollen, Kanten, Verdrahtungsort und die beiden tragenden
Regeln (`app-impurity`, `lateral-adapter`) sind **vorgegeben**, nicht Gegenstand der Umsetzung. Die
Umsetzung erfindet sie nicht neu und weicht nicht ab; fällt bei der Umsetzung ein Grund gegen die
Festlegung auf, ist das eine **neue ADR mit *Supersedes***, kein stiller Renderer-Entscheid — die
ADR ist ab Annahme immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4).

## 4. Trigger

**`open` → `in-progress`:** CR **0.17.0** ist gefahren (eigener Commit, vor diesem Slice) — die
Anforderung führt `hexagonal` jetzt. Der Bedarf ist doppelt belegt: Gate-Standardform **und** zwei
reale Repos der Familie. **Zusätzlich seit dem Plan-Review vom 2026-07-27:** die ADR-Frage aus §3a
ist entschieden — [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) ist
**Accepted**. Der Plan-Review war **blockierend** (1 HIGH); sein Befund steckt jetzt in DoD (1).
Damit ist die Bedingung „bleibt in `open/`, bis entschieden ist" erfüllt.

Rückführungen:

- `in-progress` → `next`: falls das neue Layout zeigt, dass Rollen-Vokabular und `archLayout` eine
  gemeinsame Umbaustufe brauchen (heute sind die Rollen hexslice-geprägt) — dann trennt ein
  Re-Slice den Vokabular-Umbau vom Renderer.
- `in-progress` → `open`: falls die Familien-Konvention und das Gate-Gerüst sich als **unvereinbar**
  erweisen (etwa weil a-check auf `internal/core` fest verdrahtet ist). Dann ist die Wahl des
  emittierten Layouts eine Architektur-Entscheidung mit ADR-Bedarf, kein Renderer-Detail.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt die DoD
(Modul 11); `make gates`, `make mutate` und `make full-smoke` grün; `git mv` nach `done/` (eigener
Move-Commit, Link-Reconciliation im Folge-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Zwei Layouts, die sich ähneln, verschmelzen mit der Zeit.** `hexagonal` und `hexslice` teilen
  die Idee, nicht die Namen. Ohne den Disjunktheits-Test aus DoD (3) macht der nächste Aufräumer
  ein Layout mit zwei Kanten-Mengen daraus — und CR 0.17.0 hat genau das ausgeschlossen.
- **Die Kante `driven → core` sieht wie ein Fehler aus.** Sie steht im Gate-Gerüst nur
  auskommentiert. Wer die emittierte Config gegen das Gerüst liest, hält sie für Überschuss —
  deshalb der Mutations-Fall (dieselbe Klasse wie die C++-Kante `adapters → ports` in slice-054).
- **Das Rollen-Vokabular ist heute hexslice-geprägt.** `roleDomain`/`roleAppSlice` passen nicht auf
  `core`/`port`. Entweder neue Rollen oder eine Umbenennung — Letztere zöge `hexslice` mit und
  bräche dessen Byte-Identität. Der Plan wählt **neue Rollen**; zeigt die Umsetzung, dass das den
  Kompositions-Kern verbiegt, greift die Rückführung nach `next`.
- **Die zweite Sprache ist bewusst draußen.** cpp erbt die Achse, braucht aber eine eigene
  Kanten-Prüfung (Vererbung ⇒ `adapters → ports`, wie in slice-053 gemessen). Eigener Zuschnitt.
- **Die ungenutzten Gate-Fähigkeiten bleiben ungenutzt** (`adapter_sink`, `tech`,
  `forbidden_constructs`): die Referenz-Configs der Familie führen sie, unsere emittierte tut
  es weiterhin nicht — dieselbe Abgrenzung wie in welle-08 §6. Sie steht hier, damit die
  Auslassung als Absicht lesbar ist (Plan-Review F-4).
- **Der Disjunktheits-Test darf keine hartkodierte Liste sein** — er leitet die
  Verzeichnisnamen aus den Renderern ab und prüft den Schnitt beider Mengen; sonst altert er
  beim vierten Layout still (Plan-Review F-5).
- **Die Verdrahtung liegt in `cmd/**` — dem einzigen ungeprüften Bereich.** Das ist die eine
  Stelle, an der wir der Familie bewusst nicht folgen. Steht dort mehr als Konstruktion, wandert
  Logik ins Ungeprüfte; der Renderer emittiert deshalb dort **nur** Konstruktion, und die Use-Case
  bleibt im Kern ([`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) §Konsequenzen).
- **Kein Carveout absehbar.**

## 7. Closure-Notiz (nach `done/`)

**Abgeschlossen:** 2026-07-28. **Rollen-Sequenz vollständig:** Implementation → Review
(`docs/reviews/2026-07-28-slice-058-impl-review.md`, KONFORM mit Auflagen: 0 HIGH · 2 MEDIUM ·
2 LOW · 1 INFO) → Verifikation (`docs/reviews/2026-07-28-slice-058-verification.md`, **DoD
BESTÄTIGT**, keine Rückkante) → Closure. Sensoren auf dem Endstand, von Review **und**
Verifikation je selbst gefahren: `make gates` Exit 0 (d-check 224/0, comment-claims 31/0) ·
`make mutate` **102 ok / 0 Befunde** · `make full-smoke` Exit 0.

### Was funktioniert hat

- **Die ADR ging voraus, und das war der Unterschied.** Schichten, Rollen, Kanten und
  Verdrahtungsort standen in [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) fest
  (vier Proposed-Runden); die Umsetzung hatte keine Designfrage mehr offen, und der Review konnte
  sie **Zeile für Zeile gegen die ADR-Tabelle** prüfen statt zu diskutieren — 0 HIGH.
- **Der Plan-Review-HIGH vor dem Code.** Die Geschichtet-Erkennung von Namen auf Struktur zu
  heben war **Voraussetzung, nicht Anhang**: unverändert übernommen hätte `hexagonal` still kein
  Arch-Gate bekommen, und der Wächter wäre dabei grün geblieben.
- **Zähne mit Regel-Namen statt „Exit ≠ 0".** Beide tragenden Regeln wurden im realen Ziel rot
  gesehen (`app-impurity`, `lateral-adapter`) — Letztere ist **keine Kante**, also fängt sie kein
  Kanten-Wächter.

### Was anders lief als geplant

- **Aus drei Mutations-Klassen wurden acht Fälle** (99–106). Der Plan nannte Rollen,
  `driven→core` und Disjunktheit; die strukturelle Erkennung brauchte **zwei Richtungen**
  (102 = das neue Layout verliert sein Gate, 103 = das bestehende verliert es), und der Review
  fand drei weitere Wächter ohne Fall (104–106).
- **Ein Mutations-Fall scheiterte an sich selbst und meldete es.** Die erste Fassung von 103
  (`if false` an der Schleifenbedingung) ließ die Schleifenvariable ungenutzt → Compile-Fehler →
  `make mutate` meldete „rot, aber die Erwartung fällt nicht — falscher Grund". Der Sensor hat
  seinen eigenen Defekt gefangen, nicht ich.
- **Der CR kam zu spät.** `LH-FA-07` beschrieb das Gate layout-spezifisch; das fiel erst im
  Review auf (F-2). Der CR 0.18.0 liegt damit **nach** dem `open → in-progress`-Move, während
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 2 ihn davor verlangt — die Abweichung steht in der Historie-Zeile selbst.
- **Mehr als geplant, aber ADR-gedeckt:**
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  stand nicht in der Plan-Tabelle; [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md)
  Folgepflicht 6 verlangt den Zeiger.

### Steering-Loop-Einträge

1. **Eine Fähigkeits-Erkennung, die an Namen hängt, ist eine Zeitbombe mit stillem Zünder.**
   `archLayered` fragte nach der Rolle `domain` — für das erste geschichtete Layout richtig, für
   jedes zweite falsch, und zwar **grün**. Geschärfte Regel: Erkennungen, die über eine
   *Fähigkeit* entscheiden (bekommt dieses Ding sein Gate?), strukturell formulieren, nie über
   eine Namensliste — und **der Wächter darf nicht dieselbe Funktion befragen, die er bewacht**,
   sonst ist er tautologisch. Neuer Sensor: die Baum-abgeleitete Erkennung im Kopplungs-Wächter
   plus die Fälle `test/mutations/102-archlayered-namensbasiert.sh` und
   `test/mutations/103-archlayered-erkennung-weg.sh` (beide Richtungen).
2. **Falsche Begründung im Sensor-Korpus ist ein eigener Befund-Typ — zweimal in diesem Slice
   getroffen.** Review-F-4 (`test/mutations/63-langarch-support.sh` begründete sich mit einer
   Aussage, die derselbe Commit als überholt korrigierte) und Verifikations-A-2
   (`test/mutations/104-hexagonal-role-fileset.sh` behauptete „das Skelett übersetzt weiter" —
   es übersetzt **nicht**). Die Mutation greift in beiden Fällen; die **Prosa** lügt, und wer sie
   liest, zieht den falschen Schluss. Geschärfte Regel: die Begründung eines Mutations-Falls wird
   gegen den **beobachteten** Fehlschlag geschrieben, nicht gegen die Absicht.
   **Sensor-Lücke, ehrlich benannt:** `make comment-claims` deckt Kommentar-Behauptungen im
   Code, **nicht** die `#`-Prosa in `test/mutations/` — diese Klasse hat heute keinen Sensor.
3. **Wenn ein Slice eine Fähigkeit verdoppelt, ist die bindende Anforderung auf „Klasse statt
   Instanz" zu prüfen.** `LH-FA-07` nannte `--arch hexslice` namentlich; mit dem zweiten Layout
   trat der Vertrag vom Verhalten weg. Dieselbe Konstellation lag bei slice-053 (zweite Sprache)
   vor und fiel dort **nicht** auf — die Klasse ist also älter als dieser Slice.
4. **Restrisiko, benannt statt geglättet (Verifikations-A-1):** „`flat` und `hexslice` bleiben
   byte-identisch" ist **statisch belegt** (der Diff fasst ihre Konstanten nicht an), aber von
   **keinem Sensor gemessen** — kein Wächter vergleicht den Inhalt gegen einen Vorher-Stand. Der
   DoD-Text ist an dieser Stelle strenger als
   [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), das für `flat`
   „funktional unverändert" verlangt. Der Teil der Zusage **mit** Rot-Pflicht (die
   Gate-Entscheidung) hat sein Gegenbeispiel (Fall 103).

### Folge-Kandidaten (benannt, **nicht** geschnitten — cp-Disziplin)

- **`make doc-targets` verdrahten** (`modules:` + `gates`) samt Mutations-Fall „Geister-Befehl":
  die Modul-15-Pflichtregel *„keine Befehle behaupten, die es nicht gibt"* liegt als
  tool-geliefertes Ziel vor, ist an keinen Trigger gehängt und heute grün gemessen (224/0).
  Gehört auf die Achse *Regeln ohne Feedback-Quadrant schließen* — dieselbe, auf der
  [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  schon `doc-planning` benannt hat. **Dogfood-Ebene**; ob die *emittierte* `.d-check.yml` (heute
  `[links, anchors]`) nachzieht, ist eine eigene Frage am Adopter-Vertrag
  ([`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)).
- **cpp × hexagonal** — [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) Folgepflicht 3:
  die zweite Sprache erbt die Achse, **nicht** die Kanten-Menge (Vererbung ⇒ `adapters→ports`).
- **Byte-Identitäts-Sensor** für `flat`/`hexslice` — oder die Zusage auf das einschränken, was
  gedeckt ist (A-1).
- **CLI-Ebenen-Test für `hexagonal`** (A-4): heute hängt die CLI-Ebene allein am `make full-smoke`;
  `hexslice` hat seinen Test in `cmd/ai-harness-init/main_test.go`.

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als
**Greenfield**; die berührte Sub-Area *Generator* (`internal/gen/`) ist in diesem Repo entstanden
und vollständig bekannt. Der Vollblock entfällt damit laut Template.

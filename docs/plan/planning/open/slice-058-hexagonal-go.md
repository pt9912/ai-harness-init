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
HexSlice-Realisierung, von der dieses Layout **abgegrenzt** wird).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

`add-lang go <pfad> --arch hexagonal` legt ein Go-Modul mit den **drei klassischen Schichten** an —
`core` / `port` / `adapter` plus Composition Root —, und das Arch-Gate prüft sie. Maßstab ist die
**gelebte Konvention der Werkzeug-Familie**, nicht das Lehrbuch und nicht das
`--print-config`-Gerüst.

## 2. Definition of Done

- [ ] **(1) `add-lang go <pfad> --arch hexagonal` legt das geschichtete Modul an — samt Gate.**
  Exit 0, mit dem Layout der Familie (`internal/hexagon/core`, `internal/hexagon/port`,
  `internal/adapter/driven`, Composition Root `cmd/**`), **nicht** dem `--print-config`-Gerüst
  (`internal/core` …); dazu Rollen-Vokabular, geöffnete Achse und `.a-check.yml`.
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
- [ ] **(2) Das Gate hat Zähne, und die Kanten-Menge ist bewacht.** Ein verbotener
  `core → adapter`-Import färbt `a-check` im realen Ziel rot, **mit Richtungs-Befund** (nicht nur
  Exit ≠ 0). Die Kante **`adapters → core`** ist Teil der emittierten Config — sie steht im
  `--print-config`-Gerüst nur auskommentiert, die Familie führt sie real — und sie bekommt einen
  Mutations-Fall, sonst „räumt" sie später jemand weg (die Lehre aus slice-054/Fall 96).
- [ ] **(3) Die Abgrenzung zu `hexslice` ist mechanisch, nicht nur beschrieben.** Ein Test hält
  fest, dass die beiden Layouts **disjunkte Verzeichnisnamen** tragen (`core` vs `domain`, `port`
  vs `application/**/ports`, `adapter/driven` vs `adapters/outbound`); sonst verschmelzen sie beim
  nächsten Aufräumen zu einem Layout mit zwei Kanten-Mengen — genau das, was CR 0.17.0 ausschließt.
- [ ] `make gates` grün, `make mutate` ohne Befund, `make full-smoke` grün.
- [ ] Doku-Update: [Handbuch](../../../user/benutzerhandbuch.md) und
  [`README.md`](../../../../README.md) nennen die dritte Bauform — **erst wenn (1) und (2) grün
  sind** (die Reihenfolge aus slice-054).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
| `harness/tools/full-smoke.sh` | update | `add-lang go <pfad> --arch hexagonal` + Zahn (verbotener `core → adapter`-Import) |
| `test/mutations/` | neu | Rollen-Abdeckung · `adapters → core`-Kante · Disjunktheit |
| [`spec/architecture.md`](../../../../spec/architecture.md) §5 | update | die normative Heimat der Layout-Regeln nennt heute **nur** `hexslice` (6 Treffer gegen 0) — ein zweites schichten-tragendes Layout gehört dorthin, nicht nur ins Handbuch (Plan-Review F-3, slice-053-Lehre) |
| `internal/gen/arch.go` (`archLayered`) + `internal/gen/archgate_test.go` | update | Geschichtet-Erkennung von Namen auf Struktur (Plan-Review F-1) — berührt `hexslice` mit |
| Handbuch, [`README.md`](../../../../README.md) | update | dritte Bauform — **nach** den Sensoren |

## 3a. ADR-Frage (Plan-Review F-2) — offen, Nutzer-Entscheidung

**Der Befund:** für die Realisierung von `hexslice` wurde eine eigene ADR geschrieben
([`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md): welche Rollen, welche Richtungen, nach
welcher Referenz). Für `hexagonal` steht dieselbe Klasse an. Der Plan behandelte sie zunächst als
Renderer-Detail — inkonsistent zur eigenen Präzedenz.

**Was für eine ADR spricht:** die Wahl trifft Adopter dauerhaft (Verzeichnis-Layout ist schwer
umkehrbar, sobald Repos so gebaut sind), und es ist eine **echte Wahl** — die gelebte
Familien-Konvention (`internal/hexagon/core`) gegen das Gate-Gerüst (`internal/core`). Beide sind
vertretbar; wir wählen die erste. Genau solche Entscheidungen sollen laut
[`AGENTS.md`](../../../../AGENTS.md) §5 auffindbar sein — ein Slice wandert nach `done/` und wird
nicht mehr gelesen.

**Was dagegen spricht:** [`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md) trägt die
Achse bereits und sieht mehrere Architekturen ausdrücklich vor; die Layout-Wahl ist hier weniger
Entwurf als **Messung** (zwei reale Repos, ein Gate-Gerüst). Eine ADR pro Architektur könnte die
Achse mit Zeremonie belasten, die der nächsten Sprache nicht hilft.

**Empfehlung des Reviews:** eine **kurze `ADR-0010`** <!-- d-check:ignore (noch nicht angelegt — Gegenstand der offenen Entscheidung) --> (Proposed-first wie 0006–0009), die genau zwei
Dinge festhält — *welches Layout emittiert wird und warum die Familien-Konvention gegen das
Gate-Gerüst gewinnt* sowie *warum `hexagonal` und `hexslice` getrennte Layouts bleiben*. Das ist
billiger als die spätere Frage „warum eigentlich `core` und nicht `domain`?", die sonst niemand
mehr beantworten kann.

**Bis zur Entscheidung bleibt dieser Slice in `open/`.**

## 4. Trigger

**`open` → `in-progress`:** CR **0.17.0** ist gefahren (eigener Commit, vor diesem Slice) — die
Anforderung führt `hexagonal` jetzt. Der Bedarf ist doppelt belegt: Gate-Standardform **und** zwei
reale Repos der Familie. **Zusätzlich seit dem Plan-Review vom 2026-07-27:** die ADR-Frage aus §3a
ist entschieden (ADR geschrieben oder begründet abgelehnt). Der Plan-Review war **blockierend**
(1 HIGH); sein Befund steckt jetzt in DoD (1).

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
- **Die Kante `adapters → core` sieht wie ein Fehler aus.** Sie steht im Gate-Gerüst nur
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
- **Kein Carveout absehbar.**

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als
**Greenfield**; die berührte Sub-Area *Generator* (`internal/gen/`) ist in diesem Repo entstanden
und vollständig bekannt. Der Vollblock entfällt damit laut Template.

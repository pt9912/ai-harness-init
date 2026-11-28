# Slice slice-027: CI — der Sensor-Lauf auf frischem Klon

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

> **Herkunft: eine seit Monaten dokumentierte Annahme ohne Implementierung.**
> [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) (2026-06-13) benennt als Restlücke des Gate-Nachweises: *„frischer Klon
> bzw. gelöschter `.harness`-State mit cleanem Tree wird freigegeben (**CI ist dort das
> Netz**)."* Dieses Netz gibt es nicht — gemessen am 2026-07-20: keine
> CI-Konfiguration im Repo. Die Restlücke ist also seit der Formulierung **unabgedeckt**,
> und die Zusage „CI fängt das" ist eine Zusage ohne Abdeckung ([`AGENTS.md`](../../../../AGENTS.md) §3.6,
> eine Ebene über dem Code).
>
> Zweiter Auslöser: `make mutate` (slice-026) und `make smoke` sind **Nicht-Gate**-Sensoren.
> Sie hängen heute an Wellen-Closure-Triggern — das ist besser als nichts, aber grob
> gekörnt: zwischen zwei Closures kann ein Wächter seine Zähne verlieren, ohne dass es
> jemand sieht.

Ein CI-Lauf, der auf **frischem Klon** `make gates` fährt (die Restlücke aus
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)) und die Nicht-Gate-Sensoren in der Körnung laufen lässt, die zu ihnen
passt — statt sie an menschliche Disziplin zu binden.

## 2. Definition of Done

- [x] **Entwurfs-Entscheidungen getroffen und begründet** (§6): Runner-Plattform · welche Targets in welchem Job · Umgang mit den **netz-abhängigen** Sensoren · Frequenz je Sensor. **Vor der Konfiguration**, nicht nebenbei.
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): CI fährt `make gates` auf einem **frisch geklonten** Repo ohne `.harness/state/` — genau der Fall, den [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) als Restlücke benennt und den lokal **nichts** prüft (der Stop-Hook gibt einen cleanen Tree ohne State frei).
- [x] `make mutate` und `make smoke` laufen in CI. Damit hängt [`AGENTS.md`](../../../../AGENTS.md) §3.6s Feedback nicht mehr allein an einem Wellen-Closure-Trigger.
- [x] **Die CI definiert den Build NICHT neu:** sie ruft ausschließlich `make`-Targets. Eine zweite Definition dessen, was ein Gate ist, wäre exakt die Drift-Klasse, die dieses Repo an mehreren Stellen bereits bekämpft hat ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Geist: eine Quelle, nicht zwei).
- [x] [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) gewahrt: der Runner braucht Docker, aber **keine** Host-Go-Toolchain — sonst hätte die CI eine Fähigkeit, die der lokale Guard verbietet.
- [x] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): kein floating `latest`. `runs-on: ubuntu-24.04` (benannte Version) und `actions/checkout` per Commit-SHA gepinnt. Grenze in [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 4 benannt: ein GitHub-**hosted** Runner-Image ist nicht *digest*-pinnbar — die Check-Reproduzierbarkeit trägt die gepinnten Tool-Images, nicht der Runner.
- [x] Die netz-abhängigen Maintenance-Sensoren (`regelwerk-check`, `baseline-freshness`) laufen **getrennt** und in eigener Frequenz — sie gehören nicht in den Pfad, der pro Push grün sein muss.
- [x] [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) benennen, **was CI prüft und was nicht** — kein „CI fängt das" ohne Angabe, was genau.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| CI-Konfiguration | neu | Der eigentliche Liefergegenstand; Pfad/Format folgt aus der Runner-Entscheidung (§6) |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Was CI prüft — und was sie **nicht** prüft |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Neuer MR-Eintrag: die CI-Setzung samt Frequenz-Wahl; [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)s Restlücke bekommt ihren Nachtrag |

**Nachgeführt 2026-07-20 (aus der Implementierung).** Der Slice liefert mehr als die reine
Workflow-Datei — das lokale Gegenbeispiel-Gate zur CI und dessen Selbstbewachung:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `ci-lint`-Target (actionlint, gepinntes Image) **in `make gates`**: der Workflow-Syntaxfehler ist lokal vor dem Push fangbar (das Gegenbeispiel-Gate zu „die CI läuft", [`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `test/mutations/10-ci-workflow-syntax.sh` | neu | Schritt 19: der neue Gate-Wächter `ci-lint` bekommt seine Mutation (doppelter `runs-on` → actionlint rot); neuer `# verify: ci-lint`-Modus |
| `harness/tools/mutate.sh` | update | `failure_form` um den `ci-lint`-Arm erweitert (die eine Zulassungsquelle aus [slice-026](slice-026-mutations-sensor.md) N-2) |

## 4. Trigger

slice-026 in `done/` (dann steht `make mutate`, das die CI fahren soll). Als
Harness-Wartung hängt der Slice an keiner Welle; die Roadmap sequenziert ihn.

**Nicht dringlich, aber auch nicht beliebig aufschiebbar:** je länger die
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke unabgedeckt bleibt, desto mehr Zusagen stützen sich auf ein
Netz, das nicht existiert. Ein sinnvoller Zeitpunkt ist **vor** der welle-02-Closure —
dann prüft der erste CI-Lauf einen Stand, den vier Rollen-Durchgänge schon gesehen haben.

Rückführungen: `in-progress → next`, wenn die Runner-Entscheidung und die Konfiguration
nicht in eine Sitzung passen. `in-progress → open`, wenn sich zeigt, dass die
Runner-Wahl eine Architektur-Entscheidung ist (Netz-Abhängigkeit, Kosten,
Datenabfluss) — dann ADR vor Code, Modul 4.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Danach ist die
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke belegt abgedeckt statt behauptet.

## 6. Risiken und offene Punkte

- **Die CI wird leicht zur zweiten Build-Definition.** Wer Schritte in die
  CI-Konfiguration schreibt statt `make`-Targets aufzurufen, hat zwei Wahrheiten darüber,
  was ein Gate ist — und sie driften. Dieses Repo hat diese Klasse mehrfach bekämpft
  ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert): Fragment tool-generiert statt handgepflegt). **Nur `make`.**
- **Frequenz-Entwurf ist der eigentliche Inhalt, nicht die YAML.** Drei Klassen mit
  verschiedenen Kosten: `gates` ist offline und schnell (pro Push), `smoke`/`mutate`
  brauchen Docker und Minuten (pro Push? pro PR? nächtlich?), `regelwerk-check`/
  `baseline-freshness` brauchen **Netz zu einem Fremd-Host** (nie im Pflicht-Pfad —
  ein Upstream-Ausfall dürfte nie einen Push blockieren). Die Wahl gehört begründet,
  nicht geraten.
- **Netz-Sensoren können falsch-rot werden.** `baseline-freshness` meldet einen neuen
  Upstream-Tag — das ist ein *Hinweis*, kein Defekt des Commits. Läuft er im
  Pflicht-Pfad, blockiert ein Kurs-Release die Entwicklung. Das ist die Sorte
  Fehlkonstruktion, die Leute dazu bringt, Gates zu ignorieren.
- **Ein grüner CI-Lauf ist keine Aussage über das, was er nicht fährt.** Wird das nicht
  benannt, entsteht dieselbe Überdehnung wie bei „`make smoke` belegt Byte-Gleichheit"
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Beispiel 2) — nur mit größerer Reichweite.
- **Reihenfolge zum Repo-Zustand:** die CI wird `make gates` auf frischem Klon fahren.
  Sollte das *heute* nicht grün sein (etwa weil ein Sensor lokalen State voraussetzt),
  ist genau das der Befund, den der Slice liefern soll — nicht ein Grund, ihn zu
  verschieben.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** `.github/workflows/ci.yml` fährt bei jedem Push/PR `make gates` + `make smoke` +
`make mutate` auf frischem, gehostetem Klon; die Netz-Sensoren nur nächtlich. Die CI ruft
**ausschließlich `make`-Targets** ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions), Setzung 1). Dazu `make ci-lint`
(actionlint, gepinnt) als **Gate in `make gates`** — das lokale Gegenbeispiel-Gate zur Zusage
„die CI läuft" ([`AGENTS.md`](../../../../AGENTS.md) §3.6), mit eigenem Mutations-Fall
(`test/mutations/10`).

**Der Kern — die [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke ist geschlossen, und zwar belegt.** Sie stand seit
2026-06-13 offen: „frischer Klon … CI ist dort das Netz" — und dieses Netz existierte nicht. Es
existiert jetzt, und der Beleg ist **empirisch**, nicht behauptet: der GitHub-Actions-Lauf gegen den
gepinnten Stand lief grün — `gates` (1m20s), `mutate` (2m35s), `smoke` (31s), `upstream-drift`
skipped (push, nicht schedule). Zusätzlich lokal vom Verifier bestätigt: `git clone` in ein frisches
tmp ohne `.harness/state/` → `make gates` Exit 0.

**Drei Rollen-Runden, jede fing etwas, das die vorige nicht sah:**
- **Verifier** fand die DoD-Verletzung, die Reviewer und Tests nicht sehen können ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit):
  `ubuntu-latest`/`@v4` floating) — die reine Verifier-only-Klasse, und ich hatte sie übersehen,
  weil ich die Tool-*Images* pinnte und die *Runner*-Umgebung nicht.
- **Reviewer** fand zwei echte Workflow-Bugs (F-1 concurrency ließ Push den Nachtlauf kappen, F-2
  verschluckte `baseline-freshness`) — beide gefixt statt vertagt.
- **Sensor** (`make mutate`) fing beim Bau **zwei** eigene Fehler: Fall 09 („Mutation hat nicht
  gegriffen", weil der neue `ci-lint`-Arm `failure_form` neu ausrichtete) und Fall 10 („falscher
  Grund", weil `actionlint -color` das Fehler-Präfix zerstückelte).

### Steering-Loop-Eintrag — benannte Spec-Lücke geschlossen + neue Grenze

Die **Spec-Lücke** ist die Herkunft dieses Slice: [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) verließ sich seit einem
Dreivierteljahr auf ein „CI ist dort das Netz", das niemand gebaut hatte. Der Lerneintrag ist
weniger die CI selbst als das **Muster**: eine Zusage in einem MR („X fängt das") ohne das
Artefakt X ist §3.6 auf Prozess-Ebene — sie überlebt, weil kein Sensor sie prüft. Gefunden wurde
sie nicht durch Absicht, sondern beim **Berichten der slice-026-Restrisiken** (Messung „gibt es CI?"
→ nein). Geschärfte Regel: **wenn ein MR ein Artefakt als Abdeckung nennt, gehört die Existenz
dieses Artefakts geprüft, nicht angenommen** — dieselbe Rot-gesehen-Disziplin wie bei Tests, eine
Ebene höher.

### Was diese Closure NICHT behauptet

- **Der nächtliche `upstream-drift`-Job ist im push-Pfad nicht belegt** (er ist dort `skipped`). Die
  F-2-Änderung (`baseline-freshness` läuft auch bei `regelwerk-check`-Fehler) ist von `actionlint`
  syntaktisch bestätigt, aber ihr **Verhalten** zeigt erst der erste `schedule`-Lauf (~03:00 UTC) oder
  ein manueller Trigger. Ehrlich offen, nicht behauptet.
- **`ci-lint` belegt Workflow-Syntax, nicht -Verhalten** — das Verhalten belegt der Actions-Lauf
  (jetzt geschehen und grün).

### Folge-Slices

- Keiner zwingend. **N-6 (slice-026) ist mit diesem Slice vollständig** — `make mutate` hat jetzt
  seinen mechanischen Pro-Push-Auslöser. Die restlichen welle-02-Slices (025 → 023 → 004b) folgen der
  Roadmap; sie sind von slice-027 unberührt.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Die
CI-Konfiguration ist eine **neue** Sub-Area ohne Altbestand — es gibt nichts zu
reconcilen, nur zu setzen.

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

- [ ] **Entwurfs-Entscheidungen getroffen und begründet** (§6): Runner-Plattform · welche Targets in welchem Job · Umgang mit den **netz-abhängigen** Sensoren · Frequenz je Sensor. **Vor der Konfiguration**, nicht nebenbei.
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): CI fährt `make gates` auf einem **frisch geklonten** Repo ohne `.harness/state/` — genau der Fall, den [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) als Restlücke benennt und den lokal **nichts** prüft (der Stop-Hook gibt einen cleanen Tree ohne State frei).
- [ ] `make mutate` und `make smoke` laufen in CI. Damit hängt [`AGENTS.md`](../../../../AGENTS.md) §3.6s Feedback nicht mehr allein an einem Wellen-Closure-Trigger.
- [ ] **Die CI definiert den Build NICHT neu:** sie ruft ausschließlich `make`-Targets. Eine zweite Definition dessen, was ein Gate ist, wäre exakt die Drift-Klasse, die dieses Repo an mehreren Stellen bereits bekämpft hat ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Geist: eine Quelle, nicht zwei).
- [ ] [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) gewahrt: der Runner braucht Docker, aber **keine** Host-Go-Toolchain — sonst hätte die CI eine Fähigkeit, die der lokale Guard verbietet.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): die CI-Umgebung ist gepinnt (Runner-Image/Version), kein floating `latest`.
- [ ] Die netz-abhängigen Maintenance-Sensoren (`regelwerk-check`, `baseline-freshness`) laufen **getrennt** und in eigener Frequenz — sie gehören nicht in den Pfad, der pro Push grün sein muss.
- [ ] [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) benennen, **was CI prüft und was nicht** — kein „CI fängt das" ohne Angabe, was genau.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| CI-Konfiguration | neu | Der eigentliche Liefergegenstand; Pfad/Format folgt aus der Runner-Entscheidung (§6) |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Was CI prüft — und was sie **nicht** prüft |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Neuer MR-Eintrag: die CI-Setzung samt Frequenz-Wahl; [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)s Restlücke bekommt ihren Nachtrag |

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

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Die
CI-Konfiguration ist eine **neue** Sub-Area ohne Altbestand — es gibt nichts zu
reconcilen, nur zu setzen.

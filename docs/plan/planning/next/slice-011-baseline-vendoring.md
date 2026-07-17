# Slice slice-011: Baseline committet vendoren

**Status:** next

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor), [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-16.

---

## 1. Ziel

Das Betriebsregelwerk wechselt vom **gefetchten, gitignorierten Cache** auf die
von der Baseline v3.1.0 vorgeschriebene **committet vendored** Form:
`.harness/baseline/v3.1.0/{regelwerk,templates}/` + `SHA256SUMS`, netzlos auf
jedem Checkout präsent. Quelle ist `lab-regelwerk.zip` vom Release-Tag `v3.1.0`
(ZIP-sha256 `bd90c721e7583b218d097def8abac42fb0544c7a140e2e649d71e772f7a90220`,
am 2026-07-17 gemessen; **vor** dem Vendoring erneut zu verifizieren). Regelwerk
**und** Templates liegen parallel — die `../templates/…`-Ziel-Form-Verweise des
Regelwerks lösen dadurch netzlos lokal auf: **12 eindeutige Ziele, 0 tot**
(Zählmethode, weil roh-`grep` je nach Muster 15–19 Treffer liefert: eindeutige
Link-**Ziele** nach `sort -u`, gemessen mit
`grep -rhoP '\.\./templates/\S*?\.md' regelwerk/ | sort -u`; Fließtext-Erwähnungen
wie `` `../templates/…` `` in `modul-02:185` zählen nicht mit).

`make regelwerk-fetch` entfällt; an seine Stelle tritt ein **netzloses**
`baseline-verify` (`sha256sum -c SHA256SUMS` **plus** Vollständigkeits-Check, s. §6),
das — anders als der bisherige Netz-Fetch — **in `gates`** laufen kann, ohne
offline-grün zu verletzen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
`make regelwerk-check` **bleibt** und wird auf den Baseline-Tag umgebogen — er ist
der einzige Upstream-Drift-Sensor, läuft als Maintenance-Target **nicht** in `gates`
und verletzt offline-grün damit nicht (s. §6).

Baseline-Vorgabe (Modul 2 §Anmerkung zur vendored Baseline, wortgleich; in v3.1.0
unverändert gegenüber v3.0.0 — am 2026-07-17 gegen `regelwerk/modul-02-harness-bootstrap.md:173-175`
geprüft): „Regelwerk *und* Templates werden beim Bootstrap **committet vendored**
(`.harness/baseline/<tag>/{regelwerk,templates}/` + `SHA256SUMS`, netzlos
materialisiert), nicht pro Lauf extern gefetcht".

**Abgrenzung.** Dieser Slice nimmt **nur** die Mechanik und die Doku-Absätze mit,
**die diese Mechanik beschreiben** (`AGENTS.md` §1 Cache-Absatz, `CLAUDE.md`
Pointer) — sonst behauptet das Repo nach dem Merge weiter „gitignored, kein
committeter Fremd-Blob" und wäre eine Harness-Lüge. **Nicht** hier: die toten
externen Quellen-Pointer und `harness/conventions.md` §Baseline (slice-012), der
Nachzug an Vorlagen und Slice-Köpfen (slice-013), die inhaltlichen Nachzüge an
Reviewer-Skill und Wellen-Closure (slice-014) und der d-check-Pin-Sprung
(v0.10.0 → 0.43.1; eigenes Risiko, eigener Slice).

## 2. Definition of Done

- [ ] `.harness/baseline/v3.1.0/{regelwerk,templates}/` committet (**42 Dateien**:
      21 `regelwerk/` + 21 `templates/`; ZIP-sha256
      `bd90c721e7583b218d097def8abac42fb0544c7a140e2e649d71e772f7a90220` vor dem
      Entpacken verifiziert) + erzeugtes `SHA256SUMS`; belegt, dass **alle 12
      eindeutigen** `../templates/…`-Ziele aus `regelwerk/` lokal auflösen (0 tot)
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] `Makefile`: `regelwerk-fetch` entfernt, `regelwerk-check` **behalten** und auf
      `BASELINE_TAG` umgebogen (Maintenance/Netz, **nicht** in `gates`);
      `baseline-verify` (netzlos, `sha256sum -c` **plus** Vollständigkeits-Check,
      kein `curl`/`unzip`) ist Prerequisite von `gates`. **Beide** Manipulations-Arten
      real vorgeführt: geänderte Datei **und** zusätzlich eingelegte Datei schlagen
      **rot** aus ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] Der Tag-String hat **genau eine** Quelle (`BASELINE_TAG` im `Makefile`); kein
      zweiter Literal-`v3.1.0` in Mechanik-Dateien (Injektor, `.d-check.yml`) — per
      `grep` belegt. Doku-Erwähnungen sind davon ausgenommen (s. §6).
- [ ] Injektor (`harness/tools/sessionstart-inject-regelwerk.sh`) liest den Index
      unter `$(BASELINE_TAG)/regelwerk/README.md`; `test/sessionstart.bats`
      auf den neuen Pfad nachgezogen und grün.
- [ ] `harness/README.md` §Sensors und `AGENTS.md` §4 führen `baseline-verify` — die
      beiden einzigen kanonischen „welche Gates laufen"-Tabellen des Repos. Ein
      `gates`-Prerequisite, das dort fehlt, ist ein Gate, das die Doku nicht kennt.
- [ ] `.gitignore` (`.harness/cache/`-Block entfällt) und `.d-check.yml`
      (`scan.ignore`: `.harness/cache/**` → `.harness/baseline/**`) nachgezogen;
      `make docs-check` grün **mit** dem committeten Baum (er trägt fremde
      MR-/ADR-Kennungen, die sonst die `ids`-Link-Pflicht treffen).
- [ ] Neuer Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer
      nach [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)) trägt die Vendoring-Mechanik und **alle vier Setzungen
      wörtlich** (Formulierung siehe §6 — die Setzung lebt im MR-Eintrag, nicht in
      diesem Slice, der nach `done/` ins Archiv geht):
      1. **Provenienz-Anker:** ZIP-sha256 des Release-Assets (Upstream-Kette),
         getrennt von der lokalen Integrität;
      2. **`SHA256SUMS`-Umfang:** alle 42 Dateien beider Bäume, Pfade relativ zu
         `<tag>/`, die Datei selbst ausgenommen (ihre Integrität trägt git);
      3. **`<tag>`-Politik:** ein Tag zur Zeit (Ersetzen), Historie in git,
         Tag-String einzig in `BASELINE_TAG`;
      4. **Drift-Sensor:** `regelwerk-check` bleibt + Auflösungs-Trigger.
      [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) und der Cache-Teil von [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) als Historie markiert
      (nicht überschrieben).
- [ ] `AGENTS.md` §1 + `CLAUDE.md` beschreiben die vendored Form (Pfad, netzlos,
      Index + Modul on-demand); „gitignored", „kein committeter Fremd-Blob",
      „`make regelwerk-fetch` ausführen" und „wortgleich" entfallen dort.
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v3.1.0/` | neu | Vendored Baseline (Regelwerk + Templates parallel, 42 Dateien) + `SHA256SUMS` |
| `Makefile` | update | `BASELINE_TAG` als einzige Tag-Quelle; `regelwerk-fetch` raus, `regelwerk-check` umgebogen; netzloses `baseline-verify` in `gates` |
| `harness/tools/sessionstart-inject-regelwerk.sh` | update | Index-Pfad aus `BASELINE_TAG` abgeleitet (kein Tag-Literal) |
| `test/sessionstart.bats` | update | Pfad + Warn-Pfad (fehlende Baseline) |
| `.gitignore` | update | `.harness/cache/`-Block entfällt (Cache obsolet) |
| `.d-check.yml` | update | `scan.ignore` auf `.harness/baseline/**` |
| `harness/conventions.md` | update | neuer MR-Eintrag; [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)/[`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) als Historie |
| `AGENTS.md` (§1), `CLAUDE.md` | update | Mechanik-Absätze auf die vendored Form |
| `harness/README.md` (§Sensors), `AGENTS.md` (§4 Quality Gates) | update | die beiden kanonischen Gate-Aufzählungen bekommen `baseline-verify` — sonst ist ein `gates`-Prerequisite dort nicht geführt |

## 4. Trigger

Sofort startbar — reine Harness-Mechanik, unabhängig vom Go-CLI. Setzt nichts
voraus außer dem verifizierten ZIP.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Drift-Sensor bleibt — Kurskorrektur gegenüber dem ersten Entwurf.** Der Slice
  wollte `regelwerk-check` mitstreichen und die Drift-Blindheit als „bewusste
  Reduktion" tragen. Dagegen spricht ein **gemessener** Befund: v3.1.0 erschien am
  2026-07-17 um 03:54 UTC, **neun Stunden** nach v3.0.0 — und das Repo hat es nicht
  bemerkt, weil sein einziger Sensor auf v1.2.0 gepinnt ist. Die Reduktion wäre
  nicht theoretisch, sie hätte sich am Tag des Vendorings materialisiert.
  `regelwerk-check` läuft als Maintenance-Target **nicht in `gates`** und verletzt
  offline-grün also nicht; ihn zu behalten kostet nichts und liefert genau den
  **Auflösungs-Trigger**, den der MR-Eintrag ohnehin braucht. `baseline-verify`
  (Integrität, netzlos, in `gates`) und `regelwerk-check` (Drift, Netz,
  Maintenance) sind komplementär, nicht redundant.
- **Doku-Gate gegen den committeten Baum.** Der vendored Baum trägt fremde
  MR-/ADR-Kennungen (Kurs-eigene Beispiele, nicht die des Repos — 18 Treffer in
  6 Dateien, gegen v3.1.0 verifiziert: u. a. `regelwerk/modul-02:153,216`,
  `modul-08:82`, `modul-13:143` — die Zeilennummern gelten in v3.1.0 unverändert).
  Ohne `.harness/baseline/**` in `scan.ignore` färbt `make docs-check` rot — vor dem
  Commit verifizieren, nicht danach. Ein gitignorierter Cache war nie im
  Scan-Bereich; ein committeter Blob ist es. **Präzisierung:** betroffen ist
  praktisch nur `regelwerk/` — die Treffer unter `templates/` liegen sämtlich in
  `*.template.md`, das `scan.ignore` bereits heute ausnimmt.
- **`SHA256SUMS`-Umfang ist eine Repo-Setzung, keine Vorgabe** — Wortlaut für den
  MR-Eintrag. Die Baseline sagt nur *dass* die Datei existiert; Format, Umfang und
  Erzeugung sind unspezifiziert, und das ZIP liefert **keine** mit. Setzung:
  `sha256sum` über alle **42** Dateien beider Bäume, Pfade relativ zu `<tag>/`, die
  Datei selbst ausgenommen (sie kann sich nicht selbst hashen — ihre Integrität
  trägt git). **Nicht ausreichend allein:** `sha256sum -c` prüft nur, was *gelistet*
  ist, und bleibt bei einer **zusätzlich eingelegten** Datei grün. Die DoD verspricht
  aber „schlägt bei manipulierter Arbeitskopie rot aus" — das gilt sonst nur für
  Änderung und Löschung. `baseline-verify` braucht deshalb einen
  **Vollständigkeits-Check** (Dateizahl bzw. „keine ungelisteten Pfade unter
  `<tag>/`"), sonst ist „prüft die Integrität" überdehnt.
- **Provenienz ≠ Integrität — beide gehören in den MR-Eintrag.** `SHA256SUMS` ist
  **selbst erzeugt**: es beweist, dass der Baum sich seit dem Vendoring nicht bewegt
  hat, **nicht**, dass er je vom offiziellen Release stammt. Diese Kette hängt allein
  an der ZIP-sha256 (`bd90c721…0220`) — und die steht heute nur in diesem Slice, der
  nach `done/` ins Archiv wandert. Der MR-Eintrag trägt beide: ZIP-sha256 als
  **Upstream-Provenienz**, `SHA256SUMS` als **lokale Integrität**.
- **`<tag>`-Politik ist eine Repo-Setzung** — Wortlaut für den MR-Eintrag. Das
  Regelwerk sagt zu alten `<tag>`-Verzeichnissen nichts (Koexistenz vs. Ersetzen).
  Setzung: ein Tag zur Zeit (**Ersetzen**), Historie liegt in git. **Folge, die die
  Setzung mitträgt:** der Tag steht im Pfad, also würde er ohne Gegenmaßnahme in
  `Makefile`, Injektor, `.d-check.yml`, `AGENTS.md` und `CLAUDE.md` gleichzeitig
  stehen — jeder Bump wäre ein repo-weiter Grep, also genau die Maintenance, die
  dieser Slice loswerden will. Deshalb: **eine** Quelle (`BASELINE_TAG` im
  `Makefile`), Mechanik leitet ab. Dass Tag-Churn hier schnell ist, ist gemessen:
  v3.0.0 → v3.1.0 in neun Stunden, und die Mehrheit dieses Releases ist, dass der
  Kurs seine **eigenen** Tag-Links nachzieht — **150 von 193 geänderten Zeilen (77 %)**
  sind reine `blob/v3.0.0/` → `blob/v3.1.0/`-Bumps. Die restlichen 43 Zeilen (22 %)
  sind inhaltlich (u. a. ein neuer Absatz „**Vendored gelesen?**" in
  `regelwerk/README.md`) — v3.1.0 ist **kein** reines Re-Pin-Release, nur
  überwiegend eines.
- **~241 KB committeter Fremd-Blob** (gemessen: 167 KB `regelwerk/` + 74 KB
  `templates/`). Bewusst: `AGENTS.md` §1 verbot das bisher ausdrücklich. Der Gewinn
  ist netzlose Präsenz auf jedem Checkout und der Wegfall der
  Host-`unzip`-Abhängigkeit — beides zahlt auf
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ein. **Präzisierung:** `curl` bleibt
  Maintenance-Abhängigkeit, weil `regelwerk-check` bleibt — nur `unzip` entfällt.
- **Presence-Garantie unverändert schwach (Codex).** Index-only-Inject bleibt wie
  in [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis); v3.1.0 deckt read-on-demand ausdrücklich („ohne das ganze
  Regelwerk im Kontext zu halten", `modul-02:180`). Kein Gate-Verlust, kein
  neuer Tradeoff.
- **Größe: bewusst nicht geschnitten (Nutzer-Entscheidung 2026-07-17).** Dieser Slice
  trägt **9** DoD-Häkchen und berührt Daten, Build, Tooling, Test, Gate-Config und
  Doku. Ein Review am 2026-07-17 meldete das als HIGH gegen den v3.1.0-Regeltext
  („**Zu groß**, wenn eines zutrifft: mehr als drei DoD-Punkte · mehrere Schichten
  betroffen · nicht in *einer* Review-Sitzung prüfbar", `modul-05:71-73`) — der
  Befund ist **berechtigt und wird bewusst getragen**. Begründung: derselbe Modul-5-Text
  verlangt „**Schnitt nach Lieferwert, nicht nach Schichten**" und nennt
  Schicht-Schnitte ausdrücklich zombie-erzeugend („voneinander abhängige, einzeln
  nutzlose Zombie-Slices", `modul-05:75-77`). Dieser Slice liefert **einen** Wert —
  die Baseline ist netzlos präsent und verifiziert. Jeder denkbare Schnitt wäre ein
  Schicht-Schnitt (vendorter Baum ohne umgestellten Injektor = halb-migriertes Repo,
  einzeln nicht lieferbar) und bräche damit die **unstrittige** Regel, um die
  **strittige** zu erfüllen. Das ist der schlechtere Tausch.
- **Offen (nicht hier lösbar): zählt die Regel Häkchen oder Verhaltens-Zusagen?**
  Der Befund oben *illustriert* die Frage, statt sie zu beantworten. In v3.1.0 ist
  sie **nicht** entscheidbar — der Text, der die Einheit definierte
  (`SL-014`-Worked-Example), ist mit der Entdidaktisierung entfallen, und die
  Vorlage liefert selbst 5 Checkboxen gegen eine ≤3-Regel. Gehört geklärt, bevor
  irgendein Slice **auf die Zahl hin** geschnitten wird — Herleitung und Belege in
  slice-013 §6.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`harness/tools/`, die `.codex/`-Injektion, `Makefile`/Gate-Config und die Doku
teilen die adoptierte Harness-Mechanik ([`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor), [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)); GF (Doc führt).
Der vendored Baum selbst ist **kein** zu reifendes Artefakt — Modul 2 hält
ausdrücklich fest: „vendored Baseline + Tooling tragen keine Phase-Reife".

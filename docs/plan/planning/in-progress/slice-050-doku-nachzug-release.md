# Slice slice-050: Doku-Nachzug zum ersten Release (M5 Schritt 2)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Release-Weg — Präzedenz slice-026/027/043/047/048/049 für Arbeit ohne Welle).

**Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Plattform-Matrix — **unverändert**, dieser Slice
beschreibt nur, was sie schon fordert), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (CI/Release-Workflow), [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) (Commit-Trennung um das Lastenheft).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-26.

---

## 1. Ziel

[`README.md`](../../../../README.md) und das [Benutzerhandbuch](../../../user/benutzerhandbuch.md) sagen die Wahrheit über den
Auslieferungsweg: **vorgefertigte Binaries für die sechs Plattformen sind der empfohlene Weg**, der
Bau aus dem Quellcode bleibt der zweite (er ist der einzige Weg für ungetaggte Stände). Vier
gemessene Aussagen, die das Gegenteil behaupten, fallen — und zwar **erst dann, wenn das Release
existiert**, nicht vorher.

## 2. Definition of Done

- [ ] **Die vier gemessenen Falschaussagen sind weg** (Fundstellen und Kommando in §3):
  [`README.md`](../../../../README.md) Zeile 41 („Fertige Binaries gibt es noch nicht") und Zeile 48 („Was heute noch
  fehlt: vorgefertigte Release-Binaries"), [Benutzerhandbuch](../../../user/benutzerhandbuch.md) Zeile 4
  („Noch keine vorgefertigten Release-Binaries") und Zeile 63 („Es gibt derzeit **noch keine**
  vorgefertigten Download-Binaries"). **Prüfbar:** das §3-Kommando liefert danach keinen Treffer
  mehr, der einen fehlenden Release behauptet.
- [ ] **Der Installations-Abschnitt trägt den Download-Weg als ersten Weg**
  ([Benutzerhandbuch](../../../user/benutzerhandbuch.md) §2 „Das Werkzeug bereitstellen"), mit den **sechs Asset-Namen
  exakt so, wie der Workflow sie erzeugt** — Quelle ist die `matrix`-Liste in
  [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml), nicht die plausible Form. Der Bau aus Quelle bleibt
  **erhalten** (kein Ersatz): ohne Tag gibt es kein Asset.
- [ ] **Keine Zusage vor ihrem Beleg** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): kein Satz behauptet einen Release,
  den es nicht gibt. Die Aussagen sind auf `ab v0.1.0` bezogen formuliert, und der Slice
  **schließt erst, wenn der Tag steht** (§5). Das Gegenbeispiel ist benannt: ein Leser, der die
  Doku des getaggten Standes liest und keinen Download findet.
- [ ] **Handbuch-Kopf `Software-Stand`** von „Entwicklungsstand M4" auf den veröffentlichten Stand
  gezogen (M5 erreicht, `v0.1.0`).
- [ ] **`spec/lastenheft.md` unberührt — über die Commits DIESES Slice** (`63236d3..321b849`),
  belegt per `git diff 63236d3..321b849 -- spec/lastenheft.md` (leer). **Range ausdrücklich
  benannt** (Review-Runde-3-Befund INFO-1): seit `30f0fcd` liegt ein **Change-Request-Commit** am
  Lastenheft im Repo — eine Nutzer-Entscheidung, kein Slice-Commit. Genau diese Unterscheidung
  macht [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 lesbar; ohne die Range wäre die DoD-Aussage mehrdeutig.
  [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ändert sich **nicht**: die Anforderung (sechs Kombinationen) und ihre
  Messmethode stehen seit 0.13.0 fest; dieser Slice beschreibt sie nur in Nutzer-Sprache. Wäre eine
  Lastenheft-Änderung nötig, ist das ein **eigener CR** ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)), kein Nebeneffekt.
- [ ] **Tag `v0.1.0` gesetzt, `release`-Lauf grün über alle acht Jobs**, und das Release trägt
  **sechs** Assets — **gezählt, nicht angenommen**.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-26, live — Kommando neben der Aussage; die slice-049-Lehre, dass eine
Ist-Behauptung ohne ihren Messbefehl viermal fiel):**

Kommando:
`grep -n "Fertige Binaries\|vorgefertigte\|Entwicklungsstand M4\|noch keine" README.md docs/user/benutzerhandbuch.md`

Ergebnis: **vier** Treffer, alle in §2 benannt. Weitere Stellen gibt es nicht — insbesondere
enthält der Rest des Handbuchs keine zweite Installations-Beschreibung.

- **Asset-Namen** (aus der `matrix` in [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml), sechs Einträge):
  `ai-harness-init-linux-amd64` · `ai-harness-init-linux-arm64` · `ai-harness-init-darwin-amd64` ·
  `ai-harness-init-darwin-arm64` · `ai-harness-init-windows-amd64.exe` ·
  `ai-harness-init-windows-arm64.exe`.
- **Release-Pfad ist bewiesen, nicht der Meilenstein:** die `v0.1.0-RC`-Probe lief grün über alle
  acht Jobs (Bau, sechs Plattform-Start-Smokes, `publish`); das Prerelease wurde danach entfernt
  ([slice-048](../done/slice-048-release-artefakte.md) §Nachtrag). `git tag` ist **leer** — es gibt noch keinen Tag.
- **`publish` feuert nur auf einem Tag-Push** (Bedingung `github.event_name == 'push'` **und**
  `refs/tags/`-Präfix) — ein `workflow_dispatch` veröffentlicht bewusst nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`README.md`](../../../../README.md) | update | zwei Aussagen (Zeile 41, 48); Download als empfohlener Weg, Bau aus Quelle bleibt |
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) | update | Kopf-`Software-Stand` (Zeile 4), §2 „Das Werkzeug bereitstellen" (Zeile 63 ff.) inkl. der sechs Asset-Namen |
| [`roadmap.md`](../in-progress/roadmap.md) | update | M5 auf **erreicht** setzen, Schritte 2/3 abhaken (Closure-Schritt) |
| `spec/lastenheft.md` | **unberührt** | [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ist unverändert; eine Änderung wäre ein eigener CR |

**Reihenfolge (bewusst gewählt, s. §6):** (1) Doku-Änderung committen — der Tag wird **aus diesem
Commit** geschnitten, damit der veröffentlichte Stand die richtige Doku trägt. (2) Tag `v0.1.0`
pushen, `release`-Lauf beobachten. (3) Assets zählen. (4) Roadmap fortschreiben, Closure.

## 4. Trigger

**`open` → `in-progress` (Implementer beginnt):** M5 Schritt 1 ist erledigt —
[slice-049](../done/slice-049-baseline-bump-v3.5.2.md) hat die Baseline auf `v3.5.2` gezogen und ist am 2026-07-26 geschlossen
(`baseline-freshness` Exit 0). Keine aktive Welle, kein Vorgänger blockiert.

**Kopplung an Schritt 3, ausdrücklich benannt statt versteckt.** Der Doku-Nachzug und der Tag sind
**nicht trennbar, ohne [`AGENTS.md`](../../../../AGENTS.md) §3.6 zu brechen**: die Doku-Änderung *ist* die Zusage „es
gibt vorgefertigte Binaries", und die ist erst wahr, wenn das Release existiert. Darum trägt dieser
Slice den Tag in seinem Closure-Trigger, statt ihn einem Folge-Slice zuzuschieben. Der umgekehrte
Schnitt (erst taggen, dann Doku) wäre schlechter: der veröffentlichte Stand enthielte dann eine
Doku, die ihren eigenen Release verneint.

Rückführungen:

- `in-progress` → `open`: falls der `release`-Lauf auf dem echten Tag rot wird (die RC-Probe war
  grün, aber ein `publish` auf einem echten Tag ist damit **nicht** belegt — nur der Weg dorthin),
  oder falls der Nutzer die Trennung von Doku und Tag ausdrücklich will (dann ist der Tag ein
  eigener Vorgang mit eigenem Trigger, und die Doku-Formulierung muss auf „geplant" zurück).
- `in-progress` → `next`: falls der Installations-Abschnitt mehr wird als ein Weg-Nachtrag (z. B.
  Prüfsummen-Verifikation der Assets als eigener Vertrag) — dann zerlegen.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` grün; **Tag `v0.1.0` gepusht, `release`-Lauf grün über alle acht Jobs, sechs Assets am
Release gezählt**; Roadmap-M5 auf **erreicht**; Slice per `git mv` nach `done/` (eigener
Move-Commit, Link-Reconciliation im Folge-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Das eigentliche Risiko ist eine Zusage ohne Beleg.** Die Doku-Änderung behauptet einen
  Download-Weg. Zwischen Doku-Commit und Tag-Push ist sie unwahr. Das Fenster ist unvermeidbar (der
  Tag *muss* aus dem korrigierten Commit geschnitten werden, sonst ist der veröffentlichte Stand
  falsch) — es gehört **benannt**, nicht wegdefiniert, und es ist der Grund, warum der Tag im
  Closure-Trigger steht.
- **Ein grüner RC belegt kein grünes `publish`.** Der `publish`-Job feuert nur auf einem Tag-Push;
  die RC-Probe hat ihn real durchlaufen, aber ein Fehlschlag auf dem echten Tag ist möglich
  (Rechte, Release-Notes, Asset-Kollision). Rückführung in §4.
- **Ein Tag ist nach außen wirkend und schlecht umkehrbar.** Er ist eine bewusste Nutzer-Operation;
  ein zurückgezogener Release hinterlässt Spuren. Vor dem Push ist die Zustimmung einzuholen.
- **Die Asset-Namen dürfen nicht aus dem Gedächtnis kommen.** Sie stehen in der `matrix` von
  [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) und sind von dort zu übernehmen — die Klasse „plausible Form
  statt gemessener Form" hat dieses Repo schon einen halluzinierten Aufruf im README gekostet.
- **`docs/user/` ist Nutzer-Doku, nicht Prozess-Doku.** Slice-/Welle-IDs gehören dort nicht hinein
  (dieselbe Trennlinie wie beim README: Fähigkeit ins Nutzer-Dokument, Planungszustand in die
  Roadmap).

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

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als **Greenfield** —
Doc führt, Code folgt. Die berührte Sub-Area *Nutzer-Dokumentation* ([`README.md`](../../../../README.md) +
[`docs/user/`](../../../user/benutzerhandbuch.md)) erfüllt das Inklusionskriterium (eigene Zielgruppe · eigene Sprache · eigener
Änderungs-Rhythmus) und trägt keine BF-Altlast: beide Dateien sind in diesem Repo entstanden und
vollständig bekannt.

Der Vollblock entfällt damit laut Template. **Eine Anmerkung ist trotzdem nötig:** der Slice hat
neben der Doku eine **nach außen wirkende** Achse (der Tag). Sie ist kein Sub-Area-Modus-Thema,
sondern eine Freigabe-Frage — sie steht in §4 und §6.

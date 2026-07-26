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

- [x] **Die vier gemessenen Falschaussagen sind weg** (Fundstellen und Kommando in §3):
  [`README.md`](../../../../README.md) Zeile 41 („Fertige Binaries gibt es noch nicht") und Zeile 48 („Was heute noch
  fehlt: vorgefertigte Release-Binaries"), [Benutzerhandbuch](../../../user/benutzerhandbuch.md) Zeile 4
  („Noch keine vorgefertigten Release-Binaries") und Zeile 63 („Es gibt derzeit **noch keine**
  vorgefertigten Download-Binaries"). **Prüfbar:** das §3-Kommando liefert danach keinen Treffer
  mehr, der einen fehlenden Release behauptet.
- [x] **Der Installations-Abschnitt trägt den Download-Weg als ersten Weg**
  ([Benutzerhandbuch](../../../user/benutzerhandbuch.md) §2 „Das Werkzeug bereitstellen"), mit den **sechs Asset-Namen
  exakt so, wie der Workflow sie erzeugt** — Quelle ist die `matrix`-Liste in
  [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml), nicht die plausible Form. Der Bau aus Quelle bleibt
  **erhalten** (kein Ersatz): ohne Tag gibt es kein Asset.
- [ ] **Keine Zusage vor ihrem Beleg** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): kein Satz behauptet einen Release,
  den es nicht gibt. Die Aussagen sind auf `ab v0.1.0` bezogen formuliert, und der Slice
  **schließt erst, wenn der Tag steht** (§5). Das Gegenbeispiel ist benannt: ein Leser, der die
  Doku des getaggten Standes liest und keinen Download findet.
  **BEWUSST NICHT ABGEHAKT** — Verifikation (Modul 11): **TEILWEISE**. Die Zusage hält auf `main`
  überall, aber **das hier selbst benannte Gegenbeispiel ist im veröffentlichten Tag rot**:
  `git show v0.1.0:docs/user/benutzerhandbuch.md` trägt „Gibt es ein fertiges Download-Binary? —
  Derzeit nicht" und „keine Release-Versionsnummer". Ein `[x]` wäre hier genau das stille Grün,
  gegen das dieser Punkt geschrieben ist. Einordnung, Ursache und Folge-Weg: §7 (A-1).
- [x] **Handbuch-Kopf `Software-Stand`** von „Entwicklungsstand M4" auf den veröffentlichten Stand
  gezogen (M5 erreicht, `v0.1.0`).
- [x] **Kein Commit DIESES Slice ändert `spec/lastenheft.md`.** Geprüft wird die **volle**
  Slice-Range bis zum Closure-Stand, nicht ein eingefrorener Ausschnitt (Runde-5-Befund T-2), und
  die Aussage gilt **nur für diesen Slice** — sie ist **kein** Allquantor über die Repo-Historie
  (Runde-5-Befund T-1: `7b717f4` ist ein Slice-Commit an `spec/lastenheft.md`, von
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Ist-Messung selbst gelistet — genau deshalb entstand die Setzung).
  **Messbefehl statt Zahl** (Runde-4-Befund S-2):
  `git log --format='%h %s' 63236d3..HEAD -- spec/lastenheft.md` listet **ausschließlich**
  `spec:`-Commits, die Nutzer-Entscheidungen tragen (Change Requests bzw. deren Korrekturen) —
  kein `impl:`/`fix:`/`close:`-Commit dieses Slice. Genau diese Unterscheidung macht
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 nachträglich lesbar.
  [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ändert sich **nicht**: die Anforderung (sechs Kombinationen) und ihre
  Messmethode stehen seit 0.13.0 fest; dieser Slice beschreibt sie nur in Nutzer-Sprache. Wäre eine
  Lastenheft-Änderung nötig, ist das ein **eigener CR** ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)), kein Nebeneffekt.
- [x] **Tag `v0.1.0` gesetzt, `release`-Lauf grün über alle acht Jobs**, und das Release trägt
  **sechs** Assets — **gezählt, nicht angenommen**.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
  ([slice-048](slice-048-release-artefakte.md) §Nachtrag). `git tag` ist **leer** — es gibt noch keinen Tag.
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
[slice-049](slice-049-baseline-bump-v3.5.2.md) hat die Baseline auf `v3.5.2` gezogen und ist am 2026-07-26 geschlossen
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

**Was hat funktioniert.** Der Release-Weg selbst lief ohne Reibung: Tag aus dem korrigierten Commit
geschnitten, `release`-Lauf **8/8 Jobs grün**, **sechs** Assets — und die Asset-Namen sind nicht
behauptet, sondern dreifach maschinell gleichgesetzt (`matrix` in
[`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) ↔ Handbuch-Tabelle ↔ `gh release view`, symmetrische
Differenz leer; vom Verifier unabhängig wiederholt). [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ist damit erstmals real
eingelöst. Die **Kopplung von Doku und Tag** in einem Slice (§4) hat sich bewährt: der
veröffentlichte Stand trägt die korrigierte Installations-Anleitung, weil der Tag aus ihr
geschnitten wurde — die umgekehrte Reihenfolge hätte ein Release ausgeliefert, das seinen eigenen
Download-Weg verneint.

**Was anders lief als geplant — und es ist das Eigentliche.** Der Slice brauchte **fünf
Review-Runden** für einen Doku-Nachzug. Kein einziger Befund traf die Doku-*Absicht*; **alle**
trafen **Ist-Aussagen über einen Zustand**, und zwar immer nach demselben Muster: eine Behauptung
greift weiter als das, was gemessen wurde. Die Klasse ist dieselbe wie in
[slice-049](slice-049-baseline-bump-v3.5.2.md) — aber sie ist **gewandert**, und die Wanderung ist der Befund:

| Runde | Ort der Aussage | Was zu weit griff |
|---|---|---|
| 1 | Slice-Plan §3 | „Weitere Stellen gibt es nicht" — die FAQ war nicht im Suchmuster, und sie ging **mit ins Release** |
| 1 | eigener Ehrlichkeits-Kasten im Handbuch | „bei jedem Release auf Linux" — der Voll-Smoke hängt am Push, nicht am Release, und nur an amd64 |
| 2 | `README.md` | dritte kuratierte Gate-Liste, fünf von sieben Prerequisites |
| 3 | **`spec/lastenheft.md`** | „es genügt, den Voll-Smoke auf einem Linux-ARM-Runner zu fahren" — das gepinnte d-check-Image ist Single-Arch-`amd64` |
| 3–5 | **Release-Text (git-extern)** | zweimal eine *entlastende* Zusage über eine Menge, die nicht vollständig gemessen war |
| 5 | die **DoD** selbst | „jeder Lastenheft-Commit … keine Slice-Commits" — `7b717f4` widerlegt es, und [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) listet ihn selbst |

Jede Station liegt **weiter außerhalb** dessen, was [`AGENTS.md`](../../../../AGENTS.md) §3.6 aufzählt und `make mutate`
erreicht: Plan-Prosa → Nutzer-Doku → `README` → `spec/` (rank 1!) → **git-extern**. Der Durchbruch
kam in Runde 4/5 nicht durch eine bessere Formulierung, sondern durch einen **Bauform-Wechsel**:
statt einer Aufzählung, die vollständig sein müsste, trägt die Aussage jetzt **den Befehl, der sie
misst** — im Release-Text (`git diff v0.1.0 origin/main -- '*.md'`) und in der DoD
(`git log … -- spec/lastenheft.md`). Eine dritte, engere Aufzählung wäre derselbe Fehler mit
kleinerem Radius gewesen.

**Abweichungen, die mit in `done/` gehen** (kein stilles Grün):

- **A-1 — DoD-Punkt 3 ist NICHT abgehakt.** Das dort selbst benannte Gegenbeispiel ist im
  veröffentlichten Tag rot: `v0.1.0` trägt in FAQ und Anhang zwei Sätze, die den Release verneinen.
  Ursache ist der gebrochene Plan-Allquantor aus Runde 1. **Offengelegt** im Release-Text (mit
  Messbefehl), **nicht** im Tag reparierbar ohne Force. Folge-Weg: ein `v0.1.1` zieht es mit, oder
  ein Sensor prüft **vor** dem Tag. Beides ist ein eigener Vorgang mit eigenem Trigger.
- **A-2 — Push vor der Closure.** Der Verifier maß `origin/main` drei Commits hinter `HEAD`; **kein
  CI-Lauf hatte den Prüfstand gesehen**. Er hat die Lücke selbst geschlossen (`make gates` und
  `make full-smoke`, beide Exit 0). Lehre: in diesem Repo pusht **nichts automatisch** — eine
  frühere Annahme des Gegenteils war falsch und ist korrigiert.
- **A-3 — der DoD-Messbefehl misst schwächer als die Eigenschaft.** Er klassifiziert Commits über
  ihr **Präfix** (`spec:`), also über eine Selbstauskunft. Der Verifier hat die stärkere Messung
  nachgezogen (`git log --name-only` über alle Commits). Gehört zu [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Durchsetzung.
- **A-4 — [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) hat keine Regel für CRs, die aus dem Review eines LAUFENDEN Slice
  entstehen.** Setzung 2 ordnet den CR *vor* den umsetzenden Slice; hier entstand er **mitten
  darin** (aus Befund N-2). Kein Verstoß — die Ordnungs-Klausel greift ins Leere. Die Setzung
  braucht diesen Fall.

**Steering-Loop-Eintrag** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **[`AGENTS.md`](../../../../AGENTS.md) §3.6 schärfen — dieselbe Forderung wie in [slice-049](slice-049-baseline-bump-v3.5.2.md), jetzt mit dem
  Beweis, dass sie nicht reicht.** slice-049 schlug vor: *ein Allquantor über einen Repo-Zustand
  trägt den Befehl, der ihn misst, neben sich.* Dieser Slice hat den Vorschlag **fünfmal gebrochen,
  während er notiert war** — Feedforward ohne Feedback verfällt nicht später, sondern sofort. Die
  Träger-Liste braucht zusätzlich `spec/` und **veröffentlichte Artefakte außerhalb von git**.
- **Der Sensor-Kandidat bekommt eine Achse, die er nicht hatte.** *Regeln ohne Feedback-Quadrant
  schließen* führt bisher nur Repo-interne Regeln. Der Release-Text zeigt: ein Artefakt kann
  **veröffentlicht und unbewacht** sein. Kein Gate dieses Repos erreicht ihn — er wurde viermal
  überarbeitet, jedes Mal von einem Menschen bzw. Reviewer gefunden.
- **Ein Sensor VOR dem Tag ist der eigentliche Hebel.** A-1 wäre durch nichts anderes verhindert
  worden: der Tag ist der Moment, in dem Doku-Fehler unumkehrbar werden. Ein Check, der vor dem
  Tag-Push die Aussagen der Nutzer-Doku gegen den Ist-Zustand hält, hätte alle vier Runde-1-Befunde
  gefangen.

**Folge-Kandidaten** (nicht geschnitten — cp-Disziplin): `v0.1.1` mit dem Doku-Nachzug im Tag ·
Sensor vor dem Tag-Push · [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) um den Mid-Slice-CR-Fall ergänzen (A-4) · die
Präfix-Schwäche des Commit-Klassifikators (A-3).

**Review und Verifikation.** Fünf Review-Runden; **Runde 5: KONFORM** (0 HIGH, 0 MEDIUM, 4 LOW,
2 INFO), die LOWs danach aufgelöst. Verifikation: **DoD TEILWEISE BESTÄTIGT** — 7 von 8 Punkten
bestätigt mit eigenen Belegen, 0 × WIDERLEGT, Punkt 3 als A-1 offen. Der Verifier fuhr `make gates`
und `make full-smoke` selbst und bestätigte die Sensor-Auslassungen am realen Diff (10 Dateien,
ausnahmslos `.md`).

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

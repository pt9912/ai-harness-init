# Slice slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten: Ein Werkzeug hält alle sechs Träger-Pins nach der Publikation gegen die SHA256SUMS des Tags

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Pin ist die Quelle der Reproduzierbarkeit des Trägers),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die Zusage „Pin gegen Publikation gehalten" trägt einen Zahn an der realen Quelle),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) und [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (Pin und `SHA256SUMS` als Release-Asset).
Auslöser: Auftrag des Auftraggebers nach Verdikt V-1 ([`docs/reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md`](../../../reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md)).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-20.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make traeger-pins-check` holt die `SHA256SUMS` des Tags, paart je Plattform Dateiname und Digest und hält sie gegen alle sechs `TRAEGER_SHA256_*` des `Makefile` — heute hält `make traeger-fetch` nur die Plattform des Aufrufers, CI nur linux-amd64, die übrigen vier hält nichts (Verdikt V-1: vier Release-Schnitte in Folge fanden denselben Fund, die Prosa-Form ist ausgeschöpft).

**Ausgangslage (gemessen am Stand HEAD 0f5d67c0):** `Makefile` Zeilen 45–51 führen `TRAEGER_TAG` und sechs `TRAEGER_SHA256_*`; `docs/user/releasing.md` Schritt 2 sagt, `make traeger-fetch` belege „nach der Publikation" die Digests. Vor der Publikation existiert das Asset nicht; ein Vergleich vorher hielte den Pin gegen seine eigene Quelle.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein Vergleich Bau gegen Bau — das Werkzeug hält Pin gegen Publikation und sagt nichts über den Bau selbst; die Menge der Assets gegen die Prüfsummen hält `release-sums.sh verify` in Schritt 3 der Prozedur, Reproduzierbarkeit des Baus ist ein anderer Gegenstand.
- Kein Gate, nicht in `make gates` — er braucht Netz und eine Release-Lage, die ein frischer Klon nicht garantiert; Werkzeug im Stil von `make tap-check`, Bindepunkt ist die Prozedur.
- Keine Zeile in `AGENTS.md` §3.6 — Hard Rules schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und eine Zeile über einen laufenden Sensor entsteht erst nach dem Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.1). Übergabe unten.
- Kein Warte-Schritt und kein Pin-Schreibweg — ein fehlendes Asset endet mit Klasse 2 (nicht ausführbar), nicht mit Warten; das Warten im Worker liegt bei `slice-mutate-branch-worker-wartet-die-publikation-ab`, den Pin zieht Schritt 2 der Prozedur von Hand.
- Kein Eingriff in `traeger-fetch` — er hält weiter die Plattform des Aufrufers; der neue Lauf ergänzt ihn, ersetzt ihn nicht.

**Hinweis für den Architect (Übergabe-Artefakt).** Nach dem Lauf des Sensors am echten `v0.10.0` verlangt die Klasse eine Zeile in [`AGENTS.md`](../../../../AGENTS.md) §3.6 (viertes Falsch/Richtig-Paar, Unterklasse *Pin des realen `Makefile` nach der Publikation*: Sensor `make traeger-pins-check`, Grenze *kein Bau-gegen-Bau*, Wächter-Lage). Sie entsteht in einem **eigenen Architect-Commit** nach der Closure dieses Slice; der Slice schreibt sie nicht.

## 2. Definition of Done

- [x] **L1 — Werkzeug:** `make traeger-pins-check` (`TAG=<tag>`, Default `TRAEGER_TAG`) holt die `SHA256SUMS` über den Transport von `traeger-fetch` (gepinntes Bild, Netz an genau diesem Aufruf), paart je Plattform Dateiname und Digest und vergleicht gegen die sechs `TRAEGER_SHA256_*`. Exit des Skripts 0 gleich, 1 Unterschied (nennt die Plattform), 2 nicht ausführbar (auch: Asset nicht abrufbar, Zeile fehlt); über `make` endet jeder Fehlschlag mit 2, die Klasse des Skripts steht in der letzten stderr-Zeile `traeger-pins-check: Exit <N>` ([`AGENTS.md`](../../../../AGENTS.md) §3.6, letztes Paar — die Zusage ist an `make traeger-pins-check` gemessen).
- [x] **L2 — Wächter über der Paarung:** `test/traeger-pins-check.bats` hält Paarung (Name gegen Digest, nicht Position) und die drei Exit-Klassen über einer Fixture-`SHA256SUMS`; `test/mutations/<nächste freie Nummer>-traeger-pins-paarung-nach-position.sh` paart nach Zeilenposition statt Name und färbt den Test rot; `make mutate-greift` grün, `MUTATE_CASES=<Nr>` einmal rot gesehen. Die Zusage nennt, was sie hält: die Paarungs-Logik, **nicht** den realen Pin — den hält L3.
- [x] **L3 — Rot an der realen Quelle:** Lauf am echten Release `v0.10.0` unverfälscht Exit 0; in einem Probe-Klon eine **Nicht-Host-Plattform** des `Makefile` (nicht `darwin-arm64`) verfälscht, Lauf endet rot und nennt genau diese Plattform; beide Läufe samt Ausgabe in §7. Bindepunkt: `docs/user/releasing.md` nach Schritt 5 vor dem Bericht, Satz in Schritt 2 („belegt nach der Publikation `make traeger-fetch`") auf die Plattform des Aufrufers eingeschränkt, Zeile in der Werkzeuge-Tabelle von `harness/README.md` (`kein Gate`) und `harness/sensors/traeger-pins-check.md`. Der Rot-Beleg ist eine Handlung des Laufs, kein Sensor: kein Wächter hält den realen Lauf; Träger ist der Release-Schnitt, der die Prozedur fährt.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/traeger-pins-check.sh` | neu | Holen, Paaren, Vergleichen; Transport und Bild-Pin wie `traeger-fetch.sh` gelesen, nicht zweimal geführt — L1 |
| `Makefile` | update | Ziel `traeger-pins-check` mit Kommentarblock (Exit-Aussage am `make`-Aufruf), Skript in die `shell-lint`-Liste — L1 |
| `test/traeger-pins-check.bats` | neu | Paarung, Exit 0/1/2, Plattformname in der Meldung — L2 |
| `test/mutations/<nächste freie Nummer>-traeger-pins-paarung-nach-position.sh` | neu | Paarung nach Position, Test wird rot — L2 |
| `docs/user/releasing.md`, `harness/README.md`, `harness/sensors/traeger-pins-check.md` | update / update / neu | Bindepunkt, Werkzeuge-Zeile, Vertrag und Grenze — L3 |

## 4. Trigger

**Start** (`next` → `in-progress`): keine Abhängigkeit; Reihenfolge nach Auftraggeber: nach `slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen`, vor `slice-mutate-branch-worker-wartet-die-publikation-ab`.

**Rückführungen:**

- `in-progress` → `next`: der Transport verlangt einen Eingriff in `traeger-fetch.sh` über das Lesen seines Pins hinaus (dritte Schicht oder mehr als drei Liefer-Punkte).
- `in-progress` → `open`: die Assets von `v0.10.0` sind nicht abrufbar — der Rot-Beleg an der realen Quelle (L3) ist dann unmöglich; Trigger für die Wiederaufnahme ist der nächste veröffentlichte Tag.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review- und Verifier-Report liegen vor, Closure-Notiz mit Lerneintrag in Form eines neuen Sensors (Werkzeug); das Übergabe-Artefakt an den Architect (Zeile in `AGENTS.md` §3.6, §1) ist in §7 genannt.

## 6. Risiken und offene Punkte

- Der Rot-Beleg an `v0.10.0` hängt an Netz und an der Abrufbarkeit des Release — **Ausgang:** entfallen: Das Release ist der Pin-Gegenstand selbst (`TRAEGER_TAG`); wäre es nicht abrufbar, bräche `make traeger-fetch` und der Lauf wäre kein Slice mehr, sondern ein Rücksprung nach `open` (§4).
- Der Sensor deckt nur Pin gegen Publikation, nicht den Bau — **Ausgang:** entfallen: Die Grenze steht im Skriptkopf und im Sensor-Vertrag; Bau gegen Bau ist ausgeschlossen (§1), die Menge gegen die Prüfsummen hält Schritt 3 der Prozedur.
- Der Sensor läuft nur, wenn der Release-Schnitt ihn fährt (Werkzeug, kein Gate) — **Ausgang:** weiter offen → `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` im Register.

## 7. Closure-Notiz

- **Was hat funktioniert:** L1 gefahren (Implementer, Reviewer, Verifier je zweimal, an der **realen** Release `v0.10.0`). Grün: `make traeger-pins-check TAG=v0.10.0` →
  `traeger-pins-check: gleich — alle 6 Pins halten gegen die SHA256SUMS von v0.10.0.`, Prozess-Exit 0. Rot (L3): `TRAEGER_SHA256_WINDOWS_ARM64` auf `0…01` per Make-Variablen-Override
  (Nicht-Host-Plattform, `Makefile` unberührt) → `traeger-pins-check: TRAEGER_SHA256_WINDOWS_ARM64 weicht ab — Pin 0…01, SHA256SUMS von v0.10.0 fuehrt f87b07b4…1002 fuer
  ai-harness-init-windows-arm64.exe`, `Unterschied bei 1 von 6 Plattformen`, `traeger-pins-check: Exit 1`, `make: *** [traeger-pins-check] Error 1`, **Prozess-Exit von make 2**; nur
  diese Plattform genannt. Der Verifier fuhr zusätzlich `TRAEGER_SHA256_LINUX_ARM64` (genau diese genannt) und `TAG=v9.9.9` (404, `traeger-pins-check: Exit 2`). Die Exit-Zusage ist
  an `make` gemessen. L2 gelesen und gefahren: `make test-bats` 15/15; Brüche auf einer Kopie: Paarung nach Position färbt die Fälle 1, 2, 3, 4, 8, 9, 12, 15 rot (der gepinnte
  Fall 1 darunter), Abbruch nach dem ersten Unterschied färbt Fall 2 und 8; Fall 774 lokal rot gesehen. Mutations-CI-Probe (Nutzerfreigabe, Branch danach gelöscht): 53 Fälle,
  alle ok, Urteil grün, darunter 774 (Shard 9). Review: 0 HIGH, 1 MEDIUM, 0 LOW, 2 INFO ([Report](../../../reviews/2026-10-20-slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten.md));
  Verifier: L1 bis L3 bestätigt, Verdikt V-1 erfüllt ([Report](../../../reviews/2026-10-20-slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten-verify.md)).
  **Grenze, benannt:** gedeckt ist Pin gegen Publikation für `v0.10.0` am Tag der Messung; nicht gedeckt sind Bau gegen Bau, die Menge der Assets und ein Kanal, der Asset und
  `SHA256SUMS` gemeinsam ersetzt; den realen Pin hält allein der Lauf am Release-Schnitt, kein Wächter.
- **Was ging anders als geplant:** (1) L3 verfälschte den Pin per Make-Override statt in einem Probe-Klon; derselbe Wert erreicht das Skript, das `Makefile` blieb unberührt.
  (2) F-1 (MEDIUM): beim Einfügen des Targets entstand in der `.PHONY`-Zeile `tap-checktap-nachzug`; kein Gate war rot, der Reviewer fand es am Diff, der Implementer behob es
  (`ba67fcbd`). F-2 (INFO): der Test band die Exaktheit der Namens-Paarung nicht (`==` → `~` blieb grün); behoben durch einen Fall mit Fremd-Eintrag (`0779f3fc`). F-3 (INFO,
  Gegenprobe „nur der benannte Test" nicht gefahren): bleibt, der Fall-Kopf behauptet keine Exklusivität. (3) Prozessfehler des Implementers: Fall 774 einmal direkt im Arbeitsbaum
  gestartet, sofort wiederhergestellt; `git diff --stat 3ea59b26 HEAD` führt genau die neun erwarteten Dateien (Reviewer). (4) Verifier: Docker/colima teilt `/private/tmp` nicht; der
  erste Versuch dort lief gar nicht und wurde nicht als grün gewertet, die Brüche liefen auf einer Kopie unter `$HOME`.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** CI (`mutate-branch`, Linux-Runner, Image-Lage nicht erhoben): 53 Fälle, alle ok, Wanduhr 621 s. Ungemessen: Aufteilung
  auf die Shards und auf Vorlauf gegen Fälle, jede Deutung. Keine Deutung.
- **Steering-Loop-Eintrag:** **neuer Sensor** — `make traeger-pins-check` (Werkzeug, kein Gate; `harness/tools/traeger-pins-check.sh`, Vertrag `harness/sensors/traeger-pins-check.md`, Bindepunkt
  `docs/user/releasing.md` nach Schritt 5). Anlass ist die Prosa-Form, die über vier Release-Schnitte denselben Fund nicht hielt (Verdikt V-1). Kein `liegt in`-Feld: das Skript trägt keinen
  Herkunfts-Anker `seit slice-…`, die Anker-Paarung (a) wäre rot; der Anker entsteht mit der Zeile des Architects (Übergabe unten). Zweite benannte Lücke, ohne Sensor: ein
  Tippfehler in der `.PHONY`-Zeile (F-1) färbt kein Gate; ein Token-Abgleich gegen die Rezept-Namen ist baubar und nicht gebaut — Ort `BEO-ALL/phony-zeile-verschmilzt-zwei-targets-im-diff` (1×, offen).
- **Übergabe-Artefakt an den Architect (eigener Architect-Commit nach dieser Closure; der Slice schreibt sie nicht):** Zeile in [`AGENTS.md`](../../../../AGENTS.md) §3.6, viertes Falsch/Richtig-Paar,
  Unterklasse *Pin des realen `Makefile` nach der Publikation*: Sensor `make traeger-pins-check`; Zusage nennt, was sie hält — Pin gegen die `SHA256SUMS` des Tags für alle sechs Plattformen, Paarung
  nach Name (bats plus Mutations-Fall 774 über einer nachgebauten `SHA256SUMS`); **Grenze** kein Bau gegen Bau, nicht die Menge der Assets, den realen Pin hält allein der Lauf am Release-Schnitt;
  **Wächter-Lage:** keiner hält diesen Lauf, Träger ist der Release-Schnitt; Exit-Satz an `make` gemessen (Skript-Klasse in der Zeile `traeger-pins-check: Exit <N>`, make-Exit 2); Herkunft
  `· seit slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten`. Danach zieht die `state.md` von `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` die Unterklasse auf *verkörpert* (Planner).
- **Beobachtungs-Register (`../observations/`):** neu `BEO-ALL/mutations-fall-skript-direkt-im-arbeitsbaum-gestartet` (2×, offen; Belege dieser Slice und `slice-benutzerhandbuch-fuehrt-java-python-csharp`, dort nur in §7 benannt, hier
  nachgezogen), neu `BEO-ALL/phony-zeile-verschmilzt-zwei-targets-im-diff` (1×, offen); ergänzt `BEO-ALL/commit-message-datei-im-scratchpad-ist-fuer-den-docker-daemon-unsichtbar` (2×, offen; gleiche
  Ursache, anderer Verbraucher: Arbeitskopie statt Message-Datei). Fortgeschrieben ohne Beleg: `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` (11×, `state.md` nennt den Stand der Unterklasse):
  dieser Slice ist die Lieferung ihres Ausgangs, kein Auftreten. Zitiert ohne Beleg: `BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture` (1×; hier kein No-op-Aufruf, die Fixture-Grenze steht im Skriptkopf)
  und `BEO-ALL/pin-digest-ohne-waechter` (8×, kein Auftreten). Kein Eintrag erreicht 3×.
- **Folge-Slices:** keiner. Die Zeile in `AGENTS.md` ist Architect-Arbeit, kein Slice. `slice-mutate-branch-worker-wartet-die-publikation-ab` steht nur als Abgrenzung (§1, Warte-Schritt), sein Plan ist unberührt.
- **Trigger-Audit dieser Closure:** `CO-001` und `CO-002` unberührt; kein bootstrap-aware Gate berührt; keine ADR mit Re-Evaluierungs-Trigger berührt; Hard Rules tragen *permanent* oder ihren Trigger unverändert. Nichts fällig durch diesen Slice.
- **Archivierung ([`MR-078`](../../../../harness/conventions.md#mr-078)):** nicht ausgeführt: `ls docs/plan/planning/done/*/archiv.zip` findet keines, `archive-welle` bricht an der Untergrenze; der Slice bleibt flach in `done/`.
- **Risiken aus §6:** alle drei haben ihren Ausgang in §6. Risiko 1 (*entfallen*) hat sich bestätigt: `v0.10.0` war abrufbar, L3 lief. Risiko 3 (*weiter offen*): der Register-Eintrag steht, sein Stand für die Unterklasse ist *geplant* mit der Architect-Übergabe oben als Adresse, nicht *verkörpert*.
- **Drei Paarungen:** geprüft am 2026-10-20, nach dem `git mv`. (a) Anker: kein `liegt in`-Feld mit Zielort in §7, nichts zu prüfen. (b) Folge-Slice: keiner genannt; `slice-mutate-branch-worker-wartet-die-publikation-ab` steht nur als Abgrenzung (die Datei liegt in `open/`). (c) Register: die sechs genannten `BEO-ALL/`-Verzeichnisse existieren und tragen je ein nicht leeres `evidence/` (2, 1, 2, 11, 1 und 8 Belege); `make register-ausgang` → `273 Eintraege, 78 ueber der Schwelle, 0 Befund(e)`. Zweite Hälfte (c) über das ganze Register: ein Verzeichnis ohne Beleg, namentlich `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet, gehört nicht zu diesem Slice (Kommando: Schleife aus `docs/plan/planning/observations/README.md`).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`, die einzige deklarierte Sub-Area der Beobachtungen); sie erfüllt die Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`ls -d docs/plan/planning/observations/BEO-ALL/*/`, gelesen am Stand HEAD 0f5d67c0). Treffer: `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` (11 Belege, `verkörpert` — der Slice ist die benannte Unterklasse *Pin des realen `Makefile`*; sein Lauf-Zahn an der realen Quelle ist L3), `BEO-ALL/pin-digest-ohne-waechter` (8 Belege, `verkörpert`) und `BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture` (1 Beleg, `offen` — berührt der Slice einen weiteren Pin-Aufruf mit nachgebauter Fixture, ist der Zähler bei 2; L2 benennt die Fixture-Grenze am Ort). Kein Eintrag erreicht mit diesem Slice 3× neu.

alle berührten Sub-Areas GF


# Verifikation — slice-waechter-umgebungs-robustheit (welle-ohne-docker)

**Verifier-Lauf:** frisch, frischer Kontext (Review-Report gelesen, Rot-/Run-Belege eigen-händig)
**Code-Stand:** HEAD `0e2115cb` (main); Implementer-Diff `e3c4cfd2..ba3394c1` (4 Commits)
**Review:** `docs/reviews/2026-11-27-slice-waechter-umgebungs-robustheit.md` (`0e2115cb`, F-1/F-2 LOW, kein HIGH)
**Betriebsform:** docker-los am Host (Linux); alle Läufe über make-Ziele

---

## Urteile je DoD-Punkt (§2)

- **Liefer-Punkt 1 — Wächter-Setups tragen die Umgebung selbst: ERFÜLLT.**
  Bestand: `test/traeger-fetch.bats` und `test/traeger-fetch-host.bats` unseten die
  `TRAEGER_*`-Stellen im setup (`for v in TRAEGER_TAG … done`); `test/targets-modul-wiring.bats`
  fügt `LC_ALL=C` an den vier `sort`- und zwei `comm`-Stellen fest in der Datei ein.
  Rot-Beleg (Brechen an der realen Route, vom Verifier gefahren): im Klon
  `/tmp/vswr` die Setups des Wächters ihrer `unset`-Schleife entkleidet und über das
  make-Rezept (das `Makefile:61`-Export trägt den vollen Pin-Satz) gefahren:
  `make test-bats BATS_TARGET=test/traeger-fetch.bats` → **4 rot {3, 5, 7, 9}**, deckungsgleich
  mit Plan §3 Mess-Protokoll; Wächter-Zwilling im Klon `/tmp/vswr-b` gleicher Ausmerz →
  **5 rot** {happy im Manifest-Modus 2 · negative … 4 · fail-closed teilweise 5 · fehlender Tag 6 ·
  plattform-matrix 7} — dieselben Fälle, die Plan §3 unter den Sweep-Nummern {603, 605, 606, 607, 608} trägt
  (konstanter Offset 601, gleicher Fall-Namen-Satz). Grün nach der Restauration an HEAD:
  beide Wächter-Einzelläufe 0 rot (siehe Läufe unten).
- **Liefer-Punkt 2 — Einzellauf und Sweep liefern dieselbe Rot-Menge: ERFÜLLT** (Läufe L-1 … L-7,
  unten) — Einzelläufe der vier geänderten Wächter: 0 rot je Datei (targets 2× identisch grün);
  voller Sweep `make test-bats BATS_TARGET=test/`: **genau ein rot: Fall 273**
  (`ignore-refs-restbreite`) — derselbe Fall, den auch sein Einzellauf rot liefert, und
  der Plan §3 benannte Vorlauf-Stand, nicht aus dem Diff.
- **Liefer-Punkt 3 — Exit-Vertrag an beiden Wegen oder Grenze in der Sensors-Zelle: BESTÄTIGT
  in der gelesenen Form, MIT GRENZE.** Docker trägt auf diesem Host nicht — der Image-Weg
  (`test-bats-image`) fuhr nicht. Gelesene Form stimmt mit dem Bestand überein:
  Grenz-Zeile im Kopf `test/dockerfile-teststufe.bats:19-25` (Rezept-Fälle lesen grep-Formen,
  kein make/git/docker zur Laufzeit; Image-Weg trägt deren Werkzeuge · `seit slice-waechter-umgebungs-robustheit`),
  `harness/README.md` Zellen `traeger-fetch`/`traeger-fetch-image` (Host- und opt-in Weg, derselbe Pin-Vertrag),
  `harness/sensors/docs-check.md:8-22` (`$(DCHECK_CARRIER)`, `.harness/state/bin/d-check`,
  `make dcheck-fetch`, „Was der Host-Weg nicht deckt" benannt). **Offen bleibt:** ein Lauf,
  der den Exit-Vertrag *auf dem Image-Weg* misst, ist auf diesem Host nicht möglich — der
  Beleg trägt dann CI. Der zweite OR-Halbteil (docs-check-Prosa trägt den Carrier-Weg) ist
  im Bestand (hergebracht `9c788a9c`).
- **`make gates` grün: NICHT ERFÜLLT am Stand — rot an vorbestehenden Klassen, keine aus
  dem Slice-Diff.** Siehe Abschnitt Gates unten.
- **Review durchgeführt, Report unter docs/reviews/: ERFÜLLT** (`0e2115cb`, F-1/F-2 LOW,
  Rollenwechsel nach dem Implementer-Lauf).
- **Doku-Update bei berührtem öffentlichen Vertrag: ERFÜLLT (Bestand)** — Sensor-Prosa
  (docs-check Carrier-Weg) und README-Zellen stehen; der Diff führt kein neues Target ein.
- **Closure-Notiz mit Lerneintrag: OFFEN (Planner-Closure)** — §7 leer, wie geplant.
- **Beobachtungs-Register fortgeschrieben: OFFEN (Planner-Closure)** — der Stand
  `BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante` trägt `Stand: offen` und
  `Ausgang: geplant — slice-waechter-umgebungs-robustheit` (1 Vorgang, `Zähler 1`); die
  Mess-Belege dieses Laufs gehen in `evidence/` bei der Closure.
- **Jedes Risiko aus §6 trägt einen Ausgang: OFFEN (Planner-Closure)** — inhaltlich widerlegt:
  die Auslöser sind die **geerbten Pin-Mengen** (Brechen an der reale Route: rot genau im
  Plan-§3-Muster), nicht der Läufer und nicht die Reihenfolge des Sweep — die Risiko-Ursachen
  „Läufer-Werkzeug selbst" und „Symptom-Dreh am Host-Profil" sind **entfallen**; die formalen
  Ausgänge trägt die Closure-Notiz.

## Verifikations-Beleg-Liste (Läufe dieses Laufs, docker-los am Host)

- **L-1** `make test-bats BATS_TARGET=test/targets-modul-wiring.bats` 2× → je 0 rot (7 ok).
- **L-2** `make test-bats BATS_TARGET=test/traeger-fetch.bats` → 0 rot.
- **L-3** `make test-bats BATS_TARGET=test/traeger-fetch-host.bats` → 0 rot.
- **L-4** `make test-bats BATS_TARGET=test/dockerfile-teststufe.bats` → 0 rot.
- **L-5** `make test-bats BATS_TARGET=test/ignore-refs-restbreite.bats` → **1 rot: Fall 273**
  („11 aufloesende Links, deklariert sind 10") — Plan §3 Vorlauf-Stand, nicht aus dem Diff.
- **L-6** `make test-bats BATS_TARGET=test/` (voller Sweep) → exakt ein `not ok 273`, Rest ok
  (deckungsgleich mit L-1 … L-5; der einzig rote Fall ist in beiden Formen derselbe).
  (Ein Zwillingslauf des Sweep wurde nach dem Lesen der Rot-Menge abgebrochen, um Doppel-Last zu vermeiden.)
- **L-7** Brechen an der reale Route (Klon `/tmp/vswr`, `/tmp/vswr-b`, nach den Läufen geräumt):
  Setup-`unset`-Schleifen entfernt, über das make-Rezept mit den aus `Makefile:61` exportierten
  `TRAEGER_*` gefahren → rot-Mengen wie oben (LP-1). Kollations-Proben im Klon:
  `LC_ALL=C comm` Präfixe entfernt → unter `LC_ALL=en_US.utf8` **grün** (7 ok; der `comm`-Teil
  der Kollations-Zusage wird von seinem Präfix nicht gebunden) · dann `LC_ALL=C sort` Präfixe
  entfernt → **rot** („comm: file 1 is not in sorted order") — F-1 am Bestand bestätigt:
  der Zahn sitzt an den `sort`-Stellen, die Grenze trägt sie nirgends.
- **L-8** `make gates` (einmal, TEILDRIFT-Lauf: docs-check-host · test · shell-lint ·
  register-ausgang · mutate-greift) → **bricht an docs-check-host: 3076 Datei(en), 102 Befund(e)**
  (Claim-Stand laut Review 3075/102 — der Review-Report-Commit selbst fügt die eine Datei; Klasse
  unverändert, keine Befunde aus dem Plan-Diff: die drei Plan-Befunde (Z.21, 174, 247) sind
  Stand- und Zeilen-Verschiebung eines bei `e3c4cfd2` bestehenden Satzes). Register-ausgang:
  **grün** (291 Einträge, 82 über der Schwelle, 0 Befunde) — in derselben Kette gefahren, den
  Rest fuhren L-9 … L-11 einzeln, weil `make` am ersten roten Check endet.
- **L-9** `make shell-lint` → **rot, vorbestehend**: SC2254 ×4 in `harness/tools/gates-keys.sh`,
  SC2016 in `test/mutations/785` (+ Infos 797–801) — **keine Meldung** in den vier berührten
  `.bats`-Dateien.
- **L-10** `make test` → **rot am vorbestehenden Fall 273** (1..648, exakt ein not ok), Sequenz
  endet dort; test-go fuhr in L-11.
- **L-11** `make test-go` → **rot, vorbestehend, zwei Klassen**:
  `FAIL github.com/…/internal/emit` (TestStopHook_CommitBindung/dogfood, Stop-Hook-Klasse)
  und `FAIL github.com/…/internal/gen` — `TestGoProfile_PinsMatchRepo`: „ARG GO_VERSION:
  generiert \\"1.27.3\\" != Repo-Dockerfile \\"1.27.4\\" (Drift, LH-QA-02)". Beide Klassen liegen
  in Dateien, die der Diff nicht berührt (nur 4 `.bats`-Dateien + Plan-MD im Diff).

## Verifizierung der Review-Findings

- **F-1 (LOW) bestätigt:** die Messung trägt der Bestand noch nicht — kein Mutations-Fall gegen
  `targets-modul-wiring.bats` in `test/mutations/`, keine Grenz-Zeile im Kommentar oder Plan §3;
  die Bruchprobe (L-7) zeigt beide Richtungen. → Closure-Posten (Planner): Grenz-Zeile oder
  Mutations-Fall.
- **F-2 (LOW) bestätigt:** `git log -S BATS_ROOT -- harness/tools/bats-lint.sh` → `9c788a9c`;
  `git blame -L 14,20 harness/sensors/docs-check.md` → `9c788a9c` — beide Zeilen löst der Plan
  §3 Ist-Stand auf `be63da5d` — falsch (`be63da5d` trägt die Rezept-Wächter-Formen, die F-3-Zellen
  und den Mutations-Fall 810; `git show --stat` beider Commits). Die Schlussfolgerung (die drei
  Zeilen sind vor diesem Lauf erfüllt) bleibt wahr. → Closure-Posten (Planner): Herkunfts-Korrektur.

## Offene Posten für die Closure (Planner)

- Plan §3 Herkunfts-Korrektur nach F-2 (be63da5d/9c788a9c).
- F-1-Grenze („Zahn an `sort`, `comm`-Teil ungebunden") als Kommentar-Grenze oder Mutations-Fall.
- Fall 273 (ignore-refs-Restbreite 11/10) — Präzedenz-Nachzug als Planner-Posten
  (Plan §3 nennt `9321ffcc` als Route; keine Verbreiterung des Eintrags).
- Lerneintrag der Klasse „Weg-Agnostik der Wächter endet an den Werkzeugen" mit Herkunfts-Anker
  `seit slice-waechter-umgebungs-robustheit` (§5).
- Risiken §6: beide Ausgänge **entfallen** (Brechen an der reale Route isoliert die geerbten
  Pin-Mengen als Ursache, nicht den Läufer) — in der Closure-Notiz formal tragen.
- Register `BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`: Mess-Belege in
  `evidence/` (Implementer-Lauf + dieser Verifikations-Lauf), Zähler folgt aus den Dateien.
- Die 5 vorbestehenden Gates-Rot-Klassen mit trägerseits zuständigen Rollen:
  (a) docs-check 102 Befunde — Planungs-Baum/ADR-Index-Nachzug (Planner/Architect, u. a.
  Fall 273-Deckung); (b) bats Fall 273 — dieselbe Route; (c) shell-lint SC2254 (gates-keys)
  + SC2016 (Mutations-Fälle) — Implementer/Architect über `// shellcheck disable`-Verbot §3.2
  (zentraler Config-Eintrag oder Skriptkorrektur); (d) test-go internal/gen GO_VERSION-Drift
  (1.27.3 generiert vs 1.27.4 Dockerfile) — Implementer (Pin/Nachzug); (e) test-go
  internal/emit Stop-Hook-KommitBindung — Implementer/Architect (Stop-Hook-Bindung, ADR-0083-Fassung).
- **LP-3-Grenze:** Exit-Vertrag auf dem opt-in Image-Weg (`test-bats-image`) ist auf dem Host
  nicht messbar (docker trägt nicht) — Messung reist nach CI; bis dahin trägt die gelesene Form
  (Grenz-Zeile + docs-check-Prosa) die Zusage, und der Verifikations-Bericht benennt die Grenze.

## Negativbefunde (je ein Satz je Schwerpunkt)

- Kein Mutations-Fall bindet den `comm`-Teil der Kollations-Zusage (F-1) — die Grenze trägt der
  Bestand noch nicht.
- Der Image-Weg-Urteil über den Exit-Vertrag (LP-3-Halbteil 1) ist auf diesem Host nicht
  messbar — gelesen, nicht gefahren.
- Keine der 5 vorbestehenden Gates-Rot-Klassen stammt aus dem Slice-Diff (am Code/Läufen
  bestätigt, nicht am Bericht allein).
- `make mutate-greift` fuhr in diesem Lauf nicht: gates endet am ersten roten Check, und nach dem
  Nachziehen der übrigen roten Klassen (L-9--L-11) blieb er offen; sein Posten trägt ein eigener Lauf.

## Werkzeuge und Ablage

Läufe: make-Ziele ausschließlich (`test-bats` mit `BATS_TARGET`, `gates`, `shell-lint`, `test`,
`test-go`, `register-ausgang`). Bruchproben in Klonen unter `/tmp/vswr*` (nach den Läufen
geräumt — kein Baum-Artefakt im Repo); Logs `/tmp/vsgates.txt`, `/tmp/vsshell.txt`,
`/tmp/vstest.txt`, `/tmp/vsgo.txt`. Kein Commit, kein Push, keine Plan-Inhalte angefasst.

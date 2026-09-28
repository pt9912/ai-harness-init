# Verify-Report: slice-release-schnitt-v025-bereitet-vor — 2026-09-28

**Rolle:** Verifier (Modul 11 — „Bauen wir es richtig?" gegen DoD/ADR/Plan).
Eigener, frischer Kontext — keine Reviewer-Aussage ungeprüft übernommen; jede
Zahl und jeder Digest unten ist selbst nachgerechnet.

**Gegenstand:** Commits `f84b353c` (slice-mv) · `4e512592` (Pin-Commit
`v0.2.5`) · `31876391` (drei docs-check-Fixes) · `31f2e80b` (Reviewer-Report,
0 HIGH/MEDIUM/LOW, 1 INFO F-1).

**Eingangs-Kontext:** vollständiger Slice-Plan (§1–§8),
`docs/user/releasing.md` Schritte 1–4, `git show 4e512592`, `git show
31876391`, der Review-Report.

---

## Sicherheitsgrenze (zuerst geprüft, vor allem anderen)

```
git tag --list | grep v0.2.5   → leer, kein Treffer
git status -sb                 → ## main...origin/main [voraus 5]
git log origin/main..HEAD      → ded522c5, f84b353c, 4e512592, 31876391, 31f2e80b
```

**Bestätigt: kein Tag `v0.2.5` erstellt, nichts gepusht.** Fünf Commits
lokal voraus (der vierte des Reviewer-Reports war zum Zeitpunkt seines
eigenen Laufs noch nicht committet — sein Report nennt vier; jetzt sind es
fünf, alle weiterhin unpushed). Die Sicherheitsgrenze des Auftrags ist
eingehalten.

## 1. Liefer-Punkt 1 — Vorlage gesetzt, Assets gebaut

- `grep -n TRAEGER_TAG internal/emit/templates/enforce/traeger.mk
  test/traeger-fetch.bats` → beide `v0.2.5`. Bestätigt.
- `dist/` existiert weiterhin (nicht durch nachfolgende Läufe entfernt):
  sechs Plattform-Binaries + `SHA256SUMS`, Zeitstempel 07:30–07:31 Uhr, ein
  zusammenhängender Bau-Lauf. Kein erneuter Bau nötig.
- `ls dist/` → `ai-harness-init-darwin-amd64`, `-darwin-arm64`,
  `-linux-amd64`, `-linux-arm64`, `-windows-amd64.exe`, `-windows-arm64.exe`,
  `SHA256SUMS` — genau die sechs Plattformen der Matrix
  ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)).

**Bestätigt.**

## 2. Liefer-Punkt 2 — Assets verifiziert, Pin gezogen (eigene Byte-Verifikation)

Eigene, unabhängige `sha256sum`-Berechnung auf allen sechs Binaries in
`dist/`, verglichen gegen `dist/SHA256SUMS` **und** gegen die sechs
`TRAEGER_SHA256_*`-Werte im `Makefile`:

```
cd dist && sha256sum ai-harness-init-* | diff - <(sort SHA256SUMS)
→ IDENTISCH, keine Abweichung
```

Alle sechs von mir selbst berechneten Digests sind byte-identisch mit
`dist/SHA256SUMS` **und** mit den sechs im `Makefile` gepinnten
`TRAEGER_SHA256_*`-Werten (`c6a6a171…`, `1a00ea11…`, `0cb38747…`,
`3816b1ab…`, `b914c573…`, `a348a9d3…`). `bash harness/tools/release-sums.sh
verify dist` → alle sechs `OK`, Exit 0.

**Die sechs gepinnten Digests sind korrekt — eigenständig bestätigt.**

### Finding V-1 (MEDIUM, DoD-Testbehauptung nicht gedeckt) — Modul 11 „Bewusstes Brechen"

Die DoD selbst behauptet eine rote Gegenprobe: *„weicht einer der sechs
Digest-Pins vom Asset ab, bricht der Kopplungs-/Negative-Fall in
`test/traeger-fetch.bats`"*. Bewusstes Brechen durchgeführt (Modul 11
§Bewusstes Brechen für DoD-Testbehauptungen):

```
sed -i 's/TRAEGER_SHA256_LINUX_AMD64 ?= c6a6a171.../TRAEGER_SHA256_LINUX_AMD64 ?= ffff…ffff (64 hex)/' Makefile
docker run --rm --network none -v "$PWD":/code:ro -w /code $BATS_IMAGE test/traeger-fetch.bats
→ 1..10, ALLE 10 Tests "ok" — auch mit dem verfälschten realen Pin-Wert
git checkout -- Makefile   # danach zweifelsfrei zurückgesetzt
git diff --stat            # leer — Baum exakt wieder committeter Stand
bash harness/tools/working-tree-hash.sh  # == Stempel, bestätigt
```

**Befund:** Die DoD-Behauptung trägt nicht. Ursache: `test/traeger-fetch.bats`
liest den realen `Makefile`-Pin-Wert an keiner Stelle in eine Vergleichs-
Assertion ein.

- Der Fall „pin-kopplung" (Zeile 116–130) prüft nur *Präsenz* und *Länge*
  (`[ -n "$mk" ]`, `[ "${#mk}" -eq 64 ]`) — nicht den Wert.
- Alle Happy-/Negative-Fälle im Dogfood-Modus (Zeilen 163–226, inkl. des in
  der DoD zitierten „negative im Dogfood-Modus") injizieren ihre **eigenen**
  synthetischen Digest-Werte per `env TRAEGER_SHA256_LINUX_AMD64=…` direkt an
  das Skript — der reale `Makefile`-Wert wird dabei vollständig überschrieben,
  nie gelesen.

Die Tests belegen eine reale, tragende Eigenschaft — das Skript bricht
fail-closed bei **irgendeiner** Digest-Abweichung (generische Logik) —, aber
**nicht** die in der DoD behauptete Eigenschaft, dass ein Fehler im
*tatsächlichen* Release-Pin von `test/traeger-fetch.bats` gefangen würde. Ein
Tippfehler im echten `Makefile`-Pin liefe durch alle zehn Fälle grün.

**Einordnung nach Modul 11:** korrektheitskritischer DoD-Punkt
(LH-QA-02 Reproduzierbarkeit — der Pin ist der Integritätsanker des
Fetch-Pfads). Der fehlende Rot-Beleg ist hier vom Verifier nachgetragen: Ich
habe die tatsächlich tragende Prüfung — eigenständiger `sha256sum`-Abgleich
gegen `dist/SHA256SUMS` (§2 oben) — selbst durchgeführt und sie bestätigt
sich; **kein Datenfehler im aktuellen Pin.** Das *Risiko* ist damit nicht die
Korrektheit dieses konkreten Pins (die steht fest), sondern dass **kein
automatischer Sensor** existiert, der einen künftigen Tippfehler an dieser
Stelle fängt — die einzige Instanz, die das heute leistet, ist ein
Mensch/Agent mit `sha256sum`. Das ist dieselbe Klasse wie beim
Vorgänger-Slice (die DoD zitiert „Fall 1" dort) — die Ungenauigkeit ist damit
nicht neu, wird hier aber zum ersten Mal mit einer echten Gegenprobe
belegt statt angenommen.

**Empfehlung an den Planner:** kein Merge-/Closure-Blocker (die Daten sind
korrekt, eigenständig bestätigt), aber die DoD-Formulierung sollte präzisiert
werden (der Fall deckt die Skript-Logik, nicht den realen Pin-Wert), und die
Lücke „kein automatischer Sensor für Makefile-Pin-vs-dist/SHA256SUMS-Drift"
ist ein Kandidat für das Beobachtungs-Register (neue Beobachtung oder
Ergänzung, thematisch bei Release/Pin — keine der drei in §7 bereits
zitierten Beobachtungen deckt genau diese Lücke).

## 3. Liefer-Punkt 3 — Gates am Tag-Baum

**Erst-Check:** Stempel `.harness/state/gates-passed.diffsha` (Inhalt
`5d32e1e8…`, Schreibzeit 07:38, unmittelbar nach Commit `31876391`) war
**nicht** deckungsgleich mit dem `working-tree-hash.sh` des aktuellen Baums
(`bc954b1a…`, Stand nach Commit `31f2e80b`, dem Reviewer-Report). Erwartete
Ursache genau wie im Auftrag vorgezeichnet: der Report-Commit fügte eine
neue Datei hinzu, nachdem der letzte `make gates`-Lauf stattfand — kein
inhaltlicher Mangel am Code, aber der Stempel war vor Closure neu zu ziehen.

**Selbst nachgezogen:** `make gates` frisch auf dem aktuellen Baum
(inkl. Review-Report) gefahren. Alle zehn Prerequisites von `record-gates`
(`baseline-verify docs-check lint build test shell-lint ci-lint
comment-claims host-bin span-check`) sind in `make`-Zielabhängigkeiten
verdrahtet — `record-gates.sh` (die Stempel-Schreib-Recipe) läuft nur, wenn
**alle** vorher grün waren (Standard-Make-Semantik ohne `-k`). Der Stempel
wurde tatsächlich neu geschrieben und ist jetzt deckungsgleich:

```
cat .harness/state/gates-passed.diffsha   → bc954b1a3afa7ad708f0972d18086a880ef7556361a991a79c2a937976df437a
bash harness/tools/working-tree-hash.sh   → bc954b1a3afa7ad708f0972d18086a880ef7556361a991a79c2a937976df437a
```

(comment-claims meldete dabei „77 Datei(en) geprueft, 0 Befund(e)" — der
frische MR-073-Link ist mitgeprüft.) Ich verlasse mich nicht auf den
Prozess-Exit-Code der Hintergrund-Pipeline (der war durch ein `| tail -80`
im eigenen Aufruf verunreinigt und methodisch nicht belastbar) — belastbar
ist einzig, dass der Stempel korrekt neu geschrieben wurde, was bei einem
Fehlschlag irgendeines Prerequisites strukturell nicht passiert wäre.

**Bestätigt — mit der bereits im Auftrag antizipierten Randnotiz:** Der
ursprüngliche Implementer-/Reviewer-Stempel war zum Zeitpunkt meiner Prüfung
veraltet (durch den zwischenzeitlichen Report-Commit), ist aber jetzt durch
meinen eigenen `make gates`-Lauf aktuell und deckungsgleich. Vor der
Planner-Closure ist zu beachten: Mein eigener Verify-Report-Commit (dieser
hier) fügt selbst wieder eine neue Datei hinzu und macht den Stempel
**erneut** veraltet — das ist normal (Verifier-Commits sind reine Doku,
Modul 9/10-Analogie) und kein Fehler; der **nächste** `make gates`-Lauf vor
dem tatsächlichen Tag-Push (Schritt 4 der Prozedur, außerhalb dieses Slice)
muss ohnehin auf dem dann finalen Commit erneut laufen — das deckt sich mit
Risiko 3 aus §6 (siehe unten).

## 4. `release-sums.sh verify dist`

Selbst gefahren: `bash harness/tools/release-sums.sh verify dist` → alle
sechs Assets `OK`, `EXIT=0`. Bestätigt (siehe auch §2).

## 5. `test/traeger-fetch.bats` „pin-kopplung" — Gegenprobe

Siehe Finding V-1 oben (§2): Mutations-Gegenprobe durchgeführt (`Makefile`
testweise verändert, Docker-bats-Lauf, Ergebnis alle 10 grün trotz falschem
realem Pin), danach `git checkout -- Makefile` und `git diff --stat`
bestätigt leer — Baum zweifelsfrei auf committeten Stand zurückgesetzt.
`bash harness/tools/working-tree-hash.sh` nach dem Reset deckt sich wieder
mit dem (zu dem Zeitpunkt gültigen) Stempel.

## 6. Reviewer-Finding F-1 (INFO) — Einschätzung

F-1 bemängelt, dass §3 der Plan-Tabelle die zwei durch `31876391`
zusätzlich berührten Dateien (`roadmap.md`, das Slice-Dokument selbst)
nicht nachträgt. Eigene Prüfung: beide Änderungen sind keine Code-Änderung
(die Zusage „Kein Code-Diff jenseits der Pin-/Vorlage-Stellen" bleibt
unverletzt), beide sind gate-getrieben (docs-check-Struktur-Regel bzw.
Ruhe-Marker-Regel) und kausal an die eigene `slice-mv`-Transition dieses
Slice gebunden — kein eigenständiger Scope-Creep. **Einschätzung: reine
INFO, kein Ausgang im Sinne der Risiko-Klasse nötig** (es ist kein Risiko
aus §6, sondern ein Reviewer-Finding); es geht als Finding-Klasse in den
Closure-Zähler ein (Modul 5 §Closure-Regeln, drei Quellen), braucht aber
keine Sonderbehandlung — erstes Auftreten dieser Klasse, keine 3×-Schwelle.

## 7. Plan-vs-Code-Diff (zusätzlich, eigenständig)

`git show --stat` beider Implementer-Commits gegen §3 der Plan-Tabelle
abgeglichen: `Makefile`, `internal/emit/templates/enforce/traeger.mk`,
`test/traeger-fetch.bats` (Commit `4e512592`) — exakt die drei geplanten
Dateien, keine mehr, keine weniger. `dist/` als lokaler, nicht committeter
Bau-Output — plan-konform (`.gitignore` greift, `git status --ignored`
bestätigt). Die zwei Zusatz-Dateien in `31876391` sind F-1 (oben). **Kein
Code-Diff jenseits der deklarierten Pin-/Vorlage-Stellen** — Zusage hält.

Randbefund (kein DoD-Blocker dieses Slice, zur Kenntnis): `ADR-0063`, auf das
Slice-Kopf und beide Implementer-Commit-Messages verweisen, trägt
**Status: Proposed**, nicht Accepted. Dieser Slice **implementiert**
ADR-0063 nicht (die `TRAEGER_VERSION`-Injektion via `ldflags`/Docker-Build-Arg
ist unverändert Bestand aus einem Vorgänger-Slice, nicht Teil des Diffs von
`4e512592`/`31876391`) — er zitiert die ADR nur als Kontext für
„`TRAEGER_VERSION` ist der Wert, den der Bau trägt". Kein DoD-Verstoß dieses
Slice, aber eine offene Prozess-Frage (Proposed-ADR bereits produktiv im Bau
genutzt) außerhalb seines Scopes.

## 8. §6-Risiken — eigenständige Einschätzung je Ausgang

| Risiko | eigene Einschätzung | empfohlener Ausgang |
|---|---|---|
| 1. Plattform-Matrix-Bau bricht | `dist/` trägt alle sechs Assets, Zeitstempel eines zusammenhängenden Laufs, alle sechs Digests von mir selbst nachgerechnet und deckungsgleich — kein Bau-Abbruch, kein Fix nötig. | **entfallen** — alle sechs Assets bauten im ersten Lauf |
| 2. CI-Race beim Merge vor Tag-Push | Kein Tag existiert, nichts wurde gepusht (Sicherheitsgrenze oben) — der Fall, den das Risiko beschreibt, kann in diesem Slice gar nicht eintreten; die Struktur-Entscheidung der referenzierten Beobachtung ist unverändert offen. | **weiter offen** — Struktur-Entscheidung steht aus, operativer Ausgang bleibt der Re-Run nach dem tatsächlichen Schritt 5 (außerhalb dieses Slice) |
| 3. Belegbasis-Lücke Closure↔Tag-Push | Bereits jetzt beobachtet (§3 oben): mein eigener Verify-Commit macht den Stempel erneut veraltet, und §3.10 verlangt einen separaten Planner-Closure-Commit danach — der Tag wird strukturell **nicht** auf demselben Commit sitzen, den `make gates` zuletzt sah. | **eingetreten** — eine erneute `make gates`-Verifikation unmittelbar vor dem tatsächlichen Tag-Push ist nötig, außerhalb der DoD dieses Slice (deckt sich mit `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`) |
| 4. d-check-Pin-Sprung MR-073 | `make gates` lief bei mir frisch grün (inkl. `docs-check`/`comment-claims`, 0 Befunde) — der Befund (MR-073-Link fehlte) trat ein und wurde bereits in `31876391` behoben. | **eingetreten** — Befund wurde im laufenden Slice behoben (wie in der Risiko-Formulierung selbst als möglicher Ausgang vorgesehen) |

## Verdikt

**DoD erfüllt: ja, mit einer dokumentierten Einschränkung (Finding V-1,
MEDIUM, kein Blocker).**

- Liefer-Punkt 1: bestätigt.
- Liefer-Punkt 2: Daten bestätigt (eigene Byte-Verifikation); die in der DoD
  behauptete automatisierte rote Gegenprobe in `test/traeger-fetch.bats`
  trägt nicht (Finding V-1) — der Rot-Beleg wurde vom Verifier ersatzweise
  über eine direkte `sha256sum`-Prüfung erbracht.
- Liefer-Punkt 3: bestätigt, nach eigenem Nachziehen des zwischenzeitlich
  veralteten Stempels.
- Review-Voraussetzung: erfüllt (Report liegt vor, 0 HIGH/MEDIUM/LOW, 1
  INFO ohne Merge-Block).
- Sicherheitsgrenze: **kein Tag erstellt, nichts gepusht** — eigenständig
  bestätigt, zweimal (vor und nach der eigenen Arbeit).

**Empfehlung an den Planner (§6, vier Risiken):**

1. Plattform-Matrix-Bau bricht → **entfallen**.
2. CI-Race beim Merge → **weiter offen** (ins Beobachtungs-Register bereits
   verlinkt, Struktur-Entscheidung bleibt Planner-/Architect-Sache).
3. Belegbasis-Lücke Closure↔Tag-Push → **eingetreten**: vor dem tatsächlichen
   Tag-Push (Schritt 5, außerhalb dieses Slice) ist zwingend ein erneuter
   `make gates`-Lauf auf dem dann finalen Commit fällig — das ist keine
   Wiederholung dieses Slice, sondern die im Risiko selbst vorgesehene
   Konsequenz.
4. d-check-Pin-Sprung MR-073 → **eingetreten**, im laufenden Slice behoben
   (Commit `31876391`).

Zusätzlich zur Closure-Notiz: Finding V-1 (DoD-Testbehauptung ohne Deckung
in `test/traeger-fetch.bats`) als Lerneintrag bzw. Beobachtungs-Register-
Kandidat aufnehmen — die Formulierung „bricht der Kopplungs-/Negative-Fall"
sollte für künftige Release-Slices präzisiert oder durch einen echten
Pin-vs-`dist/SHA256SUMS`-Sensor unterlegt werden.

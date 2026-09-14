# Verifikation `slice-vorlauf-waechter-geht-ins-ziel` — sechs von zehn DoD-Punkten tragen, vier gehören dem Planner

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `c0daab58` (Arbeitsbaum vor und
nach jeder Messung leer, `git status --porcelain` → keine Zeile) · **Plan:**
`slice-vorlauf-waechter-geht-ins-ziel` §1, §2, §3, §5, §6 — geprüft ist die **DoD gegen den
tatsächlichen Stand**, nicht der Plan gegen sich selbst (das war der Reviewer, Modul 10/11) ·
**Review:** `2026-09-14-slice-vorlauf-waechter-geht-ins-ziel` (Runde 1: 1 HIGH · 3 MEDIUM · 1 LOW ·
2 INFO), Runde 2 (2 MEDIUM · 1 LOW · 1 INFO), Runde 3 (1 MEDIUM · 1 LOW), Runde 4
(0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO); die eine LOW ist mit `c0daab58` behoben · **Prüfgegenstand:**
§2 Definition of Done, die Quellen, auf die sie sich beruft ([`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
[`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
[`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)),
und der Plan-vs-Code-Diff in beide Richtungen.

**Commits der Umsetzung:** `59fd546c` (der Vorlauf-Wächter geht ins Ziel) · `fa00e736`, `1e6f9e4b`
(Review-Runde 2) · `ee350f6d` (Runde 3) · `d8ab4835`, `1b060790` (Runde 4) · `c0daab58` (R4-1).
**Plan-Korrekturen des Planner im selben Gegenstand:** `0092870f` (DoD-Punkt 2 auf eine
erfüllbare Sonde), `a278359d` (§1-Ausschluss auf seinen Geltungsbereich).

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an keinem der sieben
Umsetzungs-Commits, am Slice-Plan und an keiner der vier Review-Runden etwas verfasst — kein
Kommentar, kein Testfall, kein Fragment, kein Plan-Satz. Er hat gelesen und Sensoren gefahren.
**Offengelegt:** vier Mutations-Fälle sind **im Arbeitsbaum** angewandt und einzeln zurückgenommen
worden (`git checkout -- internal/emit/`, danach `git status --porcelain` leer, `git rev-parse HEAD`
unverändert `c0daab58`). Wegwerf-Dateien dieses Laufs liegen ausschließlich unter `/tmp/verif/`,
nicht im Repo; die zwei `d-check.mk`- und `doc-gate.mk`-Bäume, an denen die Fragment-Sonden liefen,
sind `/tmp`-Kopien.

**Zitier-Form** *(wie in den Review-Reports zu diesem Gegenstand)*: **Kennung, nicht Adresse** für
alles, was der Prozess bewegt. Ortsfeste Code-Pfade bleiben Inline-Code, ortsfeste Ziele bleiben
Link.

---

## Ergebnis in einer Tabelle

| §2 DoD-Punkt | Verdikt |
|---|---|
| „Das Ziel führt den Wächter, gebunden an die zwei history-lesenden Targets“ — er läuft **vor** dem Modul-Lauf | **erfüllt** (§2.1) |
| „Der Fall aus [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3 ist rot gesehen“ — leere Range bricht ab, nicht-leere bleibt grün | **erfüllt** (§2.2) |
| „Keine neue Host-Abhängigkeit“ und kein Image-Lauf vor dem Modul-Lauf, Fehlt-Fall sagt etwas | **erfüllt** (§2.3) |
| `make gates` grün | **erfüllt** (§2.4) |
| Review durchgeführt, Report unter `docs/reviews/` liegt vor | **erfüllt** (§2.5) |
| Doku-Update: die Aufzählung der emittierten Werkzeuge | **erfüllt** (§2.6) |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **nicht fällig** — Planner (`AGENTS.md` §3.10) |
| Beobachtungs-Register (`../observations/`) fortgeschrieben | **nicht fällig** — Planner |
| Jedes Risiko aus §6 trägt einen Ausgang | **nicht fällig** — Planner |
| Die drei Paarungen sind getragen | **nicht fällig** — Welle-Closure |

**DoD-Verletzungen: keine.** Drei Befunde eigener Klasse stehen in §5 — alle INFO, keiner
merge-blockierend; sie sind §2.1, §2.6 und der Sensor-Prosa zugeordnet und als „nicht
DoD-Verletzung“ ausgewiesen.

---

## 1. Ist der Sensor gelaufen?

Alle Docker-Läufe über `make` (`AGENTS.md` §3.9), keine Host-Toolchain.

```sh
make gates        # EXIT 0
# baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
# d-check: 1392 Datei(en) geprüft, 0 Befund(e)
# comment-claims: 58 Datei(en) geprueft, 0 Befund(e)
# span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
# [test 2/2] RUN CGO_ENABLED=0 go test -count=1 ./...  → acht Pakete `ok`
# grep -c '^ok ' → 280 ; grep -c '^not ok' → 0
make full-smoke   # EXIT 0 (93 s), Abschnitt (f) mit sieben Zusicherungen (§2.1)
```

Vier Mutations-Fälle fuhren ihren **benannten** Wächter rot (§4, `AGENTS.md` §3.6). Kein Sensor
wurde ausgelassen; was **nicht** lief, steht in §6.

---

## 2. Deckt der Sensor die Zusage?

### 2.1 Liefer-Punkt 1 „Das Ziel führt den Wächter, gebunden an die zwei Targets“ — **erfüllt**

Das Fragment verbatim aus `docGateMk` gezogen (dieselbe Funktion, die `DocGate` in
`harness/mk/doc-gate.mk` schreibt — `DocGateMk() string { return docGateMk }`):

```sh
sed -n '/^const docGateMk = `/,/^`$/p' internal/emit/emit.go | sed '1s/^const docGateMk = `//' | sed '$d' > /tmp/verif/frag/doc-gate.mk
wc -l /tmp/verif/frag/doc-gate.mk                                                   # 53
grep -n 'history-range-guard' /tmp/verif/frag/doc-gate.mk
# 17:.PHONY: history-range-guard
# 19:history-range-guard: ## Vorlauf-Waechter: RANGE muss aufloesbar UND nicht leer sein …
# 20:	@bash tools/harness/history-range-guard.sh "$(if $(STAGED),--staged,$(RANGE))"
# 30:doc-immutable: history-range-guard
# 38:doc-commits: history-range-guard
```

**Die Ordnungskante selbst gemessen** — in einem Zielbaum aus dem extrahierten Fragment und einem
`d-check.mk` mit beiden Zielen, an der Kante gelesen (`make -n` führt kein Rezept aus):

```sh
make --no-print-directory -f doc-gate.mk -n doc-immutable RANGE=HEAD~1..HEAD | grep -n 'history-range-guard.sh\|docker run'
# 1:bash tools/harness/history-range-guard.sh "HEAD~1..HEAD"
# 2:docker run --rm --network none -v "/tmp/verif/target:/repo:ro" img --range HEAD~1..HEAD
make --no-print-directory -f doc-gate.mk -n doc-commits RANGE=HEAD~1..HEAD | grep -n 'history-range-guard.sh\|docker run'
# 1:bash tools/harness/history-range-guard.sh "HEAD~1..HEAD"
# 2:docker run --rm --network none -v "/tmp/verif/target:/repo:ro" img --range HEAD~1..HEAD
```

**Beide Ziele** führen den Wächter in Zeile 1, den Modul-Lauf in Zeile 2 — die Ordnungskante trägt
für beide. Der Beleg aus `make full-smoke` (nicht eine Zeile im Emit-Code) liegt vor: sieben
Zusicherungen in Abschnitt (f) und sechs in (a)–(e), darunter je Ziel eine rote und eine grüne
Richtung:

```sh
grep -n 'Zieldefinition\|Vorlauf-Waechter\|Waechter greift\|OHNE den Waechter\|Gegenprobe' /tmp/verif/full-smoke.log
# 247 Waechter greift (golang): make doc-immutable RANGE=HEAD..HEAD bricht ab …
# 248 Waechter greift (golang): make doc-commits  RANGE=HEAD..HEAD bricht ab …
# 249 Waechter greift (golang): make doc-immutable RANGE=HEAD~1..HEAD bricht ab …
# 250/252 OHNE den Waechter meldet dasselbe Modul … gruen (doc-immutable / doc-commits)
# 254 Gegenprobe (golang): dieselbe Range auf dem vollstaendigen Klon bleibt gruen
# 257/258 Zieldefinition: LAUT ab (Ziel-Zeile umbenannt), doc-immutable / doc-commits
# 259/260 Zieldefinition: LAUT ab (Ziel-Zeile ohne Rezept), doc-immutable / doc-commits
# 261 Zieldefinition: ohne das Probe-Werkzeug … LAUT ab
# 262 Zieldefinition: die Kommandozeile setzt die Entscheidung nicht … LAUT ab
# 263 Zieldefinition: derselbe Aufruf ueber dem unverfaelschten d-check.mk bleibt gruen (doc-commits)
```

**Befund-Klasse dazu in §5 (V-1):** die *Ordnungs*-Prüfung des Smoke greift nur für
`doc-immutable`; für `doc-commits` prüft Zusicherung (a) allein die **Nennung**. Die Zusage ist
damit erfüllt — ich habe die zweite Hälfte selbst gemessen (s. o.) —, aber ihr dauerhafter Zahn
ist einseitig.

### 2.2 Liefer-Punkt 2 „Der Fall aus `MR-007` Setzung 3 ist rot gesehen“ — **erfüllt**

Eigene Sonde am emittierten Wächter (`internal/emit/templates/enforce/history-range-guard.sh`,
byte-gleich zu dem, was der Emit schreibt), in zwei Klons **derselben** Quelle, einer mit
`--depth 1`, einer vollständig, beide über `file://`:

```sh
git clone -q --depth 1 "file://$W/src" "$W/flach" ; git clone -q "file://$W/src" "$W/voll"
cd "$W/flach" ; bash <Wächter> HEAD..HEAD
# history-range-guard: Range 'HEAD..HEAD' ist aufloesbar, aber LEER (0 Commits).
#   Shallow-Grenzen: 1
#   Angeforderte Range: HEAD..HEAD
#   -> Checkout braucht 'fetch-depth: 0' (oder ausreichende Tiefe) fuer diesen Job.
# EXIT=1                      ← nicht "0 Befund(e)", nicht Exit 0
cd "$W/voll"  ; bash <Wächter> HEAD~1..HEAD
# history-range-guard: Range 'HEAD~1..HEAD' aufgeloest, 1 Commit(s) — OK.
# EXIT=0                      ← die grüne Richtung
```

Beide Richtungen sind damit **gelesen**, nicht nur am Exit-Code abgelesen. Die Grenze, die der
Wächter nicht überdehnt, ebenfalls gemessen: dieselbe unauflösbare Basis im flachen Klon endet mit
`ist NICHT aufloesbar (Basis fehlt im Klon?).` und **EXIT=2** — sie deckt er nicht zusätzlich.

Die Klassen-Zusage des Punktes („meldet **nicht** `0 Befund(e)`/Exit 0“) ist an **beiden** Zielen
im Ziel selbst gefahren — die blinde Hälfte über `-f d-check.mk`, also ohne das Fragment:

```sh
sed -n '250,253p' /tmp/verif/full-smoke.log
# full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen (doc-immutable) …
# full-smoke:   d-check: 20 Datei(en) geprüft, 0 Befund(e)
# full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen (doc-commits) …
# full-smoke:   d-check: 20 Datei(en) geprüft, 0 Befund(e)
```

**Die Plan-Korrektur `0092870f` war sachlich nötig, und ich habe das nachgemessen:** die vorige
Fassung des Punktes verlangte „dieselbe Sonde auf einem vollständigen Klon bleibt grün“ **ohne** die
Range zu nennen — mit einer leeren Range kann das in keinem Klon eintreten. Meine vierte Messung
(leere Range auf dem **vollständigen** Klon, `Shallow-Grenzen: voll (kein Shallow-Klon)`) endet
ebenfalls mit **EXIT=1**. Die genannte Range `HEAD~1..HEAD` ist die einzige, die die grüne Hälfte
trägt.

### 2.3 Liefer-Punkt 3 „Keine neue Host-Abhängigkeit“ und kein Image-Lauf vorher — **erfüllt**

- **Der Wächter läuft mit `bash + git`.** Das Rezept des Fragments ist
  `@bash tools/harness/history-range-guard.sh "…"`; das Skript trägt `set -euo pipefail` und ruft
  ausschließlich `git rev-list --count`, `git rev-parse`, `git diff --cached`, `wc`, `tr` — kein
  Image, kein Netz (`grep -nE 'docker|curl|wget' internal/emit/templates/enforce/history-range-guard.sh`
  → 0 Treffer außer dem Wort „Docker“ im Kopfkommentar, der `Kein Docker, kein Netz` sagt).
- **Kein Image-Lauf vor dem Modul-Lauf** — dieselbe Ordnungskante wie §2.1: Zeile 1 `bash …`, Zeile
  2 `docker run …`.
- **Die neue Fail-closed-Probe (`awk`) ist keine neue Abhängigkeit.** Sie liegt **im** `make`-Lauf
  des Ziels (`$(shell awk …)` beim Parsen des Fragments, `if [ -z "$z_guard" ]`-frei), und `awk`
  führt das emittierte Repo längst:

  ```sh
  grep -n 'awk' internal/emit/makefile.go
  # 30:	@grep -hE '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN{FS=":.*##"}…'   ← das Hilfe-Ziel
  grep -n 'awk' internal/emit/enforce.go | head -2
  # 61:		// Command-Guard (slice-032): bash+awk, kein node/jq (LH-QA-03).
  sed -n '/^### LH-FA-06/,/^### LH-FA-07/p' spec/lastenheft.md | grep -n 'awk'
  # 23:- **Minimal:** Das emittierte Repo braucht über `bash + git + docker` hinaus nichts (awk ist POSIX-Basis).
  ```

  `awk` ist damit POSIX-Basis und steht im Akzeptanzkriterium der Quelle ausdrücklich als zulässig.
- **Der Fehlt-Fall sagt etwas.** Gemessen an einem `d-check.mk`, dessen zwei Ziel-Zeilen umbenannt
  sind (Fragment = `/tmp`-Kopie, `make -f doc-gate.mk`):

  ```sh
  make --no-print-directory -f doc-gate.mk doc-immutable RANGE=HEAD~1..HEAD
  # harness/mk/doc-gate.mk: d-check.mk fuehrt 'doc-immutable' nicht als Ziel mit Rezept (oder awk fehlt) —
  #   die Vorbindung des Vorlauf-Waechters haette dort kein Rezept (LH-QA-01).
  # make: *** [doc-gate.mk:42: doc-immutable] Fehler 2
  # EXIT=2
  ```

  Dieselbe Sonde ohne Probe-Werkzeug im PATH (die Randlage aus dem Smoke, hier einzeln):

  ```sh
  env PATH=/nonexistent "$(command -v make)" -f doc-gate.mk -n doc-immutable RANGE=HEAD~1..HEAD
  # echo "harness/mk/doc-gate.mk: d-check.mk fuehrt 'doc-immutable' nicht als Ziel mit Rezept (oder awk fehlt) …" >&2
  # exit 2                       ← der unbekannte Ausgang fällt in den Abbruch, nicht in die Bindung
  ```

  **Kein stiller Erfolg in beide Richtungen:** die Meldung des Wächters (leere Range) und die
  Meldung des Fragments (fehlende Ziel-Definition) sind zwei verschiedene Texte mit zwei
  verschiedenen Ursachen, beide gelesen.

### 2.4 `make gates` grün — **erfüllt**

```sh
make gates   # EXIT 0 (00:19), entscheidende Zeilen:
# baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
# d-check: 1392 Datei(en) geprüft, 0 Befund(e)
# comment-claims: 58 Datei(en) geprueft, 0 Befund(e)
# span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
```

Keine Zeile beginnt mit `not ok`; die vier neuen Go-Wächter laufen in der
`[test 2/2] RUN CGO_ENABLED=0 go test -count=1 ./...`-Stufe mit (`internal/emit` → `ok`).

### 2.5 Review durchgeführt, Report liegt vor — **erfüllt**

Vier Reports unter `docs/reviews/`, der letzte mit dem Verdikt **0 HIGH · 0 MEDIUM · 1 LOW ·
1 INFO**; die eine LOW (R4-1) ist mit `c0daab58` behoben (dazu §2.7), die INFO (R4-2) und die
Struktur-Frage N-3 sind ausdrücklich dem Architect zugeordnet. Vier separate
`Rolle Reviewer`-Commits (`493d4fff`, `019d11ac`, `6621ed91`, `b57e1073`) — kein Self-Review
(Modul 8).

### 2.6 Doku-Update: die Aufzählung der emittierten Werkzeuge — **erfüllt**

Gelesen als die Stelle, die die Mechanik **im gebootstrappten Ziel** aufzählt: die Sensor-Prosa
`harness/sensors/history-range-guard.md` hat mit diesem Slice den neuen Abschnitt *Im
gebootstrappten Ziel* bekommen — Zielpfad `tools/harness/history-range-guard.sh`, die zwei
gebundenen Targets, die Ordnungskante, die fail-closed Probe und die `AdaptMK`-Voraussetzung.

**Eine zweite Aufzählung existiert im Repo nicht** (gemessen, nicht vermutet):

```sh
grep -rln 'stop-require-gates.sh' --include=*.md . | grep -v '.harness/baseline' | grep -v docs/reviews
# CLAUDE.md · docs/plan/planning/done/slice-031… · docs/plan/planning/done/slice-138… · docs/plan/adr/0011…
```

— keine Datei führt die emittierten Werkzeuge einzeln. [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
nennt **Klassen** („Stop-Hook + Gate-Nachweis-Mechanik (`tools/harness/` …)“); ein weiteres Skript
unter `tools/harness/` wächst in die Klasse hinein, ohne den Vertrag zu ändern — konsistent mit dem
Kopf des Slice („Berührte Spec-Stellen: `—`“).

### 2.7 Die vierte Runde (R4-1) — die Zusage „bricht laut ab“ ist **nicht mehr** per Kommandozeile aufhebbar

Eigene Messung an derselben verfälschten `/tmp`-Kopie wie §2.3
(`make -f doc-gate.mk …` mit `override DOC_GATE_ZIEL = …`):

| Aufruf über dem `d-check.mk` **ohne** Ziel-Definition | gemessen |
|---|---|
| `make -f doc-gate.mk doc-immutable …` | Meldung des Fragments + `Fehler 2`, **EXIT=2** |
| `make -f doc-gate.mk DOC_GATE_ZIEL=da doc-immutable …` | dieselbe Meldung, **EXIT=2** ← der Befund R4-1 |
| `env DOC_GATE_ZIEL=da make -f doc-gate.mk … doc-immutable` | dieselbe Meldung, **EXIT=2** |
| `make -f doc-gate.mk DOC_GATE_ZIEL=da doc-commits …` | Meldung für `doc-commits` + `Fehler 2`, **EXIT=2** |

**Die Grün-Richtung unverändert** — derselbe Kommandozeilen-Angriff über dem **intakten**
`d-check.mk` druckt weiter Wächter **und** Modul und endet mit 0:

```sh
make --no-print-directory -f doc-gate.mk -n DOC_GATE_ZIEL=da doc-immutable RANGE=HEAD~1..HEAD
# bash tools/harness/history-range-guard.sh "HEAD~1..HEAD"
# docker run --rm --network none -v "/tmp/verif/target:/repo:ro" img --range HEAD~1..HEAD
# EXIT=0
```

Der Befund der Runde 4 ist damit **geschlossen**, und die Behauptung des Behebungs-Commits
(„die Kommandozeile setzt diese Variable nicht“) trägt am emittierten Fragment in **beiden**
Richtungen.

### 2.8 Die noch nicht fälligen Punkte — **nicht fällig**, mit Beleg

Nach `AGENTS.md` §3.10 ist der Abschluss Planner-Arbeit und läuft **nach** dieser Verifikation:

```sh
grep -c 'eingetreten: CO-NNN' docs/plan/planning/done/slice-vorlauf-waechter-geht-ins-ziel.md   # 3
ls docs/plan/planning/observations/                                                                    # BEO-ALL  README.md
ls docs/plan/planning/observations/BEO-ALL/*/evidence/ | grep -ci vorlauf-waechter                      # 0
```

Drei Risiko-Platzhalter in §6, keine Register-Datei für diesen Slice, §7 noch Vorlage. **Kein
Befund** — die vier Punkte sind zum jetzigen Zeitpunkt nicht dran (Planer/`git mv`).

---

## 3. Sagt der Plan, was der Artefakt tut?

**Geplantes, das gebaut ist** (§3 des Slice):

| Plan-Zeile | Artefakt |
|---|---|
| `internal/emit/templates/enforce/` — neu | `history-range-guard.sh` liegt dort und ist in `enforceFiles()` als `tools/harness/history-range-guard.sh` (0755) registriert (`git diff --stat 59fd546c~1..c0daab58 -- internal/emit/enforce.go` → 7 Zeilen) |
| `internal/emit/emit.go … update` | `docGateMk` trägt die zwei Vorbindungs-Zeilen, die eine Probe und die zwei Abbruch-Zweige; `AdaptMK` ruft `requireVorbindungsTargets` |
| `test/…` — neu/update | **neun** neue Mutations-Fälle `325`–`333` (alle `A`, keine bestehende Datei geändert oder entfernt) + drei neue Go-Wächter in `internal/emit/emit_test.go` / `enforce_test.go` |
| „Der Wächter wird nicht neu erfunden“ | dieselbe Logik; die zwei Fassungen sind bis auf die zwei `--decide`-Einstiege, ihre Usage-Zeile und eine Meldung textgleich (`diff <(grep -vE '^\s*#|^\s*$' harness/tools/history-range-guard.sh) <(grep -vE '^\s*#|^\s*$' internal/emit/templates/enforce/history-range-guard.sh)`) |

**Gebautes, das der Plan nicht nennt** — in beide Richtungen benannt:

1. **Der Träger des Smoke-Abschnitts.** §3 nennt `Makefile` (`full-smoke`) als die Datei des Belegs;
   geändert ist **nicht** das Makefile, sondern `harness/tools/full-smoke.sh` (+172 Zeilen), das
   Rezept des Ziels ruft. Die *Wirkung* ist die geplante — der Beleg läuft über `make full-smoke` —,
   die *Adresse* im Plan zeigt eine Ebene zu hoch. Zwei weitere Dateien kommen hinzu, die §3 nicht
   führt: `internal/emit/templates.go` (die Grenz-Beschreibung von `InitInvariantTargets`, die zwei
   Ziele sind jetzt init-invariant) und `harness/sensors/history-range-guard.md`.
2. **Die R4-1-Achse.** §1 und §2 sagen zur Umgehbarkeit der fail-closed Entscheidung nichts; sie ist
   erst durch den Review-Lauf zu Runde 4 entstanden und mit `c0daab58` geschlossen (`override`, eine
   siebte Zusicherung in (f), neuer Fall `333`, Nachzug an `329`). Ein Zug **über** den Plan hinaus,
   aber keiner an einer §1-Abgrenzung — die vier Ausschlüsse bleiben unberührt.
3. **Zu groß wurde der Slice nicht.** Drei Liefer-Punkte, wie §2 sie zählt; die Gate-Läufe und die
   fünf Closure-Pflichten zählen nach der Regel nicht mit.

**§1-Abgrenzung am Diff geprüft** (`git log --oneline 493d4fff..c0daab58` + `--name-status`):

- **Kein Zug an der Fall-Menge:** in `test/mutations/` ausschließlich `A`-Einträge; die einzige
  Änderung an einer bestehenden Datei ist der Operand des eigenen neuen Falls `326` (Runde 2: die
  Probe von der Prosa auf die ausführende Zeile gezogen) — verschärft, nicht gelockert.
- **`mutate.yml`/`ci.yml`:** beide gehen auf `138c7a2e` (`Rolle Planner`) aus dem **anderen** Slice
  `slice-der-mutations-lauf-ist-begrenzbar` zurück, nicht auf einen der sieben Commits dieses
  Gegenstands. Ebenso `harness/sensors/mutate.md` und der CI-Absatz in `harness/README.md`.
- **Reviewer-/Verifier-Anweisungssatz:** `git diff --name-status … -- .harness/skills/` → leer.
  Geändert sind `.claude/agents/implementer.md` und `.claude/commands/implement-slice.md` — beide
  aus den Planner-Commits `258ab942` sowie dem Implementer-Commit `e76b3962` des **Mutations-Stufen**-Slices,
  nicht aus diesem Gegenstand; kein Reviewer-/Verifier-Artefakt ist berührt.
- **Produkt-Code:** die Go-Dateien des Deltas liegen ausnahmslos unter `internal/emit/`
  (`emit.go`, `enforce.go`, `templates.go`, zwei `_test.go`); kein `internal/`-Paket sonst, kein
  `cmd/`.

**§1/§8 Messungen des Plans heute nachgezogen** (die Zahlen wandern, `MR-025` Setzung 2):

```sh
grep -c 'history-range-guard' Makefile                              # 5  (wie im Plan)
git grep -c 'history-range-guard' -- internal/ | wc -l              # 5  (Plan nennt 0 — Pre-State, jetzt gebaut)
ls docs/plan/planning/observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/evidence/*.md | wc -l   # 1
ls docs/plan/planning/observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/evidence/*.md | wc -l    # 3
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                                                        # 114
```

Die beiden §8-Zähler stimmen (1× offen, 3× geplant). Die zweite Zeile ist die **einzige** Plan-Zahl,
die heute nicht mehr reproduziert — erwartet: sie beschreibt den Vorzustand, den dieser Slice
schließt, und steht mit ihrem Kommando daneben.

---

## 4. Modul 11 §Bewusstes Brechen — vier neue Fälle einzeln, mit gelesener Ausgabe

Jeder Fall im Arbeitsbaum angewandt, `make`-Sensor gefahren, der benannte Wächter im Rot gelesen,
danach zurückgenommen. **Kein voller `make mutate`** — der Satz läuft laut
`.github/workflows/mutate.yml` Post-integration (§6 zeigt die Grenze).

| Fall | Angewandt (`git diff --stat`) | Sensor | Ausgabe (gekürzt) |
|---|---|---|---|
| `332` zweiter Probe-Aufruf mit falschem Ziel | `internal/emit/emit.go \| 2 +-` | `make full-smoke` → **EXIT 2** | `FEHLER — golang: die Kette des Ziels ist nicht die zugesagte: [doc-commits nennt den Waechter nicht] (LH-QA-01).` |
| `333` Kommandozeile setzt die Entscheidung | `internal/emit/emit.go \| 2 +-` | `make full-smoke` → **EXIT 2** | `FEHLER — golang (DOC_GATE_ZIEL auf der Kommandozeile, doc-immutable): die Kommandozeile setzte die Entscheidung — make -n druckt die Waechter-Zeile (Exit 0).` |
| `329` Fragment ohne fail-closed | `internal/emit/emit.go \| 2 +-` | `make full-smoke` → **EXIT 2** | `FEHLER — golang (d-check.mk ohne Ziel-Definition, doc-immutable): make doc-immutable blieb ueber einem d-check.mk OHNE die Ziel-Definition GRUEN (Exit 0) — die Vorbindung hat dort kein Rezept.` |
| `327` Vorbindungs-Prüfung ohne Target-Liste | `internal/emit/emit.go \| 2 +-` | `make test` → **EXIT 2** | `--- FAIL: TestAdaptMK_BrichtBeiFehlendemVorbindungsTarget` · `emit_test.go:231: AdaptMK ohne das Target "doc-immutable": kein Fehler — die Vorbindung haette dort kein Rezept (LH-QA-01)` (und dieselbe Zeile für `doc-commits`) |

**Jede Meldung trägt die behauptete Ursache**, nicht „irgendein Rot“:

- `332` fällt an der **Kette** (a) — die Probe des zweiten Aufrufs vertippt sich, das Ziel wählt den
  Abbruch-Zweig, `make -n doc-commits` druckt statt der Wächter-Zeile die Abbruch-Regel. Genau das
  sagt seine Erwartung.
- `333` fällt **an der sechsten** Zusicherung: die fünf davor tragen (im Log: `Waechter greift`
  ×3, `OHNE den Waechter` ×2, `Gegenprobe`), die sechste nennt den Kommandozeilen-Pfad.
- `329` fällt an der **ersten** Zieldefinition-Zusicherung mit der GRUEN-Meldung — dem stillen
  Erfolg, gegen den die fail-closed Zeile steht.
- `327` fällt in der **Go**-Stufe (`make test`), der Text nennt fehlendes Rezept und `LH-QA-01`.

**Grenze dieses Abschnitts:** von den neun neuen Fällen sind vier gefahren (`327`, `329`, `332`,
`333`), fünf nicht (`325`, `326`, `328`, `330`, `331`). Ein nicht gefahrener Fall ist ein Befund nur
für die, die ihn erwartet hätten — hier ist er der benannte Rest (§6), und die vier gefahrenen
decken beide Stufen (`make test`, `make full-smoke`).

---

## 5. Befunde (Verifier-Klasse — **keine** DoD-Verletzung)

| ID | Klasse | Befund | Ort | Klasse/Gewicht |
|---|---|---|---|---|
| **V-1** | `ordnungskante-der-zweiten-ziel-haelfte-ohne-eigenen-zahn` | `make full-smoke` prüft die **Ordnung** („Wächter vor Modul“) nur für `doc-immutable`: `z_guard -ge $z_docker` wird allein aus der `doc-immutable`-Kette berechnet; für `doc-commits` steht nur `grep -qF 'history-range-guard.sh'`. Die DoD-Zusage „er läuft **vor** dem Modul-Lauf“ gilt aber **beiden** Zielen. Eine Drift, die `doc-commits` **nennt**, aber nach dem Modul laufen lässt, fällt heute durch. **Ich habe die Lücke mit eigener Messung geschlossen** (§2.1, beide Ziele Zeile 1/2) — die Zusage ist damit erfüllt, der dauerhafte Wächter bleibt einseitig. | `harness/tools/full-smoke.sh:470`–`479` | **INFO** — erfüllt, nicht bewacht |
| **V-2** | `zahl-ohne-kommando-in-der-sensor-prosa-des-slices` | Der mit diesem Slice geschriebene Abschnitt *Im gebootstrappten Ziel* sagt „**zweimal** gefahren, mit entfernter Ziel-Zeile und … einer Ziel-Zeile ohne Rezept“. Abschnitt (f) fährt inzwischen **vier** rote Läufe (zwei Auslöser × zwei Ziele) plus die zwei Randlagen; die Zusage ist gewachsen, die Zahl steht. Kein `grep`/`make` daneben (`MR-025` Setzung 2 verlangt es). Der Reviewer hat die Stelle als Negativbefund mit Grenze schon benannt (Runde 4, §Negativbefunde) — sie ist damit **getragen**, nicht neu. | `harness/sensors/history-range-guard.md`, Abschnitt *Im gebootstrappten Ziel* | **INFO** |
| **V-3** | `zwei-fassungen-eines-waechters-ohne-vergleich` | Zwei Fassungen derselben Logik: die Dogfood-Kopie `harness/tools/history-range-guard.sh` (bats-getestet, trägt die zwei `--decide`-Einstiege) und `internal/emit/templates/enforce/history-range-guard.sh` (emittiert, Go-Textanker + E2E). Die Sensor-Prosa sagt „die Entscheidung ist dieselbe Funktion“ — **am kommentar-bereinigten `diff` heute bestätigt**, aber **kein Sensor vergleicht die zwei Fassungen**: ändert jemand `decide()` in einer und nicht in der anderen, bleiben beide Suiten grün und der Satz wird still falsch. | `harness/tools/history-range-guard.sh` ↔ `internal/emit/templates/enforce/history-range-guard.sh` | **INFO** |

**Grenze V-4 (Herkunft, kein Befund an der Sache).** Der DoD-Punkt 2 und §1 berufen sich auf
„[`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) **Setzung 3**“ als
Quelle der Klasse. `MR-007` Setzung 3 heißt *„Vollständigkeits-Check ist Pflicht, nicht Kür“* und
handelt von `sha256sum -c` / `baseline-verify` — sie **nennt** die Klasse („ein stilles Grün“), ihr
**Gegenstand** ist aber nicht die Commit-Range. Der DoD-Punkt beschreibt seinen Fall selbst
vollständig, ist damit prüfbar und geprüft (§2.2); die Zitier-Kette stammt unverändert aus der
Vorgänger-Arbeit (`harness/tools/history-range-guard.sh:10`) und steht in
`harness/sensors/history-range-guard.md:15` außerhalb dieses Deltas. Benannt, nicht still
entschieden — ob der Planner die Fundstelle schärfen will, ist seine Entscheidung.

---

## 6. Was ich nicht geprüft habe, und die Rest-Unsicherheit

1. **Kein voller `make mutate`.** Der repo-weite Satz läuft Post-integration
   (`.github/workflows/mutate.yml`, `schedule` + `workflow_dispatch`); ich habe vier der neun neuen
   Fälle **einzeln** gefahren (§4). Ob die übrigen fünf ihren Wächter färben, ist **ungemessen**
   geblieben — ihr Beleg liegt in den Commit-Messages und in den Review-Runden, nicht in diesem Lauf.
2. **Die zwei Commits der Nachbar-Slices** (`mutate.yml`, `ci.yml`, `harness/README.md`-CI-Absatz,
   `harness/sensors/mutate.md`, die zwei Anweisungssätze): nur gegen die §1-Abgrenzung geprüft, **nicht
   inhaltlich** — sie gehören einem anderen Gegenstand und einer anderen Rolle.
3. **Kein Pin-Sprung.** Risiko 3 aus §6 („der Pin bewegt sich unter dem Slice weg“) ist nicht
   geprüft: ob ein künftiges `d-check` die leere Range selbst von der leeren Menge unterscheidet,
   entscheidet kein Sensor dieses Repos.
4. **Die Span-/Telemetrie-Achse** (ob dieser Lauf seine Rollen-Spans trägt) ist nicht Gegenstand
   dieses Berichts.
5. **`harness/tools/history-range-guard.sh` selbst** ist nicht neu geprüft: die Dogfood-Kopie und
   ihre bats-Datei sind Vorgänger-Arbeit (`slice-123`); mein Diff-Vergleich deckt nur die
   Gleichheit der Entscheidungslogik (V-3).
6. **Rest-Unsicherheit der Mutations-Belege im Arbeitsbaum.** Die vier Fälle liefen **im** Baum, nicht
   in einer Isolationskopie wie im Treiber. Ich habe nach jedem Fall zurückgenommen und den leeren
   `git status` belegt; ein Rest bleibt: `make gates` und `make full-smoke` dieses Berichts liefen
   über den **unverfälschten** Stand, die Mutations-Läufe dazwischen über verfälschte — die
   Reihenfolge ist an `/tmp/verif/*.log` mit Zeitstempeln ablesbar.

---

## Verdikt

**0 DoD-Verletzungen.** Sechs der zehn §2-Punkte sind **erfüllt** und einzeln belegt; vier sind
**nicht fällig** und gehören nach `AGENTS.md` §3.10 dem Planner (Closure-Notiz, Register,
Risiko-Ausgänge, drei Paarungen). Der Plan hat geliefert, was er zusagt: das gebootstrappte Ziel
bricht über einer auflösbaren, aber leeren Commit-Range an **beiden** history-lesenden Targets ab,
bevor der Container startet — mit einer Meldung, die die Ursache nennt, und ohne die zwei Wege
zurück in den stillen Erfolg (fehlende Ziel-Definition, Kommandozeilen-Zuweisung), die die
Review-Runden gefunden haben.

**Nicht merge-blockierend, aber zur Kenntnis in die Closure:** drei INFO-Klassen (V-1
ordnungskante der zweiten Hälfte, V-2 Zahl ohne Kommando in der Sensor-Prosa, V-3 zwei Fassungen
ohne Vergleich) und die Herkunfts-Grenze V-4. V-1 ist die einzige, die eine **Zusage** betrifft, und
sie ist mit diesem Lauf gemessen erfüllt — wer sie dauerhaft bewachen will, gibt der
`doc-commits`-Kette dieselbe Ordnungs-Prüfung wie der `doc-immutable`-Kette; das ist ein
Implementer-Schnitt, **kein Vorschlag von hier** (Modul 11 §Harness-Einordnung; die Entscheidung
fällt dort, wo die Arbeit liegt).

**Übergabe:** dieser Bericht an den **Planner** (DoD-Konformität + Plan-vs-Code-Diff, die Eingabe
der Closure); die drei Klassen aus §5 gehen mit den Review-Klassen der vier Runden in die
Closure-Notiz §7 und von dort ins Beobachtungs-Register.

*Keine Erwartungswerte* ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — Datei-, Test- und Ausgabezahlen dieses Berichts wandern mit dem Baum und stehen je
neben dem Kommando, das sie liefert.

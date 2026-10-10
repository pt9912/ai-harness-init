# Review: slice-d-check-pin-bringt-den-go-sicherheitsfix — Nachprüfung am Pin v0.86.0

**Rolle:** Reviewer (`.harness/skills/reviewer.md`), frischer Kontext. **Datum:** 2026-10-10.

**Summary:** 0 HIGH · 0 MEDIUM · 0 LOW · 2 INFO. Pin und Digest stimmen, die Bilanz ist vollständig,
die Go-Fassung ist gemessen, und der `reviews`-Kommentar hält in jeder gefahrenen Sonde gegen die echte
v0.86.0. MEDIUM-1 aus dem ersten Review ist erledigt.

**Gegenstand überholt:** Mit `43091527` ist die Zielversion des Plans auf v0.86.1 umgezogen. Dieser
Report gilt für `53107f53` am Pin v0.86.0. Digest, Go-Fassung, Bilanz und `reviews`-Sonden sind an
v0.86.1 neu zu fahren. `make gates` lief in einem Klon von `43091527` plus diesem Report → EXIT 0. Im
Arbeitsbaum lief es rot (`TestDCheckConfig_ReviewsBleibtKommentarBlock`, Pin v0.86.1), weil ein
paralleler Lauf `d-check.mk`/`emit.go` auf v0.86.1 umstellt, ohne dass die Prosa schon nachgezogen ist.
Das ist dessen unfertiger Stand und kein Befund dieses Diffs.

## Eingang

- **Diff:** `4520ab1e..53107f53` ohne Report-Dateien: `724b63ff`, `a2b805ea` (Plan), `53107f53`
  (`d-check.mk`, `internal/emit/emit.go`, `internal/emit/emit_test.go`,
  `internal/emit/templates/d-check.yml`, `test/mutations/666-…`, `667-…`).
- **Plan:** `slice-d-check-pin-bringt-den-go-sicherheitsfix` (in `in-progress/`), Zielversion v0.86.0.
- **Regeln:** MR-063, MR-065, MR-067, MR-084, MR-086, AGENTS.md §3.6/§3.7.

## Findings

### INFO-1 — Die Zuordnung über `match: name` hat eine Token-Grenze, die der Kommentar nicht nennt

- `kategorie`: INFO · `quelle`: AGENTS.md §3.6 · `pfad`: `internal/emit/templates/d-check.yml:41-45`
- `befund`: Der Kommentar sagt, `match: name` ordne über den Basisnamen „im Report-Namen“ zu, und
  nennt als einzige Ausnahme den längeren Basisnamen eines zweiten Plans unter done-dir. Die Sonde C3
  (Plan `slice-ca`, Report `2026-01-01-slice-cache.md`, kein Plan `slice-cache`) gibt `review-missing`
  für `slice-ca`; die Sonde C1 (`slice-cache`, Report `…-slice-cache-nachpruefung.md`) gibt EXIT 0.
  Die Zuordnung verlangt also eine Grenze hinter dem Namen. Wer sich darauf verlässt, bekommt ein
  lautes Rot statt eines stillen Grüns, und nach der Namensregel des Repos ist der Fall nicht
  erreichbar.
- `verifizierbar`: ja (Sonde unten) · `klasse`: Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

### INFO-2 — Die Pin-Fassung im `codepaths`-Kommentar ist nicht an `DefaultImage` gekoppelt

- `kategorie`: INFO · `quelle`: AGENTS.md §3.6 · `pfad`: `internal/emit/templates/d-check.yml:27-28`
- `befund`: `TestDCheckConfig_ReviewsBleibtKommentarBlock` koppelt nur die Prosa des `reviews`-Blocks an
  den Tag (Ausschnitt `# reviews bleibt aus.` bis `# reviews:`). „Still bleiben am Pin v0.86.0“ im
  `codepaths`-Block wurde von Hand nachgezogen. Beim nächsten Sprung kann es neben dem neuen Pin stehen
  bleiben und kein Test meldet das. Der Testkopf sagt das selbst nicht anders zu, darum kein höherer
  Rang.
- `verifizierbar`: nein · `klasse`: Aussage über das gepinnte Werkzeug ohne Blick in seinen Stand

## Sonden und Belege

- **Digest:** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.86.0` → OCI-Index
  `sha256:d90200e94db311a70f9b15045e1290feecde03e9185ad78fb1ebea265e6ee44b` (amd64 `7fbd5a20…`, arm64
  `59e52bac…`). Derselbe Wert steht in `d-check.mk:68,79` und `internal/emit/emit.go:34`, das gebootstrappte
  Ziel trägt ihn ebenfalls. `git grep -e v0.85.0 -e c07f1fe6` über die lebenden Dateien (ohne
  Zeitdokumente, MR-Dateien und Baseline) findet nichts. Hunk-Kommando aus dem Kopfkommentar → `6`.
- **Go-Fassung (Stichprobe arm64):** `/d-check` per `docker create --platform linux/arm64 …@sha256:59e52bac…`
  und `docker cp` herausgeholt, dann `go version -m` im `golang@sha256:e0174e51…` → `go1.27.2`,
  `GOARCH=arm64`.
- **Bilanz:** gelesen, nicht nachgefahren. Fünf Stufen, alle Diffs leer. Neun aktive Module im
  Dogfood und neun im Ziel. Die Grund-Codes aus Stufe 3 und 5 decken jedes Modul ab. Die Prüf-Bedingung
  nach MR-067 und die Angabe nach MR-065 sind genannt. Neue Defaults treffen kein aktives Modul:
  `grep -c 'skip-pattern\|skip-allows-empty' .d-check.yml` → 0, und im Template steht der Schlüssel nur
  in Kommentarzeilen. Kein Modul ohne Basis. Die Bilanz ist vollständig.
- **`reviews`-Sonde gegen die echte v0.86.0:** Ziel mit `.harness/state/bin/ai-harness-init --lang go` erzeugt,
  dann wie im Trigger aktiviert (`reviews` in `modules:`, Block ohne `#`, `match: name`), dann
  `make -s docs-check`. Je Fall eine Kopie unter dem Scratchpad.

  | Fall | Lage | Ergebnis |
  |---|---|---|
  | A | done-dir leer | EXIT 2, `review-missing` leere Prüfmenge |
  | B1 | `slice-cache` + `slice-cache-warmup`, Report nur `…-warmup` | EXIT 2 für `slice-cache` |
  | B2 | Reports für beide | EXIT 0 |
  | D2 | ein Report-Name trägt beide Namen | EXIT 2 für `slice-cache` (nur der längere gedeckt) |
  | E1 | längerer Name liegt in `in-progress/`, nicht unter done-dir | kein `review-missing` (nur `planning-drift` der Sonde) |
  | C1 | Report `…-slice-cache-nachpruefung`, kein zweiter Plan | EXIT 0 |
  | C3 | Plan `slice-ca`, Report `…-slice-cache` | EXIT 2 (INFO-1) |
  | D1 | ein Plan ohne Review-Zeile | EXIT 0 |
  | F1 | `skip-allows-empty` ohne `skip-pattern` | Exit 2, Konfig-Fehler „halbe Aktivierung“ |
  | F2 | `skip-pattern` + `skip-allows-empty`, done-dir leer | EXIT 2, leere Prüfmenge |
  | F3 | dazu ein Stub, den `skip-pattern` herausnimmt | EXIT 0 |
  | F5 | F3 + `slice-neu` mit Review-Zeile ohne Report | EXIT 2 |

  „Nur der längste Basisname“ (B1, D2, E1) und „`skip-allows-empty` ändert den roten Start nicht“
  (F1, F2, F3) stimmen. Der Trigger sagt keine Aktivierung zu, die rot startet: Bei liegendem Plan und
  Report je Plan mit Review-Zeile sind B2, C1 und D1 grün. Das Rot in B1 und D2 beschreibt der Satz
  direkt davor.
- **Mutationen:** `MUTATE_CASES='666-… 667-…' make mutate` → `2 ok, 0 Befund(e)`. Gegenprobe in
  einer `git archive`-Kopie: beide Mutationen angewandt, `t.Skip` **nur** in
  `TestDCheckConfig_ReviewsBleibtKommentarBlock`, dann `make test-go` → rc 0, alle Pakete `ok`. Der
  benannte Test bindet beide Fälle allein.
- **Amend in `53107f53`:** Laut Reflog ist `e8667bc2` (Elter `a2b805ea`, eigener Commit,
  04:53:59) per `commit (amend)` 13 s später zu `53107f53` geworden. `git reflog show origin/main` geht
  von `a2b805ea` direkt auf `53107f53`, `e8667bc2` wurde also nie gepusht.
  `git diff --stat e8667bc2 53107f53` → nur `internal/emit/templates/d-check.yml`, eine Datei aus §3
  des Plans. Kein fremder Pfad.

## Geprüft, ohne Befund

- **Pin (Liefer-Punkt 1):** Index-Digest an beiden Stellen, keine Altfassung in lebenden Dateien.
- **Strenge-Bilanz (Liefer-Punkt 2):** vollständig nach MR-063/065/067, keine Senkung (§3.5).
- **Go-Fassung (Liefer-Punkt 3):** arm64 nachgemessen, Methode trägt.
- **`reviews`-Kommentar und Trigger (MR-086):** Aussagen am Pin v0.86.0 gefahren (Tabelle oben),
  `match: name` im Block, das Modul bleibt aus `modules:`.
- **Test und Mutationen (§3.6):** Die Kopplung von Tag und Prosa sowie die Zeile `match: name` sind
  gebunden, der benannte Test bindet allein, und die Grenze steht im Testkopf.
- **Kommentar-Klassen (§3.7):** Die neuen Kommentare beschreiben die Stelle im Indikativ, ohne Chronik.
- **Amend:** nur eigener, ungepushter Commit, nur ein Plan-Pfad.
- **MEDIUM-1 (erster Review):** erledigt. Der Block beschreibt v0.86.0 und trägt `match: name`, und der
  Trigger nennt den Schlüssel.

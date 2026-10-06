# Verifikation — slice-d-check-pin-macht-den-range-leerfall-laut (d-check-Pin `v0.81.0`)

Rolle Verifier (Modul 11). Eingaben: Plan §1/§2/§6, Review `2026-10-06-d-check-pin-v0810-review.md`
samt Nachrunde, `MR-079`, Implementer-Commits `dd26964c`, `0b89450c`, `1ff70b83`, `d90d016b`.
Closure-Punkte der DoD (Notiz, Register, Risiko-Ausgänge, Paarungen) sind Planner-Arbeit und hier
nicht verifiziert.

- **L1 — bestätigt.** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.81.0` →
  `sha256:c6e61342…c92e5`, gleich `DCHECK_DIGEST` in `d-check.mk` und `DefaultDigest` in
  `internal/emit/emit.go`; beide Tags `v0.81.0`. Rot an der realen Quelle: `DefaultImage` in
  `emit.go` auf `v0.79.0` gedreht → `make test-go` Exit 2,
  `--- FAIL: TestDefaultImage_MatchesCanonical … emit.DefaultImage "…:v0.79.0" != kanonische Quelle "…:v0.81.0" (Tag-Drift)`;
  zurückgesetzt, Baum sauber.
- **L2 — bestätigt.** `make full-smoke` → Exit 0. Die Leerfall-Stufe meldet am vollständigen Klon
  `doc-commits` `20 Datei(en) geprüft, 0 Befund(e)` und `doc-immutable` Exit 2,
  `Range-Leerfall "HEAD".."HEAD" — … es wurde nichts geprüft`. Rot mit der behaupteten Ursache über
  den engsten Weg: der Stufen-Aufruf `make -f d-check.mk doc-immutable RANGE=HEAD..HEAD` am frisch
  emittierten, committeten `--lang go`-Ziel (`git rev-list --count HEAD..HEAD` → 0) unter dem
  `v0.79.0`-Digest (`b4b8756b…`) → Exit 0, `0 Befund(e)`: die Bedingung `roh_rc -eq 0` der Stufe
  greift („bleibt über der leeren Range grün“); unter `v0.81.0` Exit 2 mit `Range-Leerfall`.
  `make e2e-abdeckung` → Baum unverändert (`git diff --quiet`). Fall 325:
  `make mutate MUTATE_CASES=325-vorlauf-waechter-verliert-doc-immutable` → `1 ok, 0 Befund(e)`.
- **L3 — bestätigt (Stichprobe, eine Stufe, die der Review nicht fuhr).** Ziel aus
  `.harness/state/bin/ai-harness-init --lang go` in ein frisches Repo; Angabe nach `MR-065`:
  frisch emittiertes Verzeichnis, kein Objektspeicher, `docs-check` liest keine Historie. Je Digest
  per `DCHECK_DIGEST`-Override: unverändert `20 Datei(en) geprüft, 0 Befund(e)` unter beiden; mit
  entwerteten Markern (6 Dateien) ebenso, `diff` der Befundzeilen leer. Nicht-Null-Basis mit einer
  Sonde (`links`, `anchors`, `spans`) unter beiden Digests `21 Datei(en) geprüft, 4 Befund(e)`, je 1
  `anchor-missing`, `repo-escape`, `span-unclosed`, `target-missing`. Deckt sich mit `MR-079`.
  Dogfood-Stufen übernommen aus Review und `MR-079`, nicht nachgefahren.
- **Review- und Architect-Punkt — bestätigt.** Review mit Nachrunde liegt vor; `MR-079` liegt vor.
  CI: `adr-immutable` in `.github/workflows/ci.yml` checkt mit `fetch-depth: 0` aus und fährt
  `make adr-immutable` (Wächter + `vcs`) — vom flachen Abbruch über nicht leerer Range nicht
  betroffen.
- **Befund V-1 (LOW) — unbenannte Lücke.** Weder der Pin-Kopplungstest
  (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical`) noch die neue Stufe
  `leerfall_laut_ohne_waechter` hat einen Fall in `test/mutations/`
  (`grep -l 'MatchesCanonical\|DefaultDigest\|DefaultImage\|leerfall_laut' test/mutations/*` → leer);
  beide Zähne sind damit von `make mutate` unbewacht (`AGENTS.md` §3.6). Plan §6 und `MR-079`
  nennen das nicht. Für den Planner: als Risiko-Ausgang oder Folge-Slice benennen.
- **Offene Punkte für den Planner (benannt, kein neuer Befund).** (a) Der Abbruch von `vcs` im
  flachen Klon über einer **nicht leeren** Range (Tiefe 2, `HEAD~1..HEAD`) hält kein Sensor. Plan §6
  führt ihn als Risiko 1, Review F-4 ebenso. `MR-079` §Grenze nennt nur „Einzelläufe“. Die
  Sensor-Doku sagt nicht, dass kein Wächter ihn hält; F-4 ist weiter offen. (b) Die Tabellenzeile
  *flacher Klon* in `harness/sensors/history-range-guard.md` fährt keine Stufe: Schritt (d) läuft am
  vollständigen Klon. Benannt ist das nur in Review F-4, nicht in Plan oder `MR-079`. Beides gehört
  in den Ausgang von Risiko 1. `make gates`: ein Lauf über dem Baum mit diesem Bericht, Ergebnis in
  der Commit-Message.

Laufzeit: `make full-smoke` 128 s; Verifikation gesamt ≈ 25 min.

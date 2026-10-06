# Verifikation — slice-d-check-pin-nimmt-die-authority-liste (d-check-Pin `v0.82.0`)

Rolle Verifier (Modul 11). Eingaben: Plan §1/§2/§6, Review `2026-10-06-d-check-pin-v0820-review.md`
(F-1, F-2, F-3), `MR-080`, Commits `6fb5058f`, `2d1d2a73`, `971504c5`, `251657f9`. Alle Proben in
Kopien unter dem Scratchpad; der Baum ist unverändert. Closure-Punkte der DoD (Notiz, Register,
Risiko-Ausgänge, Paarungen) sind Planner-Arbeit und hier nicht verifiziert.

- **L1 — bestätigt.** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.82.0` →
  `sha256:d28e9437…532e0c8`, gleich `d-check.mk:79` und `internal/emit/emit.go:33`, Tags an beiden
  Stellen `v0.82.0`. Rot an der realen Quelle: `emit.go` auf den Stand `6fb5058f~1` gedreht →
  `make test-go` Exit 2, `TestDefaultDigest_MatchesCanonical`
  (`emit.DefaultDigest "sha256:c6e61342…" != kanonische Pin-Quelle "sha256:d28e9437…" (Drift)`) und
  `TestDefaultImage_MatchesCanonical` (`… "…:v0.81.0" != … "…:v0.82.0" (Tag-Drift)`); zurückgesetzt,
  `git status` leer.
- **L2 — bestätigt; F-3 behoben.** Ziel nach den Kommandos aus `MR-080` (*Kommandos, Ziel*)
  nachgefahren: `make host-bin`, `git init -q "$Z" && ai-harness-init --lang go --name rv "$Z"`
  (ohne vorhandenen Zielordner Exit 2), Lauf `make -s -C "$Z" docs-check DCHECK_DIGEST=<OLD|NEW>`.
  Unverändert unter beiden Digests `20 Datei(en) geprüft, 0 Befund(e)`; mit den fünf Sonden
  (`ADR-0001` als Text, `matrix` über `spec/architecture.md`, Zelle `Vertrag` um 230 Zeichen) beide
  `22 Datei(en) geprüft, 10 Befund(e)`, alle sechs Module mit Basis, `diff` der Befundzeilen leer.
  Dogfood Stufe 1 an `git archive 6fb5058f` (alte Kopie mit `d-check.mk` aus `6fb5058f~1`,
  Symlinks 10 = `git ls-tree` 10, `-type f` leer): beide `2278 Datei(en) geprüft, 0 Befund(e)`,
  `diff` leer. Stufen 2/3 des Dogfoods aus dem Review übernommen, nicht nachgefahren.
  `make full-smoke` → `EXIT=0`; die Leerfall-Stufe meldet unter dem emittierten `v0.82.0`
  `doc-immutable` Exit 2 mit `Range-Leerfall "HEAD".."HEAD" — … es wurde nichts geprüft`.
- **L3 — bestätigt, mit Befund V-1.** Zwei Kopien von `HEAD`, `authority: harness/README.md` gegen
  `[harness/README.md]`, unter `v0.82.0`. Grün: Normallauf (`2280 … 0 Befund(e)`), `--json`
  (stdout und stderr), `make doc-targets`, `make doc-doctor` (Ströme getrennt) byte-gleich. Rot mit
  drei `.PHONY`-Sonden (undokumentiert · nur in einer `AGENTS.md`-Tabellenzeile · nur in
  README-Prosa): jede `gate-undocumented` unter beiden Formen, Normallauf/`--json`/`--doctor`
  byte-gleich, `doc-targets` mit getrennten Strömen dreimal byte-gleich.
  **V-1 (LOW, Zusage):** `doc-targets` mit `2>&1` unterscheidet sich einmal zwischen String und
  Liste (Zusammenfassungs-Zeile vor bzw. nach den Befundzeilen) — dieselbe Strom-Verzahnung, die
  `MR-080` nur für `--doctor` als Grenze nennt. Die Byte-Identitäts-Aussage gilt für jeden Lauf
  nur bei getrennten Strömen; der Satz in `MR-080` schränkt sie nur bei `--doctor` ein. Für Planner →
  Architect: Grenze auf alle Läufe ziehen (Bedeutung, keine Wortwahl).
- **F-1, F-2 — bestätigt.** `MR-080` führt das Trigger-Audit zu `ADR-0045` (Trigger Z. 386); Belege
  nachgefahren: ``grep -cE '^\| `make ' AGENTS.md`` → 0, `ls harness/mk` → nicht vorhanden,
  `grep -c 'es gibt nur einen Index' …/v6.13.0/templates/.d-check.yml` → 1. Gegenprobe der Liste:
  `authority: [harness/README.md, AGENTS.md]` nimmt die AGENTS-Sonde aus `gate-undocumented`, die
  Prosa-Sonde bleibt — die Vereinigung wirkt, scopt nicht nach Abschnitt, und ist mit 0
  AGENTS-Tabellenzeilen heute folgenlos. Der Kommentar `.d-check.yml:157-164` beschreibt die
  Konfiguration wahr (`authority` = `harness/README.md`, `doc-tables` `[AGENTS.md, harness/README.md]`;
  AGENTS-only und Prosa-only fallen beide, wie er sagt). `make gates` am Ende: siehe letzte Zeile.

Laufzeit: Verifikation 2026-10-06, `make gates` Exit 0.

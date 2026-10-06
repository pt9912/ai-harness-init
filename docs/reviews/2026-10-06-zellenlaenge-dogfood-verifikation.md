# Verifikation slice-werkzeug-zellenlaenge-hat-einen-sensor (Rolle Verifier)

- **DoD (1) bestätigt:** Eintrag in `.d-check.yml` (Vertrag 150, Tut was 260, kein `hint`/`exempt-paths`, Kommentar mit Kommando); `make doc-structure` und `make docs-check`: `2234 Datei(en) geprüft, 0 Befund(e)`.
- **DoD (2) bestätigt, Rot an der realen `harness/README.md`** (jeweils `git checkout --` danach, Baum sauber): `Tut was` 257→273: `section-cell-oversized … hat 273 Zeichen, erlaubt sind 260` (Z. 78); `Vertrag` 149→160: `… hat 160 Zeichen, erlaubt sind 150` (Z. 50); Kopf `Vertrag`/`Tut was` umbenannt: je `section-column-missing`.
- **Schwelle (Sonde `awk length` + d-check selbst, nicht der `wc -m` des Implementers):** Bestand 257/149; Schwelle 257/149 grün (0 Befunde), 256 → Befund (257 > 256), Vertrag 148 → Befund (149 > 148). Zeichen, nicht Bytes, bestätigt.
- **Doku `docs-check.md`:** 257/149 tragen ihr Kommando, die Grenzen stimmen (`failure_form()` führt kein `docs-check`-Muster: 0 Treffer; `Bindung` unbegrenzt; Wachstums- statt Kürze-Schranke). Nicht eigens gefahren: die 260/261- und 150/151-Zeilen der Tabelle (Schwellenmitte durch 257/256 und 149/148 gedeckt). Abgrenzung des Plans gehalten: Diff = `.d-check.yml`, `docs-check.md`, Review; kein ADR, kein emittierter Teil. Keine Befunde. `make gates` Exit 0.
- Laufzeit: ca. 300 s (davon `make gates` 177 s).

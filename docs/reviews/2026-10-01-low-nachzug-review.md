# Review — Lastenheft 0.24.1/0.24.2 und LOW-Nachzüge (LH-FA-13, LH-FA-15)

Rolle: Reviewer · Gegenstand: `7105f2fa`, `d2e8beac` (nur `spec/lastenheft.md`), `c3a5edd5`, `b9382904` · Bezug: F-3 bis F-6 aus `2026-10-01-lh-fa-10-schnitt-review.md`

## Findings

| # | Kategorie | Quelle | Pfad | Befund | verifizierbar | klasse |
|---|---|---|---|---|---|---|
| 1 | INFO | LH-FA-13 | `spec/spezifikation.md` SPEC-049 | Die Zelle trägt zwei Aussagen: „Haupt-Kontext ohne Zahl" (jetzt LH-FA-13, trägt es) und die Splitting-Pflicht samt Größe des Sammelpostens (steht in LH-FA-17). Die Zeile zeigt nur auf LH-FA-13; die zweite Hälfte bleibt dort ohne Kriterium. | nein | Zuordnung nur zur Hälfte |
| 2 | INFO | LH-FA-16 | `spec/spezifikation.md` SPEC-060 | Bleibt bei LH-FA-16: `seq`/Nebenläufigkeit/Strom-Trennung sind dort belegt, die Ableitung von `slice`/`requirement`/`branch` steht in LH-FA-13. Bewusst nicht geändert (Auftrag), nur benannt. | nein | Zuordnung nur zur Hälfte |

Keine MEDIUM/HIGH.

## Geprüft, ohne Befund

- **Schwerpunkt 1 (Verschiebung):** Wortlaut der „Benannten Grenze" im Diff `d2e8beac` zeichenidentisch; in LH-FA-10 steht sie nicht mehr (nur LH-FA-15 Z. 383, plus die zwei fremden Grenzen in FA-11/FA-12). `git grep 'Benannte Grenze'` über spec/harness/internal/test/docs/user: einziger Verweis darauf ist `fieldlist_test.go:160` (jetzt LH-FA-15, gültig). F-3: „Für den Haupt-Kontext trägt der Span keine Zahl" ist Zusage über das Verhalten des Trägers, deckt sich mit SPEC-049 („Wert steht leer da", Payload-Aussage dort ausdrücklich als gelesen/vermessen getrennt) und kollidiert nicht mit SPEC-050 (Ablehnungsliste `cwd`/`effort`/`prompt_id`).
- **Schwerpunkt 2 (Zeilen):** SPEC-008 gegen LH-FA-16 „Strom und Sequenz" (Paar Sitzung/Agent) trägt; SPEC-049 gegen LH-FA-13 „Token- und Cache-Felder" trägt bis auf Finding 1; SPEC-060 s. Finding 2.
- **Schwerpunkt 3 (Kommentar-Zeiger):** `full-smoke.sh` (Kommentar und OK-Zeile) nennen LH-FA-13 für die Feldliste, LH-FA-13 Beschreibung/„geschlossene Feldliste … lesbar" stimmt; `fieldlist_test.go` „LH-FA-15 §Benannte Grenze" stimmt mit dem Lastenheft. Die Rollen-Typen-Zeile (`slice-097/LH-FA-10`) bleibt richtig (Träger/Rollen-Typen).
- **Schwerpunkt 4 (CR-Form, MR-015):** je Version ein eigener Commit, `--name-only` je nur `spec/lastenheft.md`; Version-Bump 0.24.0→0.24.1→0.24.2; Historie-Zeilen mit Quelle „Nutzer-Entscheidung" und ohne Anlass-Erzählung.

## Sensor

`make gates`: EXIT 0.

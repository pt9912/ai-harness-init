# Review: slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst

Rolle: Reviewer · Bezug: LH-FA-12, LH-FA-13, LH-FA-15, LH-FA-16, LH-FA-17 · AGENTS.md §3.6/§3.8 ·
Gegenstand: 3e2d25f5, 8fbd8ea4, 42feef25 (Implementer), c6badd9b (Architect).
Sensor: `make gates` → EXIT=0. Bruchproben in Scratchpad-Kopien, kein Rest im Baum.

## Findings

**F1 — MEDIUM · AGENTS.md §3.8/§3.10 (Rollen-Konflikt, nicht herabgestuft).** c6badd9b berührt neben
`AGENTS.md` die `state.md` einer Beobachtung (`Stand: geplant` → `verkörpert in AGENTS.md §3.6`).
§3.8 verlangt „ausschließlich Artefakte derselben schreibenden Rolle" — ADRs, AGENTS.md,
Konventionsspeicher; `state.md` steht dort nicht. ADR-0024 (derivatives Register gehört der Rolle seines
Originals) kann es tragen, ist aber nicht benannt; §3.10 bindet „die Fortschreibung des
Beobachtungs-Registers" an den Planner-Abschluss, und der Slice ist nicht geschlossen. Verdikt
Architect/Planner nötig (Commit-Zuschnitt nachträglich nur an `git log --stat` ablesbar). verifizierbar: nein.
klasse: Architect-Commit berührt Register-Zustand.

**F2 — LOW · AGENTS.md §3.6 (Zusage-Reichweite).** Der neue Absatz sagt „Den Wortlaut hält allein der Fall
in `test/e2e-abdeckung.bats` … byte-gleich gegen die Deklaration". Der Fall (`halter`, `cmp -s`) hält nur
die Gleichheit Deklaration ↔ erzeugte Datei: wird die Teilabdeckung in `full-smoke.sh` gestrichen und
`make e2e-abdeckung` neu gefahren, bleibt er grün (gelesen, `test/e2e-abdeckung.bats:105-117`; nicht
gefahren). Der Folgesatz „kein Sensor liest die Kurzbeschreibung gegen den Körper ihrer Stufe" benennt die
Lücke, aber „hält den Wortlaut" liest sich weiter. Auch DoD 1 „Teilabdeckung entfernt → ein Fall rot" ist
nur ohne Neuerzeugung wahr. verifizierbar: ja. klasse: Wächter hält Synchronität, nicht Inhalt.

**F3 — INFO · Bedeutung (Stufen 2 und 5).** Beide deklarieren weiter `LH-FA-13` ohne Teilabdeckungs-Text
(`full-smoke.sh:429`, `:2277`; messen dort nur `rollen_typen_im_ziel`/`feldliste_im_ziel`). Plan §1 schließt
„andere Stufen" aus, F1 des Vorberichts nannte nur 3 und 6 — kein Verstoß, aber dieselbe Klasse, im Register zu führen.

**F4 — INFO · `rolle_im_ziel` (Zähl-Zahn, Reichweite).** Gezählt wird nur die Anzahl, nicht die
Namensmenge: Ziel mit `architect.md` entfernt und einer Kopie `planner2.md` (`name: planner`) → 6 = 6,
Funktion grün (gefahren). Gefangen wird das von `rollen_typen_im_ziel` (je Quelldatei) vor dem Gate-Lauf.
Der Kommentar sagt „Zahl … gleicht der Zahl" und behauptet nicht mehr; kein Befund gegen die Zusage.

## Geprüft, ohne Befund

- **F1–F3 des Vorberichts behoben:** Kurzbeschreibungen Stufe 3/6 nennen FA-13/15/16/17-Teilmessung; gegen
  Körper und Wortlaut geprüft: FA-13 Pflichtfeld-Schlüssel (`traeger_im_ziel` Feldschleife) + Feldlisten-Abgleich
  stimmen; FA-15 besetzt/leer-unbekannt stimmt, `tool_response.agentType` steht im Go-Test
  `internal/span/response_test.go` (`TestSpawnedRoleIsNormalised`, B1); FA-16 Aufbewahrung (`span-clean`,
  Wachstums-Satz) und Exit 0/leeres stdout für gültigen Payload stimmen, Strom/Folge, Lock, kaputter Payload
  sind nicht behauptet; FA-17 „nur Abdeckung zuerst" untertreibt (keine Bilanz + Grund sind mitgemessen) — zulässig.
- **Zähl-Prüfung gefahren** (Scratchpad, echter Träger `.harness/state/bin`, echter Wrapper, Typ-Quelle
  `internal/emit/templates/agents`): Basis grün (8 Payloads); ein Typ weniger → rot mit Zählmeldung;
  Zählzweig auf `-gt 99` mutiert (nicht vom Implementer gefahren) → grün, also bindet die Zählung allein
  den Ausfall; leere Quelle → rot (Soll 0 fängt 0=0 ab); Quelle ist das Repo-Verzeichnis, Ziel `.claude/agents`
  — keine Tautologie. Tausch gegen Fremdtyp fällt an der Rollen-Ableitung.
- **AGENTS.md-Form:** Falsch/Richtig, „Ein Wächter existiert nicht", Herkunfts-Anker `· seit slice-…` stehen;
  kein Konflikt mit §3.7 (Anker ist ein auflösbares Feld); kein Eintrag im Adaptions-Block nötig (Lücke, keine
  Abweichung); die Hard-Rule-Änderung selbst liegt in eigenem Architect-Commit (bis auf F1).
- **§3.7-Kommentar `rolle_im_ziel`:** Zusage/Grenze/Rang-Zeiger, keine Befund-Kennung, Go-Test-Pfad existiert.
- **`test/e2e-abdeckung.bats`:** Rot nur bei Abweichung Deklaration/Datei bzw. fehlender Deklaration (gelesen); siehe F2.

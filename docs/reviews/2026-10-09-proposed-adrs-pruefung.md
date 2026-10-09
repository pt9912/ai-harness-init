# Prüfung: ADR-0062, ADR-0063, ADR-0064, ADR-0068 gegen Code und Bestand — 2026-10-09

**Rolle:** Architect · **Gegenstand:** Stand `126b1009` · **Status geändert:** keiner (der
Auftraggeber nimmt an).

**Summary:** ADR-0064 und ADR-0068 sind bereits `Accepted` (kein Prüfgegenstand mehr). ADR-0063
annahmereif nach Nachtrag einer Reviewer-Runde. ADR-0062 annahmereif nach Nachtrag einer
Reviewer-Runde.

## ADR-0064, ADR-0068 — bereits Accepted

`grep -h '^\*\*Status' docs/plan/adr/0064-*.md docs/plan/adr/0068-*.md` → beide `**Status:** Accepted`
(angenommen 2026-09-24 bzw. 2026-09-26, Beleg je in der §Geschichte der Datei). Der Index führt beide
als `Accepted`. Nichts zu tun.

## ADR-0063 — Das Werkzeug sagt seine Fassung

- **Umgesetzt:** ja. `cmd/ai-harness-init/version.go` (`fassung`, Default leer; Fehlt-Fall auf
  stderr, Exit 2), `Dockerfile` (`-X main.fassung` nur bei nicht-leerem `TRAEGER_VERSION`),
  `Makefile` reicht `TRAEGER_VERSION` ohne Default durch, `.github/workflows/release.yml:64` setzt
  ihn am Tag-Ref. Handbuch nennt den Wortlaut (`grep -c 'keine Fassung injiziert'
  docs/user/benutzerhandbuch.md` → 2).
- **Fitness Function:** vorhanden — `TestVersionFehltFallIstLaut` u. a. in
  `cmd/ai-harness-init/version_test.go`, Mutations-Fälle `399`–`403`. Rot gesehen in einer Kopie:
  `MUTATE_CASES='399-fassung-fehlt-fall-entstaerkt 403-fassungs-pin-default' make mutate` → siehe
  §Rot-Belege.
- **Widerspruch:** keiner gefunden zu ADR-0058/0059 (Digests reisen nicht im Binary; die Pin-Achse
  bleibt) und zu `MR-048`.
- **Urteil: annahmereif nach Nachtrag** — der Acceptance-Trigger verlangt eine **Reviewer-Runde**
  gegen ADR-0058, ADR-0059 und `MR-048`; die vorhandenen Reports sind Code-Review und Verifikation
  des Slice, keine Konsistenz-Runde der ADR. Eine Runde, sonst nichts.

## ADR-0062 — Eigentums-Frage ohne Quelle

- **Umgesetzt:** Prozessregel, kein Code. Verkörperung hängt am Accept: das Register-Verzeichnis
  `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` steht auf `geplant`
  mit Kennung ADR-0062 und wird mit dem Accept `verkörpert`.
- **Fitness Function:** keine, ehrlich deklariert (Urteil, kein Muster) — keine Lücke gegen die
  ADR-Ziel-Form.
- **Widerspruch:** keiner. Seit `Proposed` (2026-09-23) neun weitere Belege
  (`ls …/evidence | wc -l` → 12; neun mit Anlage-Datum nach dem 2026-09-23). Trigger 2 feuert
  dadurch **nicht** — er gilt, „obwohl der Träger steht", und der Cutoff der ADR bindet erst ab dem
  Accept-Commit. Die Wiederholung spricht für die Annahme, nicht gegen sie.
- **Urteil: annahmereif nach Nachtrag** — der Acceptance-Trigger verlangt eine **Reviewer-Runde**
  gegen ADR-0015, ADR-0024, ADR-0028, ADR-0048 und `MR-015`; keine liegt in `docs/reviews/`.
  Mitzuprüfen: ADR-0086 (emittierte Ebene ohne Eigentums-Aussage) — steht im Einklang mit der
  Folgepflicht „emittierte Ebene bleibt unberührt".

## Rot-Belege dieses Laufs

- ADR-0063: in einer Kopie `make mutate` → `2 ok, 0 Befund(e)` (`ok` = der Wächter färbt die Mutation rot), rc=0.
- ADR-0089 (Nebenbefund dieses Laufs): in einer Kopie Datei-Modus `0o644` → `make test-go` → `--- FAIL: TestModeIsOwnerOnly … Modus = -rw-r--r--, erwartet 0600`, rc=2.

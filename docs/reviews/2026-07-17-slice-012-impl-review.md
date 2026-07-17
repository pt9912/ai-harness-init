# Review-Report: slice-012 Implementierung (Quellen-Wahrheit) — 2026-07-17

**Review-Art:** Code — geprüft gegen Plan (slice-012 DoD) + Konventionen, LH-QA-02.

**Gegenstand:** die Änderung an `harness/conventions.md` (§Baseline +
§Adoptierte Konventions-Quellen) + die Closure-Notiz. Kontext: slice-011 (in `done/`)
hatte `AGENTS.md` §1 bereits auf die vendored Form umgeschrieben und dabei die dortigen
toten Pointer entfernt — slice-012 behandelt nur noch `harness/conventions.md`.

**Skill:** `.harness/skills/reviewer.md` @ 1.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
**Modell:** claude-opus-4-8[1m] (Orchestrierung) + 1× claude-sonnet-5 (Faktentreue + Konformität) ·
**Datum:** 2026-07-17

**Eingangs-Kontext:** slice-012 (Ziel + DoD + Closure-Notiz), `.harness/skills/reviewer.md`,
`LH-QA-02`, `AGENTS.md` §1 (Nachweis der slice-011-Abdeckung), der vendored Baum
`.harness/baseline/v3.1.0/`, die GitHub-Releases-API.

---

## Findings

**Keine (HIGH 0 · MEDIUM 0 · LOW 0 · INFO 0).**

## Negativbefunde (geprüft, ohne Befund — mit ausgeführten Belegen)

- **URL-Erreichbarkeit (die DoD-eigene Messmethode):** neue Quelle
  `…/tree/v3.1.0/kurs/de` → `curl` **HTTP 200**; entfernte Quelle
  `raw…/main/…/agents-regelwerk.md` → **404**. Beide Behauptungen exakt.
- **Stand-Zeile** „Kurs-Welle 26 · 2026-07-17" — wortgleich in
  `.harness/baseline/v3.1.0/regelwerk/README.md:3`.
- **Release-Historie** („Monolith seit v2.0.0 weg, zuletzt v1.4.0"; „`lab-templates.zip`
  zuletzt v2.0.0") — per Releases-API asset-per-Tag bestätigt.
- **AGENTS.md-DoD-Nachweis:** `grep` auf `raw.githubusercontent`/`lab-templates`/`/main/`
  in `AGENTS.md` → 0 Treffer; die Verweiskette „der Kurs, den `regelwerk/README.md`
  nennt" führt auf `blob/v3.1.0/kurs/de/README.md` (HTTP 200). Die Closure-Behauptung
  „DoD 1/2 durch slice-011 abgedeckt" ist **gegenbelegt**, nicht bloß behauptet.
- **Historie nicht überschrieben:** Adoptionsdatum 2026-06-13 + `templates-v4` bleiben
  als Historie, ergänzt um die Re-Baseline-Zeile — konsistent zum repo-weiten Prinzip.
- **LH-QA-02:** neue Quelle tag-gepinnt (`/tree/v3.1.0/…`), keine neue `main`/`latest`-floating-Referenz.
- **Repo-weite Konsistenz:** keine andere normative Datei (`README.md`, `CLAUDE.md`,
  `spec/`, `harness/README.md`) trägt die tote URL oder `templates-v4` als aktuellen Stand.

## Angrenzende Beobachtung (kein Finding)

`templates-v4`-Pins bestehen in anderen aktiven Dateien (`slice.template.md`,
`welle.template.md`, `roadmap.md`, `open/slice-001…005`, `review-report.template.md`) —
korrekt als **slice-013**-Aufgabe abgegrenzt (dort §1 als offener Punkt geführt), kein
slice-012-Befund.

## Verdikt

**Merge-blockierend:** nein. Kein Finding. Der Diff ist faktentreu (URLs curl-belegt,
Stand wortgleich, Release-Historie API-bestätigt), harness-konform (tag-gepinnt,
Historie erhalten) und der „durch slice-011 abgedeckt"-Nachweis ist verifiziert statt
behauptet.

**Steering-Loop-Bezug:** Dieser Lauf bestätigt die geschärfte Regel aus der
slice-012-Closure — *bei Slice-Start den Ist-Zustand gegen den Plan messen*: der Slice
schrumpfte, weil slice-011 seine AGENTS-Arbeit vorwegnahm; das wurde gemessen (grep +
curl) statt doppelt behauptet. Reports zitieren Slices per ID (Frozen-Doc-Regel).

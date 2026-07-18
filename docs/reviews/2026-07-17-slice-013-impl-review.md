# Review-Report: slice-013 Implementierung (Templates referenzieren) — 2026-07-17

**Review-Art:** Code — geprüft gegen Plan (slice-013 DoD), Konventionen, Hard Rules,
LH-QA-02/03, MR-008. Besonderheit: der Slice **schwenkte mitten in der Umsetzung** von
„Template-Kopien patchen" auf „Kopien löschen + referenzieren" (MR-008) — der Review
prüft den reshapten Stand.

**Gegenstand:** Commit `1b2428d` + der Closure-Nachtrag (MR-008 `LH-FA-02`-Abgrenzung).

**Skill:** `.harness/skills/reviewer.md` @ 1.0.0 ·
**Modell:** claude-opus-4-8[1m] (Orchestrierung) + 2× claude-sonnet-5 (Linsen) ·
**Datum:** 2026-07-17

**Verfahren:** zwei Linsen — (a) Referenz-Modell-Korrektheit + Sweep-Vollständigkeit +
Harness-Konformität, (b) Faktentreue. Beide mit dem in-repo vendored Baum als
Grundwahrheit und explizitem `lab`-vs-`kurs/de`-Hinweis.

**Eingangs-Kontext:** slice-013 (reshaped), `.harness/skills/reviewer.md`, MR-008 +
MR-000, `LH-FA-02`, `AGENTS.md` §3, der vendored Baum, git-Historie (`HEAD~1` für den
Vorher-Zustand der gelöschten Templates), `kurs/de/` @ v3.1.0 (WebFetch).

---

## Findings

### F-1 — `LH-FA-02` vs. MR-008 nicht abgegrenzt

- `kategorie`: INFO
- `quelle`: LH-FA-02 (`spec/lastenheft.md`), MR-008
- `pfad`: `harness/conventions.md` (MR-008)
- `befund`: `LH-FA-02` (rank-1) verlangt für die vom Go-Tool **emittierte** Zielstruktur
  co-located `.template.md` für dieselben fünf Artefakt-Typen, die MR-008 für die
  **eigenen** Artefakte dieses Repos gerade löscht. MR-008 grenzte seinen Geltungsbereich
  nicht gegen die Emissions-Anforderung ab — ein künftiger slice-003-Implementierer
  könnte „referenzieren statt kopieren" fälschlich auf die Emissions-Logik übertragen
  und LH-FA-02 verletzen.
- `verifizierbar`: kein Gate; manuell durch Lesen von LH-FA-02 und MR-008 nebeneinander.
- **Behandlung: behoben** — MR-008 trägt jetzt eine ausdrückliche Abgrenzung: gilt nur
  für die eigenen Planungs-Artefakte *dieses* Repos (das die volle Baseline vendored,
  MR-007, und deshalb referenzieren kann); ein emittiertes Fremdrepo erhält nicht
  notwendig den ganzen Baum → dort bleibt LH-FA-02 bindend, MR-008 generalisiert nicht.

## Negativbefunde (geprüft, ohne Befund — mit ausgeführten Belegen)

- **Referenz-Modell vollständig:** `find docs -iname '*.template.md'` → 0; vendored Baum
  18 `*.template.md` intakt; `cp` aus dem vendored Baum liefert die v3.1.0-Form
  (Lifecycle-Feld, `ADR-<NNNN>`) — real ausgeführt.
- **„Null Adaptionen" (die zentrale MR-008-Behauptung) unabhängig nachgerechnet:** Diff
  der gelöschten Kopien (`HEAD~1`) gegen den vendorten Baum = ausschließlich mechanische
  Deltas (`templates-v4`→`v3.1.0`, `ADR-NN`→`ADR-NNNN`, Status→Lifecycle-Wortlaut);
  `carveout.template.md` 0 Diff-Zeilen. Zusätzlich gegen den `templates-v4`-Tag selbst:
  2 von 5 byte-identisch, 3 nur Link-Pin-Transformation. Keine Repo-Adaption.
- **Keine dangling references:** 0 Markdown-**Links** auf die gelöschten Templates in
  aktiven Dateien; verbleibende Erwähnungen sind Inline-Code-Prosa oder Zeitdokumente.
- **Status→Lifecycle-Sweep vollständig:** 0 `**Status:**` in aktiven Slice-Köpfen, alle
  6 tragen `**Lifecycle:**`; `done/` unberührt (nicht im Diff); die vendored
  `welle.template.md` behält ihr Status-Feld (v3.1.0 streicht nur den Slice-Kopf).
- **Anker-Befund verifiziert (beide Bäume):** `lab` hat `### Ziel-Form: …`, `kurs/de/`
  @ v3.1.0 behält `## Worked Example …`/`## Worked Mini-Example …` (WebFetch). Die
  vorhandenen Anker stimmen fürs Kurs-Ziel; Umbiegen hätte sie gebrochen. Die
  Zwei-Bäume-Erzählung deckt sich 1:1 mit der git-Historie (`HEAD~1`).
- **MR-008-Kohärenz:** alle Pflichtelemente (Adaption, Modul-2-Abweichung, empirischer
  Beleg, Tag-Tradeoff, Auflösungs-Trigger); `carveout.template.md` als einzige Datei
  unter `docs/plan/carveouts/*` bestätigt (git), Verzeichnis jetzt weg, in MR-008 als
  benigne dokumentiert.
- **Hard Rules:** git mv (Move) getrennt vom Content-Commit (§3.3); keine Accepted-ADR
  verändert (§3.4); MR-008 korrekt als Konventions-Eintrag, nicht als ADR (§3.5).
- **Historische Zahlen (slice-013 §6):** v1.2.0-`lab` 219 Zeilen mit `SL-014`/`Faustregel`,
  v3.1.0-`lab` 120 ohne, `kurs/de/` v3.1.0 300 mit — alle vier per raw-URL bestätigt.

## Nicht abschließend verifizierbar

- „`closure-note-reviewer`-Skill stand schon in v1.2.0" (slice-013 §6) — Begriff im
  v1.2.0-`lab`-Modul-10 nicht auffindbar, GitHub-Code-Suche 401 (Auth). Keine
  `datei:zeile` in der Behauptung → als offen gewertet, nicht als Fehler.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 (behoben) |

## Verdikt

**Merge-blockierend:** nein. Kein HIGH/MEDIUM/LOW. Beide Linsen bestätigten die zentrale
empirische Behauptung („null Adaptionen") unabhängig, der Status→Lifecycle-Sweep ist
vollständig ohne Kollateralschaden an `done/`, und die Zwei-Bäume-Anker-Erzählung deckt
sich mit der git-Historie. Das eine INFO (LH-FA-02-Abgrenzung) ist im Closure-Nachtrag
behoben, bevor slice-003 es überträgt.

**Steering-Loop-Bezug:** Der Reshape selbst ist der Beleg für die geschärfte Regel
*„bei Slice-Start den Ist-Zustand messen"* — der Template-Diff deckte auf, dass das
Kopier-Modell hier reine Wartungskosten war. Zwei-Bäume-Falle zum 3. Mal (Anker):
benannte Spec-Lücke „kein Gate prüft externe Anker-Fragmente" in der Closure-Notiz
festgehalten, Kandidat für `open/`.

# Verifikation — slice-126: Eine Commit-Message ohne Kennung wird rot, vor dem Commit

- **Rolle:** Verifier · **Datum:** 2026-09-11
- **Prüfgegenstand:** `799e6bce` (`in-progress/slice-126-…`), zwei Review-Runden, beantwortet
  durch `1e5b6ad2`/`799e6bce`.
- **Baum bei Beginn:** `git status --porcelain` leer.

## DoD

**(1) Rot ohne Kennung, grün mit — benannter Ort.** Erfüllt, selbst gemessen:
`make commit-msg-check MSG=<ohne Kennung>` → `commit-untraceable`, EXIT 2; mit Kennung →
EXIT 0. Voller Hook nachgezogen: JSON-`block` bzw. kein Output/EXIT 0. Beide Läufe stehen
bereits im Umsetzungs-Commit `10ba393a`.

**(2) Prüfbereich + Cutoff.** Erfüllt. `.d-check.yml` trägt `id-patterns`
(`ADR-\d{4}`/`LH-[A-Z]{2}-\d{2}`/`MR-\d{3}`/`slice-\d+`) + `exempt-pattern`. Range-in-CI ist
**entschieden gegen**, nicht offengelassen: selbst geprüft — `docker run --rm --network none
-v <klon-ausserhalb>:/repo:ro ghcr.io/pt9912/d-check@sha256:e31a372b…4641 --enable commits
--range HEAD~5..HEAD` (1 Lauf) → `Range-Basis-Vorfahren nicht lesbar`, EXIT 2. `commits` steht
nicht in `modules:` (`grep -n '^modules:' .d-check.yml`) — kein stilles Grün in `docs-check`;
LH-QA-01 hält, `doc-commits` wird als *unbedienbar* geführt, nicht als aktiv behauptet.

**(3) Träger dokumentiert.** Erfüllt. `harness/README.md` (~432–441) nennt Ort, Umfang
(Datei/`--commit-msg`), Grenze (Anwesenheit≠Wahrheit) und zwei blinde Flecken (Variablen-Pfad
dauerhaft unerreichbar; `slice-mv`/`archive-welle` strukturell unerreichbar, 304/2107 Commits).
`test/mutations/307` (Block-Bedingung invertiert) + `308` (Flag-Regex verengt) sitzen an der
realen Hook-Datei, je genau eine Zeile getroffen (selbst per `grep -cF` nachvollzogen);
`test/commit-msg-guard.bats` (18 `@test`) deckt beide Verdikte hermetisch.

## Zusage vs. Träger (Auftrags-Kernfrage)

Die Lücke ist **benannt, nicht verschwiegen** — das ist DoD (3)s Maßstab, nicht
Vollständigkeit der Erkennung. Variablen-Pfad: matcht seit Runde 2, Existenzprüfung greift
dauerhaft nicht, an beiden Orten (Skriptkopf :18-21, README :434) identisch benannt.
304/2107-Commits (`slice-mv`/`archive-welle`): benannt, offen als Träger-Frage an den Planner
gelassen — korrekt als Übergabe-Artefakt, nicht als Lücke im Slice. `-m "…"`: README sagt
seit Runde 3 "nicht garantiert" statt "bewusst ausgenommen" (Fundmenge 0/2107, erreichbar,
nicht eingetreten). Der Träger ist als Stolperdraht mit benannten Lücken dokumentiert, kein
Sandbox-Anspruch — dieselbe Grenze wie beim Nachbar-Guard (ADR-0004). Keine Über-Zusage mehr.

## Werkzeug-Defekt an beiden Fundorten

Gegengeprüft, identisch: README ~317 und ~441 sagen beide "jede nicht-leere `id-patterns`-Liste
bricht `--range` ab, auch die drei eingebauten Muster verbatim; leere/fehlende Liste prüft dann
gar nichts" (Runde-3-Korrektur von Review-HIGH-1 — vorher fälschlich "dann laufen die
eingebauten Muster"). Selbst nachgemessen: `--print-config` führt `commits:` vollständig
auskommentiert. Konsequenz an beiden Orten gleich: `doc-commits` advisory, kein CI-Range-Job.

## Review-Auflösung und Plan-vs-Code

Runde 1 (1H/5M/1L/1I), Runde 2 (1H/1M/1L/1I) beantwortet durch `1e5b6ad2`/`799e6bce`,
Runde-3-Fixes oben unabhängig nachgemessen. MEDIUM-4 (Träger hängt an Konvention, die 4/6
Agent-Dateien nicht nennen) bleibt offen, vom Reviewer selbst nicht-blockierend eingestuft.
Kein Gebautes-aber-nicht-Geplantes: `.github/workflows/ci.yml` unberührt (DoD (2) entschied
dagegen), kein Griff auf `AGENTS.md §3`/`harness/conventions.md` (Architect-Eigentum,
verboten laut Plan — bestätigt leer), `slice-121` unberührt.

## Laufender Sensor — Abnahme-Kriterium

`make mutate` lief bei Prüfbeginn bereits (Worker seit 15:59, `MUTATE_JOBS=2`); nicht selbst
gestartet, nicht gewartet.

**Erfüllt DoD (3), wenn:** Endzeile `mutate: <N> ok, 0 Befund(e)`, Exit 0, **und** keine Zeile
`mutate: BEFUND …307…` oder `…308…` im Bericht — beide Fall-IDs mit Status `OK`.
**Verfehlt DoD (3), wenn:** eine `BEFUND`-Zeile zu 307 oder 308 erscheint — der Zahn hat die
Mutation nicht geröted. Bricht der Lauf vorher ab (`ABBRUCH`/`ABGEBROCHEN`), ist keine Aussage
möglich; Lauf wiederholen, kein Befund gegen den Slice. Jede andere `BEFUND`-Zeile (anderer
Fall) betrifft slice-126 nicht.

## Urteil

DoD (1) und (2): erfüllt, selbst gemessen. DoD (3): inhaltlich erfüllt — **bis auf den noch
laufenden `make mutate`-Sensor**, Kriterium oben.

**Ist die DoD erfüllt — nur bis auf den laufenden Sensor.** Häkchen dürfen gesetzt werden,
sobald `make mutate` grün durchläuft ohne BEFUND zu 307/308; meldet er BEFUND auf einen der
beiden, geht der Fall an den Implementer zurück.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01PzeHw5QnguVvohdHnF2C31

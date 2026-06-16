# Slice slice-010: Regelwerk-Cache als Split-Modul-Verzeichnis

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor), [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis).

**Autor:** Demo. **Datum:** 2026-06-16.

---

## 1. Ziel

Der Regelwerk-Cache wird von der **Einzeldatei** (`agents-regelwerk.md`,
Raw-`.md` von `main`) auf ein **Split-Modul-Verzeichnis**
`.harness/cache/agents-regelwerk/` umgestellt: `make regelwerk-fetch` zieht das
gepinnte `lab-regelwerk.zip` (Release-Tag `v1.2.0`, **ZIP-sha256**) und entpackt
es atomar in 21 Dateien (`grundlagen-*`, `modul-00`…`modul-16`, `README.md` als
Index). Der Codex-SessionStart-Hook injiziert künftig **nur den Index**
(`README.md`); beide Agenten lesen das relevante Modul **on-demand**. Wortgleich
zur Quelle, kein selbst erzeugter Digest ([`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis), ergänzt [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).

**Abgrenzung:** Die Durchsetzungsschicht (PreToolUse-Guard, Stop-Gate) ist
**unberührt** — dies ist Context Engineering (inferential feedforward), kein
Gate. Der Templates-Bootstrap (`lab-templates.zip`, die `LH-FA-*`-Produktseite)
ist **nicht** Teil dieses Slices.

## 2. Definition of Done

- [ ] `Makefile`: `REGELWERK_URL`→ZIP, `REGELWERK_SHA256`→`ef61f8a7…97e43`,
      `REGELWERK_CACHE`→Verzeichnis; `regelwerk-fetch` verifiziert die ZIP-sha256
      **vor** jeder Cache-Mutation und ersetzt den Cache via temp→`mv` (`mv`
      atomar, Replace als Ganzes nicht); bei Fetch-Fehler/Drift bleibt der Cache
      **unverändert** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] Injektor (`harness/tools/sessionstart-inject-regelwerk.sh`) injiziert den
      **Index** (`…/agents-regelwerk/README.md`) statt des Volltexts; fehlendes
      Cache-Verzeichnis → **sichtbare Warnung** mit `make regelwerk-fetch`,
      exit 0; awk-Encoder bleibt, **kein** node/jq ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)), **kein**
      Netz im Hook.
- [ ] `bats` (`test/sessionstart.bats`) deckt: Index-Injektion gegen
      synthetisches Verzeichnis (Modul-Inhalt **nicht** injiziert); fehlendes
      Verzeichnis → Warnung + exit 0. Encoder-Tests unverändert grün.
- [ ] `CLAUDE.md` + `AGENTS.md` §1 zeigen auf das **Verzeichnis** + Index +
      on-demand; „Volltext lesen/paginieren" entfällt.
- [ ] **[`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)** in `harness/conventions.md` (Split-Modul-Bezug, ZIP-Pin,
      Index-only-Inject + **Tradeoff** schwächere Presence-Garantie),
      Querverweis aus [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor).
- [ ] Folgepunkt in `slice-009` aufgenommen (Drift-Invariante auf
      `sha256(Upstream-ZIP)` umstellen, entpacktes Verzeichnis als abgeleitetes
      Artefakt).
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | ZIP-URL/-sha256, Cache-Verzeichnis, Entpack-Fetch via temp→mv (curl+unzip) |
| `harness/tools/sessionstart-inject-regelwerk.sh` | update | Index statt Volltext injizieren; fehlendes Verzeichnis → Warnung |
| `CLAUDE.md` | update | Pointer auf Verzeichnis/Index + on-demand-Lektüre |
| `AGENTS.md` (§1) | update | Cache-Beschreibung (Split-ZIP, ZIP-gepinnt, Index-Inject) |
| `harness/conventions.md` | update | [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) (+ [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)-Querverweis) |
| `test/sessionstart.bats` | update | Index-Injektion + fehlendes Verzeichnis |
| [slice-009](slice-009-regelwerk-drift-check.md) | update | Folgepunkt: Drift-Invariante umstellen |

## 4. Trigger

Sofort startbar — reine Harness-Mechanik, unabhängig vom Go-CLI. Setzt den Cache
+ `make regelwerk-fetch` aus [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) voraus (existiert bereits).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Schwächere Presence-Garantie (Codex):** Index-only ersetzt den
  Volltext-Inject aus slice-007 — bewusst (Per-Session-Kosten/Kohärenz), im
  inform-Quadranten, **kein** Gate-Verlust. In [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) dokumentiert.
- **Maintenance-Abhängigkeit `unzip`** (host, wie `curl`) — nur
  `regelwerk-fetch`, **nicht** in `gates`, **nicht** im emittierten Zielrepo.
- **Derivative Quelle:** Das ZIP ist eine derivative Sicht (ZIP-`README.md`);
  bei Konflikt gilt die Kurs-Quelle. Kein selbst erzeugter Digest
  (slice-007-Lehre, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- **Drift/Pin-Pflege:** Re-Pin (`REGELWERK_SHA256`) + Tag-Bump bei
  Upstream-Release manuell; Überwachung via [slice-009](slice-009-regelwerk-drift-check.md) (Invariante nachzuziehen).
- **Stale Einzeldatei:** der alte `.harness/cache/agents-regelwerk.md` bleibt
  lokal liegen (gitignored, regenerierbar) — vom Injektor nicht mehr gelesen.

## 7. Closure-Notiz (nach `done/`)

**Abschluss:** 2026-06-16. DoD vollständig; Gates grün.

**End-Stand (maßgeblich):** Der Regelwerk-Cache ist ein **Split-Modul-Verzeichnis**
`.harness/cache/agents-regelwerk/` (21 Dateien). `make regelwerk-fetch` zieht
`lab-regelwerk.zip` (Tag `v1.2.0`, ZIP-sha256 `ef61f8a7…97e43`), verifiziert vor
jeder Cache-Mutation und ersetzt den Cache via temp→`mv` (`mv` atomar, Replace als
Ganzes nicht). Der Codex-SessionStart-Hook
injiziert nur den **Index** (`README.md`) mit Pointer-Präfix; beide Agenten lesen
Module on-demand. `CLAUDE.md`/`AGENTS.md` §1 zeigen aufs Verzeichnis. Mechanik:
[`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) (ergänzt [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).

**Nachweise (beobachtbar):**

- `make regelwerk-fetch` real ausgeführt: ZIP geladen, sha256 verifiziert, 21
  Dateien entpackt (Index 3756 B) — Beleg für die Fetch-/Entpack-Mechanik.
- `make test` 37/37 grün, inkl. dreier neuer Injektor-Tests: Index injiziert,
  Modul-Inhalt **nicht** injiziert (Index-only); fehlendes Verzeichnis bzw.
  Verzeichnis ohne `README.md` → sichtbare Warnung + exit 0.
- `make gates` grün (`docs-check` 28 Dateien / 0 Befunde inkl. des neu
  angelegten Anker-Ziels, `shell-lint` clean, `test`).

**Was anders war als geplant:** nichts Strukturelles — `.gitignore`
(`.harness/cache/`) und `.d-check.yml` (`scan.ignore` + `codepaths.roots` ohne
`.harness`) deckten das Verzeichnis bereits, daher keine Gate-Config-Änderung
nötig (vorab verifiziert).

**Review (unabhängig, Modul 10):** Ein separater `code-reviewer`-Agent prüfte den
Diff (review-only). Verdikt **APPROVE-WITH-NITS**: bestätigt Pin-vor-Mutation,
pipefail-/awk-sichere Index-Injektion, ehrlichen Tradeoff, keine Harness-Lüge.
Behobene Nits: [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)-Body als **Historie** markiert (Vorwärtsverweis direkt unter
der Überschrift); dritter bats-Test (Verzeichnis ohne `README.md`); „atomar"-Wording
präzisiert (nur das `mv` ist atomar). Report:
[`docs/reviews/2026-06-16-slice-010-regelwerk-split-modul-cache.md`](../../../reviews/2026-06-16-slice-010-regelwerk-split-modul-cache.md).

**Steering-Loop-Lerneintrag:**

1. **Read-on-demand zu Ende gedacht.** slice-007 musste den 212-KB-Volltext für
   Claude bereits aufgeben (10k/150k-Caps → Pointer). Der Split-Modul-Cache
   verallgemeinert das auf beide Agenten und entlastet die
   Codex-Per-Session-Kosten — Index (3,7 KB) statt 212 KB.
2. **Bewusster Tradeoff, keine stille Schwächung.** Die schwächere
   Presence-Garantie (Codex Index-only) ist in [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) explizit als
   inferential-feedforward-Bewegung dokumentiert; die fail-closed-Gates bleiben
   unberührt. Keine Harness-Lüge: das ZIP ist die wortgleiche Kurs-Sicht, kein
   Eigen-Digest (slice-007-Lehre gehalten).

**Folge-Slices / offen:**

- `slice-009` (Drift-Check): Invariante auf `sha256(Upstream-ZIP)` umstellen
  (Folgepunkt dort aufgenommen).
- Stale `.harness/cache/agents-regelwerk.md` (alte Einzeldatei) lokal entfernbar;
  gitignored, vom Injektor nicht mehr gelesen.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`harness/tools/`, die `.codex/`-Injektion, `Makefile` und die Doku teilen die
adoptierte Harness-Mechanik ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)); GF (Doc führt).

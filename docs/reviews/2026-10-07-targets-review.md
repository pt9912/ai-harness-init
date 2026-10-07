# Review: slice-targets-modul-im-emittierten-doc-gate

**Rolle:** Reviewer (`.harness/skills/reviewer.md`) · **Datum:** 2026-10-07 ·
**Gegenstand:** Commits `2fec4763`, `ccf163b9`, `2b93feca`, `9a36e370` gegen den Slice-Plan,
ADR-0080 (Festlegung 5, Fitness 3), ADR-0078, MR-054, MR-080, Kurs `v6.16.0` Welle 159,
AGENTS.md §3.6/§3.7.

**Summary:** 1 HIGH · 1 MEDIUM · 2 LOW · 2 INFO. Wiederkehrende Klasse: Grenzen-Aufzählung
ohne die Form, die der eigene Entscheid nahelegt.

## Findings

### F-1 — HIGH — Grenzen-Aufzählung ohne die eingebundene Datei außerhalb der Wurzel

- `quelle`: AGENTS.md §3.6; Kurs `v6.16.0` `modul-13-quality-gates.md` §Hard Rule („Ein Gate ohne seine Grenze behauptet ebenfalls zu viel“)
- `pfad`: `internal/emit/templates/d-check.yml` (Kopfkommentar, Absatz „Grenzen:“), `docs/user/benutzerhandbuch.md:522` („Grenzen: …“)
- `befund`: Eine `.mk`-Datei unterhalb der Wurzel (nicht `harness/mk/`), die `repo.mk` per `include` einbindet, liest der Sensor nicht: ihr Target läuft mit `make`, `docs-check` meldet `0 Befund(e)`. Beide Grenzen-Aufzählungen, die der Diff anlegt, nennen die Form nicht, und ADR-0080 Festlegung 1 nennt genau diesen Weg („Wer mehrere Dateien will, bindet sie aus `repo.mk` ein“).
- Beleg (frisch emittiertes `--lang go`-Ziel, Binär `.harness/state/bin/ai-harness-init` vom HEAD-Stand):
  `mkdir mk; printf 'sub-x:\n\t@true\n' > mk/extra.mk; echo 'include mk/extra.mk' >> repo.mk; make docs-check` →
  `d-check: 21 Datei(en) geprüft, 0 Befund(e)`; `make sub-x` läuft.
- `verifizierbar`: ja (`make full-smoke`, sobald eine Stufe die Form fährt)
- `klasse`: Grenzen-Aufzählung ohne Formen-Probe

### F-2 — MEDIUM — Konfiguration weicht vom Plan ab; die ADR-Prämisse dahinter ist widerlegt

- `quelle`: Slice-Plan §1 „Konfiguration im Ziel“, §3 Zeile `d-check.yml`; ADR-0080 Festlegung 2/3, Fitness 2
- `pfad`: `internal/emit/templates/d-check.yml` Block `targets:` (`makefiles: [Makefile, "harness/mk/*.mk", "*.mk"]`)
- `befund`: Plan §1/§3 setzen `makefiles: [Makefile, "harness/mk/*.mk", d-check.mk, repo.mk]` mit der Prämisse „`repo.mk` existiert dank Startinhalt immer“. ADR-0080 Festlegung 3 und Fitness 2 lassen `repo.mk` fehlen; mit der Einzeldatei endete `make gates` dann rot (Exit 2 laut Commit-Message am Pin `v0.82.0`, hier nicht nachgemessen). Der Glob löst den Widerspruch und deckt die vier Plan-Quellen als Obermenge (zusätzlich `a-check.mk`, das der Plan nicht nannte, und jede fremde `.mk` an der Wurzel). Kein ADR-Verstoß: Festlegung 5 verlangt nur, dass `repo.mk` in `makefiles:` steht; Festlegung 2 nennt „keinen Glob“ als Folge, nicht als Gebot, mit der Klausel „eine fehlende Einzeldatei ist nicht gemessen“. **Kein Rollen-Konflikt, kein Konflikt-Pfad nach Modul 8 nötig.** Zu klären ist es vor Merge trotzdem: Plan-Text und Konfiguration gehen auseinander, und das ist ein Übergabe-Artefakt an den Planner (AGENTS.md §3.10). Ob ADR-0080 die widerlegte Prämisse in Festlegung 2 per Folge-ADR berichtigt, entscheidet der Architect.
- Glob-Folgen nachgemessen (gleiches Ziel): fremde `vendor.mk` an der Wurzel → `vendor.mk:1 fremd-x gate-undocumented` (wie benannt); Target in `harness/mk/x.mk` → **ein** Befund, nicht zwei (keine Doppel-Lesung über `*.mk`); `Makefile` trifft `*.mk` nicht; `repo.mk` gelöscht → `0 Befund(e)`.
- `verifizierbar`: ja (`make full-smoke`, Stufen `repo_mk_im_ziel` und `targets_im_ziel`)
- `klasse`: Plan-Konfiguration auf ungemessener Prämisse

### F-3 — LOW — der Kopf der emittierten `repo.mk` verlangt die Zeile nur für Gates

- `quelle`: Maintainability; Kurs `v6.16.0` `modul-13-quality-gates.md` §Hard Rule (beide Richtungen)
- `pfad`: Startinhalt von `repo.mk` (im Ziel: „Jedes Target, das hier als Gate steht, bekommt seine Zeile in harness/README.md“)
- `befund`: Mit dem Modul `targets` braucht **jedes** Target in `repo.mk` eine Zeile, nicht nur ein Gate. Wer dem Kopf folgt und ein Nicht-Gate-Target ohne Zeile anlegt, bekommt `gate-undocumented` (laut, aber die Anleitung schickt dahin). Das Handbuch sagt es richtig („Jedes Target darin braucht eine Zeile“).
- `verifizierbar`: ja (`make full-smoke`, `targets_im_ziel` Gegenbeispiel `eigen-probe`)
- `klasse`: emittierte Anleitung hinter dem emittierten Gate

### F-4 — LOW — Target-Erkennung des Werkzeug-Teils enger als die des Sensors

- `quelle`: Maintainability
- `pfad`: `internal/emit/werkzeugindex.go` `werkzeugRegelPattern` (`^([a-z][a-z0-9-]*):`)
- `befund`: d-check meldet Targets mit `_` oder Großbuchstaben (`repo.mk:16 my_tgt gate-undocumented`, `repo.mk:18 Build gate-undocumented`); der Werkzeug-Teil erkennt solche Namen (und Mehrfach-Targets `a b:`) nicht. Trägt ein künftiges Fragment ein solches Target, steht es in keinem Teil, und das frische Ziel startet rot. Heute führt kein Fragment eines (grüner Start in allen `make gates`-Stufen von `make full-smoke`).
- `verifizierbar`: ja (`make full-smoke`)
- `klasse`: latente Wartungsfalle — zwei Erkenner derselben Menge

### F-5 — INFO — Werkzeug-Teil ohne Klasse in der Klassentabelle (Planner)

- `quelle`: Slice-Plan §3 Zeile `internal/emit/` („Klasse konvergent in der Klassentabelle `internal/emit/enforce.go`“)
- `pfad`: `internal/emit/werkzeugindex.go:12-17`
- `befund`: `PathClass("harness/mk/ai-harness-init.md")` liefert `klasseUnbestimmt`; das Verhalten ist konvergent (Test `TestWerkzeugIndex_KonvergentHeiltDrift`), wie `d-check.mk` aus `DocGate`. Keine Zusage, die `PathClass` liest, nennt den Pfad. Planabweichung ohne Verhaltensfolge.
- `verifizierbar`: nein
- `klasse`: Plan nennt Träger, Code wählt Präzedenz

### F-6 — INFO — Risiko 1 aus §6 trägt der Diff (Planner)

- `quelle`: Slice-Plan §6
- `pfad`: `cmd/ai-harness-init/main.go` (`addLang` ruft `emit.WerkzeugIndex`)
- `befund`: `add-lang` schreibt den Werkzeug-Teil im selben Lauf neu; das Risiko „fehlt bis zum nächsten Bootstrap“ tritt in dieser Form nicht ein. Ausgang setzt der Planner.
- `verifizierbar`: nein (Stufen nach `add-lang` fahren `make gates` grün, die Deklaration von `targets_im_ziel` misst den Nachzug ausdrücklich nicht)
- `klasse`: —

## Gefahrene Proben

| Probe | Kommando | Ergebnis |
|---|---|---|
| Mutationsfälle | `make mutate MUTATE_CASES="530-werkzeug-index-nicht-disjunkt 531-werkzeug-index-ohne-gate-klasse 295-emittierte-modulliste-verliert-matrix"` | `3 ok, 0 Befund(e)` |
| Gegenprobe 530, 531 | je Mutation angewandt, `t.Skip` allein in `TestWerkzeugIndex_ZeileJeWerkzeugTargetDisjunkt`, `go test ./internal/emit/` im `test`-Image (Kopie unter dem Scratchpad) | beide `ok` — der benannte Test bindet allein |
| Fall 514 | `grep -c '^modules: \[links, anchors, ids, matrix, spans, structure, targets\]$' internal/emit/templates/d-check.yml` | `1` — das Muster trifft |
| Disjunktheit | Werkzeug-Target `lint` in `harness/README.md` eingetragen → Re-Lauf → Zeile entfernt | Re-Lauf nimmt `lint` aus dem Werkzeug-Teil; nach Entfernen vor Re-Lauf `harness/mk/go.mk:13 lint gate-undocumented` (laut); nach Re-Lauf `0 Befund(e)` |
| E2E | `make full-smoke` | `EXIT 0`; `targets_im_ziel` grüner Start, `gate-undocumented` und `gate-phantom` je mit Gegenprobe |
| Abdeckungs-Sicht | `make e2e-abdeckung; git status --short` | keine Änderung (byte-gleich) |

## Geprüft, ohne Befund

- (b) Konvergent-Schreiben: Bootstrap (letzter Schritt in `emitAll`, auch ohne Sprache) und `add-lang` schreiben den Teil neu; Handänderung wird überschrieben; Disjunktheit gegen die README zum Laufzeitpunkt, die Doppelung danach ist im Kopf des Teils und im Handbuch benannt.
- (c) Ziel mit eigener `.d-check.yml`/`harness/README.md`: Modul und Link fehlen ohne Meldung; das ist im Kopfkommentar der Vorlage und im Handbuch wahrheitsgemäß benannt, ebenso im Abdeckungs-Satz der Stufe („NICHT gemessen“).
- (d) `targets_im_ziel` misst, was ihre Deklaration sagt; die Gegenprobe zu Fitness 3 streicht den Glob (nicht `repo.mk` selbst), die Wirkung ist dieselbe. `repo_mk_im_ziel` trägt nur die zwei Zeilen nach, die das Modul verlangt.
- (f) Handbuch: Ist-Zustand, keine Kennungen; jede Aussage des neuen Absatzes am Ziel nachgefahren, außer der Lücke aus F-1.
- Kurs Welle 159: Werkzeug-Teil unter `harness/mk/`, je Lauf neu, `kein Gate` in der Bindung, Link-Zeile unter den Tabellen, `authority` als Vereinigung — erfüllt.
- AGENTS.md §3.7: neue Kommentare in `werkzeugindex.go`, `main.go`, `full-smoke.sh`, `d-check.yml` tragen Zusage, Kopplung oder Grenze.
- MR-054: Erprobung (Modul läuft im Dogfood), grüner Start, rotes Gegenbeispiel je Richtung — belegt.

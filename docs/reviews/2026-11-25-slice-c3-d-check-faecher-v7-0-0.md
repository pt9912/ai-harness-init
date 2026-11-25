# Review-Report: slice-c3-d-check-faecher-v7-0-0 — 2026-11-25

**Review-Art:** Code-Review gegen Plan + Konventionen (`modul-10-review-harness.md` §Drei
Review-Arten). Der dazugehörige Architect-Commit (`MR-096`/`MR-097`, Architektur-Zug) wurde
auf Geltungsbereichs- und Formkonsistenz gegen die Implementer-Commits mitgeprüft; Findings
dazu sind Architektur-Form-Befunde, keine Implementer-Befunde.

**Gegenstand:** `slice-c3-d-check-faecher-v7-0-0` — Range `477e94eb..701886e0` (Plan-Anlage,
Claim-Move, Gate-Befund-Nachzug, Plan-Nachkorrektur, emittierte `d-check.yml`-Form + Tests,
Dogfood-Glob-Zeilen + pinsync-Aktivierung, bats-Wächter + Mutations-Fall 790 +
`docs-check.md` §Grenze/§Modul pinsync, Marker + `d-check:ignore`, GRENZE-Spalte-0-Nachzug,
SC2034, C4-Platzhalter-Link + Anker-Nachzüge 171/392, `MR-096`/`MR-097`).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0
**Modell:** glm-5.3-flash · **Datum:** 2026-11-25

**Eingangs-Kontext:**

- `slice-c3-d-check-faecher-v7-0-0` (Slice-Plan, Kennung)
- [`MR-054`](../../harness/conventions/MR-054-drei-kriterien-fuer-ein-modul-im-emittierten-doc-gate.md)
  (Ruder je emittierter Aktivierung) · [`MR-055`](../../harness/conventions/MR-055-eine-stellen-messung-traegt-keine-folgerung-ueber-eine-eigenschaft.md)
  · [`MR-071`](../../harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md)
  · [`MR-090`](../../harness/conventions/MR-090-ein-sensor-haelt-den-anker-am-commit.md)
  · [`MR-096`](../../harness/conventions/MR-096-planning-faecher-am-stand-v7-0-0.md) /
  [`MR-097`](../../harness/conventions/MR-097-pinsync-faecher-am-stand-v7-0-0.md) (Architect-Zug)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `AGENTS.md` §3 (Hard Rules)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die `docs-check`-Zeile des Gate-Index zählt neun Module auf; die Konfiguration trägt seit diesem Zug zehn (`pinsync`). Die Aufzählung ist mit der `modules:`-Zeile des Zuges ungleich geblieben — dieselbe wiederholte Fundklasse, die der Planungs-Bestand als Arbeitspunkt kennt („Die nächste Änderung an `modules:` erzeugt dieselbe Fundmenge neu"). | `LH-QA-01`; Plan §2 DoD „Doku-Update"; `AGENTS.md` §4/§5 | `harness/README.md` · „(links/anchors/ids/matrix/codepaths/spans/planning/targets/structure)" gegen `grep -m1 '^modules:' .d-check.yml` | ja — Kein Gate liest die Aufzählung; `git grep -ln 'links/anchors/ids/matrix/codepaths/spans/planning/targets/structure' -- ':!docs/reviews'` nennt die eine Fundstelle | Prosa-Modul-Aufzählung gegen Config |
| F-2 | LOW | Plan §3/LP2 nennt als Mutations-Fall den verfälschten Pin-Wert an genau einer Quelle; der angelegte Fall `790` entfernt stattdessen die `d-check.mk`-Quellen-Zeile aus `.d-check.yml` und bindet so die Config-Zusicherung, nicht das Verhalten. Der verfälschte-Pin-Zahn ist nur als einmaliger Handlauf belegt (`docs-check.md` §Modul pinsync, Aufruf + `git checkout`, Wortlaut der Meldung notiert) — an keiner laufenden Stelle reproduziert. | Plan §2 LP2 / §3; [MR-054](../../harness/conventions/MR-054-drei-kriterien-fuer-ein-modul-im-emittierten-doc-gate.md); `AGENTS.md` §3.6 | `test/mutations/790-d-check-pin-paarung-faerbt-pinsync-rot.sh` · `sed -i '/- {file: d-check.mk, pattern:/d' .d-check.yml` | ja — Verhalten rot am reale Quelle: von Hand einmal nachvollzogen (dieser Lauf, Bruchprobe in Kopie, s. u.); Automatisiert: `make mutate MUTATE_CASES=790-d-check-pin-paarung-faerbt-pinsync-rot` → `1 ok` | Verfälschte-Pin-Probe nur Handlauf |
| F-3 | LOW | Die Grenz-Formulierung des planning-Blocks überreibt für eine der zwei Richtungen: „Zeiger ohne Datei … bleibt dann still" / „die Listen-Hälfte von `## Offene Wellen` bleibt ungewächtert" — am Gate bleibt ein Zeiger-ohne-Datei nie still, das `links`-Modul färbt jedes totere Linkziel (gemessen: Klang-Geist-Probe, Befund-Code `target-missing`). Nur die Datei-ohne-Zeiger-Richtung ist bei Namens-Form wirklich stumm (gemessen: Namens-Form-Geist-Datei → `0 Befund(e)`, Ziffern-Form → `wave-drift`). | `AGENTS.md` §3.7 (Kommentar beschreibt, was da ist); [MR-096](../../harness/conventions/MR-096-planning-faecher-am-stand-v7-0-0.md) Setzung 3 | `internal/emit/templates/d-check.yml` · „Datei ohne Zeiger und Zeiger ohne Datei bleiben dann still"; `.d-check.yml` · „die Listen-Haelfte … bleibt bei Namens-Form ungewaechtert" | ja — Doku-Drift ohne Gate; der Grenz-Satz liest sich gegen die gemessene Gate-Lage | Grenz-Formulierung überdeckt eine Richtungs-Abdeckung |
| F-4 | INFO | Der `d-check:ignore`-Marker der Plan-Übergabe (§3, MR-096-/MR-097-Zeile) trägt die Begründung „sind geplant, nicht angelegt" — mit dem Architect-Zug (`701886e0`) sind beide Dateien angelegt und die Anker gesetzt; die Begründung ist damit verbraucht. Ohne Nachzug friert der Plan beim `git mv` nach `done/` diese gegenstandslose Ausnahme ein. | `AGENTS.md` §3.7; Übergabe-Form Plan §3 | `docs/plan/planning/in-progress/slice-c3-d-check-faecher-v7-0-0.md` §3 · `<!-- d-check:ignore: MR-096- und MR-097-Datei sind geplant, nicht angelegt; … -->` | nein — kein Sensor liest den Bestand der Marker; Träger ist die Closure | Verbrauchter Plan-Marker wird eingefroren |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| MR-054-Ruder, emittiertes planning (Erprobung · grüner Start · rotes Gegenbeispiel) | geprüft, Befund nur in der oben genannten Lücken-Form: `make smoke` (dieser Lauf selbst gefahren) meldet die emittierte Konfiguration samt `waves`-Block „0 Befund(e)" out-of-the-box; die red-Verhaltens-Proben am Ziel (`wave-drift` in der emittierten Konfiguration) sind Handlauf — die Drei-Beleg-Form des `full-smoke`-Laufs deklariert ebendiese Lücke („NICHT gemessen: … die Faehigkeiten closure/waves des Moduls", Stufe `planning_im_ziel`); die Werkzeug-Verhaltens-Klassen sind unabhängig am Dogfood bestätigt (Bruchproben unten) |
| `wave-drift` / `pinsync-mismatch` rot aus dem richtigen Grund | geprüft, ohne Befund — Bruchproben in `/tmp/c3probe` (Kopie): Geist-Datei in Ziffern-Form → `docs/plan/planning/in-progress/roadmap.md:11 welle-007 wave-drift …`; `d-check.mk` auf `v9.9.9` verfälscht → `internal/emit/emit.go:33 d-check pinsync-mismatch Pin "d-check": …` — Wortlaut deckungsgleich mit dem notierten Beleg in `harness/sensors/docs-check.md` | 
| Dogfood `.d-check.yml` (Glob-Zeilen, pinsync-Block, scan.ignore unverändert) | geprüft, ohne Befund — die `ignore:`-Zeile trägt den `worktrees`-Eintrag nicht (Plan §1-Ausschluss gehalten); `make docs-check` → `0 Befund(e)`, Positiv-Zeile `pinsync: 1 Pin(s) geprüft, 2 Quelle(n) gelesen` |
| Zwei-Wortlaut-Zuordnung (Dogfood `welle-*` / emittiert `wave-*`) | geprüft, ohne Befund — `harness/sensors/docs-check.md` §Grenze trägt beide Grenzen (Bestandsform-Paragraph „Die Glob-Zeilen tragen die Bestandsform ausdrücklich", Kennungs-Form-Paragraph „Zweite Grenze am selben Block"), je mit Herkunfts-Anker `· seit slice-c3-d-check-faecher-v7-0-0`; Zustand + Anker, keine Chronik (`AGENTS.md` §3.7). Die Befund-Codes sind Werkzeug-Wortlaute (`wave-drift`, `pinsync-mismatch`), auf beiden Ebenen dieselben — die Zweiwortlaut-Lage liegt nur in den Glob-Zeilen und ist dort benannt |
| MR-096/MR-097 gegen die Implementer-Commits | geprüft, ohne Befund — Geltungsbereiche decken die geänderten Dateien: `9d5e2d4a` (Template + `TestDCheckConfig_PlanningBlock`) und `3458d096`-Teile (`waves-modul-wiring.bats`, `docs-check.md` §Grenze planning) tragen `MR-096`; `78512cea`/`3458d096`-Pinsync-Teile/`cc56ee9d` (pinsync-Block, `pinsync-modul-wiring.bats`, Fall 790, §Modul pinsync, kommentierter Template-Block) tragen `MR-097`; Anker-Slugs lösen im Index beider Anker-Formen (`make docs-check` → `0 Befund(e)`); `TestDefaultImage_MatchesCanonical` existiert (`internal/emit/emit_test.go:360`); Index-Zeilen tragen Datum, Geltungsbereich mit `…`, „keine — … Fork", Adaption, Begründung, Auflösungs-Trigger |
| Mutations-Fall 790 Anlage-Form ([MR-071](../../harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md) / [MR-090](../../harness/conventions/MR-090-ein-sensor-haelt-den-anker-am-commit.md)) | geprüft, ohne Befund — das `sed`-Muster trifft die Quell-Zeile am Bestand (beide Fanggruppen, exakt eine je Quelle); `# files: .d-check.yml`, `# expect:` trägt den Test-Namen der Config-Zusicherung; die Grenz-Zeile (kein Docker-Lauf im Treiber, Verhaltens-Zahn davor gemessen, Beleg in `docs-check.md` §Modul pinsync) trägt die Fall-Datei selbst, nicht nur die Sensor-Doku; `make mutate MUTATE_CASES=790-d-check-pin-paarung-faerbt-pinsync-rot` (dieser Lauf) → `1 ok, 0 Befund(e)`, 172,95 s (Hinweis: die angegebene Kurzform `MUTATE_CASES=790` löst nicht — der Treiber verlangt den vollen Fall-Namen). Mitfärben-Gegenprobe: gelesen, nicht gefahren — statisch bindet nur der benannte Test; die drei Geschwister-Tests bleiben nach der Mutation grün (Pin-Zeile unberührt, restliches Muster mit genau einer Fanggruppe, Modul-Liste unberührt) |
| Mutations-Anker 171/392 ([MR-071](../../harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md)) | geprüft, ohne Befund — beide `sed`-Muster lesen jetzt `\.claude/worktrees/\*\*` zwischen `.tmp` und `.harness` und treffen die Bestands-Zeile des Templates wörtlich |
| Marker in `docs-check.md` (environment-check-Vorlage, `b473b1e9`) | geprüft, ohne Befund — die Begründung (geplante Datei, Vorlage in der vendored Baseline, C4 entscheidet die Adaption) ist zum heutigen Stand wahr und behält einen Träger (C4) |
| CI-Branch-Dokumentation (Welle-Form kollektiver Sweep) | geprüft, ohne Befund am Bestand — im Plan §7/§5 noch nichts zu prüfen; die 18-Fall-Urteilung von `make mutate-auswahl` und die Nicht-Push-Entscheidung sind Closure-Gut und tragen dort die §7-Zeile (Übergabe an die Verifikation: die lokale Rotbelege für Fall 790 und die Anker-Nachzüge 171/392 sind wie oben belegt) |
| Ruhe-Marker / Lifecycle-Handarbeit (`c75c82ef`) | geprüft, ohne Befund — Marker unter „Offene Wellen" entfernt, solange der Slice in `in-progress/` liegt; die Bruchproben liefen gegen genau diesen Zustand grün |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Prosa-Modul-Aufzählung gegen Config · Verfälschte-Pin-Probe
nur Handlauf · Grenz-Formulierung überdeckt eine Richtungs-Abdeckung · Verbrauchter
Plan-Marker wird eingefroren

## Bruchproben (dieser Lauf, Kopie `/tmp/c3probe`, kein Rest im Baum)

- Grünfahrt: `make docs-check` → `pinsync: 1 Pin(s) geprüft, 2 Quelle(n) gelesen`, `2996 Datei(en) geprüft, 0 Befund(e)`.
- Geist-Datei Namens-Form (`welle-probe-geist.md`) → `0 Befund(e)` — die Kennungs-Form-Grenze ist real und korrekt beschrieben.
- Geist-Datei Ziffern-Form (`welle-007.md`) → 1 Befund, Code `wave-drift` an `roadmap.md:11` — die Bijektion färbt aus dem richtigen Grund.
- `DCHECK_IMAGE` an einer Quelle auf `v9.9.9` verfälscht → 1 pinsync-Befund, Code `pinsync-mismatch`, Wortlaut deckungsgleich mit dem Beleg in `docs-check.md`.
- Klang-Geist (Zeiger ohne Datei) → `target-missing` durch `links` — Grundlage von F-3.
- `make mutate MUTATE_CASES=790-d-check-pin-paarung-faerbt-pinsync-rot` am echten Baum → `1 ok, 0 Befund(e)`.

## Verdikt

**Merge-blockierend:** ja, mit Reichweite — kein HIGH; F-1 ist ein Ein-Zeilen-Doku-Nachzug
an der Sensor-Zelle, den der Plan selbst als DoD-Punkt nennt, und gehört vor die Closure
(kein Code- oder Gate-Defekt — die Abweichung von der typischen MEDIUM-Sperre ist der
Nachzug-Charakter, nicht die Ermessensfreiheit). F-2/F-3 sind LOW mit konkreten
Nachzugs-Worten, F-4 ein Closure-Handgriff.

**Übergabe:** Findings gehen an den Implementer; die Finding-Klassen in die Slice-Closure §7
und von dort in den Zähler. Der Report selbst ist Lauf-Beleg. Keine Prüfung gegen DoD —
die Verifikation liegt separat (Modul 11); die DoD-Nähe von F-1 und die
18-Fall-Urteils-Dokumentation der Welle-Form trägt sie dort nach.

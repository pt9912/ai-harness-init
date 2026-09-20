# Review-Report: slice-unscoped-ziele-kollidieren-nicht-im-mono-repo — 2026-09-20 (Runde 1)

**Review-Art:** Code — geprüft gegen den Slice-Plan und die referenzierten LH-IDs (Modul 10 §Drei Review-Arten).

**Gegenstand:** `git diff 77d5346a..1fa5ceba`, eingeschränkt auf die fünf Commits der Rolle
Implementation (`1d8c0081`, `3d818d90`, `d02e3552`, `32045c93`, `1fa5ceba`) — die Range selbst
trägt daneben mehrere Planner-Commits (Roadmap, andere Slices, `welle-v021-faehigkeit.md`), die
nicht Gegenstand dieses Slice sind und darum nicht Teil dieses Reviews. Geprüfte Dateien:
`internal/gen/{golang,cpp,gen}.go` + `*_test.go`, `cmd/ai-harness-init/main.go` + `main_test.go`,
`harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md`, `test/mutations/379-381-*.sh`, sowie
die Verfeinerung des Slice-Plans selbst (§3).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0
**Modell:** claude-sonnet-5 (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-20

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-unscoped-ziele-kollidieren-nicht-im-mono-repo` (`docs/plan/planning/in-progress/`, Stand im Arbeits-Commit inkl. §3-Verfeinerung)
- [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `AGENTS.md` §3 (Hard Rules), v. a. §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (Kommentar-Disziplin), §3.9 (Docker-only)
- Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice, `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
- Vorheriger Verifikations-Report [`2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md`](2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md) (im Slice-Kopf zitiert; nur als Provenienz der Renderer-Stellen gelesen, keine erneute Prüfung seines Gegenstands)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Plan §3 („Gewählte Form") und drei Code-Kommentare (main.go, golang.go, cpp.go) behaupten als Zusage: „das Rezept bleibt bei dem Fragment, das die unscoped Targets am Root zuerst geschrieben hat". Der eigene Konvergenz-Test widerlegt die Permanenz dieser Aussage: Wird das zuerst geschriebene Fragment erneut geschrieben (Re-Lauf `add-lang go .`, während `cpp.mk` bereits existiert), verliert *es selbst* sein Rezept und wechselt in die reine Präzedenz-Erweiterungsform — der Test verlangt das ausdrücklich (`!strings.Contains(gomk, "test: test-go") \|\| strings.Contains(gomk, "\ntest: ##")` muss danach falsch sein). Nach einem solchen Re-Lauf trägt **keines** der beiden Fragmente mehr das ursprüngliche unscoped Rezept — nur noch zwei Präzedenz-Erweiterungen auf die modul-scoped Targets. Funktional bleibt `make test/lint/build` davon unberührt (beide Sprachkontexte laufen weiter, da `record-gates`/die Prerequisite-Kette dies trägt), aber die Doku-Aussage über den Persistenz-Mechanismus ist keine verlässliche Beschreibung des Zustandsraums, sondern nur eine Momentaufnahme direkt nach dem zweiten `add-lang`. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist); Slice-Plan §3 | `docs/plan/planning/in-progress/slice-unscoped-ziele-kollidieren-nicht-im-mono-repo.md:118-131`; `cmd/ai-harness-init/main.go:18-25`; `internal/gen/golang.go:122-125,573-580`; `internal/gen/cpp.go:102-105,318-324`; belegt durch `cmd/ai-harness-init/main_test.go` (`TestRun_AddLangMixedRoot`, Re-Lauf-Block) | ja — `TestRun_AddLangMixedRoot` selbst zeigt den Effekt; kein Sensor hält die Prosa-Aussage dagegen | Persistenz-Zusage im Kommentar/Plan widerspricht dem eigenen Re-Lauf-Test |
| F-2 | LOW | Sowohl die unveränderte Einzel-Fassung (`GATE_CHECKS += lint build test`) als auch die neue gemischte Fassung (`GATE_CHECKS += test lint build`) hängen dieselben drei unscoped Namen an; am gemischten Root (dem primären, im E2E gemessenen Szenario go-single + cpp-mixed) landen `test`/`lint`/`build` darum zweimal in `GATE_CHECKS`, und `record-gates: $(GATE_CHECKS)` trägt eine Prerequisite-Liste mit Dubletten. Make baut jedes Ziel trotzdem nur einmal (kein Fehlverhalten), aber es ist genau das Muster „Ketten-Duplikate in Make-Targets", das der Skill als LOW-Beispiel nennt. | Maintainability | `internal/gen/golang.go:1021` (`GATE_CHECKS += lint build test`, Einzel-Fassung), `:605` (`GATE_CHECKS += test lint build`, gemischte Fassung); analog `internal/gen/cpp.go:681,681+40` | ja — `grep -c 'GATE_CHECKS += test lint build\|GATE_CHECKS += lint build test' harness/mk/*.mk` an einem gemischten Bootstrap zeigt zwei Treffer | Ketten-Duplikate in Make-Targets (unscoped Namen doppelt in GATE_CHECKS) |
| F-3 | LOW | `codeGateFragmentFor` bricht laut Plan-Prosa und Kommentar bei einem `Stat`-Fehler ≠ `ErrNotExist` statt die Fassung still zu wählen — eine explizit benannte Zusage (Plan §3, main.go-Kommentar Zeile 24f.). Kein Test erzwingt diesen Zweig (z. B. über einen unlesbaren `harness/mk/`-Ordner); die drei neuen Tests decken nur den Erfolgspfad (Datei existiert / existiert nicht). AGENTS.md §3.6 verlangt für jede Zusage ein rot gesehenes Gegenbeispiel. | `AGENTS.md` §3.6 | `cmd/ai-harness-init/main.go:37-46` (der `case !errors.Is(statErr, fs.ErrNotExist):`-Zweig) | ja — ein Test, der den Stat-Fehler erzwingt (z. B. `harness/mk/<other>.mk` als Verzeichnis mit entzogenen Leserechten), würde ihn belegen; heute existiert keiner | Defensiver Fehlerzweig ohne rote Gegenprobe |
| F-4 | LOW | Zwei aufeinanderfolgende Commits (`1d8c0081`, `3d818d90`) tragen wortgleiche Commit-Messages, obwohl der zweite ein inhaltlicher Fix ist (entfernt fälschliche `--build-arg GO_VERSION`/`--build-arg CXX_VERSION`-Marker und `einordnen`-Aufrufe aus dem E2E-Zahn). `git log --oneline` unterscheidet die beiden Commits nicht; wer die Historie liest, sieht zwei identische Titel ohne Hinweis, dass der zweite eine Korrektur des ersten ist. | Maintainability (Commit-Historie) | Commits `1d8c0081`, `3d818d90` | nein — kein Gate prüft Commit-Message-Eindeutigkeit über aufeinanderfolgende Commits | Wortgleiche Commit-Message für Arbeit und Nachzug-Fix |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| §1-Abgrenzung des Plans (kein Re-Publish, keine hexslice-Berührung, kein zweiter Fetch-Weg) | geprüft, ohne Befund — der Diff berührt weder `internal/fetch/` noch `internal/emit/archgate.go` noch hexslice-Layout-Code |
| Byte-Identität der Einzel-Sprach-Fassung (§6 Risiko 1) | geprüft, ohne Befund — `goMkFragmentTmpl`/`cppMkFragmentTmpl` und die Funktionen `goFragment`/`cppFragment` sind im Diff unverändert; `codeGateFragmentFor` liefert für `path != "."` und für den Fall „kein zweites Root-Fragment" weiterhin exakt `gen.CodeGateFragment(...)` |
| Determinismus (§6 Risiko 2, LH-QA-02) | geprüft, ohne Befund — `TestCodeGateFragmentMixed_Go` und `TestCppCodeGateFragmentMixed` rufen die gemischte Fassung je zweimal auf und vergleichen byte-genau; beide Renderer nutzen dieselbe Helper-Form (`mixedFragmentFest`, dedupliziert in `32045c93` gegen einen `dupl`-Befund) |
| Voll-E2E misst den direkten Aufruf ohne `--target` (Liefer-Punkt 2) | geprüft, ohne Befund — `harness/tools/full-smoke.sh:2250-2296` ruft `make -C "$tmprepo_mixed" test/lint/build` direkt, prüft beide Tag-Marker (`app:`, `cpp:`) und beide Sprachfassungen der Überschreibungs-Meldung (EN/DE) |
| `docs/user/e2e-abdeckung.md` regeneriert statt handeditiert | geprüft, ohne Befund — Stufen 9-20 sind konsistent verschoben, neue Stufe 9 trägt LH-FA-04/LH-QA-01; Fall (4) in `test/e2e-abdeckung.bats` hält die Datei ohnehin byte-gleich gegen den Generator |
| Mutations-Fälle 379-381 (Fall-Anlage-Form, MR-071) | geprüft, ohne Befund — alle drei `sed`-Muster treffen exakt auf den aktuellen Quell-Bestand (`return gen.CodeGateFragmentMixed(...)`, `test: test-{{MODULE}}`), `expect:` benennt die tatsächlich neuen Testnamen, Nummerierung 379-381 lückenlos nach 378 |
| AGENTS.md §3.9 (Docker-only) | geprüft, ohne Befund — keine Host-Toolchain in Befehlsposition; `sed` in den Mutations-Skripten folgt der etablierten Konvention (siehe z. B. `test/mutations/377-*.sh`) |
| Selbstkorrektur der Kommentar-Disziplin (§3.7) | geprüft, ohne Befund — Commit `d02e3552` entfernt selbst eine Chronik-Formulierung („Vor der Komposition definierten beide …") aus dem full-smoke-Kommentar und ersetzt sie durch eine Präsens-Beschreibung des Ist-Zustands |
| ADR-/Gate-Bezug | geprüft, ohne Befund — keine aktive ADR referenziert oder verletzt, kein halluziniertes Gate, keine Gate-Lockerung |
| `make gates` / `make full-smoke` selbst gefahren | **nicht** selbst gefahren (Docker-only, Reviewer-Lauf ohne Docker-Zugriff in dieser Sitzung) — Bestätigung bleibt beim Implementer-Bericht bzw. der Verifikation |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Persistenz-Zusage im Kommentar/Plan widerspricht dem eigenen Re-Lauf-Test · Ketten-Duplikate in Make-Targets (unscoped Namen doppelt in GATE_CHECKS) · Defensiver Fehlerzweig ohne rote Gegenprobe · Wortgleiche Commit-Message für Arbeit und Nachzug-Fix

## Verdikt

**Merge-blockierend:** nein — keine HIGH-Findings. Die Kernmechanik (Präzedenz-Erweiterung ohne
eigenes Rezept, GATE_CHECKS-Anhang, direkter E2E-Zahn) ist plan- und ADR-konform umgesetzt, die
Rot-Gegenproben für Liefer-Punkt 1 (Mutationen 379/380/381) und Liefer-Punkt 2 (bestehender
`e2e-abdeckung.bats`-Mechanismus) sind strukturell vorhanden. F-1 ist eine Dokumentations-/
Kommentar-Genauigkeitsfrage (keine Funktionsstörung), sollte aber vor Closure präzisiert werden,
da sie in vier Artefakten (Plan + drei Renderer/Aufrufer-Kommentare) dieselbe zu weit gehende
Persistenz-Behauptung wiederholt. F-2 bis F-4 sind Wartungs-Nits ohne Failure-Pfad am Gate.

**Übergabe:** Alle vier Findings gehen an den Implementer zur Klärung vor der nächsten Closure
(kein Rollen-Konflikt, keine Architect-Eskalation nötig). Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Steering-Loop-Zähler. Dieser Report ist ein Lauf-Beleg und
wird über Läufe hinweg nicht erneut gelesen. Verifikation (DoD-/Spec-Konformität, inkl. `make
gates`/`make mutate`-Läufe) ist Aufgabe des Verifiers, nicht dieses Reports.

# Slice slice-unscoped-ziele-kollidieren-nicht-im-mono-repo: Die unscoped-Ziele kollidieren nicht im gemischten Mono-Repo

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — die Komposition und der E2E-Zahn sind Belege der Liefer-Punkte
selbst.

**Bezug:**
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
(Mono-Repo: das Sprachmodul ist wiederholbar — zwei Module in einem Ziel),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(das Gate, dessen Kontext fehlt, ist still grün),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(gleicher Aufruf → byte-identische Ausgabe — die Komposition ändert die Form,
nicht die Determinismus-Zusage),
[Verifikations-Report des Fix-Slices](../../../../docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md)
(die Renderer-Stellen am gemessenen Stand); Setzung des Auftraggebers vom
2026-09-20: der mixed-Mono-Repo-Lauf misst den direkten Aufruf.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-20.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ziel:** Die unscoped `test`/`lint`/`build`-Ziele kollidieren nicht mehr im
gemischten Mono-Repo. Die Fundstellen: beide Renderer definieren die gleichen
unscoped Targets — `internal/gen/golang.go:969`/`:972`/`:975` (`test`,
`lint`, `build`) und `internal/gen/cpp.go:664`/`:667`/`:670` (dieselben
Namen); in einem Ziel mit beiden Sprachen meldet `make` die Überschreibung,
und die letzte Definition gewinnt — ein Modul fällt still heraus. Der
Voll-E2E misst die Mono-Repo-Gates-Kette über die `--target`-Marker
(`harness/tools/full-smoke.sh:2174-2182`) — der **direkte** Aufruf
(`make test` ohne `--target`) ist dort nicht gemessen. Der E2E-Zahn misst ihn:
der mixed-Mono-Repo-Lauf ruft `make test` (und `lint`/`build`) direkt und
verlangt, dass beide Sprach-Kontexte bedient sind — oder die Mechanik
komponiert die unscoped-Ziele (Sprach-Scoping oder Komposition im Aggregator —
die Wahl liegt beim Implementer am Bestand) und die E2E misst genau das.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Re-Publish von `v0.2.1`** — **anderer Vorgang:** der Generator-Output
  ändert sich für künftige Bootstraps; das published Release bleibt, wie es
  geschnitten ist. Ein Re-Publish würde die Tag-Kopplung
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2) für denselben Stand zweimal vollziehen.
- **Keine hexslice-Berührung** — **Bestand bleibt bewusst stehen:** der
  Adapter-Ports-Fix ist geschlossen; die Ordner-Namen und die Gate-Kanten
  stehen, wie sie sind.
- **Kein zweiter Fetch-Weg** — **Bestand bleibt bewusst stehen:** der Fetch
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 1) bleibt, wo er steht; der Slice rührt die Bau-Gerüstung, nicht
  den Träger-Weg.
- **Die `hexslice`-Layouts bleiben unberührt** — **Schicht-Abgrenzung:** der
  Slice trifft die unscoped Targets der Bau-Gerüstung (arch-invariant); die
  Layout-Achse bleibt, wie sie ist.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß.

- [ ] **Liefer-Punkt 1 — die Mechanik komponiert die unscoped-Ziele:** in
      einem Ziel mit beiden Sprachen beantwortet `make test` (und `lint`,
      `build`) den Aufruf, ohne ein Modul still fallen zu lassen — die
      make-Überschreibungsmeldung tritt nicht mehr auf, beide Kontexte sind
      bedient (Komposition oder Scoping, Wahl am Bestand). Rote Gegenprobe:
      vor dem Griff meldet `make` die Überschreibung der Targets und führt
      nur ein Modul aus (gemessen am mixed-Ziel) — der direkte Aufruf
      verliert den zweiten Kontext.
- [ ] **Liefer-Punkt 2 — der E2E-Zahn misst den direkten Aufruf:** der
      mixed-Mono-Repo-Lauf im Voll-E2E ruft `make test`/`lint`/`build`
      direkt (ohne `--target`) und verlangt, dass beide Sprach-Kontexte
      bedient sind; er trägt seine Kopfzeile im Stufen-Muster des Erzeugers
      und seine Deklaration — nach `make e2e-abdeckung` steht sie in
      `docs/user/e2e-abdeckung.md`. Rote Gegenprobe: ohne den direkten
      Aufruf fällt der Zahn aus der Sicht — der Fall in
      `test/e2e-abdeckung.bats` färbt rot (eine Stufe, die nur durch ihr
      Kommentar existiert, meldet der Generator nicht).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschritten — oder
      „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/golang.go` | update | die unscoped Targets `:969/:972/:975` — Komposition oder Scoping |
| `internal/gen/cpp.go` | update | dieselben Targets `:664/:667/:670` |
| `cmd/ai-harness-init/main.go` | update | (Verfeinerung) die Wahl der Fassung liegt am Aufrufer: `wireLang` erkennt am Root das zweite Sprach-Fragment (`harness/mk/<andere>.mk`) und nimmt die gemischte Fassung; Subdir bleibt, wie es ist |
| `harness/tools/full-smoke.sh` | update | der mixed-Lauf misst den direkten Aufruf (Liefer-Punkt 2) |
| `docs/user/e2e-abdeckung.md` | update | regeneriert via `make e2e-abdeckung` — nicht hand-edited |
| Renderer-Tests | update | die Erwartungen an die komponierte Form je Renderer |

**Gewählte Form (Komposition am Bestand):** die Einzel-Sprach-Ziele bleiben — am Root,
wo nur ein Sprach-Fragment liegt, ist die unscoped Fassung byte-identisch unverändert.
Liegt am Root ein zweites Sprach-Fragment, kommt das (gerade geschriebene) Fragment in
der **gemischten Fassung**: modul-scoped Targets (`test-go`/`test-cpp`, Kontext Root) plus
die unscoped Ziele `test`/`lint`/`build` **nur als Präzedenz-Erweiterung ohne eigenes
Rezept** — make hängt Präzedenz-Listen mehrerer Regeln zusammen. Geprüft wird je Aufruf
nur, ob am Root *jetzt* ein anderes Sprach-Fragment liegt; welches der beiden Fragmente
das eigene Rezept trägt, hängt damit vom Verlauf der `add-lang`-Aufrufe ab, nicht davon,
wer zuerst geschrieben hat. `GATE_CHECKS` hängt die **unscoped**
Namen an (die Aggregator-Kette komponiert über `record-gates: $(GATE_CHECKS)` und
dedupliziert die Präzedenz-Liste); die scoped Namen stehen nicht daneben, sonst liefe der
Kontext in `record-gates` doppelt. Grund gegen `::`-Rezepte (Doppel-Doppelpunkt in beiden
Fassungen): die Einzel-Sprach-Ziele blieben nur in der Wirkung, nicht in der Form
unverändert, und die Zusage der Renderer-Tests an die Einzel-Form (Risiko §6) hält so an
der bestehenden Fassung fest; der Präzedenz-Anhang ist dieselbe Mechanik, die der
Aggregator für `GATE_CHECKS` ohnehin fährt.

## 4. Trigger

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen:** zu groß → `next`, wenn die Komposition über die drei
unscoped Targets hinaus wächst; blockiert → `open`, falls die make-Mechanik
keine komponierte Form trägt, die die Einzel-Sprach-Ziele unberührt lässt.

## 5. Closure-Trigger

DoD mit den roten Gegenproben belegt und der mixed-Mono-Repo-Lauf im
Voll-E2E grün über dem direkten Aufruf.

## 6. Risiken und offene Punkte

- **Die Einzel-Sprach-Ziele dürfen nicht weichen** — die Komposition darf die
  Go-only- und C++-Ziele nicht ändern (byte-identisch
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
  Ausgang: entfallen, wenn die Renderer-Tests die Einzel-Form halten; sonst
  weiter offen.
- **Die Determinismus-Zusage** — gleicher Aufruf → byte-identische Ausgabe
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit));
  die Kompositions-Reihenfolge ist fest. Ausgang: entfallen, wenn die
  Renderer-Tests sie halten; sonst weiter offen.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) — die
Renderer (`internal/gen/`) — und `harness/tools/` — der Voll-E2E. Beide
erfüllen die Schwelle ≥ 2 von 3 Achsen (Inventur: ja; mehrere Dateien: ja;
Aussage: ja — die Mono-Repo-Zusagen). Beide stehen in der Modus-Deklaration
als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer für diese Sub-Areas: keine — kein Eintrag trägt die
Kollision-Klasse der unscoped Targets; die nächste in der Nähe,
`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
(**Zählerstand 5×**, Ausgang *verkörpert*), trägt eine andere Klasse und wird
durch diesen Plan nicht hochgeschrieben. Keine Treffer sind ebenfalls eine
Antwort und werden notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.
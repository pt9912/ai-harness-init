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

- [x] **Liefer-Punkt 1 — die Mechanik komponiert die unscoped-Ziele:** in
      einem Ziel mit beiden Sprachen beantwortet `make test` (und `lint`,
      `build`) den Aufruf, ohne ein Modul still fallen zu lassen — die
      make-Überschreibungsmeldung tritt nicht mehr auf, beide Kontexte sind
      bedient (Komposition oder Scoping, Wahl am Bestand). Rote Gegenprobe:
      vor dem Griff meldet `make` die Überschreibung der Targets und führt
      nur ein Modul aus (gemessen am mixed-Ziel) — der direkte Aufruf
      verliert den zweiten Kontext.
      **Belegt:** rote Gegenproben `test/mutations/379-381-*.sh`; grüne
      Funktionstests `TestCodeGateFragmentMixed_Go`
      (`internal/gen/gen_test.go:189`) / `TestCppCodeGateFragmentMixed`
      (`internal/gen/cpp_test.go:158`) und
      `TestRun_AddLangMixedRoot`/`TestRun_AddLangMixedRootCppFirst`/
      `TestRun_AddLangMixedRootStatError` (`cmd/ai-harness-init/main_test.go`);
      Review-Negativbefund „Byte-Identität der Einzel-Sprach-Fassung …/
      Determinismus … ohne Befund"
      ([Runde 1](../../../reviews/2026-09-20-slice-unscoped-ziele-kollidieren-nicht-im-mono-repo-runde-1.md)).
- [x] **Liefer-Punkt 2 — der E2E-Zahn misst den direkten Aufruf:** der
      mixed-Mono-Repo-Lauf im Voll-E2E ruft `make test`/`lint`/`build`
      direkt (ohne `--target`) und verlangt, dass beide Sprach-Kontexte
      bedient sind; er trägt seine Kopfzeile im Stufen-Muster des Erzeugers
      und seine Deklaration — nach `make e2e-abdeckung` steht sie in
      `docs/user/e2e-abdeckung.md`. Rote Gegenprobe: ohne den direkten
      Aufruf fällt der Zahn aus der Sicht — der Fall in
      `test/e2e-abdeckung.bats` färbt rot (eine Stufe, die nur durch ihr
      Kommentar existiert, meldet der Generator nicht).
      **Belegt:** `harness/tools/full-smoke.sh:2250-2296` ruft den
      mixed-Lauf direkt ohne `--target` (beide Tag-Marker `app:`/`cpp:`,
      beide Sprachfassungen der Überschreibungs-Meldung EN/DE);
      `docs/user/e2e-abdeckung.md` regeneriert (neue Stufe 9), gehalten von
      Fall (4) in `test/e2e-abdeckung.bats`. Verifiziert per
      Quelltext-Abgleich — der Verifier konnte in seiner Sitzung keinen
      `make full-smoke`-Lauf fahren (kein Docker-Zugriff); ein Docker-Lauf
      dieser Sitzung war für diese Bestätigung nicht zusätzlich nötig, da
      Review-Negativbefund und Quelltext übereinstimmend die Kopplung
      zeigen.
- [x] `make gates` grün — inhaltsbasiert nachgewiesen: der Arbeitsbaum-Hash
      in `.harness/state/gates-passed.diffsha` (`d3fa52f0…`) stimmt auf
      Commit `e1008ecc` (Mechanik: `harness/tools/working-tree-hash.sh`,
      Verifier-Bestätigung 2026-09-20).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
      [`2026-09-20-…-runde-1.md`](../../../reviews/2026-09-20-slice-unscoped-ziele-kollidieren-nicht-im-mono-repo-runde-1.md)
      (0 HIGH, 1 MEDIUM, 3 LOW; F-1/F-3 behoben in `e1008ecc`, F-2/F-4
      bewusst offen gelassen — siehe §7).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — siehe §7.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — siehe §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen — siehe §6/§7.

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
  **Ausgang: entfallen.** `git diff 77d5346a..e1008ecc -- internal/gen/golang.go`
  zeigt für den Einzel-Sprach-Pfad (`goFragment`/`CodeGateFragment`) keine
  Änderung, nur die neue Funktion `goFragmentMixed` kommt hinzu (analog
  `cpp.go`); `TestRun_AddLangRepeatable` hält den wiederholten
  Einzel-Sprach-Aufruf byte-identisch. Review-Negativbefund „Byte-Identität
  der Einzel-Sprach-Fassung … ohne Befund" bestätigt dasselbe unabhängig.
- **Die Determinismus-Zusage** — gleicher Aufruf → byte-identische Ausgabe
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit));
  die Kompositions-Reihenfolge ist fest. **Ausgang: entfallen.**
  `TestCodeGateFragmentMixed_Go`/`TestCppCodeGateFragmentMixed` rufen die
  gemischte Fassung je zweimal auf und vergleichen byte-genau; beide
  Renderer nutzen dieselbe Helper-Form (`mixedFragmentFest`). Review-
  Negativbefund bestätigt dasselbe unabhängig.

## 7. Closure-Notiz

- **Was hat funktioniert:** Die Präzedenz-Erweiterung ohne eigenes Rezept
  (§3 „Gewählte Form") hat die Kollision real aufgelöst, ohne die
  Einzel-Sprach-Fassungen anzurühren — beide Risiken aus §6 halten. Die
  Rot-Gegenproben (`test/mutations/379-381-*.sh`) und der direkte E2E-Zahn
  tragen beide Liefer-Punkte. Review (gegen Plan/ADR) und Verifikation
  (gegen DoD/Spec, Gate-Hash-Beleg) liefen mit unterschiedlichem
  Eingabe-Kontext und fanden unterschiedliche Klassen von Befunden — genau
  die Rollen-Trennung aus Modul 8, keine Redundanz.
- **Was ging anders als geplant:** Plan §3 hatte implizit eine
  Persistenz-Eigenschaft behauptet („das zuerst schreibende Fragment
  behält sein Rezept"), die der eigene, im selben Diff mitgelieferte
  Re-Lauf-Test bereits widerlegte (Review-Finding F-1, MEDIUM). Der
  Implementer-Fix (`e1008ecc`) hat die Zusage auf die tatsächlich haltbare
  Eigenschaft eingeschränkt — die Präzedenz-Erweiterung ist stabil,
  welches Fragment das eigene Rezept trägt, nicht. F-3 (defensiver
  Fehlerzweig ohne rote Gegenprobe, `AGENTS.md` §3.6) wurde im selben
  Commit mit einem neuen Test (`TestRun_AddLangMixedRootStatError`)
  geschlossen. F-2 (harmloses `GATE_CHECKS`-Duplikat) und F-4 (wortgleiche
  Commit-Messages `1d8c0081`/`3d818d90`) bleiben bewusst offen — beide sind
  laut Reviewer-Verdikt „Wartungs-Nits ohne Failure-Pfad am Gate", nicht
  merge-blockierend, und ein Rewrite bereits gemergter Commit-Historie für
  F-4 wäre ein Eingriff, den dieser Slice nicht rechtfertigt.
- **Steering-Loop-Eintrag:** Lese-Schritt und Trigger-Audit laufen hier,
  da der Slice ohne Welle geführt wird (Baseline-Regelwerk
  `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, Tabelle „Träger
  im Repo ohne Wellen"). Lese-Schritt: keine Registerzeile erreicht mit
  diesem Slice 3× — die zwei neu angelegten Beobachtungen (unten) stehen
  bei 1×, `offen`, kein Zielort verkörpert. Trigger-Audit: kein Carveout,
  kein bootstrap-aware Gate und keine ADR mit fälligem
  Re-Evaluierungs-Trigger sind an diesem Slice beteiligt — nichts
  fällig.
- **Beobachtungs-Register (`../observations/`):** zwei neue Verzeichnisse
  angelegt, Sub-Area `ALL` (Stichwort-Suche im Bestand vor Anlage ergab
  keinen Treffer für beide Klassen):
  [`persistenz-zusage-ist-eine-momentaufnahme`](../observations/BEO-ALL/persistenz-zusage-ist-eine-momentaufnahme/observation.md)
  (F-1-Klasse: Persistenz-Zusage widerspricht dem mitgelieferten Test) und
  [`commit-message-wiederholt-sich-beim-nachzug-fix`](../observations/BEO-ALL/commit-message-wiederholt-sich-beim-nachzug-fix/observation.md)
  (F-4-Klasse: wortgleiche Commit-Message für Arbeit und Nachzug-Fix; der
  Eintrag benennt zwei weitere, unbelegte Vorkommen aus der Repo-Historie
  unter „Benannt, nicht gezählt"). F-2 (GATE_CHECKS-Duplikat) ist reine
  Ketten-Redundanz ohne Failure-Pfad und bekommt keinen eigenen
  Register-Eintrag — dafür existiert keine erkennbare Wiederholungsklasse
  jenseits dieses einen Fundorts.
- **Folge-Slices:** keine. F-2/F-4 sind stehender, bewusst belassener
  Bestand (Begründung siehe oben); beide Register-Einträge stehen bei 1×
  und werden erst ab 3× zu einem verkörperten Steering-Loop-Eintrag oder
  einem eigenen Folge-Slice.
- **Risiken aus §6:** beide **entfallen** — Details und Belege stehen
  direkt in §6 bei den jeweiligen Bullets.
- **Drei Paarungen:**
  (a) Anker-Paarung — kein Eintrag dieser Closure trägt `liegt in
  <Zielort>` (keine Registerzeile hat 3× erreicht), daher nichts zu
  prüfen.
  (b) Folge-Slice-Paarung — keine Folge-Slices genannt, daher nichts zu
  prüfen.
  (c) Register-Paarung — beide neu angelegten Verzeichnisse existieren
  unter `docs/plan/planning/observations/BEO-ALL/` mit je einer
  nicht-leeren `evidence/`-Datei (`slice-unscoped-ziele-kollidieren-nicht-im-mono-repo.md`).

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
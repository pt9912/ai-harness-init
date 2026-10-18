# Verifikation — slice-java-hexslice-layout

**Rolle:** Verifier (Modul 11), frischer Kontext. **Gegenstand:** `docs/plan/planning/in-progress/slice-java-hexslice-layout.md`,
Range `eed91448..HEAD` (eb4c450c, e01a6d7a, 7acf530c, 10a752ac, 9cd94a10). **Gegen:** DoD, ADR-0094 (Accepted), Plan §3.
Alle Läufe Docker-only, GNU-sed im PATH, `MUTATE_JOBS=1`, `SMOKE_ARTIFACT_TARGET=artifact-host` bei den Lauf-Zähnen.

## Verdikt

Alle fachlichen DoD-Punkte (1 bis 4) sind bestätigt. Offen: die Zahl der Messzahl-Commit-Message für den Gesamt-Zuwachs
trägt nicht (Befund V-1, MEDIUM). H-1 des Reviews ist behoben. Die Punkte 5 bis 9 gehören dem Planner (Closure).

## H-1 (Review) — behoben

- `git show --stat -M e01a6d7a`: eine Datei, `678-java-hexslice-ohne-renderer.sh => 678-java-hexagonal-ohne-renderer.sh | 0` (Rename 100 %).
- `git show --stat -M 7acf530c`: 678 erscheint nur als Inhaltsänderung (`678-java-hexagonal-ohne-renderer.sh | 10 +-`), kein A/D.
- `git diff backup-vor-h1 HEAD | wc -c` → `0` (Baum-Gleichheit mit dem Alt-Stand).
- Reihenfolge `eb4c450c → e01a6d7a → 7acf530c → 10a752ac → 9cd94a10` bestätigt (`git log --oneline eed91448..HEAD`).

## DoD je Punkt

**DoD 1 — Renderer + a-check-Config + Lauf-Zahn in derselben Lieferung: bestätigt.**
- Gelesen: `internal/gen/java_hexslice.go` — `languages` java `**/*.java`, `resolution java: fixed-root`, `roots ["src/main/java/app"]`,
  `package_base "app"`; sieben Kanten inkl. `driven_adapters → ports_outbound`; Pfade nach ADR-0060 (`jvm.go`, Paket = Verzeichnis).
  `langArchs()["java"] = {flat, hexslice}`; `archGateConfigs()["java"]` ergänzt; `hexagonal` → Exit 2 (Fall 678, Stufe in der Java-flat-Stufe).
- Realquelle: Bootstrap `host-bin --lang java --arch hexslice` in gitignoriertem Probeverzeichnis, `make a-check` → `gesamt: 0 Befund(e)`,
  ohne Hinweis „Import-Symbolen". Die Kante `driven_adapters → ports_outbound` ist im Ziel grün (ein Adapter implementiert den Port).
- Rot-Beleg Kante (nachgetragen): Kante per GNU-sed entfernt → `make a-check` Exit 2,
  `wrong-direction: 2`, `InMemoryRepository.java:5: wrong-direction: driven_adapters -> ports_outbound (…GreetingRepository)` und
  `StdoutNotifier.java:4: wrong-direction: driven_adapters -> ports_outbound (…Notifier)`.
- Lauf-Zähne (gefahren, je einzeln `MUTATE_CASES=… make mutate`, Meldung gelesen):
  - 724 (Rolle domain→app): `ok … -> full-smoke: FEHLER — Java-Arch-Gate rot, aber nicht mit core-impurity an der Domain-Datei`, 148,7 s. Ursache wie behauptet.
  - 725 (Root `src/main/java` statt `…/app`): `ok … -> full-smoke: FEHLER — das Java-Arch-Gate ist gruen, loest aber keinen Import auf`, 139,7 s. Ursache wie behauptet.
  - 727 (Kante entfernt): `ok … -> full-smoke: FEHLER — make gates nach add-lang java --arch hexslice ist NICHT Exit 0`, 186,4 s.
    Review INFO-1 bestätigt: die Meldung der Stufe nennt `wrong-direction` nicht, `# expect:` pinnt nur „NICHT Exit 0". Ursache ist jedoch
    nicht frei: die Mutation ändert allein die Kante, der Grün-Vorlauf (235 s) belegt, dass alle übrigen Gates grün sind, und die Handprobe oben
    (identische Mutation, echtes a-check) liefert allein `wrong-direction` an zwei Dateien. Eine andere Ursache ist mit dieser Mutation nicht denkbar;
    der Beleg im Lauf ist aber „irgendwie rot" — das Pinnen auf `wrong-direction` bleibt ein Verbesserungsfall (V-3, LOW).
- Text-Wächter 719–723, 726, 728–730 vom Reviewer einzeln gefahren (Report, Negativbefund), `mutate-greift` über alle 716 Fälle `0 Befund(e)`;
  nicht wiederholt, Stichprobe über den vollen `make gates` (siehe unten, Exit 0).

**DoD 2 — full-smoke-Stufe, Abdeckungs-Sicht, Messzahl: Stufe und Sicht bestätigt; Messzahl bedingt.**
- Stufe (`harness/tools/full-smoke.sh`, „Java-hexSlice-Stufe"): `add-lang java apps/javahexslice --arch hexslice`, `make gates` grün,
  Marker, Abwesenheit „Import-Symbolen", roter Fall mit `Greeting.java:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier`,
  Ruecknahme, Gegenprobe grün; Meldung gelesen in meinem Lauf `make full-smoke-host` (rc=0, „Java-hexSlice-Stufe dauerte 11s").
  Rot-Belege über 724, 725, 727 (oben). `e2e_abdeckung`-Kopfzeile vorhanden; `docs/user/e2e-abdeckung.md` Zeile „Stufe 23" nennt Gemessenes und
  NICHT Gemessenes am selben Ort; Datei vom `make gates`-Lauf mitgeprüft (Exit 0).
- L-2 des Reviews bewertet: „Paket gleich Verzeichnis" steht in der Zeile unter Gemessenem, die Stufe misst es nicht (sie misst Import-Auflösung;
  Paket == Verzeichnis hält `internal/gen/java_hexslice_test.go`, Fall 719). Die Zeile nennt zugleich „ein Paket ausserhalb seines Verzeichnisses"
  unter NICHT gemessen — widersprüchlich lesbar, §3.6-Klasse „emittierte Zusage". **LOW, bestätigt** (V-2); berührt die Abnahme nicht (die Zusage
  der DoD ist `core-impurity` + Gegenprobe), ist aber vor der Closure zu glätten (Klammer streichen oder „Paket gleich Verzeichnis (Go-Test, nicht die Stufe)").
- Messzahl nach MR-089: Commit-Message 10a752ac nennt Kommando `make full-smoke-host`, Lage (warm: gradle-Image, a-check-Image, Build-Cache),
  Variante `artifact-host`, Läufe vorher 228/202 s, nachher 280/282 s, Stufe 12/11 s (erster Lauf 20 s), Rauschen ~25 s, „Kaltlauf ungemessen".
  Form erfüllt (im Baum, nicht nur im Handoff). Eigene Messung (je ein Lauf, `make full-smoke-host`, Worktree `eed91448` unter
  `.harness/state/wt-vorher`, danach entfernt; macOS/Colima, Image warm nach vorangegangenen Läufen, Variante artifact-host):
  **vorher 263 s, nachher 268 s** (Gesamt +5 s); Stufenzeit Java-hexSlice **11 s** (deckt sich mit 11/12 s der Message).
  - Die Stufenzeit ist bestätigt.
  - Der Gesamt-Zuwachs der Message (52–80 s, Mittel 66 s) ist **nicht reproduziert**: +5 s liegt im Rauschen (~25 s). Die vorher-Läufe der
    Message (228/202 s) liegen deutlich unter meinem Vorher (263 s), die nachher-Läufe (280/282 s) nahe an meinem Nachher (268 s) — wahrscheinlich
    Zustandsdrift des Hosts (Cache/Last) zwischen den Messreihen, nicht der Diff. Die Erklärung des Reviewers (I-3: `kennungs_form_im_ziel` und
    zwei `make gates` über das Mono-Repo fahren `apps/javahexslice` mit) ist **plausibel für wenige Sekunden** (Stufenzeiten Kotlin-hexSlice 13→11 s,
    C# 14→11 s variieren in dieser Größe), trägt aber **nicht** 40–68 s. Einzelne Läufe je Stand; belastbar ist allein die Stufenzeit.
    Fazit: Zahl bedingt bestätigt (Stufe ja, Gesamt nein). V-1.

**DoD 3 — `spec/architecture.md` Layout je Sprache: bestätigt.** Diff gelesen: `java` unter den Sprachen mit `flat` und `hexslice`; `src/main/java/app/…`,
`Main.java`, `src/test/java/`, `fixed-root` mit `src/main/java/app`, `package_base app`, Kante `driven_adapters→ports_outbound`; Zusatz „bei Java
ebenso ein voll qualifizierter Name ohne `import`" deckt sich mit der Realprobe des Reviewers und der NICHT-gemessen-Zeile. Keine Zeit-/Liefersätze.
Rollenfrage: zulässig (AGENTS.md §3.8 bindet nur Hard Rules und Adaptions-Block; ADR-0094 Folgepflicht und Plan-DoD 3 nennen den Slice als Träger;
`slice-151` bleibt offen). Ich bestätige I-4 des Reviews.

**DoD 4 — `make gates`:** einmal am Ende mit GNU-sed-PATH gefahren → `rc=0` (Log `…/vf/gates.log` gelesen: `d-check: 2829 Datei(en) geprüft, 0 Befund(e)`,
bats/Go-Tests, `mutate-greift` Teil der Kette). **bestätigt.**

**DoD 5–9 (Review-Report, Closure-Notiz, Register, Risiko-Ausgänge, Paarungen):** Closure-Arbeit des Planners (§3.10); Review-Report liegt vor
(`docs/reviews/2026-10-18-slice-java-hexslice-layout.md`). §7 ist leer, wie vor der Closure zu erwarten. **Nicht Gegenstand dieser Verifikation.**

## Weitere Prüfungen

- **Kotlin-Refactoring (`jvm.go`/`jvmLayout`, `kotlin.go`, `kotlin_test.go`):** Diff gelesen — `kotlinRole` liefert über `jvmLayout.role` dieselben
  Pfade, Rollen und Dateiinhalte wie die gelöschte Switch-Fassung (Mapping Zeile für Zeile verglichen; `hexagonal` → nil unverändert).
  Gefahren (je einzeln, ok, Ursache aus der Meldung): 623 `TestKotlinHexslice_PaketGleichVerzeichnis rot`, 624 `TestArchGateConfig_KotlinEdgesMatchSkeleton rot`,
  626 `TestKotlinCodeGateFragment_RootUndSubdir rot`, 618 `TestKotlinCodeGateFragment_TargetsMatchStages rot`. Keine Wächter-Zähne verloren.
  Nicht gefahren: 625, 621, 628 (full-smoke, berühren die Config-Konstante); der Kotlin-Stufenlauf selbst lief grün im `full-smoke-host` (Kotlin-hexSlice-Stufe 11 s, Kotlin-Root-Stufe).
- **Out-of-Scope:** kein python-/csharp-hexslice (`langArchs` python/csharp bleiben `{flat}`), kein `hexagonal` für Java (Exit 2, Fall 678), kein a-check-Eingriff,
  kein Freshness-Werkzeug. L-1 des Reviews (Benutzerhandbuch Z. 328 nennt `go, cpp, kotlin` und `cpp oder kotlin mit hexagonal`, `java` fehlt seit `slice-java-skelett`)
  gelesen: die Lücke besteht vorab, DoD und ADR-0094 nennen das Handbuch nicht; die Abnahme berührt sie nicht. Sie ist ein öffentlicher Vertrag (AGENTS.md §6 Schritt 7) —
  Planner-Entscheidung (Folge-Slice oder Mitnahme beim Sprachprofil-Abschluss).
- **Rollen-/Commit-Zuschnitt:** `git log --format='%h %s' -- AGENTS.md docs/plan/adr harness/conventions* spec/lastenheft.md` über `eed91448..HEAD` leer; kein
  ADR-, AGENTS-, conventions- oder Lastenheft-Eingriff. Commits tragen die Rolle in der Message und Kennungen (LH-FA-04, LH-FA-07, ADR-0094); Move getrennt von Rewrite (H-1 behoben).

## Befunde

- **V-1 (MEDIUM, Zusage):** Die Messzahl der Commit-Message 10a752ac nennt einen Gesamt-Zuwachs von 52–80 s; mein einzelner Vorher/Nachher-Lauf zeigt +5 s (263 → 268 s).
  Die Stufenzeit (11 s) stimmt. Die Gesamtzahl ist von der Messreihe-Drift getragen, nicht von der Stufe. Empfehlung: Closure nennt die Stufenzeit als belastbare Zahl und
  die Gesamt-Zahl als „im Rauschen, 5 bis 66 s je nach Messreihe"; kein Code-Befund.
- **V-2 (LOW, Zusage):** L-2 des Reviews bestätigt (Abdeckungs-Zeile nennt „Paket gleich Verzeichnis" unter Gemessenem, die Stufe misst es nicht).
- **V-3 (LOW):** Fall 727 pinnt die Ursache nicht (`# expect:` „NICHT Exit 0"); Handprobe belegt `wrong-direction`. Verbesserung (z. B. eine Meldung der Stufe mit der Fundstelle) ist ein Folgefall.
- Negativbefunde je Schwerpunkt: Plan-vs-Code (Plan §3-Tabelle ↔ Diff) — nichts Gebautes ohne Plan (`jvm.go` und `skeleton_helpers_test.go` sind der Kotlin/Java-Teilung dienende Refactorings, im Review-Diff gelesen, kein Zahn verloren);
  Config-Text ↔ Spec ↔ Stufe konsistent; keine Host-Toolchain; Probeverzeichnisse und Worktree entfernt, kein Push nach `mutate/…`.

## Empfehlung für die Closure (Planner)

H-1 behoben, DoD 1–4 bestätigt. Vor der Closure: V-1 in §7 als Zahl mit Lage/Variante und dem Rauschen festhalten (Stufenzeit 11 s belastbar, Gesamt unsicher);
V-2 (Zeile glätten, kleiner Implementer-Nachtrag oder Folge) und L-1/V-3 als Folge-Slice oder Register-Beleg entscheiden. Risiken aus §6: alle vier aus den Läufen entscheidbar
(Gegenbeispiel rot am Ziel gesehen; Paket-Außerhalb bleibt benannte Grenze mit Go-Test; Kante grün und rot am Ziel gesehen; Lauf-Zahn 724/725/727 in derselben Lieferung).
Der Slice-Abschluss ist Planner-Arbeit (§3.10).

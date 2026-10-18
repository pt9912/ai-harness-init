# Slice slice-csharp-hexslice-layout: C#-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp`.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren). [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md)
(Accepted) legt die Layouts `flat` und `hexslice` fest, Festlegung 5 trägt Pfade und Auflösung.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über die ADR
des Architect).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-18.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang csharp --arch hexslice` rendert die Rollen-Verzeichnisse der ADR (Pfade nach
[ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md), PascalCase,
Verzeichnis gleich Namensraum) samt `.a-check.yml`, und ein `using` aus dem Kern in einen Adapter färbt
das emittierte Arch-Gate rot.

**Abhängigkeit:** setzt `slice-csharp-skelett` voraus (Renderer, Gerüst, Stufe im Mono-Repo); er liegt
in `done/`.

**Ausdrücklich NICHT in diesem Slice:**

- `flat` und das C#-Gerüst — liefert `slice-csharp-skelett`; hier nur die Schicht-Achse darüber.
- `hexagonal` — die ADR legt das Layout nicht fest (Re-Evaluierungs-Trigger, Folge-ADR); ohne ADR
  wäre es eine ungetragene Entscheidung.
- Eine Anforderung an a-check — nur, wenn eine Config, die `using`s auflöst, grün bleibt
  (Re-Evaluierungs-Trigger der ADR); dann Rückführung.
- `app-impurity`, `wrong-direction` und `lateral-adapter` als rote Fälle — die ADR hat sie nicht
  gefahren; die Stufe misst `core-impurity`, die übrigen bleiben Zusage.
- Ein Sensor für die Verzeichnis-Schreibweise beim Adopter — die ADR benennt die Lücke (`IDE0130`
  unterscheidet Groß-/Kleinschreibung nicht); der Slice hält den Renderer, nicht den Adopter.
- Ein C#-Freshness-Werkzeug — anderer Vorgang als das Layout.

## 2. Definition of Done

- [ ] hexslice-Renderer mit den Pfaden der ADR Festlegung 5 (`src/App/Hexagon/{Domain,Application}/…`,
      `src/App/Adapters/{Driving,Driven}/…`, Composition Root `src/App/Program.cs`, Tests unter
      `tests/App.Tests`); `archGateConfigs()` mit `languages: csharp: ["**/*.cs"]`,
      `exclude: ["tests/**"]` und `resolution: csharp: {mode: fixed-root, roots: ["src/App"],
      package_base: "App"}`; `csharp` in `langArchs()` führt `hexslice`; **Entscheidung von
      Ports-Ordnern und Kanten-Menge** ([ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
      Festlegung 4, Kotlin-Muster; die Kante `driven_adapters → ports_outbound` ist am C#-Fall nicht
      gemessen; Kanten-Menge nach [`slice-java-hexslice-layout`](../done/slice-java-hexslice-layout.md)
      und [`slice-python-hexslice-layout`](../done/slice-python-hexslice-layout.md): sieben Kanten
      einschließlich `driven_adapters → ports_outbound`, im Ziel gemessen) im Plan §7 und im Test
      festgehalten; **ein Test hält die gerenderten Verzeichnis-Globs der `.a-check.yml` gegen die
      gerenderten Pfade** (PascalCase-Schreibweise; einmal rot gesehen mit einem klein geschriebenen
      Verzeichnis); im gebootstrappten Ziel meldet a-check keinen Hinweis „0 von N Import-Symbolen
      lösen auf" (Probe gegen das Ziel, nicht gegen eine Fixture). **Je Config-Schlüssel ein
      Text-Wächter, und der Lauf-Zahn im Ziel (rot an `core-impurity`, Kante `driven_adapters → ports_outbound`
      grün) kommt in derselben Lieferung** ([`AGENTS.md`](../../../../AGENTS.md) §3.6); Fälle ab 748.
      Wo ein Schlüssel nur den Text-Wächter trägt, nennt die Abdeckungs-Zeile die Lücke am selben Ort.
- [ ] `make full-smoke`: `add-lang csharp <pfad> --arch hexslice` grün; mit `using` aus
      `App.Hexagon.Domain` nach `App.Adapters` rot mit `core-impurity` (Meldung gelesen), Gegenprobe
      grün; Stufe mit `e2e_abdeckung`-Kopfzeile (Grenzen von a-check am Pin am selben Ort: voll
      qualifizierter Name, `<Using>` im `.csproj`, Reflection, Namensraum ≠ Verzeichnis,
      Kleinschreibung; `exclude: tests/**` als nicht gemessene Gerüst-Wahl), `docs/user/e2e-abdeckung.md`
      neu erzeugt; jeder neue Full-Smoke-Fall pinnt die Ursache im `# expect:` (nicht nur „rot");
      die Stufen-Selbstprüfung `test/full-smoke-ausgang.bats` (Fall 177 zählt die `einordnen`-Aufrufe der
      Stufen) bleibt grün. **Laufzeit-Zuwachs ([`MR-089`](../../../../harness/conventions.md#mr-089));
      die Zahl steht bei der Übergabe im Baum:** Kommando `make full-smoke-host`, Lage (Image warm oder
      kalt), Variante, mindestens zwei Läufe je Stand (vorher/nachher) in einer Commit-Message des
      Implementers oder einer Datei des Lieferstands. Belastbar ist die Stufenzeit; die Gesamtdauer
      rauscht um rund 25 s und trägt keinen Zuwachs allein; der Verifier hält die Zahl gegen seine
      eigene Messung.
- [ ] `spec/architecture.md` Layout je Sprache um C# nachgezogen (Folgepflicht der ADR).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/csharp.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer, `archGateConfigs()`, `langArchs()`; Glob-gegen-Pfad-Test; Test-Helfer gemeinsam mit den anderen Sprach-Tests aus `internal/gen/skeleton_helpers_test.go`, kein Klon |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe und Arch-Zahn, erzeugte Sicht; Berührungspunkt `emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` |
| `spec/architecture.md` | update | Layout je Sprache |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)), neue Nummern ab 748; **Prüfauftrag an den Implementer:** Fall 705 `csharp-hexslice-ohne-renderer` (erwartet `TestGenerateArch_CsharpNurFlat`) ist am Quell-Bestand zu messen — bleibt seine Zusage mit dem Renderer wahr (dann Wächter, ggf. Umbenennung auf `csharp-hexagonal-ohne-renderer` wie Fall 690 bei Python), oder ist sie überholt; bei Umbenennung reiner `git mv` zuerst, Inhalt in eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3, [`BEO-ALL/move-und-umschreiben-in-einem-commit`](../observations/BEO-ALL/move-und-umschreiben-in-einem-commit/observation.md)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-csharp-skelett` liegt in `done/` (erfüllt), die ADR für C# ist
`Accepted`, WIP-Slot frei.

**Rückführungen — vorab benennen:**

- `in-progress` → `next`: der Rollen-Renderer verlangt eine Änderung am sprach-agnostischen Seam
  `internal/gen/arch.go` — eigener Schnitt.
- `in-progress` → `open`: eine auflösende Config bleibt grün (Trigger der ADR) — Anforderung an a-check
  über den Auftraggeber.

## 5. Closure-Trigger

DoD vollständig, Arch-Zahn rot und Gegenprobe grün in `make full-smoke`, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Das Gegenbeispiel färbt am gebootstrappten Ziel nicht rot (die ADR hat es nur an einer
  Zwei-Schichten-Probe rot gesehen, nicht am vollen Skelett) — **Ausgang:** bei der Closure; zuerst
  die Config prüfen (Hinweis „0 von N Import-Symbolen"), Layout sonst aus dem Slice nehmen.
- Die Verzeichnis-Schreibweise hält am Adopter kein Sensor (`IDE0130` unterscheidet Groß-/Kleinschreibung
  nicht; ein klein geschriebenes Verzeichnis gibt ein stilles Grün im Arch-Gate) — **Ausgang:** bei der
  Closure; der Glob-gegen-Pfad-Test hält den Renderer, die Lücke bleibt in der Abdeckungs-Zeile der
  Stufe benannt.
- Voll qualifizierter Name ohne `using`, `<Using>` im `.csproj` und Reflection entgehen dem Arch-Gate
  (Grenze von a-check am Pin bzw. des Glob-Prüfbereichs) — **Ausgang:** bei der Closure; Grenze in
  der Abdeckungs-Zeile der Stufe benannt.
- Die Kante `driven_adapters → ports_outbound` ist am C#-Fall nicht gemessen — **Ausgang:** bei der
  Closure; Entscheidung und Messung im Test festgehalten (§2).
- Die Messzahl steht bei der Übergabe nicht im Baum oder trägt nur über das Rauschen der Gesamtdauer —
  **Ausgang:** bei der Closure; DoD 2 nennt Kommando, Lage, Variante und Läufe, der Verifier misst gegen.
- Ein neuer Full-Smoke-Fall färbt an der falschen Ursache rot (grobes `# expect:`) — **Ausgang:** bei der
  Closure; das `# expect:` pinnt die Ursache, der Verifier prüft per Handprobe.
- Eine neue Stufe, die `einordnen` aufruft, bricht die Zählgleichung in `test/full-smoke-ausgang.bats`
  (Fall 177) — **Ausgang:** bei der Closure; der Lieferstand fährt den Test vor der Übergabe.

## 7. Closure-Notiz

<!-- Erst bei der Closure füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Layout liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-18):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der a-check-Pin besteht schon ·
`waechter-misst-die-fixture-statt-der-realen-quelle` — 10, verkörpert; die Probe läuft gegen das Ziel,
nicht gegen eine Fixture ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die Stufe erbt es ·
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` — 1, offen; die Stufe
fährt den Mono-Repo-Pfad, ein Fund am gemischten Root wäre der zweite Beleg ·
`waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` — 3, verkörpert ([`AGENTS.md`](../../../../AGENTS.md)
§3.6); Lauf-Zahn im Ziel in derselben Lieferung (DoD 1) ·
`move-und-umschreiben-in-einem-commit` — 1, offen; Fall 705 (§3) ·
`full-smoke-fall-expect-pinnt-nicht-die-ursache` — 2, offen; ein weiteres Auftreten wäre das dritte (DoD 2) ·
`relativer-import-am-hexslice-ziel-ungefahren` — 1, offen; Python-spezifisch, C# berührt ihn nicht (der
Namensraum-Fall ist die C#-Entsprechung, DoD 2).

**Modus:** alle berührten Sub-Areas GF.

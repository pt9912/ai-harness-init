# Slice slice-csharp-hexslice-layout: C#-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp`.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren). [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md)
(Accepted) legt die Layouts `flat` und `hexslice` fest, Festlegung 5 trägt Pfade und Auflösung;
[`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) (Accepted) löst davon drei Sätze ab
(Supersedes (Teil)): die Richtungs-Ordner `inbound`/`outbound` unter `Ports` sind klein, `Ports` und alles
übrige PascalCase, damit `port-locality` greift.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über die ADRs
des Architect, [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) und [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)).

**Planner-Änderung der Abnahme (2026-10-18, nach [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)):** DoD 1 bis 3 tragen die kleine Richtung; neu
in der Abnahme sind der Lauf-Zahn `port-locality`, die Adopter-Anleitung im Config-Kommentar, der
Fall für den Lauf-Zahn und die Abdeckungs-Aussage ohne „port-locality ungeprüft". Der Implementer-Stand
`3e91174c..6964b9c7` (PascalCase-Richtung) erfüllt sie nicht und wird nachgezogen.

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-18.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang csharp --arch hexslice` rendert die Rollen-Verzeichnisse der ADRs (Pfade nach
[ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md), PascalCase außer den
Richtungs-Ordnern `inbound`/`outbound` unter `Ports` nach
[ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md); Verzeichnis gleich Namensraum) samt
`.a-check.yml`; ein `using` aus dem Kern in einen Adapter färbt das emittierte Arch-Gate rot
(`core-impurity`), ein fremder Port-`using` im Handler ebenso (`port-locality`).

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
- Ein Sensor für die Verzeichnis-Schreibweise beim Adopter — die ADRs benennen die Lücke (`IDE0130`
  unterscheidet Groß-/Kleinschreibung nicht); der Slice hält den Renderer, nicht den Adopter.
- Eine Anforderung an a-check, das Richtungs-Segment ohne Beachtung der Schreibweise abzuziehen
  (Alternative C der [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)) — Re-Evaluierungs-Trigger der ADR, vom Auftraggeber nicht jetzt gestellt.
- Ein C#-Freshness-Werkzeug — anderer Vorgang als das Layout.

## 2. Definition of Done

- [x] hexslice-Renderer mit den Pfaden der [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 5 (`src/App/Hexagon/{Domain,Application}/…`,
      `src/App/Adapters/{Driving,Driven}/…`, Composition Root `src/App/Program.cs`, Tests unter
      `tests/App.Tests`) **und den kleinen Richtungs-Ordnern der [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)**
      (`…/Ports/{inbound,outbound}/`; Verzeichnisse und Namensräume, z. B.
      `App.Hexagon.Application.Example.Greet.Ports.inbound`; `Ports` und alles übrige PascalCase);
      `archGateConfigs()` mit `languages: csharp: ["**/*.cs"]`,
      `exclude: ["tests/**"]` und `resolution: csharp: {mode: fixed-root, roots: ["src/App"],
      package_base: "App"}`; `csharp` in `langArchs()` führt `hexslice`; **Entscheidung von
      Ports-Ordnern und Kanten-Menge** ([ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
      Festlegung 4, Kotlin-Muster; die Kante `driven_adapters → ports_outbound` ist am C#-Fall nicht
      gemessen; Kanten-Menge nach [`slice-java-hexslice-layout`](../done/slice-java-hexslice-layout.md)
      und [`slice-python-hexslice-layout`](../done/slice-python-hexslice-layout.md): sieben Kanten
      einschließlich `driven_adapters → ports_outbound`, im Ziel gemessen) im Plan §7 und im Test
      festgehalten; **ein Test hält die gerenderten Verzeichnis-Globs der `.a-check.yml` gegen die
      gerenderten Pfade** (Richtungs-Segment klein, übrige PascalCase; einmal rot gesehen durch Großschreiben
      eines Richtungs-Segments in Renderer oder Config); die **emittierte Config** trägt Port-Globs
      `…/Ports/{inbound,outbound}/**`, und ihr Kommentar nennt die gemessene Ursache — das
      kleingeschriebene Richtungs-Segment, nicht den Ordner `ports` (Review F1) — samt Anleitung für eine
      neue Slice (Verzeichnis, Namensraum und Glob mit kleiner Richtung); im gebootstrappten Ziel meldet
      a-check weder „0 von N Import-Symbolen lösen auf" noch den Hinweis „erreichen den App-Baum nicht"
      (Probe gegen das Ziel, nicht gegen eine Fixture). **Je Config-Schlüssel ein Text-Wächter, und die
      Lauf-Zähne im Ziel kommen in derselben Lieferung** ([`AGENTS.md`](../../../../AGENTS.md) §3.6):
      `core-impurity` rot, Kante `driven_adapters → ports_outbound` grün, und **`port-locality`**: eine
      zweite Slice, angelegt nach der Vorschrift des Config-Kommentars, und ein fremder Port-`using` im
      Handler färben a-check rot mit `port-locality … Handler.cs:<Zeile>` (wörtlich
      `port-locality: app außerhalb Port-Scope …/<Slice>`); die grüne Ausgabe des unveränderten Ziels
      trägt den Hinweis nicht. Fälle ab 748. Wo ein Schlüssel nur den Text-Wächter trägt, nennt die
      Abdeckungs-Zeile die Lücke am selben Ort.
- [x] `make full-smoke`: `add-lang csharp <pfad> --arch hexslice` grün; mit `using` aus
      `App.Hexagon.Domain` nach `App.Adapters` rot mit `core-impurity` (Meldung gelesen), Gegenprobe
      grün; Stufe mit `e2e_abdeckung`-Kopfzeile (Grenzen von a-check am Pin am selben Ort: voll
      qualifizierter Name, `<Using>` im `.csproj`, Reflection, Namensraum ≠ Verzeichnis,
      Schreibweise des Richtungs-Segments beim Adopter ohne Sensor; `exclude: tests/**` als nicht gemessene
      Gerüst-Wahl; die Aussage „port-locality ungeprüft" entfällt, `port-locality` ist gemessen), die
      Aussage steht übereinstimmend an den vier Orten Config-Kommentar, `spec/architecture.md`,
      Abdeckungs-Zeile und Stufen-Kopf (kein Sensor hält die Übereinstimmung, [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) nennt die Lücke),
      `docs/user/e2e-abdeckung.md` neu erzeugt; jeder neue Full-Smoke-Fall pinnt die Ursache im
      `# expect:` (nicht nur „rot"), der Fall für `port-locality` pinnt `port-locality` und `Handler.cs`;
      die Stufen-Selbstprüfung `test/full-smoke-ausgang.bats` (Fall 177 zählt die `einordnen`-Aufrufe der
      Stufen) bleibt grün. **Laufzeit-Zuwachs ([`MR-089`](../../../../harness/conventions.md#mr-089));
      die Zahl steht bei der Übergabe im Baum:** Kommando `make full-smoke-host`, Lage (Image warm oder
      kalt), Variante, mindestens zwei Läufe je Stand (vorher/nachher) in einer Commit-Message des
      Implementers oder einer Datei des Lieferstands; die Läufe wechseln sich ab (V, N, V, N), damit ein
      Ausreißer (der erste Nachher-Lauf lag bei 495 s, erklärt, nicht gemessen) sich nicht an einem Stand
      festsetzt. Belastbar ist die Stufenzeit; die Gesamtdauer rauscht um rund 25 s und trägt keinen
      Zuwachs allein; der Verifier hält die Zahl gegen seine eigene Messung.
      **Mutations-Fälle 748 bis 763** (Pfade, Muster, `# expect:` auf die kleine Richtung; Fall 756
      (Glob gegen Verzeichnis) und Fall 760 (Namensraum) am Quell-Bestand neu gemessen), **ein neuer Fall
      für den `port-locality`-Lauf-Zahn**, rot herstellbar durch Großschreiben des Richtungs-Segments;
      jede Umbenennung eines Falls zuerst als reiner `git mv`, der Inhalt danach in eigenem Commit
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
- [x] `spec/architecture.md` Layout je Sprache um C# nachgezogen, mit den kleinen Richtungs-Ordnern und
      der Aussage, dass `port-locality` geprüft ist (Folgepflicht der [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) und
      [ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/csharp.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer mit kleinen Richtungs-Ordnern, `archGateConfigs()` (Globs, Kommentar), `langArchs()`; Glob-gegen-Pfad-Test; Test-Helfer gemeinsam mit den anderen Sprach-Tests aus `internal/gen/skeleton_helpers_test.go`, kein Klon |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe, Arch-Zähne (`core-impurity`, `port-locality`), Stufen-Kopf, erzeugte Sicht; Berührungspunkt `emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` |
| `spec/architecture.md` | update | Layout je Sprache |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)), Fälle 748 bis 763 auf die kleine Richtung gezogen, dazu ein Fall für den `port-locality`-Lauf-Zahn (neue Nummer); **Prüfauftrag an den Implementer:** Fall 705 `csharp-hexslice-ohne-renderer` (erwartet `TestGenerateArch_CsharpNurFlat`) ist am Quell-Bestand zu messen — bleibt seine Zusage mit dem Renderer wahr (dann Wächter, ggf. Umbenennung auf `csharp-hexagonal-ohne-renderer` wie Fall 690 bei Python), oder ist sie überholt; bei Umbenennung reiner `git mv` zuerst, Inhalt in eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3, [`BEO-ALL/move-und-umschreiben-in-einem-commit`](../observations/BEO-ALL/move-und-umschreiben-in-einem-commit/observation.md)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-csharp-skelett` liegt in `done/` (erfüllt), die ADR für C# ist
`Accepted`, WIP-Slot frei.

**Rückführungen — vorab benennen:**

- `in-progress` → `next`: der Rollen-Renderer verlangt eine Änderung am sprach-agnostischen Seam
  `internal/gen/arch.go` — eigener Schnitt. Nach dem Urteil des Architect ([`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)) **nicht ausgelöst**:
  die kleine Richtung ändert Renderer und C#-Config, nicht den Seam.
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
- Die Schreibweise der Richtungs-Ordner beim Adopter hat keinen Sensor: ein groß geschriebenes
  `Inbound`/`Outbound` bringt den Hinweis zurück und `port-locality` geht für den Port verloren
  ([ADR-0097](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) Festlegung 4; `make gates` bleibt
  grün) — **Ausgang:** bei der Closure; der Renderer ist gehalten (Text-Wächter), die Lücke steht im
  Config-Kommentar und in der Abdeckungs-Zeile; weiter offen heißt Register-Eintrag.
- Die Gegenrichtung zu Messung 5 der [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) (Verzeichnis klein, Namensraum groß) färbt nur, wenn ein
  Adapter den Port importiert; eine Slice ohne Adapter-Import bliebe still (nicht gefahren) —
  **Ausgang:** bei der Closure; als Grenze in der Abdeckungs-Zeile benannt, ungeprüft gelassen.
- Der Lauf der Stufe über Bind-Mount und der CI-Linux-Lauf sind für `port-locality` ungemessen ([`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md)
  Messung 6: Bind-Mount und `docker cp` gleich; CI-Linux nicht) — **Ausgang:** bei der Closure; färbt der
  Lauf-Zahn in CI nicht, gilt Trigger 3 der ADR (Config und Schreibweise zuerst prüfen), sonst *weiter offen*.
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

**Einordnung der Review-Befunde** (`docs/reviews/2026-10-18-slice-csharp-hexslice-layout.md`):
F1 (Config-Kommentar nennt die falsche Ursache) und F2 (`port-locality` ungeprüft) sind Abnahme und stehen
in DoD 1 und 2. F3 (Mutation allein an den Config-Globs nicht gefahren) ist Hinweis, kein DoD-Punkt: der
Implementer fährt sie beim Neumessen von Fall 756 mit und hält das Ergebnis in §7 fest.

## 7. Closure-Notiz

- **Was hat funktioniert:** Nach der Nacharbeit trägt der Slice das Layout mit kleinen Richtungs-Ordnern
  (`Ports/inbound`, `Ports/outbound`, übrige Verzeichnisse und Namensräume PascalCase), `languages: csharp`, `fixed-root` auf
  `src/App`, sieben Kanten einschließlich `driven_adapters → ports_outbound`. Im gebootstrappten Ziel (Probe des Verifiers, nicht Fixture)
  meldet a-check `0 Befund(e)` ohne die zwei Hinweise; `core-impurity` (Fall 761), die Auflösung (762), die Port-Kante (763) und
  `port-locality` (764: zweite Slice nach der Vorschrift des Config-Kommentars, fremder Port-`using` im Handler, `Handler.cs:1`) haben je
  einen Lauf-Zahn, dazu Text-Wächter je Schlüssel (748 bis 760, 765, 766) in derselben Lieferung; der Verifier fuhr 705, 749, 755 bis 758 und
  761 bis 766 rot und las die Ursache. Der Lauf `ci` auf `e1b5fa08` (Linux) ist grün, sein `full-smoke` belegt den `port-locality`-Zahn
  (`port-locality: 1` an `Handler.cs:1`), Stufe 29 s.
- **Was ging anders als geplant:** Der Erst-Stand `3e91174c..6964b9c7` (PascalCase-Richtung nach [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md)
  Festlegung 5) war nach dem Erst-Review (F1 falsche Ursache im Config-Kommentar, F2 `port-locality` ungeprüft) in Teilen neu zu bauen: Die Messung
  des Reviewers am Ziel (a-check zieht das Richtungs-Segment nur kleingeschrieben ab) widerlegte die Layout-Festlegung, der Architect löste drei
  Sätze davon durch [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) ab, der Planner zog die Abnahme nach (Plan-Kopf), Renderer,
  Config, Stufe, Abdeckungs-Zeile und Fälle folgten (`4541d7e9..e1b5fa08`), die Gegenrichtung `ddbee1df`. Nicht in §3 geführt, geliefert (Review und
  Verifier lasen den Diff, zulässig): die Fälle 765 und 766 (Text-Wächter für `inbound` und den Port-Glob, aus
  [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) Festlegung 1 und 2); die Zeile in `README.md`; der geteilte Helfer
  `assertArchConfigResolution` (Python und C#, `dupl`; Fälle 734, 745 und 720 fuhren ohne Zahn-Verlust); `spec/architecture.md` durch den Implementer
  (Rollenfrage `slice-151` offen; [`AGENTS.md`](../../../../AGENTS.md) §3.8 bindet nur Hard Rules und Adaptions-Block); die Pausen `sleep 2` in der
  Stufe.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** Kommando `make full-smoke-host`, macOS/arm64 (Colima), Image warm, Variante
  Mono-Repo mit allen Sprachen und der C#-hexSlice-Stufe. Erst-Stand-Reihe (Message von `61306d52`): Vorher 313 s und 330 s, Nachher 495 s und 318 s,
  Stufe 11 s und 23 s; der 495-s-Lauf lief auf einem durch Mutationsläufe veränderten Cache. Nacharbeits-Reihe (Message von `1765e7aa`, V, N, V, N
  abwechselnd): Gesamt 362, 334, 331, 372 s, Stufe 11, 19, 10, 22 s, davon 6 s Pausen. Verifier (je ein Lauf je Stand): Stufe V 12 s, N 28 s.
  **Belastbar ist allein die Größenordnung der Stufenzeit: rund 10 bis 16 s Zuwachs, davon 6 s Pausen**; die Gesamtdauer rauscht um rund 25 s und trägt
  keinen Zuwachs. CI (Linux, `make full-smoke`): Stufe 29 s, andere Variante und Lage, nicht gleichzusetzen. **Ungemessen:** kalter Cache, Image-Pull.
- **Benannte Grenzen (Review L-1, Verifier L-1, L-2, I-3):** Die Pausen `sleep 2` haben keine Gegenprobe (Beobachtung beim Implementer, vom Reviewer in
  9 Versuchen und vom Verifier nicht reproduziert; Register). Der Zuwachs der Stufenzeit ist je Stand mit einem Lauf gegengemessen (16 s gegen 9 bis
  12 s der Implementer-Reihe). Die Abdeckungs-Zeile sagt „stilles Gruen" für ein Verzeichnis in anderer Schreibweise, der Config-Kommentar nennt
  `wrong-direction`, wo ein Adapter importiert; gemessen ist beides nur für das Richtungs-Segment. `IDE1006`, `CA1707`, `CS8981` stehen in
  [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) als nicht gemessen, nicht in der Zeile. Die Zeile führt „CI-Linux" unter
  NICHT gemessen; für `e1b5fa08` ist der Lauf grün. Die drei Sätze sind ein Implementer-Nachtrag (klein), kein Slice: Die Regel steht in
  [`AGENTS.md`](../../../../AGENTS.md) §3.6, wer die Zeile berührt, zieht sie nach; Beleg `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`.
  Die Rollenfrage `spec/` bleibt bei `slice-151-spec-straten-haben-eine-schreibende-rolle`; Alternative C (a-check-Anforderung) bleibt
  Re-Evaluierungs-Trigger 1 von [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md), kein Slice.
- **Steering-Loop-Eintrag:** geschärfte Regel (Vorschlag, nicht verkörpert): Eine Layout-Festlegung, die Globs oder Schreibweisen eines Fremd-Gates
  trägt, ist an **jedem** Schlüssel des Gates gemessen, den ihre Pfade berühren, bevor sie in der ADR steht, oder führt den ungemessenen Schlüssel
  in der Liste „nicht gemessen". [`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 5 maß die Auflösung,
  nicht `port-locality`; die Lücke fiel erst in der Messung des Erst-Reviews auf und kostete den halben Slice. Neuer Sensor, in derselben Lieferung:
  der Lauf-Zahn 764 hält die Wirkung der Festlegung am Ziel, 765 und 766 halten die Schreibweise im Renderer und in der Config; er hält diese eine
  Festlegung, nicht die Klasse. Ein Sensor auf die Klasse ist nicht baubar (ob eine ADR jeden Schlüssel nennt, ist ein Urteil über Bedeutung);
  Träger ist der Architect beim Annehmen und der Reviewer, der am Ziel misst. Gezählt in der neuen Beobachtung
  `BEO-ALL/adr-festlegung-bindet-gate-schluessel-die-ihre-messung-nicht-trug` (1×, offen); unter der Schwelle, der Lese-Schritt einer späteren
  Closure entscheidet. Zweite Lehre, bestätigt statt neu: der Lauf-Zahn im Ziel in derselben Lieferung wie der Text-Wächter hielt (zum vierten Mal in
  Folge) und die Fälle 761 bis 764 pinnen die Ursache im `# expect:`.
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-csharp-hexslice-layout.md`:
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen` (verkörpert),
  `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert); neu angelegt:
  `BEO-ALL/adr-festlegung-bindet-gate-schluessel-die-ihre-messung-nicht-trug`,
  `BEO-ALL/bind-mount-sicht-auf-umgeschriebene-dateien-ist-unter-macos-verzoegert` (Nachbarn `lokaler-full-smoke-scheitert-auf-macos-host` und
  `gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last` gelesen: anderer Mechanismus, kein Beleg dort),
  `BEO-ALL/csharp-hexslice-adopter-form-ohne-sensor` (je 1×, offen). Kein Beleg, kein Auftreten: `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache`
  (alle neuen `# expect:` pinnen die Ursache, 764 pinnt `port-locality` und `Handler.cs`), `BEO-ALL/move-und-umschreiben-in-einem-commit` (Fall 705:
  reiner `git mv` `50b65502`, Inhalt `fc260961`), `BEO-ALL/neuer-waechter-ohne-mutations-fall` (jeder neue Wächter trägt einen Fall),
  `BEO-ALL/emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache`. **Zitiert ohne Beleg:**
  `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` (verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.6): der Slice hielt die
  Regel für Rolle, Root, Port-Kante und `port-locality` ein; text-gehalten bleiben die übrigen Kanten, `languages`, `exclude` und die Adopter-Form,
  benannt in der Abdeckungs-Zeile wie bei Python. Ob diese Restmenge ein viertes Auftreten ist, steht beim Auftraggeber (Bericht); Gegenrichtung und
  Adopter-Schreibweise haben nur Text- und Doku-Grenze.
- **Folge-Slices:** keine angelegt. `slice-151-spec-straten-haben-eine-schreibende-rolle` — ist eine Datei in `next/` (Rollenfrage, hier nur zitiert).
- **Paarungen (nach dem Move):** Anker-Paarung: kein Eintrag trägt das Feld `liegt in`, nichts zu paaren. Folge-Slice-Paarung:
  `slice-151-spec-straten-haben-eine-schreibende-rolle` ist eine Datei in `next/`. Register-Paarung: jede genannte Beobachtung existiert mit nicht
  leerem `evidence/`; `make register-ausgang` 0 Befund(e).
- **Risiken aus §6:** Risiko 1 (Gegenbeispiel färbt am Ziel nicht rot) entfallen — nicht eingetreten: `core-impurity` am Ziel rot (Fall 761, Probe des
  Verifiers); Risiko 2 (Verzeichnis-Schreibweise ohne Sensor) weiter offen (Register, `BEO-ALL/csharp-hexslice-adopter-form-ohne-sensor`); Risiko 3
  (Schreibweise der Richtungs-Ordner) weiter offen (dasselbe Register-Paar); Risiko 4 (Gegenrichtung nur bei Adapter-Import rot) weiter offen
  (dasselbe); Risiko 5 (Bind-Mount und CI-Linux) entfallen — nicht eingetreten: der Zahn färbt im Lauf `ci` auf `e1b5fa08` (Linux) und im
  `full-smoke-host` über Bind-Mount rot, Trigger 3 der [`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md) nicht ausgelöst; die
  Pausen sind eigener Register-Eintrag (`BEO-ALL/bind-mount-sicht-auf-umgeschriebene-dateien-ist-unter-macos-verzoegert`); Risiko 6 (voll
  qualifizierter Name, `<Using>`, Reflection) weiter offen (Register, `BEO-ALL/csharp-hexslice-adopter-form-ohne-sensor`); Risiko 7 (Kante
  `driven_adapters → ports_outbound`) entfallen — nicht eingetreten: grün im Ziel, rot ohne sie (Fall 763, `wrong-direction`); Risiko 8 (Messzahl)
  entfallen — nicht eingetreten: Zahl im Baum, Verifier gegengemessen (oben); Risiko 9 (grobes `# expect:`) entfallen — nicht eingetreten: 761 bis
  764 pinnen die Ursache, Verifier prüfte; Risiko 10 (Fall 177) entfallen — nicht eingetreten: `make test` grün — je einmal in §6.

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

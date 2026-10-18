# Slice slice-java-hexslice-layout: Java-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp`.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren). [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md)
(Accepted) legt die Layouts
`flat` und `hexslice` fest, Festlegung 4 trägt Pfade und Auflösung.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über die ADR
des Architect).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang java --arch hexslice` rendert die Rollen-Pakete der ADR (Pfade nach
[ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)) samt `.a-check.yml`,
und ein Import aus dem Kern in einen Adapter färbt das emittierte Arch-Gate rot.

**Abhängigkeit:** setzt `slice-java-skelett` voraus (Renderer, Gerüst, Stufe im Mono-Repo); er liegt
in `done/`.

**Vom Layout-Slice zu entscheiden** (Übergabe des ADR-Reviews, L-4; [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md)
Festlegung 4 lässt es offen): die Ports-Ordner und die Kanten-Menge der `.a-check.yml` nach dem
Kotlin-Muster (`internal/gen/kotlin.go`, `internal/gen/arch.go`), einschließlich der Vererbungs-Kante
`driven_adapters → ports_outbound` (`implements` importiert den Port). Diese Kante ist am Java-Fall nicht
gemessen; der Slice misst sie im Ziel (DoD 1).

**Ausdrücklich NICHT in diesem Slice:**

- `flat` und das Java-Gerüst — liefert `slice-java-skelett`; hier nur die Schicht-Achse darüber.
- `hexagonal` — die ADR legt das Layout nicht fest (Re-Evaluierungs-Trigger, Folge-ADR); ohne ADR
  wäre es eine ungetragene Entscheidung.
- Eine Anforderung an a-check — nur, wenn eine Config, die Importe auflöst, grün bleibt
  (Re-Evaluierungs-Trigger der ADR); dann Rückführung.
- Ein Java-Freshness-Werkzeug — anderer Vorgang als das Layout.

## 2. Definition of Done

- [x] hexslice-Renderer mit den Pfaden der ADR Festlegung 4 (`src/main/java/app/hexagon/…`,
      `src/main/java/app/adapters/…`, `Main.java`, Tests unter `src/test/java/app/`), Paket == Verzeichnis;
      `archGateConfigs()` mit `languages: java` und
      `resolution: java: {mode: fixed-root, roots: ["src/main/java/app"], package_base: "app"}`;
      `java` in `langArchs()` führt `hexslice`; Ports-Ordner und Kanten-Menge entschieden, die Kante
      `driven_adapters → ports_outbound` im Ziel grün gesehen (ein Adapter, der den Port `implements`);
      im gebootstrappten Ziel meldet a-check keinen Hinweis „0 von N Import-Symbolen lösen auf" (Probe
      gegen das Ziel, nicht gegen eine Fixture).
- [x] `make full-smoke`: `add-lang java <pfad> --arch hexslice` grün; mit Import aus
      `app.hexagon.domain` nach `app.adapters` rot mit `core-impurity` (Meldung gelesen); Stufe mit
      `e2e_abdeckung`-Kopfzeile, `docs/user/e2e-abdeckung.md` neu erzeugt; Laufzeit-Zuwachs mit
      Image-Lage und Variante ([`MR-089`](../../../../harness/conventions.md#mr-089)). **Die Zahl steht
      bei der Übergabe im Baum:** Kommando `make full-smoke-host`, Lage (Image warm oder kalt), Variante,
      Läufe vorher und nachher stehen in einer Commit-Message des Implementers oder einer Datei des
      Lieferstands; der Verifier hält sie gegen seine eigene Messung. Träger ist der Implementer-Handoff
      (`slice-messzahl-der-dod-liegt-im-lieferstand` entscheidet den dauerhaften Ort; bis dahin gilt diese
      Zeile).
- [x] `spec/architecture.md` Layout je Sprache um Java nachgezogen (Folgepflicht der ADR).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/java.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer, `archGateConfigs()`, `langArchs()` |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe und Arch-Zahn, erzeugte Sicht |
| `spec/architecture.md` | update | Layout je Sprache |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-java-skelett` liegt in `done/`, die ADR für Java ist
`Accepted`, WIP-Slot frei.

**Rückführungen — vorab benennen:**

- `in-progress` → `next`: der Rollen-Renderer verlangt eine Änderung am sprach-agnostischen Seam
  `internal/gen/arch.go` — eigener Schnitt.
- `in-progress` → `open`: eine auflösende Config bleibt grün (Trigger der ADR) — Anforderung an a-check
  über den Auftraggeber.

## 5. Closure-Trigger

DoD vollständig, Arch-Zahn rot und Gegenprobe grün in `make full-smoke`, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Das Gegenbeispiel färbt am gebootstrappten Ziel nicht rot (die ADR hat es nur am Probe-Projekt rot
  gesehen) — **Ausgang:** bei der Closure; zuerst die Config prüfen, Layout sonst aus dem Slice nehmen.
- Ein Paket außerhalb seines Verzeichnisses entgeht der Auflösung — **Ausgang:** bei der Closure;
  Skelett-Test hält Paket == Verzeichnis, Adopter-Fall ist Konsequenz der ADR.
- Die Kante `driven_adapters → ports_outbound` ist am Java-Fall nicht gemessen; die Config färbt einen
  legitimen `implements` rot oder lässt den Port-Import ungeprüft — **Ausgang:** bei der Closure; DoD 1
  verlangt den grünen Fall im Ziel, bei Rot ist die Kanten-Menge zu korrigieren, nicht der Fall zu streichen.
- Ein Wächter, dessen Zusage das Ziel durchsetzt (Config-Text), hat nur den Text-Wächter — **Ausgang:**
  bei der Closure; der Lauf-Zahn im Ziel (rot an `core-impurity`) kommt in derselben Lieferung wie der
  Text-Wächter ([`BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn`](../observations/BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn/observation.md)).

## 7. Closure-Notiz

- **Was hat funktioniert:** Das Kotlin-Muster trug Java als eigenes Layout: Rollen-Renderer
  (`internal/gen/java_hexslice.go`, gemeinsamer `jvmLayout` mit Kotlin), `languages: java`,
  `fixed-root` auf `src/main/java/app`, sieben Kanten einschließlich `driven_adapters → ports_outbound`. Im
  gebootstrappten Ziel meldet a-check `0 Befund(e)` ohne Hinweis auf nicht auflösende Import-Symbole; ein Import
  aus `app.hexagon.domain` nach `app.adapters` färbt `make gates` rot mit `core-impurity` an `Greeting.java:4`,
  die Gegenprobe ist grün. Drei Lauf-Zähne in derselben Lieferung wie die Text-Wächter (Fälle 724 Rolle, 725 Root,
  727 Port-Kante, je rot gesehen); die Lehre aus Python und C# hielt zum dritten Mal in Folge, und der Plan hatte
  sie als Risiko 4 vorab benannt. Die Kante `driven_adapters → ports_outbound` ist im Ziel grün (ein Adapter
  implementiert den Port) und rot ohne sie (`wrong-direction` an zwei Dateien, Handprobe des Verifiers).
- **H-1 behoben (Review, [`AGENTS.md`](../../../../AGENTS.md) §3.3):** Der Umbau des Falls 678 (Rename plus
  Inhalt) lag in einem Commit. Die lokale, ungepushte Historie wurde vor dem Push neu gesetzt; Hash-Zuordnung alt
  → neu: `7142a817` → `7acf530c` (Inhalt), `a6a54283` → `10a752ac` (Stufe), `8350d737` → `9cd94a10`
  (Review-Report); neu: `e01a6d7a` (reiner `git mv`). Beleg: Rename 100 % in `e01a6d7a`, die Inhaltsänderung
  getrennt in `7acf530c`, `git diff backup-vor-h1 HEAD` leer (Baum-Gleichheit, Verifier). Die Berichte unter
  `docs/reviews/` nennen die alten Hashes (Zeitdokumente). Der Zweig `backup-vor-h1` steht noch.
- **Was ging anders als geplant:** Nicht in §3 geführt, geliefert: das Refactoring `jvm.go`/`jvmLayout` mit
  Berührung von `kotlin.go` und `kotlin_test.go` (gemeinsamer Rollen-Renderer statt zweier Switch-Fassungen;
  Review und Verifier lasen den Diff, Kotlin-Fälle 618, 623, 624, 626 gefahren, kein Zahn verloren);
  `skeleton_helpers_test.go`; die Anpassung der Zeile in `README.md`; `spec/architecture.md` durch den
  Implementer (Rollenfrage `slice-151` offen — Review I-4 und Verifier: zulässig, [`AGENTS.md`](../../../../AGENTS.md)
  §3.8 bindet nur Hard Rules und Adaptions-Block). Der Implementer-Nachtrag `7227e9bb` glättet die
  Abdeckungs-Zeile (Review L-2, Verifier V-2).
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** Kommando `make full-smoke-host`,
  macOS/arm64 (Colima), Variante `artifact-host`, Image warm (Images und Build-Cache lagen lokal).
  Implementer (Commit-Message von `10a752ac`): Vorher 228 s und 202 s, Nachher 280 s und 282 s, Stufe 12 s und
  11 s (ein erster Lauf 20 s). Verifier (je ein Lauf): vorher 263 s, nachher 268 s (+5 s), Stufe 11 s.
  **Belastbar ist allein die Stufenzeit von 11 s bis 12 s.** Der Gesamtzuwachs der Handoff-Reihe (52 s bis 80 s)
  ist nicht reproduziert (Verifier V-1); er liegt im Rauschen, 5 s bis 66 s je nach Messreihe (Rauschen rund
  25 s). Die Erklärung des Reviewers (die Stufe `kennungs_form_im_ziel` und zwei `make gates` über das Mono-Repo
  fahren das neue Modul `apps/javahexslice` mit) trägt für wenige Sekunden, nicht für 40 s bis 68 s.
  **Ungemessen:** kalter Cache, Image-Pull; keine Aussage über andere Varianten.
- **Verifier V-1 (MEDIUM, Prozess):** Die Zahl stand diesmal im Baum (Commit-Message), Kommando, Lage und Variante
  eingeschlossen; sie trug trotzdem nicht, weil der Gesamtzuwachs von der Drift zwischen den Messreihen getragen
  war, nicht von der Stufe. Die Zeile in DoD 2 (Verifier hält die Zahl gegen eigene Messung) hat genau das
  aufgedeckt. Kein Beleg zu `BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum`: das Auftreten dort
  (Zahl fehlt bei der Übergabe) trat nicht ein.
- **Benannte Grenzen (Review I-1, L-2, Verifier V-3):** Die Kanten außer `core-impurity` und der Port-Kante
  haben nur den Text-Wächter (Beleg im Register); ein Paket außerhalb seines Verzeichnisses und ein voll
  qualifizierter Name ohne `import` bleiben im Adopter-Code unbeobachtet (Abdeckungs-Zeile nennt beides); Fall 727
  pinnt die Ursache nicht (Handprobe zeigt `wrong-direction`). Pins hält kein Wächter gegen die Registry.
- **Steering-Loop-Eintrag:** geschärfte Regel (Vorschlag, nicht verkörpert): Ein Umbau, der eine Datei
  umbenennt **und** inhaltlich ändert — im Implementer-Lauf etwa der Umbau eines Mutations-Falls, den der Lauf im
  selben Zug anlegt —, geht in zwei Commits, erst der reine `git mv`, dann der Inhalt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.3). Die Regel stand und wurde trotzdem gebrochen; ihr Sensor
  (`make full-smoke`) hält den Zuschnitt allein für `make slice-mv`, ein Sensor auf `git log -M --name-status`
  über einer Range wäre baubar, ist nicht gebaut. Gezählt in der neuen Beobachtung
  `BEO-ALL/move-und-umschreiben-in-einem-commit` (1×, offen); unter der Schwelle, der Lese-Schritt einer späteren
  Closure entscheidet. Zweite Lehre, bestätigt statt neu: der Lauf-Zahn im Ziel in derselben Lieferung wie der
  Text-Wächter hielt (Python-Lehre, zum dritten Mal in Folge); die Gegenrichtung
  `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` bleibt für die übrigen Kanten offen.
- **Folge-Arbeit aus Review und Verifier:**
  - L-1 (`docs/user/benutzerhandbuch.md:328` nennt hexslice-Sprachen ohne `java`; `java` kommt im Handbuch nirgends
    vor, öffentlicher Vertrag, [`AGENTS.md`](../../../../AGENTS.md) §6 Schritt 7): Out-of-Scope dieses Slice. Kein
    offener Slice trägt die Lücke (`slice-releasing-zieht-nach-docs-maintainer` betrifft das Release, nicht das
    Handbuch); Beleg zu `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke` (2×, offen). Der Nachzug fällt mit
    dem nächsten Release-Schnitt (Handbuch im Ist-Zustand) zusammen, der auch Python und C# ins Handbuch holt;
    ein Slice dafür ist nicht angelegt — die Entscheidung liegt beim Auftraggeber.
  - V-3 (Fall 727 pinnt die Ursache nicht): Beleg zur neuen Beobachtung
    `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache` (1×); `slice-mutations-faelle-ueber-full-smoke-faerben-am-erwarteten-grund`
    deckt Fälle mit früher fallender Stufe, nicht ein grobes `# expect:`.
  - Die Kotlin-Stufe in `harness/tools/full-smoke.sh` führt „Paket gleich Verzeichnis" weiter unter Gemessenem,
    obwohl sie nur Import-Auflösung prüft (gleiche Klasse wie L-2): Beleg zu
    `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert in [`AGENTS.md`](../../../../AGENTS.md)
    §3.6). Kein Slice: die Regel ist verkörpert, der Bestand ist kein Arbeitsauftrag; wer die Kotlin-Stufe berührt,
    zieht die Zeile nach.
  - Die vom Implementer vorgeschlagene Beobachtung zur Datei-Trennung `jvm.go` (`dupl`-Folge) entfällt: kein
    Defekt und kein Wächter dahinter (Review I-5).
- **Nicht geplante Lieferungen:** Anpassung der Zeile in `README.md`; Refactoring `jvm.go`/`jvmLayout` mit
  Kotlin-Berührung; `spec/architecture.md` durch den Implementer. Alle drei gelesen, zulässig (Review, Verifier).
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-java-hexslice-layout.md`:
  `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` (2×, offen),
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen` (verkörpert),
  `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert),
  `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke` (2×, offen); neu angelegt:
  `BEO-ALL/move-und-umschreiben-in-einem-commit`, `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache`,
  `BEO-ALL/jvm-paket-ausserhalb-seines-verzeichnisses-entgeht-der-aufloesung` (je 1×, offen). Kein Beleg für
  `BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` (kein Auftreten, oben).
- **Folge-Slices:** `slice-messzahl-der-dod-liegt-im-lieferstand` — ist eine Datei in `open/` (Ausgang des
  Register-Eintrags zur Messzahl, hier nur zitiert).
- **Paarungen (nach dem Move):** Anker-Paarung: kein Eintrag trägt das Feld `liegt in`, nichts zu paaren.
  Folge-Slice-Paarung: `slice-messzahl-der-dod-liegt-im-lieferstand` ist eine Datei in `open/`. Register-Paarung:
  jede genannte Beobachtung existiert mit nicht leerem `evidence/`; `make register-ausgang` 0 Befund(e).
- **Risiken aus §6:** Risiko 1 (Gegenbeispiel färbt am Ziel nicht rot) entfallen — nicht eingetreten:
  `core-impurity` am Ziel rot gesehen (`Greeting.java:4`), Gegenprobe grün, Fälle 724 und 725; Risiko 2 (Paket
  außerhalb seines Verzeichnisses) weiter offen (Register, `BEO-ALL/jvm-paket-ausserhalb-seines-verzeichnisses-entgeht-der-aufloesung`);
  Risiko 3 (Kante `driven_adapters → ports_outbound`) entfallen — nicht eingetreten: grün im Ziel gesehen, rot ohne sie
  (`wrong-direction`, Fall 727 und Handprobe); Risiko 4 (Wächter nur mit Text) entfallen — nicht eingetreten:
  Lauf-Zähne 724, 725, 727 in derselben Lieferung — je einmal in §6.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Layout liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-18):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der a-check-Pin besteht schon ·
`waechter-misst-die-fixture-statt-der-realen-quelle` — 10, geplant; die Probe läuft gegen das Ziel, nicht
gegen eine Fixture ·
`strukturtest-sieht-den-import-alias-nicht` — 2, offen; der Paket-Test des Skeletts ist davon berührt ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die Stufe erbt es ·
`waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` — 1, offen; der Arch-Zahn im Ziel ist
sein Lauf-Zahn (ein zweiter Beleg hier würde ihn auf 2× heben) ·
`messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` — 3, geplant (`slice-messzahl-der-dod-liegt-im-lieferstand`);
die Messzahl-Zeile in DoD 2 trägt es bis dahin ·
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` — 7, verkörpert; der Kaltlauf bleibt ungemessen.

**Modus:** alle berührten Sub-Areas GF.

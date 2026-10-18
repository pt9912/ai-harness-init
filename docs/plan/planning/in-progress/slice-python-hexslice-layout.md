# Slice slice-python-hexslice-layout: Python-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp`.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren). [`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md)
(Accepted) legt die Layouts `flat` und `hexslice` fest, Festlegung 5 trägt Pfade und Auflösung.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über die ADR
des Architect).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang python --arch hexslice` rendert die Rollen-Pakete der ADR (Pfade nach
[ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)) samt `.a-check.yml`,
und ein Import aus dem Kern in einen Adapter färbt das emittierte Arch-Gate rot.

**Abhängigkeit:** setzt `slice-python-skelett` voraus (Renderer, Gerüst, Stufe im Mono-Repo); er liegt
in `done/`.

**Vom Layout-Slice zu entscheiden** ([ADR-0095](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md)
Festlegung 5 lässt es offen): die Ports-Ordner und die Kanten-Menge der `.a-check.yml` nach dem Muster
von `internal/gen/kotlin.go`, `internal/gen/arch.go` und
[`slice-java-hexslice-layout`](../done/slice-java-hexslice-layout.md) (sieben Kanten einschließlich
`driven_adapters → ports_outbound`, im Ziel gemessen, nicht an der Vier-Schichten-Probe).

**Ausdrücklich NICHT in diesem Slice:**

- `flat` und das Python-Gerüst — liefert `slice-python-skelett`; hier nur die Schicht-Achse darüber.
- `hexagonal` — die ADR legt das Layout nicht fest (Re-Evaluierungs-Trigger, Folge-ADR); ohne ADR
  wäre es eine ungetragene Entscheidung.
- Eine Anforderung an a-check — nur, wenn eine Config, die Importe auflöst, grün bleibt
  (Re-Evaluierungs-Trigger der ADR); dann Rückführung.
- `app-impurity` und `wrong-direction` als rote Fälle — die ADR hat sie nicht gefahren; die Stufe
  misst `core-impurity` (und, soweit billig, `lateral-adapter`), die übrigen bleiben Zusage.
- Ein Python-Freshness-Werkzeug — anderer Vorgang als das Layout.

## 2. Definition of Done

- [x] hexslice-Renderer mit den Pfaden der ADR Festlegung 5 (`src/app/hexagon/{domain,application}/…`,
      `src/app/adapters/{driving,driven}/…`, Composition Root `src/app/main.py`, Tests unter `tests/`);
      `archGateConfigs()` mit `languages: python: ["**/*.py"]`, `exclude: ["tests/**"]` und
      `resolution: python: {mode: fixed-root, roots: ["src/app"], package_base: "app"}`; `python` in
      `langArchs()` führt `hexslice`; **Entscheidung von Ports-Ordnern und Kanten-Menge** ([ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
      Festlegung 4, Java-Muster) im Plan §7 und im Test festgehalten; die Kante
      `driven_adapters → ports_outbound` im Ziel grün gesehen (ein Adapter, der den Port importiert);
      im gebootstrappten Ziel meldet a-check keinen Hinweis „0 von N Import-Symbolen lösen auf" (Probe
      gegen das Ziel, nicht gegen eine Fixture). **Je Config-Schlüssel ein Text-Wächter, und der
      Lauf-Zahn im Ziel (rot an `core-impurity`) kommt in derselben Lieferung** (Fälle ab 731;
      [`BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn`](../observations/BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn/observation.md)).
- [x] `make full-smoke`: `add-lang python <pfad> --arch hexslice` grün; mit Import aus
      `app.hexagon.domain` nach `app.adapters` rot mit `core-impurity` (Meldung gelesen), Gegenprobe
      grün; Stufe mit `e2e_abdeckung`-Kopfzeile, `docs/user/e2e-abdeckung.md` neu erzeugt; jeder neue
      Full-Smoke-Fall pinnt die Ursache im `# expect:` (nicht nur „rot").
      **Laufzeit-Zuwachs ([`MR-089`](../../../../harness/conventions.md#mr-089)); die Zahl steht bei der
      Übergabe im Baum:** Kommando `make full-smoke-host`, Lage (Image warm oder kalt), Variante, mindestens
      zwei Läufe je Stand (vorher/nachher) stehen in einer Commit-Message des Implementers oder einer Datei
      des Lieferstands. Belastbar ist die Stufenzeit; die Gesamtdauer rauscht um bis zu rund 25 s und trägt
      keinen Zuwachs allein. Der Verifier hält die Zahl gegen seine eigene Messung
      (`slice-messzahl-der-dod-liegt-im-lieferstand`
      entscheidet den dauerhaften Ort; bis dahin gilt diese Zeile).
- [x] `spec/architecture.md` Layout je Sprache um Python nachgezogen (Folgepflicht der ADR).
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
| `internal/gen/python.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer, `archGateConfigs()`, `langArchs()`; Test-Helfer gemeinsam mit den anderen Sprach-Tests, kein Klon |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe und Arch-Zahn, erzeugte Sicht; Berührungspunkt `emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` |
| `spec/architecture.md` | update | Layout je Sprache |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)), neue Nummern ab 731; Fall 690 `python-hexslice-ohne-renderer` wird mit dem Renderer gegenstandslos und per reinem `git mv` auf `python-hexagonal-ohne-renderer` umbenannt, **die Inhaltsänderung danach in einem eigenen Commit** ([`AGENTS.md`](../../../../AGENTS.md) §3.3, [`BEO-ALL/move-und-umschreiben-in-einem-commit`](../observations/BEO-ALL/move-und-umschreiben-in-einem-commit/observation.md)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-python-skelett` liegt in `done/` (erfüllt), die ADR für Python ist
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
  gesehen, die Vier-Schichten-Probe trägt nicht das volle Skelett) — **Ausgang:** bei der Closure;
  zuerst die Config prüfen, Layout sonst aus dem Slice nehmen.
- Ein relativer Import entgeht a-check (Hinweis „nicht extrahiert", Exit 0) und ist nur über ruff
  `TID252` geschlossen — **Ausgang:** bei der Closure; ob `TID252` am gebootstrappten Ziel `lint` rot
  färbt, ist dort zu sehen (Skelett-Slice trägt die Regel, dieser Slice das Layout).
- Die Messzahl steht bei der Übergabe nicht im Baum oder trägt nur über das Rauschen der Gesamtdauer
  (Java: Gesamtzuwachs nicht reproduziert) — **Ausgang:** bei der Closure; DoD 2 nennt Kommando, Lage,
  Variante und Läufe, der Verifier misst gegen.
- Ein Umbau von Fall 690 (Rename plus Inhalt) liegt in einem Commit — **Ausgang:** bei der Closure;
  zwei Commits, der Move zuerst, Plan §3.
- Ein neuer Full-Smoke-Fall färbt an der falschen Ursache rot (grobes `# expect:`) — **Ausgang:** bei der
  Closure; das `# expect:` pinnt die Ursache, der Verifier prüft per Handprobe.
- Voll qualifizierter Name ohne Import und dynamischer Import entgehen dem Arch-Gate (Grenze von
  a-check am Pin) — **Ausgang:** bei der Closure; Grenze in der Abdeckungs-Zeile der Stufe benannt.

## 7. Closure-Notiz

- **Was hat funktioniert:** Das Java-Muster trug Python ohne Umbau am Seam: Rollen-Renderer
  (`internal/gen/python_hexslice.go`), `languages: python`, `fixed-root` auf `src/app` mit `package_base: app`, sieben
  Kanten einschließlich `driven_adapters → ports_outbound`, `exclude: tests/**`. Im gebootstrappten Ziel meldet
  a-check `0 Befund(e)` ohne Hinweis auf nicht auflösende Import-Symbole; ein Import aus `app.hexagon.domain` nach
  `app.adapters` färbt `make gates` rot mit `core-impurity` an `greeting.py:3`, die Gegenprobe ist grün. Drei
  Lauf-Zähne in derselben Lieferung wie die Text-Wächter (Fälle 739 Rolle, 740 Resolution, 742 Port-Kante); die
  Kante `driven_adapters → ports_outbound` ist grün (ein Adapter erbt und importiert den Port) und rot ohne sie
  (`wrong-direction` an `in_memory_repository.py:4`, Handprobe des Verifiers). Die Lehren aus Java hielten:
  Rename und Inhalt von Fall 690 in zwei Commits (`c069e697` reiner `git mv`, R100; `67f93340` Inhalt; Verifier
  `git log -M --name-status`), die Messzahl stand im Baum (Commit-Message `a4fc68be`).
- **Was ging anders als geplant:** Nicht in §3 geführt, geliefert: die Anpassung der Zeile in `README.md`;
  `spec/architecture.md` durch den Implementer (Review I-4 und Verifier: zulässig, [`AGENTS.md`](../../../../AGENTS.md)
  §3.8 bindet nur Hard Rules und Adaptions-Block); die geteilten Helfer `archConfigResolution` und die
  Ausnahme-Funktion in `assertGlobsMatchSkeleton` mit Berührung der Java-Tests (Verhalten unverändert, Java-Fälle 720
  und 723 vom Verifier gefahren, kein Zahn verloren); die Endform von Fall 690 (siehe Lerneintrag); der
  Korrektur-Commit `b37cdf0c` (die `einordnen`-Zählung in `test/full-smoke-ausgang.bats`, Fall 177: eine Stufe, die
  `einordnen` aufruft, ändert die Zählgleichung). Der Review (0 HIGH, 0 MEDIUM, 2 LOW, 5 INFO) wurde in `244254bb`
  (L-1, L-2: Kommentare zu den Paket-Markern auf die gemessene Lage — mypy verlangt nur den Wurzel-Marker, ein
  Marker-Import in eine Schicht fällt als `wrong-direction`) und `ceca3bc8` (I-2, Fall 742) behoben; der Verifier
  hat beide Korrekturen am Ziel real nachgefahren.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** Kommando `make full-smoke-host`,
  macOS/arm64 (Colima), Variante `artifact-host`, Image warm. Implementer (Commit-Message von `a4fc68be`, je zwei
  Läufe): Vorher 313 s und 311 s, Nachher 330 s und 341 s (Zuwachs 17 s bis 30 s), Stufe Python-hexSlice 9 s und 9 s,
  Python-flat 7 s und 8 s gegen 10 s und 9 s. Verifier (je ein Lauf je Stand): Stufe Python-hexSlice 9 s, Python-flat
  7 s nachher und 8 s vorher; die Gesamtdauer hat er nicht gemessen (V-2). **Belastbar ist allein die Stufenzeit von
  9 s.** Der Gesamtzuwachs der Handoff-Reihe liegt im Rauschen von rund 25 s und ist weder gestützt noch widerlegt;
  was über die Stufenzeit hinausgeht, ist nicht erklärt. **Ungemessen:** kalter Cache, Image-Pull; keine Aussage
  über andere Varianten.
- **Benannte Grenzen (Review I-1, L-2, Verifier V-3):** Die Kanten außer `core-impurity` und der Port-Kante haben nur
  den Text-Wächter; die Abdeckungs-Zeile nennt die übrigen Richtungs-Regeln, den relativen Import, den voll
  qualifizierten Namen, den dynamischen Import und den Marker-Import mit schichtlosem oder nicht auflösendem Ziel
  unter NICHT gemessen. Der Hinweis „6 gescannte Datei(en) liegen in keiner Schicht" (leere `__init__.py`) steht bei
  jedem a-check-Lauf des Ziels; er folgt aus `exclude: tests/**` nach [`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md)
  Festlegung 4 und ist kein Defekt (Review INFO-1, Verifier V-3). Ob die Marker in `exclude` gehören, ist eine
  Config-Entscheidung des Architect, kein Gegenstand dieses Slice. Pins hält kein Wächter gegen die Registry.
- **Verifier V-1 (INFO):** Plan §3 trug „Fall 690 wird gegenstandslos"; gebaut ist die Endform des Falls als Wächter
  für `hexagonal` ohne Renderer (Anker `"python": {archFlat, archHexslice},` in `internal/gen/gen.go`). §3 bleibt
  stehen; die Annahme ist hier widerlegt.
- **Steering-Loop-Eintrag:** geschärfte Regel (Vorschlag, nicht verkörpert): Eine Annahme des Plans über den Wegfall
  eines Wächters (hier „Fall 690 wird gegenstandslos") steht im Plan als **Prüfauftrag an den Implementer** und nicht
  als Tatsache; der Fall bleibt Wächter, bis seine Zusage am Quell-Bestand als überholt gemessen ist. Hier trug die
  Formulierung „wird mit dem Renderer gegenstandslos" die Annahme in den Plan, der Implementer widerlegte sie am
  Fall und hielt ihn als Wächter für die verbleibende Zusage (`hexagonal` bleibt Exit 2); ein Sensor dafür ist nicht
  gebaut, Träger ist der Planner beim Schnitt. Zweite Lehre, gezählt: das `# expect:` des Falls 742 pinnte die
  Ursache nicht, trotz der Zusage in §6 Risiko 5 und DoD 2; erst der Review fand es (I-2). Beleg zu
  `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache` (2×, offen, Java 727 und Python 742); unter der Schwelle,
  der Lese-Schritt einer späteren Closure entscheidet. Bestätigt statt neu: der Lauf-Zahn im Ziel in derselben
  Lieferung wie der Text-Wächter (vierte Sprache in Folge), die Messzahl im Baum und die Trennung von Rename und
  Inhalt.
- **Nicht gezählt, Entscheidung des Auftraggebers:** Die Kanten außer `core-impurity` und der Port-Kante tragen in
  Python wie in Java und C# nur den Text-Wächter; das ist dasselbe Auftreten wie `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn`
  (2×) und wäre sein drittes. Der Beleg `evidence/slice-python-hexslice-layout.md` ist **nicht** angelegt: ab 3× verlangt
  der Lese-Schritt einen Ausgang (*verkörpert*, *geplant* oder *gestrichen*), und den weist der Auftraggeber zu —
  die Eintragung ist offen und im Bericht an ihn benannt.
- **Folge-Arbeit:** Der relative Import am hexslice-Ziel ist nicht gefahren (Risiko 2, unten); der Beleg steht in der
  neuen Beobachtung. `exclude` für die leeren Marker: Architect, kein Slice, kein Register-Eintrag (kein Defekt, kein
  Wiederauftreten).
- **Nicht geplante Lieferungen:** `README.md`-Zeile, `spec/architecture.md`, die geteilten Helfer mit Java-Berührung,
  Endform von Fall 690, Korrektur-Commit `b37cdf0c`. Alle gelesen, zulässig (Review, Verifier).
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-python-hexslice-layout.md`:
  `BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache` (2×, offen),
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen` (verkörpert); neu angelegt:
  `BEO-ALL/relativer-import-am-hexslice-ziel-ungefahren` (1×, offen). Kein Beleg für
  `BEO-ALL/move-und-umschreiben-in-einem-commit` (zwei Commits, kein Auftreten) und
  `BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` (die Zahl stand im Baum). Offen bis zur
  Entscheidung: `BEO-ALL/waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` (oben).
- **Folge-Slices:** keiner angelegt; `slice-csharp-hexslice-layout` bleibt in `open/` (Priorisierung beim
  Auftraggeber).
- **Paarungen (nach dem Move):** wird nach dem Move eingetragen.
- **Risiken aus §6:** Risiko 1 (Gegenbeispiel färbt am Ziel nicht rot) entfallen — nicht eingetreten:
  `core-impurity` am Ziel rot gesehen (`greeting.py:3`), Gegenprobe grün, Fälle 739 und 740; Risiko 2 (relativer
  Import entgeht a-check, nur `TID252`) weiter offen (Register, `BEO-ALL/relativer-import-am-hexslice-ziel-ungefahren`):
  die lint-Stage des flachen Python-Ziels färbt ihn rot ([`slice-python-skelett`](../done/slice-python-skelett.md)), am hexslice-Ziel
  ist er nicht gefahren; Risiko 3 (Messzahl nicht im Baum oder nur im Rauschen) entfallen — nicht eingetreten: die
  Zahl steht in `a4fc68be` mit Kommando, Lage und Variante, der Verifier hat die Stufenzeit gegengemessen; Risiko 4
  (Fall 690 Rename plus Inhalt in einem Commit) entfallen — nicht eingetreten: `c069e697` und `67f93340`;
  Risiko 5 (grobes `# expect:`) entfallen — eingetreten und im Slice behoben, nichts bleibt offen: Fall 742 pinnte die Ursache nicht (Review I-2), `ceca3bc8`
  pinnt `wrong-direction driven_adapters -> ports_outbound`, vom Verifier real rot gelesen; Beleg im Register, kein
  Folge-Slice nötig; Risiko 6 (qualifizierter Name, dynamischer Import) entfallen — nicht eingetreten als Defekt, die
  Grenze ist in der Abdeckungs-Zeile der Stufe benannt — je einmal in §6.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Layout liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-18):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der a-check-Pin besteht schon ·
`waechter-misst-die-fixture-statt-der-realen-quelle` — 10, verkörpert; die Probe läuft gegen das Ziel,
nicht gegen eine Fixture ·
`strukturtest-sieht-den-import-alias-nicht` — 2, offen; Python-Import-Formen (Alias, relativ) sind
davon berührt ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die Stufe erbt es ·
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` — 1, offen; die Stufe
fährt den Mono-Repo-Pfad, ein Fund am gemischten Root wäre der zweite Beleg ·
`waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` — 2, offen; Lauf-Zahn im Ziel in derselben
Lieferung (DoD 1) ·
`move-und-umschreiben-in-einem-commit` — 1, offen; Fall 690 (§3) ·
`full-smoke-fall-expect-pinnt-nicht-die-ursache` — 1, offen; DoD 2.

**Modus:** alle berührten Sub-Areas GF.

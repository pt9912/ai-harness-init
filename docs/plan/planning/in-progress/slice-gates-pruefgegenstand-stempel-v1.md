# Slice slice-gates-pruefgegenstand-stempel-v1: Je-Check-Prüfgegenstand-Stempel für den Fast-Pfad (Tier 2)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle ([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst):
der Baseline-Test ist das *Mehr* — eine beobachtbare Closure-Bedingung, die mehr
beobachtet als die DoD dieses Slice; es gibt keine, der Closure-Trigger unten
wäre die Abschrift der eigenen DoD). Wellenlose Arbeit erscheint nicht in der
Roadmap (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der SKIP behauptet kein Verdikt, das der Schlüssel nicht deckt — das
Zulässigkeits-Kriterium, [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 2),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(dieselbe Eingabe, dasselbe Verdikt — die Invariante des Beleg-Übersprungs),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(der Key entsteht aus dem, was der Host ohnehin trägt),
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(Form-Präzedenz: Beleg statt Lauf, Prüfgegenstand-Bezugsmenge, benannter Rest, fail-closed),
[ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
(der Tier-1-Fast-Pfad, den dieser Slice je Check verfeinert),
[ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(der Stempelvertrag des Stop-Hooks),
[ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(die Hash-Ausnahme `.harness/stamp/**` — Record-Konsum rotiert nichts),
[`MR-050`](../../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
(das Deckungs-Kriterium),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der neuen Mutations-Fälle).

**Berührte Spec-Stellen:** `spec/architecture.md` §5 — die Ordnungskante
(`record-gates:` über die Check-Liste und der Fast-Pfad `gates` über den
Stempel). Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** pt9912
<!-- BEDIENHINWEIS: Verantwortlich hält die Arbeit — der Rolleninhaber der
Implementer-Rolle, gesetzt beim Übergang open→next (Baseline-Regelwerk
modul-05-planning-harness.md §Lifecycle als State Machine). Der Autor schrieb
den Plan; zwei Felder, zwei Fragen. Kein Statuswert: der Zustand bleibt das
Verzeichnis. Kein Sensor prüft das Feld — es ist Deklaration.
Paralleler Lauf — ein WIP-Slot, ein Zweig, ein `git worktree`: Das WIP-Limit
zählt pro Lauf. Hält ein Mensch mehrere Implementer-Läufe parallel, trägt das
Feld ab next→in-progress Person und Zweig — `<Name> (Zweig <branch-name>)` —,
und jeder Lauf arbeitet in seinem eigenen Arbeitsbaum (`git worktree` oder ein
weiterer Klon), nie zwei Läufe in derselben Arbeitskopie. Ein Slice gehört
einem Implementer-Lauf. -->

**Autor:** pt9912. **Datum:** 2026-11-26.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make gates` urteilt je Check statt über den ganzen Arbeitsbaum:
je Check der Ordnungskante ein Prüfgegenstand-Schlüssel (Inhalt-Hash über
seine Bezugsmenge, [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegungen 2/3-Form) und ein Grün-Stempel an genau einer Stempel-Ablage; der
Fast-Pfad ([ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md), Tier 2)
fährt bei Teildrift nur die Checks, deren Schlüssel seit dem letzten grünen
Lauf driftete, und SKIPpt über dem vollständig gedeckten Satz — bei jedem
Zweifel der volle Lauf über `make record-gates` (fail-closed).

**Übernimmt:** `slice-environment-check-fuehrt-die-gates` — den je-Check-Key
für `environment-check` samt seiner Tafel-Menge: das Check-Skript
`harness/tools/environment-check.sh`, das Inventar
`harness/tools/environment-inventory.txt` und die `SPEC-099`-Zeile
(`spec/spezifikation.md`) als eigene Check-Zeile der Prüfgegenstand-Tafel
(§3) und des Schlüssel-Satzerzeugers. Bis diese Zeile steht, fährt der Check
stets voll — fail-closed, kein verwertbarer Schlüssel (Festlegung 4-Form, deklariert
am Makefile-Kommentar der Kante); der Tier-2-Schlüssel-Rückenstand des
Vorgänger-Slices ist kein Defekt, sondern die Nehmer-Seite dieses Plans, und
löst sich erst hier, nicht mit dessen Lieferung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Mutations-Treiber bleibt, wie er ist** — sein Beleg-Slot und sein
  SKIP sind von seiner eigenen Ablage getragen (Festlegung 5 je [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)), nicht
  von dieser Stempel-Ablage; das wäre ein anderer Vorgang. Ob die Festlegungen
  1/2/4 als allgemeine Regel taugen, prüft Re-Evaluierungs-Trigger 3 von
  [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md);
  der Architektur-Zug (Start-Trigger §4) beantwortet ihn für diesen
  Fast-Pfad — der Treiber selbst wird hier nicht angefasst.
- **Die emittierten Ziel-Vorlagen bekommen das je-Check-Konzept nicht** —
  der emittierte Baum trägt den Tier-1-Fast-Pfad als Konzept schon nicht
  (`grep -rl 'gates-fast' internal/emit/` → **0**; kein Erwartungswert,
  die 0 hängt daran, dass kein Treffer besteht); ein Adopter-Target hat weder
  Tier-1 noch Tier-2. Bestand bleibt bewusst stehen; die Grenze ist dieselbe,
  die [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
  Festlegung 4 für den Hash-Skript benannt hat.
- **Kein zweiter Träger des Handoff-Gate-Zustands** — die HEAD-Kante bleibt
  in der Fassung von [ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md);
  die je-Check-Keys treten als Block-Kriterium *daneben* in derselben
  `.harness/state/`-Klasse; ein zweiter Mechanismus daneben entsteht nicht
  (Abgrenzung [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
  Konsequenzen).
- **Kein neues Make-Target neben der Kante** — jeder Check bleibt an
  `record-gates: <Checks>` verdrahtet (Zusage 3 von
  `test/gate-nachweis-kante.bats`); der je-Check-Stempel-Schreiber wird vom
  vollen Lauf getragen, der SKIP-Anteil bleibt Wrapper
  ([ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Festlegung 1-Form:
  Schreiber bleibt `record-gates`).

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** je Check sein Prüfgegenstand — der
      Schlüssel-Satzerzeuger trägt je Check der Kante eine deklarierte
      Bezugsmenge an **einer** Definition ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
      Festlegung 3), je Check eine Grün-Stempel-Ablage mit dem Inhalt-Key, und
      die [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)-Ausnahme
      gilt auf dieser einen Definition; die Deckung ist je Check **gezeigt**
      (Mengen-Messung gegen den im Lauf gelesenen Bestand), nicht angenommen —
      Messrezept je Check im Kopf des Satzerzeugers. Ein Check ohne
      verwertbare Definition fährt voll (fail-closed,
      [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
- [x] **Liefer-Punkt 2:** `make gates` fährt nur die gedrifteten Checks —
      SKIP nur über dem vollständig gedeckten je-Check-Satz, Teildrift fährt
      genau die gedrifteten Checks und schreibt nur deren Stempel;
      `GATES_FORCE=1` bleibt Träger des benannten Rests, die SKIP-Meldung
      nennt ihn ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
      Festlegung 4). CI läuft unverändert voll — kein Stempel-Konzept auf CI,
      alle Keys unformal → alle Checks gedriftet (dasselbe Verhältnis wie
      Tier-1, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [x] **Liefer-Punkt 3:** der Stop-Hook blockt über der Mischform — HEAD-Kante
      unverändert ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)),
      die je-Check-Keys als Deckungs-Kriterium daneben; unlesbarer oder
      fehlender Stempel blockt (fail-closed). Wächter- und Mutations-Bestand
      ziehen nach: `test/gate-nachweis-kante.bats`, `test/gates-fastpfad.bats`
      und die Fälle 212/213/214/637 auf die je-Check-Form; neu die zwei
      Fälle der §3-Liste (drifteter Check läuft, ungedrifteter behält den
      Stempel byte-gleich · Record-only-Commit rotiert nichts).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die Zeile `make gates` in [`harness/README.md`](../../../../harness/README.md)
      und [`harness/sensors/gates.md`](../../../../harness/sensors/gates.md)
      §Vertrag nennt die Tier-2-Form der Tafel (Titel „make gates —
      Fast-Pfad je-Check-Satz (Tier 2)"; der Anker „§Fast-Pfad" nennt keine
      Überschrift, die Form steht im Titel und in §Vertrag) — öffentlicher
      Vertrag berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind hier geprüft
      — Repo ohne Wellen-Betrieb, nach dem `git mv`.

## 3. Plan (vor Code)

**Design-Festlegungen** (je eine mit Begründung):

1. **Je Check sein Prüfgegenstand** — die Tafel unten trägt je Check die
   Bezugsmenge und die Begründung, warum genau diese (nicht größer, nicht
   kleiner). Die Deckung je Check wird **gezeigt** ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 2, Beweisrichtung): Mengen-Messung (Comm) der deklarierten
   Definition gegen den Bestand, den der Lauf im Ziel tatsächlich liest;
   ohne Messung ist der Default *kein Übersprung* — der Check fährt voll.
2. **Stempel-Form: je Check ein Key-Stempel** — je Check eine Stempel-Datei
   unter `.harness/state/`, deren Eintrag der **Inhalt-Hash seiner
   Prüfgegenstand-Menge** ist, geschrieben an genau einer Stelle
   ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 3: eine Definition, zwei gibt es nicht); die Gesamt-Dateien
   ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md))
   bleiben in Bestand und Lesern — die je-Check-Keys treten als
   Vergleichsgröße *daneben* in derselben `.harness/state/`-Klasse.
   Die [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)-Ausnahme
   (`.harness/stamp/**`) gilt auf der einen Definition — **Record-Konsum
   rotiert nichts**, die Ausnahme wächst nicht zu einer zweiten.
3. **Die Kante bleibt, der Skip wird fein** — `record-gates: <Checks>` bleibt
   in Bestand, Reihenfolge und Wächter unverändert (Zusagen 1–5 von
   `test/gate-nachweis-kante.bats`); `make gates` (Fast-Pfad) SKIPpt nur über
   dem vollständig gedeckten je-Check-Satz und fährt bei Teildrift genau die
   gedrifteten Checks; **der volle Lauf bleibt**: jeder Unform, ein fehlender
   oder nicht zeigbar deckbarer Check, `GATES_FORCE=1` → voller Lauf über
   `make record-gates` (fail-closed). CI läuft unverändert voll — kein
   Stempel-Konzept auf CI.
4. **Der benannte Rest bleibt der Rest je [ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)** — der lokale Docker-Cache-
   Zustand und die Host-Werkzeuge stehen außerhalb jedes baum-abgeleiteten
   Schlüssels ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 4; [ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
   Festlegung 2); je-Check-Betroffenheit: alle Image-fahrenden Checks
   (`lint`, `build`, `test`, `host-bin` — die Image-Digests stehen in
   getrackten Dateien und sind transitiv im Key, der Cache-*Zustand* ist
   keine Adresse [`MR-050`](../../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)),
   ebenso die übrigen über Host-Werkzeuge. Träger bleibt `GATES_FORCE=1`
   samt Meldung; auf der je-Check-Ebene nennt jede SKIP-Meldung den Rest.
5. **Stop-Hook: Mischform** — die HEAD-Kante bleibt unverändert
   ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md));
   die Block-Bedingung erweitert sich um die je-Check-Deckung: der Hook liest
   alle Check-Stempel und vergleicht je Prüfgegenstand-Hash gegen den
   Satzerzeuger; ein nicht deckender Check blockt. Fail-closed in beide
   Richtungen: fehlender oder unformaler Stempel und Satzerzeuger-Fehler
   blocken, statt freizugeben ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
6. **Mutations-Bestand zieht nach, zwei Fälle kommen** — die Fälle
   212 (Wrapper-Verdrahtung), 213 (Kanten-Liste), 214 (baseline-verify
   als erster), 637 (`MUTATE_CASES`-Verbot) greifen weiter, weil die Kante
   unverändert bleibt; ihre Anker werden gegen den Quell-Bestand erneut
   gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
   Je neu: (a) *drifted-Check läuft, ungeändert-Check fährt keinen Lauf und
   behält seinen Stempel byte-gleich*; (b) *Record-only-Commit fährt nichts —
   ein Commit, der allein `.harness/stamp/mutate/` bewegt, rotiert keinen
   je-Check-Key und keinen* (die engere Menge je
   [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
   Festlegung 2; der Vertrags-Rest → §6); beide Anlage-Formen nach
   [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit),
   gemessen über dem realen Skript.
7. **Die [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)-Ablage bleibt, die Synthese der begleitenden ADR fasst die Formen** —
   die Hash-Ausnahme `.harness/stamp/**` bleibt unverändert in Kraft; die
   begleitende ADR des Architect-Sub-Zugs (Start-Trigger §4) nennt die zwei
   Stempel-Klassen bei dieser Erweiterung — `.harness/state/` (je Check +
   Gesamt, nicht-committet) und `.harness/stamp/` (committet, Lauf-Urteil) —
   unverändert von [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
   Festlegung 1.

**Datei-/Komponenten-Ebene:**

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/gates-keys.sh` <!-- d-check:ignore (Platzhalter: entsteht im Implementer-Zug, MR-071-Form) --> (Name beim Implementer) | neu | Schlüssel-Satzerzeuger je Check: je Check der Kante eine deklarierte Bezugsmenge (Tafel unten) — **eine** Definition, drei Leser (Schreiber, Fast-Pfad, Stop-Hook); fail-closed: unbekannter oder undefinierter Check → voller Lauf ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) |
| `harness/tools/gates-fast.sh` | update | die SKIP-Bedingung tritt vom Stempel-Paar (Tier-1) auf den je-Check-Satz (Tier-2); bei Teildrift Fahrt der gedrifteten Checks über `make <check>` |
| `harness/tools/record-gates.sh` | update | schreibt je Check nach dessen grünem Exit seinen je-Check-Key; die zwei Gesamt-Dateien bleiben ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)) |
| `.claude/hooks/stop-require-gates.sh` | update | Block-Kriterium: HEAD-Kante unverändert, je-Check-Deckung daneben (Festlegung 5) |
| `Makefile` | update | die Kante selbst bleibt — `record-gates: <Checks>` unverändert (Mutations-Fälle 213/214 greifen weiter); Rezept-Kommentar nennt die Tier-2-Form |
| `test/gate-nachweis-kante.bats`, `test/gates-fastpfad.bats` | update | Wächter-Bestand auf die je-Check-Form gezogen; die Zusagen des Kanten-Wächters bleiben, keiner gestrichen (Form des Tier-1-Closures) |
| `test/mutations/212`, `213`, `214`, `637` | update | Anker gegen den Quell-Bestand erneut gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)); die vier greifen über der neuen Form weiter |
| `test/mutations/<zwei neue Fälle>` | neu | die zwei Fälle aus Festlegung 6 (je Testart: Anlage-Form gemessen am Bestand, Negative/Happy) |
| `harness/README.md`, `harness/sensors/gates.md` | update | die Zeile `make gates` nennt die Tier-2-Form und die Grenze der Gesamt-Deckung (kein Abschnitt geleert) |

**Die Prüfgegenstand-Tafel je Check** (Menge als Form; je Zeile der Rest des
Gelesen-Bestands im Messrezept benannt, nicht geschlossen —
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4-Form, je Check; je Check gemessen — jede Menge trägt auch die
Rezeptzeile der Kante in `Makefile`, 13/13: `bash harness/tools/gates-keys.sh
menge <check> | grep -cE '^Makefile$'` → `1` je Check, und der Rezept-Edit
dreht den je-Check-Key, Rot-Züge `bash test/gates-keys.bats` Tests 7–10):

| Check | Menge (Form) | Begründung |
|---|---|---|
| `baseline-verify` | das Rezept `harness/tools/baseline-verify.sh` + der vendored Baum `.harness/baseline/` mit der `SHA256SUMS` **im Tag-Verzeichnis** (`.harness/baseline/<tag>/SHA256SUMS`) und der Baseline-Kopie `templates/.d-check.yml` + die Pin-Zeilen `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im `Makefile` (transitiv über die Rezeptzeile); das Wurzel-`.d-check.yml` liegt NICHT in der Menge | der Check urteilt über Integrität/Vollständigkeit des Tag-Verzeichnisses und die Pin-Kopplung; die Pin-Zeilen liest er unter dem `make`-Rezept — an die gefahrene Tafel angepasst, Form des Befunds als Tafel-Drift (Review-Befund F-2, je Wahrheitsgehalt gerechtfertigt) |
| `docs-check` | die gescannte Menge: `.d-check.yml`, `d-check.mk` und alle `.md` im Prüfbereich, vermindert um die `scan.ignore`-Ausschlüsse | das Gate urteilt über Doku-Referenzen in genau dieser Menge — dieselben Ausschlüsse, damit dieselbe Deckung wie der Lauf |
| `lint` | Go-Quellen `internal/**`, `cmd/**`, `go.mod`/`go.sum`, Lint-Config, die Dockerfile-`lint`-Stage | genau das liest golangci-lint in der Stage; der Docker-Cache-Zustand bleibt benannter Rest (Festlegung 4) |
| `build` | dieselbe Gelesen-Menge wie `lint`, in der `build`-Stage | dieselbe Stufen-Kette; eine Trennung wäre eine zweite Form desselben Gelesens ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 3) |
| `test` | Go-Quellen, `go.mod`/`go.sum`, `Dockerfile`-`test`-Stage, `test/*.bats` | Go-Unit- und Bats-Läufe lesen genau diese Bestände |
| `shell-lint` | `.claude/hooks/**`, `harness/tools/*.sh`, `.githooks/**`, `test/*.bats`-Rümpfe, Shellcheck-Konfig | genau die geprüften Shell-/Bats-Rümpfe; die Ausnahme-Liste im Kopf von `bats-lint.sh` gehört zur Definition |
| `ci-lint` | `.github/workflows/**` + der Actionlint-Pin im `Makefile` | genau die syntax-geprüften Workflows |
| `comment-claims` | die Prüfbereich-Menge des Sensors über der Gate-Config (Quell- und Doku-Bäume, wie der Sensor sie scannt) | der Sensor urteilt über Kommentar-Behauptungen in genau dieser Menge |
| `register-ausgang` | `docs/plan/planning/observations/**/state.md` + die `evidence/`-Mengen + das auswertende Skript | genau die gelesenen Zustandsfelder und der Zähler-Source |
| `mutate-greift` | `test/mutations/**`, `harness/tools/mutate.sh`, das `mutate-greift`-Rezept im `Makefile` | genau der Fall-Bestand und der Treiber, den das Rezept fährt |
| `host-bin` | das Rezept im `Makefile` (inkl. der `TRAEGER_TAG`-Auswertung) + `go.mod` + die cmd-/internal-Quellen (Modul-Daten, 113 Einträge gemessen); `harness/tools/`-Anteile keine — der Traeger wird benutzt, nicht gemessen (Prerequisite-Vorbild `archive-welle`) | das Rezept kompiliert die Quellen mit ihren Modul-Daten — an die gefahrene Tafel angepasst (Review-Befund F-2, zweite Zeile) |
| `span-check` | die span-Prüf-Skripte + die Träger-/Ablageort-Verdrahtung, die der Check liest (+ die Deklaration in `spec/spezifikation.md` §5, deren Verdrahtungssätze er hält) | der Check urteilt über Verdrahtung, nicht über Lauf-Ergebnisse |

**Design-Posten, die dieser Slice nach der Messung nicht mehr selbst trägt** —
beide übernommen vom Nehmer `slice-stamp-records-konsum-v1` (liegt
in `in-progress/`, s. §6):
der **Zuordnungs-Rest** des Stop-Hook-Approve-Zweigs (`gates-keys.sh rest`
nennt 34 Dateien außerhalb jeder Tafel-Menge) und der **Record-only-Vertrag**
(die ausgenommene Hash-Menge ist `.harness/stamp/mutate/`, nicht ganz
`.harness/stamp/**` — [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
Festlegung 2; Festlegung 6 (b) oben an die engere Menge geschärft).

**Ansatz als Liste (ergänzt die Tabelle):**

- Der je-Check-Stempel entsteht im **vollen** Lauf je Check ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 5 auf die je-Check-Ebene übertragen): ein Teildrift-Lauf schreibt
  nur den Stempel des von ihm gefahrenen Checks und berührt stehende Belege
  der ungeänderten Checks nie; ein roter Check hinterlässt keinen Beleg und
  entwertet keinen — sein Urteil steht in seinem Exit.
- Der Schlüssel-Satzerzeuger ist die einzige Form je Bezugsmenge; der
  Fast-Pfad und der Stop-Hook **ruft ihn** an, statt eine zweite Form
  derselben Definition zu pflegen — die Drift-Form aus
  [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Kontext (zwei Definitionen desselben Wortes) entsteht hier nicht wieder.

## 4. Trigger

**Start** (`next` → `in-progress`): der Auftrag des Auftraggebers ist
eingetreten (dieser Slice liegt priorisiert in `next/`), und die
begleitende ADR des Architect-Sub-Zugs — A-Form je Plan-Übergabe: `ADR-0108` — entsteht im Architect-Sub-Zug, Kennungs-Form bis dahin, als <!-- d-check:ignore (Platzhalter: entsteht im Architect-Sub-Zug, ADR-0104-Form) -->
*Stempel-Synthese*, nach der
Fastpfad-Präzedenz `slice-gates-fastpfad-ueber-stempel`
([ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) vor
`slice-gates-fastpfad-ueber-stempel`) — liegt `Accepted` vor. Ihr Gegenstand:
die je-Check-Stempel-Form gegenüber
[ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)/[ADR-0099](../../adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
(Festlegungen zu Key, Ablage, je-Check-Betroffenheit des benannten Rests und
der [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)-Ausnahme
auf **einer** Definition). Rollen-Sequenz Modul 8 — der Architect-Zug kommt
vor der Implementation.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Deckungs-Messung
  je Check zeigt für **die Mehrheit** der Checks keine zeigbar deckbare
  Baum-Menge (Schlüssel ≠ Gelesen-Bestand breit) — dann trägt nur je Check
  mit zeigbarer Deckung die je-Check-Form, der Übrige fährt voll als
  deklarierter Bestand ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 4-Form) — der Slice verkleinert den Fast-Pfad auf die gezeigten
  Checks, statt still weiterzuschließen (Form der
  Tier-1-Rückführung `slice-gates-fastpfad-ueber-stempel`:
  „nur für eine Klasse geschnitten").
- `in-progress` → `open` (blockiert — Carveout?): ein Check urteilt über
  etwas, das kein baum-abgeleiteter Schlüssel darstellt (Lauf-Zustand als
  Urteils-Eingang, etwa der Docker-Cache-Zustand eines im Image fahrenden
  Checks), und der je-Check-Fast-Pfad könnte nur mit Carveout greifen — die
  Frage wird offen an den Architect gestellt, bevor der je-Check-Fast-Pfad
  aktiviert wird.

## 5. Closure-Trigger

DoD (§2) vollständig, und die zwei reale Protokoll-Läufe stehen im Verifikations-Bericht:

1. ein **Doku-only-Commit** fährt nach einem grünen Lauf denselben
   Fast-Pfad, der die nicht-doku-gelesenen Checks SKIPpt und genau
   `docs-check-host` fährt — **gefahren** (Commit `97792eec`, nur README.md;
   d-check grün, 0 Befunde, je-Check-Stempel gesetzt). Der **Code-only**-
   Halbteil der ursprünglichen Zusage 1 ist an dieser Messung nicht gefahren —
   die Zusage galt breiter als ihre Messung; sie gilt an der Messung: die
   Sensitivität der Code-Checks trägt die Tafel-Menge samt der Rot-Züge
   (`test/gates-keys.bats`, Tests 7/8), den Halt am vollen Lauf trägt der
   Verifikations-Zug jeder Closure (`GATES_FORCE=1 make gates`, LP 2 (c)).
2. ein **Record-only-Commit** SKIPpt vollständig und rotiert keinen Stempel —
   **gefahren** (Commit `d12581ad`, nur `.harness/stamp/mutate/`; Keys
   byte-gleich vor/nach): die ausgenommene Hash-Menge ist die engere
   `.harness/stamp/mutate/`, nicht ganz `.harness/stamp/**`
   ([ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
   Festlegung 2); der Rest ist Design-Posten des
   `slice-stamp-records-konsum-v1` (§6).

Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Der je-Check-Schlüssel deckt den gelesenen Bestand eines Checks nicht**
  (Messung je [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 2) — **Ausgang (vorgesehen):** eingetreten → der betroffene
  Check fährt voll als deklarierter Bestand (Festlegung 4-Form, je Check in
  der begleitenden ADR benannt); der Slice schneidet weiter mit den zeigbaren Checks.
  Ein Befund über der Mehrheit → Rückführung §4.
- **Lokal fährt der Fast-Pfad je-Check, CI immer voll** (kein Stempel-Konzept
  auf CI) — **Ausgang (vorgesehen):** entfallen mit Grund — dasselbe
  Verhältnis wie Tier-1: das Netz dort ist CI
  ([ADR-0083](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)),
  der lokale Fast-Pfad war nie CI-Behauptung.
- **Der Record-Konsum rotiert je-Check-Keys** (der Satzerzeuger nimmt
  `.harness/stamp/**` nicht aus) — **Ausgang (vorgesehen):** geplant →
  die [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)-Ausnahme
  gilt auf der einen Definition; Mutations-Fall (b) als Wächter; wächst die
  Ausnahme-Liste, ist das der sichtbare Ort
  ([ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
  Festlegung 2-Form).
- **Der Zuordnungs-Rest des Stop-Hook-Approve-Zweigs und der Record-only-Vertrag
  in der Breite der Plan-Fassung** — der `gates-keys.sh rest`-Walk nennt 34
  Dateien außerhalb jeder Tafel-Menge; solange sie unzugeordnet sind, blockt
  der Hook auch über deckenden je-Check-Keys (fail-closed) und trägt der
  volle `record-gates`-Lauf am neuen HEAD plus die `stop_hook_active`-Freigabe
  des zweiten Versuchs; der Record-only-Vertrag las die Plan-Fassung als
  `.harness/stamp/**`, die ausgenommene Menge ist `.harness/stamp/mutate/`
  ([ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) Festlegung 2). — **Ausgang:** weiter offen →
  `slice-stamp-records-konsum-v1` (Nehmer-Kennung in §3); die Aufnahme des
  Rests je Check in die Mengen ist eine Plan-Entscheidung je
  [ADR-0108](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md) (Abwägung E), kein stiller Eintrag.

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** der Schlüssel-Satzerzeuger
  (`harness/tools/gates-keys.sh`) trägt je Check eine deklarierte Menge an
  **einer** Definition, drei Leser (Schreiber, Fast-Pfad, Stop-Hook); die
  Kante (`record-gates: <Checks>`) blieb in Bestand, Reihenfolge und
  Wächtern unverändert, die vier Alt-Fälle greifen weiter, 804 Mutationen in
  804 greifen.
- **Was ging anders als geplant:** die gefahrene Tafel driftete in zwei
  Zeilen von der Plan-Tafel (baseline-verify: `SHA256SUMS` im Tag-Verzeichnis,
  Wurzel-`.d-check.yml` nicht in der Menge, Pin-Zeilen transitiv über das
  `Makefile`; host-bin: Modul-Daten statt `harness/tools/`-Anteile) — der
  Nachzug trägt diesem Zug (§3, je Wahrheitsgehalt gerechtfertigt); Zusage 1
  in §5 galt breiter als ihre Messung (der Code-only-Halt ist ungemessen) —
  an der Messung geschärft, nicht still; der Record-only-Vertrag las
  `.harness/stamp/**`, die ausgenommene Menge ist `.harness/stamp/mutate/`.
- **Steering-Loop-Eintrag:** geschärfte Regel — die Rezeptzeilen der Kante
  liegen je Check in den Tafel-Mengen (gemessen 13/13:
  `bash harness/tools/gates-keys.sh menge <check> | grep -cE '^Makefile$'` →
  `1` je Check) und der Rezept-Edit dreht den je-Check-Key (Rot-Züge je
  `bash test/gates-keys.bats`, Rezeptzeilen- und Rezept-Edit-Klasse).
  Gezählt, nicht verkörpert — die Regel verkörpert sich im Wächter-Bestand
  vor der Regel-Zeit; die Teil-Zeile `liegt in` entfällt ersatzlos. Auslöser:
  die wiederkehrende Review-Finding-Klasse der Kante (F-Summary im
  `docs/reviews/2026-11-27-slice-gates-pruefgegenstand-stempel-v1.md`:
  Rezeptzeilen der Kante in 8 von 12 Mengen) und der Register-Beleg
  `evidence/slice-gates-pruefgegenstand-stempel-v1.md` in
  [`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/`](../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/).
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-gates-pruefgegenstand-stempel-v1.md`
  in [`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/`](../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/)
  ergänzt — der Eintrag ist schon verkörpert, seine Belege wachsen, die
  Zähler-Frage entfällt an der verkörperten Form; `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/`
  trägt seinen Beleg schon aus dem Implementer-Zug (Zähler 1). Kein Eintrag
  über der Schwelle mit diesem Zug.
- **Folge-Slices:** `slice-stamp-records-konsum-v1` (Nehmer der zwei
  Design-Posten aus §3/§6 — Zuordnungs-Rest, Record-only-Vertrag) — ist eine
  Datei in `in-progress/`.
- **Risiken aus §6:** 1. Mengen-Deckung — **entfallen** (gezeigt: alle 13
  Checks decken ihren gelesenen Bestand, Messung und Rot-Züge im
  Verifikations-Bericht); 2. CI immer voll — **entfallen** (dasselbe
  Verhältnis wie Tier-1: kein Stempel-Konzept auf CI, der lokale Fast-Pfad
  war nie CI-Behauptung); 3. Record-Konsum rotiert je-Check-Keys —
  **entfallen** (gemessen: Record-only-Commit `d12581ad`, Keys byte-gleich
  vor/nach; die ausgenommene Menge ist die engere `.harness/stamp/mutate/`
  je [ADR-0103](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) Festlegung 2); 4. Zuordnungs-Rest + Record-only-Vertrag —
  **weiter offen** → `slice-stamp-records-konsum-v1`.
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `harness/tools/`
(Kürzel `TOOLS`) und `*` (gesamtes Repo, Kürzel `ALL`) — beide stehen in der
Modus-Deklaration (`harness/conventions.md`
§Modus-Deklaration pro Sub-Area); beide erfüllen die Schwelle ≥ 2 von 3
Achsen — Strukturregeln über den Adaptions-Block (MR-Einträge) bzw. über die
Modus-Deklaration selbst, Phase-Reife Phase 5 (die Tools laufen in
`make gates`), Evidenz-Risiko bei GF niedrig.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/BEO-ALL/`, **286** Verzeichnisse;
`ls docs/plan/planning/observations/BEO-ALL/ | wc -l` — keine
Erwartungswert-Zahl, sie wandert mit dem Bestand). Je berührter Sub-Area
der Stand:

- [`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand`](../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/state.md)
  — **verkörpert** (3 Belege); dieser Slice arbeitet an der verkörperten
  Form — die je-Check-Bezugsmenge ist dieselbe Linie
  ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 3). Bei Closure `evidence/slice-gates-pruefgegenstand-stempel-v1.md`
  ergänzen.
- [`BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/state.md)
  — **geplant** (Ausgang mit Kennung zugewiesen); berührt die Gate-Zeile,
  die dieser Slice fortschreibt — die Zusage nennt ihren Ausschnitt
  (Festlegung 5 in §3), kein 3×-Übertritt mit diesem Slice.

Keine Treffer unter der Schwelle in den berührten Sub-Areas.

**Modus:** alle berührten Sub-Areas GF — der Modus-Begründungsblock entfällt.

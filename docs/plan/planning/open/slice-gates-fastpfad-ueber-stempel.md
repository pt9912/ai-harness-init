# Slice gates-fastpfad-ueber-stempel: Fast-Pfad von `make gates` über den Gate-Stempel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die mehr beobachtet,
als die DoDs dieses Slice belegen (`make gates` grün gehört ohnehin zu ihnen);
ein repo-weiter Beleg über die DoDs hinaus steht nicht an
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht —
wellenlose Arbeit ist Baseline-Default,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — jedes neue/umbenannte Target trägt seinen Gate-Index-Eintrag in [`harness/README.md`](../../../../harness/README.md) §Sensors · [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der SKIP ist deterministisch am Stempel-Paar, netzlos · [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) — Wortlaut-Präzedenz für Beleg-Schlüssel und benannten Rest · [`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) — Stempel-Konsum des Stop-Hooks, unverändert.

**Berührte Spec-Stellen:** [`spec/architecture.md §5`](../../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume) — die Ordnungskante `record-gates: $(GATE_CHECKS)` und `make -j`-Parallelität der Checks bleiben unverändert; nur ihr Konsum durch `gates` ändert sich.

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

<!-- Ziel = ein Satz, Liefer-Fokus. Je Ausschluss eine Begruendung. -->

aufraeumen". Abgrenzung = je Punkt eine Begruendung, nicht nur eine Nennung:
ein Ausschluss ohne Grund ist eine Behauptung. Keine Mindestzahl — ein echter
Ausschluss ist besser als vier erfundene. -->

**Ziel:** `make gates` meldet an einem Baum, dessen Hash den Gate-Stempel deckt, `gedeckt` und überspringt die Checks (Exit 0); sonst fährt es den vollen Lauf. Der Fast-Pfad macht jenes Urteil zum Einsprungpunkt von `gates`, das der Stop-Hook am Turn-Ende ohnehin fällt ([`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)) — kein neues Urteil, dieselbe Grundlage (`harness/tools/working-tree-hash.sh`, Baum-Hash über getrackte und untrackte Dateien, [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)); SKIP nur, wenn **beide** Stempel decken (`.harness/state/gates-passed.diffsha` gegen den Arbeitsbaum, `.harness/state/gates-passed.head` gegen HEAD) und **beide** gitignored bleiben (`record-gates` bleibt alleiniger Schreiber). Die begleitende ADR (SKIP-Bedingung, benannter Rest, FORCE-Schalter) schreibt der **Architect** (Übergabe Planner→Architect→Planner, Modul 8); der Slice liest sie als Constraint und zieht seine Tests danach.

**Design-Enge, im Plan festgehalten:** Ein Fast-Pfad *im Rezept von* `record-gates` bringt nichts — `make` baut die Prerequisites zuerst, das Rezept liefert zuletzt. `gates` wird darum selbst zum Rezept, das einen Wrapper startet: gedeckter Stempel → Meldung, Exit 0; sonst `make record-gates`. Diese Form bricht die Deckungsgleichheit `make -n gates` ⟷ `make -n record-gates`, die [`test/gate-nachweis-kante.bats`](../../../../test/gate-nachweis-kante.bats) misst — der Wächter wird im Slice mitgezogen und die Änderung einmal rot gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6, kein Test, der nur die heutige Implementierung prüft).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **bats-Sharding** — Bestand bleibt bewusst stehen: Der Fast-Pfad heilt den Warm-/Wiederhol-Lauf, nicht die Kalt-Messung in CI (frischer Klon hat keinen Stempel und fährt fail-closed voll); das Sharding adressiert eine andere Ursache als der Fast-Pfad: ohne Stempel-Schlüssel in CI fährt der Kalt-Lauf zu Recht voll, die ~166 s der bats-Suite (~50 % der gemessenen Gesamtdauer) bleiben davon unberührt.
- **Kanten-Parallelisierung** (neue `.NOTPARALLEL`-Entscheidung, Reordering von `record-gates: $(GATE_CHECKS)`) — das wäre ein anderer Vorgang: Die Ordnungskante ist bewacht ([`test/gate-nachweis-kante.bats`](../../../../test/gate-nachweis-kante.bats)) und an [`spec/architecture.md §5`](../../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume) verankert; ihre Parallelität wird separat entschieden, nicht hier mitgenommen.
- **„Nur Arbeitsweise"** — ein anderer Vorgang: Der Auftraggeber hat zwischen Fast-Pfad über Baum-Hash und Arbeitsweise-Änderung entschieden; nur ersteres ist der Gegenstand und erzeugt ein Repo-Artefakt.
- **Stempel-Form und ihr Konsum bleiben unverändert** — Schicht-Abgrenzung: `record-gates` schreibt wie heute `.harness/state/gates-passed.diffsha` und `.harness/state/gates-passed.head` (gitignored, [.gitignore](../../../../.gitignore)); der Stop-Hook ([`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)) liest sie unverändert; der Fast-Pfad schreibt keinen Stempel.
- **Kein neuer CI-Workflow** — ein anderer Vorgang: CI fährt `make gates` auf dem frischen Klon unverändert (kein Stempel → fail-closed voller Lauf); ein Stempel-Vorlauf im CI wäre eine separate Kalt-Pfad-Entscheidung.

## 2. Definition of Done

<!-- je Zeile ein pruefbares Kriterium; drei Liefer-Punkte. -->

- [ ] Fast-Pfad-Verdrahtung: `make gates` überspringt die Checks nur über dem gedeckten Stempel-Paar (`.harness/state/gates-passed.diffsha` **und** `.head` gegen [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh) bzw. HEAD) und meldet die gedeckte Lage; fehlender, unlesbarer oder nicht mehr passender Stempel fährt fail-closed den vollen Lauf ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Semantik); Test: eine neue bats-Datei `test/gates-fastpfad.bats` — Happy (gedecktes Paar → SKIP-Meldung), Negative (Stempel fehlt / trägt fremden Hash / ist unlesbar → voller Lauf), Boundary (FORCE-Schalter zwingt den vollen Lauf über gedecktem Paar, Analogie `MUTATE_FORCE=1`, [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4).
- [ ] Zahn-Nachweis je Richtung ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die gezogene Deckungsgleichheits-Annahme von [`test/gate-nachweis-kante.bats`](../../../../test/gate-nachweis-kante.bats) ist einmal aus dem richtigen Grund rot gesehen; zwei neue Mutations-Fälle unter `test/mutations/` (SKIP greift ohne gedecktes Paar färbt den Wächter rot am benannten Grund; Anker am Commit, [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] [`harness/README.md`](../../../../harness/README.md) §Sensors: die `make gates`-Zelle nennt den Fast-Pfad und verweist als Bindung auf die ADR des Architects; die SKIP-Meldung nennt den benannten Rest, den kein baum-abgeleiteter Schlüssel deckt (Docker-Cache-Zustand, Host-Werkzeuge — Wortlaut-Präzedenz [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für <Schnittstelle X> falls öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

<!-- Der Implementer-Agent erweitert die Liste in seinem ersten Lauf. -->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| eine neue Wrapper-Datei `gates-fast.sh` unter `harness/tools/` | neu | Wrapper: vergleicht Stempel-Paar gegen Arbeitsbaum-Hash und HEAD, fail-closed bei Zweifel, startet `make record-gates` sonst; Meldung mit benanntem Rest; FORCE-Schalter (Name: `GATES_FORCE=1`, Empfehlung — die endgültige Benennung trägt die architectliche ADR) |
| `Makefile` | update | `gates:` wird zum Rezept, das den Wrapper startet (Design-Enge §1); `record-gates:` und die Ordnungskante `record-gates: $(GATE_CHECKS)` bleiben byte-gleich ( [`test/gate-nachweis-kante.bats`](../../../../test/gate-nachweis-kante.bats) misst die Kante weiter) |
| [`test/gate-nachweis-kante.bats`](../../../../test/gate-nachweis-kante.bats) | update | Wächterdeckung an die neue Form gezogen (Deckungsgleichheits-Prüfung neu gefasst oder um die SKIP-Form ergänzt); Rot einmal gesehen — DoD 2 |
| `test/gates-fastpfad.bats` | neu | Happy/Negative/Boundary nach DoD 1, hermetisch über Fixture-Makefiles wie der Kanten-Wächter; `--network none` |
| je 2 Fälle in `test/mutations/` | neu | der Zahn des Fast-Pfad-Wächters (DoD 2); sed-Anker gegen den Quell-Bestand ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)), Anker am Commit ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)) |
| [`harness/README.md`](../../../../harness/README.md) | update | §Sensors-Zelle `make gates`: Fast-Pfad + Bindung zur ADR des Architects |

**Ansatz:** die SKIP-Bedingung lehnt sich am Stop-Hook-Analogie an, nicht an ein zweites Urteil
([`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)): dieselbe Grundlage
(`harness/tools/working-tree-hash.sh` + HEAD), dieselbe Bedingung, `gates` als Einsprung statt
nur der Stop-Hook; CI bleibt unverändert (frischer Klon fährt voll).

## 4. Trigger

**Start** (`next` → `in-progress`): der Auftrag des Auftraggebers ist eingetreten (dieser Slice liegt priorisiert in `next/`), und die ADR des Architects zur SKIP-Bedingung, dem benannten Rest und dem FORCE-Schalter liegt `Accepted` vor (Rollen-Sequenz Modul 8 — der Architect-Zug kommt vor der Implementation).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der SKIP braucht über das Stempel-Paar hinaus Klassenausschlüsse oder ein zweites, feineres Beleg-Format (etwa je-Target-Belege) — dann ist der Fast-Pfad nur für eine Gate-Klasse geschnitten, nicht für alle.
- `in-progress` → `open` (blockiert — Carveout?): eine `gates`-Voraussetzung trägt einen Prüfgegenstand, den der Baum-Hash strukturell nicht deckt (etwa ein netz-bindender Check tritt in `make gates` auf), und die SKIP-Bedingung könnte nur mit Carveout greifen — die Frage wird offen gestellt, bevor der Fast-Pfad aktiviert wird.

## 5. Closure-Trigger

DoD vollständig (inkl. Zahn-Nachweis je Richtung, §3.6) + Review-Report
unter [`docs/reviews/`](../../../../docs/reviews/) + `make gates` grün +
Closure-Notiz mit Lerneintrag — ohne ihn ist der Slice nur abgelegt.
Beobachtung: der erste `make gates`-Lauf nach dem Merge fährt selbst den
vollen Lauf (der Code liegt im Baum-Hash), der darauf folgende überspringt —
beide Richtungen sind damit nach der Lieferung am realen Wächter beobachtbar.

## 6. Risiken und offene Punkte

- Der Stempel deckt den Zustand von Docker-Cache und Host-Werkzeugen nicht — SKIP urteilt über einen baum-abgeleiteten Schlüssel, der nicht jeden Prüfgegenstand trägt (Vorbild: [`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand`](../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/observation.md), [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4). — **Ausgang:** eingetreten → SKIP nur bei gedecktem Paar (diffsha und head), SKIP-Meldung nennt den benannten Rest mit dem [`ADR-0035`-Wortlaut](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md), FORCE-Schalter erzwingt den vollen Lauf; der Beleg des Auftretens wandert in den bestehenden Register-Eintrag (zitieren statt neu anlegen).
- Verhalten-Change in CI: ein frischer Klon hat keinen Stempel. — **Ausgang:** entfallen → fail-closed-Default: fehlender, veränderter oder unlesbarer Stempel fährt den vollen Lauf (DoD 1, Negative-Fälle); CI ruft `make gates` unverändert.
- Zweite Quelle für denselben Zustand: der Fast-Pfad könnte wie ein zweiter Stempel-Schreiber gelesen werden. — **Ausgang:** entfallen → der Fast-Pfad schreibt nichts; `.harness/state/gates-passed.<diffsha|head>` entsteht allein im Rezept `record-gates` und wird vom Stop-Hook unverändert konsumiert ([`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)).
- Ein späteres Gate-Audit schließt die SKIP-Bedingung, ohne die Werkzeug-Änderung im Stempel zu beachten. — **Ausgang:** entfallen → der Baum-Hash trägt getrackte und untrackte Dateien ([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)); jede Änderung an `record-gates.sh`, `working-tree-hash.sh` oder dem Fast-Pfad selbst invalidiert den Stempel und erzwingt den vollen Lauf — kein zweiter Mechanismus nötig.

## 7. Closure-Notiz

<!-- Reihenfolge: diese Sektion vor dem `git mv` nach done/ fuellen —
einzige Ausnahme ist das letzte DoD-Item in §2 (die Paarungen suchen in
`done/`, also nach dem `git mv`). Vorhandene `BEO-<KUERZEL>/<slug>` zitieren,
nicht neu formulieren; das Feld `liegt in` steht nur, wenn hier wirklich
etwas verkörpert wurde. Im Repo ohne Wellen-Betrieb braucht die Closure
drei Commits: Inhalt, `git mv`, Haekchen. -->


- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** zwei berührte Sub-Aren, beide erfüllen die Schwelle ≥ 2 von 3 Achsen. `harness/tools/` (Kürzel `TOOLS`): Pfad-Berührung **und** Regeln des Bereichs sind im Adaptions-Block verankert ([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff), [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)). `*` (gesamtes Repo, Kürzel `ALL`): der Gegenstand ist das repo-weite Gate-Target `make gates` samt Stop-Hock-Kopplung (Hard Rules [`AGENTS.md`](../../../../AGENTS.md) §3.6/§4). `Makefile` allein wäre zu grob — es wird auf diese zwei Arenen verteilt, keine Ausdifferenzierung nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand`](../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/observation.md) — Stand `offen`, Zähler 1 Beleg (`ls .../evidence/... | wc -l` → 1; datierte Messung, [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)), unter der Schwelle 3. Der Slice berührt dieselbe Klasse (Stempel-Wahrheit, Risiko 1 in §6); der Beleg wird bei der Closure ergänzt — Zähler 2×, immer noch kein eigener Folge-Slice. `BEO-TOOLS/`: zwei Einträge (`live-pipe-unter-pipefail-verwirft-treffer`, `nicht-gate-werkzeug-ohne-funktionalen-waechter`) — keine betrifft den Fast-Pfad; keine Treffer ist ebenfalls eine Antwort.

**Modus-Begründungsblock:** alle berührten Sub-Aren GF (Deklaration [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area — `*` GF, `harness/tools/` GF); der Begründungsblock je Sub-Area entfällt, der Hinweis genügt.

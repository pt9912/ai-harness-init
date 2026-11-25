# Slice slice-c2-template-renames-und-kennungs-formen-v7-0-0: Template-Renamens + Kennungs-Formen (Cluster C2)

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: `make gates` über
dem Gesamt-Baum, der Replay `make full-smoke` und der kollektive Mutations-Sweep
nach der Heilung (siehe §6, Risiko 2).

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(die Emitterseite der Template-Ablage),
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
(Werkzeug-/Rollen-Namen der Baseline),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form),
[`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
(zugelassene Formen → Fundliste im Vorgang),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
(Anker von Mutations-Fällen gegen den Quell-Bestand),
[`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert)
(Archiv-Form wellenloser Slices),
[`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
(Mutations-Probe — Abweichung als Welle-Form, §6),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

**Berührte Spec-Stellen:** `—` — die Vorlagen-, Kennungs- und Verweis-Formen
stehen im v7-Regelwerk-Baum (`.harness/baseline/v7.0.0/templates/` samt der
Norm „Dateinamen sind englisch" in `grundlagen-harness-dateien.md`) und im
Adaptions-Block, nicht im Spec-Stratum.

**Verantwortlich:** pt9912.

**Autor:** Planner (ai-harness-init-Team, pt9912). **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die sieben umbenannten Vorlagen des `v7.0.0`-Sprungs tragen am
**Emissionssort** — der Emitter schreibt die Ziel-Skelette unter den
v7-Dateinamen (`spec/spezifikation→specification`,
`docs/plan/adr/NNNN-titel→NNNN-title`, `planning/welle→wave`,
`welle-results→wave-results`, `archiv-stub-slice→archive-stub-slice`,
`archiv-stub-welle→archive-stub-wave`,
`harness/conventions/MR-NNN-titel→MR-NNN-title`), die
Kennungs-Präfixe (`welle-`→`wave-`, `<welle-id>`→`<wave-id>`,
`archiv.zip`→`archive.zip`) ziehen in emittierten Inhalten und
Dogfood-Texten, die 145 `target-missing`-Verweise des Doc-Gate zeigen auf die
neuen Pfade, und die Form-Fundlisten des Adaptions-Blocks tragen die neuen
Namen ([`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
`Löst auf`-Feld,
[`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang),
[`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert)).

**Bewusstes Urteil — Werkzeugnamen bleiben Prosa-Deutsch
([`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)-Linie),
nicht statt.** Der v7-Satz *„Dateinamen sind englisch"* (`grundlagen-harness-dateien.md`)
gilt für **Dateinamen der Vorlagen**. Bezeichner, die eine Rolle oder das
Werkzeug-Interface tragen — `plan-welle`, `close-welle`, `archive-welle`, der
Datei-Pfad `templates/commands/plan-welle.md` in
[`internal/emit/commands.go`](../../../../internal/emit/commands.go) — bleiben
steht; **Platzhalter- und Kennungs-Formen** ziehen: die Interface-Variable
`WELLE=<welle-id>` in
[`internal/emit/templates/enforce/archivierung.mk`](../../../../internal/emit/templates/enforce/archivierung.mk)
zieht als `WAVE=<wave-id>`, weil sie den Kennungs-Form-Stand trägt, nicht den
Rollen-Namen. Dieses Urteil steht hier ausgeschrieben
([`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)-Nachfolge
als Eintrags-Zug trägt C7, siehe unten) — kein stiller Zug.

**Ausdrücklich NICHT in diesem Slice:**

- **C3 d-check-Fächer** — die emittierte Doc-Gate-Konfig am neuen Regelwerk-Stand
  (`worktrees`-Ignore, kommentierte Standard-Blöcke `planning`/`pinsync`,
  `planning` verlangt d-check ≥ `v0.91.0`): die Modul-Zusammensetzung ist eine
  Entscheidung ([`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Ruder),
  kein Namens-Zug. Hier zieht **nur die Namens-Form** in
  [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml)
  (die `welle`-Klasse samt Token und Regel-Namen); der Konfig-Gegenstand
  übernimmt `slice-c3-d-check-faecher-v7-0-0`
  ([`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) §4 —
  die Kennung ist die Tafel-Adresse, die Slice-Datei entsteht beim Schnitt und
  nimmt die Sendung an, Klasse 1).
- **C4 environment-check** — die Sensor-Entscheidung über die neue Vorlage
  `templates/harness/sensors/environment-check.template.md` (M): Ob das
  emittierte Skelett einen neuen Sensor führt, ist Adaption am Regel-Stand,
  kein Rename — `slice-c4-environment-check-v7-0-0` (Tafel-Adresse, Klasse 1).
- **C5 Vertrauensgrenzen** — die Regel-Baum-Texte am neuen Stand
  (`architecture` §6, Modul-14-Umbau, Modul-04): hier zieht allein die
  Verweis-Achse, die auf Vorlagen-Namen zeigt; die Anker-Deckung der
  Referenz-Achse übernimmt `slice-c5-vertrauensgrenzen-v7-0-0`
  (Tafel-Adresse, Klasse 3 — anderer Vorgang: Anker statt Form).
- **C6 AGENTS-Vorlage** — der übernommene Docker-/Parallele-Läufe-Norm-Satz
  (`AGENTS.template.md`, M): Referenz-Adaption des Sockel-Norm-Texts, kein
  Rename — `slice-c6-agents-vorlage-v7-0-0` (Tafel-Adresse, Klasse 3).
- **C7 Adaption-Nachzüge** — die Terminologie-/Stand-Text-Züge
  ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  feuert, [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag),
  der [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)-Nachfolge-Eintrag
  — M): hier zieht **nur die Form-Fundliste** in den Eintrags-Dateien
  (die gemessenen zugelassenen Formen, [`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)-Form),
  nicht die Aussage — die Aussage bleibt byte-gleich außerhalb der Listen;
  die Norm-Entscheidungen übernimmt `slice-c7-adaptions-nachzuege-v7-0-0`
  (Tafel-Adresse, Klasse 1 oben).
- **Die Mutations-Probe als eigener CI-Branch-Lauf**
  ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  Setzung 1): ausgeschlossen — die C1-Lern-Zeile
  ([`slice-baseline-vendorung-v7-0-0` §7](../welle-baseline-sprung-v7-0-0.md))
  zeigt, dass die Probe wellen-intern unurteilbar bleibt, solange eine geplante
  rote Fläche im Zwischenstand trägt (0 Fall-Urteile über drei Läufe). Die
  Setzung ist die **Welle-Form** (§6, Risiko 2) — benannt, nicht still.

## 2. Definition of Done

- [ ] **(1) Der Emitter trägt die v7-Formen:** die sieben Vorlagen-Namen in
      [`internal/emit/templates.go`](../../../../internal/emit/templates.go)
      (case-Zeilen, Konstanten, Link-Texte — einschließlich der zwei
      `v6.18.1`-Kommentar-Stellen, Zeilen 1056/1135), die
      `fremdeKennung`-Regexp in
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go)
      (die falsch-alte `welle-[0-9]+`-Alternative), die Namens-Form in
      [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml),
      das Archiv-Keying in
      `internal/emit/templates/{agents,enforce,commands}` — `go test ./...`
      grün, `make test-bats` trägt keinen Befund mehr in den
      C1-Fixtur-Fällen **17/19/20/105–108**.
- [ ] **(2) Die 145 `target-missing`-Verweise zeigen auf die neuen Pfade** —
      `make docs-check` meldet nach dem Zug keinen Befund der Klasse
      `target-missing` mehr (Basismessung am Stand nach C1:
      `d-check: 2988 Datei(en) geprüft, 145 Befund(e)`, 2026-11-25); die
      übrigen Befund-Klassen der Cluster C3–C7 tragen deren DoD, §7 nennt die
      verbleibende Zahl am Kommando
      ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
- [ ] **(3) Die Form-Fundlisten tragen die neuen Namen:** [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
      (Fundliste im Vorgang — Messung nach dem Zug, [`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)),
      [`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang),
      [`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert)
      (die `archiv.zip`-Form erbt die `archive.zip`-Form im emittierten Stub);
      die [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)-Aussage
      bleibt bewusst unberührt (Urteil oben, sie trägt C7).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein
      Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — Beleg oder
      „keine Beobachtung angefallen" in §7; kein Zähler wird gesetzt, er folgt
      aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure ([`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md),
      auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/templates.go`](../../../../internal/emit/templates.go) | update | case-Zeile 86–91, Konstanten und Link-Texte auf die sieben v7-Namen; die zwei `v6.18.1`-Kommentar-Stellen (Zeilen 1056/1135) auf den neuen Tag ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)-Nachziehung im Kommentar) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | `fremdeKennung` (Zeile 268): die Alternativ-Form `welle-[0-9]+` übernimmt die wave-Form — die Erkennung trägt die **zugelassenen** Formen ([`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang), Fundliste in diesem Plan) |
| [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) | update (Namens-Form) | die `welle`-Klasse samt Token und Regel-Namen in der wave-Form; **nicht** die Modul-Zusammensetzung ([`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel), C3) |
| [`internal/emit/commands.go`](../../../../internal/emit/commands.go) | prüfung (erwartet keine Änderung) | Command-Ziele `plan-welle`/`close-welle` bleiben — Werkzeugnamen (Urteil oben) |
| `internal/emit/templates/enforce/archivierung.mk` | update | `WELLE=<welle-id>` → `WAVE=<wave-id>` (Kennungs-Form, Urteil oben), Target-Name `archive-welle` und der `done/<welle-id>/`-Verzeichnis-Erzug im wave-Stand |
| [`internal/emit/templates/enforce/slice-mv.sh`](../../../../internal/emit/templates/enforce/slice-mv.sh) | prüfung (update, falls der Name-Präfix-Zug die `welle-`-Klassifizierung trägt) | der „praefixlose `weller`-/`wave-`-Ziel"-Handgriff liest den Bestand — Form-Zug nur dort, wo der Satz den alten Präfix trägt |
| [`internal/emit/baumaussage.go`](../../../../internal/emit/baumaussage.go) | prüfung (erwartet keine Änderung) | die Bezugs-Zeile nennt `make archive-welle` (Werkzeugname, Urteil oben); keine Vorlagen-Namen im Text (grep 2026-11-25: keine Funde) |
| [`internal/emit/fieldlist.go`](../../../../internal/emit/fieldlist.go) | prüfung (erwartet keine Änderung) | grep `welle\|wave\|archiv\|archive` (2026-11-25): keine Funde — der Form-Zug trägt hier keinen Zug |
| [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go) / [`internal/emit/emitteddocs_test.go`](../../../../internal/emit/emitteddocs_test.go) | update | Fixtures (`courseSet`/Inventare) an den **realen** v7-Vorlagen-Satz — der Bestand ist die Quelle, nicht die nachgebaute Fixtur ([`AGENTS.md`](../../../../AGENTS.md) §3.6, letzte Fassung) |
| [`test/courseset-fixture.bats`](../../../../test/courseset-fixture.bats) / [`test/archiv-stub-vorlagen.bats`](../../../../test/archiv-stub-vorlagen.bats) / [`test/vcs-modul-wiring.bats`](../../../../test/vcs-modul-wiring.bats) | prüfung / update (Fixtur-Fälle 17/19/20/105–108) | die Fälle zielen auf die Stub-Vorlagen-Namen — geändert wird je Fall nur, wenn er die alten Namen selbst hardcodiert; grün, wenn die Fixtures den realen v7-Satz tragen |
| [`test/mutations/215-welle-results-als-singleton.sh`](../../../../test/mutations/215-welle-results-als-singleton.sh) / [`test/mutations/222-archiv-stub-slice-als-singleton.sh`](../../../../test/mutations/222-archiv-stub-slice-als-singleton.sh) / [`test/mutations/223-archiv-stub-welle-als-singleton.sh`](../../../../test/mutations/223-archiv-stub-welle-als-singleton.sh) | update (sed-Anker) | [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand): der Anker misst gegen den Quell-Bestand — je Fall nur Namens-Anteile (`welle-results→wave-results`, `archiv-stub-*→archive-stub-*`), Form wie im Vorgänger-Slice (`slice-baseline-vendorung-v7-0-0`, §7) für 224/244/248 (diese drei sind bereits re-geankert — hier prüfung) |
| [`harness/conventions.md`](../../../../harness/conventions.md) + [`harness/conventions/MR-057-…`](../../../../harness/conventions/MR-057-kennungs-form-fuer-neue-slices-und-wellen-ist-der-name.md), [`harness/conventions/MR-059-…`](../../../../harness/conventions/MR-059-kennungs-erkennung-traegt-die-zugelassenen-formen.md), [`harness/conventions/MR-078-…`](../../../../harness/conventions/MR-078-wellenlose-slices-werden-bei-der-eigenen-closure-archiviert.md) | update (Fundlisten-Zug) | die zugelassenen Formen/Fundlisten tragen die neuen Namen und die Messung nach dem Zug ([`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)); die Aussage bleibt byte-gleich außerhalb der Listen (Risiko 3) |
| README/README-Doku, die ins v6-Namens-Abgetretene zeigen: [`AGENTS.md`](../../../../AGENTS.md), [`CLAUDE.md`](../../../../CLAUDE.md), [`harness/README.md`](../../../../harness/README.md), [`harness/sensors/`](../../../../harness/sensors/), [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md), [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md) u. a. je Befundzeile | update | die 145 `target-missing`-Verweise re-pointed — der Verweis zieht auf den neuen Pfad und, wo er einen Vorlagen-Namen trägt, auf dessen v7-Namens-Form |

**Ansatz:**

- **Die sieben Vorlagen-Renamens ziehen als ein Namens-Zug,** einzeln würde je
  Form ein Zwischenstand halb-alt/halb-neu tragen — der Emitter, die Fixtures
  und die Fall-Anker lesen denselben Baum, der Form-Zug ist kopplungs-streng
  (fail-closed-Gruppe, wie die Pin-Formen in [C1](../welle-baseline-sprung-v7-0-0.md)).
- **Die Rollen-/Werkzeug-Bezeichner-Nachzieh (Fundlisten-Messung) läuft nach dem
  Form-Zug** — eine Messung, die ihr eigener Vorgang bewegt, wird nach dem
  Vorgang genommen ([`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)).
- **Jeder Verweis-Befund nach dem Zug einzeln gere-pointed** (je Zielpfad vorher
  per `test -f` geprüft, Form wie das Retargeting des Vorgänger-Slices).

## 4. Trigger

**Start** (`next` → `in-progress`): der Start-Trigger der
[`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) ist
eingetreten (`slice-gates-fastpfad-ueber-stempel` liegt in `done/`), **und** die
vorgelagerte Cluster-Closure [`slice-baseline-vendorung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)
liegt in `done/` (beides ist am 2026-11-25 eingetreten — deshalb wird der
Slice bereits mit der Anlage direkt `open` → `next` priorisiert, mit gesetzt
`Verantwortlich:`-Feld).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Form-Zug greift
  über Namens- und Präfix-Züge hinaus — etwa verlangt die `d-check.yml`-Klasse
  Klassen-Mechanik statt Namens-Zug (die emittierte Modul-Konfig), oder das
  `courseSet`-Fixture-Konstrukt braucht einen eigenen Form-Vertrag.
- `in-progress` → `open` (blockiert — Carveout?): der v7-Vorlagensatz und der
  Emitter divergieren semantisch (die Vorlagen ändern sich über Rename hinaus
  — der Form-Zug bricht): Reproduktion, dann Sendung an C3–C7.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt, Review-Report unter `docs/reviews/`, Closure-Notiz mit
Lerneintrag. **Mutations-Form des Slices:** kein eigener CI-Branch-Lauf
([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
Setzung 1 — oben ausdrücklich ausgeschlossen); die Belege tragen
lokal `make mutate-greift` (Färbung der Anker-Treffer, [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
§Grenze benannt) und der **kollektive CI-Sweep nach der Welle-Heilung** als
Träger der Fall-Urteile.

## 6. Risiken und offene Punkte

- **R1 — Die `emitteddocs`-/Template-Fixtures tragen Form-Verträge je Sektion**
  (die sieben Befund-Zusagen des C1-Zugs, Fall-Klassen 17/19/20/105–108): der
  Form-Zug könnte je Form eine Test-Nachziehung brauchen, und eine Zusage, die
  unter dem Zug ohne Nachziehung grün bleibt, bricht. — **Ausgang:** erwartbar
  **entfallen** — der Zug trägt je Form die Fixtur-Nachziehung mit (die
  Fixtures messen den realen v7-Satz als Quelle, nicht eine nachgebaute
  Fixtur); bleibt eine Zusage ohne Nachziehung grün, wird sie an der Stelle
  benannt und der Ausgang geändert (dann: weitere Öffnung → Register).
- **R2 — [`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  Setzung 1 (Mutations-Probe eines Slices über CI-Branch ab neun Fällen) ist im
  geplanten roten Welle-Zwischenstand strukturiert unerfüllbar** — die
  geplante rote `test-bats`-Fläche bricht den Grün-Vorlauf je Shard-Kopie
  fail-closed, bevor ein Fall urteilt (C1-Lern-Zeile, 0 Fall-Urteile in drei
  Läufen). — **Ausgang:** **weiter offen** — die **Welle-Form** trägt den
  Beleg: der kollektive CI-Sweep nach der Heilung (Anker der Fälle zielen auf
  den Bestand, [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
  der Lese-Schritt der [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)-Closure
  liest die Ausgangs-Zeile.
- **R3 — Die Fundlisten-Nachziehung berührt angenommene Einträge**
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  Form — „an einem angenommenen Eintrag wird nichts nachträglich inhaltlich
  geändert"): die Nachziehung an [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)/[`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)/[`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert)
  liest sich als Inhalts-Änderung. — **Ausgang:** erwartbar **entfallen** —
  die Nachziehung trägt die **datierte Fundliste** (Messstelle im `Löst auf`-/
  `Grenze`-Feld, [`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)-Form),
  nicht die Aussage; erweist sich eine Aussage (nicht die Liste) als betroffen,
  ist sie **eingetreten** und trägt C7.
- **R4 — Der `make docs-check`-Zwischenstand trägt nach diesem Zug weiter
  Befunde der übrigen Cluster (C3–C7)** — C2 könnte als „der
  Welle-Zwischenstand ist grün" gelesen werden. — **Ausgang:** erwartbar
  **entfallen** — §7 nennt die verbleibende Zahl am Kommando und ihre
  Cluster-Zuordnung ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen; die Befund-Zuordnung der verbleibenden
docs-check-Zeilen je Cluster (R4) trägt dieser Abschnitt am Kommando
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)). -->

**Implementer-Übergabe (2026-11-25) — Review-F-Nachziehung, nicht die Closure:**

- **F-1/F-2 (WAVE-Formzug trug nur zwei von drei Beinen) — geheilt:** die Rezept-Zeile
  `internal/emit/templates/enforce/archivierung.mk:42` `$(WELLE)` → `$(WAVE)` und die
  Dogfood-Variable `Makefile:592–596` (Kommentar, `ARCHIV_KENNUNG`-Filter, Hilfe-Zeile,
  Pass-through) samt den drei sie beschreibenden Textstellen (`harness/sensors/archive-welle.md:11`,
  `cmd/ai-harness-init/archive_welle_test.go:347f`, Mutations-Anker 255/256). Lauf-Zahn
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6): an einer isolierten Kopie von HEAD vor dem Fix
  ergab `make -n archive-welle WAVE=wave-reviews-somesh-probe` ein leeres Argument
  (`archive-welle  ""`); nach dem Fix trägt das Argument die Kennung
  (`archive-welle  "wave-reviews-somesh-probe"`, gegenstands-los `""`,
  `WAVE=altbestand KENNUNG=…` → `--kennung "…" "altbestand")`.
- **Zahn-Grenze der Rezept-Zeile:** kein Wächter in `make gates` hält den
  Kennungs-Pass-through der mk-Rezept-/Makefile-Zeile — die Test-Stelle
  `cmd/ai-harness-init/archive_welle_test.go` (leere Kennung) misst den Binär-Parser, die
  Hilf-Zeile hält `internal/emit/archivierung_test.go` als Text, und die Mutations-Anker 256 (Makefile),
  509/511 (Fragment-Text) greifen auf Quelltext-Niveau; der Aufruf selbst läuft erst in einem
  realen Ziel (`make full-smoke`). Die Grenze steht hier benannt ([`AGENTS.md`](../../../../AGENTS.md) §3.6-Form),
  nicht still grün.
- **docs-check am Stand nach dem Zug: `d-check: 2989 Datei(en) geprüft, 0 Befund(e)`** —
  keine verbleibende Befundzeile, keine C3–C7-Zuordnung nötig (R4 entfallen am Kommando,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind die Emittersebene
(`internal/emit/*`), der Adaptions-Block ([`harness/conventions.md`](../../../../harness/conventions.md)
samt Einträgen), die Dogfood-Doku ([`AGENTS.md`](../../../../AGENTS.md),
[`CLAUDE.md`](../../../../CLAUDE.md), [`harness/README.md`](../../../../harness/README.md),
[`harness/sensors/`](../../../../harness/sensors/),
[`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)) und
die Mutations-/Bats-Fixtur-Ebene — alle fallen unter den Eintrag
`*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area);
die Schwellwert-Prüfung trägt der Eintrag, weiter ausdifferenzieren ist hier
nicht nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register `BEO-ALL`
durchgegangen (279 Einträge). Treffer, die die Sub-Area der Form-Züge betreffen
und hier als Risiko stehen: [`BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
(Stand: offen — die R3-Grenze, Träger der Lücke bleibt der Lauf, der die Form
zieht), [`BEO-ALL/namensform-kennung-in-emittierter-datei-ohne-sensor`](../observations/BEO-ALL/namensform-kennung-in-emittierter-datei-ohne-sensor/observation.md)
(Stand: offen — kein Sensor; der Träger bleibt dieser Lauf, die Fundliste in
diesem Plan §3),
[`BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
(Stand: offen — der Emitter-Zug läuft hier nicht mehr voraus: die v7-Baum-Form
steht nach C1, der Bestand zieht nach). Keine Berührung erreicht die Schwelle
mit diesem Slice.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — entfällt nach dem
Umfang-Absatz der Vorlage.

# Slice slice-088: d-check-Pin v0.51.1 → v0.62.0 (elf Minors; `structure` wird verfügbar)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiv — der Pin ist veraltet) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Pin **ist** die
Reproduzierbarkeit: ein Tag ohne Digest ist ein bewegliches Ziel, und ein Pin, der an mehreren
Orten steht, ist nur dann einer, wenn alle gleichzeitig wandern.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — das
neue Modul `structure` wird **verfügbar gemacht, nicht aktiviert**; ein leer aktiviertes Modul
wäre ein Phantom-Gate, und kein neuer Gate-Name entsteht.
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) —
das Muster: **Trockenlauf vor dem Pin**, netzlos, mit ausgewiesener Befund-Differenz.
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) — das
Fragment ist tool-generiert; die vier Handgriffe der Re-Adaption (`docs-check`, `doc-help`-Grep,
`DCHECK_DIGEST`, Kopfkommentar) stehen dort, nicht hier.
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) — der
Eintrag, den dieser Sprung fortsetzt; sein Auflösungs-Trigger ist genau dieser Slice-Typ.

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Das gepinnte d-check-Image steht auf v0.62.0 — an jedem Ort, der den Pin führt, mit dreifach
belegtem Digest und einem netzlosen Trockenlauf, der die Befund-Differenz ausweist.**

Der Sensor hat gefeuert: `make freshness-dcheck` meldet gepinnt **v0.51.1** gegen latest
**v0.62.0** — **elf** Minor-Releases (v0.52.0 vom 2026-08-09 bis v0.62.0 vom 2026-08-21). Der
Sprung ist die Fortsetzung der
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)-Linie
und nichts darüber hinaus.

**Was der Slice ausdrücklich NICHT tut: das Modul `structure` aktivieren.** Ausgeliefert ist es
seit **v0.57.0** — das 20. Regelmodul samt zwölftem `--print-mk`-Target `doc-structure`; mit
v0.62.0 kommt es **hier** an. Es wird damit **verfügbar**, wie `sources` es mit
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) wurde.
Ob dieses Repo eine Struktur-Prüfung will, ist eine Frage an den Prüfbereich und an die Strenge —
sie gehört in einen eigenen Schnitt mit eigenem False-Positive-Risiko, nicht in einen Pin
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 2. Definition of Done

Jeder Punkt nennt das Kommando, das ihn rot färbt, **und welchen Teil der Zusage dieses Kommando
deckt** — eine Zusage reicht nur so weit wie ihr Sensor
([slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7). Wo kein Gate-Lauf rot wird,
steht das hier, statt dass ein Kommando die Lücke verdeckt.

- [ ] **(1) Der Pin steht auf v0.62.0 an allen fünf Orten, die ihn führen — gleichzeitig.**
      [`d-check.mk`](../../../../d-check.mk) (`DCHECK_IMAGE`, `DCHECK_DIGEST`, Kopfkommentar),
      [`Makefile`](../../../../Makefile) (das Tag-Beispiel im Kommentar über `DCHECK_TAG`),
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) (`DefaultImage`/`DefaultDigest`)
      sowie [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline **und** ein
      neuer MR-Eintrag. Der Digest ist **dreifach belegt** — lokaler RepoDigest ·
      `docker buildx imagetools inspect` · d-check-Release —, gemessen am 2026-08-22:
      `sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf`
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

      **Fünf Orte, fünf Kommandos — keines deckt alle, und nur zwei laufen in `make gates`:**

      - `grep -n 'v0\.51\.1\|fede3d02' d-check.mk Makefile internal/emit/emit.go` → **leer**
        (Exit 1) deckt die drei Code-Orte: jeder stehengebliebene Tag und jeder stehengebliebene
        Digest ist ein Treffer. Die Suche ist auf genau diese drei Dateien beschränkt, weil eine
        Suche über den Baum **korrekterweise** nie leer wird — die alte Version steht als
        Fixture-String in
        [`test/component-freshness.bats`](../../../../test/component-freshness.bats), als
        eingefrorener Zeitbezug im Vorgänger-Eintrag und als Ausgangspunkt im neuen Eintrag der
        [`harness/conventions.md`](../../../../harness/conventions.md); der Sprung **heißt**
        v0.51.1 → v0.62.0. Wer diese drei Klassen mitliest, misst nicht den Pin. Handlauf: kein
        Gate fährt ihn.
      - `make test` über [`internal/emit/emit_test.go`](../../../../internal/emit/emit_test.go)
        deckt **einen** Ort, als einziger davon gate-getragen:
        `TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
        `DCHECK_IMAGE`/`DCHECK_DIGEST` aus [`d-check.mk`](../../../../d-check.mk) und fallen, wenn
        der Emitter-Pin nachhinkt. Was sie **nicht** sehen: zwei gleich alte Werte.
      - `make freshness-dcheck` deckt genau diese Blindstelle — es vergleicht den Tag aus
        [`d-check.mk`](../../../../d-check.mk) gegen den neuesten Release und meldet *VERALTET*,
        solange dort v0.51.1 steht. Netzgebunden und nicht in `make gates`; es ist der Sensor, der
        diesen Slice ausgelöst hat, und derselbe Lauf schließt ihn ab.
      - `grep -n 'Image v0\.62\.0' harness/conventions.md` → **eine** Zeile deckt die
        §Baseline-Zeile. Handlauf.
      - `make docs-check` deckt vom neuen MR-Eintrag die **Existenz der Überschrift und die
        Auflösbarkeit des Ankers**, nicht die Version, die beide nennen — und das **nur, sofern**
        die §Baseline-Zeile ihn als Anker-Link nennt: das `anchors`-Modul meldet
        `anchor-missing`, wenn die verlinkte Überschrift fehlt (hermetisch in beide Richtungen
        gemessen — ohne Eintrag ein Befund bei Exit 1, mit Eintrag null Befunde bei Exit 0).
        Diese Kopplung ist der Grund, den Eintrag von der §Baseline-Zeile aus zu **verlinken**
        statt ihn nur anzulegen. **Die Richtigkeit der Version trägt hier kein Kommando:** stehen
        Anker-Link und Überschrift gemeinsam auf einer falschen Version, löst der Anker auf und
        der Lauf bleibt grün; der §Baseline-Handlauf eine Zeile darüber bleibt es ebenfalls, denn
        er liest die §Baseline-Zeile und nicht die Überschrift. Das ist dieselbe Klasse wie die
        Blindstelle von `make test` — zwei Werte, die zueinander stimmen und zur Welt nicht —,
        nur schließt sie hier kein zweites Kommando: die Version im MR-Titel wird gelesen, nicht
        gemessen.

      **Der [`harness/conventions.md`](../../../../harness/conventions.md)-Anteil gehört dem
      Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8): §Baseline-Zeile und MR-Eintrag
      landen in einem **eigenen** Commit, der nur Artefakte dieser Rolle berührt und die Rolle in
      seiner Message nennt.
- [ ] **(2) `d-check.mk` ist frisch aus `--print-mk` (v0.62.0) erzeugt und re-adaptiert; das neue
      Modul `structure` ist verfügbar, aber NICHT aktiviert.** Die
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Handgriffe
      sind vollzogen (`doc-check` → `docs-check` als Target **und** im Hilfetext, `doc-help`-Grep
      auf `docs?-`, `DCHECK_DIGEST` gepinnt, adaptierter Kopfkommentar). Alles Übrige ist
      **verbatim vom Tool** — auch das neue Target `doc-structure` und das neue
      `--disable structure` in den **bestehenden** fokussierten advisory-Recipes (§3 zählt sie).

      **Gebrochen ist die Zusage, sobald eines von dreien eintritt:** `structure` steht in der
      `modules:`-Liste von [`.d-check.yml`](../../../../.d-check.yml)
      (`grep -c 'structure' .d-check.yml` zählt **0** — jede Zahl darüber ist der Bruch);
      `doc-structure` taucht in [`AGENTS.md`](../../../../AGENTS.md) §4 oder
      [`harness/README.md`](../../../../harness/README.md) §Sensors auf (heute in beiden kein
      Treffer — ein dort behaupteter Gate-Name ist genau die Halluzination, die
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
      ausschließt); oder `docs-check` verschwindet aus [`d-check.mk`](../../../../d-check.mk)
      (`grep -c '^docs-check:' d-check.mk` → **1**, und die **0** ist der Bruch — die
      Re-Adaption wäre zurückgefallen; die Gesamtzahl der `docs-check`-Vorkommen taugt nicht als
      Erwartungswert, sie wandert mit dem Kopfkommentar).

      **Für die Modul-Liste dieses Repos gibt es keinen Sensor.** `grep -rl 'd-check.yml' test/`
      nennt **zwei** Dateien (`grep -rn` zeigt darin sieben Zeilen), und keine trägt sie:
      [`test/sources-pin.bats`](../../../../test/sources-pin.bats) koppelt den `sources`-Pin an
      `BASELINE_ZIP_SHA256`, [`test/mutations/04-inscope-filterregel.sh`](../../../../test/mutations/04-inscope-filterregel.sh)
      nennt die Datei als Beispiel für die **emittierte** Seite. Die einzigen
      Modul-Listen-Assertionen im Repo
      ([`internal/emit/emit_test.go`](../../../../internal/emit/emit_test.go),
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go)) halten die
      emittierte Starter-Config fest, nicht die eigene. Der Punkt ist damit ein Handlauf — die
      Lücke ist benannt, der Träger gehört in einen eigenen Schnitt (§6).
- [ ] **(3) Der Pflicht-Trockenlauf ist gefahren und seine Befund-Differenz steht im Closure-Beleg**
      ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster,
      netzlos, `--network none`): v0.62.0 gegen den **unveränderten** Baum mit unveränderter
      [`.d-check.yml`](../../../../.d-check.yml), Exit-Code getrennt erhoben. Erwartet ist eine
      **Differenz, keine Zahl**: beide Versionen liefern über demselben Baum `0 Befund(e)` bei
      Exit 0, und der `diff` der beiden Ausgaben ist leer. Die mitlaufende Dateizahl ist
      ausdrücklich **kein** Erwartungswert — sie wächst mit jedem angelegten Dokument (am
      2026-08-22 innerhalb eines Tages von 330 auf 334) und färbte den Punkt rot, ohne dass am Pin
      etwas gebrochen wäre. Der Lauf ist im Slice zu **wiederholen**, nicht zu übernehmen: eine
      Messung vom Vortag gilt für den Baum vom Vortag.
- [ ] `make gates` grün; dazu `make smoke`, `make full-smoke` und `make mutate` — der Emitter-Pin
      wandert ins **emittierte** Repo, und nur der Voll-Smoke fährt dessen Gate mit v0.62.0.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Was am 2026-08-22 gemessen ist — und was der Slice trotzdem selbst misst

Die Vorab-Messung ist read-only gefahren und steht hier, damit der Schnitt entscheidbar ist:
`--print-mk` von v0.62.0 gegen das heutige [`d-check.mk`](../../../../d-check.mk) ist
**strukturgleich**; die Differenzen sind (a) Tag- und Digest-Zeile, (b) unsere Adaption
`docs-check` gegen das erzeugte `doc-check` samt dem erweiterten `doc-help`-Grep, (c) ein **neues
Modul** `structure` — ein neues Target `doc-structure` und ein zusätzliches `--disable structure`
in **fünf der sechs** fokussierten advisory-Recipes; das sechste **ist** `doc-structure`, es
enabled sein Modul, statt es abzuwählen. Am v0.62.0-Fragment gezählt:
`grep -c -- '--enable' d-check.mk` → **6** Recipes, davon mit `--disable structure`
(`grep -- '--enable' d-check.mk | grep -c -- '--disable structure'`) → **5**. Der Trockenlauf
über den unveränderten Baum liefert `0 Befund(e)`, Exit 0.

**Der Slice wiederholt beides.** Ein Ergebnis von gestern belegt den Baum von gestern; die
explizite `modules:`-Liste in [`.d-check.yml`](../../../../.d-check.yml) immunisiert gegen neue
Default-Module, aber „immunisiert" ist eine Erwartung und der Lauf ist die Messung
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile):
Handbuch ≠ mein Baum).

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Der Pin landet in einem Schnitt; kein zweiter Slice muss mitlanden, damit die
   Aussage stimmt. Eine spätere `structure`-Adoption **setzt** diesen Slice voraus, statt mit ihm
   zu landen.
2. **Gemeinsames Closure-Kriterium?** Nein — ein Trigger darüber schriebe die DoD ab.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv**, und zwar der Musterfall, den
   [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
   Setzung 1 wörtlich nennt: *„Pin ist veraltet"*. Ein Sensor hat gefeuert; keine neue Fähigkeit
   wird gewollt.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss. Der Zustand dieses Slice ist sein Verzeichnis.

### Dogfood **und** emittiert — beide Ebenen, verschiedene Verträge

Der Pin lebt zweimal: als **Dogfood** in [`d-check.mk`](../../../../d-check.mk) (unser eigenes
`docs-check`) und als **Emitter-Default** in
[`internal/emit/emit.go`](../../../../internal/emit/emit.go), von wo aus er in jedes emittierte
Repo geht (Tier-1-Drift, per Go-Test an [`d-check.mk`](../../../../d-check.mk) gekoppelt). Was
**nicht** mitwandert, ist die Modul-Wahl: die emittierte Starter-Config bleibt
`modules: [links, anchors]` — dort ist `structure` so wenig aktiviert wie `sources` oder
`citations` ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
Deshalb steht `make full-smoke` in der DoD: es ist der einzige Lauf, der das emittierte Gate
**mit dem neuen Image** fährt.

### Berührte Dateien — und eine Stelle, die gemessen *nicht* dazugehört

| Datei / Komponente | Änderungs-Art | Wer schreibt | Begründung |
|---|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update (neu erzeugt) | Implementer | v0.62.0-Fragment aus `--print-mk` + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption; `DCHECK_IMAGE`/`DCHECK_DIGEST` neu gepinnt, Kopfkommentar auf den neuen Stand |
| [`Makefile`](../../../../Makefile) | update | Implementer | der Kommentar über `DCHECK_TAG` führt das Tag als Beispiel; ein Kommentar beschreibt, was da ist ([`AGENTS.md`](../../../../AGENTS.md) §3.7) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | Implementer | `DefaultImage`/`DefaultDigest` → v0.62.0; ohne den Nachzug färbt `make test` rot |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | **Architect** | §Baseline-Zeile *d-check: Image v0.51.1* und der neue MR-Eintrag — Adaptions-Block, eigener Commit, Rolle in der Message ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | — | `structure` bleibt un-aktiviert; ein leer aktiviertes Modul wäre ein Phantom-Gate ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| [`test/component-freshness.bats`](../../../../test/component-freshness.bats) | **unverändert — gemessen, nicht vermutet** | — | die Datei nennt `v0.51.1`, führt den Pin aber **nicht**: die Werte gehen als Fixture-Strings in `--compare <name> <gepinnt> <latest>`, der Vergleicher liest [`d-check.mk`](../../../../d-check.mk) nicht (Datei-Kopf: *„HERMETISCH … der Fetch ist im Skript davon getrennt"*). Wer sie mitzieht, ändert eine Fixture, nicht einen Pin |

## 4. Trigger

**`open` → `next`: erfüllt, sofort.** Das Ereignis ist eingetreten — v0.62.0 ist veröffentlicht,
das Image ist lokal inspizierbar (`--print-mk` gefahren, Manifest-Digest gelesen), und
`make freshness-dcheck` steht auf **VERALTET**. Es gibt keine fremde Entscheidung, auf die dieser
Slice wartet.

**`next` → `in-progress`: WIP-Limit frei** — konkret: nach der Closure von
[slice-086](../done/slice-086-vordergrund-per-updatedinput.md), dem einzigen Slice, der
`in-progress/` heute belegt. `ls docs/plan/planning/in-progress/` ist das Prüfkommando; es zeigt
danach nur noch die Roadmap.

Rückführungen:

- `in-progress` → `open`: der Trockenlauf ist **nicht** 0-Befund-differenzfrei — ein neu feuerndes
  Pflicht-Modul, ein Schema-Bruch in [`.d-check.yml`](../../../../.d-check.yml) oder eine
  geänderte Befundklasse über elf Minors. Dann ist zuerst zu entscheiden, **welche** Befunde
  gelten sollen; das ist keine Pin-Frage mehr
  ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
  sieht den Fall vor).
- `in-progress` → `next`: `structure` erweist sich als nicht abwählbar oder zieht Config-Arbeit
  nach sich. Dann trennt ein Re-Schnitt den **Pin** von der **Modul-Entscheidung**; der Pin ist
  einzeln lieferbar, die Entscheidung braucht einen eigenen Prüfbereich.

## 5. Closure-Trigger

DoD vollständig; der Trockenlauf im Slice selbst gefahren und seine Befund-Differenz berichtet;
Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation (Modul 11) bestätigt die DoD;
`make gates`, `make smoke`, `make full-smoke` und `make mutate` grün; Closure-Notiz mit
Steering-Loop-Eintrag.

**Der Link-Zug gehört zu BEIDEN Moves, nicht nur zum letzten.** Jeder `git mv` ist ein eigener,
reiner Move-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3); **nach jedem** folgt der
Link-Reconciliation-Commit — beim Eintritt (`open` → `next` → `in-progress`) wie beim Abgang nach
`done/`. Betroffen sind die eigenen `../`-Links dieser Datei **und** jeder eingehende Verweis.
**Prüfkommando statt Erinnerung:** `make docs-check` nach jedem Move; solange es rot ist, ist der
Zug nicht fertig. Der Grund steht gemessen in
[slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7: dort war der Zug beim
Eintritts-Move nötig und im Plan nicht vorgesehen.

## 6. Risiken und offene Punkte

- **Elf Minors auf einmal sind kein „inerter Bump", bis der Lauf es sagt.** Die bisherigen Sprünge
  dieser Linie waren ein bis vier Minors; hier liegen elf dazwischen, und die Befundklassen können
  sich in jedem geändert haben. Die 0-Befund-Differenz ist deshalb **DoD-Punkt**, nicht Annahme —
  dieselbe Lehre wie in [slice-021](../done/slice-021-dcheck-pin-v0511.md): *„inert" ist zu messen*.
- **Fünf Pin-Orte, zwei Rollen.** Vier Orte trägt der Implementer, den fünften der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Wer den Architect-Anteil in den Implementer-Commit
  nimmt, verletzt die Regel — und wer ihn ganz vergisst, hinterlässt eine §Baseline-Zeile, die
  eine Version behauptet, die nicht mehr läuft.
- **`structure` nicht aktivieren — auch nicht „kurz probieren".** Ein aktiviertes Modul ohne
  entschiedenen Prüfbereich ist entweder ein Phantom-Gate oder eine Befundflut; beides ist eine
  Änderung an der Gate-Strenge und gehört nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 in eine eigene Entscheidung.
- **„`structure` ist nicht aktiviert" hat im Repo keinen Träger — offener Punkt.** Die Aussage ruht
  auf einer Zeile in [`.d-check.yml`](../../../../.d-check.yml), die kein Test liest. Wer das Modul
  versuchsweise aktiviert und die Änderung stehen lässt, wird von keinem Gate gestellt: `structure`
  ist heute unkonfiguriert, und über unkonfiguriertem Prüfbereich meldet es Grün — `make
  doc-structure` fährt es und liefert `0 Befund(e)`, Exit 0, ohne eine Regel angewandt zu haben.
  Am Gate-Ausgang ist dieser Fall nicht von echtem Grün zu unterscheiden, und genau das schließt
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) aus.
  Dieser Slice benennt die Lücke und schließt sie nicht; ein Träger für die Modul-Liste ist ein
  eigener Schnitt.
- **Der Emitter-Pin ist ein öffentlicher Vertrag.** Er landet in fremden Repos. `make smoke` allein
  belegt ihn nicht — es prüft die Emission, nicht den Lauf des emittierten Gates; das tut
  `make full-smoke`. Wer nur den ersten fährt, hat den Pin behauptet, nicht belegt.
- **Eine Zahl im Fließtext, die ihr danebenstehendes Kommando nicht liefert, hat in diesem Repo
  keinen Sensor — offener Punkt über diesen Slice hinaus.** Die Klasse trifft jede Prosa-Behauptung
  neben ihrem Beleg-Kommando, in Plänen wie in Register-Einträgen; ihr Schaden ist nicht die
  falsche Ziffer, sondern was ein Lauf daraus macht, der sie nachzählt: entweder ein falsches Rot
  an einem korrekten Gegenstand oder die Gewohnheit, ausgewiesene Messungen gar nicht erst
  nachzuzählen. **Gemessen ist die Lücke, nicht vermutet:** `make comment-claims` lässt **jede**
  Markdown-Datei dauerhaft außerhalb seines Prüfbereichs
  ([`AGENTS.md`](../../../../AGENTS.md) §4) und prüft ohnehin, ob ein genannter Sensor
  **existiert**, nicht, ob eine Behauptung stimmt; kein Modul des Doku-Gates führt ein Kommando aus,
  gegen dessen Ausgabe eine Zahl im Text stehen könnte.

  **Kandidaten liegen im Bestand, ihre Eignung ist ungeprüft.** `citations` und
  `codepaths.check-lines`
  ([`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines))
  binden Text an eine **Datei-Spanne**; `structure`, mit diesem Pin verfügbar, bindet Abschnitte an
  **Struktur-Invarianten** (verbotenes/gefordertes Muster, geforderte Marken). Alle drei sind
  hermetisch und lesen Dateien — aus ihren Modul-Verträgen gelesen, nicht an diesem Repo erprobt.
  Daraus folgt bestenfalls, dass `structure` die **Form** fordern könnte (eine Zahl nur zusammen mit
  ihrem Kommando im selben Abschnitt); den **Wert** gegen den Lauf zu halten kann keines von ihnen,
  weil keines einen Lauf fährt.

  **Träger, solange kein Sensor existiert:** ein Eintrag im Adaptions-Block von
  [`harness/conventions.md`](../../../../harness/conventions.md), geschrieben vom **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — erkennbar daran, dass sein §Auflösungs-Trigger den
  nächsten Lauf benennt, der ihn zieht, so wie die Pin-Linie ihre Einträge beim nächsten Re-Pin
  zieht. Ohne diesen Träger lebt die Klasse nur in Zeitdokumenten, die kein Lauf wieder aufschlägt.
  **Offen, und hier nicht entschieden:** ob der Sensor einen eigenen Schnitt bekommt — ein
  hermetischer Prüfer in der Bauart von `make comment-claims`, mit Markdown im Prüfbereich — oder
  ob die Adoption von `structure` genügt. Dieser Slice entscheidet sie nicht; er
  stellt sie und bewegt seinen eigenen Prüfbereich nicht.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): Gate-Konfiguration
([`d-check.mk`](../../../../d-check.mk), [`.d-check.yml`](../../../../.d-check.yml)), der
Emitter-Pin in [`internal/emit/emit.go`](../../../../internal/emit/emit.go) und der
Adaptions-Block teilen die adoptierte Harness-Mechanik
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); der
Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

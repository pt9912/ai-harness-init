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

- [x] **(1) Der Pin steht auf v0.62.0 an allen fünf Orten, die ihn führen — gleichzeitig.**
      [`d-check.mk`](../../../../d-check.mk) (`DCHECK_IMAGE`, `DCHECK_DIGEST`, Kopfkommentar),
      [`Makefile`](../../../../Makefile) (das Tag-Beispiel im Kommentar über `DCHECK_TAG`),
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) (`DefaultImage`/`DefaultDigest`)
      sowie [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline **und** ein
      neuer MR-Eintrag. Der Digest ist **dreifach belegt** — lokaler RepoDigest ·
      `docker buildx imagetools inspect` · d-check-Release —, gemessen am 2026-08-22:
      `sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf`
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

      **Fünf Orte, fünf Kommandos — keines deckt alle, und nur zwei laufen in `make gates`.** Die
      zwei sind an der Kette selbst gezählt, nicht aus der Liste abgeleitet:
      `grep '^gates:' Makefile | tr ' ' '\n' | grep -c -x -e docs-check -e test` → **2**; die
      übrigen drei Kommandos stehen in keiner Gate-Kette und sind unten als Handläufe markiert.

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
        deckt **einen** Ort, als eines der zwei gate-getragenen Kommandos dieser Liste (das
        andere ist `make docs-check`, fünfter Spiegelstrich):
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
- [x] **(2) `d-check.mk` ist frisch aus `--print-mk` (v0.62.0) erzeugt und re-adaptiert; das neue
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
- [x] **(3) Der Pflicht-Trockenlauf ist gefahren und seine Befund-Differenz steht im Closure-Beleg**
      ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster,
      netzlos, `--network none`): v0.62.0 gegen den **unveränderten** Baum mit unveränderter
      [`.d-check.yml`](../../../../.d-check.yml), Exit-Code getrennt erhoben. Erwartet ist eine
      **Differenz, keine Zahl**: beide Versionen liefern über demselben Baum `0 Befund(e)` bei
      Exit 0, und der `diff` der beiden Ausgaben ist leer. Die mitlaufende Dateizahl ist
      ausdrücklich **kein** Erwartungswert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2) — sie wächst mit jedem angelegten Dokument und färbte den Punkt rot, ohne dass am
      Pin etwas gebrochen wäre: dieselbe Kette meldete am 2026-08-22 nacheinander **333**
      (Trockenlauf in `d239099`), **335** (Verdikt-Runde), **336** (Gate-Lauf der Verifikation über
      `a89ece4`) und **337** (`make docs-check` an dem Stand, den diese Datei beschreibt, Exit 0). Der Lauf ist im Slice zu **wiederholen**, nicht zu
      übernehmen: eine Messung vom Vortag gilt für den Baum vom Vortag.
- [x] `make gates` grün; dazu `make smoke`, `make full-smoke` und `make mutate` — der Emitter-Pin
      wandert ins **emittierte** Repo, und nur der Voll-Smoke fährt dessen Gate mit v0.62.0.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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

**Die Klasse aus §6 muss diese Datei verlassen haben, bevor die Datei nach `done/` geht — und das
ist ein Prüfkommando, keine Erinnerung.** Mit der Closure wird der Plan ein Zeitdokument; was allein
in ihm steht, schlägt kein Lauf wieder auf. Closure-Kriterium ist deshalb ein Träger **außerhalb**
dieser Datei, im Adaptions-Block, geschrieben vom **Architect**
([`AGENTS.md`](../../../../AGENTS.md) §3.8):
`grep -c 'Eine Zahl im Text steht neben dem Kommando, das sie liefert' harness/conventions.md`
→ **1**, und der Eintrag führt einen Auflösungs-Trigger, der den nächsten Lauf benennt, der ihn zieht
(`grep -c 'fällig beim nächsten d-check-Pin-Sprung' harness/conventions.md` → **1**). Liefert eines
der beiden **0**, ist der Slice nicht abschlussreif — die Frage wäre dann gestellt und nicht
übergeben, und §6 liefe in genau die Ablage, die er selbst als untauglich benennt.

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
  keinen Sensor — die Pflicht dagegen trägt ein Register-Eintrag
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)),
  kein Gate.** Die Klasse trifft jede Prosa-Behauptung
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

  **Der Träger steht, solange kein Sensor existiert:**
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  im Adaptions-Block, geschrieben vom **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8) —
  `grep -c 'Eine Zahl im Text steht neben dem Kommando, das sie liefert' harness/conventions.md`
  → **1**. Der Eintrag setzt zweierlei: die Zahl
  steht im selben Absatz wie das Kommando, das **genau sie** ausgibt, und wer sie schreibt, hat es
  über dem Baum gefahren, von dem sie spricht (Setzung 1); eine Zahl, die mit dem Artefakt
  mitwandert, taugt nicht als Erwartungswert und wird gekennzeichnet oder durch ein Kriterium
  ersetzt, das den Gegenstand misst statt sein Umfeld (Setzung 2). Sein Geltungsbereich ist eng und
  gemessen — **75** lebende repo-eigene Markdown-Dateien
  (`git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | wc -l`);
  Zeitdokumente, vendored Baseline und Templates liegen draußen, und der Cutoff gilt ab
  Einführung: gebunden ist die Zahl, die geschrieben oder geändert wird, der Bestand ist kein
  Arbeitsauftrag.

  **Die Entscheidung ist damit übergeben, nicht mehr nur gestellt.** Welcher der drei Wege gilt —
  ein eigener hermetischer Prüfer in der Bauart von `make comment-claims` mit Markdown im
  Prüfbereich, die Adoption eines d-check-Moduls für die **Form** bei ausdrücklich ungedecktem
  **Wert**, oder bewusste Permanenz im Feedforward-Quadranten —, steht als Auflösungs-Trigger im
  Eintrag selbst und wird beim **nächsten d-check-Pin-Sprung fällig**
  (`grep -c 'fällig beim nächsten d-check-Pin-Sprung' harness/conventions.md` → **1**); früher,
  sobald `grep -c 'structure' .d-check.yml` über **0** steigt. Das Ereignis meldet sich selbst:
  `make freshness-dcheck` steht dann auf *VERALTET*, und der Slice, der den Pin zieht, schlägt den
  Adaptions-Block ohnehin auf. Dieser Slice entscheidet die Frage nicht und bewegt seinen eigenen
  Prüfbereich nicht; er sorgt dafür, dass sie nicht mit ihm in die Ablage geht (§5).

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Das gepinnte d-check-Image steht auf **v0.62.0** — an allen fünf Orten, die den Pin
führen, mit dem dreifach belegten Digest
`sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf`. Das Modul `structure`
ist damit **verfügbar und nicht aktiviert**, und kein neuer Gate-Name ist entstanden. Der Sensor,
der den Slice ausgelöst hat, meldet ihn selbst geschlossen: `make freshness-dcheck` →
*„d-check: aktuell — gepinnt und latest sind beide v0.62.0."*, Exit 0. Das Gefäß des Ergebnisses
ist [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) —
Pin, Trockenlauf, und die Strenge-Bilanz **an der Quell-Differenz der Regeldateien** statt am
0-zu-0-Lauf; die Lehre dieses Slice trägt
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
Die Linie
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)
ist fortgesetzt und nicht erweitert.

**Vier beobachtbare Closure-Kriterien.**

1. **Der Pin steht, an jedem Ort einzeln gemessen.** Die drei Code-Orte:
   `grep -n 'v0\.51\.1\|fede3d02' d-check.mk Makefile internal/emit/emit.go` → **leer**, Exit 1.
   Der vierte, die §Baseline-Zeile: `grep -c 'Image v0\.62\.0' harness/conventions.md` → **1**. Der
   fünfte, der MR-Eintrag, liegt im Architect-Commit `d678de7` und trägt seit `c53d849` das Bein,
   auf dem seine Strenge-Bilanz ruht
   (`grep -c 'Welches der zwei Beine die Bilanz trägt' harness/conventions.md` → **1**). Dass
   `structure` verfügbar und **nicht** aktiviert ist, tragen zwei Kommandos:
   `grep -c 'structure' .d-check.yml` → **0** (Exit 1) und
   `grep -c 'doc-structure' AGENTS.md harness/README.md` → je **0** — kein behaupteter Gate-Name
   ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
   Die Re-Adaption steht: `grep -c '^docs-check:' d-check.mk` → **1**,
   `grep -c -- '--enable' d-check.mk` → **6**, davon
   `grep -- '--enable' d-check.mk | grep -c -- '--disable structure'` → **5**.
2. **Der Trockenlauf ist im Slice gefahren, und die Differenz ist die Aussage, nicht die Zahl.**
   Beide Digests über **denselben** Baum, netzlos (`--network none`), Exit-Code getrennt erhoben:
   im Werkstück-Commit `d239099` über dem Baum `f961b4e` je `333 Datei(en) geprüft, 0 Befund(e)`,
   Exit 0, `diff` der Ausgaben leer; in der Verdikt-Runde über dem Baum `cc7d3bf` unabhängig
   wiederholt, je `335 Datei(en) geprüft, 0 Befund(e)`, Exit 0, `diff` leer. Die Dateizahl ist
   zwischen beiden Läufen gewandert, die **Differenz** nicht — genau das hat DoD (3) zugesagt und
   die mitwandernde Zahl ausdrücklich ausgenommen
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2).
3. **Das Review ist frei, nach drei Runden mit je ausgestelltem Verdikt — und die Klasse, die es
   gefunden hat, hat einen Träger außerhalb dieser Datei.**
   [Runde 1](../../../reviews/2026-08-22-slice-088-review.md) (`c89612f`, 1 HIGH / 3 MEDIUM /
   3 LOW / 1 INFO, blockierend) → [Runde 2](../../../reviews/2026-08-22-slice-088-bestaetigungsrunde.md)
   (`f65e2fa`, alle acht aufgelöst, 1 MEDIUM / 2 LOW / 1 INFO neu, blockierend) →
   [Runde 3](../../../reviews/2026-08-22-slice-088-verdikt-runde.md) (`3fa27b2`, **frei**, 2 LOW).
   Über die drei Runden zählt
   `grep -h '^### \(HIGH\|MEDIUM\|LOW\|INFO\)-' docs/reviews/2026-08-22-slice-088-*.md | wc -l`
   → **14** Findings; die blockierende Menge jeder Runde ist vor dem nächsten Verdikt gezogen
   (`abe01f4`, `cc7d3bf`), keine Kategorie ist gestiegen. Der Träger, den §5 als Closure-Kriterium
   führt, liegt vor:
   `grep -c 'Eine Zahl im Text steht neben dem Kommando, das sie liefert' harness/conventions.md`
   → **1** und `grep -c 'fällig beim nächsten d-check-Pin-Sprung' harness/conventions.md` → **1**.
4. **Die Verifikation (Modul 11) bestätigt die DoD mit selbst gefahrenen Sensoren.**
   [Report](../../../reviews/2026-08-22-slice-088-verify.md) (`4663bc9`): **DoD (1)–(5) bestätigt,
   DoD (6) bestätigt mit einem nicht blockierenden Befund am Beleg des Steering-Loop-Eintrags.** Der
   Verifier hat `make gates`, `make mutate`, `make smoke`, `make full-smoke` und
   `make freshness-dcheck` selbst gefahren, zwölf Mess-Aussagen dieser Notiz einzeln nachgezählt und
   vier Rot-/Grün-Sonden in einer isolierten Kopie außerhalb des Repos gegen die Abdeckungsgrenzen
   gesetzt, die DoD (1) für sich selbst zieht.

**Wo der Liefergegenstand in der Historie liegt.**
`git log --oneline --grep='slice-088' 04067d7 | wc -l` zählt **15** Commits — der Stand gehört ins
Kommando, denn ohne ihn wandert die Zahl mit jedem Closure-Commit weiter und ist kein
Erwartungswert. Der Schnitt liegt in `251e9ca`; das Werkstück in `d239099`
(`d-check.mk` aus `--print-mk` v0.62.0 samt den vier
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Handgriffen,
der Emitter-Pin in [`internal/emit/emit.go`](../../../../internal/emit/emit.go), das Tag-Beispiel im
[`Makefile`](../../../../Makefile)-Kommentar), seine zwei Korrekturen in `1f3f6e6` (`structure` kam
mit v0.57.0, nicht mit v0.62.0) und `5e96bd4` (fünf von sechs Recipes). Der Architect-Anteil liegt
in `d678de7` (der Pin-Eintrag), `c53d849` (zwölf Targets in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), die
Strenge an der Quell-Differenz) und `04067d7`
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
samt dem tragenden Bein der Bilanz); die drei Verdikte in `c89612f`, `f65e2fa`, `3fa27b2`;
die zwei Planner-Nachzüge in `abe01f4` und `cc7d3bf`. Die Lifecycle-Commits `3ea7a64`
(`open → next`) und `6551545` (`next → in-progress`) sind reine Moves, `6766cf2` und `f961b4e` die
Link-Züge danach. Wer den Slice sucht, findet ihn über diese Commits und **nicht** in der Roadmap:
`grep -c 'slice-088' docs/plan/planning/in-progress/roadmap.md` → **0** (Exit 1), wie
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 es verlangt; Setzung 3 lässt auch die Closure spurlos an ihr vorbeigehen. Der Zustand ist
das Verzeichnis.

**Was der Slice nicht deckt.**

- **Die Richtigkeit der Version im MR-Titel trägt kein Kommando.** Stehen Anker-Link und
  Überschrift gemeinsam auf einer falschen Version, löst der Anker auf, `make docs-check` bleibt
  grün, und der §Baseline-Handlauf ebenfalls, weil er die §Baseline-Zeile liest und nicht die
  Überschrift. Die Verdikt-Runde hat das mit einer Sonde am HEAD reproduziert (beide Seiten auf
  `v0.61.0`, Lauf grün bei Exit 0). Die Lücke ist in DoD (1) benannt und bleibt offen; sie ist die
  **Wert**-Hälfte, die auch
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  für seinen Weg (b) ausdrücklich ungedeckt lässt.
- **Die Modul-Liste der Dogfood-[`.d-check.yml`](../../../../.d-check.yml) liest kein Test.** Wer
  `structure` versuchsweise aktiviert und die Änderung stehen lässt, wird von keinem Gate gestellt:
  über unkonfiguriertem Prüfbereich meldet das Modul Grün, und am Gate-Ausgang ist dieser Fall von
  echtem Grün nicht zu unterscheiden. Benannt in §6, hier nicht geschlossen.
- **`.mk`-Dateien liegen außerhalb des `ids`-Prüfbereichs.** Die baren `MR-`-Kennungen im Kopf von
  [`d-check.mk`](../../../../d-check.mk) erzeugen nie einen Befund; kein Handgriff dieses Slice
  ändert daran etwas.
- **Kein Modul wurde aktiviert und keine Strenge gesenkt.** Der Slice berührt
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 nicht — die Bilanz dazu hängt an der Versions-Differenz
  der Regelmodule und steht in
  [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar),
  nicht hier.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Eine gemessene Aussage lebt so oft, wie sie geschrieben wurde. Ihre Korrektur ist erst fertig,
wenn die Fundort-Suche über die lebenden Artefakte leer ist — ein Fix an einem Ort ist keiner.**
Wer den gemeldeten Fundort repariert, hat den Befund beantwortet, nicht die Aussage; der zweite
Fundort widerlegt danach den ersten, und beide stehen im Repo nebeneinander.

**Gemessen an diesem Slice, nicht postuliert.** Die Aussage *„wie viele der fokussierten
advisory-Recipes disablen `structure`"* stand an **vier** Fundorten: im Kopfkommentar von
[`d-check.mk`](../../../../d-check.mk), in
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar), in §3
dieses Plans und in seiner DoD (2). Sie fiel **zweimal in Folge an verschiedenen Orten**: R1-HIGH-1
traf den Kopfkommentar (gezogen in `5e96bd4`), R2-MEDIUM-1 denselben Satz in §3 (gezogen in
`cc7d3bf`, zusammen mit DoD (2)). Erst die dritte Runde konnte die Fundort-Suche leer melden —
über die drei Artefakte, die die falsche Fassung tragen konnten:
`grep -n 'jedem fokussierten' d-check.mk Makefile harness/conventions.md` → **leer, Exit 1**,
heute erneut gefahren. **Diesen Plan nimmt die Suche nicht mit, und das ist ihre Bedingung, kein
Auslassen:** er zitiert die getilgte Formulierung in der Kommandozeile darüber, und mit ihm als
vierter Datei liefert dasselbe Kommando **Exit 0 mit genau einem Treffer — der Zeile, auf der es
selbst steht** (ebenfalls gefahren). Eine Suche nach einer getilgten Formulierung wird in dem
Dokument, das die Formulierung zitiert, per Konstruktion fündig; wer den Zitat-Fall nicht am
Fundort benennt, legt einen Treffer vor, der das Gegenteil dessen belegt, was er zeigen soll —
derselbe Griff wie in
[der Messung zu slice-086](../../../reviews/2026-08-21-updatedinput-messung.md) §4.
Deckungsgleich sind die vier Fundorte in **Quantor und Zahl, nicht in viermal derselben Zahl**: die
Zahlen tragen zwei davon — der Kopfkommentar von [`d-check.mk`](../../../../d-check.mk)
(*„von den sechs … disablen FUENF"*) und §3 dieses Plans (*„fünf der sechs"*), beide gegen
`grep -c -- '--enable' d-check.mk` → **6** und
`grep -- '--enable' d-check.mk | grep -c -- '--disable structure'` → **5** gemessen —, während
DoD (2) für die Zählung auf §3 verweist und
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) den
Quantor ohne Zahl führt (*„in den bestehenden fokussierten advisory-Recipes"*).
**Nicht die Reparatur war langsam, sondern ihre Reichweite:**
`git log -1 --format='%ad' --date=format:'%H:%M' <sha>` liest für den Befund `c89612f` und für seine
Korrektur `5e96bd4` **dieselbe** Minute (11:20) — und bis zum freien Verdikt `3fa27b2` (12:03)
brauchte es trotzdem zwei weitere Runden, weil die falsche Fassung nach dem Fix am gemeldeten Ort
in §3 wörtlich stehenblieb: `git show cc7d3bf` zieht sie dort und schärft DoD (2) im selben Zug
nach.

**Anwendung, prüfbar am Text:** Wer eine gemessene Aussage korrigiert, nennt im selben Zug die
**Fundort-Suche** und ihr Ergebnis — ein Muster, das die Aussage trifft, über die **lebenden**
Artefakte; Zeitdokumente bleiben draußen, sonst wird die Suche per Konstruktion fündig und beweist
nichts. Die Probe ist eine Frage an den eigenen Commit: **an wie vielen Orten steht dieser Satz,
und welches Kommando zeigt, dass keiner übrig ist?** Fällt die Antwort auf „ich habe die gemeldete
Stelle geändert", ist die Korrektur nicht fertig, sondern der nächste Befund.

**Ebene und Träger, benannt statt behauptet.** Die Regel gilt der **Repo**-Ebene, für jede Rolle,
die eine gemessene Aussage schreibt oder zieht; über den emittierten Harness sagt sie nichts.
**Kein Sensor sieht sie:** `make comment-claims` führt in seinem Prüfbereich **null**
Markdown-Dateien
(`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c '\.md$'`
→ **0**, Exit 1), und `make docs-check` prüft Links, Anker, Kennungen, Matrix, Codepfade und
Spans — kein Modul vergleicht zwei Prosa-Stellen miteinander. **Zwei Träger stehen, ein dritter ist
benannt:** (a) den Fundort-Fall dieses Slice trägt
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
§Auflösungs-Trigger, der seit `c53d849` einen **fünften** Handgriff führt — die Target-Aufzählung
beim nächsten Re-Pin gegen `make doc-help` abgleichen; (b) den Schreib-Fall trägt
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1, die die Zahl an ihr Kommando bindet, bevor sie sich vervielfältigen kann; (c) den
Zieh-Fall trägt der nächste Schnitt derselben Bauart, und er liegt geschnitten vor:
[slice-089](../open/slice-089-carveout-co-002-ueberfuehren.md) DoD (2) zieht **sechs** Zeiger auf
denselben Gegenstand und nennt als rot färbendes Kommando genau eine Fundort-Suche
(`grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → **leer**). Ohne
diesen Griff bliebe der Eintrag ein Satz in einer Datei, die niemand wieder liest.

**Drei Beobachtungen, die keine Regel werden — mit ihrem Ort.**

- **Eine Abdeckungs-Zusage, die nur Existenz prüft, ist keine über Richtigkeit.** `make docs-check`
  deckt vom MR-Eintrag die Existenz der Überschrift und die Auflösbarkeit des Ankers; die Version,
  die beide nennen, deckt es nicht — mit Sonde belegt, oben unter *Was der Slice nicht deckt*
  eingeordnet. Das ist der Anwendungsfall der Regel aus
  [slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7 (*eine Zusage reicht nur so
  weit wie ihr Sensor*), keine neue Regel; DoD (1) sagt die Grenze inzwischen selbst.
- **Ein Beleg-Lauf, der vorher wie nachher `0` liefert, ist in der Lockerungsrichtung
  informationsleer.** Der Trockenlauf trägt eine Richtung — über diesem Korpus entsteht kein neuer
  Befund —, und er kann nicht zeigen, dass eine Regel weniger findet. Die §3.5-Frage brauchte
  deshalb das zweite Bein, die Quell-Differenz der Regeldateien. Getragen wird das bereits, in
  [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
  §Auflösungs-Trigger (*„an der Quell-Differenz der Regeldateien, nicht an der
  CHANGELOG-Aufzählung"*); hier steht es als Beobachtung mit Zeiger.
- **Die Klasse, die diesen Slice über drei Runden begleitet hat, ist nicht mehr seine.** *Eine Zahl
  im Fließtext, die ihr danebenstehendes Kommando nicht liefert* trägt seit `04067d7` der
  Adaptions-Block
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)),
  mit gemessener Begründung, engem Geltungsbereich, Cutoff und einem Auflösungs-Trigger, der fällig
  wird statt zu mahnen. Für diesen Slice bleibt sie eine Beobachtung mit Zeiger — die Entscheidung
  über ihren Sensor steht unten in der Tabelle.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die Bestätigung der DoD durch Modul 11 und die nicht gate-getragenen Kommandos der DoD (1)/(2) — die Rest-Suche `grep -n 'v0\.51\.1\|fede3d02' …`, `make freshness-dcheck` (netzgebunden) und `grep -n 'Image v0\.62\.0' harness/conventions.md` | **erledigt** mit `4663bc9`: der Verifier hat sie mit eigenem Prüf-Artefakt selbst gefahren; für die Buchführung festgehalten, nicht als offener Posten |
| Die `--print-mk`-Fixture [`internal/emit/testdata/raw-print-mk.txt`](../../../../internal/emit/testdata/raw-print-mk.txt) trägt die v0.46.0-Form: `grep -cE '^docs?-[a-z-]+:' internal/emit/testdata/raw-print-mk.txt` → **11** Targets gegen `grep -cE '^docs?-[a-z-]+:' d-check.mk` → **12** im heutigen Fragment, `grep -c 'doc-structure\|disable structure' internal/emit/testdata/raw-print-mk.txt` → **0** (Exit 1) | **Planner**, eigener Schnitt: ob eine sechzehn Minors alte Fixture die Adaptions-Logik noch repräsentiert. Kein Pin-Ort und kein DoD-Bruch — sie ist Parser-Eingang von `TestAdaptMK_Fixture`, und das Ziel-Fragment entsteht zur Bootstrap-Zeit aus dem gepinnten Image |
| Die Entscheidung aus [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Auflösungs-Trigger: eigener hermetischer Prüfer · Adoption eines d-check-Moduls für die Form · bewusste Permanenz | **Auftraggeber** / Planner (Schnitt-Entscheidung). Davor gehört ein **Probelauf**: heute liegt nur der Modul-Vertrag vor, kein Ergebnis an diesem Repo. Fällig beim nächsten d-check-Pin-Sprung, früher, sobald `grep -c 'structure' .d-check.yml` über **0** steigt |
| R1-INFO-1 — für die `modules:`-Liste der Dogfood-[`.d-check.yml`](../../../../.d-check.yml) gibt es keinen Sensor; ein unkonfiguriertes Modul ist am Gate-Ausgang von echtem Grün nicht zu unterscheiden | **Planner**, eigener Schnitt. Der Prüfbereich ist zu entscheiden, bevor ein Wächter entsteht — sonst friert er eine Liste ein, die noch wandert |
| R1-LOW-3 — `.mk`-Dateien liegen außerhalb des `ids`-Prüfbereichs; die baren `MR-`-Kennungen in [`d-check.mk`](../../../../d-check.mk) erzeugen nie einen Befund | **Architect**, benannt für einen künftigen Schnitt; keine Aktion in diesem Slice |
| Die Version im MR-Titel wird gelesen, nicht gemessen — für die **Wert**-Hälfte steht kein Kommando | keiner, und das ist entschieden: [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) sagt für Weg (b) ausdrücklich, dass der Wert ungedeckt bleibt. Ein Träger entstünde nur mit Weg (a) |
| R2-INFO-1 — [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) stützte seine Lockerungs-Hälfte auf eine CHANGELOG-Aufzählung, die upstream selbst als offen ausweist | **erledigt** mit `04067d7`: `grep -c 'Welches der zwei Beine die Bilanz trägt' harness/conventions.md` → **1**. Für die Buchführung festgehalten, nicht als offener Posten |

**Gates.** Der [Verifikations-Lauf](../../../reviews/2026-08-22-slice-088-verify.md) auf `a89ece4`
hat sie selbst gefahren, Exit-Codes getrennt erhoben: `make gates` **Exit 0** —
`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 336 Datei(en) geprüft, 0 Befund(e)`,
`1..143` bats (`grep -c '^ok '` → 143, `grep -c '^not ok'` → 0),
`comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check` ok —, dazu `make mutate`
**Exit 0** mit `143 ok, 0 Befund(e)`, `make smoke` **Exit 0** (emittiertes `docs-check`:
12 Dateien, 0 Befunde) und `make full-smoke` **Exit 0**, wobei das **emittierte** Gate nachweislich
gegen `d-check@sha256:3996a593…` lief (`grep -c '3996a593' <log>` → **7** Recipe-Zeilen des
emittierten `docs-check`). Der Stempel band den Lauf an den Baum, nicht an eine Erinnerung:
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` waren
byte-gleich (`4d85066…`), und `record-gates` schreibt ihn nur als **letzter** Prerequisite grüner
Gates ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)).
Diese vier Läufe sind in dieser Notiz **nicht wiederholt**; sie gehören dem Stand, den der Stempel
bindet.

Selbst gefahren und über den Baum, von dem sie sprechen: `make docs-check` →
`d-check: 337 Datei(en) geprüft, 0 Befund(e)`, Exit 0 (getrennt erhoben; das Rezept zeigt den
Digest `sha256:3996a593…` in seiner Kommandozeile) und `make freshness-dcheck` →
*„d-check: aktuell — gepinnt und latest sind beide v0.62.0."*, Exit 0 — der Sensor, der den Slice
geöffnet hat, schließt ihn. Die Dateizahl ist dabei **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): dieselbe Kette meldete am 2026-08-22 nacheinander 333, 335, 336 und 337, ohne dass am
Pin etwas gebrochen wäre. Diese Notiz macht den Stempel ungültig; der volle `make gates`-Lauf gehört zum
Commit, der sie trägt, nicht zu ihr.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): Gate-Konfiguration
([`d-check.mk`](../../../../d-check.mk), [`.d-check.yml`](../../../../.d-check.yml)), der
Emitter-Pin in [`internal/emit/emit.go`](../../../../internal/emit/emit.go) und der
Adaptions-Block teilen die adoptierte Harness-Mechanik
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); der
Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

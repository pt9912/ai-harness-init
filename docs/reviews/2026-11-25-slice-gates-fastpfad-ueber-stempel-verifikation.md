# Verifier-Report: slice-gates-fastpfad-ueber-stempel — 2026-11-25

**Verifikation gegen DoD + Spec/ADR** (Modul-11-Frage: „Bauen wir es richtig?"; der
Reviewer-Report `docs/reviews/2026-11-25-slice-gates-fastpfad-ueber-stempel.md`
prüfte Code gegen Plan + ADR und ist getrennt).

**Gegenstand:** Slice `slice-gates-fastpfad-ueber-stempel` · Implementer-Range
`d3811ccd..5ddbbc8d` (4 Commits: `4fe21917` Fast-Pfad-Einsprung + Kante umgefasst,
`f892861b` Fälle 784/785, `ee94dd40` Sensor-Prosa + Zelle→Link, `5ddbbc8d` Fälle
211/212 an die Wrapper-Form) · ADR-0099 (`f1071d76`, `Accepted`) ·
Review-Report (`28da4709`) · Welle-Eröffnung (`747fff1c`, `HEAD`).

**Basis-Regeln:** [ADR-0099](../plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) (Festlegungen 1–4) — Kern · [ADR-0099](../plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
· [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(fail-closed) · [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
/ [`MR-091`](../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
(Fall-Anlage/Anker/CI-Branch) · [`spec/architecture.md` §5](../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
(Ordnungskante, unverändert).

---

## Mutations-Ergebnis vom CI-Branch (vorgelesen, dann gelöscht)

- Branch gelesen: `git fetch origin mutate/slice-gates-fastpfad-ueber-stempel-28da4709 && git show FETCH_HEAD:mutate-ergebnis.txt`
  — **Urteil: `gruen`**, **Fallmenge 23 (Slice: 23)**, alle 23 `ok`,
  Wanduhr 380 s, 10 Shards Exit 0.
- **Geprüfter Commit: `28da4709cc…`** — das ist der Review-Report-Commit über dem
  Implementer-Range (`5ddbbc8d`) und ADR-0099; er trägt den verifizierten Code voll.
  Die vier Slice-Fälle (784, 785, 211, 212) sind in den Shards 0/1/2/7/8 einzeln
  aufgeführt. [`MR-091`](../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  Setzung 1 ist damit vor der Verifikation erfüllt.
- Branch danach gelöscht: `git push origin --delete mutate/slice-gates-fastpfad-ueber-stempel-28da4709`
  → `[deleted]`; `git ls-remote origin 'refs/heads/mutate/slice-gates-fastpfad-ueber-stempel*'`
  → 0 Treffer. Kein älterer Branch desselben Slice existierte.

## Verdikt je DoD-Punkt (§2 des Slice-Plans)

**DoD 1 — Fast-Pfad-Verdrahtung: bestätigt.**

- **Code-Lesung:** `harness/tools/gates-fast.sh` — SKIP nur in `entscheide()`
  über **beiden** Vergleichen ("[ \"$stamp_diff\" = \"$ist_diff\" ]",
  "[ \"$stamp_head\" = \"$ist_head\" ]") **und** beiden Form-Wächtern
  (`stammt_aus_baum` 64 Hex von `working-tree-hash.sh`, `stammt_von_head`
  SHA 40–64 Hex oder `kein-commit`); `kein-commit` wird wie eine SHA verglichen
  (ADR-0099 Festlegung 1). Jede Unform → Exit 1 → `exec make record-gates`
  (Festlegung 4, MR-017). `head_wert` ist Funktext-identisch mit
  `record-gates.sh` und `.claude/hooks/stop-require-gates.sh` (Kopplung, vom Wächter
  `kopplung: head_wert ist in drei Fassungen gleich` am gelebten Bestand gehalten).
- **Spot-Checks über den realen Weg, selbst gefahrt** (Kopie `/tmp/verify-fast`,
  `make`-Shim, der nur die Weiterleitung `make record-gates` sichtbar macht und
  alles andere an echtes make durchreicht — Voll-Läufe nicht angefahren):
  - **A) gedecktes Paar, über `make gates`** → `gates: SKIP — der Gate-Stempel
    (…diffsha + …head) deckt Arbeitsbaum-Hash und HEAD…` · Exit 0.
  - **B) fremder diffsha-Stempel** → `WEITERLEITUNG: exec make record-gates
    (voller Lauf)` — fail-closed.
  - **C) head-Stempel fremd** → Weiterleitung — fail-closed.
  - **D) gedecktes Paar + `GATES_FORCE=1`** → Weiterleitung (Festlegung 3).
  - **E) direkter Aufruf `bash harness/tools/gates-fast.sh` am echten Baum**
    → SKIP-Meldung, zweite Zeile nennt den benannten Rest wörtlich: *„Rest, den
    kein baum-abgeleiteter Schluessel deckt (ADR-0099 Festlegung 2): der lokale
    Docker-Cache-Zustand und die Host-Werkzeuge (bash, tar, git, docker).
    GATES_FORCE=1 erzwingt den vollen Lauf."* · Exit 0.
  - **Nebenbeobachtung (Risiko-4-Ausgang direkt am realen Wächter):** eine einzelne
    untrackte Zusatzdatei in der Kopie senkte den Baum-Hash daneben (`d66f8848…`
    → `3391d724…`) und die Stempel wurden ungedeckt — fail-closed, voller Lauf.
- **Wo die Zusage gemessen ist:** die Form-Zusage über den **Lauf** misst der
  direkte Aufruf am Skript (E oben); die **Verdrahtung in `make gates`** ist
  strukturell an
  [`test/gate-nachweis-kante.bats`](../../test/gate-nachweis-kante.bats) (Zusage 2:
  `gates` an keinen Voraussetzungen, Rezept genau eine nichtleere Zeile
  `@bash harness/tools/gates-fast.sh`) und an
  [`test/gates-fastpfad.bats`](../../test/gates-fastpfad.bats) (Weiterleitung
  `exec make record-gates`, kein Stempel-Schreiben) — und am Lauf zusätzlich durch
  die Spot-Checks A/B oben belegt; `make -n gates` gibt genau die eine
  Wrapper-Zeile. Die **reale Rot-vor/Gruen-nach-Lage** am vollen Pfad trägt
  `make gates` selbst (Skript-Kommentar benennt es; Wächter-Sensor dafür
  existiert nicht und ist nirgends behauptet).
- **bats 12/12:** `test/gates-fastpfad.bats` trägt 12 Tests
  (`grep -c '@test'` → 12), alle in der grünen CI-Suite des geprüften Commits.
- **Grenze, benannt:** die Negative-Klasse „HEAD unaufösbar (Git-Fehler)" ist
  fixture-mäßig nicht hermetisch testbar (das bats-Image führt kein `git`); sie
  liest im Code fail-closed (`if ! ist_head="$(head_wert)"` → voller Lauf) und ist
  im Skriptkopf benannt — Lücke, kein Wächter-Defekt.

**DoD 2 — Zahn-Nachweis je Richtung: bestätigt.**

- Die zwei neuen Fälle sind am Kopf von `test/mutations/784-gates-fast-skip-ohne-gedecktes-paar.sh`
  und `785-…` verankert: 784 macht aus dem Deckungsvergleich einen Blankoscheck
  (`[ "$stamp_diff" = … ]` → `true`), 785 verschiebt den FORCE-Vergleich von `1`
  auf `0`. Beide nennen den erwarteten Rot-Grund im Kopf; die
  Anlage-Disziplin (`# files: harness/tools/gates-fast.sh`, sed-Anker gegen den
  Quell-Bestand, `expect:`-Zeile) ist vollständig.
- **Selbst gefahrene lokae Rot-Belege** (`make mutate MUTATE_CASES='784-… 785-…'`,
  ~192 s je Fall am Sensor `test-bats`, Grün-Vorläufe je ~190 s):
  `ok 784-gates-fast-skip-ohne-gedecktes-paar -> fastpfad: fremder Hash am
  diffsha-Stempel -> voller Lauf (fail-closed) rot` · `ok 785-… -> fastpfad:
  GATES_FORCE=1 ueber gedecktem Paar -> voller Lauf rot` ·
  **2 ok, 0 Befund(e)**. Die Deckungsgleichheits-Zusage der alten Kante (
  `make -n gates` ⟷ `make -n record-gates`) wurde im Commit `4fe21917` an die
  Wrapper-Form umgezogen — 5 Zustände umgezogen, keine gestrichen; der Wächter
  misst den **Zustand** (keine Voraussetzungen am `gates`, Rezept-Zeile, Kanten-
  Liste sortiert gegen Erwartungsliste, `baseline-verify` erster), nicht die
  heutige Implementierung.
- **Bestandsfälle 211/212** an der Wrapper-Form gezogen (Commit `5ddbbc8d`):
  211 `s/^gates: ##/gates: compile ##/` → erwartet rot
  `gate-nachweis: gates haengt an keinen make-Voraussetzungen (Fast-Pfad-Form)` —
  in CI-Shard 1 `ok`; 212 alle `exec make record-gates`-Zeilen → `exit 0` →
  erwartet rot `verdrahtung: der Wrapper faehrt bei Nicht-Deckung genau make
  record-gates` — in CI-Shard 2 `ok`. Der anfänglich zu breite Anker von 212
  (Waechter blieb grün) wurde als Befund sichtbar, verengt und neu rot gesehen —
  MR-071/§3.6-Mechanik hat das selbst aufgedeckt.
- **Kanten-Sensor:** `make mutate-greift` voll gefahren →
  **771 Fall/Faelle, 771 greifen, 0 Befund(e)** — jeder Fall-Patch ändert seine
  `# files:`-Datei (MR-071, Kanten-Hälfte).

**DoD 3 — README-Zelle + `harness/sensors/gates.md`: bestätigt.**

- [`harness/README.md`](../../harness/README.md) §Sensors, Zelle `make gates`:
  nennt den Fast-Pfad („SKIP über dem gedeckten Stempel-Paar, sonst voll") und
  trägt [ADR-0099](../../docs/plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
  als Bindung; die Prosa steht als Link auf
  [`harness/sensors/gates.md`](../../harness/sensors/gates.md).
- Die Prosa trägt die Grenze vollständig: §Der benannte Rest (Docker-Cache,
  Host-Werkzeuge, Wortlaut ADR-0099 Festlegung 2) und §Grenze — der SKIP urteilt
  nie über das hinaus, was er sicher lesen kann; die Deckung bei künftigen Checks
  im Kanten-Satz tragen die **Re-Evaluierungs-Trigger der ADR**, nicht ein
  Wächter (ADR-0099 §Fitness Function: *„Was hier nicht behauptet wird"*). Kein
  Sensor für diese Klasse ist behauptet — Deckung von Zusage und Sensor-Pauschale
  schließt.
- Zusätzlich: `gates`-Target-Zeile im Makefile nennt ADR-0099
  (`Makefile:736`); die `record-gates:`-Zeile ist byte-gleich geblieben (12 Checks,
  `baseline-verify` erster — vom Kanten-Wächter gehalten); die
  `FORM SEIT ADR-0099`-Marke am Makefile trägt den Vorgang als Zustand, nicht als
  Chronik.

**DoD 4 — `make gates` grün: bestätigt (Stempel deckt HEAD; eigener Lauf nicht
gefahren).**

- `[ "$(cat .harness/state/gates-passed.head)" = "$(git rev-parse HEAD)" ]` →
  `747fff1c914389ca…` = `HEAD`. Der `diffsha`-Stempel deckt den Arbeitsbaum:
  `cat .harness/state/gates-passed.diffsha` → `d66f8848…`, und
  `bash harness/tools/working-tree-hash.sh` am selben Baum liefert `d66f8848…`
  (beide selbst gemessen am verifizierten Stand; `record-gates` ist alleiniger
  Schreiber, der Stempel belegt einen grünen Vollauf über genau diesem Baum).
- Ein eigener weiterer `make gates`-Lauf wurde laut Auftrag nicht gefahren — der
  Stempel-Nachweis trägt; nach dem Commit dieses Reports wird der nächste
  `make gates`-Lauf fail-closed voll fahren (beobachtbar, wie im Plan §5 notiert).

**Resultat:** alle vier Code-DoD-Punkte bestätigt; die übrigen §2-Punkte (Review,
Doku-Update für den berührten Vertrag, Closure-Notiz, Register, Risiko-Ausgänge,
Paarungen) sind **Closure-Arbeit des Planners** — kein Verifier-Gegenstand; ihr
Stand ist unten notiert.

---

## Plan-vs-Code

- **§3-Zeile „README-Zelle" wich ab:** statt der Prosa in der Zelle trägt die
  Zelle einen Link auf `harness/sensors/gates.md`, **eine Datei, die der Plan §3
  nicht nennt** (Gebautes ohne Plan-Zeile). Die Abweichung ist erzwungen: die
  Erstfassung der Zelle (Commit `ee94dd40^`) maß 354 Zeichen und fiel an das
  docs-check-Modul `section-cell-oversized` (rot im ersten gates-Lauf des
  Implementers gesehen); das Modul ist real — `harness/tools/full-smoke.sh`
  benennt `meldung='section-cell-oversized'` als rot färbende Meldung. Bindung
  ADR-0099 blieb an der Zelle; der mehrsatzige Vertrag zog als Prosa ins
  Sensor-File. Die Abweichung ist also gerechtfertigt, aber **zu vermerken** —
  der Plan §3 sollte sie in der Closure nachziehen.
- **§3-Zeile „je 2 Fälle in `test/mutations/`"** — 784/785 sind neu wie geplant;
  darüber hinaus wurden **zwei Bestandsfälle (211/212)** an die Wrapper-Form
  gezogen. Das war durch die Änderung der gemessenen Form zwingend (Anker hingen
  an der alten `gates: record-gates`-Lage, MR-071 legte es offen) und ist kein
  Plan-Bruch, aber ebenfalls über den Plan hinaus.
- **Alle übrigen §3-Zeilen treffen den Code:** `gates-fast.sh` neu am geplanten
  Pfad, `Makefile`-Änderung an der verplanten Stelle (Rezept, Kante byte-gleich),
  `gate-nachweis-kante.bats` umgezogen, `gates-fastpfad.bats` mit den drei
  verplanten Klassen (Happy/Negative/Boundary, hermetisch, `--network none`).
- **Plan-Defekte aus dem Review (Übergabe-Abschnitt des Review-Reports) — bestätigt
  und offen für §7:** der MR-091-Probe-Weg fehlt im Plan §2/§3 (er ist inzwischen
  **vollzogen**, siehe oben — die Closure trägt das Ergebnis als Risiko-Ausgang,
  nicht als offenen Punkt mehr), und die Folgen an `harness/conventions.md`
  (Zelle verlässt die `—`-Form, Zähler im Zusatzklassen-Block) fehlen im Plan §6
  (F-2). §7 des Slice-Plans ist leer; die Ablage ist richtig (`in-progress/`,
  Closure ist Planner-Arbeit).

## Risiken §6 — Ausgänge am Artefakt bestätigt

- **Risiko 1 (Stempel deckt Docker-Cache/Host-Werkzeuge nicht — eingetreten):**
  SKIP nur bei gedecktem Paar, Meldung nennt den Rest wörtlich, FORCE-Schalter —
  alles am Code und im Lauf belegt (E, D oben). Der Beleg im Register
  `BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand` wird laut Plan §6/§8 erst
  bei der **Closure** angehangen (`evidence/` steht aktuell bei 1 Beleg,
  `slice-180.md`; Stand `offen`) — erwartet, kein Defekt; die Closure liegt an.
- **Risiko 2 (CI-Verhalten-Change — entfallen):** fail-closed am fehlenden Stempel
  ist im Code und in Spot-Check B belegt; CI ruft `make gates` unverändert.
- **Risiko 3 (zweite Schreibstelle — entfallen):** das Skript schreibt nichts
  (Code-Lesung + Wächter `verdrahtung: der Fast-Pfad schreibt keinen Stempel`);
  Schreiber bleibt `record-gates`.
- **Risiko 4 (späteres Gate-Audit — entfallen):** jede Touch-Änderung invalidiert
  — direkt am realen Wächter beobachtet (Nebenbeobachtung bei Spot-Check A oben).

---

## Offene Punkte für den Planner (Closure) / Architect

1. **F-2 des Review-Reports ist weiter offen** (Architect-Artefakt, korrekt vom
   Implementer nicht angefasst): `harness/conventions.md`
   §Zusatzklassen-Deklaration — gemessen am HEAD: `wc -l` → **47** (Block notiert
   31), `grep -cE 'ADR-[0-9]{4}'` → **15** (Block notiert 8),
   `grep -cE '^ *— *$'` → **0** (Block notiert 1); der Satz „`—` steht allein in
   der Zeile `make gates`" stimmt nicht mehr (die Zelle trägt ADR-0099 als
   Bindung). Übergabe an den Architect (AGENTS §3.8) bleibt stehen.
2. **Das CI-Mutations-Ergebnis (F-1) ist erledigt** — der Branch ist nach dem
   Lesen gelöscht und das Ergebnis nur in diesem Report festgehalten:
   `gruen`, 23/23, geprüfter Commit `28da4709`. Die Closure kann diesen Report
   zitieren, den Branch gibt es nicht mehr.
3. **Register-Beleg** für Risiko 1 bei der Closure ergänzen (Plan §6/§8 — 2×).
4. **Plan-Defekte in §7 tragen** (MR-091-Weg, Conventions-Folge) — sie stehen
   weiter als Übergabe im Review-Report.
5. Nach diesem Report-Commit fährt der nächste `make gates`-Lauf voll
   (fail-closed) — erwartetes Verhalten, kein Defekt.

**Verifikations-Urteil: freigegeben.** Kein Befund gegen den Code. Die
Verifikation schließt die DoD-Punkte 1–4; die restlichen §2-Punkte hängen an der
Slice-Closure, die Planner-Arbeit bleibt.

**Sensoren dieses Laufs:** CI-Branch-Mutations-Lauf (23/23, gelöscht) ·
`make mutate MUTATE_CASES=…` 784+785 (2 ok, je benannter Rot-Grund) ·
`make mutate-greift` (771/771, 0 Befunde) · reale Weg-Spot-Checks A–E an einer
Kopie · direkter Aufruf am echten Baum · Stempel-Gegenmessung selbst gemessen ·
`make docs-check` nach dem Commit (grün). `make gates` selbst bewusst nicht
gefahren (kein Stempel-Einzug aus der Verifier-Sitzung).

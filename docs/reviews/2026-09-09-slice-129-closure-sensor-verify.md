# Verifikation — slice-129: Die Closure-Notiz-Pflicht bekommt ihren Sensor

**Rolle:** Verifier (Modul 11, frischer Kontext) · **Datum:** 2026-09-09

## Eingang

- **Slice-Plan:** [`docs/plan/planning/in-progress/slice-129-closure-notiz-hat-einen-sensor.md`](../plan/planning/in-progress/slice-129-closure-notiz-hat-einen-sensor.md)
- **Drei Review-Reports:** [Runde 1](2026-09-09-slice-129-closure-sensor-review.md) (2 HIGH/2 MEDIUM/2 LOW/3 INFO, merge-blockierend) ·
  [Runde 2](2026-09-09-slice-129-closure-sensor-review-runde-2.md) (2 HIGH/2 MEDIUM/0 LOW/2 INFO, merge-blockierend) ·
  [Runde 3](2026-09-09-slice-129-closure-sensor-review-runde-3.md) (0 HIGH/0 MEDIUM/2 LOW/1 INFO, **nicht** merge-blockierend, „reif für den Verifier")
- **Commit-Kette:** `02937ed3` … `f25d5504` (Implementer, mehrere Runden), dazwischen drei Reviewer-Commits (`59c5cd6c`, `9d27866d`, `5e71f6a2`).
- **Baum bei Prüfungsbeginn:** `git status --porcelain` leer; `HEAD` = `39b530af` (die zwei jüngsten Commits sind ein unabhängiger `slice-mv`/Priorisierungs-Vorgang für drei Emit-Slices, **nicht** Gegenstand dieses Slice — ausgeklammert, wie in der Aufgabenstellung benannt).

Nichts aus den drei Reports übernommen — jede Zahl unten ist in diesem Lauf neu erhoben, gegen
Kopien außerhalb des Repos (netzlos, `--network none`, Mount `:ro`) mit dem in `d-check.mk`
gepinnten Digest `sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`
(`v0.74.1`), bzw. direkt am Arbeitsbaum wo angegeben.

## 1. DoD Punkt für Punkt — Sache statt Häkchen

Die drei Häkchen stehen auf `[ ]` (`grep -n '^\- \[' <plan>` → alle drei `[ ]`) — korrekt nach
§3.10: sie dürfen nur der Planner in der Closure setzen. Geprüft wird hier, ob die
`Rot:`/`Erfüllt:`-Klauseln **vollständig** stehen und ob die Arbeit ihnen **in der Sache**
genügt.

**Kriterien-Text vollständig.** `diff` gegen `git show 3b6c81af^:<plan>` (den Stand vor der ersten
Implementer-Runde): die drei `**Rot:**`-Klauseln sind unverändert vorhanden, die drei
`**Erfüllt:**`-Blöcke stehen **additiv** darunter, ohne ein Kriterium zu verschieben. Die einzigen
sonstigen Abweichungen sind zwei Pfad-Updates (`open/` → `next/` bei den slice-073-Verweisen,
Folge des unabhängigen `slice-mv` am `HEAD`) und die §3-Tabelle (Aufwands-/Umfangs-Zeile, kein
Abnahmekriterium — dieselbe Einordnung, die schon Runde 1 und Runde 3 vorgenommen haben und die
ich teile: §3.10 bindet DoD-Punkte, Closure-Trigger und Out-of-Scope-Grenzen, nicht die
Plan-vor-Code-Tabelle).

**(1) Sensor verdrahtet, färbt rot — selbst reproduziert.**
`.d-check.yml` setzt `planning.closure.dir: docs/plan/planning/done`, kein `glob:`, kein
`boilerplate:`. Eigener Lauf gegen eine frische `git archive`-Kopie:

```
d-check: 1011 Datei(en) geprüft, 0 Befund(e)
```

§7 von `docs/plan/planning/done/slice-001a-cli-skeleton.md` in einer zweiten Kopie auf einen Satz
gekürzt:

```
docs/plan/planning/done/slice-001a-cli-skeleton.md:79  docs/plan/planning/done  closure-note-thin
  Closure-Notiz trägt 1 Satzende-Zeichen außerhalb von Code-Blöcken, verlangt sind 4
```

EXIT 1. Beide Läufe wörtlich das, was `harness/README.md:93-102` als Beleg zitiert. **Erfüllt.**

**(2) Kandidaten-Filter entschieden, Welle-Ebene benannt — Zahlen nachgezählt.**
`slice-glob` bleibt Default (kein `glob:` in `.d-check.yml`). `harness/README.md:104-130`
begründet den Ausschluss der Welle-Ebene mit der Zwei-Datei-Form der Welle-Closure. Eigene
Messung: `grep -lE '^# .*[Cc]losure' docs/plan/planning/done/welle-*-results.md | wc -l` → **8**
von **12**; die vier Ausreißer (`welle-06/07/08/12`) namentlich benannt und korrekt als
H1-„Results-Notiz" ohne das Wort „Closure" identifiziert. Probeweise `glob: '*.md'` gegen eine
Kopie: **20** Befunde (12 `closure-note-missing` + 8 `closure-note-thin`) — deckt sich mit dem
Text. **Erfüllt.**

**(3) Ort des Laufs entschieden, gegen die Werkzeug-Empfehlung — kein neues Ziel.**
`git diff 838cc6d6^ HEAD -- Makefile` ist leer — kein neues Rezept, kein eigenes `--config`-Profil.
`closure` läuft im bestehenden `planning:`-Block, am geteilten Durchsetzungspunkt `docs-check` in
`make gates`. Was das nicht leistet (jeder `docs-check`-Lauf öffnet jetzt auch jede flache
`slice-*.md` unter `done/`) steht in `harness/README.md:140-150`. **Erfüllt.**

**Standard-Punkte:**

- `make gates` grün — **selbst gefahren** (nicht aus einem Report übernommen): EXIT 0, Ausgabe
  endet mit `comment-claims: 57 Datei(en) geprueft, 0 Befund(e)` und
  `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.
  `.harness/state/gates-passed.diffsha` deckungsgleich mit
  `harness/tools/working-tree-hash.sh` (`748eccb4…`).
- `make mutate` ohne Befund — **selbst gefahren, vollständig, nicht aus dem Beleg-Slot
  übersprungen** (siehe §3 unten): `mutate: 276 ok, 0 Befund(e)`, EXIT 0. Der Beleg-Schlüssel
  `.harness/state/mutate-passed.key` ist danach frisch (`c07312fc…`).
- Doku-Update für den berührten öffentlichen Vertrag: `harness/README.md` trägt den neuen
  Abschnitt (98 Zeilen laut `git show --stat`).
- Closure-Notiz mit Steering-Loop-Eintrag: **noch nicht geschrieben** — §7 des Plans ist der
  unveränderte Platzhalter-Kommentar. Das ist **kein Implementer-Versäumnis**, sondern
  Planner-Arbeit nach §3.10/Modul 5 und folgerichtig noch offen.

**Verdikt DoD:** Alle drei slice-eigenen Punkte sind in der Sache erfüllt und mit selbst
reproduzierten Kommandos belegt. Beide Standard-Gate-Punkte sind grün, selbst gefahren. Der
verbleibende Standard-Punkt (Closure-Notiz) ist genuine Planner-Arbeit und kein Verifikations-Hindernis.

## 2. Plan-vs-Code-Diff

| Plan sagt | Code tut | Deckung |
|---|---|---|
| `closure.dir: docs/plan/planning/done`, kein `glob`, kein `boilerplate` | `.d-check.yml:50-55` exakt das | ✅ |
| kein neues Makefile-Ziel | `git diff` über `Makefile` im Slice-Umfang leer | ✅ |
| `harness/README.md` dokumentiert Deckung, Filter-Begründung, Nicht-Rekursion, Nicht-Leistung | alle vier Absätze vorhanden, Zahlen nachgezählt (8/12, 20, 1×placeholder, 10×boilerplate) | ✅ |
| `test/` bekommt den Rot-Fall aus DoD (1) plus `test/mutations/`-Zahn | `test/closure-modul-wiring.bats` (6 Zusicherungen) + `test/mutations/285-290` (6 Fälle, je genau eine Zusicherung treffend) | ✅ — selbst durch bats-Lauf unmutiert (6/6 ok) und je Mutation (genau die benannte Zusicherung fällt) verifiziert |
| `done/` unverändert, Rot nur in Wegwerf-Kopien | `git diff 838cc6d6^ f25d5504 --name-only` enthält kein `docs/plan/planning/done/*` | ✅ |
| `internal/emit/` unverändert (Ebene Dogfood) | dieselbe Diff-Prüfung: kein `internal/emit/*`-Pfad berührt; `modules: [links, anchors]` im emittierten Fragment unverändert (`internal/emit/emit_test.go:17`) | ✅ — siehe §4 |
| `harness/conventions.md` **nicht** durch diesen Slice (Übergabe an Architect) | unverändert im Slice-Diff | ✅ |

**Was der Plan nicht sagt, der Code aber tut (Gebautes-aber-nicht-Geplantes):** nichts
Nennenswertes über die in den Review-Runden bereits verhandelten Korrekturen hinaus (Kommentar-
Präzisierungen in `test/mutations/288/289/290`, Rücknahme der DoD-Text-Umschreibung). Kein
zusätzlicher Funktionsumfang, kein zusätzlicher Sensor, keine zusätzliche Konfiguration jenseits
dessen, was DoD (1)–(3) verlangen.

**Was der Plan sagt, der Code aber (noch) nicht auflöst:** vier `MR-016`-Zitate im Plan-Kopf und
in §3/§6/§8 (`docs/plan/planning/in-progress/slice-129-…md:28,183,203,251`) — dieselbe tote
Adaption, die `harness/README.md` in Runde 1 korrigiert bekam. `git blame` bestätigt: alle vier
Zeilen stammen aus dem Anlage-Commit `829910a5` (2026-08-28), `MR-016` wurde erst am 2026-08-31
(`447bb097`) durch `MR-037` abgelöst — bei Niederschrift korrekt. Nach §3.10 ist das eine
**Übergabe an den Planner** (Norm-Aussage im eigenen Plan-Artefakt), kein Implementer-Auftrag und
kein Verifikations-Hindernis; ich nenne es unten als Closure-Vorarbeit.

## 3. Der offene Beleg-Slot (Runde-3-INFO-1) — jetzt geschlossen

Runde 3 stellte fest: `.harness/state/mutate-passed.key` (`55a93abb…`) deckte den damaligen
Baumzustand nicht mehr (`isolation_key` lieferte `3db3d84c…`). Ich habe `make mutate` in diesem
Lauf **vollständig** gefahren — kein Übersprung, expliziter `timeout`, im Hintergrund verfolgt bis
zur Fertig-Meldung (Laufzeit real ca. 27 Minuten unter Last durch einen parallelen, fremden
Docker-Build auf demselben Host — die zwei-Wochen-alte Referenzmessung aus dem
Session-Memory nennt ~526 s bei ungestörtem Host; die Fall-Arbeit selbst
(`mutate: … Fall-Arbeit gesamt 6411.1 s`) ist unverändert plausibel gegenüber 276 Fällen à
im Mittel ~23 s):

```
mutate: untere Schranke jeder Parallelisierung = laengster Einzelfall: 89.94 s (199-mutate-zeitschranke-greift-nie)
mutate: 276 ok, 0 Befund(e)
[exited with code 0]
```

`ls test/mutations/*.sh | wc -l` → **276** — deckt sich mit der gemeldeten Fallzahl. Der
Beleg-Schlüssel ist jetzt frisch (`c07312fc…`), `git status --porcelain` danach leer. Damit ist der
Standard-DoD-Punkt „`make mutate` ohne Befund" für den **aktuellen** Baumzustand real gedeckt, nicht
nur behauptet — genau die Lücke, die mir als Übergabe benannt war.

## 4. ADR-/MR-017-Konformität

- **`internal/emit/` unberührt.** `git diff --name-only 838cc6d6^ f25d5504 -- internal/emit/` ist
  leer; `internal/emit/emit_test.go:17` verlangt weiterhin `modules: [links, anchors]` im
  emittierten Starter-`.d-check.yml` — die `closure`-Fähigkeit sickert nicht in die Emission.
- **MR-017 (Default-Regel für emittierte Prüfbereiche, fail-closed)** ist nicht einschlägig
  berührt: kein emittiertes Artefakt ändert sich durch diesen Slice.
- **Keine superseded ADR referenziert.** Im Slice-Diff mittelbar genannt: ADR-0033 und ADR-0035,
  beide `Proposed` (`grep -m1 '^\*\*Status' docs/plan/adr/0033-*.md docs/plan/adr/0035-*.md`
  → beide `Proposed`), zitiert als Zeiger auf gebauten Mechanismus, nicht als normative Stütze —
  dieselbe Einordnung wie in Runde 3.
- **Kein Gate gelockert.** `modules:` in `.d-check.yml` unverändert (`links, anchors, ids, matrix,
  codepaths, spans, planning`); die Änderung ist ein Gate-*Anheben* (neue Fähigkeit innerhalb eines
  bereits aktiven Moduls), kein Absenken — §3.5 nicht einschlägig.
- **§3.3 (Move+Rewrite getrennt):** kein Move im Slice-Umfang, nicht einschlägig.
- **§3.9 (Docker-only):** keine Host-Toolchain in einem der neuen Rezepte/Skripte; alle Sonden in
  diesem Verify-Lauf liefen ebenfalls über das gepinnte Image bzw. reine Datei-Operationen.

## 5. Eigene Stichproben über die drei Reviews hinaus

- Negativkontrolle „nicht rekursiv" selbst nachgestellt: identische §7-dünne Datei einmal flach
  unter `done/`, einmal unter einem synthetischen `done/welle-99/` — flach `closure-note-thin`
  (1 Fund), tief **0** Funde bei **1012** geprüften Dateien (die Tiefe wird durchsucht, `links`
  meldet dort separat `target-missing` für die jetzt zu tiefen Relativpfade — irrelevant für
  `closure`). Bestätigt MEDIUM-1/R1 sowie dessen Behebung.
- `boilerplate: ["Platzhalter"]` selbst gesetzt: **10** `closure-note-boilerplate`-Funde, EXIT 1 —
  deckt sich mit dem in `harness/README.md` und in Fall 290 behaupteten Wert.
- `dir: docs/plan/planning/open` selbst gesetzt: **43** `closure-note-thin`-Funde (nicht 45 — der
  in `test/mutations/288-…sh:9` hart codierte Wert ist zwei Tage bzw. mehrere `slice-mv`-Vorgänge
  später bereits gealtert; **dasselbe Symptom, das Runde 3 als LOW-1 benennt**, hier live
  reproduziert). Bestätigt: LOW-1/R3 ist real und nicht behoben — zu Recht als nicht-blockierend
  eingestuft, denn die tragende Aussage des Kommentars („falscher Bestand wird gemeldet, richtige
  Diagnose") bleibt unabhängig von der genauen Zahl wahr, und kein Gate erreicht die Stelle
  (`test/` liegt außerhalb von `make comment-claims`).
- `dir: docs/plan/planning/does-not-exist-289` selbst gesetzt: exakt die zitierte Meldung
  (`… fehlt oder ist unlesbar (fail-closed)`), EXIT 1.
- Alle sechs `test/closure-modul-wiring.bats`-Zusicherungen unmutiert grün (6/6 `ok`) und je
  Mutation 285–290 einzeln gegen eine frische Kopie gefahren: jede färbt **genau** die in ihrer
  `# expect:`-Zeile genannte Zusicherung rot, keine weitere unerwartete.
- Commit-Hygiene: `f25d5504` (der jüngste Slice-Commit) trägt keine `LH-*`/`ADR-*`-ID
  (`git log -1 --format=%B f25d5504 | grep -oE 'LH-[A-Z]+-[0-9]+|ADR-[0-9]{4}'` leer) — bestätigt
  LOW-2/R3. Der Commit ist noch lokal (`git status -sb` → `[voraus 10]` inklusive der zwei
  unabhängigen `slice-mv`-Folgecommits), nicht mehr rückwirkend sauber zu korrigieren ohne
  History-Rewrite; nicht-blockierend, wie von Runde 3 eingeordnet.

Keine dieser Stichproben ergab einen Befund, den die drei Reviews nicht bereits kannten oder der
über „nicht-blockierend" hinausginge.

## 6. Was einer Closure im Weg steht

Nichts Technisches. Was fehlt, ist ausschließlich **Planner-Arbeit nach §3.10/Modul 5**, nicht vom
Implementer nachzuholen:

1. Die drei DoD-Häkchen von `[ ]` auf `[x]` setzen (der Implementer hat sie korrekt offen
   gelassen).
2. §7 Closure-Notiz mit Steering-Loop-Eintrag schreiben. Kandidaten aus den drei Reviews, die den
   Zähler des Beobachtungs-Registers bewegen oder einen neuen Eintrag verlangen: *fremdes
   Rollen-Artefakt im Implementations-Kontext* (in diesem Slice **entstanden und selbst wieder
   zurückgenommen** — kein neuer Registerzähler-Zuwachs, da nichts unwidersprochen im Baum blieb),
   *Zusammenfassung stärker als ihre Quelle* (Register-Stand vor diesem Slice: 3 — Runde 1 MEDIUM-2
   ist eine weitere Fundstelle desselben Vorgangs und zählt laut Modul 6 nicht zweimal), *neuer
   Wächter ohne Mutations-Fall* (in Runde 2 vollständig behoben — LOW-2/R1 hat keinen offenen Rest
   mehr), *retirierter Adaptions-Eintrag als lebende Begründung zitiert* (in `harness/README.md`
   behoben, im Plan selbst noch offen — s. §2 oben), *Baseline-Aussage ohne Mess-Tag* (behoben),
   *Kommentar beruft sich auf eine Quelle in keinem Rang* (behoben), *inventar-abhängiger Messwert
   im Skript-Kommentar ohne Kommando* (neu, LOW, Register prüfen ob 1. Auftreten) und
   *Commit-Message ohne Traceability-Kennung* (neu, LOW).
3. Die vier `MR-016`-Zitate im Slice-Plan selbst (§2 oben) sind eine Korrektur, die nach §3.10
   dem Planner gehört, nicht nachträglich dem Implementer — analog zur bereits erfolgten Korrektur
   in `harness/README.md`.
4. Risiken §6 des Plans gegen die drei Ausgänge (eingetreten/entfallen/weiter offen) auflösen —
   inhaltlich sind alle vier dort benannten Risiken durch die DoD-(1)-(3)-Umsetzung sachlich
   beantwortet (Nicht-Rekursion benannt statt verschwiegen, Platzhalter-Kosten korrekt bewertet,
   Floskel-Liste nicht aktiviert, kein zweites Profil).
5. `git mv` nach `done/`.

Der Implementer und die drei Review-Runden haben ihren Teil geleistet und ihn belegt, nicht nur
behauptet.

## Verdikt

**DoD erfüllt: ja** — alle drei slice-eigenen Punkte in der Sache erfüllt und in diesem Lauf
unabhängig reproduziert; beide Standard-Gate-Punkte grün, beide selbst gefahren (nicht aus einem
Report übernommen), `make mutate` **vollständig und frisch** mit `276 ok, 0 Befund(e)`. Keine
ADR-Verletzung, keine Emission in `internal/emit/`, keine Gate-Lockerung. Plan und Code stimmen an
allen geprüften Stellen überein; die einzige Abweichung (vier tote `MR-016`-Zitate im Plan selbst)
ist eine Planner-Übergabe, kein Implementer-Defekt.

**Was einer Closure im Weg steht:** nichts Technisches — ausschließlich die in §6 aufgezählte
Planner-Arbeit (DoD-Häkchen, Closure-Notiz mit Registereintrag, die vier `MR-016`-Zitate im Plan,
Risiko-Ausgänge, `git mv`). Zwei nicht-blockierende LOW-Befunde aus Runde 3 (wandernde Zahl in
`test/mutations/288`, fehlende Traceability-ID in `f25d5504`) bleiben stehen und sind für die
Closure-Notiz vorgemerkt, verhindern sie aber nicht.

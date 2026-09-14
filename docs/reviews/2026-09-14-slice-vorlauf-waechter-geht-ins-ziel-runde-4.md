# Review-Report: slice-vorlauf-waechter-geht-ins-ziel — Runde 4 — 2026-09-14

**Review-Art:** Code-Review gegen **Plan + Hard Rules** (Modul 10 §Drei Review-Arten). **Vierter
Lauf** am selben Gegenstand, geprüft ist das **Delta seit Runde 3**. **Kein DoD-Review** —
DoD-/Spec-Konformität prüft der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** die zwei Commits `d8ab4835` („die fail-closed Probe steht einmal — beide Ziele
lesen sie“) und `1b060790` („Fall 331 auf die eine Probe gezogen“) — die Behebung von N-5 und N-6
aus Runde 3 samt Nachzug an einem eigenen Mutationsfall. **Geprüfter Stand:** `1b060790`;
Arbeitsbaum vor dem ersten Mess-Lauf leer (`git status --porcelain` → keine Zeile), nach jedem
Mutations-Lauf einzeln zurückgenommen und erneut leer (§4, §6). Runde-3-Report:
`2026-09-14-slice-vorlauf-waechter-geht-ins-ziel-runde-3.md` — **sein Urteil ist nicht
übernommen**: jeder Befund ist in diesem Lauf einzeln nachgemessen (§1–§8), keiner abgeschrieben.

**Kein Self-Review (Negativ-Aussage):** dieser Lauf hat an `d8ab4835`, an `1b060790` und an den
drei Vorgänger-Commits dieses Gegenstands **nicht geschrieben** — kein Kommentar, kein Test, kein
Fragment, keine Mutations-Datei, kein Sensor-Dokument dieses Deltas stammt aus diesem Kontext.
Aus der Commit-Message und aus dem Implementer-Bericht ist **nichts** als Befund oder als
Negativbefund übernommen; die dort behaupteten Rot-Belege sind nachgefahren (§4), die behauptete
Wirkung des Umbaus ist mit **drei eigenen Driften** angegriffen (§3, §6) statt geglaubt.

**Skill:** `.harness/skills/reviewer.md` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-14

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-vorlauf-waechter-geht-ins-ziel` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.9)
- [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- Baseline `v6.8.0` · `regelwerk/grundlagen-harness-dateien.md` §Was ein Kommentar trägt
  (Zeitform-Test — Konjunktiv zulässig über den **Bruch** und über **künftige Arbeit**,
  unzulässig über die **verworfene Alternative**) und dessen Geltungsbereich
- Vorherige Findings am **selben Gegenstand**: Runde 1 (1 HIGH · 3 MEDIUM · 1 LOW · 2 INFO),
  Runde 2 (2 MEDIUM · 1 LOW · 1 INFO), Runde 3 (1 MEDIUM · 1 LOW)

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
Die Docker-Sonden (`make gates`, `make full-smoke`) liefen über `make`; die isolierten
Make-/awk-Sonden in `/tmp` sind Wegwerf-Dateien und **nicht** im Repo.

### 1. Der Runde-3-Angriff auf Zeile 100 — nachgefahren

```sh
$ sed -i '100s@"rezeptlos"@"da"@' internal/emit/emit.go
$ git diff --stat -- internal/emit/emit.go      # Ausgabe: leer
$ sed -n '100p' internal/emit/emit.go
doc-immutable: history-range-guard
```

**Trägt:** Zeile 100 ist die Bindungs-Zeile des ersten Ziels; `sed` ändert nichts. Die Probe stand
in Runde 3 auf Zeile 100 **des Fragments**, heute auf Zeile 97 **der Datei** und **einmal** für
beide Ziele (`grep -c 'DOC_GATE_ZIEL = ' internal/emit/emit.go` → **1**).

### 2. Die Zusicherungen in Abschnitt (f) — gezählt, nicht geglaubt

```sh
$ make full-smoke          # EXIT 0 (FULLSMOKE_EXIT=0 im Log)
$ grep -n 'Zieldefinition' /tmp/r4/fs-baseline.log
266: make doc-immutable bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab, ohne ein Modul zu fahren.
267: make doc-commits  bricht … (umbenanntes Ziel, beide Ziele)
268: make doc-immutable bricht … (Ziel-Zeile ohne Rezept)
269: make doc-commits  bricht … (Ziel-Zeile ohne Rezept)
270: ohne das Probe-Werkzeug bricht make doc-immutable LAUT ab, statt zu binden.
271: derselbe Aufruf ueber dem unverfaelschten d-check.mk bleibt gruen (doc-commits), der Modul-Lauf fand statt.
```

**Sechs Zusicherungen**, wie behauptet: vier rote Lagen (zwei Auslöser × zwei Ziele), die Randlage
ohne Probe-Werkzeug, die grüne Richtung. Die zwei Auslöser sind quellseitig je ein eigener
Helfer-Aufruf (`harness/tools/full-smoke.sh:547`, `:548`, `:553`, `:556`, `:561`, `:563`).

### 3. Die vierte Klasse — die Probe als **eine** Variable, mit vier eigenen Driften angegriffen

Gegen die neue Struktur sind **drei** Driften gefahren, jede einzeln, jede über `make full-smoke`,
jede danach zurückgenommen (`git status --porcelain` → leer):

| Drift an `internal/emit/emit.go` | erwartete erste fallende Zusicherung | gemessen |
|---|---|---|
| beide Aufrufe lesen `doc-immutable` (Kreuzverdrahtung vorwärts) | 4. (Ziel-Zeile ohne Rezept, `doc-commits`) | **EXIT 2**, `make doc-commits blieb … GRUEN (Exit 0)` |
| beide Aufrufe lesen `doc-commits` (Kreuzverdrahtung rückwärts) | 3. (Ziel-Zeile ohne Rezept, `doc-immutable`) | **EXIT 2**, `make doc-immutable blieb … GRUEN (Exit 0)` |
| zweiter Aufruf zeigt auf ein **anderes existierendes** Ziel (`docs-check`) | 2. (umbenanntes Ziel, `doc-commits`) | **EXIT 2**, dieselbe Zeile |
| die **Variable selbst** durch ein festes `"da"` ersetzt | 1. | in diesem Lauf **nicht** gefahren — der Beleg liegt beim Fall `329` und ist hier nicht nachgemessen (§Verdikt, *offen*) |

```sh
$ sed -i 's@$(call DOC_GATE_ZIEL,doc-commits)@…'   # je Drift, hier vorwaerts; Logs: /tmp/r4/fs-crosswire.log (vorwaerts), fs-crosswire-rev.log (rueckwaerts), fs-argother.log (Argument)
$ grep -n 'FEHLER' /tmp/r4/fs-crosswire.log | sed -n '1p'
262:full-smoke: FEHLER — golang (d-check.mk ohne Ziel-Definition, doc-commits): make doc-commits blieb ueber einem d-check.mk OHNE die Ziel-Definition GRUEN (Exit 0) — die Vorbindung hat dort kein Rezept.
```

**Damit trägt die Behebung an beiden Hälften:** jede der vier roten Lagen ist **einzeln** die erste
fallende — zwei davon an der Hälfte, die vor dem Delta **keinen** Wächter hatte (`doc-commits`).
Die zweite Zusicherung ist über den Umweg „Aufruf-Argument zeigt auf ein anderes existierendes
Ziel“ erreichbar (Sandbox-Messung: über umbenannten Ziel-Zeilen liefert die Probe für `docs-check`
`da` und für `doc-immutable` leer); im dritten Drift bewiesen.

### 4. Ein Mutationsfall einzeln — zwei gefahren, beide Meldungen gelesen

```sh
$ bash test/mutations/331-unbekannter-probe-ausgang-bindet.sh   # Operand: … d-check.mk 2>/dev/null || echo da)
$ grep -c 'd-check.mk 2>/dev/null || echo da)' internal/emit/emit.go   # → 1
$ make full-smoke                                              # EXIT 2
254:full-smoke: FEHLER — golang (ohne Probe-Werkzeug im PATH, doc-immutable): der Aufruf waehlte trotz fehlenden Probe-Werkzeugs die Bindung — make -n druckt die Waechter-Zeile (Exit 0).
```

Die ersten **vier** Zusicherungen tragen (Log `Zieldefinition` 250–253), die fünfte fällt, und die
Meldung ist die des `# expect:` („waehlte trotz fehlenden Probe-Werkzeugs die Bindung“) — **der
Nachzug `1b060790` bringt den Fall zurück an seinen Wächter.**

```sh
$ bash test/mutations/332-zweiter-probe-aufruf-mit-falschem-ziel.sh
$ make full-smoke                                              # EXIT 2
245:full-smoke: FEHLER — golang: die Kette des Ziels ist nicht die zugesagte: [doc-commits nennt den Waechter nicht] (LH-QA-01).
```

Der **neue** Fall `332` fällt ebenfalls aus dem benannten Grund; sein Zahn sitzt an der Kette (a),
nicht in (f) — der Kommentar der Datei sagt genau das. **Weder 329 noch 330** sind in diesem Lauf
einzeln gefahren (Weisung: kein voller Satz; zwei Einzel-Belege treten an seine Stelle).

### 5. „Haben weitere Operanden ihr Ziel verloren?“ — alle Fälle mit `emit.go`-Bezug, je gezählt

```sh
$ for n in 40 325 327 329 330 331 332; do …; done   # jeder Operand nach dem Delta:
325 (doc-immutable: history-range-guard)          → 1
327 (vorbindungsTargets-Literal)                  → 1
 40 (GATE_CHECKS += docs-check)                   → 1
329 (^DOC_GATE_ZIEL = .*)                         → 1
330 (? "da" : "rezeptlos")                        → 1
331 (d-check.mk 2>/dev/null)                      → 1   ← der Nachzug
332 ($(call DOC_GATE_ZIEL,doc-commits))           → 1
$ git grep -n 'shell awk' -- . | grep -v '\.harness/baseline'   # nur emit.go:97 (die Variable)
```

**Kein weiterer Operand hat durch den Umbau sein Ziel verloren.** Die einzige verbliebene Nennung
der alten Inline-Form steht in `docs/reviews/2026-09-14-…-runde-3.md:312-313` — ein **Zeitdokument**,
das den damaligen Stand festhält und nach §3.7-Geltungsbereich nicht nachgezogen wird.

### 6. Die Variable selbst — die Umgehungsfläche, in `/tmp` gemessen

```sh
$ make -f doc-gate.mk -n doc-immutable RANGE=HEAD~1..HEAD              # d-check.mk OHNE die Ziel-Definition
echo "… d-check.mk fuehrt 'doc-immutable' nicht als Ziel mit Rezept …" >&2 ; exit 2
$ make -f doc-gate.mk -n doc-immutable RANGE=HEAD~1..HEAD DOC_GATE_ZIEL=da
bash tools/harness/history-range-guard.sh "HEAD~1..HEAD"              # bindet — kein Abbruch
$ DOC_GATE_ZIEL=da make -f doc-gate.mk -n doc-immutable RANGE=…       # Umgebung allein
echo "… fuehrt 'doc-immutable' nicht als Ziel mit Rezept …" >&2 ; exit 2
$ make -f doc-gate-prev.mk -n doc-immutable RANGE=… DOC_GATE_ZIEL=da  # Vorfassung (zwei $(shell awk))
echo "… fuehrt 'doc-immutable' nicht als Ziel mit Rezept …" >&2 ; exit 2
```

Die **Kommandozeilen**-Zuweisung schlägt die Zuweisung des Fragments (make-Semantik), die Umgebung
allein nicht; die **Vorfassung** ist auf dieselbe Weise **nicht** angreifbar. Das ist die eine
Kante, die die Behebung **neu** erzeugt (Findings R4-1).

### 7. Kosten und Sonderzeichen der einen Probe

```sh
$ PATH=<Zähl-awk>:$PATH make -f doc-gate.mk -n doc-immutable RANGE=…; wc -l awk.log   # 2
$ PATH=<Zähl-awk>:$PATH make -f doc-gate-prev.mk -n doc-immutable RANGE=…; wc -l awk.log  # 2
```

**Zwei `awk`-Aufrufe je `make`-Lauf — vor und nach dem Umbau dieselbe Zahl.** Die rekursive
Zuweisung wird je `ifeq` expandiert; vorher standen dort zwei `$(shell …)`. Kein Aufschlag, kein
Nebeneffekt; die Fragment-Datei ist 43 Zeilen und wird zweimal je Parse gelesen.

Zum `$(call)`-Argument (Sandbox, `doc-commits` mit Rezept in `d-check.mk`):

```text
$(call DOC_GATE_ZIEL,doc-commits) → da          $(call DOC_GATE_ZIEL,doc-commit) → „“ (leer)
$(call DOC_GATE_ZIEL,)           → „“ (leer)     $(call DOC_GATE_ZIEL,doc,x)      → „“ (leer)
$(DOC_GATE_ZIEL) ohne call       → „“ (leer)
```

Jeder nicht-belegte Ausgang ist **leer** und damit im `ifeq` nicht gleich `da` → Abbruch. Die neue
Argument-Achse (Komma teilt das Argument, leerer Name, Aufruf ohne `call`) ist **fail-closed**; ein
Metazeichen im Namen landet ungeschützt im `awk`-Muster, was für die zwei literalen Zielnamen
(`-` ist kein Metazeichen) ohne Wirkung ist.

### 8. `make gates` und `make full-smoke` dieses Laufs

| Lauf | Ergebnis |
|---|---|
| `make gates` (Arbeitsbaum leer, **ohne** diesen Report) | **EXIT 0**; entscheidende Zeilen `baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`, `d-check: 1391 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 58 Datei(en) geprueft, 0 Befund(e)`, `span-check: Traeger vorhanden …`; bats `ok`-Zeilen: `grep -c '^ok ' /tmp/r4/gates.log` → **280** |
| `make gates` (derselbe Lauf mit diesem Report im Baum) | **EXIT 0**, `d-check: 1392 Datei(en) geprüft, 0 Befund(e)` |
| `make full-smoke` (unverfälscht) | **EXIT 0** (§2) |
| `make full-smoke` über **drei** eigene Driften (§3; die vierte Lage ist der Fall `329`) | **EXIT 2** je, aus dem benannten Grund |
| `make full-smoke` über die Fälle `331` und `332` (§4) | **EXIT 2** je, Meldung gelesen |
| `make mutate` | **nicht gefahren** — Weisung: Post-integration (`.github/workflows/mutate.yml`); an seine Stelle treten die Einzel-Belege (§4) |

*Keine Erwartungswerte* — Datei- und Testzahlen wandern mit dem Baum.

---

## Runde 3 — je Befund ein Verdikt

| Runde-3-ID | Verdikt | Kommando / Beleg |
|---|---|---|
| **N-5** (MEDIUM) — die Probe stand zweimal, die Hälften drifteten, kein Anker fing die zweite allein | **behoben** | Die Probe ist **eine** Variable (`grep -c 'DOC_GATE_ZIEL = ' internal/emit/emit.go` → 1), beide `ifeq`-Zeilen lesen sie mit ihrem eigenen Namen. Der Runde-3-Angriff auf die zweite Hälfte ist inert (§1). **Drei eigene Driften** fallen je an der Hälfte, die sie treffen: Kreuzverdrahtung vorwärts → Zusicherung 4, rückwärts → 3, Argument auf ein anderes existierendes Ziel → 2 (§3). Die `doc-commits`-Hälfte, die vorher **keinen** Wächter hatte, trägt jetzt einen (§3). |
| **N-6** (LOW) — Konjunktiv über die verworfene Alternative in der umgeschriebenen Klausel | **behoben** an den drei genannten Stellen | `git show d8ab4835 -- internal/emit/emit.go harness/tools/full-smoke.sh \| grep '^+' \| grep -iE 'stuende\|endete\|statt zu fallen'` → **keine Zeile**; alle drei Stellen nennen den Zustand im Indikativ („Eine Vorbindung … laesst make mit Exit 0 enden“; „… laesst allein den Waechter laufen (Exit 0)“; „… haelt den Fall auf, in dem make allein den Waechter faehrt“). **Kein** Verweis auf die vorige Fassung in irgendeiner neuen Zeile des Deltas; der einzige verbleibende Stand der alten Form steht in der **Runde-3-Datei** selbst (Zeitdokument, §5) — die hält `git`. **Grenze:** dieselbe Klausel steht unverändert in `harness/sensors/history-range-guard.md:89-90` („Sonst stünde die Vorbindung … statt zu fallen“, aus `ee350f6d`); sie liegt **außerhalb** des §3.7-Geltungsbereichs (Code · Konfiguration · Skripte · Zustandsfelder) — benannt, nicht still entschieden (R4-2). |

**Neu entstanden ist durch die Behebung R4-1** (§6): mit der einen Variable ist die fail-closed
Entscheidung ein Wert, den die **Kommandozeile** überschreiben kann; die Vorfassung war so nicht
angreifbar. Alles andere, was die Behebung berührt, hat der Angriff dieses Laufs getragen (§3, §4).

## Findings (neu in diesem Lauf)

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source of
Truth. Die Spalten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung gilt der Skill bzw.
dessen Quelle `v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | **LOW** | Die fail-closed Entscheidung ist mit dem Umbau ein **Wert der Variable** `DOC_GATE_ZIEL` geworden, die eine **Kommandozeilen**-Zuweisung überschreibt (make-Semantik: Kommandozeile schlägt Makefile). Gemessen: `make … DOC_GATE_ZIEL=da doc-immutable` **bindet** über einem `d-check.mk` ohne die Ziel-Definition — der Aufruf läuft allein den Wächter, Exit 0, und die Abbruch-Meldung erscheint nie; dieselbe Zuweisung über der **Vorfassung** (zwei `$(shell awk …)` im `ifeq`) ändert nichts. Die Umgebung allein greift nicht. Kein Sensor der beiden Richtungen fährt diese Zeile: die Zusicherungen von (f) rufen `make` ohne diese Zuweisung, und `make gates` fährt im Ziel keines der zwei Targets. | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) | `internal/emit/emit.go:97` (Zusage), `:99`, `:107` (die zwei Leser) | ja — `make DOC_GATE_ZIEL=da doc-immutable` über einem `d-check.mk` **ohne** die Ziel-Definition, am emittierten Fragment (§6) | **fail-closed-probe-als-kommandozeilen-ueberschreibbare-make-variable** |
| R4-2 | **INFO** | Die Klausel, die N-6 in den Code-Stellen beseitigt hat, steht unverändert in der **Sensor-Prosa**: „Sonst stünde die Vorbindung über einem Ziel ohne Rezept, und `make` endete mit Erfolg (Exit 0), statt zu fallen.“ Sie stammt aus derselben Autoren-Runde (`git blame` → `ee350f6d`) und ist bei der Behebung **nicht** mitgezogen worden. Der Satz liegt **außerhalb** des §3.7-Geltungsbereichs (Code · Konfiguration · Skripte · Zustandsfelder lebender Register — Sensor-Prosa ist keines davon) und ist darum **kein** Verstoß; er ist der Grund, warum die Klasse im Bestand weiterlebt, und gehört zur Kenntnis des Architect (nicht der Literale-Nennungen wegen, sondern der Reichweite der Klasse). | [`AGENTS.md`](../../AGENTS.md) §3.7 (Geltungsbereich) · `v6.8.0` · `regelwerk/grundlagen-harness-dateien.md` §Was ein Kommentar trägt | `harness/sensors/history-range-guard.md:89-90` | nein — kein Gate liest die Zeitform eines Satzes | **konjunktiv-klausel-in-sensor-prosa-jenseits-des-3.7-geltungsbereichs** |

**Klassifikations-Grenze zu R4-1, benannt statt still entschieden:** R4-1 wäre als „Stilles-Grün-Pfad
in einem Gate oder Gate-Skript“ auch MEDIUM/HIGH lesbar. Er ist es **nicht**, weil die Umgehung
**keine Drift im Baum** ist, sondern eine ausdrückliche Handlung des Aufrufers, die nur der
Kommentar über der Variablen benennt; nichts in diesem Repo, in `.github/workflows/` oder im
emittierten Ziel setzt sie (`grep -rn 'DOC_GATE_ZIEL' .` ohne Baseline und ohne `docs/` → nur
`internal/emit/emit.go` und die zwei Mutations-Dateien). Dieselbe Bauart trägt das Repo bereits
bewusst: die Klasse „blind und grün“ ist im Ziel auch über `make -f d-check.mk <ziel>` zu erreichen —
genau der Aufruf, den Abschnitt (d) des Smoke selbst als Gegenprobe führt. **Was ihn höbe:** wenn
der Aufruf über eine Variable dieses Namens in CI, im emittierten Ziel oder in einem Helfer
irgendwo vorkommt — dann ist es ein stiller Pfad im Regelbetrieb und nicht mehr eine Handlung.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Die sechs Zusicherungen in (f): unabhängig oder im Bündel?** | geprüft, ohne Befund: jede ist ein eigener Helfer-Aufruf (`full-smoke.sh:547`–`563`), und **vier** verschiedene Driften fallen je an einer **anderen** (4., 3., 2.) bzw. in einem eigenen Fall (5.); die Restaurierungen zwischen den Blöcken sind vollständig (`cp .orig` vor jedem `sed`, `mv` am Ende). **Grenze:** der Helfer beendet sich beim ersten Fehlschlag (`exit 1`), ein roter Lauf mißt darum nur die Zusicherungen **vor** der fallenden — das ist die normale Einzel-Beleg-Form, kein Bündel |
| **Zusicherung 6 (grüne Richtung `doc-commits`)** | geprüft, ohne Befund: nicht redundant zur Kette (a) — (a) prüft für `doc-commits` nur „nennt den Wächter“, **nicht** „nennt den Modul-Lauf“ (`z_docker` wird allein aus der `doc-immutable`-Kette berechnet, `full-smoke.sh:450-454`); die Zusicherung ist der einzige Zahn für „`doc-commits` hat den Modul-Lauf verloren“ |
| **Der Nachzug `1b060790`: trifft der neue Operand genau eine Fundstelle?** | geprüft, ohne Befund: `grep -c 'd-check.mk 2>/dev/null || echo da)'` → **1**, und der Diff zeigt genau die Zuweisungszeile. **Alle** übrigen Operanden mit `emit.go`-Bezug treffen ebenfalls je genau einmal (§5) |
| **Sind weitere Operanden durch den Umbau zielfrei geworden?** | geprüft, ohne Befund: die sieben Fälle `40/325/327/329/330/331/332` treffen je 1 (§5); die alte Inline-Form existiert repo-weit nur noch im Zeitdokument der Runde 3 |
| **Die zwei behaupteten Rot-Belege im Delta** | geprüft, ohne Befund: `331` und `332` einzeln gefahren, beide **EXIT 2**, beide mit der Zeile ihres `# expect:` in der Ausgabe (§4); `# files: internal/emit/emit.go` löst eindeutig auf, `# verify: full-smoke` ist ein geführter Modus des Treibers |
| **Kosten der rekursiven Zuweisung** | geprüft, ohne Befund: **2** `awk`-Aufrufe je `make`-Lauf, identisch zur Vorfassung (§7); kein Aufschlag, keine Nebenwirkung, kein neuer Host-Bezug (`awk` ist POSIX-Basis und war vorher schon das Probe-Werkzeug) |
| **`$(call)` mit Sonderzeichen im Ziel-Namen** | geprüft, mit Grenze: Komma (Argument-Teilung), leerer Name und Aufruf ohne `call` ergeben je **leer** und damit den Abbruch — fail-closed. Ungeschützt bleibt der `awk`-**Regex**-Charakter des Namens (`.` würde weiten); für die zwei literalen Namen ohne Metazeichen ist das ohne Wirkung, und die Klasse ist **nicht** neu (die Vorfassung trug denselben Namen im selben Muster) |
| **`AGENTS.md` §3.7 über allen neuen Texten des Deltas** | geprüft, ohne Befund: keine der drei umgeschriebenen Klauseln ist Konjunktiv über die verworfene Alternative; `grep` über die **hinzugefügten** Zeilen auf `stuende|endete|statt zu fallen|vorige Fassung|frueher stand` → **0 Treffer**; die entfernte Klausel („der laute Fehlschlag davor war ‚Keine Regel‘“) ist damit **weg** statt umgeschrieben — das ist die Regel, nicht ihr Bruch |
| **`AGENTS.md` §3.7, das neue „Rekursiv zugewiesen (nicht :=), sonst …“** (`emit.go:96`) | geprüft, ohne Befund: die Zeile ist **Kopplung** an den, der die Zuweisungsform ändert („was muß ich mitändern“), im Indikativ; sie beschreibt die Wirkung der abweichenden Form als technische Tatsache, nicht mit Konjunktiv über eine verworfene Entscheidung. Die Probe dieser Regel ist die **Zeitrichtung des Konjunktivs** — hier steht keiner |
| **`AGENTS.md` §3.2 (Lint-Suppression)** | geprüft, ohne Befund: kein `//nolint`, kein `# shellcheck disable` im Delta |
| **`AGENTS.md` §3.9 (Docker-only)** | geprüft, ohne Befund: kein Rezept ruft ein Host-Werkzeug in der Befehlsposition; das Fragment arbeitet mit `bash`, `git`, `awk`, das Bild kommt aus `d-check.mk`; die `/tmp`-Sonden dieses Laufs sind Wegwerf-Dateien außerhalb des Repos |
| **`AGENTS.md` §3.6 (Rot-Beleg je Zusage)** | geprüft, ohne Befund: der neue Fall `332` trägt seinen `# expect:`-Text verbatim in der Fehlschlag-Ausgabe, und die Commit-Message nennt Bedingung und gelesene Meldung |
| **`AGENTS.md` §3.11 (Adresse in einfrierendem Artefakt)** | geprüft, ohne Befund: die neuen Texte nennen kein Artefakt, dessen Ort der Prozeß bewegt, bei seinem Pfad; `LH-*`/`§`-Kennungen stehen als Inline-Code |
| **`MR-025` (Zahl neben Kommando)** | geprüft, ohne Befund: die neuen Texte führen keine Zahl als Erwartungswert |
| **Gate-Lockerung ohne ADR (§3.5)** | geprüft, ohne Befund: das Delta nimmt **zwei** stille Pfade weg (die zweite Ziel-Hälfte) und fügt an der Probe selbst keinen hinzu; keine Schwelle, kein Modul, keine Strenge gesenkt. R4-1 ist eine **neue Umgehungs**-Fläche, keine Lockerung im Sinne des §3.5 (nichts wird abgeschaltet, nichts herabgestuft) |
| **Das Sensor-Dokument gegen den neuen Stand** | geprüft, mit Grenze: es nennt weiter beide Ziele und beide **Auslöser**-Klassen („zweimal gefahren, mit entfernter Ziel-Zeile und … einer Ziel-Zeile ohne Rezept“) — nach dem Delta sind es vier rote Läufe plus die Randlage. Der Satz bleibt lesbar (die zwei Auslöser sind die zwei), die **Zahl** ist aber nicht an ein Kommando gebunden: sie steht als Prosa ohne `grep`/`make`, und ein Leser kann die Abdeckung an ihr nicht abzählen (§2 zählt die Zeilen) |
| **Traceability der Commit-Messages** | geprüft, ohne Befund: `d8ab4835` und `1b060790` nennen `LH-FA-06`/`LH-QA-01` und tragen die Rolle im Betreff; beide benennen Bedingung, gelesene Meldung und die Grenze („kein voller `make mutate`“) |
| **Rollentrennung (§3.8/§3.10/ADR-0028)** | geprüft, ohne Befund: kein Commit dieses Deltas berührt Hard Rule, Adaptions-Eintrag, ADR oder Closure-Artefakt; beide sind Implementer-Arbeit am eigenen Gegenstand |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 (N-5 geschlossen) |
| LOW | 1 (R4-1, neu) |
| INFO | 1 (R4-2, Grenze des §3.7-Geltungsbereichs) |

**Finding-Klassen dieses Laufs:** fail-closed-probe-als-kommandozeilen-ueberschreibbare-make-variable ·
konjunktiv-klausel-in-sensor-prosa-jenseits-des-3.7-geltungsbereichs

Die Runde-3-Klassen `doppelte-probe-ohne-zweiseitigen-negativtest` und
`konjunktiv-ueber-die-verworfene-alternative-in-umgeschriebener-klausel` sind **geschlossen** —
die zweite an den drei Code-Stellen, mit der Prosa-Grenze als R4-2.
`dieselbe-menge-in-drei-literalen-nennungen-ohne-ableitung` (N-3) ist **unverändert offen** und
gehört dem Architect; das Delta hat sie nicht vergrößert und nicht verkleinert
(`grep -c 'doc-immutable' internal/emit/emit.go` → 10 Zeilen mit Prosa,
`grep -c 'doc-commits'` → 7 — dieselbe Größenordnung wie in Runde 3, strukturell **fünf** je Ziel:
`awk`-Muster → jetzt **eine** Zelle, Bindungs-Zeile, Abbruch-Ziel-Zeile, Meldung,
`vorbindungsTargets()`; die Muster-Zelle ist damit auf **eine** zusammengefallen). Ob das den
Zähler bewegt, entscheidet die Slice-Closure §7 — dieser Report zählt nicht.

## Verdikt

**Merge-blockierend: nein** — kein HIGH und kein MEDIUM. **N-5 ist behoben**, gemessen an vier
eigenen Driften, von denen drei die `doc-commits`-Hälfte treffen, die vor dem Delta keinen Wächter
hatte; **N-6 ist an den drei genannten Stellen behoben**. **R4-1 (LOW)** ist die eine Kante, die die
Behebung neu erzeugt, und sie ist benannt statt still entschieden: sie braucht eine ausdrückliche
Kommandozeilen-Zuweisung, die heute **nichts** im Repo, in der CI oder im emittierten Ziel setzt,
und sie verschiebt die Entscheidung der Probe nicht — sie macht sie überschreibbar. Wer sie
schließen will, entscheidet das im Implementer-Lauf; **kein Lösungsvorschlag von hier** (Skill
§Was dieser Skill NICHT macht).

**Was dieser Lauf zu den Auftrags-Fragen sagt.** (1) Der Runde-3-Angriff auf Zeile 100 ist inert,
und die **andere** Richtung ist gefahren: die **Variable** läßt sich verfälschen — über die
Kommandozeile, nicht über den Baum; die Klasse ist damit **verschoben**, aber nicht in den Baum
hinein (§6, R4-1). (2) `make full-smoke` ist selbst gefahren, **sechs** Zusicherungen gezählt, und
die vier roten Lagen fallen **einzeln** — drei davon in diesem Lauf belegt; die vierte (Zusicherung
1) ist hier **nicht** nachgemessen — ihr Beleg liegt beim Fall `329` (§3, §4). (3) Die Meldungen der
selbst gefahrenen Fälle `331` und `332` tragen die behauptete Ursache. (4) Der Nachzug `1b060790`
trifft **genau eine** Fundstelle, und **kein** weiterer Operand hat sein Ziel verloren (§5). (5) N-6 ist
an drei Stellen behoben, **kein** Verweis auf die vorige Fassung steht in den neuen Zeilen (§5, Verdikt-Tabelle).

**Offen geblieben in diesem Lauf** (was dieser Report **nicht** geprüft hat): (a) ein **eigener**
voller `make mutate` — Weisung: Post-integration (`.github/workflows/mutate.yml`); die Fälle `329`
und `330` sind **nicht** selbst gefahren, ihr Beleg ist nicht nachgemessen; (b) die **N-3**-Struktur-Frage
(Ableitung der zwei Zielnamen) — unverändert offen, beim Architect; (c) `.claude/agents/implementer.md`
und `.claude/commands/implement-slice.md` über den Prüfstand hinaus; (d) die span-/Telemetrie-Achse.

**Übergabe:** **R4-1** geht an den **Implementer** (LOW — vor Merge zu entscheiden ist er nicht).
**R4-2** und die **N-3**-Struktur-Frage gehen an den **Architect**. Die Finding-Klassen dieses Laufs
gehen in die Slice-Closure §7 und von dort in das Beobachtungs-Register.

Dieser Report ist ein **Lauf-Beleg** (Audit: dieses Delta, dieser Skill, dieses Modell, dieses
Verdikt) — er wird über Läufe hinweg nicht wieder gelesen und muss es nicht. Er ersetzt keine
Verifikation: DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).

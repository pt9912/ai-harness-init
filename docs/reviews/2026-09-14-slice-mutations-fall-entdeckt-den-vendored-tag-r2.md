# Review-Report (Runde 2): slice-mutations-fall-entdeckt-den-vendored-tag — 2026-09-14

**Review-Art:** Code-Review, **Nachtrags-Runde** — geprüft wird der Nachbesserungs-Commit gegen den
Report der ersten Runde und gegen die Hard Rules (Modul 10 §Drei Review-Arten). Gegenstand sind ein
Shell-Treiber, sechs Mutations-Fälle, eine bats-Datei und ein Sensor-Vertrag.

**Gegenstand:** ein Commit `f668cb35` (Rolle Implementer), scoped. **Geprüfter Stand:** `f668cb35`
(HEAD, `main`), `git status --porcelain` leer. **Kein Self-Review:** dieser Lauf hat an dem Commit
nicht geschrieben; er ist auch nicht der Lauf, der Runde 1 schrieb — die Findings von dort sind
Eingabe, nicht Ergebnis.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-14

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

- der Report der ersten Runde, `docs/reviews/2026-09-14-slice-mutations-fall-entdeckt-den-vendored-tag.md`
  (F-1 … F-9, Verdikt blockierend) — als **Prüfliste**, nicht als übernommenes Ergebnis
- Slice-Plan `slice-mutations-fall-entdeckt-den-vendored-tag` (§1 Ziel/Abgrenzung, §2 DoD, §6 Risiken)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.2, §3.6, §3.7, §3.8, §3.9, §3.10)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`ADR-0035`](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) —
  Bezugsmenge des Beleg-Schlüssels
- `make mutate` §Vertrag und §Grenze (der öffentliche Vertrag, den der Slice berührt)
- Baseline `v6.8.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für
  DoD-Testbehauptungen · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
- Vorherige Findings am selben Modul: die Review-Reports zu `slice-047`, `slice-100`, `slice-117`,
  `slice-180` und die Runde 1 dieses Slice — daraus die wiederkehrende Klasse
  `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf über `f668cb35` selbst gefahren. **Keine Zahl
und keine Eigenschaft ist aus der Commit-Message oder aus Runde 1 übernommen** — auch dort, wo das
Ergebnis mit der Behauptung übereinstimmt.

### 1. Ist der Commit wirklich reine Kommentar-Änderung? — drei unabhängige Messungen

Die Commit-Message behauptet „Reine Kommentar-Korrektur ohne Verhaltensaenderung an keiner
geprueften Stelle". Der Umfang ist neun Dateien, +36/−32 (`git show f668cb35 --stat`).

**(a) Keine geänderte Zeile außerhalb der Kommentar-Position.** Über alle `*.sh`/`*.bats` des Diffs:

```sh
git show f668cb35 -U0 -- '*.sh' '*.bats' | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' \
  | grep -vE '^[+-][[:space:]]*#'
```

leer, EXIT 1. Die einzigen Nicht-`#`-Änderungen des ganzen Commits liegen in
`harness/sensors/mutate.md` und sind Prosa.

**(b) Der ausführbare Rest ist byte-gleich.** Für jede der acht Shell-/bats-Dateien wurden alle
`#`-Zeilen entfernt und der Rest gehasht, vorher gegen nachher:

| Datei | Rest ohne `#`-Zeilen |
|---|---|
| `harness/tools/mutate.sh` | identisch (`9c5de5a937cbae0a`) |
| `test/mutate-driver.bats` | identisch (`c2051af119028b6c`) |
| `219-…`, `220-…`, `224-…`, `244-…`, `248-…`, `324-…` | je identisch |

**(c) Keine `#`-Zeile ist in Wahrheit Nutzlast.** Zwei Kanäle, an denen eine `#`-Zeile im Treiber
mehr als ein Kommentar sein kann, wurden einzeln ausgeschlossen:

- **Here-Doc:** `grep -nE "<<-?'?[A-Z_]+'?" harness/tools/mutate.sh` liefert nur Prosa-Treffer,
  kein Here-Doc-Operator; die Datei führt keines. Eine `#`-Zeile kann dort also nicht Daten sein.
- **Fall-Direktiven:** In einem Mutations-Fall *sind* `# files:`, `# expect:` und `# verify:`
  Metadaten. Für alle sechs berührten Fälle sind genau diese Zeilen byte-gleich geblieben
  (`sed -n -e 's/^# files: /F|/p' -e 's/^# expect: /E|/p' -e 's/^# verify: /V|/p'`, Hash vorher
  gegen nachher). Und keine **eingefügte** Zeile ist selbst eine Direktive:
  `git show f668cb35 -U0 -- 'test/mutations/*' | grep -cE '^\+# (files|expect|verify): '` → **0**.
  Der Parser ist `sed -n 's/^# files: //p'` (`mutate.sh:278`, `:629`) und damit zeilenanfang-fest;
  die geänderten Zeilen beginnen mit ``# ` ``.

**Befund: die Behauptung trägt.** Der `sed`-Operand von Fall 324 ist byte-identisch (`od -c` der
letzten zwei Zeilen, gleicher md5 vorher/nachher) und trifft im neuen `mutate.sh` weiterhin
**genau einmal** (`grep -cF '[ "$n" -eq 1 ] || return 1'` → 1, Zeile 258).

### 2. Der Verzicht auf `make mutate` — der Kanal, der ihn kippen könnte

Byte-Gleichheit des ausführbaren Teils allein deckt den Verzicht **nicht**: `harness/tools/mutate.sh`
ist selbst Ziel von Mutations-Fällen, und Bedingung 2 des Treibers verlangt, dass eine Mutation die
Datei *ändert*. Hätte eine umformulierte Kommentar-Zeile den `sed`-Operanden eines fremden Falls
getragen, wäre dieser Fall jetzt wirkungslos — und `make mutate` rot.

Gemessen wurde über **alle** Fälle, deren `# files:` auf `harness/tools/mutate.sh` auflöst: je Fall
eine Wegwerf-Kopie der **alten** und der **neuen** Fassung, Fall ausgeführt, `sha256sum` vorher
gegen nachher.

```text
geprueft: 27 Faelle mit '# files: harness/tools/mutate.sh'
Bedingung-2-Ergebnis alt != neu: 0
davon auf dem NEUEN Stand wirkungslos (NO-OP): 0
```

*(Die erste Fassung dieser Messung war durch ein `eval`-Quoting-Problem wirkungslos — sie verglich
leere Variablen und meldete deshalb ebenfalls „0". Die Zahlen oben stammen aus dem korrigierten
Lauf ohne `eval`; die kaputte Fassung ist verworfen, nicht ausgewertet.)*

Zwei weitere Kanäle, ebenfalls leer:

- Kein Mutations-Fall zielt auf `harness/sensors/mutate.md` oder `test/mutate-driver.bats`
  (`sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sort -u | grep -E 'mutate\.md|mutate-driver'`
  → kein Treffer). Die Änderungen dort können Bedingung 2 also gar nicht berühren.
- Keine `# expect:`-Zeichenkette des Bestands kommt im **entfernten** Text dieses Commits vor
  (alle `# expect:`-Werte gegen die `-`-Zeilen des Diffs, 0 Treffer). Bedingung 4 — „der erwartete
  Wächter steht in der Fehlschlag-Ausgabe" — hängt damit an keiner geänderten Zeile.

**Verdikt zu Punkt 3 der Aufgabe:** Der Verzicht auf einen erneuten `make mutate`-Lauf ist
**gedeckt**. Die Grenze dieser Aussage, ausdrücklich benannt: Bedingung 3 und 4 (Sensor wird rot,
und aus dem richtigen Grund) sind hier **nicht** nachgefahren worden; gezeigt ist, dass keine
geänderte Zeile in einen Pfad reicht, der sie bewegen könnte.

### 3. F-1 — die drei Chronik-Stellen

Die drei von Runde 1 benannten Wortlaute sind an den drei Stellen weg
(`grep -nE 'alter Fassung|schon einmal beseitigt|vorher blieb hier'` über den neun Dateien trifft
keine davon mehr). Die Ersatztexte im Einzelnen geprüft:

| Stelle | Ersatz | Urteil |
|---|---|---|
| `mutate.sh:265` (`mutation_targets`) | „Iteriert PRO Fall, damit ein Abbruch den FALL nennt …" | Chronik entfernt, Indikativ, trifft den Code (Schleife `for case_file` ab `:270`) |
| `mutate.sh:252` (`resolve_file_spec`) | „zwei getrennt gepflegte Ausloesungen **waeren** dieselbe Drift-Konstruktion wie bei failure_form (eine Quelle, keine zweite Liste)" | Chronik entfernt — **aber Modus gekippt**, siehe N-1 |
| `test/mutate-driver.bats:227` | „mit einer Meldung, die den Fall nennt — nicht nur ‚Fingerabdruck der Mutations-Ziele nicht berechenbar'" | sauber: der zitierte Satz ist **kein** abwesender Text, er steht real in `mutate.sh:1576`; der Kontrast ist zwischen zwei **gegenwärtigen** Meldungen |

### 4. F-2 — die vier Herkunfts-Anker

`grep -nE 'DoD dieses Slice|DoD 1|slice-mutations-fall-entdeckt-den-vendored-tag'` über den neun
Dateien: **kein Treffer**. Alle vier Stellen tragen jetzt eine zulässige Form:

- `mutate.sh:650` → `(LH-QA-01)`
- `test/mutate-driver.bats:190` → `traegt LH-QA-01`
- `test/mutate-driver.bats:189` → Abschnittsmarke ohne Slice-Kennung
- `test/mutations/324-…sh:14` → „Haelt AGENTS.md §3.6 wach … (LH-QA-01)"

Beide Formen sind im Repo etabliert und nicht für diesen Commit erfunden: `LH-QA-01` stand vor dem
Commit bereits an **6** Stellen in `mutate.sh` (unverändert 6 danach) und in **22** Dateien unter
`test/mutations/`; `AGENTS.md §3.6` in **4**. *Keine Erwartungswerte* — beide Zahlen wandern mit dem
Bestand. Die Form „AGENTS.md §3.6" ist dabei kein Herkunfts-Feld, sondern ein **Rang-Zeiger** (Rang 8
der Source Precedence) und damit eine der fünf zulässigen Kommentar-Klassen.

### 5. F-3 — die Zusagen-Differenzierung, an der Mechanik nachgemessen

Die neue Zusage lautet in beiden Artefakten: `mutation_targets` bricht den **ganzen** Lauf ab (vor
jeder Isolationskopie), `run_case` meldet einen Befund für **diesen** Fall und der Lauf geht weiter.
Am Code geprüft:

| Behauptung | Fundstelle | Trägt? |
|---|---|---|
| `run_case` → Befund, Lauf geht weiter | `:655-657` — `report_fail`, dann `return`; `report_fail` (`:544-547`) zählt `fail_count` hoch und schreibt `mutate: BEFUND  <name>  …` | ja |
| `mutation_targets` → ganzer Lauf ab | `:1575-1578` — `target_fingerprint` scheitert, `echo "mutate: ABBRUCH …"`, `exit 1` | ja, am **Vorlauf**-Aufrufer |
| „vor jeder Isolationskopie" | `exit 1` steht auf `:1578`, das erste `ISO_ROOT="$(mktemp -d)"` auf `:1580` | ja |
| beide Meldungen nennen den Fall | `:274` (`$(basename "$case_file" .sh)`) und `:656` über `report_fail "$name"` | ja |

Die Vokabel-Trennung ist im Treiber real und nicht bloß rhetorisch: `grep -c 'mutate: ABBRUCH'` →
**19**, `grep -c 'mutate: BEFUND'` → **1** (das eine `printf` in `report_fail`). *Keine
Erwartungswerte.*

**Dabei ist der zweite Aufrufer aufgefallen** — `mutation_targets` läuft über `target_fingerprint`
ein zweites Mal, nach dem Lauf (`:1710`), und dort wird derselbe Rückgabewert zu
`report_fail "host-baum" …` statt zu einem Abbruch. Siehe N-2.

### 6. F-4 — die fünf Überschriften

`grep -rn 'NENNT DEN TAG NICHT MEHR' test/mutations/` → kein Treffer. Die neue Überschrift
„`# files:` ENTDECKT DAS TAG-VERZEICHNIS" ist sachlich gedeckt: alle fünf `# files:`-Zeilen führen
den Glob mit `*` an der Tag-Stelle (`.harness/baseline/*/templates/…`, je einzeln gelesen), und die
Auflösung liefert den Tag-Anteil (Sonde in §7: `baum/*/templates` → `baum/v1.0.0/templates`).

### 7. F-5 — `compgen -G` und das Verzeichnis, als Sonde gefahren

`resolve_file_spec` wörtlich aus `f668cb35` kopiert und gegen einen Wegwerf-Baum gefahren:

| Eingabe | Ergebnis |
|---|---|
| existierende Datei, literal | rc=0, der Pfad |
| fehlende Datei, literal | rc=1, leer |
| **existierendes Verzeichnis, literal** | **rc=0, der Pfad** |
| Glob, genau ein Tag-Verzeichnis | rc=0, der aufgelöste Pfad |
| Glob, zwei Treffer | rc=1, leer |
| `root` existiert nicht | rc=1, leer |

Der neue Kommentar — „nur, wenn ETWAS unter diesem Namen da ist (eine Datei ODER ein Verzeichnis;
die Unterscheidung trifft compgen -G nicht)" — ist damit **zutreffend**; die alte Zusage „nur, wenn
die Datei da ist" ist weg (`grep -n 'nur, wenn die Datei da ist'` → kein Treffer). F-5 ist als
*Kommentar*-Befund eingelöst; dass die Angabe erst an `sha256sum` fiele, bleibt unverändert und war
schon in Runde 1 keine Verhaltens-Forderung.

### 8. Gate-Läufe dieses Review-Laufs

| Lauf | Ergebnis |
|---|---|
| `make docs-check` | `d-check: 1346 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 |
| `make comment-claims` | `comment-claims: 58 Datei(en) geprueft, 0 Befund(e)`, EXIT 0 |
| `make shell-lint` | EXIT 0 |
| `make test-bats` | EXIT 0; `ok 165`, `ok 166`, `ok 167` sind die drei Fälle dieses Slice |

*Keine Erwartungswerte* — die Dateizahlen wandern mit dem Baum. `make mutate` wurde nicht gefahren;
warum das hier gedeckt ist und wo die Deckung endet, steht in §2.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Spalten unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

Die Nummerierung ist **N-**, nicht **F-** — die F-Nummern gehören Runde 1 und werden hier nur
zitiert.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | LOW | Die F-1-Korrektur tauscht Chronik gegen **Konjunktiv über die verworfene Alternative**: aus „zwei getrennt gepflegte Ausloesungen **sind** dieselbe Drift-Konstruktion, die dieses Repo … schon einmal beseitigt hat" wurde „… **waeren** dieselbe Drift-Konstruktion wie bei failure_form". Die Chronik ist damit weg, der Modus liegt aber in genau der Form, die `AGENTS.md` §3.7 als *Falsch* aufführt. Drei unberührte Geschwister-Sätze derselben Aussage in derselben Datei stehen weiter im Indikativ — die Datei führt die Kopplungs-Aussage jetzt in zwei Fassungen. | `AGENTS.md` §3.7 (*„Falsch: … Konjunktiv über die verworfene Alternative"*) | `harness/tools/mutate.sh:252-253` | nein — `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht, worüber ein Kommentar spricht (`AGENTS.md` §3.7 §Ein Wächter existiert nicht) | kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle |
| N-2 | LOW | Die F-3-Korrektur sagt zu: „`mutation_targets` bricht darauf den **GANZEN** Lauf ab (vor jeder Isolationskopie)". `mutation_targets` hat über `target_fingerprint` **zwei** Aufrufer: `:1575` (vor dem Lauf) → `exit 1`, Zusage trägt; `:1710` (nach dem Lauf) → `report_fail "host-baum" …`, der Lauf läuft zu Ende und die Meldung nennt **nicht** den Fall, sondern `host-baum`. Die neue Zusage ist an einem der beiden Aufrufer unzutreffend. | `AGENTS.md` §3.7 (*„die Zusage auf das einschränken, was der Code hält"*) | `harness/tools/mutate.sh:26-29`, `harness/sensors/mutate.md:33-35` (Gegenstelle `harness/tools/mutate.sh:1710-1713`) | ja — eine `# files:`-Zieldatei während eines Laufs entfernen; der Lauf endet mit `mutate: BEFUND  host-baum …` statt mit einem Abbruch | zusage-vereinheitlicht-zwei-stellen-mit-verschiedener-fehlschlag-form |
| N-3 | LOW | Der Commit trennt „Befund" von „Abbruch" im Skript-Kopf und im Sensor-Vertrag, lässt die **dritte** Stelle aber auf der alten, vereinheitlichten Fassung: der bats-Kopf sagt, eine nicht auflösende Angabe „ist ein Befund mit dem Namen des Falls — an **BEIDEN** Stellen". Im Treiber ist `BEFUND` ein Fachwort (**1** `printf` in `report_fail`, gezählt in `fail_count`) gegen **19** `ABBRUCH`-Zeilen. Der Wortlaut ist Bestand; dieser Commit hat den Block umbrochen und seinen Anker getauscht und damit die Divergenz zwischen zwei lebenden Artefakten erzeugt. Der nächste Kommentar-Block derselben Datei (`:225-228`) zieht die Unterscheidung ausdrücklich. | `AGENTS.md` §3.7 · Maintainability | `test/mutate-driver.bats:190-193` (Gegenstelle `harness/tools/mutate.sh:26-29`) | ja — beide Köpfe nebeneinander lesen; die Sonde aus §5 zeigt beide Fehlschlag-Formen | zusage-vereinheitlicht-zwei-stellen-mit-verschiedener-fehlschlag-form |
| N-4 | INFO | Die Form „ohne X wäre/könnte …" steht unverändert auf zwei Zeilen, die dieser Commit **neu geschrieben** hat: „— sonst schrumpfte die Ziel-Menge leiser, als LH-QA-01 zulaesst" und „ohne diesen Zahn koennte die Zahl-Schranke … unbemerkt aufweichen, und die Zusage … waere nur im Feedforward-Quadranten". Runde 1 hat genau diese Zeilenbereiche zitiert (F-1 `pfad` `mutate.sh:261`, F-2 `pfad` `324-…sh:14`) und die Form **nicht** beanstandet. Ob der kontrafaktische Modus selbst unter §3.7 fällt oder als Grenz-/Zusagen-Begründung trägt, ist eine Klassifikations-Frage — Architect, nicht Implementer. Ohne diesen Eintrag sähe N-1 wie ein verschobener Maßstab aus. | `AGENTS.md` §3.7 §Geltungsbereich | `harness/tools/mutate.sh:266`, `test/mutations/324-mutate-files-schranke-erlaubt-mehrfachtreffer.sh:14-16` | nein | kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle |
| N-5 | INFO | Der von F-1 beanstandete Satzteil „die dieses Repo an `failure_form` schon einmal beseitigt hat" steht unverändert an **drei** weiteren Stellen derselben Datei. Alle drei liegen außerhalb dieses Diffs und fallen unter den Cutoff von §3.7 (*„der Bestand ist kein Arbeitsauftrag dieser Sektion"*) — **kein Implementer-Punkt**. Genannt, weil es N-1 erklärt: die eine korrigierte Instanz ist jetzt die einzige von vieren in abweichendem Modus. | `AGENTS.md` §3.7 §Cutoff | `harness/tools/mutate.sh:192`, `:342`, `:1309` | nein | kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle |
| N-6 | INFO | Ein Kommentar im Treiber adressiert das Beobachtungs-Register als `BEO-025` in `docs/plan/planning/observations.md`. Die Datei existiert nicht mehr; das Register läuft in Verzeichnis-Form (`docs/plan/planning/observations/BEO-ALL/<slug>/`, gemessen **112** Verzeichnisse, kein Erwartungswert), und `BEO-025` ist keine vergebene Kennung dieser Form. Außerhalb dieses Diffs, Bestand — genannt, weil kein Gate diese Adresse liest (`make comment-claims` prüft genannte **Sensoren**, nicht Pfade). | Maintainability | `harness/tools/mutate.sh:1530` | ja — `ls docs/plan/planning/observations.md` schlägt fehl | tote-adresse-in-lebendem-kommentar |
| N-7 | INFO | Die vier INFO-Findings der ersten Runde sind unverändert: F-6 (die **Null-Treffer**-Richtung der Schranke trägt weiter keinen Mutations-Fall — Fall-Bestand unverändert **310**, `git show f668cb35 --diff-filter=A --name-only` leer), F-7 (der Kopf nennt „literaler Pfad", faktisch läuft alles durch `compgen -G`), F-8 (Plan-Reihenfolge am Commit nicht ablesbar), F-9 (der `*.bats`-Geltungsbereich von §3.7). Sie trugen in Runde 1 keine Pflicht und tragen auch hier keine; F-9 bleibt beim Architect und ist für N-3 einschlägig — der §3.7-Pathspec (`AGENTS.md:238`) führt `*.bats` nicht. | Runde 1, F-6…F-9 | `test/mutations/`, `harness/tools/mutate.sh:239`, `AGENTS.md:238` | teils | vorrunden-info-ohne-aenderung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **F-1 (HIGH), Stelle 1 — `mutation_targets`** | geprüft, **behoben**: „alter Fassung" entfernt, Ersatz im Indikativ und am Code gedeckt (Schleife `for case_file` ab `:270`) |
| **F-1 (HIGH), Stelle 2 — `resolve_file_spec`** | geprüft, **Chronik behoben**; Restbefund zum Modus als N-1 (LOW), keine Chronik mehr |
| **F-1 (HIGH), Stelle 3 — bats** | geprüft, **behoben**: der Kontrast nennt eine Meldung, die real in `mutate.sh:1576` steht — kein abwesender Text |
| **F-2 (HIGH), alle vier Stellen** | geprüft, **behoben**: keine `DoD`-/Slice-Kennung mehr in den neun Dateien; `LH-QA-01` und `AGENTS.md §3.6` sind etablierte, auflösende Formen (6 bzw. 4 Vorkommen im Bestand vor dem Commit) |
| **F-3 (MEDIUM)** | geprüft, **behoben** an beiden benannten Stellen; beide Halbsätze am Code nachgemessen (§5). Der dritte, nicht benannte Ort wird N-3, der zweite Aufrufer N-2 |
| **F-4 (LOW)** | geprüft, **behoben**: Wortlaut an allen fünf Stellen weg, Ersatz sachlich gedeckt (Globs einzeln gelesen) |
| **F-5 (LOW)** | geprüft, **behoben**: Verzeichnis-Verhalten von `compgen -G` als Sonde bestätigt, Kommentar trifft es |
| **Kommentar-only-Behauptung** | geprüft, ohne Befund: drei unabhängige Messungen (§1) — keine Nicht-`#`-Zeile in Shell/bats, ausführbarer Rest byte-gleich, keine `#`-Zeile ist Direktive oder Here-Doc-Nutzlast |
| **Verzicht auf `make mutate`** | geprüft, ohne Befund: 27 Fälle mit `# files: harness/tools/mutate.sh`, Bedingung-2-Ergebnis alt gegen neu **0** Abweichungen, **0** Fälle auf dem neuen Stand wirkungslos; kein Fall zielt auf `mutate.md`/`mutate-driver.bats`; keine `# expect:`-Zeichenkette im entfernten Text. Grenze benannt in §2 |
| **`sed`-Operand von Fall 324** | geprüft, ohne Befund: byte-identisch (`od -c`/md5 vorher gegen nachher) und trifft im neuen `mutate.sh` genau einmal (`:258`) |
| **`# expect:`-Kopplung von Fall 324** | geprüft, ohne Befund: die Zeile zitiert den bats-Testnamen weiterhin wörtlich (`grep -F "@test \"$E\""` trifft), obwohl der Kommentar daneben umgeschrieben wurde |
| **Regression am Rest der neun Dateien** | geprüft, ohne Befund: `--numstat` zeigt neun Dateien, die Hunks liegen ausschließlich in Kommentar-/Prosa-Blöcken; keine eingefügte Zeile trägt Trailing-Whitespace oder Tab |
| **Regression außerhalb der neun Dateien** | geprüft, ohne Befund: der Commit berührt keine weitere Datei; `git diff f668cb35..HEAD` über den neun ist leer (`f668cb35` **ist** HEAD), `git status --porcelain` leer |
| **Neue §3.7-Verstöße durch die Umformulierung** | geprüft, mit Befund N-1 (Modus-Kippen) und N-3 (einseitig gezogene Zusage); darüber hinaus ohne Befund — kein neu eingeführter abwesender Text, keine neue Befund-Kennung, kein neues Lauf-Protokoll, kein abgebrochener Satz |
| **Neue Ungenauigkeiten in den Ersatztexten** | geprüft, ohne weiteren Befund: die F-4-Überschrift, die F-5-Aussage über `compgen -G` und beide Halbsätze der F-3-Trennung sind einzeln am Code bzw. an einer Sonde nachgemessen |
| **`AGENTS.md` §3.2 (Lint-Suppression)** | geprüft, ohne Befund: keine `# shellcheck disable`-Zeile im Diff; `make shell-lint` EXIT 0 |
| **`AGENTS.md` §3.6 (Zusage mit rotem Gegenbeispiel)** | geprüft, ohne Befund: der Commit setzt keine neue Zusage, er nimmt zwei zurück; die drei Zähne von Runde 1 laufen unverändert grün (`ok 165/166/167`) |
| **`AGENTS.md` §3.8 / §3.10 (Rollen-Eigentum)** | geprüft, ohne Befund: keine Hard Rule, kein Adaptions-Eintrag, keine ADR, kein Slice-Plan, kein Closure-Artefakt im Diff; die Message nennt die Rolle |
| **`AGENTS.md` §3.9 (Docker-only)** | geprüft, ohne Befund: keine Host-Toolchain im Diff |
| **`ADR-0035` — Bezugsmenge des Beleg-Schlüssels** | geprüft, ohne Befund: `isolation_key_files` und die beiden Ausnahme-Listen sind im Diff nicht enthalten |
| **Halluziniertes Gate (`LH-QA-01`)** | geprüft, ohne Befund: kein neues Target behauptet; `harness/README.md` unberührt |
| **Traceability / `MR-051`** | geprüft, ohne Befund: die Message nennt `LH-QA-01` und `AGENTS.md` §3.7; die Zahl darin (`310 ok, 0 Befund(e)`) steht neben dem Lauf, der sie lieferte, und ist als Beleg des **Vorgänger**-Commits gekennzeichnet |
| **Gate-Läufe** | geprüft, ohne Befund: `make docs-check` 1346/0, `make comment-claims` 58/0, `make shell-lint` EXIT 0, `make test-bats` EXIT 0 — alle vier in diesem Lauf real gefahren |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 4 |

**Finding-Klassen dieses Laufs:** kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle ·
zusage-vereinheitlicht-zwei-stellen-mit-verschiedener-fehlschlag-form ·
tote-adresse-in-lebendem-kommentar · vorrunden-info-ohne-aenderung

Die ersten beiden Klassen sind dieselben wie in Runde 1. **Sie zählen deshalb nicht neu:** Ein
Vorgang zählt einmal, und Runde 1 und Runde 2 prüfen denselben Slice — das ist **ein** Vorgang, nicht
zwei. Die Zuordnung und das Anlegen der Belege sind Sache der Slice-Closure, nicht dieses Reports.

## Verdikt

**Merge-blockierend: nein.** Die beiden HIGH und das MEDIUM der ersten Runde sind eingelöst, und
zwar an jeder der neun benannten Stellen — nicht abgenommen, sondern in diesem Lauf einzeln
nachgemessen (§3 bis §7). Auch die zwei LOW sind mitgenommen und tragen.

Die Behauptung, auf der der Verzicht auf `make mutate` ruht, ist **eigenständig bestätigt** und
nicht übernommen: Der Commit ändert keine ausführbare Zeile, und — der Kanal, den Byte-Gleichheit
allein nicht deckt — keiner der 27 Mutations-Fälle, die auf `harness/tools/mutate.sh` zielen, wird
durch die umformulierten Kommentare wirkungslos. Was diese Deckung **nicht** einschließt, steht in
§2 benannt.

Die drei verbleibenden LOW sind Kommentartext und betreffen keine Zeile ausführbaren Codes. N-1 und
N-3 sind Nebenwirkungen der Nachbesserung selbst — der typische Kanal, den diese Runde suchen
sollte: eine einseitig gezogene Zusage (N-3) und ein beim Umschreiben gekippter Modus (N-1). Beide
sind billig und kein Grund, den Merge aufzuhalten; N-4 hält fest, warum N-1 kein verschobener
Maßstab ist.

**Übergabe:** N-1, N-2 und N-3 gehen an den Implementer. N-4, N-5, N-6 und die F-9-Hälfte von N-7
sind **keine** Implementer-Punkte und gehen als offene Fragen an den Architect — sie betreffen den
Geltungsbereich von `AGENTS.md` §3.7 und Bestand außerhalb des Diffs. Die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler, als **derselbe** Vorgang wie Runde 1.
Dieser Report ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell, dieses
Verdikt) — er wird über Läufe hinweg nicht wieder gelesen, und muss es nicht. Der Report ersetzt
keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes
Prüf-Artefakt, anderer Eingabe-Kontext).

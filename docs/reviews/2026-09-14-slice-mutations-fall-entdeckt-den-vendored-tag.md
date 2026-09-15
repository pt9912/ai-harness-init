# Review-Report: slice-mutations-fall-entdeckt-den-vendored-tag — 2026-09-14

**Review-Art:** Code-Review — geprüft wird der Diff gegen den Slice-Plan und gegen die Hard Rules
(Modul 10 §Drei Review-Arten). Gegenstand sind ein Shell-Treiber, sechs Mutations-Fälle, eine
bats-Datei und ein Sensor-Vertrag.

**Gegenstand:** ein Commit `f3055672` (Rolle Implementer). **Geprüfter Stand:** `f3055672`
(HEAD, `main`), `git status --porcelain` leer. **Kein Self-Review:** dieser Lauf hat an dem
Commit nicht geschrieben.

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
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-mutations-fall-entdeckt-den-vendored-tag` (§1 Ziel/Abgrenzung, §2 DoD,
  §3 Plan inkl. Reihenfolge-Vorgabe, §5 Closure-Trigger, §6 Risiken, §8 Sichtungs-Schritt)
- [`ADR-0035`](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) —
  Bezugsmenge des Beleg-Schlüssels (`isolation_key_files`), Festlegung 3
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.2, §3.6, §3.7, §3.8, §3.9, §3.10)
- [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
- `make mutate` §Vertrag und §Grenze (der öffentliche Vertrag, den der Slice berührt)
- Baseline `v6.8.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für
  DoD-Testbehauptungen · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
- Vorherige Findings am selben Modul: die Review-Reports zu `slice-047` (zwei Runden),
  `slice-100`, `slice-117` (Runde 2) und `slice-180` (drei Runden) — alle zum
  Mutations-Treiber; daraus die wiederkehrenden Klassen `mutations-fall-zeigt-auf-falsche-datei`,
  `mutations-fall-ueberlebt-die-umbenennung-seines-waechters` und
  `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf über `f3055672` selbst gefahren. Keine Zahl
ist aus der Commit-Message übernommen; wo eine Zahl der Message nachgemessen wurde, steht das
dabei.

### 1. Der rote Beleg zu DoD 1 — vom Plan §5 ausdrücklich in diesen Report verlangt

Der Slice-Plan §5 Closure-Trigger 2 verlangt, dass die Meldung **gelesen** ist und den Fall
nennt, und legt den Beleg in den Review-Report statt in die Closure-Notiz. Nachgestellt wurde ein
Fall-Verzeichnis mit genau der Angabe, die der Sprung auf `v6.8.0` getötet hat:

```sh
printf '#!/usr/bin/env bash\n# files: .harness/baseline/v6.7.2/templates/AGENTS.template.md\n# expect: egal\n' > cases/219-toter-tag-nachgestellt.sh
bash -c "source harness/tools/mutate.sh 2>/dev/null || true; mutation_targets <cases> <repo>"
```

Ausgabe, EXIT 1:

```text
mutate: ABBRUCH — 219-toter-tag-nachgestellt: '# files: .harness/baseline/v6.7.2/templates/AGENTS.template.md' loest gegen <maschinen-lokaler Klon> nicht auf genau eine Datei auf.
```

Dieselbe Meldung über `target_fingerprint <repo> <cases>`, ebenfalls EXIT 1. Die Zusage aus DoD 1
— *ein Befund, der den Fall nennt* — ist damit an beiden Aufrufern gehalten und die Meldung
gelesen, nicht nur der Exit-Code.

**Gegenprobe über der alten Fassung** (`git show f3055672^:harness/tools/mutate.sh`, derselbe
Fall): `mutation_targets` liefert EXIT 0 und den toten Pfad, `target_fingerprint` endet in
`sha256sum: … Datei oder Verzeichnis nicht gefunden` mit EXIT 123, woraus `main` die Zeile
`mutate: ABBRUCH — Fingerabdruck der Mutations-Ziele nicht berechenbar.` macht — **ohne** eine
Datei oder einen Fall zu nennen. Der Plan-Befund aus §1, gegen den DoD 3 geschnitten ist, ist
damit unabhängig bestätigt: Die ersetzte Zusage *„daraus macht die Vollständigkeits-Schranke in
`merge_report` einen Befund"* war falsch, der Lauf kam dort nie an.

### 2. Rot-vor-Grün für den neuen Zahn (`AGENTS.md` §3.6)

Die drei neuen `@test`-Rümpfe aus `test/mutate-driver.bats` wurden 1:1 gegen zwei Treiber-Kopien
nachgefahren — einmal unverändert, einmal mit genau der Mutation aus
`test/mutations/324-mutate-files-schranke-erlaubt-mehrfachtreffer.sh` (`-eq 1` → `-ge 1`):

| Treiber | Test „OHNE Treffer" | Test „MEHR ALS EINEM Treffer" | Test „`mutation_targets` BRICHT ab" |
|---|---|---|---|
| unverändert | PASS | PASS | PASS |
| mit Mutation 324 | PASS | **FAIL** | PASS |

Der rot werdende Test ist exakt der, den die `# expect:`-Zeile des Falls nennt, und er fällt aus
dem Grund, den der Fall-Kommentar behauptet — die Ausgabe im mutierten Lauf lautet
`tar: b/ziel.txt\na/ziel.txt: Funktion stat fehlgeschlagen`, also der Dateiname mit eingebettetem
Zeilenumbruch. Damit ist die Anforderung der Baseline `v6.8.0` ·
`regelwerk/modul-11-verification.md` §Bewusstes Brechen — *das Rot trägt die behauptete Ursache*
— an diesem Fall gehalten.

### 3. Fail-closed-Eigenschaft von `resolve_file_spec`, als Sonde gefahren

Die Funktion wurde wörtlich kopiert und gegen einen Wegwerf-Baum gefahren:

| Eingabe | Ergebnis |
|---|---|
| Glob, genau ein Tag-Verzeichnis | rc=0, der aufgelöste Pfad |
| literaler Pfad, Datei existiert | rc=0, derselbe Pfad |
| literaler Pfad, Datei fehlt | **rc=1**, leere Ausgabe |
| Glob, zwei Tag-Verzeichnisse | **rc=1**, leere Ausgabe |
| `root` existiert nicht | **rc=1**, leere Ausgabe |
| Dateiname mit Zeilenumbruch | **rc=1**, leere Ausgabe |
| Dateiname mit Leerzeichen, ein Treffer | rc=0, ein Pfad (nicht gesplittet) |
| Treffer ist ein **Verzeichnis** | rc=0 — siehe LOW-2 |
| Name enthält `[` `]` literal | rc=1 — siehe INFO-2 |

Zusätzlich geprüft, weil die Auflösung **auf dem Host und vor jeder Isolationskopie** läuft: Eine
`# files:`-Angabe mit `$(…)`, mit Backticks, mit `~/` oder mit `{a,b}` wird von `compgen -G`
**nicht** expandiert (rc=1, und die hinterlegte `touch`-Sonde hat nicht gefeuert). Die Angabe kann
also keinen Host-Befehl ausführen, obwohl sie aus einer Datei stammt.

### 4. Bezugsmenge des Fingerabdrucks — unverschoben

```sh
bash -c "source harness/tools/mutate.sh 2>/dev/null||true; mutation_targets test/mutations ." | wc -l    # 65
# alte Fassung + alter Fall-Satz aus f3055672^:                                                           # 65
```

Die Differenz zwischen beiden Listen ist **genau** die dreier Baseline-Pfade `…/v6.7.2/…` →
`…/v6.8.0/…`; alle übrigen 62 Zeilen sind identisch. Jeder der 65 aufgelösten Pfade existiert
(geprüft mit `[ -e ]` über der Liste). Vor dem Commit enthielt dieselbe Menge drei Pfade, die es
nicht gibt. **Keine Erwartungswerte** — die Zahl wandert mit dem Fall-Bestand.

### 5. Die fünf umgestellten Fälle greifen gegen den `v6.8.0`-Satz (§6, Risiko 1)

Über einer Kopie von `.harness/baseline/` wurde jeder der fünf Fälle ausgeführt und die
`sha256sum` seiner Zieldatei vorher/nachher verglichen: **alle fünf** ändern ihre Zieldatei
(rc=0, Bedingung 2 des Treibers erfüllt). Ob der benannte Wächter dann auch rot wird
(Bedingung 3 und 4), trägt der `make mutate`-Lauf des Implementers, nicht diese Messung.

### 6. Gate-Läufe dieses Review-Laufs

| Lauf | Ergebnis |
|---|---|
| `make docs-check` | `d-check: 1345 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 |
| `make shell-lint` | EXIT 0 (Prüfbereich schließt `test/mutations/*.sh` ein, `test/*.bats` nicht) |
| `make test-bats` | EXIT 0; `ok 165`, `ok 166`, `ok 167` sind die drei neuen Fälle |
| `ls test/mutations/*.sh \| wc -l` | 310 — deckt sich mit der Zahl in der Commit-Message |

`make mutate` wurde in diesem Lauf **nicht** gefahren (Laufzeit; der Beleg des Implementers steht
in der Commit-Message samt Kommando, `MR-051` Setzung 1 erfüllt). Die Teilaussagen, die dieser
Report unabhängig braucht, sind oben einzeln gemessen.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Spalten unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Drei neu geschriebene Kommentare beschreiben den **abwesenden Vorzustand** statt der Stelle: „(nicht ueber der geflachten Zeilen-Menge **alter Fassung**)", „… die dieses Repo an `failure_form` **schon einmal beseitigt hat**" und „— **vorher** blieb hier nur die unadressierte Meldung …". Ein späterer Lauf liest „alter Fassung" als Aussage über Code, der nicht da ist. | `AGENTS.md` §3.7 (Cutoff der Quellen-Klausel 2026-08-30) | `harness/tools/mutate.sh:261`, `harness/tools/mutate.sh:247-249`, `test/mutate-driver.bats:226` | nein — `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht, worüber ein Kommentar spricht (`AGENTS.md` §3.7 §Ein Wächter existiert nicht) | kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle |
| F-2 | HIGH | Vier neu geschriebene Kommentare tragen ihre Herkunft als **Erzählung** statt als das eine auflösbare Feld: „(LH-QA-01, **DoD dieses Slice**)" — die Datei nennt keinen Slice, der Zeiger löst nirgends auf —, „Deckt **DoD 1 des Slice** slice-mutations-fall-entdeckt-den-vendored-tag", eine Abschnittsmarke mit der Slice-Kennung und „`resolve_file_spec` **trägt DoD 1**". Ein DoD-Punkt eines wandernden Plans ist keine der zulässigen Anker-Formen. | `AGENTS.md` §3.7 (Herkunft als **ein** auflösbares Feld: `LH-*`, `ADR-*`, `· seit slice-<Kennung>`) | `harness/tools/mutate.sh:647`, `test/mutations/324-mutate-files-schranke-erlaubt-mehrfachtreffer.sh:14`, `test/mutate-driver.bats:189`, `test/mutate-driver.bats:190` | nein — derselbe fehlende Wächter wie bei F-1 | kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle |
| F-3 | MEDIUM | Kopf und Sensor-Vertrag sagen für **beide** Leser der `# files:`-Zeile dieselbe Fehlschlag-Form zu — „bricht den Lauf laut ab und nennt den Fall (`mutation_targets` bzw. `run_case`)". In `run_case` bricht der Lauf nicht ab: dort steht `report_fail` (gemessen: `mutate: BEFUND  02-zwei-treffer …`), die übrigen Fälle laufen weiter, rot wird erst der Gesamtlauf. | `AGENTS.md` §3.7 („die Zusage auf das einschränken, was der Code hält") | `harness/tools/mutate.sh:26-27`, `harness/sensors/mutate.md:33-34` | ja — die Sonde aus §3 dieses Reports zeigt beide Fehlschlag-Formen nebeneinander | zusage-vereinheitlicht-zwei-stellen-mit-verschiedener-fehlschlag-form |
| F-4 | LOW | Fünf gleichlautende neue Absatz-Überschriften bestimmen den Ist-Zustand über den abwesenden Vorzustand: „`# files:` NENNT DEN TAG **NICHT MEHR**". Die mildeste Form von F-1 — der Rest des Absatzes steht durchgehend im Indikativ und ist zutreffend. | `AGENTS.md` §3.7 | `test/mutations/219-…sh:28`, `220-…sh:34`, `224-…sh:18`, `244-…sh:21`, `248-…sh:21` | nein | kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle |
| F-5 | LOW | `resolve_file_spec` löst auch ein **Verzeichnis** auf (gemessen: rc=0), während der Kommentar daneben „nur, wenn die **Datei** da ist" zusagt. Eine solche Angabe passiert die Schranke und fällt erst an `sha256sum "${file_list[@]}"` — dort ohne Fall-Namen und als harter Abbruch des Workers statt als Befund. | `AGENTS.md` §3.7 · `LH-QA-01` | `harness/tools/mutate.sh:250-256` (Zusage `:238-239`) | ja — `# files:` auf ein Verzeichnis zeigen lassen und `run_case` fahren | neue-oeffentliche-funktion-ohne-benannte-grenze |
| F-6 | INFO | Nur die **obere** Richtung der neuen Schranke trägt einen Mutations-Fall: mit `-eq 1` → `-ge 1` bleibt der Test für „kein Treffer" grün (gemessen, §2 dieses Reports). Die Null-Treffer-Richtung — genau die, die den roten CI-Lauf ausgelöst hat — ist nur bats-getestet, nicht mutations-bewacht. Weder `make mutate` §Grenze noch der Treiber-Kopf nennen das. | `AGENTS.md` §3.6 („wer keinen Fall in `test/mutations/` hat, ist unbewacht") | `test/mutations/324-mutate-files-schranke-erlaubt-mehrfachtreffer.sh:19` | ja — ein zweiter Fall, der die Null-Richtung entschärft | neuer-waechter-ohne-mutations-fall |
| F-7 | INFO | Der Kopf nennt die Eingabe „Bash-Glob **oder literaler Pfad**"; tatsächlich läuft jede Angabe durch `compgen -G`. Ein literaler Pfad, dessen **Name** ein Glob-Metazeichen trägt, löst deshalb nicht auf (gemessen: `stern[1].cfg` → rc=1, obwohl die Datei da ist). Heute trifft das keinen Fall, und die Richtung ist fail-closed. | Maintainability | `harness/tools/mutate.sh:237` | ja — Sonde wie in §3 dieses Reports | eingabe-klasse-im-kopf-weiter-gefasst-als-die-verarbeitung |
| F-8 | INFO | Die Reihenfolge-Vorgabe aus Plan §3 („zuerst der Treiber samt Wächter und Zahn, dann die fünf Fälle; der rote Beleg zu DoD 1 **vor** DoD 2") ist an einem einzelnen Commit nicht ablesbar. Sie ist in der gewählten Konstruktion allerdings gegenstandslos geworden: Der Beleg der Schranke hängt an synthetischen bats-Fixtures und nicht an den fünf Fällen, und dieser Report liefert ihn unabhängig nach (§1). | Slice-Plan §3 | `f3055672` (ein Commit, neun Dateien) | nein — `git` sieht Dateien, nicht Arbeitsreihenfolge | plan-reihenfolge-ohne-spur-im-artefakt |
| F-9 | INFO | Der Geltungsbereich von `AGENTS.md` §3.7 nennt in Prosa „Code, Konfiguration, Skripte", der dort gemessene Pathspec führt `*.sh *.awk *Makefile Dockerfile *.go` und **kein** `*.bats`. Drei Fundstellen aus F-1/F-2 liegen in `test/mutate-driver.bats` und hängen damit an dieser offenen Frage. Für den Architect, nicht für den Implementer. | `AGENTS.md` §3.7 §Geltungsbereich | `AGENTS.md` (Pathspec-Block in §3.7) | nein | geltungsbereich-prosa-und-pathspec-fallen-auseinander |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Out-of-Scope §1, Punkt 1** — `internal/emit/templates.go` | geprüft, ohne Befund: nicht im Diff; `git grep -c 'v6\.7\.2' -- internal/emit/templates.go` → 3, der Mess-Stand nach `MR-033` steht unverändert |
| **Out-of-Scope §1, Punkt 2a** — `refs:`-Ventil | geprüft, ohne Befund: `.d-check.yml:170` unverändert, nicht im Diff |
| **Out-of-Scope §1, Punkt 2b** — Payload in Fall 221 | geprüft, ohne Befund: `test/mutations/221-ignore-refs-restbreite.sh:23` unverändert, nicht im Diff |
| **Out-of-Scope §1, Punkt 2c** — Fixture-Tags | geprüft, ohne Befund: `internal/archive/scan_test.go` nicht im Diff |
| **Out-of-Scope §1, Punkt 3** — repo-weiter Wächter über tote Adressen | geprüft, ohne Befund: kein Modul der Gate-Config angefasst, kein neuer Wächter behauptet |
| **Out-of-Scope §1, Punkt 4** — Schicht-Abgrenzung | geprüft, ohne Befund: die neun Dateien liegen ausschließlich unter `harness/tools/`, `harness/sensors/` und `test/`; kein `internal/`, kein `cmd/`, keine `.template.md` |
| **DoD 2, mechanische Hälfte** | geprüft, ohne Befund: `git grep -nE '^# files: \.harness/baseline/v[0-9]' -- test/mutations/` ist leer (EXIT 1). Die einzige verbliebene Tag-Nennung unter `test/mutations/` ist der ausgeschlossene Payload in Fall 221 |
| **DoD 1, „dieselbe Funktion, nicht zwei Fassungen"** | geprüft, ohne Befund: `resolve_file_spec` ist im Skript einmal definiert und von genau zwei Stellen gerufen (`mutation_targets:270`, `run_case:652`) |
| **`ADR-0035` — Bezugsmenge des Beleg-Schlüssels** | geprüft, ohne Befund: `isolation_key_files` ist im Diff nicht enthalten und liest keine `# files:`-Zeile; `ISOLATION_KEY_EXEMPT=(./.git)` und `ISOLATION_EXCLUDES=(./.harness/state)` sind unverändert, `.harness/baseline/` geht also weiter in den Schlüssel ein — ein Baseline-Sprung entwertet den Beleg, der Übersprung kann den Lauf über einem neuen Vorlagensatz nicht überspringen. Risiko 2 aus §6 ist nicht eingetreten |
| **Risiko 1 aus §6 (stumpfer Fall)** | geprüft, ohne Befund: alle fünf Mutationen ändern ihre Zieldatei im `v6.8.0`-Satz (§5 dieses Reports) |
| **Risiko 3 aus §6 (mehr als ein Treffer)** | geprüft, ohne Befund: die Schranke ist unabhängig von `make baseline-verify` gebaut und als Sonde rot gesehen |
| **Isolations-Eigenschaft der neuen Host-Auflösung** | geprüft, ohne Befund: `compgen -G` expandiert weder Kommando-Substitution noch Backticks, Tilde oder Klammern; eine `# files:`-Zeile kann auf dem Host nichts ausführen (§3 dieses Reports) |
| **Fingerabdruck-Semantik** | geprüft, ohne Befund: 65 → 65 Pfade, Differenz genau die drei Baseline-Pfade, alle 65 existieren; die Ziel-Menge schrumpft nicht still (`LH-QA-01`) |
| **Fail-closed bei leerer Ziel-Menge** | geprüft, ohne Befund: `target_fingerprint` trägt jetzt `|| return 1` auf `mutation_targets` **und** behält `[ -n "$targets" ]`; der bestehende Fall 73 bleibt gültig |
| **`AGENTS.md` §3.2 (Lint-Suppression)** | geprüft, ohne Befund: keine `# shellcheck disable`-Zeile im Diff; `make shell-lint` EXIT 0 |
| **`AGENTS.md` §3.8 / §3.10 (Rollen-Eigentum)** | geprüft, ohne Befund: der Commit berührt keine Hard Rule, keinen Adaptions-Eintrag, keine ADR, keinen Slice-Plan und kein Closure-Artefakt; die Message nennt die Rolle |
| **`AGENTS.md` §3.9 (Docker-only)** | geprüft, ohne Befund: keine Host-Toolchain im Diff; die neuen Rezept-Pfade laufen weiter über `make` |
| **Traceability / `MR-051`** | geprüft, ohne Befund: die Message nennt `LH-QA-01`, `LH-QA-02`, `AGENTS.md` §3.6 und §3.7; jede Zahl darin steht neben dem Kommando, das sie liefert (`MUTATE_FORCE=1 make mutate`, `make gates`) |
| **Halluziniertes Gate (`LH-QA-01`)** | geprüft, ohne Befund: kein neues Target behauptet; `harness/README.md` §Werkzeuge ist unberührt, `make mutate` steht dort schon als *kein Gate* |
| **Fall-Konventionen des neuen Zahns** | geprüft, ohne Befund: Nummer 324 war frei (höchste zuvor 323), `# verify: test-bats` ist ein von `failure_form` geführter Modus, `# files:` und `# expect:` sind gesetzt |
| **`# expect:`-Kopplung des neuen Zahns** | geprüft, ohne Befund: die Zeile zitiert den bats-Testnamen wörtlich; eine Umbenennung des Tests färbt den Fall über Bedingung 4 rot statt still grün |
| **Doppelte `# files:`-Köpfe** | geprüft, ohne Befund: der bestehende Mehrfach-Kopf-Wächter in `run_case` läuft weiter **vor** der neuen Auflösung |
| **`make mutate`-Laufzeit** | geprüft, ohne Befund: `mutation_targets` über 310 Fällen 0,017 s → 2,806 s (gemessen mit `time bash -c "source …; mutation_targets test/mutations . \| wc -l"` gegen dieselbe Messung auf `f3055672^`); zweimal je Lauf, also rund 5,6 s auf einen Lauf in der Größenordnung von Minuten — keine Stellschraube am Verdikt und weit unter `MUTATE_STALL_SECONDS` |
| **`harness/sensors/mutate.md` §Grenze** | geprüft, ohne Befund: der Abschnitt existiert unter diesem Titel, der neue Absatz liegt darin, und der DoD-Doku-Punkt ist damit am benannten Ort eingelöst |
| **Gate-Läufe** | geprüft, ohne Befund: `make docs-check` 1345/0, `make shell-lint` EXIT 0, `make test-bats` EXIT 0 — alle drei in diesem Lauf real gefahren |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 4 |

**Finding-Klassen dieses Laufs:** kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle ·
zusage-vereinheitlicht-zwei-stellen-mit-verschiedener-fehlschlag-form ·
neue-oeffentliche-funktion-ohne-benannte-grenze · neuer-waechter-ohne-mutations-fall ·
eingabe-klasse-im-kopf-weiter-gefasst-als-die-verarbeitung · plan-reihenfolge-ohne-spur-im-artefakt ·
geltungsbereich-prosa-und-pathspec-fallen-auseinander

Die erste Klasse ist die einzige, die im Beobachtungs-Register bereits geführt wird; sie steht
dort `offen` und hat mit diesem Lauf **einen** Vorgang mehr, nicht drei — F-1, F-2 und F-4 sind
dieselbe Klasse in einem Vorgang. Die Zuordnung und das Anlegen des Belegs sind Sache der
Slice-Closure, nicht dieses Reports.

## Verdikt

**Merge-blockierend:** ja — zwei HIGH und ein MEDIUM. Alle drei liegen ausschließlich im
**Kommentartext**; die Mechanik des Commits ist in diesem Lauf unabhängig nachgemessen und trägt:
Die Auflösung ist in allen geprüften Richtungen fail-closed, die Bezugsmenge des Fingerabdrucks ist
unverschoben, die Bezugsmenge des Beleg-Schlüssels aus
[`ADR-0035`](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist
unberührt, der neue Zahn wird aus dem behaupteten Grund rot, und die vier Out-of-Scope-Punkte aus
§1 sind eingehalten. Die Sperre ist damit billig aufzulösen und betrifft keine Zeile ausführbaren
Codes.

**Übergabe:** Findings gehen an den Implementer (Rückkante
Review → Plan bei Plan-Defekt); die **Finding-Klassen** gehen zusätzlich
in die Slice-Closure §7 und von dort in den Zähler. F-9 ist kein Implementer-Punkt und geht als
offene Frage an den Architect. Dieser Report selbst
ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell,
dieses Verdikt) — er wird über Läufe hinweg nicht wieder gelesen, und
muss es nicht. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

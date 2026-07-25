# Review-Report: slice-047 (mutate gegen isolierte Kopie), **Runde 2** — 2026-07-25

**Review-Art:** Code — geprüft wird der **Nachbesserungs-Diff** gegen die
Findings aus Runde 1, gegen Slice-Plan, aktive ADRs und Konventionen
(Modul 10 §Drei Review-Arten). **Enger Auftrag:** (a) ist jedes Alt-Finding
aufgelöst, (b) hat der Fix **neue** Probleme eingeführt. Runde 1 wird
**nicht** wiederholt. **Nicht** geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-047, Commit `8c3e095` (Vor-Stand `3bd554b`, den Runde 1 bewertete)

**Skill:** `.harness/skills/reviewer.md` @ 1.3.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan [`slice-047-mutate-host-isolation.md`](../plan/planning/in-progress/slice-047-mutate-host-isolation.md) (DoD §2, Plan-Tabelle §3, Risiken §6)
- **Report Runde 1** [`2026-07-25-slice-047-impl-review.md`](2026-07-25-slice-047-impl-review.md) (F-1…F-12 im Wortlaut)
- **Verifier-Report** [`2026-07-25-slice-047-verification.md`](2026-07-25-slice-047-verification.md) (R-1…R-7, zwei TEILWEISE)
- aktive ADRs: [ADR-0003](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- berührte IDs: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`AGENTS.md`](../../AGENTS.md) (Hard Rules §3.1–§3.6), [`harness/conventions.md`](../../harness/conventions.md) ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung))
- vorherige Findings am gleichen Modul: slice-026 F-1/F-5/F-6/F-7/N-2/N-4/NR-1/NR-2, slice-026 F-12 (Auslöser), **slice-034 F-1 („entfernte Mutation = entfernte Deckung")**, slice-037 (Anker-Re-Verankerung), slice-044 F-1

**Betriebsmodus:** read-only, **keine `make`-Läufe** (mutierender Sensor;
`make mutate` ~15 min). Sensor-Ausgaben aus dem Implementer-Lauf übernommen
(`make gates` grün 173 Dateien/0 Befunde · `make mutate` **70 ok, 0 Befunde**,
Fälle 72/73/74 je rot · `shell-lint` clean); das Log `mutate8.log` habe ich
gelesen, nicht nachgefahren. Eigene Messungen: `git show/diff/log`,
Datei-Lektüre, `grep` (Anker-Eindeutigkeit, Ziel-Menge, Fall↔Wächter-Abgleich).
Host-`grep` ist ugrep 7.5.0 — daraus wurden **keine** Schlüsse über
Container-`grep`-Verhalten gezogen.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

### Teil A — Status der Alt-Findings

Ein Wort je Finding, mit Beleg. Zeilennummern beziehen sich auf den
Stand `8c3e095`.

| Alt-Finding | Status | Beleg |
|---|---|---|
| **F-1** leeres `$WORK` läuft auf den Host | **aufgelöst** | `require_isolated` (`harness/tools/mutate.sh:158-164`) prüft leer / `$REPO` / `$REPO/*` / kein Verzeichnis, wird in `main` vor dem ersten Fall gerufen (`:391`, `|| exit 1`); bats-Wächter mit allen drei Zweigen (`test/mutate-driver.bats:77-84`). |
| **F-2** fünfte Bedingung sieht den symmetrischen Rückfall nicht | **aufgelöst** | Prüfung mitten im Lauf (`:267-287`), direkt nach der Mutation und **vor** Bedingung 2; der Kommentar der fünften Bedingung (`:425-428`) nimmt die zu starke Zusage zurück und benennt die Arbeitsteilung. Rot-Beleg als Handbeobachtung im Commit-Text — nicht als Fall (dazu N-1). |
| **F-3** drei neue Wächter ohne Mutationsfall | **teilweise** | Nur einer der drei geschlossen (`.git`-Umfang → Fall `74`, rot in `mutate8.log:75`). `test/mutate-driver.bats:111` und `:146` haben weiter keinen Fall; netto ist die Zahl unbewachter slice-047-Wächter von 3 auf 4 gestiegen (N-2). |
| **F-4** `AGENTS.md` schreibt dem Fingerabdruck zu viel zu | **aufgelöst** | `AGENTS.md:129` nennt jetzt „vor, **während** und nach" und „nur diese Dateien — nicht den ganzen Baum"; `harness/README.md:53` parallel. Beides deckt sich mit `:267-287` + `:425-435`. Der Rest-Overclaim ist ein **anderer** Halbsatz (N-6). |
| **F-5** Mutation 72 färbt eine vorgelagerte Assertion | **aufgelöst** | Ortsregel in der reinen `isolation_path` (`:127-137`), eigener Wächter für die **Verweigerung** (`test/mutate-driver.bats:69-72`), Fall `72` auf deren `return`-Zweig verankert; `mutate8.log:73` zeigt rot an genau diesem Wächter. |
| **F-6** `host_after` ohne Diagnose-Pfad | **aufgelöst** | `:429-432` (`if !` + eigene Meldung). Nebenwirkung: Doppel-Befund (N-8). |
| **F-7** Kopier-Kosten in jedem `make test` | **aufgelöst** | Nur noch `test/mutate-driver.bats:91` ruft `prepare_isolation`; `:59` benutzt die reine `isolation_path`. |
| **F-8** Lifecycle-Prosa gegen Verzeichnis | **aufgelöst** | `docs/plan/planning/in-progress/roadmap.md:21` und `docs/plan/planning/done/welle-07-results.md:104` tragen beide `in-progress/`; kein weiteres `open/` zu slice-047 im Repo. |
| **F-9** Negativ-Assertion bindet an die heutige Ziel-Menge | **offen** (INFO) | `test/mutate-driver.bats:155` unverändert (`! grep -q '^AGENTS.md$'`). War INFO, kein Auftrag. |
| **F-10** Anker von Fall 73 breit | **aufgelöst** | Anker trägt die volle Zeile (`test/mutations/73-mutate-fingerprint-leer.sh:17`), nachgemessen genau ein Treffer; das bloße `\|\| return 1` käme heute **achtmal** vor — der Fix war notwendig geworden, nicht kosmetisch. |
| **F-11** `[ ! -e "$dest/.harness/state" ]` kann vakuum-grün sein | **offen** (INFO) | `test/mutate-driver.bats:102` unverändert. War INFO (= Verifier R-5, Backlog). |
| **F-12** Plan-Drift bestätigt | **offen** (INFO, kein Auftrag) | Feststellung, kein Befund gegen den Diff. |

Kontext-Findings des Verifiers, soweit sie den Diff betreffen:
**R-1** *teilweise* (nicht-diskriminierend behoben, „selbst unbewacht" nicht — N-1) ·
**R-2** *teilweise* (Scope ergänzt, „kein Residuum" nicht relativiert — N-6) ·
**R-3** *aufgelöst* (`:373-381` steht jetzt vor dem Fingerabdruck `:384`, damit erreichbar) ·
**R-4** *bewusst offen*, als Restrisiko benannt — akzeptiert.

### Teil B — neue Findings

### F-1 — die neue Mitten-im-Lauf-Prüfung ist selbst unbewacht, und die Begründung dafür trifft nicht zu

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 („wer keinen Fall in `test/mutations/` hat, ist unbewacht"), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `harness/tools/mutate.sh:277-287` · Commit-Text `8c3e095` („als Mutations-Fall unmoeglich — make mutate kann sich nicht selbst fahren")
- `befund`: `grep -rn 'HOST_BEFORE\|host_now\|Isolation gebrochen' test/` findet nichts; weder ein bats-Wächter noch ein Mutationsfall deckt den neuen Vergleich. Dreht jemand `!=` (`:283`) nach `=`, bleibt `make mutate` grün. Die Begründung, ein Fall sei unmöglich, steht gegen den Ist-Stand: `test/mutations/09`, `72`, `73` und `74` mutieren alle `harness/tools/mutate.sh` und werden über `test/mutate-driver.bats` rot gesehen — die Selbst-Mutation läuft in diesem Repo genau so. Was fehlt, ist die Form, die derselbe Commit für F-5 gerade hergestellt hat (reine Funktion statt Zweig in `run_case`). Damit ist Verifier R-1 Punkt 1 nicht geschlossen, sondern an die neue Stelle gewandert.
- `verifizierbar`: ja — `sed -i 's/!= "\$HOST_BEFORE"/= "\$HOST_BEFORE"/'` auf `:283` müsste `make mutate` rot färben; heute tut es das nicht.

### F-2 — die Re-Verankerung von Fall 72 hat Deckung ersetzt statt ergänzt

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6; slice-034 F-1 („entfernte Mutation = entfernte Deckung") als benannte Steering-Lehre dieses Repos
- `pfad`: `test/mutations/72-mutate-isolation-im-repo.sh:16` · `test/mutate-driver.bats:54`, `:77`, `:111`, `:146`
- `befund`: Fall 72 färbte vorher den Wächter `test/mutate-driver.bats:54` („die isolierte Kopie liegt AUSSERHALB des Repos") rot; nach der Re-Verankerung färbt er `:69`, und `:54` hat **keinen** Fall mehr — die Zuweisung `dest="$1/repo"` (`harness/tools/mutate.sh:128`), also die Ortszuweisung selbst, ist damit unbewacht (der alte Sed hätte an `:54` weiter Zähne, er wurde ersetzt statt behalten). Abgleich `# expect:`-Strings gegen `@test`-Namen: von den slice-047-Wächtern haben `:54`, `:77` (neu in diesem Fix), `:111` und `:146` keinen Mutationsfall — **vier** statt der drei, die F-3 in Runde 1 gemeldet hat.
- `verifizierbar`: ja — `grep -h '^# expect: ' test/mutations/*.sh` gegen `grep '^@test' test/mutate-driver.bats`; `mutate8.log` nennt für `:54`, `:77`, `:111`, `:146` keinen Fall.

### F-3 — eine parallel bearbeitete Zieldatei erzeugt bis zu 70 falsche Befunde und verhindert dabei jede Messung

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 (Zusage > Ist), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`harness/README.md`](../../harness/README.md) §Nicht-Gate-Verify
- `pfad`: `harness/tools/mutate.sh:283-287` · Zusage `harness/README.md:53` („nur diese Dateien, damit paralleles Arbeiten am Repo den Lauf nicht rötet") · `AGENTS.md:129`
- `befund`: `HOST_BEFORE` ist über den gesamten Lauf konstant. Ändert sich während der ~15 Minuten **eine** der 25 Zieldateien im Host-Baum (die Menge enthält `harness/tools/mutate.sh`, `cmd/ai-harness-init/main.go`, alle `internal/gen/*`- und `internal/emit/*`-Ziele, `.github/workflows/ci.yml`), schlägt der Vergleich in **jedem** Folgefall an: der Fall bricht mit „die Mutation hat den HOST-Baum getroffen statt die Kopie — Isolation gebrochen" ab, **bevor** die Bedingungen 2–4 messen. Der Lauf meldet dann bis zu 70 Befunde und hat keinen einzigen Wächter geprüft; die Meldung nennt als Ursache ausschließlich den Isolations-Bruch (die fünfte Bedingung `:434` nennt „oder es wurde parallel editiert", die Fall-Meldung nicht). Die beiden Briefings sagen für genau diesen Fall das Gegenteil zu.
- `verifizierbar`: ja — während eines Laufs eine Zieldatei anfassen; jeder Folgefall meldet den Isolations-Bruch.

### F-4 — bei erkanntem Isolations-Bruch läuft die Schleife weiter

- `kategorie`: LOW
- `quelle`: Fail-closed-Prinzip des Skript-Kopfs (`harness/tools/mutate.sh:38-48`), Maintainability
- `pfad`: `harness/tools/mutate.sh:283-287`
- `befund`: Der Zweig meldet, ruft `restore` (das nach `$WORK` zurückspielt, `:82-84`) und kehrt aus `run_case` zurück; die Fall-Schleife `:421-423` läuft weiter. Trifft ein Defekt tatsächlich den Host-Baum, mutiert der Treiber nach der Erkennung noch bis zu 69 weitere Male gegen genau diesen Baum, und keines dieser Ziele wird zurückgestellt — das Backup liegt in der Kopie. Die Bedingung erkennt den Bruch und begrenzt ihn nicht.
- `verifizierbar`: ja — die Wegwerf-Kopie, in der der Implementer den Rot-Beleg gebaut hat, zeigt es beim Weiterlaufen über mehrere Fälle.

### F-5 — Kommentar-Block durch das Vorziehen des Leer-Set-Wächters verwaist

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `harness/tools/mutate.sh:367-369` gegen `:389-392`
- `befund`: Der Block „ISOLATION: den Baum EINMAL nach ausserhalb des Repos kopieren … ein Abbruch laesst nichts zurueck" steht unverändert an seiner alten Stelle; darunter folgt jetzt der Leer-Set-Wächter, der Code, den er beschreibt, erst rund 20 Zeilen später. Der Kommentar erklärt nicht mehr das, was unter ihm steht.
- `verifizierbar`: nein — Lesbarkeit; `shell-lint` sieht es nicht.

### F-6 — der Skript-Kopf ist hinter den beiden Briefings zurückgeblieben

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6 (Zusage gegen Code), Doku-Drift
- `pfad`: `harness/tools/mutate.sh:38` („FAIL-CLOSED, vier Bedingungen"), `:57-61` („target_fingerprint vor/nach dem Lauf")
- `befund`: `run_case` trägt seit diesem Commit fünf Prüfungen (Isolation zwischen 1 und 2), `main` eine sechste; der Kopf zählt weiter vier und nennt den Fingerabdruck „vor/nach". `AGENTS.md:129` und `harness/README.md:53` sagen inzwischen „vor, während und nach" — die repo-weite Doku ist nachgezogen, die quellennahe Beschreibung nicht.
- `verifizierbar`: nein — Doku-Aussage; die Grenze folgt aus `:267-287`.

### F-7 — „kein Residuum" blieb unrelativiert, und „das" umfasst mehr als gemessen wird

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) Hard Rule §3.6; Verifier R-2 (ausdrücklich als vor der Closure zu erledigen gelistet)
- `pfad`: `AGENTS.md:129`
- `befund`: Der Satz lautet „… der Arbeitsbaum wird nie verändert, parallele Gate-/Test-Läufe sind unbedenklich, und ein Abbruch lässt kein Residuum zurück. **Der Lauf misst das mit:** …". Der stale Lock (`harness/tools/mutate.sh:23-28`, `.harness/state/mutate.lock` nach SIGKILL) und das liegenbleibende Temp-Verzeichnis stehen weiter unerwähnt — der zweite Teil von Verifier R-2 wurde nicht ausgeführt. Zudem bezieht sich „das" grammatisch auf alle drei vorangehenden Zusagen; gemessen wird nur die erste, und die nur auf den Zieldateien.
- `verifizierbar`: nein — Doku-Aussage.

### F-8 — der neue `host_after`-Diagnose-Pfad meldet ein Ereignis zweimal

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `harness/tools/mutate.sh:429-435`
- `befund`: Scheitert die Berechnung, meldet `:430` „Fingerabdruck nach dem Lauf nicht berechenbar", setzt `host_after=""` und fällt anschließend zwingend in `:433-435` — ein zweiter Befund („eine Mutations-Zieldatei im HOST-Baum hat sich geaendert") für dasselbe Ereignis. `fail_count` zählt zwei.
- `verifizierbar`: ja — eine `# files:`-Zieldatei während eines Laufs entfernen.

### F-9 — beide Ortsregeln vergleichen rein textuell

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `harness/tools/mutate.sh:129-134` (`isolation_path`) · `:159-162` (`require_isolated`)
- `befund`: Der `case`-Vergleich gegen `"$REPO"`/`"$REPO"/*` greift nur bei absoluten, kanonischen Pfaden; ein relativer Wert (`isolation_path sub` → `sub/repo`, cwd = `$REPO`) passierte beide Schranken und läge unter dem Repo. Heute nicht erreichbar (`mktemp -d` liefert absolut, `REPO` ist über `cd … && pwd` kanonisiert) — `require_isolated` erbt die Lücke aber neu. Ebenfalls Reihenfolge: `[ -n "$root" ]` (`:135`) steht **nach** der Ortsregel und nach `dest="$1/repo"`.
- `verifizierbar`: ja — `isolation_path sub` aus dem Repo-Verzeichnis.

### F-10 — Anker von Fall 72 ist einrückungsabhängig

- `kategorie`: INFO
- `quelle`: Maintainability (Re-Verankerungs-Klasse aus slice-037/slice-044)
- `pfad`: `test/mutations/72-mutate-isolation-im-repo.sh:16`
- `befund`: `sed -i 's/^      return 1$/      return 0/'` trifft heute genau eine Zeile (`harness/tools/mutate.sh:132`, nachgezählt gegen acht `return 1` insgesamt), hängt aber an sechs Leerzeichen Einrückung; eine Umformatierung machte die Mutation wirkungslos. Fail-closed — Bedingung 2 fänge es als „Mutation hat nicht gegriffen" —, aber der Fall zeigte dann auf die falsche Ursache.
- `verifizierbar`: ja — `grep -c '^      return 1$' harness/tools/mutate.sh`

### F-11 — der billiger gewordene bats-Wächter räumt sein Temp-Verzeichnis nicht mehr weg

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `test/mutate-driver.bats:59`
- `befund`: `isolation_path '$(mktemp -d)'` legt ein Verzeichnis an, das kein `rm -rf` mehr entfernt (die Vorfassung räumte `$root` auf). `isolation_path` ist rein und braucht kein existierendes Verzeichnis; das Verzeichnis wird nur noch erzeugt, um einen Pfad zu haben. Folgenlos (Container-Lebensdauer), aber je `make test` ein Rest.
- `verifizierbar`: ja — `ls /tmp` nach einem `make test`-Lauf auf dem Host.

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

Die sieben Regressions-Kandidaten des Auftrags sind hier vollständig
abgearbeitet — auch die, bei denen nichts zu finden war.

- geprüft, ohne Befund: **Kandidat 1a — kann die neue Reihenfolge einen Fall zu „ok" machen?** Nein. Der neue Zweig (`harness/tools/mutate.sh:277-287`) endet in **beiden** Ausgängen in `report_fail` + `restore` + `return`; er hat keinen Pfad, der zu `pass_count` führt. Bei Gleichheit fällt der Fluss unverändert in Bedingung 2 (`:289-307`). Kein Befund-Weg entfernt, keiner umsortiert außer der Einfügung; die Wege 1/2/3/4 stehen weiter in `:261-265`, `:297-307`, `:314-318`, `:328-333`. Der Fall „ein Mutations-Skript fasst legitim eine Datei an, die Ziel eines anderen Falls ist" existiert nicht: alle Fälle laufen mit cwd `$WORK` und relativen Pfaden (in Runde 1 über alle Fälle geprüft, seither nur `74` hinzugekommen — ebenfalls relativ).
- geprüft, ohne Befund: **Kandidat 2 — `HOST_BEFORE` als Global.** Gesetzt in `main` (`:384`) vor der Kopie (`:390`) und vor der Schleife (`:421`); die Reihenfolge ist richtig, der Fingerabdruck beschreibt den Stand, der kopiert wird. Beim Sourcen ist der Wert `""` (`:73`) — ein direkt gerufener `run_case` verglich dann gegen den Leerstring und meldete einen Befund: **fail-closed**, kein stilles Grün. Kein bats-Test ruft `run_case` (geprüft: alle elf `@test` rufen ausschließlich `failure_form`, `isolation_path`, `prepare_isolation`, `require_isolated`, `fingerprint_of_list`, `mutation_targets`, `target_fingerprint`).
- geprüft, ohne Befund: **Kandidat 3 — Erreichbarkeit von `require_isolated`.** `WORK` wird an genau einer Stelle zugewiesen (`:390`); die Schranke unmittelbar danach (`:391`) deckt damit alle sechs `cd "$WORK"`-Stellen und `restore`. Der Kommentar „VOR jedem Zugriff" ist eine Idealisierung (es ist ein Aufruf, nicht sechs), bei einmaliger Zuweisung aber tragfähig — kein Over-Engineering, drei Zeilen. Fällt `prepare_isolation`, bricht schon die Zuweisung unter `set -e` ab; die Schranke ist die zweite Linie, nicht die einzige. (Symlink-/Relativpfad-Grenze siehe F-9, INFO.)
- geprüft, ohne Befund: **Kandidat 4 — Ortsregel an genau einer Stelle.** Die `case`-Regel steht nur noch in `isolation_path` (`:129-134`); `prepare_isolation` (`:145-151`) ruft sie und propagiert den Fehlschlag (`|| return 1`), `main` ruft nur `prepare_isolation`. Kein Pfad umgeht sie. Der neue Wächter `test/mutate-driver.bats:69-72` prüft die **Verweigerung** direkt (`run … ; [ "$status" -ne 0 ]`) und nicht mehr eine vorgelagerte Nicht-Leer-Assertion — `mutate8.log:73` zeigt Fall 72 rot an genau diesem Namen. F-5 ist damit an der Wurzel behoben, nicht verschoben.
- geprüft, ohne Befund: **Kandidat 5 — Form der Mutationen 72/73/74.** Alle drei brechen **Verhalten, nicht Kompilat**: `return 1`→`return 0` (72), `|| return 1`→`|| return 0` (73), ein zusätzliches `--exclude` im `tar`-Aufruf (74) — das Skript bleibt in allen drei Fällen parsebar und lauffähig. Anker heute je **genau einmal** getroffen (nachgezählt: `^      return 1$` 1×, `-n "$targets" ] || return 1` 1×, `tar -cf - --exclude=./.harness/state` 1×). Jedes Szenario erreicht die Schranke, die es zu prüfen behauptet: 72 → `isolation_path`-Verweigerung, 73 → `[ -n "$targets" ]` über einem Fall-Verzeichnis mit `# expect:`-only-Datei, 74 → `[ -e "$dest/.git" ]` in dem einen wirklich kopierenden Test. `mutate8.log:73-75` bestätigt drei Rot an drei verschiedenen Wächtern. SC2016: 72 und 74 sind dollar-frei bzw. in Single Quotes, 73 nutzt Doppelquotes mit escaptem `$`.
- geprüft, ohne Befund: **Kandidat 7 — Leer-Set-Wächter an neuer Position.** Reihenfolge jetzt `[ -d "$CASES_DIR" ]` (`:365`) → Glob (`:370-372`) → Leer-Prüfung (`:373-381`) → Fingerabdruck (`:384`) → Kopie (`:389-392`). Der Wächter ist damit erreichbar (Verifier R-3 geschlossen), und der Fingerabdruck steht weiterhin vor der Kopie. Nichts anderes hat sich mitverschoben — Lock (`:356-363`), Grün-Vorlauf (`:394-418`) und Schleife (`:420-423`) stehen unverändert in derselben Ordnung. (Der Kommentar blieb zurück: F-5.)
- geprüft, ohne Befund: **Semantik-Erhalt des Header-Vertrags und des Grün-Vorlaufs** — `# files:`/`# expect:`/`# verify:`, Doppelkopf-Prüfung, `failure_form` als einzige Zulassungsquelle und der Grün-Vorlauf je Modus sind im Diff nicht berührt; die Fall-Menge ist rein additiv (69 → 70, nur `74` neu, kein Altfall umgeschrieben außer den zwei re-verankerten Seds).
- geprüft, ohne Befund: **[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Verträglichkeit des Fixes** — keine neue Datei im Working Tree, `git status --porcelain` leer, Isolation weiter unter `mktemp -d`; die neuen Funktionen sind Top-Level und ohne Seiteneffekt beim Sourcen (`main()`-Kapselung `:344`/`:442` unverändert).
- geprüft, ohne Befund: **Hard Rules 3.1–3.5** — kein neues Gate versprochen, kein `git mv`, keine ADR berührt, keine Schwellensenkung, keine Lint-Suppression im Diff (`# shellcheck disable` kommt nicht vor).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 4 |
| INFO | 4 |

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend:** ja — drei MEDIUM. Die Bewertung ist eng: die
**Mechanik des Fixes ist richtig**. Acht der zwölf Alt-Findings sind
sauber aufgelöst, zwei davon an der Wurzel (F-5 durch die reine
Funktion, F-2 durch die Verlagerung der Messung in den Lauf), und die
neue Prüfung schließt die Lücke, die Reviewer und Verifier unabhängig
gefunden hatten. Kein neuer stiller Grün-Pfad, kein Fall kann durch
die neue Reihenfolge zu „ok" werden, `mutate8.log` zeigt 70 ok / 0
Befunde mit drei Rot an drei verschiedenen Wächtern.

Blockierend ist, dass der Fix **dieselbe Klasse reproduziert, die er
beheben sollte**: die neu eingezogene Prüfung — der Sensor der
Kern-Zusage dieses Slice — hat weder Wächter noch Fall (F-1), und die
Re-Verankerung von Fall 72 hat Deckung **ersetzt statt ergänzt**, sodass
die Zahl unbewachter slice-047-Wächter von drei auf vier gestiegen ist
(F-2) — genau die slice-034-Lehre „entfernte Mutation = entfernte
Deckung", die dieses Repo bereits einmal aufgeschrieben hat. Dazu
kommt eine Konstruktion, die bei paralleler Arbeit an einer Zieldatei
bis zu 70 falsche Befunde erzeugt und dabei keinen einzigen Wächter
misst (F-3) — der Fall, den die beiden Briefings ausdrücklich als
unproblematisch zusagen.

Der Rest-Aufwand ist klein und mechanisch: eine reine Funktion für den
Vergleich plus Wächter und Fall, ein wiederhergestellter oder neuer
Fall für `test/mutate-driver.bats:54`, und eine Meldung, die die zweite
mögliche Ursache nennt. LOW/INFO sind Doku- und Kommentar-Nachzüge.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

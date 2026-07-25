# Verifier-Report slice-047 — `make mutate` gegen isolierte Kopie (Host-Baum nie mutieren)

Rolle: Verifier (Modul 11). Frischer Kontext, **strikt read-only** — kein `make`-Lauf
(Schaden-Präzedenz: ein früherer Verifier-Subagent mutierte per Hintergrund-`make mutate`
den Haupt-Baum). Commit `3bd554b`, Basis `a6c78b2`. Datum: 2026-07-25.

**Was ich unabhängig gemessen habe** (statt nachzufahren):

- `git show/diff/log/ls-tree`, vollständiges Lesen von `harness/tools/mutate.sh` (396 Z.),
  `test/mutate-driver.bats`, `test/mutations/72|73`, `Makefile`, `harness/tools/{record-gates,working-tree-hash}.sh`.
- **Gate-Stempel gegen den Baum:** `harness/tools/working-tree-hash.sh` (read-only) liefert
  `6f2b622b66d72ce2def55d55f9b47854250b3e0b6029c21caf37610d94abd985` — **byte-gleich** mit
  `.harness/state/gates-passed.diffsha`. `record-gates` läuft nur als letzter `gates`-Prereq
  (`Makefile:189`), `git status` ist clean → `make gates` lief real **auf genau diesem Baum** grün.
- **Plan-Drift selbst nachgeprüft:** `grep '^### MR-' harness/conventions.md` → MR-000…MR-014;
  kein Eintrag zu F-12/mutate/Host-Baum. Der vom Implementer gemeldete Drift ist **wahr**.
- **Schreibpfad-Audit:** jede Verwendung von `$REPO` in `mutate.sh` ist lesend
  (`:143` `tar -cf -`, `:330`/`:383` Fingerabdruck, `:137` Pfad-Vergleich); `run_case` läuft
  fünffach gegen `$WORK` (`:230`, `:236`, `:242`, `:258`, `:271`), der Grün-Vorlauf gegen `$WORK`
  (`:367`). Es existiert **kein** Schreibpfad des Treibers in den Host-Baum.
- Logs: `mutate7.log` (finaler Lauf), `mutate3…6.log` (Verlaufs-Rekonstruktion), `hostvor.txt`.

---

## DoD Punkt für Punkt

### 1. Host-Baum während UND nach dem Lauf byte-unverändert (inkl. Sample MITTEN im Lauf) — **TEILWEISE**

Drei getrennte Hälften, die unterschiedlich gut gedeckt sind:

- **„nach dem Lauf" — BESTÄTIGT.** Fünfte Bedingung `mutate.sh:380-386`: `host_before`
  (`:330`) vs. `host_after` (`:383`), Abweichung → `report_fail "host-baum"`. In allen vier
  vollständigen Läufen (`mutate4…7.log`) fiel sie nicht; `mutate7.log:75` = `69 ok, 0 Befund(e)`.
- **„byte-unverändert" (Umfang) — TEILWEISE.** `target_fingerprint` (`:112-117`) hasht **nur**
  die Vereinigung der `# files:`-Ziele — heute **25 Pfade** (nachgezählt). Der ganze Baum ist
  damit **nicht** gemessen. Der Code benennt den Preis offen (`:103-107`), und der Verzicht ist
  sachlich richtig (sonst rötet jede parallele Doku-Arbeit den Lauf). Für den Rest des Baums
  trägt das **Code-Lesen** (Schreibpfad-Audit oben), nicht eine Messung. Die DoD-Formulierung
  „byte-unverändert" ist also strukturell erfüllt, **messtechnisch** aber nur auf der
  Mutations-Ziel-Menge.
- **„Sample MITTEN im Lauf" — NICHT BESTÄTIGT (unbelegbar aus den Artefakten).** Die Behauptung
  („zweimal `make gates` grün parallel zu laufendem `make mutate`") ist plausibel und wäre der
  richtige Beleg — `make gates` fährt `lint build test docs-check shell-lint ci-lint`
  (`Makefile:189`) auf dem **Host**-Baum, eine mutierte Host-Quelle würde dort rot. Es existiert
  aber **kein Artefakt**: kein Gate-Log im Scratchpad, und der Stempel (mtime 10:45) liegt
  **nach** dem letzten mutate-Lauf (10:36), belegt also einen sequentiellen, keinen parallelen
  Lauf. `hostvor.txt` trägt genau **einen** Hash (`4b47fbea…`, 09:31) ohne Nachher-Wert; die
  „dreimal gemessen"-Kette ist aus den Dateien nicht rekonstruierbar.
- **Wichtiger als das fehlende Log (verifier-only):** die fünfte Bedingung **unterscheidet den
  neuen vom alten Zustand bei einem vollständigen Lauf nicht**. Auch der alte Treiber sicherte
  vor der Mutation und stellte danach wieder her — ein Vorher/Nachher-Vergleich wäre dort
  **ebenso grün** gewesen. Genau das transiente Fenster zwischen `sed -i` und `restore` ist
  F-12, und **kein** Sensor im Repo misst es. Der einzige Sensor mit Zähnen für die
  Isolations-Eigenschaft ist Mutation 72 (Ort der Kopie), nicht die fünfte Bedingung.

→ Der Kern ist geliefert und strukturell zwingend; die **diskriminierende Hälfte der DoD**
(mitten im Lauf) beruht auf einer nicht festgehaltenen Handbeobachtung. Siehe R-1/R-6.

### 2. Mutations-Sensor semantisch identisch — **BESTÄTIGT**

- Die **vier Befund-Wege** sind 1:1 erhalten und nur im Arbeitsverzeichnis verschoben:
  (1) Mutations-Skript scheitert `:242-246`, (2) Mutation greift nicht `:256-266`,
  (3) Sensor bleibt grün `:273-277`, (4) rot aus falschem Grund `:287-292`.
- Header-Vertrag unverändert: Doppelkopf-Prüfung `:198-203`, `# files:`/`# expect:` Pflicht
  `:214-217`, `# verify:`-Default `:213`, Zulassung aus `failure_form` `:219-222`.
- Grün-Vorlauf je Modus `:349-373` (jetzt gegen `$WORK`), `main()`-Kapselung `:303`/`:393`,
  Ausgabeform `mutate: $pass_count ok, $fail_count Befund(e)` `:388` — alles unverändert.
- **Fall-Menge additiv:** `git ls-tree a6c78b2 test/mutations/` = 67 Dateien, heute 69. Kein Fall
  entfernt, keiner umgeschrieben (Diff enthält nur zwei `new file`).
- Realer Lauf: `mutate7.log:75` `69 ok, 0 Befund(e)`, Kopf-Zeile `:1`
  („isolierte Kopie unter /tmp/tmp.bKyZmdrajX/repo").
- Einzige gewollte Verhaltens-Änderung: die ACHTUNG-Zeile („dieser Lauf VERAENDERT den
  Arbeitsbaum") ist entfallen — korrekt, sie wäre jetzt falsch.

### 3. Abgebrochener Lauf ohne Residuen im Host-Baum — **BESTÄTIGT (mit zwei Nuancen)**

- Strukturell zwingend: es gibt keinen Schreibpfad in `$REPO` (Audit oben), also kann ein Abbruch
  zu **keinem** Zeitpunkt eine Mutation im Host-Baum zurücklassen. `cleanup` `:147-153` wirft nur
  `$ISO_ROOT` (mktemp, außerhalb) weg; `restore` `:75-84` schreibt nach `$WORK` und ist zusätzlich
  gegen leeres `$WORK` gesichert. `git checkout -- .`-Recovery ist damit gegenstandslos.
- **Nuance a:** ein SIGKILL lässt weiterhin `$REPO/.harness/state/mutate.lock` liegen (`:315-321`).
  Das ist ein Residuum im Host-**Verzeichnis**, nicht im getrackten Baum: `working-tree-hash.sh`
  läuft mit `--exclude-standard`, `.harness/state/` ist gitignored → der MR-003-Hash bleibt stabil.
  Der Skript-Kopf `:23-28` dokumentiert das bewusst als fail-closed. Kein DoD-Verstoß, aber die
  Doku-Formulierung „ein Abbruch lässt kein Residuum zurück" (AGENTS.md:129) ist dafür zu absolut.
- **Nuance b:** ein SIGKILL lässt ~8 MB unter `/tmp` liegen (kein Aufräum-Pfad außer dem trap).
- Behavioral **nicht** vorgeführt: kein Kill-Lauf in den Belegen. `mutate3.log` zeigt einen realen
  Abbruch (Grün-Vorlauf `ci-lint` rot) mit sauberem Baum, deckt aber den Abbruch *mitten in einer
  Mutation* nicht. Ich werte den Punkt trotzdem als bestätigt, weil die Eigenschaft aus der
  Abwesenheit jedes Host-Schreibpfads folgt und nicht von der Ausführungsreihenfolge abhängt.

### 4. `mutate.lock` überflüssig ODER neu begründet — dokumentiert — **BESTÄTIGT**

- Begründung **ersetzt, nicht ergänzt** (`:304-311`): nicht mehr Baum-Schutz, sondern
  Ressourcen-Serialisierung (geteilte Docker-Tags/Build-Cache). Die Abbruch-Meldung `:317-319` ist
  mitgezogen (der alte Satz „Zwei gleichzeitige Laeufe mutieren denselben Arbeitsbaum" ist raus) —
  die „wandernde Grenze umschreiben statt ergänzen"-Lehre aus slice-032 ist eingehalten, ebenso im
  Skript-Kopf `:50-55`.
- Einschränkung, s. R-4: der Klammersatz „die Ergebnisse blieben zwar korrekt (jeder Build hat
  seinen eigenen Kontext)" gilt für `test`/`lint` (die Assertion läuft **im** `docker build`), nicht
  für `make artifact`/`make smoke` (`Makefile:65-70`: `docker create ai-harness-init:build` **nach**
  einem separaten Build → Tag-Fenster).

### 5. `make gates` grün inkl. shellcheck auf `mutate.sh` — **BESTÄTIGT (unabhängig)**

- Kein Zitat: Stempel `= 6f2b622b…` **identisch** mit dem von mir berechneten Baum-Hash, Tree clean.
  `record-gates` schreibt nur nach grünen Gates (`Makefile:185-189`, `record-gates.sh`).
- shellcheck-Abdeckung real: `shell-lint` linted `harness/tools/*.sh` **und** `test/mutations/*.sh`
  (`Makefile:100-102`) — das geänderte `mutate.sh` **und** beide neuen Fälle liegen darin.
- `ci-lint`/`docs-check` decken die geänderten Doku-Zeilen (AGENTS.md:129, harness/README.md:53)
  und die reparierten Slice-Links (roadmap/welle-07-results/slice-045b) mit ab.

### 6. `make mutate` grün gegen die Isolation (Selbst-Beweis) — **BESTÄTIGT**

- `mutate7.log:1` (Isolations-Zeile) + `:75` `69 ok, 0 Befund(e)` — der Sensor bewacht sich, während
  er in der Kopie läuft.
- **Neue Fälle je rot gesehen** (das ist die §3.6-Zusage, nicht der grüne Lauf):
  `72-mutate-isolation-im-repo -> die isolierte Kopie liegt AUSSERHALB des Repos rot` (`mutate7.log:73`),
  `73-mutate-fingerprint-leer -> target_fingerprint FAELLT bei leerer Ziel-Liste rot` (`:74`).
- **Anker-Eindeutigkeit selbst geprüft** (die slice-037-Lehre): `|| return 1` kommt in `mutate.sh`
  **genau einmal** vor (`:115`), `dest="$root/repo"` **genau einmal** (`:131`) — beide Seds sind
  spezifisch, keine breite Mutation.
- **Beide Mutationen brechen Verhalten, nicht das Kompilat** (slice-045b-Lehre): 72 verlegt einen
  Pfad, 73 dreht einen Rückgabewert; in beiden Fällen läuft das Skript weiter und der bats-Wächter
  fällt an der Assertion.
- **Korrektur an der Beleg-Erzählung:** die Auftrags-Beschreibung nennt `mutate5`+`mutate6` als die
  Läufe mit einem Befund an Fall 73. Real: **`mutate4`** (09:46, git-basierte Fassung
  `'host_fingerprint FAELLT ausserhalb eines git-Repos'`) und **`mutate6`** (10:22, `|| true`-Fassung)
  waren rot; `mutate5` (10:00) war bereits `69 ok, 0`. Kein Flakiness-Verdacht: zwischen den Läufen
  änderte sich der Fall-Inhalt (git-basiert → ziel-basiert), nicht das Ergebnis bei gleichem Stand.
  Der Verlauf belegt genau, was der Sensor leisten soll — er hat **zwei** zahnlose Eigen-Mutationen
  des Implementers gefangen.

### 7. Doku-Nachzug `harness/conventions.md` (MR-Block F-12/mutate) — **TEILWEISE**

- **Der Plan-Drift ist real und korrekt gemeldet** (selbst geprüft): `harness/conventions.md` führt
  MR-000…MR-014; **kein** MR-Eintrag beschreibt mutate/F-12/Host-Baum-Veränderung. Die vier
  mutate-Vorkommen (`:562`, `:565`, `:573`, `:601`) stehen im MR-014-CI-Block und sagen nur, dass
  CI `make mutate` fährt — dort ist nichts nachzuziehen. Der DoD-Punkt zielte auf einen Ort, den es
  nicht gibt; die Ersetzung durch AGENTS.md §4 und `harness/README.md` §Nicht-Gate-Verify trifft
  **genau** die beiden Stellen, an denen `make mutate` beschrieben wird. Der Ort ist damit erfüllt.
- **Offen bleibt die Formulierung — und zwar in der Overclaim-Klasse, die dieses Repo wiederholt
  fängt.** Beide neuen Sätze machen die volle Zusage und benennen als Beleg den Fingerabdruck:
  - `AGENTS.md:129`: „der Arbeitsbaum wird nie verändert … (der Lauf belegt das selbst per
    Fingerabdruck vor/nach)"
  - `harness/README.md:53`: „nie den Arbeitsbaum; der Lauf misst das selbst (Fingerabdruck
    vor/nach, fail-closed)"

  Der Fingerabdruck misst aber nur die 25 `# files:`-Ziele — die Einschränkung, die
  `mutate.sh:103-107` selbst sorgfältig ausschreibt, fehlt an beiden Doku-Stellen. Der Satz
  behauptet also mehr Messung, als stattfindet. Ein Halbsatz („gemessen an den Mutations-Zielen;
  für den Rest trägt die Konstruktion") schließt das.
- Zusätzlich: „ein Abbruch lässt kein Residuum zurück" ignoriert den stale Lock (Punkt 3, Nuance a).

### 8. Closure-Notiz mit Steering-Loop-Eintrag — **NOCH OFFEN (erwartet)**

§7 des Slice ist leer, der Slice liegt in `in-progress/`. Regulär, Planner-Rolle nach diesem Urteil.

---

## Plan (§3-Tabelle) gegen Code

| Geplant | Ist | Urteil |
|---|---|---|
| `harness/tools/mutate.sh` refactor — Zyklus gegen isolierte Kopie, vier Befund-Wege + Header-Semantik erhalten | genau so (`prepare_isolation`, `WORK` in `run_case`, Bedingungen 1–4 unverändert) | OK |
| `harness/conventions.md` (MR-Block) update | **nicht geliefert — Ziel existiert nicht**; ersetzt durch `AGENTS.md:129` + `harness/README.md:53` | Drift, sachlich richtig ersetzt; Formulierung offen (Punkt 7) |
| ggf. `.gitignore`/Makefile | nicht nötig (Isolation in `/tmp`, `mktemp -d`) | OK — der Plan sah es als „ggf." vor |
| Isolations-Ansatz: Temp-Kopie / worktree / In-Container | **Temp-Kopie** (`tar`), die kleinste tragfähige Variante; worktree bewusst verworfen (slice-044-Falle), In-Container nicht angefasst | OK, Trigger §4 („erst Temp-Kopie liefern") eingehalten |
| **nicht geplant** | `test/mutate-driver.bats` +5 Tests, `test/mutations/72`, `73` | **Abweichung, pflichtig**: AGENTS §3.6 verlangt für jede neue Zusage ein rot gesehenes Gegenbeispiel. Kein ungeplantes *Verhalten*. |
| **nicht geplant** | Link-Reparaturen in `roadmap.md`, `welle-07-results.md`, `slice-045b-arch-cli.md` (`open/` → `in-progress/`) | OK — Folge des Lifecycle-Moves, doc-gate-pflichtig |

Nichts Geplantes fehlt außer dem nicht existierenden MR-Block. Kein ungeplantes Laufzeit-Verhalten.

**Risiken aus §6 — Stand:**
- *Docker-Build-Kontext:* aufgelöst und im Code dokumentiert (`:119-128`) — `.git` musste mit
  (actionlint), Ausschluss nur `.harness/state/`. Vom Grün-Vorlauf real gefangen (`mutate3.log`).
- *slice-044-Worktree-Falle:* aufgelöst, **fail-closed** (`:136-141`) und per Mutation 72 rot gesehen.
- *Semantik-Erhalt:* gehalten (Punkt 2).
- *Nicht-Ziel „Fälle unberührt":* gehalten — die 67 Altfälle sind byte-gleich.

---

## Restrisiken / Befunde

### R-1 (MEDIUM, verifier-only) — die fünfte Bedingung, das DoD-1-Messmittel, ist selbst unbewacht und nicht diskriminierend

Zwei getrennte Schwächen derselben Stelle (`mutate.sh:380-386`):

1. **Kein rot gesehenes Gegenbeispiel.** `grep -rn 'host-baum\|host_before\|host_after' test/` findet
   nichts außerhalb von `mutate.sh`. Weder ein bats-Test noch eine Mutation färbt den Vergleich oder
   `report_fail "host-baum"` rot. Mutation 73 deckt nur die *fail-closed*-Schranke **in**
   `target_fingerprint`, Mutation 72 nur den Ort der Kopie. Dreht jemand `!=` nach `=`, merkt es
   niemand — der Sensor der Kern-Zusage kann still grün werden. (Der Skript-Kopf `:18-21` benennt
   diese Kuratier-Grenze für `run_case`; `main()` und die fünfte Bedingung sind dort noch nicht genannt.)
2. **Nicht diskriminierend.** Bei einem *vollständigen* Lauf wäre der Vorher/Nachher-Vergleich auch
   unter dem **alten** Treiber grün gewesen (Backup + Restore). Er fängt nur den *persistenten*
   Leck-Fall (z. B. asymmetrisches Restore) — nicht das transiente Fenster, das F-12 ausmacht.
   Der Kommentar `:381-382` („Sie fällt, sobald ein Pfad wieder gegen `$REPO` statt gegen die Kopie
   läuft") stimmt für einen *einzelnen* zurückgedrehten Pfad, **nicht** für ein vollständiges
   Zurückdrehen aller sechs Stellen — dann sind Backup und Restore wieder symmetrisch und der
   Fingerabdruck schweigt. Die Aussage im Kommentar ist damit zu stark.

Billige Härtung: einen Fall-Hook, der mitten im Lauf einen Host-Fingerabdruck zieht, oder eine
Mutation, die `restore`s `-C "$WORK"` auf `-C "$REPO"` dreht (dann fällt die fünfte Bedingung real).

### R-2 (MEDIUM) — Doku-Overclaim: der Fingerabdruck belegt weniger, als die beiden Sätze behaupten

`AGENTS.md:129` und `harness/README.md:53` nennen den Fingerabdruck als Beleg für „der Arbeitsbaum
wird nie verändert". Gemessen werden 25 `# files:`-Ziele; der Rest des Baums ist konstruktiv, nicht
messtechnisch gedeckt. `mutate.sh:103-107` sagt das korrekt — die Doku übernimmt die Einschränkung
nicht. Ein Halbsatz genügt. (Siehe DoD-Punkt 7.)

### R-3 (LOW) — der Wächter gegen das leere Fall-Set ist toter Code geworden

`mutate.sh:342-347` („keine Faelle in `$CASES_DIR` — ein leeres Set ist kein gruener Lauf", ein
bewusster slice-026-Wächter gegen stilles Grün) ist **unerreichbar**: bei leerem `CASES_DIR`
scheitert schon `mutation_targets` (`:97`, Glob expandiert nicht → `sed` Exit 2 → leere Liste), also
bricht `main` bereits `:330-334` mit „Fingerabdruck nicht berechenbar" ab. Verhalten bleibt
fail-closed (kein stilles Grün), aber die Diagnose ist irreführend und ein dokumentierter Wächter
prüft ab jetzt über einem leeren Bereich. Entweder die Reihenfolge tauschen (Fall-Set-Prüfung vor
dem Fingerabdruck) oder den toten Zweig entfernen.

### R-4 (LOW) — verbleibender F-12-Kanal über geteilte Docker-Tags (nicht über den Baum)

Die Isolation trennt Dateien, **nicht** Docker-Tags. `make test`/`make lint` sind unkritisch (die
Assertion läuft im `docker build`, `Makefile:49/52`). `make artifact` baut jedoch
`ai-harness-init:build` und zieht das Binary danach in einem **getrennten** Schritt
(`docker create ai-harness-init:build`, `Makefile:65-70`) — und `make smoke`/`make full-smoke`
hängen daran. Läuft ein `make smoke` auf dem Host parallel zu einem mutate-Lauf, der gerade
`# verify: smoke` fährt, kann der Host-Lauf ein aus **mutiertem** Kontext gebautes Binary
extrahieren. Der Lock serialisiert nur mutate-gegen-mutate. Der Klammersatz in `:308-309`
(„die Ergebnisse blieben zwar korrekt") ist für diesen Pfad zu stark; die AGENTS-Formulierung
(„parallele **Gate-/Test**-Läufe sind unbedenklich") ist dagegen richtig eng.

### R-5 (LOW) — eine neue bats-Assertion prüft im mutate-Kontext über einem leeren Bereich

`test/mutate-driver.bats:81` (`[ ! -e "$dest/.harness/state" ]`) hat Zähne, wenn `make test` auf dem
Host läuft (dort existiert `.harness/state/`). Läuft dieselbe Datei **innerhalb** eines mutate-Laufs,
ist `CURDIR` die Kopie — die trägt `.harness/state` gar nicht, die Assertion ist trivial wahr.
Kein Defekt (der Hauptpfad `make gates` misst real), aber die Aussagekraft ist kontextabhängig; für
Zähne müsste der Test das Verzeichnis vor dem Kopieren selbst anlegen.

### R-6 (INFO) — der teuerste Beleg der DoD ist nicht festgehalten

Der parallele `make gates`-Lauf ist die eigentliche F-12-Reproduktion und damit der wertvollste
Beleg dieses Slices — er existiert nur als Behauptung. Bei der Closure in §7 gehört mindestens
die Beobachtung notiert (Uhrzeit, was parallel lief, Ergebnis); besser wäre, sie reproduzierbar zu
machen (Skript, das während eines mutate-Laufs im Sekundentakt `working-tree-hash.sh` sampelt).
Ohne das ist die Kernzusage des Slices in sechs Monaten nur noch Prosa.

### R-7 (INFO) — Kopie trägt `.git`, damit auch git-Schreibfähigkeit in der Kopie

`prepare_isolation` kopiert `.git` mit (nötig für actionlint). Damit könnte ein künftiger
Mutations-Fall git-Operationen ausführen — folgenlos für den Host (die Kopie ist ein eigenes Repo),
aber der Kopf sollte das benennen, damit niemand aus „`.git` ist da" auf „ist der Host" schließt.
Kein heutiger Fall tut es (geprüft: nur `72` enthält überhaupt den String `$REPO`, und der steht als
literaler Ersetzungstext im sed-Muster).

---

## Gesamturteil

**DoD im Kern BESTÄTIGT — mit zwei TEILWEISE-Punkten (1 und 7), die vor der Closure zu schließen sind.**

Die Substanz ist geliefert und strukturell zwingend: der Treiber hat **keinen** Schreibpfad mehr in
den Host-Baum (fünf Stellen in `run_case` plus Grün-Vorlauf gegen `$WORK`; jede `$REPO`-Verwendung
lesend), die Isolation liegt fail-closed außerhalb des Repos und ist per Mutation 72 rot gesehen,
die vier Befund-Wege und der Header-Vertrag sind unverändert, die Fall-Menge rein additiv (67 → 69),
und `make gates` lief nachweislich auf **genau diesem** Baum grün (Stempel == selbst berechneter
Tree-Hash, nicht zitiert). Der Lock ist neu begründet statt überflüssig behauptet, und die alte
Begründung wurde ersetzt, nicht ergänzt. Der Verlauf `mutate4→7` zeigt den Sensor bei der Arbeit:
er hat **zwei** zahnlose Eigen-Mutationen des Implementers gefangen.

Nicht bestätigt ist die diskriminierende Hälfte von DoD-1: das **Sample mitten im Lauf** ist aus
keinem Artefakt rekonstruierbar, und das im Code eingebaute Messmittel (Vorher/Nachher-Fingerabdruck)
kann diese Eigenschaft prinzipiell nicht belegen — es wäre unter dem alten, fehlerhaften Treiber
ebenso grün gewesen und deckt zudem nur 25 Zieldateien statt des Baums. Teilweise ist DoD-7: der
gemeldete Plan-Drift stimmt (den MR-Block gibt es nicht) und die Ersatz-Orte sind richtig gewählt,
aber beide neuen Sätze führen den Fingerabdruck als Beleg für eine Zusage an, die er nur zum Teil
trägt — die Overclaim-Klasse, die dieses Repo wiederholt fängt.

**Vor der Closure zu erledigen:**

1. **R-2 / DoD-7:** die Scope-Einschränkung des Fingerabdrucks in `AGENTS.md:129` und
   `harness/README.md:53` ergänzen (ein Halbsatz), und „kein Residuum" um den stale Lock relativieren.
2. **R-6 / DoD-1:** die parallele Beobachtung in §7 des Slice notieren — sonst existiert der
   teuerste Beleg dieses Slices nirgends.
3. **R-1:** als `open/`-Folgepunkt schneiden (Mutation, die `restore`s `-C "$WORK"` auf `-C "$REPO"`
   dreht → die fünfte Bedingung real rot sehen; Kommentar `:381-382` auf das entschärfen, was der
   Vergleich wirklich fängt).
4. **R-3, R-4, R-5, R-7** als Backlog-Notizen (toter Wächter, Docker-Tag-Kanal, kontextabhängige
   bats-Assertion, `.git` in der Kopie).

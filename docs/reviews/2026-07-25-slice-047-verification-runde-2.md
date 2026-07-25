# Verifier-Report slice-047 — Runde 2 (enge Nachprüfung der zwei TEILWEISE-Punkte)

Rolle: Verifier (Modul 11). Frischer Kontext, **strikt read-only** — kein `make`-Lauf, keine
Host-Toolchain (Schaden-Präzedenz: ein früherer Verifier-Subagent mutierte per
Hintergrund-`make mutate` den Haupt-Baum). Fix-Commit `8c3e095`, Vor-Stand `3bd554b`,
Slice-Basis `a6c78b2`. Datum: 2026-07-25.

**Scope dieser Runde** (eng, per Auftrag): DoD 1 und DoD 7 — die beiden Punkte, die
[Runde 1](2026-07-25-slice-047-verification.md) als TEILWEISE führte — plus die Frage, ob die
Nachbesserung einen bereits bestätigten Punkt (2–6) beschädigt hat. Punkte 2–6 werden **nicht**
neu verifiziert, nur auf Regression geprüft.

**Was ich unabhängig gemessen habe:**

- `git show 8c3e095` (voller Diff), `git diff --stat a6c78b2..HEAD`, `git log`, `git status`.
- Vollständiges Lesen des heutigen `harness/tools/mutate.sh` (445 Z.) und
  `test/mutate-driver.bats` (165 Z.); Lesen der drei Fälle `test/mutations/72|73|74`.
- **Gate-Stempel gegen den Baum:** `harness/tools/working-tree-hash.sh` (read-only: `git ls-files`
  + `sha256sum`, kein `make`) liefert
  `b7ce3820baa33954bf1b1680c21e5f0c745c8c209b4f02a99a32d28da351a0d0` — **byte-gleich** mit
  `.harness/state/gates-passed.diffsha`; `git status --porcelain` ist **leer**. `make gates` lief
  also real grün auf **genau diesem** Baum (HEAD `8c3e095`), nicht zitiert.
- **Anker-Eindeutigkeit der drei Fälle selbst nachgezählt** (die slice-037-Lehre):
  `^      return 1$` → **genau 1×** (`mutate.sh:132`), `-n "$targets" ] || return 1` → **genau 1×**
  (`:118`), `tar -cf - --exclude=./.harness/state` → **genau 1×** (`:149`). Das alte 72er-Muster
  `dest="$root/repo"` kommt **0×** vor — konsistent mit dem Umbau.
- **Ziel-Menge nachgezählt:** `mutation_targets` liefert heute **25 Pfade**, Fall-Zahl **70**.
- Log `mutate8.log` (11:18): Kopfzeile `isolierte Kopie unter /tmp/tmp.ACL5cZ93A2/repo`,
  Zeilen 73–75 = Fälle 72/73/74 je `ok … rot`, Schlusszeile `mutate: 70 ok, 0 Befund(e)`.
- Kein `.harness/state/mutate.lock` vorhanden → der Lauf endete sauber.

---

## Punkt 1 — DoD 1 („während UND nach dem Lauf byte-unverändert", Sample MITTEN im Lauf) — **BESTÄTIGT**

### a) Trägt die Mitten-im-Lauf-Prüfung die DoD-Formulierung? — ja

`mutate.sh:267-287` sitzt **in `run_case`**, direkt nach der Anwendung der Mutation (`:261`) und
**vor** Bedingung 2 (`:289`). Sie berechnet `target_fingerprint "$REPO" "$CASES_DIR"` (`:278`) und
vergleicht gegen die globale `HOST_BEFORE` (`:73`, gesetzt in `main` `:384` **vor** dem Kopieren).
Damit ist das „während" nicht mehr eine Sitzungs-Beobachtung, sondern **70 Messpunkte pro Lauf** —
je einer in genau dem Fenster, das F-12 ausmacht (Mutation angewandt, `restore` noch nicht gelaufen).
Das ist strikt mehr, als die DoD verlangte („ein paralleler `make test`/Hash-Sample MITTEN im Lauf").
Der Befund von Runde 1 („aus keinem Artefakt rekonstruierbar") ist damit gegenstandslos: der Beleg
hängt nicht mehr an einem Log, sondern am Code, und `mutate8.log:76` zeigt ihn 70× grün durchlaufen.

### b) Deckt sie den symmetrischen Rückfall wirklich? — ja, Code gelesen, nicht übernommen

Ich habe die drei Rückfall-Formen einzeln gegen den Code durchgespielt:

1. **Sed und Restore beide gegen `$REPO`** (exakt das Vor-slice-047-Verhalten, also `cd "$WORK"` →
   `cd "$REPO"` in `:249`/`:255`/`:261` und `:83`): der Sed trifft die Host-Zieldatei. Die Datei ist
   per Konstruktion in der Ziel-Menge — `mutation_targets` (`:99-101`) bildet die Vereinigung **aller**
   `# files:`-Köpfe, und das Ziel des laufenden Falls steht in seinem eigenen Kopf. Also
   `host_now != HOST_BEFORE` → `report_fail` `:284`. **Fällt.**
2. **`WORK` leer oder `= $REPO`**: fängt schon `require_isolated` (`:158-164`, aufgerufen `:391`)
   vor dem ersten Fall.
3. **Asymmetrisches Restore** (Sed in der Kopie, `restore` nach `$REPO`): fällt beim **nächsten**
   Fall in der Mitten-Prüfung und zusätzlich in der fünften Bedingung (`:433`).

Die **Reihenfolge** ist nachweislich richtig gewählt und nicht bloß behauptet: im Rückfall bleibt die
Kopie unverändert, also hätte Bedingung 2 (`:303`, „Mutation hat nicht gegriffen — Patch veraltet?")
zuerst gefeuert und einen gebrochenen Sensor als veralteten Patch **fehldiagnostiziert**. Der Kommentar
`:273-276` begründet das; der Code hält es (Prüfung `:277-287` steht vor der Schleife `:298`).

Beide neuen Zweige rufen **`restore` vor `return`** (`:280`, `:285`) — ohne das trüge die Kopie die
Mutation in alle Folgefälle. Geprüft, ist da.

Der Kommentar der fünften Bedingung ist mitgezogen und jetzt **nicht mehr zu stark**: `:425-428` sagt
ausdrücklich, dass sie ein *liegengebliebenes Residuum* fängt und den symmetrischen Rückfall **nicht**
sie fängt, sondern die Mitten-Prüfung. Genau die Überzeichnung aus Runde 1 (R-1.2) ist damit ersetzt,
nicht ergänzt.

### c) Ist die Beschränkung auf die `# files:`-Ziele mit der DoD vereinbar? — ja, mit einem benannten Rest

Die DoD sagt wörtlich „ein Content-Hash der **getrackten+ungetrackten** Dateien vor dem Lauf == nach
dem Lauf". Der Treiber misst **25 Pfade**, nicht den Baum. Was **bleibt offen**, exakt benannt:

- **Umfang:** eine Host-Schreibung **außerhalb** der 25 Ziele sähe der Treiber nicht. Der Rest des
  Baums ist **konstruktiv** gedeckt: ich habe jede `$REPO`-Verwendung im heutigen Skript erneut
  auditiert — `:65`/`:75` (Pfad-Ableitung), `:130`/`:161` (Vergleich), `:149` (`tar -cf -`, lesend),
  `:278`/`:384`/`:429` (Fingerabdruck, lesend). **Einziger Schreibpfad in `$REPO` ist `mkdir "$LOCK"`
  unter `.harness/state/` (`:356-357`) — gitignored, außerhalb des MR-003-Hashes.** Und
  beobachtungsseitig: nach `mutate8` (11:18) ist der Baum `git status`-clean und der Tree-Hash gleich
  dem Gate-Stempel.
- **Zeitfenster:** gemessen wird direkt nach dem Sed. Eine Host-Schreibung, die **während** des
  Sensor-Laufs (`make $verify` in der Kopie, `:312`) entstünde und vor dem nächsten Messpunkt wieder
  verschwände, bliebe unsichtbar. Rein theoretisch — der Sensor-Lauf hat kein `$REPO` im Kontext.

Beides ist derselbe Rest, den Runde 1 schon als „strukturell erfüllt, messtechnisch auf der Ziel-Menge"
akzeptierte; er war **nicht** der Grund für TEILWEISE. Der Grund war die fehlende Diskriminierung —
und die ist geschlossen.

### d) §3.6 für die neue Zusage — erfüllt, aber die Begründung stimmt nicht (siehe R2-1)

Ein Gegenbeispiel ist **benannt und einmal rot gesehen** (Sed und Restore in einer Wegwerf-Kopie auf
den Baum zurückgedreht → `die Mutation hat den HOST-Baum getroffen statt die Kopie — Isolation
gebrochen`), festgehalten in der Commit-Message von `8c3e095`. §3.6 (`AGENTS.md:82-85`) nennt die
Commit-Message ausdrücklich als Träger einer Zusage und verlangt „benannt + einmal rot gesehen" —
das ist gehalten. **Nicht** gehalten ist die Begründung, warum kein dauerhafter Wächter existiert
(→ R2-1); das ist ein Haltbarkeits-, kein DoD-1-Defekt.

## Punkt 2 — DoD 7 (Doku hält genau, was der Code hält) — **BESTÄTIGT**

Beide Sätze sind **umgeschrieben, nicht ergänzt**, und ich habe sie Klausel für Klausel gegen den
Code gehalten:

| Klausel (Doku) | Code | Urteil |
|---|---|---|
| „vergleicht die Mutations-Zieldateien im Arbeitsbaum vor, **während** und nach dem Lauf" (`AGENTS.md:129`, `harness/README.md:53`) | `HOST_BEFORE` `:384` · `host_now` `:278` (je Fall) · `host_after` `:429` | **exakt** |
| „nur diese Dateien — nicht den ganzen Baum" | `target_fingerprint` `:115-120` über `mutation_targets` `:99-101`, 25 Pfade | **exakt** — die Scope-Einschränkung aus `mutate.sh:106-110` ist jetzt an beiden Doku-Stellen da |
| „fail-closed" (README) | `:118` `return 1` bei leerer Liste; `:278-282` und `:429-432` melden statt zu schweigen | trägt |
| „der Arbeitsbaum wird nie verändert" | kein Schreibpfad in den getrackten Baum (Audit oben) | trägt |
| „parallele Gate-/Test-Läufe sind unbedenklich" (AGENTS) | `gates`/`test` schreiben keine Quelldatei | trägt, richtig eng formuliert |
| „ein Abbruch lässt kein Residuum zurück" (AGENTS) | SIGKILL lässt `.harness/state/mutate.lock` (`:23-28`) + ~8 MB `/tmp` liegen | **zu absolut** → R2-3 |
| „damit paralleles Arbeiten den Lauf nicht rötet" | gilt für Doku/Slices/Reviews; für die 25 Ziel-Quelldateien rötet es seit dem Fix **pro Fall** | verkürzt → R2-2/R2-4 |

**Der Overclaim, der DoD 7 auf TEILWEISE setzte** — der Fingerabdruck als Beleg für die volle Zusage
ohne Nennung seines Umfangs — **ist geschlossen**, an beiden Stellen wörtlich.

**Der Plan-Drift bleibt bestätigt und die Ersetzung vollständig:** `grep '^### MR-' harness/conventions.md`
→ weiterhin MR-000…MR-014, kein Eintrag zu mutate/F-12/Host-Baum; die vier mutate-Vorkommen
(`:562`, `:565`, `:573`, `:601`) stehen im MR-014-CI-Block und sagen nur, dass CI `make mutate` fährt.
Der DoD-Punkt zielte auf einen Ort, den es nicht gibt; `AGENTS.md:129` + `harness/README.md:53` sind
die einzigen zwei Stellen, an denen `make mutate` beschrieben wird, und beide sind nachgezogen.
Ein neuer MR-Eintrag wäre möglich, ist aber nicht gefordert (die Konvention wurde nicht durch eine
Regel ersetzt, sondern durch Struktur aufgelöst).

Offen bleibt nur der Halbsatz „kein Residuum" (R2-3) — er stand als **zweite Hälfte** von Runde-1-To-do 1
auf der Closure-Liste und wurde nicht geliefert. Er betrifft nicht die Mess-Zusage von DoD 7, sondern
die Abbruch-Aussage (DoD 3, dort schon als Nuance a bestätigt), ist LOW und mit einem Halbsatz zu heilen.

---

## Regressions-Prüfung der bestätigten Punkte 2–6

### DoD 2 (Sensor semantisch identisch) — **nicht beschädigt**

- **Die vier Befund-Wege stehen 1:1**, nur um die neue Prüfung herum verschoben:
  (1) Mutations-Skript scheitert `:261-265`, (2) Mutation greift nicht `:303-307`,
  (3) Sensor bleibt grün `:314-318`, (4) rot aus falschem Grund `:328-333`.
- **Header-Vertrag unverändert:** Doppelkopf `:217-222`, `# files:`/`# expect:` Pflicht `:233-236`,
  `# verify:`-Default `:232`, Zulassung aus `failure_form` `:238-241` (einzige Quelle, `:198-205`).
- **Ausgabeform unverändert:** `mutate: $pass_count ok, $fail_count Befund(e)` `:437`;
  Grün-Vorlauf je Modus `:394-418`; `main()`-Kapselung `:344`/`:442`.
- **Reihenfolge-Änderung geprüft:** die neue Prüfung ist im Normalfall wirkungslos (Host unverändert →
  `host_now == HOST_BEFORE` → Durchlauf). Ein *legitim* wirkungsloser Patch ändert den Host nicht,
  erreicht also weiterhin Bedingung 2 und wird weiterhin als „Patch veraltet?" gemeldet — die
  Fehldiagnose läuft in die **richtige** Richtung (gebrochener Sensor schlägt veralteten Patch).
- **Fall-Menge weiterhin additiv:** `git diff --stat a6c78b2..HEAD -- test/mutations/` zeigt **nur**
  72/73/74 (`45 insertions`, keine Löschung) — die 67 Altfälle sind seit Slice-Beginn byte-gleich.
  Dass 72 und 73 im Fix umgeschrieben wurden, betrifft nur die **eigenen** neuen Fälle dieses Slices.
- **Neu: ein fünfter Abbruch-Weg in `run_case`.** Er ist DoD-1-gefordert und fail-closed, aber er ist
  eine Semantik-Erweiterung — siehe R2-2.

### DoD 3 (Abbruch ohne Residuen) — **nicht beschädigt**

`restore` `:78-87`, `cleanup` `:166-173`, `trap` `:177` sind vom Fix **unberührt** (kein Diff-Hunk).
Beide neuen Zweige rufen `restore` (`:280`, `:285`). Kein neuer Schreibpfad in `$REPO`.

### DoD 4 (Lock neu begründet) — **nicht beschädigt**

Der Lock-Block `:345-363` trägt keinen Diff-Hunk; die ersetzte Begründung (Ressourcen-Serialisierung
statt Baum-Schutz) und die mitgezogene Abbruch-Meldung `:358-360` stehen unverändert.

### DoD 5 (`make gates` grün inkl. shellcheck) — **unabhängig neu bestätigt**

Stempel `b7ce3820…` == selbst berechneter Tree-Hash, Tree clean → `make gates` lief auf **genau diesem**
Stand grün. `shell-lint` (`Makefile:91-93`) linted `harness/tools/*.sh` **und** `test/mutations/*.sh`,
deckt also `mutate.sh` und den neuen Fall 74. Die Doku-Änderungen (`AGENTS.md:129`,
`harness/README.md:53`) fallen unter `docs-check`.

### DoD 6 (`make mutate` grün, neue Fälle rot gesehen) — **nicht beschädigt, erweitert**

`mutate8.log`: `70 ok, 0 Befund(e)`, Kopfzeile mit Isolations-Pfad; die drei Fälle je an **ihrem
eigenen** Wächter rot:
`72 -> isolation_path VERWEIGERT ein Ziel unter dem Repo`,
`73 -> target_fingerprint FAELLT bei leerer Ziel-Liste`,
`74 -> die Kopie traegt den Sensor-Bedarf inklusive .git`.
Fall 72 ist damit von der Nicht-Leer-Assertion auf die **Ortsregel selbst** umverankert (Review F-5),
Fall 73 auf die volle Zeile statt des mehrdeutig gewordenen `|| return 1` (das jetzt 2× vorkommt,
`:118`/`:147` — die Re-Verankerung war nötig und ist korrekt). Alle drei Anker sind eindeutig
(nachgezählt, s. o.), alle drei brechen **Verhalten, nicht das Kompilat** (slice-045b-Lehre).
Bonus, nicht gefordert: R-3 aus Runde 1 (toter Leer-Set-Wächter) ist geschlossen — die
Fall-Set-Prüfung `:373-381` steht jetzt **vor** dem Fingerabdruck `:384`.

---

## Befunde dieser Runde

### R2-1 (MEDIUM) — der Wächter, der jetzt DoD 1 trägt, ist selbst unbewacht; die Begründung dafür ist falsch

`grep -rn 'Isolation gebrochen\|host_now\|HOST_BEFORE' test/` findet **nichts**. Weder ein bats-Test
noch ein Mutations-Fall färbt `mutate.sh:283-287` rot. Wer `!=` nach `=` dreht oder den Block löscht,
bekommt einen grünen `make test`, ein grünes `make mutate` und ein grünes `make gates` — die
diskriminierende Hälfte von DoD 1 kann still verschwinden. Das ist R-1.1 aus Runde 1, eine Ebene
weitergewandert, und dieselbe Klasse wie Review-F-3 („fünf neue Wächter, zwei Fälle").

**Die Begründung im Commit („als Mutations-Fall unmöglich — `make mutate` kann sich nicht selbst
fahren") trägt nicht.** Das Muster dieses Slices ist ein anderes und dreimal vorgeführt: die Einheit
hermetisch in `test/mutate-driver.bats` prüfen, dann per Fall in `test/mutations/` mutieren — genau so
sind `isolation_path` (72), `target_fingerprint` (73) und `prepare_isolation` (74) bewacht. Für die
Mitten-Prüfung geht das ebenso, weil **beide neuen Zweige vor jedem `make`-Aufruf zurückkehren**
(`:280`, `:285`): ein Test kann `mutate.sh` sourcen, `WORK` auf ein Temp-Verzeichnis mit der
Ziel-Datei setzen, `HOST_BEFORE` absichtlich falsch belegen und `run_case` gegen eine Wegwerf-Fall-Datei
laufen lassen — der Pfad endet bei `report_fail`, ohne Docker, ohne `make`. Alle dafür nötigen
Werkzeuge (`tar`, `sed`, `sha256sum`, `mktemp`) sind im bats-Container nachweislich vorhanden, sie
werden von den bestehenden Tests `:91-104` und `:111-123` benutzt.

Nicht closure-blockierend (§3.6 ist durch das benannte, einmal rot gesehene Gegenbeispiel formal
erfüllt), aber der Satz „als Fall nicht darstellbar" gehört korrigiert, und der Fall gehört als
`open/`-Folgepunkt geschnitten — sonst steht die teuerste Eigenschaft dieses Slices ab morgen wieder
nur in Prosa.

### R2-2 (LOW) — die Mitten-Prüfung diagnostiziert absolut, wo ihre Zwillings-Bedingung hedged

`:284` meldet unbedingt „die Mutation hat den HOST-Baum getroffen statt die Kopie — Isolation
gebrochen". Die fünfte Bedingung sagt für **denselben** Messwert korrekt „entweder greift die
Isolation nicht, **oder es wurde parallel editiert**" (`:434`). Der Treiber kann die beiden Ursachen
nicht unterscheiden. Folge: editiert jemand während eines Laufs eine der 25 Ziel-Dateien (das sind die
heißen Quellen: `internal/gen/*.go`, `internal/emit/*.go`, `cmd/ai-harness-init/main.go`,
`harness/tools/*.sh`, `.github/workflows/ci.yml`), bricht **jeder Folgefall** vor seiner Messung ab
und meldet einen Isolations-Bruch. Vorher war das **ein** Befund am Ende bei sonst vollständiger
Messung; jetzt kollabiert der Informationsgehalt des Laufs, und die Meldung schickt den Leser auf die
falsche Fährte (Harness-Integrität statt „Finger weg vom Baum, solange mutate läuft").
Fail-closed ist hier die richtige Wahl — nur die Formulierung sollte die von `:434` spiegeln.

### R2-3 (LOW, offener Rest aus Runde 1) — „ein Abbruch lässt kein Residuum zurück" ist weiterhin unrelativiert

`AGENTS.md:129`. Ein SIGKILL hinterlässt `.harness/state/mutate.lock` (blockiert **jeden** weiteren
Lauf, bis er von Hand entfernt wird) und ~8 MB unter `/tmp`. `mutate.sh:23-28` und `:174-176` sagen
das sauber („kein Residuum **im Baum**"); die AGENTS-Zeile verkürzt auf „kein Residuum". Stand auf der
Runde-1-Closure-Liste (To-do 1, zweite Hälfte) und wurde nicht geliefert. Ein Halbsatz schließt es.

### R2-4 (INFO) — „damit paralleles Arbeiten den Lauf nicht rötet" gilt nur für die Nicht-Ziel-Dateien

`AGENTS.md:129` / `harness/README.md:53` geben den Zweck der Scope-Begrenzung als Eigenschaft aus.
`mutate.sh:106-110` ist präziser: gemeint ist parallele Arbeit an **Doku, Slice-Dateien, Reviews**.
Arbeit an den 25 Zielen rötet sehr wohl (und seit dem Fix pro Fall, s. R2-2). Grenzfall derselben
Überzeichnungs-Klasse, aber deutlich schwächer als der geschlossene Fingerabdruck-Overclaim.

### R2-5 (INFO) — der Rot-Beleg lebt nur in der Commit-Message

Der manuelle Rückfall-Versuch (Sed + Restore zurückgedreht → Meldung gesehen) steht ausschließlich in
`8c3e095`. Kein `docs/reviews/`-Bericht trägt ihn (`2026-07-25-slice-047-impl-review.md` ist 10:57,
also **vor** dem Fix), §7 des Slice ist leer. Gehört in die Closure-Notiz — mit Uhrzeit, genauem
Rückdreh-Umfang und der beobachteten Meldung.

**Weiter gültig aus Runde 1:** R-4 (Docker-Tag-Kanal über `ai-harness-init:build` in
`artifact`/`smoke`, vom Implementer als Restrisiko übernommen), R-5 (kontextabhängige
bats-Assertion `[ ! -e "$dest/.harness/state" ]`, jetzt `test/mutate-driver.bats:102`), R-7 (`.git`
in der Kopie). R-3 ist geschlossen, R-6 durch die Mitten-Prüfung strukturell erledigt.

---

## Gesamturteil

**DoD BESTÄTIGT.** Beide TEILWEISE-Punkte aus Runde 1 sind geschlossen.

DoD 1: die diskriminierende Hälfte ist nicht mehr eine unbelegte Handbeobachtung, sondern
**Mechanik** — `run_case` misst den Host-Fingerabdruck 70× pro Lauf in genau dem Fenster zwischen Sed
und Restore, das F-12 ausmacht, und der symmetrische Rückfall fällt dort nachweislich (Code gelesen,
drei Rückfall-Formen einzeln durchgespielt; die Ziel-Menge enthält per Konstruktion das Ziel des
laufenden Falls, die Prüfung steht vor Bedingung 2, beide Zweige rufen `restore`). Der Kommentar der
fünften Bedingung ist auf das entschärft, was sie wirklich fängt. Rest: gemessen wird die
Ziel-Menge (25 Pfade), nicht der Baum — für den Rest trägt der Schreibpfad-Audit (einziger
`$REPO`-Schreibzugriff ist der gitignorete Lock) und der clean gemessene Tree.

DoD 7: beide Sätze nennen jetzt „vor, **während** und nach" und die Beschränkung auf die
Zieldateien; ich habe sie Klausel für Klausel gegen den Code gehalten, und sechs von sieben Klauseln
halten exakt. Der Plan-Drift bleibt bestätigt, die Ersetzung ist der vollständige Ort.

Kein bestätigter Punkt wurde beschädigt: die vier Befund-Wege, der Header-Vertrag, die Ausgabeform,
der Lock-Block und `restore`/`cleanup`/`trap` sind unverändert; die Alt-Fälle sind byte-gleich; die
neue Prüfung ist im Normalfall wirkungslos und diagnostiziert im Fehlerfall in die richtige Richtung.
`make gates` ist unabhängig als grün auf **diesem** Baum belegt (Stempel == selbst berechneter Hash).

**Vor der Closure (nicht blockierend, aber benannt):**

1. **R2-3:** Halbsatz in `AGENTS.md:129` — „kein Residuum **im Baum**; ein harter Abbruch lässt den
   Lock stehen (fail-closed, Pfad wird gemeldet)".
2. **R2-2:** die Meldung `mutate.sh:284` auf die hedged Formulierung von `:434` bringen.
3. **R2-1:** als `open/`-Folgepunkt schneiden — bats-Wächter für die Mitten-Prüfung + Mutations-Fall
   auf `!=` — und die Aussage „als Fall nicht darstellbar" in der Closure-Notiz korrigieren.
4. **R2-5:** den Rot-Beleg in §7 des Slice festhalten (Uhrzeit, Rückdreh-Umfang, Meldung).
5. **R2-4, R-4, R-5, R-7** als Backlog-Notizen.

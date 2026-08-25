# Slice slice-100: Der Grün-Vorlauf nennt den Grund — ein Abbruch ohne die Ausgabe des roten Sensors ist eine Diagnose, die niemand hat

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — der Gegenstand ist eine Schleife in einer Datei
plus ihr Wächter; der Slice ist einzeln lieferbar und wartet auf keinen zweiten. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser
reaktiv oder gewollt?** Reaktiv: ein CI-Job ist rot geworden und der Lauf konnte nicht sagen,
warum. Kein Fähigkeits-Sprung — die emittierte Ebene bleibt unberührt, das Werkzeug lernt nichts
Neues, ein bestehender Treiber gibt eine Auskunft, die er heute wegwirft. Präzedenz für wellenlose
Wartung an genau diesem Treiber sind slice-026 (sein Bau) und slice-093 (seine letzte Erweiterung),
beide *ohne Welle*
(`grep -h '^\*\*Welle:' docs/plan/planning/done/slice-0{26,93}-*.md`). **Nicht** als Präzedenz
angeführt ist slice-027, obwohl auch er wellenlos lief:
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
zählt ihn ausdrücklich zu den drei Fähigkeits-Sprüngen, die Frage 3 heute anders entschiede. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.
[welle-12](../welle-12-erfassungsschicht-emittieren.md) bleibt unberührt — sie führt die
Erfassungsschicht, nicht den Mutations-Treiber.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Sensor, dessen Abbruch keinen Grund nennt, ist die stille Variante derselben Klasse: er meldet ein
Urteil, dessen Grundlage der Lauf nicht mehr hat),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (*ein Kommentar beschreibt, was da ist* — hier auf eine
Laufzeit-Meldung angewandt: sie beschreibt heute eine Ursache, die der Treiber nicht kennt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (DoD 1 unten hat zwei Bruchstellen und bekommt für jede
ein eigenes Gegenbeispiel, dazu eine Gegenprobe über den echten Pfad; DoD 2 hat gar keines, und das
steht dort),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (die CI
ist der Ort, an dem der Abbruch beobachtet wurde, und sie ruft nur `make`-Targets — der Grund
gehört darum in das Target, nicht in den Workflow),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie ausgibt).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Bricht der Grün-Vorlauf von `make mutate` ab, steht die Ausgabe des Sensors, der rot war, im
selben Protokoll — und der Abbruch-Satz behauptet nur, was der Treiber wissen kann.**

**Das sind zwei Zusagen, nicht eine, und sie sind ungleich gedeckt.** Die erste ist Mechanik und
bekommt drei Rot-Läufe (DoD 1). Die zweite ist ein Urteil über einen Satz; für sie existiert **kein
Kommando**, und das steht bei ihr (DoD 2), statt sich hinter der ersten zu verstecken.

### Der Anlass: ein roter Job, dessen Grund der Lauf weggeworfen hat

Der `mutate`-Job des CI-Laufs `32815700451` endete nach **285 s** mit
(`gh api repos/:owner/:repo/actions/runs/32815700451/jobs --jq '.jobs[] | select(.name=="mutate")
| ((.completed_at|fromdate)-(.started_at|fromdate))'`)

```
mutate: Gruen-Vorlauf make full-smoke (muss VOR der ersten Mutation gruen sein)
mutate: ABBRUCH — make full-smoke ist schon ohne Mutation rot.
  Auf rotem Baum ist jeder Fall bedeutungslos: er waere rot, aber nicht
  wegen SEINER Mutation. Erst den Baum gruen bekommen.
```

Das ist die **vollständige** Evidenz des Laufs. Warum `make full-smoke` rot war, steht nirgends —
der Vorlauf verwirft `stdout` und `stderr` des Sensors
(`grep -n 'make "\$m"' harness/tools/mutate.sh` → eine Zeile, sie endet auf `>/dev/null 2>&1`).
Wer den Job liest, hat einen Exit-Code und einen Satz, der eine Ursache benennt, die der Treiber
nicht gemessen hat.

### Bestandsaufnahme — gemessen am 2026-08-25, Kommando neben der Aussage

Keine dieser Zahlen ist ein Erwartungswert; sie wandern mit dem Bestand, über den sie sprechen
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Sie beschreiben die Ausgangslage, gegen die geschnitten wird.

| Aussage | Wert | Kommando |
|---|---|---|
| Modi, die der Vorlauf vor der ersten Mutation fährt | **5** | `{ echo test; sed -n 's/^# verify: //p' test/mutations/*.sh; } \| LC_ALL=C sort -u \| wc -l` |
| Stellen in `harness/tools/mutate.sh`, die eine Ausgabe nach `/dev/null 2>&1` schicken | **2** | `grep -c '>/dev/null 2>&1' harness/tools/mutate.sh` |
| Fälle in `test/mutations/` | **147** | `ls test/mutations/*.sh \| wc -l` |
| `make full-smoke` über diesem Baum | **81.15 s**, Exit 0 | `/usr/bin/time -f 'FULLSMOKE_SECONDS=%e' make full-smoke` |
| Zeilen, die dieser grüne Lauf druckt | **2883** | derselbe Lauf nach `>fs.log 2>&1`, dann `wc -l <fs.log` |

Die letzten zwei Zeilen tragen die Schnitt-Entscheidung: der Sensor ist **gesprächig**, und genau
sein Gerede ist die Diagnose, die der Vorlauf heute wegwirft. Sie sagen zugleich, dass ein
ungefiltertes Durchreichen keine Lösung ist — 2883 Zeilen je Modus wären der zweite Weg, eine
Ursache unsichtbar zu machen.

### Die vermutete Ursache trägt nicht — vier Messungen gegen sie

Die naheliegende Lesart lautet: `full-smoke` läuft im Durchgang zweimal, einmal als eigener Job und
einmal im Vorlauf von `mutate`, beide auf `ubuntu-24.04`, also auf derselben Maschine — die
Ressourcen kollidieren. **Diese Lesart ist gemessen falsch, und drei weitere Zahlen sprechen gegen
sie.**

1. **`ubuntu-24.04` ist ein Label, keine Maschine.** Die vier Jobs eines Laufs bekommen vier
   verschiedene Runner:
   `gh api repos/:owner/:repo/actions/runs/32815700451/jobs --jq '[.jobs[].runner_id] | "\(length) Jobs, \(unique|length) Runner"'`
   → **4 Jobs, 4 Runner**; über den grünen Lauf `32818758506` dasselbe Kommando → **4 Jobs, 4
   Runner**. Es gibt keine geteilte CPU, keinen geteilten Cache und kein geteiltes Dateisystem
   zwischen ihnen. `.github/workflows/ci.yml` sagt das an einer Stelle bereits selbst
   (`grep -n 'eigenen Runner' .github/workflows/ci.yml` → **1**).
2. **„Jeder Push rot" ist nicht die gemessene Häufigkeit.** Gezählt wird über eine benannte
   Eigenschaft: *CI-Läufe seit `569eec7`, deren `mutate`-Job ein Verdikt erreicht hat* — abgebrochene
   Läufe zählen nicht, sie sagen nichts über den Sensor. Das Kommando gibt genau diese Menge aus:

   ```sh
   for id in $(gh run list --workflow=ci.yml --limit 100 --json databaseId,createdAt \
       --jq '.[] | select(.createdAt > "2026-08-23T16:50:47Z") | .databaseId'); do
     gh api "repos/:owner/:repo/actions/runs/$id/jobs" \
       --jq '.jobs[] | select(.name=="mutate") | .conclusion // "laeuft"'
   done | sort | uniq -c
   ```

   → `7 success`, **`1 failure`**, `5 cancelled`, `1 laeuft`. Verdikte sind **8**, rot ist **1**.
   Der Zeitpunkt in der Auswahl ist der Commit, mit dem der Modus entstand
   (`git log -1 --format='%ad' --date=iso 569eec7` → **2026-08-23 18:50:47 +0200**). Ein Fehlschlag
   in acht ist flatterig, nicht deterministisch — und Flattern verlangt eine Ursachen-Messung,
   bevor es eine Gegenmaßnahme verlangt.
3. **Derselbe Sensor war im selben Lauf grün — auf einem anderen Runner.** Im roten Lauf lief der
   Job `full-smoke` **241 s** und wurde grün, während der Vorlauf nach **219 s** rot abbrach
   (`gh run view 32815700451 --json jobs --jq '.jobs[] | [.name,.conclusion] | @tsv'`; die 219 s
   sind die Differenz der zwei Zeitstempel im Job-Log). Beide Jobs checken denselben Commit aus;
   der Vorlauf fährt eine `tar`-Kopie dieses Baums unter einem anderen Pfad. Der **Inhalt** des
   Baums scheidet damit als Ursache aus — was bleibt, ist der Pfad oder die Umgebung. Über diesem
   Baum hier fährt `make full-smoke` in **81.15 s** grün (Tabelle oben).
4. **Docker ist keine unterscheidende Eigenschaft — alle vier Jobs fahren es.** Eigenschaft: *ein
   CI-Job, dessen `make`-Target — direkt oder über ein aufgerufenes Skript oder Sub-`make` —
   `docker` ausführt.* Gemessen **4 von 4**, je Job mit eigenem Kommando:
   `gates` → `make -n gates \| grep -c docker` → **8**;
   `smoke` → `grep -c docker harness/tools/smoke.sh` → **2**;
   `full-smoke` → `grep -c docker harness/tools/full-smoke.sh` → **1** (dazu `make artifact` und
   `make -j -C <ziel> gates`, die selbst bauen);
   `mutate` → `grep -c docker harness/tools/mutate.sh` → **0**, aber sein Vorlauf fährt die fünf
   Modi aus der Tabelle, und `make -n test \| grep -c docker` → **2**,
   `make -n test-go \| grep -c docker` → **1**, `make -n ci-lint \| grep -c docker` → **1**.
   Eine Eigenschaft, die auf alle vier zutrifft, trennt die zwei Verdächtigen von nichts ab.

**Was der Vorlauf seit `569eec7` wirklich kostet, ist dagegen belegt.** Der `mutate`-Job lag in den
acht grünen Läufen davor bei **806–880 s**, in den sechs grünen danach bei **1098–1173 s**
(je Lauf `gh api repos/:owner/:repo/actions/runs/<id>/jobs --jq '.jobs[] | select(.name=="mutate")
| ((.completed_at|fromdate)-(.started_at|fromdate))'`, Läufe aus dem Kommando unter Punkt 2). Der
Aufschlag ist real und gewollt — er ist der Preis eines Modus, den slice-093 mit seinem Kopf-Text
bezahlt hat. Er ist **keine** Erklärung für ein Rot.

### Die Abwägung: vier Wege, einer gewählt

- **(A) Der Abbruch trägt die Ausgabe des roten Modus — gewählt.** Er ist der einzige Weg, der
  keine Ursache voraussetzt. Die drei anderen wählen eine Gegenmaßnahme, bevor die Klasse des
  Fehlschlags feststeht; nach Punkt 1–3 oben liegt sie außerhalb des Baum-Inhalts, und **welche**
  Ursache es war, entscheidet allein die weggeworfene Ausgabe. Kandidaten gäbe es genug — ein
  Registry-Limit, der Plattenplatz, ein abgerissener Pull —, und die Aufzählung ist offen: sie ist
  eine Vermutungsliste, keine gemessene Menge, und genau deshalb wird hier nicht aus ihr gewählt.
  Der Preis ist ein `mktemp`-Log und zwölf Zeilen im Protokoll; der Gewinn ist, dass der **nächste**
  Abbruch die Frage beantwortet, statt sie zu wiederholen.
- **(B) `needs: full-smoke` am `mutate`-Job.** Verworfen, und nicht wegen der Laufzeit. Er wirkt
  gegen nichts: die zwei Jobs teilen keine Maschine (Punkt 1), also sequenziert er zwei Dinge, die
  einander nie im Weg standen. Bezahlt würde das mit **241 s** Wanduhr auf **jedem** Push (die
  Laufzeit des `full-smoke`-Jobs im Referenz-Lauf, Punkt 3). Ein Nutzen bliebe: bei einem
  **wirklich** roten Baum spart `needs:` die vergeblichen vier Minuten des `mutate`-Jobs. Genau
  dieser Fall ist in der gemessenen Menge aber **nicht** aufgetreten — der eine Fehlschlag lief
  neben einem grünen `full-smoke`-Job.
- **(C) Den Vorlauf entlasten, etwa `full-smoke` überspringen, weil es als eigener Job läuft.**
  Verworfen — es geht nicht einmal. Der Vorlauf fährt `full-smoke` **auf der isolierten Kopie**
  unter `mktemp -d` außerhalb des Repos
  (`grep -n 'isolierte Kopie unter' harness/tools/mutate.sh` → **1**), nicht auf dem Checkout, den
  der `full-smoke`-Job prüft; ein grüner Job ist damit keine Aussage über den grünen Vorlauf, und
  ein Überspringen tauschte einen Beleg gegen einen anderen, der ihn nicht trägt. Dazu kommt die
  Schichten-Frage: `harness/tools/mutate.sh` nennt CI an keiner Stelle
  (`grep -ci 'github\|workflow\|CI-Lauf' harness/tools/mutate.sh` → **0**), ein Sensor, der sich
  auf Nachbar-Jobs verließe, wäre nur noch in CI vollständig. Und ein Vorlauf, der Modi überspringt,
  verliert die Eigenschaft, für die er existiert; sein Kopf sagt, warum es ihn gibt — *während des
  Reviews färbte ein paralleler mutate-Lauf im selben Arbeitsbaum die Tests rot*
  (`grep -c 'faerbte ein' harness/tools/mutate.sh` → **1**).
- **(D) `concurrency`-Gruppe oder ein größerer Runner für `mutate`.** Verworfen. Eine
  `concurrency`-Gruppe serialisiert **Läufe**, nicht die Jobs eines Laufs — `.github/workflows/ci.yml`
  führt bereits eine (`grep -c '^concurrency:' .github/workflows/ci.yml` → **1**), und sie hat den
  Fehlschlag nicht verhindert, weil er innerhalb eines Laufs entstand. Ein größerer Runner wäre die
  Gegenmaßnahme gegen *Plattenplatz oder Speicher* — eine der Vermutungen aus (A), und welche
  zutrifft, sagt erst (A) selbst. Er kostet außerdem Geld, und eine Ausgabe für eine ungemessene
  Ursache ist eine Wette.

**Was der gewählte Weg ausdrücklich nicht mitentscheidet:** ob der `mutate`-Job am Ende ein
`needs:`, einen anderen Runner oder gar nichts bekommt. Er stellt die Messung her, die diese Wahl
trägt; die Wahl selbst ist ein Folge-Slice mit einem beobachtbaren Trigger (§6).

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando existiert, steht das dabei — und wo ein
Kommando nur eine Hälfte einer Zusage erreicht, steht die andere Hälfte mit ihrem eigenen
Gegenbeispiel daneben.

- [ ] **(1) Ein abgebrochener Grün-Vorlauf zeigt die letzten Zeilen des Modus, der rot war — in
      derselben Form, in der der Fall-Pfad sie schon zeigt.** Der Fall-Pfad hat das Werkzeug
      bereits: `show_tail` schreibt zwölf eingerückte Zeilen des Sensor-Logs nach `stderr`
      (`grep -c 'show_tail()' harness/tools/mutate.sh` → **1**); es steht heute lokal in `run_case`
      und muss dafür herausgehoben werden.
      **Die Zusage hat zwei Bruchstellen, denn `>/dev/null` und `2>&1` sind zwei Umleitungen.**
      Ein Gegenbeispiel für nur eine von beiden erfüllte §3.6 nur formal: es bliebe offen, ob der
      *andere* Strom weiterhin verschwindet — und bei `make full-smoke` liegt die tragende Zeile
      auf `stderr` (`grep -c 'full-smoke: FEHLER.*>&2' harness/tools/full-smoke.sh` → **73**),
      während der Kontext davor auf `stdout` steht. Deshalb hängen an diesem Punkt **zwei**
      stehende Gegenbeispiele und eine Gegenprobe über den echten Pfad, und alle drei gehören mit
      ihrer Ausgabe in die Verify-Notiz, nicht nur ihr Ergebnis.
      **Rot A (`stdout`):** ein Fall in [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats)
      über die aus `main` herausgelöste Vorlauf-Funktion, mit einem `make`-Stub auf `$PATH`, der
      eine Marker-Zeile nach `stdout` **und** eine nach `stderr` druckt und Exit 1 liefert; der Fall
      verlangt **beide** Marker in der Ausgabe des Abbruchs. Rot gesehen, indem allein
      `>/dev/null` an der Aufruf-Stelle wiederhergestellt wird → der `stdout`-Marker fehlt.
      **Rot B (`stderr`):** derselbe Fall, rot gesehen, indem allein `2>/dev/null` gesetzt wird →
      der `stderr`-Marker fehlt. A und B sind nacheinander zu fahren; ein einziger Eingriff, der
      beide Ströme gleichzeitig wegnimmt, belegt keine der zwei Hälften einzeln.
      **Rot C (Gegenprobe über den echten Pfad, einmalig):** den ersten und billigsten Modus der
      Schleife absichtlich rot machen — eine Zeile in einem Go- oder bats-Test, sodass `make test`
      fällt — und `make mutate` fahren. Mit der heutigen Fassung endet der Lauf mit dem
      Abbruch-Satz und **null** Zeilen des Sensors; mit der neuen stehen die zwölf Zeilen darunter.
      Ohne diese Richtung wäre nur belegt, dass die herausgelöste Funktion isoliert trägt, nicht
      dass der reale Lauf sie erreicht. Der Eingriff wird danach zurückgenommen.
- [ ] **(2) Der Abbruch behauptet nur, was der Treiber gemessen hat: dass dieser Modus rot war —
      nicht, dass der Baum es ist.** Heute schließt der Satz *„Erst den Baum gruen bekommen"* eine
      Ursache aus, die der Treiber nicht ausschließen kann; im Referenz-Lauf fuhr derselbe Commit im
      Nachbar-Job grün durch denselben Sensor (§1, Punkt 3). Das ist
      [`AGENTS.md`](../../../../AGENTS.md) §3.7 auf eine Laufzeit-Meldung angewandt: sie beschreibt
      einen Zustand, den die Stelle nicht kennt.
      **Kein Kommando färbt diesen Punkt rot, und das ist keine Vertagung, sondern der Befund.**
      `make comment-claims` prüft, ob ein **genannter Sensor existiert**, nicht worüber ein Satz
      spricht — `harness/tools/*.sh` liegt im Prüfbereich, aber der Gate stellt eine andere Frage
      ([`AGENTS.md`](../../../../AGENTS.md) §4, Prüfbereich-Zeile). Ein bats-Fall über den Wortlaut
      wäre die erste Falsch-Klasse aus §3.6: er prüfte die heutige Formulierung statt der
      Eigenschaft und könnte unter keiner sinnvollen Mutation rot werden. Diese Hälfte trägt das
      Review, nicht ein Gate.
- [ ] **(3) Das Protokoll des Vorlaufs liegt außerhalb des Repos.** Der Treiber sagt in seiner
      ersten Ausgabezeile zu, den Host-Baum nicht anzufassen; sein eigener Beleg dafür — der
      Fingerabdruck aus Bedingung 5 — deckt **nur** die Mutations-Zieldateien
      (`grep -c 'target_fingerprint' harness/tools/mutate.sh` → **4**), eine neue Datei im
      Arbeitsbaum liefe daran vorbei. Sie wäre nicht harmlos: `harness/tools/working-tree-hash.sh`
      zählt untrackte Dateien mit (`grep -c 'exclude-standard' harness/tools/working-tree-hash.sh`
      → **2**), ein Log im Repo verschöbe also mitten im Lauf den Nachweis-Stempel aus
      [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung).
      **Rot:** ein Fall in [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats), der den
      Log-Pfad gegen `$REPO` hält — dieselbe Bauart wie die bestehenden Fälle über die Lage
      relativ zum Repo (`grep '^@test' test/mutate-driver.bats | grep -ci 'repo'` → **3** von
      `grep -c '^@test' test/mutate-driver.bats` → **18**). Rot gesehen, indem das Log probeweise
      unter `$REPO` angelegt wird.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | die Vorlauf-Schleife aus `main` in eine Funktion herausheben (dieselbe Kapselung, die `main` schon trägt, damit bats sourcen kann); den Sensor-Lauf in ein `mktemp`-Log schreiben statt nach `/dev/null`; `show_tail` aus `run_case` herausheben und im Abbruch-Zweig aufrufen; den Abbruch-Satz auf das einschränken, was gemessen ist (DoD 1–3) |
| [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) | update | der Fall aus DoD 1 mit `make`-Stub und zwei Strom-Markern, der Fall aus DoD 3 über den Log-Pfad. Beide sourcen den Treiber wie die 18 bestehenden Fälle |
| `test/mutations/` | **unverändert** | dieser Slice fügt keinen Mutations-Fall hinzu. Der Wächter aus DoD 1 lebt in `make test-bats`, und `narrow_sensor` wählt dafür die schmalste Stufe — ein eigener Mutations-Fall wäre der Zahn **über** dem Zahn und gehört, wenn überhaupt, in einen eigenen Schnitt |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | **unverändert** | die vier Jobs laufen auf vier Runnern (§1, Punkt 1); es gibt nichts zu sequenzieren. Ein Satz *„hier steht kein `needs:`, weil …"* wäre Konjunktiv über die verworfene Alternative und damit genau das, was [`AGENTS.md`](../../../../AGENTS.md) §3.7 als erste Falsch-Klasse führt — die Abwägung steht in §1 dieses Plans, nicht im Workflow |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | **unverändert** | der Sensor ist nicht der Gegenstand. Er wird für DoD 1 Rot C **nicht** angefasst; rot gemacht wird der billigste Modus der Schleife |
| [`harness/README.md`](../../../../harness/README.md), [`AGENTS.md`](../../../../AGENTS.md) | **unverändert** | beide beschreiben `make mutate` als Nicht-Gate-Verify; sein Vertrag ändert sich nicht. Was sich ändert, ist die Auskunft im Fehlerfall — kein öffentlicher Vertrag |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |
| [`docs/plan/planning/welle-12-erfassungsschicht-emittieren.md`](../welle-12-erfassungsschicht-emittieren.md) | **unverändert** | anderer Gegenstand; dieser Slice hängt an keiner Welle |

**Die Menge der Zeilen, an denen der Grund verschwindet, ist gemessen und klein.**
`grep -c '>/dev/null 2>&1' harness/tools/mutate.sh` → **2**. Die zweite ist **nicht** dieselbe
Klasse und wird **nicht** mitgezogen: sie steht im Bestands-Pfad und unterdrückt eine erwartete,
bedeutungslose Ausgabe — die Melde-Zeile eines `sha256sum -c`, das als Bedingung dient und dessen
Ergebnis der Exit-Code trägt. Welche der beiden gemeint ist, entscheidet der
Implementer an der Zeile, die im Abbruch-Zweig steht
(`grep -n 'make "\$m"' harness/tools/mutate.sh` → **1** Treffer) — nicht am Zähler.

**Das Log gehört in dasselbe `mktemp`-Muster, das der Fall-Pfad schon benutzt.** `run_case`
schreibt sein Sensor-Log nach `$BACKUP/verify.log` unter einem `mktemp -d`
(`grep -c 'mktemp -d' harness/tools/mutate.sh` → **2**); der Vorlauf bekommt keinen neuen
Mechanismus, sondern denselben. DoD 3 macht daraus eine Zusage, weil ein neuer Datei-Schreibvorgang
in einem Skript, dessen erste Ausgabezeile Nicht-Einmischung zusagt, genau die Stelle ist, an der
diese Zusage still bricht.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): sofort möglich, nichts blockiert ihn.** Der Gegenstand
liegt vollständig in diesem Repo — eine Schleife in
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) und ihr Wächter in
[`test/mutate-driver.bats`](../../../../test/mutate-driver.bats). Er berührt die emittierte Ebene
nicht, hängt an keiner Welle und wartet insbesondere **nicht** auf
[welle-12](../welle-12-erfassungsschicht-emittieren.md), deren Trigger auf der Erfassungsschicht
steht. Er wartet auch **nicht** auf den nächsten roten CI-Lauf: die Auskunft, die er herstellt, ist
unabhängig davon, wann sie das nächste Mal gebraucht wird.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn sich die Vorlauf-Schleife nicht herauslösen lässt,
  ohne die Reihenfolge von Lock, Fingerabdruck und Isolation in `main` umzustellen. Dann sind es
  zwei Slices — einer, der `main` entflicht, und dieser. Die Probe steht vor dem ersten Edit: die
  herausgelöste Funktion muss ohne Zustand außer `$WORK` und der Modus-Liste auskommen.
- **`in-progress` → `open` (blockiert):** wenn sich Rot C aus DoD 1 nicht herstellen lässt, weil
  kein Modus der Schleife lokal reproduzierbar rot zu bekommen ist, ohne den Baum in einen Zustand
  zu bringen, aus dem ihn `git restore` nicht zurückholt. Dann ist der Blocker die Gegenprobe, und
  sie gehört als Carveout nach Modul 7 dokumentiert — mit dem Rot-Lauf als Auflösungs-Trigger, denn
  ohne ihn ist DoD 1 nur zur Hälfte belegt.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt, jeder mit gefahrenem Kommando; die **drei** Rot-Läufe aus DoD 1 (`stdout`,
`stderr`, echter Pfad) mit ihrer Ausgabe in der Verify-Notiz, nicht nur ihr Ergebnis; `make gates`
grün; `make mutate` grün einschließlich der neuen bats-Fälle; Closure-Notiz mit
Steering-Loop-Lerneintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: ein grüner CI-Lauf als Beleg.** Was der Slice
liefert, zeigt sich erst an einem Lauf, der **abbricht** — und den kann niemand auf Zuruf
herstellen. Ein grüner CI-Lauf belegt hier nichts (er durchläuft den Abbruch-Zweig gar nicht), und
ihn als Kriterium zu führen hieße, eine Zusage mit einer Beobachtung zu decken, die zu ihr keine
Beziehung hat.

## 6. Risiken und offene Punkte

- **Die eigentliche Zusage ist eine CI-Eigenschaft und lokal nicht messbar — das ist kein Mangel
  der DoD, sondern ihre Grenze.** *„Ein roter `mutate`-Job ist ohne einen zweiten Lauf
  klassifizierbar"* spricht über einen Lauf auf fremder Hardware, in fremdem Netz, mit fremdem
  Docker-Zustand. Die drei Rot-Läufe aus DoD 1 belegen den **Mechanismus** — dass der Abbruch-Zweig
  die Sensor-Ausgabe trägt —, und das ist alles, was ein lokales Kommando erreichen kann. Ob die
  zwölf Zeilen im konkreten CI-Fall **ausreichen**, um die Ursache zu benennen, entscheidet erst
  der nächste Abbruch dort. Wer das lokale Grün als Beleg für die CI-Eigenschaft ausgäbe, beginge
  die zweite Falsch-Klasse aus [`AGENTS.md`](../../../../AGENTS.md) §3.6 — benennen, was wirklich
  deckt, oder dass nichts deckt.
- **Zwölf Zeilen können zu wenig sein.** `show_tail` zeigt `tail -n 12`
  (`grep -c 'tail -n 12' harness/tools/mutate.sh` → **1**), und ein grüner `make full-smoke` druckt
  über diesem Baum **2883** Zeilen (§1). Bei `full-smoke` steht die tragende Zeile am Ende — das
  Skript beendet nach jedem `full-smoke: FEHLER` sofort
  (`grep -c '^[[:space:]]*exit 1' harness/tools/full-smoke.sh` → **73**, gleich viele wie
  Fehlschlag-Zeilen) —, bei einem Docker-Abbruch mitten im Build muss das nicht gelten. Die Zahl
  wird hier **nicht** vorab erhöht: sie ist heute im Fall-Pfad erprobt, und eine Änderung ohne
  gemessenen Anlass wäre eine Vermutung. Der Anlass wäre ein Abbruch, dessen Tail die Ursache
  abschneidet — dann steht die Zahl zur Debatte, mit dem Protokoll als Beleg.
- **Der eine gemessene Fehlschlag bleibt unerklärt, und dieser Slice erklärt ihn auch nicht.** Er
  stellt her, dass der **nächste** erklärbar ist. Das ist bewusst: nach §1 Punkt 1–3 scheidet der
  **Inhalt** des Baums aus, offen bleiben Pfad und Umgebung, und jede Gegenmaßnahme, die vor dieser
  Antwort gewählt wird, ist eine Wette. **Folge-Slice mit beobachtbarem Trigger:** sobald ein
  `mutate`-Job erneut im Grün-Vorlauf abbricht und sein Protokoll die Ursache nennt, wird über die
  Gegenmaßnahme
  entschieden — `needs:`, größerer Runner, ein Retry, oder nichts. Bis dahin gibt es keinen
  Kandidaten, nur Verdächtige.
- **Die Häufigkeit kann steigen, ohne dass es jemand merkt.** Gezählt über *CI-Läufe seit
  `569eec7`, deren `mutate`-Job ein Verdikt erreicht hat*, steht es bei **1** rot von **8** (§1,
  Punkt 2, mit Kommando). Es gibt **keinen** Sensor, der diese Quote beobachtet; sie entsteht nur,
  wenn jemand das Kommando fährt. Das ist hier benannt, nicht geschlossen — ein Quoten-Wächter wäre
  ein eigener Gegenstand mit eigener Abwägung (er müsste Netz sprechen und gehörte damit zu den
  nächtlichen Sensoren, nicht in `make gates`).
- **Die Herauslösung der Schleife aus `main` kann Zustand mitnehmen, den `main` heute implizit
  hält.** `main` setzt vor der Schleife `LOCK`, `HOST_BEFORE`, `ISO_ROOT` und `WORK`; die Funktion
  darf davon nur `$WORK` und die Modus-Liste brauchen, sonst ist sie in bats nicht ohne echten Lauf
  aufrufbar — und genau das war der Grund, aus dem `main` überhaupt gekapselt wurde
  (`grep -c 'Hauptteil gekapselt' harness/tools/mutate.sh` → **1**). Fällt die Probe, greift die
  Rückführung aus §4.
- **`make comment-claims` wird den neuen Code nicht prüfen, wenn er untrackt bleibt.** Der
  Prüfbereich ist `git ls-files` ohne `--others` — eine neu angelegte Datei liegt außerhalb, bis
  sie `git add` gesehen hat ([`harness/README.md`](../../../../harness/README.md), Abschnitt zu den
  drei Achsen). Dieser Slice legt zwar keine neue Datei an, aber der Gate-Lauf gehört trotzdem
  **nach** das `git add`, sonst behauptet die Zeile *„N Datei(en) geprueft"* mehr, als sie trägt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

### Sub-Area: Mutations-Sensor (Treiber + seine bats-Wächter)

Eine Sub-Area, kein zweiter Block: berührt sind
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) und
[`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) — Werkzeug und sein eigener
Wächter, dieselbe Sub-Area über beide Achsen.

- **Modus:** GF. Der Treiber ist in diesem Repo entstanden (slice-026), und sein Vertrag stand in
  [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md), bevor die erste Zeile Code lief. Es gibt
  keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre — Doc führt, Code folgt.
- **Konventionen-Dichte:** hoch. Der Gegenstand ist über vier Setzungen verankert: die
  Nicht-Gate-Verify-Einordnung ([`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md)), die Zusagen-Regel
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6), die Kommentar-Regel
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7) und der Nachweis-Stempel aus
  [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  an dem DoD 3 hängt. Die letzten beiden tragen die zwei Punkte, die dieser Slice überhaupt
  unterscheidbar machen.
- **Phase-Reife:** Phase 4 (Qualität). Der Sensor läuft, hat 18 eigene bats-Fälle
  (`grep -c '^@test' test/mutate-driver.bats` → **18**) und einen mechanischen Pro-Push-Auslöser
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)). Was
  fehlt, ist nicht Reife, sondern Auskunft im Fehlerfall.
- **Evidenz-/Diskrepanz-Risiko:** niedrig, und das ist gemessen statt angenommen — der Treiber
  belegt seine eigene Hauptzusage im Lauf (Fingerabdruck vor, während und nach jedem Fall) und
  seine Funktionen sind einzeln sourcebar. Das Restrisiko liegt an genau einer Stelle: `main` hält
  Zustand, den die herauszulösende Schleife nicht erben darf — §4 nennt dafür die Probe und die
  Rückführung.
- **Reconciliation-Aufwand:** keiner. Es gibt keine Doku-Aussage über die **Auskunft** des
  Vorlaufs, die mit dem Code auseinanderläuft: der Kopf von `harness/tools/mutate.sh` führt fünf
  nummerierte Fail-closed-Bedingungen
  (`sed -n '1,80p' harness/tools/mutate.sh | grep -cE '^#   [0-9]\. '` → **5**), und der
  Grün-Vorlauf ist keine davon. Er kommt an vier Stellen vor
  (`grep -c 'Gruen-Vorlauf' harness/tools/mutate.sh` → **4**): dreimal als Kommentar über seine
  Existenz und seinen Preis, einmal als die Fortschritts-Zeile, die der Lauf druckt — keine davon
  sagt etwas darüber zu, was der Abbruch zeigt. Graduation-Trigger entfällt; die Sub-Area ist
  bereits GF.

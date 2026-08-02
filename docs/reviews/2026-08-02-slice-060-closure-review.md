# Code-Review (Modul 10) — slice-060, die drei Commits vor der Closure (`8864708` · `b00cb6d` · `f89cba3`)

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10) — frischer Kontext, weder Autor des Codes noch eines Vorgänger-Reports |
| **Datum** | 2026-08-02 |
| **Prüfstand** | `main` @ `f89cba3`, Arbeitsbaum sauber, drei ungepushte Commits |
| **Prüfgegenstand** | `8864708` (`harness/conventions.md` `MR-018`, `docs/plan/planning/open/slice-074-…`) · `b00cb6d` (`.claude/hooks/pretooluse-agent-guard.sh`, Kopfkommentar) · `f89cba3` (`docs/plan/planning/in-progress/slice-060-rollen-achse.md`) |
| **Slice-Plan** | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` — DoD (1), §3-Dateitabelle, §6 |
| **`LH-*`** | `LH-QA-03` (reines bash + awk im Guard-Pfad) · `LH-QA-01` (kein Gate über leerem Prüfbereich) |
| **ADRs** | `ADR-0014` (Accepted) · `ADR-0011` (Accepted) · `ADR-0004` (Guard ist Stolperdraht) · `ADR-0003` (Docker-only) · `ADR-0012` (Proposed, nur berührt) |
| **Hard Rules** | `AGENTS.md` §3.1 · §3.2 · §3.3 · §3.4 · §3.5 · §3.6 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-31-slice-060-verify-fixes-review.md` (MEDIUM-1/2, LOW-1…5, INFO-1; Verdikt *nicht konform*) · `docs/reviews/2026-08-01-slice-060-verify.md` (V-1 LOW, V-2/V-3 INFO) — gelesen, nichts daraus übernommen |
| **Nicht Gegenstand** | die DoD-Abhakung (Verifikation, getrennter Kontext) |
| **Gefahrene Sensoren** | `make gates` voll (Exit 0, eigener Lauf) · drei **eigene** Mutations-Sonden gegen den Guard über den `run_case`-Pfad des gesourcten `harness/tools/mutate.sh` · die Bestands-Fälle 119 und 139 über denselben Pfad · `comment-claims.sh` gegen fünf konstruierte Varianten des Kopf-Blocks · der Guard direkt gegen fünf beschnittene `PATH`-Umgebungen und zwei gefälschte Extraktoren · Auszählung der `settings.json`-Prüfstellen über den im Text deklarierten Umfang · Anlege-Commit je Mutations-Fall 117–139 |
| **Nicht gefahren** | `make mutate` als Vollauf (Nutzer-Ausschluss) · `make smoke`/`make full-smoke` |

---

## Findings

Blockierende zuerst, einzeln.

### MEDIUM-1 — `8864708` ändert den Rumpf eines akzeptierten Adaptions-Eintrags, und keine Regel des Repos deckt diesen Vorgang

- **kategorie:** MEDIUM
- **quelle:** `ADR-0014` (Accepted) · [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) · [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage)/[`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
- **pfad:** `harness/conventions.md:1233-1264` (Commit `8864708`)
- **befund:** Der Commit schreibt **innerhalb** von `MR-018` um — die Zählgröße (*vier Artefakte* → *fünf Prüfstellen*), den Zählsatz und die fünf Zeilen der Sonden-Passage, die durch einen Zeiger auf slice-074 ersetzt werden. `MR-018` ist committet und damit *akzeptiert* nach der Festlegung, die [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) trägt (*„akzeptiert heißt committet"*); die adoptierte Vorlagen-Disziplin lässt *„nur neue Einträge oder explizite Aufhebungen via neuen MR"* zu, und die **eine** Abweichung, die `ADR-0014` davon nimmt, betrifft das Entfernen des Rumpfs eines **vollständig aufgehobenen** Eintrags. Gemessen: bei `8864708^` steht `ADR-0014` auf `**Status:** Accepted` und `MR-020` liegt im Adaptions-Block; `docs/plan/planning/next/slice-076-mr-018-umzug-technik-stratum.md:137-152` benennt für genau diesen Eintrag den vorgesehenen Weg (*„ein neuer Eintrag hebt `MR-018` vollständig auf"*). Die beiden Lesarten von `ADR-0014` Festlegung 1 zeigen dabei in verschiedene Richtungen — *„Append-only gilt dem Eintrag, nicht seinem Rumpf"* liest sich als Freigabe des Rumpfs, ihr Kontext (*„Erhalten bleiben die Nummer … Den Rumpf trägt `git`"*) als Regel für den Vollzug einer Aufhebung —, und kein Eintrag, keine ADR und kein Slice sagt, welche gilt. **Was dadurch bricht:** `ADR-0014` Bedingung 2 (b) verlangt beim Aufheben, dass *„jede bindende Aussage des Rumpfs an einem bindenden Ort steht"*; wer den Rumpf still korrigieren darf, kann am Artefakt nicht mehr unterscheiden, welche Aussage die ursprüngliche und welche die nachgezogene ist — der Leser von `MR-018` sieht heute *fünf*, ohne dass am Ort des Lesens steht, dass dort *vier* stand und die Zahl falsch war.
- **verifizierbar:** nein — kein Gate dieses Repos liest Diffs; `ADR-0014` §*Was hier bewusst NICHT steht* spricht genau das aus (*„sein Gegenbeispiel wäre ein Diff, und kein Gate dieses Repos liest Diffs"*). Am Artefakt nachprüfbar: `git show 8864708^:docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md | grep '^\*\*Status'` → `Accepted`; `git show 8864708^:harness/conventions.md | grep -c '^### MR-020'` → `1`.

### MEDIUM-2 — „Zähne haben" bezeichnet im Guard-Kopf und im Plan verschiedene Mengen, zwei Commits auseinander

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:15-16` gegen `docs/plan/planning/in-progress/slice-060-rollen-achse.md:287-289`
- **befund:** Der Kopf (`b00cb6d`) sagt *„Zaehne haben die letzten drei (test/agent-guard.bats)"* — also Parse-Zweifel, fehlender Typ, fehlender Schalter. Der Plan (`f89cba3`) sagt im selben Slice *„Zähne haben **fehlender Typ** und **fehlender Schalter**; der **Parse-Zweifel** hat einen bats-Fall, aber keinen Dauer-Sensor"* — zwei statt drei. `AGENTS.md` §3.6 definiert das Wort in der Gegenrichtung: *„gelistet heißt: wer keinen Fall in `test/mutations/` hat, ist unbewacht"*; gemessen führen genau vier Fälle den Guard als Ziel (117 · 118 · 119 · 139, über den Inhalt geprüft, nicht über den Namen), und keiner davon adressiert den Parse-Zweifel-Zweig. Der Kopf ist in seiner engen Lesart wahr — meine Sonde `x3-parse-zweig-failopen` färbt `guard: kaputte Eingabe -> DENY (fail-closed)` rot —, aber er trägt dieselbe Bezeichnung für einen Zweig, den `make mutate` bauartbedingt nicht überwachen kann, und weist nur awk und Extraktor als `UNBEWACHT` aus. **Failure-Szenario:** verliert der bats-Fall zum Parse-Zweifel seine Zähne oder verschwindet er, meldet `make mutate` nichts — es gibt keinen Fall, der ihn führt —, während der Kopf, den die Closure einfriert, dem nächsten Leser sagt, der Zweig habe Zähne.
- **verifizierbar:** ja, teilweise — `grep -l pretooluse-agent-guard test/mutations/*.sh` → 4 Dateien, keine mit `# expect: guard: kaputte Eingabe …`; die Zahn-Aussage selbst über den `run_case`-Pfad (Ausgaben unten in §Sensor-Protokoll).

### LOW-1 — Die Groß-Schreibung von `UNBEWACHT` ist für `comment-claims` folgenlos; die dafür genannte Begründung beschreibt das Verhalten des Gates nicht

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (eine Aussage über einen Sensor, ohne ihn gefahren zu haben)
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:16`; `harness/tools/comment-claims.sh:31-35`
- **befund:** Die Begründung für die Versalien lautet, kleingeschrieben enthielte `unbewacht` das Claim-Verb `bewacht` und `comment-claims` läse es als Zusage, die die Nennung von `test/agent-guard.bats` im selben Block stillschweigend erfüllt. Gemessen an fünf konstruierten Varianten trifft das für den Satz **wie er dasteht** nicht zu: die kleingeschriebene Fassung *„unbewacht, nicht unbewachbar"* fällt unter die Verneinungs-Ausnahme `comment-claims.sh:35` (`(…|bewacht|…)[^.]{0,12}(nicht|kein|nie)`) und wird gar nicht erst als Behauptung gezählt — Variante B meldet `0 Befund(e)`. Zusätzlich steht `test/agent-guard.bats` **auf derselben Zeile**, `block_sensor` ist also unabhängig von der Schreibweise gesetzt. Der Gate schweigt heute tatsächlich (Variante A und der reale Baum: `comment-claims: 38 Datei(en) geprueft, 0 Befund(e)`), aber nicht aus dem angegebenen Grund. **Failure-Szenario:** wer die Versalien als gate-wirksames Mittel übernimmt, setzt sie an einer Stelle ein, an der weder die Verneinungs-Ausnahme noch eine Sensor-Nennung greift, und hält eine Behauptung für stillgestellt, die der Gate röten würde.
- **verifizierbar:** ja — `bash harness/tools/comment-claims.sh <Variante>` über die fünf Varianten; Ausgaben unten in §Sensor-Protokoll.

### LOW-2 — Der gesamte 34-zeilige Kopf-Block des Guards liegt außerhalb der Reichweite von `comment-claims`

- **kategorie:** LOW
- **quelle:** Maintainability; `AGENTS.md` §4 (`comment-claims`-Prüfbereich)
- **pfad:** `.claude/hooks/pretooluse-agent-guard.sh:2-35`
- **befund:** `comment-claims.sh` prüft den Kommentar-**Block**, und ein Block endet an der ersten Nicht-Kommentar-Zeile — hier erst bei `set -euo pipefail` (`:36`). Der Block trägt `test/agent-guard.bats` an `:16`, `:21` und `:22`; damit ist `block_sensor` für alle 34 Zeilen gesetzt, und jede Behauptung an beliebiger Stelle des Kopfes gilt als belegt. Nachgestellt: eine Behauptung in einem Block **ohne** Sensor-Nennung feuert (Variante E, Exit 1), dieselbe Behauptung mit Nennung nicht (Variante D, Exit 0). **Failure-Szenario:** das ist der Mechanismus, unter dem die zuvor beanstandete Fassung *„JEDER unlesbare Eingang endet fail-closed"* den Gate über den ganzen Slice hinweg passierte; die nächste zu weite Zusage im selben Block passiert ihn ebenso.
- **verifizierbar:** ja — `bash harness/tools/comment-claims.sh` gegen die Varianten D und E; der Gate-Lauf selbst bleibt in beiden Fällen ohne Aussage über den Kopf.

### LOW-3 — Zwei Passagen über die Entstehung des eigenen Textes bleiben im Plan stehen, den die Closure einfriert

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §5 (Artefakt beschreibt die Sache)
- **pfad:** `docs/plan/planning/in-progress/slice-060-rollen-achse.md:19` und `:270`
- **befund:** `f89cba3` räumt Befund-IDs und Runden-Verweise aus den berührten Absätzen (gemessen: `grep -cE '(Review|Verifier)-Befund'` 7 → 0 über die ganze Datei, 0 Treffer in den hinzugefügten Zeilen). In zwei nicht berührten Absätzen steht dieselbe Klasse weiter: `:19` *„Eine frühere Fassung schrieb hier ‚Festlegung 2 … wird erweitert'"* und `:270` *„Eine frühere Fassung dieses Punktes behauptete, die Bedingung habe *keinen* Sensor"*. **Failure-Szenario:** der Plan geht mit dem `git mv` nach `done/` und trägt dann dauerhaft zwei Sätze, deren Gegenstand nicht die Sache, sondern ein früherer Zustand desselben Dokuments ist.
- **verifizierbar:** nein — Prosa, außerhalb jedes Gates; ablesbar über `grep -nE '[Ff]rühere Fassung'`.

### LOW-4 — `8864708` erzeugt in slice-074 einen doppeldeutigen Rückbezug

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `docs/plan/planning/open/slice-074-agent-vor-aufruf-protokoll.md:301`
- **befund:** Dieselbe Tabellenzelle beginnt mit *„ein neuer **Eintrag** im Adaptions-Block"* und endet mit *„dort steht **dieser Eintrag** als *nicht gebaut*"*. Gemeint ist der `PreToolUse`-Eintrag in `.claude/settings.json`, den `MR-018` (c) als *„geschnitten als slice-074, gebaut ist er nicht"* führt — nicht der Adaptions-Block-Eintrag, von dem die Zelle zuvor spricht. Die ersetzte Fassung (*„dort steht die Sonde als *nicht gefahren*"*) trug das Missverständnis nicht. **Failure-Szenario:** wer die Zeile liest, entnimmt ihr, `MR-018` erkläre den geplanten Konventions-Eintrag für ungebaut — eine Aussage, die dort nicht steht.
- **verifizierbar:** nein — Prosa in einem `open/`-Plan, außerhalb jedes Gates.

### INFO-1 — Die Zahl „19 Fundstellen" in `f89cba3` ist unter keinem angegebenen Muster reproduzierbar

- **kategorie:** INFO
- **quelle:** `AGENTS.md` §3.6 (die Commit-Message ist eine Zusage)
- **pfad:** Commit-Message `f89cba3`
- **befund:** Die Message sagt *„aus den beruehrten Absaetzen sind Befund-IDs und Runden-Verweise raus (19 Fundstellen -> 0)"*, nennt aber kein Messmuster. Über die 31 entfernten Zeilen gezählt: **8** Zeilen tragen mindestens einen Marker, **23** Vorkommen sind Befund-IDs/Runden-Verweise, **28** mit Datums-Stempeln. Der Endpunkt *→ 0* ist bestätigt (0 Treffer in den hinzugefügten Zeilen, 0 `(Review|Verifier)-Befund` in der Datei); nur die 19 ist es nicht. Das ist die Klasse, die der vorherige Report als wiederkehrend protokolliert hat (*„Zahl behauptet statt abgezählt"*).
- **verifizierbar:** nein — kein Gate liest Commit-Messages; nachzählbar über `git show f89cba3 -- <Plan> | grep '^-'`.

### INFO-2 — „Prüfstelle" ist im Text nicht definiert; die Fünf hält unter genau einer Granularität

- **kategorie:** INFO
- **quelle:** [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
- **pfad:** `harness/conventions.md:1236-1247`
- **befund:** Über den im Text selbst deklarierten Umfang (`test/**`, `Makefile`, `harness/tools/*.sh`, die Go-Tests) habe ich **fünf** unterscheidbare Zusicherungen über `.claude/settings.json` in **drei** Dateien gezählt — die Zahl im Text stimmt (Auszählung unten). Sie hält aber nur unter der Regel *„eine Prüfstelle = eine eigenständige Zusicherung über `settings.json`"*, und die steht nicht da: `TestEnforce_EmitsAllMechanicFiles` trägt **zwei** Mechanismen, die den Pfad berühren (die `os.Stat`-Schleife über `EnforcePaths()` und die `want`-Enthaltensein-Schleife, `internal/emit/enforce_test.go:24-46`), und wird als **eine** gezählt, während in `harness/tools/smoke.sh` zwei `if`-Blöcke als **zwei** zählen. Unter der Granularität von `smoke.sh` wären es sechs, unter der von *„eine benannte Einheit"* vier — die frühere Zahl.
- **verifizierbar:** nein — `comment-claims` deckt kein Markdown, `d-check` prüft keine Sätze; nachzählbar allein über den deklarierten Umfang.

---

## Negativbefunde (geprüft, ohne Befund)

1. **Der Zweig-Bestand des Guard-Kopfes stimmt.** `grep -n emit_deny` → fünf Aufrufstellen (`:67`, `:69`, `:76`, `:89`, `:101`) plus die Funktionsdefinition; `emit_deny` ist der einzige Deny-Mechanismus. *„Fail-closed antworten FUENF Zweige"* ist abgezählt richtig. Kein Befund.
2. **Die Reihenfolge-Aussage stimmt.** awk (`:66`), Extraktor (`:68`), Parse-Zweifel (`:75`) und fehlender Typ (`:89`) liegen alle **vor** der Rollen-Frage (`:94`); nur der Schalter (`:99`/`:101`) liegt dahinter. *„bei JEDEM Aufruf"* gegen *„NUR bei Rollen-Typen"* trifft den Code. Kein Befund.
3. **`UNBEWACHT` für awk und Extraktor ist gemessen, nicht geschlossen.** Beide Zweige über den `run_case`-Pfad fail-open gemacht: `make test-bats` bleibt grün, kein Sensor färbt sich. Die Gegenprobe am selben Lauf (Parse-Zweifel fail-open) wird rot. Kein Befund — die Aussage ist so breit wie ihr Prüfbereich.
4. **„nicht unbewachbar" trägt.** Beide Denies sind erreichbar und beobachtbar: `PATH` ohne `awk` liefert `permissionDecisionReason: "Agent-Guard: awk fehlt …"`, ein Guard ohne erreichbaren Nachbarbaum liefert `"Agent-Guard: Extraktor fehlt …"`. Kein Befund.
5. **Die zwei fail-open-Pfade und der fail-closed-Pfad aus Plan §6 sind bestätigt.** Ohne `cat` → `rc=127`, stdout **0 Byte**; ohne `sed` → `rc=127`, stdout **0 Byte**; Extraktor mit `rc=0` und leerem *oder* falschem Inhalt → `rc=0`, **keine Ausgabe**, also PASS; ohne `dirname` → `rc=0` **mit** Deny-JSON, also fail-closed. Kein Befund.
6. **Die Exit-Code-Prämisse stimmt gegen die vendored Referenz.** `docs/user/claude-hooks-referenz.md:686` (*„Jeder andere Exit-Code ist ein nicht-blockierender Fehler"*) und `:704` (*„Für die meisten Hook-Ereignisse blockiert nur Exit-Code 2 … Die Ausnahme ist `WorktreeCreate`"*) tragen den Satz in Plan §6. Kein Befund.
7. **Die Fall-Spanne 117–139 ist am Bestand lückenlos, nicht am Dateinamen.** Alle 23 Dateien existieren, keine Lücke; je Datei der Anlege-Commit (`git log --diff-filter=A`) ist ein slice-060-Commit; kein slice-060-Commit legt einen Mutations-Fall außerhalb 117–139 an; 115 und 116 stammen aus slice-059, 115 wurde von slice-060 nur geändert. Kein Befund.
8. **Die tragende Aussage von Prüfschritt 3 (b) hält.** Alle fünf Prüfstellen gelten dem **emittierten** Ziel (`$tmprepo`, `emit.EnforceFile(…)`, `internal/emit/templates/enforce/settings.json`). Die Gegenprobe über das ganze Repo fördert außer ihnen nur `internal/emit/enforce.go` (Produktionscode) und den Kommentar im Agent-Guard zutage; `test/agent-guard.bats:28` ruft den Guard **direkt über seinen Pfad** auf, nie über `.claude/settings.json`. *„Kein Sensor dieses Repos prüft, dass er verdrahtet ist"* ist damit auch über den deklarierten Umfang hinaus richtig. Kein Befund.
9. **Die Zitat-Nachzüge in slice-074 sind wortgetreu.** Beide Fragmente des Zitats stehen nach Zeilenumbruch-Normalisierung verbatim in `MR-018`; der ersetzte Wortlaut (*„eine Sonde auf die Schlüsselnamen"*) kommt außerhalb von `docs/reviews/` nicht mehr vor. Kein Befund (die Doppeldeutigkeit der zweiten Stelle ist LOW-4, nicht die Zitat-Treue).
10. **`AGENTS.md` §3.1.** Kein neuer Gate-Name, kein neues Target in den drei Commits. Kein Befund.
11. **`AGENTS.md` §3.2.** Kein `//nolint`, kein `# shellcheck disable` im Diff; `shell-lint` im eigenen `make gates`-Lauf grün. Kein Befund.
12. **`AGENTS.md` §3.3.** Kein Rename in den drei Commits. Kein Befund.
13. **`AGENTS.md` §3.4.** Keiner der drei Commits berührt `docs/plan/adr/` (je 0 Dateien). `ADR-0011` und `ADR-0014` sind unangetastet. Kein Befund.
14. **`AGENTS.md` §3.5.** Keine Schwellen-Senkung; `b00cb6d` und `f89cba3` **verengen** Zusagen, `8864708` korrigiert eine Zahl nach oben. Kein Befund.
15. **`LH-QA-03` / `ADR-0004`.** Der Guard bleibt reines bash + awk; kein `node`/`jq`/`python` kommt hinzu. Die zwei fail-open-Pfade widersprechen `ADR-0004` nicht — der Guard ist dort ausdrücklich *„ein Stolperdraht, keine Sandbox"*, und sein Zweck ist nach seinem eigenen Kopf Telemetrie, nicht Sicherheit. Kein Befund.
16. **Die Größen- und Form-Angaben der drei Commits stimmen.** `8864708` 19+/19− (Datei-Zeilenzahl unverändert); `b00cb6d` 4+/4− bei unverändert sechs Zeilen des betroffenen Absatzes; `f89cba3` 353 → 362 Zeilen = +9. Der neue §6-Punkt ist **neuer Gegenstand** (die Grenzen des Guards standen im Plan nirgends), kein Absatz an der Stelle eines ersetzten Satzes; die drei Stellen mit entfernten Befund-IDs sind **ersetzt**, nicht ergänzt. Kein Befund.
17. **Der Host-Baum blieb unberührt.** `sha256sum .claude/hooks/pretooluse-agent-guard.sh` vor und nach allen fünf Mutationsläufen identisch (`e908edb0…41dd87`); mutiert wurde ausschließlich in der isolierten Kopie außerhalb des Repos. Kein Befund.
18. **`make gates` grün, eigener Lauf.** Exit 0. Kein Befund.

---

## Sensor-Protokoll — echte Ausgaben

### Drei eigene Mutations-Sonden über den `run_case`-Pfad

```
sonde: isolierte Kopie unter /tmp/tmp.JpZWapcdGY/repo
sonde: Gruen-Vorlauf make test-bats
sonde: Gruen-Vorlauf ok
mutate: BEFUND  x1-awk-zweig-failopen        make test-bats blieb GRUEN — 'guard: awk fehlt -> DENY (fail-closed)' hat keine Zaehne mehr
mutate: BEFUND  x2-extraktor-zweig-failopen  make test-bats blieb GRUEN — 'guard: Extraktor fehlt -> DENY (fail-closed)' hat keine Zaehne mehr
mutate: ok      x3-parse-zweig-failopen      -> guard: kaputte Eingabe -> DENY (fail-closed) rot
sonde: 1 ok, 2 Befund(e)
```

Die zwei „BEFUND"-Zeilen sind hier der **erwartete** Ausgang: sie sind der Beleg für `UNBEWACHT`.

### Die beiden Bestands-Fälle zu Typ und Schalter

```
mutate: ok      119-agentguard-schalter-failopen  -> guard: Rolle ohne Schalter -> DENY (Abwesenheit gilt als Hintergrund) rot
mutate: ok      139-agentguard-typ-failopen       -> guard: Agent-Aufruf ohne Subagent-Typ -> DENY (fail-closed) rot
sonde: 2 ok, 0 Befund(e)
```

### Der Guard gegen fünf beschnittene `PATH`-Umgebungen

```
voll (Kontrolle)   rc=0    Deny „Rollen-Agent 'reviewer' muss im VORDERGRUND starten …"
ohne cat           rc=127  stdout 0 Byte   (stderr: line 63: cat: command not found)
ohne sed           rc=127  stdout 0 Byte   (stderr: line 78: sed: command not found)
ohne dirname       rc=0    Deny „Agent-Guard: Extraktor fehlt …"
ohne awk           rc=0    Deny „Agent-Guard: awk fehlt, keine Pruefung moeglich (fail-closed)."
```

### Der Guard gegen zwei gefälschte Extraktoren (`rc=0`, falscher Inhalt)

```
Extraktor liefert rc=0 + 'false'/'reviewer' (Payload ist in Wahrheit Hintergrund)
  -> rc=0  Ausgabe-Bytes=0   (PASS)
Extraktor liefert rc=0 + LEER
  -> rc=0  Ausgabe-Bytes=0   (PASS)
```

### `comment-claims` gegen fünf Varianten des Kopf-Blocks

```
A  „… (test/agent-guard.bats); … sind UNBEWACHT, nicht unbewachbar."   0 Befund(e)  EXIT=0
B  „… (test/agent-guard.bats); … sind unbewacht, nicht unbewachbar."   0 Befund(e)  EXIT=0
C  „… sind unbewacht."                     (ohne Sensor-Nennung)       1 Befund     EXIT=1
D  „… (test/agent-guard.bats); … sind unbewacht."                      0 Befund(e)  EXIT=0
E  Behauptung „… das er bewacht."          (ohne Sensor-Nennung)       1 Befund     EXIT=1
```

Und gegen die reale Datei, ganz und kleingeschrieben:

```
v1-original              comment-claims: 1 Datei(en) geprueft, 0 Befund(e)
v2-klein                 comment-claims: 1 Datei(en) geprueft, 0 Befund(e)
v3-klein-ohne-negation   comment-claims: 1 Datei(en) geprueft, 0 Befund(e)
```

### Die fünf `settings.json`-Prüfstellen, über den im Text deklarierten Umfang

```
grep -rn 'settings\.json' test/                    -> 3 Zeilen, 1 Datei (test/mutations/32)
grep -n  'settings\.json' Makefile                 -> 0
grep -n  'settings\.json' harness/tools/*.sh       -> 4 Zeilen, 1 Datei (smoke.sh)
grep -rn 'settings\.json' --include='*_test.go' .  -> 5 Zeilen, 1 Datei (enforce_test.go)
```

| # | Prüfstelle | Datei | Art |
|---|---|---|---|
| 1 | Existenz-Schleife der Durchsetzungsschicht (`:75-82`) | `harness/tools/smoke.sh` | Vorhandensein |
| 2 | `PreToolUse`-Prüfung (`:85-88`) | `harness/tools/smoke.sh` | Verdrahtung |
| 3 | `TestEnforce_EmitsAllMechanicFiles` (`:19-57`) | `internal/emit/enforce_test.go` | Vorhandensein |
| 4 | `TestEnforce_SettingsWiresBothHooks` (`:88-96`) | `internal/emit/enforce_test.go` | Verdrahtung |
| 5 | `32-enforce-settings-wires-guard.sh` | `test/mutations/` | Dauer-Sensor zu 4 |

### Die Fall-Spanne 117–139 am Anlege-Commit

```
117-122  9e0632d  slice-060: die sechs Agent-Guard-Mutationen als staendige Faelle
123-127  4a9ed3c  slice-060 DoD (2): Agent namentlich gelistet, mit Positiv-Liste
128-129  b373d25  ·  130-131  467e467  ·  132-135  3e3079d
136-137  f2829ae  ·  138      a836c9b  ·  139      dcee2f3
fehlend im Bereich 117..139: (keine)          Dateien im Bereich: 23
```

### `make gates`, eigener Lauf auf `f89cba3`

```
baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 279 Datei(en) geprüft, 0 Befund(e)
1..150
comment-claims: 38 Datei(en) geprueft, 0 Befund(e)
span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert
EXIT=0
```

Keine `not ok`-Zeile im Lauf. Die Zahlen decken sich mit denen der Aufgabenstellung.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 4 |
| INFO | 2 |
| **Summe** | **8** |

**Wiederkehrende Klasse.** Der Report vom 2026-07-31 hat *„Aussage breiter als ihr Prüfbereich"*
viermal in einem Commit protokolliert, der genau diese Klasse auflösen sollte. Sie tritt hier
**nicht** mehr auf: die drei geprüften Zusagen — fünf Zweige, drei mit Zähnen, awk und Extraktor
unbewacht — sind alle drei gemessen und keine reicht über ihren Sensor hinaus. An ihre Stelle
tritt eine andere: **dasselbe Wort trägt in zwei Artefakten desselben Slice zwei Bedeutungen**
(MEDIUM-2), und **eine Begründung beschreibt einen Sensor, ohne ihn gefahren zu haben**
(LOW-1) — die Klasse ist von der Zusage in ihre Begründung gewandert. Das gehört in die
Closure-Notiz.

---

## Verdikt

**NICHT KONFORM.**

Zwei MEDIUM blockieren nach der Kategorien-Semantik des Reviewer-Skills, und beide sind mit dem
`git mv` nach `done/` eingefroren.

**Was der Sache nach trägt und was nicht.** Die drei Commits leisten, was sie zusagen: der
zurückgenommene Guard-Kopf ist zum ersten Mal in diesem Slice **genau so breit wie sein
Prüfbereich** — ich habe alle fünf Zweige einzeln gefahren, die zwei unbewachten über eigene
Mutationen als unbewacht bestätigt und die drei bewachten rot gesehen; die Fall-Spanne 117–139
ist am Bestand lückenlos, nicht am Dateinamen; die Prüfstellen-Zahl fünf stimmt über den
deklarierten Umfang; die zwei fail-open- und der eine fail-closed-Pfad, die der Kopf nicht
aufzählt, widersprechen ihm nicht, weil er *„nicht jeder Eingang"* ausdrücklich sagt. Blockierend
ist nicht die Sache, sondern zweierlei daneben: ein Eingriff in den Rumpf eines akzeptierten
Adaptions-Eintrags, für den das Repo seit zwei Commits eine Regel führt und keine Ausnahme
(MEDIUM-1), und ein Deckungsbegriff, der im Guard-Kopf drei und im Plan zwei Zweige meint, während
`AGENTS.md` §3.6 ihn über die Listung in `test/mutations/` definiert (MEDIUM-2).

**Ist der Slice aus Review-Sicht closure-reif? Nein — heute nicht.** Der Closure-Trigger §5
verlangt ein *ausgestelltes* Review-Verdikt; dieses hier lautet **nicht konform**. Die zwei
MEDIUM sind vor dem `git mv` zu klären — MEDIUM-1 durch eine Entscheidung darüber, welche Lesart
von `ADR-0014` Festlegung 1 gilt, MEDIUM-2 durch eine Angleichung der beiden Aussagen. Die vier
LOW und zwei INFO blockieren nicht.

**Nicht gegen den Implementer gewertet, aber Teil der Closure:** die sechs DoD-Kästchen stehen
unverändert auf `- [ ]` und `§7 Closure-Notiz` trägt nur den Platzhalter-Kommentar (gemessen:
6 × `- [ ]`, 0 × `- [x]`). Das ist Planner-Arbeit im Zug der Closure, kein Befund gegen diesen
Diff.

**Zwei Angaben der Aufgabenstellung sind ausdrücklich zu melden statt still zu übergehen.**
Erstens: die Versalien-Begründung trägt nicht — der Gate schweigt heute, aber nicht wegen der
Groß-Schreibung (LOW-1, an fünf Varianten gemessen). Zweitens: die Zahl *„19 → 0 entfernte
Befund-IDs"* ist im Endpunkt bestätigt, in der 19 unter keinem angegebenen Muster reproduzierbar
(INFO-1). Richtig sind dagegen alle übrigen Angaben, die ich nachgeprüft habe: 19+/19− für
`8864708`, sechs Zeilen auf sechs für `b00cb6d`, +9 Zeilen für `f89cba3`, und der Ausgangs-Stand
`make gates` Exit 0 mit d-check 279/0, comment-claims 38/0 und 150 bats.

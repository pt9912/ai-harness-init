# Review-Report: slice-059 — 2026-07-29 (Runde 3, Prüfung der Review-Antwort)

**Review-Art:** Code — geprüft wird die **Antwort** auf die Runde-2-Befunde
(1 HIGH, 3 MEDIUM, 7 LOW, 3 INFO; Report
`docs/reviews/2026-07-29-slice-059-runde-2-review.md`), nicht der Slice erneut in
ganzer Breite. Neu aufgefallene Defekte sind trotzdem aufgenommen.

**Gegenstand:** `76be8c8` (Antwort auf Runde 2) und `3a1a86d` (Verifikations-Reste)
— zusammen `f88feed..3a1a86d`. Die drei Folge-Commits (`e1ec008`, `cb555f1`,
`feb8d21`) betreffen den Lifecycle von slice-065 und sind nicht Gegenstand.

**Modell:** Opus 5 (1M context) · **Datum:** 2026-07-29 · **Baseline:** v3.5.2

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- `docs/plan/planning/in-progress/slice-059-telemetrie-erfassung-hook.md`
- `docs/plan/adr/0011-telemetrie-erfassung-policy.md` (Accepted, immutabel), `ADR-0003`
- `LH-QA-01` … `LH-QA-04`
- `AGENTS.md` §3 Hard Rules (insb. §3.6), `harness/conventions.md` `MR-018`, `MR-005`
- Regelwerk `modul-10-review-harness.md` (Finding-Kategorien, Verdikt)

**Sensorlage.** Vom Auftrag gesetzt, **nicht von mir gefahren** (Ressourcen-Schranke):
`make gates` Exit 0 (comment-claims 36/0) · `make mutate` 111 ok / 0 Befunde
(`.harness/state/mutate-runde3.log`, Stand vor `3a1a86d`). Ich habe **keinen** Build
und **kein** Gate gefahren. Selbst gemessen (billige Leseoperationen am realen
Zustand): der Live-Bestand unter `.harness/state/spans/` (Strom-Namen, Rechte,
Feldbestand einer geschriebenen Zeile), der Push-Stand von `origin/main`, die
Gate-Abdeckung von `harness/tools/*.sh` aus dem `Makefile`.

---

## Status der Runde-2-Befunde

| Runde 2 | Status | Beleg / Rest |
|---|---|---|
| **HIGH-1** Strom-Spaltung, 58 doppelte `seq` | **vollständig** | `harness/conventions.md:970-983` trägt die Regel *„Der Strom ist `(session, agent)` — die FELDER, nicht der Dateiname"* mit **zwei bindenden Folgeregeln** (nach Feldern gruppieren; vor einem Wechsel der Namensbildung `span-clean`). Altbestand geräumt — selbst gemessen: `.harness/state/spans/` führt drei Ströme, **alle** in `_`-Schreibweise, **kein** `(session, agent)`-Paar mehr in zwei Dateien; der Sitzungs-Strom beginnt neu bei 1. Rest → F-1 |
| **MEDIUM-1** flock scheitert an einem Lock-**Verzeichnis** (EISDIR) | **vollständig** für den benannten Fall | `internal/span/emit.go:313-325` räumt auf und öffnet erneut; `TestLeftoverLockDirectoryDoesNotBlock` (`span_test.go:520`) legt ein echtes Verzeichnis an; Mutation 114 nimmt das `os.Remove` weg (Anker existiert, EISDIR bleibt bestehen ⇒ Wächter rot). Neuer Rest an derselben Stelle → F-2 |
| **MEDIUM-2** `span-check` prüfte 7 von 14 | **vollständig** | `harness/tools/span-check.sh:98-102` führt **15 von 15** Pflicht-Zeilen aus `MR-018:838-850`; selbst gegen die Tabelle gelegt **und** an einer echten Live-Zeile nachgemessen: alle 15 anwesend |
| **MEDIUM-3** `correlation`-Kommentar „nicht ableitbar" | **vollständig** | `emit.go:355-362` sagt jetzt das Richtige (*hängt am Lauf, kommt aus `roleFromAgentType`*) und benennt die überholte Fassung als überholt |
| **LOW-1** Querverweis „s. Abweichung 3" | **vollständig** | `conventions.md:849` → *Abweichung 2*, und Abweichung 2 (`:906`) ist die PR-Nummer |
| **LOW-2** `agent_type` Optional ohne `omitempty` | **vollständig** | Aufgelöst Richtung **Pflicht**. Die Begründung trägt: `session`/`agent`/`agent_type`/`agent_role` als ein Block, leer = Aussage — dieselbe Konstruktion wie bei `branch`/`commit` (Abweichung 2) und `agent_role` (Abweichung 3). Konsistent an **vier** Stellen: Tabelle `:844`, Struct `emit.go:50` (kein `omitempty`), `TestMandatoryFieldsAlwaysPresent`, `span-check.sh:100`. Repo-weit gegrept: keine Fundstelle nennt es noch Optional |
| **LOW-3** `git check-ignore` unbewacht | **benannt statt behoben** | `span-check.sh:32-38` nennt die **Grenze der Methode** korrekt: das Entfernen einer Prüfung lässt den Gate grün, Mutation misst Zähne, nicht Existenz. Für ein LOW eine zulässige Auflösung |
| **LOW-7** `BashOutput` mit `program`/`argc` | **vollständig** | Aus `classCommand` genommen (`span.go:161-166`), Tabelle in zwei Zeilen mit Begründung (`conventions.md:871-872`), `TestUnknownToolStaysSilent` füttert `BashOutput` **ausdrücklich** mit einem `command`-Feld — genau dem Fall, der vorher `program` erzeugt hätte |
| **LOW-4** (Lock-Dateien), **LOW-5** (`uname`), **LOW-6** (`-j`) | **offen, unbenannt** | Gemessen: nach `span-clean` liegen wieder 5 `.lock`-Dateien, alle aus `span-check`-Läufen; kein `.NOTPARALLEL`; `Makefile:241-242` unverändert. LOW blockiert nicht — dass sie **nirgends** als bewusst vertagt stehen, ist F-6 |
| **INFO-1/-2/-3** | offen | waren INFO, keine Aktion erwartet |

**Zwei neue Felder** (`duration_ms`, `result_bytes`): die Wächter tragen, was sie
behaupten — s. Negativbefunde; ein Rand als F-5.
**Ablageort 0755/0600:** die Trennung stimmt und ist live belegt; zwei Ränder als F-3.
**`agent-watch.sh`:** die Auflösung reicht; die Zusage darin ist falsch → F-4.

---

## Findings

### F-1 — die neue bindende Regel „vor einem Wechsel der Namensbildung `span-clean`" hat keinen Sensor

- `kategorie`: LOW
- `quelle`: `ADR-0011` Folgepflicht 4, `MR-018` (`harness/conventions.md:970-983`)
- `pfad`: `harness/conventions.md:978-983`; kein Gegenstück in `harness/tools/span-check.sh`
- `befund`: Dieselbe Doppelvergabe ist in diesem Slice **zweimal** entstanden (awk→Go:
  16 Duplikate; `sanitizePart`: 58) und **beide Male von Hand** gefunden worden. Die
  Regel steht jetzt normativ da, wird aber von keinem Gate gemessen — es gibt keine
  Prüfung, die zwei Dateien mit identischem `(session, agent)` im Bestand meldet.
- `verifizierbar`: ja — zwei Strom-Dateien mit identischem `session`-Feld anlegen und
  `make gates` fahren; kein Gate meldet es. *Abgeleitet aus dem Gate-Bestand, nicht
  gefahren (Ressourcen-Schranke).*

### F-2 — die EISDIR-Reparatur kann ein **fremdes, frisches** Schloss entfernen; genau das schließt der Kommentar 20 Zeilen darüber aus

- `kategorie`: LOW (MEDIUM, sobald je eine `mkdir`-Fassung veröffentlicht wäre — s. `befund`)
- `quelle`: `AGENTS.md` §3.6, `ADR-0011` Folgepflicht 4
- `pfad`: `internal/span/emit.go:320` (`os.Remove(path)`) gegen `:294-297`
  (*„und damit auch kein Brechen eines solchen Schlosses"*), Wächter
  `internal/span/span_test.go:520-533`
- `befund`: `os.Remove` versucht laut Implementierung **zuerst `unlink`** und erst danach
  `rmdir`; es entfernt also auch eine **Datei**. Treffen zwei Emitter dasselbe
  liegengebliebene Lock-Verzeichnis, kann der zweite zwischen seinem `Stat` und seinem
  `Remove` die inzwischen angelegte, geflockte Lock-**Datei** des ersten löschen — beide
  flocken danach verschiedene Inodes, lesen dieselbe `.seq` und vergeben **dieselbe
  Nummer**. Das ist das Fehlerbild aus Runde-1-MEDIUM-5, in der Reparatur des
  Runde-2-MEDIUM-1 wieder aufgemacht; der Kommentar über `acquire` schließt das Brechen
  unbedingt aus. Wächter und Mutation 114 fahren nur **einen** Emitter.
  **Warum trotzdem LOW:** die auslösende Vorbedingung ist heute unerreichbar — selbst
  gemessen: `origin/main` steht auf `21684e8`, also **vor** jeder Emitter-Fassung; keine
  `mkdir`-sperrende Fassung wurde je gepusht, und im einzigen Checkout, der sie fuhr,
  liegt kein Lock-Verzeichnis (`ls -la .harness/state/spans/` zeigt ausschließlich Dateien).
- `verifizierbar`: ja — in `TestLeftoverLockDirectoryDoesNotBlock` zwei nebenläufige
  Emitter auf dasselbe Verzeichnis setzen. *Abgeleitet aus der `os.Remove`-Semantik
  (unlink vor rmdir) und dem Code, nicht gefahren.*

### F-3 — die 0755-Zusage gilt nur für ein **frisch angelegtes** Verzeichnis und nur bei passender `umask`

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `internal/span/emit.go:226-237` (`os.MkdirAll(dir, 0o755)` samt Zusage) gegen
  `:288-291` (`appendLine` zieht den Modus einer **bestehenden** Datei ausdrücklich nach),
  Wächter `internal/span/span_test.go:352-361`
- `befund`: `MkdirAll` gibt für ein **bestehendes** Verzeichnis `nil` zurück, ohne die
  Rechte anzufassen — ein von der Vorgänger-Fassung mit `0700` angelegter Ablageort
  bleibt `0700`, und `make docs-check` bleibt mit „permission denied" rot. Für **Dateien**
  ist genau diese Klasse zwei Funktionen weiter oben behandelt (`f.Chmod(0o600)`,
  Review-Befund LOW-3 der ersten Runde); für das Verzeichnis nicht. Zweitens unterliegt
  `MkdirAll` der `umask`: bei `umask 077` entsteht wieder `0700`.
  `TestSpanDirIsTraversable` misst über `newRoot(t)` ausschließlich den frisch angelegten
  Fall im Test-Container, also weder den Bestand noch die `umask` des Hosts, auf dem der
  Hook läuft.
  **Zur Fairness:** die Trennung *Verzeichnis betretbar / Dateien 0600* ist inhaltlich
  richtig und live belegt (selbst gemessen: `.harness/state/spans` = `755`, alle
  `.jsonl`/`.seq`/`.lock` = `600`); der Fund selbst ist der wertvollste dieses Commits.
- `verifizierbar`: ja — `chmod 700 .harness/state/spans`, einen Span schreiben, danach
  `stat -c %a` lesen: unverändert `700`. *Abgeleitet aus der `MkdirAll`-Semantik, nicht
  gefahren.*

### F-4 — die Abweichungs-Zeile zu `agent-watch.sh` sagt „unbewacht, kein Gate"; zwei Gates fassen die Datei

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (eine Zusage über die eigene Abdeckung, hier in der
  konservativen Richtung falsch)
- `pfad`: `docs/plan/planning/in-progress/slice-059-telemetrie-erfassung-hook.md:154`
  und `:183-193`, `docs/plan/planning/next/slice-065-testlauf-ressourcendeckel.md:102`
  gegen `Makefile:128` (`shell-lint` über `harness/tools/*.sh`) und `Makefile:135`
  (`comment-claims` über `git ls-files 'harness/tools/*.sh'`), beide in `Makefile:270`
  (`gates`)
- `befund`: Die Datei liegt unter `harness/tools/` und ist getrackt, wird also in **jedem**
  `make gates` von `shellcheck` und von `comment-claims` gefasst. Zutreffend wäre: kein
  **funktionaler** Wächter, kein Makefile-Ziel, kein `MR`-Eintrag. So gelesen plant
  slice-065 Arbeit ein, die zur Hälfte schon getan ist.
- `verifizierbar`: ja, selbst gefahren — `Makefile:128`/`:135` gegen `:270` legen.

### F-5 — `result_bytes` ist die Länge der **JSON-Kodierung**, nicht die des Ergebnisses

- `kategorie`: INFO
- `quelle`: `MR-018` (`harness/conventions.md:856`)
- `pfad`: `internal/span/span.go:94-100` (`int64(len(v))` auf einer `json.RawMessage`),
  `internal/span/span_test.go:306-330`
- `befund`: Gemessen wird die Länge des rohen JSON-Werts — inklusive Anführungszeichen,
  Escape-Folgen und, bei einem Objekt, der Schlüsselnamen. Die Feldzeile fragt *„Wie groß
  war das Ergebnis?"*; der Code-Kommentar ist mit *„wie die Payload sie trägt"* präziser
  als die normative Stelle. Der Wächter prüft nur `> 0`, pinnt die Semantik also nicht.
  Für die Incident-Frage (*erklärt ein einzelner Aufruf eine Spitze?*) trägt die Zahl als
  Proxy; ein Vergleich gegen eine Dateigröße läge daneben.

### F-6 — LOW-4/-5/-6 der Vorrunde sind weder behoben noch als vertagt benannt

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `.harness/state/spans/*.lock` (5 Stück, alle aus `span-check`-Läufen),
  `Makefile:241-242`, `Makefile:270`
- `befund`: Die Antwort adressiert HIGH-1, alle drei MEDIUM, LOW-1, LOW-2, LOW-3 und
  LOW-7 und benennt LOW-3 ausdrücklich als Grenze. LOW-4 (wachsender Lock-Bestand),
  LOW-5 (unbekannte `uname`-Werte) und LOW-6 (`-j`-Reihenfolge) kommen in beiden
  Commit-Messages nicht vor. Sie blockieren nicht; hier festgehalten, damit „nicht
  gesehen" und „bewusst gelassen" unterscheidbar bleiben.

---

## Negativbefunde

- **geprüft, ohne Befund: in den Span wandert nur die Länge des Ergebnisses.** Und zwar
  **strukturell**, nicht durch Sorgfalt: `Parse` legt in `Payload` ausschließlich
  `int64(len(v))` ab — der Inhalt von `tool_response` verlässt `Parse` nie, `Build` kann
  ihn gar nicht erreichen. Deshalb muss Mutation 115 ein Literal einschleusen, statt den
  Inhalt durchzureichen; das ist kein schwacher Fall, sondern die Folge der richtigen
  Schnittstelle. `TestDurationAndResultSize` prüft die **marshalte Zeile** gegen drei
  Kanarienvögel (`abc123`, `AWS_SECRET`, `noch mehr Ausgabe`); Mutation 115 hat ihn im
  Lauf 111 ok / 0 Befunde rot gesehen. Die Gegenrichtung deckt
  `TestMissingDurationStaysAbsent`: eine fehlende Messung wird nicht als `0` erfunden.
  Beide Felder tragen `omitempty` und stehen als **Optional** in `MR-018` — konsistent.
- **geprüft, ohne Befund: die Payload-Messung ist als Herkunft benannt.**
  `harness/conventions.md:875-889` führt die gemessenen Schlüsselnamen, die zwei Lehren
  (`duration_ms` liegt bereit; `tool_response` statt `tool_output`) **und** die drei
  ausdrücklich abgelehnten Felder (`cwd`, `effort`, `prompt_id`). Das erfüllt die Zusage
  *„Das Schema ist GESCHLOSSEN"* (`:832-834`) in beide Richtungen: aufgenommen mit
  Incident-Frage, abgelehnt mit Grund.
- **geprüft, ohne Befund: die Pflicht-Spalte ist an vier Stellen deckungsgleich.**
  15 Pflicht-Zeilen in `MR-018:838-850`, 15 Felder ohne `omitempty` im Struct, 15 in
  `TestMandatoryFieldsAlwaysPresent`, 15 in `span-check.sh` (plus `program` als
  gerechtfertigtes Optional für die Bash-Payload des Gates). Live an einer echten Zeile
  von 09:27Z gegengemessen: alle 15 anwesend, `agent`/`agent_type`/`agent_role` leer und
  **als leer erkennbar**, dazu `duration_ms:34084` und `result_bytes:284`.
- **geprüft, ohne Befund: `AGENTS.md` §3.2–§3.5.** `git show --stat` beider Commits über
  `docs/plan/adr/` und `spec/` ist leer — die immutable `ADR-0011` und die Spec sind nicht
  angefasst (§3.4). Kein `//nolint`, kein `shellcheck disable`, kein `git mv` im Diff
  (§3.2/§3.3); `make gates` ist nicht gelockert (§3.5), `span-check` prüft **mehr** als
  vorher.
- **geprüft, ohne Befund: `agent-watch.sh` ist gegenüber dem Slice-Gegenstand inert.** Kein
  Makefile-Ziel, kein Hook, kein Test, kein Aufruf aus einem anderen Skript (gegrept). Es
  in §3 **und** §6 als Abweichung samt Grenze zu führen und in slice-065 als Vorarbeit
  einzuhängen, ist die Auflösung, die Modul 10 verlangt: benennen statt mitliefern. Ein
  Herausnehmen wäre keine bessere Auflösung — der Melder ist aus einem gemessenen Vorfall
  entstanden und in der Folge-Planung bereits verankert. Einzige Korrektur: F-4.
- **geprüft, ohne Befund: die Emission ist unberührt.** `internal/emit/` steht in keinem
  der beiden Diffs; das **Ob** eines Emitters für den emittierten Harness bleibt bei
  slice-062.
- **geprüft, nicht bewertet (Modul 11):** ob `make gates` und `make mutate` reproduzieren.
  Ich habe beides nicht gefahren. Beobachtung ohne Anspruch:
  `.harness/state/gates-passed.diffsha` trägt 11:27, `3a1a86d` ist von 11:23 — die
  Reproduktion gehört trotzdem der Verifikation.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | **0** |
| MEDIUM | **0** |
| LOW | 4 |
| INFO | 2 |

**Der blockierende Befund der Vorrunde ist geschlossen, und zwar an beiden Enden:** die
Regel steht normativ in `MR-018`, und der gespaltene Bestand ist geräumt — selbst
nachgemessen, nicht aus der Commit-Message übernommen. Die drei MEDIUM sind ebenfalls
vollständig; MEDIUM-2 ist an einer Live-Zeile gegengemessen.

**Das Muster hat sich zum dritten Mal verkleinert und einmal verschoben.** Runde 1: vier
HIGH, drei davon Halbierungen. Runde 2: ein HIGH, drei MEDIUM, zwei Halbierungen.
Runde 3: kein HIGH, kein MEDIUM, **keine** Halbierung — alle nachgeprüften Befunde sind
vollständig oder (LOW-3) als Grenze der Methode korrekt benannt. Die alte Klasse *„ein
Kommentar sagt mehr zu, als sein Code trägt"* ist nicht verschwunden, aber von zwei
MEDIUM auf zwei LOW geschrumpft (F-2, F-3) — und beide sitzen in den **Reparatur**-Pfaden,
die diese Runde neu entstanden sind, nicht mehr im Hauptweg.

**Was diese Runde gegenläufig auszeichnet, und es ist substanziell:** der Fund *„der Gate
war grün wegen Altbestand"* ist genau die Selbstmessung, die die zwei Vorrunden vermisst
haben — hier hat der Implementer dem eigenen grünen Gate nicht geglaubt, nachgeräumt und
den Defekt dadurch überhaupt erst sichtbar gemacht. Ebenso die zwei neuen Felder: erst an
einer echten Payload **gemessen**, dann aufgenommen, samt zweier korrigierter eigener
Annahmen und einer benannten Ablehnungsliste. Und `agent-watch.sh` ist selbst gemeldet
worden, bevor jemand danach fragte.

---

## Verdikt

**KONFORM.** Merge-blockierend: **nein** — 0 HIGH, 0 MEDIUM.

Der HIGH-1 der Vorrunde ist an beiden Enden geschlossen (Regel **und** Bestand, gemessen),
die drei MEDIUM sind vollständig, und von den sieben LOW sind fünf behoben, eines
(LOW-3) als Grenze der Methode korrekt benannt. Die vier neuen LOW blockieren nach
Modul 10 nicht; zwei davon (F-2, F-3) beschreiben Ränder in den heute entstandenen
Reparatur-Pfaden, deren auslösende Vorbedingung ich als **nicht erreichbar** gemessen habe
(`origin/main` kennt keine Emitter-Fassung; im einzigen Checkout mit dieser Historie liegt
weder ein Lock-Verzeichnis noch ein `0700`-Ablageort). Sie gehören in die Folgearbeit,
nicht vor den Abschluss — F-2 mit einem Ein-Wort-Umfang, F-3 mit einer Zeile.

**Übergabe:** Die sechs Findings gehen an die Implementation. Bei F-1 und F-5 ist
`MR-018` die zu ändernde Stelle, nicht der Code. Dieses Verdikt ersetzt keine
Verifikation: DoD- und Spec-Konformität sowie die Reproduktion von `make gates` und
`make mutate` prüft Modul 11 separat — ich habe kein Gate gefahren (Ressourcen-Schranke).

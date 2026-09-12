# Verifikation — slice-221: Der Verweis-Nachzug lässt die `Accepted`-ADR unberührt

- **Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-12
- **Eingang:** DoD-Bestätigung des Implementers über die Commits `3fb64279` (Lieferung),
  `67a1784b` (Nacharbeit R1), `a42b16b8` (Nacharbeit R2) plus zwei Review-Runden
  (`docs/reviews/2026-09-12-slice-221-nachzug-laesst-die-adr-unberuehrt.md`, 1 HIGH/1 MEDIUM/1 LOW;
  `…-r2.md`, 0 HIGH/1 MEDIUM/3 LOW, Verdikt „Sperre aus Runde 1 ist gehoben").
- **Prüfgegenstand:** `docs/plan/planning/in-progress/slice-221-nachzug-laesst-die-adr-unberuehrt.md`
  gegen den Baum bei `HEAD=9652c5d7` (letzter für diesen Slice relevanter Commit `a42b16b8`; die
  zwei Commits danach — `8031de35`, `cb702147`, `9652c5d7` — gehören zu `slice-222` und
  `ADR-0044` und berühren keine Datei mit Bezug zu `slice-221`,
  `git show --pretty=format: --name-only cb702147 9652c5d7 8031de35 | grep -i 221` → leer).
- **Frage dieser Rolle:** Bauen wir es richtig — gegen Plan und DoD. Nicht Gegenstand: ob der Diff
  dem Plan folgt (Reviewer, zweimal gelaufen), ob das Ziel den realen Bedarf trifft (Validator,
  hier nicht vorgesehen).
- **Nicht angefasst, wie angewiesen:** `docs/plan/adr/0044-*.md`, `docs/plan/adr/README.md`,
  `harness/conventions.md` — Architect-Lauf parallel unterwegs, während dieser Verifikation als
  `M` im Arbeitsbaum sichtbar. Ich habe sie nur gelesen (für die `[unsauber]`-Diagnose unten), nicht
  geändert.

---

## 1. Ist der Sensor gelaufen?

`make gates` habe ich **nicht** erneut gefahren (Anweisung: Docker-Ziele bleiben aus, paralleler
Architect-Lauf). Ich übernehme die Zusage „EXIT 0 über `9652c5d7`" aus der Aufgabenstellung
unbestätigt für die Docker-Ziele (`lint`, `build`, `test`, `docs-check`, `span-check`,
`baseline-verify`), stütze mich aber wo möglich auf **fremde, bereits gelaufene** Beweise statt sie
zu wiederholen:

- **R2 hat `make test-go`, `make test-bats`, `make shell-lint`, `make comment-claims` selbst
  gefahren** — nicht nur zitiert: „`make test-bats` EXIT 0 mit `1..272`, **272** Zeilen `^ok `[…],
  `make comment-claims` → *„58 Datei(en) geprueft, 0 Befund(e)"*" (R2, MEDIUM-1-Beleg). Das ist ein
  unabhängiger Lauf einer anderen Rolle in frischem Kontext, kein Implementer-Selbstbericht.
- **Die sieben Mutationen der R2-Sonde** (Tabelle „Was ich real rot bzw. grün gesehen habe") sind
  von mir **nicht** wiederholt, aber inhaltlich gegen den Code nachvollzogen (§2 unten): Jede
  genannte Zeilennummer/Funktion existiert exakt so im aktuellen `scan.go`/`refs.go`.
- **Was ich selbst, ohne Docker, gegen den aktuellen Baum gefahren habe:**
  - `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand` — der Träger liegt
    bereits gebaut vor (`.harness/state/bin/ai-harness-init`, Zeitstempel nach `a42b16b8`), Aufruf
    ist kein Docker-Ziel.
  - Textuelle Prüfung aller neuen/geänderten Kommentare, Test-Funktionsnamen und Mutationsfälle
    gegen den referenzierten Code (`grep`, `git show`, `git diff`).
  - `git show --stat` auf alle drei Commits, `git log` auf `docs/plan/adr/0042-*.md` seit
    `Accepted` (kein Treffer nach dem Accept-Commit).

**Ein Sensor fehlt beobachtbar nicht** — jeder in der DoD genannte Wächter (`test-bats`-Fall,
`test-go`-Fälle, die beiden Mutationsfälle je Träger, `docs-check`, `comment-claims`) existiert als
Datei/Testfunktion und ist mindestens einmal (von R2 oder von mir) tatsächlich gelaufen. Was **ich**
nicht selbst gefahren habe, ist `make gates` als Ganzes, `make mutate` als Volllauf,
`make full-smoke`/`make smoke` und `docs-check` — siehe §„Was ich nicht geprüft habe" am Ende.

## 2. DoD-Punkt für DoD-Punkt

| # | DoD-Punkt | Befund | Beleg |
|---|---|---|---|
| 1 | **Shell-Träger** — `slice-mv.sh` nimmt `docs/plan/adr` neben `.harness/baseline` aus der eingehenden Ersetzung, `docs/reviews/` bleibt drin; Pathspec an **einer** von `main()` benutzten Stelle, bats-Fall + Mutations-Fall (`test-bats`) nehmen ihr die Zähne | **Erfüllt — über zwei Wächter, nicht nur einen.** `eingehend_ausgenommene_pfade()` liefert `:!.harness/baseline` und `:!docs/plan/adr` (`harness/tools/slice-mv.sh:134-136`); `main()` liest sie in `in_pathspec[]` und übergibt sie an `git grep` (`slice-mv.sh:235-245`). Der **Listen-Inhalt** ist von `test/slice-mv.bats:116-121` und `test/mutations/313-…` (`# verify: test-bats`) gedeckt. Die **Verdrahtung** (dass `main()` die Liste auch benutzt) hängt seit R1-MEDIUM-1 zusätzlich an `TestSliceMvEchtUebergehtAcceptedADRBeimNachzug` (`cmd/ai-harness-init/slice_mv_echt_test.go`, `# verify: test-go`) und `test/mutations/315-…`. Das ist **mehr**, als der DoD-Wortlaut nennt (er nennt nur `test-bats`) — siehe Plan-vs-Code-Diff §3. | `grep -n "eingehend_ausgenommene_pfade\|in_pathspec" harness/tools/slice-mv.sh`; Testcode oben gelesen; Mutationsdatei-Inhalte oben zitiert. |
| 2 | **Go-Träger** — `VerweisFund`/`Nachziehen` überspringen `docs/plan/adr/`, `Haenger` behält vollen Suchraum; bestehender Test/Mutationsfall unverändert wirksam, ein eigener Fall (`test-go`) nimmt dem neuen Ausschluss die Zähne | **Erfüllt.** `SuchraumNachzug`/`AusgenommenePfadeNachzug` (neu, `scan.go:80-127`) werden ausschließlich von `VerweisFund` (`refs.go:92`) und `Nachziehen` (`refs.go:230`) gerufen; `Haenger` (`scan.go:180`) ruft weiterhin `Suchraum()`. `TestVerweisFundUndNachziehenUebergehenAcceptedADR` (neu, `refs_test.go`) und `TestHaengerFindetVerweisAusADRTrotzNachzugAusnahme` (neu, `scan_test.go`, aus R1-HIGH-1) prüfen **beide Eigenschaften an derselben Fixture**. R2 hat **sieben** unabhängige Mutationen an allen vier beteiligten Code-Stellen gefahren — alle rot, keine grün geblieben (R2 Tabelle „Was ich real rot bzw. grün gesehen habe"). Die alten Wächter `TestHaengerFindetVerweisAusReviewReport`/`test/mutations/233-…` bleiben unverändert, weil sie ausschließlich `AusgenommenePfade()` prüfen (von diesem Slice nicht verändert). | `git show 3fb64279 -- internal/archive/{refs,scan}.go`; `git show 67a1784b -- internal/archive/scan{,_test}.go`; R2 §„Was ich real rot bzw. grün gesehen habe". |
| 3 | **Sperre fällt, beobachtbar** — Vorschau nennt `0` `docs/plan/adr`-Zeilen als Nachzugsziel, weiterhin genau eine Sperre `[haenger]` | **Erfüllt, selbst nachgemessen.** `archive-welle --vorschau altbestand` (Bereich „Verweise:", d.h. die Nachzugs-Zielliste) enthält **0** Treffer für `docs/plan/adr`; die **3** Treffer, die ein naives `grep -c 'plan/adr'` über den **gesamten** Vorschau-Text liefert, stammen ausschließlich aus dem `[haenger]`-Block (Format `docs/plan/adr/…md -> docs/reviews/…md`, also ADR **als Quelle** eines noch lebenden Verweises — genau die Eigenschaft, die `Haenger` weiterhin sehen soll). Die zwei sind, wie R1 im Negativbefund festhält, nicht verwechselt. Auf meinem aktuellen (durch das parallele `ADR-0044`-Vorhaben unsauberen) Baum zeigt die Vorschau zusätzlich `[unsauber]` — das ist die vom Architect-Lauf hinterlassene Änderung an `docs/plan/adr/0044-*.md`/`docs/plan/adr/README.md`/`harness/conventions.md`, **nicht** slice-221-bezogen; auf dem sauberen Baum von R1/R2 stand bereits nur `[haenger]`. | `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand \| awk '/^  Verweise:/{b=1;next} /^  Sperren:/{b=0} b' \| grep -c 'docs/plan/adr'` → **0**; `… \| sed -n '/^  Sperren:/,$p' \| grep -oE '^\s*\[[a-z]+\]' \| sort -u` → `[haenger]`, `[unsauber]` (letzteres fremdverursacht, s. `git status --porcelain`). |
| 4 | `make gates` grün | **Nicht selbst nachgefahren** (Anweisung). Bezeugt durch: Commit-Message `a42b16b8` (*„make gates: EXIT 0 (docs-check 1194/0, comment-claims 58/0)"*) **und** unabhängig durch R2, die `test-go`/`test-bats`/`shell-lint`/`comment-claims` selbst gefahren hat. Fehlend aus meiner eigenen Prüfung: `lint`, `build`, `span-check`, `baseline-verify`, der volle `docs-check`-Lauf. | s. §„Was ich nicht geprüft habe". |
| 5 | Review durchgeführt, Report liegt vor, kein Self-Review | **Erfüllt.** Zwei Reports vorhanden (`…r1.md`, `…-r2.md`), beide im Reviewer-Skill-Format, R2 ausdrücklich „frischer Kontext, Runde 1 als Eingang gelesen". Keiner der beiden Reports trägt eine Implementer-Signatur. | Dateien gelesen (oben zitiert). |
| 6 | Doku-Update: beide Sensor-Dokumente nennen die Ausnahmeliste namentlich, ziehen mit | **Erfüllt.** `harness/sensors/slice-mv.md` §Grenze nennt wörtlich *„repo-weit außer `.harness/baseline/**`[…] und `docs/plan/adr/**`"*; `harness/sensors/archive-welle.md` §Grenze Punkt 3 nennt *„nimmt allein `.git` und `.harness/baseline/**` aus"* für `Haenger` **und** ergänzt separat *„Der schreibende Zweig (`VerweisFund`/`Nachziehen`) nimmt zusätzlich `docs/plan/adr/**` aus"*. Punkt 6 (LOW-1 aus R1) steht im Indikativ Präsens, nicht mehr im Präteritum. | Beide Dateien vollständig gelesen (s. o.). |
| 7 | Closure-Notiz mit Steering-Loop-Lerneintrag | **Noch offen — regelkonform.** §7 des Plans trägt ausschließlich `<…>`-Platzhalter. Das ist nach `AGENTS.md` §3.10 **Planner-Arbeit** und läuft nach dieser Verifikation, nicht davor. Kein Implementer-/Verifier-Defekt. | `sed -n '181,201p' docs/plan/planning/in-progress/slice-221-*.md`. |
| 8 | Beobachtungs-Register fortgeschrieben | **Noch offen — regelkonform, aus demselben Grund.** `BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md` steht weiterhin auf `offen` (13 Belege) — **ADR-0042 Folgepflicht 3 sagt ausdrücklich**: „Den Stand schreibt die Closure […], nicht dieser Lauf." Der Zielort für den Ausgang *verkörpert* wäre `ADR-0042` selbst. | `cat docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md`. |
| 9 | Jedes Risiko aus §6 trägt einen Ausgang | **Noch nicht zugewiesen (Planner-Arbeit) — aber für keines fehlt die Evidenz.** Siehe §4 unten: für alle drei Risiken liegt eine tragende Messung vor. | s. §4. |
| 10 | Drei Paarungen (Anker · Folge-Slice · Register) | **Noch nicht anwendbar** — sie prüfen die *gerade entstandenen* Closure-Einträge aus §7-9, die noch nicht existieren. Kein Defekt, reine Reihenfolge. | — |

**Zusammenfassung §2:** Die drei **inhaltlichen** DoD-Punkte (1–3) sind erfüllt und über
mehrere, teils voneinander unabhängige Mutationen belegt — keiner von ihnen ist ein Häkchen für
etwas, das daneben liegt. Punkt 4 ist nur teilweise von mir selbst geprüft (s. o.). Die Punkte 5–6
sind erfüllt. Die Punkte 7–10 sind **erwartungsgemäß offen**, weil sie nach `AGENTS.md` §3.10 in
den Planner-Kontext gehören, der nach dieser Verifikation beginnt.

## 3. Plan-vs-Code-Diff — beide Richtungen

**Was der Plan vorsah und der Code nicht (mindestens nicht in der geplanten Form) liefert:**
Nichts — jede geplante Zeile aus §3 ist umgesetzt (`slice-mv.sh`, `refs.go`, `scan.go`,
`refs_test.go`, `test/slice-mv.bats`, beide Sensor-Dokumente).

**Was der Code liefert und der Plan nicht in §3 vorsah — Wachstum, gegen §1 gehalten:**

| Zusätzliches Artefakt | Auslöser | Fällt es unter §1-Abgrenzung? |
|---|---|---|
| `internal/archive/scan_test.go` (Update, nicht in §3 gelistet) | R1-HIGH-1: Trennung der Suchräume ungewächtert | **Nein, aber gedeckt** — §1 schließt nur „Der Archiv-Move selbst", die `ignore-refs`-Paare, ADR-0042 selbst, den Status-Schnitt und das emittierte Skelett aus. Ein Test zur Eigenschaft, die DoD-Punkt 2 explizit fordert („einmal rot gesehen"), ist keine dieser fünf Klassen — er ist die **Einlösung** von DoD 2, nicht eine sechste. |
| `internal/archive/anwenden_test.go` (Update, nicht in §3 gelistet) | Kalibrierungs-Fixture nutzte bislang `docs/plan/adr/0033-x.md` als Stellvertreter für „irgendeine Datei mit Präfix-Verweis" — nach dem neuen Ausschluss musste sie auf `docs/reviews/…` umgestellt werden, sonst hätte der bestehende Test die neue Regel gebrochen | **Ja, direkt aus dem Auftrag** — ohne diese Anpassung wäre `TestZuStagenNenntNurArchivStubsUndNachgezogene` selbst zum falschen Zeugen geworden. |
| `cmd/ai-harness-init/archive_welle.go` (Kommentar-Update, nicht in §3 gelistet) | Kommentar über `gitLsFiles` musste die neue Drei-Leser-Aufteilung nennen, sonst hätte er die Nachzugs-Trennung falsch beschrieben (§3.7) | **Ja** — reine Kommentar-Pflege an einer Stelle, die der neue Suchraum-Split ohnehin berührt. |
| `cmd/ai-harness-init/slice_mv_echt_test.go` (**neue Datei**, nicht in §3 gelistet) | R1-MEDIUM-1: der bats-Fall deckt nur die reine Pathspec-Liste, nie `main()`s Gebrauch davon (kein `git` im `BATS_IMAGE`) | **Nein wörtlich, ja der Sache nach** — §1 schließt „Der Shell-Träger ist heute unbewachtbar" ausdrücklich **nicht** aus, sondern nennt es Teil des Auftrags („Das ist Teil des Auftrags, nicht seine Voraussetzung", Plan §1 Ende). Diese neue Datei ist genau die Einlösung dieses Satzes. Sie ändert aber den **Wächter-Typ** aus DoD-Punkt 1 (der Wortlaut nennt `test-bats`) auf `test-go` — eine echte, wenn auch begründete Abweichung vom DoD-**Text**. |
| `test/mutations/312`, `314`, `315` (3 statt der geplanten „2 neu" in §3) | R1-HIGH-1 (314) und R1-MEDIUM-1 (315); `312` deckt den Go-Träger direkt aus der ursprünglichen Lieferung | Kein Verstoß gegen die ≤3-Liefer-Punkte-Regel — die zusätzlichen Fälle bedienen weiterhin nur DoD-Punkte 1/2, keinen vierten Liefergegenstand. |

**Urteil zum Diff:** Das Wachstum ist in jedem einzelnen Fall eine **Reaktion auf einen im Review
gemessenen Befund an genau diesem Liefergegenstand**, keine über den Slice hinauswachsende Arbeit.
Keiner der Zusätze berührt eine der fünf in §1 ausdrücklich ausgeschlossenen Klassen. Die einzige
Stelle, an der Code und DoD-**Wortlaut** wirklich auseinanderlaufen, ist DoD-Punkt 1: Er benennt
`test-bats` als den Wächter, der dem Shell-Träger die Zähne nimmt; tatsächlich trägt inzwischen
`test-go` (`TestSliceMvEchtUebergehtAcceptedADRBeimNachzug`/`test/mutations/315`) die Verdrahtungs-
Hälfte der Zusage, `test-bats` nur noch die Listen-Hälfte. Das ist **keine Lücke** — es ist
**mehr** Deckung, als der DoD-Text verlangt —, aber die textliche Divergenz ist real und gehört dem
Planner zur Kenntnis, falls er den DoD-Wortlaut für die Closure-Notiz zitiert.

## 4. Risiken aus §6 — Evidenzlage

Keinem der drei Risiken fehlt die Evidenz für eine Ausgangs-Zuweisung; die Zuweisung selbst ist
Planner-Arbeit (Modul 5):

1. **„Der Ausschluss landet in der geteilten Liste"** — **nicht eingetreten**. Der Code trennt
   `AusgenommenePfadeNachzug()` von `AusgenommenePfade()`; R2s Sonde #3 (`sed -i '41s|...docs/plan/adr...'`,
   d. h. den Ausschluss probeweise in die geteilte Liste verschoben) färbt den neuen Wächter
   **rot**. Belastbare Grundlage für „entfallen".
2. **„Der Pfad-Schnitt trifft auch `Proposed`-ADRs"** — **strukturell weiterhin wahr, aber heute
   ohne Instanz**. `ADR-0042` selbst benennt das als akzeptierten Preis und führt einen eigenen
   Re-Evaluierungs-Trigger 3 dafür; `grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md` zeigt
   aktuell **5** `Proposed`-Dateien, keine davon in der Vorschau als betroffen genannt (selbst
   nachgemessen: `archive-welle --vorschau altbestand` nennt keine `0044-*`/`0043-*`/… Datei im
   Verweise-Block). Für den Planner: Dieses Risiko ist bereits **in ADR-0042 selbst** als Kosten-
   Punkt verkörpert (Festlegung 2 + Re-Evaluierungs-Trigger 3) — die Frage ist, ob ein zusätzlicher
   Registereintrag nötig ist oder ob der Ausgang „entfallen — bereits an anderer Stelle
   entschieden/verkörpert, mit Zeiger auf ADR-0042" lauten sollte.
3. **„Ein dritter Träger bleibt unentdeckt"** — **nicht eingetreten**. Beide Review-Runden haben
   das unabhängig mit demselben Ergebnis geprüft (R1: „Aliasing / dritter Träger — ohne Befund"; R2:
   „schreibende Stellen: `refs.go:243`[…], `anwenden.go:233,285`[…]; … haben außerhalb von
   `refs.go` keinen Nicht-Test-Aufrufer"). Belastbare Grundlage für „entfallen".

## 5. ADR-Konformität

- **ADR-0042 Festlegung 2** (beide Träger nehmen `docs/plan/adr` zusätzlich zum vendored Baum aus
  ihrer Ersetzung aus — kein Byte-Nachzug in einer `Accepted`-ADR): **erfüllt**, s. §2 Punkte 1–2.
- **ADR-0042 Festlegung 5** (Sperre für den ersten Archiv-Move, bis beide Träger die Ausnahme
  führen): **erfüllt und beobachtbar gehoben**, s. §2 Punkt 3. `[haenger]` bleibt als einzige
  fachliche Sperre stehen — genau der Zustand, den Festlegung 5 nach Erfüllung von Folgepflicht 1
  vorsieht.
- **ADR-0042 Folgepflicht 1** („beide Träger bekommen ihren zusätzlich ausgenommenen Pfad […]
  samt Test"): **erfüllt** — und zwar über die Vertiefung aus R1/R2 hinaus stärker belegt, als der
  Wortlaut „samt Test" verlangt (mehrere Tests je Träger statt einem).
- **ADR-0042 Folgepflicht 3** (Registereintrag bekommt seinen Ausgang **bei der Closure**, nicht in
  diesem Lauf): korrekt **nicht** von diesem Slice vorweggenommen, s. §2 Punkt 8.
- **ADR-0042 selbst unverändert** (§3.4/`make adr-immutable`): bestätigt — `git log --oneline -- docs/plan/adr/0042-*.md`
  zeigt keinen Commit nach dem Accept-Commit `945dc9c9`.
- **ADR-0033 Abnahme-Kriterium 1** (`docs/reviews/**` bleibt im Suchraum von `Haenger` **und** von
  `VerweisFund`/`Nachziehen`): **erfüllt** — bestätigt durch `test/slice-mv.bats` (Nicht-Mitgliedschaft
  von `docs/reviews`), `TestVerweisFundUndNachziehenUebergehenAcceptedADR` (Report wird gezählt/
  nachgezogen, ADR nicht) und die umkalibrierten Fixtures in `refs_test.go`/`anwenden_test.go`.
  Keine der drei berührten Dateien nimmt `docs/reviews` versehentlich mit heraus.
- **ADR-0033, alle übrigen Festlegungen:** unberührt (kein Diff außerhalb der oben genannten
  Dateien berührt Archivierungs-Logik jenseits der Ausschlussliste).

## 6. Zusagen, die der Code nicht hält? — keine über R2 hinaus gefunden

Die Klasse, die beide Reviews trieb — „Zusage ohne rot gesehenes Gegenbeispiel an der Stelle, die
die Zusage trägt" —, ist nach `a42b16b8` an beiden ursprünglich betroffenen Trägern geschlossen
(Go: R1-HIGH-1 via `TestHaengerFindetVerweisAusADRTrotzNachzugAusnahme` + 7 Sonden; Shell: R1/R2-
MEDIUM-1 via `TestSliceMvEchtUebergehtAcceptedADRBeimNachzug` + Mutation 315). Ich habe zusätzlich
gezielt nach einer **neuen** Instanz dieser Klasse in den zuletzt geänderten Kommentaren gesucht
(§3.7-Lesart: Indikativ Präsens, auflösbare Herkunft) — keine gefunden: `scan.go:80-94`,
`scan.go:168-173`, `refs.go:63-66`, `refs.go:213-219`, der `slice-mv.sh`-Kopfblock „ZWEITE MESSUNG"
und `scan_test.go:150-153` beschreiben durchweg den **Zustand** samt auflösbarem Sensor, nicht ein
Protokoll oder eine verworfene Alternative.

## Kein Rollen-Selbstverifiziert

Dieser Lauf startet in frischem Kontext ohne den Implementer- oder Reviewer-Kontext dieses Slice.
Eigene Handlungen: `archive-welle --vorschau altbestand` selbst ausgeführt und in zwei Blöcken
(Verweise/Sperren) zerlegt statt den DoD-Text unbesehen zu übernehmen; alle drei Commit-Diffs
selbst gelesen statt aus den Reports zitiert; `git log` auf `ADR-0042` selbst gegen §3.4 geprüft;
die Risiko-Evidenz in §6 des Plans selbst gegen Code und Reviews abgeglichen, nicht nur den
Reviewer-Wortlaut übernommen.

## Was ich nicht geprüft habe

- **`make gates` als Ganzes** sowie einzeln `lint`, `build`, `test` (Docker-Stufen), `docs-check`,
  `span-check`, `baseline-verify` — Anweisung, Docker-Ziele während des parallelen Architect-Laufs
  auszulassen. Ich stütze mich auf die Commit-Message-Zusage und auf R2s eigenständigen
  `test-go`/`test-bats`/`shell-lint`/`comment-claims`-Lauf.
- **`make mutate` als Volllauf** (300 Fälle). Ich habe keine eigene Mutation gefahren, sondern die
  sieben Sonden aus R2 sowie die vier neuen Mutationsfälle **inhaltlich** gegen den aktuellen Code
  gelesen (Anker, referenzierte Testnamen, Eindeutigkeit der `sed`-Muster) — nicht ausgeführt.
- **`make full-smoke` / `make smoke`.**
- **`git status --porcelain` auf einem wirklich sauberen Baum** — mein Baum trägt drei
  `ADR-0044`-Änderungen aus dem parallelen Architect-Lauf; ich habe sie nur diagnostisch gelesen
  (für die `[unsauber]`-Erklärung in §2 Punkt 3), nicht berührt.
- **Die textliche Vollständigkeit von `harness/sensors/slice-mv.md` gegen die Ziel-Form** (die
  fehlenden zwei Abschnitte, die R1 als „Bestand, von diesem Diff nicht berührt" einordnet) — das
  ist keine Zusage dieses Slice.
- **Ob mein eigener Bericht das Doku-Gate hält** — nicht mit `docs-check` geprüft (s. o.).

---

## Verdikt

**DoD erfüllt: ja, für alle Punkte, die vor der Planner-Closure prüfbar sind.**

- DoD 1–3 (Shell-Träger, Go-Träger, Sperre fällt beobachtbar): **erfüllt**, mehrfach und teils
  redundant belegt (mehr Wächter, als der Text verlangt, für den Shell-Träger sogar ein anderer
  Wächter-**Typ** als im Wortlaut genannt — s. §3).
- DoD 4 (`make gates`): **von mir nicht selbst nachgefahren**, per Anweisung; bezeugt durch Commit-
  Message und einen unabhängigen Teil-Lauf der Reviewer-Rolle (R2).
- DoD 5–6 (Review, Doku-Update): **erfüllt**.
- DoD 7–10 (Closure-Notiz, Register, Risiko-Ausgänge, drei Paarungen): **erwartungsgemäß offen** —
  `AGENTS.md` §3.10 bindet diese Schritte an den Planner-Kontext, der nach dieser Verifikation
  beginnt. Kein Risiko aus §6 steht ohne Evidenz für seinen Ausgang da (§4).

**ADR-Konformität:** ADR-0042 Festlegungen 2/5 und Folgepflicht 1 erfüllt, Folgepflicht 3
korrekt nicht vorweggenommen, ADR-0042 selbst unverändert; ADR-0033 Abnahme-Kriterium 1 gehalten.

**Plan-vs-Code:** Kein Punkt aus §3 fehlt im Code. Vier zusätzliche Artefakte über §3 hinaus, alle
vier direkt aus Review-Findings an genau diesem Liefergegenstand, keines verletzt die §1-
Abgrenzung. Eine textliche DoD-Divergenz ist zu benennen (Punkt 1: geplanter Wächter-Typ
`test-bats`, tatsächlich tragender Wächter für die Verdrahtungs-Hälfte `test-go`) — sachlich mehr
Deckung, aber ein Punkt für die Closure-Notiz, falls der Planner den DoD-Text wörtlich abgleicht.

**Kann der Planner den Slice schließen:** aus Verifikations-Sicht **ja**, sobald (a) `make gates`
auf dem dann sauberen Baum einmal bestätigt ist (nach Abschluss des parallelen `ADR-0044`-Laufs)
und (b) die in §2 als „noch offen" markierten Closure-Schritte (7–10) durchlaufen sind. Kein
technischer, sensor-gestützter Befund hält den Slice zurück.

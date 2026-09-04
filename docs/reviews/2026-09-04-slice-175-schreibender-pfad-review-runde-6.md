# Review Runde 6 — slice-175, die zwei behobenen MEDIUM und der fremde Mutations-Befund

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung der zwei MEDIUM aus Runde 5 mit **selbst gefahrenen** Sonden, dazu die Frage, ob die Reparatur des seit `slice-166` mitgeschleppten Mutations-Befundes `221` trägt. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git show 78eaba5` (`cmd/ai-harness-init/main.go` +28/−8, `harness/README.md`, `test/unterkommando-kopplung.bats` +90/−33, `test/mutations/256`–`258` neu) und `git show 31e3ea8` (`test/mutations/221-ignore-refs-restbreite.sh` +14/−5) |
| **Runde 1** | [`2026-09-04-slice-175-schreibender-pfad-review.md`](2026-09-04-slice-175-schreibender-pfad-review.md) — 1 HIGH, 5 MEDIUM, 2 LOW, 2 INFO |
| **Runde 2** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-2.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-2.md) — 1 HIGH, 1 MEDIUM |
| **Runde 3** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-3.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-3.md) — 1 HIGH (Verdrahtung `echterEingang()`) |
| **Runde 4** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-4.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-4.md) — 1 HIGH (Bedien-Einstieg `Makefile:322`), 1 MEDIUM, 1 LOW |
| **Runde 5** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-5.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-5.md) — 0 HIGH, 2 MEDIUM, 1 LOW, 1 INFO |
| **Plan** | [`docs/plan/planning/in-progress/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/in-progress/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) (**`Accepted`**), [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md), [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.8, §3.9; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht und keiner aus den eigenen Reports der Runden 1–5 übernommen.** Jedes Rot und jedes Grün unten ist in dieser Sitzung selbst gefahren; das Kommando steht beim Befund. Wo eine Stufe **nicht** selbst gemessen wurde, steht das ausdrücklich dabei |

**Wie gemessen wurde.** Neun Sonden über einer **Kopie des Baums außerhalb des Repos**
(`tar --exclude=.git --exclude=.harness/state`), je mit `make test-bats`; dazu ein über
`make artifact DEST=…` aus derselben Kopie gebauter Träger, gefahren in einem leeren
Scratch-Verzeichnis; dazu ein vollständiger, selbst gefahrener `make mutate` über dem echten
Baum. Alle Läufe Docker-only über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9). Die Kopie ist
byte-gleich zum HEAD-Blob — `diff <(git show HEAD:<datei>) <kopie>` leer für
`test/unterkommando-kopplung.bats`, `Makefile`, `.claude/settings.json`,
`cmd/ai-harness-init/main.go`, `test/mutations/221-ignore-refs-restbreite.sh`, `.d-check.yml`
und `test/ignore-refs-restbreite.bats`. Die Messungen gelten für `31e3ea8`.

**Ausgangs-Lauf, unmutiert.** `make test-bats` über der Kopie: **211** `ok`, ein einziges
`not ok 127 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` — ein Artefakt der Kopie
ohne `.git`, kein Befund. Beide Kopplungs-Fälle grün: `ok 211` (Makefile) und **`ok 212`**
(`.claude/settings.json`, neu). Jedes Rot unten hebt sich gegen dieses Grün ab.

---

## Die neun Sonden dieser Sitzung

| # | Sonde | Ziel | Erwartet | Gemessen |
|---|---|---|---|---|
| A | `Makefile:322` → `@$(HOST_BIN) archive-welle "$(WELLE)" \|\| $(HOST_BIN) $(FALLBACK)` — **exakt die Form, die Runde 5 grün maß** | MEDIUM-1 | rot | **rot** — `not ok 211`, *„aus 5 Nennung(en) in der Makefile sind 4 Name(n) gewonnen"* |
| B | zweite Nennung in **anderer** Zeile: `272` → `@$(HOST_BIN) span-report && $(HOST_BIN) $(NACHLAUF)` | MEDIUM-1 | rot | **rot** — `not ok 211`, dieselbe Kalibrierungs-Meldung |
| C | eigener Vertipper (andere Form als `257`): `span-emit` → `spanemit`, alle drei Hooks | MEDIUM-2 | rot | **rot** — `not ok 212`, *„gibt dem Traeger 'spanemit', und main() dispatcht diesen Namen nicht"* |
| D | Unterkommando nur an **einem** der drei Hooks entfernt (`82s, span-emit,,`) | MEDIUM-2 | rot | **rot** — `not ok 212`, *„aus 3 Nennung(en) … sind 2 Name(n) gewonnen"* |
| E | `span-emit` → `span-emit2` in `.claude/settings.json` | Namens-Muster | ? | **grün** — `ok 211` **und** `ok 212`; s. MEDIUM-1 |
| E2 | `Makefile:322` → `archive-welle2` | Namens-Muster | ? | **grün** — `ok 211` und `ok 212`; s. MEDIUM-1 |
| F | die drei Hook-Kommandos durch `"true"` ersetzt (`ai-harness-init` kommt nicht mehr vor) | leeres Grün | rot | **rot** — `not ok 212`, *„nennt den Traeger nicht mehr in der Form, die dieser Fall liest"*; s. INFO-1 |
| H | `bash test/mutations/221-ignore-refs-restbreite.sh` in der **neuen** Fassung | Fall `221` | rot | **rot** — `not ok 120`, *„…MR-021-…md -> .harness/baseline/v3.5.2/…/modul-08-agentenrollen.md: 2 aufloesende Links, hoechstens 1 ist gedeckt"* |
| I | die **alte** Fassung von `221` (Anhang an `harness/conventions.md`) | Fall `221` | ? | **grün** — `ok 120`; der Defekt ist reproduziert |

Dazu am gebauten Träger, in einem leeren Verzeichnis:
`printf '{"session_id":"s","hook_event_name":"PreToolUse"}' | <dest>/ai-harness-init span-emit`
→ **Exit 0**; derselbe Aufruf mit `span-emit2` → **Exit 2**, Usage auf stderr, **null Bytes auf
stdout**, Verzeichnis danach leer.

Und der vollständige eigene Lauf: `make mutate` → **`244 ok, 0 Befund(e)`**, EXIT 0,
*„Vollstaendigkeit — 244 von 244 Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal gezogen"*
(Fall-Arbeit gesamt 3584,3 s). `221`, `253`, `254`, `255`, `256`, `257`, `258` je `OK`.
`git status --porcelain` davor und danach leer.

---

## Findings

### MEDIUM-1 — Das Namens-Muster schneidet am ersten Zeichen außerhalb `[a-z-]` ab; ein Unterkommando-Name, dessen Präfix ein gültiger `case` ist, bleibt ungekoppelt und beide Fälle grün

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — eine Zusage ist fertig, wenn
  benannt ist, was sie brechen ließe, und das rot gesehen wurde) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 6
- **pfad:** `test/unterkommando-kopplung.bats:49` (die Namens-Gewinnung) und `:84`/`:97` (die
  zwei Muster) · `harness/README.md:79` (die Zusage) · `cmd/ai-harness-init/main.go:521-524`
  (*„die zwei Formen, unter denen sie bricht"*)
- **befund:** Beide Fälle gewinnen den Namen mit `grep -oE '…[[:space:]]+[a-z][a-z-]*'`. Trägt
  der Name ein Zeichen außerhalb `[a-z-]` **hinter** einem vollständigen gültigen Namen, liefert
  das Muster den abgeschnittenen Präfix, die Kalibrierung bleibt ausgeglichen und die
  Dispatch-Schleife findet den `case` — für einen Namen, den kein Aufrufer nennt. **Gemessen,
  nicht abgeleitet:** `span-emit` → `span-emit2` in allen drei Hooks lässt `ok 211` **und**
  `ok 212` stehen (Sonde E), `archive-welle` → `archive-welle2` in `Makefile:322` ebenso
  (Sonde E2); der einzige `not ok` ist in beiden Läufen das bekannte `.git`-Artefakt der Kopie.
  Am gebauten Träger endet `span-emit2` mit **Exit 2** und der Usage auf stderr (oben gemessen)
  — am Hook-Kanal der Wert, mit dem ein Hook blockiert, und genau die Lage, die dieser Fall
  laut seinem eigenen Kopf *„im Gate, bevor … ein Hook feuert"* abfangen soll. Die Zusage in
  [`harness/README.md`](../../harness/README.md) — *„prüft, dass jeder Name, den ein Aufrufer
  dieses Repos hinter dem Träger nennt, im Dispatch von `cmd/ai-harness-init/main.go` einen
  `case` hat"* — reicht damit weiter als der Sensor, und der Satz in `main.go`, der die
  brechenden Formen mit **zwei** beziffert (`257`, `258`), ebenso. Kein zweiter Sensor deckt die
  Stelle: `shell-lint` führt weder `Makefile` noch `.claude/settings.json`
  (`Makefile:134-135`, selbst gefahren, Exit 0), `make comment-claims` hat beide dauerhaft
  außerhalb ([`AGENTS.md`](../../AGENTS.md) §4, selbst gefahren: *„55 Datei(en) geprueft, 0
  Befund(e)"*), und keine Go-Stufe öffnet die echte `.claude/settings.json` — die vier Go-Treffer
  (`internal/emit/enforce.go`, `enforce_test.go`, `erfassung_test.go`) lesen die **emittierte**
  Fassung im Temp-Baum bzw. die Vorlage.
- **verifizierbar:** ja — `span-emit` in `.claude/settings.json` zu `span-emit2` ändern, dann
  `make test-bats`; heute grün, erwartet rot. Dasselbe im `Makefile` mit `archive-welle2`.
- **klasse:** Sensor deckt nicht die Menge, über die seine Zusage spricht

### LOW-1 — Der Sensor-Kopf beziffert die Aufrufer-Menge dieses Repos mit zwei; gemessen nennen vier Dateien ein Unterkommando hinter dem Träger

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Abgrenzung* — beschrieben wird, was da
  ist) · Maintainability
- **pfad:** `test/unterkommando-kopplung.bats:2-11`
- **befund:** Der Kopf sagt *„Zwei Aufrufer nennen solche Namen, und nichts sonst verbindet sie
  mit dem Dispatch"* und listet `Makefile` und `.claude/settings.json`. **Gemessen** über den
  Index: `harness/tools/span-check.sh:104` nennt `span-emit` hinter `"$BIN"`, und
  `harness/tools/full-smoke.sh` nennt `add-lang` neunmal hinter `"$tmpbin/ai-harness-init"`
  (`git grep -nE '"\$(\{)?[A-Za-z_][A-Za-z_0-9]*(\})?(/ai-harness-init)?"[[:space:]]+(add-lang|span-emit|span-report|archive-welle)\b' -- 'harness/tools/*.sh' '.claude/hooks/*.sh'`).
  Beide sind gekoppelt — aber durch den **Lauf**, nicht durch diesen Fall, und die zwei Läufe
  stehen verschieden: `span-check` liegt in `make gates` (`Makefile:353` führt es in
  `record-gates`), `full-smoke` ausdrücklich nicht ([`AGENTS.md`](../../AGENTS.md) §4). Der Satz
  liest sich als gemessene Aussage über das Repo; wer die Aufrufer-Menge daraus nimmt, hält
  neun `add-lang`-Literale für gedeckt, deren einziger Wächter außerhalb der Gates liegt.
  Die entsprechende Aussage in [`harness/README.md`](../../harness/README.md) ist davon **nicht**
  betroffen — sie spricht über den *Prüfbereich* („zwei Aufrufer liegen in seinem Prüfbereich")
  und ist so richtig.
- **verifizierbar:** nein — kein Gate-Lauf bestätigt eine Mengen-Aussage in einem Kommentar;
  bestätigt ist sie durch das `git grep` oben.
- **klasse:** Mengen-Aussage in einem Kommentar ohne Messung

### INFO-1 — Die drei Erfassungs-Hooks sind mit diesem Commit Gate-Vorbedingung geworden; wer sie abschaltet, macht `make gates` rot

- **kategorie:** INFO
- **quelle:** [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Folgepflicht 3 (Spans
  sind bis zur Emission ein Dogfood-Werkzeug) · Maintainability
- **pfad:** `test/unterkommando-kopplung.bats:52-56` (der Nennungs-Null-Zweig) ·
  `.claude/settings.json:70`, `:82`, `:94`
- **befund:** Der Fall bricht ab, sobald `.claude/settings.json` den Träger nicht mehr nennt —
  **gemessen** (Sonde F): die drei Hook-Kommandos durch `"true"` ersetzt, `not ok 212`,
  *„nennt den Traeger nicht mehr in der Form, die dieser Fall liest — die Kopplung haette keinen
  Gegenstand und dieser Fall waere ein leeres Gruen."* Das ist als Schutz gegen leeres Grün
  gewollt und die Meldung sagt es. Undokumentiert ist die **Folge**: die Erfassung dieses Repos
  ist damit nicht mehr abschaltbar, ohne den Sensor anzufassen — weder
  [`harness/README.md`](../../harness/README.md) noch der Fall-Kopf nennt das.
- **verifizierbar:** ja — die drei `command`-Werte in `.claude/settings.json` ersetzen, dann
  `make test-bats`.
- **klasse:** Ein Fail-closed-Zweig macht einen optionalen Kanal zur Gate-Vorbedingung, ohne es
  zu nennen

---

## Negativbefunde — geprüft, ohne Befund

- **MEDIUM-1 aus Runde 5 ist geschlossen, an genau der Form, an der er entstand.** Sonde A ist
  die Zeile, die Runde 5 als grün maß; sie ist heute rot, und die Meldung zählt Vorkommen
  (*„aus 5 Nennung(en) … sind 4 Name(n) gewonnen"*), nicht Zeilen. Sonde B zeigt dasselbe an
  einer anderen Zeile, Sonde D an einer von drei Nennungen in einer anderen Datei. Beide
  Zählungen kommen jetzt aus `grep -oE … | grep -c .` (`:48`, `:50`). Kein Befund.
- **MEDIUM-2 aus Runde 5 ist geschlossen.** Der Hook-Kanal hat einen Wächter: Sonde C (eigener
  Vertipper, andere Form als der gelistete Fall `257`) färbt `not ok 212` und nennt den
  konkreten Namen samt heutigem Dispatch — sie ist lesbar, nicht nur rot
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Der Fall läuft in `make gates`: `record-gates` führt
  `test`, `test` führt `test-bats`, und im Ausgangs-Lauf steht er als `ok 212`. Der
  `GRENZE`-Absatz in `main.go:513-517` führt jetzt **zwei** Zweige vor der Klemme
  (`os.Getwd()` → Exit 1, Sperre in `run()` → Exit 2) statt einen. Kein Befund.
- **Die Reparatur von `221` trägt, und die Notwendigkeit ist belegt.** Sonde I fährt die alte
  Fassung (Anhang an `harness/conventions.md`) und lässt `ok 120` stehen — der Fall griff und
  der Wächter blieb grün. Sonde H fährt die neue Fassung und färbt `not ok 120` mit dem Paar,
  das `.d-check.yml:50-51` als `- in:` führt. Der zweite Verweis löst korrekt auf: aus
  `harness/conventions/` heraus normalisiert `../../harness/../.harness/baseline/…` auf dasselbe
  Ziel wie der eine vorhandene Verweis
  (`grep -n 'baseline/v3.5.2/regelwerk/modul-08-agentenrollen' harness/conventions/MR-021-…md`
  → **1** Treffer, Zeile 55) — 1 + 1 = 2 > 1. Kein Befund.
- **Die Reparatur ist auf ihre Klasse hin geprüft.** Kein weiterer Mutations-Fall hängt an einer
  Datei, die der Umzug aus [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md)
  bewegt hat: `grep -H '^# files:' $(grep -ln 'harness/conventions' test/mutations/*.sh)` liefert
  drei Fälle, deren `files:` auf `internal/emit/templates.go`,
  `harness/conventions/MR-021-…md` und `internal/span/emit.go` zeigen — nur `221` nannte den
  bewegten Ort. Kein Befund.
- **Der Bestand hat seine Zähne behalten.** Selbst gefahrener `make mutate` über dem echten
  Baum: **244 ok, 0 Befund(e)**, EXIT 0, Vollständigkeits-Zeile *„244 von 244 Fall-Dateien mit
  Ergebnis, jede Fall-ID genau einmal gezogen"*. Der lange mitgeschleppte Befund ist damit
  gemessen weg, und die drei neuen Fälle (`256`, `257`, `258`) melden je `OK` — der Treiber
  prüft dabei auch, dass der erwartete Wächter in der Fehlschlag-Ausgabe steht (Bedingung 4
  seines Kopfes), nicht nur, dass irgendetwas rot wurde. Kein Befund.
- **Der Host-Baum blieb unberührt.** `git status --porcelain` vor und nach dem `mutate`-Lauf
  leer; der Treiber meldet *„4 isolierte Kopie(n) unter /tmp/… — der Host-Baum wird NICHT
  veraendert"*. Kein Befund.
- **Die Scope-Aussagen des neuen Fall-Kopfes stimmen.** `make comment-claims` führt weder
  `Makefile` noch `.claude/settings.json` (Zielrezept `Makefile:140`: `internal/*.go`,
  `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`); `shell-lint`
  liest beide nicht (`Makefile:134-135`); keine Go-Stufe öffnet die echte `.claude/settings.json`
  (oben ausgeführt). Kein Befund.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8,
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
  `git show --name-only --pretty=format: 78eaba5 31e3ea8` trifft weder `AGENTS.md` noch
  `harness/conventions*`, weder `docs/plan/adr/` noch `docs/plan/planning/` noch
  `.claude/commands/`. Der fremde Befund `221` liegt in einem **eigenen** Commit, dessen Message
  ihn als solchen ausweist. Kein Befund.
- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2).
  `git diff c3aa8d1..HEAD | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'` leer,
  und `make shell-lint` — das `test/mutations/*.sh` einschließt — läuft mit Exit 0, obwohl Fall
  `256` ein maskiertes Dollar im Ersetzungsteil führt. Kein Befund.
- **Die neuen Kommentare tragen ihre Klasse und keine Chronik**
  ([`AGENTS.md`](../../AGENTS.md) §3.7). Die Blöcke stehen im Indikativ und nennen Zusage,
  Kopplung und Grenze; `git diff 2b1e5da..HEAD -- '*.go' '*.sh' '*.bats' 'Makefile' | grep -nE
  '^\+[[:space:]]*(#|//).*(Review-Befund|Runde [0-9]|MEDIUM-|HIGH-)'` ist leer. Die eine
  Herkunfts-Nennung im Fall `221` (*„Der Eintrag zeigt seit ADR-0032 auf den ausgelagerten
  MR-021-Rumpf"*) ist **ein** auflösbares Feld in der zulässigen Form. Kein Befund.
- **Der Arbeitsbaum ist übergabefähig.** `git status --porcelain` leer, `make docs-check` über
  dem echten Baum meldet **589 Datei(en), 0 Befund(e)**. Kein Befund.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, `make gates` als Ganzes,
`make full-smoke`, `make lint`, `make test-go`, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren Acceptance-Trigger
erreicht hat.

**Nicht neu geprüft, unverändert delegiert:** MEDIUM-5 aus Runde 1
(`.claude/commands/close-welle.md` nennt Schritt 4 als Handarbeit und das Ziel gar nicht —
**Planner**, [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)),
MEDIUM-3 und MEDIUM-4 aus Runde 2 (Zähler-Stand in §6/§8 des Slice-Plans; `Stand`-Zellen im
Beobachtungs-Register), LOW-1 aus Runde 4 (Deckungs-Grenze des Feldes `schreibend`) sowie
LOW-1 und INFO-1 aus Runde 5. Die zwei aus Runde 5 sind unberührt: der Diff fasst
`cmd/ai-harness-init/main_test.go` nicht an, und `Makefile:322` faltet die drei Exit-Codes
weiter auf einen.

**Nicht gefahren, aus dem Bestand gelesen:** die Stufen 1 bis 9 der Ketten-Tabelle aus Runde 5.
Dass ihre Fälle heute rot färben, ist in dieser Sitzung nur **mittelbar** gemessen — über den
`make mutate`-Lauf, der jeden von ihnen als `OK` meldet —, nicht einzeln nachgestellt.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 1 | Sensor deckt nicht die Menge, über die seine Zusage spricht |
| **LOW** | 1 | Mengen-Aussage in einem Kommentar ohne Messung |
| **INFO** | 1 | Ein Fail-closed-Zweig macht einen optionalen Kanal zur Gate-Vorbedingung, ohne es zu nennen |

**Geschlossen aus Runde 5:** MEDIUM-1 (Selbst-Kalibrierung) und MEDIUM-2 (Hook-Kanal), beide
hier mit eigenen Sonden nachgeprüft. **Zusätzlich geschlossen:** der fremde Mutations-Befund
`221`, mit reproduziertem Defekt davor.

**Warum MEDIUM-1 nicht HIGH ist.** Die HIGH-Anker der Skill-Datei nennen den *Stillen-Grün-Pfad
in einem Gate-Skript*, und unter den Sonden E/E2 ist der Fall genau das. Die Eskalation
unterbleibt aus demselben **gemessenen** Grund, den Runde 5 für ihren strukturgleichen Befund
nannte, und nicht aus Milde: der Restschaden bleibt durch die Sperre in `run()` begrenzt — der
Träger endet mit Exit 2 und schreibt nichts (oben am gebauten Binär gemessen: null Bytes stdout,
Verzeichnis danach leer). Was verloren geht, ist das Vorziehen ins Gate, nicht die Sperre selbst.
Wer diese Einschätzung nicht teilt, geht den Konflikt-Pfad aus Modul 8, nicht den Weg über die
Kategorie.

**Dritte Runde, dieselbe Klasse, jedes Mal enger.** Runde 4 fand den `Makefile` ungekoppelt,
Runde 5 die Kalibrierung über der falschen Zählgröße, Runde 6 das Namens-Muster über der
falschen Zeichenklasse. Das ist die Schwelle, an der die Skill-Datei *„Guide/Sensor nachziehen
statt nur melden"* verlangt — für die Closure §7 derselbe Vorgang und dieselbe Kennung
`BEO-025`. **Ob** der Zähler-Schritt fällt und was er auslöst, entscheidet die Closure und nicht
dieser Report
([`docs/plan/planning/observations.md`](../plan/planning/observations.md)).

---

## Verdikt

**Nicht freigegeben für die Verifikation** — knapp, aus einem MEDIUM.

- **Beide MEDIUM aus Runde 5 sind wirklich behoben, nicht nur behauptet.** Die exakte Form, die
  Runde 5 grün maß, ist heute rot (Sonde A); zwei weitere Formen derselben Klasse ebenso
  (B, D); der Hook-Kanal hat einen Wächter, der unter einem selbst erfundenen Vertipper fällt
  und dabei den Namen nennt (C); und der Wächter fällt auch, wenn ihm der Gegenstand ganz
  entzogen wird (F). Alle fünf in dieser Sitzung selbst gefahren, gegen einen unmutierten
  Ausgangs-Lauf mit `ok 211` und `ok 212`.
- **Die Reparatur des fremden Befundes `221` ist korrekt und vollständig.** Sie ist notwendig
  (die alte Fassung lässt den Wächter grün — selbst reproduziert), sie wirkt (die neue färbt ihn
  rot, mit dem Paar aus der Config und der richtigen Zahl), und sie ist die einzige ihrer Klasse
  (kein weiterer Fall nennt einen von [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md)
  bewegten Ort). Der selbst gefahrene `make mutate` schließt das ab: **244 ok, 0 Befund(e)**,
  jede Fall-ID genau einmal gezogen — zum ersten Mal über diesen Slice ohne offenen
  Mutations-Befund.
- **Was blockiert, ist eine Zusage, die weiter reicht als ihr Sensor.**
  [`harness/README.md`](../../harness/README.md) sagt *„jeder Name … einen `case`"*, und
  `main.go` beziffert die brechenden Formen mit zwei. Gemessen gibt es eine dritte: ein Name,
  dessen gültiger Präfix vom Muster gelesen und dessen Rest verschluckt wird, passiert beide
  Fälle grün — an beiden Aufrufern, und am Hook-Kanal mit dem Exit-Code, den
  [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 ausschließt. Nach
  [`AGENTS.md`](../../AGENTS.md) §3.6 schließt den Befund, was das Gegenbeispiel rot färbt —
  ein Sensor, der die Menge trifft, über die er spricht, **oder** eine Zusage, die nur noch sagt,
  was er hält. Welcher der beiden Wege gegangen wird, entscheidet nicht dieser Report.

**Was trägt.** Kein Kommentar trägt Chronik, kein fremdes Rollen-Artefakt ist berührt, keine
Lint-Suppression ist dazugekommen, der fremde Befund liegt in einem eigenen Commit mit eigener
Begründung, `comment-claims` meldet 55/0, `shell-lint` Exit 0, `docs-check` 589/0, der
Arbeitsbaum ist sauber, und `make mutate` ist über 244 Fälle grün.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation MEDIUM-1 mit dem Argument
bestreiten, die Form sei zu unwahrscheinlich, greift der Konflikt-Pfad aus Modul 8
§Konflikt-Pfad als Rollen-Sequenz (Reviewer → Architect → Verdikt als Artefakt); die
Herabstufung eines Findings, weil die Implementation widerspricht, ist dort ausdrücklich der
vierte, falsche Pfad. Das Gegenbeispiel ist ein Sensor, der rot wird — nicht eine Einschätzung.

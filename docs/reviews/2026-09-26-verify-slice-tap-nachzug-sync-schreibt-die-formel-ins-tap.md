# Verifikations-Report: slice-tap-nachzug-sync-schreibt-die-formel-ins-tap — 2026-09-26

**Rolle:** Verifier (Modul 11), frischer Kontext. Frage: *Bauen wir es richtig?* — gegen Plan, DoD, ADR und Hard Rules. Nicht der
Reviewer-Maßstab (Diff gegen Plan/ADR), nicht der Validator.

**Gegenstand:** Slice `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` (Kennung, nicht Pfad — der Plan wandert mit dem Lifecycle,
`AGENTS.md` §3.11). HEAD `c45140c1`, Baum sauber. Gemessen wird `git diff 3256c64d..HEAD` (11 Dateien, 844 Zeilen dazu, 98 weg).

**Constraint-Quellen gelesen:** Slice vollständig (Ziel, §1 Abgrenzung, §2 DoD, §3, §4, §6 mit offenen Fragen, §8) · `ADR-0064` komplett
(Festlegungen 1 bis 5, §Fitness Function, Folgepflichten, §Grenze) · `ADR-0066` · `harness/tools/tap-nachzug.sh` ·
`harness/tools/tap-nachzug-nutzlast.sh` · `test/tap-nachzug.bats` (Kopf, Stubs und alle `sync`-Fälle) · `Makefile` (Ziel `tap-nachzug`) ·
`harness/README.md` · `.d-check.yml` · `docs/user/releasing.md` Schritt 7 und 8 · `MR-071` · `AGENTS.md` §3 · der Review-Report
`2026-09-26-slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` (0 HIGH · 1 MEDIUM · 3 LOW · 3 INFO).

**Was der Review nicht gesehen hat:** die drei Commits nach ihm — `bb583255` (R-1/R-2/R-4: Header-Fall am PUT, Meldung nach erfolgtem
Schreiben, Fall 53 `sync teilerfolg`), `0d057bbe` (Anker von Mutations-Fall 418) und `c45140c1` (`docs/user/releasing.md`: R-2/R-3/R-6a).
Sie sind hier gegen eigene Läufe geprüft, nicht gegen den Report.

## 1. Eigene Läufe

Alle Läufe in Scratchpad-Kopien von `git archive HEAD` (kein `.git`), Docker-only im `BATS_IMAGE` des Makefiles
(`docker run --rm --network none -v <Kopie>:/code:ro … test/tap-nachzug.bats`), je Mutation eine frische Kopie. Kein Schreibzugriff im
Repo-Baum (`git status --short` vor und nach den Läufen: leer), kein Tap-Zugriff mit Schreibrecht, kein Token außer dem Sentinel der
Stubs, kein `make mutate`, keine Host-Toolchain.

| Lauf | Ergebnis |
|---|---|
| Kopie unverändert, `test/tap-nachzug.bats` | `1..53`, kein `not ok`; `grep -c '^@test' test/tap-nachzug.bats` → `53` |
| `env -u TAP_TOKEN make tap-nachzug TAG=v0.2.4` (Host, vor jedem Netz-Zugriff) | Prozess-Exit 2; Ausgabe nennt `TAP_TOKEN ist nicht gesetzt` und den Ausfallweg `make tap-nachzug TAG=<tag>`; `tap-sync: Exit 2` genau einmal (vorletzte Zeile, danach `make: *** … Fehler 2`) |
| `make tap-check TAG=v0.2.4` (lesend, Netz an diesem Aufruf) | Exit 0, `gleich`, Digest `ccc0a3db…` — das Tap trägt `v0.2.4` |
| `make tap-check TAG=v0.2.3` (lesend) | Prozess-Exit 2, `tap-check: Exit 1`, erste abweichende Zeile die `version`-Zeile (Zeile 11) — das Gegenstück des Vorfalls, Klasse 1 |
| 16 Schwächungen von `sync` (Tabelle 2) | alle 16 färben mindestens einen Fall rot, jede mit der Ursache, die die Meldung nennt |
| 6 Schwächungen der Grenze-Aussagen in Schritt 7 und des Makefile-Ziels (Tabelle 4) | alle färben die in der Prozedur genannten bzw. die zugehörigen Fälle |
| 4 Gegenproben „Zusicherung entfernen, Schwächung bleibt" | 4 von 4 bleiben grün — die Zusicherung bindet allein |
| 27 Mutations-Fälle des Bestands, die `tap-nachzug` berühren (`grep -l 'tap-nachzug' test/mutations/*.sh`), je am HEAD-Stand | alle 27: Anker trifft, Fall färbt mindestens einen Fall mit seinem `# expect:`-Text rot |
| `make docs-check` in vier Kopien (Tabelle 5) | Basis grün; Eintrag allein entfernt: grün; README-Zeile allein entfernt: grün; beides entfernt: rot |

`make tap-check` gegen `v0.2.4` liest das reale Tap lesend; ein Schreib-Pfad am realen Tap wurde nicht gefahren.

### Tabelle 2 — 16 Schwächungen von `sync` (Meldung gelesen)

`N` = `harness/tools/tap-nachzug-nutzlast.sh`, `K` = `harness/tools/tap-nachzug.sh`. „Trägt die Ursache": die Meldung bzw. die
fehlgeschlagene Zusicherung nennt genau die geschwächte Eigenschaft.

| Schwächung | roter Fall (Zeile der Assertion) | trägt die behauptete Ursache |
|---|---|---|
| Token-Nachweis am Host entfernt (`K`, Schritt b) | `sync fehlt-nachweis` (713, `docker_aufrufe`); die Nutzlast meldet den Fehlt-Fall selbst, aber der Container startete | ja — der Fall bindet *„vor docker"*, nicht nur *„Exit 2"* |
| Token-Nachweis in der Nutzlast entfernt (`N`, `sync_lauf`) | `sync fehlt-nachweis` (722, Direktaufruf der Nutzlast: Exit ≠ 2) | ja |
| Vorab-Regel: Metadatum nicht zuerst abgeschnitten (`K`) | `vorab-tag: die Regel des Skripts entscheidet dieselben Tags wie … publish` (354) | ja (Kopplung an `release.yml`) |
| Vorwärts-Schutz `-lt` → `-le` im dritten Feld (`N`) | `sync idempotenz` (764), `sync vorwaerts-schutz: … Gleichstand` (805); Meldung *„Vorwärts-Schutz: der Tag v0.2.3 ist älter als der Tap-Stand 0.2.3"* | ja |
| Vorwärts-Schutz lexikografisch (`sort`) statt numerisch je Feld (`N`) | `sync vorwaerts-schutz` beide Fälle (782, 798); Meldung *„Tag v0.2.10 ist älter als der Tap-Stand 0.2.9"* | ja |
| Blob-Stand `000…0` statt der Bytes des ersten Lesens (`N`) | `sync optimistisch` (887) | ja |
| 409: zweiter Schreibaufruf vor der Meldung (`N`) | `sync token` (842), `sync optimistisch` (893), `sync abgelehnt` (912) — `schreibaufrufe` = 2 | ja |
| Nachkontrolle entfernt (`if vergleiche` → `if true`, `N`) | `sync nachkontrolle` (935: Exit 0 statt 1), `sync teilerfolg` (960) | ja |
| Token als `-H "$(cat "$hdr")"` in der Argumentliste des Schreibens (`N`) | `sync token` (844, Sentinel in `STUB_LOG_CURL`) | ja |
| Antwort der Schnittstelle im `*)`-Zweig auf stderr (`N`) | `sync token` (843, Sentinel in `$output$stderr`, Fund im Fall *Serverfehler 500*) | ja |
| Schreibaufruf ohne `-H "@$hdr"` (`N`) | `sync token` (850, `STUB_LOG_HDR_PUT` leer) | ja — die Schwächung, die im Review überlebte (R-1), färbt jetzt |
| `nicht_lesbar` ohne Zweig für `geschrieben=ja` (`N`) | `sync teilerfolg` (962, *„das Schreiben ist bereits erfolgt"* fehlt; die Meldung sagt *„es wurde nichts verglichen"*) | ja |
| `geschrieben=ja` → `geschrieben=nein` (`N`) | `sync teilerfolg` (962) | ja |
| Wortlaut *„bereits erfolgt"* → *„gelaufen"* (`N`) | `sync teilerfolg` (962) | ja |
| Meldung nach erfolgtem Schreiben trägt zusätzlich *„es wurde nichts verglichen"* (`N`) | `sync teilerfolg` (965, `nirgends 'nichts verglichen'`) | ja |
| Idempotenz: `sync_lauf` vergleicht nie „gleich" (`if gleich` → `if false`, `N`) | `sync idempotenz` (765, `gleich` fehlt in der Ausgabe) | ja |

### Tabelle 3 — Gegenproben („grün heißt bindet")

Assertion durch `true` ersetzt, Schwächung bleibt; **grün** heißt: die Assertion bindet allein, kein zweiter Fänger.

| Schwächung | entwaffnet | Ergebnis |
|---|---|---|
| Blob-Stand `000…0` | 887 und 894 (`sync optimistisch`) | **grün** — die beiden Zeilen binden den Blob-Stand allein |
| Schreibaufruf ohne Header | 850 (`STUB_LOG_HDR_PUT`) | **grün** — die Zeile bindet den Header am PUT allein (die Zeilen 847/848 sehen die Lese-Aufrufe) |
| Antwort im `*)`-Zweig auf stderr | 843 (`$output$stderr`) | **grün** — bindet allein; `nirgends` in 844 liest nur Protokolle und Body |
| Wortlaut *„bereits erfolgt"* → *„gelaufen"* | 962 | **grün** — die Zeile bindet den Wortlaut allein |

Redundanz statt Lücke, ebenfalls gemessen: `nicht_lesbar` ohne den `geschrieben`-Zweig färbt auch bei entwaffneten 962 **und** 965 weiter
(Zeile 963, `make tap-check TAG=…` steht nur in der Meldung nach dem Schreiben); die Nachkontrolle entfernt und 935 entwaffnet färbt
weiter (936, Fall 53); der zweite Schreibaufruf bei entwaffneter 893 färbt weiter (842, 894, 912). Das ist ein zweiter Fänger, keine
fehlenden Zähne — die Wortlaut-Schwächungen (*„gelaufen"*, *„nichts verglichen"* zusätzlich) färben je genau eine Zeile.

### Tabelle 4 — Grenze-Absatz von Schritt 7 und Makefile-Ziel

| Schwächung | Ergebnis |
|---|---|
| `check`/`sync` teilen `gleich()`; „größere Tap-Version gilt als gleich, wenn **mindestens zwei** Zeilen abweichen (numerisch je Feld)" | **alle 53 Fälle grün** — die Aussage der Prozedur *„keiner der `53` Fälle wird von ihm rot"* ist bestätigt |
| dieselbe Schwächung, schon bei **einer** abweichenden Zeile (Lebendigkeits-Probe: der Code wirkt) | `check liest keine Version` (324) rot — die Schwächung ist scharf; die Prozedur sagt zu Recht, dass dieser Fall die Einzeilen-Form bindet |
| „kleinere Tap-Version gilt als gleich" | neun Fälle rot, darunter die drei, die die Prozedur nennt: `vorfall nachgestellt`, `exit-zeile`, `unterschied` |
| „bei ungleichen Bytes gilt eine gleiche `version`-Zeile als gleich" | sechs Fälle rot, darunter die fünf, die die Prozedur nennt: `vergleich verschieden`, `vergleich byte-genau`, `cache-fenster: erst alt`, `cache-fenster: beide Male alt`, `cache-fenster: die Wartezeit` |
| `TAG=$(TAG)` bzw. `TAP_TOKEN=$(TAP_TOKEN)` in der Rezeptzeile von `tap-nachzug` | `uebergabe ohne text: die Rezeptzeilen von tap-nachzug …` (419 bzw. 421) rot |
| `tap-nachzug` als Prerequisite von `gates` bzw. von `record-gates` | `kein gate: …` (431) rot |

### Tabelle 5 — `make docs-check` (Liefer-Punkt 2)

| Kopie | Exit | Ergebnis |
|---|---|---|
| unverändert | 0 | `1937 Datei(en) geprüft, 0 Befund(e)` |
| Eintrag `tap-nachzug` aus `targets.exempt-targets` entfernt, README-Zeile bleibt | **0** | 0 Befunde |
| README-Zeile `make tap-nachzug` entfernt, Eintrag bleibt | **0** | 0 Befunde |
| beides entfernt | 2 | 1 Befund: `Makefile:512 tap-nachzug gate-undocumented — Makefile-Regel ohne Deklaration in der Autoritäts-Doku harness/README.md` |

## 2. Verdikt je DoD-Punkt

### Liefer-Punkt 1 — der Modus `sync`: **bestätigt**, Zusage auf die nachgebildete Schnittstelle eingeschränkt, wie die DoD sie fasst

- Jede in der DoD genannte Zeile der Fitness Function von `ADR-0064`, die `sync` betrifft, hat einen Fall: Tap ohne Formel-Datei (404) →
  `sync: ein Tap ohne Formel-Datei …` · `sync` liest bis zum Schreiben einmal → `sync wiederholt das Lesen … nicht` · Idempotenz →
  `sync idempotenz` · Vorwärts-Schutz kleiner/größer/Gleichstand, numerisch je Feld → `sync vorwaerts-schutz` (zwei Fälle) · Lesbarkeit
  der `version`-Zeile (fehlt, mehrfach, außerhalb der Feldform, `0.2`, `0.2.3.4`, `0.2.`, leer) → `sync version-zeile`, in `check` kein
  Gegenstand → `version-zeile: in check …` · Fehlt-Nachweis vor Vorab-Regel und Netz → `sync fehlt-nachweis` (vier Kombinationen) ·
  Vorab-Tag → `sync vorab-tag` · Token nie in Kommandozeile/Ausgabe (Erfolg, 409, 401, 500, keine Antwort), Kopfdatei 0600 und danach
  entfernt → `sync token` · geschriebene Bytes → `sync schreiben` · Optimistik → `sync optimistisch` · ausdrücklich abgelehnt gegen
  ungewiss → `sync abgelehnt` · Nachkontrolle → `sync nachkontrolle` · **Teilerfolg** (nicht in der Fitness Function der ADR, im Review
  als R-2 verlangt) → `sync teilerfolg`.
- Jeder dieser Fälle wurde in Tabelle 2 durch mindestens eine Schwächung rot gesehen, die Meldung gelesen; Exit-2-Zusagen prüfen auch die
  Meldung (Fälle 40, 45, 47, 51, 53 lesen den Text). Vier Zähne binden nachweislich allein (Tabelle 3).
- Die Exit-Zeile `tap-sync: Exit <N>` steht bei Exit 1 und 2 genau einmal, bei Exit 0 nicht (gelesen in den Läufen; Fälle 40, 45, 47, 51,
  52, 53 zählen `exit_zeilen`).
- Die Commit-Message des Nachzugs nennt den Tag und sagt keine Digest-Prüfung zu (Fall 49, Zeilen 872 bis 877); die Ausgabe der Läufe
  trägt Tag und Digest.
- **Rot-Beleg am realen Zustand, lesend:** `env -u TAP_TOKEN make tap-nachzug TAG=v0.2.4` endet mit Prozess-Exit 2, nennt den Ausfallweg,
  trägt `tap-sync: Exit 2`; `make tap-check TAG=v0.2.4` endet mit Exit 0. Dass **kein Container startete**, ist aus der Reihenfolge im
  Skript geschlossen (Schritt b steht vor `docker run`) und durch die Schwächung *„Token-Nachweis am Host entfernt"* belegt — dort startet
  der Stub-`docker` und der Fall wird rot (`docker_aufrufe`); ein Container-Zähler am realen Lauf wurde nicht gemessen.
- **Was nicht bewiesen ist und nirgends behauptet wird:** der Schreib-Pfad am realen Tap. Die Fälle laufen gegen einen `curl`-Stub, die
  Nutzlast läuft im `sh` des `bats`-Bildes, nicht im digest-gepinnten Transport-Bild; der erste reale Nachzug des Auftraggebers ist der
  Beleg (§Grenze der ADR). Die Einschränkung steht im Kopf von `test/tap-nachzug.bats`, in der README-Zeile und in Schritt 7.

### Liefer-Punkt 2 — das Ziel `make tap-nachzug` und seine drei Träger: **bestätigt mit Vorbehalt** (DoD-Wortlaut zu `docs-check`, Befund V-1)

- Rezept: `@bash harness/tools/tap-nachzug.sh sync`, ohne make-Referenz auf Tag und Token; `.PHONY` trägt das Ziel; keine
  Prerequisite-Kette, nicht in `gates`/`record-gates` (Tabelle 4: beide Schwächungen färben Fälle 20/21 bzw. 21).
- Kommentar nach `ADR-0066` Folgepflicht 1: nennt Netz, Token, den Exit des **Skripts** samt Ebene, die Zeile `tap-sync: Exit <N>`, ihre
  Position mit Bedingung (*bei `make <ziel>` aus dem Wurzelverzeichnis die vorletzte Zeile*), die Nicht-Zusage bei Signal **mit** der
  Aussage, dass dort auch die Klasse fehlt.
- README-Zeile in §Werkzeuge trägt `kein Gate` und Bindung (`ADR-0064`, `ADR-0066`); `targets.exempt-targets` führt `tap-nachzug`
  exakt (Zeile 193 der `.d-check.yml`).
- Die Zahl im Kommentar der `.d-check.yml`: *„17 von 21"* — gemessen über die 21 genannten Ziele, die `## `-Hilfetext mit *„NICHT in
  gates"* tragen: 17; die vier ohne (`span-clean`, `doc-immutable`, `doc-commits`, `record-gates`) sind die im Kommentar genannten.
- **Vorbehalt:** die DoD sagt *„`make docs-check` färbt sich in beiden Fällen"*. Gemessen färbt sich das Gate nur, wenn **beide** Träger
  fehlen (Tabelle 5); jeder der beiden allein lässt es grün, weil README-Zeile und Eintrag einander als Deklaration genügen. Was
  gebaut ist, ist richtig und vollständig; der Sensor deckt die Zusage nur als Paar. Übergabe an den Planner (V-1).

### Liefer-Punkt 3 — der Umbau von Schritt 7: **bestätigt**

- Die vier alternden Aussagen sind gezogen: `grep -nE 'Handgriff|einzige Tap-Ziel|Bytes, keine Versionen|allein bei der Vorbedingung'
  docs/user/releasing.md` → 0 Treffer. Das Kommando `grep -ci version …` steht als Beleg der Eigenschaft nicht mehr da, sondern als
  Gegenbeispiel: `1` (Host-Skript, ein Wort im Kopfkommentar, `grep -ni version harness/tools/tap-nachzug.sh` → Zeile 18) und `11`
  (Nutzlast); die Begründung ist damit auf die Nutzlast beschränkt (R-3 des Reviews gezogen).
- **Jede Wiedergabe gegen Skript und Läufe gefahren:** `gleich`/`nachgezogen` mit Tag und Digest (Läufe, Fälle 44/49) · `Vorab-Tag, Tap
  bleibt` · `Formel-Unterschied nach dem Schreiben` mit beiden Digests (Fall 52) · `TAP_TOKEN ist nicht gesetzt` · `Vorwärts-Schutz`
  · `Schreiben abgelehnt` mit `Tap unverändert` für HTTP 401, 403, 409 · `Ausgang des Schreibens ungewiss` mit `make tap-check
  TAG=<tag>` für *„keine Antwort oder eine andere Antwort als 200, 401, 403 und 409"* (Fall 51 fährt 000, 500, 502, 201, 204, 404, 422,
  429) · `das Schreiben ist bereits erfolgt` mit dem Verweis auf `make tap-check` bei einer Nachkontrolle mit 404 oder ohne Antwort (Fall 53
  fährt 404, 401, 403, 429, 500, 000). Jede genannte Meldung steht im Skript (`grep -c` je Wortlaut ≥ 1). Kein Fehler der Wiedergabe
  gefunden.
- **Die Zahl `53`** steht neben `grep -c '^@test' test/tap-nachzug.bats` → `53`. **Die R-7-Aussage** (*„nicht gebunden … keiner der 53
  Fälle wird von ihm rot"*) ist mit der Wortlaut-Schwächung gefahren und bestätigt (Tabelle 4: zwei Zeilen abweichend → alle grün;
  eine Zeile → Fall 13 rot). Die Bindungs-Aussagen darüber (kleinere Version; gleiche `version`-Zeile bei ungleichen Bytes) stimmen mit
  den gefahrenen Fällen überein, Fall für Fall.
- **Zustandsform:** keine Chronik, keine Konjunktive über verworfene Alternativen, keine Klon-Pfade, kein Lauf-Protokoll. Das Wort *Rolle*
  steht einmal, negativ: *„die Prozedur nennt keine ausführende Rolle"* — eine Rolle wird nirgends als Ausführende benannt (DoD:
  *„keine Rolle als Ausführende"*, §6 Frage 1).
- **Nummerierung:** Schritt 7 bleibt Schritt 7; die Nennungen in `docs/user/releasing.md` (Schritt 1, 3, 4, 5, 6, 7, 8) stimmen;
  `grep -rn 'releasing.md#'` in lebenden Artefakten → keiner (nur Zeitdokumente).
- **Zusagen auf die nachgebildete Schnittstelle eingeschränkt:** der Absatz *Handlung* trägt seit `c45140c1` den Satz *„der Schreib-Pfad
  ist gegen eine nachgebildete Schnittstelle belegt, am realen Tap belegt ihn erst ein realer Nachzug"* (R-6a gezogen); der erste reale
  Nachzug wird nicht vorweggenommen.

### Übrige DoD-Punkte (Closure-Pflichten)

`make gates`: Stempel gedeckt am HEAD laut Eingang (nach diesem Report neu gefahren, siehe unten). Review durchgeführt: der Report liegt
vor, Runde 1; die Folge-Commits danach hat kein Reviewer gelesen (siehe oben). Closure-Notiz, Register, Risiko-Ausgänge, Paarungen,
Handbuch-Vermerk: **Planner-Arbeit** (`AGENTS.md` §3.10), hier nicht geprüft und nicht bewegt.

## 3. Befunde

Klassen nach dem Modul-11-Maßstab: *DoD-Verletzung* (Wortlaut trägt nicht) · *Deckung* (Zusage breiter als ihr Sensor) ·
*Plan-vs-Code*. Kein HIGH.

**V-1 — DoD-Wortlaut zu Liefer-Punkt 2 · Klasse: Deckung / DoD-Wortlaut · Schwere: MEDIUM (Abnahme-Formulierung, Code richtig).**
DoD: *„`make docs-check` färbt sich in beiden Fällen (`targets`); die Gegenprobe ist, den Eintrag testweise zu entfernen und die Meldung
zu lesen."* Gemessen (Tabelle 5): ein entfernter Eintrag **allein** lässt das Gate grün (Exit 0, 0 Befunde), eine entfernte README-Zeile
allein ebenfalls; rot wird es erst, wenn beide fehlen, mit dem Grund `gate-undocumented` (Richtung 1 des Moduls). Die DoD-Gegenprobe
liefert damit kein Rot. Die Zusage ist breiter als der Sensor. Die Formulierung liegt beim Planner (die ausführende Rolle schreibt ihr
Abnahmekriterium nicht um, `AGENTS.md` §3.10); die Aussage in `ADR-0064` Folgepflicht 1 (*„ohne Eintrag färbt das Doku-Gate im ersten
Lauf rot"*) trägt in diesem Repo ebenfalls nur, solange die README-Zeile fehlt — die ADR ist `Accepted` und wird nicht angefasst
(`AGENTS.md` §3.4); ob das eine Schärfung braucht, urteilt der Architect.

**V-2 — Wortlaut *„Die Wächter von `sync` tragen `bats`-Fälle und keinen Fall in `test/mutations/`"* (Schritt 7, Absatz *Grenze*) ·
Klasse: Deckung · Schwere: INFO.** Wörtlich wahr (`grep -ln 'sync' test/mutations/*.sh` → keine Datei), aber die Fälle für gemeinsame
Wächter färben `sync`-Fälle mit: gemessen färbt 452 zusätzlich `sync vorwaerts-schutz: ein groesserer Kern`, 411 `sync nachkontrolle`,
416 `sync token`, 428 und 433 `sync fehlt-nachweis`, 432 `sync idempotenz` und `sync schreiben`. Die **`sync`-eigenen** Wächter (Vorwärts-Schutz,
Feldform der `version`-Zeile, Idempotenz-Zweig, Blob-Stand, Nachkontrolle, Header am PUT, Fehlt-Nachweis) sind ungelistet, wie §1 des Plans
sagt. Kein Rot; ob *„die Wächter von `sync`"* auf *„die `sync`-eigenen"* schärfer zu fassen ist, entscheidet der Planner beim Nachzug
der Prozedur.

**V-3 — Schritt 7, Vorab-Satz · Klasse: Plan-vs-Code, klein · Schwere: INFO.** *„Für einen Vorab-Tag entfällt der Nachzug"* ist mit
`sync` ohne `TAP_TOKEN` **nicht** wahr — Schritt b geht Schritt c voraus (Exit 2, gebunden durch `sync fehlt-nachweis`, auch für
`v1.0.0-rc.1`). Der unbedingte Satz zwei Absätze darüber (*„Ohne `TAP_TOKEN` endet der Aufruf mit Exit 2 vor jedem Netz-Zugriff"*) deckt
den Fall; ein Leser, der nur den Vorab-Satz liest, erfährt es nicht. Reviewer-Beobachtung R-6c, unverändert.

Keine weiteren Abweichungen der Wiedergabe gegen das Skript gefunden.

## 4. Plan-vs-Code-Diff

**Geplant und gebaut:** alle sieben Zeilen von §3 des Plans (`harness/tools/tap-nachzug.sh`, `harness/tools/tap-nachzug-nutzlast.sh`,
`test/tap-nachzug.bats`, `Makefile`, `harness/README.md`, `.d-check.yml`, `docs/user/releasing.md`); keine der drei Liefer-Punkte
fehlt. Die Fälle der Fitness Function von `ADR-0064` für `sync` stehen vollständig.

**Gebaut, nicht (im §3 des Plans) geplant:**

- `docs/plan/planning/in-progress/roadmap.md`: drei Zeilen — der Ruhe-Marker *„Nichts in Arbeit"* ist entfernt (Commit der Beanspruchung).
  Notwendige Folge des Zustands: das Modul `planning` des Doku-Gates koppelt den Marker an `in-progress/`
  (`.d-check.yml`, Modul `planning`); beim Schließen geht der Marker zurück (Übergabe, Abschnitt 5).
- `test/mutations/418-tap-check-lesefehler-ist-unterschied.sh`: eine Zeile — der Anker folgt dem neuen Hilfsaufruf `nicht_lesbar`.
  Nicht in §3, aber notwendig: der alte Anker trifft nicht mehr (`grep -c 'fehler "Tap nicht lesbar (HTTP'` → 0, der neue → 1); `make
  mutate` fiele sonst unter Bedingung 2 von `harness/tools/mutate.sh` (Mutation ändert die Datei nicht → Befund). **MR-071:** der neue Anker ändert genau eine Zeile (gemessen), färbt zwei
  Fälle (5 und 53) und trägt den `# expect:`-Text. §1 des Plans schließt Mutations-Fälle **für `sync`** aus; das hier ist die Pflege eines
  bestehenden `check`-Falls, kein neuer Fall.
- Der Hilfsaufruf `nicht_lesbar` und der Zustand `geschrieben` in der Nutzlast samt Fall 53: Folge von Review R-2, im §3 nur als
  *„Unterscheidung abgelehnt gegen Ausgang ungewiss"* angelegt, nicht als Meldung nach einem erfolgten Schreiben. Die Erweiterung ist
  klein, gebunden (Tabelle 2) und liegt innerhalb von Liefer-Punkt 1.

**Geplant, nicht gebaut:** nichts. **Abgrenzung §1 eingehalten:** kein Release-Job (`git diff 3256c64d..HEAD --stat` nennt keine Datei
unter `.github/`), keine Umgebung und kein Secret, kein Schreibzugriff aufs Tap, kein Handbuch, keine Änderung an einer ADR
(`git diff 3256c64d..HEAD --stat -- docs/plan/adr` → leer), kein eingefrorenes Zeitdokument umgeschrieben (nur der Review-Report ist neu),
keine Rolle und kein Klon-Pfad in der Prozedur. Kein Mutations-Fall für `sync` (Folge-Schnitt ohne Kennung, §1).

**Größe:** drei Liefer-Punkte (≤ 3), zwei Schichten (Werkzeug, Nutzer-Doku; die Roadmap-Zeilen sind Zustandspflege). Der Review hat den
Diff in einer Runde getragen (Risiko *„zu groß für eine Sitzung"*: kein Anzeichen eingetreten); die Nach-Review-Commits umfassen
`test/tap-nachzug.bats` (Fall 53 und der Header-Nachweis in `sync token`), die Nutzlast (`nicht_lesbar`), eine Zeile in Fall 418 und den Text von Schritt 7.

## 5. Übergaben

### An den Planner

1. **DoD-Wortlaut zu `docs-check` (V-1):** zwei Träger, die sich gegenseitig decken; das Rot entsteht erst beim Ausfall beider. Ob der
   Wortlaut auf *„färbt sich, wenn beide fehlen"* zu schärfen ist oder ob der Slice mit dem Befund schließt, urteilt der Planner. Klassen-
   Kandidat für das Register: *Zusage über zwei redundante Träger — der Sensor färbt nur bei Ausfall beider* (ob ein Nachbar-Beleg
   besteht, ist beim Schreiben des Belegs zu lesen; hier nicht nachgeschlagen).
2. **§6-Risiko-Ausgänge — Fakten, Zuweisung beim Planner:**
   - *zu groß für eine Sitzung:* der Review lief in einer Runde, 0 HIGH; Kandidat *entfallen*. Vorbehalt: die Nach-Review-Commits hat
     nur dieser Lauf gelesen.
   - *Schreib-Pfad nur gegen nachgebildete Schnittstelle:* unverändert; Kandidat *weiter offen* (`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`,
     verkörpert in `AGENTS.md` §3.6); Beleg ist der erste reale Nachzug.
   - *`sync` ohne Mutations-Fälle:* 16 Schwächungen und vier bindende Gegenproben gemessen, **0** Mutations-Fälle mit `sync`-Bezug;
     Kandidat *weiter offen* (`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`); der Folge-Schnitt ist noch ohne Kennung
     (§1).
   - *Ein Lauf schreibt ins reale Tap:* kein Lauf hat es getan — dieser Lauf las nur (`make tap-check`) und rief `make tap-nachzug`
     ohne Token auf (Exit 2 vor Netz). Kandidat *entfallen*.
   - *Schritt 7 wird mit dem Job-Schnitt erneut falsch:* **Adresse ohne Datei, damit sie im Eingang des Laufs steht, der den Job-Slice
     schneidet:** Schritt 7 ist heute die Handlung von `make tap-nachzug`. Beim Job-Schnitt wird die Handlung der Job `tap`, das Ziel der
     lokale Ausfallweg, und die Meldung in Schritt 8 hängt weiter an `make tap-check`; die vier Aussagen, die dann altern, sind absehbar
     die Handlung (*„`make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers"*), die Voraussetzung (*„Token mit
     Schreibrecht"*), der Satz zur Rolle (*„die Prozedur nennt keine ausführende Rolle"*) und der Absatz *Grenze* zu den Wächtern von
     `sync`. Träger ist allein §1 dieses Slice; ein Sensor besteht nicht (`BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet`).
3. **Register-Belege / Klassen-Kandidaten (Urteil beim Schreiben des Belegs):**
   - `BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle` (2×): der Review fand R-3 (Wortzähler-Begründung);
     dieser Lauf fand in der Wiedergabe der Klassen und Meldungen keinen weiteren Fehler; V-2 ist ein möglicher Nachbar.
   - `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor` (2×): Schritt 7 ist wieder eine Prozedur-Zeile ohne Sensor — die DoD nennt es
     selbst; in diesem Lauf waren Review und Verifier der Träger, kein Test liest die Prozedur.
   - `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`: unverändert offen (§6 Frage 1); Schritt 7 nennt keine
     Rolle, dieser Lauf schrieb nicht ins Tap. Kein weiterer Beleg aus diesem Lauf.
   - Review-Klassen: R-1 (*Header-Zusage nicht an die Methode gebunden*) und R-2 (*Meldung nach Teilerfolg*) sind behoben und gebunden
     (Tabelle 2: Zeilen 850 bzw. 962/965).
4. **Trigger-Audit der ADR-Klasse für `ADR-0066`, dritter Re-Evaluierungs-Trigger — Fakten, Verdikt beim Architect:** die Nutzlast beendet
   mit genau drei Status: `exit 0` (gleich; nachgezogen; Nachkontrolle gleich), `exit 10` (Unterschied, auch die Nachkontrolle nach dem
   Schreiben) und `beende 2` (nicht ausführbar, mit interner Fehler-Abbildung auf 2) — `grep -nE '\bexit (0|10|2)\b|beende 2'
   harness/tools/tap-nachzug-nutzlast.sh`; `sync` führt **keinen** vierten Status ein, und die neuen Ausgänge (Vorwärts-Schutz,
   Ablehnung, *ungewiss*, *bereits erfolgt*) sind Status 2 mit eigener Meldung. Das Host-Skript bildet unverändert 0, 10, alles andere →
   2. Produktiver Leser der Nutzlast: allein `harness/tools/tap-nachzug.sh`; `test/tap-nachzug.bats` und die `check`-Fälle in
   `test/mutations/` rufen sie direkt (Test-Leser; neu ist der Direktaufruf in `sync fehlt-nachweis`, der Status 2 liest). Ein zweiter
   produktiver Aufrufer besteht nicht. Ob damit eine der beiden Bedingungen des Triggers eintrat, sagt der Architect.
5. **Ruhe-Marker:** der Marker in der Roadmap ist entfernt, solange der Slice in `in-progress/` liegt; beim Schließen (`in-progress/` leer)
   ist er zurückzusetzen — das Modul `planning` des Doku-Gates hält beide Richtungen.
6. **Die bleibende Eigentums-Frage:** §6 Frage 1 ist unverändert offen; Schritt 7 stützt sich auf keine mündliche Erlaubnis.
7. **Handbuch (Weg C):** die Nutzer-Doku sagt *„sie wird je Release-Schnitt aus dem Formel-Asset desselben Schnitts nachgezogen"* und ist
   unverändert. Wahr ist das mit dem Ziel nur als Handlung des Aufrufers, mit dem Job als Regelweg (§1, Folge-Schnitt). Vermerk in §7 ist
   Closure-Arbeit.
8. **Nach-Review-Commits:** `bb583255`, `0d057bbe`, `c45140c1` hat kein Reviewer gelesen; dieser Bericht deckt sie mit eigenen Läufen ab
   (Tabellen 2 bis 4). Ob eine zweite Reviewer-Runde nötig ist, urteilt der Planner; der Verifier findet keinen HIGH.

### An den Architect

1. **Zuordnung der Antworten der Schnittstelle beim Schreiben (offene Frage 2, Verdikt bleibt beim Architect).** Gemessen: 200 →
   Nachkontrolle; **401, 403, 409** → *„Tap unverändert"*; keine Antwort und **jeder andere** Status (500, 502, 201, 204, 404, 422, 429)
   → *„Ausgang des Schreibens ungewiss"* mit `make tap-check TAG=<tag>`; alle Klasse 2 (Fall 51 fährt beide Listen; Schwächungen J/J2 des
   Reviews). Gegen `ADR-0064` Festlegung 3 gelesen: *„Tap unverändert"* sagt das Werkzeug nur bei den drei Codes, die die ADR mit
   *Anmeldung, Schutz, Konflikt* meint — keine Aussage über einen nicht vollzogenen Schreibvorgang bei einem anderen Code, keine
   stille Grün-Meldung; die Zuordnung überschreitet die ADR damit **nicht** in der Zusage. Sie **erweitert** aber den Begriff *ungewiss*
   über *„ohne Antwort"* hinaus auf Antworten mit anderem Status (sichere Richtung, Klasse gleich); ob 404, 422, 429 oder alle 4xx nach
   *„unverändert"* wandern dürfen und ob ein Schutz des Branches ohne festen Code eine eigene Ursache bekommt, trägt die ADR nicht.
2. **ADR-Lücke: die Meldung der Nachkontrolle nach erfolgtem Schreiben.** Die Tabelle in `ADR-0064` Festlegung 2 ordnet ein unlesbares
   Tap Klasse 2 zu; dass die Meldung **nach einem vollzogenen Schreiben** das sagen muss (*„das Schreiben ist bereits erfolgt (HTTP 200)
   … ob das Tap die Bytes des Assets trägt, ist unbekannt"*), steht in keiner Festlegung. Implementiert und gebunden (Fall 53, Tabelle 2);
   ob die ADR es aufnimmt (Folge-ADR mit `Supersedes`) oder die Prozedur genügt, urteilt der Architect.
3. **`ADR-0064` Folgepflicht 1, Satz *„ohne Eintrag färbt das Doku-Gate im ersten Lauf rot"*:** gemessen wahr nur, wenn auch die README-Zeile
   fehlt (V-1). Kein Änderungsauftrag; Fakt für die Schärfung, falls der Architect eine für nötig hält.
4. **Trigger-Audit `ADR-0066`, dritter Trigger:** Fakten in Abschnitt 5, Übergabe Planner Nr. 4.

## 6. Ehrlich: was nur gelesen und was nicht gemessen ist

- **Nur gelesen:** die Blob-Formel im realen Transport-Bild (der Review hat sie am Bild gemessen; dieser Lauf hat sie nicht wiederholt);
  die Wortlaute von `ADR-0064` und `ADR-0066` (kein Lauf); die Handbuch-Zeile von Weg C; die Job-Form in `release.yml` (nicht Gegenstand).
- **Nicht gemessen:** ein Schreib-Pfad am realen Tap (kein Token, kein Schreibzugriff — Absicht, `ADR-0064` §Grenze); die reale Form der
  Schnittstellen-Antworten für 404, 422, 429 beim Schreiben; `curl`-Zeitüberschreitungen am realen Netz (der Stub bildet *„keine
  Antwort"* mit Exit 7 nach); Cache-Verhalten der Contents-API in der Nachkontrolle; `make mutate`, `make full-smoke`; ein Container-Zähler
  am realen Lauf ohne Token (Schluss aus der Reihenfolge im Skript, gestützt durch die Schwächung *„Token-Nachweis am Host entfernt"*).
- **Nicht nachgefahren:** die 28 Schwächungen des Reviews sind nicht wiederholt, sondern durch 16 eigene ersetzt (Tabelle 2), die dieselben
  Wächter treffen und die drei Nach-Review-Änderungen zusätzlich; die 27 Mutations-Fälle des Bestands sind dagegen alle gefahren.
- **Messartefakt:** mein Zähler *„geänderte Zeilen"* für Fall 433 stand auf 0 (er zählt nur hinzugekommene Zeilen); der Fall färbt zwei
  Fälle mit seinem `# expect:`-Text, der Anker trifft also.
- **Nicht Gegenstand des Verifiers:** ob der Slice gebaut werden *sollte* (Validator), und die Closure (Planner).

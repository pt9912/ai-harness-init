# Review-Report: slice-tap-nachzug-sync-schreibt-die-formel-ins-tap — 2026-09-26

**Review-Art:** Werkzeug-, Test- und Doku-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 3256c64d..HEAD` (HEAD `bced82b9`, Baum sauber). Produktiv-Diff: `1590aca7` (Ziel `make tap-nachzug`, README-Zeile,
`targets.exempt-targets`), `3dd38d36` (Modus `sync` in `harness/tools/tap-nachzug.sh` und `harness/tools/tap-nachzug-nutzlast.sh`, 14 neue
Fälle in `test/tap-nachzug.bats`), `bced82b9` (`docs/user/releasing.md`, Schritt 7). Move-/Marker-Commits: `9f356c1a` (`make slice-mv`,
`git show --stat -M`: reiner Move `next/` → `in-progress/`, 0 Zeilen geändert), `440f8ffa` (`make slice-mv`, ein Verweis nachgezogen),
`5effdc6f` (Rolle Implementer: Ruhe-Marker der Roadmap entfernt, drei Zeilen).

**Plan-Bezug:** Slice `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` (Ziel, §1 Abgrenzung, §3, §6 mit den offenen Fragen, §8) — Kennung,
nicht Pfad: der Plan wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0064` (`Accepted`, Festlegungen 1 bis 5,
§Fitness Function, Folgepflichten, §Grenze), `ADR-0066` (`Accepted`, Festlegung 1 und 2, Folgepflicht 1), `LH-QA-02`, `LH-QA-03`, `MR-071`,
`AGENTS.md` §3.3, §3.6, §3.7, §3.9, §3.10, §3.11, Setzung des Auftraggebers *„die Nutzerdoku trägt nur den Ist-Zustand"*.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` · `ADR-0066` · `MR-071` · `LH-QA-02` · `AGENTS.md` §3 · beide Skripte vollständig ·
`test/tap-nachzug.bats` · `test/mutations/409` bis `434` und `452` · `docs/user/releasing.md` · `harness/README.md` · `Makefile` ·
`.d-check.yml`. Der Implementer-Bericht lag dem Lauf **nicht** vor: seine Schwächungen M1 bis M28 sind nicht nachgefahren, sondern durch
eigene Schwächungen (unten, Kürzel A bis Z2, U3) ersetzt; die 27 Fälle des Mutations-Bestands sind nur zur Hälfte stichprobenartig gefahren.

**Eigene Sensor-Läufe dieses Laufs** — alle in Scratchpad-Kopien von `git archive HEAD` (kein `.git`), Docker-only im bats-Bild des Makefiles
(`docker run --rm --network none -v <Kopie>:/code:ro … test/tap-nachzug.bats`); kein Schreibzugriff im Repo-Baum, kein Tap-Zugriff, kein
Token außer dem Sentinel `TOKSENTINEL-9f3a71c2` in den Stubs, kein `make mutate`. Ein Lauf des Curl-Bildes des Pins (`--network none`) hat
die Blob-Formel der Nutzlast am **realen Bild** gemessen.

| Lauf | Ergebnis |
|---|---|
| unverändert, `test/tap-nachzug.bats` | `1..52`, kein `not ok` (`grep -c '^@test' test/tap-nachzug.bats` → `52`) |
| Blob-Formel im Bild `curlimages/curl@sha256:463eaf…` (`wc -c`, `printf 'blob %s\0'`, `cat`, `sha1sum`) gegen `git hash-object` derselben Datei (Nicht-ASCII-Byte, ohne Endzeilenumbruch) | beide `144021cca30f4bdd32328786fb50108e4f33d985`; `printf` ist dort ein Shell-Builtin; `base64 -w 0` und `curl 8.16.0` (kennt `-H @<Datei>`) vorhanden |
| `env -u TAP_TOKEN make tap-nachzug TAG=v0.2.3` (Host, kein Netz, kein Container) | Prozess-Exit 2, Meldung nennt `TAP_TOKEN` und den Ausfallweg, `tap-sync: Exit 2` als vorletzte Zeile, dann `make: *** … Fehler 2`; ohne `TAG`: Exit 2 mit der Meldung zu `TAG` |
| 28 Schwächungen der Nutzlast/des Skripts, je in frischer Kopie (Tabelle unten) | 27 färben mindestens einen Fall rot, **eine überlebt** (H) |
| 4 Gegenproben „Zusicherung entfernen, Mutation bleibt" | 2 werden **grün** (Zusicherung bindet allein), 2 bleiben rot (zweiter Fänger) |
| Mutations-Bestand 409, 411, 416, 427, 434, 452 am HEAD-Stand, je in frischer Kopie (`bash test/mutations/<n>-….sh`) | jeder Anker trifft (Kopie unterscheidet sich vom Bestand), jeder färbt einen Fall mit seinem `# expect:`-Text rot (409: 3 Fälle, 411: 6, 416: 3, 427: 14, 434: 1, 452: 2 — 452 färbt neben `check liest keine Version` auch `sync vorwaerts-schutz: ein groesserer Kern`) |

**Schwächungen und Rot-Ursache** (Nutzlast = `harness/tools/tap-nachzug-nutzlast.sh`, Skript = `harness/tools/tap-nachzug.sh`; Meldung gelesen):

| Kürzel | Schwächung | rote Fälle (Kern) | Meldung trägt die behauptete Ursache |
|---|---|---|---|
| A | Vorwärts-Schutz entfernt (`if tag_kleiner` → `if false`) | `sync vorwaerts-schutz: kleinerer Kern` | ja: `Tap 0.2.3, Tag v0.1.2: Exit 1 … Formel-Unterschied nach dem Schreiben` statt Exit 2 |
| B | Gleichstand: `-lt` → `-le` im dritten Feld | `sync idempotenz`, `sync vorwaerts-schutz: größerer Kern und Gleichstand` | ja |
| C | Idempotenz: erster Vergleich in `sync_lauf` immer ungleich | `sync idempotenz` (Zeile 760, `*"gleich"*`) | ja (Ausgabe `nachgezogen`) |
| D | Blob-Stand `0000` statt der Bytes des ersten Lesens | `sync optimistisch` (Zeile 880, mitgesandter Stand) | ja |
| E | 409: zweiter Schreibaufruf vor der Meldung | `sync token`, `sync optimistisch`, `sync abgelehnt` (`schreibaufrufe` = 2) | ja |
| E2 | 409: zusätzlicher Lese-Aufruf des Tap-Kopfs | `sync optimistisch` (Zeile 888, `lesungen_gesamt`) | ja |
| F | Nachkontrolle entfernt (`if vergleiche` → `if true`) | `sync nachkontrolle` (Zeile 928: `Exit 0` statt 1) | ja |
| G | Token als `-H "$(cat "$hdr")"` in der Argumentliste des Schreibens | `sync token` | ja (Sentinel in `STUB_LOG_CURL`) |
| **H** | **Schreibaufruf ohne `-H "@$hdr"` (kein Token am PUT)** | **keiner** | **überlebt: 52 von 52 grün** |
| I | `base64` ohne `-w 0` | `sync vorwaerts-schutz: größerer Kern`, `sync schreiben`, `sync optimistisch` | ja |
| J | `*)`-Zweig meldet `Tap unverändert` statt `Ausgang … ungewiss` | `sync abgelehnt` (Zeile 914) | ja |
| J2 | `*)`-Zweig trägt `Ausgang … ungewiss` **und** `Tap unverändert` | `sync abgelehnt` (Zeile 917, `nirgends 'unverändert'`) | ja — einzige rote Zeile |
| K | Fehlt-Nachweis am Host entfernt | `sync fehlt-nachweis` (Zeile 708, `docker_aufrufe`) | ja |
| K2 | Schritt b nur für stabile Tags (Vorab vor Nachweis) | `sync fehlt-nachweis` (Vorab-Iteration, Exit 0 statt 2) | ja |
| L | Vorwärts-Schutz lexikografisch (`sort`) | `sync vorwaerts-schutz` beide | ja |
| M | Feldform-Prüfung der Felder entfernt (`\|\| fehler` → `\|\| :`) | `sync version-zeile` (Zeile 814, Meldung; `arithmetic syntax error` im Stderr) | ja |
| N | mehrfache `version`-Zeile nicht erkannt | `sync version-zeile` (Zeile 814; `bad number`) | ja |
| Q | `sync` liest vor dem Schreiben wiederholt (`vergleiche`) | `sync wiederholt…`, `sync idempotenz`, `sync optimistisch`, `sync nachkontrolle` | ja |
| S | Blob ohne NUL (`blob %s`) | `sync optimistisch` | ja |
| T | Nachkontrolle-Ungleich endet `exit 0` statt 10 | `sync nachkontrolle` (Zeile 928; Meldung `Formel-Unterschied nach dem Schreiben` steht, Exit 0) | ja |
| V, V2 | Antwort der Schnittstelle (`cat "$work/antwort"`) im `*)`- bzw. 409-Zweig auf stderr | `sync token` (Zeile 838, Sentinel in `$output$stderr`) | ja |
| W | Commit-Message trägt `(Digest geprüft)` | `sync schreiben` (Zeile 868) | ja |
| X | `umask 022` statt `077` (Kopfdatei nicht 0600) | `token` und `sync token` | ja |
| Xi | Feldform `{0,8}` → `{0,20}` | `sync version-zeile` | ja |
| Y | Aufräumen der Arbeitsdatei entfernt | `token` (2 Fälle), `sync token` | ja |
| Z1 | zweites Feld `-lt` → `-le` | 8 Fälle (jeder mit gleichem zweiten Feld) | ja |
| Z2 | erstes Feld `-gt` → `-ge` | `sync vorwaerts-schutz: kleinerer Kern` | ja |

**Gegenproben** („grün heißt bindet": die Zusicherung entfernen, die Schwächung bleibt): GP1 (Zeile 917 entfernt, Schwächung J2) → **grün**, die
Zeile bindet allein; GP4 (Zeile 888 entfernt, Schwächung E2) → **grün**, die Zeile bindet allein; GP2 (Zeile 868 entfernt, Schwächung W) und
GP3 (Zeile 760 entfernt, Schwächung C) → **weiter rot**, ein zweiter Fänger (Zeile 869 bzw. 762) deckt dieselbe Schwächung — keine Lücke, nur
Redundanz.

---

## Findings

Kein HIGH.

### MEDIUM

**R-1** — `kategorie`: MEDIUM · `quelle`: `AGENTS.md` §3.6 (Zusage erst fertig, wenn ihr Gegenbeispiel rot gesehen wurde), `ADR-0064`
Festlegung 4 (Header als `-H @<Datei>`) · `pfad`: `harness/tools/tap-nachzug-nutzlast.sh:234-236` (Schreibaufruf), `test/tap-nachzug.bats:831-847`
(Fall `sync token`), Kopfkommentar `harness/tools/tap-nachzug-nutzlast.sh:41-45` (*„Belegt in test/tap-nachzug.bats"*) · `befund`: Nimmt man
`-H "@$hdr"` aus dem **Schreib**aufruf, färbt kein Fall der 52 rot (Schwächung H, `bats rc=0`). Der Fall `sync token` prüft, dass **jede** Kopfdatei,
die der `curl`-Stub sieht, Modus 0600 trägt und den Bearer enthält — die Lese-Aufrufe erfüllen das, der Stub bindet die Kopfdatei nicht an die
Methode (`STUB_LOG_HDR` kennt die Methode nicht). Kein Fall behauptet, dass der Schreibaufruf das Token trägt. **Failure-Szenario:** ein Umbau
lässt den Header am PUT fallen, die Suite bleibt grün, der erste reale Nachzug endet mit einer Ablehnung der Schnittstelle (laut, Exit 2, keine
stille Grün-Meldung; deshalb MEDIUM, nicht HIGH). · `verifizierbar`: ja — Schwächung H in Scratchpad-Kopie (`bats rc=0`, 0 `not ok`). ·
`klasse`: *Header-Zusage im Schreib-Pfad nicht an die Methode gebunden — der Stub prüft „jede Kopfdatei", nicht „die des PUT"*

### LOW

**R-2** — `kategorie`: LOW · `quelle`: `ADR-0064` Festlegung 3 (Schritt g), Setzung *Ist-Zustand* · `pfad`: `harness/tools/tap-nachzug-nutzlast.sh:262`
(`vergleiche` nach dem Schreiben) mit `:102-114` (`lese_tap`), `docs/user/releasing.md:132-141` (Exit-2-Liste von `tap-sync`) · `befund`: Schreibt
das Werkzeug erfolgreich (HTTP 200) und ist das Tap in der **Nachkontrolle** nicht lesbar (404, 401/403/429, 5xx, keine Antwort), endet der Lauf mit
Exit 2 und `Tap nicht lesbar … — es wurde nichts verglichen`; weder die Meldung noch die Prozedur sagt, dass das Tap zu diesem Zeitpunkt bereits
geschrieben ist (die Prozedur nennt *„dann kann das Tap geschrieben sein"* nur beim Ausgang *ungewiss*). Der Wiederholungslauf ist konvergent
(`make tap-nachzug` erneut, oder `make tap-check`); ein Bediener liest die Meldung aber als *„nichts geschehen"*. Kein Fall fährt diesen Zweig
(der Stub hat einen Lese-Code für alle Lesungen, nicht für die Lesung nach dem Schreiben). · `verifizierbar`: nein — mit dem vorhandenen Stub
nicht herstellbar (der Code ist gelesen, nicht gefahren). · `klasse`: *Meldung nach Teilerfolg verschweigt den bereits vollzogenen Schreibvorgang*

**R-3** — `kategorie`: LOW · `quelle`: Setzung *Ist-Zustand*, `BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`
· `pfad`: `docs/user/releasing.md:215-218` · `befund`: *„`grep -ci version harness/tools/tap-nachzug.sh harness/tools/tap-nachzug-nutzlast.sh`
liefert mit dem Modus `sync` je Datei mehr als `0`, weil `sync` die Zeile für den Vorwärts-Schutz liest"*. Die Zählung stimmt (`1` und `11`, gemessen),
die Begründung nur für die Nutzlast: der eine Treffer in `harness/tools/tap-nachzug.sh` ist das Wort im Kopfkommentar (`version-Zeile nicht
lesbar`), das Host-Skript liest keine `version`-Zeile. · `verifizierbar`: ja — `grep -ni version harness/tools/tap-nachzug.sh`. ·
`klasse`: *Wortzähler-Begründung trägt für eine der zwei genannten Dateien nicht*

**R-4** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.7 (Konjunktiv über die verworfene Alternative) · `pfad`: `test/tap-nachzug.bats:769-770`
(*„Tap 0.10.0 gegen v0.9.0 (lexikografisch waere 0.9.0 spaeter)"*) · `befund`: Der Kommentar beschreibt, was eine verworfene Implementierung
(lexikografischer Vergleich) täte; die Zeile 787 desselben Musters steht im Indikativ (*„numerisch groesser, lexikografisch kleiner"*). Unter
HIGH nicht eingestuft, weil der Satz die unterscheidende Eigenschaft des Falls nennt, die Assertion misst (Schwächung L färbt beide
Vorwärts-Fälle), und nicht den Vorgang, der die Stelle erzeugt hat. · `verifizierbar`: nein (kein Gate für Kommentar-Klassen). ·
`klasse`: *Kommentar im Konjunktiv über die verworfene Alternative*

### INFO

**R-5 — Offene Frage 2 des Plans (dem Review vorgelegt): Zuordnung der Antworten beim Schreiben.** Befund am Code
(`harness/tools/tap-nachzug-nutzlast.sh:237-245`): 200 → Nachkontrolle; 401/403/409 → *„Schreiben abgelehnt … Tap unverändert"* (Exit 2); 000 und
**jeder andere** Status (5xx, 201, 204, 404, 422, 429) → *„Ausgang des Schreibens ungewiss"* mit `make tap-check TAG=<tag>` (Exit 2). Der
Fall `sync abgelehnt` bindet beide Listen (Schwächungen J, J2). **Deckung durch `ADR-0064` Festlegung 3:** die ADR benennt **Ursachen**
(*„Anmeldung, Schutz des Branches, Konflikt"*), keine Statuscodes, und kennt zwei Klassen (*ausdrücklich abgelehnt* → unverändert; *ohne Antwort* →
ungewiss). Eine Antwort mit anderem Status ist in keiner der beiden; die Zuordnung *Ursache → 401/403/409* ist eine Annahme über die reale
Schnittstelle, die dieser Lauf nicht messen kann (kein Netz): ob *Schutz des Branches* dort mit 403, 409 oder 422 antwortet, ist ungemessen.
**Ist die sichere Richtung sicher?** Ja, in beide Richtungen am Code gelesen: *„Tap unverändert"* kann nur aus 401, 403 oder 409 entstehen —
ein Schreibvorgang, den die Schnittstelle mit diesen Codes beantwortet, ist nicht vollzogen; *„ungewiss"* behauptet nie etwas über den Zustand
und nennt das Werkzeug, das ihn entscheidet. Die Klasse (Exit 2) ist in beiden Fällen dieselbe. **Überschreitet die Zuordnung die ADR?** Nein: eine
404 beim Schreiben als *„ungewiss"* statt *„nicht lesbar"* ändert die Klasse nicht, und *„nicht lesbar"* meint in der ADR das Lesen. Was die
Zuordnung kostet, ist eine überflüssige Nachkontrolle für Antworten, die sicher nichts geschrieben haben (422, 429, 404) und ein Schutz-Ablehnung
mit einem anderen Code als 403 (Meldung *„ungewiss"* statt der ausdrücklichen Ablehnung). **Empfehlung:** die Zuordnung bleibt wie sie ist, bis
der erste reale Nachzug die Codes des Tap zeigt — sie ist konservativ und kann keine Zusage brechen; ein Verdikt, ob weitere 4xx-Codes
(422, 429, 404) in *„Tap unverändert"* wandern dürfen, ist **Architect-Arbeit** (die ADR trägt es nicht), samt der Frage, ob die Meldung eines
ausdrücklichen Schutzes ohne festen Code als eigene Ursache benannt wird. Übergabe unten.

**R-6** — `kategorie`: INFO · `quelle`: `docs/user/releasing.md`, Setzung *Ist-Zustand* · `pfad`: `docs/user/releasing.md:97-107`,
`docs/user/releasing.md:120-126` · `befund`: (a) Der Absatz *Handlung* sagt *„auf den Default-Branch"* und *„kontrolliert danach"* ohne Einschränkung;
die Einschränkung auf die nachgebildete Schnittstelle steht erst am Ende des Absatzes *Grenze* (`docs/user/releasing.md:220-222`). (b) *„die Prozedur
nennt keine ausführende Rolle"* ist eine Aussage der Prozedur über die eigene Abwesenheit; sie ist wahr und Ist-Zustand, aber die einzige
Stelle des Schritts, die von sich selbst spricht. (c) Der Vorab-Satz (*„entfällt der Nachzug"*) nennt nicht, dass ein Vorab-Tag **ohne**
`TAP_TOKEN` mit Exit 2 endet (Schritt b geht Schritt c voraus, Fall `sync fehlt-nachweis` bindet es); der unbedingte Satz zwei Zeilen
darüber (*„Ohne `TAP_TOKEN` endet der Aufruf mit Exit 2 vor jedem Netz-Zugriff"*) deckt es. Kein Befund gegen eine Regel; Urteil beim Planner/Verifier. ·
`verifizierbar`: nein · `klasse`: *Zusage-Einschränkung steht abseits der Zusage*

**R-7** — `kategorie`: INFO · `quelle`: `AGENTS.md` §3.6 · `pfad`: `docs/user/releasing.md:209-214` · `befund`: *„keiner der `52` Fälle … wird von ihm rot"*
über einen Vergleich, der eine größere Tap-Version bei zusätzlich abweichenden Zeilen als gleich gelten lässt, ist von diesem Lauf **nicht
bestätigt**. Ein Näherungsversuch (Schwächung U3: `cmp -l` > 1 Byte **und** lexikografisch größere `version`-Zeile → gleich) färbte den Fall
`sync vorwaerts-schutz: ein groesserer Kern` rot — die Näherung ist aber unscharf (`0.2.9` gilt lexikografisch als größer als `0.2.10`, ist
numerisch kleiner; das Byte-Maß ersetzt *„weitere Zeilen"* nicht). Weder Bestätigung noch Widerlegung; die Zahl `52` steht korrekt neben
`grep -c '^@test' test/tap-nachzug.bats`. Der Verifier fährt die Schwächung in ihrer Wortlaut-Form (numerisch größere Tap-Version **und**
mindestens zwei abweichende Zeilen). · `verifizierbar`: ja · `klasse`: *„nicht gebunden"-Aussage über die Suite ohne Messung mit der Wortlaut-Schwächung*

---

## Geprüft, ohne Befund

- **Token im Schreib-Pfad (ADR-0064 Festlegung 4):** `-e TAP_TOKEN` ohne Wert (`harness/tools/tap-nachzug.sh`, Fall `sync token` prüft `-e TAP_TOKEN`
  vorhanden, `TAP_TOKEN=` nirgends); der Header entsteht mit dem Builtin `printf` in einer Datei unter `umask 077` (X rot), `curl -H @<Datei>`
  (G rot), Datei und Antwort-/Body-Datei werden vom EXIT-Trap entfernt (Y rot), auch bei `INT`/`TERM` (`trap 'exit 2'`); kein `set -x`; keine Meldung
  gibt die Antwort der Schnittstelle aus (V, V2 rot). Der Body trägt nur `"sha"`, den Tag und Base64 des Assets.
- **Schritt b vor c (ADR-0064 Festlegung 3):** Fehlt-Nachweis am Host vor jedem `docker`- und `curl`-Aufruf, auch für Vorab-Tags, leerer Wert gilt als fehlend
  (K, K2 rot); die Nutzlast führt den Nachweis ein zweites Mal (Fall ruft sie direkt). Der Lauf über `make` ist am realen Ziel gefahren.
- **Vorwärts-Schutz, Gleichstand, Feldform, `version`-Zeile:** numerisch je Feld (A, B, L, Z1, Z2 rot), 0.10.0 gegen 0.9.0, Gleichstand schreibt, Vorab-Tag
  lässt das Tap bleiben (Exit 0, ohne Netz); Feldform und Zeilenzahl mit Meldung der Zeile, nie `0.0.0` (M, N, Xi rot).
- **Schreiben:** ein Versuch, optimistisch gegen den Blob-Stand der gelesenen Bytes (D, S, E, E2 rot; Formel am realen Bild gemessen), `base64 -w 0`
  (I rot), Commit-Message nennt den Tag und sagt keine Prüfung zu (W rot), Nachkontrolle mit Wiederholung (F, T rot), Exit-Zeile `tap-sync: Exit N`
  bei 1 und 2 genau einmal, bei 0 nicht.
- **Ausgang-Zuordnung:** siehe R-5; kein Weg, auf dem *„Tap unverändert"* aus einem Status außerhalb 401/403/409 entsteht.
- **Ziel und Nachbarn:** `tap-nachzug:` in `.PHONY`, Rezept ohne make-Referenz auf Tag und Token (Textfall), in keiner Prerequisite-Kette, nicht in `gates`/`record-gates`;
  Kommentar am Ziel nennt Netz, Token und die Ebene der Klassen (`ADR-0066` Folgepflicht 1: Exit des Skripts, Zeile, Position mit Bedingung, Signal mit Klasse);
  README-Zeile trägt `kein Gate` und Bindung; `targets.exempt-targets` führt `tap-nachzug` exakt; der Zahlenkommentar *„17 von 21"* in `.d-check.yml` stimmt
  (Schleife über die 21 genannten Ziele: 17 tragen `NICHT in gates` im `## `-Hilfetext, die vier ohne sind die im Kommentar genannten).
- **`docs/user/releasing.md` Schritt 7:** die vier alternden Aussagen sind ersetzt (`grep -nE 'Handgriff|einzige Tap-Ziel|Bytes, keine Versionen|allein bei der Vorbedingung'`
  → keine Treffer); Klassen 0/1/2 gegen das Skript gelesen (`gleich`/`nachgezogen` mit Tag und Digest, `Formel-Unterschied nach dem Schreiben`, `Schreiben abgelehnt`,
  `Ausgang des Schreibens ungewiss`, `Vorwärts-Schutz` — jede zitierte Meldung steht im Skript); Zahl `52` neben dem Kommando; Nummerierung (Schritt 7 bleibt
  Schritt 7, Verweise in Schritt 8 stimmen); Zustandsform, keine Chronik, kein Klon-Pfad; `grep -ci version` → `1` und `11` (siehe R-3 zur Begründung).
- **Rollen/Regeln:** `9f356c1a` reiner Move (§3.3, 0 Zeilen); kein Closure-Artefakt im Diff (§3.10: keine §7-Notiz, keine Häkchen, kein Register-Eintrag); keine
  Pfad-Adresse eines wandernden Artefakts in einem eingefrorenen (§3.11); kein Schreibzugriff aufs Tap in irgendeinem Fall (die Stubs `curl`/`docker`/`sleep`
  stehen vor dem `PATH`, jeder Fall fährt sie; der Sentinel steht nur in Stubs und Fällen); Docker-only (§3.9): das Skript ruft nur `docker` und Shell-Builtins,
  die Nutzlast nur Programme des Bild-Bestands (Fall `nutzlast: … Bild-Bestands`). Heredoc und `docker pull` des Implementers haben keine Spur im Repo
  (`git status` sauber, `git log -p` ohne Scratch-Pfad).
- **Kein Mutations-Fall für `sync`** (`grep -l 'tap-nachzug' test/mutations/*` nennt nur `tap-check`-Fälle und 452): im Plan benannt (§1, Folge-Schnitt), ungelistet,
  nicht unbewacht; die Prozedur sagt es (*„keinen Fall in `test/mutations/`"*). Kein Befund.

## Summary

**0 HIGH · 1 MEDIUM · 3 LOW · 3 INFO** — MEDIUM R-1 (Header am Schreibaufruf ungebunden), LOW R-2 (Meldung nach Teilerfolg), R-3 (Wortzähler-Begründung), R-4
(Kommentar im Konjunktiv), INFO R-5 (Frage 2: Empfehlung, Verdikt beim Architect), R-6, R-7.

## Übergaben

- **Implementer:** R-1 (ein Fall, der den Header **am PUT** bindet — die Schwächung H färbt ihn rot, die Gegenprobe grün heißt bindet), R-2 (Zweig
  fahren oder die Meldung um den vollzogenen Schreibvorgang ergänzen; Prozedur nachziehen), R-3 (Begründung auf die Nutzlast beschränken), R-4.
- **Verifier:** R-7 mit der Wortlaut-Schwächung; die Aussagen von Schritt 7 gegen einen Lauf des Skripts (Klassen und Zeile `tap-sync: Exit <N>`).
- **Planner:** keine Änderung der Abnahme; Klassen-Kandidaten für §7: R-1 (*Zusage nicht an die Methode gebunden*), R-2 (*Meldung nach Teilerfolg*),
  R-3 (Nachbar von `prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`).
- **Architect:** R-5 — Verdikt, ob 422/429/404 (oder alle 4xx) beim Schreiben *„Tap unverändert"* tragen dürfen und ob ein Schutz des Branches ohne festen Code als
  eigene Ursache geführt wird; dazu die ADR-Lücke aus R-2 (die Meldung der Nachkontrolle nach einem vollzogenen Schreiben). Kein HIGH, darum kein
  Konflikt-Pfad.

# Review-Report: ADR-0064 (Tap-Nachzug), Nachrunde 3 — 2026-09-24

**Review-Art:** Design — kurze Nachrunde einer `Proposed`-ADR, nur das Neue seit Runde 2. Runde 1:
`docs/reviews/2026-09-24-adr-0064-tap-nachzug-runde-1.md`; Runde 2:
`docs/reviews/2026-09-24-adr-0064-tap-nachzug-runde-2.md` (annahmefähig; N-1 MEDIUM, N-2 bis N-6 LOW, N-7 INFO).
Beide unangetastet.

**Gegenstand:** `git diff 9f79188f 0a6d0a86 -- docs/plan/adr/0064-*.md` — Architect-Commit `0a6d0a86`
(+170/−66). Der Arbeitsbaum war zu Beginn sauber; im Repo wurde nur diese Datei geschrieben.

**Rolle:** Reviewer, frischer Kontext. Jede Messung der ADR, die sich lesend fahren ließ, ist nachgefahren
(im gepinnten Transport-Bild, `--pull=never`; netzlos, wo die Messung kein Netz braucht; der einzige Netz-Zugriff
ist ein anonymer `GET`). Der Bild-Digest ist der von `harness/tools/traeger-fetch.sh` (`TRAEGER_IMAGE`, Zeile 35).

## Gesamturteil

**Annahmefähig.** Kein HIGH, kein MEDIUM. Der MEDIUM aus Runde 2 (N-1, die Fitness-Lücke an der `version`-Zeile)
ist behoben und geschlossen gedacht: Feldform, Exit 2 ohne Schreiben, nie ein stilles `0.0.0`, dazu die
Fitness-Zeilen mit Meldungs-Prüfung. Alle drei Bild-`sh`-Messungen und die Bildbestands-Messung reproduzieren
exakt. Die neue Wiederholung mit Wartezeit (N-3) trägt als Design; ihre Prämisse ist aus der Kopfzeile abgeleitet,
nicht beobachtet (B-2). Diese Runde findet **drei LOW und drei INFO**, keiner an der Substanz der sieben
Festlegungen.

**Acceptance-Trigger.** Wortlaut in der ADR (§Der Acceptance-Trigger): *„…wenn eine Reviewer-Runde über die dann
geltende Fassung sie gegen ADR-0058 (Festlegung 4), ADR-0059 und MR-014 auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund an der **Substanz** der sieben Festlegungen in `docs/reviews/` liegt. Ein blockierender
Befund an der **Darstellung** … wird behoben und hindert die Annahme nicht."* Diese Runde hat die Fassung `0a6d0a86`
gegen die drei Bezüge geprüft (unten); ihr Report führt keinen blockierenden Befund an der Substanz.
**Der Trigger ist erfüllt.** Die Annahme selbst bleibt beim Auftraggeber.

## Findings

### B-1 — LOW — Die Exit-Tabelle der Kontrolle nennt die `version`-Zeile für beide Modi, Schritt d gilt nur in `sync`

- `kategorie`: LOW · `quelle`: ADR-0064 Festlegung 1 (Tabelle, Schritt d nur `sync`), Festlegung 2 (Exit-Tabelle)
- `pfad`: `docs/plan/adr/0064-…md:207` (Schritt d: `check` „—"), `:274` (Exit 2: *„Tap nicht lesbar (auch: keine
  Formel-Datei, `version`-Zeile fehlt oder genügt der Feldform nicht)"*)
- `befund`: Die Exit-Tabelle steht unter der Kontrolle, die beide Modi teilen; die Lesbarkeit der `version`-Zeile
  ist aber Teil des Vorwärts-Schutzes (Schritt d), den `check` nicht kennt. Offen ist, was `check` mit **gleichen**
  Bytes und ungewöhnlicher `version`-Zeile tut (Exit 0 nach dem Vergleich, oder Exit 2 aus der Lesbarkeit). Die
  Fitness-Zeile *„Lesbarkeit der `version`-Zeile"* nennt den Modus nicht. Ein Implementer entscheidet; der
  Prozedur-Schritt `make tap-check` (Festlegung 6) hängt an der Antwort.
- `verifizierbar`: ja — ein bats-Fall `check` mit Tap = Asset und `version`-Zeile außerhalb der Feldform zeigt die Wahl
- `klasse`: Tabelle über zwei Modi trägt eine Bedingung, die nur einer kennt

### B-2 — LOW — Die Wiederholung des Lesens: die Prämisse ist aus der Kopfzeile abgeleitet, *„im Regelfall"* und *„65 s = 60 + 5"* sind ohne Beleg

- `kategorie`: LOW · `quelle`: ADR-0064 §Lage (Cache-Fenster), Festlegung 2, §Konsequenzen (Negativ), `AGENTS.md` §3.6
- `pfad`: `docs/plan/adr/0064-…md:144-155`, `:259-267`, `:446-450`
- `befund`: Gemessen ist die **Kopfzeile** — anonym reproduziert: `cache-control: public, max-age=60, s-maxage=60`,
  HTTP 200; die authentifizierte Fassung (`private`, mit `gh`) habe ich nicht nachgefahren. Ein **beobachtetes**
  Stale-Lesen führt die ADR nicht; *„ein Lesen kurz nach einem Schreiben kann den Stand davor liefern"* ist
  Schluss aus dem Header, und Festlegung 2 setzt darauf *„im Regelfall als falsches Ungleich"*. Die 5 s in *„das
  Fenster von 60 s plus 5 s"* sind nicht als Wahl ausgewiesen (der Re-Evaluierungs-Trigger hängt an der 60, nicht an
  der 5); ein Zwischen-Cache (`max-age=60` zusätzlich zu `s-maxage=60`) könnte über 65 s hinaus halten, dann endet
  die Kontrolle mit einem falschen Exit 1 — die sichere Richtung, aber ohne Nennung. Die Kostenaussage der
  Konsequenzen (*„eine echte Abweichung kostet den `tap-check` … 65 s"*) trifft dazu nur einen Teil: dieselben 65 s
  fallen bei **jedem** cache-bedingten falschen Ungleich an — also in der Nachkontrolle nach jedem Schreiben und im
  `tap-check` der Prozedur, wo der Fall gerade eintreten soll. Ändert sich der Tap-Stand zwischen den zwei Lesungen,
  entscheidet das zweite Lesen; welches Lesen die Meldung (*„nennt beide Digests"*) belegt, sagt die ADR nicht.
- `verifizierbar`: nein — ohne ein Stale-Lesen am realen Tap ist die Prämisse nicht zu bestätigen; die Fitness-Fälle
  (Stub alt → neu) prüfen die Logik, nicht die Prämisse
- `klasse`: Design stützt sich auf eine aus einem Header gefolgerte Eigenschaft, die nicht beobachtet ist

### B-3 — LOW — *„In `sync` (Schritt e) gibt es diese Wiederholung nicht"* hat kein rotes Gegenbeispiel

- `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6, ADR-0064 Festlegung 2, §Fitness Function
- `pfad`: `docs/plan/adr/0064-…md:264-267`; Fitness-Tabelle `:547` (Cache-Fenster-Zeile), `:557` (Optimistisch)
- `befund`: Die Zusage nennt drei Folgen: kein Wiederholen in Schritt e; ein alter Stand führt höchstens zu einem
  Schreiben, das am Blob-Stand scheitert (Exit 2, Tap unverändert); der Wiederholungslauf ist konvergent. Die
  Fitness-Zeile zur Wiederholung bindet `check` und Schritt g (Stub alt → neu, beide alt, sofort gleich); die Zeile
  *„Optimistisch"* bindet den Konflikt. Wird die Wiederholung testweise **auch** in Schritt e eingebaut, bleiben
  beide Zeilen grün, solange der Stub konstant ungleich liefert und die Wartezeit im Test 0 ist — kein Fall zählt die
  Lese-Aufrufe von `sync` vor dem Schreiben.
- `verifizierbar`: ja — ein Fall `sync` mit Stub *alt, dann neu* fordert Schreibaufruf 1 und genau einen Lese-Aufruf
  vor dem Schreiben
- `klasse`: Zusage ohne benanntes rotes Gegenbeispiel (Wiederholung aus Runde 1: F-3, F-7, F-8; Runde 2: N-1)

### B-4 — INFO — Der lokale Weg: `make` wertet `$(shell …)` im Kommandozeilen-Wert aus, bevor die Formprüfung läuft

- `kategorie`: INFO · `quelle`: ADR-0064 Festlegung 1 (*„Zwei Wege, zwei Übergabeformen"*), `AGENTS.md` §3.9
- `pfad`: `docs/plan/adr/0064-…md:219-226`, Fitness-Tabelle `:552`
- `befund`: Die ADR nennt `$(HOME)`, `$$(id)` und `${IFS}` und stellt fest, der Tippende sei der Auftraggeber. Gemessen
  (GNU Make 4.3, Wegwerf-Makefile im Scratchpad): der **Env-Weg** reicht `v1.0.0$(shell echo X > marker)y` und
  `v1$(HOME)y` **byte-genau** durch (keine Datei `marker`) — die Zusage der CI trägt; der **Kommandozeilen-Weg**
  wertet aus (`v1/home/dby`) und **führt** `$(shell …)` aus (Datei `marker` entsteht), noch bevor ein Skript und seine
  Formprüfung laufen. Der Fall der Fitness-Tabelle deckt den Kommandozeilen-Weg mit `$$(id)`, nicht mit einer make-
  eigenen Funktion. Die Grenze liegt beim Auftraggeber und ist vertretbar; sie steht nicht in §Grenze.
- `verifizierbar`: ja — `make t TAG='v1.0.0$(shell echo X > marker)y'` (Rezept `printf '%s\n' "$$TAG"`)
- `klasse`: Zusage der Formprüfung reicht nicht vor die Auswertung des Aufrufers

### B-5 — INFO — Das anonyme Lese-Limit der Schnittstelle steht nicht in der ADR

- `kategorie`: INFO · `quelle`: ADR-0064 Festlegung 2 (Lesen ohne Token), Festlegung 6
- `pfad`: `docs/plan/adr/0064-…md:255-258`, `:402-407`
- `befund`: Der anonyme `GET` liefert heute die Kopfzeile `x-ratelimit-limit: 60` (gemessen; das Zeitfenster steht nicht in der Kopfzeile, die ich gelesen habe). Der `tap-check` der
  Prozedur liest anonym, mit Wiederholung zweimal; ein erschöpftes Limit endet als `Tap nicht lesbar` (Exit 2, nie 1)
  — die Klasse trägt, aber die ADR nennt das Limit für den anonymen Weg nicht und führt keinen Fall mit einer
  Limit-Antwort. Die Begründung *„kein Rate-Limit-Rot auf einem geteilten Runner"* gilt dem Token-Weg.
- `verifizierbar`: ja — `curl -sI` auf den Contents-Pfad zeigt `x-ratelimit-*`
- `klasse`: benannte Grenze fehlt, ihre Klasse ist gedeckt

### B-6 — INFO — Der Bezug zu `LH-QA-03` ist im Wortlaut enger, als die Anforderung ist

- `kategorie`: INFO · `quelle`: `LH-QA-03` (`spec/lastenheft.md`, Abschnitt *Minimale Abhängigkeiten*), ADR-0064 Bezug und
  Festlegung 5
- `pfad`: `docs/plan/adr/0064-…md:13-16`, `:365-371`
- `befund`: Die ADR schreibt *„die Laufzeit des Tools braucht „nur **git + docker**""*; die Anforderung sagt *„die Laufzeit
  **beim Bootstrap** braucht nur **git + docker**"* und *„Emittierte Ziel-Repos bleiben make/docker-getrieben"*. Der
  wörtliche Teil (*„nur git + docker"*) stimmt; *„des Tools"* statt *„beim Bootstrap"* ist eine Paraphrase. Die
  Folgerung (kein neuer Host-Bedarf über `make` und die `bash` der Rezepte hinaus; das Werkzeug ist ein Ziel dieses
  Repos, nicht ein Bootstrap-Schritt) trägt und ist in Runde 2 als Bezug-Fehler (N-4) richtig behoben; `MR-069` ist
  wörtlich zitiert.
- `verifizierbar`: ja — `sed -n 465,469p spec/lastenheft.md`
- `klasse`: Zitat trägt die Paraphrase der Gegenseite, nicht ihren Wortlaut

## Prüfung der Schwerpunkte des Auftrags

### N-1 (Fitness-Lücke, fail-open) — behoben

- **Feldform.** `0` oder Ziffernfolge ohne führende Null, höchstens 9 Stellen; für Tag-Kern (Host, vor `docker`, auch
  bei Vorab-Tags: *„Schritt a geht Schritt c voraus"*) und Tap-Stand. Nicht lesbare `version`-Zeile (fehlt, mehrfach,
  genügt der Form nicht, nicht drei Felder) → Exit 2 ohne Schreiben, *„nie ein stillschweigendes `0.0.0`"*.
- **Bild-`sh`, alle vier Messungen der ADR nachgefahren** (`docker run --rm --pull=never --network none --entrypoint sh <Bild>`):

  | Aufruf | ADR | gemessen |
  |---|---|---|
  | `e=""; echo $(( e + 0 ))` | `0`, Exit 0 | `0`, Exit 0 |
  | `e=08; echo $(( e + 0 ))` | Syntaxfehler, Exit 2 | `sh: arithmetic syntax error`, Exit 2 |
  | `e=99999999999999999999; echo $(( e + 0 ))` | `7766279631452241919` | `7766279631452241919`, Exit 0 |
  | `echo $((999999999999999999+1))` | `1000000000000000000` | `1000000000000000000` |

  Ergänzend gemessen: `$((999999999+999999999))` → `1999999998`, `$((999999999*999999999))` →
  `999999998000000001` — auch Summe und Produkt zweier 9-stelliger Felder bleiben im Bereich; `e=0x10` rechnet als `16`
  (hexadezimal wäre offen, die Feldform schließt es aus, weil `x` kein Ziffernzeichen ist).
- **Trägt „9 Stellen"?** Ja als **Wahl mit Reserve**, nicht als Messung: die ADR nennt sie *„weit unter den 18 Ziffern,
  die der Bild-`sh` noch richtig rechnet"* und *„über jeder Fassung, die ein Schnitt trägt"* — Letzteres ist eine
  Erwartung über künftige Tags (ein Datums-Tag `v20260924.0.0` hat 8 Stellen und passt), keine Aussage über den
  Bestand; sie ist mit Exit 2 an der sicheren Seite. Die Fälle (10-Stellen-Tag, 20-Stellen-Tap) binden beide Seiten.
- **Vergleich mit Vorab-Tag, Build-Metadatum, `v0.2.3-rc.1` gegen Tap `0.2.3`.** Reihenfolge a (Form, Feldform) → c
  (Vorab: *„Metadatum zuerst abgeschnitten"*, Exit 0 mit *„Vorab-Tag, Tap bleibt"*, ohne Netz) → d (Kern **numerisch je
  Feld** gegen den Tap-Stand, nur stabile Tags). `v0.2.3-rc.1` endet in c mit Exit 0; `v1.0.0+build-1` ist stabil und
  geht mit dem Kern `1.0.0` in d. Beide Kerne sind vor dem Vergleich feldform-geprüft; fail-closed.
- **Der Tap-Stand am realen Tap:** anonym gelesen enthält die Formel genau **eine** Zeile mit `version` (`version "0.2.3"`,
  Zeile 11) — die Form *„genau eine Zeile `version "<K>.<K>.<K>"`"* trifft den Bestand.
- **Fitness-Zeilen** (Zeilen 549 bis 552): leere Extraktion, `0.08.3`, 20-stelliges Feld, `0.2`, Gleichstand mit
  Schreiben (`<=` statt `<` färbt rot), Feldform-Tags `v01.0.0`, `v1.0.08`, `v1.0.1234567890`, `v01.0.0-rc.1` — je mit
  Schwächung; die Exit-2-Fälle prüfen die Meldung. Die Schwächung *„Feldform entfernt → `0.08.3` bricht mit dem
  Syntaxfehler der Shell"* stimmt mit der Messung überein (Exit 2 der Shell, nicht der ADR-Meldung). Rest B-1.

### N-3 (Wiederholung mit Wartezeit) — trägt, mit B-2 und B-3

- **Messung:** anonymer `GET` auf `…/contents/Formula/ai-harness-init.rb` im gepinnten Bild: `HTTP/2 200`,
  `cache-control: public, max-age=60, s-maxage=60` (reproduziert). Die authentifizierte Kopfzeile ist nicht nachgefahren.
- **Design:** `check` und Schritt g lesen bei Ungleichheit einmal nach 65 s erneut; Exit 1 nur bei zweiter Ungleichheit;
  Gleichheit im ersten Lesen wartet nicht; `sync` Schritt e ohne Wiederholung; die Wartezeit ist im Test injizierbar
  (Festlegung 5, Fitness-Zeile *„Wartezeit im Test auf 0"*). Eine Wiederholung erzeugt nie ein falsches Grün: Grün
  bleibt *„zwei gelesene, gleiche Dateien"*. Ein Stale-Lesen über 65 s hinaus erzeugt einen falschen Exit 1 (die
  sichere Richtung). Ratenlimit: B-5. Wartezeit in der Prozedur: Folgepflicht 3 nennt sie; ein Aufruf ohne Ungleichheit
  wartet nicht.
- **Bei `sync` mit altem Stand:** ein Schreiben gegen den gelesenen Blob-Stand scheitert (Konflikt), Exit 2, Tap
  unverändert; der Wiederholungslauf ist konvergent — die Zeile *„Optimistisch"* bindet das. Dass Schritt e ohne
  Wiederholung bleibt, bindet keine Zeile (B-3).

### N-2, N-4, N-5, N-6, N-7 (Runde 2) — behoben

| Befund | Stand | Beleg dieser Runde |
|---|---|---|
| N-2 (Tag anlegbar; zwei Wege; Rezept-Textfall) | **behoben** | `git check-ref-format refs/tags/'v1.0.0$(touch${IFS}marker)'` → Exit 0, `v1.0.0;x` → Exit 0 (auch `v01.0.0`); Env-Weg byte-genau, Kommandozeilen-Weg expandiert (gemessen, B-4); Rezept-Textfall (*„keine make-Referenz auf den Tag"*) steht als eigene Fitness-Zeile |
| N-4 (Bezug: `MR-069`, `LH-QA-03`) | **behoben** | `MR-069`: *„…trägt seine Prüfung als Inline-Block, solange die Prüfung nur das Verzeichnis liest, das der vorherige Step gelegt hat"* wörtlich; *„er bekommt kein Geheimnis"* ist jetzt als Setzung dieser ADR ausgewiesen (Bezug und Festlegung 4); `LH-QA-03`: B-6 |
| N-5 (`## Grenze` als oberste Ebene) | **behoben** | `grep -cE '^## Grenze' docs/plan/adr/0064-*.md` → **0**; `### Grenze` steht unter `## Konsequenzen` (Zeile 482) |
| N-6 (Bildbestand) | **behoben** | am Bild gemessen: `curl base64 cmp sha256sum sha1sum sed awk od wc grep mktemp stat sleep` ja, `jq bash git gh` nein; Builtins `printf trap umask test read` (*„is a shell builtin"*, `trap` *special*); Blob-Stand-Rezept `printf "blob %s\0" "$n"; cat f` mit `sha1sum` liefert für `abc` `f2ba8f84ab5c1bce84a7b441cb1959cfc7093b7f`, gleich `git hash-object`; `curl -H @<Datei>` wird verstanden (curl 8.16.0). Pin-Quelle: ein bats-Kopplungsfall gegen `TRAEGER_IMAGE` (Zeile 35 von `harness/tools/traeger-fetch.sh`); dort hält `test/traeger-fetch.bats` schon eine Zwillings-Kopplung — die Kopplungs-Bauart existiert |
| N-7 (Randlagen) | **behoben** | (a) *„Ausgang ungewiss"* bei Antwort-losem Schreiben, *„unverändert"* nur bei ausdrücklicher Ablehnung — Fitness-Zeile *„Schreiben ohne Antwort"*; (b) Tap ohne Formel-Datei → Exit 2, Fitness (404 in `sync`, Schreibzähler 0); (c) `-e TAP_TOKEN` gegen den Daemon **gemessen**: mit `-e TAP_TOKEN` (Wert aus der Umgebung) zeigt `docker inspect` `TAP_TOKEN=SENTINEL-1234` und `/proc/1/environ` im Container ebenfalls — die Grenze in §Grenze benennt genau das |

## Konsistenz gegen die Bezüge des Acceptance-Triggers

- **ADR-0058 Festlegung 4** (Transport im gepinnten Bild, Host braucht `git`, `docker`, GNU `make`, Netz an genau diesem
  Aufruf): ADR-0064 nutzt das Muster (Pin-Prüfung, Bild) und legt eine **zweite Stelle** für den Digest an, gekoppelt
  an `TRAEGER_IMAGE`; sie sagt, dass `bash` auf dem Host die Voraussetzung der Rezepte ist (`traeger-fetch.sh`).
  Festlegung 3 (*„Kein Prerequisite"*): beide Ziele stehen nicht in `gates`/`record-gates`.
- **ADR-0059:** *„Das Binary trägt keinen Wert, der vom Bau-Ergebnis abhängt"* steht wörtlich (`grep -c -F` → 1); der Nachzug
  liest die fertige Formel nur.
- **MR-014 Setzung 1** (*„ein Check wird nie in der Workflow-YAML definiert"*; Steps rufen `make`): der Job `tap` ruft
  `make tap-nachzug` ohne Inline-Prüfung; der `publish`-Job bleibt der Job ohne Checkout (`MR-069`, wörtlich zitiert).
- **Neue Widersprüche durch die Änderungen seit Runde 2:** keine. Die Kostenaussage (65 s) ist in Konsequenzen und
  Folgepflicht 3 genannt (unvollständig, B-2); die Pin-Kopplung ist in Fitness und Festlegung 5 gleich beschrieben; die
  Zahl der Festlegungen (sieben) und der Bezug des Triggers stimmen.

## Geprüft, ohne Befund

- **Pflichtgliederung:** `## Kontext / Entscheidung / Verglichene Alternativen / Konsequenzen / Fitness Function /
  Re-Evaluierungs-Trigger / Geschichte`; `### Grenze` unter `## Konsequenzen`; `### Der Acceptance-Trigger` unter
  `## Re-Evaluierungs-Trigger`.
- **§3.7/§3.11:** keine Slice-Kennung als Adresse in der ADR (`grep -nE 'slice-[a-z0-9]+-|welle-'` → keine Fundstelle);
  der Diff seit Runde 2 nennt keine Pfad-Adresse auf ein wanderndes Artefakt außer den Verweisen auf
  `docs/user/releasing.md` und `harness/tools/…` (ortsfest).
- **`MR-025`:** die Zahlen der neuen Messungen (18/20 Ziffern, 60 s, 65 s, 9 Stellen) sind Wahl bzw. tragen ihr
  Kommando in §Lage; keine ist ein Erwartungswert.
- **Fitness-Tabelle:** die Zeilen zu Feldform, Cache-Fenster, Gleichstand, Schreiben ohne Antwort, Tap ohne Datei, Pin-Kopplung
  und Job-Form tragen je ein benanntes rotes Gegenbeispiel; das `mutate`-Set nennt die neuen Wächter (Gleichstands-Vergleich,
  Feldform-Prüfung, Wiederholung des Lesens).
- **Rollen-Grenzen:** `0a6d0a86` berührt allein die ADR; kein Adaptions-Block-Commit (`AGENTS.md` §3.8).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 (B-1 … B-3) |
| INFO | 3 (B-4 … B-6) |

**Runde-2-Befunde:** 7 von 7 behoben (N-1 MEDIUM eingeschlossen).

**Wiederkehrende Klassen für den Zähler (Slice-Closure §7):** *Zusage ohne benanntes rotes Gegenbeispiel* (B-3; Runde 1:
F-3, F-7, F-8; Runde 2: N-1 — jetzt kleiner: eine Nebenzusage), *Design stützt sich auf eine aus einem Header gefolgerte
Eigenschaft* (B-2).

**Verdikt:** annahmefähig; der Acceptance-Trigger ist erfüllt. B-1 bis B-3 sind Darstellung/Beleg-Seite und gehören in die
Umsetzung (Fitness-Zeilen) oder als Satz in die ADR, sie hindern die Annahme nicht.

## Sensoren dieser Runde

`git diff 9f79188f 0a6d0a86` (ADR); `docker run --rm --pull=never --entrypoint sh <Bild>` für vier `sh`-Arithmetik-Messungen,
Werkzeug-/Builtin-Bestand, Blob-Stand-Rezept, `curl -H @<Datei>`-Probe, `-e TAP_TOKEN` gegen `docker inspect` und
`/proc/1/environ` (Sentinel, kurzlebiger Container); ein anonymer `GET`/`HEAD` auf die Contents-Schnittstelle (nur lesen);
GNU Make 4.3 im Scratchpad für die Übergabe-Wege; `git check-ref-format`. Nicht gefahren: `make mutate` (Auftrag),
`make test`, `make full-smoke`, der authentifizierte Lese-Pfad (`gh`). Das Ergebnis von `make gates` nach beiden Commits steht
im Bericht am Ende des Laufs.

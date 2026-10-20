# Verifier-Report: slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft

Rolle Verifier. Stand HEAD 1ae09d73 (Basis 62fd6c95). Bezug: LH-QA-01, LH-QA-02, ADR-0033.
Gelesen: Slice-Plan, Diff Basis..HEAD (anwenden.go, anwenden_test.go, export_test.go, full-smoke.sh, Faelle 771-773, sensors/full-smoke.md, e2e-abdeckung.md), Review-Report.

## Mutations-Ergebnis vom CI-Branch
- `git fetch origin mutate/slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft-1ae09d73` gelingt (Ref liegt, Commit 1ae09d73), aber `git show FETCH_HEAD:mutate-ergebnis.txt` -> `fatal: path 'mutate-ergebnis.txt' does not exist`. Befund: Ergebnis fehlt (Lauf lief laut Auftrag noch). Nicht gewartet, Branch nicht geloescht (kein Ergebnis gelesen). Der Planner liest das Ergebnis nach.
- Ersatz: die drei Faelle selbst gefahren (s. u.).

## Verdikte je DoD-Punkt
- **L1 Rueckleseprobe in der Operation: bestaetigt.** `pruefeArchiv` (anwenden.go) laeuft in `inhaltsSchritt` nach dem Schreiben, vor Stubs/Loeschung/Staging; Zip-Open, jeder Eintrag bis Ende gelesen (CRC), Namen und Bytes gegen Quelle, fremd/doppelt/fehlt. Test `TestAnwendenBrichtVorDemKuerzenAb` hat 6 Unterfaelle (abgeschnitten, bytes-verfaelscht, gueltig-andere-bytes, fehlt, fremd, doppelt), misst Fehlertext (Archiv + Eintrag), Original-Volltext, Review-Report, 1 Commit/0 add/kein rm, Zip bleibt liegen.
  - Rot-Beleg (a), selbst gefahren: `pruefeArchiv(...); false && err != nil` per sed im Arbeitsbaum, `make test-go`, danach `git checkout` (Baum sauber). Ausgabe: alle 6 Unterfaelle `--- FAIL: TestAnwendenBrichtVorDemKuerzenAb/<name>` mit `anwenden_test.go:749: defektes Archiv: want Fehler, got nil — die Rueckleseprobe laeuft nicht`. Ursache ist die gepinnte.
  - (c) Abbruch vor Kuerzen/Stubs: durch Lesen der Reihenfolge im Code (Probe zwischen `schreibeZip` und den Folgeschritten) und durch die Baum-Assertions des Tests belegt. NICHT gefahren: eine Umstellung der Probe hinter das Kuerzen. Die Assertions (Original ungekuerzt, 0 add, kein rm) wuerden dabei rot; gelesen, nicht gebrochen.
  - Zusage-Grenze im Doc-Kommentar stimmt: defektes Zip bleibt auf Platte (Test haelt es), Haltbarkeit nicht zugesagt (Risiko 1 entfallen, deckt sich).
- **L2 Zahn im E2E: bedingt bestaetigt.** `archiv_gueltig` (full-smoke.sh) liest per `unzip -t` + `unzip -lq` im `BATS_IMAGE` (Makefile-Pin, `--network none`, ro-Mount), an den drei Stellen. `# expect:` pinnt in 772 "besteht die Leseprobe nicht", in 773 "altbestand/archiv.zip ist nicht gelesen und vollstaendig".
  - Rot-Beleg (b), gefahren: `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES='772-… 773-…' MUTATE_JOBS=1 make mutate` -> `772 … -> besteht die Leseprobe nicht rot`, `773 … -> altbestand/archiv.zip ist nicht gelesen und vollstaendig rot`, `2 ok, 0 Befund(e)`. Das Zip ist das reale, das `make archive-welle` im Ziel schreibt (Traeger aus dem Arbeitsbaum, Writer-Close entfernt).
  - Abweichung vom Plantext: der Plan nennt "Fall mit verfaelschtem Zip"; die Fall-Zaehne sind ein ABGESCHNITTENES Zip (Eintrag-Verfaelschung liegt nur im Unit-Test L1). Fuer die Zusage "Validitaet" ausreichend, aber nicht wortgleich.
  - Offene Luecke (im Sensor-Doc benannt, nicht verdeckt): die dritte Stelle (gefetchter Release-Traeger) hat keinen Mutationsfall; Stelle 1 und 2 sind rot gesehen. Stelle 1 wird nur ueber 772 (Stufe vor Altbestand) belegt, Stelle 2 ueber 773.
  - `archiv_gueltig` prueft Lesbarkeit und Eintragsnamen, nicht Byte-Gleichheit; so im Kopfkommentar und in sensors/full-smoke.md benannt, Byte-Gleichheit traegt allein die Probe des Traegers.
  - Aufruf-Zusage: Fall 772/773 laufen ueber `make mutate` -> full-smoke; die Zahn-Meldung ist die Stufe-Meldung, kein Exit-Satz zugesagt.
  - Hinweis (kein Befund): die Kurzbeschreibung der Stufen 7/8 in e2e-abdeckung.md nennt die Archiv-Leseprobe nicht; sie bleibt wahr, ist aber enger als der Sensor.
- **L3 Mutations-Fall: bestaetigt.** `771-archiv-rueckleseprobe-ausgehebelt.sh` `# expect: TestAnwendenBrichtVorDemKuerzenAb`, `# verify: test-go`. `make mutate-greift` -> `759 Fall/Faelle, 759 greifen, 0 Befund(e)`. `MUTATE_CASES=771 make mutate` -> `771 … OK (8.70 s) -> TestAnwendenBrichtVorDemKuerzenAb rot`, `1 ok, 0 Befund(e)`.
- **`make gates` gruen:** siehe unten (Stempel).
- Review-Report liegt vor (2 LOW behoben in c589bb0e/1ae09d73, 2 INFO) — Planner-Sache, kein Haken gesetzt.
- Closure-Punkte (Notiz, Register, Risiko-Ausgaenge, Paarungen): Planner; §7 ist unausgefuellt (erwartet).

## Weitere Pruefungen
- Docker-only: kein Host-`unzip` im Diff; Pin aus `Makefile` (`BATS_IMAGE ?= bats/bats@sha256:e8f18e0a…`), `git diff Basis..HEAD -- Makefile` leer, kein neuer Pin. `unzip` sonst nur in baseline-verify.sh als Kommentar.
- e2e-abdeckung.md: `make e2e-abdeckung` -> "unveraendert — 48 Stufen, 48 Deklarationen", `git status` sauber. Der Diff der Datei besteht nur aus verschobenen Zeilennummern (`full-smoke.sh:N`); Texte byte-gleich (per Normalisierung der Nummern verglichen, keine Differenz).
- Abgrenzungen: `[untergrenze]`/`[haenger]` nicht im Diff beruehrt; Archivformat (`Zip`) und Stubs unveraendert; Wellen-/Slice-Auswahl unberuehrt. Mehr als der Plan: `export_test.go` und `anwenden()` mit Schreibpunkt-Parameter — im Plan §3 als "injizierbarer Schreib-/Lesepunkt" angekuendigt, Produktverhalten unveraendert. Gebautes ohne Plan: Fall 772/773 (Plan nennt nur 771) und die Doku in sensors/full-smoke.md — dem DoD L2 zuordenbar, kein Widerspruch.
- Kommentare (3.7): Zusage/Grenze/Kopplung-Klassen, kein Befund-/Slice-Narrativ gefunden; Sensor-Namen als Zusage.
- Messzahlen (MR-089): in full-smoke.md keine Laufzeitzahl; die 8.70 s / 46 s oben sind meine Messungen, nicht im Repo.

## Ehrlich: Gefahren vs. Gelesen
- Gefahren: 6 Unterfaelle rot (Probe stummgeschaltet); 771, 772, 773 ueber `make mutate` ok; mutate-greift; e2e-abdeckung.
- Gelesen, nicht gefahren: Reihenfolge Probe vor Kuerzen als eigene Mutation; dritte Stelle; CI-Branch-Ergebnis (fehlt); Review-Report nicht neu bewertet.

## Offene Punkte fuer Planner/Architect
1. CI-Ergebnis `mutate-ergebnis.txt` nachlesen und den Branch danach loeschen.
2. Dritte full-smoke-Stelle ohne Mutationsfall; `archiv_gueltig` ohne Byte-Gleichheit — benannt, ggf. Register-Eintrag.
3. L2-Wortlaut "verfaelschtes Zip" vs. gelieferter "abgeschnittener" Fall — Planner entscheidet, ob der Wortlaut genuegt.
4. Risiko 2 (`BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache`): 772/773 pinnen die Ursache gezielt (Meldungstext der Leseprobe); Zaehler-Entscheidung Planner.

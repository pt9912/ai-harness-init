# Review-Report: releasing.md Schritt 7 (Verifier-Vorbehalte F-1 bis F-3) — Kurzrunde — 2026-09-25

**Review-Art:** Kurzrunde über eine einzelne Doku-Änderung (Modul 10). Geprüft wird gegen die Quellen
(Skript, bats-Fälle, `ADR-0066`, Zeile `make tap-check` der Sensors-Tabelle), nicht gegen eine DoD.

**Gegenstand:** Commit `6df654f5` (Rolle Implementer) — eine Datei, 26 Zeilen hinzu, 12 entfernt:
`docs/user/releasing.md`, Schritt 7 (Klasse 2, Exit-Zeile samt Ausnahmen, Aussage „Bytes, keine
Versionen"). Nicht Gegenstand: die übrige Prozedur.

**Plan-Bezug:** Slice `slice-tap-nachzug-ist-schritt-der-release-prozedur` (geschlossen); die Änderung zieht die
Vorbehalte F-1 bis F-3 aus `docs/reviews/2026-09-25-verify-slice-tap-nachzug-ist-schritt-der-release-prozedur.md`.
Rechtsgrundlage: `LH-QA-02`, `ADR-0064`, `ADR-0066`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13) · **Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eigene Sensor-Läufe** (kein Host-Go, kein `make mutate`, kein Tap-Schreibzugriff, Prüfgegenstand nach jedem
Eingriff per `git checkout -- <datei>` und `git status --short` (leer) wiederhergestellt):

- `make tap-check TAG=v9.9.9` → `tap-check: Asset nicht auffindbar: … (HTTP 404) — es wurde nichts verglichen` ·
  `tap-check: Exit 2` · `make: *** … Fehler 2`, Prozess-Exit 2.
- `make tap-check TAG=v0.2` → `tap-check: Tag-Form falsch: v0.2 — erwartet …` · `tap-check: Exit 2`, Prozess-Exit 2;
  **ohne** den Satz „es wurde nichts verglichen".
- `DOCKER_HOST=tcp://127.0.0.1:1 make tap-check TAG=v0.2.4` → Docker-Meldung, dann `… der Transport im Bild endete ohne
  Ergebnis der Nutzlast (docker Exit 1) — das Ergebnis des Vergleichs ist unbekannt` · `tap-check: Exit 2`.
- `grep -ci version harness/tools/tap-nachzug.sh harness/tools/tap-nachzug-nutzlast.sh` → `0` je Datei.
- Mutation im Scratch-Zustand (bats-Bild des Makefiles, `--network none`, `test/tap-nachzug.bats`, 37 Fälle; Mutation in
  `gleich()` der Nutzlast, danach zurückgesetzt): siehe M-1.
- Wegwerf-Makefile im Scratchpad (`@kill -TERM $$$$` als Rezept): `make -C <dir> t` → `make: *** [Makefile:2: t] Beendet`,
  Prozess-Exit **2** (nicht 143); siehe L-2.
- `grep -nE 'Schritt(e)? [0-9]' docs/user/releasing.md`: Verweise auf Schritt 1, 3, 4, 5, 6, 7, 8 lösen gegen die Nummern
  1 bis 8 (`grep -n '^[0-9]\. \*\*' docs/user/releasing.md`) unverändert auf.

## Findings

### M-1 — MEDIUM — Zusage „der Vergleich liest keine `version`-Zeile" ist vom genannten bats-Fall nicht gebunden

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.6 (Zusage ohne rot gesehenes Gegenbeispiel; ein Test bindet die Eigenschaft, nicht ihre heutige
  Implementierung)
- `pfad`: `docs/user/releasing.md:160-171`, Bezug `test/tap-nachzug.bats:251`
- `befund`: Der Text sagt „Sie vergleicht Bytes, keine Versionen: der Vergleich liest keine `version`-Zeile … Die Eigenschaft
  hält der bats-Fall `version-zeile: in check kein Gegenstand …`". Der Fall fährt ausschließlich **gleiche Bytes** (Asset und Tap
  identisch, einmal mit `version "0.08.3"`, einmal ohne `version`-Zeile) und erwartet Exit 0. Ein Vergleich, der die
  `version`-Zeilen liest, färbt ihn nur, wenn er auf gleichen Bytes scheitert; ein Versions-Vergleich auf **ungleichen** Bytes
  liegt außerhalb dessen, was der Fall misst. Die Aussage trägt damit mehr, als der Beleg bindet; der Satz danach nennt den Inhalt
  des Falls korrekt („gleiche Bytes enden mit Exit 0 …"), die Überschrift der Eigenschaft davor nicht.
- **Messbeleg / Gegenprobe:** Mutation in `gleich()` von `harness/tools/tap-nachzug-nutzlast.sh`, Zweig „cmp meldet Unterschied":
  liest die `version`-Zeile aus Asset und Tap und gibt `return 0`, wenn die Tap-Version **größer** ist (ein Vorwärts-Schutz-Ersatz).
  Lauf `test/tap-nachzug.bats`: `1..37`, **kein** `not ok` — die Mutation überlebt die ganze Datei, der Fall `version-zeile`
  eingeschlossen. Gegenprobe der Wirksamkeit (dieselbe Stelle, Bedingung `!=` statt `>`): `not ok 3` (`vorfall nachgestellt …`),
  `not ok 29` (`exit-zeile …`), `not ok 34` (`unterschied …`) — die Mutationsstelle wird erreicht, das Überleben der ersten
  Mutation ist also kein Leerlauf.
- `verifizierbar`: ja (der Lauf oben; `make test` fährt die Datei)
- `klasse`: „Doku-Zusage über eine Eigenschaft, deren benannter Test nur einen Ausschnitt (gleiche Bytes) misst"

### L-1 — LOW — „jeweils" der Klasse-2-Beispiele ist mehrdeutig zugeordnet

- `kategorie`: LOW · `quelle`: Maintainability (Doku-Drift, `AGENTS.md` §3.7 Zustandsform: was da ist, gilt genau)
- `pfad`: `docs/user/releasing.md:131-137`
- `befund`: „eine falsche Tag- oder Feldform (`Tag-Form falsch`, `Feldform falsch`), ein nicht auffindbares Asset (HTTP 404) und
  ein Tap, das sich nicht lesen lässt (jeweils `es wurde nichts verglichen`)". Die Klammer steht hinter dem dritten Glied; ein
  Leser kann „jeweils" auf alle drei Beispiele beziehen. Für die Form-Meldungen trifft das nicht zu: `harness/tools/tap-nachzug.sh`
  Zeilen 123 und 131 tragen den Satz nicht (Messbeleg: `make tap-check TAG=v0.2`, oben). Für Asset und Tap gilt er
  (`harness/tools/tap-nachzug-nutzlast.sh` Zeilen 83, 97 bis 99, 111). Die Zuordnung der übrigen Beispiele stimmt: der
  Docker-Ausfall trägt `das Ergebnis des Vergleichs ist unbekannt` (Zeile 171 des Skripts, gemessen).
- `verifizierbar`: ja (Lauf `make tap-check TAG=v0.2` gegen den Text; kein Gate)
- `klasse`: „Sammelklammer über Beispiele mit verschiedenen Meldungen"

### L-2 — LOW — „der Prozess endet mit 128 plus der Signalnummer" steht in einem `make`-Absatz und ist über `make` nicht gemessen

- `kategorie`: LOW · `quelle`: `ADR-0066` Festlegung 2 §Nicht zugesagt; `AGENTS.md` §3.6
- `pfad`: `docs/user/releasing.md:142-146`
- `befund`: Der Satz folgt auf „Über `make` endet jeder Fehlschlag mit Prozess-Exit 2" und nennt für ein Signal „der Prozess
  endet mit 128 plus der Signalnummer". `ADR-0066` misst das am **Skript im Direktaufruf** (`exit=143`, 0 Bytes stderr). Über
  `make` liefert ein Signal an das Rezept-Kommando Prozess-Exit **2** mit `make: *** … Beendet` (Messbeleg oben, Wegwerf-Makefile);
  128 plus Signalnummer gilt dort nur, wenn `make` selbst das Signal erhält. Der Text nennt nicht, welcher Prozess gemeint ist; wer
  ihn über `make` liest, erwartet 143 und findet 2. Die Aussage „die Klasse fehlt, keine der drei Klassen ist gemeint" bleibt
  richtig. Gleicher Wortlaut steht in der README-Zeile `make tap-check` und im Kopfkommentar des Makefile-Ziels (dort nicht Gegenstand
  dieses Commits).
- `verifizierbar`: ja (Wegwerf-Makefile-Sonde; kein Gate)
- `klasse`: „Messung am Skript als Aussage über den `make`-Aufruf gelesen"

### I-1 — INFO — Bei nicht beschreibbarer stderr ist nach `ADR-0066` auch die Klasse nicht zugesagt; der Text nennt nur die Zeile

- `pfad`: `docs/user/releasing.md:142-148`; Quelle `ADR-0066` Festlegung 2, §Nicht zugesagt („Bei nicht beschreibbarer stderr ist
  auch die Klasse nicht zugesagt … ein Formel-Unterschied endet dort als Klasse 2")
- `befund`: Der Text deckt die drei Ausnahmen der **Zeile** wörtlich nach der ADR (Signal · nicht beschreibbare stderr · fehlender
  oder unbekannter Modus; „nur im Direktaufruf" stimmt: `grep -rn 'tap-nachzug.sh' Makefile .github` findet einen Aufruf, `Makefile:493`
  mit festem `check`). Die zusätzliche Aussage der ADR für stderr (Klasse 1 kann als Klasse 2 enden, die sichere Richtung) steht im
  Text nicht, während Klasse 1 zwei Absätze davor ohne Vorbehalt steht. Sichere Richtung, kein Fehlgrün; deshalb nur INFO, an die
  Rolle zur Kenntnis, die den Text führt.
- `verifizierbar`: nein (Aussage über eine Umgebungsbedingung, kein Gate)
- `klasse`: „Ausnahme einer Zusage nur zur Hälfte übernommen"

## Geprüft, ohne Befund

- **F-1, Definition Klasse 2** („ein Ergebnis des Vergleichs liegt nicht vor, die Ausgabe nennt die Ursache"): gegen alle `fehler`-Stellen
  von `tap-nachzug.sh` (Modus, Bild-Pin, `TAP_WAIT`, `TAG` leer, Tag-Form, Feldform, Transport) und der Nutzlast (Asset, Tap, `cmp`) —
  jede nennt eine Ursache; die Definition trägt, „nicht abschließend" deckt die nicht aufgezählten Ursachen.
- **F-1, Zuordnung** `Tag-Form falsch` / `Feldform falsch` / HTTP 404 / Tap nicht lesbar / Docker-Ausfall → Meldung: wörtlich gegen Skript
  und drei eigene Läufe; stimmt bis auf die Klammer in L-1.
- **F-2, Kommando:** `grep -ci version …` → `0` je Datei, wie angegeben; die zwei Fehlrichtungen (falsch-rot durch ein Kommentar-Wort,
  falsch-grün durch einen Versions-Vergleich ohne das Wort) sind richtig beschrieben und sagen nicht mehr zu als gemessen. Offen ist
  nur M-1 (der Beleg der Eigenschaft, nicht das Kommando).
- **F-3, Ausnahmen der Zeile:** Signal, nicht beschreibbare stderr, fehlender oder unbekannter Modus stimmen mit `ADR-0066` und der
  README-Zeile überein; kein Mehr, kein Weniger außer I-1 und L-2.
- **`AGENTS.md` §3.7:** Zustandsform, keine Konjunktive über verworfene Alternativen, keine Chronik, keine Rolle, kein Klon-Pfad; der
  Verweis auf `ADR-0066` ist Kennung mit ortsfestem Pfad (§3.11 nicht berührt).
- **`MR-025`:** die Zahl `0` steht neben dem Kommando, das sie liefert; `65 s` und `128` sind Festlegung/Definition, keine Messung.
- **Nummerierung der Schritte:** unverändert (oben).
- **HIGH-Liste des Skills:** keine ADR-/Hard-Rule-Verletzung (M-1 ist eine Zusage-Deckungslücke in Nutzerdoku, kein Gate-Pfad),
  keine Gate-Lockerung, kein Stilles-Grün-Pfad im Gate, kein halluziniertes Gate (`make tap-check` existiert, `Makefile:492`),
  keine superseded ADR, keine Norm im Template-Kommentar, kein Code-Kommentar geändert, kein Zustandsfeld berührt.

## Übergabe

Keine Korrektur an `docs/user/releasing.md` in diesem Lauf (Übergabe an den Implementer). M-1 verlangt vor dem Merge eine Klärung:
Aussage auf das einschränken, was der Fall bindet, oder den Beleg bis zur Aussage tragen. L-1 und L-2 sind Doku-Drift; I-1 Kenntnisnahme.

## Summary

Kurzrunde `6df654f5`: 0 HIGH · 1 MEDIUM (M-1) · 2 LOW (L-1, L-2) · 1 INFO (I-1). Wiederkehrende Finding-Klassen für die Closure:
„Doku-Zusage über eine Eigenschaft, deren benannter Test nur einen Ausschnitt misst" (M-1).

# Übergabe an den Architect — Nachfolge-Eintrag zu MR-071 §Grenze

**Von:** Implementer, slice-mutations-anker-greift-in-den-gates · **An:** Architect · **Datum:** 2026-10-09

**Gegenstand:** Liefer-Punkt 3 des Slice. Der Norm-Text entsteht im Architect-Lauf (AGENTS.md §3.8);
hier steht nur, was der Implementer-Lauf als Quelle liefert.

## Was mit dem Slice falsch wird

MR-071 §Grenze, zweiter Punkt: *„Kein Sensor hält die Anlage — … ein Struktur-Sensor über sed-Ankern
existiert nicht"*. Mit dem Slice gibt es einen solchen Sensor: Das Ziel `make mutate-greift`
(`harness/tools/mutate.sh --greift`) hängt an `record-gates` und läuft damit in `make gates`.

Der erste Punkt (*„Die Regel verlagert die Prüfung auf die Anlage, nicht auf den Lauf. Der Treiber
meldet … erst innerhalb des Fall-Ablaufs, hinter Isolationskopie und Grün-Vorlauf"*) beschreibt
weiterhin `make mutate`. Für den Greift-Modus trifft er nicht zu: Dort fällt die Meldung ohne
Isolationskopie des Baums und ohne Grün-Vorlauf, und zwar am Commit. Ob damit der erste
Auflösungs-Trigger von MR-071 (*„Wenn der Treiber das Verschieben schon vor der Isolationskopie
meldet"*) eingetreten ist, ist die Frage an den Architect.

## Vorschlag für den Kern des Nachfolge-Eintrags

- **Form:** neuer Eintrag mit Kopf-Marke an MR-071 nach MR-032 (Teil-Ablösung von §Grenze, Punkt 2;
  die Regel selbst und Punkt 3 bleiben).
- **Sensor:** `make mutate-greift`, in `make gates`. Je Fall werden die `# files:` auf eine Kopie
  außerhalb des Repos gelegt und der Patch angewandt. Jede Datei muss sich danach ändern, sonst gibt
  es einen Befund mit Fallname und Exit 1. Der Modus läuft ohne Grün-Vorlauf, ohne Sensor-Lauf und
  ohne Docker. Er ist rot an den Fall-Fassungen 29/247 aus `98bfab0b^` und grün an HEAD
  (`test/mutate-driver.bats`, Fälle „greift: …"). Den Zahn trägt
  `test/mutations/635-greift-modus-uebersieht-ungegriffenen-anker.sh`.
- **Grenze des Sensors:**
  1. Grün heißt *der Anker trifft*, nicht *der Wächter wird rot*. Das bleibt beim nächtlichen
     `make mutate`.
  2. Ein Anker, der trifft, aber die falsche Stelle trifft (Zeilennummer, zu breites Muster), geht
     durch. Das ist `BEO-ALL/mutations-fall-an-zeilennummer-verankert`, bewusst außerhalb des Slice.
  3. `# files:` und `# expect:` bleiben bei ihren Nachbar-Klassen. Der Modus meldet eine nicht
     auflösende `# files:`-Angabe, erkennt aber nicht, ob sie die *richtige* Datei nennt. `# expect:`
     liest er gar nicht.
  4. Ein Fall-Skript, das mehr als seine `# files:` braucht, scheitert in der Kopie und wird als
     Befund gemeldet. Im Bestand trifft das auf keinen der 621 Fälle zu
     (`bash harness/tools/mutate.sh --greift` auf dem Stand vor diesem Slice).
  5. **Verdrahtung Rezept → Modus** (Review M-1). Stand: gedeckt. `test/gate-nachweis-kante.bats`
     hält nur, dass `mutate-greift` an `record-gates` hängt. Was das Rezept tut, hält der Fall
     „greift: das Rezept von make mutate-greift faehrt mutate.sh --greift als Prozess …" in
     `test/mutate-driver.bats`; er liest das Rezept aus dem `Makefile` und fährt es als Prozess.
     Zahn: `test/mutations/636-greift-einstieg-faehrt-den-modus-nicht.sh`.
  6. **Präfix-Pfade in `# files:`** (Review M-2). Stand: gedeckt. Der Vergleich läuft je exaktem
     Pfad; bats-Fall „greift: ein Pfad, der Praefix eines anderen in # files: ist, …".
  7. **GNU-Werkzeuge auf dem Host** (Review M-3). Stand: offen, als Grenze benannt in
     `harness/sensors/mutate.md` §Greift-Modus. Die Fall-Skripte nutzen `sed -i` ohne Suffix und
     `\t` im Muster, der Treiber `mktemp -d -p`; der Modus läuft ohne Container. Ein Nicht-GNU-Host
     ist nicht gemessen. Eine Norm, die den Sensor nennt, sagt diese Bedingung mit.
  8. **`MUTATE_CASES` aus der Umgebung** (Review I-1). Stand: im Gate wirkungslos. Das Rezept
     `make mutate-greift` setzt `unset MUTATE_CASES` vor den Aufruf; beim Direktaufruf
     `bash harness/tools/mutate.sh --greift` engt es weiter ein. Gehalten vom Fall aus Punkt 5,
     Zahn `test/mutations/637-greift-rezept-laesst-mutate-cases-durch.sh`.
- **Beleg im Bestand:** Der erste Lauf über HEAD meldete die Fälle 145 und 147 als entwaffnet: Ihr
  Anker zitierte die Zeile vor `ac429eec`. Der Implementer-Lauf hat sie im eigenen Commit nachgezogen
  (`9fbc304c`). Ob das ein weiterer Beleg in
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` ist, entscheidet die Closure.

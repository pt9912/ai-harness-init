# Verifikation `slice-e2e-abdeckung-ist-deklariert-und-erzeugt` — 0 DoD-Verletzungen

**Rolle:** Verifier · **Datum:** 2026-09-16 · **Geprüfter Stand:** `6121b1a6` (Arbeitsbaum
sauber, Gate-Stempel deckungsgleich) — die Umsetzungskette `ce74fa41` · `54184620` ·
`aeafce6d` · `32ef9ef7` · `e85d33e3` · `6121b1a6` · **Verifikations-Art:** DoD-Konformität
gegen den tatsächlichen Baum (Modul 11), nicht Review.

**Eingang:** Slice-Plan
`slice-e2e-abdeckung-ist-deklariert-und-erzeugt` §1/§2/§3/§5/§6 · die zwei
Review-Reports (`…-verify`-Nachbar: Runde 1 und Runde 2) als **gelesen, nicht wiederholt** ·
`AGENTS.md` §3.6, §3.7, §3.9 · `LH-QA-01`, `LH-FA-01` · Baseline-Regelwerk `v6.8.0`
`modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen.

**Auftrag dieses Laufs.** Drei Liefer-Punkte plus der Halter der committeten Tabelle, dazu
`make gates`, Review, Doku-Update. **Nicht fällig** — Planner: die fünf unteren DoD-Zeilen
(Closure, Register, Risiko-Ausgänge, Paarungen). **Nicht Gegenstand:** die Findings der
beiden Reviews (sie sind geprüft und zu ihren Teilen geschlossen) und `LH-FA-11` in
`spec/lastenheft.md` (Architect-CR `b9c45ef0`, fremder Vorgang).

> **Zitier-Form.** Kennung statt Adresse für alles, was der Prozess bewegt; ortsfeste
> Code-Pfade als Inline-Code mit `Datei:Zeile`. Zahlen stehen neben dem Kommando, das sie
> liefert ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

---

## 1. Ergebnis je DoD-Punkt

| §2-Punkt | Verdikt | Beleg dieses Laufs (Sensor · Exit) |
|---|---|---|
| **(1)** Jede Stufe trägt ihre Deklaration, und die Deklarations-Form ist eine | **erfüllt** | `grep -cE '^echo "full-smoke: .* \.\.\."$' harness/tools/full-smoke.sh` → **16**; `grep -cE '^[[:space:]]*e2e_abdeckung "' …` → **16**; die Region jeder Stufe trägt **genau einen** Aufruf (awk-Region-Schnitt → 16×`1`). **Der Anker ist eine bestehende Zeile:** jedes der 16 dritten Argumente kommt im **Vor**-Zustand `c7fb4fb6` vor (`git show c7fb4fb6:harness/tools/full-smoke.sh | grep -cF "<Anker>"` → je 1 bzw. 2, kein 0) — keine neue Marke. Additivität: `git diff --numstat c7fb4fb6..HEAD -- harness/tools/full-smoke.sh` → `75 0`. **Laufzeit-Hälfte:** eigenes Gegenbeispiel gefahren (Abschnitt 4) |
| **(2)** `make e2e-abdeckung` erzeugt die Tabelle aus dem **Quelltext**, kein Gate | **erfüllt** | `bash harness/tools/e2e-abdeckung.sh orig.sh out.md` über einer `/tmp`-Kopie, **ohne Docker**: Exit 0, 16 Zeilen; zweiter Lauf → *„unverändert"*. **Kein Gate** an allen drei Stellen deckungsgleich: nicht in `record-gates` (`grep -n '^record-gates:' Makefile` → Zeile 450, das Ziel fehlt in der Liste), `kein Gate` **in der Zeile selbst** (`harness/README.md:73`), Eintrag in `targets.exempt-targets` (`.d-check.yml:104`). **Kopf sagt, was die Datei ist:** *„stabile Abdeckungs-Deklaration, kein Lauf-Beleg"* (`docs/user/e2e-abdeckung.md:4`). **Kennungsspalte:** jede Tabellenzeile trägt `lastenheft.md#` (16 von 16); **Beschreibungsspalte:** `awk -F'\|' '/^\| \[/{print $5}' docs/user/e2e-abdeckung.md \| grep -c 'LH-'` → **0**. **Rot gesehen** (Abschnitt 4) |
| **Halter der committeten Tabelle** in `make test`, nicht als Gate | **erfüllt** | `test/e2e-abdeckung.bats` Fall *„halter: die committete Tabelle ist der aktuelle Ausgang des Erzeugers"* — in `make gates` **grün** gefahren (`ok 112`), über einer Sandkasten-Kopie des geprüften Skripts, `cmp -s` gegen `docs/user/e2e-abdeckung.md` |
| **(3)** Beide Lücken-Richtungen fallen laut aus, ihr Rot ist hergestellt | **erfüllt** | Stufen-Menge **über ein Kriterium**, in beiden Trägern dieselbe Zeichenkette (`harness/tools/full-smoke.sh:93` und `harness/tools/e2e-abdeckung.sh:57`); Quelle und Ziel als Argumente (`Aufruf: … <quelle> <ziel>`, Exit 2 bei falscher Anzahl). Beide Richtungen **selbst rot gefahren** (Abschnitt 4) |
| `make gates` grün | **erfüllt** | `make gates` → **Exit 0**; darin `d-check: 1477 Datei(en) geprüft, 0 Befund(e)` |
| `make e2e-abdeckung` geschrieben, Stand committet, zweiter Lauf *„unverändert"* | **erfüllt** | `make e2e-abdeckung` zweimal über dem echten Ziel → beide Male `unverändert — docs/user/e2e-abdeckung.md (16 Stufen, 16 Deklarationen)`; danach `git status --porcelain` → leer |
| Review durchgeführt, Report in `docs/reviews/` | **erfüllt** | Zwei Reports, Runde 1 (merge-blockierend, F-1) und Runde 2 (`F-1` geschlossen, **nicht** blockierend); anderer Kontext als die Umsetzung |
| Doku-Update: Sensor nennt die Form, `harness/README.md` §Werkzeuge führt das Ziel | **erfüllt** | `harness/sensors/full-smoke.md` §Deklaration der Stufen (Zeilen 13–37: Aufruf-Form, Erzeuger, beide Richtungen, Halter mit seiner Gate-Reichweite) · `harness/README.md:73` mit `kein Gate` in der Zeile |
| Die fünf unteren DoD-Zeilen (Closure · Register · Risiko-Ausgänge · Paarungen) | **nicht fällig** | Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10) — dieser Lauf lässt sie offen, statt sie zu bestätigen |

**Befunde eigener Klasse (DoD-Verletzung): keine.** Die Klasse, die nur die Verifikation
fängt — Zusage im Plan, die der Baum nicht trägt — ist in diesem Lauf **nicht** aufgetreten.

---

## 2. Negativ-Aussage

Gemessen und **nicht** gefunden:

- **Keine Stufe ohne Deklaration** und **keine Deklaration ohne Stufe** über dem heutigen
  Baum: der Erzeuger läuft über dem geprüften Skript Exit 0 (16/16) — beide Lücken-Richtungen
  sind durch Konstruktion ausgeschlossen, nicht durch Sichtung.
- **Keine Zeile der Tabelle ohne Anker-Link**, **keine Kennung in der Beschreibungsspalte**.
- **Kein Gate-Anspruch am Erzeuger** an keiner der drei Stellen (Makefile-Liste, README-Zeile,
  `exempt-targets`), und **kein** Widerspruch zwischen ihnen.
- **Keine `Ort`-Angabe außerhalb der Datei** und keine tote: `make docs-check` ist über der
  committeten Tabelle grün, **und** die Einzelform ist dort tatsächlich geprüft (Abschnitt 3).
- **Keine Änderung an einer bestehenden Prüfung des E2E** (`75 0` — nur Hinzufügungen), also
  auch keine der §1-`NICHT`-Punkte berührt.

---

## 3. Risiko 2 aus §6 — gemessen, und der Ausgang ist *nicht* die benannte Lücke

**Frage:** prüft `codepaths.check-lines` des gepinnten d-check die **Einzelform** `file:NNN`
oder nur die Bereichsform `file:N-M`? Der Reviewer hat sie in beiden Runden **nicht**
nachgefahren; die Antwort entscheidet, ob die Spalte `Ort` überhaupt bewacht ist.

**Sonde** (zwei Läufe, je ein Sonden-Dokument unter `docs/`, danach entfernt; die Konfiguration
ist unverändert — `.d-check.yml:280-287`, `check-lines: true`, `roots: [spec, docs, harness]`):

| Lauf | Sonden-Inhalt | Ergebnis |
|---|---|---|
| rot | `` `harness/tools/full-smoke.sh:99999` `` | `make docs-check` → **Exit 2**: `docs/vfy-probe-codepaths.md:3  harness/tools/full-smoke.sh:99999-99999  citation-out-of-range  Zeilen-Referenz hinter dem Datei-Ende` |
| grün | `` `harness/tools/full-smoke.sh:266` `` | `make docs-check` → **Exit 0**, `1478 Datei(en) geprüft, 0 Befund(e)` |

**Antwort: ja — die Einzelform ist geprüft** (das Modul normalisiert sie intern auf
`NNN-NNN` und verlangt `bis <= Zeilenzahl`). **Damit ist Risiko 2 nicht eingetreten, und die
im Plan als Rückfall vorgesehene *„benannte Lücke" ist keine.** Die Spalte `Ort` ist doppelt
gebunden: das Gate hält die Zeilennummer gegen das Skript, der Halter hält die committete
Datei gegen den Erzeuger. Die Aussage im Kopf des Erzeugers („`make docs-check` prüft an der
Tabelle nur ihre Verweise") bleibt davon unberührt und richtig — die *Übereinstimmung* mit
dem Erzeuger prüft das Gate nicht; die Nummer gegen die Datei prüft es sehr wohl.

---

## 4. Die Rot-Belege dieses Laufs (eigene Messungen, `/tmp`-Kopien)

Alle über Kopien; der geprüfte Baum wurde in keinem Fall berührt (`git status --porcelain`
nach jeder Messung leer).

| Zusage | Mutation | Ergebnis |
|---|---|---|
| Richtung **(b)** Stufe ohne Deklaration fällt laut aus | Aufruf der Stufe 1 aus einer Kopie entfernt | Exit **1**, `FEHLER — Stufe ohne Deklaration … Stufe 1: 1/3 natives Release-Binary …  Region: mut_b.sh:257-269  Nachweis: sed -n '257,269p' mut_b.sh` |
| Richtung **(a)** Deklaration ohne auflösenden Anker fällt laut aus | **nur die Ankerquelle** (Zeile 266) der Kopie umgeschrieben, der Aufruf bleibt | Exit **1**, `FEHLER — Deklaration ohne Stufe … Deklaration: mut_a2.sh:258 … Anker: [das Release-Binary kam nicht auf den Host]  Region: …  Nachweis: …` |
| **Laufzeit-Hälfte** der Deklaration (§2(1): *„Der Aufruf läuft auch im E2E selbst und bricht ab"*) — der von Review-F-2 als **unbelegt** benannte Punkt | dieselbe Funktion **wörtlich** aus `harness/tools/full-smoke.sh` in einen Treiber übernommen, dessen Aufruf auf **derselben Zeilennummer** (258) steht, über einer Kopie als `$quelle` | **grün:** `Abdeckung der Stufe ab Zeile 257: LH-FA-01 … (Anker aufgeloest in /tmp/vfy/full-smoke.sh:266)`; **rot** (dieselbe Kopie mit umgeschriebener Ankerquelle): `FEHLER — Deklaration ohne Stufe … (…:257-271, Anker: […])`, Exit 1 |

**Was das trägt und was nicht.** Die Funktion ist damit **in beiden Richtungen rot gesehen** —
F-2s Feststellung „die Laufzeit-Hälfte hat ihr Gegenbeispiel nur an der Schwester-Implementierung"
trifft für den **Funktionskörper** nicht mehr zu; sie trifft weiter für die **Verdrahtung im
E2E-Prozess**: dass ein realer `make full-smoke`-Lauf die Deklarationszeile erreicht, ist aus
dem Kontrollfluss ablesbar (der Aufruf steht unmittelbar nach der Kopfzeile seiner Stufe, vor
jeder Arbeit der Stufe), aber **nicht beobachtet** — die Beobachtung kostete einen vollen
E2E-Lauf. Der Plan lässt die Stufen-Zahl ausdrücklich wandern (§1: *„keine Erwartungswerte"*),
und der heutige Baum führt **16** Stufen gegen die im Plan gemessenen **15** — die Substanz
von §2(1) (*jede* Stufe) hält, die Zahl nicht.

---

## 5. Plan-vs-Code-Diff (beide Richtungen)

**Geplant und vorhanden** — alle acht Zeilen der §3-Tabelle: `harness/tools/full-smoke.sh`
(Funktionskopf + 16 Aufrufe), `harness/tools/e2e-abdeckung.sh` (neu), `Makefile` (advisory-Ziel),
`docs/user/e2e-abdeckung.md` (erzeugt), `harness/README.md`, `.d-check.yml`,
`harness/sensors/full-smoke.md`, `test/e2e-abdeckung.bats` (neu), `test/mutations/` (neu).
Der Plan nennt die Mutationsdatei ohne Kennung; der Baum führt `362-e2e-stufe-ohne-deklaration.sh`
mit `# files: harness/tools/full-smoke.sh` — genau die Datei, über der der Wächter-Fall
`test/e2e-abdeckung.bats:44` fährt.

**Gebaut, nicht im §3-Plan** — und warum es keine Plan-Änderung ist:

| Gegenstand | Bewertung |
|---|---|
| `.claude/agents/{architect,implementer,planner,reviewer}.md` | **Budget-Zeile je Rollen-Karte**, je Commit von der Rolle selbst (`2e4726f1`, `9bb316f7`, Implementer-Commit). Setzung des Auftraggebers vom 2026-09-16, je Karte ein bis fünf Worte; kein Gegenstand dieses Slice — die Karte gehört der ausführenden Rolle ([`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) |
| `spec/lastenheft.md` | **`b9c45ef0` „Rolle Architect: LH-FA-11 im Lastenheft"** — angenommener Change Request, fremder Vorgang. Von diesem Auftrag ausdrücklich ausgenommen |
| `docs/reviews/…` (2 Reports) | Prozess-Artefakte des Reviews, kein Liefer-Punkt |
| Die Plan-Datei selbst | vom Planner in `aeafce6d` gezogen (§3.10) — Rückkante, kein Implementer-Zugriff |

**Der einzige Text-Diff gegen den Plan** ist damit die Stufen-Zahl (15 → 16, Abschnitt 4),
und sie ist von §1 selbst zugelassen.

---

## 6. Offengelegt — was dieser Lauf am Baum getan hat

`make gates` (Exit 0), `make e2e-abdeckung` **zweimal** über dem echten Ziel (beide Male
`unverändert`, keine Byte-Änderung — belegt durch leeres `git status --porcelain` danach),
zwei `make docs-check`-Läufe über einem **eigenen Sonden-Dokument** unter `docs/`
(`docs/vfy-probe-codepaths.md`, nach dem zweiten Lauf **gelöscht**; das Verzeichnis ist
wieder leer), der Erzeuger und die zwei Laufzeit-Sonden in `/tmp/vfy` bzw. `/tmp/vfy2`.
**Nicht gefahren:** `make mutate` (Auftrags-Grenze), `make full-smoke`, `make smoke`.

---

## 7. Was dieser Lauf nicht prüfen konnte

| Bereich | Grund |
|---|---|
| `make mutate` und damit die Zeile *„`make mutate` meldet den Fall als bewacht"* aus §5 | **Auftrags-Grenze.** Geprüft ist stattdessen die **Verdrahtung** (Kopf `# files:`/`# expect:`/`# verify: test-bats`, Treiber wählt die bats-Stufe und verlangt die Fehlschlag-Form `not ok [0-9]+`, `harness/tools/mutate.sh:589/747`) **plus** die eigene Messung, dass genau diese Mutation den Erzeuger auf Exit 1 zwingt (Abschnitt 4) — die Kausalität des Rot steht damit, der Treiber-Lauf nicht |
| Die Laufzeit-Hälfte **im echten E2E-Prozess** | nur ein voller `make full-smoke` erreicht sie (Abschnitt 4) |
| Inhaltliche Zuordnung *jeder* Deklaration zu ihrer Stufe | Urteil, kein Sensor — §6 Risiko 3, im Plan benannt und dort mit Ausgang bei der Closure |
| §6-Risiko-Ausgänge, §7, Register, Paarungen | Planner bei der Closure (§3.10) |
| Review-F-6 (LOW): der Rot-Beleg des Halters nennt einen Pfad, den die Messung nicht nimmt | **Auftrags-Grenze: nicht Gegenstand dieses Laufs**, beim Planner. Der **Punkt** trägt (der Fall fällt — belegt über die Exit-1-Hälfte, Abschnitt 4); seine **Begründung** nennt die Byte-Abweichung, die in dieser Lage nicht zum Zug kommt |

---

## 8. Verdikt

**Alle fälligen DoD-Punkte erfüllt — 0 Verletzungen.** Die drei Liefer-Punkte tragen am
heutigen Baum, ihr Halter läuft im Gate, und die zwei Lücken-Richtungen sind **in diesem
Lauf selbst** rot gefahren, nicht aus dem Implementer-Bericht übernommen.

**Was den Slice trägt, ist eine Entscheidung und kein Werkzeug:** der Anker als **bestehende**
Zeilenausschnitt — gemessen: jedes der 16 dritten Argumente stand schon im Vor-Zustand —, und
damit trägt die Deklaration ihren Ort aus dem Skript, das sie beschreibt, statt eine zweite
Marke zu pflegen, die driften könnte. Die Stufen-Menge ist in beiden Trägern dieselbe
Zeichenkette und keine Aufzählung; die Divergenz der zwei Träger fängt die Schluss-Invariante
des Erzeugers (`16 Stufen, 16 Deklarationen`), die über den Halter in `make gates` läuft.

**Risiko 2 aus §6 ist gemessen und fällt positiv aus** (Abschnitt 3): die Einzelform ist
bewacht, die im Plan vorgesehene Rückfall-Lücke entsteht nicht. **Risiko 1** (Textform der
Kopfzeile) ist im Sensor benannt, nicht geschlossen. **Risiko 3** bleibt der Rest ohne Sensor
und ist als solcher benannt. **F-2** ist für den Funktionskörper in diesem Lauf geschlossen,
für die Verdrahtung im E2E-Prozess nicht.

**Übergabe:** an den **Planner** — dieser Bericht als Beleg für die Closure-Fähigkeit der drei
Liefer-Punkte, §6-Risiko 2 mit seinem Ausgang (*nicht eingetreten*, gemessen), §6-Risiko 1 und 3
unverändert offen, Risiko 4 (`docs/user/` im Prüfbereich) **entfallen**: `make docs-check` ist
über der erzeugten Tabelle grün, die Link-Form des Hauses ist getroffen. Offen und **nicht** bei
mir: Review-F-5/F-6 (Planner bzw. erledigt) und die fünf unteren DoD-Zeilen. Dieser Bericht ist
ein Verifikations-Beleg, kein Review und keine Closure.

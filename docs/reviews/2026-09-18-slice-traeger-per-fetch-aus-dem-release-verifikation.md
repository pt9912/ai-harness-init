# Verifikations-Report: slice-traeger-per-fetch-aus-dem-release — 2026-09-18

**Verifikations-Art:** DoD-/ADR-Konformität plus Plan-vs-Code-Diff — geprüft wird,
ob der Code das umsetzt, was der (gezogene) Slice-Plan und ADR-0058 verlangen.
Nicht geprüft wurde gegen den Review-Report selbst; die drei gezogenen MEDIUM
(F-1/F-2/F-3) und die LOW/INFO (F-4/F-5/F-6) liegen als gezogene Commits vor
(`ff21ce71` Plan, `6353aa1a` ADR, `b2bd98c7` `.d-check.yml`) und sind hier als
Constraint-Eingabe gelesen, nicht erneut gerettet.

**Gegenstand:** `a2d21386` (ADR-0058, Proposed) · `14d7b6fd` (Implementer-Diff)
· `ff21ce71` (Plan gezogen) · `6353aa1a` (ADR geglättet) · `b2bd98c7` (F-4).

**Skill-Grundlage:** Baseline `v6.9.0` · `regelwerk/modul-11-verification.md`
(§Bewusstes Brechen für DoD-Testbehauptungen, §Regeln gegen typische
Fehlannahmen) — die Prüfgrundlage des Verifier steht im Slice (DoD, §1, §5, §6,
§8) und in ADR-0058; kein Skill-Artefakt nötig.

**Modell:** claude glm-5.3-flash · **Datum:** 2026-09-18

---

## Eingangs-Belege, die dieser Lauf NICHT wiederholt hat

- `make gates` grün am Kopf `b2bd98c7` (Auftraggeber-Angabe; nicht wiederholt).
- `make docs-check` 1704/0 (Auftraggeber-Angabe; im Zug der L3-Rot-Gegenprobe
  unten ist ein eigener Lauf mit demselben Zähler gefahren — dort am mutierten
  Baum, die Zahl ist der Ausschnitt des Laufs, nicht ein Repo-Urteil).
- Review-Runde 1 liegt vor (`docs/reviews/2026-09-18-slice-traeger-per-fetch-
  aus-dem-release-runde-1.md`); ihre zwei rot gefahrenen Gegenproben
  (Digest-Verifizierung umgangen, Deklarations-Zeile entfernt) werden hier als
  Beleg übernommen und nicht wiederholt.

## Die zwei Messungen, die der Reviewer ausdrücklich nicht gefahren hat

### 1. `make full-smoke` — §5-Closure-Trigger — gefahren, grün

`make full-smoke` → **EXIT 0** (Lauf dieses Berichts, Log 3143 Zeilen, 0
unerwartete FEHLER — die zwei FEHLER-Zeilen im Log sind die erwarteten
Negative-Demonstrationen der emittierten Selbstprüfung, je eine mit OK-Bestätigung).

Die neue Stufe fuhr am realen gebootstrappten Ziel (golang) mit ihren drei
OK-Zeilen (`harness/tools/full-smoke.sh` Stufe `traeger_fetch_im_ziel`):

- Fehlt-Fall: `make archive-welle` meldet die Abwesenheit mit Exit 0, nennt das
  Fehlende und schreibt nichts — der Fetch ist kein Prerequisite.
- Fetch: `make traeger-fetch` legt den Träger aus dem gepinnten Release ab,
  ausführbar, Digest vor der Ablage verifiziert — **real gegen das Release**
  (Netz), nicht gegen ein Fixture.
- Negative: der verdrehte sha256-Pin bricht nach EINMAL Laden laut, nennt die
  Digest-Abweichung, und der liegende Träger bleibt unangetastet.

**Reichweite der Aussage:** die Stufe misst am Ziel der Host-Plattform
(linux-amd64). Die „läuft"-Hälfte von `archive-welle` mit dem gefetchten
Träger ist im Lauf nicht gefahren und nicht behauptet — der GRENZE-Abschnitt
der Stufe (`full-smoke.sh:1537-1546`) trägt genau das: der v0.1.1-Träger führt
das Unterkommando nicht, der Aufruf startet dort den Init-Pfad, der laut-Bruch
gilt erst ab dem Release-Schnitt (ADR-0058 Festlegung 2 in der geglätteten
Fassung, Folgepflicht 3). Die Stufe behauptet keinen Erfolg, der nichts belegt.

### 2. sha256-Pins gegen die realen Assets — 2 von 6 selbst verifiziert

```sh
docker run --rm curlimages/curl@sha256:463eaf6072688fe96ac64fa623fe73e1dbe25d8ad6c34404a669ad3ce1f104b6 \
  sh -c 'curl -fsSL https://github.com/pt9912/ai-harness-init/releases/download/v0.1.1/ai-harness-init-linux-amd64 | sha256sum; \
         curl -fsSL https://github.com/pt9912/ai-harness-init/releases/download/v0.1.1/ai-harness-init-windows-amd64.exe | sha256sum'
# 654041d9c7a198435c9b32067a1c938b358174c28905d05dd94b44016d88b0bc  -
# 18d406f4c619339c6556c5602fd86fbf630022199ac9ad52cd777d64839103e7  -
```

Beide stimmen mit den Makefile-Pins überein (`TRAEGER_SHA256_LINUX_AMD64`,
`TRAEGER_SHA256_WINDOWS_AMD64` — der `.exe`-Fall eingeschlossen). Der Transport
lief im Container des gepinnten Bilds, nicht auf dem Host (AGENTS.md §3.9).

**Die Aussage deckt 2 von 6.** Die vier übrigen Pins (linux-arm64,
darwin-amd64, darwin-arm64, windows-arm64) sind von diesem Lauf **nicht**
gegen die Assets verifiziert — sie beruhen auf der Messung des Implementers.
Bricht einer davon, bricht der Fetch auf genau dieser Plattform fail-closed
(Exit, keine Ablage) — der Schaden ist ein sichtbarer Bruch am Fetch, keine
stille Korruption; die Messlücke bleibt trotzdem benannt (siehe Spec-Lücken).

## Negative-Richtung, selbst gefahren (Wegwerf-Ablage, realer Transport)

```sh
make --no-print-directory traeger-fetch TRAEGER_CARRIER=$TMPD/ai-harness-init \
  TRAEGER_SHA256_LINUX_AMD64=000...000
# traeger-fetch: Digest-Abweichung — ist 654041d9…, erwartet 000…000.
#   Der Traeger wird nicht abgelegt.  → Exit 2
```

Vor/Nach-Hash der Wegwerf-Ablage: byte-gleich. Die Verifizierung läuft **vor**
der Ablage; der abgebrochene Lauf hinterlässt den liegenden Träger unangetastet
(ADR-0058 Festlegung 1, Folgepflicht 2). Der Lauf fuhr den realen Container
(die Meldung nennt den Digest des real geladenen Assets — der zweite
unabhängige Treffer für den linux-amd64-Pin).

## DoD, Punkt für Punkt

| DoD-Punkt | Urteil | Beleg |
|---|---|---|
| **L1 — Fetch mit Pin** | **erfüllt** | Target `traeger-fetch` im Makefile (ohne Prerequisite), Pins kanonisch im Makefile, als `?=`-Default im emittierten Fragment gespiegelt (`internal/emit/templates/enforce/traeger.mk`) — dieselben 7 Werte (Tag + 6 sha256) plus `TRAEGER_CARRIER`, visuell identisch gelesen und von Fall 1 in `test/traeger-fetch.bats` gehalten (Klasse `test/sources-pin.bats`); Digest vor der Ablage (siehe Negative-Richtung oben); Fehlt-Fall Exit 0 in der E2E-Stufe gemessen. Rot-Gegenprobe L1 (Verifizierung umgangen → Negative-Fall rot an genau der Zusicherung, Fall **bindet**): vom Reviewer gefahren, hier übernommen |
| **L2 — E2E-Stufe am realen Ziel** | **erfüllt, mit Wortlaut-Abweichung in der Reihenfolge** | Stufe `traeger_fetch_im_ziel` in `harness/tools/full-smoke.sh`, grün gefahren (siehe oben); GRENZE-Abschnitt (`full-smoke.sh:1537-1546`) trägt den Messbefund „läuft"-Hälfte erst nach dem Release-Schnitt, still startend am gepinnten Stand — passend zur **geglätteten** Festlegung 2; OK-Zeilen nennen nur das Gemessene; Kopfzeile im Stufen-Muster (`full-smoke.sh:1516-1518`) und Deklaration → `docs/user/e2e-abdeckung.md` Stufe 4, der Halter-Fall in `test/e2e-abdeckung.bats` hält die Tabelle als Erzeuger-Ausgang; Rot-Gegenprobe (Deklarations-Zeile entfernt → Fall 1 und Fall 5 rot): vom Reviewer gefahren, übernommen. **Abweichung:** der Plan sagt „frischer Klon ohne Träger → Fetch → …; der **anschließende** `archive-welle`-Aufruf endet an der dokumentierten Grenze" — die Stufe ruft `archive-welle` **vor** dem Fetch (am Klon ohne Träger) und nach dem Fetch **gar nicht**. Die Substanz ist getroffen: ein Aufruf *nach* dem Fetch stünde am gepinnten Stand nicht an der dokumentierten Grenze (der Träger läge ja), sondern startete still den Init-Pfad — einen Bootstrap-Versuch mit Seiteneffekten im Mess-Klon; die Grenze, die der Plan meint, ist die Fehlt-Fall-Zusage (ADR-0033 Festlegung 4), und die misst die Stufe. Der Wortlaut „anschließend" ist trotzdem zu ziehen — Planner-Arbeit |
| **L3 — Doku** | **Zeile erfüllt; die behauptete Rot-Gegenprobe nicht erfüllt** | `harness/README.md` Zeile 80: Target genannt, „kein Gate" in der Zeile, Halbsatz was es stattdessen tut, Netz-Bedarf benannt; `docs/user/e2e-abdeckung.md` regeneriert (Halter-Fall grün). **Aber:** die Rot-Gegenprobe sagt „nennt die Werkzeuge-Tabelle das Target mit Gate-Anspruch, färbt `make docs-check` (Modul `targets`) rot". Selbst gefahren: der Werkzeuge-Zeile der Stempel `kein Gate ·` entfernt, `make docs-check` → **1704 Datei(en) geprüft, 0 Befund(e), EXIT 0** — der genannte Sensor urteilt nicht über die Klasse der Zeile, das rot ist unter ihm **nie gesehen worden und nicht sehbar** (AGENTS.md §3.6: die Zusage ist breiter als ihr Sensor). Der angrenzende Wächter anderer Bauart existiert: `test/targets-modul-wiring.bats` hält „kein exempt-targets-Eintrag ist zugleich eine Sensors-Tabellenzeile" — das fängt eine *andere* Mutation (Zeile in der Gate-Tabelle), nicht das fehlende „kein Gate" in der Werkzeuge-Zeile. Übergabe-Artefakt an den Planner (siehe unten) |
| `make gates` grün | erfüllt (übernommen) | Auftraggeber-Angabe zum Kopf `b2bd98c7`; nicht wiederholt |
| Review durchgeführt, Report liegt vor | erfüllt | Runde 1 in `docs/reviews/`, 0 HIGH |
| Doku-Update bei öffentlichem Vertrag | erfüllt | = L3 (README-Werkzeuge-Zeile, E2E-Sicht) |
| Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge §6, drei Paarungen | **ausstehend — nicht prüfbar in diesem Lauf** | Closure ist Planner-Arbeit in frischem Kontext (AGENTS.md §3.10); dieser Bericht ist ihre Eingabe. Die Risiko-Ausgänge aus §6 sind hier noch offen und gehen in die Closure: Risiko 1 (Fassungs-Drift) ist durch die Architekt-Entscheidung (ADR-0058, prozeduraler Fit, Release-Schnitt als Folgepflicht 3) mit Ausgang versehen-fähig; Risiko 2 (Emission berührt sich selbst) — keine Lücke gefunden, die weder bats noch E2E-Stufe deckt (Ausgang: entfallen-fähig); Risiko 3 (Fehlt-Fall-Zusage) — gemessen in bats Fall 8 und E2E (a), Ausgang: entfallen-fähig. Das Urteil über die Ausgänge fällt in der Closure, nicht hier |

## §5 Closure-Trigger

„DoD vollständig mit roten Gegenproben der drei Liefer-Punkte belegt, und
`make full-smoke` grün über der neuen Stufe."

- `make full-smoke` grün: **gefahren, EXIT 0** (dieser Bericht).
- Rote Gegenprobe L1: belegt (Review, Fall bindet).
- Rote Gegenprobe L2: belegt (Review, Fall 1 + Fall 5 rot).
- **Rote Gegenprobe L3: unbelegt** — der benannte Sensor färbt bei der
  behaupteten Mutation nicht rot (eigene Messung oben). Der §5-Zustand „mit
  roten Gegenproben **der drei** Liefer-Punkte belegt" ist damit **nicht
  vollständig**. Das ist keine Verletzung der Lieferung, sondern der Beleglage:
  ein DoD-Punkt, der nicht erfüllt ist, geht als Übergabe-Artefakt an den
  Planner (§3.10) — dieser Bericht schreibt den DoD nicht um und repariert
  nichts.

## ADR-0058 als Constraint — Festlegung für Festlegung

| Festlegung | Urteil | Beleg |
|---|---|---|
| 1 — Pin `v0.1.1` + sha256 je Asset, kanonisch im Makefile, gespiegelt in der Emission, fail-closed gekoppelt | erfüllt | Makefile-Zeilen 42-50; Fragment `traeger.mk` trägt dieselben Werte; `test/traeger-fetch.bats` Fall 1 hält die Kopplung; 2 von 6 Digests unabhängig verifiziert (siehe oben) |
| 2 — Kein Stempel; Fassungs-Fit prozedural; **geglättete Fassung:** am gepinnten Stand bricht der Aufruf still (Init-Pfad), der laut-Bruch ist Zusage an den Release-Schnitt | erfüllt — passend zur geglätteten Fassung | Keine Stempel-Logik in `internal/emit` (kein Fassungs-Schreibzugriff); der Code hängt an keiner Stelle vom laut-Bruch ab; GRENZE-Abschnitt der E2E-Stufe und bats-Kommentare tragen die still-Start-Form; die ADR-Messung reproduziert: `grep -c 'case "' cmd/ai-harness-init/main.go` → **4** (vier Fälle, kein Default) |
| 3 — Eigenes Fragment `harness/mk/traeger.mk`, eigenes Target, kein Prerequisite, nichts an `GATE_CHECKS` | erfüllt | `internal/emit/traeger.go` registriert Fragment (Konvergent, 0644) und Skript (0755) UNBEDINGT; `grep -c 'traeger' internal/emit/templates/enforce/archivierung.mk` → **0** (das Archivierungs-Fragment ist unberührt); `archive-welle` hat weiterhin nur `host-bin` als Prerequisite; Dogfood-Target im Makefile ohne Prerequisite |
| 4 — Transport im gepinnten Docker-Bild | erfüllt | `TRAEGER_IMAGE` digest-gepinnt (`curlimages/curl@sha256:463eaf…`), digest-Form wird fail-closed geprüft (Exit 2 bei floatingem Tag); `curl` läuft nur im Container-Payload — kein `curl`/`wget` in der Befehlsposition auf dem Host; live gemessen (beide Läufe oben) |
| 5 — Verhältnis zu ADR-0033: Schärfung, kein `Supersedes`; Fehlt-Fall unangetastet | erfüllt | Fehlt-Fall Exit 0 mit Meldung und ohne Schreiben in der E2E-Stufe gemessen; kein Prerequisite, kein Automatismus (bats Fall 8 + Makefile) |

Die Fitness-Function-Tabelle der ADR ist in allen vier Zeilen gedeckt (bats
Kopplung · bats Digest fail-closed · bats Fehlt-Fall-Form + E2E real ·
`make full-smoke`).

## Abgrenzung §1 — die vier Ausschlüsse gehalten

| Ausschluss | Urteil | Beleg |
|---|---|---|
| Deklaration der bestehenden Archivierungs-Stufe | gehalten | Der Implementer-Diff (`14d7b6fd`) berührt die Archivierungs-Stufe nicht; die Sicht führt 19 Zeilen, die Alt-Stufe steht weiterhin außerhalb |
| Kein eigener Fetch-Weg für `span-report`/`span-clean`/`hook-overhead` | gehalten | Alle drei Targets unverändert (`host-bin`-Basis, Makefile-Zeilen 351/366/384); kein zweiter Träger-Weg im Diff |
| Kein Signier-Schritt, keine zweite Asset-Prüfung | gehalten | Der Fetch prüft den Digest, keine Signatur-Logik im Skript; die README-Zeile sagt genau das |
| Kein Release-Schnitt | gehalten | Kein Release-/Workflow-Artefakt im Diff (`git show 14d7b6fd --stat`: 15 Dateien, keine unter `.github/`, keine Release-Logik) |

## Plan-vs-Code-Diff

**Geplant und gebaut, Deckung vollständig:** `internal/emit` (Pin-Default im
Fragment, `traeger.go` + `enforce.go`-Registrierung statt Stempel-Logik — je
Architekt-Entscheidung, Frage 1) · Dogfood-Makefile mit demselben Target und
denselben Pins · `harness/tools/full-smoke.sh` neue Stufe ·
`test/traeger-fetch.bats` (neu, 8 Fälle) · `test/e2e-abdeckung.bats` (Halter
deckt die neue Deklaration) · `docs/user/e2e-abdeckung.md` regeneriert ·
`harness/README.md` Werkzeuge-Zeile.

**Gebaut, aber nicht im Plan §3 gestanden** (drei Mitbewegungen, keine davon
durch §1 ausgeschlossen — die Plan-Kante „Wer später etwas mitnimmt, das hier
ausgeschlossen war" greift nicht; sie sind die mechanische Folge des
Target-Zuwachses und vom Review als solche gelesen):

1. `.d-check.yml`: `traeger-fetch` in `exempt-targets` (notwendig, sonst fände
   `gate-undocumented` ein Makefile-Target ohne Tabellenzeile) plus die
   Kommentar-Korrektur F-4.
2. `harness/sensors/docs-check.md`: die Target-Zahl 37 → 40 (Zustandskorrektur
   am lebenden Register, mit Kommando daneben).
3. `harness/conventions.md` §Zusatzklassen-Deklaration: Zählung fortgeschrieben
   (derivatives Register, ADR-0024-Lesart des Reviews).

**Wortlaut-Abweichung Code ↔ Plan:** L2 „der anschließende `archive-welle`-Aufruf"
gegen die Stufe, die den Aufruf **vor** dem Fetch misst und nach dem Fetch
weglässt (Begründung oben — nach dem Fetch gäbe es an der gepinnten Fassung
keine dokumentierte Grenze mehr, sondern den stillen Init-Pfad). Substanz
getroffen, Wortlaut zu ziehen.

**Nicht gebaut, was der Plan als offene Frage gestellt hat:** nichts — die zwei
Fragen aus §1 sind von ADR-0058 entschieden (Pin im Makefile + Emissions-Default,
eigenes Fragment, kein Prerequisite) und so umgesetzt.

## Spec-Lücken und Übergabe-Artefakte an den Planner

1. **L3-Rot-Gegenprobe unbelegt (DoD-Verletzung, §3.10).** Der DoD-Punkt
   behauptet eine rot färbende Mutation am Modul `targets`, die der Sensor
   nicht sieht — selbst gemessen: Werkzeuge-Zeile ohne „kein Gate"-Stempel,
   `make docs-check` → 1704/0, EXIT 0. Entweder den DoD-Punkt auf den
   tatsächlichen Wächter ziehen (`test/targets-modul-wiring.bats`, der die
   Disjunktion exempt-targets ↔ Gate-Tabellenzeile hält — eine andere Mutation),
   oder die Lücke als benannte Klasse stehen lassen (§3.6: benannt, nicht
   geschlossen). Der DoD im heutigen Wortlaut ist mit der Behauptung nicht
   schließbar.
2. **L2-Wortlaut „anschließend"** — siehe oben; Substanz gedeckt, Reihenfolge
   im Plan zu ziehen, damit der Plan sagt, was der Code tut.
3. **Vier von sechs sha256-Pins ohne unabhängigen Beleg.** Verifiziert sind
   linux-amd64 und windows-amd64.exe (dieser Bericht, Kommando oben); die
   übrigen vier beruhen auf der Implementer-Messung. Fail-closed bricht bei
   Abweichung sichtbar, aber ein falscher Pin bricht den Fetch auf genau der
   Plattform — für einen Adopter auf darwin/arm64 wäre das ein Befund, kein
   stilles Risiko. Nachziehen optional; benannt werden soll es.

## Negativbefunde — geprüft und nicht beanstandet

- **Pin-Kopplung (7 + 1 Werte):** Makefile und emittiertes Fragment tragen
  identische Werte (`TRAEGER_TAG`, sechs `TRAEGER_SHA256_*`, `TRAEGER_CARRIER`);
  Fall 1 des bats-Zahns hält die Kopplung; keine Abweichung.
- **Byte-Gleichheit des Transport-Skripts:** Dogfood
  `harness/tools/traeger-fetch.sh` ↔ emittiert
  `internal/emit/templates/enforce/traeger-fetch.sh` — Reviewer `cmp`
  byte-gleich, bats Fall 2 hält sie; keine Abweichung.
- **Kein Host-Transport (§3.9):** kein `curl`/`wget` in der Befehlsposition auf
  dem Host; beide eigenen Läufe dieses Berichts fuhren den Container; keine
  Abweichung.
- **Fail-closed vor dem Transport:** fehlender Pin und unbekannte Plattform
  brechen mit Exit 2 ohne Transport und ohne Ablage (bats Fall 5/6, gelesen);
  die Meldungen nennen die behauptete Ursache; keine Abweichung.
- **Fehlt-Fall-Zusage (ADR-0033 Festlegung 4, ADR-0058 Festlegung 3/5):** kein
  Prerequisite, nichts an `GATE_CHECKS`, `archivierung.mk` nenn-frei geprüft
  (`grep -c traeger … → 0`), `archive-welle` im Dogfood nennt den Fetch nicht;
  keine Abweichung.
- **Plattform-Matrix (LH-QA-04):** `.exe`-Asset und Ablage als
  `ai-harness-init.exe` (bats Fall 7 gelesen, `.exe`-Digest von diesem Bericht
  gegen das reale Asset verifiziert); Ablage-Namen gekoppelt mit
  `CarrierPath` in `internal/emit/enforce.go`; keine Abweichung.
- **Geglättete ADR-Fassung:** Festlegung 2 und Re-Evaluierungs-Trigger 2 sagen
  jetzt still-startend am gepinnten Stand; Implementation und E2E-GRENZE passen
  dazu, niemand hängt am laut-Bruch; keine Abweichung.
- **F-1/F-4/F-6 gezogen und wirksam:** Plan-Kopf nennt docker (F-1), der
  `.d-check.yml`-Kommentar zählt 4 ohne Hilfetext und nennt `traeger-fetch` in
  der 15er-Liste (F-4), die §8-Zahl trägt ihr Kommando (F-6); keine
  Beanstandung.
- **§8 des Plans (Sub-Area-Prüfungen):** beide Sub-Areas in der Modus-Deklaration
  als GF geführt; Beobachtungs-Sichtung nennt Zählerstände mit Kommandos; keine
  Beanstandung.

## Verdikt

**Konformität: erfüllt mit einer DoD-Verletzung in der Beleg-Ebene.** Die drei
Liefer-Punkte sind im Code vollständig und am realen Ziel gemessen; §5
(`make full-smoke` grün) ist von diesem Lauf belegt; ADR-0058 (geglättete
Fassung) ist vom Code eingehalten; die Abgrenzung §1 ist nicht verlassen. Der
eine nicht erfüllte Punkt ist nicht die Lieferung, sondern ihre behauptete
Rot-Gegenprobe: L3 nennt einen Sensor, der die Mutation nicht sieht — Übergabe
an den Planner vor der Closure (DoD-Wortlaut oder Sensor), zusammen mit dem
L2-Wortlaut „anschließend" und der Benennung der vier unverifizierten Pins.

**Dieser Report ist ein Lauf-Beleg** — er ersetzt keine Closure; die
Closure-Pflichten (§7, Register, Risiko-Ausgänge, Paarungen) sind
Planner-Arbeit nach diesem Bericht.
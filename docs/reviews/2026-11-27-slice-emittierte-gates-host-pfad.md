# Review — slice-emittierte-gates-host-pfad

**Datum:** 2026-11-27 · **Lauf:** Reviewer (`reviewer`), frischer Kontext

**Diff:** `ef1ac86f..e41cf3c5` (3 Implementer-Commits, 18 Dateien, +1017/−60)
**Plan:** `docs/plan/planning/in-progress/slice-emittierte-gates-host-pfad.md`
**Skill:** `.harness/skills/reviewer.md` v2.3.0 — dieses Review prüft den Diff gegen
**Plan und ADR** (Modul 10), nicht gegen die DoD-Abhakung (Verifier-Grenze).
**Bezugs-ADRs:** ADR-0109 (docker-los Pflicht-Weg, opt-in Image-Weg), ADR-0004, ADR-0059.

## Messungen und Läufe dieses Reviews

- **Kopien-Bodies:** `diff <(grep -vE '^\s*(#|$)' …)` über
  `internal/emit/templates/enforce/environment-check.sh` und `dcheck-fetch.sh` gegen
  `harness/tools/*` — 239 resp. 127 Anweisungs-Zeilen je Seite, Diff leer, Zeilenzahl
  identisch. Die Identität selbst trägt.
- **docs-check-Befund-Zuordnung:** `git worktree add --detach <Kopie> ef1ac86f` im
  gitignored Staat, dort `make docs-check-host DCHECK_CARRIER=<repo>/.harness/state/bin/d-check`
  → **106 Befunde, 3078 Dateien** — byte-identisch zum Zählerstand an `e41cf3c5`.
  Die 3 Implementer-Commits **haben keine** docs-check-Befunde hinzugefügt; die
  Implementer-Aussage „106, byte-identisch" trägt, und der Plusposten gegenüber
  102 gehört den Planungs-Artefakten (Plan-Text, `next/`-Slices), nicht dem Diff.
  Worktree-Kopie wurde entfernt; kein Rest im Baum.
- **Mutationsprobe (Kopie-Identität):** eine Anweisungs-Zeile an das Ende der
  emittierten `dcheck-fetch.sh`-Kopie angehängt → `make test-go`:
  `TestEmittedEnvironmentCheck_EngineGleichDerLabFassung` **blieb grün**; rot färbten
  nur die Vorbestand-Klassen (`TestStopHook_CommitBindung`, `TestGoProfile_PinsMatchRepo`
  — beide vor dem Diff). Kopie zurückgesetzt, Baum clean.
- **`make gates`** (einmal, Ende): fail-fast an `docs-check-host` mit **106 Befunde**
  (bekannte Vorbestand-Klassen: `target-missing`, `id-unlinked`, `planning-drift`,
  `section-cell-oversized`, `span-unclosed`); `environment-check` davor grün,
  die Stufen dahinter fuhren in diesem Lauf nicht mehr.
- **`make mutate-greift`** (MR-090-Anlage): 796 Fälle, **794 greifen, 2 Befunde** —
  Fall 784/785 (`gates-fast.sh`, Vorbestand-Klasse „Anker veraltet"). **Fall 40
  greift** am Bestand: der Anker-Nachzug trägt.

## Findings

- `kategorie:` HIGH
- `quelle:` AGENTS.md §3.7 („Ein Kommentar beschreibt, was da ist"); Skill-HIGH-Liste
  „Kommentar trägt keine der Kommentar-Klassen"
- `pfad:` `test/mutations/40-docgate-fragment-wiring.sh:11-15`
- `befund:` Der neue Kopf-Abschnitt „Anker-Verhalten" beschreibt die **ersetzte**
  Anlage — „der Prefix-Match haengt an, der Host-Prafix bleibt stehen" nennt einen
  Prefix-Match, den der Bestand nicht trägt (der aktuelle Anker ist ganzzeilig
  `^GATE_CHECKS += docs-check-host$`), und „die Gates-Zeile traegt jetzt docs-check-host"
  erzählt den Übergang, nicht den Zustand. Ein weiterführender Lauf liest daraus eine
  Prefix-Klasse als Deckung, die der `$`-Anker nicht trägt: eine erweiterte Zeile
  (`GATE_CHECKS += docs-check-host-schnell`) würde am Anker vorbeiziehen, während die
  Anlage-Doku ihre Fassung weiter zusichert.
- `verifizierbar:` nein — kein Sensor liest die Mechanik oder Tempus eines Fall-Kopfs;
  Träger ist dieses Review (Skill, Zeile „Kein Gate fängt das").
- `klasse:` mutations-fall-kommentar-beschreibt-die-ersetzte-anlage

- `kategorie:` MEDIUM
- `quelle:` LH-QA-01 (jedes emittierte Gate-Target läuft am frischen Checkout); Plan §1
  („make dcheck-fetch legt die fetched Ablage an"); Lab-Gegenstück `Makefile:734`
- `pfad:` `internal/emit/emit.go:132-135` (docGateMk) · `d-check.mk:79-80`
- `befund:` Das emittierte `dcheck-fetch`-Rezept ruft `@bash tools/harness/dcheck-fetch.sh`,
  ohne `DCHECK_IMAGE`/`DCHECK_DIGEST` zu reichen; `d-check.mk` trägt beide als
  Make-Variablen **ohne `export`**, und das Skript liest nur die Umgebung — es bricht
  fail-closed mit „DCHECK_IMAGE ist nicht gesetzt". `make dcheck-fetch` im
  gebootstrappten Ziel kann **nie** erfolgreich sein; die Ablage der
  `docs-check-host`-Diagnose ist unerreichbar. Die Lab-Rezeptform reicht beide Pins
  explizit weiter — die Kopie trägt den Skript-Körper, das Rezept nicht.
- `verifizierbar:` ja — jedes frisch gebootstrappte Ziel: `make dcheck-fetch` → Exit 2
  „kein Tag-Pin".
- `klasse:` emittiertes rezept reicht seine pin-quelle nicht durch

- `kategorie:` MEDIUM
- `quelle:` AGENTS.md §3.6 (Zusage ohne Gegenfall, der sie bricht)
- `pfad:` `internal/emit/environment_test.go:38-49` (`gleichZeilenweise`) · Zusage im
  Kopf `templates/enforce/dcheck-fetch.sh:12-14` („ab der ersten Anweisungs-Zeile …
  Zeile fuer Zeile identisch mit ihr")
- `befund:` Der Wächter vergleicht nur die ersten N Zeilen (N = Lab-Länge) und schlägt
  nur an, wenn die Kopie **kleiner** als ihr Original ist — eine am Ende hinzugefügte
  Anweisungs-Zeile verletzt die „identisch"-Zusage, ohne irgendeinen Wächter zu färben.
  Beleg oben (Probe): angehängte Zeile → Identitäts-Test grün; nur die Vorbestand-Klassen
  färbten.
- `verifizierbar:` ja — dieselbe Probe (Anhängen einer Anweisungs-Zeile an die Kopie →
  `make test-go` färbt sie nicht).
- `klasse:` identitaets-waechter misst nur praefix-gleichheit

- `kategorie:` MEDIUM
- `quelle:` AGENTS.md §3.6 („Falsch: ein Wächter, dessen Fall-Satz … über einer
  nachgebauten Eingabe läuft … während die reale Quelle unbeobachtet bleibt")
- `pfad:` `internal/gen/golang.go:1097-1098` (Grund-Text der
  `InventoryRows`-Soll-Zeilen)
- `befund:` Die emittierte go-Zeile zusichert „der Emissions-Waechter haelt die Zeile
  gegen die Stelle — bei einer Pin-Veraenderung faerbt er die Emission rot". Kein Test
  hält die Zeile gegen die gerenderte Pin-Stelle im Fragment; der einzige benannte
  Inventar-Test (`TestEnsureInventoryRows`) misst mit fest verdrahteten Fixture-Werten
  (1.27.4, v2.15.0) das Anhängen/Deduplizieren, nicht die Paarung. Die Kopplung trägt
  allein als Bau-Form (dieselbe `version`-/`golangciVersion`-Variable am Aufrufsort) —
  der zusicherte Wächter existiert nicht, und der Satz wandert in das Inventar jedes
  gebootstrappten Ziels.
- `verifizierbar:` ja — `grep -rn "InventoryRows"`: keine Test-Paarung mit `goFragment`;
  das Verhalten bleibt an keinem Wächter gehalten.
- `klasse:` emittierte zusage nennt einen waechter, der nicht existiert

- `kategorie:` MEDIUM
- `quelle:` AGENTS.md §3.6 (Zusage gegen den Bestand); §5 Doku-Regeln
- `pfad:` `docs/user/benutzerhandbuch.md:344`
- `befund:` Der Absatz „Ein bereits aufgesetztes Repository geklont" zusichert,
  `make gates` funktioniere vom frischen Klon „unverändert", denn die Gates prüfen nur
  die Host-Werkzeuge und den versionierten Inhalt — aber `docs-check-host` hängt in
  `GATE_CHECKS` und bricht an der fehlenden fetched Ablage mit Exit 2 (gitignored, reist
  nicht mit dem Klon). Die Zusage widerspricht der Diagnose-Form, die dieselbe Situation
  zwei Absätze später selbst als Abbruch-Klasse benennt.
- `verifizierbar:` ja — frischer Klon → `make gates` bricht an `docs-check-host` (Exit 2,
  `…/d-check fehlt`).
- `klasse:` doku-zusage widerlegt den bestand im selben abschnitt

- `kategorie:` MEDIUM
- `quelle:` LH-QA-03 („der Bootstrap braucht nur **git**"), vertraglich; Plan §1 (derselbe
  Satz als Ergebnis); ADR-0109 (lässt die Mechanik der Implementation, stellt sie aber
  nicht frei)
- `pfad:` `internal/emit/emit.go:266-273` (`printMK`, Carrier-Zweig)
- `befund:` Der Bootstrap erzeugt `d-check.mk` über `--print-mk` und braucht dafür
  `docker` **oder** eine per `DCHECK_CARRIER` von außen beschaffte, ausführbare
  Programmdatei — `make dcheck-fetch` existiert erst **nach** dem Bootstrap **im**
  Ziel (Chicken-and-Egg). Die End-Zusage „Bootstrap braucht nur git" ist am
  Default-Weg nicht erreicht, und die Lücke wird im Diff an keiner Stelle als Lücke
  benannt (der Kommentar nennt nur Form und Rueffall).
- `verifizierbar:` ja — Bootstrap eines tmp-Ziels ohne Docker und ohne
  `DCHECK_CARRIER` → Lauf bricht am print-mk-Zugang.
- `klasse:` bootstrap-traeger-luecke-unbenannt

- `kategorie:` LOW
- `quelle:` Maintainability (Modul 1: „Plan ist die Stelle, an der Spec und ADR auf
  einen Code-Diff zusammenfallen")
- `pfad:` Plan §3-Tabelle (Datei-Zeilen) vs. `internal/gen/golang.go` (+111, größter
  Einzelposten des Diffs)
- `befund:` Die §3-Tabelle nennt nur `internal/emit/templates/**`,
  `internal/emit/**_test.go` und Doku — die Go-Skelett-Gate-Fragment-Änderung
  (`internal/gen/golang.go`) fehlt als Zeile. Die Implementer-Lesart trägt, aber **nicht
  allein über §4**: der §4-Re-Slice-Trigger nennt (Kotlin, Java, Python, Csharp) —
  der Go-Fall hängt an §1 („Der Bootstrap-Code (Go) selbst, **außer der
  Gate-Fragmente** — nur die Gates-Ebene wandert"), der die Skelett-Gate-Fragmente
  ausdrücklich im Umfang hält. Kein HIGH-Planwiderspruch — aber die Tabellen-Reichweite
  wurde still nachgereicht.
- `verifizierbar:` nein
- `klasse:` plan-tabelle-schneidet-knapper-als-der-diff

- `kategorie:` INFO
- `quelle:` Maintainability · ADR-0109 erster Check
- `pfad:` `internal/emit/environment.go:30-36` (environmentMk) vs.
  `internal/emit/makefile.go:20-23` (Aggregator über make -j)
- `befund:` Die „erster Check"-Zusage („endet dem Lauf, **bevor** ein Gate gegen
  fehlendes Werkzeug falsch faerbt") misst eine Präferenz in der Prerequisites-Liste;
  unter `make -j` starten die Checks gemeinsam, und der falsche Befund eines späteren
  Gates kann zuerst laufen. Die sequential form hält; die Annahme, auch die -j-Form sei
  damit getragen, ist dokumentationswürdig und nicht dokumentiert.
- `verifizierbar:` ja — `make -j gates` im gebootstrappten Ziel mit fehlendem
  Go-Werkzeug: beide Befunde gleichzeitig in der Ausgabe.
- `klasse:` reihenfolge-zusage gilt nur sequenziell

- `kategorie:` INFO
- `quelle:` AGENTS.md §3.6 (Fall-Anlage) · MR-071/MR-090
- `pfad:` `internal/emit/environment.go:36` (GATE_CHECKS-Praeferenz) ·
  `test/mutations/` (Fallmenge)
- `befund:` Die neue Praeferenz-Zusage der Template-Ebene trägt einen Go-Wächter
  (`TestEmittedEnvironmentMk_StelltCheckVorAlleChecks`, beide Formen gehalten —
  Präferenz-Zeile verlangt, Anhang verboten), aber **keinen** Fall in der Mutations-Anlage;
  der einzige Template-Ebenen-Fall des Diffs ist Fall 40. Die Rot-Form steht im Test-Kopf
  benannt — ob der Implementer sie rot gefahren hat, prüft der Verifier (DoD-Punkt 3).
- `verifizierbar:` ja — `make mutate` listet Fälle; Anlage fehlt für die Praeferenz-Zusage.
- `klasse:` neue zusage ohne fall-anlage

## Negativbefunde (geprüft, ohne den genannten Befund)

- **Plan §1/§2/§4 Lesart:** geprüft — der Umfang „nur die Gates-Ebene wandert"
  (§1, Ausschluss „Bootstrap-Code außer der Gate-Fragmente") trägt die
  `internal/gen`-Änderung; der §4-Re-Slice-Trigger (K/J/P/C) hält die Größenlinie —
  kein einziges K/J/P/C-Fragment ist im Diff umgestellt, `gen.InventoryRows` liefert
  für Nicht-Go `nil` mit benannter Begründung. Nur die Tabellen-Reichweite von §3
  ist betroffen (LOW oben).
- **Engine-Kopien (2× byte-gekoppelt):** geprüft — Anweisungs-Körper beider Kopien
  byte-identisch zur Lab-Fassung (Messung oben); die Kopien-Köpfe tragen Herkunft und
  Weg-Verweis als Kommentar; die Rot-Zug-Form der Identität ist die der MEDIUM oben.
- **Fall 15/189 (dcheck-Anker-Klassen):** geprüft — `make mutate-greift`: beide greifen
  am Bestand (794/796, Befunde nur 784/785, Vorbestand).
- **`GATE_CHECKS :=`-Praeferenz:** geprüft — der Wächter hält beide Formen
  (Präferenz verlangt, `+=` verboten, emitted Pfad verlangt) mit benanntem Rot-Zug im
  Test-Kopf; kein Befund am Wächter selbst (nur die Fall-Anlage, INFO oben).
- **Exit-Vertrag des host-Wegs:** geprüft — fehlende Ablage → Diagnose + Exit 2
  (`emit.go:136`), Carrier-Gegenwart läuft bis zum d-check-Fund, Exit-Klasse wie im
  Make-Rezept; Image-Weg (`docs-check`, `d-check.mk`) im Diff unangetastet.
- **docs-check Plusposten 102→106:** geprüft — der Diff trägt **keinen** der
  106 Befunde (Messung am Vorgängerstand, byte-identisch); die 106 sind Vorbestand
  und Planungs-Artefakte, keine Implementer-Mehrung. Eine gestagte
  Carrier-Variante ist dafür nicht nötig und nicht im Spiel.
- **test-go Rotklassen:** geprüft — die zwei Fails unter `make test-go`
  (`TestStopHook_CommitBindung`, `TestGoProfile_PinsMatchRepo`) sind die bekannten
  Vorbestand-Klassen (Stop-Hook/GO_VERSION, vor dem Diff); der Diff hat keine
  Test-Rotklasse hinzugefügt (Probe oben).
- **`DCHECK_CARRIER`-Umschreibung in `printMK`:** geprüft — Carrier-Zweig nur bei
  gesetzter, nicht leerer Variable; docker-Lauf bleibt byte-identischer Rueffall;
  `--network none` bleibt am docker-Zweig. Kein Befund.

## Verifier-Empfehlungen

1. `make dcheck-fetch` im real gebootstrappten Ziel fahren (F2) — der Rezept-Gap
   ist der erste Block des host-Wegs im Ziel und entscheidet über DoD-Punkt 2.
2. Den Mutations-Beweis der Fall-40-Anlage nicht nur „greift" (MR-090) sondern
   rot gefärbt einfordern (`make mutate-auswahl` auf dem CI-Branch, Fall 40), dazu
   den vom Implementer benannten Rot-Zug der Praeferenz-Zusage (INFO/Anlage-Finding).
3. Die Bootstrap-Blockade (F6) als Risikoeintrag prüfen: sie fällt nicht in den
   ausdrücklich ausgeschlossenen Gegenständen des Plans und hat keinen Ausgang in §6.
4. `make gates` bleibt fail-fast an `docs-check-host` (106 Vorbestand-Befunde) —
   die Stufen nach `docs-check-host` (`test`, `lint`, `build`, …) sind in diesem
   Gate-Lauf nicht gefahren; die grünen Stempel der Implementer-Fassung decken die
   Stufen einzeln, nicht den neuen HEAD.

## Rollenwiderspruch

Kein HIGH mit Rollen-Konflikt: das HIGH-Finding (F1) ist eine Kommentar-Mechanik-
Beobachtung der Fall-Anlage, der Implementer hat sie nicht verteidigt — der
Konflikt-Pfad (Modul 8) greift nicht.

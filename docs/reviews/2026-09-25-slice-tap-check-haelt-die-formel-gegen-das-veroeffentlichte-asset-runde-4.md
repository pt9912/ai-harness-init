# Review-Report: slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset — Runde 4 — 2026-09-25

**Review-Art:** Code — Nachprüfung der Runde-3-Befunde (kurz), Diff gegen Plan, ADR und Hard Rules (Modul 10).
Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff c606829d..HEAD` **ohne** die ADR-Datei — drei Commits: `bfae848f` (Rolle Planner, nur
Plan-Wortlaut), `e9cdf49e` und `041aabfa` (Rolle Implementer). Berührt: `harness/tools/tap-nachzug.sh`,
`harness/tools/tap-nachzug-nutzlast.sh`, `test/tap-nachzug.bats`, `test/mutations/434-…`, `Makefile`,
`harness/README.md`, der Slice-Plan (`git diff --stat c606829d..HEAD -- . ':!docs/plan/adr'` → 8 Dateien, 219 Zeilen hinzu, 55 entfernt;
darin steht der Report der ADR-Runde 1 mit 115 Zeilen, der nicht Prüfgegenstand ist).

**Plan-Bezug:** Slice `slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset` (§1, Liefer-Punkte 1 bis 3,
§4, §6) — Kennung, nicht Pfad: der Plan wandert mit dem Lifecycle. **Constraint:** `ADR-0064` (`Accepted`),
`ADR-0066` (`Proposed`, Fassung `2f6fe0c2`; ihr Review ist ein getrennter Lauf), `LH-QA-02`.
**Vorlauf:** Runde 3 (`docs/reviews/2026-09-24-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset-runde-3.md`):
R3-1, R3-2, R3-3.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` · `ADR-0066` (als Constraint gelesen) · `LH-QA-02` · `MR-071` ·
`AGENTS.md` §3.2, §3.4, §3.6, §3.7, §3.9, §3.11 · Runde-3-Report. Der Implementer-Bericht war Behauptung; Code,
Tests und Sonden sind selbst gelesen und gefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt):

- **`test/tap-nachzug.bats` unmutiert** im gepinnten bats-Image auf einer Scratchpad-Kopie von `harness/`,
  `Makefile`, `.github/` und der bats-Datei: **0 rote Fälle**.
- **Zähne 420, 429, 434 emuliert, nicht über `make mutate`:** je eine frische Kopie, das Mutations-Skript dort
  angewandt (Anker ändert die Datei: bei allen drei ja), bats-Datei gefahren, Meldung gelesen.
  **420** → rot 26, 29, 30 (`docker Status 1: Exit 1, stderr: tap-check: Exit 1` · `Ziel /dev/full, Tag-Form: Exit 2`
  statt Klasse); **429** → rot 26 und 29 (`docker Status 1: Exit 1, stderr: tap-check: Exit 1`); **434** → rot 30
  (`Ziel /dev/full, Tag-Form: Exit 1`). Jedes `# expect:` ist ein Präfix des Fall-Namens, den der Zahn rot färbt
  (26 und 30 tragen die neuen Namen).
- **Gegenproben (grün heißt „bindet"):** 429 mit Status-Assertion, Zeilen-Assertion **und** Meldungs-Assertionen
  von Fall 26 sowie Status und Zeile des `docker`-Status-1-Blocks von Fall 29 auf `true` → **0 rote Fälle**;
  lässt man die Meldungs-Assertionen stehen, bleibt Fall 26 rot (drei unabhängige Träger, wie der Fall-Kopf sie
  führt). 434 mit allen `[ "$status" -eq 2 ]` in Fall 30 auf `true` → **0 rote**. Nicht gefahren: die Gegenprobe
  zu 420 (drei Träger in 26, 29, 30; die zwei Zähne 420 und 429 färben dieselben Fälle).
- **Ad-hoc-Mutationen am `*)`-Arm** (Scratchpad, nicht gelistet): **M1** hängt an die neue Meldung
  „— es wurde nichts verglichen" an, lässt die zwei Assertions-Zeichenketten stehen → **0 rote Fälle**.
  **M2** ersetzt „das Ergebnis des Vergleichs ist unbekannt" durch „es wurde nichts verglichen" → rot 26 allein
  (`[[ "$stderr" == *"Ergebnis des Vergleichs ist unbekannt"* ]]' failed`). **M4** bildet 137 und 143 auf Exit 1
  ab → rot 26 allein (die erweiterte Statusliste trägt).
- **`docker`-Stub am realen Skript, direkt und über `make tap-check`:** Status **137** und **143** → Exit 2, Meldung
  *„der Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit N) — das Ergebnis des Vergleichs ist
  unbekannt"*, danach `tap-check: Exit 2`; über `make` `Error 2` (`LC_ALL=C`). Status **10** vom Stub selbst → Exit 1,
  **einzige Ausgabe `tap-check: Exit 1`** (keine Digests, keine Meldung der Nutzlast); über `make` danach
  `make: *** [Makefile:492: tap-check] Fehler 1`, Prozess-Exit 2.
- **Reales `docker` im gepinnten Transport-Bild** (`--pull=never`, Container `exit 10`): stderr `/dev/full`,
  Container schreibt auf stderr → **`status=1`**; stderr `/dev/null` → `status=10`; stderr `/dev/full`,
  Container schreibt **nichts** auf stderr → `status=10`; im Container `exec 2>/dev/full`, Host-stderr normal →
  `status=10`; Host-stderr geschlossen (`2>&-`) → `status=10`.
- **Signal:** `docker`-Stub mit `sleep 4`, `SIGTERM` an das Skript → Prozess-Exit **143**, stderr leer.
- **Nicht gefahren:** `make mutate` (verboten; der Beleg hängt am Baum-Hash, Verifier), der Rot-Beleg am realen Tap
  (Netz), die Token-Sonden im echten Bild (in Runde 3 gefahren, der Diff berührt weder Nutzlast-Logik noch Token-Pfad —
  die Nutzlast-Datei trägt nur vier Kommentarzeilen mehr). `make gates` — siehe Ende.

---

## Status der Runde-3-Befunde

| Runde 3 | Status | Beleg dieses Laufs |
|---|---|---|
| R3-1 MEDIUM (Skript-Kopf und Fall-Name versprechen „Klasse bleibt bei nicht beschreibbarer stderr") | **behoben; Rest R4-2** | Die Zusage im Kopf ist auf das gehaltene zurückgenommen: *„Ein Schreibfehler auf stderr ändert den Exit dieses Skripts nicht (melde); ist die stderr auch im Bild nicht beschreibbar, endet der docker-Client mit Status 1 statt mit dem der Nutzlast, und ein Formel-Unterschied endet als Klasse 2"* (Kopf Zeilen 36–40). Fall 30 heißt jetzt *„ein Schreibfehler des Skripts aendert seinen Exit nicht, nur die Zeile fehlt"* und misst genau das (Zahn 434 rot, Gegenprobe grün); der Kommentar benennt den nicht gedeckten Rest (`docker` ist im Fall ein Stub). Das Realverhalten ist gemessen (`status=1` gegen `status=10`). Makefile-Kommentar, README-Zeile und Plan nennen die Klasse bei nicht beschreibbarer stderr nicht mehr als gehalten. Die Ortsangabe „im Bild" ist ungenau — R4-2. |
| R3-2 MEDIUM→LOW (Meldung des `*)`-Arms breiter als die Herkunftsmenge des Status) | **behoben; Rest R4-1** | Die Meldung sagt jetzt *„endete ohne Ergebnis der Nutzlast … das Ergebnis des Vergleichs ist unbekannt"*, keine Behauptung „nichts verglichen" mehr; die Herkunftsliste am `docker`-Aufruf nennt den Stream-Fehler des Clients und „ob der Vergleich dabei gelaufen ist, ist unbekannt". Gemessen für 137 und 143 (Stub) und für Status 1 im Fall; die Klasse bleibt Exit 2. Die Aufnahme von 137 und 143 in die Fall-Liste bindet (M4 rot). Was die neue Fassung nicht bindet, ist die **Abwesenheit** der alten Behauptung — R4-1. |
| R3-3 INFO (Status 10 als privater Kanal, Restmenge nicht benannt) | **behoben** | Skript-Kopf (Abschnitt STATUS-KANAL) und Nutzlast-Kopf benennen den Kanal, die Abbildung (0 → 0, 10 → 1, alles andere → 2), die Restmenge und ihre Wirkung; die Wirkung ist **wahr gemessen** (Stub mit Status 10 → Exit 1, „die einzige Ausgabe ist die Exit-Zeile", über `make` `Fehler 1` und Prozess-Exit 2). „kein Vertrag" steht in beiden Köpfen. Die ADR nennt den Kanal nicht (dort Trigger 3, wie in ADR-Runde 1 I-2 empfohlen); der Plan führt ihn als Bestand unterhalb der ADR. |

**Neue Fehler durch die Korrekturen:** keiner an der Klasse oder am Exit. Die Änderung am Skript ist Kommentar,
die Meldung und eine Kommentarumstellung (`git diff c606829d..HEAD -- harness/tools/tap-nachzug.sh`: eine
Code-Zeile, der `*)`-Arm); die Bats-Änderung erweitert die Statusliste und ändert Assertions-Strings der Meldung.
Der Nutzlast-Diff sind vier Kommentarzeilen. Was neu offen ist, steht unten.

## Übereinstimmung der Köpfe mit `ADR-0066` (Prüfpunkt Zustandsform, Positionsbedingung, Nicht-Zusage)

| Artefakt | Zustandsform (§3.7) | Positionsbedingung | „nicht zugesagt": Signal · stderr · Modus | „Klasse bleibt" |
|---|---|---|---|---|
| Skript-Kopf (Zeilen 14–40) | ja — Indikativ, keine verworfene Alternative, kein Befund-Bezug | „Bei `make <ziel>` aus dem Wurzelverzeichnis vorletzte … unter `make -C` und unter einem umschließenden `make` folgen weitere Zeilen — gelesen wird die Zeile, nicht ihre Position" | alle drei genannt (Zeilen 36–37) | nicht behauptet |
| Nutzlast-Kopf | ja | — (Nutzlast kennt `make` nicht) | — | — |
| Makefile-Kommentar (Zeilen 479–491) | ja | wie im Skript-Kopf | alle drei genannt | nicht behauptet |
| README-Zeile `make tap-check` | ja | „aus dem Wurzelverzeichnis … unter `-C` oder einem umschließenden `make` folgen weitere Zeilen" | alle drei genannt | nicht behauptet |
| Plan (Diff) | ja | „aus dem Wurzelverzeichnis" in §1, §2, §3 | alle drei; „bei nicht beschreibbarem stderr im Bild" zusätzlich | nicht behauptet |

`grep -niE 'bleibt|frueher|früher|ohne dass|wäre|waere'` über die hinzugefügten Zeilen von `harness/`, `Makefile`
und `test/` → 0 Treffer: keine Behauptung „Klasse bleibt", keine verworfene Alternative, kein abwesender Text. Die
Köpfe stimmen mit `ADR-0066` §Entscheidung überein; die Abweichung ist ein einziger Ausdruck (R4-2).

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | LOW | Der Fall-Name von Fall 26 sagt, das Skript endet *„mit einer Meldung, die kein Ergebnis des Vergleichs behauptet"*. Gemessen wird das über zwei **positive** Zeichenketten (`Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit $s)`, `Ergebnis des Vergleichs ist unbekannt`) und die Abwesenheit von `Formel-Unterschied`; die Abwesenheit von *„nichts verglichen"* — der Behauptung, um die es beim Umbau ging — misst keine Assertion mehr (die alte positive Assertion darauf ist entfallen, eine negative kam nicht hinzu). M1 (die alte Behauptung an die neue Meldung angehängt) färbt **0** Fälle rot. Der Wortlaut-Ersatz ist gebunden (M2 rot in Fall 26), aber allein von diesem einen Fall, und **kein Zahn unter `test/mutations/` listet den Wortlaut** — wer die Meldungs-Assertion streicht, färbt bei den Zähnen 420 und 429 nichts rot, denn dort trägt der Status (Gegenprobe). | `AGENTS.md` §3.6 (Test-Name muss die Eigenschaft messen, nicht ihre heutige Implementierung) · `ADR-0064` Festlegung 2 (Meldung nennt die Ursache) | `test/tap-nachzug.bats` Zeilen 411–423; `harness/tools/tap-nachzug.sh` Zeile 168 | ja — M1: Meldung um „— es wurde nichts verglichen" ergänzt, bats-Datei → 0 rot | Fall-Name behauptet Abwesenheit einer Aussage, gemessen werden nur ihre Ersatz-Strings |
| R4-2 | LOW | Die Ortsangabe „**im Bild**" für die nicht beschreibbare stderr trifft nicht die Messung. Nicht beschreibbar muss die stderr des **aufrufenden** `docker`-Prozesses sein (Host-Seite), und der Container muss auf seine stderr **schreiben**; ist die stderr **im Container** nicht beschreibbar (`exec 2>/dev/full`), endet der Client mit 10 (gemessen), und schreibt der Container nichts, ebenso (gemessen). Der Skript-Kopf sagt *„ist die stderr auch im Bild nicht beschreibbar, endet der docker-Client mit Status 1"* ohne die zweite Bedingung, der Fall-Kommentar *„eine stderr, die im Bild nicht beschreibbar ist"*, der Plan zweimal *„nicht beschreibbarem stderr im Bild"*. `ADR-0066` führt die Bedingung richtig mit (*„schreibt der Container auf eine stderr, die sich nicht beschreiben lässt"*, mit der Sonde). Ein Leser, der die Klasse-2-Folge auf eine stderr *im Container* bezieht, liest eine Zusage-Grenze, die es dort nicht gibt. | `AGENTS.md` §3.6 (Zusage-Grenze auf das einschränken, was gilt) · `ADR-0066` §Nicht zugesagt | `harness/tools/tap-nachzug.sh` Zeilen 38–40; `test/tap-nachzug.bats` Zeilen 492–495; Slice-Plan (Abgrenzung und Abnahme-Wortlaut) | ja — Sonden: `docker run … 2>/dev/full` (Container schreibt) → 1; ohne Schreiben → 10; `exec 2>/dev/full` im Container → 10 | Ortsangabe der Grenze ungenau, zweite Bedingung fehlt |
| R4-3 | INFO | Der Kopfkommentar des Zahns 420 nennt die Statusmenge des Falls als *„1, 3, 125 und 127"*; Fall 26 führt jetzt sechs (mit 137 und 143). Die Zähne färben unverändert (rot 26); der Kommentar beschreibt den Fall in seiner früheren Größe. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `test/mutations/420-tap-check-docker-fehler-ist-unterschied.sh` Zeilen 6–9 | ja — Vergleich Kommentar gegen Fall | Kommentar nennt eine Teilmenge der Fall-Liste |
| R4-4 | INFO | Bei einem Signal an das Skript endet der Prozess mit **143**, ohne jede Ausgabe (Stub `sleep 4`, `SIGTERM`). Skript-Kopf und `ADR-0066` nehmen dort die **Zeile** aus der Zusage; die Klassen-Aussage im Kopf (*„EXIT DES SKRIPTS: 0 … 1 … 2"*) ist unbedingt formuliert, für ein Signal gilt sie nicht. Kein Widerspruch (die Ausnahme ist benannt), dieselbe Form, die in der ADR-Runde 2 als I-1 steht. | `AGENTS.md` §3.6 | `harness/tools/tap-nachzug.sh` Zeilen 14–19, 36 | ja — Sonde wie oben | Klassen-Zusage nennt das Signal als Ausnahme nur für die Zeile |
| R4-5 | INFO | Der Plan sagt im Diff *„der Konsistenz-Review ist eingearbeitet, die zweite Runde und der Accept stehen aus"*. Mit der ADR-Runde 2 desselben Tages ist der Teilsatz zur zweiten Runde überholt. Planner-Wortlaut, kein Code-Befund. | Maintainability | Slice-Plan, Absatz zum Accept | nein | Prozess-Zustand im Plan-Fließtext überholt |

## Bewertung der bekannten Lücke: kein dauerhafter Zahn auf den Wortlaut der Meldung (Empfehlung, keine Entscheidung)

Der Implementer-Bericht nennt die Lücke selbst; gemessen ist sie so:

- **Was der Fall trägt:** Der *Ersatz* des Wortlauts ist gebunden — M2 färbt Fall 26 rot, und zwar aus dem
  behaupteten Grund (die Meldungs-Assertion, nicht der Status: Exit und Zeile bleiben dabei 2). Die erweiterte
  Statusliste bindet ebenfalls (M4). Für den heutigen Baum ist die Meldung damit gebunden, kein stilles Grün.
- **Was er nicht trägt:** (1) das, was der Fall-Name behauptet — die Abwesenheit einer Ergebnis-Behauptung (R4-1,
  M1 grün); (2) die **Haltbarkeit** der Meldungs-Assertion: `make mutate` prüft nur gelistete Zähne, und die
  Zähne 420 und 429 färben Fall 26 auch ohne Meldungs-Assertion über den Status. Wer die Assertion streicht,
  bekommt von keinem Sensor eine Meldung (Gegenprobe 429: erst mit allen drei Trägern schwach wird der Lauf grün).
- **Trägt das?** Für die heutige Zusage ja, für die Eigenschaft, die der Fall-Name benennt, nein. Ein Zahn, der
  den Wortlaut ersetzt (M2-Klasse), würde denselben Fall 26 färben und ihn *gelistet* machen — er schlösse die
  Haltbarkeitslücke, nicht die M1-Lücke. M1 schließt allein eine **negative Assertion** im Fall; ein Zahn auf M1
  wäre nur so scharf wie diese Assertion. **Empfehlung:** die Entscheidung liegt beim Implementer und beim
  Planner (ob die Zusage „keine Ergebnis-Behauptung" bleibt oder auf die Zeichenketten zurückgenommen wird); ist
  sie Zusage, gehört sie an einen Träger, der sie misst, und an einen Zahn, der den Träger listet.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Klassen-Abbildung nach dem Umbau:** `beende` und der `docker`-Zweig unverändert bis auf die Meldung (Zeile 168); 0 → 0, 10 → 1 (`unterschied=ja` unmittelbar vor `exit 1`), 2 → 2, jeder andere Status → 2 mit Meldung; Stub 1, 3, 125, 127, 137, 143 → 2 (Fall 26 im emulierten Lauf grün, mit Statusliste), Stub 10 → 1 nur mit Zeile; kein Kommando des Skripts kann 10 als Unterschied durchreichen | geprüft, ohne Befund (Restmenge des Kanals in den Köpfen benannt, R3-3) |
| **Exit-Zeile:** Fall 29 unverändert bis auf den Zusatz `sync` (`tap-sync: Exit 2`); unmutiert grün, Zähne 427, 428, 432, 433 in dieser Runde nicht angefasst (ADR-Runde 2 hat sie emuliert: rot 29) | geprüft, ohne Befund |
| **Token-Umgang und Nutzlast-Logik:** der Diff berührt allein vier Kommentarzeilen der Nutzlast; Logik, Token-Datei, `unset`, Entfernung im `beende` unverändert | geprüft, ohne Befund (Sonden aus Runde 3 nicht wiederholt) |
| **Lint-Suppression (`AGENTS.md` §3.2):** keine `# shellcheck disable` und kein `//nolint` im Diff (`git diff c606829d..HEAD | grep -c 'shellcheck disable'` → 0) | geprüft, ohne Befund |
| **Adressen (§3.11):** Köpfe, Makefile-Kommentar, README-Zeile und Fall-Kommentare nennen `ADR-0066` bei der Kennung; der Plan nennt Slice und ADR bei Kennung; kein Pfad-Link auf ein bewegtes Artefakt in den lebenden Dateien des Diffs | geprüft, ohne Befund |
| **Rollen-Grenzen (§3.8, §3.10):** Planner-Commit nur Plan, Implementer-Commits nur Skript, Nutzlast, Test, Zahn, Makefile-Kommentar, README-Zeile; kein Closure-Schritt und keine Änderung an Hard Rules oder Adaptions-Block im Diff; Plan §7 unberührt | geprüft, ohne Befund |
| **Abgrenzung (Plan §1):** kein `sync`-Verhalten, kein Gate (`tap-check` in keiner Prerequisite-Kette), `traeger-fetch.sh` und Workflow unberührt | geprüft, ohne Befund |
| **Doku gegen Code:** Skript-Kopf, Makefile-Kommentar, README-Zeile, Plan stimmen mit `ADR-0066` in Zeile als Träger, Position nur bei `make <ziel>` aus dem Wurzelverzeichnis und den drei Nicht-Zusagen überein; die Ziffer der `make`-Meldung wird als kein Vertrag geführt (gemessen: `Fehler 1`/`Error 2`) | geprüft, ohne Befund (Ausdruck „im Bild": R4-2) |
| **Größe und Schnitt:** 3 Commits, 7 Dateien ohne den Report der ADR-Runde 1 (Stat oben), in einer Sitzung prüfbar; drei Liefer-Punkte, zwei Schichten | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 3 |

**Runde-3-Befunde:** R3-1, R3-2, R3-3 behoben (mit den Resten R4-2 und R4-1).

**Finding-Klassen dieses Laufs:** Fall-Name behauptet Abwesenheit einer Aussage, gemessen werden nur ihre
Ersatz-Strings · Ortsangabe der Grenze ungenau, zweite Bedingung fehlt · Kommentar nennt eine Teilmenge der
Fall-Liste · Klassen-Zusage nennt das Signal als Ausnahme nur für die Zeile · Prozess-Zustand im Plan-Fließtext
überholt

## Verdikt

**Kein Merge-Blocker.** Kein HIGH, kein MEDIUM: die drei Runde-3-Befunde sind behoben, die Korrekturen haben
weder Klasse noch Exit verändert, Köpfe, Makefile-Kommentar, README-Zeile und Plan stimmen mit `ADR-0066`
überein. R4-1 und R4-2 sind LOW und vor dem Merge mitzunehmen, wenn der Implementer sie für berechtigt hält;
sie blockieren nicht. Der Slice hängt für seinen Abschluss weiter am Accept von `ADR-0066` (Auftraggeber) und am
Beleg der Zähne unter `make mutate` (Verifier).

**Übergabe:**

- **R4-1, R4-2, R4-3 → Implementer** (Fall 26 und sein Name; Ortsangabe in Kopf, Fall-Kommentar und Plan-Wortlaut;
  Zahn-Kommentare). Die Entscheidung, ob die Zusage „keine Ergebnis-Behauptung" bleibt, gehört Planner und
  Implementer, nicht diesem Lauf.
- **R4-4 → Architect** (dieselbe Form wie ADR-Runde 2 I-1; Adresse ist die ADR, nicht der Slice).
- **R4-5 → Planner** (Plan-Wortlaut).
- Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler (die Runden 1 bis 4
  zählen als Vorgänge **derselben** Closure). Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation:
  DoD-Konformität, den realen Rot-Beleg und den Beleg der Fälle unter `make mutate` prüft der Verifier.

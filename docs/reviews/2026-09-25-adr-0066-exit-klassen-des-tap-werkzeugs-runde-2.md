# Review-Report: ADR-0066 (Exit-Klassen des Tap-Werkzeugs sind die des Skripts) — Runde 2 — 2026-09-25

**Review-Art:** Konsistenz einer `Proposed`-ADR gegen ihre Vorgängerin und die Baseline, zweite Runde auf der
Fassung nach Runde 1 (Modul 8: der Reviewer prüft ADR-Änderungen auf Konsistenz; Modul 4 §Hard Rule für
Accepted-ADRs; Modul 10). Nicht auf Zweckmäßigkeit, nicht gegen eine DoD. Die Annahme (`Accepted`) ist
Entscheidung des Auftraggebers.

**Gegenstand:** Commit `2f6fe0c2` (Rolle Architect, Runde 1 eingearbeitet) — eine Datei, 93 Zeilen hinzu, 45
entfernt: `docs/plan/adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md`
(`git show --stat 2f6fe0c2`). `ADR-0064` und der ADR-Index sind in diesem Commit **nicht** berührt.

**Plan-Bezug:** kein Slice-Plan; Bezug ist `ADR-0064` (`Accepted`, Gegenstand der Teil-Ablösung),
`ADR-0040` (Beleg des Accept-Übergangs) und `LH-QA-02`.

**Vorlauf:** Runde 1 (`docs/reviews/2026-09-24-adr-0066-exit-klassen-des-tap-werkzeugs-runde-1.md`): M-1, L-1,
L-2, L-3, I-1, I-2 — Status unten.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eingangs-Kontext:** `ADR-0066` (Fassung `2f6fe0c2`, vollständig) · Runde-1-Report · `ADR-0064` (Exit-Nennungen
an allen Vorkommen, dazu die Umgebung der Zeilen 268–295, 328–336, 412–428, 469–472, 572–600) ·
`harness/tools/tap-nachzug.sh` und `harness/tools/tap-nachzug-nutzlast.sh` (Stand `041aabfa`) ·
`test/tap-nachzug.bats` · `test/mutations/427`, `428`, `432`, `433` · `AGENTS.md` §3.4, §3.5, §3.6, §3.7, §3.11 ·
`v6.9.0` `modul-04-adrs.md`, `modul-06-roadmap.md` (Trigger-Audit), `modul-08-agentenrollen.md`. Der Architect-Text
war Behauptung; die Messungen der ADR sind unten selbst nachgefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt):

- **GNU Make 4.3, Wegwerf-Makefile im Scratchpad** (`sh -c "exit 3"` und `exit 1` als Rezept):
  `make -C <dir> t` → drei Zeilen (`Verzeichnis … wird betreten` · `*** [Makefile:2: t] Fehler 3` ·
  `Verzeichnis … wird verlassen`), Prozess-Exit **2**; `make t` aus dem Verzeichnis → nur `Fehler 3`, Exit 2;
  umschließendes `make -f Outer.mk o` → `make[1]: *** [Makefile:2: t] Fehler 3` und danach
  `make: *** [Outer.mk:2: o] Fehler 2`; `LC_ALL=C LANGUAGE=C` → `Error 3`; Skript-Zeile vor `exit 1` steht vor
  der Meldung (`Fehler 1`), mit `-C` folgt zusätzlich die Zeile `wird verlassen`, mit `-s` bleibt die Meldung.
  Die drei Sonden aus §Kontext der ADR liefern die dort kommentierte Ausgabe; die zweite und dritte sind aus dem
  Text lauffähig (`T` gesetzt).
- **Reales Ziel:** `make tap-check TAG=v01.0.0 2>&1 >/dev/null | tail -n 3` → `tap-check: Feldform falsch …` ·
  `tap-check: Exit 2` · `make: *** [Makefile:492: tap-check] Fehler 2`, Prozess-Exit 2.
- **`docker`-Stub (Status 10, 137) hinter dem realen Skript und über `make tap-check`:** Status 10 → Exit 1,
  einzige Ausgabe `tap-check: Exit 1`, über `make` danach `Fehler 1`, Prozess-Exit 2; Status 137 → Exit 2 mit
  Zeile, unter `LC_ALL=C` `Error 2`.
- **Reales `docker` im gepinnten Transport-Bild** (`--pull=never`), die Sonde der ADR wörtlich:
  `docker run --rm <Bild> sh -c 'echo x >&2; exit 10' 2>/dev/full` → `status=1`, mit `2>/dev/null` → `status=10`.
  Gegenproben: Container schreibt **nichts** auf stderr, Host-stderr `/dev/full` → `status=10`; Container-intern
  `exec 2>/dev/full` → `status=10`; Host-stderr geschlossen (`2>&-`) → `status=10`.
- **Signal:** `docker`-Stub mit `sleep 4`, `SIGTERM` an das Skript → Prozess-Exit **143**, stderr leer.
- **Zähne 427, 428, 432, 433 emuliert, nicht über `make mutate`:** je eine frische Kopie von `harness/`,
  `Makefile`, `.github/` und `test/tap-nachzug.bats` im Scratchpad, das Mutations-Skript dort angewandt, die
  bats-Datei im gepinnten bats-Image gefahren. Unmutierter Lauf: 0 rote Fälle. Anker ändert die Datei bei
  allen vier; rot färbt jeweils Fall 29 (`exit-zeile: …`): 427 und 428 zusätzlich 26 und 31 (je 6 rote Fälle),
  432 und 433 nur 29. Gegenproben nicht wiederholt (in der Slice-Runde 3 gefahren, Baum unverändert für diese
  Fälle).
- **`make history-range-guard RANGE=2f6fe0c2~1..2f6fe0c2`:** aufgelöst, 1 Commit, OK.
  **`make adr-immutable` über dieselbe Range:** `d-check: 1867 Datei(en) geprüft, 0 Befund(e)`. Beide Zahlen
  sind Momentaufnahmen, keine Erwartungswerte.
- **Nicht gefahren:** `make mutate` (verboten; Rot-Beleg der Zähne trägt der Verifier), der Rot-Beleg am realen
  Tap (`make tap-check TAG=v0.2.2`, Netz), `make docs-check` einzeln (läuft in `make gates` am Ende).

## Status der Runde-1-Befunde

| Runde 1 | Status | Beleg dieses Laufs |
|---|---|---|
| M-1 MEDIUM (Begründung mit gemessen falscher Prämisse; Alternative „Ziffer lesen" fehlt) | **behoben** | §Kontext nennt jetzt: die Ziffer hinter `Fehler`/`Error` **ist** der Exit des Skripts, die Klasse ist über `make` ablesbar (Sonde: `Fehler 3` bei Exit 3, `Fehler 1` bei Skript-Exit 1). Alternative F (Ziffer als Träger) steht in der Tabelle; §„Warum E trotz F" gründet auf der Festigkeit des Vertrags, nicht auf einer Unlesbarkeit. Die Gegenargumente sind wahr (Abschnitt Ehrlichkeit unten); Rest: L-2 dieser Runde. |
| L-1 LOW (Sammel-Begründung „vier Stellen") | **behoben** | Teil-Ablösung nennt **drei** Stellen; Trigger 1 bindet ausdrücklich fort mit der Begründung, dass er über `make` wörtlich wahr ist (Sonde: Rezept-Exit 2 → Prozess-Exit 2). Rest: I-3 dieser Runde. |
| L-2 LOW (Position ohne Aufruf-Bedingung; Sonde mit ungesetzter Variable) | **behoben** | „vorletzte Zeile" gilt nur für `make <ziel>` aus dem Wurzelverzeichnis (gemessen), `-C`/`-w` und umschließendes `make` sind als eigene Fälle mit Ausgabe belegt; beide Sonden setzen `T=$(mktemp -d)`. Die Leseregel hängt an der Zeile, nicht an der Position. |
| L-3 LOW (geschlossene Modus-Menge im Vertrag, offener Fallback im Skript) | **behoben** | Die ADR nimmt Aufruf ohne und mit unbekanntem Modus aus der Zusage (`tap-nachzug: Exit 2` bzw. `tap-<Argument>: Exit 2`); das Skript schreibt genau das (`${modus:-nachzug}`, Zeilen 76, 81, 86, 93), Skript-Kopf und ADR stimmen überein. |
| I-1 INFO (Nicht-Zusage nennt die Zeile, nicht die Klasse bei unbeschreibbarer stderr) | **eingearbeitet, wahr** | Halbsatz steht: „Bei nicht beschreibbarer stderr ist auch die Klasse nicht zugesagt … endet der `docker`-Client mit 1 statt mit dem Status der Nutzlast … Klasse 2, die sichere Richtung". Die Sonde der ADR reproduziert (`status=1` gegen `status=10`); die Bedingung „schreibt der Container auf stderr" ist richtig gesetzt (Gegenprobe: ohne Schreiben `status=10`). |
| I-2 INFO (privater Status-Kanal) | **adressiert** | Die ADR nennt den Kanal nicht (wie empfohlen), stellt aber Re-Evaluierungs-Trigger 3 auf genau die Bedingung, unter der er Vertrag würde (Ergebnis außerhalb von gleich/Unterschied/nicht ausführbar; zweiter Aufrufer). Zu Form und Wächter: L-1 dieser Runde. |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| L-1 | LOW | Die Re-Evaluierungs-Trigger 2 und 3 sind als Bedingung formuliert, ihr Wächter ist nicht benannt und die Lücke nicht ausgesprochen. Trigger 3 sagt „beobachtbar am Schnitt, der den Modus `sync` implementiert" — das nennt einen Zeitpunkt und keinen Beobachter oder Ort; Trigger 2 („an einem roten Lauf, dessen Klasse der Leser … falsch schloss") verlangt eine Beobachtung, für die kein Artefakt und keine Ablage genannt ist. Der allgemeine Träger — Trigger-Audit der ADR-Klasse bei der Closure — trägt, steht aber weder hier noch in einer Zeile, die sagt, dass es der einzige ist. Die Datei ist ab dem Accept immutabel; eine nachgetragene Lücken-Aussage ist danach nur per Folge-ADR möglich. Nebenbefund: zwischen Trigger 2 und 3 steht eine Leerzeile, die die Liste teilt. | `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 („Ein Trigger ohne Wächter ist eine Absichtserklärung mit Verfallsdatum") · `modul-04-adrs.md` §Re-Evaluierungs-Trigger | `docs/plan/adr/0066-…md` Zeilen 208–218 | nein (Form der Trigger-Zeilen, kein Gate-Lauf) | Re-Evaluierungs-Trigger ohne benannten Wächter oder ausgesprochene Lücke |
| L-2 | LOW | §„Warum E trotz F" begründet mit „ein Zusagen-Text, dessen Wortlaut und Stelle die Locale, die `make`-Version und die Umgebung des Aufrufers bestimmen, nicht rot werden kann, wenn er bricht". Das ist zu stark: ein Fall, der `make` mit `LC_ALL=C` fährt und die Ziffer liest, würde rot. Den tragenden Grund, den die ADR nicht nennt, gibt der Kopf von `test/tap-nachzug.bats`: das bats-Image trägt kein `make`, die Meldung von `make` ist hermetisch in `make test` nicht haltbar. Die anderen Gegenargumente von F sind wahr und tragen (Abschnitt Ehrlichkeit); nur dieses eine ist als Prinzip formuliert, wo es eine Lage ist. Auch F's Contra „von keinem Fall dieses Repos gehalten" ist ein Ist-Zustand, kein Ausschluss. | `AGENTS.md` §3.6 (Zusage auf das einschränken, was gilt) · `ADR-0066` §Verglichene Alternativen F, §„Warum E trotz F" | `docs/plan/adr/0066-…md` Zeilen 162, 164–170; `test/tap-nachzug.bats` Zeilen 13–15 | ja — Sonde: `LC_ALL=C make` → `Error N`, `de_DE` → `Fehler N`; ein Fall ist baubar, wo `make` verfügbar ist | Begründung als Prinzip formuliert, tragend ist eine Lage |
| I-1 | INFO | Bei einem Signal an das Skript endet der Prozess mit **143** ohne jede Ausgabe (Sonde: `docker`-Stub `sleep 4`, `SIGTERM`). Die Nicht-Zusage nennt dort nur die **Zeile**; bei nicht beschreibbarer stderr nennt sie inzwischen auch die Klasse. Festlegung 1 („Die Klassen 0, 1 und 2 sind der Exit des Skripts") und `ADR-0064` Festlegung 2 („drei Klassen") gelten für ein Signal nicht — ein Ende, das keine der drei Klassen ist. Kein Widerspruch (die Ausnahme ist benannt), aber dieselbe Form, die Runde 1 I-1 für stderr fand: die Grenze nennt die Zeile, nicht die Klasse. | `AGENTS.md` §3.6 · `ADR-0066` Festlegung 1, §Nicht zugesagt | `docs/plan/adr/0066-…md` Zeilen 141–146 | ja — Sonde wie oben | Nicht-Zusage nennt die Zeile, nicht die Klasse unter demselben Ausfall |
| I-2 | INFO | Stelle 1 der Teil-Ablösung zitiert die **Fall-Zelle** der Zeile *Rot-Beleg am realen Zustand* (`make tap-check` gegen `v0.2.2` → „Exit 1"). Die **Zusage-Zelle** derselben Zeile (`ADR-0064` Zeile 592) sagt „fängt einen Formel-Unterschied als Exit 1 … (nicht 2)" — über `make` die schärfere Falschheit, denn der Prozess-Exit ist dort 2. Die Ablösung greift, weil sie die **Zeile** nennt; wer die Fall-Zelle als das Zitat liest, sieht die zweite Zelle nicht. | `ADR-0066` §Supersedes (Teil) 1 | `docs/plan/adr/0066-…md` Zeilen 30–31; `docs/plan/adr/0064-…md` Zeile 592 | nein | Stellen-Zitat nennt eine Zelle einer Zeile mit zwei betroffenen Zellen |
| I-3 | INFO | Die Fortbindung von Trigger 1 begründet mit „der Job-Schritt endet bei jedem Fehlschlag mit 2". Ein Job `tap` und ein Ziel `make tap-nachzug` bestehen im Baum nicht (`grep -n 'tap-nachzug:' Makefile` → kein Treffer; `.github/workflows/release.yml` nennt `tap` nur in einem Kommentar). Die Aussage ist eine Eigenschaft jedes `make`-Rezepts und für den künftigen Schritt wahr, in der Gegenwartsform steht sie aber über einen Schritt, den es noch nicht gibt. | `ADR-0064` Re-Evaluierungs-Trigger 1 · Maintainability | `docs/plan/adr/0066-…md` Zeilen 41–43 | ja — Sonde: `grep` wie oben | Präsens-Aussage über einen noch nicht gelieferten Workflow-Schritt |

## Ehrlichkeit von Alternative F und §„Warum E trotz F" (Prüfpunkt 3)

| Argument der ADR | Gemessen |
|---|---|
| Der Wortlaut der Meldung hängt an der Locale (`Fehler`/`Error`) | wahr: `Fehler 3` unter `de_DE`, `Error 3` unter `LC_ALL=C LANGUAGE=C` |
| Das Format ist keine Zusage von `make` und von keinem Fall dieses Repos gehalten | wahr als Ist-Zustand (`grep -n 'Fehler\|Error' test/tap-nachzug.bats` nennt nur `interner Fehler …`-Texte); als Prinzip zu stark, siehe L-2 |
| Die Position wandert: `-C` fügt eine Zeile an, unter einem umschließenden `make` steht als letzte Meldung die des äußeren mit `Fehler 2` und die Klasse nur in der des inneren | wahr, alle drei Ausgaben nachgefahren |
| Die Ziffer trägt die Klasse nur, solange das Kommando das Skript allein ist | wahr: der Status ist der des Rezept-Kommandos; das Rezept ist heute `@bash harness/tools/tap-nachzug.sh check` allein (Makefile Zeile 492) |
| Ein Direktaufruf ohne `make` hat keine Meldung | wahr |
| Die Zeile ist locale- und positionsfrei | wahr für die Position **im Skript-stderr**: `export LC_ALL=C` im Skript, `beende` schreibt die Zeile als letztes und beendet |

Die Argumente sind nicht zurechtgebogen; ein einziges (L-2) ist zu absolut formuliert. **Trägt E?** Ja. Die
Entscheidung E hängt an drei wahren Punkten, die zusammen tragen: der Vertrag steht in einem Text, den das
Skript schreibt und ein Fall hält; die Position der Zeile im Skript-stderr ist fest; der Direktaufruf hat keine
Meldung, der Vertrag deckt ihn trotzdem. Die Ziffer liest, wer sie braucht — der Vertrag stützt sich nicht auf
sie, und die ADR sagt das ausdrücklich („Ein Mensch, der die Ziffer liest, liest nichts Falsches").

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Wörtlichkeit der drei Zitate** an `ADR-0064`: Zeile 592 (*Rot-Beleg am realen Zustand*, `make tap-check` gegen `v0.2.2` → *Exit 1*), Zeilen 425–426 (*„ein Exit 1 der Prozedur ist erst nach dieser Wiederholung ein Formel-Unterschied"*, ein Zeilenumbruch), Zeile 471 (*„ein echter Unterschied endet danach mit Exit 1"*) | drei von drei wörtlich (zur Zelle bei Stelle 1: I-2); geprüft, ohne weiteren Befund |
| **Vollständigkeit über alle Vorkommen von „Exit" in `ADR-0064`** (`grep -c -iE 'Exit ?[0-9]\|exit-?klass' docs/plan/adr/0064-*.md` → **43** Treffer-Zeilen wie in Runde 1; mit `Exit\b` **46**, die drei Mehrtreffer — Zeilen 282, 567, 583 — sind der Tabellenkopf der Klassen, ein Satz über den „Exit-Code“ und ein Zeilentext, der nur `make tap-nachzug` nennt; keine ist eine Klassen-Aussage). Alle Nennungen von `Exit 1` durchgesehen: Zeilen 271–274 (Wiederholung; „der Lauf" als Schritt-Ausgang), 292, 333 (Schritt g, `sync`), 574–575 (Tabelle der bats-Fälle, Skript mit Stubs) sprechen vom **Ausgang des Skripts** und stehen unter Festlegung 1 der ADR-0066; über `make` wörtlich falsch sind allein die drei genannten (Zeile 471 nennt dieselbe Nachkontrolle wie 333, aber mit `tap-check` der Prozedur, also über `make`). Die `Exit 0`- und `Exit 2`-Nennungen über `make` (417, 419, 581, 598) sind wahr (`make` → 0 bei Erfolg, 2 bei jedem Fehlschlag). **Keine vierte über `make` wörtlich falsche Stelle** | geprüft, ohne Befund |
| **`AGENTS.md` §3.4:** `2f6fe0c2` berührt `ADR-0064` nicht; `make adr-immutable` über `2f6fe0c2~1..2f6fe0c2` → 0 Befunde bei nicht leerer, aufgelöster Range; der Zusatz an der Status-Zelle von `ADR-0064` im ADR-Index bleibt Folgepflicht 3 des annehmenden Laufs (Index-Zeile von `ADR-0064` unverändert `Accepted`) | geprüft, ohne Befund |
| **Teil-`Supersedes` (Form):** ein Gegenstand, drei wörtlich genannte Stellen, ausdrückliche Fortbindungsliste (sieben Festlegungen, drei Klassen samt Schwellen, Fitness-Regel-Gehalt, Rot-Beleg als Beleg, übrige Trigger, Grenze); Form wie der Präzedenzfall `ADR-0032` | geprüft, ohne Befund |
| **Grenzen gegen den Skript-Kopf** (`harness/tools/tap-nachzug.sh` Zeilen 28–40): Signal, nicht beschreibbare stderr, fehlender oder unbekannter Modus stehen in Kopf und ADR gleich; die Position („vorletzte nur bei `make <ziel>` aus dem Wurzelverzeichnis; unter `-C` und unter einem umschließenden `make` weitere Zeilen") stimmt; Kopf sagt „Ein Schreibfehler auf stderr ändert den Exit dieses Skripts nicht" — enger als die ADR, kein Widerspruch. **Die Ortsangabe „im Bild" im Kopf ist ungenau**, das ist ein Befund an den Kopf, nicht an die ADR (Runde 4 des Slice) | geprüft, ohne Befund an der ADR |
| **Fitness Function gegen reale Fälle:** Fall `exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile des Skripts tap-<modus>: Exit <N> und steht genau einmal, bei Exit 0 fehlt sie` (bats Zeile 445) deckt alle in der ADR genannten Läufe: Formel-Unterschied → 1 und `tap-check: Exit 1`; falsche Tag-Form (`v1.0.0;x`) → 2 und `tap-check: Exit 2`; gleich und Vorab-Tag → 0 ohne Zeile, auch nicht auf stdout; `sync` → `tap-sync: Exit 2`; Zählung je Lauf. Die vier Schwächungen der ADR haben je einen Zahn (`427` Zeile entfernt, `428` falsche Klasse, `432` Zeile bei Exit 0, `433` Zeile doppelt), jeder mit `# expect:` auf den Fall-Namen und `# verify: test-bats`; emuliert: jeder färbt Fall 29 rot | geprüft, ohne Befund; Rot-Beleg unter `make mutate` trägt der Verifier |
| **Fitness-Zeile 2 (Rot-Beleg am realen Zustand):** Form wie in `ADR-0064` (Skript ohne `make`: Prozess-Exit 1 und Zeile; `make`: Exit 2 und die Zeile vor der Meldung; Tag im Tap: 0), als datiert und *kein Gate* markiert. Formal am Stub nachgestellt: über `make` steht `tap-check: Exit 1` vor `Fehler 1` und der Prozess-Exit ist 2. Am realen Tap **nicht** gefahren (Netz) | geprüft, ohne Befund |
| **ADR-Form:** Kopf mit `Supersedes (Teil)`, Kontext, Entscheidung (zwei Festlegungen), Verglichene Alternativen (A–F, gewählte fett), Konsequenzen (drei Folgepflichten), Fitness Function, drei Re-Evaluierungs-Trigger (Form: L-1), Acceptance-Trigger, Geschichte (eine Zeile, Zustand); Index-Zeile 0066 vorhanden, `Proposed`; 242 Zeilen und 19 805 Bytes (`grep -c '' …`, `wc -c …`) für zwei Festlegungen | geprüft, ohne Befund |
| **Adressen (§3.11, `AGENTS.md` §3.7):** keine Slice-Kennung (`grep -nE 'slice-[0-9a-z]' docs/plan/adr/0066-*.md` → 0 Treffer); der Beleg des Accept steht als Kennung („Report … in `docs/reviews/`"), Pfade nur auf ortsfeste Ziele (`docs/user/releasing.md`, `harness/sensors/adr-immutable.md`, `harness/conventions.md`); kein Runden-Verlauf im Text | geprüft, ohne Befund |
| **Zahlen (`MR-025`):** `GNU Make 4.3` neben `make --version`; „drei Stellen", „sieben Festlegungen", „drei Klassen", „65 s" sind Strukturzahlen der zitierten ADR bzw. ihre Wahl; keine Zahl ist als Erwartungswert geführt | geprüft, ohne Befund |
| **Gate-Lockerung (§3.5) und Hard Rules (§3.8):** keine Schwelle, kein Modul, keine Strenge ändert sich; der Commit berührt nur die ADR und nennt die Rolle in der Message | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 3 |

**Runde-1-Befunde:** M-1, L-1, L-2, L-3 behoben · I-1 eingearbeitet und wahr · I-2 adressiert (Trigger 3).

**Finding-Klassen dieses Laufs:** Re-Evaluierungs-Trigger ohne benannten Wächter oder ausgesprochene Lücke ·
Begründung als Prinzip formuliert, tragend ist eine Lage · Nicht-Zusage nennt die Zeile, nicht die Klasse unter
demselben Ausfall · Stellen-Zitat nennt eine Zelle einer Zeile mit zwei betroffenen Zellen · Präsens-Aussage über
einen noch nicht gelieferten Workflow-Schritt

## Verdikt

**Empfehlung zum Accept: unbedingt an der Substanz.** Kein HIGH, kein MEDIUM. Die zwei Festlegungen (Klasse des
Skripts; Träger `tap-<modus>: Exit <N>`) sind gegen `ADR-0064` wörtlich nachgemessen und konsistent, die
Teil-Ablösung trifft genau die drei über `make` falschen Stellen, es bleibt keine vierte, Trigger 1 bindet zu
Recht fort, die Runde-1-Befunde sind eingearbeitet, und die Entscheidung E trägt auch gegen die neue Alternative F.
L-1 und L-2 sowie I-1 bis I-3 sind Befunde an der **Darstellung** im Sinn des Acceptance-Triggers und hindern die
Annahme nicht. Weil die Datei danach immutabel ist, sind sie **vor** dem Accept mitzunehmen, wenn der Architect sie
für berechtigt hält (sonst nur per Folge-ADR); das ist seine Entscheidung. Der Beleg nach `ADR-0040` Festlegung 2
ist diese Runde. **Die Annahme selbst ist die Entscheidung des Auftraggebers.**

**Übergabe:**

- **L-1, L-2, I-1, I-2, I-3 → Architect** (Wortlaut der ADR; Wahl zwischen Ändern und Stehenlassen bleibt bei ihm).
  Kein Reviewer-Verdikt über Zweckmäßigkeit.
- Folgepflicht 2 (`docs/user/releasing.md` liest die Zeile) ist noch nicht erfüllt — `grep -n 'tap-check'
  docs/user/releasing.md` → kein Treffer; sie gehört dem annehmenden Lauf bzw. dem liefernden Slice, kein Befund
  dieser Runde.
- Die **Finding-Klassen** gehen zusätzlich in die Closure §7 des liefernden Slice; dieser Report ist ein Lauf-Beleg
  und ersetzt weder die Verifikation noch die Annahme.

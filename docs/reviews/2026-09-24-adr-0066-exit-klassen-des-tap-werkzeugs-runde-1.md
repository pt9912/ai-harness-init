# Review-Report: ADR-0066 (Exit-Klassen des Tap-Werkzeugs sind die des Skripts) — Runde 1 — 2026-09-24

**Review-Art:** Konsistenz einer `Proposed`-ADR gegen ihre Vorgängerin und die Baseline (Modul 8: der
Reviewer prüft ADR-Änderungen auf Konsistenz; Modul 4 §Hard Rule für Accepted-ADRs; Modul 10). Nicht auf
Zweckmäßigkeit, nicht gegen eine DoD. Die Annahme (`Accepted`) ist Entscheidung des Auftraggebers.

**Gegenstand:** Commit `318f8e9d` (Rolle Architect) — zwei Dateien, 195 Zeilen hinzu:
`docs/plan/adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md` (194 Zeilen) und eine Zeile im
ADR-Index. `ADR-0064` ist in diesem Commit **nicht** berührt (`git show --stat 318f8e9d`).

**Plan-Bezug:** kein Slice-Plan; Bezug ist `ADR-0064` (`Accepted`, Gegenstand der Teil-Ablösung) und
`LH-QA-02`. Der liefernde Slice (`slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset`) ist
Kontext, nicht Prüfgegenstand.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** `ADR-0066` vollständig · `ADR-0064` vollständig (643 Zeilen, in zwei Lesungen) ·
`ADR-0032` (Präzedenzfall der Teil-Ablösung, Kopf) · `ADR-0040` (Festlegung 1 und 2, Kopf) ·
`docs/plan/adr/README.md` (Zeile 0066, Zeilen 0064 und 0032) · Vorlage `NNNN-titel.template.md`
(Abschnittsfolge) · `harness/sensors/adr-immutable.md` und `harness/sensors/history-range-guard.md` ·
`AGENTS.md` §3.4, §3.5, §3.6, §3.7, §3.8, §3.9, §3.11 · `v6.9.0` `modul-04-adrs.md`, `modul-08-agentenrollen.md`
(§Konflikt-Pfad), `modul-10-review-harness.md` · als Umsetzungs-Kontext `harness/tools/tap-nachzug.sh`,
`test/tap-nachzug.bats`, `test/mutations/427…433` und aus den Reports Runde 2 und 3 des Slice nur R2-2 und
R3-1 bis R3-3. Der Architect-Text war Behauptung; die Messungen der ADR sind unten selbst nachgefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt):

- **`make` (GNU Make 4.3), Wegwerf-Makefile im Scratchpad:** Rezept `exit 1` → Prozess-Exit **2**, Meldung
  `Fehler 1`; Rezept `exit 3` → Prozess-Exit **2**, Meldung `Fehler 3`; Rezept `exit 0` → 0. Skript-Zeile
  auf stderr, danach `exit 1` → die Zeile steht **vor** der `make`-Meldung. Mit `make -C <dir>` folgt der
  Meldung zusätzlich `Verzeichnis … wird verlassen` (siehe L-2).
- **Reales Ziel:** `make tap-check TAG=v01.0.0` (endet vor jedem `docker`-Aufruf) → letzte drei stderr-Zeilen
  `tap-check: Feldform falsch …` · `tap-check: Exit 2` · `make: *** [Makefile:489: tap-check] Fehler 2`,
  Prozess-Exit 2; unter `LC_ALL=de_DE.UTF-8` dasselbe (die Locale des Hosts steht schon auf Deutsch).
- **Direktaufruf:** `TAG=v0.2.3 bash harness/tools/tap-nachzug.sh foo` → letzte Zeile `tap-foo: Exit 2`;
  ohne Modus → `tap-nachzug: Exit 2` (siehe L-3).
- **`make history-range-guard RANGE=318f8e9d~1..318f8e9d`:** aufgelöst, 1 Commit, OK. Die Range ist nicht
  leer, und `ADR-0064` liegt nicht in ihr; der Lauf ist damit für die Frage „bleibt der Kern von `ADR-0064`
  unverändert" aussagekräftig.
- **`make adr-immutable RANGE=318f8e9d~1..318f8e9d`:** `d-check: 1866 Datei(en) geprüft, 0 Befund(e)`.
- **`make docs-check`:** `d-check: 1866 Datei(en) geprüft, 0 Befund(e)`. Beide Zahlen sind Momentaufnahmen,
  keine Erwartungswerte.
- **Nicht gefahren:** `make mutate` (verboten; die Zähne 427, 428, 432, 433 sind gelesen, nicht rot gesehen
  — Beleg hängt am Verifier), reale `docker`-/Netz-Sonden (R3-1 ist von einem anderen Lauf gemessen und wird
  zitiert, nicht wiederholt).

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| M-1 | MEDIUM | Die Begründung des Trägers nennt eine Unlesbarkeit, die es nicht gibt. §Kontext sagt, die `make`-Meldung „nenne den Status des Kommandos, nicht die Klasse", und §Kontext „Was ohne Träger verloren ginge" folgert, die Trennung von Formel-Unterschied und Nicht-Ausführbarkeit sei über `make` „nicht mehr ablesbar"; „die Klasse braucht einen Träger, der durch `make` hindurch reicht". Gemessen: der Status des Kommandos **ist** hier der Exit des Skripts, also die Klasse — `make` meldet `Fehler 1` bei Skript-Exit 1 und `Fehler 3` bei Exit 3, im realen Ziel `Fehler 2` bei Exit 2; die ADR zeigt in ihrer eigenen Sonde `… Fehler 1 · exit=2`, ohne den Widerspruch zu ziehen. Nicht durch `make` hindurch reicht der **Prozess-Exit**; die Ziffer in der Meldung reicht durch, nur ihr Wortlaut (`Fehler`/`Error`) ist locale-abhängig. Tragfähig bleibt die Festlegung als **vertraglicher, locale-freier, grep-barer Text**, den das Skript selbst schreibt — das steht aber nicht als Grund da. In §Verglichene Alternativen fehlt die naheliegende Option „die Ziffer der `make`-Meldung lesen" ganz; Alternative D („Rezept ändern") ist nicht dieselbe. Ein Norm-Text, der die Notwendigkeit seiner Festlegung mit einer messbar falschen Aussage begründet, ist eine Harness-Lüge kleinen Formats: der nächste Leser prüft die Meldung, findet die Ziffer und hält die Zeile für überflüssig. | `ADR-0066` §Kontext („Was ohne Träger verloren ginge", „Die letzte Zeile des Skripts …") · §Verglichene Alternativen · `AGENTS.md` §3.6 (Zusage auf das einschränken, was gilt) | `docs/plan/adr/0066-…md` Zeilen 76–86, 123–131 | ja — Sonde: Wegwerf-Makefile mit `sh -c "exit 3"` → `Fehler 3`, Prozess-Exit 2 | Begründung einer Festlegung mit gemessen falscher Prämisse; naheliegende Alternative nicht verglichen |
| L-1 | LOW | Der Satz „die vier Stellen lassen sich **wörtlich nicht halten**" trifft auf Stelle 4 nicht zu: der Trigger 1 von `ADR-0064` (*„am roten Job `tap` mit Exit 2 aus der Anmeldung"*) ist über `make` **wörtlich wahr** — der Job-Schritt endet bei jedem Fehlschlag mit 2, also auch bei der Anmeldung. Unhaltbar ist dort nicht der Exit, sondern die Zuordnung *Exit 2 → Ursache Anmeldung*: sie liest der Job am Exit nicht ab, sondern an der Meldung des Skripts. Die Wirkung der Teil-Ablösung (Klasse des Skripts, Ursache aus der Meldung) ist richtig; die Begründung über alle vier Stellen gleichzeitig ist es nicht. | `ADR-0066` §Kontext („Ein `make tap-check` mit Prozess-Exit 1 ist damit nicht herstellbar; die vier Stellen lassen sich wörtlich nicht halten") · `ADR-0064` Re-Evaluierungs-Trigger 1 | `docs/plan/adr/0066-…md` Zeilen 71–72; `docs/plan/adr/0064-…md` Zeile 598 | ja — Sonde: Rezept mit `exit 2` → Prozess-Exit 2 | Sammel-Begründung über eine Stellenmenge, von der eine Stelle abweicht |
| L-2 | LOW | Die Aussage „die Skript-Zeile ist dort die **vorletzte** Zeile der Ausgabe" gilt für `make <ziel>` aus dem Wurzelverzeichnis; unter `make -C <dir>` (und `-w`, Sub-`make`) folgt der Meldung die Zeile `Verzeichnis … wird verlassen`, die Skript-Zeile ist dann die drittletzte (gemessen). Die Leseregel der ADR (*„liest die letzte Zeile **des Skripts**"*) hängt nicht an der Position und bleibt wahr; nur der Positionssatz ist unbedingt formuliert. Dazu ist die Sonde in §Kontext nicht aus dem Text wiederholbar: `$T` ist nirgends gesetzt, und `make -C "$T"` ist genau die Form, die die zusätzliche Zeile erzeugt (Aufbau-Anleitung ohne Prüf-Bedingung, `MR-067`). | `ADR-0066` §Kontext · `MR-067` · `AGENTS.md` §3.6 | `docs/plan/adr/0066-…md` Zeilen 63–69, 82–86 | ja — Sonde: dasselbe Wegwerf-Makefile mit `make -C` | Positionszusage ohne ihre Aufruf-Bedingung; Sonde mit ungesetzter Variable |
| L-3 | LOW | Festlegung 2 schließt den Modus: *„`<modus>` ist `check` oder `sync`"*. Das Skript schreibt bei einem Aufruf ohne oder mit unbekanntem Modus die Zeile mit anderem Token: `tap-nachzug: Exit 2` (kein Modus), `tap-foo: Exit 2` (Modus `foo`) — gemessen; Ursache ist der Fallback `${modus:-nachzug}` und die Übernahme des Arguments. Über die `make`-Ziele nicht erreichbar (sie setzen den Modus fest), ein Direktaufruf erreicht es. Die Zusage der ADR und ihr Fall (`check`, `sync`) decken es nicht; entweder der Wortlaut der ADR oder das Skript bricht die geschlossene Menge. | `ADR-0066` Festlegung 2 · `AGENTS.md` §3.6 | `docs/plan/adr/0066-…md` Zeilen 111–116; `harness/tools/tap-nachzug.sh` Zeilen 64–81 | ja — Sonde: `TAG=v0.2.3 bash harness/tools/tap-nachzug.sh foo` → `tap-foo: Exit 2` | geschlossene Wertemenge im Vertrag, offener Fallback im Skript |
| I-1 | INFO | **R3-1 — nicht beschreibbare stderr:** die Grenze der ADR ist **wahr gemessen, weil sie nur die Zeile nimmt** (*„die Zeile bei … einer stderr, die nicht beschreibbar ist"*). Nach dem Befund R3-1 (anderer Lauf, reales `docker`: bei stderr `/dev/full` endet der Client mit Status 1, das Skript mit Exit **2** statt der Klasse 1) kippt bei nicht beschreibbarer stderr mit realem `docker` aber auch die **Klasse** — die sichere Richtung, 2 statt 1. Das ist eine Eigenschaft von `ADR-0064` Festlegung 2 (drei Klassen, unbedingt formuliert), die `ADR-0066` in Festlegung 1 („die Klassen 0, 1 und 2 sind der Exit des Skripts") übernimmt, ohne sie zu bedingen. Widerspruch zu `ADR-0066` besteht nicht; der Widerspruch liegt im Skript-Kopf (Implementer, R3-1). **Empfehlung, keine Entscheidung:** die ADR braucht dazu keine Aussage, damit sie stimmt; ein Halbsatz in der Nicht-Zusage („… und, mit realem `docker`, die Klasse 1 selbst: sie endet dort als 2") machte die Grenze vollständig und hielte den Skript-Kopf nach seiner Korrektur und die ADR gleich. Lässt der Architect ihn weg, gehört die Einschränkung allein in den Skript-Kopf und den Fall-Namen. | `ADR-0066` §Entscheidung („Nicht zugesagt") · `ADR-0064` Festlegung 2 · `AGENTS.md` §3.6 | `docs/plan/adr/0066-…md` Zeilen 118–121 | ja — Sonde des R3-1 (Shim-`docker` ruft reales `docker`, `2>/dev/full`) | Nicht-Zusage nennt die Zeile, nicht die Klasse unter demselben Ausfall |
| I-2 | INFO | **R3-3 — Status 10 als privater Kanal:** er liegt **unterhalb** der Festlegungen von `ADR-0066` und `ADR-0064`. `ADR-0066` bindet die Zeile an den Exit **des Skripts**, nicht an das, was die Nutzlast dem Host zurückgibt; `ADR-0064` Festlegung 5 nennt die Nutzlast als eigene Datei und lässt den Rückkanal offen. Ein Vertrag wird der Kanal erst, wenn ihn ein **zweiter Aufrufer** der Nutzlast oder eine Ergebnis-Klasse trägt, die das Host-Skript nicht selbst herleiten kann. Der `sync`-Schnitt braucht das nicht zwingend: Klasse 1 (Formel-Unterschied) hat in `sync` denselben einen Ursprung wie in `check` (Schritt e/g, Vergleich), Klasse 2 bleibt 2. **Empfehlung, keine Entscheidung:** die ADR nennt den Kanal nicht; der Skript-Kopf und der Nutzlast-Kopf halten ihn samt Restmenge fest (R3-3, Implementer). Ein Gegenlesen durch den Architect ist erst fällig, wenn der `sync`-Schnitt einen Status jenseits von 0, 2 und 10 einführt oder ein Ergebnis, das Klasse 1 aus einer anderen Quelle als dem Vergleich trägt — dann als Zusatz zu dieser ADR oder als Folge-ADR, nicht als stilles Wachstum des Kanals. | `ADR-0064` Festlegung 2, 5 · `ADR-0066` Festlegung 1 · Maintainability | `docs/plan/adr/0066-…md` Zeilen 103–109 | nein (Empfehlung zur Zuordnung) | privater Status-Kanal zwischen zwei Dateien, Vertragsgrenze offen |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Wörtlichkeit der vier Zitate** (an `ADR-0064` nachgemessen): (1) §Fitness Function, Zeile *Rot-Beleg am realen Zustand* — `make tap-check` gegen `v0.2.2` → *„Exit 1"* (Zeile 592); (2) Festlegung 6 — *„ein Exit 1 der Prozedur ist erst nach dieser Wiederholung ein Formel-Unterschied"* (Zeilen 425–426, ein Zeilenumbruch); (3) §Konsequenzen Negativ — *„ein echter Unterschied endet danach mit Exit 1"* (Zeile 471); (4) Trigger 1 — *„am roten Job `tap` mit Exit 2 aus der Anmeldung"* (Zeile 598) | vier von vier wörtlich und vollständig; geprüft, ohne Befund (zur Tragweite von 4 siehe L-1) |
| **Vollständigkeit der Stellenmenge:** Sonde über alle Vorkommen von `Exit`, `Exit-Klass` in `ADR-0064` (`grep -n -iE 'Exit ?[0-9]|exit-?klass'`, 43 Treffer-Zeilen). Genau diese nennen ein **`make`-Ziel oder den Job zusammen mit Exit 1 oder 2**: Zeilen 425–426, 471, 592, 598 (die vier) und Zeile 581 (`make tap-check TAG='v1.0.0$$(id)'` → *je Exit 2*, in der Zelle mit den Env-Weg-Fällen). Zeile 581 ist über `make` **wahr** (Prozess-Exit 2) und auf Skript-Ebene wahr; kein Konflikt, keine fünfte Stelle. Alle übrigen Exit-Nennungen (Tabelle Zeile 286, Schritte b bis g, Zeilen 271–278, 290–293, 302–340, 533, 574–580, 583–588) sprechen vom Ausgang des Skripts und stehen unter Festlegung 1 der ADR-0066, ohne dass sie einzeln genannt sein müssten | geprüft, ohne Befund |
| **Reichweite und `AGENTS.md` §3.4:** `Supersedes (Teil)` nennt **einen** Gegenstand (Lesart als Prozess-Exit eines `make`-Ziels), vier Stellen wörtlich, und listet, was fortbindet (sieben Festlegungen, drei Klassen samt Schwellen, Regel-Gehalt der Fitness-Zeilen, Rot-Beleg als Beleg, übrige Trigger, Grenze). Form gleich dem Präzedenzfall `ADR-0032`. `git show --stat 318f8e9d` berührt `ADR-0064` nicht; `make adr-immutable` über `318f8e9d~1..318f8e9d` → 0 Befunde. Der Zusatz im Index (*„revidiert durch ADR-0066"*) ist als Folgepflicht 3 an den annehmenden Lauf gelegt, die Zeile von `ADR-0064` im Index ist unverändert `Accepted` — richtig, denn eine `Proposed`-ADR revidiert noch nichts | geprüft, ohne Befund |
| **Die `make`-Behauptung, Kern:** Skript-Exit 0 → Prozess-Exit 0; Skript-Exit 1 oder 2 (und 3) → Prozess-Exit 2, gemessen mit GNU Make 4.3 an drei Wegwerf-Rezepten und am realen Ziel. Festlegung 1 nennt die Eigenschaft ausdrücklich „von GNU Make, … keine Zusage des Werkzeugs" — die Zuschreibung ist richtig gesetzt (das Repo verlangt GNU `make`, `AGENTS.md` §3.9) | geprüft, ohne Befund (zur Begründung siehe M-1) |
| **Ausgabe-Reihenfolge:** im realen Ziel und im Wegwerf-Makefile steht die Zeile des Skripts **vor** der `make`-Meldung, die `make`-Meldung ist die letzte Zeile (ohne `-C`) | geprüft, ohne Befund (zur Bedingung siehe L-2) |
| **Festlegung 2 als Zusage mit Gegenbeispiel (§3.6):** Wortlaut fest (*„ein anderer Text ist eine Änderung dieser Entscheidung"*), Häufigkeit (genau einmal), Klassen-Bindung (`<N>` = Exit des Skripts), Exit-0-Ausschluss; Grenzen ausdrücklich (Signal, nicht beschreibbare stderr); vier Schwächungen benannt (Zeile entfernt, falsche Klasse, Zeile bei Exit 0, Zeile doppelt) | geprüft, ohne Befund (Reichweite der Grenze: I-1; geschlossene Modus-Menge: L-3) |
| **Fitness Function gegen reale Sensoren:** der Fall `exit-zeile: bei Exit 1 und Exit 2 ist die letzte stderr-Zeile des Skripts tap-<modus>: Exit <N> und steht genau einmal, bei Exit 0 fehlt sie` steht in `test/tap-nachzug.bats` (Zeile 445) und deckt die genannten Fälle: Formel-Unterschied → 1 und `tap-check: Exit 1`; sechs Herkünfte des Exit 2 einschließlich `sync` → `tap-sync: Exit 2`; Exit 0 (gleich, Vorab-Tag) ohne Zeile; Zählung je Lauf. Die vier Schwächungen haben je einen Fall unter `test/mutations/`: `427-tap-check-exit-zeile-fehlt`, `428-…-falsche-klasse`, `432-…-bei-exit-0`, `433-…-doppelt`, alle mit `# expect:` auf den Fall-Namen und `# verify: test-bats`. Nicht rot gesehen von diesem Lauf (`make mutate` verboten) | geprüft, ohne Befund; Rot-Beleg der Zähne trägt der Verifier |
| **Rot-Beleg am realen Zustand:** die Zeile trägt zwei Aufrufe (Skript ohne `make`: Prozess-Exit 1 und letzte Zeile; `make`: Prozess-Exit 2, Zeile steht vor der `make`-Meldung; Tag, den das Tap trägt: beide 0) und ist als **datiert** und *kein Gate* markiert, wie in `ADR-0064`. Nicht nachgefahren (Netz und `docker` am realen Tap; ein anderer Lauf hat den Beleg gefahren) | geprüft, ohne Befund |
| **ADR-Form** (Modul 4, Vorlage): Kopf (Status, Datum, Autor, Bezug, Schärft, `Supersedes (Teil)`, Regeln), Kontext, Entscheidung, Verglichene Alternativen (fünf Optionen A bis E, gewählte fett), Konsequenzen (Positiv/Negativ, drei Folgepflichten), Fitness Function, Re-Evaluierungs-Trigger (zwei, beobachtbar formuliert), Acceptance-Trigger, Geschichte (eine Zeile, Zustand statt Verlauf), Schlussformel; Index-Zeile 0066 vorhanden, Status `Proposed`, Bezugs-Spalte mit fünf Verweisen; `docs-check` 0 Befunde | geprüft, ohne Befund |
| **Adressen (§3.11, `AGENTS.md` §3.7):** keine Slice-Kennung und keine Slice-Nummer in der ADR (`grep -nE 'slice-[0-9a-z]'` → 0 Treffer; der Slice heißt „liefernder Slice"); Verweise auf `docs/user/releasing.md`, `harness/sensors/adr-immutable.md`, `harness/conventions.md` sind ortsfest; der Bericht-Beleg des Accept steht als Kennung, nicht als Pfad-Link (ADR-0040 Festlegung 1, Trigger-Text); der Vorlauf der Runden steht nicht als Erzählung in der Datei | geprüft, ohne Befund |
| **Zahlen (`MR-025`):** `GNU Make 4.3` steht neben `make --version`; „vier Stellen", „sieben Festlegungen", „drei Klassen", „65 s" sind Strukturzahlen der zitierten ADR bzw. ihre Wahl (die 65 s stehen in `ADR-0064` Festlegung 2 als Wahl der dortigen Entscheidung); keine Zahl ist als Erwartungswert geführt | geprüft, ohne Befund |
| **Rollen (`AGENTS.md` §3.8, ADR-0024, Modul 8):** ADR und ADR-Index sind Architect-Artefakte; der Commit berührt nur diese beiden Dateien und nennt die Rolle in der Message. Die Ablösungs-Form folgt Verdikt 2 des Konflikt-Pfads (Folge-ADR mit `supersedes`); das Verdikt ist ein Artefakt, kein mündlicher Schluss. `ADR-0062` wird von `ADR-0066` nicht zitiert (`grep -c '0062'` → 0), die gefragte Wechselwirkung mit dessen Festlegung 2 („Berührung ist keine Antwort") entfällt damit | geprüft, ohne Befund |
| **Gate-Lockerung (§3.5):** keine Schwelle, kein Modul, keine Strenge ändert sich; die Entscheidung ändert *„keine Klasse"* und erhöht (Träger `tap-<modus>: Exit <N>`) die Prüfbarkeit | geprüft, ohne Befund |
| **Größe:** 194 Zeilen (14 660 Bytes) gegen 643 Zeilen (58 180 Bytes) der geschärften ADR, für zwei Festlegungen; rund 50 Zeilen Kopf (Supersedes samt Fortbindungsliste) sind die Form der Teil-Ablösung, rund 30 Zeilen Kontext-Messung tragen die Festlegung 1. Die Alternativen A bis C wiederholen zum Teil §„Warum eine ADR" — Verdichtbar, aber nicht falsch; ein Schnitt in zwei ADRs (Ebene · Träger) trüge nicht, weil Festlegung 2 ohne Festlegung 1 keinen Gegenstand hat | geprüft, ohne Befund (trägt) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Begründung einer Festlegung mit gemessen falscher Prämisse; naheliegende
Alternative nicht verglichen · Sammel-Begründung über eine Stellenmenge, von der eine Stelle abweicht ·
Positionszusage ohne ihre Aufruf-Bedingung; Sonde mit ungesetzter Variable · geschlossene Wertemenge im
Vertrag, offener Fallback im Skript · Nicht-Zusage nennt die Zeile, nicht die Klasse unter demselben Ausfall ·
privater Status-Kanal zwischen zwei Dateien, Vertragsgrenze offen

## Verdikt

**Empfehlung zum Accept: bedingt.** Die Entscheidung selbst — Klasse des Skripts, Träger `tap-<modus>: Exit <N>`,
Teil-Ablösung auf genau vier wörtlich zitierte Stellen — ist konsistent mit `ADR-0064`, verletzt keine
`Accepted`-ADR und keine Hard Rule, ändert den Kern von `ADR-0064` nicht und hält die Stellenmenge vollständig.
Kein HIGH. Vor dem Accept zu klären ist **M-1**: die Notwendigkeit des Trägers steht auf einer Prämisse, die
die eigene Sonde der ADR widerlegt (die Ziffer der `make`-Meldung **ist** die Klasse); die Festlegung trägt auch
ohne sie, aber sie muss aus dem richtigen Grund getragen werden (locale-freier, vom Skript geschriebener,
vertraglicher Text statt einer Meldung in `make`-Wortlaut), und die Alternative „Ziffer der `make`-Meldung
lesen" gehört in die Tabelle. Ob M-1 als Befund an der **Substanz** oder an der **Darstellung** im Sinn des
Acceptance-Triggers zählt, entscheidet nicht dieser Lauf; er liest ihn als Begründungs-Korrektur an einer
noch veränderlichen `Proposed`-Datei. Wird er als Substanz gelesen, ist der Beleg nach `ADR-0040` Festlegung 2
die nächste Runde der prüfenden Rolle. L-1 bis L-3 und I-1 sind vor dem Accept mitzunehmen, weil die Datei danach
immutabel ist; I-2 braucht keine Änderung der ADR.

**Übergabe:**

- **M-1, L-1, L-2, L-3, I-1 → Architect** (Wortlaut der ADR; L-3 alternativ Implementer, wenn der Fallback im Skript
  an die geschlossene Menge gebunden wird; I-1 als Halbsatz oder bewusst weggelassen). Kein Reviewer-Verdikt über
  Zweckmäßigkeit — die Wahl zwischen den Wegen bleibt beim Architect.
- **I-2 → Implementer** (Skript-Kopf und Nutzlast-Kopf, R3-3) und als Vermerk für den `sync`-Schnitt.
- Die **Finding-Klassen** gehen zusätzlich in die Closure §7 des liefernden Slice und von dort in den Zähler; dieser
  Report ist ein Lauf-Beleg und ersetzt weder die Verifikation noch die Annahme.

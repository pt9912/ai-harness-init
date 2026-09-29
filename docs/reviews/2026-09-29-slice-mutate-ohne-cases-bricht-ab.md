# Review-Report: slice-mutate-ohne-cases-bricht-ab — 2026-09-29

**Review-Art:** Code — geprüft gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** `slice-mutate-ohne-cases-bricht-ab` — Commits `f8a1fe80` (slice-mv, reiner
Move), `e46c6e76` (Ruhe-Marker, Roadmap) und `205e9b44` (Implementierung).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0 (2026-09-27)
**Modell:** glm-5.3-flash · **Datum:** 2026-09-29

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-mutate-ohne-cases-bricht-ab.md` (§1–§8)
- `AGENTS.md` §3.6, §3.7, §3.9
- `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice
- `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Gate und Beleg
- `LH-QA-01`
- `harness/sensors/mutate.md` (Vertrag von `make mutate`), `harness/README.md` §Werkzeuge,
  `.github/workflows/mutate.yml`, `Makefile` (Rezept `mutate`)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Die Vollauf-Sperre macht den **Beleg-Übersprung unerreichbar**: Die Sperre bricht ab, wenn `MUTATE_CASES` unset und `MUTATE_FORCE` leer ist (`mutate.sh:1622`) — exakt die Vorbedingung des Übersprungs-Zweigs (`mutate.sh:1665`: `partial` leer **und** `MUTATE_FORCE` leer **und** Beleg passt). Der Exit-0-Pfad (`mutate: Beleg fuer Pruefgegenstand … liegt vor`) ist damit toter Code, und der Sensor-Vertrag dokumentiert ihn als lebendig weiter: `harness/sensors/mutate.md` §Grenze („gibt dieser Lauf diesen Beleg aus statt den Fall-Satz erneut zu fahren“, Z. 17–20) und §Ausgänge (Exit-0-Zeile, Z. 48) sind in **dieselben Diff** nicht nachgezogen; auch der Kopfkommentar des Skripts (Z. 65–79) und der BELEG-STATT-LAUF-Block beschreiben den Übersprung im Präsens. Real nachgestellt: stehender, zum `isolation_key` **passender** Beleg-Slot, kein `MUTATE_CASES`, kein `MUTATE_FORCE` → Abbruch mit der Sperren-Meldung, Exit 1 — nicht Exit 0 mit „Beleg … liegt vor“. Ein dokumentiertes, außen beobachtbares Verhalten wurde stillgelegt, ohne dass eine Stelle des Diffs das nennt. | `harness/sensors/mutate.md` (Vertrag) · `AGENTS.md` §3.7 · [ADR-0035](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) | `harness/tools/mutate.sh:1622-1628`, `harness/tools/mutate.sh:1665-1669`, `harness/sensors/mutate.md:17-20`, `harness/sensors/mutate.md:48` | ja — Sonde: Fake-Repo mit passendem Slot (`isolation_key` in den Slot geschrieben), `bash mutate.sh` ohne Env → Sperren-Abbruch statt Übersprung (real gefahren, s. u.); alternative Lesart: der Lauf, der den Übersprung zeigen soll, endet Exit 2 über `make` | Öffentlicher Vertrag still stillgelegt — Doku beschreibt unerreichbares Verhalten weiter |
| F-2 | HIGH | Die Umstellung des Tests `driver: main() ueberspringt NUR bei einem Beleg, der dem aktuellen Schluessel entspricht` auf `MUTATE_FORCE=1` (`test/mutate-driver.bats:1156`) nimmt dem Test **seinen Zahn**: Mit gesetztem `MUTATE_FORCE` short-circuitet die `&&`-Kette von `mutate.sh:1665` vor dem Schlüsselvergleich — der Lauf wird an der unbekannten `# verify:`-Form abgebrochen, nicht am Vergleich, den der Test-Name behauptet zu binden. Der Mutations-Fall `264-mutate-uebersprung-ohne-schluesselvergleich.sh` (nimmt genau diesen Vergleich weg, Z. 16) färbt damit **keinen** Test mehr rot — real gefahren: `make mutate MUTATE_CASES='264-…'` → `BEFUND … blieb GRUEN — 'driver: main() ueberspringt NUR …' hat keine Zaehne mehr` (94,23 s, Exit 1/2). Der nächste nächtliche `mutate.yml`-Vollsweep meldet denselben Befund und wird rot. Dazu trägt der neue Testkommentar (Z. 1149–1150) eine falsche Zusage: „der Lauf soll am SCHLUESSELVERGLEICH des Uebersprungs gemessen werden“ — gemessen wird an genau dieser Stelle nicht (§3.7). | `AGENTS.md` §3.6, §3.7 | `test/mutate-driver.bats:1142-1160`, `test/mutations/264-mutate-uebersprung-ohne-schluesselvergleich.sh:16` | ja — `make mutate MUTATE_CASES='264-mutate-uebersprung-ohne-schluesselvergleich'` → `0 ok, 1 Befund(e)` (real gefahren, Ausgabe im Review-Lauf belegt) | Zahnverlust im Mutations-Sensor — Test-Name behauptet eine Eigenschaft, die unter der zugehörigen Mutation nicht mehr rot wird |
| F-3 | INFO | Die Rezept-Zeile selbst bleibt unbewacht: Der Wächter-Test fährt `bash harness/tools/mutate.sh` mit `MUTATE_JOBS` in der Umgebung — die Form des Rezepts (`Makefile:250`) ohne die `make`-Ebene, die der gepinnte bats-Container nicht trägt (im Testkopf benannt). Solange der Guard im Skript sitzt, kann die `make`-Ebene ihn nicht umgehen; träte das Rezept aber künftig selbst `MUTATE_FORCE` oder `MUTATE_CASES` bei, disarmierte das die Sperre lautlos, und kein Sensor liest die Rezept-Zeile. | Maintainability | `Makefile:250`, `test/mutate-driver.bats:1390-1416` | nein — kein Sensor liest die Rezept-Zeile | Rezept-Zeile als unüberwachter Umgebungsteil des Wächter-Aufrufs |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Plan-§3-Konformität (Liefer-Punkte) | geprüft, ohne Befund — die vier §3-Zeilen (`mutate.sh`, `mutate-driver.bats`, `sensors/mutate.md`, `harness/README.md`) sind exakt die Arbeits-Flächen des Diffs; nichts außerhalb §3 still mitgenommen. Roadmap-Ruhe-Marker (`e46c6e76`) und Plan-Move (`f8a1fe80`) sind Lifecycle-Begleitung in eigenen Commits, kein Arbeits-Umfang |
| Exit-Vertrag (Skript 1 → `make` 2) | geprüft, ohne Befund — Rezept ohne `-`-Präfix und ohne `|| true` (`Makefile:250`); im realen Teillauf von F-2 endete der Lauf `make: *** Fehler 1`, Make-Exit 2 — die Zusage von `harness/sensors/mutate.md` §Ausgänge gilt für die neue Sperre mit |
| CI-Verträglichkeit (Schwerpunkt des Plans §6 R3) | geprüft, ohne Befund — `mutate.yml` setzt `MUTATE_CASES` je Shard im Step-Umfeld des `make mutate`-Aufrufs (Z. 82–84), und der Shard-Step bricht bei leerer Zuteilung selbst mit Exit 1 **vor** dem `make`-Aufruf ab (Z. 77–80): der Guard trifft keinen Workflow-Aufruf. Der Guard ist damit nicht die Ursache, aber F-2 macht den nächtlichen Lauf aus anderem Grund rot |
| Die vier umgestellten bats-Aufrufe (`MUTATE_STALL_SECONDS`-Block, zwei `# verify:`-Blöcke) | geprüft, ohne Befund — Assertion-Mengen unverändert; die drei `MUTATE_STALL_SECONDS`-Fälle brechen vor dem Guard ab (JOBS-/STALL-/CASES_DIR-Schranken liegen davor), die Umstellung ist dort prophylaktisch, keine Schwächung; die zwei `# verify:`-Blöcke behalten ihre Messung (Status, Meldung), **ihr** Sachverhalt ist F-2 |
| `vollauf()`-Hilfsfunktion — Behauptung „sie aendert nichts an dem, was diese Tests messen“ | geprüft, ohne Befund — Test „voller Lauf mit Befund“ (Z. 1362–1378): Übersprung war vor der Sperre ohnehin nicht erreicht (Slot-Inhalt ≠ Schlüssel); Test „grüner voller Lauf“ (Z. 1380–1390): ein erzwungener voller Lauf schreibt den Slot wie zuvor |
| Guard-Position und Lock-Residuum | geprüft, ohne Befund — Sperre steht nach Lock, JOBS-, STALL- und CASES_DIR-Prüfung, vor `select_cases`, Beleg-Schlüssel, Sofort-Entwertung und Isolationskopie; der EXIT-Trap räumt das Lock (`cleanup`, Z. 459), ein Guard-Abbruch hinterlässt kein Residuum |
| Neuer Wächter-Block (Schwerpunkt 6, zahn-faehrt-die-verdrahtung) | geprüft, ohne Befund — fährt die reale Rezept-Form (Skript-Ebene, `MUTATE_JOBS` in der Umgebung), bindet Exit, Meldung, alle drei Ausweg-Texte, fehlende Isolationskopie (Probe-Log) und byte-gleichen stehenden Beleg; die make-Lücke ist im Testkopf benannt, Residuum als F-3 (INFO) |
| `AGENTS.md` §3.7 — Kommentar-Klassen im Skript | geprüft, ohne Befund — Kopf- und Main-Kommentar der Sperre stehen im Indikativ (Zusage/Abgrenzung), nennen den Sensor namentlich, keine Chronik, keine Befund-Kennung; die falsche Zusage steht im bats-Test und ist unter F-2 gemeldet |
| `comment-claims`-Anschluss | geprüft, ohne Befund — der im Skript genannte Sensor-Name `test/mutate-driver.bats „driver: ohne MUTATE_CASES bricht der Lauf ab, bevor kopiert wird“` trifft den realen Testnamen wörtlich |

### Unabhängige Nachvollziehung (Reviewer-eigene Reproduktion)

- `make mutate MUTATE_CASES='264-mutate-uebersprung-ohne-schluesselvergleich'` real gefahren:
  `mutate: [w2] 264-… BEFUND (94.23 s)`, `mutate: BEFUND … blieb GRUEN — 'driver: main()
  ueberspringt NUR bei einem Beleg, der dem aktuellen Schluessel entspricht' hat keine Zaehne
  mehr`, `0 ok, 1 Befund(e)`, Make-Exit 2 (F-2).
- Sonde zum Übersprung: Fake-Repo (Treiber kopiert, ein Fall, `test/mutations` vorhanden),
  Beleg-Slot mit dem aktuellen `isolation_key` beschrieben, `bash mutate.sh` **ohne**
  `MUTATE_CASES`/`MUTATE_FORCE` → `mutate: ABBRUCH — ohne MUTATE_CASES faehrt hier kein
  Vollauf.`, Exit 1 — der dokumentierte Exit-0-Übersprung bleibt aus (F-1).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Öffentlicher Vertrag still stillgelegt — Doku beschreibt
unerreichbares Verhalten weiter · Zahnverlust im Mutations-Sensor — Test-Name behauptet eine
Eigenschaft, die unter der zugehörigen Mutation nicht mehr rot wird

## Verdikt

**Merge-blockierend: ja.** Zwei HIGHs, beide real gefahren, nicht nur gelesen:

- F-2 entzieht dem Mutations-Sensor einen kuratierten Zahn — der nächtliche `mutate.yml`-Lauf
  wird den 264-Befund melden und rot enden; der Diff verletzt damit die eigene §3.6-Disziplin
  an genau dem Test, den er umstellte.
- F-1 stilllegt ein dokumentiertes Verhalten des Sensors (Exit-0-Beleg-Übersprung) und lässt
  den Vertragstext in `harness/sensors/mutate.md` — im selben Diff berührt — sich selbst
  widersprechen.

Beide HIGHs haben dieselbe Wurzel (Sperre vor Übersprung-Zweig) und sind zusammen in einer
Entscheidung aufzulösen; die Wahl des Weges ist nicht Gegenstand dieses Reports. F-3 (INFO)
trägt keine Merge-Sperre.

**Übergabe:** Findings gehen an den Implementer/Planner zur Entscheidung; die Finding-Klassen
gehen in die Slice-Closure §7 und von dort in den Steering-Loop-Zähler. Dieser Report ist ein
Lauf-Beleg und ersetzt keine Verifikation (Modul 11, getrennter Kontext).

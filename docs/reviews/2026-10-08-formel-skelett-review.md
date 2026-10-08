# Review-Report: slice-formel-skelett-nennt-die-fassungs-ausnahme — 2026-10-08

**Review-Art:** Code — gegen Plan + Konventionen.

**Gegenstand:** `6b8d134c`, `a24fb926` (Claim `6e5fb171`, `dc1e1f04`, `0cc93569` nicht Gegenstand).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

**Eingangs-Kontext:**

- Slice-Plan `slice-formel-skelett-nennt-die-fassungs-ausnahme` (Welle `welle-handbuch-zeigt-den-bestand`)
- ADR-0063 (**Proposed**) Festlegung 1 · ADR-0059 (Accepted) Festlegung 2
- `LH-QA-04`
- `AGENTS.md` §3.6, §3.7; `MR-071`

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Test-Kopf sagt, der Test sehe „`-X`-Operanden in Dockerfile, Makefile und den Workflows"; sein Muster `-X [A-Za-z0-9_./]+=` erkennt vier gültige `-X`-Formen nicht (`-X=main.v=x`, `-X 'main.v=x'`, `-X "main.v=x"`, Tab statt Leerzeichen — gefahren, je „nicht erkannt"). Ein zweiter injizierter Wert in einer dieser Formen außerhalb von `Dockerfile:101` (dort hält Test 6 die Zeile wörtlich) lässt den Skelett-Satz überbreit stehen, und kein Gate meldet es. | `AGENTS.md` §3.6; Skill §LOW/INFO mit Eskalation (Grenzen-Aufzählung ohne Formen-Probe) | `test/release-matrix.bats` · `grep -ohE -- '-X [A-Za-z0-9_./]+='` und Kopf „Grenze: er sieht `-X`-Operanden …" | ja — Formen-Probe des Musters (Kommando unten) | Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe |
| F-2 | MEDIUM | Der neue Satz „kein Wert reist im Binary außer der Fassung" ist als Allaussage falsch: das eingebettete `internal/emit/templates/enforce/traeger.mk` (`//go:embed all:templates/enforce`) trägt `TRAEGER_TAG ?= v0.5.0`, den ADR-0059 Festlegung 2 ausdrücklich als zulässigen Wert im Binary benennt; dazu `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go`. Der Test misst nur die `-X`-Menge (Grenze benannt), die Zusage geht darüber hinaus. Der Wortlaut ist vom Plan (DoD 1) vorgegeben — Plan-Defekt, Übergabe an den Planner. | ADR-0059 Festlegung 2; `AGENTS.md` §3.6 | `harness/tools/homebrew-formula.rb.tmpl:4` · „kein Wert reist im Binary außer der Fassung" | nein — kein Gate liest den Satz gegen die eingebetteten Werte | Zusage neben geänderter Ableitung bleibt überbreit |
| F-3 | MEDIUM | Die Rot-Angabe von DoD 1 („`docs-check` hält die Referenz auf die ADR") trägt nicht: mit `ADR-9999` statt `ADR-0063` im Skelett meldet `make docs-check` in einer Kopie `2543 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Den Anker hält allein der neue bats-Test (Literal). Plan-Defekt — Übergabe an den Planner. | `AGENTS.md` §3.6; `v6.17.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen | Slice-Plan §2 DoD (1) · „**Rot:** `make gates` — `docs-check` hält die Referenz" | ja — Bruchprobe unten | DoD-Rot-Angabe nennt einen Sensor, der den Fall nicht sieht |
| F-4 | INFO | Fall 610 färbt neben Test 9 auch Test 6 (`die build-Stage injiziert die Fassung aus dem uebergebenen Wert`), der `Dockerfile:101` wörtlich hält; die Gegenprobe (Test 9 übersprungen) bliebe rot. Test 9 bindet Eigenes (Makefile, Workflows), dafür trägt aber kein Fall eine Mutation — der Fall trifft die Stelle, die Test 6 schon allein bindet. Kein Exklusivitäts-Anspruch im Fall-Kopf. | Skill §Mutations-Fall nennt einen Test, die Mutation färbt mehrere | `test/mutations/610-fassungs-ausnahme-zweiter-injizierter-wert.sh` | ja — `make test-bats BATS_TARGET=test/release-matrix.bats` unter der Mutation | Mutations-Fall trifft eine von einem anderen Test schon gebundene Stelle |
| F-5 | INFO | Der Skelett-Satz und das Literal im Test verweisen auf „ADR-0063 Festlegung 1" einer **Proposed**-ADR. Der beschriebene Sachverhalt (Injektion an `Dockerfile:101`) ist wahr und vom Test gehalten; nicht gehalten ist, dass Nummer und Inhalt der Festlegung bis zum Accept unverändert bleiben (ADR-0063 §Der Acceptance-Trigger lässt Substanz-Änderungen zu). Kein HIGH: eine Proposed-ADR ist nicht superseded. | ADR-0063 §Der Acceptance-Trigger | `harness/tools/homebrew-formula.rb.tmpl:4` | nein | Verweis auf nicht eingefrorene Festlegungs-Nummer |

**Kommandos und Ausgaben (Kopie per `git archive HEAD` im Scratchpad, danach entfernt):**

- Fall 610 angewandt (`Dockerfile:101` → `… -X main.fassung=${TRAEGER_VERSION} -X main.commit=x}"`), `make test-bats BATS_TARGET=test/release-matrix.bats` →
  `not ok 6 … die build-Stage injiziert die Fassung …` und
  `not ok 9 … das Formel-Skelett nennt genau die eine Ausnahme …` mit Meldung
  `der Bau injiziert nicht genau die Fassung ins Binary — der Skelett-Satz nennt nur sie als Ausnahme: -X main.commit= / -X main.fassung=` — gelesen, die Begründung trifft den Treffer.
- Fall 611 angewandt (Zeile 4 → `kein Wert reist im Binary.`), dieselbe Datei → allein `not ok 9`, Meldung
  `der Kopf des Formel-Skeletts nennt die Fassungs-Ausnahme samt Anker nicht: …` samt dem gelesenen Kopf — trifft. Volle bats-Suite: zusätzlich nur `driver: die Kopie traegt den Sensor-Bedarf inklusive .git` (Artefakt der Kopie ohne `.git`, nicht der Mutation). 611 bindet allein. Beide `sed`-Anker treffen den Quell-Bestand (`MR-071`): die Zeile ändert sich.
- Formen-Probe: `printf '%s\n' "$s" | grep -ohE -- '-X [A-Za-z0-9_./]+='` über `-X main.commit=x` (erkannt), `-X=main.commit=x`, `-X 'main.commit=x'`, `-X "main.commit=x"`, `-X<TAB>main.commit=x`, `-Xmain.commit=x` (alle „nicht erkannt"; die letzte ist kein gültiges Go-Flag und zählt nicht).
- Reale Quelle: `grep -rn -- '-X \|ldflags' Dockerfile Makefile *.mk .github/workflows/ harness/mk` → einzig `Dockerfile:101` (plus Kommentar `Dockerfile:96`); der Satz ist über der `-X`-Menge heute wahr.
- `sed -i 's/ADR-0063 Festlegung 1/ADR-9999 Festlegung 1/'` im Skelett, `make docs-check` → `0 Befund(e)`, Exit 0.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `harness/tools/homebrew-formula.rb.tmpl` §3.7 | geprüft, ohne Befund — Zusage mit Rang-Zeiger, keine Chronik (Wahrheit: F-2) |
| neue Kommentare in `test/release-matrix.bats` und Fällen 610/611 §3.7 | geprüft, ohne Befund — Zusage/Kopplung/Grenze im Indikativ |
| Fall 611 Bindung | geprüft, ohne Befund — färbt allein Test 9, Meldung gelesen |
| `MR-071` (sed-Anker gegen den Quell-Bestand) | geprüft, ohne Befund — beide Anker treffen |
| Plan §3 / §1 Abgrenzung | geprüft — der Diff geht über §3 hinaus (Test und zwei Fälle), Ausschlüsse §1 nicht verletzt; Abweichung an den Planner neben F-2/F-3 |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe · Zusage neben geänderter Ableitung bleibt überbreit · DoD-Rot-Angabe nennt einen Sensor, der den Fall nicht sieht · Mutations-Fall trifft eine von einem anderen Test schon gebundene Stelle · Verweis auf nicht eingefrorene Festlegungs-Nummer

## Verdikt

**Merge-blockierend:** ja — F-1 (HIGH) und F-2/F-3 (MEDIUM). Kein Rollen-Konflikt.

**Übergabe:** F-1, F-4 an den Implementer; F-2 und F-3 sind Plan-Defekte (vorgegebener Wortlaut,
Rot-Angabe der DoD) und gehen über die Rückkante Review → Plan an den Planner. `make gates` lief
in diesem Lauf nicht (Auftrag).

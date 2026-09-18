# Review-Report: slice-traeger-per-fetch-aus-dem-release — 2026-09-18 (Runde 1)

**Review-Art:** Code — geprüft wird der Implementer-Diff gegen Slice-Plan + ADR-0058
und die ADR-0058 selbst gegen die Form-Regeln (Acceptance-Runde ihres Triggers).

**Gegenstand:** `a2d21386` (Architect: ADR-0058, Proposed) · `14d7b6fd`
(Implementer: Fragment, Pins, bats-Zähne, E2E-Stufe, Doku)

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** claude glm-5.3-flash · **Datum:** 2026-09-18

> **Zitier-Form:** Dieser Report friert ein; Kennung statt Adresse —
> `slice-traeger-per-fetch-aus-dem-release` statt seines Lifecycle-Pfads,
> `make traeger-fetch` statt eines Links auf die Sensor-Datei, Baseline-Stellen
> als `v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt>.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- `slice-traeger-per-fetch-aus-dem-release` (Slice-Plan, in `in-progress/`)
- ADR-0058 (Proposed — ihr Acceptance-Trigger ist diese Runde) ·
  ADR-0033 Festlegung 4/5 · ADR-0022 Festlegung 5(b) · ADR-0007 Festlegung 3 ·
  ADR-0040 (Accept-Beleg)
- `LH-FA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`, `LH-FA-12`
- `AGENTS.md` §3 (Hard Rules) · [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- vorherige Findings am Modul: BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext
  (Kontext des F-6-Umfelds), BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht (2×)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der Plan-Kopf beruft den Fetch auf `LH-QA-03` mit „der Fetch braucht davon nur `git`/`make`" — die ADR-0058 Festlegung 4 entscheidet den Transport **im gepinnten Docker-Bild**, der Fetch braucht damit docker. Die ADR gewinnt nach Source Precedence; der Plan ist zu ziehen, nicht die ADR. Der Implementer hat den Plan-Text korrekt nicht angefasst (§3.10) — Plan-Korrektur ist Übergabe-Artefakt an den Planner. | ADR-0058 Festlegung 4 · `LH-QA-03` | docs/plan/planning/done/slice-traeger-per-fetch-aus-dem-release.md:24-26 | ja — der Widerspruch ist an den zwei Textstellen ablesbar | Plan-Kopf beruft sich auf eine LH-Anforderung, die die Entscheidung nicht trägt |
| F-2 | MEDIUM | L2 und der Closure-Trigger (§5) verlangen „→ `archive-welle` läuft"; die Hälfte ist am gepinnten Stand `v0.1.1` nicht messbar — der gefetchte Träger führt das Unterkommando nicht, der Aufruf startet den Init-Pfad. Die Abweichung ist **nicht still**: am Lieferort als GRENZE dokumentiert (Stufen-Kommentar und OK-Zeile in `full-smoke.sh`), der Messbefund trägt, die Nachzieh-Adresse ist benannt (Release-Schnitt, ADR-0058 Festlegung 2, Folgepflicht 3). Der Plan-Text selbst ist unkorrigiert — der Slice kann mit L2 im Wortlaut nicht schließen; Plan-Korrektur und der Folge-Posten sind Planner-Arbeit vor der Closure. | Plan L2 · ADR-0058 Festlegung 2 | docs/plan/planning/done/slice-traeger-per-fetch-aus-dem-release.md:142-154, 246-248 · harness/tools/full-smoke.sh (Stufe `traeger_fetch_im_ziel`, Abschnitt GRENZE) | ja — `make full-smoke` legt genau solchen Träger ab; der „läuft"-Teil färbt erst mit einem Pin, der das Unterkommando führt | DoD-Hälfte am gepinnten Stand nicht messbar, Plan-Text unkorrigiert |
| F-3 | MEDIUM | ADR-0058 Festlegung 2 sagt „Bricht die Kopplung, fällt sie laut: ein Träger, dessen Fassung ein vom Fragment gerufenes Unterkommando nicht führt, bricht beim Aufruf mit einem Fehler — nicht still", und Re-Evaluierungs-Trigger 2 setzt denselben laut-Bruch voraus („lauter Bruch, an einem Ziel ablesbar"). Gemessen am gepinnten Stand `v0.1.1` bricht der Aufruf **nicht** laut — er startet den Init-Pfad (Stufen-GRENZE in `full-smoke.sh`). Die Festlegung ist für genau den Stand, den sie selbst pinnt, nicht wahr; die ADR ist Proposed — jetzt ist die Korrektur gratis, nach `Accepted` kostet sie eine Supersedes-ADR. | ADR-0058 Festlegung 2 + Re-Evaluierungs-Trigger 2 | docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md:151-153, 253-256 | ja — die E2E-Stufe misst genau diesen Aufruf am Ziel | ADR-Festlegung widerspricht der Messung am selbst gewählten Pin |
| F-4 | LOW | Der Gruppen-(a)-Kommentar in `.d-check.yml` nennt `traeger-fetch` unter den Targets, die den `## `-Hilfetext mit „NICHT in gates" **nicht** tragen — die Makefile-Zeile `traeger-fetch: ## … — NICHT in gates` trägt ihn genau. Der Kommentar widerspricht sich selbst: 19 minus 15 ergibt 4, die Ohne-Liste nennt 5. | Maintainability | .d-check.yml:150-154 · Makefile (`traeger-fetch`-Zeile) | ja — `grep '^traeger-fetch:' Makefile` neben dem Kommentar | Config-Kommentar behauptet eine Abwesenheit, die der Bestand widerlegt |
| F-5 | LOW | ADR-0058 paraphrasiert ADR-0033 Festlegung 4 als „hält als Wiederherstellungs-Weg **allein** den erneuten Tool-Lauf fest" — das Verbatim („und wiederhergestellt wird er durch einen erneuten Tool-Lauf") trägt kein „allein". Der Schluss von Festlegung 5 (Schärfung, kein `Supersedes`) hält gegen das Verbatim; die Paraphrase vor `Accepted` glätten, sonst liest ein späterer Lauf eine Exklusivität, die ADR-0033 nie gesetzt hat. | ADR-0033 Festlegung 4 | docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md:58-59 (Kontext) gegen docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md:300-305 | ja — zwei Zitate nebeneinander | Paraphrase schärft ein verbatim Zitat unbegründet |
| F-6 | INFO | Der Plan nennt in §8 „145 Verzeichnisse unter `BEO-ALL/`" ohne das Kommando daneben (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → 145 — die Zahl ist korrekt, die Form fehlt). Kann der Planner im Zug der F-1/F-2-Korrektur nachziehen. | `MR-025` | docs/plan/planning/done/slice-traeger-per-fetch-aus-dem-release.md:327 | ja — das Zählkommando neben der Zahl | Zahl im lebenden Artefakt ohne Kommando daneben |
| F-7 | INFO | Der Zusatzklassen-Block in `harness/conventions.md` ist ein derivatives Register (er misst die Tabellen in `harness/README.md` §Sensors) und wurde mit der README-Änderung im Implementer-Commit fortgeschrieben; §3.8 nennt den Konventionsspeicher als Architect-Artefakt, ADR-0024 ordnet ein derivatives Register der Rolle seiner Originale zu. Dieser Lauf liest die Aktualisierung per ADR-0024 als legitime Mitbewegung — eine Setzung des Architect würde die Zuordnung dauerhaft auflösen, bevor die Klasse ins Register fällt. | ADR-0024 · `AGENTS.md` §3.8 | harness/conventions.md (§Zusatzklassen-Deklaration) | nein — Urteil, kein Gate; Träger wäre eine Architect-Setzung | Eigentums-Zuordnung eines derivativen Konventionsspeicher-Abschnitts nicht gesetzt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pin-Kopplung Makefile ↔ emittiertes Fragment (`TRAEGER_TAG` + sechs `TRAEGER_SHA256_*`, `?=`-Default) | geprüft, ohne Befund — bats Fall 1 grün gefahren; alle sieben Werte in beiden Stellen gelesen, identisch |
| Byte-Gleichheit `harness/tools/traeger-fetch.sh` ↔ `internal/emit/templates/enforce/traeger-fetch.sh` | geprüft, ohne Befund — `cmp` → byte-gleich; bats Fall 2 hält die Kopplung |
| Transport im gepinnten Bild (ADR-0058 Festlegung 4, `AGENTS.md` §3.9) | geprüft, ohne Befund — kein `curl`/`wget` in der Befehlsposition auf dem Host; `curl` nur im Container-Payload; `TRAEGER_IMAGE` digest-gepinnt in Skript und Zwilling |
| Rote Gegenprobe Digest-Zusicherung (Plan L2, ADR-0058 Folgepflicht 2) | selbst gefahren — Ablage vor die Verifizierung geschoben: Fall 4 fällt rot an genau der Zusicherung (`[ ! -e … ]`, bats-Zeile 147), Fall 2 zusätzlich (cmp); der Fall **bindet**. Danach restored, Baum sauber |
| Negative-Fall-Meldung „Digest-Abweichung" | grün gefahren (Fall 4), die Meldung nennt ist/erwartet — behauptete Ursache |
| Fehlt-Fall-Zusage (ADR-0033 Festlegung 4, ADR-0058 Festlegung 3/5) | geprüft, ohne Befund — bats Fall 8: kein Prerequisite, nichts an `GATE_CHECKS`, `archivierung.mk` nennt den Fetch nicht, Dogfood-`gates`/`archive-welle` nennen ihn nicht |
| Plattform-Matrix (`LH-QA-04`) | geprüft, ohne Befund — bats Fall 7: `.exe`-Asset, arm64, Ablage als `ai-harness-init.exe` |
| fail-closed vor dem Transport | geprüft, ohne Befund — bats Fall 5/6: fehlender Pin und unbekannte Plattform brechen mit Exit 2, ohne Transport und ohne Ablage-Verzeichnis |
| E2E-Sicht (`LH-FA-12`): neue Stufe in der Sicht, Anker in ihrer Region | geprüft, ohne Befund — 19 Deklarationen = 19 Tabellenzeilen (`grep -c 'e2e_abdeckung "' harness/tools/full-smoke.sh` → 19 Aufrufe neben Zeile 112/3159; `grep -c '^| \[' docs/user/e2e-abdeckung.md` → 19); die neue Stufe steht als Stufe 4; ihr Anker „ohne den Traeger zu legen" löst in der Stufen-Region auf (`full-smoke.sh:1642`) |
| Rote Gegenprobe Deklaration (Plan L2) | selbst gefahren — Deklarations-Zeile der neuen Stufe entfernt: Fall 1 (Erzeuger gegen committete Tabelle) und Fall 5 (halter) des e2e-Wächters färben rot; restored |
| `docs-check`-Zahl 40 in `harness/sensors/docs-check.md` | geprüft, ohne Befund — `sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '` → 40; Vorstand 39; die davor stehende „37" war um 2 veraltet, die Korrektur ist eine Zustandskorrektur mit Kommando daneben, ohne Chronik (`MR-025`, §3.7) |
| `harness/conventions.md` §Zusatzklassen (31/8/20/0) | geprüft, ohne Befund — alle vier Zählkommandos gefahren, Ausgaben decken die Zahlen |
| `harness/README.md` Werkzeuge-Zeile `make traeger-fetch` | geprüft, ohne Befund — Target genannt, „kein Gate" in der Zeile, Halbsatz was es tut, Netz-Bedarf benannt (`AGENTS.md` §4-Regeln, Modul 13 „genannt, aber kein Gate") |
| ADR-0058 Form | geprüft, ohne Befund — `Proposed` mit Acceptance-Trigger nach ADR-0040-Muster (Beleg: Report ohne blockierenden Befund), `Schärft`-Feld in der Form von ADR-0033, vier Re-Evaluierungs-Trigger, keine Fremd-Kennungen (`d-check` nur als Werkzeug-Name und `<!-- d-check:ignore -->`-Marke), Index-Zeile in `docs/plan/adr/README.md` vorhanden |
| §3.8-Zuschnitt beider Commits (`git show --stat`) | geprüft, ohne Befund — `a2d21386` = ADR-0058 + ADR-Index, Rolle in der Message; `14d7b6fd` = 15 Dateien ohne ADR/AGENTS/Adaptions-Block, Rolle und Kennungen in der Message |
| Fassungs-Fit: `harness/mk/traeger.mk` existiert nur als Emission (Dogfood trägt das Target im Makefile) | geprüft, ohne Befund — entspricht ADR-0058 Festlegung 3; `enforce.go` registriert Fragment und Skript UNBEDINGT, `enforce_test.go`/`baumaussage_test.go` nachgezogen |
| Plan §8 Sichtungs-Angaben (Zählerstände der zwei genannten BEO) | geprüft, ohne Befund — Evidence-Zählung: 1× und 2×, wie der Plan sagt; kein Eintrag erreicht 3× durch diesen Plan |

**Nicht gefahren:** `make full-smoke` — der Closure-Trigger (§5) verlangt ihn grün über
der neuen Stufe; er braucht Netz und liegt außerhalb von `make gates`. Die sechs
`TRAEGER_SHA256_*`-Werte sind lokal nicht gegen die Release-Assets verifizierbar
(Netz); ihre Verifikation ist genau der Gegenstand der E2E-Stufe und damit
Verifier-/Closure-Pflicht. `make gates` wurde vom Implementer über `14d7b6fd`
gefahren und hier nicht wiederholt.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Plan-Kopf beruft sich auf eine LH-Anforderung,
die die Entscheidung nicht trägt · DoD-Hälfte am gepinnten Stand nicht messbar,
Plan-Text unkorrigiert · ADR-Festlegung widerspricht der Messung am selbst
gewählten Pin · Config-Kommentar behauptet eine Abwesenheit, die der Bestand
widerlegt · Paraphrase schärft ein verbatim Zitat unbegründet · Zahl im lebenden
Artefakt ohne Kommando daneben · Eigentums-Zuordnung eines derivativen
Konventionsspeicher-Abschnitts nicht gesetzt

## Verdikt

**Merge-blockierend:** nein — für den Implementer-Diff `14d7b6fd`. Kein HIGH, und
die drei MEDIUM tragen nicht den Code, sondern die Texte um ihn: F-1/F-2 sind
Planner-Übergabe-Artefakte (Plan-Kopf und L2/Closure-Trigger sind vor der
Slice-Closure zu ziehen — §3.10), F-3 blockiert den **Accept-Übergang** der
ADR-0058, nicht den Merge: die ADR bleibt bis zur Klärung von F-3 (und der
Glättung von F-5) `Proposed`; ihr eigener Acceptance-Trigger verlangt einen
Report ohne blockierenden Befund — dieser hier blockiert den Accept, nicht den
Diff. Die L2-Abweichung (F-2) ist als Abweichung dokumentiert, nicht als stille
Verengung: Messbefund trägt, Nachzieh-Adresse ist benannt.

**Übergabe:** Findings F-1/F-2 an den **Planner** (Plan-Korrekturen vor Closure),
F-3/F-5 an den **Architect** (ADR-0058 vor Accept), F-4 an den **Implementer**
(Rückkante), F-6 an den Planner, F-7 an den Architect (Setzung oder ausdrückliche
Ablehnung). Die Finding-Klassen gehen in die Slice-Closure §7 und von dort in den
Zähler. Dieser Report ist ein Lauf-Beleg — er ersetzt keine Verifikation; DoD-/
Spec-Konformität (namentlich `make full-smoke` grün über der neuen Stufe und der
„läuft"-Vorbehalt aus F-2) prüft der Verifier separat.
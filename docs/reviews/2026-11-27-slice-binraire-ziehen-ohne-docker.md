# Review — slice-binraire-ziehen-ohne-docker

**Lauf:** Reviewer, 2026-11-27 · **Diff:** Commit `15cb3586` (16 Dateien, +866/−14) ·
**Gegen:** Slice-Plan (`docs/plan/planning/in-progress/slice-binraire-ziehen-ohne-docker.md`),
ADR-0109, MR-098, ADR-0058/0059, LH-QA-02 — **nicht** gegen die DoD (Verifier).
**Umgebung:** Docker-Daemon aus — `make gates`/`make test` nicht gefahren; geprüft
docker-los (Bats-Läufe am Host, Bruchproben in Kopien unter `/tmp/rvw-slice-binraire`,
`make mutate-greift`).

## Findings

### F-1 — HIGH

- `kategorie`: HIGH
- `quelle`: AGENTS.md §3.7 / Reviewer-Skill HIGH „Kommentar trägt keine der Kommentar-Klassen"
- `pfad`: `harness/tools/dcheck-fetch.sh:6-20`
- `befund`: Der Skriptkopf trägt die Weg-Wahl-Abwägung: (a) das Messungs-Protokoll
  `… traegt KEIN Asset — … (api.github.com/repos/pt9912/d-check/releases/latest, gemessen
  am Schnitt des Pins v0.93.0)` und (c) die verworfene Alternative im Konjunktiv
  `(c) Klon am Pin-Commit + `go build` wäre der Fallback — nicht nötig: er haengte an einer
  zweiten Pin-Stelle (Source-Tarball, der kein Pruefsummen-Asset reist) und an Host-go`.
  Das ist kein Träger der fünf Klassen — die Abwägung gehört an die ADR, die Protokoll-Zeile
  ist Herkunft eines Laufs. ADR-0109 trägt die Weg-Wahl-Abwägung nicht
  (`grep -n 'OCR\|assets\|Registry\|d-check' docs/plan/adr/0109-…` → nur pinsync); der
  Slice-Plan §3 sagte die Entscheidung in der ADR-0109-Platzhalter-Synthese zu, „nicht still
  im Skript". Dieselbe Abwägung steht als zweite Fassung in
  `harness/sensors/dcheck-fetch.md` §Weg — dort ist sie Doku-Text, nicht §3.7-gebunden.
- `verifizierbar`: ja — Mutations-/Doku-Gate fängt nichts; Beleg ist der Zitat-Vergleich Skriptkopf ↔ ADR-0109.
- `klasse`: Abwägung und Messungs-Protokoll als Skriptkopf-Kommentar

### F-2 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (Meldung-Zusage vs gemessene Form, §3.6-Form)
- `pfad`: `harness/tools/dcheck-fetch.sh:65-71`
- `befund`: Die Form-Probe misst `sha256:[0-9a-f][0-9a-f]*` (beliebig lang ≥ 2 hex), die
  Meldung Zeile 68 verspricht `sha256:<64-hex>`. Kein stilles Grün — ein kurzer Digest
  bricht spätestens an `verifiziere` (64-hex-Ist ≠ kürzerer Erwartet) oder am Registry-Zug —
  aber Meldung und ggf. Exit-Klasse (curl-Abbruch statt 2) weichen von der zugesagten Klasse ab.
- `verifizierbar`: ja — Mutations-Patch auf die Zeichenklasse, dcheck-fetch.bats Test 1 färbt.
- `klasse`: Meldung-Zusage weiter als die gemessene Form

### F-3 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (latente Wartungsfalle / Grenze ohne Durchsetzung)
- `pfad`: `harness/tools/dcheck-fetch.sh:76-78` vs `d-check.mk:83-88`
- `befund`: Die Registry/Repo-Zerlegung liest `DCHECK_IMAGE`, während der Image-Weg
  (`DCHECK_REF := ghcr.io/pt9912/d-check@$(DCHECK_DIGEST)`) die Ursprungs-Adresse hart
  verdrahtet und `DCHECK_IMAGE` ignoriert. Bei einer `DCHECK_IMAGE`-Abweichung ziehen die
  zwei Wege dieselbe Digest-Summe aus verschiedenen Registries; die im Kopf genannte Grenze
  („andere Registries traegt dieser Weg nicht", Zeile 75) ist im Code nicht durchgesetzt —
  der Zug versucht jede Registry (Token-Form nur für ghcr.io gemessen). Die Digest-Summe
  selbst hält die Byte-Kette, daher kein HIGH.
- `verifizierbar`: ja — Mutations-Patch auf `DCHECK_REF`, oder bats-Fall mit abweichendem Registry-Teil.
- `klasse`: Pin-Stelle geteilt, Ursprungs-Adresse doppelt abgeleitet

### F-4 — LOW

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.7 (Kommentar-Zusage, die der Code nicht trägt)
- `pfad`: `harness/tools/dcheck-fetch.sh:146-147`
- `befund`: „Layer-Zuordnung: Media-Form entscheidet gzip oder plain (gepinnt am Content,
  dessen Form damit an den Manifest-Digest gebunden ist)" — der Code verzweigt nicht; er
  fährt stets `tar -tzf`/`tar -xzf` (Zeilen 162/166). Ein plain (ungezippt) tragernder Layer
  endet mit der Fehldiagnose „kein gepruefter Layer traegt ein Member d-check" (exit 1, laut,
  ohne Ablage) — keine still grüne Stelle, aber die Meldung diagnostiziert falsch.

### F-5 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (Ketten-Duplikat mit falscher Einzigkeits-Behauptung)
- `pfad`: `harness/tools/dcheck-fetch.sh:22` vs `harness/sensors/dcheck-fetch.md:11-13`
- `befund`: Die Zuordnung Digest ↔ Binary steht in zwei Fassungen — Skriptkopf („an DIESER
  Stelle dokumentiert, an keiner zweiten") und Sensor-Text („an dieser Stelle, nicht an einer
  zweiten") — und beide behaupten die Einzigkeit, die der Bestand widerlegt. Konsistent am
  Lesetag, driftpflichtig über die Commits.

### F-6 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (unvollständige Aufzählung im Fall-Kommentar)
- `pfad`: `test/mutations/799-dcheck-fetch-byte-kette-entzaubert.sh:11` ·
  `test/mutations/801-traeger-host-digest-entzaubert.sh:10`
- `befund`: Die Rot-Probe-Aufzählungen sind unvollständig — Bruchprobe (Kopien): unter 799
  fallen Tests 2, 4 **und 5** des dcheck-fetch.bats (genannt: 2 und 4); unter 801 fallen Tests
  1, 2 **und 7** des traeger-fetch-host.bats (genannt: 1 und 2). Je benannter `expect:`-Zahn
  bindet (die Happy-Fälle fallen jeweils), MR-071/MR-090-Form greift — nur die Beleg-Listen
  im Kommentar sind schief.

### F-7 — INFO

- `kategorie`: INFO
- `quelle`: Reviewer-Skill INFO (dokumentationswürdige, undokumentierte Annahme)
- `pfad`: `harness/tools/dcheck-fetch.sh:133-136, 149-151`
- `befund`: Der Plattform-/Layer-Match nimmt die JSON-Schreibform des Registries an
  (Feldreihenfolge `mediaType → digest → size → platform` nach `tr -d '[:space:]'`) und
  kennt nur `*image.layer.v1.tar*`-Layer-Media-Typen (kein docker-Schema-Layer-Typ). Beide
  Grenzen brechen laut (exit 2, „kein linux/$a-Plattform-Manifest" / „keinen tar-Layer") —
  sie stehen im Skriptkopf und im Sensor-Text nicht.

### F-8 — INFO

- `kategorie`: INFO
- `quelle`: Maintainability (Ablage-Anker zweifach verankert)
- `pfad`: `harness/tools/dcheck-fetch.sh:45` vs `harness/tools/environment-check.sh:172-176`
- `befund`: Der Fetch-Default der Ablage ist CWD-relativ (`.harness/state/bin/d-check`), die
  Anwesenheits-Probe verankert mit `REPO_ROOT`. Beide Verdrahtungen laufen über `make` (Repo-Wurzel) — nur ein
  manuell aus anderem CWD gerufener Fetch legt dahin ab, wo die Probe nicht liest;
  `DCHECK_CARRIER` (SPEC-099) ist die Überschreibung. Annahme „make ist die einzige
  Verdrahtung" — deklariert im env-check-Kommentar, nicht am Fetch selbst.

### F-9 — INFO (Verweis an Verifier)

- `kategorie`: INFO
- `quelle`: Kontext-Eingang (Vorbefund-Deutung)
- `pfad`: `test/environment-check.bats:83-85` (Test 5)
- `befund`: Der behauptete vorbefundene Test-5-Fehlschlag ist am Host reproduziert und
  **keine Regression von 15cb3586** (Zeilen unberührt — Diff-Hunks beginnen bei −119; der
  Fehlschlag ist `env: 'bash': No such file or directory`, der Test-eigene enge
  `PATH="$S:/nonexistent"` lässt die shebang-ENV bash nicht finden). Die Deutung „env vs
  gepinntes Image" trifft den beobachteten Modus nicht — die Deutung ist an der
  Fehlschlag-Ausgabe, nicht an der Ursprungs-Vermutung zu halten.

## Negativbefunde (geprüft, ohne Befund)

- **Pin-Einheit:** der OCI-Zug liest `DCHECK_DIGEST` exakt aus `d-check.mk` (`Makefile`-Rezept
  `@DCHECK_IMAGE="$(DCHECK_IMAGE)" DCHECK_DIGEST="$(DCHECK_DIGEST)" bash …`); `d-check.mk`
  ist vom Diff unberührt, die pinsync-Paarung (`d-check.mk` ↔ Emit-Kante) trägt unverändert.
  Keine zweite Pin-Stelle für den Digest (Ursprungs-Abweichung s. F-3, Summe geteilt).
- **Fail-closed-Kette:** Bruchproben an Kopien — fehlende Prüfsumme und falsche Form brechen
  vor dem Registry-Zug (Shim-Log leer, kein Ablagepfad), Index-/Blob-Abweichung brechen mit
  exit 1 vor der Ablage, fehlender Member und falsche Plattform brechen laut; Träger-Host:
  teilausgeführte Pins, fehlender Tag und fehlendes curl brechen vor dem Transport
  (Shim-Log leer), Abweichung exit 1 ohne Ablage, Windows-`.exe`-Zuordnung getragen.
- **Exit-Klassen:** Skripte ordnen Abweichung=1, Auform=2 je konsistent; keine Doku-Zeile
  (README-Reihe, Makefile-Hilfe, Sensors-Prosa) sagt einen Exit-Satz zu — §3.6-Form
  (Aufruf benennen) nicht berührt.
- **Opt-in-Verdrahtung:** `traeger-fetch-image` bleibt als Target + README-Zeile +
  Sensor-Absatz; der Split Pflicht-Weg (Host) / opt-in (Image) nennt beide Wege, den
  unveränderten Ablageort und die Wächter-Aufteilung (host.bats vs traeger-fetch.bats).
  Target-Namen eindeutig (`grep -c '^dcheck-fetch:\|^traeger-fetch:' Makefile` → je 1,
  `.PHONY` nachgezogen), keine README-Sektion geleert, Vertrag+Bindung je Zeile getragen.
- **Bats-Hermetik:** beide Suiten am Host gefahren, **13/13 grün** docker-los — der
  curl-Stub mit Byte-Map deckt Token/Manifest/Blob je URL, `sha256sum`/`tar` laufen real;
  die Digest-Kette Index↔Manifest↔Layer wird je Blob byte-verifiziert, die Fixtures bauen
  die Kette selbst (Blob → Manifest-Digest → Index-Digest als Pin).
- **Mutations-Fälle 799–802:** `files:` je eine Datei, sed-Anker gegen die reale Quelle
  greifend; `expect:` wortgenau gegen die bats-Testnamen (grep); `make mutate-greift`:
  785/788 greifen — die 3 Befunde (784/785/794, Anker „veraltet") sind die erwarteten
  Vorbefunde, 799–802 greifen je; Bindung je Fall durch Bruchprobe belegt (s. F-6).
- **Inventar-Schärfung:** die d-check-Zeile nennt PATH **und** fetched Ablage als
  ausdrücklich benannte Erweiterung, Anker-Form `· seit slice-binraire-ziehen-ohne-docker`;
  die curl-Zeile nennt jetzt das fail-closed-Verhalten statt der alten Warn-Form; die
  Soll-Herkunft der go/d-check-Pins ist unberührt (pinsync-Paarung).
- **SPEC-099:** Schärfung trägt die Erweiterung normativ (benannte Ausnahme,
  `DCHECK_CARRIER`-Überschreibung, Grenze „ohne Ablage bleibt der Befund") — deckungsgleich
  mit `probe_dcheck_ablage` (`[ -x "$p" ]` = Anwesenheit + Ausführbar-Form); Historie-Zeile
  ergänzt; Referenz-Richtung: die Spec-Zeile nennt (wie ihr Bestand) Harness-Inventar-Pfad
  und Sensor-Zeiger — Muster des Bestands, kein neuer Bruch.
- **MR-015:** kein `spec/lastenheft.md`-Touch im Diff.
- **Kontrakt-Pfade:** `welle-ohne-docker.md`, `open/slice-labor-gates-host-rezepte.md`,
  ADR-0109-Datei — alle aufgelöst; Sensoren-Prosa neu angelegt, README-Index-Zeilen
  folgen der Form.

## Lauf

- `bats test/dcheck-fetch.bats test/traeger-fetch-host.bats` → 13/13 ok (host, netzlos).
- `bats test/environment-check.bats` → 9/10 ok; Test 5 fällt vorbefunden (s. F-9).
- `make mutate-greift` → 788 Fälle, 785 greifen, Befund 784/785/794 (Vorbefunde).
- Bruchproben für 799/801 an Kopien `/tmp/rvw-slice-binraire/{a,b}` — Baum nach Prüfung
  residue-frei (Kopien standen ausschließlich unter `/tmp`).

---

# Addendum — Abgleich-Runde zu Commit `edf99b05` (Fixes F-1 bis F-6)

**Lauf:** Reviewer-Folge, 2026-11-27 · Diff `edf99b05` (5 Dateien, +91/−66).
Methodik wie der Erstlauf: Fassungen gelesen, Bats am Host gefahren, Anker-Kommentare der
Mutations-Fälle gegen Bruchproben gehalten.

## Abgleich je Befund

| Befund | Stand | Beleg |
| --- | --- | --- |
| F-1 (HIGH, Weg-Wahl-Abwägung im Skriptkopf) | **gelöst** | Kopf trägt nur Zustand + `VERTRAG: harness/sensors/dcheck-fetch.md` als Rang-Zeiger (`git show edf99b05 -- harness/tools/dcheck-fetch.sh`); `(a)`/`(c)` und das Messungs-Protokoll sind entfallen; die Abwägung steht allein in der Sensor-Datei §Weg. `grep -n 'ZUORDNUNG\|KEIN Asset\|wäre' harness/tools/dcheck-fetch.sh` → keine Treffer (nur „Ref-Zerlegung"-Beispiel-Notation und der Zeiger-Text) |
| F-5 (LOW, Zuordnung doppelt) | **gelöst** | Die Kette steht nur noch in `harness/sensors/dcheck-fetch.md` §Die Zuordnung; der Skriptkopf nennt sie ausdrücklich als Rang-Zeiger „keine zweite Fassung" — Behauptung und Bestand stimmen jetzt |
| F-2 (LOW, Form-Probe zu weit) | **gelöst** | Probe ist `[[ "$DCHECK_DIGEST" =~ ^sha256:[0-9a-f]{64}$ ]]` (64 exakt); permanente Zähne: dcheck-fetch.bats Test 1 trägt 63-hex- und 65-hex-Fälle je Exit 2 (grün im Lauf gefahren) |
| F-3 (LOW, Registry doppelt abgeleitet) | **gelöst** | Harter Vergleich `[ "$registry" != "ghcr.io" ]` vor dem Token-Zug, fail-closed Exit 2; Wächter-Case ergänzt (`docker.io/…` → Exit 2, „die gepraegte Quelle (ghcr.io)", Shim-Log leer); Sensor-Datei trägt §Registry-Ursprung als Zustands-Doku |
| F-4 (LOW, gzip/plain-Kommentar ohne Code) | **gelöst, mit Rest s. N-1** | Verzweigung implementiert: `*+gzip) zflag="z"` · `*v1.tar) zflag=""` · sonst Exit 2; `tar -t${zflag}f`/`-x${zflag}f` je Eintrag |
| F-6 (LOW, unvollständige Rot-Mengen) | **gelöst** | Bruchproben an Kopien unter `/tmp/rvw-slice-binraire-r2` bestätigen die Kommentare wortgenau: 799 → rot 2/4/5, grün 1/3/6 (Test 3 mit Begründung, warum er grün bleibt); 801 → rot 1/2/7, grün 3/4/5/6 — die gemessenen Mengen stehen vollständig in den Anker-Kommentaren |

Neue Gesamtläufe am Host nach dem Fix: `bats test/dcheck-fetch.bats test/traeger-fetch-host.bats` →
**13/13 ok** (docker-los, netzlos).

## Verbleibend offen (aus dem Erstlauf)

- **F-7 (INFO)** — JSON-Feldreihenfolge- und Layer-Media-Typ-Annahmen des Plattform-/Layer-Match
  (`harness/tools/dcheck-fetch.sh`: `grep -oE '"mediaType"…"digest"…"size"…"platform"…'`);
  die Layer-Menge umfasst weiter nur `*image.layer.v1.tar*`-Formen; beide Grenzen brechen
  laut, stehen aber in Skriptkopf und Sensor-Text unverändert nicht. **Offen.**
- **F-8 (INFO)** — Fetch-Default der Ablage CWD-relativ vs Probe REPO_ROOT-verankert;
  Deckung nur über `make`. **Offen.**
- **F-9 (INFO, für den Verifier — korrigierte Deutung übernommen)** — Der Test-5-Fehlschlag
  von `test/environment-check.bats` am Host ist die Test-eigene Verdrahtung:
  `run env PATH="$S:/nonexistent" bash "$SCRIPT"` lässt die shebang-ENV (`#!/usr/bin/env bash`)
  kein `bash` finden (`env: 'bash': No such file or directory`, Exit 127) — **das ist der
  Fehlschlag-Modus, keine Umwelt-Divergenz „env vs gepinntes Image"**. Nicht von 15cb3586
  verursacht (Hunks beginnen bei −119; der Mechanismus läuft vor dem Skript). Offen für den
  Verifier: der Vorbefund ist als hermeticity-Bruch des Tests zu tragen, nicht als
  Umgebungs-Befund; die Deutung in der Vorlage ist an der Fehlschlag-Ausgabe zu berichtigen.

## Neue Befunde am Fix-Commit

### N-1 — LOW

- `kategorie`: LOW
- `quelle`: Reviewer-Skill „Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil"
- `pfad`: `harness/tools/dcheck-fetch.sh` (Medienform-Zweig, F-4-Lösung) · `harness/sensors/dcheck-fetch.md` (Kopf/Zusage)
- `befund`: Die neue Mehrteil-Zusage — Medienform je Layer entschieden als gzip / plain /
  sonst fail-closed — trägt Mutations-Deckung nur für die gzip-Hälfte (Happy-Fall färbt bei
  entzauntem z-Glied). Der plain-Zweig und der sonst-fail-closed-Zweig haben keinen bindenden
  Bats-Fall (Fixture baut nur `tar+gzip`); ein plain-Layer im gepinnten Image ist praktisch
  erreichbar und würde den ungebundenen Zweig tragen.
- `verifizierbar`: ja — Mutations-Patch auf den plain-Bin (`*v1.tar) zflag="z"`) oder bats-Fall mit plain-Layer-Fixture.
- `klasse`: Mehrteil-Zusage mit Deckung nur je einer Teil-Grenze

### N-2 — INFO

- `kategorie`: INFO
- `quelle`: Rest von F-3 (Ursprungs-Ableitung, zweite Hälfte)
- `pfad`: `harness/tools/dcheck-fetch.sh:55-58` vs `d-check.mk:83-88`
- `befund`: Die Registry-Hartdiagnose fixt das Präfix; das **Repo**-Segement bleibt aus
  `DCHECK_IMAGE` abgeleitet (`repo="${ref#*/}"`), während der Image-Weg `pt9912/d-check`
  hart verdrahtet. Eine `DCHECK_IMAGE`-Abweichung im Repo-Teil brächte den Zug dazu, denselben
  Digest aus einem fremden Reponamen zu suchen — die Summe fängt die Bytes, ein fehlendes
  Objekt bricht laut; kein Reopening von F-3, Rest benannt.

### N-3 — LOW

- `kategorie`: LOW
- `quelle`: Doku-Drift (Prosa-Liste unvollständig)
- `pfad`: `harness/sensors/dcheck-fetch.md` §Wächter
- `befund`: Die Wächter-Aufzählung nennt Happy, Negative (Index-/Blob-/Member) und Vorab-Fälle
  (fehlende Prüfsumme, falsche Prüfform) — die im Fix ergänzten Cases (63/65-hex als
  Prüfform-Untermenge gedeckt; der **Registry-Präfix-Fall** nicht) sind nicht nachgezogen:
  der Registry-Präfix-Fall fällt unter keine der genannten Klassen.
- `verifizierbar`: ja — Leselauf; kein Sensor hält die Liste.
- `klasse`: Wächter-Aufzählung hinter dem Suite-Bestand

## Lauf (Addendum)

- `bats test/dcheck-fetch.bats test/traeger-fetch-host.bats` → 13/13 ok (host, netzlos).
- Bruchproben 799/801 an Kopien `/tmp/rvw-slice-binraire-r2/{a,b}` — Mengen wortgenau wie in
  den Anker-Kommentaren; Baum residue-frei (Kopien nur unter `/tmp`).
- Keine Änderung außer diesem Report; Report uncommitted.

# Review-Report: slice-release-schnitt-koppelt-pin-und-fassung — Runde 3 (2026-09-19)

**Review-Art:** Code — Folgeläufe der Runde 2; geprüft wird ein Commit gegen ihre Befunde.
Kein Neu-Review: Runde 2
(`docs/reviews/2026-09-18-slice-release-schnitt-koppelt-pin-und-fassung-runde-2.md`,
Commit `7c071065`) ist abgehandelt; ihre zwei HIGH (N-1, N-2) und das N-4 sind die
Gegenstände dieser Runde. `make gates` grün über dem Kopf, `make docs-check` 1718/0 —
nicht wiederholt.

**Gegenstand:** `f2d51ddb` (Rolle Implementation) — die Ruheort-Form im publish-Job, der
wahre AUFRUFE-Kommentar, die Form- und Mengen-Haltung im verify-Modus samt der
in-flight SC2012-Umstellung (Asset-Liste von `ls -1` auf die Glob-Array-Form) · HEAD
`f2d51ddb`.

**Skill:** `.harness/skills/reviewer.md` @ v2.0.0 ·
**Modell:** glm-5.3-flash · **Datum:** 2026-09-19

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v6.9.0` ·
> `regelwerk/modul-05-planning-harness.md` §Offene Risiken — diese Zeile ist
> selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-release-schnitt-koppelt-pin-und-fassung` (in-progress, Stand `f2d51ddb`)
- Runde-2-Report (oben) — ihre N-1/N-2/N-4 sind die Gegenstände; N-3/N-5/N-6/N-7 nicht
- ADR-0059 (Proposed — Festlegung 1 „eine Zeile je Asset", Folgepflicht 1) ·
  ADR-0058 (Accepted — Festlegung 1–3 fortbindend)
- [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
  Setzung 1 samt Nachtrag (slice-048) — die Workflow-Disziplin (N-3-Weg-Frage)
- LH-QA-04 (Plattform-Matrix) · [`AGENTS.md`](../../AGENTS.md) §3.7/§3.9
- gepinnte Images: `BATS_IMAGE` (BusyBox) als Proben-Umgebung für die Skript-Proben
  (`make test-bats`-Rezept-Form: read-only Mount, `--network none`); GNU coreutils 9.4
  (Host) als GNU-Probe für die Job-Seite — der Job läuft auf `ubuntu-24.04`
- die Runde-2-Mitgaben 1–5 als Prüfkategorien dieser Runde

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| M-1 | MEDIUM | Die N-4-Hälfte am **Publikations-Runner** bleibt offen: der Job-Schritt (Zeile `run: cd dist && sha256sum -c SHA256SUMS`) hält nur den **Inhalt** — die Zeilen-FORM und die Menge „eine Zeile je Asset" hält er nicht. Gemessen (GNU coreutils 9.4, bare `-c`): eine improper Zeile neben einer gültigen liefert `WARNUNG: 1 Zeile ist nicht korrekt formatiert`, **Exit 0** — der Lauf publiziert weiter; ein Asset ohne Zeile im `dist`-Verzeichnis wird von `-c` nicht erkannt und über `gh release upload/create dist/*` an das Release gehängt. Die Script-Seite hält beide Klassen (gemessen, s. Negativbefunde); die GRENZE-Notiz im Kopf erklärt die Form-Haltung am Skript über die BusyBox-Fassung des **bats-Bilds** — der Runner des Jobs ist GNU, wo die Form ebenfalls ungehalten durchläuft. Der Kommentar, der die beiden Stellen verknüpft, behauptet die Äquivalenz: „dort laeuft dieselbe Pruefung als eine Zeile coreutils" — dieselbe Prüfung ist sie nicht; am Job läuft die Hälfte ohne Form und Menge. | ADR-0059 Festlegung 1 + Folgepflicht 1 · Runde-2 N-4 (zweite Instanz) | `.github/workflows/release.yml:123-130` · `harness/tools/release-sums.sh:25-31,70-105` | ja — die GNU-Probe (Exit 0 mit improper Zeile, gemessen); die Skript-Gegenproben | Fail-closed-Grenze der Manifest-Form unbenannt |
| L-1 | LOW | Der neue Zahn-Kommentar (Fall 18) trägt eine Klausel über die vorige Zahn-Fassung statt über die geltende Zusage: „der gebrochenen Form zusaetze sie still" — sie beschreibt abwesenden Text (das Verhalten der **früheren** Prüfung) und ist zudem verstümmelt; lesbar ist sie weder im Präsens (falsch — der Zahn duldet die gebrochene Form nicht, gemessen) noch im Präteritum (Chronik). Die geltende Zusage steht im selben Kommentar davor; die Klausel ist der einzige Bruch. | [`AGENTS.md`](../../AGENTS.md) §3.7 (Beschrieben wird die Stelle, nicht der Vorgang — Falsch-Form „die frühere Fassung prüfte nur …") | `test/release-matrix.bats:325-328` | nein — Form-Urteil über den Kommentar | Chronik-Klausel über die vorige Zahn-Fassung im neuen Kommentar |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| N-1 Ruheort-Form, **Rot-Richtung** | gefahren — die gebrochene Wurzel-Form (`sha256sum -c dist/SHA256SUMS`) in `release.yml:130` eingesetzt, Fall 18 im gepinnten Image: **rot** mit genau der Ruheort-Assertion (`not ok 1 release: der publish-Job haelt die reisende SUMS fail-closed VOR dem Upload … \``grep -qF 'cd dist && sha256sum -c SHA256SUMS' "$wf"\`` failed, `release-matrix.bats:329`). Der Zahn **verbietet** die gebrochene Form — er friert sie nicht ein; die Meldung benennt die gebrochene Lage über die fehlende Ruheort-Form. Zurückgenommen; der Baum steht wieder auf `f2d51ddb`. (Der Exit-Fang der Probe holte `tail` statt bats — der rote Lauf steht im Meldungsbild.) |
| N-1 Ruheort-Form, **Grün-Richtung** | geprüft ohne Wiederholung — `make gates` grün über `f2d51ddb` (Auftrag); die Job-Zeile ist die gemessene Ruheort-Form, Fall 18 hält sie wörtlich und die Reihenfolge vor dem ersten `gh release upload/create` |
| N-2 AUFRUFE-Kommentar | geprüft gegen [`AGENTS.md`](../../AGENTS.md) §3.7 — Indikativ über den Ist-Zustand („fuehrt die Haltung NICHT ueber diesen Ort", „checkt bewusst nicht aus"), keine Befund-Kennung (das `F-1` des **neuen** YAML-Kommentars ist entfallen — der Neu-Kommentar-Teil von N-6 damit abgehoben; der Altbestand bleibt ungebunden, Cutoff), kein Vorgangs-Perfekt. Deckungsgleich mit dem Job: der publish-Job hat keinen Checkout-Schritt (geprüft), das Skript liegt ihm nicht vor, die Haltung läuft dort als die benannte coreutils-Zeile am Ruheort. Ein Vorbehalt: die Äquivalenz-Formulierung „dieselbe Pruefung" — s. M-1 |
| N-4 Skript-Hälfte | gemessen im gepinnten Image (BusyBox, Rezept-Form): **Basis grün** (2 Assets, passende SUMS, Exit 0); **Richtung A** (Asset aus dem Verzeichnis genommen, Zeile bleibt) → Exit 1 mit der Menge-Meldung („die Menge der Eintraege … ist nicht die Menge der Assets"); **Richtung B** (Asset ohne Zeile) → Exit 1 mit derselben Menge-Meldung; **improper Zeile** → Exit 1 mit der Form-Meldung („ausserhalb der Form") — die Form-Haltung läuft **vor** dem `-c`-Lauf; **fehlende SUMS** → Exit 1 mit der fehlt-Meldung. Beide Richtungen und die Zeilen-FORM sind gehalten, die Meldungen benennen die jeweilige Klasse |
| N-4 Job-Hälfte | **nicht gehalten** — gemessen (GNU coreutils 9.4): bare `-c` mit improper Zeile neben gültiger → `WARNUNG: 1 Zeile ist nicht korrekt formatiert`, **Exit 0**; s. M-1 |
| SC2012 / in-flight | kein `ls`-Rest im Skript (die zwei `grep`-Treffer sind die Wörter „als/also" in Kommentaren); die Mengen-Enumeration liest den Glob als Array mit `nullglob`; shell-lint grün (gates). Der Amend verdeckt nichts: genau drei Dateien (`release.yml`, `release-sums.sh`, `release-matrix.bats`), jeder Hunk gehört zur Behebung der drei Befunde bzw. zur SC2012-Umstellung — keine Doku-, Spec- oder Makefile-Berührung |
| Rest-Referenzen der gebrochenen Form | `sha256sum -c dist` steht außerhalb `docs/reviews/` nirgends im Baum — die alte Form lebt nur noch in den Zeitdokumenten der Runden 1–2 |
| Commit-Form `f2d51ddb` | Rolle Implementation in der Message, eigene Kennungen (`ADR-0059`, `LH-QA-04`), ein Commit; die Message-Behauptungen (Ruheort, Aufrufer, Menge in beide Richtungen, GNU/BusyBox-Grenze) decken sich mit dem gemessenen Zustand — ausgenommen die „dieselbe Pruefung"-Stelle (M-1) |
| Plan §3 zur SUMS-Mechanik | geprüft, ohne Befund — der Plan-Text („reisende SUMS, fail-closed vor dem Upload, die Prüfung liest nur das Verzeichnis") deckt sich mit dem Zustand nach dem Commit |
| GRENZE-Notiz im Skript-Kopf | geprüft, ohne Befund — Indikativ über die echte Grenze: GNU hält eine improper Zeile ohne `--strict` als Warnung durch (Exit 0), und `--strict` fehlt im bats-Bild — durch die eigene GNU-Probe bestätigt; die Form-Haltung am Skript folgt daraus, der Lauf über `sha256sum -c` trägt den Inhalt |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |

**Finding-Klassen dieses Laufs:** Fail-closed-Grenze der Manifest-Form unbenannt (2. Instanz — Runde-2 N-4) · Chronik-Klausel über die vorige Zahn-Fassung im neuen Kommentar

## Verdikt

**Kein blockierender Befund.** Die zwei HIGH der Runde 2 sind abgehoben: N-1 (die
Ruheort-Form steht im Job, die Rot-Richtung färbt von genau diesem Zahn), N-2 (der
AUFRUFE-Kommentar nennt die wahren Aufrufer und deckt sich mit dem Job). N-4 ist zur
Hälfte abgehoben — die Skript-Seite hält Form und Menge in beide Richtungen (gemessen);
die andere Hälfte steht als M-1 offen (MEDIUM, nicht merge-blockierend). Der
Neu-Kommentar-Teil von N-6 ist mit dem `F-1`-Entfall abgehoben; der Altbestand bleibt
ungebunden (Cutoff).

**Der Weg zum Tag-Zug ist frei.** Die Wägung zu den drei offenen Fragen:

1. **M-1 (Job-Seite von N-4) blockiert den Tag-Zug nicht.** Die Klassen fehlende
   SUMS, fehlende Datei und abweichender Digest laufen am Job rot; die improper-Klasse
   und die Menge-Klasse sind am Job ungehalten und brauchen ein Ereignis im
   Artefakt-Kanal, um zu tragen. Das ist eine Mitgabe — abzuhandeln **vor dem Accept
   von ADR-0059**, nicht vor dem Schnitt: der Accept-Trigger verlangt einen Report
   ohne blockierenden Befund (der steht hier), aber Festlegung 1 wird am
   Publikations-Runner nur zur Hälfte gehalten, und der Kommentar behauptet die
   volle Hälfte.
2. **Die N-3-MR-Frage blockiert den Tag-Zug nicht — sie ist dringender geworden.**
   Die Wägung des Auftrags trägt: die MR-Setzung betrifft die **Form der Abweichung**
   (Inline-Check in der Workflow-YAML gegen
   [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
   Setzung 1, Nachtrag), nicht die Tragfähigkeit des Schritts — der Job verifiziert,
   der MR-Eintrag fehlt. Aber `f2d51ddb` hat den Schritt **bewegt** (die Prüfung
   geändert), ohne die Abhebung der Setzung zu benennen — die Runde-2-Mitgabe 3
   gilt unverändert: still berühren lässt die Setzung sich nicht. Separater
   Architect-Zug, parallel oder nach dem Tag-Zug.
3. **Die „Plan-L2-Wortlaut"-Frage blockiert den Tag-Zug nicht.** Sie löst weiterhin
   in keinem Artefakt auf (Runde-2-Wägung 6: nur die zwei Zeilen des Runde-1-Reports,
   die ihren eigenen Nicht-Fund protokollieren) und berührt weder den Job-Schritt
   noch die Release-Mechanik. Separater Planner-Zug.

**Mitgaben:** M-1 vor dem Accept von ADR-0059 (Architect/Implementer) · L-1 an der
Stelle selbst, sobald ein Lauf sie anfasst — der Kommentar ist neu geschrieben und
damit gebunden · die zwei offenen Fragen (N-3-MR, Plan-L2) als separate Züge daneben.
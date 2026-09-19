# Review-Report: slice-release-schnitt-koppelt-pin-und-fassung — Runde 2 (2026-09-19)

**Review-Art:** Code — Folgeläufe der Runde 1; geprüft werden die zwei Abhandlungs-Commits
gegen Plan + Konventionen (Modul 10 §Drei Review-Arten). Kein Neu-Review: Runde 1
(`docs/reviews/2026-09-18-slice-release-schnitt-koppelt-pin-und-fassung-runde-1.md`,
Commit `918d76dc`) ist abgehandelt; ihre zwei MEDIUM (F-1 SUMS-Mechanik, F-2
Restaurierung) sind die Gegenstände dieser Runde.

**Gegenstand:** `a79ac863` (Plan-Pull, Rolle Planner) und `da8c6608` (SUMS-Mechanik,
Rolle Implementation) · HEAD `da8c6608`.

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

- Slice-Plan `slice-release-schnitt-koppelt-pin-und-fassung` (in-progress, Stand `da8c6608`)
- Runde-1-Report (oben) — ihre F-1/F-2 sind die Gegenstände; ihre F-3..F-6 nicht
- ADR-0059 (Proposed — Constraint des Slices; Folgepflicht 1 ist der Mechanik-Gegenstand)
- ADR-0058 (Accepted — Festlegung 1–3 fortbindend)
- [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
  Setzung 1 samt Nachtrag (slice-048) — die Workflow-Disziplin
- LH-QA-04 (Plattform-Matrix) · AGENTS.md §3.7/§3.9 ·
  `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Offene Risiken, §Closure-Regeln
- reale SUMS des Releases `v0.2.1` (über `gh release download` geholt, 6 Zeilen)
- gepinnte Images: `BATS_IMAGE` (BusyBox) und die `test`-Stage (GNU coreutils 9.7) — beide
  als Proben-Umgebung, keine Host-Toolchain

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | HIGH | Der neue publish-Job-Schritt `sha256sum -c dist/SHA256SUMS` löst die in der SUMS stehenden bloßen Dateinamen relativ zum Arbeitsverzeichnis (Workspace-Wurzel) auf; die Artefakte liegen unter `dist/`. Gemessen in **beiden** coreutils-Varianten: Job-Form Exit 1, Ruheort-Form (`cd dist && sha256sum -c SHA256SUMS`) Exit 0 — BusyBox im gepinnten bats-Image und GNU coreutils 9.7 in der `test`-Stage. Der Schritt ist der **erste** des publish-Jobs: jeder Tag-Lauf baut, smoked und bricht dann an der Verifikation, bevor irgendetwas hochgeladen wird — der fail-closed-Schritt ist zum sicheren Fehlschlag der ganzen Publikation geworden. Das Skript selbst kennt die Ruheort-Form (`cd "$dir"` vor `sha256sum -c`, `release-sums.sh:73-76`); der Job-Schritt wiederholt sie nicht. | ADR-0059 Festlegung 1 + Folgepflicht 1 · Liefer-Punkt 1 des Plans | `.github/workflows/release.yml:128` | ja — die zwei Proben; der erste echte Tag-Lauf | Verifikationsschritt löst Manifest-Einträge relativ zum falschen Verzeichnis auf |
| N-2 | HIGH | Der Kopfkommentar des neuen Skripts nennt als Aufrufe „das Rezept `release-artifacts` (generate) und der publish-Job der Release-Workflow (verify)" — der publish-Job ruft das Skript **nicht**: er führt roh `sha256sum -c` aus, und ohne Checkout ist das Skript dort gar nicht vorhanden. Der verify-Modus des Skripts wird außerhalb des bats-Laufs (Fall 19) von nichts gerufen. Wer die Verkettung über diesen Kommentar prüft, liest einen Träger, den es nicht gibt — und attribuiert die Form-Vorprüfung an einen Ort, an dem sie nicht läuft. | [`AGENTS.md`](../../AGENTS.md) §3.7 (Ein Kommentar beschreibt, was da ist) | `harness/tools/release-sums.sh:20-21` (gegen `.github/workflows/release.yml:127-128`) | ja — der YAML-Schritt gegen den Kommentar | Kommentar behauptet ein Aufruf-Verhältnis, das nicht da ist |
| N-3 | MEDIUM | Der Halten-Schritt ist ein **Inline-Prüfblock in der Workflow-YAML** — MR-014 Setzung 1 (Nachtrag slice-048) sagt wörtlich: „ein Check wird nie in der Workflow-YAML definiert … Ein Inline-Prüfblock in der YAML bleibt verboten — unabhängig davon, auf welchem Runner er liefe." Das versionierte, shell-lint-gedeckte Gegenstück (`harness/tools/release-sums.sh verify`) wird vom Job nicht gerufen. Die Abweichung ist in keinem `MR`/ADR benannt; der neue YAML-Kommentar begründet nur den fehlenden Checkout, nicht die berührte Setzung. | [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1 (Nachtrag 2026-07-25, slice-048) | `.github/workflows/release.yml:127-128` | ja — der MR-Wortlaut gegen den Schritt | Check-Definition in der Workflow-YAML statt im versionierten Artefakt |
| N-4 | MEDIUM | Die Grenze der gestrichenen `--strict`-Form ist unbenannt und real: die Form-Vorprüfung verlangt nur **eine** gültige Zeile (`release-sums.sh:69`), und GNU `sha256sum -c` (der Runner des Jobs) lässt improper-Zeilen neben gültigen als Warnung durch — **Exit 0, gemessen** (BusyBox bricht mit Exit 1). Auf dem Publikations-Runner reitet ein Manifest mit unformatierten Zeilen und gekürzter Eintragliste durch; und keine der beiden Hälften prüft die Vollständigkeit „eine Zeile je Asset" (ADR-0059 Festlegung 1) — ein Asset, das **nicht gelistet** ist, wird von keiner Richtung erfasst. Gefangen bleiben: fehlende SUMS, ganz fremdes/leeres Manifest, abweichender Digest, gelistet-und-fehlt (alle vier gemessen rot). Der Skript-Kommentar nennt die Gelistet-Seite („Jede gelistete Datei muss da sein"), nicht die Listungs-Seite. | ADR-0059 Festlegung 1 („eine Zeile je Asset") | `harness/tools/release-sums.sh:67-76` · `.github/workflows/release.yml:128` | ja — die Proben (GNU Exit 0 mit improper-Zeile) | Fail-closed-Grenze der Manifest-Form unbenannt |
| N-5 | LOW | §6 führt den Bootstrap-Unfall als drittes Risiko mit Ausgang *eingetreten*; dessen Payload nennt keinen Carveout und keine Folge-Slice-Kennung — die geschlossene Menge des Baseline-Regelwerks verlangt für *eingetreten* genau diese zwei —, sondern den Restaurierungs-Commit (`e34ef1de`) und die Register-Beobachtung. Substanziell ist der Ausgang getragen (Schaden im Diff, Klasse im Register, beide Adressen auflösbar); die Form weicht ab. Derselbe Payload-Typ liegt im `done/`-Bestand vor (slice-052, slice-083, slice-084 — `grep -l 'Ausgang.*eingetreten' docs/plan/planning/done/*.md`). | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst | Plan §6 (Risiko 3) | nein — Form-Urteil über den Plan-Text | Risiko-Ausgang *eingetreten* trägt Maßnahme statt Kennung |
| N-6 | LOW | Der **neue** YAML-Kommentar begründet die Schritt-Platzierung mit „dieser Job checkt absichtlich nicht aus (F-1)" — eine Review-Befund-Kennung als Herkunfts-Form; sie löst nach `docs/reviews/**` auf und dort **mehrdeutig**: jeder Report führt ein F-1, und das F-1 der Runde 1 handelt die SUMS-Mechanik, nicht das Checkout-Design. §3.7 lässt Herkunft nur als **ein** auflösbare Feld in den Anker-Formen (`LH-*` · `ADR-*` · `· seit slice-<Kennung>`). Der Bestand trägt dieselbe Klasse mehrfach (`release.yml:112,137,152` — Cutoff: kein Nachrüsten); der hier gebundene Kommentar ist der neue. | [`AGENTS.md`](../../AGENTS.md) §3.7 | `.github/workflows/release.yml:125` | ja — `grep -rn 'F-1' docs/reviews/` zeigt die Mehrdeutigkeit | Befund-Kennung als Herkunft in neuem Kommentar |
| N-7 | LOW | Der Reihenfolge-Zahn (Fall 18) findet die erste Zeile, die auf `gh release (upload|create)` matcht — auch in einem **Kommentar**. Die M3-Mutation (Platzhalter-Kommentar mit dem Wortlaut `gh release create` vor dem verify-Schritt) färbt Fall 18 rot; ein unschuldiger Kommentar desselben Wortlauts brächte denselben roten Lauf. Über-tight — dieselbe textuelle Klasse wie die übrigen Zähne der Datei, aber eine latente Wartungsfalle. | Maintainability | `test/release-matrix.bats:329-332` | ja — die M3-Mutation | Reihenfolge-Zahn matcht Kommentarzeilen |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `release-sums.sh` generate | geprüft, ohne Befund — Konvergenz (Glob ohne Selbstbezug der SUMS, temp+`mv`), is-file-Wache, deterministische Zeilenfolge (Sortierung über den alphabetischen Glob, `:52-53`); Fall 19 grün |
| Regex gegen die reale SUMS `v0.2.1` | geprüft, ohne Befund — 6 Zeilen, 6 Regex-Treffer, 0 Nicht-Treffer; alle sechs Makefile-Pins stehen wörtlich in ihr (`awk '/^TRAEGER_SHA256/{print $NF}' Makefile` je `grep -qF` gegen die SUMS → 6× OK). **Der Auftrag sagte „sieben Zeilen" — gemessen sind sechs**: die SUMS listet die sechs Binaries, sich selbst nicht; sieben ist die Asset-Zahl |
| Zähne-Bindung (Fall 17/18/19) | geprüft, ohne Befund — alle drei grün am unmutierten Baum (`--filter SUMS` im gepinnten Image); M1 färbt Fall 18 **allein** rot, M2 Fall 17 **allein** — kein anderer Zweig deckt die geschwächte Zusage, die Zähne binden |
| Plan-Pull `a79ac863` | geprüft, ohne Befund — ein Commit, eine Datei (der Plan), Rolle Planner in der Message; die shortstat-Angabe der Restaurierungs-Zeile stimmt (`git show --shortstat e34ef1de` → 2 Dateien, 489 insertions(+), 24 deletions(-)); append-only bestätigt (`git merge-base --is-ancestor v0.2.0 e34ef1de` → wahr, `v0.2.0` steht weiter auf `70139992`, kein Force-Push sichtbar) |
| Commit-Zuschnitt `da8c6608` | geprüft, ohne Befund in der Rollen-Trennung — die DoD-Änderung (SUMS in Liefer-Punkt 1) lief der Planner-Commit `a79ac863`; der Implementer-Commit ergänzt nur die §3-Verfeinerungs-Zeile (die Verfeinerungs-Praxis, die der Plan selbst zweimal befolgt) |
| Fremd-Kennungen in beiden Messages | geprüft, ohne Befund — nur eigene IDs (`ADR-0059`, `ADR-0058`, `LH-QA-04`, `LH-QA-02`) |
| §6-Risiko-Text (Bootstrap-Unfall) | geprüft, ohne Befund — der Vorfall steht als Risiko-Beschreibung (Originalinformation), der Ausgang trägt Zustand und Beleg; keine Chronik im Ausgang |
| Register-Verknüpfung | geprüft, ohne Befund — `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` existiert mit `observation.md`/`state.md`/`evidence/slice-release-schnitt-koppelt-pin-und-fassung.md`, `state.md`: `Stand: offen` — der Plan-Ausgang zitiert den Stand korrekt (1×) |
| Kanal-Split-Wägung (Auftragspunkt 1) | trägt — s. Wägung 1; keine doppelte Erzeugung |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 2 |
| LOW | 3 |

**Finding-Klassen dieses Laufs:** Verifikationsschritt löst Manifest-Einträge relativ zum falschen Verzeichnis auf · Kommentar behauptet ein Aufruf-Verhältnis, das nicht da ist · Check-Definition in der Workflow-YAML statt im versionierten Artefakt · Fail-closed-Grenze der Manifest-Form unbenannt · Risiko-Ausgang *eingetreten* trägt Maßnahme statt Kennung · Befund-Kennung als Herkunft in neuem Kommentar · Reihenfolge-Zahn matcht Kommentarzeilen

## Verdikt

**Merge-blockierend: ja für den Tag-Zug.** N-1 macht den publish-Job zum
sicheren Fehlschlag an jedem Lauf — der nächste Tag baut, smoked und bricht an
der Verifikation, bevor irgendetwas publiziert wird; der Release-Schnitt
vollzöge sich nicht. N-2/N-3/N-6 liegen an derselben Verdrahtungs-Stelle.
**Nein für den bestehenden Baum:** die drei Zähne sind grün (gemessen), das
Skript und das Rezept tragen, die Rote Gegenprobe des Implementers hält in der
behaupeten Form (M1/M2) — der Bruch liegt allein im Job-Schritt, der lokal
unsichtbar ist (die Grenze steht im Kopf derselben YAML: kein Gate führt den
Workflow aus).

**ADR-0059 bleibt `Proposed`.** Der Accept-Trigger verlangt einen Report ohne
blockierenden Befund; die blockierenden Befunde dieser Runde treffen die
Mechanik des Folgevollzugs (Folgepflicht 1), nicht die Festlegungen der ADR —
die Konsistenz-Prüfung der Runde 1 (Form der Teil-Ablösung, Dogfood-Hälfte,
Kopplung) steht und wird hier nicht bestritten.

**Mitgabe an den Auftraggeber für den Tag-Zug** — was gelten muss, damit der
Zug frei ist:

1. Die Verifikation im publish-Job muss die SUMS-Einträge **vom Ruheort des
   Manifests** auflösen — gemessen ist die Wurzel-Form rot (Exit 1, beide
   coreutils-Varianten) und die Ruheort-Form grün; jede Umstellung der
   Verdrahtung ist zugleich die Stelle von N-2/N-3/N-6.
2. Der AUFRUFE-Kommentar des Skripts muss den realen Träger des verify-Modus
   nennen — heute behauptet er einen, der nicht ruft.
3. Ob der Job ohne Checkout einen Inline-Check tragen darf, ist eine
   Setzungs-Frage an MR-014 Setzung 1 (Nachtrag) — ein neuer `MR`-Eintrag oder
   die Rückkehr zur Regelform (versioniertes Artefakt, der Step ruft es); still
   berühren lässt die Setzung sich nicht.
4. Die Zähne sind danach nachzuziehen — Fall 18 hält heute die **gebrochene**
   Form fest (M4: die arbeitsfähige Ruheort-Form färbt ihn rot, gemessen).
5. Die N-4-Grenze (improper-Zeilen im GNU-Job, Vollständigkeit „eine Zeile je
   Asset" ungeprüft) ist zu benennen oder zu prüfen — heute steht sie in
   keinem Kommentar und in keiner Prüfung.

### Wägungen zum Auftrag

1. **Kanal-Split der Erzeugung — trägt, ohne Verdoppelung.** Zwei Generatoren
   wären der Fehler: ein Manifest, das der Job selbst aus den heruntergeladenen
   Artefakten erzeugte, beschriebe auch beschädigte konsistent und prüfte
   nichts; ein Rezept ohne Haltung gäbe eine im Artifact-Kanal beschädigte
   Menge ungeprüft ans Release. Die Begründung des Implementers („getrennte
   Rollen statt zwei Generatoren") trägt genau so. Die Analogie zu ADR-0059
   Festlegung 3 stimmt in der Klasse (Erzeugung und Haltung an getrennten
   Orten), nicht im Kanal-Begriff: Festlegung 3 trennt **Kanäle** (git gegen
   Release), diese Mechanik trennt **Vorgangs-Orte** (Bau gegen Publikation) —
   der Unterschied ist benannt und macht die Mechanik nicht falsch. Genau ein
   Generator, genau ein Haltungs-Ort.
2. **Fail-closed-Richtung im Job.** Die Reihenfolge hält im Text (verify
   `:128` vor dem ersten `gh release upload` `:156`) und die Streichung färbt
   rot (M1, gemessen — Fall 18 allein, kein anderer Zweig). Die Einordnung des
   Implementers — kein Gate führt Workflow-YAML aus, nur die textuellen Zähne
   sehen die Verdrahtung — stimmt mit der selbst deklarierten Grenze der Datei
   überein (release.yml Kopf, Start-Smoke-Absatz: „lokal ist das nicht
   sichtbar, weil kein Gate den Workflow ausführt"). Sie ist aber genau der
   blinde Fleck, auf dem N-1 steht: die gebrochene Runtime ist lokal
   unsichtbar, und der Zahn hält sogar die gebrochene Form fest (M4) — der
   Text-Zahn bindet an den Defekt, nicht gegen ihn.
3. **Die Zähne binden — gemessen, mit Polarität.** M1 (verify-Schritt
   entfernt): Fall 18 rot an `grep -qF 'sha256sum -c dist/SHA256SUMS'`
   (`release-matrix.bats:325`), Fall 17/19 grün. M2 (generate-Aufruf entfernt):
   Fall 17 rot an `release-matrix.bats:318`, die übrigen grün. M3 (Upload vor
   die Verifikation): Fall 18 rot an der Ordnungs-Zeile `:332`. Keine der drei
   Schwächungen wird von einem anderen Zweig gedeckt — grün heißt hier
   binden, und die gebrochene Zusage färbt von genau diesem Zahn. Die
   Kehrseite der Bindung ist M4: der Zahn verlangt die gebrochene Form
   wörtlich (N-1-Konsequenz, Mitgabe 4).
4. **BusyBox-Begründung und ihre Grenze.** `sha256sum --strict` existiert im
   gepinnten bats-Image nicht (Probe: Exit 1) — die Begründung trägt. Die
   Regex-Vorprüfung hält gegen die reale SUMS: 6/6 Zeilen, 0 Nicht-Treffer,
   alle sechs Makefile-Pins wörtlich enthalten. Die Grenze der Streichung ist
   real und läuft auf dem **Publikations**-Runner auf: GNU ohne `--strict`
   lässt improper-Zeilen als Warnung durch (Exit 0 gemessen), BusyBox bricht
   (Exit 1) — N-4. Die Form-Vorprüfung fängt nur das ganz fremde/leere
   Manifest, und die Vollständigkeit „eine Zeile je Asset" prüft keine
   Richtung.
5. **§3.9 und die Workflow-Praxis.** Auf dem Runner ist der rohe
   `sha256sum`-Schritt kein §3.9-Fall (die Regel bindet den Host-Lauf des
   Agenten, nicht CI). Gegen die Workflow-Praxis des Repos schon: MR-014
   Setzung 1 (Nachtrag) verbietet den Inline-Prüfblock ausdrücklich
   runner-unabhängig, und der Kopf derselben YAML deklariert die Setzung als
   Praxis des eigenen Files — N-3. Die no-checkout-Entscheidung selbst ist
   etabliert (GH_REPO-Kommentar) und begründet; sie begründet die
   Setzungs-Berührung nicht.
6. **Fremd-Kennungen und Zuschnitte.** `a79ac863`: nur der Plan, Rolle
   Planner — der Plan-Pull ist sauber vom Mechanik-Commit getrennt, und die
   DoD-Änderung (SUMS in Liefer-Punkt 1) lief **nicht** der ausführende Lauf.
   `da8c6608`: die fünf Mechanik-Dateien + die §3-Verfeinerungs-Zeile, Rolle
   Implementation. Kein Fremd-Bezeichner in beiden Messages (grep über `%B`).
   Der Plan-Pull deckt den Diff-Umfang: Restaurierungs-Zeile §3 (shortstat
   stimmt, gemessen), Bootstrap-Unfall als drittes §6-Risiko mit Ausgang
   (*eingetreten* → Restaurierung trägt den Schaden, Register-Beobachtung
   trägt die Klasse — keine Chronik im Ausgang; die Payload-Form ist N-5),
   SUMS-Mechanik-Zeile §3 mit den drei Zähnen — geprüft gegen den
   Commit-Bestand `f9b62059..da8c6608`, jede Datei-Klasse des Laufs hat eine
   Plan-Zeile. Die „Übergabe Plan-L2-Wortlaut" aus dem Auftrag löst weiterhin
   in keinem Artefakt auf — `grep -rn 'Plan-L2' docs harness .harness spec
   test` → nur die zwei Zeilen des Runde-1-Reports, die ihren eigenen
   Nicht-Fund protokollieren; gegenstandslos erklärt ist sie nirgends. Aus
   dieser Runde: unbeantwortet, nicht abgehandelt — die zwei konkreten
   Antworten auf Runde 1 (F-1 → `da8c6608`, F-2 → `a79ac863`) tragen; falls
   die Kennung eine dritte Übergabe meinte, ist sie in keinem Artefakt
   benannt.
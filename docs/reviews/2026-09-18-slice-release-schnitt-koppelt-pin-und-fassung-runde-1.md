# Review-Report: slice-release-schnitt-koppelt-pin-und-fassung — Runde 1 (2026-09-18)

**Review-Art:** Code — geprüft wird der Diff gegen Plan + Konventionen + die
Proposed-ADR der Runde (Modul 10 §Drei Review-Arten).

**Gegenstand:** slice-release-schnitt-koppelt-pin-und-fassung · Diff-Range
`ed94a6c3..dff4a8f3` (7 Commits) · Tag `v0.2.1` → `77471f53` (Nebenzweig zum Tip)

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
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-release-schnitt-koppelt-pin-und-fassung` (in-progress, Stand dff4a8f3)
- ADR-0059 (Proposed — Mit-Gegenstand der Runde, Acceptance-Trigger verlangt diesen Report)
- ADR-0058 (Accepted — Festlegung 1–5, Fitness Function, Teil-Ablösungs-Gegenstand)
- ADR-0055, ADR-0032 (Accepted — die Form der Teil-Ablösung und der Index-Zusatz)
- LH-QA-02, LH-QA-03, LH-QA-04, LH-FA-01 (spec/lastenheft.md)
- AGENTS.md §3 (Hard Rules) · Modul 5/6/10 der Baseline `v6.9.0`
- Kontext: der releasing-Slice (`open/`) und der Register-Beleg
  `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad`

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die `SHA256SUMS` des Releases `v0.2.1` wurde von Hand hochgeladen (`gh api repos/pt9912/ai-harness-init/releases/tags/v0.2.1 --jq '.assets[] | "\(.name) \(.created_at)"'` → SUMS 2026-09-19T04:11:03Z gegen Assets 03:55:23–25Z), aber kein Schritt des Release-Vorgangs erzeugt sie — `make release-artifacts` baut nur die sechs Binaries, der publish-Job lädt `dist/*`; Folgepflicht 1 von ADR-0059 ist für diesen Schnitt als Akt, nicht als Mechanik vollzogen, und der nächste Schnitt wiederholt die Lücke — die CI am Tag brach genau an der fehlenden SUMS. | ADR-0059 Festlegung 1 + Folgepflicht 1 (Proposed — Constraint dieses Slices) | `.github/workflows/release.yml` (publish-Job) · `Makefile` (`release-artifacts`) | ja — Asset-Liste des nächsten Tags bzw. ein Workflow-Dry-Run ohne Upload zeigt, dass `dist/` keine `SHA256SUMS` trägt | ADR-Folgepflicht als Akt statt als Mechanik vollzogen |
| F-2 | MEDIUM | Die Makefile-Restaurierung über dem Tag-Grund (`e34ef1de`, 489 Zeilen laut `git show --stat e34ef1de`) — der größte Umfangs-Zuwachs des Laufs — trägt keinen Plan-Eintrag: §3 führt die Datei nur als Pin-Update, die zwei „Verfeinert"-Blöcke nennen flock-Bruch und ADR-0059-Mechanik, §6 weder Vorfall noch Folge-Risiko; getragen ist der Vorfall nur im Register-Beleg und in der Commit-Message — der Verifier liest Plan+DoD und findet die Restaurierung in keinem geplanten Umfang. | Maintainability (Modul-5-Verfeinerungs-Praxis, die der Plan selbst zweimal befolgt) | `docs/plan/planning/done/slice-release-schnitt-koppelt-pin-und-fassung.md` §3/§6 | ja — der Plan-vs-Code-Diff des Verifiers | Ungeplanter Umfangs-Zuwachs ohne Verfeinerungs-Eintrag |
| F-3 | LOW | Der GRENZE-Kommentar der E2E-Stufe nennt „der gepinnte Release-Stand v0.2.0", die Pins tragen seit `dff4a8f3` v0.2.1 (`grep -n 'v0\.2\.[01]' harness/tools/full-smoke.sh` → :1542 gegen `grep -n '^TRAEGER_TAG' Makefile` → v0.2.1) — der Kommentar beschreibt einen vergangenen Stand als den gepinnten. | AGENTS.md §3.7 | `harness/tools/full-smoke.sh:1542` | ja — die zwei greps | Kommentar nennt vergangenen Pin-Stand als den lebenden |
| F-4 | LOW | Die `state.md` des neuen Register-Verzeichnisses endet ohne Zeilenende (`tail -c 1 …/state.md | od -An -c` → `n`) — zeilenbasierte Sensoren lesen die Schluss-Zeile nur mit Toleranz. | Maintainability | `docs/plan/planning/observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/state.md` | ja — `tail -c 1` | Textdatei ohne Zeilenende |
| F-5 | INFO | Der „Emitter-Default" der Pin-Kopplung hat nie einen Code-Träger gehabt — `git log -S TRAEGER_SHA256 -- internal/emit/emit.go` ist leer, die Digest-Stellen waren nur Makefile und Fragment-Vorlage (`git grep -c TRAEGER_SHA256 70139992 -- internal/emit/emit.go` → leer); die Teil-Ablösung zitiert die Fitness-Zeile korrekt, die nicht existierende Stelle wird als solche nicht benannt. | ADR-0059 (Teil-Ablösung, „die Stellen ‚Emitter-Default' und ‚Fragment-Default'") | `docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md` (§Supersedes (Teil)) | ja — `git log -S` | Pin-Stelle der Fitness Function ohne Code-Träger |
| F-6 | INFO | Die Annahme „docs-check rot am Tag-Baum" ist widerlegt: der ci-Fehlschlag am Tag `v0.2.1` war der Ziel-Modus-Fetch der Stufe `traeger_fetch_im_ziel` (curl 404 auf `SHA256SUMS`, 03:53:22Z — 18 min vor deren Upload), im selben Log meldet d-check „20 Datei(en) geprüft, 0 Befund(e)". | Maintainability — Beleg: CI-Run 35419762106, `gh run view 35419762106 --log-failed` | (CI-Log, kein Repo-Pfad) | ja — der Run-Log-Aufruf | Tag-Zustand ohne Log-Lektüre behauptet |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `internal/emit/templates/enforce/traeger.mk` + emittierter Zwilling `traeger-fetch.sh` | geprüft, ohne Befund — kein Digest-Wert (`grep -c 'TRAEGER_SHA256'` → 0), Tag v0.2.1, byte-gleich (bats Fall 2) |
| `test/traeger-fetch.bats` (10 Fälle) | geprüft, ohne Befund — Teilweise-Mutation rot an Fall 7, die übrigen 9 grün (s. Wägung 6) |
| Makefile-Pin-Paar ↔ `SHA256SUMS` | geprüft, ohne Befund — alle sechs SUMS-Einträge identisch mit den sechs Makefile-Pins (SUMS-Download, Zeichenvergleich) |
| ADR-0059 Form (Teil-`Supersedes`, Index-Zusatz, Verbatim-Zitat) | geprüft, ohne Befund — Form hält gegen ADR-0055/ADR-0032 |
| ADR-Commit-Zuschnitt (§3.8) + Fremd-Kennungen in der Range | geprüft, ohne Befund — `8ce18768` berührt nur ADR-Datei + ADR-Index; kein Fremd-Bezeichner in den sieben Messages |
| `docs/user/e2e-abdeckung.md` (regeneriert) | geprüft, ohne Befund — Stufe-4-Text trägt den Vollzug/laut-Bruch, Zeilenverschiebungen konsistent mit dem full-smoke-Wachstum |
| `harness/README.md` Werkzeuge-Zeile | geprüft, ohne Befund — SUMS-Kette und ADR-0059 Festlegung 3 getragen |
| Register-Beleg + `observation.md` (ohne-argument) | geprüft, ohne Befund — der Vorfall steht einmal erzählt (Fund, Klasse, Schaden, Reparatur, CI-Lage); keine Doppelung mit Plan oder Commit |
| Release-Text `v0.2.1` (externer Text) | geprüft, ohne Befund — Stand-Form (Stand, Assets, Grenze), keine Chronik, keine Befund-/Slice-Kennungen; der blob/main-Link auf ADR-0059 ist eine bewegliche Adresse in externem Kontext |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** ADR-Folgepflicht als Akt statt als Mechanik vollzogen · Ungeplanter Umfangs-Zuwachs ohne Verfeinerungs-Eintrag · Kommentar nennt vergangenen Pin-Stand als den lebenden · Textdatei ohne Zeilenende · Pin-Stelle der Fitness Function ohne Code-Träger · Tag-Zustand ohne Log-Lektüre behauptet

## Verdikt

**Merge-blockierend:** ja für den anstehenden Tag-Zug — F-1: der Release-Schnitt
soll nicht erneut vollzogen werden, bevor die `SHA256SUMS`-Erzeugung im
Release-Vorgang trägt oder als ausdrückliche Übergabe mit Kennung steht (der
heutige Upload war Handarbeit des Auftraggebers, gemessen an den Asset-Zeiten).
Nein für den bestehenden Baum: die Mechanik ist am Tip gemessen (Ziel-Modus-Fetch
real grün, `make host-bin`-Sonde, bats-Suite) und die CI auf `dff4a8f3` ist grün.
Der Accept von ADR-0059: F-1 betrifft seine Folgepflicht 1 — vor dem Accept
klären oder als Übergabe benennen; F-5 ist INFO und blockiert den Accept nicht.

### Wägungen zum Auftrag

1. **Unfall und Reparatur.** (a) Die Reparatur ist **keine §1-Vergrößerung**:
   kein Punkt der Ausdrücklich-NICHT-Liste (Fetch, Signier-Schritt,
   Stempel-Mechanismus, Emissions-Struktur) deckt die Makefile-Restaurierung,
   und §3 führt die Datei als update-Zeile. Sie ist aber **unplant im Umfang**
   (489 Zeilen gegen „der Pin zeigt auf den neuen Stand") und trägt keinen
   Verfeinerungs-Eintrag — F-2. (b) Die Register-Beobachtung trägt den Vorfall
   **einmal und vollständig** (Fund, Klasse — laut-Bruch deckt das fehlende
   Argument, nicht ein unbekanntes Unterkommando —, Schaden, Reparatur
   append-only, CI-Lage); der Plan erzählt nichts davon doppelt, weil er gar
   nichts davon erzählt — die Kehrseite von (a). (c) §6 führt den Vorfall
   **weder als Risiko noch als Übergabe** — derselbe Teil von F-2.
2. **ADR-0059 gegen die Messung.** Die Wand ist reproduziert: das `v0.2.0`-Asset
   hasht zu `0a5851f4…` (Pin-Modus-Fetch gegen diesen Pin, Exit 0), das
   veröffentlichte Binary bettet `37c67efa…` ein
   (`grep -oa 'TRAEGER_SHA256_LINUX_AMD64 ?= [0-9a-f]\{64\}'` am Asset), und der
   Tag-Baum trägt die korrekten Werte (`git show v0.2.0:internal/emit/templates/enforce/traeger.mk`).
   Die Teil-Ablösung hält der Form: Verbatim-Zitat der abgelösten
   Festlegung-1-Hälfte, wörtliche Aufzählung dessen, was fortbindet, Index-Zusatz
   mit Umfang und revidierender ADR (ADR-0032-Folgepflicht); ADR-0055 ist die
   zweite Anwendung derselben Form. Die Dogfood-Begründung (Einzeldigests
   bleiben, Kanal-Split) trägt: das Makefile ist nicht embedded — der einzige
   embedded Träger ist die Vorlage (F-5 rückt die fehlende dritte Stelle zurecht).
   Die Kopplung Makefile↔SUMS ist an `v0.2.1` über **alle sechs** Einträge
   identisch gemessen. Die SUMS-Integrität reist über den Release — F-1 zur
   Mechanik; die Grenze „kein Signier-Schritt" bleibt Bestand (Plan §1) und ist
   Re-Evaluierungs-Trigger 1 der ADR.
3. **Festlegung 2 am neuen Binary.** `grep -c 'TRAEGER_SHA256'
   internal/emit/templates/enforce/traeger.mk` → **0**; die Sonde am frisch
   gebauten Binary (`make host-bin`): `grep -c 'TRAEGER_SHA256'` → 0,
   `grep -oa 'TRAEGER_TAG ?= v0\.2\.1'` → 1 — kein build-abhängiger Wert im
   Binary, der Tag als Release-Entscheidung. Beide Proben gefahren.
4. **Zwei Kanäle.** Ziel-Modus real gefahren (`TRAEGER_TAG=v0.2.1` ohne
   Digest-Pins, `bash harness/tools/traeger-fetch.sh`): Exit 0, Träger abgelegt,
   `sha256sum` → `da4589f6…` = Makefile-Pin = SUMS-Eintrag; die SUMS selbst aus
   dem Release geholt und alle sechs Einträge gegen die Makefile-Pins gehalten.
   Dogfood-Modus über `make traeger-fetch` (Export-Zeile Makefile:53) am
   Makefile-Pin — beide Kanäle sind verdrahtet, nicht nur getestet. Der
   Teilweise-Bruch: siehe 6.
5. **Tag-Zustand.** `v0.2.1` → `77471f53` ist ein **Nebenzweig**-Commit
   (`git merge-base --is-ancestor 77471f53 dff4a8f3` → 1), der Baumunterschied
   zum Tip ist genau die Plan-Verlinkung (5+/2−). Am Tag: ci FAILURE — Ursache
   SUMS-404, nicht docs-check (F-6); release SUCCESS ohne jeden docs-check-Schritt
   (Workflow liest kein Gate). Am Tag `v0.2.0`: **beide** Workflows FAILURE in
   10–12 s — das beschädigte Makefile brach `make release-artifacts` sofort; der
   Unfall ist am Tag selbst belegt. Mitgabe: der Zug ist nötig — der
   Release-Schnitt ist erst vollzogen, wenn der Tag-Baum seinen Gates-Beleg
   trägt (die zwei Disziplin-Zeilen des releasing-Slices) und die SUMS im selben
   Vorgang entsteht (F-1); die Klasse „ge-taggter Stand trägt keinen
   Gates-Beleg" ist dreimal gefallen und hängt am releasing-Slice mit Ausgang
   *weiter offen*.
6. **bats-Zähne.** 10 Fälle gelesen; die Teilweise-Mutation selbst gefahren
   (Guard `if [ -z "$sha" ] && [ -n "$teilweise" ]` → `if false` in **beiden**
   Zwillingen, bats-Image gepinnt): Fall 7 rot mit `[ "$status" -eq 2 ]' failed`,
   die übrigen 9 grün — der Zahn bindet, das Rot kommt von dieser Mutation:
   unter der geschwächten Zusicherung fällt der Lauf still in den
   Manifest-Kanal und legt den Träger ab (Exit 0), und genau das fängt der Fall.
   Arbeitsbaum danach restauriert (`git status --porcelain` → 0).
7. **Übergaben an den Planner.** ADR-0059 ist als Constraint im Plan §3 benannt
   („das Übergabe-Artefakt, das dieser Slice als Constraint liest") — am Tag
   fehlt genau dieser Block, das ist die Plan-Verlinkung des Zugs. Die Klasse
   und der pausierte Handbuch-Nachzug stehen im releasing-Slice (`open/`, §6 mit
   Ausgang *weiter offen*). Die Kennung „Plan-L2-Wortlaut" aus dem Auftrag löst
   in keinem Artefakt auf (`grep -rn 'Plan-L2' docs/plan docs/reviews harness`
   → leer) — falls sie eine dritte Übergabe meint, ist sie in keinem Artefakt
   benannt; nichts wurde still gelassen, soweit messbar.
8. **Fremd-Kennungen und Zuschnitte.** Kein Fremd-Bezeichner in den sieben
   Messages der Range (grep über `%B`); der ADR-Commit `8ce18768` berührt nur
   ADR-Datei + ADR-Index, Rolle in der Message; alle Commits tragen Rolle und
   Kennung. Release-Text: Stand-Form, chronik-frei.
# Review-Report: slice-release-job-tap-nachzug-und-schritt-7-folgt — 2026-09-29

**Review-Art:** Code-Review — geprüft gegen: Slice-Plan
`slice-release-job-tap-nachzug-und-schritt-7-folgt` (inkl. Plan-Anpassung
`dfeaba69`), ADR-0064, ADR-0066, `AGENTS.md` §3, `AGENTS.md` §6
(Reviewer-Skill statt DoD — die DoD-Abhakung bleibt beim Verifier).

**Gegenstand:** Diff `dfeaba69^..d1a4b1f4` (vier Commits: Plan-Anpassung
Planner · LP1 `34b11a9e` · LP2 `6b1bdbbf` · Ruhe-Marker `d1a4b1f4`), HEAD
`d1a4b1f4`, Arbeitsbaum clean.

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 (`9565beb4`) ·
**Modell:** GLM (Z.ai) · **Datum:** 2026-09-29

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v6.13.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).
> Ein `pfad`-Feld auf den **geprüften Gegenstand** zitiert den Stand des Laufs
> und darf ihn festhalten.

**Eingangs-Kontext:**

- Slice-Plan `slice-release-job-tap-nachzug-und-schritt-7-folgt` (§1 mit
  Geber-Bedingungen und Abgrenzung, §6 Risiken, §8 Beobachtungs-Sichtung)
- ADR-0064 (Accepted — Folgepflicht 2/3, Festlegung 4, §Fitness Function
  Zeilen *Job-Form* und *Übergabe ohne Text*)
- ADR-0066 (Accepted — Re-Evaluierungs-Trigger 1)
- `AGENTS.md` §3 (Hard Rules, namentlich §3.6, §3.7, §3.11)
- Skript-Quellen: `harness/tools/tap-nachzug.sh`,
  `harness/tools/tap-nachzug-nutzlast.sh`, Makefile-Rezept `tap-nachzug`

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Abweichung von ADR-0064 Festlegung 4 („Ort: ein Umgebungs-Secret, kein Repository-Secret") und von der Fitness-Zeile *Job-Form* (`environment:`) ist im Slice-Plan §1/LP1 begründet (Auftraggeber-Setzung 2026-09-29, Ersatz-Bindung durch `needs: publish` + Tag-Trigger) und die bats-Fälle binden die Plan-Aufzählung — aber kein **lebendes** Artefakt trägt die Abweichung: `releasing.md` Schritt 7 zitiert Festlegung 4 unmittelbar neben der abweichenden Form (Repo-Secret), ohne den Unterschied zu nennen, und der bats-Kopf verankert sich in den ADR-Fitness-Zeilen, deren Aufzählung `environment:` führt, während der Fall ihre Abwesenheit bindet. Der Plan ist ein Planungs-Artefakt mit Lifecycle-Ende; nach `v6.13.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz ist das Vehicle für eine dokumentierte Abweichung von einer `Accepted`-Festlegung das Architect-Verdikt als Folge-ADR (`supersedes`) — nicht der Plan allein. | ADR-0064 Festlegung 4 + §Fitness Function · `v6.13.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz | `.github/workflows/release.yml:211` · `test/tap-nachzug.bats:971-975` · `docs/user/releasing.md:112-116` | nein — kein Gate liest ADR-Zitate gegen die Implementation; Träger ist dieser Review | ADR-Abweichung nur im Plan getragen |
| F-2 | LOW | Schritt 7 schreibt dem Job die Invocation `make tap-nachzug TAG=<tag>` zu; der Job fährt `run: make tap-nachzug` (exakt so gebunden), und TAG reist als Step-`env` (`release.yml:212`). Der Satz beschreibt die Form des lokalen Aufrufs, nicht die Job-Form; ein Leser, der die Prozedur gegen `release.yml` prüft, findet `TAG=<tag>` nicht in der Job-Zeile. | Maintainability — dieselbe Klasse wie `BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle` (dort 3×; Plan §8 meldet derartige Fundstellen dem Verifier) | `docs/user/releasing.md:104-106` | nein — kein Gate hält `releasing.md` gegen `release.yml` (Plan LP2 benennt diese Deckungslücke selbst) | Prozedur-Wiedergabe eines Werkzeug-Vertrags reicht weiter als die Quelle |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Job-Form `release.yml` gegen alle zehn Zeilen der Plan-Aufzählung (LP1) — `needs: publish`, byte-gleiche `if`-Zeile (`release.yml:130` vs `:201`), kein `environment:`, Checkout mit `persist-credentials: false` (`:208`), `permissions: contents: read`, genau ein `run: make tap-nachzug`, Step-`env` (`:211-212`), kein `${{` im `run:`, kein `env:` auf Workflow- oder Job-Ebene, genau ein `secrets.`-Treffer in der Datei, kein Secret im `publish`-Job | geprüft, ohne Befund |
| bats-Fälle (`test/tap-nachzug.bats:975-1082`): je Aufzählungs-Zeile ein Fall (10/10); jede gebundene Schwächung strukturell rot-fähig (je Zeile einzeln entfernt bzw. Secret anders gesetzt bzw. Verzweigung im `run:`); leere Mengen mit `[ -n "$…" ]`-Sonde gesichert (`tap_run`); die vacuous-green-Fälle (environment, if) sind durch den Existenz-Fall (Job-Anlage + `needs`) gedeckt | geprüft, ohne Befund |
| Meldungs-Zitate in Schritt 7 gegen Skriptquelle gefahren: „Ohne `TAP_TOKEN` … Exit 2 vor jedem Netz-Zugriff" (`tap-nachzug.sh:147-148`, Schritt b vor c vor jedem Netz-Aufruf) und „endet mit `Vorab-Tag, Tap bleibt`" (`tap-nachzug.sh:156` — verbatim Teil der Zeile `tap-<modus>: Vorab-Tag, Tap bleibt (<tag>)`, Exit 0, im Job wie lokal grün) | geprüft, ohne Befund |
| Schritt-Nummern: 1–8 ohne Umbau; Schritt 7 bleibt Schritt 7 (auch im Einleitungssatz), Schritt 8 verweist korrekt auf „(Schritt 7)" und hängt an `make tap-check TAG=<tag>`; die Nummer von Schritt 6 (Zustandsfeld von `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`) unberührt | geprüft, ohne Befund |
| Formen-Probe zur Zahl `63` in `releasing.md` (`Nicht gebunden`-Aufzählung, durch den Diff geändert): die zehn neuen Fälle sind Datei-Lektüre über `$WF` (awk/grep) und lesen keine Vergleichslogik — die Nicht-Gebunden-Aussage trägt für 63 wie für 53; das Kommando steht daneben (MR-025), Zähler gemessen | geprüft, ohne Befund |
| Checkout-Zählung der Kommentar-Köpfe (`ci.yml`, `release.yml`): gemessen — neun Checkouts repo-weit (ci 4, release 3, mutate 1, upstream-drift 1), genau einer mit `fetch-depth: 0` (`ci.yml:105`; übrige Treffer sind Kommentar-Zeilen) | geprüft, ohne Befund |
| §3.7 an den neuen Kommentaren (release.yml tap-Kommentar, bats-Kopf, ci.yml-Kopf, releasing.md-Neutext): Zustands-Beschreibung, Rang-Zeiger, Grenze — keine Chronik, keine Befund-Kennung als Grund, keine verworfene Alternative; der ci.yml-Kommentar nennt den neuen Stand statt der früheren Zahl | geprüft, ohne Befund |
| Commit-Zuschnitt: `dfeaba69` (Rolle Planner, nur Plan-Datei), `34b11a9e` (LP1: release.yml + ci.yml + bats), `6b1bdbbf` (LP2: releasing.md), `d1a4b1f4` (Ruhe-Marker) — je eine Rolle, keine Mischopte; §3.3 nicht betroffen (keine Move+Inhalt-Mischung); slice-mv-Commits `81c6e060`/`c32e5404` sind reine Tool-Läufe (Move + Verweis-Nachzug) | geprüft, ohne Befund |
| Ruhe-Marker-Commit `d1a4b1f4` (Form): derivativ — folgt dem Verzeichnis `in-progress/`, eigener Commit, Marker ersetzt „Nichts in Arbeit" statt eine zweite Quelle zu führen | geprüft, ohne Befund |
| MR-069-Form: der Job checkt das Repo aus und ruft `make tap-nachzug` — die Prüfung lebt im Repo; die Prüfung des `publish`-Jobs bleibt inline (Bestand, unberührt) | geprüft, ohne Befund |
| Mutations-/Deckungs-Anspruch: weder `releasing.md` noch die Suite behauptet `make mutate`-Deckung für die Job-Form-Zähne (Datei-Lektüre, gefahren in `make test`); die Grenze — Gates können kein Secret lesen und keinen GitHub-Lauf fahren, der erste Tag-Lauf ist der Beleg — ist im bats-Kopf und in Plan LP1 benannt | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** ADR-Abweichung nur im Plan getragen ·
Prozedur-Wiedergabe eines Werkzeug-Vertrags reicht weiter als die Quelle

**Sensors dieses Laufs:** `make ci-lint` EXIT 0 (actionlint, gepinntes Bild) ·
`make docs-check` nach dem Commit (Ergebnis in der Übergabe).

## Verdikt

**Merge-blockierend:** nein — kein HIGH; das MEDIUM (F-1) ist vor der
Slice-Closure zu klären, nicht durch Umbau des Jobs: Die Abweichung selbst ist
Auftraggeber-decided, im Plan §1 begründet und test-gebunden. Ihr fehlendes
Vehicle ist ein Übergabe-Artefakt an den Architect — die Folge-ADR (Verdikt 2
bzw. 3 des Konflikt-Pfads) oder das ausdrückliche Architect-Verdikt, das die
Closure-Notiz ohnehin für ADR-0066 Trigger 1 einsammelt. Die Closure darf
nicht still ohne diesen Nachschub erfolgen; F-2 geht als vierter Beleg der
genannten Register-Klasse in die Closure §7.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei
Plan-Defekt); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7
und von dort in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** — er
wird über Läufe hinweg nicht wieder gelesen, und muss es nicht. Der Report
ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier
separat (`v6.13.0` · `regelwerk/modul-11-verification.md`); namentlich die
Rot-Belege je bats-Fall und der Abgleich der Wiedergaben in Schritt 7 gegen
Skript und Workflow sind dort zu fahren.

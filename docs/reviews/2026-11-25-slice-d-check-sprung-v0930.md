# Review-Report: slice-d-check-sprung-v0930 — 2026-11-25

**Review-Art:** Code — Code-Review gegen Plan + Konventionen (`v6.18.1` · `regelwerk/modul-10-review-harness.md` §Drei Review-Arten).

**Gegenstand:** `slice-d-check-sprung-v0930`, Commits `8f012d58` → `3e9fc7ec`
(`625cdef0` Pin-Lieferung, `aa2cee57` Übergabe, `9cdb898a` Link-Nachzug, `3e9fc7ec`
Plan-Berichtigung). Plan: `slice-d-check-sprung-v0930` in `in-progress/` — geprüft
gegen die **berichtigte** Fassung (`3e9fc7ec`, ausdrücklicher Ausschluss „MR-Eintrag", §1).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** glm-5.3-flash · **Datum:** 2026-11-25

> **Zitier-Form** (Norm-Block, bleibt stehen). Kennung, nicht Adresse:
> `slice-d-check-sprung-v0930` statt Lifecycle-Pfad, `make docs-check` statt
> Link auf die Sensor-Datei, Baseline-Stellen als Tag + Pfad in Inline-Code
> (`v6.18.1` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice).

**Eingangs-Kontext:**

- `slice-d-check-sprung-v0930` (berichtigte Fassung, Stand `3e9fc7ec`)
- aktive MRs: `MR-010`, `MR-062`, `MR-063`, `MR-086`, `MR-091`, `MR-092`; Form-Nachbarn `MR-051`, `MR-053`, `MR-065`, `MR-067`, `MR-071`, `MR-090`
- berührte `LH-*`: `LH-QA-01`, `LH-QA-02`
- `AGENTS.md` §3 (Hard Rules), dort §3.5/§3.6/§3.7/§3.9 gelesen

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Gegenmessung trägt in keinem Beleg-Träger (Commit-Message `aa2cee57`, Slice-Plan §9.2) die Aufteilung je Modul und Grund-Code — nur Stufen-Summen („110 Befunde, 11 Grund-Codes, alle neun Module mit Basis"). `MR-063` Setzung 1 verlangt, dass die Messung *je Modul die Grund-Codes nennt, die ihre Basis trägt*, und setzt ausdrücklich: eine Gesamtzahl ersetzt die Aufteilung nicht; die MR-063-Eigenform listet die Verteilung (`cut -f3 · sort · uniq -c`) zeilenweise. | `MR-055`, `MR-063` | `slice-d-check-sprung-v0930.md` §9.2; Commit-Message `aa2cee57` | ja — ein Nachlauf der Übergabe §9.2 mit Verteilung je Grund-Code unter beiden Digests bestätigt oder widerlegt die Summen | Aufteilung der Gegenmessung-Basis fehlt hinter einer Gesamtzahl |
| F-2 | MEDIUM | Die MR-063-Symlink-Prüf-Bedingung entfällt: weder Commit-Message `aa2cee57` noch Plan §9 nennen die Kontrolle „Symlinks stehen" aus der Form (MR-092 trug sie als „10 von 10, 0 reguläre"); `MR-067` (Prüf-Bedingung vor den Kommandos) ist in den Trailern genannt, fährt aber kein Kommando. Ohne sie basiert die byte-gleich-Bilanz auf der Annahme, der `git archive`-Klon habe die MR-063-Lage — ein identischer Klon-Bruch auf beiden Pins bliebe byte-gleich und unbeobachtet. | `MR-063` Setzung 2, `MR-067`, `LH-QA-02` | `slice-d-check-sprung-v0930.md` §9.2 | ja — der Nachlauf der Symlink-Kontrolle auf der `git archive`-Kopie von `625cdef0` (`find .claude/rules -type l / -type f`) | Prüfvorbedingung der Gegenmessung ohne Kommando benannt |
| F-3 | LOW | Plan §3 nennt die `roadmap.md`-Berührung auch nach der Plan-Berichtigung `3e9fc7ec` nicht — der Datei-Satz der Tabelle und der echte Diff divergieren; getragen ist der Handgriff nur an der Commit-Message `625cdef0` („Ruhe-Marker entfällt … Handgriff wie `70ed9c0c`"). Der Handgriff selbst ist legitim: vom `planning`-Modul erzwungen (`planning-drift`, Ruhe-Marker bei beanspruchtem Slice), vom DoD `make gates` grün verlangt und im Commit benannt. | Maintainability (Plan-Fidelity) | `slice-d-check-sprung-v0930.md` §3 vs. `625cdef0` (roadmap.md hunk) | ja — `make docs-check` hält die Marker-Lage; der Plan-Defekt fährt kein Sensor | Berührung des Diffs ohne Plan-Tabelle-Zeile |
| F-4 | LOW | Doku-Drift am Bestand: `docs/user/benutzerhandbuch.md` führt die versionierte Prosa „die neue Fassung `v0.86.1`" (Zeile 816) und „Pin `v0.86.x`" (Zeile 826), geschrieben in `5d7e7453` und seitdem unangetastet — der Pin ist jetzt `v0.93.0`. Vom Diff unberührt; die Einordnung unter den Doku-Update-Punkt der DoD (§2, „Pin-Segment-Fassung") trägt die Verifikation, nicht dieser Review. Bestätigt zugleich den Auftraggeber-Hinweis „chronisch für ältere Ziel-Fassungen". | Maintainability | `docs/user/benutzerhandbuch.md:816`, `:826` | partially — `make docs-check` fährt die versionierte Prosa nicht | pin-datierte Handbuch-Prosa hinter dem Pin-Stand |
| F-5 | INFO | Der dritte Verhaltens-Delta der Delta-Lesung (`v0.88.0`: `--trace` erkennt Namens-Kennung ohne `trace`-Block; Plan §3 nennt die Voraussetzung über `MR-057`) ist in der Gegenmessung nicht gemessen — nur in den advisory-RTM-Targets wirksam (`doc-trace`/`doc-complete`, kein Gate). | `MR-057` | `slice-d-check-sprung-v0930.md` §3 (v0.88.0), §9.2 | nein — advisory Target, kein Gate-Lauf | benanntes Werkzeug-Delta ohne Messstufe |
| F-6 | INFO | Der Ergebnis-Commit der Mutations-CI ist strukturell re-run-ungeeignet: ein zweiter `ergebnis`-Job auf demselben Branch pusht `mutate-ergebnis.txt` non-fast-forward (ohne `--force`, `MR-091` Setzung 2 (c)) — in Run 45625795106 (Attempt 3) scheiterte der Push (Exit 2 im Log) und der Branch wurde danach geräumt. Für diesen Slice ist der Konsum-Träger an §9.7 benannt (Job-Log statt File); die Mechanik selbst ist die dokumentationswürdige Annahme. | `MR-091` | Run 45625795106, Job-Log `ergebnis` (139305369935), Terminal-Abschnitt `! [rejected] … (non-fast-forward)` | ja — ein Wiederholungslauf desselben Branch reproduziert die Ablehnung | Ergebnis-Commit ohne Re-Run-Weg |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pin-Stand, drei Pin-Leben (`d-check.mk`, `internal/emit/emit.go`, Pin-Fassung der Kommentar-Blöcke in `internal/emit/templates/d-check.yml`) | geprüft, ohne Befund — `grep -rn 'v0\.86\.1\|3e0b9779'` über `internal/`, `.d-check.yml`, `d-check.mk`, `test/`, `docs/user/` nennt außer den eingefrorenen Trägern (`MR-092`-Eintrag, `done/`-Slices) nur benutzerhandbuch-Prosa (F-4 behandelt) |
| Werkzeug-Deltas des Fragments gegen den Handgriff-Satz `MR-010`/`MR-062` | geprüft, ohne Befund — der Diff trägt genau drei Deltas-Klassen (Pin-Zeile, drei `--disable`-Anhänge an den sechs fokussierten advisory-Recipes, `doc-manual` verbatim hinter `doc-usage` ohne `--enable`-Modul und damit ohne Marke); Hunk-Kommando „6" steht im Kopf, `test/doc-block-marke-wiring.bats` grün (belegt am Commit) |
| `exempt-targets`-Eintrag `doc-manual` (Auftrags-Abweichung 2) | geprüft, ohne Befund — keine Senkung: der Eintrag ist die dritte Mechanismus-Antwort des `targets`-Moduls auf `gate-undocumented`, Form trifft (Gruppe (b): eigener `## `-Hilfetext, keine Prosa-Erwähnung im Gate-Index — `doc-manual` steht weder in `Makefile:gates` noch in `harness/README.md`); die Plan-Tabelle wurde im selben Commit nachgetragen (erlaubte Implementer-Erweiterung) |
| Modul-Aktivierungen (neue opt-in-Module `metrics`/`pinsync`/`linelength`) | geprüft, ohne Befund — keine Aktivierung: die `modules:`-Zeile bleibt bei den neun bestehenden Modulen, kein ADR nötig (`AGENTS.md` §3.5, die byte-gleich-Bilanz der Gegenmessung trägt die Begründung) |
| Behauptete Gates über den Ausschnitt hinaus | geprüft, ohne Befund — keine Zeile des Diffs hebt ein Gate-Ziel, lockert eine Schwelle oder nennt ein Target neu als Gate; die drei `--disable`-Anhänge räumen opt-in-Module ab, die in keinem Prüfbereich aktiv sind |
| Mutations-Fälle 786–789 (`MR-071`/`MR-090`) | geprüft, ohne Befund — je Fall ein zeilengenauer Anker im Quell-Bestand (`^DCHECK_(DIGEST|IMAGE) \?=` bzw. die Tab-Konstanten in `emit.go`), `# files:`- und `# expect:`-Köpfe vollständig; die erwarteten Wächter `TestDefaultDigest_MatchesCanonical`/`TestDefaultImage_MatchesCanonical` existieren und lesen die kanonische Quelle `d-check.mk`, nicht eine Fixture |
| CI-Konsum der Mutations-Runde (Beweisklasse, Auftrag-Frage) | geprüft, mit Ergebnis — belegt: `gh api …/actions/jobs/139305369935/logs` (Run 45625795106, Attempt 3) trägt je-Fall-`ok` für 786–789 (Shards 6/7/8/9), `Fallmenge: 82 (Slice: 82)` und `Urteil: gruen`; `MR-091` Setzung 1 (Probe per CI-Branch vor der Verifikation, Konsum vor der Verifikation) erfüllt. Das Ergebnis-File selbst ging nicht auf den Branch (F-6, INFO, an §9.7 benannt) |
| Grenze der `vcs --staged`-Sonde (§3.6-Klasse, der Auftrag-Frage) | geprüft, ohne Befund — trägt: die Sonde reproduziert die CHANGELOG-Differenz nicht und die Lücke steht an derselben Stelle benannt (Plan §9.4, „nicht verdeckt"); beide Module opt-in, in keinem Prüfbereich aktiv — kein grüner Sensor verdeckt eine ungesicherte Zusage desselben Laufs |
| Stempel-Lage | geprüft, ohne Befund — `.harness/state/gates-passed.head` = `3e9fc7ec` = HEAD; `make gates` nicht nachgefahren (Stempel deckt), nach diesem Report läuft `make docs-check` |

## Drei Abweichungen (Urteile)

1. **Roadmap-Ruhe-Marker-Touch** — legitim: Der Ruhe-Marker „Nichts in Arbeit" dürfte bei einem Slice in `in-progress/` nicht stehen (`v6.18.1` · `regelwerk/modul-06-roadmap.md` §Roadmap-Struktur, Marker-Vächter in beide Richtungen); das `planning`-Modul färbt sonst rot und der DoD-Punkt `make gates` grün erzwingt den Handgriff. Im Commit `625cdef0` benannt inkl. Handgriff-Vorbild `70ed9c0c`. Kein blockierendes Finding; Rest: F-3 (LOW, Plan-Tabelle).
2. **`exempt-targets` für `doc-manual`** — korrekt: keine Senkung am Gate-Index, sondern die vom `targets`-Modul selbst vorgesehene dritte Antwort (`authority`-Zeile, `exempt-targets`-Eintrag); Form trifft Gruppe (b) (Hilfetext, keine Prosa-Erwähnung), das Target trägt keinen Gate-Anspruch und steht nicht in `make gates`. Kein Finding.
3. **Drei CI-Versuche** — register-würdig, kein blockierendes Finding: Die Vorlauf-Tode der Versuche 1/2 sind lokale Flakes unter Last (Verdikt unverändert bei `MUTATE_JOBS=1`, belegt am Commit `625cdef0`), das Docker-Image-Namen-Rennen ist als Register-Kandidat an §9.7 benannt; die Schreib-Hälfte des Registers trägt die Slice-Closure. Die übrigen Kandidaten (Gitlink-Sonde, chronische Handbuch-Prosa) stehen in F-4/F-5; keiner davon ist ein Defekt dieses Diffs.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Aufteilung der Gegenmessung-Basis fehlt hinter einer Gesamtzahl · Prüfvorbedingung der Gegenmessung ohne Kommando benannt · Berührung des Diffs ohne Plan-Tabelle-Zeile · pin-datierte Handbuch-Prosa hinter dem Pin-Stand · benanntes Werkzeug-Delta ohne Messstufe · Ergebnis-Commit ohne Re-Run-Weg

## Verdikt

**Merge-blockierend:** nein — beide MEDIUM-Findings betreffen die *Beleg-Form* der
Gegenmessung (F-1/F-2), nicht ihre Aussage: die byte-gleich-Mengen stehen, die
Stufen-Fassung und die Grenze der `vcs`-Sonde sind benannt. Sie sind vor der
Closure zu lösen (Nachtrag der Aufteilung und der Symlink-Kontrolle an §9.2 bzw.
als Konsum-Träger im Verifikations-Lauf), nicht vor dem weiteren Rollenwechsel —
die Rollen-Sequenz Implementation → Review → Verifikation ist hier nicht
unterbrochen: die Verifikation liest DoD/Spec, nicht diesen Report.

**Übergabe:** Findings gehen an den Implementer; die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report
selbst ist ein **Lauf-Beleg** — er ersetzt keine Verifikation (DoD/Spec-Konformität
prüft der Verifier separat, `v6.18.1` · `regelwerk/modul-11-verification.md`).

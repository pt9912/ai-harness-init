# Review: Dogfood-Hook und commits.id-patterns erkennen den benannten Slice

Reviewer-Lauf, Commits `edab4f6e`, `6963627a`, `ba960cb0`, gegen
`slice-kennungs-erkennung-traegt-die-zugelassenen-formen` (§1–§4 samt Übergabe), MR-057/MR-059, MR-071,
ADR-0053 und AGENTS.md §3.5/§3.6/§3.7. Die Fundliste des Implementers (DoD 1) liegt im Vorgang, nicht im Diff.

## Findings

1. **LOW** · Quelle: AGENTS.md §3.6/§3.7 · `test/mutations/523-dogfood-hook-ohne-benannten-slice.sh:7-9` ·
   Der Fall-Kopf sagt, die Kopplungs-Fälle sähen die Mutation nicht, „nur der Fall des benannten Slice" binde die Verwendung. Gegenprobe
   (Kopie, Mutation 523 angewandt, ausschließlich `traeger: ein benannter Slice (MR-057-Form)…` per `skip`): rot bleiben
   `commit-msg-hook.bats` 10, 15 und `commit-msg-emission.bats` 16 (`beide Fassungen urteilen gleich`, Paar `0 1`). Die Exklusivitäts-Behauptung
   ist falsch; der Fall bleibt rot. verifizierbar: ja · klasse: „Fall-Kopf behauptet Exklusivität, Gegenprobe widerlegt".
2. **LOW** · Quelle: AGENTS.md §3.6 (Doku-Zusage) · `harness/README.md:115` · die Zeile sagt, Commits mit benannter Kennung
   (Werkzeug-Messages) „brechen am Träger"; der Dogfood-Hook nimmt sie jetzt an (`slice-mv: Verweise auf slice-…` → Exit 0, gefahren).
   Ebenso nennt `harness/sensors/commit-msg-check.md:11` vier `id-patterns`, die Config führt fünf. Plan §3 führt beide Stellen als „nur falls";
   die Lesung trifft sie. verifizierbar: ja · klasse: „Prosa nennt überholte Erkennungs-Menge".
3. **INFO** · Quelle: AGENTS.md §3.5 · `.d-check.yml:511` · Bewertung der Gate-Frage: die Schwelle (Anwesenheit einer Kennung der
   Menge aus MR-057/059) bleibt; die Menge folgt der Deklaration, vorher wies `commits` zugelassene Kennungen ab. Real nimmt das Gate aber mehr
   Betreffe an: ohne Kennung vorher 996, nachher 363 (Bestand mit heutigem HEAD); davon ist ein großer Teil `slice-mv:`, der schon über das
   Werkzeugwort `slice-mv` trifft (`slice-mv:` allein: Exit 0, gefahren), 113 dieser Betreffe tragen daneben keinen Namen. Das ist
   Trennschärfe, nicht Schwelle; ein ADR-Hinweis besteht nicht (`doc-commits` ist nicht in `make gates`, `commit-msg-check` kein Gate), das
   akzeptierte Negativ ist für `a slice-wise fix` benannt, für `slice-mv` weder im Hook-Kopf noch im Plan §1/§6 — im Vorgänger-Review benannt.
4. **INFO** · Quelle: Plan §4 Übergabe · `test/commit-msg-emission.bats` (neue Fälle) · Zerreißen von `(^|…)` ist durch die eigene Zeile
   `named_slice=` geschlossen (Zeilen-Gleichheit, genau eine je Datei, Exit-Paar-Fall). Offen und nicht benannt: eine dritte Zusatzvariable
   neben `patterns=`/`named_slice=` sieht weder `hook_patterns()` noch die Gleichheit; nur ein Exit-Paar über die sechs fixen Messages würde
   sie fangen, wenn sie dort träfe.

## Geprüft, ohne Befund

- (a) `diff` der `named_slice=`-Zeile Dogfood vs. `internal/emit/templates/enforce/commit-msg-traceability.sh`: gleich; Annahme/Abweisung gefahren: `slice-foo`/`slice-174` angenommen, `noslice-foo` abgewiesen; Hook-Kopf beschreibt, was da ist.
- (b) RE2 gegen den gepinnten d-check über `make commit-msg-check`: Betreff mit benanntem Slice, `slice-174`, `a slice-wise fix` angenommen; `noslice-foo`, kennungsfrei abgewiesen; Hook und Gate urteilen gleich.
- (c) Gleichheit und Verhalten beider Zeilen: Mutation 520/521/522 rot gesehen; Fall 11 bindet die Grenzzeichen.
- (d) `make mutate` mit `316 317 342 520 521 522 523 524` ausgeschrieben, `MUTATE_FORCE=1`: `8 ok, 0 Befund(e)`, Baum danach sauber. Gegenprobe 524 (nur `kopplung: …dieselbe Muster-Menge` per `skip`): grün, der Test bindet allein. 523: siehe Finding 1. MR-071: die `sed`-Anker greifen am Quellbestand (Fälle werden rot, Selbst-Befund ausgeblieben).
- (e) Fundliste: `git grep -nE 'slice-\[0-9\]|slice-\\d'` über harness/, test (ohne mutations), `.d-check.yml`, Makefile, `d-check.mk`, `.githooks`, `.claude/hooks`, internal: keine weitere Erkennung des Dogfood-Pfads; Treffer nur `patterns=`, `id-patterns`, Prosa und Go-Tests der emittierten Ebene (Setzung 4 ausgenommen).

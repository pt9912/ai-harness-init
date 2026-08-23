# ADR-0022 (Proposed) — Schlussrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-23. **Lauf:** Haupt-Kontext dieser Session
(kein frischer Subagent), **vierte** Runde zu dieser ADR. Der schreibende Nachzug (`9305c13`)
stammt ebenfalls aus dem Haupt-Kontext, nicht von einem frischen Architect-Subagenten — dieselbe
Skepsis wie in der Vorrunde ist angebracht und wurde angewandt: keine der beiden Behebungen wird
aus der Commit-Message übernommen, beide sind an ihrem Gegenstand selbst nachgeprüft.

**Review-Art:** Bestätigungsrunde — kein Voll-Review. Die Runden 1–3 haben den Text vollständig
abgedeckt; was dort als Negativbefund geschlossen wurde, wird hier nicht neu aufgerollt. Geprüft
wird, ob die zwei offenen Findings der dritten Runde tragen, plus die stehenden Prüfungen.

**Gegenstand:** `5cf29c6..9305c13` — ein Commit, eine Datei:
`docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md` (+16/−5, jetzt 737
Zeilen). Selbst gemessen: `git diff --numstat 5cf29c6..9305c13` → genau diese Zahlen.
`git status --porcelain` → leer. `git rev-parse HEAD` → `9305c13ff42a2d71185fcf138e6fb5c6f9cf4891`.
Status im Kopf weiterhin `Proposed`.

**Vorrunden:** [`…-proposed-review.md`](2026-08-23-adr-0022-proposed-review.md) (1 HIGH/2
MEDIUM/5 LOW/4 INFO, blockiert), [`…-bestaetigungsrunde.md`](2026-08-23-adr-0022-bestaetigungsrunde.md)
(0 HIGH/2 MEDIUM/5 LOW/3 INFO, blockiert), [`…-bestaetigungsrunde-runde-2.md`](2026-08-23-adr-0022-bestaetigungsrunde-runde-2.md)
(0 HIGH/1 MEDIUM/0 LOW/1 INFO, blockiert — dies ist die dritte Runde, deren zwei Findings hier
geprüft werden; Datei-Name und Commit-Bezeichnung *„dritte Runde"* weichen ab, Gegenstand ist
derselbe).

## Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug)

1. **Diff/Commit-Range:** `5cf29c6..9305c13`, ein Commit, eine Datei (oben gemessen).
2. **Betroffene Anforderungen:** [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
   (Rang 1), `LH-QA-01`, `LH-QA-02`.
3. **Referenzierte aktive ADRs:** `ADR-0020`, `ADR-0021` — beide *Accepted*, beide byte-identisch
   zum Vorzustand geprüft.
4. **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4 (Immutabilität), §3.6 (keine Zusage ohne rot
   gesehenes Gegenbeispiel / gelistet heißt bewacht), §3.7, §3.8 (Architect-Commit);
   [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
5. **Vorherige Findings am gleichen Modul:** MEDIUM-1 und INFO-1 der dritten Runde, einzeln an
   ihrem Gegenstand nachgeprüft — nicht an der Ankündigung im Commit-Text.
6. **Plan-Bezug:** keiner — der Gegenstand ist eine Entscheidung, kein Slice.

## Selbst gefahren — Kommando und Ergebnis

| Kommando | Ergebnis |
|---|---|
| `git diff --numstat 5cf29c6..9305c13` | `16  5  docs/plan/adr/0022-…md` — genau eine Datei |
| `git diff --stat 5cf29c6..9305c13 -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` | leer, Exit 0 — §3.4 hält |
| `git diff --name-status 5cf29c6..9305c13` | `M` auf genau eine Datei unter `docs/plan/adr/**` — §3.8 |
| `grep -c 'failure_form' docs/plan/adr/0022-*.md` | **1** — deckt sich mit der Kontroll-Zahl der Commit-Message |
| `grep -c '\| \`make full-smoke\` \|$' docs/plan/adr/0022-*.md` | **2** — deckt sich mit der Kontroll-Zahl der Commit-Message |
| `grep -n '\| \`make full-smoke\` \|$'` | Zeilen `677` und `682` — genau die beiden Fitness-Zeilen, deren Make-Target-Spalte ausschließlich `make full-smoke` trägt |
| Alle acht Fitness-Zeilen einzeln nach Make-Target-Spalte gelesen | die übrigen sechs tragen `make test`, `make test`+`make mutate`, oder `—`; **keine** mischt `full-smoke` mit `test`/`mutate` |
| `grep -n 'Was hier und dort zusammenhängt'` | leer, Exit 1 — die gestrichene Berufungs-Formel ist wirklich weg, nicht nur umformuliert |
| `sed -n '227,236p' harness/tools/mutate.sh` | `failure_form()` kennt `test`, `test-go`, `test-bats`, `smoke`, `ci-lint`; `*) return 1` sonst |
| `sed -n 's/^# verify: //p' test/mutations/*.sh \| sort \| uniq -c` | je einmal `ci-lint` und `smoke` — deckt sich mit dem Bestand, den die ADR nennt |
| `grep -niE 'slice-[0-9]\|welle-[0-9]'` über die Datei | ein Treffer, ein Dateipfad innerhalb eines Kommandos (Folgepflicht 5), keine normative Slice-Adresse |
| `grep -niE 'runde\|HIGH-[0-9]\|MEDIUM-[0-9]\|LOW-[0-9]\|INFO-[0-9]\|hier stand'` | leer, Exit 1 — keine Review-Geschichte im Text |
| `grep -nE '^\*\*[0-9]\.'` | acht Treffer, 1–8, ohne Nummern-Lücke |
| `make docs-check` | `d-check: 354 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `make gates` | Exit 0; `grep -c '^ok '` → **143**, `grep -c '^not ok '` → **0**; `comment-claims: 40 Datei(en) geprüft, 0 Befund(e)`; letzte Zeile `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert` |

---

## Status der zwei offenen Findings der dritten Runde

### MEDIUM-1 — Sensor-Lücke nur an einer von zwei `full-smoke`-Zeilen benannt

**Behoben, und zwar an der Wurzel — Eigenschaft statt Adresse.**

- **(i) Deckt der Vorspann beide Zeilen, korrekt abgegrenzt?** Ja. Der neue Vorspann
  (`:664-673`, direkt unter der Überschrift `## Fitness Function`, vor der Tabelle) formuliert die
  Grenze als Eigenschaft *„jeder Zeile unten, deren Target ausschließlich `make full-smoke` ist"*.
  Selbst nachgezählt: von acht Fitness-Zeilen tragen genau zwei (`:677` *„Der Träger schreibt im
  Ziel"* und `:682` *„Die Auswertung meldet ihre Leere"*) ausschließlich `make full-smoke` in der
  Make-Target-Spalte; die übrigen sechs hängen an `make test` und/oder `make mutate` (fünf
  Zeilen) oder haben kein Target (die letzte, nicht maschinell prüfbare Zeile). Der Ausschluss-Satz
  *„Zeilen, die an `make test` · `make mutate` hängen, sind davon nicht berührt"* trifft exakt zu:
  `failure_form` in `mutate.sh` kennt `test` (und `test-go`/`test-bats`) als Fehlschlag-Muster,
  jene fünf Zeilen sind über `make mutate` also grundsätzlich adressierbar, im Unterschied zu den
  zwei `full-smoke`-Zeilen.
- **(ii) Genau ein Ort, oder Dublette?** Genau ein Ort. `grep -c 'failure_form'` → **1** — die
  komplette Bestands-Beschreibung (welche Verify-Strings `failure_form` kennt, der Fund `je einmal
  ci-lint und smoke`, der Hinweis, dass die Lücke für `make smoke` schon einmal geschlossen wurde)
  steht ausschließlich im Vorspann. Zeile `:682` (Trägerin von `ADR-0021` Folgepflicht 6) enthält
  diese Details nicht mehr, sondern nur noch den Verweis *„und für dieses Target gilt die Grenze
  über der Tabelle"*. Ein Vorher/Nachher-Vergleich der Zeile bestätigt: **ausschließlich** der
  failure_form-Absatz wurde entfernt, jeder andere Satz der Zeile (Testbeschreibung, Rot-Kriterium,
  `ADR-0021`-Bezug, die Asymmetrie-Begründung, *„Geschuldet, nicht geliefert"*) blieb unverändert
  stehen. Zeile `:677` (die andere `full-smoke`-Zeile) ist vom Diff gar nicht berührt und trug die
  Details vorher auch nicht — sie war nie der adressierte Ort, sondern der bislang stumme.
- **(iii) `failure_form`-Beschreibung weiterhin am Code belegt?** Ja, selbst gegen
  `harness/tools/mutate.sh:227-236` geprüft: die Case-Verzweigung kennt `test`, `test-go`,
  `test-bats`, `smoke`, `ci-lint` und fällt sonst auf `*) return 1`, was der Aufrufer (Zeile 269 f.)
  in *„unbekanntes '# verify: …' — kein Fehlschlag-Muster definiert"* übersetzt — Wortlaut und
  Verhalten decken sich mit dem, was der Vorspann jetzt behauptet. Der Bestand `sed -n 's/^#
  verify: //p' test/mutations/*.sh | sort | uniq -c` → je einmal `ci-lint` und `smoke`, exakt wie
  im Text.
- **(iv) Verliert die Zusagen-Zeile etwas?** Nein. Der einzige entfernte Textblock ist die
  failure_form-Detailbeschreibung, die jetzt eine Ebene höher steht und über den neuen Satz *„und
  für dieses Target gilt die Grenze über der Tabelle"* an ihrem alten Ort weiterhin erreichbar
  ist. Die Zeile behält ihr eigenes Test-Rezept (*„Rot zu sehen ist: den Grund-Satz aus der Ausgabe
  nehmen…"*), ihre `ADR-0021`-Folgepflicht-6-Bindung, ihre `Geschuldet, nicht geliefert`-Markierung
  und die Asymmetrie-Erklärung zur Nachbar-Zeile — letztere sogar präzisiert: *„die Grenze zwei
  Orte hat"* → *„die Grenze aus [ADR-0021] Folgepflicht 6 zwei Orte hat"*, eine engere, nicht
  vagere Referenz.

Damit ist exakt die Fehlerklasse behoben, die die dritte Runde benannt hatte (*„Adresse statt
Eigenschaft"*) — und zwar nach demselben Muster, das dieser Nachzug bereits für Folgepflicht 5 und
Folgepflicht 7 gefahren hatte, jetzt konsequent auch auf das eigene MEDIUM-2/MEDIUM-1 angewandt.

### INFO-1 — Kopplungs-Berufung auf `ADR-0020` Folgepflicht 1

**Die Streichung trägt — keine neue Lücke.**

Die beanstandete Berufung (*„Was hier und dort zusammenhängt, hält [ADR-0020] Folgepflicht 1"*)
ist ersatzlos gestrichen (`grep -n 'Was hier und dort zusammenhängt'` → leer, Exit 1), nicht durch
eine andere Berufung ersetzt. An ihre Stelle tritt: *„Gemeinsam ist beiden Ebenen allein die
Mechanik, aus der die Zähler kommen müssten; mehr braucht die Aussage nicht, und mehr behauptet
sie nicht."* Das ist keine unbelegte neue Behauptung, sondern die Wiederaufnahme eines Satzes, der
im selben Absatz zwei Sätze zuvor bereits steht: *„Das Agenten-Werkzeug ist auf der emittierten
Ebene dasselbe"* (`:519-520`). Die Schlussfolgerung (*„Diese Entscheidung sagt darum über einen
Adopter nichts zu, was jene nicht schon über die Mechanik gesagt hat"*) stützt sich damit auf eine
Prämisse, die der Absatz selbst schon etabliert hat, statt auf eine Analogie zu einer fremden
Regel, die — wie die dritte Runde zu Recht festhielt — wörtlich einen anderen Gegenstand (einen
**Beleg**, kein Aussage-Verhältnis zweier ADRs) bindet. Die Streichung schließt damit die
beanstandete Lücke, statt eine neue zu öffnen: die vorher schiefe Stütze ist weg, die tragende
Prämisse steht jetzt im Absatz selbst statt in einem zitierten Fremd-Satz.

Zur Vollständigkeit: die exakte Wortfolge *„der Beleg emittiert nichts, was der Dogfood nicht
selbst fährt"* (das Zitat aus `ADR-0020` Folgepflicht 1) kommt an zwei anderen Stellen der Datei
weiterhin vor (`:105`, `:605`) — beide für einen eigenständigen, in den Vorrunden nicht
beanstandeten Zweck (Folgepflicht 1 dieser ADR selbst, *„der Dogfood zieht den Einstiegspunkt
nach"*). Das ist nicht die gestrichene Stelle und keine Dublette der gestrichenen Aussage.

---

## Negativbefunde (geprüft, ohne Befund)

- **§3.4 — `ADR-0020` und `ADR-0021` byte-identisch zum Vorzustand.** `git diff --stat
  5cf29c6..9305c13 -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer, selbst gefahren.
- **§3.8 — nur ein Architect-Artefakt.** `git diff --name-status 5cf29c6..9305c13` → `M` auf genau
  eine Datei unter `docs/plan/adr/**`; Commit-Message beginnt mit *„Rolle Architect:"*.
- **Keine Slice-/Wellen-IDs als normativer Anker.** Ein Treffer, ein Dateipfad innerhalb eines
  Kommandos in Folgepflicht 5 (Verweis auf das nachzuziehende Plan-Artefakt), keine Slice-ID als
  Entscheidungs-Anker.
- **`MR-025` — beide Kontroll-Zahlen der Commit-Message nachgefahren.** `grep -c 'failure_form'` →
  1, `grep -c '| \`make full-smoke\` |$'` → 2 — beide exakt wie behauptet, beide selbst gefahren,
  nicht aus der Commit-Message übernommen. Die Zahlen im neuen Vorspann-Text selbst (*„je einmal
  `ci-lint` und `smoke`"*) tragen ihr Kommando im selben Satz.
- **Verbatim-Gegenprobe auf die umgezogene/neu eingesetzte Formulierung.** Die Beschreibung von
  `failure_form` im Vorspann gegen `harness/tools/mutate.sh:227-236` und den Bestand in
  `test/mutations/*.sh` als Here-String-Grep geprüft (`grep -qF <<<`, kein `printf | grep -q`) —
  Fund und Text stimmen überein.
- **Keine Review-Geschichte im ADR-Text (§3.7).** `grep -niE 'runde|HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]|INFO-[0-9]|hier stand'`
  → leer, Exit 1.
- **Festlegungen 1–8 vollständig, keine Nummern-Lücke.** `grep -nE '^\*\*[0-9]\.'` → acht Treffer.
- **`make gates` und `make docs-check` — selbst gefahren, beide bestätigt, nichts aus der
  Commit-Message übernommen.** `make docs-check` → `354 Datei(en) geprüft, 0 Befund(e)`, Exit 0.
  `make gates` → Exit 0, `grep -c '^ok '` → 143, `grep -c '^not ok '` → 0, `comment-claims: 40/0`,
  letzte Zeile `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert`.
- **Kein neuer Befund außerhalb der zwei geprüften Punkte.** Diese Runde ist eine gezielte
  Bestätigungsrunde, keine Voll-Prüfung; im geprüften Umfang (Vorspann, die zwei betroffenen
  Fitness-Zeilen, die geänderte Festlegung-8-Passage, die Standard-Prüfungen) ist nichts Weiteres
  aufgefallen.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 0 |

Verlauf: HIGH 1 → 0 → 0 → **0**; MEDIUM 2 → 2 → 1 → **0**; LOW 5 → 5 → 0 → **0**; INFO 4 → 3 → 1 →
**0**. Die blockierende Menge ist leer, und beide Findings der Vorrunde sind an ihrem Gegenstand
geschlossen, nicht nur umformuliert.

## Verdikt

**Frei für die Annahme.** Aus meiner Sicht steht der Übernahme in den Status *Accepted* nichts
mehr entgegen — der Architect kann den Statuswechsel setzen.

Beide offenen Findings der dritten Runde sind an der Wurzel behoben: MEDIUM-1, weil die
Mutations-Sensor-Lücke jetzt als Eigenschaft des Ziels `make full-smoke` über der gesamten
Fitness-Tabelle steht statt an einer von zwei betroffenen Zeilen, mit exakt den Kontroll-Zahlen,
die die Commit-Message nennt (`failure_form` einmal, zwei `full-smoke`-exklusive Zeilen, beide
jetzt gedeckt) — und ohne dass die adressierte Zeile dabei etwas verliert, das sie tragen musste.
INFO-1, weil die schiefe Berufung auf `ADR-0020` Folgepflicht 1 ersatzlos gestrichen ist und die
verbleibende Aussage sich auf eine im selben Absatz bereits etablierte Prämisse stützt, statt eine
neue, unbelegte Lücke zu hinterlassen. `ADR-0020` und `ADR-0021` sind byte-identisch zum
Vorzustand, der Commit trägt ausschließlich ein Architect-Artefakt, keine Slice-/Wellen-ID dient
als normativer Anker, und `make gates`/`make docs-check` sind selbst gefahren und grün.

**Übergabe:** Der Statuswechsel gehört dem Architect (ADR und Index sind Architect-Artefakte,
§3.8). Dieser Report ersetzt keine Verifikation — DoD-Abhakung und Gate-Lauf-Bestätigung für einen
etwaigen Umsetzungs-Slice bleiben Sache des Verifiers (Modul 11, getrennter Kontext).

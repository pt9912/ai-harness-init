# ADR-0022 (Proposed) — Schlussrunde zur Erweiterungsrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-23. **Lauf:** frischer Subagent, eigener
Kontext.

**Anlass.** Die Bestätigungsrunde zur Erweiterungsrunde
(`2026-08-23-adr-0022-erweiterungsrunde-bestaetigung.md`, Diff `4302b5b..eaf5d0f`) fand 0 HIGH ·
1 MEDIUM (MEDIUM-A) · 0 LOW · 0 INFO, Verdikt *blockiert*. MEDIUM-A: drei von vier Fundorten der
überzeichneten H-Aussage waren korrigiert, ein vierter (Zeile 341, byte-identisch seit `4302b5b`)
widersprach der Korrektur direkt. Diese Runde prüft **ausschließlich**, ob MEDIUM-A behoben ist,
plus die stehenden Prüfungen — kein Voll-Review, die vorigen Runden werden nicht neu aufgerollt.
Der schreibende Kontext war wieder der Haupt-Kontext, nicht ein frischer Architect-Subagent.

**Gegenstand:** `28d80e1..3e713db`, ein Commit:

- `3e713db` — Nachzug MEDIUM-A (`docs/plan/adr/0022-…md`, +2/−1, selbst gemessen:
  `git diff --stat 28d80e1..3e713db` → genau diese Zahlen, genau diese eine Datei).

`git diff --name-status 28d80e1..3e713db` → `M` auf genau `docs/plan/adr/0022-…md`.
`git status --porcelain` → leer. Status im ADR-Kopf weiter *Proposed*. Commit-Message beginnt mit
*„Rolle Architect:"* (§3.8).

## Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug)

1. **Diff/Commit-Range:** `28d80e1..3e713db`, ein Commit, eine Datei (oben gemessen).
2. **Betroffene Anforderungen:** `LH-FA-10` (Rang 1), `LH-FA-01`, `LH-QA-01`, `LH-QA-02`,
   `LH-QA-03`, `LH-QA-04` — unverändert.
3. **Referenzierte aktive ADRs:** `ADR-0003`, `ADR-0007`, `ADR-0011`, `ADR-0016`, `ADR-0020`,
   `ADR-0021` — alle *Accepted*; `ADR-0020`/`ADR-0021` byte-identisch geprüft
   (`git diff --stat 28d80e1..3e713db -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer,
   Exit 0).
4. **Hard Rules:** `AGENTS.md` §3.4 (Immutabilität), §3.6 (kein Halluzinat), §3.7 (keine
   Review-Geschichte im Artefakt, Ersatz statt Nebeneinanderstellung), §3.8
   (Architect-Commit); `MR-025`.
5. **Vorherige Findings am gleichen Modul:** MEDIUM-A der Bestätigungsrunde ist der unmittelbare
   Auftrag; alle Findings der Runden davor (Voll-Review, Erweiterungsrunde) sind bereits
   geschlossen und werden nicht neu aufgerollt.
6. **Plan-Bezug:** keiner — Entscheidung, kein Slice.

## Selbst gefahren — Kommando und Ergebnis

| Kommando | Ergebnis |
|---|---|
| `git diff 28d80e1..3e713db -- docs/plan/adr/0022-…md` | genau der MEDIUM-A-Satz ersetzt: „…ist Alternative H — beantwortet ist sie damit nicht, wie der nächste Absatz zeigt." ersetzt „…ist Alternative H." — Ersatz an Ort und Stelle, kein Neben-Rest (§3.7) |
| `grep -niE 'stellbar\|beantwort\|erledigt\|löst.{0,20}annahme\|entkoppelt\|hebt.{0,15}auf\|braucht.{0,20}annahme\|annahme.{0,20}auf' docs/plan/adr/0022-…md` | **sechs** in-Dokument-Fundorte der Kernaussage (Zeilen 206, 341, 352, 368, 610, 768) — nicht fünf, siehe LOW-A |
| Gegenlesen der sechs Fundorte + der Index-Zeile in `docs/plan/adr/README.md` | alle sieben sagen dasselbe: H macht die Plattform-Frage **stellbar**, **nicht** beantwortet/gelöst — kein Widerspruch in der Menge |
| `grep -n "weil er sie stellbar macht" docs/plan/adr/0022-…md docs/plan/adr/README.md` | **ein** Treffer (Zeile 768) — Zeile 368 trägt dieselbe Aussage, aber mit `**stellbar**` (Markdown-Fettung um das Wort), daher **kein** Treffer auf die wörtliche Suchphrase; mechanischer Beleg, warum eine zitat-basierte Zählung diese Stelle verfehlt |
| Zeile 341–342 gegen den Folgeabsatz (344–352) gelesen | Vorwärtsverweis „wie der nächste Absatz zeigt" trägt: der Absatz „Warum G und nicht H — und was H wirklich löst" führt genau die Unterscheidung stellbar/beantwortet aus und schließt mit „sie wird damit **stellbar**, nicht beantwortet." |
| `git diff --stat 28d80e1..3e713db -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` | leer, Exit 0 — §3.4 hält |
| `git diff --name-status 28d80e1..3e713db` | `M` auf genau einer Datei, ADR-Stratum — §3.8 |
| `grep -niE 'runde\|HIGH-[0-9]\|MEDIUM-[0-9]\|LOW-[0-9]\|INFO-[0-9]\|hier stand\|erweiterungsrunde\|bestätigungsrunde\|schlussrunde' docs/plan/adr/0022-…md` | leer — kein Review-Geschichte-Leck (§3.7) |
| `grep -niE 'slice-[0-9]\|welle-[0-9]' docs/plan/adr/0022-…md docs/plan/adr/README.md` | ein Treffer, Dateipfad innerhalb eines Kommandos, unverändert seit der Erweiterungsrunde — keine neue Slice-/Wellen-ID als normativer Anker |
| `grep -n "\.harness/baseline" / "Zeile [0-9]\+ " docs/plan/adr/0022-…md` (ADR-0016 Festlegung 3(a)/2) | leer — keine lokalen `<tag>`-Pfade, kein bloßer Zeilennummer-Locator; die zwei Baseline-Belege (`v5.11.0`/`modul-15-observability.md` §…, verbatim zitiert) tragen bereits Tag + Datei/Abschnitt + Zitat |
| `make docs-check` | `d-check: 357 Datei(en) geprüft, 0 Befund(e)` — deckt die Commit-Message |
| `make gates` | Exit 0; `grep -c '^ok '` → **143**; `grep -c '^not ok '` → **0**; `comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`; `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert` — deckt die Commit-Message vollständig |

---

## Findings

### LOW-A — die „fünf Fundorte"-Zählung im Commit ist eine Untererfassung; die Menge bleibt trotzdem konsistent

**Quelle:** dieselbe Mengen-Frage wie MEDIUM-A der Vorrunde, jetzt gegen die Korrektur selbst
gehalten.

**Pfad:** Commit-Message `3e713db` (Behauptung „alle fünf Fundorte … und die Index-Zeile") gegen
`docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:368`.

**Befund:** Die Commit-Message zählt fünf in-Dokument-Fundorte (Abzählungs-Zeile :206,
Alternativen-Zeile :610, Trigger :768, „zwei Absätze" :341/:352) plus die Index-Zeile. Eine
eigene, wortformen-übergreifende Suche (`stellbar`, `beantwort`, `erledigt`, `löst…Annahme`,
`entkoppelt`, `hebt…auf`, `braucht…Annahme`) findet einen **sechsten** in-Dokument-Fundort bei
Zeile 368: *„Tritt einer auf, ist H der nächstliegende Ausgang — nicht weil er die Frage
erledigt, sondern weil er sie **stellbar** macht…"* — Teil des Absatzes „Die Wahl fällt auf G,
solange die Annahme hält", getrennt von den Absätzen :341/:352 durch einen dazwischenliegenden,
themenfremden Absatz über die Mechanik (:354–364). Diese Stelle trägt bereits die korrekte
Fassung (kein Widerspruch), wurde aber offenbar schon im vorletzten Nachzug (`d1f7c36`)
mitkorrigiert, ohne in der Fundort-Liste dieser oder der vorigen Runde aufzutauchen. Der
naheliegende, mechanische Grund: eine wörtliche Suche nach dem in der Commit-Message zitierten
Trigger-Satz *„weil er sie stellbar macht"* trifft **nur** Zeile 768 — Zeile 368 trägt dieselbe
Aussage mit Markdown-Fettung um das Wort (`**stellbar**`), was eine zitat-basierte Suche
mechanisch verfehlt. Die substanzielle Prüfung (tragen alle Fundorte dieselbe Aussage?) fällt
positiv aus — die quantitative Prüfung („alle fünf") ist gemessen ungenau, weil die
Verifikationsmethode wieder über benannte Zitate statt über eine formunabhängige Volltextsuche
lief, exakt das Muster, das MEDIUM-A der Vorrunde ausgelöst hatte.

**Verifizierbar:** ja — `grep -niE 'stellbar|beantwort|erledigt|löst.{0,20}annahme|entkoppelt'
docs/plan/adr/0022-…md` liefert sechs Treffer der Kernaussage, nicht fünf.

**Bewertung/Einordnung:** kein Blocker. Anders als MEDIUM-A der Vorrunde steht hier **kein**
Widerspruch im Dokument selbst — der ungezählte sechste Fundort sagt dasselbe wie die anderen.
Die Ungenauigkeit steckt ausschließlich in der Commit-Message (einem historischen, nicht
lebenden Artefakt, das nicht Teil des ADR-Inhalts ist, der bei Annahme einfriert), nicht im
ADR-Text selbst. Als LOW eingeordnet statt MEDIUM, weil kein Failure-Szenario im Dokument
existiert — der Wartungsfall ist die *Methode* (zitat-basierte statt formunabhängige Suche),
nicht ein aktueller Fehler.

---

## Bestätigte Behebung (der eine Punkt des Auftrags)

- **MEDIUM-A — behoben.** Zeile 341–342 lautet jetzt: *„…ist Alternative H — beantwortet ist sie
  damit nicht, wie der nächste Absatz zeigt."* Der Widerspruch zur drei Zeilen tiefer stehenden
  Aussage („stellbar, nicht beantwortet") ist aufgelöst — beide Stellen sagen jetzt dasselbe. Der
  Vorwärtsverweis auf „der nächste Absatz" trägt: der Absatz „Warum G und nicht H — und was H
  wirklich löst" (:344–352) führt exakt diese Unterscheidung aus. Die eigene Sechser-Menge (statt
  der beanspruchten Fünfer-Menge) ist vollständig konsistent — kein weiterer Widerspruch, an
  keiner der sechs Textstellen und nicht in der Index-Zeile.

---

## Negativbefunde (geprüft, ohne Befund)

- **Menge vollständig und konsistent geprüft.** Formen-übergreifende Suche über das ganze
  Dokument (nicht nur die in der Commit-Message benannten Orte) findet sechs in-Dokument-Stellen
  plus die Index-Zeile; alle sieben tragen dieselbe Fassung. Kein siebter/achter Fundort mit
  abweichender Aussage gefunden (auch `klärt`, `beseitigt`, `räumt…ab`, `invalidiert`,
  `schafft…ab` geprüft — keine weiteren Treffer zur Annahme-(a)/H-Aussage).
- **§3.7 — Ersatz statt Nebeneinanderstellung.** `git diff 28d80e1..3e713db` zeigt eine reine
  Satz-Ersetzung an Ort und Stelle; kein alter Wortlaut bleibt als Rest liegen.
- **§3.7 — keine Review-Geschichte im Artefakt.** `grep -niE
  'runde|HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]|INFO-[0-9]|hier stand|erweiterungsrunde|
  bestätigungsrunde|schlussrunde'` über die ADR-Datei → leer.
- **§3.4 — `ADR-0020`/`ADR-0021` byte-identisch.** `git diff --stat 28d80e1..3e713db --
  docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer.
- **§3.8 — nur Architect-Artefakte.** Ein Commit, `M` auf genau der ADR-Datei,
  Commit-Message-Präfix `Rolle Architect:`.
- **Keine Slice-/Wellen-IDs als normativer Anker** — unverändert (ein Dateipfad-Treffer innerhalb
  eines Kommandos).
- **`MR-025`.** Keine neu eingeführte nackte Zahl ohne begleitendes Kommando/Etikett im ADR-Text
  gefunden.
- **`ADR-0016` Festlegung 3(a)/Festlegung 2 — Form der Baseline-Belege.** Die zwei
  Baseline-Belege dieser ADR (`v5.11.0`, `modul-15-observability.md` §Span-/Audit-Attribut-Regeln
  bzw. §Token-Attributions-Regeln, jeweils verbatim zitiert) tragen bereits Tag +
  Regelwerks-Dateiname/Abschnittsname + Zitat verbatim — keinen lokalen
  `.harness/baseline/<tag>/`-Präfix, keinen bloßen Zeilennummer-Locator
  (`grep -n '\.harness/baseline' docs/plan/adr/0022-…md` → leer; `grep -nE 'Zeile [0-9]+'
  docs/plan/adr/0022-…md` → leer). Für den Accept-Übergang scheint hier nichts nachzuziehen —
  eine formale Bestätigung bleibt dem Architect/Auftraggeber überlassen, dies ist eine
  Beobachtung, keine DoD-Abhakung.
- **`make gates`/`make docs-check` — selbst gefahren, beide grün, nichts aus der Commit-Message
  übernommen.** `make docs-check` → 357/0. `make gates` → Exit 0, 143 `ok`, 0 `not ok`,
  `comment-claims: 40/0`, `span-check` grün — deckt exakt die Zahlen aus der Commit-Message.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

## Verdikt

**Frei für die Annahme.** MEDIUM-A der Bestätigungsrunde ist behoben: der vierte, zuvor
widersprüchliche Fundort trägt jetzt dieselbe Fassung wie die übrigen, und der Vorwärtsverweis
auf den Folgeabsatz trägt. Eine eigene, formen-übergreifende Nachmessung der Menge (nicht nur der
in der Commit-Message benannten Orte) findet zwar einen sechsten, dort nicht mitgezählten
Fundort (Zeile 368) — dieser sagt aber dasselbe wie die anderen fünf plus Index-Zeile, es bleibt
also **kein** Widerspruch im Dokument. Der Zähl-Ungenauigkeit ist als LOW-A protokolliert
(Methodik-Hinweis für künftige Menge-Prüfungen an dieser ADR: zitat-basierte Suche verfehlt
Stellen mit abweichender Markdown-Fettung), blockiert die Annahme aber nicht, weil sie sich
ausschließlich in der Commit-Message zeigt, nicht im ADR-Inhalt selbst. Alle stehenden Prüfungen
(nur ADR-0022 berührt, ADR-0020/0021 byte-identisch, nur Architect-Commit, keine Slice-/
Wellen-IDs, keine Review-Geschichte im Text, `make gates` und `make docs-check` selbst gefahren
und grün mit exakt den in der Commit-Message behaupteten Zahlen) sind frei.

Aus meiner Sicht steht der Annahme (Statuswechsel auf *Accepted*) nichts mehr entgegen — der
Architect kann den Status setzen. Für den Accept-Übergang selbst verlangt `ADR-0016` Festlegung
3(a), dass die Baseline-Belege in der Form aus Festlegung 2 stehen (Tag + Regelwerks-Dateiname/
Abschnittsname + Zitat verbatim, kein lokaler `.harness/baseline/<tag>/`-Pfad, keine bloße
Zeilennummer); die zwei Belege in dieser ADR (`v5.11.0`, `modul-15-observability.md` §…) tragen
diese Form bereits, gemessen mit `grep` gegen beide verbotenen Muster (leer in beiden Fällen) —
eine formale Bestätigung am Übergang selbst bleibt dennoch Sache des Architects, dies ist eine
Beobachtung, keine DoD-Abhakung. Dieser Report ersetzt keine Verifikation — DoD-Abhakung und
Gate-Lauf-Bestätigung bleiben Sache des Verifiers (Modul 11, getrennter Kontext).

# Review-Report: slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert — 2026-09-30

**Review-Art:** Code (Bericht-Artefakt) — geprüft gegen Plan, ADRs und Hard Rules; nicht gegen die DoD (Verifier).

**Gegenstand:** Commit `988b701b`, eine neue Datei: `docs/reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md` (447 Zeilen), Stand der Spec `ed4eedcf`.

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-sonnet-5-5 · **Datum:** 2026-09-30

**Eingangs-Kontext:**

- Slice-Plan `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert` (vollständig)
- ADR-0011, ADR-0013, ADR-0071 (`Proposed`), MR-021, MR-025
- `LH-FA-10`
- `AGENTS.md` §3.4, §3.6, §3.7, §3.8, §3.10, §3.11
- `v6.13.0` · `regelwerk/modul-10-review-harness.md`

Alle Zahlen unten sind selbst nachgefahren; nichts stammt aus dem Handoff.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Der Plan schreibt als Einheit den Absatz vor und den Listenpunkt nur für die zwei Listen über 6 KB (rund 34 Einheiten). Der Bericht schneidet auch die Erfassungs-Liste, die Abweichungen 1–6 und die neun Zusicherungen von `Bewacht` feiner und führt 64 Einheiten plus 10 zweite Zeilen (74 Zeilen). Der Schnitt steht in §1 des Berichts, aber nicht als Abweichung vom Plan. Er ist in einer Sitzung prüfbar (74 Zeilen, unter der Rückführungs-Grenze von rund 100). | Slice-Plan §3 (Einheit) und §1 (Wer später mitnimmt, hat den Plan geändert); `v6.13.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice | `docs/reviews/…-klassifikation.md:28-34` | nein — Urteil | Plan-Abweichung im Bericht nicht als solche benannt |
| F-2 | LOW | Die Zeile `T` (0 Bytes) trägt 16 Testnamen und 27 Fall-Nummern aus den Tabellenzeilen. 11 davon (alle `TestCommand*`) stehen nur in `SPEC-031` (gemessen: `comm` gegen die Zeilen 137–718 → 11). Diese Nennung ist ehrlich ausgewiesen (§2). Dass fünf weitere Testnamen (`TestAgentGetsNoArgumentFields`, `TestFailedAgentCallCapturesNothing`, `TestMandatoryFieldsAlwaysPresent`, `TestResolvedModelIsStructurallyBounded`, `TestSpawnedRoleIsNormalised`) in `T` **und** im Fließtext stehen und `T` damit die Namens-Differenz für ihre Fließtext-Nennung verdeckt, steht nicht dort. Gefahren: die Zeilen U56, U57, U58, U59, U61 gestrichen → die Testnamen-Differenz bleibt 0, nur die Byte-Summe (44407 statt 45889) fällt. | `AGENTS.md` §3.6 (Sensor über nachgebauter Menge); Slice-Plan §2 Liefer-Punkt 1 | `docs/reviews/…-klassifikation.md:81-84, 171` | ja — Bruchprobe s. u. | Vollständigkeits-Kommando durch Sammelzeile teilweise blind |
| F-3 | LOW | Der Plan verlangt für die Vollständigkeit die Bruchprobe („eine Zeile streichen — beide Kommandos zeigen den Fehlbetrag; der Vermerk steht im Review-Bericht"). Der Bericht des Implementers nennt die Kommandos, aber keine Bruchprobe und keinen Rot-Beleg. Die Zusage „maschinell gedeckt" (§7) ist damit im Bericht ungesehen. Der Reviewer hat sie nachgefahren (Abschnitt Bruchprobe unten). | `AGENTS.md` §3.6; Slice-Plan §2/§5 | `docs/reviews/…-klassifikation.md:81, 443` | ja | Zusage ohne rot gesehenes Gegenbeispiel |
| F-4 | INFO | Die Zählung „24 der 35 Zeilen mit gemessen/Datum stehen in Klasse c" ordnet nach der ersten Zeile der Einheit. Zwei der 35 Treffer sind das Wort `ungemessen` (Zeilen 195 und 655, keine Messung); Zeilen 325 und 330 („gemessen am 2026-08-08") stehen in U21 (Klasse a), ihre zweite Zeile U21b ist c. Die Aussage „trifft für 24 von 35 zu" ist damit eine Angabe nach Erst-Zeile; beides ist im Bericht nicht genannt. | Slice-Plan §6 Risiko 3 | `docs/reviews/…-klassifikation.md:56-69, 204-207` | ja — `grep -nE 'gemessen\|…'` mit Zeilen 195/655 | Zählregel nennt ihre Grenzen nicht |
| F-5 | INFO | Bei einzelnen Grenzfällen fehlt die Begründung des Partners. U35 („Was die Regel nicht ist: eine Messung", Zeilen 450–453) ist `b` mit Partner `d`; der Text sagt nichts über eine Abweichung, er grenzt die Regel ab (`b/a` läge näher). Die Übergabe an den Architect (§4 Punkt 8) nennt U35 ohne Partner-Begründung. | Slice-Plan §1 (Grenzfälle markieren) | `docs/reviews/…-klassifikation.md:138, 217` | nein — Urteil | Grenzfall-Partner ohne Begründung |

## Bruchprobe (vom Reviewer gefahren, Kopien im Scratchpad, Bericht unverändert)

Kommandos wörtlich aus §2 des Berichts (Byte-Summe gegen 45889; Testnamen- und Fall-Differenz):

| Änderung an der Kopie | Byte-Summe | fehlende Testnamen | fehlende Fall-Dateien |
|---|---|---|---|
| unverändert | 45889 | 0 | 0 |
| Zeile U10 gestrichen (kein Test, kein Fall) | 45243 | 0 | 0 |
| Zeile U52 gestrichen | 45292 | 3 | 1 |
| Zeile T gestrichen | 45889 | 11 | 0 |
| U56, U57, U58, U59, U61 gestrichen | 44407 | 0 | nicht gefahren |

Ergebnis: Die Byte-Summe trägt die Vollständigkeit; die Namens-Kommandos allein tragen sie nicht (Zeile U10, F-2). Rot ist jeweils an der Summe ablesbar. Kein Rot-Beleg für Kommando 2 und 3 allein bei Streichung von Zeilen, deren Namen `T` mitträgt.

## Nachgemessen (alles Handoff-unabhängig)

- Byte-Summe: `sed -n '137,718p' spec/spezifikation.md | wc -c` → 45889 = Summe der Spalte (45889).
- Je Einheit die Bytes gegen `sed -n '<a>,<b>p' spec/spezifikation.md | wc -c` gehalten: 0 Abweichungen bei 64 Einheiten; die Zeilenbereiche schließen lückenlos von 137 bis 718.
- Zeilenzahlen: 64 Einheiten + 10 zweite Zeilen = 74 (+ `T` = 75); Grenzfälle 20 Einheiten + 4 zweite Zeilen = 24 markierte Zeilen. Klassenverteilung (21/10/15/12/16 Zeilen; 10177/3293/13508/8245/10666 Bytes; Grenzfälle 6/5/11/1/1) stimmt mit §2 überein.
- 35 gemessen/Datum-Zeilen; Verteilung nach Erst-Zeile 4/4/24/0/3, wie berichtet.
- 24 Testnamen und 26 Fall-Dateien in der Spec; 26 Fall-Dateien stehen ohne `T` in den U-Zeilen; 13 Testnamen im Fließtext stehen alle in den U-Zeilen.
- Zeiger: 100 Stellen und 30 Dateien; Z-Tabelle hat 100 Zeilen; Verteilung 44+23+3+7+23 und 44+51+5 schließt auf 100. Stichprobe Z063, Z072, Z088, Z096 gegen die Fundstelle gelesen: Zuordnung plausibel (Z088 verweist auf die Lesevorschrift zu `spawned_role`, die in `SPEC-022` steht, also `T`).
- Randbefunde: `grep -c 'statt Implementation' spec/spezifikation.md` → 0; `grep -c 'CO-002'` → Spec 0, Guard-Skript 1; ADR-0028 Zeile 214 und ADR-0021 Zeilen 72 und 652 nennen die Erwartung wie berichtet.
- 10 `SPEC`-Zeilen ohne `LH` (001, 002, 003, 008, 014, 016, 019, 026, 027, 028) stimmen mit der Liste in §6.3 überein; Fundstellen in `LH-FA-10` (Zeilen 259–266, 287–298, 303–306, 315–316) gegen `spec/lastenheft.md` gelesen.
- Klassen-Stichprobe gegen den Spec-Text (18 Einheiten, alle fünf Klassen): U02, U04, U05, U08, U12, U16, U21/U21b, U25, U35, U38, U42, U53, U60, U62, U63, U64, U09, U30. Zuordnung und Grenzfall-Markierung nachvollziehbar; Abweichung nur bei U35 (F-5).
- Aufnahme-Regel (Zeilen 20–23) und „Die Nennung selbst ist unbewacht" (Zeilen 82–91) wie zitiert.
- `git diff --stat HEAD~1 -- spec internal test cmd` → leer: der Commit ändert nur die Berichtsdatei.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Vollständigkeit (Byte-Summe, Zeilenbereiche, Testnamen, Fall-Dateien) | geprüft, ohne Befund; Einschränkung F-2, F-3 |
| Träger-Zeile `T` (Konstruktion) | geprüft, ohne Befund zur Ehrlichkeit: als Träger mit 0 Bytes ausgewiesen, die 11 Nur-Tabellen-Namen genannt; Einschränkung F-2 |
| Einheiten-Schnitt | geprüft, Befund F-1 (LOW) |
| Klassen-Zuordnung (Stichprobe, 5 Klassen, mehrere Grenzfälle) | geprüft, ohne Befund außer F-5 |
| Zahlen-Behauptungen (35/24, 100, 10, ADR-Randbefunde) | geprüft, ohne Befund außer F-4 |
| `AGENTS.md` §3.7 | geprüft, ohne Befund: der Bericht ist ein Zeitdokument in `docs/reviews/**`, kein Zustandsfeld; keine Befund-IDs und keine Slice-Erzählung im Sinn der Regel |
| `AGENTS.md` §3.11 | geprüft, ohne Befund: Slice-Kennung ohne Lifecycle-Pfad, ADR-Links auf ortsfeste Ablage, Kennungen (`MR-021`, `MR-025`, `LH-FA-10`) als Anker-Links; der Pfad auf `docs/reviews/2026-08-02-span-schema-messreihen.md` betrifft ein Zeitdokument, das den Lifecycle verlassen hat |
| `AGENTS.md` §3.4 / §3.8 / §3.10 | geprüft, ohne Befund: keine ADR, kein Adaptions-Block, keine Hard Rule, keine Closure-Artefakte angefasst; die zwei ADR-Randbefunde stehen als Befund, nicht als Änderung |
| Rollen-Grenze (Implementer schreibt keinen Norm-Text) | geprüft, ohne Befund: „Art" nennt den Bericht ausdrücklich Nicht-Norm; Klassen sind Arbeitshypothese aus dem Plan; §4 stellt Fragen an den Architect; die LH-Bindungen (`einzeln`/`pauschal`/`nahe`) sind als Kandidaten mit Ebenen-Vorbehalt gekennzeichnet |
| Kein Umbau von `spec/`, `internal/`, `test/`, `cmd/` | geprüft, ohne Befund |
| Halluzinierte Gates / Gate-Lockerung | geprüft, ohne Befund: keine Target-Nennung, die das Makefile nicht führt (nur `make span-clean`, `make mutate`, `make test`, `make test-go`, `make span-check`, wie in der Spec) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 2 |

Wiederkehrende Klasse für die Slice-Closure §7: „Vollständigkeits-Kommando durch Sammelzeile teilweise blind" (F-2).

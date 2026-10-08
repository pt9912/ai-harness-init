# Review-Report: slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung — 2026-10-08

**Review-Art:** Code — gegen Plan + Konventionen.

**Gegenstand:** `294af852` (Claim `b1d2e28e`, `ea04fee3`, `fe9686ea`)

**Skill:** `.harness/skills/reviewer.md` @ `78381a2b` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung` (Plan §1–§3, §6, §8)
- `spec/spezifikation.md` §5, Zeilen `SPEC-024`, `SPEC-039`, `SPEC-049`, `SPEC-055`, `SPEC-056`, `SPEC-057`, `SPEC-087`
- `LH-FA-13`, `LH-FA-16`, `LH-QA-01`
- `MR-071`, `MR-077`, `MR-081`
- `AGENTS.md` §3.6, §3.7, §3.10

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Doc-Kommentar über den vier Sätzen sagt zu: „ändert sich die Zeile, fällt der Test". Die Tests halten je Spec-Zeile nur ausgewählte Wendungen; eine Änderung an einer nicht gewählten Stelle der Zeile bleibt grün, während die emittierte Feldliste das Gegenteil weiter behauptet. Sonde: `SPEC-057` um „das nur Sitzungen älter als 30 Tage entfernt" ergänzt und in `SPEC-049` „geschätzt wird nicht" durch „geschätzt wird aus `result_bytes`" ersetzt — beide Tests `PASS`, die Feldliste sagt weiter „das den ganzen Bestand entfernt" und „geschätzt wird nicht". Der Plan schließt den Wortlaut-Sensor in §1 ausdrücklich aus und führt die Abweichung als Risiko §6/1; der Kommentar sagt ihn trotzdem zu. Kein Gate meldet die Folge. | `AGENTS.md` §3.6 (Doc-Kommentar sagt mehr zu, als der Code hält); Skill „Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil" (HIGH, kein Gate meldet) | `internal/span/fieldlist.go:208` | ja — die Sonde unten | Kommentar sagt Kopplung an die ganze Quelle zu, Test hält Stichwörter |
| F-2 | LOW | Das emittierte Dokument trägt jetzt eine Zusage über den Bestand („**Der Bestand wird nie nebenbei geräumt.**", Räumen nur über `make span-clean`) und behält unverändert den Grenz-Satz „**Über den Bestand ist nichts zugesagt.**". Ein Adopter liest beide Sätze in derselben Datei; der zweite widerspricht dem ersten im Wortlaut, auch wenn sein Rumpf nur Vertraulichkeit meint. | `LH-FA-16` | `internal/span/fieldlist.go:149` gegen `:240` | nein | neue Zusage kollidiert mit bestehendem Grenz-Satz |
| F-3 | INFO | Die Quellen-Angabe nennt den Abschnitt als festes „§5"; die Tests binden die Gegenstands-Zelle aus der Spezifikation, das Abschnitts-Ordinal nicht. Eine Umnummerierung der Spezifikation lässt die emittierte Quellen-Angabe auf einen falschen Abschnitt zeigen, ohne Rot. | Maintainability | `internal/span/fieldlist.go:217`, `:225`, `:236`, `:244` | nein | Quellen-Angabe teilweise aus der Quelle gelesen |
| F-4 | INFO → Planner | Liefer-Punkt 1 verlangt den „Wortlaut, der die Quelle nennt (Spec-Zeile bzw. Adaptions-Eintrag)". Der Lauf nennt die Spec-Zeile bei ihrem Gegenstand und den Eintrag `MR-077` beim Titel statt bei der Kennung und trägt diese Lesart in §3 „Fortgeschrieben im Lauf (Implementer)" ein; begründet mit `LH-QA-01` (Kennungen lösen im Ziel nicht auf). Ob das die Abnahme von Liefer-Punkt 1 ist, entscheidet der Planner (`AGENTS.md` §3.10). `MR-081` steht im Bezug des Plans, die Feldliste nennt ihn nicht; der Cache-Satz stützt sich allein auf die Spec-Zeilen. | `AGENTS.md` §3.10 | Plan §3 | nein | — |

### Gefahrene Sonden (Scratchpad-Kopien per `git archive HEAD`, Host-Baum unberührt)

| Sonde | Erwartung | Ergebnis |
|---|---|---|
| Fälle 604–608 zusammen angewandt; Anker-Treffer gezählt | je genau eine Stelle | `fieldlist.go` 4 geänderte Zeilen, `spezifikation.md` 1 |
| Dieselben Mutationen, `go test -run 'TestFeldliste_(CacheStatus\|PRNummer\|HauptKontext\|Bestand)' ./internal/span/` | jeder benannte Test rot mit der gestrichenen Wendung | alle vier `FAIL`, je „traegt die Wendung "**…**" nicht"; 608 zusätzlich „(Quelle SPEC-057) traegt die Wendung "„Bestand (Abweichung 4)"" nicht" |
| Gegenprobe: Mutationen angewandt, `t.Skip("gegenprobe")` **ausschließlich** in den vier benannten Tests, `go test -count=1 ./...` | grün = jeder benannte Test bindet allein | EXIT 0, kein `FAIL` |
| F-1: `SPEC-057` und `SPEC-049` an nicht gewählter Stelle geändert, Feldliste unverändert | rot, wenn „ändert sich die Zeile, fällt der Test" hält | beide Tests `PASS` → F-1 |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Inhaltliche Wahrheit der vier Sätze gegen Spec und Code | geprüft, ohne Befund außer F-2: Cache-Zähler nur aus `tool_response.usage` eines `Agent`-Aufrufs (`internal/span/span.go:121`, `response.go:72–73`), sonst `nicht bekannt: tool_response.usage` (`notknown.go:17`); Emitter nur `O_APPEND` (`emit.go:312`); `span-clean` ist `rm -rf $(SPAN_DIR)` im unbedingten Fragment `templates/enforce/erfassung.mk:36`, der konvergente Aggregator bindet `harness/mk/*.mk` ein; PR-Satz deckt `SPEC-056`; Haupt-Kontext-Satz deckt `SPEC-049`; „Abweichung 3" führt §5 nicht mehr (`grep -n 'Abweichung [35]'` → nur `SPEC-039`), Abweichung 5 deckt der bestehende `limitCounters`. |
| Quelle beim Gegenstand statt Kennung (`LH-QA-01`) | geprüft: jeder zitierte Gegenstand steht genau einmal im Dokument (`grep -c` je 1), `quelleGenannt` liest die Zelle aus der Spezifikation, `mrTitel` den Titel aus der Eintrags-Datei; Rest in F-3, F-4. |
| Tests an der realen Quelle (§3.6) | geprüft, ohne Befund außer F-1: Spezifikation und MR-Datei werden gelesen, nicht abgeschrieben; Fall 608 mutiert die reale Spec-Zelle; Build-Kontext führt `spec/` und `harness/conventions/` (`.dockerignore` schließt nur `.git` und `.harness/*` aus). |
| Mutations-Fälle 604–608 (`MR-071`, Exklusivität) | geprüft, ohne Befund: `# files:` nennt die mutierte Datei, Anker trifft je eine Stelle, Gegenprobe grün; kein Fall-Kopf behauptet Exklusivität. |
| `full-smoke`-Stufe | geprüft, ohne Befund: liest `$repo/$FELDLISTE_REL` im gebootstrappten Ziel, Kopfzeile über `e2e_abdeckung`, Deklaration und Funktions-Kommentar nennen die Grenze „gemessen ist der Text im Ziel, nicht das Verhalten". Rot der Stufe nicht gefahren (braucht das Release-Artefakt). |
| Kommentare (§3.7) und je Test eigener Doc-Kommentar | geprüft, ohne Befund außer F-1: vier Tests und vier Helfer mit eigenem Kommentar, Indikativ, keine Chronik oder Befund-Kennung. |
| Schicht-Grenze (§1: keine Änderung an `spec/`, kein Schema-Feld, keine Emit-Vorlage) | geprüft, ohne Befund: `git show --stat 294af852` berührt `spec/` und `internal/emit/` nicht. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

# Review-Report: ADR-0070 — Kurzrunde vor dem Accept — 2026-09-26

**Review-Art:** Kurzrunde nach blockierenden Befunden (`ADR-0040` Festlegung 2: der Accept verlangt eine erneute Runde der prüfenden Rolle). Die Konsistenz-Runde `2026-09-26-review-adr-0070-konsistenz` meldete für `ADR-0070` zwei MEDIUM (Gate-Zusage für `done/` zu weit; Link-Syntax im Code-Span offen) und sechs LOW; der Architect hat korrigiert (Verdikt `2026-09-26-architect-verdikt-korrektur-adr-0070`). Geprüft wird **nur**, ob die Korrekturen die Findings tragen und keine neue Inkonsistenz einführen.

**Gegenstand:** `docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md` (Status `Proposed`) in der Fassung von Commit `45b86228` — eingeengte Gate-Zusage für `done/`, Festlegung 1 (syntaktische Erkennung, Grenze), Festlegung 3 (Begründung des Baum-Unterschieds), Trigger 4 bis 7, Folgepflichten 3 und 4, Fitness-Zeilen — gegen `ADR-0042`, `ADR-0033`, `ADR-0030`, `harness/tools/slice-mv.sh`, `internal/archive/{collect,scan}.go`, `.d-check.yml`, Baseline `modul-06-roadmap.md`, den ADR-Index. HEAD `45b86228`, Baum sauber bei Beginn.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13) · **Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eigene Läufe** — Zählungen mit den Kommandos der ADR im Repo (nur lesend, `git grep`/`awk`); der Rot-Beleg in einer Scratchpad-Kopie (`git archive HEAD`), kein Schreibzugriff im Repo-Baum, kein Push, kein `make mutate`, keine Host-Toolchain.

| Lauf | Ergebnis |
|---|---|
| Zählung (a): Code-Spans in `done/` rein / mit Leerzeichen / Kommandowort (ADR Z. 96-99) | `rein 17 · mit Leerzeichen 42` (Summe 59, gleich der Span-Zahl der Baum-Zählung), `32` mit Kommandowort — stimmt |
| Zählung (b): je Baum Link- und Span-Vorkommen (ADR Z. 110-117) | `done/` 527 Links · 59 Spans — stimmt. `docs/reviews/` 55 Links · **611** Spans in **214** Dateien; die ADR nennt 610 und 213 (die Zahlen wandern, `MR-025`; siehe I-70-1) |
| Zählung (c): Link-Syntax im Einzel-Backtick-Span / im Code-Block unter `docs/reviews/` (Z. 157) | `Span 9 · Block 0` — stimmt |
| Zählung (d): davon mit Ziel in `open/`, `next/`, `in-progress/` (Z. 158-159) | `0` — stimmt |
| Referenz-Definitionen auf einen beweglichen Träger (Z. 228 und Trigger 7) | `0` — stimmt |
| Zitat Abnahme-Kriterium 1 in `ADR-0033` (Z. 62) | `grep -c` → `1` — stimmt |
| Baseline-Zitat (Z. 169-172) gegen `modul-06-roadmap.md:273-276` | wörtlich gleich (*„Der Umzug ändert Pfade; die Operation zieht die Verweise nach — in **beiden** Formen, mit Verzeichnis-Präfix und geschwister-relativ."*); der Satz erklärt die zwei Formen selbst als Präfix gegen geschwister-relativ, also Schreibweisen — die Lesart der ADR trägt |
| `internal/archive/collect.go` `Reviews` (Z. 269-304) | sammelt über `SliceNummer` (Regex `^slice-([0-9]+[A-Za-z]*)`) und `ReviewTrifft` (`slice-<nr>` im Report-Dateinamen); benannte Slices ergeben die Nummer `""` und sammeln nichts; das Verdikt `…-slice-mv-und-eingefrorene-adressen.md` trägt keine Ziffern-Nummer — die Aussage der ADR (Z. 339-345) stimmt |
| `internal/archive/scan.go`: `Suchraum` gegen `AusgenommenePfadeNachzug` | `Suchraum` nimmt nur `AusgenommenePfade()` aus, `docs/plan/adr` kommt erst in `AusgenommenePfadeNachzug` hinzu — der Suchraum des Hänger-Wächters schließt die ADR ein, wie die ADR sagt |
| `.d-check.yml:384` | `exempt-paths: ["docs/reviews/**"]` steht unter `codepaths:` (Zeile 373); genau ein Treffer des Kommandos aus Z. 74 |
| ADR-Index Zeile 77 gegen die Datei; Zeile 37 (`ADR-0030`) als Muster für Folgepflicht 3 | Titel gleich der H1, Status `Proposed`, Bezug-Liste gleich (ADR-0042, -0033, -0030, -0040, `LH-QA-01`, `MR-000`, `MR-025`); die Zeile von `ADR-0042` (Z. 49) trägt noch keine Marke — richtig, Folgepflicht 3 sagt *„erst mit dem Accept"*; `ADR-0030` (Z. 37) führt das Muster *„Accepted (§Entscheidung Festlegung 3 … revidiert durch …)"* |
| `ls test/sources-pin.bats` | vorhanden; liest `.d-check.yml` und Makefile per `grep`/`sed` und vergleicht — die Kopplung in Folgepflicht 4 ist von derselben Bauart |
| **Rot-Beleg zu Fitness-Zeile 1** (Scratchpad, eine Fixture mit fünf Zeilen: Link mit und ohne Anker, reiner Pfad-Span, Operand im Kommando-Span, Fließtext, Pfad im Code-Block) | siehe Prüfpunkt (c) |

---

## Findings

Kein HIGH, kein MEDIUM. Beide MEDIUM der Vorrunde sind behoben; die sechs LOW der Vorrunde sind eingearbeitet (LOW-1 bis LOW-6 der Vorrunde: Baseline-Einordnung Z. 167-178, Index-Folgepflicht Z. 363-369, Kopplungs-Test Z. 370-373, Trigger Z. 396-420, Fußzeile/Bezug Z. 9-23, Referenz-Definition Z. 227-230).

### LOW

**L-70-1** — `kategorie`: LOW · `quelle`: `LH-QA-01` (ein Gate sagt nur über seinen Prüfbereich etwas), `AGENTS.md` §3.6 · `pfad`: `0070-…md:259-262` (Festlegung 3, zweiter Punkt) · `befund`: *„sie nicht nachzuziehen hieße, sie stumm zu schalten — eine Senkung nach §3.5"*. Ein unterbliebener Nachzug für den reinen Pfad-Span in `done/` färbt `make docs-check` rot (`codepath-missing`, die konstruierte Probe der ADR selbst); **stumm** wird er erst durch das Ventil, das der rote Lauf erzwingt. Der Satz überspringt das Rot, das die eigene Begründung trägt; der Zusammenhang steht in Festlegung 2, aber nicht in diesem Satz. · `verifizierbar`: nein (Wortlaut; die Probe selbst ist nicht als Sensor gebaut, Fitness-Zeile 5) · `klasse`: „Kausalkette verkürzt: Gate-Rot und Stummschaltung in einem Satz vermengt"

**L-70-2** — `kategorie`: LOW · `quelle`: `ADR-0042` §Verglichene Alternativen (A, Contra; D, Pro: *„Das Kriterium ist die Aussage, nicht die Gate-Sichtbarkeit"*) · `pfad`: `0070-…md:259-275` (Festlegung 3) gegen `0042-…md:423` und `:426` · `befund`: Der Baum-Unterschied für den reinen Pfad-Span (`done/` schreibt, `docs/reviews/**` nicht) hängt an der Gate-Sichtbarkeit; genau diese Ursache nennt `ADR-0042` als Contra von Alternative A und schließt sie als Maßstab in Alternative D aus. Die ADR benennt die Sache ehrlich (*„Kostenargument, kein Prinzip"*, Negativ, Trigger 6), zitiert aber die Stelle nicht, gegen die sie sich hier stellt; `ADR-0042` Festlegung 1 trägt daneben selbst ein Gate-Kosten-Argument (*„weniger prüfen"*), das die Position deckt — dieses Stück steht ebenfalls nicht da. Wer die Alternativen von `ADR-0042` liest, sieht einen Widerspruch, den die ADR nur teilweise auflöst. Der Rest ist **kein** Widerspruch zu *„die Tatsache-Begründung gilt für beide Bäume"*: die zwei Begründungen sind getrennt und die Restungleichbehandlung ist als solche benannt (siehe Prüfpunkt (a)). · `verifizierbar`: ja (Lektüre gegen `0042-…md:423-426`) · `klasse`: „Abweichung von einer Alternativen-Zeile der Vorgänger-ADR ohne Zitat der Stelle"

**L-70-3** — `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6 (Zusage ohne rot gesehenes Gegenbeispiel) · `pfad`: `0070-…md:220-226` (Festlegung 1, Grenze: *„Code-Span **oder Code-Block**"*) gegen `:383` (Fitness-Zeile 2: *„Link-Syntax als Zitat in einem Code-Span"*) · `befund`: Die Grenze sagt, ein Link-Zitat werde im Code-Span und im Code-Block mitersetzt; die Fitness-Zeile bindet nur den Span. Der Block hat Bestand 0 und keinen Fall; das Gegenbeispiel für die Block-Hälfte der Zusage fehlt, ohne dass die Lücke benannt wäre (die Referenz-Definition ist benannt, der Block nicht). Folge bei einer Regel, die nur die Zeilen im Span erkennt: der Block bliebe unbemerkt anders. · `verifizierbar`: ja (Fitness-Zeile 2 um eine Block-Zeile) · `klasse`: „Grenz-Zusage nennt zwei Formen, ein Fall bindet eine"

### INFO

**I-70-1** — `kategorie`: INFO · `quelle`: `MR-025` · `pfad`: `0070-…md:115-117` · `befund`: Die Zahlen `610` Spans / `213` Dateien in `docs/reviews/` stehen am HEAD bei `611` / `214`; sie sind ausdrücklich keine Erwartungswerte, die Tabelle nennt den Stand (`f8d33b38`), die Zählung nicht. Kein Fehler; die Größenordnung trägt. · `verifizierbar`: ja · `klasse`: „datierte Zählung ohne Stand neben dem Kommando"

**I-70-2** — `kategorie`: INFO · `quelle`: `MR-000`, Baseline `modul-06-roadmap.md` Schritt 4 · `pfad`: `0070-…md:167-178` · `befund`: Die Einordnung *„keine Abweichung, kein Eintrag"* ruht auf der engen Lesart, dass ein Pfad im Code-Span **kein Verweis** im Sinn der Stelle ist. Die Stelle lässt das offen (das sagt die ADR); sie ist damit eine Wette auf die Lesart des Kurses, keine Feststellung. Wird der Kurs an dieser Stelle einmal deutlicher, ist ein Eintrag fällig — die ADR hält das Urteil beim Architect. · `verifizierbar`: nein · `klasse`: „Baseline-Lesart offen gelassen, Einordnung hängt an ihr"

**I-70-3** — `kategorie`: INFO · `quelle`: `ADR-0042` Festlegung 4, Gegenform 2 · `pfad`: `0070-…md:266-269` · `befund`: Die *„42 Spans dieser Klasse"* in `done/` (Näherung: Leerzeichen im Span) und die *fünf* Fundstellen von `ADR-0042` (Operand im Code-**Block**, Messung 5) sind zwei verschiedene Mengen; die ADR sagt *Näherung*, nennt die Differenz aber nicht. Der Leser, der beide Zahlen nebeneinander sieht, kann sie für dieselbe halten. · `verifizierbar`: ja · `klasse`: „zwei Messungen über verwandte, nicht gleiche Mengen ohne Abgrenzung"

---

## Prüfpunkte des Auftrags

**(a) Trägt die Tatsache-Begründung in Festlegung 3, oder versteckt sie sich hinter dem Kostenargument?** Sie trägt. Die ADR trennt zwei Aussagen und behauptet nicht, dass die zweite für beide Bäume gilt: *Tatsache* ist baum-unabhängig (Link = Zeiger, Span/Operand/Block = Beleg des damaligen Orts), *Gate* trägt nur für den reinen Pfad-Span in `done/` (`codepaths` sieht ihn, gemessen konstruiert). Daraus folgt die benannte Rest-Ungleichbehandlung (Operand und Block in `done/` behalten den Nachzug, obwohl die Tatsache-Begründung dagegen spräche), begründet mit der Kontext-Erkennung, die ein Träger dafür bräuchte — dieselbe, die Festlegung 1 für das Link-Zitat verwirft, und die Trennung *„Adresse ja, aussagetragende Adresse nein"*, die `ADR-0042` Alternative E verwirft. Das ist konsistent: *„gilt für beide Bäume"* bezieht sich auf die Begründung, *„Kosten, nicht Prinzip"* auf den Umfang des Nachzugs; die zwei Sätze widersprechen einander nicht. Die Wendung *„aus Kosten, nicht aus Prinzip"* steht im Verdikt, die ADR sagt *„Kostenargument, kein Prinzip"*. Offen bleibt die Zitierung der Vorgänger-Alternativen (L-70-2), nicht der Kern.

**(b) Zählungen.** Alle Zahlen der ADR am HEAD reproduziert (Tabelle oben); Abweichung nur bei den zwei wandernden Summen (I-70-1). Die Politik-Tabelle (Stand `f8d33b38`, `1964` geprüfte Dateien) habe ich nicht neu gefahren: die Kopien aus dem Verdikt sind Läufe außerhalb des Repos und in dieser Runde nicht Gegenstand; die Vorrunde hat sie geprüft, die Tabelle ist unverändert.

**(c) Fitness-Zeile 1 — Rot konstruierbar?** Ja, gefahren in der Scratchpad-Kopie; **gefahren** ist der reale Träger nur für Politik A, alles andere ist eine `sed`-Nachbildung der Regel, nicht der Go-/Shell-Träger:

- **Realer Träger, Politik A** (die Funktion `rewrite_incoming_in_file` aus `harness/tools/slice-mv.sh`, aus der Kopie herausgelöst und gegen die Fixture gefahren): **5** von 5 Zeilen mit dem Pfad ersetzt — Link, reiner Span, Operand, Fließtext, Block. Das ist das Rot der Zusage *„die Form-Regel entfällt"*: der reine Span wird umgeschrieben.
- **Nachbildung der Form-Regel** (`sed`, Anker `](`, Ziel bis `)` oder `#`): genau die Link-Zeile ändert sich; die vier Nicht-Link-Formen bleiben **Byte für Byte** (`diff` der Nicht-Link-Zeilen leer).
- **Nachbildung des Trägers mit nur unmittelbarem Backtick-Kontext** (Token in Backticks ohne Leerzeichen bleibt, sonst Ersatz): der reine Span bleibt, **Operand, Fließtext und Code-Block werden ersetzt**, dazu der Link — der Träger besteht den reinen Span und bricht die drei anderen. Ein Fall mit **nur** dem reinen Span lässt denselben Träger **unverändert** (grün). Beide Aussagen der Zeile (Rot bei drei Formen, Grün bei einem Fall nur mit reinem Span) sind damit belegt; sie gelten für die Nachbildung, nicht für einen gebauten Träger, und die Zeile sagt selbst *„Noch nicht gebaut"*.
- Der Link-Nachzug-Zweig (Politik B, *„der Link ist tot"*) ist nicht neu gefahren; er steht auf der Messung *+2* aus der Vorrunde.

**(d) Trigger 4 bis 7, Folgepflicht 4.** Alle vier sind an einem benannten Beleg ablesbar und tragen keinen Termin: 4 und 5 am Bericht eines Laufs, 6 am Diff des Nachzug-Commits (`git show -U0`) oder am Träger (Kontext-Erkennung), 7 an einem Kommando mit Zahl (`… | wc -l` größer 0, gefahren: `0`). Trigger 1 und 2 sind an `.d-check.yml` ablesbar. `test/sources-pin.bats` existiert und ist ein taugliches Vorbild (liest `.d-check.yml` per `grep`, vergleicht mit dem Makefile). Ein Kopplungs-Test müsste die Zeile unter `codepaths:` (Z. 373-384) eingrenzen — die anderen Module tragen ähnliche `exempt-paths`-Zeilen (Z. 324, 328, 340, 371), der Test darf sie nicht mit der Zeile aus Z. 384 verwechseln; das ist Sache des Implementers, kein Befund.

**(e) Baseline-Zitat.** Wörtlich, siehe Tabelle. Der Satz *„beide Formen sind dort zwei Schreibweisen desselben Pfades"* folgt aus der Stelle selbst (*„mit Verzeichnis-Präfix und geschwister-relativ"*); dass ein Span-Pfad ein *Verweis* ist, lässt sie offen — I-70-2.

**(f) `AGENTS.md` §3.4 / §3.11.** Die ADR schreibt keine Pfad-Adresse eines beweglichen Artefakts. Der Link auf das Verdikt (Z. 130, `docs/reviews/…-slice-mv-und-eingefrorene-adressen.md`) wird durch die Begründung Z. 339-345 gedeckt: `Reviews` sammelt nur Reports mit einer Ziffern-Slice-Nummer im Namen, das Verdikt hat keine, `docs/reviews/` ist eine stehende Ablage, und träfe ein Schnitt es doch, bräche der Hänger-Wächter laut (sein Suchraum schließt `docs/plan/adr/` ein) — alles am Code gelesen. Die Fassung des Korrektur-Verdikts steht in der ADR nur als Kennung (Geschichte-Zeile), nicht als Pfad.

**(g) Index.** Zeile 77 stimmt mit der Datei (Titel, Status, Bezug). Die Marke an der Zeile von `ADR-0042` fehlt noch und ist erst beim Accept fällig (Folgepflicht 3) — richtig; eine Marke vorher wäre eine unwahre Zustandsaussage.

**(h) Acceptance-Trigger, HIGH-Liste.** Der Trigger ist erfüllbar und benannt (Reviewer-Runde gegen `ADR-0042`, `-0033`, `-0030`; nach blockierenden Befunden die nächste Runde, `ADR-0040` Festlegung 2; die Accept-Zeile nennt die Kennung). Die Kennung dieser Runde ist `2026-09-26-review-kurzrunde-adr-0070`. Repo-HIGH-Liste des Skills: kein Verstoß gegen eine aktive ADR oder Hard Rule (die ADR ändert `.d-check.yml` nicht, keine Senkung nach §3.5, die geprüfte Dateizahl gleich in allen Politiken); kein halluziniertes Gate (Fitness-Zeilen tragen *„Noch nicht gebaut"*, kein Target wird behauptet); keine Zustandsfeld-Chronik im Index.

## Geprüft, ohne Befund

- Kontext-Zählungen und Kommandos (Z. 96-99, 110-117, 157-159, 186-189 nicht neu gefahren, Z. 228): stimmen bis auf die zwei wandernden Summen (I-70-1)
- Erkennungs-Grenze (Festlegung 1): syntaktisch, benannt statt behoben, Bestand 9/0/0, Trigger 6 und 7 tragen
- Baseline-Zitat und Einordnung (Kontext Z. 167-178): wörtlich, Lesart benannt (I-70-2)
- Folgepflichten 1 bis 4 und Fitness-Zeilen 1, 3 bis 6: konsistent nummeriert (Zeile 6 = Kopplung), Rot-Bedingungen konstruierbar
- §3.4/§3.11, Ausnahmeliste, Index: kein Befund

## Accept-Empfehlung

**ja.** Kein blockierender Befund gegen den Gegenstand; die zwei MEDIUM der Vorrunde sind behoben, die Korrektur führt keine neue Inkonsistenz ein. Die drei LOW sind Wortlaut- und Deckungslücken, keine Bedingung des Accept.

**Tokens vor dem Accept** (nach dem Accept ist die Datei nach `AGENTS.md` §3.4 nicht mehr inhaltlich änderbar) — optional, nichts davon blockiert:

1. L-70-1: Z. 259-262 — *„sie nicht nachzuziehen hieße, sie stumm zu schalten"* auf die tragende Kette bringen (unterbliebener Nachzug färbt `codepaths` rot; stumm wird er erst durch das Ventil, eine Senkung nach §3.5).
2. L-70-2: Z. 259-275 — die Stelle nennen, gegen die die Gate-Sichtbarkeit hier als Grund dient (`ADR-0042` Alternative A und D) und die Stelle, die sie deckt (Festlegung 1, *„weniger prüfen"*).
3. L-70-3: Z. 383 (Fitness-Zeile 2) — den Code-Block als Fall aufnehmen oder als benannte Lücke neben die Referenz-Definition stellen (Z. 389-392).

Ohne diese Korrekturen kann der Accept vollzogen werden; die drei bleiben dann als Befund im Bericht und ggf. Folge-ADR-Stoff.

# Architect-Verdikt: Wächter `register-ausgang` (F-1, F-3) und die acht Einträge ohne Ausgang

**Rolle:** Architect (Modul 8, Konflikt-Pfad und Zeile 3b). **Datum:** 2026-10-08.
**Eingang:** Review `2026-10-08-register-ausgang-review.md` (F-1, F-3), Slice
`slice-register-ueber-der-schwelle-bekommt-seinen-waechter`,
`bash harness/tools/register-ausgang.sh` → 233 Einträge, 65 über der Schwelle, 8 Befunde, rc=1
(gelesen 2026-10-08, keine Erwartung).

## F-1 — Verdikt 3: Die Schärfe ist legitim, aber nicht entschieden

Das Repo führt Wellen. Nach `modul-06-roadmap.md` ist der Lese-Schritt deshalb die Welle-Closure,
und [ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 3 erlaubt `offen`
über der Schwelle bis dahin. Ein Gate ohne Zeit-Bedingung ist schärfer als diese Entscheidung, und
der Bestand liest den Zeitpunkt zweifach. Die Schärfe zieht eine Folge-ADR nach:
[ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md) (`Proposed`).
Eine Slice-Closure, die einen Eintrag über die Schwelle hebt, ist für ihn ein Lese-Schritt. Der
Ausgang steht im Commit des Belegs. Die ADR ersetzt ADR-0049 nicht, sondern ergänzt sie.

**Für den Slice:** Plan §1 gilt. Die Verdrahtung in `make gates` folgt auf das Accept von ADR-0085
**und** auf einen Bestand ohne Befund (Tabelle unten, `state.md` schreibt der Planner). Bis dahin
bleibt der Wächter ein Werkzeug mit `kein Gate`. Der Kopf des Skripts nennt den Zeitpunkt, sobald
ADR-0085 angenommen ist.

## F-3 — Bindung

Die Regel kommt aus **ADR-0049**, der Zeitpunkt aus **ADR-0085**. **ADR-0069** gilt nur für die
Zählung (`evidence/*.md`). Zieht der Implementer nach: `harness/README.md` §Werkzeuge,
Skript-Kopf, `Makefile`-Hilfetext und Plan §3. Die Begründung *„Ausnahmeliste verbietet ADR-0069
(Trigger 2)"* stützt sich stattdessen auf Plan §3: der Sensor führt keine Liste erwarteter
Einträge.

## Die acht Einträge — je ein Ausgang

| `BEO-ALL/<slug>` | Belege | Ausgang | Zielort / Kennung · Begründung |
|---|---|---|---|
| `beleg-faehrt-den-behaupteten-pfad-nicht` | 3 | verkörpert | [`AGENTS.md`](../../AGENTS.md) §3.6, Falsch/Richtig *„Byte-Gleichheit belegt `make smoke`"* → *„benennen, was wirklich deckt — oder dass nichts deckt"*. Die Regel ist älter als die Beobachtung, deshalb kein Herkunfts-Anker (ADR-0049 Festlegung 1). Als Grenze für `state.md`: kein Wächter. `make mutate` hält vorhandene Zähne und prüft keinen Beleg-Pfad. |
| `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` | 5 | verkörpert | `.harness/skills/reviewer.md`, Eintrag *„Mutations-Fall nennt einen Test, die Mutation färbt mehrere"*. Der Anker `seit slice-fall-406-trifft-die-umgebaute-zerlegung` ist vorhanden. **Ab 4: kein mechanischer Sensor möglich.** Der Grund steht am Zielort: Eine Exklusivitäts-Prüfung im Treiber träfe legitimes Mitfärben über eine gemeinsame Ausgabe-Senke systematisch als Befund. |
| `plan-abweichung-landet-im-commit-bericht-statt-im-plan` | 4 | verkörpert | Baseline-Regelwerk `modul-09-implementierung.md` §Rücksprungkanten-Regeln, *„Der Plan lebt in §3 des Slice-Plans"*. Die Baseline nennt ihre eigene Stelle, deshalb kein Anker. **Ab 4: kein mechanischer Sensor möglich.** Ein Commit trägt keine Slice-Kennung, also kann kein Sensor Commit-Dateien eindeutig der §3 eines Plans zuordnen. Träger ist der Plan-vs-Code-Diff des Verifiers, der alle vier Belege gefunden hat. |
| `pin-digest-ohne-waechter` | 4 | geplant | **`slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`** (neu, Planner): (a) die Fallbacks in `harness/tools/smoke.sh`/`full-smoke.sh` gegen den Pin, netzlos in `make gates`; (b) den `@sha256`-Digest gegen den Tag, nächtlich mit Netz wie `regelwerk-check`. **Mechanischer Sensor:** (a) und (b). Die vorhandene Datei `slice-pin-kopplung-bekommt-ihren-mutations-fall` ist ein anderer Gegenstand. |
| `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` | 3 | geplant | Derselbe Sammel-Slice, Teil (c): ein kommentar-bereinigter `diff` jedes Paars aus Dogfood und Vorlage (`history-range-guard`, `stop-require-gates`/`record-gates`, `close-welle`) in `make test`. Die erlaubten Abweichungen nennt der Slice. |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 3 | geplant | **`slice-162-versions-sensor-baseline-pins`** (liegt in `open/`). Das `versions`-Modul macht einen vergessenen Tag-Nachzug zum Befund. Der Planner nimmt die Inline-Code-Pfade ohne Link ausdrücklich in §1 auf. |
| `baseline-sprungweite-treibt-kosten` | 3 | geplant | **`slice-baseline-wird-je-release-adoptiert`** (neu): Ein MR-Eintrag des Architect setzt den Adoptions-Rhythmus. Jede Version, die `make baseline-freshness` meldet, wird als eigener Sprung adoptiert. Der Slice hängt an der Auftraggeber-Entscheidung unten. |
| `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` | 3 | geplant | **`slice-span-traegt-die-fassung-seiner-erfassungsregel`** (neu): Ein Span trägt die Fassung der Regel, unter der er entstand. Der Slice entscheidet zwischen einem Feld in `spec/spezifikation.md` §5 und einer datierten Wechsel-Zeile dort. Ohne Fassung trennt kein Leser einen Regelwechsel von einer Verhaltensänderung. |

**Kein Eintrag gestrichen:** Alle acht Klassen können wieder auftreten. Bei *verkörpert* trägt der
Planner die Grenze als Abschnitt *Grenze der Verkörperung, benannt* in die `state.md` ein, und die
Stand-Zeile nennt den Zielort.

## Offene Entscheidungen des Auftraggebers

- **Accept von ADR-0085.** Empfehlung: annehmen. Davon hängt die Verdrahtung des Wächters ab.
- **Adoptions-Rhythmus „je Release ein Sprung".** Option: ja oder weiter gesammelt. Empfehlung: ja,
  denn die Belege zeigen, dass die Kosten mit der Sprungweite wachsen. Lehnt der Auftraggeber ab,
  ist das kein Grund für *gestrichen*, denn die Klasse tritt weiter auf. Der Ausgang wird dann
  im nächsten Architect-Zug neu entschieden.

# Review-Report: `slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung` — 2026-09-18 (Runde 4)

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11).

**Gegenstand:** `93dc8bec` — ein Commit, sieben Dateien (eine davon der Runde-3-Report).
Vorlauf: Runde 1 (1 HIGH, 2 MEDIUM, 2 LOW, 2 INFO), Runde 2 (1 HIGH, 1 MEDIUM, 3 LOW,
1 INFO), Runde 3 (1 HIGH, 1 MEDIUM, 1 LOW, 1 INFO).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 ·
**Modell:** claude-opus-5 · **Datum:** 2026-09-18.

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Ein `pfad`-Feld auf den
> **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den Stand des
> Laufs und darf ihn festhalten.

**Eingangs-Kontext:** die Findings der Runden 1 bis 3 zu diesem Slice · der Slice-Plan
§1 bis §3 · `LH-FA-12` (tragend), `LH-FA-02`, `LH-QA-01`, `LH-QA-03` ·
`AGENTS.md` §3.6, §3.7 · Baseline `v6.9.0` ·
`regelwerk/modul-13-quality-gates.md` §Ein Gate ohne seine Grenze.

---

## Findings

### Eigene Läufe — Grundlage der Findings

Träger ist ein über `make host-bin` **neu gebautes** Binär über `93dc8bec`; die
emittierte Datei im Ziel ist byte-gleich mit ihrer Vorlage. Gemessen wurde in einem
frisch gebootstrappten, sprachlosen Ziel und über einem `git archive`-Klon dieses Repos
im Scratchpad. Der Arbeitsbaum blieb unberührt — `git status --porcelain` leer.

| Lauf | Ergebnis |
|---|---|
| Quelltext-Suche in der Vorlage nach `](`, `rel_prefix`, `slug`, `titel_fuer`, `titel_rein`, `TYPOGRAFIE`, `SATZZEICHEN`, `ANFUEHRUNGEN` | **kein einziger Treffer** — es gibt keinen Zweig, der einen Verweis bauen könnte |
| Ziel: Überschrift liegt, Kennung **löst auf** (`RQ-1`), dazu `LH-FA-01` | Zelle `` `RQ-1`, `LH-FA-01` ``; Links im ganzen Dokument: **0** |
| Ziel: Gedankenstrich-Zweig | Zelle `—`, Hinweis nennt die Stufe, Zähler `1 ohne Kennung` |
| Ziel: **Spec-Datei entfernt** | Exit 0, **kein Wort dazu**; die geschriebene Sicht nennt die fehlende Datei weiter als Maßstab (Zeile 14) |
| Ziel: `E2E_ABDECKUNG_SPEC=meine-anforderungen.md` | die geschriebene Sicht nennt `meine-anforderungen.md` (1×), die Vorgabe **nicht** (0×) — der Marker wirkt an dem, was entsteht |
| Ziel: `make docs-check` über allen drei erzeugten Sichten | **EXIT 0**, 24 Dateien, 0 Befunde |
| Klon dieses Repos, unverändert, d-check mit dem gepinnten Digest | 1678 Dateien, **0 Befunde** |
| derselbe Klon, **ein** Anker in `docs/user/e2e-abdeckung.md` künstlich verdorben | 1678 Dateien, **1 Befund** — `anchor-missing` auf genau dieser Datei, EXIT ≠ 0 |
| unsere Fassung über `### RQ-9 — Titel mit Leerzeichen␣␣␣` | Anker `#rq-9--titel-mit-leerzeichen` — **ohne** Bindestriche am Ende; der Fall aus Runde 3 ist zu |

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | LOW | Mit dem Verweis-Zweig ist auch der **Hinweis auf eine fehlende Spec-Datei** entfallen: der Lauf sagt dazu nichts mehr, und die geschriebene Sicht nennt die Datei trotzdem als Maßstab des Lesers — gemessen an einem Ziel ohne `spec/lastenheft.md`: Exit 0 ohne ein Wort, Zeile 14 der Sicht nennt sie. Ein Adopter, dessen Anforderungen woanders stehen und der den Marker nie setzt, bekommt einen Zeiger auf eine Datei, die es nicht gibt; vorher nannte der Lauf ihm Datei **und** Marker. Kein Gate sieht es, weil es ein Code-Span ist. | Maintainability · `LH-FA-02` (der Marker ist das, was der Adopter setzen soll — der Lauf sagt ihm nicht mehr, dass er es müsste) | `internal/emit/templates/enforce/e2e-abdeckung.sh:155` (die geschriebene Zeile) gegen den in diesem Commit entfallenen Existenz-Zweig | ja — Ziel ohne Spec-Datei, `make e2e-abdeckung`, Ausgabe und Zeile 14 der Sicht lesen | mit dem Zweig ist auch sein Hinweis entfallen |
| R4-2 | INFO | **Planner-Punkt, bestätigt.** DoD LP3 beschreibt die Trennlinie überholt: *„Löst eine deklarierte Kennung in der Spec des Ziels nicht auf, schreibt die emittierte Fassung sie als Code-Span ohne Verweis"* — unter der ausgelieferten Fassung trägt **jede** Kennung einen Code-Span, auch die auflösende; der Satz liest sich als Ausnahme für einen Sonderfall, den es nicht mehr gibt. Auch die zugehörige *Rot durch*-Zeile („eine nicht auflösende Kennung … → bricht die emittierte Fassung ab") hat kein Objekt mehr. Die zweite Hälfte (unsere Fassung bricht ab) trägt weiterhin — gemessen. Dazu unverändert: die §3-Tabelle führt die inzwischen berührten Dateien nicht vollständig. | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice · zuständig: **Planner** (`AGENTS.md` §3.10 — die ausführende Rolle schreibt ihr Abnahmekriterium nicht um) | Slice-Plan §2, dritter Liefer-Punkt | nein | DoD beschreibt eine Trennlinie, die der Code nicht mehr führt |
| R4-3 | INFO | **Architect-Punkt, bestätigt.** `LH-FA-12` §Benannte Grenze lautet: *„Löst eine genannte Kennung in der Spec des Ziels nicht auf, steht sie als Code-Span ohne Verweis statt als Befund"*. Wörtlich bleibt der Satz wahr, seine **Implikatur** nicht: er stellt den Code-Span als Ausnahme dar und unterstellt damit für den auflösenden Fall einen Verweis, den die ausgelieferte Fassung nirgends mehr schreibt. Die übrigen sieben Akzeptanzkriterien halte ich gegen die Messung für unberührt — Happy Path, Gedankenstrich, beide Lücken-Richtungen, zweiter Lauf, Minimalität und *kein aus dem Nichts* sind gemessen erfüllt, und der Marker-Satz ebenfalls (siehe Negativbefund). | `spec/lastenheft.md` (Vertrags-Stratum) · zuständig: **Architect** über einen Change Request ([`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)) | `spec/lastenheft.md:446-449` | nein | Vertrags-Satz trägt eine Implikatur, die der Code nicht mehr führt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Frage 1 — schreibt die ausgelieferte Fassung doch irgendwo einen Verweis? | geprüft, ohne Befund — **nein**, und zwar zweifach belegt: die Quelltext-Suche findet keine der sieben Ableitungs-Stellen, kein `rel_prefix` und kein `](`; und im Ziel bleibt die Zelle ein Code-Span auch dort, wo die Überschrift liegt und ein Anker abzuleiten wäre. Der `—`-Zweig, der Mehr-Kennungs-Zweig und der Zweig ohne Spec-Datei schreiben alle drei dieselbe Form |
| Frage 2 — ist der Trim die richtige Stelle? | geprüft, ohne Befund — er sitzt in `slug_fuer` **vor** Kleinschreibung und Löschungen, also dort, wo auch der Renderer trimmt; gemessen: die Überschrift aus Runde 3 ergibt jetzt `#rq-9--titel-mit-leerzeichen` ohne Bindestriche am Ende |
| Frage 2 — bleibt der Träger greifbar? | geprüft, ohne Befund, und **gemessen statt geglaubt**: über einem `git archive`-Klon liefert der gepinnte d-check 0 Befunde; ein einziger verdorbener Anker in `docs/user/e2e-abdeckung.md` macht daraus 1 Befund `anchor-missing` mit EXIT ≠ 0. Da `docs-check` in `make gates` hängt, färbt eine künftig danebengehende Ableitung wirklich rot — nach dem Schreiben, und genau das sagt der Sensor-Text auch |
| Frage 3 — hält die Kopplung die Asymmetrie, statt sie zu unterstellen? | geprüft, ohne Befund — der Kopplungs-Fall prüft **beide** Richtungen je Stelle: die sieben Ableitungs-Namen kommen in unserer Fassung ≥ 1× und in der ausgelieferten **0×** vor, dazu `](` ≥ 1× hier und 0× dort. Geteilt bleiben Tabellen-Kopfzeile, Deklarations-Form und die zwei Lücken-Schlüssel. Das ist eine Messung über beide Dateien, keine Behauptung |
| Frage 4 — ist `E2E_ABDECKUNG_SPEC` unter B noch etwas wert? | geprüft, ohne Befund — **ja, knapp und nachweisbar**: gesetzt, nennt der Kopf der geschriebenen Sicht die gesetzte Datei, und die Vorgabe steht nicht daneben (1× / 0×). Damit wirkt er an dem, **was entsteht**, wie `LH-FA-12` es verlangt, und nicht nur in der Ausgabe des Laufs. Sein Gewicht ist von *Quelle der Anker* auf *Maßstab des Lesers* gesunken, und genau so steht es in der Marker-Liste der Vorlage |
| R3-2 (Kalibrierung ohne Grenze) | **erledigt** — die Grenze und ihr Träger stehen jetzt an der Stelle: der Absatz *WAS DIESE NACHBILDUNG TRAEGT — UND WARUM SIE NUR HIER STEHT* nennt `make docs-check` in `make gates` als Träger und sagt, dass die ausgelieferte Fassung ihn nicht hat; der Sensor-Text trägt dieselbe Aussage samt dem, was offen bleibt (es fällt **nach** dem Schreiben) |
| R3-3 (Kommentar nennt einen Ort ohne die Aussage) | **erledigt** — der Zeiger steht jetzt auf `harness/sensors/full-smoke.md`, und dort steht die Formen-Liste wirklich |
| R3-1 (dritte Richtung, Whitespace) | **erledigt für die Fassung, die sie noch betrifft** — unsere; in der ausgelieferten hat der Fall kein Objekt mehr, weil kein Anker mehr entsteht |
| Aufteilung insgesamt — verschiebt sie das Problem? | geprüft, ohne Befund — **nein**: die Klasse *abgeleiteter Anker ohne Prüfung gegen die Zieldatei* existiert in der ausgelieferten Fassung nicht mehr (keine Ableitung), und in unserer hängt sie an einem Träger, der gemessen bei jedem `make gates` bissig ist. Das ist keine Verschiebung, sondern die Ablösung einer Nachbildung durch einen Verzicht dort, wo kein Gate sie halten kann |
| `AGENTS.md` §3.2 | geprüft, ohne Befund — keine Suppression im Diff; der Backtick steht weiter als Variable |
| `AGENTS.md` §3.4/§3.5/§3.8/§3.10/§3.11 | geprüft, ohne Befund — keine ADR, keine Gate-Lockerung, keine Norm-Artefakte; die zwei fremden Artefakte hat der Implementer **gemeldet statt geändert**, und das ist die richtige Kante |
| `LH-QA-01` / `kein Gate` | geprüft, ohne Befund — unverändert an keiner Gate-Kette des Ziels |
| Committete Sicht dieses Repos | geprüft, ohne Befund — der Referenz-Lauf über dem Klon ist grün, die Sicht trägt weiter ihre 18 auflösenden Verweise |
| Emittierte Ablage, Klassen, Marker-Liste | geprüft, ohne Befund — konvergent, vier Marker unverändert, keine neue Abhängigkeit |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** mit dem Zweig ist auch sein Hinweis entfallen ·
DoD beschreibt eine Trennlinie, die der Code nicht mehr führt · Vertrags-Satz trägt eine
Implikatur, die der Code nicht mehr führt

*Die Klasse **abgeleiteter Anker wird geschrieben, ohne gegen die Zieldatei geprüft zu
sein** ist in diesem Lauf nicht mehr aufgetreten. Dass sie in drei Runden dreimal
auftrat, bleibt der Zähler-Stoff der Closure — nicht dieses Reports.*

## Verdikt

**Merge-blockierend:** nein.

**Ist der Weg zu Verifikation und Closure frei? Ja — mit einer Reihenfolge.** Die
Aufteilung trägt, und sie verschiebt nichts: In der ausgelieferten Fassung gibt es die
Klasse nicht mehr, weil es die Ableitung nicht mehr gibt — belegt über den Quelltext
(keine der sieben Stellen, kein `](`) **und** über das Verhalten (Code-Span auch dort,
wo der Anker abzuleiten wäre). In unserer Fassung bleibt die Nachbildung, aber ihr
Träger ist kein Argument, sondern gemessen: derselbe Klon liefert 0 Befunde und, mit
einem verdorbenen Anker in genau dieser Datei, 1 Befund mit EXIT ≠ 0. Die Begründung
des Implementers — eine Nachbildung nur dort, wo ihr Gate läuft — steht damit auf einer
Messung, nicht auf einer Einschätzung. Der Trim sitzt an der Stelle, an der auch der
Renderer trimmt, und schließt den Fall aus Runde 3.

**Die Reihenfolge:** Die zwei fremden Punkte sind **bestätigt**, und der DoD-Punkt gehört
**vor** die Verifikation, nicht nach ihr — LP3 ist das Prüf-Artefakt des Verifiers, und
ein überholter Satz darin ließe ihn eine Trennlinie messen, die der Code nicht mehr
führt. Der Lastenheft-Satz ist Vertrags-Stratum und braucht den Weg, den er braucht; er
blockiert die Verifikation nicht, weil er wörtlich wahr bleibt.

**Übergabe:** R4-1 geht an den Implementer; R4-2 an den **Planner**, R4-3 an den
**Architect** (Modul 10 §Was dieser Skill NICHT macht — ich bestätige, ich schreibe
nicht). Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in
den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser
Skill, dieses Modell, dieses Verdikt) — er wird über Läufe hinweg nicht wieder gelesen,
und muss es nicht. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

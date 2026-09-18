# Review-Report: `slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung` — 2026-09-18 (Runde 3)

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11).

**Gegenstand:** `321210de` — ein Commit, acht Dateien (eine davon der Runde-2-Report).
Vorlauf: Runde 1 (1 HIGH, 2 MEDIUM, 2 LOW, 2 INFO), Runde 2 (1 HIGH, 1 MEDIUM, 3 LOW,
1 INFO).

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

**Eingangs-Kontext:** die Findings der Runden 1 und 2 zu diesem Slice · der Slice-Plan
§1 bis §3 · `LH-FA-12` (tragend), `LH-FA-02`, `LH-QA-01`, `LH-QA-03` ·
`AGENTS.md` §3.6, §3.7 · Baseline `v6.9.0` ·
`regelwerk/modul-13-quality-gates.md` §Ein Gate ohne seine Grenze.

---

## Findings

### Eigene Läufe — Grundlage der Findings

Träger ist ein über `make host-bin` **neu gebautes** Binär über `321210de`; die emittierte
Datei im Ziel ist byte-gleich mit ihrer Vorlage. Gemessen wurde in einem frisch
gebootstrappten, sprachlosen Ziel; der Arbeitsbaum dieses Repos blieb unberührt.

Gesucht wurde die dritte Richtung: **fünf** Überschriften in einer Spec-Datei des Ziels,
alle fünf in **einer** Deklaration genannt, eine Sicht, ein Gate-Lauf darüber.

| Überschrift im Ziel | abgeleiteter Anker | `make docs-check` des Ziels |
|---|---|---|
| `### RQ-4 — Titel mit Abschluss ###` | `#rq-4--titel-mit-abschluss-` | grün — das Gate lässt die ATX-Abschlusszeichen ebenso stehen |
| `### RQ-5 — Titel mit Leerzeichen·␣␣␣` | `#rq-5--titel-mit-leerzeichen---` | **`anchor-missing`** |
| `### RQ-6 — A &amp; B` | `#rq-6--a-amp-b` | grün — die Entity wird nicht aufgelöst |
| `### RQ-7 — Autolink <https://example.invalid>` | `#rq-7--autolink-httpsexampleinvalid` | grün |
| `### RQ-8 — Titel *kursiv* hier` | `#rq-8--titel-kursiv-hier` | grün |
| Lauf des Erzeugers darüber | — | **Exit 0**, Meldung `0 ohne Verweis` |

Isolierte Gegenprobe allein mit der Leerzeichen-Überschrift: **beide** Fassungen
schreiben den Verweis und enden mit Exit 0; unsere meldet keinen Fall ohne Verweis, die
emittierte meldet `0 ohne Verweis`.

Weitere Läufe: `make help` des Ziels führt beide Einträge · der Spiegel-Lauf des
Erzeugers dieses Repos ist byte-gleich mit der committeten Sicht (die 18 geänderten
Zeilen sind nachgezogene `Ort`-Angaben, kein Handgriff) · `harness/README.md` auf eine
Formen-Liste durchsucht: **kein Treffer**.

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | HIGH | **Dritte Richtung gefunden — der HIGH bleibt offen.** Sie ist weder Zeichen (`slug_sicher`) noch Inline-Syntax (`titel_rein`), sondern **Whitespace-Normalisierung**: eine Überschrift mit Leerzeichen am Zeilenende ergibt `#rq-5--titel-mit-leerzeichen---`, das Gate trimmt und erwartet `#rq-5--titel-mit-leerzeichen`. Beide Wächter lassen sie durch — keine eckige Klammer, nur erlaubte Zeichen —, der Lauf endet mit Exit 0 und meldet `0 ohne Verweis`, und das `docs-check` des Ziels fällt mit `anchor-missing` auf der Datei, die das Werkzeug selbst geschrieben hat. Vier Gegenproben desselben Laufs fallen **nicht**: ATX-Abschluss, HTML-Entity, Autolink, Hervorhebung. Die Kalibrierung von Runde 2 ist damit bestätigt und die Lücke daneben gemessen. | `AGENTS.md` §3.7 („die Zusage auf das einschränken, was der Code hält") und §3.6 · `LH-FA-12` §Benannte Grenze | `internal/emit/templates/enforce/e2e-abdeckung.sh:145-166` (`titel_rein`), `:168-189` (`slug_fuer`), `:191-196` (`slug_sicher`), `:42-52` (die Zusage) · dieselbe Lage in `harness/tools/e2e-abdeckung.sh:138-166` | ja — reproduziert: Ziel-Spec um eine Überschrift mit drei Leerzeichen am Zeilenende ergänzt, `make e2e-abdeckung` EXIT 0, danach `make docs-check` EXIT 2 | abgeleiteter Anker wird geschrieben, ohne gegen die Zieldatei geprüft zu sein |
| R3-2 | MEDIUM | **Die Kalibrierung ist benannt, ihre Grenze nicht — und nicht an der Stelle, die sie braucht.** Der `titel_rein`-Block sagt „GEMESSEN, NICHT VERMUTET" und zählt auf, was fällt und was nicht; er sagt nicht, dass die Aufzählung am gemessenen Verhalten **eines** Doku-Gates hängt, das die emittierte Fassung nicht mitbringt, dass kein Lauf prüft, ob die Zeilen noch gelten, und wohin ein Fehlgriff fällt. Unsere Fassung trägt für ihre Hälfte einen Träger-Satz (`das Modul anchors von make docs-check prueft das Ergebnis`), die emittierte keinen. Die Zusage-Einschränkung im Kopf deckt genau eine Richtung — *„nicht, dass jede Kennung einen Verweis bekommt"* — und nicht die, die R3-1 misst: dass ein **geschriebener** Verweis daneben liegen kann. | `AGENTS.md` §3.7 (Grenze als Kommentar-Klasse) · `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Ein Gate ohne seine Grenze | `internal/emit/templates/enforce/e2e-abdeckung.sh:145-159` und `:42-52`; Vergleichsstelle `harness/tools/e2e-abdeckung.sh:124` | nein — kein Gate liest Kommentar-Prosa | Kalibrierung genannt, ihre Grenze und ihr Träger nicht |
| R3-3 | LOW | Der in diesem Commit geänderte Kommentar nennt `harness/README.md` als Ort, der die Formen „in derselben Gestalt" führt; dort steht keine solche Liste — gemessen: kein Treffer auf `Formen`, `Trockenlauf`, `wrapper`. Wer die Liste das nächste Mal erweitert, sucht an einem Ort, der sie nie trug. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `test/full-smoke-ausgang.bats:178-179` | nein | Kommentar nennt einen Ort, der die genannte Aussage nicht führt |
| R3-4 | INFO | Aus den Vorrunden unverändert offen und hier nicht adressiert (beide waren INFO): die §3-Tabelle des Plans nennt die inzwischen berührten Dateien `test/full-smoke-ausgang.bats`, `internal/emit/baumaussage_test.go`, `Makefile`, `internal/emit/makefile.go` und `harness/sensors/full-smoke.md` nicht vollständig; und die Zusage des Ziels über seine Abdeckungs-Sicht hat weiterhin nur einen Träger, den nichts von selbst ruft. | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice · `LH-FA-12` §Abgrenzung | Plan §3 gegen `git diff --stat fc611ea3..321210de` | nein | Plan-Tabelle nennt nicht jede berührte Datei |

### Was sich über die Runden zeigt — eine Beobachtung, kein eigener Befund

Drei Runden, drei Richtungen: Zeichen außerhalb der Lösch-Aufzählung (Runde 1) ·
Markdown-Inline-Syntax (Runde 2) · Whitespace-Normalisierung (Runde 3). Jede Runde
schließt eine **aufgezählte** Teilmenge, und jede Aufzählung ist an gemessenem
Gate-Verhalten kalibriert. Was über alle drei gleich bleibt: der abgeleitete Anker wird
gegen **keine** Eigenschaft der Datei geprüft, aus der er stammt — obwohl der Lauf diese
Datei ohnehin liest. Das ist die Beobachtung; welche Antwort sie verdient, entscheidet
der Implementer (Modul 10 §Was dieser Skill NICHT macht).

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| R2-2 (Kopf der emittierten Vorlage) | **erledigt für den gemeldeten Defekt** — der Kopf nennt jetzt drei Lagen für den Code-Span-Zweig, und die Zweig-Gründe des Codes stimmen damit überein. Was daneben fehlt, ist R3-2 und ein anderer Befund |
| R2-3 (Begründung des Zwillings) | **erledigt** — die Begründung sagt jetzt, was die Zeile tut: Gegenprobe über einen Namen ohne Ziffer, ausdrücklich **nicht** gegen einen leeren Index |
| R2-4 (`make help` außerhalb der Menge) | **erledigt** — der Aufruf führt und wertet seinen Exit-Code aus, liegt damit in der Abschnitts-Menge und ist als fünfte Form an drei Stellen genannt (Kopf von `harness/tools/full-smoke.sh`, `test/full-smoke-ausgang.bats`, `harness/sensors/full-smoke.md`); die vierte genannte Stelle trägt sie nicht (R3-3) |
| R2-5 (Vorbedingung des Test-Seams) | **erledigt** — die Vorbedingung steht am Seam und benennt beide Basen (Arbeitsverzeichnis fürs Nachschlagen, Ort der Sicht für den Link) sowie die Aufrufform, die sie voraussetzt |
| Kopplung nach der Aufteilung (Frage 3) | geprüft, ohne Befund — der Kopplungs-Fall hält jetzt `titel_fuer` (bis auf die **eine** gezählte `spec_da`-Zeile), `slug_fuer`, `titel_rein` und `slug_sicher` byte-gleich, dazu die drei Zeichen-Mengen, jeweils mit einer Mindest-Zeilenzahl gegen den leeren Vergleich. Die Trennlinie ist weiterhin **eine** Regel — „unsere bricht ab, die emittierte setzt einen Code-Span" —, jetzt an drei Zweigen ausgesprochen; die gekoppelten Funktionen sind identisch, die Zweig-Struktur ist es nicht und muss es nicht sein |
| `titel_rein` in der Rot-Richtung | geprüft, ohne Befund — Link und Bild bekommen den Code-Span, der Hinweis nennt die Rohzeile, der Zähler nennt `2 ohne Verweis`; unsere Fassung bricht über derselben Lage ab |
| `titel_rein` in der Grün-Richtung | geprüft, ohne Befund — HTML im Titel bleibt ein Verweis, und der bats-Fall führt ihn ausdrücklich als Prüfstein gegen eine zu breite Regel; meine eigene Messung bestätigt ihn (HTML, Entity, Autolink, Hervorhebung, ATX-Abschluss bleiben grün) |
| Committete Sicht dieses Repos | geprüft, ohne Befund — der Spiegel-Lauf über `321210de` ist byte-gleich; die 18 geänderten Zeilen sind nachgezogene Ortsangaben |
| `AGENTS.md` §3.2 | geprüft, ohne Befund — keine Suppression im Diff |
| `AGENTS.md` §3.4/§3.5/§3.8/§3.10/§3.11 | geprüft, ohne Befund |
| `LH-QA-01` / `kein Gate` | geprüft, ohne Befund — unverändert an keiner Gate-Kette des Ziels; die neue Index-Prüfung hängt in Stufe 18 von `make full-smoke` |
| Emittierte Ablage, Klassen, Marker | geprüft, ohne Befund — konvergent, Marker-Liste unberührt, keine neue Abhängigkeit; der Modus-Wechsel von `harness/tools/full-smoke.sh` auf `0755` betrifft ein Skript dieses Repos, nicht die Emission |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** abgeleiteter Anker wird geschrieben, ohne gegen die
Zieldatei geprüft zu sein · Kalibrierung genannt, ihre Grenze und ihr Träger nicht ·
Kommentar nennt einen Ort, der die genannte Aussage nicht führt · Plan-Tabelle nennt
nicht jede berührte Datei

*Die erste Klasse ist in diesem Slice nun **dreimal** aufgetreten — dieselbe Klasse,
jedes Mal eine andere Ursache. Ein Vorgang zählt einmal; die Zuordnung zum Register ist
Sache der Closure, nicht dieses Reports.*

## Verdikt

**Merge-blockierend:** ja — R3-1 (HIGH) und R3-2.

**Ist der Weg zu Verifikation und Closure frei? Nein.** Die gestellte Prüffrage war, ob
es eine dritte Richtung gibt; es gibt sie, sie ist gemessen, und ihr Ausgang ist
unverändert der aus Runde 1: ein Lauf mit Exit 0 und der Meldung `0 ohne Verweis`, und
danach ein rotes `docs-check` im Baum des Adopters auf einer Datei, die das Werkzeug
geschrieben hat. Der Auslöser ist diesmal Whitespace am Zeilenende einer Überschrift —
billiger zu treffen als die zwei Ursachen davor.

Alles andere aus Runde 2 ist zu, und zwar sauber: der Kopf nennt seine drei Lagen, die
Begründung des Zwillings sagt jetzt, was die Zeile tut, der Hilfe-Aufruf steht in der
Menge, über der die Abdeckungs-Zusage gilt, die Seam-Vorbedingung steht am Seam, und die
Kopplung hält nach der Aufteilung mehr als vorher — vier Funktionen statt einer, die
Trennlinie weiterhin eine und ausdrücklich gezählt. Die Klassen-Messung des Implementers
hält meiner Gegenprobe stand; HTML als Prüfstein ist richtig gesetzt.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei
Plan-Defekt); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von
dort in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** (Audit: dieser Diff,
dieser Skill, dieses Modell, dieses Verdikt) — er wird über Läufe hinweg nicht wieder
gelesen, und muss es nicht. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

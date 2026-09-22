# ADR-0061: Ein Review-Report bekommt beim Archivieren einen Stub — die eingehende Adresse bleibt gültig, statt gebrochen oder stummgeschaltet zu werden

**Status:** Proposed

**Datum:** 2026-09-22

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — der Träger; Festlegung 1
macht die Archivierung zum Unterkommando des Produkt-Binärs, Festlegung 3 die Stub-Form der
Slice-/Welle-Dateien zur Ausfüll-Vorlage; Abnahme-Kriterium 1 misst genau den Hänger-Fall, den
diese Entscheidung schließt),
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) (**Accepted** — die Präzedenz für ein
baum-weites `ignore-refs`-Ventil und seine enge Aufnahme-Grenze; diese Entscheidung braucht das
Ventil für Report-Ziele **nicht** und nennt den Grund),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted** — Festlegung 4
hält `haenger` als Sperre des ersten Archiv-Moves; diese Entscheidung löst den Report-Anteil dieser
Sperre auf),
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — trennt die eigene
Frage ausdrücklich von dieser: *„hier bricht ein Verweis, weil sein Ziel ersatzlos verschwindet;
[in ADR-0042] wird ein Artefakt geschrieben, weil sein Ziel umzieht"*; keine ihrer fünf
Festlegungen wird berührt),
[`AGENTS.md`](../../../AGENTS.md) §3.4 (Accepted-ADRs unveränderlich — einer der neun Fundorte, die
Alternative *auflösen* träfe), §3.5 (Gate-Senkung nur per ADR — geprüft und **nicht** gebraucht,
weil kein Referenz-Ventil entsteht), §3.8 (Hard Rules und Adaptions-Block schreibt der Architect —
bindet den Eintrag, den diese Entscheidung auslöst),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
dieses Repos hält den Status eines Artefakts gegen die Form seiner Adressen — die Lücke wird
benannt, nicht geschlossen),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`MR-041`](../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
(Referenz statt Kopie für wiederkehrende Ausfüll-Vorlagen — der Grund, warum ein Stub-Template
dieser Klasse normalerweise vendored wäre, und warum das hier nicht so geht),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Sie entscheidet, was mit einer Zeitdokument-Klasse
beim Archivieren geschieht, nicht über eine Anforderung oder eine technische Festlegung.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

### Was die Entscheidung auslöst

Der Slice-Plan
[`slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang`](../planning/in-progress/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md)
stellt eine reine Architektur-Frage, die die adoptierte Baseline `v6.9.0` bereits einmal
entschieden hat — mit einer Annahme, die der Bestand dieses Repos widerlegt.
`modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4, verbatim: *„Review-Reports bekommen
keinen Stub; sie haben keine Identität jenseits ihres Slice."* Für Slices und Wellen gilt das
Gegenteil ausdrücklich: Ihr Stub bleibt liegen und *„lässt eingehende Verweise gültig"*.

Der Bestand widerspricht der Report-Hälfte messbar:

```sh
for r in docs/reviews/*.md; do rb="${r##*/}"; \
  git grep -lF -e "]($rb)" -- ':!.harness/baseline' | grep -vxF "$r" | sed "s|.*|$rb|"; \
done | sort -u | wc -l     # 144 Report-Dateien sind Ziel eines Links
ls docs/reviews/*.md | wc -l   # 345
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). 42 % des Report-Bestands sind Ziel eines eingehenden Links — die Voraussetzung der
Ziel-Form (*niemand zeigt einzeln auf einen Report*) trägt hier nicht.

**Der erste Archiv-Lauf bricht daran, gemessen und nicht erwartet.** Die Vorschau
(`make host-bin`, dann `archive-welle --vorschau welle-13`) meldet die Sperre `[haenger]` mit
**44** Fundstellen — Quellen, die den Lauf überleben, während ihr Ziel im Archiv verschwindet:

```text
#  22 docs/reviews (Reports, die diese Welle nicht einsammelt)
#  11 docs/plan/planning/open (offene Slice-Pläne)
#   3 docs/plan/adr (zwei Dateien, beide Accepted)
#   2 harness/conventions · 2 docs/plan/planning/done · 2 docs/plan/carveouts/done
#   1 spec/lastenheft.md (Rang 1) · 1 observations/…/evidence (ab Merge eingefroren)
```

Diese Entscheidung beantwortet den Report-**Ziel**-Anteil dieser Sperre — unabhängig davon, in
welchem Baum die referenzierende Quelle liegt. Was mit Slice-/Welle-**Zielen** derselben Sperre
geschieht (der Pfad-Nachzug bei ihrem Umzug von flach nach `done/<welle-id>/`), ist bereits
entschieden ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)) und nicht Gegenstand
hier — jene Entscheidung nennt den Unterschied selbst: *„hier bricht ein Verweis, weil sein Ziel
ersatzlos verschwindet"* (diese Frage) gegen *„hier wird ein Artefakt geschrieben, weil sein Ziel
umzieht"* (ADR-0042).

### Vier Alternativen, mit Preis

**a) Auflösen** — jeden der 144 Verweise umschreiben oder entfernen. **Scheitert an neun der 44
Fundstellen**, die in Artefakten liegen, die niemand mehr überschreibt oder die über dem Plan
rangieren: zwei `Accepted`-ADRs (3 Fundstellen), ein aufgelöster Carveout (2), ein append-only
`harness/conventions/`-Eintrag (2), eine ab Merge eingefrorene Evidence-Datei (1) und
[`spec/lastenheft.md`](../../../spec/lastenheft.md) selbst (1), Rang 1 der Source Precedence. Für
sie hieße *„auflösen"*: das eingefrorene Artefakt **schreiben** — genau das, was
[`AGENTS.md`](../../../AGENTS.md) §3.4 und §3.11 verbieten. Notiert im Register als
`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (12× zum Zeitpunkt der Slice-Planung).
Selbst für die übrigen 35 Fundstellen bliebe es ein Urteil je Stelle über 144 Dateien — keine davon
mechanisch.

**b) Stub entgegen dem Wortlaut der Ziel-Form** — der Report bekommt beim Archivieren, wie Slice
und Welle, einen gekürzten Rest an **seinem heutigen Pfad** `docs/reviews/<datei>.md`. Widerspricht
der Baseline-Aussage direkt und braucht einen Adaptions-Block-Eintrag nach
[`AGENTS.md`](../../../AGENTS.md) §3.8 — keine unerklärte Abweichung
([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).

**c) Referenz-Ventil im Doku-Gate** (`.d-check.yml` `ignore-refs`) — macht den Verweis gate-sicher
und unauflösbar. Die Präzedenz [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) zieht
für dieselbe Apparatur eine enge Aufnahme-Grenze — ein benanntes Paar, kein Verzeichnis. Ein Ventil
über `docs/reviews/**` schaltete **jede künftige tote Report-Adresse** stumm, nicht nur die
archivierten ([`AGENTS.md`](../../../AGENTS.md) §3.11, letzter Absatz) — eine Senkung nach §3.5,
die eine eigene Begründungslast trägt. Notiert im Register als
`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse` (3×).

**d) Report-Bestand von der Archivierung ausnehmen** — `docs/reviews/` wird nie archiviert, bleibt
für immer flach. Die Archivierung erreicht ihr Ziel (Repo-Verschlankung,
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)) für die mengenmäßig größte
Zeitdokument-Klasse nie — heute **345** Dateien und wachsend.

### Was heute gemessen ist, und warum es b) trägt

**1. Der Träger löscht Reports heute ersatzlos.** `internal/archive/anwenden.go` sammelt die
Reviews einer Welle in `b.Reviews` und entfernt sie vollständig aus dem Arbeitsbaum
(`g.Rm(b.Reviews)`), ohne einen Rest an ihrer Stelle zu hinterlassen — anders als bei Slice und
Welle, deren Stub genau an ihrer alten Adresse liegen bleibt.

**2. Ein Stub am unveränderten Pfad braucht keinen einzigen der 144 Verweise anzufassen.** Anders
als bei Slice/Welle-Stubs, die beim Archivieren von `docs/plan/planning/done/` nach
`docs/plan/planning/done/<welle-id>/` **umziehen** und darum einen Pfad-Nachzug brauchen
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)), liegen Reports heute schon flach
unter `docs/reviews/` und bleiben es: Der Stub tritt an dieselbe Adresse, jeder bestehende Link —
in einer Nachbar-Review, einem offenen Slice-Plan, einer `Accepted`-ADR, `spec/lastenheft.md` —
löst unverändert auf. Für die neun Fundstellen in eingefrorenen/rang-höheren Artefakten (Alternative
a's Preis) heißt das: **kein Byte wird dort angefasst**, weil nichts nachgezogen werden muss.

**3. Kein Referenz-Ventil wird gebraucht.** Löst jede Adresse weiterhin auf, entfällt der Grund für
Alternative c) vollständig — kein `ignore-refs`-Paar, keine Senkung nach §3.5, keine
Auskunftsunfähigkeit.

**4. Der Anker-Fall, der Reste-Content am ehesten bräche, ist heute leer.**

```sh
git grep -ohE '\]\([^)]*docs/reviews/[^)]*\.md#[^)]*\)' -- '*.md' ':!.harness/baseline' | wc -l   # 0
```

**Kein Erwartungswert** — die Zahl wandert mit dem Bestand. Kein einziger Link im Repo zeigt heute
mit einem Anker-Fragment auf einen Abschnitt eines Review-Reports; ein gekürzter Stub bräche darum
keinen bestehenden Verweis dieser Form. Dieselbe Lücke — Zustandssatz neben der Adresse, Operand in
einem Mess-Kommando — bleibt offen, wie sie es für Slice-Stubs bereits ist
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4): benannt, nicht
geschlossen, und diese Entscheidung erweitert sie nicht.

**5. 122 der 144 Fundstellen sind Report-zu-Report-Verweise** — bereits von
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) §Kontext gemessen (*„Ein Wächter, der
`docs/reviews/**` aus seinem Suchraum nähme, wäre für 122 Report-Dateien blind, die heute auf einen
anderen Report zeigen"*) und der Grund, warum jene Entscheidung `docs/reviews/**` bewusst **nicht**
aus dem Verweis-Suchraum nimmt. Ein Stub am unveränderten Pfad ist die Fortsetzung derselben Linie,
nicht ihr Bruch.

**6. Der Preis ist keine neue Fähigkeitsfläche, sondern eine vierte Anwendung einer bestehenden.**
Slice und Welle bekommen ihren Stub bereits; ein Report-Stub ist dieselbe Mechanik auf eine vierte
Artefaktklasse angewandt — kein neuer Vertriebskanal, kein neues Gate, keine neue Prüfungsart.

## Entscheidung

**Wir wählen Alternative b): Ein Review-Report bekommt beim Archivieren einen gekürzten Stub an
seinem unveränderten Pfad `docs/reviews/<datei>.md` — Identität, Archiv-Zeiger, Zustand — statt
gelöscht zu werden. Vier Festlegungen.**

**1. Der Stub liegt an derselben Adresse, nicht in einem Wellen-Unterverzeichnis.** Anders als
Slice- und Welle-Dateien (die von flach nach `done/<welle-id>/` umziehen) bleibt ein
Report-Stub dort, wo der Report heute liegt: `docs/reviews/<datei>.md`. Das ist der tragende Punkt
dieser Entscheidung — jede bestehende und jede künftige Adresse auf einen archivierten Report
bleibt ohne Nachzug gültig.

**2. Der Stub-Inhalt ist minimal: Überschrift, Archiv-Zeiger, Zustand.** Dieselbe Form wie bei
Slice/Welle
([`archiv-stub-slice.template.md`](../../../.harness/baseline/v6.9.0/templates/docs/plan/planning/archiv-stub-slice.template.md)),
auf einen Review-Report angewandt. Da die vendored Baseline keine Vorlage für diese Artefaktklasse
führt (sie sieht die Klasse *„Report-Stub"* nicht vor), entsteht die Form **repo-eigen** unter
`docs/plan/planning/` als Nachbar-Vorlage der beiden vorhandenen — kein Bruch mit
[`MR-041`](../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline):
jene Regel bindet **wiederkehrende, vendored** Vorlagen; für eine Form, die der Kurs nicht führt,
gibt es nichts zu referenzieren.

**3. `internal/archive/` bekommt die Fähigkeit als Erweiterung, nicht als neuen Mechanismus.**
Anstelle von `g.Rm(b.Reviews)` schreibt der Lauf je Review einen Stub an unveränderter Adresse und
staged ihn; das Archiv-Zip nimmt den vollen Report-Inhalt wie bisher auf. Implementer-Arbeit,
eigener Slice (siehe unten).

**4. Was diese Entscheidung nicht löst, bleibt benannt, nicht geschlossen** — dieselben drei
Gegenformen, die [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4 für
Slice-Stubs führt, gelten unverändert auch für Report-Stubs: ein Zustandssatz neben einer Adresse
(*„der Report ist 40 Zeilen lang"*), ein Operand in einem Mess-Kommando, ein Abschnitts-Anker auf
einen künftig gekürzten Stub (heute leer, Messung 4). Kein Sensor hält das; Träger bleibt der Lauf,
der schreibt.

### Was diese Entscheidung nicht tut

- **Kein Referenz-Ventil.** `.d-check.yml` bekommt keinen neuen `ignore-refs`-Eintrag; die drei aus
  [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) und die zwei aus
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) bleiben unverändert die einzigen.
- **Kein `Supersedes`.** [ADR-0033](0033-wellen-archivierung-als-unterkommando.md),
  [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md),
  [ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) und
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) bleiben unverändert wahr; keine
  ihrer Festlegungen wird berührt.
- **Sie baut nichts.** Stub-Vorlage, Go-Code und Tests sind Implementer-Artefakte
  ([`AGENTS.md`](../../../AGENTS.md) §3.8).
- **Sie schreibt kein einziges der 144 bestehenden Verweise um.** Das ist der Kern des Preises:
  Alternative b) braucht — anders als a) — keine Umsetzung im referenzierenden Bestand.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Auflösen: alle 144 Verweise umschreiben/entfernen | Kein zusätzliches Artefakt, keine Adaption | Scheitert an 9 Fundstellen in `Accepted`-ADRs, einem aufgelösten Carveout, einem append-only-Konventionseintrag, einer eingefrorenen Evidence-Datei und `spec/lastenheft.md` — dort hieße es, das eingefrorene Artefakt zu schreiben, verboten nach [`AGENTS.md`](../../../AGENTS.md) §3.4/§3.11. Für die übrigen 135 ein Urteil je Fundstelle ohne Match |
| **B — Stub am unveränderten Pfad (gewählt)** | Löst alle 44 Hänger-Fundstellen des Report-Anteils ohne einen der 144 Verweise anzufassen — auch die neun in eingefrorenen Artefakten bleiben unberührt, weil nichts nachgezogen werden muss; kein Ventil, keine Senkung nach §3.5; vierte Anwendung einer bereits etablierten Mechanik (Slice-/Welle-Stub); 0 Anker-Links gemessen, die brächen | Widerspricht dem Wortlaut der Ziel-Form direkt, braucht einen Adaptions-Block-Eintrag; die Stub-Vorlage ist repo-eigen statt vendored, weil der Kurs die Klasse nicht führt; drei Gegenformen (Zustandssatz, Mess-Operand, künftiger Anker) bleiben ungelöst, wie bei Slice-Stubs bereits |
| C — Referenz-Ventil (`ignore-refs` über `docs/reviews/**`) | Macht den Verweis gate-sicher ohne Umsetzung im Bestand | Nimmt der Adresse die Auskunftsfähigkeit dauerhaft; ein Ventil über ein ganzes Verzeichnis ist breiter als jedes der fünf bestehenden Paare (die je ein benanntes Ziel tragen) und schaltete jede künftige tote Report-Adresse mit stumm, nicht nur die archivierten — Senkung nach §3.5 mit eigener, hier ungedeckter Begründungslast |
| D — `docs/reviews/` nie archivieren | Kein Eingriff in `internal/archive/`, kein neuer Adaptions-Eintrag | Die Archivierung erreicht ihr Ziel für die größte Zeitdokument-Klasse (345 Dateien, wachsend) nie — [ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) bliebe für `docs/reviews/` dauerhaft ohne Wirkung |

## Konsequenzen

- **Positiv:** Der Report-Anteil der `[haenger]`-Sperre entfällt vollständig, ohne dass ein
  bestehender Verweis umgeschrieben wird — der teuerste Teil von Alternative a) entfällt ersatzlos.
- **Positiv:** Kein neues `ignore-refs`-Paar, keine Senkung nach §3.5, keine dauerhaft
  auskunftsunfähige Adresse.
- **Positiv:** Konsistente Mechanik — Slice, Welle und jetzt Report tragen dasselbe Prinzip
  (*„eingehende Verweise bleiben gültig"*).
- **Negativ:** Der Report-Bestand wird durch den Stub **nicht** kleiner als heute an derjenigen
  Stelle, an der er liegt — die Verschlankung wirkt im Archiv-Zip, nicht im Arbeitsbaum-Zähler pro
  Datei; `docs/reviews/` behält so viele Dateien, wie es je hatte.
- **Negativ:** Drei Gegenformen bleiben offen (wie bei Slice-Stubs): ein Zustandssatz neben der
  Adresse, ein Operand in einem Mess-Kommando, ein künftiger Abschnitts-Anker auf einen gekürzten
  Stub. Kein Sensor hält das.
- **Negativ:** Die Stub-Vorlage ist repo-eigen, nicht vendored — sie zieht bei einem künftigen
  Baseline-Sprung nicht automatisch nach, falls der Kurs die Klasse je aufnimmt.
- **Folgepflicht (Implementer):** `internal/archive/` bekommt die Stub-Emission für Reviews
  (Ablösung von `g.Rm(b.Reviews)`), eine repo-eigene Stub-Vorlage, und die drei
  Abnahme-Kriterien von [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) bleiben erhalten
  — Kriterium 1 (*„Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden
  Review-Report schließt `docs/reviews/**` nicht aus"*) verliert mit dieser Entscheidung seinen
  Gegenstand für Report-**Ziele** und bleibt für Slice-/Welle-Ziele unverändert bestehen. Eigener
  Folge-Slice (Titel-Vorschlag unten), **kein** Nachzug der 144 bestehenden Verweise.
- **Folgepflicht (Architect, in diesem Lauf erledigt):** Adaptions-Block-Eintrag für die Abweichung
  von der Ziel-Form.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test (`internal/archive`) | Ein archivierter Review hinterlässt eine Stub-Datei an seinem ursprünglichen Pfad statt gelöscht zu werden; der Stub trägt Archiv-Zeiger und Zustand | `make test` |
| d-check (`links`) | Ein bestehender Verweis auf einen archivierten Report löst nach dem Archiv-Move weiterhin auf (Stub-Adresse = Alt-Adresse) | `make docs-check` |
| Go-Test (`internal/archive` `--vorschau`) | Die `[haenger]`-Sperre führt nach der Umsetzung keine Report-Ziele mehr | `make test` |
| — | Die drei Gegenformen aus §Entscheidung Festlegung 4 (Zustandssatz, Mess-Operand, künftiger Anker) — kein Sensor | — |

## Re-Evaluierungs-Trigger

- **Wenn ein Anker-Link auf einen Review-Report-Abschnitt entsteht** *(beobachtbar am Kommando aus
  §Was heute gemessen ist, Punkt 4)*: Dann trifft die dritte Gegenform real, und der Preis dieser
  Entscheidung ist neu zu beziffern.
- **Wenn die adoptierte Baseline eine eigene Stub-Form für Review-Reports einführt**: Dann prüft
  ein Re-Baseline-Lauf, ob die vendored Form die repo-eigene Vorlage aus Festlegung 2 ablöst
  ([`MR-041`](../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)-Prinzip).
- **Wenn ein vierter Baum sein Ziel ersatzlos verlieren soll** (eine weitere Zeitdokument-Klasse
  ohne Stub-Mechanik bekäme dieselbe Frage): Diese Entscheidung ist keine Vorlage dafür — eine
  eigene ADR prüft die Klasse neu, wie [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md)
  Festlegung 3 es für sein Ventil verlangt.
- **Wenn der Report-Bestand über eine Größenordnung wächst, die die Stub-Form selbst in Frage
  stellt** (etwa: der Stub-Overhead wird gegenüber dem archivierten Inhalt relevant): permanent bis
  dahin, kein Datum.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-22 | **Proposed** | Architect-Lauf zu `slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang`; Acceptance-Trigger: eine Reviewer-Runde prüft diese Entscheidung gegen [ADR-0033](0033-wellen-archivierung-als-unterkommando.md), [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) und [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) auf Konsistenz; ihr Report liegt ohne blockierenden Befund in `docs/reviews/` (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz"*) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0061` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

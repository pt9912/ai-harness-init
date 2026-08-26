# Slice slice-107: Was von einem Argument-Wert wandert, sagt eine Quelle — der Inhalts-Hash bekommt seinen Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Norm-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Widerspruch, ein Ausgang; einzeln
lieferbar, und kein zweiter Slice wartet auf ihn. **(2) Gemeinsames Closure-Kriterium?** Nein —
jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?**
Reaktiv: ein gemessener Widerspruch zwischen zwei *Accepted*-Entscheidungen, der Anforderung auf
Rang 1 und dem laufenden Träger (§1). Kein Fähigkeits-Sprung — das Werkzeug lernt nichts, was es
nicht schon kann. **Auch nicht in [welle-12](../welle-12-erfassungsschicht-emittieren.md):** deren
Abdeckungs-Tabelle führt die Zeile *„Redaktion — was zugesagt ist und was nicht"* als von
[slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md) geliefert, und
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) nennt den
Fingerabdruck selbst als eine der Ableitungen — das Kriterium ist in **jedem** Ausgang erfüllt.
Dieser Slice füllt keine Zelle und leert keine. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: beide — und genau das ist der Gegenstand.** Die zwei Entscheidungssätze reden über die
**emittierte** Ebene, gemessen wird der **eine** Träger, der auf beiden läuft: das Produkt-Binär
wird in den Zustands-Bereich des Ziels kopiert
([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1),
also erfasst dort dieselbe Funktion wie hier. Eine ebenen-verschiedene Schärfe wäre ein neues
Verhalten desselben Binärs, kein Lese-Unterschied.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (**Rang 1**,
§Redaktion: *„von Argument-Werten wandert nie der Inhalt, sondern eine Ableitung (Pfad, Länge,
Fingerabdruck)"* — die Anforderung gilt der emittierten Ebene und nennt ihn),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2 und die
ebenen-abhängige Schärfe daneben: *„Für alles Emittierte gilt die Tabelle unverkürzt und ohne
Inhalts-Hash"*),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 6 führt den Adopter-Vertrag mit *„abgeleitete Argument-Werte ohne Inhalts-Hash"*),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (eine *Accepted*-ADR wird nicht überschrieben; eine
Korrektur ist eine neue Entscheidung — daraus folgt die Form des Ausgangs, nicht sein Inhalt),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 und
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (die Quelle, die den **Architect** für den
Entscheidungstext benennt — dieser Slice liefert den Termin, nicht den Text),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(*„weder ADR noch Slice dürfen `LH-*` je ändern"* — die Grenze, an der einer der drei Ausgänge
teurer ist, als er aussieht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie liefert),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-26.

---

## 1. Ziel

**Was von einem Argument-Wert in eine erfasste Zeile wandert, steht in genau einer geltenden
Fassung — und wo zwei *Accepted*-Entscheidungen etwas anderes sagen als die Anforderung auf Rang 1
und der laufende Träger, trägt der Widerspruch einen Ausgang statt einer Nennung.**

### Die Ausgangslage: vier Quellen, zwei Aussagen

Die Eigenschaft, über die gezählt wird: *eine Stelle, die sagt, ob von einem Schreib-Werkzeug ein
Inhalts-Hash in die Zeile wandert.* Jede Zahl wandert mit ihrem Bestand und ist **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

| Quelle | Rang | was sie sagt | Kommando |
|---|---|---|---|
| [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Redaktion | **1** | die Ableitung ist *„(Pfad, Länge, Fingerabdruck)"* — für die **emittierte** Ebene, denn die ist der Gegenstand der Anforderung | `sed -n '/^### .* — Erfassungsschicht emittieren$/,/^## 4\./p' spec/lastenheft.md \| grep -c 'Fingerabdruck'` → **1** |
| [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 | Entscheidung | *„Pfad + Länge; **im Repo zusätzlich** ein Inhalts-Hash"*, und daneben *„Für alles Emittierte gilt die Tabelle unverkürzt und **ohne** Inhalts-Hash"* | `grep -c 'ohne Inhalts-Hash' docs/plan/adr/0011-telemetrie-erfassung-policy.md` → **1** |
| [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6 | Entscheidung | der Adopter-Vertrag führt *„abgeleitete Argument-Werte **ohne** Inhalts-Hash"* | `grep -c 'Inhalts-Hash' docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md` → **1** |
| der laufende Träger | Code | der Fingerabdruck wird für Schreib-Werkzeuge **unbedingt** gesetzt; eine Ebenen-Unterscheidung gibt es nicht | `grep -n 'classFileWrite' internal/span/emit.go` → Zeile **135**; `grep -c 'Ebene' internal/span/emit.go` → **0** |

**Und die Zeile trägt ihn wirklich, nicht nur der Code.** Über dem Bestand dieses Repos:
`grep -l 'sha256_16' .harness/state/spans/*.jsonl | wc -l` → **188** von
`ls -1 .harness/state/spans/*.jsonl | wc -l` → **221** Strom-Dateien. Im gebootstrappten Ziel
steht das Feld im Ausdruck des Trägers über sein eigenes Schema:
`b=<scratch>/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); grep -c 'sha256_16' "$p/harness/erfassung-feldliste.md"`
→ **1** (der Träger stammt aus `make artifact DEST=<scratch>/bin`, Docker-only). Damit ist der
Widerspruch nicht papieren: **er steht seit
[slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md) geschrieben im Repo
eines Adopters.**

### Warum das nicht durch Lesen aufzulösen ist

Die naheliegende Lesart — *„die Schärfe ist je Ebene verschieden, und im Repo ist der Hash
erlaubt"* — verlangt, dass der Träger die Ebenen unterscheidet. Er tut es nicht (Kommando oben,
**0**), und er **kann** es nicht ohne Entscheidung: das emittierte Programm ist eine **Kopie
desselben Binärs** ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 1). Eine Unterscheidung wäre ein Laufzeit-Schalter — also ein neues Verhalten, über das
eine Entscheidung zu treffen ist, und zwar eine, die
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 1
berührt (*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"* — hier in der
Gegenrichtung: der Dogfood führte dann etwas, das das Ziel nicht führt, und belegte es nicht mehr).

### Die drei Ausgänge — und warum einer teurer ist, als er aussieht

- **(a) Eine neue Entscheidung zieht die zwei Sätze auf Rang 1 nach.** Die zwei *Accepted*-ADRs
  bleiben unangetastet; eine Korrektur entsteht als neue Entscheidung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
- **(b) Die Erfassung ändert sich — der Fingerabdruck fällt.** **Dieser Ausgang steht einem ADR
  nicht offen:**
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) nennt ihn auf
  Rang 1, und *„weder ADR noch Slice dürfen `LH-*` je ändern"*
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  adoptierter Wortlaut). Vor ihm liegt ein Change Request, dessen annehmender Akt die
  Nutzer-Entscheidung ist und der dem umsetzenden Slice **vorausgeht** (ebenda, Setzung 1/2).
- **(c) Abgelehnt mit Grund.** Eine Lesart löst den Widerspruch auf — dann ist die Lesart der
  Ausgang, und sie steht dort, wo der nächste Lauf sie findet.

**Was dieser Slice ausdrücklich nicht tut: den Entscheidungstext vorwegnehmen.** Den schreibt der
Architect ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1;
[`AGENTS.md`](../../../../AGENTS.md) §3.8 zitiert dafür das Regelwerk: *„ADR-Änderung: Architect
schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*). Dieser Slice liefert
den **Termin** und die Kommandos, an denen der Ausgang messbar ist.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Der Widerspruch trägt genau einen der drei Ausgänge aus §1, und der Ausgang steht
      dort, wo ihn der nächste Lauf findet.** Bei (a) und (b) im Entscheidungs-Stratum, bei (c) in
      §7 dieses Slice — nie in einer geschlossenen Datei unter `done/`.
      **Kein Kommando färbt „der Widerspruch hat einen Ausgang" rot, und das ist der Befund, keine
      Vertagung.** Die vier Quellen sind gezählt (§1); die Wahl zwischen ihnen ist ein Urteil über
      Fließtext, kein Muster — dieselbe Absage, die
      [slice-101](slice-101-norm-postens-bekommen-einen-termin.md) §1 ihrem Weg (C) erteilt. Diese
      Hälfte trägt das Review. Was **je Ausgang** messbar ist, steht in DoD (2).
- [ ] **(2) Der gewählte Ausgang ist am lebenden Artefakt messbar — mit dem Kommando, das heute
      den alten Wert liefert.** Für **(a)**: `grep -rl 'Inhalts-Hash' docs/plan/adr/*.md | wc -l` →
      heute **2**; die neue Entscheidung ist die dritte Datei und nennt beide abgelösten Sätze.
      Für **(b)**: `grep -c 'sha256_16' "$p/harness/erfassung-feldliste.md"` am frisch
      gebootstrappten Ziel → heute **1**, danach **0**, und
      `grep -c 'classFileWrite' internal/span/emit.go` bewegt sich mit. Für **(c)** bewegt sich
      **kein** Wert — dann sagt die Closure-Notiz ausdrücklich, dass hier **nichts** gemessen
      wurde, statt das Ausbleiben als Erfolg zu lesen.
- [ ] **(3) Die zwei *Accepted*-Entscheidungen bleiben unangetastet.** Eine Korrektur entsteht als
      neue Entscheidung, nicht durch Überschreiben
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
      **Rot:** `git diff --stat <Basis> -- docs/plan/adr/0011-telemetrie-erfassung-policy.md docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
      liefert eine nicht-leere Ausgabe.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag. **Der Doku-Punkt
ist bei Ausgang (b) nicht leer:** das emittierte Dokument ist ein Adopter-Vertrag, und seine
Feldzeile fällt mit der Erfassung.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr`](../../adr) | **neu**, soweit Ausgang (a) oder (b) | die Korrektur einer *Accepted*-Entscheidung ist eine neue Entscheidung ([`AGENTS.md`](../../../../AGENTS.md) §3.4); ihr Text ist Architect-Arbeit ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Rang 1 nennt den Fingerabdruck; keine interne Quelle ändert `LH-*` ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)). Verlangt der Lauf Ausgang (b), greift die Rückführung aus §4 |
| [`internal/span/emit.go`](../../../../internal/span/emit.go) | **unverändert**, außer bei Ausgang (b) | der Träger tut heute, was Rang 1 sagt; gemessen wird die Aussage über ihn, nicht sein Verhalten |
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go) | **unverändert**, außer bei Ausgang (b) | fällt das Feld, fällt sein Eintrag — und zwar erzwungen: [slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md) hat die zwei Richtungen so gebaut, dass ein Eintrag ohne Feld die Erzeugung abbricht. Hier ist der konstruktive Ausschluss der Drift zum ersten Mal ein Werkzeug und keine Zusage |
| `docs/plan/planning/done/` | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich); ein Ausgang, der als Nachtrag in eine geschlossene Datei geschrieben wird, steht wieder an dem Ort, den kein Lauf aufschlägt |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Eine Frage gehört vor den Entscheidungstext, nicht in ihn:** *Gilt der Widerspruch nur dem
Fingerabdruck, oder derselben Achse insgesamt?* Dieselbe Tabelle in
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 führt neben dem Hash die
**Länge** und das **erste Token** — Ableitungen, die derselbe Träger ebenfalls schreibt:
`grep -lE '"(bytes|program|argc)":' .harness/state/spans/*.jsonl | wc -l` → **211** von **221**
Strom-Dateien führen mindestens eine davon, gegen **188** für den Fingerabdruck (§1). Die zwei
Sätze der Entscheidungen nehmen sie **nicht** aus; nur der Hash ist ausdrücklich genannt. Trifft
die Antwort mehr als eine Zeile, ist der
Gegenstand ein Durchgang über die Tabelle und nicht ein Satz — dann greift die Rückführung aus §4.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit — und das ist
der Termin, den dieser Slice trägt.** Alle vier Quellen liegen im Baum, der Widerspruch ist über
ihnen gemessen (§1), und keine Vorarbeit eines anderen Slice fehlt. Er wartet insbesondere **nicht**
auf die Closure von [welle-12](../welle-12-erfassungsschicht-emittieren.md): das Kriterium
*„Redaktion"* ist in jedem der drei Ausgänge erfüllt.

**Was dieser Slice ausdrücklich nicht ist: eine Nennung.** Die Form *„Träger: der Architect"* ist
in diesem Repo gemessen vergeben und nicht eingelöst —
`git grep -l '^\*\*Träger: der Architect' -- 'docs/plan/planning/done/*.md' | wc -l` → **3**
([slice-101](slice-101-norm-postens-bekommen-einen-termin.md) §1, mit derselben Messung). Was
fehlt, ist nicht die Zuständigkeit, sondern der Anlass zu laufen; in diesem Repo entsteht ein
Anlass durch einen Schnitt.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn die Frage aus §3 mehr als den Fingerabdruck trifft.
  Dann ist der Gegenstand ein Durchgang über die Ableitungs-Tabelle von
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2, und der zerfällt nach
  Werkzeug-Klasse, nicht nach Satz.
- **`in-progress` → `open` (blockiert):** wenn der Lauf zu Ausgang (b) kommt. Dann liegt vor ihm
  ein Change Request, dessen annehmender Akt eine Nutzer-Entscheidung ist und der dem umsetzenden
  Slice **vorausgeht**
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 1/2) — der Slice wartet darauf, statt an
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) vorbei zu
  bauen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt; der gewählte Ausgang mit seinem Kommando und seinem neuen Wert, bei Ausgang
(c) die ausdrückliche Feststellung, dass nichts gemessen wurde; Review konform (Modul 10);
Verifikation bestätigt (Modul 11); `make gates` grün; `git mv` nach `done/` als eigener
Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel ·
neuer Sensor · benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass eine neue Entscheidung entsteht.** Ein
Durchgang, dessen Erfolgskriterium die neue ADR ist, kann nur noch entscheiden; die Ablehnung mit
Grund ist ein vollwertiger Ausgang, und ohne sie wäre das Ergebnis vorweggenommen.

## 6. Risiken und offene Punkte

- **Der Slice kann den Entscheidungstext vorwegnehmen.** Sein Ergebnis ist ein Termin, und die
  Versuchung ist, die Lösung gleich mitzuschreiben. Wer das tut, verschiebt nur die Stelle, an der
  die Entscheidung unbelegt entsteht ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Ausgang (b) ist teurer, als er aussieht, und die Kosten liegen außerhalb des Repos.** Der
  Fingerabdruck steht auf Rang 1; ein Change Request ist ein externer Vorgang, kein
  Harness-Konstrukt
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  Wer ihn übergeht, ändert eine Anforderung aus einem Slice heraus — genau die Klasse, gegen die
  jener Eintrag steht.
- **Eine ebenen-verschiedene Schärfe kostet mehr als eine Zeile Code.** Sie macht aus einem Binär
  zwei Verhalten. Der Dogfood belegt dann nicht mehr, was das Ziel tut — die Richtung, die
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 1
  für den umgekehrten Fall ausschließt.
- **Der Widerspruch ist älter als der Slice, der ihn sichtbar macht.** Der Träger schreibt den
  Fingerabdruck, seit es ihn gibt; neu ist allein, dass die Aussage darüber **im Repo eines
  Adopters** steht. Wer daraus einen Fehler von
  [slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md) macht, sucht am
  falschen Ende — jener Slice hat den Widerspruch geleistet, nicht verursacht.
- **`make gates` deckt den Gegenstand nicht.** Der Doku-Gate prüft Kennungen, Anker und Pfade;
  zwei Entscheidungen, die einander widersprechen, sind grün. Das ist keine Lücke dieses Schnitts,
  sondern die Grenze der Form — und der Grund, aus dem DoD (1) kein Rot-Kommando trägt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/plan/adr/` und — nur
im Ausgang (b) — `internal/span/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

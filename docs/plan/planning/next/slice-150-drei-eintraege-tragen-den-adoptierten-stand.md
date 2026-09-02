# Slice slice-150: Drei Adaptions-Einträge tragen den adoptierten Stand

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md). **Und das ist eine Entscheidung, keine
Fortschreibung** — die Nachbar-Regel von [welle-10](../welle-10-re-baseline.md) §6 schickt einen
Fund, der eigene Arbeit verlangt, als Slice in `open/` **ohne** Wellen-Zugehörigkeit
([slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) ist dieser Fall).
Hier greift sie nicht: Gegenstand sind nicht neue Regelwerks-Inhalte, sondern **zwei korrigierte
Ausgänge des Durchgangs 1 dieser Welle** — [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
und [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
liegen **in** der eingefrorenen Bezugsmenge, deren Abdeckung das Closure-Kriterium jener Welle
verlangt (§3 dort). Schlösse die Welle mit den zwei Ausgängen aus
[slice-082](../done/slice-082-adaptions-durchgang.md) §9, die gegen den adoptierten Stand falsch
sind, wäre ihr Durchgangs-Beleg ein Grün, das nicht hinsieht.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die
Baseline-Aussage, deren Abweichungs-Index dieser Block ist),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (Kopf statt Rumpf bei
Aufhebung, Teil- gegen Vollablösung),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (die Prozedur, nach der ein
Freshness-Audit-Ausgang entsteht — einzeln, mit eigenem Beleg).

**Berührte Spec-Stellen:** `—`. Der Ausgang landet im Adaptions-Block, nicht in einem
Spec-Stratum.

**Verantwortlich:** Architect (pt9912) — der gesamte Liefergegenstand ist der Ausgang je Eintrag im
Adaptions-Block von [`harness/conventions.md`](../../../../harness/conventions.md), ein
Architect-Artefakt ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Präzedenzfälle
[slice-082](../done/slice-082-adaptions-durchgang.md) und
[slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) tragen dieselbe
Besetzung. Das Feld weicht damit von der Default-Besetzung ab, die Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine nennt (*„den Rolleninhaber der
Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-09-02.

---

## 1. Ziel

Drei Einträge des Adaptions-Blocks sagen heute etwas über die Baseline, das am adoptierten Stand
`v5.12.0` nicht mehr trägt. Jeder bekommt **genau einen** verbuchten Ausgang mit Beleg — welchen,
entscheidet der Architect-Lauf; dass jeder einen bekommt, entscheidet dieser Plan.

**Gefunden hat sie der Form-Durchgang, nicht der Adaptions-Durchgang.**
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §6 hält alle drei fest; sie
fielen auf, weil das neue Pflichtfeld `Ersetzt-Baseline-Regel` je Eintrag eine **einzelne**
Baseline-Regel verlangt und dafür jeder Eintrag gegen den **Volltext** des adoptierten Stands
gelesen werden musste. Der Delta-Durchgang aus
[slice-082](../done/slice-082-adaptions-durchgang.md) fragte nach der **Bewegung** der Baseline und
kam bei zweien zum gegenteiligen Ergebnis. Die Klasse führt
[`BEO-013`](../observations.md) (1×, Beleg `slice-083`); dieser Plan trägt die drei Einzelfälle.

**(1) [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
— die Baseline schreibt die Setzung inzwischen selbst.**
`modul-02-harness-bootstrap.md` §Anmerkung zum Instanziierungs-Zeitpunkt nennt am adoptierten Stand
dieselbe Liste wie der Geltungsbereich des Eintrags und schließt mit *„keine Blank-Kopie im Repo
vorhalten"* (`grep -c 'keine Blank-Kopie im Repo' .harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md`
→ **1**). Der Achse-1-Ausgang aus [slice-082](../done/slice-082-adaptions-durchgang.md) §9 lautet
*bleibt gültig* (`grep -n '^| 008 |' docs/plan/planning/done/slice-082-adaptions-durchgang.md`).

**(2) [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 3 — dasselbe, eine Ebene tiefer.** Der Eintrag ist über
[`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
bereits teilweise abgelöst; dessen §Achse 2 führt Setzung 3 als *eigenen, nicht eingetretenen
Bedarf*, gebunden an den Trigger *„sobald ein externer Auftraggeber existiert"*. Am adoptierten
Stand ist der Bedarf unabhängig von diesem Trigger erledigt:
`grundlagen-source-precedence.md` §Spec-Stratifizierung sagt wörtlich *„die Verweis-Spalte nennt
diesen Vorgang statt eines Tickets"*
(`grep -c 'die Verweis-Spalte nennt diesen Vorgang statt eines' .harness/baseline/v5.12.0/regelwerk/grundlagen-source-precedence.md`
→ **1**). Abzulösen ist damit nicht nur eine Aussage jenes Eintrags, sondern die Aussage von
[`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
§Achse 2 über sie.

**(3) [`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)
— der Rumpf argumentiert gegen einen abgelösten Tag, das Pflichtfeld nennt den geltenden.** Der
Adaptions-Absatz begründet das Zusatzfeld gegen die Pflichtfeld-Liste der Vorlage von `v3.5.2` und
nennt sich deshalb *„keine Abweichung von einer Baseline-Regel"*; das seit dem Form-Durchgang
danebenstehende Feld `Ersetzt-Baseline-Regel` nennt `grundlagen-traceability.md` §Herkunfts-Anker
und sagt, dass es gegen `v5.12.0` gemessen **eine** ist. Beide Sätze stehen unvermittelt
nebeneinander, und der Block ist nach seiner Ziel-Form ein *Index der Abweichungen*: Ein Eintrag,
der eine Abweichung **bestreitet**, während er eine setzt, beantwortet die Leserfrage falsch. **Der
Ausgang ist hier nicht vorgezeichnet:** nach
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
Setzung 4 ist eine Kopf-Marke fällig, wenn ein **späterer Eintrag** eine Aussage ablöst — hier
steht die ablösende Aussage im Eintrag selbst. Ob daraus eine Marke, ein Nachfolge-Eintrag oder
eine begründete Nicht-Fälligkeit folgt, ist eine **Form-Entscheidung über diesen Block** und
gehört dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**Was dieser Slice nicht ist: ein zweiter Bestands-Durchgang.** Die Menge ist **extensional
geschlossen** — genau die drei Kennungen oben, die
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §6 benennt. Ein Kriterium
über *„alle Einträge, deren Aussage am adoptierten Stand nicht mehr trägt"* wäre eine Abdeckung
über eine Menge, die dieser Plan nicht führt, und liefe auf denselben Durchgang hinaus, den
[slice-082](../done/slice-082-adaptions-durchgang.md) schon gefahren hat. Für den **Bestand**
gleichgelagerter Fälle gilt der Cutoff aus
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
unverändert: *„der Bestand ist kein Arbeitsauftrag"*.

## 2. Definition of Done

- [ ] [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
      trägt einen der fünf Freshness-Audit-Ausgänge
      (`modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline) mit Beleg gegen
      `v5.12.0`. Verlangt ist **ein** Ausgang mit Begründung, nicht ein bestimmter: welche
      Reichweite der Rückbau hat (Teil-Ablösung mit Rumpf nach
      [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a) oder
      vollständige Aufhebung nach
      [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)),
      entscheidet der Lauf am Rumpf, nicht dieser Plan. Wo ein Nachfolge-Eintrag entsteht, trägt
      der Vorgänger seine Kopf-Marke nach
      [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
      Setzung 3 in derselben Änderung.
- [ ] [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
      Setzung 3 trägt denselben Nachweis — **und die Aussage von
      [`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
      §Achse 2 ist mitentschieden.** Sie ist die Stelle, an der Setzung 3 heute als offener
      eigener Bedarf steht; ein Ausgang, der nur den einen Eintrag anfasst, ließe zwei Fassungen
      derselben Frage stehen. Der dort betroffene Rumpf bleibt dabei unangetastet
      ([`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
      §Geltungsbereich: *„Nicht der Inhalt eines akzeptierten Rumpfs"*).
- [ ] [`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)
      trägt eine **entschiedene** Antwort auf die Kopf-Marken-Frage aus §1 (3) — Marke gesetzt,
      Nachfolge-Eintrag geschrieben oder Nicht-Fälligkeit begründet —, und die Antwort steht **im
      Block**, nicht in diesem Plan: ein Verdikt, das nur hier stünde, fände der nächste
      Form-Durchgang nicht. Sagt die Antwort etwas über andere Einträge derselben Gestalt, sagt
      sie es als Regel mit Cutoff, nicht als Arbeitsauftrag über den Bestand (§1, letzter Absatz).
- [ ] `make gates` grün.
- [ ] Doku-Update: keines außerhalb von
      [`harness/conventions.md`](../../../../harness/conventions.md) erwartet — tritt eines ein
      (etwa ein Zitat dieses Blocks in [`AGENTS.md`](../../../../AGENTS.md)), zieht es im selben
      Architect-Commit mit ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler
      +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert. **[`BEO-013`](../observations.md) ist der naheliegende Kandidat und wird nicht
      automatisch erhöht:** diese Ausführung ist die *Auflösung* der gezählten Klasse, kein
      zweites Auftreten.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo führt
      Wellen-Betrieb, sie prüft die nächste Welle-Closure.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Nachfolge-Einträge und/oder Kopf-Marken für die drei Kennungen aus §1; append-only, kein Rumpf wird umgeschrieben |

Mehr steht hier nicht, und das ist der Zuschnitt: **eine Datei, eine Rolle, drei Einträge.** Der
Adaptions-Block wächst dadurch — dass eine wachsende Datei ein eigener Roadmap-Kandidat ist
(Verzeichnis-Form), steht in [welle-10](../welle-10-re-baseline.md) §6 und ist hier
ausdrücklich **nicht** mitgeschnitten.

## 4. Trigger

**Start** (`next` → `in-progress`): [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md)
liegt in `done/`. Der Trigger ist beobachtbar und **kein Ergebnis dieses Slice** — er benennt den
Lauf, der die drei Befunde protokolliert hat; ohne dessen Closure stünden sie noch als offene
Risiken in einem Plan, der sie nicht auflösen darf.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Recherche für **einen** der drei
  Einträge einen eigenen Nachfolge-Eintrag mit eigener Begründungslast erzeugt, der die anderen
  zwei aus der Sitzung drängt. Dann wird geteilt (je Kennung ein Slice), nicht gedehnt — dieselbe
  Antwort, die [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §4 auf
  denselben Druck gegeben hat.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Ausgang für einen Eintrag eine
  Entscheidung verlangt, die dieses Repo noch nicht treffen kann — etwa wenn *übernehmen* an einer
  Fähigkeit hängt, die fehlt. Dann ist es keine Adaption mehr, sondern ein Carveout mit
  Auflösungs-Trigger und Folge-Slice (`modul-07-carveouts.md`).

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Ausgang für [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  könnte am Rumpf scheitern, statt ihn abzulösen.** Der Eintrag trägt neben der Setzung eine
  Abgrenzung gegen [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  und einen Nachzug von 2026-07-21, der die Abgrenzung selbst wieder aufhebt; was davon eigenständig
  bindet, entscheidet über Teil- oder Vollablösung
  ([`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2). Wer das
  überspringt, entfernt einen Satz, den ein anderes Artefakt zitiert. — **Ausgang:** offen bis zur
  Closure.
- **Die Deckung von [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 3 ist an **einem** Satz gemessen, und ein Satz ist keine Setzung.** Setzung 3 verlangt
  neben der Verweis-Form auch, dass der *Anlass* in der Änderungs-Spalte bleibt; ob der
  Baseline-Absatz das mitträgt, ist gegen den Volltext zu prüfen und nicht gegen das Zitat in §1.
  Genau dieser Kurzschluss ist [`BEO-008`](../observations.md) — *„die Baseline behandelt jetzt
  dasselbe Thema"* trägt nicht. — **Ausgang:** offen bis zur Closure.
- **Die Kopf-Marken-Frage aus §1 (3) kann als „nicht fällig" enden, und dann liefert dieser
  Liefer-Punkt kein Artefakt.** Ein Verdikt ohne Ort ist nach der DoD-Zeile oben kein Ausgang; er
  müsste dann als eigener Eintrag im Block stehen, und damit wächst der Block um eine
  Form-Entscheidung statt um eine Abweichung. Ob das der richtige Ort ist, ist dieselbe offene
  Frage, die [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  §*Der Ort ist offen, die Verbindlichkeit nicht* für sich schon führt. — **Ausgang:** offen bis
  zur Closure.
- **Kein Wächter sieht, ob dieser Slice seine Arbeit tut.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../../../.d-check.yml) hält einen Eintrag dieses Blocks gegen die Baseline
  (`grep -n '^modules:' .d-check.yml`), und `make comment-claims` hat keine Markdown-Datei im
  Prüfbereich — dieselbe Lücke, die
  [`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  für sich benennt. Träger ist der Rollen-Wechsel und der Form-Vergleich der nächsten
  Re-Baseline. — **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist eine Sub-Area, `*` (gesamtes Repo), wie die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
sie führt. Eine feinere Ausdifferenzierung (`harness/` als eigene Sub-Area) erfüllt das
Inklusionskriterium hier nicht: der Liefergegenstand ist der repo-weite Abweichungs-Index, nicht
ein Verzeichnis. Dass `*` nichts unterscheidet, ist bekannt und gezählt —
[`BEO-004`](../observations.md) (1×).

**Vorgelagert — offene Beobachtungen sichten:** gesichtet ist der gemergte Stand von
[`observations.md`](../observations.md). Alle Zeilen tragen die Sub-Area `*` und sind damit formal
Treffer; sachlich berühren diesen Schnitt drei, keine davon an der Schwelle:
[`BEO-013`](../observations.md) (1×) — die Klasse, deren drei Einzelfälle dieser Slice auflöst;
[`BEO-008`](../observations.md) (1×) — der Achse-1-Kurzschluss, hier als Risiko in §6 geführt statt
nur genannt; [`BEO-002`](../observations.md) (1×) — der fehlende Ausgang *real, aber nicht jetzt*,
der auch für diesen Plan gälte, wenn er nicht ausgeführt wird. **Keine erreicht mit diesem Slice
3×**, kein Eintrag wird also zur Lücke, und keiner verlangt einen eigenen Folge-Slice.

Alle berührten Sub-Areas GF: `harness/` gehört zum Greenfield-Bestand, der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).
Ein Modus-Begründungsblock ist damit nicht Pflicht.

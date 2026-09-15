# Slice slice-lifecycle-move-geht-ins-ziel: Der Lifecycle-Move zieht seine Verweise im Ziel nach

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md). Die Welle trägt das
*Mehr* über dieser DoD: ihr Closure-Trigger fährt die neu emittierten Werkzeuge im gebootstrappten
Ziel einmal durch (`make full-smoke`) — einen Beleg, den kein Punkt dieser DoD führt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist die Command-Vorlage, die das Werkzeug in ein
fremdes Ziel schreibt. Der Anweisungssatz **dieses** Repos bleibt draußen und hat einen benannten
Ausgang ([slice-226](../done/slice-226-implementer-anweisungssatz-zieht-nach.md), §5 der Welle).

**Bezug:**
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
emittierte Anleitung — sie schreibt den Lifecycle-Wechsel vor),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
repo-spezifischen Stellen bleiben adaptierbare Marker),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Kommando behaupten, das im Ziel nicht läuft),
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 (die zwei
Pfad-Ausnahmen des Nachzugs sind Repo-Politik),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (ein Anweisungssatz
gehört der Rolle, die ihn ausführt).

**Berührte Spec-Stellen:** `—`. Der Slice ändert eine Emissions-Vorlage; kein Zielelement der
Spec-Straten wird angefasst.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der emittierte `implement-slice.md` schreibt den Lifecycle-Wechsel an zwei Stellen als
**Handarbeit** vor — und lässt den **Verweis-Nachzug** entfallen, den der Dogfood automatisiert hat.
Das Ziel bekommt das Werkzeug und den Satz, der darauf zeigt.

### Der Anlass ist am Baum gemessen

Die emittierte Command-Vorlage nennt `git mv` viermal und kennt den Nachzug nicht; der Dogfood hat
beides getrennt:

```sh
grep -c 'git mv' internal/emit/templates/commands/implement-slice.md   # 4
git grep -c 'slice-mv' -- internal/emit internal/gen | wc -l           # 0
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit dem Baum. Die zwei Stellen sind **Schritt 9** (der Eintritt nach
`in-progress/`) und **Schritt 24** (die Closure nach `done/`); jede verlangt einen *reinen* Move und
überlässt den Verweis-Nachzug dem Lauf. Genau dort bricht es in der Praxis: der Move macht Pfade
tot, und die Reparatur ist Handarbeit, die niemand anweist.

**Das Werkzeug existiert und ist fast generisch.** `harness/tools/slice-mv.sh` bewegt den Slice,
committet den reinen Move sofort als eigenen Commit und zieht danach **eingehende** und
**ausgehende** Verweise nach — jede Präfix-Form mit einer Regel statt einer Musterliste. Seine
einzigen Repo-Bindungen sind **zwei** Pathspec-Ausschlüsse (der unveränderte Fremdtext der vendored
Baseline und die `Accepted`-ADR), und beides ist Repo-Politik nach
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 — im Ziel also
adaptierbarer Marker, kein hart verdrahteter Wert
([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Anweisungssatz dieses Repos.** Gegenstand ist die **emittierte** Vorlage; die lokale Fassung
  zieht über [slice-226](../done/slice-226-implementer-anweisungssatz-zieht-nach.md) nach (Dogfood, eigener
  Ausgang). Beide in einem Slice hieße, zwei Verträge mit einem Diff zu bedienen.
- **Die dritte Hälfte eines Ortswechsels.** Ein bewachtes **Zustandsfeld** nachzuziehen ist ein
  eigener Vorgang; er liegt bei
  [slice-ortswechsel-zieht-sein-zustandsfeld-nach](../open/slice-ortswechsel-zieht-sein-zustandsfeld-nach.md).
  Das Werkzeug deckt **Verweise**, nicht Zustandsfelder — die Grenze bleibt an beiden Stellen benannt.
- **Der Nachzug über die Ebene.** Dass die emittierte Vorlage der ausgeführten nachläuft, hält keine
  Quelle zusammen; die Klasse ist im Register gezählt und die Welle schließt sie nicht mit (Welle
  §5/§6).
- **Der Produkt-Code.** Diese Eröffnung schneidet; `internal/` wird von ihr nicht angefasst.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Was hier steht, ist die Grenze, an der ein wachsender Slice sich
messen lässt: Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den
Plan **geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Der emittierte Anweisungssatz nennt für Schritt 9 und Schritt 24 das Werkzeug** statt des
      `git mv` von Hand, und die repo-spezifischen Stellen bleiben **adaptierbare** Marker
      ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)) — der
      Adopter darf sein Fragment anders nennen — und *was* daran frei ist, steht hier, weil der
      Satz sonst zwei Lesarten trägt: die **Datei** ist frei (der Aggregator bindet
      `harness/mk/*.mk` per Glob ein), der **Ziel-Name** darin ist es **nicht** — er kommt aus einem
      tool-eigenen Fragment, das jeder Bootstrap kanonisch neu schreibt.
- [ ] **Das Ziel führt das Werkzeug, und es zieht Verweise in beiden Richtungen nach:** eingehende
      (jede Präfix-Form auf die bewegte Datei) und ausgehende (präfixlose Ziele innerhalb der
      bewegten Datei). Der Move bleibt ein **reiner** Commit, getrennt von der Inhaltsänderung; fiel
      keine Änderung an, bleibt es beim einen Commit. Beide Richtungen sind im Ziel belegt, nicht im
      Emit-Code behauptet.
- [ ] **Fehlt eine Voraussetzung, sagt das Werkzeug das und committet nichts** — der unsaubere
      Arbeitsbaum ist der benannte Fall. Rot gesehen: den Fall herstellen, Kommando fahren, Ausgabe
      und Exit-Code lesen. Die zwei Pfad-Ausnahmen sind als Repo-Politik **markiert**, nicht
      versteckt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Aufzählung der emittierten Werkzeuge, soweit dieser Slice sie wachsen lässt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/implement-slice.md` | update | die zwei Stellen (9, 24) nennen das Werkzeug statt der Handarbeit |
| `internal/emit/templates/enforce/` bzw. ein Fragment im emittierten Fragment-Verzeichnis | neu/update | das Ziel bekommt den Nachzug als Ziel und die Vorlage daneben |
| `Makefile` (`full-smoke`) | update | der Beleg aus DoD (2) |
| `test/…` | neu/update | die zwei Ersetzungsrichtungen und der unsaubere Baum — DoD (2)/(3) |

**Das Werkzeug wird übernommen, nicht neu gebaut.** `harness/tools/slice-mv.sh` trägt die Regel für
den eingehenden Nachzug (ein Vorkommen von `<von>/<datei>` an einer Wortgrenze, statt einer
Musterliste, die driftet) und trennt seine Ersetzungs-Funktionen von `main()`, damit ein Test sie
ohne `git`-Repo rufen kann. Die Emission übernimmt diese Form; die **Repo-Politik** darin — die zwei
Pfad-Ausnahmen — wird als Marker ausgewiesen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`Verantwortlich:` gesetzt) und das
WIP-Limit frei. **Keine harte Bindung an den Dogfood-Zwilling:**
[slice-226](../done/slice-226-implementer-anweisungssatz-zieht-nach.md) zieht den lokalen Anweisungssatz auf
eine **andere** Ziel-Fassung nach; die zwei Ebenen dürfen auseinanderlaufen, solange die Richtung
stimmt — erst die ausgeführte Fassung, dann die emittierte (Welle §5).

**Reihenfolge innerhalb der Welle:** unabhängig von den drei übrigen Mitgliedern; die vier Flächen
sind disjunkt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der eingehende **und** der ausgehende
  Nachzug zusammen nicht in einer Review-Sitzung prüfbar sind — dann ist der Schnitt an der
  Richtung zu schneiden, nicht die DoD länger zu machen.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Nachzug im Ziel eine Repo-Entscheidung
  verlangt, die kein Marker trägt (etwa eine dritte Pfad-Ausnahme) — dann gehört erst die
  Entscheidung, dann der Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über einem gebootstrappten Ziel **und** die beiden
Nachzug-Richtungen dort belegt; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nachzug ist im Ziel nicht entscheidbar, wo er auf fremde Texte trifft.** Das Werkzeug
  ersetzt in **jedem** Vorkommen an einer Wortgrenze; in einem Ziel, das dieselbe Slice-Kennung in
  einem Fremd-Text führt (vendored Baseline, eingefrorene ADR), wäre die Ersetzung falsch. Die zwei
  Pfad-Ausnahmen decken die zwei Fälle **dieses** Repos, nicht die des Ziels. — **Ausgang:**
  <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: → BEO im Register>
- **Der ausgehende Nachzug kollidiert mit dem Ziel-Ruheort.** Er trifft präfixlose Ziele *innerhalb*
  der bewegten Datei; trägt das Ziel eine andere Lifecycle-Tiefe, ist die Vorgabe falsch. Die
  Vorlage muss die Tiefe ableiten, nicht annehmen. — **Ausgang:** <eingetreten: CO-NNN /
  slice-<Kennung> | entfallen: Grund | weiter offen: → BEO im Register>
- **Die zwei Fassungen driften weiter ungeobachtet.** Kein Sensor hält den lokalen Anweisungssatz
  gegen die emittierte Vorlage; die zwei sind getrennte Artefakte, und dieses Mitglied schreibt die
  emittierte Fassung, nicht den Wächter. Die Lücke bleibt benannt (Welle §6) und ist der Grund, den
  Nachzug nicht still zu lassen. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen:
  Grund | weiter offen: → BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen im Register>

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <von der Welle-Closure getragen — Anker · Folge-Slice · Register>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
`internal/emit/` liegt in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area). Die
**emittierte** Ebene ist keine Sub-Area dieses Repos: sie ist ein anderer Vertrag, und die
Deklaration führt sie nicht.

**Vorgelagert — offene Beobachtungen sichten:** das Register durchgegangen. **Zwei Treffer**, beide
mit ihrem Zähler-Stand (die Zahl der Dateien unter `evidence/`, abgelesen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` — kein gespeicherter Wert):

- [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **24×, offen.** Berührt: dass der emittierte Satz der ausgeführten Fassung nachläuft, hält keine
  Quelle zusammen. Dieses Mitglied schreibt die **Vorlage**, nicht die Klammer; die Lücke steht als
  Risiko in §6 und als Out-of-Scope in Welle §6.
- [`BEO-ALL/verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
  — **6×, offen.** Berührt: der Gegenstand des Werkzeugs ist genau diese Klasse, und
  `make slice-mv` deckt sie im Dogfood seit `slice-144`. Für das Ziel heißt das: der Nachzug ist
  belegt, nicht behauptet — die zwei Richtungen sind im gebootstrappten Ziel zu fahren.

Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

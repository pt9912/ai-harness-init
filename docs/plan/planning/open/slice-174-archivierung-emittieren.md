# Slice slice-174: Ein gebootstrapptes Ziel erreicht die Wellen-Archivierung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD unten; ein repo-weiter Beleg darüber
hinaus steht in keinem Kriterium (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).

**Bezug:**
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(die emittierte Anleitung — der Adopter bekommt den Prozess, nicht nur die Gerüste),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(repo-spezifische Stellen bleiben adaptierbare Marker),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Kommando behaupten, das im Ziel nicht läuft),
[ADR-0007](../../adr/0007-bootstrap-phasen.md) (Phasen und Idempotenz-Klassen je emittiertem
Artefakt),
[ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5b
(der Träger liegt gitignored — ein frischer Klon des Adopter-Repos hat ihn nicht),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (ein
Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Implementer

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der emittierte Anweisungssatz nennt für Schritt 4 ein Kommando, das im Ziel läuft — statt der
Feststellung, dass die Bedingung nicht eingetreten ist.**

Die Vorlagen für beide Stub-Arten liegen im Ziel bereits: der Bootstrap vendort den
Baseline-Baum, und darin stehen `archiv-stub-slice.template.md` und
`archiv-stub-welle.template.md`
(`ls .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-*.template.md | wc -l`
→ **2**; kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Was fehlt, ist der **Ausführende**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Ein frisch gebootstrapptes Ziel erreicht `archive-welle`** — auf dem Weg, den Festlegung
      (d) aus [slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md) wählt. Der Weg ist in
      `make full-smoke` **belegt**, nicht behauptet: derselbe Beleg-Typ, mit dem
      [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) die
      Erfassungsschicht im Ziel abgenommen hat.
- [ ] **Der emittierte `close-welle.md` nennt für Schritt 4 das Kommando** statt des
      Nicht-Eintritts, und die repo-spezifische Stelle bleibt ein **adaptierbarer** Marker
      ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)) —
      der Adopter darf das Target anders nennen.
- [ ] **Fehlt der Träger im Ziel, sagt das Kommando das und färbt nichts rot** — der Fall aus
      [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5b
      (frischer Klon, gitignorierter Ablageort). Rot gesehen an genau diesem Fall: Träger
      entfernen, Kommando fahren, Ausgabe und Exit-Code lesen.
- [ ] `make gates` grün.
- [ ] Doku-Update: die Aufzählung emittierter Artefakte in
      [`harness/README.md`](../../../../harness/README.md) und
      [`README.md`](../../../../README.md), soweit sie durch diesen Slice wächst.
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
| `internal/emit/templates/commands/close-welle.md` | update | Schritt 4 nennt das Kommando statt des Nicht-Eintritts |
| `internal/emit/` | update | nur falls Festlegung (d) einen eigenen Emissions-Schritt verlangt; die Vorlagen liegen über den vendored Baum schon im Ziel |
| `Makefile` (`full-smoke`) | update | der Beleg aus DoD (1) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-173](../done/slice-173-archive-welle-als-unterkommando.md) liegt in `done/` — vorher gibt es kein
Kommando, auf das der emittierte Anweisungssatz zeigen könnte, und ein Zeiger darauf wäre genau
die halluzinierte Zusage aus
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die **Erreichbarkeit** im Ziel eine
  eigene Abzählung verlangt — der Träger liegt gitignored, und ein frischer Klon hat ihn nicht.
  Das ist eine Träger-Frage und gehört zu
  [slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md), nicht an die Emissionsstelle.
- `in-progress` → `open` (blockiert — Carveout?): wenn Festlegung (d) die Emission verneint —
  dann hat dieser Slice keinen Gegenstand.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über beiden Zweigen aus DoD (1) und (3); `make gates`
grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Ausweg der Erfassungsschicht trägt hier nicht.**
  [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5b
  löst den fehlenden Träger mit einem committeten Wrapper, der **schweigt und erfolgreich endet**
  — richtig für einen fail-open-Beobachter. Die Archivierung schreibt Commits und löscht Dateien;
  Schweigen wäre dort der teurere Fehlerfall. DoD (3) verlangt darum eine **Meldung** ohne Rot,
  nicht Stille. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter
  offen: → BEO-NNN im Register>
- **Der Gegenstand ist ein Rollen-Anweisungssatz, und dieser Slice ist Implementer-Arbeit.**
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) gibt
  `close-welle.md` der ausführenden Rolle — dem Planner; `BEO-007` im
  [Register](../observations/README.md) (4×, geplant) führt die noch offenen Teile derselben Frage. Die
  **Text**-Hälfte von DoD (2) ist damit eine Übergabe, keine Implementer-Entscheidung. —
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im
  Register>
- **Ein Sensor des Ziels sieht die Stubs womöglich nicht mehr.** Der emittierte Anweisungssatz
  warnt selbst: was auf `done/*.md` keilt, sieht die Stubs eine Ebene tiefer nicht und bleibt
  grün, ohne noch etwas zu prüfen. Was die emittierte Gate-Konfiguration hier zusagt, ist zu
  prüfen, nicht anzunehmen. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund |
  weiter offen: → BEO-NNN im Register>

## 7. Closure-Notiz

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
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — `internal/emit/` liegt
in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).
Die **emittierte** Ebene ist keine Sub-Area dieses Repos: sie ist ein anderer Vertrag, und die
Deklaration führt sie nicht.

**Vorgelagert — offene Beobachtungen sichten:** Zwei Treffer im [Register](../observations/README.md).
`BEO-007` (4×, geplant — wer die Anweisungssätze schreiben darf, sagt keine Quelle) steht als
Risiko in §6. `BEO-009` (8×, geplant — eine geänderte Ableitung lässt die Zusage daneben stehen)
ist berührt: DoD (2) zieht **genau eine** solche Zusage nach, den Satz über das nicht vorhandene
Werkzeug; der Zähler bewegt sich damit nicht, weil dieser Slice die Klasse auflöst statt sie zu
beobachten. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

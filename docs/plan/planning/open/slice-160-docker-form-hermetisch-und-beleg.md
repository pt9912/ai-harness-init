# Slice slice-160: Die Docker-Form gegen die Ziel-Fassung — hermetischer Prüflauf und die Trennung Gate/Beleg

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`ADR-0003`](../../adr/0003-go-native-binaries.md).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Für die vier neuen Docker-Aussagen der Ziel-Fassung steht der Ist-Zustand dieses Repos gemessen
da, und jede Abweichung trägt einen Ausgang — Konformität, `MR-<NNN>` oder Carveout.**

Die vier: *Zwei Formen des Reproduzierbarkeits-Ankers* (Archiv vs. Rezept — eine notierte
Image-Kennung hält fest, **welches** Image einen Lauf gemacht hat, und ist kein
Wiederholungs-Schlüssel) ·
*Besitz der Belege eines containerisierten Gates* (root-Besitz über einem beschreibbaren Mount) ·
*Der Prüflauf ist hermetisch — kein Mount* (Quellen per `COPY`, Rückweg über `stdout`; bei
Gate-Stage-als-Gate zwei Griffe: `--no-cache-filter` und **kein** `-q`) · und Modul 13
*Gate und Beleg — zwei Rollen derselben Prüfung* (`|| true` an den Beleg-Lauf, nie an den
Gate-Lauf; die sammelnde Stage erbt von der Quell-Stage, nicht von der Gate-Stage).

**Beide Ebenen sind Gegenstand** — der Dogfood (`Makefile`, `Dockerfile`) und die emittierte
(`internal/emit/templates/enforce/`). Was hier gilt und was das Werkzeug ausliefert, sind
verschiedene Verträge und werden getrennt beantwortet.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Ist-Messung Mount und Besitz:** je Docker-Aufruf in `Makefile` und `d-check.mk` steht,
      ob er mountet, ob der Mount schreibbar ist und wem die Belege danach gehören — der Testfall,
      den die Quelle selbst nennt (`ls -l` auf das Build-Verzeichnis nach dem ersten Gate-Lauf).
      Dazu die Einordnung des Reproduzierbarkeits-Ankers: Archiv-Form oder Rezept-Form.
- [ ] **Ist-Messung Gate und Beleg:** wo ein Beleg-Lauf am Gate-Target oder an der Gate-Stage
      hängt, und wo ein `|| true` sitzt. Erbt eine sammelnde Stage von einer Gate-Stage, ist das
      der Befund.
- [ ] **Je Befund ein Ausgang** — Konformität (nichts zu tun, belegt), `MR-<NNN>` (benannte
      Abweichung, Architect) oder Carveout mit Auflösungs-Trigger. Getrennt für Dogfood und
      emittierte Ebene; keine Pauschale über beide.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| dieser Plan, §9 | update | trägt die zwei Ist-Messungen und die Ausgänge |
| `Makefile`, `Dockerfile` | update | nur, soweit ein Befund einen Ausgang *Konformität herstellen* bekommt |
| `internal/emit/templates/enforce/` | update | dieselbe Frage auf der emittierten Ebene |
| `harness/conventions.md` | update | falls die Antwort ein `MR-<NNN>` ist — Architect, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](slice-156-baum-tauschen-pins-ziehen.md) liegt in
`done/` — erst dann ist `v5.18.0` der Ist-Maßstab, und ein Befund dagegen ist einer
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn ein Ausgang *Konformität
  herstellen* den Build-Weg umbaut — der Umbau ist dann ein eigener Slice, die Messung bleibt
  hier.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Befund nur durch eine Senkung einer
  bestehenden Schwelle grün würde ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; kein Befund der zwei Messungen steht ohne Ausgang; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Messung wird zur Zusage, ohne rot gesehen worden zu sein** — *„der Prüflauf ist
  hermetisch"* ist eine Zusage nach [`AGENTS.md`](../../../../AGENTS.md) §3.6 und braucht das
  Gegenbeispiel, nicht die Lektüre des Makefiles. — **Ausgang:** offen, wird bei Closure verbucht.
- **Der Umbau kostet mehr als die Abweichung** — die Rezept-Form verlangt, dass beim Build
  nichts installiert wird und jede Eingabe digest-gepinnt ist; ob dieses Repo das hält, ist
  gemessen zu beantworten und nicht anzunehmen. — **Ausgang:** offen, wird bei Closure verbucht.

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
- **Beobachtungs-Register (`../observations.md`):** <neue `BEO-<NNN>` angelegt (Sub-Area, 1×, Beleg slice-NNN) | `BEO-<NNN>` auf <N>× erhöht, Beleg slice-NNN ergänzt | keine Beobachtung angefallen>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo, Build- und Gate-Weg) und
`harness/tools/` — beide führt die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area),
beide als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-009` (ein Fix ändert die Ableitung und lässt
die Zusage stehen) trifft das erste Risiko in §6 unmittelbar. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

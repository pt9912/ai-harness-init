# Slice slice-gliederung-der-instanzen-ohne-vorlagen-delta: Fünf Instanzen einmaliger Vorlagen ohne Delta tragen die Gliederung ihrer Vorlage

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht fällt negativ aus: Keine Closure-Bedingung beobachtet mehr als die
DoD. Nach [`MR-037`](../../../../harness/conventions.md#mr-037) steht wellenlose Arbeit nicht in
der Roadmap.

**Bezug:** [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (§Konsequenzen,
Übernahme-Vorgabe delta-gebunden),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 2, Ist-Maßstab),
[`MR-000`](../../../../harness/conventions.md#mr-000),
[`MR-019`](../../../../harness/conventions.md#mr-019).

**Berührte Spec-Stellen:** `architecture.md §4`, `architecture.md §5` · `spezifikation.md`
(oberste Gliederung) — nur die `##`-Ebene, kein Inhalt.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-16.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Fünf Instanzen einmaliger Vorlagen tragen auf der obersten Ebene (`##`) genau die
Abschnitte ihrer Vorlage. Eigener Stoff steht als Unterabschnitt (`###`) im passenden
Vorlagen-Abschnitt; ein Abschnitt, den die Vorlage als bedingt kennzeichnet, fehlt nur, wenn seine
Bedingung nicht zutrifft. Maßstab ist das Gliederungs-Kriterium in
[`harness/migration.md`](../../../../harness/migration.md) §5 a.

| Instanz | Vorlage |
|---|---|
| `docs/plan/carveouts/README.md` | `.harness/baseline/v6.9.0/templates/docs/plan/carveouts/README.template.md` |
| `harness/README.md` | `.harness/baseline/v6.9.0/templates/harness/README.template.md` |
| `README.md` | `.harness/baseline/v6.9.0/templates/project-readme.template.md` |
| `spec/architecture.md` | `.harness/baseline/v6.9.0/templates/spec/architecture.template.md` |
| `spec/spezifikation.md` | `.harness/baseline/v6.9.0/templates/spec/spezifikation.template.md` |

Die Abweichungen misst der Umsetzungs-Lauf, je Zeile der Tabelle:

```sh
diff <(grep '^## ' <vorlage>) <(grep '^## ' <instanz>)
```

**Herkunft:** Der Instanz-Durchgang des Sprungs hat die fünf gefunden; der
[Vorlagen-Bericht zum Tag `v6.9.0`](../../../migrations/v6.9.0.md) führt sie mit „kein Delta;
Gliederung weicht ab". Keine der fünf Vorlagen ändert sich zwischen `v6.8.0` und `v6.9.0`, die
Übernahme-Vorgabe des Auftraggebers ist aber **delta-gebunden**
([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen). Deshalb
gehören die fünf nicht in den Sprung. Für diesen Slice gelten die vier Ausgänge aus §5 a
vollständig: *bewusst abweichend* ist möglich, wenn ein aktiver `MR`-Eintrag die Abweichung trägt.
Ob einer trägt, urteilt der Architect.

**Setzungen des Auftraggebers (2026-09-16):** Freiraum gibt es nur innerhalb der Abschnitte, als
Unterabschnitte. Kein Inhaltsumzug. Die Spec zeigt nicht nach außen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Instanzen von Vorlagen mit Delta und wiederkehrende Vorlagen** — *Bestand bleibt stehen*: Sie
  hat der Sprung-Slice `slice-sprung-auf-v690-wird-vollzogen` übernommen oder als append-only
  berichtet.
- **Der Inhalt der Abschnitte** — *anderer Vorgang*: Innerhalb der Abschnitte ist Freiraum
  (Setzung); dieser Slice ändert Gliederung, keinen Text.
- **Außenverweise der Spec-Straten** — *anderer Vorgang*: Die Regel „Spec-Straten zeigen nicht
  nach außen" trägt der Matrix-Slice, der noch nicht angelegt ist. Dieser Slice fügt beim
  Umgliedern keinen Außenverweis hinzu und räumt keinen bestehenden (§6, Risiko 2).
- **Die schreibende Rolle für `spec/*.md`** — *ein Folge-Slice übernimmt sie*:
  `slice-151-spec-straten-haben-eine-schreibende-rolle` (Titel: „Für die zwei Spec-Straten
  benennt eine Quelle die schreibende Rolle"); §6, Risiko 1.
- **Einmalige Instanzen außerhalb der fünf** — *Bestand bleibt stehen*: Der Vorlagen-Bericht führt
  nur diese fünf als abweichend.
- **Ein Sensor für das Gliederungs-Kriterium** — *anderer Vorgang*: Ob `make doc-structure` es
  trägt, ist eine eigene Entscheidung; hier ist es ein Kandidat für den Lerneintrag.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **1 — Die drei Doku-Instanzen folgen der Gliederung ihrer Vorlage:**
      `docs/plan/carveouts/README.md`, `harness/README.md`, `README.md`. Das Kommando aus §1
      liefert je Datei keine Zeile, außer für bedingte Abschnitte, deren Bedingung benannt ist.
      Je Instanz steht ein Ausgang aus §5 a in §7.
- [ ] **2 — Die zwei Spec-Instanzen folgen der Gliederung ihrer Vorlage:** `spec/architecture.md`,
      `spec/spezifikation.md`, mit demselben Kriterium und demselben Beleg. Geschrieben von der
      Rolle, die `slice-151-spec-straten-haben-eine-schreibende-rolle` benennt (§6, Risiko 1).
- [ ] **3 — Keine Adresse stirbt an einer umbenannten Überschrift.** Vor jeder Umbenennung ist
      gemessen, wer den alten Anker nennt, über beide Adress-Formen (Markdown-Link und Code-Span)
      und einschließlich eingefrorener Artefakte ([`AGENTS.md`](../../../../AGENTS.md) §3.11).
      Die Entscheidung — etwa ein expliziter Anker mit dem alten Slug — steht vor der
      Umbenennung, und `make docs-check` bleibt grün.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: über die fünf Dateien hinaus keines; der Ausgang je Instanz steht in §7.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/carveouts/README.md`, `harness/README.md`, `README.md` | update | Liefer-Punkt 1 |
| `spec/architecture.md`, `spec/spezifikation.md` | update | Liefer-Punkt 2 |
| Dateien mit Verweisen auf einen geänderten Anker | update, nur lebende | Liefer-Punkt 3 |

**Kein Code, keine Testdatei-Zeile.** Die Reihenfolge trägt: erst die Anker-Messung aus
Liefer-Punkt 3, dann die Umbenennung.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-sprung-auf-v690-wird-vollzogen` liegt in `done/` — erst
dann ist `v6.9.0` gebucht. Dazu ist das WIP-Limit frei. Für Liefer-Punkt 2 nennt eine Quelle die
schreibende Rolle der Spec-Straten (§6, Risiko 1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Eine Instanz braucht mehr als Umgliedern,
  etwa weil ein fehlender Pflicht-Abschnitt neuen Text verlangt. Dann wird je Instanz geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Eine Umbenennung träfe eine Adresse in einem
  eingefrorenen Artefakt, und die Entscheidung dazu steht aus; oder eine Abweichung soll
  *bewusst abweichend* bleiben, und kein aktiver `MR`-Eintrag trägt sie. Beides ist eine Übergabe
  an den Architect.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. Das Kommando aus §1 liefert für alle fünf Instanzen keine Zeile außer benannten bedingten
   Abschnitten.
2. `make docs-check` ist grün, und jede Adresse aus Liefer-Punkt 3 hat ihre Entscheidung.

**Lerneintrag** in einer der drei Formen, §7. **Die Closure schreibt der Planner**
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Den Ausgang setzt die Closure. *Absehbar* nennt, welcher Ausgang unter welcher Bedingung eintritt.

1. **Für `spec/*.md` benennt keine Quelle die schreibende Rolle.** Die Adresse ist
   `slice-151-spec-straten-haben-eine-schreibende-rolle`. *Absehbar:* entfallen, wenn der vor dem
   Start schließt oder der Auftraggeber die Rolle setzt; sonst eingetreten, Liefer-Punkt 2 wartet.
2. **Der Matrix-Slice berührt `spec/spezifikation.md` ebenfalls.** Er trägt die Regel, dass die
   Spec-Straten nicht nach außen zeigen, und ist noch nicht angelegt. Zwei Slices an derselben
   Datei brauchen eine Reihenfolge. *Absehbar:* entfallen, wenn der Matrix-Slice mit Kennung
   angelegt ist und die Reihenfolge nennt; sonst weiter offen.
3. **Eine umbenannte Überschrift macht Anker in eingefrorenen Artefakten tot.** Der
   Vorlagen-Bericht verlangt Umbenennungen in `harness/README.md` und `spec/architecture.md`, und
   eingefrorene Artefakte verlinken per Anker in beide Stränge (keine Erwartungswerte):

   ```sh
   F=( docs/reviews docs/plan/planning/done docs/plan/adr )
   git grep -lE '\]\([^)]*harness/README\.md#' -- "${F[@]}" | wc -l                          #  3
   git grep -lE '\]\([^)]*spec/(architecture|spezifikation)\.md#' -- "${F[@]}" | wc -l       # 25
   ```

   *Absehbar:* entfallen, wenn Liefer-Punkt 3 vor jeder Umbenennung entscheidet; sonst
   eingetreten, Beleg in `vorgeschriebener-ortswechsel-macht-adresse-tot`.
4. **Prosa-Adressen auf eine Überschrift sieht kein Gate**, etwa `harness/README.md` §Sensors in
   [`AGENTS.md`](../../../../AGENTS.md) §4 und in den Anweisungssätzen. *Absehbar:* entfallen,
   wenn der Lauf sie per Suche mitzieht; sonst eingetreten.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Ausgang je Instanz (Liefer-Punkt 1 und 2):** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** entfällt hier — dieses Repo fährt Wellen (§2).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo).
`harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) enthalten keine der fünf Dateien.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen; alle Einträge führen die
Sub-Area `*`, gesichtet ist nach Gegenstand. Zähler je Treffer:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`; keine
Erwartungswerte.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `verweise-brechen-beim-ortswechsel` | 6 | verkörpert | eine umbenannte Überschrift verschiebt eine Adresse (Liefer-Punkt 3) |
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4 | verkörpert | §6, Risiko 3 |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |
| `re-baseline-ohne-inventur-slice` | 2 | offen | kein Auftreten: Die Abweichungen bestehen gegen `v6.8.0` ebenso, weil keine der fünf Vorlagen ein Delta hat; sie sind keine nachgereichte Form-Pflicht der neuen Fassung |
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 2 | offen | übernimmt ein Umgliedern eine Überschrift mit Pfad aus der Vorlage, prüft der Lauf den Pfad; das dritte Auftreten wäre eine Lücke |

**Keiner der Einträge erreicht mit diesem Slice zum ersten Mal 3×.**

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

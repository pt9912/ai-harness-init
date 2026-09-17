# Slice slice-spec-straten-zeigen-nicht-nach-aussen: Die Spec-Straten zeigen nicht nach außen, und das Doku-Gate hält das im Dogfood und im Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht fällt negativ aus: `make gates` und `make full-smoke` stehen in §2, und keine
Closure-Bedingung beobachtet mehr als diese DoD.

**Bezug:**
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die Doc-Gate-Startkonfiguration geht ins Ziel),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-001`](../../../../harness/conventions.md#mr-001) (Schärfung des `matrix`-Moduls),
[`MR-054`](../../../../harness/conventions.md#mr-054) (Kriterien für das emittierte Doc-Gate),
[`MR-017`](../../../../harness/conventions.md#mr-017) (emittierte Prüfbereiche fail-closed).

**Berührte Spec-Stellen:** `spezifikation.md §5` · `architecture.md §5`: Dort liegen die
Fundstellen der Sonde (§1). Die Historie beider Dateien bekommt je eine Zeile.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die drei Spec-Straten haben keine Referenz nach außen, weder als Link noch als bloße
`MR-`- oder `ADR-`-Kennung. `make docs-check` hält das im Dogfood, und das emittierte Doku-Gate
trägt dieselbe Regel, ohne dass ein frisch gebootstrapptes Ziel rot startet. `MR`- und
ADR-Einträge dürfen weiter auf die Spec zeigen. Auftrag des Auftraggebers vom 2026-09-16; der
Slice übernimmt dabei den Review-Befund F-5 zu `slice-sprung-auf-v690-wird-vollzogen`: Nach dem
Entfernen der Links verweisen Sätze der Spezifikation noch auf „das Modul", ohne dass ein Bezug
dasteht.

### Die Sonde

Gefahren an einer Wegwerf-Kopie des Arbeitsbaums am Stand `c6d2f731`, mit dem d-check-Pin aus
`d-check.mk` (`v0.74.1`). Die Änderung am `matrix:`-Block von
[`.d-check.yml`](../../../../.d-check.yml) umfasst drei Zeilen:

```yaml
    - {name: aussen, paths: ["**"]}                      # letzte Klasse, First-Match
    - {from: spec-straten, to: aussen, allow: false}     # neue Regel
  exempt-paths: ["docs/plan/adr/README.md", "docs/plan/planning/done/**"]
```

**Warum `exempt-paths`:** Die Status-Prüfung trifft jede klassifizierte Quelle, unabhängig von
den Regeln (d-check `DC-FA-MTX-001.a`). Ohne die Zeile meldeten der ADR-Index und eine
Welle-Datei unter `done/` in der Sonde vom 2026-09-16 `matrix-inactive`.

**Ergebnis:** `d-check: 1522 Datei(en) geprüft, 13 Befund(e)`, alle `matrix-forbidden`
(`grep -c matrix-forbidden <ausgabe>`), 12 in `spec/spezifikation.md` und 1 in
`spec/architecture.md`, kein `matrix-inactive`. Die Fundstellen liefert
`grep matrix-forbidden <ausgabe> | cut -f1,2`. Nach Ziel geordnet:

| Ziel der Referenz | Fundstellen |
|---|---|
| Adaptions-Block (`harness/conventions.md`, zwei `MR`-Anker) | 2 — je 1 in `spezifikation.md` und `architecture.md` |
| Carveout `CO-002` | 5 |
| `docs/user/claude-hooks-referenz.md` | 3 |
| `docs/reviews/**` | 2 |
| `AGENTS.md` | 1 |

**Gegenprobe:** Mit einem angehängten Link aus `spec/architecture.md` auf den ADR-Index steigt
die Zahl auf 14, und die neue Zeile lautet
`Referenz spec-straten → aussen ist nicht erlaubt`. Die Ausnahme in `exempt-paths` macht den
Index also nicht zu einem erlaubten Ziel. Die zwölf Links in den vendored Baum, die die Sonde
vom 2026-09-16 noch zählte, hat der Sprung-Slice schon entfernt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Historie des Lastenhefts im Dogfood bleibt ausgenommen** (`exclude-sections`). *Bestand
  bleibt bewusst stehen:* Das Lastenheft ändert sich nur per Change Request des Auftraggebers.
  Das emittierte Template nimmt `Historie` nicht aus; was daraus im Ziel folgt, misst DoD 2.
- **Der Abschnitt über die erklärten Abweichungen vom Observability-Modul in
  `spec/spezifikation.md` wird nicht in den Adaptions-Block verlegt.** *Anderer Vorgang einer
  anderen Rolle:* Den Adaptions-Block schreibt der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Dieser Slice entfernt dort nur die Referenzen;
  ob der Abschnitt umzieht, entscheidet der Architect vor dem Start (§4).
- **Keine Gliederungs-Änderung an `spec/spezifikation.md`.** *Ein Folge-Slice übernimmt sie:*
  `slice-gliederung-der-instanzen-ohne-vorlagen-delta` (Überschneidung an derselben Datei, §6).
- **Keine Festlegung, welche Rolle die Spec-Straten schreibt.** *Ein Folge-Slice übernimmt sie:*
  `slice-151-spec-straten-haben-eine-schreibende-rolle` (§6, Risiko 4).
- **Die Gegenrichtung bleibt offen:** Verweise aus `MR`- und ADR-Einträgen auf die Spec bleiben
  erlaubt. *Anderer Vorgang*, so beauftragt.
- **Kein Referenz-Ventil (`ignore-refs`) für eine Fundstelle.** *Anderer Vorgang:* Jedes Paar
  ist eine Senkung mit eigener ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5 und §3.11).

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

Drei Liefer-Punkte auf zwei Ebenen: Dogfood (Konfiguration und Spec) und Emission (Template und
seine Tests).

- [ ] **1 — Im Dogfood steht die Regel, und der Bestand hält sie.**
      - Der `matrix:`-Block in [`.d-check.yml`](../../../../.d-check.yml) trägt die drei Zeilen
        aus §1.
      - Jede Fundstelle der Sonde ist aufgelöst: Die Aussage bleibt, die Referenz fällt
        (Setzung des Auftraggebers vom 2026-09-16). Das gilt auch für die zwei `MR`-Nennungen in
        §5 und die Rückbezüge ohne Ziel aus F-5.
      - `make docs-check` meldet `0 Befund(e)`.
      - Die Historie von `spezifikation.md` und `architecture.md` trägt je eine Zeile.
      - **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): Ein Link aus einem
        Spec-Stratum auf den ADR-Index färbt `matrix-forbidden`, und die Meldung nennt die neue
        Regel. Das Kommando steht im Umsetzungs-Commit.
- [ ] **2 — Die emittierte Regel geht ins Ziel, und das Ziel startet grün.**
      - `internal/emit/templates/d-check.yml` trägt Klasse und Regel; der Kopfkommentar des
        `matrix`-Blocks nennt die neue Position.
      - `make full-smoke` ist grün, das Ziel startet also grün.
      - Eine Referenz aus einem Spec-Stratum des Ziels auf eine Datei außerhalb färbt das
        emittierte Gate rot, rot gesehen, im E2E oder als Fall in `make test`.
      - Ob die Historie im Ziel ausgenommen wird, ist gemessen und nicht angenommen.
- [ ] **3 — Für bloße Kennungen ist entschieden, wer sie fängt, und die Entscheidung ist
      belegt.** Möglich sind zwei Wege:
      - `token`-Klassen für `MR-` und `ADR-` in beiden Konfigurationen (d-check `DC-FA-MTX-003`);
      - oder der Nachweis, dass `ids` mit `link-policy: always` die bloße Kennung in einem
        Spec-Stratum schon fängt. So begründet das emittierte Template heute, warum dort kein
        `ADR`-Token steht.

      Auf beiden Ebenen gilt dasselbe: Eine bloße `MR-`-Kennung in einem Spec-Stratum ist rot
      gesehen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)
      nennt beim Modul `matrix` die neue Klasse und ihre Grenze.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
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
| [`.d-check.yml`](../../../../.d-check.yml) (`matrix:`) | update | Klasse, Regel, `exempt-paths` (DoD 1) |
| `spec/spezifikation.md` §5, §7 | update | zwölf Fundstellen, Rückbezüge aus F-5, Historie-Zeile |
| `spec/architecture.md` §5, Historie | update | eine Fundstelle, Historie-Zeile |
| `internal/emit/templates/d-check.yml` | update | Klasse, Regel, Kopfkommentar (DoD 2) |
| Test der emittierten Konfiguration (die Datei nennt der Implementer) | update | [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7): Regel vorhanden, Gegenbeispiel rot |
| `harness/tools/full-smoke.sh` | update, falls das Gegenbeispiel im E2E läuft | [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| `test/mutations/` | neu, falls der neue Wächter ein Test ist | Register `neuer-waechter-ohne-mutations-fall` (§8) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | Modul `matrix` |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und ein Architect-Verdikt liegt als
Artefakt vor. Es beantwortet drei Fragen:

- **(a)** Bindet [`MR-054`](../../../../harness/conventions.md#mr-054) auch eine
  **Regel**-Änderung in einem Modul, das im emittierten Gate schon aktiv ist, oder nur die
  Aufnahme eines Moduls?
- **(b)** Ist `exempt-paths` eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5? Die
  zwei Pfade sind heute keiner Klasse zugeordnet, die Ausnahme nimmt ihnen also nichts, was sie
  heute tragen.
- **(c)** Bleibt der Abweichungs-Abschnitt in der Spezifikation, oder wandert er in den
  Adaptions-Block?

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Mehr als die Hälfte der Fundstellen
  lässt sich nicht durch bloßes Entfernen der Referenz auflösen, weil die Aussage ohne ihre
  Quelle umformuliert werden muss. Dann werden Dogfood (DoD 1) und Emission (DoD 2 und 3)
  getrennt geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Eine von zwei Bedingungen genügt.
  - `make full-smoke` wird mit der emittierten Regel rot, weil eine vendored Spec-Vorlage im
    Ziel eine Referenz nach außen trägt, die das Ziel nicht ändern darf. Die Entscheidung liegt
    dann beim Architect.
  - Oder der gepinnte d-check kann die Regel nicht ausdrücken. Das ist dann eine Anforderung an
    das Nachbar-Repo, keine Grenze.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Mit aktiver Regel meldet `make docs-check` `0 Befund(e)`, und die Gegenprobe aus DoD 1 ist rot
   gesehen.
2. Mit der emittierten Regel ist `make full-smoke` grün, und das Gegenbeispiel aus DoD 2 ist rot
   gesehen.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Eine Aussage trägt ohne ihre Quelle nicht.** Wer nur die Referenz entfernt, lässt einen
   Rückbezug ohne Ziel stehen (F-5), und wer umformuliert, kann die Aussage verschieben.
   *Absehbar:* entfallen, wenn je Fundstelle die Aussage ohne Quelle geprüft ist; sonst
   eingetreten, mit Beleg in `umschrift-eines-zitats-aendert-die-aussage`. — **Ausgang:** <offen>
2. **Das emittierte Gate startet rot.** Nimmt das Template `Historie` nicht aus und trägt eine
   Spec-Vorlage dort eine Referenz nach außen, ist ein frisches Ziel rot. *Absehbar:* entfallen,
   wenn `make full-smoke` grün ist; sonst eingetreten, Rückführung nach `open`. —
   **Ausgang:** <offen>
3. **Zwei Slices greifen an dieselbe Datei:** Dieser und
   `slice-gliederung-der-instanzen-ohne-vorlagen-delta` ändern `spec/spezifikation.md`. Das ist
   hier genannt, nicht aufgelöst. *Absehbar:* entfallen, wenn beide nacheinander laufen. —
   **Ausgang:** <offen>
4. **Für die Spec-Straten benennt keine Quelle die schreibende Rolle.** Die Setzung vom
   2026-09-16 ließ die Verweise den Implementer im Sprung-Slice nachziehen; ob sie auch hier
   gilt, sagt sie nicht. `slice-151-spec-straten-haben-eine-schreibende-rolle` ist die Adresse.
   *Absehbar:* entfallen, wenn `slice-151` vorher schließt oder der Auftraggeber setzt; sonst
   eingetreten, mit Beleg in `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`.
   — **Ausgang:** <offen>
5. **`exempt-paths` wird als Senkung gelesen, ohne ihr Gate-Verhalten zu messen.** *Absehbar:*
   entfallen durch Start-Frage (b) und die Gegenprobe aus §1; sonst eingetreten, mit Beleg in
   `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`. — **Ausgang:** <offen>

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
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** offen bis zur Closure.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (gesamtes Repo). Der
Slice ändert `spec/`, `.d-check.yml`, `internal/emit/` und `harness/sensors/`, und keine engere
deklarierte Sub-Area umschließt das. `harness/tools/` (`TOOLS`) ist nur berührt, wenn das
Gegenbeispiel im E2E läuft. `.codex/` (`CODEX`) ist nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`, gesichtet
ist deshalb nach Gegenstand. Den Zähler je Treffer liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `neuer-waechter-ohne-mutations-fall` | 8 | verkörpert | die neue Regel ist ein Wächter (§3, `test/mutations/`) |
| `zusage-ohne-herstellbares-gegenbeispiel` | 3 | verkörpert | DoD 1 bis 3 verlangen je ein rot gesehenes Gegenbeispiel |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |
| `umschrift-eines-zitats-aendert-die-aussage` | 1 | offen | §6, Risiko 1 |
| `spec-aenderung-ohne-historie-zeile` | 1 | offen | DoD 1 verlangt die Historie-Zeile |
| `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` | 1 | offen | §6, Risiko 4 |
| `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens` | 1 | offen | §6, Risiko 5 |
| `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` | 1 | offen | DoD-Update in `harness/sensors/docs-check.md` nennt die Grenze der Regel |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 1 | offen | DoD 1 und 2 ziehen beide Ebenen zugleich |

**Kein Eintrag erreicht mit diesem Slice absehbar 3×.** Die drei Einträge mit mindestens drei
Belegen tragen `verkörpert` oder `geplant`, und die genannte Kennung liegt als Datei in `open/`.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

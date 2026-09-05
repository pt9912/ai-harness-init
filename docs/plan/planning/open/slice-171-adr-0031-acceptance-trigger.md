# Slice slice-171: ADR-0031 durchläuft ihren Acceptance-Trigger

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine.

**Bezug:** [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
(der Gegenstand), [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md)
(deren Festlegung 3 der Gegenstand anwendet),
[ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
(Nachbarfall; ihr Acceptance-Trigger liegt bei
[slice-152](slice-152-adr-0029-acceptance-trigger.md) — derselbe Bauplan),
Baseline-Regelwerk `grundlagen-bootstrap.md` §Vier Trigger-Klassen
(Acceptance-Trigger), [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md).

**Berührte Spec-Stellen:** `—`.
[ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
entscheidet die regierende Fassung eines Migrations-Sprungs und den Ort einer
Zielstand-Setzung; sie ändert kein Spec-Stratum.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). Der
Liefergegenstand ist ein ADR-Status-Übergang und damit **Architect**-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.8, Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Regeln); die Konsistenz-Prüfung davor liegt
beim Reviewer.

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

[ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
steht auf `Proposed` und hat keinen Träger für ihren Acceptance-Trigger —
gemessen mit
`git grep -l 'adr/0031-' -- docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress 'docs/plan/planning/*.md'`,
das vor diesem Plan **nichts** ausgab. Ein Acceptance-Trigger ohne Träger ist
eine Absichtserklärung mit Verfallsdatum (Baseline-Regelwerk
`modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 2). Dieser Slice holt
den Schritt nach: Reviewer-Konsistenzprüfung, dann `Accepted` durch den
Architect.

**Der Schnitt ist eine ausdrückliche Übergabe, keine Eigeninitiative.** Die
Closure von [slice-163](../done/slice-163-regierende-fassung-des-sprungs.md) §7
führt ihn als *Offene Übergabe an den Planner* und nennt dort ausdrücklich
keine Folge-Slice-ID, weil das Schneiden Planner-Arbeit ist. Der
Trigger-Audit der Closure von
[welle-14](../done/welle-14-re-baseline.md) hat sie aufgenommen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      durchläuft den Acceptance-Trigger und trägt ihn.** Ein Reviewer-Durchgang
      prüft auf Konsistenz (Baseline-Regelwerk `modul-08-agentenrollen.md`
      §Rollen-Regeln); danach setzt der Architect `**Status:** Accepted` und
      ergänzt die Geschichte-Tabelle um die Zeile, die den Trigger benennt. Der
      ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt
      denselben Status (`grep -c '0031.*Proposed' docs/plan/adr/README.md` →
      **0** danach).
- [ ] **(2) Der vierte Re-Evaluierungs-Trigger der ADR bekommt sein Verdikt.**
      Er lautet *„wenn §Baseline von `harness/conventions.md` seinen Ort
      verlässt"* und nennt als beobachtbaren Anlass die Verzeichnis-Form des
      Adaptions-Blocks — die **steht** seit
      [slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md)
      ([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)),
      während §Baseline seinen Ort **nicht** verlassen hat
      (`grep -c '^## Baseline' harness/conventions.md` → **1**). Anlass
      eingetreten, Bedingung nicht: entweder *nicht gefeuert* mit dieser
      Messung als Beleg, oder — wenn die Prüfung den Anlass als die eigentliche
      Bedingung liest — Neufassung des Triggers. Ein dritter Ausgang ist keiner.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis
      `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler
      wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls
      eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) | update (Status + Geschichte-Zeile + Trigger-Verdikt), Architect | DoD (1)/(2); nach `Accepted` immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4) — DoD (2) gehört **vor** den Status-Wechsel |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update (Status-Spalte), Architect | DoD (1) — derivatives Register desselben Originals ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| [`docs/plan/planning/observations/README.md`](../observations/README.md) | update | Register-Pflicht (nicht mitgezählt) |

**Commit-Zuschnitt nach Rollen:** ein Reviewer-Durchgang ohne eigenen Commit
(Konsistenz ist Voraussetzung, kein Artefakt), danach ein Architect-Commit für
den Status-Übergang, zuletzt die Planner-Closure.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit. Keine
technische Vorbedingung. **Nicht** blockiert auf
[slice-152](slice-152-adr-0029-acceptance-trigger.md): die zwei ADRs
entscheiden verschiedene Gegenstände und hängen nicht aneinander.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn DoD (2) eine
  Neufassung des Triggers verlangt und die eine eigene Ableitung braucht.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Konsistenzprüfung
  einen Rollen-Widerspruch findet, der nach Baseline-Regelwerk
  `modul-08-agentenrollen.md` §Konflikt-Pfad ein Verdikt oder eine Folge-ADR
  statt eines Status-Wechsels verlangt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Erstens:**
`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md`
→ **1**, mit einer Geschichte-Zeile, die den Acceptance-Trigger nennt.
**Zweitens:** der vierte Re-Evaluierungs-Trigger trägt sein Verdikt als Text in
der ADR, mit dem Kommando daneben, das die Lage von §Baseline misst. Dazu die
Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein
Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Konsistenzprüfung findet einen inhaltlichen Einwand** gegen eine der
  zwei Festlegungen von
  [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md).
  — **Ausgang:** <entfallen: nur Konsistenz-Bestätigung | eingetreten: die ADR
  wird vor der Annahme korrigiert (sie ist noch `Proposed`, keine Folge-ADR
  nötig) — Beleg in der Geschichte-Tabelle>
- **Festlegung 1 ist beim Bearbeiten schon verbraucht**: sie gilt laut ADR
  **nur** für `v5.12.0` → `v5.18.0`, und dieser Sprung ist vollzogen. Eine
  Annahme, die nichts mehr regiert, ist eine Formalie. — **Ausgang:**
  <entfallen: Festlegung 2 (Ort der Zielstand-Setzung) wirkt fort und trägt die
  Annahme allein | eingetreten: der Umfang der Annahme wird in der
  Geschichte-Zeile eingeschränkt>
- **Die Klasse *`Proposed`-ADR ohne Träger* wiederholt sich**, statt mit
  diesem Slice zu enden — sie hat mit
  [ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md),
  [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
  und diesem Fall drei Instanzen, und ihre Kennung entsteht erst in der Closure
  von [slice-152](slice-152-adr-0029-acceptance-trigger.md) (dessen DoD-Punkt 6
  sie vergibt). — **Ausgang:** <weiter offen → jene Kennung im Register,
  Zähler erhöht mit Beleg `slice-171`>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `docs/plan/adr/`. Es fällt
unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
— **alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit
nach dem *Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
(4×, *wer ein Norm-Artefakt schreiben darf*) berührt diesen Slice am Rand — der
Status-Übergang selbst ist unstrittig Architect-Arbeit, die Frage jener Zeile
betrifft die Anweisungssätze und nicht die ADR; der Slice erhöht sie nicht.
[`BEO-ALL/byte-gleichheit-als-aussage-ueber-die-regel-gelesen`](../observations/BEO-ALL/byte-gleichheit-als-aussage-ueber-die-regel-gelesen/observation.md) (1×, Byte-Gleichheit eines Regelwerks-Abschnitts
als Aussage über die Regel) ist der **Gegenstand** der zu prüfenden ADR und
steht dort als §Kontext.
[`BEO-ALL/ausloesender-trigger-ohne-traeger-im-migrierenden-vorgang`](../observations/BEO-ALL/ausloesender-trigger-ohne-traeger-im-migrierenden-vorgang/observation.md) (2×, *ein Auflösungs-Trigger feuert und bleibt
unbemerkt*) trägt DoD (2): der vierte Re-Evaluierungs-Trigger ist genau dieser
Fall, mit Anlass eingetreten und Bedingung offen.
[`BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md) (1×, Plan-Umfang) ist auf diesen Plan angewandt
statt notiert. Keine weiteren Treffer.

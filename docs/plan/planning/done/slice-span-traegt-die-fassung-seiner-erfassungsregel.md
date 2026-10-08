# Slice slice-span-traegt-die-fassung-seiner-erfassungsregel: Der Span trägt die Fassung seiner Erfassungsregel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt
nur durch `git mv` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** [welle-erfassungsschicht-im-ziel](../welle-erfassungsschicht-im-ziel.md) — erster Slice:
der Wechsel leerer Werte auf *nicht bekannt* (`slice-agent-role-traegt-nicht-bekannt`) ist der nächste
Bedeutungswechsel und trägt seine Fassung dann schon.

**Bezug:** [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md).

**Berührte Spec-Stellen:** [`spezifikation.md` §5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder).

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-10-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Leser des Span-Bestands kann einen Regelwechsel von einer Verhaltensänderung des
Beobachteten trennen, weil jede Zeile die Fassung der Erfassungsregel nennt, unter der sie entstand.

**Ausdrücklich NICHT in diesem Slice:**

- Eine Migration des Bestands — der Bestand ist gitignored, maschinenlokal und append-only; alte
  Zeilen bleiben ohne Fassung und gelten als *nicht bekannt*.
- Neue Span-Felder jenseits der Fassungs-Angabe — anderer Vorgang.

## 2. Definition of Done

- [x] Entschieden und in `spec/spezifikation.md` §5 begründet: ein Fassungs-Feld je Span **oder** eine
      datierte Wechsel-Zeile je Bedeutungswechsel.
- [x] Umgesetzt, und `make span-report` trennt die Fassungen; ein Span ohne bzw. mit falscher Fassung
      ist rot gesehen (bei der Feld-Variante).
- [x] Die bisherigen Bedeutungswechsel (`program`-Feld) sind in der gewählten Form nachgetragen.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder in §7 notiert, dass keine Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die Welle-Closure.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5 | update | gewählt ist die Feld-Variante: Feldzeile `rule_version` (`SPEC-088`), Regel mit Begründung und Zählregel (`SPEC-089`), Fassungs-Tabelle 1–4 mit den bisherigen Bedeutungswechseln (`SPEC-090`–`SPEC-093`), zwei Zusicherungen (`SPEC-094`, `SPEC-095`) ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)) |
| `internal/span/` (`emit.go`, `ruleversion.go`, `fieldlist.go`) | update | Pflichtfeld `rule_version` mit der Konstante der laufenden Fassung; die emittierte Feldliste trägt seine Frage |
| `internal/report/report.go` | update | Zeile `Erfassungsregel:` nennt je Fassung die lesbaren Zeilen, ohne Feld als *nicht bekannt* |
| Go-Tests, Mutations-Fälle 592–596 | neu/update | Fassung geschrieben, an die Spec-Tabelle gekoppelt, im Bericht getrennt; 595/596 binden Leer-Guard und untere Grenze der Fassungs-Zeile; `0` zählt als *nicht bekannt* (`TestAggregiere_FassungNullIstNichtBekannt`) |
| `harness/sensors/span-report.md`, `docs/user/benutzerhandbuch.md` | update | Ausgabe des Berichts um die Fassungs-Zeile |

## 4. Trigger

**Start** (`next` → `in-progress`): priorisiert, `Verantwortlich:` gesetzt.

- `in-progress` → `next`: die Feld-Variante verlangt eine Änderung an [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) selbst (Change
  Request) — dann trennt sich der Spec-Teil ab. Lastenheft 0.25.1 nennt die Fassung nicht; ein
  Pflichtfeld mehr in der geschlossenen Feldliste ist eine Festlegung in §5, kein CR, solange
  [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) es nicht ausschließt.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Fassungs-Angabe wird bei einem künftigen Regelwechsel nicht hochgezählt — **Ausgang:** weiter
  offen → `BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (Beleg dieses Slice); ob ein
  Bedeutungswechsel erkannt und hochgezählt wird, hält kein Wächter (`SPEC-094`).

## 7. Closure-Notiz

- **Was hat funktioniert:** Feld-Variante `rule_version` (`SPEC-088`/`SPEC-089`), Fassungs-Tabelle 1–4 (`SPEC-090`–`SPEC-093`); `TestCurrentRuleVersionIsTheLastSpecFassung` hält die Konstante an der realen Tabelle, Fälle 592–596 färben rot (`make mutate` → ok). Review `docs/reviews/2026-10-08-span-fassung-review.md` (0 HIGH, 0 MEDIUM; F-1–F-4 in `b24e7315`), Verifikation `docs/reviews/2026-10-08-span-fassung-verifikation.md` (DoD 1–5 bestätigt; V-1 in `2236a0cd`), CI-Lauf `37775749099` grün.
- **Was ging anders als geplant:** Die Zählregel bekam ihre Einheit (je Release) erst aus Review-F-4; Fälle 595/596 und `TestAggregiere_FassungNullIstNichtBekannt` stehen aus Review und Verifikation in §3.
- **Grenzen:** (1) Der Träger aus einem Zwischenstand zwischen zwei Releases (`make host-bin`) schreibt die neue Fassung schon, bevor das Release sie trägt — die Zählregel zählt je Release, der Träger je Build (F-4). (2) `rule_version` `0` gilt als *nicht bekannt* (V-1); `TestAggregiere_FassungNullIstNichtBekannt` bindet es und ist rot gesehen, ein Mutations-Fall dafür existiert nicht.
- **Steering-Loop-Eintrag:** neuer Sensor — `TestCurrentRuleVersionIsTheLastSpecFassung` und Fälle 592–596 in `test/mutations/` färben rot, sobald die geschriebene Fassung von der letzten Zeile der Fassungs-Tabelle abweicht oder der Bericht die Fassungen nicht trennt; benannte Spec-Lücke — `SPEC-094`: das Erkennen eines Bedeutungswechsels hält kein Wächter ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)).
- **Beobachtungs-Register (`../observations/`):** Beleg in `BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (Risiko §6, weiter offen) und in `BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` (Finding-Klasse Review-F-2/F-3), je `evidence/slice-span-traegt-die-fassung-seiner-erfassungsregel.md`. Der Stand des ersten nennt weiter diesen Slice als `geplant`; seinen Ausgang nach der Lieferung entscheidet der Zug Planner → Architect → Planner.
- **Folge-Slices:** keine.
- **Risiken aus §6:** (1) weiter offen → Register, s. o.
- **Drei Paarungen:** dieses Repo fährt Wellen — die Welle-Closure von `welle-erfassungsschicht-im-ziel` prüft sie erneut; die Slice-Closure fährt sie nach dem `git mv` selbst (Zeile unten).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), Kürzel `ALL`.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe`
über der Schwelle, Stand `geplant` auf diesen Slice.

Alle berührten Sub-Areas GF.


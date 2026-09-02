# Slice slice-148: `spec/architecture.md` trägt ihr `ARC-<NNN>`-Pflichtfeld

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — Teil von Durchgang 2 (*Form*), abgetrennt aus
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1/§6, dessen Form-Diff-Protokoll
das neue Pflichtfeld für dieses Artefakt bereits gemessen, aber nicht umgesetzt hat.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Doc-Gate, das per Abschnittsname statt per ID auf eine verschobene Zeile zeigen könnte, ist
das stille Grün, das diese Anforderung ausschließt),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (jede nicht übernommene
Position der Ziel-Form ist als Abweichung zu begründen).

**Berührte Spec-Stellen:** `architecture.md §1` (Komponenten-Übersicht, vergibt `ARC-<NNN>`),
`§2` (Schichten und Constraints, referenziert die Kennung), `§3` (externe Abhängigkeiten, vergibt
`ARC-<NNN>`).

**Verantwortlich:** — bis zur Priorisierung. **Keine Quelle benennt eine schreibende Rolle für
dieses Artefakt** — [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) grenzt die
Architect-Zuordnung ausdrücklich auf `AGENTS.md` §3 und den Adaptions-Block in
`harness/conventions.md` ein (*„Über die übrigen Norm-Artefakte trifft diese ADR **keine**
Aussage"*), und Baseline-Regelwerk `modul-03-spec.md` nennt für keines der drei Spec-Strata eine
Rolle. `AGENTS.md` §3.8 bestätigt das ausdrücklich für dieses Artefakt. Siehe §6, Risiko
*Rollenfrage* — dieselbe offene Frage wie [slice-147](slice-147-spezifikation-traegt-ihr-id-schema.md),
unabhängig beantwortbar, weil ein anderes Artefakt.

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

`spec/architecture.md` bekommt das Pflichtfeld der Ziel-Fassung: `ARC-<NNN>` je Komponente (§1)
und je externer Abhängigkeit (§3), die Schichten-Tabelle in §2 referenziert die Kennung. Gemessen,
nicht neu entdeckt — der Form-Diff aus
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1 führt diesen Ausgang bereits als
*„neues Pflichtfeld"*; dieser Slice ist die Umsetzung, die dort als zu groß für den einen
Durchgang zurückgeführt wurde.

**Die Ripple-Menge ist kleiner als bei `spezifikation.md` und liegt vollständig in immutablen
ADRs.** Zwei lebende Dateien außerhalb der Zeitdokumente zeigen per Abschnitts-Anker auf
`spec/architecture.md#…`
(`grep -rl 'architecture.md#' --include='*.md' . | grep -v '^\./\.harness/baseline' | grep -v
'^\./docs/reviews' | grep -v 'planning/done' | grep -v '^\./\.harness' | wc -l` → **2**):
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) und
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), beide `Status:
Accepted` und beide auf **dieselbe** Zeile, `§5 Idempotenz, Fragment-Assembly und Resume`. Weder
Achse berührt dieser Slice inhaltlich — `ARC-<NNN>` wird in §1–§3 vergeben, §5 bleibt unangetastet.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) `ARC-<NNN>` je Komponente (§1) und externer Abhängigkeit (§3) vergeben, die
      Schichten-Tabelle (§2) referenziert die Kennung.** Ziel-Form aus dem Form-Diff-Protokoll
      ([slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1, Zeile
      `spec/architecture.md`). Abschnitts-Überschriften bleiben unverändert, §5 bleibt
      inhaltlich unberührt.
- [ ] **(2) Gegenprobe: `spec/architecture.md#5-idempotenz-fragment-assembly-und-resume` bleibt
      auflösbar.** Beide referenzierenden Accepted-ADRs ([`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md),
      [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)) sind nach
      `AGENTS.md` §3.4 immutabel — dieser Slice ändert keine von ihnen; die Gegenprobe ist
      Existenz-, keine Korrektur-Pflicht.
- [ ] `make gates` grün.
- [ ] Doku-Update: keiner über dieses Artefakt hinaus — die Kennungen sind die Doku-Änderung
      selbst.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register entfällt dauerhaft: dieses Repo hat keinen Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler
      +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der nächsten Welle-Closure geprüft, nicht hier.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/architecture.md`](../../../../spec/architecture.md) | update | `ARC-<NNN>` §1/§3, Referenz in §2 |
| [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md), [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) | prüfen, keine Änderung | Gegenprobe DoD (2) — beide immutabel, beide zeigen auf §5, das dieser Slice nicht anfasst |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice mehr (WIP-Limit 1) **und**
die Rollenfrage aus §6 ist entschieden — entweder durch eine benannte Quelle oder durch
Priorisierung mit `Verantwortlich:` = Implementer-Rolleninhaber als Default.

**Keine Reihenfolge-Bindung innerhalb der Welle.** Dieser Slice hängt an keinem anderen Mitglied
von [welle-10](../welle-10-re-baseline.md): [slice-147](slice-147-spezifikation-traegt-ihr-id-schema.md)
berührt ein anderes Artefakt mit eigener Referenz-Menge, und die fortgeführte
`harness/conventions.md`-Arbeit in [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md)
berührt keine spec-Datei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): unwahrscheinlich bei einer Ripple-Menge
  von zwei Dateien — träte sie dennoch ein (etwa weil §1/§3 stärker umgebaut werden müssen, als der
  Form-Diff zeigt), trennt der Schnitt Kennungs-Vergabe und Umbau.
- `in-progress` → `open` (blockiert — Carveout?): die Gegenprobe bricht an einem der zwei
  Accepted-ADR-Zeiger — dann wartet dieser Slice auf ein Folge-ADR (Architect-Zug), kein Carveout.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Kriterium 1** — DoD (1)/(2) abgehakt, die Kommando-Ausgabe aus §1 erneut gefahren: weiterhin
**2** lebende Referenzstellen, keine meldet `target-missing`. **Kriterium 2** — `make gates` grün.
**Lerneintrag** in §7 — ohne ihn geht der Slice nicht nach `done/`.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Rollenfrage: wer darf `spec/architecture.md` schreiben?** Keine kanonische Quelle benennt eine
  Rolle (Kopf oben). Wird ohne Klärung priorisiert, entscheidet der Default aus
  Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine (Implementer-
  Rolleninhaber) — das ist zulässig, aber eine **Setzung**, keine Ableitung, und sollte als solche
  im Priorisierungs-Commit benannt werden. — **Ausgang:** <eingetreten: eine Quelle wurde benannt,
  Feld gesetzt | entfallen: n/a — die Lücke besteht per Messung | weiter offen: notiert für die
  nächste Slice-Closure, kein neuer BEO-Eintrag vor Closure dieses Slice>
- **Die Gegenprobe (DoD 2) findet einen Anker-Bruch an einem der zwei Accepted-ADRs.** Beide
  zeigen auf dieselbe Zeile (§5), die dieser Slice nicht anfasst — das Risiko ist damit klein,
  aber nicht null, falls die Kennungs-Vergabe in §1/§3 eine Umnummerierung der nachfolgenden
  Abschnitte erzwingt. — **Ausgang:** <eingetreten: Folge-ADR mit `supersedes` vorgeschlagen,
  dieser Slice liefert nur die Kennungen und dokumentiert den Bruch | entfallen: §5 bleibt an
  Position und Anker unverändert (Erwartungswert dieses Plans) | weiter offen>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `spec/` — Greenfield-Bestand nach der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md), dieselbe
Einordnung wie in [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §8,
[slice-136](slice-136-roadmap-traegt-die-ziel-form.md) §8 und
[slice-147](slice-147-spezifikation-traegt-ihr-id-schema.md) §8.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`docs/plan/planning/observations.md`, neun Einträge `BEO-001`–`BEO-009`, Sub-Area durchweg `*`
per `BEO-004`). Inhaltlich passt keiner auf eine ID-Vergabe in `spec/architecture.md` — dieselbe
Prüfung wie in [slice-147](slice-147-spezifikation-traegt-ihr-id-schema.md) §8, hier mit kleinerer
Ripple-Menge (§1) und identischem Ergebnis. **Keine unmittelbaren Treffer über die pauschale
`*`-Zuordnung hinaus.**

Alle berührten Sub-Areas GF: `spec/` gehört zum Greenfield-Bestand.

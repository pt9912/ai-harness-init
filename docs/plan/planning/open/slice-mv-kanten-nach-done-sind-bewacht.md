# Slice slice-mv-kanten-nach-done-sind-bewacht: Die Kanten `open → done` und `next → done` von `make slice-mv` haben einen Wächter, im Dogfood und im Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (das Ziel, in dem
`make full-smoke` misst), [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
(die zwei Kanten kommen mit `v6.9.0`).

**Berührte Spec-Stellen:** —

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

**Ziel:** Ein erfolgreicher Wechsel `open → done` und `next → done` mit `make slice-mv` ist
bewacht, im Dogfood-Werkzeug `harness/tools/slice-mv.sh` und in der emittierten Fassung im
gebootstrappten Ziel. Die Tabelle der Kanten in
[`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze wird damit von
einer Messung zu einer bewachten Zusage.

**Herkunft:** `slice-stilllegungs-kanten-sind-gemessen` hat die Kanten gemessen und festgestellt,
dass kein Wächter sie hält. Die Tests in `test/slice-mv.bats` rufen die Ersetzungs-Funktionen ohne
Repository auf, und das gepinnte bats-Image führt kein `git`. [`make full-smoke`](../../../../harness/sensors/full-smoke.md)
fährt im Ziel `TO=done` nur in zwei Sperr-Fällen (`grep -n 'slice-mv SLICE' harness/tools/full-smoke.sh`).
Review-Befund F-2 zu jenem Slice verlangt für den Wächter eine Adresse; das ist sie.

**Warum nicht vor der Gruppierung der Go-Slices.** Die Gruppierung nimmt die Kanten einmal, in
Serie, und jeder Wechsel hat dort ein sofortiges Urteil: den Exit-Code,
`git show --numstat --format= -M HEAD~1` auf den Move-Commit (reiner Rename) und
`make docs-check`. Die Messung zeigt, dass das beobachtbare Versagen der Kanten `target-missing`
ist, und das färbt `make docs-check`. Der Wächter schützt gegen Regression über die Zeit, nicht
diesen einen Lauf. Die Messung ist bei der Gruppierung frisch, weil
`slice-mv-zieht-praefixlose-geschwister-verweise-nach` das Werkzeug davor noch einmal ändert und
beide Kanten neu misst. **Die Bedingung dafür:** Der Lauf, der die Kanten nimmt, fährt die drei
Prüfungen je Wechsel. Ihr Träger ist
[`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) §Einen Slice
stilllegen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die präfixlosen Geschwister-Verweise.** *Ein anderer Slice übernimmt sie:*
  `slice-mv-zieht-praefixlose-geschwister-verweise-nach`. Dieser Slice bewacht dessen Ergebnis
  und startet darum danach (§4).
- **Die Form der Stilllegung** (leere Liefer-Punkte, Zeile `Gegenstand:`). *Anderer Vorgang:* Das
  Werkzeug prüft sie nicht, und die Anforderung geht an das d-check-Repo.
- **Die übrigen Kanten** (`open → next`, `next → in-progress`, `in-progress → done` und die
  Rückführungen). *Bestand bleibt bewusst stehen:* Sie sind nicht Gegenstand der Messung, und
  `make full-smoke` fährt im Ziel schon einen erfolgreichen Wechsel `TO=next`.
- **Die Gruppierung selbst.** *Anderer Vorgang*, siehe oben.

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

Drei Liefer-Punkte auf zwei Ebenen: Dogfood-Werkzeug und emittierte Fassung im Ziel.

- [ ] **1 — Ein Wächter in `make gates` fährt `harness/tools/slice-mv.sh` über beide Kanten.**
      - Er arbeitet in einem Wegwerf-Repository mit eingehenden Präfix-Verweisen (auch aus
        `done/**` und `docs/reviews/**`), ausgehenden präfixlosen Zielen und präfixlosen
        Geschwister-Verweisen.
      - Er prüft je Kante Exit 0, einen Move-Commit als reinen Rename und einen Nachzug, nach dem
        jeder Verweis auf die bewegte Datei auflöst.
      - **Wo der Wächter läuft, entscheidet der Umsetzungs-Lauf und begründet es.** Zur Wahl
        stehen `git` in der bats-Stufe (`BATS_IMAGE` im `Makefile`) oder ein anderer Weg über ein
        gepinntes Image ([`AGENTS.md`](../../../../AGENTS.md) §3.9).
- [ ] **2 — `make full-smoke` fährt im gebootstrappten Ziel je Kante einen erfolgreichen
      Wechsel.** Das emittierte Doku-Gate des Ziels ist danach ohne Befund. Die
      Stufen-Deklaration folgt der Form in `harness/tools/full-smoke.sh`, und
      `docs/user/e2e-abdeckung.md` ist neu erzeugt (`make e2e-abdeckung`).
- [ ] **3 — Jeder der zwei Wächter ist rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      - Für den Wächter aus DoD 1: ein Fall unter `test/mutations/`, der den Nachzug oder den
        reinen Move bricht. `make mutate` meldet ihn rot, die Meldung ist gelesen.
      - Für den Fall aus DoD 2: ein einmaliges Rot über einer gebrochenen emittierten Fassung,
        mit Kommando im Umsetzungs-Commit. `make mutate` kennt für `make full-smoke` keine
        Fehlschlag-Form.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze
      (`### Kanten …`) nennt die zwei Wächter statt *„Kein Wächter hält die zwei Kanten"*;
      [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md) nennt die neue
      Stufe.
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
| Träger des Wächters aus DoD 1 (bats-Datei oder Skript, dazu ggf. `Makefile`/Image) | neu / update | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `harness/tools/full-smoke.sh` | update | Stufe je Kante ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)) |
| `docs/user/e2e-abdeckung.md` | update, erzeugt | Stufen-Deklaration |
| `test/mutations/<nnn>-slice-mv-…` | neu | DoD 3 |
| [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md), [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md) | update | Doku-Update |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und
`slice-mv-zieht-praefixlose-geschwister-verweise-nach` liegt in `done/`. Der Wächter hält dann
das Werkzeug in der Form, die die Gruppierung benutzt hat. Die Gruppierung der Go-Slices ist
keine Start-Bedingung (§1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Träger aus DoD 1 verlangt einen
  Image-Wechsel mit eigenem Pin und eigener Freshness-Frage. Dann werden DoD 1 und DoD 2 getrennt
  geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Kein gepinntes Image trägt `git` und bats
  zugleich, und ein eigenes Image wäre eine Entscheidung nach
  [`ADR-0003`](../../adr/0003-go-native-binaries.md). Die Entscheidung liegt dann beim
  Architect.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Der Wächter aus DoD 1 läuft in `make gates` grün, und sein Mutations-Fall ist rot gesehen.
2. `make full-smoke` ist grün mit den zwei neuen Wechseln, und ihr Rot ist gesehen.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Wächter misst eine nachgebaute Verdrahtung statt der Stelle, die `make slice-mv` fährt.**
   *Absehbar:* entfallen, wenn der Wächter das Skript so aufruft wie das Rezept; sonst
   eingetreten, mit Beleg in `waechter-misst-die-fixture-statt-der-realen-quelle`. —
   **Ausgang:** <offen>
2. **Die Laufzeit von `make gates` oder `make full-smoke` wächst merklich.** *Absehbar:*
   entfallen, wenn der Zuwachs gemessen und im Umsetzungs-Commit genannt ist. —
   **Ausgang:** <offen>
3. **Die Gruppierung läuft, bevor dieser Slice schließt, und ohne die drei Prüfungen je
   Wechsel.** *Absehbar:* entfallen, wenn der Lauf, der die Kanten nimmt, sie fährt (§1). —
   **Ausgang:** <offen>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** `harness/tools/` (`TOOLS`) trägt das Werkzeug und
`full-smoke.sh`. Test, Image-Pin und Sensor-Dateien liegen in `*`. `.codex/` (`CODEX`) ist nicht
berührt.

**Vorgelagert — offene Beobachtungen sichten:** Gesichtet ist nach Gegenstand; den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`. Keine der Zahlen ist ein
Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md) | 6 | verkörpert in `harness/tools/slice-mv.sh`, `seit slice-144` | der Wächter hält diese Verkörperung für zwei Kanten |
| `neuer-waechter-ohne-mutations-fall` | 8 | verkörpert | DoD 3 |
| `verweis-nachzug-bricht-tree-operand` | 2 | offen | das Wegwerf-Repository aus DoD 1 kann einen Tree-Operanden tragen |
| `benannte-luecke-ohne-ausgang` | 2 | offen | dieser Slice ist der Ausgang einer benannten Lücke |

**Keiner der Einträge erreicht mit diesem Slice absehbar 3×.** Die Einträge ab 3× tragen
`verkörpert`.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

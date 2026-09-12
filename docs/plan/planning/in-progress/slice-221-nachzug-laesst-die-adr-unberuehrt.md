# Slice slice-221: Der Verweis-Nachzug lässt die `Accepted`-ADR unberührt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die drei offenen Wellen führen geschlossene Slice-Listen, und es gibt
keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der Beleg ist ein
Vorschau-Lauf plus `make gates`, beides steht in §2.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der neue Ausschluss bekommt seinen Wächter, statt behauptet zu werden),
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 2
der Gegenstand, Folgepflicht 1 der Auftrag, Festlegung 5 die Sperre, die dieser Slice hebt),
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — Abnahme-Kriterium 1
hält `docs/reviews/**` im Suchraum, unberührt),
[ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted**).

**Berührte Spec-Stellen:** `—` — der Slice ändert die Ausnahmeliste zweier Träger; weder
Lastenheft-Vertrag noch Spezifikation noch Architektur führen sie.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner (ai-harness-init-Team, pt9912). **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Beide Träger des Verweis-Nachzugs — `make slice-mv` und das Unterkommando
`archive-welle` — schreiben nicht mehr in `docs/plan/adr/`. Das ist
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Folgepflicht 1; ihre
Festlegung 5 sperrt den ersten Archiv-Move, bis beide Träger die Ausnahme führen.

**Der Go-Träger trägt die eigentliche Arbeit, und der Grund ist gemessen.** Im Shell-Träger ist es
eine Pathspec-Zeile (`grep -c "':\!" harness/tools/slice-mv.sh` → **1**). Im Go-Träger speist
**eine** Liste drei Leser — `Haenger` (fail-closed-Vorprüfung), `VerweisFund` und `Nachziehen`
(zählender und schreibender Nachzug):
`grep -c 'Suchraum(dateien)' internal/archive/*.go | awk -F: '{s+=$NF} END{print s}'` → **3**.
Trägt man `docs/plan/adr/` dort ein, verliert die Hänger-Vorprüfung **18** Dateien mit **60**
Fundstellen, und der Lauf bliebe grün:

```sh
for r in docs/reviews/*.md; do rb="${r##*/}"; git grep -lF -e "$rb" -- 'docs/plan/adr/*.md'; done | sort -u | wc -l   # 18
for r in docs/reviews/*.md; do rb="${r##*/}"; git grep -cF -e "$rb" -- 'docs/plan/adr/*.md'; done | awk -F: '{s+=$NF} END{print s+0}'   # 60
```

**Keine Erwartungswerte.** Der Ausschluss gehört darum in die zwei Nachzug-Leser, nicht in die
geteilte Liste; `Haenger` behält seinen vollen Suchraum.

**Der Shell-Träger ist heute unbewachtbar, und auch das ist gemessen.** Seine Pathspec-Zeile steht
in `main()`, das `git mv`/`git grep` ruft — das gepinnte `BATS_IMAGE` führt kein `git`, und
`test/slice-mv.bats` erklärt genau deshalb, dass der Beleg für diese Liste **nicht** als bats-Fall
steht, sondern als Vor/Nach-Paar im Skriptkopf
(`grep -c 'BATS_IMAGE fuehrt kein' test/slice-mv.bats` → **1**). Ein Mutations-Zahn auf die Liste
setzt darum voraus, dass sie an **eine** Stelle wandert, die `main()` benutzt und ein bats-Fall
lesen kann; sonst prüft der Test seine eigene Nachbildung
([`AGENTS.md`](../../../../AGENTS.md) §3.6). Das ist Teil des Auftrags, nicht seine Voraussetzung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Archiv-Move selbst.** Zwei eigenständige Fragen stehen davor und nehmen die Sendung an: die
  `[haenger]`-Sperre ([slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md))
  und die `Anwenden`-Lücke ([slice-220](../open/slice-220-plan-ausgang-traegt-eine-kennung.md)). Dieser
  Slice hebt allein die **normative** Sperre aus Festlegung 5.
- **Die zwei `ignore-refs`-Paare.** Festlegung 3 weist sie dem Lauf zu, der den Move vollzieht —
  beide Adressen lösen heute auf, sie jetzt stumm zu schalten nähme eine lebende, richtige Referenz
  aus der Prüfung.
- **[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) selbst.** `Accepted`, nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich;
  `make adr-immutable` färbt rot. Constraint, nicht Gegenstand.
- **Kein status-lesender Schnitt** (`Accepted` gegen `Proposed`). Festlegung 2 verlangt den
  Pfad-Schnitt und nennt die Differenz heute leer; der Status-Schnitt ist ihr
  Re-Evaluierungs-Trigger 3 — ein anderer Vorgang.
- **Schicht-Abgrenzung: kein emittiertes Skelett.** Geltungsbereich der ADR ist dieses Repo; was ein
  Zielrepo bekommt, entscheidet der Vorgang, der die Tool-Ebene entscheidet.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Shell-Träger.** `slice-mv.sh` nimmt `docs/plan/adr` neben `.harness/baseline` aus der
      eingehenden Ersetzung aus, `docs/reviews/` bleibt **drin**. Damit ein Wächter die Zeile
      überhaupt erreicht, gibt sie ihre Pathspec-Liste an **einer** Stelle aus, die `main()` selbst
      benutzt; ein bats-Fall liest genau diese und prüft Mitgliedschaft **und** Nicht-Mitgliedschaft,
      ein `test/mutations/`-Fall (`# verify: test-bats`) nimmt ihr die Zähne — einmal rot gesehen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **Go-Träger.** `VerweisFund` und `Nachziehen` überspringen `docs/plan/adr/`, `Haenger` behält
      seinen vollen Suchraum — `TestHaengerFindetVerweisAusReviewReport` grün,
      `test/mutations/233-archive-welle-go-haenger-suchraum.sh` unverändert wirksam; ein eigener
      Fall (`# verify: test-go`) nimmt dem neuen Ausschluss die Zähne, einmal rot gesehen.
- [ ] **Die Sperre fällt, beobachtbar.** `… archive-welle --vorschau altbestand | grep -c
      'plan/adr'` → **0** (vorher **1**, kein Erwartungswert); dieselbe Vorschau führt weiter genau
      eine Sperre, und sie heißt `[haenger]`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Beide Sensor-Beschreibungen nennen die Ausnahmeliste namentlich und ziehen mit —
      [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) (*„repo-weit außer
      `.harness/baseline/**`"*) und
      [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) (*„nimmt
      allein `.git` und `.harness/baseline/**` aus"*, dazu die Sperren-Aussage aus Festlegung 5).
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
| `harness/tools/slice-mv.sh` | update | Pathspec bekommt `':!docs/plan/adr'` und wandert an **eine** lesbare Stelle |
| `internal/archive/refs.go` | update | der neue Ausschluss greift **hier**, bei den zwei Nachzug-Lesern — nicht in der geteilten Liste |
| `internal/archive/scan.go` | update | benennt den zweiten Suchraum und hält fest, warum `Haenger` ihn **nicht** benutzt |
| `internal/archive/refs_test.go` | update | ADR ausgenommen, `docs/reviews/` drin — die Kalibrierung |
| `test/slice-mv.bats` | update | liest die ausgelagerte Pathspec-Liste — Mitgliedschaft und Gegenprobe |
| `test/mutations/<NNN>-*.sh` (2 neu) | neu | je Träger ein Zahn ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `harness/sensors/{slice-mv,archive-welle}.md` | update | die Sensor-Aussage zieht mit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): sofort — unblockiert. Der Constraint
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) ist `Accepted`
(`grep -c '^\*\*Status:\*\* Accepted$' docs/plan/adr/0042-*.md` → **1**), WIP frei
(`ls docs/plan/planning/in-progress/slice-*.md | wc -l`, kein Erwartungswert).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: wenn der Go-Träger den zweiten Suchraum nicht ohne Umbau seiner drei
  Leser aufnimmt — dann sind die zwei Träger zwei Slices.
- `in-progress` → `open`: wenn einer der zwei Mutations-Fälle sich nicht rot färben lässt, weil kein
  Wächter den Ausschluss trennscharf trifft. Dann wartet der Slice auf die Entscheidung, welcher
  Wächter die Zusage trägt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** `make gates` grün mit gültigem Stempel; **(b)**
`archive-welle --vorschau altbestand` nennt keine Datei unter `docs/plan/adr/` mehr und führt
weiter genau eine Sperre, `[haenger]`. Dazu der Lerneintrag in §7.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Ausschluss landet in der geteilten Liste.** In `AusgenommenePfade()` statt in den zwei
  Nachzug-Lesern eingetragen, nimmt er der Hänger-Vorprüfung 18 Dateien / 60 Fundstellen (§1) — und
  der Lauf bliebe **grün**. — **Ausgang:** <eingetreten / entfallen / weiter offen>
- **Der Pfad-Schnitt trifft auch `Proposed`-ADRs.** Der von Festlegung 2 benannte Preis, heute
  leer; ab hier trägt ihn ein Träger statt einer Messung.
  — **Ausgang:** <eingetreten / entfallen / weiter offen>
- **Ein dritter Träger bleibt unentdeckt.** §1 misst zwei; findet der Lauf einen weiteren Ort, der
  Verweise mechanisch umschreibt, ist Folgepflicht 1 nicht erfüllt.
  — **Ausgang:** <eingetreten / entfallen / weiter offen>

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
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** zwei berührte, beide in der Modus-Deklaration
([`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area))
geführt: `harness/tools/` (`TOOLS`) für den Shell-Träger, `*` (`ALL`) für `internal/archive/`.
Keine ist zu grob; `internal/archive/` bekommt **keine** eigene Sub-Area — es hinge allein an der
Verzeichnis-Achse und verfehlte die Schwelle ≥ 2 von 3.

**Vorgelagert — offene Beobachtungen sichten:** vier Treffer, Zähler-Stand je aus
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` (keine Erwartungswerte):

- [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **13×**, `offen` — dieser Slice ist ihr Träger; den Ausgang setzt die Closure
  ([ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Folgepflicht 3).
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  **4×**, `offen` — einschlägig; darum steht der Zahn je Träger in §2, nicht in der Closure.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  **13×**, `geplant` — der Grund, warum die Kalibrierung eigener DoD-Bestandteil ist.
- [`vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
  **4×**, `verkörpert`.

Keiner erreicht **mit diesem Slice** erstmals 3×; kein Folge-Slice fällig.

**Modus-Begründungsblock:** entfällt — **alle berührten Sub-Areas GF**. Das
Evidenz-/Diskrepanz-Risiko ist niedrig, und die vier Stände oben sind sein Beleg: Doc führt, Code
folgt, und die Diskrepanz, um die es geht, ist von
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) bereits entschieden.



# Slice slice-156: Der vendored Baum zieht auf `v5.18.0` — Tausch und Pins

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(`<tag>`-Politik: ein Tag zur Zeit, Tag-String hat genau eine Quelle),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die Adoptions-Erklärung).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`.harness/baseline/v5.18.0/` liegt vendored, `v5.12.0` ist fort, und jeder Pin und jeder
Baseline-Pfad im lebenden Bestand zeigt auf den neuen Tag.** Geschnitten aus Position 1 des
Katalogs in [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 (die Stand-Zeile
des Regelwerk-Index, die `harness/conventions.md` §Baseline zitiert).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Baum getauscht, Pins gezogen:** `BASELINE_TAG`, `BASELINE_ZIP_SHA256` und der
      `sources`-Pin in [`.d-check.yml`](../../../../.d-check.yml) tragen `v5.18.0`;
      `make baseline-verify` meldet `v5.18.0 OK`, `make regelwerk-check` ist grün.
- [ ] **Kein `v5.12.0`-Pfad bleibt im lebenden Bestand** — gemessen statt behauptet, mit dem
      Kommando im Plan; Zeitdokumente (`docs/reviews/**`, `docs/plan/planning/done/**`) und die
      nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen ADRs bleiben unangetastet.
- [ ] **Die Adoptions-Erklärung nennt den neuen Stand:**
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und §Baseline
      führen `v5.18.0` samt der Regelwerk-Stand-Zeile des neuen Index. Adaptions-Block heißt
      Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — eigener Commit.
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
| `.harness/baseline/` | neu / refactor | der Tausch selbst |
| `Makefile`, `.d-check.yml` | update | die drei Pins |
| `harness/conventions.md` | update | §Baseline und [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — Architect, eigener Commit |
| lebende Verweise auf `.harness/baseline/v5.12.0/` | update | der Tag steht im Pfad |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md)
liegt in `done/` — der Katalog steht, und mit ihm die Menge der Positionen, die dieser Tausch
auslöst.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn das Nachziehen der Baseline-Pfade
  einen eigenen Entscheidungs-Bedarf erzeugt (eingefrorene Adresse in einem `Accepted`-Artefakt,
  Klasse `BEO-017`) — dann trägt den zweiten Teil ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn das Release-Asset des Tags netzlos nicht
  gegen einen zweiten unabhängigen Ladeweg zu belegen ist.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make baseline-verify` meldet `v5.18.0 OK`; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Tausch bricht die emittierte Ebene, und `make gates` sieht es nicht** — genau das
  passierte beim letzten Baum-Tausch; sichtbar wurde es allein über `make full-smoke`, das nicht
  in `make gates` läuft (Closure-Trigger von [welle-14](../welle-14-re-baseline.md) §3).
  — **Ausgang:** offen, wird bei Closure verbucht.
- **Ein Baseline-Pfad in einem eingefrorenen Artefakt wird durch den Tausch tot** — die Klasse
  liegt als `BEO-017` im [Register](../observations.md), erste gemessene Instanz war genau dieser
  Fall. — **Ausgang:** offen, wird bei Closure verbucht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt für den vendored Baum keine engere.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-017` (Zähler-Stand siehe
[Register](../observations.md)) steht als Risiko in §6; `BEO-010` und `BEO-011` tragen den
Zuschnitt dieser Welle und sind dort verbucht. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

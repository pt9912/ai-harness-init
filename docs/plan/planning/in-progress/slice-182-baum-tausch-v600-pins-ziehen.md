# Slice slice-182: Der vendored Baum steht auf `v6.0.0` — Pins gezogen, Setzung verbucht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied, und zwar zwingend.** Ihr
Closure-Trigger nennt zwei Bedingungen, die nur dieser Slice herstellt: `make baseline-verify`
meldet `v6.0.0 OK`, und §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md)
nennt denselben Tag. Kein anderer Mitglieds-Kandidat kann sie einlösen.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Pin ist
die Reproduzierbarkeits-Klammer; dieser Slice bewegt ihn),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum ist der Gegenstand — committet, netzlos, genau ein Tag),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2
nennt Ort und Mindestumfang der Zielstand-Buchung, die dieser Slice vollzieht),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (jeder Verweis in den Baum trägt
seinen Tag — die Pin-Hälfte des Tauschs).

**Berührte Spec-Stellen:** `—`. Der Slice tauscht einen vendored Fremd-Blob und zieht Verweise
nach; er schreibt keine Spec-Stelle.

**Verantwortlich:** Implementer (pt9912). Der Zielstand-Buchungs-Punkt in `harness/conventions.md`
bleibt Architect-Hoheit (§3.8) und wandert als eigener, gesondert benannter Commit in den Ablauf.

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`.harness/baseline/` führt `v6.0.0` als einzigen Baum, jeder lebende Verweis mit
Tag-Segment zeigt dorthin, und die Setzung des Auftraggebers ist an ihrem Ort verbucht.**

Der Slice geht aus dem Diff-Katalog in
[slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 hervor und trägt dort die
Positionen **P-01** (der Regelwerks-Stand, den §Baseline zitiert), **P-12** (die drei
Vorlagen-Querverweise ohne Gegenstand hier) und die Vorbedingung von **P-13** (die neue Vorlage
`observation.template.md` liegt netzlos erst nach dem Tausch vor).

**Er entscheidet nichts über die regierende Fassung.** Das ist
[slice-178](../open/slice-178-regierende-fassung-des-sprungs-v600.md); dieser Slice vollzieht.

**Die Buchung gehört hierher und nicht in den Katalog-Slice.** Die Zeile in §Baseline trägt nach
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 das
**Datum des Vollzugs** — vor dem Tausch trüge sie ein Datum für ein Ereignis, das nicht
stattgefunden hat. Präzedenz ist [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md), der
die Zeile für den vorigen Sprung schrieb.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Der Baum ist getauscht.** `.harness/baseline/v6.0.0/{regelwerk,templates}` samt
      `SHA256SUMS` liegt committet, `.harness/baseline/v5.18.0/` ist entfernt, und
      `make baseline-verify` meldet `v6.0.0 OK`. Genau ein Tag liegt im Baum — die Zusage von
      [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
      ist keine Vollständigkeits-, sondern eine Eindeutigkeits-Aussage und wird als solche belegt
      (`ls -d .harness/baseline/v*/ | wc -l` → 1).
- [ ] **Kein lebender Verweis zeigt auf den alten Tag.** Bezugsmenge und Ausschlüsse gemessen statt
      behauptet: `git grep -n '\.harness/baseline/v5\.18\.0' -- '*.md' '*.go' '*.sh' '*.yml'
      'Makefile'` außerhalb der eingefrorenen Bestände (`docs/plan/planning/done/`,
      `docs/reviews/`, `harness/conventions/done/`, `docs/plan/adr/` — Accepted-ADRs sind nach
      [`AGENTS.md`](../../../../AGENTS.md) §3.4 unantastbar) trifft **null**. Die Symlinks unter
      `.claude/rules/` zeigen auf den neuen Baum; ihre Zahl bleibt, was
      [`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
      als geschlossene Menge führt. **Bestands-Prosa, die einen vergangenen Stand als
      Herkunfts-Anker nennt, ist nicht betroffen** — sie trägt kein `.harness/baseline/`-Segment.
- [ ] **Die Zielstand-Setzung ist verbucht.** §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) trägt die
      Re-Baseline-Zeile in der Form aus
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Festlegung 2 — Ziel-Tag, **Datum des Vollzugs**,
      [slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) als Zeiger auf den
      Delta-Nachweis, **sonst nichts** —, und die `Stand:`-Zeile sowie der zitierte
      Regelwerks-Stand (`sed -n '3p' .harness/baseline/v6.0.0/regelwerk/README.md`) sind
      nachgezogen. **Diese Datei gehört dem Architect**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): der Teil-Punkt ist ein **eigener Commit**, der
      nur Architect-Artefakte berührt und die Rolle in seiner Message nennt.
- [ ] `make gates` grün. **Dazu `make full-smoke`** — der Baum-Tausch von
      [welle-10](../done/welle-10-re-baseline.md) brach genau dort und blieb für `make gates`
      unsichtbar ([slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)).
- [ ] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice. Ein öffentlicher
      Vertrag ist nicht berührt — der vendored Baum ist Infrastruktur, kein Nutzer-sichtbares
      Verhalten.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.0.0/` | neu | der vendored Baum des Zielstands, netzlos verifizierbar |
| `.harness/baseline/v5.18.0/` | entfernt | genau ein Tag liegt im Baum ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| lebende Pfad-Verweise mit Tag-Segment | update | Bezugsmenge und Ausschlüsse in DoD 2 |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline | update | die Buchung — **eigener Architect-Commit** |

**Der Commit-Zuschnitt ist zweiteilig, und die Grenze läuft nicht am Inhalt, sondern an der
Rolle.** Tausch und Verweis-Nachzug sind derselbe Vorgang und bleiben zusammen; §Baseline ist
Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und bekommt seinen eigenen Commit.
Ob darüber hinaus [`AGENTS.md`](../../../../AGENTS.md) §3.3 greift, entscheidet der Lauf an seiner
Messung: Weist `git diff-tree -r --name-status -M` über dem Tausch-Commit eine `R`-Zeile aus, ist
der Move von der Inhaltsänderung zu trennen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md)
liegt in `done/`. Der Grund ist tragend, nicht ordnend: Der Katalog sagt, welche Positionen der
Tausch mitzieht und welche einen eigenen Träger haben — ohne ihn tauscht der Lauf einen Baum und
weiß nicht, was er damit ausgelöst hat (`BEO-010`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Verweis-Nachzug mehr als eine
  mechanische Ersetzung ist — etwa weil eine `cite`-artige Zeilenspann-Bindung existiert, die
  von Hand nachzurechnen ist. Dann trennt der Schnitt Tausch (Liefer-Punkt 1) und Nachzug
  (Liefer-Punkt 2).
- `in-progress` → `open` (blockiert — Carveout?): wenn `make full-smoke` am neuen Baum rot wird
  und die Ursache in der Ziel-Fassung liegt statt in diesem Repo. Dann ist der rote Gate-Status
  auf einen Trigger zu schalten (Carveout, Baseline-Regelwerk `modul-07-carveouts.md`), nicht
  still zu übergehen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make baseline-verify` meldet `v6.0.0 OK` und `make full-smoke` ist grün;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Pin-Nachzug lässt eine Klasse von Verweisen stehen, die kein Gate sieht** (`BEO-003`, 5×,
  **verkörpert** in `make slice-mv` — dessen Deckung gilt Slice-Adressen, nicht Baseline-Pfaden).
  Das Nachbar-Repo hat an genau dieser Stelle **zwei** übersehene Klassen gemeldet: eine
  Version-Annotation neben einem Zitat und die Selbstauskunfts-Zahlen des begleitenden
  Adaptions-Eintrags
  (`unzip -p /Development/d-check/docs/plan/planning/done/welle-88/archiv.zip
  docs/plan/planning/done/slice-193-baseline-v600-bump.md`, §9). — **Ausgang:** <…>
- **Die Zwei-Commit-Trennung fällt unter Zeitdruck zusammen** (`BEO-009`, 10×, **geplant**). Der
  Architect-Commit für §Baseline ist die Bedingung, unter der
  [`AGENTS.md`](../../../../AGENTS.md) §3.8 überhaupt nachträglich an `git log --stat` ablesbar
  ist; er ist kein Formalismus. — **Ausgang:** <…>
- **`make full-smoke` ist im Closure-Trigger genannt, aber nicht in `make gates`.** Ein Lauf, der
  nur `make gates` fährt, hält den Slice für fertig. Der Fehlerfall ist gemessen und nicht
  hypothetisch ([slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)). —
  **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register:** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — sie prüft die Closure von
  [welle-15](../welle-15-re-baseline.md).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area,
die die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
den vendored Baum und den Konventionsspeicher führt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand, keine erreicht mit
ihm 3×:

- `BEO-003` (5×, **verkörpert**) — *Verweise brechen beim Ortswechsel*. Steht als Risiko in §6.
- `BEO-009` (10×, **geplant**) — *eine Zusage neben der geänderten Ableitung bleibt stehen*. Steht
  als Risiko in §6, hier in der Commit-Zuschnitt-Form.
- `BEO-011` (1×) — *gesammelte Sprünge kosten überproportional*. Dieser Sprung wird zeitnah
  adoptiert; die Kostenreihe misst die Closure von [welle-15](../welle-15-re-baseline.md).
- `BEO-025` (2×) — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*. Bindet
  DoD 4: `make gates` sieht den Fall aus DoD 1 nicht vollständig, `make full-smoke` gehört dazu.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

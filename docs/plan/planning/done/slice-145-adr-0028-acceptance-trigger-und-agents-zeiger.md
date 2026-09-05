# Slice slice-145: ADR-0028 durchläuft ihren Acceptance-Trigger, und AGENTS.md bekommt den Zeiger, den ihre Folgepflicht verspricht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet. **Bündel?** Nein — ein ADR-Status-Übergang plus ein
Zeiger, einzeln lieferbar, wartet auf keinen zweiten Slice. **Gemeinsames Closure-Kriterium?**
Nein — jedes wäre die Abschrift seiner eigenen DoD. **Auslöser reaktiv oder gewollt?** Reaktiv:
Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz verlangt für
Verdikt 3 (*„Lockerung legitim, aber undokumentiert"*) **zwei** Artefakte — die Folge-ADR **und**
einen Erinnerungs-Slice in `next/`; die Folge-ADR ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md))
existiert, der Erinnerungs-Slice fehlte. Der Gegenstand stammt nicht aus dem Re-Baseline-Delta und
belegt kein Closure-Kriterium von [welle-10](../done/welle-10-re-baseline.md) §3; er gehört darum in
keine Welle. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:** [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (der
Gegenstand dieses Slice — ihr Acceptance-Trigger und ihre Folgepflicht 1),
[ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (dieselbe
Lücke, derselbe Präzedenzfall für die Zeiger- und Index-Pflege), [`AGENTS.md`](../../../../AGENTS.md)
§3.8 (die schreibende Rolle für Hard Rules **und** — nach Folgepflicht 1 von
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) — für ihren
eigenen Zeiger), Baseline-Regelwerk `modul-04-adrs.md` §Kernidee (Re-Evaluierungs-Trigger,
Accepted-Hard-Rule) und Baseline-Regelwerk `grundlagen-bootstrap.md` §Vier Trigger-Klassen
(Acceptance-Trigger: „ADR-Review-Runde abgeschlossen → bindend" — genau der Trigger, der laut der
Geschichte-Tabelle von [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
bislang **nicht** stattgefunden hat),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt zwei Norm-Artefakte (ADR, `AGENTS.md`) und ein
Register; [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) selbst ist
*„Prozess-ADR ohne Spec-Stratum"*.

**Verantwortlich:** Architect (pt9912) — der tragende Liefergegenstand ist der ADR-Status-Übergang
und der Hard-Rule-Zeiger in `AGENTS.md` §3.8, und beides schreibt nach
[`AGENTS.md`](../../../../AGENTS.md) §3.8 bzw. Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Regeln (*„ADR-Änderung: Architect schreibt"*) der **Architect**; die
Konsistenz-Prüfung, die der Acceptance-Trigger verlangt, liegt beim Reviewer. Derselbe
Liefergegenstand trägt bei den Präzedenzfällen
[slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) und
[slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) dieselbe Besetzung. Das Feld
weicht damit von der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine nennt (*„den Rolleninhaber der Implementer-Rolle"*). Abgelegt direkt
in `next/`, wie Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz
es für den Erinnerungs-Slice von Verdikt 3 vorgibt.

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) steht auf `Proposed`,
ohne dass der Acceptance-Trigger der Baseline (ADR-Review-Runde abgeschlossen) je stattgefunden
hat — ihre eigene Geschichte-Tabelle sagt das aus, mit derselben Zurückhaltung wie
[ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md): der Bestand begründet keinen
Status. Dieser Slice holt den fehlenden Schritt nach: ein Reviewer
prüft die ADR auf Konsistenz (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln), der
Architect setzt danach `Accepted`. Mit der Annahme wird sofort ihre **Folgepflicht 1** fällig — der
Zeiger in [`AGENTS.md`](../../../../AGENTS.md) §3.8 zeigt heute nur auf
[ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und endet
dort; ein Leser findet den Command-Fall nicht. Beide Schritte liefert dieser Slice, nicht die
inhaltliche Überarbeitung von [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
selbst — die bleibt außerhalb seines Schreibziels
([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Konsequenzen,
Folgepflicht 1: *„Dieser Lauf schreibt `AGENTS.md` nicht — außerhalb seines Schreibziels"*, hier
gespiegelt: dieser Slice schreibt keinen neuen ADR-Inhalt).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) durchläuft
      den Acceptance-Trigger und trägt ihn.** Ein Reviewer-Durchgang
      prüft die ADR auf Konsistenz (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln);
      danach setzt der Architect `**Status:** Accepted` und ergänzt die Geschichte-Tabelle um eine
      neue Zeile, die den Trigger benennt (*„ADR-Review-Runde abgeschlossen → bindend"*,
      Baseline-Regelwerk `grundlagen-bootstrap.md` §Vier Trigger-Klassen). Der ADR-Index
      ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt dieselbe Status-Spalte
      (`grep -c '0028.*Proposed' docs/plan/adr/README.md` → **0** danach, statt der heutigen
      **1**) — derivatives Register, gehört der Rolle seines Originals
      ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
- [x] **(2) `AGENTS.md` §3.8 bekommt den Zeiger, den Folgepflicht 1 verspricht.** Der Architect
      ergänzt in eigenem Commit, der ausschließlich Architect-Artefakte berührt, den Fall
      „Command-/Skill-Anweisungssätze" neben dem bestehenden Zeiger auf
      [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md), mit
      Verweis auf [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md).
      Geschieht **erst nach** DoD (1) — eine Hard Rule, die auf eine `Proposed`-Entscheidung zeigt,
      behauptet Bindung, die nicht besteht
      ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Konsequenzen,
      Folgepflicht 1).
- [x] `make gates` grün.
- [x] Doku-Update: `harness/README.md`, falls es §3.8 zitiert und die Ergänzung nachzuziehen ist
      (Prüfung, kein sicherer Treffer).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — `BEO-007` bekommt seinen
      Ausgang: **verkörpert** über [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
      und den `AGENTS.md`-Zeiger aus DoD (2), nicht über die 3×-Schwelle (der Zähler bleibt bei
      1×) — derselbe Konflikt-Pfad-Auslöser, den
      [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Kontext für
      sich selbst benennt.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure, nicht
      dieser Slice — dieses Repo fährt Wellen-Betrieb, und das gilt auch für wellenlose Slices.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) | update (Status + Geschichte-Zeile), durch den Architect | DoD (1) — Acceptance-Trigger vollzogen; nach `Accepted` wird die Datei nicht mehr inhaltlich überschrieben (Baseline-Regelwerk `modul-04-adrs.md` §Hard Rule für Accepted-ADRs) |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update (Status-Spalte), durch den Architect | DoD (1) — derivatives Register desselben Originals |
| [`AGENTS.md`](../../../../AGENTS.md) | update (§3.8 Zeiger), durch den Architect | DoD (2) — Folgepflicht 1 aus [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), fällig erst mit der Annahme |
| `docs/plan/planning/observations.md` | update (`BEO-007` Stand-Spalte) | Register-Pflicht (nicht mitgezählt) |

**Der Commit-Zuschnitt folgt den Rollen:** ein Reviewer-Durchgang ohne eigenen Commit (Konsistenz
ist Voraussetzung, kein Artefakt), danach ein Architect-Commit für DoD (1) und ein zweiter für
DoD (2) — zwei Commits, weil DoD (2) erst nach der Annahme entstehen darf und die beiden sonst in
einem Commit einen Zustand behaupteten, der beim Schreiben von DoD (2) noch nicht galt —, zuletzt
die Planner-Closure.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit; eine technische Vorbedingung
hat der Slice nicht. Das WIP-Limit gilt für `in-progress/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Reviewer-Konsistenzprüfung aus
  DoD (1) einen inhaltlichen Einwand gegen
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) findet, der über
  Konsistenz hinausgeht (z. B.
  gegen Festlegung 1 oder 2) — dann ist eine Plan-Korrektur an der ADR selbst fällig, und das ist
  Architect-Arbeit außerhalb dieses schlanken Erinnerungs-Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Reviewer-Konsistenzprüfung einen
  Rollen-Widerspruch findet, der eine neue Architektur-Entscheidung (Folge-ADR) statt eines
  Status-Wechsels verlangt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **erstens** `grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
→ **1**, mit einer neuen Geschichte-Zeile, die den Acceptance-Trigger nennt. **Zweitens**
`AGENTS.md` §3.8 nennt [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(`grep -c 'ADR-0028' AGENTS.md` <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) --> → **≥ 1**), in einem Architect-Commit,
der ausschließlich Artefakte dieser Rolle berührt (`git log --stat`). Dazu die Closure-Notiz mit
Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Reviewer-Konsistenzprüfung findet einen echten inhaltlichen Einwand**, der über eine
  bloße Formalie hinausgeht — z. B. gegen die Abgrenzung von `.claude/agents/*.md` in
  Festlegung 3, oder gegen eine der drei Optionen in §Verglichene Alternativen. —
  **Ausgang: eingetreten**, und zwar in der ersten Runde: deren MEDIUM-2 traf Festlegung 2 — der
  ausgenommene Teil war dem Architect zugewiesen und die Zuordnung
  [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) zugeschrieben, deren §Was hier
  NICHT entschieden ist genau das ausnimmt. Die ADR wurde vor der Annahme korrigiert, wie der
  Zweig es vorsieht; der Beleg steht in ihrer Geschichte-Tabelle, und die fünfte Runde bestätigt
  die Konsistenz ohne inhaltlichen Einwand. **Kein Folge-Slice, kein Carveout:** die Korrektur ist
  im `Proposed`-Fenster vollzogen und nachgemessen, ein Rest bleibt nicht.
- **Der Zeiger in `AGENTS.md` §3.8 überlädt den Absatz**, der heute genau einen Fall
  ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)/derivative
  Register) trägt — ein zweiter Fall in Prosa könnte gegen §3.7 laufen
  (ein Kommentar/Zustandsfeld trägt genau **ein** auflösbares Feld, keinen Absatz). —
  **Ausgang: entfallen.** Die Ergänzung ist ein Absatz mit genau **einem** auflösbaren Feld — dem
  Verweis auf [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (`grep -c 'ADR-0028' AGENTS.md` <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) --> → **1**) —, und Ausnahme wie offener Rest stehen als
  Zeiger auf die Entscheidung statt als zweite Begründungs-Prosa.
- **`harness/README.md` zitiert §3.8 mit einer heute passenden, nach der Ergänzung veralteten
  Formulierung** (z. B. „zwei Artefakte" statt „zwei Norm-Artefaktklassen plus benannte
  Ausnahme"). — **Ausgang: entfallen** — kein Zitat betroffen, die DoD-Prüfung ist negativ:
  `grep -c '3\.8' harness/README.md` → **0** (Exit 1); der Harness-Einstieg nennt weder die Hard
  Rule noch eine der zwei Entscheidungen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. `grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
   → **1**, mit einer Geschichte-Zeile, die den Acceptance-Trigger benennt; der ADR-Index trägt
   dieselbe Spalte (`grep -c '0028.*Proposed' docs/plan/adr/README.md` → **0**, vorher **1**).
2. [`AGENTS.md`](../../../../AGENTS.md) §3.8 nennt die Entscheidung
   (`grep -c 'ADR-0028' AGENTS.md` <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) --> → **1**), gesetzt in einem eigenen Architect-Commit,
   der außer dieser Datei nichts berührt (`git log --stat`).
3. `make gates` grün nach dem Commit dieser Notiz; der Stop-Hook-Stempel deckt den Arbeitsbaum.

- **Was funktioniert hat:** die Trennung von Reviewer und Architect am selben Text. Fünf Runden
  fanden keinen Befund gegen die Entscheidung selbst; der eine, der über die Form hinausging,
  traf die Rollen-Zuordnung in Festlegung 2 (§6, Risiko 1). Jede Korrektur lief im
  `Proposed`-Fenster, wo sie ein bis zwei Zeichen kostet; nach `Accepted` wäre jede eine
  Folge-ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
- **Was anders lief als geplant:** §2 und §8 dieses Plans rechnen mit
  `BEO-007` bei **1×**; die Zeile steht bei **4×** und führte den Ausgang
  schon dreigeteilt. Geschrieben ist der Stand des **Registers**, nicht der des Plans. Die Klasse
  liegt als `BEO-025`; der Plan-Text bleibt stehen, damit deren Beleg im
  Indikativ zeigt, worauf er zeigt.
- **Steering-Loop-Eintrag: eine benannte Lücke** — *für eine Präsens-Aussage über ein
  repo-eigenes lebendes Artefakt in einem Text, der nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren wird, benennt keine Quelle eine Form.*
  Vier der fünf Runden trugen dieselbe Ursache;
  [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) bindet den Regelwerks-Beleg,
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  den vendored Baum und nimmt `docs/plan/adr/` ausdrücklich aus,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  die Zahl. Kein Zielort — **benannt, nicht verkörpert**: die Lücke liegt als
  `BEO-024`.
- **Verkörpert, und trotzdem ohne `liegt in`-Feld:** Zielort ist
  [`AGENTS.md`](../../../../AGENTS.md) §3.8, und die Herkunft trägt er dort als **ein** auflösbares
  Feld — den Verweis auf
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md). Ein zweiter Anker
  `· seit slice-145` daneben liefe gegen [`AGENTS.md`](../../../../AGENTS.md) §3.7, und das Feld
  dieser Sektion zöge die Anker-Paarung auf genau ihn. Der Anker steht darum dort, wo dieses Repo
  ihn führt: in der `Stand`-Zelle von `BEO-007` — wie schon bei
  `BEO-001`, deren Zielort ihn ebenfalls nicht als Literal trägt.
- **Beobachtungs-Register (`../observations.md`):** `BEO-007` behält Zähler
  und Belege — dieser Slice **trägt** den Ausgang, er beobachtet nicht —; die `Stand`-Zelle führt
  die Command-Hälfte jetzt als **verkörpert** (`seit slice-145`) und die Zeile im Ganzen weiter
  als **geplant**, bis die zwei übrigen Teile eine angenommene Quelle haben. Zwei neue Kennungen:
  `BEO-024` und `BEO-025`, je 1×, Beleg `slice-145`.
- **Folge-Slices:** keine neuen — die zwei offenen Teile von `BEO-007`
  tragen [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md) und
  [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md), beide in `open/`.
- **Risiken aus §6:** drei benannt, drei mit genau einem Ausgang — eines **eingetreten** (der
  inhaltliche Einwand der ersten Runde, im `Proposed`-Fenster korrigiert, ohne Rest), zwei
  **entfallen** (Form des Zeigers, `harness/README.md` zitiert §3.8 nicht).
- **Eine Abweichung, benannt statt geheilt:** der Übergang `next` → `in-progress` landete erst
  unmittelbar vor dieser Closure auf dem Hauptzweig; Baseline-Regelwerk
  `modul-05-planning-harness.md` §Lifecycle als State Machine verlangt ihn **vor** der Arbeit.
  Der Anspruch war für andere Läufe darum nicht sichtbar. Einmalig, in diesem Lauf, ohne Kollision
  (`ls docs/plan/planning/in-progress/` führte davor keinen zweiten Slice).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `docs/plan/adr/` und das Wurzelverzeichnis
(`AGENTS.md`). Beide fallen unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
**alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit nach dem
*Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-007` steht im Register (Sub-Area `*`, 1×,
Beleg slice-137) und ist der direkte Gegenstand dieses Slice — ihr Ausgang steht in DoD (siehe
oben), nicht bloß als Sichtungs-Notiz. Keine weiteren Treffer für die berührten Sub-Areas.

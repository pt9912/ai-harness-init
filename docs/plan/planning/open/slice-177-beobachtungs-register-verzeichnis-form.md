# Slice slice-177: Das Beobachtungs-Register läuft in der Verzeichnis-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied, und der Grund ist gemessen statt
zweckmäßig.** Der Zuschnitt-Test ist nicht *„braucht diese Arbeit eine Welle?"*
([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)),
sondern *„ist die Ablage-Form eine Pflicht der Ziel-Fassung?"* — und sie ist es: `v6.0.0` ersetzt
die Register-Vorlage durch eine Vorlage je **Beobachtung** und schreibt `modul-06-roadmap.md`
§Das Beobachtungs-Register darauf um (Beleg in §1). Damit fällt die Arbeit unter das Welle-Ziel
*„jede Pflicht, die die neue Fassung mitbringt, hat einen verbuchten Ausgang"*. Die Präzedenz
[slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md)/[slice-167](../done/slice-167-aufgeloeste-adaptionen-bekommen-ihre-verzeichnis-position.md)
lief **wellenlos**, weil die Verzeichnis-Form des Adaptions-Blocks eine repo-eigene Setzung war
([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form))
und keine Pflicht des damals adoptierten Stands.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Ziel-Form
kommt aus dem auf einen Tag gepinnten Baum),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
maschinelle Hälfte der Register-Paarung ändert mit der Ablage ihren Gegenstand — was heute kein
Modul prüft, prüft es danach ebenso wenig),
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
(die Präzedenz derselben Form-Umstellung in diesem Repo),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(die Ziel-Form liegt im vendored Baum, und der wird vorher getauscht).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt ein Planning-Artefakt; er schreibt keine
Spec-Stelle.

**Verantwortlich:** `—` bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Zwei Closures, die verschiedene Beobachtungen anfassen, schreiben in verschiedene Dateien.**
Heute schreibt **jede** Slice-Closure in dieselbe Datei — neue Kennung anlegen oder Zähler
erhöhen —, und damit ist `docs/plan/planning/observations.md` ein struktureller
Kollisions-Punkt für parallel arbeitende Rolleninhaber.

**Der Beleg ist ein Vorfall, keine Hypothese.** Am 2026-09-03 liefen zwei Läufe desselben Slice
auf demselben Elternstand und schrieben dieselbe Datei; der Konflikt wurde von Hand aufgelöst:

```sh
git log --format='%H %P %s' -n 4    # 94f2552 und 787f7e8 tragen denselben Parent d96e9df
                                    # und dieselbe Message; 77c805a ist der Aufloesungs-Merge
```

Die Datei traf es nicht, aber die Bedingung ist dieselbe und für das Register **häufiger**: sie
wird von jeder Closure geschrieben — `git log --format=%H -- docs/plan/planning/observations.md
| wc -l` → **59** Commits. Nach der Umstellung kollidieren nur noch zwei Läufe, die **dieselbe**
Beobachtung anfassen.

**Die Ziel-Form steht nicht zur Wahl, sie ist die des Sprungs.** `v6.0.0` streicht
`templates/docs/plan/planning/observations.template.md` und legt
`templates/docs/plan/planning/observation.template.md` an — eine Vorlage je **Beobachtung**, mit
einem Verzeichnis `observations` unter `docs/plan/planning/` als Ablage, drei Dateien je Eintrag
(`observation.md`
unveränderlich · `state.md` veränderlich · `evidence/<vorgangs-id>.md` je Auftreten) und **ohne
Zähler-Feld**: der Zähler ist die Zahl der Evidence-Dateien.

```sh
# am lokalen Kurs-Klon
git diff --name-status v5.18.0 v6.0.0 -- lab/templates/docs/plan/planning
git show v6.0.0:lab/templates/docs/plan/planning/observation.template.md | head -8
```

**Die Größe trägt hier nichts, und das steht so da statt als Analogie.** Das Vorbild
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
teilte einen Speicher, der heute `cat harness/conventions.md harness/conventions/*.md | wc -c` →
**339 546** Zeichen misst; dieses Register misst `wc -c < docs/plan/planning/observations.md` →
**52 701** Zeichen bei `grep -c '^| BEO-' docs/plan/planning/observations.md` → **29** Einträgen.
Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Migration ist damit **billig**, nicht durch Größe **erzwungen** — der Treiber ist
die Nebenläufigkeit oben und die Pflicht des Sprungs.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die Ablage steht in der Ziel-Form.** Ein Verzeichnis `observations` unter
      `docs/plan/planning/` trägt je Beobachtung ein Verzeichnis nach `observation.template.md`
      des dann vendored Stands —
      `observation.md`, `state.md`, `evidence/` mit einer Datei je Auftreten — plus die `README.md`,
      die die Ablage auch leer sichtbar hält. **Kein Zähler-Feld bleibt stehen:** die Zahl der
      Evidence-Dateien **ist** der Zähler, und ein zweites Feld daneben wäre die Quelle, die die
      Form gerade abschafft. Vollständigkeit gemessen statt behauptet: die Zahl der Verzeichnisse
      deckt `grep -c '^| BEO-' docs/plan/planning/observations.md` am Ausgangsstand.
- [ ] **Kein Verweis zeigt ins Leere.** Die lebenden Referenzen auf die alte Datei sind nachgezogen
      — Bezugsmenge `git grep -l 'observations\.md' -- '*.md' ':!.harness/baseline' | wc -l`
      (2026-09-04: **92** Dateien, **483** Vorkommen mit `-o … | wc -l`; keine Erwartungswerte,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). **Der Doppel-Anker-Mechanismus des Vorbilds hat hier keinen Gegenstand:** die
      Referenzen tragen keinen Eintrags-Anker, gemessen mit
      `git grep -o 'observations\.md#' -- '*.md' ':!.harness/baseline' | wc -l` → **0**. Belegt
      durch `make docs-check` ohne Befund.
- [ ] `make gates` grün.
- [ ] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice; jede Quelle, die
      die Register-**Form** beschreibt statt nur auf sie zu zeigen, ist nachgezogen oder als
      Übergabe benannt (§6). Ein öffentlicher Vertrag ist nicht berührt.
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
| `observations` unter `docs/plan/planning/` | neu | die Ablage, je Beobachtung ein Verzeichnis aus der vendored Vorlage |
| `docs/plan/planning/observations.md` | refactor | geht in der Ablage auf; die Position ist der Zustand |
| lebende Verweise auf die alte Datei | update | Bezugsmenge und Kommando in DoD 2 |

Der `git mv` und die Inhaltsänderung sind **zwei Commits**
([`AGENTS.md`](../../../../AGENTS.md) §3.3) — die Präzedenz
[slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md) hat denselben Zuschnitt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der vendored Baum trägt die Ziel-Form — `make baseline-verify`
meldet `v6.0.0 OK`. Die Bedingung nennt **kein** Slice, weil der tauschende Slice aus dem Katalog
in [slice-176](../open/slice-176-inventur-vor-dem-schnitt-v600.md) §9 hervorgeht und heute nicht
existiert;
eine Kennung hier behauptete eine Datei, die es nicht gibt. Der Grund ist tragend, nicht ordnend:
Vor dem Tausch ist `v5.18.0` der Ist-Maßstab
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und die Vorlage,
aus der die Ablage per `cp` entsteht, liegt netzlos erst danach vor.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Verweis-Nachzug nicht mechanisch
  läuft — `make slice-mv` deckt die Slice-Adressen, nicht diese —, und die 92 Dateien einzeln
  gelesen werden müssen. Dann trennt der Schnitt Ablage (Liefer-Punkt 1) und Verweis-Nachzug
  (Liefer-Punkt 2) in zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Ziel-Form eine Entscheidung verlangt, die
  dieser Slice nicht fällen darf — siehe die Kürzel-Frage in §6.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make docs-check` ohne Befund über der neuen Ablage; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Ziel-Form adressiert `BEO-<KUERZEL>/<slug>`, und dieses Repo führt kein Kürzel.** Gemessen:
  `git grep -ohE '\b(ADR|CO|MR|BEO)-[A-Z]{2,}-[0-9]+' -- '*.md' ':!.harness/baseline' | sort -u |
  wc -l` → **0** (kein Erwartungswert,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Für die Kürzel-Spalte ist dieselbe Frage schon beantwortet — wer ohne Bereichssegment
  zählt, streicht sie
  ([`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)) —,
  aber ob dieselbe Antwort für ein **Verzeichnis-Segment** trägt, ist eine Aussage über den
  Konventionsspeicher und damit Architect-Sache ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
  Dieser Slice legt die Ablage an und **entscheidet die Form der Kennung nicht**. — **Ausgang:** <…>
- **Ein Verweis-Nachzug über 92 Dateien bricht etwas, das kein Gate sieht** (`BEO-003`, 5×,
  **verkörpert** in `make slice-mv`). Dessen Deckung gilt Slice-Adressen; für diese Datei gibt es
  keinen Träger, und die präfixlose Form bricht in beide Richtungen. `make docs-check` fängt die
  Link- und Codepath-Hälfte, nicht die Inline-Code-Hälfte (`BEO-025`). — **Ausgang:** <…>
- **Die Form-Beschreibung steht an mehreren Orten und zieht nicht mit** (`BEO-009`, 9×). Der
  Kopftext des Registers, die drei Anweisungssätze unter `.claude/commands/` und ihre emittierten
  Gegenstücke beschreiben die heutige Tabellen-Form. Wer die Anweisungssätze schreiben darf, ist die
  offene Frage aus `BEO-007` — die emittierte Ebene ist davon getrennt. — **Ausgang:** <…>
- **Die Nebenläufigkeits-Zusage ist nicht bewiesen, sondern hergeleitet.** Dass zwei Closures an
  verschiedenen Beobachtungen nicht mehr kollidieren, folgt aus der Datei-Trennung; ein
  Gegenbeispiel ist hier **nicht** rot gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und kein
  Sensor misst Merge-Verhalten. Der Slice sagt darum die **Eigenschaft der Ablage** zu, nicht ein
  Ausbleiben von Konflikten. — **Ausgang:** <…>

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
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register:** <…> — dieser Slice schreibt seinen eigenen Eintrag bereits in die
  **neue** Ablage; der Übergang ist damit an seiner ersten Benutzung geprüft.
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area, die
die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
das Planning-Layout führt; `harness/tools/` und `.codex/` sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand, keine erreicht mit
ihm 3×; die drei ersten stehen als Risiko in §6:

- `BEO-003` (5×, **verkörpert**) — *Verweise brechen beim Ortswechsel*. Die verkörperte Deckung
  gilt Slice-Adressen; diese Datei hat keinen Träger.
- `BEO-009` (9×, **geplant**) — *eine Zusage neben der geänderten Ableitung bleibt stehen*. Die
  Form-Beschreibung des Registers steht an mehreren Orten.
- `BEO-025` (2×) — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*. Bindet die
  Formulierung von DoD 2: `make docs-check` deckt Link und Codepath, nicht Inline-Code.
- `BEO-002` (1×) — *eine Registerzeile hat keine Spalte für einen Träger*. Die Ziel-Form trennt
  `observation.md`, `state.md` und `evidence/`; ob sie diese Lücke schließt, ist bei der Closure zu
  prüfen statt anzunehmen.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

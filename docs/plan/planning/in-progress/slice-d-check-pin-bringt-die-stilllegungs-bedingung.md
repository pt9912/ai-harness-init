# Slice slice-d-check-pin-bringt-die-stilllegungs-bedingung: Der d-check-Pin springt `v0.74.1` → `v0.76.0`, und die Bedingung für die Stilllegungs-Form wird verfügbar

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

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der
Digest-Pin ist die Reproduzierbarkeits-Zusage),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das
Modul `targets` hält den Gate-Index gegen die Targets des Fragments),
[`MR-010`](../../../../harness/conventions.md#mr-010) (Re-Adaption des tool-generierten Fragments),
[`MR-027`](../../../../harness/conventions.md#mr-027) §Auflösungs-Trigger (Strenge-Bilanz an der
Quell-Differenz, bei Zeilenverlust zusätzlich auf einer Nicht-Null-Basis),
[`MR-052`](../../../../harness/conventions.md#mr-052) (der letzte Sprung dieser Linie),
[`MR-053`](../../../../harness/conventions.md#mr-053) (ein Eintrag datiert seine Werkzeug-Aussage),
[`MR-054`](../../../../harness/conventions.md#mr-054) und
[`MR-055`](../../../../harness/conventions.md#mr-055) (was ins emittierte Gate geht und was eine
Stellen-Messung trägt),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Re-Evaluierungs-Trigger 2
hängt am Pin).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der gepinnte d-check steht auf `v0.76.0`, an beiden gekoppelten Stellen und mit belegtem
Digest. Das tool-generierte Fragment ist gegen eine frische Ausgabe re-adaptiert, und die
Strenge-Bilanz über die Spanne ist gezogen. Danach stellt das gepinnte Bild die
`structure`-Bedingung `open-tasks-require-marker` bereit; aktiviert wird sie hier nicht.

**Warum jetzt.** Die Bedingung ist die Antwort des Werkzeugs auf den Änderungswunsch zur
Stilllegungs-Form (d-check `CHANGELOG.md`, `[0.76.0]`). Die Gruppierung der Go-Slices nimmt die
Kanten `open → done` und `next → done` in Serie. **Dieser Slice und
`slice-stilllegungs-form-hat-einen-waechter` laufen vor ihr**, damit ein Wächter die Stilllegungen
hält (§4).

### Das Delta, gemessen

Gemessen im Planungslauf am 2026-09-17, nur lesend, am lokalen Klon des Werkzeugs
(`<Klon des d-check-Repos>`, eine Fremdquelle). Keine Zahl ist ein Erwartungswert.

1. **Die Spanne umfasst zwei Releases.**
   `git -C <Klon> for-each-ref --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.75*' 'refs/tags/v0.76*'`
   gibt `v0.75.0 2026-09-08` und `v0.76.0 2026-09-17` aus.
2. **Der CHANGELOG weist keinen Breaking Change aus**
   (`awk '/^## \[0\.76\.0\]/,/^## \[0\.74\.1\]/' CHANGELOG.md`):
   - `[0.75.0]` bringt das Modul `mentions` (opt-in, Grund-Code `artifact-unmentioned`).
   - `[0.75.0]` bringt das Feld `summary.notes` in der Lauf-Zusammenfassung, auch unter `--json`
     und `--yaml`. Laut Eintrag ist das die einzige Änderung an einer bestehenden Ausgabe. Kein
     Werkzeug dieses Repos liest `summary`
     (`git grep -n 'filesChecked\|findingCount' -- harness/tools test internal ':!*.md'` → kein
     Treffer).
   - `[0.76.0]` bringt die elfte `structure`-Bedingung `open-tasks-require-marker` mit dem neuen
     Grund-Code `section-open-tasks-marker-missing`. Ohne ihre Schlüssel verhält sich das Modul
     byte-identisch.
   - *Changed* betrifft nur den Harness des Werkzeugs selbst.

   Die Aufzählung bestätigt nur. Tragend sind Messung 3 und die Gegenmessung aus DoD 2.
3. **Keine Regeldatei eines aktiven Moduls ändert eine Zeile.** Aktiv sind acht Module
   (`grep -n '^modules:' .d-check.yml`).
   `git -C <Klon> diff --numstat v0.74.1..v0.76.0 -- internal/hexagon/core/rules/` nennt
   `mentions.go`, `run.go`, `structure.go`, `vcs.go` und `workflows.go` samt Tests, aber keine
   Regeldatei eines aktiven Moduls.
4. **Geteilte Infrastruktur verliert Zeilen.**
   `git -C <Klon> diff --numstat v0.74.1..v0.76.0 -- 'internal/**/*.go' ':!*_test.go'` führt
   `rules/run.go` mit +22/−6, `model/config.go` mit +59/−1 und zwei CLI-Dateien mit je −1. Damit
   greift die zweite Hälfte des Auflösungs-Triggers von
   [`MR-027`](../../../../harness/conventions.md#mr-027): Die Bilanz braucht die Gegenmessung auf
   einer Nicht-Null-Basis.

**Nicht gemessen im Planungslauf** sind der Digest, die frische `--print-mk`-Ausgabe, der
Trockenlauf und die Gegenmessung. Sie brauchen das Bild und zum Teil Netz; der Umsetzungs-Lauf
trägt sie (§2).

### Was bei uns rot werden kann

- **Ein neues Target im Fragment.** Das Modul `targets` ist aktiv. Bringt `--print-mk` ein neues
  Target mit, meldet es ein Target ohne Index-Eintrag, bis
  [`harness/README.md`](../../../../harness/README.md) es nennt oder `targets.exempt-targets` in
  [`.d-check.yml`](../../../../.d-check.yml) es führt.
- **Die Anker der Fixture** `internal/emit/testdata/raw-print-mk.txt`, an denen der Emitter hängt
  ([`MR-010`](../../../../harness/conventions.md#mr-010) §Auflösungs-Trigger).
- **Die geteilte Infrastruktur** aus Messung 4. Jedes aktive Modul läuft durch sie.
- **Aussagen mit dem alten Digest als Messstand.** In lebenden Artefakten zählt sie
  `git grep -n 'e31a372b' -- ':!.harness' ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr'`.
  - Unter den offenen Plänen nennen `slice-192-rtm-sieht-alle-anforderungen`,
    `slice-213-review-report-laeuft-in-der-tabellen-form` und
    `slice-spec-straten-zeigen-nicht-nach-aussen` den alten Stand.
  - `slice-mv-kanten-nach-done-sind-bewacht` und `slice-risiko-ausgang-hat-einen-sensor` stützen
    sich auf eine Messung an ihm.
  - Nach dem Sprung misst jeder dieser Slices in seinem eigenen Lauf neu. Dieser Slice ändert
    keinen von ihnen.
- **[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
  Re-Evaluierungs-Trigger 2:** *„Wenn ein Modul des Doku-Gates Status und Adress-Form
  zusammenhält."* Ob `v0.76.0` ein solches Modul liefert, prüft DoD 2.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **`open-tasks-require-marker` wird nicht aktiviert, und `structure` ebenso wenig.** *Ein
  Folge-Slice übernimmt es:* `slice-stilllegungs-form-hat-einen-waechter`. Die Aktivierung ist ein
  Anheben ([`MR-001`](../../../../harness/conventions.md#mr-001)) mit eigener Konfiguration,
  eigenem grünen Start und eigenem roten Gegenbeispiel. Für das emittierte Gate kommen die drei
  Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054) hinzu. Mit ihr hätte dieser
  Slice mehr als drei Liefer-Punkte.
- **Das Modul `mentions` wird nicht aktiviert.** *Bestand bleibt bewusst stehen:* Kein Plan und
  kein Befund verlangt es, und verfügbar heißt nicht aktiv.
- **Kein Adaptions-Eintrag zum Sprung.** *Anderer Vorgang:* Der Adaptions-Block gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); §6 führt die Übergabe.
- **Die Pläne und Messungen am alten Digest werden nicht nachgezogen.** *Anderer Vorgang:* Jeder
  misst in seinem eigenen Lauf neu (oben).
- **Kein Scan des gepinnten Bildes auf Schwachstellen.** *Anderer Vorgang:* §6 führt die Lücke.

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

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **1 — Der Pin steht auf `v0.76.0`, an beiden gekoppelten Stellen und mit belegtem Digest,
      und das Fragment ist re-adaptiert.**
      - `DCHECK_IMAGE` und `DCHECK_DIGEST` in [`d-check.mk`](../../../../d-check.mk) sowie
        `DefaultImage` und `DefaultDigest` in
        [`internal/emit/emit.go`](../../../../internal/emit/emit.go) tragen denselben Tag und
        denselben Digest. Der Digest ist aus der Registry und aus dem lokalen Bild belegt, mit
        Kommando im Umsetzungs-Commit.
      - Die Handgriffe aus [`MR-010`](../../../../harness/conventions.md#mr-010) Setzung 1 laufen
        gegen eine frische `--print-mk`-Ausgabe, und die Anker der Fixture sind gezählt.
      - Ein neues Target des Fragments steht im Gate-Index oder in `targets.exempt-targets`, und
        `make docs-check` meldet keinen Befund.
      - Der Kopf von `d-check.mk` spricht über den neuen Stand ([`AGENTS.md`](../../../../AGENTS.md)
        §3.7).
      - **Rot:** Wer nur `d-check.mk` bewegt, bringt `make test` an
        `TestDefaultImage_MatchesCanonical` und `TestDefaultDigest_MatchesCanonical` zu Fall. Die
        Meldung ist gelesen.
- [ ] **2 — Die Strenge-Bilanz über `v0.74.1..v0.76.0` ist gezogen, mit ihrer Richtung.**
      - Die Quell-Differenz der aktiven Regeldateien (§1 Messung 3) ist gegen ein falsches Negativ
        geprüft: An beiden Tags liegen dieselben Dateien unter denselben Pfaden.
      - Die geteilte Infrastruktur aus §1 Messung 4 ist gelesen, zuerst `rules/run.go`.
      - Der Trockenlauf beider Digests läuft über denselben Baum. Daneben steht, was er nicht zeigt.
      - Die Gegenmessung läuft auf einer Nicht-Null-Basis, in einer Kopie außerhalb des Repos mit
        entwerteten Markern. Zugesagt ist eine identische Befundmenge je Datei, Zeile und
        Grund-Code.
      - Die Antwort auf [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
        Trigger 2 steht mit Beleg im Umsetzungs-Commit.
      - Fällt die Bilanz auf **Senkung**, greift §4.
      - **Rot:** Die zwei Befundmengen weichen ab, oder das `numstat`-Kommando nennt eine
        Regeldatei eines aktiven Moduls.
- [ ] **3 — Jede Werkzeug-Aussage mit dem alten Digest als Messstand ist neu gemessen oder
      datiert** ([`MR-053`](../../../../harness/conventions.md#mr-053)).
      - Gemeint sind die Stellen in
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), die
        `e31a372b` als Messstand nennen. Darunter ist die Tabelle zur Stilllegung, die selbst sagt:
        *„wandert der Pin in `d-check.mk`, gilt sie für den alten Stand, bis jemand neu misst"*.
      - Die Stilllegungs-Messung ist am neuen Digest neu gefahren, denn die Gruppierung stützt
        sich auf sie.
      - **Rot:** `grep -n 'e31a372b' harness/sensors/docs-check.md` nennt eine Zeile, die den alten
        Stand als geltend ausgibt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: über Liefer-Punkt 3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target hinzu, zieht Liefer-Punkt 1 den Gate-Index nach.
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
| [`d-check.mk`](../../../../d-check.mk) | update | Pin, Kopf, Re-Adaption (DoD 1) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | emittierter Default, per go-Test gekoppelt (DoD 1) |
| `internal/emit/testdata/raw-print-mk.txt` | update, falls ein Anker fehlt | [`MR-010`](../../../../harness/conventions.md#mr-010) §Auflösungs-Trigger |
| [`harness/README.md`](../../../../harness/README.md) oder [`.d-check.yml`](../../../../.d-check.yml) | update, falls ein Target hinzukommt | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (DoD 1) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | DoD 3 |
| [`.d-check.yml`](../../../../.d-check.yml) (Kommentar am `commits`-Block) und [`harness/sensors/commit-msg-check.md`](../../../../harness/sensors/commit-msg-check.md) | update | Beide nennen den `--range`-Abbruch als Eigenschaft des gepinnten `v0.74.1`; nach dem Sprung ist die Aussage am neuen Stand nachgemessen und datiert ([`MR-053`](../../../../harness/conventions.md#mr-053)). Die Zählung in §1 lief über den Digest und fand diese zwei Tag-Nennungen nicht. |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei. Keine Abhängigkeit hält den Start.
**Die Gruppierung der Go-Slices startet erst, wenn dieser Slice und
`slice-stilllegungs-form-hat-einen-waechter` in `done/` liegen.**

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Bilanz fällt auf Senkung und
  braucht eine ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5), oder das Fragment braucht mehr als
  die Handgriffe aus [`MR-010`](../../../../harness/conventions.md#mr-010) Setzung 1.
- `in-progress` → `open` (blockiert — Carveout?): Der Digest von `v0.76.0` ist in der Registry
  nicht belegbar.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Unter dem neuen Pin meldet `make docs-check` keinen Befund, und `make test` hält die Kopplung.
2. Die Gegenmessung auf Nicht-Null-Basis zeigt identische Befundmengen, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Die leere Quell-Differenz liest sich als Freispruch.** Sie ist nur eine Untergrenze, denn die
   geteilte Infrastruktur bewegt sich (§1 Messung 4). *Absehbar:* entfallen, wenn die Gegenmessung
   aus DoD 2 identische Mengen liefert; sonst eingetreten, und §4 greift. — **Ausgang:** <offen>
2. **Vor dem Start erscheint ein weiterer Release.** *Absehbar:* entfallen, wenn der Slice vorher
   beginnt. Sonst zieht der Planner den Ziel-Tag in Titel und §1 nach, bevor der Slice beginnt;
   die Kennung nennt keinen Tag. — **Ausgang:** <offen>
3. **Kein Sensor dieses Repos scannt das gepinnte Bild.** `make freshness-dcheck` meldet einen
   neuen Tag, aber keine verwundbare Version. *Absehbar:* weiter offen, solange kein Slice die
   Frage nimmt. — **Ausgang:** <offen>
4. **Der Kopf von `d-check.mk` kann den Adaptions-Eintrag zu diesem Sprung erst nennen, wenn der
   Architect ihn geschrieben hat.** *Absehbar:* entfallen, wenn der Architect-Lauf vor der
   Umsetzung liegt. — **Ausgang:** <offen>

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein Adaptions-Eintrag zum Sprung `v0.74.1` → `v0.76.0` nach dem Muster von
[`MR-052`](../../../../harness/conventions.md#mr-052), in der Form aus
[`MR-053`](../../../../harness/conventions.md#mr-053). Er trägt die Messungen dieses Slice und nennt
`open-tasks-require-marker` und `mentions` als verfügbar, nicht aktiv.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `d-check.mk`, `.d-check.yml`, `internal/emit/`
und `harness/sensors/`; alle liegen in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind
nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | 2 | offen | DoD 3: die Messung nennt ihren Stand, und der Sprung bewegt ihn |
| [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) | 2 | offen | §1: das Delta ist am Quellstand gemessen, nicht aus dem CHANGELOG übernommen |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 2 | offen | §6 Risiko 1: Regeldateien sind nicht das Verhalten |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

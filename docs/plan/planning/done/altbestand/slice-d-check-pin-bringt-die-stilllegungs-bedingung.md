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

- [x] **1 — Der Pin steht auf `v0.76.0`, an beiden gekoppelten Stellen und mit belegtem Digest,
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
      - **Beleg:** Verifikations-Bericht `docs/reviews/2026-09-17-slice-d-check-pin-bringt-die-stilllegungs-bedingung-verify.md` §1 und §2.1 bis §2.2: Tag und Digest `sha256:f0b55fde…945396` stehen an beiden Stellen, das Fragment hat gegen die frische Ausgabe 8 Hunks, es sind 13 Targets wie zuvor, und jeder der fünf Anker steht einmal da. Das Rot der zwei Tests ist mit der richtigen Ursache gesehen.
- [x] **2 — Die Strenge-Bilanz über `v0.74.1..v0.76.0` ist gezogen, mit ihrer Richtung.**
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
      - **Beleg:** Quell-Differenz, gelesenes `rules/run.go` und Trockenlauf in `0fbefa46`. Die Gegenmessung je Modul steht in [`MR-063`](../../../../harness/conventions.md#mr-063), und Review Runde 2 hat sie mit eigenen Sonden reproduziert (61 = 61, `diff` leer). Ergebnis: keine Senkung, §4 greift nicht. [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Trigger 2 ist nicht eingetreten (Verifikation §2.3).
- [x] **3 — Jede Werkzeug-Aussage mit dem alten Digest als Messstand ist neu gemessen oder
      datiert** ([`MR-053`](../../../../harness/conventions.md#mr-053)).
      - Gemeint sind die Stellen in
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), die
        `e31a372b` als Messstand nennen. Darunter ist die Tabelle zur Stilllegung, die selbst sagt:
        *„wandert der Pin in `d-check.mk`, gilt sie für den alten Stand, bis jemand neu misst"*.
      - Die Stilllegungs-Messung ist am neuen Digest neu gefahren, denn die Gruppierung stützt
        sich auf sie.
      - **Rot:** `grep -n 'e31a372b' harness/sensors/docs-check.md` nennt eine Zeile, die den alten
        Stand als geltend ausgibt.
      - **Beleg:** `grep -n 'e31a372b' harness/sensors/docs-check.md` → kein Treffer. Die Stilllegungs-Tabelle nennt `v0.76.0` mit Digest, und zwei ihrer acht Lagen sind am neuen Digest nachgefahren (Verifikation §2.4).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: über Liefer-Punkt 3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target hinzu, zieht Liefer-Punkt 1 den Gate-Index nach.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
| [`Makefile`](../../../../Makefile) | update | Zwei handgeschriebene `--disable`-Listen folgen dem Fragment und der Modul-Liste: `commit-msg-check` schaltet `mentions` ab, `regelwerk-check` schaltet alle aktiven Module ab (dazu `targets`); der Kommentar dort nennt statt einer festen Zahl die zwei Kommandos, die gleich sein müssen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). |

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
   aus DoD 2 identische Mengen liefert; sonst eingetreten, und §4 greift. — **Ausgang:** **entfallen.** Die Gegenmessung je Modul in [`MR-063`](../../../../harness/conventions.md#mr-063) liefert identische Mengen, und Review Runde 2 hat sie reproduziert; §4 greift nicht.
2. **Vor dem Start erscheint ein weiterer Release.** *Absehbar:* entfallen, wenn der Slice vorher
   beginnt. Sonst zieht der Planner den Ziel-Tag in Titel und §1 nach, bevor der Slice beginnt;
   die Kennung nennt keinen Tag. — **Ausgang:** **entfallen**, nach dem eigenen Wortlaut: Der Slice begann vor dem nächsten Release (Verifikation V-2). `v0.76.1` erschien danach; den Sprung trägt der Auflösungs-Trigger von [`MR-061`](../../../../harness/conventions.md#mr-061) mit dem Folge-Slice `slice-d-check-pin-zieht-den-vcs-patch-nach`.
3. **Kein Sensor dieses Repos scannt das gepinnte Bild.** `make freshness-dcheck` meldet einen
   neuen Tag, aber keine verwundbare Version. *Absehbar:* weiter offen, solange kein Slice die
   Frage nimmt. — **Ausgang:** **weiter offen** → [`gepinntes-bild-ohne-schwachstellen-scan`](../observations/BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan/observation.md) im Register.
4. **Der Kopf von `d-check.mk` kann den Adaptions-Eintrag zu diesem Sprung erst nennen, wenn der
   Architect ihn geschrieben hat.** *Absehbar:* entfallen, wenn der Architect-Lauf vor der
   Umsetzung liegt. — **Ausgang:** **entfallen.** Jeder Architect-Lauf lag vor dem Umsetzungs-Commit, der den Kopf auf seinen Eintrag zeigen ließ: `966458a5` vor `675d1f03`, `87ef3941` vor `9f6484a9`.

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

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), über dem
Stand `5ba18366`. Maßstab sind Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln und `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, dort
die Tabelle der Träger im Repo ohne Wellen.

- **Was hat funktioniert:**
  - Das Rot aus DoD 1 hat die behauptete Ursache. Mit zurückgesetztem `internal/emit/emit.go`
    fallen genau `TestDefaultDigest_MatchesCanonical` und `TestDefaultImage_MatchesCanonical`, und
    beide Meldungen nennen das abweichende Paar (Verifikation §2.1).
  - Die dritte Stelle der Bilanz, die Regeldateien der Module außerhalb von `modules:`, fand die
    Verschärfung in `vcs`. Die Quell-Differenz der aktiven Module zeigt sie nicht.
  - Die zweite Review-Runde hat die Gegenmessung mit eigenen Sonden reproduziert, auch für drei
    Module, die in Runde 1 keine Basis hatten.
- **Was ging anders als geplant:**
  - **Die Rückführung aus §4 war dem Wortlaut nach ausgelöst, und der Slice ging trotzdem nicht
    zurück** (Verifikation V-1).
    - §4 nannte *mehr als die Handgriffe aus*
      [`MR-010`](../../../../harness/conventions.md#mr-010) *Setzung 1*. Dort standen vier, das
      Fragment trug aber schon vor dem Sprung fünf. Der fünfte stammt aus `slice-217` und ist
      jetzt in [`MR-062`](../../../../harness/conventions.md#mr-062) deklariert.
    - Der Sprung selbst brachte keinen Handgriff hinzu. Alte gegen neue Ausgabe zeigt nur die
      Zeile `DCHECK_IMAGE` und sechsmal `--disable mentions`, und beides übernimmt das Fragment
      wörtlich (Verifikation §2.2).
    - Die Bedingung bewacht, ob **der Sprung** den Adaptions-Aufwand vergrößert, und so liest sie
      diese Closure. Zu groß war der Slice nicht, denn die drei Liefer-Punkte blieben
      unverändert.
    - Der Folge-Plan schreibt die Bedingung in dieser Lesart, und das Register führt den Fall.
  - **Die Übergabe in §6 nannte einen Adaptions-Eintrag, entstanden sind drei**:
    [`MR-061`](../../../../harness/conventions.md#mr-061),
    [`MR-062`](../../../../harness/conventions.md#mr-062) und
    [`MR-063`](../../../../harness/conventions.md#mr-063).
    - [`MR-062`](../../../../harness/conventions.md#mr-062) deklariert Bestand.
    - [`MR-063`](../../../../harness/conventions.md#mr-063) wurde nötig, weil die Gegenmessung in
      [`MR-061`](../../../../harness/conventions.md#mr-061) nur drei der acht aktiven Module
      deckte (Review F-2).
    - [`MR-061`](../../../../harness/conventions.md#mr-061) war da schon gepusht. Deshalb heilte
      ein neuer Eintrag den Defekt, mit Kopf-Marken an
      [`MR-061`](../../../../harness/conventions.md#mr-061) und
      [`MR-052`](../../../../harness/conventions.md#mr-052).
  - **Drei Kommentare trugen ein Lauf-Protokoll** (Review F-1, HIGH). Vor der Closure verweisen
    sie stattdessen auf den Rang.
  - **§3 wuchs im ausführenden Kontext um das `Makefile`** (Review F-4). Das deckt
    `.claude/commands/implement-slice.md`; DoD, §1, §4 und §6 blieben unverändert.
  - **Nach dem Start erschien d-check `v0.76.1`** (Verifikation V-2). Laut `CHANGELOG.md`,
    `[0.76.1]`, bricht `vcs` jetzt ab, wo ein Lauf bisher still grün meldete.
  - **Die Nachmess-Übergabe aus §1 hatte beim Empfänger keinen Träger** (Verifikation V-3).
- **Entscheidungen zu den Übergaben aus der Verifikation:**
  - **V-1:** oben unter *Was ging anders als geplant*.
  - **V-2: Folge-Slice** `slice-d-check-pin-zieht-den-vcs-patch-nach` in `open/`.
    - Er hebt den Pin auf den Patch und zieht die Bilanz nach
      [`MR-063`](../../../../harness/conventions.md#mr-063).
    - Er misst den abbrechenden `vcs`-Fall, den
      [`MR-061`](../../../../harness/conventions.md#mr-061) als ungemessen führt.
    - Das Delta ist dort nur aus dem CHANGELOG gelesen. Digest und Quell-Differenz liefert der
      Umsetzungs-Lauf.
  - **V-3: Vermerk in den Plänen, keine Folge-Zeile hier.**
    - Warum nicht §7: Eine Zeile in §7 eines Plans in `done/` hat keinen Leser. Der Volltext eines
      geschlossenen Slice kommt in keinem lesenden Knoten vor (Baseline-Regelwerk
      `grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln, Absatz zum Fluss).
      Der Plan dagegen ist der Eingang des Laufs, der misst, und die offenen Pläne gehören dem
      Planner.
    - Vier Pläne nennen jetzt den Messstand `v0.74.1` und verweisen für den gepinnten Stand auf
      `d-check.mk`: `slice-192-rtm-sieht-alle-anforderungen`,
      `slice-213-review-report-laeuft-in-der-tabellen-form`,
      `slice-spec-straten-zeigen-nicht-nach-aussen` und
      `slice-stilllegungs-form-hat-einen-waechter`.
    - Warum ein Verweis statt `v0.76.0`: Mit dem Folge-Slice wäre ein Tag im Vermerk wieder
      falsch, und genau diese Klasse führt das Register.
    - `slice-mv-kanten-nach-done-sind-bewacht` und `slice-risiko-ausgang-hat-einen-sensor` nennen
      weder Pin noch Digest. Ihre Basis ist in DoD 3 neu gemessen.
    - Der Ausschluss aus §1 galt für den Umsetzungs-Lauf, nicht für den Planner. Gemessen wird
      weiterhin im eigenen Lauf.
  - **F-5 (INFO): Adresse ist DoD 1 des Folge-Slice**
    `slice-d-check-pin-zieht-den-vcs-patch-nach`, dazu ein Register-Beleg.
    - Urteil: nicht blockierend. Kein DoD-Punkt und kein Gate stützt sich auf den Kommentar, und
      die Namensmengen sind heute gleich.
    - Den Kommentar zieht der Lauf nach, der die `--disable`-Listen beim nächsten Sprung ohnehin
      gegen die Module hält. Er nutzt dafür den Namensvergleich aus der Verifikation.
  - **V-4: Register-Beleg, und der Folge-Slice zieht den Kopf nach** (dort DoD 1: *ein*
    Messstand).
    - Der Cutoff aus [`AGENTS.md`](../../../../AGENTS.md) §3.7 bindet die zwei alten Zeilen
      nicht, wohl aber den Verweis, den dieser Slice schrieb.
    - Beim nächsten Sprung wird der Kopf ohnehin angefasst.
- **Steering-Loop-Eintrag:** **Geschärfte Regel.**
  [`MR-063`](../../../../harness/conventions.md#mr-063) legt fest, wie die Gegenmessung eines
  d-check-Sprungs läuft; ihr Auflösungs-Trigger ist permanent.
  - Jedes aktive Modul bekommt eine Basis, die Symlinks bleiben stehen, und verglichen wird je
    Grund-Code.
  - Der nächste Sprung fährt diese Messung, statt eine Basis zu übernehmen, die nur einen Teil
    der Module deckt.
  - **Kein `liegt in`-Feld:** Die Regel entstand aus einem Review-Befund, nicht aus der
    3×-Schwelle; ihre Herkunft steht im Feld `Wirksamkeits-Anlass`.
  - Den Lese-Schritt tragen die drei Einträge unten, die zum ersten Mal 3× erreichen.
- **Beobachtungs-Register (`../observations/`):** Der Beleg heißt in jedem Fall
  `evidence/slice-d-check-pin-bringt-die-stilllegungs-bedingung.md`. Den Zähler liefert
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`. Die Zahl der Belege aus
  diesem Vorgang liefert
  `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-d-check-pin-bringt-die-stilllegungs-bedingung.md | wc -l`
  (→ 8). Keine der Zahlen ist ein Erwartungswert.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md) | Review F-1 (wiederkehrende Klasse laut Review) | 13 | verkörpert |
  | [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | Review F-2; Runde 2, N-1 | 3, zum ersten Mal | geplant |
  | [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) | die Spalten-Aussage in [`MR-052`](../../../../harness/conventions.md#mr-052), abgelöst durch [`MR-063`](../../../../harness/conventions.md#mr-063) (Review Runde 2) | 3, zum ersten Mal | geplant |
  | [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | Verifikation V-3, V-4 | 3, zum ersten Mal | geplant |
  | [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | Review F-5 | 17 | geplant |
  | [`rueckfuehrungs-schwelle-misst-nicht-die-eigenschaft-die-sie-bewacht`](../observations/BEO-ALL/rueckfuehrungs-schwelle-misst-nicht-die-eigenschaft-die-sie-bewacht/observation.md) | Verifikation V-1 | 2 | offen |
  | [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md) | [`MR-061`](../../../../harness/conventions.md#mr-061) → [`MR-063`](../../../../harness/conventions.md#mr-063) | 1, neu | offen |
  | [`gepinntes-bild-ohne-schwachstellen-scan`](../observations/BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan/observation.md) | §6 Risiko 3 | 1, neu | offen |

  **Lese-Schritt.** Drei Einträge erreichen mit diesem Slice zum ersten Mal 3×:

  - `stellen-messung-als-eigenschaft-ausgegeben`: `slice-stilllegungs-kanten-sind-gemessen`,
    `slice-mv-zieht-praefixlose-geschwister-verweise-nach` und dieser Slice.
  - `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`: `slice-125`, `slice-193`
    und dieser Slice.
  - `werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`:
    `slice-stilllegungs-kanten-sind-gemessen`,
    `slice-mv-zieht-praefixlose-geschwister-verweise-nach` und dieser Slice.

  - **Ausgang für alle drei: geplant**, Kennung
    `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` (in `open/`).
  - **Warum geplant:** Keiner der drei Einträge hat einen Zielort, der seine Klasse ganz deckt.
    [`MR-053`](../../../../harness/conventions.md#mr-053) und
    [`MR-055`](../../../../harness/conventions.md#mr-055) setzen zwei der Regeln nur für
    Einträge des Adaptions-Blocks, und die dritte steht nirgends.
  - **Warum ein Slice statt drei:** Alle drei betreffen dieselbe Artefaktklasse und dieselbe
    Lücke. Sie brauchen dasselbe Verdikt des Architect zu Zielort und schreibender Rolle
    (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b).
    Das Verdikt holt jener Slice ein, nicht diese Closure.
  - **Die zwei anderen Einträge über der Schwelle behalten ihren Ausgang:**
    `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` und
    `zusage-nennt-sensor-der-form-nicht-sieht`. Der Fall liegt jeweils innerhalb der Grenze, die
    ihre `state.md` nennt.

  **Nicht getragen, mit Urteil:**

  - **F-3** (*vier Anker* gegen fünf): In
    [`MR-063`](../../../../harness/conventions.md#mr-063) behoben, und der Review nennt keine
    Wiederholung.
    - `extensionale-zahl-unterschreitet-die-eigene-fundmenge` passt nicht: Gezählt war eine
      fremde Aufzählung, nicht die eigene Fundmenge.
  - **F-4** (Diff-Datei fehlt in der Plan-Tabelle): §3 darf im ausführenden Kontext wachsen.
    - `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` betrifft Beweisführung, nicht Dateien.
  - **F-6** (Verweis auf eine abgelöste Setzung): In
    [`MR-063`](../../../../harness/conventions.md#mr-063) behoben. Der Verweis läuft nur über
    eine Station mehr und ist kein Defekt.
  - `naechste-rolle-uebernimmt-vor-dem-schluss-der-vorigen-runde`: Runde 2 hat die Nacharbeit
    freigegeben, bevor die Verifikation übernahm.
  - `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: Die Closure setzt den Ruhe-Marker
    in einem eigenen Commit nach ihrem Move.
- **Trigger-Audit** (wellenlos, bei der Slice-Closure):
  - **Carveout:** `CO-001` steht auf *Auflösung fällig*, die Adresse ist
    `slice-113-co-001-ist-faellig` in `open/`. `CO-002` steht auf *permanent*. Dieser Slice
    berührt keine ihrer Bedingungen.
  - **Bootstrap-aware Gate:** keines vorhanden
    (`grep -n -i 'bootstrap-aware' Makefile *.mk harness/mk/*.mk` → kein Treffer).
  - **ADR:**
    - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md), Trigger 2
      (*„Wenn ein Modul des Doku-Gates Status und Adress-Form zusammenhält."*): **nicht
      eingetreten, gemessen.**
      - Der `--print-config`-Vergleich beider Digests bringt nur `mentions` in die
        Verfügbar-Liste und zwölf Kommentarzeilen zu `open-tasks-require-marker`.
      - Keine dieser Zeilen verbindet Status und Adress-Form, und `planning.go` ist unverändert
        (`0fbefa46`, Review Runde 1, Verifikation §2.3).
      - Am neuen Stand prüft den Trigger der nächste Pin-Sprung.
    - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md), Trigger 1, 3
      und 4: nicht berührt. Der Slice bewegt weder die Baseline noch `make slice-mv`, und keine
      Aussage der ADR ist durch ihn falsch geworden.
    - [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md): Keiner ihrer Trigger
      ist berührt, denn dieser Slice führt keinen Baseline-Sprung aus.
  - **Adaptions-Einträge dieses Slice:**
    - [`MR-061`](../../../../harness/conventions.md#mr-061), permanent (*bei jedem
      d-check-Release*): **ausgelöst** durch `v0.76.1`. Träger ist
      `slice-d-check-pin-zieht-den-vcs-patch-nach`.
    - [`MR-063`](../../../../harness/conventions.md#mr-063), permanent (*bei jedem
      d-check-Sprung*): Ausgeführt wird er von demselben Folge-Slice (dort DoD 2).
    - [`MR-062`](../../../../harness/conventions.md#mr-062), zwei Fälle: Keiner ist eingetreten.
      - Die Menge der Ziele ohne eigenen Block ist nicht leer; das hält Fall 2 des bats-Wächters
        fest, grün in Review Runde 1.
      - Die `v0.76.0`-Ausgabe von `--print-mk` erzeugt den Hinweis nicht selbst
        (Verifikation §2.2).
      - Für `v0.76.1` misst beides der Folge-Slice.
    - Die permanenten Trigger von [`MR-010`](../../../../harness/conventions.md#mr-010),
      [`MR-027`](../../../../harness/conventions.md#mr-027) und
      [`MR-052`](../../../../harness/conventions.md#mr-052) hängen am selben Release. Auch sie
      trägt derselbe Folge-Slice.
- **Folge-Slices:**
  - `slice-d-check-pin-zieht-den-vcs-patch-nach` (neu, in `open/`): V-2, F-5, V-4 und der
    Auflösungs-Trigger von [`MR-061`](../../../../harness/conventions.md#mr-061).
  - `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` (neu, in `open/`): aus dem
    Lese-Schritt.
  - `slice-stilllegungs-form-hat-einen-waechter` (vorhanden, in `open/`): die Aktivierung, die §1
    ausschließt.
- **Risiken aus §6:** Jedes hat genau einen Ausgang. 1, 2 und 4 sind entfallen, 3 bleibt weiter
  offen.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.
- **Drei Paarungen** (§2):
  - (a) Kein Gegenstand, denn diese Notiz führt kein `liegt in`-Feld.
  - (b) Getragen: Alle drei genannten Folge-Slices liegen als Datei in `open/`
    (`ls docs/plan/planning/open/<kennung>.md`).
  - (c) Getragen: Jede genannte Beobachtung existiert als Verzeichnis, und jedes davon trägt
    mindestens einen Beleg (Tabelle oben).

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

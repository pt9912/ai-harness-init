# Slice slice-sprung-auf-v6181-wird-vollzogen: Jeder Träger des Tags steht auf `v6.18.1`, und die Emission folgt den umgeschriebenen Vorlagen-Adressen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung beobachtet mehr als die DoD dieses Slice
(`make gates`, `make baseline-verify` und `make full-smoke` stehen in §2); Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Tag-Klammer),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (Vorlagen wandern ins Ziel),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Template-Ablage),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) (regierende Fassung des Sprungs und Emissions-Urteil; `Accepted`),
[`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) (Muster der regierenden Fassung),
[`MR-007`](../../../../harness/conventions.md#mr-007) (Vendoring),
[`MR-025`](../../../../harness/conventions.md#mr-025).
Auslöser: Auftrag des Auftraggebers vom 2026-10-16 — der Patch-Sprung ist klein, die Emission darf nicht vergessen werden.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Sprung `v6.18.0` → `v6.18.1` ist vollzogen — vendored Baum, fünf gekoppelte Pins, Mess-Tag,
Symlinks und jede lebende Adresse stehen auf `v6.18.1` — **und** der Emitter folgt den im Delta
umgeschriebenen Vorlagen-Adressen, so dass ein frisch gebootstrapptes Ziel grün startet.

**Delta**, gemessen am 2026-10-16 (keine Erwartungswerte, [`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2):

```sh
gh api repos/pt9912/ai-harness-course/compare/v6.18.0...v6.18.1 --jq '[.files[].filename]'
#   CHANGELOG.md · docs/roadmap.md · tools/rewrite-template-links.sh   (3 Commits; kurs/de und lab/regelwerk nicht berührt)
gh release view v6.18.1 -R pt9912/ai-harness-course --json assets --jq '.assets[]|[.name,.digest]|@tsv'
#   lab-regelwerk.zip  sha256:c3a256ed971b27c15286588760add53770c52766054641cdf8487db6524bed31 · SHA256SUMS
diff -rq .harness/baseline/v6.18.0 <entpacktes Asset>        # Asset in ein eigenes leeres Verzeichnis
diff -r  .harness/baseline/v6.18.0/regelwerk <entpackt>/regelwerk | grep '^[<>]' | grep -vc 'Quelle:'   # Regelwerk-Inhalt
diff -r  .harness/baseline/v6.18.0/templates <entpackt>/templates | grep '^[<>]'                       # Vorlagen
```

Inhalt: Der Bundle-Bau schreibt in Vorlagen jeden Code-Span-Pfad, der auf `.template.md` endet und im
Vorlagen-Baum existiert, auf `.harness/baseline/<tag>/templates/<pfad>` um (Kurs-Welle 162, fünf Treffer in vier
Vorlagen). Gemessen am Asset: das Regelwerk trägt nur den neuen Tag in den `Quelle:`-Kommentaren und in
zwei Kurs-URLs der `README.md` (der Inhalts-Diff ohne `Quelle:`-Zeilen zählt 4 Zeilen); fünf Vorlagen
weichen ab — die Vorlagen von Reviewer-Skill, Closure-Note-Reviewer, Harness-README und Konventionsspeicher (Adress-Umschreibung)
und die `AGENTS`-Vorlage (Tag der Release-URL). Die Release-Assets heißen `lab-regelwerk.zip` und `SHA256SUMS`; der
Digest des Assets ist am 2026-10-16 an `gh` und an `shasum -a 256` des heruntergeladenen Assets gemessen
und gleich — der Implementer misst beim Tausch neu.

**Träger, gemessen über dem Arbeitsbaum dieses Plans** (keine Erwartungswerte):

```sh
grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile                        # kanonisch
grep -n 'lab-regelwerk' -A 1 .d-check.yml
grep -nE 'Default(Tag|BaselineSHA256) =' internal/fetch/baseline.go
grep -n 'const InventurMessTag' internal/emit/baumaussage.go
readlink .claude/rules/*.md | grep -c 'baseline/v6\.18\.0'
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.18\.0[^)]*\)' -- "${PS[@]}" | wc -l   # Links
git grep -oE '`[^`]*\.harness/baseline/v6\.18\.0[^`]*`'     -- "${PS[@]}" | wc -l   # Inline-Pfade
git grep -l 'baseline/v6.18.0' -- ':!*.md' ':!.harness/baseline'                    # nicht-Markdown-Träger
```

**Emission — was der Plan misst und was er offen lässt.** Der emittierte Vorlagen-Satz kommt aus dem
vendored Baum (`internal/emit/templates.go`). Gelesen am Wortlaut: der Marker `conventionsPathRefOld`
(zwei Zeilen, `` `harness/conventions/MR-NNN-titel.template.md` ``) trifft den Text von `v6.18.1` nicht mehr, weil
die Adresse dort das Präfix `.harness/baseline/<tag>/templates/` trägt. **Verdikt A2**
([`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) Festlegung 2): die Neutralisierung bleibt stehen, die
Erwartung `conventionsPathRefOld` in `test/neutralisierung-marker.bats` wird von `1` auf `0` gesetzt, die umgeschriebenen
Adressen bleiben im emittierten Satz stehen — kein Einsetzen des Tags, kein Tabellen-Update in `internal/emit/templates.go`
(nur der Kommentar zur Zeile darf nachgezogen werden). Gemessen hat der Architect `codepaths` am Scratch-Repo; **nicht
gemessen** ist der Lauf im frischen Ziel — den Beleg, dass das emittierte `codepaths` die Inline-Pfade mit dem Literal
`<tag>` nicht als `codepath-missing` meldet, trägt `make full-smoke`.
Die Proben im Kommentar von `StripCommentHints` gelten laut ihrem Wortlaut je für den Satz, gegen den sie gefahren wurden.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Release `v0.8.0` und sein Tag-Push.** *Folge-Slice:* [`slice-release-schnitt-v080-liefert-die-baseline-v6181`](../open/slice-release-schnitt-v080-liefert-die-baseline-v6181.md)
  nimmt ihn an; sein Start-Trigger ist dieser Slice in `done/`.
- **`reviews` im Dogfood scharf schalten.** *Folge-Slice:* [`slice-review-deckung-laeuft-im-dogfood`](../open/slice-review-deckung-laeuft-im-dogfood.md)
  trägt es; das Delta berührt Modul 10 nicht.
- **Dogfood-Instanzen der Vorlagen** (Reviewer-Skill, `harness/README.md`, `harness/conventions.md`) auf die neuen Adressen ziehen.
  *Bestand bleibt bewusst stehen:* das Delta ändert die Bundle-Form der Adresse; die Instanzen tragen Pfade, die im eigenen Repo auflösen.
- **Eingefrorene Adressen** (`done/**`, `docs/plan/carveouts/done/**`, Register, `Accepted`-ADRs).
  *Bestand bleibt stehen* ([`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.11); trägt eine `Accepted`-ADR einen Link in
  `v6.18.0/`, wird ihre Deckung **vor** dem Tausch beim Architect angefragt.
- **Norm-Texte.** *Schicht-Abgrenzung:* die Übergaben unten schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**Übergaben an den Architect** (keine Liefer-Punkte; je eigener Commit):

- **A1 — entschieden:** eigene Kurz-ADR, [`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) (Bezug
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md), kein `supersedes`); liegt als Architect-Commit vor,
  Status `Proposed`.
- **A2 — entschieden:** Verdikt in [`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) Festlegung 2, siehe Emission oben; liegt mit ihr als Architect-Commit vor.
- **A3 — nach dem Vollzug:** Buchung §Baseline in [`harness/conventions.md`](../../../../harness/conventions.md);
  Sprung-Zeile in [`harness/migration.md`](../../../../harness/migration.md) §1 (zitiert [`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md)) samt der tag-tragenden Pfade
  des Instanz-Registers; Freshness-Verdikt über die Kandidaten [`MR-008`](../../../../harness/conventions.md#mr-008), [`MR-020`](../../../../harness/conventions.md#mr-020), [`MR-026`](../../../../harness/conventions.md#mr-026), [`MR-028`](../../../../harness/conventions.md#mr-028), [`MR-029`](../../../../harness/conventions.md#mr-029), [`MR-031`](../../../../harness/conventions.md#mr-031),
  [`MR-034`](../../../../harness/conventions.md#mr-034), [`MR-038`](../../../../harness/conventions.md#mr-038), [`MR-045`](../../../../harness/conventions.md#mr-045), [`MR-060`](../../../../harness/conventions.md#mr-060), [`MR-072`](../../../../harness/conventions.md#mr-072) ([`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) Festlegung 1) **vor** dem Entfernen von `v6.18.0/`
  (Register `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums`).

## 2. Definition of Done

Zwei Liefer-Punkte, einer je Achse (Baseline · Emission).

- [x] **1 — Jeder Träger des Tags steht auf `v6.18.1`, und keine lebende Adresse bleibt auf `v6.18.0`.** Baum über
      [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md) aus dem verifizierten Asset (einmal Netz,
      [`MR-007`](../../../../harness/conventions.md#mr-007)); `make baseline-verify` meldet `v6.18.1 OK`; fünf Pins gesetzt,
      sha256 am Asset gemessen, Kommando im Tausch-Commit; `make regelwerk-check` → `0 Befund(e)`; Mess-Tag und
      Symlinks auf `v6.18.1`; das Link-Kommando aus §1 liefert **0** außerhalb von `ignore-refs`-Paaren. Tausch- und
      Nachzugs-Commit in einem Push, Nachzug je Eigentümer ein Commit mit Rolle.
      **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein echter Pin-Wert bleibt einmal auf `v6.18.0`, ein
      Pin-Wächter wird mit einer Meldung über genau diese Stelle rot.
- [x] **2 — Die Emission folgt den umgeschriebenen Adressen.** Jeder der fünf Treffer bleibt nach Verdikt A2 stehen;
      `test/neutralisierung-marker.bats` meldet je Marker die erwartete Trefferzahl am neuen Baum, für
      `conventionsPathRefOld` `0`; die drei Proben im Kommentar
      von `StripCommentHints` sind gegen den neuen Satz gefahren und leer; `make full-smoke` startet am frischen Ziel grün,
      und im emittierten Satz steht keine Adresse, die im Ziel nicht auflöst (Kommando im Beleg).
      **Rot gesehen:** der Wächter ist die Erwartung `conventionsPathRefOld:0`; er wird an der **realen** Quelle rot, wenn der
      Marker wieder trifft (der vendorte Baum wird so verändert, dass die Adresse ohne Präfix steht — nicht die Fixture) —
      der Bats-Fall meldet genau diese Stelle.
- [x] `make gates` grün über dem Liefer-Stand; `make full-smoke` endet EXIT 0.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), volle Slice-Kennung im
      Dateinamen — Rollenwechsel nach Schritt 8 des Minimal Agent Workflow, kein Self-Review (Modul 8).
- [x] Doku-Update: die Architect-Übergaben A1–A3 liegen als eigene Commits vor.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen sind getragen — das Repo fährt Wellen; sie prüft die nächste Welle-Closure.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.18.1/` · `.harness/baseline/v6.18.0/` | neu · entfernt (nach A3-Verdikt) | Liefer-Punkt 1 |
| `Makefile`, `.d-check.yml` (`sources`), `internal/fetch/baseline.go` | update | fünf Pins (1) |
| `internal/emit/baumaussage.go`, `internal/emit/templates.go` (Kommentar-Adressen), `.claude/rules/*.md` | update | Mess-Tag, Adressen, Symlinks (1) |
| lebende Markdown-Artefakte mit Adresse | update | 1 — je Eigentümer ein Commit |
| `internal/emit/templates.go` (nur Kommentar zur Zeile `conventionsPathRefOld`; Tabelle unverändert), `internal/emit/*_test.go` | update, falls Fixture den alten Wortlaut führt | 2, Verdikt A2 |
| `test/neutralisierung-marker.bats`, `test/mutations/577-conventions-neutralisierung-faellt-im-ziel-aus.sh` | update (Erwartung `0`) · entfernen oder neu verankern ([`MR-071`](../../../../harness/conventions.md#mr-071)) | Wächter für 2 (reale Quelle) |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | unverändert (A2 verlangt keine Stufe) | Beleg am frischen Ziel (2) |
| `test/sources-pin.bats`, `internal/fetch/*_test.go` | unverändert | Wächter für 1 |

## 4. Trigger

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice; die Übergaben A1 und A2 liegen mit
[`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) als Architect-Commit vor, **erfüllte Startbedingung:** die Annahme
von [`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) (`Accepted`, Beleg: ADR-Kopf und ADR-Index); `make baseline-freshness` meldet keinen neueren Tag als `v6.18.1`; einmal Netz für
`make vendor-baseline` und `make regelwerk-check`; WIP-Limit frei. Der Zug nach `in-progress/` landet auf dem Hauptzweig.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Liefer-Punkt 2 übersteigt eine Review-Sitzung (Wächter-Anpassung und Fall `577`) —
  er wird eigener Slice, mit der Release-Bedingung *kein Tag zwischen den Vorgängen*.
- `in-progress` → `open`, jede Bedingung für sich hinreichend: **(a)** der am Asset gemessene sha256 weicht ab, oder
  `make vendor-baseline` bricht an seiner Sperre ab; **(b)** das frische Ziel startet mit der nach A2 gewählten Behandlung
  nicht grün — der Architect urteilt neu; **(c)** eine `Accepted`-ADR trägt einen Link in `v6.18.0/`, und ihre Deckung ist vor dem Tausch nicht entschieden.

## 5. Closure-Trigger

1. `make baseline-verify` meldet `v6.18.1 OK`; `make gates` grün; das Link-Kommando aus §1 und
   `readlink .claude/rules/*.md | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.18\.1/'` liefern **0**;
   `make full-smoke` EXIT 0 mit dem Beleg aus Liefer-Punkt 2.
2. Die Architect-Übergaben A1–A3 liegen als Commits vor; Review und Verifikation liegen unter `docs/reviews/`.

**Lerneintrag** in einer der drei Formen, §7. Die Closure schreibt der Planner in frischem Kontext und eigenem Commit
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Die Neutralisierung fällt am neuen Stand still aus** — `conventionsPathRefOld` trifft nicht mehr (nach A2 gewollt); ohne
  Wächter am realen Baum bliebe ein Test über einer Fixture grün. Der Wächter ist die Erwartung `0` in `test/neutralisierung-marker.bats`.
  **Ausgang: entfallen** — der Wächter steht und ist an der realen Quelle rot gesehen (Verifikation F-3).
- **Fall `577` und Fixtures tragen den alten Wortlaut** — `test/mutations/577-conventions-neutralisierung-faellt-im-ziel-aus.sh`
  dürfte am neuen Baum keinen Treffer mehr haben (Folgerung, nicht gemessen), und `internal/emit/*_test.go` könnten den alten
  Wortlaut als Fixture führen. Der Implementer prüft beides und entscheidet über Fall `577` nach
  [`MR-071`](../../../../harness/conventions.md#mr-071) (entfernen oder neu verankern). **Ausgang: eingetreten** — Fall `577` ist entfernt (`26ef8f20`); die
  Restlücke (Aufruf am Pin ohne realen Wächter) ist **weiter offen** im Register:
  [`BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture`](../observations/BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture/observation.md).
- **Das frische Ziel startet nicht grün** — Inline-Pfade mit dem Literal `<tag>` im emittierten Satz. Das wäre das dritte Auftreten von
  [`BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`](../observations/BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt/observation.md)
  (heute 2×) und bekäme einen eigenen Folge-Slice. **Ausgang: entfallen** — nicht eingetreten: `make full-smoke-host` EXIT 0, `codepath-missing` nennt nur den beabsichtigten Zahn; kein drittes Auftreten (Messgrenze: §7).
- **Tag-tragende Adresse überlebt den Tausch nicht** — das Link-Kommando aus §1 fängt es
  ([`BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht`](../observations/BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht/observation.md), Stand `geplant`).
  **Ausgang: entfallen** — nicht eingetreten: das Link-Kommando aus §1 liefert 0 außerhalb von `ignore-refs`-Paaren, die Symlink-Probe 0.
- **Asset → vendored Baum bleibt ungehalten** — `SHA256SUMS` ist selbst erzeugt; die Herkunft hält allein der Vendoring-Vorgang
  ([`MR-007`](../../../../harness/conventions.md#mr-007)). **Ausgang: weiter offen** — Register
  [`BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../observations/BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
  (Stand `offen`); kein neuer Beleg, hier trat nichts auf, und die Verifikation hat Asset gegen Baum nicht nachgemessen.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-16

- **Was hat funktioniert:** DoD 1, 2 und `make gates` bestätigt
  ([Verifikation](../../../reviews/2026-10-16-slice-sprung-auf-v6181-wird-vollzogen-verify.md),
  `0007e163`): `make baseline-verify` → `v6.18.1 OK`, fünf Pins und Mess-Tag auf `v6.18.1`, sieben
  Symlinks, Link-Kommando 0, `make regelwerk-check` → 0 Befunde, `make full-smoke-host` EXIT 0.
  Rot gesehen vom Verifier an echten Werten: Makefile-Pin `v6.18.0` → `test/sources-pin.bats` rot; sha in
  `.d-check.yml` verfälscht → rot; `DefaultTag` → `TestDefaultTag_MatchesBaseline` rot; Präfix im vendorten
  Baum entfernt → `conventionsPathRefOld: 1 Treffer … erwartet 0`. Review
  ([Report](../../../reviews/2026-10-16-slice-sprung-auf-v6181-wird-vollzogen.md), `a85c72bd`): 0 HIGH,
  0 MEDIUM, 1 LOW, 2 INFO. Architect-Übergaben A1 bis A3:
  [`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) `Accepted`, Commits `5f294fbd`,
  `2a44411b`, `c63d2f48`.
- **Grenze von DoD 2 (Verifikation F-2):** gemessen ist *„nicht als `codepath-missing` gemeldet"*, nicht
  *„löst im Ziel auf"*. Die Literale `<tag>` im emittierten Satz lösen im Ziel nicht auf; das emittierte
  `codepaths` hat `roots: [spec, docs, harness]`, und `.harness/…` liegt außerhalb. Ein Sensor für „löst auf"
  existiert nicht. Der Haken trägt die engere Aussage.
- **Nicht gelaufen:** `make mutate-auswahl` endete beim Implementer mit Exit 10 (Weg über den CI-Branch
  `mutate/…`); es wurde nicht gepusht, ein Ergebnis liegt nicht vor
  ([`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)). Die DoD verlangt die Probe nicht;
  der einzige Fall zum Gegenstand (`577`) ist entfernt, `make mutate-greift` läuft grün in `make gates`.
  Die Probe trägt für diesen Slice keine Zusage, und über sie wird nichts behauptet; der Nacht-Vollsweep
  bleibt der Träger.
- **Was ging anders als geplant:** Fall `577` fiel weg statt neu verankert zu werden (die Mutation ist am
  Pin ohne Wirkung, [`MR-071`](../../../../harness/conventions.md#mr-071)); das Freshness-Verdikt
  `c63d2f48` ist ein leerer Commit, das Verdikt steht in seiner Message (Review INFO-2) — nach A3
  zulässig, auffindbar über `git log --grep Freshness-Verdikt`.
- **Steering-Loop-Eintrag:** Benannte Lücke, im Register geführt: ein Aufruf, der am Pin ohne Wirkung ist,
  behält nur eine Fixture als Wächter und trägt die Begründung nicht am Ort der Zusage (LOW-1);
  `conventionsPathRefOld:0` unterscheidet nicht „Präfix steht" von „Satz entfällt" (INFO-1, folgenlos, den
  Ende-zu-Ende-Beleg trägt `make full-smoke`). Gezählt, nicht verkörpert; **kein Folge-Slice** — ein Satz am
  Kommentar von `NeutralizeConventionsTemplateRef` ist kein Slice, und die Beobachtung steht bei 1×; wer die
  Stelle anfasst, zieht den Satz nach. Dieser Abschluss schrieb keinen Produktionscode.
- **Beobachtungs-Register (`../observations/`):**
  - neu: [`BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture`](../observations/BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture/observation.md)
    (LOW-1), 1×, `offen`.
  - ein Beleg mehr: [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
    (F-2: eine Adresse, die im Ziel nicht auflöst, liegt außerhalb der `codepaths`-roots); Stand
    `verkörpert`, unverändert.
  - Kein Beleg: `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` bleibt bei 2×
    ([`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) Festlegung 2; das Ziel startet
    grün, F-2 ist eine Messgrenze, kein Rot); `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums`
    trat nicht ein (Verdikt `c63d2f48` vor dem Entfernen `e10c2328`), bleibt bei 1×;
    `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` trat nicht ein.
  - Kein Eintrag ohne Ausgang erreicht 3×.
- **Folge-Slices:** keiner angelegt; der Start-Trigger von
  [`slice-release-schnitt-v080-liefert-die-baseline-v6181`](../open/slice-release-schnitt-v080-liefert-die-baseline-v6181.md)
  (dieser Slice in `done/`) ist mit dem Move erfüllt.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines.
  [`ADR-0093`](../../adr/0093-ziel-fassung-regiert-den-sprung-v6181.md) Re-Evaluierungs-Trigger: nicht
  eingetreten. Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist
  nicht gebaut, wie beim Vorgänger).
- **Risiken aus §6:** jede Zeile in §6 hat ihren Ausgang (dreimal entfallen, einmal eingetreten, einmal weiter offen).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — Tag und Vorlagen stehen in `Makefile`,
`.d-check.yml`, `internal/`, `.claude/rules/`, `harness/`, `docs/`. `TOOLS` ist nur über `harness/tools/full-smoke.sh` berührt,
falls A2 eine Stufe verlangt, ohne neue Mechanik; `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand (`79801cd8`) gesichtet, alle Einträge führen `*`;
Zähler = `ls <eintrag>/evidence/*.md | wc -l`, gemessen am 2026-10-16, keine Erwartungswerte.

| Eintrag | Zähler | Berührung |
|---|---|---|
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 2 (offen) | Liefer-Punkt 2 — ein drittes Auftreten ist in §6 benannt |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 3 (geplant) | Liefer-Punkt 1, Link-Kommando |
| `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums` | 1 (offen) | A3 verlangt das Verdikt vor dem Entfernen |
| `re-baseline-ohne-inventur-slice` | 2 (offen) | kein Auftreten — das Delta ist in §1 gemessen |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 2 (offen) | kein Auftreten — die Dogfood-Instanzen bleiben bewusst stehen (§1) |
| `baseline-sprungweite-treibt-kosten` | 3 (verkörpert) | kein Auftreten — ein Patch-Abstand |

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area).

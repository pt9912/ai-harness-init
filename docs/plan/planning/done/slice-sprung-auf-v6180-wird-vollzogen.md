# Slice slice-sprung-auf-v6180-wird-vollzogen: Jeder Träger des Tags steht auf `v6.18.0`, und Dogfood wie emittiertes Ziel folgen dem Delta der Review-Deckung

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
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate über leerer Menge),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (Vorlagen wandern ins
Ziel),
[`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) (Muster der regierenden
Fassung; die Fassung für `v6.18.0` ist [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md), Architect-Übergabe A1),
[`MR-007`](../../../../harness/conventions.md#mr-007) (Vendoring),
[`MR-054`](../../../../harness/conventions.md#mr-054) (drei Kriterien für ein emittiertes Modul),
[`MR-086`](../../../../harness/conventions.md#mr-086) (`reviews` bleibt aus dem emittierten Gate),
[`MR-025`](../../../../harness/conventions.md#mr-025).

**Berührte Spec-Stellen:** — (Adressen in den vendored Baum zählen die Kommandos in §1 mit; ihr
Nachzug ist Adresse, keine Spec-Änderung).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Sprung `v6.17.0` → `v6.18.0` ist nach der regierenden Fassung ([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md), Architect-Übergabe
A1) vollzogen — vendored Baum, fünf gekoppelte Pins, Mess-Tag, Symlinks und jede lebende Adresse
stehen auf `v6.18.0` —, und **beide Ebenen** folgen dem Delta: der Dogfood und das, was das
Werkzeug ins Ziel emittiert (Auftrag des Auftraggebers vom 2026-10-10).

**Delta**, gemessen am maschinen-lokalen Kurs-Klon `$K` (keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2):

```sh
git -C "$K" diff --stat v6.17.0 v6.18.0 -- kurs/de           # allein modul-10-review-harness.md
git -C "$K" diff --stat v6.17.0 v6.18.0 -- lab/templates lab/regelwerk
#   .d-check.yml · docs/reviews/review-report.template.md · harness/README.template.md
#   · regelwerk/modul-10-review-harness.md · regelwerk/README.md (Stand-Zeile)
```

Inhalt: eine Regel-Welle, *die Review-Deckung läuft nicht leer*. Modul 10 verlangt, dass ein
Deckungs-Sensor den Leerlauf meldet (keine erkannte Zusage unter vorhandenen Slices), den Report
über die **volle** Slice-Kennung zuordnet und archivierte Slices nicht mehr als Kandidaten führt
(alle archiviert = Ruhezustand); abgelegt wird ein Report mit der vollen Slice-Kennung im
Dateinamen. Die Vorlage `.d-check.yml` trägt `reviews` weiter **auskommentiert**, jetzt mit
`match: name`, `require-promises`, `recursive`, `skip-pattern` und `skip-allows-empty`; die
README-Vorlage nennt diese Voraussetzungen; die Report-Vorlage die volle Kennung im Dateinamen.
Bezugsstand der Vorlage ist d-check `v0.86.1`.

**Träger, gemessen über dem Arbeitsbaum dieses Plans** (keine Erwartungswerte):

```sh
grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile                        # kanonisch
grep -n 'lab-regelwerk' -A 1 .d-check.yml
grep -nE 'Default(Tag|BaselineSHA256) =' internal/fetch/baseline.go
grep -n 'const InventurMessTag' internal/emit/baumaussage.go
readlink .claude/rules/*.md | grep -c 'baseline/v6\.17\.0'
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.17\.0[^)]*\)' -- "${PS[@]}" | wc -l   # Links
git grep -oE '`[^`]*\.harness/baseline/v6\.17\.0[^`]*`'     -- "${PS[@]}" | wc -l   # Inline-Pfade
git grep -l 'baseline/v6.17.0' -- ':!*.md' ':!.harness/baseline'
grep -n 'reviews' internal/emit/templates/d-check.yml | head -3        # emittierter Kommentar-Block
grep -n 'docs/reviews/<' .harness/skills/reviewer.md                   # Ablage-Form im Dogfood
```

Emittiert werden `review-report.template.md` und `.harness/baseline/v6.18.0/templates/harness/README.template.md` aus dem vendored
Baum (`internal/emit/templates.go`, `internal/emit/werkzeugindex.go`); die emittierte
`.d-check.yml` ist dagegen die eigene Vorlage `internal/emit/templates/d-check.yml`, nicht die der
Baseline.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der d-check-Pin `v0.86.1`.** *Anderer Vorgang:* `slice-d-check-pin-bringt-den-go-sicherheitsfix`
  trägt ihn; dieser Slice startet erst, wenn jener in `done/` liegt (§4).
- **`reviews` im Dogfood scharf schalten, falls die Sonde Befunde über dem `done/`-Bestand
  meldet.** *Anderer Vorgang:* das Nachziehen fehlender oder falsch benannter Reports über den
  Bestand wächst mit dem Bestand, nicht mit dem Delta; ergibt A2 die Aktivierung und meldet die
  Sonde Befunde, schneidet der Planner dafür einen eigenen Slice, und hier wird nur das Verdikt
  getragen.
- **Umbenennen vorhandener Reports.** *Bestand bleibt stehen:* `docs/reviews/**` sind
  Zeitdokumente ([`AGENTS.md`](../../../../AGENTS.md) §3.7, §3.11); die Ablage-Regel bindet neue
  Reports.
- **Eingefrorene Adressen** (`done/**`, `docs/plan/carveouts/done/**`, Register,
  `Accepted`-ADRs). *Bestand bleibt stehen* ([`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.11);
  trägt eine `Accepted`-ADR einen Link in `v6.17.0/`, wird ihre Deckung **vor** dem Tausch beim
  Architect angefragt.
- **Norm-Texte.** *Schicht-Abgrenzung:* die Übergaben unten schreibt der Architect.

**Übergaben an den Architect — vor dem Start** (keine Liefer-Punkte; je eigener Commit,
[`AGENTS.md`](../../../../AGENTS.md) §3.8):

- **A1 — ADR *„Ziel-Fassung regiert den Sprung v6.18.0"*, `Proposed`,** nach dem Muster von
  [`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md); die Annahme entscheidet der
  Auftraggeber. Sie trägt das Delta, die Kandidaten des Freshness-Durchgangs (wer Modul 10, die
  Report-Ablage oder `reviews` nennt) und die Re-Evaluierungs-Trigger. Liegt vor als
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md), `Accepted`; ihre
  Festlegungen 2–4 tragen das Verdikt A2.
- **A2 — Delta-Urteil zu [`MR-086`](../../../../harness/conventions.md#mr-086), beide Ebenen.**
  (a) *Emission:* bleibt `reviews` im emittierten Gate auskommentiert (der Kommentar-Block zieht
  die neuen Schlüssel nach), oder wird es aktiv? Zu messen am Pin `v0.86.1` mit einem frisch
  gebootstrappten Ziel und der Konfiguration der Vorlage (`match: name`, `require-promises`,
  `recursive`, `skip-pattern`, `skip-allows-empty`): startet es grün? Die Nachprüfung des
  Pin-Slice hat gezeigt, dass ein leeres `done/` fail-closed rot startet, auch mit
  `skip-allows-empty` — dann hält der Auflösungs-Trigger von [`MR-086`](../../../../harness/conventions.md#mr-086) nicht, und der Eintrag
  bleibt mit nachgezogener Begründung. (b) *Dogfood:* wird `reviews` hier aktiviert
  ([`MR-054`](../../../../harness/conventions.md#mr-054) Kriterium 1 hängt daran)? Die Sonde über
  dem `done/`-Bestand liefert die Befund-Zahl samt Kommando.
- **A3 — nach dem Vollzug:** Buchung §Baseline in
  [`harness/conventions.md`](../../../../harness/conventions.md) mit Zeiger auf [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md);
  Sprung-Zeile in [`harness/migration.md`](../../../../harness/migration.md) §1; Freshness-Verdikt
  über die Kandidaten aus [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) **vor** dem Entfernen von `v6.17.0/` (Register
  `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums`).

## 2. Definition of Done

Drei slice-eigene Punkte, einer je Achse (Baseline · Dogfood · Emission).

- [x] **1 — Jeder Träger des Tags steht auf `v6.18.0`, und keine lebende Adresse bleibt auf
      `v6.17.0`.** Baum über [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md)
      aus dem verifizierten Release-Asset (einmal Netz,
      [`MR-007`](../../../../harness/conventions.md#mr-007)); `make baseline-verify` meldet
      `v6.18.0 OK`; fünf Pins gesetzt, sha256 am Asset gemessen, Kommando im Tausch-Commit;
      `make regelwerk-check` → `0 Befund(e)`; Mess-Tag und Symlinks auf `v6.18.0`; das
      Link-Kommando aus §1 liefert **0** außerhalb von `ignore-refs`-Paaren. Tausch- und
      Nachzugs-Commit in einem Push, Nachzug je Eigentümer ein Commit mit Rolle.
      **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein echter Pin-Wert bleibt einmal
      auf `v6.17.0`, ein Pin-Wächter wird mit einer Meldung über genau diese Stelle rot.
- [x] **2 — Der Dogfood folgt dem Delta.** Die Ablage-Form neuer Reports nennt die volle
      Slice-Kennung im Dateinamen (Reviewer-Skill und die Rollen-Anweisungen, die die Form
      nennen; je Eigentümer ein Commit,
      [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); `harness/README.md`
      nennt die Review-Deckung im Ist-Zustand nach Verdikt A2(b) — aktiv mit den Schlüsseln der
      Vorlage und grünem `make docs-check`, oder ausdrücklich nicht aktiv mit Grund.
- [x] **3 — Die Emission folgt dem Delta.** Die emittierten Vorlagen (Report-Vorlage, README-Vorlage des Harness)
      tragen den Stand `v6.18.0`; `internal/emit/templates/d-check.yml` folgt Verdikt A2(a) —
      Kommentar-Block mit den neuen Schlüsseln oder aktives Modul. Beleg in `make full-smoke` am
      frischen Ziel: das Ziel-Gate startet grün; ist `reviews` aktiv, färbt ein Slice in `done/`
      mit Review-Zusage und ohne Report das Ziel-Gate rot (Meldung gelesen), sonst hält ein
      Go-Test den Block auskommentiert und ein Fall in `test/mutations/` färbt ihn rot.
      `e2e_abdeckung`-Deklaration und `make e2e-abdeckung` nachgezogen.
- [x] `make gates` grün über dem Liefer-Stand; `make full-smoke` endet EXIT 0.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die Architect-Übergaben A1–A3 aus §1 liegen als eigene Commits vor; Handbuch
      (`docs/user/`) im Ist-Zustand, falls die Emission das Ziel-Gate ändert.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap, die Datei existiert nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure — das Repo fährt Wellen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.18.0/` · `.harness/baseline/v6.17.0/` | neu · entfernt (nach A3-Verdikt) | Liefer-Punkt 1 |
| `Makefile`, `.d-check.yml` (`sources`), `internal/fetch/baseline.go` | update | fünf Pins (1) |
| `internal/emit/baumaussage.go`, `internal/emit/templates.go`, `.claude/rules/*.md` | update | Mess-Tag, Adressen, Symlinks (1) |
| lebende Markdown-Artefakte mit Adresse | update | 1 — je Eigentümer ein Commit |
| `.harness/skills/reviewer.md`, Rollen-Anweisungen mit `docs/reviews/<…>` | update | Ablage-Form (2) |
| `harness/README.md`, ggf. `.d-check.yml` (`reviews`) | update | 2, nach Verdikt A2(b) |
| `internal/emit/templates/d-check.yml`, `internal/emit/werkzeugindex.go` | update | 3, nach Verdikt A2(a) |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Beleg am frischen Ziel (3) |
| `internal/emit/*_test.go`, `test/mutations/` | update · neu | Wächter für 3 |
| `test/sources-pin.bats`, `internal/fetch/*_test.go` | unverändert | Wächter für 1 |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-d-check-pin-bringt-den-go-sicherheitsfix` liegt in
`done/` (d-check `v0.86.1` gepinnt, der Bezugsstand der Vorlage); [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) ist `Accepted`;
das Verdikt A2 liegt als Commit vor; WIP-Limit frei; einmal Netz für `make vendor-baseline` und
`make regelwerk-check`; `make baseline-freshness` meldet keinen neueren Tag als `v6.18.0`. Der Zug
nach `in-progress/` landet auf dem Hauptzweig.

**Startbedingung erfüllt** (2026-10-10): der Vorgänger liegt in `done/`; [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) ist `Accepted`
(`c82071b7`) und trägt das Verdikt A2 in ihren Festlegungen 2–4; `in-progress/` trägt keinen Slice;
`make baseline-freshness` meldet `latest: v6.18.0`; der Auftraggeber hat den Sprung freigegeben.
Netz für `make vendor-baseline` und `make regelwerk-check` braucht der Implementer-Lauf.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Liefer-Punkt 3 übersteigt eine Review-Sitzung (aktives `reviews` im Ziel
  samt neuer `full-smoke`-Stufe und Emitter-Änderung) — dann wird er als eigener Slice
  abgeschnitten, mit der Release-Bedingung *kein Tag zwischen den Vorgängen*.
- `in-progress` → `open`, jede Bedingung für sich hinreichend: **(a)** der am Asset gemessene
  sha256 weicht ab, oder `make vendor-baseline` bricht an seiner Sperre ab; **(b)** das frische
  Ziel startet mit der gewählten Emission nicht grün, abweichend vom Verdikt A2(a) — der
  Architect urteilt neu; **(c)** eine `Accepted`-ADR trägt einen Link in `v6.17.0/`, und ihre
  Deckung ist vor dem Tausch nicht entschieden.

## 5. Closure-Trigger

1. `make baseline-verify` meldet `v6.18.0 OK`; `make gates` grün; das Link-Kommando aus §1 und
   `readlink .claude/rules/*.md | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.18\.0/'`
   liefern **0**; `make full-smoke` EXIT 0 mit dem Beleg aus Liefer-Punkt 3.
2. Die Architect-Übergaben A1–A3 liegen als Commits vor; Review und Verifikation liegen unter
   `docs/reviews/`, mit der vollen Slice-Kennung im Dateinamen.

**Lerneintrag** in einer der drei Formen, §7. Die Closure schreibt der Planner in frischem Kontext
und eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Emittierter Stand läuft dem Dogfood voraus** — aktiviert A2 `reviews` im Ziel, nicht aber
  hier, ist das das dritte Auftreten der Klasse; dann braucht sie einen eigenen Folge-Slice (§8).
  **Ausgang: entfallen** — das Ziel aktiviert `reviews` nicht
  ([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegungen 2 und 4); der
  Eintrag bleibt bei 2×, `offen`.
- **Grünes Ziel über leerer Menge** — `skip-allows-empty` und `require-promises` ziehen gegen
  einander; ein grüner Start über null Kandidaten darf nicht als Deckung gelesen werden
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Die
  Grenz-Aussage im Ziel nennt die Bedingung.
  **Ausgang: entfallen** — im Ziel ist das Modul nicht aktiv, ein grüner Start über null Kandidaten
  entsteht nicht (fail-closed mit leerer Prüfmenge gemessen,
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 2); die Stufe
  `review_vorlagen_im_ziel` nennt am selben Ort, dass der Text gemessen ist. Die Aktivierung im
  Dogfood trägt `slice-review-deckung-laeuft-im-dogfood` mit eigenem Rot-Beleg.
- **`match: name` deckt nur den längsten passenden Slice-Namen** — ein Report, dessen Name einen
  kürzeren Slice als Präfix eines längeren trägt, fällt dem längeren zu (Befund des Pin-Slice).
  Die Sonde in A2 misst es am Bestand.
  **Ausgang: entfallen** — die Sonde fand `Praefix-Paare=0` über dem `done/`-Bestand
  ([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 3); die Grenze
  für künftige Paare trägt der Abschnitt von `slice-review-deckung-laeuft-im-dogfood`.
- **Tag-tragende Adresse überlebt den Tausch nicht** — Liefer-Punkt 1 fängt es mit dem
  Link-Kommando.
  **Ausgang: entfallen** — nicht eingetreten: das Link-Kommando aus §1 liefert 0
  ([Verifikation](../../../reviews/2026-10-10-slice-sprung-auf-v6180-wird-vollzogen-verify.md)).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-10

- **Was hat funktioniert:** DoD 1 bis 3 bestätigt
  ([Verifikation](../../../reviews/2026-10-10-slice-sprung-auf-v6180-wird-vollzogen-verify.md),
  `84c1499e`): `make baseline-verify` → `v6.18.0 OK`, fünf Pins und Mess-Tag auf `v6.18.0`, sieben
  Symlinks, Link-Kommando 0, `make gates` und `make full-smoke` EXIT 0. Rot gesehen: Pin-Wert
  `v6.17.0` → `test/sources-pin.bats` rot; `skip-allows-empty` aus dem Block entfernt →
  `TestDCheckConfig_ReviewsBleibtKommentarBlock` rot mit dem Schlüssel in der Meldung. Mutation
  140/140 `ok` über `mutate/…-e5a3000b`, beide Branches gelöscht. Review
  ([Report](../../../reviews/2026-10-10-slice-sprung-auf-v6180-wird-vollzogen.md), `678d3980`):
  0 HIGH, 1 LOW, annahmereif. Architect-Übergaben A1 bis A3: `ADR-0091` `Accepted`, Commits
  `4a617506`, `32bbd041`, `ed76b475`.
- **Was ging anders als geplant:** Die Verifikation lief vor dem Review-Report und meldete ihn als
  F-1 offen; `678d3980` erledigt ihn. `reviews` bleibt in beiden Ebenen aus (Dogfood:
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 3, vom
  Auftraggeber gewählt).
- **Steering-Loop-Eintrag:** Neuer Sensor: `TestDCheckConfig_ReviewsBleibtKommentarBlock` hält jeden
  der fünf Schlüssel des emittierten `reviews`-Blocks einzeln, dazu die `full-smoke`-Stufe
  `review_vorlagen_im_ziel` (Text im Ziel). Benannte Grenzen: die Haltbarkeit der vier neuen
  Schlüssel überwacht kein Fall in `test/mutations/` (Review LOW-1, Verifikation F-2) — gezählt in
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md),
  deren Sensor `slice-der-mutations-treiber-sieht-bindung-und-abdeckung` trägt; dass ein
  aktivierter Block im Ziel greift, misst keine Stufe (F-3, in der Stufe benannt). Gezählt, nicht
  verkörpert.
- **Beobachtungs-Register (`../observations/`):**
  - [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
    (LOW-1, F-2) → ein Beleg mehr, Stand `geplant`, unverändert.
  - Kein weiterer Beleg: `emittierter-stand-laeuft-dem-dogfood-voraus` bleibt bei 2×
    ([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 4);
    `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums` trat nicht ein (Verdikt
    `ed76b475` liegt vor dem Entfernen `e5a3000b`); F-3 ist die in der Stufe benannte Grenze.
  - Kein Eintrag ohne Ausgang erreicht 3×.
- **Folge-Slices:** `slice-review-deckung-laeuft-im-dogfood` (`open/`, nimmt die Aktivierung nach
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 3 an); für F-2
  keiner angelegt, Entscheidung beim Auftraggeber.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines.
  [`MR-086`](../../../../harness/conventions.md#mr-086): Auflösungs-Trigger nicht eingetreten (am
  Pin `v0.86.1` startet das Ziel mit `reviews` rot,
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 2). Re-Evaluierungs-Trigger von
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md): nicht eingetreten. Hard
  Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice`
  ist nicht gebaut).
- **Risiken aus §6:** jede Zeile in §6 hat ihren Ausgang (viermal entfallen).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — Tag und Vorlagen stehen
in `Makefile`, `.d-check.yml`, `internal/`, `.claude/rules/`, `.harness/skills/`, `harness/`,
`docs/`. `TOOLS` ist über `harness/tools/full-smoke.sh` berührt, ohne neue Mechanik der Sub-Area;
`CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, alle
Einträge führen `*`, gesichtet nach Gegenstand (reviews · Baseline · Emission). Zähler:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte.

| Eintrag | Zähler | Berührung |
|---|---|---|
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 2 (offen) | Verdikt A2 — `reviews` aktiv im Ziel und nicht hier wäre das dritte Auftreten (§6) |
| `zusicherung-ueber-der-leeren-menge-wahr` | 3 (verkörpert) | Kern des Delta; Liefer-Punkt 3 nennt die Bedingung im Ziel |
| `re-baseline-ohne-inventur-slice` | 2 (offen) | kein Auftreten — die Inventur trägt [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) |
| `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums` | 1 (offen) | A3 verlangt das Verdikt vor dem Entfernen |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 3 (geplant) | Liefer-Punkt 1, Link-Kommando |
| `baseline-sprungweite-treibt-kosten` | 3 (verkörpert) | kein Auftreten — ein Minor Abstand |
| `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` | 1 (offen) | Liefer-Punkt 1 aus dem Asset |
| `abnahme-kommando-trifft-datierte-messaussage` | 1 (offen) | Closure-Trigger 1 zählt Adressen, keine datierten Messaussagen |
| `stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen` | 1 (offen) | Liefer-Punkt 1 — Stand-Felder außerhalb von §Baseline mitzählen |
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 2 (offen) | Liefer-Punkt 3 — die README-Vorlage nennt `doc-reviews`; das Ziel führt es nur mit aktivem Modul |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 5 (geplant) | die Prosa des `reviews`-Blocks ist eine solche Aussage; die Sonde in A2 misst sie |
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | 13 (verkörpert) | Liefer-Punkt 3 — die Grenz-Aussage nennt, was im Ziel gemessen wird |

Kein offener Eintrag erreicht mit diesem Slice erstmals 3×, außer im Fall aus §6.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

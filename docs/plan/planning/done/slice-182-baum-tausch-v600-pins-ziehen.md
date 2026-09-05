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
[slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md); dieser Slice vollzieht.

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

- [x] **Der Baum ist getauscht.** `.harness/baseline/v6.0.0/{regelwerk,templates}` samt
      `SHA256SUMS` liegt committet, `.harness/baseline/v5.18.0/` ist entfernt, und
      `make baseline-verify` meldet `v6.0.0 OK`. Genau ein Tag liegt im Baum — die Zusage von
      [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
      ist keine Vollständigkeits-, sondern eine Eindeutigkeits-Aussage und wird als solche belegt
      (`ls -d .harness/baseline/v*/ | wc -l` → 1).

      **Und die fünf Pin-Stellen tragen denselben Tag.** `BASELINE_TAG` und
      `BASELINE_ZIP_SHA256` (`Makefile`), `sources`-`url`/`sha256` in
      [`.d-check.yml`](../../../../.d-check.yml) sowie `DefaultTag`/`DefaultBaselineSHA256`
      in `internal/fetch/baseline.go` nennen `v6.0.0` bzw. den sha256 seines
      Release-Assets, und `make regelwerk-check` (Netz, **nicht** in `make gates`) ist grün.
      Der vendored Baum stammt aus **diesem** Asset, oder der Unterschied zum
      `git archive`-Stand ist gemessen und benannt. **Kein Gate deckt das:**
      `baseline-verify` entdeckt das `<tag>`-Verzeichnis statt `BASELINE_TAG` zu lesen, und
      `test/sources-pin.bats` koppelt die fünf nur untereinander — beide sind grün,
      während Baum und Pins verschiedene Tags tragen. Der Pin ist die einzige Kette zur
      Upstream-Provenienz (`SHA256SUMS` ist selbst erzeugt,
      [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Präzedenz:
      [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) DoD 1.
- [x] **Kein lebender Verweis zeigt auf den alten Tag.** Bezugsmenge und Ausschlüsse gemessen statt
      behauptet: `git grep -n '\.harness/baseline/v5\.18\.0' -- '*.md' '*.go' '*.sh' '*.yml'
      'Makefile'` außerhalb der eingefrorenen Bestände (`docs/plan/planning/done/`,
      `docs/reviews/`, `harness/conventions/done/`, `docs/plan/adr/` — Accepted-ADRs sind nach
      [`AGENTS.md`](../../../../AGENTS.md) §3.4 unantastbar) trifft **null**. Die Symlinks unter
      `.claude/rules/` zeigen auf den neuen Baum; ihre Zahl bleibt, was
      [`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
      als geschlossene Menge führt. **Bestands-Prosa, die einen vergangenen Stand als
      Herkunfts-Anker nennt, ist nicht betroffen** — sie trägt kein `.harness/baseline/`-Segment.

      **Fünfter Ausschluss, nachgezogen statt der Vollständigkeit halber behauptet:** derselbe Lauf
      trifft außerhalb der vier Verzeichnisse **nicht** null, sondern **38** Treffer über **18**
      Dateien (obiges Kommando; kein Erwartungswert,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2 — die Zahl wandert mit jedem Text, der den abgelösten Tag zitiert). Davon **2** in
      dieser Plan-Datei selbst (ihre eigene DoD-/Tabellen-Zeile nennt den entfernten Pfad namentlich
      — trivial exempt, sie beschreibt ihren eigenen Gegenstand); **32** in 13 weiteren Dateien
      (neun offenen Slice-Plänen, zwei Welle-Plänen, `docs/plan/planning/observations.md` —
      BEO-021/BEO-023 — und `.harness/skills/reviewer.md`, dessen Re-Pin-Log je Fassung die zwei
      `diff`-Kommandos führt, mit denen sie gemessen wurde), jeder ein **datierter Mess-Zeitbezug**
      nach
      [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist):
      er steht in einem Kommando oder Zitat, das den Tag nennt, gegen den es gemessen wurde.
      **Zwei davon sind Tree-Operanden** und dürfen gerade nicht gezogen werden — dort ist der alte
      Pfad der richtige, und eine Ersetzung machte aus einem laufenden Kommando eines, das `fatal`
      meldet (`grep -cE '[0-9a-f]{7,40}\^?:\.harness/baseline/v5\.18\.0'` über der Trefferliste →
      **2**, `BEO-036`). **4** liegen in `harness/conventions.md` §Modus-Deklaration und den drei
      Adaptions-Einträgen
      [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)/[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)/[`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)
      und damit in Architect-Schreibrecht ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — ob deren
      Zitate selbst re-verifiziert gehören, ist eine Architect-Entscheidung, keine
      DoD-2-Verletzung nach
      [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
      Setzung 1.

      **Was `make gates` davon trägt, und was nicht.** `docs-check` ist über allen 18 Dateien grün,
      und das belegt **keinen toten Link** — nicht *keinen toten Pfad*. Als Pfad in den
      Arbeitsbaum sind alle 38 tot, denn `.harness/baseline/v5.18.0/` liegt nicht mehr darin;
      gesehen wird davon keiner, weil keiner als Markdown-Link geschrieben ist
      (`grep -cE '\]\([^)]*\.harness/baseline/v5\.18\.0'` über der Trefferliste → **0**). Die
      Zusage dieses Punktes ist deshalb nicht *ein Sensor deckt die 38*, sondern *jeder der 38 ist
      von Hand klassifiziert, und keiner ist ein lebender Verweis in den entfernten Baum*.
- [x] **Die Zielstand-Setzung ist verbucht.** §Baseline von
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
- [x] `make gates` grün. **Dazu `make full-smoke`** — der Baum-Tausch von
      [welle-10](../done/welle-10-re-baseline.md) brach genau dort und blieb für `make gates`
      unsichtbar ([slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)).
- [x] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice. Ein öffentlicher
      Vertrag ist nicht berührt — der vendored Baum ist Infrastruktur, kein Nutzer-sichtbares
      Verhalten.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.0.0/` | neu | der vendored Baum des Zielstands, netzlos verifizierbar |
| `.harness/baseline/v5.18.0/` | entfernt | genau ein Tag liegt im Baum ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| `Makefile`, [`.d-check.yml`](../../../../.d-check.yml), `internal/fetch/baseline.go` | update | die fünf Pin-Stellen (DoD 1) |
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
  docs/plan/planning/done/slice-193-baseline-v600-bump.md`, §9). — **Ausgang: weiter offen →
  Beobachtungs-Register, `BEO-009`.** Beide vom Nachbar-Repo genannten
  Klassen sind aufgetreten. Die **Version-Annotation neben einem Zitat** zweimal, beide in diesem
  Slice behoben: `docs/user/benutzerhandbuch.md` zeigte eine Beispielausgabe, die das Werkzeug
  nicht mehr erzeugt, und der Kopf von `.harness/skills/reviewer.md` deklarierte eine Baseline,
  die das Repo nicht mehr führt (Version 1.7.0). Die **Selbstauskunfts-Zahlen des begleitenden
  Adaptions-Eintrags** einmal, und sie steht: [`AGENTS.md`](../../../../AGENTS.md) §1 sagt
  *„12 eindeutige Ziele, 0 tot — gemessen"* ohne das Kommando, das genau das liefert, und ihr
  einziger Beleg in
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  misst gegen `v5.12.0`, zwei Sprünge zurück. Dieser Slice zieht sie nicht nach und **nennt dafür
  keinen Träger**: keine geplante Arbeit adressiert sie
  (`git grep -l '12 eindeutige Ziele' -- docs/plan/planning/open/ docs/plan/planning/next/` → leer,
  Exit 1; derselbe Lauf über `docs/plan/planning/` trifft zwei Dateien, und beide sind geschlossene
  oder laufende Vorgänge statt Träger). Der Zähler ist ihre Route —
  `BEO-009` führt die Unterklasse *Prosa-Zahl* ausdrücklich als ungedeckt, und eine erfundene
  Folge-Slice-ID wäre ein Ausgang, der formal steht und materiell leer ist.
- **Die Zwei-Commit-Trennung fällt unter Zeitdruck zusammen** (`BEO-009`, 10×, **geplant**). Der
  Architect-Commit für §Baseline ist die Bedingung, unter der
  [`AGENTS.md`](../../../../AGENTS.md) §3.8 überhaupt nachträglich an `git log --stat` ablesbar
  ist; er ist kein Formalismus. — **Ausgang: entfallen.** Die Trennung hat gehalten, und zwar an
  jedem der vier rollen-benannten Commits dieses Slice. Gemessen je Commit mit
  `git show --pretty=format: --name-only <c>`, gefiltert gegen die Artefakte der jeweils
  schreibenden Rolle: die zwei Architect-Commits (`faa8178`, `ab2ed5a`) berühren nur
  [`AGENTS.md`](../../../../AGENTS.md), `harness/conventions.md`, `harness/conventions/` und
  `docs/plan/adr/`; die zwei Planner-Commits (`548a20e`, `ba83212`) nur `docs/plan/planning/`.
  Der Rest der Ausgabe ist in allen vier Fällen leer. Mit der Closure schließt das Zeitfenster
  dieses Risikos — der nächste Sprung setzt es neu.
- **`make full-smoke` ist im Closure-Trigger genannt, aber nicht in `make gates`.** Ein Lauf, der
  nur `make gates` fährt, hält den Slice für fertig. Der Fehlerfall ist gemessen und nicht
  hypothetisch ([slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)). —
  **Ausgang: entfallen.** Der Lauf, gegen den das Risiko steht, ist die Closure dieses Slice, und
  sie hat `make full-smoke` gefahren statt sich auf `make gates` zu verlassen — Ergebnis in §7. Die
  Eigenschaft dahinter bleibt und ist kein Risiko, sondern eine benannte Anordnung:
  [`harness/README.md`](../../../../harness/README.md) führt `full-smoke` unter *Nicht-Gate-Verify*,
  und `grep -n '^record-gates:' Makefile` zeigt, dass die Zielliste des Gate-Laufs ihn nicht nennt.
  DoD 4 dieses Plans nennt ihn deshalb ausdrücklich daneben; der nächste Baum-Tausch trägt dasselbe
  Risiko erneut und braucht dieselbe Zeile.
- **Das emittierte Repo hat seit diesem Baum-Tausch KEINE stehende Register-Datei mehr — und für
  diese Hälfte weist keine Quelle einen Träger aus.** Die alte Vorlage `observations.template.md`
  (flaches `docs/plan/planning/observations.md`, ein Ziel je Repo) ist upstream mit `v6.0.0`
  entfallen; ihr Nachfolger `observation.template.md` nennt einen Ziel-Ort MIT zwei Platzhaltern
  (`docs/plan/planning/observations/BEO-<KUERZEL>/<slug>/`,
  [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md))
  und ist damit nach `emit.isRecurring` wiederkehrend statt Singleton. Dieser Slice zieht nur die
  Klassifikation (`emit.isRecurring`, `test/courseset-fixture.bats`) auf den jetzt geltenden
  Zustand nach; er erfindet keine Lösung.

  **Der Zustand im Ziel ist gemessen, nicht hergeleitet.** Ein frisch gebootstrapptes Repo trägt
  kein `observations/` und sagt zugleich, es trage eines: nach `make host-bin` den Träger aus dem
  Zustands-Bereich in einem leeren `git init`-Verzeichnis mit `--name Probe` laufen lassen, dann
  dort `ls -d docs/plan/planning/observations` → *nicht gefunden*, während
  `grep -c 'observations/' docs/plan/planning/README.md` → **1** die Ablage als vorhanden
  beschreibt. Ein frisches Repo bekommt damit weder einen Ort für den Sichtungs-Schritt noch die
  leere Ablage, die *nichts beobachtet* von *nie geführt* unterscheidet
  (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register).

  **Warum hier trotzdem kein Träger steht.** Von den **7** Mitgliedern dieser Welle
  (`grep -c '^| \[slice-' docs/plan/planning/welle-15-re-baseline.md`) berührt keines die
  emittierte Ablage. [slice-177](../in-progress/slice-177-beobachtungs-register-verzeichnis-form.md) legt
  die Ablage **dieses** Repos an ([`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1) und nennt die Emit-Ebene nicht
  (`grep -c 'internal/emit' docs/plan/planning/in-progress/slice-177-beobachtungs-register-verzeichnis-form.md`
  → **0**); [slice-184](../open/slice-184-register-form-im-bestand-nachziehen.md) zieht die
  emittierten **Anweisungssätze** nach, und alle seine Emit-Stellen zeigen dorthin
  (`grep -c 'internal/emit' docs/plan/planning/open/slice-184-register-form-im-bestand-nachziehen.md`
  → **4**, dasselbe Kommando mit dem Muster `internal/emit/templates/commands` → ebenfalls **4**).
  Auch der Katalog in
  [slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 führt die Position **P-14** als
  **RE** (*bindet dieses Repo*) statt als **RE + EM**; die Begründung, die dort die Emit-Ebene
  ausschließt (**P-12**), misst den **repo-eigenen** Vorlagensatz
  (`find internal/emit/templates -path '*planning*' | wc -l` → **0**), während `emit.planTemplates`
  den **vendored** Satz begeht. Genau diese Differenz lässt die emittierte Hälfte durchfallen.

  **Und ein Ersatz verlangt eine Entscheidung, die keine Quelle trifft.** `v6.0.0` liefert **keine**
  Vorlage für die `README.md`, die dasselbe Modul jedem Repo ab Beginn zuschreibt
  (`find .harness/baseline/v6.0.0/templates -path '*observations*' | wc -l` → **0**) — wer die
  Lücke schließt, entscheidet zuerst, ob dieses Repo dafür einen eigenen Vorlagen-Text führt oder
  die emittierte Aussage zurücknimmt. Keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). — **Ausgang: weiter offen → Beobachtungs-Register, `BEO-038`**
  (neue Kennung, Erstauftreten). Der dritte Ausgang ist hier der einzige, der nicht lügt: Ein
  Carveout schaltete einen roten Gate-Status auf einen Trigger, und rot ist hier nichts — kein Gate
  sieht die Lücke. Eine Folge-Slice-ID wäre ein Ausgang, der formal steht und materiell leer ist:
  Von den sieben Mitgliedern dieser Welle adressiert keines die Emit-Ebene dieser Ablage, und die
  Entscheidung, die ein Träger zuerst bräuchte — eigener Vorlagen-Text oder Rücknahme der
  emittierten Aussage —, trifft keine Quelle.
- **Ein Mutations-Fall, dessen `# files:`-Ziel dieser Tausch entfernt, legt `make mutate` repo-weit
  still.** Der Treiber berechnet den Fingerabdruck **aller** Ziele vor dem ersten Fall
  (`target_fingerprint` in `harness/tools/mutate.sh`); ein fehlendes Ziel bricht den Lauf ab, statt
  den je Fall angekündigten lauten Befund zu liefern — die Vollständigkeits-Schranke in
  `merge_report` kommt dann gar nicht mehr zum Zug. **Eingetreten, und in diesem Slice behoben:**
  `test/mutations/219` und `220` trugen die upstream entfallene `observations.template.md` und
  zielen jetzt auf `AGENTS.template.md`, deren Kopiere-Satz dieselbe Drift am selben Wächter trägt
  (`emit.isRecurring` gegen `test/courseset-fixture.bats`). Der Satz läuft wieder vollständig:
  `make mutate` meldet `250 ok, 0 Befund(e)`, EXIT 0 über `ls test/mutations/*.sh | wc -l` → **250**
  Fälle (kein Erwartungswert,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die für diesen Slice geänderten Wächter — `ziel_ort` in
  `test/courseset-fixture.bats`, `isRecurring` in `internal/emit/templates.go` — tragen damit wieder
  gelistete Fälle, und keiner meldet Befund. Ein Träger außerhalb dieses Slice hat keinen
  Gegenstand. — **Ausgang: eingetreten, und die Realisierung ist in diesem Slice aufgefangen.**
  Weder Carveout noch Folge-Slice haben einen Gegenstand: der Satz läuft wieder vollständig, und
  die zwei umgezielten Fälle färben ihren Wächter selbst rot, bevor sie grün wurden. Was das
  Einzelne überlebt, ist die **Fall**-Hälfte — ein Mutations-Fall nennt eine Datei, die sein
  Wächter nicht liest —, und sie hat eine Kennung: `BEO-028` im
  Beobachtungs-Register, mit diesem Slice als zweitem Beleg.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Der Rollen-Schnitt hat den Slice getragen, und zwar messbar.** Vier
  Commits nennen ihre Rolle im Betreff, und keiner greift über sie hinaus (§6, Risiko 2). Genau
  diese Trennung hat die zwei schwersten Befunde erzeugt statt verdeckt: Ein frischer
  Reviewer-Kontext fand, dass das normative Artefakt dem Zustand widersprach, den derselbe Slice
  34 Minuten zuvor hergestellt hatte, und dass eine Teilersetzung vier Zeilen mitgenommen hatte —
  beides Befunde, die nur ein zweiter Kontext sieht. **Die vorab benannten Rückführungen aus §4
  haben nicht gegriffen**, und das ist die zweite Bestätigung: Der Verweis-Nachzug blieb eine
  mechanische Ersetzung, und `make full-smoke` wurde am neuen Baum nicht rot.
- **Was ging anders als geplant:** **Zweimal hat eine Zusage über ihren eigenen Gegenstand hinaus
  gegriffen — beide Male in der Bezugsmenge, nicht im Befund.** DoD 2 definiert seine Menge über
  ein Pfad-`grep`; die zwei lebenden Stellen, die den abgelösten Tag **ohne** Pfad-Segment führten
  (Beispielausgabe im Benutzerhandbuch, Baseline-Deklaration im Reviewer-Skill), liegen unter der
  Überschrift des Punktes und außerhalb seiner Menge. Und der `# files:`-Kopf zweier
  Mutations-Fälle wurde mit dem Baum gezogen, während derselbe Vorgang ihr Ziel entfernte: Der
  Treiber berechnet den Fingerabdruck **aller** Ziele vor dem ersten Fall, also fiel nicht ein
  Fall aus, sondern der ganze Satz — und die CI fährt ihn bei jedem Push. **Beide Klassen waren in
  §6 vorab benannt**; was fehlte, war nicht die Erwartung, sondern eine Menge, die sie einfängt.
- **Steering-Loop-Eintrag — benannte Spec-Lücke:** **Das Lastenheft entscheidet nicht, ob ein
  emittiertes Repo das Beobachtungs-Register bekommt.**
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) führt drei
  Klassen — Singleton, wiederkehrende Vorlage (*ADR · slice · welle · carveout · review-report*),
  derivative Index-Sicht — und dazu eine `.gitkeep`-Regel für leere Struktur-Verzeichnisse. Die
  **leere Ablage** des Registers fällt in keine davon: Sie ist keine Vorlage, kein Index, und
  `.gitkeep` trägt sie nicht, weil das Baseline-Regelwerk für sie ausdrücklich eine `README.md`
  verlangt (*„die leere Ablage **ist** die Aussage"*) — ein leeres Verzeichnis führt `git` nicht.
  Die Lücke ist gemessen, nicht behauptet: `grep -ci 'observation' spec/lastenheft.md` → **0**,
  `grep -ci 'Beobachtungs-Register' spec/lastenheft.md spec/spezifikation.md` → je **0**. Solange
  die Klasse nicht entschieden ist, ist auch nicht entscheidbar, ob der heutige Zustand ein Defekt
  oder die Absicht ist — und genau daran scheiterte die Träger-Suche in §6.
- **Beobachtungs-Register:** sieben Zeilen fortgeschrieben — **fünf Belege an bestehenden
  Kennungen und zwei neue Kennungen** (`grep -c '^| BEO-' ../observations.md` zählt die Zeilen des
  Registers, kein Erwartungswert). Dieser Slice ist **ein** Vorgang und zählt je Zeile einmal, auch
  wo mehrere Befunde dieselbe Zeile treffen. `BEO-009` (→ 11×, Stand **geplant**) für die drei Präsens-Aussagen gegen den
  gepinnten Stand und die Prosa-Zahl aus Risiko 1 · `BEO-015` (→ **3×**) für die Provenienz- und
  Inventur-Zahlen der Commit-Messages, die der Nachmessung nicht standhielten · `BEO-025` (→ 5×,
  Stand **geplant**) für die DoD-2-Zusage, die `docs-check` mehr belegen ließ als es prüft ·
  `BEO-028` (→ 2×) für den Mutations-Fall, der seinen Gegenstand verlor · `BEO-030` (→ **3×**),
  weil der Sichtungs-Schritt in §8 dieses Plans `BEO-025` mit 2× zitierte, während das Register
  4× trug · **`BEO-038` neu** (1×) für die emittierte Hälfte des Registers, Risiko 4 · **`BEO-039`
  neu** (1×) für den Ausgang, der eine Träger-Kennung nennt, deren DoD den Befund nicht adressiert.
  **Zwei Zeilen treten mit dieser Closure über die Schwelle** — `BEO-015` und `BEO-030` — und
  stehen bis dahin `offen`: Den Ausgang weist der **Lese-Schritt** zu, und der liegt in diesem Repo
  bei der Welle-Closure. Sie sind damit Pflicht-Posten für Schritt 3a der Closure von
  [welle-15](../welle-15-re-baseline.md), nicht für diese hier.
- **Folge-Slices: keine.** Alle drei offenen Posten haben eine Route, und keine davon ist eine neue
  Plan-Datei: die Prosa-Zahl in [`AGENTS.md`](../../../../AGENTS.md) §1 zählt unter `BEO-009`, die
  emittierte Register-Hälfte unter `BEO-038`, der falsche Träger im Kopf von
  `internal/emit/templates.go` unter `BEO-039`. Eine Kennung ohne Gegenstand zu vergeben wäre
  derselbe Fehler wie ein Ausgang ohne Träger, nur teurer.
- **Risiken aus §6:** fünf Risiken, fünf Ausgänge, jeder einer der drei — **weiter offen** →
  Register (Risiko 1 nach `BEO-009`, Risiko 4 nach `BEO-038`) · **entfallen** mit Begründung
  (Risiko 2: die Rollen-Trennung hat an allen vier Commits gehalten, gemessen; Risiko 3:
  `make full-smoke` ist gefahren, das Zeitfenster schließt mit dieser Closure) · **eingetreten**
  (Risiko 5: der Mutations-Satz lag still und ist in diesem Slice wieder vollständig). Der
  Wortlaut steht je Risiko in §6 und nicht hier zweimal.
- **Ein Posten geht an die Implementer-Rolle, offen und benannt:** Der Kopfkommentar von
  `internal/emit/templates.go` nennt für die fehlende emittierte Register-Ablage
  [slice-177](../in-progress/slice-177-beobachtungs-register-verzeichnis-form.md) als Ersatz-Träger
  (`grep -n 'slice-177' internal/emit/templates.go` → eine Zeile), während jener Slice die
  Emit-Ebene nicht führt
  (`grep -c 'internal/emit' docs/plan/planning/in-progress/slice-177-beobachtungs-register-verzeichnis-form.md`
  → **0**; keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Dieselbe Aussage,
  die in §6 dieses Plans korrigiert wurde, steht dort weiter — sie liegt in einer Code-Datei und
  damit außerhalb dessen, was ein Planner-Commit schreibt.
- **Verifikation, selbst gefahren statt zitiert:** `make gates` EXIT 0 —
  `baseline-verify: v6.0.0 OK — 53 Dateien`, `d-check: 605 Datei(en) geprüft, 0 Befund(e)`,
  `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`, `span-check` ok. `make full-smoke`
  EXIT 0 über alle Abschnitte (Arch-Gate, drittes Layout, Idempotenz, Rollen-Typen, Feldliste) —
  der Lauf, den DoD 4 neben `make gates` stellt, weil der Baum-Tausch von
  [welle-10](../done/welle-10-re-baseline.md) genau dort brach. Keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — die Dateizahlen wandern mit dem Baum.
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

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand. **Keine der vier
erreicht 3× erst durch ihn**, und eine steht schon darüber und trägt ihren Ausgang. Die Stände sind
am Register abgelesen und wandern mit jedem geschlossenen Slice — keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2; `grep -oE '^\| BEO-0(03|09|11|25) \|' docs/plan/planning/observations.md` findet die vier
Zeilen, der Stand steht in ihrer vierten Spalte). Welche
Zeilen die **Closure** über die Schwelle hebt, steht in §7: Der Sichtungs-Schritt liest, was vor
der Arbeit dasteht.

- `BEO-003` (5×, **verkörpert**) — *Verweise brechen beim Ortswechsel*. Steht als Risiko in §6.
- `BEO-009` (10×, **geplant**) — *eine Zusage neben der geänderten Ableitung bleibt stehen*. Steht
  als Risiko in §6, hier in der Commit-Zuschnitt-Form.
- `BEO-011` (1×) — *gesammelte Sprünge kosten überproportional*. Dieser Sprung wird zeitnah
  adoptiert; die Kostenreihe misst die Closure von [welle-15](../welle-15-re-baseline.md).
- `BEO-025` (4×, **geplant** in [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md))
  — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*. Bindet DoD 4:
  `make gates` sieht den Fall aus DoD 1 nicht vollständig, `make full-smoke` gehört dazu.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

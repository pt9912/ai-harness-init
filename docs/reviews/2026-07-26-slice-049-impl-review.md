# Review-Report: slice-049 — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** slice-049 Baseline-Re-Vendor v3.5.1 → v3.5.2 + CR-Regel-Entscheidung.
Range `80eec58..ce4b611` (zwei Commits: `9cfa1f3` reiner Lifecycle-Move, `ce4b611` Impl),
52 Dateien.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: [`slice-049-baseline-bump-v3.5.2.md`](../plan/planning/in-progress/slice-049-baseline-bump-v3.5.2.md) (§2 DoD als *Absichts*-Quelle, §3 Plan, §6 Risiken)
- aktive ADRs: keine im Diff geändert; mittelbar berührt `ADR-0003` (Docker-only). Immutabilitäts-Schutz geprüft für alle accepted ADRs (Hard Rule 3.4)
- berührte `LH-*`-IDs: `LH-QA-02` (Reproduzierbarkeit/Pins), `LH-QA-01` (keine halluzinierten Gates), `LH-QA-03` (minimale Abhängigkeiten) in [`spec/lastenheft.md`](../../spec/lastenheft.md)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6)
- Konventionen: [`harness/conventions.md`](../../harness/conventions.md) — `MR-007` (Setzungen 1–4), `MR-013` (Zwei-Pin-Kopplung), der neue `MR-015`
- vorherige Findings am gleichen Modul: [`2026-07-24-slice-043-review.md`](2026-07-24-slice-043-review.md) (Vorgänger-Re-Vendor v3.5.0→v3.5.1)

**Prüfumfang / Grenze:** der vendored Fremd-Baum `.harness/baseline/v3.5.2/**` ist
derivativer Upstream-Inhalt und d-check-ignoriert — geprüft wurde dort **das
Vendoring-Verfahren** (Provenienz, `SHA256SUMS`-Form, Setzung 4, Ziel-Form-Auflösung)
und der **Normativ-Delta**, nicht der Textinhalt der Module. Eigene Sensor-Läufe:
`make baseline-verify`, `make docs-check` (lesend). **Nicht** gefahren: `make mutate`,
`make test`, `make gates` (mutierende bzw. verifizierende Rolle läuft getrennt —
Steering-Loop-Lehre aus slice-043: zwei Rollen nie gleichzeitig auf demselben Baum).
Die Upstream-**Herkunft** des ZIP ist netzlos nicht nachprüfbar (siehe Negativbefunde).

---

## Findings

### F-1 — MR-015 Setzung 2: die zitierte Messung deckt die Setzung nicht

- `kategorie`: HIGH
- `quelle`: Hard Rule 3.6 (`AGENTS.md` §3.6, „Keine Zusage ohne rot gesehenes Gegenbeispiel") · `MR-015`
- `pfad`: `harness/conventions.md:676-683` (Setzung 2, Zeilen „Gemessen (2026-07-26)" / „Ein Commit berührte die Datei doch")
- `befund`: Setzung 2 erklärt als beobachtbares Merkmal, ein angenommener CR liege in
  einem **eigenen Commit, der ausschließlich `spec/lastenheft.md` ändert**, und nennt
  `git log -- spec/lastenheft.md` + `git show --stat` als das Verfahren, das die Frage
  nachträglich beantwortet. Führt man genau dieses Verfahren aus, widerspricht das
  Ergebnis der im selben Absatz behaupteten Messung: **16** Commits berühren
  `spec/lastenheft.md`, davon ändern nur **6** ausschließlich diese Datei
  (`5c4930b`, `9ce4721`, `af0d454`, `2c8227b`, `2879429`, `27628b5`); die übrigen **10**
  bündeln sie mit ADRs, Slice-Dateien, Roadmap, `AGENTS.md`, `.d-check.yml` oder
  `spec/architecture.md` (`d30db38` 21 Dateien, `c615da7` 15, `ec3af11` 9, `bc447fe` 7,
  `a0e74f1` 4, `43f1eda`/`65f4bcf` je 3, `beec837`/`4b0d0d5` je 2, `7b717f4` 11).
  Auch die Teil-Aussage „alle 13 CR-Zeilen stammen aus eigenen `spec:`/`plan:`-Commits"
  ist falsch: die Zeilen 0.1.0/0.2.0/0.3.0 stammen aus `d30db38` („Harness bootstrap: …"),
  `bc447fe` („Phase 1 Go-Pivot: …") und `a0e74f1` („Entscheidungs-Schritt: …") — keiner
  dieser Commits trägt ein `spec:`- oder `plan:`-Präfix.
- `verifizierbar`: ja — `git log --follow --format="%h %s" -- spec/lastenheft.md` plus
  `git show --stat` je Treffer; das ist derselbe Lauf, den `MR-015` selbst als
  Beweismittel benennt.

### F-2 — die als „einmalig" ausgewiesene Ausnahme ist nicht einmalig

- `kategorie`: MEDIUM
- `quelle`: Hard Rule 3.6 · `MR-015`
- `pfad`: `harness/conventions.md:681-686` („**Ein Commit berührte die Datei doch** (`7b717f4`, …) … darum gilt die Setzung **auch für rein redaktionelle** Änderungen")
- `befund`: `MR-015` führt `7b717f4` als **den** einen Commit, der `spec/lastenheft.md`
  außerhalb der CR-Entscheidung berührte, und leitet daraus die Ausweitung auf
  redaktionelle Änderungen ab. `c615da7` („Doc-Gate schärfen: matrix + link-policy:always
  + Anker-IDs", 15 Dateien inkl. `.d-check.yml`, `AGENTS.md`, drei ADRs, fünf
  Slice-Dateien) änderte in `spec/lastenheft.md` ausschließlich die Link-Form der
  Historien-Zeile 0.2.0 — dieselbe Klasse (rein redaktionell, in einen Inhalts-Commit
  gebündelt), die der Eintrag als Einzelfall darstellt. Die Aussage „Ein Commit … doch"
  quantifiziert damit die Ist-Lage zu niedrig.
- `verifizierbar`: ja — `git show c615da7 --stat` und `git show c615da7 -- spec/lastenheft.md`.

### F-3 — Move-Commit lässt zwei eingehende Roadmap-Links ins Leere zeigen

- `kategorie`: MEDIUM
- `quelle`: Hard Rule 3.1 („Jeder … Gate muss auf frischem Checkout laufen") · etablierte Repo-Praxis (`14e3455`, `ec16f77`) · Slice-Plan §5
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:22` und `:48` im Zustand von `9cfa1f3`
- `befund`: `9cfa1f3` verschiebt die Slice-Datei `open/ → in-progress/`, ohne die zwei
  Roadmap-Links `../open/slice-049-baseline-bump-v3.5.2.md` mitzuziehen — die Reparatur
  passiert erst im Inhalts-Commit `ce4b611`. Auf dem Checkout `9cfa1f3` existiert
  `docs/plan/planning/open/` nur noch mit `.gitkeep`, beide Links zeigen auf eine nicht
  existierende Datei. Die Repo-Praxis führt genau diesen Fall explizit
  (`14e3455`: „open -> in-progress … keine Inbound-Links zu ziehen";
  `ec16f77`/`08410bc`: „+ Inbound-Links im selben Commit"); hier gab es Inbound-Links,
  und sie blieben liegen. Hard Rule 3.3 verlangt die Trennung von Move und
  *Inhaltsänderung* — eine Link-Reparatur im Move-Commit ist nach dieser Praxis kein
  Verstoß dagegen, sondern der Normalfall.
- `verifizierbar`: ja — `git checkout 9cfa1f3 && make docs-check` (links-Modul) färbt rot;
  statisch bereits belegt durch `git ls-tree 9cfa1f3 docs/plan/planning/open/`.

### F-4 — Zählung „13 aktive Referenzen gezogen" trifft den Diff nicht

- `kategorie`: LOW
- `quelle`: `LH-QA-02` (Reproduzierbarkeit der Re-Baseline-Prozedur) · Maintainability
- `pfad`: Commit-Message `ce4b611` („Doc-Reconciliation: 13 aktive v3.5.1-Referenzen in 4 Dateien gezogen") · Slice-Plan §2/§3
- `befund`: Der Diff bewegt **11** Vorkommen, nicht 13:
  `harness/conventions.md` 5 von 6 (die Zeile „auf `v3.5.1`: 2026-07-24 (slice-043)"
  bleibt korrekt stehen), `.harness/skills/reviewer.md` 2 von 3 (der 1.3.0-Historieneintrag
  bleibt korrekt stehen), `docs/user/benutzerhandbuch.md` 3, `roadmap.md` 1. Die Zählung
  „13 gezogen" zählt zwei bewusst als **historisch** behaltene Vorkommen als gezogen mit;
  wer die Zahl beim nächsten Re-Vendor als Checkliste nimmt, zieht die
  Re-Baseline-Historie mit und löscht damit den Stand, den `MR-007` in
  `conventions.md` §Baseline führt.
- `verifizierbar`: ja — `git grep -c "v3\.5\.1" 80eec58` über die Nicht-`done/`-,
  Nicht-`docs/reviews/`-, Nicht-Baseline-Pfade gegen `git diff 80eec58..ce4b611`.

### F-5 — aktives Planungsdokument zeigt weiter auf den abgelösten Kurs-Tag

- `kategorie`: LOW
- `quelle`: `LH-QA-02` (Pin auf den Tag, „nicht `main`-floating") · `harness/conventions.md` §Adoptierte Konventions-Quellen
- `pfad`: `docs/plan/planning/in-progress/slice-049-baseline-bump-v3.5.2.md:6` und `:181`
- `befund`: Die beiden Kurs-URLs des **aktiven** (in-progress) Slice-Dokuments —
  Lifecycle-Definition (Modul 5) und Steering-Loop-Definition (Grundlagen/Klassifikation) —
  zeigen weiter auf `blob/v3.5.1/…`. Das sind normative Verweise auf die kanonische
  Quelle, keine historischen Bezüge; die gleichartige URL in `roadmap.md:7` (Kurs Modul 6)
  wurde im selben Commit auf `v3.5.2` gezogen. Nach dem Re-Vendor benennt
  `conventions.md` `v3.5.2` als kanonische Quelle, während ein aktives Dokument die
  Regel-Definition aus dem abgelösten Stand zitiert. (Der Plan erlaubt der Slice-Datei
  `v3.5.1` als *historischen* Bezug — die Ziel-Form-Verweise fallen nicht darunter.)
- `verifizierbar`: nein für `make docs-check` — externe URLs sind netzlos nicht
  d-check-gedeckt (Slice-Plan §6 benennt das selbst); nachweisbar per
  `git grep -n "blob/v3.5.1" -- docs/plan/planning/in-progress/`.

### F-6 — Geltungsbereich beansprucht AGENTS.md, ohne dort sichtbar zu sein

- `kategorie`: INFO
- `quelle`: Maintainability · `MR-015`
- `pfad`: `harness/conventions.md:643-644`
- `befund`: Der Geltungsbereich von `MR-015` nennt neben `spec/lastenheft.md` §7 auch
  „`AGENTS.md` §3.4/§3.5-Umfeld"; `AGENTS.md` ist im Diff unverändert und enthält keinen
  Hinweis auf die neue Commit-Disziplin. Die Setzung ist damit nur über die vollständige
  Lektüre von `harness/conventions.md` erreichbar (die `CLAUDE.md` allerdings verbindlich
  vorschreibt) — der Hard-Rule-Katalog selbst kennt sie nicht.
- `verifizierbar`: nein (kein Gate deckt Geltungsbereichs-Aussagen); belegbar per
  `git diff 80eec58..ce4b611 -- AGENTS.md` (leer).

---

## Negativbefunde

- geprüft, ohne Befund: **fünf gekoppelte Pins (`MR-007`/`MR-013`).** `BASELINE_TAG`=`v3.5.2`
  + `BASELINE_ZIP_SHA256`=`2af45aad…1925` ([`Makefile`](../../Makefile):26/35), `DefaultTag`=`v3.5.2`
  + `DefaultBaselineSHA256`=`2af45aad…1925` ([`internal/fetch/baseline.go`](../../internal/fetch/baseline.go):48/55),
  [`.d-check.yml`](../../.d-check.yml):72/73 `sources` url `…/v3.5.2/…` + sha256 `2af45aad…1925` —
  alle fünf identisch gezogen. Die Prädikate der Kopplungswächter (`sources-pin.bats`:
  `yml_sha == mk_sha`, `url` enthält `/$mk_tag/`) sind auf dem Ist-Stand statisch erfüllt.
- geprüft, ohne Befund: **`SHA256SUMS`-Form (`MR-007` Setzung 2).** 42 Zeilen, 42 Dateien im
  Baum, `SHA256SUMS` selbst **nicht** gelistet (`grep -c` = 0), nach Pfad `LC_ALL=C`-sortiert
  (`LC_ALL=C sort -k2 -c` grün), Pfade relativ zu `<tag>/` — formgleich mit dem
  Vorgänger-Baum `v3.5.1`. `make baseline-verify` selbst gefahren:
  `v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
- geprüft, ohne Befund: **Setzung 4 (ein Tag zur Zeit).** `.harness/baseline/` enthält
  ausschließlich `v3.5.2/`; der `v3.5.1`-Baum ist vollständig entfernt (git erkennt den
  Tausch als Rename+Modify, Stat zeigt `{v3.5.1 => v3.5.2}/…`).
- geprüft, ohne Befund: **Setzung 1 (Provenienz ≠ Integrität) — Verfahrens-Reihenfolge.**
  Der Pin `2af45aad…1925` ist identisch mit dem am 2026-07-25 zur Planungszeit gemessenen
  Wert (Slice-Plan §2/§3), die Commit-Message weist die Prüfung *vor* dem Entpacken aus.
  **Grenze:** die Herkunft des Baums aus genau diesem Asset ist netzlos nicht
  nachprüfbar (`make regelwerk-check` ist ein Netz-Sensor) — der Reviewer bestätigt die
  *Konsistenz* der Pin-Kette, nicht den Upstream-Fetch.
- geprüft, ohne Befund: **Hard Rule 3.4 (ADRs immutable).**
  `git diff 80eec58..ce4b611 -- docs/plan/adr/` ist leer; `ADR-0004`/`ADR-0005`/`ADR-0006`
  und alle übrigen accepted ADRs unangetastet, ihre `v3.5.x`-Historienbezüge stehen.
- geprüft, ohne Befund: **`spec/`-Unberührtheit.** `git diff 80eec58..ce4b611 -- spec/` ist
  leer — der Slice adoptiert die Regel „kein Slice ändert `LH-*`", ohne sie im Vollzug zu
  widerlegen. Kein `LH-*` geändert, keine Anforderung neu, `LH-QA-01`/`LH-QA-03` unberührt.
- geprüft, ohne Befund: **Hard Rule 3.3 (Move und Inhalt getrennt).** `9cfa1f3` ist ein
  reiner Move (0 Insertions/Deletions, Rename erkannt), `ce4b611` trägt den Inhalt.
  Die getrennte Link-Reparatur ist als F-3 gemeldet, nicht als 3.3-Verstoß.
- geprüft, ohne Befund: **Normativer Delta des vendored Baums.** Genau drei Dateien sind
  substanziell geändert — `regelwerk/README.md` (Stand Kurs-Welle 33 → 34 · 2026-07-24,
  in `conventions.md`:13 korrekt nachgezogen), `regelwerk/grundlagen-konventionen.md`
  (+12 Zeilen, der CR-Absatz) und `templates/spec/lastenheft.template.md` (+6 Zeilen
  Kommentar über `## 7. Historie`). Alle übrigen Änderungen sind `blob/v3.5.1/` →
  `blob/v3.5.2/`-URL-Bumps. Keine Kollision mit `AGENTS.md` §3 oder einem bestehenden
  `MR-*` außer der in `MR-015` behandelten CR-Achse.
- geprüft, ohne Befund: **`MR-015`-Zitat verbatim.** Der als „verbatim aus dem vendored
  Baum" ausgewiesene Block stimmt zeichengleich (nur Zeilenumbrüche normalisiert) mit
  `.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md:159-169` überein; die
  Fundstellen-Angabe „§Spec-Stratifizierung" trifft zu (Abschnitt 122–170). Keine
  Kondensierung, keine Paraphrase als Zitat ausgegeben.
- geprüft, ohne Befund: **`MR-015`-Durchsetzungs-Ehrlichkeit.** Der Eintrag behauptet
  **kein** Gate und **keinen** Sensor, sondern weist die Lücke explizit als „benannt,
  nicht geschlossen" aus und verweist sie auf die Roadmap — kein stilles Grün, kein
  halluziniertes Gate (`LH-QA-01`). Die Begründung „kein ADR nötig, weil Verschärfung"
  deckt sich mit `AGENTS.md` §3.5 (ADR-Pflicht nur für Senkungen) und `MR-001`.
  Der Befund F-1 betrifft die *Ist-Messung* im Eintrag, nicht diese Abgrenzung.
- geprüft, ohne Befund: **Doc-Reconciliation-Abdeckung.** Nach dem Commit verbleiben
  `v3.5.1`-Vorkommen ausschließlich in frozen `done/`-Slices, `docs/reviews/**`, der
  Slice-049-Datei (historischer Bezug — Ausnahme F-5 für die Ziel-Form-URLs), dem
  1.3.0-Historieneintrag in `reviewer.md` und der Re-Baseline-Historie in
  `conventions.md`:17. Keine übersehene aktive Referenz, keine fälschlich gebumpte
  Historie. Kein accepted ADR angefasst.
- geprüft, ohne Befund: **Ziel-Form-Auflösung im neuen Baum.** Alle 13 eindeutigen
  `../templates/…`-Verweise des `regelwerk/`-Baums lösen lokal auf (0 tote Ziele) — die
  Geschwister-Lage aus `MR-007`/`AGENTS.md` §1 trägt nach dem Tausch weiter.
- geprüft, ohne Befund: **`make docs-check` selbst gefahren:** `d-check: 181 Datei(en)
  geprüft, 0 Befund(e)` — deckt sich mit der Angabe in der Commit-Message; der neue
  `MR-015`-Anker (aus `roadmap.md` referenziert) löst auf.
- geprüft, ohne Befund: **`ADR-0003` (Docker-only) / `LH-QA-03`.** Der Diff führt keine
  Host-Toolchain, kein neues Werkzeug und keine neue Abhängigkeit ein; alle berührten
  Prüfungen laufen weiter über `make`-Targets in gepinnten Images.
- geprüft, ohne Befund: **Wiederkehr der slice-043-Findings.** Das dortige MEDIUM
  (nichtdeterministisch rotes `make test`) war laut Closure-Nachtrag ein
  Concurrency-Artefakt zweier gleichzeitiger Rollen und ist seit slice-047
  (`make mutate` gegen eine isolierte Kopie) gegenstandslos; das INFO
  (Aggregator-Ordnungskante) folgte aus derselben Ursache. Keine Wiederholung im
  vorliegenden Diff sichtbar; `make test` wurde rollenbedingt nicht gefahren.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 1 |

## Verdikt

**NICHT KONFORM. Merge-blockierend: ja** (F-1 HIGH, F-2/F-3 MEDIUM).

Das **Vendoring-Verfahren ist einwandfrei**: alle vier `MR-007`-Setzungen und die
`MR-013`-Zwei-Pin-Kopplung sind erfüllt, die fünf Pins sind identisch gezogen, der alte
Baum ist weg, `baseline-verify` und `docs-check` sind selbst grün gesehen,
`spec/lastenheft.md` und alle accepted ADRs sind unberührt, die Doc-Reconciliation ist
historien-treu. Wäre dies ein reiner Pin-Bump, lautete das Verdikt KONFORM.

Blockierend ist die **inhaltliche Achse des Slice**. `MR-015` ist als Setzung sauber
konstruiert und in seiner Durchsetzungs-Lücke ehrlich — aber der Beleg, auf dem
Setzung 2 ruht, hält der eigenen Messvorschrift nicht stand (F-1): das Kriterium
„eigener Commit, ausschließlich `spec/lastenheft.md`" erfüllen 6 von 16 Commits, nicht
alle; die als einmalig ausgewiesene Ausnahme ist mindestens zweimal vorhanden (F-2).
Damit trägt eine normative Setzung eine Ist-Aussage, die ihr eigenes benanntes Verfahren
widerlegt — genau die Klasse „Zusage weiter als Abdeckung" (`AGENTS.md` §3.6), gegen die
dieses Repo seine Hard Rule geschrieben hat. Der Befund trifft die Aussage, **nicht** die
Setzung: die Regel selbst bleibt für künftige Einträge unberührt tragfähig.

F-3 ist unabhängig davon merge-relevant, weil er einen Commit in der Historie hinterlässt,
dessen `make docs-check` rot ist.

**Übergabe:** Findings gehen an die Implementation (Rückkante Review → Plan bei
Plan-Defekt; hier kein Plan-Defekt — der Plan verlangt die Messung, die Umsetzung hat sie
überdehnt). Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der
Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Findings

Reihenfolge: Befund nachgemessen, **dann** reagiert. Keine Herabstufung „weil der
Implementer widerspricht" (Modul 8 §Konflikt-Pfad) — F-3 bekommt eine Beleg-gestützte
Antwort, keine Kategorie-Änderung.

- **F-1 (HIGH) — bestätigt, behoben.** Eigene Nachmessung reproduziert den Befund exakt:
  16 Commits berühren `spec/lastenheft.md`, **6** ändern sie allein, **10** bündeln sie.
  Die ursprüngliche Setzung-2-Aussage prüfte nur das **Commit-Präfix**, nicht die
  **Datei-Menge** — die eigene Messvorschrift also nicht ausgeführt. `MR-015` Setzung 2
  ist umgeschrieben: sie ist jetzt ausdrücklich eine **neue Disziplin ab diesem Eintrag**
  (mit Cutoff), nicht eine Beschreibung des Ist-Standes; die vollständige Klassifikation
  der 10 Bündel (7 Entscheidungs-Bündel mit dem tragenden ADR, 1 Initial-Bootstrap,
  2 rein redaktionell) steht im Eintrag. Der widerlegte Satz wird **benannt statt
  geglättet** — er ist eine Instanz der `AGENTS.md`-§3.6-Klasse.
- **F-2 (MEDIUM) — bestätigt, in F-1 aufgegangen.** `c615da7` änderte in
  `spec/lastenheft.md` real nur die Link-Form einer Historie-Zeile (Diff nachgelesen) und
  steht jetzt gleichrangig neben `7b717f4` als zweite redaktionelle Berührung.
- **F-3 (MEDIUM) — Substanz bestätigt, Präzedenz-Begründung widerlegt, Abhilfe abgelehnt
  mit Beleg.**
  1. *Substanz stimmt:* auf dem Checkout von `9cfa1f3` zeigen die beiden Roadmap-Links ins
     Leere.
  2. *Die zitierte Repo-Praxis trägt nicht:* `14e3455` sagt im Betreff ausdrücklich
     „keine Inbound-Links zu ziehen"; `ec16f77` behauptet „+ Inbound-Links im selben
     Commit", sein `--stat` zeigt aber **1 Datei / 0 Insertions** — die Praxis wurde nie
     ausgeübt, die Commit-Message überzeichnet. Es gibt im Repo **keine** adoptierte
     Konvention, die Zwischen-Commits gate-grün verlangt; `make gates` ist an den Handoff
     gebunden, CI an den gepushten Head.
  3. *Abhilfe wäre unverhältnismäßig:* beide Commits liegen bereits auf `origin/main`
     (Reflog: `update by push`). Die Reparatur wäre ein Force-Push auf den öffentlichen
     Default-Branch — eine nach außen wirkende, schwer umkehrbare Operation für einen
     Zwischenzustand, den kein Gate je auswertet. Sie ist keine Implementer-Entscheidung.
  4. *Wo der Befund hingehört:* die Roadmap führt „Lifecycle-Move-Konvention — eingehende
     Links gehören in den Move-Commit" bereits als Kandidat (Doku-/Sensor-Wartung,
     Achse 4). Dieser Befund ist dessen **zweite gemessene Instanz** und schärft seinen
     Trigger.
- **F-4 (LOW) — bestätigt, in die Closure-Notiz übernommen.** 13 **Vorkommen**, davon
  **11 gezogen** und 2 bewusst als historischer Bezug behalten. Die Commit-Message von
  `ce4b611` sagt „13 aktive Referenzen gezogen" — das ist zu weit; korrigiert hier, weil
  der Commit gepusht ist.
- **F-5 (LOW) — behoben.** Die beiden Definitions-Zitate im Slice-Dokument (Lifecycle,
  Steering Loop) zeigen jetzt auf `blob/v3.5.2/…`; die verbleibenden `v3.5.1`-Nennungen
  darin sind echte historische Bezüge (DoD-gedeckt).
- **INFO-1 — behoben.** Der `MR-015`-Geltungsbereich nennt `AGENTS.md` nicht mehr als
  berührt; er sagt jetzt ausdrücklich, dass die Setzung eine MR-Adaption und **keine**
  neue Hard Rule ist, und verweist die Katalog-Frage an den Slice, der den Sensor baut.

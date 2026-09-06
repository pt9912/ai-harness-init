# Review — slice-190: Der Bootstrap legt die Orte an, die seine eigenen emittierten Texte nennen

**Rolle:** Reviewer (Modul 8/10) · **Datum:** 2026-09-06 · **Runde:** 1

**Reviewer-Skill:** `.harness/skills/reviewer.md` v1.7.0 (Baseline `v6.0.0`,
`regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

---

## Eingangs-Kontext (die fünf Pflicht-Punkte + Slice-Plan)

- **Diff/Commit-Range:** `711d92cb..2cb06ad9` — vier Commits: `711d92cb` (reiner Move
  `next/ → in-progress/`), `962319c7` (Verweis-Nachzug, 3 eingehend), `079f172d` (Roadmap,
  Ruhe-Marker entfernt), `2cb06ad9` (Implementierung in `internal/emit/templates.go` und
  `internal/emit/templates_test.go`). Berührte Dateien:
  `git diff --name-only 711d92cb^..2cb06ad9 | wc -l` → **7**.
- **Betroffene `LH-*`:** `LH-FA-02` (zweiklassige Template-Ablage, Struktur-Verzeichnisse, Zusage
  *out-of-the-box gate-sicher*), `LH-FA-01` (Bootstrap), `LH-QA-01` (keine halluzinierten Gates),
  `LH-QA-02` (Reproduzierbarkeit).
- **Referenzierte aktive ADRs:** `ADR-0037` (bindend, `Accepted` seit 2026-09-06),
  `ADR-0007` (Idempotenz-Klassen), `ADR-0005` (vendored Template-Baum im Ziel),
  `ADR-0034` (Verzeichnis-Form des Registers). Mitgeprüft, weil der Range einen
  Lifecycle-Move trägt: `ADR-0030` (Festlegung 3 und 4), `ADR-0016` (Festlegung 4).
  Keine superseded ADR referenziert.
- **Hard Rules:** `AGENTS.md` §3.1, §3.3, §3.5, §3.6, §3.7, §3.9, §3.10, §3.11.
- **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-22-slice-028-emit-gate-sicher.md`
  F-1 (der `NeutralizeRoadmap`-Kommentar schrieb die Drift-Erkennung einem go-Test zu, der sie
  fixturebedingt nicht leistet — korrigiert auf *„real fängt es allein `make smoke`"*) und die dort
  zitierte Vorgeschichte slice-022b F-3 (*falsche `make smoke`-Zuschreibung im Test-Kommentar*).
  Diese Klasse kehrt in HIGH-1 wieder.
- **Slice-Plan:** `slice-190` (Repo-Ergänzung über die Baseline-Fünf hinaus).

**Nicht Gegenstand dieses Laufs:** die DoD-Abhakung. DoD (3) — die Vorher/Nachher-Messreihe
6 → 3 am frischen Ziel — prüft die Verifikation in getrenntem Kontext.

**Eigene Sensor-Läufe.** `git status` vor Beginn: sauberer Baum, 11 Commits vor `origin/main`.
Nach der Prüfung: `make gates` → EXIT 0; `make docs-check` → `895 Datei(en) geprüft, 0 Befund(e)`;
`make comment-claims` → `56 Datei(en) geprueft, 0 Befund(e)`;
`make baseline-verify` → `v6.0.0 OK — 53 Dateien`. **Keine Erwartungswerte** (`MR-025` Setzung 2).

---

## Findings

### HIGH-1 — Zwei Kommentare schreiben die Drift-Erkennung `make smoke` zu; `make smoke` kann sie nicht leisten

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (ein
  Kommentar beschreibt, was da ist), `LH-QA-01`
- **pfad:** `internal/emit/templates.go:501-503` und `internal/emit/templates.go:524-526`
- **befund:** Beide neuen Funktionen tragen den Satz *„Deckungs-Grenze wie bei
  `NeutralizeRoadmap`: Wortlaut-Drift im vendored Fremdtext faengt allein `make smoke` gegen den
  realen Satz, nicht dieser Test."* Bei `NeutralizeRoadmap` trägt der Satz, weil der dortige
  Defekt ein **gebrochener Markdown-Link** ist; das emittierte Doku-Gate fährt `links`. Die zwei
  neuen Defekte sind **Inline-Code-Pfade** — sie liest allein `codepaths`, und im emittierten
  Prüfbereich ist `codepaths` auskommentiert:
  `grep -n '^modules:' internal/emit/templates/d-check.yml` → `modules: [links, anchors]`, und
  `harness/tools/smoke.sh` Schritt 4 wertet genau den Exit dieses Laufs aus
  (`grep -n 'docs-check' harness/tools/smoke.sh`). Driftet der Wortlaut im vendored Baum, wird
  der `strings.ReplaceAll` beider Funktionen ein stiller No-op, und **kein** Sensor färbt rot —
  `make test` nicht (die Fixture trägt den alten Wortlaut), `make gates` nicht, `make smoke`
  nicht. `ADR-0037` §Fitness Function sagt dasselbe im Klartext: *„Die Deckung zwischen
  emittiertem Text und emittiertem Bestand hat ebenfalls keinen [Sensor]: Das Doku-Gate des Ziels
  fährt `codepaths` heute nicht"* — der Kommentar widerspricht der bindenden Entscheidung.
- **verifizierbar:** **nein** — kein Gate-Lauf dieses Repos bestätigt ihn, und das ist der Befund.
  Nachvollziehbar durch Lesen von `internal/emit/templates/d-check.yml` gegen
  `harness/tools/smoke.sh` Schritt 4. Ein reales Gegenbeispiel verlangte eine Wortlaut-Änderung im
  vendored Baum und fiele damit unter `MR-007`; es gehört auf eine Kopie außerhalb des Repos.
- **klasse:** Kommentar schreibt die Drift-Erkennung einem Sensor zu, der sie nicht leistet
- **Kontext-Eskalation:** dritte Instanz derselben Klasse an demselben Modul (slice-022b F-3,
  slice-028 F-1, hier). Nach §Kontext-Eskalation des Reviewer-Skills ein Steering-Loop-Signal —
  gemeldet, nicht nur notiert.

### HIGH-2 — Der (b)-Beleg im `structureGitkeeps`-Kommentar beschreibt den Stand vor der eigenen Änderung

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.7 (*„Falsch: ‚die frühere Fassung prüfte nur die Länge' — beschreibt
  abwesenden Text"*), `ADR-0037` Festlegung 1 Bedingung (b)
- **pfad:** `internal/emit/templates.go:413-417`
- **befund:** Der Kommentar belegt Bedingung (b) mit dem Satz, die `want`-Liste führe
  *„`harness/conventions.md` ohne ein zusaetzliches `harness/conventions/`"*. Derselbe Commit hat
  genau diesen Eintrag in dieselbe Liste geschrieben. Das Kommando, mit dem `ADR-0037` die
  Bedingung belegt, liefert heute die Gegenzahl:
  `sed -n '/^func TestTemplates_EmittierterBestandVollstaendig/,/^}/p' internal/emit/templates_test.go | grep -c 'harness/conventions/'`
  → **1** (die ADR nennt an dieser Stelle **0**). Der Kommentar steht damit im Indikativ über
  einen Zustand, den er selbst aufgehoben hat; wer (b) an ihm nachprüft, findet die Begründung
  des Eintrags durch ihre eigene Messung widerlegt. **Keine Erwartungswerte.**
- **verifizierbar:** **nein** — kein Modul des Doku-Gates liest Kommentar-Inhalte
  (`grep -n '^modules:' .d-check.yml`), und `make comment-claims` prüft nur, ob ein *genannter*
  Sensor existiert, nicht, worüber ein Kommentar spricht; es lief 56/0 grün.
- **klasse:** Zusage neben geänderter Ableitung bleibt stehen (registriert als
  `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`)

### HIGH-3 — Der Lifecycle-Move lief ohne die Vorab-Messung, die §3.11 und ADR-0030 Festlegung 4 verlangen; zwei eingefrorene Rollen-Reports wurden byte-geändert

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.11 Absatz 2, `ADR-0030` Festlegung 4 (`Accepted`, aktiv)
- **pfad:** `711d92cb` / `962319c7`; Rückstand in
  `docs/reviews/2026-09-06-adr-0037-konsistenz-review.md:47-48`
- **befund:** §3.11 verlangt: *„Vor einem vom Prozess vorgeschriebenen Ortswechsel — dem `git mv`
  des Lifecycle … — misst der bewegende Lauf über beide Adress-Formen … ob ein eingefrorenes
  Artefakt das bewegte als Pfad nennt … Findet er einen, gehört die Entscheidung vor den Move."*
  `ADR-0030` Festlegung 4 sagt dasselbe und benennt den Träger: *„der Lauf, der den Move plant"*.
  Der Move fand drei eingehende Verweise, zwei davon in nach §3.11 einfrierenden **Rollen-Reports**
  (`2026-09-06-adr-0037-konsistenz-review.md`, `2026-09-06-slice-123-history-range-guard-review.md`),
  und `slice-mv` hat sie beide byte-geändert. Kein Artefakt des Range hält eine Vorab-Messung oder
  eine Entscheidung fest; die Commit-Message ist die tool-erzeugte Standardzeile. Der Rückstand ist
  messbar: der Konsistenz-Report trägt jetzt den Link-Pfad `in-progress/` unmittelbar neben seiner
  eigenen Prosa *„(in `open/`)"* — Pfad und Satz derselben Zeile widersprechen sich, genau die
  Grenze, die `make slice-mv` selbst deklariert (*„es zieht Pfade nach, keine Zustandssätze"*).
  Für diese Datei ist es die **zweite** solche Änderung: `591420b3` hat sie beim
  `open → next`-Move schon einmal umgeschrieben
  (`git log --oneline -- docs/reviews/2026-09-06-adr-0037-konsistenz-review.md`).
- **Gegenrede, geprüft und nicht durchgreifend:** `harness/README.md` beschreibt das Umschreiben
  von `docs/reviews/**` durch `make slice-mv` als gewollt. Das ist Rang 9 der Source Precedence;
  §3.11 (Rang 8) und `ADR-0030` (Rang 4) stehen darüber, und keiner der beiden nimmt die
  Vorab-Messung zurück. Eine Entscheidung *„der Nachzug ist hier richtig"* wäre legitim — sie ist
  nur nirgends getroffen.
- **verifizierbar:** **nein** — `ADR-0030` §Konsequenzen stellt es selbst fest: *„Festlegung 4 hat
  heute keinen Sensor. Kein Modul des Doku-Gates liest Lifecycle-Reihenfolgen."*
- **klasse:** Vorgeschriebener Ortswechsel ohne Vorab-Entscheidung über eingefrorene Adressen
  (Nachbarklasse zu `BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`)

### MEDIUM-1 — Die zwei neuen Neutralisierungen haben keinen Fall in `test/mutations/`; die Präzedenz-Begründung ist widerlegt

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (*„gelistet heißt: wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"*)
- **pfad:** `internal/emit/templates.go:504` und `:527`; Gegenstück fehlt in `test/mutations/`
- **befund:** Der Emitter führt fünf Neutralisierungen, drei davon haben einen kuratierten Fall,
  die zwei neuen nicht:

  ```sh
  grep -ho 'Neutralize[A-Za-z]*' internal/emit/templates.go | sort -u | wc -l   # 5
  grep -ho 'Neutralize[A-Za-z]*' test/mutations/*.sh       | sort -u | wc -l   # 3
  ls test/mutations/*.sh | wc -l                                               # 259
  ```

  **Keine Erwartungswerte.** Die genannte Begründung — `NeutralizeRoadmap` habe ebenfalls keinen —
  ist am Bestand widerlegt: `test/mutations/29-roadmap-nicht-neutralisiert.sh` ist genau der Fall
  *„der `NeutralizeRoadmap`-Aufruf faellt weg"*, dazu `206` für `NeutralizePlaceholderLinks`,
  `208` für dessen zweiten Aufrufpunkt und `153` für `NeutralizeMakeClaims`. Der Bestand begründet
  in diesem Repo ohnehin nichts; hier sagt er zusätzlich das Gegenteil. Wirkung: `make mutate`
  meldet 259 Fälle grün, ohne die **Haltbarkeit** der zwei neuen Wächter je berührt zu haben.
- **verifizierbar:** **ja, aber nicht durch ein Rot** — die zwei Zählkommandos oben sind der
  Nachweis; kein Gate-Lauf färbt rot, und gerade das ist der Befund. Ein Gegenbeispiel ist das
  Entfernen eines der zwei `if rel == …`-Blöcke: `make test` wird rot, `make mutate` bliebe ohne
  eigenen Fall stumm über der Frage, ob es das tut.
- **klasse:** Neuer Wächter ohne kuratierten Mutations-Fall

### LOW-1 — Commit `079f172d` trägt `LH-FA-02` als Traceability-ID für eine Dogfood-Planungs-Zustandsänderung

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §5 / `harness/README.md` §Traceability (PRs/Commits nennen mindestens
  eine `LH-*`- oder `ADR-*`-ID)
- **pfad:** `079f172d` (Commit-Message, letzte Zeile)
- **befund:** Die ID ist gesetzt, trifft aber den falschen Vertrag. `LH-FA-02` regelt die
  zweiklassige Template-Ablage **des emittierten Ziels**; geändert wurde der Ruhe-Marker der
  Roadmap **dieses** Repos, also ein Planungs-Zustand des Dogfood. Der Slice-Plan zieht die Linie
  selbst (*„Ebene: emittiert, nicht Dogfood"*). Wer die Kette später über `LH-FA-02` aufrollt,
  bekommt einen Commit angezeigt, der mit dem emittierten Bestand nichts zu tun hat.
- **verifizierbar:** **nein** — kein Modul des Doku-Gates liest Commit-Messages
  (`grep -n '^modules:' .d-check.yml`).
- **klasse:** Traceability-ID benennt den falschen Vertrag

### LOW-2 — Der Slice-Plan §1 sagt „sechs Einträge" neben einem Kommando, das jetzt sieben liefert

- **kategorie:** LOW
- **quelle:** `MR-025` (eine Zahl steht neben dem Kommando, das sie liefert),
  `AGENTS.md` §3.10 (Übergabe statt Selbst-Korrektur)
- **pfad:** `slice-190` §1 (der Absatz *„Die feste Liste in `structureGitkeeps()` trägt heute
  sechs Einträge"* samt dem Kommando darunter)
- **befund:** `sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c '^\t\t"'`
  liefert seit `2cb06ad9` **7**; die Prosa daneben steht im Indikativ Präsens auf **6**. Der Plan
  ist ein lebendes Artefakt und wird bis zur Closure gelesen. **Ausdrücklich kein Auftrag an den
  Implementer:** der Plan gehört dem Planner, und §3.10 hält die ausführende Rolle von ihrem
  eigenen Abnahme-Umfeld fern — dies ist ein Übergabe-Posten für die Closure, kein Nacharbeits-
  Punkt in diesem Lauf.
- **verifizierbar:** **ja** — das im Plan selbst abgedruckte Kommando.
- **klasse:** Zusage neben geänderter Ableitung bleibt stehen

### INFO-1 — Der Lauf ist ein zweiter Beleg für `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`

- **kategorie:** INFO
- **quelle:** Beobachtungs-Register, `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`
- **pfad:** `079f172d`
- **befund:** Der `next → in-progress`-Move machte den vom Modul `planning` bewachten Ruhe-Marker
  falsch; der Ausgleichs-Schritt lief als Handarbeit, und welcher Schritt ihn trägt, schreibt nach
  wie vor kein Artefakt vor, das der bewegende Lauf liest — genau der Wortlaut der `state.md`
  dieses Eintrags (*„Der Sensor macht den Fehlschlag laut, er schreibt den Ausgleichs-Schritt aber
  nicht vor; kein Anweisungssatz und kein Werkzeug dieses Repos nennt ihn."*). Der Zähler steht
  heute bei
  `ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l`
  → **1**, Stand `offen`. **Kein Erwartungswert.** Ob daraus ein Beleg wird, entscheidet die
  Closure; hier steht die Beobachtung, nicht ihre Buchung.
- **verifizierbar:** **nein** — die Register-Paarung prüft Deckung, nicht das Urteil *ist das
  dieselbe Beobachtung*.
- **klasse:** Lifecycle-Move macht ein bewachtes Zustandsfeld falsch

### INFO-2 — Der gewählte Ausgang nimmt dem Adopter den Ort der Eintrags-Vorlage; die tag-tragende Alternative lag einen Parameter entfernt

- **kategorie:** INFO
- **quelle:** `slice-190` DoD (2) erste Option (*„den Pfad im emittierten Text auf den vendored Ort
  ausschreiben"*), `ADR-0005`
- **pfad:** `internal/emit/templates.go:483-493` (Kommentar und die zwei Konstanten)
- **befund:** Der Kommentar begründet die Wahl mit *„Der volle, tag-gebundene Pfad ist an dieser
  Stelle im Emitter nicht bekannt (kein Baseline-Tag als Parameter durchgereicht)"*. Das ist als
  Aussage über *diese Stelle* zutreffend und damit §3.7-konform. Es beschreibt aber eine Folge der
  gewählten Signatur, keine Grenze der Lage: der Aufrufer kennt den Tag
  (`grep -n 'tag := envOr' cmd/ai-harness-init/main.go`, und `emit.Templates` wird eine Zeile
  später mit `templatesDir(targetDir, tag)` gerufen), und das Ziel-Repo trägt die Vorlage real
  unter `.harness/baseline/<tag>/templates/harness/conventions/` (`ADR-0005`). Der emittierte Satz
  sagt dem Adopter nach der Neutralisierung nur noch, *dass* es eine Eintrags-Vorlage gibt, nicht
  mehr *wo*. DoD (2) lässt alle drei Ausgänge zu; der informative war erreichbar. Festgehalten,
  nicht beanstandet.
- **verifizierbar:** **nein** — eine Abwägung, kein Gate-Gegenstand.
- **klasse:** Emittierter Text verliert eine auflösbare Adresse zugunsten der Gate-Sicherheit

---

## Negativbefunde (geprüft, ohne Befund)

- **Der vendored Fremdtext ist unberührt (`MR-007`).**
  `git diff --stat 711d92cb^..2cb06ad9 -- .harness/baseline/` ist leer; die vollständige
  Datei-Liste des Range führt sieben Dateien, keine davon unter `.harness/baseline/`.
  `make baseline-verify` → `v6.0.0 OK — 53 Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
  Beide Ausgänge laufen emit-seitig, wie die Commit-Message zusagt. Kein Befund.
- **Beide Neutralisierungs-Konstanten treffen den realen vendored Satz heute byte-genau** — der
  Punkt, an dem HIGH-1 *heute* noch kein stilles Grün ist:
  ```sh
  tr '\n' '\r' < .harness/baseline/v6.0.0/templates/harness/conventions.template.md \
    | grep -c $'kopiert aus\r`harness/conventions/MR-NNN-titel.template.md` der vendored Baseline;'   # 1
  tr '\n' '\r' < .harness/baseline/v6.0.0/templates/docs/plan/planning/README.template.md \
    | grep -c $'sondern in ihr eigenes `docs/plan/carveouts/done/` (Baseline-Regelwerk'               # 1
  ```
  **Keine Erwartungswerte** — beide wandern mit dem vendored Baum, und genau das ist der Grund für
  HIGH-1. Kein Befund am heutigen Stand.
- **Der `d-check:ignore`-Marker steht in einer Lage, in der er wirkt.** `MR-027` verengt ihn in
  zwei Achsen: er unterdrückt nur in **echter HTML-Kommentar-Form** und **nicht** in Inline-Code
  eingeschlossen. `carveoutsDoneRefNew` setzt `<!-- d-check:ignore (…) -->` als echten Kommentar
  auf dieselbe Zeile wie den Inline-Code-Pfad, außerhalb der Backticks. Der Wortlaut der Klammer
  ist der, den `carveout.template.md` für denselben Ort selbst führt — die Form, die `ADR-0037`
  Festlegung 4 zitiert. Kein Befund.
- **`ADR-0037` Festlegung 1 Bedingung (a) und (c) für `harness/conventions` tragen.** (a) ist an
  zwei unbedingten Indikativ-Nennungen belegt — `grundlagen-harness-dateien.md`
  §Verzeichniskonvention und der **Rumpf** (nicht der Kommentarblock) von
  `conventions.template.md`, beide Baseline `v6.0.0`; die drei Nicht-Formen der Auswertungs-Regel
  (Modus-Zusatz · Ziel eines Vorgangs · Glosse) greifen an keiner von beiden. (c) trägt, weil der
  Träger ein leeres `.gitkeep` ist (`out[k] = []byte{}`) und damit keinen Link führen kann. Zu (b)
  siehe HIGH-2 — die *Sache* trifft zu (`git` führt kein leeres Verzeichnis), nur ihr abgedruckter
  Beleg nicht mehr. Kein Befund an der Entscheidung selbst.
- **`ADR-0037` Festlegung 4 ist eingehalten.** `docs/plan/carveouts/done` und
  `docs/plan/planning/observations` sind **nicht** in `structureGitkeeps()` gelandet; der
  Kopfkommentar nennt für beide den Grund, und für den zweiten den Träger-Unterschied
  (`README.md` statt `.gitkeep`, Festlegung 2). Der Slice hat den Register-Ort nicht vorgezogen.
  Kein Befund.
- **Die Rollen-Frage zum Ruhe-Marker: kein Befund.** §3.10 bindet den **Abschluss** und zählt ihn
  auf — Closure-Notiz, Risiko-Ausgänge, DoD-Häkchen, Beobachtungs-Register, Welle-Plan, `git mv`
  nach `done/`. Der Ruhe-Marker beim **Claim** steht in keinem dieser Posten. Baseline `v6.0.0`,
  `modul-05-planning-harness.md` §Trigger je Lifecycle-Übergang weist `next→in-progress`
  ausdrücklich dem Implementer zu und verlangt den Move auf dem Hauptzweig **vor** der Arbeit; die
  `state.md` von `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` nennt als Träger
  *„den Lauf, der den Move plant"*. Dazu die mechanische Klammer: das Modul `planning` färbt
  `docs-check` rot, sobald `in-progress/` einen Slice trägt und der Marker stehen bleibt — ohne
  den Nachzug erreicht der Implementer keinen grünen Gate. Die Asymmetrie zum Gegenstück
  (`7491b885` stellte den Marker bei der Closure als *Rolle Planner* zurück) ist damit sachlich
  begründet, auch wenn sie nirgends geschrieben steht; das ist INFO-1, kein Verstoß. Die
  Trace-ID des Commits ist LOW-1.
- **Der `slice-mv`-Nachzug in `slice-191` (`open/`) ist kein fremdes Rollen-Artefakt.** Der
  Verweis-Nachzug beim Ortswechsel ist als Mechanik verkörpert
  (`BEO-ALL/verweise-brechen-beim-ortswechsel`), ändert Pfade und keine Aussagen, und lief als
  eigener Commit getrennt vom Move (`AGENTS.md` §3.3). Kein Befund.
- **§3.3 (Move und Inhalt getrennt) ist eingehalten.** `711d92cb` ist ein reiner Move
  (`1 file changed, 0 insertions(+), 0 deletions(-)`), der Inhalts-Nachzug liegt in `962319c7`.
  Kein Befund.
- **Die zwei Wiring-Proben haben Zähne.** `TestTemplates_ConventionsTemplateRefGateSafe` und
  `TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe` prüfen die **Ausgabe-Eigenschaft** des
  emittierten Dokuments gegen eine Fixture, die den auslösenden Satz trägt — nicht ein
  Implementierungsdetail. Entfernt man den jeweiligen `if rel == …`-Block, färben sie rot. Das ist
  die Achse, die `AGENTS.md` §3.6 verlangt; die fehlende **Haltbarkeits**-Prüfung ist MEDIUM-1.
  Kein Befund an der Test-Konstruktion.
- **Keine zweite Fassung der Ziel-Liste.** `TemplateTargets()` leitet aus derselben
  `planTemplates()` ab; ein hinzugefügter Ort kann nicht in einer Liste stehen und in der anderen
  fehlen. Die drei `want`-Listen (`TestTemplates_Layout`,
  `TestTemplates_EmittierterBestandVollstaendig`, `TestTemplates_MinimalQuelle`) sind alle drei
  nachgezogen — der Mengen-Vergleich ist geschärft, nicht aufgeweicht (`ADR-0037` Folgepflicht 1).
  Kein Befund.
- **`structureGitkeeps()` bleibt tool-definiert und quell-unabhängig.** Der neue Eintrag steht in
  der festen Liste, nicht in einer Ableitung aus `src`; damit trägt ihn auch der sprachlose
  Bootstrap (`TestTemplates_MinimalQuelle`). Das ist die bestehende Klasse aller sechs
  Vorgänger-Einträge, keine neue Weiche. Kein Befund.
- **Kein Eintrag im Adaptions-Block fällig.** `ADR-0037` stellt Baseline-Konformität her, statt
  von ihr abzuweichen (`MR-000`); der Diff setzt keine Abweichung, die zu deklarieren wäre.
  Kein Befund.
- **§3.9 (Docker-only) eingehalten.** Alle Gate-Läufe des Diffs und dieses Reviews liefen über
  `make`-Ziele in gepinnten Images; keine Host-Toolchain in der Befehlsposition. Kein Befund.
- **Keine superseded ADR referenziert.** Die vier im Plan genannten ADRs stehen auf `Accepted`
  (`grep -m1 '^\*\*Status' docs/plan/adr/00{05,07,34,37}-*.md`). Kein Befund.
- **`make gates` grün, mit deckungsgleichem Baum-Stempel** — EXIT 0, `docs-check` 895/0,
  `comment-claims` 56/0, `baseline-verify` OK. Kein Befund. *(Die Gate-Bestätigung ist nicht
  Reviewer-Urteil, sondern Kontext für die Findings oben; DoD-Abhakung bleibt Verifikation.)*

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 3 | HIGH-1 (falsche Sensor-Zuschreibung, 3. Instanz der Klasse) · HIGH-2 ((b)-Beleg beschreibt den eigenen Vorzustand) · HIGH-3 (Move ohne §3.11-Vorab-Messung, zwei eingefrorene Reports geändert) |
| MEDIUM | 1 | MEDIUM-1 (zwei neue Wächter ohne Mutations-Fall; Präzedenz-Begründung widerlegt) |
| LOW | 2 | LOW-1 (Trace-ID trifft den falschen Vertrag) · LOW-2 (Plan §1 zählt 6, das Kommando 7) |
| INFO | 2 | INFO-1 (zweiter Beleg einer offenen Beobachtung) · INFO-2 (verlorene Adresse im emittierten Text) |

**Wiederkehrende Klassen für den Steering-Loop** (Speisung über die Slice-Closure §7 ins
Beobachtungs-Register — die Buchung entscheidet die Closure, nicht dieser Report):
*Kommentar schreibt die Drift-Erkennung einem Sensor zu, der sie nicht leistet* (3× an diesem
Modul) · *Zusage neben geänderter Ableitung bleibt stehen* (HIGH-2, LOW-2) ·
*Lifecycle-Move macht ein bewachtes Zustandsfeld falsch* (INFO-1).

---

## Verdikt

**NICHT KONFORM — Merge blockiert.** Drei HIGH und ein MEDIUM.

Die **Sache** des Slice ist tragfähig: `harness/conventions` erfüllt die drei Bedingungen aus
`ADR-0037` Festlegung 1, die zwei ausgeschlossenen Orte bleiben ausgeschlossen, der vendored Baum
ist unberührt, beide Ausgänge greifen am heutigen realen Satz byte-genau, und die Wiring-Proben
messen Ausgabe-Eigenschaften statt Implementierungsdetails. Blockierend sind nicht die
Entscheidungen, sondern **drei Aussagen und eine Lücke, die den Bestand belastbarer erscheinen
lassen, als er ist**: zwei Kommentare benennen einen Sensor, der die zugesagte Drift nicht sehen
kann (HIGH-1); ein Beleg im Code widerlegt sich mit dem eigenen Kommando (HIGH-2); ein
vorgeschriebener Ortswechsel lief ohne die Entscheidung, die §3.11 vor ihn setzt, und hat zwei
einfrierende Rollen-Reports angefasst (HIGH-3); und die zwei neuen Wächter stehen als einzige
ihrer Klasse ohne kuratierten Mutations-Fall, begründet mit einem Präzedenzfall, den der Bestand
widerlegt (MEDIUM-1).

**Kein Rollen-Konflikt festgestellt.** Kein HIGH steht gegen eine Position des Implementers, die
sich auf eine Quelle beruft; der Konflikt-Pfad aus Modul 8 wird damit nicht ausgelöst. Sollte
HIGH-3 bestritten werden, ist der Gegenstand eine Rang-Frage zwischen `harness/README.md` (Rang 9)
und §3.11 / `ADR-0030` (Rang 8 / Rang 4) — dann greift der Konflikt-Pfad mit dem Architect als
Adressat, nicht eine Herabstufung dieses Befundes.

**Übergaben aus diesem Report** (Reviewer → Implementer, soweit nicht anders vermerkt):
HIGH-1, HIGH-2 und MEDIUM-1 liegen im Implementations-Kontext. HIGH-3 ist eine Entscheidung über
einen bereits vollzogenen Move und gehört als Übergabe an den Planner, zusammen mit LOW-2 (der
Plan gehört ihm, `AGENTS.md` §3.10) und INFO-1 (Register-Buchung bei der Closure). LOW-1 ist
in `git` festgeschrieben und nicht mehr korrigierbar; er steht hier als Klasse, nicht als Auftrag.

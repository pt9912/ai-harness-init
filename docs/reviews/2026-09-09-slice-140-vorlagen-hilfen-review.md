# Review-Report — slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr

**Rolle:** Reviewer · **Datum:** 2026-09-09 · **Runde:** 1

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `e184d996^..fdcb2762` — vier Commits: `e184d996` (reiner `git mv`
  `next/` → `in-progress/`, 0 Insertions), `ad7cde01` (`slice-mv`-Verweis-Nachzug),
  `1d7cd066` (präfixlose Geschwister-Referenzen + Ruhe-Marker) und `fdcb2762` (die Umsetzung:
  `internal/emit/templates.go`, `internal/emit/readme.go`, `internal/emit/templates_test.go`,
  `test/mutations/291-strip-comment-hints-nicht-verdrahtet.sh`).
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der Satz, an
  dem der Slice hängt — Singletons werden zu gestempelten `.md`-Zielen),
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
  `ANPASSEN`-Marker, die *nicht* fallen dürfen),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (der vendored Baum reist
  unverändert mit),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
  Zusage über einen Sensor, der sie nicht trägt),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte aktive ADRs:** [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md)
  (`Accepted`, im Slice-Kopf als Bezug geführt),
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (`Accepted`,
  Festlegung 3 und 4 — für den Verweis-Nachzug in `docs/reviews/**` und `done/**`).
- **Aktive `MR-*`:** [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  (der Vorlagen-Satz gehört dem Kurs — geändert wird das Emit),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  (fail-closed für emittierte Prüfbereiche),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.1, §3.3, §3.6, §3.7, §3.9,
  §3.10, §3.11.
- **Vorherige Findings am gleichen Modul:**
  [2026-09-08 · slice-201](2026-09-08-slice-201-codepaths-vendored-baum-review.md) und
  [2026-09-06 · slice-190](2026-09-06-slice-190-bootstrap-orte-review.md) (beide berühren
  `internal/emit/`). Aus slice-190 wiederholt sich hier die Klasse *„Kommentar schreibt die
  Drift-Erkennung einem Sensor zu, der sie nicht leistet"* — unten HIGH-2.
- **Slice-Plan (Repo-Ergänzung):** `slice-140`, gelesen in `in-progress/`; §7 ist unberührt
  (`Erst nach Abschluss füllen.`), §6 trägt vier Risiken ohne Ausgang — beides korrekt, der
  Abschluss ist Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zustand des Baums vor dem Lauf:** `git status --porcelain` leer. `HEAD` (`fdcb2762`) steht
**vor** `origin/main` (`2a2ceafd`) — die Arbeit ist noch nicht gepusht; das ist kein Befund,
sondern der erwartete Zustand vor dem Review.

**Instrumente dieses Laufs.** Docker-only ([`AGENTS.md`](../../AGENTS.md) §3.9): `make host-bin`,
`make test-go`, `make comment-claims` sowie der in `d-check.mk` gepinnte d-check-Digest
`sha256:e31a372b…` (`v0.74.1`) mit `--network none`. Dazu **ein realer Emit-Lauf** des gebauten
Trägers gegen ein frisches `git init`-Repo außerhalb des Arbeitsbaums, mit echtem Netz-Bezug der
`v6.5.0`-Baseline. Alle Mutationen liefen in **Kopien außerhalb** des Repos; der Arbeitsbaum ist
nicht angefasst worden.

**Nachgemessen, bevor geurteilt wurde.** Der Kern-Nachweis des Slice reproduziert. Über dem real
emittierten Baum `$P`:

```sh
find "$P" -name '*.md' -not -path '*/.git/*' -not -path '*/.harness/baseline/*' -print0 \
  | xargs -0 grep -n '<!--' | grep -v 'd-check:ignore' > /tmp/rest.txt
grep -vc '/\.claude/' /tmp/rest.txt   # 0   -- die Regel greift
grep -c  '/\.claude/' /tmp/rest.txt   # 10  -- die ANPASSEN-Marker bleiben unberuehrt
diff -rq "$P/.harness/baseline/v6.5.0/templates" .harness/baseline/v6.5.0/templates  # identisch
```

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl unten wandert mit dem Vorlagen-Satz.

## Findings

### HIGH-1 — Die `RootReadme()`-Hälfte des neuen Wächters kann nicht rot werden

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„erst fertig, wenn benannt ist, was passieren
  müsste, damit sie bricht, und das einmal rot gesehen wurde"*); Reviewer-Skill-Anker
  *Stilles-Grün-Pfad in einem Gate*
- **pfad:** `internal/emit/templates_test.go:591-592` und `:87` · `internal/emit/templates.go:805-807`
- **befund:** Der Test-Doc-Kommentar sagt, der Wächter messe *„gegen den GESAMTEN emittierten Satz
  (Templates() + RootReadme())"*, und der Doc-Kommentar an `StripCommentHints` nennt *„die
  Verdrahtung in planTemplates/RootReadme"*; die Commit-Message von `fdcb2762` wiederholt es. Die
  Fixture trägt für die `RootReadme`-Hälfte aber keinen Eingang, an dem sie fallen könnte:
  `courseSet()` legt `project-readme.template.md` als `hint + body + spitz` an, und keiner dieser
  drei Bausteine enthält ein `<!--`; ergänzt wird im Test allein
  `spec/lastenheft.template.md`. Die Selbst-Wächter des Tests (`inQuelle == 0`, `dokumente == 0`)
  zählen über den **ganzen** Satz und sind von der lastenheft-Ergänzung bereits befriedigt. Real
  gemessen: entfernt man die Verdrahtung aus `internal/emit/readme.go:44` und lässt
  `planTemplates` unberührt, meldet **die gesamte Go-Suite `ok`, Exit 0**. Die Gegenprobe
  validiert die Methode — `test/mutations/291-strip-comment-hints-nicht-verdrahtet.sh` (der die
  `templates.go`-Verdrahtung trifft) färbt denselben Test rot
  (`--- FAIL: TestTemplates_KeineKommentarHilfenImEmittiertenSatz`). Ein Lauf, der die
  `readme.go`-Verdrahtung verliert, schickt jedem Adopter wieder fünf Kommentar-Hilfen in sein
  Root-`README.md`, ohne dass ein Sensor es sagt.
- **verifizierbar:** ja — `make test-go` über einer Kopie, in der `internal/emit/readme.go:44` auf
  `body := stampName(StripHintBlock(string(content)), name)` zurückgesetzt ist: alle acht Pakete
  `ok`, Exit 0.
- **klasse:** `Waechter-Haelfte-ohne-rot-faerbbaren-Eingang`

### HIGH-2 — Der Doc-Kommentar schreibt `make smoke` eine Deckung zu, die er nicht leistet

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (das Falsch-Beispiel steht dort wörtlich:
  *„Byte-Gleichheit belegt `make smoke`", ohne `smoke` gelesen zu haben*);
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `internal/emit/templates.go:808-809`
- **befund:** Der Kommentar sagt über den realen vendored Satz: *„ob die Regel dort greift, misst
  allein `make smoke`, ausserhalb von `make gates`"*. `harness/tools/smoke.sh` prüft in seinen
  fünf Schritten kein einziges Mal auf Kommentar-Hilfen; seine einzige Inhalts-Aussage ist
  Schritt 4 — *emittiertes `docs-check` meldet 0 Befunde* —, und die emittierte `.d-check.yml`
  fährt `modules: [links, anchors]`, kein `codepaths`. Real gemessen: schreibt man eine echte
  Kommentar-Hilfe des vendored Satzes in die emittierte `harness/README.md` zurück, meldet das
  emittierte `docs-check` `19 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — `make smoke` bliebe also
  grün, während Schritt 5 der Kopier-Prozedur unvollzogen ist. Das ist kein Grenzfall: vor
  `fdcb2762` war die Regel gar nicht verdrahtet, und `make smoke` war grün. Der unmittelbar
  darüber stehende Nachbar-Kommentar (`internal/emit/templates.go:727-732`) macht es richtig und
  ist der Maßstab, gegen den dieser abfällt: er sagt *„Ob diese Regel einen realen Link ERREICHT,
  misst dagegen kein Gate"* und begründet den `smoke`-Verweis über den Befund, den `docs-check`
  dort wirklich wirft. `make comment-claims` fängt das nicht und sagt das selbst
  (`harness/tools/comment-claims.sh` Kopf: *„Ob der genannte Sensor die Behauptung inhaltlich
  TRAEGT. Das bleibt Review-Arbeit."*) — der Gate meldet `57 Datei(en) geprueft, 0 Befund(e)`.
- **verifizierbar:** ja — `make -f d-check.mk docs-check` im emittierten Probe-Repo mit
  zurückgeschriebener Kommentar-Hilfe: `0 Befund(e)`, Exit 0.
- **klasse:** `Kommentar-schreibt-Deckung-einem-Sensor-zu-der-sie-nicht-leistet`

### HIGH-3 — `StripCommentHints` löscht das Zitat der Kommentar-Syntax und entwertet ein emittiertes Norm-Artefakt

- **kategorie:** HIGH
- **quelle:** [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3);
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed);
  Slice-Plan §6 Risiko 1 und §4 Rückführung `in-progress → open`
- **pfad:** `internal/emit/templates.go:789` (`commentHintPattern`) — Wirkung am emittierten
  `.harness/skills/reviewer.md:30`
- **befund:** Das Muster kennt keinen Unterschied zwischen einer Kommentar-**Hilfe** und einem
  Inline-Code-**Zitat** der Kommentar-Syntax. Im realen Satz trifft es genau eines, und zwar das
  am schlechtesten entbehrliche: `.harness/baseline/v6.5.0/templates/.harness/skills/reviewer.template.md:42`
  führt den HIGH-Anker *„**Norm nur im Template-Kommentar** — eine Regel steht im `<!-- -->`-Block
  eines `.template.md`"*. Im real emittierten Baum steht dort:
  *„eine Regel steht im ``-Block eines `.template.md`"* — der Anker sagt nicht mehr, um welchen
  Block es geht. Betroffen ist die Skill-Datei, über die Modul 8 die Reviewer-Rolle überhaupt
  führt (§Welche Rolle braucht welche Artefaktklasse), im emittierten Repo also die
  Urteilsgrundlage jedes Adopter-Reviews. Der Slice-Plan hat den Fall vorab benannt — §6 Risiko 1
  *„Ein HTML-Kommentar kann tragenden Inhalt halten"* mit der Bezugsmenge *„jede Fundstelle des
  Kommandos einzeln geprüft"* und der Rückführung `in-progress → open` in §4 —; die Durchsicht hat
  ihn nicht getroffen. Kein Sensor kann ihn treffen: DoD (1) und
  `TestTemplates_KeineKommentarHilfenImEmittiertenSatz` zählen, was **weg** ist, nie was
  **beschädigt** wurde, und beide sind grün.
- **verifizierbar:** ja —
  `grep -n 'Norm nur im Template-Kommentar' -A 1 "$P/.harness/skills/reviewer.md"` gegen dieselbe
  Zeile in `.harness/baseline/v6.5.0/templates/.harness/skills/reviewer.template.md`; zusätzlich
  `grep -rn '``[^`]' "$P" --include='*.md'`, das die leere Inline-Code-Spanne ausweist.
- **klasse:** `Emit-Regel-trifft-das-Zitat-ihres-eigenen-Gegenstands`

### MEDIUM-1 — Die neue öffentliche Funktion nennt keine ihrer Grenzen

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Grenze*);
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed);
  Reviewer-Skill-Anker *fehlende Negativtests bei neuem öffentlichem Vertrag*
- **pfad:** `internal/emit/templates.go:785-809`; `internal/emit/templates_test.go:562-580`
- **befund:** `StripHintBlock` unmittelbar darunter (`:755-760`) nennt seine Annahme ausdrücklich
  (*„Annahme (Review-L1): der Hinweis ist ein eigenstaendiger, blank-getrennter Blockquote (so in
  allen 10 Singletons)"*), und `NeutralizePlaceholderLinks` darüber führt vier nummerierte
  Grenzen. `StripCommentHints` führt keine, obwohl zwei messbar bestehen. Erstens das
  Inline-Code-Zitat (HIGH-3). Zweitens die **Code-Fence-Blindheit**: das Muster kennt keinen
  Markdown-Kontext, und zwei emittierte Vorlagen tragen mehr Schließungen als Öffnungen, weil
  Mermaid-Pfeile dieselbe Zeichenfolge führen —
  `docs/plan/planning/roadmap.template.md` (öffnend 3, schließend 7) und
  `spec/architecture.template.md` (öffnend 5, schließend 14). Heute geht das gut, und das ist
  gemessen, nicht gehofft: in beiden Dateien schließt jeder Kommentar vor dem nächsten Pfeil, die
  emittierten Diagramme sind unversehrt. Es ist aber eine Eigenschaft des heutigen Upstream-Textes,
  nicht des Emitters — schöbe der Kurs einen Kommentar vor einen Diagramm-Block, fräße der
  non-greedy Abschluss den Diagramm-Anfang und ließe den Kommentar-Rest als sichtbaren Text
  stehen. `TestStripCommentHints` prüft drei Fälle (einzeilig, mehrzeilig, `d-check:ignore`) und
  keine der beiden Formen.
- **verifizierbar:** ja — je Vorlage
  `grep -o '<!--' <datei> | wc -l` gegen `grep -o -- '-->' <datei> | wc -l`.
- **klasse:** `Neue-oeffentliche-Funktion-ohne-benannte-Grenze`

### LOW-1 — Die `d-check:ignore`-Ausnahme greift auf Substring, nicht auf Marker-Form

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `internal/emit/templates.go:795` und `:813`
- **befund:** `strings.Contains(m, "d-check:ignore")` lässt **jeden** Kommentar stehen, der die
  Zeichenkette irgendwo trägt — auch einen mehrzeiligen Bedienhinweis, der die Ausnahme nur
  *erklärt*. Heute tritt der Fall nicht ein: von den 96 Kommentar-Blöcken des vendored Satzes
  tragen 7 die Zeichenkette, und alle 7 sind echte Marker der Form
  `<!-- d-check:ignore (Grund) -->`. Die Form existiert im Satz aber bereits als Zitat —
  `.harness/baseline/v6.5.0/templates/README.md:71` führt `` `<!-- d-check:ignore … -->` `` als
  Inline-Code im Prozedur-Text; die Datei wird heute nicht emittiert (Set-Index), sonst stünde
  dort ein lebender Kommentar im Ziel. Der Doc-Kommentar an `dcheckIgnoreMarker` beschreibt das
  Verhalten korrekt (*„ein Kommentar, der sie traegt, bleibt stehen"*); der an
  `StripCommentHints` (`:801`) spricht dagegen von *„ein `<!-- d-check:ignore … -->`-Marker"* und
  legt eine Form-Erkennung nahe, die es nicht gibt.
- **verifizierbar:** ja — alle Kommentar-Blöcke des Satzes extrahieren und die
  `d-check:ignore`-tragenden gegen die Marker-Form halten.
- **klasse:** `Ausnahme-auf-Substring-statt-auf-Form`

### LOW-2 — Kein Mutations-Fall nennt `internal/emit/readme.go`

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"*); Beobachtung
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (Stand `offen`)
- **pfad:** `test/mutations/291-strip-comment-hints-nicht-verdrahtet.sh:2`
- **befund:** Die `files:`-Zeile des einzigen neuen Falls nennt allein
  `internal/emit/templates.go`; die zweite, gleichrangige Verdrahtung in
  `internal/emit/readme.go:44` hat keinen. Ein Lauf, der sie entfernt, meldet in `make mutate`
  nichts — dieselbe Stelle, an der HIGH-1 den Wächter selbst zahnlos misst. Die beiden Befunde
  hängen zusammen: solange die Fixture für `project-readme.template.md` keinen Kommentar trägt,
  hätte auch ein Fall dort nichts, dessen Rot er erwarten könnte.
- **verifizierbar:** ja — `grep '^# files:' test/mutations/*.sh | grep readme.go` (leer).
- **klasse:** `Zweite-Verdrahtung-ohne-eigenen-Mutations-Fall`

### INFO-1 — Die Bedingung der §4-Rückführung ist eingetreten

- **kategorie:** INFO
- **quelle:** Slice-Plan §4 (`in-progress → open`), §6 Risiko 1
- **pfad:** `docs/plan/planning/done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md`
- **befund:** §4 benennt die Rückführung *„wenn ein entfernter Kommentar tragenden Inhalt hält,
  der nirgendwo sonst steht"*, und §6 Risiko 1 stellt dieselbe Frage mit der Bezugsmenge des
  §1-Kommandos. HIGH-3 ist genau dieser Fall, gemessen am realen Satz. Notiert wird hier nur, dass
  die Bedingung erfüllt ist — welcher der drei Ausgänge das Risiko bekommt und ob der Slice
  zurückgeht, entscheidet die Closure, und die ist Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10).
- **verifizierbar:** nein (Plan-Auslegung, kein Gate-Gegenstand).
- **klasse:** `Vorab-benannte-Rueckfuehrungs-Bedingung-eingetreten`

### INFO-2 — Zwei offene Beobachtungen haben einen weiteren Beleg bekommen

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.11; Baseline-Regelwerk `modul-06-roadmap.md`
  §Das Beobachtungs-Register
- **pfad:** `ad7cde01` und `1d7cd066`
- **befund:** `ad7cde01` (`slice-mv`) hat den Verweis auf slice-140 in
  `docs/reviews/2026-08-30-slice-130-verify.md` — einem Rollen-Report und damit einem nach
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3
  einfrierenden Artefakt — sowie in `docs/plan/planning/done/slice-130-…` umgeschrieben. Das ist
  die dokumentierte Wirkungsweise des vorgeschriebenen Werkzeugs und kein Fehlgriff des Laufs; es
  ist der **7.** Beleg von
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  (Stand `offen`, dessen `state.md` die Auflösung ausdrücklich dem Architect zuweist). `1d7cd066`
  hat den Ruhe-Marker der Roadmap gezogen — der **8.** Beleg von
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  (Stand `offen`). Beide Zahlen sind `ls …/evidence/ | wc -l` **vor** diesem Lauf plus eins und
  keine Erwartungswerte. Ob dieser Slice die Belege schreibt, entscheidet die Closure.
- **verifizierbar:** nein (Register-Zuordnung ist Closure-Arbeit).
- **klasse:** `Weiterer-Beleg-einer-offenen-Beobachtung`

## Negativbefunde (geprüft, ohne Befund)

- **Kern-Zusage des Slice.** Über dem real emittierten Baum fällt die Kommentar-Hilfen-Zahl
  außerhalb `.claude/` auf **0**, bei unveränderten **10** darunter. Die Regel greift am realen
  vendored Satz, nicht nur an der Fixture.
- **[`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) —
  `ANPASSEN`-Marker unberührt.** Alle neun Dateien unter `.claude/` tragen ihre Marker
  unverändert; `StripCommentHints` läuft nur in `planTemplates` und `RootReadme`, und beide lesen
  den vendored Satz, nicht `internal/emit/templates/`.
- **Die Herkunfts-Trennung hängt *nicht* am Pfad-Präfix.** Das Risiko aus §6 (*„Der Wächter muss
  an der Quelle unterscheiden, nicht am Zielpfad"*) ist in der Umsetzung vermieden: die
  Unterscheidung liegt am Emit-Pfad. Ein neues Dokument aus `internal/emit/templates/` außerhalb
  von `.claude/` bliebe korrekt verschont.
- **[`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) /
  [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) —
  der vendored Baum ist unverändert.** `diff -rq` zwischen dem mitemittierten
  `.harness/baseline/v6.5.0/templates` und dem des Repos: identisch. Der Diff des Range berührt
  keine Datei unter `.harness/baseline/`.
- **Ist `RootReadme()` durch den Plan gedeckt?** Ja — keine Bereichs-Erweiterung. DoD (1) misst
  *„kein emittiertes Dokument aus dem vendored Satz"* über den **ganzen** Baum (`find "$P" -name
  '*.md'`), und `project-readme.template.md` trägt fünf Kommentar-Blöcke. Ohne die Verdrahtung in
  `readme.go` wäre DoD (1) rot. Die §3-Tabelle nennt zwar nur `internal/emit/templates.go`, aber
  sie führt daneben `internal/emit/` auf Paket-Granularität; Schicht-Zahl und Liefer-Punkte
  (Modul 5 §Ziel-Form: Slice) bleiben unverändert. Die Sache selbst ist trotzdem nicht sauber
  abgedeckt — das ist HIGH-1, nicht eine Umfangs-Frage.
- **Rollen-Grenze von `1d7cd066`.** Rein mechanische Nacharbeit des Lifecycle-Moves, nichts
  Inhaltliches. Die zwei Pfad-Korrekturen in `next/slice-073` und `next/slice-174` sind exakt die
  von `harness/README.md` dokumentierte dritte Grenze von `make slice-mv` (präfixlose Referenz aus
  einer anderen, unbewegten Datei). Der Ruhe-Marker musste fallen, weil das `planning`-Modul der
  `.d-check.yml` ihn gegen `in-progress/` hält; Träger ist nach dem `state.md` der einschlägigen
  Beobachtung *„der Lauf, der den Move plant"*, und den `next → in-progress`-Move führt nach
  Modul 5 der Implementer. Kein Rollen-Verstoß.
- **[`AGENTS.md`](../../AGENTS.md) §3.3 — Move und Inhalt getrennt.** `e184d996` ist ein reiner
  `git mv` (0 Insertions, 0 Deletions), der Nachzug liegt in `ad7cde01`. Korrekt.
- **[`AGENTS.md`](../../AGENTS.md) §3.8 / §3.10 — keine fremden Rollen-Artefakte.** Der Range
  berührt weder `AGENTS.md` noch `harness/conventions.md` noch `docs/plan/adr/`; §7 des Slice-Plans
  ist unverändert, keine DoD-Häkchen gesetzt, kein `git mv` nach `done/`.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only.** Kein Host-Toolchain-Aufruf im Diff; die
  neuen Ziele laufen über `make`.
- **Traceability.** `fdcb2762` nennt `LH-FA-02`, `1d7cd066` nennt `LH-FA-01`. Beide auflösbar.
- **`make comment-claims`.** Grün (`57 Datei(en) geprueft, 0 Befund(e)`) — jeder in den neuen
  Kommentaren genannte Sensor existiert. Dass einer inhaltlich nicht trägt, ist HIGH-2 und liegt
  laut Skript-Kopf ausdrücklich außerhalb dieses Gates.
- **Kein Schaden an den Mermaid-Diagrammen.** Die emittierten `roadmap.md` und `architecture.md`
  tragen ihre Pfeile vollständig; die Fence-Blindheit bleibt eine benannte Grenze (MEDIUM-1), kein
  eingetretener Defekt.
- **Der übrige entfernte Bestand ist korrekt entfernt.** Alle übrigen Kommentar-Blöcke der elf
  emittierten Dokumente sind Autoren-Hinweise; keiner hält Inhalt, den der Adopter braucht. Eine
  Vorlage sagt es selbst (`harness/conventions.template.md`: *„Die Bedingung … steht oben im
  Fliesstext, weil dieser Kommentar beim Kopieren wegfaellt"*).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 3 | `Waechter-Haelfte-ohne-rot-faerbbaren-Eingang` · `Kommentar-schreibt-Deckung-einem-Sensor-zu-der-sie-nicht-leistet` · `Emit-Regel-trifft-das-Zitat-ihres-eigenen-Gegenstands` |
| MEDIUM | 1 | `Neue-oeffentliche-Funktion-ohne-benannte-Grenze` |
| LOW | 2 | `Ausnahme-auf-Substring-statt-auf-Form` · `Zweite-Verdrahtung-ohne-eigenen-Mutations-Fall` |
| INFO | 2 | `Vorab-benannte-Rueckfuehrungs-Bedingung-eingetreten` · `Weiterer-Beleg-einer-offenen-Beobachtung` |

**Wiederkehrende Klasse in dieser Sitzung:** HIGH-1 und HIGH-2 sind beide *eine Zusage nennt einen
Sensor, der sie nicht trägt* — einmal am Test, einmal am Doc-Kommentar. Zusammen mit dem
gleichlautenden Befund aus [2026-09-06 · slice-190](2026-09-06-slice-190-bootstrap-orte-review.md)
ist das die dritte Wiederholung derselben Klasse und damit ein Steering-Loop-Signal für die
Closure, kein bloßer Einzelbefund.

## Verdikt

**Blockierend.** Drei HIGH und ein MEDIUM. Die Kern-Lieferung des Slice funktioniert und ist am
realen Satz nachgemessen — Schritt 5 der Kopier-Prozedur läuft, die zwei Ausnahmen sind unberührt.
Blockierend sind nicht die Regel, sondern ihre Ränder: eine Wächter-Hälfte, die nicht rot werden
kann (HIGH-1), ein Kommentar, der die Lücke mit einem Sensor zudeckt, der sie nicht schließt
(HIGH-2), und ein emittiertes Norm-Artefakt, das die Regel beschädigt statt bereinigt (HIGH-3) —
letzteres genau der Fall, für den der Plan selbst eine Rückführung vorgesehen hat. Alle drei sind
gemessen, keiner ist geschlossen, und keiner der laufenden Gates sieht einen davon.

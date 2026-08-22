# Welle welle-11: Träger-Aussage — das emittierte Repo sagt, welche mitgelieferte Regel keinen Träger hat

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-11-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug (Konformitäts-Welle auf der emittierten Ebene, keine
Nutzer-Fähigkeit des Werkzeugs).

**Verantwortlich:** Planner. **Datum:** 2026-08-22.

---

## 1. Welle-Ziel

**Das gebootstrappte Repo sagt zu dem Regelwerk, das es vollständig mitgeliefert bekommt, welche
seiner Regeln dort einen Träger haben und welche nicht — als Text in bereits emittierten
Dokumenten, ohne ein neues Artefakt.**

Der Gegenstand ist die zweite Hälfte von
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren). Die erste ist erfüllt:
das Ziel trägt den vendored Baum netzlos und prüfsummen-verifiziert. Die zweite ist offen — ein
Adopter liest dort Regeln, deren Träger in seinem Repo nicht existiert, und **nichts in seinem Repo
sagt es ihm**. Dieselbe Lage war am 2026-07-28 der Auslöser von
[welle-09](welle-09-modul-15-konformitaet.md) (*„Nutzer-Befund — Modul 15 ist adoptiert und in
keinem Block umgesetzt"*); der Adopter steht danach dort, wo dieses Repo damals stand.

### Bestandsaufnahme — an einem gebootstrappten Ziel gemessen, nicht am Emit-Code gelesen

Alle Zahlen dieses Abschnitts stammen aus **zwei Sonden-Repos**, mit dem Binär aus
[`harness/tools/full-smoke.sh`](../../../harness/tools/full-smoke.sh)-Bauart erzeugt
(`make artifact DEST=<dir>`, dann `ai-harness-init --name Probe` bzw.
`ai-harness-init --lang go --name ProbeGo` in ein leeres `git init`-Verzeichnis) — die
**Varianten-Klammer**, ohne die wahr und falsch an der Ausgabe nicht zu unterscheiden sind
([`ADR-0007`](../adr/0007-bootstrap-phasen.md): `--lang` ist optional). Kommando neben der Aussage
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)),
gefahren am 2026-08-22:

| Regel im mitgelieferten Regelwerk | Träger hier | im Ziel | Kommando im Sonden-Repo |
|---|---|---|---|
| **Modul 2** §*Freshness-Audit der vendored Baseline* | `harness/tools/baseline-freshness.sh` + `harness/tools/component-freshness.sh`, `make baseline-freshness`, Nachtlauf | **fehlt ganz** — kein Ziel, keine Zeile | `grep -rni 'freshness' --exclude-dir=.git --exclude-dir=baseline . \| wc -l` → **0**; Gegenprobe im mitgelieferten Baum: `grep -rlni 'freshness' .harness/baseline/v3.5.2/regelwerk/ \| wc -l` → **2** |
| **`make`-Ansprüche des vendored Baums** (Modul 7/11/13/15 + Grundlagen) | hier gibt es die Ziele teils, teils nicht | **5** Regelwerk-Dateien nennen ein Ziel, das in **keiner** Variante existiert; **2** wiederkehrende Vorlagen tragen es beim `cp` in ein lebendes Dokument | `grep -rlE 'make (arch-check\|coverage-gate\|coverage-gate-critical\|fullbuild\|test-determinism\|verify)\b' .harness/baseline/v3.5.2/regelwerk/ \| wc -l` |
| **Modul 15**, Erfassung · Token-Attribution · Cache-Counter | `span-emit`, `make span-report`, `.claude/agents/` | **entschieden**, permanent nicht emittiert ([`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegungen 1–3) | `ls .claude/` im Ziel → `commands hooks settings.json` |
| **Modul 15**, Doku-Konsistenz-Drift | `make docs-check` + `.d-check.yml` | Träger `doc-targets` liegt bei, ist **nicht aktiviert** — Gegenstand von [welle-09](welle-09-modul-15-konformitaet.md), nicht dieser Welle | `grep -m1 '^modules:' .d-check.yml` → `modules: [links, anchors]`; `grep -c 'targets' .d-check.yml` → **0** |
| **Modul 8**, Rollen-Trennung | `.claude/agents/` (6 Dateien) | **entschieden**, permanent nicht emittiert ([`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegung 2) | dasselbe `ls .claude/` |

**Zwei Posten der Ausgangs-Lage haben die Messung nicht überlebt, und das ändert den Schnitt.**

1. **Der Reviewer-Skill fehlt nicht — er kommt mit.** `ls .harness/skills/` im Sonden-Repo nennt
   `reviewer.md` **und** `closure-note-reviewer.md`. Beide sind seit slice-030 als Singleton
   in-scope ([`internal/emit/templates.go`](../../../internal/emit/templates.go) `inScope`, dort
   ausdrücklich als Regel statt als Allowlist), und
   [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) führt den
   Reviewer-Skill in seiner Aufzählung. Die Ziel-Form aus Modul 10 ist im Ziel also vorhanden — als
   auszufüllende Vorlage, was genau ihre Ziel-Form ist. **Ein Slice dafür hätte keinen
   Gegenstand.** Derselbe Befund gilt für alle **sieben** `### Ziel-Form`-Abschnitte des
   Regelwerks — `grep -rh '^### Ziel-Form' .harness/baseline/v3.5.2/regelwerk/ | wc -l` → **7**,
   und jede zugehörige Vorlage liegt im `templates/`-Geschwisterbaum, den das Ziel vollständig
   bekommt (`ls .harness/baseline/v3.5.2/templates/.harness/skills/ …/docs/plan/{planning,adr,carveouts}/`).
2. **Die Mutations-Regel steht im Ziel nirgends.** *„Keine Zusage ohne rot gesehenes
   Gegenbeispiel"* ist [`AGENTS.md`](../../../AGENTS.md) §3.6 **dieses** Repos und ein Vorgriff auf
   einen späteren Kurs-Stand
   ([`MR-022`](../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)-Klasse).
   Die emittierte `AGENTS.md` stammt aus der vendored Vorlage und führt unter §3 sechs andere Hard
   Rules (`grep -n '^### 3\.' AGENTS.md` im Sonden-Repo); im gesamten mitgelieferten Baum trifft
   `grep -rniE 'rot gesehen|gegenbeispiel' .harness/baseline/v3.5.2/` **eine** Zeile, und die ist
   *„Gegenbeispiel-Rauschen"* aus einem anderen Zusammenhang. **Ein Ziel, das die Regel nicht
   liest, vermisst ihren Träger nicht** — `harness/tools/mutate.sh` und `test/mutations/` sind
   deshalb kein vierter Slice (§6).

### Kontext: drei Architect-Runden zur Emissions-Frage, die bisher nur in Chat-Antworten lebten

Diese sechs Befunde sind **keine Arbeit dieser Welle**. Sie stehen hier, weil
[`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) ab *Accepted* immutabel ist
([`AGENTS.md`](../../../AGENTS.md) §3.4) und über die Distributions-Frage nur einen Satz führt —
ein späterer Lauf fände die Runden sonst nirgends.

- **Sieben Transport-Wege sind abgezählt; die Zahl liefert kein Kommando, die Suchmethode ist
  prüfbar.** Sie entstand von Hand aus einem Sweep über die Mechaniken, die dieses Repo betreibt,
  gekreuzt mit vier Zeitpunkten (Bau · Release · Bootstrap · Laufzeit des Ziels) — nachvollziehbar
  ist die Methode, nicht die Ziffer
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1, Fall *Zählung von Hand*). **Weg 3 — digest-gepinntes OCI-Image, Binär per
  `docker create`/`docker cp` heraus — trägt mechanisch:** `docker` steht in
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)-AC
  *Minimal* auf der erlaubten Seite (*„über `bash + git + docker` hinaus nichts"*), und das Ziel
  fährt ohnehin ein digest-gepinntes Image — `grep -n 'DCHECK_DIGEST ?=' d-check.mk` im Sonden-Repo
  zeigt die gepinnte Referenz, die `docs-check` startet.
- **Zwei Kosten-Zuschreibungen aus [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md)
  Festlegung 1 sind korrigiert.** *„Eigene Plattform-Matrix"* ist **überzeichnet**:
  `grep -n 'RELEASE_PLATFORMS' Makefile` zeigt eine Variable, und
  `grep -n 'TARGET_OS\|TARGET_ARCH' Dockerfile` zeigt, dass die Bau-Stufe die Zielplattform bereits
  als Argument nimmt — eine zweite Matrix entstünde nicht, es wären dieselben Achsen. *„Eigene
  Distribution"* trifft für den Fetch-Weg zu; für den Image-Weg trägt auf der **Ziel**-Seite das
  `d-check`-Muster, **auf unserer Seite existiert der Kanal aber nicht**:
  `grep -rnE 'docker push|ghcr\.io|registry' .github/workflows/*.yml` ist leer (Exit 1).
- **Warum es trotzdem keine Folge-ADR gab.** Weg 3 verletzt
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) **Folgepflicht 1** (*„der Beleg emittiert
  nichts, was der Dogfood nicht selbst fährt"*) — der Dogfood **baut** den Emitter, das Ziel
  extrahierte ihn; das sind zwei Wege, und nur einer ist hier erprobt. Und **Folgepflicht 5** macht
  die Emission zum **Adopter-Vertrag** (Schema · Redaktion · Ablageort) mit drei gemessenen Lücken:
  im Ziel **kein Leser** (`grep -rn 'span-report\|span-emit' Makefile harness/mk/*.mk d-check.mk`
  im Sonden-Repo ist leer, Exit 1), **keine Rotation**
  (`grep -rn 'rotat\|retention\|prune' internal/span/*.go` ist leer, Exit 1) und die Redaktion
  fremden Codes, für die [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) nur den Dogfood
  entschieden hat.
- **Ein Muster, das erst die Abzählung sichtbar macht.** Jeder Kanal, dessen Inhalt unser eigenes
  **Release** erzeugt, ist von unserem Vor-Release-Smoke **nicht erreichbar**:
  [`harness/tools/full-smoke.sh`](../../../harness/tools/full-smoke.sh) baut das Werkzeug mit
  `make artifact` aus dem **Arbeitsbaum**. Was erst der Release-Lauf erzeugt, sieht der Smoke, der
  vor ihm läuft, per Konstruktion nie — dieselbe Klasse wie der Release-Text aus slice-050, den
  kein Gate dieses Repos erreicht.
- **Der `agent_role`-Einwand ist erledigt.** Die sechs Rollen-Dateien kosten
  `cat .claude/agents/*.md | wc -c` → **10.376** Byte, und die Achse trägt gemessen (slice-060,
  slice-066). Der Einwand war nie ihr Preis, sondern ihr fehlender Abnehmer im Ziel — und der hängt
  einseitig: **kippt [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegung 1, kippt
  Festlegung 2 mit** (dort ausgeschrieben: *„Die Zelle folgt Festlegung 1, und die Kopplung ist
  einseitig"*).
- **Der offene Change Request, präzise benannt.** Er trifft **nicht**
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) oder
  [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — beide **halten**
  für den Image-Weg, weil `docker` in ihrem Budget steht. Es fehlt eine Anforderung **überhaupt**:
  der CR wäre **additiv**, eine neue `LH-FA-*` für die emittierte Erfassungsschicht samt ihrer
  Policy-Hälfte (Schema · Redaktion · Ablageort · Rotation). Eigentümer ist der **Auftraggeber**
  ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  Solange er offen ist, ist die Modul-15-Emission **kein Wellen-Gegenstand** (§6).

## 2. Trigger (Welle startet)

- **[welle-10](welle-10-re-baseline.md) liegt in `done/`.** Beobachtbar ohne Rückfrage: die
  Plan-Datei liegt neben ihrer Ergebnis-Notiz.
- **Warum diese Reihenfolge tragend ist und nicht bloß ordentlich:** **jede** Messung dieser Welle
  läuft über den vendored Baum, und welle-10 tauscht genau ihn. Der Adaptions-Durchgang jener Welle
  bewegt zudem den Gegenstand von slice-090 unmittelbar — die Ziel-Fassung führt den
  Freshness-Audit mit **sieben** statt drei Eigenschaften, gemessen und ausgeschrieben in
  [ADR-0018](../adr/0018-ziel-fassung-regiert-die-migration.md) §*Was die beiden Fassungen zum
  Freshness-Audit führen* (**Proposed** — welcher Tag am Ende steht, ist dort noch offen; dass der
  Abschnitt **wächst**, ist gegen beide erwogenen Zielstände gemessen und trägt den Trigger
  unabhängig vom Ausgang). Eine Aussage über den Audit, die vor dem Tausch entsteht, beschriebe
  eine Prozedur, die das Ziel danach nicht mehr liest. Dasselbe Argument zog welle-10 gegenüber
  welle-09; es zieht hier eine Stufe weiter.
- **Damit ist [welle-09](welle-09-modul-15-konformitaet.md) mittelbar Vorbedingung** (sie blockiert
  welle-10). Das ist kein zweiter Trigger, sondern eine Folge des ersten — und es ist die
  Abgrenzung, die den Schnitt sauber hält: die `make`-Ansprüche der **lebenden** emittierten
  Doku-Tische gehören slice-087, die des **vendored Baums** dieser Welle (§4).

## 3. Closure-Trigger (Welle schließt)

**Das gemeinsame Kriterium:** *Für jeden Regelblock und jede Ziel-Form des mitgelieferten
Regelwerks sagt das emittierte Repo, ob ein Träger mitkommt — belegt im `full-smoke`.* Es wird
erst wahr, wenn alle drei Slices liegen: 090 und 091 setzen je einen Wert, 092 schließt die Liste.

- **Alle Slices dieser Welle in `done/`.**
- **Vollständigkeit heißt Inventar gegen Abdeckung, nicht „die auffälligen".** Der **Nenner** ist
  die Datei-Zahl des mitgelieferten Regelwerk-Verzeichnisses, zur Laufzeit gelesen
  (`ls .harness/baseline/*/regelwerk/*.md | wc -l` im gebootstrappten Ziel), nicht abgeschrieben —
  eine notierte Zahl bräche beim nächsten Baseline-Sprung, ohne dass am Gegenstand etwas bricht
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Dieselbe Lücke, an der welle-10 ihren Adaptions-Durchgang aufhängt.
- **Je Regelblock genau ein Wert, und der Wert-Vorrat ist geschlossen:** *Träger kommt mit* ·
  *Träger liegt bei, ist nicht verdrahtet* · *kommt nicht mit — Grund und Dauer benannt*. Eine
  leere Zelle ist ein offener Closure-Trigger, kein „passt schon". Wo
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) den Wert bereits gesetzt hat, wird er
  **verwiesen, nicht abgeschrieben** — eine zweite Fassung derselben Entscheidung driftet.
- **Beide Richtungen im `full-smoke`, über beide Bootstrap-Varianten geklammert:** (a) die Aussage
  steht im frisch gebootstrappten Ziel out-of-the-box, sprachlos **und** mit `--lang go`; (b) ihre
  emit-seitige Rücknahme wird **rot gesehen**. Nur (a) wäre die
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle
  eine Ebene weiter: ein Text, dessen Fehlen nichts rot färbt, ist keine Zusage
  ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Kein neues Artefakt.** Der emittierte Datei-Satz wächst nicht — die Aussage landet in
  Dokumenten, die das Ziel ohnehin bekommt. Damit bleibt die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) unberührt und
  das Budget aus [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) auch;
  ohne diese Schranke wäre die Welle ein Change Request
  ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  Prüfbar an der Ziel-Pfad-Liste des Emits (`TestTemplates_Layout`-Muster in
  `internal/emit/templates_test.go`), nicht an einer Beteuerung.
- **`make gates` grün** *und* `make full-smoke`; jeder neue Wächter hat seinen
  `test/mutations/`-Fall ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Carveout-Audit (Modul 7)** über den Bestand in `docs/plan/carveouts/` — gelesen wird der
  `Status:`-Kopf, nicht das Verzeichnis (`grep -n '^\*\*Status:' docs/plan/carveouts/CO-*.md`).
- **Closure-Notiz `welle-11-results.md`** mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Der Zustand jedes Slice ist sein Lifecycle-Verzeichnis, hier nicht gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-090](open/slice-090-freshness-audit-im-ziel.md) | Das Ziel erfährt, dass sein vendored Baum altert — und warum kein Sensor mitkommt | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |
| [slice-091](open/slice-091-vendored-baum-ohne-anspruch.md) | Der mitgelieferte Baum stellt keine `make`-Ansprüche an das Ziel, und eine lebende Zeile sagt es | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-092](open/slice-092-traeger-inventur.md) | Die Träger-Inventur: je Regelblock ein Wert, Inventar gegen Abdeckung | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |

**Die Reihenfolge ist die Aussage: 090 und 091 setzen je einen Wert, 092 schließt die Liste.** 090
und 091 hängen nicht aneinander — der eine spricht über eine Regel **ohne** Träger, der andere über
einen **Anspruch ohne Gegenstand**; beide sind einzeln lieferbar und einzeln nützlich. 092 läuft
zuletzt, weil eine Inventur, die vor ihnen entsteht, zwei Zellen als offen führte, die dann schon
belegt sind.

**Warum 090 und 091 zwei Slices sind und nicht einer.** Sie beantworten zwei Fragen und werden in
zwei Sitzungen geprüft: *„welche mitgelieferte Regel hat hier keinen Träger?"* (Modul 2, eine
geschuldete **Handlung** des Adopters) gegen *„welcher mitgelieferte Satz behauptet etwas über
dieses Repo, das nicht gilt?"* (eine **Falschaussage**, die beim `cp` einer Vorlage weiterwandert).
Der zweite hat einen eigenen, gemessenen Träger-Kreis: `welle.template.md` nennt `make fullbuild`,
`NNNN-titel.template.md` nennt `make arch-check` — und beide werden nach
[`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
**absichtlich** in lebende Plan-Dokumente kopiert. In einem Slice zusammen wären es mehr Zusagen,
als Modul 5 §Ziel-Form einem Schnitt zugesteht.

**Warum `harness/tools/mutate.sh` + `test/mutations/` kein vierter Slice ist.** Die Regel dahinter
— *keine Zusage ohne rot gesehenes Gegenbeispiel* — steht in
[`AGENTS.md`](../../../AGENTS.md) §3.6 **dieses** Repos und in **keiner** Zeile des mitgelieferten
Regelwerks (§1, zweiter Posten, mit Kommando). Ein Ziel, das die Regel nicht liest, vermisst ihren
Träger nicht; ein Slice dafür schriebe eine Aussage über eine Abwesenheit, deren Gegenstück im Ziel
gar nicht existiert — das wäre die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse mit
umgekehrtem Vorzeichen. **Die Frage kann wiederkommen, und dann als eigene:** bringt die
Re-Baseline die Regel in den Kurs-Stand, liest sie das Ziel — die Prüfung gehört dann in den
Adaptions-Durchgang von [welle-10](welle-10-re-baseline.md), der ohnehin jeden Eintrag gegen die
neue Fassung hält.

**Und warum kein Slice für den Reviewer-Skill.** Er kommt mit (§1, erster Posten, mit Kommando).
Ein Slice hätte keinen Gegenstand — die Ziel-Form liegt im Ziel, ausgefüllt wird sie vom Adopter.
Der Wert *Träger kommt mit* für Modul 10 wird in 092 gesetzt, nicht erarbeitet.

## 5. Abhängigkeiten

- **Wird blockiert von:** [welle-10](welle-10-re-baseline.md) — sie tauscht den Baum, über den
  jede Messung dieser Welle läuft (§2). Mittelbar damit auch von
  [welle-09](welle-09-modul-15-konformitaet.md), die welle-10 blockiert.
- **Blockiert:** keine geplante Welle. Sie ist die letzte der drei in der Reihe.
- **Innerhalb der Welle:** {090, 091} → 092.
- **Eine Eintritts-Vorfrage gehört dem Architect, und sie ist heute unbeantwortet.**
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) §Konsequenzen schreibt zum Halbsatz *„und
  das Ziel erfährt es nicht"*: *„eine Deklaration im Ziel wäre ein Artefakt, und genau das ist hier
  ausgeschlossen — die Grenze wird benannt, nicht geschlossen."* **Zu entscheiden ist, ob
  *Artefakt* dort die neue Datei meint oder jede Aussage.** Die Messung stützt die erste Lesart:
  die Entscheidung heißt *„nur Block 4, **ohne neues Artefakt**"*, und ein Satz in einem Dokument,
  das das Ziel ohnehin bekommt, lässt weder die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) noch das
  Budget aus [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) wachsen.
  Trägt die zweite Lesart, braucht diese Welle eine Folge-ADR, und slice-092 ist blockiert. **Der
  Planner entscheidet das nicht** — [`AGENTS.md`](../../../AGENTS.md) §3.4 macht die ADR ab
  *Accepted* immutabel, ihre Auslegung ist eine Architektur-Frage. Die Frage ist vor dem Eintritt
  von 092 zu stellen, nicht vor dem Schnitt: 090 und 091 hängen nicht an ihr, weil sie über
  Modul 2 bzw. über `make`-Ansprüche sprechen und nicht über die drei Modul-15-Blöcke, die
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) entschieden hat.
- **Nicht abhängig, aber benachbart:** slice-087 räumt dieselbe Fehlerklasse in den **lebenden**
  emittierten Doku-Tischen. Wer beide gleichzeitig anfasst, erzeugt einen Konflikt in
  `internal/emit`; die Trigger-Reihenfolge (§2) verhindert das.

## 6. Out-of-Scope für diese Welle

- **Die Emission der Modul-15-Erfassungsschicht** — Span-Emitter, Rollen-Typen, Token-Bericht.
  Sie ist in [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegungen 1–3 als
  **permanent** entschieden, und der Weg, der sie mechanisch trüge, verlangt eine Anforderung, die
  es nicht gibt. **Benannter Posten mit Eigentümer: der additive Change Request liegt beim
  Auftraggeber** ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler));
  die drei Runden, die dorthin führten, stehen in §1. Solange er offen ist, setzt diese Welle für
  diese Blöcke nur den **Wert** aus der ADR, sie stellt die Entscheidung nicht neu.
- **Die Aktivierung von `doc-targets` im Ziel** (Modul 15, Block 4). Sie gehört
  [welle-09](welle-09-modul-15-konformitaet.md), ist dort geschnitten (slice-063 auf slice-087) und
  in [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegungen 4/5 entschieden. Diese
  Welle nimmt ihr Ergebnis als Zellwert entgegen und rührt die Konfiguration nicht an.
- **Die `make`-Ansprüche der lebenden emittierten Doku-Tische** (`AGENTS.md`,
  `harness/README.md`, `.harness/skills/closure-note-reviewer.md`). Derselbe Fehler, anderer
  Gegenstand: sie sind slice-087, und der liegt in welle-09.
  [slice-091](open/slice-091-vendored-baum-ohne-anspruch.md) nimmt ausdrücklich nur den **vendored**
  Baum — die Trennung ist am Kommando ablesbar: sein Sweep schließt genau diese drei Vorlagen aus
  (dort §1).
- **Eine Reparatur im vendored Baum.** Er ist auf beiden Ebenen byte-verifiziert (`make
  baseline-verify` gegen `SHA256SUMS`, hier wie im Ziel); wer den Anspruch dort heilte, färbte den
  Gate rot. Diese Welle sagt **über** den Baum etwas, sie ändert ihn nicht — dieselbe Grenze, die
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(e) zieht.
- **`harness/tools/mutate.sh` + `test/mutations/`** — kein Gegenstand im Ziel (§4, mit Kommando).
- **Zeitdokumente** unter `docs/reviews/**` und `docs/plan/planning/done/**`. Sie halten den Stand
  ihres Laufs fest und werden nicht nachgezogen
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich).

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-11-results.md. -->

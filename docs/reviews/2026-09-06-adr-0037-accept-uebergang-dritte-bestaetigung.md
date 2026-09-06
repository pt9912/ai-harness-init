# Dritte Bestätigungsprüfung — ADR-0037 vor dem `Accepted`-Übergang

**Rolle:** Reviewer · **Datum:** 2026-09-06 · **Skill:** `reviewer.md` 1.7.0
**Art:** Bestätigungsprüfung, **keine** Runde 8 — Prüfgegenstand ist der Nacharbeits-Commit zu M-1,
L-1 und INFO-2 der Vorrunde und erneut die Frage, ob der Übergang selbst eine Aussage umstößt.

## Kopf-Metadaten

- **Prüfgegenstand:** `a74ff409` gegen `bb4fdfe0` (`git diff bb4fdfe0 a74ff409`), Gegenstand
  [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md),
  Status `Proposed`.
- **Vorrunde:** [`2026-09-06-adr-0037-accept-uebergang-zweite-bestaetigung.md`](2026-09-06-adr-0037-accept-uebergang-zweite-bestaetigung.md)
  (0 HIGH · 1 MEDIUM · 1 LOW · 2 INFO).
- **Auftrag:** die Simulation nachfahren, beide Hälften und beide Varianten, und prüfen, ob eine
  **dritte** Hälfte fehlt · Auflage 3 auf der Eigenschaft · Auflage 2 mit beiden Richtungen · den
  `-E`-Sweep des Architect · das Verdikt · und die Reihen-Frage nach der noch ausstehenden
  Test-Erweiterung.
- **Eingangs-Kontext (Skill §Eingangs-Kontext):** Diff/Commit-Range ✓ · Hard Rules
  ([`AGENTS.md`](../../AGENTS.md) §3.4/§3.5/§3.6/§3.7/§3.9/§3.10/§3.11) ✓ · referenzierte aktive
  ADRs ([ADR-0005](../plan/adr/0005-ziel-repo-distribution.md),
  [ADR-0006](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md),
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md),
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [ADR-0027](../plan/adr/0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md))
  ✓ · `LH-*` ([`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) ✓ · `MR-*`
  ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form),
  [`MR-046`](../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht),
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))
  ✓ · vorherige Findings am gleichen Modul (Runden 1–7, verengte Nachprüfung, zwei
  Bestätigungsprüfungen) ✓. **Nicht erhalten und hier benannt:** der Slice-Plan `slice-190`; die
  Aussagen der Datei über ihn liegen außerhalb meines Auftrags.
- **Nicht mein Gegenstand:** die inhaltlichen Festlegungen 1–4 (zehn Läufe ohne Befund gegen die
  Entscheidung) und die DoD-Abhakung (Verifier). `make docs-check` habe ich gefahren — als
  **Messung** zu einem Befund, nicht als Gate-Bestätigung.
- **Umgebung:** `git`, `sed`, `awk` und **zwei** `grep`-Implementierungen über Kopien außerhalb des
  Arbeitsbaums; keine Host-Toolchain ([`AGENTS.md`](../../AGENTS.md) §3.9). Für den einen
  Gate-Lauf lagen die zwei Dateien kurzzeitig im Arbeitsbaum und sind byte-exakt zurückgesetzt
  (`git status --porcelain` leer, `git diff --quiet HEAD -- docs/plan/adr/` Exit 0).

## Die Simulation, vollständig nachgefahren

Aufbau wie in der Vorrunde, jetzt **beide Hälften**: Kopie des Ist-Stands außerhalb des
Arbeitsbaums, `**Status:** Proposed` → `Accepted`, je eine der zwei realen `Accepted`-Zeilen des
Bestands (ADR-0028 bzw. ADR-0036) als letzte Zeile der Geschichte-Tabelle — **und** der von
Folgepflicht 5 vorgeschriebene Index-Nachzug an einer Kopie von `docs/plan/adr/README.md`.

Alle sieben Sonden der Datei über die drei Stände:

| Sonde | ist | + `Accepted` (0028) | + `Accepted` (0036) |
|---|---|---|---|
| Beleg-Form `grep -cE 'Baseline .v6\.0\.0.,'` | 11 | 11 | 11 |
| roher Link-Kopf `grep -oE '[]][(]' \| wc -l` | 131 | 135 | 135 |
| Ziel-Muster zeilenweise `grep -oE '\]\([^)]+\)' \| wc -l` | 131 | 135 | 135 |
| dasselbe umbruch-sicher über `tr '\n' ' '` | 131 | 135 | 135 |
| Ziel-Menge über den **Pfad** | 16 | 17 | 18 |
| Ziel-Menge über die **Zeichenkette** | 30 | 31 | 32 |
| tag-gepinnte Nennungen (alle im Fence) | 19 | 19 | 19 |
| `grep -c 'führt \`Proposed\`'` | 0 | 0 | 0 |
| Markdown-Links in den vendored Baum | 0 | 0 | 0 |
| Link-Kopf im Code-Fence / im Inline-Span | 0/0 | 0/0 | 0/0 |

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Tabelle des Architect reproduziert Zeile für Zeile. Die Index-Hälfte bewegt genau
**eine** Zeile (`diff | grep -c '^[<>]'` → 2) und keinen einzigen Link; die Statuszelle steht
vorher auf `Proposed`, nachher auf `Accepted`.

**Eine dritte Hälfte gibt es nicht — gemessen, nicht angenommen.** Vier unabhängige Messungen:

```sh
# 1. Der Bestand: jeder Accept-Commit berührt genau diese zwei Dateien
for adr in 0028 0030 0034 0036; do f=$(ls docs/plan/adr/${adr}-*.md)
  c=$(git log --format='%H' -S'**Status:** Accepted' -- "$f" | head -1)
  git show --pretty=format: --name-only "$c" | sed '/^$/d'; done | sort -u
# docs/plan/adr/00{28,30,34,36}-*.md  und  docs/plan/adr/README.md — sonst nichts

# 2. Wer ADR-0037 sonst nennt, nennt seinen Status nicht
git grep -l -e 'ADR-0037' -e '0037-bootstrap' -- ':!.harness/baseline'

# 3. Weder Vorlage noch Regelwerk verlangen einen dritten Schritt
grep -c -i 'acceptance' .harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md   # 0

# 4. Der statusabhängige Gate-Zweig kennt Accepted nicht als Verbot
awk '/^matrix:/{f=1} f{print} /^codepaths:/{if(f)exit}' .d-check.yml | grep 'status:'
# status: {forbidden: [superseded, deprecated]}
```

**Keine Erwartungswerte.** Zu (2): die Treffer sind die ADR selbst, der Index, ein `done/`-Slice und
sein Evidence-Beleg, ein `open/`-Slice und die zehn Review-Reports. Keiner behauptet den Status —
`done/slice-123` sagt *„berührt sie nicht"*, `open/slice-193` führt die **Nacharbeit** als
Start-Bedingung, und die zwei `Proposed`-Nennungen in `open/slice-152` und `open/slice-171` zählen
eine Menge, die der Übergang **verkleinert**; ihre DoD wird dadurch leichter, nicht falsch.

**Und der Übergang übersteht den Sensor** — beide Hälften im Arbeitsbaum, Variante 28 wie
Variante 36: `make docs-check` → `894 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. **Beide Richtungen
gesehen** ([`AGENTS.md`](../../AGENTS.md) §3.6): dieselbe Simulation mit einem Link in einen
beweglichen Baum meldet `docs/plan/adr/0037-…md:801 ../planning/next/slice-190-strukturorte.md
target-missing`, EXIT 1.

## Findings

### M-1 — Auflage 4 nennt für den `)`-Fall eine Wirkung, die die Sonde nicht hat

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6,
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:731` (Auflage 4) und
  `:796` (Geschichte-Zeile, dieselbe Aussage)
- **befund:** Beide Stellen sagen, ein Link-**Ziel mit `)` darin** ließe die drei Zählungen
  auseinanderfallen, deren Gleichheit die Sonden-Aussage trägt. Gemessen tut es das nicht: Über
  einem Ziel mit `)` bleiben alle drei Zählungen **gleich**, die Sonde meldet nichts. Was
  tatsächlich bricht, ist die **Extraktion** — `\]\([^)]+\)` schneidet das Ziel an der ersten
  Klammer ab —, und genau die extrahierte Pfad-Menge ist die Menge, über die die
  Erschöpfungs-Aussage Ziel für Ziel läuft. Die Zählungen prüfen die **Vollzähligkeit** der
  Treffer, nicht die **Richtigkeit** der Ziele; die zwei Stellen geben das eine für das andere
  aus.

  ```sh
  printf 'Ein Link [X](pfad/zu(einer)datei.md) mitten im Text.\n' > t-paren.md
  printf 'Ein Link [X](pfad/zu/einer/\ndatei.md) ueber einen Umbruch.\n' > t-umbruch.md
  for f in t-paren t-umbruch; do
    a=$(grep -oE '[]][(]' $f.md | wc -l)
    b=$(grep -oE '\]\([^)]+\)' $f.md | wc -l)
    c=$(tr '\n' ' ' < $f.md | grep -oE '\]\([^)]+\)' | wc -l)
    printf '%-11s %s/%s/%s\n' "$f" "$a" "$b" "$c"; done
  # t-paren     1/1/1   -> gleich, die Sonde meldet NICHTS
  # t-umbruch   1/0/1   -> ungleich, die Sonde meldet
  grep -oE '\]\([^)]+\)' t-paren.md | sed -E 's/^\]\(//; s/\)$//'   # pfad/zu(einer
  ```

  **Keine Erwartungswerte.** Der zweite der zwei genannten Fälle — der Umbruch-Link — verhält sich
  wie beschrieben; der erste nicht. Und die Gegenprobe am **Gate** zeigt, dass die Sonde und das
  Doku-Gate über derselben Zeile verschiedene Ziele lesen: d-check nennt in seinem Befund den
  **vollständigen** Pfad `pfad/zu(einer)datei.md`, die Sonde liefert `pfad/zu(einer`. Balancierte
  Klammern sind in einem Markdown-Linkziel zulässig; eine CommonMark-treue Extraktion desselben
  Ziels liefert es ungekürzt.
- **verifizierbar:** ja für die Messung (der Block oben, plus `make docs-check` über einer Kopie
  mit einem solchen Ziel); **nein** als Gate für die Aussage selbst — kein Modul der
  `.d-check.yml` liest den Wirkungssatz einer Prosa-Auflage (`grep -n '^modules:' .d-check.yml`).
- **klasse:** Wirkungs-Aussage einer Sonde nennt einen Fall, den die Sonde nicht anzeigt
- **warum blockierend:** Die Aussage ist **jetzt schon falsch** und friert in zwei Stellen ein.
  Wer nach dem Übergang die Gleichheit der drei Zählungen prüft und grün sieht, hält die
  Pfad-Menge für vollständig **und** richtig; für einen der zwei ausdrücklich genannten Fälle ist
  sie nur vollständig. Das ist die Bauform, die
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) für Gates
  verbietet, eine Ebene tiefer — eine Deckung, die kein Lauf hat, als vorhanden verbucht. Nach
  `Accepted` ist der Satz durch [`AGENTS.md`](../../AGENTS.md) §3.4 unerreichbar und die Korrektur
  kostet eine Folge-ADR; es ist derselbe Kosten-Grund, mit dem
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) die Beleg-Form vor
  den Übergang legt.

### L-1 — Auflage 2 verbreitert die Richtung, nicht das Subjekt: die Klasse von M-1 der Vorrunde bleibt draußen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4,
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:719-724`
- **befund:** Auflage 2 lautet jetzt *„Keine neue selbstbezügliche Aussage über den Bestand dieser
  Datei — mit Zahl wie ohne — **und keine Änderung, die eine stehende falsch macht**."* Das
  Ellipsen-Subjekt der zweiten Richtung ist *selbstbezügliche Aussage*; beide Richtungen sind damit
  auf Aussagen über **diese Datei** beschränkt. Der Posten, den die Vorrunde als M-1 blockierte,
  war keine solche: sein Subjekt war der **ADR-Index**, ein fremdes Artefakt. Die Geschichte-Zeile
  desselben Commits spricht die Verallgemeinerung aus — *„dieselbe Trennlinie … angewandt auf einen
  **fremden** Gegenstand"* —, die bindende Auflage übernimmt sie nicht. Die realisierte Instanz ist
  entfernt; die Regel, die ihre Wiederkehr im Geschichte-Eintrag des annehmenden Laufs verhinderte,
  steht nicht.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  tr '\n' ' ' < "$D" | tr -s ' ' \
    | grep -c 'Keine neue \*\*selbstbezügliche Aussage\*\* über den Bestand dieser Datei'   # 1
  tr '\n' ' ' < "$D" | tr -s ' ' \
    | grep -c 'angewandt auf einen \*\*fremden\*\* Gegenstand'                              # 1
  ```

  **Keine Erwartungswerte.** Ein konstruierter Geschichte-Eintrag *„Der ADR-Index steht jetzt auf
  `Accepted`"* passiert alle fünf Auflagen und alle sieben Sonden: er ändert keine Zählung außer
  der Link-Zahl, führt kein neues Ziel in die Pfad-Menge ein und trägt weder einen Baseline-Link
  noch eine rohe Link-Kopf-Sequenz.
- **verifizierbar:** ja für die Messung; nein als Gate.
- **klasse:** das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat
- **nicht blockierend:** Anders als bei M-1 ist keine stehende Aussage falsch — die Auflage ist nur
  enger als die Lehre, die zwei Absätze weiter in derselben Datei steht, und der annehmende Lauf
  liest beide. Dazu ist der Fall im **Bestand nicht realisiert**: die zwei einzigen realen
  `Accepted`-Zeilen dieses Repos (ADR-0028, ADR-0036) tragen ausschließlich Aussagen über benannte
  abgeschlossene Vorgänge, kein Präsens-Urteil über ein fremdes Artefakt.

### INFO-1 — Auflage 3 ist strenger als die Sektion, die sie als Grund nennt

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.11
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:725-731`
- **befund:** Auflage 3 fragt je Ziel nach *wandert auf Anweisung* und beruft sich dafür auf
  §3.11. Jene Sektion trägt daneben ihre eigene Gegen-Klausel — *„ein Verzeichnis, ein Glob, eine
  stehende Ablage und eine Datei, die ihren Lifecycle bereits verlassen hat, sind ortsfest und
  bleiben als Pfad zulässig"* —, und die Auflage nennt sie nicht. Sie ist damit enger als ihr
  Grund, nicht weiter; die praktisch betroffene Klasse hat die Datei an anderer Stelle bereits
  ausgenommen (die Register-Ablage ist samt ihren Verzeichnissen ortsfest,
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5).
- **verifizierbar:** nein.
- **klasse:** abgeleitete Regel lässt die Ausnahme ihrer Quelle weg

### INFO-2 — der ADR-Index zählt sechs Gate-Module, die Konfiguration führt sieben

- **kategorie:** INFO
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** [`docs/plan/adr/README.md`](../plan/adr/README.md) §Konventionen, letzter Punkt
- **befund:** Der Index sagt *„Keines der in `.d-check.yml` aktivierten Module (`links, anchors,
  ids, matrix, codepaths, spans`) vergleicht eine Zelle mit der `# `-Überschrift oder einem
  Kopffeld"*. Die Konfiguration führt seit der Aktivierung von `planning` **sieben** Module. Die
  Aussage selbst bleibt wahr — `planning` liest die Lifecycle-Invariante, keine Index-Zelle —, ihre
  Aufzählung ist es nicht mehr. Der Befund ist **nicht** durch den Prüfgegenstand verursacht und
  steht hier, weil Folgepflicht 5 den annehmenden Lauf in genau diese Datei schickt.

  ```sh
  grep -n '^modules:' .d-check.yml
  # modules: [links, anchors, ids, matrix, codepaths, spans, planning]
  ```

  **Kein Erwartungswert.**
- **verifizierbar:** ja für die Messung; nein als Gate.
- **klasse:** eingefrorene Aufzählung neben einer wandernden Konfiguration

## Negativbefunde

- **M-1 der Vorrunde — behoben, Instrument in beide Richtungen nachgefahren.** Der Satz *„Der
  ADR-Index (`README.md`) führt `Proposed`"* ist weg; die Pflicht steht ohne ihn und verortet den
  Nachzug weiter nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  im selben Architect-Commit. `grep -c 'führt \`Proposed\`'` über der Fassung vor `a74ff409` → 1,
  über der danach → 0, über beiden Simulationen → 0. **Keine Erwartungswerte.** Der Bestand
  bestätigt die Rollen-Zuweisung: vier geprüfte Accept-Commits berühren die ADR **und** den Index,
  keiner etwas Drittes.
- **L-1 der Vorrunde — behoben, und die Eigenschaft trägt statt der Liste.** Auflage 3 steht auf
  *„Kein Markdown-Link auf ein Ziel, dessen Ort ein vom Prozess vorgeschriebener Vorgang bewegt"*.
  Die vier Vorgänge daneben sind als **Beispiel** markiert (*„fallen unter anderem"*) und
  ausdrücklich als Nicht-Kriterium (*„geprüft wird gegen die Eigenschaft, nicht gegen diese
  vier"*). Die zwei von mir gemeldeten Bäume sind erfasst — die Carveout-Ablage über *„die
  Auflösung eines Carveouts"*, die Eintragsdateien über *„der `git mv` eines Eintrags des
  Adaptions-Blocks"* —, und die Liste tut die Arbeit nicht: ich habe die Erschöpfungs-Prüfung
  ohne jede Klassen-Liste über **alle 18** Ziele beider Simulationen gefahren, Ziel für Ziel, und
  keines wird von einem Vorgang bewegt. Am Werkzeug statt am Wortlaut geprüft:
  `internal/archive/collect.go` sammelt `docs/plan/planning` und `docs/reviews`,
  `harness/tools/slice-mv.sh` bewegt innerhalb von `LIFECYCLE="open next in-progress done"`; unter
  `docs/plan/adr/` bewegt kein Werkzeug etwas (`grep -rn "docs/plan/adr" internal/archive/
  harness/tools/slice-mv.sh` trifft nur Testdaten und eine **lesende** Stub-Funktion).
- **INFO-2 der Vorrunde — geschlossen.** Das Urteil über die tag-gepinnten Baseline-Nennungen
  fällt jetzt unter Auflage 2, zweite Richtung, und ist dort namentlich genannt. Die Nennungen
  selbst stehen in allen drei Ständen bei 19, sämtlich im Code-Fence.
- **INFO-1 der Vorrunde — richtig nicht aufgenommen.** Er gilt dem Beleg-Kommando einer
  Commit-Message und weist die zwei betroffenen Sätze selbst als wahr und stabil aus; am Text der
  Datei war nichts zu ändern.
- **Der `-E`-Sweep des Architect hält, und ich habe ihn mechanisch statt per Auge nachgefahren.**
  Über **alle** abgedruckten Kommandos — 19 Code-Fences plus die Inline-Spans — gibt es kein
  `grep` mit escaped Klammer ohne `-E`:

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  { awk '/^[[:space:]]*```/{f=!f; next} f' "$D"
    awk '/^[[:space:]]*```/{f=!f; next} !f' "$D" | grep -oE '`[^`]+`'; } \
    | grep -E 'grep ' | grep -E '\\[()]' | grep -vcE 'grep -[a-zA-Z]*E'   # 0
  ```

  **Kein Erwartungswert.**
- **Erweiterung, hier zum ersten Mal gefahren: jedes abgedruckte Kommando unter zwei
  `grep`-Implementierungen.** Die Eigenkorrektur der Vorrunde hatte gezeigt, dass ein abgedrucktes
  Kommando in *dieser* Umgebung abbrechen kann; die Frage danach ist, ob es in einer **anderen**
  etwas anderes ausgibt. Alle 19 Fence-Blöcke und alle zwölf zählenden Inline-Kommandos laufen
  unter GNU grep 3.11 und unter ugrep 7.8.4 mit **identischem** Ergebnis, und jedes trifft seinen
  abgedruckten Wert. Ein einziger Unterschied bleibt und ist keiner am Wert: `blk16` gibt seine
  zwei Dateien in verschiedener Reihenfolge aus.
- **REFUTED — die `^\|`-Form ist kein Instrument-Defekt.** Ich hatte den Verdacht, dass
  `grep -h '^\| .*\*\*Accepted\*\*'` unter GNU grep die Alternation `\|` trifft und damit jede
  Zeile matcht; roh gelesen tut es das (12133 statt 65 Zeilen). Der Verdacht trägt trotzdem nicht:
  Das Kommando steht in einer **Tabellenzelle**, wo `\|` die Markdown-Schreibung des Pipe-Zeichens
  ist — auch innerhalb eines Code-Spans. Gerendert lautet es `'^| …'`, und in dieser Form liefert
  es unter beiden Werkzeugen **2**, den Wert, den die Zeile behauptet. Der Architect hat in seiner
  Commit-Message genau die gerenderte Form abgedruckt. Belegt mit Code-Zitat und Messung, nicht mit
  „spekulativ".
- **Erweiterung, ebenfalls neu: die fünf Auflagen adversarisch gestresst.** Alle bisherigen
  Simulationen variierten die **Identität** der `Accepted`-Zeile (0028 gegen 0036), nicht ihre
  **Inhalts-Klasse**; beide Proxys tragen weder eine selbstbezügliche noch eine
  Fremd-Zustands-Aussage und können die Auflagen 2 bis 5 darum gar nicht auslösen. Ich habe je eine
  Zeile gebaut, die genau eine Auflage verletzt, und gemessen, welche Sonde anschlägt:

  | konstruierte Zeile | trifft | Sonde meldet |
  |---|---|---|
  | Markdown-Link in den vendored Baum | Auflage 1 | ja (Baseline-Link 0 → 1) |
  | *„Die Datei trägt zwölf Baseline-Belege"* | Auflage 2 (1. Richtung) | nein — Auflage, kein Sensor |
  | Link nach `planning/next/…` | Auflage 3 | ja (Pfad-Menge +1, `docs-check` rot) |
  | Ziel mit `)` darin | Auflage 4 | **nein** — siehe M-1 |
  | *„Der ADR-Index steht jetzt auf `Accepted`"* | **keine** | nein — siehe L-1 |

  Der leere Sensor bei Auflage 2 ist erwartet und in der Datei ausgesprochen (*„keine hat einen
  Wächter"*); der leere bei Auflage 4 ist es nicht.
- **Ein Wächter, den die Datei nicht nennt, bindet den annehmenden Lauf trotzdem.** Die
  `ids`-Muster der `.d-check.yml` tragen dreimal `link-policy: always`
  (`awk '/^ids:/,/^matrix:/' .d-check.yml | grep -c 'link-policy: always'` → **3**, kein
  Erwartungswert); jede `ADR-NNNN`-, `LH-XX-NN`- und `MR-NNN`-Kennung im Geschichte-Eintrag muss
  also verlinkt sein. Das widerspricht der Aussage *„keine der fünf hat einen Wächter"* nicht — sie
  gilt den Auflagen, nicht dem Zeileninhalt —, und es ist die einzige maschinelle Schranke, die auf
  die neue Zeile fällt.
- **Der Übergang übersteht das Doku-Gate.** Beide Hälften im Arbeitsbaum, Variante 28 wie
  Variante 36: `894 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Der Arbeitsbaum ist danach byte-exakt
  zurückgesetzt.
- **Umfang des Commits.** `git show --pretty=format: --name-only a74ff409` nennt allein die ADR;
  zwei Hunks, 18 Einfügungen / 9 Löschungen. Status (`Proposed`, Zeile 3) und ADR-Index sind
  unverändert. Die Zahl der Auflagen ist weiter fünf
  (`sed -n '/Folgepflicht 5 (der annehmende Lauf)/,/^$/p' | tr '\n' ' ' | grep -oE '\([1-9]\) \*\*' | wc -l`
  → 5), der Satz *„Fünf Auflagen binden den Übergang"* bleibt wahr.
- **Der `Bezug`-Kopf trägt ADR-0024 weiterhin nicht.** Das ist keine Abweichung von der Vorrunde —
  sie hatte den Zug ausdrücklich dem **annehmenden** Lauf zugewiesen, nicht diesem Commit.
- **Nicht geprüft, weil außerhalb des Auftrags:** die Festlegungen 1–4 selbst, die Aussagen der
  Datei über `slice-190`, die Belegform der übrigen Baseline-Aussagen (Runde 7) und die
  DoD-Konformität (Verifier).

## Die Reihen-Frage — welche Erweiterung noch aussteht

Die letzten drei Posten fielen, weil der Test wuchs: *Korrektur prüfen* → *Übergang simulieren* →
*beide Dateien simulieren*. Zwei Erweiterungen standen noch aus; ich habe **beide in diesem Lauf
ausgeführt** statt sie einer weiteren Runde zu überlassen.

1. **Instrument-Unabhängigkeit.** Bis hierher lief jede Messung unter *einer*
   `grep`-Implementierung. Jedes abgedruckte Kommando ist jetzt unter zwei gefahren — ohne
   Abweichung, und mit einer widerlegten Verdachts-Fundstelle.
2. **Auflagen adversarisch statt bestätigend geprüft.** Bis hierher wurde gemessen, dass die
   realen `Accepted`-Zeilen die Auflagen *einhalten*. Nicht gemessen war, ob eine Zeile, die eine
   Auflage *verletzt*, überhaupt auffällt. Genau dieser Schritt hat M-1 und L-1 geliefert — die
   zwei Auflagen, deren Fall durch alle Sonden fällt.

**Eine dritte sehe ich nicht mehr, und das ist Teil meines Verdikts.** Die drei Achsen, an denen
diese Reihe Posten produziert hat, sind jetzt alle mit einem Test belegt: der Übergang schreibt
zwei Dateien (Bestands-Messung über vier Accept-Commits), er übersteht den Sensor (Gate-Lauf über
beiden Varianten), und seine Auflagen sind in beide Richtungen gefahren (Einhaltung **und**
Verletzung). Was danach bleibt, ist keine Test-Erweiterung mehr, sondern der **Wortlaut** der
Zeile, die der annehmende Lauf schreibt — und der ist per Definition erst prüfbar, wenn er
dasteht. Ein Test kann ihn nicht vorwegnehmen; die Auflagen sind das Mittel, und deshalb liegt
mein blockierender Posten in einer von ihnen.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | *Wirkungs-Aussage einer Sonde nennt einen Fall, den die Sonde nicht anzeigt* (M-1) |
| LOW | 1 | *das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat* (L-1) |
| INFO | 2 | *abgeleitete Regel lässt die Ausnahme ihrer Quelle weg* (INFO-1) · *eingefrorene Aufzählung neben einer wandernden Konfiguration* (INFO-2) |

**Steering-Loop-Gehalt.** L-1 trägt die Klasse, die diese Reihe am häufigsten führt, und sie ist
zum zweiten Mal in Folge **versetzt**: In der Vorrunde war der Katalog aus der Aussage entfernt und
in der Auflage wieder aufgetaucht; hier ist er aus der Auflage entfernt und die *Subjekt*-Grenze
zurückgeblieben. M-1 trägt die Klasse der verengten Nachprüfung und von Runde-6-M-1 — *ein
Instrument, das nicht ausgibt, was danebensteht* —, diesmal nicht am Wert, sondern an der
Wirkungs-Aussage. Die Register-Zuordnung beider Klassen fällt bei der Slice-Closure, nicht hier
([`AGENTS.md`](../../AGENTS.md) §3.10).

## Verdikt

**Der `Accepted`-Übergang ist noch nicht möglich.** Genau ein Posten blockiert, und er liegt **in
der Wahrheit** — nicht im Argument und nicht im Protokoll.

- **Im Argument** steht nichts offen. Gegen die vier Festlegungen ist in zehn Läufen kein Befund
  gefallen. M-1 der Vorrunde ist an seiner Substanz behoben, und die Behebung ist in beide
  Richtungen nachgemessen. L-1 der Vorrunde ist mehr als behoben: Auflage 3 steht auf der
  Eigenschaft, und ich habe belegt, dass nicht die Beispiel-Liste die Arbeit tut — die
  Erschöpfungs-Prüfung läuft ohne jede Klassen-Liste über alle 18 Ziele und am Werkzeug statt am
  Wortlaut. INFO-2 der Vorrunde ist über die zweite Richtung von Auflage 2 geschlossen, ohne den
  sechsten Katalog-Eintrag, der L-1 gekostet hätte.
- **Im Protokoll** steht nichts offen. Alle abgedruckten Kommandos reproduzieren — und zwar unter
  zwei `grep`-Implementierungen. Die drei Zählungen sind in jedem der drei Stände gleich, kein
  eingefrorener Selbstbezugs-Wert ist geblieben, der `-E`-Sweep hält mechanisch, und der Übergang
  fährt das Doku-Gate in beiden Varianten grün. Meinen einen Verdacht gegen ein Instrument habe ich
  oben ausdrücklich widerlegt statt ihn als Befund zu führen.
- **In der Wahrheit** steht der Posten: Auflage 4 und die Geschichte-Zeile, aus der sie stammt,
  sagen für den `)`-Fall eine Sonden-Wirkung zu, die die Sonde nicht hat. Die Zählungen bleiben
  gleich; was bricht, ist die Ziel-Extraktion, über die die Erschöpfungs-Aussage läuft. Der Satz
  ist heute falsch und friert an zwei Stellen ein.

**Warum ihn keine der neun Vorrunden fangen konnte:** Sie haben die Sonde jeweils *gefahren* und
ihre Gleichheit festgestellt. Ob die Gleichheit den Fall anzeigt, für den sie beansprucht wird, ist
eine andere Frage — sie verlangt ein Gegenbeispiel, das die Sonde rot färben **müsste**
([`AGENTS.md`](../../AGENTS.md) §3.6). Für den Umbruch-Link färbt es rot, für das `)`-Ziel nicht.

### Auflagen für den annehmenden Lauf

Gültig, sobald M-1 erledigt ist. Ich bestätige die fünf, die als Folgepflicht 5 in der Datei
stehen — vollständig, nummeriert und **in beiden Präzedenz-Varianten einhaltbar**: gegen die
`Accepted`-Zeile von ADR-0028 wie gegen die von ADR-0036 hält jede einzelne (Baseline-Link 0/0,
Link in einen beweglichen Baum 0/0, drei Zählungen gleich, kein Link-Kopf in Fence oder Span,
keine neue Selbstbezugs-Aussage), und der Gate-Lauf über beiden Ständen ist grün. Auflage 4 gilt
dabei nach ihrem **Verbot**, nicht nach ihrer Begründung. Dazu drei Punkte:

1. **Auflage 2 gilt auch für ein fremdes Artefakt**, dessen Zustand derselbe Commit ändert —
   namentlich für den ADR-Index (L-1). Getragen ist das von der Trennlinie, die die Datei zwei
   Absätze weiter selbst zieht: Subjekt = benannter abgeschlossener Vorgang trägt, Subjekt =
   laufender Bestand nicht.
2. **Jede `ADR-NNNN`-, `LH-XX-NN`- und `MR-NNN`-Kennung des neuen Geschichte-Eintrags wird
   verlinkt** — das ist die einzige maschinelle Schranke auf die Zeile
   (`ids`/`link-policy: always`, drei Muster) und die einzige, deren Verletzung sofort rot wird.
3. **Der `Bezug`-Kopf um ADR-0024 und der Index-Nachzug reisen im selben Architect-Commit mit** —
   unverändert aus der Vorrunde; der Zug ist nicht geschuldet, aber folgenlos für alle sieben
   Sonden und schließt die einzige Ausnahme von der Form, die diese Datei sonst durchhält.

**Keine dieser Auflagen hat einen Wächter, Punkt 2 ausgenommen** — kein Modul der `.d-check.yml`
liest sie (`grep -n '^modules:' .d-check.yml`), und `make mutate` kennt keine Fehlschlag-Form
dafür. Träger ist der Rollen-Wechsel vor dem Übergang, nicht ein Gate danach.

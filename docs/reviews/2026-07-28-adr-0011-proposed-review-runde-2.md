# Review-Report: ADR-0011 (Proposed, **Runde 2**) — Telemetrie-Erfassung, Policy für Agenten-Spans — 2026-07-28

**Review-Art:** **Proposed-Review einer ADR, zweite Runde** — geprüft wird die **Überarbeitung**
einer noch nicht angenommenen Entscheidung ([`AGENTS.md`](../../AGENTS.md) §3.4 greift erst ab
*Accepted*). Kein Produktiv-Diff. **Nicht** geprüft: Code, DoD-Abhakung (Modul 11, getrennter
Kontext).

**Leitfrage dieser Runde** — und sie ist eine andere als in Runde 1: nicht „sind die alten Befunde
abgehakt", sondern **was die Überarbeitung neu kaputt gemacht hat und was sie nur verschoben hat**.
Die Präzedenz dieses Repos trägt die Frage: bei [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md)
fing die zweite Runde eine fail-OPEN-Regression, die der Fix selbst erzeugt hatte; bei
[`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md) fing jede der vier Runden, was die
vorige eingebaut hatte. **Diese Runde findet dasselbe Muster:** die drei schwersten Befunde unten
existieren erst seit der Überarbeitung, und zwei davon entstehen im Fix des Runde-1-HIGH F-2.

**Gegenstand:** [`docs/plan/adr/0011-telemetrie-erfassung-policy.md`](../plan/adr/0011-telemetrie-erfassung-policy.md)
(Status **Proposed**), im Kontext von
[`docs/plan/planning/welle-09-modul-15-konformitaet.md`](../plan/planning/welle-09-modul-15-konformitaet.md)
und `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md`. <!-- d-check:ignore (Lifecycle-Pfad: die Slice-Datei wandert durch open/next/in-progress/done) -->

**Diff:** `git show bbbc0c2` — vier Dateien, 664+/54−: die ADR (171 Zeilen), slice-059 (1 Zeile),
welle-09 (5 Zeilen), plus der Runde-1-Report als neue Datei. **Gemessen:** weder
`spec/lastenheft.md` noch `.claude/settings.json` sind berührt
(`git show bbbc0c2 --name-only`), die Überarbeitung ist rein dokumentarisch.

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ 1.4.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Regelwerk (Baseline v3.5.2, vendored): `modul-04-architektur-adrs.md` §Ziel-Form: ADR,
  `modul-15-observability.md` (der Gegenstand), `modul-07-carveouts.md` §Auflösungs-Trigger,
  `grundlagen-klassifikation.md` §Quadranten (Wortlaut gelesen, nicht aus der ADR übernommen)
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (**verbatim** gelesen,
  `spec/lastenheft.md:268-276`)
- Aktive ADRs auf Kollision geprüft: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md),
  [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md),
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md),
  [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md)
- Adaptionen: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.4 und §3.6
- **Vorherige Findings am gleichen Modul:** [`2026-07-28-adr-0011-proposed-review.md`](2026-07-28-adr-0011-proposed-review.md)
  (Runde 1: 2 HIGH, 6 MEDIUM, 3 LOW) und der vorgelagerte
  [`2026-07-28-welle-09-plan-review.md`](2026-07-28-welle-09-plan-review.md) (F-2/F-3 HIGH, F-4)
- **Eigene Messungen dieser Sitzung** (nichts aus der ADR oder aus Runde 1 übernommen):
  `make docs-check` → **d-check 230/0** (Stand vor diesem Report); `.claude/settings.json` und
  `.codex/hooks.json` gelesen; `ls -la .harness/state/` → Verzeichnis **0775**, Stempeldatei
  **0664**; `harness/tools/record-gates.sh` gelesen (legt `.harness/state/` mit `mkdir -p` an,
  setzt keinen Modus); Makefile auf ein Aufräum-Target für `.harness/state/` durchsucht → **keins**;
  `harness/tools/mutate.sh` §`narrow_sensor` gelesen (Fall-Kopf `# files:` + `# expect:`, bats-Fälle
  sind zulässig); Inventar der Host-Skripte gezählt (`harness/tools/` → **14 `.sh` + 2 `.awk`**,
  `.claude/hooks/` → **2 `.sh`**); **die Hook-Doku (<https://code.claude.com/docs/en/hooks>) selbst
  abgerufen** — gezielt zu Parallelität, Timeout-Semantik, PreToolUse-Exit-Codes und
  `permissionDecision`

---

## Findings

### R2-1 — Festlegung 4 verbietet in einem Satz, was sie im nächsten erlaubt: „keine Host-Sprachlaufzeit" schließt die vorhandene Durchsetzungsschicht und einen laufenden Gate mit ein

- `kategorie`: **HIGH**
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ·
  [`AGENTS.md`](../../AGENTS.md) §3.4 (nach *Accepted* nicht mehr korrigierbar) ·
  `modul-04-architektur-adrs.md` §Kernidee („Wenn dein Reviewer-Agent den Grund nicht findet, kann
  er die Entscheidung nicht verteidigen") · [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:122-126` („Konkrete Folge"), im
  Widerspruch zu `:110-117` (Randbedingung) und zu `:135` (Festlegung 5 zieht sie ins Ziel)
- `befund`: Die neue Fassung zieht aus
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) die Folge *„ein
  Hook-Skript in einer **Host-Sprachlaufzeit** ist damit **ausgeschlossen** — auch dann, wenn der
  Command-Guard es heute nicht blockt"* und schließt zwei Sätze später mit *„Die vorhandene
  Durchsetzungsschicht ist zero-dep bash+awk … die Erfassung bleibt in derselben Klasse."* Ein
  Kriterium, das `bash` und `awk` **aus** der Klasse „Host-Sprachlaufzeit" heraushielte, nennt die
  ADR nicht — die Ausnahme steht als Behauptung neben dem Verbot. Am Ist-Bestand gemessen ist die
  Reichweite nicht theoretisch: dieses Repo fährt **14 Host-`.sh` + 2 Host-`.awk`** unter
  `harness/tools/`, **2** unter `.claude/hooks/`, und `make comment-claims` — ein Schritt **in
  `make gates`** — ist im Makefile selbst als *„Hermetisch: reines bash+awk auf dem Arbeitsbaum,
  kein Docker, kein Netz"* deklariert. Die Regel ist damit in genau zwei Lesarten stabil, und beide
  sind schlecht: sie gilt wörtlich (dann verurteilt sie den bestehenden Guard, den Stop-Hook und
  einen laufenden Gate und lässt slice-059 ohne zulässige Umsetzung) oder sie gilt mit der
  ungeschriebenen bash/awk-Ausnahme (dann ist sie inhaltsleer und der Implementer zieht die Grenze
  selbst). Es ist dieselbe Fehlerklasse, die Runde 1 als F-4(b) fand — „das Ergebnis in die
  Anforderung hineinschreiben" —, nur vom Zitat in die Folgerung umgezogen.
  Failure-Szenario: der Implementer von slice-059 liest Festlegung 4, hält den geplanten
  bash+awk-Emitter für ausgeschlossen (nichts im Text sagt ihm das Gegenteil außer einem Satz, der
  seinerseits nur behauptet) und zieht die in slice-059 §4 vorgesehene Kante `in-progress → open`
  wegen einer Normativ-Frage, die die ADR gerade entschieden zu haben behauptet. Umgekehrt: der
  Autor von slice-062/063 nimmt die Ausnahme als Freibrief und emittiert eine beliebige
  Interpreter-Wahl ins Ziel — Festlegung 5 (`:135`) erklärt Festlegung 4 dort für unverändert
  geltend, ohne dass irgendwo steht, was sie erlaubt.
- `verifizierbar`: ja — `grep -c "^	@bash\|^	bash" Makefile` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:122-126`; `sed -n '129,136p' Makefile` (die
  `comment-claims`-Deklaration). Kein Gate deckt es (`docs-check` prüft Link-/Anker-Existenz, nicht
  Widerspruchsfreiheit).

### R2-2 — Festlegung 6 setzt einen bewusst fehlertoleranten Hook auf das Event, das den fail-closed Guard trägt, und lässt Event und Ausgabekanal offen; die Trennung existiert nur in der Prosa

- `kategorie`: **HIGH** (Basis MEDIUM, eine Stufe nach §Kontext-Eskalation des Reviewer-Skills —
  Beobachtung im Gate-/Sicherheitspfad)
- `quelle`: [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  (Guard fail-closed, Sub-Shell-Prüfung) ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  („laut falsch schlägt leise falsch") · [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  `modul-04-architektur-adrs.md` §Kernidee
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:139-152` (Festlegung 6, besonders
  `:141` „kein blockierender Exit-Code" und `:149-151` „Der Unterschied zum Guard liegt in der
  Aufgabe") gegen `:110-112` (Festlegung 4 lässt Event **und** Matcher offen)
- `befund`: Festlegung 6 begründet die Koexistenz von fail-open und fail-closed **mit der Aufgabe**
  („der Guard *verhindert*, die Telemetrie *beobachtet*") und regelt vom Mechanismus genau eine
  Größe: den Exit-Code. Offen bleiben die beiden Größen, an denen die Trennung tatsächlich hängt —
  **welches Event** (Festlegung 4: „entscheidet der umsetzende Slice") und **welcher Ausgabekanal**.
  Am 2026-07-28 direkt an der Quelle gemessen (<https://code.claude.com/docs/en/hooks>), verbatim:
  *„All matching hooks run in parallel, and identical handlers are deduplicated automatically"*;
  für `PreToolUse` **Exit 0**: *„Success. Claude Code parses stdout for JSON output. No decision
  means normal permission flow applies"*; `permissionDecision` kennt den Wert *„`allow` – allows
  the tool call"*; und für den Konfliktfall hält dieselbe Quelle fest, dass eine Aggregationsregel
  für widersprüchliche Entscheidungen **nicht dokumentiert** ist. Damit gilt: registriert der Slice
  die Erfassung auf `PreToolUse` — was die ADR ausdrücklich zulässt und ihr eigener Kontext (`:39`,
  leerer Matcher trifft alle Tools) nahelegt —, läuft ein Skript, dessen Normalpfad nach
  Festlegung 6 **Exit 0** ist, **parallel** zum Guard auf demselben Entscheidungskanal, ohne
  festgelegte Reihenfolge. Die ADR sagt an keiner Stelle, dass der Emitter auf stdout schweigen
  muss oder auf ein Nach-Event gehört, obwohl sie im Kontext (`:34-36`) selbst feststellt, dass ein
  Nach-Event mit dem Tool-Ergebnis existiert.
  Failure-Szenario: der Emitter wird fail-open gebaut wie verlangt (jeder Fehler → Exit 0,
  Diagnose auf stdout statt stderr, oder — der naheliegendste Fehler eines JSONL-Schreibers — ein
  Span-Objekt landet bei fehlendem/nicht schreibbarem Ablageort auf stdout). Auf `PreToolUse` wird
  dieser stdout als Entscheidungsdokument geparst; im günstigen Fall ist er kein gültiges Schema
  und wird ignoriert, im ungünstigen trägt er ein Feld, das die normale Permission-Prüfung
  beeinflusst — und was bei widersprüchlichen Entscheidungen zweier paralleler Hooks passiert, ist
  in der von der ADR selbst als ungepinnt markierten Quelle nicht festgelegt. Der fail-closed
  Boden aus [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  hängt dann an einer undokumentierten Aggregation. Das ist wortgleich die Konstellation, die bei
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) die zweite Runde gefunden hat: ein fail-OPEN-Pfad,
  entstanden beim Beheben eines anderen Befunds.
- `verifizierbar`: nein — die ADR trifft die Aussage nicht, also kann kein Lauf sie bestätigen;
  per Lektüre gegen die abgerufene Quelle feststellbar. (Nach Umsetzung wäre es ein bats-Fall:
  Emitter schreibt auf stdout → wird der Guard-Boden noch gehalten?)

### R2-3 — Folgepflicht 4 ist die einzige Absicherung gegen den stillen Teilverlust, hat keinen Sensor, und ist im Timeout-Fall vom Emitter selbst gar nicht erfüllbar

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Eine Zusage … ist erst fertig, wenn benannt ist,
  was passieren müsste, damit sie bricht, und das einmal rot gesehen wurde") ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  `modul-04-architektur-adrs.md` §Ziel-Form („Jede Entscheidung mit Architektur-Wirkung bekommt
  eine Fitness Function — sonst ist sie Absichtserklärung")
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:191-194` (Folgepflicht 4) gegen
  `:198-204` (Fitness-Function-Tabelle — fünf Zeilen, keine davon misst die Sichtbarkeit) und
  `:141-143` (der eigene harte Timeout)
- `befund`: Festlegung 6 erzeugt einen Zustand, den es vorher nicht gab: einen **Teilverlust**, der
  den Lauf nicht stört. Die ADR sieht ihn und benennt die Gefahr wörtlich — *„sonst entsteht ein
  Log, das lückenhaft ist und vollständig aussieht"* — und setzt dagegen **einen Satz**: der
  Verlust werde sichtbar gemacht, *„wie die Sichtbarkeit aussieht … entscheidet der umsetzende
  Slice; **dass** es sie gibt, entscheidet diese ADR."* Die Fitness-Function-Tabelle bekommt in
  derselben Überarbeitung drei neue Zeilen — für Ablageort, Dateimodus und fail-open — und **keine**
  für Folgepflicht 4. Verschärfend ist die Mechanik: der von Festlegung 6 verlangte *eigene harte
  Timeout* endet für den Emitter im Abbruch; ein abgebrochener Prozess kann seinen eigenen
  Verlust nicht mehr protokollieren. Die Sichtbarkeit bräuchte also einen **zweiten**, außerhalb
  des Emitters liegenden Zähler — eine Konstruktion, die die ADR nicht nennt und deren Existenz
  sie zugleich zusagt. Nach dem Vokabular dieses Repos ist das die Klasse „Zusage weiter als
  Abdeckung", die [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  §Setzung 2 an sich selbst schon einmal protokolliert hat.
  Failure-Szenario: der Emitter läuft in 3 von 400 Tool-Calls einer Sitzung in seinen Timeout
  (Plattenlast, ein großer `Write`-Payload, ein blockierendes `flock`). Der Lauf merkt nichts —
  genau wie gewollt. Die JSONL-Datei enthält 397 lückenlos aussehende Zeilen; kein Feld, kein
  Zähler und kein Gate weist die drei fehlenden aus. slice-060 summiert daraus eine Token-Bilanz
  je Rolle und trägt sie in die Closure-Matrix von welle-09 als „Sensor" ein. Der Beleg für die
  Vollständigkeit fehlt nicht — er ist unbemerkt falsch. Das ist derselbe Ausgang, den Runde 1 als
  zweite Hälfte von F-2 beschrieben hat („Exit 0 bei jedem Fehler, Spans fehlen lückenhaft, niemand
  merkt es"), jetzt als **entschiedener** Zustand statt als Lücke.
- `verifizierbar`: ja, am Artefakt — `grep -c "Verlust\|sichtbar" ` in der
  Fitness-Function-Tabelle → 0; die Abwesenheit einer Zeile ist per Lektüre feststellbar. Kein
  Gate deckt es (`make docs-check` → 230/0 mit der Folgepflicht im Baum).

### R2-4 — Die neue Fitness-Function-Zeile „Fail-open belegt" nennt `make test` für eine Eigenschaft, die bats nicht beobachten kann — und deren Timeout-Hälfte die zitierte Quelle nicht dokumentiert

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 (Falsch-Beispiel: „‚Byte-Gleichheit belegt `make smoke`',
  ohne `smoke` gelesen zu haben") · ADR-0011 §Re-Evaluierungs-Trigger 1 (die Quelle ist ungepinnt)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:204` (fünfte Zeile)
- `befund`: Die Zeile sagt zu, ein absichtlich fehlschlagender Emitter *„lässt den Tool-Call
  **durch**"*, und nennt als Target `make test` (bats). Was ein bats-Fall beobachten kann, ist das
  Verhalten **des Skripts** (Exit-Code, Laufzeit, Dateiwirkung). Ob daraufhin *der Tool-Call
  durchgelassen wird*, ist eine Eigenschaft des **Agenten-Werkzeugs** — sie folgt erst über die
  Exit-Code-Semantik der Hook-Oberfläche, also über genau die Quelle, die dieselbe ADR in
  Trigger 1 als *nicht gepinnt und von keinem Gate geprüft* kennzeichnet. Für die zweite,
  ausdrücklich getrennt geführte Hälfte (*„und getrennt: Überschreiten des eigenen Timeouts"*)
  fällt auch diese Ableitung aus: an der Quelle am 2026-07-28 nachgeschlagen ist `timeout`
  dokumentiert als *„Seconds before canceling"* mit 600 s Default für `command`-Hooks — **was mit
  dem Tool-Call geschieht, wenn ein `PreToolUse`-Hook gecancelt wird, steht dort nicht.** Die
  Zeile sagt also „belegt" zu einer Eigenschaft, deren tragende Hälfte weder gemessen noch
  dokumentiert ist. Das ist die Klasse des Runde-1-HIGH F-1, eine Tabellenzeile weiter unten und
  eine Stufe schwächer: das Target existiert und wird für den Skript-Teil real rot — der
  **behauptete** Gegenstand reicht darüber hinaus.
  Failure-Szenario: der Verifier hakt die Fitness Function mit einem grünen `make test` ab, in dem
  ein bats-Fall prüft, dass das Emitter-Skript bei Fehler mit 0 endet. Die Zusage „der Tool-Call
  wird durchgelassen" ist damit **nicht** gemessen; ändert das Werkzeug seine
  Cancel-Semantik — der Fall, den Trigger 1 ausdrücklich vorsieht —, bleibt `make test` grün,
  während jeder Timeout des Emitters den Lauf anhält. Der Sensor meldet dann nichts, weil er die
  Eigenschaft nie gemessen hat.
- `verifizierbar`: ja — <https://code.claude.com/docs/en/hooks> §Timeout gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:204`. Kein Gate deckt es (`docs-check` läuft
  `--network none`).

### R2-5 — „Lebensdauer: die Sitzung" benennt eine Lebensdauer ohne einen Mechanismus, der sie beendet; der Satz „kein wachsender Bestand" ist am eigenen Entwurf falsch

- `kategorie`: **MEDIUM**
- `quelle`: Runde-1-Befund F-6 (Aufbewahrung) · `modul-15-observability.md` §Audit-Span-Schema ·
  ADR-0011 §Kontext (`:54-56`, „Audit- und Kosten-Instrument") · Maintainability
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:103-105`
- `befund`: Runde 1 beanstandete an Festlegung 3, dass die Spans „flüchtig" **genannt** wurden,
  ohne dass etwas sie flüchtig macht. Die Überarbeitung ersetzt das Wort durch *„Lebensdauer: die
  Sitzung. Spans werden je Sitzung neu angelegt statt fortgeschrieben; ein Lauf hinterlässt keinen
  wachsenden Bestand."* Das ist keine andere Regel, sondern dieselbe Lücke mit präziserem
  Vokabular: „je Sitzung neu angelegt" bestimmt, **wie** geschrieben wird, nicht **wann gelöscht**.
  Nichts löscht — gemessen: der Makefile kennt kein Aufräum-Target für `.harness/state/`
  (Volltextsuche, 0 Treffer), `harness/tools/record-gates.sh` legt das Verzeichnis nur mit
  `mkdir -p` an, und die ADR benennt weder einen Löschenden noch einen Zeitpunkt. Die Folge kehrt
  die Zusage sogar um: **eine Datei je Sitzung** ist per Konstruktion ein wachsender Bestand — die
  einzelne Datei wächst nicht, ihre Anzahl schon. Der Halbsatz *„Wer sie aufheben will, kopiert sie
  bewusst heraus"* setzt eine Löschung voraus, die der Text nirgends anordnet; und für den
  Absturzfall (Sitzung endet ohne Abschluss) gibt es weder eine Aussage noch einen Aufräumer.
  Failure-Szenario: nach Wochen Dogfood liegen unter `.harness/state/` mehrere hundert
  Span-Dateien mit Pfaden und allowlist-passierten Argumenten — jede korrekt `0600`, keine je
  gelöscht, keine von einem Gate gemessen. Der Ort ist gitignoriert, also fällt es niemandem auf;
  bei jedem `tar`/Backup/Container-Mount des Arbeitsverzeichnisses wandert der Bestand mit. Der
  Runde-1-Befund F-6 ist damit in seiner Kern-Hälfte nicht behoben, sondern umformuliert.
- `verifizierbar`: ja — Volltextsuche nach einem Aufräum-Target im Makefile (0 Treffer);
  `cat harness/tools/record-gates.sh`. Kein Gate deckt es.

### R2-6 — Festlegung 1 macht den Startzustand zu genau der Abweichung, die die ADR selbst als begründungspflichtig bezeichnet — ohne Begründung und ohne Auslöser

- `kategorie`: **MEDIUM**
- `quelle`: `modul-15-observability.md` §Span-/Audit-Attribut-Regeln („Pflicht-Minimum … jede
  Abweichung davon begründest du") · Vorbefund F-2 (HIGH) aus
  [`2026-07-28-welle-09-plan-review.md`](2026-07-28-welle-09-plan-review.md) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:70-72` (Policy-Punkt 1) gegen `:75-77`
  (Punkt 3) und `:161` (Alternative E, Contra-Spalte)
- `befund`: Punkt 1 erklärt **beide** Modul-15-Listen für bindend, *„keine darf gegen die andere
  ausgespielt werden"* — die Mindestfelder eines Tool-Call-Spans enthalten laut Modul 15
  ausdrücklich `tool.arguments` (redacted). Punkt 3 setzt fest: *„Die Argument-Allowlist beginnt
  LEER."* Die ADR sagt an dritter Stelle selbst, was das bedeutet: die E-Zeile der
  Alternativen-Tabelle nennt das Weglassen von `tool.arguments` *„eine begründungspflichtige
  Abweichung"* und erklärt im selben Satz die leere Allowlist zum **Startzustand**. Die Begründung,
  die derselbe Satz für nötig hält, liefert die ADR nicht — und Punkt 4, der die Abweichungspflicht
  operationalisiert, deckt den Fall nicht ab: er greift für ein *„nicht erschließbares"*
  Pflicht-Feld, während `tool.arguments` erschließbar ist und bewusst nicht erfasst wird. Die
  Abweichungs-Begründung, die Modul 15 verlangt, hat damit **keinen Auslöser**.
  Failure-Szenario: slice-059 liefert einen Span, der nur Korrelations-IDs trägt. Der Verifier
  prüft Festlegung 1.4, findet kein *nicht erschließbares* Pflicht-Feld — `tool.arguments` liegt ja
  vor —, hakt ab; die Closure-Matrix von welle-09 trägt für Block 1/Repo „Sensor", und die vom
  Modul verlangte Begründung für das Fehlen eines Mindestfeldes ist nie geschrieben worden. Das ist
  der HIGH-Befund F-2 des welle-09-Plan-Reviews („eine verkürzte Feldliste, deren Fehlen die
  Begründungspflicht nicht auslöst") — diesmal nicht aus Versehen, sondern als Startzustand der
  ADR, die ihn beheben sollte.
- `verifizierbar`: nein — Konsistenz-Urteil innerhalb desselben Dokuments, per Zitat-Abgleich mit
  `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:33-34` feststellbar.

### R2-7 — Zwei der neuen Quadranten-Kennzeichnungen behaupten einen Sensor, den es nicht gibt

- `kategorie`: **MEDIUM**
- `quelle`: `grundlagen-klassifikation.md` §Quadranten (verbatim: *„**Feedback** (Sensor,
  detektiv)"*; *„Computational + Feedback: erkennt falsche Aktionen schnell und deterministisch.
  Das sind die Gates"*) · `modul-07-carveouts.md` §Auflösungs-Trigger · Vorbefund F-8 aus Runde 1
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:230` (Trigger 3) und `:236`
  (Trigger 5), im Kontrast zu `:223` / `:233` / `:240` (dort ist die Kennzeichnung korrekt)
- `befund`: Runde 1 verlangte, die Trigger 2/4/5 mit derselben Ehrlichkeit zu kennzeichnen wie
  Trigger 1 („wirkt nur, wenn ihn jemand liest"). Die Überarbeitung hat Kennzeichnungen ergänzt —
  drei davon korrekt als *feedforward — kein Sensor*, zwei aber als **feedback**: *„Wenn Spans
  emittiert werden sollen (slice-062) *(feedback — der CR ist der Auslöser)*"* und *„Wenn die
  Erfassung den Lauf messbar bremst *(feedback — die Messung liegt im Slice)*"*. Nach dem
  Wortlaut der Klassifikation ist Feedback die **Sensor**-Achse. Ein Change Request ist ein
  menschlicher Vorgang, kein Sensor; und eine Messung, die **innerhalb** eines Slice einmal
  stattfindet, ist nach dessen `git mv` nach `done/` kein stehender Sensor mehr — nichts im Repo
  misst danach je wieder den Aufschlag je Tool-Call. Die Nachbesserung ist damit in den zwei Fällen
  **großzügiger** als die Wirklichkeit, in denen ein Leser sich auf sie verlassen würde; die drei
  ehrlich gekennzeichneten sind gerade die harmlosen.
  Failure-Szenario: welle-09 schließt, slice-059/060 wandern nach `done/`. Ein späterer Leser der
  ADR sieht bei „bremst den Lauf messbar" die Kennzeichnung *feedback* und schließt daraus, dass
  ein Sensor die Bedingung überwacht; er richtet keine Wiedervorlage ein. Der Aufschlag wächst mit
  jedem neuen Allowlist-Feld, niemand misst, der Trigger feuert nie — der permanente Carveout aus
  Modul 7, hier in der Form eines fehlklassifizierten Trigger-Eintrags.
- `verifizierbar`: ja — `sed -n '10,20p' .harness/baseline/v3.5.2/regelwerk/grundlagen-klassifikation.md`
  gegen `docs/plan/adr/0011-telemetrie-erfassung-policy.md:230` und `:236`. Kein Gate deckt es.

### R2-8 — Die zwei neuen Schwellen sind keine Schwellen: eine verweist auf einen Wert, den es nicht gibt, die andere ersetzt „regelmäßig" durch „dauerhaft"

- `kategorie`: **MEDIUM**
- `quelle`: `modul-07-carveouts.md` §Ziel-Form („Auflösungs-Trigger als beobachtbare, **messbare**
  Bedingung … eine Schwelle, die ein anderer Mensch **ohne Rückfrage** als erreicht beurteilen
  kann") · Vorbefund F-8 aus Runde 1
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:236-239` (Trigger 5) und `:240-242`
  (Trigger 6)
- `befund`: Trigger 5 lautet *„**Schwelle** ist der im Slice gemessene Aufschlag je Tool-Call;
  überschreitet er den dort festgelegten Wert …"* — die Bedingung ist auf sich selbst bezogen: sie
  feuert, wenn ein Wert überschritten wird, den ein anderes Artefakt erst noch festlegen soll.
  Gemessen: slice-059 §3 Messung E nennt eine **Anzahl** (189 Tool-Calls, ~380 Hook-Starts) und
  **keine** Grenze; slice-059 enthält keinen Zahlenwert für den zulässigen Aufschlag. Ein Leser,
  der die Bedingung beurteilen soll, muss also erst ein Artefakt suchen, das den Wert noch nicht
  trägt, und das nach `done/` wandert. Trigger 6 („Wenn die leere Start-Allowlist **dauerhaft**
  leer bleibt") ersetzt das von Runde 1 als unbrauchbar verworfene „regelmäßig" durch „dauerhaft":
  kein Zeitraum, kein Beobachter, kein Kommando. Von den beiden in Runde 1 beanstandeten
  Trigger-Mängeln ist damit einer behoben (Trigger 2, s. u.) und einer im Wortlaut verschoben.
  Failure-Szenario: der Aufschlag je Tool-Call verdoppelt sich, nachdem die Allowlist gewachsen
  ist. Niemand kann sagen, ob die Schwelle erreicht ist, weil keine existiert; die Re-Evaluierung
  findet nicht statt, und die ADR steht als *Accepted* mit einer Trigger-Zeile, die formal erfüllt
  aussieht. Modul 7 nennt das den permanenten Carveout, der lügt.
- `verifizierbar`: ja — Volltextsuche nach einer Zahl mit Zeit-Einheit in
  `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` → nur die Call-Zählungen der <!-- d-check:ignore (Lifecycle-Pfad) -->
  Messung E, keine Grenze. Kein Gate deckt es.

### R2-9 — Die als falsch nachgewiesene `LH-QA-03`-Lesart wurde nur in der ADR korrigiert; slice-059 und welle-09 tragen sie weiter, und die ADR widerspricht ihnen jetzt direkt

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Rang 1,
  [`AGENTS.md`](../../AGENTS.md) §2) · Vorbefund F-4 aus Runde 1 (der die Doppelverteilung
  **ausdrücklich benannt hat**) · Drift-Klasse „derselbe Stand an zwei Orten, einer altert"
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:16` und `:37-38` und <!-- d-check:ignore (Lifecycle-Pfad) -->
  `:126` · `docs/plan/planning/welle-09-modul-15-konformitaet.md:189` und `:193` — gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:110-120`
- `befund`: Die ADR erklärt die alte Lesart in einer eigenen Klammer für erledigt: *„(Diese Fassung
  korrigiert Runde 1, die dieselbe Anforderung auf das Ziel verengt und ihren Wortlaut um `bash`
  erweitert hatte — **beides falsch**, vom Proposed-Review nachgewiesen.)"* Der Diff `bbbc0c2`
  ändert an slice-059 jedoch **eine** Zeile (den `tool_output`-Feldnamen) und an welle-09 fünf
  (den ADR-Rückverweis). Gemessen stehen dort unverändert: slice-059 §Bezug — „[`LH-QA-03`] (**bash+awk**,
  keine neue Abhängigkeit)"; slice-059 §1 — „im emittierten Ziel gilt **zusätzlich** [`LH-QA-03`]
  (über `bash + git + docker` hinaus nichts) — **die schärfere Grenze bindet erst slice-063, nicht
  diesen Slice**"; welle-09 §6 — „im Repo Docker-only, im Ziel zusätzlich [`LH-QA-03`]
  (`bash + git + docker`)". Beide Sätze sind genau die zwei Fehler, die die ADR für widerlegt
  erklärt, und der slice-059-Satz behauptet zusätzlich das Gegenteil der neuen Festlegung 4 (die
  Grenze binde diesen Slice **nicht**). Nach *Accepted* stünde eine Rang-3-Quelle gegen zwei
  Plan-Artefakte, die der Implementer laut Workflow (`AGENTS.md` §6, `CLAUDE.md`) zuerst liest.
  Failure-Szenario: der Implementer öffnet slice-059 — das Artefakt, auf das ihn der Workflow
  zeigt —, liest „die schärfere Grenze bindet … nicht diesen Slice" und baut gegen die widerlegte
  Randbedingung; oder der Autor von slice-062 liest welle-09 §6 und behandelt
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) als reine
  Ziel-Anforderung, während die ADR sie zur Repo-Grenze erklärt hat. Runde 1 hat die
  Doppelverteilung namentlich gemeldet; die Überarbeitung hat sie nicht aufgelöst.
- `verifizierbar`: ja — Volltextsuche nach `bash + git + docker` über
  `docs/plan/planning/` → zwei Treffer. Kein Gate deckt es.

### R2-10 — Die neue Geltungsbereichs-Aussage stützt sich auf eine Klausel, die den gezogenen Schluss nicht trägt: die Bindung an dieses Repo folgt aus der Tool-Build-Klausel, nicht aus der Bootstrap-Klausel

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (verbatim
  gelesen) · [`AGENTS.md`](../../AGENTS.md) §3.6 („die Zusage auf das einschränken, was der Code
  hält" — hier: was die Anforderung sagt) · [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:113-117`
- `befund`: Die ADR zitiert korrekt *„die Laufzeit **beim Bootstrap** braucht nur git + docker
  (keine Host-Sprachlaufzeit, kein Paketmanager)"* und schließt daraus: *„und das bindet **dieses
  Repo**, nicht nur das Ziel."* Der **Schluss** ist richtig — Runde 1 hat ihn belegt —, aber nicht
  aus dieser Klausel: der Nachsatz „beim Bootstrap" bindet die Aussage an die Laufzeit, die ein
  Nutzer braucht, um das Tool zu bootstrappen (die Messmethode derselben Anforderung sagt es
  wörtlich: *„Smoke: Binary auf frischem System mit nur git + docker → Bootstrap grün"*). Die
  Klausel, die dieses Repo bindet, ist die **nächste**: *„Der Tool-Build läuft reproduzierbar im
  gepinnten Image … kein Host-`go` (Docker-only)."* Die ADR fällt damit von der Verengung aus
  Runde 1 in die Gegenrichtung: sie überträgt die Bootstrap-Klausel auf ein Entwicklungs-Werkzeug
  dieses Repos, das mit dem Bootstrap eines Adopters nichts zu tun hat. Genau diese Übertragung
  ist die Wurzel von R2-1.
  Failure-Szenario: der Autor eines späteren Slice (oder ein Reviewer) prüft, ob eine geplante
  Mechanik gegen [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  verstößt, liest die ADR-Fassung, nimmt die Bootstrap-Klausel als allgemeine Repo-Grenze und misst
  Entwicklungs-Werkzeuge an einer Bedingung, die für die Nutzer-Laufzeit formuliert ist — mit dem
  Ergebnis, dass entweder der bestehende Bestand als Verstoß erscheint (R2-1) oder die Anforderung
  als beliebig dehnbar behandelt wird. Nach *Accepted* ist die Lesart zementiert
  ([`AGENTS.md`](../../AGENTS.md) §3.4), und
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  verbietet, sie über das Lastenheft zu korrigieren („weder ADR noch Slice dürfen `LH-*` je ändern").
- `verifizierbar`: ja — `sed -n '268,277p' spec/lastenheft.md` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:113-117`. Kein Gate deckt es (`docs-check`
  prüft Anker-Existenz, nicht Zitat-Anwendung).

### R2-11 — Der ADR-Index führt weiter `LH-QA-02` und beschreibt ADR-0011 als „Schema-Minimum", das Festlegung 1 gerade abgeschafft hat

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 („Neue ADRs aktualisieren den ADR-Index") ·
  Vorbefund F-11 aus Runde 1 · Drift-Klasse „derselbe Stand an zwei Orten"
- `pfad`: [`docs/plan/adr/README.md`](../plan/adr/README.md):19 gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:9-14` und `:64-68`
- `befund`: Die Überarbeitung entfernt
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) aus dem Bezug-Feld der ADR
  (Antwort auf Runde-1-F-11) und zieht den Index nicht nach: die Index-Zeile führt weiterhin
  `LH-QA-01, LH-QA-02, LH-QA-03`. Zusätzlich beschreibt der Index den Gegenstand als
  „**Schema-Minimum**, Allowlist-Redaktion, Ablage …", während Festlegung 1 in derselben
  Überarbeitung ausdrücklich festhält, dass die ADR **nicht** die Feldtabelle entscheidet, sondern
  die Policy, und die Tabelle in ein `MR-<NNN>` verlegt. Der Index verspricht damit genau das, was
  die ADR aufgibt.
  Failure-Szenario: wer über den Index sucht (der dafür da ist), erwartet in ADR-0011 ein
  Schema-Minimum und findet eine Policy; und eine spätere Änderung an
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) löst über den Index eine
  Nachzieh-Prüfung von ADR-0011 aus, die im Dokument selbst keinen Anknüpfungspunkt mehr hat.
- `verifizierbar`: ja — `grep -n "0011" docs/plan/adr/README.md` gegen das Bezug-Feld der ADR.
  Kein Gate deckt es (`docs-check` prüft Link-Auflösung, nicht Übereinstimmung zweier Listen).

### R2-12 — `LH-QA-01` steht mit zugewiesener Rolle im Bezug und kommt im Body weiterhin nicht vor

- `kategorie`: **LOW**
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form („Der Kontext *referenziert* die
  Anforderung") · Vorbefund F-11 aus Runde 1
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:11-12`
- `befund`: Das Bezug-Feld nennt jetzt für
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Rolle
  („jede Fitness Function unten muss rot werden **können**") — die Rolle steht aber **im
  Bezug-Feld selbst**, nicht im Body. Volltextsuche: `LH-QA-01` erscheint im gesamten Dokument nur
  in Zeile 11. Der Abschnitt „Was hier bewusst NICHT steht" (`:206-213`), der die Anforderung
  tragen würde, begründet die Streichungen mit [`AGENTS.md`](../../AGENTS.md) §3.6 und nennt
  `LH-QA-01` nicht. Die halbe Hälfte des Runde-1-Befunds ist behoben (LH-QA-02 entfernt), diese
  nicht.
  Failure-Szenario: eine spätere Änderung an
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) löst eine
  Nachzieh-Prüfung aus; der Prüfende findet außer der Kopfzeile keine Stelle, an der die
  Anforderung wirkt, und kann weder „betroffen" noch „unbetroffen" belegen.
- `verifizierbar`: ja — `grep -n "LH-QA-01" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → nur `:11`. Kein Gate deckt es.

### R2-13 — Die Contra-Spalte der gewählten Option C ist unverändert und führt die beiden Kosten weiterhin nicht, die die ADR an anderer Stelle als ihre größten benennt

- `kategorie`: **LOW**
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form („Mindestens drei Verglichene Alternativen,
  jede mit Trade-off") · zweite Hälfte des Runde-1-Befunds F-5
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:160` (Zeile C) gegen `:180-183`
  („Negativ, und jetzt der schärfere Punkt") und `:169-171`
- `befund`: Runde 1 beanstandete an der Alternativen-Tabelle **zwei** Dinge: die fehlende Option E
  und die **Asymmetrie** — A und D bekommen „keine neue Sicherheitsfläche" als *Pro*
  gutgeschrieben, während C's Contra-Spalte weder die Sicherheitsfläche noch die laufende
  Allowlist-Pflege führt, obwohl die ADR beide im Konsequenzen-Abschnitt als ihre größten Kosten
  benennt. Der Diff ergänzt E und lässt die C-Zeile **unverändert** (im Diff nicht enthalten). Die
  Asymmetrie wird durch E sogar schärfer: die neue E-Zeile führt „löst die Sicherheitsfläche fast
  vollständig auf" als *Pro*, direkt neben einer C-Zeile, die dieselbe Fläche nicht als Contra
  kennt.
  Failure-Szenario: ein Leser, der nur die Tabelle liest (wofür eine Vergleichstabelle da ist),
  entnimmt ihr, dass C keine Sicherheitskosten hat, und findet den entscheidenden Satz erst zwei
  Abschnitte später bei den Konsequenzen — oder gar nicht.
- `verifizierbar`: ja — `git show bbbc0c2 -- docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  enthält keine Änderung an der C-Zeile. Kein Gate deckt es.

### R2-14 — Der neue `0600`-Modus schützt das Lesen, nicht den Bestand: das Zustands-Verzeichnis ist gruppenschreibbar

- `kategorie`: **INFO**
- `quelle`: Runde-1-Befund F-6 · ADR-0011 Festlegung 3 (`:100-102`)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:100-102`
- `befund`: Die ADR nennt die Messung korrekt (`.harness/state/` ist `775`, die Stempeldatei `664`
  — eigene Messung 2026-07-28 bestätigt: `drwxrwxr-x` bzw. `-rw-rw-r--`) und entscheidet den
  **Datei**-Modus. Das Verzeichnis bleibt unangetastet und ist gruppenschreibbar; das Löschen und
  Ersetzen einer Datei hängt am Schreibrecht des **Verzeichnisses**, nicht der Datei. Ein `0600`
  Span-File in einem `0775` Verzeichnis ist also gegen Mitlesen geschützt und gegen Entfernen oder
  Unterschieben nicht. Der Befund bleibt **INFO**, weil Festlegung 3 dritter Punkt („Kein
  Beleg-Status") die Integritäts-Anforderung ausdrücklich absenkt — ein Span ist keine Beleg-Quelle
  im Sinne von [`AGENTS.md`](../../AGENTS.md) §3.6. Dokumentationswürdig ist, dass die ADR die
  gemessene Rechte-Lage als Problem benennt und nur ihre Lese-Hälfte auflöst.
- `verifizierbar`: ja — `ls -ld .harness/state/`. Kein Gate deckt es.

### R2-15 — E ist zugleich verglichene Alternative und Startzustand der gewählten Option; die C/E-Achse ist offen, und die ADR sagt das selbst

- `kategorie`: **INFO**
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form · ADR-0011 §Entscheidung (`:60-62`) gegen
  `:161` und `:240-242`
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:161`, `:240-242`
- `befund`: Die E-Zeile erklärt: *„E ist der **Grenzfall von C** — mit leerer Allowlist *ist* C
  genau E"*, und Trigger 6 räumt ein, dass eine dauerhaft leere Allowlist bedeutet, „faktisch
  Alternative E" zu betreiben, weshalb „die Wahl zwischen C und E ausdrücklich zu wiederholen"
  sei. Damit ist die im Entscheidungssatz getroffene Wahl **nicht** die Wahl zwischen C und E: was
  wirklich entschieden ist, ist der Ort (Festlegung 3), die Richtung der Redaktion (Festlegung 2),
  die Betriebs-Fehlerrichtung (Festlegung 6) und die **Regel, unter der Felder hinzukommen**
  (Festlegung 1.3) — nicht der Umfang. Das ist als Entscheidung tragfähig und wird hier
  ausdrücklich **nicht** als Formmangel geführt: Modul 4 verlangt ≥ 3 Alternativen mit Trade-off,
  und mit A/B/C/D/E sind es fünf, jede mit Pro und Contra. Festgehalten wird nur, dass der Satz
  „Wir wählen Option C" weniger trägt, als er klingt — die Umfangs-Achse bleibt beim umsetzenden
  Slice, und die ADR benennt das offen (was der ehrliche Weg ist). Der operative Rest dieser
  Konstruktion ist als R2-6 geführt.
- `verifizierbar`: nein — Lesart-Urteil, per Lektüre gegen den eigenen Trigger 6 feststellbar.

## Negativbefunde

### Runde-1-Befunde, die **sauber gelöst** sind

- geprüft, ohne Befund: **F-1 (HIGH) ist vollständig und richtig gelöst.** Beide tautologischen
  Zeilen sind weg (`working-tree-hash unverändert` und `git status --porcelain unverändert`), die
  Streichung ist **mit ihrer Begründung dokumentiert** (`:206-213`, inklusive des
  `--exclude-standard`-Mechanismus, der sie tautologisch machte), und die Ersatz-Zeile bewacht die
  Eigenschaft wirklich: „Ablageort auf einen nicht-ignorierten Pfad ziehen ⇒ der Wächter muss rot
  werden" ist im vorhandenen Mutations-Harness ausführbar — gemessen an
  `harness/tools/mutate.sh` §`narrow_sensor`: ein Fall trägt `# files:` + `# expect:`, und ein
  `# expect:`, das keinen `Test[A-Z]*`-Namen nennt, fährt die bats-Stufe. Das ist der stärkste
  Teil dieser Überarbeitung, und er ist **nicht** anzufassen.
- geprüft, ohne Befund: **F-7 (Festlegung 5 halbverbindlich) ist gelöst.** „Portabel gemeint" ist
  ersetzt durch eine eindeutige Setzung: *„das **OB** der Emission entscheidet der Change Request,
  das **WIE** entscheidet diese ADR"*, mit Aufzählung dessen, was im Ziel gilt, und mit
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  als Begründung für die strengere Seite. Die von Runde 1 beanstandete Zweideutigkeit („weder
  bindend noch unverbindlich") existiert nicht mehr; die gewählte Lesart ist die, die
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  respektiert, weil der CR seinen Gegenstand (das *Ob*) behält.
- geprüft, ohne Befund: **F-9 (LOW, `tool_response`) ist gelöst — und vorbildlich.** slice-059
  Messung A nennt jetzt `tool_output`/`tool_output_path` und **benennt die Herkunft des eigenen
  Fehlers** („ein Feldname aus einer zusammenfassenden Abfrage statt aus dem Volltext"), statt ihn
  stillschweigend zu glätten. Der einzige verbliebene `tool_response`-Treffer ist genau dieser
  Korrektur-Satz.
- geprüft, ohne Befund: **F-10 (LOW, einseitiger Verweis) ist gelöst.** welle-09 §4 nennt
  ADR-0011 jetzt beim Namen (`welle-09-modul-15-konformitaet.md:172`, mit Status und Rundenstand);
  der Rückverweis ist beidseitig.
- geprüft, ohne Befund: **F-8, Teil „Trigger 2 ist bei Abfassung bereits erfüllt", ist gelöst.**
  Der Trigger trägt jetzt eine Bedingung, die heute **nicht** erfüllt ist und die ein Dritter ohne
  Rückfrage beurteilen kann: „sobald ein Auswertungs-Slice (060) eine Zahl *je Rolle* ausweisen
  soll". Beanstandet werden nur die zwei **anderen** Trigger (→ R2-7, R2-8).

### Runde-1-Befunde, die **teilweise** gelöst sind (und wo der Rest steht)

- geprüft, mit Einschränkung: **F-2 (HIGH) ist als Lücke geschlossen — die Antwort erzeugt drei
  neue Befunde.** Es gibt jetzt eine Entscheidung zu Fehlschlag und Timeout, samt real benannter
  und begründet verworfener Gegen-Entscheidung (fail-closed Audit in regulierten Umgebungen). Das
  ist die Form, die Modul 4 verlangt, und der Inhalt ist für dieses Repo plausibel begründet. Was
  die Antwort **mitbringt**, steht als R2-2 (Kollisionsfläche mit dem Guard), R2-3 (stiller
  Teilverlust ohne Sensor) und R2-4 (die Fitness Function dazu).
- geprüft, mit Einschränkung: **F-3 (Festlegung 1 = Wiedergabe) ist zur Hälfte gelöst.** Neu und
  echt ist **eine** Setzung: „Die Argument-Allowlist beginnt LEER" — sie hat eine Gegenposition
  („was verfügbar ist, wird erfasst"), sie ist operativ, und sie schneidet den Umfang. Die
  Delegation der Feldtabelle in ein `MR-<NNN>` ist außerdem nicht mehr versteckt, sondern
  **deklariert und begründet** („eine ab *Accepted* immutable ADR ist der falsche Ort für eine
  wachsende Tabelle") — das ist eine tragfähige Antwort auf „Wiedergabe statt Entscheidung". Der
  Rest steht als R2-6: der so gesetzte Startzustand ist die Abweichung, die die ADR selbst für
  begründungspflichtig hält.
- geprüft, mit Einschränkung: **F-4 (`LH-QA-03`) ist in seinen zwei konkreten Punkten korrigiert
  und dabei überkorrigiert.** `bash` steht nicht mehr im Zitat, der Geltungsbereich ist nicht mehr
  auf das Ziel verengt — beides richtig. Neu: die Bindung wird aus der falschen Klausel abgeleitet
  (R2-10), die Folgerung widerspricht sich selbst (R2-1), und die Plan-Artefakte tragen die
  widerlegte Fassung weiter (R2-9).
- geprüft, mit Einschränkung: **F-5 (fehlende Alternative E) ist in der Sache gelöst,** die
  Alternative ist mit Pro und Contra ergänzt und ihre Beziehung zu C ausgesprochen. Die zweite
  Hälfte des Befunds (asymmetrische Contra-Spalte von C) ist unangetastet → R2-13.
- geprüft, mit Einschränkung: **F-6 (Aufbewahrung/Rechte) ist zur Hälfte gelöst.** Der Dateimodus
  ist entschieden (`0600`, vom Emitter selbst gesetzt), und er hat mit
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:203` eine Fitness-Function-Zeile bekommen, die
  in bats real rot werden kann. Die Aufbewahrung ist umformuliert, nicht geregelt (R2-5), und die
  Verzeichnis-Hälfte bleibt offen (R2-14).

### Sonstige geprüfte Bereiche ohne Befund

- geprüft, ohne Befund: **Form nach Modul 4 und Vorlage.** Alle Kopf-Felder vorhanden (Status ·
  Datum · Autor · Bezug · Schärft); Body-Blöcke vollständig und in Vorlagen-Reihenfolge (Kontext ·
  Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger · Geschichte); **fünf** Alternativen (≥ 3), jede mit Pro **und** Contra;
  Konsequenzen führen Positiv, Negativ und vier Folgepflichten getrennt. Die Alternativen-Tabelle
  listet E zwischen C und D statt am Ende — das ist Lesereihenfolge, keine Regelverletzung, und
  wird ausdrücklich **nicht** als Finding geführt (kein Konventions-Anker).
- geprüft, ohne Befund: **`Geschichte`-Eintrag.** Die neue Zeile führt Datum, Ereignis
  („Überarbeitet (Runde 2), weiter **Proposed**") und Verweis auf den Runde-1-Report samt
  Befundzahlen und Verdikt, und benennt die eigenen Fehler **inhaltlich** statt nur zu zählen. Das
  entspricht der Vorlage und der Präzedenz aus
  [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md). Der Status ist **nicht** vorgreifend
  auf *Accepted* gesetzt — im Dokument (`:3`) und im Index gleichermaßen **Proposed**.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4 und §3.5.** Die Überarbeitung
  betrifft eine *Proposed*-ADR, überschreibt keine *Accepted*-ADR und beansprucht kein
  *Supersedes*. Sie lockert **kein** Gate: Festlegung 6 regelt das Verhalten eines **künftigen,
  noch nicht existierenden** Hooks; `.claude/settings.json` ist im Diff unberührt (gemessen), der
  fail-closed Guard und der Stop-Hook sind unverändert. „fail-open" ist hier keine Senkung einer
  bestehenden Schwelle, sondern die Richtungswahl für einen neuen Bestandteil — ein ADR ist dafür
  der richtige Ort, nicht der Fehler. Beanstandet wird ausschließlich, dass die Trennung zum Guard
  nur behauptet ist (→ R2-2).
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  zum jetzigen Zeitpunkt.** `git show bbbc0c2 --name-only` → vier Dateien, **kein**
  `spec/lastenheft.md`. Die ADR ändert kein `LH-*`, sie referenziert nur; der CR bleibt korrekt bei
  slice-062 verortet und behält mit dem *Ob* einen echten Gegenstand. Ein CR ist jetzt nicht fällig.
- geprüft, ohne Befund: **Kollision mit aktiven ADRs — weiterhin keine.**
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) bindet den **Tool-Build** (Cross-Compile,
  kein Host-`go`) und wird von einem Hook-Skript nicht berührt;
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) hat den Container-Weg für Hooks aus
  Latenzgründen ausdrücklich verworfen und trägt die bash/awk-Bauart, an die Festlegung 4 anknüpft;
  [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) und
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) sind unberührt. Beanstandet wird die
  **Herleitung** der Randbedingung (→ R2-1, R2-10), nicht ein Widerspruch zu einer aktiven
  Entscheidung.
- geprüft, ohne Befund: **Festlegung 2 (Allowlist statt Denylist) ist unverändert und bleibt der
  tragfähigste Teil.** Der Diff fasst sie nicht an; die Begründung („eine Denylist kann unter keiner
  **realen** Lücke rot werden") hält, und sie ist mit der
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Linie
  konsistent.
- geprüft, ohne Befund: **Festlegung 3, Ort und Herleitung.** Die
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Kollision
  ist real und der gewählte Ort richtig; das ist in Runde 1 bereits geprüft und durch die
  Überarbeitung nicht verändert worden. Beanstandet werden nur die neuen Auflagen (→ R2-5, R2-14).
- geprüft, ohne Befund: **Fitness-Function-Zeilen 1–4 sind red-fähig.** Zeile 1 und 2 (Pflicht-Feld,
  Allowlist) sind unverändert und in Runde 1 bereits als prüfbar bestätigt; Zeile 3 (Ablageort) ist
  gegen das reale Mutations-Harness geprüft (s. o.); Zeile 4 (`0600` unabhängig von den
  Verzeichnis-Rechten) ist in bats direkt beobachtbar — Verzeichnis permissiv setzen, Emitter
  laufen lassen, Modus der erzeugten Datei prüfen. Beanstandet wird ausschließlich Zeile 5
  (→ R2-4). Einschränkung, die **nicht** als eigener Befund geführt wird: solange Festlegung 1 die
  Feldtabelle ausdrücklich delegiert, hat Zeile 1 weiterhin keinen definierten Gegenstand — das ist
  in R2-6 mitbehandelt.
- geprüft, ohne Befund: **Doc-Gate-Regeln.** Eigener Lauf dieser Sitzung: `make docs-check` →
  **d-check 230 Dateien, 0 Befunde** (Stand vor diesem Report). Alle `LH-`/`ADR-`/`MR-`-Kennungen
  in der überarbeiteten ADR sind als Link geführt; die relativen Tiefen aus `docs/plan/adr/`
  stimmen; die neu genannten Inline-Pfade existieren.
- geprüft, ohne Befund: **die Hook-Oberflächen-Aussagen des Kontexts wurden nicht verändert** und
  sind in Runde 1 zweifach an der Quelle bestätigt worden; diese Runde hat die Quelle ein drittes
  Mal abgerufen, gezielt zu den **neuen** Aussagen der Festlegung 6 — die „600 s"-Angabe der ADR
  ist am Original bestätigt (`command`-Hooks, Standard-Events). Der Befund R2-4 betrifft **nicht**
  diese Zahl, sondern die daraus **nicht** ableitbare Cancel-Wirkung.
- geprüft, ohne Befund: **die Annahme im Kontext (`:54-56`) und `Schärft: —`** sind unverändert
  und in Runde 1 geprüft; die Überarbeitung berührt beide nicht.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 3 |
| MEDIUM | 7 |
| LOW | 3 |
| INFO | 2 |

**Herkunft der Befunde:** **10** von 15 existieren erst seit der Überarbeitung (R2-1 bis R2-8,
R2-10, R2-11) — davon drei als **Umformulierung** eines Runde-1-Befunds, die dessen Kern nicht
auflöst (R2-5, R2-7, R2-8). **4** sind unerledigte Reste aus Runde 1, die der Diff nicht angefasst
hat (R2-9, R2-12, R2-13, R2-14). **1** ist eine Einordnung ohne Handlungsdruck (R2-15).

## Verdikt

**Kann ADR-0011 in dieser Fassung auf *Accepted* gesetzt werden: nein.**

**Was blockiert — und die Antwort auf die Leitfrage dieser Runde lautet: der Fix selbst.** Zwei der
drei HIGH sind **Kinder der Überarbeitung**, und beide sitzen in der neuen Festlegung 6, also im
größten Eingriff:

**R2-2** ist der schwerste. Die ADR begründet die Koexistenz von fail-open und fail-closed mit der
*Aufgabe* der beiden Hooks — und regelt vom *Mechanismus* nur den Exit-Code, während sie Event und
Matcher (Festlegung 4) ausdrücklich offenlässt. An der Quelle gemessen laufen alle passenden Hooks
**parallel**, `PreToolUse`-Exit-0 macht stdout zum Entscheidungskanal, und die Aggregation
widersprüchlicher Entscheidungen ist **nicht dokumentiert**. Ein bewusst fehlertoleranter Schreiber
auf demselben Event wie der fail-closed Guard ist damit genau die Konstellation, die dieses Repo
bei [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) schon einmal in Runde 2 gefangen hat.

**R2-3** ist die zweite Hälfte davon und beantwortet die Frage „reicht *der Verlust wird sichtbar
gemacht* als Setzung?" mit **nein**: Folgepflicht 4 ist die einzige Absicherung gegen genau den
Zustand, den die ADR selbst als „ein Log, das lückenhaft ist und vollständig aussieht" beschreibt —
sie bekommt keine der drei neuen Fitness-Function-Zeilen, und im Timeout-Fall kann der abgebrochene
Emitter seinen eigenen Verlust ohnehin nicht melden. Das ist die Repo-eigene Klasse „Zusage weiter
als Abdeckung", eingebaut im Fix des Runde-1-HIGH.

**R2-1** ist der dritte und betrifft die verschärfte Randbedingung: sie ist **zu weit** geraten.
Wörtlich genommen schließt „keine Host-Sprachlaufzeit" die 16 Host-Skripte dieses Repos, den
fail-closed Guard, den Stop-Hook und den Gate `make comment-claims` mit ein — die Ausnahme für
bash+awk steht zwei Sätze weiter als bloße Behauptung, ohne Kriterium. Damit ist slice-059 unter
der wörtlichen Lesart **nicht umsetzbar** und unter der praktischen Lesart durch nichts begrenzt;
zwei Leser ziehen die Grenze verschieden. Nach *Accepted* wäre das nicht mehr korrigierbar
([`AGENTS.md`](../../AGENTS.md) §3.4), und
[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
verbietet die Reparatur über das Lastenheft.

**Was verschoben statt gelöst wurde.** Drei Stellen, alle im selben Muster — der Wortlaut wurde
präziser, der Mechanismus blieb aus: die Aufbewahrung („flüchtig" → „Lebensdauer: die Sitzung", ohne
Löschenden, R2-5), die Trigger-Schwelle („regelmäßig" → „dauerhaft" bzw. „der dort festgelegte
Wert", R2-8) und die Quadranten-Ehrlichkeit (Kennzeichnungen ergänzt, zwei davon behaupten einen
Sensor, den es nicht gibt, R2-7). Dazu die Korrektur, die nur an einem von drei Orten ankam
(R2-9): die als falsch nachgewiesene `LH-QA-03`-Lesart steht unverändert in slice-059 und welle-09
und widerspricht der ADR jetzt direkt.

**Was ausdrücklich trägt und nicht anzufassen ist.** **F-1 ist mustergültig gelöst** — beide
Tautologien gestrichen, die Streichung mit ihrem Mechanismus begründet, die Ersatz-Zeile im realen
Mutations-Harness ausführbar. **F-7 ist gelöst** (Ob/Wie-Trennung, eindeutig normativ). **F-9 und
F-10 sind gelöst.** Festlegung 2 bleibt der stärkste Teil der ADR, Festlegung 3s Ort bleibt richtig
hergeleitet, Form und Geschichte entsprechen Modul 4 und der Vorlage, der Status ist nirgends
vorgreifend gesetzt, es gibt keine Kollision mit einer aktiven ADR, und `make docs-check` läuft
230/0.

**Zur Frage „Festlegung 1 — Entscheidung oder elegantere Delegation".** Beides, und die Grenze ist
benennbar: **unveränderlich ab *Accepted*** sind die Richtung der Redaktion (Allowlist), der
leere Startzustand, die Pflicht zur Incident-Frage je Feld, der Ablageort samt Modus, die
Betriebs-Fehlerrichtung und die Pflicht, ein nicht erschließbares Pflicht-Feld zu begründen.
**Frei bleibt** der gesamte Umfang — welche Felder je hinzukommen —, und zwar dauerhaft, weil die
Tabelle in einem `MR` lebt, das jeder Folge-Slice ändern darf. Diese Grenze ist scharf genug, dass
zwei Leser sie gleich ziehen; **nicht** scharf ist die Ausnahme davon (R2-6), weil der gewählte
Startzustand selbst eine begründungspflichtige Abweichung ist, deren Begründungspflicht die ADR
nicht auslöst.

**Trägt die ADR jetzt genug, um slice-059 zu entsperren? Nein**, und zwar aus einem anderen Grund
als in Runde 1: nicht mehr, weil zu wenig entschieden wäre, sondern weil zwei der neuen
Entscheidungen den Slice **unausführbar** (R2-1) bzw. **auf einer undokumentierten Mechanik**
(R2-2) aufsetzen und der Slice-Text der ADR an der tragenden Randbedingung widerspricht (R2-9).

**Übergabe:** an den **ADR-Autor** (Rückkante Review → Architektur/Planung, die ADR bleibt
*Proposed*); die Anteile R2-9 zusätzlich an die **Planung** (slice-059, welle-09). Es gibt keinen
Produktiv-Diff; nichts geht an die Implementation. slice-059 bleibt in `open/`. Der Report ersetzt
keine Verifikation — DoD-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt,
anderer Eingabe-Kontext).

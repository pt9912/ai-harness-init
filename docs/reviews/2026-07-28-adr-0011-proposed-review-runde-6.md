# Review-Report: ADR-0011 (Proposed, **Runde 6**) — Telemetrie-Erfassung, Policy für Agenten-Spans — 2026-07-28

**Review-Art:** **Proposed-Review einer ADR, sechste Runde** — geprüft wird die **fünfte
Überarbeitung** plus den ihr nachgelagerten **Kürzungs-Durchgang** einer noch nicht angenommenen
Entscheidung ([`AGENTS.md`](../../AGENTS.md) §3.4 greift erst ab *Accepted*). Kein Produktiv-Diff.
**Nicht** geprüft: Code, DoD-Abhakung (Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Leitfrage dieser Runde — zweigeteilt.** (1) *Hat die Kürzung Substanz mitgenommen?* Das ist das
Hauptrisiko dieses Durchgangs: elf Rückverweise auf Review-Runden sind aus Kontext, Entscheidung,
Festlegungen, Konsequenzen und Fitness Functions entfernt, 415 → 390 Zeilen. (2) *Ist die ADR
jetzt annehmbar?* **Ergebnis vorab:** Die Kürzung hat die Substanz **erhalten** — alle vier
ehrlichen Grenzen stehen unverändert, keine Nummerierung ist gebrochen, kein Bezug zeigt ins
Leere. Genau **eine** Stelle hat die Kürzung falsch gemacht, und sie sitzt nicht im gekürzten
Text, sondern in der `Geschichte`, die auf ihn zeigt. **Es gibt in dieser Runde kein HIGH** — zum
ersten Mal in sechs Runden ist nichts *blockierend*.

**Der Beleg-Prüfauftrag, unverändert scharf.** In dieser ADR wurde dreimal etwas als *gemessen*
ausgegeben, das nicht gemessen war (zweimal die Sensor-Lage, einmal die Werkzeug-Doku). Ich habe
deshalb **jede** Behauptung, die als gemessen, belegt oder verbatim zitiert auftritt, an ihrer
Quelle geprüft — Ergebnisse gebündelt unter
[Beleg-Prüfung](#beleg-prüfung-jede-gemessen-aussage-an-ihrer-quelle). Kurzfassung: **von 23
geprüften Belegen halten 21 vollständig**, einer hält der Sache nach, aber nicht als Wortlaut,
einer ist eine Ableitung, die als Quellen-Aussage auftritt. **Beide Sensor-Aussagen, an denen
Runde 5 die ADR gestoppt hat, habe ich selbst gefahren — sie halten jetzt.**

**Gegenstand:** [`docs/plan/adr/0011-telemetrie-erfassung-policy.md`](../plan/adr/0011-telemetrie-erfassung-policy.md)
(Status **Proposed**, 390 Zeilen), im Kontext von
[`docs/plan/planning/welle-09-modul-15-konformitaet.md`](../plan/planning/welle-09-modul-15-konformitaet.md)
und `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` <!-- d-check:ignore (Lifecycle-Pfad: die Slice-Datei wandert durch open/next/in-progress/done) -->
sowie [`docs/plan/adr/README.md`](../plan/adr/README.md).

**Diff:** `git show 4789149` (die Kürzung — eine Datei, 22+/47−) auf `git show 95c1eb2` (die
Runde-6-Überarbeitung — vier Dateien). **Gemessen** (`git show 4789149 --stat`): der
Kürzungs-Commit berührt **ausschließlich** die ADR — nicht den Index, nicht welle-09, nicht
slice-059, nicht `spec/`, nicht `test/`, nicht `.claude/settings.json`.

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ 1.4.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Regelwerk (Baseline v3.5.2, vendored, Index zuerst): `modul-04-architektur-adrs.md`
  §Ziel-Form: ADR **vollständig gelesen** (inkl. *„Jede Entscheidung mit Architektur-Wirkung
  bekommt eine Fitness Function — sonst ist sie Absichtserklärung"* und *„`Accepted` wird nie
  überschrieben"*), `modul-15-observability.md` **vollständig** gelesen (§Span-/Audit-Attribut-
  Regeln, §Token-Attributions-Regeln, §Cache-Counter-Regeln), `grundlagen-klassifikation.md`
- Ziel-Form-Vorlage: `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`
  (Block-Reihenfolge gegen die ADR abgeglichen)
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) — **verbatim** gelesen
  (`spec/lastenheft.md:258-310`), nicht aus der ADR oder den Vorrunden übernommen
- Aktive ADRs auf Kollision geprüft: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md)
- Adaptionen: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.4 und §3.6
- **Vorherige Findings am gleichen Modul — alle fünf Vorrunden gelesen:**
  [Runde 1](2026-07-28-adr-0011-proposed-review.md) (2 HIGH / 6 MEDIUM / 3 LOW),
  [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md) (3 HIGH / 7 MEDIUM / 3 LOW / 2 INFO),
  [Runde 3](2026-07-28-adr-0011-proposed-review-runde-3.md) (1 HIGH / 4 MEDIUM / 6 LOW / 1 INFO),
  [Runde 4](2026-07-28-adr-0011-proposed-review-runde-4.md) (3 HIGH / 8 MEDIUM / 5 LOW / 1 INFO),
  [Runde 5](2026-07-28-adr-0011-proposed-review-runde-5.md) (2 HIGH / 6 MEDIUM / 3 LOW / 1 INFO)
- **Eigene Messungen dieser Sitzung** (nichts aus der ADR oder aus den Vorrunden übernommen):
  `make test-bats` **vollständig gefahren** (127 Tests, Exit 0, darunter
  `ok 89 driver: die Kopie traegt den Sensor-Bedarf inklusive .git`); `make docs-check` →
  **d-check 234 Dateien / 0 Befunde**; `make comment-claims` → **31 Dateien / 0 Befunde**;
  [`test/mutate-driver.bats`](../../test/mutate-driver.bats)`:88-106` gelesen;
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) §`prepare_isolation` (`:152`),
  §`run_case`, §`narrow_sensor`, §`failure_form` gelesen;
  `grep -E "log|tee|>>" .claude/hooks/pretooluse-command-guard.sh` → **exit 1, leer**;
  `.claude/settings.json` und `.codex/hooks.json` gelesen;
  [`.claude/hooks/stop-require-gates.sh`](../../.claude/hooks/stop-require-gates.sh) gelesen
  (`"decision": "block"` auf `:38` und `:51`); `ls -la .harness/state/` → Verzeichnis **0775**,
  Stempeldatei **0664**; `git ls-files .harness/state` → **0**; `.gitignore:5`;
  `ls harness/tools/ | wc -l` → **16**; `ls test/mutations/ | wc -l` → **102**;
  `docs/plan/planning/{in-progress,open,next}/` gelistet; **ein `awk`-Fatalfehler real
  ausgelöst** → **Exit 2**; `internal/emit/enforce.go` (Hook-Emission ins Ziel-Repo);
  **die Hook-Doku am 2026-07-28 dreimal gezielt abgerufen** (DE- **und** EN-Fassung) — zu
  `tool_use_id`, `session_id`/`agent_id`/`agent_type`, leerem Matcher, Timeout-Default und der
  `decision`-Tabelle je Ereignis

---

## Findings

### Durch die Kürzung neu

#### F6-1 — Die `Geschichte` behauptet über den eigenen Body: *„Beide Fehlgriffe stehen jetzt **im Text**"* — die Kürzung hat genau diese Passagen aus dem Text entfernt

- `kategorie`: **MEDIUM** (Doku-Drift mit Wirkung; keine Eskalation in den Gate-Pfad, weil keine
  Sensor- oder Gate-Aussage betroffen ist — aber [`AGENTS.md`](../../AGENTS.md) §3.4 friert die
  Zeile ab *Accepted* ein, und sie ist eine **Selbstauskunft der ADR über ihren eigenen Inhalt**)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 · `modul-04-architektur-adrs.md` §Ziel-Form
  (Block `Geschichte`) · Drift-Klasse „derselbe Stand an zwei Orten, einer altert" ·
  Vorbefunde F-10 / R2-11 / R3-8 / R4-13 / R5-4 (dieselbe Klasse, sechste Runde)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:386` gegen `:121-128`
- `befund`: Die Runde-6-Zeile der `Geschichte` sagt wörtlich: *„Beide Fehlgriffe stehen jetzt **im
  Text**, weil ihre Klasse lehrreicher ist als ihr Endstand: dreimal wurde eine
  `grep`-Trefferliste als Vollständigkeitsaussage gelesen, statt den Sensor zu fahren."* Der
  Kürzungs-Commit `4789149` entfernt genau den Absatz, auf den sich das bezieht — *„Zur Herkunft
  dieser Zeile, weil sie zweimal falsch war … Runde 4 behauptete hier einen Mutations-Fall …
  Runde 5 korrigierte auf ‚unbewacht, kein Sensor meldet es' — ebenfalls falsch"*. Gemessen:
  `grep -n "Runde 4 behauptete\|Runde 5 korrigierte"` über den Body → **0 Treffer**. Die
  `Geschichte` ist damit die **einzige** Stelle, die diese Fehlgriffe noch führt, und sie
  behauptet gleichzeitig, sie stünden woanders. Der Kürzungs-Commit hat außerdem **keine eigene
  Zeile** in der `Geschichte` bekommen, obwohl er 47 Zeilen aus Kontext, Entscheidung,
  Festlegungen 1–6, Konsequenzen und Fitness Functions entfernt — die Tabelle führt sechs
  Fassungen, git führt sieben Body-Änderungen.
  Failure-Szenario: die ADR geht auf *Accepted*. Der CR-Autor von slice-062 oder ein Verifier
  liest die `Geschichte`, um zu prüfen, ob die drei belegten Fehlgriffe aufgearbeitet sind; die
  Zeile verweist ihn in den Body, wo nichts steht. Er kann aus dem Artefakt heraus nicht
  entscheiden, ob die Kürzung nur die *Erzählung* oder auch die *Korrektur* entfernt hat — und
  weil die einzige Zeile, die davon spricht, nach §3.4 nicht mehr änderbar ist, bleibt ihm nur
  git-Archäologie über zwei Commits. Verschärfend: der Satz *„ihre Klasse ist lehrreicher als ihr
  Endstand"* ist die einzige Stelle, an der diese ADR ihre eigene Steering-Loop-Lehre trägt; sie
  zeigt jetzt auf Leerraum.
- `verifizierbar`: ja, ohne Umsetzung — `git show 4789149` (der entfernte Absatz);
  `grep -n "Runde 4 behauptete\|Runde 5 korrigierte" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → leer; `sed -n '386p'` (die Behauptung). **Kein Gate deckt es:** `make docs-check` prüft
  Links/Anker/IDs und läuft grün (234/0, selbst gefahren), nicht die Wahrheit einer Aussage über
  den eigenen Body.

#### F6-2 — Folgepflicht 4 verliert ihren Satzabschluss: die Kürzung entfernte die Klammer samt Punkt, zwei Sätze laufen ineinander

- `kategorie`: **LOW**
- `quelle`: „Maintainability" · [`AGENTS.md`](../../AGENTS.md) §3.4 (ab *Accepted* nicht mehr
  korrigierbar) · ADR-0011 Folgepflicht 4 (die einzige Sichtbarkeits-Zusage der ADR)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:308-309`
- `befund`: Die Kürzung entfernte den Beleg-Verweis *„(Proposed-Review Runde 2)"* — und mit ihm
  den Punkt, der den Satz beendete. Der Text lautet jetzt: *„… wäre genau die Zusage ohne
  Abdeckung, gegen die [`AGENTS.md`](../../AGENTS.md) §3.6 steht Die Setzung ist deshalb: **jeder
  Span trägt eine je Sitzung monoton steigende Folgenummer** …"*. Es fehlt kein Wort, es fehlt
  ein Satzzeichen — aber an der Nahtstelle zwischen der **Begründung** (warum eine Sichtbarkeit,
  die vom Emitter abhängt, nicht trägt) und der **Setzung** (der Folgenummer). Das ist die
  tragende Herleitung von Folgepflicht 4 und damit der einzigen Vollständigkeits-Zusage dieser
  ADR.
  Failure-Szenario: die ADR geht auf *Accepted*. Ein Leser, der prüfen will, ob die Herleitung
  trägt — etwa der Implementer von slice-059, der entscheiden muss, wie streng die Folgenummer
  vergeben wird —, muss raten, wo der Begründungssatz endet und die Setzung beginnt; die
  naheliegende Lesart macht *„§3.6 steht die Setzung"* zu einem Halbsatz, der die Setzung dem
  Hard-Rule-Text zuschreibt statt dieser ADR. Nach §3.4 ist die Stelle nicht mehr reparierbar.
- `verifizierbar`: ja, am Artefakt —
  `sed -n '308,309p' docs/plan/adr/0011-telemetrie-erfassung-policy.md`; `git show 4789149` zeigt
  die Ursache (`(Proposed-Review Runde 2). Die Setzung` → `steht\n  Die Setzung`). Kein Gate
  deckt es — d-check prüft keine Satzzeichen (selbst gefahren: 234/0).

### Aus den Vorrunden offen

#### F6-3 — „Strom" ist an zwei Orten **verschieden** definiert: Festlegung 3 sagt *je Sitzung*, Folgepflicht 4 sagt *je Agent* — und die Runde-6-Überschrift hat die Mehrdeutigkeit zur Wort-Kollision verschärft

- `kategorie`: **MEDIUM** — **aus Vorrunden offen** (R5-6 unaufgelöst; die Reparatur von R5-5(a)
  hat den Begriff in die Gegen-Aussage hineingeschrieben)
- `quelle`: ADR-0011 Festlegung 3, zweiter Punkt · ADR-0011 Folgepflicht 4 ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code hält"*) ·
  `modul-07-carveouts.md` §Ziel-Form (ein Kriterium, das ein anderer ohne Rückfrage anwenden
  kann) · Vorbefunde R4-9, R5-6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:160-161` gegen `:316-317`
- `befund`: Runde 6 hat die von R5-5(a) beanstandete Überschrift *„Lebensdauer: die Sitzung"*
  ersetzt durch **„Je Sitzung ein eigener Strom — und der Emitter fasst nur seinen eigenen an."**,
  darunter *„Jede Sitzung schreibt in ihre **eigene, sitzungs-benannte** Datei"*. Folgepflicht 4
  schließt mit **„Je Agent ein eigener Strom, je Strom ein eigener Zähler."** Derselbe Begriff,
  zwei unvereinbare Zuordnungen: `grep -n "Strom"` liefert `:160` (je Sitzung), `:248`
  (Emitter-Ausgabekanal, dritte Bedeutung), `:317` (je Agent). Die alte Überschrift war
  *unscharf*; die neue ist **falsch gegenüber der eigenen Folgepflicht**. R5-6 hatte genau diese
  Frage offen gelassen („Ob ‚Strom' eine Datei oder ein Abschnitt in der Sitzungs-Datei ist,
  entscheidet die ADR nicht") — die Runde-6-Überarbeitung hat sie nicht entschieden, sondern die
  eine Lesart in eine Überschrift geschrieben und die andere in der Folgepflicht stehen lassen.
  Failure-Szenario: slice-059 setzt Festlegung 3 um, weil sie in der **Entscheidung** steht und
  die Folgepflichten weiter unten in den *Konsequenzen*: eine sitzungs-benannte Datei, in die
  Hauptkontext und alle Subagenten schreiben. Die Sitzung startet drei Subagenten (in diesem Repo
  der Normalfall — slice-059 §Messung E zählt für **eine** Sitzung 189 Calls im Hauptkontext plus
  49 und 66 in Subagenten). Vier Emitter-Prozesse führen nach Folgepflicht 4 **je einen eigenen
  Zähler** und schreiben ihn in **eine** Datei: der Bestand enthält vier ineinander verschränkte
  Nummernfolgen, jede beginnt bei 1. Der Leser, dem Folgepflicht 4 wörtlich zusagt, dass *„eine
  Lücke im Bestand erkennbar ist"*, sieht Nummern-Wiederholungen statt einer Lücke — genau der
  Zustand *„lückenhaft und sieht vollständig aus"*, den derselbe Absatz ausschließen will, und
  genau die Doppelvergabe, gegen die der (Sitzung, Agent)-Kreis eingeführt wurde. Umgekehrt: baut
  er nach Folgepflicht 4 eine Datei je Agent, ist *„sitzungs-benannt"* falsch und die
  Aufräum-Regel (*„beim ersten Span einer Sitzung entfernt der Emitter ältere Bestände"*) greift
  bei jedem frisch gestarteten Subagenten ins Leere. Nach §3.4 lässt sich keine der beiden
  Stellen mehr angleichen.
- `verifizierbar`: ja, am Artefakt — `grep -n "Strom" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → `:160`, `:248`, `:317`; `:161` (sitzungs-benannte Datei) gegen `:316-317` (je Agent). Kein
  Gate deckt es.

#### F6-4 — `LH-QA-01` ist aus dem Body verschwunden: die Anforderung steht wieder **nur** im Kopf-Feld (Regression von R4-14, das vier Runden gekostet hat)

- `kategorie`: **LOW** — **Regression aus Vorrunden** (R4-14 war in Runde 5 als gelöst gemessen)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 (*„Requirement- und ADR-IDs in PRs/Commits
  referenzieren"*) · `modul-04-architektur-adrs.md` §Ziel-Form (*„Der Kontext referenziert die
  Anforderung"*) · Vorbefunde F-9, R2-13, R3-9, R4-14 (dort in Runde 5 als **gelöst** abgehakt)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:11` (einziger Treffer)
- `befund`: Gemessen: `grep -n "LH-QA-01"` über die ADR liefert **genau einen** Treffer — `:11`,
  das **Bezug**-Kopf-Feld. Runde 5 hatte hier zwei gemessen und R4-14 ausdrücklich als *„nach vier
  Runden gelöst — und ohne Kosmetik"* geschlossen, weil die ID im Body an der inhaltlich
  richtigen Stelle stand (*„genau die Klasse, gegen die `LH-QA-01` steht"*, im Absatz über den
  Zustands-Ausschluss). Die Runde-6-Überarbeitung `95c1eb2` hat diesen Absatz vollständig ersetzt
  — die ID ging dabei mit verloren und wurde nirgends nachgezogen. Betroffen ist ausgerechnet der
  Abschnitt *„Was hier bewusst NICHT steht, und warum"*, der die `LH-QA-01`-Logik (eine Zusage,
  die unter keiner Mutation rot werden kann, ist ein halluziniertes Gate) **ausführt**, sich aber
  nur noch auf [`AGENTS.md`](../../AGENTS.md) §3.6 beruft. (Die Kürzung `4789149` ist hier
  **nicht** ursächlich — sie fasst `LH-QA-01` an keiner Stelle an; gemessen am Diff.)
  Failure-Szenario: die ADR geht auf *Accepted*. Ein Verifier, der zu `LH-QA-01` die tragenden
  ADR-Stellen sucht — der übliche Weg von der Anforderung zur Entscheidung —, findet nur das
  Kopf-Feld und muss aus dessen Klammertext raten, welcher Absatz gemeint ist. Der Absatz, der
  die Anforderung wirklich einlöst, ist über die ID nicht auffindbar; nach §3.4 lässt sich der
  Link nicht mehr setzen. Dass `make docs-check` grün bleibt (selbst gefahren: 234/0), ist Teil
  des Befunds: das Gate prüft die Form vorhandener Links, nicht die Abwesenheit eines nötigen.
- `verifizierbar`: ja, am Artefakt —
  `grep -c "LH-QA-01" docs/plan/adr/0011-telemetrie-erfassung-policy.md` → **1**;
  `git show 95c1eb2` zeigt den Wegfall im ersetzten Absatz. Kein Gate deckt es.

#### F6-5 — Das in Festlegung 3 benannte Aufräum-`make`-Ziel hat weiterhin weder Folgepflicht noch Fitness Function

- `kategorie`: **LOW** — **aus Vorrunden offen** (unveränderter Rest von R5-5(b); die Kürzung
  fasst die Stelle nicht an)
- `quelle`: ADR-0011 Festlegung 3, zweiter Punkt · ADR-0011 §Bedrohungsmodell Grund 1 und Grund 2
  · [`AGENTS.md`](../../AGENTS.md) §3.6 · Vorbefunde R2-5, R3-4, R4-8, R5-5
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:169` gegen `:293-321` (die fünf
  Folgepflichten) und `:325-335` (die neun Fitness-Function-Zeilen)
- `befund`: Die Entscheidung ist unverändert richtig und ausgesprochen: *„alte Bestände bleiben
  liegen, bis jemand sie **ausdrücklich** entfernt (ein `make`-Ziel, kein Automatismus). Der
  Bestand wächst also — das ist eine **benannte** Entscheidung, kein Versehen."* Die Kürzung hat
  diese Ehrlichkeit **erhalten** (sie war das Hauptrisiko dieses Durchgangs und ist es nicht
  geworden). Unverändert offen ist die Folgekante: Volltextsuche nach einem Aufräum-Ziel in den
  Folgepflichten und in der Fitness-Function-Tabelle → **kein Treffer**. Es bleibt das einzige
  Artefakt, das der Text für nötig erklärt und niemandem aufträgt.
  Failure-Szenario: unverändert das aus R5-5 — nach einigen Wochen Parallelbetrieb (dieses Repo
  führt Review-, Verifikations- und Implementer-Sitzungen getrennt) liegen in `.harness/state/`
  Dutzende Span-Dateien mit Pfaden, Kommando-Tokens und — auf der Repo-Ebene ausdrücklich erlaubt
  — Inhalts-**Hashes**, in einem Verzeichnis, das ich als `0775` gemessen habe. Grund 1 des
  eigenen Bedrohungsmodells (*„ein rotiertes Secret ist aus der Quelle raus und stünde im Log
  weiter"*) ist ein **Zeit**-, kein Grenz-Argument und greift, sobald die Lebensdauer nicht mehr
  die Sitzung ist; Grund 2 (*„wer sein Zustands-Verzeichnis an einen Fehlerbericht hängt"*) wird
  mit jeder liegengebliebenen Datei wahrscheinlicher.
- `verifizierbar`: ja, am Artefakt — Volltextsuche nach *Aufräum* → `:162`, `:169`, sonst nur
  `Geschichte`; Volltextsuche nach *make-Ziel* → `:169`, sonst nur `Geschichte`. Kein Gate deckt es.

#### F6-6 — „Allowlist" steht weiter an zwei **normativen** Stellen, obwohl die Entscheidung den Begriff nicht mehr führt

- `kategorie`: **LOW** — **aus Vorrunden offen** (Rest von R4-10 / R5-8; Runde 6 hat zwei von
  vier Stellen gezogen, die Kürzung keine)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 · Vorbefunde R4-10, R5-8 · Drift-Klasse
  „derselbe Stand an zwei Orten, einer altert"
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:273` und `:377`
- `befund`: Gemessen: `grep -n "Allowlist"` liefert außerhalb der `Geschichte` zwei Treffer.
  (a) `:273`, Cs **Contra**-Spalte: *„jede Erweiterung der Allowlist ist eine Einzelfall-Abwägung,
  und diese Pflege endet nie"* — die Allowlist ist nach Festlegung 1.3 durch das *geschlossene
  Schema* ersetzt, und Festlegung 2 spricht seit Runde 6 von *namentlich gelisteten Werkzeugen*.
  (b) `:377`, Re-Evaluierungs-Trigger 6: *„Die Runde-4-Fassung knüpfte den Trigger an eine ‚leere
  Allowlist' — die es nach Festlegung 1.3 nicht mehr gibt"*. Diese zweite Stelle ist zugleich der
  **einzige** im Body verbliebene Rückverweis auf eine Review-Runde — die Kürzung hat elf andere
  entfernt und diesen stehen gelassen; ihr eigener Commit nennt als Geltungsbereich *„Kontext,
  Entscheidung, Festlegungen 1–6, Konsequenzen und Fitness Functions"*, also alles außer den
  Triggern. Die Regel ist damit nicht falsch, aber uneinheitlich angewandt.
  Failure-Szenario: die ADR geht auf *Accepted*. Der Fall-Autor von slice-059 liest die
  Alternativen-Tabelle — die vorgesehene Stelle, um Cs Kosten zu verstehen — und findet dort eine
  „Allowlist", deren Pflege *„nie endet"*. Er sucht sie in den Festlegungen und findet zwei
  Kandidaten (das geschlossene **Feld**-Schema aus 1.3 und die **Werkzeug**-Tabelle aus
  Festlegung 2); der Trigger auf `:377` nennt eine dritte, abgeschaffte Variante. Er baut seinen
  Wächter gegen die falsche der beiden — exakt das Failure-Szenario, das R5-8 für die inzwischen
  reparierte Fitness-Function-Zeile beschrieben hat, nur eine Ebene weiter außen. Nach §3.4 ist
  keine der beiden Stellen mehr korrigierbar.
- `verifizierbar`: ja, am Artefakt —
  `grep -n "Allowlist" docs/plan/adr/0011-telemetrie-erfassung-policy.md` → `:273`, `:377`
  (plus `Geschichte`). Kein Gate deckt es.

#### F6-7 — *„Subagenten teilen **laut Quelle** die Sitzungs-Kennung"* ist eine Ableitung, keine Aussage der Quelle

- `kategorie`: **LOW** (Basis wäre MEDIUM nach dem Muster von R5-3 — eine als Quellen-Aussage
  auftretende Behauptung, die die Quelle nicht trägt; **eine Stufe herunter**, weil die
  Ableitung *sachlich plausibel* ist, ich sie **nicht widerlegen** konnte, und die gewählte
  Konstruktion unter **beiden** Lesarten sicher bleibt)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · ADR-0011 §Kontext (*„an der Werkzeug-Doku
  gemessen"*) · Werkzeug-Doku <https://code.claude.com/docs/de/hooks> bzw. `/en/hooks` ·
  Vorbefunde R4-4, R5-3 (dieselbe Klasse: Quellen-Attribution ohne Quellen-Deckung)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:313-314`
- `befund`: Folgepflicht 4 begründet den Nummernkreis je (Sitzung, Agent) mit: *„Subagenten
  teilen **laut Quelle** die Sitzungs-Kennung und feuern dieselben Hooks — ein sitzungs-weiter
  Zähler vergäbe bei parallelen Läufen **dieselbe Nummer zweimal**."* Ich habe die Quelle am
  2026-07-28 gezielt danach abgefragt. Die **zweite** Hälfte hält verbatim: `agent_id` ist
  *„Present only when the hook fires inside a subagent call. Use this to distinguish subagent
  hook calls from main-thread calls."* Die **erste** Hälfte steht dort **nicht**: die
  `session_id`-Zeile lautet vollständig *„Current session identifier"* — ohne jede Aussage über
  Subagenten. Dass die Kennung geteilt wird, folgt aus dem *Zweck* von `agent_id` (ein
  Unterscheidungsfeld wäre überflüssig, wenn `session_id` bereits unterschiede), ist also eine
  gut begründete **Ableitung** — aber die ADR schreibt „laut Quelle" und macht sie damit zur
  Fremdaussage. Ich kann sie **nicht widerlegen**; ich kann feststellen, dass die Quelle sie
  nicht trifft.
  Failure-Szenario: die ADR geht auf *Accepted*. Beim Auslösen von Re-Evaluierungs-Trigger 1
  (*„wenn das Agenten-Werkzeug seine Hook-Oberfläche ändert … dann ist die Abdeckung neu zu
  messen"*) sucht der Prüfende die Zusage in der Quelle, um sie gegen die neue Fassung zu halten
  — und findet sie dort nie, weder vorher noch nachher. Der Trigger kann für diese Eigenschaft
  strukturell nicht auslösen, weil sein Referenzpunkt nicht existiert. Nach §3.4 ist die
  Attribution nicht mehr in eine Ableitung zurückzustufen. Es ist die **vierte** als
  Quellen-/Messaussage ausgegebene Behauptung dieser ADR, die an ihrer Quelle nicht wörtlich
  wiederzufinden ist — nach §Kontext-Eskalation des Reviewer-Skills bleibt das ein
  **Steering-Loop-Signal**, auch wenn der Einzelfall harmlos ist.
- `verifizierbar`: ja — Abruf von <https://code.claude.com/docs/en/hooks>, Tabelle *Common input
  fields*, Zeilen `session_id` / `agent_id` / `agent_type`, gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:313-314`. Kein Gate deckt es
  (`docs-check` läuft `--network none`).

#### F6-8 — Unverändert offen aus Runde 5, von Runde 6 und der Kürzung nicht berührt

- `kategorie`: **LOW** (drei Punkte) / **INFO** (einer) — **aus Vorrunden offen**, hier gebündelt,
  weil der Diff sie nachweislich nicht anfasst und die Failure-Szenarien der Vorrunde unverändert
  gelten
- `quelle`: Vorbefunde R3-5/R4-15/R5-10 · R4-16/R5-11 · R2-14/R3-12/R4-17/R5-12
- `pfad`: `:184-196` · `:89-92` gegen `:275` · `:157-159`
- `befund`:
  (a) **GNU/BSD-Dialektfrage (LOW, R5-10).** *„POSIX-System"* beantwortet weiterhin *„vorhanden
  wo"*, nicht *„in welchem Dialekt"*; der Bestand, den derselbe Absatz für *„nicht betroffen"*
  erklärt, deklariert im eigenen Kopf das Gegenteil —
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh)`:32-36` (gelesen): *„Die Faelle
  nutzen `sed -i` und GNU-BRE-Escapes, sind also **NICHT strikt POSIX**"*. Festlegung 5 zieht die
  Liste unverändert ins emittierte Ziel, und
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) führt macOS erstklassig.
  Failure-Szenario unverändert aus R4-15: der Emitter wird mit GNU-Semantik gebaut, greift auf
  einem BSD-Ziel anders, und betroffen ist die **Ableitung der Argument-Werte** — der
  sicherheitstragende Teil dieser ADR.
  (b) **`transcript_path` gegen die Verwerfung von Alternative D (LOW, R5-11).** Regel 1.4 bietet
  als Auflösung des einzigen offenen Feldes an, der Span trage den `transcript_path`; dieselbe
  ADR verwirft D mit *„die Datenquelle liegt **außerhalb** des Repos, gehört uns nicht und kann
  sich mit dem Werkzeug ändern"*. Ich habe die technische Grundlage nachgemessen und **bestätige
  die Prämisse**: die Hook-Payload trägt **keine** Token-/Cache-Zähler, der Weg führt zwingend
  über das Transkript. Die Spannung bleibt damit real, ist aber für den Slice **entscheidbar**
  (Modul 15 verlangt verbatim nur *„jede Abweichung davon begründest du"*, keinen Sensor — gegen
  den Modul-Wortlaut geprüft), also kein blockierender Mangel. Failure-Szenario unverändert:
  slice-059 wählt den `transcript_path`-Weg, slice-060 findet das Transkript rotiert oder im
  Format geändert, und der Cache-Status ist weder erfasst noch als Abweichung dokumentiert.
  (c) **Zustands-Verzeichnis gruppenschreibbar (INFO, R5-12).** Eigene Messung 2026-07-28
  bestätigt die Zahlen der ADR erneut: `.harness/state/` ist `drwxrwxr-x` (0775), die Stempeldatei
  `-rw-rw-r--` (0664). Ein `0600`-Span in einem `0775`-Verzeichnis ist gegen Mitlesen geschützt,
  gegen Entfernen und Unterschieben nicht. Bleibt INFO, weil Festlegung 3 dritter Punkt („Kein
  Beleg-Status") die Integritäts-Anforderung ausdrücklich absenkt — im Verbund mit F6-5 gilt
  aber: je länger Bestände liegen bleiben, desto länger stehen sie dort.
- `verifizierbar`: ja — (a) `sed -n '30,36p' harness/tools/mutate.sh` gegen `:184-196`;
  (b) Abruf der Hook-Doku (Payload-Feldliste ohne Token-/Cache-Zähler) gegen `:89-92` und `:275`;
  (c) `ls -ld .harness/state/`. Kein Gate deckt sie.

#### F6-9 — Die ungepinnte Quelle divergiert zwischen ihren Sprachfassungen, und die ADR nennt die Fassung, in der ihre Span-Identität nicht auffindbar war

- `kategorie`: **INFO** (dokumentationswürdige, aber undokumentierte Annahme — **kein** Vorwurf
  an die ADR: die Aussage selbst ist an der Quelle **belegt**, nur nicht an der zitierten)
- `quelle`: ADR-0011 §Kontext (*„an der Werkzeug-Doku gemessen, 2026-07-28,
  <https://code.claude.com/docs/de/hooks>"*) · ADR-0011 §Re-Evaluierungs-Trigger 1 (*„Die Quelle
  … ist **nicht gepinnt** und wird von keinem Gate geprüft"*)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:34-38`
- `befund`: Der Kontext führt *„eine gemeinsame `tool_use_id` über Vor- und Nach-Event (**die
  Span-Identität**)"* als gemessene Eigenschaft der Hook-Oberfläche — sie ist damit das Feld, auf
  dem das gesamte Span-Konzept und Alternative E (*„der Span trägt nur IDs (`tool_use_id`, …)"*)
  ruhen. Gemessen am 2026-07-28: auf der **englischen** Fassung
  (<https://code.claude.com/docs/en/hooks>) steht das Feld verbatim, samt Beispiel-JSON
  (`"tool_use_id": "toolu_01ABC123..."`) und dem Satz *„The `tool_name`, `tool_input`, and
  `tool_use_id` fields are event-specific."* — **die Behauptung der ADR hält**. Auf der von der
  ADR genannten **deutschen** URL war das Feld in **zwei** unabhängigen, gezielt darauf
  gerichteten Abrufen nicht auffindbar; der zweite Abruf gab das `PreToolUse`-Beispiel-JSON aus,
  und es führt weder `tool_use_id` noch die drei zusätzlichen `tool_input`-Schlüssel der
  englischen Fassung. Ich schließe daraus **nicht**, dass die DE-Seite das Feld nicht führt (mein
  Abruf geht über eine zusammenfassende Zwischenstufe — dieselbe Einschränkung, die Runde 5 für
  ihren eigenen Negativbefund benannt hat); ich stelle fest, dass die beiden Fassungen in einer
  Weise auseinanderlaufen, die genau das tragende Feld betrifft.
  Failure-Szenario: Re-Evaluierungs-Trigger 1 löst aus („das Werkzeug hat seine Hook-Oberfläche
  geändert"). Der Prüfende folgt der in der ADR genannten URL — der deutschen —, findet die
  Span-Identität dort nicht und schließt, das Feld sei entfallen; er zieht die Zusage aus
  Festlegung 1 zurück oder baut eine Ersatz-Korrelation über `session_id` + Zeitstempel, obwohl
  die Oberfläche unverändert ist. Der Trigger sagt selbst, dass **kein Gate** die Quelle prüft
  und er nur wirkt, *„wenn ihn jemand liest"* — die Sprachfassung entscheidet dann allein über
  das Ergebnis.
- `verifizierbar`: ja — Abruf beider URLs mit derselben Frage nach `tool_use_id`; die EN-Fassung
  liefert Feld und Beispiel, die DE-Fassung in zwei Abrufen nicht. Kein Gate deckt es
  (`docs-check` läuft `--network none`; selbst gefahren: 234/0).

## Negativbefunde

### Die Leitfrage dieser Runde: **hat die Kürzung Substanz mitgenommen?**

- geprüft, ohne Befund: **Alle vier ehrlichen Grenzen stehen unverändert — ich habe jede einzeln
  gegen den Vor-Stand `95c1eb2` gehalten.**
  (a) *Emitter stirbt vor der Nummernvergabe:* `:318-321` führt den Absatz **„Ehrlich zu den
  Grenzen"** wörtlich fort — *„stirbt der Emitter vor der Vergabe, wurde nie eine Nummer vergeben
  — dann entsteht keine Lücke, und dieser Fall bleibt unsichtbar. Er ist **nicht** gedeckt, und
  das steht hier, statt die Folgenummer als Vollschutz auszugeben."* Kein Wort entfernt.
  (b) *Der Bestand wächst, weil Lebendigkeit nicht entscheidbar ist:* `:164-171` — die Kürzung
  ersetzt *„der wachsende Bestand, den Runde 2 bemängelt hat"* durch *„Der Bestand wächst also —
  das ist eine **benannte** Entscheidung, kein Versehen."* Die Begründung (*„eine Sitzungs-Kennung
  ist kein Lebendigkeits-Signal"*), der Preis (*„bis jemand sie ausdrücklich entfernt"*) und das
  Argument der unsichtbarsten Lücke stehen unverändert.
  (c) *Warum die tautologische Fitness Function fehlt:* `:337-344` ist **vollständig erhalten**,
  einschließlich beider gestrichener Zeilen, des `--exclude-standard`-Mechanismus und des Satzes
  *„die gestrichene Zeile hätte im Gate nur Sicherheit vorgetäuscht"*. Nur das Etikett
  *„(Proposed-Review-Befund, Runde 1)"* ist entfallen.
  (d) *Warum es für den Zustands-Ausschluss bewusst keinen Mutations-Fall gibt:* `:126-128` und
  die Fitness-Function-Zeile `:335` tragen die Begründung beide, in identischer Form — *„`make
  mutate` arbeitet in der isolierten Kopie, und die enthält den Zustands-Bereich gerade nicht —
  die Mutation maskierte sich selbst."* **Ich habe das selbst nachgemessen** (s. Beleg-Prüfung).
- geprüft, ohne Befund: **Keine Nummerierung ist gebrochen, kein Bezug zeigt ins Leere.** Die
  Liste in Festlegung 1 zählt sauber 1–5 (`grep -n "^[0-9]\."` → `:70`, `:73`, `:75`, `:82`,
  `:94`); die Festlegungen 1–6 sind vollständig und in Reihenfolge; die Folgepflichten 1, 2, 3, 5,
  4 existieren alle. **Jeder interne Verweis wurde einzeln aufgelöst:** Festlegung 1 → „Folgepflicht
  1" ✓; Festlegung 5 → „Festlegungen 1–4 und 6" ✓ (5 korrekt ausgenommen); Festlegung 6 →
  „Folgepflicht 4" ✓; Folgepflicht 4 → *„Der zugehörige Zahn steht unten in der Fitness Function"*
  ✓ (Zeile 4 der Tabelle, *„Ein Span wird unterschlagen"*); Kontext → *„steht ihr Wandel unten als
  Re-Evaluierungs-Trigger"* ✓ (Trigger 1); Fitness-Function-Zeilen → Festlegung 2 / Festlegung 6 ✓;
  Kopf-Feld → *„die Randbedingung aus Festlegung 4 — verbatim zitiert"* ✓. **Kein toter Verweis.**
- geprüft, ohne Befund: **Kein Satz hat außer dem in F6-2 benannten seinen Anschluss verloren.**
  Ich habe alle elf Kürzungsstellen des Diffs einzeln im neuen Text gelesen. Zehn tragen einen
  vollständigen Ersatzsatz, der die Aussage ohne die Fehlergeschichte führt — insbesondere
  `:98-99` (*„Sie steht am Ende der Prüfung, nicht an ihrem Anfang"* ersetzt die Zählung der drei
  Felder; die verbleibende offene Frage steht ohnehin in Regel 1.4), `:110` (die
  Gattungs-Begründung ist als **Grund** erhalten, nicht nur als Vorfassungs-Zitat), `:232-235`
  (*„Wie das Werkzeug mehrere Antworten verrechnet, ist für das Argument unerheblich"* — die
  Schluss-Richtung ist unverändert und war schon in Runde 5 ausdrücklich nicht beanstandet) und
  `:241-242` (*„wer dorthin ausweicht, **verlegt** die Kollision"*).
- geprüft, ohne Befund: **Die Kürzung hat keine Festlegung, keine Alternative und keine
  Fitness-Function-Zeile inhaltlich verändert.** `git show 4789149` fasst die neun
  Fitness-Function-Zeilen, die Alternativen-Tabelle A/B/C/D/E, die Re-Evaluierungs-Trigger und die
  `Geschichte`-Zeilen **nicht** an; die Entscheidungssätze aller sechs Festlegungen sind
  wortgleich. Was sich änderte, ist ausschließlich Begleittext.
- geprüft, ohne Befund: **Das Dokument endet sauber** — letzte Zeile ist die letzte
  `Geschichte`-Tabellenzeile, kein Fremd-Markup, kein Template-Hinweis-Block.
  Eine **Formsache ohne Failure-Szenario** (deshalb kein Finding): die Kürzung hinterlässt bei
  `:209-210` eine **doppelte Leerzeile**, wo die entfernte Klammer stand; es ist die einzige im
  Dokument (`awk`-Zählung) und rendert identisch.

### Runde-5-Befunde, die **sauber gelöst** sind

- geprüft, ohne Befund: **R5-1 ist gelöst — und ich habe es nicht geglaubt, sondern gefahren.**
  Der Absatz sagt jetzt *„Und diese Ausnahme ist bewacht — von `test/mutate-driver.bats`"*. Ich
  habe `make test-bats` dieser Sitzung vollständig laufen lassen (Exit 0, 127 Tests) und
  `ok 89 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` in der Ausgabe;
  [`test/mutate-driver.bats`](../../test/mutate-driver.bats)`:104` trägt die Zusicherung
  `[ ! -e "$dest/.harness/state" ]`, `make test` ist Bestandteil von `make gates` (`Makefile:231`),
  und `.harness/state/` existiert im Arbeitsbaum. Die Aussage der ADR ist damit **belegt**, nicht
  behauptet — nach drei falschen Anläufen an derselben Stelle.
- geprüft, ohne Befund: **R5-2 ist gelöst, und die Begründung ist an der Mechanik nachgemessen.**
  Die Fitness-Function-Zeile ist von `test/mutations/` auf **bats/`make gates`** umgestellt und
  sagt ausdrücklich *„**Kein** Mutations-Fall"*. Ich habe die Ursache selbst verifiziert:
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh)`:152` lautet
  `( cd "$REPO" && tar -cf - --exclude=./.harness/state . ) | tar -xf - -C "$dest"` — die
  isolierte Kopie enthält den Zustands-Bereich nicht, eine Mutation des Ausschlusses maskierte
  sich also tatsächlich selbst. Die Zeile ist damit **keine** halluzinierte Fitness Function mehr,
  sondern eine korrekt begründete Nicht-Zeile. Es ist **keine** neue tautologische Zeile
  hinzugekommen; ich habe alle neun Zeilen einzeln auf Rot-Fähigkeit geprüft.
- geprüft, ohne Befund: **R5-3 ist an der Wurzel gelöst.** Die Aggregations-Aussage ist
  **ersatzlos** gestrichen; der Absatz argumentiert jetzt unabhängig davon, wie das Werkzeug
  mehrere Antworten verrechnet. Ich habe ausdrücklich geprüft, ob die Kürzung dabei die
  Schluss-Richtung beschädigt hat — sie tut es nicht: *„dass ein Telemetrie-Hook überhaupt auf
  einem Kanal steht, auf dem Entscheidungen transportiert werden, ist das Risiko"* trägt das
  Argument allein, und die beiden übrigen Punkte (kein entscheidungsfreies Ereignis; der zweite
  fail-closed Hook auf `Stop`) sind beide von mir an der Quelle bzw. am Repo bestätigt.
- geprüft, ohne Befund: **R5-4 ist gelöst — die Drei-Wege-Drift ist geschlossen.** Alle drei
  Artefakte führen denselben Stand: ADR `Geschichte` *„Überarbeitet (Runde 6)"* (`:386`, dazu die
  nachgetragene Runde-5-Zeile `:387`), [`docs/plan/adr/README.md`](../plan/adr/README.md)`:19`
  *„**Proposed** (Runde 6)"*, `docs/plan/planning/welle-09-modul-15-konformitaet.md:173` *„Status
  **Proposed**, nach der sechsten Runde"*. Der Index beschreibt außerdem korrekt, was die ADR
  entscheidet. Was von diesem Befund bleibt, ist nicht die Drift, sondern der **Inhalt** einer der
  Zeilen (→ F6-1).
- geprüft, ohne Befund: **R5-5(a) ist gelöst** — die Überschrift behauptet nicht mehr das
  Gegenteil dessen, was darunter entschieden ist. (Was sie stattdessen behauptet, steht als F6-3;
  offen bleibt R5-5(b) als F6-5.)
- geprüft, ohne Befund: **R5-7 ist gelöst.** Die Default-Zeile entscheidet jetzt ausdrücklich über
  den **Werkzeug-NAMEN** statt über eine Gattung (*„die Zeilen oben sind auf konkrete Namen
  abzubilden, und was nicht namentlich gelistet ist, fällt hierher"*), und die
  Fitness-Function-Zeile 2 ist mitgezogen (*„Ein Werkzeug, das **nicht namentlich** im Schema
  steht"*). Ich habe geprüft, ob die Namensliste ein Zuhause hat: Festlegung 1.3 erklärt das
  Schema für geschlossen (*„erfasst wird, was darin steht"*), Folgepflicht 1 führt es als
  `MR-<NNN>` in [`harness/conventions.md`](../../harness/conventions.md), und die
  Fitness-Function-Zeile prüft gegen genau dieses Schema — die Kette schließt sich, ohne dass die
  ADR die Namen selbst aufzählen müsste (was Festlegung 1 mit guten Gründen ablehnt).
- geprüft, ohne Befund: **R5-9 ist gelöst.** Folgepflicht 5 ist auf die stdout-Setzung umgewidmet
  und benennt genau die von R4-3/R5-9 beschriebene Kindprozess-Hälfte (*„die fd 1 erben"*, *„verliert
  ihre Zähne lautlos, wenn jemand die Umleitung entfernt"*). Der Mutations-Fall ist damit als
  Folgepflicht beauftragt statt als Fitness Function behauptet — die korrekte Form für etwas, das
  es noch nicht gibt.

### Beleg-Prüfung: jede „gemessen"-Aussage an ihrer Quelle

Der besondere Prüfauftrag. Geprüft wurde **jede** Stelle, die im Text als *gemessen*, *belegt*,
*verbatim* oder *laut Quelle* auftritt — an der Quelle, nicht an der ADR und nicht an den
Vorrunden.

**Halten vollständig (21):**

- geprüft, ohne Befund: **Modul 15 §Kernidee.** `modul-15-observability.md:16-19` verbatim:
  *„beobachtest du einen Agentenlauf als **Trace aus Spans** — einen pro Tool-Call. Der teuerste
  Span trägt Korrelations-IDs …"*. Die Kontext-Wiedergabe der ADR ist korrekt.
- geprüft, ohne Befund: **Beide Modul-15-Listen (Festlegung 1.1).** `:33` verbatim
  *„`tool.name`, `tool.arguments` (redacted), `tool.result.status` plus Korrelations-IDs zu
  Slice/PR/Agent-Rolle"*; `:34` verbatim *„Pflicht-Minimum: Slice-ID, Agent-Rolle, Cache-Status,
  `requirement.id` — jede Abweichung davon begründest du"*. Keine ist verkürzt, keine gegen die
  andere ausgespielt.
- geprüft, ohne Befund: **Das Modul-15-Zitat in Alternative B.** `:34` verbatim: *„Ein Attribut
  ohne Incident-Frage fliegt raus"*.
- geprüft, ohne Befund: **„der Guard behält nichts".** `grep -E "log|tee|>>"` über
  `.claude/hooks/pretooluse-command-guard.sh` → **exit 1, keine Zeile**. Selbst gefahren.
- geprüft, ohne Befund: **„in beiden Agenten-Werkzeugen verdrahtet und ins Ziel-Repo emittiert".**
  `.claude/settings.json` (`PreToolUse`/`Bash` → Guard, `Stop` **ohne Matcher** →
  `stop-require-gates.sh`) und `.codex/hooks.json` gelesen; `internal/emit/enforce.go:46/56`
  emittiert `.claude/settings.json` und den Guard ins Ziel. Alle drei Teilaussagen halten.
- geprüft, ohne Befund: **„ein leerer Matcher trifft alle Tools".** An der Quelle verbatim:
  *„`"*"`, `""` oder weggelassen | Alle treffen | wird bei jedem Auftreten des Ereignisses
  ausgelöst"*.
- geprüft, ohne Befund: **„dokumentiert sind 600 s".** An der Quelle: *„Standardwerte: 600 für
  `command`, `http` und `mcp_tool`"*, je Hook per `timeout`-Feld überschreibbar — die Setzung
  „eigener harter Timeout deutlich darunter" ist damit umsetzbar.
- geprüft, ohne Befund: **„ein Nach-Event mit dem Tool-Ergebnis und ein eigenes
  Fehlschlag-Event".** An der Quelle verbatim: *„**PostToolUse** After a tool call succeeds"* /
  *„**PostToolUseFailure** After a tool call fails"*.
- geprüft, ohne Befund: **„`transcript_path` als Brücke zu den Token-/Cache-Zählern" und „der
  Cache-Status steht im Transkript, nicht in der Payload" (Regel 1.4).** An der Quelle: `transcript_path`
  ist gemeinsames Eingabefeld (*„Pfad zur Gesprächs-JSON"*), und die Payload führt **keine**
  Token- oder Cache-Zähler. Beide Aussagen halten — die zweite ist die Grundlage des einzigen
  offen gelassenen Feldes und damit besonders relevant.
- geprüft, ohne Befund: **„Hooks feuern auch in Subagenten, mit `agent_id`/`agent_type` in der
  Payload".** An der Quelle verbatim: `agent_id` *„Nur vorhanden, wenn der Hook innerhalb eines
  Subagenten-Aufrufs ausgelöst wird"*; `agent_type` *„Agent-Name … Vorhanden, wenn die Sitzung
  `--agent` verwendet oder der Hook innerhalb eines Subagenten ausgelöst wird"*.
- geprüft, ohne Befund: **„es gibt kein entscheidungsfreies Ereignis" und „`Stop`/`SubagentStop`
  sind blockierbar".** An der Quelle verbatim: die Tabelle listet
  *„UserPromptSubmit, UserPromptExpansion, PostToolUse, PostToolUseFailure, PostToolBatch, Stop,
  SubagentStop, ConfigChange, PreCompact | Top-Level `decision`"*; Exit 2 bei `Stop` →
  *„Verhindert, dass Claude stoppt"*, bei `SubagentStop` → *„Verhindert, dass der Subagent
  stoppt"*.
- geprüft, ohne Befund: **„dieses Repo betreibt bereits einen zweiten fail-closed Hook —
  `stop-require-gates.sh` auf `Stop`, der bei Exit 0 ein `{"decision":"block"}` schreibt".**
  Gelesen: `.claude/hooks/stop-require-gates.sh:38` und `:51` schreiben `"decision": "block"`,
  `:23`/`:32`/`:59` schreiben `"decision":"approve"`; `.claude/settings.json` registriert ihn auf
  `Stop` **ohne** Matcher. Beide Hälften halten.
- geprüft, ohne Befund: **„`awk` beendet sich bei einem fatalen Fehler mit Exit 2".** **Real
  ausgelöst** (Skalar-/Array-Konflikt sowie fehlende `-f`-Datei) → beide Male **Exit 2**. Die
  Begründung der Exit-Klemme ist gemessen, nicht angenommen.
- geprüft, ohne Befund: **„das Zustands-Verzeichnis ist 775, die Stempeldatei 664".**
  `ls -la .harness/state/` → `drwxrwxr-x` und `-rw-rw-r--`. Beide Zahlen stimmen.
- geprüft, ohne Befund: **„sie ist nie committet".** `git ls-files .harness/state` → **0
  Einträge**; `.gitignore:5` führt `.harness/state/`.
- geprüft, ohne Befund: **„die einzige Stelle, die den Baum kopiert (`harness/tools/mutate.sh`),
  schließt den Zustands-Bereich ausdrücklich aus".** `grep -n "exclude" harness/tools/mutate.sh` →
  **genau ein Treffer**, `:152`.
- geprüft, ohne Befund: **„Die 16 Host-Skripte dieses Repos, der Guard und der Stop-Hook".**
  `ls harness/tools/ | wc -l` → **16**; `.claude/hooks/` enthält genau die zwei genannten.
- geprüft, ohne Befund: **das `ADR-0004`-Zitat.**
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md)`:33` verbatim: *„`awk` ist POSIX-Basis
  (überall vorhanden, wo die bash-Hooks laufen) — kein neuer Dep"*.
- geprüft, ohne Befund: **`LH-QA-03` verbatim, in beiden Richtungen.** `spec/lastenheft.md`
  gelesen: Messmethode *„Smoke: Binary auf frischem System mit nur git + docker → Bootstrap
  grün"* und für die emittierte Seite wörtlich *„Emittierte Ziel-Repos bleiben
  make/docker-getrieben."* Beide Zitate der ADR sind wortgleich, und die Lesart „die
  Bootstrap-Klausel meint die **Nutzer**-Laufzeit" ist am Wortlaut korrekt — die Anforderung
  spricht von *„die Laufzeit **beim Bootstrap**"*.
- geprüft, ohne Befund: **„liegt kein Slice in `in-progress/` — der Zustand *heute*".**
  `ls docs/plan/planning/in-progress/` → **genau `roadmap.md`**, kein Slice. `open/` enthält
  slice-059, `next/` ist leer.
- geprüft, ohne Befund: **die Zahlen der Kürzungs-Commit-Message.** *„390 statt 415 Zeilen"* →
  `wc -l` → **390**. *„d-check 234/0, comment-claims 31/0"* → eigene Läufe dieser Sitzung:
  `make docs-check` → **234 Datei(en) geprüft, 0 Befund(e)**; `make comment-claims` → **31
  Datei(en) geprueft, 0 Befund(e)**. Beide unabhängig bestätigt.

**Hält der Sache nach, aber nicht als Wortlaut (1):**

- **Der zitierte bats-Testfall-Titel.** Die ADR schreibt *„Testfall *„die Kopie trägt den
  Sensor-Bedarf inklusive .git"*"* — der reale Titel lautet
  `driver: die Kopie traegt den Sensor-Bedarf inklusive .git` (ASCII-`ae`, mit `driver: `-Präfix).
  Der Test **existiert** und assertiert genau das Behauptete; die Kursivsetzung suggeriert aber
  einen Wortlaut, den eine Suche im Repo nicht findet. **Kein eigenes Finding**, weil die Aussage
  in der Sache belegt ist und die ADR für diese Zeile ausdrücklich **keinen** `# expect:`-tragenden
  Mutations-Fall vorsieht — der einzige Pfad, auf dem ein nicht-exakter Titel mechanisch
  fehlgehen könnte. Als Beleg-Hygiene dennoch festgehalten.

**Hält nicht als Quellen-Aussage (1):**

- **„Subagenten teilen laut Quelle die Sitzungs-Kennung"** → die `session_id`-Zeile der Quelle
  lautet vollständig *„Current session identifier"* und differenziert für Subagenten nicht; die
  Aussage ist eine plausible Ableitung aus dem Zweck von `agent_id`, keine Aussage der Quelle
  (→ **F6-7**).

**Bewertung des Musters.** Die zwei Fehlgriffe, an denen Runde 5 die ADR gestoppt hat, sind
**beide behoben und von mir unabhängig nachgemessen** — das ist der erste Durchgang, in dem keine
Sensor-Aussage dieser ADR an ihrer Quelle fällt. Was bleibt (F6-7, F6-9), ist keine falsche
Behauptung mehr, sondern eine **Attribution**, die schärfer ist als ihre Quelle. Die Klasse hat
sich also abgeschwächt, ist aber nicht verschwunden: nach §Kontext-Eskalation bleibt der
Steering-Loop-Eintrag stehen — *eine Aussage über eine Quelle gehört an ihr **gelesen**, und
„laut Quelle" nur dort, wo die Quelle es sagt*.

### Was ich sonst geprüft und **nicht** beanstandet habe (mit Beleg)

- geprüft, ohne Befund: **Alle neun Fitness-Function-Zeilen sind rot zu bekommen — oder sagen
  ausdrücklich, dass und warum sie es nicht sind.** Die vier `test/mutations/`-Zeilen (fehlendes
  Pflicht-Feld · nicht namentlich gelistetes Werkzeug · Ablageort auf nicht-ignorierten Pfad ·
  unterschlagener Span) sind reguläre Fälle in der Form dieses Repos; `narrow_sensor` bildet einen
  bats-Titel korrekt auf `test-bats` ab (gelesen, `mutate.sh:211-225`) und `failure_form test-bats`
  liefert `not ok [0-9]+` (`:227-235`). Die drei bats-Zeilen (0600 · Exit-Klemme · stdout leer) sind
  hermetisch messbar; die stdout-Zeile ist ehrlich begrenzt (*„unter allen geprüften
  Fehlerfällen"*) statt über alle Pfade quantifiziert. Die neunte Zeile ist die korrekt begründete
  Nicht-Zeile (s. R5-2). **Keine tautologische Zeile**, und der Abschnitt *„Was hier bewusst NICHT
  steht"* führt beide in Runde 1 gestrichenen unverändert fort.
- geprüft, ohne Befund: **Form nach Modul 4 und Vorlage.** Gegen
  `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md` abgeglichen: die
  Block-Reihenfolge (Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness
  Function · Re-Evaluierungs-Trigger · Geschichte) ist **exakt** eingehalten; alle Kopf-Felder
  vorhanden (Status · Datum · Autor · Bezug · Schärft, letzteres korrekt `—` für eine
  Prozess-ADR); **fünf** Alternativen (≥ 3 nach §Ziel-Form), jede mit Pro **und** Contra; kein
  Template-Hinweis-Block. Die zwei von Runde 5 benannten Reihenfolge-Formsachen (Folgepflicht 5 vor
  4; E vor D in der Tabelle) bestehen fort und bleiben **ohne Failure-Szenario**, also kein Finding.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4 und §3.5.** Der Kürzungs-Commit
  betrifft eine *Proposed*-ADR, überschreibt keine *Accepted*-ADR, beansprucht kein *Supersedes*
  und lockert kein Gate. `.claude/settings.json`, `Makefile`, `test/` und `spec/` sind im Diff
  **nicht** enthalten (gemessen an `git show 4789149 --stat`: **eine** Datei). Status ist im
  Dokument (`:3`), im Index und in welle-09 **Proposed**; slice-059 liegt in `open/`, `next/` ist
  leer.
- geprüft, ohne Befund:
  **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).**
  Kein `spec/lastenheft.md` im Diff; die ADR ändert kein `LH-*`, sie referenziert nur. Festlegung 5
  hält die Ob/Wie-Teilung sauber: das **Ob** der Emission gehört slice-062 samt CR, das **Wie**
  entscheidet die ADR, und die Aufzählung der ins Ziel gezogenen Eigenschaften ist mit dem, was die
  ADR im Repo entscheidet, deckungsgleich.
- geprüft, ohne Befund:
  **[`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed).**
  Gelesen (`harness/conventions.md:784-790`): Geltungsbereich ist *„jeder Prüfbereich, dessen
  Schärfe wir für **unbekannte** Nutzer festlegen"*. Festlegung 2 (kein Inhalts-Hash auf der
  emittierten Ebene) und Festlegung 5 (keine laxere Fassung für fremde Repos) wenden die Regel in
  der richtigen Richtung an.
- geprüft, ohne Befund:
  **[`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  und [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption).**
  Die Herleitung von Festlegung 3 (ein Span im getrackten Baum bräche den inhaltsbasierten
  Nachweis, der Stop-Hook blockierte sich selbst) ist unverändert und in vier Vorrunden bestätigt;
  der gitignorierte Zustands-Bereich ist der korrekte Ablageort (selbst gemessen: `.gitignore:5`,
  `git ls-files` leer). Der Ablageort des Emitters selbst bleibt der ADR überlassen; slice-059
  verortet ihn unter `harness/tools/` — im Einklang mit `MR-005`.
- geprüft, ohne Befund: **Kollision mit aktiven ADRs — weiterhin keine.**
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) bindet den Tool-Build und wird von einem
  Hook-Skript nicht berührt; [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) trägt die
  bash/awk-Bauart, an die Festlegung 4 in korrekt eingegrenzter Weise anknüpft (die Eingrenzung
  *„für die Bauart der Durchsetzungsschicht, nicht für die Frage, was ins Ziel emittiert wird"*
  hat die Kürzung erhalten).
- geprüft, ohne Befund: **Quadranten-Kennzeichnung der Re-Evaluierungs-Trigger.** Gegen
  `grundlagen-klassifikation.md` geprüft: alle sechs Trigger tragen eine ehrliche
  *feedforward*-Kennzeichnung, keiner behauptet einen Sensor, den es nicht gibt. Die
  Latenz-Schwelle (50 ms im Median) nennt weiterhin ihre Herkunft (*„eine Setzung, keine
  Messung"*) und ihre Änderungsregel; die Kürzung hat den Abschnitt nicht berührt.
- geprüft, ohne Befund: **Konsistenz von `Geschichte`, Index, Slice und Welle.** Vier Artefakte,
  ein Stand: ADR `:3`/`:386` · [`README.md`](../plan/adr/README.md)`:19` · welle-09 `:173` ·
  slice-059 (führt ADR-0011 als **Proposed** und bleibt deshalb in `open/`). Die von R3-8/R4-13/R5-4
  über vier Runden verfolgte Drift ist geschlossen; was bleibt, ist der **Inhalt** einer Zeile
  (F6-1), nicht ihr Fehlen.
- geprüft, ohne Befund: **Die Entscheidung selbst.** Ich habe sie ergebnisoffen und ohne die
  Vorrunden-Verdikte gegen die fünf Alternativen gelesen: lokale Erfassung mit Policy · abgeleitete
  Werte mit benanntem Bedrohungsmodell und ebenen-abhängiger Schärfe · Ablage außerhalb des
  versionierten Baums mit selbst gesetztem `0600` · fail-**open** im Betrieb bei fail-**closed**
  Umfang, konstruktiv am Emitter statt an der Ereignis-Wahl · Randbedingung „vorhanden statt zu
  installieren" · Ob/Wie-Teilung mit CR. **Kein Punkt davon ist strittig**, und **keiner der neun
  Befunde dieser Runde verlangt, eine Festlegung zu ändern** — alle betreffen Text, Belege,
  Nachzieh-Kanten und eine Begriffs-Kollision.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | **0** |
| MEDIUM | 2 |
| LOW | 5 |
| INFO | 2 |

**Herkunft der Befunde.** **2** entstehen erst durch die Kürzung (F6-1, F6-2) — und **beide sind
Text-Defekte, keiner betrifft eine Festlegung**. **7** sind Reste bzw. Regressionen aus den
Vorrunden (F6-3 = R5-6 + verschärft durch die R5-5(a)-Reparatur, F6-4 = Regression von R4-14,
F6-5 = R5-5(b), F6-6 = Rest von R4-10/R5-8, F6-7 = Klasse von R4-4/R5-3, F6-8 = R5-10/R5-11/R5-12,
F6-9 = neu, aber an der ungepinnten Quelle, nicht an der ADR).

**Trend über sechs Runden:** HIGH 2 → 3 → 1 → 3 → 2 → **0**; Gesamtbefunde 11 → 15 → 12 → 17 → 12
→ **9**. **Zum ersten Mal fällt keine Sensor- oder Gate-Aussage dieser ADR an ihrer Quelle**, und
zum ersten Mal gibt es keinen blockierenden Befund.

## Verdikt

**Antwort auf Leitfrage 1 — hat die Kürzung Substanz mitgenommen? Nein.** Ich habe alle vier
ehrlichen Grenzen einzeln gegen den Vor-Stand gehalten: sie stehen unverändert und im Wortlaut.
Kein interner Verweis zeigt ins Leere, keine Nummerierung ist gebrochen, keine Festlegung, keine
Alternative und keine Fitness-Function-Zeile ist inhaltlich verändert. Von elf Kürzungsstellen
tragen zehn einen vollständigen Ersatzsatz. Der Durchgang hat getan, was er zu tun vorgab —
**mit genau zwei Ausnahmen**: ein Satz hat sein Satzende verloren (F6-2), und die `Geschichte`
zeigt jetzt auf Text, den es nicht mehr gibt (F6-1). Beides ist Reparatur-Arbeit von wenigen
Zeilen.

**Antwort auf Leitfrage 2 — ist die ADR jetzt annehmbar?**

**Kann ADR-0011 in dieser Fassung, unverändert, auf *Accepted* gesetzt werden: nein.**
**Ist die Entscheidung annehmbar: ja — und zum ersten Mal ohne Einschränkung.** Die Trennung, wie
verlangt:

**Blockierend: nichts.** Es gibt in dieser Runde **kein HIGH**. Keine Zusage ohne Sensor, kein
halluziniertes Gate, kein Verstoß gegen eine aktive ADR oder eine Hard Rule, keine Gate-Lockerung.
Die beiden Befunde, an denen Runde 5 die ADR gestoppt hat, sind behoben und von mir unabhängig
nachgemessen (`make test-bats` selbst gefahren, `ok 89`; `mutate.sh:152` selbst gelesen). Die
Entscheidung ist in keinem Punkt strittig.

**Vor der Umsetzung zu erledigen (2 MEDIUM) — nicht für die Entscheidung, aber vor dem Einfrieren
durch [`AGENTS.md`](../../AGENTS.md) §3.4:**

1. **F6-1:** Die `Geschichte`-Zeile zu Runde 6 behauptet, die zwei Fehlgriffe stünden *„im Text"* —
   die Kürzung hat sie dort entfernt. Die ADR macht eine falsche Aussage über ihren eigenen Body,
   und §3.4 macht sie danach unkorrigierbar.
2. **F6-3:** *„Strom"* ist in Festlegung 3 *je Sitzung* und in Folgepflicht 4 *je Agent* — dieselbe
   ADR entscheidet die Ablage-Frage zweimal verschieden. Der Implementer muss sich entscheiden,
   und beide Wege brechen je eine andere Zusage.

**Formsache (5 LOW / 2 INFO):** der verlorene Satzabschluss in Folgepflicht 4 (F6-2), das aus dem
Body verschwundene `LH-QA-01` (F6-4), das Aufräum-`make`-Ziel ohne Folgepflicht (F6-5), die zwei
Allowlist-Reste (F6-6), das *„laut Quelle"* über die Sitzungs-Kennung (F6-7), die drei
unveränderten Vorrunden-Reste GNU/BSD · `transcript_path` · Verzeichnis-Rechte (F6-8) und die
Sprachfassungs-Divergenz der ungepinnten Quelle (F6-9). Dazu die doppelte Leerzeile bei `:209-210`
und die zwei Reihenfolge-Formsachen aus Runde 5 — beide ohne Failure-Szenario und deshalb kein
Finding.

**Trägt die ADR jetzt genug, um slice-059 zu entsperren?** Für alles außer der Ablage: **ja**. Der
Slice könnte heute das Schema, die abgeleitete Redaktion, den fail-closed Default über
Werkzeug-Namen, die Exit-Klemme, die stdout-Setzung und acht der neun Fitness-Function-Zeilen bauen,
ohne auf eine Auslegung angewiesen zu sein. Was er **nicht** entscheiden kann, ohne der ADR zu
widersprechen, ist die eine Frage aus F6-3: eine Datei je Sitzung oder je Agent.

**Was ausdrücklich trägt und nicht anzufassen ist.** Die abgeleitete Redaktion mit benanntem
Bedrohungsmodell und ebenen-abhängigem Hash-Verzicht — methodisch weiterhin der beste Teil dieser
ADR, und ihre drei Messungen halten jetzt alle drei. Festlegung 4 als **Kriterium** statt als
Liste. Die Konstruktion von Festlegung 6 am Emitter statt an der Ereignis-Wahl, deren Begründung
ich am realen `awk` (Exit 2) und am realen zweiten `Stop`-Hook (`"decision": "block"`) bestätigt
habe. Die Ob/Wie-Teilung mit CR. Die vier ehrlichen Grenzen, die diese Kürzung nicht angetastet
hat — sie sind der Grund, warum diese ADR trotz sechs Runden besser geworden ist statt glatter.
Form nach Modul 4 vollständig, Status nirgends vorgreifend, keine Kollision mit einer aktiven ADR,
`make docs-check` 234/0, `make comment-claims` 31/0, `make test-bats` 127/127 grün — alles selbst
gefahren.

**Übergabe:** an den **ADR-Autor** (Rückkante Review → Architektur/Planung; die ADR bleibt bis zur
Erledigung von F6-1 und F6-3 *Proposed*). F6-3 zusätzlich an die **Planung**, weil die Antwort die
DoD (2) von slice-059 berührt. Als **Steering-Loop-Eintrag**, in abgeschwächter Fortschreibung des
Runde-5-Eintrags: *„laut Quelle" nur dort schreiben, wo die Quelle es sagt — eine Ableitung ist
zulässig, aber sie heißt Ableitung.* Und als zweiter Eintrag, neu aus dieser Runde: *wer
Begleittext streicht, prüft die Stellen, die auf ihn zeigen* — F6-1 und F6-2 sind beide von der
Kürzung erzeugt, beide außerhalb des gekürzten Absatzes. Es gibt keinen Produktiv-Diff. slice-059
bleibt in `open/`. Der Report ersetzt keine Verifikation — DoD-Konformität prüft der Verifier
separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

# Review-Report: ADR-0011 (Proposed) — Telemetrie-Erfassung, Policy für Agenten-Spans — 2026-07-28

**Review-Art:** **Proposed-Review einer ADR** — geprüft wird eine Entscheidung, die noch **nicht**
angenommen und damit noch änderbar ist ([`AGENTS.md`](../../AGENTS.md) §3.4 greift erst ab
*Accepted*). Kein Produktiv-Diff; Eingabe ist das Entscheidungs-Artefakt selbst plus sein
Plan-Kontext. Die Begründungen der ADR sind **Prüfgegenstand, nicht Wahrheit**. **Nicht** geprüft:
Code, DoD-Abhakung (Modul 11, getrennter Kontext).

**Gegenstand:** [`docs/plan/adr/0011-telemetrie-erfassung-policy.md`](../plan/adr/0011-telemetrie-erfassung-policy.md)
(Status **Proposed**), im Kontext von
[`docs/plan/planning/welle-09-modul-15-konformitaet.md`](../plan/planning/welle-09-modul-15-konformitaet.md)
und `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md`. <!-- d-check:ignore (Lifecycle-Pfad: die Slice-Datei wandert durch open/next/in-progress/done) -->

**Commit-Range:** `git log --oneline origin/main..HEAD` → 9 Commits, davon für diesen Review
tragend: `2645f9f` + `65a97ce` (welle-09/slice-059), `022b2c1` (Plan-Review-Nacharbeit),
`adf646e` (ADR-0011 Proposed), `3b64307` (Hook-Oberfläche gemessen).

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ 1.4.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Regelwerk (Baseline v3.5.2, vendored): `modul-04-architektur-adrs.md` §Ziel-Form: ADR (die
  Form, gegen die geprüft wird), `modul-15-observability.md` (der Gegenstand),
  `modul-07-carveouts.md` §Auflösungs-Trigger, `grundlagen-klassifikation.md` §Quadranten
- Vorlage: `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Wortlaut gelesen, nicht
  aus der ADR übernommen)
- Aktive ADRs auf Kollision geprüft: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md),
  [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md),
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md), [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md)
- Adaptionen: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.1, §3.4, §3.5, §3.6
- Vorherige Findings am gleichen Modul: [`docs/reviews/2026-07-28-welle-09-plan-review.md`](2026-07-28-welle-09-plan-review.md)
  (F-2/F-3 HIGH, F-4 „ADR vor slice-059") — ADR-0011 ist die Antwort darauf und wird auch daran
  gemessen; Muster-Präzedenz für die Form: [`2026-07-27-adr-0010-proposed-review.md`](2026-07-27-adr-0010-proposed-review.md)
  und dessen Runden 2/3
- **Eigene Messungen dieser Sitzung** (nicht aus der ADR übernommen): `make docs-check` →
  **d-check 229/0**; `harness/tools/working-tree-hash.sh` gelesen; `Makefile:231` (`gates`-Kette)
  gelesen; `.gitignore` + `ls -la .harness/state/` gemessen; `grep -nE "log|tee|>>"` im Guard →
  leer (Exit 1); `.claude/settings.json` → `"matcher": "Bash"`; **die Hook-Doku
  (<https://code.claude.com/docs/de/hooks> und `/en/hooks`) zweifach direkt abgerufen**, statt der
  ADR zu glauben

---

## Findings

### F-1 — Fitness-Function-Zeile 4 kann unter keiner Mutation rot werden: `make gates` enthält keinen span-erzeugenden Schritt

- `kategorie`: **HIGH**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Eine Fitness Function, die unter keiner Mutation
  rot wird, ist Dekoration") · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  `modul-04-architektur-adrs.md` §Ziel-Form („Jede Entscheidung mit Architektur-Wirkung bekommt
  eine Fitness Function — sonst ist sie Absichtserklärung")
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:153` (Fitness-Function-Tabelle, vierte
  Zeile), nachrangig `:152` (dritte Zeile)
- `befund`: Zeile 4 nennt als Regel „ein Lauf mit geschriebenen Spans lässt den Working-Tree-Hash
  unverändert" und als Make-Target `make gates`. `make gates` ist
  `baseline-verify docs-check lint build test shell-lint ci-lint comment-claims record-gates`
  ([`Makefile`](../../Makefile):231) — **kein** Schritt darin erzeugt Spans, und `record-gates`
  berechnet den Hash **einmal am Ende**, vergleicht ihn nicht über einen span-erzeugenden Lauf
  hinweg. Verschärfend: [`harness/tools/working-tree-hash.sh`](../../harness/tools/working-tree-hash.sh):14
  ruft `git ls-files -z --cached --others --exclude-standard` — `--exclude-standard` schließt
  **jeden gitignorierten Pfad unbedingt** aus. Die zugesagte Eigenschaft gilt damit für einen
  gitignorierten Ablageort *per Konstruktion*, unabhängig davon, was der Emitter tut. Der einzige
  reale Beobachter einer Verletzung wäre der Stop-Hook — und der **blockiert die Sitzung**, statt
  einen Gate-Befund zu melden; er steht nicht in der Spalte. Zeile 3 (bats/`make test`) ist
  demgegenüber ein echter Zahn, misst aber eine **schwächere** Eigenschaft als sie behauptet:
  `git status --porcelain` unterscheidet `.harness/state/` nicht von `/bin/` oder `/dist/`
  ([`.gitignore`](../../.gitignore):11 und `:16`), also nicht „außerhalb des versionierten Baums"
  von „irgendwo ignoriert".
  Failure-Szenario: slice-059 legt den Emitter versehentlich in einen **nicht** ignorierten Pfad
  (oder eine spätere Änderung nimmt `.harness/state/` aus der `.gitignore`); der Verifier hakt
  Fitness-Function-Zeile 4 mit einem grünen `make gates` ab, weil `make gates` grün ist und
  **immer** grün bleibt; der Bruch schlägt erst beim Nutzer als selbstblockierender Stop-Hook auf,
  also außerhalb jedes Gate-Protokolls. Die ADR trägt damit als tragende Zusage genau die Klasse,
  die [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  „halluzinierter Gate" nennt: ein benanntes Target, das die benannte Regel nicht prüft.
- `verifizierbar`: ja — `grep -n "^gates:" Makefile` gegen die Regel-Spalte; `grep -n "exclude-standard"
  harness/tools/working-tree-hash.sh`. Kein Gate deckt es (`make docs-check` → 229/0 mit der Zeile
  im Baum).

### F-2 — Keine Konsequenz für Hook-Fehlschlag und Hook-Latenz, auf demselben Pfad, der den fail-closed Guard trägt

- `kategorie`: **HIGH** (Basis MEDIUM, eine Stufe nach §Kontext-Eskalation des Reviewer-Skills —
  dieselbe Beobachtung im Gate-/Sicherheitspfad)
- `quelle`: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) ·
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  (Guard fail-closed) · [`AGENTS.md`](../../AGENTS.md) §3.6 · `modul-04-architektur-adrs.md`
  §Kernidee (Konsequenzen tragen die Schmerzen mit)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:59` (Entscheidungssatz „fail-closed"),
  `:92-100` (Festlegung 4), `:118-144` (Konsequenzen — Fehlschlag/Latenz kommen dort nicht vor)
- `befund`: Die ADR wählt „eine lokale, **fail-closed** Span-Erfassung" und verschiebt in
  Festlegung 4 genau die Wahl, die den Radius eines Fehlschlags bestimmt (welches Event, welcher
  Matcher). Die Konsequenzen-Liste behandelt Eigenbau-Auswertung, Allowlist-Pflege und
  Write/Edit-Payloads — **nicht**, was passiert, wenn der Emitter fehlschlägt oder langsam ist.
  An der Werkzeug-Doku selbst gemessen (2026-07-28, `/en/hooks`, verbatim): *„Exit 2: Blocking
  error … stderr text is fed back to Claude as an error message"*, *„Any other exit code:
  Non-blocking error"*, Default-Timeout für `command`-Hooks **600 Sekunden**. Ein Hook auf dem
  Tool-Pfad entscheidet damit über die Verfügbarkeit **jedes** Tool-Calls; das Wort „fail-closed"
  im Entscheidungssatz benennt keine Achse (Redaktion? Hook?), und die ADR sagt nirgends, ob ein
  gescheiterter Span-Schreibvorgang den Lauf bremst, blockiert oder still durchlässt. slice-059
  führt die Latenz nur als **Messung E** (~380 Hook-Starts je Sitzung) und den Fehlschlag gar
  nicht.
  Failure-Szenario: der Implementer verdrahtet den Emitter im Sinne des Wortes „fail-closed" mit
  Exit 2; ein Encoding-Fehler in einer `Write`-Payload lässt ihn abstürzen, und **jeder** Tool-Call
  des Repos wird geblockt — der Audit-Sensor legt den Harness lahm. Oder umgekehrt: er wählt Exit 0
  bei jedem Fehler, Spans fehlen lückenhaft, niemand merkt es, und die Closure-Matrix von welle-09
  trägt für Block 1/Repo „Sensor". Beide Ausgänge sind mit der angenommenen ADR vereinbar; genau
  das ist die Lücke.
- `verifizierbar`: nein — die ADR trifft die Aussage nicht, also kann kein Lauf sie bestätigen;
  per Lektüre gegen die zitierte Doku feststellbar. (Nach Umsetzung wäre es ein bats-Fall:
  Emitter mit Exit 2 → bleibt der Tool-Call durch?)

### F-3 — Festlegung 1 ist eine Wiedergabe von Modul 15; die Schema-Entscheidung wird per Folgepflicht 1 in ein änderbares Artefakt verschoben

- `kategorie`: **MEDIUM**
- `quelle`: `modul-15-observability.md` §Span-/Audit-Attribut-Regeln (dritter Bullet) ·
  `modul-04-architektur-adrs.md` §Ziel-Form · [`AGENTS.md`](../../AGENTS.md) §3.4 ·
  Vorbefund F-4 aus [`2026-07-28-welle-09-plan-review.md`](2026-07-28-welle-09-plan-review.md)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:62-73` (Festlegung 1) gegen
  `:138-140` (Folgepflicht 1) und `:46-51` (Kontext-Begründung)
- `befund`: Jede Klausel von Festlegung 1 steht bereits in Modul 15: die zwei Listen, die Markierung
  *Pflicht/Optional*, die Incident-Frage je Feld, „ein Feld ohne Incident-Frage wird nicht erfasst"
  und „jede Abweichung davon begründest du". Prüfung auf die Gegen-Entscheidung: die einzige
  denkbare Gegenposition wäre „eine verkürzte Feldliste ohne Begründung ist zulässig" — die
  vertritt niemand, und die Alternativen-Tabelle stellt sie auch nicht zur Wahl (sie vergleicht
  ausschließlich die **Erfassungs-Art** A–D, keine Schema-Frage). Festlegung 1 entscheidet damit
  nichts; sie repariert den Plan-Review-Befund F-2, was eine **Plan-Korrektur** ist, keine
  Architektur-Entscheidung. Das eigentlich zu Entscheidende — welche Felder, welche
  Incident-Fragen, welche Abweichung mit welcher Begründung — verlegt Folgepflicht 1 in einen
  künftigen `MR-<NNN>` in [`harness/conventions.md`](../../harness/conventions.md), also in ein
  Artefakt ohne Immutabilität. Die ADR begründet ihre eigene Existenz aber gerade damit, dass diese
  Entscheidungen sonst „faktisch im ersten Dogfood-Slice" fielen (`:46-51`).
  Failure-Szenario: slice-059 wandert nach `next` mit der Begründung „das Schema ist per ADR-0011
  entschieden"; der Implementer findet in der ADR kein Schema, schreibt es in den `MR`-Eintrag, und
  weil ADR-0011 als *Accepted* immutable ist, schaut niemand mehr nach — die Feldliste samt
  Sicherheitsfläche lebt fortan in einer Datei, die jeder Folge-Slice ändern darf. Das ist F-4 des
  Plan-Reviews, um einen Slice nach vorn verschoben statt aufgelöst.
- `verifizierbar`: nein — Konsistenz-Urteil gegen Modul 15 und die eigene Kontext-Begründung; per
  Zitat-Abgleich mit `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:34` feststellbar.

### F-4 — Die zitierte Normativität von `LH-QA-03` stimmt in Geltungsbereich und Wortlaut nicht

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Rang 1,
  [`AGENTS.md`](../../AGENTS.md) §2) · [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  („weder ADR noch Slice dürfen `LH-*` je ändern — sie referenzieren nur") ·
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:96-99`
- `befund`: Die ADR schneidet zu — Zitat mit entschärften Link-Klammern: `im Repo Docker-only
  (ADR-0003), im emittierten Ziel **zusätzlich** LH-QA-03 (bash + git + docker)`. Beides ist am
  Quelltext falsch.
  (a) **Geltungsbereich:** `LH-QA-03` bindet ausdrücklich auch dieses Repo — verbatim: *„Der
  Tool-Build läuft reproduzierbar im gepinnten Image (Go-Toolchain, Cross-Compile) — **kein
  Host-`go`** (Docker-only)."* Die Docker-only-Regel der Repo-Ebene **ist** `LH-QA-03`;
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) leitet sie von dort ab (§Konsequenzen:
  „`LH-QA-03` ohne Host-Toolchain"). Die ADR nennt für die Repo-Ebene die rangniedrigere Quelle
  (Rang 3) und stellt die ranghöhere (Rang 1) als emittiert-only dar.
  (b) **Wortlaut:** `LH-QA-03` sagt *„die Laufzeit beim Bootstrap braucht nur **git + docker**"* —
  `bash` steht dort nicht. Die ADR erweitert den zitierten Abhängigkeitssatz um ein drittes
  Element. Dass bash/awk in der Praxis tragbar ist, hat
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) separat begründet (Guard-Parser,
  node/jq abgelehnt) — diese Ableitung zitiert ADR-0011 nicht, sie schreibt das Ergebnis in die
  Anforderung hinein.
  Failure-Szenario: der Autor von slice-062/063 liest ADR-0011 als Randbedingung, hält `bash` für
  vertraglich zugesichert und emittiert einen bash/awk-Emitter ohne den ADR-0004-Beleg; und
  gleichzeitig hält er die Repo-Ebene für nur ADR-gebunden (Rang 3) und damit für per ADR
  lockerbar — während die Grenze in Wahrheit im Lastenheft steht und nur ein CR sie bewegt
  ([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  Der Fehler ist im Repo bereits doppelt verteilt (welle-09 §6, slice-059 §1 tragen denselben
  Satz), wird also durch Annahme der ADR normativ zementiert.
- `verifizierbar`: ja — `sed -n '268,277p' spec/lastenheft.md` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:96-99`. Kein Gate deckt es (`docs-check`
  prüft Link-/Anker-Existenz, nicht Zitat-Treue).

### F-5 — Eine ernsthafte Alternative fehlt: der Korrelations-Hook ohne Payload

- `kategorie`: **MEDIUM**
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form („Mindestens drei Verglichene Alternativen,
  jede mit Trade-off") · `modul-15-observability.md` §Span-/Audit-Attribut-Regeln · ADR-0011
  §Konsequenzen (`:134-137`)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:109-116` (Alternativen-Tabelle) gegen
  `:134-137` („Negativ, und jetzt der schärfere Punkt")
- `befund`: Die Tabelle stellt A (nichts tun) · B (OTel-Stack) · C (lokale Erfassung, gewählt) ·
  D (nur Transkripte) gegenüber. Nicht verglichen wird die naheliegende Zwischenform: ein Hook, der
  **nur Korrelations-Daten** schreibt (`tool_use_id`, `tool.name`, `slice.id`, `agent.role`,
  Ergebnis-Status, `transcript_path`) und `tool.arguments` **gar nicht** erfasst — die Argumente
  bleiben im ohnehin existierenden Transkript. Diese Option löst exakt die Schwäche, die D
  disqualifiziert (fehlende Korrelations-IDs, `agent.role` als `general-purpose`), und **löscht
  zugleich** die von der ADR selbst als schärfsten Punkt benannte Negativ-Konsequenz: „volle
  Abdeckung heißt, der Hook sieht auch `Write`/`Edit`-Payloads — also Datei-Inhalte … was am
  ehesten Secrets trägt". Ohne diese Zeile erscheint die Sicherheitsfläche als **notwendiger**
  Preis der Erfassung, und die Allowlist (Festlegung 2) als alternativlos. Verstärkend: die
  Contra-Spalte von C nennt die beiden Kosten, die die ADR an anderer Stelle als ihre größten
  benennt (Sicherheitsfläche, laufende Allowlist-Pflege), **nicht** — während A und D „keine neue
  Sicherheitsfläche" als **Pro** gutgeschrieben bekommen. Die Gegenüberstellung ist damit zugunsten
  von C asymmetrisch.
  Failure-Szenario: die ADR wird angenommen, slice-059 baut Payload-Erfassung samt Allowlist,
  slice-063 emittiert sie an unbekannte Adopter — und die Frage, ob dieses Repo überhaupt jemals
  Tool-Argumente in eine eigene Datei schreiben musste, um Modul 15 zu erfüllen, ist nie gestellt
  worden. Rückabwicklung nach *Accepted* kostet eine Supersedes-ADR
  ([`AGENTS.md`](../../AGENTS.md) §3.4).
- `verifizierbar`: nein — Vollständigkeits-Urteil über den Optionen-Raum; per Lektüre gegen den
  eigenen Konsequenzen-Abschnitt feststellbar.

### F-6 — Keine Konsequenz zu Aufbewahrung, Rotation, Löschung und Leserechten der Spans

- `kategorie`: **MEDIUM**
- `quelle`: `modul-15-observability.md` §Audit-Span-Schema (Incident-Frage als
  Erfassungs-Kriterium) · ADR-0011 §Kontext (`:53-55`, „Audit- und Kosten-Instrument") ·
  Maintainability
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:84-90` (Festlegung 3) und
  `:118-144` (Konsequenzen)
- `befund`: Festlegung 3 entscheidet den **Ort** und nennt die Spans „**flüchtig**" — es gibt aber
  keinen Mechanismus, der sie flüchtig macht. Weder die ADR noch der Plan nennt eine
  Aufbewahrungsdauer, eine Rotation, eine Größengrenze oder einen Lösch-Zeitpunkt; nichts im
  Repo räumt `.harness/state/` auf. Gemessen (2026-07-28): `.harness/state/` ist `drwxrwxr-x`
  (0775), sein Inhalt `-rw-rw-r--` (0664) — **gitignored, aber für Gruppe und Andere lesbar**. Die
  ADR diskutiert die Erfassungs**fläche** (Allowlist, Write/Edit-Payloads) ausführlich und die
  **Ablage** dieser Daten gar nicht. Bei voller Abdeckung („`matcher: ""` erfasst alles — auch
  `Read`", slice-059 Messung F) wächst dort eine unbegrenzte Liste aller gelesenen und
  geschriebenen Pfade eines jeden Laufs.
  Failure-Szenario: nach Wochen Dogfood liegt in `.harness/state/` ein mehrere hundert Megabyte
  großes JSONL mit jedem berührten Pfad und jedem allowlist-passierten Argument; es ist von jedem
  lokalen Konto lesbar, wird von keinem Gate gemessen, von keinem Prozess gelöscht, und wandert
  bei jedem `tar`/Backup/Container-Mount des Arbeitsverzeichnisses mit. Die Allowlist hat die
  **Feld**-Auswahl entschieden und die **Lebensdauer** ungeregelt gelassen — genau die zweite
  Hälfte des Satzes „ein Audit-Log, das Secrets sammelt, ist schlimmer als kein Audit-Log".
- `verifizierbar`: ja — `ls -la .harness/state/` und `grep -rn "state" Makefile` (kein
  Aufräum-Target); die Abwesenheit einer Regel ist per Lektüre der ADR feststellbar. Kein Gate
  deckt es.

### F-7 — Festlegung 5 ist „portabel gemeint" — und damit weder bindend noch unverbindlich

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) ·
  [`AGENTS.md`](../../AGENTS.md) §2 (ADRs sind Rang 3 und normativ) · welle-09 §6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:102-107`
- `befund`: Festlegung 5 trennt sauber („diese ADR gilt für das Repo; die Emission entscheidet
  slice-062 samt CR") und hebt die Trennung im nächsten Satz halb auf: „**Festlegung 2 und 3 sind
  dabei jedoch portabel gemeint** — wenn emittiert wird, dann mit Allowlist und außerhalb des
  versionierten Baums." „Gemeint" ist kein normativer Modus. Eine angenommene ADR ist Rang 3 und
  wirkt; ein Satz, der wirken will, ohne zu binden, hat zwei Leser: Lesart A — es bindet, dann ist
  der Adopter-Vertrag durch eine ADR vorentschieden, bevor der von
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  verlangte CR ihn trägt, und slice-062 entscheidet ein Fait accompli. Lesart B — es bindet nicht,
  dann ist der Satz Dekoration und der emittierte Default steht offen, obwohl
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  („laut falsch schlägt leise falsch") für unbekannte Adopter genau hier eine Setzung verlangt.
  Failure-Szenario: der CR-/ADR-Autor von slice-062 liest Lesart A, behandelt den CR als Formsache
  und bewegt den Adopter-Vertrag ohne den externen Vorgang, den
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 1/2 als eigenen, vorgelagerten Commit verlangt — oder er liest Lesart B und emittiert
  eine Denylist, womit die Kern-Begründung dieser ADR im Ziel in ihr Gegenteil verkehrt wird.
- `verifizierbar`: nein — Normativitäts-Urteil, per Lektüre gegen
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  feststellbar; kein Gate.

### F-8 — Re-Evaluierungs-Trigger 5 hat keine messbare Schwelle; Trigger 2 ist bei Abfassung bereits erfüllt

- `kategorie`: **MEDIUM**
- `quelle`: `modul-07-carveouts.md` §Ziel-Form („**Auflösungs-Trigger als beobachtbare, messbare
  Bedingung** — nicht ‚sobald wir Zeit haben‘, sondern eine Schwelle, die ein anderer Mensch ohne
  Rückfrage als erreicht beurteilen kann") · `grundlagen-klassifikation.md` §Quadranten
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:172-174` (Trigger 5), `:163-167`
  (Trigger 2), `:170-171` (Trigger 4)
- `befund`: Trigger 5 lautet „Wenn die Allowlist in der Praxis mehr blockiert als sie schützt —
  messbar daran, dass Spans **regelmäßig ohne verwertbaren Inhalt** entstehen." Weder „regelmäßig"
  noch „verwertbar" ist eine Schwelle; kein Anteil, kein Zeitraum, kein Beobachter, kein Kommando.
  Trigger 2 („Wenn `agent_type` nicht auf unsere Rollen abbildbar **bleibt**") ist nach dem eigenen
  Text der ADR **heute schon** eingetreten — sie stellt im selben Absatz fest, dass die Payload
  `general-purpose` liefert und die Rollen-Achse ein Sammelposten ist. Ein Trigger, der bei
  Abfassung bereits feuert und keinen Adressaten benennt, verschiebt eine offene Entscheidung in
  die Trigger-Liste. Bemerkenswert ist der Kontrast: Trigger 1 kennzeichnet seinen Quadranten
  ausdrücklich und ehrlich („lebt daher im *inferential-feedforward*-Quadranten und wirkt nur, wenn
  ihn jemand liest") — Trigger 2, 4 und 5 haben denselben Status und **keine** solche
  Kennzeichnung, obwohl die Präzedenz aus [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md)
  im selben Dokument zitiert wird.
  Failure-Szenario: welle-09 schließt; die Allowlist ist zu eng geschnitten und liefert
  strukturlose Spans; niemand kann sagen, ob „regelmäßig" erreicht ist, weil niemand zuständig ist
  und nichts zählt — die Re-Evaluierung findet nie statt, und die ADR bleibt als *Accepted* stehen,
  obwohl ihre Feld-Auswahl nachweislich nicht trägt. Modul 7 nennt das den permanenten Carveout,
  der lügt, hier in der Form eines Trigger-Eintrags.
- `verifizierbar`: nein — Qualitäts-Urteil über die Trigger-Formulierung gegen den Modul-7-Maßstab;
  per Lektüre feststellbar. Kein Gate.

### F-9 — Die „gemessene" Kette trägt einen falschen Feldnamen: dokumentiert ist `tool_output`, nicht `tool_response`

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Kommando neben der Aussage" / gemessen statt
  angenommen) · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · ADR-0011
  §Kontext (`:33-44`) und Re-Evaluierungs-Trigger 1
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:95` (Messung A) — die <!-- d-check:ignore (Lifecycle-Pfad) -->
  Aussage, auf die sich `docs/plan/adr/0011-telemetrie-erfassung-policy.md:33-37` stützt
- `befund`: Die ADR selbst formuliert vorsichtig und **korrekt** („ein Nach-Event mit dem
  Tool-Ergebnis und ein eigenes Fehlschlag-Event") — die Mess-Zeile, aus der sie stammt, ist
  konkreter und falsch: slice-059 Messung A behauptet „**`PostToolUse` liefert `tool_response`**".
  Am 2026-07-28 direkt an der zitierten Quelle abgerufen: das dokumentierte
  `PostToolUse`-Payload-Beispiel führt `tool_name`, `tool_input`, `tool_use_id`, **`tool_output`**
  und `tool_output_path` — ein Feld `tool_response` erscheint nicht. Die übrigen Aussagen derselben
  Messung halten (siehe Negativbefunde). Der Befund ist gering in der Sache, aber typisch für die
  Fehlerklasse, die Re-Evaluierungs-Trigger 1 selbst adressiert: eine ungepinnte, von keinem Gate
  geprüfte Quelle, deren Details beim Abschreiben verrutschen.
  Failure-Szenario: der Implementer parst `tool_response` aus der Payload, bekommt leer, schließt
  daraus „`tool.result.status` ist nicht erfassbar" und zieht die in slice-059 §4 vorgesehene
  Rückführungskante `in-progress → open` — ein Re-Slice wegen eines Tippfehlers in der eigenen
  Messnotiz.
- `verifizierbar`: ja — <https://code.claude.com/docs/en/hooks>, Abschnitt PostToolUse-Input.
  Kein Gate deckt es (`docs-check` läuft netzlos; d-checks `external`-Modul ist aus).

### F-10 — welle-09 verweist nirgends auf ADR-0011, während die ADR welle-09 §4 als ihre Herkunft nennt

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 („Requirement- und ADR-IDs referenzieren") ·
  `modul-04-architektur-adrs.md` §Kernidee („Wenn dein Reviewer-Agent den Grund nicht findet, kann
  er die Entscheidung nicht verteidigen") · Drift-Klasse „derselbe Stand an zwei Orten"
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:180` (Geschichte-Zeile) gegen
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:170-173` und `:113-120` (Slice-Tabelle)
- `befund`: Die Geschichte-Zeile der ADR nennt als Herkunft „welle-09 §4 / slice-059 §6".
  `grep -n "ADR-0011\|0011" docs/plan/planning/welle-09-modul-15-konformitaet.md` liefert **nichts**
  (Exit 1): §4 sagt nur „ADR-Bedarf — vor slice-059 … Solange das nicht als ADR entschieden ist,
  bleibt slice-059 in `open/`", ohne die inzwischen existierende ADR zu nennen; die Slice-Tabelle
  führt für slice-059 weiterhin nur
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) als
  Bezug. Der Rückverweis existiert nur einseitig (slice-059 → ADR-0011).
  Failure-Szenario: der Planner, der slice-059 von `open` nach `next` bewegt, liest die Welle-Datei
  als maßgebliches Planungsartefakt, findet dort die Vorbedingung „ADR entschieden" unerfüllt
  formuliert und hält den Slice weiter zurück — oder umgekehrt, der Autor von slice-062 sucht die
  Vorentscheidung zur Emission in der Welle und findet sie nicht.
- `verifizierbar`: ja — `grep -c "0011" docs/plan/planning/welle-09-modul-15-konformitaet.md` → 0.
  Kein Gate deckt es (`docs-check` prüft die Existenz genannter Kennungen, nicht die Existenz
  fehlender).

### F-11 — Der Bezug führt `LH-QA-01` und `LH-QA-02`, die im Body nie vorkommen

- `kategorie`: **LOW**
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form („Der Kontext *referenziert* die Anforderung")
  · `templates/docs/plan/adr/NNNN-titel.template.md` §Bezug
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:9-11`
- `befund`: Das Bezug-Feld nennt
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) und
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
  `grep -n "LH-QA-01\|LH-QA-02"` trifft ausschließlich die Kopfzeilen 9 und 10 — im gesamten Body
  wird keine der beiden Anforderungen benutzt, weder in Kontext, Entscheidung, Alternativen,
  Konsequenzen noch in der Fitness Function. Nur `LH-QA-03` erscheint zweimal im Body. Das
  Bezug-Feld ist die Aufwärts-Deklaration der Änderungskopplung; eine Anforderung, die dort steht
  und nirgends wirkt, macht die Kopplung unlesbar.
  Failure-Szenario: eine spätere Änderung an
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) löst über den Bezug eine
  Nachzieh-Prüfung von ADR-0011 aus; der Prüfende findet keine Stelle, an der die Anforderung
  wirkt, und kann weder „betroffen" noch „unbetroffen" belegen. (Ironisch tragfähig wäre die
  Nennung durchaus — F-1 ist ein
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Befund;
  nur führt die ADR den Bezug nirgends aus.)
- `verifizierbar`: ja — `grep -n "LH-QA-01\|LH-QA-02" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → nur `:9` und `:10`. Kein Gate deckt es (`docs-check` prüft Link-Auflösung, nicht Verwendung).

## Negativbefunde

- geprüft, ohne Befund: **die Hook-Oberflächen-Aussagen im Kontext (`:33-39`) — selbst an der
  Quelle nachgemessen, nicht aus dem Text übernommen.** Zwei unabhängige Abrufe von
  <https://code.claude.com/docs/de/hooks> und `/en/hooks` am 2026-07-28 bestätigen **alle fünf**
  tragenden Aussagen: (a) ein Nach-Event mit dem Tool-Ergebnis existiert (`PostToolUse`, Payload
  mit `tool_output`/`tool_output_path`); (b) `PostToolUseFailure` existiert als **eigenes** Event
  und liefert `error`; (c) `tool_use_id` ist dokumentiert und trägt über Pre-/Post-Event dieselbe
  ID — als Span-Identität tragfähig, ebenso `session_id`, `transcript_path`, `cwd`; (d) Hooks
  feuern in Subagenten, Payload mit `agent_id` + `agent_type`; (e) **leerer Matcher = alle Tools**,
  verbatim: *„`*`, `""` or omitted — All match — will be triggered at each occurrence of the
  event"*. Damit trägt insbesondere der Konsequenzen-Absatz `:126-133`, der den HIGH-Befund F-3 des
  Plan-Reviews auflöst: die Bash-Enge ist wirklich eine Registrierungs-Entscheidung
  (`.claude/settings.json` → `"matcher": "Bash"`, gemessen), keine Plattform-Grenze. Ein erster,
  flüchtigerer Abruf hatte (e) als „nicht dokumentiert" gemeldet — das ist am Volltext
  **widerlegt** und wird hier ausdrücklich nicht als Befund geführt.
- geprüft, ohne Befund: **die Ist-Aussagen zum heutigen Stand (`:28-31`).** Nachgemessen:
  `grep -nE "log|tee|>>" .claude/hooks/pretooluse-command-guard.sh` → leer (Exit 1); der Guard
  sieht die Payload und behält nichts. Die Aussage „es fehlt nicht die Erfassungsstelle, sondern
  die Senke" hält.
- geprüft, ohne Befund: **die Modul-15-Adoptionsaussage (`:23-26`).** „Seit dem 2026-07-17
  adoptiert und in keinem Block umgesetzt" ist im Plan-Review vom 2026-07-28 (Negativbefund 1)
  gegen `git log --all -- '*modul-15-observability.md'` (vier Re-Vendor-Commits, null inhaltliche)
  bereits nachgezählt bestätigt und hier nicht erneut zu beanstanden.
- geprüft, ohne Befund: **Festlegung 2 (Allowlist) ist eine echte Entscheidung mit echter
  Gegen-Entscheidung.** Die Denylist ist die reale Gegenposition, sie ist benannt, und die
  Verwerfung ist inhaltlich begründet (sie kann unter keiner *realen* Lücke rot werden) statt
  behauptet. Sie löst den Plan-Review-Befund F-5 an der Wurzel und ist konsistent mit der
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Linie.
  Beanstandet wird an anderer Stelle allein, dass die Alternativen-Tabelle diese Achse nicht führt
  (→ F-5) und dass die Ablage der so gefilterten Daten ungeregelt bleibt (→ F-6) — **nicht** die
  Festlegung selbst. Sie ist der tragfähigste Teil dieser ADR.
- geprüft, ohne Befund: **Festlegung 3 ist sachlich richtig hergeleitet.** Der Konflikt ist real:
  [`harness/tools/working-tree-hash.sh`](../../harness/tools/working-tree-hash.sh) hasht getrackte
  **und** untrackte Dateien
  ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)),
  ein Span-File in einem **nicht ignorierten** Pfad ginge ein, und der Stop-Hook blockierte sich
  selbst. Der gewählte Ort ist korrekt. Beanstandet wird die Zahn-Form (→ F-1) und die fehlende
  Lebensdauer-Regel (→ F-6), nicht der Ort.
- geprüft, ohne Befund: **„Spans sind flüchtig … keine Beleg-Quelle für eine Zusage" ist kein
  Selbstwiderspruch.** Naheliegende Lesart wäre, dass ein Audit-Artefakt, das nie Beleg sein darf,
  die Incident-Fragen aus Festlegung 1 nicht beantworten kann. Im Vokabular dieses Repos ist
  „Zusage" jedoch der §3.6-Begriff (Gate-/Test-Behauptung mit rot gesehenem Gegenbeispiel) — der
  Satz sagt also „ein Span taugt nicht als Gate-Nachweis", nicht „ein Span taugt nicht als
  Forensik". Der Vorwurf wird hier ausdrücklich **verworfen**; offen bleibt allein die
  Aufbewahrung (→ F-6).
- geprüft, ohne Befund: **Kollision mit aktiven ADRs — keine.**
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) setzt Docker-only für den **Tool-Build**
  (Cross-Compile, kein Host-`go`); ein bash-Hook auf dem Host ist davon nicht berührt — der
  PreToolUse-Guard und der Stop-Hook laufen seit
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  genau so, und [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) hat den Container-Weg für
  Hooks aus Latenzgründen ausdrücklich verworfen („`docker run` pro Bash-Call ~300–700 ms
  Kaltstart"). [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) (Quellmodell
  der emittierten Durchsetzung) und [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md)
  (Bootstrap-Phasen, Idempotenz) werden von ADR-0011 nicht berührt, weil Festlegung 5 die Emission
  aus dem Geltungsbereich nimmt. Beanstandet wird nur die **Zuschreibung** der Normativität
  (→ F-4), nicht ein Widerspruch in der Sache.
- geprüft, ohne Befund: **`Schärft: —` samt Zeiger auf `architecture.md §5`.** Die Vorlage sieht
  `—` für eine Prozess-ADR ohne Spec-Stratum ausdrücklich vor. Der Zusatz-Zeiger ist tragfähig
  geprüft: `spec/architecture.md` §5 („Idempotenz, Fragment-Assembly und Resume") klassifiziert
  tool-eigene Infrastruktur explizit inklusive **„Hooks, Guard"** als konvergent — ein emittierter
  Span-Emitter fiele genau dorthin. Der naheliegende Vorwurf „falscher Abschnitt" ist damit
  **verworfen**.
- geprüft, ohne Befund: **Quadranten-Einordnung von Trigger 1.**
  `grundlagen-klassifikation.md` führt Quadrant 3 als *Inferential + Feedforward*; die Schreibweise
  der ADR („*inferential-feedforward*-Quadranten") bezeichnet ihn korrekt, und die Einordnung ist
  **ehrlich** — die Quelle ist wirklich ungepinnt und von keinem Gate geprüft (`docs-check` läuft
  `--network none`, verifiziert). Die Präzedenz aus
  [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md) ist korrekt zitiert. Beanstandet
  wird allein, dass Trigger 2/4/5 dieselbe Ehrlichkeit nicht bekommen (→ F-8).
- geprüft, ohne Befund: **Form nach Modul 4 / Vorlage.** Alle Kopf-Felder vorhanden (Status ·
  Datum · Autor · Bezug · Schärft); alle Body-Blöcke in der Reihenfolge der Vorlage (Kontext ·
  Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger · Geschichte); **vier** Alternativen, also ≥ 3, jede mit Pro **und**
  Contra; der Template-Hinweis-Block ist entfernt; Konsequenzen führen Positiv, Negativ und
  Folgepflichten getrennt. Kein Formmangel.
- geprüft, ohne Befund: **ADR-Index aktualisiert.**
  [`docs/plan/adr/README.md`](../plan/adr/README.md):19 führt ADR-0011 mit Titel, Status
  **Proposed** und Bezug — die Pflicht aus [`AGENTS.md`](../../AGENTS.md) §5 („Neue ADRs
  aktualisieren den ADR-Index") ist erfüllt, und der Status ist dort korrekt als Proposed geführt,
  nicht vorgreifend als Accepted.
- geprüft, ohne Befund: **Doc-Gate-Regeln.** `make docs-check` → **d-check 229 Dateien, 0
  Befunde** (eigener Lauf dieser Sitzung). Alle `LH-`/`ADR-`/`MR-`-Kennungen in ADR-0011 sind als
  Link geführt; die relativen Tiefen aus `docs/plan/adr/` stimmen (`../../../spec/`,
  `../../../harness/`, `../planning/`); alle in Inline-Code genannten Pfade existieren
  (`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`, `test/mutations/`,
  `harness/conventions.md`); keine Abwärts-Verweise aus einem `spec/`-Stratum (die ADR verweist
  aufwärts, was die `matrix`-Regel erlaubt).
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4 und §3.5.** Die ADR überschreibt
  keine *Accepted*-ADR und beansprucht kein Supersedes; sie lockert **kein** Gate — sie fügt
  Sensoren hinzu (Verschärfung, kein ADR-pflichtiger Senkungs-Vorgang). Der Review erfolgt
  ausdrücklich **vor** *Accepted*, solange Änderung noch zulässig ist.
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  zum jetzigen Zeitpunkt.** ADR-0011 ändert **kein** `LH-*`; `spec/lastenheft.md` ist im gesamten
  Commit-Range `origin/main..HEAD` unberührt (`git log --stat` geprüft), und Festlegung 5 verortet
  den CR korrekt bei slice-062. Ein CR ist jetzt nicht fällig. Beanstandet wird allein die
  Halbverbindlichkeit des Portabilitäts-Satzes (→ F-7) und die falsch zitierte
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)-Reichweite (→ F-4).
- geprüft, ohne Befund: **[`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption).**
  Die ADR legt keinen Ablageort für ausführbare Tools fest und kollidiert daher nicht mit der
  `harness/tools/`-Konvention; slice-059 verortet den Emitter dort korrekt.
- geprüft, ohne Befund: **Fitness-Function-Zeilen 1 und 2 (`make mutate`).** Beide beschreiben
  Mutationen, die eine reale Gegenprobe haben („Span ohne Pflicht-Feld", „Feld nicht auf der
  Allowlist") und deren Rot-Werden am Artefakt beobachtbar wäre — sie sind Zusagen auf die Zukunft,
  aber prüfbare. Beanstandet wird ausschließlich Zeile 4 (→ F-1). Einschränkung, die nicht als
  eigener Befund geführt wird: solange Festlegung 1 kein konkretes Pflichtfeld benennt (→ F-3),
  hat Zeile 1 noch keinen definierten Gegenstand.
- geprüft, ohne Befund: **die Annahme im Kontext (`:53-55`) ist als Annahme deklariert.** „Audit-
  und Kosten-Instrument, kein Betriebs-Monitoring — kippt das, kippt der Zuschnitt", mit Trigger 4
  als Gegenstück. Das ist genau die von der Vorlage verlangte Form („Welche Annahmen gelten? Wenn
  diese Annahmen kippen, kippt die Entscheidung") und wird hier nicht beanstandet.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 6 |
| LOW | 3 |
| INFO | 0 |

## Verdikt

**Kann ADR-0011 in dieser Fassung auf *Accepted* gesetzt werden: nein.**

**Was blockiert.** Zwei HIGH, und beide betreffen nicht die Wahl, sondern ihre Haltbarkeit.
**F-1** ist der schwerere: die vierte Fitness Function nennt `make gates` als prüfendes Target für
eine Eigenschaft, die `make gates` nicht prüft und nicht prüfen kann — kein Schritt der Kette
erzeugt Spans, `record-gates` vergleicht nichts, und `--exclude-standard` macht die Zusage für
jeden gitignorierten Pfad unbedingt wahr. Nach [`AGENTS.md`](../../AGENTS.md) §3.6 ist das
Dekoration, nach [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
ein behaupteter Gate; und da eine *Accepted*-ADR nicht mehr überschrieben wird (§3.4), zementiert
die Annahme die Behauptung. **F-2** ist die zweite Hälfte davon: die ADR wählt einen Mechanismus,
der vor **jedem** Tool-Call feuert, nennt ihn im Entscheidungssatz „fail-closed" und sagt an keiner
Stelle, was bei Fehlschlag oder Zeitüberschreitung geschieht — während die von ihr selbst zitierte
Quelle Exit 2 als blockierend und 600 s als Default-Timeout dokumentiert. Beide Ausgänge (Harness
blockiert / Spans fehlen still) sind mit der ADR vereinbar.

**Zur Leitfrage „Entscheidungen oder Umformulierungen".** Von fünf Festlegungen tragen **zwei**
eigenständig: **Festlegung 2** (Allowlist statt Denylist) ist eine echte Wahl mit echter, benannter
und begründet verworfener Gegen-Entscheidung — sie ist der stärkste Teil dieser ADR. **Festlegung
3** (außerhalb des versionierten Baums) ist am realen Mechanismus hergeleitet und richtig.
**Festlegung 1** ist eine Wiedergabe von Modul 15, deren einzige Klauseln sämtlich dort stehen; das
eigentlich zu Entscheidende wandert per Folgepflicht 1 in einen künftigen, änderbaren `MR`-Eintrag
(F-3). **Festlegung 5** ist halb verbindlich und damit in beiden Lesarten problematisch (F-7).

**Zu Festlegung 4 — Entscheidung oder Ausweichen?** Hier lautet die Antwort differenziert:
Werkzeug, Event-Wahl und Format **offenzulassen ist legitim** — die Messungen stehen aus, und eine
ADR, die sie vorwegnähme, entschiede gegen Daten, die es noch nicht gibt. Die Grenze verläuft
dort, wo die offene Frage eine **Eigenschaft** berührt, die die ADR selbst zusagt: die Wahl von
Event und Matcher bestimmt Erfassungsumfang **und** Fehlschlag-Radius, und für den zweiten trifft
die ADR keine Randbedingung (F-2). „Keine neue Abhängigkeit" ist als Randbedingung zu wenig, um
die Offenheit zu tragen — und sie ist zudem falsch belegt (F-4).

**Trägt die ADR genug, um slice-059 zu entsperren?** Teilweise. Von den drei Gründen, aus denen
der Plan-Review die ADR verlangt hat — Artefakt-Klasse, Datenfluss, Sicherheitsfläche —, sind
**Datenfluss** (Festlegung 3) und **Sicherheitsfläche** (Festlegung 2) real entschieden. Die
**Artefakt-Klasse** selbst, also das Schema, ist es nicht: sie ist an einen `MR`-Eintrag delegiert,
den der umsetzende Slice schreibt. Damit reproduziert die ADR in abgeschwächter Form genau den
Befund F-4, auf den sie antwortet.

**Was ausdrücklich trägt und nicht anzufassen ist.** Die fünf Aussagen zur Hook-Oberfläche sind an
der Quelle nachgemessen und halten **vollständig**, einschließlich der entscheidenden „leerer
Matcher trifft alle Tools" — die Auflösung des Plan-Review-HIGH F-3 ist echt, nicht behauptet. Die
Ist-Messung zum Guard hält. Die Form nach Modul 4 ist vollständig, der ADR-Index korrekt
nachgezogen, `make docs-check` läuft mit 229/0. Es gibt **keine** Kollision mit ADR-0003/0004/0006/0007.

**Übergabe:** an den **ADR-Autor** (Rückkante Review → Architektur/Planung, die ADR bleibt
*Proposed*). Es gibt keinen Produktiv-Diff; nichts geht an die Implementation. slice-059 bleibt bis
zur Auflösung der beiden HIGH in `open/`. Der Report ersetzt keine Verifikation — DoD-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

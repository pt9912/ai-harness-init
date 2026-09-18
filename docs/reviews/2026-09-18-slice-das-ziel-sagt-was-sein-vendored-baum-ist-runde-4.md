# Review-Report: `slice-das-ziel-sagt-was-sein-vendored-baum-ist` — 2026-09-18, Runde 4

**Review-Art:** Code — die Nacharbeit zu R3-1 bis R3-4 gegen Plan, aktive ADRs und die Hard
Rules. **Keine** DoD-Abhakung.

**Gegenstand:** `00f6abc3`.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

**Eingangs-Kontext:** der Slice-Plan §1 · `ADR-0007` Festlegung 3 und `ADR-0054`
Festlegung 1 und 2 (Idempotenz-Klassen) · `ADR-0022` Festlegung 5 · `LH-QA-01`, `LH-FA-09` ·
`MR-025`, `MR-033`, `MR-053` · `AGENTS.md` §3.7 · die Reports der Runden 1 bis 3.

---

## 1. Trägt die Kopf-Bedingung?

**Die Form ist richtig gewählt.** Fünfzehn wortgleiche Zusätze wären fünfzehn Stellen, die
gegeneinander driften; die Klasse einmal zu nennen ist die schmalere Zusage. Die Messung
stimmt auch: skip-if-present sind die Singletons (`internal/emit/templates.go:310`), die
Root-README (`internal/emit/readme.go:47`), die Gate-Konfiguration
(`internal/emit/emit.go:183`), das konditionale Arch-Gate (`internal/emit/archgate.go:114`)
und der Commit-Träger (`internal/emit/commitmsg.go:57-58`). **Der erste Satz der
Kopf-Bedingung ist damit wahr** — dort legt der Bootstrap nur ab, wo nichts liegt, und eine
vorhandene Fassung überlebt unberührt.

**Der zweite Satz ist es nicht.** Er sagt, das Werkzeug nenne jeden Pfad, den es stehen
lässt. Das Repo hat **zwei** skip-if-present-Schreiber, und nur einer meldet:

- `writeSkipIfPresentTold` (`internal/emit/enforce.go:454`) druckt
  `ai-harness-init: <pfad> liegt bereits — die Datei bleibt unberuehrt (skip-if-present).`
  Erreicht wird er ausschließlich über `writeEnforceFile` (`:440-445`), also für die
  Durchsetzungs-Mechanik — unter den skip-if-present-Adressen ist das der Commit-Träger.
- `writeSkipIfPresent` (`internal/emit/enforce.go:510`) ist **stumm**: liegt die Datei,
  gibt er `nil` zurück und schreibt nichts. Ihn rufen `Templates`, `RootReadme`, `DocGate`
  und das Arch-Gate.

Und es liegt nicht an einem vergessenen Aufruf, sondern am Signaturschnitt: In
`cmd/ai-harness-init/main.go` bekommt allein `emit.Enforce(targetDir, notice)` (`:439`)
einen Melde-Kanal; `emit.DocGate` (`:418`), `emit.Templates` (`:424`) und `emit.RootReadme`
(`:428`) haben keinen. Damit bleibt für `AGENTS.md`, `harness/README.md`,
`harness/conventions.md`, die drei `spec/`-Dateien, die Planning-/ADR-/Carveout-READMEs, die
Roadmap, das Register-README, `README.md` und `.d-check.yml` jeder Übergang still — das
sind die meisten Adressen, über die die Tabelle spricht. Das ist **R4-1**.

## 2. Die zwei Ausnahmen

**Richtig geschnitten.** Beide tragen eine *andere Folge*, nicht dieselbe in anderen Worten:
`modul-15 §Erfassung` hängt am Gelingens-Zweig der Träger-Ablage (`ADR-0022` Festlegung 5) —
dort fehlt das Artefakt **ganz**, statt in einer fremden Fassung dazuliegen. Beim
Commit-Träger fallen Prüfung und Träger in verschiedene Klassen, und die Folge ist die
Wirkung: ein fremder Hook ruft die mitgelieferte Prüfung nur, wenn er es selbst tut.

**Die Commit-Träger-Zelle ist jetzt wahr**, Satz für Satz gegen `internal/emit/commitmsg.go`
gehalten: die Prüfung liegt in jedem Lauf (`commitMsgCheckFile`, `class: Konvergent`), der
Träger nur an freiem Pfad (`commitMsgHookFile`, `class: SkipIfPresent`), und die Aktivierung
hängt an `make hooks-install` (`hooksInstallMkFile`). Der Zusatz *„sein Name gehört git"*
ist die Begründung, die `ADR-0054` Festlegung 1 selbst gibt.

## 3. R3-2 und die GRENZE-Notiz

**R3-2 ist erledigt.** Der Verweis auf den Verifikations-Report und das Präteritum über den
abwesenden Text sind gestrichen; stehen bleibt die Zusage, was der Wächter hält. Die Form
*„Ohne ihn wäre die Zusage breiter als ihr Wächter"* ist dieselbe, die dieser Slice seit
Runde 1 durchgehend führt und die ich dreimal unbeanstandet gelassen habe — sie beschreibt
den Wert dessen, was da ist, nicht eine verworfene Alternative.

**Die vier Stücke decken, was herausfällt.** Prosa · nackter Name ohne Trenner und ohne
bekannte Endung · Adresse im vendored Baum (mit dem Grund: sie schreibt der Fetch, nicht der
Emitter — das beantwortet R3-4) · das Urteil über die Richtigkeit. Die fünfte Klasse, die
Spanne mit Leerraum, steht eine Handbreit höher im selben Kommentar und ist damit ebenfalls
benannt. Die Klassen sind vollständig; an den Beispielen hängt **R4-2**.

## 4. Findings dieser Runde

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | HIGH | Die Kopf-Bedingung schließt mit der Zusage, das Werkzeug nenne jeden Pfad, den es stehen lässt. Es nennt nur die Pfade der Durchsetzungs-Mechanik: `writeSkipIfPresent` kehrt bei liegender Datei stumm zurück, und `Templates`, `RootReadme` und `DocGate` bekommen in `main.go` gar keinen Melde-Kanal. Für die Mehrzahl der Adressen der Tabelle — `AGENTS.md`, `harness/README.md`, `harness/conventions.md`, `spec/`, die Planning-READMEs, die Roadmap, `README.md`, `.d-check.yml` — bleibt der Lauf still. Damit trägt der Satz, der alle Zellen von ihrer Bedingung entlastet, selbst eine Behauptung über das Werkzeug, die es nicht einlöst. | `LH-QA-01` · `ADR-0007` Festlegung 3 | `internal/emit/baumaussage.go:299-302` gegen `internal/emit/enforce.go:454` und `:510` sowie `cmd/ai-harness-init/main.go:418-439` | ja — ein zweiter Bootstrap über ein Ziel mit eigener `AGENTS.md`: die Datei bleibt stehen, die Ausgabe schweigt | Emittierte Aussage sagt eine Werkzeug-Meldung zu, die nur eine Teilmenge kennt |
| R4-2 | INFO | Die GRENZE-Notiz belegt die Klasse *nackter Name* mit `SHA256SUMS` und `GATE_CHECKS`. `SHA256SUMS` kommt in keiner Zelle vor (es steht in der Block-Prosa, die `AdressenAusText` nie sieht), und die drei Namen, die real herausfallen — `baseline-verify`, `span-report`, `span-clean` — nennt sie nicht. Die Klasse ist richtig beschrieben, die Illustration trifft den Bestand nicht. | Maintainability | `internal/emit/baumaussage.go:203-206` | nein | Beispiel einer benannten Grenze stammt nicht aus dem Prüfbereich |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Erster Satz der Kopf-Bedingung | geprüft, ohne Befund — die Klassen-Messung stimmt; skip-if-present an allen fünf genannten Stellen im Code nachgesehen |
| Die zwei Ausnahmen | geprüft, ohne Befund — beide tragen eine andere Folge, keine ist eine Wiederholung der Kopf-Bedingung |
| Commit-Träger-Zelle | geprüft, ohne Befund — jede Teilaussage gegen `internal/emit/commitmsg.go` und `ADR-0054` gehalten; R3-1 ist damit erledigt |
| R3-2 | geprüft, ohne Befund — Herkunft und Präteritum gestrichen, die Zusage steht |
| R3-3 / R3-4 | geprüft, ohne Befund — beide Klassen sind jetzt benannt, R3-4 samt Grund; die Beispiel-Frage steht als R4-2 |
| Die 28 Adress-Spannen | geprüft, ohne Befund — die Nacharbeit ändert keine Adresse; die einzige berührte Zelle nennt dieselben zwei Pfade wie zuvor |
| `test/mutations/369` | geprüft, ohne Befund — die Zelle zu `modul-06-roadmap.md` ist unberührt, der `sed` trifft weiter genau eine reale Zeile |
| Wächter und seine Schranken | geprüft, ohne Befund — `AdressenAusText`, `EmittierteAdressen` und der Test sind funktional unverändert; nur Kommentare bewegt |
| `MR-025` / `MR-033` / `MR-053` | geprüft, ohne Befund — keine neue Zahl, keine Baseline-Aussage ohne Mess-Stand, der Adaptions-Block unberührt |
| `AGENTS.md` §3.7 in den geänderten Kommentaren | geprüft, ohne Befund — die GRENZE-Notiz und der Test-Kommentar stehen im Indikativ über das, was da ist |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Emittierte Aussage sagt eine Werkzeug-Meldung zu, die nur
eine Teilmenge kennt · Beispiel einer benannten Grenze stammt nicht aus dem Prüfbereich

Die erste Klasse ist die dritte Instanz der Familie *Zusage über das Ziel reicht weiter als
das, was dort passiert* in diesem Slice (F-3, R3-1, jetzt R4-1) — nur diesmal nicht in einer
Zelle, sondern in dem Satz, der die Zellen entlastet. Das gehört in die Closure-Notiz §7 und
ins Beobachtungs-Register, nicht in eine weitere Runde.

## Verdikt

**Die Closure ist nicht frei.** Der Umbau ist in der Sache richtig — die Klasse ist gemessen,
die Form ist die schmalere, die zwei Ausnahmen sitzen an den richtigen Stellen, und die
Commit-Träger-Zelle ist jetzt wahr. Aber die neue Kopf-Bedingung trägt in ihrem zweiten Satz
eine Zusage über das Werkzeug, die dessen stiller Zweig nicht einlöst, und sie trägt sie für
mehr Adressen als je eine Zelle betraf. Solange dieser Satz steht, ist die Entlastung der
Zellen nicht gedeckt.

Der Befund verlangt keine Entscheidung, sondern eine Wahl zwischen zwei Wegen, die beide dem
Implementer offenstehen: den Satz auf das einschränken, was der Lauf wirklich meldet, oder
die Auskunft an eine Stelle hängen, die der Adopter ohne Lauf-Ausgabe lesen kann. Welcher
Weg — das entscheidet der Implementer, nicht dieser Report.

Offen aus den Vorrunden, unverändert und **keine** Bedingung dieses Slice: F-7 (Planner),
F-8, R2-1 (Architect) und die Klassenfrage aus F-5 (Architect).

**Übergabe:** R4-1 an den Implementer; die Finding-Klassen in die Slice-Closure §7. Dieser
Report ist Lauf-Beleg und ersetzt keine Verifikation.

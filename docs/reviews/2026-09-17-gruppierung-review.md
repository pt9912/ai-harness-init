# Review der Gruppierung der dreizehn Go-Slices — 1 HIGH · 1 MEDIUM · 1 LOW · 1 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `4cc3e17c` (HEAD, **lokal**) —
`ADR-0057` (`Proposed`), die Index-Zeile und das Architect-Verdikt
`docs/reviews/2026-09-17-gruppierung-architect.md`; dazu als Gegenstand des Verdikts die sechs
Pläne aus `a2a5e2ed` (gepusht, `docs/plan/planning/open/`) · **Review-Art:** Review gegen ADRs,
Adaptions-Block, Hard Rules und die Baseline-Ziel-Formen · **Nicht Gegenstand:** die DoD-Abhakung
(Verifikation) und der Pin-Slice der Runden 1 bis 4.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:** `ADR-0005`, `ADR-0011`, `ADR-0012`, `ADR-0013`, `ADR-0020`, `ADR-0022`,
`ADR-0034`, `ADR-0053` · `LH-FA-02`, `LH-FA-09`, `LH-QA-01`, `LH-QA-02` · `MR-008`, `MR-015`,
`MR-019`, `MR-025`, `MR-036`, `MR-057`, `MR-059` · `AGENTS.md` §3.4, §3.5, §3.6, §3.8 ·
`v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt und §Ziel-Form: Slice, `regelwerk/modul-06-roadmap.md` §Wann Arbeit eine Welle braucht ·
`v6.9.0` · `templates/docs/plan/adr/NNNN-titel.template.md`.

---

## Eigene Messung

Die Angaben des Architects sind nicht übernommen; alle vier Kommandos aus `ADR-0057` §Kontext und
die tragenden Zahlen der Befunde sind selbst gefahren, read-only im Arbeitsbaum.

| Gegenstand | Ergebnis |
|---|---|
| Klammer in `LH-FA-02` | `Wiederkehrende** Vorlagen (ADR · slice · welle · carveout · review-report)` — **5** Glieder |
| `isRecurring` | **11** Namen |
| Dispositions-Weichen | **3** (`isRecurring`, `isDerivativeIndex`, `isBrownfieldOnly`) |
| Zahl-Aussage in `ADR-0020` | **1** Vorkommen von *„die fünf wiederkehrenden Vorlagen"*; die ADR ist `Accepted` |
| vendored Vorlagen-Satz | **25** `*.template.md` |
| **Dispatch in `internal/emit/templates.go`** | Zeile 355: `if isRecurring(…) \|\| isDerivativeIndex(rel) \|\| isBrownfieldOnly(rel) { continue }` — **alles Übrige wird Singleton** (Zeile 390). Der Kommentar bei Zeile 346 sagt es selbst: *„WER HIER EINE VORLAGE NICHT EINTRAEGT, ENTSCHEIDET 'Singleton'"* |
| B-1 | Gruppe 4 nennt `ADR-0005`/`ADR-0020` **0**× , der Geber `slice-139` **4**× — der Befund trifft |
| B-5 | `slice-109` liegt in `next/`; `grep -l 'spezifikation.md#5-metriken'` nennt **6** offene Pläne, darunter Gruppe 5 und Gruppe 6 — der Alleinstellungs-Grund hält nicht |
| B-6 | Gruppe 5 trägt `Übernimmt: slice-071-bilanz-nennt-ihren-bestand` — **ein** Geber; Gruppe 6 trägt `Übernimmt: slice-204-das-programm-feld-nennt-das-programm` — ebenfalls **einer** |
| B-7 | alle **13** Geber existieren und liegen in `next/`; Liefer-Punkte je Nehmer: 3, 3, 3, 3, 3 und (Gruppe 6) einer mit Unterpunkten plus Doku-Update |
| B-4 | `slice-090`, `slice-091`, `slice-092` führen alle `**Welle:** welle-11`, der Nehmer trägt das Feld — die Welle bündelt danach **einen** Slice |
| Gliederung `ADR-0057` | die sieben `##`-Abschnitte der Vorlage, in ihrer Reihenfolge, nichts darüber hinaus |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R-1 | HIGH | Festlegung 1 widerspricht sich und macht die Fitness Function unerreichbar. Der Satz sagt erst *„… fällt unter genau eine der drei Weichen **oder wird als Singleton emittiert**"* und dann *„eine Vorlage, die keine Weiche fasst, färbt den Wächter fail-closed rot"*. Im Code ist *Singleton* der **else-Zweig** (Zeile 355/390), also fasst jede unklassifizierte Vorlage automatisch die Singleton-Disposition: Nach der ersten Hälfte kann nichts je rot werden, nach der zweiten wären alle 11 Singletons rot. Der zweite Mutations-Fall der Fitness Function (*„legt eine neue Vorlage in den geprüften Satz — der Wächter fällt"*) ist nur erfüllbar, wenn der Wächter eine **positive** Singleton-Liste führt; genau das verlangt Festlegung 1 nicht. Damit hätte der Wächter die stille Stelle, gegen die er gebaut wird — der Code-Kommentar bei Zeile 346 benennt sie wörtlich. | `AGENTS.md` §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel) · `LH-QA-01` eine Ebene tiefer | `docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md`, §Entscheidung Festlegung 1 und §Fitness Function, Zeile 2 | ja: der zweite Mutations-Fall lässt sich am heutigen Dispatch nicht rot färben | Zusage, deren Rot-Bedingung am Dispatch unerreichbar ist |
| R-2 | MEDIUM | Die Zahl-Aussage in `ADR-0020` ist **schon heute** unrichtig — sie sagt, *die fünf* wiederkehrenden Vorlagen würden nicht emittiert, während der Code 11 führt. `ADR-0057` behandelt sie durchgehend als etwas, das ein CR erst *„still auf falsch"* stellte (Festlegung 3, Folgepflicht 2), und macht den Ausgang damit von einer Vertragsänderung abhängig, die vielleicht nie kommt. Die bestehende Differenz bekommt so keinen Ausgang, obwohl sie unabhängig vom CR besteht. | `AGENTS.md` §3.4 (Korrektur nur als Folge-ADR) · `MR-025` | `ADR-0057`, §Entscheidung Festlegung 3 und §Konsequenzen Folgepflicht 2; gemessen gegen `internal/emit/templates.go` und `docs/plan/adr/0020-…md` | ja: die zwei Kommandos der Mess-Tabelle (11 gegen 5) | überholte Aussage in einer eingefrorenen ADR nur bedingt adressiert |
| R-3 | LOW | B-6 misst Gruppe 5 am Kriterium *ein Geber, Liefer-Punkte bis in die Formulierung übernommen* und schließt daraus auf *Umbenennung statt Gruppierung*. Gruppe 6 ist ebenfalls eine 1:1-Übernahme (`slice-204`), wird aber an einem **zweiten**, nirgends als Regel ausgesprochenen Kriterium gemessen (*„die DoD ist neu geschnitten"*) und bekommt darum keinen Entscheidungspunkt im Auftrag an den Planner (§3, Punkt 3 nennt nur Gruppe 5). Der Kosten-Einwand von B-6 — eine vollständige Stilllegung samt Risiko-Ausgängen für einen Identitäts-Wechsel, den `MR-057` nicht verlangt — trifft beide gleichermaßen. | `MR-057` · Maintainability | `docs/reviews/2026-09-17-gruppierung-architect.md`, B-6 letzter Satz und §3 Punkt 3 | ja: `Übernimmt:` beider Nehmer nennt je **einen** Geber | zwei Fälle derselben Klasse, an zwei Kriterien gemessen |
| R-4 | INFO | Das Kommando unter B-5 (`grep -l 'spezifikation.md#5-metriken' …`) misst, wer §5 **verlinkt**, und trägt den Satz über die, die dort **schreiben**. Für `slice-span-programm-nennt-das-programm` ist das Schreiben eigens belegt (DoD *„Doku-Update — berührt ist das Technik-Stratum"*), für die übrigen vier Treffer nicht. Der Befund hält; sein Kommando misst eine weitere Menge als sein Satz. Zuständig: Architect. | `MR-055` (eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft) | Architect-Verdikt, B-5 | ja: die sechs Treffer einzeln lesen | Kommando misst eine weitere Menge als die Aussage daneben |

**Warum R-1 HIGH ist.** Die ADR steht vor `Accepted` und ist danach unveränderlich
(`AGENTS.md` §3.4). Eine Festlegung, deren Rot-Bedingung am vorhandenen Dispatch keinen Zustand
hat, bindet den umsetzenden Slice auf einen Wächter, der entweder nie rot wird oder von der ADR
abweichen muss — beides ist teurer als ein Satz jetzt. Der Gate-Bezug hebt die Kategorie zusätzlich
(Kontext-Eskalation).

**Kein Rollen-Konflikt.** R-1 bis R-4 stehen gegen keine dokumentierte Gegenposition; der
Konflikt-Pfad aus Modul 8 greift nicht.

## Antworten auf die vier Prüffragen

**1. `ADR-0057`.** Die Entscheidung trägt in der Sache: Option B ist gegen A und E sauber
abgewogen, folgt dem Präzedenzfall aus `ADR-0020` Festlegung (e) (*„Welcher Satz das ist, ist eine
Regel und keine Aufzählung"* — Zitat geprüft, Zeile 515) und löst die Kopplung des Wächters an
einen fremden Akt. **Kein `Supersedes` ist richtig:** Die Stelle in `ADR-0020` ist eine Klammer in
der **Begründung** zu Festlegung (e) über den vendored Baum, keine Festlegung; `ADR-0057` schränkt
sie nicht ein, sondern füllt eine Lücke — die Klasse *wiederkehrend* war dort nie entschieden. Was
dabei offenbleibt, steht als R-2. **Die Fitness Function trägt nicht:** siehe R-1; fail-closed ist
sie nur in der Absicht, nicht in der Bedingung — die **Disjunktheits**-Hälfte dagegen hat Zähne (ein
Name in zwei Weichen ist heute unsichtbar, weil `||` kurzschließt, und wäre prüfbar). **Form:** die
sieben Abschnitte der Vorlage in ihrer Reihenfolge, Status/Datum/Autor/Bezug im Kopf, `Schärft:`
mit Begründung, drei Re-Evaluierungs-Trigger (jeder beobachtbar), Geschichte-Zeile *Proposed*, und
die Index-Zeile trägt Titel, Status und Bezug. **§3.5:** keine Gate-Lockerung — die Entscheidung
**setzt** einen Wächter, wo keiner war. **§3.8:** eigener Commit, ausschließlich
Architect-Artefakte (ADR, ADR-Index, eigenes Verdikt), Rolle in der Message.

**2. Die Befunde B-1 bis B-7 stimmen**, jeder an seiner eigenen Messung nachgeprüft (Tabelle oben).
B-1 trifft (0 gegen 4). B-5 trifft — mit der Einschränkung R-4 zum Kommando. B-6 trifft für
Gruppe 5. **Zur Nachfrage nach Gruppe 6:** Der Architect **nennt** sie, im letzten Satz von B-6, und
begründet die Ungleichbehandlung mit der neu geschnittenen DoD; die Prämisse *„der Architect nennt
sie nicht"* ist damit widerlegt. Ob die Begründung trägt, ist R-3 — sie hält den Einwand nicht
vollständig von Gruppe 6 fern, weil dessen Kosten-Hälfte auch dort anfällt.

**3. Die sechs Pläne**, soweit dieser Review sie trägt: `Übernimmt:` steht in allen sechs in §1, die
13 genannten Geber existieren und liegen ungeschlossen in `next/`, die Größenregel ist überall
gehalten (dreimal drei Liefer-Punkte, zweimal drei, einmal einer mit Unterpunkten), jeder Plan führt
einen `Ausdrücklich NICHT`-Block mit vier oder fünf begründeten Ausschlüssen aus den vier Klassen,
eine Suche nach Chronik-Mustern (`Review-Befund`, `Runde N`, Befund-Kennungen, *„bis slice-…"*)
bleibt in allen sechs **leer** (§3.7), und die Zahlen stehen neben ihren Kommandos (`MR-025`).

**4. Neue Befunde:** R-1 bis R-4.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `ADR-0057` §Kontext, alle vier Kommandos | geprüft, ohne Befund: 5, 11, 3 und 1 — jede Zahl selbst gefahren, jede als Nicht-Erwartungswert deklariert |
| `ADR-0057` Alternativen-Tabelle | geprüft, ohne Befund: fünf Optionen mit Pro **und** Contra, die gewählte markiert; das Contra von B (Rang-1-Aussage bleibt vorerst unrichtig) ist benannt statt beschönigt |
| `ADR-0057` Konsequenzen | geprüft, ohne Befund: zwei positive, zwei negative, zwei Folgepflichten; die Grenze *„Kopiert-und-ausgefüllt je Vorgang ist am Dateibaum nicht direkt messbar"* ist die richtige und steht in der Meldung statt in einem Kommentar daneben |
| `AGENTS.md` §3.4 | geprüft, ohne Befund: keine `Accepted`-ADR wird überschrieben; `ADR-0020` bleibt unangetastet, der Ausgang für seine Zahl-Aussage ist als Folgepflicht benannt (Einschränkung R-2) |
| Statusprüfung der zitierten ADRs | geprüft, ohne Befund: `ADR-0020` ist `Accepted`; das Verdikt prüft für jede Gruppe Status und Aussage und nennt das Kommando dazu |
| Übernahme-Form (`modul-05` §Ein Slice, dessen Gegenstand ein anderer übernimmt) | geprüft, ohne Befund: Bedingung 1 (die Adresse nimmt an) ist für alle 13 erfüllt — kein Nehmer ist geschlossen, keiner schließt einen übernommenen Punkt aus; Bedingung 3 (Wellen-Zugehörigkeit wandert) ist für `welle-11` vollzogen |
| B-4, Wellen-Test | geprüft, ohne Befund: die Messung stimmt, und die Einordnung als **Planungs**-Entscheidung statt Architektur-Urteil trifft die Rollen-Grenze |
| B-7, Kennungs-Form | geprüft, ohne Befund: der Hinweis auf zwei Adress-Formen (Datei-Stamm gegen `slice-090`) ist richtig und als Empfehlung markiert, nicht als Setzung |
| Grenze des Verdikts | geprüft, ohne Befund: §4 benennt drei ungeprüfte Flächen, darunter die Review-Sitzungs-Größe — sie steht in allen sechs Plänen als Risiko mit Rückführung |
| `AGENTS.md` §3.11 | geprüft, ohne Befund: die ADR nennt Slices bei der Kennung; ihre Pfad-Links zeigen auf ortsfeste Ablagen |

## Summary

**1 HIGH · 1 MEDIUM · 1 LOW · 1 INFO.** Die Gruppierungs-Analyse des Architects hält — alle sieben
Befunde sind an eigener Messung bestätigt, und die Entscheidung für `ADR-0057` ist die richtige
Antwort auf B-2. Der HIGH sitzt nicht in der Entscheidung, sondern in ihrer **Formulierung**:
Festlegung 1 und die Fitness Function beschreiben einen Wächter, dessen Rot am heutigen Dispatch
keinen Zustand hat. Klasse für die Closure §7: **Zusage, deren Rot-Bedingung am Dispatch
unerreichbar ist** — sie liegt nahe an
`BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`.

## Verdikt

**`ADR-0057` kann in dieser Fassung nicht nach `Accepted`.** R-1 gehört vorher behoben — ein Satz
in Festlegung 1, der sagt, dass *Singleton* eine **positiv geführte** Disposition ist und nicht der
else-Zweig, sonst trägt die Fitness Function nicht. R-2 gehört in denselben Zug, weil die ADR mit
dem Accept einfriert und die Folgepflicht sonst an einer Bedingung hängt, die den heutigen Zustand
verfehlt. Beides ist Architect-Arbeit und braucht keinen neuen Vorgang.

**Stufe 2 kann teilweise starten, und zwar getrennt nach Gruppe:**
- **Gruppen 1, 2 und 3** — frei. Bezüge bestätigt, Übernahme-Form vollständig, keine offene
  Entscheidung; die Stilllegung der neun Geber kann laufen.
- **Gruppe 4** — gesperrt, bis `ADR-0057` `Accepted` ist und der Plan nach Auftrag 1 nachgezogen
  wurde. `slice-139` geht bis dahin nicht nach `done/`, wie der Architect richtig festhält.
- **Gruppe 5** — gesperrt, bis die Entscheidung aus B-6 getroffen ist (streichen oder Mehrwert
  benennen).
- **Gruppe 6** — eine Planner-Minute, kein Block: dieselbe 1:1-Lage wie Gruppe 5 (R-3), Entscheidung
  notieren und dann laufen lassen.

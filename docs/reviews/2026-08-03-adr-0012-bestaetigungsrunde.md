# Review — `ADR-0012` (Proposed), Bestätigungsrunde nach dem Verweis-Nachzug

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Review-Art** | Design-Review (Modul 10 §Drei Review-Arten) — geprüft wird eine Entscheidung gegen Spec, aktive ADRs und Hard Rules, nicht ein Code-Diff |
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 |
| **Modell** | claude-opus-5[1m] |
| **Datum** | 2026-08-03 |
| **Diff/Commit-Range** | `cfd1b62..HEAD` über `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md` — genau **ein** Commit: `0d4d49b` (+22/−17, `git show --numstat` gefahren). Zusätzlich gegen den Stand der Vorgänger-Runde gelesen: `111fcdd`, `04c1b1e`, `1950020` (die Befund-Behebungen zwischen `ac06b9a` und `cfd1b62`) |
| **Prüfgegenstand** | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md` (289 Zeilen, Status **Proposed**) + `docs/plan/adr/README.md:20` |
| **Modul-8-Auftrag** | `.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz"*. Der Reviewer entscheidet **nicht** über die Annahme und setzt den Status nicht; er stellt den Zustand fest |
| **`LH-*`** | `LH-QA-01` (`spec/lastenheft.md:258-261`, in der ADR zweimal zitiert), `LH-QA-03` (in Alternative E) |
| **Aktive ADRs** | `ADR-0011` (**Accepted**), `ADR-0003` (**Accepted**), `ADR-0013` (**Accepted**, Festlegung 1 = der Zielort des `Schärft`-Kopfs), `ADR-0014` (**Accepted**, Bedingungen des aufgehobenen Eintrags) |
| **Hard Rules** | `AGENTS.md` §3.1, §3.4, §3.5, §3.6 (Wortlaut selbst gelesen, `AGENTS.md:53-113`) |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-31-adr-0012-proposed-review.md` (1 HIGH, 4 MEDIUM, 3 LOW, 2 INFO — **NICHT KONFORM**) · `docs/reviews/2026-08-02-slice-076-mr-018-umzug-review.md` · `docs/reviews/2026-08-02-slice-068-review.md` |
| **Regelwerk on-demand** | `regelwerk/README.md` (Index), `modul-10-review-harness.md` (vollständig), `modul-08-agentenrollen.md` §Rollen-Regeln + §Konflikt-Pfad, `modul-07-carveouts.md` (vollständig, 132 Zeilen), `modul-15-observability.md` §Token-Attributions-Regeln |
| **Gate-Lage des Prüfgegenstands** | `make docs-check` **selbst gefahren**: `287 Datei(en) geprüft, 0 Befund(e)` — die neun umgehängten Links, ihre Anker und die `matrix`-Regeln lösen auf. Der Gate prüft `[links, anchors, ids, matrix, codepaths, spans]` (`.d-check.yml:18`), also **keine Sätze**; `make comment-claims` lässt jede Markdown-Datei außen vor (`Makefile:135`). Für die Aussagen dieser ADR ist diese Lektüre der einzige Sensor |

**Prüfmethode.** Jede der **neun** umgehängten Fundstellen einzeln am neuen Ziel
(`spec/spezifikation.md` §5) nachgelesen — nicht nur „löst der Link auf", sondern „trägt der
Zielort den behaupteten Satz". Dazu die Sätze **um** die neun Stellen herum, die über denselben
umgezogenen Bestand sprechen, ohne selbst einen Link zu tragen: dort liegen zwei der drei
MEDIUM. Jede Zahl selbst nachgezählt, jede Zuschreibung an einen Träger am Träger geprüft. Der
Vorgänger-Bestand (`git show 736b562:harness/conventions.md`, `git show a4199c9:…`) wurde
herangezogen, um zu unterscheiden, ob eine Aussage **immer** falsch war oder **durch den Umzug**
falsch geworden ist. `make docs-check` gefahren; `make gates` nicht — der Gegenstand ist reines
Markdown, und die Gate-Ausgabe des Autors (`0d4d49b`: *„d-check 287/0, comment-claims 38/0"*)
deckt sich mit dem selbst gefahrenen `docs-check`.

---

## Status der Vorgänger-Befunde

| ID | Vorgänger-Befund | Status heute | Beleg |
|---|---|---|---|
| **H-1** | *„die Auswertung, die es messen könnte, liegt in `open/`"* schrieb dem Auswertungs-Slice eine Messung zu, die die ADR selbst ausschließt | **aufgelöst** | `:161-167` sagt jetzt *„solange die Annahmen (a)–(c) gelten, beziffert keine Auswertung sie — sie liest Spans, und kein Span trägt diese Token"*; die zweite Fundstelle (Alternative G, `:146`) sagt *„wie viel weniger, misst **niemand**"*. Beide Zuschreibungen sind ersetzt, nicht abgeschwächt |
| **M-1** | Die zwei Fitness-Function-Zeilen zeigten auf einen Slice, dessen DoD und Plan-Tabelle sie nicht führen | **aufgelöst, mit Träger** | `slice-066` DoD **(2)** ist ein **eigener** Punkt (`docs/plan/planning/open/slice-066-telemetrie-auswertung.md:70-84`), er nennt *„Zwei Zähne, rot gesehen"* — Go-Test (`make test`) **und** `test/mutations/`-Fall (`make mutate`) — und grenzt sich in `:82-84` ausdrücklich gegen DoD (1) ab. Die Plan-Tabelle führt ihn: `:113` — *„`test/` + `test/mutations/` \| neu \| die Zähne aus DoD (1) … **und die zwei aus DoD (2) für die Nenner-Angabe**"*. Beide vom Auftrag verlangten Zähne stehen namentlich |
| **M-2** | Die Konsequenz behauptete den Sensor im Präsens | **aufgelöst** | `:154-157`: *„einen Wächter, **sobald** die Bilanz entsteht (Fitness Function unten; **heute existiert er nicht**)"* |
| **M-3** | Der Beleg-Verweis *„und in den Risiken von `slice-066`"* zeigte auf die abgegrenzte Nachbargröße | **aufgelöst** | `:128-131` nennt als Fundstelle nur noch `spec/spezifikation.md` §5 Abweichung 6; dort steht die Pflicht verbatim (`spec/spezifikation.md:517-520`) |
| **M-4** | `LH-QA-01` trug drei unvereinbare Rollen | **aufgelöst** | `:10-15` führt die Anforderung nur noch für die **emittierte** Ebene mit einem Kriterium; Festlegung 1 steht in `:206-215` allein auf `AGENTS.md` §3.6; `:248-252` wendet dasselbe Kriterium auf **beide** Hälften an. Kein Widerspruch mehr auffindbar |
| **L-1** | Folgepflicht 2 benannte eine Stelle des überholten Welle-Vokabulars; drei waren betroffen, und der Träger führte den Welle-Plan nicht | **aufgelöst — durch den Träger, nicht durch die ADR** | `welle-09:16-18` (Welle-Ziel) nennt jetzt *„oder das Verdikt einer ADR"*; `welle-09:102-106` führt **ADR-Verdikt** als eigene Belegart; `welle-09:158` schreibt dem Slice die **zweigeteilte** Belegart zu; `slice-068` (in `done/`) hat `welle-09` in seiner Plan-Tabelle (`:118`). Siehe aber **M-3** dieser Runde: die ADR sagt davon nichts |
| **L-2** | *„bisher überwiegend"* als Mengenaussage über den Repo-Bestand | **aufgelöst** | `:42-46` ist auf *„an der Arbeit an der Rollen-Achse dieses Repos ist belegt"* zurückgenommen; die Aussage deckt sich mit `slice-068:152-157` |
| **L-3** | Zeilenzahl in einer Commit-Message | historisch, nicht nachziehbar | — |
| **I-1** | Mitentfernte, wahre Modul-7-Eigenschaft | unverändert INFO | — |
| **I-2** | `welle-09:89-90` sagte *„drei Werte"*, die Tabelle führte vier | **aufgelöst** | `welle-09:88-90` sagt jetzt *„jede Zelle mit **einem Wert aus der Tabelle unten**"*, ohne Zahl. Siehe I-4 dieser Runde für einen benachbarten Rest |

**Damit sind alle fünf blockierenden Befunde der Vorgänger-Runde erledigt** — keiner davon
kosmetisch, alle vier MEDIUM mit einem benannten Träger im Zielartefakt.

---

## Findings

### M-1 — Die Trichter-Antwort auf Frage 1 stützt sich auf einen „ernst erreichbaren Trigger" der Nachbar-Abweichung, den ihr Zielort nicht mehr trägt

- **kategorie:** MEDIUM
- **quelle:** Hard Rule `AGENTS.md` §3.6 (*„benennen, was wirklich deckt — oder dass nichts deckt"*); `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:48-67`
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:80-83` gegen `spec/spezifikation.md:483-489`
- **befund:** Der Text lautet: *„Die Nachbar-Abweichung 5 … betrifft dieselbe Achse, hat aber einen **eigenen, ernst erreichbaren Trigger** und ist durch einen `PreToolUse`-Guard bereits verkleinert."* Abweichung 5 trägt an ihrem heutigen Ort **genau eine** Auflösungs-Bedingung (über den ganzen Block `spec/spezifikation.md:414-489` ausgezählt, ein Treffer): *„Sie entfällt ersatzlos, sobald die `tool_response` eines Hintergrund-Laufs Zähler trägt. Die Quelle dafür ist **nicht gepinnt** und wird von **keinem Gate** geprüft: die Bedingung wirkt nur, wenn sie jemand nachsieht."* Das ist weder „eigen" noch „ernst erreichbar": es ist derselbe Hook-Oberflächen-Trigger, den diese ADR unter `:256-261` als **ihren eigenen** Re-Evaluierungs-Trigger führt, und dieselbe Klasse, die `:88-92` als *nicht durch Aufwand herbeizuführen* für permanent erklärt.
- **Wodurch die Aussage falsch wurde:** Der pre-move-Bestand trug **zwei** Trigger (`git show 736b562:harness/conventions.md`, Zeilen 1270-1283): *„(1) die **Abdeckungszahl** aus slice-066 DoD (1) … Sie ist **messbar, aber noch nicht gemessen**"* und *„(2) Trägt die `tool_response` eines Hintergrund-Laufs eines Tages Zähler …"*. Der erste — der durch Arbeit erreichbare — ist beim Umzug entfallen; `MR-021` verzeichnet die Klasse als ersatzlos (`harness/conventions.md:1004-1006`: *„**Prozess-Zustand** — welcher Slice was trägt, welcher Trigger auf welchen Slice wartet"*). Die Aussage der ADR war am Vorgänger-Bestand **wahr** (die Vorgänger-Runde hat sie unter N-19 so gemessen) und ist es seit dem Umzug nicht mehr.
- **verifizierbar:** nein — kein Gate liest Markdown-Sätze gegeneinander. Belegt durch Lektüre von `spec/spezifikation.md:483-489` und `:414-489` gegen `git show 736b562:harness/conventions.md:1270-1283`.
- **Failure-Szenario:** Die ADR wird angenommen und ist ab da immutabel (`AGENTS.md` §3.4). Modul 7 §Werkzeug-Wahl entscheidet die **Artefakt-Klasse** in zwei sequenziellen Fragen, Granularität vor Temporalität; die Antwort auf Frage 1 (*Einzelne*, kein gemeinsamer Geltungsbereich **mit gemeinsamer Auflösung**) trägt in der ADR drei Stützen, und eine davon ist die Unterscheidbarkeit der Trigger. Wer nach der Annahme prüft, ob Abweichung 5 und 6 ein Cluster mit gemeinsamer Auflösung sind, liest in der maßgeblichen Entscheidung eine Unterscheidung, die die heutige Quelle nicht hergibt — beide Abweichungen hängen dort am selben, nicht herbeiführbaren Ereignis.
- **Kategorisierung, offengelegt:** HIGH erwogen und verworfen. Die Antwort *„Einzelne"* überlebt ohne diese Stütze: `:84-87` prüft **beide** von `modul-07-carveouts.md:130` genannten BF-Symptome eigenständig (ein Carveout ohne Geltungsbereichs-Überschnitt; kein *„Code existiert vor Doku"*-Muster), und eine BF-Sub-Area-Markierung in einem durchweg als GF deklarierten Bestand hätte keinen Gegenstand. Die Entscheidung kippt also nicht — die Begründung trägt eine unbelegte Behauptung.

### M-2 — „sechs erklärte Abweichungen von diesem Pflicht-Minimum" widerspricht dem Zielort, auf den der Satz jetzt zeigt

- **kategorie:** MEDIUM
- **quelle:** Hard Rule `AGENTS.md` §3.6; Skill-Anker „Bezug-/Abdeckungslücke"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:39-43` (Kern auf `:41-42`) gegen `spec/spezifikation.md:311-329`
- **befund:** Die Kette lautet: *„`modul-15-observability.md` §Token-Attributions-Regeln verlangt eine Token-Bilanz **je Rolle**. [`spec/spezifikation.md`] §5 führt sechs erklärte Abweichungen von **diesem** Pflicht-Minimum"*. Der Zielort sagt das Gegenteil, ausdrücklich und mit Zuordnung je Posten (`spec/spezifikation.md:311-329`): *„Sechs erklärte Abweichungen — sie kommen aus **drei Regelblöcken** des Observability-Moduls, und **eine weicht von keinem ab**"* — vom **Pflicht-Minimum eines Audit-Span-Schemas** weichen 1 und 3 ab, von den **Mindestfeldern eines Tool-Call-Spans** die 2, von den **Token-Attributions-Regeln** nur **5 und 6**, und **4** von keiner Modul-Regel. Unter beiden im Zielort geführten Lesarten von *„diesem Pflicht-Minimum"* ist die Zahl sechs falsch.
- **Wodurch die Aussage falsch wurde:** Die pauschale Fassung stand so im Vorgänger-Bestand (`git show 736b562:harness/conventions.md:1064`: *„Sechs erklärte Abweichungen vom Modul-15-Pflicht-Minimum"*) und wurde beim Umzug **als Fehler erkannt und in eigenem Commit behoben** (`5da0db3`, Message: *„Die Ueberschrift des Abweichungs-Blocks nannte EINEN Regelblock fuer Posten aus DREIEN"*, mit der Zuordnung je Abweichung). `0d4d49b` hat den Link auf den korrigierten Text umgehängt und die Formulierung mitgenommen.
- **verifizierbar:** nein. Belegt durch Lektüre von `spec/spezifikation.md:311-329` und der Commit-Message von `5da0db3`.
- **Failure-Szenario:** Der Wellen-Closure-Trigger buchstabiert die Matrix als *„Je Regelblock UND je Ebene ein belegter Zustand"* (`docs/plan/planning/welle-09-modul-15-konformitaet.md:88-90`) — die Zuordnung Abweichung → Regelblock ist also genau die Größe, an der die Zellen hängen. Eine ab *Accepted* immutable ADR, die alle sechs Abweichungen an den Token-Attributions-Block bindet, lässt die Zellen für Block 1 und Block 4 leer aussehen oder zieht Abweichung 4 (Altbestände, Aufbewahrungs-Entscheidung ohne Modul-Regel) in eine Modul-15-Zelle. Die Korrektur wäre dann eine Supersedes-ADR über einen Einleitungssatz.
- **Nicht mitgemeldet:** die gleichlautende Wendung im `Schärft`-Kopf (`:24-25`, *„die erklärten Abweichungen vom Pflicht-Minimum"*) — sie spiegelt den Wortlaut der **Accepted** `ADR-0013` Festlegung 1 (*„die je Abweichung vom Pflicht-Minimum geschuldete Begründung"*) und trägt kein *„diesem"*, das sie an die Token-Attributions-Regeln bindet.

### M-3 — Folgepflicht 2 verlangt im Präsens einen Zustand, der seit `2ba8392` besteht; eine ihrer Aussagen ist am heutigen Welle-Plan falsch

- **kategorie:** MEDIUM
- **quelle:** Hard Rule `AGENTS.md` §3.4 (Immutabilität ab *Accepted*) i. V. m. §3.6; Skill-Anker „Doku-Drift" mit Kontext-Eskalation (dieselbe Klasse hat `0d4d49b` für Folgepflicht 1 behoben)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:177-186` gegen `docs/plan/planning/welle-09-modul-15-konformitaet.md:16-18`, `:102-106`, `:158` und `docs/plan/planning/done/slice-068-rollen-arbeit-laeuft-als-rolle.md:72-83`, `:118`
- **befund:** Die Folgepflicht steht in drei Teilen, und alle drei sind eingelöst: (a) *„sie verlangt eine **Ergänzung des Vokabulars**"* — `welle-09:104` führt die Belegart **ADR-Verdikt** samt Definition *„**ohne Auflösungs-Trigger**: Modul 7 §Werkzeug-Wahl lässt ihn auf dem ADR-Pfad wegfallen. … Erster Fall: `ADR-0012`"*; (b) *„wer sie einführt, **zieht den Satz mit**, der die Belegarten aufzählt"* — der Satz im Welle-Ziel ist mitgezogen (`welle-09:16-18`: *„…, eine deklarierte Entscheidung mit Auflösungs-Trigger **oder das Verdikt einer ADR, dass die Abweichung permanent ist**"*); (c) *„Die Festlegung **trägt der Slice**, der die Rollen-Konvention schreibt; der Welle-Plan gehört dafür in seine **Plan-Tabelle**"* — `slice-068` liegt seit `f069590` in `done/`, seine DoD (3) ist abgehakt und trägt die zweigeteilte Belegart, seine Plan-Tabelle führt `welle-09` als `update` (`slice-068:118`). Eine Aussage ist dabei nicht nur überholt, sondern **falsch**: *„Ein Closure-Vokabular, das *deklariert* … definiert …, **hat für diesen Wert keinen Platz**"* — das Vokabular in `welle-09:102-106` definiert *deklariert* genau so **und** hat für diesen Wert einen Platz.
- **Zur Ungleichbehandlung im selben Commit:** `0d4d49b` hat Folgepflicht 1 mit derselben Diagnose überarbeitet (`:284`: *„Folgepflicht 1 war zudem **sachlich überholt**"*) und sie mit *„eingelöst, und zwar anders als zuerst vorgesehen"* überschrieben. Folgepflicht 2 steht unverändert seit `111fcdd` und wurde beim Nachzug nicht gegen den heutigen Bestand gehalten.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die ADR wird angenommen. Wer die Wellen-Closure fährt, liest in der maßgeblichen Entscheidung eine offene Folgepflicht an *„den Slice, der die Rollen-Konvention schreibt"* — ein Slice, der geschlossen ist. Zwei Ausgänge, beide falsch: die Closure wird an einer erfüllten Pflicht aufgehalten, oder die Belegart wird ein zweites Mal eingeführt und steht danach an zwei Orten verschieden im Repo. Die Korrektur wäre nach `AGENTS.md` §3.4 eine Supersedes-ADR.

### L-1 — „zum Zeitpunkt der Annahme trug das Verzeichnis 106 Fälle": gemessen sind 102

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (die Zahl steht als Messergebnis)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:243-244`
- **befund:** Der Satz lautet *„zum Zeitpunkt der Annahme trug das Verzeichnis **106 Fälle**, die Span-Fälle beginnen bei 107"*. `ADR-0011` wurde in `0fb1db8` angenommen (*„adr: ADR-0011 ACCEPTED"*); dort trägt `test/mutations/` **102** Dateien (`git ls-tree --name-only 0fb1db8 test/mutations/ | grep -c '\.sh$'` → 102, keine Nicht-`.sh`-Datei). Die 106 ist die **höchste Nummer**, nicht die Anzahl: die Nummernfolge hat acht Lücken (12, 14, 21, 22, 23, 25, 33, 35) und vier doppelt vergebene Nummern (47, 48, 49, 50) — 106 − 8 + 4 = 102. Der zweite Halbsatz stimmt: `106-archgate-kanten-zyklus.sh` ist der letzte Nicht-Span-Fall, `107-span-klemme-entfernt.sh` der erste Span-Fall. Derselbe Ordinal-/Kardinal-Abstand besteht heute fort (135 Dateien, höchste Nummer 139).
- **verifizierbar:** ja — `git ls-tree --name-only 0fb1db8 test/mutations/ | grep -c '\.sh$'`. Gefahren.
- **Failure-Szenario:** Gering für die Entscheidung — die Präzedenz („die Datei darf zum Annahme-Zeitpunkt fehlen") hängt nicht an der Größe des Verzeichnisses. Gemeldet, weil die Zahl als Messung auftritt und ab *Accepted* nicht mehr korrigierbar ist; wer später eine Fall-Nummer aus einer Anzahl ableitet, greift daneben.

### L-2 — Das Zitat der `spec`-Sensor-Spalte kehrt die Wortstellung der Quelle um

- **kategorie:** LOW
- **quelle:** Repo-Regel „autoritative Quellen verbatim spiegeln"; Skill-Anker „Doku-Drift"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:233-235` gegen `spec/spezifikation.md:75-77`
- **befund:** Die ADR setzt in Anführungszeichen: *„**prüft kein Gate**, ob ein … genannter Wächter noch existiert oder noch so heißt"*. Die Quelle lautet *„**kein Gate prüft**, ob ein hier oder unter **Bewacht** genannter Wächter noch existiert oder noch so heißt"*. Die Auslassungspunkte decken *„hier oder unter Bewacht"*, nicht die Umstellung der ersten beiden Wörter.
- **verifizierbar:** nein (kein Gate prüft Zitattreue in Markdown).
- **Failure-Szenario:** Schwach — die Aussage ist inhaltlich identisch. Gemeldet, weil ein Zitat in dieser ADR anderswo verbatim geführt wird (`modul-07-carveouts.md:63-67` und `:129` sind wortgenau) und ein umgestelltes Zitat in einem immutablen Dokument bei einer späteren Textänderung der Quelle nicht mehr als Zitat auffindbar ist.

### L-3 — Die drei „anderen Fragen" sind nicht mehr die Fragen des lebenden Plan-Bestands

- **kategorie:** LOW
- **quelle:** Skill-Anker „Doku-Drift"; `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:61-65`
- **befund:** Der Satz setzt seinen Prüfbereich selbst (*„Über die lebenden Plandateien — `open/`, `next/`, `in-progress/` samt Roadmap und der flach liegende Welle-Plan"*) und charakterisiert ihn: *„wo überhaupt von Token die Rede ist, geht es um andere Fragen (Splitting-Regel des Sammelpostens, Berichtsgröße, Wächter-Bindung)"*. Über genau diesen Bereich gemessen (`grep -ril token` über `open/`, `next/`, `in-progress/`, `welle-09…md`, `planning/README.md`) sprechen **sieben** Dateien von Token, und sie decken mehr als drei Fragen ab: `slice-066` (Splitting-Regel ✓), `slice-069:41` (Wächter-Bindung ✓), `welle-09:96,158` (Berichtsgröße ✓), `roadmap:92`, dazu **`slice-071`** — die Cache-Rechnung mit `cache_creation_input_tokens`/`cache_read_input_tokens`/`input_tokens` (`:37-56`, `:122-129`), eine vierte Frage — und `slice-072`/`slice-073`, wo *Token* der `token:`-Modus des Doku-Gates ist, also ein Homonym. Die tragende Verneinung des Satzes hält: **keine** der sieben führt die Bedingung *„eine Quelle innerhalb des Repos, die Haupt-Kontext-Token trägt"*; `slice-071:122-124` schließt den Haupt-Kontext ausdrücklich aus und verweist dafür auf diese ADR.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Aufzählung wird als Vollständigkeitsaussage über den Plan-Bestand weiterzitiert und übersieht die Cache-Rechnung, die aus **denselben** `Agent`-Spans rechnet und damit denselben Nenner-Vorbehalt trägt wie die Token-Bilanz.

### L-4 — Alternative G führt die Berichtsgrößen-Festlegung als geplant; sie liegt geliefert im Technik-Stratum

- **kategorie:** LOW
- **quelle:** Skill-Anker „Doku-Drift"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:146` gegen `spec/spezifikation.md:271-289`
- **befund:** Die Pro-Spalte sagt *„sie ist **bereits geplant** — der Slice, der die Rollen-Konvention schreibt, legt die Berichtsgröße fest, und die Auswertung erzeugt sie"*. Die Festlegung ist nicht mehr geplant, sondern geschrieben: `spec/spezifikation.md:271-289` führt sie unter *„Die BERICHTSGRÖSSE dieser Regel — was sie zeigt und was nicht"* samt beider Festlegungen (Anteil im Bericht statt als Schwelle; *„gedeckt" heißt „Span mit ZÄHLERN"*), geliefert von `slice-068` DoD (2), der in `done/` liegt. Geplant ist heute nur noch die zweite Hälfte des Satzes (*„und die Auswertung erzeugt sie"*, `slice-066` DoD (1) in `open/`).
- **verifizierbar:** nein.
- **Failure-Szenario:** Schwach — die Aussage untertreibt, sie behauptet nichts Falsches über die Sache. Gemeldet, weil sie mit M-3 dieselbe Wurzel hat: Sätze über `slice-068` sind seit dessen Abschluss nicht nachgezogen worden.

### I-1 — Die Geschichte-Zeile zählt drei erhaltene Bestandteile des aufgehobenen Eintrags; erhalten sind vier

- **kategorie:** INFO
- **quelle:** `MR-020` (`harness/conventions.md:904-912`), `ADR-0014`
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:284`
- **befund:** *„er behält **Nummer, Überschrift und eine Zeiger-Zeile**"*. `MR-020` legt vier Bestandteile fest — *„die Nummer, die Überschrift **wörtlich** (sie ist der Anker), das `Datum` und **eine** Zeile mit dem aufhebenden Eintrag"* —, und `harness/conventions.md:835-838` führt alle vier, einschließlich `**Datum:** 2026-07-28`.
- **verifizierbar:** nein.
- **Failure-Szenario:** Schwach. Die ADR definiert die Form nicht (das tun `MR-020`/`ADR-0014`); sie beschreibt sie beiläufig. Gemeldet, weil eine Aufzählung in einem immutablen Dokument als Definition gelesen werden kann.

### I-2 — „Die Zeile von 2026-07-31 unten" hat vier Kandidaten

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:284` gegen `:286-289`
- **befund:** Die Geschichte-Tabelle führt **vier** Zeilen mit dem Datum 2026-07-31 (`:286`, `:287`, `:288`, `:289`). Gemeint ist erkennbar `:289` — die einzige, die noch auf `MR-018` zeigt. Eine Falschaussage folgt daraus nicht: alle vier sind unverändert (`git show 0d4d49b` zeigt genau eine hinzugefügte Zeile, keine geänderte).
- **verifizierbar:** ja (`git show 0d4d49b --numstat`: +22/−17, die Geschichte-Tabelle nur additiv). Gefahren.
- **Failure-Szenario:** Keines im Bestand; ein Leser braucht einen zweiten Blick.

### I-3 — Nebenbefund außerhalb des Prüfgegenstands: Abweichung 5 wird als „deklariert mit Auflösungs-Trigger" gebucht, ihr Trigger ist nach Modul-7-Frage 2 nicht ernst erreichbar

- **kategorie:** INFO
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:63-67`; `docs/plan/planning/welle-09-modul-15-konformitaet.md:103`
- **pfad:** `spec/spezifikation.md:486-489` gegen `welle-09:158` und `slice-068:72-83`
- **befund:** `welle-09` definiert *deklariert* als *„bewusste Nicht-Umsetzung, ausgeschrieben mit Geltungsbereich, Begründung und **Auflösungs-Trigger**"*, und `slice-068` DoD (3) bucht für den Hintergrund-Teil (Abweichung 5) genau diesen Wert. Der einzige verbliebene Trigger von Abweichung 5 ist *„nicht gepinnt … wirkt nur, wenn sie jemand nachsieht"* — nach `modul-07-carveouts.md:63-67` (*„Nein (‚nichts davon werden wir in absehbarer Zeit tun') → permanent, übergeführt in eine ADR"*) dieselbe Antwort, die für Abweichung 6 zur ADR geführt hat. Der Befund liegt außerhalb dieser ADR; er ist ihr Spiegelbild und die Sachfrage hinter M-1.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Wellen-Closure bucht dieselbe Trigger-Klasse in derselben Zelle einmal als *deklariert* und einmal als *ADR-Verdikt*, ohne dass ein Artefakt den Unterschied trägt.

### I-4 — Nebenbefund außerhalb des Prüfgegenstands: das Welle-Ziel nennt drei Belegarten „auf BEIDEN Ebenen", die Tabelle führt fünf

- **kategorie:** INFO
- **quelle:** Skill-Anker „Doku-Drift"
- **pfad:** `docs/plan/planning/welle-09-modul-15-konformitaet.md:16-18` gegen `:102-106`
- **befund:** Das Welle-Ziel verlangt *„auf BEIDEN Ebenen — einen laufenden Sensor, eine deklarierte Entscheidung mit Auflösungs-Trigger oder das Verdikt einer ADR … und nichts dazwischen"* — drei. Die Wert-Tabelle führt fünf (Sensor · deklariert · ADR-Verdikt · emittiert · nicht emittiert), und `:91-92` ordnet **emittiert**/**nicht emittiert** ausdrücklich der Tool-Spalte zu. Das Ziel zählt damit für „beide Ebenen" nur die Repo-Werte. Selbst nachgezählt, nicht aus der Beauftragung übernommen. Der frühere Zählfehler an dieser Stelle (I-2 der Vorgänger-Runde, *„drei Werte"* bei vier) ist behoben; dies ist ein anderer Satz.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Ergänzung aus Folgepflicht 2 ist in der Tabelle angekommen, im Zielsatz der Welle aber nur zur Hälfte — eine Tool-Zelle mit *nicht emittiert* liest sich gegen das Welle-Ziel als „dazwischen".

---

## Negativbefunde

Je Bereich eine „geprüft, ohne Befund"-Zeile. Wo eine Vollständigkeit behauptet wird, steht der
Prüfbereich dabei, aus dem sie stammt.

| # | Bereich | Ergebnis |
|---|---|---|
| **N-1** | **Die neun umgehängten Verweise, Stelle für Stelle** (`:41`, `:49`, `:67`, `:73`, `:129`, `:152`, `:169`, `:233`, `:269`) | Alle neun am neuen Ziel gelesen. Sieben tragen ihre Aussage vollständig: `:49` (*„im Einzelnen in §5 Abweichung 6"* → `spec:495-498`), `:67` (die abgegebene Schema-Festlegung → `spec:271-289` + `slice-068:117`), `:73` (*„erklärte Abweichung in §5"*), `:129` (Nenner-Pflicht → `spec:517-520`, verbatim), `:152` (*„findet keine Zusage mehr, die auf einen Träger zeigt"* → Abweichung 6 trägt keinen Trigger, über `spec:490-522` ausgezählt), `:169` (Folgepflicht 1, s. N-2), `:269` (*„trägt sie in §5 nach"* → `spec:64-70`, das geschlossene Schema nennt genau diesen Ort). Zwei tragen sie nicht: `:41` → **M-2**, `:233` → **L-2**. **Ohne weiteren Befund.** |
| **N-2** | **Folgepflicht 1, alle drei Teilaussagen am Original** | (1) *„§5 Abweichung 6 trägt die Beschreibung **ohne Auflösungs-Trigger**"* — über `spec/spezifikation.md:490-522` ausgezählt: kein Trigger-Satz, im Unterschied zu Abweichung 5 (`:486`). ✓ (2) *„Das **Verdikt** steht … allein hier"* — `spec` §5 trägt es nicht, und die Formregel des Stratums (`spec:27-34`) verbietet den Abwärts-Zeiger, der es tragen könnte. ✓ (3) *„`MR-021` hat es … ausdrücklich als **ersatzlos** verzeichnet, mit dem Grund *„Ein zweiter Ort driftet"*"* — `harness/conventions.md:987`, Punkt 2: *„Das **Verdikt *permanent*** zur Abweichung *Haupt-Kontext ohne Zahl* samt seinem Trichter: der Posten ist in `ADR-0012` übergeführt … **Ein zweiter Ort driftet.**"* Verbatim. ✓ **Ohne Befund — die substanziellste Änderung des Commits trägt.** |
| **N-3** | **Die Zahl „Neun Verweise" der Geschichte-Zeile** | `git show 0d4d49b^:…` führt **zehn** `MR-018`-Vorkommen; neun sind umgehängt, das zehnte (`:289`, Geschichte-Zeile) ist in derselben Tabellenzeile ausdrücklich als unverändert benannt. Die Zahl bezeichnet die geänderten Stellen und ist exakt. **Ohne Befund.** |
| **N-4** | **Die Geschichte-Zeile 2026-08-03, übrige Zuschreibungen** | *„vollständig aufgehoben (`MR-021`, Bedingungen in `ADR-0014`)"* → `conventions.md:943-947` ✓ · *„die sechs erklärten Abweichungen stehen im Technik-Stratum"* → `conventions.md:950-952` + `spec:311-522` ✓ · *„der Kopf ist genau als Anker erhalten"* → `conventions.md:835`, Überschrift wörtlich; `make docs-check` löst den Anker auf ✓ · *„kein Gate liest sie: `codepaths` prüft Pfade, nicht Sätze"* → `.d-check.yml:18` + `conventions.md:977-986` ✓ · *„Ab *Accepted* wären sie nach `AGENTS.md` §3.4 nur noch per Supersedes zu korrigieren"* → `AGENTS.md:71-74` ✓. Ausnahmen: **I-1**, **I-2**. **Sonst ohne Befund.** |
| **N-5** | **`slice-066` als Träger der Fitness-Function-Zeilen** (die vom Auftrag verlangte Prüfung zu M-1 der Vorgänger-Runde) | DoD (2) ist ein **eigener** Punkt (`:70-84`), nennt den Go-Test (`make test`) **und** den `test/mutations/`-Fall (`make mutate`) namentlich als *„Zwei Zähne, rot gesehen"* und grenzt sich gegen DoD (1) ab. Die Plan-Tabelle nennt sie ein zweites Mal (`:113`, *„die zwei aus DoD (2) für die Nenner-Angabe"*). Beide vom Auftrag genannten Zähne sind belegt. **Ohne Befund.** |
| **N-6** | **Die Drei-Größen-Abgrenzung** (Nenner · Sammelposten-Anteil · Abdeckungszahl) | ADR `:235-239` gegen `slice-066` DoD (1) `:56-69` und DoD (2) `:82-84`: beide Artefakte ziehen dieselben zwei Grenzen mit denselben Worten, und `slice-066:68-69` grenzt zusätzlich die Bezugsgröße der Abdeckungszahl gegen den Nenner ab. Keine Größe fällt zusammen. **Ohne Befund.** |
| **N-7** | **Modul-7-Zitate und Zeilenverweise** (`:26-29`, `:46-93`, `:48`, `:48-67`, `:63-67`, `:105-110`, `:129`, `:130`, `:21`) | Alle neun am vollständig gelesenen Modul (132 Zeilen) geprüft; die vendored Datei ist seit `ce4b611` unverändert. Die drei Blockzitate sind verbatim; `:48-67` deckt tatsächlich beide Fragen in der Reihenfolge *Granularität vor Temporalität* (`:49-52` sagt es wörtlich); `:130` nennt beide BF-Symptome; `:21` trägt die Dateikonvention `docs/plan/carveouts/CO-<NNN>-…`. **Ohne Befund** (die *Anwendung* eines dieser Zitate ist M-1, nicht das Zitat). |
| **N-8** | **Modul-15-Bezug** | `modul-15-observability.md` §Token-Attributions-Regeln verlangt *„Summiere Input- und Output-Token pro `agent.role` … Wo ein Span keinen Rollen-Tag trägt (Sammelposten), entscheide begründet, wie du ihn aufteilst"*. Die ADR gibt das als *„Token-Bilanz je Rolle"* korrekt wieder; Festlegung 3 (`:132-135`) hält die Splitting-Pflicht ausdrücklich offen. **Ohne Befund.** |
| **N-9** | **`ADR-0011`-Zitate und Status der referenzierten ADRs** | Festlegung 1 Punkt 4 / Punkt 5, Festlegung 5, Alternative D, Option B, §Re-Evaluierungs-Trigger — am Original geprüft. `ADR-0011`, `ADR-0003`, `ADR-0013`, `ADR-0014` sind **Accepted** (`docs/plan/adr/README.md:11,19,21,22`), keine superseded Referenz. `ADR-0013` Festlegung 1 deckt den `Schärft`-Zielort wörtlich. **Ohne Befund.** |
| **N-10** | **`LH-QA-01`-Wortlaut und -Rolle** | `spec/lastenheft.md:260-261` verbatim gegen `:11-13`; die Anforderung trägt in der ADR nur noch die emittierte Ebene, mit **einem** Kriterium an **einer** Stelle (`:248-252`), und dasselbe Kriterium wird auf beide Festlegungen angewendet. **Ohne Befund.** |
| **N-11** | **Vollständigkeitsaussage über die vendored Werkzeug-Doku** (`:143`, Alternative C) | Über alle **3.383** Zeilen von `docs/user/claude-hooks-referenz.md` neu gemessen: `usage` als Feldname genau einmal (`:1574`), `totalTokens` genau einmal (`:1571`); die weiteren Treffer sind `/docs/de/monitoring-usage`-URLs (`:641`) und der Fehlertyp `max_output_tokens` (`:225`, `:2419`) — kein Nutzungsfeld. Die Spanne `:1571-1574` trifft exakt `totalTokens`/`totalDurationMs`/`totalToolUseCount`/`usage`. **Ohne Befund — die härteste Vollständigkeitsaussage der ADR hält weiterhin.** |
| **N-12** | **Alternative E, Exporter-Detail** | *„das Werkzeug entfernt die Exporter-Variablen aus jedem Unterprozess, den es spawnt, einschließlich Hooks"* — `docs/user/claude-hooks-referenz.md:655`, sinngleich (*„entfernt `OTEL_*`-Exportervariablen aus jedem Unterprozess, den es spawnt … einschließlich Hooks"*). **Ohne Befund.** |
| **N-13** | **Re-Evaluierungs-Trigger, zweiter Punkt** (`:262-270`) | *„der greift genau ein Feld heraus und protokolliert nichts"* — `.claude/hooks/stop-require-gates.sh` vollständig gelesen (60 Zeilen): eine einzige Payload-Auswertung (`:21`, `stop_hook_active`), keine Protokollierung. *„vermessen sind die Schlüsselmengen von `PostToolUse`/`PostToolUseFailure` und die `tool_response` des `Agent`-Werkzeugs — sonst nichts"* deckt sich mit `spec/spezifikation.md:506-515`. **Ohne Befund.** |
| **N-14** | **Gate-Aussagen der Fitness Function** (`:210-215`) | `make comment-claims`: vier Pfad-Muster, kein Markdown (`Makefile:135`; die fünf Globs `internal/*.go`/`internal/**/*.go` treffen dieselbe Familie, `AGENTS.md:126` sagt dasselbe). `make docs-check`: genau `[links, anchors, ids, matrix, codepaths, spans]` (`.d-check.yml:18`). *„keine Behauptungen"* trifft zu — selbst gefahren: 287 Dateien, 0 Befunde, keine Zeile über Sätze. **Ohne Befund.** |
| **N-15** | **Der Präzedenzfall `ADR-0011` → `slice-059`** | *„mit **fünf** `test/mutations/`-Zeilen angenommen"* — `0011-…:328,329,330,331,335`, ausgezählt: fünf. *„dort nannte der umsetzende Slice die Zähne in seiner eigenen Definition of Done (*„Zwei Zähne, rot gesehen"*) und dieselben zwei in seiner Plan-Tabelle"* — `slice-059:82` (DoD (3), wörtlich) und `:168` (*„die zwei Zähne aus DoD (3)"*). **Ohne Befund** (die dritte Zahl desselben Satzes ist **L-1**). |
| **N-16** | **Der historische Auflösungs-Trigger** (`:61`) | *„eine Quelle innerhalb des Repos, die Haupt-Kontext-Token trägt"* — `git show a4199c9:harness/conventions.md:1143-1144` verbatim. **Ohne Befund.** |
| **N-17** | **Trichter-Frage 1, übrige Stützen** (`:83-87`) | *„dieses Repo führt genau **einen** Carveout"* — `docs/plan/carveouts/` führt `CO-001-bats-shell-lint.md` und ein `README.md`; Geltungsbereich `shell-lint`/bats, kein Überschnitt. *„sie folgt nicht aus dem Muster *„Code existiert vor Doku"* — die Doku ist hier vollständig"* ✓. *„durch einen `PreToolUse`-Guard bereits verkleinert"* → `spec/spezifikation.md:425-434` ✓. **Ohne Befund** (die vierte Stütze ist **M-1**). |
| **N-18** | **Annahmen ↔ Re-Evaluierungs-Trigger** | `:108-111` nennt (a) Hook-Oberfläche, (b) Transkript-Ausschluss, (c) kein eigener Empfänger und sagt *„Alle drei stehen unten als Re-Evaluierungs-Trigger"*. Geprüft: (a) → `:256-261`, (b) → `:271-274`, (c) → `:275-278`, jeder mit `*(feedforward — …)*`-Kennzeichnung; der vierte (`:262-270`) löst die Zusage aus `:94-102` ein. **Vollständig, ohne Befund.** |
| **N-19** | **Hard Rules** | §3.1: kein Gate in `make gates`, `AGENTS.md` §4 oder `harness/README.md` behauptet; die in der Fitness Function genannten Targets `make test`/`make mutate` existieren (`Makefile:37`). §3.2/§3.3: nicht berührt (`0d4d49b` ist ein reiner Inhalts-Commit an einer Datei, kein Move). §3.4: Status bleibt **Proposed** (`:3`), Index-Eintrag ebenfalls (`README.md:20`); keine Accepted-ADR überschrieben, keine Supersedes-Kette angefasst. §3.5: keine Gate-Lockerung — die ADR fügt zwei Wächter-Zeilen hinzu. **Ohne Befund.** |
| **N-20** | **Template-Konformität** | Gegen `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`: alle Pflicht-Abschnitte vorhanden (Status · Datum · Autor · Bezug · Schärft · Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function · Re-Evaluierungs-Trigger · Geschichte); ≥ 3 Alternativen (sieben, A–G); `Schärft` gefüllt und mit Aufwärts-Deklaration; Geschichte-Tabelle mit Datum/Ereignis/Verweis geführt; ADR-Index aktualisiert. **Ohne Befund.** |
| **N-21** | **Repo-Regel „eine ADR nennt keine Slice-Kennungen"** | Über die ganze Datei gemessen (`grep -niE 'slice-[0-9]'` und `'welle-[0-9]{2}'`): **null** `slice-NNN`-Kennungen, **null** `welle-NN`-Kennungen — auch in der Verweis-Spalte der Geschichte-Tabelle, die die Regel ausnehmen würde (`.d-check.yml`-Kommentar *„Provenance nur in den Historie-/Geschichte-Tabellen (ausgenommen)"*; `slice-072` DoD (1) nennt `ADR-0012` ausdrücklich als den Fall, den die künftige Regel fangen soll). Die Pflichten hängen an der **Funktion** (*„der Slice, der die Bilanz baut"*, *„der Slice, der die Rollen-Konvention schreibt"*) — genau die Prosa-Form, die `slice-072` DoD (3) als unsichtbar für die Regel benennt. **Ohne Befund; die Regel ist übererfüllt.** |
| **N-22** | **Gate-Lauf** | `make docs-check` selbst gefahren: `287 Datei(en) geprüft, 0 Befund(e)`. Die neun neuen Links, ihre Anker, die `ids`-Linkpflicht auf `ADR-`/`MR-`-Kennungen und die `matrix`-Regeln (u. a. `spec-straten` → keine Abwärts-Kennung) sind damit grün. **Ohne Befund.** |

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | **0** | — |
| **MEDIUM** | **3** | M-1, M-2, M-3 |
| **LOW** | **4** | L-1, L-2, L-3, L-4 |
| **INFO** | **4** | I-1, I-2, I-3, I-4 |
| **Negativbefunde** | **22** | N-1 … N-22 |

**Zur Eskalations-Regel des Skills.** M-1, M-2, L-3 und L-4 sind **eine** Klasse: eine Aussage
über Bestand, der inzwischen umgezogen oder geschlossen ist, wurde nicht am neuen Stand geprüft.
M-3 ist dieselbe Klasse auf der Zeit- statt der Orts-Achse. `0d4d49b` hat genau diese Klasse
adressiert — aber am **Linkziel**, nicht am **Satz**: die neun Verweise zeigen jetzt richtig, und
zwei der neun Sätze und drei Sätze **ohne** Verweis sagen weiterhin, was der neue Ort nicht
hergibt. Das ist die dritte Sitzung mit derselben Klasse an diesem Dokument (Vorgänger-Runde:
H-1/M-1/M-2/M-3) und damit über der Steering-Loop-Schwelle. Der strukturelle Grund ist benannt
und unverändert: für Zuschreibungen in Markdown existiert in diesem Repo **kein** Sensor —
`comment-claims` deckt kein Markdown, `d-check` prüft Links, Anker, Kennungen und Zeilenspannen,
keine Sätze —, und für ADR-Text kommt die Immutabilität ab *Accepted* hinzu: hier ist die
Prüfung nicht nur der einzige, sondern der **letzte** Sensor.

Ausdrücklich festgehalten: **alle fünf blockierenden Befunde der Vorgänger-Runde sind
aufgelöst**, und zwar mit Träger statt mit Umformulierung — die Nenner-Pflicht hat in
`slice-066` DoD (2) einen eigenen DoD-Punkt mit zwei namentlich genannten Zähnen und eine Zeile
in der Plan-Tabelle. Die schwierigste Vollständigkeitsaussage der ADR (3.383 Zeilen fremder
Doku) hält auch in dieser Runde, ebenso die Präzedenz-Rechnung, die Modul-7-Zitate und die
Annahmen-↔-Trigger-Abbildung.

---

## Verdikt

**NICHT KONFORM.**

Drei MEDIUM blockieren nach Skill (*„HIGH und MEDIUM blockieren typischerweise"*). Kein HIGH.

Der Nachzug `0d4d49b` ist in seinem erklärten Umfang **vollständig und richtig**: neun von zehn
`MR-018`-Verweisen zeigen jetzt auf `spec/spezifikation.md` §5, der zehnte steht begründet in der
Geschichte, `make docs-check` ist grün, und die substanzielle Änderung — Folgepflicht 1 — trägt
in allen drei Teilaussagen am Original (N-2): Abweichung 6 führt keinen Trigger, das Verdikt
steht nicht dort, und `MR-021` verzeichnet es wörtlich als *ersatzlos* mit dem Grund *„Ein
zweiter Ort driftet"*.

Was der Annahme im Weg steht, ist **eine** Sache: **der Nachzug hat die Verweise geprüft, nicht
die Sätze um sie herum.** Zwei Aussagen, die am alten Ort belegt waren und die die
Vorgänger-Runde dort als haltbar gemessen hat, sind am neuen Ort widerlegt — der „ernst
erreichbare Trigger" der Nachbar-Abweichung, den der Umzug als Prozess-Zustand gestrichen hat
(M-1, `:80-83`), und die Zuordnung aller sechs Abweichungen an ein Pflicht-Minimum, die derselbe
Umzug in einem eigenen Commit ausdrücklich als falsch benannt und korrigiert hat (M-2, `:41-42`).
Dazu eine Folgepflicht, die im Präsens einfordert, was seit dem Abschluss des Trägers steht, und
dabei eine Aussage über das heutige Closure-Vokabular trifft, die nicht mehr zutrifft (M-3,
`:177-186`) — dieselbe Diagnose, die derselbe Commit für Folgepflicht 1 gestellt und behoben hat.

Über die Annahme entscheide ich nicht; ich stelle den Zustand fest. Die Entscheidung selbst —
Option F, permanent, mit der Nenner-Pflicht als positiver Hälfte — ist in dieser Runde an keinem
Punkt strittig: der Trichter ist in der Reihenfolge des Moduls durchlaufen, die Alternativen sind
vollständig, die Fitness Function ist zweigeteilt und hat für die prüfbare Hälfte einen Träger
mit zwei Zähnen. Die drei MEDIUM liegen sämtlich in Sätzen **über** den Bestand, nicht in der
Entscheidung — und genau deshalb sind sie vor der Annahme zu klären: ab *Accepted* wäre jeder
von ihnen nur noch per Supersedes zu korrigieren (`AGENTS.md` §3.4).

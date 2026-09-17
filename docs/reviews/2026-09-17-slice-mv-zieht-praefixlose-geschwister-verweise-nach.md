# Review-Report: `slice-mv-zieht-praefixlose-geschwister-verweise-nach` — 2026-09-17

**Review-Art:** Code — gegen den Slice-Plan, `ADR-0042` und die Hard Rules aus `AGENTS.md` §3.

**Gegenstand:** Commit `da1f3419` (10 Dateien, +231/−78), Plan des Slice
`slice-mv-zieht-praefixlose-geschwister-verweise-nach` am Stand `da1f3419`.

**Skill:** `.harness/skills/reviewer.md` @ `1b643a87` (Version 2.0.0) ·
**Modell:** `claude-opus-5` · **Datum:** 2026-09-17

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext:**

- Slice-Plan `slice-mv-zieht-praefixlose-geschwister-verweise-nach` (§1–§6, §8)
- `ADR-0042` (Festlegung 1, 2, 4), `ADR-0028`
- `LH-QA-01`
- `AGENTS.md` §3.3, §3.6, §3.7, §3.9, §3.10, §3.11
- vorherige Findings am selben Werkzeug: die Reviews zu `slice-stilllegungs-kanten-sind-gemessen`
  und `slice-144`
- `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine,
  `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen,
  `templates/docs/reviews/review-report.template.md`

---

## Eigene Messung

Alle Läufe laufen außerhalb des Repos im Scratch-Verzeichnis dieser Sitzung. Die Kopien entstehen
mit `git archive HEAD | tar -x`, die bats-Stufe läuft über `make -C <kopie> test-bats`. Keine
Kopie trägt `.git`, deshalb fällt in jeder Kopie zusätzlich
`not ok 188 driver: die Kopie traegt den Sensor-Bedarf inklusive .git`. Dieses Rot gehört zum
Aufbau und nicht zur Mutation.

| Lauf | Ergebnis |
|---|---|
| Mutation 363 (`bash test/mutations/363-….sh`, `diff` zeigt genau die gelöschte `sed`-Zeile 188) | `make` Exit 2; `not ok 275 eingehend praefixlos: …` mit `Ist-Bestand (/code/harness/tools/slice-mv.sh) weicht ab:`, darunter die Probe mit **unveränderten** Links `[a]`, `[b]`, `[f]`. Das Rot hat also die behauptete Ursache. Daneben fällt `not ok 282 kopplung: …` mit `Rumpf von rewrite_incoming_bare_in_file weicht … ab`. Sonst 308 × `ok`. |
| Mutation 346 (unverändert angewandt) | `make` Exit 2; `not ok 282 …` mit `Rumpf von rewrite_incoming_in_file weicht … ab`, sonst grün. |
| Abgleich wie in `harness/tools/mutate.sh` (`grep -E 'not ok [0-9]+' \| grep -qF "$expect"`), über beide Ausgaben | beide `expect`-Zeilen gefunden, jede in der Zeile des behaupteten Falls |
| Gegenmutation am Aufruf: in `main()` der Dogfood-Fassung `n="$(rewrite_incoming_bare_in_file …)"` durch `n=0` ersetzt | `make` Exit 2 allein wegen 188; 310 × `ok`. **Kein Fall bemerkt den fehlenden Aufruf** (siehe F-4). |
| `main()` real in einem Mini-Repo (Host-`bash` und `git` wie im Rezept von `make slice-mv`, lokale Identität), `slice-a-ziel` von `open` nach `done` | Exit 0; Move-Commit `0 0` (reiner Rename). Ersetzt wurden `[1](…)`, `[2](…#7-closure)`, der Code-Span `` `[3](slice-a-ziel.md)` `` und `[q](…)` in einer Datei mit zusätzlicher Präfix-Form. Stehen blieben der Code-Span mit bloßem Namen, der Tree-Operand, `.mdx`, `./`-Form, der längere Name, die Referenz-Definition, eine Datei in `open/sub/`, eine ungetrackte Datei unter `open/`, die ADR (Präfix- **und** präfixlose Form) und ein Stub unter `done/welle-x/`. Ausgabe `4 Datei(en) … darin 4 praefixlose(r) Link(s)`; zwei der vier Dateien tragen beide Formen und zählen einmal. |
| dasselbe Mini-Repo, `slice-a-ziel` von `done` zurück nach `open` | Exit 0; das flache `done/slice-z-closed.md` bekommt `[z](../open/slice-a-ziel.md)` (siehe F-2) |
| Zahlen der Kanten-Tabelle, am Baum `da1f3419` | `slice-070-comment-claims-pruefbereich`: 6 Links in 5 Dateien; `slice-103-traeger-waechter-decken-was-sie-sagen`: 3 Links in 2 Dateien. Das deckt die Tabelle. |
| Blob-Angaben | `git rev-parse --short HEAD:harness/tools/slice-mv.sh` → `7eaeb0df`, dasselbe an `0ea7e148` → `d1bda5b4` |
| Zählschleife der Sensor-Datei gegen die Ersetzungsform `](<name>)`/`](<name>#` | `open: 56`/`56`, `next: 8`/`8`; beide Mengen sind am Bestand gleich |
| Zählkommando aus Grenze 3 | läuft, gibt `0` aus |
| präfixlose Links zwischen flachen Dateien unter `done/` (dieselbe Schleife mit `done`) | `380` |
| Einzelfall-Filter von `make mutate` | keiner: `harness/tools/mutate.sh` liest `MUTATE_FORCE`, `MUTATE_JOBS`, `MUTATE_STALL_SECONDS` |

**Nicht nachgefahren:** Die Messung der Kanten am echten Baum mit `make docs-check`, dazu
`make smoke` und `make full-smoke`. Ihre Zahlen stammen aus dem Umsetzungs-Commit. Unabhängig
davon prüft der Mini-Repo-Lauf oben die Verdrahtung, und die Link-Zahlen sind am Baum nachgezählt.
Keine Zahl dieses Abschnitts ist ein Erwartungswert.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der in diesem Diff geschriebene BELEG-Satz lautet *„die main() an jenem Stand nicht nachzog; der heutige Stand zieht sie nach"*. Er beschreibt ein früheres, heute abwesendes Verhalten, also Chronik statt Stelle. Zweite Fundstelle: Der Diff fasst eine Zeile in Mutation 346 an und lässt ihr Lauf-Protokoll im Präteritum stehen (*„alle Fall-Saetze blieben mit dieser Mutation gruen"*). | `AGENTS.md` §3.7; `v6.9.0` · `regelwerk/grundlagen-harness-dateien.md` §Was ein Kommentar trägt | `harness/tools/slice-mv.sh:58-59`; `test/mutations/346-lifecycle-ersetzung-nur-in-einer-fassung.sh:13` | nein: `AGENTS.md` §3.7 nennt keinen Wächter | `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` |
| F-2 | LOW | Plan §6 Risiko 4 knüpft den Ausgang *entfallen* an eine Beschränkung auf `open/`, `next/` und `in-progress/`. Der Code beschränkt nicht: `main()` nimmt `done` als Ausgangsverzeichnis an, und die Ersetzung schreibt dann in flache `done/`-Geschwister (Mini-Repo; Bestand 380 solche Links). Grenze 3 spricht für ihr Zählkommando von „drei Ausgangsverzeichnissen". | Slice-Plan §6 Risiko 4; `ADR-0042` Festlegung 1 | `harness/tools/slice-mv.sh:96-100`, `:299`; dasselbe in `internal/emit/templates/enforce/slice-mv.sh:240` | ja: Mini-Repo, `make slice-mv … TO=open` für einen Slice aus `done/` mit präfixlosem Geschwister-Link | Risiko-Bedingung des Plans vom Code nicht erfüllt |
| F-3 | LOW | Im Funktionskommentar zeigt *„Markdown liest sie nicht"* grammatisch auf die Formen, die stehen bleiben, nicht auf die Regel. Die Grenze, auf die der Satz zeigt, ist an der Funktion darum nicht lesbar: Ein Code-Span, der die Link-Syntax trägt, wird ersetzt (Mini-Repo, `[3]`). | Maintainability; `AGENTS.md` §3.7 (Klasse *Grenze*) | `harness/tools/slice-mv.sh:182`; `internal/emit/templates/enforce/slice-mv.sh:127` | nein | Grenz-Satz im Kommentar mit unklarem Bezug |
| F-4 | INFO | Kein Zahn deckt, welche Dateien `main()` der präfixlosen Ersetzung übergibt (`git grep` mit `:(glob)`), und ebenso wenig die Kommentar-Zusage *„zaehlt in $in_count nicht doppelt"*. Die Gegenmutation am Aufruf lässt `make test-bats` grün. Die Lücke ist an beiden Stellen deklariert; ihre Adresse `slice-mv-kanten-nach-done-sind-bewacht` nimmt die Geschwister-Verweise in ihrer DoD an. Zuständig: Planner. | `AGENTS.md` §3.6 | `harness/tools/slice-mv.sh:285-299`; `harness/sensors/slice-mv.md:80-86` | ja: Gegenmutation wie oben unter §Eigene Messung | Aufruf-Verdrahtung ohne Zahn (Stufe ohne git) |
| F-5 | INFO | DoD 3 verlangt die Mutation „mit `make mutate` gesehen". Implementer und Reviewer haben sie beide von Hand gefahren, mit `make test-bats` in einer Kopie, denn `make mutate` hat keinen Einzelfall-Filter. Den Grün-Vorlauf und die Rücksetzung von `harness/tools/mutate.sh` fährt dieser Weg nicht. Ob das den DoD-Punkt trägt, entscheidet die Verifikation. Zuständig: Verifier. | Slice-Plan §2 DoD 3 | Slice-Plan §2 | ja: `make mutate` | — |

### Zu den drei offenen Punkten des Implementers

**1 — Ersetzung auch bei `from=done` (F-2).** Die Begründung aus `ADR-0042` Festlegung 1 trägt,
soweit es um den **Baum** geht: Festlegung 1 nennt `docs/plan/planning/done/` ausdrücklich als
Zeitdokument, in dem die Adresse ersetzt wird. Die Ausnahme aus Festlegung 2 bleibt gewahrt; die
ADR im Mini-Repo blieb unverändert. Nicht getragen ist ein Satzteil: Festlegung 1 bindet den
Nachzug eines **vom Prozess vorgeschriebenen** Ortswechsels, und aus `done/` führt keine Kante
(`v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine, `done --> [*]`).
Für `from=done` entscheidet Festlegung 1 also nichts. Eine neue Klasse von Schreibzugriffen führt
der Diff damit trotzdem nicht ein: Die Präfix-Ersetzung schreibt schon vor diesem Diff bei jedem
Wechsel, auch aus `done/`, in `done/**`, und das Werkzeug nimmt `done` als Ausgang an. Der Befund
ist deshalb die Abweichung vom Plan, nicht ein Verstoß gegen die ADR. Der Plan nennt als Bedingung
für *entfallen* die Beschränkung, und die ist nicht erfüllt. Welcher Ausgang für Risiko 4 gilt und
mit welcher Begründung, legt der Planner bei der Closure fest.

**2 — Die Auswahl in `main()` hat keinen Zahn (F-4).** Das ist **keine HIGH-Lücke**, sondern
adressierbar, aus drei Gründen:

- Die Zusage ist einmal rot gesehen, und zwar am realen Vorzustand, den
  `v6.9.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen
  neben dem Mutationstest zulässt. Die Gegenprobe über Blob `d1bda5b` zeigt je Kante genau so viele
  `target-missing`, wie das Zählkommando präfixlose Links nennt. Diesen Lauf hat der Review nicht
  nachgefahren. Die Link-Zahlen hat er am Baum nachgezählt, die Verdrahtung im Mini-Repo gefahren.
- Die fehlende Dauer-Bewachung steht an beiden Stellen, an denen ein Leser sie sucht: im Skriptkopf
  (Grenze 3, letzter Satz) und in der Sensor-Datei (*„Welche Dateien `main()` ihr übergibt, fährt
  keine bats-Stufe"*). Das gepinnte bats-Image führt kein `git`.
- Die Adresse nimmt die Sendung an: Plan §1 schließt den `git`-Wächter mit Verweis auf
  `slice-mv-kanten-nach-done-sind-bewacht` aus. Jener Slice liegt in `open/`, bewacht nach seinem
  §1 das Ergebnis dieses Slice und nennt die präfixlosen Geschwister-Verweise in seiner DoD.

Die Gegenmutation oben bestätigt die Lücke, wie der Implementer sie beschreibt. Mit ihr gilt auch
die Zusage zur Einfach-Zählung als ungedeckt. Im Mini-Repo hielt sie.

**3 — BELEG-Absatz im Skriptkopf (F-1).** Der Absatz liest sich nicht nur chronikartig, er ist
Chronik. Der BELEG-Block ist als Ganzes ein Lauf-Protokoll aus dem Bestand, und diesen Bestand
bindet `AGENTS.md` §3.7 nicht. Der Diff hat den Block aber angefasst und dabei einen neuen Satz
geschrieben, der ein früheres Verhalten dem heutigen gegenüberstellt. Das ist das Falsch-Beispiel
*„die frühere Fassung prüfte nur die Länge"* auf Verhalten statt auf Text angewandt. Die Hard Rule
bindet jeden Kommentar, der geschrieben oder geändert wird. Der Skill führt diese Klasse als HIGH.
Widerspricht der Implementer der Einstufung, gilt der Konflikt-Pfad aus Modul 8: ein Verdikt des
Architect als Artefakt, keine Herabstufung.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Ersetzungs-Regex beider Fassungen: Link mit und ohne Anker, Code-Span mit bloßem Namen, Tree-Operand, Präfix-Form, längerer Name, `.mdx`, `./`-Form, Referenz-Definition | geprüft (bats 275, Mini-Repo), ohne Befund außer der deklarierten Code-Span-Grenze |
| Auswahl der Geschwister: flach, nur getrackt, ADR und vendored Baum ausgenommen, Stub-Unterverzeichnis unberührt | geprüft (Mini-Repo), ohne Befund; zu `done` siehe F-2 |
| Zähler `in_count`/`bare_count`, Ausgabe- und Commit-Zeile | geprüft (Mini-Repo), ohne Befund |
| `AGENTS.md` §3.3: Move-Commit bleibt reiner Rename | geprüft (Mini-Repo, `0 0`), ohne Befund |
| Kopplung: `rewrite_incoming_bare_in_file` in `KERN`, Rümpfe wortgleich; Titel des Kopplungs-Falls und `expect` von 346 | geprüft (Mutationen 346 und 363), ohne Befund |
| `AGENTS.md` §3.6, Mutation 363: färbt rot aus dem behaupteten Grund, `expect` trifft | geprüft, ohne Befund |
| Kanten-Tabelle und Blob-Angaben in `harness/sensors/slice-mv.md` | geprüft (nachgezählt), ohne Befund |
| Aussage „Jeder davon bekommt … vorangestellt" über die Zählmenge | geprüft (Mengen gleich), ohne Befund |
| Pflichtgliederung der zwei Sensor-Dateien: die fünf `##` der Vorlage `gate.template.md`, eigener Stoff als `###` | geprüft, ohne Befund |
| Stoff-Umzug: Nichts wandert zwischen Dateien, Umformulierungen stehen am Ort | geprüft, ohne Befund |
| Exit-Aussagen: Tabelle `0, make`; `docs-check` mit `d-check Exit 1, make Exit 2` getrennt | geprüft, ohne Befund |
| `ADR-0028`: Die zwei `implement-slice.md`-Fassungen hat die ausführende Rolle geändert | geprüft, ohne Befund |
| `AGENTS.md` §3.10: Der Plan ist nur in der Datei-Tabelle §3 erweitert (erlaubt nach `.claude/commands/implement-slice.md:113`), DoD, §1, §5 und §6 sind unverändert | geprüft, ohne Befund |
| `AGENTS.md` §3.9: keine Host-Toolchain im Diff | geprüft, ohne Befund |
| `AGENTS.md` §3.11: neue Pfade nur in lebenden Artefakten (Skriptköpfe, Sensor-Dateien, Anleitungen) | geprüft, ohne Befund |
| Zählkommando aus Grenze 3 | geprüft (läuft), ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`
(vorhandene Register-Kennung) · Risiko-Bedingung des Plans vom Code nicht erfüllt ·
Grenz-Satz im Kommentar mit unklarem Bezug · Aufruf-Verdrahtung ohne Zahn (Stufe ohne git)

## Verdikt

**Merge-blockierend:** ja, wegen F-1 (HIGH, `AGENTS.md` §3.7). Der Commit ist bereits gepusht. Die
Blockade gilt deshalb für die Closure: Der Slice geht nicht nach `done/`, solange F-1 offen ist.
F-2 und F-3 sind vor der Closure zu klären. F-4 und F-5 gehen an Planner bzw. Verifier. Das
Werkzeug selbst ist in seiner Funktion ohne Befund: Die Ersetzung trifft nur die Link-Form, die
Grenze 3 nennt, und die Mutation 363 hat Zähne.

**Übergabe:** Die Findings gehen an den Implementer. F-2 geht zusätzlich an den Planner (Ausgang
von Risiko 4), F-4 an den Planner (Folge-Slice), F-5 an den Verifier. Die Finding-Klassen gehen in
die Slice-Closure §7. Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation.

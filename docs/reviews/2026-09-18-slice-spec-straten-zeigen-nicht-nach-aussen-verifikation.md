# Verifikations-Bericht: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18

**Rolle/Art:** Verifier (Modul 11) — DoD-/ADR-Konformität **und** Plan-vs-Code-Diff. **Nicht** gegen
den Review (das war der Reviewer), sondern gegen DoD, Spec und Plan. Der Eingang ist der Stand
**nach** dem Review, die Prüfgrundlage liegt im Slice selbst.

**Gegenstand:** der Lieferstand des Slice — `8cabca1e` (Dogfood-Regel und 13 Fundstellen),
`7c9a2741` und `89f17f54` (emittierte Ebene), `bfd05e97` (erzeugte E2E-Sicht), `e621fbc2`,
`55621868`, `64517a2c` (Review-Runden), `749b0b9d` (Architect-Verdikt Runde 2) —, gemessen am
Baumkopf `d65d2a14`, dem Planner-Zug, der DoD 1 auf den gelieferten Stand gezogen hat.

**Eingangs-Kontext:** der Slice-Plan `slice-spec-straten-zeigen-nicht-nach-aussen` (DoD, §1, §4,
§6, §8) · die kanonischen Quellen, auf die er sich beruft (`LH-FA-03`, `LH-QA-01`, `MR-001`,
`MR-017`, `MR-054`) · `v6.9.0` · `regelwerk/modul-11-verification.md`, `modul-05`, `modul-13`,
`grundlagen-referenz-richtung.md` · `AGENTS.md` §3.5, §3.6, §3.7, §3.9.

**Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*: Dieser Bericht friert ein und nennt darum
**Kennungen statt Adressen** — `slice-<Kennung>` statt Lifecycle-Pfad, `make <target>` statt eines
Links auf die Sensor-Datei, eine Baseline-Stelle als Tag + Pfad im Code-Span. Ortsfeste Ablagen
(`AGENTS.md` §<N>, `harness/sensors/docs-check.md`) stehen als Pfad. Markdown-Links sind vermieden,
wo das Ziel dem Lifecycle folgt.

**Eigene Läufe** (Docker-only über `make`, kein Host-Werkzeug):

1. `make docs-check` über diesen Baum mit einem angehängten Link aus `spec/architecture.md` auf den
   ADR-Index → `d-check: 1689 Datei(en) geprüft, 1 Befund(e)`, die Zeile
   `spec/architecture.md:257  ../docs/plan/adr/README.md  matrix-forbidden  Referenz spec-straten → aussen ist nicht erlaubt`
   — der Befund ist genau der eingeschmuggelte; der unveränderte Bestand trägt also `0`.
2. Derselbe Lauf mit zusätzlich einer blanken `MR-001` in `spec/spezifikation.md` → `2 Befund(e)`,
   die zweite Zeile `spec/spezifikation.md:739  MR-001  id-unlinked  Kennung ohne Link auf ihre Definition`.
3. `make docs-check` mit zwei konstruierten Slice-Pfaden und je einem Verweis aus
   `spec/architecture.md` → `1691 Datei(en) geprüft, 2 Befund(e)`, und die Meldungen trennen die
   Klassen: `…/done/welle-verifier-sonde/slice-flach.md` → `Referenz spec-straten → slice …`,
   `…/done/welle-verifier-sonde/viel/tiefer/slice-tief.md` → `Referenz spec-straten → aussen …`.
   Damit ist die Eigenschaft *`*` überquert keine `/`-Grenze* **selbst gemessen**: die enge
   Pfad-Liste greift, und der tiefe Pfad fällt nicht in eine Lücke, sondern in `aussen` und bleibt
   verboten. Nach jedem Lauf ist der Arbeitsbaum zurückgesetzt (`git status --porcelain` → leer).
4. `gh run view` auf die CI-Läufe `35342965850` (Push von `2f09676a`) und `35343478857` (Push von
   `d65d2a14`): beide grün, `full-smoke` 4m05s bzw. 4m05s, `gates` 3m04s; im Log des `full-smoke`
   stehen die zwei **neuen** Zähne mit ihren Meldungen (Abschnitt *Rot-Belege*).
5. `make gates` über dem Stand dieses Berichts → **EXIT 0** (nach dem Review-Stand nicht
   wiederholt, weil davor nichts am Baum geändert wurde; für diesen Bericht neu gefahren, damit der
   Stop-Hook einen gedeckten Baum sieht).

**Bewusst nicht wiederholt:** `make docs-check` über den unveränderten Kopf (`0 Befund(e)` steht als
Differenz-Rechnung aus Lauf 1: 1 Befund = der eingeschmuggelte) · die Mutations-Läufe des Reviewers
in seinem Wegwerf-Klon · die `full-smoke`-Zähne im eigenen Lauf (sie sind im CI-Log desselben
Baums eingefroren, und der Zahn-Lauf ist teuer).

---

## DoD 1 — Dogfood: Regel, Genauigkeit, Bestand — **erfüllt**

| Kriterium | Ausgang | Beleg |
|---|---|---|
| Der `matrix:`-Block trägt die drei Zeilen aus §1 | erfüllt | `sed -n '/^matrix:/,/^codepaths:/p' .d-check.yml` → Klasse `aussen: ["**"]` als **letzte** Klassen-Zeile, Regel `{from: spec-straten, to: aussen, allow: false}`, `exempt-paths`-Zeile |
| Klasse `slice` auf ausdrücklichen Pfaden statt `**`; `*`-Eigenschaft am gepinnten Stand gemessen | erfüllt | Pfad-Liste im Block (vier Lifecycle-Verzeichnisse + `done/*/slice-*.md`); Klasse **selbst gemessen** in Lauf 3: flacher Pfad → Klasse `slice`, tiefer Pfad → Klasse `aussen`, kein Durchgriff |
| `exempt-paths` nimmt die Review-Reports auf, Begründung an der Zeile | erfüllt | `exempt-paths: ["docs/plan/adr/README.md", "docs/reviews/**", "docs/plan/planning/done/welle-*.md"]`, mit dem Begründungs-Block unmittelbar darüber — inklusive der Gegenprobe, dass `done/**` **nicht** dort steht (das wäre die Senkung) |
| Jede Fundstelle der Sonde ist aufgelöst: die Aussage bleibt, die Referenz fällt (auch die zwei `MR`-Nennungen in §5 und die Rückbezüge ohne Ziel aus F-5) | erfüllt | `grep -cE '(MR-[0-9]{3}\|ADR-[0-9]{4})' spec/spezifikation.md spec/architecture.md` → `0` und `0` (die 12 im Lastenheft liegen in dessen ausgenommener Historie); `grep -nE 'wie dort\|dort gemessen\|ebenda\|siehe dort\|vgl\.' spec/spezifikation.md spec/architecture.md` → kein Treffer. Die Sätze lesen sich ohne ihre Quelle: der Zeiger `CO-002`/Report entfällt, die Aussage bleibt, und wo der Satz seine einzige Quelle im Verweis hatte, ist er auf das zurückgeschnitten, was er ohne sie hält |
| `make docs-check` meldet `0 Befund(e)` | erfüllt | Lauf 1 gegen den unveränderten Baum: die Gesamtzahl ist 1 und die eine Zeile ist die eingeschmuggelte → Bestand 0. Der Kopf-Stand ist zusätzlich mit `make docs-check` belegt (1689 Dateien / 0 Befunde) |
| Je Spec-Stratum der eigene Träger: `spezifikation.md` eine Zeile in §7 Historie, `architecture.md` der Frische-Marker im Kopf auf dem Datum der Änderung | erfüllt | `sed -n '/^## 7\. Historie/,$p' spec/spezifikation.md` → Zeile `\| 2026-09-18 \| §5 trägt keine Referenz nach außen mehr …`; Kopf von `spec/architecture.md` → `**Status:** Aktiv. **Letzte Änderung:** 2026-09-18.` Das Datum ist das der Änderung (der Umsetzungs-Commit `8cabca1e` ist vom 2026-09-18). Das Lastenheft ist unberührt und braucht keinen Träger |
| **Rot gesehen**: ein Link aus einem Spec-Stratum auf den ADR-Index färbt `matrix-forbidden`, die Meldung nennt die neue Regel | erfüllt | **selbst gefahren**, Lauf 1 — die zitierte Meldung nennt die Regel beim Namen. Das Kommando steht als Sonde im Abschnitt *Modul `matrix`* von `harness/sensors/docs-check.md` (Commit `7c9a2741`, ein Umsetzungs-Commit dieses Slice) |

## DoD 2 — Emission: die Regel geht ins Ziel, das Ziel startet grün — **erfüllt**

| Kriterium | Ausgang | Beleg |
|---|---|---|
| `internal/emit/templates/d-check.yml` trägt Klasse und Regel; der Kopfkommentar nennt die neue Position | erfüllt | Diff von `eb6e23e2..d65d2a14`: `+ adaptionsblock` mit `token: 'MR-\d{3}'`, `+ aussen`, `+ {from: spec-straten, to: aussen …}`; Kopfkommentar: *„Vier Positionen gehen darueber hinaus … Die dritte ist die Klasse aussen … Die vierte ist die Klasse adaptionsblock …"* |
| Klassen `slice` und `welle` stehen beide auf `**`, und die Entscheidung steht als Kommentar im Template | erfüllt | `grep -c '\*\*/\(slice\|welle\)-\*\.md' internal/emit/templates/d-check.yml` → `2` (Zeilen 53/54); Begründung im Kommentar über der `aussen`-Zeile: *„… eine engere Pfad-Liste waere hier eine Zusage ueber einen Dateibestand, den an dieser Stelle niemand messen kann"* |
| `make full-smoke` ist grün, das Ziel startet grün | erfüllt | CI-Lauf `35343478857` (Kopf `d65d2a14`, pushed) und `35342965850` (`2f09676a`): Job `full-smoke` ✓, Job `gates` ✓, Job `smoke` ✓. Nicht mein eigener Lauf — der Zahn-Lauf steht als CI-Beleg mit demselben Baum |
| Eine Referenz aus einem Spec-Stratum des Ziels nach außen färbt das emittierte Gate rot, Rot gesehen im E2E | erfüllt | die zwei neuen Zähne in `harness/tools/full-smoke.sh` (Diff-Abschnitte `(2a)` und `(3a)`) — beide im CI-Log von `35342965850` als *belegt* geführt, mit den gelesenen Meldungen (Abschnitt *Rot-Belege*) |
| Ob die Historie im Ziel ausgenommen wird, ist gemessen und nicht angenommen | erfüllt (indirekt gemessen) | Die emittierte Fassung trägt `exclude-sections: [Geschichte]`, `Historie` ist **nicht** ausgenommen; die vendored Spezifikations-Vorlage schreibt in ihrer §7 selbst *„kein ADR- und kein Slice-Verweis … Die Decken-Regel gilt für alle drei Spec-Straten, auch hier"*, und die Lastenheft-Vorlage *„Kein Spec-Stratum nimmt seine Historie davon aus … Die Spalte ‚Verweis' trägt den externen CR; der steht außerhalb des Repos"*. Gemessen ist das am grünen `full-smoke`: das Ziel fährt sein `docs-check` über seine Straten samt Historie und startet ohne Befund. **Stärke der Aussage:** sie gilt für die heutige Vorlagen-Fassung; eine künftige Vorlage mit einem Außen-Verweis in ihrer Historie färbte das Ziel rot, und dann greift die zweite Rückführung aus §4 |

## DoD 3 — Wer die bloße Kennung fängt, ist entschieden und belegt — **erfüllt**

| Kriterium | Ausgang | Beleg |
|---|---|---|
| Der Weg ist gewählt und je Ebene eigener Messung unterzogen | erfüllt | Dogfood: der `ids`-Block trägt `MR-\d{3}` mit `link-policy: always` (`sed -n '/^ids:/,/^# Referenz-Richtung/p' .d-check.yml`) → **selbst gemessen** in Lauf 2, `id-unlinked`. Emission: Klasse `adaptionsblock` mit `token: 'MR-\d{3}'` + Regel aus `spec-straten` → im Ziel über den `matrix-MR-Zahn` belegt (CI-Log) |
| Für `ADR-` trägt die vorhandene Klasse `adr` / der Nachweis über `ids` | erfüllt | Die `ADR`-Klausel ist unverändert (Kontext-Zeilen im Diff); die emittierte Fassung führt bewusst **kein** `ADR`-Token, und der Grund steht als Kommentar dort — der `id-unlinked`-Zahn in `full-smoke` fährt die bare ADR-Kennung im Ziel und ist grün |
| Der gefahrene Weg ist gegen den verworfenen belegt (kein `ids`-Muster für `MR` im Ziel) | erfüllt | die Verwerfung ist gemessen: ein `ids`-Muster `MR-\d{3}` auf `harness/conventions/` lässt ein frisches Ziel rot starten (`harness/conventions.md:13 MR-000 id-unlinked`), weil die emittierte Index-Datei ihre eigenen Kennungen blank nennt — die Begründung steht im Kopfkommentar des Templates und in Abschnitt *Modul `matrix`* der Sensor-Doku |
| Eine bloße `MR`-Kennung ist **rot gesehen** — Dogfood gegen diesen Baum | erfüllt | **selbst gefahren**, Lauf 2: `spec/spezifikation.md:739  MR-001  id-unlinked  Kennung ohne Link auf ihre Definition` |
| Dieselbe Kennung rot gesehen — Emission gegen ein Ziel | erfüllt | CI-Log von `35342965850`: `spec/lastenheft.md:7  MR-001  matrix-forbidden  Token-Referenz spec-straten → adaptionsblock (MR-001) ist nicht erlaubt — Provenance via <!-- d-check:status-provenance --> deklarieren` |

## Weitere DoD-Punkte

| Punkt | Ausgang | Beleg |
|---|---|---|
| `make gates` grün | **erfüllt** | eigener Lauf über dem Stand dieses Berichts, EXIT 0 (der Kopf-Stand ist zusätzlich vom Auftraggeber belegt) |
| Review durchgeführt, Report unter `docs/reviews/` liegt vor | **erfüllt** | vier Runden (`9f66eb13`, `2f8f6461`, `627b47f6`, `2f09676a`) plus zwei Architect-Verdikte (`7dee6676`, `749b0b9d`); die Runde 4 erklärt *frei für Verifikation und Closure* |
| Doku-Update: `harness/sensors/docs-check.md` nennt beim Modul `matrix` die neue Klasse und ihre Grenze | **erfüllt** | neuer Abschnitt *Modul `matrix`* mit drei benannten Grenzen (Referenzen statt Kennungen · `exclude-sections` · `exempt-paths` nimmt aus der Status-Prüfung, nicht aus den Regeln), jede mit Kommando |
| Closure-Notiz mit Steering-Loop-Lerneintrag · Beobachtungs-Register fortgeschrieben · jedes Risiko aus §6 mit Ausgang · drei Paarungen | **nicht prüfbar in diesem Lauf** | §6 führt alle fünf Risiken als `<offen>`, §7 alle Felder als *offen bis zur Closure*. Das ist **Planner-Arbeit** (`AGENTS.md` §3.10) und liegt nach dieser Verifikation. Die Register-Route für die Finding-Klasse dieses Slice (`neuer-waechter-ohne-mutations-fall`) steht in §8 und ist bei der Closure zu belegen |
| Reconciliation-Register entfällt | **erfüllt** | dieses Repo führt keine `reconciliation.md` |

---

## Die Rot-Belege (§3.6) — worauf meine Aussage jeweils ruht

| Zusage | Rot-Beleg | Worauf meine Aussage ruht |
|---|---|---|
| Neue Dogfood-Regel fängt einen Link nach außen | `matrix-forbidden  Referenz spec-straten → aussen ist nicht erlaubt` | **self-driven** (Lauf 1), am gepinnten Stand, mit gelesener Meldung; Baum danach zurückgesetzt |
| Dogfood-Regel fällt nicht auf den Bestand zurück (Gegenrichtung: der Sensor schweigt) | `1691 Datei(en), 2 Befund(e)` = genau meine zwei Einschmuggelungen | **self-driven** (Lauf 1–3): die Differenz zum unveränderten Bestand ist die Zahl 0 |
| Die enge `slice`-Klasse greift und hinterlässt keine Lücke | flacher Pfad → Klasse `slice`; tiefer Pfad → Klasse `aussen` | **self-driven** (Lauf 3) |
| Bare `MR`-Kennung im Dogfood | `id-unlinked` | **self-driven** (Lauf 2) |
| Emittierte Regel fängt eine Referenz nach außen im Ziel | `spec/lastenheft.md:7  ../README.md  matrix-forbidden  Referenz spec-straten → aussen ist nicht erlaubt` | **CI-Log** des Repos (Lauf `35342965850`, Job `full-smoke`), Zahn-Zeile *„matrix-aussen-Zahn belegt"*; nicht selbst gefahren |
| Emittierte Kennungs-Klasse fängt die bare `MR`-Kennung im Ziel | `matrix-forbidden  Token-Referenz spec-straten → adaptionsblock (MR-001) ist nicht erlaubt — Provenance …` | **CI-Log** desselben Laufs, Zahn-Zeile *„matrix-MR-Zahn belegt"* |
| Go-Test: `aussen`-Klasse und ihre Regel sind vorhanden; `aussen` ist die letzte Klasse; `exempt-paths` exakt; kein Welle-Pfad | Die vier Zähne `372`–`376` färben `TestDCheckConfig_EntschiedeneModulListe` rot | **Reviewer-Messung** (Runde 3/4, Wegwerf-Klon, je Lauf die `--- FAIL`-Zeile und die Assertion-Zeile); von mir **nicht** wiederholt. Für `372`/`376` zusätzlich die Gegenprobe mit geweitetem Muster (Runde 4), die belegt, dass der Fall an seinem Zahn hängt |
| Der verworfene Weg (`ids`-Muster für `MR` im Ziel) ist rot | `harness/conventions.md:13  MR-000  id-unlinked` im Ziel | **Implementer-Beleg** im Umsetzungs-Commit `7c9a2741`, nicht nachgefahren; die Konsequenz steht sichtbar im Template und in der Sensor-Doku |

**Zum Vorwurf der Lücke, den ich ausdrücklich *nicht* erhebe:** der Go-Test liest die **Vorlage**,
nicht ein gebootstrapptes Ziel. Das trägt hier, weil `internal/emit/emit.go` sie per `go:embed`
wörtlich einbettet und über `writeSkipIfPresent` **unverändert** schreibt (`grep -n 'go:embed templates/d-check.yml\|writeSkipIfPresent(targetDir, ".d-check.yml"' internal/emit/emit.go`
→ Zeilen 36 und 183) — für ein **frisches** Ziel sind Vorlagen-Bytes und Ziel-Bytes dieselben. Die
zwei Unterschiede, die bleiben, sind beide gedeckt: ein Ziel, das seine Konfiguration schon hat,
behält sie (skip-if-present — die Datei wird dann gar nicht geprüft, und das ist die dokumentierte
Klasse), und die *Wirkung* am realen Ziel misst ohnehin der E2E-Zahn, nicht der Unit-Test.

---

## Plan-vs-Code-Diff

**Was der Plan verspricht, was der Diff liefert:**

| Plan-Stelle | Diff | Ausgang |
|---|---|---|
| §3 Dogfood: `.d-check.yml` (`matrix:`) — Klasse, Regel, `exempt-paths` samt Begründung an der Zeile, enge Pfad-Liste | genau diese vier Änderungen, sonst nichts in der Datei (`exempt-paths`-Zeile plus Kommentar-Block unmittelbar darüber) | deckungsgleich |
| §3 Dogfood: `spec/spezifikation.md` §5, §7 · `spec/architecture.md` §5, Kopf | 12 Fundstellen + Historie-Zeile bzw. 1 Fundstelle + Frische-Marker; **keine** Gliederungs-Änderung, **kein** Satz-Umzug | deckungsgleich |
| §1-Ausschluss „Der Abweichungs-Abschnitt bleibt in §5" | der Abschnitt steht unverändert, nur seine Zeiger fallen | eingehalten |
| §3 Produkt: `internal/emit/templates/d-check.yml` | Klasse `aussen`, Klasse `adaptionsblock` + `token:`, zwei Regeln, `exempt-paths`, Kopfkommentar mit beiden Positionen | deckungsgleich, **eine Regel mehr als §1 wörtlich nennt** (s. V-1) |
| §3 Produkt: „Test der emittierten Konfiguration (die Datei nennt der Implementer)" | `internal/emit/emit_test.go` um vier Zusicherungen erweitert | deckungsgleich |
| §3 Produkt: „`harness/tools/full-smoke.sh` — update, falls das Gegenbeispiel im E2E läuft" | zwei neue Zähne im Ziel (`matrix-aussen`, `matrix-MR`) plus die Anpassung des Zähne-Kommentars von vier auf sechs | deckungsgleich |
| §3 Dogfood: „`test/mutations/` — neu, falls der neue Wächter ein Test ist" | fünf neue Fälle `372`–`376` | deckungsgleich |
| DoD „Doku-Update: `harness/sensors/docs-check.md`" | neuer Abschnitt *Modul `matrix`* | deckungsgleich |

**Gebaut, aber nicht im Plan §3 genannt — beide Richtungen geprüft:**

1. `docs/user/e2e-abdeckung.md` — die erzeugte Sicht ist mitgezogen (Zeilennummern der Stufen
   verschieben sich durch die zwei neuen Zähne). Sie ist **derivativ** (`make e2e-abdeckung` liest
   die Stufen-Deklarationen), ihr Inhalt hängt an `test/e2e-abdeckung.bats`, und dasselbe Werkzeug
   erzeugt sie bei jedem Lauf neu. Keine Plan-Lücke, aber eine Zeile in §3, die sie nicht nennt.
2. `docs/plan/planning/in-progress/roadmap.md` — der Ruhe-Marker *Nichts in Arbeit* ist entfernt
   (`8132860f`, Planner-Zug), weil `in-progress/` diesen Slice trägt. Derivativ auf die
   Verzeichnis-Position, Planner-Arbeit, nicht Implementer-Umfang.
3. Der zweite emittierte Regel-Eintrag (`spec-straten → adaptionsblock`) — von **DoD 3** ausdrücklich
   als Weg freigegeben („dieser Weg verlangt also eine eigene Klasse für den Adaptions-Block, vor
   `aussen` einsortiert"), von §1 wörtlich („genau **eine** Regel") nicht gedeckt. Der tragende Satz
   des Ausschlusses — *keine Regel, deren Quelle ein Planungs-Artefakt ist* — hält: beide neuen
   Regeln haben `spec-straten` als Quelle. Siehe V-1.

**Nichts geplant-und-nicht-gebaut.** Jede Zeile der beiden §3-Tabellen hat eine Entsprechung im
Diff.

**Kein Produkt-Verhalten außerhalb der Regel:** `git diff --stat eb6e23e2..d65d2a14` nennt im
Produkt-Baum allein `internal/emit/templates/d-check.yml` und `internal/emit/emit_test.go` —
`emit.go` ist unberührt, kein Modul wurde aktiviert (`modules:` unverändert), keine Datei außerhalb
von `.d-check.yml`, `spec/`, `internal/emit/`, `harness/`, `test/mutations/`, `docs/` ist berührt.
Auch kein Norm-Artefakt fremder Rollen: `AGENTS.md`, `harness/conventions.md` und die ADRs stehen
nicht im Diff.

---

## Befunde an den Planner

**V-1 (LOW, Plan-Text):** §1 sagt *„Der Slice fügt genau **eine** Regel hinzu"*, geliefert sind auf
der Emissions-Ebene **zwei** (`spec-straten → aussen` und `spec-straten → adaptionsblock`), auf der
Dogfood-Ebene genau eine. Die zweite ist durch **DoD 3** freigegeben (*„dieser Weg verlangt also
eine eigene Klasse für den Adaptions-Block"*) und steht in keinem Widerspruch zum tragenden Satz des
Ausschlusses (keine Quelle ist ein Planungs-Artefakt). Der Zähl-Wortlaut in §1 ist damit zu eng für
die eigene DoD. **Kein DoD-Verstoß** — eine Plan-Korrektur nach §3.10-Übergabe, kein Umschreiben
des Abnahmekriteriums durch mich.

**V-2 (INFO, Form):** DoD 1 verlangt `docs/reviews/*.md` in `exempt-paths`, geliefert ist
`docs/reviews/**` (ebenso die emittierte Fassung, dort ohne Welle-Pfad). Auf diesem Baum sind beide
Formen deckungsgleich; die weitere Form nimmt Unterverzeichnisse mit, was für eine
Zeitdokument-Ablage die richtigere Enge ist. Benannt, nicht beanstandet.

**V-3 (INFO, Grenze der Regel):** Die Dogfood-Ausnahme `exclude-sections` nimmt **jede** Historie
aus, nicht nur die des Lastenhefts, von dem §1 spricht. Damit steht die mit diesem Slice
hinzugefügte Historie-Zeile von `spec/spezifikation.md` selbst außerhalb der neuen Regel. Das ist
Bestand (die Zeile ist unverändert), und die Grenze ist in `harness/sensors/docs-check.md` ehrlich
benannt (*„Die Historie-Abschnitte stehen außerhalb …`ids` teilt diese Ausnahme **nicht**"*) — der
Closure-Satz zur Grenze sollte sie trotzdem in der Form nennen, in der sie gilt, und nicht als
Lastenheft-Sonderfall.

**V-4 (INFO, Register-Route):** Der Reviewer hat **R4-1 (LOW)** stehen gelassen. Ich bestätige seine
Einordnung **nicht blockierend**, aus denselben zwei Gründen und einem dritten: kein gelisteter
Mutant entkommt (die Presence-Klausel ist zusätzlich, ihr Mutant fällt über die Positions-Prüfung);
die Eigenschaft selbst ist am realen Ziel durch den `matrix-aussen-Zahn` gedeckt, den die CI fährt
(im Log belegt); und **kein DoD-Punkt** dieses Slice verlangt einen Mutations-Fall je Klausel — §3
verlangt Fälle für den neuen Wächter, und fünf sind geliefert. Die Feststellung des Reviewers
(*„ein Fall muss seine Zusicherung binden"*) gehört als Beleg in die Closure §7 zur
Register-Klasse `neuer-waechter-ohne-mutations-fall`, nicht in einen Implementer-Zug.

---

## Spec-Lücken

1. **Eine Prosa-Rückverweisung ohne Kennung und ohne Link ist unsichtbar.** Die neue Decken-Regel
   fängt Referenzen (Links) und — über `token:` bzw. `ids` — Kennungen. Ein Satz wie *„wie in der
   Nutzer-Doku beschrieben"* oder *„das Modul verlangt …"* bleibt in jedem Stratum grün, weil er
   weder Link noch Kennung trägt. Genau diese Form war der Befund F-5 am Sprung-Slice, und sie ist
   nur **handwerklich** geschlossen (die Sätze sind umgeschrieben), nicht mechanisch. Wer die Zusage
   *„die Aussage bleibt, die Referenz fällt"* für die Zukunft will, braucht einen zweiten Sensor —
   heute existiert keiner, und `modul-11` (§Fitness Function ohne Standard-Tool) benennt genau
   diesen Fall.
2. **Die Spec-Straten haben weiterhin keine benannte schreibende Rolle.** §1 schließt das für diesen
   Slice aus und nennt `slice-151-spec-straten-haben-eine-schreibende-rolle` als Adresse; §6 Risiko 4
   bleibt offen. Die Zusage dieses Slice hängt damit an einer Setzung, die im Baum nicht steht.
3. **Der `emittiert`-Bestand des Ziels ist nur über den E2E messbar, nicht über einen Unit-Test.**
   Das ist keine Lücke dieses Slice, sondern der Zuschnitt der beiden Ebenen — sie steht hier, weil
   DoD 2 sie selbst ausspricht und die Register-Beobachtung `emittierter-stand-laeuft-dem-dogfood-voraus`
   sie führt.

---

## Negativbefunde — geprüft, ohne Befund

| Bereich | Ergebnis |
|---|---|
| §1-Ausschlüsse 1–7 | eingehalten: `exclude-sections` unverändert · Abweichungs-Abschnitt bleibt in §5 · keine Gliederungs-Änderung (`##`-Ebenen von `spec/spezifikation.md` unberührt) · keine Festlegung einer schreibenden Rolle · keine Regel für die Gegenrichtung · kein `ignore-refs`-Paar · keine Verbots-Regel mit einem Planungs-Artefakt als **Quelle** |
| Keine halluzinierten Gates (`LH-QA-01`) | kein neues Target behauptet; die zwei E2E-Zähne laufen innerhalb des bestehenden `full-smoke`; der neue Mutations-Fall-Satz trifft nur existierende Tests |
| Kein Produkt-Verhalten außerhalb der Regel | `emit.go` unberührt, `modules:` unverändert, keine Aktivierung, keine Schwellen-Senkung (`AGENTS.md` §3.5): `exempt-paths` ist gegen die Zwei-Stand-Sonde begründet und als Kommentar an der Zeile dokumentiert |
| Keine Lint-Suppression (`AGENTS.md` §3.2) | kein `# shellcheck disable`, kein `//nolint` in den neuen Zeilen |
| Keine Norm-Artefakte fremder Rollen (`AGENTS.md` §3.8) | `AGENTS.md`, `harness/conventions.md`, `docs/plan/adr/**` stehen nicht im Diff |
| Kein Host-Werkzeug (`AGENTS.md` §3.9) | die neuen Zeilen in `full-smoke.sh` sind `sed`/`make`/`grep`; keine Sprach-Toolchain, kein Paketmanager |
| Der emittierte Block nimmt die **vorhandenen** Regeln unberührt | `{from: adr, to: slice}`, `{from: adr, to: welle}` und die `welle`-Klasse stehen als Kontext-Zeilen im Diff — Bestand, nicht mitgewachsen; die Baseline-Herkunft dieser Positionen ist im Kopfkommentar benannt |
| `exempt-paths` der emittierten Fassung ohne den Welle-Pfad, mit Begründung | geprüft, ohne Befund — der Kommentar nennt beide Gründe (kein Gegenstand im frischen Ziel; Status-Deckung der Klasse `welle`), und der Unit-Test verbietet jede Nennung des Pfades, auch im Kommentar (Zahn `375`) |
| Meldungs-Form der zwei neuen Zähne | geprüft, ohne Befund — beide verlangen `matrix-forbidden` **mit** der Regel-Klausel (`grep -qE 'matrix-forbidden.*spec-straten . aussen'` bzw. `'MR-001.*matrix-forbidden'`), also rot aus dem **richtigen** Grund, nicht irgendein Rot |
| Der Kopfkommentar des Templates gegen `AGENTS.md` §3.7 | geprüft, ohne Befund — Zustands-Aussagen im Indikativ, die Entscheidung (Pfad-Enge, kein `ids`-Muster) an der Stelle, kein Lauf-Protokoll, keine Befund-Kennung |
| Die zwei Spec-Träger gegen `AGENTS.md` §3.7 | geprüft, ohne Befund — die Historie-Zeile beschreibt den Zustand des Dokuments (nicht „wir haben entfernt"), der Frische-Marker trägt das Datum der Änderung; beide adressieren den, der die Stelle ändert, nicht den, der die Entscheidung traf |
| „Vorhanden ≠ behauptet" am emittierten Modul-Satz | geprüft, ohne Befund — kein Modul neu aktiviert; die zwei Zusicherungen liegen **innerhalb** aktiver Module (`matrix`), also unter `MR-017` und `AGENTS.md` §3.6, wie das Architect-Verdikt es festhält |

---

## Verdikt

**Drei Liefer-Punkte: bestätigt.** DoD 1, 2 und 3 sind erfüllt, je Unterkriterium mit dem Beleg
oben; die zwei Ebenen sind getrennt gemessen (Dogfood von mir selbst, Emission über den CI-Lauf des
Repos), und keine Zusage reicht weiter als ihr Sensor. **Keine DoD-Verletzung**, keine
Review-Finding-Klasse, die nur die Verifikation fängt.

**Offen und dem Planner übergeben:** die vier Punkte V-1 bis V-4 (drei INFO, ein LOW-Plan-Text) —
keiner blockiert die Closure. Die Closure-Pflichten des Slice (Notiz, Register, Risiko-Ausgänge,
Paarungen) sind in diesem Lauf **nicht** prüfbar, weil sie nach dieser Übergabe liegen
(`AGENTS.md` §3.10); §6 führt alle fünf Risiken als `<offen>`, und die Register-Route zu R4-1 steht
in V-4.

**Frei für die Closure durch den Planner.**

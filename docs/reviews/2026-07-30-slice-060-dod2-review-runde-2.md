# Code-Review Runde 2: slice-060 DoD (2) — die Auflösung der fünf blockierenden Befunde

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md` v1.4.0). **Datum:** 2026-07-30.
**Autor:** ai-harness-init-Team (pt9912). Frischer Kontext — weder der Code noch der
Runde-1-Report stammen von diesem Lauf.

## Kopf-Metadaten (die fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Inhalt |
|---|---|
| **Diff / Commit-Range** | Auflösungs-Runde `4ae9c98..b373d25` (11 Dateien, +751/−35); Gesamt-Slice `ff1f1a1..b373d25` (18 Dateien, +1528/−27) |
| **`LH-*`-Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), berührt: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| **Referenzierte aktive ADRs** | [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**), [`ADR-0003`](../plan/adr/0003-go-native-binaries.md), [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1 · §3.2 · §3.4 · §3.5 · §3.6 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-30-slice-060-dod2-review.md` (Runde 1: 1 HIGH · 4 MEDIUM · 4 LOW · 3 INFO), `…-slice-060-dod2-adr-0011-architect.md` (B1–B5, Z1–Z5), `…-slice-059-go-emitter-review*.md` (3 Runden), `…-slice-060-066-plan-review*.md` (4 Runden) |
| **Slice-Plan** (Repo-Ergänzung) | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` DoD (2), §3-Änderungstabelle, §6 |

**Nicht Gegenstand:** die DoD-Abhakung und die Bestätigung von Gate-Läufen (Modul 11).

**Gefahrene Sensoren (echte Ausgabe, nicht übernommen).** Kein `make mutate`-Vollauf
(Nutzer-Ausschluss). Stattdessen drei Sonden über den gesourcten Treiber-Pfad
(`harness/tools/mutate.sh` + `run_case`, isolierte Kopie außerhalb des Repos, Host-Baum
per `target_fingerprint` vor/nach gemessen und unverändert):

```
SONDE 1  mutate: ok  128-span-rolle-unnormalisiert   -> TestSpawnedRoleIsNormalised rot
         mutate: ok  129-span-modellschranke-kuerzt  -> TestResolvedModelIsStructurallyBounded rot
SONDE 2  (Variante A: mustNotContain-Block von TestUnlistedResponseKeyStaysOut gestrichen)
         mutate: BEFUND 127-span-positivliste-negiert  rot, aber 'TestUnlistedResponseKeyStaysOut'
                                                       faellt nicht — falscher Grund
SONDE 3  (Variante B: zusaetzlich `model_version` zurueck in die Gegenprobe = Fassung Runde 1)
         mutate: ok  127-span-positivliste-negiert   -> TestUnlistedResponseKeyStaysOut rot
```

Dazu: `bash harness/tools/comment-claims.sh Makefile` → Exit 1 mit einem Befund;
derselbe Scanner über die 149 indizierten Shell/bats-Dateien **außerhalb** des
Prüfbereichs; Auszählung des Span-Bestands (`.harness/state/spans/`, gitignored, nur
lesend); Auszählung von `test/mutations/`, `response_test.go`, der `MR-018`-Zahlen und des
`comment-claims`-Prüfbereichs gegen `git ls-files`.

---

## Bilanz über die zwölf Runde-1-Befunde

| Runde-1-Befund | Status |
|---|---|
| **HIGH-1** `comment-claims` blind für Untrackte, Stempel deckt sie | **halb** |
| **MEDIUM-1** `MR-018` sagt zweimal Gegenteiliges über den Cache-Status | **geschlossen** |
| **MEDIUM-2** `spawned_role` beruft sich auf die `agent_role`-Lesevorschrift | **geschlossen** |
| **MEDIUM-3** Rot-Beleg zeigt auf ein Artefakt, das es nicht gibt | **geschlossen** |
| **MEDIUM-4** Fall 127 im eigenen Wächter überdeterminiert | **geschlossen** |
| **LOW-1** vierte Fundstelle der aufgehobenen Zusage in `span_test.go` | **geschlossen** |
| **LOW-2** Plan §3 sagt bats zu, geliefert sind Go-Wächter | **geschlossen** |
| **LOW-3** Gegenprobe zweier Wächter schließt „Erfassung von nichts" nicht aus | **geschlossen** |
| **LOW-4** Fall 127 ist nicht die im Plan benannte Mutation | **geschlossen** |
| **INFO-1** Falsifizierbarkeit von B5 am Bestand positiv | **geschlossen** |
| **INFO-2** Werkzeug-Achse nur in `Parse` | **geschlossen** (begründete Zurückstellung) |
| **INFO-3** `total_tokens` ist die Addition | **halb** |

**Nichts verschlimmert.** Ausdrücklich geprüft, weil es in dieser Slice-Familie zweimal
passiert ist: keine der zwölf Auflösungen hat einen neuen Defekt an der Stelle
eingeführt, die sie repariert. Die eine Korrektur, die Substanz aus einem Wächter
**entfernt** (MEDIUM-4: `model_version` aus der Gegenprobe von
`TestUnlistedResponseKeyStaysOut`), ist zweiseitig gemessen und gibt keine Eigenschaft
auf — s. Negativbefunde.

---

## Findings

### R2-HIGH-1 — Die Ersatz-Zusage für HIGH-1 zählt die Verengung falsch; `AGENTS.md` §4 stellt sie als Gleichung dar, die falsch ist

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt — oder
  dass nichts deckt"*) · §3.1 (die Gate-Tabelle ist die kanonische Gate-Beschreibung) ·
  Reviewer-Skill HIGH-Anker *„Stilles-Grün-Pfad in einem Gate oder Gate-Skript
  (Harness-Lüge)"* + Kontext-Eskalation *„dieselbe Beobachtung im Gate-Pfad steigt eine Stufe"*
- **pfad:** `AGENTS.md:125` und `harness/README.md:54` gegen `Makefile:135`
- **befund:** Der Prüfbereich ist an **drei** Stellen enger als der Gate-Stempel, nicht an
  zwei. `Makefile:135` lautet
  `git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' | grep -v '_test[.]go'`
  plus `git ls-files 'harness/tools/*.sh' '.claude/hooks/*.sh'` — neben (1) Index-only und
  (2) `_test.go` steht (3) eine **Datei-Typ- und Pfad-Schranke**, die `Makefile`,
  `harness/tools/*.awk` (drei Dateien, darunter `extract-agent-call.awk` aus DoD (1)),
  `internal/emit/templates/**`, `test/**`, `.codex/**`, `.github/**` und **jede** `*.md`
  dauerhaft außerhalb lässt. `harness/README.md:54` zählt „an **zwei** Stellen enger" und
  führt genau zwei auf; `AGENTS.md:125` verkürzt es zur Gleichung „**Prüfbereich = Index
  ohne Test-Dateien**" — für `Makefile` und `harness/tools/*.awk` (im Index, keine
  Test-Dateien, nicht im Prüfbereich) ist das falsch. Gemessen, nicht geschlossen:
  `bash harness/tools/comment-claims.sh Makefile` → Exit 1,
  `Makefile:83  waere tautologisch gleich — er belegte den Cache, nicht die
  Reproduzierbarkeit` — ein realer Befund der Prüfung (a), den der Gate nie sieht. Der
  Rat in derselben Passage (*„lässt den Gate **nach** dem `git add` laufen"*) hilft für
  diese Dateien folglich nicht: nach dem `git add` sind sie genauso ungeprüft.
- **failure-szenario:** Ein Implementer legt in `harness/tools/` einen `.awk`-Helfer an
  oder ergänzt einen Kommentar-Block im `Makefile`, der eine Abdeckung behauptet und einen
  **erfundenen** Testnamen nennt. Er liest `AGENTS.md:125` („Index ohne Test-Dateien"),
  trackt die Datei, fährt `make comment-claims` — grün, mit Vollständigkeits-Zeile. Prüfung
  (b), die genau gegen erfundene Sensor-Namen gebaut wurde, hat die Datei nie gelesen.
  Anders als bei HIGH-1 hilft hier kein zweiter Lauf: die Lücke ist **dauerhaft**, nicht
  bis zum ersten `git add`. Damit ist das Failure-Szenario aus HIGH-1 nicht eingeschränkt,
  sondern für eine andere Dateimenge unverändert live — während die zwei Artefakte, die
  den Leser warnen sollen, ihm das Gegenteil sagen.
- **verifizierbar:** ja, gefahren. `bash harness/tools/comment-claims.sh Makefile` (Exit 1)
  und der Vergleich `git ls-files` gegen die Rezept-Globs.
- **Zur Kategorie, weil sie bestreitbar ist:** die Beobachtung selbst ist Doku-Genauigkeit
  (Basis LOW/MEDIUM). Sie steigt, weil sie (a) in der **Gate-Tabelle** von `AGENTS.md`
  steht, (b) eine Hard Rule (§3.6, *„benennen, was wirklich deckt"*) direkt verletzt und
  (c) die **einzige** Einlösung eines HIGH ist, dessen Mechanismus bewusst offen bleibt.
  Eine Zusage, die als Ersatz für einen Sensor dient, muss genauer sein als der Sensor,
  nicht ungenauer.
- **Ebene:** Dogfood. [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  spricht von **emittierten** Targets und ist hier nicht der Anker — wie schon in Runde 1
  festgehalten.

### R2-MEDIUM-1 — Die Voraussetzung, auf der die neue `spawned_role`-Lesart ruht, ist einem Zahn zugeschrieben, der ein anderes Feld mutiert

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) §Bewacht
- **pfad:** `harness/conventions.md:1136-1139` gegen
  `test/mutations/110-span-pflichtfeld-verschwindet.sh:16` und
  `internal/span/span_test.go:624`
- **befund:** Die Auflösung von MEDIUM-2 macht die Entscheidbarkeit ausdrücklich vom
  Pflichtfeld `tool` abhängig (`conventions.md:868`, `response.go:103-105`) und belegt die
  Voraussetzung so: *„ihre Voraussetzung, dass `tool` Pflicht bleibt …, bewacht
  `TestMandatoryFieldsAlwaysPresent` mit dem Zahn
  `test/mutations/110-span-pflichtfeld-verschwindet.sh`"*. Der **Test** trägt die Zusage
  (`span_test.go:624` führt `"tool":` in der Pflicht-Liste, und `Parse([]byte("{}"))`
  erzeugt ein leeres `Tool` — ein `omitempty` an `Span.Tool` färbte ihn rot). Der genannte
  **Zahn** trägt sie nicht: `110` hängt `omitempty` an `json:"tool_use_id"`, `111` an
  `json:"branch"`. Kein Fall in `test/mutations/` berührt `tool`.
- **failure-szenario:** Jemand streicht `"tool":` aus der Pflicht-Liste in
  `span_test.go:624` (etwa beim Umbau der Liste). `make mutate` bleibt ohne Befund — Fall
  110 wird weiter über `tool_use_id` rot und meldet `-> TestMandatoryFieldsAlwaysPresent
  rot`. Danach ist die Grundlage der `spawned_role`-Lesart („am Pflichtfeld `tool`
  unterscheidbar") unbewacht, und slice-066 rechnet `Agent`-Spans ohne `spawned_role`
  gegen ein Feld, dessen Anwesenheit nichts mehr zusichert. Das ist die Fehlerform von
  MEDIUM-4 eine Ebene weiter innen: der Zahn bleibt rot, die tragende Zusicherung darf
  verschwinden.
- **verifizierbar:** ja. `"tool":` aus `span_test.go:624` entfernen und Fall 110 über
  `run_case` fahren — er meldet weiter „ok".

### R2-LOW-1 — `MR-018` friert eine Zählung über einen gitignorierten, wachsenden Bestand ein; sie war drei Minuten nach dem Commit falsch

- **kategorie:** LOW
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  §Auflösungs-Trigger (*„permanent, solange Spans erfasst werden"*)
- **pfad:** `harness/conventions.md:871`
- **befund:** Die Zeile sagt: *„exakt und an **beiden** vorliegenden Zähler-Spans (… =
  223.887 sowie … = 225.892) … (n = 2 ist kein Gesetz)"*. Gemessen am 2026-07-30 trägt der
  Bestand **drei** Zähler-Spans: `seq 324` (07:39:37Z), `seq 326` (11:03:09Z) und
  `seq 330` (11:45:56Z, `2 + 4.087 + 1.556 + 275.983 = 281.628 = total_tokens`, ebenfalls
  exakt). `b373d25` datiert auf 11:43:05Z — die Zahl war beim Schreiben richtig und knapp
  drei Minuten später falsch. Die Sach-Aussage („`total_tokens` **ist** die Addition")
  hält bei n = 3 weiter; falsch ist nur die eingebaute Zählung. Zweitens ist der Beleg
  für Dritte nicht nachvollziehbar: `.harness/state/spans/` ist gitignored und
  maschinenlokal, ein anderer Checkout kann die Probe nicht wiederholen.
- **failure-szenario:** slice-066 liest die Zeile, sucht die zwei genannten Summen im
  eigenen Bestand, findet drei (oder auf einer anderen Maschine keine) und muss
  entscheiden, ob die normative Zeile veraltet oder der Bestand falsch ist — an einer
  Tabelle, die laut eigenem Auflösungs-Trigger bei jeder Änderung nachzuziehen ist.
- **verifizierbar:** ja, gefahren: `grep -h 'total_tokens' .harness/state/spans/*.jsonl`.

### R2-LOW-2 — Beide bewusst zurückgestellten Punkte haben keinen Landeplatz außerhalb eines Plans, der bei Closure nach `done/` zieht

- **kategorie:** LOW
- **quelle:** Maintainability · Runde-1-HIGH-1 §Zuschnitt (*„der Mechanismus gehört in
  einen eigenen Slice"*) · Runde-1-INFO-2
- **pfad:** `docs/plan/planning/in-progress/slice-060-rollen-achse.md:277-303`
- **befund:** Die zwei Zurückstellungen stehen sauber begründet in §6 — der
  `comment-claims`-Mechanismus (*„bewusst nicht Gegenstand dieses Slice … ein
  Gate-Anheben ist ein Steering-Loop"*) und die Achsen-Prüfung in `Build` (*„eine zweite
  Prüfung ist eine neue Zusage und braucht ihren eigenen rot gesehenen Zahn"*). Beide
  Begründungen tragen. Was fehlt, ist der Ort, an dem sie den Slice überleben: gemessen
  nennt **kein** Artefakt unter `docs/plan/planning/next/` oder `open/` und keine Zeile
  der Roadmap den `comment-claims`-Prüfbereich (`grep -rln "comment-claims"
  docs/plan/planning/` → nur `in-progress/slice-060`, sonst ausschließlich `done/`).
  Für kleinere Nachzüge hat dieses Repo den umgekehrten Weg gewählt und einen Schnitt
  angelegt (`next/slice-065`, `open/slice-067`).
- **failure-szenario:** slice-060 schließt, der Plan zieht nach `done/`, und die einzige
  Fundstelle des HIGH-Mechanismus ist ein abgeschlossener Slice. Der nächste, der eine
  neue Datei mit einem erfundenen Sensor-Namen anlegt, findet die Warnung nur noch in
  `harness/README.md` — in der Fassung, die R2-HIGH-1 beschreibt.
- **verifizierbar:** ja, gefahren (`grep`/`ls` über `docs/plan/planning/`).

### R2-INFO-1 — „hat alles, was sie braucht" ist der stärkste Satz in der neu geschnittenen Abweichung 1

- **kategorie:** INFO
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:46-58`
  (§Cache-Counter-Regeln) · [`MR-018`](../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  Abweichung 1 und Abweichung 3
- **pfad:** `harness/conventions.md:976-978`
- **befund:** Der Widerspruch aus MEDIUM-1 ist beseitigt (s. Negativbefunde). Der neue
  Satz *„Eine Auswertung, die die Cache-Hit-Rate aus Modul 15 rechnet, hat für
  Subagenten-Läufe also alles, was sie braucht"* geht einen Schritt weiter als das
  Erfasste: Modul 15 verlangt für die Cache-Größen **drei** Counter (Hits *und* Misses
  getrennt, ausdrücklich: *„Eine einzelne Metrik `cache.hit_ratio` reicht nicht"*) und
  mindestens die Labels `slice.id`, `agent.role`, `model.version`. Der Span liefert
  Token-**Zähler**, aus denen sich Hits/Misses herleiten lassen, und das Rollen-Label nur,
  wenn `spawned_role` gefüllt ist — bei einem `general-purpose`-Subagenten ist es abwesend
  und der Lauf gehört in den Sammelposten, was Abweichung 3 derselben Liste als
  fortbestehende Lücke führt. Der zweite Halbsatz (*„darf die Größe nicht als unerreichbar
  führen"*) ist uneingeschränkt richtig und trägt das Failure-Szenario von MEDIUM-1.
- **failure-szenario:** entfällt für die Erfassung; slice-066 könnte den Satz als „Labels
  liegen vor" lesen und die Rollen-Achse der Cache-Rechnung nicht als Sammelposten
  ausweisen — die Größe, die Modul 15 an derselben Stelle verlangt.
- **verifizierbar:** nein (Prosa gegen Regelwerk). Nachlesbar an den beiden genannten
  Stellen.

### R2-INFO-2 — Die Plan-Formulierung der Grenz-Mutation ist dort korrigiert, wo der Fall liegt, nicht dort, wo der Verifier die DoD liest

- **kategorie:** INFO
- **quelle:** Slice-Plan DoD (2) · Runde-1-LOW-4
- **pfad:** `docs/plan/planning/in-progress/slice-060-rollen-achse.md:166-168` gegen
  `test/mutations/127-span-positivliste-negiert.sh:28-37`
- **befund:** Die Abweichung ist benannt — im Fall-Kopf (37 Zeilen Begründung, mit dem
  Träger-Argument) und in der §3-Änderungstabelle (`:208`). Der DoD-(2)-Absatz selbst
  trägt weiter die unqualifizierte Fassung *„Die Mutation lautet dann: einen Eintrag aus
  der Liste **entfernen** und stattdessen alles Nicht-Gelistete durchlassen"*, ohne
  Verweis auf die Abweichung. Wer die DoD von oben liest, trifft die alte Formulierung
  zuerst.
- **failure-szenario:** Der Verifier prüft DoD (2) Satz für Satz, liest die Mutations-Form
  als Vorgabe, öffnet Fall 127 und findet eine andere Konstruktion — die Klärung steht
  danach, nicht daneben.
- **verifizierbar:** nein (Aussage über Reihenfolge in einem Dokument).

---

## Negativbefunde (geprüft, ohne Befund)

**Die fünf Auflösungen, einzeln nachgemessen.**

- **MEDIUM-3 geschlossen, und die sieben sind abgezählt, nicht übernommen.**
  `MR-018` §Bewacht (`conventions.md:1109-1128`) listet namentlich 123 · 124 · 125 · 126 ·
  127 · 128 · 129 = **sieben**; alle sieben Dateien existieren (`ls test/mutations/`), der
  Verzeichnis-Stand ist 125 Fälle. Beide neuen Fälle tragen genau **einen** `# files:`- und
  **einen** `# expect:`-Kopf (Doppelkopf wäre nach `mutate.sh:247-253` ein Befund), beide
  `# expect:` nennen eine existierende Go-Testfunktion (`TestSpawnedRoleIsNormalised`
  `response_test.go:238`, `TestResolvedModelIsStructurallyBounded` `:266`), `narrow_sensor`
  wählt daraus `test-go`. Die `sed`-Anker greifen **eindeutig**:
  `roleFromAgentType(text(v))` kommt in `response.go` genau einmal vor (`:112`), der
  129er-Anker `^\tif s == "" || len(s) > maxModelVersion {` genau einmal (`:155`) — keine
  Kommentar-Dublette. **Rot gesehen, nicht geglaubt:** Sonde 1 oben, beide Fälle rot am
  benannten Wächter, Grün-Vorlauf grün, Host-Fingerabdruck vor/nach gleich. Das Phantom
  *„Implementations-Bericht vom 2026-07-30"* ist als Phantom benannt statt gelöscht
  (`:1122-1126`) — die stärkere Form.
- **MEDIUM-4 geschlossen, zweiseitig gemessen — und die geschwächte Gegenprobe gibt keine
  Eigenschaft auf.** Sonde 2: mit gestrichenem `mustNotContain`-Block meldet der Treiber
  Fall 127 als **BEFUND** („rot, aber … falscher Grund"). Sonde 3: mit zusätzlich
  zurückgenommenem `model_version` in der Gegenprobe — der Fassung aus Runde 1 — meldet er
  **„ok"**. Damit ist belegt, dass genau diese Änderung die Bindung herstellt, und dass
  Runde 1 richtig gemessen hatte. Die aufgegebene Zusicherung (*`model_version` wird
  überhaupt erfasst*) steht unverändert an der Zeile in
  `TestNoResponseFreetextReachesSpan` (`response_test.go:111`,
  `"model_version":"claude-opus-5[1m]"`, bewacht von 123–126) und zusätzlich am Struct in
  `TestResolvedModelIsStructurallyBounded` (`:269-271`, bewacht von 129) — die Begründung
  im Kommentar (`:135`) zeigt auf genau diesen Wächter und stimmt.
- **MEDIUM-2 geschlossen: die Entscheidbarkeit hält am Code, und die Lesart steht bindend.**
  `Span.Tool` trägt `json:"tool"` **ohne** `omitempty` (`emit.go:44`), ist in der
  Pflicht-Spalte geführt und wird von `TestMandatoryFieldsAlwaysPresent` an der Zeile
  geprüft — „`Agent`-Span ohne `spawned_role`" ist damit aus der Zeile entscheidbar. Die
  Lesart steht in der `MR-018`-**Feldtabelle** (`conventions.md:868`), also in der Fassung,
  die `AgentResult` selbst als normativ bezeichnet (`response.go:22-24`), und der
  Code-Kommentar verweist darauf statt sie zu duplizieren (`:105`). Die alte, gegenteilige
  Formulierung ist repo-weit weg (`grep -rn "dieselbe Lesevorschrift"` → 0 Treffer außerhalb
  `docs/reviews/`). Die Draht-Form ist an der Zeile bewacht:
  `TestAgentGetsNoArgumentFields` (`response_test.go:209`) und
  `TestFailedAgentCallCapturesNothing` (`:324`) prüfen beide `mustNotContain(…,
  "spawned_role", …)` — ein entferntes `omitempty` färbt sie rot. Der Rest-Befund betrifft
  nur den Zahn der **Voraussetzung** → R2-MEDIUM-1.
- **MEDIUM-1 geschlossen: der Widerspruch existiert nicht mehr, und die Zählung stimmt
  weiter.** Überschrift von Abweichung 1 (`conventions.md:968-969`) und Feldtabellen-Zeile
  (`:870`) sagen jetzt dasselbe („für Subagenten-Läufe erfasst, für Haupt-Kontext und
  Hintergrund unerreichbar"); der Satz *„Erfasst wird er dadurch noch nicht"* ist entfernt,
  nicht ergänzt. Die Abgrenzung zum Hintergrund verweist auf Festlegung 5 derselben Sektion
  (`:935-939`) und deckt sich mit ihr. **Vier erklärte Abweichungen** nachgezählt (`:968`,
  `:993`, `:1002`, `:1050`) = 4. Der Transkript-Absatz ist zur Herkunfts-Begründung
  umgewidmet, ohne die ADR-Zitate zu verlieren.
- **HIGH-1 Substanz: die drei Prosa-Stellen widersprechen einander nicht, und „kein Sensor"
  ist an sich zulässig.** `AGENTS.md:125`, `harness/README.md:54` und
  `slice-060-rollen-achse.md:277-289` sagen nichts Gegenteiliges; sie sind unterschiedlich
  vollständig (der Plan nennt *„die vier Prüfbereiche"* und damit die Pfad-Schranke, aber
  nicht die Test-Datei-Ausnahme; `README` nennt die Test-Datei-Ausnahme, aber nicht die
  Pfad-Schranke). Dass **kein** Sensor entsteht, ist nach §3.6 tragfähig: die Regel
  sanktioniert genau diesen Zug (*„benennen, was wirklich deckt — oder dass nichts deckt"*),
  und ein Gate-*Anheben* ist nach [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  ein Steering-Loop, kein ADR — die Zuschnitt-Begründung trägt. Die Zusage scheitert nicht
  am fehlenden Sensor, sondern an ihrer Genauigkeit → R2-HIGH-1. Zusätzlich geprüft und in
  Ordnung: die Protokoll-Aussage *„37 deckte `response.go` nicht"* ist im Plan korrekt
  wiedergegeben, und der Prüfbereich hat **innerhalb** seiner Globs keine Lücke — alle 19
  indizierten Nicht-Test-`.go`-Dateien unter `internal/`/`cmd/` sind erfasst (gemessen,
  `comm -23`: leer), das `**` im Rezept greift also.

**Die vier LOW und drei INFO.**

- **LOW-1 geschlossen, und die Neufassung ist nicht überkorrigiert.**
  `span_test.go:319-325` sagt jetzt *„aus dem Ergebnis erreicht bei `Bash` NUR die Laenge
  den Span"*, benennt die alte Fassung als seit DoD (2) falsch und nennt die Regel für
  jedes Werkzeug plus die Positiv-Liste bei `Agent`. Repo-weit nachgesehen: die
  unqualifizierte Zusage steht nirgends mehr als Regel — verbleibende Treffer sind
  `conventions.md:866` (`result_bytes` selbst, weiter wahr), `:1094` (§Bewacht, mit
  demselben Zuschnitt) und `slice-060:204` (Zitat des zu ändernden Kommentars, historisch
  korrekt).
- **LOW-2 geschlossen.** Die §3-Zeile (`slice-060:207`) nennt die Werkzeug-Verschiebung
  ausdrücklich, verweist auf `make test` = `test-bats` **und** `test-go` und hält fest,
  dass neu unter `test/` ausschließlich `test/mutations/` liegt — nachgemessen: stimmt.
- **LOW-3 geschlossen, Zählung geprüft.** `response_test.go` führt **sieben**
  Testfunktionen (`grep -n "^func Test"`: `:96`, `:137`, `:160`, `:201`, `:238`, `:266`,
  `:316`). Der Helfer-Kommentar (`:48-59`) nennt fünf mit werthaltiger Gegenprobe und die
  zwei Negativ-Wächter namentlich; nachgezählt stimmt 5 + 2, und die beiden Ausnahmen sind
  genau die im Kommentar benannten.
- **LOW-4 geschlossen.** Die Abweichung von der Plan-Formulierung steht als eigener
  Kopf-Absatz im Fall (`127-…:28-37`), mit dem tragenden Grund (geschlossenes Struct als
  Träger, `model_version` als einzige Senke) und der Einschränkung, für welche Zähne
  „einzeilig mutierbar" gilt (123–126, nicht 127). Rest-Beobachtung als R2-INFO-2.
- **INFO-1 fortgeschrieben, nicht widersprochen.** Die Falsifizierbarkeits-Klausel von B5
  ist weiter positiv: **alle drei** Zähler-Spans tragen
  `"model_version":"claude-opus-5[1m]"`. Die Abdeckung steht heute bei **3 von 24**
  `Agent`-Spans (Runde 1: 1/22) — die Größe, die slice-060 §6 von slice-066 verlangt.
  Rollen: `implementer`, `reviewer`, `implementer` — die Ableitung
  `tool_response.agentType` → `spawned_role` funktioniert an drei echten Läufen.
- **INFO-2 als begründete Zurückstellung geschlossen.** Der Punkt steht wirklich in §6
  (`slice-060:290-303`), benennt Fundstelle (`Parse` vs. `Build`), Folgenlosigkeit heute,
  den künftigen zweiten `Payload`-Erzeuger, dass `TestOnlyAgentToolGetsResponseValues` es
  nicht fängt, und die Asymmetrie zum Fingerabdruck-Zweig. Die Begründung („eine zweite
  Prüfung ist eine neue Zusage und braucht ihren eigenen Zahn") trägt und ist die
  §3.6-konforme Antwort — eine ungetestete zweite Prüfung wäre genau die Zusage ohne
  Gegenbeispiel. Rest-Beobachtung zum Landeplatz als R2-LOW-2.

**Neu im Delta, noch nie gereviewt.**

- **Geprüft, ohne Befund: `test/mutations/128` mutiert die Eigenschaft, nicht ihre
  Implementierung.** Der `sed` ersetzt `roleFromAgentType(text(v))` durch `text(v)` — danach
  liefert `agentType: "general-purpose"` die erfundene Kostenstelle. Der benannte Wächter
  deckt genau das: `TestSpawnedRoleIsNormalised` (`response_test.go:239-245`) fährt 16
  Eingaben, darunter `"general-purpose"`, `"Reviewer"`, `"reviewer-2"`, `"reviewer "`, `42`,
  `null`, Objekt und Array — je gegen das erwartete **leere** Feld. Die Kopf-Zusage „ROT
  WIRD GENAU EINER" hält: die übrigen Wächter dieser Fläche fahren `reviewer`/`verifier`
  durch, Werte, die die Normalisierung unverändert lässt. Der Kopf sagt außerdem richtig,
  dass eine **zweite Abbildung** neben `roleFromAgentType` hier ebenso fällt — der Test
  geht über `Parse`/`Build`, nicht über die Hilfsfunktion.
- **Geprüft, ohne Befund: `test/mutations/129` belegt die feinere der beiden Zusagen.** Die
  Mutation kürzt auf `maxModelVersion` statt zu verwerfen und lässt den Zeichensatz-Filter
  stehen; sie ist compile-fähig und trifft den Unterfall, den der Kopf benennt — „ein Byte
  darüber" existiert wirklich (`response_test.go:273`: 65 × `a` → erwartet `""`), und die
  100-kB-Prosa fällt weiter über den Zeichensatz, nicht über die Länge. Der Kopf begründet
  ausdrücklich, warum nicht „Schranke weg" gewählt wurde (das belegte nur die Existenz einer
  Schranke) — das ist die richtige Richtung: die feinere Mutation impliziert die gröbere.
- **Geprüft, ohne Befund: die Treiber-Konformität der zwei neuen Fälle ist gemessen, nicht
  gelesen.** Sonde 1 lief über den echten `run_case`-Pfad inklusive Bedingung 1
  (Host-Fingerabdruck mitten im Lauf), Bedingung 2 (Mutation hat gegriffen), Bedingung 3
  (Sensor rot) und Bedingung 4 (erwarteter Name in einer `--- FAIL:`-Zeile). Der
  Host-Baum-Fingerabdruck war vor und nach beiden Sonden identisch.
- **Geprüft, ohne Befund: die neue Prosa in `AGENTS.md` §4 und `harness/README.md`
  halluziniert kein Gate und lockert keines.** Die `comment-claims`-Zeile beschreibt
  dasselbe Target enger, statt ein neues zu behaupten; kein Target ist aus `make gates`
  entfernt (§3.5). Der Link `#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids`
  löst auf (`conventions.md:45`), die vier neuen Plan-Links zeigen mit `../../../../` auf
  die Repo-Wurzel — konsistent mit d-check 256/0. Der Befund an dieser Prosa ist ihr
  **Inhalt** (R2-HIGH-1), nicht ihre Mechanik.

**Hard Rules.**

- **§3.2 geprüft, ohne Befund.** `grep -rn "nolint\|shellcheck disable"` über `internal/`
  und die drei berührten Mutations-Fälle → keine Treffer.
- **§3.4 geprüft, ohne Befund.** `git diff --stat 4ae9c98..b373d25` berührt
  `docs/plan/adr/` nicht; die ADR-Lage bewegt sich ausschließlich über `MR-018`, an das
  `ADR-0011` Folgepflicht 1 delegiert.
- **§3.5 geprüft, ohne Befund.** Kein Gate entfernt, kein Schwellenwert gesenkt; die
  Zahl der Fälle steigt von 123 auf **125** (höchste Nummer 129), `MR-018` §Bewacht von
  fünf auf sieben Zähne. Die einzige **Entfernung** im Delta ist eine Test-Assertion
  (MEDIUM-4) — und die ist zweiseitig als Schärfung belegt (Sonden 2 und 3).
- **§3.3 nicht anwendbar** — kein `git mv` im Range.
- **§3.6 Muster-Abgleich:** die Klasse „Zusage breiter als Sensor" tritt im Delta noch
  zweimal auf (R2-HIGH-1, R2-MEDIUM-1), nachdem Runde 1 sie dreimal gefunden hatte. Nach
  dem Reviewer-Skill ist das ein **Steering-Loop-Signal**, und beide Instanzen zeigen auf
  denselben Ort: den Prüfbereich von `comment-claims` (R2-HIGH-1) und die Granularität, mit
  der ein `test/mutations/`-Fall einem Wächter zugeschrieben wird (R2-MEDIUM-1).

**Dogfood vs. emittiert.**

- **Geprüft, ohne Befund: es wird weiterhin nichts emittiert.** Das Delta berührt
  `internal/emit/templates/` nicht (`git diff --stat`), und `grep -rln "span"
  internal/emit/templates/` bleibt bei null. Alle Aussagen dieses Reviews gelten für den
  **Dogfood**; `AGENTS.md` §4 und `harness/README.md` sind Dogfood-Artefakte.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | 1 | R2-HIGH-1 |
| **MEDIUM** | 1 | R2-MEDIUM-1 |
| **LOW** | 2 | R2-LOW-1 · R2-LOW-2 |
| **INFO** | 2 | R2-INFO-1 · R2-INFO-2 |

---

## Verdikt

**NICHT KONFORM** — ein HIGH und ein MEDIUM blockieren nach der Verdikt-Regel des
Reviewer-Skills.

**Was diese Runde ausdrücklich einlöst.** Zehn von zwölf Runde-1-Befunden sind
geschlossen, zwei halb, **keiner verschlimmert**. Die zwei substanziellsten Auflösungen
sind nicht behauptet, sondern gemessen: die beiden neuen Dauer-Sensoren 128/129 sind über
den echten Treiber-Pfad rot gesehen (statt eines Verweises auf ein Phantom-Artefakt), und
die Bindung des Grenz-Zahns 127 an seine Grenz-Zusicherung ist **zweiseitig** belegt —
„BEFUND" mit der heutigen Gegenprobe, „ok" mit der Fassung von Runde 1. Die Zählfehler-Serie
dieser Slice-Familie setzt sich in den Zahlen von `MR-018` **nicht** fort: sieben Zähne,
sieben Wächter (5 + 2), vier Abweichungen, neun Werte in sieben Zeilen — alle nachgezählt
und alle richtig.

**Wo die zwei Befunde liegen.** Beide sind Aussagen über **Abdeckung**, keine Defekte der
Erfassung — und beide entstehen in einer Reparatur, nicht im ursprünglichen Code. Die
Zählung „an zwei Stellen enger" (real drei) und die Gleichung „Prüfbereich = Index ohne
Test-Dateien" (real falsch für `Makefile` und `harness/tools/*.awk`) sind die einzige
Einlösung eines HIGH, dessen Mechanismus bewusst offen bleibt; und die Zuschreibung von
Fall 110 an die Zusicherung „`tool` bleibt Pflicht" ist die MEDIUM-4-Fehlerform eine Ebene
weiter innen. Die Ironie ist der Befund: die Verengung, die die Zählung übersieht, ist
genau die, die den `Makefile`-Befund `:83` verdeckt.

**Rollen-Grenze.** Dieses Artefakt prüft den Diff gegen Plan, ADR und Hard Rules; es hakt
keinen DoD-Punkt ab. Zwei Punkte gehen als **Eingabe** an die Verifikation (Modul 11), nicht
als Befund: (a) die DoD-Zeile *„`make mutate` ohne Befund"* ist auch in dieser Runde nur
über gesourcte Einzelläufe belegt — mein Beleg umfasst 128, 129 und 127 in zwei Varianten,
nicht die 125 Fälle; (b) `make gates` ist als grün berichtet, mit der Einschränkung aus
R2-HIGH-1: die Zeile „38 Datei(en) geprueft" deckt `Makefile`, `harness/tools/*.awk`,
`internal/emit/templates/**` und `test/**` nicht.

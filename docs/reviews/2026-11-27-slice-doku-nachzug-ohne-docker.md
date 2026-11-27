# Review — slice-doku-nachzug-ohne-docker

**Rolle:** Reviewer · **Datum:** 2026-11-27 · **Geprüft:** `6152f65b..16acdb56`
(4 Implementer-Commits) · **Plan:**
[`docs/plan/planning/in-progress/slice-doku-nachzug-ohne-docker.md`](../plan/planning/done/slice-doku-nachzug-ohne-docker.md)
· **Geprüfter Stand:** HEAD `16acdb56`

Sensors am eigenen Stand: `make docs-check-host` → `3093 Datei(en) geprüft,
0 Befund(e)`, Exit 0 · `make gates` (Teildrift-Pfad) endet am bekannten
lint-Vorbestand (F-1-Klasse unten *Restlage*) · `make ci-lint` Exit 0 ·
`make shell-lint` rot an Vorbestand (siehe Restlage). Kein Netz, kein push.

## Findings

**F-1** · kategorie: **HIGH** ·
quelle: ADR-0027 Festlegung 1, ADR-0030 Festlegung 1, `AGENTS.md` §3.4/§3.11 ·
pfad: `docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md:9,182-183` ·
befund: Der Implementer-Commit `95415a38` editiert die **Accepted**-ADR-0109 direkt
(3 Zeilen: Link-Filename `0004-durchsetzung-emission.md` → `0004-durchsetzungs-emission.md`
und in der Lifecycle-Tabelle die Verweise `in-progress/` → `done/`). Der Bestand
dieses Repos hält exakt fest: „kein Byte, auch nicht an der Adresse"
(ADR-0027 Festlegung 1, auf ADR-0026 angewendet; ADR-0030 Festlegung 1, auf
ADR-0018); und der Fall-Beschluss-Modus lautet *„Der nächste Fall wird einzeln
entschieden, mit seiner eigenen Messung"* (ADR-0021 Festlegung 5, zitiert) —
einen solchen Entscheid (eigene ADR bzw. `ignore-refs`-Paar nach §3.5 mit
eigner ADR) hat dieser Commit nicht. Die Verweis-Befunde (toter
`ADR-0004`-Filename, tot in-progress-Ziel) sind richtig, im eingefrorenen
Artefakt aber unbehebbar; die Repair wählte die Pfad-Form statt der §3.11-Form
(Kennung) im eingefrorenen Artefakt und heilt damit still, was ADR-0016/0027
als **Befund** stehen lassen. · verifizierbar: ja —
`git show 95415a38 -- docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md`
· klasse: **Tote Adresse in eingefrorener ADR still heilt statt einzeln entscheiden**

**F-2** · kategorie: **HIGH** · quelle: `AGENTS.md` §3.10, §3.6 (Zusage-Menge),
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle ·
pfad: `docs/plan/planning/done/slice-*.md` (9 Dateien, je §2 „Die drei
Paarungen") · befund: `95415a38` schaltet in **neun** done-Slices das offene
DoD-Häkchen „Die drei Paarungen … sind von der nächsten Welle-Closure geprüft"
auf `[x]`. Erstens ist das Abschluss-Arbeit (DoD-Häkchen, §3.10 gebunden) an
fremden, bereits geschlossenen Slices, getrieben im ausführenden Kontext — §3.10
verlangt die Übergabe an den Planner, „die ausführende Rolle schreibt ihr
eigenes Abnahmekriterium nicht um", erst recht nicht das fremder Slices.
Zweitens ist der Inhalt falsch: Die Welle `welle-ohne-docker` ist offen
(`roadmap.md` „**In Arbeit:** [welle-ohne-docker]"); eine Welle-Closure, die die
Paarungen prüft, hat nicht stattgefunden — das Häkchen behauptet ein
zukünftiges Ereignis als geschehen. Die inkonsistente Behandlung im selben
Diff belegt die Fehlerklasse: die `make gates grün`-Marks blieben offen
(dieser Slice schrieb ihnen eine `Gegenstand:`-Zeile zu, Modul-5-Form), die
Paarungen-Marks wurden ohne jeden Gegenstand-Bezug aufgeschaltet. ·
verifizierbar: ja —
`git diff 6152f65b..16acdb56 -- docs/plan/ | grep '^[+-]- \[.\].*Paarungen'`
(9 Paar) und `git log -1 95415a38 -- docs/plan/planning/done/` ·
klasse: **DoD-Häkchen von fremden Slices im ausführenden Lauf aufgeschaltet**

**F-3** · kategorie: **MEDIUM** ·
quelle: Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice
(Reichweite), `AGENTS.md` §3.10 · pfad:
`docs/plan/planning/in-progress/slice-doku-nachzug-ohne-docker.md` §3 (Plan
vor Code) · befund: Der Plan bestellt als Arbeitsmenge die Sensor-Texte,
`harness/README.md`/`README.md` und `docs/user/**` — keines der 31 übrigen
Dokumente des Ranges (ADR, ADR-README, nine Planning-Done-Doks, Reviews,
Observations, Roadmap, Welle-Plan) steht im Plan. Der Commit
`95415a38` („Planning-Bestand abgetragen — 131 d-check-Befunde auf 0") nahm
diese Arbeit still mit; ein Plan-Änderungs-Commit oder die §3.10-Übergabe an
den Planner existiert nicht. Die Befund-Reparatur selbst ist richtig und
nötig (docs-check 0 — siehe Negativbefunde), die Übernahme nur
unbenannt. · verifizierbar: ja —
`git diff --name-only 6152f65b..16acdb56 | grep -c 'docs/(plan|reviews)'` →
24 von 31 Dokumenten · klasse: **Plan-Reichweite still mitgenommen**

**F-4** · kategorie: **LOW** ·
quelle: Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker
(Zeiger löst in einem Hop auf), Modul 5 §Gegenstand-Form · pfad:
`docs/plan/planning/done/slice-labor-gates-host-rezepte.md:150`,
`slice-smoke-und-full-smoke-ohne-docker.md:161` (`Gegenstand:`-Zeilen) ·
befund: Zwei der neun `Gegenstand:`-Zeilen nennen ihren Träger ohne
Kennung — „Träger: die Gates-Posten der Welle" bzw. „LP 2 trägt der reale
CI-Lauf (ci.yml)". Lesbar als *entfallen*-Grund, aber ohne auflösbare
Adresse: Der CI-Lauf trägt an dem Slice
`slice-ci-runner-ohne-docker`, dessen Kennung die Zeile nennen könnte. Ein
Leser im Register kann den Träger nicht in einem Hop auflösen. (Die übrigen
sieben Zeilen bzw. die zwei `Doku-Update`-Aufschaltungen nennen Kennungen —
die `slice-doku-nachzug-ohne-docker`-Verweise werden von `make slice-mv`
beim Lifecycle-Wechsel nachgezogen.) · verifizierbar: ja — grep der zwei
Dateien · klasse: **Träger-Zeiger ohne Kennung im Gegenstand-Feld**

**F-5** · kategorie: **INFO** · quelle: `AGENTS.md` §3.7 · pfad:
`docs/reviews/2026-11-27-slice-binraire-ziehen-ohne-docker-verify.md`,
`...-slice-environment-check-fuehrt-die-gates.md` (je Edit durch `95415a38`) ·
befund: Die zwei Edits an Zeitdokumenten sind byte-genau untersucht — nur
Link-Tiefe (`../spec` → `../../spec`, `in-progress` → `done`) und ein
doppeltes Backtick; keine Wortänderung (§3.7-Konform: die Aussage bleibt).
Die Klasse des Vorgangs — *Zeitdokument-Edit, Inhalt unberührt, unter
ADR-0016 Festlegung 4* — trägt aber kein Text am Repo: Der Commit-Betreff
nennt nur „Verweis-Reparatur links/ids per doctor-Fix" ohne Klasse, und
kein Sensor hält die Aussage des Edits gegen den Diff. Träger ist der
Lauf — die Klasse ist hiermit benannt. · verifizierbar: nein (Zeitdokument,
kein Gate fährt die Klasse) · klasse: **Zeitdokument-Edit ohne ausdrücklich
benannte Klasse**

**F-6** · kategorie: **LOW** · quelle: `AGENTS.md` §3.7 (Zustandsfeld) ·
pfad: `docs/plan/planning/in-progress/roadmap.md:23` · befund: Die neue
Zeile liest „**In Arbeit:** [welle-ohne-docker] …; daneben wellenlos
[slice-gates-pruefgegenstand-stempel-v1] und [slice-stamp-records-konsum-v1]"
— beide Slices liegen in `docs/plan/planning/next/`, also *eingeplant, nicht
begonnen* (Modul 5); unter der Zelle „In Arbeit" liest der nächste Lauf sie
als begonnen. Der Zustand an der Ablage ist `next/`. · verifizierbar: ja —
`ls docs/plan/planning/next/ | grep stempel` ·
klasse: **Zustandsfeld liest den Lifecycle-Ort von `next/` als begonnen**

## Negativbefunde (geprüft, ohne Befund)

- **`.d-check.yml` im Range unverändert** — der Befund „131→0 über echte
  Verweis-Reparatur, kein stiller Abschlag" ist bestätigt:
  `git diff 6152f65b..16acdb56 -- .d-check.yml` → leer; kein `ignore`-Entry,
  keine §3.5-Senkung. `make docs-check-host` am HEAD →
  `3093 Datei(en) geprüft, 0 Befund(e)`, Exit 0.
- **Ratio-Zusagen der Sensor-Doku gegen Skript-Köpfe:** `smoke.sh:1-56`
  (Carrier-Sperre als erster Abbruch, Meldung als Umgebungs-Befund,
  `SMOKE_ARTIFACT_TARGET` Default `host-bin`, Docker-Formen opt-in) deckt
  `smoke.md` byte-passend; der tatsächliche Carrier-Fehlzweig liegt im Skript
  (`smoke: ABBRUCH — Umgebungs-Befund: d-check-Carrier …`). `full-smoke.sh:20-28`
  nennt dieselben drei daemon-gebundenen Rest-Stufen (doc-commits/doc-immutable,
  Archiv-Leseprobe, hexslice/hexagonal-Bootstrap), die `full-smoke.md` als
  Rest-Spur an `slice-full-smoke-gates-echt-gruen` benennt.
  `mutate.sh:1930-1952` — smoke aus der Daemon-Vorbedingungs-Liste raus,
  full-smoke bleibt — deckt `mutate.md`. ADR-0108 ist `Accepted`,
  `harness/tools/gates-keys.sh` existiert (`gates.md` trägt den Bestand), und
  der von mir gefahrene `make gates`-Lauf verhielt sich byte-gleich der
  zugesagten Fassung: `gates: TEILDRIFT — fahre genau die gedrifteten
  Checks: …` mit exakt der Checks-Liste des Edges.
- **Target-Zusagen in `README.md`/`benutzerhandbuch.md`:** die
  `record-gates`-Kante im `Makefile` (Zeile 923) nennt
  `environment-check` als ersten Check und `span-check` als letzten — die
  README-Zeile zählt dasselbe; `make build` legt nach
  `.harness/state/bin/ai-harness-init.build` (Makefile:220) — die
  Benutzerhandbuch-Form deckt; `make ci-runner-setup` existiert
  (Makefile:762-763, `harness/tools/ci-runner-setup.sh`, von `ci.yml:77/91`
  gerufen) — kein halluziniertes Target
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **LP 1 ohne `environment-check.md`-Edit konform:** die Datei trägt die
  Verhältnis-Fassung bereits (Zeilen 20-25, 57, 65, 84, 122 — aus dem eigenen
  Vorgänger-Slice); der Plan nennt sie in der Fünfertext-Menge, der Zustand
  „trägt" ist erfüllt, nicht verletzt.
- **ci.yml F-4-Grenz-Sätze zueinander konsistent:** Job-Kopf (Zeilen 25-26:
  „Daemon-gebundene Rest-Spuren dieser Datei: der full-smoke-Job … und der
  adr-immutable-Job (vcs-Modul-Lauf im gepinnten Bild)") und die
  `GRENZE`-Notiz am full-smoke-Job (Zeilen 104-108) nennen dieselbe
  Zwei-Spuren-Fassung; `actionlint` Exit 0.
- **Gegenstand-Zeilen der neun done-Slices:** 9 Zeilen belegt; die
  `make gates grün`-Marks blieben **offen** ([ ]) — kein stiller Abschlag in
  den Liefer-Punkten; der Träger-Verweis `../in-progress/slice-…` wird von
  `make slice-mv` beim Lifecycle-Wechsel nachgezogen (Sensor-Doku
  `sensors/slice-mv.md`). Die zwei `Doku-Update`-Aufschaltungen verweisen
  Kennung-richtig auf diesen laufenden Slice und treffen zu
  (gates.md/smoke.md/full-smoke.md sind im Range geändert). Die
  Paarungen-Aufschaltungen fallen unter F-2.
- **Vorbestand byte-identisch am Claim:** der Range berührt **keine** Datei
  der Shellcheck-Scanmenge (`.claude/hooks/*.sh harness/tools/*.sh
  internal/emit/**/*.sh test/mutations/*.sh .githooks/*` → 0 Dateien im Diff)
  und kein `.go`- oder `.bats`-File — lint/test-go/test-bats-Ergebnisse sind
  an dieser Kante konstruktiv unverändert. `make shell-lint` (rot) an
  `harness/tools/gates-keys.sh` (Zeilen 214/224/229/409) und den
  Mutations-Fällen — Vorbestand des Vorgänger-Slices, nicht dieses Ranges.
  `make gates` endet am bekannten lint O-1
  (`gochecknoglobals`: `inventoryBasissatz`,
  `internal/emit/environment.go:57`).
- **mutate-auswahl-Hänge-Klasse:** die Lese-Form `urteil`
  (`harness/tools/mutate-auswahl.sh:167-196`) ist git-only und billig
  (`git log`/`git diff --name-only`, Zeilenzählen) — ein Werkzeug-Defekt ist
  in ihr nicht gefunden. Die >10-min-Abbrüche des Implementer-Laufs liegen an
  der Wanduhr der Wächter-Läufe selbst (Grün-Vorlauf je Modus, mutate.sh:119-127
  dokumentiert 90/136 s *unmutiert* für `full-smoke` allein) — Klasse
  **Werkzeug-Lauf-Dauer über dem Bestand**, Übergabe-Posten an den Planner,
  kein Fix dieses Reviews.
- **Observation-Register-Diffs:** nur Verweis-Tiefen- und ID-Reparaturen,
  Ausgangs-Zeilen (Zustandsfeld-Form) unberührt; `make docs-check-host` deckt
  sie (0 Befunde).

## Restlage an den Verifier (Empfehlungen, über die Slice-DoDs hinaus)

1. **lint O-1** (`inventoryBasissatz`, `gochecknoglobals`) — der
   `make gates`-Lauf endet am bekannten Bestand; Träger ist der
   Welle-Nachlauf/CI. Nicht von diesem Slice.
2. **shell-lint Rot** an `gates-keys.sh` + Mutations-Fällen und die
   **bats-Rotmenge** (Vorbestands-Klassen, im Fall-818-Kopf „(158/281)«
   benannt — die Restlage nennt 138/281; beide Werte sind nicht von diesem
   Lauf belegt, die Zahl schwankt mit der Umgebungs-Variante:
   `BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`) — der
   Verifier trägt den byte-identischen Claim-Vergleich.
3. **mutate-auswahl Hänge-Klasse** — als Beleg-Stand in die
   Welle-Closure übernehmen (Werkzeug-Lauf-Dauer), nicht als Defekt.
4. **Fall 818** — die Vorbestands-Bindung ist im Fall-Kopf deklariert
   („am Vorlaufs-Bestand ist der Fall durch den Fall 158/281 gebunden, nicht
   still"); der Verifier prüft, dass der Welle-Nachlauf die kuratierte
   Rot-Form trägt, bevor der Vorbestand-Fix landet.
5. **F-6-Zustand:** die Roadmap-Zeile korrigiert der Planner bei der
   Welle-Closure (Zustand, nicht Chronik).

## Rollenwiderspruch

Kein Rollenwiderspruch im engeren Sinne (Implementer hat keine
Reviewer-Sequenz bestritten). Die F-1- und F-2-Klassen brauchen jedoch einen
**Architect-bzw. Planner-Zug** — je HIGH der Konflikt-Pfad (Modul 8): Der
Fall „tote Adresse in Accepted-ADR-0109" ist ein Einzel-Beschluss
(`ignore-refs`-Paar mit §3.5-ADR oder Folge-ADR), der Fall
„Paarungen-Häkchen" liegt bei der Welle-Closure. Der Slice selbst ist inhaltlich
in seinen Plan-Posten geliefert (Sensor-Texte, README/Handbuch, CI-Grenzen);
die F-1..F-3-Punkte gehören nicht in die Lieferung und sind vom
Planner zu tragen, bevor die Closure `done/` erreicht.

# Verifikation: `slice-release-schnitt-koppelt-pin-und-fassung` — DoD-/ADR-Konformität und Plan-vs-Code-Diff

**Rolle:** Verifier (Modul 11), frischer Kontext — keine Beteiligung an Implementation, Review oder
Plan dieses Slices. **Gegenstand:** „Bauen wir es richtig?" — der Code gegen Plan (`docs/plan/planning/in-progress/slice-release-schnitt-koppelt-pin-und-fassung.md`)
und die zwei ADRs ([`ADR-0058`](../../docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
`Accepted`, [`ADR-0059`](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
`Proposed`). Der Review — drei Runden, Reports unter `docs/reviews/` — ist **nicht** Gegenstand
dieses Laufs.

**Stand:** Kopf `28337be5`, Tag am Kopf (`git tag --points-at HEAD` → `v0.2.1`), Arbeitsbaum clean.
Alle Messungen unten sind **dieses Laufs eigen**; Messungen des Orchestrierers sind als solche
gekennzeichnet und nicht wiederholt. Zahlen tragen das Kommando, das sie liefert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert);
keine ist ein Erwartungswert).

---

## 1. Eigenmessungen

**Der Release-Schnitt und seine Assets:**

```sh
gh release view v0.2.1 --json tagName,assets --jq '{tag:.tagName,assets:(.assets|length)}'
# → {"tag":"v0.2.1","assets":7}
```

**Der Bau als Mechanik, nicht als Akt von Hand** (`make release-artifacts DEST=/tmp/vfy-rel`,
exit 0): der Lauf meldet `release-sums: SHA256SUMS geschrieben (6 Assets in /tmp/vfy-rel)` und
`release-artifacts: OK — 6 Binaries + SHA256SUMS in /tmp/vfy-rel`; `ls /tmp/vfy-rel` zeigt sechs
Binaries und die `SHA256SUMS`. Die `generate`-Zeile ist die Quelle:

```sh
grep -n 'release-sums.sh generate' Makefile        # → @bash harness/tools/release-sums.sh generate "$(DEST)"
```

**Die publizierte SUMS ist das Erzeugnis dieser Mechanik:**

```sh
diff /tmp/vfy-rel/SHA256SUMS /tmp/vfy-rel/SHA256SUMS.release   # → byte-identisch (leer)
```

Die `SHA256SUMS` am Release `v0.2.1` ist Byte für Byte die, die `release-sums.sh generate` über
den deterministischen Glob-Lauf schreibt — die SUMS ist von der Prozedur-Mechanik entstanden, die
Folgepflicht 1 von [`ADR-0059`](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
verlangt, und nicht von Hand hochgeladen. `sha256sum -c SHA256SUMS` am frischen DEST → **6× OK**.

**Pin-Kopplung am Release, alle sechs Plattformen** (über den Auftrag — linux-amd64 vom
Orchestrierer, zwei weitere Plattformen von diesem Lauf — hinaus wurden **alle sechs** Zeilen
gehalten):

```sh
gh release download v0.2.1 -p SHA256SUMS -O /tmp/vfy-rel/SHA256SUMS.release
# je Zeile gegen den Makefile-Pin verglichen → 6× OK
```

Alle sechs Zeilen der Release-SUMS sind Byte für Byte die `TRAEGER_SHA256_*`-Pins des Makefile
(`:46–51`) — die Kopplung aus Folgepflicht 2 hält am gepinnten Tag an **allen** Plattformen,
nicht nur am von Hand nachgewiesenen linux-amd64. Und weil die Release-SUMS byte-identisch zur
frisch gebauten ist, gilt dieselbe Gleichheit für den frischen Bau aus dem Tag-Baum.

**`ADR-0059` Festlegung 2 am Binary — mit Präzisierung der Sonde.** Die Auftrags-Sonde
*„`grep -c 'TRAEGER_SHA256'` → 0"* trifft am **Binary** in diesem Wortlaut **nicht zu** — der
rohe String steht **5×** im frisch gebauten Asset:

```sh
grep -oa '.\{0,30\}TRAEGER_SHA256.\{0,50\}' /tmp/vfy-rel/ai-harness-init-linux-amd64 | sort -u
# → 5 Zeilen: ausschließlich Code-Referenzen des eingebetteten Fetch-Skripts
#   (sha_var="TRAEGER_SHA256_${plat_u}_${arch_u}", "TRAEGER_SHA256_$p",
#   "erwartet=\"$TRAEGER_SHA256\"", "-e TRAEGER_SHA256=\"$sha\"", Kommentar)
```

Das **Kriterium** der Festlegung 2 — kein Wert im Binary, der vom Bau-Ergebnis abhängt — hält:

```sh
grep -oaE 'TRAEGER_SHA256[A-Z_]*[[:space:]]*[?:]?=[[:space:]]*[0-9a-f]{64}' \
  /tmp/vfy-rel/ai-harness-init-linux-amd64 | wc -l                    # → 0
grep -oa 'TRAEGER_TAG ?= v0.2.1' /tmp/vfy-rel/ai-harness-init-linux-amd64 | wc -l   # → 1
grep -c 'TRAEGER_SHA256' internal/emit/templates/enforce/traeger.mk  # → 0  (Fitness-Zeile der ADR-0059)
```

Die 64-Hex-Zeichenketten im Binary sind Krypto-Konstanten der Go-Laufzeit und der
Transport-Bild-Digest (`463eaf60…`, Quellen-Literal); kein Asset-Digest. Der Binary-Sonduhr
des Auftrags ist als Roh-Grep zu eng gefasst — richtig ist sie an der Fragment-Vorlage (→ 0,
gemessen) und am Kriterium (→ kein Bau-abhängiger Wert, gemessen).

**Der laut-Bruch am Ziel (L3):** `make full-smoke` → **exit 0** über 19 Stufen, Stufe 4
(`traeger_fetch_im_ziel`) mit allen fünf belegten Fällen am realen Ziel (Log-Auszüge):

- (a) Fehlt-Fall: „meldet die Abwesenheit mit Exit 0 und schreibt nichts — der Fehlt-Fall ist
  unangetastet, der Fetch kein Prerequisite."
- (b) Fetch real (Ziel-Modus, Netz, Transport im Bild): „legt den Traeger aus dem gepinnten
  Release ab, ausführbar, Digest vor der Ablage verifiziert." — der Fetch im frischen Klon
  exportiert keine Digest-Pins, verifiziert also real gegen die `SHA256SUMS` des gepinnten Tags.
- (c) Negativ-Fall (Dogfood-Kanal, real): „der verdrehte sha256-Pin bricht den Fetch nach EINMAL
  Laden laut, nennt die Digest-Abweichung, und der liegende Traeger bleibt unangetastet" — der
  rot gesehene Gegenbeispiel-Lauf am realen Netz, mit der behaupteten Ursache in der Meldung.
- (d) Konsumenten-Aufruf: „archiviert welle-fetch mit dem aus dem gepinnten Release gefetchten
  Traeger — Vollzug gemeldet, Archiv mit Stubs gelegt."
- (e) laut-Bruch: „bricht den Aufruf mit der Argument-Sperre statt still zu starten, und nichts
  ist geschrieben."

Die Meldungen „unbekannte Architektur onion/hexagonal" im Lauf-Log sind die **erwarteten**
Negativ-Proben der Stufen (laut-Bruch, danach zurückgenommen), kein Lauf-Fehlschlag — der
Gesamt-Exit ist 0.

---

## 2. DoD, Punkt für Punkt

**Liefer-Punkt 1 — Release-Schnitt: erfüllt.**

- **Sieben Assets am Release** (sechs Plattform-Binaries + `SHA256SUMS`): `gh release view` →
  `assets: 7` (Messung oben).
- **Die SUMS als Mechanik:** gebaut (`make release-artifacts DEST=/tmp/vfy-rel`, exit 0, SUMS im
  DEST), `generate`-Zeile als Quelle im Rezept, publish-Job hält Form/Menge/Inhalt inline vor dem
  Upload (`.github/workflows/release.yml`, Haltungs-Block vor `gh release upload/create`; die
  Reihenfolge Haltung-vor-Upload hält `test/release-matrix.bats` Fall „…fail-closed VOR dem
  Upload").
- **Matrix nach `LH-QA-04`:** sechs Plattformen; die drei SUMS-Zähne stehen in
  `test/release-matrix.bats` (`:317` Rezept erzeugt SUMS am selben Ort · `:323` publish-Job hält
  fail-closed · `:344` generate/verify hermetisch, beide Richtungen der Vollständigkeit).
- **Rote Gegenproben:** fehlt ein Asset → Matrix-Test (in `make test`); fehlt die SUMS → der
  Fetch bricht vor jeder Ablage (`curl -fsSL` auf das fehlende Manifest bricht das Payload unter
  `set -eu`; gemessen real am Schnitt laut Plan-Notiz HTTP 404). Die Klasse „verdrehtes Asset
  gegen das Manifest" ist hermetisch und real gehalten (bats Negativ-Fälle; full-smoke (c) real).

**Liefer-Punkt 2 — Pin-Nachzug: erfüllt.**

- `grep -nE '^TRAEGER_(TAG|SHA256)' Makefile` → `:45 TRAEGER_TAG ?= v0.2.1`, `:46–51` sechs
  Digests; Fragment `internal/emit/templates/enforce/traeger.mk` → `TRAEGER_TAG ?= v0.2.1`,
  **kein** Digest (`grep -c 'TRAEGER_SHA256' …traeger.mk` → 0), nur `TRAEGER_TAG`/`TRAEGER_CARRIER`
  exportiert.
- **Kopplungs-Test** Fall 1 in `test/traeger-fetch.bats:116` (beide Stellen gegen `v0.2.1`, kein
  Digest im Fragment, sechs 64-Hex-Werte im Makefile); Negative-Fälle: Manifest-Abweichung bricht
  ohne Ablage (`:174`), Pin-Abweichung bricht ohne zweiten Download (`:196`), teilweise
  exportierte Pins brechen **vor** dem Transport (`:213`), Dogfood-Zwilling byte-gleich (`:132`).
- **Eigene Messung der Folgepflicht 2 am Release:** alle sechs SUMS-Zeilen == Makefile-Pins
  (Kommando in §1), Release-SUMS byte-identisch zur frisch gebauten. **Deckung:** alle sechs
  Plattformen; die Messung dieses Laufs übersteigt den Auftrag (linux-amd64 + zwei weitere) und
  ersetzt dessen engere Aussage.

**Liefer-Punkt 3 — der laut-Bruch am Ziel: erfüllt.** `make full-smoke` exit 0; die Stufe misst
am realen Ziel den Gelingens-Fall des Konsumenten-Aufrufs mit dem **gefetchten** Träger ((d), real
archiviert) und den laut-Bruch an einem Träger ohne die Sperren ((e), Argument-Sperre, nichts
geschrieben) — der gemessene Zustand, nicht die Grenze des gepinnten Standes. Die Rote Gegenprobe
(„kehrt die Stufe den laut-Bruch in einen stillen Init-Pfad-Start zurück, färbt der Fall rot")
ist im Fall (e) als Muster gebaut: Exit 0 **oder** fehlende Ursache-Meldung **oder** geschriebener
Klon → Stufe bricht.

**`make gates` grün: erfüllt.** Beleg: `make gates` dieses Verifikations-Laufs über den finalen
Baum (inkl. dieses Reports), Nachweis `.harness/state/gates-passed.diffsha` (Stop-Hook); der
Orchestrierer-Lauf meldete grün am selben Kopf, die Tag-CI grün (Gates + `adr-immutable`-Range
`451e3fbf..28337be5`).

**Review durchgeführt: erfüllt.** Drei Runden unter `docs/reviews/` (Runde 1 `918d76dc`, Runde 2
`7c071065`, Runde 3 `8b6a5149` + Code-Span-Nachtrag `40d62e67`); kein Self-Review.

**Doku-Update: erfüllt.** Werkzeuge-Zeile trägt den Pin-Stand (`harness/README.md:80`, „
`v0.2.1`", Verifizierung gegen die `SHA256SUMS`, zwei Kanäle); E2E-Sicht regeneriert
(`docs/user/e2e-abdeckung.md` — Stufe-4-Zeile trägt Vollzug und laut-Bruch, Zeilen-Anker der
folgenden Stufen nachgezogen; erzeugt, nicht hand-edited).

**Closure-Notiz, Register, Risiko-Ausgänge, Paarungen, `git mv`: nicht prüfbar in diesem Lauf —
Closure des Planners steht aus.** Der Slice liegt in `in-progress/`, §7 ist Platzhalter, die
DoD-Häkchen sind offen. Kein Defekt der Implementation; die Closure-Pflichten sind der
Planner-Übergabe unten.

---

## 3. Befunde

**V-1 (MEDIUM): die GRENZE-Stelle der E2E-Stufe nennt einen nicht mehr gepinnten Stand.**
`harness/tools/full-smoke.sh:1542` — *„GRENZE, GEMESSEN AM ASSET: der gepinnte Release-Stand
v0.2.0 führt das Unterkommando …"*. Der gepinnte Stand ist `v0.2.1` (Makefile `:45`,
Fragment-Default); der Satz behauptet das Gegenteil — dieselbe Klasse wie eine zweite Pin-Quelle,
die driftet, hier in einem Kommentar ([`AGENTS.md`](../../AGENTS.md) §3.7: beschrieben wird die
Stelle, nicht der Stand ihrer Entstehung). Nicht DoD-brechend — die Stufe liest den Pin dynamisch
und lief an `v0.2.1` grün —, aber die Stelle wird geändert, und der nächste Leser liest `v0.2.0`
als gepinnt. Vorschlag: die Version aus dem Satz nehmen (die Klasse trägt die Aussage — *der
gepinnte Release-Stand führt das Unterkommando und die Sperre; deshalb sind (d) und (e)
messbar*) oder den Pin dynamisch benennen. `grep -rn 'v0\.2\.0' --include='*.sh'
--include='*.mk' Makefile harness/ tools/ | grep -v baseline` → genau **eine** Stelle; mehr
Befunde dieser Klasse gibt es nicht.

**V-2 (INFO, benannte Lücke): die fehlende-`SHA256SUMS`-Klasse trägt keinen hermetischen Zahn.**
Die 404-Klasse (SUMS-Asset fehlt am Release) bricht fail-closed per Konstruktion (`curl -fsSL`
bricht das Payload, bevor irgendetwas abgelegt wird), ist aber in `test/traeger-fetch.bats` nicht
hermetisch belegt — die Negativ-Zähne decken die Manifest-**Abweichung** (fremder Eintrag), nicht
das fehlende Manifest. Gemessen wurde sie real am Schnitt (Plan-Notiz). Grenze der Deklaration,
benannt nach [`AGENTS.md`](../../AGENTS.md) §3.6 — kein DoD-Punkt verletzt (L1 nennt die
Messung, nicht einen Zahn).

**Keine weiteren Befunde.** Insbesondere: **keine Fremd-Kennungen** in den Slice-Diffs —
`git diff f9b62059^..HEAD | grep -E '^\+.*(a-check|/Development/|d-check/v?0\.7)'` → nur die
Autor-Zeile „ai-harness-init-Team" der ADRs (eigenes Team); kein d-check-, a-check- oder
Kurs-Bezug wanderte in die Artefakte. **Kein Signier-Schritt, kein Stempel, keine
Emissions-Struktur-Änderung** im Diff (Fragment-Ort, Target-Form, Prerequisite-Freiheit
unverändert — die Vorlage führt nur `.PHONY` und das Target ohne Prerequisite). **Kein
Bau-abhängiger Wert** im Binary (§1).

---

## 4. Plan-vs-Code-Diff (beide Richtungen)

**Geplant → gebaut:** alle Positionen der §3-Tabelle und beider Verfeinerungs-Blöcke tragen ihre
Artefakte — Release-Pipeline (publish-Job mit Inline-Haltung), `Makefile` (Pins `:45–51`,
Rezept `release-artifacts` mit `generate`-Zeile), `internal/emit/templates/enforce/traeger.mk`
(nur Tag), `test/traeger-fetch.bats` (Kopplung + Negative), `full-smoke.sh` Stufe 4 (fünf Fälle),
`docs/user/e2e-abdeckung.md` (regeneriert), Span-Spaltung
(`internal/span/{emit.go,lock_unix.go,lock_windows.go}` — die zwei POSIX-Syscalls je OS,
`emit.go` plattformfrei), `traeger-fetch.sh` + byte-gleicher emittierter Zwilling, `release-sums.sh`
+ publish-Job + `test/release-matrix.bats`. Die Restaurierung `e34ef1de` trägt genau den
Diff-Umfang, den der Plan nennt: `git show --shortstat e34ef1de` → 2 Dateien, 489 insertions(+),
24 deletions(-).

**Gebaut → nicht geplant (im Slice-Range `f9b62059^..HEAD`):** kein Code außerhalb des Plans.
Im Range liegen daneben Artefakte anderer Rollen/Vorgänge, die der Plan nicht führt und auch
nicht führen muss: die Plan-Datei des Nachbarslice `slice-releasing-doku-traegt-den-release-vorgang`
(zwei Planner-Commits, eigener Gegenstand), `ADR-0059` samt ADR-Index (Architect-Übergabe),
die drei Review-Reports, das BEO-Verzeichnis
`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` (Planner, §6-Risiko 3), und die
Architect-Norm-Commits `MR-069`/`MR-070` samt Kopf-Marken an `MR-014`/`MR-053`/`MR-034`
(Nachzieh-Setzungen des Auftraggebers 2026-09-19 — außerhalb des Slice-Gegenstands, eigener
Zuschnitt, s. unten).

**§1-Abgrenzung:** die vier Ausschlüsse halten. Der Fetch selbst ist nicht neu gebaut (die
Änderungen am Fetch-Helfer sind die Prüfquelle-Umstellung aus dem `ADR-0059`-Verfeinerungsblock
des Plans, kein zweiter Fetch-Weg); kein Signier-Schritt; kein Stempel (Festlegung 2 am Binary
gemessen); die Emissions-Struktur (Fragment-Ort, Target-Form, Prerequisite) unverändert.

**Commit-Zuschnitte** (`git show --name-only` je Commit): die drei Architect-Commits
(`e861bbf7`, `7f812119`, `28337be5`) berühren ausschließlich `harness/conventions.md` und
`harness/conventions/MR-*` — eigener Zuschnitt nach [`AGENTS.md`](../../AGENTS.md) §3.8; die
Reviewer-Commits tragen nur ihre Reports; die Planner-Commits tragen Plan-, Roadmap- und
Beobachtungs-Dateien; die Implementation-Commits tragen Code, Tests, Workflow und den Slice-Plan
(Verfeinerungen §3, §6-Ausgänge — Übergabe-üblich, kein Closure-Schritt im
Implementations-Commit).

**`MR-069`/`MR-070` als die normative Hälfte:** die No-Checkout-Abweichung trägt ihren Eintrag
(`MR-069`, mit Messbefund, Alternative, Ausnahme in einem Satz, zwei Auflösungs-Triggern und
benannter Lint-Grenze); die Kopf-Marken an `MR-053`/`MR-034` nennen Reichweite, Ziel und
Fortgeltung und stehen **in derselben Änderung** wie der ablösende Eintrag — Form nach
[`MR-032`](../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
und [`MR-046`](../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht):
Rümpfe bleiben, Einträge bleiben aktiv in `conventions/`, die Marke trägt nur die abgelöste
Aussage. [`ADR-0059`](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
bleibt `Proposed` — ihr Accept fällt mit der Closure (Acceptance-Trigger der ADR).

---

## 5. Übergabe an den Planner

1. **Closure steht aus** (DoD-Häkchen, §7-Notiz mit Lerneintrag, Register-Fortsschreibung,
   `git mv` nach `done/`, eigener Commit). Die drei Paarungen sind dann zu prüfen.
2. **§6-Risiken 1 und 2 tragen gegenwärtig den Platzhalter „Ausgang: offen"** — das ist keiner
   der drei Ausgänge; bei der Closure braucht jedes genau einen (*eingetreten* mit Kennung ·
   *entfallen* mit Grund · *weiter offen* ins Register).
3. **Befund V-1** (GRENZE-Kommentar nennt `v0.2.0` als gepinnten Stand) — Korrektur an der
   Stelle vor oder mit der Closure; sie gehört in den Diff des Slices oder einen Micro-Follow-up,
   nicht in die Closure.
4. **Befund V-2** (kein hermetischer Zahn für die fehlende-SUMS-Klasse) — als benannte Lücke
   stehen lassen oder als Folge-Slice schneiden; keine Pflicht aus dem DoD.
5. **`ADR-0059`-Accept** mit der Closure: der Acceptance-Trigger verlangt eine Reviewer-Runde
   gegen `ADR-0058`, `ADR-0055` und `MR-007`; die Runden 1–3 dieses Slices prüften den
   Implementations-Diff, nicht die ADR-Konsistenz — der Accept braucht seine eigene Runde
   (Beleg nach [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
   Festlegung 2), solange die ADR nicht schon in einer dieser Runden geprüft wurde.
6. **Deckungsaussage dieses Laufs:** die Pin-↔-SUMS-Kopplung ist an **allen sechs** Plattformen
   am Release gemessen (über den Auftrag hinaus); der Gelingens-Fall und der laut-Bruch sind am
   realen Ziel für die Plattform des Laufs (linux/amd64) gemessen — die übrigen Plattformen trägt
   der Plattform-Smoke der Release-Workflow (Start-Smoke), nicht diese Stufe (GRENZE im
   Workflow-Kopf benannt). Der Dogfood-Modus fuhr in diesem Lauf real nur als Negativ-Fall
   (full-smoke (c)); sein Gelingens-Fall ist hermetisch gehalten (bats) und von CI gefahren.
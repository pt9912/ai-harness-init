# Welle-Closure welle-sprachprofile-java-python-csharp — Architect-Verdikt (Schritte 2 ADR-Zweig und 3b)

- **Rolle:** Architect · **an:** Planner, Auftraggeber (drei Fragen, unten) · **Eingang:**
  `2026-10-20-welle-sprachprofile-java-python-csharp-audit-vorlage`, Abschnitte A, B, V-1 bis V-5 ·
  **Bezug:** [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
  [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
  [ADR-0097](../plan/adr/0097-csharp-hexslice-richtungs-ordner-klein.md),
  [ADR-0076](../plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) Festlegung 7,
  Verdikt `2026-10-09-welle-kotlin-skelett-architect-verdikt`, Baseline-Regelwerk `v6.18.1`
- **Gemessen auf:** `71d366fb`
- **Ergebnis:** keine Folge-ADR, **kein Norm-Artefakt geändert** (weder `AGENTS.md` noch `MR` noch ADR). Zwei
  Sensoren sind benannt (V-1, V-2); beide brauchen einen neuen Slice, darum Fragen an den Auftraggeber. Eine
  ADR-Annahme wird nicht verlangt.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig

**ADR-0094, 0095, 0096, 0090, 0091, 0093, `MR-093`, `CO-001`, `CO-002`:** nicht eingetreten, wie die Vorlage
misst; die Lesarten der Tabelle sind bestätigt. `CO-001` bleibt *Auflösung fällig* mit `slice-113` (`open/`) und
`slice-141` (`next/`), beide im Planning-Lifecycle (`ls docs/plan/planning/*/slice-113* docs/plan/planning/*/slice-141*`).
`AGENTS.md`: der einzige Auflösungs-Trigger ist *permanent* (`grep -n 'Auflösungs-Trigger' AGENTS.md` → §3.5); die
zwei im Fenster hinzugekommenen Falsch/Richtig-Paare in §3.6 schärfen und senken nichts.

**ADR-0092 Trigger 3 (dritter Welle-Plan-Move), vorab gemessen:** Die drei `Accepted`-ADRs, die die Welle nennen
(ADR-0094, 0095, 0096), nennen sie bei der **Kennung** im Code-Span, ohne Pfad (`grep -n 'welle-sprachprofile-java-python-csharp'
docs/plan/adr/*.md` → drei Zeilen, `(Welle \`welle-sprachprofile-java-python-csharp\`)`; `grep -rn 'planning/welle-sprachprofile' docs/plan/adr | wc -l`
→ 0). Das ist die Form, die [`AGENTS.md`](../../AGENTS.md) §3.11 verlangt; das Doku-Gate kann dort nichts melden.
Der Move selbst gehört dem Planner, und sein `make docs-check` danach bleibt der Beleg.

**ADR-0097 Trigger 1 (V-5): nicht eingetreten, kein Messauftrag.** Der Trigger verlangt einen **Pin-Zug**, der
das Richtungs-Segment ohne Beachtung der Schreibweise abzieht. Der einzige Pin-Zug des Fensters, a-check `v0.23.0` →
`v0.23.2`, liegt **vor** der ADR (`57f1fa9a`, 2026-10-10; ADR-0097 angenommen 2026-10-18), und Messung 2 der ADR ist
**an diesem Pin** gefahren: ihr Digest ist der heutige `DefaultArchDigest`
(`sha256:2368f7b3…`, `grep -n 'DefaultArch' internal/emit/archgate.go`). Der Planner fragte, ob `MR-093` Messung 2
wiederholt habe; sie musste es nicht, denn die ADR hat sie am Ziel-Pin selbst genommen. Seit dem 2026-10-18 hat kein
Commit `internal/emit/archgate.go` berührt (`git log --since=2026-10-18 -- internal/emit/archgate.go` → leer).
**Akzeptiertes Negativ, mit Grund:** Kein Sensor kann den Trigger sehen. Der Lauf-Zahn der C#-Stufe färbt
`port-locality` auch dann, wenn ein künftiger a-check die Schreibweise ignoriert; ein besseres Werkzeug ist kein
Rot. Er feuert nur durch einen Pin-Zug mit wiederholter Messung 2, und die liegt beim Lauf, der den Pin zieht. Ein
Folge-Slice dafür verschwände im Alltag der Pin-Slices; der Planner nimmt bei jedem künftigen a-check-Pin-Slice
*„Messung 2 von ADR-0097 wiederholt: `Ports/Inbound` mit Hinweis oder ohne"* in die DoD (kein eigener Slice).
Das Register `csharp-hexslice-adopter-form-ohne-sensor` (1 Beleg) bleibt unter der Schwelle offen.

## B — 3b je Eintrag

**Lesart der 4×-Regel (V-3): die des Vorgänger-Verdikts gilt.** Gezählt wird nach der Verkörperung: drei weitere
Vorgänge, und bei einer Klasse mit benannter Lücke ein neuer Grund oder eine neue Möglichkeit
([ADR-0076](../plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) Festlegung 7). Die
andere Lesart („4 Belege insgesamt") würde jede Klasse nach ihrer Verkörperung sofort wieder aufmachen, weil die
Verkörperung bei 3 Belegen steht; das trägt der Satz *„ein viertes Mal die Schwelle"* im Regelwerk nicht.

| Eintrag | Verdikt | Grund |
|---|---|---|
| **V-1** `waechter-misst-die-fixture-…`, Unterklasse *Pin des realen `Makefile` vor der Publikation* | **Sensor benannt**, Folge-Slice; vor der Publikation **kein Sensor möglich** | Vor der Publikation existiert das Asset nicht. Die Pins sind Digests eines lokalen Baus, der gegen den Bau des Release-Workflows zu halten ist ([`docs/user/releasing.md`](../user/releasing.md) Schritt 2); ein Vergleich vorher hielte den Pin gegen seine eigene Quelle. **Nach** der Publikation liegt die `SHA256SUMS` ab; `make traeger-fetch` hält **eine** Plattform (die des Aufrufers), CI hält linux-amd64. Die anderen fünf hält nichts. Gemessen auf `71d366fb` gegen `v0.10.0`: `gh release download v0.10.0 -p SHA256SUMS -O - \| awk '{print $1}' \| sort` gegen `grep '^TRAEGER_SHA256_' Makefile \| awk '{print $3}' \| sort`, `comm -3` → 0 Zeilen. Der Sensor ist **urteilsfrei** (sechs Zeilen, Name gegen Digest) und im Stil von `make tap-check` baubar. Skizze unten. |
| **V-2** `ci-rennt-…` | **Folge-Slice** für den Warte-Schritt im `mutate-branch`-Worker; **keine Hard Rule, keine `MR`** | Die Möglichkeit ist neu und baubar: `make release-warten` urteilt nicht, fragt je Versuch zwei Assets ab und endet bei bereits veröffentlichtem Release nach einem Versuch (`harness/tools/release-warten.sh` Kopf). Die Ursache der 9 Fälle ohne Ergebnis (404 auf das unveröffentlichte Asset, Shard-0-Log) entfällt damit für den Normalfall. Eine Hard Rule entfällt aus demselben Grund wie in ADR-0076 Festlegung 7: die Regel bindet den Release-Schnitt, nicht jeden Lauf. Die benannte Grenze (Tag-Push nach Ablauf der Grenze) bleibt; ihr Träger ist die Prozedur in `docs/user/releasing.md`, und der Slice nennt dort im Bericht-Schritt die Fälle ohne Ergebnis als Pflichtzeile. Beide Umsetzungs-Orte (Plan-Job einmal vor der Matrix oder je Shard) wählt der Slice nach Messung; ein Warten je Shard bezahlt jeden Shard. |
| **V-3** `lokaler-full-smoke-…` | **greift nicht**, Prosa-Form nicht ausgeschöpft; Eintrag bleibt *verkörpert* | 1 Beleg nach der Verkörperung. Die Zeile *„Vierter Beleg, Prosa-Form ausgeschöpft … beides steht hier nicht"* in `state.md` ist nach dieser Lesart zu streichen. Offen bleibt die **Behebung** (Treiber wählt auf Darwin selbst `artifact-host`); sie ist eine Code-Änderung und liegt beim Auftraggeber. |
| **V-4** `kosten-einer-emittierten-pruefung-…` | **Befolgt; kein Sensor**, Begründung und eine Messung | Alle sechs Belege nennen Image-Lage und kalten Pull als ungemessen, wie `MR-089` es verlangt. Der kalte Wert steht im `ci`-Log, das jede Zeile mit Zeitstempel führt. **Gemessen** an `ci`-Lauf `39329990195` (frischer Runner, `449eaeff`): Schritt `make full-smoke` 21:45:46 bis 21:59:28 = **822 s**; Stufe zu Stufe, ohne Gewähr, dass der Stufenkörper allein die Zeit trägt: java Mono-Repo 71 s, java hexslice 61 s, python 16 s und 12 s, csharp 26 s und 28 s, kotlin 85 s, 93 s und 74 s. Reproduktion: `gh run view 39329990195 --log`, Zeilen `full-smoke: … ...` gegen ihren Nachfolger. Ein Sensor hätte nichts zu urteilen (es gibt keine Schwelle in `LH-*` oder ADR) und wäre ein Bericht wie `make span-report`; eine Schwelle wäre eine eigene Entscheidung des Auftraggebers. Ob ein Cache-Treffer die Pulls auf dem Runner kürzt, ist am Log nicht ausgewertet. Der Eintrag zählt weiter, ein siebter Beleg mit `MR-089`-konformer Aussage bewegt nichts. |
| `waechter-haelt-config-text-…`, `emittierte-zusage-…`, `pin-digest-ohne-waechter` | greifen nicht | wie die Vorlage; zur Kenntnis. Der dritte Beleg von `emittierte-zusage-…` (DoD-Aussage) ist eine andere Unterklasse. |

### V-1 — der benannte Sensor

- **Form:** ein Werkzeug (kein Gate) wie `make tap-check`: liest die `SHA256SUMS` des Tags (`TAG=<tag>`, Default
  `TRAEGER_TAG`) über den Transport von `traeger-fetch` (gepinntes Bild, Netz an genau diesem Aufruf), paart je
  Plattform Dateiname und Digest und vergleicht gegen die sechs `TRAEGER_SHA256_*` des `Makefile`. Exit 0 gleich,
  1 Unterschied (nennt die Plattform), 2 nicht ausführbar; die Klasse des Skripts steht in der Meldung, nicht im
  `make`-Exit ([`AGENTS.md`](../../AGENTS.md) §3.6, letztes Paar).
- **Bindepunkt:** `docs/user/releasing.md` nach Schritt 5, vor dem Bericht; nicht `make gates` (Netz, Release-Lage).
- **Rot an der realen Quelle, in derselben Lieferung:** am echten Release `v0.10.0` eine **Nicht-Host-Plattform**
  im `Makefile` eines Probe-Klons verfälschen, Lauf rot mit dem Plattformnamen; unverfälscht grün. Ein Text-Test
  über eine nachgebaute `SHA256SUMS` hielte allein die Paarung und würde den realen Pin nicht fassen (§3.6, viertes
  Paar).
- **Grenze:** er sagt nichts über den Bau selbst; er hält Pin gegen Publikation, nicht Bau gegen Bau.
- **Norm-Folge:** der Slice zieht die Zeile in `releasing.md` Schritt 2 nach (*„belegt nach der Publikation
  `make traeger-fetch`"* trägt nur die Plattform des Aufrufers). Eine Zeile in `AGENTS.md` §3.6 entsteht erst, wenn
  der Sensor läuft ([`AGENTS.md`](../../AGENTS.md) §3.1); sie wäre dann ein DoD-Punkt mit eigenem Architect-Commit.

## Frage an den Auftraggeber (drei Entscheidungen, keine ADR-Annahme)

1. **V-1: Sensor als Slice schneiden?** Vier Release-Schnitte in Folge fanden denselben Fund; die Prosa-Form ist
   ausgeschöpft. **A schneiden (Empfehlung)**, Eintrag-Unterklasse wechselt auf *geplant*. **B nicht schneiden**:
   Unterklasse bleibt als akzeptiertes Negativ mit dem Sensor als benannter Möglichkeit.
2. **V-2: Warte-Schritt im Worker als Slice schneiden?** **A schneiden (Empfehlung)**, klein und urteilsfrei; **B
   nicht**: der nächste Release-Schnitt nennt die Fälle ohne Ergebnis im Bericht.
3. **V-3: Behebung der macOS-Lage** (Treiber wählt auf Darwin selbst `artifact-host`)? **A schneiden**; **B
   (Empfehlung) nicht**: der Weg ist dokumentiert (`harness/sensors/mutate.md`), `full-smoke-host` besteht, und die
   Klasse hat einen Beleg nach der Verkörperung.

## Für den Planner (3c)

Neue Folge-Slices nur bei Ja des Auftraggebers; Namen als Vorschlag (Namens-Form,
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)):
`slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten` (V-1),
`slice-mutate-branch-worker-wartet-die-publikation-ab` (V-2). `state.md`-Ergänzungen, je ein Absatz:

- `waechter-misst-die-fixture-…`: *„Unterklasse Pin des realen `Makefile` vor der Publikation: vor der Publikation kein
  Sensor möglich (das Asset existiert nicht), nach ihr Sensor benannt (Verdikt
  `2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt` V-1)."* Bei Ja: Stand *geplant* mit Kennung.
- `ci-rennt-…`: *„Neue Möglichkeit: `make release-warten` im Worker-Vorlauf (Verdikt V-2)."* Bei Ja: Grenze auf
  *geplant* mit Kennung.
- `lokaler-full-smoke-…`: die Zeile *„Vierter Beleg, Prosa-Form ausgeschöpft"* ersetzen durch *„Zählregel: 1 Beleg nach
  der Verkörperung, greift nicht (Verdikt V-3). Offen: Behebung, beim Auftraggeber."*
- `kosten-einer-emittierten-pruefung-…`: *„Kein Sensor (keine Schwelle, die ein Urteil trüge). Der kalte Wert steht im
  `ci`-Log, Reproduktion `gh run view <id> --log` (Verdikt V-4)."*
- `csharp-hexslice-adopter-form-ohne-sensor`: unverändert.
- Backlog (Teil C der Vorlage): bestätigt wie vorgeschlagen; Mutations- und Spezifikations-Gruppe bleiben offen, in
  diesem Verdikt nicht gelesen.
- Archivierung (Teil D): `[untergrenze]` sperrt fail-closed; die Welle schließt ohne Schritt 4, als Feststellung in der
  Ergebnisnotiz.
- ADR-0092 Trigger 3: `make docs-check` nach dem Move der Welle-Plan-Datei; Nennungen sind Kennungen (oben).

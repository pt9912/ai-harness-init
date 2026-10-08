# Welle-Closure welle-erfassungsschicht-im-ziel — Architect-Verdikt (Schritte 2 ADR-Zweig und 3b)

- **Rolle:** Architect · **an:** Planner · **Eingang:** `2026-10-08-welle-erfassungsschicht-im-ziel-audit-vorlage`,
  Abschnitte A und B (C, D brauchen kein Verdikt) · **Bezug:**
  [`LH-FA-13`](../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans), Baseline-Regelwerk `v6.17.0`,
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 und 3
- **Gemessen auf:** `ff28ccfa`
- **Ergebnis:** keine Folge-ADR, kein neuer Slice, kein Norm-Artefakt geändert. Ein Eintrag bekommt einen
  neuen Ausgang (*verkörpert*); kein neuer Beleg; kein Herkunfts-Anker zu setzen.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig

| ADR · Trigger | gefeuert | Verdikt |
|---|---|---|
| [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2/5, [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6 — Teil-Ablösung durch [ADR-0087](../plan/adr/0087-fingerabdruck-gilt-auch-fuer-das-emittierte.md) | — | **mit der Annahme erledigt.** Die Ablösung ist der `supersedes`-Weg selbst; die Index-Zeilen beider ADRs tragen die Marke (`grep -n '0087' docs/plan/adr/README.md`). |
| ADR-0011 Re-Evaluierungs-Trigger (Hook-Oberfläche · `agent_type` · Emission · eigener Betrieb · Bremse · C/E-Wahl) | nein | **bestätigt.** Keiner nennt die Ebenen-Schärfe des Hashes. Die Welle kennzeichnet eine unbekannte Rolle (`SPEC-096`), sie ändert die Abbildung `agent_type` → Rolle nicht. |
| ADR-0022 Re-Evaluierungs-Trigger (Aufschlag · Verbrauchs-Zähler · Hook-Oberfläche · Plattform) | nein | **bestätigt.** Der Fingerabdruck läuft im Dogfood seit ADR-0011; der Aufschlag, den `make hook-overhead` hier misst, enthält ihn schon, und die Mechanik ist auf beiden Ebenen dieselbe. Kein neuer Kostenposten, also keine neue Messpflicht. |
| [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) | — | `Proposed`, nur genannt; kein Gegenstand des Audits. |
| übrige | nein | im Fenster nur ADR-0087, ADR-0088, Index und `spec/spezifikation.md` geändert (`git diff --name-status 3779eb4a HEAD -- docs/plan/adr harness/conventions AGENTS.md Makefile d-check.mk internal/emit/emit.go .d-check.yml spec/`); kein Pin-, Baseline- oder Lastenheft-Sprung. |

**Hard Rules:** einziger Auflösungs-Trigger in [`AGENTS.md`](../../AGENTS.md) lautet *permanent*
(`grep -n 'Auflösungs-Trigger' AGENTS.md` → Zeile 110). **Bestätigt**, keine Zeile zu entfernen.

## B — Lese-Schritt und Verkörperung (3a, 3b)

### (a) `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` → **verkörpert**

- **Zielort:** [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
  `SPEC-088` (`rule_version` in jeder Zeile), `SPEC-089` (Zählregel und Fassungs-Tabelle),
  `SPEC-094` (die geschriebene Fassung ist die letzte Tabellenzeile).
- **Kein Herkunfts-Anker.** Die Regel steht als Festlegung mit eigener Kennung; nach
  [ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1 trägt der Zielort dann
  seine Kennung, und ein `seit slice-…` in einer Spec-Zelle wäre der zweite Anker, den die
  Geltungsbereichs-Klausel (`grundlagen-traceability.md` §Herkunfts-Anker) ausschließt. Kein
  Eigentümer muss etwas setzen; die fehlende `liegt in`-Zeile in §7 des Slice ist damit kein Defekt.
- **Sensor (Beleg 4):** `TestCurrentRuleVersionIsTheLastSpecFassung` (`make test`) mit
  `test/mutations/593-span-fassung-ohne-tabelle-hochgezaehlt.sh` hält die Konstante gegen die reale
  Tabelle; `592` hält das Feld in jeder Zeile.
- **Grenze der Verkörperung:** ob ein Bedeutungswechsel als solcher erkannt und hochgezählt wird,
  hält kein Wächter (`SPEC-094` sagt es selbst). Ein Sensor dafür wäre **baubar**: ein Golden-Test, der
  für feste Payloads die Zeile je Fassung festhält und rot wird, wenn sich die Ausgabe ohne neue
  Fassung ändert. **Akzeptiertes Negativ, nicht gebaut:** Beleg 4 ist das Restrisiko des liefernden
  Slice und kein unangekündigter Wechsel. Der erste Wechsel unter der Regel (Fassung 5, `SPEC-096`)
  wurde hochgezählt. **Trigger:** tritt ein unangekündigter Bedeutungswechsel auf, also ein neuer Beleg
  dieser Klasse, wird der Golden-Test als Slice geschnitten.

### (b) `zusicherung-ueber-der-leeren-menge-wahr` — **kein neuer Beleg, bestätigt**

Kandidat ist DoD 3 von `slice-agent-role-traegt-nicht-bekannt`: *„keine Rolle *nicht bekannt* in der
Ausgabe"* an `make span-report`, über einem Bestand ohne Verbrauchs-Zähler, also über einer leeren
Menge von Rollen-Zeilen. Die Form passt (Negation über einer selbst besorgten Menge). Die
Fehlerrichtung der Klasse ist aber, dass *die Eigenschaft als gemessen gilt*, wo nichts vorlag, und
die fehlt hier. Die Verifikation nennt den Lauf *„nur trivial"* und *„nicht gegenprüfbar"*; die
Closure führt ihn als Grenze 2. Getragen wird die Zusage von
`TestAggregiere_KennzeichnungIstKeineRolle` über einer nicht leeren Eingabe. Das ist der Ausweg der
Klasse, angewandt. Die Planner-Lesart der Vorlage gilt. Der Hinweis auf die drohende Eskalation spielt
für die Zählung keine Rolle.

**Akzeptiertes Negativ, für künftige Läufe:** eine leere Bezugsmenge, die der messende Lauf selbst
als Grenze benennt und deren Zusage an anderer Stelle über einer nicht leeren Menge getragen wird,
gilt nicht als Auftreten. Ein Beleg entsteht nur, wenn die leere Menge als Messung gelesen wird.

**Für den Planner:** (a) `state.md` → *verkörpert* mit Zielort, Sensor und Grenze von oben; (b) bleibt
unverändert.

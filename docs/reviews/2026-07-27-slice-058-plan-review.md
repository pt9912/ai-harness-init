# Review-Report: slice-058 (Plan) — 2026-07-27

**Review-Art:** **Plan** — geprüft wird der **Plan** gegen **Spec und aktive ADRs**, *bevor*
implementiert wird (Modul 10 §Drei Review-Arten). Es gibt noch keinen Diff; Eingabe ist der Plan
selbst. Nicht geprüft: Code, DoD-Abhakung.

**Gegenstand:** `docs/plan/planning/open/slice-058-hexagonal-go.md` (Commit `502f429`), zusammen
mit dem vorausgehenden CR **0.17.0** (`ca87f65`).

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Warum überhaupt ein Plan-Review:** der letzte lag am **2026-07-18** (slice-018); seither haben
rund 40 Slices ausschließlich einen Code-Review bekommen (46 Reports „Review-Art: Code" gegen 3
„Plan"). Allein in dieser Sitzung wurden **drei Plan-Defekte** erst während oder nach der
Implementierung gefunden (slice-053 Achsen-Kopplung, slice-056 widersprüchliche DoD, slice-057
untaugliches Vehikel) — genau die Klasse, die Modul 10 als „Plan-Review-HIGH kostet eine
Plan-Korrektur" beschreibt.

**Eingangs-Kontext:**

- Plan: `docs/plan/planning/open/slice-058-hexagonal-go.md`
- Spec: [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (nach CR 0.17.0), [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`spec/architecture.md`](../../spec/architecture.md) §5 (die normative Heimat der Layout-Regeln)
- Aktive ADRs: [`ADR-0008`](../plan/adr/0008-arch-achse-emittiertes-skelett.md) (Arch-Achse), [`ADR-0009`](../plan/adr/0009-hexslice-arch-realisierung.md) (HexSlice-Realisierung)
- [`AGENTS.md`](../../AGENTS.md) §3 Hard Rules
- Referenz-Belege des CR: das `--print-config`-Gerüst des gepinnten Arch-Gates und die `.a-check.yml` zweier realer Repos der Familie

---

## Findings

### F-1 — Das geplante Layout wäre für Gate **und** Wächter unsichtbar

- `kategorie`: **HIGH**
- `quelle`: [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · Plan §2 DoD (1)
- `pfad`: `internal/gen/arch.go` (`archLayered`), `internal/gen/archgate_test.go:261`
- `befund`: Der Plan wählt **neue Rollen** (`core`/`port`/`adapter`) und das Familien-Layout
  (`internal/hexagon/core/**`). Beide Mechanismen, die heute über die Gate-Emission entscheiden,
  sind aber auf **hexslice-Namen** verdrahtet:

  ```go
  func archLayered(arch string) bool {          // arch.go
      for _, r := range archLayout(arch) {
          if r == roleDomain { return true }    // ← nur roleDomain zählt
      }
      return false
  }
  ```
  ```go
  if strings.Contains(rel, "hexagon/domain/") { layered = true }   // archgate_test.go:261
  ```

  Folge, wenn der Plan unverändert umgesetzt wird: `archLayered("hexagonal")` ist **false** →
  `ArchGateConfig` meldet `ok=false` → **es wird kein Arch-Gate emittiert**. Und der
  Kopplungs-Wächter `TestArchGateConfig_CoversEveryLayeredCombo`, auf den sich DoD (1) ausdrücklich
  beruft („der Wächter koppelt sie"), erkennt das Layout **ebenfalls nicht** als geschichtet und
  bliebe grün. Ein geschichtetes Modul ohne Gate, ohne dass irgendetwas rot wird — die
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse in
  Reinform.
- `verifizierbar`: ja — `sed -n '/^func archLayered/,/^}/p' internal/gen/arch.go` und
  `grep -n 'hexagon/domain/' internal/gen/archgate_test.go`.
- **Konsequenz für den Plan:** DoD (1) trägt eine **falsche Zusage** („der Wächter koppelt sie").
  Der Plan braucht einen eigenen Punkt: *die Geschichtet-Erkennung wird von einer Namensprüfung auf
  eine strukturelle gehoben* — und dieser Umbau berührt `hexslice` mit, ist also nicht
  nebenwirkungsfrei. **Blockierend**: ohne diese Korrektur liefert der Slice ein stilles Loch.

### F-2 — Kein ADR geplant, obwohl die Präzedenz einen verlangt

- `kategorie`: MEDIUM
- `quelle`: [`ADR-0009`](../plan/adr/0009-hexslice-arch-realisierung.md) als Präzedenzfall · [`AGENTS.md`](../../AGENTS.md) §5
- `pfad`: Plan §3 (Änderungs-Tabelle ohne ADR-Zeile)
- `befund`: Für die **Realisierung** von `hexslice` wurde eine eigene ADR geschrieben (ADR-0009:
  welche Rollen, welche Richtungen, nach welcher Referenz). Für `hexagonal` steht dieselbe Klasse
  von Entscheidungen an — **welches Layout emittiert wird** (gelebte Familien-Konvention statt
  `--print-config`-Gerüst) und **welche Kanten-Menge** (inklusive `adapters → core`). Der Plan
  behandelt beides als Renderer-Detail. Das ist inkonsistent zur eigenen Präzedenz und macht die
  Entscheidung unauffindbar: sie stünde nur in einem Slice, der nach `done/` wandert.
- `verifizierbar`: nein — Konsistenz-Urteil gegen die Präzedenz, kein Gate.
- **Konsequenz:** entweder eine ADR (Proposed-first, wie 0006–0009) oder eine **begründete**
  Notiz im Plan, warum hier keine nötig ist. Stillschweigen ist die schlechteste der drei Optionen.

### F-3 — Die normative Heimat der Layout-Regeln bleibt stehen

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence) · slice-053-Lehre („Regeln gehören nach `architecture.md`, nicht in Kommentare")
- `pfad`: [`spec/architecture.md`](../../spec/architecture.md) §5
- `befund`: `architecture.md` nennt `hexslice` **sechsmal** und `hexagonal` **null**mal; §5
  beschreibt genau **ein** schichten-tragendes Layout. Der Plan sieht ein Doku-Update für Handbuch
  und README vor — aber **nicht** für die Spec-Ebene. Damit bliebe die Architektur-Beschreibung
  hinter dem Code zurück, und zwar an derselben Stelle, an der slice-053 die Regeln bewusst
  verankert hat.
- `verifizierbar`: ja — `grep -c "hexslice" spec/architecture.md` → 6; `grep -c "hexagonal"` → 0.
- **Konsequenz:** ein DoD-Punkt oder eine Zeile in der Änderungs-Tabelle für `architecture.md` §5.

### F-4 — Die ungenutzten Gate-Fähigkeiten sind nicht abgegrenzt

- `kategorie`: LOW
- `quelle`: welle-08 §6 (dort war es explizit abgegrenzt)
- `pfad`: Plan §6
- `befund`: Die Referenz-Configs der Familie nutzen `adapter_sink`, `tech` und
  `forbidden_constructs`. Unsere emittierte Config tut das für `hexslice` bewusst nicht — in
  welle-08 stand das als ausdrückliche Abgrenzung. Der Plan von slice-058 schweigt dazu; ohne
  Abgrenzung ist unklar, ob die Auslassung Absicht oder Vergessen ist.
- `verifizierbar`: ja — die Referenz-Configs führen die Schlüssel, unsere nicht.

### F-5 — Der Disjunktheits-Test darf keine Liste sein

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · slice-052/055-Lehre („ein Literal-Set als Wächter altert")
- `pfad`: Plan §2 DoD (3)
- `befund`: DoD (3) verlangt einen Test auf **disjunkte Verzeichnisnamen**. Wird er als
  hartkodierte Liste geschrieben, altert er beim nächsten Layout still. Er sollte die Namen **aus
  den Renderern ableiten** und den Schnitt beider Mengen prüfen — dann trägt er auch für eine
  vierte Architektur.
- `verifizierbar`: ja — beim Code-Review am fertigen Test.

## Negativbefunde

- geprüft, ohne Befund: **Spec-Deckung** — `hexagonal` ist seit CR 0.17.0 in [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) geführt, samt Abgrenzung zu `hexslice`; der Plan bewegt sich innerhalb der Anforderung, nicht daneben.
- geprüft, ohne Befund: **CR-Reihenfolge** ([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) — der CR liegt als eigener Commit **vor** dem Slice-Plan und ändert nur `spec/lastenheft.md`.
- geprüft, ohne Befund: **Slice-Größe** (Modul 5) — drei slice-eigene DoD-Punkte plus die drei Standard-Zeilen; die Konformität aus slice-055 hält.
- geprüft, ohne Befund: **Welle-Frage** ([`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)) — im Plan explizit beantwortet, inklusive des Grenzfalls bei Frage 3 und der Ansage, bei Bedarf nachzuschneiden statt rückwirkend umzudeuten.
- geprüft, ohne Befund: **Reihenfolge Sensoren vor Doku** — DoD nennt sie ausdrücklich (die Lehre aus slice-054).
- geprüft, ohne Befund: **`adapters → core` als bewachte Kante** — der Plan sieht dafür einen Mutations-Fall vor; die Klasse ist aus slice-054 (Fall 96) belegt.
- geprüft, ohne Befund: **Rückführungen** — §4 benennt beide Kanten konkret und nicht formelhaft, insbesondere den Fall „Vokabular-Umbau gehört getrennt".

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 1 |
| INFO | 1 |

## Verdikt

**Merge-blockierend:** **ja** — F-1 ist HIGH und trifft den Kern: der Plan würde ein geschichtetes
Modul **ohne Arch-Gate** erzeugen, und der Wächter, auf den sich die DoD beruft, würde dabei grün
bleiben. Das ist keine Detailkorrektur, sondern ein zusätzlicher Arbeitsschritt (Geschichtet-
Erkennung von Namen auf Struktur heben) **mit Rückwirkung auf `hexslice`**.

**Empfehlung:** Plan überarbeiten, bevor der Slice nach `in-progress` geht — F-1 als eigener
DoD-Punkt oder als eigener vorgelagerter Slice, F-2 (ADR ja/nein, begründet) und F-3
(`architecture.md`) in die Änderungs-Tabelle.

**Der Beleg für die Review-Art selbst:** F-1 hätte im Code-Review einen kompletten
Implementierungs-Lauf gekostet — und wäre womöglich gar nicht aufgefallen, weil der Fall **grün**
aussieht. Genau dafür sieht Modul 10 den Plan-Review vor.

**Übergabe:** Findings gehen an die **Planung** (Rückkante Review → Plan), nicht an die
Implementation — es gibt noch keinen Diff.

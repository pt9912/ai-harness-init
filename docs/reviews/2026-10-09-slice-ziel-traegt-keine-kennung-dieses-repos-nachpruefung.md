# Review-Report: slice-ziel-traegt-keine-kennung-dieses-repos, Nachprüfung — 2026-10-09

**Review-Art:** Code — Nachprüfung der Befunde aus dem Review vom selben Tag (`e5a4c118`).

**Gegenstand:** `47365e76`

**Skill:** `.harness/skills/reviewer.md` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-ziel-traegt-keine-kennung-dieses-repos`; der Vor-Report (`e5a4c118`)
- `ADR-0090`, `LH-QA-01`, `AGENTS.md` §3.5–§3.7

**Summary:** 0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO — freigegeben. Alle sechs Vor-Befunde behoben.
Klassen: Muster-Kommentar beschreibt eine Schreibform, die das Repo überwiegend nicht nutzt ·
Geltungs-Aussage eines Musters weiter als sein Prüfbereich.

---

## Findings

### LOW-1 — `agentsAbschnittMuster` erkennt die Form nicht, in der das Repo den Verweis meist schreibt

- `kategorie`: LOW (Grenzen-Aufzählung, gefahrene Form fehlt, Kommentar schickt in die Irre)
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `cmd/ai-harness-init/kennungen_test.go` (`agentsAbschnittMuster`, Kopf von
  `TestTraegerMeldungenTragenKeineKennung`)
- `befund`: Der Kommentar sagt, das Muster treffe die Nummer „in der Form, in der dieses Repo sie
  schreibt". Gefahren (`grep -qE 'AGENTS\.md ?§? ?[0-9]'`, dieselbe Syntax wie das Go-Muster):
  Treffer bei `AGENTS.md 3.5`, `AGENTS.md §3.5`, `AGENTS.md § 3.5`. Kein Treffer bei
  `` `AGENTS.md` §3.5 ``, ``[`AGENTS.md`](…) §3.5``, `AGENTS.md, §3.5`, `AGENTS.md (§3.5)`
  und `AGENTS.md  §3.5` (doppeltes Leerzeichen). Die Backtick-Form ist die häufigste im Repo
  (``git grep -hoE '`AGENTS\.md` ?§ ?[0-9]' -- '*.md' '*.go' '*.sh' ':!.harness/baseline' | wc -l``
  → 2106, gegen 377 für die erkannte Form), und sie steht auch in Go-Literalen
  (`internal/emit/baumaussage.go:78`). Die GRENZE nennt „eine Abschnittsnummer in anderer Form"
  allgemein, deshalb kein stilles Überversprechen. Als Beispiele nennt sie aber nur zwei seltene
  Formen, und der Muster-Kommentar behauptet die Repo-Form. Heute trägt kein Träger-Literal eine
  der unerkannten Formen mit Nummer: `make gates` ist grün, und die Liste unter `grep -rn 'AGENTS\.md'`
  über die Nicht-Test-Quellen enthält nur Kommentare.
- `verifizierbar`: ja — Sonde oben
- `klasse`: Grenzen-Aufzählung ohne die Haupt-Form

### INFO-1 — „gilt nur für Meldungen des Trägers" ist enger gesagt als gemessen

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `cmd/ai-harness-init/kennungen_test.go` (`agentsAbschnittMuster`)
- `befund`: `TestTraegerMeldungenTragenKeineKennung` liest jedes `ast.BasicLit` unter `cmd/` und
  `internal/`. Dazu gehören auch Literale, die als emittierter Text ins Ziel gehen (Fall 641 mutiert
  ein solches in `internal/emit/archgate.go`; `internal/emit/baumaussage.go` führt weitere). Ein
  solches Literal mit einem Verweis auf einen Abschnitt der **Ziel**-`AGENTS.md` würde laut gemeldet,
  obwohl er dort auflöst. Ein falsch-positiver Treffer, kein stilles Grün. Heute gibt es keinen.
- `verifizierbar`: nein
- `klasse`: Geltungs-Aussage weiter als der Prüfbereich

---

## Geprüft, ohne Befund

- **HIGH-1 (Rechts-Grenze):** `kennungenInText` verwirft nur noch, wenn auf die Kennung ein
  Buchstabe, eine Ziffer oder `_` folgt. Damit treffen `MR-077-statt-der`, `slice-082-foo` und
  `LH-QA-01-Bedingung`. `ADR-00012`, `ADR-0001x` und `LH-QA-012` treffen nicht. Kopf und Code
  stimmen überein, `TestKennungenInTextGrenzen` hält beide Richtungen. Die feste Länge
  (`{4}`, `{3}`, `{2}`) und die Rechts-Sperre für Ziffern halten eine längere Ziffernfolge fern.
  Ein Nicht-ASCII-Buchstabe nach der Kennung (`LH-QA-01ä`) zählt als Treffer. Das ist laut, nicht
  still, und deshalb kein Befund. Fall 649: die Lesung des Verifiers wird übernommen, nicht
  nachgefahren.
- **MEDIUM-1:** Die Meldung von `haenger` nennt die Regel im Klartext. Fall 650 bindet das neue
  Muster.
- **LOW-1 / Schwerpunkt 3 (`ADR-[0-9]{4}` in `fremdeKennung`):** Die Streichung läuft nur über
  den Rumpf der fremden `--print-mk`-Ausgabe. Den eigenen Kopf (`adopterHeader`,
  `archAdopterHeader`) hängen `AdaptMK` und `AdaptArchMK` erst **nach** der Streichung an
  (`internal/emit/emit.go:236`, `internal/emit/archgate.go:148`). Im Rumpf ist ein `ADR-NNNN` die
  ADR des Werkzeugs. Im Ziel würde sie in den ADR-Nummernraum des Ziels fallen, und dort löst sie
  entweder nicht oder auf eine fremde Entscheidung auf. Die Streichung entfernt also keine Kennung,
  die im Ziel auflösen soll. Real gefahren (`docker run --rm --network none … --print-mk`, Pins
  d-check v0.84.0, a-check v0.23.0): Die Klammer-Kennungen sind nur `DC-FA-…`, `AC-QA-03` und
  `ADR-0030`, alle in der eingegrenzten Menge. `slice-082` steht dort frei im Satz. `(UTF-8)` und
  Verwandte bleiben stehen (`TestStreicheFremdeKennungenTrifftNurDieRegister`, Fall 651).
- **LOW-2:** Der Kopf von Fall 641 nennt jetzt beide roten Tests und beschreibt die Gegenprobe so,
  wie sie im Vor-Review gemessen wurde.
- **INFO-1/INFO-2 (Vor-Report):** Die Grenzen sind im Testkopf benannt.
  `prosaVerweisMuster` ist mit `(?:[^.]|\.\S)` gefasst: `spezifikation.md` und `v0.6.0` beenden den
  Satz nicht, „Spezifikation. Danach …" bleibt kein Treffer.
- **Hard Rules §3.3/§3.4/§3.8:** Es gibt keinen Move mit Inhaltsänderung, keine Accepted-ADR ist
  berührt, und im Implementer-Commit liegt keine Norm-Datei.

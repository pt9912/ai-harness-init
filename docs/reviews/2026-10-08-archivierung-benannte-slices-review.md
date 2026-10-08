# Review-Report — slice-archivierung-erkennt-benannte-slices

**Datum:** 2026-10-08 · **Rolle:** Reviewer (Modul 8, frischer Kontext) ·
**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) 2.3.0 · **Runde:** 1

## Eingangs-Kontext

| Punkt | Inhalt |
|---|---|
| **Diff** | `fcc02cfd` (Arbeit), `cf6d2b78` (Fall 583 shellcheck-sauber); Claim `2919c956`/`850c663b`, Roadmap `0d5ecf0f` gelesen, ohne Code-Gegenstand |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| **ADRs / MR** | `ADR-0033`, `ADR-0041`, `ADR-0077`, `ADR-0081`; `MR-057` Setzung 1, `MR-059`, `MR-071`, `MR-072` |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7, §3.10 |
| **Slice-Plan** | `slice-archivierung-erkennt-benannte-slices` (Kennung, nicht Pfad — er wandert, §3.11) |

## Findings

### LOW-1 — Doc-Kommentar eines Bestandstests hängt jetzt am neuen Test

- `kategorie`: LOW · `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (Kopplung)
- `pfad`: `internal/archive/stub_test.go:150-157`
- `befund`: Der neue Test ist zwischen den Doc-Kommentar von `TestTitelVonLaesstDenNummernRestStehen`
  und dessen `func` eingefügt. Der Kommentar, der „die vier getroffenen H1-Formen UND die Grenze"
  zusagt, steht damit als erster Absatz über `TestTitelVonStreiftDenNamen`; der Bestandstest
  steht ohne Kommentar. Wer die Zusage ändert, findet sie am falschen Test.
- `verifizierbar`: nein (`make comment-claims` prüft die Existenz des genannten Tests, nicht die Zuordnung)
- `klasse`: Kommentar durch Einfügen von seinem Gegenstand getrennt

### INFO-1 — `kennungRE` streift bei fehlendem Trenner einen Teil des Namens

- `kategorie`: INFO · `quelle`: Maintainability (Skill §LOW/INFO mit Eskalation, Formen-Probe)
- `pfad`: `internal/archive/stub.go:151`, Aufzählung in `stub.go:157-160`
- `befund`: Fehlt hinter einer benannten Kennung ein Trenner, backtrackt `[A-Za-z0-9-]*` bis zum
  letzten Bindestrich und nimmt ihn als Trenner: `slice-foo-bar Titel` → `bar Titel`,
  `welle-adopter-weg-im-ziel Titel` → `ziel Titel`. Die Aufzählung im Funktionskopf nennt nur
  vollständige Treffer und das unveränderte Stehenbleiben. Die Nummern-Form hatte das schon vorher
  (`slice-190-titel Rest` → `titel Rest`), der Name macht es leichter erreichbar. Im Bestand tritt
  es nicht auf (Messung unten: 0 Abweichungen), und die Vorlage schreibt `: `.
- `verifizierbar`: nein
- `klasse`: Grenzen-Aufzählung ohne Formen-Probe

### INFO-2 — Präfix-Grenze weicht vom DoD-Wortlaut ab (an Planner/Verifier)

- `kategorie`: INFO · `quelle`: Plan §2 DoD (1)
- `pfad`: `internal/archive/collect.go:118-147, 352-369`
- `befund`: Laut DoD (1) gilt „Wortgrenze wie bei der Nummer“. Umgesetzt ist dagegen
  „der längste Name im Lifecycle gewinnt“. Plan §3 begründet das (der Bindestrich ist hinter einem
  Namen Runden-Trenner und Namensteil zugleich). Die Abweichung widerspricht keiner ADR. Sie ist
  im Code-Kopf (GRENZE) und in `harness/sensors/archive-welle.md` Punkt 5 benannt. Ob DoD (1)
  damit erfüllt ist, entscheiden Planner und Verifier. Der Reviewer entscheidet das nicht.
- `verifizierbar`: ja (Messung unten)
- `klasse`: Plan-Fortschreibung statt DoD-Wortlaut

## Messungen (selbst gefahren)

- **Vorschau am realen Bestand:** `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand`
  (Binär 09:15, nach `fcc02cfd`) → `wellenlos 198`, `Review-Reports (ohne Stub): 325`. EXIT 3
  ist die bekannte Verweis-Sperre, kein Fehler dieses Diffs.
- **Unabhängige Nachrechnung (Shell, `grep -P`, ohne Go):** Ich habe die Kennungen aller
  Lifecycle-Dateien gesammelt (381) und jeden Report in `docs/reviews/` (724) mit `reviewTraegt`
  und der Präfix-Grenze zugeordnet. Ergebnis: 244 Reports bleiben ohne Zuordnung, **0** sind
  mehrdeutig. Die Reports der 198 wellenlosen `done/`-Slices sind **325** = 170 mit Nummer +
  155 mit Namen, gleich der Vorschau. Zu viel eingesammelt wird nicht: Hinter jedem benannten
  Treffer steht nur ein Runden-Suffix (leer 120, `-verify` 26, `-verifikation` 10, `-review`,
  `-nachpruefung`, `-freshness` je 3, `-implementer`, `-architect` je 2, Rest je 1, nach Abzug von
  `-rN`/`-runde-N`). Kein fremder Name hängt hinter einer Kennung.
- **Titel am Bestand:** `kennungRE` lief über die H1 aller benannten Slice- und aller Welle-Dateien.
  Jeder benannte Treffer beginnt mit dem vollen Dateinamen, kein Teil-Streifen.
- **Mutationen:** `make mutate MUTATE_CASES="583-… 584-… 585-…"` → `3 ok, 0 Befund(e)`. Die
  `sed`-Anker treffen den Quell-Bestand (`MR-071`), jede der drei Mutationen ist angewandt und rot.
- **Gegenprobe (Skill):** Alle drei Mutationen angewandt, `t.Skip` **nur** in den drei benannten
  Tests, `make test-go` → rot über `TestAnwendenSchreibtDenStubEinesBenanntenSlice` und
  `TestEinsammelnReviewsBenannterSlices`. Das ist ein struktureller Nebeneffekt. Die drei
  Unit-Tests binden eigene Fälle, die die Integrationstests nicht führen: `slice-Gross-x.md` → `""`,
  Nummern-Form unverändert, `slice-foobar`-Grenze, `—`-Trenner und Welle-Name. Kein Befund.
  Danach `git checkout -- internal/archive`, Baum sauber.

## Negativbefund

- **`SliceNummer`/`sliceKennungRE`:** geprüft, ohne Befund. Die Nummer-Alternative steht zuerst,
  der Name beginnt mit einem Buchstaben, beide Formen schließen sich aus, Aufrufer `anwenden.go:269`
  und `lifecycleKennungen` passen.
- **`ReviewTrifft`/`lifecycleKennungen`:** geprüft, ohne Befund. Das Ergebnis ist
  reihenfolge-unabhängig und `Reviews` sortiert. Eine Nummer-Kennung bekommt nie ein
  `andere`-Präfix, weil eine Nummer keinen Bindestrich trägt. Die Fehlzuordnung durch einen fremden
  Namen mit eingebettetem `slice-<k>` steht als GRENZE im Kopf, und im Bestand gibt es 0 Fälle.
- **Tests messen die Eigenschaft:** geprüft, ohne Befund. Die Tests prüfen die volle Liste
  (`strings.Join` gegen die Erwartung) und den Gegenfall (`foo-bar-r2` bleibt liegen).
- **`harness/sensors/archive-welle.md`:** geprüft, ohne Befund. Die Zuordnungs-Regel stimmt mit
  dem Code überein.
- **§3.7 im Code-Diff (außer LOW-1):** geprüft, ohne Befund. Die Kommentare stehen im Indikativ
  über den Zustand, die genannten Tests existieren.
- **§3.10:** geprüft, ohne Befund. Der Implementer hat Plan §3 fortgeschrieben, DoD und §6/§7
  nicht.

**Zählung:** HIGH 0 · MEDIUM 0 · LOW 1 · INFO 2.

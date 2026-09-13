# Review Runde 2 — slice-werkzeug-erkennt-die-benannte-kennung

**Rolle:** Reviewer (`.harness/skills/reviewer.md`, v1.7.0) · **Datum:** 2026-09-13
**Gegenstand:** Commit `004335cc` (Review-Nacharbeit) gegen die Befunde aus
[Runde 1](2026-09-13-slice-werkzeug-erkennt-die-benannte-kennung.md) — **eine** Frage: sind sie
aufgelöst? Kein Neuaufrollen; ein neuer Befund steht nur hier, wenn er blockiert.
**Arbeitsbaum:** unverändert. Alle Sonden liefen gegen Kopien unter dem Scratchpad, im gepinnten
Go-Image `golang@sha256:65b6f280…` bzw. `bats/bats@sha256:e8f18e0a…`, je `--network none`.

---

## Je Befund ein Urteil

### HIGH-1 — **aufgelöst**

Drei Messungen, alle gegen den **lebenden** Baum bzw. das gepinnte Image:

1. *Die benannte Kennung löst auf.* Sonde `SlicePfadRelativ(root="/src", …)` über eine
   HEAD-Kopie: `werkzeug-erkennt-die-benannte-kennung` →
   `"../../in-progress/slice-werkzeug-erkennt-die-benannte-kennung.md"` (Runde 1: `""`).
2. *Die nummerierte Form ist unverändert.* Dieselbe Sonde: `188` und `176` liefern exakt die
   Werte aus Runde 1. Über den **ganzen** Bestand gemessen — `Hervorgegangen()` über alle 83
   `- **Folge-Slices`-Zeilen des Planning-Baums, einmal mit dem Code aus `6c3ea3a9^`
   (vor dem Slice) und einmal aus `004335cc`, beide Male derselbe Baum:
   **0 abweichende Zeilen**.
3. *Die Tests messen die Eigenschaft, nicht den Zustand.* Zwei Mutationen an
   `sliceDateiMuster()`, je auf einer eigenen Kopie:

   ```sh
   sed -i '/"slice-" + kennungTeil + ".md",/d'   internal/archive/stub.go   # A: HIGH-1-Defekt zurück
   sed -i '/"slice-" + kennungTeil + "-\*.md",/d' internal/archive/stub.go  # B: nummerierte Form weg
   ```

   A → `--- FAIL:` `TestHervorgegangenUebernimmtBenannteSliceKennung`,
   `TestHervorgegangenMischtBenannteUndNummerierteSliceKennung`,
   `TestSlicePfadRelativLiefertDieAufsteigendeForm`.
   B → zusätzlich `TestHervorgegangenBautAnkerLinks` und
   `TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach`.
   Beide Richtungen sind damit bewacht; genau die zwei Tests, die in Runde 1 den Ausfall als
   `want` hielten, fallen unter A.

`TestHervorgegangenBenannteKennungOhneDateiBleibtBar` deckt den Randfall ohne Datei und ist
keine Attrappe (er fällt unter Mutation `317`).

### MEDIUM-1 — **aufgelöst** (Entscheidung trägt), mit **N-1** daneben

Die Grenze ist gemessen und an vier Stellen benannt — je `grep -c` = 1:
`vier Stück` (`harness/tools/slice-mv.sh` §GRENZEN), `Vier gemessene Grenzen`
(`harness/sensors/slice-mv.md`), `GRENZE, gemessen (MR-057 Setzung 1` (`internal/archive/stub.go`
über `sliceRE`), `Keine Erkennung der zweiten Namensform` (Slice-Plan §1). Die Lücke selbst
besteht unverändert und ist korrekt beschrieben:

```sh
printf '%s\n' '](slice-ADR-0042-nachzug.md)' | grep -cohE '\]\(slice-[0-9a-z][^)/]*\)'   # 0
printf '%s\n' '](slice-adr-0042-nachzug.md)' | grep -cohE '\]\(slice-[0-9a-z][^)/]*\)'   # 1
```

Die Begründung (*Erkennung müsste die Anker-Präfixe selbst kennen — mehr Fläche als die drei
Liefer-Punkte*) trägt: sie ist Klasse 3 der Out-of-Scope-Formen (*es wäre ein anderer Vorgang*).
**Wo** sie eingetragen wurde, ist der neue Befund N-1.

### MEDIUM-2 — **aufgelöst**

Mutation selbst gefahren (`bash test/mutations/318-…sh` auf einer Kopie, dann die volle Go-Suite
im gepinnten Image):

```text
--- FAIL: TestSliceKennungAusTitelSuffixBleibtDieNummer (0.00s)
    stub_test.go:284: Hervorgegangen = "slice-170-archivierungs-werkzeug", want "slice-170"
```

Genau der im `expect:` genannte Wächter, genau einer, und die Meldung trifft die behauptete
Eigenschaft. Der `sed` greift (`var sliceRE` verändert). Der `sliceRE`-Kommentar nennt
leftmost-first als Grund. **Kein vorhandener Zahn ist entwaffnet:** `317` färbt weiterhin seinen
`expect:`-Test rot, und `test/slice-mv.bats` ist 11/11 grün (darunter Fall 7, der `expect:` von
`316`).

### MEDIUM-3 — **aufgelöst**; der Test ist ehrlich, kein verdeckendes `want`

Die Begründung ist nachgemessen und trägt — ein Backtick-Filter wäre falsch-negativ:

```sh
grep -rhE '^- \*\*Folge-Slices' docs/plan/planning/done/ | wc -l                  # 60
grep -rhE '^- \*\*Folge-Slices' docs/plan/planning/done/ | grep -cE '`slice-[0-9a-z]'  # 3
```

Zwei der drei sind **echte** Folge-Slice-Kennungen in Backticks (`` `slice-206` ``,
`` `slice-197` ``), die ein solcher Filter verlöre. Keine Erwartungswerte.

`TestHervorgegangenFliesstextTokenBleibtVonEchterKennungUnunterscheidbar` deklariert sich im
Kommentar als *gemessene Grenze, keine Zusage*, die Grenze steht zusätzlich am Funktionskopf von
`Hervorgegangen()`, und der Test ist rot-fähig (er fällt unter Mutation `317`). Das ist ein
Charakterisierungs-Test, kein eingefrorener Ausfall: Wer den Existenz-Guard nachrüstet, muss ihn
bewusst ändern — genau die Sichtbarkeit, die §3.6 verlangt.

### LOW-1 — **teilweise aufgelöst** (nicht blockierend)

Die drei in Runde 1 genannten Stellen tragen `SLICE=slice-<Kennung>`. Dieselbe Aussage steht
unverändert in einem vierten Träger, den Runde 1 nicht nannte:

```sh
grep -n 'slice-NNN' Makefile   # 340: ## … (SLICE=<slice-NNN> TO=<…>) — NICHT in gates
```

Das ist die Zeile, die `make help` ausgibt.

### INFO-1 — **teilweise aufgelöst** (nicht blockierend)

Korrigiert in `internal/archive/stub.go` und `harness/sensors/slice-mv.md`. **Nicht** korrigiert
an der dritten von Runde 1 genannten Stelle:

```sh
grep -n 'ohne Ziffern-Praefix' harness/tools/slice-mv.sh   # 170 (Runde 1: :162-163)
```

Dort steht weiterhin *„benannte (slice-<slug>, lowercase Kebab-Case ohne Ziffern-Praefix)"*,
während das Fundmuster derselben Datei (`:181`) auf `slice-[0-9a-z]` bindet. Die Commit-Message
führt die Korrektur als erledigt.

### LOW-2 — **aufgelöst** (mit HIGH-1). INFO-2 — unverändert, war schon in Runde 1 nicht blockierend.

---

## Neuer Befund — er blockiert

### N-1 — Der Implementations-Commit schreibt eine Out-of-Scope-Grenze in den eigenen Slice-Plan

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.10 (Hard Rule)
- **pfad:** `docs/plan/planning/in-progress/slice-werkzeug-erkennt-die-benannte-kennung.md:134-143` (in `004335cc`)
- **befund:** Der Commit fügt §1 *Ziel und Abgrenzung* einen vierten Out-of-Scope-Punkt hinzu.
  [`AGENTS.md`](../../AGENTS.md) §3.10 nennt *„eine Out-of-Scope-Grenze"* wörtlich als Änderung,
  die *„die Abnahme selbst verschiebt"* und deshalb **Übergabe-Artefakt an den Planner** ist:
  *„die ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um"*. Genau diese Grenze war
  vorher offen — Runde 1 stellte MEDIUM-1 darauf ab, dass *„§1 des Plans schließt die Form nicht
  aus"*. Der gemessene Lauf schließt sie damit zu seinen eigenen Gunsten, im selben Commit wie die
  Arbeit. Die drei Code-/Doku-Träger der Grenze sind davon unberührt; blockiert ist der Plan-Hunk,
  nicht der Code.
- **verifizierbar:** nein — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Commits;
  `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt (§3.10 stellt das für sich
  selbst fest).
- **klasse:** `fremdes-rollen-artefakt-im-implementations-kontext` (vorhandener Register-Eintrag,
  Stand `verkörpert`, `ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md | wc -l` → 8)

---

## Die Rückführungs-Frage (§4, `in-progress → next`)

**Die Messung des Laufs stimmt, sein Schluss folgt nicht daraus.**

Nachgeprüft: `SlicePfadRelativ` hat genau eine Aufrufstelle im Produkt-Code plus den Test —

```sh
git grep -nE '(^|[^A-Za-z])SlicePfadRelativ\(' -- '*.go'
# internal/archive/stub.go:270 (in Hervorgegangen) · stub.go:346 (Definition) · stub_test.go:340/341
```

(Die vierte Nennung in `internal/archive/refs.go:173` ist ein Kopplungs-Kommentar, kein Aufruf.)

Die Bedingung fragt aber nicht danach. Sie lautet: *„Wenn die Muster-Änderung in
`internal/archive/stub.go` weitere Aufrufer sichtbar macht, die dieselbe Kennung lesen"*, mit der
**konkreten Schwelle** *„mehr als die eine Funktion `Hervorgegangen()` im Diff"*. Beide Hälften
sind erfüllt: `SlicePfadRelativ` **ist** der weitere Leser derselben Kennung, den die
Muster-Änderung sichtbar gemacht hat (das war HIGH-1), und der Diff des Slice trägt inzwischen
drei Funktionen neben `Hervorgegangen()`:

```sh
git diff 6c3ea3a9^..004335cc -- internal/archive/stub.go | grep -E '^[+-]func '
# +func ersterTrefferInDir(…)  +func sliceDateiMuster(…)  +/-func SlicePfadRelativ(…)
```

**Urteil: die Rückführung hat gefeuert**, gemessen an ihrem eigenen Wortlaut. Ob sie *gezogen*
wird — Go-Teil als eigener Slice, dieser behält das Skript — oder ob der Plan stattdessen
sichtbar geändert wird, entscheidet der Planner; die ausführende Rolle entscheidet es nicht
(dieselbe Adresse wie N-1). Der Lauf hat sie mit einer Messung für nicht gefeuert erklärt, die
eine andere Größe misst.

---

## Negativbefunde — geprüft, ohne Befund

- **Kein Regress auf der nummerierten Form**, gemessen über den ganzen Bestand (83 Zeilen, 0
  Abweichungen; Kommando oben) — keine Erwartungswerte.
- **Go-Suite grün** auf der unmutierten HEAD-Kopie: 8 Pakete `ok`, EXIT 0.
- **`test/slice-mv.bats` 11/11 grün** auf derselben Kopie — die Kopf-/`usage()`-Änderungen dieses
  Commits brechen keinen vorhandenen Fall.
- **`make comment-claims`**: `58 Datei(en) geprueft, 0 Befund(e)`, EXIT 0 — die vier neu in
  Kommentaren genannten Tests existieren.
- **`internal/archive/refs.go` trägt die neue Form.** Die drei Ersetzungsregeln binden über
  `regexp.QuoteMeta(base)` auf den konkreten Dateinamen, nicht auf ein Ziffern-Muster; ein
  aufsteigender Stub-Verweis `../slice-<slug>.md`, den das Werkzeug jetzt selbst schreiben kann,
  wird von einem späteren Lauf ebenso nachgezogen wie ein nummerierter
  ([`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 3
  bleibt getragen).
- **Kein Zahn entwaffnet** (§4-Rückführung `in-progress → open`): `316` und `317` färben
  weiterhin ihren `expect:`-Test rot.

## Was ich NICHT geprüft habe

- Die **DoD** — Verifikation, nicht Review.
- `make gates`, `make mutate`, `make full-smoke` **als Ganze**; gefahren wurden
  `make comment-claims` sowie gezielte Einzelläufe in den gepinnten Images.
- Alles, was Runde 1 bereits ohne Befund abgeschlossen hat (Punkt 2/4/5, Schicht-Abgrenzung,
  ADR-0042, Hard Rules außer §3.10) — Runde 2 rollt nicht neu auf.

## Kategorie-Summary

| Runde-1-Befund | Urteil |
|---|---|
| HIGH-1 | aufgelöst |
| MEDIUM-1 | aufgelöst (Entscheidung trägt) |
| MEDIUM-2 | aufgelöst |
| MEDIUM-3 | aufgelöst |
| LOW-1 | teilweise (vierter Träger `Makefile:340`) |
| LOW-2 | aufgelöst |
| INFO-1 | teilweise (`slice-mv.sh:170`) |
| INFO-2 | unverändert, nicht blockierend |

| Neu | Kategorie | Klasse |
|---|---|---|
| N-1 | HIGH | `fremdes-rollen-artefakt-im-implementations-kontext` |

## Verdikt

**Der technische Gegenstand ist frei: alle sechs Befunde der Runde 1 sind in der Sache
aufgelöst, zwei davon (LOW-1, INFO-1) mit einem Rest an einer je dritten/vierten Stelle, der
nicht blockiert.** Blockierend bleibt eine Rollen-Frage, nicht eine Code-Frage: N-1 (der
Implementations-Commit schreibt eine Out-of-Scope-Grenze in den eigenen Plan) und die
Rückführungs-Bedingung §4, die nach ihrem Wortlaut gefeuert hat — beide gehen an dieselbe
Adresse, den Planner, und beide ohne Code-Nacharbeit.

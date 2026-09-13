# Review — slice-werkzeug-erkennt-die-benannte-kennung

**Rolle:** Reviewer (`.harness/skills/reviewer.md`, v1.7.0) · **Datum:** 2026-09-13
**Gegenstand:** Commit `6c3ea3a9` gegen
[`docs/plan/planning/done/slice-werkzeug-erkennt-die-benannte-kennung.md`](../plan/planning/done/slice-werkzeug-erkennt-die-benannte-kennung.md)
**Geprüft gegen:** Slice-Plan · [`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ·
[`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) ·
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) ·
[`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules). **Nicht** gegen die DoD — das ist Verifikation.
**Arbeitsbaum:** unverändert; alle Sonden liefen gegen Kopien unter dem Scratchpad, der Baum ist
nach dem Lauf sauber (`git status --porcelain` leer).

---

## Findings

### HIGH-1 — Die Erkennung ist erweitert, die Auflösung nicht: der Anker-Link einer benannten Kennung wird nie gebaut, und zwei neue Tests setzen den Ausfall als Sollwert

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · Slice-Plan §1 (Ziel-Tabelle) und §4 (Rückführung `in-progress → next`)
- **pfad:** `internal/archive/stub.go:241` (Aufruf) und `internal/archive/stub.go:303-322` (`SlicePfadRelativ`); `internal/archive/stub_test.go:221-249`
- **befund:** `Hervorgegangen()` trifft die benannte Kennung jetzt und reicht sie per
  `SlicePfadRelativ(root, strings.TrimPrefix(id, "slice-"), welleID)` weiter. Deren Globs lauten
  durchweg `"slice-"+nummer+"-*.md"` und verlangen damit einen **Titel-Suffix hinter der
  Kennung** — die Dateiform einer benannten Kennung ist aber `slice-<slug>.md` ohne Suffix
  (`docs/plan/planning/done/slice-werkzeug-erkennt-die-benannte-kennung.md`). Gemessen
  gegen den **lebenden** Baum dieses Repos:

  ```text
  SlicePfadRelativ("werkzeug-erkennt-die-benannte-kennung") = ""
  SlicePfadRelativ("188")                                   = "../../open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md"
  SlicePfadRelativ("176")                                   = "../slice-176-inventur-vor-dem-schnitt-v600.md"
  Hervorgegangen(<Folge-Slices-Zeile mit der benannten Kennung>) = "slice-werkzeug-erkennt-die-benannte-kennung"
  ```

  (Sonde: ein `archive_test`-Testfile in einer Repo-Kopie, `root = /src`, gefahren im gepinnten
  Go-Image `golang@sha256:65b6f280…`, `--network none`.)

  Der Stub gibt die Kennung damit **bar** aus. Genau diese Form definiert der Doc-Kommentar
  derselben Funktion als eine Aussage: *„Ein Folge-Slice, den der Lifecycle nicht mehr führt,
  steht ohne Link da statt mit einem toten"* (`stub.go:216-217`) — während der Lifecycle ihn
  führt. Das Werkzeug erzeugt damit für die neue Kennungsklasse eine falsche Aussage in einem
  Artefakt, das ab Archivierung stehen bleibt; es ist dieselbe Klasse, gegen die der Slice
  angetreten ist, nur eine Funktion weiter.

  Die zwei neuen Go-Tests halten diesen Ausfall als `want` fest —
  `TestHervorgegangenUebernimmtBenannteSliceKennung` erwartet `"slice-benannter-slug"`, und sein
  Kommentar begründet das mit *„auch ohne eine unter dem heutigen Glob-Muster aufloesbare
  Datei"*. Das ist das „Falsch"-Muster aus [`AGENTS.md`](../../AGENTS.md) §3.6: Ein Test, dessen
  Name eine Eigenschaft behauptet (*übernimmt die Kennung*), misst statt ihrer die **heutige
  Implementierung** (den heutigen Glob) und kann unter der Mutation, die wirklich zählt — ein
  Glob, der die benannte Form auflöst —, nie rot werden.

  Der Slice-Plan hat diesen Fall vorab benannt: §4 nennt als Rückführung
  *„Wenn die Muster-Änderung in `internal/archive/stub.go` weitere Aufrufer sichtbar macht, die
  dieselbe Kennung lesen"*. `SlicePfadRelativ` ist ein solcher Leser. Der Lauf hat die Schwelle
  (*mehr als die eine Funktion `Hervorgegangen()` im Diff*) eingehalten, aber weder die
  Rückführung gezogen noch den Fund als Grenze oder Folge-Slice ausgewiesen; §1 schließt ihn
  nicht aus. Die Zählung des Plans (*„genau zwei Stellen tragen sie heute"*) stammt aus
  `git grep -nE 'slice-\[0-9\]'` und sieht nur **Zeichenklassen**-Bindungen — die Bindung in
  `SlicePfadRelativ` ist eine **Form**-Bindung (`Kennung` + `-` + Titel) und fällt durch dieses
  Raster.
- **verifizierbar:** ja — die Sonde oben; ein Test, der die *Eigenschaft* misst (benannter
  Folge-Slice mit **vorhandener** Datei ⇒ Anker-Link), wäre heute rot und ist nicht vorhanden.
- **klasse:** `erkennung-erweitert-aufloesung-nicht-test-friert-den-ausfall-als-sollwert-ein`

---

### MEDIUM-1 — Die Anker-Präfix-Hälfte von `MR-057` Setzung 1 ist für beide neuen Muster unsichtbar, und keine Stelle erklärt das

- **kategorie:** MEDIUM
- **quelle:** [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 1 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `harness/tools/slice-mv.sh:174` · `internal/archive/stub.go:207` · `harness/sensors/slice-mv.md:22-29`
- **befund:** [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  Setzung 1 lässt **zwei** Namensformen zu: *„das Präfix eines vorhandenen Ankers (`LH-*`,
  `ADR-*`, `CO-*`) **oder** ein freier Slug in lowercase-Kebab-Case"* — wörtlich aus
  `.harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md` §Vergabe. Die Anker
  dieses Repos sind durchweg groß geschrieben (`ids`-Muster in [`.d-check.yml`](../../.d-check.yml):
  `ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`, `MR-\d{3}`). Beide neuen Muster binden auf `[a-z]` und
  sehen die erste Hälfte nicht:

  ```sh
  for t in '](slice-ADR-0042-nachzug.md)' '](slice-LH-QA-01-x.md)' '](slice-adr-0042-nachzug.md)'; do
    printf '%-32s neu=%s\n' "$t" "$(printf '%s\n' "$t" | grep -cohE '\]\(slice-[0-9a-z][^)/]*\)')"
  done
  # ](slice-ADR-0042-nachzug.md)     neu=0
  # ](slice-LH-QA-01-x.md)           neu=0
  # ](slice-adr-0042-nachzug.md)     neu=1
  ```

  Go-Seite gleichlautend (Sonde im gepinnten Image): `slice-ADR-0042-nachzug` und
  `slice-LH-FA-01-x` liefern unter altem **wie** neuem `sliceRE` die leere Trefferliste.

  Der Punkt ist nicht, dass die Groß-Form zwingend gelten *muss* — ob sie ihre Schreibweise
  behält, entscheidet weder [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  noch die Baseline ausdrücklich. Der Punkt ist, dass der Diff diese Frage **entschieden hat,
  ohne sie zu benennen**: §1 des Plans schließt die Form nicht aus, der GRENZEN-Block des
  Skripts zählt weiterhin *„drei Stück"*, und [`harness/sensors/slice-mv.md`](../../harness/sensors/slice-mv.md)
  nennt *„Drei gemessene Grenzen"*. Trifft die Groß-Form je zu, meldet
  `make slice-mv` wieder `ausgehend: 0` und der Stub verliert die Kennung — der Ausgangszustand,
  nur mit einer Dokumentation, die ihn für geschlossen ausgibt.
- **verifizierbar:** ja — die zwei Sonden oben; ein bats-/Go-Fall über `slice-ADR-…` wäre heute rot.
- **klasse:** `zusage-nennt-sensor-der-form-nicht-sieht` (vorhandener Register-Eintrag, 14×)

---

### MEDIUM-2 — Die Reihenfolge der Alternativen in `sliceRE` ist tragend und von keinem Wächter gehalten

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `internal/archive/stub.go:204-207`; `test/mutations/317-stub-slicere-verliert-benannte-kennung.sh`
- **befund:** Go-`regexp` (nicht `MustCompilePOSIX`) wählt **leftmost-first**: In
  `slice-(?:[0-9]{3}|[a-z0-9]+(?:-[a-z0-9]+)*)` gewinnt die Ziffern-Alternative, deshalb liefert
  `slice-188-archiv-stub-kennt-…` weiterhin `slice-188` und nicht die ganze Kebab-Kette. Genau
  daran hängt die Rückwärts-Kompatibilität. Die Reihenfolge ist weder im Kommentar über der
  Zeile genannt noch von einem Test oder Mutations-Fall gehalten: Tauscht man nur die beiden
  Alternativen (in POSIX-Lesart dasselbe Muster, in Go **nicht**), bleibt die **gesamte**
  Go-Suite grün — acht Pakete, alle `ok`, darunter `internal/archive`.

  Der Tausch, mit dem das gemessen ist:

  ```sh
  sed -i 's/slice-(?:\[0-9\]{3}|\[a-z0-9\]+(?:-\[a-z0-9\]+)\*)/slice-(?:[a-z0-9]+(?:-[a-z0-9]+)*|[0-9]{3})/' internal/archive/stub.go
  ```

  Über dem realen Bestand ändern dabei **18 von 83** `- **Folge-Slices`-Zeilen ihr Ergebnis und
  erzeugen Phantom-Kennungen (`[slice-170 slice-170]` → `[slice-170 slice-170-archivierungs-werkzeug]`):

  ```sh
  grep -rhE '^- \*\*Folge-Slices' docs/plan/planning/ | wc -l   # 83  (Bezugsmenge)
  # dieselbe Datei durch eine Go-Sonde im gepinnten Image, beide Reihenfolgen verglichen:
  # "Folge-Slices-Zeilen=83  davon durch die Reihenfolge veraendert=18"
  ```

  Beide Zahlen wandern mit dem Bestand — keine Erwartungswerte. Alle vorhandenen Tests
  verwenden Eingaben (`slice-176 (A)`, `slice-176 (Titel)`), bei denen beide Reihenfolgen
  dasselbe liefern; der einzige kuratierte Fall (317) nimmt die Buchstaben-Hälfte zurück, nicht
  die Reihenfolge. Nach dem Maßstab des Plans selbst (*„Ohne ihn ist der neue Wächter
  ungelistet und damit unbewacht"*) ist diese Eigenschaft unbewacht.
- **verifizierbar:** ja — der Tausch oben; `make test`/`make mutate` bleiben grün, das ist der Befund.
- **klasse:** `neuer-waechter-ohne-mutations-fall` (vorhandener Register-Eintrag, 5×)

---

### MEDIUM-3 — Die Go-Seite hat keinen Existenz-Guard und keinen Negativfall: jeder `slice-…`-Token in der Folge-Slices-Zeile wird zur Kennung

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §6 (erstes Risiko) und §3 (Zeile `internal/archive/stub_test.go`)
- **pfad:** `internal/archive/stub.go:241-247`
- **befund:** Der Plan benennt das Risiko *„Ein toleranteres Muster trifft mehr, als es soll …
  ein Fließtext-`slice-mv` fiele darunter"* und nennt als *„vorab benannte Antwort"* die
  Boundary-Fälle aus §3. Für die **Shell**-Seite trägt diese Antwort, aber nicht wegen eines
  Tests, sondern wegen eines Guards, der schon vorher da war:
  `[ -f "$PLANNING/$from/$t" ] || continue` (`slice-mv.sh:170`) — gemessen über den ganzen
  Planning-Baum kommt durch das neue Muster genau ein Nicht-Slice-Ziel hinzu, und der Guard
  hält es:

  ```sh
  comm -13 <(grep -rohE '\]\(slice-[0-9][^)/]*\)'   docs/plan/planning/ | sort -u) \
           <(grep -rohE '\]\(slice-[0-9a-z][^)/]*\)' docs/plan/planning/ | sort -u)
  # ](slice-mv.sh)                                   <- Fließtext im Plan dieses Slice selbst
  # ](slice-werkzeug-erkennt-die-benannte-kennung.md)
  find docs/plan/planning -name 'slice-mv.sh' | wc -l   # 0  -> Guard greift
  ```

  Für die **Go**-Seite gibt es weder Guard noch Boundary-Fall in dieser Richtung:
  `Hervorgegangen()` gibt bei nicht auflösbarem Pfad die bare Kennung aus. Sonde:

  ```text
  inhalt = "- **Folge-Slices:** keine; der Nachzug via `make slice-mv` genuegt"
  Hervorgegangen = "slice-mv"
  ```

  Der Stub trüge dann `slice-mv` als eine Kennung, die den Vorgang überlebt hat. §3 des Plans
  sieht für `stub_test.go` nur *Happy* und *gemischte Liste* vor — ein Negativfall in der
  Über-Treffer-Richtung fehlt, obwohl §6 die Richtung ausdrücklich als Risiko führt.
  Verschärfend: HIGH-1 macht „bare Ausgabe" zum Normalfall jeder benannten Kennung, wodurch
  echter und falscher Treffer in der Ausgabe **ununterscheidbar** werden.
- **verifizierbar:** ja — die Sonde oben; ein Negativfall wäre heute rot.
- **klasse:** `benanntes-risiko-ohne-deckenden-fall-auf-einer-der-zwei-seiten`

---

### LOW-1 — Der Vertrag beider Doku-Träger nennt weiterhin `SLICE=<slice-NNN>`, in einer Datei, die der Diff geändert hat

- **kategorie:** LOW
- **quelle:** [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 3 · Maintainability
- **pfad:** `harness/sensors/slice-mv.md:5` · `harness/tools/slice-mv.sh:18` (ZUSAGE), `:87` (GRENZE 2), `:106` (`usage()`)
- **befund:** Der Diff ergänzt [`harness/sensors/slice-mv.md`](../../harness/sensors/slice-mv.md)
  um den Satz, dass das Fundmuster benannte Kennungen trifft — die **Vertrags-Zeile derselben
  Datei** (Zeile 5) deklariert die Aufruf-Form aber unverändert als `SLICE=<slice-NNN>`; ebenso
  die ZUSAGE-Zeile und der `usage()`-Text des Skripts, dessen Kopf der Diff anfasst, und
  GRENZE (2) mit *„(SLICE=<slice-NNN>)"*. Das Werkzeug nimmt eine benannte Kennung nachweislich
  an (Fixture unten, Aufruf `slice-mv.sh slice-benannte-kennung done`, EXIT 0). Ein Leser des
  Vertrags lernt das Gegenteil der Zeile 24 derselben Datei.
- **verifizierbar:** nein — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Platzhalter-Formen.
- **klasse:** `vertrags-zeile-und-ergaenzungssatz-derselben-datei-widersprechen-sich`

---

### LOW-2 — Ein Test-Kommentar nennt einen Grund, den sein Test nicht herstellt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist*)
- **pfad:** `internal/archive/stub_test.go:236-238`
- **befund:** Der Kommentar zu `TestHervorgegangenMischtBenannteUndNummerierteSliceKennung` sagt,
  die benannte Kennung erscheine bar, *„(Datei existiert nicht unter dem Glob-Muster)"*. Der Test
  legt für die benannte Kennung **gar keine** Datei an (`schreibe(…)` läuft nur für
  `slice-176-folge.md`). Beschrieben ist damit eine Ursache, die an der Stelle nicht vorliegt —
  und ausgerechnet die, die HIGH-1 trägt: dass auch eine **vorhandene** Datei nicht auflöst, ist
  nirgends gemessen.
- **verifizierbar:** nein — `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht, worüber ein Kommentar spricht.
- **klasse:** `kommentar-nennt-ursache-die-der-test-nicht-herstellt`

---

### INFO-1 — „ohne Ziffern-Präfix" beschreibt die zweite Alternative enger, als sie ist

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `internal/archive/stub.go:204-206` · `harness/tools/slice-mv.sh:162-163` · `harness/sensors/slice-mv.md:24-25`
- **befund:** Drei Stellen beschreiben die benannte Form als *„lowercase Kebab-Case ohne
  Ziffern-Präfix"*. Die Alternative lautet `[a-z0-9]+(?:-[a-z0-9]+)*` und lässt eine führende
  Ziffer zu — `slice-13` trifft sie (Sonde: alt `[]`, neu `["slice-13"]` für die Eingabe
  `"slice-13 steckt in slice-130"`). Die Ausdehnung ist harmlos, die Beschreibung nicht
  deckungsgleich.
- **verifizierbar:** nein
- **klasse:** `kommentar-beschreibt-die-zeichenklasse-enger-als-sie-ist`

---

### INFO-2 — `harness/README.md` steht in §3 des Plans, nicht im Diff

- **kategorie:** INFO
- **quelle:** Slice-Plan §3
- **pfad:** `harness/README.md:76`
- **befund:** §3 führt [`harness/README.md`](../../harness/README.md) als `update`; der Diff fasst
  die Datei nicht an. Die Zeile lautet *„Lifecycle-Wechsel eines Slice inklusive seiner
  Verweise"* — generisch und vor wie nach dem Slice zutreffend, ein Nachzug also entbehrlich.
  Notiert, weil die Abweichung vom Plan nirgends festgehalten ist.
- **verifizierbar:** nein
- **klasse:** `plan-zeile-ohne-diff-und-ohne-vermerk`

---

## Negativbefunde — geprüft, ohne Befund

- **Punkt 4 — Zuschnitt von `sliceRE`.** Bestätigt. `git grep 'sliceRE'` liefert drei Zeilen
  (Kommentar, Definition `stub.go:207`, Verwendung `stub.go:241`); die Verwendung steht
  ausschließlich in `Hervorgegangen()` und dort auf der gefilterten `folge`-Zeilenmenge.
  `beoRE` (`BEO-[0-9]{3}`) und `adrRE` (`ADR-[0-9]{4}`) sind im Diff unberührt — die Abgrenzung
  zu [slice-188](../plan/planning/open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md)
  trägt, beide Diffs bleiben disjunkt.
- **Kein Verlust an nummerierten Formen — beide Seiten gemessen.**
  *Shell:* über den ganzen Planning-Baum trifft das alte Muster 119 eindeutige bare Ziele, das
  neue 121; die Differenz „nur alt" ist **leer** (`comm -23`, Kommando in MEDIUM-3).
  *Go:* über alle 83 `- **Folge-Slices`-Zeilen des Baums liefern altes und neues `sliceRE`
  **identische** Trefferlisten (`Zeilen=83 abweichend=0`, Go-Sonde im gepinnten Image). Keine
  Erwartungswerte — beide Zahlen wandern mit dem Bestand.
- **Punkt 2 — die Fixture-Messung reproduziert.** Eigenes Scratch-Repo (Planning-Layout, echtes
  `git`), Geschwister bleibt in `in-progress/`, bewegte Datei nach `done/`, einmal mit dem
  Skript aus `6c3ea3a9^` und einmal aus `6c3ea3a9`:

  | Stand | Meldung | Verweis danach |
  |---|---|---|
  | alt | `ausgehend: 0 …`, *„Kein Verweis zu ziehen"* | `](slice-geschwister-benannt.md)` — zeigt von `done/` aus ins Leere |
  | neu | `ausgehend: 1 …`, Commit 2 gesetzt | `](../in-progress/slice-geschwister-benannt.md)` — korrekt |

  In der gemischten Variante (ein benanntes **und** ein nummeriertes Geschwister): alt `1`,
  neu `2`, wobei der alte Lauf ausschließlich das nummerierte umhängt. Die Aussage des Laufs —
  **blind, nicht „nichts zu tun"** — trägt: der alte Stand meldet Erfolg und lässt einen
  Verweis stehen, der von seinem neuen Ort aus auf keine Datei zeigt.
- **Punkt 3 — beide Mutations-Fälle einzeln angewandt und rot gesehen.**
  `316` (nimmt `a-z` aus der Zeichenklasse): `test/slice-mv.bats` → `not ok 7` mit exakt
  dem Namen aus dem `expect:`-Feld, dazu `not ok 8`; die übrigen 9 bleiben grün.
  `317` (nimmt die Kebab-Alternative aus `sliceRE`): die Go-Stufe über `internal/archive` →
  `--- FAIL: TestHervorgegangenUebernimmtBenannteSliceKennung`, exakt der `expect:`-String,
  dazu der Misch-Test; der unmutierte Klon ist `ok`. Beide `sed`-Ausdrücke sind BRE-korrekt und
  treffen genau eine Zeile. Ein Drift-Schutz besteht: der Treiber meldet
  *„Mutation hat nicht gegriffen bei: … — Patch veraltet?"* (`harness/tools/mutate.sh:671-678`),
  ein wirkungsloser `sed` fällt also laut aus, statt still grün zu bleiben. **Was die zwei
  Fälle nicht decken, steht als MEDIUM-2 oben.**
- **Punkt 5 — §3.7 im geänderten Code.** Die neuen und umgeschriebenen Kommentare stehen im
  Indikativ über den Ist-Zustand, tragen keine Befund-Kennung, keine Slice-Nummer als Erzählung
  und kein Lauf-Protokoll. Der einzige Treffer eines `grep` auf `^\+.*(#|//).*slice-[0-9]` ist
  `slice-13`/`slice-130` als **Testdaten**-Bezeichnung der Teilstring-Falle — Beschreibung der
  Stelle, keine Herkunft. Die zwei Einschränkungen stehen als LOW-2 und INFO-1.
- **Schicht-Abgrenzung (§1) gehalten.** Der Diff berührt genau 7 Dateien; `internal/emit/**`,
  `harness/conventions/**` und `docs/plan/adr/**` sind nicht dabei
  (`git show --pretty=format: --name-only 6c3ea3a9`). Die emittierte Ebene bleibt unberührt.
- **[`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) nicht angefasst.**
  `eingehend_ausgenommene_pfade()` kommt im Diff nicht vor; die Ausnahmeliste ist unverändert
  (bats-Fall 11 grün). Keine Gate-Lockerung, damit kein §3.5-Fall.
- **[`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 3
  unberührt.** Die Stub-Form kommt weiterhin aus der vendored Vorlage; der Diff ändert die
  Kennungs-**Erkennung**, nicht die Formatierung.
- **Hard Rules ohne Befund:** §3.2 — kein `//nolint`, kein `# shellcheck disable` im Diff.
  §3.3 — der Commit enthält keinen Move. §3.4/§3.8/§3.10/§3.11 — keine ADR, kein
  Adaptions-Eintrag, keine Closure-Artefakte, keine eingefrorene Adresse im Diff.
- **`make comment-claims` gefahren:** `58 Datei(en) geprueft, 0 Befund(e)`, EXIT 0.

## Was ich NICHT geprüft habe

- **Die DoD** (§2 des Plans) — Auftrag und Rollenschnitt schließen sie aus; das ist Verifikation.
- **`make gates`, `make mutate`, `make full-smoke`, `make smoke`, `make shell-lint`,
  `make docs-check` als Ganze.** Gefahren habe ich nur `make comment-claims` sowie gezielte
  Einzel-Läufe (`test/slice-mv.bats` im gepinnten bats-Image, die Go-Stufe im gepinnten
  Go-Image). Ob `test/mutations/316|317` im vollen `make mutate`-Lauf ohne BEFUND durchlaufen,
  ist damit **nicht** belegt — nur dass jede Mutation den im `expect:` genannten Test isoliert
  rot färbt.
- **Die Wirkung auf `docs-check` nach einem realen Move** des Slice nach `done/` — die Fixture
  lief gegen ein Scratch-Repo ohne Doc-Gate.
- **Die emittierte Ebene** (`internal/emit/**`) — in §1 ausgeschlossen und im Diff unberührt;
  ob die dort liegenden Muster dieselbe Lücke tragen, ist nicht Gegenstand dieses Laufs.
- **`beoRE`** und die Register-Kennungsform — Gegenstand von
  [slice-188](../plan/planning/open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md).
- **Ob der Groß-Schreibung der Anker-Präfix-Form eine Entscheidung fehlt**, ist als MEDIUM-1
  gemeldet; die Entscheidung selbst zu treffen ist Architect-Arbeit, nicht meine.

## Kategorie-Summary

| Kategorie | Zahl | Klassen |
|---|---|---|
| HIGH | 1 | `erkennung-erweitert-aufloesung-nicht-test-friert-den-ausfall-als-sollwert-ein` |
| MEDIUM | 3 | `zusage-nennt-sensor-der-form-nicht-sieht` · `neuer-waechter-ohne-mutations-fall` · `benanntes-risiko-ohne-deckenden-fall-auf-einer-der-zwei-seiten` |
| LOW | 2 | `vertrags-zeile-und-ergaenzungssatz-derselben-datei-widersprechen-sich` · `kommentar-nennt-ursache-die-der-test-nicht-herstellt` |
| INFO | 2 | `kommentar-beschreibt-die-zeichenklasse-enger-als-sie-ist` · `plan-zeile-ohne-diff-und-ohne-vermerk` |

Zwei der vier HIGH/MEDIUM-Klassen sind **bestehende** Register-Einträge
(`zusage-nennt-sensor-der-form-nicht-sieht` 14×, `neuer-waechter-ohne-mutations-fall` 5×) und
gehören als Beleg dieses Vorgangs in deren `evidence/` — ein Vorgang zählt einmal.

## Verdikt

**Blockierend.** Der Skript-Anteil trägt: die Fixture-Messung ist reproduziert, kein
nummerierter Treffer geht verloren, der Über-Treffer ist durch den vorhandenen Existenz-Guard
gehalten, und der Mutations-Fall färbt seinen Wächter rot. Der Go-Anteil trägt nur die halbe
Strecke: Die Kennung wird erkannt und dann von `SlicePfadRelativ` wieder verloren, und die zwei
neuen Tests halten genau diesen Verlust als Sollwert fest — der Zustand, den
[`AGENTS.md`](../../AGENTS.md) §3.6 als *„Test, der die heutige Implementierung misst"*
beschreibt und der unter keiner Mutation rot werden kann. HIGH-1 ist vor dem Merge zu
entscheiden: entweder die Auflösung nachziehen, oder die Grenze dort ausweisen, wo der nächste
Lauf sie liest — beides ist Übergabe an Implementer bzw. Planner, nicht Gegenstand dieses
Reports.

Die drei MEDIUM sind vor Merge zu klären, blockieren aber nicht je für sich: MEDIUM-1 braucht
eine Entscheidung zur Groß-Form (Architect), MEDIUM-2 einen Fall, der die Reihenfolge hält,
MEDIUM-3 einen Negativfall auf der Go-Seite. LOW und INFO sind nachzuziehen, wenn die Stelle
ohnehin angefasst wird.

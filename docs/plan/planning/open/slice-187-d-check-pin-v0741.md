# Slice slice-187: Der d-check-Pin springt `v0.65.0` → `v0.74.1` — neun Minors, zwei neue Module, ein dreizehntes Target

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Das Kriterium ist die beobachtbare Closure-Bedingung, die **mehr**
beobachtet als die DoD dieses Slice (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht) — hier gibt es sie nicht: kein Bündel, kein gemeinsames Closure-Kriterium, kein
repo-weiter Beleg über die DoD hinaus. Seit
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
trägt diese Frage die Baseline selbst; die dritte Frage *reaktiv oder gewollt* ist dort
ausdrücklich **entfallen** und wird hier deshalb nicht gestellt.

**Mitglied von [welle-15](../welle-15-re-baseline.md) ist dieser Slice nicht — und das ist keine
Auslegung, sondern zitierbar:** deren §6 *Out-of-Scope* nennt den d-check-Pin namentlich
(*„eigene Linie, eigener Trigger; er hängt an keiner Baseline-Version"*). Die Zeile nennt dabei
[slice-135](slice-135-d-check-pin-v0661.md) als den Slice dieser Linie; dieser hier tritt an
dessen Stelle (§1 *Was mit slice-135 geschieht*), der Ausschluss gilt unverändert für beide.
Wellenlose Arbeit erscheint nicht in der Roadmap; ihr Zustand ist die Verzeichnis-Position.

**Ebene: Dogfood und emittiert zugleich.** Der lebende Pin steht in
[`d-check.mk`](../../../../d-check.mk), daran gekoppelt der **emittierte** Default in
[`internal/emit/emit.go`](../../../../internal/emit/emit.go); zwei go-Tests halten beide zusammen.
Die emittierte Modul-Liste bleibt unberührt
([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) —
dieser Slice bewegt eine Versions-Referenz, keine Prüfbereichs-Entscheidung.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Digest-Pin ist die
Reproduzierbarkeits-Zusage; ein Tag allein ist keine),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Target-Aufzählung aus
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 2 bewegt sich mit diesem Sprung — **zwölf → dreizehn**, §1 Messung 3),
[`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
§Auflösungs-Trigger (der Satz, der diesen Slice auslöst, samt der Auflage, die Strenge-Bilanz an
der **Quell-Differenz** zu ziehen),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(das Muster *„Trockenlauf vor dem Pin, Pflicht und belegt"*),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(die vier Handgriffe der Re-Adaption des tool-generierten Fragments),
[`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)
und
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)
(dieselbe Linie, frühere Sprünge),
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
(das Muster *verfügbar, nicht aktiviert* — hier auf drei neue Fähigkeiten anzuwenden),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben dem Kommando, das genau sie liefert),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (Senkung ⇒ ADR — die Frage, die die Bilanz beantworten
muss, statt sie am grünen Trockenlauf vorbeizuwinken),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — der Kopf des
Fragments spricht im Präsens über den gepinnten Stand).

**Berührte Spec-Stellen:** `—`. Der Pin ist eine Versions-Referenz auf ein Fremd-Werkzeug; welche
Module das Doku-Gate fährt, entscheidet [`.d-check.yml`](../../../../.d-check.yml), und die bleibt
unangetastet (§3). Der Verweis zeigt ohnehin **aufwärts**: die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** `—` bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-05.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der gepinnte d-check steht auf `v0.74.1`, das tool-generierte Fragment ist gegen eine frische
Ausgabe re-adaptiert statt nachgebessert, und die Strenge-Bilanz über neun Minors ist an der
Quell-Differenz **und** an einer Nicht-Null-Basis gezogen. Geerbt wird nichts.**

### Der Anlass, gemessen

`make freshness-dcheck` meldet einen neueren Tag als `DCHECK_TAG`. Heute steht in
[`d-check.mk`](../../../../d-check.mk) `DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.65.0` mit
`DCHECK_DIGEST ?= sha256:5ea03abe…41288`; der neueste Release ist `v0.74.1`.

**Die Spanne ist die zweitgrößte dieser Linie und der eigentliche Kostentreiber.** Auf den
gepinnten Stand folgen **zwölf** Tags — neun Minors, dazu zwei Patch-Releases und der bekannte tote
Tag `v0.66.0`. Gezählt am lokalen Klon `/Development/d-check` mit
`git for-each-ref --sort=v:refname --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.6[5-9]*' 'refs/tags/v0.7[0-9].*'`;
die Ausgabe spannt `v0.65.0` (2026-08-28) bis `v0.74.1` (2026-09-04). **Keine Erwartungswerte** —
die Zahl wächst mit jedem Upstream-Release
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Nur [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
war größer (elf Minors); der Sprung davor,
[`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt),
maß drei.

### Sechs Messungen, jede neben ihrem Kommando

Alle in diesem Planungslauf gefahren, am 2026-09-05, netzlos gegen den Baum (`--network none`,
Mount `:ro`); der Klon des Werkzeugs unter `/Development/d-check` ist eine **Fremdquelle** und kein
Artefakt dieses Repos (§6). Die Registry-Abfragen brauchen Netz und liegen außerhalb von
`make gates`.

1. **Der Digest ist dreifach belegt, und alle drei Beine sind hier gefahren.**
   `sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641` — aus der Registry
   (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.74.1`, Zeile `Digest:`), aus dem
   lokalen Bestand
   (`docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/pt9912/d-check:v0.74.1`) und
   als **Fremdquelle** aus dem Benutzerhandbuch des Werkzeugs
   (`grep -rn 'e31a372b' /Development/d-check --include='*.md'` → **1** Zeile, der Pin-Block des
   Handbuchs). Drei Wege, ein Wert
   ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
2. **Der Trockenlauf vor dem Pin zeigt eine Differenz von null Befunden.** `make docs-check`
   (gepinnt) und `make docs-check DCHECK_DIGEST=sha256:e31a372b…4641` über denselben unveränderten
   Baum mit unveränderter [`.d-check.yml`](../../../../.d-check.yml): beide
   `d-check: 775 Datei(en) geprüft, 0 Befund(e)`, beide Exit 0; `diff` der zwei Ausgaben führt
   **genau eine** Zeile — das von `make` mitgeschriebene `docker run`, in dem der Digest steht.
   **Weder die 775 noch die 0 sind Erwartungswerte** — die Dateizahl wächst mit jedem Dokument.
   Tragend ist die **Gleichheit** der zwei Ausgaben.
3. **Das Fragment ändert sich in acht Zeilen, nicht in einer — und das ist der Unterschied zu den
   zwei Vorgänger-Sprüngen.** `--print-mk` unter beiden Digests, netzlos: **68** gegen **76** Zeilen
   (`wc -l`). `diff` der zwei Ausgaben führt vier Blöcke: (a) vier neue Kopf-Kommentarzeilen mit
   den zwei Handbuch-URLs, (b) je `--disable workflows --disable reviews` in **sechs** fokussierten
   advisory-Recipes, (c) das neue Target `doc-usage` (`--help`), (d) die `DCHECK_IMAGE`-Zeile.
   **Die Target-Zahl bewegt sich damit: `grep -cE '^docs?-[a-z-]+:'` liefert 12 über die
   `v0.65.0`-Ausgabe und über [`d-check.mk`](../../../../d-check.mk), aber 13 über die
   `v0.74.1`-Ausgabe.** Die Aufzählung in
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 2 nennt heute *zwölf* und wird durch diesen Sprung falsch — sie ist Architect-Eigentum
   und steht als Übergabe in §6.
4. **Die fünf Anker, an denen `AdaptMK` hängt, tragen unverändert.** Der Auflösungs-Trigger von
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   verlangt je Re-Pin ihre Prüfung. Über der frischen `v0.74.1`-Ausgabe liefern
   `grep -cF 'DCHECK_IMAGE ?='` sowie `grep -c` für `^\.PHONY: doc-check$`, `^doc-check:` und
   `^DCHECK_DIGEST ?=$` **viermal 1** — dieselben vier Kommandos über
   `internal/emit/testdata/raw-print-mk.txt` ebenfalls **viermal 1**. Die Fixture friert eine
   ältere Ausgabe ein (`wc -l` → **64** gegen **76**); nachzuziehen wäre sie erst, wenn ein Anker
   fehlt. **Ihre Zeilenzahl ist kein Kriterium**, und die fünfte Zählung (`^doc-[a-z-]+:` → 13
   gegen 11) ist genau darum keiner: sie misst den Umfang, nicht die Verankerung.
5. **Strenge-Bilanz an der Quell-Differenz: null bewegte Zeilen an allen sechs aktiven
   Regeldateien.** Aktiv sind sechs Module (`grep -m1 '^modules:' .d-check.yml` →
   `links, anchors, ids, matrix, codepaths, spans`). Am Klon gibt
   `git diff --numstat v0.65.0..v0.74.1 -- internal/hexagon/core/rules/{links,anchors,ids,matrix,codepaths,spans}.go`
   **keine** Zeile aus. **Das ist gegen ein falsches Negativ geprüft**, statt aus der leeren
   Ausgabe geschlossen zu werden: `git ls-tree --name-only v0.65.0 internal/hexagon/core/rules/`
   und dasselbe mit `v0.74.1` führen alle sechs Dateien unter genau diesen Pfaden — eine
   Umbenennung, die dieselbe leere Ausgabe erzeugt hätte, liegt nicht vor.
   **Die Reichweite dieser Messung endet an den Regeldateien, und das ist ihre benannte Grenze:**
   `git diff --numstat v0.65.0..v0.74.1 -- 'internal/**/*.go'` führt daneben geteilte
   Infrastruktur, die jedes Modul durchläuft, und **auch sie verliert Zeilen** —
   `markdown.go` **+14/−9**, `sections.go` **+3/−2**, `run.go` **+11/−4**, `model/config.go`
   **+209/−12**, `model/finding.go` **+32/−2**, `configyaml.go` **+318/−22** und
   `app/trace_table.go` **+3/−103**. Zwei davon sind hier aufgelöst statt beschwiegen:
   Der **−103**-Block in `trace_table.go` ist ein reiner **Umzug** — `splitPipeTableLine` wandert
   als exportiertes `rules.SplitPipeTableLine` eine Ebene tiefer, die Aufrufstellen daneben zeigen
   auf denselben Namen. Und die einzige inhaltlich geänderte Funktion in `markdown.go`,
   `tableCells`, hat unter den sechs aktiven Modulen **keinen** Aufrufer:
   `git grep -n 'tableCells(' v0.74.1 -- 'internal/**/*.go' ':!*_test.go'` nennt neben der
   Definition `planning_waves.go`, `structure_tablecell.go` und `structure_tableorder.go` — drei
   Dateien aus **nicht adoptierten** Modulen.
6. **Die Gegenrichtung, auf einer Nicht-Null-Basis gemessen — und sie hat etwas gefunden, das der
   Trockenlauf nicht zeigen konnte.** Kopie des Baums außerhalb des Repos (`git archive HEAD`),
   alle Marker in getracktem Markdown außerhalb der vendored Baseline entwertet
   (`find . -name '*.md' -not -path './.harness/baseline/*' -exec sed -i 's/d-check:ignore/d-check:IGNORIERT-NICHT/g' -- {} +`;
   **172** Dateien mit **331** Marker-Zeilen vorher, Restzähler danach **0**), dann beide Digests:
   **beide** melden `d-check: 779 Datei(en) geprüft, 85 Befund(e)`, Exit 1, und die Befundmenge ist
   je Datei, Zeile, Ziel und Grund-Code **identisch** — `15` `codepath-missing`, `38` `id-unlinked`,
   `32` `target-missing` auf beiden Seiten. **Auf einer Basis, auf der ein Wegfall sichtbar geworden
   wäre, fällt nichts weg.** Tragend ist die Gleichheit der zwei Mengen, nicht die Datei- oder
   Befundzahl.
   **Der Fund liegt daneben, in der Ausgabe-Form:** `v0.74.1` hängt jeder Befund-Zeile eine
   **vierte, tab-getrennte Spalte** an — den Klartext des Grundes (`target-missing` →
   *„Linkziel existiert nicht"*). Über dem realen Baum mit **0** Befunden ist diese Änderung
   unsichtbar; sie wird erst auf einer Nicht-Null-Basis beobachtbar. Ein Leser, der die letzte
   Spalte als Grund-Code nimmt (`awk -F'\t' '{print $NF}'` — die Form, die
   [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
   für seine Klassen-Bilanz benutzt), bekommt ab diesem Pin den Klartext statt des Codes.

### Was der Trockenlauf trägt, und was nicht

Er trägt **eine** Richtung: über diesem Korpus entsteht kein neuer Befund. In der Gegenrichtung ist
er über einer **0**-Befund-Basis **informationsleer** — eine weggefallene Befundklasse erzeugt
dieselbe Ausgabe wie eine unveränderte. Diese Gegenrichtung tragen hier Messung 5 (an der Quelle)
und Messung 6 (am Verhalten auf einer Basis, die den Wegfall zeigen könnte). Messung 6 ist deshalb
**nicht optional**, obwohl der Auflösungs-Trigger von
[`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
sie wörtlich an *„wo ein aktives Modul Zeilen verliert"* knüpft und diese Bedingung über die Spanne
nicht erfüllt ist: geteilte Infrastruktur verliert Zeilen (Messung 5), und eine Bedingung, die auf
die Regeldateien zeigt, ist die **Untergrenze** der Frage, nicht ihre Antwort. Dass Messung 6 dann
die Spalten-Änderung fand, ist der Beleg dafür, dass sie nicht Zeremonie ist.

### Kein Breaking Change trifft diesen Baum — und das ist gemessen, nicht gelesen

Der CHANGELOG des Werkzeugs weist über die Spanne **einen** Breaking Change aus (`[0.66.1]`: die
tabellenbezogenen `structure`-Schlüssel ziehen unter `table.*` um, Vorgänger-Schlüssel brechen mit
Exit 2) und **eine** ausdrückliche Lockerung (`[0.69.0]`: `structure`s
`exempt-section-pattern`-Zähler verkleinert eine erklärte Menge). Beide liegen in `structure`,
einem hier **nicht aktivierten** Modul; dazu entfällt in `[0.67.0]` ein Grund-Code des ebenfalls
nicht aktivierten `workflows`. Gemessen statt geglaubt: `grep -c 'structure' .d-check.yml` → **0**
(Exit 1), und Messung 2 bestätigt am Verhalten, dass die geltende Config unter dem neuen Digest
ohne Exit 2 durchläuft. **Die Aufzählung ist bestätigend, nicht tragend** — upstream weist sie
selbst als offen aus; tragend sind Messung 5 und 6
([`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
§Welches der zwei Beine die Bilanz trägt).

### Drei Fähigkeiten werden verfügbar — keine wird hier aktiviert

Dieselbe Trennung, die
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) im
Titel führt: *verfügbar*, nicht *aktiv*. Eine Modul- oder Bedingungs-Aktivierung ist ein
**Anheben** und geht über den Steering-Loop
([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
also über einen eigenen Schnitt mit eigener Config-Entscheidung und eigenem Trockenlauf.

- **Das Modul `workflows`** (21.) und **`reviews`** (22.) — der Modulsatz wächst von 20 auf 22,
  abzählbar an den `--disable`-Namen der generierten Recipes
  (`grep -oE '\-\-disable [a-z]+' <ausgabe> | sort -u | wc -l` → **20** gegen **22**).
- **`planning.observations.dir`** (`[0.74.0]`), und diese Fähigkeit ist die bemerkenswerte:
  Sie prüft die Register-Deckung gegen eine **Verzeichnis-Ablage** — eine zitierte Kennung
  `<pfad>` gilt als nachgewiesen, wenn `<observations.dir>/<pfad>/observation.md` existiert.
  Das ist genau die Form, die dieses Repo seit dem Umzug nach
  [`observations/`](../observations/README.md) führt, und genau die maschinelle Hälfte der
  Register-Paarung (c), die Modul 6 verlangt und für die
  `BEO-ALL/register-paarung-ohne-gate-modul` festhält, sie habe *„in keinem gepinnten
  Doku-Gate-Stand ein Modul"*. **Mit diesem Pin hat sie eines** — im Bild, nicht in `modules:`.
  Was daraus folgt, entscheidet der Aktivierungs-Schnitt und der Ausgang jener Beobachtung, nicht
  dieser Slice (§6).

### Was mit slice-135 geschieht

[slice-135](slice-135-d-check-pin-v0661.md) liegt in `open/` und zieht den Pin auf **`v0.66.1`** —
einen Stand, den acht weitere Minors überholt haben. Sein Gegenstand ist der dieses Slice: Die
Pin-Linie trägt **einen** lebenden Pin, zwei offene Pläne können ihn nicht beide bewegen, und wer
`v0.66.1` pinnte, ließe `make freshness-dcheck` im selben Moment wieder rot. Dieser Slice tritt
deshalb an seine Stelle; slice-135 bekommt einen Zeiger hierher und bleibt als Datei liegen.

**Gelöscht wird er nicht, und der Grund ist eine benannte Lücke statt einer Vorliebe:** Für das
Entfernen einer Plandatei gibt es keine normative Grundlage — Modul 5 kennt vier Verzeichnisse und
keinen Zustand *zurückgezogen*, und der Bestand an früheren `git rm` ist Bestand, keine Norm.
Die Lücke steht als Risiko in §6 mit Übergabe.

**Seine Messungen sind damit nicht wertlos, aber auch nicht übernehmbar:** sie sind über
`v0.65.0..v0.66.1` gezogen, eine echte Teilmenge dieser Spanne, und über einen Baum vom
2026-08-29. Übernommen wird hier **keine** Zahl aus ihm; alle sechs Messungen oben sind in diesem
Lauf neu gefahren.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Der Pin steht auf `v0.74.1`, dreifach belegt, und der emittierte Default zieht mit.**
      Beide gekoppelten Stellen — [`d-check.mk`](../../../../d-check.mk) und
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) — tragen Tag und Digest
      zeichengleich; der Digest ist **vor** dem Pin über die drei Beine aus §1 Messung 1 neu
      belegt, nicht aus diesem Plan abgeschrieben.
      **Rot:** nur [`d-check.mk`](../../../../d-check.mk) bewegen und
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) stehen lassen → `make test`
      fällt mit `--- FAIL:` an `TestDefaultImage_MatchesCanonical` und
      `TestDefaultDigest_MatchesCanonical`. Dieser Lauf gehört **gesehen** und seine Meldung
      **gelesen** — sie nennt die zwei Zeichenketten, die auseinanderlaufen.
- [ ] **(2) Das Fragment ist gegen eine frische `v0.74.1`-Ausgabe re-adaptiert, nicht
      nachgebessert — die vier Handgriffe erneut angewandt, der Rest verbatim übernommen.**
      Das ist der Punkt, der diesen Sprung von den zwei Vorgängern unterscheidet: Das Tool liefert
      **acht** Zeilen mehr (§1 Messung 3), darunter ein neues Target und sechs veränderte Recipes.
      Wer nur die zwei Wertzeilen tauscht, hat ein Fragment, das vorgibt, aus `v0.74.1` abgeleitet
      zu sein, und aus `v0.65.0` stammt.
      **Rot, mit gemessenem Gegenstück:** `diff <(docker run --rm --network none <v0.74.1-digest>
      --print-mk) d-check.mk | grep -c '^[0-9]'` muss **4** liefern — genau die vier Handgriffe aus
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 1. **Heute liefert dieselbe Zeile 9**, und gegen die `v0.65.0`-Ausgabe liefert sie
      **4**; die 4 ist damit kein Erwartungswert aus der Erinnerung, sondern ein Kriterium, dessen
      Ist-Wert vor und nach dem Handgriff gemessen ist. Bleibt sie bei 9 oder steht sie bei 5, ist
      verbatim-Inhalt verlorengegangen oder ein Handgriff doppelt angewandt.
- [ ] **(3) Der Kopf von [`d-check.mk`](../../../../d-check.mk) sagt, was der gepinnte Stand tut —
      an einer eigenen Sonde gemessen, nicht vom Vorgänger geerbt.** **Zehn** Stellen nennen heute
      den alten Stand (`grep -c 'v0\.65\.0\|5ea03abe' d-check.mk` → **10**). Die Sonden-Tabelle der
      Marker-Semantik ist über **`v0.74.1`** neu zu messen; die Vorgänger-Spanne `v0.62.0` →
      `v0.65.0` steht danach nicht mehr im Kopf, denn sie ist Gegenstand des Adaptions-Eintrags und
      nicht des Kopfes ([`AGENTS.md`](../../../../AGENTS.md) §3.7: die vorige Fassung hält `git`).
      **Und der Kopf bekommt eine Aussage dazu, die er heute nicht trägt:** dass die Befund-Zeile
      unter diesem Stand eine **vierte** Spalte führt (§1 Messung 6) — eine Zusage an den, der eine
      Ausgabe zerlegt.
      **Rot, zwei Formen:** (a) `grep -c 'v0\.65\.0\|5ea03abe\|v0\.62\.0' d-check.mk` liefert mehr
      als **0**, während `DCHECK_IMAGE` `v0.74.1` sagt — dann behauptet der Kopf einen Stand, der
      nicht gepinnt ist; (b) die Sonde selbst: ein `d-check:ignore` in blanker Prosa über einem
      echten Befund wird unter `v0.74.1` **unterdrückt** statt gemeldet — dann ist die Tabelle
      abgeschrieben statt gemessen.
- [ ] `make gates` grün — heute ist es das (§1 Messung 2, `0 Befund(e)`, Exit 0), und dieser Slice
      darf es nicht kippen. Der Punkt sagt hier bewusst *grün* und nicht *ohne neuen Befund*: Die
      Basis ist null, jede Abweichung ist ein Zugang.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist. Berührt ist keiner: Der Pin ist eine
      Versions-Referenz, und die Gate-Namen in [`AGENTS.md`](../../../../AGENTS.md) §4 und
      [`harness/README.md`](../../../../harness/README.md) bewegen sich nicht — `docs-check` bleibt
      der einzige behauptete Gate, `doc-usage` ist advisory. Die Target-**Zahl** bewegt sich
      (§1 Messung 3); sie steht in
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 2 und damit in Architect-Eigentum (§6 Übergabe 2), nicht in einer der zwei
      Doku-Dateien — gemessen mit
      `grep -rn 'doc-help\|doc-structure\|doc-trace' harness/README.md docs/user/*.md`, das über
      diesen Dateien keinen Target-Namen findet.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb ([welle-15](../welle-15-re-baseline.md) liegt flach), sie werden also von der
      nächsten Welle-Closure geprüft und nicht hier, auch für Slices ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | der lebende Pin (`DCHECK_IMAGE` + `DCHECK_DIGEST`), der Adopter-Kopf **und** der verbatim-Teil. Anders als bei den zwei Vorgänger-Sprüngen ist der verbatim-Teil betroffen: sechs advisory-Recipes bekommen `--disable workflows --disable reviews`, ein dreizehntes Target `doc-usage` kommt hinzu, vier Kopf-Kommentarzeilen mit Handbuch-URLs (§1 Messung 3). Der Weg ist **Neu-Erzeugen und die vier Handgriffe erneut anwenden**, nicht Nachbessern (DoD (2)). Dazu die **zehn** Kopf-Stellen, die den alten Stand nennen (`grep -c 'v0\.65\.0\|5ea03abe' d-check.mk` → **10**), und die Sonden-Tabelle, die zu **messen** und nicht umzuschreiben ist (DoD (3)) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | `DefaultImage`/`DefaultDigest` — Tier-1-Drift; die zwei go-Tests koppeln beide Stellen und färben DoD (1) rot |
| [`Makefile`](../../../../Makefile) | update | das Tag-Beispiel im Kommentar über `DCHECK_TAG` (`grep -n 'v0\.65\.0' Makefile` → **eine** Zeile) — dieselbe Stelle, die [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) und [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) bei den Vorgänger-Sprüngen nachzogen |
| [slice-135](slice-135-d-check-pin-v0661.md) | update | Zeiger auf diesen Slice, weil seine Ziel-Version überholt ist und die Linie **einen** lebenden Pin trägt (§1 *Was mit slice-135 geschieht*). Planner-Eigentum, keine fremde Rolle berührt. **Nicht** gelöscht — dafür fehlt die Norm (§6) |
| [`harness/conventions.md`](../../../../harness/conventions.md) und `harness/conventions/` | **nicht durch diesen Slice** | Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der neue Adaptions-Eintrag, die Fortschreibung von §Baseline und die **Korrektur der Target-Zahl** in [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2 entstehen im Architect-Lauf; dieser Slice liefert die **Messungen** als Übergabe-Artefakt (§6) |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | der Pin bewegt keine Modul-Liste und keinen Prüfbereich. Wer hier `workflows`, `reviews` oder `planning.observations.dir` einträgt, aktiviert eine Fähigkeit — das ist ein eigener Schnitt (§1 *Drei Fähigkeiten*) |
| [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) | **unverändert** | die emittierte Starter-Config bleibt `modules: [links, anchors]` ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)); der eine Breaking Change der Spanne trifft `structure` und damit weder diese noch die lebende Config (§1 *Kein Breaking Change*) |
| `internal/emit/testdata/raw-print-mk.txt` | **unverändert** | die vier Anker, an denen `AdaptMK` hängt, stehen in der frischen `v0.74.1`-Ausgabe je genau einmal (§1 Messung 4). Nachzuziehen wäre die Fixture erst, wenn einer fehlt — ihre Zeilenzahl ist kein Kriterium |
| `docs/reviews/**`, `docs/plan/planning/done/**` | **unangetastet** | Zeitdokumente; sie frieren den Stand ihres Laufs ein. Die Nennungen von `v0.65.0` darin sind wahr über ihren Gegenstand |
| Roadmap | **keine Zeile** | wellenlose Arbeit wird dort nicht geführt; ihr Zustand ist die Verzeichnis-Position (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **das WIP-Limit von 1 ist frei** —
`ls docs/plan/planning/in-progress/ | grep -c '^slice-'` liefert **0**. Am 2026-09-05 liefert es
**1**, den laufenden [slice-177](../in-progress/slice-177-beobachtungs-register-verzeichnis-form.md);
das WIP-Limit ist eine harte Größe und kein Vorschlag. Eine inhaltliche Vorbedingung hat
dieser Slice **nicht**: Die Auslöse-Bedingung ist heute erfüllt (`make freshness-dcheck`, §1), alle
sechs Messungen aus §1 sind gefahren, und keine wartet auf ein fremdes Artefakt. Insbesondere
wartet er **nicht** auf [welle-15](../welle-15-re-baseline.md): Deren §6 schließt diese Linie
ausdrücklich aus, die zwei berühren einander in keinem Gegenstand.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Re-Adaption aus DoD (2) führt nicht
  auf **4** Hunks, weil das Tool im verbatim-Teil mehr verändert hat, als die vier Handgriffe
  auffangen — dann ist der Pin eine Sache und die Fragment-Neuordnung eine zweite, zwei Schnitte
  statt eines vierten DoD-Punktes. Ebenso, wenn die Sonde aus DoD (3) zeigt, dass sich die
  Marker-Semantik über die Spanne bewegt hat und ein Marker im Bestand betroffen ist: dann ist die
  Marker-Bereinigung ein eigener Schnitt.
- `in-progress` → `open` (blockiert — Carveout?): Die Strenge-Bilanz findet an einem der sechs
  aktiven Module doch eine **Senkung** — etwa weil die Gegenmessung aus §1 Messung 6 auf dem
  Umsetzungs-Baum eine Differenz liefert, die heute nicht besteht. Dann verlangt
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 einen ADR, und den schreibt der Architect — der Slice
  blockiert an einer fremden Rolle und geht zurück, statt die ADR nebenbei mitzunehmen. Ein
  **Carveout** entsteht dabei nicht: Er nimmt ein Gate aus, und hier ist keines auszunehmen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **`make freshness-dcheck` endet mit 0** (der Pin hat den Release
eingeholt — dasselbe Kommando, das den Slice ausgelöst hat), und **`make docs-check` meldet
`0 Befund(e)` bei Exit 0** (derselbe Befundbestand wie §1 Messung 2 — kein Befund kommt hinzu).
Dazu: DoD (1) bis (3) erfüllt mit gefahrenen Kommandos und gelesenen Meldungen, `make gates` grün,
`make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden
Befund, Closure-Notiz in §7 mit Steering-Loop-Lerneintrag und der **Übergabe an den Architect**
(§6).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Sprungweite ist der Kostentreiber, und sie trifft diesmal den verbatim-Teil.** Neun
  Minors haben ein Fragment erzeugt, das in acht Zeilen von dem abweicht, gegen das
  [`d-check.mk`](../../../../d-check.mk) adaptiert ist (§1 Messung 3) — bei den zwei
  Vorgänger-Sprüngen war es **eine**. Wer den Sprung wie jene behandelt und nur die zwei
  Wertzeilen tauscht, verliert das neue Target und sechs Recipe-Zeilen, ohne dass ein Gate es
  meldet: Kein Modul dieses Repos hält das Fragment gegen die Tool-Ausgabe. — **Ausgang:**
  <entfallen: DoD (2) misst die Hunk-Zahl gegen eine frische Ausgabe und färbt bei 9 statt 4 rot |
  eingetreten: Folge-Slice für die Fragment-Neuordnung, §4 Rückführung 1>
- **Die leere Quell-Differenz ist die verführerischste Messung dieses Slice.** *„Keine der sechs
  aktiven Regeldateien bewegt eine Zeile"* liest sich wie ein Freispruch und ist nur eine
  Untergrenze: Die Bilanz ist über **Dateien** gezogen, während die Frage über **Verhalten** geht,
  und geteilte Infrastruktur hat sich in sieben Dateien bewegt (§1 Messung 5). — **Ausgang:**
  <entfallen: die Gegenmessung auf Nicht-Null-Basis aus §1 Messung 6 liefert identische
  Befundmengen und ist im Umsetzungs-Lauf zu wiederholen | eingetreten: sie liefert eine Differenz,
  und §4 Rückführung 2 greift>
- **Die vierte Ausgabe-Spalte ist gemessen, aber nicht bewacht.** Ab diesem Pin trägt jede
  Befund-Zeile den Grund zusätzlich im Klartext (§1 Messung 6). Kein Skript dieses Repos zerlegt
  heute eine d-check-Befund-Zeile spaltenweise — gemessen: `test/ignore-refs-restbreite.bats` liest
  die **Config** und nicht die Ausgabe, und `harness/tools/full-smoke.sh` prüft mit
  `grep -qF -- "geprüft"` die **Summen**-Zeile, deren Form sich nicht bewegt. Die Zusage gilt für
  den heutigen Bestand; wer künftig `$NF` als Grund-Code liest, liest den Klartext. — **Ausgang:**
  <entfallen: der Kopf von [`d-check.mk`](../../../../d-check.mk) sagt es zu, DoD (3) | eingetreten:
  Folge-Slice, wenn ein Leser der Spalten-Form entsteht>
- **`BEO-ALL/register-paarung-ohne-gate-modul` wird durch diesen Slice in seiner Tatsachen-Basis
  überholt.** Der Eintrag steht bei **1×** und hält fest, die maschinelle Hälfte der
  Register-Paarung habe *„in keinem gepinnten Doku-Gate-Stand ein Modul"*. Nach diesem Pin hat sie
  eines (`planning.observations.dir`, §1 *Drei Fähigkeiten*) — im Bild, nicht in `modules:`. Der
  Satz wird damit als geschriebener falsch, während die **Deckung** unverändert fehlt.
  `observation.md` ist ab Anlage unveränderlich; bewegt werden darf nur `state.md`. — **Ausgang:**
  <weiter offen: der Eintrag bleibt im Register, sein Stand wird in der Closure gegen den neuen
  Sachverhalt geprüft | eingetreten: Folge-Slice für die Aktivierungs-Entscheidung, die ein
  **Anheben** ist und über den Steering-Loop läuft>
- **Ein überholter offener Plan hat keinen Ausgang, den eine Norm nennt.**
  [slice-135](slice-135-d-check-pin-v0661.md) zeigt die Klasse: ein Plan wartet in `open/` über
  Versions-Sprünge hinweg, und der Sprung ändert die Pflicht, die er halten soll. Modul 5 kennt
  vier Verzeichnisse und keinen Zustand *zurückgezogen*; für das Entfernen einer Plandatei gibt es
  keine normative Grundlage, und der Bestand an früheren `git rm` ist Bestand, keine Norm. Dieser
  Slice behilft sich mit einem Zeiger (§3) — das ist eine Handlung ohne Regel.
  **Der Nachbar im Register ist gesichtet und nicht vereinnahmt:**
  `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` steht bei **2×** und benennt
  denselben Mechanismus, aber ausdrücklich über einen **Baseline**-Sprung; die d-check-Linie ist
  laut [welle-15](../welle-15-re-baseline.md) §6 eine andere. Ob das eine dritte Gelegenheit
  desselben Eintrags ist — dann Schwelle — oder eine eigene Beobachtung über zu enge Fassung, ist
  das Urteil der Closure und keines dieses Plans. — **Ausgang:** <weiter offen: als Beleg in einen
  der zwei Einträge, entschieden bei der Closure | eingetreten: Folge-Slice, der den Ausgang eines
  überholten offenen Plans normiert>
- **Der Pin trägt einen Grund, den kein Sensor dieses Repos kennt.** `make freshness-dcheck` sagt
  *„ein neuer Tag ist da"*, nicht *„der gepinnte ist verwundbar"*; kein Gate scannt das gepinnte
  Fremd-Image. `[0.74.1]` ist ein reiner Security-Release (zwei behebbare CVEs in
  `golang.org/x/crypto`, **Fremdquelle** CHANGELOG des Klons, hier nicht nachgemessen), und
  `[0.65.0]` war es vor ihm. Die Klasse ist bereits einmal aufgefallen
  ([slice-122](../done/slice-122-d-check-pin-v0650.md) §6) und mit diesem Slice nicht geschlossen.
  — **Ausgang:** <weiter offen: als Kandidat notiert, ohne eigenen Schnitt in diesem Lauf |
  eingetreten: Folge-Slice>
- **Der Rang-Zeiger bleibt nach diesem Slice halb.** Zeile 2 des Kopfes nennt nach DoD (3) die
  richtige **Version**, aber weiter nur die Einträge der Vorgänger-Sprünge — der Eintrag zu diesem
  hier existiert zum Umsetzungs-Zeitpunkt nicht (Übergabe 1). Das ist eine echte
  Reihenfolge-Abhängigkeit an einer fremden Rolle, keine Auslassung, und sie darf den Pin nicht
  aufhalten. — **Ausgang:** <entfallen: der Architect-Lauf liegt vor dem Umsetzungs-Lauf und der
  Zeiger nennt den Eintrag sofort | eingetreten: Folge-Slice nach dem Muster von
  [slice-128](../done/slice-128-d-check-kopf-sagt-was-gilt.md)>

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8 — vier Posten, keiner hier geschrieben)

Der Adaptions-Block ist Architect-Eigentum; dieser Slice liefert **Messungen**, keinen Regeltext.

1. **Ein neuer Adaptions-Eintrag zum `v0.65.0` → `v0.74.1`-Sprung**, nach dem Muster von
   [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) und
   [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt).
   Was er zu tragen hat, liefert §1: Digest mit drei Beinen · Trockenlauf als 0-Differenz auf einer
   0-Befund-Basis samt dem Satz, was er **nicht** zeigt · Fragment-Diff über acht Zeilen mit
   Target-Zahl **12 → 13** · Strenge-Bilanz als **leere** Regeldatei-Differenz mit ihrer benannten
   Grenze und der Prüfung gegen das falsche Negativ · Gegenmessung auf Nicht-Null-Basis mit
   identischer Befundmenge · die **vierte Ausgabe-Spalte** als Verhaltensänderung, die nur diese
   Gegenmessung sichtbar macht.
2. **Die Target-Zahl in
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 2 wird durch diesen Sprung falsch.** Sie nennt heute *zwölf* mit dem Kommando
   `grep -cE '^docs?-[a-z-]+:' d-check.mk`; nach dem Pin liefert dasselbe Kommando **13**
   (§1 Messung 3). Denselben Nachzug hat
   [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
   schon einmal geleistet (elf → zwölf). **Das ist kein optionaler Posten:** Er ist die Bedingung
   dafür, dass die Aufzählung nach dem Umsetzungs-Commit noch stimmt.
3. **Die §Baseline-Zeile führt die Sprung-Einträge auf und wächst mit diesem hier.** Sie trägt
   ausdrücklich **keine** zweite Fassung der Version, sondern zeigt auf den lebenden Ort; zu
   ergänzen ist allein die Aufzählung der Einträge. Ein Zeilen-Bereich steht hier bewusst nicht —
   er wandert mit jeder Architect-Änderung an derselben Datei.
4. **Drei Fähigkeiten sind ab diesem Pin verfügbar und nicht adoptiert** (§1). Ob der neue Eintrag
   sie so nennt — *verfügbar*, nicht *aktiv*, die Lage aus
   [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) —,
   entscheidet der Architect-Lauf. Für `planning.observations.dir` kommt eine zweite Frage dazu,
   die dieser Slice nicht beantwortet: Sie berührt den Stand von
   `BEO-ALL/register-paarung-ohne-gate-modul`, und ein Register-Stand ist kein Adaptions-Eintrag.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **`*` (gesamtes Repo)**. Die
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt
**drei** Sub-Areas — `*` (`ALL`), `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) —, und keine
der Dateien aus §3 liegt unter den zwei engeren: [`d-check.mk`](../../../../d-check.mk),
[`Makefile`](../../../../Makefile) und [`internal/emit/`](../../../../internal/emit/) fallen
sämtlich unter `*`. **Eine feinere Wahl wäre hier eine Erfindung, keine Ausdifferenzierung:** Wer
*„Gate-Fragment"* und *„Emitter"* als eigene Sub-Areas führt, nennt Namen, die die Deklaration
nicht kennt — und nach Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register ist dann
*„entweder die Zuordnung falsch oder die Deklaration unvollständig"*. Welche der beiden, entscheidet
der Architect, dem die Deklaration gehört ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice
bleibt bei der deklarierten Sub-Area und benennt die Frage, statt sie durch Praxis zu beantworten.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
vollständig durchgegangen (**41** Verzeichnisse unter `BEO-ALL/`,
`find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d | wc -l`; **kein
Erwartungswert**). **Jede** Beobachtung trägt dieselbe Sub-Area `*` — die Zuordnung unterscheidet
in diesem Repo nichts, was der Eintrag `BEO-ALL/sub-area-spalte-unterscheidet-nichts` selbst
festhält; die Auswahl unten ist deshalb **inhaltlich** getroffen und nicht über die Sub-Area.
**Vier Einträge berühren diesen Slice, keiner erreicht mit ihm 3×** (Zähler abgeleitet aus
`ls <eintrag>/evidence | wc -l`):

- `BEO-ALL/register-paarung-ohne-gate-modul` (**1×**, `slice-137`, Stand `offen`) — *die maschinelle
  Hälfte der Register-Paarung hat in keinem gepinnten Doku-Gate-Stand ein Modul*. Dieser Slice
  ändert die **Tatsachen-Basis** des Eintrags, ohne die Lücke zu schließen: `v0.74.0` liefert
  `planning.observations.dir` genau für die Verzeichnis-Form dieses Repos, verfügbar und nicht
  aktiviert (§1 *Drei Fähigkeiten*). Steht als Risiko in §6.
- `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` (**2×**, `slice-160`,
  `slice-176`, Stand `offen`) — *ein Plan wartet in `open/` über einen Sprung hinweg, und der
  Sprung ändert die Pflicht, die er halten soll*. [slice-135](slice-135-d-check-pin-v0661.md) ist
  genau dieser Fall, **aber auf einer anderen Linie**: Der Eintrag sagt *Baseline*-Sprung, und
  [welle-15](../welle-15-re-baseline.md) §6 trennt die d-check-Linie ausdrücklich davon. **Deshalb
  zählt dieser Slice hier nicht selbsttätig hoch** — die Frage, ob die Fassung des Eintrags zu eng
  ist oder eine zweite Beobachtung vorliegt, ist Urteil und gehört in die Closure (§6). Wäre sie
  mit *ja* beantwortet, stünde der Eintrag bei 3× und bräuchte einen eigenen Folge-Slice; das ist
  der Grund, sie zu benennen statt sie beiläufig zu entscheiden.
- `BEO-ALL/baseline-sprungweite-treibt-kosten` (**1×**, `slice-149`, Stand `offen`) — *Sprünge
  werden gesammelt statt einzeln adoptiert, und die Kosten wachsen mit der Sprungweite statt mit
  dem Prozess*. Neun Minors in acht Tagen, und die Kosten sind hier **beziffert**: acht
  Fragment-Zeilen statt einer, ein Target mehr, eine Aussage in
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), die
  nachzuziehen ist. Dieselbe Linien-Frage wie beim Eintrag darüber — der Text sagt *Re-Baseline* —,
  und dieselbe Antwort: benannt, nicht stillschweigend mitgezählt.
- `BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus` (**2×**, `slice-136`, `slice-176`,
  Stand `offen`) — *ein Slice-Plan trägt ein Vielfaches der Zeilenzahl, die das Schwester-Repo für
  dieselbe Arbeitsklasse braucht*. Der Eintrag **bindet diesen Plan selbst, und er hält ihn nicht
  ein**: `wc -l` über diese Datei liefert eine Zahl in der Größenordnung, die der Eintrag
  beanstandet. Der Umfang steckt in §1 — sechs Messungen mit ihren Kommandos —, und er ist hier
  nicht Zierde: Der Sprung ist der zweitgrößte dieser Linie, Messung 6 hat eine
  Verhaltensänderung gefunden, die kein anderer Weg gezeigt hätte, und der Auflösungs-Trigger von
  [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
  verlangt die Bilanz ausdrücklich belegt. **Das ist eine Begründung, keine Entlastung.** Ob dieser
  Plan die dritte Gelegenheit des Eintrags ist — dann Schwelle und eigener Folge-Slice —, ist das
  Urteil der Closure; hier steht er benannt statt übergangen.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit nach dem
*Umfang*-Absatz oben (Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form:
Sub-Area-Modus-Begründung). `*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code
folgt, Graduation `n/a`. Das Gate-Fragment ist innerhalb dieser Sub-Area **konventionell dicht bis
zur Vorschrift** — es ist tool-generiert, und die vier erlaubten Handgriffe stehen abgezählt in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1; dieser Slice bleibt in Handgriff 1 bis 4 und erfindet keinen fünften.

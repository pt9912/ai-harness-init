# Slice slice-135: Der d-check-Pin zieht auf v0.66.1 — und der Kopf sagt, was der gepinnte Stand tut

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle (Wartung, reaktiv). Das Kriterium ist nicht die Größe der Arbeit, sondern
ob es eine beobachtbare Closure-Bedingung gibt, die **mehr** beobachtet als die DoD dieses Slice
— Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht. Hier gibt es sie
nicht: der Auslöser ist ein fremder Release, kein Vorhaben dieses Repos. Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Pin und die Aussagen, die an ihm hängen. **(2) Gemeinsames
Closure-Kriterium?** Nein. **(3) Auslöser reaktiv oder gewollt?** **Reaktiv**, und Frage 3 nennt
genau diesen Fall wörtlich (*„Pin ist veraltet → reaktiv, ohne Welle"*). Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist die
Verzeichnis-Position. Die drei Paarungen prüft gleichwohl die nächste Welle-Closure — dieses Repo
fährt Wellen-Betrieb, und die liest auch Slices ohne Wellen-Zugehörigkeit.

**Ebene: Dogfood und emittiert zugleich, und das ist keine Ausnahme, sondern die Kopplung.** Der
lebende Pin steht in [`d-check.mk`](../../../../d-check.mk); daran gekoppelt steht der
**emittierte** Default in [`internal/emit/emit.go`](../../../../internal/emit/emit.go), und zwei
go-Tests halten beide zusammen. Die emittierte **Modul-Liste** bleibt unberührt
([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) —
dieser Slice bewegt eine Versions-Referenz, keine Prüfbereichs-Entscheidung.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Digest-Pin ist die
Reproduzierbarkeits-Zusage; ein Tag allein ist keine — dieser Sprung liefert dafür ein
Lehrstück, §1),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Target-Aufzählung aus
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 2 ist an den Re-Pin gebunden — sie wächst mit dem Tool, die Aufzählung nur von Hand),
[`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
§Auflösungs-Trigger (der Satz, der diesen Slice auslöst, samt der Auflage, die Strenge-Bilanz an
der **Quell-Differenz** zu ziehen),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(das Muster *„Trockenlauf vor dem Pin, Pflicht und belegt"*),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(die vier Handgriffe der Re-Adaption des tool-generierten Fragments und der Fixture-Abgleich in
seinem Auflösungs-Trigger),
[`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)
und
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)
(dieselbe Linie, zwei Sprünge früher),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben dem Kommando, das genau sie liefert),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (Senkung ⇒ ADR — die Frage, die die Bilanz beantworten
muss, statt sie am grünen Trockenlauf vorbeizuwinken),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — der Kopf des
Fragments spricht im Präsens über den gepinnten Stand).

**Berührte Spec-Stellen:** — Dieser Slice berührt keine. Der Pin ist eine Versions-Referenz auf
ein Fremd-Werkzeug; welche Module das Doku-Gate fährt, entscheidet
[`.d-check.yml`](../../../../.d-check.yml), und die bleibt unangetastet (§3). Der Verweis zeigt
ohnehin **aufwärts**: die Spec nennt diesen Slice nie (Baseline-Regelwerk
`grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-29.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der gepinnte d-check steht auf `v0.66.1`, und jede Aussage, die an diesem Pin hängt, ist gegen
ihn gemessen — die Strenge-Bilanz an der Quell-Differenz, der Kopf des Gate-Fragments an einer
eigenen Sonde. Geerbt wird nichts.**

### Der Anlass, gemessen

`make freshness-dcheck` meldet `gepinnt: v0.65.0` und `latest: v0.66.1`; das Skript endet mit 1,
`make` meldet den Rezept-Fehlschlag und endet mit **2**. Heute steht in
[`d-check.mk`](../../../../d-check.mk) `DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.65.0` mit
`DCHECK_DIGEST ?= sha256:5ea03abe…41288`.

### Sechs Messungen, jede neben ihrem Kommando

Alle in diesem Planungslauf selbst gefahren, am 2026-08-29. Die Läufe gegen den Baum benutzen den
Arbeitsbaum dieses Repos, netzlos (`--network none`), Mount `:ro`; der Klon des Werkzeugs unter
`/Development/d-check` ist eine **Fremdquelle** und kein Artefakt dieses Repos (§6).

1. **Der Digest ist dreifach belegt, und alle drei Beine sind hier gefahren.**
   `sha256:117a3503b2e721aee35dad85b477b6e29b497721f67b7d042b16daef4410a7f1` — aus der Registry
   (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.66.1`, Zeile `Digest:`), aus dem
   lokalen Bestand
   (`docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/pt9912/d-check:v0.66.1`) und
   als **Fremdquelle** aus dem Benutzerhandbuch des Werkzeugs
   (`grep -rn '117a3503' /Development/d-check --include='*.md'` → **1** Zeile, der Pin-Block des
   Handbuchs). Drei Wege, ein Wert
   ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
2. **Der Trockenlauf vor dem Pin zeigt eine Differenz von null Befunden.** `make docs-check`
   (gepinnt) und `make docs-check DCHECK_DIGEST=sha256:117a3503…a7f1` über denselben unveränderten
   Baum mit unveränderter [`.d-check.yml`](../../../../.d-check.yml): beide
   `d-check: 450 Datei(en) geprüft, 1 Befund(e)`, beide derselbe Befund
   (`harness/conventions.md:1015`, Grund `target-missing`), beide Exit 2 aus `make`. `diff` der
   zwei Ausgaben führt **genau eine** Zeile — das von `make` mitgeschriebene `docker run`, in dem
   der Digest steht. **Weder die 450 noch die 1 sind Erwartungswerte:** die Dateizahl wächst mit
   jedem Dokument, und der eine Befund ist der bekannte, von
   [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) getragene Stand
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2). Tragend ist die **Gleichheit** der zwei Ausgaben.
3. **Das Fragment ändert sich in genau einer Zeile.** `--print-mk` unter beiden Digests, netzlos:
   je **68** Zeilen (`wc -l`), und `diff` der zwei Ausgaben führt eine Zeile —
   `DCHECK_IMAGE ?= …:v0.65.0` → `…:v0.66.1`. Kein Recipe, kein Target, kein Flag bewegt sich. Die
   Target-Aufzählung aus
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 2 bleibt damit inhaltlich stehen — `grep -cE '^docs?-[a-z-]+:'` liefert **12** über
   beide Ausgaben und über [`d-check.mk`](../../../../d-check.mk) —; **abzugleichen ist sie
   trotzdem**, weil ihr Auflösungs-Trigger den Abgleich verlangt und nicht sein Ergebnis.
4. **Auch die Fixture kostet ihr Alter nichts, und das ist gemessen statt angenommen.** Der
   Auflösungs-Trigger von
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   verlangt je Re-Pin, die fünf Anker zu prüfen, an denen `AdaptMK` hängt. Über der frischen
   `v0.66.1`-Ausgabe liefert je ein `grep -c` für `DCHECK_IMAGE ?=`, `^\.PHONY: doc-check$`,
   `^doc-check:`, `^DCHECK_DIGEST ?=$` und `'^doc-[a-z-]+:` **fünfmal 1** — dieselben fünf
   Kommandos über `internal/emit/testdata/raw-print-mk.txt` ebenfalls **fünfmal 1**. Die Fixture
   friert eine ältere Ausgabe ein (`wc -l` → **64** gegen **68** der frischen); nachzuziehen wäre
   sie erst, wenn ein Anker fehlt.
5. **Die Strenge-Bilanz steht an der Quell-Differenz, und sie ist diesmal kurz.** Aktiv sind sechs
   Module (`grep -m1 '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans`).
   Über `v0.65.0..v0.66.1` bewegt **keine** ihrer sechs Regeldateien eine Zeile:
   `git diff --numstat v0.65.0..v0.66.1 -- internal/hexagon/core/rules/<datei>.go` am Klon gibt für
   `links`, `anchors`, `ids`, `matrix`, `codepaths` und `spans` **keine** Zeile aus. Bewegt hat
   sich **eine** geteilte Datei, aus der aktive Module lesen könnten — `markdown.go` **+14/−9**,
   dieselbe Kommandoform —, und ihre einzige geänderte Funktion `tableCells` hat unter den sechs
   aktiven Modulen **keinen** Aufrufer:
   `git grep -n 'tableCells(' v0.66.1 -- 'internal/**/*.go' ':!*_test.go'` nennt neben der
   Definition `planning_waves.go`, `structure_tablecell.go` und `structure_tableorder.go` — drei
   Dateien aus **nicht adoptierten** Modulen. Die zwei Achsen der Marker-Semantik sind über die
   Spanne unbewegt: `git show v0.66.1:internal/hexagon/core/rules/ids.go` und dasselbe mit
   `v0.65.0`, je durch `grep -n 'commentMarkerRe = \|stripped := stripInlineCodeByLine'`, liefern
   beide dieselben zwei Zeilennummern **161** und **182**.
   **Die Reichweite dieser Messung endet an den Regeldateien, und das ist ihre benannte Grenze:**
   `git diff --numstat v0.65.0..v0.66.1 -- '*.go'` führt daneben geteilte Infrastruktur, die jedes
   Modul durchläuft, und **auch sie verliert Zeilen** — das Modell (`config.go` **+65/−11**,
   `finding.go` **+13/−2**) und der Config-Leser (`configyaml.go` **+136/−19**). Deshalb
   verlangt DoD (2) die Gegenmessung auf Nicht-Null-Basis, obwohl die Bedingung des
   Auflösungs-Triggers wörtlich auf *„ein aktives Modul verliert Zeilen"* zeigt und wörtlich nicht
   erfüllt ist.
6. **Der Sprung trägt einen Breaking Change an der Config-Form — und er trifft dieses Repo auf
   keiner der zwei Ebenen.** Upstream benennt fünf `structure`-Schlüssel, die entfallen
   (`table-order` → `table.order`, `table-column` → `table.order-column`, die Zellengrenzen unter
   `table.column[]`), jeder mit **Exit 2** statt stillem Ignorieren. Gemessen: `grep -c 'structure'
   .d-check.yml` → **0** (Exit 1), und die emittierte Starter-Config führt
   `modules: [links, anchors]` (`grep -n 'modules:' internal/emit/templates/d-check.yml`). Kein
   Schlüssel, der brechen könnte — Messung 2 bestätigt es am Verhalten.

### `v0.66.0` ist ein toter Tag, und das gehört in diesen Plan

`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.66.0` antwortet
`ERROR: ghcr.io/pt9912/d-check:v0.66.0: not found`, während der Tag am Klon existiert
(`git tag --list 'v0.66*'` am Klon → **zwei** Zeilen). Upstream sagt es selbst
(`git log -1 --format=%s v0.66.1` → *„Release-Prep auf v0.66.1 — v0.66.0 blieb ein toter Tag"*).
**Das ist kein Kuriosum, sondern der Beleg für
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit):** ein Tag ist keine
Reproduzierbarkeits-Zusage — hätte `make freshness-dcheck` auf `v0.66.0` gezeigt, wäre ihm kein
Image gefolgt. Der Pin zieht deshalb auf `v0.66.1`, und der Digest, nicht der Tag, ist die
tragende Hälfte.

### Was der Trockenlauf trägt, und was nicht

Er trägt **eine** Richtung: über diesem Korpus entsteht kein neuer Befund, und der eine
vorhandene bleibt derselbe. In der Gegenrichtung ist er **informationsleer** — eine weggefallene
Befundklasse erzeugt dieselbe Ausgabe wie eine unveränderte. Diese Gegenrichtung trägt hier
Messung 5, und zwar **an der Quelle**: null bewegte Zeilen an allen sechs aktiven Regeldateien,
und die eine bewegte geteilte Funktion ohne aktiven Aufrufer. Genau das verlangt der
Auflösungs-Trigger von
[`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
(*„die Strenge-Bilanz über die neue Spanne neu ziehen — an der Quell-Differenz der Regeldateien"*).
Die dort zusätzlich verlangte Gegenmessung auf Nicht-Null-Basis ist an die Bedingung *„wo ein
aktives Modul Zeilen verliert"* geknüpft, und die ist über diese Spanne **wörtlich nicht** erfüllt
— **verlangt wird sie hier trotzdem** (DoD (2)): geteilte Infrastruktur verliert Zeilen, und der
eine Befund des heutigen Trockenlaufs macht genau eine Befundklasse beobachtbar, nicht die sechs
Module. Eine Bedingung, die auf die Regeldateien zeigt, ist die **Untergrenze** der Frage, nicht
ihre Antwort.

### Was daneben liegt und hier nicht mitkommt

**Die neunte `structure`-Bedingung `cell-max-chars` wird mit diesem Pin verfügbar — sie wird hier
nicht aktiviert.** Eine Modul- oder Bedingungs-Aktivierung ist ein **Anheben** und geht über den
Steering-Loop
([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
also über einen eigenen Schnitt mit eigener Config-Entscheidung und eigenem Trockenlauf; dass ein
Pin eine Fähigkeit **verfügbar** macht, ist keine Entscheidung über sie — dieselbe Trennung, die
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) schon
für `structure` selbst gezogen hat. **Und sie trägt die Frage nicht, für die sie sonst naheläge:**
[slice-134](slice-134-adr-index-traegt-die-ziel-form.md) bräuchte die Gleichheit einer
Tabellenzelle mit der **H1 der verlinkten Datei**; die neue Bedingung begrenzt die **Zeichenzahl**
einer über ihren Kopfzeilen-Namen benannten Spalte. Gemessen an der Quelle:
`grep -rn -i 'H1 der\|Überschrift der verlinkten\|verlinkten Datei'` über `spec/lastenheft.md` und
`spec/spezifikation.md` des Klons → **kein Treffer**, Exit 1.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Der Pin steht auf `v0.66.1`, dreifach belegt, und der emittierte Default zieht mit.**
      Beide gekoppelten Stellen tragen Tag und Digest zeichengleich; die vier Re-Adaptions-Handgriffe
      aus [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 1 sind gegen eine **frische** Tool-Ausgabe ausgeführt, nicht gegen die Erinnerung.
      **Rot:** nur [`d-check.mk`](../../../../d-check.mk) bewegen und
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) stehen lassen → `make test` fällt
      mit `--- FAIL:` an `TestDefaultImage_MatchesCanonical` und
      `TestDefaultDigest_MatchesCanonical`. Dieser Lauf gehört **gesehen**, nicht behauptet, und
      seine Meldung gelesen — sie nennt die zwei Zeichenketten, die auseinanderlaufen.
- [ ] **(2) Die Strenge-Bilanz über `v0.65.0..v0.66.1` ist an der Quell-Differenz gezogen und im
      Umsetzungs-Commit ausgewiesen — mit ihrer Richtung.** Der Trockenlauf beider Digests über
      denselben Baum steht daneben, samt dem Satz, was er **nicht** zeigt (§1 *Was der Trockenlauf
      trägt*). **Dazu gehört die Gegenmessung auf Nicht-Null-Basis** — beide Digests über einer
      Kopie außerhalb des Repos, in der die Marker entwertet sind, mit identischer Befundmenge als
      Zusage. Sie ist nicht optional, obwohl der Auflösungs-Trigger sie wörtlich an eine Bedingung
      knüpft, die diese Spanne nicht erfüllt: geteilte Infrastruktur **verliert** Zeilen (§1
      Messung 5, benannte Grenze), und der heutige Trockenlauf steht mit **einem** Befund auf einer
      Basis, die nur die Klasse `target-missing` beobachtbar macht. Fällt die Bilanz auf
      **Senkung**, greift §4 statt eines vierten DoD-Punktes.
      **Rot, zwei Formen, beide herstellbar:** (a) `make docs-check` meldet nach dem Pin einen
      anderen Befundbestand als die Messung 2 aus §1 — dann ist der Sprung nicht kostenlos und der
      Slice hat eine Bereinigung statt einer Zusage; (b) das `git diff --numstat`-Kommando aus §1
      Messung 5 gibt für eine der sechs aktiven Regeldateien eine Zeile aus, **oder**
      `git grep -n 'tableCells('` nennt eine Datei eines aktiven Moduls — dann ist die
      Quell-Differenz nicht leer und die Bilanz braucht die Gegenmessung auf Nicht-Null-Basis, die
      [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
      §Auflösungs-Trigger für diesen Fall verlangt.
- [ ] **(3) Der Kopf von [`d-check.mk`](../../../../d-check.mk) sagt, was der gepinnte Stand tut —
      an einer eigenen Sonde gemessen, nicht vom Vorgänger geerbt.** Die Sonden-Tabelle der
      Marker-Semantik trägt vier Lagen über **`v0.66.1`**; die Vorgänger-Spanne `v0.62.0` → `v0.65.0`
      steht dort nicht mehr, denn sie ist Gegenstand des Adaptions-Eintrags und nicht des Kopfes
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7: die vorige Fassung hält `git`). Dasselbe gilt für
      die drei übrigen Pin-Nennungen im Kopf und für den literalen Digest im
      Neu-Erzeugungs-Kommando.
      **Rot, zwei Formen:** (a) `grep -c 'v0\.65\.0\|5ea03abe\|v0\.62\.0' d-check.mk` liefert mehr
      als **0**, während `DCHECK_IMAGE` `v0.66.1` sagt — dann behauptet der Kopf einen Stand, der
      nicht gepinnt ist. Heute liefert dieselbe Zeile **10**, und die engere Form ohne `v0.62.0`
      ebenfalls **10**: die drei `v0.62.0`-Zeilen sind genau die Tabellenzeilen, die daneben schon
      `v0.65.0` nennen (`grep -c 'v0\.62\.0' d-check.mk` → **3**); (b) die Sonde selbst: ein
      `d-check:ignore` in blanker Prosa über einem echten Befund wird
      unter `v0.66.1` **unterdrückt** statt gemeldet — dann ist die Tabelle falsch abgeschrieben
      statt gemessen. Als Gegenprobe zur Zähl-Form gehört das Neu-Erzeugungs-Kommando des Kopfes
      **wörtlich gefahren**: mit gezogenem Pin liefert
      `diff <(docker run --rm --network none <v0.66.1-digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
      → **4** Hunks; heute, vor dem Pin, liefert dieselbe Zeile **3**, weil die `DCHECK_IMAGE`-Zeile
      in den Hunk des Adopter-Kopfes fällt. Die **4** ist damit kein Erwartungswert aus der
      Erinnerung, sondern ein Kriterium mit gemessenem Gegenstück.
- [ ] `make gates` ohne **neuen** Befund — und der Punkt sagt hier bewusst nicht „grün": der
      Gate-Lauf ist heute rot, an genau einem Befund, den dieser Slice nicht verursacht und nicht
      behebt (§1 Messung 2, getragen von
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md), aufzulösen von
      [slice-132](slice-132-adaptions-block-ohne-totes-ziel.md)). Der Punkt bedeutet hier: **kein
      Befund kommt hinzu und keiner fällt weg**, gemessen gegen §1 Messung 2. Steht die Reihenfolge
      anders — 132 zuerst —, ist er unverändert `0 Befund(e)`.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist. Berührt ist keiner: der Pin ist eine
      Versions-Referenz, und die Gate-Namen in [`AGENTS.md`](../../../../AGENTS.md) §4 und
      [`harness/README.md`](../../../../harness/README.md) bewegen sich nicht (§1 Messung 3, `12`
      Targets vor wie nach).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (die `observations.md` neben den Wellen): das Repo führt **keines** —
      die Datei existiert nicht (`ls docs/plan/planning/` nennt sie nicht). Das Item entfällt nicht
      still, sondern mit diesem Grund; er wird in §7 notiert. Dasselbe gilt für das
      Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der nächsten Welle-Closure geprüft, nicht hier (auch für
      Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | der lebende Pin (`DCHECK_IMAGE` + `DCHECK_DIGEST`) und der Adopter-Kopf. **Zehn** Stellen nennen heute den alten Stand (`grep -c 'v0\.65\.0\|5ea03abe' d-check.mk`; `grep -n` daneben zeigt die Lage): **zwei** Wertzeilen, **vier** in der Sonden-Tabelle samt ihrer Überschrift, **drei** in Rang-Zeiger, Digest-Zusage und Lauf-Satz, **eine** als literaler Digest im Neu-Erzeugungs-Kommando. Der Aufwand liegt in den acht Kopf-Zeilen, nicht in den zwei Wertzeilen, und die Sonden-Tabelle ist neu zu **messen**, nicht umzuschreiben (DoD (3)). Alles im Rahmen von Handgriff 1 und 2 aus [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | `DefaultImage`/`DefaultDigest` — Tier-1-Drift; die zwei go-Tests koppeln beide Stellen und färben DoD (1) rot |
| [`Makefile`](../../../../Makefile) | update | das Tag-Beispiel im Kommentar über `DCHECK_TAG` (`grep -n 'v0\.65\.0' Makefile` → **eine** Zeile) — dieselbe Stelle, die [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) und [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) bei den Vorgänger-Sprüngen nachzogen |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der neue Adaptions-Eintrag, die Fortschreibung von §Baseline und der datierte Fixture-Beleg im Auflösungs-Trigger von [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) entstehen im Architect-Lauf; dieser Slice liefert die **Messungen** als Übergabe-Artefakt (§6) |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | der Pin bewegt keine Modul-Liste und keinen Prüfbereich. Wer hier etwas ändert, aktiviert eine Fähigkeit — das ist ein eigener Schnitt (§1 *Was daneben liegt*) |
| [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) | **unverändert** | die emittierte Starter-Config bleibt `modules: [links, anchors]` ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)); der Breaking Change an der `structure`-Config-Form trifft sie nicht (§1 Messung 6) |
| `internal/emit/testdata/raw-print-mk.txt` | **unverändert** | die fünf Anker, an denen `AdaptMK` hängt, stehen in der frischen `v0.66.1`-Ausgabe je genau einmal (§1 Messung 4). Nachzuziehen wäre die Fixture erst, wenn einer fehlt — ihre Zeilenzahl ist kein Kriterium |
| `docs/reviews/**`, `docs/plan/planning/done/**` | **unangetastet** | Zeitdokumente; sie frieren den Stand ihres Laufs ein. Die Nennungen von `v0.65.0` darin sind wahr über ihren Gegenstand |
| Roadmap | **keine Zeile** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2); ihr Zustand ist die Verzeichnis-Position |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **das WIP-Limit von 1 ist frei** —
`ls docs/plan/planning/in-progress/ | grep -c '^slice-'` liefert **0**. Am 2026-08-29 liefert es
**1**, den laufenden [slice-081](../in-progress/slice-081-baum-tauschen-pin-ziehen.md); das
WIP-Limit ist eine harte Größe und kein Vorschlag (Baseline-Regelwerk
`modul-05-planning-harness.md` §Trigger je Lifecycle-Übergang und WIP-Limit). Eine inhaltliche
Vorbedingung hat dieser Slice **nicht**: die Auslöse-Bedingung ist heute erfüllt
(`make freshness-dcheck`, §1), und keine der sechs Messungen aus §1 wartet auf ein fremdes
Artefakt. Insbesondere wartet er **nicht** auf
[slice-132](slice-132-adaptions-block-ohne-totes-ziel.md) — dessen Befund ist unter beiden Digests
derselbe (§1 Messung 2), die zwei Slices berühren einander also nur in der Ausgabe eines Laufs,
nicht in ihrem Gegenstand.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Sonde aus DoD (3) zeigt, dass sich
  die Marker-Semantik über die Spanne **doch** bewegt hat und ein Marker im Bestand betroffen ist.
  Dann ist der Pin eine Sache und die Marker-Bereinigung eine zweite — zwei Schnitte, kein vierter
  DoD-Punkt.
- `in-progress` → `open` (blockiert — Carveout?): die Strenge-Bilanz findet an einem der sechs
  aktiven Module eine **Senkung**. Dann verlangt [`AGENTS.md`](../../../../AGENTS.md) §3.5 einen
  ADR, und den schreibt der Architect — der Slice blockiert an einer fremden Rolle und geht zurück,
  statt die ADR nebenbei mitzunehmen. Ein **Carveout** entsteht dabei nicht: er nimmt ein Gate aus,
  und hier ist keines auszunehmen; ein Carveout säße zudem in keinem Rang und dürfte eine
  Vertrags-Aussage nicht ändern (Baseline-Regelwerk `modul-07-carveouts.md`).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **`make freshness-dcheck` endet mit 0** (der Pin hat den Release
eingeholt — dasselbe Kommando, das den Slice ausgelöst hat), und **`make docs-check` meldet
denselben Befundbestand wie §1 Messung 2** (kein Befund kommt hinzu, keiner fällt weg). Dazu:
DoD (1) bis (3) erfüllt mit gefahrenen Kommandos und gelesenen Meldungen, `make gates` ohne neuen
Befund, `make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne
blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Lerneintrag und der **Übergabe an den
Architect** (§3, Zeile [`harness/conventions.md`](../../../../harness/conventions.md)).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die leere Quell-Differenz ist die verführerischste Messung dieses Slice.** *„Keine der sechs
  aktiven Regeldateien bewegt eine Zeile"* liest sich wie ein Freispruch und ist nur eine
  Untergrenze: die Bilanz ist über **Dateien** gezogen, während die Frage über **Verhalten** geht,
  und geteilte Infrastruktur hat sich bewegt (§1 Messung 5). — **Ausgang:** <entfallen: die
  Gegenmessung auf Nicht-Null-Basis aus DoD (2) liefert identische Befundmengen | eingetreten: sie
  liefert eine Differenz, und §4 greift>
- **Die Bilanz ist gegen ein Fremd-Repo gemessen, nicht gegen ein Gate.** Kein Modul dieses Repos
  vergleicht die Befundklassen zweier d-check-Versionen; wer den Klon unter `/Development/d-check`
  nicht hat, kann §1 Messung 5 nicht nachvollziehen. Die konstruierte Sonde aus DoD (3) und die
  Gegenmessung aus DoD (2) sind deshalb die Teile, die **ohne** ihn reichen. Dass das Werkzeug ein
  Nachbar-Repo ist und keine Fremd-Software, macht die Lage zugleich zu einer **Anforderung** statt
  zu einer Grenze. — **Ausgang:** <entfallen: die zwei repo-eigenen Messungen tragen die Bilanz
  allein | eingetreten: Folge-Slice mit der Anforderung an das Werkzeug, benannt und adressiert>
- **Der Kopf ist der billigste Ort, an dem eine Aussage veraltet, und der teuerste, an dem sie
  gelesen wird.** Er steht in jedem Lauf im Kontext, der [`d-check.mk`](../../../../d-check.mk)
  aufschlägt, und **kein Modul der aktiven sechs liest ihn** — die zehn Nennungen des alten Standes
  hat kein Gate gemeldet, sondern ein `grep` (§3). Nach diesem Slice gilt dasselbe für die neuen.
  — **Ausgang:** <entfallen: die Aussagen des Kopfes sind gemessen und tragen bis zum nächsten Pin
  | eingetreten: Folge-Slice oder Übergabe, wenn eine Aussage einen Wächter braucht>
- **Der Pin trägt einen Grund, den kein Sensor dieses Repos kennt.** `make freshness-dcheck` sagt
  *„ein neuer Tag ist da"*, nicht *„der gepinnte ist verwundbar"*; kein Gate scannt das gepinnte
  Fremd-Image. Diese Klasse ist bereits einmal aufgefallen
  ([slice-122](../done/slice-122-d-check-pin-v0650.md) §6, vierzehn HIGH-CVEs im damaligen Sprung)
  und ist mit diesem Slice nicht geschlossen. — **Ausgang:** <weiter offen: als Kandidat notiert,
  ohne eigenen Schnitt in diesem Lauf | eingetreten: Folge-Slice>
- **Ein toter Tag kann sich wiederholen.** `v0.66.0` existiert am Klon und **nicht** in der
  Registry (§1). Ein Lauf, der dem Freshness-Ausgang blind folgt, pinnt auf ein Image, das es nicht
  gibt. — **Ausgang:** <entfallen: der Digest ist vor dem Pin dreifach belegt, DoD (1) | eingetreten:
  Übergabe an den Architect, weil die Beleg-Pflicht dann eine Regel-Frage ist>
- **Der Rang-Zeiger bleibt nach diesem Slice halb.** Zeile 2 des Kopfes nennt nach DoD (3) die
  richtige **Version**, aber weiter nur die Einträge der Vorgänger-Sprünge — der Eintrag zu diesem
  hier existiert zum Umsetzungs-Zeitpunkt nicht (§6 Übergabe 1). Das ist eine echte
  Reihenfolge-Abhängigkeit an einer fremden Rolle, keine Auslassung, und sie darf den Pin nicht
  aufhalten. — **Ausgang:** <entfallen: der Architect-Lauf liegt vor dem Umsetzungs-Lauf und der
  Zeiger nennt den Eintrag sofort | eingetreten: Folge-Slice nach dem Muster von
  [slice-128](../done/slice-128-d-check-kopf-sagt-was-gilt.md), mit dem Beginn-Trigger *„der
  Eintrag existiert"*>

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8 — vier Posten, keiner hier geschrieben)

Der Adaptions-Block ist Architect-Eigentum; dieser Slice liefert **Messungen**, keinen Regeltext.

1. **Ein neuer Adaptions-Eintrag zum `v0.65.0` → `v0.66.1`-Sprung**, nach dem Muster von
   [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
   [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines),
   [`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) und
   [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt).
   Was er zu tragen hat, liefert §1: Digest mit drei Beinen, Trockenlauf als 0-Differenz auf einer
   1-Befund-Basis, Fragment-Diff von genau einer Zeile, Strenge-Bilanz als **leere**
   Regeldatei-Differenz mit ihrer benannten Grenze, und die Richtungs-Aussage.
   **Die Reihenfolge ist geteilt, und dieser Slice teilt sie ausdrücklich:** der Rang-Zeiger in
   Zeile 2 des Kopfes trägt **zwei** Hälften — die Version, aus der das Fragment abgeleitet ist,
   und die Liste der Einträge, die es adaptieren. Die **Version** zieht dieser Slice (DoD (3));
   die **Liste** kann erst nachziehen, wenn der Eintrag existiert. Dieselbe Abhängigkeit trug beim
   Vorgänger-Sprung ein eigener Schnitt
   ([slice-128](../done/slice-128-d-check-kopf-sagt-was-gilt.md) DoD (1)); hier ist sie ein
   benannter Rest mit Ausgang (§6, letzte Risiko-Zeile) und **kein** vierter DoD-Punkt.
2. **Die §Baseline-Zeile führt die Sprung-Einträge auf und wächst mit diesem hier.** Sie trägt
   ausdrücklich **keine** zweite Fassung der Version, sondern zeigt auf den lebenden Ort; zu
   ergänzen ist allein die Aufzählung der Einträge
   (`grep -n 'Die Sprünge dieser Linie führen' harness/conventions.md` → **eine** Zeile, und sie
   führt die Einträge). Ein Zeilen-Bereich steht hier bewusst nicht: er wandert mit jeder
   Architect-Änderung an derselben Datei.
3. **Der Auflösungs-Trigger von
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   trägt einen datierten Fixture-Beleg über `v0.65.0`.** Dieser Lauf hat ihn über `v0.66.1`
   wiederholt: fünf Anker, fünfmal **1** (§1 Messung 4). Ob der Beleg im Eintrag mitwandert oder
   der Trigger nur die Prüfung verlangt und die Zahl nicht führt, ist eine Entscheidung am Text —
   dieselbe Frage, die
   [slice-128](../done/slice-128-d-check-kopf-sagt-was-gilt.md) für zwei andere Zahlen übergeben
   hat.
4. **Die neunte `structure`-Bedingung ist ab diesem Pin verfügbar und nicht adoptiert.** Das ist
   dieselbe Lage, die
   [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
   im Titel führt — *verfügbar*, nicht *aktiv*. Ob der neue Eintrag sie so nennt, entscheidet der
   Architect-Lauf; die Messung dazu liegt in §1 (*Was daneben liegt*), samt der Feststellung, dass
   sie die H1-Gleichheit **nicht** trägt.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind **zwei**: das Gate-Fragment
([`d-check.mk`](../../../../d-check.mk) plus [`Makefile`](../../../../Makefile)-Kommentar) und der
Emitter ([`internal/emit/`](../../../../internal/emit/)). Der Schnitt ist nicht zu grob: das
Fragment ist **tool-generiert** und kennt genau vier erlaubte Handgriffe
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1), der Emitter ist repo-eigener Go-Code mit Tests — verschiedene Regel-Lage,
verschiedene Änderungs-Art, gemeinsamer Wert nur über die zwei Kopplungstests. Beide erfüllen die
Schwelle ≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein** Beobachtungs-Register —
eine `observations.md` unter `docs/plan/planning/` existiert nicht (`ls docs/plan/planning/`
nennt vier Verzeichnisse, eine `README.md` und vier Welle-Pläne). Keine Treffer, und der Grund ist
die fehlende Datei, nicht ein leeres Register; er wird in §7 notiert.

Alle berührten Sub-Areas GF; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md). Der Modus-Begründungsblock
entfällt damit nach dem *Umfang*-Absatz oben. Das Gate-Fragment ist **konventionell dicht bis zur
Vorschrift** — es ist tool-generiert, und die vier erlaubten Handgriffe stehen abgezählt in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1; dieser Slice bleibt in Handgriff 1 und 2.

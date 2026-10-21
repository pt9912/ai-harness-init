# Slice slice-bats-ruempfe-erreichen-shell-lint: `shell-lint` liest die Rümpfe der bats-Dateien

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — **ein** Gate-Rezept. **(2) Gemeinsames Closure-Kriterium?** Nein —
jedes wäre die Abschrift der DoD. **(3) Auslöser?** Reaktiv: Der Auflösungs-Trigger von
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) ist eingetreten; dieser Slice ist die
Gate-Arbeit, [slice-113](../open/slice-113-co-001-ist-faellig.md) die Auflösung dahinter.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist das `shell-lint`-Rezept **dieses**
[`Makefile`](../../../../Makefile). Was ein emittiertes Repo an Shell-Lint bekommt, entscheidet der
Slice, der die Tool-Ebene entscheidet.

**Bezug:**
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) und
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only, gepinnte Images),
[`AGENTS.md`](../../../../AGENTS.md) §3.2 (Suppression-Verbot), §3.5 (Gates nicht ohne ADR lockern),
§3.6 (rot gesehenes Gegenbeispiel), §3.9 (Docker-only),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-21.

---

## 1. Ziel und Abgrenzung

**Ziel:** **`make shell-lint` liest die Logik aller `test/*.bats`-Dateien und ist grün, ohne die
Pfad-Ausnahme, die [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) trägt.**

**Bestand, gemessen vor dem Schnitt.** `git ls-files 'test/*.bats' | wc -l` → **50** Dateien. Ein
**einmaliger Vorlauf des Planners** (HEAD `a5ee6205`; das Skript liegt nicht im Repo, der Implementer
**misst neu**): `bats-preprocess` aus dem gepinnten `BATS_IMAGE`
(`/opt/bats/libexec/bats-core/bats-preprocess`, mit `BATS_ROOT=/opt/bats BATS_LIBDIR=lib`) erzeugt je
Datei den Extrakt, `shellcheck --shell=bash` im gepinnten `SHELLCHECK_IMAGE` liest ihn → **173**
Befunde in **39** der 50 Dateien: SC2016 60, SC2154 58 (die bats-Variablen `status`/`output`),
SC2164 36, Rest 19. Die Zahlen sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); ihr Kommando nach dem Bau ist die Ausgabe des Rezepts aus DoD (1) im `--format=gcc`,
gezählt mit `grep -c ': \(error\|warning\|note\):'` und je Regel mit
`grep -o 'SC[0-9]*' | sort | uniq -c | sort -rn`.

**Die zwei Images sind getrennt.** `bats-preprocess` liegt im `BATS_IMAGE`, `shellcheck` im
`SHELLCHECK_IMAGE`; keines trägt das andere Werkzeug. Die Verkettung ist Entwurf des Laufs
(§3); Docker-only
([`AGENTS.md`](../../../../AGENTS.md) §3.9) und kein neuer Image-Pin sind die Randbedingungen.

### Architect-Verdikt (beantwortet)

Das Verdikt `2026-10-21-slice-bats-ruempfe-erreichen-shell-lint-architect-verdikt`
([Report](../../../reviews/2026-10-21-slice-bats-ruempfe-erreichen-shell-lint-architect-verdikt.md))
lautet: **Config-Ausnahme nach [`AGENTS.md`](../../../../AGENTS.md) §3.2, keine Senkung nach §3.5,
keine ADR.** Mischform:

- **SC2154** über einen Fuß **hinter** dem Extrakt
  (`status=0; output=; lines=(); : "$status" "$output" "${lines[@]}"`); ein Kopf verschöbe die Zeilen.
  Ohne den `:`-Teil entstehen neue SC2034.
- **SC2016** über `--exclude=SC2016` **nur** am eigenen shellcheck-Aufruf für den bats-Extrakt (das
  gepinnte shellcheck kennt `--exclude`); **keine** `.shellcheckrc` an der Wurzel, sonst entfiele SC2016
  auch für `harness/tools` und `test/mutations`.
- **Mount:** [`MR-049`](../../../../harness/conventions.md#mr-049--drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein-statt-ihn-per-copy-ins-bild-zu-nehmen)
  bleibt unberührt (kein `-v …:rw`, siehe §3 V1).
- **Gegenstands-Kommentar** der Ausnahme (Regel, Baum, Treffer, benannte Grenze) steht im Report; kein
  Wächter prüft ihn, das ist das akzeptierte Negativ.

Die Zahlen des Reports (173 Befunde, 55 ohne Suppression zu beheben, SC2154 auf 0) sind eine Messung des
Architects vom 2026-10-21 auf HEAD `479a466a`, **keine Erwartungswerte**; der Implementer misst neu.

**Übernimmt:** nichts. Der Gegenstand der Auflösung bleibt bei [slice-113](../open/slice-113-co-001-ist-faellig.md).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Eine `.shellcheckrc` an der Wurzel oder ein `-v …:rw`-Mount** — beides schaltet die Ausnahme auf
  andere Bäume aus bzw. berührt [`MR-049`](../../../../harness/conventions.md#mr-049--drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein-statt-ihn-per-copy-ins-bild-zu-nehmen); das Verdikt schließt sie aus.
- **Die Auflösung von `CO-001`** (Move nach `done/`, Pfad-Nachzug, zehntes `ignore-refs`-Paar, Absatz
  *„GRENZE, keine Regel"*, Bindung und Index) — [slice-113](../open/slice-113-co-001-ist-faellig.md) führt sie
  aus und nimmt sie an (sein §1). Der Carveout bleibt bis dahin in `carveouts/`; zurückgenommen wird hier
  nur die Pfad-Ausnahme im Rezept, nicht das Dokument.
- **Ein bats-natives Lint-Werkzeug** (zweite Technik aus `CO-001`) — kostet ein neues Image, einen
  Freshness-Eintrag und eine zweite Werkzeug-Achse; die Extraktion trägt, weil `bats-preprocess` im
  gepinnten `BATS_IMAGE` liegt. Scheitert die Verkettung messbar, geht der Slice zurück (§4), er
  pinnt kein Werkzeug im Lauf.
- **Umbau der bats-Fälle über die Befund-Behebung hinaus** — etwa die `!`-Negationen, soweit
  shellcheck sie nicht meldet: sie sind Bestand im Register
  (`BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung`, §8), nicht Gegenstand eines Lint-Slice.
- **Die emittierte Ebene** — Dogfood; ein Ziel-Rezept entscheidet die Tool-Ebene.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Die Verkettung steht, und ihre Erweiterung ist rot gesehen.** `bats-preprocess` im
      `BATS_IMAGE` und `shellcheck` im `SHELLCHECK_IMAGE` laufen verkettet über alle
      `git ls-files 'test/*.bats'`, Docker-only; `make shell-lint` ruft sie.
      **Rot:** ein absichtlicher Befund in einem `@test`-Rumpf färbt `make shell-lint` rot, und die
      Ausgabe nennt **Datei und Regel** (und die Zeile; trägt der Extrakt keine Rück-Zuordnung zur
      Original-Zeile, steht diese Grenze am Rezept, §6). **Heute ungedeckt:**
      `sed -n '/^shell-lint:/,/^$/p' Makefile | grep -c '\.bats'` → **0**.
- [ ] **(2) Der Bestand ist grün, ohne Inline-Suppression und ohne die Pfad-Ausnahme.** Die Befunde
      sind behoben (die Klassen außer SC2154/SC2016, ohne Suppression); SC2154 und SC2016 stehen nach
      dem Verdikt aus §1 (Fuß, `--exclude` nur am bats-Aufruf) mit ihrem ganzen Gegenstand im
      Kommentar ([`AGENTS.md`](../../../../AGENTS.md) §3.2, §3.5). `make shell-lint` ist grün, das
      Rezept schließt keine bats-Datei mehr aus, `make gates` ist grün.
      **Rot:** `git grep -c 'shellcheck disable' -- 'test/*.bats'` findet eine Stelle.
- [ ] **(3) Ein Prüfbereich, der wieder schrumpft, wird rot — zwei Mutations-Fälle.** In
      `test/mutations/`: (a) ohne den Fuß färbt SC2154 den Lauf rot, (b) ohne `--exclude=SC2016` färbt
      SC2016 ihn rot; `make mutate` läuft beide grün-als-erwartet
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). **Grenze als Zusage-Satz im Skript, nicht als Wirkung
      behauptet:** dass die `--exclude`-Begrenzung auf den bats-Aufruf `harness/tools` und
      `test/mutations` die volle Schwelle lässt, lässt sich nicht rot färben, solange kein Rumpf dort
      ein `$` in Einzelquotes trägt.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`Makefile`](../../../../Makefile) | update | `shell-lint` ruft die Verkettung; die Pfad-Liste des Rezepts verliert die Ausnahme (DoD 1, 2) |
| `harness/tools/` (Verkettungs-Skript) | neu, empfohlen | zwei Images lassen sich in einem Rezept nur unleserlich verketten; ein Skript fällt selbst in den Prüfbereich von `shell-lint` und bekommt zwei bats-Fälle nach dem Muster von [`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh) |
| `test/*.bats` | update, soweit Befunde auftreten | Behebung statt Unterdrückung (DoD 2) |
| Fuß und `--exclude=SC2016` im Verkettungs-Skript | neu, nach Verdikt (§1) | keine Konfigurationsdatei; Ausnahme nur am shellcheck-Aufruf für den bats-Extrakt, Gegenstands-Kommentar nach dem Report |
| `test/mutations/` | neu | der Fall aus DoD (3) |
| [`harness/README.md`](../../../../harness/README.md) | update | die Vertragszeile von `shell-lint` nennt den erweiterten Prüfbereich |
| `internal/emit/`, [`.harness/baseline`](../../../../.harness/baseline) | **unverändert** | Dogfood; Baseline byte-verifiziert |

**Entwurf der Verkettung — V1 ist entschieden (Mischform nach dem Verdikt):**

- Ein Container im `BATS_IMAGE` (`--network none`, Baum read-only) schreibt den Extrakt **aller** 50
  Dateien auf stdout, mit einer Trennzeile je Datei; ein Container-Start statt 100. Der **Host** teilt den
  Strom in Dateien unter dem gitignorierten Zustands-Bereich (`.harness/state/`, vorher geleert), jeder
  Extrakt trägt den Fuß (SC2154). Schritt 2 `shellcheck` (mit `--exclude=SC2016`) im
  `SHELLCHECK_IMAGE` liest dieses Verzeichnis read-only.
- **Dateinamen-Rückabbildung** auf `test/<name>.bats`: `bats-preprocess` trägt die Originalzeile 1:1, nur
  der Dateiname zeigt auf den Extrakt-Pfad; das Skript bildet ihn zurück.
- Die Pins bleiben im `Makefile` und reisen als Umgebung ins Skript — kein zweiter Pin.

## 4. Trigger

**Start** (`open` → `next` → `in-progress`): der Architect hat die Frage aus §1 beantwortet (Verdikt
`2026-10-21-slice-bats-ruempfe-erreichen-shell-lint-architect-verdikt`, keine ADR nötig), der
Auftraggeber hat den Slice priorisiert, und das WIP-Limit ist frei.
[slice-113](../open/slice-113-co-001-ist-faellig.md) beginnt erst, wenn dieser Slice in `done/` liegt.

**Rückführungen — vorab benannt:**

- `in-progress` → `next`: die Behebung der Befunde (55 beim Architect-Vorlauf in 39 Dateien, SC2164
  allein 36) ist in **einer** Review-Sitzung nicht prüfbar. Dann Re-Slice: (A) Verkettung mit Fuß und
  `--exclude` plus Fälle, (B) Befund-Behebung nach Regel-Klasse, nicht ein vierter DoD-Punkt.
- `in-progress` → `open`: die Verkettung liefert keinen stabilen Extrakt. Dann bekommt `CO-001` den
  gemessenen Grund und einen Trigger, der nicht eingetreten ist; [slice-113](../open/slice-113-co-001-ist-faellig.md)
  entfällt mit diesem Grund.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt, `make gates` grün **ohne** Pfad-Ausnahme, `make mutate` grün einschließlich des
neuen Falls (Verifier trägt den Rot-Beleg der Rücknahme nach, falls er fehlt), Review nach Modul 10 und
Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Extrakt verschiebt Zeilen.** — **Ausgang:** entfallen: `bats-preprocess` trägt die Originalzeile
  1:1 (Verdikt), der Fuß steht hinter dem Extrakt und verschiebt nichts; der Implementer bestätigt es
  am Trockenlauf, sonst Rückführung `→ open`.
- **Der Mount wird schreibbar und berührt [`MR-049`](../../../../harness/conventions.md#mr-049--drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein-statt-ihn-per-copy-ins-bild-zu-nehmen).** — **Ausgang:** entfallen: V1 schreibt auf stdout,
  der Host teilt; kein `-v …:rw`.
- **Das Skript ist ein Werkzeug über Testdateien und selbst ungetestet, wenn niemand es bindet.** —
  **Ausgang:** <…>
- **Die Befund-Menge sprengt eine Review-Sitzung** (173 in 39 Dateien beim Vorlauf, keine
  Erwartungswerte); der Cutoff-Reflex *„ab jetzt, Bestand nicht"* trägt nicht, weil ein Lint-Lauf keine
  Datei-Historie kennt. Rückführung `→ next` (§4). — **Ausgang:** <…>
- **SC2016 ohne Suppression heißt Umbau der Zusicherungen.** Das Register trägt den Fall, dass die
  Aufteilung einer Prüfung ihre Ko-Okkurrenz lockert
  (`BEO-ALL/marker-pruefung-in-full-smoke-wird-fuer-shell-lint-aufgespalten`, 1×). — **Ausgang:** <…>

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, *Shell-Sensorik dieses Repos* (`shell-lint`,
`harness/tools/*.sh`, `test/*.bats`): Konventionen (§3.2, §3.6), Artefakte (Rezept, Skripte, Fälle) und
Sensor (`shell-lint`) tragen sie, Schwelle ≥ 2 von 3 erfüllt, nicht zu grob.

**Vorgelagert — offene Beobachtungen sichten** (gemergter Stand, `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`):

- `BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung` — **2×**, offen. Der Bestand dort (46 `!`-Zeilen
  in 15 Dateien) ist genau der Raum, den dieser Prüfbereich erstmals ansieht. Findet der Lauf eine
  weitere solche Stelle, ist der Beleg aus diesem Slice der **dritte**: der Lese-Schritt der Closure
  vergibt den Ausgang, es gibt keine Notiz mehr.
- `BEO-ALL/marker-pruefung-in-full-smoke-wird-fuer-shell-lint-aufgespalten` — **1×**, offen: die
  SC2016-Behebung ohne Suppression (§6).
- `BEO-ALL/ausnahmeliste-nur-auf-form-geprueft` — **4×**; sein Ausgang steht in seiner `state.md`.
  Berührt, falls die zentrale Ausnahme aus §1 eine Liste führt.

### Sub-Area: Shell-Sensorik dieses Repos

- **Modus:** GF
- **Konventionen-Dichte:** hoch — Docker-only mit gepinntem Image
  ([`ADR-0003`](../../adr/0003-go-native-binaries.md)), Suppression-Verbot (§3.2), jeder Wächter mit
  `test/mutations/`-Fall (§3.6).
- **Phase-Reife:** Phase 4 — `shell-lint` läuft und steht in der Sensors-Tabelle von
  [`harness/README.md`](../../../../harness/README.md).
- **Evidenz-/Diskrepanz-Risiko:** mittel — der Prüfbereich wird zum ersten Mal geöffnet; die Befund-Zahl
  ist eine einmalige Messung (§1), der Trockenlauf kommt vor der Wahl der Verkettung.
- **Reconciliation-Aufwand:** M; Graduation entfällt (kein BF), die Rückführung `→ next` (§4) fängt eine
  Überschreitung.

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
Gate-Arbeit, [slice-113](slice-113-co-001-ist-faellig.md) die Auflösung dahinter.

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

**Verantwortlich:** —

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

### Architect-Frage — **vor dem Claim zu beantworten**

SC2154 (bats-Variablen) und SC2016 (`$` in Einzelquotes) sind ohne Inline-Suppression
([`AGENTS.md`](../../../../AGENTS.md) §3.2) nur zentral zu führen, in einer shellcheck-Konfiguration
(`disable=`), oder gar nicht, wenn der Extrakt SC2154 durch eine vorangestellte Variablen-Deklaration
vermeidet. Zu entscheiden:

1. **Ist eine zentrale Ausnahme für SC2154 und/oder SC2016 im neu geöffneten Prüfbereich eine
   Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5** — dann ADR, Annahme ist Auftraggeber-Entscheidung
   ([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)) — **oder eine
   Config-Ausnahme nach §3.2** (zentraler, begründeter Eintrag)? Gegenlage: heute ist nichts
   gelintet, ein Gate wird also geöffnet statt gesenkt; die Schwelle der *übrigen* Dateien bleibt, und
   §3.5 Absatz 2 verlangt, dass die Begründung **ihren ganzen Gegenstand** nennt (jede Regel, jeden
   Baum, den der Schlüssel stumm schaltet). Kein Wächter prüft eine shellcheck-Konfiguration auf
   diesen Satz (`internal/ausnahmegrund/` liest `.d-check.yml`).
2. **Muss die Ausnahme auf den bats-Lauf begrenzt sein** (eigene Konfigurationsdatei nur für diesen
   Aufruf, sofern das gepinnte shellcheck sie erlaubt — der Implementer misst), damit
   `harness/tools/*.sh` und `test/mutations/*.sh` die volle Schwelle behalten?
3. **Trägt die Alternative ohne Ausnahme** (Extrakt mit Kopf-Deklaration für `status`/`output`/`lines`)
   — und ist ein Kopf, den der Extraktor schreibt, selbst eine Ausnahme im Sinne von §3.5?
4. **Nur bei Zwischenablage:** berührt ein schreibbarer Mount für den Extrakt
   [`MR-049`](../../../../harness/conventions.md#mr-049--drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein-statt-ihn-per-copy-ins-bild-zu-nehmen)
   (Gate-Rezepte reichen den Baum read-only herein)?

**Antwort als Artefakt:** Verdikt-Report unter `docs/reviews/`; bei Senkung dazu eine ADR im Status
`Proposed`. Bis dahin liegt der Slice in `open/`, **nicht geclaimt** (§4).

**Übernimmt:** nichts. Der Gegenstand der Auflösung bleibt bei [slice-113](slice-113-co-001-ist-faellig.md).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Auflösung von `CO-001`** (Move nach `done/`, Pfad-Nachzug, zehntes `ignore-refs`-Paar, Absatz
  *„GRENZE, keine Regel"*, Bindung und Index) — [slice-113](slice-113-co-001-ist-faellig.md) führt sie
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
      sind behoben; was nur zentral zu führen ist, steht nach dem Verdikt aus §1 mit seinem ganzen
      Gegenstand ([`AGENTS.md`](../../../../AGENTS.md) §3.2, §3.5). `make shell-lint` ist grün, das
      Rezept schließt keine bats-Datei mehr aus, `make gates` ist grün.
      **Rot:** `git grep -c 'shellcheck disable' -- 'test/*.bats'` findet eine Stelle.
- [ ] **(3) Ein Prüfbereich, der wieder schrumpft, wird rot.** Ein Fall in `test/mutations/` nimmt
      `.bats` (oder die Verkettung) aus dem Rezept und färbt seinen Wächter rot; `make mutate`
      läuft ihn grün-als-erwartet ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`Makefile`](../../../../Makefile) | update | `shell-lint` ruft die Verkettung; die Pfad-Liste des Rezepts verliert die Ausnahme (DoD 1, 2) |
| `harness/tools/` (Verkettungs-Skript) | neu, empfohlen | zwei Images lassen sich in einem Rezept nur unleserlich verketten; ein Skript fällt selbst in den Prüfbereich von `shell-lint` und bekommt zwei bats-Fälle nach dem Muster von [`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh) |
| `test/*.bats` | update, soweit Befunde auftreten | Behebung statt Unterdrückung (DoD 2) |
| shellcheck-Konfiguration | neu, **nur nach Verdikt** (§1) | zentraler Eintrag mit ganzem Gegenstand, begrenzt auf den bats-Lauf, falls Frage 2 es verlangt |
| `test/mutations/` | neu | der Fall aus DoD (3) |
| [`harness/README.md`](../../../../harness/README.md) | update | die Vertragszeile von `shell-lint` nennt den erweiterten Prüfbereich |
| `internal/emit/`, [`.harness/baseline`](../../../../.harness/baseline) | **unverändert** | Dogfood; Baseline byte-verifiziert |

**Entwurf der Verkettung — die Wahl trifft der Implementer nach einem Trockenlauf über alle 50 Dateien:**

- **V1 (empfohlen) Zwischenablage:** Schritt 1 `docker run --network none` im `BATS_IMAGE` (Baum
  read-only), schreibt je Datei den Extrakt in ein vorher geleertes, gitignoriertes Verzeichnis unter
  `.harness/state/`; Schritt 2 `shellcheck` im `SHELLCHECK_IMAGE` liest dieses Verzeichnis read-only.
  Die Pins bleiben im `Makefile` und reisen als Umgebung ins Skript — kein zweiter Pin.
- **V2 Pipe ohne Zwischenablage:** Extrakt je Datei auf stdout, `shellcheck -` liest stdin. Kein
  schreibbarer Mount (Frage 4 entfällt), aber 100 Container-Starts und der Dateiname geht verloren,
  den das Skript der Ausgabe voranstellen muss.

## 4. Trigger

**Start** (`open` → `next` → `in-progress`): **der Architect hat die Frage aus §1 beantwortet**
(Verdikt-Report liegt vor, bei Senkung die ADR im Status `Accepted`), der Auftraggeber hat den Slice
priorisiert, und das WIP-Limit ist frei. Ein Wächter für das Vorliegen des Verdikts existiert nicht,
und das steht hier statt eines behaupteten
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
[slice-113](slice-113-co-001-ist-faellig.md) beginnt erst, wenn dieser Slice in `done/` liegt.

**Rückführungen — vorab benannt:**

- `in-progress` → `next`: die Behebung der Befunde ist in **einer** Review-Sitzung nicht prüfbar.
  Dann Re-Slice nach Regel-Klasse, nicht ein vierter DoD-Punkt.
- `in-progress` → `open`: die Verkettung liefert keinen stabilen Extrakt. Dann bekommt `CO-001` den
  gemessenen Grund und einen Trigger, der nicht eingetreten ist; [slice-113](slice-113-co-001-ist-faellig.md)
  entfällt mit diesem Grund.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt, `make gates` grün **ohne** Pfad-Ausnahme, `make mutate` grün einschließlich des
neuen Falls (Verifier trägt den Rot-Beleg der Rücknahme nach, falls er fehlt), Review nach Modul 10 und
Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Extrakt verschiebt Zeilen.** Meldet shellcheck Zeilen des Extrakts statt der Originaldatei,
  ist die Fundstelle für den Leser nicht auffindbar. Der Trockenlauf misst, ob `bats-preprocess` eine
  Rück-Zuordnung trägt. — **Ausgang:** <eingetreten: Folge-Slice | entfallen: Grund | weiter offen: → BEO>
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

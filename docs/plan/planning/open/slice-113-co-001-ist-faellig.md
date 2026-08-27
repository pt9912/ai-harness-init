# Slice slice-113: `CO-001` ist fällig — der Auflösungs-Trigger ist eingetreten, und `shell-lint` erreicht die bats-Rümpfe

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Carveout-Auflösung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — der Gegenstand ist **ein** Carveout und **ein**
Gate-Rezept; der Slice ist einzeln lieferbar und wartet auf keinen zweiten. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser
reaktiv oder gewollt?** Reaktiv: der Auflösungs-Trigger von
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) ist eingetreten und beim vorangegangenen
Audit nicht gesehen worden (§1). Kein Fähigkeits-Sprung — die emittierte Ebene bleibt unberührt,
ein bestehender Gate bekommt den Prüfbereich, den sein Carveout ihm zugesagt hat. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist das `shell-lint`-Rezept **dieses**
[`Makefile`](../../../../Makefile) und der Carveout dieses Repos. Was ein emittiertes Repo an
Shell-Lint bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet — nicht dieser.

**Bezug:**
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) (der Carveout selbst),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Gate-Ausnahme, deren Auflösungs-Trigger eingetreten ist und die weiterläuft, sagt einen
Prüfbereich zu, den sie nicht mehr rechtfertigt),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only, gepinntes shellcheck-Image),
[`AGENTS.md`](../../../../AGENTS.md) §3.2 (kein `# shellcheck disable` ohne begründeten zentralen
Eintrag — die Regel, an der der neue Prüfbereich sofort hängt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage braucht ihr rot gesehenes Gegenbeispiel),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**`shell-lint` liest die Logik in den bats-Dateien, und
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) liegt danach in
`docs/plan/carveouts/done/` — oder der Lauf sagt, welche der zwei im Carveout genannten Techniken <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
warum nicht trägt, und der Carveout wird mit diesem Grund neu gefasst statt stillschweigend
verlängert.**

### Die Ausgangslage: der Trigger ist eingetreten, gemessen an der Eigenschaft, die er nennt

[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) §Auflösungs-Trigger lautet: *„sobald **eine
einzelne .bats-Datei eigene Hilfsfunktionen mit Verzweigung oder Schleifen** trägt (nicht nur
lineare `run`+`assert`-Zeilen)"*. Die Eigenschaft, über die gezählt wird, ist damit gegeben —
**eine Verzweigungs- oder Schleifen-Zeile im Rumpf einer benannten Funktion, die kein
`@test`-Rumpf ist**. Sie ist mit einem Kommando entscheidbar; der Sensor liegt als Programm-Text
neben seiner Zahl, weil ihn kein Gate fährt:

```
awk '/^@test /{t=1;d=1;next}
     /^[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{/{f=1;n=$1;d=1;next}
     (t||f){d+=gsub(/\{/,"{")-gsub(/\}/,"}");
            if(f && $0~/^[[:space:]]*(if|for|while|case|until)[[:space:]]/)
              printf "%s\t%s\t%d\n",FILENAME,n,FNR;
            if(d<=0){t=0;f=0}}' $(git ls-files 'test/*.bats')
```

→ **zwei** Zeilen, beide in **einer** Datei und **einer** Funktion:
[`test/release-matrix.bats`](../../../../test/release-matrix.bats), `lh_platforms()`, Zeilen 47
und 51 — zwei verschachtelte `for`-Schleifen über zwei aus dem Lastenheft gelesene Mengen. Der
Prüfbereich dabei: `git ls-files 'test/*.bats' | wc -l` → **16** Dateien. Beide Zahlen wandern mit
ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Zwei ist eine Untergrenze, mit Absicht.** Dieselbe Funktion trägt zwei
`[ … ] || return 1`-Wächter, die das Muster nicht erfasst — Steuerfluss ohne Schlüsselwort. Wer
die Zahl als Menge liest, liest sie falsch; was sie trägt, ist die Aussage *„der Trigger ist
eingetreten"*, und dafür genügt eine.

**Seit wann, auf die Minute, und welcher Audit daran vorbeigegangen ist.** Die Funktion kam mit
der Datei (`git log --diff-filter=A --format='%h %ad' --date=iso -- test/release-matrix.bats | tail -1`
→ `dfca6c6 2026-07-25 17:17:58 +0200`, slice-048, wellenlos), und `lh_platforms` steht seit
demselben Commit darin (`git log --format='%h %ad' --date=iso -S 'lh_platforms' -- test/release-matrix.bats | tail -1`).
Gegen die drei seitherigen Audits gehalten:

| Audit | Zeitpunkt | Urteil damals | trifft zu? |
|---|---|---|---|
| welle-06-Closure | `git log -1 --format=%ad --date=iso e44cd58` → 2026-07-24 09:45:25 | Trigger nicht erfüllt | **ja** — die Datei existierte nicht |
| welle-07-Closure | `git log -1 --format=%ad --date=iso 5050fa9` → 2026-07-25 08:59:54 | Trigger nicht erfüllt | **ja** — acht Stunden vor der Datei |
| welle-08-Closure | `git log -1 --format=%ad --date=iso 392093f` → 2026-07-27 13:24:04 | Trigger nicht erfüllt | **nein** — die Funktion lag da |

**Die Ursache ist die Frage, nicht die Sorgfalt.** Alle drei Audits fragten *„hat **diese Welle**
eine `.bats`-Datei hinzugefügt, und trägt **die** Verzweigungen?"*. Der Trigger fragt über den
**Bestand**: *„trägt **eine einzelne** `.bats`-Datei …"*. Eine Datei, die zwischen zwei Wellen
aus wellenloser Arbeit entsteht, fällt durch jede Wellen-Frage hindurch — und genau so ist es
gekommen: slice-048 lief ohne Welle.

### Der Nutzen ist gemessen, nicht behauptet: die Datei dokumentiert ihren eigenen Fund

[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) §Begründung trägt die Abwägung *„der Nutzen
einer Teilabdeckung [trägt] den Aufwand aktuell nicht"*. Dieselbe Datei, die den Trigger auslöst,
widerlegt sie an einem realen Fall: ihr Kommentar über
[`test/release-matrix.bats`](../../../../test/release-matrix.bats)`:98-101` hält fest, dass eine
mit `!` negierte Assertion unter `set -e` **nicht** greift, der Fehlschlag verschluckt wird und
eine Mutation dadurch **grün durchlief** — gefunden im Review, von Hand
(`sed -n '98,101p' test/release-matrix.bats`). Genau diese Klasse ist eine benannte
shellcheck-Regel. Ein Sensor, der einen real eingetretenen stillen Grün-Fall gefunden hätte, ist
keine Teilabdeckung ohne Nutzen.

### Ein zweiter Befund aus demselben Audit, hier mitgenommen statt nebenan vergessen

[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) §Geltungs-Konfiguration sagt zu über das
`shell-lint`-Rezept: *„.bats nicht in der Liste — Grund im Kommentar; Verweis ‚CO-001'"*. Gemessen
gibt es diesen Verweis nicht: `grep -c 'CO-001' Makefile` → **0** (Exit 1), und
`git grep -c 'CO-00' -- Makefile .d-check.yml d-check.mk .github/` findet in **keiner**
Gate-Konfiguration eine Carveout-Kennung (Exit 1). Modul 7 §Ziel-Form verlangt sie ausdrücklich —
*„sonst ist die Pfad-Ausnahme im `make gates`-Output eine stille Senkung ohne Begründung"*. Löst
dieser Slice den Carveout auf, entfällt die Ausnahme und mit ihr die Pflicht; löst er ihn **nicht**
auf, ist der Verweis nachzutragen. Beide Ausgänge stehen in DoD (3).

### Die Abwägung: zwei Techniken nennt der Carveout, eine wird gewählt

- **(A) Die `@test`-Rümpfe extrahieren und mit `shellcheck --shell=bash` linten.** Der Weg, den
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) zuerst nennt und den slice-008 als Folge
  vorgesehen hat. Er braucht kein neues Image — `SHELLCHECK_IMAGE` ist gepinnt und läuft schon.
- **(B) Ein bats-natives Lint-Werkzeug einführen.** Der zweite genannte Weg. Er kostet ein neues
  gepinntes Image, einen Freshness-Eintrag und eine zweite Werkzeug-Achse.
- **Die Wahl trifft der Lauf, nicht dieser Plan** — beide sind im Carveout gedeckt, und welcher
  trägt, entscheidet sich an einem Trockenlauf über dem realen Bestand
  ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)-Muster:
  *„Trockenlauf vor dem Pin"*). Was der Plan festlegt, ist die **Reihenfolge**: erst der
  Trockenlauf über allen 16 Dateien, dann die Wahl, dann das Rezept.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) `shell-lint` erreicht die Logik der bats-Dateien, und die Erweiterung ist rot
      gesehen.** Der Prüfbereich wächst um die bats-Rümpfe; das Rezept nennt sie.
      **Rot:** ein absichtlicher shellcheck-Befund in einem `@test`-Rumpf oder einer Hilfsfunktion
      (z. B. die mit `!` negierte Assertion, die den Carveout-Nutzen belegt) färbt `make shell-lint`
      rot, und die Ausgabe nennt **Datei, Zeile und Regel** — nicht nur einen Exit-Code
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Danach zurückgenommen.
      **Heute rot-frei und damit ungedeckt:** `sed -n '/^shell-lint:/,/^$/p' Makefile | grep -c '\.bats'`
      → **0** — das Rezept nennt die Endung in keiner seiner Pfad-Angaben.
- [ ] **(2) Es gibt keine Inline-Suppression, und die Ausnahmen, die bleiben, stehen zentral mit
      Grund.** Ein neu geöffneter Prüfbereich über sechzehn Dateien produziert Befunde; sie werden
      **behoben** oder als zentraler, begründeter Eintrag geführt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.2).
      **Rot:** `git grep -c 'shellcheck disable' -- 'test/*.bats'` liefert einen Treffer.
- [ ] **(3) Der Carveout trägt seinen Ausgang, und der Ausgang ist eine Verzeichnis-Position.**
      **Bei Auflösung:** `git mv docs/plan/carveouts/CO-001-bats-shell-lint.md docs/plan/carveouts/done/`,
      `make gates` grün **ohne** Ausnahme, und die Verifikations-Checkliste des Carveouts ist
      abgehakt. **Bei Nicht-Auflösung:** der Carveout wird mit dem gemessenen Grund neu gefasst —
      welche der zwei Techniken woran scheitert —, sein Auflösungs-Trigger wird durch einen
      ersetzt, der nicht bereits eingetreten ist, **und** der fehlende `# CO-001`-Verweis im
      `shell-lint`-Rezept wird nachgetragen (§1).
      **Rot in beiden Fällen:** `ls docs/plan/carveouts/CO-001-*.md` und
      `grep -c 'CO-001' Makefile` — genau eine der beiden Antworten muss sich bewegt haben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`Makefile`](../../../../Makefile) | update | das `shell-lint`-Rezept und sein Kommentar; die Datei-Liste des shellcheck-Aufrufs ist heute die Ausnahme selbst |
| `harness/tools/` | neu, **nur bei Weg (A)** | der Extraktor der `@test`-Rümpfe. Er ist selbst ein Shell-Helfer und fällt damit in den bestehenden Prüfbereich |
| `test/*.bats` | update, **soweit Befunde auftreten** | die Befunde des neuen Prüfbereichs werden behoben, nicht unterdrückt (DoD 2) |
| [`docs/plan/carveouts/CO-001-bats-shell-lint.md`](../../carveouts/CO-001-bats-shell-lint.md) | `git mv` nach `done/` **oder** update | DoD (3); der Move ist ein eigener Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3) |
| `test/mutations/` | neu | der neue Wächter braucht seinen Fall — ein Prüfbereich, der wieder schrumpft, muss rot werden ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | die zwei Gate-Tabellen beschreiben den Vertrag von `shell-lint`; wächst sein Prüfbereich, wächst die Beschreibung mit. **Norm-Text ist es nicht** — die Zeilen liegen außerhalb der Hard Rules |
| [`.harness/baseline`](../../../../.harness/baseline) | **unverändert** | byte-verifiziert |
| `internal/emit/` | **unverändert** | Ebene Dogfood (Kopfzeile) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit.** Der
Auflösungs-Trigger des Carveouts ist eingetreten; damit ist der Slice fällig, nicht bloß möglich.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: der Trockenlauf liefert so viele Befunde, dass Prüfbereich-Öffnung und
  Befund-Behebung zwei Landungen sind. Dann Re-Slice, nicht ein vierter DoD-Punkt.
- `in-progress` → `open`: beide Techniken scheitern messbar. Dann ist DoD (3) über den zweiten Ast
  zu erfüllen — der Carveout bekommt einen Trigger, der noch nicht eingetreten ist — und der Slice
  geht mit diesem Ergebnis zurück, nicht mit einer Vertagung.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt, `make gates` grün, `make mutate` grün einschließlich des neuen Falls,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der geöffnete Prüfbereich kann viele Befunde liefern.** Sechzehn Dateien, nie gelintet. Die
  Rückführung `→ next` steht dafür in §4; der Cutoff-Reflex — *„ab jetzt, Bestand nicht"* — trägt
  hier **nicht**, weil der Prüfbereich eines Lint-Laufs keine Datei-Historie kennt.
- **Der Extraktor ist ein Werkzeug über Testdateien und selbst ungetestet, wenn niemand ihn
  bindet.** Präzedenz ist [`harness/tools/start-smoke.sh`](../../../../harness/tools/start-smoke.sh):
  Skript plus zwei bats-Tests plus Mutations-Fall.
- **Die Audit-Frage bleibt offen, auch wenn dieser Slice schließt.** Dass drei Audits nach der
  **Welle** statt nach dem **Bestand** fragten, ist ein Befund über die Audit-Methode, nicht über
  diesen Carveout. Er wird hier benannt und **nicht** mitgeschnitten; sein Ort ist die
  Closure-Notiz von [welle-12](../welle-12-erfassungsschicht-emittieren.md), die ihn gefunden hat.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Begründung, weil der Slice
einen Gate-Prüfbereich verändert:

### Sub-Area: Shell-Sensorik dieses Repos (`shell-lint` + `harness/tools/*.sh` + `test/*.bats`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — Docker-only mit gepinntem Image
  ([`ADR-0003`](../../adr/0003-go-native-binaries.md)), Suppression-Verbot
  ([`AGENTS.md`](../../../../AGENTS.md) §3.2), jeder Wächter mit `test/mutations/`-Fall
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- **Phase-Reife:** Phase 4 (Qualität) — der Gate läuft seit slice-008 und ist in beiden
  Gate-Tabellen beschrieben.
- **Evidenz-/Diskrepanz-Risiko:** mittel — der Prüfbereich wird zum ersten Mal geöffnet; wie viele
  Befunde dort liegen, ist vor dem Trockenlauf unbekannt. Genau dafür steht der Trockenlauf **vor**
  der Technik-Wahl in §1.
- **Reconciliation-Aufwand:** S bis M, abhängig vom Trockenlauf. Graduation entfällt (kein BF);
  die Rückführung `→ next` in §4 ist der Ausgang, falls M überschritten wird.

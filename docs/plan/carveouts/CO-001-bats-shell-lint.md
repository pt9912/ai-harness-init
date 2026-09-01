# CO-001: shell-lint deckt die bats-Dateien nicht ab

**Status:** Aktiv — **Auflösung fällig**, nicht offen: der Auflösungs-Trigger ist eingetreten
(Letzte Prüfung unten), und die Auflösung ist als
[slice-113](../planning/open/slice-113-co-001-ist-faellig.md) geschnitten. Die Datei liegt weiter
hier und nicht in `done/`, weil eine Auflösung erst gilt, wenn die Gate-Ausnahme fort und
`make gates` ohne sie grün ist.

**Datum angelegt:** 2026-07-21. **Letzte Prüfung:** 2026-09-01 (welle-10-Trigger-Audit,
[slice-149](../planning/done/slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md):
**Trigger weiterhin EINGETRETEN**, Ausgang **verlängert mit Folge-Slice** — nicht aufgelöst und
nicht permanent. Der Trigger fragt über den Bestand, und der ist gewachsen statt geschrumpft:
`git ls-files 'test/*.bats' | wc -l` → **20**, und die tragende Fundstelle steht unverändert —
`sed -n '30,55p' test/release-matrix.bats | grep -nE '^\s*(if|for|while|case) '` nennt die zwei
verschachtelten `for`-Schleifen im Rumpf von `lh_platforms()`. Die Zahl wandert mit dem Bestand und
ist kein Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Zwei Folge-Slices tragen den Ausgang, und sie sind nicht dieselbe Arbeit:
[slice-141](../planning/next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) entscheidet
**vorher**, [slice-113](../planning/open/slice-113-co-001-ist-faellig.md) **führt aus**).
**Vorherige Prüfung:** 2026-08-27 (welle-12-Closure-Audit:
**Trigger EINGETRETEN**. Der Trigger fragt über den Bestand — *„sobald eine einzelne
`.bats`-Datei eigene Hilfsfunktionen mit Verzweigung oder Schleifen trägt"* —, nicht über die
Neuzugänge einer Welle. Gemessen über alle
`git ls-files 'test/*.bats' | wc -l` → **16** Dateien mit einem awk-Sensor, der
Verzweigungs-Zeilen im Rumpf einer **benannten Funktion** von denen in einem `@test`-Rumpf trennt
(Programm-Text in [slice-113](../planning/open/slice-113-co-001-ist-faellig.md) §1, weil ihn kein
Gate fährt): **zwei** Zeilen, beide in `test/release-matrix.bats`, Funktion `lh_platforms()`,
Zeilen 47 und 51 — zwei verschachtelte `for`-Schleifen. Die Zwei ist eine **Untergrenze**: zwei
`[ … ] || return 1`-Wächter derselben Funktion sind Steuerfluss ohne Schlüsselwort und fallen
durch das Muster. Die Funktion liegt seit
`dfca6c6` (2026-07-25 17:17:58, slice-048, **wellenlos**) im Baum; der Audit vom 2026-07-27 hat
sie übersehen, weil er nach den Neuzugängen **seiner Welle** fragte. welle-12 selbst brachte
`test/span-emit-wrapper.bats` mit
`grep -cE '^\s*(if|for|while|case) ' test/span-emit-wrapper.bats` → **0** — an ihr liegt es
nicht. Zugleich korrigiert: die Zahl im Geltungsbereich stand auf „dreizehn" und steht jetzt an
ihrem Kommando
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1), statt ein drittes Mal von Hand nachgezogen zu werden). **Vorherige Prüfung:**
2026-07-27 (welle-08-Closure-Audit: **unverändert gültig, Trigger nicht erfüllt**. welle-08 selbst fügte **keine** `.bats`-Datei hinzu; die Zahl stieg dennoch von zwölf auf **dreizehn** — `test/comment-claims.bats` kam aus einem wellenlosen Slice derselben Sitzung. Gemessen: die neue Datei trägt **null** Verzweigungen/Schleifen (`grep -cE '^\s*(if|for|while|case) '` → 0), also weiter lineare `run`+`assert`-Logik — der Auflösungs-Trigger verlangt eigene Hilfsfunktionen mit Verzweigung. Die im Geltungsbereich genannte Zahl war auf „elf" stehengeblieben und ist hiermit korrigiert). **Vorherige Prüfung:** 2026-07-25 (welle-07-Closure-Audit: unverändert gültig; welle-07 fügte **keine** `.bats`-Datei hinzu — ihre neuen Wächter sind Go-Tests und `test/mutations/*.sh`, und Letztere werden von `shell-lint` **voll** gelintet. Geltungsbereich und Begründung unberührt). **Vorherige Prüfung:** 2026-07-24 (welle-06-Closure-Audit: drei `.bats`-Dateien hinzugekommen — `component-freshness`, `go-freshness`, `cpp-freshness` —, die unter denselben Glob-Ausschluss fallen).

**Betroffenes Gate:** `shell-lint` (shellcheck im gepinnten Image).

**Geltungsbereich:** alle bats-Dateien unter test/ (Endung .bats). Ihre Zahl liefert
`git ls-files 'test/*.bats' | wc -l` → **16**; sie wandert mit dem Bestand und ist **kein**
Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Shell-Hooks und -Helfer unter harness/tools/, .claude/hooks/,
internal/emit/templates/ und test/mutations/ bleiben **voll** gelintet — der
Ausschluss betrifft ausschließlich die bats-Testdateien.

**Folge-Slice:** [slice-113](../planning/open/slice-113-co-001-ist-faellig.md) — er entscheidet
zwischen den zwei unten genannten Techniken und führt den Ausgang aus (Auflösung mit `git mv` nach
`done/` **oder** Neufassung mit einem Trigger, der noch nicht eingetreten ist). Herkunft der
Aufgabe: [slice-008](../planning/done/slice-008-shell-lint-gate.md), §6-Folge-Punkt.

---

## Begründung

shellcheck parst die bats-@test-Syntax nicht: eine .bats-Datei ist kein
POSIX-/Bash-Skript mit Shebang, sondern ein bats-DSL mit @test-Blöcken. Ein
direkter shellcheck-Lauf über die .bats-Dateien bricht mit **Parse**-Fehlern
(nicht mit echten Lint-Befunden) und wäre damit ein Gate, das nichts Reales
prüft. Der shell-lint-Recipe schließt .bats deshalb bewusst aus (dokumentiert im
Recipe-Kommentar des Makefiles).

Das ist eine technische Werkzeuggrenze, kein „noch nicht geschafft" — die Grenze bleibt, auch
wenn die Ausnahme fällt: ein direkter shellcheck-Lauf über eine `.bats`-Datei wird nie gehen, was
geht, ist ein Vorverarbeitungs-Schritt.

**Die Aufwands-Abwägung, die diesen Carveout trug, ist abgelaufen.** Sie lautete: die bats-Logik
sei dünn (Setup plus lineare `run`+`assert`-Zeilen je Datei), der Nutzen einer Teilabdeckung trage
den Aufwand nicht. Gemessen trägt heute eine Datei eine Hilfsfunktion mit verschachtelten
Schleifen, und dieselbe Datei dokumentiert einen real eingetretenen stillen Grün-Fall der Klasse,
die shellcheck kennt (`sed -n '98,101p' test/release-matrix.bats`). Genau darauf zielte der
Auflösungs-Trigger unten; er ist eingetreten, und die Abwägung ist damit entschieden, nicht mehr
offen.

## Auflösungs-Trigger

Sobald die bats-Logik nennenswert wächst — konkret: sobald **eine einzelne
.bats-Datei eigene Hilfsfunktionen mit Verzweigung oder Schleifen** trägt (nicht
nur lineare `run`+`assert`-Zeilen). Dann die @test-Rümpfe extrahieren und mit
`shellcheck --shell=bash` linten (slice-008-Folge), oder ein bats-natives
Lint-Werkzeug einführen.

## Geltungs-Konfiguration

| Datei | Zeile/Section | Wert |
|---|---|---|
| Makefile | `shell-lint`-Recipe (Kommentar + Datei-Liste des shellcheck-Aufrufs) | .bats nicht in der Liste — Grund im Kommentar; Verweis „CO-001" |

## Verifikation (nach Auflösung)

- [ ] Gate ist für den Geltungsbereich aktiviert (`shell-lint` deckt die bats-Dateien ab).
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-21 | Angelegt (Backlog-Formalisierung, Roadmap §Backlog Cluster E) | [slice-008](../planning/done/slice-008-shell-lint-gate.md) |
| 2026-07-21 | Geprüft, weiterhin gültig | — |
| 2026-07-22 | Audit bei welle-03-Closure: weiterhin gültig — Auflösungs-Trigger nicht erfüllt (welle-03 fügte keine bats-Hilfsfunktion mit Verzweigung/Schleifen hinzu; die vorhandenen `for`-Schleifen liegen in @test-Rümpfen, nicht in Helfern) | — |
| 2026-09-01 | Audit bei welle-10-Closure (Artefaktklasse *Carveout*): Trigger weiterhin **eingetreten**, Ausgang **verlängert mit Folge-Slice** — der Bestand ist von 16 auf 20 `.bats`-Dateien gewachsen, die tragende Fundstelle `lh_platforms()` steht unverändert. Betroffenes Gate bleibt `shell-lint`; ob es unter das Welle-Kriterium *„ohne offenen Carveout auf einem Gate dieser Welle"* fällt, entscheidet die Welle-Closure, nicht dieser Audit | [slice-149](../planning/done/slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md) |

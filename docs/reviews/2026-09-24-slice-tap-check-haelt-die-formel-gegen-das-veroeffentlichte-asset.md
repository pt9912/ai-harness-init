# Review-Report: slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset — 2026-09-24

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der
Verifier).

**Gegenstand:** `git diff 9ca302ec..HEAD` — vier Commits, 20 Dateien, 747 Zeilen hinzu, 5 entfernt:
`de04d408` (Anspruch, reiner Move), `b2f6e3e9` (Roadmap-Zeile), `8f5250b1` (Werkzeug, Doku, bats),
`49398f89` (Mutations-Fälle 409 bis 420). Berührt: `harness/tools/tap-nachzug.sh`,
`harness/tools/tap-nachzug-nutzlast.sh`, `test/tap-nachzug.bats`, `test/mutations/` (409 bis 420),
`Makefile`, `harness/README.md`, `.d-check.yml`, `docs/plan/planning/in-progress/roadmap.md`.

**Plan-Bezug:** Slice `slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset` (§1 Ziel und
Abgrenzung, §2 nur als Referenz für die Zusagen, §3, §4, §6). Kennung, nicht Pfad: der Plan wandert mit
dem Lifecycle.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` (Accepted, vollständig gelesen) · `ADR-0058` ·
`ADR-0059` · `LH-QA-02` · `LH-QA-03` · `MR-014` · `MR-071` · `AGENTS.md` §3 (v.a. §3.6, §3.7, §3.9, §3.10,
§3.11) · `v6.9.0` · `regelwerk/modul-05-planning-harness.md`, `modul-06-roadmap.md`,
`modul-08-agentenrollen.md`, `modul-10-review-harness.md`, `modul-11-verification.md`,
`modul-13-quality-gates.md` (Bezug). Der Implementer-Bericht war Behauptung; Code und Tests sind selbst
gelesen.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt):

- `test/tap-nachzug.bats` einzeln im gepinnten bats-Image (`docker run`, wie das Rezept `test-bats`):
  27 von 27 ok, bats 1.11.0.
- `make docs-check` → `1862 Datei(en) geprüft, 0 Befund(e)`; `make comment-claims` → `76 Datei(en)
  geprueft, 0 Befund(e)`; `make help` nennt `tap-check`.
- **Mutations-Fälle 409 bis 420 emuliert, nicht über `make mutate`:** je Fall eine frische Kopie der
  betroffenen Dateien im Scratchpad, das Skript des Falls dort angewandt, `test/tap-nachzug.bats` im
  bats-Image gefahren. Alle 12 `sed`-Anker ändern die Datei; alle 12 färben mindestens den Fall rot,
  den `# expect:` nennt (Ergebnis je Fall in F-1, F-4, F-8 und den Negativbefunden).
- **Zusatz-Sonden in Scratchpad-Kopien** (nicht im Repo): F-1 (Token zusätzlich als Argument), F-2 (`jq`-
  und `bash`-Aufruf in der Nutzlast), F-4 (Zeichenmenge und Anker der Tag-Form gelockert), F-5
  (`TMPDIR` unbeschreibbar).
- **Reales Bild, ohne Netz:** die Nutzlast im digest-gepinnten Bild aus `harness/tools/tap-nachzug.sh`
  (curl 8.16.0, BusyBox 1.37.0), gegen `127.0.0.1` (unerreichbar → Exit 2 mit Meldung; `curl -H @<Datei>`
  gegen einen `nc`-Listener sendet den Header aus einer 0600-Datei).
- `make tap-check TAG=v01.0.0` (Exit 2 auf dem Host, vor `docker`) und `make tap-check TAG=v1.0.0-rc.1`
  (Exit 0, ohne Netz), einmal unter `LC_ALL=C`, einmal unter `de_DE.UTF-8`.
- `make gates` — siehe Ende des Reports.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Die Zusage *„der Sentinel steht in keiner Argumentliste"* hängt in `test/tap-nachzug.bats` an `! grep -qF "$S" "$STUB_LOG_CURL" "$STUB_LOG_DOCKER"` (Zeilen 314 und 328), mitten im Fall. Unter bats' `set -e` löst ein invertiertes Kommando (`!`) keinen Abbruch aus, und nur das **letzte** Kommando eines Falls bestimmt sein Ergebnis; beide Zeilen sind wirkungslos. Gemessen: Die Nutzlast übergibt das Token **zusätzlich** als `-H "X-Debug: ${TAP_TOKEN}"` (Header-Datei bleibt, `unset TAP_TOKEN` entfällt) → **kein** Fall der Suite wird rot, obwohl das Token dann in der Prozess-Kommandozeile steht. Fall 416 färbt Fall „token: ein Sentinel-Token …" rot, aber über eine **andere** Zeile: `grep -q -- '-H @'` (Zeile 315) findet die Header-Datei nicht mehr, weil 416 sie **ersetzt**, nicht ergänzt. Die Ursache der Zusage (Token in der Argumentliste) trägt das Rot nicht; `ADR-0064` §Fitness Function nennt genau diese Schwächung („Header als `-H "Authorization: Bearer $TAP_TOKEN"` → der Argument-Fall wird rot") und verlangt, dass der Fall aus diesem Grund rot wird. | `AGENTS.md` §3.6 · `ADR-0064` Festlegung 4, §Fitness Function (Token-Zeile) · `v6.9.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen | `test/tap-nachzug.bats` Zeilen 314, 315, 328; `test/mutations/416-tap-check-token-als-argument.sh` | ja — Sonde: Token zusätzlich als Argument, `test/tap-nachzug.bats` einzeln: 0 rote Fälle | Negation `!` mitten im bats-Fall ohne Wirkung |
| F-2 | HIGH | Der Fall „nutzlast: die Datei ist ein POSIX-sh-Skript und ruft nur Programme des Bild-Bestands" führt `! grep -qE … <(…)` in einer `for`-Schleife über `jq bash git gh python3` (Zeilen 381 bis 383). Der Fall endet mit der Schleife; deren Status ist der des **letzten** Durchlaufs (`python3`). Die vier Programme, die `ADR-0064` §Lage als fehlend im Bild misst (`jq`, `bash`, `git`, `gh`), können den Fall nicht rot färben. Gemessen: ein `bash -c true` in der Nutzlast → Fall bleibt grün (0 rote Fälle); ein `jq`-Aufruf färbt nur die Fälle rot, die die Nutzlast laufen lassen (das Bild des Stubs hat kein `jq`), nicht diesen. Der Test-Name behauptet eine Eigenschaft, die er nur für `python3` misst. | `AGENTS.md` §3.6 (Test-Name behauptet, was der Test nicht misst) · `ADR-0064` Festlegung 5 (Maßstab: nur Programme des gemessenen Bestands) | `test/tap-nachzug.bats` Zeilen 379 bis 384 | ja — Sonde: `bash -c true` in der Nutzlast, Fall bleibt grün | Negation `!` mitten im bats-Fall ohne Wirkung |
| F-3 | MEDIUM | **Plan-/ADR-Widerspruch, kein Implementer-Fehler:** `make` beendet jedes fehlschlagende Rezept mit Exit 2. Über `make tap-check` sind Exit 1 (Formel-Unterschied) und Exit 2 (nicht ausführbar) am Prozess-Exit nicht zu unterscheiden; nur die Zeile `Error 1` bzw. `Error 2` von make trägt den Exit des Skripts (gemessen: `make tap-check TAG=v01.0.0` → Skript-Exit 2, make-Zeile `Error 2`). `ADR-0064` Festlegung 2 nennt die drei Klassen *„an der Form erkennbar"*, §Fitness Function und Plan §2 Liefer-Punkt 3 (b) verlangen für `make tap-check TAG=v0.2.2` **Exit 1**, Festlegung 6 macht die Meldung des Schnitts von einem Exit des `make`-Ziels abhängig. Der Implementer hat den Befund benannt und in Makefile-Kommentar, Skript-Kopf und README-Zeile ehrlich dokumentiert; die Ehrlichkeit löst den Widerspruch nicht. | `ADR-0064` Festlegung 2 (Exit-Tabelle), Festlegung 6, §Fitness Function (Rot-Beleg am realen Zustand) · Plan §2 Liefer-Punkt 3 (b) | `Makefile` Zeilen 478 bis 486; `harness/README.md` (Zeile `make tap-check`); `harness/tools/tap-nachzug.sh` Zeilen 14 bis 15 | ja — `make tap-check TAG=v01.0.0`, Exit des Prozesses ablesen | Exit-Vertrag der ADR über `make` nicht erreichbar |
| F-4 | MEDIUM | Die Zusage *„Pre-Release- und Build-Feld nur aus `[0-9A-Za-z.-]`, nicht leer; jede andere Form → Exit 2"* hat kein bindendes Gegenbeispiel. Gemessen in Kopien: Zeichenmenge beider Felder auf `.+` gelockert → 0 rote Fälle; Anfangsanker der Tag-Form entfernt → 0 rote Fälle; Endanker entfernt → 1 roter Fall. Die zwei Tags, die Plan und ADR nennen (`v1.0.0$(touch${IFS}marker)`, `v1.0.0;x`), enden im Kern-Feld an der Feldform, **nicht** an der Tag-Form; ein Tag wie `v1.0.0-rc$(id)` oder `v1.0.0-rc;x` (Vorab-Zweig, Exit 0 vor jeder Feldform-Stufe) und ein Build-Feld mit Shell-Zeichen kommen in keinem Fall vor. Fall 413 färbt nur über die Meldung `Tag-Form falsch` (Zeile 280) und nur für **einen** der fünf Tags der Schleife; `ADR-0064` §Fitness Function erwartet dort *„Marker/Aufruf-Zähler wird rot"*, was durch die nachgelagerte Feldform nicht eintritt. Der Wert wird im Vorab-Zweig unmaskiert gedruckt (`printf '%s'`), im Stabil-Zweig als `-e`-Wert und in die URL gereicht, nie ausgewertet: kein Ausführungs-Pfad, aber die Zusage der Form ist ohne Zahn. | `AGENTS.md` §3.6 · `ADR-0064` Festlegung 1 (Formprüfung vor jeder Verwendung), §Fitness Function (Tag-Eingabe) · `MR-071` (Anker-Messung; Anker selbst treffen) | `harness/tools/tap-nachzug.sh` Zeile 60; `test/tap-nachzug.bats` Zeilen 268 bis 281; `test/mutations/413-tap-check-tag-form-fehlt.sh` | ja — Sonde: Zeichenmenge bzw. Anfangsanker gelockert, `test/tap-nachzug.bats` einzeln grün | Formprüfung ohne Gegenbeispiel je Zeichenklasse und Anker |
| F-5 | MEDIUM | Ein unerwarteter Fehlschlag **innerhalb** der Nutzlast endet als Exit 1, der Klasse *„Formel-Unterschied"*. `set -eu` reicht den Status des ersten scheiternden Kommandos durch: gemessen mit `TMPDIR=/nonexistent` → `mktemp: No such file or directory`, Exit **1**, ohne Digests und ohne Meldung. Ebenso Exit 1 bei einem scheiternden `printf … >"$hdr"` (volle Platte) oder `sha256sum`. Das Host-Skript reicht 1 unverändert durch (`0 | 1 | 2) exit "$rc"`); der Fall „transport" (docker Exit 125) deckt nur den Weg **vor** der Nutzlast. `ADR-0064` Festlegung 2: *„Ein Lesefehler ist damit nie 1 und nie 0"*, Exit 1 nennt beide Digests und die abweichende Zeile. | `ADR-0064` Festlegung 2 (Exit-Tabelle, Absatz *„Ein Lesefehler …"*) · `AGENTS.md` §3.6 | `harness/tools/tap-nachzug-nutzlast.sh` Zeilen 23 bis 37; `harness/tools/tap-nachzug.sh` Zeilen 100 bis 102 | ja — Sonde: `TMPDIR=/nonexistent` mit der Nutzlast, Exit 1 | Interner Fehler der Nutzlast endet als Formel-Unterschied |
| F-6 | LOW | Makefile-Kommentar und README-Zeile nennen make's Meldung *„Fehler N"*. make schreibt sie sprachabhängig: unter `LC_ALL=C` `Error 2`, unter `de_DE.UTF-8` `Fehler 2` (beides gemessen). Die Aussage trägt nur in der deutschen Locale. | Maintainability (Zusage-Präzision, `AGENTS.md` §3.7) | `Makefile` Zeilen 478 bis 481; `harness/README.md` (Zeile `make tap-check`) | ja — `make tap-check TAG=v01.0.0` unter zwei Locales | Locale-abhängige Meldung als Zusage zitiert |
| F-7 | LOW | Der Kopfkommentar der Nutzlast nennt als aufgerufene Programme `curl, cmp, sha256sum, sed, awk, mktemp, sleep`. Die Nutzlast ruft `sed` nicht und ruft `rm` (im `trap`), das die Liste nicht nennt. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `harness/tools/tap-nachzug-nutzlast.sh` Zeilen 3 bis 6 | ja — `grep -n 'sed' harness/tools/tap-nachzug-nutzlast.sh` findet nur den Kommentar | Kommentar-Liste weicht vom Code ab |
| F-8 | LOW | Fall „token: ein Sentinel-Token …" prüft `[ "$(cat "$STUB_LOG_HDR")" = "modus=600 bearer=1" ]`, also **genau eine** Header-Datei = ein Lese-Aufruf. Mutation 412 (Sofort-Gleich wartet und liest ein zweites Mal) färbt darum **zusätzlich** diesen Fall rot (gemessen: 412 → Fälle 10 und 19). Ein legitimes zweites Lesen (etwa die Nachkontrolle des Folge-Schnitts über dieselbe Einheit) bräche den Token-Fall aus einem Grund, der mit dem Token nichts zu tun hat. | Maintainability | `test/tap-nachzug.bats` Zeile 316; `test/mutations/412-tap-check-sofort-gleich-wartet.sh` | ja — Mutation 412 in einer Kopie, Ausgabe der roten Fälle | Fall koppelt zwei Zusagen (Token-Umgang, Zahl der Lesungen) |
| F-9 | INFO | Commit `b2f6e3e9` (Rolle Implementer) entfernt die Ruhe-Marker-Zeile der Roadmap. **Zulässig, und hier die Quelle:** die `planning`-Regel hält den Marker gegen das Verzeichnis in beide Richtungen (`v6.9.0` · `regelwerk/modul-06-roadmap.md` §Roadmap-Struktur, *Offene Wellen*; `.d-check.yml`, Grund-Code `planning-drift`); ein beanspruchter Slice bei stehendem Marker färbt `make docs-check` rot (Grund-Code laut `MR-063`; das Rot selbst ist in diesem Lauf nicht gemessen). Keine Quelle benennt die schreibende Rolle der Zeile: `AGENTS.md` §3.8 bindet nur Hard Rules und Adaptions-Block an den Architect, §3.10 bindet nur den **Abschluss** an den Planner (die Marker-Zeile ist kein Closure-Artefakt; ihre Wiederherstellung beim Abschluss ist es, und der Commit-Text nennt sie als Planner-Schritt). Die Vorbild-Commits `8c0b6a39` und `02a724e3` tragen „Rolle Planner"; das ist Repo-Praxis, keine Norm, und wird hier nicht als Maßstab gelesen. Zwischen `de04d408` und `b2f6e3e9` ist das Repo rot (Marker bei beanspruchtem Slice) — dieselbe Zweier-Folge wie bei den Vorbildern; beide gehören in denselben Push. Kosmetik: die Löschung lässt zwei Leerzeilen zurück (die Vorbilder löschten die Leerzeile mit). Offen an den Architect: welche Rolle die Zeile schreibt, sagt keine Quelle. | `AGENTS.md` §3.8, §3.10 · `v6.9.0` · `regelwerk/modul-06-roadmap.md`, `regelwerk/modul-08-agentenrollen.md` (Planner → Implementer: Slice in `in-progress/`) | `docs/plan/planning/in-progress/roadmap.md` Zeilen 19 bis 23 | ja — `make docs-check` (grün mit dem Commit; das Rot ohne ihn ist nicht selbst gemessen, Quelle die Tabelle in `MR-063`) | Schreibende Rolle einer abgeleiteten Roadmap-Zeile nicht benannt |
| F-10 | INFO | Die hermetischen Fälle sind eine Fixture: Stubs für `curl` und `docker`, keine Prüfung des `Accept`-Kopfs, der Weiterleitung der Download-Adresse, der 404-Form. Am realen Bild ohne Netz gemessen (nicht Ersatz für den Beleg des Liefer-Punkts 3 (b), den der Verifier trägt): die Nutzlast läuft unter der BusyBox-`sh` des gepinnten Bilds (Exit 2 mit Meldung bei unerreichbarem Asset, keine Reste in `/tmp`), `curl` 8.16.0 sendet `-H @<Datei>` aus einer 0600-Datei. Der reale Rot-Beleg gegen `v0.2.2` und `v0.2.3` steht aus (Netz an genau diesem Aufruf; nicht Gegenstand des Reviews). | `ADR-0064` §Grenze · Plan §6 (Stubs als Fixture) | `harness/tools/tap-nachzug-nutzlast.sh`; `test/tap-nachzug.bats` Zeilen 1 bis 20 | nein — braucht Netz und den Tap-Stand des Tages | Fixture-Grenze benannt, Real-Beleg offen |
| F-11 | INFO | Der Mount `-v "$nutzlast:/nutzlast/…:ro"` trägt den Pfad des Repos ungeprüft in einen `-v`-Wert (`src:dst:opt`): ein Repo-Pfad mit `:` wird von `docker` anders gelesen, der Lauf endet dann als `docker`-Fehler (Exit 125 → Exit 2, laut). Kein stilles Grün. | Maintainability (Portabilität) | `harness/tools/tap-nachzug.sh` Zeile 98 | nein | Pfad im `-v`-Wert ungeprüft |
| F-12 | INFO | Dieselbe Klasse wie F-1/F-2 steht in anderen bats-Dateien als Vorkommen einer Form, nicht als Befund: `grep -nE '^\s+! ' test/*.bats \| grep -v tap-nachzug \| wc -l` → **46** (Stand des Laufs, kein Erwartungswert). Nicht bewertet: jede Stelle ist letztes Kommando eines Falls (wirksam) oder mitten im Fall (wirkungslos) — die Zahl trennt beides nicht. | Maintainability | `test/` | ja — je Stelle eine Sonde | Negation `!` mitten im bats-Fall ohne Wirkung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `harness/tools/tap-nachzug.sh`: Ablauf a, c, e; Modus-Argument; `sync` endet mit Exit 2 und der Meldung *„nicht implementiert"*, kein leerer Rumpf | geprüft, ohne Befund |
| Tag-Form, Feldform (9 Stellen, führende Null), Schritt a vor Schritt c, Formprüfung auf dem Host vor `docker` (Code, nicht Test-Bindung — die steht in F-4) | geprüft, ohne Befund |
| Vorab-Regel: Metadatum zuerst abgeschnitten, `printf` der Meldung erst **nach** der Formprüfung; Regel des Skripts entscheidet dieselben Tags wie die Zeile im `publish`-Job (Fall 14 liest sie aus `.github/workflows/release.yml`, Fälle 409 und 410 färben ihn rot) | geprüft, ohne Befund |
| Vergleich byte-genau über Dateien (`cmp`), Endzeilenumbruch und Nicht-ASCII-Byte, zweites Lesen nach 65 s (Default gemessen), Sofort-Gleich ohne Wartezeit, Meldung nennt beide Digests und die erste abweichende Zeile **des zweiten Lesens** | geprüft, ohne Befund |
| Token im Code: Header per Builtin `printf` in eine Datei unter `umask 077` (Fall rot bei entferntem `umask`), `curl -H @<Datei>`, `unset TAP_TOKEN`, Datei nach dem Lauf entfernt (`trap … EXIT`), kein `set -x`, keine Antwort der Schnittstelle in der Ausgabe (Fall 20 wirksam: `[[ … != … ]]`), kein Token beim Laden des Assets (`-L` ohne Header, kein Header-Leck über Weiterleitung) | geprüft, ohne Befund am Code (Test-Bindung: F-1) |
| Pin-Prüfung `*@sha256:*` und Kopplung an `TRAEGER_IMAGE` (Fälle 22 und 23, Mutationen 415 und 417 färben sie); Vorgabe byte-gleich zu `harness/tools/traeger-fetch.sh` | geprüft, ohne Befund |
| Injektion über `TAG` und `TAP_*`: Tag nie ausgewertet, `-e`-Werte einzeln, Nutzlast zitiert jede Variable, Mount `:ro`; das Rezept trägt weder `$(TAG)` noch `${TAG}` (Fall 17) | geprüft, ohne Befund (Grenze des lokalen Wegs: `make` wertet `TAG=…` vor dem Skript aus, in `ADR-0064` §Grenze benannt) |
| Docker-only (`AGENTS.md` §3.9): Host braucht `bash`, `docker`, `make`; die Nutzlast ruft `curl`, `cmp`, `sha256sum`, `awk`, `mktemp`, `sleep`, `rm` und Builtins, kein `jq`, `bash`, `git`, `gh` | geprüft, ohne Befund (Test-Bindung dieser Eigenschaft: F-2) |
| Portabilität der POSIX-`sh`-Nutzlast: läuft im bats-Image (Alpine-BusyBox) über alle 27 Fälle und unter der `sh` des gepinnten Transport-Bilds (Sonde, F-10) | geprüft, ohne Befund |
| Mutations-Fälle 409 bis 420 nach `MR-071`: jeder `sed`-Anker ändert die Datei am heutigen Bestand; jeder Fall färbt in der emulierten Kopie den Fall rot, den `# expect:` nennt (409: Fälle 13, 14 · 410: 14 · 411: 2, 3, 8, 9 · 412: 10, 19 · 413: 15 · 414: 16 · 415: 22 · 416: 19 · 417: 23 · 418: 5 · 419: 4 · 420: 25); Verdrahtung statt Nachbau (die Fälle fahren das Skript und die Nutzlast als Dateien). Ausnahmen der **Bindung**: 416 (F-1), 413 (F-4), 412 (F-8) | geprüft, ohne Befund an Anker und Wirkung |
| `Makefile`: `tap-check` in `.PHONY`, nicht in `gates` und nicht in `record-gates` (Fall 18), Kommentar in Zustandsform, Hilfetext mit `NICHT in gates` | geprüft, ohne Befund (Wortlaut *„Fehler N"*: F-6) |
| `harness/README.md` §Werkzeuge und `targets.exempt-targets`: Zeile mit `kein Gate`, Eintrag exakt (kein Glob), Zählung im Kommentar der `.d-check.yml` stimmt zur Liste (20 Einträge); `make docs-check` 0 Befunde | geprüft, ohne Befund |
| Abgrenzung (Plan §1): kein `sync`-Verhalten (nur die Absage mit Exit 2), kein Gate, kein Adaptions-Eintrag, kein neues ADR, `harness/tools/traeger-fetch.sh` und Release-Workflow unberührt (`git diff --stat`) | geprüft, ohne Befund |
| Kommentare (`AGENTS.md` §3.7) in Skript, Nutzlast, bats-Datei, Mutations-Fällen: Zusage, Kopplung, Grenze, Zustandsform, keine Befund-Kennung, keine Chronik | geprüft, ohne Befund (Ausnahme: F-7) |
| Größe und Schnitt: 747 Zeilen, davon 384 die bats-Datei, 12 Fälle je 10 bis 12 Zeilen, zwei Skripte von 104 und 116 Zeilen; drei Liefer-Punkte, zwei Schichten — in einer Sitzung prüfbar | geprüft, ohne Befund |
| Rollen-Grenze `AGENTS.md` §3.10: der Slice-Plan §7 ist leer, kein Closure-Schritt im Diff | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 3 |
| LOW | 3 |
| INFO | 4 |

**Finding-Klassen dieses Laufs:** Negation `!` mitten im bats-Fall ohne Wirkung · Exit-Vertrag der ADR über
`make` nicht erreichbar · Formprüfung ohne Gegenbeispiel je Zeichenklasse und Anker · Interner Fehler der
Nutzlast endet als Formel-Unterschied · Locale-abhängige Meldung als Zusage zitiert · Kommentar-Liste
weicht vom Code ab · Fall koppelt zwei Zusagen · Schreibende Rolle einer abgeleiteten Roadmap-Zeile nicht
benannt

## Verdikt

**Merge-blockierend:** ja — F-1 und F-2 sind HIGH (Verstoß gegen `AGENTS.md` §3.6: eine Zusage, deren
Gegenbeispiel nicht aus dem behaupteten Grund rot wird, im Sicherheitspfad des Tokens), F-3 bis F-5 sind
MEDIUM und vor dem Merge zu klären.

**Übergabe:**

- **F-1, F-2, F-4, F-5 → Implementer.** Der Code des Token-Umgangs hält die Zusage (Negativbefund); offen
  ist, ob die Fälle sie binden.
- **F-3 → Architect (Verdikt) und Planner (Wortlaut der DoD 3 (b)); nicht der Implementer.** Dieser
  Befund ist kein Diff-Fehler: `ADR-0064` (Accepted, `AGENTS.md` §3.4) und der Plan verlangen an `make`
  etwas, das GNU make nicht liefert. Der Konflikt-Pfad aus `v6.9.0` · `regelwerk/modul-08-agentenrollen.md`
  §Konflikt-Pfad als Rollen-Sequenz gilt: ein Verdikt als Artefakt (Plan-Korrektur oder Folge-ADR mit
  `Supersedes ADR-0064`), nicht „herabstufen, weil der Implementer es dokumentiert hat".
- **F-9 → Architect** (Frage nach der schreibenden Rolle der Roadmap-Zeile), **F-6, F-7, F-8, F-10 bis
  F-12 → Implementer** nach dessen Ermessen.
- Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser
  Report ist ein Lauf-Beleg und ersetzt keine Verifikation: DoD-Konformität, den realen Rot-Beleg und den
  Beleg der Fälle unter `make mutate` prüft der Verifier.

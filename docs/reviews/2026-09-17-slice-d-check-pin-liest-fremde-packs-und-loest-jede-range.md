# Review `slice-d-check-pin-liest-fremde-packs-und-loest-jede-range` (Runde 1) — 0 HIGH · 2 MEDIUM · 3 LOW · 2 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `59cc6eee` (HEAD), Basis
`c07600ac`; sieben Commits, davon `66dcc433` (Architect) und `59cc6eee` (Implementer) **lokal**,
die übrigen fünf gepusht · **Review-Art:** Review gegen Plan, ADRs, Adaptions-Block und Hard Rules
(`v6.9.0` · `regelwerk/modul-10-review-harness.md`) · **Nicht Gegenstand:** die DoD-Abhakung, denn
die prüft die Verifikation (`v6.9.0` · `regelwerk/modul-11-verification.md`).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Slice-Plan `slice-d-check-pin-liest-fremde-packs-und-loest-jede-range`: §1 Ziel und Abgrenzung,
  §2 DoD (als Vertrag gelesen, nicht abgehakt), §3 Plan, §4 Trigger, §6 Risiken, §8.
- Der Plan-Änderungs-Commit `e4b44dd3` (Planner) mit seiner Begründung.
- `AGENTS.md` §3.1, §3.4, §3.5, §3.6, §3.7, §3.8, §3.9, §3.11.
- Adaptions-Block: `MR-010`, `MR-025`, `MR-032`, `MR-033`, `MR-039`, `MR-046`, `MR-048`, `MR-053`,
  `MR-054`, `MR-055`, `MR-061`, `MR-062`, `MR-063`, `MR-064`, `MR-065` und der neue `MR-066`;
  dazu `harness/conventions.md` §Adaptions-Block (Disziplin) und die Eintrags-Vorlage
  `v6.9.0` · `templates/harness/conventions/MR-NNN-titel.template.md`.
- `LH-QA-01`, `LH-QA-02`.
- Frühere Reports in `docs/reviews/` zum selben Modul-Umfeld (`docs-check`, `slice-mv`),
  gesichtet über den Dateinamen; die dort wiederkehrende Klasse *Stellen-Messung als Eigenschaft
  ausgegeben* ist in diesem Diff gezielt gesucht.

---

## Eigene Messung

Die Angaben des Implementers und des Architects sind nicht übernommen. Nachgemessen ist
read-only im Arbeitsbaum (`grep`, `git`, `docker run … :ro`) und in einer Wegwerf-Kopie im
Scratchpad; der Arbeitsbaum ist nicht verändert. Der Klon des Werkzeugs (`/Development/d-check`)
ist nur gelesen.

| Gegenstand | Kommando | Ergebnis |
|---|---|---|
| Fragment-Hunks gegen den neuen Digest | `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:2f2f2460… --print-mk) d-check.mk \| grep -c '^[0-9]'` | `6` — deckt die Zahl in `MR-066` |
| Digest lokal belegt | `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.76.3` | `sha256:2f2f24601251d6b6c1dda13c4a847039a88abfd7e2de508d64180be97bfd2af0` — deckt Pin und Eintrag |
| Fragment-Differenz der zwei Stände | `diff <alt.mk> <neu.mk> \| grep -c '^[0-9]'` an Kopien von `55c2e641^` und `55c2e641` | `4` — deckt die Zahl in der Gegenmessung |
| Zeilenbewegung im Fragment | `git show --numstat --format= 55c2e641 -- d-check.mk` | `5 5` — deckt „fünf Zeilen, alle Tag oder Digest" |
| Kopplung `regelwerk-check` | das `diff`-Kommando aus dem Makefile-Kommentar über dem Ziel | keine Ausgabe, Exit 0 — deckungsgleich mit der `modules:`-Zeile |
| Quell-Differenz, Regeldateien | `git -C <Klon> diff --numstat v0.76.1 v0.76.3 -- internal/hexagon/core/rules/` | genau `commits.go`, `commits_test.go`, `vcs.go`, `vcs_test.go` — keine Regeldatei eines der neun aktiven Module |
| Quell-Differenz, Produktivcode gesamt | `git -C <Klon> diff --numstat v0.76.1 v0.76.3 -- 'internal/**' ':!*_test.go'` | genau `adapter/driven/git/git.go`, `adapter/driven/git/packalias.go`, `rules/commits.go`, `rules/vcs.go` — die Bilanz-Aussage ist auf dieser Achse **vollständig** |
| Marken-Zahlen des Eintrags | `grep -c 'keinen eigenen Block' d-check.mk`, `grep -c '^structure:' .d-check.yml`, `git ls-tree -r HEAD .claude/rules/ \| awk '$1=="120000"' \| wc -l` | `3`, `1`, `10` — decken die Zahlen in `MR-066` |
| Präfix-Zahl des Eintrags | `grep -c 'Praefix .pack-. oder .loose-.' .d-check.yml` | **`0`**, der Eintrag nennt `1` — siehe F-1 |
| Emittierte Startkonfiguration | `grep -m1 'modules:' internal/emit/templates/d-check.yml`, `grep -cE '^(vcs\|commits):' internal/emit/templates/d-check.yml` | `[links, anchors, ids, matrix, spans]`, `0` — unverändert |
| `.d-check.yml`: Regel berührt? | Diff über die Nicht-Kommentarzeilen | `0` geänderte Nicht-Kommentarzeilen — die Abgrenzung aus §1 hält |
| Wächter fängt die unauflösbare Basis | `grep -n 'NICHT aufloesbar' harness/tools/history-range-guard.sh` | Z. 165–168: `git rev-list --count` schlägt fehl, Meldung, `exit 2` — die neue Aussage der Sensor-Datei trägt |
| E2E-Tabelle aktuell | `bash harness/tools/e2e-abdeckung.sh harness/tools/full-smoke.sh <scratchpad>`, dann `diff` gegen `docs/user/e2e-abdeckung.md` | identisch bis auf die Link-Tiefe, die aus dem Ablageort des Sonden-Ziels folgt; alle 16 Zeilennummern und Texte gleich |
| Restbestand `v0.76.1` | das Zählkommando aus §1 des Plans | 11 Zeilen in vier Sensor-Dateien, **jede** als datierter Mess-Operand oder als Gegenüberstellung `v0.76.1` ↔ `v0.76.3`; keine nennt `v0.76.1` als geltenden Stand |
| Rollen-Grenze | `git show --pretty=format: --name-only` je Commit | `66dcc433` berührt ausschließlich `AGENTS.md`, `harness/conventions.md` und drei Dateien unter `harness/conventions/`; kein Implementer-Commit berührt eines davon |

**Nicht nachgemessen:** die Gegenmessung selbst (zwei Kopien, Marker-Entwertung, Sonden-Satz:
1618/57/76) und die vier Range-Messungen an den Wegwerf-Klonen. Sie brauchen je zwei
Image-Läufe über einer präparierten Kopie; die Angaben sind gelesen und auf Widerspruchsfreiheit
geprüft, nicht wiederholt. Für den Schluss *keine Senkung* ist die **Quell-Differenz** unabhängig
nachgemessen (Zeilen 6 und 7 oben) und trägt ihn allein für die Regeldateien; die Gegenmessung
trägt die datei-scannenden Pfade und bleibt insoweit unbestätigt.

## Findings

Schema: `.harness/skills/reviewer.md` §Output-Schema (`v6.9.0` ·
`regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Das Feld `Löst auf` belegt die Ablösung des Wortlauts aus `MR-065` Setzung 2 mit `grep -c 'Praefix .pack-. oder .loose-.' .d-check.yml` → **1**. Das Kommando liefert **0**: Der Kommentar setzt die zwei Präfixe durch einen Zeilenumbruch nach dem Wort „oder" auf zwei aufeinanderfolgende Zeilen, und `grep` liest zeilenweise. Die belegte Aussage stimmt, ihr Beleg nicht. | `MR-025` (eine Zahl steht neben dem Kommando, das sie liefert) | `harness/conventions/MR-066-d-check-pin-v0763-packs-unter-fremdem-praefix-lesbar-range-immer-aufgeloest.md`, Feld `Löst auf`, zweiter Unterpunkt | ja: das Kommando selbst, im Arbeitsbaum | Zahl von ihrem eigenen Kommando widerlegt |
| F-2 | MEDIUM | Zwei neu geschriebene Kommentare begründen im Konjunktiv über die verworfene Alternative: „— sie liefe sonst unter einer Zusage, die sie nicht traegt" und „— dort waere das Gruen nicht mehr herstellbar und die Behauptung falsch". `AGENTS.md` §3.7 führt genau diese Form als *falsch* und bindet sie ab Einführung, also für jeden Kommentar, der geschrieben wird. | `AGENTS.md` §3.7 | `harness/tools/full-smoke.sh`, Kopf von `blind_gruen_ohne_waechter` (Block (d) im Aufrufer und die Vorbedingung in der Funktion) | nein: kein Modul und kein `make mutate`-Fall liest Kommentar-Klassen | Kommentar begründet im Konjunktiv über die verworfene Alternative |
| F-3 | LOW | Dasselbe Feld sagt, den abgelösten Wortlaut führten „die Sensor-Dateien und der Kommentar am `commits`-Block seit diesem Sprung um das Präfix `loose-` erweitert". Für den Kommentar stimmt das; die zwei Sensor-Dateien führen den Präfix-Wortlaut **nicht** erweitert, sondern ersetzt: sie sprechen jetzt von „einem Pack mit passendem/gültigem Index oder lose". | `MR-053` (der Eintrag datiert seine Werkzeug-Aussage) · Maintainability | `MR-066`, Feld `Löst auf`, zweiter Unterpunkt, gegen `harness/sensors/commit-msg-check.md:81` und `harness/sensors/history-range-guard.md:57` | ja: die zwei Zeilen lesen | Ablösungs-Beleg beschreibt die Zieltexte anders, als sie lauten |
| F-4 | LOW | Die neue Kopf-Marke schließt mit „Der Auflösungs-Trigger dieses Eintrags ist damit eingelöst." Das Feld `Auflösungs-Trigger` von `MR-064` lautet `permanent`; eingetreten ist die darin genannte **Neu-Prüf-Bedingung**. `harness/conventions.md` §Adaptions-Block knüpft an den eingetretenen Auflösungs-Trigger den `git mv` nach `conventions/done/` — die Marke friert mit dem Push ein und lädt einen späteren Lauf zu genau diesem Zug ein. | `harness/conventions.md` §Adaptions-Block (Disziplin) · `MR-046` | `harness/conventions/MR-064-d-check-pin-v0761-vcs-bricht-bei-unlesbarem-objekt-ab.md:5` | nein: kein Modul hält Feldwert und Verzeichnis-Position zusammen | Marke nennt den permanenten Trigger eingelöst |
| F-5 | LOW | `blind_gruen_ohne_waechter` nimmt den Aufbau als vierten Parameter mit Vorbelegung `flachen Klon`. Die beiden heutigen Aufrufe setzen ihn; ein dritter ohne Argument beschriftet auch einen vollständigen Klon als flachen — und die Beschriftung steht in der **Beleg-Zeile**, die die Stufe ausgibt. | Maintainability (latente Wartungsfalle) · `LH-QA-01` | `harness/tools/full-smoke.sh`, Zeile `local repo="$1" ziel="$2" kennung="$3" aufbau="${4:-flachen Klon}"` | nein | Vorbelegung eines Beleg-Etiketts |
| F-6 | INFO | Der neue Verweis trägt beide Anker nebeneinander: den Überschriften-Slug **und** in Klammern die kurze Kennung. `harness/conventions.md` §Adaptions-Block erklärt beide für gültig und die kurze für neue Verweise vorgesehen; zwei Links auf dieselbe Zeile in einem Satz sind Redundanz. Daneben adressiert `§Messung 1 und §Grenze` Feld-Namen des Eintrags als Abschnitte. Zuständig: Implementer. | Maintainability | `harness/sensors/commit-msg-check.md:94-96` | ja für den Link (er löst auf), nein für die Form | doppelter Anker auf dieselbe Index-Zeile |
| F-7 | INFO | Der Schluss der Bilanz lautet „keine Senkung **an einem der neun aktiven Module**". Die geänderte Infrastruktur `adapter/driven/git/` trägt auch `tracked`, das `make doc-tracked` fährt; für dieses Ziel gibt der Eintrag kein eigenes Verdikt, sondern nur die allgemeine Einordnung „Erweiterung der gelesenen Menge". Ein späterer Leser kann den Schluss weiter lesen, als er reicht. Zuständig: Architect. | `MR-055` (eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft) | `MR-066`, Felder `Strenge-Bilanz` und `Kein ADR nötig` | nein | Schluss ohne Verdikt für ein mitbetroffenes Nicht-Gate-Ziel |

**Warum F-1 nicht HIGH ist.** Die belegte Sachaussage trifft zu — der Kommentar am
`commits`-Block führt beide Präfixe —, und das Kommando steht in einem Eintrag, der noch nicht
gepusht und damit noch nicht eingefroren ist. Kein Gate und kein Modul liest das Feld; die
Harness-Lüge entsteht erst, wenn der Eintrag mit dem falschen Beleg einfriert. Genau das ist
Risiko 3 des Plans (`norm-eintrag-friert-vor-seinem-review-ein`), und es ist hier vermeidbar.

**Warum F-2 nicht HIGH ist.** Die HIGH-Zeile des Skills verlangt einen Kommentar, der **keine**
der fünf Klassen trägt. Beide Kommentare tragen Abgrenzung und Kopplung (sie nennen den
Aufbau, das Ziel und den Test, über dem die Einordnungs-Zusage gilt); falsch ist jeweils nur der
angehängte Konjunktiv-Halbsatz. Dass es zwei Stellen in einem Commit sind, hebt die Kategorie auf
MEDIUM (*Wiederholung eines Musters*), nicht auf HIGH.

**Kein Rollen-Konflikt.** Kein Finding ist HIGH, und keines steht gegen eine Einschätzung des
Implementers oder des Architects, die im Diff dokumentiert wäre. Der Konflikt-Pfad aus Modul 8
greift nicht.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `MR-066` Pflichtfelder | geprüft, ohne Befund: `Datum`, `Geltungsbereich`, `Ersetzt-Baseline-Regel`, `Adaption`, `Begründung`, `Auflösungs-Trigger` stehen; `Löst auf` und `Ausgelöst durch Baseline-Stand` stehen paarweise, wie die Vorlage sie nur gemeinsam verlangt. `Wirksamkeits-Anlass` blank nach `MR-028`. Das Fork-Verdikt steht im Feld `Ersetzt-Baseline-Regel` (`MR-039` Setzung 3) |
| `MR-066` Zahlen (`MR-025`) | geprüft, mit Befund F-1; alle übrigen sechs Zahlen sind nachgemessen und decken (Mess-Tabelle oben), jede trägt „kein Erwartungswert" oder steht neben ihrem Kommando |
| `MR-066` Werkzeug-Aussagen (`MR-053`) | geprüft, ohne Befund: jede nennt `v0.76.1` oder `v0.76.3` als Mess-Operand; der lebende Pin steht nicht im Eintrag, sondern ist als in `d-check.mk` lebend benannt |
| `MR-066` Baseline-Aussagen (`MR-033`) | geprüft, ohne Befund: die zwei Regelwerks-Verweise zeigen auf `.harness/baseline/v6.9.0/…`, der adoptierte Stand |
| `MR-066` Chronik (`AGENTS.md` §3.7) | geprüft, ohne Befund: kein Absatz erzählt die Entstehung des Eintrags; die Messungen stehen als datierte Momentaufnahmen im Indikativ |
| Schluss „keine Senkung", Hälfte 1 (Quell-Differenz) | geprüft, ohne Befund: unabhängig nachgemessen, auf der Produktivcode-Achse sogar vollständig — genau vier Dateien, keine davon Regeldatei eines aktiven Moduls |
| Schluss „keine Senkung", Hälfte 2 (Gegenmessung nach `MR-063`) | gelesen, nicht wiederholt: Basis je aktivem Modul ist über die 17 genannten Codes nachvollziehbar (`structure` über `section-missing`/`section-open-tasks-marker-missing`, `links` über `repo-escape`), Befundmengen und Spaltenzahl unter beiden Digests gleich, Symlink-Kontrolle `10/0` nachgemessen |
| Genannte Grenzen der Bilanz | geprüft, ohne Befund: `span-nested-link` stumm unter **beiden** Digests und darum ohne Aussage über den Sprung; die Gegenmessung fährt den VCS-Port nicht (Kopie ohne `.git`); das Präfix ist nur an `loose-*` gemessen. Alle drei stehen im Eintrag und sind nicht überdehnt |
| Kopf-Marken, Fälligkeit (`MR-032` Setzung 4) | geprüft, ohne Befund: die Ausnahme für die Pin-Kette greift nicht, weil `MR-066` im Feld `Löst auf` zwei Aussagen **namentlich** ablöst — das ist die erste Hälfte von Setzung 4, und sie sticht |
| Kopf-Marken, Form (`MR-032` Setzung 1 und 3) | geprüft, ohne Befund: Blockquote direkt unter der Überschrift, `ÜBERHOLT: <Reichweite> → <Ziel>.` mit Fortgeltungssatz; die ältere Marke an `MR-064` ist unangetastet und die neue als zweite Blockquote-Zeile gesetzt; beide im selben Commit wie der ablösende Eintrag |
| Verzeichnis-Position (`MR-046`) | geprüft, ohne Befund: `MR-064` und `MR-065` bleiben in `conventions/`, der Eintrag sagt es und begründet es mit der Binärität der Position |
| Index-Zeile und `d-check:`-Zeile | geprüft, ohne Befund: eine Zeile in *Aktive Adaptionen* mit beiden Ankern (`mr-066` und Überschriften-Slug), Geltungsbereich und Fork-Verdikt als Anfang des Felds; die Kettenzeile in §Baseline nennt `MR-066` an der richtigen Stelle |
| E2E-Stufe `blind_gruen_ohne_waechter` | geprüft, ohne Befund: die Vorbedingung fordert den **Anlass** (`git rev-list --count HEAD..HEAD` auflösbar **und** `0`) und bricht sonst mit Exit 1 ab; die Rot-Bedingung bleibt „Exit ≠ 0 oder kein `0 Befund(e)`". Die Klasse *blind und grün* ist damit weiter gemessen, nur je Ziel an dem Klon, an dem der gepinnte Stand sie noch zulässt. `$voll` ist vor dem Aufruf angelegt |
| Mitziehen der Abdeckungs-Datei | geprüft, ohne Befund: `docs/user/e2e-abdeckung.md` ist der aktuelle Ausgang des Erzeugers (eigener Lauf, Vergleich in der Mess-Tabelle). `test/e2e-abdeckung.bats` hält diese Byte-Gleichheit und braucht keine Änderung, weil die Stufen-Deklarationen unverändert sind |
| `--disable`-Listen (`LH-QA-01`) | geprüft, ohne Befund: das Kopplungs-Kommando für `regelwerk-check` endet mit 0 und gibt nichts aus; der Kommentar darüber behauptet genau diese Deckungsgleichheit und nichts darüber hinaus — „sie nennen genau die Module, die `.d-check.yml` für `docs-check` aktiviert" trifft seit dem `--disable structure` zu |
| Emittierte Ebene (`MR-048`, `MR-054`) | geprüft, ohne Befund: `emit.go` trägt nur den Pin; `MR-048` regelt die `FROM`-Zeilen der Sprach-Skelette in `internal/gen/` und ist nicht berührt; die emittierte Modul-Liste ist unverändert, `MR-054` hat kein Objekt |
| `history-range-guard.md` §Grenze | geprüft, ohne Befund: beide nachgezogenen Aussagen sind wahr — der Wächter fängt die unauflösbare Basis selbst ab (Skript Z. 165–168), und der Zusatz „keine doppelte Prüfung ohne Gegenstand" ist durch die Ziel-Messung gedeckt, weil d-check diesen Fall ohne Klassen-Block erst seit `v0.76.3` abbricht |
| `history-range-guard.md` §Zusage | geprüft, ohne Befund: die Tabelle *zwei Aufbauten* sagt, was die Stufe jetzt fährt, und benennt, dass der **Anlass** an beiden Aufbauten ungedeckt bleibt — das Grün wird nicht als Deckung ausgegeben |
| Restbestand `v0.76.1` (`MR-053`) | geprüft, ohne Befund: 11 Zeilen, jede als Mess-Operand oder Gegenüberstellung; `doc-structure.md:38` ist auf „der **damals** gepinnte Digest" umgestellt, `docs-check.md:164` und `:250` nennen Tag **und** Digest |
| `AGENTS.md` §3.8 (Rollen-Trennung) | geprüft, ohne Befund: `66dcc433` berührt ausschließlich Architect-Artefakte und nennt die Rolle; kein Implementer-Commit fasst `AGENTS.md` oder den Adaptions-Block an |
| `AGENTS.md` §3.5 (Gate-Lockerung) | geprüft, ohne Befund: kein Modul abgeschaltet, keine Schwelle gesenkt. `--disable structure` in `regelwerk-check` **engt** den Netz-Lauf ein; die zwei Werkzeug-Änderungen sind Verschärfungen an Zielen ohne Gate-Anspruch |
| `AGENTS.md` §3.4 (ADR-Immutabilität) | geprüft, ohne Befund: keine ADR berührt; `ADR-0042` Trigger 2 ist im Eintrag als nicht eingetreten begründet, mit dem Fragment-`diff` als Träger |
| `AGENTS.md` §3.9 (Docker-only) | geprüft, ohne Befund: alle neuen Kommandos laufen über `make` oder `docker run`; keine Host-Toolchain |
| `AGENTS.md` §3.11 (Adresse im einfrierenden Artefakt) | geprüft, ohne Befund: `MR-066` nennt Slices bei der Kennung, die Pfad-Links zeigen auf ortsfeste Ablagen (`../conventions.md`, `.harness/baseline/v6.9.0/…`, `spec/`, `docs/plan/adr/`) |
| Plan-Treue §1 | geprüft, ohne Befund: keine der fünf Abgrenzungen ist verletzt — Alternates nur nachgemessen und datiert, keine Klassen-Regel für Werkzeug-Lücken gesetzt, `.d-check.yml` nur im Kommentar berührt (0 geänderte Nicht-Kommentarzeilen), emittierte Startkonfiguration ohne `vcs:`/`commits:`, Objektspeicher des Arbeitsklons unberührt |
| Plan-Treue, Größenregel | geprüft, ohne Befund: `e4b44dd3` nimmt zwei Gegenstände in den Schnitt und lässt es bei **drei** Liefer-Punkten; beide hängen an Liefer-Punkt 1, der die `--disable`-Listen und `full-smoke` schon vorher nannte. Die Änderung ist in eigenem Commit von der **Planner**-Rolle geschrieben und begründet — Wachstum ist damit benannt, nicht stillschweigend |
| Rückführung nach §4 | geprüft, ohne Befund: der Rückführungs-Fall („die Stufe verlangt mehr als eine Umschrift ihrer Aussage") ist nicht eingetreten — der Eingriff bleibt eine Umschrift plus Vorbedingung, ohne neuen Aufbau |
| Commit-Messages (`MR-051`) | geprüft, ohne Befund: jede Message trägt Kennungen; die Zahlen der Messungen stehen dort mit Kommando |

## Summary

**0 HIGH · 2 MEDIUM · 3 LOW · 2 INFO.**

Wiederkehrende Klasse für die Closure §7: **Zahl von ihrem eigenen Kommando widerlegt** (F-1).
Sie liegt nahe an `BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`
und an `BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben`, ist aber keines von beiden: hier
stimmt der gemessene Stand, und der Beleg scheitert an der Zeilenweise des Werkzeugs `grep`. Ob
die Closure einen vorhandenen Eintrag zitiert oder einen neuen anlegt, entscheidet sie.

Zweite Klasse, für die Closure ebenfalls verwertbar: **Kommentar begründet im Konjunktiv über die
verworfene Alternative** (F-2) — dieselbe Form, die `AGENTS.md` §3.7 als erstes Falsch-Beispiel
führt, in einem Lauf zweimal geschrieben.

## Verdikt

**Nacharbeit vor dem Push, kein Merge-Block.**

Die tragenden Aussagen halten. Unabhängig nachgemessen: der Digest, die Fragment-Hunks, die
Kopplung der `--disable`-Liste, die Vollständigkeit der Quell-Differenz, die Aktualität der
E2E-Tabelle und die neue Aussage der Wächter-Datei. Der Schluss *keine Senkung* trägt auf der
Quell-Achse aus eigener Messung und auf der Scan-Achse aus der gelesenen Gegenmessung; seine drei
Grenzen sind im Eintrag benannt und nicht überdehnt.

- **Push:** F-1, F-3 und F-4 sitzen in `66dcc433` — dem Architect-Commit, der mit dem Push
  einfriert (`harness/conventions.md` §Adaptions-Block; Plan §6 Risiko 3). Sie gehören **vor** den
  Push entschieden, sonst kostet jede Korrektur einen Folge-Eintrag. F-1 und F-3 gehen an den
  Architect, F-4 ebenso.
- **F-2 und F-5** gehen an den Implementer und berühren `071803f0`, der bereits gepusht ist;
  beide sind in einem Folge-Commit behebbar und halten den Push der zwei lokalen Commits nicht
  auf, wenn F-1/F-3/F-4 geklärt sind.
- **Closure:** noch nicht. Sie setzt die Verifikation gegen die DoD voraus (`make gates`,
  `make full-smoke`, die vier Messungen) — dieser Report sagt darüber nichts.

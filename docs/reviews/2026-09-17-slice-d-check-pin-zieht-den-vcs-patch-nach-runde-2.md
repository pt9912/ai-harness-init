# Review-Report: slice-d-check-pin-zieht-den-vcs-patch-nach, Runde 2 — 2026-09-17

**Review-Art:** Code, Nachprüfung. Geprüft wird nur die Nacharbeit zu F-1 bis F-5 und F-8 aus
Runde 1 (`docs/reviews/2026-09-17-slice-d-check-pin-zieht-den-vcs-patch-nach.md`, Commit
`7ee75011`). Neue Befunde stehen hier nur, wenn die Nacharbeit sie erzeugt hat.

**Gegenstand:** `git diff 7ee75011..1ba2e474`. Alle vier Commits sind lokal und nicht gepusht:

| Commit | Rolle | Dateien |
|---|---|---|
| `af7a7e9c` | Architect | `MR-064` |
| `4db3fcfb` | Implementer | `.d-check.yml`, `Makefile`, `harness/sensors/commit-msg-check.md`, `harness/sensors/doc-tracked.md`, `harness/sensors/history-range-guard.md` |
| `e72dd3a2` | Architect | `harness/conventions.md`, `MR-061` (Kopf-Marke), `MR-064` |
| `1ba2e474` | Implementer | `harness/sensors/commit-msg-check.md` (Anker) |

**Skill:** `.harness/skills/reviewer.md` 2.0.0 · **Modell:** `claude-opus-5[1m]` · **Datum:** 2026-09-17

**Eingangs-Kontext:** die Findings aus Runde 1; `MR-032`, `MR-045`, `MR-053`, `MR-055`, `MR-061`,
`MR-063`, `MR-064`; `AGENTS.md` §3.3, §3.7, §3.8. Nur lesend: der Werkzeug-Klon am Tag `v0.76.1`.

---

## Status je Finding aus Runde 1

| ID | Status | Beleg |
|---|---|---|
| F-1 | **behoben** | `harness/sensors/history-range-guard.md` §Grenze sagt jetzt: *„`doc-commits` im Dogfood hängt am Objektspeicher des Klons."* Der Punkt nennt beide Fälle und die Messung mit Digest. Zusätzlich ist `harness/sensors/doc-tracked.md` nachgezogen (*„ob ein `--range`-Lauf prüft oder abbricht, hängt am Objektspeicher des Klons"*). `git grep` findet keine weitere lebende Stelle mit der alten Einordnung. |
| F-2 | **behoben** | `MR-064` §Grenze nennt das gemessene Objekt je Ziel: für `adr-immutable`/`doc-immutable` den Unterbaum, für `doc-commits` die Vorfahren-Kette. Der Blob bleibt ausdrücklich ungemessen. Die drei Klon-Formen stehen mit Messung da. Der Auflösungs-Trigger verlangt jetzt einen Klon per `git clone --no-local` oder die Pack-Namen. Die neue Formulierung erzeugt N-1. |
| F-3 | **behoben** | Die Strenge-Bilanz nennt je Aussage ihren Träger. Für den VCS-Port ist das die Quell-Lesung, und die Gegenmessung ist dort ausdrücklich als nicht tragend benannt, auch in §Grenze und im Auflösungs-Trigger. Die Quell-Lesung habe ich am Tag `v0.76.1` nachgefahren, siehe Messungen. |
| F-4 | **behoben** | Die Bedingung lautet an allen Stellen gleich: *„Objekte der Range liegen in einem Pack, dessen Name nicht mit `pack-` beginnt; gemessen ist das an `loose-*.pack`"*. Sie steht in `MR-064` (Bedingung, §Grenze, Auflösungs-Trigger), in `commit-msg-check.md`, in `history-range-guard.md` und im Kommentar am `commits`-Block, dort in ASCII-Umschrift. Das Gegenstück *„Liegen alle in Packs, deren Name mit `pack-` beginnt"* steht in den drei lebenden Stellen gleich. Überall ist die Präfix-Regel als Vermutung ausgewiesen. Der `xyz-*`-Datenpunkt ist als stützend und nicht belegend eingeordnet. |
| F-5 | **behoben** | Der Kommentar am `commits`-Block zeigt jetzt auf `harness/sensors/commit-msg-check.md` §Grenze. Dort stehen der Beleg (beide Fälle, Digests, Kopf) und die Träger-Aussage (*„Fehlerfrei und weiter prüfend bleibt in jedem Klon nur `--commit-msg`"*). |
| F-8 | **behoben** | Beide Namensprüfungen schneiden mit `--disable [a-z-]+`. Der Kommentar beschreibt die `diff`-Ausgabe mit `<`-/`>`-Zeilen, Hunk-Köpfen und Trennern sowie Exit 0 bzw. 1. Den Bindestrich-Fall habe ich an einer Kopie rot gesehen, siehe Messungen. |

## Neue Findings (durch die Nacharbeit entstanden)

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | LOW | §Grenze sagt *„Nur ein Klon per `git clone --no-local` ist von solchen Packs frei."* Laut `commit-msg-check.md` aus demselben Slice ist auch ein Klon nach `git repack -a -d` frei (*„im umgepackten Arbeitsklon"*). Der umgepackte Arbeitsklon zählt heute 0 × `loose-`. Umgekehrt ist ein `--no-local`-Klon nur so lange frei, bis eine Wartung `loose-*`-Packs anlegt. Der Auflösungs-Trigger verlangt einen *„Klon per `git clone --no-local`"* und sagt nicht, dass er frisch sein muss. Unter `v0.76.1` wäre die Folge für Bäume ein lauter Abbruch, kein stilles Grün. | `MR-055` | `MR-064` §Grenze, zweiter Punkt; §Auflösungs-Trigger, vorletzter Satz | ja — `git repack -a -d` in einer Kopie, dann `ls .git/objects/pack/` | Stellen-Messung als Eigenschaft ausgegeben |
| N-2 | INFO | Der Dateiname von `MR-064` trägt weiter `…-unlesbarem-objekt-ab`, der Titel sagt *„Unterbaum"*. Das stört nicht: Die Index-Zeile verlinkt die Datei über ihren Pfad, und beide Anker (`mr-064`, Titel-Slug) sitzen in der Index-Zeile. Der Dateiname ist eine Adresse und keine Titel-Kopie; im Bestand weichen andere Einträge ebenso ab (etwa `MR-061`). Eine Umbenennung wäre ein eigener `git mv` (§3.3) samt Zeiger-Nachzug, ohne dass sich eine Aussage ändert. | `MR-045` | `harness/conventions.md`, Index-Zeile `MR-064` | nein | — |

## Titel und Anker von MR-064

- Der Titel in der Datei (Zeile 1) und in der Index-Zeile lautet gleich: *„d-check-Pin v0.76.1
  (vcs bricht bei unlesbarem Unterbaum ab)"*.
- `git grep -n 'mr-064--'` findet vier Verweise, alle auf
  `#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab`: die Index-Zeile
  (`<a id>`), §Baseline, die Kopf-Marke an `MR-061` und `commit-msg-check.md`. Der alte Slug
  kommt nirgends mehr vor.
- `git grep -i 'unlesbarem Objekt'` gibt nichts aus.
- `e72dd3a2` berührt an `MR-061` nur den Anker in der eigenen, noch ungepushten Kopf-Marke; der
  Rumpf bleibt unberührt.

## Eigene Messungen

Alle Mutationen liefen in Kopien unter dem Scratchpad. Vor jedem Schritt habe ich das Verzeichnis
per `mktemp -d` angelegt und seinen Pfad geprüft. `git status --short` im Arbeitsbaum war nach
jedem Lauf leer.

- **Stichprobe `xyz-*`.** `git clone --no-local` des Repos (Kopf `1ba2e474`, ein Pack
  `pack-*`). Vor der Umbenennung meldet `make adr-immutable RANGE=8ae647cc~1..8ae647cc`
  `0 Befund(e)`, make-Exit 0. Danach wurden `.idx`, `.pack` und `.rev` auf `xyz-*` umbenannt.
  - `git cat-file -t 8ae647cc~1:.claude/hooks` → `tree`.
  - `history-range-guard` meldet *„Range aufgeloest, 1 Commit(s) — OK"*.
  - Derselbe `make`-Lauf endet mit make-Exit 2 und
    `d-check: error: Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`.
  - Das `doc-immutable`-Rezept direkt gefahren: Werkzeug-Exit 2.

  Das deckt sich mit `MR-064`.
- **Quell-Lesung (F-3)** am Tag `v0.76.1`, nur lesend:
  - Das Kommando aus `MR-064` nennt sechs Aufrufe in drei Dateien: `rules/vcs.go` 4,
    `rules/commits.go` 1, `rules/run.go` 1.
  - Der Aufruf in `run.go` (Zeile 79) steht unter `if active["tracked"]`.
  - In `cli/cli.go` liefert `resolveVCS` einen `nil`-Port, wenn weder ein git-Modul noch `tracked`
    aktiv ist (*„Port nil, falls vcs inaktiv"*).
  - Keines der drei Module steht in `modules:`.
- **Namensprüfung (F-8)** an Kopien von `Makefile`, `d-check.mk` und `.d-check.yml`. Beide
  Kommandos habe ich wörtlich aus den Kommentaren gezogen; auf dem unveränderten Stand geben sie
  nichts aus (Exit 0).
  - `open-tasks` auf beiden Seiten: Exit 0.
  - `regelwerk-check` mit `open-foo` gegen `open-tasks` in `modules:`: `< open-tasks` /
    `> open-foo`, Exit 1.
  - `commit-msg-check` mit `open-foo` gegen `open-tasks` im Fragment: `< --disable open-tasks` /
    `> --disable open-foo`, Exit 1.

  Der Bindestrich-Name wird also vollständig verglichen.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Wortlaut der Bedingung an allen sechs Stellen und ihr Gegenstück | geprüft, ohne Befund |
| Titel und Anker von `MR-064` (Datei, Index, §Baseline, Kopf-Marke, Sensor-Datei) | geprüft, ohne Befund (N-2 nur als Einordnung) |
| Commit-Zuschnitt (§3.8): `af7a7e9c` und `e72dd3a2` berühren nur `harness/conventions.md` und `harness/conventions/`; `4db3fcfb` und `1ba2e474` kein Norm-Artefakt; die Rolle steht jeweils in der Message | geprüft, ohne Befund |
| Kommentare (§3.7) in `.d-check.yml` und `Makefile` nach der Nacharbeit: kein Lauf-Protokoll, der Zeiger löst auf | geprüft, ohne Befund |
| Datierung (`MR-053`) der neuen Messungen: `xyz-*`, Transportklon, `c414119b..ebb76b3d` nennen Digest bzw. Kopf | geprüft, ohne Befund |
| Einordnung des `xyz-*`-Datenpunkts als stützend, nicht belegend (`MR-055`) | geprüft, ohne Befund |
| Messung *„Transportklon mit umbenannten Pack-Dateien"* in `commit-msg-check.md` | nur gelesen, nicht nachgefahren; die Stichprobe galt dem `xyz-*`-Fall |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

Aus Runde 1 behoben: F-1, F-2, F-3, F-4, F-5, F-8. F-6 und F-7 waren nicht Gegenstand.

**Finding-Klassen dieses Laufs:** Stellen-Messung als Eigenschaft ausgegeben

## Verdikt

**Bereit für Verifier und Closure.** Die Nacharbeit behebt alle sechs geprüften Findings. N-1
blockiert nicht.

**Merge-blockierend:** nein.

- **N-1 betrifft `MR-064`, der noch lokal ist.** Ob der Satz vor dem Push geschärft wird, entscheidet
  der Architect (`AGENTS.md` §3.8). Nach dem Push bräuchte eine Korrektur einen eigenen Eintrag.
- **Übergabe:** Die Klasse von N-1 geht in §7 der Slice-Closure. Für den Verifier gilt aus Runde 1
  weiter F-6 (Werkzeug-Exit gegen make-Exit).

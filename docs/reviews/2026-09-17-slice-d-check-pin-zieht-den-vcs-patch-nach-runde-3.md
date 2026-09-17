# Review-Report: slice-d-check-pin-zieht-den-vcs-patch-nach, Runde 3 — 2026-09-17

**Review-Art:** Code, Nachprüfung. Geprüft wird nur die Nacharbeit zu V-1 und V-2 aus dem
Verifikations-Bericht (`docs/reviews/2026-09-17-slice-d-check-pin-zieht-den-vcs-patch-nach-verify.md`,
Commit `97e71814`). Neue Befunde stehen hier nur, wenn die Nacharbeit sie erzeugt hat.

**Gegenstand:** `git diff 97e71814..f4cb0141`. Beide Commits sind lokal und nicht gepusht:

| Commit | Rolle | Dateien |
|---|---|---|
| `045fa9b7` | Implementer | `.d-check.yml`, `harness/sensors/commit-msg-check.md`, `harness/sensors/history-range-guard.md` |
| `f4cb0141` | Architect | `MR-065` (neu), Kopf-Marke an `MR-064`, `harness/conventions.md` (Index und §Baseline) |

**Skill:** `.harness/skills/reviewer.md` 2.0.0 · **Modell:** `claude-opus-5[1m]` · **Datum:** 2026-09-17

**Eingangs-Kontext:** V-1 bis V-3 aus dem Verifikations-Bericht; `MR-032`, `MR-039`, `MR-046`,
`MR-053`, `MR-055`, `MR-060`, `MR-064`, `MR-065`; `AGENTS.md` §3.4, §3.7, §3.8.

---

## Status V-1 und V-2

| ID | Status | Beleg |
|---|---|---|
| V-1 | **behoben** | Das Gegenstück ist an den drei Stellen auf das Gemessene eingeschränkt: im Kommentar am `commits`-Block, in `commit-msg-check.md` §Grenze und in `history-range-guard.md` §Grenze. Dort steht jetzt *„Geprüft hat … in den gemessenen Klonen ohne Alternates …; dass das genügt, ist nicht belegt"*. Der `--shared`-Klon ist als gemessener Abbruch genannt, der Fall mit nur losen Objekten als gemessene prüfende Lage. Aus *„Welcher der zwei Fälle"* ist *„Welche Form vorliegt"* geworden. Neu entstanden ist dabei R3-1. |
| V-2 | **behoben** | `MR-065` Setzung 1 verlangt zum Laufzeitpunkt drei Angaben: Pack-Namen, Alternates und lose Objekte. Die Begründung steht dabei: Pack-Namen allein sehen den `--shared`-Klon nicht. Setzung 2 nennt jede Lage außerhalb der Tabelle *ungemessen*, nicht *frei*. `MR-064` trägt die Kopf-Marke auf genau die zwei Stellen, die die Frei-Bestimmung trugen: §Grenze (Zeile 268) und den Satz im Auflösungs-Trigger (Zeile 317). Beide Zitate stimmen mit dem Text überein. `MR-065` §Grenze sagt ausdrücklich, dass kein Wächter die Angabe prüft. |

## MR-065 als Norm-Artefakt

| Prüfpunkt | Ergebnis |
|---|---|
| `MR-032` Setzung 1: Die Marke ist eine Zeile direkt unter der Überschrift von `MR-064` | eingehalten |
| `MR-032` Setzung 3: Der ablösende Eintrag setzt die Marke in derselben Änderung | eingehalten (`f4cb0141`) |
| Nur die Marke: Der Diff an `MR-064` besteht aus zwei hinzugefügten Zeilen, der Rumpf ist unverändert | eingehalten |
| Die Marke bewahrt die Messungen des abgelösten Punkts (*„die Pack-Namen, die die Formen von `git clone` und `git repack -a -d` hinterlassen, bleiben als Messung stehen"*) | eingehalten |
| `MR-046`: `MR-064` bleibt in `conventions/` | eingehalten |
| `MR-060`: Der neue Eintrag führt alle Pflichtfelder, die auch `MR-064` führt (Datum, Wirksamkeits-Anlass, Geltungsbereich, Löst auf, Ausgelöst durch Baseline-Stand, Ersetzt-Baseline-Regel mit Verdikt nach `MR-039` Setzung 3, Adaption, Grenze, Begründung, Auflösungs-Trigger) | eingehalten |
| Index-Zeile: Titel wie in der Datei, Anker-Slug aus dem Titel abgeleitet, Anfänge von Geltungsbereich und Ersetzt-Baseline-Regel wie in der Datei; Zeile in §Baseline | eingehalten |
| `MR-053`: Die Messungen nennen den Stand (`v0.76.1`), und `v0.76.0` ist als ungemessen benannt | eingehalten |
| `ADR-0053` (V-3) ist nur genannt, nicht geändert (§3.4) | eingehalten |
| §3.8: `f4cb0141` berührt nur `harness/conventions.md` und `harness/conventions/`; `045fa9b7` kein Norm-Artefakt; die Rolle steht jeweils in der Message | eingehalten |
| Wortlaut von Setzung 2 gegen die drei Implementer-Stellen | in der Sache gleich, mit einer Ausnahme (R3-1) |

## Neue Findings (durch die Nacharbeit entstanden)

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | LOW | `commit-msg-check.md` zählt *„umgepackt (`git repack -a -d`)"* zu den gemessenen Formen, in denen der Range-Lauf prüft; der Kommentar am `commits`-Block führt dieselbe Form. `MR-065` hat diese Zeile nicht in der Tabelle, und §Grenze nennt *„eine Mischung aus losen Objekten und Packs"* ungemessen. Der umgepackte Arbeitsklon, in dem Runde 2 und die Verifikation gemessen haben, ist eine solche Mischung: `git count-objects -v` → `count: 95`, dazu ein `pack-*`-Pack, keine Alternates. Nach Setzung 2 wäre diese Form also *ungemessen*, nach den zwei lebenden Stellen *geprüft*. Die Angabe `count:` fehlt in der Sensor-Datei für diese Form, und in Zeile 1 der Tabelle von `MR-065` steht sie als *nicht erhoben*. Die Abweichung zeigt in die vorsichtige Richtung; ein stilles Grün folgt daraus nicht. | `MR-065` Setzung 1 und 2; `MR-055` | `MR-065` §Grenze, zweiter Punkt; `harness/sensors/commit-msg-check.md` §Grenze, Punkt *„Geprüft hat …"*; `.d-check.yml` (Kommentar am `commits`-Block) | ja — `git count-objects -v` im umgepackten Klon, dazu der Mischungs-Lauf unten | Lage ohne die Angabe, die ihre eigene Setzung verlangt |

## Stichprobe

Die Kopien lagen unter dem Scratchpad. Das Verzeichnis habe ich per `mktemp -d` angelegt und
seinen Pfad vor jedem Schritt geprüft. `git status --short` im Arbeitsbaum war danach leer.

- **`git clone --shared` des Arbeitsklons.**
  - Zustand: `ls -A .git/objects/pack/` → 0 Einträge. `.git/objects/info/alternates` nennt
    `/Development/KI/ai-harness-init/.git/objects`. `git count-objects -v` → `count: 0` und eine
    Zeile `alternate:`.
  - git liest den Baum: `git cat-file -t '8ae647cc~1:.claude/hooks'` → `tree`.
  - `make adr-immutable RANGE=8ae647cc~1..8ae647cc`: `history-range-guard` meldet OK, danach
    make-Exit 2 mit `Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`.
  - `make doc-commits RANGE=c414119b..ebb76b3d`: make-Exit 2 mit
    `Range-Basis "c414119b" nicht auflösbar: reference not found`.
  - Mit zusätzlichem Mount: Den `docker run`-Aufruf beider Rezepte (`make -s -n`) habe ich um
    einen read-only-Mount des Alternates-Pfads unter demselben absoluten Pfad ergänzt. Beide
    Läufe enden mit **Werkzeug-Exit 2** und derselben Meldung.

  Das deckt sich mit der Tabelle und dem Mount-Absatz in `MR-065`.
- **Mischung, Zusatzmessung zu R3-1.** In einem `git clone --no-local`-Klon habe ich einen leeren
  Commit ohne Kennung angelegt.
  - Zustand: ein `pack-*`-Pack, `count: 1`, keine Alternates.
  - `make doc-commits RANGE=HEAD~1..HEAD` prüft: 1 × `commit-untraceable` auf dem losen Commit,
    dessen Eltern-Commit im Pack liegt, make-Exit 2.

  Das ist eine Stelle, keine Eigenschaft der Mischung (`MR-055`).

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Kopf-Marke an `MR-064`: Form, Umfang, zitierte Sätze | geprüft, ohne Befund |
| Index-Zeile und Zeile in §Baseline für `MR-065`, Anker | geprüft, ohne Befund |
| Pflichtfelder von `MR-065` (`MR-060`) | geprüft, ohne Befund |
| `--shared`-Abbruch, auch mit Mount | geprüft, ohne Befund |
| Wortlaut von Setzung 2 an den drei Implementer-Stellen, in der Sache | geprüft, ohne Befund außer R3-1 |
| Kommentar (§3.7) am `commits`-Block nach der Nacharbeit: kein Lauf-Protokoll, der Zeiger löst auf | geprüft, ohne Befund |
| Commit-Zuschnitt (§3.8) | geprüft, ohne Befund |
| Zeile *„nur lose Objekte"* der Tabelle (`git unpack-objects`) | nur gelesen, nicht nachgefahren |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

V-1 und V-2 sind behoben.

**Finding-Klassen dieses Laufs:** Lage ohne die Angabe, die ihre eigene Setzung verlangt

## Verdikt

**Bereit für Push und Closure.** R3-1 blockiert nicht.

**Merge-blockierend:** nein.

- **R3-1 betrifft `MR-065` und zwei lebende Stellen.** `MR-065` ist noch lokal. Ob der Architect
  die Mischung vor dem Push in die Tabelle aufnimmt oder die Form *„umgepackt"* an den zwei
  lebenden Stellen auf eine Angabe `count:` bindet, entscheiden Architect bzw. Implementer
  (`AGENTS.md` §3.8).
- **Nach dem Push gilt die Regel des Eintrags selbst:** *„Kommt eine neue Lage in die Tabelle, dann
  in einem neuen Eintrag."*
- **Übergabe:** Die Klasse von R3-1 geht in §7 der Slice-Closure.

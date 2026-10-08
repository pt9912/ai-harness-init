# Review-Report: slice-zeilenenden-meldungstest-bindet-das-verzeichnis — 2026-10-08

**Review-Art:** Code — gegen Plan + Konventionen.

**Gegenstand:** `e5ab0209` (Claim `90896758`, `c32e35c6`, `1c6c4c42`)

**Skill:** `.harness/skills/reviewer.md` @ `78381a2b` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-zeilenenden-meldungstest-bindet-das-verzeichnis` (Plan, §1–§3, §6)
- `ADR-0067` Festlegung 3 und 4
- `LH-QA-04`, `LH-FA-06`
- `MR-071`
- `AGENTS.md` §3.6, §3.7

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die Assertion sucht das erwartete Verzeichnis per `strings.Contains` im Aussage-Teil und bindet es nicht an eine Grenze davor: nennt der Aussagesatz zu `harness/mk/.gitattributes` das Verzeichnis `tools/harness/mk/`, bleibt `make test-go` grün (Sonde unten, EXIT 0). Der Doc-Kommentar sagt zu, die Aussage nenne „die Dateien des Verzeichnisses dieses Pfades"; für ein fremdes Verzeichnis, dessen Name auf das erwartete endet, hält der Test das nicht. Erreichbar ist die Verwechslung praktisch, weil `tools/harness/` in derselben Tabelle `zeilenendenFiles` als konvergentes Nachbar-Verzeichnis steht. | `AGENTS.md` §3.6 | `internal/emit/zeilenenden_test.go` · `if !strings.Contains(rest, aussage)` mit `path.Dir(rel) + "/"` | ja — `make test-go` über der Sonde `zeilenendenMeldung("harness/mk")` → `zeilenendenMeldung("tools/harness/mk")` | Teilzeichenketten-Suche bindet einen Pfad nicht an seine Grenze |

### Gefahrene Sonden (Scratchpad-Kopien per `git archive HEAD`, Host-Baum unberührt)

| Sonde | Erwartung | Ergebnis |
|---|---|---|
| `make mutate MUTATE_CASES=586-zeilenenden-meldung-nennt-fremdes-verzeichnis` (Treiber, Isolation, Grün-Vorlauf) | Fall ok | `mutate: ok 586-… -> TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet rot` · `1 ok, 0 Befund(e)`, EXIT 0 |
| Gegenprobe: Mutation 586 angewandt, `t.Skip("gegenprobe")` **ausschließlich** im benannten Test | grün = der benannte Test bindet allein | `make test-go` EXIT 0, kein `--- FAIL` |
| Vorzustand: Test des Eltern-Commits `e5ab0209~1`, Mutation 586 angewandt | grün (die alte Assertion war durch Konstruktion erfüllt) | `make test-go` EXIT 0 |
| Grenze: `zeilenendenMeldung("harness/mk")` → `("tools/harness/mk")`, Test am Stand `HEAD` | rot, wenn das Verzeichnis gebunden ist | `make test-go` EXIT 0 → F-1 |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Eigenschaft statt Implementierung (`internal/emit/zeilenenden_test.go`, Aussage-Schleife) | geprüft, ohne Befund außer F-1: gesucht wird hinter dem Pfad-Token (`rest`), die Vorzustand-Sonde ist grün, der Stand `HEAD` unter Mutation 586 rot. |
| Herkunft der Erwartung (Register-Klasse `erwartung-stammt-aus-dem-geprueften-gegenstand`) | geprüft, ohne Befund: `path.Dir(rel)` stammt aus der test-eigenen Liste `skip`, nicht aus der Meldung und nicht aus `zeilenendenFiles`; die Meldung liefert nur den Suchraum. |
| Mutations-Fall 586 (Anker, `# files:`/`# expect:`, Modus, Exklusivität) | geprüft, ohne Befund: `# files:` nennt die mutierte Datei, Modus `100755`, Anker trifft genau eine Stelle (Zeile 30), Treiber ok, Gegenprobe mit `t.Skip` grün — kein zweiter Test bindet die Stelle mit; der Fall-Kopf behauptet keine Exklusivität. |
| Kommentare (§3.7) — Doc-Kommentar des Tests, Kommentar an der Schleife, Fall-Kopf | geprüft, ohne Befund: je ein eigener Kommentar, Indikativ, Klassen Zusage/Abgrenzung; keine Chronik, keine Befund-Kennung, kein abgebrochener Satz; der Doc-Kommentar führt 586 unter den Rot-Gegenbeispielen. |
| Mehrteilige Zusage je Teil (Skill, LOW/INFO mit Eskalation) | geprüft: die drei übrigen Aussage-Zeichenketten sind laut Plan §1 als Gruppe von Fall 449 gebunden und nicht Gegenstand des Diffs; die Verzeichnis-Teilgrenze trägt F-1. |
| Produktions-Code und Schicht-Grenze | geprüft, ohne Befund: `git show --stat e5ab0209` berührt nur den Test und den Fall. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Teilzeichenketten-Suche bindet einen Pfad nicht an seine Grenze

## Verdikt

Kein Merge-Blocker. F-1 geht an den Implementer zur Entscheidung (akzeptieren oder begründen).

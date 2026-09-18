# Review-Report: `slice-das-ziel-prueft-seine-durchsetzung-selbst` — 2026-09-18

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11), anderer Eingabe-Kontext.

**Gegenstand:** Commit-Range `f6ff3954..a40fe473` — `2bda848a` (Emission) und
`a40fe473` (Messung im Emitter-Lauf). Runde 1.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 ·
**Modell:** claude-opus-5 · **Datum:** 2026-09-18.

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- der Slice-Plan `slice-das-ziel-prueft-seine-durchsetzung-selbst` §1 bis §6 und §8
- `ADR-0054` (Klasse des emittierten Commit-Trägers: skip-if-present), `ADR-0007`
  Festlegung 3 (konvergente Wurzeln)
- `LH-FA-11` (tragend), `LH-FA-02`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`
- `AGENTS.md` §3 (Hard Rules), namentlich §3.6 und §3.7
- Baseline `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin),
  `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill
- Vorherige Findings am selben Modul: die Review-Runden zu
  `slice-das-ziel-sagt-was-sein-vendored-baum-ist` (Emissions-Pfad, Marker-Klasse)

---

## Findings

### Eigene Läufe — Grundlage der Findings

Alles unten Gemessene lief in einem **gebootstrappten Ziel im Scratchpad**, nicht im
Arbeitsbaum dieses Repos; der Arbeitsbaum war vor und nach dem Lauf sauber
(`git status --porcelain` leer). Träger ist das Produkt-Binär aus `make host-bin`.

| Lauf | Ergebnis |
|---|---|
| `make host-bin` | EXIT 0 |
| Bootstrap `--name zielA` (sprachlos), `git init`, erster Commit | EXIT 0 |
| `make selbstpruefung` im Ziel (Default) | **EXIT 0**, beide Commit-Ausgänge in der Ausgabe, `make gates` im Klon grün, **1,089 s** |
| dasselbe in einem Ziel `--lang go` | **EXIT 0**, **15,314 s**; letzte Gate-Zeile `#14 DONE 0.2s` |
| `make selbstpruefung` ohne git-Repo | EXIT 2, benannter Abbruch |
| `make selbstpruefung` in einem Repo **ohne Commit** | EXIT 2, benannter Abbruch |
| Ziel mit lokal gesetztem `core.hooksPath` | EXIT 0 — der Klon erbt lokale Config nicht |
| Ziel unter **global** gesetztem `core.hooksPath` (`GIT_CONFIG_GLOBAL`) | **EXIT 2** — Abbruch, siehe F-3 |
| Ziel mit **eigenem** `.githooks/commit-msg` (skip-if-present) | **EXIT 2** — Abbruch, siehe F-4 |
| `SELBSTPRUEFUNG_TRAEGER=Makefile` | **EXIT 0** — siehe F-2 |
| `SELBSTPRUEFUNG_AKTIVIERUNG=true` | EXIT 2, benannter Abbruch — der Marker wirkt |
| `SELBSTPRUEFUNG_GATE=false` | EXIT 2, benannter Abbruch — der Marker wirkt |
| Adopter-Edit in beiden emittierten Dateien, danach zweiter Bootstrap | beide Edits still überschrieben — siehe F-5 |
| Mutation der **emittierten** Vorlage (Gate-Schritt fest auf `make gates`, Ankündigungen unverändert) gegen die fünf Zusicherungen des Marker-Laufs | **alle fünf grün** — siehe F-1 |
| `make -n gates` im Ziel (sprachlos und `--lang go`) | 0 Treffer auf `selbstpruefung` |

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Marker-Lauf (b) kann nicht rot werden, wenn die Vorlage den gesetzten Marker gar nicht benutzt: beide positiven Zusicherungen zitieren Zeilen, in die das Skript die **Variable** interpoliert, und die dritte (`baseline-verify`) ist Teilstring der ersten; die zwei verbotenen Zeichenketten fehlen auch im Default-Lauf, `record-gates` kommt in keiner der beiden Ausgaben vor. Gemessen: eine Vorlage, deren Gate-Schritt fest `make gates` fährt, passiert alle fünf Zusicherungen. | `AGENTS.md` §3.6 · `LH-FA-11` AC *Adaptierbar* | `harness/tools/full-smoke.sh:2801-2827` | ja — `make full-smoke` nach einer Mutation, die den Marker ignoriert, bleibt heute grün | Zusicherung prüft die Ankündigung statt der Wirkung |
| F-2 | HIGH | `SELBSTPRUEFUNG_TRAEGER` lenkt allein eine Existenzprüfung; in Betrieb genommen wird stets, was der Aktivierungsschritt setzt. Der Schluss-Satz schreibt die beobachtete Wirkung trotzdem dem Marker zu. Gemessen: mit `SELBSTPRUEFUNG_TRAEGER=Makefile` endet der Lauf Exit 0 und meldet *„der Traeger [Makefile] reist mit dem Klon … danach faellt ein Commit OHNE Kennung"*, während `.githooks/commit-msg` aufgehalten hat. | `AGENTS.md` §3.6 · `LH-FA-11` AC *Adaptierbar* | `internal/emit/templates/enforce/selbstpruefung.sh:45-47,89-91,156` | ja — ein Lauf mit auf eine beliebige vorhandene Datei gesetztem Marker endet grün | gesetzter Marker wird im Ergebnis-Satz als wirkend geführt, ohne zu wirken |
| F-3 | MEDIUM | `git config --get core.hooksPath` liest alle Scopes; die Aussage daneben gilt der **lokalen** Config des Klons. Auf einer Maschine mit global gesetztem `core.hooksPath` bricht die Vorlage mit *„der frische Klon traegt bereits core.hooksPath=…"* ab, und die E2E-Stufe an derselben Stelle über dem Ziel. Gemessen mit `GIT_CONFIG_GLOBAL`. | `LH-QA-02` · Maintainability | `internal/emit/templates/enforce/selbstpruefung.sh:80-87` · `harness/tools/full-smoke.sh:2755-2759` | ja — `GIT_CONFIG_GLOBAL` mit `core.hooksPath` gesetzt, dann `make selbstpruefung` bzw. `make full-smoke` | Scope-blinde Config-Lesung trägt eine Aussage über lokalen Zustand |
| F-4 | MEDIUM | Ein Ziel, das an `.githooks/commit-msg` bereits seinen eigenen Träger führt — der Zustand, den `ADR-0054` Festlegung 1 ausdrücklich zulässt und den der Bootstrap mit eigener Meldung herstellt —, bekommt eine Selbstprüfung, die konstruktionsbedingt fällt: Commit-Messages und die erwartete Kennungs-Menge sind fest verdrahtet und von keinem der drei Marker erreichbar. Gemessen: Abbruch mit *„das Ziel hat dann keine Durchsetzung, sondern eine Behauptung"*. | `ADR-0054` Festlegung 1 · `LH-FA-02` | `internal/emit/templates/enforce/selbstpruefung.sh:106-141` | ja — Bootstrap über ein Verzeichnis mit eigenem `.githooks/commit-msg`, dann `make selbstpruefung` | emittierte Prüfung fordert einen Zustand, den die ADR dem Adopter freistellt |
| F-5 | MEDIUM | Das Fragment trägt die drei `?=`-Belegungen — den Ort, an dem ein Adopter eine dauerhafte Vorgabe setzt — und sagt über seine konvergente Klasse nichts; der Kopf der Vorlage nennt es zugleich als Setz-Weg. Gemessen: ein Edit an `SELBSTPRUEFUNG_GATE ?=` im Fragment und einer in der Vorlage sind nach dem nächsten Bootstrap weg, ohne dass der Lauf ein Wort darüber verliert (der Träger daneben bekommt seine skip-if-present-Meldung). | `AGENTS.md` §3.7 · `LH-FA-02` | `internal/emit/templates/enforce/selbstpruefung.mk:8-24` · `internal/emit/templates/enforce/selbstpruefung.sh:18-23` | ja — zweiter Bootstrap über ein Ziel mit editiertem Fragment | Adaptions-Ort ohne Hinweis auf seine Überschreib-Klasse |
| F-6 | MEDIUM | Der Kommentar sagt der ausgegebenen letzten Gate-Zeile eine Unterscheidungskraft zu (*„sie zeigt, WELCHES Kommando lief"*), die sie nicht trägt: sie ist die letzte nichtleere Zeile eines fremden Kommandos. Gemessen im Ziel `--lang go`: `#14 DONE 0.2s`. | `AGENTS.md` §3.7 · §3.6 | `internal/emit/templates/enforce/selbstpruefung.sh:151-155` | nein — kein Sensor liest, worüber ein Kommentar spricht | Kommentar sagt eine Unterscheidungskraft zu, die die Ausgabe nicht trägt |
| F-7 | LOW | Die neue Stufe bootstrappt ein **sprachloses** Ziel (`--name full-smoke-selbst`, kein `--lang`), und ihr eigener Kommentar sagt das auch; ihre fünf Fehlermeldungen und der `einordnen`-Aufruf führen trotzdem `golang:` bzw. `(--lang go)`. Wer im Rot der CI danach sucht, sucht am falschen Ziel. | Maintainability | `harness/tools/full-smoke.sh:2737-2828` | nein | Diagnose nennt eine Variante, die der Lauf nicht fährt |
| F-8 | LOW | §3 des Plans führt für `harness/tools/full-smoke.sh` *„**eine** neue Stufe: sie fährt die Selbstprüfung im gebootstrappten Ziel einmal durch"*; umgesetzt sind ein **fünftes** Bootstrap-Ziel samt `git init`/Commit und **zwei** Läufe. Die Abweichung ist im Code begründet, der Plan ist nicht nachgezogen. | Slice-Plan §3 | `harness/tools/full-smoke.sh:128-140,2737-2752` | nein | Plan-Tabelle nach bewusster Abweichung nicht nachgezogen |
| F-9 | LOW | Die Stufen-Deklaration führt `LH-QA-03` mit; in der Stufe fällt kein Beobachtungspunkt, wenn die Vorlage ein weiteres Host-Werkzeug ruft — sie liefe auf jeder Maschine grün, die es hat. Die Abdeckungs-Sicht führt die Kennung damit über einer Zusage, die dieser Lauf nicht messen kann. | `LH-QA-01` · `LH-QA-03` | `harness/tools/full-smoke.sh:2736` · `docs/user/e2e-abdeckung.md:35` | nein | Kennung deklariert ohne fallenden Beobachtungspunkt |
| F-10 | INFO | `git rev-parse --show-toplevel` liefert die **äußere** Wurzel, wenn das Ziel in einem umgebenden Repo liegt (Monorepo, Unterverzeichnis); geklont und geprüft würde dann das äußere Repo. Der Voraussetzungs-Absatz nennt nur *„ein git-Repo mit mindestens einem Commit"*. | Maintainability | `internal/emit/templates/enforce/selbstpruefung.sh:34-38,61` | nein | Voraussetzung benennt die Repo-Wurzel nicht, die sie meint |
| F-11 | INFO | Zu Risiko 2 des Plans (*Gate-Kosten im Klon*), gemessen statt geschätzt: **1,089 s** im sprachlosen Ziel, **15,314 s** im Ziel `--lang go` — beide mit warmem Image-Cache. Adressat ist der Planner beim Risiko-Ausgang, nicht dieser Diff. | Slice-Plan §6 Risiko 2 | — | ja — `make selbstpruefung` im Ziel | Risiko-Schätzung durch Messung ablösbar |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Beide Commit-Ausgänge in **einem** Lauf: liest die Stufe die Ausgabe oder nur den Exit-Code? | geprüft, ohne Befund — vier wörtliche Sätze werden gegriffen, darunter je einer für den gefallenen und den durchgelassenen Commit; die Vorlage selbst liest zum Exit-Code zusätzlich die Lage von `HEAD` |
| `selbstpruefung` hängt an keiner `gates`-Kette des Ziels | geprüft, ohne Befund — die Stufe liest `make -n gates`, sichert vorher die Nicht-Leere der Kette über `record-gates.sh` ab und prüft dann die Abwesenheit; unabhängig nachgemessen in beiden Ziel-Varianten: 0 Treffer |
| Risiko 4 des Plans (Ausgangslage des Klons) | geprüft, ohne Befund — „kein git-Repo" und „Repo ohne Commit" brechen je mit eigener, zutreffender Meldung ab; die Commit-Identität bringt der Lauf selbst mit |
| Marker `SELBSTPRUEFUNG_AKTIVIERUNG` und `SELBSTPRUEFUNG_GATE` als **Wirkung** | geprüft, ohne Befund — ein wirkungsloser Aktivierungsschritt und ein rotes Gate-Kommando brechen den Lauf je mit benannter Ursache ab |
| Ziel mit Sprach-Skelett (`--lang go`) | geprüft, ohne Befund — Exit 0, die Gate-Kette des Ziels läuft im Klon durch |
| Go-Zähne der Emission (`internal/emit/selbstpruefung_test.go`) | geprüft, ohne Befund — Ablage, Ausführungs-Bit, Inventur, Klasse, Fragment-Ziel und die Marker-Verdrahtung werden gegen den **vollständigen Ist-Bestand** gehalten (beide Richtungen), und der Test benennt seine Grenze ausdrücklich |
| Mutations-Fall `test/mutations/370-…` | geprüft, ohne Befund — er trifft genau die Schleife, deren Ausgabe die Stufe liest, und sein `# expect:` zitiert eine Fehlerzeile, die im Skript nur einmal vorkommt |
| Emissions-Klasse der zwei neuen Dateien gegenüber `ADR-0054` | geprüft, ohne Befund — konvergent, und die skip-if-present-Klasse des Trägers bleibt unberührt (im Lauf mit belegtem Pfad blieb der fremde Träger byte-gleich liegen) |
| Nennung des neuen Kommandos im Ziel (Modul 13 §Hard Rule, dritte Lage) | geprüft, ohne Befund — `make help` im Ziel führt `selbstpruefung` mit der Marke `KEIN Gate` |
| Neue Abhängigkeit im Ziel (`LH-QA-03`) | geprüft, ohne Befund — beobachtet wurden nur `git`, `make`, `bash`, coreutils und das, was das Gate-Kommando selbst mitbringt |
| Erzeugte Abdeckungs-Sicht `docs/user/e2e-abdeckung.md` | geprüft, ohne Befund — Zeile 35 entsteht aus der Stufen-Deklaration, die übrigen Zeilen ändern nur ihre Zeilen-Nummern |
| §1-Abgrenzung des Plans (vier Ausschlüsse) | geprüft, ohne Befund — die Durchsetzungsschicht selbst, der Abschnitt `COMMIT-KENNUNG IM ZIEL`, ein Vergleichs-Sensor und ein neues `make`-Ziel dieses Repos sind unberührt |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 4 |
| LOW | 3 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Zusicherung prüft die Ankündigung statt der Wirkung ·
gesetzter Marker wird im Ergebnis-Satz als wirkend geführt, ohne zu wirken ·
Scope-blinde Config-Lesung trägt eine Aussage über lokalen Zustand ·
emittierte Prüfung fordert einen Zustand, den die ADR dem Adopter freistellt ·
Adaptions-Ort ohne Hinweis auf seine Überschreib-Klasse ·
Kommentar sagt eine Unterscheidungskraft zu, die die Ausgabe nicht trägt ·
Diagnose nennt eine Variante, die der Lauf nicht fährt ·
Plan-Tabelle nach bewusster Abweichung nicht nachgezogen ·
Kennung deklariert ohne fallenden Beobachtungspunkt

## Verdikt

**Merge-blockierend:** ja — zwei HIGH und vier MEDIUM. Beide HIGH treffen dieselbe
Zusage aus zwei Richtungen: der eine Marker, dessen Wirkung die Stufe zu messen
angibt, wird nur als Ankündigung gelesen (F-1), und der andere wird im Schluss-Satz
als wirkend geführt, ohne zu wirken (F-2). Ein Rollen-Widerspruch besteht nicht;
fällt er auf, gilt der Konflikt-Pfad aus Modul 8.

**Übergabe:** Findings gehen an den Implementer; die **Finding-Klassen** zusätzlich
in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein
**Lauf-Beleg** und wird über Läufe hinweg nicht wieder gelesen. Er ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).

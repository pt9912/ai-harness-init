# Review-Report: `slice-das-ziel-sagt-was-sein-vendored-baum-ist` — 2026-09-18, Runde 3

**Review-Art:** Code — die V-1-Nacharbeit gegen Plan, aktive ADRs und die Hard Rules.
**Keine** DoD-Abhakung.

**Gegenstand:** `git diff 5c45749a..10ba3953` — `63618fb6` und `10ba3953`.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

**Eingangs-Kontext:** der Slice-Plan §1 · `ADR-0022` (Accepted, Festlegung 5) · `ADR-0054`
(Accepted, Festlegung 1 und 2) · `LH-FA-09`, `LH-QA-01` · `MR-025`, `MR-033`, `MR-053` ·
`AGENTS.md` §3.2, §3.6, §3.7 · die Reports der Runden 1 und 2 und der Verifikations-Report
zu diesem Slice.

---

## 1. Fundmenge — eigene Messung

Ich habe die Adressen nicht aus dem Wächter übernommen, sondern unabhängig gezogen — alle
Inline-Code-Spannen aller Inventur-Zellen, danach klassifiziert nach Verzeichnis-Trenner,
Datei-Endung und Leerraum:

```sh
sed -n '/^func traegerInventur/,/^}/p' internal/emit/baumaussage.go \
  | grep -oE '.[^.]*.'   # Trennzeichen des Musters ist das Backtick
```

Ergebnis: **28** Spannen in Adress-Form, **12** ohne. Jede der 28 löst gegen das auf, was ein
Lauf schreibt — die drei korrigierten Zellen eingeschlossen:

- `docs/plan/planning/in-progress/roadmap.md` ist genau der Ort, den `singletonTarget`
  vergibt (`internal/emit/templates.go`, Sonderfall für `roadmapTemplate`) — die Korrektur
  trifft die reale Adresse, nicht eine plausible.
- Die zwei Prosa-Zellen sagen weiter, was sie sagen sollen: die ADR-Vorlage
  (`NNNN-titel.template.md`) und die Carveout-Vorlage (`carveout.template.md`) liegen im
  mitgelieferten Vorlagen-Baum — beide dort nachgezählt. Der gestrichene Pfad `templates/`
  war am Ziel-Root nie eine Adresse; die Aussage verliert nichts, weil der Block eine Zeile
  höher sagt, wo der Baum liegt.

**Die Fundmenge der *Adressen* ist damit vollständig.** Was sie nicht erfasst hat, ist eine
Zelle, deren Adresse stimmt und deren **Bedingung** fehlt — R3-1.

## 2. Trägt der Wächter, ohne zu überdehnen?

**Die bekannte Menge ist die reale.** `bekannt` ist `TemplateTargets(courseSet(), …)` plus
`EmittierteAdressen()`. Die Fixture könnte den Test still weiten, wenn sie Vorlagen führte,
die der echte Satz nicht hat — sie tut es nicht: `comm -23` über die `*.template.md`-Namen
der Fixture gegen den vendored Baum ist **leer**, beide Seiten **25**. Die Fixture ist damit
namensgleich mit dem realen Satz; `bekannt` ist keine geweitete Menge.

**Die zwei Schranken greifen.** `len(bekannt) == 0` bricht mit `t.Fatal`, `geprueft == 0` mit
`t.Error` — die zweite ist die wirksame: Sie fällt genau dann, wenn `AdressenAusText` nichts
mehr trifft (geänderte Zell-Form, kaputte Split-Regel), und das ist die Lage, in der ein
form-basierter Wächter sonst still grün wird. Der Geltungsbereich ist richtig geschnitten:
`TraegerKommtNichtMit` bleibt draußen, weil dort `PfadBestand` die Gegenrichtung hält — beide
zusammen decken die Zellwerte vollständig ab, ohne sich zu überlappen.

**Was herausfällt, in drei Gruppen.** Die Spannen mit Leerraum (`make gates`,
`direction: no-downward`) — die `make`-Namen hält `full-smoke` real per `make -n` im Ziel, der
Rest ist Konfigurations-Vokabular, keine Adresse. Prosa — von der Funktion benannt. Und eine
dritte, die dort **nicht** benannt ist: nackte Ziel-Namen in Inline-Code (R3-3).

**Überdehnung sehe ich keine.** Die Verzeichnis-Regel (Präfix-Treffer bei abschließendem
`/`) ist die schwächste Stelle, trifft hier aber nur spezifische Verzeichnisse; und dass die
Adresse die *richtige* für ihren Regelblock ist, sagt der Wächter ausdrücklich nicht.

## 3. Findings dieser Runde

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | MEDIUM | Die Zelle zu `grundlagen-traceability.md` sagt unbedingt *„`.githooks/commit-msg` ruft `tools/harness/commit-msg-traceability.sh`"*. Der Träger ist der **einzige** `SkipIfPresent`-Eintrag der Durchsetzungs-Mechanik (`class: SkipIfPresent` samt `meldung`): führt das Ziel dort schon seinen eigenen Hook, bleibt der stehen und ruft die mitgelieferte Prüfung nicht. Dieselbe Klasse wie F-3 aus Runde 1 — ein bedingter Träger ohne seine Bedingung —, nur an der anderen Bedingung. Der neue Wächter lässt sie durch, weil die Adresse entstehen *kann*. | `ADR-0054` Festlegung 1 und 2 · `LH-QA-01` · Plan §1 (Zellwert = Zustand des Ziels) | `internal/emit/baumaussage.go:85-86` gegen `internal/emit/commitmsg.go:57-58` | ja — `make full-smoke` Stufe 15 fährt genau diesen Zweig („Ein belegter Pfad behält seinen Träger, und der Lauf nennt ihn"); geprüft wird dort das Verhalten, nicht die Zelle | Zellwert behauptet Anwesenheit eines bedingt emittierten Trägers |
| R3-2 | MEDIUM | Der Kommentar des neuen Tests schließt mit *„Der Verifikations-Report fand genau das: die Roadmap-Zelle **nannte** einen Ort, an dem die Datei nicht liegt."* Das ist zweierlei auf einmal: die Herkunft als Absatz statt als auflösbares Feld — und zwar auf ein Zeitdokument unter `docs/reviews/**`, das in keinem Rang der Source Precedence steht — und eine Beschreibung des abwesenden Textes im Präteritum. Beide Formen führt `AGENTS.md` §3.7 als „Falsch"; der Cutoff bindet den Kommentar, der geschrieben wird. | `AGENTS.md` §3.7 | `internal/emit/baumaussage_test.go:111-112` | nein — kein Gate liest, worüber ein Kommentar spricht (`make comment-claims` prüft nur, ob ein genannter Sensor existiert) | Kommentar trägt Chronik und ein Zeitdokument als Grund |
| R3-3 | INFO | Drei Ziel-Namen stehen in Inline-Code **ohne** `make`-Präfix: `baseline-verify`, `span-report`, `span-clean`. Sie fallen aus der Form-Regel (kein Trenner, keine Endung) **und** aus der `make`-Namen-Prüfung in `full-smoke` (die verlangt das Präfix). Alle drei sind heute wahr — `harness/mk/baseline.mk` führt `baseline-verify:`, das emittierte `erfassung.mk` führt `span-report:` und `span-clean:` —, aber die `GRENZE`-Notiz an `AdressenAusText` nennt nur den Prosa-Fall und lässt diesen offen. | Maintainability | `internal/emit/baumaussage.go:202-205` | nein | Benannte Grenze ist enger als die reale Grenze |
| R3-4 | INFO | `EmittierteAdressen()` kennt keine Adresse **innerhalb** des vendored Baums. Eine Zelle, die auf etwas im Baseline-Baum zeigen will, muss deshalb in Prosa ausweichen — genau die Form, die beide Vorlagen-Zellen jetzt tragen, und zugleich der blinde Fleck des Wächters. Die Ausweichbewegung ist hier sachlich richtig (ein Pfad mit Tag-Segment wäre die Drift, die `MR-033` adressiert), aber sie ist auch der Weg, auf dem eine künftige Zelle dem Wächter entgeht. | Maintainability | `internal/emit/baumaussage.go:173-190` gegen die Zellen zu `modul-04-adrs.md` und `modul-07-carveouts.md` | nein | Der Wächter-Scope lenkt die Formulierung, nicht umgekehrt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Die 28 Adress-Spannen der Inventur gegen den realen Emit | geprüft, ohne Befund — unabhängig extrahiert und einzeln zugeordnet; alle lösen auf, inklusive der drei korrigierten |
| Die zwei Prosa-Zellen | geprüft, ohne Befund — beide Vorlagen liegen im mitgelieferten Baum (`NNNN-titel.template.md`, `carveout.template.md`), die Aussage ist unverändert wahr |
| `test/mutations/369` | geprüft, ohne Befund — der `sed` trifft genau eine reale Zeile (`grep -c 'in-progress/roadmap.md' … → 1`), die gelesene Ausgabe nennt den behaupteten Test und den behaupteten Grund (`modul-06-roadmap.md … "docs/plan/planning/roadmap.md" — kein Lauf schreibt diese Adresse`) |
| `10ba3953` (SC2016) | geprüft, ohne Befund — das Muster kommt ohne Backticks aus, die getroffene Zeile bleibt dieselbe, keine Inline-Suppression (`AGENTS.md` §3.2) |
| Fixture-Weitung des Wächters | geprüft, ohne Befund — Fixture und vendored Vorlagen-Satz sind namensgleich (25 ≡ 25, `comm -23` leer) |
| Die zwei Schranken und der Geltungsbereich | geprüft, ohne Befund — `len(bekannt)==0` fatal, `geprueft==0` fällt, `TraegerKommtNichtMit` bleibt der Gegenrichtung überlassen |
| `MR-025` | geprüft, ohne Befund — keine neue Zahl im Code oder im emittierten Text; die Messangaben der Commit-Messages stehen neben ihren Kommandos |
| `MR-033` | geprüft, ohne Befund — die zwei Prosa-Zellen vermeiden gerade den tag-tragenden Pfad; der Mess-Stand des Blocks bleibt gekoppelt |
| `MR-053` | geprüft, ohne Befund — der Adaptions-Block ist nicht berührt; R2-1 aus Runde 2 bleibt unverändert offen (Architect) |
| Übrige neue Kommentare (`AGENTS.md` §3.7) | geprüft, ohne Befund außer R3-2 — `EmittierteAdressen`, `pfadEndungen` und `AdressenAusText` beschreiben, was da ist, und tragen ihre Grenze im Indikativ |
| Emittierter Datei-Satz, `§1`-Abgrenzung, Gate-Lockerung | geprüft, ohne Befund — kein neuer Ziel-Pfad, keine Schwelle, keine Suppression; der Wächter bildet Träger und Regel **nicht** automatisch aufeinander ab (er prüft Adressen, nicht Zuordnungen) und bleibt damit innerhalb von §1 |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Zellwert behauptet Anwesenheit eines bedingt emittierten
Trägers · Kommentar trägt Chronik und ein Zeitdokument als Grund · Benannte Grenze ist enger
als die reale Grenze · Der Wächter-Scope lenkt die Formulierung, nicht umgekehrt

Die erste Klasse steht mit F-3 aus Runde 1 damit **zweimal** in diesem Slice — das gehört in
die Closure-Notiz §7 und in das Beobachtungs-Register, nicht in eine weitere Review-Runde.

## Verdikt

**Die V-1-Nacharbeit selbst ist in Ordnung:** die Adresse ist real gezogen, die Fundmenge über
alle Zellen gefahren statt am Fundort gestoppt, der Wächter hält die positive Richtung ohne
Überdehnung, und sein Zahn färbt aus dem behaupteten Grund rot.

**Die Closure ist noch nicht frei — zwei MEDIUM, beide billig.** R3-1 ist ein Satz in einer
Zelle (die Bedingung, die `ADR-0054` für genau diesen Pfad setzt), R3-2 ein Satz in einem
Test-Kommentar. Beide blockieren nach der Voreinstellung des Skills, und keiner von beiden
verlangt eine Entscheidung: R3-1 folgt dem Muster, das dieser Slice für F-3 schon geschrieben
hat, R3-2 ist eine Streichung. R3-3 und R3-4 sind Notizen ohne Handlungsdruck.

Offen aus den Vorrunden, unverändert: F-7 (Planner), F-8 (INFO), R2-1 (Architect) und die
Klassenfrage aus F-5 (Architect). Keine davon ist eine Bedingung dieses Slice.

**Übergabe:** R3-1 und R3-2 an den Implementer; die Finding-Klassen in die Slice-Closure §7.
Dieser Report ist Lauf-Beleg und ersetzt keine Verifikation.

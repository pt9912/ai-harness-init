# ADR-0078: Die Ziel-Fassung regiert den Sprung `v6.13.0` → `v6.16.0` — die Prozedur ist byte-gleich, das Delta trifft einen Adaptions-Eintrag, den Reviewer-Skill, die Spezifikation und den emittierten Gate-Index

**Status:** Proposed

**Datum:** 2026-10-06

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (Kriterium in Festlegung 3, Trennung von
Prozedur und Ist-Maßstab in Festlegung 2),
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) (der vorige Sprung; sein erster
Re-Evaluierungs-Trigger ist der Anlass, seine Form wird hier gelesen statt abgeschrieben),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) (zweiter Re-Evaluierungs-Trigger: ein
geänderter Delegat verlangt die Abwägung),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (Delta-Basis),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Form der Buchung),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
[ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[`MR-076`](../../../harness/conventions.md#mr-076),
[`MR-075`](../../../harness/conventions.md#mr-075),
[`MR-080`](../../../harness/conventions.md#mr-080),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs.

**Kopplung:** wie [ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Kopplung — §Baseline
von [`harness/conventions.md`](../../../harness/conventions.md) bekommt Zielstand-Buchung und Zeiger
mit dem Vollzug, [`harness/migration.md`](../../../harness/migration.md) §1 die Sprung-Zeile; der
ADR-Index die Zeile dieser Datei mit diesem Commit.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Der Auftraggeber hat den Sprung `v6.13.0` → `v6.16.0` beauftragt, diese Entscheidung zuerst, der
Sprung-Slice danach. `K` ist ein Klon des Kurs-Repos, `T` ein Wegwerf-Baum; Zahlen aus einem
Tag-Vergleich sind fest, Zahlen aus dem Arbeitsbaum **keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025) Setzung 2).

### Achse, Range, Partition

```sh
git -C "$K" archive v6.13.0 lab/regelwerk lab/templates | tar -x -C "$T" --strip-components=1
diff -r -x SHA256SUMS .harness/baseline/v6.13.0 "$T" | grep '^[<>]' \
  | grep -v 'github\.com/pt9912/ai-harness-course' | grep -vE '\.\./\.\./' | wc -l    # ->  0
git -C "$K" diff --numstat v6.13.0..v6.16.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'               # -> 22 Dateien  +183  -43
git -C "$K" diff --name-only v6.13.0..v6.16.0 -- lab/regelwerk  | wc -l              # ->  8
git -C "$K" diff --name-only v6.13.0..v6.16.0 -- lab/templates  | wc -l              # -> 14
git -C "$K" diff --name-status v6.13.0..v6.16.0 -- lab/regelwerk lab/templates | grep -cE '^[AD]'   # -> 0
for c in 00ee506 4b597d8 deab3c3 94ac71d 2b61314; do
  echo "$c $(git -C "$K" tag --contains $c | sort -V | head -1)"; done
# -> 00ee506 v6.14.0 (Welle 154)   4b597d8 v6.14.0 (Wellen 155–156)   deab3c3 v6.14.1 (Welle 157)
#    94ac71d v6.15.0 (Welle 158)   2b61314 v6.16.0 (Welle 159)
```

Die Achse der Vorgänger gilt unverändert; vier Releases, keines übersprungen, keine Datei neu oder
entfallen — **das Delta ist anpassend, nicht strukturell**. Die Wellen-Zuordnung liest
`git -C "$K" log --oneline v6.13.0..v6.16.0 -- lab/regelwerk lab/templates`.

### Stufe (a) und (b) — Prozedur byte-gleich, ein Delegat ändert sich außerhalb des Gelesenen

```sh
F=lab/regelwerk/modul-02-harness-bootstrap.md; S='/^#### Freshness-Audit/,/^#### Gate-Fragment/p'
git -C "$K" show v6.16.0:$F | grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$'   # -> 1
diff <(git -C "$K" show v6.13.0:$F | sed -n "$S") <(git -C "$K" show v6.16.0:$F | sed -n "$S") \
  | grep -c '^[<>]'                                                                  # -> 0
git -C "$K" diff --numstat v6.13.0..v6.16.0 -- lab/regelwerk/grundlagen-harness-dateien.md   # -> 60  3
G=lab/regelwerk/grundlagen-harness-dateien.md
for t in v6.13.0 v6.16.0; do git -C "$K" show $t:$G \
  | sed -n '/^### harness\/README.md als Einstiegspunkt/,/^## Leseordnung/p' | sha256sum; done
# -> 9cc69aa7… zweimal
git -C "$K" diff -U0 v6.13.0..v6.16.0 -- $G | grep '^@@'      # Hunks bei Zeile 25, 198, 206, 270, 342
```

Von den fünf Delegaten ändert sich nur `grundlagen-harness-dateien.md`. Die Prozedur liest dort
zwei Stellen: die Pflichtgliederung von §Einstiegspunkt (byte-gleich, Hash oben) und
§Konventionsspeicher (ab Zeile 408 am Tag `v6.16.0`, hinter allen Hunks). Der Zuwachs — Werkzeug-Teile
des Gate-Index, die Spezifikation als Ort der Werkzeug-Festlegungen — ist Gegenstand des
Durchgangs, nicht seiner Fragen. Damit ist der zweite Re-Evaluierungs-Trigger von
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) eingetreten und abgewogen: Der Durchgang
stellt unter beiden Fassungen dieselben Fragen.

**Die Meta-Frage beantwortet auch `v6.16.0` nicht:** die 13 Zeichenketten aus
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Auch `v6.13.0` beantwortet die
Meta-Frage nicht, über die `+`-Zeilen des Diffs `v6.13.0..v6.16.0` gezählt → **0** Treffer.
Dieselbe Grenze: ein Negativ über aufgezählte Wörter.

**Delta-Basis:** `ls -1 .harness/baseline/` → `v6.13.0`, und der letzte Durchgang lief für
`v6.13.0` — Basis `v6.13.0`, mit demselben Schluss wie
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Die Delta-Basis; die dort benannte
Lücke bleibt offen.

### Was das Delta in diesem Repo trifft

```sh
grep -E '^\| `SPEC-024`' spec/spezifikation.md | grep -c '| Optional |'           # -> 1
grep -n 'pfad`: Datei:Zeile' .harness/skills/reviewer.md | wc -l                     # -> 1
grep -n '^## ' spec/spezifikation.md | tail -1                                       # -> ## 7. Historie
ls harness/sensors/*.md | wc -l                                                      # -> 21
git grep -ohE 'harness/mk/[a-z0-9-]+\.mk' -- internal/emit ':!*_test.go' | sort -u | wc -l   # -> 11
ls harness/mk 2>/dev/null | wc -l                                                    # ->  0
grep -l 'BEO-<NNN>' docs/plan/planning/open/*.md docs/plan/planning/next/*.md | wc -l        # -> 31
ls harness/conventions/*.md | wc -l                                                  # -> 77
readlink .claude/rules/*.md | grep -c 'modul-13-quality-gates'                       # ->  1
```

Eine der acht geänderten Regelwerk-Dateien steht im Auto-Kontext (`modul-13-quality-gates.md`).

## Entscheidung

### Festlegung 1 — für diesen Sprung regiert die Ziel-Fassung `v6.16.0`

Gemeint ist `v6.16.0`, `lab/regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored
Baseline (Schritt 2), samt Ausgängen und Delegaten. Tragend: (1) der Durchgang läuft unter beiden
Fassungen inhaltlich gleich (§Stufe (a) und (b)); (2) was der Inhalt offenlässt, entscheidet die
Tag-Klammer ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — nach dem
Vollzug tragen Pins, Symlinks, vendored Baum und emittierter Mess-Tag `v6.16.0`.

### Festlegung 2 — Delta-Walkthrough je Release, über die volle Liste

Die Freshness-Review liest die acht geänderten Regelwerk-Dateien am Tag `v6.16.0` als Volltext,
geordnet `v6.14.0` → `v6.14.1` → `v6.15.0` → `v6.16.0`; jeder Ausgang nennt sein Release. Die
Grundgesamtheit bleibt die volle Liste der aktiven Einträge — dieselbe Organisation der Lesung wie
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) Festlegung 2, für diesen Sprung neu
gesetzt, keine allgemeine Regel.

### Festlegung 3 — Kandidaten und Folge-Arbeit je Welle

Die Spalte *Kandidat* benennt, wo der Durchgang zuerst liest; der Ausgang je Eintrag bleibt sein
Urteil. Die Spalte *Folge-Arbeit* gilt **unter der Übernahme-Vorgabe** (offene Entscheidung 1).

| Welle (Release) | Delta | Kandidat im Bestand | Folge-Arbeit (Eigenschaft) |
|---|---|---|---|
| 154 (`v6.14.0`) | `modul-15` §Audit-Span-Schema: liefert die Quelle einen Wert nicht, ist das **keine Abweichung** — das Pflichtfeld bleibt Pflicht und wird ausdrücklich als *nicht bekannt* gekennzeichnet, mit Nennung der Quelle | [`MR-076`](../../../harness/conventions.md#mr-076): sein Grund ist genau dieser Fall; seine Abweichung verliert ihr Objekt. Mitzulesen: `SPEC-024`/`SPEC-055`, `SPEC-022` (`spawned_role`, *abwesend heißt unbekannt*) und der Leerwert von `agent_role` gegen *„nicht `keine Rolle`"*; [`MR-077`](../../../harness/conventions.md#mr-077) ist ein Ersatzfeld, kein fehlender Wert | [`MR-076`](../../../harness/conventions.md#mr-076) tritt zurück; die Cache-Zähler werden Pflicht mit Unbekannt-Kennzeichnung — Spezifikation, Erfassung und Tests ziehen mit ([`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)). Die Draht-Form der Kennzeichnung legt die Spezifikation fest |
| 155–156 (`v6.14.0`) | `modul-10` und Reviewer-Vorlage: kein HIGH/MEDIUM ohne Failure-Szenario, kein Stil-Finding ohne Konventions-Anker, `pfad` = Datei · wörtliches Kurzzitat (Zeile nur Lesehilfe) | kein MR; `.harness/skills/reviewer.md` (`pfad`: Datei:Zeile) und der emittierte Reviewer-Anweisungssatz | Reviewer-Skill und emittierte Fassung ziehen Output-Schema und die zwei Ausschlüsse nach — durch die Rolle, der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) den Anweisungssatz zuordnet |
| 157 (`v6.14.1`) | Vorlagen führen `BEO-<KUERZEL>/<slug>` statt `BEO-<NNN>` | kein MR — das Repo führt die Pfad-Form seit [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3; die Vorlage holt auf | **akzeptiertes Negativ:** die 31 Pläne mit alter Vorlagen-Zeile zieht nach, wer sie anfasst; [ADR-0065](0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) zitiert die flache Form als damaligen Vorlagen-Text, ihre Entscheidung (kein Muster für `BEO-`) gilt unter beiden Formen — kein Folge-ADR |
| 158 (`v6.15.0`) | Was ein Gate, Prüfer, Hook prüft und wie er an Randformen entscheidet, ist eine technische Festlegung und steht in der Spezifikation (Vorlage §7 *Festlegungen der Harness-Werkzeuge*, Historie wird §8); Sensor-Datei und Skriptkopf tragen sie nicht; die Gate-ADR schärft diese Stelle | [`MR-075`](../../../harness/conventions.md#mr-075) (gilt für jede künftige Festlegungs-Tabelle, also auch §7), [`MR-019`](../../../harness/conventions.md#mr-019) (bestätigt); die 21 Dateien unter `harness/sensors/` | Spezifikation bekommt §7, Historie wird §8; Inventur der Randform-Festlegungen in Sensor-Dateien und Skriptköpfen, Umzug nach §7. `Accepted`-Gate-ADRs mit `Schärft: —` bleiben (§3.4); neue Gate-ADRs schärfen ihre Stelle |
| 159 (`v6.16.0`) | Bringt ein Werkzeug Make-Fragmente unter harness/mk mit, führt es deren Targets in `harness/mk/<werkzeug>.md` — werkzeug-eigen, disjunkt, vom Einstieg verlinkt; der Deklarations-Sensor misst gegen die Vereinigung | Dogfood: kein Verzeichnis harness/mk (das Fragment liegt nach [`MR-010`](../../../harness/conventions.md#mr-010) an der Wurzel) — die Bedingung greift nicht. **Emittiert:** das Werkzeug legt elf Fragmente unter harness/mk ins Ziel | Das Werkzeug schreibt im Ziel seinen Teil des Gate-Index, das emittierte `harness/README.md` verlinkt ihn, die emittierte `.d-check.yml` misst gegen die Vereinigung (die Listen-Form trägt der Pin aus [`MR-080`](../../../harness/conventions.md#mr-080)). Die Disjunktheit prüft der Sensor nicht — benannte Grenze im Ziel |

### Was diese Festlegungen nicht tun

Kein `Supersedes` ([ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) gilt nur für ihren
Sprung); keine allgemeine Regel; kein Ausgang an einem Eintrag — Festlegung 3 benennt Kandidaten
und Folge-Arbeit, das Urteil fällt im Durchgang; keine Entscheidung über die Delta-Basis künftiger
Sprünge.

### Offene Entscheidungen des Auftraggebers

1. **Übernahme vollständig** (*„eine Abweichung wird nicht gesetzt"*, wie bei den Sprüngen davor)
   oder einzelne Abweichungen? **Empfehlung: vollständig.** Davon hängt die Spalte *Folge-Arbeit*
   ab; bei einer Abweichung wird sie für diese Welle ein neuer `MR`.
2. **Schnitt der Folge-Arbeit:** Der Sprung-Slice trägt Vollzug, Durchgang und die Welle-154-Folge
   (sie entscheidet einen Adaptions-Ausgang). **Empfehlung:** Welle 158 (Spezifikation §7 samt
   Inventur) und Welle 159 (emittierter Gate-Index-Teil) je als eigener Slice, Welle 155–156 als
   Nachzug am Reviewer-Skill im Sprung-Slice.

### Acceptance-Trigger

`Accepted` auf Weisung des Auftraggebers, nach einer Reviewer-Konsistenzrunde in frischem Kontext
gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) ohne blockierenden Befund;
der Accept-Übergang nennt den Report bei seiner Kennung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden | kein Aufwand | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt die Begründung |
| B — gepinnte Fassung `v6.13.0` regiert | netzlos lesbar, Durchgang liefe gleich | nach dem Tausch trägt kein Pin den Tag; Buchung und Entscheidung auf verschiedenen Tags |
| C — Momentaufnahme über die Gesamtspanne | spart die Partition | die Release-Attribution je Ausgang würde gedeutet statt gelesen |
| D — Folge-Arbeit offen lassen, nur die Fassung wählen | kürzer | der Sprung-Slice müsste die Wirkung des Deltas neu messen; Welle 159 wirkt nur auf der emittierten Ebene und fiele aus einem Durchgang über den Adaptions-Block heraus |
| **E — gewählt: Ziel-Fassung, Walkthrough je Release, Kandidaten und Folge-Arbeit je Welle benannt** | Pins und Entscheidung auf einem Tag; der Schnitt liest die Wirkung, statt sie zu messen | Festlegung 3 kann einen Treffer übersehen, den erst der Volltext zeigt — die volle Liste bleibt darum Grundgesamtheit |

## Konsequenzen

- **Positiv:** Der Sprung hat seine Quelle vor dem ersten Konformitäts-Urteil, und der Schnitt
  kennt die vier Wirkungsorte: einen Adaptions-Eintrag, den Reviewer-Skill, die Spezifikation, den
  emittierten Gate-Index.
- **Negativ:** Welle 154 bewegt eine bewusste Abweichung zurück in eine Pflicht — Code, Spec und
  Tests der Erfassung ändern sich, nicht nur Doku.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  kein Sensor liest, nach welcher Fassung ein Durchgang lief.
- **Folgepflicht (Architect), mit dem Vollzug:** Buchung in §Baseline nach
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 samt Zeiger auf
  diese Entscheidung; Sprung-Zeile in [`harness/migration.md`](../../../harness/migration.md) §1;
  Freshness-Review nach Festlegung 2.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Lücke:** ob ein Durchgang der gewählten Prozedur folgte, ist ein Urteil über einen Vorgang;
`make baseline-verify` belegt nur den vendored Tag — dieselbe Lage wie bei
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Fitness Function.

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an:** er misst neu, Achse zuerst.
- **Der Zielstand bewegt sich vor dem Vollzug** (`make baseline-freshness` meldet einen neueren Tag,
  oder der Auftraggeber nennt einen anderen): die Festlegung verliert ihr Objekt.
- **Der Durchgang findet unter `v6.16.0` einen Kandidaten, den Festlegung 3 nicht nennt:** die Tabelle
  ist unvollständig; die Folge-Arbeit dazu entsteht im Durchgang, ohne Nachbesserung dieser Datei
  nach `Accepted`.
- **Ein künftiger Sprung ändert die gelesenen Stellen eines Delegaten:** die Abwägung aus §Stufe (b)
  ist neu zu führen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-06 | **Proposed** | Auftrag des Auftraggebers zum Sprung `v6.13.0` → `v6.16.0`; erster Re-Evaluierungs-Trigger von [ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) |

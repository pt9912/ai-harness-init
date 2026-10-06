# ADR-0078: Die Ziel-Fassung regiert den Sprung `v6.13.0` → `v6.16.0` — die Prozedur ist byte-gleich, das Delta trifft einen Adaptions-Eintrag, den Reviewer-Skill, die Spezifikation und den emittierten Gate-Index

**Status:** Accepted

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
[ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (zweiter
Re-Evaluierungs-Trigger feuert, Festlegung 4),
[ADR-0076](0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) (Teil-Ablösung,
Festlegung 4),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[`MR-076`](../../../harness/conventions.md#mr-076),
[`MR-075`](../../../harness/conventions.md#mr-075),
[`MR-080`](../../../harness/conventions.md#mr-080),
[`MR-054`](../../../harness/conventions.md#mr-054),
[`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Supersedes (Teil):** [ADR-0076](0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md)
Festlegung 1, und dort genau **eine** Zelle — der Ausgang *Adaptions-Eintrag* von E1 für
Abweichung 1 (Träger [`MR-076`](../../../harness/conventions.md#mr-076)). Alles andere jener
Festlegung bindet fort, namentlich Abweichung 2 mit
[`MR-077`](../../../harness/conventions.md#mr-077). Wirksam mit dem Vollzug von Festlegung 4.

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs.

**Kopplung:** wie [ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Kopplung — §Baseline
von [`harness/conventions.md`](../../../harness/conventions.md) bekommt Zielstand-Buchung und Zeiger
mit dem Vollzug, [`harness/migration.md`](../../../harness/migration.md) §1 die Sprung-Zeile; der
ADR-Index die Zeile dieser Datei mit diesem Commit und, mit `Accepted`, die Teil-Ablösung in der
Status-Zelle von ADR-0076.

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
# -> ed2a4b6307a9… zweimal (17 Zeilen: Überschrift bis Ende der Pflichtgliederung)
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
grep -cE '^\| `SPEC-01[012]` .*\| Pflicht \|' spec/spezifikation.md                 # -> 3
grep -n 'pfad`: Datei:Zeile' .harness/skills/reviewer.md | wc -l                     # -> 1
ls .harness/skills/                                                                  # -> reviewer.md
grep -n '^## ' spec/spezifikation.md | tail -1                                       # -> ## 7. Historie
grep -c '"7. Historie"' .d-check.yml                                                 # -> 1
ls harness/sensors/*.md | wc -l                                                      # -> 21
git grep -ohE 'harness/mk/[a-z0-9-]+\.mk' -- internal/emit ':!*_test.go' | sort -u | wc -l   # -> 11
ls harness/mk 2>/dev/null | wc -l                                                    # ->  0
grep -l 'BEO-<NNN>' docs/plan/planning/open/*.md docs/plan/planning/next/*.md | wc -l        # -> 31
ls harness/conventions/*.md | wc -l                                                  # -> 77
readlink .claude/rules/*.md | grep -c 'modul-13-quality-gates'                       # ->  1
```

Eine der acht geänderten Regelwerk-Dateien steht im Auto-Kontext (`modul-13-quality-gates.md`).

### Emittierte Ebene: diesmal zieht der Inhalt mit

```sh
git -C "$K" diff --name-only v6.13.0..v6.16.0 -- lab/templates | grep -c '\.template\.md$'   # -> 12
grep -n 'const InventurMessTag' internal/emit/baumaussage.go       # -> 36:… = "v6.13.0"
grep -c 'pfad' internal/emit/templates/agents/reviewer.md          # ->  0
grep -n '7\. Historie' internal/emit/templates/d-check.yml         # -> 34, 44 (Kommentar)
```

`inScope` (`internal/emit/templates.go`) emittiert jede `*.template.md` des gefetchten Baums außer
der Root-README; mit der Pin-Anhebung reisen damit die zwölf geänderten Vorlagen ins Ziel —
Reviewer- und Closure-Note-Reviewer-Skill, Review-Report, Slice, Welle-Results, ADR samt Index,
Spezifikation (§7/§8), Gate-Index-README, AGENTS, Konventions-Vorlage, Sensor-Datei. Anders als bei
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Emittierte Ebene ist das nicht nur
die Adresse `InventurMessTag`: das Ziel bekommt neuen Text, ohne dass ein Werkzeug-Satz sich
ändert. Ein vom Werkzeug **eigens** geschriebener Reviewer-Ablauf existiert nicht — die Rollen-Karte
`agents/reviewer.md` trägt kein Output-Schema (Zähler oben); Skill-Dateien im Ziel sind
Vorlagen-Kopien.

## Entscheidung

### Festlegung 1 — für diesen Sprung regiert die Ziel-Fassung `v6.16.0`, Übernahme vollständig

Gemeint ist `v6.16.0`, `lab/regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored
Baseline (Schritt 2), samt Ausgängen und Delegaten. Tragend: (1) der Durchgang läuft unter beiden
Fassungen inhaltlich gleich (§Stufe (a) und (b)); (2) was der Inhalt offenlässt, entscheidet die
Tag-Klammer ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — nach dem
Vollzug tragen Pins, Symlinks, vendored Baum und emittierter Mess-Tag `v6.16.0`. **Die Übernahme
ist vollständig** (Auftraggeber, 2026-10-06): keine neue Abweichung wird gesetzt; wo eine
bestehende ihren Grund an eine Welle verliert, tritt sie mit dem Nachzug zurück.

### Festlegung 2 — Delta-Walkthrough je Release, über die volle Liste

Die Freshness-Review liest die acht geänderten Regelwerk-Dateien am Tag `v6.16.0` als Volltext,
geordnet `v6.14.0` → `v6.14.1` → `v6.15.0` → `v6.16.0`; jeder Ausgang nennt sein Release. Die
Grundgesamtheit bleibt die volle Liste der aktiven Einträge — dieselbe Organisation der Lesung wie
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) Festlegung 2, für diesen Sprung neu
gesetzt, keine allgemeine Regel.

### Festlegung 3 — Kandidaten, Folge-Arbeit und Schnitt je Welle

Die Spalte *Kandidat* benennt, wo der Durchgang zuerst liest; das Urteil je weiterem Eintrag fällt
im Durchgang. Der **Schnitt** (Auftraggeber, 2026-10-06): der Sprung-Vorgang trägt Vendoring,
Pins und die Wellen 154–156; Welle 158 ist ein eigener Folge-Vorgang; Welle 159 trägt der
vorhandene Vorgang, der das Modul `targets` ins emittierte Doc-Gate aufnimmt.

| Welle (Release) | Delta | Kandidat im Bestand | Folge-Arbeit (Eigenschaft) · Träger |
|---|---|---|---|
| 154 (`v6.14.0`) | `modul-15` §Audit-Span-Schema: liefert die Quelle einen Wert nicht, ist das **keine Abweichung** — das Pflichtfeld bleibt Pflicht und ist ausdrücklich als *nicht bekannt* gekennzeichnet (nicht `0`, nicht `false`, nicht „keine Rolle"), unter Nennung der Quelle | [`MR-076`](../../../harness/conventions.md#mr-076) (`SPEC-024` `Optional`); `SPEC-010` `agent_role`, `SPEC-011` `slice`, `SPEC-012` `requirement` (Pflicht, Leerwert `""`); `SPEC-022` `spawned_role`; [`MR-077`](../../../harness/conventions.md#mr-077) ist ein Ersatzfeld, kein fehlender Wert | Festlegung 4 · Sprung-Vorgang |
| 155–156 (`v6.14.0`) | `modul-10`, Reviewer- und Closure-Note-Reviewer-Vorlage, Review-Report: kein HIGH/MEDIUM ohne Failure-Szenario, kein Stil-Finding ohne Konventions-Anker, `pfad` = Datei · wörtliches Kurzzitat (Zeile nur Lesehilfe) | kein MR; `.harness/skills/reviewer.md` (`pfad`: Datei:Zeile); eine Closure-Note-Reviewer-Datei führt das Repo nicht | der Reviewer-Skill zieht Output-Schema und die zwei Ausschlüsse nach — durch die Rolle, der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ihn zuordnet. **Emittiert:** kein Nachzug, die Vorlagen-Kopien reisen mit dem Pin (§Emittierte Ebene) · Sprung-Vorgang |
| 157 (`v6.14.1`) | Vorlagen führen `BEO-<KUERZEL>/<slug>` statt `BEO-<NNN>` | kein MR — das Repo führt die Pfad-Form seit [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3; die Vorlage holt auf | **akzeptiertes Negativ:** die 31 Pläne mit alter Vorlagen-Zeile zieht nach, wer sie anfasst; [ADR-0065](0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) zitiert die flache Form als damaligen Vorlagen-Text, ihre Entscheidung (kein Muster für `BEO-`) gilt unter beiden Formen — kein Folge-ADR |
| 158 (`v6.15.0`) | Was ein Gate, Prüfer, Hook prüft und wie er an Randformen entscheidet, ist eine technische Festlegung der Spezifikation: setzt das Werkzeug genau eine Anforderung durch, als deren Verfeinerung in §1, sonst in §7 *Festlegungen der Harness-Werkzeuge* (Historie wird §8); Sensor-Datei und Skriptkopf tragen sie nicht; die Gate-ADR schärft diese Stelle | [`MR-075`](../../../harness/conventions.md#mr-075) (gilt für jede künftige Festlegungs-Tabelle, also auch §7), [`MR-019`](../../../harness/conventions.md#mr-019) (bestätigt); die 21 Dateien unter `harness/sensors/`; `exclude-sections` der `.d-check.yml` (`"7. Historie"`); die Kommentare zu `7. Historie` in `internal/emit/templates/d-check.yml` | Inventur der Randform-Festlegungen in Sensor-Dateien und Skriptköpfen, Umzug nach §1 oder §7; Spezifikation bekommt §7, Historie wird §8, und `exclude-sections` zieht den neuen Namen desselben Abschnitts nach (kein neuer Ausnahme-Gegenstand, darum keine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5); die zwei Kommentare werden wahr gezogen. `Accepted`-Gate-ADRs mit `Schärft: —` bleiben (§3.4); neue Gate-ADRs schärfen ihre Stelle · eigener Folge-Vorgang |
| 159 (`v6.16.0`) | Bringt ein Werkzeug Make-Fragmente unter harness/mk mit, führt es deren Targets in `harness/mk/<werkzeug>.md` — werkzeug-eigen, disjunkt, vom Einstieg verlinkt; der Deklarations-Sensor misst gegen die Vereinigung | Dogfood: kein Verzeichnis harness/mk (das Fragment liegt nach [`MR-010`](../../../harness/conventions.md#mr-010) an der Wurzel) — die Bedingung greift nicht. **Emittiert:** elf Fragmente unter harness/mk im Ziel, kein Werkzeug-Teil; das emittierte Doc-Gate fährt heute kein `targets`. [`MR-054`](../../../harness/conventions.md#mr-054) bindet die Aufnahme eines Moduls an Erprobung, grünen Start und rotes Gegenbeispiel; [`MR-080`](../../../harness/conventions.md#mr-080) trägt die Listen-Form, die emittierte Startkonfiguration nimmt er aus | Das Werkzeug schreibt im Ziel seinen Teil des Gate-Index, das emittierte `harness/README.md` verlinkt ihn; gegen die Vereinigung misst erst ein emittiertes `targets`, und dessen Aufnahme besteht die drei Kriterien von [`MR-054`](../../../harness/conventions.md#mr-054) — die Übernahme-Vorgabe ersetzt sie nicht. Die Disjunktheit prüft der Sensor nicht — benannte Grenze im Ziel · der vorhandene Vorgang zum emittierten `targets` |

**Skriptkopf und [`AGENTS.md`](../../../AGENTS.md) §3.7 — akzeptiertes Negativ.** Welle 158 nimmt
dem Skriptkopf die Festlegung (*was* das Werkzeug prüft), nicht jede Zusage: §3.7 nennt Klassen,
keinen Ort für Werkzeug-Festlegungen, und der Abschnitt des Regelwerks dazu
(`grundlagen-harness-dateien.md` §Was ein Kommentar trägt, Zeilen 73–169) liegt vor allen Hunks.
Ein Kopf, aus dem die Festlegung nach §7 zieht, behält einen Rang-Zeiger dorthin — eine Klasse,
die §3.7 führt; `make comment-claims` prüft weiter, ob ein genannter Sensor existiert. Keine
Hard-Rule-Änderung.

### Festlegung 4 — Welle 154: `MR-076` tritt mit der Umstellung von `SPEC-024` zurück, nicht mit dem Vendoring

[ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 3 hält: *„echt
macht sie die Wahl, nicht der Wert"*. Das gilt unter `v6.16.0` unverändert — solange `SPEC-024`
`Optional` steht, ist die Abweichung echt, und [`MR-076`](../../../harness/conventions.md#mr-076)
bleibt ihr Ort. Unter der vollständigen Übernahme wird die Wahl zurückgenommen:

1. **Der Sprung-Vorgang stellt `SPEC-024` auf `Pflicht` mit Kennzeichnung *nicht bekannt* um**,
   samt Erfassung und Tests ([`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans));
   die Draht-Form der Kennzeichnung und die Nennung der Quelle legt die Spezifikation fest.
2. **Erst danach** hebt der Architect [`MR-076`](../../../harness/conventions.md#mr-076) auf (Kopf und Zeiger,
   [`MR-020`](../../../harness/conventions.md#mr-020)), in eigenem Commit; bis dahin bleibt er aktiv,
   auch über das Vendoring hinweg. Das ist die Teil-Ablösung von ADR-0076 im Kopf dieser Datei —
   ihr erster Re-Evaluierungs-Trigger verlangt sie, weil der Auftraggeber E1 für Abweichung 1
   anders entschieden hat.
3. **`SPEC-010`/`011`/`012`** liest der Durchgang mit: wo `""` *nicht bekannt* bedeutet (für
   `agent_role` die Lesevorschrift `SPEC-044`), bekommt das Feld dieselbe Kennzeichnung; wo `""`
   einen Wert trägt (*kein Slice*, *kein Bezug*), muss er von *nicht bekannt* unterscheidbar
   bleiben. `SPEC-022` ist `Optional` und keine Pflicht des Minimums.
4. **Trigger-Audit [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md):** ihr
   zweiter Re-Evaluierungs-Trigger (*„Wenn der Kurs das Modul 15 um eine Kennzeichnung ‚Quelle
   liefert das Feld nicht' ergänzt"*) ist eingetreten — **bestätigt, kein Folge-ADR**: die Folge
   nennt der Trigger selbst (die Wortwahl folgt dem Modul), und die Einstufung der Festlegung 3
   (Abweichungen 3, 5, 6 betreffen den Wert; 1 und 2 sind echt, solange die Wahl steht) gilt unter
   dem neuen Wortlaut wörtlich. Was sich ändert, ist der Ausgang von E1 — der gehört ADR-0076.

### Festlegung 5 — das emittierte Intervall bis zum Werkzeug-Teil ist zulässig, ohne Release dazwischen

Zwischen Sprung-Vollzug und dem Vorgang zum emittierten `targets` trägt ein gebootstrapptes Ziel
die `v6.16.0`-Anweisung (emittiertes `harness/README.md`, Kommentarblock §Sensors, und
`AGENTS.md` §4), das Werkzeug führe die Targets seiner Fragmente in `harness/mk/<werkzeug>.md` —
und das Werkzeug schreibt die elf Fragmente ohne diesen Teil. **Das Intervall ist zulässig**, unter
einer Bedingung: **kein Release-Tag zwischen beiden.** Gründe: (1) kein Gate im Ziel wird rot —
der Satz steht im Kommentar, und das emittierte Doc-Gate fährt kein `targets`; der Widerspruch ist
Doku, und ohne Release erreicht er keinen Adopter. (2) Den 159-Vorgang in den Sprung zu ziehen,
holte die drei Kriterien von [`MR-054`](../../../harness/conventions.md#mr-054) in ihn und
überschritte die Größenregel (`modul-05-planning-harness.md` §Ziel-Form: Slice, ≤ 3
Liefer-Punkte). **Grenze:** kein Sensor hält die Release-Bedingung; Träger ist der Release-Schnitt,
der diese Entscheidung liest.

### Was diese Festlegungen nicht tun

Kein `Supersedes` an [ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) (sie gilt nur für
ihren Sprung) und keines an ADR-0074; keine allgemeine Regel; keine Draht-Form der Kennzeichnung;
keine Entscheidung über die Delta-Basis künftiger Sprünge.

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
| E — [`MR-076`](../../../harness/conventions.md#mr-076) behalten (Abweichung bleibt) | keine Änderung an Erfassung und Tests | widerspricht der vollständigen Übernahme; der Grund des Eintrags ist nach Welle 154 keine Abweichung mehr |
| F — Welle 159 in den Sprung | kein Intervall im Ziel | holt [`MR-054`](../../../harness/conventions.md#mr-054) in den Sprung, sprengt die Größenregel |
| **G — gewählt: Ziel-Fassung, Walkthrough je Release, Kandidaten und Schnitt je Welle, [`MR-076`](../../../harness/conventions.md#mr-076) an die Spec-Umstellung gebunden, Intervall ohne Release** | Pins und Entscheidung auf einem Tag; der Schnitt liest die Wirkung, statt sie zu messen | Festlegung 3 kann einen Treffer übersehen, den erst der Volltext zeigt — die volle Liste bleibt darum Grundgesamtheit |

## Konsequenzen

- **Positiv:** Der Sprung hat seine Quelle vor dem ersten Konformitäts-Urteil, und der Schnitt
  kennt die Wirkungsorte: einen Adaptions-Eintrag, den Reviewer-Skill, die Spezifikation, den
  emittierten Gate-Index und die mitreisenden Vorlagen.
- **Negativ:** Welle 154 bewegt eine bewusste Abweichung zurück in eine Pflicht — Code, Spec und
  Tests der Erfassung ändern sich im Sprung-Vorgang, nicht nur Doku.
- **Negativ:** Bis zum Vorgang zum emittierten `targets` widerspricht ein frisch gebootstrapptes
  Ziel seiner eigenen Vorlage (Festlegung 5).
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  kein Sensor liest, nach welcher Fassung ein Durchgang lief.
- **Folgepflicht (Architect), mit dem Vollzug:** Buchung in §Baseline nach
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 samt Zeiger auf
  diese Entscheidung; Sprung-Zeile in [`harness/migration.md`](../../../harness/migration.md) §1;
  Freshness-Review nach Festlegung 2; Aufhebung von [`MR-076`](../../../harness/conventions.md#mr-076) nach Festlegung 4 Punkt 2.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Lücke:** ob ein Durchgang der gewählten Prozedur folgte, ist ein Urteil über einen Vorgang;
`make baseline-verify` belegt nur den vendored Tag — dieselbe Lage wie bei
[ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) §Fitness Function. Die Reihenfolge von
Spec-Umstellung und Aufhebung (Festlegung 4) und die Release-Bedingung (Festlegung 5) liest
ebenfalls kein Sensor.

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an:** er misst neu, Achse zuerst.
- **Der Zielstand bewegt sich vor dem Vollzug** (`make baseline-freshness` meldet einen neueren Tag,
  oder der Auftraggeber nennt einen anderen): die Festlegung verliert ihr Objekt.
- **Der Durchgang findet unter `v6.16.0` einen Kandidaten, den Festlegung 3 nicht nennt:** die Tabelle
  ist unvollständig; die Folge-Arbeit dazu entsteht im Durchgang, ohne Nachbesserung dieser Datei
  nach `Accepted`.
- **Ein künftiger Sprung ändert die gelesenen Stellen eines Delegaten:** die Abwägung aus §Stufe (b)
  ist neu zu führen.
- **Ein Release wird geschnitten, bevor das Ziel seinen Werkzeug-Teil des Gate-Index bekommt:**
  Festlegung 5 ist gebrochen; das Intervall gehört dann als Grenze in die Release-Notiz oder der
  Vorgang vor den Release.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-06 | **Proposed** | Auftrag des Auftraggebers zum Sprung `v6.13.0` → `v6.16.0`; erster Re-Evaluierungs-Trigger von [ADR-0072](0072-ziel-fassung-regiert-den-sprung-v6130.md) |
| 2026-10-06 | **Accepted** | Weisung des Auftraggebers vom 2026-10-06; Acceptance-Trigger eingelöst durch die Reviewer-Konsistenzrunde `2026-10-06-adr-0078-review` (kein HIGH; die drei MEDIUM vor der Annahme eingearbeitet, [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1) |

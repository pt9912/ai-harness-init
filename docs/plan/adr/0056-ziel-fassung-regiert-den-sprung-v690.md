# ADR-0056: Die Ziel-Fassung regiert auch den Sprung `v6.8.0` → `v6.9.0` — die Prozedur ändert sich additiv, tragend ist deshalb wieder ein inhaltlicher Grund, und das Vorlagen-Delta gibt dem Instanz-Durchgang einen Gegenstand

**Status:** Proposed

**Datum:** 2026-09-16

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (sie liefert das Kriterium in Festlegung 3,
die Trennung von Prozedur und Ist-Maßstab in Festlegung 2 und die Grenzen in Festlegung 4; ihr
§*Wer den Zielstand bewegt* behält die Setzung dem Auftraggeber vor),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) (der vorige Sprung; ihr erster und zweiter
Re-Evaluierungs-Trigger sind eingetreten, und ihre §Konsequenzen verbuchen die Übernahme-Vorgabe
des Auftraggebers in der Form, die hier wiederkehrt),
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) (zuletzt ein inhaltlicher Grund, dort in
einem Delegat; ihre §Konsequenzen benennen, welchen Ausgang die Übernahme-Vorgabe trifft),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2, die Leseregel für die
Delta-Basis, wird gelesen, nicht ersetzt),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**; Festlegung 2
bestimmt den Ort der Buchung. Die Zitierfähigkeit einer nicht angenommenen Entscheidung führt
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen als benannte Lücke),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Beleg im Accept-Übergang),
[ADR-0052](0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md) (**`Proposed`**; kein
host-lokaler Pfad, deshalb stehen unten Platzhalter),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (Eigentum an Register und Plan),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (ein Beleg trägt Tag und Zitat),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
und
[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
(hier gemessen, nicht beurteilt),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs.

**Kopplung:** §Baseline von [`harness/conventions.md`](../../../harness/conventions.md) verbucht
die Setzung auf `v6.9.0` und zeigt hierher. [`harness/migration.md`](../../../harness/migration.md)
§1 führt die derivative Zeile. Beides ist Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md)
§3.8).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

Festlegung 3 von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) verlangt vor jedem Sprung
eine Messung: Führt die **gepinnte** Fassung die Migrations-Prozedur? Führen beide Fassungen sie,
ist die Wahl offen und im Sprung zu begründen. Der Auftraggeber hat den Zielstand am 2026-09-16 auf
`v6.9.0` gesetzt. Diese Entscheidung setzt das voraus.

Die Kommandos unten nutzen zwei Platzhalter: `K` steht für einen Klon des Kurs-Repos (eine
Host-Voraussetzung), `T` für einen Wegwerf-Baum außerhalb des Repos. Ein Vergleich Tag gegen Tag
liefert eine feste Zahl. Eine Zahl über den Arbeitsbaum ist dagegen **kein Erwartungswert**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Achse und Range

```sh
git -C "$K" archive v6.8.0 lab/regelwerk lab/templates | tar -x -C "$T" --strip-components=1
diff -rq -x SHA256SUMS .harness/baseline/v6.8.0 "$T" | wc -l                           # -> 28
diff -r  -x SHA256SUMS .harness/baseline/v6.8.0 "$T" | grep '^[<>]' \
  | grep -v 'github\.com/pt9912/ai-harness-course' | grep -vE '\.\./\.\./' | wc -l    # ->  0
git -C "$K" log --oneline --decorate v6.8.0..v6.9.0
# -> ab8b4dc (tag: v6.9.0) feat(kurs+regelwerk+templates+example+lab): Welle 137 - Ein Slice, dessen Gegenstand ein anderer uebernimmt
#    ee254a0 feat(kurs+regelwerk): Welle 136 - Append-only-Klausel: welche Artefakt-Klassen sie traegt
#    3658c86 docs(roadmap): Meilenstein v6.8.0 mit Beleg eintragen
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # -> 7 Dateien  +137  -13
```

Der vendored Baum weicht vom Release-Asset nur in den zwei bekannten Umschrift-Klassen ab. Die Achse
aus [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) gilt also weiter. Die Range enthält
genau ein Release, und davon landen sieben Dateien im vendored Baum.

### Stufe (a) — beide Fassungen führen die Prozedur

```sh
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' \
  .harness/baseline/v6.8.0/regelwerk/modul-02-harness-bootstrap.md            # -> 1
git -C "$K" show v6.9.0:lab/regelwerk/modul-02-harness-bootstrap.md \
  | grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$'        # -> 1
```

Damit gilt der zweite Fall von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
Festlegung 3.

### Stufe (b) — die Prozedur ändert sich additiv und bekommt einen Delegat dazu

```sh
F=lab/regelwerk/modul-02-harness-bootstrap.md
S='/^#### Freshness-Audit/,/^#### Gate-Fragment/p'
diff <(git -C "$K" show v6.8.0:$F | sed -n "$S") <(git -C "$K" show v6.9.0:$F | sed -n "$S") \
  | grep -c '^[<>]'                                                            # -> 24
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- $F                               # -> 21  3
git -C "$K" diff --word-diff=porcelain v6.8.0..v6.9.0 -- $F | grep '^-[^-]'   # -> -Review-Report)
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | sed -n "$S" \
  | grep -oE '\]\([a-z0-9-]+\.md' | sed 's/](//' | sort -u | tr '\n' ' '; echo; done
# -> grundlagen-bootstrap.md grundlagen-harness-dateien.md modul-04-adrs.md modul-07-carveouts.md
#    grundlagen-bootstrap.md grundlagen-harness-dateien.md modul-04-adrs.md modul-06-roadmap.md modul-07-carveouts.md
git -C "$K" diff --name-only v6.8.0..v6.9.0 -- $F lab/regelwerk/grundlagen-bootstrap.md \
  lab/regelwerk/grundlagen-harness-dateien.md lab/regelwerk/modul-04-adrs.md \
  lab/regelwerk/modul-07-carveouts.md                                         # -> nur $F
G=lab/regelwerk/modul-06-roadmap.md
W='/^### Wellen-Closure-Prozedur/,/^### Regeln gegen/p'
diff <(git -C "$K" show v6.8.0:$G | sed -n "$W") <(git -C "$K" show v6.9.0:$G | sed -n "$W") | wc -l   # -> 0
git -C "$K" diff -U0 v6.8.0..v6.9.0 -- $G | grep '^@@'     # -> @@ -66 +66 @@ (§Roadmap-Struktur)
```

**Das gesamte Delta von `modul-02` liegt im Prozedur-Abschnitt, und es entfernt nichts.** Die
einzige entfernte Wortfolge `Review-Report)` wird zu `Review-Report,` und `` `MR`) ``. Der Satz
aus `v6.8.0` (*„**wiederkehrende** Templates (ADR, Slice, Welle, Carveout, Review-Report) gilt die
Append-only-Logik"*) bleibt vollständig erhalten. In `v6.9.0` fügt derselbe Punkt des
Form-Durchgangs drei Aussagen hinzu (`lab/regelwerk/modul-02-harness-bootstrap.md`,
§Freshness-Audit der vendored Baseline (Schritt 2)):

- *„Das Wort **Templates** benennt hier die Artefakt-Klasse, nicht 1:1 eine einzelne
  Vorlagen-Datei"*. Für die Welle nennt der Punkt dabei `welle-results.template.md`.
- *„`MR`-Einträge (…) gehören ebenfalls dazu"*; gemeint ist `MR-NNN-titel.template.md`.
- *„**Sensor-Gate-Dateien (…) dagegen nicht**"*; gemeint ist `gate.template.md`.

Die vier bisherigen Delegate bleiben unverändert. Neu ist ein Verweis auf `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, über den Archiv-Stub. Dieser Abschnitt ist über beide Tags byte-gleich;
das Delta von `modul-06` liegt außerhalb von ihm. **Damit ist der zweite Re-Evaluierungs-Trigger
von [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) eingetreten:** *„dann steht wieder
ein inhaltlicher Grund zur Verfügung, und die Abwägung ist gegen ihn zu führen statt gegen die
Klammer allein."*

### Der Unterschied trifft Fragen, die dieses Repo als offen führt

```sh
sed -n '/^## 6\./,$p' harness/migration.md \
  | grep -oE '(welle-results|observation|gate|MR-NNN-titel)\.template\.md` — [0-9]+' | sed 's/` — .*//'
# -> welle-results.template.md  observation.template.md  gate.template.md  MR-NNN-titel.template.md
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | sed -n "$S" \
  | grep -oE '(welle-results|observation|gate|MR-NNN-titel)\.template\.md' | sort -u | wc -l; done
# -> 0
#    3      (gate, MR-NNN-titel, welle-results; observation fehlt)
```

Für vier Vorlagen lässt [`harness/migration.md`](../../../harness/migration.md#6-offene-fragen) §6
offen, ob sie append-only sind. Der Prozedur-Abschnitt von `v6.8.0` nennt keine davon, der von
`v6.9.0` nennt drei. Gemessen ist damit nur eines: Die Wahl der Fassung entscheidet, ob der
Form-Durchgang zu diesen drei Vorlagen eine Klassen-Aussage vorfindet. Welche Zuordnung daraus
folgt, entscheidet der Durchgang. Die Frage zu `MR-NNN-titel` nennt in §6 zusätzlich
[`MR-039`](../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines).

### Außerhalb der Prozedur: Auto-Kontext und Vorlagen

```sh
git -C "$K" diff --name-only v6.8.0..v6.9.0 -- lab/regelwerk | sed 's|lab/regelwerk/||' \
  | while read -r f; do readlink .claude/rules/*.md | grep '\.harness/baseline/' \
      | grep -q "/$f$" && echo "$f"; done               # -> modul-05-planning-harness.md modul-06-roadmap.md
readlink .claude/rules/*.md | grep -c '\.harness/baseline/'                         # -> 7
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- lab/regelwerk/modul-05-planning-harness.md   # -> 96  5
git -C "$K" show v6.9.0:lab/regelwerk/modul-05-planning-harness.md \
  | grep -c '^#### Ein Slice, dessen Gegenstand ein anderer übernimmt$'              # -> 1
git -C "$K" diff --name-only v6.8.0..v6.9.0 -- lab/templates | sed 's|lab/templates/docs/plan/planning/||' | tr '\n' ' '
# -> README.template.md roadmap.template.md slice.template.md
find .harness/baseline/v6.8.0/templates -name '*.template.md' | wc -l               # -> 25
grep -cE '^\| `\.harness/baseline/v6\.8\.0/templates/docs/plan/planning/(README|roadmap)\.template\.md` \|.*\| eine Instanz \|$' \
  harness/migration.md                                                              # -> 2
```

Von den vier geänderten Regelwerks-Dateien (`README.md` ändert nur seine Stand-Zeile) stehen
zwei als Symlink in `.claude/rules/` und damit in **jedem** Claude-Lauf im Kontext. `modul-05`
bringt den neuen Abschnitt *Ein Slice, dessen Gegenstand ein anderer übernimmt* samt den Kanten
`open → done` und `next → done`. `modul-06` nimmt diesen Fall ins Drift-Log auf. Die sieben
Symlink-Ziele enthalten den Tag im Pfad, und der Baum-Tausch hängt sie um. Ob der neue Inhalt den
Auswahl-Maßstab von [`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)/[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff) berührt, beantwortet diese Entscheidung nicht.

Anders als bei [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) gibt es diesmal ein
**Vorlagen-Delta**. Zwei der drei Vorlagen sind einmalig und haben je eine Instanz im Register
(§4). `slice.template.md` ist wiederkehrend, und beide Fassungen führen die Klasse *Slice*. Die
Einordnung dieser drei Vorlagen hängt also nicht von der Wahl ab.

### Delta-Basis und Meta-Frage

```sh
grep -o '\*\*auf `v[0-9.]*`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md | tail -1
# -> **auf `v6.8.0`:** 2026-09-13, Delta-Nachweis in slice-sprung-auf-v680-wird-vollzogen
ls -1 .harness/baseline/                                                       # -> v6.8.0
git -C "$K" diff v6.8.0..v6.9.0 -- lab/regelwerk lab/templates | grep '^+' | grep -oE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels' \
  | sort | uniq -c                                                             # -> 2 Prozedur
```

Nach [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 ist die Delta-Basis
`v6.8.0`, und das ist zugleich der vendored Stand. Sie wird **gelesen**, nicht gesetzt. Die zwei
Treffer der Suche sind der Abschnittsname *Wellen-Closure-Prozedur* in einem Link-Text. Auch
`v6.9.0` beantwortet also nicht, welche Fassung einen Sprung regiert. **Grenze:** Das Ergebnis ist
ein Negativ über dreizehn aufgezählte Zeichenketten.

## Entscheidung

**Eine Festlegung.**

### Für den Sprung `v6.8.0` → `v6.9.0` regiert die Prozedur der Ziel-Fassung `v6.9.0`

Gemeint ist `v6.9.0`, `lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored
Baseline (Schritt 2), mit ihren Eigenschaften und Ausgängen und den fünf Abschnitten, in die sie
delegiert.

**Tragender Grund:** Die Wahl bestimmt, welche Append-only-Klausel der Form-Durchgang liest. Nur
die Ziel-Fassung liest *Templates* als Artefakt-Klasse, zählt `MR`-Einträge dazu und nimmt
Sensor-Gate-Dateien aus. Diese Aussagen stehen im Prozedur-Abschnitt selbst und treffen drei der
vier Vorlagen, die dieses Repo als offen führt. Regiert die gepinnte Fassung, bleiben diese drei
Fragen in diesem Sprung nicht nur unbeantwortet, sondern ungestellt. Dasselbe Muster beschreibt
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Dass die Wahl Folgen hat.

Zwei weitere Gründe stützen die Wahl, tragen sie aber nicht allein:

1. **Additivität.** Jede Regel der gepinnten Klausel gilt unter der Ziel-Fassung weiter. Das
   Gegenargument, die Ziel-Fassung streiche eine Pflicht, läuft damit ins Leere.
2. **Klammer.** Nach dem Vollzug tragen die fünf Pin-Stellen und der vendored Baum `v6.9.0`. In
   [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) war das der einzige Grund, hier wird er
   nicht gebraucht.

Den zweiten Grund aus [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) beansprucht diese
Entscheidung **nicht**: Die gepinnte Fassung liegt noch vendored vor.

### Was diese Festlegung nicht tut

- **Kein `Supersedes`.** [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) ist auf ihren
  Sprung beschränkt und vollzogen. [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md)
  Festlegung 2 wird gelesen.
- **Keine allgemeine Regel**: weder *„stets die Ziel-Fassung"*
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md), Option C) noch *„bei additiver Änderung
  die Ziel-Fassung"*.
- **Keine Deutung der Ausgänge und kein Urteil über einzelne Einträge**
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4). Das gilt ausdrücklich auch
  für [`MR-039`](../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines).
- **Keine Zuordnung von Register-Zeilen.** Ob `welle-results`, `gate` und `MR-NNN-titel` unter
  Buchstabe a oder b von [`harness/migration.md`](../../../harness/migration.md) §5 fallen,
  entscheidet der Durchgang. §4 bis §6 bleiben unverändert.
- **Keine Entscheidung über die Anwendung der Kanten `open → done` und `next → done`** auf Slices
  dieses Repos. Ob die Planungs-Werkzeuge und das Doku-Gate diese Kanten tragen, ist hier nicht
  gemessen.
- **Keine Inventur des Deltas, kein sha256, kein Vorgriff auf [`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)/[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff).**

### Der Acceptance-Trigger

Diese Entscheidung wird `Accepted`, **sobald eine Reviewer-Runde in frischem Kontext sie gegen
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat
und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt**. Das entspricht dem
Baseline-Regelwerk `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect
schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. **Der
Accept-Übergang nennt den Report namentlich.** Die Nachmessung durch den Kontext, der einen Befund
aufgelöst hat, zählt nicht als Beleg
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegungen 1 und 2).

**Die Runde hat drei neue Prüfgegenstände:**

1. **Trägt der inhaltliche Grund?** Der Unterschied steht diesmal im Prozedur-Text selbst und ist
   additiv. Geprüft wird in zwei Richtungen. **Zu viel** behauptet, wer daraus die Regel „additiv,
   also Ziel-Fassung" ableitet. **Zu wenig** behauptet, wer den Unterschied für wirkungslos hält,
   weil die drei Vorlagen mit Delta gleich eingeordnet bleiben.
2. **Bleibt die Trennung aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2
   scharf?** Die geänderte Klausel steuert den Form-Durchgang und sagt zugleich etwas über
   bestehende Instanzen. Bis zum Tausch soll die Klassen-Aussage der Ziel-Fassung nur den Durchgang
   steuern. Sie soll keine Konformitätsfrage über einen bestehenden `MR`-Eintrag, eine Sensor-Datei
   oder eine Ergebnis-Notiz beantworten. Die Runde prüft, ob diese Grenze hält.
3. **Ist die Übernahme-Vorgabe verbucht und nicht abgewogen?** Die Runde prüft, ob die Festlegung
   ohne sie trägt. Außerdem prüft sie die Reichweite des Wortlauts über die zwei Durchgänge dieses
   Sprungs (§Konsequenzen), insbesondere beim Ausgang **bewusst abweichend** mit einem bestehenden
   Eintrag.

Bis zur Annahme ist diese Entscheidung ein Architect-Verdikt, das der Schnitt der Folge-Slices als
Constraint liest. Eingefroren ist sie noch nicht ([`AGENTS.md`](../../../AGENTS.md) §3.4).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt beim Tausch | kein Aufwand | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt eine Begründung, und der Prozedur-Text unterscheidet sich |
| B — die gepinnte Fassung `v6.8.0` regiert | netzlos im Arbeitsbaum; ihre Klausel ist eine Teilmenge der Ziel-Klausel | Der Durchgang liest die Klausel ohne die drei Klassen-Aussagen, die offenen Fragen aus §6 bleiben ungestellt, und nach dem Tausch trägt kein Pin mehr diesen Tag |
| C — allgemeine Regel *„bei additiver Änderung regiert die Ziel-Fassung"* | spart künftige Runden | Der Aufwand liegt in der Messung, die Regel spart nur das Aufschreiben. Sie nähme außerdem die Prüfung vorweg, die [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) mit Option C verworfen hat |
| D — Ziel-Fassung für den Adaptions-Durchgang, gepinnte für den Instanz-Durchgang | Die drei Vorlagen mit Delta werden unter beiden Fassungen gleich eingeordnet | Die geänderte Klausel gehört gerade zum Form-Durchgang. Derselbe Punkt hätte in einem Sprung zwei Fassungen |
| **E — gewählt: Ziel-Fassung `v6.9.0`, ohne allgemeine Regel, ohne zweite Festlegung** | Die Wahl ruht auf einem inhaltlichen Grund im Prozedur-Text und wird von Additivität und Klammer gestützt | Der Durchgang bekommt mehr zu tun: Er hält die Klassen-Aussagen gegen Register und `MR`-Einträge. Wo sie widersprechen, setzt er nach der Übernahme-Vorgabe keine Abweichung (§Konsequenzen). Der nächste Sprung muss wieder messen |

## Konsequenzen

- **Positiv:** Der Sprung hat eine benannte Quelle, bevor das erste Konformitäts-Urteil fällt, und
  diese Quelle ist inhaltlich begründet. Die Delta-Basis ist zugleich der vendored Stand; der
  Durchgang bleibt deshalb bei sieben Dateien, `+137/−13`.
- **Negativ:** Der Durchgang ist größer als bei
  [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md). Er umfasst einen Instanz-Durchgang über
  drei Vorlagen und eine Klausel, die [`harness/migration.md`](../../../harness/migration.md) §4
  bis §6 berührt. Zwei geänderte Dateien stehen in jedem Claude-Lauf im Kontext.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Es gibt keinen Sensor** dafür, nach welcher Fassung und ab welchem Stand ein Durchgang lief.
  Diese Lücke tragen der Zeiger in §Baseline und die Review des Durchgangs.
- **Folgepflicht (Architect), in diesem Commit erledigt:** Buchung der Setzung und Zeiger in
  §Baseline von [`harness/conventions.md`](../../../harness/conventions.md), die Zeile im
  ADR-Index und die Zeile des achten Sprungs in
  [`harness/migration.md`](../../../harness/migration.md) §1. Den **Vollzug** bucht der
  ausführende Lauf nach [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2.
- **Folgepflicht (Architect), nach dieser Entscheidung:** die Reviewer-Runde und der
  Accept-Übergang.
- **Folgepflicht (Architect), im Durchgang:** die **Freshness-Review des Adaptions-Blocks** nach
  der gewählten Prozedur. Sie hält die geänderten Regelwerks-Dateien gegen die aktiven Einträge
  unter [`harness/conventions/`](../../../harness/conventions/)
  (`ls harness/conventions/*.md | wc -l` → **56**) und die Klassen-Aussagen gegen
  [`harness/migration.md`](../../../harness/migration.md) §4 bis §6. **Diese Entscheidung nimmt kein
  Ergebnis vorweg.**
- **Folgepflicht (Planner), vor dem Vollzug:** zwei Gegenstände. Erstens der **Baum-Tausch**: fünf
  Pins auf `v6.9.0`, sha256 am Asset gemessen, die sieben tag-tragenden Symlinks umgehängt.
  Zweitens der **Instanz-Durchgang** über die drei Vorlagen, in der Report-Form von
  [`harness/migration.md`](../../../harness/migration.md) §5. Ob beides ein Slice wird, schneidet
  der Planner ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)).
- **Vorgabe des Auftraggebers für diesen Sprung — hier verbucht, nicht abgewogen:** *„Der
  Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung wird nicht gesetzt."*
  (Auftraggeber, 2026-09-16). Sie gilt für `v6.8.0` → `v6.9.0` wie für die zwei Sprünge davor.
  [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen verbucht sie wörtlich als *„Der Adaptions-Durchgang übernimmt die
  Ziel-Fassung **vollständig**; eine Abweichung wird nicht gesetzt."*, und [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md)
  §Konsequenzen übernimmt diese Form. **Die Festlegung stützt sich nicht auf sie:** Die Vorgabe
  bindet das Ergebnis des Durchgangs, nicht die Quelle seiner Prozedur, und die Wahl der
  regierenden Fassung trägt ohne sie. **Reichweite:** Im Adaptions-Durchgang trifft sie den
  Ausgang *widerspricht*, wie [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) benennt. Im Instanz-Durchgang schließt ihr
  zweiter Halbsatz den Ausgang **bewusst abweichend** aus, soweit er eine Abweichung neu setzte
  ([`harness/migration.md`](../../../harness/migration.md) §5). Ob sie dort auch einen Ausgang
  ausschließt, der sich auf einen bestehenden Eintrag stützt, sagt ihr Wortlaut nicht. **Eine
  allgemeine Regel darüber, wer diese Wahl trifft, entsteht nicht.**
- **Diese ADR ändert keine weiteren Dateien** als sich selbst, den ADR-Index, §Baseline von
  `harness/conventions.md` und `harness/migration.md` §1.

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine.** `make baseline-verify` belegt nur, welcher Tag vendored ist, `make docs-check`
nur die Auflösbarkeit. `make regelwerk-check` und `make baseline-freshness` sagen jeweils etwas über
**einen** Tag (Netz, nicht in `make gates`). Ob ein Durchgang der gewählten Prozedur *gefolgt* ist,
bleibt ein Urteil über einen Vorgang.

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an** *(feedforward)*: Diese Festlegung gilt **nur** für `v6.8.0` →
  `v6.9.0`. Der nächste Sprung misst neu.
- **Der Zielstand bewegt sich vor dem Vollzug** *(sichtbar in §Baseline)*: Dann verliert diese
  Festlegung ihr Objekt. [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) zeigt, wie eine
  Teil-Ablösung zu schneiden ist.
- **Runde oder Durchgang stellen fest, dass die geänderte Klausel nur den Ist-Maßstab trifft**
  *(sichtbar am Report)*: Dann fällt der tragende Grund. Die Entscheidung ist in diesem Fall neu zu
  führen, nicht nachzubessern.
- **Eine künftige Baseline beantwortet die Meta-Frage selbst** *(Textänderung upstream)*: Dann ist
  diese Festlegung gegen den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-16 | **Proposed** | Zielstand-Setzung des Auftraggebers auf `v6.9.0` vom selben Tag; zweiter Fall aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0056` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

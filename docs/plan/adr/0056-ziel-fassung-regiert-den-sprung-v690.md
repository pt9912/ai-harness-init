# ADR-0056: Die Ziel-Fassung regiert auch den Sprung `v6.8.0` → `v6.9.0` — die Prozedur ändert sich additiv, führt den Durchgang dieses Sprungs aber nicht anders; tragend ist deshalb die Tag-Klammer, und das Vorlagen-Delta gibt dem Instanz-Durchgang einen Gegenstand

**Status:** Accepted

**Datum:** 2026-09-16

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (sie liefert das Kriterium in Festlegung 3,
die Trennung von Prozedur und Ist-Maßstab in Festlegung 2 und die Grenzen in Festlegung 4; ihr
§*Wer den Zielstand bewegt* behält die Setzung dem Auftraggeber vor),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) (der vorige Sprung. Ihr erster und zweiter
Re-Evaluierungs-Trigger sind eingetreten. Ihr tragender Grund, die Tag-Klammer, trägt hier wieder,
und ihre §Konsequenzen verbuchen die Übernahme-Vorgabe in der Form, die hier wiederkehrt),
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) (zuletzt ein inhaltlicher Grund, dort in
einem Delegat; ihre §Konsequenzen benennen, welchen Ausgang die Übernahme-Vorgabe trifft),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2, die Leseregel für die
Delta-Basis, wird gelesen, nicht ersetzt),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**; Festlegung 2
bestimmt den Ort der Buchung. Dass eine nicht angenommene Entscheidung so zitiert wird, führt
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
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Tag-Klammer, hier der
tragende Grund),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs.

**Kopplung:** §Baseline von [`harness/conventions.md`](../../../harness/conventions.md) verbucht
die Setzung auf `v6.9.0` und zeigt hierher. [`harness/migration.md`](../../../harness/migration.md)
projiziert diese Entscheidung an drei Stellen: in §1 (die Sprung-Zeile), in §5 a (die Einschränkung
aus der Übernahme-Vorgabe) und dort, wo die Datei ihre Sprung-ADRs aufzählt oder zählt (Zweck, §4,
§5, §6). Beide Dateien gehören dem Architect ([`AGENTS.md`](../../../AGENTS.md) §3.8,
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt vor jedem Sprung eine
Messung: Führt die **gepinnte** Fassung die Migrations-Prozedur? Führen beide sie, ist die Wahl
offen und im Sprung zu begründen. Der Auftraggeber hat den Zielstand am 2026-09-16 auf `v6.9.0`
gesetzt. Diese Entscheidung geht von dieser Setzung aus.

In den Kommandos steht `K` für einen Klon des Kurs-Repos (eine Host-Voraussetzung) und `T` für
einen Wegwerf-Baum außerhalb des Repos. Vergleicht ein Kommando zwei Tags, ist seine Zahl fest.
Zählt es im Arbeitsbaum, ist die Zahl **kein Erwartungswert**
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

Der vendored Baum unterscheidet sich vom Release-Asset nur in den zwei bekannten
Umschrift-Klassen. Die Achse aus [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) gilt also
weiter. Zwischen den Tags liegt genau ein Release, und sieben seiner geänderten Dateien liegen im
vendored Baum.

### Stufe (a) — beide Fassungen führen die Prozedur

```sh
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' \
  .harness/baseline/v6.8.0/regelwerk/modul-02-harness-bootstrap.md            # -> 1
git -C "$K" show v6.9.0:lab/regelwerk/modul-02-harness-bootstrap.md \
  | grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$'        # -> 1
```

Damit liegt der zweite Fall von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3
vor.

### Stufe (b) — die Prozedur ändert sich additiv und delegiert in einen Abschnitt mehr

```sh
F=lab/regelwerk/modul-02-harness-bootstrap.md
S='/^#### Freshness-Audit/,/^#### Gate-Fragment/p'
diff <(git -C "$K" show v6.8.0:$F | sed -n "$S") <(git -C "$K" show v6.9.0:$F | sed -n "$S") \
  | grep -c '^[<>]'                                                            # -> 24
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- $F                               # -> 21  3
git -C "$K" diff -U0 v6.8.0..v6.9.0 -- $F | grep '^@@'                        # -> @@ -282,3 +282,21 @@ …
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

**Das ganze Delta von `modul-02` ist ein einziger Hunk im Prozedur-Abschnitt, und er entfernt
nichts.** Er liegt im Punkt *„Der Review vergleicht auch die Form"*. Die einzige entfernte
Wortfolge `Review-Report)` wird zu `Review-Report,` und `` `MR`) ``. Der Satz aus `v6.8.0`
(*„**wiederkehrende** Templates (ADR, Slice, Welle, Carveout, Review-Report) gilt die
Append-only-Logik"*) bleibt vollständig erhalten. Neu kommen in `v6.9.0` drei Klassen-Aussagen
hinzu (`lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2)):

- *„Das Wort **Templates** benennt hier die Artefakt-Klasse, nicht 1:1 eine einzelne
  Vorlagen-Datei"*. Für die Welle nennt der Punkt dabei `welle-results.template.md`.
- *„`MR`-Einträge (…) gehören ebenfalls dazu"*; gemeint ist `MR-NNN-titel.template.md`.
- *„**Sensor-Gate-Dateien (…) dagegen nicht**"*; gemeint ist `gate.template.md`.

Die vier bisherigen Delegate bleiben unverändert. Neu verweist der Punkt über den Archiv-Stub auf
`modul-06-roadmap.md` §Wellen-Closure-Prozedur. Dieser Abschnitt ist über beide Tags byte-gleich;
das Delta von `modul-06` liegt außerhalb von ihm. **Damit ist der zweite Re-Evaluierungs-Trigger
von [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) eingetreten:** *„dann steht wieder
ein inhaltlicher Grund zur Verfügung, und die Abwägung ist gegen ihn zu führen statt gegen die
Klammer allein."*

### Der Unterschied nennt offene Vorlagen — der Durchgang behandelt sie unter beiden Fassungen gleich

```sh
sed -n '/^## 6\./,$p' harness/migration.md \
  | grep -oE '(welle-results|observation|gate|MR-NNN-titel)\.template\.md` — [0-9]+' | sed 's/` — .*//'
# -> welle-results.template.md  observation.template.md  gate.template.md  MR-NNN-titel.template.md
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | sed -n "$S" \
  | grep -oE '(welle-results|observation|gate|MR-NNN-titel)\.template\.md' | sort -u | wc -l; done
# -> 0
#    3      (gate, MR-NNN-titel, welle-results; observation fehlt)
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | grep -n 'Regelt die neue Fassung das' | cut -d: -f1; done   # -> 221 / 221
P='/Eine Stichprobe gegen den Bestand/,/^#### Gate-Fragment/p'
diff <(git -C "$K" show v6.8.0:$F | sed -n "$P") <(git -C "$K" show v6.9.0:$F | sed -n "$P") | wc -l   # -> 0
git -C "$K" diff --name-only v6.8.0..v6.9.0 -- lab/templates \
  | grep -cE '(welle-results|gate|MR-NNN-titel)\.template\.md'                # -> 0
```

Bei vier Vorlagen lässt [`harness/migration.md`](../../../harness/migration.md#6-offene-fragen) §6
offen, ob sie append-only sind. Die Prozedur in `v6.8.0` nennt keine davon, die in `v6.9.0` drei.
**Der Durchgang dieses Sprungs behandelt diese drei trotzdem unter beiden Fassungen gleich.** Die
neue Klausel ändert in keinem der drei Durchgänge der Prozedur etwas ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 1):

- **Im Adaptions-Durchgang.** Seine Frage *„Regelt die neue Fassung das, wofür diese Adaption
  angelegt wurde?"* steht in beiden Tags auf derselben Zeile, außerhalb des einzigen Hunks. Unter
  beiden Fassungen prüft sie dasselbe Delta, und die neue Klausel gehört selbst zu diesem Delta.
  Ob die Klausel einen `MR`-Eintrag trifft, fragt der Durchgang deshalb unter jeder Fassung. Das
  gilt auch für
  [`MR-039`](../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
  den §6 bei der Frage zu `MR-NNN-titel` nennt.
- **Im Form-Durchgang.** Er arbeitet auf dem Diff der zwei vendored Vorlagen-Bäume (beide Tags,
  Punkt *„Der Review vergleicht auch die Form"*). `gate`, `MR-NNN-titel` und `welle-results`
  haben kein Delta. Die drei Vorlagen, die eines haben, ordnen beide Fassungen gleich ein
  (§Außerhalb der Prozedur).
- **In der Stichprobe.** Ihr Text ist in beiden Tags wortgleich, und sie zieht nur Abschnitte ohne
  Delta, also nicht den geänderten Prozedur-Abschnitt. Hängt ihre Antwort an einer
  Klassen-Aussage, ist das eine Konformitätsfrage über bestehende Instanzen.

Die Klassen-Aussagen wirken deshalb nur auf Register-Zeilen und bestehende Instanzen von Vorlagen **ohne** Delta. Das
ist **Ist-Maßstab**: Es wird mit dem Tausch fällig, gleich welche Fassung die Prozedur stellt, und
bis dahin gilt `v6.8.0` ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2).

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

Neben `modul-02` ändern sich `README.md` (nur die Stand-Zeile), `modul-05` und `modul-06` (`git -C "$K" diff --numstat v6.8.0..v6.9.0 -- lab/regelwerk`).
`modul-05` und `modul-06` sind als Symlink in `.claude/rules/` eingebunden und stehen damit in
**jedem** Claude-Lauf im Kontext. `modul-05` bringt den neuen Abschnitt *Ein Slice, dessen
Gegenstand ein anderer übernimmt* samt den Kanten `open → done` und `next → done`. `modul-06` nimmt
diesen Fall ins Drift-Log auf. Die Symlink-Ziele tragen den Tag im Pfad, und der Baum-Tausch hängt
sie um. Ob der neue Inhalt den Auswahl-Maßstab von
[`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)/[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
berührt, beantwortet diese Entscheidung nicht.

Anders als bei [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) gibt es ein
**Vorlagen-Delta**. Die Vorlagen für die Planungs-README und die Roadmap sind einmalig und haben im
Register (§4) je eine Instanz. `slice.template.md` ist wiederkehrend, und beide Fassungen führen die
Klasse *Slice*. Ihre Einordnung hängt also nicht von der Wahl der Fassung ab.

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
`v6.8.0`. Das ist zugleich der vendored Stand. Die Basis wird also **gelesen**, nicht gesetzt. Beide
Suchtreffer sind der Abschnittsname *Wellen-Closure-Prozedur* in einem Link-Text. Auch `v6.9.0`
beantwortet damit nicht, welche Fassung einen Sprung regiert. **Grenze:** Das ist ein Negativ über
dreizehn aufgezählte Zeichenketten.

## Entscheidung

**Eine Festlegung.**

### Für den Sprung `v6.8.0` → `v6.9.0` regiert die Prozedur der Ziel-Fassung `v6.9.0`

Gemeint ist `v6.9.0`, `lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored
Baseline (Schritt 2), samt ihren Eigenschaften, Ausgängen und den Abschnitten, in die sie delegiert
(§Stufe (b)).

**Tragend ist die Tag-Klammer.** Sie trägt erst, nachdem der inhaltliche Unterschied gegen sie
abgewogen ist. Das stützt sich auf zwei gemessene Gründe:

1. **Die Wahl führt den Durchgang dieses Sprungs inhaltlich nicht anders.** Der Prozedur-Text
   ändert sich nur additiv (§Stufe (b)). In allen drei Durchgängen der Prozedur stellt der
   Durchgang unter beiden Fassungen dieselben Fragen an dieselben Gegenstände
   (§Der Unterschied nennt offene Vorlagen). Dieser Grund trägt die Wahl nicht allein, nimmt ihr
   aber jedes inhaltliche Gegenargument. Damit ist die Abwägung geführt, die der zweite
   Re-Evaluierungs-Trigger von [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) verlangt.
2. **Was der Inhalt offenlässt, entscheidet die Klammer.** Nach dem Vollzug tragen die Pin-Stellen
   den Tag `v6.9.0`, ebenso der vendored Baum. Die Pin-Stellen zählt
   [`harness/conventions.md`](../../../harness/conventions.md) §Adoptierte Konventions-Quellen mit
   ihren Kommandos auf. Eine Entscheidung, die `v6.8.0` nennt, zeigte danach auf einen Text, den
   kein Pin mehr trägt. Buchung und regierende Entscheidung stünden dann auf verschiedenen Tags,
   obwohl
   [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) Reproduzierbarkeit an den
   Tag bindet. [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) stützte sich allein auf
   diesen Grund, und hier trägt er aus demselben Grund allein.

**Die Klassen-Aussagen der Ziel-Fassung begründen die Wahl nicht.** Ihre Folgen für die
Register-Zeilen und bestehenden Instanzen gehören zum Ist-Maßstab und werden mit dem Tausch fällig,
gleich welche Fassung die Prozedur stellt. Auch den zweiten Grund aus
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) nimmt diese Entscheidung nicht in
Anspruch, denn die gepinnte Fassung liegt noch vendored vor.

### Was diese Festlegung nicht tut

- **Kein `Supersedes`.** [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) gilt nur für
  ihren Sprung und ist vollzogen. [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md)
  Festlegung 2 wird gelesen.
- **Keine allgemeine Regel.** Weder gilt *„stets die Ziel-Fassung"*
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md), Option C) noch *„bei additiver oder im
  Durchgang wirkungsloser Änderung die Ziel-Fassung"*.
- **Keine Deutung der Ausgänge und kein Urteil über einzelne Einträge**
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4). Das gilt ausdrücklich auch
  für [`MR-039`](../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines).
- **Keine Zuordnung von Register-Zeilen.** Ob `welle-results`, `gate` und `MR-NNN-titel` unter
  Buchstabe a oder b von [`harness/migration.md`](../../../harness/migration.md) §5 fallen, bleibt
  offen, bis die Folgepflicht beim Tausch sie klärt. Die Zuordnungen in §4 bis §6 bleiben
  unverändert.
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
und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt**. Das verlangt das
Baseline-Regelwerk `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect
schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. **Der Accept-Übergang
nennt den Report namentlich.** Hat eine Runde einen blockierenden Befund gemeldet, ist der Beleg
die nächste Runde derselben Rolle. Die Nachmessung durch den auflösenden Kontext zählt nicht
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegungen 1 und 2).

**Die Runde prüft drei Gegenstände:**

1. **Hält die Messung, dass der Unterschied den Durchgang nicht anders führt, und trägt die
   Klammer damit allein?** Die Runde prüft, ob der Durchgang unter beiden Fassungen dieselben
   Fragen an dieselben Gegenstände stellt: die Adaptions-Frage wortgleich, der Form-Durchgang über
   dieselben Vorlagen mit Delta bei gleicher Einordnung, die Stichprobe wortgleich und ohne den
   geänderten Abschnitt, die neu genannten Vorlagen ohne Delta.
   **Zu viel** behauptet, wer daraus eine Regel für wirkungslose Änderungen liest. **Zu wenig**
   behauptet, wer die Wahl für beliebig hält, weil der Durchgang gleich läuft.
2. **Bleibt die Trennung aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2
   scharf?** Die Festlegung ordnet die Folgen der Klassen-Aussagen für Register-Zeilen und bestehende Instanzen dem
   Ist-Maßstab zu, fällig mit dem Tausch. Die Runde prüft, ob diese Zuordnung hält. Außerdem prüft
   sie, dass keine Stelle der ADR die Klassen-Aussage schon vor dem Tausch als Maßstab für einen
   bestehenden `MR`-Eintrag, eine Sensor-Datei oder eine Ergebnis-Notiz verwendet.
3. **Ist die Übernahme-Vorgabe verbucht und nicht abgewogen?** Die Runde prüft, ob die Festlegung
   ohne sie trägt.

Bis zur Annahme ist diese Entscheidung ein Architect-Verdikt. Der Schnitt der Folge-Slices liest
sie als Constraint, eingefroren ist sie aber noch nicht ([`AGENTS.md`](../../../AGENTS.md) §3.4).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt beim Tausch | kein Aufwand | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt eine Begründung. Beim Vollzug nennte keine Quelle die regierende Fassung, obwohl die Pins den Ziel-Tag tragen |
| B — die gepinnte Fassung `v6.8.0` regiert | liegt netzlos im Arbeitsbaum; ihre Klausel ist eine Teilmenge der Ziel-Klausel, und der Durchgang liefe unter ihr nachweislich gleich | Nach dem Tausch trägt kein Pin mehr diesen Tag, und die Buchung in §Baseline zeigte auf einen anderen Tag als die regierende Entscheidung. Der Vorteil *netzlos lesbar* gilt nur bis zum Tausch |
| C — allgemeine Regel *„bei additiver oder im Durchgang wirkungsloser Änderung regiert die Ziel-Fassung"* | spart künftige Runden | Der Aufwand steckt in der Messung, die Regel spart nur das Aufschreiben. Sie nähme außerdem die Prüfung vorweg, die [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) mit Option C verworfen hat |
| D — Ziel-Fassung für den Adaptions-Durchgang, gepinnte für den Instanz-Durchgang | Der Instanz-Durchgang läuft unter beiden Fassungen gleich | Die Aufteilung bringt nichts und spaltet die Klammer: Ein Sprung hätte zwei regierende Tags |
| **E — gewählt: Ziel-Fassung `v6.9.0`, ohne allgemeine Regel, ohne zweite Festlegung** | Die Klammer trägt, nachdem der inhaltliche Unterschied gemessen und gegen sie abgewogen ist; Pins und regierende Entscheidung stehen auf demselben Tag | Der tragende Grund betrifft die Adresse und sagt nicht, welcher Text besser ist. Der Durchgang umfasst mehr als bei [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md). Widerspricht eine neue Regel einem Eintrag, setzt er nach der Übernahme-Vorgabe keine Abweichung (§Konsequenzen). Der nächste Sprung muss wieder messen |

## Konsequenzen

- **Positiv:** Der Sprung hat eine benannte Quelle, bevor das erste Konformitäts-Urteil fällt.
  Die Pins und die regierende Entscheidung nennen denselben Tag. Die Delta-Basis ist zugleich der
  vendored Stand, deshalb ist der Durchgang nicht größer als der Sprung selbst (§Achse und Range).
- **Positiv:** Für den Durchgang kostet die Zwei-Fassungen-Phase inhaltlich nichts. Solange der Baum
  `v6.8.0` trägt, stellt die gewählte Prozedur in allen drei Durchgängen dieselben Fragen wie die gepinnte.
- **Negativ:** Der tragende Grund betrifft die Adresse, nicht den Inhalt. Führt die geänderte
  Klausel den Durchgang doch anders, stünde ein inhaltlicher Grund zur Verfügung, den diese
  Entscheidung nicht geführt hat (§Re-Evaluierungs-Trigger).
- **Negativ:** Der Durchgang ist größer als bei
  [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md), weil ein Instanz-Durchgang über die
  Vorlagen mit Delta hinzukommt. Außerdem stehen geänderte Regelwerks-Dateien in jedem Claude-Lauf
  im Kontext (§Außerhalb der Prozedur).
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor** zeigt, nach welcher Fassung und ab welchem Stand ein Durchgang lief. Diese Lücke
  überbrücken der Zeiger in §Baseline und die Review des Durchgangs.
- **Folgepflicht (Architect), erledigt:**
  - In §Baseline von [`harness/conventions.md`](../../../harness/conventions.md) sind die Setzung
    und der Zeiger gebucht, im ADR-Index die Zeile dieser Datei.
  - [`harness/migration.md`](../../../harness/migration.md) trägt die Zeile des achten Sprungs in
    §1, die Einschränkung aus der Übernahme-Vorgabe in §5 a und diese Entscheidung an den Stellen,
    die Sprung-ADRs aufzählen oder zählen.
  - Den **Vollzug** bucht der ausführende Lauf nach
    [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2.
- **Folgepflicht (Architect), nach dieser Entscheidung:** die Reviewer-Runde, die der
  Acceptance-Trigger verlangt, und danach der Accept-Übergang.
- **Folgepflicht (Architect), im Durchgang:** die **Freshness-Review des Adaptions-Blocks** nach
  der gewählten Prozedur. Sie prüft die geänderten Regelwerks-Dateien gegen die aktiven Einträge
  unter [`harness/conventions/`](../../../harness/conventions/)
  (`ls harness/conventions/*.md | wc -l` → **56**). **Diese Entscheidung nimmt kein Ergebnis
  vorweg.**
- **Folgepflicht (Architect), mit dem Tausch:** die Register-Zeilen in
  [`harness/migration.md`](../../../harness/migration.md) §4 bis §6 gegen die Klassen-Aussagen von
  `v6.9.0` prüfen. Vor dem Tausch beantwortet diese Prüfung keine Konformitätsfrage
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2).
- **Folgepflicht (Planner), vor dem Vollzug:** zwei Gegenstände.
  - Der **Baum-Tausch**: die Pins aus §Adoptierte Konventions-Quellen auf `v6.9.0` setzen, den
    sha256 am Asset messen und die tag-tragenden Symlinks umhängen
    (`readlink .claude/rules/*.md | grep -c '\.harness/baseline/'`).
  - Der **Instanz-Durchgang** über die Vorlagen mit Delta, in der Report-Form von
    [`harness/migration.md`](../../../harness/migration.md) §5.

  Ob daraus ein Slice wird oder zwei, entscheidet der Planner
  ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)).
- **Vorgabe des Auftraggebers für diesen Sprung — hier verbucht, nicht abgewogen:** *„Der
  Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung wird nicht gesetzt."*
  (Auftraggeber, 2026-09-16). Sie gilt für `v6.8.0` → `v6.9.0` so wie für die zwei Sprünge davor.
  [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen verbucht sie wörtlich als
  *„Der Adaptions-Durchgang übernimmt die Ziel-Fassung **vollständig**; eine Abweichung wird nicht
  gesetzt."*, und [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) §Konsequenzen übernimmt
  diese Form.
  - **Die Festlegung stützt sich nicht auf die Vorgabe.** Die Vorgabe bindet das Ergebnis des
    Durchgangs, nicht die Quelle seiner Prozedur, und die Wahl der regierenden Fassung trägt auch
    ohne sie.
  - **Reichweite:** *Vollständig* gilt ohne Ausnahme. Im Adaptions-Durchgang trifft die Vorgabe
    den Ausgang *widerspricht*, und
    [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) wendet sie dort so an: Der bestehende
    Eintrag tritt zurück, und die neue Fassung wird übernommen. In derselben Lesart schließt sie im
    Instanz-Durchgang den Ausgang **bewusst abweichend** aus
    ([`harness/migration.md`](../../../harness/migration.md) §5), auch wenn ein bestehender
    `MR`-Eintrag die Abweichung trägt (Auftraggeber, 2026-09-16). Welche Einträge das betrifft,
    klärt der Durchgang.
  - **Eine allgemeine Regel darüber, wer diese Wahl trifft, entsteht nicht.**
- **Mitgezogen sind außer dieser Datei nur** der ADR-Index, §Baseline von `harness/conventions.md`
  und die oben genannten Stellen in `harness/migration.md`. Damit ist dort keine Zuordnung des
  Instanz-Registers und keine offene Frage entschieden.

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine.** `make baseline-verify` zeigt nur, welcher Tag vendored ist, und
`make docs-check` nur, ob Verweise auflösen. `make regelwerk-check` und `make baseline-freshness`
machen jeweils eine Aussage über **einen** Tag (brauchen Netz, laufen nicht in `make gates`). Ob
ein Durchgang der gewählten Prozedur *gefolgt* ist, bleibt ein Urteil über einen Vorgang.

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an** *(feedforward)*: Diese Festlegung gilt **nur** für `v6.8.0` →
  `v6.9.0`, der nächste Sprung misst neu.
- **Der Zielstand bewegt sich vor dem Vollzug** *(sichtbar in §Baseline)*: Dann verliert diese
  Festlegung ihr Objekt. Wie eine Teil-Ablösung zu schneiden ist, zeigt
  [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md).
- **Der Durchgang tut unter der Ziel-Fassung etwas, das die gepinnte nicht vorschreibt** *(sichtbar
  am Report des Durchgangs: ein Schritt, eine Frage oder eine Einordnung, die allein der
  Prozedur-Text von `v6.9.0` verlangt)*: Dann hält Grund 1 nicht, und die Entscheidung ist neu zu
  führen, nicht nachzubessern. Kein solcher Fall ist ein Ausgang an einem `MR`-Eintrag, den die neue
  Klausel als Teil des geprüften Deltas trägt (§Der Unterschied nennt offene Vorlagen).
- **Eine künftige Baseline beantwortet die Meta-Frage selbst** *(Textänderung upstream)*: Dann ist
  diese Festlegung gegen den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-16 | **Proposed** | Zielstand-Setzung des Auftraggebers auf `v6.9.0` vom selben Tag; zweiter Fall aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 |
| 2026-09-16 | **Accepted** | **Angenommen auf Weisung des Auftraggebers vom 2026-09-16, vollzogen in der Architect-Rolle. Der Acceptance-Trigger ist eingelöst.** Die Belege nennt diese Zeile als Kennung ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1): `2026-09-16-adr-0056-konsistenz-bestaetigung` deckt den Text am Stand `98908f51`, `2026-09-16-adr-0056-konsistenz-diff-runde` deckt den Diff `98908f51..2187ae22`. Beide Runden liefen in frischem Kontext gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md), [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) und [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), und keine meldet einen blockierenden Befund. `2026-09-16-adr-0056-konsistenz` meldete einen blockierenden Befund; diese Runde ist nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 Anlass, kein Beleg. Das LOW der Diff-Runde zur Folgepflicht *mit dem Tausch* bleibt nach Entscheidung des Auftraggebers im Text; die bestehenden Instanzen trägt die DoD des Slice, der den Tausch vollzieht. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0056` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

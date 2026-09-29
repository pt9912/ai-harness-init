# ADR-0072: Die Ziel-Fassung regiert auch den Sprung `v6.9.0` → `v6.13.0` — die Prozedur ist über vier Releases byte-gleich, ein Delegate ändert sich ohne Wirkung auf den Durchgang, und der Delta-Walkthrough läuft je Release

**Status:** Accepted

**Datum:** 2026-09-29

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (sie liefert das Kriterium in Festlegung 3,
die Trennung von Prozedur und Ist-Maßstab in Festlegung 2 und die Grenzen in Festlegung 4; ihr
§*Wer den Zielstand bewegt* behält die Setzung dem Auftraggeber vor),
[ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) (der vorige Sprung; ihr erster
Re-Evaluierungs-Trigger ist der Anlass dieser Entscheidung, und ihre
§Konsequenzen verbuchen die Übernahme-Vorgabe in der Form, die hier wiederkehrt),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) (deren zweiter Re-Evaluierungs-Trigger —
eine geänderte Prozedur oder ein geänderter Delegat stellt einen inhaltlichen Grund zur Verfügung —
ist hier zum zweiten Mal eingetreten),
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) (deren §Konsequenzen benennen, welchen
Ausgang die Übernahme-Vorgabe trifft),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2, die Leseregel für die
Delta-Basis, wird gelesen — und ihr Zielobjekt hat sich bewegt, §Die Delta-Basis),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**; Festlegung 2
bestimmt Ort und Drei-Teil-Form der Buchung, die mit dem Vollzug entsteht),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Beleg im Accept-Übergang),
[ADR-0052](0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md) (**`Proposed`**; `K` in den
Kommandos ist ein Platzhalter für den lokalen Kurs-Klon, eine Host-Voraussetzung, kein Artefakt
dieses Repos),
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

**Kopplung:** §Baseline von
[`harness/conventions.md`](../../../harness/conventions.md) bekommt die Zielstand-Setzung auf
`v6.13.0` mit dem Vollzug gebucht — in der Drei-Teil-Form von
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2, ausgeführt vom
Lauf, der den Vollzug ausführt; der Zeiger auf diese Entscheidung als regierende Fassung des
Sprungs kommt mit derselben Buchung. Der ADR-Index bekommt die Zeile dieser Datei mit diesem
Commit. [`harness/migration.md`](../../../harness/migration.md) projiziert diese Entscheidung in
§1 (die Sprung-Zeile) und §3 (die Form, in der die Delta-Basis heute gelesen wird). Alle drei
Dateien gehören dem Architect ([`AGENTS.md`](../../../AGENTS.md) §3.8,
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt vor jedem Sprung eine
Messung: Führt die **gepinnte** Fassung die Migrations-Prozedur? Führen beide sie, ist die Wahl
offen und im Sprung zu begründen. Der erste Re-Evaluierungs-Trigger von
[ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) ordnet für diesen Fall an: *der nächste
Sprung misst neu*. Der Auftraggeber hat den Sprung `v6.9.0` → `v6.13.0` beauftragt; der
Sprung-Slice liegt als Plan vor und setzt diese Entscheidung als seine Start-Voraussetzung, ohne
ihr den Ausgang vorzuschreiben. Diese Entscheidung geht von diesem Auftrag aus.

In den Kommandos steht `K` für einen Klon des Kurs-Repos (eine Host-Voraussetzung) und `T` für
einen Wegwerf-Baum außerhalb des Repos. Vergleicht ein Kommando zwei Tags, ist seine Zahl fest.
Zählt es im Arbeitsbaum, ist die Zahl **kein Erwartungswert**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Achse und Range: vier Releases, breiteste Minor-Sprungweite bisher

```sh
K=<Klon des Kurs-Repos>; T=$(mktemp -d)
git -C "$K" archive v6.9.0 lab/regelwerk lab/templates | tar -x -C "$T" --strip-components=1
diff -rq -x SHA256SUMS .harness/baseline/v6.9.0 "$T" | wc -l                           # -> 28
diff -r  -x SHA256SUMS .harness/baseline/v6.9.0 "$T" | grep '^[<>]' \
  | grep -v 'github\.com/pt9912/ai-harness-course' | grep -vE '\.\./\.\./' | wc -l    # ->  0
git -C "$K" log --oneline v6.9.0..v6.13.0 -- lab/regelwerk lab/templates | wc -l      # -> 13
git -C "$K" diff --numstat v6.9.0..v6.13.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'               # -> 27 Dateien  +313  -80
git -C "$K" diff --name-status v6.9.0..v6.13.0 -- lab/regelwerk lab/templates \
  | grep -cE '^[AD]'                                                                  # -> 0
```

Der vendored Baum unterscheidet sich vom Release-Asset nur in den zwei bekannten
Umschrift-Klassen — die Achse der Vorgänger gilt unverändert. Die Range überspannt **vier**
Releases, und keines wird übersprungen. Keine Regelwerks- oder Vorlagen-Datei kommt neu hinzu und
keine entfällt: **das Delta ist anpassend, nicht strukturell.** Die Partition je Release:

```sh
for r in "v6.9.0 v6.10.0" "v6.10.0 v6.11.0" "v6.11.0 v6.12.0" "v6.12.0 v6.13.0"; do
  set -- $r; git -C "$K" diff --numstat $1..$2 -- lab/regelwerk lab/templates \
  | awk -v t="$2" '{a+=$1;d+=$2;n++} END{printf "%s: %d Dateien  +%d  -%d\n", t, n,a,d}'; done
# -> v6.10.0: 16 Dateien  +88  -45
#    v6.11.0: 14 Dateien  +82  -22
#    v6.12.0:  8 Dateien  +103 -17
#    v6.13.0:  3 Dateien  +45  -1
```

Den Kopf-Commits der Releases liegen die Wellen 138–142 (`v6.10.0`), 143–147 (`v6.11.0`),
148–150 (`v6.12.0`) und 151–153 (`v6.13.0`) zugrunde
(`git -C "$K" log --oneline v6.9.0..v6.13.0 -- lab/regelwerk lab/templates` liest sie). Von 26
Regelwerk-Dateien sind 19 in der Range geändert:

```sh
git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/regelwerk | wc -l                  # -> 19
ls .harness/baseline/v6.9.0/regelwerk/*.md | wc -l                                     # -> 26
git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/templates | wc -l                  # -> 8
```

### Stufe (a) — beide Fassungen führen die Prozedur

```sh
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' \
  .harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md            # -> 1
git -C "$K" show v6.13.0:lab/regelwerk/modul-02-harness-bootstrap.md \
  | grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$'        # -> 1
```

Damit liegt der zweite Fall von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
Festlegung 3 vor — zum achten Mal.

### Stufe (b) — der Prozedur-Abschnitt ist byte-gleich, ein Delegate ändert sich

```sh
F=lab/regelwerk/modul-02-harness-bootstrap.md
S='/^#### Freshness-Audit/,/^#### Gate-Fragment/p'
diff <(git -C "$K" show v6.9.0:$F | sed -n "$S") <(git -C "$K" show v6.13.0:$F | sed -n "$S") \
  | grep -c '^[<>]'                                                            # -> 0
for t in v6.9.0 v6.13.0; do git -C "$K" show $t:$F | sed -n "$S" \
  | grep -oE '\]\([a-z0-9-]+\.md' | sed 's/](//' | sort -u | tr '\n' ' '; echo; done
# -> grundlagen-bootstrap.md grundlagen-harness-dateien.md modul-04-adrs.md modul-06-roadmap.md modul-07-carveouts.md
#    grundlagen-bootstrap.md grundlagen-harness-dateien.md modul-04-adrs.md modul-06-roadmap.md modul-07-carveouts.md
git -C "$K" diff --numstat v6.9.0..v6.13.0 -- lab/regelwerk/modul-04-adrs.md   # -> 39  6
git -C "$K" diff --numstat v6.9.0..v6.13.0 -- $F                               # -> 1  1
```

**Der Prozedur-Abschnitt selbst ist über alle vier Releases byte-gleich**, und die Liste seiner
fünf Delegaten ist dieselbe. **Aber ein Delegat ändert sich:** `modul-04-adrs.md` trägt +39/−6.
Der Zuwachs ist ein eigener Abschnitt *„Nachzug ist keine Überschreibung"* — die Klarstellung,
dass Adress-Nachzug an `Accepted`-ADRs und das Nachtragen neuer Felder keine inhaltliche
Überschreibung sind — sowie die Regel, dass die Aufnahme eines bestehenden Wächters in
`make gates` keinen eigenen ADR-Beleg braucht. Die eine geänderte Zeile von `modul-02` liegt
außerhalb des Prozedur-Abschnitts: die Outline-Matrix des Lastenhefts nimmt `LH-RB-*` in die
Kennungs-Liste auf.

**Damit ist der zweite Re-Evaluierungs-Trigger von
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) eingetreten:** *„dann steht wieder ein
inhaltlicher Grund zur Verfügung, und die Abwägung ist gegen ihn zu führen statt gegen die
Klammer allein."* Die Abwägung steht in der Entscheidung; sie fällt anders aus als bei
[ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md), wo die Prozedur selbst sich änderte —
hier ändert sich nur ein Delegat, und sein Delta liegt außerhalb jeder der drei Durchgänge der
Prozedur: Der Adaptions-Durchgang fragt *„Regelt die neue Fassung das, wofür diese Adaption
angelegt wurde?"* und ordnet einen der fünf Ausgänge zu — beides steht im byte-gleichen
Prozedur-Abschnitt. Der Form-Durchgang arbeitet auf dem Vorlagen-Diff. Die Stichprobe liest
Abschnitte ohne Delta. Keine der drei Stellen liest den geänderten `modul-04`-Abschnitt; die
Klarstellung regelt den Nachzug an **ADRs**, nicht die Frage eines Durchgangs.

### Der Delta-Walkthrough: vier Releases statt einer Momentaufnahme

```sh
git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/regelwerk | sed 's|lab/regelwerk/||' \
  | while read -r f; do readlink .claude/rules/*.md | grep '\.harness/baseline/' \
      | grep -q "/$f$" && echo "$f"; done | wc -l                             # -> 6
readlink .claude/rules/*.md | grep -c '\.harness/baseline/'                   # -> 7
ls harness/conventions/*.md | wc -l                                           # -> 71
```

Sechs der 19 geänderten Regelwerk-Dateien stehen als Symlink in `.claude/rules/` — in **jedem**
Claude-Lauf im Kontext ([`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl),
[`MR-056`](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)),
dreimal so viele wie beim vorigen Sprung. Ob ihr neuer Inhalt den Auswahl-Maßstab berührt,
beantwortet die Review, nicht diese Entscheidung.

Die Freshness-Review des Adaptions-Blocks läuft über die **volle** Liste der 71 aktiven Einträge;
das ist die Prozedur, an der die gewählte Fassung nichts ändert. Neu gegen die drei Sprünge davor
ist die **Attribution**: Bei vier Releases in einer Range kann eine Momentaufnahme über die
Gesamtspanne jeden Treffer einem Release zuordnen — aber die Zuordnung ist dann eine Deutung
des kumulierten Diffs, nicht eine Lesung. Der Durchgang dieses Sprungs liest darum **je Release
in der Partition oben**, jedes Mal die Änderungen dieses Abschnitts, und erst die Lesung des
**Volltexts** der geänderten Datei am Tag `v6.13.0` entscheidet, was davon an der Stelle gilt.
Jeder Ausgang an einem Eintrag nennt, aus welchem Release sein Anlass stammt. Die Lesung ist
Teil der Prozedur (*„Der Review geht durch die Adaptions-Liste"*, Eigenschaft des
Freshness-Audits), keine zweite Prozedur; sie ordnet die Reihenfolge, in der die 19 Dateien
gelesen werden, und setzt die Release-Attribution je Ausgang — mehr nicht.

### Emittierte Ebene: der Mess-Tag zieht mit, der Inhalt bleibt

```sh
git grep -lE 'v6\.9\.0' -- internal/emit | tr '\n' ' '                        # -> baumaussage.go templates.go
grep -n 'const InventurMessTag' internal/emit/baumaussage.go                 # -> 36
```

Der erste Sprung, in dem die emittierte Ebene einen Baseline-Tag trägt:
`InventurMessTag` in `internal/emit/baumaussage.go` steht auf `v6.9.0` und ist per
`TestInventurMessTag_IstDerGefetchteStand` fail-closed an den gefetchten Stand gekoppelt. Er ist
Adresse und zieht mit dem Tausch. Die Kommentar-Stellen in `internal/emit/templates.go` nennen
den Tag in Kommando-Belegen — je Treffer wird geurteilt (Adresse gegen datierte Mess-Aussage,
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
**Diese Entscheidung ändert an der emittierten Ebene nichts außer dieser Adresse:** was ein
Zielrepo an Vorlagen und Modulen bekommt, tragen
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed);
der d-check-Pin in `d-check.mk` und `internal/emit/emit.go` bindet an eine **andere** Version
(Werkzeug, nicht Baseline) und ist hier nicht in Streit.

### Die Delta-Basis

[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 liest die Delta-Basis aus
§Baseline — aus der Zeile, die den Slice mit gefülltem Delta-Nachweis-Feld nennt:

```sh
grep -o '\*\*auf `v[0-9.]*`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md   # -> leer
git log --oneline -S 'Delta-Nachweis' -- harness/conventions.md | head -2
# -> fc340eff Rolle Architect: §Baseline von harness/conventions.md auf Zustand und Zeiger gezogen (Setzung des Auftraggebers 2026-09-18, verschärft: "Wir brauchen keine Chronik/Forensik in dieser Datei")
#    31ba5903 Rolle Architect: slice-sprung-auf-v690-wird-vollzogen -- Baseline-Buchung v6.9.0 in harness/conventions.md und harness/migration.md §3 (ADR-0056, ADR-0031, ADR-0043)
```

Die Aufzählung, die diese Zeilen trug, steht in §Baseline **nicht mehr** — der Auftraggeber hat
sie am 2026-09-18 zurückgenommen (§Baseline trägt Zustand und Zeiger, keine Chronik), und
[`harness/migration.md`](../../../harness/migration.md) §3 zitiert das Kommando mit dem alten
Ziel. **Für diesen Sprung fällt die Frage trotzdem mit dem vendorten Stand zusammen:** der letzte
Die zweite Fundstelle ist die Buchung, die das Feld zuletzt trug — die des `v6.9.0`-Sprungs; sie belegt die Lesart des nächsten Absatzes.
Durchgang lief für `v6.9.0`, und derselbe Stand ist vendored
(`ls -1 .harness/baseline/` → `v6.9.0`). Die Basis ist damit `v6.9.0`, gleichgültig, welche
Lesart die Nachfolge der zurückgenommenen Aufzählung regelt. Eine eigene Festlegung zur Basis
braucht dieser Sprung nicht; wie künftige Sprünge die Basis **zeigen**, wenn §Baseline die
Aufzählung nicht mehr trägt, ist hier nicht entschieden — die Lücke ist benannt und geht in den
Acceptance-Trigger.

### Auch `v6.13.0` beantwortet die Meta-Frage nicht

```sh
git -C "$K" diff v6.9.0..v6.13.0 -- lab/regelwerk lab/templates | grep '^+' | grep -oE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels' \
  | sort | uniq -c                                                            # -> 3 Übergang
```

Drei Treffer, alle das Wort *Übergang* in sprachüblichem Gebrauch — keine Regel, die die Frage
dieser ADR selbst beantwortet. **Grenze, unverändert die der Vorgänger:** ein Negativ über
dreizehn aufgezählte Zeichenketten — eine Regel ohne eines dieser Wörter wäre nicht gefunden
worden.

### Das Vorlagen-Delta ändert die Form dieser Entscheidung nicht — für sie

Acht Vorlagen haben Delta, unter ihnen der ADR-Kopf selbst (die `Bezug`-Zeile nimmt `LH-RB-NN`
auf) und die Vorlage des Adaptions-Blocks:

```sh
git -C "$K" diff --numstat v6.9.0..v6.13.0 \
  -- lab/templates/docs/plan/adr/NNNN-titel.template.md                        # -> 1  1
git -C "$K" ls-tree -r --name-only v6.13.0 -- lab/templates | grep -c 'template.md'   # -> 25
```

Diese Entscheidung ist gegen die **gepinnte** Form `v6.9.0` geschrieben — bis der Tausch steht,
bleibt die gepinnte Fassung für jede Konformitäts-Frage maßgeblich
([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2). Die geänderten Vorlagen
sind Gegenstand des Instanz-Durchgangs, nicht der Wahl der regierenden Fassung.

## Entscheidung

**Zwei Festlegungen.**

### Für den Sprung `v6.9.0` → `v6.13.0` regiert die Prozedur der Ziel-Fassung `v6.13.0`

Gemeint ist `v6.13.0`, `lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der
vendored Baseline (Schritt 2), samt ihren Eigenschaften, ihren fünf Ausgängen und den Abschnitten,
in die sie delegiert (§Stufe (b)).

**Tragend sind zwei gemessene Gründe, und der inhaltliche Grund ist gegen die Klammer abgewogen:**

1. **Die Wahl führt den Durchgang dieses Sprungs inhaltlich nicht anders — gemessen, trotz
   Delegat-Delta.** Der Prozedur-Abschnitt ist über vier Releases byte-gleich; sein einziges
   geändertes Delegat, `modul-04-adrs.md`, ändert sich außerhalb aller drei Durchgänge der
   Prozedur (§Stufe (b)). Der zweite Re-Evaluierungs-Trigger von
   [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) verlangt die Abwägung gegen diesen
   Inhalt, und sie fällt aus: Der Durchgang stellt unter beiden Fassungen dieselben Fragen an
   dieselben Gegenstände. Dieser Grund nimmt der Wahl jedes inhaltliche Gegenargument — tragen
   muss die Klammer.
2. **Was der Inhalt offenlässt, entscheidet die Klammer.** Nach dem Vollzug tragen die fünf
   Pin-Stellen, die sieben Symlinks in `.claude/rules/`, der vendored Baum und der emittierte
   Mess-Tag den Tag `v6.13.0`. Eine Entscheidung, die `v6.9.0` nennt, zeigte danach auf einen
   Text, den kein Pin mehr trägt und der netzlos nicht mehr im Arbeitsbaum liegt; Buchung und
   regierende Entscheidung stünden auf verschiedenen Tags, obwohl
   [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) Reproduzierbarkeit an
   den Tag bindet. Der zweite Grund aus
   [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — die gepinnte Fassung liege nicht
   mehr vendored — wird auch hier **nicht** in Anspruch genommen: sie liegt.

### Der Durchgang dieses Sprungs läuft als Delta-Walkthrough je Release

Die Freshness-Review liest die 19 geänderten Regelwerk-Dateien am Tag `v6.13.0` als Volltext,
geordnet nach der Release-Partition (§Achse und Range): `v6.10.0`, dann `v6.11.0`, dann
`v6.12.0`, dann `v6.13.0`. Jeder Ausgang an einem Eintrag des Adaptions-Blocks nennt, aus
welchem Release sein Anlass stammt. Die Grundgesamtheit bleibt die volle Liste (71 Einträge) —
die Partition ordnet die Lesung, sie verkleinert sie nicht, und sie ersetzt die Lesung des
Volltexts nicht. **Nicht** Regel ist die Umkehrung: Was ein Release ändert, ist nicht damit
gefunden, dass sein Abschnitt gelesen ist; die Frage je Eintrag stellt der byte-gleiche
Prozedur-Abschnitt, und sie richtet sich an die Einträge, nicht an die Releases.

### Was diese Festlegungen nicht tun

- **Kein `Supersedes`.** [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) gilt nur für
  ihren Sprung und ist vollzogen; [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md)
  Festlegung 2 wird gelesen, soweit sie ein Ziel hat (§Die Delta-Basis).
- **Keine allgemeine Regel** — weder *„es regiert stets die Ziel-Fassung"* noch *„bei
  byte-gleicher Prozedur regiert die Ziel-Fassung"*. Der nächste Sprung misst erneut; die
  Messung ist der Aufwand, nicht das Aufschreiben.
- **Keine Deutung der fünf Ausgänge und kein Urteil über einzelne Einträge** des
  Adaptions-Blocks. Das Schreiben der Ausgänge ist Architect-Arbeit im Durchgang; diese
  Entscheidung beauftragt ihn und nimmt kein Ergebnis vorweg.
- **Keine Inventur des Deltas, kein sha256, kein Vorgriff auf**
  [`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)[/](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)[**`MR-056`**](../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)**.**
  Welche der 27 geänderten Dateien welchen Eintrag, welches Artefakt und welchen Sensor dieses
  Repos trifft, ist Gegenstand der Review, die §Konsequenzen beauftragt.
- **Keine Aussage über die emittierte Ebene außer der Adresse** (§Emittierte Ebene).
- **Keine Entscheidung, wie künftige Sprünge die Delta-Basis zeigen.** Die zurückgenommene
  Aufzählung in §Baseline ist eine Lücke, die benannt ist (§Die Delta-Basis), nicht eine, die
  hier geschlossen wird.

### Der Acceptance-Trigger

Diese Entscheidung wird `Accepted`, **sobald eine Reviewer-Runde in frischem Kontext sie gegen
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md),
[ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md),
[ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat
und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt**. Das verlangt das
Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt;
Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. **Der Accept-Übergang nennt
den Report namentlich.** Hat eine Runde einen blockierenden Befund gemeldet, ist der Beleg die
nächste Runde derselben Rolle; die Nachmessung durch den auflösenden Kontext zählt nicht
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegungen 1 und 2).

**Die Runde prüft drei Gegenstände:**

1. **Trägt die Abwägung, die der zweite Re-Evaluierungs-Trigger von
   [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) verlangt?** Die Runde prüft die
   Aussage, dass das `modul-04`-Delta außerhalb aller drei Durchgänge liegt, in **beide**
   Richtungen: **zu viel** behauptet, wer daraus liest, ein Delegat-Delta sei künftig stets
   wirkungslos; **zu wenig** behauptet, wer die Wahl für beliebig hält, weil der Abschnitt
   byte-gleich ist.
2. **Ist der Delta-Walkthrough je Release Organisation der Lesung und keine zweite Prozedur?**
   Die Runde prüft, dass die Festlegung die Fragen, Ausgänge und Volltext-Lesung des
   Freshness-Audits unangetastet lässt und nur die Reihenfolge und die Attribution je Ausgang
   setzt.
3. **Trägt die Lesart zur Delta-Basis, und ist die Lücke richtig benannt?** Die Runde prüft,
   dass der Schluss *Basis = `v6.9.0`* für diesen Sprung aus dem Zusammenfall von letztem
   Durchgang und vendorted Stand folgt und dass die offene Frage zur Form für künftige Sprünge
   nicht als entschieden dasteht.

Bis zur Annahme ist diese Entscheidung ein Architect-Verdikt und das Übergabe-Artefakt, das der
Schnitt als Constraint liest; eingefroren ist sie nicht ([`AGENTS.md`](../../../AGENTS.md) §3.4).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt beim Tausch | kein Aufwand | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt eine Begründung. Beim Vollzug nennt keine Quelle die regierende Fassung, während sechs Träger-Klassen den Ziel-Tag tragen |
| B — die gepinnte Fassung `v6.9.0` regiert | sie liegt netzlos im Arbeitsbaum, und der Durchgang liefe unter ihr nachweislich gleich | nach dem Tausch trägt kein Pin mehr diesen Tag; die Buchung in §Baseline zeigte auf einen anderen Tag als die regierende Entscheidung. Der Vorteil *netzlos lesbar* ist auf die Zwei-Fassungen-Phase befristet |
| C — allgemeine Regel *„bei byte-gleicher Prozedur regiert die Ziel-Fassung"* | spart künftige Runden | die Messung, die *byte-gleich* feststellt, ist der Aufwand — die Regel spart nur das Aufschreiben. Sie nähme die Prüfung vorweg, die [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) mit Option C verworfen hat |
| D — Ziel-Fassung regiert, Durchgang als Momentaufnahme über die Gesamtspanne | spart die Partition-Lesung | bei vier Releases verlöre jeder Ausgang die Attribution, welchem Release sein Anlass stammt — die Lesung des kumulierten Diffs lässt eine Deutung zu, wo die Partition eine Lesung hat. Die breiteste Minor-Sprungweite bisher ist genau der Fall, in dem das trägt |
| **E — gewählt: Ziel-Fassung `v6.13.0` mit Delta-Walkthrough je Release, ohne allgemeine Regel** | die Klammer trägt, nachdem das Delegat-Delta gegen sie abgewogen ist; Pins und regierende Entscheidung stehen auf demselben Tag; die Attribution der Ausgänge bleibt lesbar | der Durchgang ist der breitste der Reihe (19 Dateien, 71 Einträge, 6 Auto-Kontext-Dateien). Der nächste Sprung erbt die Messpflicht ein neuntes Mal |

## Konsequenzen

- **Positiv:** Der Sprung hat eine benannte, zitierte Quelle, bevor das erste
  Konformitäts-Urteil fällt — und der Tag, den die Träger nach dem Vollzug tragen, ist
  derselbe, den die regierende Entscheidung nennt.
- **Positiv:** Die Zwei-Fassungen-Phase kostet inhaltlich nichts: Solange der Baum `v6.9.0`
  trägt, stellt die gewählte Prozedur dieselben Fragen wie die gepinnte — der Prozedur-Abschnitt
  ist über die ganze Range byte-gleich.
- **Negativ:** Der Durchgang ist der breiteste der Reihe. 19 von 26 Regelwerk-Dateien, 71
  aktive Einträge, sechs geänderte Dateien im Auto-Kontext — die Trefferwahrscheinlichkeit je
  Eintrag ist höher als bei jedem der drei Sprünge davor.
- **Negativ:** Der tragende Grund trägt erst nach einer Abwägung, die ein Delegat-Delta
  gegen sie führt. Fiele die Wirkungs-Messung aus §Stufe (b) anders aus, stünde die
  Entscheidung ohne inhaltliches Argument da — und müsste neu geführt werden, nicht
  nachgebessert.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang lief, keines hält die
  Release-Attribution eines Ausgangs gegen die Partition, und keines liest die Delta-Basis —
  dieselbe Lage, die
  [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) für sich feststellt. Träger sind der
  Zeiger in §Baseline, die Übergabe-Artefakte des Durchgangs und die Review des Ergebnisses.
- **Folgepflicht (Architect), erledigt:** der ADR-Index trägt die Zeile dieser Datei (dieser
  Commit).
- **Folgepflicht (Architect), mit dem Vollzug:** die Zielstand-Buchung in §Baseline in der
  Drei-Teil-Form von [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2 samt dem Zeiger auf diese Entscheidung; die Sprung-Zeile in
  [`harness/migration.md`](../../../harness/migration.md) §1; §3 derselben Datei nennt die Form,
  in der die Delta-Basis heute gelesen wird — das dort zitierte Kommando liest §Baseline in
  einer Form, die zurückgenommen ist (§Die Delta-Basis).
- **Folgepflicht (Architect), im Durchgang:** die **Freshness-Review des Adaptions-Blocks** nach
  der gewählten Prozedur als Delta-Walkthrough je Release (Festlegung 2) — 71 aktive Einträge,
  19 geänderte Dateien, Ausgänge mit Release-Attribution. **Diese Entscheidung nimmt kein
  Ergebnis vorweg.**
- **Folgepflicht (Architect), mit dem Tausch:** die Register-Zeilen in
  [`harness/migration.md`](../../../harness/migration.md) §4 bis §6 gegen die Klassen-Aussagen
  von `v6.13.0` prüfen, in der Form aus
  [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen. Vor dem Tausch
  beantwortet diese Prüfung keine Konformitäts-Frage
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2).
- **Vorgabe des Auftraggebers für den Durchgang — vom Sprung-Slice-Plan verbucht, hier
  gelesen:** *„Der Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung wird nicht
  gesetzt"* — delta-gebunden, wie [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md)
  §Konsequenzen sie für die drei Sprünge davor verbucht. Diese Entscheidung stützt sich **nicht**
  auf sie: Die Vorgabe bindet das Ergebnis des Durchgangs, nicht die Quelle seiner Prozedur.
  Eine allgemeine Regel darüber, wer diese Wahl trifft, entsteht nicht.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — dieselbe Eigenschaft der Frage wie bei allen Vorgängern.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist. Nach welcher Fassung ein Durchgang **gelaufen** ist, sieht er nicht |
| `make regelwerk-check` | hält den gepinnten Tag gegen sein Release-Asset (Netz, nicht in `make gates`) — eine Aussage über **einen** Tag |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens |
| `TestInventurMessTag_IstDerGefetchteStand` | hält den Mess-Tag gegen den gefetchten Stand — die Adresse der emittierten Ebene, nicht die Wahl der Fassung |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist und ob seine
Release-Attribution stimmt, ist ein Urteil über einen Vorgang.

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an** *(feedforward)*: Diese Festlegung gilt **nur** für
  `v6.9.0` → `v6.13.0`, der nächste Sprung misst neu — die Achse zuerst, dann beide Stufen.
- **Der Zielstand bewegt sich, bevor dieser Sprung vollzogen ist** *(beobachtbar vor dem Vollzug —
  §Baseline trägt die Setzung erst mit der Buchung: an `make baseline-freshness`, das einen
  neueren Upstream-Tag als den gepinnten meldet, und an der Weisung des Auftraggebers, die einen
  anderen Zielstand benennt; kein Gate hält die Setzung gegen diese Festlegung,
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))*: Dann
  verliert diese Festlegung ihr Objekt; wie eine Teil-Ablösung zu schneiden ist, zeigt
  [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) §Re-Evaluierungs-Trigger.
- **Der Durchgang tut unter der Ziel-Fassung etwas, das die gepinnte nicht vorschreibt** *(sichtbar
  am Report des Durchgangs)*: Dann hält Grund 1 nicht, und die Entscheidung ist neu zu führen,
  nicht nachzubessern.
- **Ein künftiger Sprung ändert die Prozedur oder einen Delegaten so, dass ein Durchgang anders
  läuft** *(beobachtbar am Diff im Prozedur-Abschnitt oder in einem der fünf Delegaten)*: Dann
  steht wieder ein inhaltlicher Grund zur Verfügung, und die Abwägung ist gegen ihn zu führen
  statt gegen die Klammer allein — dieselbe Linie, die
  [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md) für ihren Fall zieht.
- **Eine künftige Baseline beantwortet die Meta-Frage selbst** *(Textänderung upstream)*: Dann
  ist diese Festlegung gegen den neuen Wortlaut neu zu begründen oder als Abweichung zu
  deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-29 | **Proposed** | Anlass sind der erste Re-Evaluierungs-Trigger von [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) (*der nächste Sprung misst neu*) und der beauftragte Sprung `v6.9.0` → `v6.13.0`, dessen Sprung-Slice diese Entscheidung als Start-Voraussetzung liest. Die Messungen dieses Laufs: §Kontext |
| 2026-09-29 | **Accepted** | **Angenommen auf Weisung des Auftraggebers vom 2026-09-29, vollzogen in der Architect-Rolle. Der Acceptance-Trigger ist eingelöst**, und der Beleg, den er verlangt, ist die **Reviewer-Konsistenzrunde vom 2026-09-29 zu ADR-0072** — Kennung `2026-09-29-adr-0072-konsistenzrunde` ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1: Kennung, kein Pfad-Link) —, gefahren in frischem Kontext gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md), [ADR-0047](0047-ziel-fassung-regiert-den-sprung-v680.md), [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) und [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md). Ihr Verdikt lautet *nicht blockierend*, alle drei benannten Prüfgegenstände sind bestätigt. **Ihr MEDIUM/LOW/INFO sind vor diesem Umschlag behoben, solange die Datei `Proposed` war:** die Beobachtbarkeit des zweiten Re-Evaluierungs-Triggers (F-1), die Zuschreibung beim Bezug auf [ADR-0056](0056-ziel-fassung-regiert-den-sprung-v690.md) — deren zweiter Trigger ist nicht eingetreten, es trägt der erste (F-2) —, die Zählung (F-3), der abgetragene Beleg zur Delta-Basis (F-4) und die Unterbeschreibung der Festlegung 2 (F-5). [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 verlangt eine weitere Runde nur nach einem **blockierenden** Befund. **Benannte Grenze:** behoben hat alles derselbe Lauf, der die Datei schrieb — die reparierte Fassung hat keine Runde bestätigt. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0072` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

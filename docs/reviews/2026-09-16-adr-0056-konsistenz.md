# Review-Report: Konsistenzrunde zu `ADR-0056` — 2026-09-16

**Review-Art:** **Die Konsistenzrunde, die der Acceptance-Trigger von `ADR-0056` verlangt.** Geprüft
wird gegen [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[`ADR-0043`](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md),
[`ADR-0047`](../plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) und
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), dazu
[`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) an den Stellen, auf die
`ADR-0056` sich stützt. Der §Kontext wird am **Kurs-Klon** nachgemessen, nicht an seiner
Zusammenfassung. Nicht Teil dieser Runde: DoD-Review, Accept-Schritt (Architect, `ADR-0040`),
Inventur des Deltas je `MR`-Eintrag und Schnitt des Sprung-Slice.

**Gegenstand:** Range `d5277aee..897ddd93`. Sie enthält drei Commits, alle `Rolle Architect`, noch
nicht gepusht: `8ae647cc` (ADR angelegt, Index-Zeile, Zielstand-Setzung in §Baseline, Sprung-Zeile
in `harness/migration.md` §1), `45c7df25` (Übernahme-Vorgabe verbucht, `harness/migration.md` §5 a)
und `897ddd93` (Reichweite der Vorgabe verbucht). Die Range berührt 4 Dateien, `+390/−4`
(`git diff --stat d5277aee..897ddd93`). Gemessen ist am Stand `897ddd93`; `git status --porcelain`
war beim Start leer.

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ `0565f274` (2.0.0) ·
**Modell:** claude-opus-5 · **Datum:** 2026-09-16

**Kein Self-Review — als Negativ-Aussage:** Dieser Lauf hat weder an `ADR-0056` noch an ihrem
Index-Eintrag, an `harness/conventions.md` oder an `harness/migration.md` geschrieben. Die einzige
Datei, die er schreibt, ist dieser Report.

**Setzungen des Auftraggebers, nicht Gegenstand des Urteils:** die Übernahme-Vorgabe *„Der
Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung wird nicht gesetzt."* und ihre
Reichweite (auch ein bestehender `MR`-Eintrag tritt zurück), beide vom 2026-09-16, sowie die
Zielstand-Setzung auf `v6.9.0`. Geprüft wird nur, ob die ADR sie **als Verbuchung** führt.

**Eingangs-Kontext:** die vier ADRs des Triggers · `ADR-0044` §Konsequenzen ·
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 ·
[`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
Festlegungen 1–2 ·
[`ADR-0052`](../plan/adr/0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md) ·
[`ADR-0039`](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) ·
[`harness/migration.md`](../../harness/migration.md) §1, §3–§6 ·
[`AGENTS.md`](../../AGENTS.md) §3.4/§3.6/§3.7/§3.8/§3.11 ·
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 ·
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
· Kurs-Klon, Tags `v6.8.0`/`v6.9.0`, `modul-02-harness-bootstrap.md` §Freshness-Audit der vendored
Baseline (Schritt 2) im **Volltext** beider Fassungen · Form-Vorbild: der Report der Konsistenzrunde
zu `ADR-0055` vom selben Tag.

---

## Eigene Messungen

Alle Kommandos von `ADR-0056` §Kontext sind wörtlich nachgefahren. `K` ist der lokale Kurs-Klon,
`T` ein Wegwerf-Baum im Scratchpad, also außerhalb des Repos. Rechts steht, was der Lauf **selbst**
ausgegeben hat.

```sh
# (1) Achse und Range
diff -rq -x SHA256SUMS .harness/baseline/v6.8.0 "$T" | wc -l                    # 28   = ADR
#   … | grep '^[<>]' | grep -v 'github\.com/…' | grep -vE '\.\./\.\./' | wc -l   # 0    = ADR
git -C "$K" log --oneline --decorate v6.8.0..v6.9.0                             # ab8b4dc (tag: v6.9.0), ee254a0, 3658c86 = ADR
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- lab/regelwerk lab/templates | awk … # 7 Dateien  +137  -13 = ADR
# (2) Stufe (a)
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' <v6.8.0 vendored>  # 1 = ADR
git -C "$K" show v6.9.0:$F | grep -c '…'                                        # 1 = ADR
# (3) Stufe (b)
diff <(… v6.8.0 …) <(… v6.9.0 …) | grep -c '^[<>]'                               # 24 = ADR
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- $F                                  # 21 3 = ADR
git -C "$K" diff -U0 v6.8.0..v6.9.0 -- $F | grep '^@@'                           # @@ -282,3 +282,21 @@  (EIN Hunk, im Punkt „Der Review vergleicht auch die Form")
git -C "$K" diff --word-diff=porcelain … | grep '^-[^-]'                         # -Review-Report)  = ADR
# Delegate (Datei-Ebene): v6.8.0 → 4 Dateien, v6.9.0 → dieselben 4 + modul-06-roadmap.md = ADR
#   verschiedene Link-Ziele im Abschnitt v6.9.0: 7 (grundlagen-harness-dateien.md zweimal, modul-07-carveouts.md zweimal)
git -C "$K" diff --name-only … -- $F <vier Delegate>                             # nur $F = ADR
diff <(… v6.8.0 $G "$W") <(… v6.9.0 $G "$W") | wc -l                             # 0 = ADR; Spanne nicht leer (164 Zeilen in v6.9.0)
git -C "$K" diff -U0 … -- $G | grep '^@@'                                        # @@ -66 +66 @@ = ADR
git -C "$K" diff --word-diff=porcelain … -- $G                                   # +„ein Slice in einem anderen aufgegangen (…Modul 5 §Ein Slice, dessen Gegenstand …)" → Drift-Log-Aussage der ADR trägt
# die Frage des Adaptions-Durchgangs, beide Tags:
git -C "$K" show v6.8.0:$F | grep -n 'Regelt die neue Fassung das'               # 221
git -C "$K" show v6.9.0:$F | grep -n 'Regelt die neue Fassung das'               # 221   (außerhalb des einzigen Hunks → wortgleich)
# (4) Vorlagen, die §6 offen führt
sed -n '/^## 6\./,$p' harness/migration.md | grep -oE … | sed …                  # welle-results observation gate MR-NNN-titel = ADR
for t in v6.8.0 v6.9.0; do … | sort -u | wc -l; done                             # 0 / 3 = ADR
git -C "$K" show v6.9.0:$F | sed -n "$S" | grep -oE '[A-Za-z-]+\.template\.md' | sort -u
#   archiv-stub-slice archiv-stub-welle gate MR-NNN-titel slice welle-results welle
# (5) Auto-Kontext und Vorlagen-Delta
… readlink .claude/rules/*.md …                                                  # modul-05-planning-harness.md modul-06-roadmap.md = ADR
readlink .claude/rules/*.md | grep -c '\.harness/baseline/'                      # 7 = ADR
git -C "$K" diff --numstat … -- lab/regelwerk/modul-05-planning-harness.md       # 96 5 = ADR
git -C "$K" show v6.9.0:…modul-05… | grep -c '^#### Ein Slice, dessen Gegenstand ein anderer übernimmt$'   # 1 = ADR
#   Kanten: v6.9.0 führt „open --> done" und „next --> done" (Zeilen 21/22), v6.8.0 keine (0) → trägt
git -C "$K" diff --name-only … -- lab/templates | …                              # README.template.md roadmap.template.md slice.template.md = ADR
#   → gate, MR-NNN-titel, welle-results sind über beide Tags byte-gleich
find .harness/baseline/v6.8.0/templates -name '*.template.md' | wc -l            # 25 = ADR
grep -cE '…(README|roadmap)\.template\.md` \|.*\| eine Instanz \|$' harness/migration.md   # 2 = ADR
# (6) Delta-Basis und Meta-Frage
grep -o '\*\*auf `v[0-9.]*`:\*\* …' harness/conventions.md | tail -1             # **auf `v6.8.0`:** 2026-09-13, Delta-Nachweis in … = ADR
ls -1 .harness/baseline/                                                         # v6.8.0 = ADR
git -C "$K" diff … | grep '^+' | grep -oE '<13 Alternativen>' | sort | uniq -c   # 2 Prozedur = ADR; beide Treffer sind der Link-Text „§Wellen-Closure-Prozedur"
ls harness/conventions/*.md | wc -l                                              # 56 = ADR (gleich an d5277aee)
# (7) Form, Pfade, Eigentum
grep -nE '/Development|/home/|/tmp/|~/' docs/plan/adr/0056-*.md                   # kein Treffer, Exit 1
git log --format='%h %s' -- harness/migration.md | head                          # bis slice-…: Implementer; ab ADR-0047: Architect
sed -n 36,48p harness/migration.md                                              # §1-Tabelle: 8 Zeilen → „achter Sprung" trägt
```

**Ergebnis der Nachmessung: jede Zahl und jede Ausgabe in §Kontext von `ADR-0056` reproduziert.**
Ob der tragende Grund trägt, entscheidet sich deshalb nicht an den Zahlen, sondern daran, was sie
belegen (Prüfgegenstand 1).

---

## Urteil zu den drei Prüfgegenständen des Triggers

### 1. Trägt der inhaltliche Grund? — **Nicht in der behaupteten Form (H-1).**

**In der Richtung, die der Trigger „zu viel" nennt, hält die ADR.** Eine allgemeine Regel „additiv,
also Ziel-Fassung" leitet sie nicht ab. Sie schließt diese Regel ausdrücklich aus (`:233-235`,
Option C `:284`), und ihr erster Re-Evaluierungs-Trigger begrenzt die Festlegung auf diesen Sprung.

**Auch „zu wenig" liegt nicht vor.** Die ADR hält den Unterschied nicht für wirkungslos, und sie
sagt richtig, dass die drei Vorlagen **mit** Delta unter beiden Fassungen gleich eingeordnet werden
(`:178-181`).

**Zu viel behauptet die ADR aber an anderer Stelle: bei der Wirkung, die sie der Wahl in diesem
Sprung zuschreibt.** Der tragende Satz lautet: *„Regiert die gepinnte Fassung, bleiben diese drei
Fragen in diesem Sprung nicht nur unbeantwortet, sondern ungestellt."* (`:213-214`). Er hält der
Messung nicht stand, und das aus zwei Gründen.

- **Für `MR-NNN-titel` ist er widerlegt.** Die Frage des Adaptions-Durchgangs, *„Regelt die neue
  Fassung das, wofür diese Adaption angelegt wurde?"*, steht in beiden Tags auf Zeile 221. Sie liegt
  außerhalb des einzigen Hunks von `modul-02` (Messung 3) und ist damit **wortgleich**. Unter beiden
  Fassungen ist ihr Gegenstand dasselbe Delta von `v6.9.0`, und zu diesem Delta gehört die neue
  Klausel *„`MR`-Einträge … gehören ebenfalls dazu"*. Der Adaptions-Durchgang stellt die Frage also
  auch unter Option B an
  [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines).
  Genau an diesem Eintrag macht [`harness/migration.md`](../../harness/migration.md) §4 die offene
  Frage zu `MR-NNN-titel` fest (`:189-197`). Die ADR selbst nennt diese Kopplung (`:151-152`) und
  beauftragt die Prüfung der Einträge unabhängig von der Fassung (`:308-311`).
- **Für `gate` und `welle-results` nennt die ADR keinen Schritt des Durchgangs, in dem die neue
  Klassen-Aussage einen Fall entscheidet.** Beide Vorlagen sind über die zwei Tags byte-gleich
  (Messung 5). Die Klausel wirkt im Form-Durchgang auf eine **geänderte** Form: *„Neue Instanzen
  folgen der neuen Form, bestehende werden nicht rückwirkend umgeschrieben."* Den
  Instanz-Durchgang beschränkt die ADR selbst auf *„die drei Vorlagen"* mit Delta (`:293-296`,
  `:316-317`), und für diese drei ist die Wahl nach ihren eigenen Worten gleichgültig. Als einziger
  Ort bleibt die Architect-Folgepflicht, *„die Klassen-Aussagen gegen `harness/migration.md` §4 bis
  §6"* zu halten (`:311-312`). Das ist eine **Umklassifizierung bestehender Register-Zeilen** zu
  Vorlagen, deren Form sich nicht bewegt hat. Das Register leitet sie aus der Klausel ab, und nach
  dem Tausch wäre diese Folge unter jeder Prozedur-Fassung fällig. Damit liegt genau der Fall vor,
  den der dritte Re-Evaluierungs-Trigger als Wegfall des tragenden Grundes führt: *„dass die
  geänderte Klausel nur den Ist-Maßstab trifft"* (`:352-354`).

**Was daraus folgt und was nicht.** Die Messung in §*Der Unterschied trifft Fragen …* belegt, dass
die Ziel-Klausel drei offene Vorlagen **nennt** (0 → 3). Dass der Durchgang dieses Sprungs sie
unter der Ziel-Fassung **anders behandelt** als unter der gepinnten, belegt sie nicht. Die ADR sagt
das selbst halb (*„Gemessen ist damit nur eines"*, `:149`), der tragende Satz zieht aber die
weitere Folgerung. Das **Ergebnis** der Festlegung (Ziel-Fassung `v6.9.0`) bestreitet dieser Befund
nicht. Die Klammer, in `ADR-0047` der allein tragende Grund, steht weiterhin zur Verfügung. Die ADR
erklärt sie hier aber für *„nicht gebraucht"* (`:222-223`). Welche Lesart trägt, muss der Architect
entscheiden. Dieser Report gibt keine vor.

### 2. Bleibt die Trennung Prozedur ↔ Ist-Maßstab bis zum Tausch scharf? — **Ja, getragen von `ADR-0018`, nicht von `ADR-0056` (I-1).**

**Die Grenze hält.** `ADR-0018` Festlegung 2 (`Accepted`) bindet sie, und `harness/migration.md` §1
wiederholt sie wortgetreu für jeden Sprung: *„unabhängig davon, welche Fassung die Prozedur des
laufenden Sprungs stellt"*. Nichts in der Range widerspricht ihr. Der Zielstand ist als *„Vollzug
steht aus"* gebucht, der vendored Stand bleibt `v6.8.0`, und die ADR fällt über keinen bestehenden
`MR`-Eintrag und keine Sensor-Datei ein Urteil (`:236-238`).

**Zwei Stellen sind offen, aber folgenlos.** Die Grenze steht in `ADR-0056` nur als Soll im
Prüfgegenstand (`:267-271`), nicht in der Festlegung. Außerdem nennt die Folgepflicht *„Klassen-Aussagen
gegen §4 bis §6"* keinen Zeitpunkt relativ zum Tausch. Beides schadet in diesem Sprung nicht:
`gate`, `MR-NNN-titel` und `welle-results` sind über die zwei Tags byte-gleich, eine
Konformitätsaussage über ihre Instanzen fiele unter beiden Fassungen gleich aus. Mit H-1 hängt das
trotzdem zusammen. Soll die Umklassifizierung der Durchgangs-Schritt sein, der den tragenden Grund
stützt, dann muss die ADR auch sagen, dass dieser Schritt vor dem Tausch keine Konformitätsfrage
beantwortet.

### 3. Ist die Übernahme-Vorgabe verbucht statt abgewogen, und trägt die Festlegung ohne sie? — **Ja.**

- **Verbucht:** Die Vorgabe steht unter §Konsequenzen als *„hier verbucht, nicht abgewogen"*,
  zugeschrieben *„(Auftraggeber, 2026-09-16)"*. Ihre Reichweite, dass auch ein bestehender
  `MR`-Eintrag zurücktritt, ist ebenso dem Auftraggeber zugeschrieben (`:319-334`). Das Zitat aus
  `ADR-0044` ist wortgleich (`0044:705-707`). Die Paraphrase *„Der bestehende Eintrag tritt zurück,
  und die neue Fassung wird übernommen"* entspricht in der Sache `ADR-0044` (*„oder das Repo
  **übernimmt** die neue Regel … Diese Wahl ist damit … getroffen"*). Sie steht ohne
  Anführungszeichen und gibt sich damit nicht als Zitat aus.
- **Die Festlegung trägt ohne die Vorgabe:** §Entscheidung (`:200-245`) nennt die Vorgabe nicht.
  Option E zieht sie nur in der **Contra**-Spalte als Folge heran (`:286`), nicht als Pro-Grund. Die
  ADR sagt zudem ausdrücklich: *„Die Festlegung stützt sich nicht auf sie"* (`:324-326`).
- **Ohne Befund** ist auch der Satz *„Sie gilt … wie für die zwei Sprünge davor"*. Die weitere
  Reichweite im Instanz-Durchgang ist als Setzung vom 2026-09-16 kenntlich gemacht und nicht als
  Fortschreibung von `ADR-0047` ausgegeben.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| H-1 | HIGH | **Der tragende Grund stützt sich auf eine Prämisse, die für eine der drei Vorlagen widerlegt ist, und für die zwei übrigen fehlt ein Durchgangs-Schritt.** *„ungestellt"* gilt nicht für `MR-NNN-titel`: Die Frage des Adaptions-Durchgangs ist in beiden Tags wortgleich (Zeile 221, außerhalb des einzigen Hunks) und trifft unter Option B dasselbe Delta samt `MR-039`. Für `gate` und `welle-results` bewegt sich keine Form, den Instanz-Durchgang beschränkt die ADR auf die drei Delta-Vorlagen, und als Ort bleibt nur die Umklassifizierung bestehender Register-Zeilen. Diesen Fall führt der dritte Re-Evaluierungs-Trigger der ADR als Wegfall des tragenden Grundes. Nach `Accepted` wäre ein nicht haltbarer Grund eingefroren, und die ADR müsste nach ihrem eigenen Trigger *„neu … geführt"* werden. | `ADR-0018` Festlegung 3 (die offene Wahl wird *begründet* entschieden) · `ADR-0056` §Acceptance-Trigger Prüfgegenstand 1 · `ADR-0056` Re-Evaluierungs-Trigger 3 | `docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md:210-215`, `:147-152`, `:293-296`, `:308-317`, `:352-354` | ja: `git -C "$K" show <tag>:$F \| grep -n 'Regelt die neue Fassung das'` (beide 221), `git -C "$K" diff -U0 … -- $F \| grep '^@@'` (ein Hunk), `git -C "$K" diff --name-only … -- lab/templates` | `tragender Grund beruft sich auf eine Wirkung, die der Durchgang des Sprungs nicht hat` |
| M-1 | MEDIUM | **Drei Geltungs-Zusagen der ADR sind am Stand ihrer eigenen Range falsch.** *„§4 bis §6 bleiben unverändert"* (`:241`), *„Diese ADR ändert keine weiteren Dateien als … `harness/migration.md` §1"* (`:335-336`) und das Kopplungs-Feld (`:40-43`, nur §1) stehen gegen `45c7df25`/`897ddd93`: Diese Commits fügen `harness/migration.md` §5 a einen Absatz hinzu, der aus dieser ADR abgeleitet ist (`migration.md:225-231`). *„in diesem Commit erledigt"* (`:300`) passt ebenfalls nicht mehr, weil die Folgepflichten auf drei Commits verteilt sind. Ab `Accepted` wäre das eine eingefrorene Zusage mit sichtbarem Gegenbeispiel. | `AGENTS.md` §3.6 · §3.4 · `ADR-0040` Festlegung 3 (Korrektur, solange `Proposed`) | `docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md:40-43`, `:241`, `:300`, `:335-336` | ja: `git diff d5277aee..897ddd93 -- harness/migration.md \| grep '^@@'` → zweiter Hunk `@@ -218,6 +222,14 @@` in §5 a | `Geltungs-Zusage einer ADR hinkt ihren eigenen Folge-Commits nach` |
| L-1 | LOW | **Die Projektionsregel von `harness/migration.md` zählt die ADRs, auf denen seine normativen Punkte beruhen, als „sechs".** §1 (`ADR-0047`, `ADR-0056`) und jetzt §5 a (`ADR-0056`) stützen sich aber auf weitere. §5 bezeichnet sich außerdem als *„keine ADR-Aussage"* (`:201`), während §5 a nun eine ADR-verbuchte Einschränkung trägt. Für `ADR-0047` bestand die Lücke schon vorher, die Range vergrößert sie. | Maintainability · `ADR-0024` Festlegung 1 (Projektionsregel gehört zum Register) | `harness/migration.md:19`, `:107`, `:201`, `:225-231`, `:270` | ja: `grep -n 'sechs' harness/migration.md` | `Register-Selbstbeschreibung zählt ihre Originale nicht nach` |
| L-2 | LOW | **Einige Zahlwörter mit Beleg-Rolle stehen ohne ihr Kommando im selben Absatz**, oder das Kommando zählt etwas anderes. Betroffen sind *„den fünf Abschnitten, in die sie delegiert"* (`:207`; das Kommando in §Stufe (b) zählt **Dateien**, im Abschnitt stehen sieben verschiedene Link-Ziele), *„sieben Dateien, `+137/−13`"* (`:292`) sowie *„fünf Pins"* und *„sieben tag-tragenden Symlinks"* (`:314-315`). Die Kommandos stehen in §Kontext, nicht im Absatz. `ADR-0047` hat dieselbe Form. Das ist Bestand, keine Norm. | `MR-025` Setzung 1 | `docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md:207`, `:221`, `:292`, `:314-315` | ja: Messung 3 (Link-Ziele), `grep -n` auf die Zeilen | `Zahl-Beleg außerhalb des Absatzes seines Kommandos` |
| I-1 | INFO | **Die Grenze Prozedur ↔ Ist-Maßstab trägt in diesem Sprung `ADR-0018` Festlegung 2, nicht `ADR-0056`.** In der ADR steht sie nur als Soll des Prüfgegenstands. Für die Umklassifizierung der Register-Zeilen nennt die Architect-Folgepflicht keinen Zeitpunkt relativ zum Tausch. Das bleibt folgenlos, weil die drei betroffenen Vorlagen byte-gleich sind, hängt aber an der Auflösung von H-1. Zuständig: Architect. | `ADR-0018` Festlegung 2 · Prüfgegenstand 2 | `docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md:267-271`, `:308-313` | nein | `Durchgangs-Schritt ohne Zeitpunkt gegenüber dem Tausch` |
| I-2 | INFO | **Im lebenden Register steht *„Der Eintrag tritt zurück, und die neue Fassung wird übernommen"* im Präsens, ohne Zeitpunkt.** §1 derselben Datei hält den Ist-Maßstab aber bis zum Tausch bei `v6.8.0`. Dass der Eintrag erst mit dem Vollzug zurücktritt, folgt nur aus *„wird übernommen"*. Die Prozedur beider Fassungen führt Übernehmen als Rückbau durch einen neuen Eintrag. Der Absatz sagt das nicht, muss es aber auch nicht. Zuständig: Architect. | `ADR-0018` Festlegung 2 · `harness/migration.md` §1 | `harness/migration.md:225-231` | nein | `Setzung im lebenden Register ohne Wirkungszeitpunkt` |
| I-3 | INFO | **Das Eigentum an `harness/migration.md` ist nur für die berührten Abschnitte abgeleitet.** §1 und §5 a projizieren Sprung-ADRs bzw. `ADR-0056`, also Architect-Originale, und `ADR-0024` Festlegung 1 trägt dort. §4 ist dagegen eine *„Beobachtung am Bestand"* über Instanzen mehrerer Rollen, und die Datei ist in einem Implementer-Slice entstanden. Für die Datei als Ganzes lässt `ADR-0024` Festlegung 2 die Frage offen. Der Commit-Zuschnitt dieser Range ist davon nicht betroffen. | `ADR-0024` Festlegung 2 · `AGENTS.md` §3.8 | `harness/migration.md:1-19`, `:102-108` | nein | `gemischte Originale eines Registers` |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| §Kontext: Achse, Range, Stufe (a), Stufe (b), Vorlagen, Auto-Kontext, Delta-Basis, Meta-Frage | **Geprüft, ohne Befund.** Jede Zahl und jede Ausgabe ist am Kurs-Klon und im Arbeitsbaum reproduziert (§Eigene Messungen). Die `sed`-Spannen sind nicht leer, die Null aus `modul-06` §Wellen-Closure-Prozedur ist also kein stilles Grün. Auch die Aussagen zu `modul-05` (neuer Abschnitt, Kanten `open → done`/`next → done`) und zum Drift-Log in `modul-06` tragen. |
| Additivität (*„entfernt nichts"*) | **Geprüft, ohne Befund.** Die Wort-Differenz entfernt nur `Review-Report)`. Die Aufzählung wird um `MR` erweitert, der Rest des Satzes bleibt stehen, und es gibt einen einzigen Hunk. |
| `ADR-0047`: eingetretene Trigger, Form der Verbuchung, kein `Supersedes` | **Geprüft, ohne Befund.** Trigger 1 (nächster Sprung) und Trigger 2 (`git diff --name-only` über die fünf Dateien nennt `modul-02`) sind eingetreten. `ADR-0047` ist auf ihren Sprung beschränkt und vollzogen. |
| `ADR-0043` Festlegung 2 (Delta-Basis) | **Geprüft, ohne Befund.** Gelesen wird `v6.8.0`. Das ist zugleich der vendored Stand und deckt sich mit `harness/migration.md` §3. |
| `ADR-0018` Festlegung 3 (zweiter Fall), Festlegung 4 (Grenzen), Option C | **Geprüft, ohne Befund**, abgesehen von H-1. Keine Deutung der Ausgänge, kein Urteil über einzelne Einträge (`MR-039` ist ausdrücklich ausgenommen), keine allgemeine Regel. |
| `ADR-0036`, zweiter Grund nicht beansprucht | **Geprüft, ohne Befund.** `ls -1 .harness/baseline/` gibt `v6.8.0` aus. |
| `ADR-0040`: Form des Acceptance-Triggers | **Geprüft, ohne Befund.** Der Trigger nennt die vier ADRs und den Ablageort, verlangt die namentliche Nennung des Reports und schließt die Nachmessung aus (Festlegungen 1 und 2). Er ist gesetzt, solange die Datei `Proposed` ist (Festlegung 3). Die Beleg-Kennung dieser Runde ist **`2026-09-16-adr-0056-konsistenz`**. |
| `ADR-0031` Festlegung 2: Buchung in §Baseline | **Geprüft, ohne Befund.** Gebucht sind die Setzung mit Datum und der Zeiger auf die regierende Entscheidung, in derselben Prosa-Form wie bei den drei vorigen Sprüngen. Die Aufzählungszeile mit Delta-Nachweis fehlt zu Recht, weil der Vollzug aussteht. `ADR-0031` ist `Proposed`, das Bezug-Feld sagt das. |
| `harness/migration.md` §1: Zeile und Folgeabsatz | **Geprüft, ohne Befund.** Die Zeilenform entspricht der Vorgänger-Zeile, der Status `Proposed` ist genannt. Die Tabelle hat acht Zeilen, *„achter Sprung"* trägt. |
| `ADR-0052` (host-lokaler Pfad) | **Geprüft, ohne Befund.** Kein Treffer auf Host-Präfixe. Die Kommandos arbeiten mit den Platzhaltern `K` und `T`. |
| `AGENTS.md` §3.7 im ADR-Rumpf | **Geprüft, ohne Befund.** Der Rumpf enthält keine Befund-Kennung und keine Slice-Erzählung. Die einzige Slice-Kennung steht in einer zitierten Kommando-Ausgabe (`:187`). *„Anders als bei ADR-0047"* vergleicht Entscheidungen und erzählt nicht die Entstehung des Textes. §Geschichte hat eine einzige Zeile. |
| `AGENTS.md` §3.11 | **Geprüft, ohne Befund.** Markdown-Links gehen nur auf ortsfeste Ziele: ADR-Dateien, `harness/migration.md`, `harness/conventions.md` samt Ankern, das Verzeichnis `harness/conventions/`, `AGENTS.md` und das Lastenheft. `.harness/baseline/v6.8.0` steht nur als Operand eines datierten Mess-Kommandos. Es ist ein tag-gescoptes Verzeichnis und nach §3.11 ortsfest. Die Präzedenz ist `ADR-0047`. |
| `MR-033` | **Geprüft, ohne Befund.** Jede Aussage über die Baseline nennt den Tag, am Kommando oder im Satz (*„In `v6.9.0` fügt …"*, *„Baseline-Regelwerk `v6.8.0`, `modul-08-agentenrollen.md`"*). |
| `AGENTS.md` §3.8: Commit-Zuschnitt | **Geprüft, ohne Befund.** Alle drei Commits berühren nur die ADR, den ADR-Index (Architect nach `ADR-0024`), `harness/conventions.md` und die Abschnitte §1 und §5 a von `harness/migration.md`, die Architect-Originale projizieren (siehe I-3). Jede Message nennt die Rolle und `ADR-0056`. |
| Rollen-Konflikt | **Keiner in dieser Runde.** Bestreitet der Architect H-1, gilt der Konflikt-Pfad aus Modul 8 als Sequenz mit Übergabe-Artefakten. Eine Herabstufung wegen des Widerspruchs ist ausgeschlossen. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:**
`tragender Grund beruft sich auf eine Wirkung, die der Durchgang des Sprungs nicht hat` ·
`Geltungs-Zusage einer ADR hinkt ihren eigenen Folge-Commits nach` ·
`Register-Selbstbeschreibung zählt ihre Originale nicht nach` ·
`Zahl-Beleg außerhalb des Absatzes seines Kommandos` ·
`Durchgangs-Schritt ohne Zeitpunkt gegenüber dem Tausch` ·
`Setzung im lebenden Register ohne Wirkungszeitpunkt` ·
`gemischte Originale eines Registers`

## Verdikt

**Nicht annahmefähig, blockierender Befund: H-1.** Er trifft die **Festlegung**, genauer ihren
tragenden Grund, und damit Prüfgegenstand 1 des Triggers. Die Prämisse *„ungestellt"* ist für
`MR-NNN-titel` widerlegt, und für `gate`/`welle-results` fehlt der Schritt im Durchgang dieses
Sprungs. Sie bestätigt nur die Lage, die Re-Evaluierungs-Trigger 3 als Wegfall des Grundes führt.
M-1 ist ebenfalls **vor** dem Umschlag zu beheben, weil die Zusage sonst eingefroren wird
(`ADR-0040` Festlegung 3). L-1, L-2 und die drei INFO-Befunde sind zu beheben oder zu beantworten,
hindern die Annahme für sich aber nicht.

**Prüfgegenstände 2 und 3 tragen.** Die Übernahme-Vorgabe ist korrekt als Verbuchung geführt, und
die Festlegung stützt sich nicht auf sie. Die Trennung Prozedur ↔ Ist-Maßstab ist durch
`ADR-0018` Festlegung 2 gehalten.

**Folge nach `ADR-0040` Festlegung 2:** Nach der Überarbeitung ist der Beleg eine **erneute Runde
der Reviewer-Rolle** in frischem Kontext. Die Nachmessung durch den Architect-Lauf, der H-1 auflöst,
zählt nicht.

**Nicht geprüft habe ich:** (a) ob `archiv-stub-slice`, `archiv-stub-welle` und `welle` durch die
Ziel-Klausel anders eingeordnet werden als durch die Ausdehnung in `harness/migration.md` §4. Die
Klausel nennt alle drei (Messung 4), die Zuordnung ist aber Sache des Durchgangs. (b) Die Wirkung
des `modul-05`-Abschnitts auf die Planungs-Werkzeuge und das Doku-Gate; die ADR schließt das selbst
aus. (c) Den Auswahl-Maßstab von `MR-035`/`MR-056`. (d) Das Delta je `MR`-Eintrag und den Schnitt
des Sprung-Slice (laut Auftrag nicht meine Aufgabe). (e) `make gates` über `897ddd93` selbst,
gefahren ist es nur über dem Endstand dieses Laufs.

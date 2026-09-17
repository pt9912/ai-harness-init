# MR-067 — Eine Aufbau-Anleitung nennt ihre Prüf-Bedingung vor ihren Kommandos

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.
- **Geltungsbereich:** die **Aufbau-Anleitung** einer Messung in einem Eintrag dieses Blocks —
  die Sätze, aus denen ein späterer Lauf die gemessene Lage wiederherstellt. Namentlich die
  Anleitung zu Messung 1 in
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst).
  **Nicht** die **Messwerte** jener Messung: Sie stehen unverändert, und dieser Eintrag prüft sie
  nicht nach. **Nicht** die Angabe, die ein history-lesender Lauf **nach** der Messung trägt: Die
  setzt
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1, sie bindet unverändert, und dieser Eintrag setzt die Bedingung **davor**. **Nicht**
  die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)):
  Sie läuft über einer `git archive`-Kopie ohne `.git` und hat keinen Objektspeicher. **Nicht**
  der **Bestand** der angenommenen Einträge: Setzung 4 zieht die zeitliche Grenze. **Nicht**
  `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 gilt; **nicht** die emittierte Ebene.
- **Löst auf:** in
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  den Aufbau-Satz von Messung 1 — *„Wegwerf-Kopie: `git clone --no-local`, Pack per
  `git unpack-objects` ausgepackt und entfernt, dann
  `git maintenance run --task=loose-objects`."* — **als Anleitung**. Die Messwerte der Tabelle
  darunter, ihre Gegenprobe und die Angabe daneben gelten fort.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung der Versuch, die Lage aus
  der Anleitung wiederherzustellen. Dieselbe Lage beschreiben
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  und
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**; das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld. Die Baseline kennt keine Form für eine Aufbau-Anleitung. Nahe liegt
  [`modul-13-quality-gates.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-13-quality-gates.md#adr-zur-fitness-function)
  §Fitness Function aus einem ADR-Satz: *„Und das Rot muss von **dieser** Regel kommen."*
  (`grep -c 'Und das Rot muss von \*dieser\* Regel kommen' .harness/baseline/v6.9.0/regelwerk/modul-13-quality-gates.md`
  → **1**). Diese Setzung wendet den Gedanken eine Stufe früher an — auf den **Aufbau**, der den
  Gegenstand überhaupt erst herstellt — und tritt an keine Stelle.
- **Adaption — Setzung 1, die Reihenfolge.** Eine Aufbau-Anleitung nennt **zuerst die
  Prüf-Bedingung**, gegen die der Aufbau vor der Messung gehalten wird, und **danach** die
  Kommandos, mit denen der schreibende Lauf sie erreicht hat. Die Bedingung ist die Zusage; die
  Kommandos sind **eine** gemessene Erreichung, nicht ihre Definition. Ein Lauf, der die Kommandos
  fährt, prüft die Bedingung, bevor er misst.
- **Setzung 2 — die Bedingung für die Pack-Namens-Lage: zwei Abwesenheiten und eine
  Anwesenheit.** Für den Fall, den
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  Messung 1 misst:
  - **kein Pack mit dem Präfix `pack-`** — `ls .git/objects/pack/ | grep -c '^pack-'` → **0**;
  - **kein loses Objekt** — `git count-objects -v`, Zeile `count:` → **0**;
  - **die Objekte der Range sind da** — `git cat-file -t <Range-Basis>` → `commit`, gefahren mit
    dem `git` des Hosts, das Packs jeden Namens liest.

  Die zwei Abwesenheiten zusammen machen das Pack unter fremdem Präfix zum **einzigen** Weg zu den
  Objekten; die Anwesenheit sagt, dass es diesen Weg überhaupt gibt. Ist eine der drei verletzt,
  misst der Lauf nicht das Pack.

  **Warum die dritte Zeile dasteht, obwohl ihr Fehlen laut scheitert.** Ein leerer Objektspeicher
  erfüllt die zwei Abwesenheiten und trägt trotzdem nichts; ein Lauf darüber bricht unter **beiden**
  Ständen ab, und ein stilles falsches Grün entsteht daraus nicht. Die Zeile kostet also keine
  Deckung, sondern spricht aus, was die zwei anderen voraussetzen — und sie ist ohnehin gemessen
  (Schritt 5 der Folge unten). Eine Bedingung, die nur Abwesenheit prüft, liest sich als *„nichts
  stört"* und ist eine über *„der Gegenstand ist da"*.
- **Setzung 3 — warum `count: 0` trägt, und warum es die übersehene Zeile ist.** Liegen die
  Objekte lose **neben** dem Pack, findet jeder Leser sie direkt; das Pack wird nicht gebraucht,
  und der Unterschied zwischen zwei Werkzeug-Ständen verschwindet. Der Lauf ist dann grün ohne
  Gegenstand — dieselbe Klasse wie ein Gate ohne Deckung
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`AGENTS.md`](../../AGENTS.md) §3.6), nur eine Stufe früher: nicht die Prüfung fehlt, sondern
  ihr Objekt. Die Pack-Zeile sieht man am Dateinamen, `count:` nur an `git count-objects -v` —
  deshalb steht es hier als Schritt und nicht nur als Angabe hinterher.
- **Setzung 4 — Cutoff: ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Aufbau-Anleitung,
  die **geschrieben oder geändert** wird; der **Bestand ist kein Arbeitsauftrag**. Die
  angenommenen Einträge dieses Blocks tragen ihre Anleitungen, wie sie sie tragen: Nachgetragen
  wird dort nichts —
  [`MR-060`](../conventions.md#mr-060--ein-neues-pflichtfeld-gilt-für-neue-einträge-bestehende-werden-nicht-nachgetragen)
  schließt das für eine neue Pflicht aus, und wo eine Anleitung wirklich abgelöst wird, ist die
  Kopf-Marke der Weg
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)).
  Ein Maßstab über den Bestand wäre dauerhaft rot und entwertete die Setzung, statt sie zu tragen;
  dieselbe Begründung trägt den Cutoff in [`AGENTS.md`](../../AGENTS.md) §3.7 und §3.8.

  **Eine Zahl steht hier nicht.** Ob eine Anleitung ihre Prüf-Bedingung trägt, ist ein **Urteil,
  kein Muster**: Ein `grep` zählte Einträge, die Kommandos führen, nicht Anleitungen ohne
  Bedingung, und gäbe damit ein Muster als Kriterium aus, das keines ist
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Dieselbe Einordnung trifft
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  für die Fälligkeit seiner Marke.
- **Die Folge, gemessen.** Host-`git` in der Fassung aus `git --version` → **2.43.0**; die Lage
  ist an einem `git clone --no-local` dieses Repos hergestellt, außerhalb des Arbeitsbaums. Die
  Zahlen wandern mit dem Bestand und sind **keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); tragend ist allein die **0** am Ende.

  | Schritt | Kommando | `count:` | `in-pack:` | `ls .git/objects/pack/` |
  |---|---|---|---|---|
  | 1 | `git clone --no-local <pfad> <ziel>` | 0 | 26713 | `pack-<hash>.{idx,pack,rev}` |
  | 2 | das Pack **aus** `.git/objects/pack/` heraus (`mv`, nicht löschen) | 0 | 0 | leer |
  | 3 | `git unpack-objects < <abgelegtes>.pack` | 26713 | 0 | leer |
  | 4 | `git maintenance run --task=loose-objects` | 26713 | 26713 | `loose-<hash>.{idx,pack,rev}` |
  | 5 | `git prune-packed` | **0** | 26713 | `loose-<hash>.{idx,pack,rev}` |

  Nach Schritt 5 sind die zwei Abwesenheiten aus Setzung 2 erfüllt, und die dritte Zeile ist
  gefahren: `git cat-file -t 8ae647cc~1` → `commit`. Der Klon ist intakt, nur anders verpackt.
- **Zwei Schritte hängen an der git-Fassung, und beide scheitern still.** Beide sind am Aufbau
  oben vorgeführt, nicht abgeleitet:
  - **Schritt 2 ist kein Zierrat.** `git unpack-objects` überspringt Objekte, die noch gepackt
    vorliegen. Mit dem Pack **in** `.git/objects/pack/` bleibt `count:` bei **0**, und der Aufruf
    meldet nichts — er sieht aus wie ein Erfolg. Ein `-f` gibt es in der gemessenen Fassung nicht:
    `git unpack-objects -f < …` antwortet mit der Usage-Zeile
    `usage: git unpack-objects [-n] [-q] [-r] [--strict]`.
  - **Schritt 5 ist kein Zierrat.** `git maintenance run --task=loose-objects` legt das
    `loose-*.pack` an und **lässt die losen Objekte liegen**: Zeile 4 der Tabelle zeigt `count:`
    und `in-pack:` gleichzeitig auf **26713**. Wer hier aufhört, hat die erste Zeile der Bedingung
    erfüllt und die zweite verletzt.
- **Grenze.**
  - **Gemessen ist eine Stelle** — eine git-Fassung, ein Klon-Verfahren, ein Repo
    ([`MR-055`](../conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
    Eine andere git-Fassung kann andere Schritte verlangen; **die Bedingung aus Setzung 2 bleibt
    davon unberührt**, und genau dafür steht sie vor den Kommandos.
  - **Die Folge ist nicht die einzige Erreichung.** Jeder Weg, der die Zeilen aus Setzung 2
    erfüllt, taugt; `git maintenance` ist der gemessene, nicht der vorgeschriebene.
  - **Die Wirkung auf d-check misst dieser Eintrag nicht.** Er stellt die Lage her und prüft sie;
    was die zwei Werkzeug-Stände darin melden, steht in
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
    Messung 1 und bleibt dort.
  - **Kein Wächter.** Kein `make`-Ziel prüft eine Aufbau-Anleitung, und keines gibt die Bedingung
    aus; Träger ist der Lauf, der die Lage herstellt. Die Kommandos brauchen nur `git` auf dem
    Host ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Begründung:**
  - **Die Anleitung wird beim nächsten Pin-Sprung gelesen, der Slice-Plan nicht.** Die drei
    Stellen, die ein Sprung konsultiert, liegen alle in diesem Block — der Trigger von
    [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv),
    die Gegenmessung aus
    [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
    und die Angabe aus
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest).
    Ein Plan ist ein Zeitdokument und steht in keiner dieser Stellen; wer die Lücke dorthin legt,
    legt sie an einen Ort, den der nächste Sprung nicht aufschlägt.
  - **Die vorhandene Angabe reicht nicht, und das ist gemessen statt vermutet.** Sie ist eine
    Pflicht **nach** dem Lauf: Sie sagt, was zu berichten ist, nicht, was herzustellen ist. Ein
    Aufbau, der bei Schritt 4 endet, erfüllt den Satz aus
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
    wörtlich und hat `count:` bei 26713 (Tabelle, Zeile 4). Die Angabe hätte das hinterher
    ausgewiesen — nachdem die Messung schon nichts mehr gemessen hätte.
  - **Der teurere Fehler ist der stille.** Die verlorene Zeit beim Nachbauen ist die kleinere
    Hälfte; die größere ist ein Aufbau, der die Bedingung verfehlt und trotzdem eine Tabelle
    füllt. Beide Stände melden dann dasselbe, und das liest sich wie ein Befund über das Werkzeug.
  - **Kopf-Marke an
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)**
    nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 1 und 3: Der Eintrag ist angenommen, und abgelöst wird ein benannter Satz. Die
    Ausnahme aus Setzung 4 für die Pin-Kette greift nicht — abgelöst wird kein Messwert, sondern
    eine **Anleitung**. Seine Datei bleibt nach
    [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
    in [`conventions/`](../conventions/): Die Position ist binär und trägt die Teil-Ablösung nicht.
  - **Ein eigener Eintrag statt einer Korrektur.**
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
    liegt gepusht und ist angenommen; an einem angenommenen Eintrag wird nichts nachträglich
    inhaltlich geändert (§Adaptions-Block). Die Kosten — ein Eintrag mehr in der Kette — trägt der
    Block ohnehin für die zwei anderen Methoden-Einträge; gelesen wird er einmal je Sprung.
- **Auflösungs-Trigger:** permanent, solange ein Eintrag dieses Blocks eine Lage herstellt, die
  ein späterer Lauf wiederherstellen soll. **Neu zu prüfen** ist Setzung 2, sobald d-check
  Alternates folgt oder Packs jeden Namens liest — dann ist die Lage kein Gegenstand mehr, und
  mit ihr entfällt ihre Bedingung. Die **Folge** ist neu zu messen, sobald der Host eine andere
  `git`-Fassung führt und einer ihrer Schritte anders antwortet; die Bedingung darüber bleibt.
  Setzung 4 hat keinen Trigger: Ein Cutoff, der später fiele, machte den Bestand nachträglich zum
  Arbeitsauftrag.

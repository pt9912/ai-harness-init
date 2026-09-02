# Slice slice-136: Die Roadmap trägt die Ziel-Form — der Abschnitt, der die Welle abschreibt, wird zum Zeiger auf sie

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — fünfter Nachzügler neben `slice-130` bis
`slice-133`. Die Zugehörigkeit ist **gemessen, nicht gewählt**, und sie fällt nach derselben Probe,
die [slice-134](../open/slice-134-adr-index-traegt-die-ziel-form.md) für den ADR-Index ins Gegenteil
führte: *stammt der Befund aus dem Re-Baseline-Delta?* Dort nein, hier ja — die abgelöste Vorlage
führte den ersten Abschnitt als `## Aktuelle Welle`, die neue führt ihn als `## Offene Wellen`
(`git show c6cc56f:.harness/baseline/v3.5.2/templates/docs/plan/planning/roadmap.template.md | grep -c '^## Aktuelle Welle'`
→ **1**, `grep -c '^## Offene Wellen' .harness/baseline/v5.12.0/templates/docs/plan/planning/roadmap.template.md`
→ **1**). Damit belegt dieser Slice ein Closure-Kriterium der Welle, das ohne ihn eine Lücke trägt:
§3 *Durchgang 2 — Form* verlangt die Pflichtfelder der neuen Gliederung **in den
Singleton-Artefakten**, und die Roadmap ist eines — in der extensionalen Menge von
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §2 steht sie nicht
(`grep -c 'roadmap' docs/plan/planning/done/slice-083-form-vergleich-pflichtfelder.md` → **0**).

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die Roadmap **dieses** Repos. Die emittierte
Ebene hat denselben Gegenstand unter einem anderen Vertrag und einen anderen Träger: was ein
Zielrepo als Roadmap bekommt, entscheidet
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md), und ein frisch
gebootstrapptes Repo hat eine leere Roadmap ohne Welle, über die dieser Slice etwas aussagen
könnte.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — die
Wächter-Frage in §1 wird **entschieden**, nicht offen gelassen; ein Modul, das über einer Menge
prüft, die nicht driften kann, ist das stille Grün, das diese Anforderung ausschließt.
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — jede nicht übernommene
Position der Ziel-Form ist als Abweichung zu begründen; eine unerklärte ist keine Adaption,
sondern ein Fork.
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
— der Eintrag bindet seinen Geltungsbereich zweimal wörtlich an `§Aktuelle Welle`; er ist
**Architect-Artefakt** und wird von diesem Slice nicht angefasst (§6).
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
— jede Zahl neben ihrem Kommando, hier besonders heikel, weil der Prüfgegenstand die Roadmap
selbst ist und ihre Zahlen mitwandern.
[ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) — die
schreibende Rolle wird aus den Originalen abgeleitet; die Roadmap projiziert die flachen
Welle-Dateien, die der **Planner** schreibt.
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.8
(Norm-Artefakte schreibt der Architect).

**Berührte Spec-Stellen:** — Dieser Slice berührt keine. Die Roadmap steht auf Rang 5 der Source
Precedence, aber als **derivative Sicht**: Ziel, Trigger und Closure-Kriterien einer Welle sagt
ihre Welle-Datei. Der Verweis zeigt ohnehin **aufwärts**; die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-29.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Die Roadmap sagt über die laufenden Wellen wieder nur das, was keine andere Datei sagt — und
was sie heute daneben sagt, hat vorher einen Ort bekommen statt gelöscht zu werden.**

### Der Befund ist eine Größe, und die Zeilenzahl misst ihn falsch

Gegen die vendored Ziel-Form gemessen (alle Kommandos aus dem Repo-Wurzelverzeichnis, Stand
2026-08-29 — **keine Erwartungswerte**,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die zwei Pfade stehen unten als `$IST` und `$SOLL`, einmal gebunden statt in jedes
Kommando wiederholt — die Kommandos laufen damit wörtlich, ohne Einsetzen:

```
IST=docs/plan/planning/in-progress/roadmap.md
SOLL=.harness/baseline/v5.12.0/templates/docs/plan/planning/roadmap.template.md
wc -c "$IST" "$SOLL"
```

→ **77 189** gegen **5 115** Zeichen. Die Abschnitts-Namen decken sich fast vollständig: beide
Dateien führen **7** Überschriften (`grep -cE '^#{1,2} ' "$IST" "$SOLL"`), und **6** davon sind
wortgleich — die `# Roadmap`-Zeile und fünf der sechs `## `-Abschnitte
(`comm -12 <(grep '^## ' "$IST" | sort) <(grep '^## ' "$SOLL" | sort) | wc -l` → **5** von 6).
**Die Form stimmt also fast; der Inhalt nicht.**

**Und der naheliegende Maßstab führt in die Irre.** Nach Zeilen ist *Aktuelle Welle* mit **140**
von **303** (`wc -l < "$IST"`) der größte Abschnitt. Nach Zeichen ist er der **drittgrößte**, weil
die Zeilen dieser Datei sehr verschieden lang sind
(`awk '{print length($0)}' "$IST" | sort -rn | head -1` → **8 651** Zeichen in **einer** Zeile).
Die Verteilung, mit ihrem Kommando:

```
awk '/^## /{if(s)printf "%-38s %5d Zeilen %7d Zeichen\n",s,NR-st,c; s=$0;st=NR;c=0}
     {c+=length($0)+1} END{printf "%-38s %5d Zeilen %7d Zeichen\n",s,NR-st+1,c}' "$IST"
```

| Abschnitt | Zeilen | Zeichen | Anteil |
|---|---|---|---|
| `## Aktuelle Welle` | 140 | 10 656 | 14 % |
| `## Nächste Wellen` | 40 | 20 773 | 27 % |
| `## Meilensteine` | 11 | 4 413 | 6 % |
| `## Abhängigkeitsgraph` | 52 | 2 823 | 4 % |
| `## Abgeschlossene Wellen` | 18 | 1 532 | 2 % |
| `## Historische Trigger-Verschiebungen` | 30 | **35 248** | **46 %** |

**Der Schwerpunkt liegt nicht dort, wo die Zeilen liegen.** Das Drift-Log trägt in **30** Zeilen
fast die Hälfte der Datei. Seine Zeilen sind zwischen **139** und **3 132** Zeichen lang
(`grep -E '^\| [0-9]{4}-' "$IST" | awk '{print length($0)}' | sort -n | sed -n '1p;$p'`), und die
Spreizung folgt dem Datum: die kurzen tragen `2026-07`, die langen `2026-08-28`. Die Spalte
`Warum?` trägt inzwischen Regelwerks-Zitate, Kommando-Belege und Rang-Argumente — eine ADR in einer
Tabellenzelle. **Die Zeilen-Nummern dieser Datei taugen nicht als Anker**, deshalb steht hier und
im Folgenden je ein inhalts-gebundenes Kommando: die Roadmap wächst bei jeder Umplanung in der
Mitte, und ein `NR>=278` zeigt schon eine Umplanung später woandershin.

### Was der Vergleich je Abschnitt ergibt

**Kopf.** Die Ziel-Form kennt **kein** `**Status:**`-Feld; die abgelöste Vorlage hatte eines und
die neue hat es gestrichen (im Template-Diff eine `-`-Zeile). Unseres steht noch da — und es ist
**bereits falsch**: `grep -o 'Letzte Änderung:\*\* [0-9-]*' "$IST"` → `2026-08-28`, während die
jüngste Drift-Zeile derselben Datei `2026-08-29` trägt
(`grep -oE '^\| 2026-[0-9-]+' "$IST" | head -1`).
Ein selbstgepflegtes Zustandsfeld, das an seiner eigenen Datei altert — genau der Grund, aus dem
die Ziel-Form es nicht mehr führt. Dazu zeigt die `Format-Regel` auf eine Kurs-URL am **abgelösten**
Tag (`grep -c 'ai-harness-course/blob/v3\.5\.2' "$IST"` → **1**), während der vendored Baum
`v5.12.0` ist (`ls -d .harness/baseline/*/`); die Ziel-Form verweist stattdessen netzlos auf
`modul-06-roadmap.md`.

**(1) `## Aktuelle Welle` gegen `## Offene Wellen` — der Namensunterschied ist die Ursache, nicht
das Symptom.** Die Ziel-Form trägt hier eine **Liste von Zeigern**, einen je flacher Welle-Datei,
plus den Ruhe-Marker, wenn `in-progress/` keinen Slice trägt. Unsere Fassung trägt stattdessen für
**zwei** Wellen je einen ausgeschriebenen `**Trigger:**`- und `**Closure-Kriterium:**`-Absatz —
also genau das, was die Ziel-Form mit *„stehen in der Welle-Datei, nicht hier"* ausschließt. **Die
Doppelung ist gemessen:** `grep -c 'baseline-freshness' "$IST"` → **2** und
`grep -c 'baseline-freshness' docs/plan/planning/welle-10-re-baseline.md` → **3**; `grep -c '4 × 2-Matrix'`
→ **3** in der Roadmap gegen **1** in [welle-09](../welle-09-modul-15-konformitaet.md). Zwei
Quellen für denselben Trigger, und die zweite altert. **Schon die abgelöste Vorlage verbot das**
— sie führte an dieser Stelle die Zeile `**Closure-Trigger:** <siehe Welle-Datei>`; der Abschnitt
ist also nicht am Tagwechsel entgleist, sondern lange davor.

**Und 21 der 140 Zeilen existieren nur, weil die Überschrift falsch ist** — der gesamte Schwanz des
Abschnitts ab *„Warum dieser Abschnitt zwei Wellen trägt, und warum welle-09 nicht nach unten
wandert"*
(`awk '/^\*\*Warum dieser Abschnitt zwei Wellen/{f=1} f&&/^## /{exit} f{n++} END{print n}' "$IST"`
→ **21**). Zwei Absätze, beide **über den Abschnitt** statt über eine Welle: der erste begründet
seine Kardinalität, der zweite, warum die Nachfolge-Regel aus Modul 6 hier nicht mechanisch greift.
Unter dem Namen *Offene Wellen* ist keine der beiden Fragen begründungsbedürftig — dort ist die
Mehrzahl der Normalfall und die Reihenfolge steht in *Nächste Wellen*. **Der Zielzustand ist heute schon fast erreicht, nur
unter dem falschen Namen** — die Bijektion, die die Ziel-Form verlangt, hält bereits:
`ls docs/plan/planning/welle-*.md | wc -l` → **4** und
`grep -o '\.\./welle-[a-z0-9-]*\.md' "$IST" | sort -u | wc -l` → **4**, dieselben vier Kennungen.
Zu tun ist der Rückbau der Prosa, nicht der Aufbau einer Liste.

**(2) `## Nächste Wellen` — Form richtig, Zellen nicht.** Die Ziel-Form ist eine Tabelle mit vier
Spalten und einzeiligen Zellen. Unsere trägt zwei ausgeschriebene Wellen-Absätze **und** eine
Kandidaten-Tabelle, deren vier Zeilen zusammen **18 314** Zeichen messen, die längste **8 651**
(`awk '/^\| Welle-Kandidat \|/{f=1;next} f&&/^\|---/{next} f&&/^\| /{s+=length($0)+1;next} f{exit} END{print s}' "$IST"`,
für die Einzelwerte `print length($0)` statt der Summe). **Diese
vier Zeilen sind der harte Fall dieses Slice:** zu ihnen gehört **keine** Welle-Datei — sie führen
noch nicht geschnittene Kandidaten, und ihr Inhalt steht nirgendwo sonst. Wer sie auf die
Ziel-Form kürzt, ohne vorher einen Ort für sie zu benennen, vernichtet die einzige Fassung.

**(3) `## Meilensteine` — die Status-Zelle erzählt die Chronik.** Modul 6 §Roadmap-Struktur sagt es
wörtlich: *„Jede `Stand`-/`Status`-Zelle … trägt den Zustand und den Beleg als auflösbaren Anker,
nie die Chronik."* Gemessen
(`awk '/^\| M[0-9]/ {n=split($0,a,"|"); printf "%s %d\n", substr(a[2],1,4), length(a[5])}' "$IST"`
— das Muster nennt `M[0-9]`, nicht `M`, sonst zählt die Kopfzeile mit):
M1–M3 je **27** Zeichen, M4 **96**, **M5 692**, **M6 753**. Die zwei letzten tragen Release-Läufe,
Asset-Zahlen, einen offengelegten Mangel und dessen spätere Behebung — Zustand plus Beleg wäre
*„erreicht 2026-07-26"* mit einem Anker. **Das ist derselbe Befund, der am ADR-Index gerade behoben
wurde** (`git log --oneline -1 06a640a`), nur in der zweiten Tabelle dieses Repos. Dazu trägt die
Spalte `Welle(n)` bei M5 den Text *„ohne Welle: slice-049 → slice-050"*, wo Modul 6 ausdrücklich
`—` und die Slice-ID **daneben** vorsieht.

**(4) `## Abhängigkeitsgraph` — der Graph passt, die Prosa darunter nicht.** Der `mermaid`-Block
entspricht der Ziel-Form. Darunter stehen drei Absätze, die Kanten **begründen** (welche entfallen
ist und warum, warum `W12` keine hat). Begründungen einer Kante gehören zum Trigger, und der steht
in der Welle-Datei; die Ziel-Form sieht unter dem Graphen nichts vor.

**(5) `## Abgeschlossene Wellen` — der Abschnitt, der die Ziel-Form trägt.** Neun Zeilen, je Welle
Datum und Zeiger auf die Results-Notiz, dazu ein dreizeiliger Absatz, der die Nummernlücke
erklärt. **Das ist der Vergleichsmaßstab für alle anderen:** 1 532 Zeichen für neun geschlossene
Wellen gegen 10 618 für zwei offene.

**(6) `## Historische Trigger-Verschiebungen` — zwei Defekte, einer davon wörtlich benannt.** Der
erste ist die Zellengröße oben. Der zweite ist der **Gegenstand**: Modul 6 sagt *„Wer Schließungen
oder Meilensteine ins Drift-Log schreibt, führt ein zweites Closure-Log, und zwei Logs driften"*,
und die Ziel-Form wiederholt es im Bedienhinweis. Unsere Tabelle führt beides —
`grep -cE '^\| [0-9]{4}-.*(geschlossen; welle-.* aktiviert|M[0-9] nachgetragen)' "$IST"` → **3**
(zwei `M<N> nachgetragen`, eine `welle-01 geschlossen; welle-02 aktiviert; M1 erreicht`).

**Quer über alle sechs Abschnitte fehlt dieselbe Zeile.** Die Ziel-Form stellt jedem Abschnitt eine
`Regeln dieser Sektion:`-Zeile voran, die seine Regel im vendored Regelwerk verankert:
`grep -c 'Regeln dieser Sektion' "$SOLL"` → **6** gegen `grep -c 'Regeln dieser Sektion' "$IST"` →
**0**. Sie ist **neu in dieser Baseline** (dieselbe Zählung über die abgelöste Vorlage → **0**) —
also Sprung-Delta, nicht Nachlässigkeit.

### Was die Kürzung riskiert, und warum das ein Liefer-Punkt wird

Die Roadmap ist derivativ — trägt sie etwas Eigenes, ist **das** der Defekt und nicht die Kürzung.
Aber *„müsste in der Welle-Datei stehen"* ist eine **Annahme**, bis sie geprüft ist, und der
Vergleich oben liefert für beide Antworten je einen belegten Fall: die Trigger-Absätze stehen
nachweislich doppelt (Kommandos in (1)), die vier Kandidaten-Zeilen nachweislich nur hier (2).
Zwischen diesen Polen liegt der Rest, und über ihn entscheidet niemand vorab. Darum trägt DoD (1)
ein **Verbleibs-Protokoll** mit genau drei zulässigen Ausgängen je getilgter Aussage — nicht den
Vorsatz, sorgfältig zu sein.

### Die Wächter-Frage, und sie hat schon einen Träger

Die Ziel-Form schreibt die Analyse aus: der Block trägt **zwei unabhängige Aussagen** — die
**Marker-Hälfte** (Ruhe-Marker genau dann, wenn `in-progress/` keinen Slice trägt) und die
**Listen-Hälfte** (Bijektion Zeiger ↔ flache Welle-Dateien, in beide Richtungen) — und warnt, dass
ein Ein-Wellen-Wächter legitime Zustände als Drift meldet.

**Der Sensor für beide Hälften existiert bereits und ist geschnitten.** d-checks Modul `planning`
(`DC-FA-PLAN-001`) prüft die Marker-Hälfte, seine `waves`-Fähigkeit die Listen-Hälfte; das Ziel
`doc-planning` steht in [`d-check.mk`](../../../../d-check.mk) und hängt an keinem Trigger — die
aktivierte Modul-Liste führt es nicht (`grep '^modules:' .d-check.yml | grep -c planning` → **0**;
`grep -c planning .d-check.yml` → **3** zählt dagegen nur Pfad-Zeichenketten und ist **nicht** der
Sensor für diese Aussage). Träger ist
[slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) in
[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — und **dieser Slice ist seine
Vorbedingung, nicht sein Duplikat.** slice-125 §1 misst gegen den heutigen Stand
`planning-drift` auf [`roadmap.md`](../in-progress/roadmap.md) **Zeile 13** — das ist die Zeile
`## Aktuelle Welle` — und stellt genau deshalb die Frage, die er selbst als offen führt: *„Entweder
der `marker`/`heading` wird auf eine Sektion gezogen, für die die Invariante wirklich gilt, oder
die Roadmap-Konvention ändert sich."* **Dieser Slice wählt den zweiten Zweig und macht die
Invariante wahr**, statt den Wächter auf eine Sektion zu richten, in der sie trivial gilt — die
Auflösung, die slice-125 DoD (2) ausdrücklich als **rot** benennt. DoD (3) hält das fest, damit die
Frage entschieden ist und nicht ungestellt bleibt
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Kein Satz verschwindet ungeprüft: das Verbleibs-Protokoll liegt vor, und jede getilgte
      Aussage trägt genau einen von drei Ausgängen.** Die drei sind erschöpfend und schließen
      einander aus: **(a) steht schon in der Welle-Datei** — Beleg ist das Kommando, das sie dort
      findet, und der Zeiger genügt; **(b) steht nur hier und wandert nach `<Ziel>`** — das Ziel ist
      benannt und existiert nach dem Slice; **(c) ist Roadmap-eigen und bleibt**, in der Ziel-Form
      gekürzt. **Der harte Fall ist vorab benannt und darf nicht in (a) rutschen:** die vier
      Kandidaten-Zeilen (18 314 Zeichen, §1) haben keine Welle-Datei — für sie ist (a) faktisch
      falsch, und (b) verlangt einen Ort, den es heute nicht gibt.
      **Rot:** eine Aussage, die die neue Fassung nicht mehr trägt, steht in keiner Protokollzeile —
      oder eine Zeile behauptet (a) und das mitgelieferte Kommando findet den Satz in der genannten
      Welle-Datei **nicht**. Beide Richtungen sind am Diff des Umsetzungs-Commits prüfbar
      (`git show --stat` plus das Protokoll); mechanisch rot wird diese Hälfte nicht, sie trägt das
      Review.
- [ ] **(2) Die Roadmap trägt die Ziel-Form über alle sieben Abschnitte, und jede nicht übernommene
      Position ist begründet statt still gelassen.** Eingeschlossen und je einzeln abzunehmen: der
      erste Abschnitt heißt `## Offene Wellen` und trägt Zeiger plus Ruhe-Marker-Mechanik statt
      Trigger- und Closure-Prosa · die sechs `Regeln dieser Sektion:`-Zeilen stehen · das
      `**Status:**`-Kopffeld ist weg und der Kurs-Verweis zeigt netzlos auf das vendored Regelwerk ·
      die Status-Zellen der Meilenstein-Tabelle tragen Zustand und Beleg, keine Chronik, und die
      Spalte `Welle(n)` bei M5 trägt `—` · das Drift-Log führt weder Schließungen noch erreichte
      Meilensteine. **Wo eine Position der Ziel-Form nicht übernommen wird, steht der Grund an der
      Roadmap** und nennt, wovon abgewichen wird
      ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — eine unerklärte
      Abweichung ist ein Fork, keine Adaption).
      **Rot:** die Kommandos aus §1 erneut gefahren — sie sind der Nachweis, nicht die Erinnerung.
      `grep -c 'Regeln dieser Sektion' "$IST"` liefert nicht **6**;
      `comm -12 <(grep '^## ' "$IST" | sort) <(grep '^## ' "$SOLL" | sort) | wc -l` liefert nicht
      **6**; `grep -c '^\*\*Status:\*\*' "$IST"` liefert nicht **0**;
      `grep -cE '^\| [0-9]{4}-.*(geschlossen; welle-.* aktiviert|M[0-9] nachgetragen)' "$IST"`
      liefert nicht **0**. **Eine Zeichenzahl ist ausdrücklich kein Abnahme-Kriterium** — ein
      Schwellenwert auf `wc -c` wäre ein Maßstab, der mit jeder legitimen Welle rot wird
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2: mitwandernde Zahlen sind keine Erwartungswerte).
- [ ] **(3) Über den Wächter ist entschieden — beide Hälften, je mit Ausgang.** Für die
      **Marker-Hälfte** und die **Listen-Hälfte** steht getrennt, ob dieser Slice sie schließt oder
      nicht; *nicht geschlossen* ist zulässig **und** verlangt den Grund plus den Folge-Slice, der
      sie trägt. Der Erwartungswert ist heute: beide gehen an
      [slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) (Marker) und dessen
      `waves`-Entscheidung (Liste) — dieser Slice **baut keinen Sensor**, er macht die Invariante
      wahr, an der slice-125 sonst scheitert. Aufgeschrieben wird das an der Roadmap **und** in
      §7, nicht nur hier, weil slice-125 später gegen den dann geltenden Stand misst.
      **Rot:** die Frage bleibt ungestellt oder wird mit *„der Sensor kommt später"* ohne benannten
      Folge-Slice beantwortet — dann prüft das Modul weiterhin über einer Menge, die nicht driften
      kann, und der Gate ist das stille Grün aus
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
      Diese Hälfte trägt das Review.
- [ ] `make gates` grün. **Erwartet ist der Stand der Welle, nicht Grün auf leerem Blatt:**
      `docs-check` steht bei einem vorbestehenden Befund
      ([`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md), Folge-Slice
      `slice-132`). Abzunehmen ist, dass **kein weiterer** dazukommt — die Zählzeile vor und nach
      dem Slice gehört in den Umsetzungs-Commit.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — die Roadmap ist **keiner**: sie
      steht auf Rang 5 der Source Precedence, aber als derivative Sicht, und dieser Slice ändert
      keine Welle-Datei inhaltlich.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben: neue `BEO-<NNN>` oder Zähler +1 mit Beleg in
      [`observations.md`](../observations.md) — *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert. Das Reconciliation-Register entfällt dauerhaft: dieses Repo
      hat keinen Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der nächsten Welle-Closure geprüft, nicht hier.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | refactor | der Gegenstand: sieben Abschnitte auf die Ziel-Form, Kopf inklusive |
| [welle-09](../welle-09-modul-15-konformitaet.md) · [welle-10](../welle-10-re-baseline.md) · [welle-11](../welle-11-traeger-aussage.md) · [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) | prüfen, ggf. update | Ziel für Ausgang (b) des Verbleibs-Protokolls: was die Roadmap heute allein trägt und in die Welle-Datei gehört, landet dort — **inhaltlich nur, was heute nirgends steht** |
| [slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) | update | seine §1-Messung nennt `roadmap.md` Zeile 13 und die Sektion `Aktuelle Welle`; nach diesem Slice zeigt sie ins Leere. Planner-Artefakt, derselbe Rollen-Lauf |

**Nicht in dieser Liste, und das ist gemessen, nicht vergessen.** `Aktuelle Welle` steht an sieben
Orten außerhalb der Zeitdokumente
(`git grep -c 'Aktuelle Welle' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`).
Drei Ebenen davon gehören anderen — jede mit ihrem Träger, keine ohne:

| Ort | Treffer | Träger |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird): Geltungsbereich und Setzung 2) | 3 | **Architect** — Adaptions-Block, [`AGENTS.md`](../../../../AGENTS.md) §3.8. Kein Slice; ein eigener Rollen-Lauf mit eigenem Commit |
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) · [`plan-welle.md`](../../../../.claude/commands/plan-welle.md) | 3 | [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) — führt `close-welle` in seiner Plan-Tabelle |
| `internal/emit/templates/commands/` (dieselben zwei Commands, emittierte Fassung) | 3 | [slice-085](../done/slice-085-emittierte-ebene-zieht-nach.md) — dort ausdrücklich zugewiesen; **andere Ebene, anderer Vertrag** |

Die Zeitdokumente in [`done/`](../done) und `docs/reviews/` bleiben unangetastet: sie sagen, was
damals galt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice mehr** — beobachtbar ohne
Rückfrage: `ls docs/plan/planning/in-progress/ | grep -c '^slice-'` → **0**. Heute steht dort
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md), und das
WIP-Limit ist **1**; dieser Slice startet deshalb **nicht** mit seinem Schnitt.

**Eine Reihenfolge-Bindung innerhalb der Welle gibt es nicht.** Der Slice hängt an keinem der vier
Nachzügler: `slice-130`/`slice-133` arbeiten am **emittierten** Baum, dieser an der Datei dieses
Repos. Er kann vor oder nach ihnen laufen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): das Verbleibs-Protokoll aus DoD (1)
  liefert für die vier Kandidaten-Zeilen den Ausgang **(b)** und damit ein Ziel, das erst
  **entstehen** muss — eine Welle-Datei oder ein Register, das es heute nicht gibt. Dann trägt
  dieser Slice zwei Gegenstände statt einen und wird geteilt: Form hier, neuer Ort dort.
- `in-progress` → `open` (blockiert — Carveout?): die Kürzung des ersten Abschnitts verlangt eine
  Aussage über [welle-09](../welle-09-modul-15-konformitaet.md), die nur die vertagte
  Planner-Sitzung treffen kann (§6). **Kein Carveout:** eine offene Vorbedingung ist keine
  Ausnahme von einer Zusage, sondern ein Grund zu warten.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Kriterium 1 — die drei DoD-Punkte sind abgehakt, und die Kommandos aus §1 sind erneut gefahren.**
Ihre Ausgabe liegt im Umsetzungs-Commit, nicht in der Erinnerung: `comm -12` über die
Abschnitts-Namen liefert **6**, `grep -c 'Regeln dieser Sektion'` liefert **6**,
`grep -c '^\*\*Status:\*\*'` liefert **0**, und die Bijektion aus §1 hält weiterhin in beide
Richtungen.

**Kriterium 2 — `make gates` läuft, und die `docs-check`-Zählzeile ist gegen den Vorher-Stand
gehalten.** Abzunehmen ist die **Differenz null**, nicht Grün: der eine vorbestehende Befund
([`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md)) bleibt, ein zweiter wäre
dieser Slice.

**Lerneintrag** in §7 — ohne ihn geht der Slice nicht nach `done/`.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die vier Kandidaten-Zeilen verlieren ihre einzige Fassung.** 18 314 Zeichen ohne Welle-Datei
  (§1). Kürzt der Lauf sie auf einzeilige Zellen, ohne den Ausgang **(b)** aus DoD (1) vorher zu
  bedienen, ist Wissen weg, das kein `git`-Log wiederbringt, weil niemand weiß, dass er suchen
  müsste. — **Ausgang:** <eingetreten: Ziel benannt und angelegt | entfallen: Ausgang (c), die
  Zeilen bleiben in Ziel-Form | weiter offen>
- **Der Rückbau des ersten Abschnitts trifft eine Aussage über welle-09, die dieser Slice nicht
  treffen darf.** Die heutige Prosa erklärt welle-09 für *„angefangen, ruhend, nicht
  abschließbar"*; unter *Offene Wellen* ist sie schlicht ein Zeiger. Damit verschwindet eine
  Einordnung, die eine eigene, ausdrücklich vertagte Planner-Sitzung zum Gegenstand hat
  ([welle-09](../welle-09-modul-15-konformitaet.md) §1). — **Ausgang:** <eingetreten: der Slice
  wartet auf die Sitzung (`in-progress` → `open`) | entfallen: die Einordnung steht in welle-09
  und der Zeiger genügt | weiter offen>
- **Der Slice widerspricht sich selbst, wenn er die Roadmap fortschreibt.** Modul 6 verlangt für
  das Umhängen eines Slice eine Drift-Log-Zeile — dieser Slice schreibt also in dieselbe Tabelle,
  deren Zellengröße er als Defekt führt. **Aufgelöst, nicht verschwiegen:** die Zeile entsteht in
  der Ziel-Form (Umplanung, Grund, Ende) und ist damit die erste, die das Kriterium erfüllt, nicht
  die nächste Ausnahme davon. — **Ausgang:** <eingetreten: Zeile länger als die Ziel-Form erlaubt
  | entfallen: Zeile in Ziel-Form | weiter offen>
- **[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  bleibt nach diesem Slice auf einen Abschnitt gebunden, den es nicht mehr gibt.** Der Eintrag
  nennt `§Aktuelle Welle` in seinem Geltungsbereich und in Setzung 2. Er ist Architect-Artefakt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und dieser Slice fasst ihn nicht an. **Das ist eine
  Übergabe, kein Versäumnis** — aber eine, die ohne Ausgang zu einer toten Referenz wird. —
  **Ausgang:** <eingetreten: Architect-Lauf angestoßen, eigener Commit | entfallen: Grund |
  weiter offen>
- **Die Kürzung erzeugt einen `docs-check`-Befund, weil ein Anker verschwindet.** Die Roadmap
  trägt Anker-Links in großer Zahl; wer Absätze entfernt, entfernt Linkziele nicht, aber
  möglicherweise Linkquellen, auf die andere Dateien zeigen. — **Ausgang:** <eingetreten: Befund
  behoben im selben Slice | entfallen: Zählzeile unverändert | weiter offen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`observations.md` neben den Wellen):** <neue `BEO-<NNN>` mit Beleg |
  Zähler +1 an einer vorhandenen Kennung | keine Beobachtung angefallen — und dann steht genau das
  hier, statt dass die Zeile fehlt>.
- **Wächter-Entscheidung (DoD 3), wörtlich für den nächsten Leser:** <Marker-Hälfte: …
  Listen-Hälfte: … — je gebaut oder mit Grund und Folge-Slice nicht gebaut>. Diese Zeile ist die,
  die [slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) später liest.
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo fährt Wellen-Betrieb — sie prüft die nächste Welle-Closure.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist genau **eine**: `docs/plan/planning/`. Sie
erfüllt die Schwelle ≥ 2 von 3 Achsen: eigener Zuschnitt mit eigener ID-Reihe (`slice-NNN`,
`welle-NN`), eigene Ziel-Formen im vendored Baum
(`ls .harness/baseline/v5.12.0/templates/docs/plan/planning/`) und eine eigene Regel-Lage über
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
— drei von drei. Der Schnitt ist nicht zu grob: `docs/plan/` als Ganzes trüge Planung, Carveouts
und ADRs zusammen und vermischte drei Regel-Lagen in einem Block — dieselbe Begründung, die
[slice-134](../open/slice-134-adr-index-traegt-die-ziel-form.md) für `docs/plan/adr/` zieht, hier für die
Nachbar-Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** die Sichtung ist **offen** — sie ist vor der
Bearbeitung gegen [`observations.md`](../observations.md) zu fahren, und ihr Ergebnis gehört ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten. Sie steht hier nicht als Ergebnis, weil der Stand des
Registers zwischen Schnitt und Bearbeitung wandert.

Alle berührten Sub-Areas GF: `docs/plan/` gehört zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md). Der
Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz oben.

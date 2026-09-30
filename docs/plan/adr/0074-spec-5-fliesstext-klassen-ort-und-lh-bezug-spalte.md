# ADR-0074: Der Fließtext von Spec §5 wird nach Klassen umgebaut — Festlegung bleibt Tabellenzeile, Begründung geht in eine Sammel-ADR, Messung nach `docs/reviews/` — und die Tabellen tragen die Spalte `Präzisiert`

**Status:** Accepted

**Datum:** 2026-09-30

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (der einzige Träger des
Span-Schemas im Vertrag; Festlegung 5),
[`ADR-0013`](0013-technik-stratum-als-zielort.md) (**Accepted** — Festlegung 1 setzt §5 als Zielort,
Festlegung 2 trennt Festlegung, Begründung und Abweichung; ihr erster Re-Evaluierungs-Trigger ist für die
Abweichungen 1 und 2 eingetreten, Festlegung 3),
[`ADR-0071`](0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) (**Proposed** — bindet die Tabellenform
der Feldtabelle; Festlegung 8),
[`ADR-0015`](0015-rollen-eigentum-an-norm-artefakten.md) (Grenze der Rollen-Zuordnung; hier Festlegung 7),
[`ADR-0024`](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (der ADR-Index gehört dem
Architect),
[`ADR-0028`](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und
[`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Zeiger auf Spec-Passagen, die es nicht mehr
gibt; Festlegung 10),
[`MR-021`](../../../harness/conventions.md#mr-021) (routet die sechs erklärten Abweichungen nach §5),
[`MR-044`](../../../harness/conventions.md#mr-044) (zählt die Spalten von §5; Festlegung 5),
[`MR-015`](../../../harness/conventions.md#mr-015) (Change Request am Lastenheft),
[`MR-025`](../../../harness/conventions.md#mr-025) (Zahl neben Kommando),
[`MR-032`](../../../harness/conventions.md#mr-032) (Kopf-Marke für eine Teil-Ablösung),
[`AGENTS.md`](../../../AGENTS.md) §3.4, §3.5, §3.6, §3.7, §3.8, §3.11,
der [Klassifikationsbericht](../../reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md)
zum Fließtext von §5 samt seinem
[Review](../../reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-review.md)
und seiner
[Verifikation](../../reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-verifikation.md)
(Zeitdokumente in der stehenden Ablage `docs/reviews/`; „Einheit Unn" unten meint eine Zeile seiner
Klassifikationstabelle)

**Revidiert:** nichts. [`ADR-0013`](0013-technik-stratum-als-zielort.md) sieht den Fall selbst vor: Annahme
(*„die Feldtabelle und ihre erklärten Abweichungen sind technische Festlegungen dieses Repos und keine
Abweichungen von der Baseline"*) und erster Re-Evaluierungs-Trigger (*„erweist sich ein Teil des Bestands als
Abweichung von der Baseline statt als eigene Festlegung, bleibt **dieser** Posten im Adaptions-Block"*) halten
fest, dass ein solcher Posten im Adaptions-Block liegt und die Entscheidung für den Rest gilt. Festlegung 3
wendet diesen Trigger an; dafür braucht es keine Revision und keine Index-Annotation. Die Begründungen der
Abweichungen 3 bis 6 sind nach Festlegung 3 keine „je Abweichung geschuldete Begründung" im Sinn von
[`ADR-0013`](0013-technik-stratum-als-zielort.md) Festlegung 1; dass eine Begründung in der Entscheidung bleibt,
sagt deren Festlegung 2. Liest jemand die Einstufung von 3 bis 6 anders, ist das eine Teil-Revision und braucht eine
Folge-ADR.

**Schärft:**
[`spec/spezifikation.md §Aufnahme-Regel`](../../../spec/spezifikation.md#aufnahme-regel),
[`§5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) und
[`§3 Defaults und Konstanten`](../../../spec/spezifikation.md#3-defaults-und-konstanten)
(die Spalte `Präzisiert` trägt alle drei Tabellen). Aufwärts-Deklaration: wer diese ADR ändert, zieht diese
drei Stellen nach. Die Spec nennt diese ADR nie.

---

## Kontext

**Stand der Messungen:** die Spec am Commit `3d926f6f` (`git show 3d926f6f:spec/spezifikation.md`; der
Klassifikationsbericht misst denselben Stand). Die Spec wandert mit jedem Umbau-Schritt, darum adressiert kein
Kommando dieser ADR sie über Zeilennummern.

Der Fließtext von §5 — alles nach der Werkzeug-Tabelle bis `## 6. Externe Verträge` — misst 45889 Byte und ist
in 64 Einheiten mit 10 zweiten Zeilen klassifiziert (Klassifikationsbericht §1, §3):

```sh
git show 3d926f6f:spec/spezifikation.md | awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' | tail -n +2 | wc -c   # 45889
F=docs/reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md
awk -F'|' '/^\| U[0-9]+b? / {gsub(/ /,"",$5); n[$5]++} END{for(k in n) print k, n[k]}' $F | sort
# a 21 · b 10 · c 15 · d 12 · e 16   (74 Zeilen; Bytes und Anteile: Bericht §2)
awk -F'|' '/^\| U[0-9]+b? / && $7 ~ /Grenzfall/' $F | wc -l    # 24 Grenzfälle
```

Alle Zahlen sind Messungen zum Zeitpunkt dieser Entscheidung, keine Erwartungswerte
([`MR-025`](../../../harness/conventions.md#mr-025)). Die Klassen `a` bis `e` sind die Arbeitshypothese
des Berichts; **alle 16 Zeilen der Klasse `e` sind Wächter-Zuordnungen**
(`awk -F'|' '/^\| U[0-9]+b? / && $5 ~ /^ e / && $6 !~ /Wächter-Zuordnung/' $F` → leer).

**Fünf gemessene Widersprüche, die diese Entscheidung auflöst:**

1. **Die Spec widerspricht sich zur Abweichung.** Die Aufnahme-Regel schließt „die Abweichung von der
   adoptierten Baseline (repo-lokales Konventionsdokument)" aus §5 aus; [`MR-021`](../../../harness/conventions.md#mr-021)
   weist „die sechs erklärten Abweichungen" nach §5, und §5 führt sie. [`ADR-0013`](0013-technik-stratum-als-zielort.md)
   Festlegung 2 sagt das Gleiche wie die Aufnahme-Regel; ihre Annahme hat einen Trigger für den Fall, dass sie kippt.
2. **Die Spec trägt Messprotokolle.** Zwischen dem Kopf und der Historie stehen zwölf Zeilen mit einem Datum
   und 39 mit „gemessen" oder Datum
   (`git show 3d926f6f:spec/spezifikation.md | sed -n '4,/^## 7\. Historie/p' | grep -cE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'` → 12;
   `… | grep -cE 'gemessen|20[0-9]{2}-[0-9]{2}-[0-9]{2}'` → 39). Die Aufnahme-Regel verlangt „etwas, gegen das
   gemessen werden kann" — nicht die Messung selbst.
3. **Die Tabellen tragen keine Bindung an den Vertrag.** [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
   ist der einzige Träger im Lastenheft; im Bericht (§6.2) tragen 10 von 34 Tabellenzeilen keinen Kandidaten
   (`grep -E '^\| .SPEC-[0-9]+. .*kein LH gefunden' $F | grep -oE 'SPEC-[0-9]+' | wc -l` → 10;
   `git show 3d926f6f:spec/spezifikation.md | grep -cE '^\| .SPEC-[0-9]+. '` → 34).
4. **Die Wächter-Zuordnung steht an zwei Orten** — in der Spalte `Sensor` der Feldtabelle und als 16 Zeilen
   Fließtext (23,2 % der Bytes, Bericht §2), die die Spec selbst als unbewacht bezeichnet. Wie viele Zusicherungen
   **nur** im Fließtext stehen, ist nicht gemessen (Festlegung 12 misst es vor dem Umbau).
5. **Der Fließtext trägt Verhaltensregeln für Rollen** (Einheiten U09, U10, U11b, U15), die kein Wert, Feld oder
   Schranke sind; der Bericht führt sie als Grenzfall der Klassen `a`/`e`.

**Was der Auftraggeber gesetzt hat, und wie diese ADR es behandelt.** Jede Setzung ist geprüft; keine ist
still geändert.

| Setzung | Prüfung | Ergebnis |
|---|---|---|
| Abweichungen 3, 5, 6 betreffen den Wert („unbekannt"), keine Abweichung; Verfügbarkeit in die emittierte Feldliste, in der Spec je Fall eine kurze Zeile | `agent_role` ist in der Spec `Pflicht` (`grep -n 'SPEC-010' spec/spezifikation.md`); die Feldliste führt „Pflicht heißt: das Feld steht in jeder Zeile, auch leer" (`grep -n 'heißt: das Feld steht in jeder Zeile' internal/span/fieldlist.go`) | **übernommen** (Festlegung 3) |
| Abweichungen 1 und 2 nur nach Prüfung mögliche Adaptions-Einträge | 1: Cache-Status ist Teil des Pflicht-Minimums, die Spec führt die Zähler als `Optional` (`SPEC-024`) — „optional machen" ist nach dem Kurs die Abweichung. 2: die PR-Korrelation steht in den Mindestfeldern, die Spec führt `branch`/`commit` statt einer PR-Angabe (`SPEC-014`) | **beide echt**; ob ein Eintrag entsteht, entscheidet E1 (Festlegung 3) |
| Abweichung 4 bleibt eine Tabellenzeile | Das Modul nennt den Emissions-Pfad samt Aufbewahrung ausdrücklich eine Repo-Entscheidung (`modul-15-observability.md`, letzter Punkt von §Span-/Audit-Attribut-Regeln) | **übernommen** |
| LH-Bezug: erst [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) prüfen; Change Request nur gebündelt und nur für fehlende Anforderungen, sonst benannte Lücke | Festlegung 5 | **übernommen**; kein Change Request jetzt |
| Messprotokolle: kein neuer Ordner, `docs/reviews/` | `docs/reviews/**` steht in `.d-check.yml` bereits in den `exempt-paths` (`grep -c 'docs/reviews' .d-check.yml` → 9); keine Senkung | **übernommen, mit einer Ergänzung** (Festlegung 4: nur mit Konsument) |
| „Bewacht" gehört als Prosa nicht in die Spec | Festlegung 12 | **übernommen** |

## Entscheidung

**Wir wählen Option C: ein Klassenraster mit je einem Zielort, dazu Zuordnungsregeln für die Grenzfälle, eine
Sammel-ADR für die Begründungen und die Spalte `Präzisiert` in allen drei Tabellen.** Das Raster ist die
Entscheidungsgrundlage der Umbau-Schritte; **diese ADR schreibt keinen Spec-Text, keinen Adaptions-Eintrag und
keinen Code** — der Wortlaut folgt in eigenen Schritten mit eigenem Diff
([`ADR-0013`](0013-technik-stratum-als-zielort.md), „Diese ADR verschiebt keinen Bestand").

**Was die Annahme nicht vorentscheidet.** Die offenen Entscheidungen E1 bis E4 (unten) bleiben mit allen Optionen
offen. Jede Festlegung gilt entweder unabhängig von ihrem Ausgang, oder sie trägt die Kennung der Entscheidung
als Bedingung („falls E1 = A"). Der Ausgang wird nicht in dieser ADR nachgetragen, sondern in einer Folge-ADR
festgehalten (Re-Evaluierungs-Trigger 4).

### Festlegung 1 — das Klassenraster

Die Arbeitshypothese des Auftraggebers (Festlegung · Begründung · Messprotokoll) reicht nicht: `d` trägt
18,0 % und `e` 23,2 % der Bytes (Bericht §2). Die fünf Kommentar-Klassen aus
[`AGENTS.md`](../../../AGENTS.md) §3.7 sind **nicht** das Raster — sie ordnen einen Kommentar seinem Leser zu,
nicht einen Spec-Satz seinem Ort.

| Klasse | Kriterium | Zielort |
|---|---|---|
| **Festlegung** (`a`) | ein Wert, Feld, eine Schranke, Regel oder Fassung, **gegen die gemessen werden kann** (Aufnahme-Regel Satz 1) — auch, was das Werkzeug **nicht** liefert | Tabellenzeile mit fortlaufender `SPEC-<NNN>` und `Präzisiert`; die Wächter-Zuordnung je Festlegung 12 |
| **Begründung** (`b`) | *warum* diese Regel und nicht die andere | Sammel-ADR (Festlegung 6), nie in die Spec |
| **Messprotokoll** (`c`) | eine datierte Messung, ein Verlauf, eine Zählung des Bestands | `docs/reviews/` **oder** entfällt (Festlegung 4), nie in die Spec |
| **Abweichung** (`d`) | eine **echte** Abweichung von einer Baseline-Regel (Festlegung 3) | die Festlegung selbst bleibt Zeile; die Abweichung liegt im Adaptions-Block, falls E1 = A — bleibt in §5, falls E1 = B — entfällt, falls E1 = C |
| **Prozess-Konvention** (`p`) | wer wann was tut — kein Wert, Feld, keine Schranke | ein Ort außerhalb der Spec nach E3; bis zur Entscheidung bleibt sie unverändert in §5 (Festlegung 13) |

Keine Klasse sind: die **Wächter-Zuordnung** (Eigenschaft der Zeile, die die Zusicherung trägt — Festlegung 12),
die **Entstehungs-Erzählung** und der **Prozess-Zustand** (offene Frage, „nicht gemessen", wer trägt was). Beide
entfallen aus der Spec nach dem Wortlaut von [`MR-021`](../../../harness/conventions.md#mr-021)
(Posten 5 und 6 der Liste „Was ersatzlos entfällt"); für den Prozess-Zustand gilt R6.

### Festlegung 2 — Zuordnungsregeln und die 24 Grenzfälle

Die Grenzfälle sind am Wortlaut der Spec im Stand `3d926f6f` geurteilt (Fundstellen: Bericht §3, §4). Die übrigen
50 Zeilen (74 − 24) sind **nicht** neu zugeordnet; der Review hat 18 Einheiten stichprobenhaft gegengelesen
(Review-Bericht).

- **R1 — der Beleg folgt seiner Aussage.** Eine Zahl oder ein Datum, die eine Begründung stützen, stehen mit ihr in der
  Sammel-ADR; stützen sie eine Festlegung, ist es ein Messprotokoll (`c`) oder sie entfallen.
- **R2 — die Grenze folgt der Festlegung.** Ein „nicht zugesagt" zu einer Festlegung steht in **deren Zeile**
  (die benannte Lücke, [`AGENTS.md`](../../../AGENTS.md) §3.6: ein Strich in der Zelle des Wächters, falls E4 die Spalte
  `Sensor` behält, sonst ein Satz in der Zeile); wo keine Zeile dazugehört, ist es ein Prozess-Zustand (R6).
- **R3 — Rollen-Verhalten ist keine technische Festlegung.** Was ein Rollen-Lauf **tun soll**, ist `p`; seine
  messbare Wirkung (ein Feld, eine Bericht-Größe) bleibt `a`. Eine LH-Bindung, die der Bericht an eine solche
  Einheit hängt (U15: [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) „Benannte Grenze"),
  geht nicht verloren: die Grenze steht im Lastenheft selbst.
- **R4 — „die Quelle liefert es nicht" ist keine Abweichung.** Nur eine Abweichung von einer Regel des Moduls ist `d`.
- **R5 — die Wächter-Zuordnung gehört zur Zeile der Zusicherung.** Wie sie dort steht, regeln Festlegung 12 und E4; nie als Fließtext.
- **R6 — ein Prozess-Zustand verlässt die Spec.** Er bekommt einen Träger nur, wenn er sonst spurlos verschwände
  **und** wiederkehren kann: der Umbau-Schritt trägt ihn dann ins Beobachtungs-Register ein; sonst nennt sein
  Bericht ihn als akzeptiertes Negativ mit Grund.

| Einheit | Bericht | Klasse hier | Regel |
|---|---|---|---|
| U02b, U12, U20b, U43, U45, U49 | c | **c** | R1 |
| U04 | b/c | **b** (Beleg in der Begründung) | R1 |
| U05, U30, U35 | a/c · a/d · b/a | **a** — Messwort und Nachbarschaft entfallen | R1, R2, R4 |
| U07, U11 | c/d · c/a | **c**, Rest **a**: „Hintergrund-Läufe liefern keine Zähler" als eine Zeile | R1, R4 |
| U09, U10, U11b, U15 | a/e | **p** | R3 |
| U12b, U13 | b/c · b/a | **b**; bei U13 der Satz „der Guard entscheidet nur die Aufrufform" als **a** (Bezug: `Lücke`, Festlegung 5) | R1, R2 |
| U14, U38 | c/e · c/d | **Prozess-Zustand** (Freitext-Felder ungemessen; Nutzer-Aufruf offen); Träger entscheidet der Umbau-Schritt | R6 |
| U16 | b/a | **a** (die Grenze der Kennzahl gehört in ihre Zeile) | R2 |
| U42 | d/a | **a** (Guard, Fälle 139, 150; Bezug: `Lücke`), Begründungsanteil **b** — Abweichung 5 ist keine | R4, R5 |
| U44 | c/e | **c**; „kein Sensor prüft die Verdrahtung" als benannte Lücke in der Guard-Zeile | R1, R2 |
| U60 | e/c | **a** (neun Zusicherungen, je eine Zeile; sechs ungebunden = sechs benannte Lücken) | R2, R5 |

Bei einer Einheit mit zwei Klassen wird am **Satz** getrennt; kein Satz trägt zwei Zielorte.

### Festlegung 3 — die sechs erklärten Abweichungen

| Nr | Einstufung | Ort |
|---|---|---|
| 1 Cache-Status | **echte Abweichung** — das Feld ist `Optional`, das Pflicht-Minimum nennt den Cache-Status | `SPEC-024` bleibt Zeile; die Abweichung nach E1 |
| 2 PR-Nummer | **echte Abweichung** — die PR-Korrelation steht in den Mindestfeldern, im Schema fehlt sie | `SPEC-014` bleibt Zeile; die Abweichung nach E1 |
| 3 `agent_role` | keine — das Feld ist `Pflicht`, leer heißt unbekannt (`SPEC-010`) | Zeile |
| 4 Altbestände | keine Modul-Regel; Repo-Entscheidung über Aufbewahrung | Zeile (`make span-clean`) |
| 5 Hintergrund-Lauf ohne Verbrauchs-Achse | keine — die Quelle liefert den Wert nicht | Zeile, `Pflicht` bleibt |
| 6 Haupt-Kontext ohne Zahl | keine — dieselbe Lage | Zeile |

- **Zu 1 und 2: echt macht sie die Wahl, nicht der Wert.** Ein Feld `Pflicht` mit leerem Wert wäre
  konform; dieses Repo hat für 1 `Optional` und für 2 kein PR-Feld gewählt. Der Adaptions-Eintrag ist der
  ehrliche Ort der Wahl (E1 = A); eine Auflösung durch Code ist die Alternative (E1 = C). **Ob ein Eintrag entsteht, ist
  nicht beschlossen** — die Einstufung ist die Prüfung, die der Plan verlangt hat. Fällt E1 auf A, schreibt der Architect
  die Einträge in eigenem Commit ([`AGENTS.md`](../../../AGENTS.md) §3.8) und überholt
  [`MR-021`](../../../harness/conventions.md#mr-021) mit einer Kopf-Marke
  ([`MR-032`](../../../harness/conventions.md#mr-032)); der Eintrag wird nicht überschrieben.
- **Zu 3, 5, 6 die Wortwahl „Quelle liefert das Feld nicht".** Dieses Repo führt sie bis zu einer
  Änderung des Moduls als eigene Bezeichnung: sie steht im Satz der Zeile und ändert die Spalte `Pflicht`
  nicht. Kein Adaptions-Eintrag — sie ist keine Abweichung ([`MR-000`](../../../harness/conventions.md#mr-000)).
- **Die emittierte Feldliste trägt nicht alle Punkte** (Planner-Messung, hier gegengelesen nur am
  Pflicht-Satz): 4 ist nicht gedeckt, 1, 2 und 6 sind es teilweise. Die Ergänzung ist **Tool-Ebene**, Code-Änderung, ein
  eigener Schritt ohne Kennung (Festlegung 9); diese ADR ändert sie nicht.

### Festlegung 4 — Messprotokolle: Ort, Konsument, Form

- **Ort:** `docs/reviews/` — kein neuer Ordner. Vorbild im Bestand ist die Messreihe, auf die
  [`MR-021`](../../../harness/conventions.md#mr-021) zeigt
  ([`docs/reviews/2026-08-02-span-schema-messreihen.md`](../../reviews/2026-08-02-span-schema-messreihen.md)).
  Der Ort ist ein Zeitdokument-Ort in stehender Ablage und damit für eine eingefrorene Adresse zulässig
  ([`AGENTS.md`](../../../AGENTS.md) §3.11).
- **Ein Messprotokoll entsteht nur mit einem Konsumenten** (eine ADR, die es als Beleg nennt, oder ein Sensor,
  der es liest) — sonst kein Artefakt ([`MR-025`](../../../harness/conventions.md#mr-025)); der Rest entfällt,
  `git` hält ihn. Ob ein Klasse-`c`-Block einen Konsumenten hat, prüft der Umbau-Schritt je Block.
- **Form:** Kommando und Ausgabe, Datum und Stand des Repos, nichts als Prosa. Die vier Aussagearten, die
  „Messprotokoll" mischt, gehen so auseinander: eine **datierte Messung** und die **Zählung des Bestands** (Kommando,
  Ausgabe) → Messprotokoll oder entfällt; eine **Messung mit Folge für eine Festlegung** → die Folge wird eine
  Zeile (`a`), die Messung bleibt Beleg; eine **Nicht-Messung** → R2; sie ist nie ein eigener Absatz.
- **Die Spec zeigt nicht dorthin.** Die `matrix`-Klasse `spec-straten` verbietet den Weg nach außen
  (`{from: spec-straten, to: aussen, allow: false}` in `.d-check.yml`).
- Zur Senkungs-Frage: Festlegung 14.

### Festlegung 5 — die Spalte `Präzisiert`

- **Name und Ort:** `Präzisiert`, als **letzte** Spalte der drei Tabellen (§3, Feldtabelle, Werkzeug-Tabelle)
  und jeder neuen Tabelle von Festlegungen. Hinten, weil Spalte 2 der Feldtabelle und ihre Kopfzeile unverändert
  bleiben (Festlegung 8).
- **Wert:** ein Anker-Link auf das Lastenheft-Element (die link-policy verlangt ihn), spec-relativ, mit der Kennung als Linktext und dem Slug der Lastenheft-Überschrift als Anker
  (`lastenheft.md#…`). Das Kriterium im Element (Happy Path,
  Redaktion …) hat keinen Anker und steht daher nicht in der Zelle — es würde ohne Sensor altern. **Trägt kein
  Element die Zeile, steht `Lücke`.**
- **Abweichung von der Vorlagen-Form, und warum sie einen Eintrag braucht.** Die vendored Spezifikations-Vorlage
  führt in §3 `ID · Name · Wert · Begründung`, in §5 `ID · Span · Pflicht-Attribute · Quelle` und keine Bindung an das
  Lastenheft in einer Spalte (`.harness/baseline/v6.13.0/templates/spec/spezifikation.template.md`; die Vorlage
  verlangt „präzisieren ja, erweitern nie" im Kopf, nicht als Spalte). Für die Spalte `Sensor` hat das Repo
  genau diese Lage als Abweichung von der Vorlagen-Form eingetragen
  ([`MR-021`](../../../harness/conventions.md#mr-021) Punkt 1, [`MR-044`](../../../harness/conventions.md#mr-044)).
  `Präzisiert` ist von derselben Art; dieselbe Aussage gilt darum auch hier: **es entsteht ein Adaptions-Eintrag**
  (Folgepflicht 2), der die Spalte als Abweichung führt und [`MR-044`](../../../harness/conventions.md#mr-044) an der
  Stelle überholt, die §5 mit „fünf Spalten" zählt (Kopf-Marke, [`MR-032`](../../../harness/conventions.md#mr-032)).
  Der Eintrag gehört **vor** den Schritt, der die Spalte einführt; diese ADR schreibt ihn nicht. Er hängt an
  keinem Ausgang von E1 bis E4; E4 betrifft die Spalte `Sensor`, nicht diese.
- **Prüfung der zehn Zeilen ohne Kandidat** (`SPEC-001`, `002`, `003`, `008`, `014`, `016`, `019`, `026`,
  `027`, `028`), am Wortlaut von [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren):
  das Element emittiert den Träger der drei Observability-Blöcke *Span-/Audit-Attribute*, *Token-Attribution* und
  *Cache-Counter* (Beschreibung) und verlangt eine „geschlossene Feldliste" (Redaktion) samt „voller Pflicht-Spalte"
  (Happy Path). Was diese Sätze trennen: eine Zeile, die ein **Feld einer der drei Blöcke** oder eine Schranke
  seines Wertes ist, ist eine Präzisierung des Elements als Ganzem (nicht eines Kriteriums) — hier `SPEC-016`,
  `019`, `026`, `027`, `028` und `001`, `002` (Schranken zu `model_version`). Die `Pflicht`-Zeilen `SPEC-003`
  (`seq`) und `008` (`session`, `agent`) tragen zusätzlich die „volle Pflicht-Spalte" des Happy Path. **`SPEC-014`
  (`branch`, `commit`) ist Kandidat mit Vorbehalt:** die Korrelations-Achsen der Beschreibung nennen Slice, Anforderung,
  Entscheidung und Rolle, nicht `branch`/`commit`; die Zeile trägt nur über die „volle Pflicht-Spalte", die sie selbst
  mitdefiniert. Findet der Umbau-Schritt, der die Spalte schreibt, kein Element, das sie ohne diesen Zirkel trägt,
  steht `Lücke`. Ein Fall, in dem eine Feldzeile `Lücke` ist, ist ein Feld ohne Zugehörigkeit zu einem der drei
  Blöcke. Ebenen-Passung: §5 beschreibt den Träger, den das Zielrepo **selbst bekommt** („der Hook dieses Repos ruft
  denselben Einstiegspunkt, den ein Zielrepo bekommt", Spec §5, Gegenstand). Das ist ein **Urteil am Wortlaut**; die
  Verifikation hat nur Schlüsselwörter geprüft (Verifikationsbericht, Liefer-Punkt 3).
- **Der Ebenen-Test für alles andere.** Eine Zeile über den **Träger** — Feld, Wert, Schranke, Ableitungs-Regel des
  Werts — hat den Bezug oben. Eine Zeile über die **Verdrahtung dieses Repos** — welche Ereignisse verdrahtet sind
  samt Matcher, die Hook-Einträge, der Guard, die Start-Konvention — hat ihn nicht: sie trägt `Lücke` oder verlässt
  die Spec (E2). Die Ereignis-Menge gehört auf die Verdrahtungs-Seite, weil sie festlegt, welche Hook-Einträge den
  Träger rufen; was der Träger aus einem gerufenen Ereignis macht, ist Träger-Seite.
- **`Lücke` ist ein Übergangswert.** Die Aufnahme-Regel verlangt in Satz 2 eine Anforderung, die die Zeile
  präzisiert; eine Zeile ohne Element erfüllt ihn nicht. Nach dem Test **sicher** `Lücke`: die verdrahtete
  Ereignis-Menge samt Matcher (U20) und die Guard-Aussagen (U13, U42). **Offen** — die Ebene ist am Wortlaut nicht
  entschieden: was `SubagentStart` und „nicht erfasst" für den Träger festlegen (U21, U23), die Strom-Identität
  (U24), die Guard-Zeile der Werkzeug-Tabelle (U44) und die neun Zusicherungen (U60). Über die offenen und jede
  weitere Zeile entscheidet der Umbau-Schritt, der sie schreibt; die Größe der Menge, über die E2 entscheidet,
  steht damit erst nach dem letzten Block fest.
- **Change Request:** keiner je Zeile. Ob die `Lücke`-Zeilen gebündelt einen Change Request nach
  [`MR-015`](../../../harness/conventions.md#mr-015) bekommen, entscheidet der Auftraggeber **einmal**, nach
  dem letzten Umbau-Block (E2). Der Architect benennt die Lücke und schreibt keine Anforderung.
- **§5 als Ganzes präzisiert [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)** —
  Ja; die Spalte trägt es je Zeile, der Abschnitt braucht keinen eigenen Satz.

### Festlegung 6 — Begründungen: eine Sammel-ADR

Eine **Sammel-ADR** trägt die Begründungen (`b`) aller Blöcke von §5, geschrieben in **einem** Architect-Schritt
**vor** dem ersten Umbau, der einen Begründungstext entfernt. Damit hat kein Umbau-Schritt einen Architect-Schritt
in der Mitte. Sie prüft je Begründung per Kommando, ob eine `Accepted`-ADR sie bereits trägt; dann wird der Text
ohne neuen ADR-Text gestrichen. Ihr `Schärft:` nennt §5 als Abschnitt, weil die Zeilen ab `SPEC-035` noch nicht
existieren; die Auffindbarkeit läuft über den Gegenstands-Namen der Begründung (akzeptiertes Negativ: eine
Zeile zeigt nicht auf ihre Begründung, wie schon bisher jede Spec-Zeile nicht abwärts zeigt).

### Festlegung 7 — die schreibende Rolle von §5 bleibt offen

Diese ADR entscheidet sie **nicht**. Der offene Schritt, der die schreibende Rolle der Spec-Straten führt,
trägt einen eigenen Acceptance-Trigger, und keine Festlegung hier hängt von ihm ab: den **Inhalt** der Aufnahme-Regel
(Klassen, Spalte) setzt diese ADR, wer den Wortlaut einträgt, **kopiert** ihn. Bis dahin arbeitet der Implementer-Kontext
an §5 wie bisher, jetzt an die Form dieser ADR gebunden ([`ADR-0015`](0015-rollen-eigentum-an-norm-artefakten.md):
wo keine Quelle die Rolle benennt, bleibt die Frage offen).

### Festlegung 8 — Kollision mit dem Existenz-Sensor

Der Existenz-Sensor aus [`ADR-0071`](0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) liest die
Feldtabelle über ihre Kopfzeile und Spalte 2 (`Feld`). Zwei Bedingungen, damit nichts kollidiert:

1. **Die Spalte kommt hinten** und ändert Spalte 1 bis 5 nicht. Die Kopfzeile fängt weiter mit
   `| ID | Feld | Pflicht | Incident-Frage | Sensor |` an — der `sed`-Anker aus
   [`ADR-0071`](0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) trifft sie als Präfix
   (`grep -c '^| ID | Feld | Pflicht | Incident-Frage | Sensor |' spec/spezifikation.md` → 1, auch mit angehängter
   Spalte gegengeprobt). Fällt die Spalte `Sensor` (E4 = B), gilt die Bedingung für die verbleibenden Spalten.
2. **Die Feldtabelle trägt nur Felder.** Eine Festlegung ohne Feld-Charakter (Positiv-Liste, Splitting-Regel,
   Zusicherung) steht in einer **eigenen** Tabelle mit eigener Kopfzeile. Eine Nicht-Feld-Zeile in der Feldtabelle wäre für den
   Sensor ein Feld ohne Gegenstück im Träger und färbte ihn rot.

Ist der Sensor vor der Spalte gebaut, zieht der Schritt der Spalte seinen Parser nach; ist er danach dran, liest er die
neue Form. Keiner blockiert den anderen.

### Festlegung 9 — das emittierte Gegenstück

Die Spezifikations-Vorlage im Emit-Baum entsteht durch diese ADR **nicht**
([`ADR-0013`](0013-technik-stratum-als-zielort.md) Folgepflicht 3: die emittierte Ebene bleibt unberührt). Dogfood und
emittiert tragen verschiedene Verträge; ein Nachzug ist Tool-Ebene. Zurückgestellt ohne Adresse — es wäre ein Schritt ohne
Gegenstand, bis ein Zielrepo eine Klassen-Regel für seine Spec fordert. Dasselbe gilt für die Feldlisten-Ergänzung
aus Festlegung 3, die dagegen einen Gegenstand hat.

### Festlegung 10 — zwei Zeiger ohne Gegenstück und die Zeiger-Regel für den Umbau

- **Die zwei Zeiger** ([`ADR-0028`](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md): *„`implementer` statt
  Implementation" in §5*; [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md): sechs `CO-002`-Zeilen in zwei
  Dateien) sind **akzeptierte Negative, keine Folge-ADR.** Der erste beschreibt einen Zustand, den die Spec seit einer
  eigenen Historie-Zeile nicht mehr hat; der zweite ist ein Prüfkommando, das kein Sensor fährt. Eine Folge-ADR
  höbe nur eine Anweisung auf, die niemand mehr ausführt.
- **Für den Umbau gilt:** bevor ein Schritt eine Passage entfernt, misst er, welche eingefrorene ADR sie beim Namen
  nennt (`grep -rn '<Passagen-Name>' docs/plan/adr`), und hält den Namen als Text in der Zeile fest, die die
  Aussage übernimmt; entfällt die Aussage, steht die Lücke im Bericht des Schrittes. Kommentar-Zeiger im Code
  zieht er nach ([`AGENTS.md`](../../../AGENTS.md) §3.7); das Zeiger-Inventar des Klassifikationsberichts
  (§5) ist die Ausgangsmenge: 100 Stellen am Stand vor dieser ADR
  (`git grep -nE 'spezifikation\.md' df1dbbda^ -- internal test cmd harness/tools docs/plan/adr | wc -l`; die ADR selbst
  nennt den Dateinamen und liegt im gesuchten Baum, ein Lauf gegen den Arbeitsstand liefert mehr).

### Festlegung 11 — Schnitt-Hinweis für den Planner

- Die Umbau-Schritte schneiden nach **Block** (34 Blöcke und 64 Einheiten, Bericht §1 mit Kommando), nicht nach den
  74 Einheiten; die Einheit ist das Arbeitsraster **innerhalb** eines Schrittes (Inventar, Byte-Bilanz), nicht sein
  Zuschnitt. Ein Schritt liefert höchstens drei Punkte: Zeilen, Entfernen der Prosa, Nachzug der Zeiger.
- Vorschlag für die Reihenfolge nach dem Pilot-Block (Werkzeug-Achse und Positiv-Liste): Wächter-Liste
  („Bewacht", mechanisch, 23,2 %) · Abweichungen 2 bis 6 · Abweichung 1 samt Splitting · Start-Konvention. **Start-Bedingungen:**
  die Sammel-ADR vor jedem Schritt, der Begründung entfernt; E1 (und ein daraus folgender Adaptions-Eintrag) vor dem
  Schritt, der die Abweichungen entfernt; der Adaptions-Eintrag zur Spalte `Präzisiert` vor dem Schritt, der sie
  einführt; E4 vor dem Schritt der Wächter-Liste; E3 vor dem Schritt der Start-Konvention. Der Planner schneidet
  erst nach dem Pilot, was der Pilot gezeigt hat.

### Festlegung 12 — der Abschnitt „Bewacht"

- Die Wächter-Prosa (Test- und Fallnamen im Fließtext) entfällt. Jede Zusicherung, die nur dort steht, wird eine Zeile
  in einer Zusicherungs-Tabelle mit `SPEC-<NNN>` und `Präzisiert`. Die Wächter-Zuordnung der Zeile richtet sich nach E4:
  Spalte `Sensor` mit einem Strich für den fehlenden Wächter (E4 = A, C), oder ein Kommentar am Test und ein
  Satz zur Lücke in der Zeile (E4 = B).
- **Vor** dem Umbau misst ein Implementer je Zusicherung, ob der Test oder Fall die Zusage in Namen oder Kommentar
  trägt; wo nur der Fließtext sie führt, geht die Zuordnung als Kommentar an den Test
  ([`AGENTS.md`](../../../AGENTS.md) §3.7), sonst ginge sie verloren.
- **Gegen-Sachverhalt bleibt benannt:** kein Sensor hält die Richtung Spec → Wächter
  (die Spec sagt es selbst: „Die Nennung selbst ist unbewacht", §5 vor der Feldtabelle). Die Spalte `Sensor` bleibt,
  solange sie besteht, Feedforward.

### Festlegung 13 — die Prozess-Konventionen

Die 16 Zeilen der Klasse `e` sind Wächter-Zuordnungen und gehen in Festlegung 12 auf; sie brauchen keinen eigenen Ort.
Die vier Einheiten U09, U10, U11b, U15 (Bericht: Klasse `a`, Grenzfall `a`/`e`) sind hier `p` (R3). Wohin `p` geht,
entscheidet E3; bis dahin bleiben die Blöcke der Start-Konvention **unverändert** in §5.

### Festlegung 14 — keine Senkung

[`AGENTS.md`](../../../AGENTS.md) §3.5 gilt für diese ADR und für jeden Umbau-Schritt: `.d-check.yml` ändert sich
dadurch nicht. Messprotokolle liegen in `docs/reviews/`, das in den `exempt-paths` bereits steht
(`grep -n 'docs/reviews' .d-check.yml`); *nicht geprüft:* welches Modul welche dieser Ausnahme-Zeilen liest. E4-C
(`codepaths.roots` wächst um `test`) ist eine Verschärfung. Jede Aufnahme eines weiteren Pfads oder Paars in
`exempt-paths` oder `ignore-refs`, die ein Umbau-Schritt als Ortsentscheidung vorschlägt, ist eine Senkung und
braucht eine eigene ADR.

### Offene Entscheidungen des Auftraggebers

Sie sind keine Fait accompli. Jede trägt Optionen, die Empfehlung des Architects und den Trigger.

**E1 — Ort der echten Abweichungen (1 und 2).**

| Option | Pro | Contra |
|---|---|---|
| A — **Adaptions-Eintrag** (Empfehlung) | folgt [`ADR-0013`](0013-technik-stratum-als-zielort.md) Festlegung 2 und der Aufnahme-Regel; das Abweichungs-Register bleibt vollständig | zwei Einträge und eine Kopf-Marke an [`MR-021`](../../../harness/conventions.md#mr-021) |
| B — bleibt in §5 | [`MR-021`](../../../harness/conventions.md#mr-021) gilt wie geschrieben | die Aufnahme-Regel müsste ihren Satz „nicht hierher gehört die Abweichung" aufgeben, und [`ADR-0013`](0013-technik-stratum-als-zielort.md) Festlegung 2 widerspräche dem — beides braucht eine Folge-ADR; die Spec trüge ein Baseline-Delta |
| C — konform machen (Feld `Pflicht`, leer) | kein Eintrag nötig | Code-Änderung; ein immer leeres PR-Feld; Feldliste zieht nach |

Trigger: vor dem Umbau-Schritt, der die Abweichungen entfernt.

**E2 — Umgang mit `Lücke`-Zeilen.** (a) benannt lassen, bis der letzte Umbau-Block steht (Empfehlung: die Menge ist dann
bekannt, ein Change Request wird **einer**); (b) ein gebündelter Change Request nach
[`MR-015`](../../../harness/conventions.md#mr-015) mit dem Lastenheft als einzigem Diff; (c) die Zeile verlässt die Spec.
Trigger: der letzte Umbau-Block ist geschlossen und `grep -c '| Lücke |'` über die Spec ist nicht 0.

**E3 — Ort der Prozess-Konventionen.** (A) ein Dokument unter `docs/user/` (Rang 6; die Nutzerdoku trägt nur
den Ist-Zustand, also die geltende Regel; die Spec darf dorthin nicht zeigen) — **Empfehlung**, sofern nach dem Umbau mehrere
Blöcke derselben Art bleiben (U09, U10, U11b, U15); (B) ein Abschnitt in
[`harness/README.md`](../../../harness/README.md) (Rang 9, gewinnt gegen keine kanonische Quelle); (C) ein Adaptions-Eintrag —
**ungeeignet**, weil ein Eintrag eine Abweichung registriert und die Konvention keine ist
([`MR-000`](../../../harness/conventions.md#mr-000)); (D) sie bleibt in der Spec, und die Aufnahme-Regel erlaubt die Klasse `p`
(die Klassen-Tabelle von Festlegung 1 gälte dann ohne Ort für `p`). Jeder Ort ist Norm-Text; **welche Rolle ihn schreibt, hat
keine Quelle** (Festlegung 7). Trigger: vor dem Umbau der Start-Konvention.

**E4 — die Spalte `Sensor` gegenüber [`MR-021`](../../../harness/conventions.md#mr-021).** Sie ist eine Abweichung von der
Vorlagen-Form. (A) bleibt (Empfehlung: keine neue Mechanik, die Nennung ist in Spec und Eintrag als unbewachte
Feedforward-Spalte offengelegt); (B) fällt, die Zuordnung reist als Kommentar am Test — die Richtung Test → Spec
wäre bewachbar; (C) bleibt, und `codepaths.roots` wächst um `test` (eine Verschärfung): dann prüfte das Gate die 26 Fall-Datei-Pfade
(`git show 3d926f6f:spec/spezifikation.md | grep -oE 'test/mutations/[0-9]+-[a-z0-9-]+\.sh' | sort -u | wc -l` → 26),
**nicht** die Testnamen; *nicht gemessen*, ob das grün startet. Trigger: vor dem Umbau der Wächter-Liste.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | kein Aufwand | die fünf Widersprüche bleiben; jeder Umbau entschiede sie für sich, und der nächste Lauf liest die Spec als Quelle für alle fünf |
| B — die Drei-Klassen-Hypothese (Festlegung · Begründung · Messprotokoll) | schlank | `d` (18,0 %) und `e` (23,2 %) blieben ohne Ort; die Abweichungs-Frage bliebe offen |
| **C — Raster mit fünf Zielorten, Zuordnungsregeln, Sammel-ADR (gewählt)** | jedes Byte bekommt einen Ort; die Auftraggeber-Setzungen sind geprüft übernommen | eine Rahmen-ADR vor dem ersten Umbau; zwei Ortswechsel brauchen eigene Norm-Schritte |
| D — die fünf Kommentar-Klassen als Raster | schon eingeführt | ordnen nach Leser, nicht nach Zielort; kein Klasse-`c`-Ort |
| E — je Block eine eigene Klassen-ADR | jede ADR nennt ihre Zeilen mit Kennung | ein Architect-Schritt in der Mitte jedes Umbaus, und kein Block sieht die Regeln der anderen |

**Zu Festlegung 6 (Begründungen).** *Je Block eine ADR* nennt in `Schärft:` die neuen `SPEC-<NNN>` — aber sie braucht die
Zeilen zuerst, also drei Rollen-Wechsel in einem Umbau oder zwei Schritte je Block. *Eine Sammel-ADR* kostet die
Kennungs-genaue Rückwärts-Auffindbarkeit und einen Schritt einmal. Gewählt: Sammel-ADR.

**Zu Festlegung 5 (Bezug).** *Change Request je Zeile* verletzt die Setzung und wäre für Zeilen, die das Element trägt,
falsch; *nur benannte Lücke, kein Wert* ließe `Lücke` unsichtbar. Gewählt: Wert `Lücke`, ein Change Request einmal
gebündelt.

## Konsequenzen

- **Positiv:** die Spec-Regeln und [`MR-021`](../../../harness/conventions.md#mr-021) stehen nicht mehr gegeneinander; jede Zeile bekommt einen Anker im
  Lastenheft; ein Messprotokoll hat einen Konsumenten oder entfällt.
- **Negativ, benannt:** die Klassen-Zuordnung hält **kein** Sensor — sie ist Urteil
  ([`AGENTS.md`](../../../AGENTS.md) §3.6, Bericht §7). `Lücke`-Zeilen verletzen bis E2 die Aufnahme-Regel Satz 2.
  Die Staleness einer Zustandsaussage über ein fremdes Werkzeug (z. B. „Hintergrund-Läufe liefern keine Zähler")
  ohne Datum in der Zeile hat keinen Sensor; sie wird bei der nächsten Messung fortgeschrieben, mit einer Zeile
  in der Historie.
- **Bestand außerhalb der Umbau-Blöcke bleibt:** die Spalte `Begründung` in §3 (die Begründung der **Höhe** eines Werts,
  nicht einer Entscheidung) und Messsätze in ihren Zellen werden nicht rückwirkend geräumt; wer sie ohnehin anfasst,
  zieht sie nach.
- **Folgepflichten:** (1) Sammel-ADR-Schritt (Architect) vor dem ersten Umbau, der Begründung entfernt;
  (2) Adaptions-Eintrag zur Spalte `Präzisiert` samt Kopf-Marke an [`MR-044`](../../../harness/conventions.md#mr-044)
  (Architect, eigener Commit) vor dem Schritt, der die Spalte einführt; dazu, falls E1 = A, die Einträge zu den
  Abweichungen 1 und 2 samt Kopf-Marke an [`MR-021`](../../../harness/conventions.md#mr-021);
  (3) Tool-Ebene: Feldliste um die Verfügbarkeits-Aussage zu 3, 5, 6 (und 1, 2, 4, soweit dort etwas fehlt) — der Planner
  schneidet, eine Kennung existiert nicht;
  (4) der Wortlaut der Aufnahme-Regel und die Spalte `Präzisiert` in den drei Tabellen folgen dem Inhalt dieser ADR,
  geschrieben von dem Schritt, der sie einführt; (5) der Umbau folgt Festlegung 10 und 11.

## Fitness Function (falls maschinell prüfbar)

Jede Festlegung, die ein Rot tragen kann, hat eine Zeile; wo keines herstellbar ist, steht `keiner` mit der Lücke
([`AGENTS.md`](../../../AGENTS.md) §3.6). **Rot gesehen ist noch keine der Zeilen**; die Beobachtung liegt bei der
Verifikation dieses Schrittes bzw. des Umbau-Schritts, der die Festlegung ausführt. Wo kein Gate existiert, steht das
Messkommando, das im Umbau-Schritt als DoD-Punkt läuft — **kein Gate**, keine Senkung. Die Kommandos messen die Spec im
Arbeitsstand; die Heute-Werte messen `3d926f6f`.

| Festlegung | Tooling | Regel | rot, wenn |
|---|---|---|---|
| 4 Messung nicht in der Spec | Messkommando | `sed -n '4,/^## 7\. Historie/p' spec/spezifikation.md \| grep -cE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'` → nach dem Umbau der Blöcke 0 | heute 12; eine Datumszeile im Fließtext nach dem Umbau |
| 4 Spec zeigt nicht auf `docs/reviews/` | `make docs-check` (`matrix`) | Link aus der Spec in `docs/reviews/` meldet `matrix-forbidden` | ein Link Spec → Messprotokoll. **Lücke, nicht gefahren:** ein Code-Span-Pfad dorthin trifft `codepaths` (Ziel existiert) und bleibt grün |
| 3 Abweichung nicht in der Spec (falls E1 = A oder C) | Messkommando | `grep -c 'Abweichung [1-6]' spec/spezifikation.md` → nach dem Umbau nur die Treffer, die Festlegung 10 als erhaltenen Namen begründet | heute 17; mehr Treffer als die vor dem Schritt gemessene Liste (`grep -rn 'Abweichung [1-6]' docs/plan/adr`) |
| 5 Spalte trägt einen auflösenden Anker | `make docs-check` (`anchors`) | erfundener Anker im Link | ein Link auf `#lh-fa-10--…` mit falschem Slug. **Lücke:** eine leere Zelle meldet kein bekannter Sensor; der Schritt der Spalte fährt es und hält das Ergebnis fest |
| 5 Spalte ist in jeder der drei Tabellen die letzte | Messkommando | `grep -cE '^\| ID \|.*\| Präzisiert \|$' spec/spezifikation.md` → mindestens 3 (die drei Kopfzeilen) | 0 bis 2: die Spalte fehlt in einer Tabelle oder steht nicht hinten. **Lücke:** `anchors` meldet beides nicht |
| 5 Anker zeigt auf das richtige Element | — | **keiner** | ein auflösender, aber falscher Anker (z. B. `SPEC-003` auf ein anderes Element als [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)); `anchors` prüft Auflösung, nicht Passung — Träger ist die Review des Schrittes |
| 5 Adaptions-Eintrag zur Spalte | — | **keiner** | die Spalte steht in der Spec, ein Eintrag fehlt; kein Sensor hält Spec-Form gegen Adaptions-Block — Träger ist die Reihenfolge der Schritte (Festlegung 11) |
| 6 Begründung nicht in der Spec | — | **keiner** | ein „Warum"-Absatz in §5. Träger ist die Review des Umbau-Schritts; die Klasse `b` steht in seiner Byte-Bilanz |
| 7 schreibende Rolle bleibt offen | — | **keiner** | ein Lauf trägt den Wortlaut der Aufnahme-Regel ein und beruft sich auf diese ADR als Rollen-Quelle. Eine Nicht-Entscheidung hat kein Gegenbeispiel, das ein Sensor sähe; Träger ist der Rollen-Wechsel vor der Änderung ([`AGENTS.md`](../../../AGENTS.md) §3.8) |
| 8 Kopfzeile und Spalte 2 bleiben | Messkommando | `grep -c '^| ID | Feld | Pflicht | Incident-Frage | Sensor |' spec/spezifikation.md` → 1 | 0 (Spalte vorn eingefügt oder Kopfzeile umbenannt) |
| 8 Feldtabelle trägt nur Felder | Existenz-Sensor der Kopplungs-ADR, sobald gebaut | Feld-Token ohne Träger-Literal | eine Nicht-Feld-Zeile in der Feldtabelle; bis der Sensor besteht: Review |
| 9 Vorlage im Emit-Baum unberührt | Messkommando | `grep -rl 'Präzisiert' internal` → leer | ein Treffer, dass der Umbau die emittierte Vorlage angefasst hat. **Lücke:** der Suchbegriff deckt nur die Spalte, nicht jede Änderung der Vorlage |
| 10 Zeiger-Nachzug | Messkommando | `grep -rnE 'spezifikation\.md' internal test cmd harness/tools \| wc -l` gegen das Inventar des Berichts | ein Kommentar nennt eine entfernte Passage. **Lücke:** kein Test bricht, der Sensor ist das Inventar |
| 11 Schnitt-Hinweis | — | **keiner** | ein Umbau-Schritt mit mehr als drei Liefer-Punkten; der Hinweis ist ein Vorschlag, Träger ist die Größenregel im Plan-Review |
| 12 Wächter-Prosa entfällt | Messkommando (Block unter der Tabelle) | nach dem Umbau 0 Zeilen (Tabellenzeilen ausgenommen) | heute 38 (Stand `3d926f6f`); ein Test- oder Fallname im Fließtext nach dem Umbau. **Lücke:** der Anker `SPEC-034` wandert, wenn Zeilen hinzukommen — der Schritt passt ihn an |
| 13 Start-Konvention bleibt bis E3 | Messkommando | `grep -c 'START-KONVENTION' spec/spezifikation.md` → gleich dem Wert vor dem Umbau | ein Schritt entfernt oder ändert die Start-Konvention vor E3 |
| 14 keine Senkung | Messkommando | `git log --oneline <Annahme-Commit>..HEAD -- .d-check.yml` → leer oder je Commit mit ADR-Kennung | ein Commit an `exempt-paths`/`ignore-refs` ohne ADR |
| 1, 2 Klassen-Zuordnung | — | **keiner** | eine falsch zugeordnete Einheit; die Zuordnung ist Urteil, Träger ist der Reviewer |
| Immutabilität nach Annahme | `make adr-immutable` | Kern einer `Accepted`-ADR über der Range unverändert | eine inhaltliche Änderung an dieser ADR nach `Accepted` |

Kommando zu Festlegung 12 (Fließtext ohne Tabellenzeilen, Test- oder Fallname):

```sh
awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' spec/spezifikation.md | grep -v '^|' | grep -cE 'test/|_test\.go|Fall [0-9]+|\.bats'
```

## Re-Evaluierungs-Trigger

- **Wenn der Pilot-Umbau eine Einheit findet, die keine der fünf Klassen trägt** *(feedforward — Beobachtung im Bericht
  des Schrittes)*: das Raster ist neu zu wägen, per Folge-ADR mit `supersedes`, nicht durch stillschweigende Erweiterung.
- **Wenn der Kurs das Modul 15 um eine Kennzeichnung „Quelle liefert das Feld nicht" ergänzt** *(feedforward — ein
  Baseline-Sprung)*: die Wortwahl aus Festlegung 3 entfällt oder folgt dem Wortlaut des Moduls.
- **Wenn die schreibende Rolle der Spec-Straten entschieden ist** *(feedforward)*: Festlegung 7 schließt.
- **Wenn E1 bis E4 entschieden sind** *(feedforward)*: der Ausgang steht in einer Folge-ADR — diese ADR ist ab
  `Accepted` unveränderlich —, und die bedingten Folgen der Festlegungen 1, 2, 8, 12 und 13 gelten in der entschiedenen Form.
- **Wenn der Existenz-Sensor gebaut ist und mit der Spalte rot bleibt** *(computational feedback)*: Festlegung 8 ist
  falsch gelesen und wird per Folge-ADR gezogen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-30 | Proposed | Architect-Schritt zur Entscheidung der Klassen, des Ortes der Messprotokolle und der Spalte `Präzisiert` |
| 2026-09-30 | Accepted | Entscheidung des Auftraggebers; die offenen Entscheidungen E1–E4 sind damit nicht getroffen |

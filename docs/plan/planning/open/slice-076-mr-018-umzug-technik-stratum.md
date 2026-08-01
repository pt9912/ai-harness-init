# Slice slice-076: Das Span-Schema zieht ins Technik-Stratum, der Adaptions-Eintrag wird aufgehoben

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) **Bündel?** Nein — ein Bestand, seine Zielorte und die Aufhebung seines heutigen Trägers
landen zusammen oder gar nicht; es gibt keinen zweiten Slice, der mitlanden müsste.
(2) **Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift der DoD.
(3) **Reaktiv oder gewollt?** **Reaktiv:** Auslöser sind eine Messung am vorhandenen Eintrag und
eine bereits gefallene Zielort-Entscheidung, nicht der Wunsch nach einer Fähigkeit. Damit **nicht**
in der Roadmap geführt
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2) — der Zustand ist das Verzeichnis.

**Nicht welle-09.** Deren Closure-Kriterium ist die 4 × 2-Matrix über die vier Regelblöcke des
Observability-Moduls, und ihre Zellen tragen einen **Wert** — Sensor, deklariert, ADR-Verdikt,
emittiert, nicht emittiert. Dieser Slice ändert keinen Zellen-Wert: er ändert das **Dokument**, in
dem der Wert steht. Der Anlass-Ort ist geteilt, die Regel-Familie nicht.

**Bezug:**
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (die Entscheidung, die diesen Slice
auslöst: Zielort ist das Technik-Stratum, und ihre Folgepflicht 1 verlangt genau das Inventar
unten),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (Festlegung 1 — die Feldtabelle
gehört nicht in eine ab *Accepted* immutable Entscheidung; ihre Zielort-Setzung aus Folgepflicht 1
ist teil-revidiert),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (der eine Posten, dessen Trichter
*permanent* ergab und der den Eintrag bereits verlassen hat),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(der Eintrag selbst — Gegenstand, nicht Quelle),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(das Gefäß und seine Form; zugleich das Vorbild dafür, wie ein akzeptierter Eintrag aufgehoben
wird, ohne ihn anzufassen),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (*„keine inhaltlichen
Adaptionen ggü. Baseline-Default"* — die Aussage, unter der die Disziplin-Regel der vendored
Vorlage hier bindet),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Kennung → klickbarer Anker),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(die vendored Vorlage ist die einzige Quelle der Ziel-Form),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate über leerem Prüfbereich — die Grenze, an der die Sensor-Frage unten gemessen wird),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Verschieben und Ändern sind zwei Commits — hier in der
Sache), §3.4 (ADRs sind ab Accepted immutabel), §3.5 (Gates nicht ohne ADR lockern — die Grenze,
an der der aufgehobene Rumpf stehen bleibt), §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel — der Grund, warum die Wächter-Bindung nicht ersatzlos entfallen darf).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-01.

---

## 1. Ziel

**Jeder Satz aus
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) steht
danach an dem Ort, dessen Gegenstand er ist — die Feldtabelle und die je Abweichung geschuldete
Begründung in [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 —, und der Eintrag
wird **aufgehoben**, nicht geändert.**

Das ist ein **Umzug**, kein Rückschnitt: die Größe des Eintrags ist das Symptom, seine
Zuständigkeit die Ursache.
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) hat genau diese Trennung entschieden
und die Größen-Antwort ausdrücklich verworfen (Option D: *„es behandelt die Größe, nicht die
Zuständigkeit"*).

### Ist-Messung (Arbeitsbaum 2026-08-01, `7e496a9`, Baum sauber; jede Zahl mit ihrem Kommando)

Die Blockgrenze ist überall dieselbe: von der Eintrags-Überschrift bis zur Zeile vor der nächsten
Überschrift derselben oder höherer Ebene. Ein Muster `^## [^M]` scheitert an
`## Modus-Deklaration` und misst 839 statt 824 — der Ausdruck unten fängt beide Grenzen.

| Größe | Kommando | Wert |
|---|---|---|
| Blockgrenzen | `grep -nE '^### MR-[0-9]{3}\|^## Modus-Deklaration' harness/conventions.md` | 835 … 1658 |
| Umfang des Eintrags | `awk 'NR>=835&&NR<=1658' harness/conventions.md \| wc -l -c` | **824 Z / 70.727 B** |
| Datei gesamt | `wc -l -c harness/conventions.md` | 1.723 Z / 142.162 B |
| Anteil des einen Eintrags | 824 / 1723 · 70.727 / 142.162 | **47,8 % der Zeilen, 49,8 % der Bytes** |
| die übrigen **19** Einträge | je Block über denselben Ausdruck, `wc -l -c` | 851 Z / 68.459 B; min 443 B · Median 3.589 B · **max 7.991 B** |
| Verhältnis | 824 gegen 851 Z · 70.727 gegen 68.459 B | auf der **Zeilen**-Achse **kleiner**, auf der **Byte**-Achse **größer** als die übrigen 19 zusammen |
| Unterüberschriften im Eintrag | `awk 'NR>=835&&NR<=1658' … \| grep -cE '^#{1,6} '` | **1** (die eigene) |
| Das Modul, dessen Abweichungen er festhält | `wc -l -c .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` | **97 Z / 6.135 B** |

**Der Befund ist die Kurve, nicht die Momentaufnahme.** Über die 26 Commits, die den Eintrag
tragen (`git log --format=%h --reverse -- harness/conventions.md`, je Commit die Blockgrenzen neu
gemessen), wuchs er in vier Tagen von **47 auf 824 Zeilen**: 47 · 61 · 146 · 179 · 180 · 180 ·
187 · 194 · 197 · 206 · **199** · 280 · 280 · 308 · 335 · 399 · 405 · 459 · 529 · 617 · 619 ·
677 · 735 · 774 · 824 · 824 — **21 Schritte aufwärts, 3 seitwärts, 1 abwärts** (und der eine
abwärts misst 7 Zeilen). Ein zu weiter Satz wird hier nicht ersetzt, er bekommt einen
einschränkenden Absatz daneben.

**Was seit dem 2026-07-28 sonst noch wuchs:** die Datei ging von 823 auf 1.723 Zeilen, die Zahl
der Einträge von 18 auf 20. **Kein Eintrag wurde je entfernt** (`git log` über alle 30 Stände,
`grep -cE '^### MR-'` je Stand: 16 · … · 20, monoton) — die Disziplin-Regel ist also gelebt, aber
nirgends geschrieben: `grep -c '<!--' harness/conventions.md` → **0**, die Vorlage trägt sie in
einem HTML-Kommentar, den die Kopie nicht mitgenommen hat.

### Wohin die Posten gehen: ein Kriterium, sechs Zielorte

**Das Kriterium in einem Satz:** *Ein Satz geht an den Ort, dessen Gegenstand er ist — was er
aussagt, entscheidet, nicht wo er heute steht.* Die Aufnahme-Regel des Stratums
([`spec/spezifikation.md`](../../../../spec/spezifikation.md#aufnahme-regel)) ist der Test für die
ersten zwei Zeilen; die übrigen folgen aus
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 2.

| Art des Satzes | Zielort | Bestand (gemessen) |
|---|---|---|
| technische Festlegung, die mit ihrem Gegenstand wächst | [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) **§5** | Feldtabelle 29 Z / 7.193 B · Werkzeug-Tabelle 17 Z / 1.851 B · Abweichungs-Block 295 Z / 23.672 B |
| Wert, der als Schranke oder Default fest ist | [`spec/spezifikation.md`](../../../../spec/spezifikation.md#3-defaults-und-konstanten) **§3** | die strukturelle Schranke um `model_version` (Länge ≤ 64, geschlossener Zeichensatz), heute in der 62-Zeilen-Positiv-Liste |
| Inhalt des Regelwerks, nacherzählt | **Link** ins Modul | **19 der 28** Modul-Nennungen der Datei stehen in diesem Eintrag (`grep -oE 'Modul[- ][0-9]{1,2}'`, 67,9 % — 9 × *Modul 15*, 3 × *Modul-15*, 5 × *Modul 7*, 1 × *Modul-7*, 1 × *Modul 8*); **0** zeigen auf ein Modul |
| Abweichung von der adoptierten Baseline | **ein neuer Eintrag** im Adaptions-Block | posten-weise vom Inventar zu entscheiden — [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) legt diese Frage ausdrücklich hierher (Re-Evaluierungs-Trigger 1) |
| Prozess-Zustand (wer trägt, was ist offen) | **Plan** — §6 dieses Slice, nicht der Eintrag | 9 Slice-Nennungen (`grep -oE 'slice-[0-9]+'`), 4 verschiedene (059 · 060 · 066 · 068) |
| datierte Messung | **Zeitdokument** unter `docs/reviews/` (dort der etablierte Ort: von `ids` und `codepaths` ausgenommen) | **49 Zeilen** mit Datums-Stempel, 51 Vorkommen |

**Zwei Nicht-Zielorte, damit die Tabelle nicht als vollständig gelesen wird.** *Ersatzlos* geht die
Entstehungs-Erzählung: **20 Zeilen** nennen einen Review- oder Verifier-Befund (21 Vorkommen),
**18 Zeilen** tragen die Formel *„bis <Datum> stand hier …"* / *„frühere Fassung"* /
*„Vorgänger"*. Und **keine neue ADR:** der Pfad ist offen und zweimal begangen
([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md)), aber von den sechs Abweichungen hat
genau eine den Trichter *permanent* erreicht, und sie ist übergeführt. Dieser Slice **setzt** den
Trigger und **löst ihn nicht aus**.

### Wie der Eintrag schrumpfen darf: gar nicht — er wird aufgehoben

Die vendored Vorlage
(`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
Adaptions-Block) schreibt vor: *„Disziplin: chronologisch nummeriert, keine nachträglichen
inhaltlichen Änderungen an akzeptierten Einträgen — nur neue Einträge oder explizite Aufhebungen
via neuen MR."* 800 Zeilen herauszunehmen ist eine solche Änderung.
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) erklärt *„keine
inhaltlichen Adaptionen ggü. Baseline-Default"*; die Regel bindet also.

**Der Weg ist der, den die Vorlage wörtlich nennt: ein neuer Eintrag hebt
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
auf; der Eintrag selbst bleibt Byte für Byte stehen.** Das ist der Weg, den dieses Repo an beiden
Ebenen schon gegangen ist:
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
hebt die 2-Strata-Klausel aus
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) auf und lässt jenen
*„unangetastet"*; [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) revidiert eine
Folgepflicht aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), ohne ein Byte an ihr
zu ändern.

**Der Präzedenzfall der ADR-Ebene trägt hier nur zur Hälfte, und der fehlende Teil ist der
Träger.** [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) kann die Reichweite in den
**ADR-Index** schreiben, weil es ihn gibt (`docs/plan/adr/README.md`, Statusspalte mit
Teil-Revisions-Annotation an drei Einträgen). Der Adaptions-Block **hat keinen Index** — auf
`## Adaptions-Block` folgt unmittelbar der erste Eintrag. Die Reichweite kann deshalb nur im
**aufhebenden Eintrag** stehen, und der steht rund 800 Zeilen unter seinem Gegenstand. Dafür sind
beide in **derselben Datei**, während [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)
und [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) zwei Dateien sind — der Index war
dort die einzige Verbindung, hier ist es die Leserichtung.

**Der Preis, benannt statt geschlossen:** wer nur
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) liest,
liest Überholtes — und zwar 824 Zeilen davon, in dem Dokument, das jede Agenten-Sitzung mitliest.
Die Feldtabelle steht danach an zwei Orten, von denen nur einer bindet. Dieselbe Kante hat
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) für eine Folgepflicht benannt; hier ist
sie drei Größenordnungen größer. **Den Rumpf zu entfernen wäre eine Lockerung der
Disziplin-Regel und damit ein ADR** ([`AGENTS.md`](../../../../AGENTS.md) §3.5), kein Nebeneffekt
dieses Slice — Trigger in §6.

### Zwei Fehlzuordnungen im heutigen Text — verschiedener Art, darum verschieden behandelt

**(a) Die Überschrift des Abweichungs-Blocks nennt einen Regelblock für Posten aus dreien.** Das
*Pflicht-Minimum* des Moduls hat vier Posten: Slice-ID · Agent-Rolle · Cache-Status ·
`requirement.id`. Am Rumpf gelesen treffen **1** (Cache-Status) und **3** (`agent_role`) es —
zwei von vier. **2** (PR-Nummer) kommt aus den *Mindestfeldern eines Tool-Call-Spans*
(*„Korrelations-IDs zu Slice/PR/Agent-Rolle"*), einer anderen Liste desselben Moduls; **5**
(Hintergrund-Lauf ohne Verbrauchs-Achse) und **6** (Haupt-Kontext ohne Zahl) aus den
*Token-Attributions-Regeln*. Drei Regelblöcke unter der Überschrift eines einzigen. Das ist eine
**Korrektur am Wortlaut** und fährt **nicht** im Umzugs-Diff mit (§3).

**(b) Abweichung 4 weicht von gar keiner Modul-Regel ab.** *„Altbestände werden beim ersten Span
einer Sitzung NICHT entfernt"* — ihr erster Satz nennt
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 3 als die Quelle, von der
sie abweicht: Aufbewahrung statt Schema, und ein anderes Dokument. Das ist **keine Korrektur**,
sondern eine **Zielort-Frage**, und
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) legt sie ausdrücklich in dieses
Inventar. Sie fährt mit, weil sie *der Umzug* ist.

### Wo die Sensor-Bindung lebt

Der Eintrag bindet Zusicherungen an namentlich genannte Wächter: **10** Test-Funktionen und **30**
Fälle aus `test/mutations/` (`grep -oE 'Test[A-Za-z0-9_]+' | sort -u` bzw.
`grep -oE 'test/mutations/[0-9]+' | sort -u`; **alle 30 existieren**, je Nummer gegen
`ls test/mutations/<n>-*.sh` geprüft, 0 fehlend). Sie stehen in zwei Bullets über **274 Zeilen**
(15 + 259).

**Die Bindung selbst ist eine technische Festlegung, die mit ihrem Gegenstand wächst — sie trifft
die Aufnahme-Regel und geht als vierte Spalte in die §5-Tabelle** (Feld · Pflicht ·
Incident-Frage · **Sensor**). Was die 274 Zeilen so groß macht, geht **nicht** mit: die Zeilen- und
Datumsangaben, wo genau ein Wächter fiel, sind datierte Messung (`docs/reviews/`), die
Review-Befund-Herkunft ist Entstehungs-Erzählung (ersatzlos).

**Zwei Kosten, beide zu nennen.**
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
deklariert für §5 heute die **Drei**-Spalten-Gestalt als *„einzige Abweichung von der
Vorlagen-Form"*. Eine vierte Spalte ist eine **weitere** Abweichung und gehört deshalb in den
Adaptions-Block — genau in den aufhebenden Eintrag, und damit ist derselbe Vorgang zugleich der
Beleg, dass der Adaptions-Block nach dem Umzug wieder seinen Gegenstand hat. Auch hier gilt die
Disziplin-Regel: jener Eintrag wird nicht angefasst, sein *„einzige"* wird überholt.

Zweitens: **welcher Sensor die Spalte hält, ist abgeleitet und nicht gemessen.**
`codepaths.roots` in `.d-check.yml` sind `[spec, docs, harness]`; `test/` steht dort **nicht** (und
`internal/` ebenso wenig — das ist am 2026-07-31 gemessen und im Eintrag festgehalten). Ob eine
Referenz auf `test/mutations/…` heute überhaupt validiert wird, ist damit offen und steht als
erste Nachmessung in §3. Der Umzug ändert daran nichts: Quell- und Zielpfad liegen beide in
`roots`.

## 2. Definition of Done

- [ ] **(1) Der Zielort trägt den Bestand.**
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  führt die Feldtabelle in der vom Observability-Modul verlangten Gestalt plus die Sensor-Spalte,
  die Werkzeug-Tabelle und je erklärter Abweichung eine Begründung;
  [§3](../../../../spec/spezifikation.md#3-defaults-und-konstanten) die Werte, die als Schranke
  fest sind. Der bindende Text trägt **keine** Entscheidungs- und keine Planungs-Kennung
  ([`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 3; gemessen von der
  `matrix`-Klasse `spec-straten`). **Keine Nennung eines Regelwerks-Moduls ohne auflösenden
  Link** — im umgezogenen Text wie im neuen Eintrag. `make docs-check` grün.
- [ ] **(2) Der Eintrag wird aufgehoben, nicht geändert.** Ein **neuer** Eintrag im
  Adaptions-Block (die nächste freie Nummer) hebt
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  auf, nennt je Posten-Art den Zielort, trägt was nach dem Inventar Regelwerks-Delta bleibt, nennt
  die Disziplin-Regel der vendored Vorlage als seine Quelle und benennt den Preis (wer nur den
  aufgehobenen Eintrag liest, liest Überholtes). Gemessen: `git diff` zeigt an den Blockgrenzen
  835 … 1658 **null** geänderte Bytes.
- [ ] **(3) Kein Posten verschwindet still, keine Zusage verliert ihren Sensor.** Das Kriterium
  aus §1 wird posten-weise angewandt und als Vorher/Nachher-Inventar in §3 fortgeschrieben; jeder
  Posten trägt seinen Zielort oder das Verdikt *ersatzlos* mit Grund. Jede der **10**
  Wächter-Funktionen und jeder der **30** Mutations-Fälle steht danach in der Sensor-Spalte oder an
  einem benannten Ort — **nachgezählt gegen die Ist-Zahlen aus §1**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6), nicht behauptet.
- [ ] `make gates` grün; `make mutate` grün über die CI (`.github/workflows/ci.yml`, frischer
  Runner).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | §5 und §3 nehmen den Bestand auf (DoD 1) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | **nur** der neue Eintrag am Ende des Adaptions-Blocks (DoD 2) — der aufgehobene bleibt unberührt |
| `docs/reviews/` | neu | das Zeitdokument, das die 49 datierten Mess-Zeilen aufnimmt |
| [`AGENTS.md`](../../../../AGENTS.md) | update | die `span-check`-Zeile der Gate-Tabelle nennt heute den aufgehobenen Eintrag als Quelle des Schemas und zeigt danach auf das Stratum |

**Die Commit-Folge ist tragend, und sie trennt Verschieben von Ändern**
([`AGENTS.md`](../../../../AGENTS.md) §3.3 in der Sache):

1. **Inventar** — jeder Posten mit Art und Zielort, bevor eine Zeile bewegt wird. Sonst
   entscheidet die Reihenfolge des Lesens, was überlebt.
2. **Umzug** — der Bestand geht **wörtlich** an seinen Zielort. Fällt dabei eine Aussage als
   falsch auf, wird sie **benannt**, nicht mitkorrigiert.
3. **Aufhebung** — der neue Eintrag. Erst jetzt, weil er die Zielorte nennen muss.
4. **Korrektur** — Fehlzuordnung (a) aus §1: je Abweichung ihr wirklicher Regelblock. Eigener
   Commit mit eigener Message; sonst ist im Ergebnis eine Korrektur nicht von einer Entfernung zu
   unterscheiden.

**Was die Umsetzung zuerst nachmisst** (Modul 9 §4), weil jede Zahl aus §1 mit dem nächsten Commit
altert:

1. **Die Blockgrenzen und alle Größen neu**, gegen denselben Ausdruck. Die Kurve in §1 ist der
   Beleg, dass Wachstum zwischen Schnitt und Umsetzung der Normalfall ist.
2. **Ob `codepaths` eine Referenz unter `test/` überhaupt prüft.** `roots` sind
   `[spec, docs, harness]`; die Aussage in §1 ist aus dieser Zeile **abgeleitet**. Eine Sonde ist
   billiger als eine Annahme — und die Antwort entscheidet, ob die Sensor-Spalte einen Sensor hat
   oder nur einen Namen.
3. **Die Anker-Form der Modul-Überschriften.** Die Zeiger aus DoD (1) zielen auf Abschnitte, deren
   Anker-Slug ungeprüft ist; ein `anchor-missing` ist billiger zu messen als zu raten.
4. **Ob eine Aussage des Eintrags im Bestand nur dort steht.** Der Umzug darf keine Regel
   verlieren, die nirgends sonst geschrieben ist.

## 4. Trigger

**`open` → `next`:** [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) ist **Accepted**.
Das ist eine echte Abhängigkeit und keine Reihung: der Zielort dieses Umzugs ist die Setzung jener
Entscheidung, und sie steht auf *Proposed*. Ein Umzug gegen eine noch nicht angenommene
Zielort-Setzung liefe Gefahr, zweimal zu laufen.

**Keine Abhängigkeit von [slice-075](slice-075-regelwerk-verweis-linkpflicht.md) — in keiner
Richtung, und der Grund hat sich mit dem Umzugs-Schnitt gedreht.** Solange dieser Slice ein
Rückschnitt war, hätte slice-075 19 Stellen verlinkt, die hier verschwinden. Als **Umzug** bleibt
der aufgehobene Eintrag Byte für Byte stehen; slice-075s Bestand von **19 der 28** Stellen ist
davon unberührt. Umgekehrt schafft slice-075 die **Pflicht** zum Link, nicht die **Möglichkeit** —
die besteht heute (`scan.ignore` prunt, *was gescannt wird*, nicht, *was aufgelöst wird*). Der
Zeiger muss deshalb hier schon ein auflösender Link sein: das ist eine **Auflage an den Text**
(DoD 1), keine Reihenfolge.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls Umzug und Aufhebung nicht in **einer** Review-Sitzung prüfbar sind
  (Modul 5 §Ziel-Form). Die Naht ist benannt und der Schnitt danach billig: sie verläuft zwischen
  Schritt 2 und Schritt 3 der Commit-Folge. Der Grund, es zunächst als **einen** Schnitt zu führen,
  ist die Doppelführung: zwischen Umzug und Aufhebung bindet die Feldtabelle an zwei Orten, und
  kein Sensor sieht das.
- `in-progress` → `open`: falls das Inventar einen Posten findet, dessen Zielort eine Entscheidung
  verlangt, die dieser Slice ausdrücklich nicht trifft (§6). Dann ist erst zu entscheiden, wohin er
  gehört.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün
und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der aufgehobene Rumpf bleibt stehen, und das ist der teuerste Punkt dieses Slice.** 824 Zeilen
  überholter Text in dem Dokument, das jede Sitzung mitliest, und die Feldtabelle an zwei Orten.
  Ihn zu entfernen ist eine **Lockerung der Disziplin-Regel** und damit ein ADR
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5), kein Nebeneffekt hier. **Trigger:** die erste
  gemessene Divergenz zwischen dem Rumpf und
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 — oder der Abschluss dieses
  Slice, je nachdem was zuerst eintritt. Bis dahin ist die Doppelführung benannt und unbewacht.
- **Die Größe ist nach dem Umzug eine eigene Frage mit eigener Begründung.** Eine Schranke über
  Adaptions-Einträge misst Größe, nicht Zuständigkeit; sie hier als Mittel des Umzugs zu benutzen
  wäre genau die Option, die
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) verworfen hat. Der Messwert für einen
  späteren Schnitt steht in §1 (Maximum der übrigen Einträge 7.991 B); die Begründung müsste er
  selbst liefern.
- **Zwei Abweichungen sind durch den Modul-7-Trichter nicht gelaufen.** Der Eintrag sagt es selbst:
  2 und 4 tragen weder Auflösungs-Trigger noch Verdikt. Sie zu führen ist eine **inhaltliche**
  Entscheidung; dieser Slice ist ein **Umbau**. Der offene Zustand wandert aus dem Eintrag hierher
  und von hier an einen eigenen Schnitt — er verschwindet nicht.
- **[slice-075](slice-075-regelwerk-verweis-linkpflicht.md) braucht eine Nachmessung, in zwei
  Punkten, und beide sind gemessen.** (1) Seine Klassen-Tabelle kennt `spec/**` nicht — heute zu
  Recht: `git ls-files 'spec/*.md' | xargs grep -ohE 'Modul[- ][0-9]{1,2}' | wc -l` → **0**. Nach
  diesem Umzug trägt [`spec/spezifikation.md`](../../../../spec/spezifikation.md) Modul-Nennungen,
  und die Klasse ist zu entscheiden (einbezogen oder ausgenommen mit Trigger). (2) Sein §6 nennt
  für den Eintrag *839 Zeilen, 50 % der Datei* „gemessen am letzten committeten Stand"; gemessen
  sind **824 Zeilen** — 49,3 % an dem Stand, den er zitiert, und **47,8 %** heute. Beide Korrekturen
  gehören in dessen nächste Berührung, nicht in diesen Schnitt.
- **Der Quellen-Konflikt um die Teil-Revision ist gemeldet und wird hier nicht behoben.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 kennt nur den Voll-Supersede; die Kurs-Fassung derselben
  Hard Rule kennt *„der abgelösten **oder geschärften** Vorgängerin"*, und das Repo hat den Weg
  viermal begangen (ADR-Index-Annotationen an drei Einträgen,
  [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
  an [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). Die Textänderung ist
  eine eigene Entscheidung.
- **Dogfood und emittiert sind hier verschieden.** Ein gebootstrapptes Ziel bekommt
  `harness/conventions.md` **und** `spec/spezifikation.md` aus derselben vendored Vorlage — was es
  nicht bekommt, ist unser Bestand.
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Folgepflicht 3 hält fest, dass sich
  an der Emission **nichts** ändert; dieser Slice bewegt sie nicht.
- **Nicht in diesem Slice:** die Entfernung des aufgehobenen Rumpfs · eine Größen-Schranke über
  Adaptions-Einträge · die inhaltliche Prüfung der sechs Abweichungen · eine neue ADR · die
  Linkpflicht als **Regel** ([slice-075](slice-075-regelwerk-verweis-linkpflicht.md) — dieser Slice
  setzt Links, er erzwingt sie nicht) · der Prüfbereich und die Bindungs-Schärfe des
  Mutations-Sensors ([slice-069](slice-069-zahn-bindet-zusicherung.md),
  [slice-070](slice-070-comment-claims-pruefbereich.md)) · die emittierte Ebene und
  [slice-073](slice-073-emittierte-doc-gate-module.md) · der Inhalt der übrigen 19 Einträge · die
  Textänderung an [`AGENTS.md`](../../../../AGENTS.md) §3.4. Ob
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  ins Stratum gehört, entscheidet **nicht** dieser Slice, sondern die Aufnahme-Regel bei der
  nächsten Berührung jenes Eintrags — hier wird sie nur an einem Gegenstand geübt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
[`spec/`](../../../../spec/spezifikation.md), [`harness/conventions.md`](../../../../harness/conventions.md)
und `docs/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

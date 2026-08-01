# Slice slice-076: Der Span-Eintrag trägt die Form, die das Observability-Modul vorschreibt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) **Bündel?** Nein — ein Eintrag, seine Zielorte und seine Schranke landen zusammen oder gar
nicht; es gibt keinen zweiten Slice, der mitlanden müsste. (2) **Gemeinsames Closure-Kriterium?**
Nein — jedes denkbare wäre die Abschrift der DoD. (3) **Reaktiv oder gewollt?** **Reaktiv:**
Auslöser ist eine Messung am vorhandenen Eintrag, nicht der Wunsch nach einer Fähigkeit. Damit
**nicht** in der Roadmap geführt
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2) — der Zustand ist das Verzeichnis.

**Nicht welle-09.** Deren Closure-Kriterium ist die 4 × 2-Matrix über die vier Regelblöcke des
Observability-Moduls, und ihre Zellen tragen einen **Wert** — Sensor, deklariert, ADR-Verdikt,
emittiert, nicht emittiert. Dieser Slice ändert keinen Zellen-Wert: er ändert die **Form**, in der
der Wert *deklariert* geschrieben steht. Der Anlass-Ort ist geteilt, die Regel-Familie nicht.

**Bezug:**
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(der Eintrag selbst — Gegenstand, nicht Quelle),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (*„keine inhaltlichen
Adaptionen ggü. Baseline-Default"* — die Aussage, unter der die Disziplin-Regel der vendored
Vorlage bindet, ohne dass ein Eintrag sie erwähnt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Kennung → klickbarer Anker, und die Linie „Gate-*Anheben* → Steering-Loop", unter der die
Schranke aus DoD (3) läuft),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(die vendored Vorlage ist die einzige Quelle der Ziel-Form — auch der des Eintrags selbst),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (Folgepflicht 1: die Feldtabelle
gehört in den Adaptions-Block und nicht in die immutable ADR — die Zuständigkeit, die dieser
Slice nicht verschiebt),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (der eine Posten, der den
Eintrag bereits verlassen hat — das Vorbild für den ADR-Pfad),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate über leerem Prüfbereich — die Grenze, an der die Schranke gemessen wird),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Verschieben und Ändern sind zwei Commits — hier in der
Sache: zwei Arbeitsschritte), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel — der Grund,
warum die Wächter-Bindung nicht ersatzlos entfallen darf).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-01.

---

## 1. Ziel

**[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
trägt die Attribut-Tabelle, die das Observability-Modul vorschreibt, und je Abweichung eine
Begründung — und zeigt für alles Übrige auf das Modul, statt es nachzuerzählen.**

### Ist-Messung (Arbeitsbaum 2026-08-01, jede Zahl mit ihrem Kommando)

Die Blockgrenze ist überall dieselbe: von der Eintrags-Überschrift bis zur Zeile vor der nächsten
Überschrift derselben oder höherer Ebene.

| Größe | Kommando | Wert |
|---|---|---|
| Umfang des Eintrags | `grep -nE '^### MR-[0-9]{3}\|^## Modus-Deklaration' harness/conventions.md`, Differenz der zwei Grenzzeilen | **864 Z / 73.995 B** |
| … im letzten committeten Stand | dasselbe über `git show HEAD:harness/conventions.md` | **824 Z** |
| Datei gesamt | `wc -l harness/conventions.md` | 1713 Z (committet 1673) |
| Anteil des einen Eintrags | 864 / 1713 | **50,4 %** (committet 49,3 %) |
| Das Modul, dessen Abweichungen er festhält | `wc -l -c .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` | **97 Z / 6.135 B** |
| Unterüberschriften im Eintrag | `awk 'NR>=835&&NR<=1698' harness/conventions.md \| grep -cE '^#{1,6} '` | **1** (die eigene Überschrift) |
| die übrigen 18 Einträge, Bytes | Blockgrenzen wie oben, je Block `wc -c` | min 443 · Median 3.149 · **max 7.991** · Summe **64.490** |
| Verhältnis | 73.995 gegen 64.490 | **der eine Eintrag ist größer als die achtzehn anderen zusammen** |
| längste Zeile im Eintrag | `awk 'NR>=835&&NR<=1698{print length($0)}' … \| sort -rn \| head -1` | **1.389 Zeichen** |
| längste Zeile im ganzen übrigen Adaptions-Block | dasselbe über `NR>=34&&NR<=834` | **352 Zeichen** |

**Der Befund ist die Kurve, nicht die Momentaufnahme.** Über die 25 Commits, die den Eintrag
tragen (`git log --format=%h --reverse -- harness/conventions.md`, je Commit die Blockgrenzen neu
gemessen), wuchs er in vier Tagen von **47 auf 824 Zeilen**: 47 · 61 · 146 · 179 · 180 · 180 ·
187 · 194 · 197 · 206 · **199** · 280 · 280 · 308 · 335 · 399 · 405 · 459 · 529 · 617 · 619 ·
677 · 735 · 774 · 824 — **21 Schritte aufwärts, 2 seitwärts, 1 abwärts**. Ein zu weiter Satz wird
hier nicht ersetzt, er bekommt einen einschränkenden Absatz daneben.

### Die Ziel-Form ist vorgeschrieben — aus zwei Quellen

**Erstens die vendored Vorlage** (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`,
Kommentar über dem Adaptions-Block): jeder Eintrag trägt *„ID, Datum, Geltungsbereich, Adaption,
Begründung, Auflösungs-Trigger (oder ‚permanent')"*. Gemessen führt der Eintrag **drei** davon als
Feld (`Datum`, `Geltungsbereich`, `Auflösungs-Trigger`); `Adaption` und `Begründung` fehlen
(`grep -cE '^- \*\*Adaption' harness/conventions.md` → 15 im Bestand, 0 im Eintrag;
`^- \*\*Begründung` → 10 im Bestand, 0 im Eintrag). Der längste Eintrag des Repos führt die zwei
Felder nicht, in denen stehen soll, worum es geht.

**Zweitens das Modul** ([`modul-15-observability.md`](../../../../.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md)),
das die Gestalt des Feldes `Adaption` selbst vorgibt: *„liste jeden Attribut-Namen, markiere ihn
als Pflicht oder Optional und nenne pro Attribut die Incident-Frage, die es beantwortet"* — eine
Tabelle mit drei Spalten. Zur Abweichung sagt es genau einen Satz: *„jede Abweichung davon
begründest du."* Eine Begründung, keine Abhandlung.

**Daraus die Zielgröße, abgelesen statt geschätzt:** 26 Attributzeilen plus Tabellenkopf (28) ·
Werkzeug-Tabelle mit sechs Zeilen plus Kopf und Vorspann (10) · die fünf Kopf-Felder (8) · je
Abweichung 3–5 Zeilen (18–30) · Auflösungs-Trigger (2) · Leerzeilen (~10). **Erwartung ~80
Zeilen, Band 60–120** — auf der Byte-Achse rund 7.000 B und damit unterhalb des heutigen
Maximums von 7.991 B.

**Die zwei anderen Formvorgaben des Moduls gelten hier nicht.** Die Vier-Zeilen-Form je
Cache-Counter (Name · Unit · Labels · Aggregation) und die Fünf-Felder-Form je Doku-Drift-Regel
betreffen Metriken und den Doku-Konsistenz-Agenten; der Geltungsbereich dieses Eintrags sind die
Spans. Sie sind Gegenstand anderer Slices der Konformitäts-Welle, nicht dieses.

### Zwei Fehlzuordnungen im heutigen Text

**(a) Die Überschrift des Abweichungs-Blocks nennt einen Regelblock für Posten aus dreien.** Das
*Pflicht-Minimum* des Moduls hat vier Posten: Slice-ID · Agent-Rolle · Cache-Status ·
`requirement.id`. Zuordnung der sechs Abweichungen am Rumpf gelesen: **1** (Cache-Status) und
**3** (`agent_role`) treffen es — zwei von vier Posten. **2** (PR-Nummer) kommt aus den
*Mindestfeldern eines Tool-Call-Spans* (*„Korrelations-IDs zu Slice/PR/Agent-Rolle"*), einer
anderen Liste desselben Moduls. **5** (Hintergrund-Lauf ohne Verbrauchs-Achse) und **6**
(Haupt-Kontext ohne Zahl) kommen aus den *Token-Attributions-Regeln*. **4** (Altbestände werden
nicht entfernt) weicht **von gar keiner Modul-Regel ab**: ihr eigener erster Satz nennt
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 3 als die Quelle, von der
sie abweicht — Aufbewahrung statt Schema, und ein anderes Dokument.

**(b) Das Modul führt zwei Minimum-Listen, die sich unterscheiden.** *Mindestfelder eines
Tool-Call-Spans*: `tool.name` · `tool.arguments` (redacted) · `tool.result.status` +
Korrelations-IDs zu Slice/PR/Agent-Rolle. *Pflicht-Minimum*: Slice-ID · Agent-Rolle ·
Cache-Status · `requirement.id`. Gemeinsam sind ihnen Slice und Agent-Rolle; PR steht nur in der
ersten, Cache-Status und `requirement.id` nur in der zweiten. Sechs Abweichungen aus drei
Regelblöcken stehen heute unter der Überschrift eines einzigen.

### Wohin die ~750 Zeilen gehen: ein Kriterium, fünf Zielorte

**Das Kriterium in einem Satz:** *Ein Satz bleibt, wenn er eine heute bindende Regel über die
Erfassung ist — was erfasst wird, ob Pflicht oder Optional, welche Incident-Frage er beantwortet
und welcher Sensor ihn hält.* Alles andere geht an den Ort **seiner Art**:

| Art | Zielort | Bestand (gemessen) |
|---|---|---|
| bindende Regel | **bleibt** — Feldtabelle, Werkzeug-Tabelle, je Abweichung eine Begründung | Zielgröße oben |
| Inhalt des Regelwerks, nacherzählt | **Link** ins Modul | 19 der 28 Modul-Nennungen der Datei stehen in diesem Eintrag (`grep -oE 'Modul[- ][0-9]{1,2}'`, 68 %); 0 zeigen heute auf ein Modul |
| Bindung Zusage ↔ Sensor | **Sensor-Spalte** der Feldtabelle | 10 Wächter-Funktionen, 30 Mutations-Fälle namentlich genannt (`grep -oE 'test/mutations/[0-9]+' \| sort -u \| wc -l`) |
| Herleitung einer **permanenten** Abweichung | **ADR** (ablösend, nie ein wachsender Registereintrag) | 1 Posten ist diesen Weg gegangen ([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md)); für die übrigen fünf ist er nicht eröffnet |
| Prozess-Zustand (wer trägt, was ist offen) | **Plan** — dieser Slice §6, nicht der Eintrag | 10 Slice-Nennungen im Eintrag (`grep -oE 'slice-[0-9]+'`), 5 verschiedene |
| datierte Messung | **Zeitdokument** unter `docs/reviews/` (dort schon der etablierte Ort: von `ids` und `codepaths` ausgenommen) | 49 Zeilen mit Datums-Stempel, 51 Vorkommen |
| Entstehungs-Erzählung | **ersatzlos** | 17 Zeilen „Review-Befund", 3 „Verifier-Befund", dazu die formlose Masse ohne Datum |

**Was der Link kostet und warum er heute schon trägt.** `scan.ignore` in `.d-check.yml` prunt,
**was gescannt wird**, nicht, **was aufgelöst wird** — ein Link in den vendored Baum wird von
`links` und `anchors` geprüft. Der Eintrag kann seine Zeiger also **jetzt** setzen; was
[slice-075](slice-075-regelwerk-verweis-linkpflicht.md) hinzufügt, ist die **Pflicht** dazu und
ihr Zahn, nicht die Möglichkeit. Die Reihenfolge steht in §4.

### Die Bremse: die Regel existiert bereits und hat keinen Sensor

Dieselbe vendored Vorlage schreibt über dem Adaptions-Block: *„Disziplin: chronologisch
nummeriert, **keine nachträglichen inhaltlichen Änderungen an akzeptierten Einträgen** — nur neue
Einträge oder explizite Aufhebungen via neuen MR."*
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) erklärt *„keine
inhaltlichen Adaptionen ggü. Baseline-Default"*; die Regel bindet hier also. Gemessen:
`grep -niE 'nachträglich|append-only|akzeptierten Eintr' harness/conventions.md` findet **keine**
Stelle, die sie erwähnt, befolgt oder abbedingt — und die Kurve oben zählt 21 Verstöße in vier
Tagen an einem einzigen Eintrag. Die Bremse ist damit **keine Erfindung dieses Slice**, sondern
eine adoptierte Regel, die ihren Feedback-Quadranten bekommt.

**Mechanisch ist sie erreichbar, und das ist der entscheidende Messwert:** eine Schranke, unter
der **alle 18** übrigen Einträge heute liegen, existiert — ihr Maximum ist 7.991 B. Es braucht
also **keine** Bestandsliste, keinen Grandfather-Eintrag und keinen Cutoff-Commit; die Schranke
ist ab dem ersten Lauf fail-closed und für jeden künftigen Eintrag gleich streng. Sie liegt auf
der **Byte**-Achse, weil die Zeilen-Achse durch Umbruch umgehbar ist und der Bestand die Umgehung
bereits zeigt (1.389 gegen 352 Zeichen).

## 2. Definition of Done

- [ ] **(1) Der Eintrag trägt die vorgeschriebene Form und zeigt auf das Modul, statt es
  nachzuerzählen.** Die fünf Kopf-Felder der Vorlage stehen (heute fehlen `Adaption` und
  `Begründung`); das Feld `Adaption` ist die Attribut-Tabelle in der vom Modul verlangten Gestalt;
  dazu die Werkzeug-Tabelle und **je Abweichung eine** Begründung. Die Überschrift des
  Abweichungs-Blocks nennt die Regelblöcke, aus denen ihre Posten stammen, statt eines für alle,
  und der Posten aus §1 (a), der von keiner Modul-Regel abweicht, steht unter seiner echten
  Quelle. **Keine Nennung eines Regelwerks-Moduls ohne auflösenden Link.** Gemessen: der Eintrag
  liegt unter der Schranke aus (3); `make docs-check` grün.
- [ ] **(2) Kein Posten verschwindet still — jeder hat seinen Zielort, und der Zielort trägt
  ihn.** Das Kriterium aus §1 wird posten-weise angewandt und als Vorher/Nachher-Inventar in §3
  fortgeschrieben. **Keine Zusage verliert ihren Sensor** ([`AGENTS.md`](../../../../AGENTS.md)
  §3.6): jede der 10 genannten Wächter-Funktionen und jeder der 30 genannten Mutations-Fälle steht
  danach in der Sensor-Spalte oder an einem benannten Ort — **nachgezählt gegen die Ist-Zahlen aus
  §1**, nicht behauptet. **Verschieben ohne Ändern** ([`AGENTS.md`](../../../../AGENTS.md) §3.3 in
  der Sache): der Wortlaut einer bindenden Aussage wird beim Umzug nicht mitkorrigiert; eine
  Aussage, die dabei als falsch auffällt, wird **benannt** und in §6 an einen Folge-Slice gegeben.
- [ ] **(3) Der Wiederaufbau wird sichtbar, bevor er wieder 800 Zeilen groß ist.** Ein
  hermetisches `make`-Target misst jeden `### MR-NNN`-Block in Bytes und wird über einer Schranke
  rot, die aus der gemessenen Verteilung folgt und **ohne Bestandsliste** auskommt. Ein Fall in
  `test/mutations/` färbt es rot, indem er einen Eintrag über die Schranke wachsen lässt; die
  Gegenrichtung — **ohne** das Target bleibt `make gates` grün, obwohl der Eintrag zu groß ist —
  gehört in denselben Beleg. Ein **neuer** Eintrag im Adaptions-Block deklariert die Schranke und
  nennt die Disziplin-Regel der vendored Vorlage als ihre Quelle; er entsteht als neuer Eintrag,
  nicht als Absatz in einem bestehenden — das ist dieselbe Regel, angewandt auf sich selbst.
- [ ] `make gates` grün; `make mutate` grün über die CI (`.github/workflows/ci.yml`, frischer
  Runner).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | refactor | der Rückschnitt aus DoD (1)/(2) und der neue Eintrag aus DoD (3) |
| `harness/tools/` | neu | das Mess-Skript der Schranke (Layout nach [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)) |
| [`Makefile`](../../../../Makefile) | update | das Target und sein Eintrag in `gates` |
| `test/` | neu | bats-Test des Skripts + der Fall aus DoD (3) |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | die Gate-Tabellen führen jedes Target; der Vertrag wächst hier, also wächst die Zeile mit |
| `docs/reviews/` | neu | das Zeitdokument, das die datierten Messungen aufnimmt (Zielort 5 aus §1) |

**Die Reihenfolge innerhalb des Slice ist tragend, und sie ist nicht die bequeme.** Zuerst der
Rückschnitt, dann die Schranke: umgekehrt wäre das Target an seinem eigenen Artefakt rot und
bräuchte genau die Bestandsliste, gegen die §1 argumentiert. Innerhalb des Rückschnitts zuerst
das **Inventar** (jeder Posten mit Art und Zielort), dann der Umzug — sonst entscheidet die
Reihenfolge des Lesens, was überlebt.

**Was die Umsetzung zuerst nachmisst** (Modul 9 §4), weil jede Zahl aus §1 mit dem nächsten
Commit altert:

1. **Die Blockgrenzen und alle Größen neu**, gegen denselben Ausdruck. Der Eintrag ist zwischen
   Schnitt und Umsetzung nachweislich gewachsen — die Kurve in §1 ist der Beleg dafür, dass das
   der Normalfall ist.
2. **Die Schranke gegen die dann geltende Verteilung.** Sie muss über dem Maximum der übrigen
   Einträge liegen und darf keine Bestandsliste brauchen; ist das nicht mehr der Fall, ist die
   Schranke neu zu begründen und nicht stillschweigend zu heben.
3. **Die Anker-Form der Modul-Überschriften.** Die Zeiger aus DoD (1) zielen auf Abschnitte, deren
   Anker-Slug ungeprüft ist; ein `anchor-missing` ist billiger zu messen als zu raten.
4. **Ob eine Aussage des Eintrags im Bestand nur hier steht.** Der Umzug darf keine Regel
   verlieren, die nirgends sonst geschrieben ist — die Sensor-Spalte belegt das für die
   bewachten, die Nachzählung aus DoD (2) für die übrigen.

## 4. Trigger

**`open` → `next`:** **keine Slice-Abhängigkeit** — aber **eine Bedingung am Baum**: die heute
nicht committete Änderung an
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) ist
committet oder verworfen. Sie behebt zwei Aussagen genau in dem Text, den dieser Slice umbaut;
läuft der Rückschnitt über sie hinweg, ist im Diff eine **Korrektur** nicht von einer
**Entfernung** zu unterscheiden, und der Review kann DoD (2) nicht prüfen. Ihr Inhalt ist in der
Ziel-Form nicht mehr nötig — beide Stellen liegen vollständig in Text, den der Rückschnitt
auflöst —, aber ihre zwei korrigierten Aussagen gehören wie jeder andere Posten an ihren Zielort,
nicht in den Papierkorb. Dieser Slice **fasst sie nicht an**.

**Ausdrücklich keine Abhängigkeit von [slice-075](slice-075-regelwerk-verweis-linkpflicht.md)
oder [slice-072](slice-072-adr-verweist-nicht-auf-lifecycle.md), und die Richtung ist die
umgekehrte.** slice-075 §6 hält fest, der Link müsse stehen, **bevor** die Nacherzählung durch
einen Zeiger ersetzt werden kann. Das trifft als **Auflage an den Text dieses Slice** zu — der
Zeiger muss ein auflösender Link sein und keine bare Nennung — und **nicht** als Reihenfolge:
slice-075 schafft die **Pflicht** zum Link, nicht die **Möglichkeit**; die besteht heute (§1,
letzter Absatz vor der Bremse). Umgekehrt ist die Abhängigkeit real und gemessen: **19 der 28**
Modul-Nennungen der Datei liegen in diesem einen Eintrag. Läuft slice-075 zuerst, verlinkt er 19
Stellen, die dieser Slice danach löscht, und seine Bestands-Tabelle ist falsch; läuft dieser
zuerst, schrumpft slice-075s Bestand auf die neun Stellen außerhalb plus die wenigen Zeiger der
Ziel-Form — genau die Nachmessung, die slice-075 §3 sich selbst schon aufgibt. Hinzu kommt:
slice-075 wartet seinerseits auf slice-072 (den `docs-check`-Modus des Mutations-Treibers), dieser
Slice auf nichts.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls Rückschnitt und Schranke nicht in **einer** Review-Sitzung prüfbar
  sind (Modul 5 §Ziel-Form). **Die Naht ist benannt und der Schnitt danach billig:** sie verläuft
  dort, wo der Rückschnitt endet und `harness/tools/` beginnt. Nach dem Rückschnitt liegt jeder
  Eintrag unter der Schranke — der Folge-Slice bräuchte also weiterhin **keinen** Bestandsschutz.
  Der Grund, es zunächst als einen Schnitt zu führen, ist [`AGENTS.md`](../../../../AGENTS.md)
  §3.6: ohne (3) bliebe die Zusage aus (1) für die ganze Liegezeit unbewacht, und die gemessene
  Wachstumsrate beträgt 21 Schritte in vier Tagen.
- `in-progress` → `open`: falls das Inventar aus §3 einen Posten findet, dessen **einziger**
  möglicher Zielort eine Entscheidung verlangt, die dieser Slice ausdrücklich nicht trifft (§6,
  erster Punkt). Dann ist erst zu entscheiden, wohin er gehört, bevor der Eintrag schrumpft.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün
und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Zwei Abweichungen sind durch den Trichter nicht gelaufen, und dieser Slice läuft sie nicht.**
  Der Eintrag sagt es heute selbst: Abweichung 2 und 4 tragen weder Auflösungs-Trigger noch
  Verdikt. Sie durch den Modul-7-Trichter zu führen ist eine **inhaltliche Entscheidung**, dieser
  Slice ist ein **Umbau** — die zwei zu mischen ist genau die Vermengung, gegen die
  [`AGENTS.md`](../../../../AGENTS.md) §3.3 steht. Der offene Zustand wandert deshalb aus dem
  Eintrag hierher und geht von hier an einen eigenen Schnitt; er verschwindet nicht.
- **Der ADR-Pfad wird nicht eröffnet.**
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) ist Accepted und damit immutabel
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4) — dorthin kann nichts verschoben werden, und eine
  ablösende ADR entsteht nur für eine Abweichung, deren Trichter *permanent* ergibt. Von den
  sechs hat das genau eine erreicht
  ([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md), bereits übergeführt). Dieser
  Slice **setzt den Trigger** — wessen Trichter *permanent* ergibt, bekommt eine ADR statt eines
  wachsenden Registereintrags — und **löst ihn nicht aus**.
- **Die Sensor-Spalte ist eine Abweichung von der Modul-Form und muss als solche begründet
  werden.** Das Modul verlangt drei Spalten; die vierte kommt aus
  [`AGENTS.md`](../../../../AGENTS.md) §3.6, weil die Pflicht-Spalte eine Zusage ist. Sie ist die
  einzige Stelle, an der die Bindung überhaupt noch bewacht sichtbar wäre: `make comment-claims`
  deckt vier Pfad-Muster **ohne** `_test.go` und **kein** Markdown — die Bindung in Testdateien,
  Fall-Köpfen oder im Adaptions-Block liegt in allen drei Fällen außerhalb jedes Sensors. Ob ein
  Fall die *genannte* Zusicherung bindet, entscheidet
  [slice-069](slice-069-zahn-bindet-zusicherung.md); der Prüfbereich von `comment-claims` ist
  [slice-070](slice-070-comment-claims-pruefbereich.md). Beide bleiben, wo sie sind.
- **Eine Byte-Schranke misst Größe, nicht Güte.** Sie fängt den gemessenen Mechanismus (Anbau
  statt Ersatz) und fängt **nicht** einen Eintrag, der knapp darunter falsch ist, und **nicht**
  den Umzug von Prosa in eine andere Datei. Das ist benannt, nicht geschlossen; die Gegenkraft
  bleibt [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  — die Schranke rechtfertigt sich über einen belegten Nutzen, nicht über Strenge.
- **Dogfood und emittiert sind hier verschieden, und die Vorlage-Annahme trägt nicht.** Ein
  gebootstrapptes Ziel bekommt sehr wohl ein `harness/conventions.md` — es steht in der
  Singleton-Liste der Emission (`internal/emit/templates_test.go`) und entsteht aus derselben
  vendored Vorlage, mit vier Beispiel-Einträgen und einem leeren `### MR-NNN`-Gerüst. Was es
  **nicht** bekommt, ist unser Eintrag. Für die Schranke heißt das: sie bleibt **Dogfood-only**.
  Grund: welche Regeln des Observability-Moduls ins Ziel gehen, entscheidet slice-062, und welche
  Doc-Gate-Module das Ziel bekommt, entscheidet
  [slice-073](slice-073-emittierte-doc-gate-module.md) — beides sind fremde Schnitte, und ein
  emittiertes Target vorwegzunehmen hieße, den Adopter-Vertrag ohne Change Request zu bewegen
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  **Auflösungs-Trigger:** slice-062 liegt in `done/`.
- **Eine Zahl in einem lebenden Plan ist falsch und gehört korrigiert, aber nicht von hier.**
  [slice-075](slice-075-regelwerk-verweis-linkpflicht.md) §6 nennt für den Eintrag *839 Zeilen*
  „gemessen am letzten committeten Stand"; gemessen sind **824** (`git show HEAD:` plus dieselben
  Blockgrenzen wie in §1 — an allen drei ungepushten Commits derselbe Wert). Die dort ebenfalls
  genannten 295 Zeilen des Abweichungs-Blocks stimmen für denselben Stand. Die Korrektur ist eine
  Zeile in einem fremden Plan und gehört in dessen nächste Berührung, nicht in diesen Schnitt.
- **Nicht in diesem Slice:** die inhaltliche Prüfung der sechs Abweichungen · eine neue ADR · der
  Prüfbereich oder die Bindungs-Schärfe des Mutations-Sensors (slice-069/070) · die emittierte
  Ebene · der Inhalt der übrigen 18 Einträge (die Schranke bindet sie, sie schneidet sie nicht) ·
  die Linkpflicht als Regel (slice-075) — dieser Slice setzt die Links, er erzwingt sie nicht.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
[`harness/conventions.md`](../../../../harness/conventions.md), `harness/tools/`,
[`Makefile`](../../../../Makefile) und `test/` gehören zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

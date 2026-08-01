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
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (die Entscheidung, die den
Verbleib des aufgehobenen Rumpfs regelt und deren Bedingungen DoD 2 bindet),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (Festlegung 1 — die Feldtabelle
gehört nicht in eine ab *Accepted* immutable Entscheidung; ihre Zielort-Setzungen aus den
Folgepflichten 1 und 2 sind teil-revidiert),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (der eine Posten, dessen Trichter
*permanent* ergab und der den Eintrag bereits verlassen hat),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(der Eintrag selbst — Gegenstand, nicht Quelle),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(das Gefäß und seine Form; zugleich der Präzedenzfall einer **Teil**-Aufhebung, bei der der Rumpf
gerade stehen bleibt),
[`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
(die Form, die der aufgehobene Eintrag danach hat: Nummer, Überschrift, `Datum`, Zeiger-Zeile),
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
Sache), §3.4 (ADRs sind ab Accepted immutabel), §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel — der Grund, warum die Wächter-Bindung nicht ersatzlos entfallen darf).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-01.

---

## 1. Ziel

**Jeder Satz aus
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) steht
danach an dem Ort, dessen Gegenstand er ist — die Feldtabelle und die je Abweichung geschuldete
Begründung in [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 —, und der Eintrag
wird **aufgehoben**: von ihm bleiben Nummer, Überschrift und ein Zeiger, den Rumpf trägt `git`.**

Das ist ein **Umzug**, kein Rückschnitt: die Größe des Eintrags ist das Symptom, seine
Zuständigkeit die Ursache.
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) hat genau diese Trennung entschieden
und die Größen-Antwort ausdrücklich verworfen (Option D: *„es behandelt die Größe, nicht die
Zuständigkeit"*).

### Ist-Messung (Stand `b39d4ff`, auf den Commit gepinnt; jede Zahl mit ihrem Kommando)

Die Blockgrenze ist überall dieselbe: von der Eintrags-Überschrift bis zur Zeile vor der nächsten
Überschrift derselben oder höherer Ebene. Ein Muster `^## [^M]` scheitert an
`## Modus-Deklaration` und lässt den **letzten** Eintrag bis zum Dateiende laufen — der Ausdruck
unten fängt beide Grenzen.

| Größe | Kommando | Wert |
|---|---|---|
| Blockgrenzen | `grep -nE '^### MR-[0-9]{3}\|^## Modus-Deklaration' harness/conventions.md` | 835 … 1658 |
| Umfang des Eintrags | `awk 'NR>=835&&NR<=1658' harness/conventions.md \| wc -l -c` | **824 Z / 70.727 B** |
| Datei gesamt | `wc -l -c harness/conventions.md` | 1.767 Z / 145.563 B |
| Anteil des einen Eintrags | 824 / 1767 · 70.727 / 145.563 | **46,6 % der Zeilen, 48,6 % der Bytes** |
| die übrigen **20** Einträge | je Block über denselben Ausdruck, `wc -l -c` | 895 Z / 71.860 B; min 443 B · Median 3.369 B · **max 7.991 B** |
| Verhältnis | 824 gegen 895 Z · 70.727 gegen 71.860 B | auf **beiden** Achsen knapp kleiner als die übrigen 20 zusammen — die Zahl kippt mit jedem neuen Eintrag, das Argument dieses Slice hängt nicht an ihr |
| Unterüberschriften im Eintrag | `awk 'NR>=835&&NR<=1658' … \| grep -cE '^#{1,6} '` | **1** (die eigene) |
| Das Modul, dessen Abweichungen er festhält | `wc -l -c .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` | **97 Z / 6.135 B** |

**Der Befund ist die Kurve, nicht die Momentaufnahme.** Über die 28 Commits, die den Eintrag
tragen (`git log --format=%h --reverse -- harness/conventions.md`, je Commit die Blockgrenzen neu
gemessen), wuchs er in vier Tagen von **47 auf 824 Zeilen**: 47 · 61 · 146 · 179 · 180 · 180 ·
187 · 194 · 197 · 206 · **199** · 280 · 280 · 308 · 335 · 399 · 405 · 459 · 529 · 617 · 619 ·
677 · 735 · 774 · 824 · 824 · 824 · 824 — **21 Schritte aufwärts, 5 seitwärts, 1 abwärts** (und
der eine abwärts misst 7 Zeilen). Ein zu weiter Satz wird hier nicht ersetzt, er bekommt einen
einschränkenden Absatz daneben.

**Was seit dem 2026-07-28 sonst noch wuchs:** die Datei ging von 823 auf 1.767 Zeilen, die Zahl
der Einträge von 18 auf 21. **Kein Eintrag wurde je entfernt** (`git log` über alle 70 Stände der
Datei, `grep -cE '^### MR-'` je Stand: 1 · … · 21, monoton). Die Disziplin-Regel selbst lebt in
einem HTML-Kommentar der vendored Vorlage, den die Kopie nicht mitgenommen hat
(`grep -c '<!--' harness/conventions.md` → **0**); im Repo trägt sie
[`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf).

### Wohin die Posten gehen: ein Kriterium, sechs Zielorte

**Das Kriterium in einem Satz:** *Ein Satz geht an den Ort, dessen Gegenstand er ist — was er
aussagt, entscheidet, nicht wo er heute steht.* Die Aufnahme-Regel des Stratums
([`spec/spezifikation.md`](../../../../spec/spezifikation.md#aufnahme-regel)) ist der Test für die
ersten zwei Zeilen — sie nehmen **beide** Zielort-Setzungen auf, die
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 1 revidiert hat: Feldtabelle
**und** Abweichungs-Begründung. Die übrigen Zeilen folgen aus deren Festlegung 2.

| Art des Satzes | Zielort | Bestand (gemessen) |
|---|---|---|
| technische Festlegung, die mit ihrem Gegenstand wächst | [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) **§5** | Feldtabelle 29 Z / 7.193 B · Werkzeug-Tabelle 17 Z / 1.851 B · Abweichungs-Block 295 Z / 23.672 B |
| Wert, der als Schranke oder Default fest ist | [`spec/spezifikation.md`](../../../../spec/spezifikation.md#3-defaults-und-konstanten) **§3** | die strukturelle Schranke um `model_version` (Länge ≤ 64, geschlossener Zeichensatz), heute in der 62-Zeilen-Positiv-Liste |
| Inhalt des Regelwerks, nacherzählt | **Link** ins Modul | **19 der 28** Modul-Nennungen der Datei stehen in diesem Eintrag (`grep -oE 'Modul[- ][0-9]{1,2}'`, 67,9 % — 9 × *Modul 15*, 3 × *Modul-15*, 5 × *Modul 7*, 1 × *Modul-7*, 1 × *Modul 8*); **0** zeigen auf ein Modul |
| Abweichung von der adoptierten Baseline | **ein neuer Eintrag** im Adaptions-Block | posten-weise vom Inventar zu entscheiden — [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) legt diese Frage ausdrücklich hierher (Re-Evaluierungs-Trigger 1) |
| Prozess-Zustand (wer trägt, was ist offen) | **Plan** — §6 dieses Slice, nicht der Eintrag | 9 Slice-Nennungen (`grep -oE 'slice-[0-9]+'`), 4 verschiedene (059 · 060 · 066 · 068) |
| datierte Messung | **Zeitdokument** unter `docs/reviews/` (dort der etablierte Ort: von `ids` und `codepaths` ausgenommen) | **49 Zeilen** mit Datums-Stempel, 51 Vorkommen — darunter die rot-gesehen-Nachweise, Gegenproben und Messreihen, die [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Bedingung (b) **nicht** deckt, weil sie keine bindende Aussage sind |

**Zwei Nicht-Zielorte, damit die Tabelle nicht als vollständig gelesen wird.** *Ersatzlos* geht die
Entstehungs-Erzählung: **19 Zeilen** nennen einen Review- oder Verifier-Befund
(`grep -cE '(Review|Verifier)-Befund'`, 20 Vorkommen), **14 Zeilen** tragen die Formel
*„bis <Datum> …"* / *„frühere Fassung"* / *„Vorgänger"*
(`grep -cE 'bis (zum )?20[0-9]{2}-[0-9]{2}-[0-9]{2}|[Ff]rühere Fassung|Vorgänger'`, 15
Vorkommen). Und **keine neue ADR:** der Pfad ist offen und dreimal begangen
([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)), aber von den sechs Abweichungen hat
genau eine den Trichter *permanent* erreicht, und sie ist übergeführt. Dieser Slice **setzt** den
Trigger und **löst ihn nicht aus**.

### Wie der Eintrag schrumpfen darf: gar nicht — der Kopf bleibt, der Rumpf geht

Die vendored Vorlage
(`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
Adaptions-Block) schreibt vor: *„Disziplin: chronologisch nummeriert, keine nachträglichen
inhaltlichen Änderungen an akzeptierten Einträgen — nur neue Einträge oder explizite Aufhebungen
via neuen MR."* Ob das Entfernen des Rumpfs die verbotene Änderung oder der Vollzug der erlaubten
Aufhebung ist, entscheidet dieser Satz nicht;
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) entscheidet es.
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) erklärt *„keine
inhaltlichen Adaptionen ggü. Baseline-Default"*; die Regel bindet also.

**Der Weg: ein neuer Eintrag hebt
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
vollständig auf, und von jenem bleiben Nummer, Überschrift wörtlich, `Datum` und eine
Zeiger-Zeile — den Rumpf trägt `git`** —
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 1, im
Adaptions-Block als
[`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
geführt. Die zwei Präzedenzfälle des Repos sind **Teil**-Aufhebungen und tragen darum nur bis zur
Hälfte:
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
hebt die 2-Strata-Klausel aus
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) auf und lässt jenen
*„unangetastet"* — nach
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Bedingung (a) zu Recht, weil
sein Rest bindet; [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) revidiert zwei
Folgepflichten aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), ohne ein Byte an
ihr zu ändern — dort gilt [`AGENTS.md`](../../../../AGENTS.md) §3.4 unberührt weiter.

**Der Adaptions-Block hat keinen Index** — auf `## Adaptions-Block` folgt unmittelbar der erste
Eintrag —, und er braucht keinen: die Zeiger-Zeile steht im Kopf von
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) selbst,
also dort, wo der Leser ankommt. Der **ADR-Index** (`docs/plan/adr/README.md`, Statusspalte mit
Teil-Revisions-Annotation an drei Einträgen) ist die Antwort auf ein anderes Problem:
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) und
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) sind zwei Dateien, hier stehen
Aufheber und Aufgehobenes in derselben.

**Der Preis, benannt statt geschlossen:** wer den Rumpf lesen will, braucht die Historie, und kein
Sensor sagt ihm, dass es ihn gab — das sagt der Kopf und sonst nichts. Erspart bleibt dafür der
umgekehrte Preis: 824 Zeilen Überholtes in dem Dokument, das jede Agenten-Sitzung mitliest, und
eine Feldtabelle an zwei Orten, von denen nur einer bindet. Die Lockerung der Disziplin-Regel aus
dem Vorlagen-Kommentar trägt
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) — sie liegt vor, und dieser
Slice ist ihr **Vollzug**, nicht ihr Anlass.

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
Fälle aus `test/mutations/` (`grep -oE 'Test[A-Z][A-Za-z0-9_]+' | sort -u` bzw.
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
zählt für das Stratum heute *„zwei Abweichungen von der Vorlagen-Form"*, deren erste die
**Drei**-Spalten-Gestalt von §5 ist. Eine vierte Spalte ist eine **dritte** Abweichung und gehört
deshalb in den Adaptions-Block — genau in den aufhebenden Eintrag, und damit ist derselbe Vorgang
zugleich der Beleg, dass der Adaptions-Block nach dem Umzug wieder seinen Gegenstand hat. Auch hier
gilt die Disziplin-Regel: jener Eintrag wird nicht angefasst, seine *„zwei"* werden überholt.

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
- [ ] **(2) Der Eintrag wird vollständig aufgehoben, und die Aufhebung wird vollzogen.** Ein
  **neuer** Eintrag im Adaptions-Block (die nächste freie Nummer) hebt
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  auf, nennt je Posten-Art den Zielort, trägt was nach dem Inventar Regelwerks-Delta bleibt und
  verzeichnet, was *ersatzlos* entfällt, je mit Grund. Von
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
  bleiben Nummer, Überschrift, `Datum` und die Zeiger-Zeile stehen, der Rumpf geht. Die drei
  Bedingungen aus [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  Festlegung 2 sind einzeln erfüllt und je an ihrem Beleg: **(a)** die Aufhebung ist vollständig —
  kein Satz des Rumpfs bindet nach dem Inventar noch von dort; **(b)** jede bindende Aussage steht
  andernorts bindend oder ist als *ersatzlos* mit Grund verzeichnet — das führt DoD (3) nach;
  **(c)** Aufhebung und Entfernung sind **zwei** Commits, und der Entfernungs-Commit löscht nur:
  `git show --numstat <sha> -- harness/conventions.md` zeigt **0** Insertions. Die Überschrift
  steht wörtlich fort, gemessen an **0** `anchor-missing` in `make docs-check`.
- [ ] **(3) Kein Posten verschwindet still, keine Zusage verliert ihren Sensor.** Das Kriterium
  aus §1 wird posten-weise angewandt und als Vorher/Nachher-Inventar in §3 fortgeschrieben; jeder
  Posten trägt seinen Zielort oder das Verdikt *ersatzlos* mit Grund — **jeder**, auch der, der
  keine bindende Aussage ist und den
  [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Bedingung (b) darum nicht
  deckt (rot-gesehen-Nachweis, Gegenprobe, Messreihe). Jede der **10**
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
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | der neue Eintrag am Ende des Blocks und die Zeiger-Zeile im Kopf des aufgehobenen; dessen Rumpf geht in einem eigenen, reinen Lösch-Commit (DoD 2) |
| `docs/reviews/` | neu | das Zeitdokument, das die 49 datierten Mess-Zeilen aufnimmt |
| [`AGENTS.md`](../../../../AGENTS.md) | update | die `span-check`-Zeile der Gate-Tabelle nennt heute den aufgehobenen Eintrag als Quelle des Schemas und zeigt danach auf das Stratum |

**Die Commit-Folge ist tragend, und sie trennt Verschieben von Ändern**
([`AGENTS.md`](../../../../AGENTS.md) §3.3 in der Sache):

1. **Inventar** — jeder Posten mit Art und Zielort, bevor eine Zeile bewegt wird. Sonst
   entscheidet die Reihenfolge des Lesens, was überlebt.
2. **Umzug** — der Bestand geht **wörtlich** an seinen Zielort. Fällt dabei eine Aussage als
   falsch auf, wird sie **benannt**, nicht mitkorrigiert.
3. **Aufhebung** — der neue Eintrag und die Zeiger-Zeile im Kopf. Erst jetzt, weil beide die
   Zielorte nennen müssen.
4. **Entfernung** — der Rumpf geht, und dieser Commit **löscht nur**. Fällig **mit** Schritt 3
   ([`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2c), weil das
   Intervall dazwischen genau der Zustand ist, in dem die Feldtabelle an zwei Orten steht und kein
   Sensor den bindenden nennt.
5. **Korrektur** — Fehlzuordnung (a) aus §1: je Abweichung ihr wirklicher Regelblock. Eigener
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
   verlieren, die nirgends sonst geschrieben ist — daran hängt, ob der Rumpf gehen darf
   ([`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Bedingung (a) und (b)).

## 4. Trigger

**`open` → `next`:** [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) **und**
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) sind **Accepted**. Das sind
echte Abhängigkeiten und keine Reihung: die erste setzt den Zielort dieses Umzugs, die zweite
erlaubt die Entfernung des Rumpfs; beide stehen auf *Proposed*. Ein Umzug gegen eine noch nicht
angenommene Zielort-Setzung liefe Gefahr, zweimal zu laufen, und eine Entfernung ohne die zweite
wäre ein Bruch der Disziplin-Regel.

**Keine Abhängigkeit von [slice-075](../open/slice-075-regelwerk-verweis-linkpflicht.md) — in keiner
Richtung, aber eine gemessene Überschneidung.** **19 der 28** Stellen seines Bestands stehen im
Rumpf von [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung);
mit dem Rumpf gehen sie und kommen als auflösende Links am Zielort wieder. Läuft slice-075 zuerst,
verlinkt er 19 Stellen, die dieser Slice bewegt — Doppelarbeit, kein Bruch; läuft dieser Slice
zuerst, schrumpft jener Bestand auf **9**, und seine Klassen-Tabelle muss `spec/**` entscheiden
(§6). Umgekehrt schafft slice-075 die **Pflicht** zum Link, nicht die **Möglichkeit** —
die besteht heute (`scan.ignore` prunt, *was gescannt wird*, nicht, *was aufgelöst wird*). Der
Zeiger muss deshalb hier schon ein auflösender Link sein: das ist eine **Auflage an den Text**
(DoD 1), keine Reihenfolge.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls Umzug und Aufhebung nicht in **einer** Review-Sitzung prüfbar sind
  (Modul 5 §Ziel-Form). Die Naht ist benannt und der Schnitt danach billig: sie verläuft zwischen
  Schritt 2 und Schritt 3 der Commit-Folge. Der Grund, es zunächst als **einen** Schnitt zu führen,
  ist die Doppelführung: zwischen Umzug und Entfernung bindet die Feldtabelle an zwei Orten, und
  kein Sensor sieht das.
- `in-progress` → `open`: falls das Inventar einen Posten findet, dessen Zielort eine Entscheidung
  verlangt, die dieser Slice ausdrücklich nicht trifft (§6). Dann ist erst zu entscheiden, wohin er
  gehört.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün
und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Rumpf geht, und dass er gehen darf, misst kein Sensor — das ist der teuerste Punkt dieses
  Slice.** Ob die Aufhebung **vollständig** ist und ob jede bindende Aussage andernorts steht
  ([`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Bedingung (a) und (b)),
  entscheidet hier ein Mensch; jene Entscheidung sagt das selbst und schließt es nicht. Träger ist
  allein das Inventar aus DoD (3), und sein Gegenbeispiel — ein Posten, der still verschwindet —
  lässt `make gates` grün. Danach trägt den Rumpf die Historie: wer ihn ohne sie braucht, hat ihn
  nicht, und genau das ist der erste Re-Evaluierungs-Trigger jener Entscheidung.
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
- **[slice-075](../open/slice-075-regelwerk-verweis-linkpflicht.md) braucht eine Nachmessung, in zwei
  Punkten, und beide sind gemessen.** (1) Seine Klassen-Tabelle kennt `spec/**` nicht — heute zu
  Recht: `git ls-files 'spec/*.md' | xargs grep -ohE 'Modul[- ][0-9]{1,2}' | wc -l` → **0**. Nach
  diesem Umzug trägt [`spec/spezifikation.md`](../../../../spec/spezifikation.md) Modul-Nennungen,
  und die Klasse ist zu entscheiden (einbezogen oder ausgenommen mit Trigger). (2) Sein §6 nennt
  für den Eintrag *839 Zeilen, 50 % der Datei* „gemessen am letzten committeten Stand"; gemessen
  sind **824 Zeilen** — 49,3 % an dem Stand, den er zitiert, und **46,6 %** bei `b39d4ff`. Beide
  Korrekturen gehören in dessen nächste Berührung, nicht in diesen Schnitt.
- **Der Quellen-Konflikt um die Teil-Revision ist gemeldet und wird hier nicht behoben.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 kennt nur den Voll-Supersede; die Kurs-Fassung derselben
  Hard Rule kennt *„der abgelösten **oder geschärften** Vorgängerin"*, und das Repo hat den Weg
  fünfmal begangen (ADR-Index-Annotationen an drei Einträgen,
  [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
  und [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  je an [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). Die Textänderung
  ist eine eigene Entscheidung.
- **Dogfood und emittiert sind hier verschieden.** Ein gebootstrapptes Ziel bekommt
  `harness/conventions.md` **und** `spec/spezifikation.md` aus derselben vendored Vorlage — was es
  nicht bekommt, ist unser Bestand.
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Folgepflicht 3 hält fest, dass sich
  an der Emission **nichts** ändert; dieser Slice bewegt sie nicht.
- **Nicht in diesem Slice:** eine Größen-Schranke über
  Adaptions-Einträge · die inhaltliche Prüfung der sechs Abweichungen · eine neue ADR · die
  Linkpflicht als **Regel** ([slice-075](../open/slice-075-regelwerk-verweis-linkpflicht.md) — dieser Slice
  setzt Links, er erzwingt sie nicht) · der Prüfbereich und die Bindungs-Schärfe des
  Mutations-Sensors ([slice-069](../open/slice-069-zahn-bindet-zusicherung.md),
  [slice-070](../open/slice-070-comment-claims-pruefbereich.md)) · die emittierte Ebene und
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) · der Inhalt der übrigen 20 Einträge · die
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

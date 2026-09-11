# Slice slice-212: Der Adaptions-Block führt sechs aktivierte Doc-Gate-Module, das Gate fährt acht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet, als die DoD dieses
Slice belegt — ein Trigger wie *„der Eintrag steht"* wäre die Abschrift der eigenen DoD. Der
Auslöser ist reaktiv: eine Übergabe an den Architect liegt vor und hat sonst keinen Träger. Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Adaptions-Block **dieses** Repos. Was ein
emittiertes Repo an Modulen bekommt, entscheidet
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und nicht diese Datei.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Register, das weniger führt als läuft, sagt über den Prüfumfang etwas Falsches — dieselbe Klasse
eine Ebene über dem Gate),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (Hard Rules und
Adaptions-Block schreibt der **Architect** — dieser Slice liefert die Messung und den Termin, nicht
den Norm-Text),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(der Eintrag, dessen Aufzählung die Lücke trägt; *„Gate-Anheben → Steering-Loop"* ist zugleich der
Weg, den beide Aktivierungen genommen haben),
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
und
[`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
(die zwei Formen, in denen ein angenommener Eintrag fortgeschrieben werden darf — sie schränken die
Wahl ein, §1).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist der
Konventionsspeicher).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-11.

---

## 1. Ziel und Abgrenzung

**Der Adaptions-Block nennt jedes Modul, das dieses Repo über die Baseline hinaus im Doc-Gate
fährt — auch die zwei, die nach seiner Niederschrift dazukamen.**

### Die Lücke ist gemessen, nicht vermutet

```sh
grep -m1 '^modules:' .d-check.yml                                                    # acht Namen
sed -n '/^- \*\*Adaption:/,/^- \*\*Begründung:/p' harness/conventions/MR-001-*.md \
  | grep -oE '`(links|anchors|ids|matrix|codepaths|spans|planning|targets)`' | sort -u   # sechs
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Mengen wandern. Tragend ist die **Differenz**: `planning` und `targets` laufen
in `make docs-check` und stehen in keinem Eintrag des Blocks als aktiviert. Dass kein *anderer*
Eintrag sie trägt, ist mitgemessen:

```sh
grep -nE '`(planning|targets)`' harness/conventions/MR-*.md | grep -viE 'docs/plan|planning-harness|modul-0'
```

Die Treffer sprechen über **Verfügbarkeit im Bild** und über Verhaltensänderungen zwischen Pins,
nicht über die Aufnahme in `modules:`.

### Zwei Nachbar-Aussagen sind gemessen und tragen die Lücke nicht

[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
nennt `planning` und `targets` als Module, die *„opt-in bleiben und **hier** nicht aktiviert"*
werden — eine an seinen Pin-Sprung gebundene Werkzeug-Aussage in genau der Form, die
[`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
vorsieht. Sie sagt nichts über die heutige Modul-Liste und wird von diesem Slice nicht angefasst.
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
nennt `planning` allein, um eine Aussage des retirierten
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
als ersatzlos zurückgebaut zu buchen — ebenfalls keine Aktivierungs-Aussage.

**Die Lücke ist damit genau eine, und sie ist eine Leerstelle statt eines Widerspruchs:** Der Block
trägt keinen Ort, an dem steht, dass dieses Repo `planning` und `targets` fährt.

### Die Form der Antwort ist eingeschränkt, und das ist die eigentliche Entscheidung

Die Aufzählung in [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
**nachträglich zu ergänzen, ist keine der zulässigen Formen**: An einem angenommenen Eintrag wird
nichts nachträglich inhaltlich geändert (§Adaptions-Block *Disziplin*), und
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
trägt für eine andere Setzung bereits eine Kopf-Marke nach
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger).
Übrig bleiben ein **neuer Eintrag**, der die zwei Aktivierungen trägt und auf den die Kopf-Marke
zeigt, oder die Feststellung, dass eine Modul-Aktivierung überhaupt **keine** Abweichung von der
Baseline ist und deshalb in keinen Eintrag gehört
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). Welche der beiden gilt,
ist eine Architektur-Frage und wird in diesem Slice **entschieden**, nicht offengelassen.

### Abgrenzung — was dieser Slice nicht tut

- **Kein Sensor, der die Aufzählung gegen `modules:` hält.** Das wäre die Feedback-Hälfte und ein
  eigener Vorgang: Norm-Text schreibt der Architect, einen Wächter baut der Implementer — beides in
  einem Slice wäre ein Schnitt über zwei Rollen. Ein Vorbild für die Kopplungs-Form liegt mit
  `test/sources-pin.bats` vor; **dass** ein solcher Wächter fehlt, gehört in die Closure-Notiz
  dieses Slice.
- **Keine Änderung an [`.d-check.yml`](../../../../.d-check.yml).** Der Baum ist der Ist-Zustand,
  gegen den der Block nachzieht; die Gate-Konfiguration ist hier Messgegenstand, nicht Gegenstand.
- **Kein Durchgang über die übrigen Einträge des Blocks.** Ob der Block insgesamt zu viel über sich
  selbst spricht, ist ein eigener Schnitt und liegt bereits bei
  [`slice-168`](../open/slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung.md) — ein Folge-Slice, der den
  verwiesenen Punkt selbst trägt.
- **Kein Nachzug der emittierten Startkonfiguration.** Ebene Dogfood (Kopfzeile); die emittierte
  Modul-Menge hängt an
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel).

## 2. Definition of Done

Ein slice-eigener Punkt (Modul 5 §Ziel-Form: ≤ 3). Ein zweiter wäre erfunden — die zwei
Nachbar-Aussagen aus §1 sind gemessen und brauchen keinen Nachzug.

- [ ] **(1) Die Aktivierung von `planning` und `targets` ist im Adaptions-Block entschieden und
      steht in einer der zulässigen Formen** — als neuer Eintrag mit Kopf-Marke auf
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
      oder als begründete Feststellung, dass eine Modul-Aktivierung keine Abweichung ist und
      deshalb keinen Eintrag trägt. Der Index trägt die Zeile, falls ein Eintrag entsteht.
      **Kein Kommando färbt diesen Punkt rot**, und das ist der Befund, keine Vertagung: Kein Modul
      aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml) liest den Wahrheitsgehalt einer
      Aufzählung. Prüfbar ist er am Diff — die Differenz aus §1 ist danach leer oder ausdrücklich
      als *keine Abweichung* erklärt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions/`](../../../../harness/conventions/) | neu **oder** unverändert | der Eintrag, der die zwei Aktivierungen trägt — falls DoD (1) auf *Eintrag* entscheidet |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Index-Zeile (derivativ, [`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) und, falls entschieden, die Kopf-Marken |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | Messgegenstand, nicht Gegenstand (§1 Abgrenzung) |
| [`test/`](../../../../test/) | **unverändert** | der Wächter ist ein eigener Vorgang (§1 Abgrenzung) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`):** WIP-Limit frei und ein Architect-Kontext verfügbar.
Der Slice hängt an keinem anderen — die Messung in §1 ist am ruhenden Baum jederzeit wiederholbar.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: die Entscheidung über die Form zieht den Durchgang über weitere Einträge
  nach sich — dann ist der Schnitt zu klein gewesen und die Arbeit gehört zu
  [`slice-168`](../open/slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung.md), nicht in einen zweiten DoD-Punkt.
- `in-progress` → `open`: die Frage *ist eine Modul-Aktivierung überhaupt eine Abweichung?* trifft
  den Block als Ganzes und nicht nur diese zwei Module. Dann ist die Lage eine ADR-Frage nach
  Modul 4, kein Eintrag.

## 5. Closure-Trigger

DoD (1) erfüllt, `make gates` grün, `make mutate` ohne Befund, Review nach Modul 10 ohne
blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Eintrag kann die Klasse verfehlen, die er schließen soll.** Ein Eintrag, der nur *„`planning`
  und `targets` sind aktiviert"* festhält, veraltet beim nächsten Modul genauso still wie die
  heutige Aufzählung. Was trägt, ist eine Regel über die **Eigenschaft** — wann eine Aktivierung
  einen Eintrag braucht —, nicht eine zweite Liste, die dieselbe Pflege verlangt.
- **Die Entscheidung *keine Abweichung* entwertet rückwirkend einen Teil von
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).**
  Fällt sie so, steht die dortige Modul-Aufzählung als etwas da, das nach der eigenen Regel nie
  hätte eingetragen werden müssen. Das ist ein zulässiger Ausgang, aber er gehört benannt statt
  nebenbei mitgenommen.
- **Ohne Wächter ist der Nachzug einmalig.** Dieser Slice stellt den Gleichstand her; er hält ihn
  nicht. Der nächste Modul-Sprung erzeugt dieselbe Differenz, und gemeldet wird sie wieder von
  niemandem.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist genau eine Sub-Area, `*` (Kürzel `ALL`) aus der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md). Sie erfüllt
das Inklusionskriterium über alle drei Achsen (eigener Konventionsspeicher, eigener Gate-Prüfbereich,
eigene Rollen-Zuständigkeit nach [`AGENTS.md`](../../../../AGENTS.md) §3.8) und ist für diesen
Gegenstand nicht zu grob: Der Adaptions-Block ist repo-weit und hat keine engere Sub-Area unter
sich.

**Vorgelagert — offene Beobachtungen sichten:** Drei Einträge des Registers treffen diese Sub-Area
und diesen Gegenstand; die Zähler stehen neben dem Kommando, das sie liefert
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte):

- [`adaptions-block-spricht-ueber-sich-selbst`](../observations/BEO-ALL/adaptions-block-spricht-ueber-sich-selbst/observation.md)
  — **3**, Stand `geplant` mit Kennung `slice-168`. Der Eintrag steht über der Schwelle und hat
  seinen Ausgang; dieser Slice berührt ihn, weil ein weiterer Eintrag **über den Block** genau die
  Masse vergrößert, die jener Schnitt zu ordnen hat. Das ist der Grund für die Abgrenzung in §1:
  der Durchgang gehört dorthin, nicht hierher.
- [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  — **2**, Stand `offen`. Dieser Slice **ist** das Träger-Artefakt, das der Eintrag für eine
  Planner→Architect-Übergabe verlangt; er erhöht den Zähler darum nicht.
- [`config-kommentar-nennt-anderen-bereich-als-der-eintrag`](../observations/BEO-ALL/config-kommentar-nennt-anderen-bereich-als-der-eintrag/observation.md)
  — **2**, Stand `offen`. Die Fehlerrichtung ist dieselbe wie hier, nur zwischen Kommentar und
  Schlüssel statt zwischen Eintrag und `modules:`-Zeile; wer den Eintrag schreibt, prüft seinen
  Geltungsbereich gegen das, was der Schlüssel wirklich trägt.

Kein Eintrag erreicht mit diesem Slice **3×**.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF: Der Konventionsspeicher ist
Doc-führend, der Code folgt ihm nicht, und der Slice legt keine neue Sub-Area an. Ein
Begründungsblock entfällt.

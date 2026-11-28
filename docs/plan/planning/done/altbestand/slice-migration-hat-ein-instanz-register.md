# Slice slice-migration-hat-ein-instanz-register: Der Baseline-Sprung bekommt vorher ein Instanz-Register und eine Report-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der
Gegenstand ist **ein** stehendes Dokument, und sein Beleg ist die Abzählung gegen ein Kommando plus
der `docs-check`-Lauf, der ohnehin in jeder DoD steht (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist das Migrations-Verfahren **dieses** Repos. Was
ein Zielrepo an Migrations-Doku bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet
(§1) — die zwei Ebenen tragen verschiedene Verträge und verschiedene Gründe.

**Bezug:**
[ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 1 bindet die
Migrations-Prozedur an den Freshness-Audit der Ziel-Fassung, Festlegung 3 an ein Kriterium je
Sprung),
[ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
[ADR-0038](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md),
[ADR-0043](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md),
[ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (die sechs Sprung-Entscheidungen,
gegen die die Auflage des Auftraggebers jeden Punkt dieses Dokuments hält),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das
Dokument behauptet keinen Sensor, den es nicht gibt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Vollständigkeits-Zahl
kommt aus einem Kommando über dem gepinnten Baum, nicht aus dem Text),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Mess-Tag).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist eine
Verfahrens-Ablage im Harness-Baum).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Vor dem nächsten Baseline-Sprung steht ein **stehendes** Dokument
`harness/migration.md` — neben [`conventions.md`](../../../../harness/conventions.md) —, das zwei <!-- d-check:ignore (geplante Datei) -->
Dinge trägt: ein **Instanz-Register** (welches Artefakt dieses Repos ist Instanz welcher vendored
Vorlage) und eine **Report-Form** für `docs/migrations/<tag>.md` mit genau einem Ausgang je <!-- d-check:ignore (geplante Ablage) -->
Vorlage.

### Was heute fehlt, und woran es sich zeigt

Der Form-Vergleich des Freshness-Audits läuft heute **Vorlage gegen Vorlage**
(`diff -r .harness/baseline/<alt>/templates .harness/baseline/<neu>/templates`, Baseline-Regelwerk
`modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline, Eigenschaft *Der Review
vergleicht auch die Form*). Was er **nicht** sagt: welches Artefakt dieses Repos die Instanz einer
geänderten Vorlage ist. Die Zuordnung wird bei jedem Sprung neu erraten, und die Form-Pflichten der
neuen Fassung kommen einzeln als Nachzügler zurück statt gebündelt in den Schnitt — die gemessene
Klasse
[`BEO-ALL/re-baseline-ohne-inventur-slice`](../observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md)
(**2×**, `offen`).

Die Bezugsmenge ist abzählbar und steht neben ihrem Kommando:

```sh
find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l   # 25
grep -m1 '^BASELINE_TAG' Makefile                                       # BASELINE_TAG ?= v6.7.2
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem Tag, und **genau das** ist der Grund, warum
**Vollständigkeit** als Abzählung gegen das Kommando definiert wird und nicht als feste Zahl im
Text ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

### Das Dokument leitet ab, es setzt nicht

**Auflage des Auftraggebers:** Jeder Punkt muss an einem der sechs Sprung-ADRs belegbar sein; was
sich dort nicht belegen lässt, steht als **offene Frage** drin statt als Regel. Das ist keine
Fußnote, sondern die Verfassung dieses Dokuments: Eine Norm-Setzung wäre eine ADR und gehörte dem
Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Was hier entsteht, ist die **Sicht** auf
Entscheidungen, die schon getroffen sind — plus eine ehrliche Liste dessen, was keine trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Durchgang gegen `v6.8.0` und kein Report unter `docs/migrations/`.** Dieser Slice liefert <!-- d-check:ignore (geplante Ablage) -->
  die **Form**, nicht ihren ersten Lauf; der Durchgang wird geschnitten, wenn der Zielstand gesetzt
  ist, und er ist nach
  [ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen ohnehin ein
  eigener Planner-Auftrag. *Es wäre ein anderer Vorgang.*
- **Kein rückwirkender Report für die sechs vollzogenen Sprünge.** Ein nachgeschriebener Bericht
  wäre rekonstruiert, nicht gemessen — dieselbe Linie, die das Baseline-Regelwerk für den
  Herkunfts-Anker zieht (*„Ab Einführung, kein Nachrüsten … der leere Zustand ist die ehrliche
  Information"*). *Bestand bleibt bewusst stehen.*
- **Keine ADR und kein Eintrag im Adaptions-Block.** Beide sind Architect-Eigentum
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und die Auflage oben macht sie entbehrlich: Das
  Dokument zitiert Entscheidungen, statt welche zu treffen. *Schicht-Abgrenzung* — beim Review
  sofort prüfbar.
- **Kein Sensor auf das Register.** Weder ein `make`-Ziel noch ein Modul der
  [`.d-check.yml`](../../../../.d-check.yml) prüft, ob eine Zeile fehlt oder ihre Zuordnung
  stimmt. Ein Wächter wäre **baubar** — die Abzählung gegen `find` ist er beinahe schon —, gebaut
  ist er nicht, und ihn hier zu behaupten wäre
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
  Ebene tiefer. *Es wäre ein anderer Vorgang.*
- **Keine Änderung an §Baseline von
  [`harness/conventions.md`](../../../../harness/conventions.md).** Dort steht die Zielstand-Buchung,
  und sie gehört dem Architect. Das neue Dokument verweist darauf und wiederholt es nicht — zwei
  Fassungen derselben Buchung driften. *Schicht-Abgrenzung.*
- **Kein Produkt-Code und keine emittierte Vorlage.** `internal/`, `cmd/`, `harness/tools/` und
  `internal/emit/templates/` bleiben unberührt; was ein Zielrepo an Migrations-Doku bekommt, ist
  die andere Ebene. *Schicht-Abgrenzung.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte, und der dritte ist die Auflage:**

- [x] **(1) `harness/migration.md` existiert und trägt das Instanz-Register.** Je vendored Vorlage <!-- d-check:ignore (geplante Datei) -->
      **genau eine** Zeile; die Zeilenzahl stimmt mit der Ausgabe von
      `find .harness/baseline/<tag>/templates -name '*.template.md' | wc -l` überein, und `<tag>`
      ist der Wert aus `grep -m1 '^BASELINE_TAG' Makefile` statt eines Literals. Jede Zeile nennt
      **das** Artefakt dieses Repos, das Instanz dieser Vorlage ist — oder *keine Instanz* **mit
      Begründung**. Eine Vorlage ohne Zeile ist der Befund, keine Auslassung.
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit))
- [x] **(2) Dasselbe Dokument trägt die Report-Form für `docs/migrations/<tag>.md`** — **drei** <!-- d-check:ignore (geplante Ablage) -->
      Fälle, und je Vorlage genau einer: für jede **nicht-wiederkehrende** Vorlage einen von
      **vier** Ausgängen mit seiner **Beleg-Art** — *übernommen* (Commit) · *schon erfüllt*
      (Fundstelle) · *bewusst abweichend* (`MR`-Kennung) · *keine Instanz* (Begründung); für jede
      **wiederkehrende** Vorlage den Ausgang *append-only* (Beleg: das Sprung-Datum); für jede noch
      **nicht zugeordnete** Vorlage eine **offene Frage** im Abschnitt *Offene Fragen* statt einer
      Regel. Die vier des ersten Falls bleiben eine **geschlossene Menge**, kein Freitext —
      dieselbe Disziplin, die Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken
      werden bei Closure aufgelöst für die drei Risiko-Ausgänge setzt; *append-only* ist keine
      fünfte Ergänzung dieser Menge, sondern die disjunkte Antwort für eine andere
      Vorlagen-Klasse. Ein Report entsteht mit diesem Slice **nicht** (§1).
- [x] **(3) Jeder normative Punkt des Dokuments nennt den Sprung-ADR, an dem er belegt ist** — aus
      [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md),
      [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
      [ADR-0036](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
      [ADR-0038](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md),
      [ADR-0043](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) oder
      [ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md). **Was sich dort nicht
      belegen lässt, steht in einem eigenen Abschnitt als offene Frage** — benannt, nicht als Regel
      getarnt. Der Abschnitt ist nicht leer zu schreiben: Ist er leer, ist **das** zu belegen.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Liefer-Punkt (1) **ist** dieses Item — `harness/migration.md` ist ein neuer <!-- d-check:ignore (geplante Datei) -->
      Einstieg neben [`conventions.md`](../../../../harness/conventions.md) und gehört in die
      Guides-Tabelle von [`harness/README.md`](../../../../harness/README.md).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein
      Erwartungswert), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne
      Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/migration.md` <!-- d-check:ignore (geplante Datei) --> | neu | trägt Instanz-Register und Report-Form — Liefer-Punkte (1)–(3) |
| [`harness/README.md`](../../../../harness/README.md) §Guides | update | der neue Einstieg gehört in die Guides-Tabelle, sonst findet ihn kein Lauf |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist eine Zuordnungs-Tabelle
und eine Form-Beschreibung; ihr Wächter wäre die Abzählung gegen `find`, und §1 schließt ihn
ausdrücklich aus. Ein `*_test.go` oder `*.bats`, das die Tabelle gegen eine zweite Fassung ihrer
selbst hielte, wäre die Kopie, die dieser Slice gerade vermeidet.

**Reihenfolge, und sie ist nicht beliebig:**

- **Erst die Bezugsmenge, dann die Zuordnung.** Die 25 Vorlagen werden aus dem Kommando gelesen,
  nicht aus einer Liste abgetippt; wer die Liste abtippt, hat die zweite Quelle schon gebaut.
- **Erst der ADR-Beleg, dann die Formulierung.** Wer den Punkt zuerst schreibt und danach den
  Beleg sucht, findet einen — die Auflage kehrt die Reihenfolge um.
- **Die offenen Fragen entstehen dabei, nicht danach.** Ein Punkt, der beim Belegen scheitert,
  wandert in den Abschnitt *Offene Fragen* und wird nicht weichgeschrieben, bis er belegbar
  aussieht.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice**, und der Sprung auf den
nächsten Tag ist **noch nicht vollzogen** — der Slice ist ihm vorgelagert. Beobachtbar ohne
Rückfrage, auf dem **Hauptzweig**:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'   # 0  (WIP frei; Exit 1 bei 0)
grep -m1 '^BASELINE_TAG' Makefile                        # BASELINE_TAG ?= v6.7.2
```

**Der Trigger ist kein Ergebnis dieses Slice** — er spricht über den Bestand von `in-progress/` und
über den gepinnten Tag, nicht über die DoD oben. Dass der Sprung noch aussteht, ist die
Vorbedingung, unter der das Dokument überhaupt etwas nützt: Nach dem Sprung wäre es rekonstruiert
statt vorbereitend.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Die Zuordnung Vorlage → Instanz
  verlangt für mehr als eine Vorlage eine eigene Entscheidung**, weil das Repo für sie zwei
  Kandidaten führt oder keinen, den eine Quelle benennt. Dann liefert dieser Slice nicht ein
  Register, sondern zusätzlich eine Reihe von Setzungen — und Setzungen sind ein anderer
  Liefergegenstand mit einer anderen schreibenden Rolle. Register zuerst, Setzungen danach.
- `in-progress` → `open` (blockiert — Carveout?): **Die Auflage ist an der Mehrheit der Punkte
  nicht erfüllbar** — die sechs Sprung-ADRs tragen die Zuordnungs-Achse nicht, und das Dokument
  würde eine Fragenliste statt einer Form. Dann gehört eine ADR davor, und die schreibt der
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Zweiter Fall: Der Zielstand auf den
  nächsten Tag wird gesetzt und vollzogen, während dieser Slice offen ist — dann ist die
  Vorbedingung aus dem Start-Trigger weg.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Die Zeilenzahl des Instanz-Registers und die Ausgabe von
   `find .harness/baseline/<tag>/templates -name '*.template.md' | wc -l` stimmen überein**, und
   `make gates` meldet Exit 0. Die Abzählung steht im Umsetzungs-Commit, nicht nur im Dokument.
2. **Jeder normative Punkt trägt eine `ADR-00NN`-Kennung aus der Sechser-Menge, und der Abschnitt
   *Offene Fragen* ist gefüllt oder seine Leere ist belegt.** Nachlesbar in `git show`; ohne diese
   Prüfung wäre die Auflage eine Absichtserklärung.

**Lerneintrag:** in der Form **benannte Spec-Lücke** — welche Zuordnung *Vorlage → Instanz* heute
keine Quelle trägt, und welcher der vier Ausgänge sich an keinem der sechs Sprung-ADRs belegen
lässt. Ob daraus stattdessen eine *geschärfte Regel* wird, entscheidet die Closure und nicht dieser
Plan.

**Ob der Eintrag daneben ein `liegt in`-Feld trägt, entscheidet die Closure.** Das Feld steht nur,
wenn mit diesem Slice wirklich eine Regel **verkörpert** wurde; eine benannte Spec-Lücke trägt es
nach Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker ausdrücklich **nicht**.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Das Register ist eine zweite Quelle, und das ist der schärfste Einwand gegen dieses
  Dokument.** Baseline-Regelwerk `grundlagen-traceability.md` §Die zweite Richtung setzt für die
  RTM *„Sie wird erzeugt, nicht gepflegt"* — ein Verzeichnis von Beziehungen neben den Artefakten
  ist eine Kopie, und Kopien driften. **Gegenmittel im Plan:** Das Register trägt genau die
  Zuordnung, die **nirgends** sonst steht, und keinen Inhalt; es gibt keinen Anker, aus dem es
  abzuleiten wäre — anders als bei der RTM, deren Quellen die Anker sind, die der
  Traceability-Constraint ohnehin erzwingt. Zeigt sich beim Bauen, dass die Zuordnung aus einem
  vorhandenen Feld ableitbar ist, ist das Dokument falsch und die Rückführung greift.
  — **Ausgang:** **entfallen.** Die Prüfung, die das Risiko selbst vorschreibt, ist beim Bauen
  gefahren und fällt negativ aus: Die Zuordnung ist aus keinem vorhandenen Feld ableitbar. **21**
  der **25** Zeilen verlangten ein Urteil, **4** ließen sich gar nicht entscheiden und stehen als
  offene Frage in §6 des Dokuments — eine Ableitung hätte für alle 25 einen Anker geliefert. Das
  Register ist damit keine Kopie, sondern die einzige Fassung. **Der Rest-Einwand steht und ist
  nicht vergessen:** Zieht ein Artefakt um, altert seine Zeile still, weil kein Sensor sie hält —
  das ist der in §1 **entschiedene** Ausschluss (*„Kein Sensor auf das Register"*), keine
  übersehene Lücke.
- **(2) Die vier Ausgänge sind eine Setzung des Auftraggebers, die Baseline führt an derselben
  Stelle fünf.** Der Freshness-Audit kennt **fünf** Ausgänge — *gegenstandslos · bleibt gültig ·
  teilweise überholt · Bezug ist entfallen · widerspricht* —, und sie gelten für den
  **Adaptions-Eintrag**, nicht für die **Vorlage**. Zwei Achsen, zwei Mengen. Wer sie zusammenzieht,
  misst eine Achse mit dem Maßstab der anderen; wer sie nebeneinanderstellt, ohne den Unterschied
  zu nennen, erzeugt beim nächsten Durchgang zwei Lesarten.
  — **Ausgang:** **entfallen.** Das Dokument stellt die zwei Achsen nicht nur nebeneinander, es
  nennt den Unterschied: §5 schließt mit dem Absatz *„Diese Ausgänge … sind nicht die fünf
  Ausgänge des Adaptions-Durchgangs"* und benennt beide Bezugsgegenstände — **Vorlage** hier,
  **Adaptions-Eintrag** dort. Zwei Review-Befunde trafen genau diese Passage (Runde 1, F-5 fehlender
  Mess-Tag, F-6 Beleg-Zeiger auf den falschen Abschnitt von
  [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md)); beide betrafen die **Form**
  des Belegs, nicht die Vermischung, und beide sind behoben.
- **(3) Die Vollständigkeits-Zahl wandert mit dem Tag, und genau sie ist das Abnahmekriterium.**
  **25** gilt für `v6.7.2`; der nächste Tag kann mehr oder weniger Vorlagen führen. Ein
  eingefrorenes Literal im Dokument wäre ein Erwartungswert
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) und machte das Register beim ersten Sprung falsch — an genau der Stelle, an der es
  gebraucht wird. **Gegenmittel im Plan:** Liefer-Punkt (1) definiert Vollständigkeit als Abzählung
  gegen das Kommando und liest `<tag>` aus `BASELINE_TAG`.
  — **Ausgang:** **entfallen.** Das Gegenmittel ist im gelieferten Dokument verkörpert: Die
  Vollständigkeit steht als Abzählung gegen `find … | wc -l` neben ihrem Kommando, der Tag kommt
  aus `grep -m1 '^BASELINE_TAG' Makefile`, und kein Literal trägt das Kriterium. Die **25** steht
  als datierte Messung neben ihrem Kommando, nicht als Erwartungswert
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — was der nächste Tag an ihr bewegt, bewegt er am Kommando mit.
- **(4) Die Auflage kann das Dokument leerlaufen lassen.** Die sechs Sprung-ADRs entscheiden über
  die **regierende Fassung** eines Sprungs; ob sie auch über die Zuordnung *Vorlage → Instanz*
  etwas sagen, ist gemessen offen — sie nennen `templates` zwischen **0** und **16** Mal
  (`for f in 0018 0031 0036 0038 0043 0044; do grep -c templates docs/plan/adr/$f-*.md; done`, kein
  Erwartungswert), und eine Nennung ist kein Beleg. Bleibt am Ende mehr in *Offene Fragen* als im
  normativen Teil, ist das Ergebnis ehrlich und trotzdem nicht das bestellte Dokument; die
  Rückführung `in-progress` → `open` ist dafür vorab benannt (§4).
  — **Ausgang:** **entfallen.** Die Schwelle, die das Risiko selbst setzt — *mehr in „Offene
  Fragen" als im normativen Teil* —, ist nicht erreicht: §4 trägt **25** Zuordnungs-Zeilen, §5
  zwei Fälle, und **4** Zeilen plus die Grundfrage stehen in §6. Die Rückführung hat nicht
  gefeuert. **Eingetreten ist die Gegenrichtung**, und sie ist gemessen: In Runde 2 und 3 erzwang
  der Review-Druck eine **Zuordnung** für Zeilen, für die die Auflage die offene Frage vorgesehen
  hätte — Runde 4 hat das als N-14/N-15/N-18 benannt. Das ist nicht dieses Risiko, sondern eine
  eigene Klasse; sie geht als Beobachtung ins Register (§7).
- **(5) Ein neues stehendes Dokument im Harness-Baum hat keinen Konsumenten, bis einer es liest.**
  [`harness/README.md`](../../../../harness/README.md) §Guides ist der einzige Ort, an dem ein Lauf
  es findet; steht es dort nicht, ist es eine Datei, die niemand öffnet. **Gegenmittel im Plan:**
  Das Doku-Item in §2 ist genau dieser Eintrag und keine Formalie.
  — **Ausgang:** **entfallen.** Der Eintrag steht in der Guides-Tabelle von
  [`harness/README.md`](../../../../harness/README.md)
  (`grep -c '(migration.md)' harness/README.md` → **1**, kein Erwartungswert). Damit findet das
  Dokument denselben Lesepfad wie [`conventions.md`](../../../../harness/conventions.md); der
  **erste** Konsument ist der Durchgang des nächsten Sprungs, und den adressiert §1.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die Reihenfolge aus §3 — erst die Bezugsmenge, dann die Zuordnung,
  und der ADR-Beleg vor der Formulierung.** Die Vollständigkeit ist nie eine Behauptung geworden:
  Sie steht als Abzählung gegen `find … | wc -l` (**25**, deckungsgleich mit den Registerzeilen)
  und liest den Tag aus `BASELINE_TAG` statt aus einem Literal. Und die **Auflage** hat getan, wofür
  sie da war: **4** der **25** Zeilen ließen sich an keinem der sechs Sprung-ADRs belegen und stehen
  als offene Frage in §6 des Dokuments, statt als Regel getarnt zu sein.
- **Was ging anders als geplant:** **Zweierlei.** (a) **DoD-Punkt (2) hat die Arbeit nicht
  überlebt.** Er setzte *„je Vorlage genau einer von vier Ausgängen"* als Tatsache; Review-Runde 1
  (F-1) hat gemessen, dass die Vier-Menge die **wiederkehrenden** Vorlagen nicht trägt, und das
  Dokument trägt seither drei Fälle — vier Ausgänge für einmalige, *append-only* für
  wiederkehrende, offene Frage in §6 für unentschiedene. Korrigieren durfte den Punkt weder
  Implementer noch Reviewer ([`AGENTS.md`](../../../../AGENTS.md) §3.10); er hat vier Runden und
  zwei Verifikationen überstanden und steht mit dieser Closure. (b) **Der Lerneintrag hat die Form
  gewechselt** — §5 plante die *benannte Spec-Lücke* und überließ die Entscheidung ausdrücklich
  dieser Closure. Sie fällt auf **geschärfte Regel**, und der Gegenstand ist nicht der Sprung,
  sondern der Prüf-Rhythmus (unten).
- **Steering-Loop-Eintrag — geschärfte Regel (Vorschlag, nicht verkörpert):** **Die Prüftiefe
  folgt der Artefakt-Klasse, nicht dem Rhythmus.** Für ein Artefakt **ohne normative Bindung** —
  kein Gate-Vertrag, keine ADR, kein Hard-Rule-Text, keine emittierte Vorlage; hier ein
  vorbereitendes **Nachschlage-Dokument** — ist eine Review-Runde **hinreichend, sobald sie kein
  HIGH mehr findet**. MEDIUM-Funde, die eine **offene Frage statt einer Antwort** nach sich ziehen,
  lösen dann keine weitere Runde aus: Sie gehen als Befund in die Closure und, wo sie eine Klasse
  treffen, ins Beobachtungs-Register. **Zielort wäre
  [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)** und nicht das
  Regelwerks-Modul: `modul-10-review-harness.md` liegt unter `.harness/baseline/` und ist committet
  vendorter Fremdtext, den dieses Repo nicht schreibt — eine Abweichung dort wäre ein Eintrag im
  Adaptions-Block und damit Architect-Arbeit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Die Skill-Datei ist der Ort, an dem die
  **nicht-ableitbare** Urteilsgrundlage des Reviewers steht (Baseline-Regelwerk
  `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse) — und *wann eine Runde
  genug ist* ist genau das.
  *(Kein `liegt in`-Feld — der Eintrag ist **gezählt, nicht verkörpert**, aus zwei unabhängigen
  Gründen. **Erstens die Schwelle:** die Beobachtung steht nach diesem Slice bei **1×**; Baseline-
  Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register bindet *verkörpert* und *geplant* an
  den 3×-Übertritt, darunter ist `offen` der Normalzustand. Eine Regel aus einer einzigen
  Beobachtung wäre genau die Verallgemeinerung, vor der die Schwelle schützt. **Zweitens das
  Eigentum:** Ein Rollen-Anweisungssatz gehört der Rolle, die ihn **ausführt**
  ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) — die
  Reviewer-Skill schreibt der Reviewer, nicht der Planner. Auch beim Übertritt ist das eine
  **Übergabe**, kein Closure-Schritt.)*
- **Beobachtungs-Register (`../observations/`):** **drei Belege.** Neu angelegt:
  [`BEO-ALL/pruef-tiefe-folgt-nicht-der-artefakt-klasse`](../observations/BEO-ALL/pruef-tiefe-folgt-nicht-der-artefakt-klasse/observation.md)
  (**1×**) — der Gegenstand des Lerneintrags oben. Ergänzt:
  [`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  (**2×**) für DoD-Punkt (2) und — **strukturell erst nach dem `git mv`, weil er ein Befund des
  Move ist** —
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  (**17×**): Der Closure-Move macht die Zeile *„In Arbeit: …"* der Roadmap falsch, und
  [`make slice-mv`](../../../../harness/sensors/slice-mv.md) zieht Pfade nach, keine Zustandssätze.
  **Die zwei aus der Sichtung (§8) sind nicht erhöht**, und das ist der Befund, nicht eine
  Auslassung: `re-baseline-ohne-inventur-slice` steht bei **2×**, weil dieser Slice die Klasse nicht
  erneut auslöst, sondern **beantwortet**; `baseline-aussage-ohne-mess-tag` steht bei **2×**, weil
  der einzige Treffer dieser Art (Runde 1, F-5) **innerhalb** desselben Vorgangs behoben wurde und
  ein Vorgang einmal zählt. **Der Lese-Schritt ist nicht meine Sache:** Dieses Repo fährt
  Wellen-Betrieb, der 3×-Übertritt gehört der nächsten Welle-Closure.
- **Folge-Slices:** **keiner.** Kein Risiko aus §6 ist eingetreten, und die offenen Fragen in §6 des
  Dokuments haben ihre Adresse bereits: Der Durchgang des nächsten Sprungs ist nach
  [ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen ein eigener
  Planner-Auftrag — er wird geschnitten, wenn der Zielstand gesetzt ist (§1). Ein Slice dafür jetzt
  zu schneiden hieße, auf einen Tag zu planen, den niemand gesetzt hat.
- **Risiken aus §6:** fünf Risiken, fünf Ausgänge — **fünfmal *entfallen*, jedes mit Messung**;
  keines *eingetreten*, keines *weiter offen*. Kein Risiko ohne Ausgang; die Einzelheiten stehen in
  §6. Bei Risiko 1 und 4 steht der **Rest** ausdrücklich daneben: der ungewächtert alternde
  Registereintrag (in §1 entschieden ausgeschlossen) und die Gegenrichtung der Auflage (oben als
  Beobachtung gebucht).
- **Verhältnismäßigkeit, als Feststellung des Auftraggebers:** **vier** Review-Runden und **sechs**
  Implementer-Commits (`ls docs/reviews/*slice-migration-hat-ein-instanz-register*.md | grep -vc verify`
  → 4, `git log --format='%s' f0d58786^..369e6e99 | grep -cE '^Rolle Implement'` → 6; keine
  Erwartungswerte) für ein Dokument mit **25** Registerzeilen, von denen **4** als offene Frage
  enden. Den Gegenstand des kommenden `v6.8.0`-Sprungs — vier Dateien, +36/−4 Zeilen im vendored
  Baum — hat der Auftraggeber beziffert; **hier ist er nicht messbar** (`ls .harness/baseline/` →
  `v6.7.2`), und die Zahl steht darum als seine Feststellung und nicht als eigene Messung.
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` →
  **3**, kein Erwartungswert) — geprüft von der nächsten Welle-Closure, auch für diesen Slice ohne
  Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln
([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
für jede Baseline-Aussage,
[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
für die Präsens-Aussage über den vendored Baum,
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
für den Baum selbst), eigener Prüfbereich
([`make docs-check`](../../../../harness/sensors/docs-check.md) über dem gesamten Doku-Bestand) und
eigene Fehlermodi (eine Zuordnung, die niemand führt und die bei jedem Sprung neu geraten wird).
**`TOOLS` ist geprüft und nicht berührt:** `harness/tools/` bekommt kein Skript; dass das neue
Dokument im selben Baum liegt, ist Pfad-Nähe und nicht hinreichend. **`CODEX` ebenso wenig** —
`.codex/` führt allein den SessionStart-Injektor.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**104** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. **Fünf Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 5× | offen | §1 — der Bestand offener Pläne hat über einen Sprung hinweg keinen Leser |
| `re-baseline-ohne-inventur-slice` | 2× | offen | §1 — **der Anlass dieses Slice**; er ist der fehlende Inventur-Schritt |
| `baseline-aussage-ohne-mess-tag` | 2× | offen | §6 Risiko 3 — die Zahl 25 gilt für `v6.7.2` und für keinen anderen Tag |
| `delta-durchgang-uebersieht-deckung` | 1× | offen | §6 Risiko 4 — das Delta ist nicht der Bestand, und das Register misst den Bestand |
| `baseline-sprungweite-treibt-kosten` | 1× | offen | §4 — die Vorbedingung *vor dem Sprung* ist genau die Kostenbremse |

```sh
for s in folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht re-baseline-ohne-inventur-slice \
         baseline-aussage-ohne-mess-tag delta-durchgang-uebersieht-deckung \
         baseline-sprungweite-treibt-kosten; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Zwei erreichen mit diesem Slice 3×, wenn er die Klasse erneut auslöst** —
`re-baseline-ohne-inventur-slice` und `baseline-aussage-ohne-mess-tag` stehen bei **2×**. Das ist
kein Grund, jetzt einen Folge-Slice zu schneiden: Den Übertritt erkennt der **Lese-Schritt**, den in
diesem Repo die Welle-Closure trägt, und er tritt nur ein, wenn die Klasse **wieder** auftritt. Die
Sichtung notiert ihn, damit die Closure hinsieht. **Ein eigener Folge-Slice entsteht aus der
Sichtung also nicht.**

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF — das Dokument entsteht neu, Doc führt.
- **Konventionen-Dichte:** hoch für den **Baseline-Umgang**, niedrig für den **Gegenstand**. Der
  vendored Baum, seine Integrität und die Form jeder Aussage über ihn sind in
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
  [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  geregelt. Für die Zuordnung *Vorlage → Instanz* führt der Adaptions-Block **keinen** Eintrag —
  das ist die Lücke, die dieser Slice benennt, und der Grund für die Auflage in §1.
- **Phase-Reife:** Phase 3 für die Migrations-Achse. Der Sprung selbst hat sechs Entscheidungen und
  eine gebuchte Zielstand-Setzung; was fehlt, ist der Schritt **zwischen** Entscheidung und
  Vollzug — die Inventur. Dass sie fehlt, ist gemessen und nicht vermutet: `re-baseline-ohne-
  inventur-slice` steht bei **2×**.
- **Evidenz-/Diskrepanz-Risiko:** **mittel**, und die tragende Diskrepanz ist nicht Doku gegen Code,
  sondern **Vorlage gegen Instanz**: Der Form-Vergleich des Freshness-Audits zeigt, was sich an der
  Vorlage geändert hat, und niemand führt, welches Artefakt ihm folgen müsste. Die Inventur, die das
  sichtbar macht, **ist** Liefer-Punkt (1) — ihr Ergebnis kann die Rückführung `in-progress` →
  `next` auslösen (§4), wenn die Zuordnung je Vorlage eine eigene Entscheidung verlangt.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers; die Datei `reconciliation.md` existiert in diesem Repo nicht
  (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das zugehörige DoD-Item entfällt
  deshalb in §2. Graduation entfällt (n/a bei GF). Der Trigger, der die Achse auf Phase 4 höbe, ist
  der erste Report unter `docs/migrations/<tag>.md` — er entsteht mit dem nächsten Sprung und nicht <!-- d-check:ignore (geplante Ablage) -->
  mit diesem Slice (§1).

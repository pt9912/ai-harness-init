# Slice slice-flache-welle-ist-eroeffnet-nicht-geplant: Die vier Rest-Träger der Wellen-Ablage lehren die geltende Arbeitsweise

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der
Gegenstand ist ein Text-Nachzug an vier gemessenen Stellen, und sein Beleg ist der
`docs-check`-Lauf, der ohnehin in jeder DoD steht (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind vier **lebende** Artefakte **dieses** Repos.
Die emittierte Vorlage, die das Werkzeug in ein Zielrepo schreibt, bleibt unberührt (§1) — die zwei
Ebenen tragen verschiedene Verträge und verschiedene Gründe.

**Bezug:**
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (Festlegung 1 setzt die
Arbeitsweise, die diese vier Stellen noch anders lehren),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind vier
Planungs-Artefakte).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Kein lebendes Planungs-Artefakt dieses Repos setzt die flache Welle-Datei mehr mit
*geplant* gleich — die Gleichsetzung, die
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 beendet.

### Die Fundmenge ist gemessen, nicht aufgezählt

Der Vorgänger `slice-wellen-schnitt-folgt-der-eroeffnungs-regel` zog die drei Träger nach, die
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen namentlich
nennt, und ließ vier weitere lebende Stellen stehen — der Ziel-Satz war weiter als die
Aufzählung, an der er sich maß
([`BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md)).
Dieser Slice beginnt deshalb mit der Menge:

```sh
git grep -l 'aktuell\* oder \*geplant\*' \
  -- ':!docs/plan/planning/done' ':!docs/reviews' ':!.harness/baseline' | wc -l   # 4
git grep -c 'Die aktive Welle liegt flach' -- 'docs/plan/planning/welle-*.md' | wc -l   # 3
grep -c 'die \*\*aktive\*\* Welle liegt \*\*flach\*\*' docs/plan/planning/README.md     # 1
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei wandern mit dem Stand; der erste Schritt der Umsetzung ist, sie neu zu
fahren. Die vier Dateien sind `docs/plan/planning/README.md` und die `Lifecycle:`-Kopfnoten von
`welle-09`, `welle-11` und `welle-13`; in den drei Kopfnoten ist es **derselbe** Satz, und die
Zeile darüber (*„Die aktive Welle liegt flach unter …"*) trägt dieselbe Gleichsetzung ein zweites
Mal.

**Die Ziel-Form muss nicht erfunden werden.** Die vendored Welle-Vorlage führt die geltende
Fassung bereits — `v6.8.0` · `templates/docs/plan/planning/welle.template.md`, Kopfnote
*„Diese Datei entsteht bei der **Eröffnung** der Welle … **Geplante Wellen bekommen noch keine
Datei**"*
(`grep -c 'Geplante Wellen bekommen noch keine' .harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md`
→ **1**, kein Erwartungswert). Die drei Kopfnoten werden an sie angeglichen, statt neu formuliert.

**Und jeder Träger hat seine eigene Ziel-Form.** Die Welle-Vorlage oben gilt für die drei
`Lifecycle:`-Kopfnoten und für sonst nichts; für
[`docs/plan/planning/README.md`](../README.md) führt das Instanz-Register
[`harness/migration.md`](../../../../harness/migration.md) eine andere —
`v6.8.0` · `templates/docs/plan/planning/README.template.md` §Slices vs. Wellen. Sie trägt neben
derselben Aussage über die flache Datei die Zuschreibung *Sequenzierungs-Autorität* an die Roadmap
(`grep -c 'Sequenzierungs-Autorität bleibt' .harness/baseline/v6.8.0/templates/docs/plan/planning/README.template.md`
→ **1**, kein Erwartungswert), die die Welle-Kopfnote gar nicht führen kann: Sie beschreibt ein
anderes Artefakt. Wer eine Instanz an die Vorlage ihres Nachbarn angleicht, verliert, was nur die
eigene trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  selbst.** Die Datei steht auf `Accepted` und ist nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren. *Bestand bleibt bewusst stehen.*
- **Keine Änderung an der emittierten Vorlage**
  [`internal/emit/templates/commands/plan-welle.md`](../../../../internal/emit/templates/commands/plan-welle.md).
  Sie trägt dieselbe Gleichsetzung (`grep -c 'aktiv/geplant' internal/emit/templates/commands/plan-welle.md`
  → **1**, kein Erwartungswert), aber auf der anderen Ebene: Was in ein Zielrepo geht, entscheidet
  ein eigener Vertrag. *Es wäre ein anderer Vorgang.*
- **Keine Eröffnung und keine Schließung einer Welle, und keine Aussage darüber, ob `welle-09`,
  `welle-11` oder `welle-13` ihre Beginn-Bedingung erfüllt.** Das ist ein Urteil je Welle
  ([ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung
  nicht tut). *Es wäre ein anderer Vorgang.*
- **Kein Nachzug an `close-welle.md`.** Sein Schritt 6 lehrt eine **Beförderung**, die
  Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 6 mit *„Befördert wird
  niemand"* ausschließt — eine **andere** Norm-Aussage mit einem **anderen** Alter.
  *Es wäre ein anderer Vorgang.*
- **Kein Produkt-Code.** `internal/`, `cmd/` und `harness/tools/` bleiben unberührt.
  *Schicht-Abgrenzung.*

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

**Zwei Liefer-Punkte, einer je Fassung des Satzes:**

- [x] **(1) Die `Lifecycle:`-Kopfnote der drei offenen Welle-Dateien (`welle-09`, `welle-11`,
      `welle-13`) trägt die Gleichsetzung nicht mehr** — weder *„Die aktive Welle liegt flach"*
      noch *„Ob eine flache Welle aktuell oder geplant ist, sagt die Roadmap"*. Sie ist an die
      Kopfnote der vendored Vorlage angeglichen (§1), **ersetzt und nicht ergänzt**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Geprüft an der gemessenen Fundmenge, nicht an
      den drei Dateinamen: die zwei `git grep`-Kommandos aus §1 liefern danach `0`.
      **Und die angeglichene Zeile trägt die Kennung dieser Welle, nicht den Platzhalter der
      Vorlage** — die Angleichung gilt der **Aussage**, nicht den Bytes (§6 Risiko 1), und wer die
      Zeile ohnehin anfasst, zieht sie nach ([`AGENTS.md`](../../../../AGENTS.md) §3.7):
      `grep -c 'welle-<Kennung>-results\.md' docs/plan/planning/welle-*.md | grep -cv ':0$'`
      liefert danach `0` (kein Erwartungswert).
- [x] **(2) `docs/plan/planning/README.md` §Slices vs. Wellen ist an *seine eigene* Ziel-Form
      angeglichen** — `v6.8.0` · `templates/docs/plan/planning/README.template.md`
      §Slices vs. Wellen, die das Instanz-Register
      [`harness/migration.md`](../../../../harness/migration.md) für genau diese Datei führt; nicht
      an die Kopfnote der Welle-Vorlage, die ein anderes Artefakt beschreibt. Die Aussage deckt
      sich mit [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 —
      flach heißt *eröffnet*, geplante Wellen haben keine Datei —, und die Ziel-Form trägt daneben
      die Zuschreibung **Sequenzierungs-Autorität** an die Roadmap, die dabei nicht verloren geht:
      `grep -c 'Sequenzierungs-Autorität' docs/plan/planning/README.md` liefert danach `1` (kein
      Erwartungswert). Der Absatz ist ersetzt, nicht ergänzt.
      **Zwei Grenzen, damit die Angleichung nicht in einen Byte-Import kippt:** Was die Ziel-Form
      nennt und dieses Repo nicht führt, kommt nicht mit — namentlich `reconciliation.md`
      (`ls docs/plan/planning/reconciliation.md` → Exit 2, §8); und die eigene Sektion
      `## Beobachtungs-Register` daneben bleibt stehen, sie ist die repo-eigene Fassung desselben
      Gegenstands.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Liefer-Punkte (1) und (2) **sind** dieses Item — beide Träger sind
      Planungs-Doku.
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
| `welle-09`, `welle-11`, `welle-13` — je die `Lifecycle:`-Kopfnote | update | derselbe Satz dreimal, an `welle.template.md` angeglichen, Kennung statt Platzhalter — Liefer-Punkt (1) |
| [`docs/plan/planning/README.md`](../README.md) §Slices vs. Wellen | update | die zweite Fassung derselben Gleichsetzung, angeglichen an `README.template.md` §Slices vs. Wellen — Liefer-Punkt (2) |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist Prosa in vier lebenden
Dateien; ihr Wächter ist der Gate-Lauf über den Bestand, den sie beschreiben. Ein `*_test.go` oder
`*.bats` daneben hielte den Text gegen eine zweite Fassung seiner selbst.

**Und keine Gate-Zusage über den Nachzug hinaus.** Kein Modul des Doku-Gates liest eine
Lifecycle-Kopfnote auf ihre Aussage; `docs-check` bleibt über beiden Fassungen grün. Träger ist
der Lauf, nicht ein Sensor — die Klasse, an der der Vorgänger-Slice zwei MEDIUM-Findings einfing
([`BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md)).

**Reihenfolge:** erst die drei Kommandos aus §1 neu fahren, dann ersetzen — **ersetzen, nicht
danebenstellen** ([`AGENTS.md`](../../../../AGENTS.md) §3.7).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice**, und kein
Wellen-Vorgang läuft parallel — weder eine Eröffnung noch eine Closure schreibt an einer der
drei Welle-Dateien. Beobachtbar ohne Rückfrage, auf dem **Hauptzweig**:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'   # 0  (WIP frei; Exit 1 bei 0)
```

**Der Trigger ist kein Ergebnis dieses Slice** — er spricht über den Bestand von `in-progress/`
vor der Arbeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Die Angleichung an die vendored
  Kopfnote verlangt mehr als einen Text-Nachzug** — etwa weil der README-Abschnitt nur zusammen
  mit einer Umstellung seiner Gliederung richtig wird. Dann liefert dieser Slice eine
  **Form-Änderung** neben dem Nachzug, und Form gehört vor Nachzug.
- `in-progress` → `open` (blockiert — Carveout?): **Eine Welle wird eröffnet oder geschlossen,
  während dieser Slice läuft.** Beide Vorgänge schreiben an denselben Dateien; der Konflikt ist
  die Parallelität, nicht die Sache.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Die drei Mess-Kommandos aus §1 liefern `0`**, und `make gates` meldet Exit 0.
2. **Die drei Kopfnoten und der README-Absatz sind gegen die Ziel-Form gelesen**, nicht gegen das
   Wortmuster: Der Umsetzungs-Commit trägt je Träger die neue Fassung und das Kommando, mit dem
   die Ziel-Form aus der vendored Vorlage gelesen wurde (§1).

**Lerneintrag:** die Form entscheidet die Closure und nicht dieser Plan. Was aus
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) folgt, trägt bereits eine ID
und braucht keinen zweiten Anker (Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker, Geltungsbereich); das Feld `liegt in` steht nur, wenn mit diesem Slice wirklich
eine Regel verkörpert wurde.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Angleichung nimmt aus der Vorlage eine Aussage mit, die dieses Repo nicht führt.**
  Die vendored Kopfnote ist Fremdtext; sie nennt Pfade und Formen, die ein adoptierendes Repo
  anders hält — die gemessene Klasse
  [`BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`](../observations/BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt/observation.md).
  **Gegenmittel im Plan:** Liefer-Punkt (1) verlangt die Angleichung der **Aussage**, nicht die
  Byte-Übernahme des Absatzes.
  — **Ausgang: eingetreten**, aufgefangen von `slice-planning-readme-beschreibt-die-eigenen-lifecycle-verzeichnisse`.
  Dreimal gemessen, und das Gegenmittel hat zwei davon gehalten: den Platzhalter
  `welle-<Kennung>-results.md` in der `welle-13`-Kopfnote und den Satz *„… und nirgends sonst"* im
  README (Runde 1, F-3 und F-4). Den dritten hat es nicht gehalten — §Slices vs. Wellen trägt jetzt
  *„Der aktive Durchlauf `open/` → `next/` → `in-progress/` nimmt ausschließlich **Slices** auf"*,
  zwei Zeilen unter einem Link auf `in-progress/roadmap.md` (Runde 2, R2-1). Er entstand in dem
  Nachzug, der die **richtige** Ziel-Form gelesen hatte: Das Gegenmittel adressiert die falsche
  Vorlage, nicht den falschen Satz aus der richtigen.
- **(2) Der Nachzug stellt die alte Arbeitsweise daneben, statt sie zu ersetzen.** Ein Absatz
  *„bis [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) entstand die Datei
  früher …"* ist Chronik im lebenden Artefakt — die Klasse
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
  **Dafür trägt kein Wächter:** [`AGENTS.md`](../../../../AGENTS.md) §3.7 nennt als
  Geltungsbereich Code, Konfiguration, Skripte und die Zustandsfelder der lebenden Register —
  Markdown-Fließtext steht in keinem davon.
  **Gegenmittel im Plan:** §3 macht *ersetzen statt danebenstellen* zur Reihenfolge-Regel.
  — **Ausgang: entfallen.** Beide Review-Runden haben es gemessen statt geglaubt: je Träger **ein**
  Hunk, die alte Fassung steht in keiner der fünf berührten Dateien neben der neuen, und über
  sämtliche hinzugefügten Zeilen trifft das Chronik-Muster (*früher · bisher · seither · nicht
  mehr · wäre · hätte · Review-Befund · `slice-[0-9]` · vorher · zuvor*) **0**. Das Risiko kann für
  diesen Slice nicht mehr eintreten, weil sein Gegenstand abgeschlossen ist; für den Folge-Slice
  steht es dort neu.
- **(3) Die drei Welle-Dateien sind offen, und ihr Rumpf trägt datierte Messungen.** Wer beim
  Nachziehen der Kopfnote eine Messzahl im Rumpf mitkorrigiert, schreibt eine Messung um, die zu
  ihrem Datum richtig war. **Gegenmittel im Plan:** Liefer-Punkt (1) nennt allein die Kopfnote;
  der Beleg ist ein Zahlen-Diff über die ganze Datei, wie ihn der Vorgänger-Slice gefahren hat.
  — **Ausgang: entfallen.** Der Zahlen-Diff über alle vier Träger der ersten Runde lieferte **null**
  Differenzen, und kein Hunk lag außerhalb des Kopfes; die zweite Runde bestätigte für den
  Nachzug dasselbe — bewegt sind ausschließlich Token des ersetzten Absatzes und die Kennung `13`,
  kein Rumpf und keine datierte Messung. Das Risiko kann für diesen Slice nicht mehr eintreten:
  Seine drei Welle-Dateien sind nicht mehr im Zugriff dieses Vorgangs.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die gemessene Fundmenge.** §1 hat die vier Träger vor dem Schnitt
  gezählt statt aufgezählt; beide Review-Runden sind die drei Kommandos neu gefahren und haben
  keine fünfte lebende Stelle gefunden. Das war der Ausgang, den der Vorgänger-Slice offen ließ.
  **Und die Ebenen-Trennung:** Die emittierte Vorlage trägt dieselbe Gleichsetzung unverändert
  weiter, weil §1 sie als *anderen Vorgang* ausgeschlossen hat — beide Runden haben es geprüft.
- **Was ging anders als geplant:** **Der Plan nannte eine Ziel-Form für vier Träger, und es waren
  zwei.** Die vendored Welle-Vorlage deckt die drei `Lifecycle:`-Kopfnoten; für
  `docs/plan/planning/README.md` führt das Instanz-Register eine eigene, und nur die trägt die
  Zuschreibung *Sequenzierungs-Autorität* an die Roadmap. Der Umsetzungs-Lauf glich die Datei an
  die Vorlage ihres Nachbarn an und verlor sie — merge-blockierendes MEDIUM, behoben im zweiten
  Lauf, nachdem der Plan die Zuordnung nachgetragen hatte.
  **Und der Schnitt hat eine Rollen-Grenze getroffen, die es nicht gab.** Das HIGH der ersten Runde
  meldete einen Rollen-Widerspruch am Welle-Plan; keine Quelle trug ihn, und auch keine trug die
  Gegenposition. Die Auflösung lief über den Konflikt-Pfad (Baseline-Regelwerk
  `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz) und kostete ein Architect-Verdikt
  und drei Konsistenzrunden.
- **Steering-Loop-Eintrag — geschärfte Regel:** Die Rollen-Grenze am Welle-Plan ist geschrieben. Ein
  **vorlagengebundener Nachzug** an einem bereits eröffneten Welle-Plan darf im
  Implementations-Kontext laufen, wenn er vier Bedingungen zugleich erfüllt; jeder andere Vorgang an
  dieser Datei bleibt Planner-Arbeit
  ([ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1,
  `Accepted`). **Kein Feld `liegt in`:** Die Regel trägt eine ADR-ID und stammt nicht aus der
  3×-Schwelle — sie braucht keinen zweiten Anker (Baseline-Regelwerk `grundlagen-traceability.md`
  §Herkunfts-Anker, Geltungsbereich). Ihre **Urteilsgrundlage** hat noch keinen Träger: Dass die
  prüfende Rolle die Grenze liest, entscheidet der Reviewer, und der Vorgang dafür hat jetzt eine
  Lifecycle-Adresse (Folge-Slices unten).
  **Benannte Lücke, gezählt statt verkörpert:** Kein Modul des Doku-Gates hält eine **Instanz** gegen
  die Vorlage, die das Instanz-Register [`harness/migration.md`](../../../../harness/migration.md)
  ihr zuordnet. Genau daran ist das MEDIUM entstanden und unentdeckt durch ein grünes
  `make docs-check` gegangen. Die Lücke steht als Registereintrag und wartet auf ihre Schwelle; ein
  Sensor wird hier **nicht** behauptet
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Beobachtungs-Register (`../observations/`):** fortgeschrieben — **fünf** Verzeichnisse neu
  angelegt, **dreizehn** Belege geschrieben, verteilt auf **zwei** Vorgänge. Der Zähler wird nicht
  gesetzt; er folgt aus den Dateien
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
  Erwartungswerte).

  **Zwei Vorgangs-Kennungen, nicht vier.** `slice-flache-welle-ist-eroeffnet-nicht-geplant` trägt,
  was das Review dieses Slice fand; `2026-09-14-adr-0048-eigentum-haengt-am-vorgang` trägt, was die
  drei Konsistenzrunden an der Entscheidung fanden. Die drei Runden sind **ein** Vorgang: Sie prüfen
  dieselbe Arbeit an derselben Datei, und ein Vorgang zählt einmal — sonst misst der Zähler
  Iterationstiefe statt Wiederholung. Die Form folgt dem Bestand, der eine ADR-Arbeit und eine
  einzelne Konsistenzrunde bereits als Vorgangs-Kennung führt.

  | Eintrag (`BEO-ALL/<slug>`) | Vorgang | Zähler danach |
  |---|---|---|
  | `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | Slice | 2× |
  | `baseline-aussage-ohne-mess-tag` | **beide** | 4× |
  | `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | Slice | 20× |
  | `instanz-und-ihre-ziel-form-fallen-auseinander` *(neu)* | Slice | 1× |
  | `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` *(neu)* | Slice | 1× |
  | `mess-zusage-trifft-das-eigene-zitat` | ADR-Vorgang | 5× |
  | `zusammenfassung-staerker-als-ihre-quelle` | ADR-Vorgang | 8× |
  | `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | ADR-Vorgang | 10× |
  | `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | ADR-Vorgang | 6× |
  | `festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten` *(neu)* | ADR-Vorgang | 1× |
  | `probe-und-ihr-belegter-fall-fallen-auseinander` *(neu)* | ADR-Vorgang | 1× |
  | `acceptance-trigger-ohne-fach-fuer-den-gemeldeten-befund` *(neu)* | ADR-Vorgang | 1× |

  **Einer bekommt ausdrücklich keinen Beleg, und das ist gemessen.**
  `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` verlangt nach seiner eigenen
  `observation.md` ein Artefakt, *„dessen Eigentum **eine Quelle** einer anderen Rolle zuweist"*.
  Für einen vorlagengebundenen Nachzug an einem laufenden Welle-Plan tut das keine — die Messung
  aus [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Kontext ist in
  dieser Closure unabhängig reproduziert (**3** im engen Prüfbereich, **4** in der breiteren
  Gegenprobe, alle drei Stellen gelesen; keine Erwartungswerte), und die zweite Review-Runde kommt
  für `docs/plan/planning/README.md` zum selben Ergebnis. Der Zähler bleibt bei **9**. Was
  stattdessen zutrifft, steht in `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`
  — der Klasse, an deren Zähler
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) ihren fünften
  Re-Evaluierungs-Trigger hängt.

  **Aufnahme-Maßstab, damit die nächste Runde ihn prüfen kann.** Eingetragen ist eine Finding-Klasse,
  wenn ihr Verzeichnis schon besteht · **oder** sie in mindestens zwei der vier Reports auftrat ·
  **oder** sie an eine repo-weite Praxis mit eigenem Register gebunden ist (das Instanz-Register).
  **Nicht eingetragen, benannt statt gezählt:** *Stellen-Messung trägt die Folgerung über eine
  Eigenschaft* — die Regel steht bereits verkörpert als
  [`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft),
  und ihr Eintrag benennt selbst, wo die Rest-Unterklasse geführt wird; ein dritter Pfad teilte sie.
  Dazu sechs Einmal-Labels, die Formulierungs-Entscheidungen **dieses einen Dokuments** beschreiben
  (*Auslegungs-Ort nicht als Wahl benannt · Folgepflicht wartet auf einen blockierten
  Statuswechsel · Acceptance-Trigger zwischen zwei Runden geändert · Begründungssatz widerspricht
  einer Bedingung derselben Datei · Wiedergabe einer fremden Festlegung richtungsoffen formuliert ·
  Vollständigkeits-Behauptung über die eigene Aufzählung*) sowie ein INFO ohne Defekt (*Maßstab
  zwischen zwei Runden stabil*). Tritt eines davon erneut auf, vergibt die nächste Closure die
  Kennung.

  **Zwei Posten für den Lese-Schritt der nächsten Welle-Closure, damit sie nicht durchrutschen:**
  `baseline-aussage-ohne-mess-tag` steht mit dieser Closure bei **4×** und trägt weiter `offen` —
  den Ausgang weist der Lese-Schritt zu, nicht diese Slice-Closure (Wellen-Betrieb). Und der
  **dritte** Re-Evaluierungs-Trigger von
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) ist gefeuert: Dieser
  Vorgang hat eine Eigentums-Frage an `docs/plan/planning/README.md` gestellt; das gehört ins
  Trigger-Audit, Schritt 2.
- **Folge-Slices:** zwei, beide als Datei im Planning-Lifecycle angelegt und als **Kennung** genannt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.11 — der Lifecycle bewegt sie, diese Notiz friert ein):
  `slice-die-vorgangs-grenze-erreicht-den-reviewer-skill` (in `next/`) ist die zweite Hälfte des
  Übergabe-Artefakts zum Konflikt-Verdikt und gibt der einzigen Folgepflicht ohne eigenen Moment
  eine Adresse; `slice-planning-readme-beschreibt-die-eigenen-lifecycle-verzeichnisse` (in `open/`)
  ist der Ausgang von Risiko 1 und nimmt den INFO-Befund derselben Datei mit.
- **Risiken aus §6:** alle drei mit genau einem Ausgang — (1) **eingetreten**, aufgefangen vom
  Folge-Slice; (2) **entfallen**, mit Messung; (3) **entfallen**, mit Messung. Siehe §6.
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**,
  kein Erwartungswert) — geprüft von der nächsten Welle-Closure, auch für diesen Slice ohne
  Wellen-Zugehörigkeit. Beide Folge-Slices existieren als Datei, alle zitierten Beobachtungs-Pfade
  als Verzeichnis mit nicht leerem `evidence/`, und ein Anker ist nicht fällig: Der
  Steering-Loop-Eintrag oben trägt kein Feld `liegt in`.

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
([`AGENTS.md`](../../../../AGENTS.md) §3.7,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)),
eigener Prüfbereich ([`make docs-check`](../../../../harness/sensors/docs-check.md)) und eigene
Fehlermodi (eine Anleitung, die in ein rotes Gate führt). **`TOOLS` und `CODEX` sind geprüft und
nicht berührt:** Keine Aussage über `harness/tools/` oder `.codex/` ändert sich.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**107** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. **Vier Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` | 7× | geplant (`slice-209`) | §1 — dieser Slice **ist** ihr Ausgang für den Vorgänger |
| `zusage-neben-geaenderter-ableitung-bleibt-stehen` | 24× | geplant (`slice-153`) | §6 Risiko 2 — vier Zusagen neben einer geänderten Ableitung |
| `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` | 1× | offen | §3 — der Nachzug schreibt keine Gate-Zusage über seinen Prüfumfang hinaus |
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 1× | offen | §6 Risiko 1 — die Ziel-Form kommt aus Fremdtext |

```sh
for s in korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge \
         zusage-neben-geaenderter-ableitung-bleibt-stehen \
         gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang \
         vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Keiner der vier erreicht mit diesem Slice 3×** — zwei stehen längst darüber und tragen ihren
Ausgang, zwei stehen bei 1×. **Ein eigener Folge-Slice entsteht aus der Sichtung also nicht.**

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — was ein lebendes Artefakt tragen darf, steht in
  [`AGENTS.md`](../../../../AGENTS.md) §3.7, die Zahl-Disziplin in
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert);
  die Ziel-Form der Kopfnote steht in der vendored Vorlage.
- **Phase-Reife:** Phase 4 für die Planungs-Doku — der Lifecycle ist bewacht
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l` → **8**, kein Erwartungswert), die
  Kopfnote selbst ist es nicht.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig**. Die Fundmenge ist vor dem Schnitt gemessen (§1),
  die Ziel-Form liegt vor, und der Gegenstand ist vier Absätze Prosa ohne Code-Kopplung.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund; die Datei `reconciliation.md`
  existiert in diesem Repo nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das
  zugehörige DoD-Item entfällt deshalb in §2. Graduation entfällt (n/a bei GF).

# Slice slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt: Ein bats-Fall hält die Zeile unter `codepaths:` gegen die Form-Regel des Nachzugs

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — dieser Slice trägt keine Closure-Bedingung, die über seine
DoD hinaus etwas beobachtet, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
(`Accepted`; Folgepflicht 4 und Fitness-Zeile 6),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate sagt nur über seinen Prüfbereich etwas; der Prüfbereich wird hier nicht verkleinert).

**Berührte Spec-Stellen:** `—` — Prozess-ADR ohne Spec-Stratum: sie ändert die
Reichweite eines Werkzeugs, keine Spec-Aussage und keine Gate-Schwelle.
Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-26.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein bats-Fall im Stil von `test/sources-pin.bats` hält die Zeile
`exempt-paths: ["docs/reviews/**"]` unter `codepaths:` in `.d-check.yml` gegen die Form-Regel des
Nachzugs: Fällt die Zeile und die Form-Regel bleibt, färbt der Test rot
([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Folgepflicht 4, Fitness-Zeile 6). Die Form-Regel besteht nur, solange das Gate die Code-Span-Form in
`docs/reviews/**` nicht prüft; der Test macht diese Abhängigkeit zu einer Zusage zwischen zwei
Dateien.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Träger der Form-Regel** — zwei Folge-Slices übernehmen sie:
  `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` (`make slice-mv`) und
  `slice-archive-welle-schreibt-in-reports-nur-die-link-form` (`archive-welle`). Dieser Slice
  **folgt** beiden (§4): davor bewachte der Test eine Regel, die kein Träger führt.
- **Eine Änderung an `.d-check.yml`** — die Datei bleibt unberührt, die Kopplung steht im Test, nicht
  in einem Kommentar der Config; und die Entscheidung in
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 2 ist ausdrücklich keine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5.
- **Die Wahrheit der Gate-Begründung** — der Test hält, dass die Zeile **da ist**, nicht dass
  `codepaths` einen Pfad-Span in einem Report tatsächlich nicht prüft; das wäre ein Lauf des
  Doku-Gates gegen eine konstruierte Probe, und die Aussage ist in der ADR als Messung geführt, für
  die kein Sensor existiert.
- **Die Gegenrichtung: ob die Form-Regel in den Trägern noch steht** — der Test hält die **Bedingung**
  (die Zeile), nicht die Implikation *Regel ⇒ Zeile*. Fällt die Zeile, färbt er rot, gleichgültig ob
  die Träger die Regel noch führen; das ist gewollt, denn dann greift Re-Evaluierungs-Trigger 1 der
  ADR (die Regel ist zu streichen, ein Folge-ADR-Vorgang), und ein grüner Test darüber wäre ein
  stilles Grün. Seine Meldung nennt deshalb die Zeile **und** den Trigger. Die Träger-Seite halten die
  Fälle in `test/slice-mv.bats` und in `internal/archive` (`docs/reviews` ist **nicht** in
  `eingehend_ausgenommene_pfade` in `harness/tools/slice-mv.sh` und nicht in `AusgenommenePfade()` in
  `internal/archive/scan.go` — Bestand, dort gebunden, kein Gegenstand dieses Slice).
- **Die emittierte Fassung** (`internal/emit/templates/enforce/slice-mv.sh`) — sie führt die Form-Regel
  nicht und liest ihre Ausnahmen aus `SLICE_MV_AUSGENOMMENE_PFADE`; der Test gilt dem Dogfood-Repo und
  wird nicht emittiert (Schicht-Abgrenzung; `harness/sensors/slice-mv.md` §Im gebootstrappten Ziel).
- **Trigger 2 der ADR (`links` bekommt für `docs/reviews/**` eine Ausnahme)** — die ADR verlangt
  dafür keinen Fall (Fitness-Zeile 6 nennt nur die `codepaths`-Zeile), und eine Zusage ohne rot
  gesehenes Gegenbeispiel wäre [`AGENTS.md`](../../../../AGENTS.md) §3.6 verletzt.

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
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Liefer-Punkt 1 — der Kopplungs-Test.** Ein bats-Fall hält die Zeile
      `exempt-paths: ["docs/reviews/**"]` **unter `codepaths:`** in `.d-check.yml`; in dieser Datei
      tragen andere Blöcke `docs/reviews/**` in eigenen `exempt-paths`-Zeilen, und der Fall bindet
      allein die unter `codepaths:`. *Bricht, wenn:* die Zeile unter `codepaths:` entfällt und die
      Form-Regel bleibt — der Test färbt rot, und seine Meldung nennt die `codepaths`-Zeile
      (Rot ist gesehen **und** die Meldung gelesen, und sie nennt neben der Zeile den
      Re-Evaluierungs-Trigger 1 der ADR); eine andere `exempt-paths`-Zeile mit
      `docs/reviews/**` zu entfernen lässt ihn grün, ebenso das Entfernen oder Ändern der
      Kommentarzeile im Block — und die Zeile als **Kommentar** zu setzen statt zu entfernen färbt
      ihn rot.
- [x] **Liefer-Punkt 2 — der Mutations-Fall, der ihn bindet.** Ein Fall in `test/mutations/` entfernt
      die Zeile unter `codepaths:` in einer Kopie und erwartet genau diesen Test rot. *Bricht, wenn:*
      der Fall auch bei einer Mutation rot bliebe, die eine **andere** Zeile trifft (dann deckt ein
      anderer Zweig ihn, und der Zahn ist unbewacht); Anker gegen den Quell-Bestand gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| eine bats-Datei unter `test/` | neu | Liefer-Punkt 1: Kopplungs-Fall im Stil von `test/sources-pin.bats` (nur Datei-Vergleich, netzlos, läuft in `make gates`) |
| `test/mutations/` | neu | Liefer-Punkt 2: ein Fall, der die Zeile unter `codepaths:` entfernt; Anker gegen den Quell-Bestand gemessen |

- **Größenurteil.** Zwei Liefer-Punkte, eine Schicht (Test gegen Config). Der Schnitt trennt den
  Test von den Trägern, weil er eine Config-Zeile hält und keinen Träger-Code; die Begründung
  steht im Geschwister `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`, §3.
- **Ansatz.** Der Fall liest den Abschnitt `codepaths:` der `.d-check.yml` und sucht die Zeile
  **darin**, nicht irgendwo in der Datei; die Kopplung wird im Kommentar des Tests als Kopplung
  genannt, mit
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) als
  Rang-Zeiger.
- **Schicht und Lauf.** Ein bats-Fall in `test/` (Text gegen Text, kein Container-Aufruf, netzlos)
  läuft in `make test-bats`, damit in `make test` und `make gates`; eine Go-Test-Fassung entfällt,
  weil beide Seiten der Kopplung Text sind und die Go-Liste nicht Gegenstand ist (§1). Die Wahl der
  Abschnitts-Erkennung — Werkzeug und Muster — bleibt beim Implementer; gebunden ist, was sie liefern
  muss: nur Zeilen unter dem Top-Level-Schlüssel `codepaths:` bis zum nächsten Top-Level-Schlüssel
  (`vcs:` am Stand der Planung), **Kommentarzeilen ausgenommen**.
- **Gemessen am Baum (2026-09-26, keine Erwartungswerte).** Die Zielzeile steht genau einmal, mit
  zwei Zeichen Einrückung: `grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml` gibt 1
  aus. Vier weitere Zeilen der Datei tragen `exempt-paths` **und** `docs/reviews/**` — drei unter
  `ids` (mit `CHANGELOG.md`), eine unter `matrix` mit eigener Liste — und die **Kommentarzeile**
  darüber, im Block `codepaths:` selbst, nennt beide Wörter ebenfalls
  (`grep -n 'exempt-paths' .d-check.yml | grep 'reviews'` zählt sechs Zeilen). Ein Muster über die
  ganze Datei oder über den Block ohne Kommentar-Ausschluss bliebe bei entfernter Zeile grün.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` **und**
`slice-archive-welle-schreibt-in-reports-nur-die-link-form` liegen in `done/`
(`ls docs/plan/planning/done | grep -c -e slice-lifecycle-move-schreibt-in-reports-nur-die-link-form -e slice-archive-welle-schreibt-in-reports-nur-die-link-form`
gibt 2 aus) — kein Ergebnis dieses Slice, also ein zulässiger Start-Trigger. Beide Träger liegen in `done/`; das Kommando gibt am 2026-09-26 **2** aus, der Trigger ist damit
eingetreten.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Fall lässt sich nicht an den Abschnitt
  `codepaths:` binden, ohne die `.d-check.yml` zu parsen — dann ist das ein Werkzeug-Bau, kein Test.
- `in-progress` → `open` (blockiert): `codepaths.exempt-paths` nimmt `docs/reviews/**` nicht mehr
  aus (Re-Evaluierungs-Trigger 1 der ADR) — die Form-Regel ist dann zu streichen und dieser Slice
  gegenstandslos, er geht als Stilllegung nach `done/`.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Der Kopplungs-Fall läuft in `make gates` grün, und der Rot-Beleg aus der DoD ist einmal gesehen
   und in seiner Meldung gelesen; wo der Implementer-Bericht ihn nicht führt, trägt der Verifier
   ihn nach (Baseline-Regelwerk `modul-11-verification.md` §Bewusstes Brechen für
   DoD-Testbehauptungen).
2. Der Mutations-Fall färbt genau diesen Test rot (`make mutate` fährt ihn; kein Gate).

Der Lerneintrag steht in §7 in einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge stehen als Vorschau da; gesetzt werden sie bei der Closure.

- **Der Test greift die falsche Zeile** — eine andere `exempt-paths`-Zeile mit `docs/reviews/**`
  (unter `ids`, `matrix` oder einem anderen Block) **oder die Kommentarzeile im Block `codepaths:`**
  hielte ihn grün, wenn die Zeile unter `codepaths:` entfällt.
  **Ausgang:** *entfallen*, wenn die Gegenprobe — die Zeile unter `codepaths:` entfernt — ihn rot
  färbt und eine andere Zeile entfernt ihn grün lässt; und die Schärfe ist gebunden, wenn der
  Test in einer Kopie **geschwächt** (Muster über die ganze Datei statt über den Block) bei
  **entfernter** Zeile **grün** bleibt — grün heißt hier: die Block-Bindung ist es, die ihn rot
  gefärbt hat, und der Mutations-Fall meldet an dieser Kopie `BEFUND`. Färbt er den geschwächten Test
  dagegen rot, deckt ein anderer Zweig ihn, und der Zahn ist unbewacht.
- **Der Anker des Mutations-Falls liegt verschoben**
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
  **Ausgang:** *entfallen*, wenn der Anker gegen `.d-check.yml` am Stand der Implementation
  gemessen und der Fall an genau der behaupteten Mutation rot gesehen ist; sonst *eingetreten* und
  im Slice behoben.
- **Der Test bewacht eine Regel, die kein Träger führt** — folgt er den Trägern nicht (§4), ist er
  ein Zeiger ohne Gegenstand. **Ausgang:** *entfallen*, solange der Start-Trigger die zwei Träger
  verlangt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

Wird bei der Closure vom Planner geschrieben
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht vom Implementer; die Zeilen folgen der Vorlage.

Geschrieben von der Rolle Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review und
Verifikation. Alle Kommandos gemessen am 2026-09-26 am Stand `2dbc76c6`, keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

- **Was hat funktioniert:** Der Schnitt hielt: zwei Liefer-Punkte, eine Schicht, keine der beiden Rückführungen aus §4
  ausgelöst; die Abschnitts-Erkennung ließ sich ohne Parser als `awk` binden. Der Verifier (Stand `85643b3b`) bestätigte
  Liefer-Punkt 1 und 2 und fuhr das Rot selbst: `test/codepaths-reviews-ausnahme.bats` färbt bei entfernter Zeile unter
  `codepaths:` rot, die Meldung nennt die Zeile und Trigger 1 der ADR; bei entfernter Zeile in `ids` oder `matrix`, bei
  entfernten Kommentarzeilen und bei einer legitimen Erweiterung der Liste bleibt er grün; die Zeile als Kommentar färbt ihn
  rot. Beide Gegenproben unter `make mutate` (Test geschwächt: Muster über die ganze Datei · Block-Ende gestrichen) melden
  `BEFUND`, die Zähne binden also die behauptete Grenze. Ergebnis-Fakten:
  `git diff --shortstat 6125fe55~1..85643b3b -- test` → **3** Dateien, **97** Einfügungen;
  `ls test/mutations/*.sh | wc -l` → **463**.
- **Was ging anders als geplant:** Der Review (Stand `c3e274d9`; 0 HIGH, 1 MEDIUM, 1 LOW, 1 INFO) fand R-1: die Abschnitts-Erkennung
  sagte im Kommentar zwei Grenzen zu, Block-Ende und Kommentar-Filter, und Fall `474` band nur die Start-Grenze (entfiel das
  Block-Ende, blieb der Fall `ok`); R-2: das Muster hält genau die einzeilige Flow-Liste, äquivalentes YAML färbt rot, und die
  Meldung nannte dann Trigger 1 für eine Ausnahme, die nicht gefallen ist; R-3 (INFO): zwei Ränder des Musters ohne Fall. Der
  Implementer zog R-1 und R-2 in `22d24bfa` (Fall `475`, Zeile unter `vcs:` statt unter `codepaths:`) und `85643b3b` (Formgrenze
  im Test-Kopf, Meldung mit beiden Ursachen, Zusage zum Filter auf das Gehaltene eingeschränkt). **Gebaut, nicht geplant:** ein
  zweiter Mutations-Fall (§3 nennt einen); der Verifier wertete das als gleiche Art, gleiche Schicht, keine Ausweitung der
  Abnahme, **und der Planner schließt sich an.** **Wer was gelesen hat:** der Review las bis `c3e274d9`; `22d24bfa` und `85643b3b`
  hat **kein Reviewer** gelesen, der Verifier hat sie gemessen (V-2), der Planner hat beide Diffs gelesen. **Entscheidung zur
  Nachrunde: keine erneute Reviewer-Runde.** Der Nachrunden-Diff besteht aus Test-Kommentar und Meldungstext (`85643b3b`)
  und einem Mutations-Fall im Muster der Fälle `470` bis `474` (`22d24bfa`); er berührt keinen Träger-Code und keine Norm. R-1
  war MEDIUM und nicht blockierend, und die Prüfung, die ein zweiter Reviewer führte — den Fall gegen die behauptete Mutation
  und die geschwächte Fassung fahren —, hat der Verifier mit beiden Gegenproben unter `make mutate` und gelesener Meldung bereits
  geleistet. Das Häkchen *Review durchgeführt* bestätigt Runde 1 samt gezogenen Findings; ein zweiter Review-Report besteht nicht
  und wird nicht behauptet. **Liefer-Punkt 2 trägt über den Wortlaut hinaus:** Fall `475` ist der Zahn zum Block-Ende, Fall `474`
  der zum Blockanfang.
- **Mutate: Teilmessung, keine Gesamtaussage.** Real gefahren ist
  `make mutate MUTATE_JOBS=1 MUTATE_CASES='474-codepaths-reviews-ausnahme-entfaellt 475-codepaths-reviews-ausnahme-wandert-in-einen-nachbar-block'`
  (Verifier, Stand `85643b3b`): `2 ok, 0 Befund(e)`, `TEILLAUF 2 von 463 — kein Beleg`; der Beleg-Slot
  `.harness/state/mutate-passed.key` ist vorher wie nachher nicht vorhanden
  (`ls .harness/state/mutate-passed.key` → nicht vorhanden). **Nicht gefahren:** ein voller `make mutate`; der Beleg-Slot von
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist nicht geschrieben. Eine Aussage über das grüne Ganze
  trägt diese Closure nicht.
- **Nicht gemessen, benannt:** **Fall `475` bewacht eine latente Lage** — im Bestand steht nach `codepaths:` keine
  `exempt-paths`-Zeile (`sed -n '/^vcs:/,$p' .d-check.yml | grep -c 'exempt-paths'` gibt für den Bestand 0, die Zeile unter
  `vcs:` entsteht erst in der Mutation); der Test färbt am unveränderten Bestand nicht. **Der Kommentar-Filter der
  Block-Erkennung hat keinen Fall** und ist einzeln nicht bindbar (das Muster der Zusicherung deckt dieselbe Lage); die Zusage im
  Kommentar ist auf das Gehaltene eingeschränkt. **Die Ränder aus R-3** (eine `exempt-paths`-Zeile unter einem Unterschlüssel von
  `codepaths:`, der `#`-Ausschluss in der Klammer) sind vom Reviewer gemessen und vom Verifier nur gelesen; kein Fall hält sie.
  **Die Wahrheit der Gate-Begründung** — dass `codepaths` einen Pfad-Span in einem Report tatsächlich nicht prüft — ist nicht Gegenstand
  (§1) und nicht gefahren; die ADR führt sie als Messung. Einfache Anführungszeichen, unquotierter Wert und mehrzeilige Flow-Liste hat
  der Reviewer gefahren, der Verifier nicht; die Gegenprobe *Block-Ende gestrichen* gegen Fall `474` ist nur im bats-Lauf gefahren,
  nicht unter `make mutate`.
- **Steering-Loop-Eintrag (Form: neuer Sensor).** Die Kopplung zwischen der Form-Regel des Nachzugs und der Zeile unter `codepaths:` ist
  gemessen statt vorausgesetzt: `test/codepaths-reviews-ausnahme.bats` hält die Zeile, die Fälle `474` (Blockanfang) und `475`
  (Blockende) binden die Abschnitts-Erkennung. Der Sensor schließt die Lücke, die der Zustand der Beobachtung
  [`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/state.md)
  als Grenze der Verkörperung nannte. **Kein Zielort-Feld und kein Herkunfts-Anker:** der Sensor trägt die Kennung seiner Quelle
  ([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) Folgepflicht 4, Fitness-Zeile 6) selbst; die Paarung (a) hätte nichts, gegen
  das sie prüft. **Grenzen des Sensors, benannt:** er hält die **Zeile**, nicht die Wahrheit der Gate-Begründung; er hält die
  Schreibform (einzeilige Flow-Liste, doppelte Anführungszeichen), nicht die Aussage; er hält die **Bedingung**, nicht die
  Implikation *Regel ⇒ Zeile*; er ist ein Test gegen die Config dieses Repos und wird nicht emittiert.
  **Die geschärfte Regel aus dem Verifier-Vorschlag ist nicht verkörpert, und der Planner verkörpert sie nicht:** *ein Test, der eine
  Zeile an einen Abschnitt bindet, trägt für die Abschnitts-Erkennung je Grenze (Start, Ende) einen Mutations-Fall; die Gegenprobe zum
  Ende ist die Verschiebung in den Nachbar-Abschnitt, nicht das ersatzlose Entfernen.* Gelesen ist, was schon steht:
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 verlangt zu jeder Zusage das rot gesehene Gegenbeispiel, nennt aber weder die Grenze eines
  Abschnitts noch die Verschiebung als Gegenprobe (`sed -n '/^### 3\.6/,/^### 3\.7/p' AGENTS.md | grep -c 'Abschnitt'` → 0), und der
  Reviewer-Skill führt die MEDIUM-Zeile *Zusicherung über einer Menge, die leer sein kann*, die eine andere Lücke trifft. Die Regel
  steht damit im Register (unten, 2×) und nicht in einem Norm-Artefakt; Hard Rules und Reviewer-Skill schreiben Architect bzw. Reviewer
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Beobachtungs-Register (`../observations/`):** je Beleg
  `evidence/slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt.md`; Zähler gelesen mit
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Zwei Belege, keine neue Beobachtung, beide `offen`:**
  [`zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/observation.md)
  (**2×**; R-1 und V-1 — ein Vorgang zählt einmal: der Kommentar sagt Block-Ende und Filter zu, der Fall bindet nur den Anfang) und
  [`regel-rand-ohne-benannte-luecke`](../observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md)
  (**3×**; R-2 und R-3 — ein Vorgang zählt einmal: die Formgrenze und zwei Ränder des Musters standen nicht im Kommentar).
  **Dieselbe Beobachtung? — je Kandidat begründet, Urteil des Planners.** *R-1* nicht in
  [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  (4×, `verkörpert` für die Klasse), obwohl der Reviewer es nahelegt: dort hängt die Zusage allein an einer Assertion ohne Fall, hier sagt ein
  **Kommentar** eine Grenze zu, und der Fall bindet die eine Hälfte — die Beschreibung von `zusage-im-doc-kommentar-…` trifft die Lage
  wörtlich; wer R-1 der verkörperten Klasse zuordnet, hebt sie auf 5× (Ausgang unverändert) und lässt jene bei 1×. *V-1* (Zusage von zwei
  redundanten Mechanismen gedeckt, einzeln nicht bindbar) nicht als eigene Beobachtung: es betrifft dieselbe Zusage (der Filter im
  Kommentar) und ist im Vorgang behoben, ein Vorgang zählt einmal. *R-2 und R-3* in `regel-rand-…`: dessen Fehlerrichtung — *die genannte
  Grenze ist vollständig* — trifft, der Rand hier ist ein Muster gegen YAML statt eine Link-Regel gegen Markdown, und der Ort der
  ungenannten Grenze ein Test-Kommentar statt einer Sensor-Doku; wer das als andere Klasse liest, lässt `regel-rand-…` bei 2× und legt eine
  neue Beobachtung mit 1× an. *V-2* (Nachrunde ohne Reviewer-Lauf) und *V-3* (latente Lage) sind Befunde der Stufe INFO ohne frühere
  Instanz und nicht eingetragen. **Lese-Schritt:** mit diesem Slice erreicht **`regel-rand-ohne-benannte-luecke`** erstmals **3×**
  (`ls docs/plan/planning/observations/BEO-ALL/regel-rand-ohne-benannte-luecke/evidence/*.md | wc -l` → 3); ihr Ausgang steht aus, weil
  die Verkörperung Architect-Arbeit ist (Rolle Planner → Architect → Planner, Modul 8): **Übergabe an den Architect, nicht verkörpert und
  nicht zugewiesen.** Alle anderen Einträge mit `evidence/` ab drei Dateien tragen einen Ausgang
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -ge 3 ] && ! grep -qhE '^\*\*Stand:\*\* (verkörpert|geplant|gestrichen)' "$d"state.md "$d"observation.md && echo "$d"; done`
  nennt nur diesen Eintrag).
- **Folge-Slices:** keiner. Der Ausgang von `regel-rand-ohne-benannte-luecke` ist Sache des Architect und entsteht aus dem Lese-Schritt, nicht aus
  diesem Slice.
- **Risiken aus §6:** drei, je ein Ausgang, keines *eingetreten*. (a) *Der Test greift die falsche Zeile* — **entfallen**: die Gegenprobe (Zeile unter
  `codepaths:` entfernt) färbt rot, das Entfernen einer der vier anderen `exempt-paths`-Zeilen und der Kommentarzeilen lässt grün, der geschwächte Test
  (Muster über die ganze Datei) bleibt bei entfernter Zeile grün und `make mutate` meldet an dieser Kopie `BEFUND`; belegt von Reviewer **und** Verifier
  je einzeln, also von zwei Rollen, die nicht der Implementer sind. (b) *Der Anker des Mutations-Falls liegt verschoben* — **entfallen**: der Anker der
  Zeile steht im Quell-Bestand genau einmal (`grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml` → 1), der Anker `vcs:` von Fall `475` ebenso
  (`grep -c '^vcs:$' .d-check.yml` → 1), und beide Fälle sind an der behaupteten Mutation rot gesehen (Teillauf `2 ok`). (c) *Der Test bewacht eine Regel,
  die kein Träger führt* — **entfallen**: der Start-Trigger verlangte beide Träger, und das Kommando aus §4 gibt **2** aus. Dass jeder Ausgang trägt, ist
  gelesen: (a) und (b) an je einem Rot-Beleg einer fremden Rolle, (c) an einem Kommando, das am Baum nachzählt.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** über beide Adress-Formen gemessen, außerhalb dieser Datei, am 2026-09-26 nach
  Anlage der Register-Belege: die Code-Span-Form `(open|next|in-progress|done)/<Kennung>`
  (`git grep -nE "(open|next|in-progress|done)/<Kennung>" -- . ':!<diese Datei>' | wc -l` → **0**) und die Markdown-Link-Form
  `](…<Kennung>[.md])` mit und ohne Verzeichnis-Präfix (`git grep -nE "\]\([^)]*<Kennung>(\.md)?[)#]" -- . ':!<diese Datei>' | wc -l` →
  **0**). Der Dateiname als Token trifft **2** Zeilen (`git grep -nE "<Kennung>\.md" -- . ':!<diese Datei>' | wc -l`): es sind die
  Muster der Zähl-Kommandos in den Closure-Notizen der zwei Träger-Slices in `done/`, `'^<Kennung>.md$'` ohne Verzeichnis-Präfix — kein
  Verweis, derselbe Falsch-Treffer wie beim Geschwister. Kein eingefrorenes Artefakt nennt den Slice als Pfad; die Reports und das
  Register nennen die Kennung. Der Move hat keinen Verweis nachzuziehen.
- **Der Move, gemessen (`make slice-mv` nach `done/`, 2026-09-26):** ein Commit, der reine Move (`1a21a8e4`, 0 Zeilen geändert); der
  Werkzeug-Lauf meldet *„Kein Verweis zu ziehen — kein zweiter Commit nötig"* (eingehend 0, ausgehend 0). Weder ein Report noch eine ADR noch
  die Baseline wurde berührt (`git diff --name-only 2798f289..1a21a8e4 -- docs/reviews docs/plan/adr .harness/baseline | wc -l` → **0**). Die
  Form-Regel des Nachzugs unter `docs/reviews/` ist am realen Lauf **ungeübt**: kein Report nannte den Pfad, und der Lauf schrieb dort nichts um.
- **Drei Paarungen (nach dem Move geprüft, 2026-09-26):** (a) *Anker:* der Eintrag trägt kein Zielort-Feld (siehe *Steering-Loop-Eintrag*), es gibt
  nichts zu paaren — benannt, nicht als grün behauptet. (b) *Folge-Slice:* die in §1 und §8 genannten Slice-Kennungen bestehen als Dateien im
  Planning-Lifecycle — beide Träger in `done/`, `slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung` je einmal
  (`grep -oE 'slice-[a-z0-9][a-z0-9-]*' <diese Datei> | sort -u`, je Kennung `ls docs/plan/planning/{open,next,in-progress,done} | grep -cx "<Kennung>.md"`
  → 1, 1, 1; das vierte Token `slice-mv` ist ein Kommando-Name und keine Kennung); §7 nennt keinen Folge-Slice. (c) *Register, beide Hälften:*
  **Hälfte 1 getragen** — jede in §7 und §8 genannte Beobachtung besteht als Verzeichnis mit nicht leerem `evidence/` (**8** Kennungen; Zähler gelesen
  2026-09-26: 3, 6, 2, 4, 4, 2, 1, 1). **Register-Paarung (c), zweite Hälfte: 4 Verzeichnisse ohne Beleg, namentlich
  `ci-rennt-gegen-die-publikation-des-gepinnten-releases`, `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` und `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen
  behauptet** ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md) Festlegung 2;
  `for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done` →
  vier Namen). Sie bestanden vor diesem Slice, und keines wurde von ihm angelegt oder berührt
  (`git diff --name-only 6125fe55~1..HEAD | grep -cE 'ci-rennt-gegen|cpp-skelett|einstiegs-datei-weicht|planungs-bestand-waechst'` → **0**);
  der Befund endet erst mit dem Beleg eines abgeschlossenen Vorgangs. **Das Häkchen der letzten DoD-Zeile ist mit dieser Ausnahme gesetzt:**
  das Repo führt Wellen-Betrieb, und das Häkchen sagt dort, dass die nächste Welle-Closure die Paarungen prüft, nicht, dass sie ganz getragen
  sind (`.d-check.yml`, Kommentar zur `structure`-Regel für `done/`); ungehakt färbte die Zeile `make docs-check` rot
  (`section-open-tasks-marker-missing`) und verlangte eine `Gegenstand:`-Zeile, die für einen gelieferten Slice falsch wäre. Die zweite Hälfte
  von (c) bleibt eine benannte Ausnahme und ist kein getragener Punkt; die Frage, wie ein Slice mit ihr korrekt schließt, ist damit weiter
  offen und hier nicht neu gelöst.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo), so, wie die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) sie
führt; eine neue oder gröbere Sub-Area entsteht nicht. Die Schwelle von 2 aus 3 Achsen ist an
diesem Eintrag nicht neu gemessen.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; der Gegenstand ist
die Kopplung einer Regel an eine Config-Zeile, und die Beobachtung, die ihn trägt, ist
[`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md).
Ihr Zähler ist die Zahl der Dateien unter ihrem `evidence/` (Stand 2026-09-26; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/evidence/*.md | wc -l   # 6
```

Sie steht über der Schwelle und ist `verkörpert` (Zielort:
[`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) neben
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)); mit diesem Slice tritt
kein Eintrag erstmals über 3×. Ein Wächter für die Kopplung ist genau die Lücke, die ihr Stand als
Grenze der Verkörperung nennt; dieser Slice schließt sie.

Die übrigen Einträge der Sub-Area `*`, die dieselbe Fläche berühren, sind gelesen (Stand 2026-09-26,
Zähler wie oben je `ls …/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte). Kein Eintrag erreicht
mit diesem Slice erstmals 3×:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `ausnahmeliste-nur-auf-form-geprueft` | 4 | geplant (`slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung`) | verwandt: der Test hält eine deklarierte Ausnahme gegen ihre Begründung, nur diese eine Zeile; die allgemeine Prüfung der Berechtigung ist dort, nicht hier |
| `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` | 2 | offen | trifft die Formulierung: der Test hält **die Zeile**, nicht die Wahrheit der Gate-Begründung — §1 nennt es, und Testname wie Kommentar tragen es ebenso |
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` | 4 | verkörpert (`AGENTS.md` §3.6) für die Klasse | Liefer-Punkt 2 ist genau der Fall, den die Klasse verlangt |
| `regel-rand-ohne-benannte-luecke` | 2 | offen | berührt die Sensor-Doku, nicht diesen Test |
| `kommentar-begruendet-die-gemeinsame-liste-nur-fuer-einen-ihrer-leser` | 1 | offen | betrifft `internal/archive/scan.go`; dieser Slice fasst die Datei nicht an, sein Zähler bewegt sich nicht |
| `nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung` | 1 | offen | betrifft die Referenz-Definition; kein Gegenstand hier (§1, Trigger 7 der ADR) |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF.

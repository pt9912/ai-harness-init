# Slice slice-221: Der Verweis-Nachzug lässt die `Accepted`-ADR unberührt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die drei offenen Wellen führen geschlossene Slice-Listen, und es gibt
keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der Beleg ist ein
Vorschau-Lauf plus `make gates`, beides steht in §2.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der neue Ausschluss bekommt seinen Wächter, statt behauptet zu werden),
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 2
der Gegenstand, Folgepflicht 1 der Auftrag, Festlegung 5 die Sperre, die dieser Slice hebt),
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — Abnahme-Kriterium 1
hält `docs/reviews/**` im Suchraum, unberührt),
[ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted**).

**Berührte Spec-Stellen:** `—` — der Slice ändert die Ausnahmeliste zweier Träger; weder
Lastenheft-Vertrag noch Spezifikation noch Architektur führen sie.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner (ai-harness-init-Team, pt9912). **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Beide Träger des Verweis-Nachzugs — `make slice-mv` und das Unterkommando
`archive-welle` — schreiben nicht mehr in `docs/plan/adr/`. Das ist
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Folgepflicht 1; ihre
Festlegung 5 sperrt den ersten Archiv-Move, bis beide Träger die Ausnahme führen.

**Der Go-Träger trägt die eigentliche Arbeit, und der Grund ist gemessen.** Im Shell-Träger ist es
eine Pathspec-Zeile (`grep -c "':\!" harness/tools/slice-mv.sh` → **1**). Im Go-Träger speist
**eine** Liste drei Leser — `Haenger` (fail-closed-Vorprüfung), `VerweisFund` und `Nachziehen`
(zählender und schreibender Nachzug):
`grep -c 'Suchraum(dateien)' internal/archive/*.go | awk -F: '{s+=$NF} END{print s}'` → **3**.
Trägt man `docs/plan/adr/` dort ein, verliert die Hänger-Vorprüfung **18** Dateien mit **60**
Fundstellen, und der Lauf bliebe grün:

```sh
for r in docs/reviews/*.md; do rb="${r##*/}"; git grep -lF -e "$rb" -- 'docs/plan/adr/*.md'; done | sort -u | wc -l   # 18
for r in docs/reviews/*.md; do rb="${r##*/}"; git grep -cF -e "$rb" -- 'docs/plan/adr/*.md'; done | awk -F: '{s+=$NF} END{print s+0}'   # 60
```

**Keine Erwartungswerte.** Der Ausschluss gehört darum in die zwei Nachzug-Leser, nicht in die
geteilte Liste; `Haenger` behält seinen vollen Suchraum.

**Der Shell-Träger ist heute unbewachtbar, und auch das ist gemessen.** Seine Pathspec-Zeile steht
in `main()`, das `git mv`/`git grep` ruft — das gepinnte `BATS_IMAGE` führt kein `git`, und
`test/slice-mv.bats` erklärt genau deshalb, dass der Beleg für diese Liste **nicht** als bats-Fall
steht, sondern als Vor/Nach-Paar im Skriptkopf
(`grep -c 'BATS_IMAGE fuehrt kein' test/slice-mv.bats` → **1**). Ein Mutations-Zahn auf die Liste
setzt darum voraus, dass sie an **eine** Stelle wandert, die `main()` benutzt und ein bats-Fall
lesen kann; sonst prüft der Test seine eigene Nachbildung
([`AGENTS.md`](../../../../AGENTS.md) §3.6). Das ist Teil des Auftrags, nicht seine Voraussetzung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Archiv-Move selbst.** Zwei eigenständige Fragen stehen davor und nehmen die Sendung an: die
  `[haenger]`-Sperre ([slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md))
  und die `Anwenden`-Lücke ([slice-220](../open/slice-220-plan-ausgang-traegt-eine-kennung.md)). Dieser
  Slice hebt allein die **normative** Sperre aus Festlegung 5.
- **Die zwei `ignore-refs`-Paare.** Festlegung 3 weist sie dem Lauf zu, der den Move vollzieht —
  beide Adressen lösen heute auf, sie jetzt stumm zu schalten nähme eine lebende, richtige Referenz
  aus der Prüfung.
- **[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) selbst.** `Accepted`, nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich;
  `make adr-immutable` färbt rot. Constraint, nicht Gegenstand.
- **Kein status-lesender Schnitt** (`Accepted` gegen `Proposed`). Festlegung 2 verlangt den
  Pfad-Schnitt und nennt die Differenz heute leer; der Status-Schnitt ist ihr
  Re-Evaluierungs-Trigger 3 — ein anderer Vorgang.
- **Schicht-Abgrenzung: kein emittiertes Skelett.** Geltungsbereich der ADR ist dieses Repo; was ein
  Zielrepo bekommt, entscheidet der Vorgang, der die Tool-Ebene entscheidet.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Shell-Träger.** `slice-mv.sh` nimmt `docs/plan/adr` neben `.harness/baseline` aus der
      eingehenden Ersetzung aus, `docs/reviews/` bleibt **drin**. Damit ein Wächter die Zeile
      überhaupt erreicht, gibt sie ihre Pathspec-Liste an **einer** Stelle aus, die `main()` selbst
      benutzt. Die Zusage hat zwei Hälften und je einen eigenen Wächter: Die **Liste** hält ein
      bats-Fall, der Mitgliedschaft **und** Nicht-Mitgliedschaft prüft, mit einem
      `test/mutations/`-Fall (`# verify: test-bats`) darauf. Die **Verdrahtung** — dass `main()`
      die Liste auch benutzt — hält ein Go-Fall über einem echten `git`-Repo mit eigenem
      `test/mutations/`-Fall (`# verify: test-go`); das gepinnte `BATS_IMAGE` führt kein `git` und
      erreicht diese Hälfte nicht. Beide einmal rot gesehen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **Go-Träger.** `VerweisFund` und `Nachziehen` überspringen `docs/plan/adr/`, `Haenger` behält
      seinen vollen Suchraum — `TestHaengerFindetVerweisAusReviewReport` grün,
      `test/mutations/233-archive-welle-go-haenger-suchraum.sh` unverändert wirksam; ein eigener
      Fall (`# verify: test-go`) nimmt dem neuen Ausschluss die Zähne, einmal rot gesehen.
      Die **Trennung** der zwei Suchräume trägt einen zweiten Fall, weil kein Wächter über
      `docs/reviews/**` sie sehen kann: Der Pfad liegt in beiden Suchräumen.
- [x] **Die Sperre fällt, beobachtbar.** Gemessen wird der **Verweise-Block** der Vorschau, also
      die Liste der Dateien, in die der Lauf schreiben würde:
      `… archive-welle --vorschau altbestand | awk '/^  Verweise:/{b=1;next} /^  Sperren:/{b=0} b'
      | grep -c 'docs/plan/adr'` → **0**. Über den **gesamten** Vorschau-Text zählt dasselbe Muster
      **3** — sie stehen alle im `[haenger]`-Block, wo die ADR die **Quelle** eines lebenden
      Verweises ist, und genau diese drei Zeilen sollen bleiben (Gegenprobe zur Zeile darüber).
      Dieselbe Vorschau führt weiter genau eine Sperre, und sie heißt `[haenger]`. Keine
      Erwartungswerte.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Beide Sensor-Beschreibungen nennen die Ausnahmeliste namentlich und ziehen mit —
      [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) (*„repo-weit außer
      `.harness/baseline/**`"*) und
      [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) (*„nimmt
      allein `.git` und `.harness/baseline/**` aus"*, dazu die Sperren-Aussage aus Festlegung 5).
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
| `harness/tools/slice-mv.sh` | update | Pathspec bekommt `':!docs/plan/adr'` und wandert an **eine** lesbare Stelle |
| `internal/archive/refs.go` | update | der neue Ausschluss greift **hier**, bei den zwei Nachzug-Lesern — nicht in der geteilten Liste |
| `internal/archive/scan.go` | update | benennt den zweiten Suchraum und hält fest, warum `Haenger` ihn **nicht** benutzt |
| `internal/archive/refs_test.go` | update | ADR ausgenommen, `docs/reviews/` drin — die Kalibrierung |
| `test/slice-mv.bats` | update | liest die ausgelagerte Pathspec-Liste — Mitgliedschaft und Gegenprobe |
| `test/mutations/<NNN>-*.sh` (2 neu) | neu | je Träger ein Zahn ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `harness/sensors/{slice-mv,archive-welle}.md` | update | die Sensor-Aussage zieht mit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): sofort — unblockiert. Der Constraint
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) ist `Accepted`
(`grep -c '^\*\*Status:\*\* Accepted$' docs/plan/adr/0042-*.md` → **1**), WIP frei
(`ls docs/plan/planning/in-progress/slice-*.md | wc -l`, kein Erwartungswert).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: wenn der Go-Träger den zweiten Suchraum nicht ohne Umbau seiner drei
  Leser aufnimmt — dann sind die zwei Träger zwei Slices.
- `in-progress` → `open`: wenn einer der zwei Mutations-Fälle sich nicht rot färben lässt, weil kein
  Wächter den Ausschluss trennscharf trifft. Dann wartet der Slice auf die Entscheidung, welcher
  Wächter die Zusage trägt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** `make gates` grün mit gültigem Stempel; **(b)**
der **Verweise-Block** von `archive-welle --vorschau altbestand` nennt keine Datei unter
`docs/plan/adr/` mehr, und dieselbe Vorschau führt weiter genau eine Sperre, `[haenger]` (Kommando
und Gegenprobe in §2). Dazu der Lerneintrag in §7.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Ausschluss landet in der geteilten Liste.** In `AusgenommenePfade()` statt in den zwei
  Nachzug-Lesern eingetragen, nimmt er der Hänger-Vorprüfung 18 Dateien / 60 Fundstellen (§1) — und
  der Lauf bliebe **grün**. — **Ausgang: entfallen.** Die zwei Listen stehen getrennt
  (`AusgenommenePfade` gegen `AusgenommenePfadeNachzug`), und die Trennung ist nicht mehr nur
  richtig, sondern bewacht: `TestHaengerFindetVerweisAusADRTrotzNachzugAusnahme` plus
  `test/mutations/314-…` färben rot, sobald `Haenger` auf den verengten Suchraum gezogen wird. Der
  Reviewer hat genau die Verschiebung, die das Risiko beschreibt, probeweise gefahren; sie wird
  rot. Der stille Grün-Pfad, der das Risiko ausmachte, existiert nicht mehr — die Leser sind
  gemessen: `grep -n 'Suchraum(dateien)\|SuchraumNachzug(dateien)' internal/archive/*.go` nennt
  `scan.go` für `Haenger` und zweimal `refs.go` für die Nachzug-Hälfte.
- **Der Pfad-Schnitt trifft auch `Proposed`-ADRs.** Der von Festlegung 2 benannte Preis, heute
  leer; ab hier trägt ihn ein Träger statt einer Messung.
  — **Ausgang: entfallen** — als Risiko *dieses Slice*, nicht als Sachverhalt. Der Preis ist in
  [ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 als
  angenommene Kosten entschieden und hat in deren Re-Evaluierungs-Trigger 3 (*„Wenn ein Träger den
  Nachzug status-abhängig schneiden kann"*) einen stehenden Leser: den Trigger-Audit jeder Closure
  (Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 2). Ein Ausgang
  *weiter offen* führte dieselbe Frage ein zweites Mal, an einem Zähler, der Wiederholung misst
  statt einer Entscheidung zu folgen. Die Differenz ist heute leer, gemessen:
  `grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md | wc -l` → **5**, und der Verweise-Block
  der Vorschau nennt **0** Dateien unter `docs/plan/adr/` (Kommando in §2) — keine
  Erwartungswerte.
- **Ein dritter Träger bleibt unentdeckt.** §1 misst zwei; findet der Lauf einen weiteren Ort, der
  Verweise mechanisch umschreibt, ist Folgepflicht 1 nicht erfüllt.
  — **Ausgang: entfallen.** Drei Messungen aus drei Kontexten kommen auf dieselben zwei Träger:
  beide Review-Runden (R1 *„ein vierter Leser existiert nicht"*, R2 über die schreibenden Stellen)
  und diese Closure über die Schreib-Seite statt über die Leser —
  `grep -n 'os.WriteFile' internal/archive/*.go cmd/ai-harness-init/*.go | grep -v _test` nennt
  `refs.go` (Nachzug), `anwenden.go` (Stub-Text) und `main.go` (Gate-Fragment); mechanisch ersetzt
  wird allein in `refs.go` und in `harness/tools/slice-mv.sh`. Ein dritter Ort ist damit nicht
  übersehen, sondern gesucht und nicht vorhanden.

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-12.

- **Was hat funktioniert:** Der Schnitt hing den Slice an die **normative** Sperre
  ([ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 5) statt an
  den Move, den sie zurückhält — und alle vier Ausschlüsse aus §1 haben gehalten: kein
  Archiv-Move, keine `ignore-refs`-Paare, keine Zeile in der ADR, kein status-lesender Schnitt.
  Tragend war die Messung in §1, die vor dem Code stand: **eine** Ausnahmeliste speist im
  Go-Träger drei Leser, und nur zwei davon dürfen den neuen Pfad sehen. Daraus folgte der zweite
  Suchraum statt eines Eintrags in der geteilten Liste; die Probe des Reviewers, die genau diese
  Alternative einsetzt, färbt heute rot. Ebenso getragen hat die Entscheidung, `docs/reviews/**`
  ausdrücklich **drin** zu lassen: Der Pfad liegt in beiden Suchräumen und ist damit der eine Ort,
  an dem die Trennung **nicht** messbar ist — wer ihn für den Beleg genommen hätte, hätte einen
  Wächter gebaut, der unter keiner Mutation rot wird.
- **Was ging anders als geplant:** Zwei Zusagen des Plans waren falsch, beide in derselben
  Richtung — sie behaupteten Deckung, die der genannte Sensor nicht erreicht, und beide stammten
  aus der Planner-Hand. **Erstens** erklärte §1 den Shell-Träger für *„heute unbewachtbar"* und
  belegte das mit dem gepinnten `BATS_IMAGE`, das kein `git` führt. Die Prämisse stimmt, die
  Folgerung nicht: `make test-go` und `make full-smoke` fahren in diesem Repo echte `git`-Repos.
  Gemessen hat das die zweite Review-Runde, geliefert wurde daraufhin ein Go-Fall über einem
  echten Scratch-Repo, der `main()` als Prozess ausführt. **Zweitens** maß das Kommando in
  DoD (3) den **gesamten** Vorschau-Text statt seines Gegenstands: Wörtlich ausgeführt gibt es
  **3** aus, nicht **0** — die drei Zeilen stehen im `[haenger]`-Block, wo die ADR die *Quelle*
  eines lebenden Verweises ist. Beide Stellen hat diese Closure nachgezogen (§2, §5): DoD (1)
  nennt jetzt beide Hälften mit ihrem je eigenen Wächter, DoD (3) den Verweise-Block samt
  Gegenprobe. **Die Korrektur nimmt nichts weg** — sie verlangt zwei Wächter, wo einer stand, und
  ein eingegrenztes Kommando, wo ein naives stand; die Tatsachen dazu hat die Verifikation vor
  dieser Closure unabhängig festgestellt.
- **Steering-Loop-Eintrag — neuer Sensor:** Die Verdrahtung des Shell-Trägers hat Zähne bekommen.
  `TestSliceMvEchtUebergehtAcceptedADRBeimNachzug` (`cmd/ai-harness-init/slice_mv_echt_test.go`)
  kopiert das Skript in ein echtes `git`-Repo, in dem eine ADR und ein Review-Report dieselbe
  Slice-Datei per Präfix-Form verlinken, und führt `main()` als Prozess aus;
  `test/mutations/315-slice-mv-main-verliert-ausnahmeliste.sh` nimmt `main()` die Verbindung zur
  Liste und färbt genau diesen Test rot. Die Verallgemeinerung, die der Slice liefert: **Eine
  Unbewachtbarkeits-Behauptung ist eine Aussage über den Werkzeugkasten des Repos, nicht über die
  Prüfstufe, die gerade im Blick ist.** Wer sie über einer Stufe misst, bekommt eine wahre Prämisse
  und eine falsche Folgerung — und schreibt den Ersatz-Beleg in Prosa, wo ein Wächter möglich war.
  Eine `— liegt in …`-Teilzeile steht **nicht**: Was dieser Slice verkörpert, ist die Festlegung
  einer ADR und trägt deren Kennung; ein zweiter Herkunfts-Anker ist dafür nach
  Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker (Geltungsbereich) nicht
  vorgesehen, und die Anker-Paarung hat hier kein Objekt.
- **Beobachtungs-Register (`../observations/`):** Drei vorhandene Kennungen **zitiert**, zwei neue
  angelegt, ein Ausgang gesetzt. Zitiert, je eine `evidence/slice-221.md`:
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (HIGH-1 und MEDIUM-1 — frische Verdrahtung an beiden Trägern, kein Fall nannte sie) · **5×** ·
  [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (drei Zusagen nannten je einen Sensor, der die zugesagte Form nicht erreicht — Kommentar,
  Skriptkopf, DoD) · **14×** ·
  [`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  (LOW-1, LOW-2, LOW-3 — drei Stellen, ein Vorgang, eine Datei) · **8×**.
  **Neu angelegt:**
  [`BEO-ALL/buchung-wiederholt-die-folgerung-ihrer-norm`](../observations/BEO-ALL/buchung-wiederholt-die-folgerung-ihrer-norm/observation.md)
  — die Klasse, die eine Architect-Runde als zweites Auftreten gemessen und bewusst nicht selbst
  gebucht hat (eine ADR-Runde ist keine Closure); Belege sind die zwei Review-Reports, in denen
  sie steht, `2026-09-12-adr-0043-ziel-fassung-v671.md` (LOW-3) und
  `2026-09-12-adr-0044-ziel-fassung-v672.md` (LOW-4) · **2×**, `offen`. Nachgeschlagen statt
  erfunden: Die drei nächstliegenden Bezeichnungen treffen etwas anderes —
  *zusammenfassung-staerker-als-ihre-quelle* hat die umgekehrte Fehlerrichtung (hier ist die Kopie
  **treu**), *zusage-neben-geaenderter-ableitung-bleibt-stehen* setzt eine bewegte Ableitung
  voraus, *adaptions-block-spricht-ueber-sich-selbst* den Block als Gegenstand. Zweitens
  [`BEO-ALL/mutations-fall-an-zeilennummer-verankert`](../observations/BEO-ALL/mutations-fall-an-zeilennummer-verankert/observation.md)
  (Runde 2, LOW-1) · **1×**; die drei Nachbarklassen grenzen sich selbst ab, und keine trägt einen
  Zeilen-Anker, dessen Verschiebung auf eine Kommentarzeile trifft. **Ausgang gesetzt:**
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  steht bei **13×** und trägt jetzt *verkörpert*, Zielort
  [ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md). Das ist **kein**
  vorgezogener Lese-Schritt: Den Ausgang hat die Entscheidung selbst zugewiesen (Folgepflicht 3,
  *„Den Stand schreibt die Closure, die das Beleg-Register fortschreibt"*); diese Closure schreibt
  ihn auf, sie wählt ihn nicht. Alle Stände sind gemessen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`), keine
  Erwartungswerte. **Kein neuer Eintrag hat mit diesem Slice 3× erreicht.**
- **Folge-Slices:** keiner. Die zwei Fragen, die §1 ausdrücklich vor den Archiv-Move stellt, haben
  ihre Adressen bereits und sind Dateien in `open/`:
  [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md) (die
  `[haenger]`-Sperre) und
  [slice-220](../open/slice-220-plan-ausgang-traegt-eine-kennung.md) (die `Anwenden`-Lücke). Was
  dieser Slice hebt, ist allein die normative Sperre; ein dritter Slice entstünde nur aus einem
  Risiko, das eingetreten wäre — keines ist es.
- **Risiken aus §6:** drei von drei, jedes **entfallen**, jedes mit Begründung und eigener Messung
  — die zwei Listen stehen getrennt und die Trennung ist bewacht, der Preis aus Festlegung 2 ist
  entschieden und hat in Re-Evaluierungs-Trigger 3 seinen stehenden Leser, und ein dritter Träger
  ist nicht übersehen, sondern über die Schreib-Seite gesucht und nicht vorhanden.
- **Drei Paarungen:** Dieses **Repo** fährt Wellen (`ls docs/plan/planning/welle-*.md | wc -l` →
  **3**, kein Erwartungswert) — zuständig ist die nächste Welle-Closure, auch für diesen Slice
  ohne Wellen-Zugehörigkeit. Nachgesehen hat diese Closure trotzdem, nach dem `git mv`: Jeder hier
  genannte Register-Pfad existiert als Verzeichnis mit nicht leerem `evidence/`, die zwei
  genannten Folge-Slices liegen im Lifecycle, und ein `liegt in`-Feld trägt diese Notiz nicht.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** zwei berührte, beide in der Modus-Deklaration
([`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area))
geführt: `harness/tools/` (`TOOLS`) für den Shell-Träger, `*` (`ALL`) für `internal/archive/`.
Keine ist zu grob; `internal/archive/` bekommt **keine** eigene Sub-Area — es hinge allein an der
Verzeichnis-Achse und verfehlte die Schwelle ≥ 2 von 3.

**Vorgelagert — offene Beobachtungen sichten:** vier Treffer, Zähler-Stand je aus
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` (keine Erwartungswerte):

- [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **13×**, `offen` — dieser Slice ist ihr Träger; den Ausgang setzt die Closure
  ([ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Folgepflicht 3).
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  **4×**, `offen` — einschlägig; darum steht der Zahn je Träger in §2, nicht in der Closure.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  **13×**, `geplant` — der Grund, warum die Kalibrierung eigener DoD-Bestandteil ist.
- [`vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
  **4×**, `verkörpert`.

Keiner erreicht **mit diesem Slice** erstmals 3×; kein Folge-Slice fällig.

**Modus-Begründungsblock:** entfällt — **alle berührten Sub-Areas GF**. Das
Evidenz-/Diskrepanz-Risiko ist niedrig, und die vier Stände oben sind sein Beleg: Doc führt, Code
folgt, und die Diskrepanz, um die es geht, ist von
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) bereits entschieden.



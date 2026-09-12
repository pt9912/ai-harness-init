# Slice slice-220: Der Plan-Ausgang des schreibenden Laufs trägt eine Kennung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt —
kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle entscheidet
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted** —
Festlegung 2 setzt den Schlüssel, dessen Betriebsart die Lücke geöffnet hat; Folgepflicht 1 endet
nach ihrem eigenen Wortlaut an den **Ausgängen der Vorprüfung**, und genau diese Menge wächst hier
um einen),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — Festlegung 1,
Träger ist das Produkt-Binär; dieser Slice baut in ihm und ändert daran nichts),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Vorprüfung, die *„Sperren: keine"* meldet, während der schreibende Lauf an einer ungenannten
Bedingung abbricht, sagt mehr zu als sie hält — ein stilles Grün an einer fail-closed-Sperre).

**Berührte Spec-Stellen:** `—`. Der Slice baut eine Werkzeug-Fähigkeit; er schreibt keine
Spec-Stelle.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Der Ausgang, an dem der schreibende Lauf unter dem Schlüssel ohne Welle abbricht, bekommt
eine Kennung und erscheint in der Vorschau — damit die Zusage des Werkzeugs wieder ohne Ausnahme
gilt und die zwei Stellen, die die Ausnahme heute in Prosa erklären, ihren Gegenstand verlieren.**

**Der Defekt ist eine auseinandergelaufene Bedingung, nicht eine fehlende Fähigkeit.** Dieselbe
Bedingung steht an zwei Stellen, und slice-219 hat nur eine der beiden Hälften am Schlüssel
entschärft:

```sh
grep -nE '^\s*(switch|if) len\(b\.Plaene\)' internal/archive/vorschau.go internal/archive/anwenden.go
#   internal/archive/anwenden.go:89:        if len(b.Plaene) != 1 {      -- greift fuer jeden Schluessel
#   internal/archive/vorschau.go:124:       switch len(b.Plaene) {       -- planSperre, unter 'altbestand' unterdrueckt
```

Unter einer Welle-Kennung stimmen beide überein; unter `altbestand` schweigt die Vorschau und
`Anwenden` bricht ab. Die Form dafür liegt bereit und wird nicht erfunden — `Sperre` in
`internal/archive/vorschau.go` trägt `Kennung`, `Grund` und `Zeilen`, und acht Ausgänge benutzen
sie schon (`grep -c 'Kennung: "' internal/archive/vorschau.go` → **8**, kein Erwartungswert). Der
Ausgang in `anwenden.go` ist ein nacktes `fmt.Errorf` ohne Kennung; **deshalb** kann die Vorschau
ihn nicht melden, und **deshalb** brauchte es den erklärenden Kommentar.

**Zwei Ausgänge sind es, nicht einer — gemessen, nicht angenommen.** Vor dem ersten Schreibzugriff
(`os.MkdirAll`) verlässt `Anwenden` sich an **zwei** Stellen auf eine Eigenschaft des ruhenden
Baums, und keine davon trägt heute eine Kennung:

```sh
awk '/^func Anwenden/,/^}/' internal/archive/anwenden.go | grep -n 'return fmt.Errorf\|return err'
#   die Plan-Pruefung (len(b.Plaene) != 1)
#   VorlagenVerzeichnis(root) -- .harness/baseline/ unlesbar oder != 1 <tag>-Verzeichnis
```

Ein Slice, der nur den ersten benennt, stellte dieselbe Klasse an der zweiten Stelle wieder her.
Die Zusage gilt erst *ohne Ausnahme*, wenn **jeder am ruhenden Baum beobachtbare** Ausgang eine
Kennung trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Fähigkeit, den schreibenden Lauf über `altbestand` durchlaufen zu lassen.** Dieser Slice
  macht die Vorschau **ehrlich**, nicht den Lauf **möglich** — nach ihm meldet
  `--vorschau altbestand` einen Ausgang mehr, nicht weniger. Ob `Anwenden` den Schlüssel ohne
  Welle-Plan und ohne Ergebnisnotiz **tragen** soll, ist eine andere Frage mit eigener
  Alternativen-Menge (Stub-Form des Welle-Plans, Zeiger auf eine Ergebnisnotiz, die es nicht gibt);
  sie ist heute **an keinen Vorgang adressiert**, und
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 1
  braucht sie. Wer diesen Slice schließt, hat sie nicht erledigt — er hat sie **sichtbar** gemacht,
  weil sie danach als benannte Sperre im Lauf steht statt als Kommentar im Code.
- **Die `[haenger]`-Sperre und die Norm-Frage dahinter** — ein anderer Vorgang mit eigener
  Alternativen-Menge, geschnitten als
  [slice-216](slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md), und eine
  Architect-Entscheidung, keine Werkzeug-Arbeit.
- **Die zwei Ausgänge, die am ruhenden Baum *nicht* beobachtbar sind** — die verletzte Stub-Form
  entsteht erst zwischen den zwei Commits, das fehlende Wellen-Argument fängt der Aufrufer vor dem
  Lauf ab. Beide bleiben als `ABGRENZUNG` in `internal/archive/vorschau.go` stehen; gestrichen wird
  allein der Satz über den Schlüssel ohne Welle, dessen Gegenstand dieser Slice beseitigt. Bestand
  bleibt bewusst stehen, weil eine Vorschau über einen Zustand, den es zur Vorschau-Zeit nicht
  gibt, keine Aussage treffen kann.
- **Der Prüfbereich der `closure`-Fähigkeit des Doku-Gates** —
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Folgepflicht 3,
  fällig *„vor dem ersten schreibenden Lauf"*. Er berührt `.d-check.yml` und die Sensor-Doku, also
  eine andere Schicht als dieser Slice.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Jeder am ruhenden Baum beobachtbare Ausgang des schreibenden Laufs trägt eine Kennung und
      erscheint in der Vorschau.** Beide oben gemessenen Stellen sind gemeint, nicht nur die
      Plan-Prüfung. `--vorschau altbestand` meldet den Plan-Ausgang danach als benannte Sperre
      neben `[haenger]`; die Zahl der Kennungen in `internal/archive/vorschau.go` wächst
      entsprechend. **Wo** die Kennung hängt — in `sperren()` oder als Rückgabe aus `Anwenden` —,
      entscheidet der Implementer; gefordert ist, dass sie **einmal** definiert ist und Vorschau
      und schreibender Lauf dieselbe Bedingung lesen, statt sie zweimal zu führen.
- [ ] **Die Kalibrierung steht: für einen echten Welle-Schlüssel erscheint der neue Ausgang
      nicht.** Dort trägt `planSperre` den Fall bereits als `kein-plan` bzw. `mehrdeutiger-plan`;
      ein zweiter Eintrag für dieselbe Bedingung wäre eine doppelte Meldung und eine zweite
      Fassung derselben Regel. Nachweis ist ein Test je Richtung über einem synthetischen Baum.
- [ ] **Das Gegenbeispiel ist rot gesehen, und ein `test/mutations/`-Fall hält es.** Eine Mutation,
      die dem neuen Ausgang die Bedingung nimmt — er erscheint nicht mehr, die Vorschau meldet für
      `altbestand` wieder zu wenig —, **muss** rot färben
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6); welcher Wächter fällt, steht in seiner
      `# expect:`-Zeile. Ohne ihn ist die wiederhergestellte Zusage eine Zusage ohne Zähne.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] **Doku-Update — und es ist eine Streichung, keine Ergänzung.** Die zwei Stellen, die die
      Ausnahme heute in Prosa erklären, fallen mit ihrem Gegenstand weg: der Satz über den
      Schlüssel ohne Welle im `ABGRENZUNG`-Block von `internal/archive/vorschau.go` und
      **§Grenze Punkt 7** in
      [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md). Der Slice
      ist **erst fertig, wenn sie weg sind** — bleiben sie stehen, beschreiben sie eine Lage, die
      es nicht mehr gibt ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/vorschau.go` | update | dort liegt `Sperre`, dort entsteht die Liste, dort steht der zu streichende `ABGRENZUNG`-Satz |
| `internal/archive/anwenden.go` | update | dort bricht der Lauf heute ohne Kennung ab |
| `internal/archive/vorschau_test.go` | update | beide Richtungen der Kalibrierung über synthetischen Bäumen |
| `test/mutations/` | neu | der Fall, der dem neuen Ausgang die Zähne nimmt |
| [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) | update | §Grenze Punkt 7 verliert seinen Gegenstand und wird gestrichen |

**Die Einsammel-Regel bleibt unberührt.** `internal/archive/collect.go` klassifiziert für diesen
Schlüssel schon heute richtig; eine Änderung dort wäre eine zweite Fassung derselben Regel.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): keine weitere Bedingung. Der Slice wartet **nicht** auf
[slice-216](slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md): Er macht eine
vorhandene Bedingung sichtbar und ändert an ihr nichts, und `[haenger]` hält den Vollzug ohnehin
zurück.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, dass die zwei Ausgänge
  aus §1 verschiedene Träger brauchen — der eine eine Bedingung über dem Bestand, der andere eine
  über der Umgebung —, dann trennt der Schnitt sie in zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Kennung nur zu haben ist, indem
  `Anwenden` seine Prüfung an die Vorschau abgibt und dabei eine Reihenfolge entsteht, in der der
  schreibende Lauf eine Vorbedingung **nicht mehr selbst** prüft. Das wäre eine Abschwächung eines
  fail-closed-Ausgangs und gehört nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 vor eine ADR, nicht
  in diesen Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `--vorschau altbestand` meldet den Plan-Ausgang als benannte Sperre und ein Lauf
unter einer Welle-Kennung meldet ihn nicht; der Mutations-Fall ist rot gesehen; die zwei
erklärenden Stellen sind **gestrichen** (`grep -c 'Grenze' …` je Datei zeigt es); Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der neue Ausgang meldet doppelt.** Unter einer Welle-Kennung trägt `planSperre` dieselbe
  Bedingung bereits; erscheint der neue daneben, führt die Vorschau zwei Namen für eine Sache, und
  die nächste Runde weiß nicht, welcher gilt. DoD 2 bindet die Kalibrierung. — **Ausgang:** <…>
- **Die Streichung bleibt aus, und die Prosa überlebt ihren Gegenstand**
  ([`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  Stand `geplant`). Genau diese Klasse hat den Slice ausgelöst; sie an seinem Ende zu wiederholen,
  wäre der teuerste Ausgang. DoD 6 bindet die zwei Stellen namentlich. — **Ausgang:** <…>
- **Der neue Wächter bekommt keinen Mutations-Fall**
  ([`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md),
  Stand `offen`). Der Bestand um dieses Unterkommando ist dicht bewacht
  (`ls test/mutations/*archive-welle*.sh | wc -l`, kein Erwartungswert); ein neuer Ausgang ohne
  eigenen Fall fiele darin auf und bliebe trotzdem grün. — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register:** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses **Repo** fährt Wellen — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo). `harness/tools/` ist
**nicht** berührt: Der Träger ist das Produkt-Binär
([`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1), die Arbeit
liegt in `internal/archive/`, und kein Skript unter `harness/tools/` wird angefasst. Die
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt
für diesen Bereich keine eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
durchgegangen; die Stände sind gemessen, nicht abgelesen
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2):

```sh
cd docs/plan/planning/observations/BEO-ALL
for d in zusage-neben-geaenderter-ableitung-bleibt-stehen neuer-waechter-ohne-mutations-fall \
         zusage-nennt-sensor-der-form-nicht-sieht benannte-luecke-ohne-ausgang; do
  printf '%2s  %s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
# 23  zusage-neben-geaenderter-ableitung-bleibt-stehen
#  4  neuer-waechter-ohne-mutations-fall
# 13  zusage-nennt-sensor-der-form-nicht-sieht
#  1  benannte-luecke-ohne-ausgang
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Vier berühren diesen
Slice; **keine** erreicht mit ihm erstmals 3×:

- **`zusage-neben-geaenderter-ableitung-bleibt-stehen` (23×, `geplant`)** — der **Auslöser** dieses
  Slice: Die Zusage der Sensor-Datei blieb neben der geänderten Ableitung stehen. Risiko 2 hält die
  Gegenrichtung, damit der Slice die Klasse nicht an seinem eigenen Ende wiederholt.
- **`neuer-waechter-ohne-mutations-fall` (4×, `offen`)** — Risiko 3, bindet DoD 3.
- **`zusage-nennt-sensor-der-form-nicht-sieht` (13×, `geplant`)** — die verwandte Klasse: Eine
  Zusage nennt einen Geltungsbereich, den der Code darunter nicht hält. Sie erklärt, warum DoD 1
  **beide** gemessenen Ausgänge verlangt und nicht nur den auffälligen.
- **`benannte-luecke-ohne-ausgang` (1×, `offen`)** — berührt den Slice als Warnung, nicht als
  Gegenstand: Die zwei erklärenden Stellen aus DoD 6 sind genau solche Grenz-Beschreibungen, und
  dieser Slice zeigt den Weg, auf dem eine wieder verschwindet — indem ihr Gegenstand beseitigt
  wird statt sie selbst.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

# Slice slice-183: Die Zuordnung des wellenlosen Altbestands zur Archivierung wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — **kein Mitglied von [welle-15](../done/welle-15-re-baseline.md), und der Grund
ist ihr eigener Closure-Trigger.** Der fordert alle Slices der Welle in `done/`, zwei grüne
repo-weite Läufe und den vollzogenen Pin; die Archivierung eines wellenlosen Slice steht in keiner
dieser Bedingungen. Das Welle-Ziel *„jede Pflicht, die die neue Fassung mitbringt, hat einen
verbuchten Ausgang"* ist mit **dieser Datei** eingelöst — ein Ausgang ist ein Träger, kein Vollzug;
wo sie liegt, sagt die Lifecycle-Note oben und sonst nichts. Ausdrücklich benannt statt
stillschweigend weggelassen
([`BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich`](../observations/BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich/observation.md),
[welle-15](../done/welle-15-re-baseline.md) §4).

**Bezug:**
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (**keiner** ihrer fünf
Re-Evaluierungs-Trigger ist gefeuert; diese Entscheidung steht **daneben** — §1),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Pflicht kommt aus
dem auf einen Tag gepinnten Baum),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate meldet einen nicht archivierten Slice — die Lücke gehört benannt, nicht behauptet).

**Berührte Spec-Stellen:** `—`. Der Slice entscheidet eine Prozess-Frage; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel *und* Abgrenzung** (Out-of-Scope-Disziplin des
Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des Ausschlusses stehen in **eben
diesem Abschnitt** des Baseline-Regelwerks, zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Ob der wellenlose Altbestand dieses Repos archiviert wird und welche Welle ihn einsammelt,
steht als angenommene Entscheidung auf Rang 4 der Source Precedence.**

**Der Auslöser gehört nicht mehr dazu, und das ist gemessen.** Die Träger-Tabelle in
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, die dieser Slice als Anlass führte, ist mit
*„Träger im Repo **ohne** Wellen"* überschrieben, und der Absatz darüber stellt die Achse:
*„**Wellenlos** ist eine Eigenschaft des **Repos** … Ein Repo mit Wellen hat eine Welle-Closure,
und die liest und prüft alles, was seit der letzten Welle in `done/` liegt — **auch Slices ohne
Wellen-Zugehörigkeit**."* Dieses Repo fährt Wellen:

```sh
ls docs/plan/planning/welle-*.md | wc -l               # 3  flach = offen/geschnitten
ls docs/plan/planning/done/welle-*-results.md | wc -l  # 12 geschlossen
```

Der Auslöser für einen wellenlos geschlossenen Slice ist hier damit die **Welle-Closure**
(Schritt 4) und nicht seine eigene Closure — und das Werkzeug führt es bereits so aus:
`internal/archive/collect.go` klassifiziert `Mitglied · Wellenlos · Fremd`, und `Bestand.Slices()`
sammelt Mitglieder **und** Wellenlose in dasselbe Wellen-Archiv. Ein Lauf sagt dasselbe
(`make host-bin` davor):

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau welle-13
#   Mitglieder (Welle-Feld nennt welle-13): 6
#   wellenlos (seit der letzten Closure): 57
```

**Von den Re-Evaluierungs-Triggern der
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) ist keiner gefeuert, und es
sind fünf, nicht zwei:**

```sh
awk '/^## Re-Evaluierungs-Trigger/{f=1;next} /^## /{f=0} f' \
  docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md | grep -c '^- \*\*Wenn'   # 5
```

Zwei kommen in die Nähe und sind einzeln gemessen:

- **Trigger 1** — *„wenn die Baseline die Archivierung aus der Wellen-Closure entfernt oder ihren
  Träger selbst benennt"*, feedforward auf eine Baseline-**Änderung**. **Nicht gefeuert**, aus zwei
  voneinander unabhängigen Gründen. Erstens trägt *Träger* an den zwei Stellen verschiedene
  Bedeutungen: Die Spalte der Tabelle oben führt durchgängig **Prozess-Momente**
  (`Slice-Closure §7`, `Slice-Planung, §8`), während jene Festlegung 1 *Träger* das
  **Produkt-Binär** nennt; über das ausführende Artefakt sagt dieselbe Quelle in
  §Wellen-Closure-Prozedur Schritt 4 nur *„deshalb gehört die Operation in ein Werkzeug und nicht
  in Handarbeit"* — ein Werkzeug verlangt, keines benannt. Wer
  die zwei gleichsetzt, feuert einen Trigger, den die Quelle nicht gefeuert hat. Zweitens stand
  die sechste Zeile, die `v6.0.0` jener Tabelle hinzufügt (Position **P-06** des Katalogs in
  [slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9), im vendored Baum bereits,
  als jene Entscheidung `Accepted` wurde — eine Zeile, die beim Accept dasteht, ist danach keine
  Baseline-Änderung mehr:

  ```sh
  git log --format=%h -S'| 2026-09-10 | **Accepted** |' \
    -- docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md   # a6c5f22c
  git show a6c5f22c:.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md \
    | grep -c 'Zeitdokumente archivieren'                            # 1
  ```

- **Trigger 2** — *„wenn ein Repo ohne Wellen-Betrieb die Archivierung braucht"*. **Nicht
  gefeuert**: Dieses Repo fährt Wellen, die Bedingung ist oben widerlegt. Sein Nachsatz benennt
  trotzdem die Lücke, in der dieser Slice steht — *„der **Auslöser** ist neu zu entscheiden, nicht
  der Träger. Diese Entscheidung sagt über ihn nichts."*

Die übrigen drei — Ausführbarkeit des Trägers am Ort der Archivierung, ein Ziel ohne vendored
Baseline-Baum, die Fähigkeitsfläche des Trägers als Befund — berühren weder Gegenstand noch
Annahmen dieses Slice. Der Träger bleibt in jedem Fall das Produkt-Binär (jene Festlegung 1 ist
unberührt).

**Fällig ist die Frage ohne jeden Trigger, denn die Baseline stellt sie diesem Repo selbst.**
`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4 überlässt die Zuordnung ausdrücklich dem
Adopter: *„Sie braucht dafür eine Entscheidung, die die laufende Regel nicht liefert: welche Welle
die Slices einsammelt, die keiner angehören. Das Repo benennt die Zuordnung — die chronologisch
nächste geschlossene Welle oder ein einzelnes Sammel-Archiv für den Bestand vor der Einführung."*
Dieses Repo hat sie nicht benannt.

**Was bleibt, ist der Altbestand, und er ist gemessen:** 57 der 148 geschlossenen Slices tragen
`**Welle:** ohne Welle`, archiviert ist keiner, und der Lauf oben bricht genau daran ab —
*„[untergrenze] 57 wellenlose(r) Slice(s) liegen flach in `docs/plan/planning/done/`, aber kein
`docs/plan/planning/done/*/archiv.zip` setzt eine Untergrenze"*; ohne sie umfasste *„wellenlos seit
der letzten Closure"* den gesamten Altbestand.

```sh
n=0; for f in docs/plan/planning/done/slice-*.md; do \
  grep -q '^\*\*Welle:\*\* ohne Welle' "$f" && n=$((n+1)); done; echo "$n"   #  57
ls docs/plan/planning/done/slice-*.md | wc -l                                # 148
ls -d docs/plan/planning/done/welle-*/ 2>/dev/null | wc -l                   #   0
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Ausgang der eingehenden Verweise auf Review-Reports** — er ist die **Vorbedingung** jeder
  ersten Archivierung und liegt bei
  [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md). Der Lauf
  oben nennt sie als zweite Sperre (`[haenger]`, 44 Fundstellen); ein Slice, der beides trägt,
  entschiede zwei Fragen mit verschiedenen Alternativen-Mengen.
- **Der Einzel-Slice-Modus des Werkzeugs** — er hat mit dem Befund oben seinen Gegenstand
  verloren: Die Archivierung läuft hier über die Welle-Closure, und die kann das Werkzeug schon.
  Ein Bau, den keine Entscheidung mehr verlangt, wäre der Schnitt vor der Messung, gegen den
  [`BEO-ALL/re-baseline-ohne-inventur-slice`](../observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md)
  steht.
- **Was der Verweis-Nachzug in einem eingefrorenen Artefakt darf** — eigener Vorgang und eine
  Norm-Frage des Architect; sie steht mit Zähler im Register
  ([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md),
  Stand `offen`) und hängt nicht an dieser Entscheidung. Sie steht als Risiko in §6.
- **Der Dateiname dieses Plans** — er bleibt, obwohl der Titel den Gegenstand nachzieht. Ihn zu
  ziehen hieße, in **vier** eingefrorene Zeitdokumente unter `done/` zu schreiben
  (`git grep -lF 'slice-183-ausloeser-der-wellenlosen-archivierung' -- 'docs/plan/planning/done' | wc -l`),
  also genau die Klasse zu vollziehen, die der Punkt darüber als offen führt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Die ADR liegt und entscheidet die Zuordnung** — ob der wellenlose Altbestand (57, §1)
      archiviert wird und, wenn ja, welche Welle ihn einsammelt: die chronologisch nächste
      geschlossene Welle oder ein einzelnes Sammel-Archiv, die zwei Formen, die die Ziel-Fassung
      selbst nennt. Die Freistellung *„Kein Zwang zum Nachrüsten — und kein Verbot"* spricht von
      *„Wellen, die vor der Einführung schlossen"*; ob sie den **wellenlosen** Bestand trägt, sagt
      sie nicht — genau diese Lücke ist zu schließen. Die Entscheidung nennt ihren `Status`; bei
      `Proposed` steht der Acceptance-Trigger daneben (Präzedenz
      [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md)).
- [x] **Das Verhältnis zu [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
      ist ausgesprochen:** kein `Supersedes` — deren Festlegung 1 (Träger = Produkt-Binär) bleibt
      unberührt, und **keiner** ihrer fünf Re-Evaluierungs-Trigger ist gefeuert. Die neue
      Entscheidung steht **daneben**: Sie beantwortet eine Frage, die jene sich ausdrücklich nicht
      gestellt hat, und genau das verlangt keine Änderung an der eingefrorenen Datei. Die zwei
      Trigger, die in die Nähe kommen, trägt sie einzeln gemessen (§1), die übrigen drei mit ihrem
      Grund. Jene ist seit dem 2026-09-10 `Accepted` und wird dafür nicht angefasst
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
- [x] **Der Sensor-Stand ist benannt statt behauptet.** Kein Gate dieses Repos meldet einen
      geschlossenen Slice ohne Archiv; was es gibt, ist die `untergrenze`-Sperre der Vorschau, und
      die ist kein Gate und steht in keiner Prerequisite-Kette. Welche Kandidaten es sonst gibt und
      warum sie nicht messen, steht in der Fitness-Function-Sektion der ADR — ein Sensor, der dort
      als vorhanden ausgegeben würde, wäre [`AGENTS.md`](../../../../AGENTS.md) §3.1 eine Ebene
      tiefer.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8); er ist zugleich der Beleg, den
      [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
      für einen Accept-Übergang verlangt.
- [x] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue
      Zeile ([`AGENTS.md`](../../../../AGENTS.md) §5). Ein öffentlicher Vertrag ist nicht berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine
      Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. **Ein Beleg steht
      schon aus:** Die Rückführung dieses Slice nach `next/` ist ein benanntes, noch nicht
      gezähltes Auftreten von
      [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
      (§6) — mit der Closure dieses Slice wird daraus `evidence/slice-183.md`.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | neu | die Entscheidung, per `cp` aus der vendored ADR-Vorlage |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | der Index wächst mit der ADR |

**Der Einzel-Slice-Modus hängt nicht mehr daran.** Er war die Folgepflicht, die dieser Plan aus
dem Auslöser ableitete; mit dem Befund in §1 ist er gegenstandslos, denn die Archivierung läuft
hier über die Welle-Closure, und die fährt das Werkzeug bereits.

**Ob die Entscheidung eine Werkzeug-Fähigkeit nach sich zieht, sagt sie selbst** — und das ist
offen, nicht vorweggenommen: Das Unterkommando nimmt eine **Welle-Kennung** und verlangt zu ihr
Plan und Ergebnisnotiz in `done/`; ein Sammel-Archiv ohne Welle hat beides nicht. Fällt die
Entscheidung dorthin, benennt sie den Folge-Slice mit Kennung; die Datei in `open/` schneidet dann
der Planner. Die Präzedenz im Nachbar-Repo hält dieselbe Reihenfolge —
`unzip -p /Development/d-check/docs/plan/planning/done/welle-88/archiv.zip
docs/plan/planning/done/slice-193-baseline-v600-bump.md` §3 trennt Regelwerks-Adoption und
Werkzeug-Umsetzung.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) liegt in `done/`. Der Grund ist tragend:
Bis zum Tausch ist `v5.18.0` der Ist-Maßstab
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und die Regel,
die hier entschieden wird, steht erst danach im vendored Baum — eine ADR, die einen Text zitiert,
der netzlos nicht vorliegt, hätte keine belegbare Quelle. **Keine zweite Bedingung tritt hinzu:**
[slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md) ist
Vorbedingung der ersten **Archivierung**, nicht dieser **Entscheidung**.

**Vollzogene Rückführung `in-progress` → `next` — der Grund, den Modul 5 im Nachhinein verlangt:**
Eingetreten ist nicht die vorab benannte Bedingung, sondern eine stärkere — **die Auslöser-Hälfte
dieses Slice hat in diesem Repo keinen Gegenstand** (§1: die Träger-Tabelle gilt dem Repo *ohne*
Wellen, dieses fährt Wellen, und die Welle-Closure sammelt die wellenlosen Slices bereits ein),
**und die verbliebene Altbestand-Hälfte sitzt auf einer Vorbedingung auf**, die eine eigene
Entscheidung mit eigener Alternativen-Menge ist. Der Schnitt trennt beide: die Vorbedingung liegt
als [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md) in
`open/`, der Altbestand bleibt hier und ist die DoD in §2.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Frage nach dem **Altbestand**
  eine eigene Abwägung mit eigenen Alternativen verlangt — 57 Vorgänge sind kein Anhang zu einer
  Zuordnungs-Entscheidung. Dann trennt der Schnitt den Bestand *vor* der ersten Archivierung von
  dem, der nach ihr anfällt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Entscheidung eine Fähigkeit des
  Werkzeugs voraussetzt, deren Machbarkeit ungemessen ist. Eine Messung am Werkzeug ist
  Implementer-Arbeit und kein Zwischenschritt in einem Architect-Lauf.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die ADR trägt `Status:` und, falls `Proposed`, ihren Acceptance-Trigger;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Freistellung für den Wellen-Altbestand wird auf den wellenlosen übertragen, ohne dass die
  Quelle das sagt**
  ([`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md),
  Stand `offen` — *ein lebendes Plan-Artefakt fasst eine Entscheidung stärker zusammen als die
  Quelle*). Der freistellende Satz spricht von *„Wellen, die vor der Einführung schlossen"*; für
  den wellenlosen Fall gab es vor `v6.0.0` gar keine Regel, von der man freigestellt sein könnte.
  Die Analogie ist zu **prüfen**, nicht zu unterstellen. — **Ausgang: weiter offen →
  Beobachtungs-Register, `BEO-ALL/zusammenfassung-staerker-als-ihre-quelle` (jetzt **6×**,
  `evidence/slice-183.md`).** Die *benannte* Form ist nicht eingetreten:
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 1
  nimmt die Freistellung weder in Anspruch noch legt sie sie aus — sie archiviert statt
  freizustellen und braucht die Analogie darum nicht. Die **Klasse** ist in diesem Slice trotzdem
  zweimal aufgetreten, an anderen Aussagen: Der Plan behauptete, [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) habe zwei
  Re-Evaluierungs-Trigger und einer sei gefeuert (gemessen fünf, keiner — drei Stellen, gezogen von
  `06d64897`), und die Contra-Zelle der Option E behauptete eine Kosten-Obermenge über B, die ihre
  eigene Folgepflicht 1 widerlegt (Review-Runde 2, MEDIUM-2). Ein Vorgang zählt einmal; beide Funde
  stehen in dem einen Beleg.
- **Die Archivierung nimmt einem vorhandenen Sensor seinen Geltungsbereich, ohne dass er rot wird**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  Stand `geplant`). Die Ziel-Fassung sagt das selbst: *„Ein Sensor, der auf `done/*.md` keilt, sieht
  die archivierten Stubs im Unterverzeichnis nicht mehr und bleibt grün, ohne noch etwas zu
  prüfen."* Mit dem Befund in §1 trifft das hier **zu** statt daneben: Das Archiv liegt unter
  `done/<welle-id>/`, nicht flach — [`harness/README.md`](../../../../harness/README.md) führt die
  Grenze für die `closure`-Fähigkeit bereits und verlangt, sie vor der ersten Archivierung
  nachzuziehen oder zu benennen. — **Ausgang: entfallen.** Dieser Slice archiviert nichts; er
  liefert eine Entscheidung, und ein Sensor-Geltungsbereich kann durch sie nicht kippen. Die Sorge
  ist damit nicht vergessen, sondern umgehängt: Sie steht als **Folgepflicht 3** in der angenommenen
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) — *„Vor dem
  ersten schreibenden Lauf wird der Prüfbereich der `closure`-Fähigkeit nachgezogen oder seine
  Grenze an der Stelle benannt, an der die Zusage heute steht"* — und daneben als
  §Konsequenzen-Negativ derselben Datei; Träger ist der Vorgang, der archiviert. Der
  Register-Eintrag bleibt unberührt bei **12×**, `geplant`: Ein Beleg für ein Auftreten, das es
  hier nicht gab, wäre eine falsche Erhöhung.
- **Der Verweis-Nachzug der Archivierung schreibt in eingefrorene Artefakte**
  ([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md),
  Stand `offen` — die Auflösung ist eine Norm-Frage des Architect). Der Lauf aus §1 misst den
  Blast-Radius: **193** Dateien, darunter eine `Accepted`-ADR, zwei aufgelöste Carveouts und zwei
  Evidence-Dateien genau dieser Beobachtung. Der Slice entscheidet das nicht (§1, Abgrenzung); er
  darf die Frage aber nicht als geklärt ausgeben. — **Ausgang: weiter offen →
  Beobachtungs-Register, `BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (jetzt
  **13×**, `evidence/slice-183.md`).** Eingetreten ist die Klasse in dieser Closure selbst, nicht
  erst bei der Archivierung: Der Verweis-Nachzug des `git mv` nach `done/` schreibt in **vier**
  eingefrorene Zeitdokumente unter `done/` (13 Fundstellen) und in **zwei** Rollen-Reports unter
  `docs/reviews/`; die Kommandos stehen im Beleg. **Eine Adresse hat der Eintrag nicht** —
  [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md) schließt
  diese Norm-Frage in seinem §1 ausdrücklich aus, und einen Ausgang zuzuweisen ist der
  **Lese-Schritt**, der in diesem Repo der Welle-Closure gehört (§7).
- **Die neue ADR steht auf `Proposed` und bindet keinen Durchgang.** Zwei Slice-Kennungen in
  `open/` tragen diese Restpflicht für ältere Entscheidungen
  ([slice-171](../open/slice-171-adr-0031-acceptance-trigger.md),
  [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md));
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) hat ihren Übergang
  inzwischen vollzogen und ist seit dem 2026-09-10 `Accepted`. Der Acceptance-Trigger gehört darum
  in die neue ADR selbst. — **Ausgang: entfallen.**
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) trägt seit dem
  2026-09-12 `Status: Accepted`. Der Acceptance-Trigger stand in der Datei, und der Beleg, den er
  verlangt, ist die dritte Reviewer-Runde ohne blockierenden Befund
  (`docs/reviews/2026-09-12-adr-0041-wellenloser-altbestand-r3.md`, Kategorie-Summary 0 HIGH ·
  0 MEDIUM) — eine **erneute** Runde derselben prüfenden Rolle, wie
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 sie
  nach einem blockierenden Befund verlangt. Die Restpflicht, die
  [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md) und
  [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md) für ältere Entscheidungen tragen,
  hat hier keinen Gegenstand.
- **Der Beleg für die eigene Rückführung steht aus.** Der Lifecycle-Move dieses Slice nach
  `in-progress/` hat den Ruhe-Marker der Roadmap gegen den Inhalt von `in-progress/` gestellt
  (`docs-check`, Grund-Code `planning-drift`); die Rückführung nach `next/` hebt ihn wieder auf.
  Das ist ein Auftreten von
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  und steht dort **benannt und nicht gezählt**, weil der Vorgang, der es trägt, nicht abgeschlossen
  ist (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register: *„Ein Vorkommen ohne
  abgeschlossenen Vorgang bekommt keinen Beleg und bewegt den Zähler nicht; es gehört trotzdem in
  den Eintrag"*). — **Ausgang: weiter offen → Beobachtungs-Register,
  `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (jetzt **13×**,
  `evidence/slice-183.md`).** Mit dieser Closure ist der Vorgang abgeschlossen, der Beleg damit
  fällig und geschrieben; der Vermerk *Benannt, nicht gezählt* in der `state.md` jenes Eintrags ist
  mit ihm entfallen. Der Beleg trägt **beide** Moves: die Rückführung, die den Ruhe-Marker wieder
  richtig stellte, und den Closure-Move, dessen präfixlose Referenz in der Roadmap `make slice-mv`
  nach eigener, gemessener Grenze nicht erreicht — sie ist in einem eigenen Commit nachgezogen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die **Messung vor dem Zug**, zweimal und beide Male mit anderem
  Ergebnis als der Befund es nannte. Review-Runde 1 meldete fünf Fundorte für die fehlende
  Zitierform; `379def11` maß die Fundmenge und zog neun. Die Plan-Korrektur `06d64897` bekam zwei
  gemeldete Zeilen und zog drei, dazu eine vierte anderer Klasse. Beide Kommandos stehen in den
  Commit-Messages, nicht nur die Zahlen — das ist genau die Regel, die
  `BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` (4×, `geplant`,
  [slice-209](../open/slice-209-report-trennt-fundort-von-fundmenge.md)) noch schreiben soll, hier
  schon praktiziert. Sie hat die Schleife nicht verlängert, sondern beendet: Runde 3 fand über die
  gezogenen Stellen keinen überlebenden Rest. **Und der Konflikt-Pfad hat getragen:** Als ADR und
  Slice-Plan einander widersprachen, entstand Verdikt 1 mit dem Plan-Diff als Übergabe-Artefakt
  (Baseline-Regelwerk `v6.5.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz)
  statt einer stillen Angleichung.
- **Was ging anders als geplant:** Der Slice hieß *Auslöser der wellenlosen Archivierung* und hat
  über den Auslöser nichts entschieden. Die Messung in §1 hat seiner ersten Hälfte den Gegenstand
  genommen — *wellenlos* ist eine Eigenschaft des **Repos**, dieses fährt Wellen, und die
  Welle-Closure sammelt die wellenlosen Slices bereits ein —, und die verbliebene Hälfte saß auf
  einer Vorbedingung mit eigener Alternativen-Menge. Das kostete eine Rückführung nach `next/` und
  einen neuen Schnitt (§4). Zweitens trug der Plan eine **falsche Prämisse über eine fremde,
  eingefrorene Quelle** an drei Stellen, bis in DoD 2 hinein: [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) habe zwei
  Re-Evaluierungs-Trigger und einer sei gefeuert. Gemessen sind es fünf, gefeuert keiner. Die
  Prämisse wanderte in den ADR-Erstentwurf und wurde dort zur tragenden Begründung des
  *Kein-`Supersedes`*; gefallen ist sie erst in Review-Runde 1. Drittens: Der Dateiname dieses
  Plans passt nicht mehr zum Titel und bleibt trotzdem stehen — ihn zu ziehen hieße, in vier
  eingefrorene Zeitdokumente zu schreiben (§1).
- **Steering-Loop-Eintrag:** Regel geschärft (Kandidat, **nicht** verkörpert): **Eine Prämisse
  über eine fremde, eingefrorene Quelle, auf die ein Slice-Plan die ausführende Rolle festlegt, ist
  vor dem Übergang `open → next` zu messen — mit Kommando und Zahl im Plan.** Die bestehenden
  Regeln decken Nachbarfelder, nicht diesen Fall:
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  bindet **Zahlen** in lebenden Artefakten,
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) die **Zitierform** einer
  Regelwerks-Aussage — eine Behauptung über die Festlegungen und Trigger einer **ADR dieses Repos**
  trifft keine von beiden. Der Preis war hier zwei Review-Runden, ein Konflikt-Pfad-Verdikt und ein
  DoD-Punkt, der gegen den angenommenen Text wörtlich unerfüllbar geworden wäre. Auslöser:
  `BEO-ALL/zusammenfassung-staerker-als-ihre-quelle` (6×) und `BEO-ALL/baseline-aussage-ohne-mess-tag`
  (2×). Verkörpern ist Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und gehört an
  den Lese-Schritt der nächsten Welle-Closure; dieser Eintrag ist damit **gezählt, nicht
  verkörpert**, und trägt darum kein Feld `liegt in`.
- **Beobachtungs-Register (`../observations/`):** vier `evidence/slice-183.md` ergänzt, jeder
  Zähler als Dateizahl abgelesen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
  Erwartungswerte) — `zusammenfassung-staerker-als-ihre-quelle` **6×** ·
  `baseline-aussage-ohne-mess-tag` **2×** ·
  `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` **13×** ·
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` **13×**. Die `state.md` des letzten
  Eintrags hat ihren Vermerk *Benannt, nicht gezählt* verloren: Er sagte, der Beleg entstehe mit
  dieser Closure, und das ist geschehen. **Neu angelegt wurde kein Verzeichnis** — die
  wiederkehrende Finding-Klasse der drei Runden, die der Report als *„Beleg-Block trägt die
  Aussage nicht, die auf ihn zeigt"* benennt, hat ihre zwei Mitglieder in den zwei ersten Einträgen
  oben: Runde 1 HIGH-1 die **Form** der Berufung, Runde 2 MEDIUM-2 ihre **Substanz**. Ein
  Dach-Eintrag darüber zählte dieselben Funde ein zweites Mal und schluckte vier bestehende, engere
  Klassen. **Eine Klasse ist ausdrücklich nicht angefallen:**
  `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` bleibt bei **4×** — beide
  Behebungs-Läufe haben die Fundmenge gemessen statt das Wortmuster des Befundes zu ziehen.
  **Zwei der vier Einträge stehen weit über der Schwelle und ohne Ausgang** — der Lese-Schritt
  gehört im Wellen-Betrieb der Welle-Closure, auch für Slices ohne Wellen-Zugehörigkeit
  (Baseline-Regelwerk `v6.5.0`, `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht); **diese
  Closure zählt, sie entscheidet nicht.** Für
  `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (13×) ist das keine Formalie: Die
  `state.md` weist die Frage dem **Architect** zu,
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4
  bindet den Vollzug der Archivierung daran, und
  [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md) **trägt sie
  nicht** — sein §1 schließt sie ausdrücklich aus. Der Eintrag braucht eine eigene Adresse; sie zu
  vergeben ist Lese-Schritt und nicht Sache dieser Closure.
- **Trigger-Audit:** Drei Artefaktklassen, alle drei geprüft. **Carveout** — zwei liegen aktiv
  (`ls docs/plan/carveouts/CO-*.md`): `CO-001` trägt einen eingetretenen Trigger mit
  [slice-113](../open/slice-113-co-001-ist-faellig.md) als Adresse, `CO-002` ist `permanent` und in
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) übergeführt; dieser Slice
  berührt weder `shell-lint` noch `make span-report` und bewegt keinen von beiden.
  **Bootstrap-aware Gate** — keines besteht: Die Modul-Liste in
  [`.d-check.yml`](../../../../.d-check.yml) (`grep -n '^modules:' .d-check.yml`) kennt keine
  Stufen, und kein Gate-Ziel dieses Repos deklariert eine Reifestufe. Wer das mit
  `git grep -l 'Hochschalt-Trigger' -- ':!.harness/baseline'` nachzählt, bekommt eine Trefferliste
  aus Zeitdokumenten, einem offenen Plan und **dieser Datei** — das Wort steht in Plänen über das
  Konzept, nicht in einer Gate-Konfiguration; die Frage beantwortet die Modul-Liste, nicht der
  `grep`. **ADR** — die fünf
  Re-Evaluierungs-Trigger von
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) sind einzeln gemessen und
  keiner ist gefeuert (§1); die fünf der neuen
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) sind mit ihrer
  Annahme entstanden, und ihr feedback-Trigger *„wenn das Sammel-Archiv liegt"* ist am Baum
  ablesbar unerfüllt (`ls -d docs/plan/planning/done/*/ 2>/dev/null | wc -l` → 0).
- **Folge-Slices:**
  [slice-219](../open/slice-219-archivierung-nimmt-einen-schluessel-ohne-welle.md) (Die
  Archivierung nimmt einen Schlüssel, der keine Welle ist) — ist eine Datei in `open/`; er löst
  Folgepflicht 1 der
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) ein und ist
  dort über seine **Eigenschaft** beschrieben statt über eine Kennung, die ein Re-Schnitt bewegt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.11).
- **Risiken aus §6:** fünf Risiken, fünf Ausgänge — zwei *entfallen* mit Begründung, drei *weiter
  offen* mit Beleg im Register; siehe §6.
- **Drei Paarungen:** dieses **Repo** fährt Wellen (§1) — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit. Dass sein Kopf-Feld
  `**Welle:** ohne Welle` trägt, verschiebt die Achse nicht.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area,
die die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
Norm-Artefakte führt. `harness/tools/` ist **nicht** berührt: Der Träger ist das Produkt-Binär
([`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1), und dieser
Slice entscheidet die Zuordnung, keine Werkzeug-Fähigkeit (§3).

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
vollständig durchgegangen. **Jede** Beobachtung trägt `*` (gesamtes Repo) — das Segment
unterscheidet in diesem Repo nichts
([`BEO-ALL/sub-area-spalte-unterscheidet-nichts`](../observations/BEO-ALL/sub-area-spalte-unterscheidet-nichts/observation.md)).
Die Stände sind **gemessen**, nicht abgelesen
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2 — ein Zähler-Stand ist eine datierte Messung; die vorige Fassung dieses Abschnitts trug
zwei überholte Werte):

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l   # 94  (kein Erwartungswert)
cd docs/plan/planning/observations/BEO-ALL
for d in re-baseline-ohne-inventur-slice zusage-nennt-sensor-der-form-nicht-sieht \
         zusammenfassung-staerker-als-ihre-quelle slice-plan-umfang-waechst-ueber-umsetzung-hinaus \
         verweis-nachzug-schreibt-in-eingefrorenes-artefakt \
         lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch; do
  printf '%2s  %s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
#  2  re-baseline-ohne-inventur-slice
# 12  zusage-nennt-sensor-der-form-nicht-sieht
#  5  zusammenfassung-staerker-als-ihre-quelle
#  2  slice-plan-umfang-waechst-ueber-umsetzung-hinaus
# 12  verweis-nachzug-schreibt-in-eingefrorenes-artefakt
# 12  lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Sechs berühren diesen
Slice; **keine** erreicht mit ihm erstmals 3×, vier stehen längst darüber:

- **`re-baseline-ohne-inventur-slice` (2×, `offen`)** — dieser Slice ist ein **Ergebnis** der
  Inventur, nicht ein Nachzügler; er bindet §3 (kein Werkzeug-Slice wird vorab erfunden).
- **`zusage-nennt-sensor-der-form-nicht-sieht` (12×, `geplant`)** — Risiko 2 in §6, bindet DoD 3.
- **`zusammenfassung-staerker-als-ihre-quelle` (5×, `offen`)** — Risiko 1 in §6.
- **`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` (2×, `offen`)** — bindet diesen Plan selbst;
  die Rückführung hat ihn neu gefasst statt ihm einen Absatz beigestellt.
- **`verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (12×, `offen`)** — Risiko 3 in §6, und der
  Grund, warum der Dateiname dieses Plans stehen bleibt (§1).
- **`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (12×, `offen`)** — Risiko 5 in §6; der
  Beleg dieses Slice steht dort benannt und noch nicht gezählt.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

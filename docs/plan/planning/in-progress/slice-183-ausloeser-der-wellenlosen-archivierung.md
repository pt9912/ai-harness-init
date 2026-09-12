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
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (von ihren
Re-Evaluierungs-Triggern feuert **einer**; der zweite trifft dieses Repo nicht — §1),
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

**Von den zwei Re-Evaluierungs-Triggern der
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) feuert darum einer, nicht
zwei.** Der erste (*„wenn die Baseline … ihren Träger selbst benennt"*) trägt: `v6.0.0` gibt dem
Fall eine sechste Zeile in jener Träger-Tabelle (Position **P-06** des Katalogs in
[slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9). Der zweite (*„wenn ein Repo
ohne Wellen-Betrieb die Archivierung braucht"*) trifft dieses Repo **nicht** — seine Bedingung ist
oben widerlegt. Der Träger bleibt in beiden Fällen das Produkt-Binär (jene Festlegung 1 ist
unberührt).

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

- [ ] **Die ADR liegt und entscheidet die Zuordnung** — ob der wellenlose Altbestand (57, §1)
      archiviert wird und, wenn ja, welche Welle ihn einsammelt: die chronologisch nächste
      geschlossene Welle oder ein einzelnes Sammel-Archiv, die zwei Formen, die die Ziel-Fassung
      selbst nennt. Die Freistellung *„Kein Zwang zum Nachrüsten — und kein Verbot"* spricht von
      *„Wellen, die vor der Einführung schlossen"*; ob sie den **wellenlosen** Bestand trägt, sagt
      sie nicht — genau diese Lücke ist zu schließen. Die Entscheidung nennt ihren `Status`; bei
      `Proposed` steht der Acceptance-Trigger daneben (Präzedenz
      [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md)).
- [ ] **Das Verhältnis zu [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
      ist ausgesprochen:** kein `Supersedes` — deren Festlegung 1 (Träger = Produkt-Binär) bleibt
      unberührt, gefeuert ist **einer** ihrer Trigger, und ein gefeuerter Trigger ändert die
      Entscheidung nicht, sondern verlangt eine daneben. Dass ihr zweiter Trigger dieses Repo
      nicht trifft, gehört in die neue Entscheidung: Jene ist seit dem 2026-09-10 `Accepted` und
      wird dafür nicht angefasst ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
- [ ] **Der Sensor-Stand ist benannt statt behauptet.** Kein Gate dieses Repos meldet einen
      geschlossenen Slice ohne Archiv; was es gibt, ist die `untergrenze`-Sperre der Vorschau, und
      die ist kein Gate und steht in keiner Prerequisite-Kette. Welche Kandidaten es sonst gibt und
      warum sie nicht messen, steht in der Fitness-Function-Sektion der ADR — ein Sensor, der dort
      als vorhanden ausgegeben würde, wäre [`AGENTS.md`](../../../../AGENTS.md) §3.1 eine Ebene
      tiefer.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8); er ist zugleich der Beleg, den
      [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
      für einen Accept-Übergang verlangt.
- [ ] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue
      Zeile ([`AGENTS.md`](../../../../AGENTS.md) §5). Ein öffentlicher Vertrag ist nicht berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine
      Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. **Ein Beleg steht
      schon aus:** Die Rückführung dieses Slice nach `next/` ist ein benanntes, noch nicht
      gezähltes Auftreten von
      [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
      (§6) — mit der Closure dieses Slice wird daraus `evidence/slice-183.md`.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
  Die Analogie ist zu **prüfen**, nicht zu unterstellen. — **Ausgang:** <…>
- **Die Archivierung nimmt einem vorhandenen Sensor seinen Geltungsbereich, ohne dass er rot wird**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  Stand `geplant`). Die Ziel-Fassung sagt das selbst: *„Ein Sensor, der auf `done/*.md` keilt, sieht
  die archivierten Stubs im Unterverzeichnis nicht mehr und bleibt grün, ohne noch etwas zu
  prüfen."* Mit dem Befund in §1 trifft das hier **zu** statt daneben: Das Archiv liegt unter
  `done/<welle-id>/`, nicht flach — [`harness/README.md`](../../../../harness/README.md) führt die
  Grenze für die `closure`-Fähigkeit bereits und verlangt, sie vor der ersten Archivierung
  nachzuziehen oder zu benennen. — **Ausgang:** <…>
- **Der Verweis-Nachzug der Archivierung schreibt in eingefrorene Artefakte**
  ([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md),
  Stand `offen` — die Auflösung ist eine Norm-Frage des Architect). Der Lauf aus §1 misst den
  Blast-Radius: **193** Dateien, darunter eine `Accepted`-ADR, zwei aufgelöste Carveouts und zwei
  Evidence-Dateien genau dieser Beobachtung. Der Slice entscheidet das nicht (§1, Abgrenzung); er
  darf die Frage aber nicht als geklärt ausgeben. — **Ausgang:** <…>
- **Die neue ADR steht auf `Proposed` und bindet keinen Durchgang.** Zwei Slice-Kennungen in
  `open/` tragen diese Restpflicht für ältere Entscheidungen
  ([slice-171](../open/slice-171-adr-0031-acceptance-trigger.md),
  [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md));
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) hat ihren Übergang
  inzwischen vollzogen und ist seit dem 2026-09-10 `Accepted`. Der Acceptance-Trigger gehört darum
  in die neue ADR selbst. — **Ausgang:** <…>
- **Der Beleg für die eigene Rückführung steht aus.** Der Lifecycle-Move dieses Slice nach
  `in-progress/` hat den Ruhe-Marker der Roadmap gegen den Inhalt von `in-progress/` gestellt
  (`docs-check`, Grund-Code `planning-drift`); die Rückführung nach `next/` hebt ihn wieder auf.
  Das ist ein Auftreten von
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  und steht dort **benannt und nicht gezählt**, weil der Vorgang, der es trägt, nicht abgeschlossen
  ist (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register: *„Ein Vorkommen ohne
  abgeschlossenen Vorgang bekommt keinen Beleg und bewegt den Zähler nicht; es gehört trotzdem in
  den Eintrag"*). — **Ausgang:** <…>

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
Slice entscheidet ohnehin nur den Auslöser.

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

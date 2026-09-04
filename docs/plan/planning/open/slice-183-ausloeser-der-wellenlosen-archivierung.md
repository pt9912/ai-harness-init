# Slice slice-183: Der Auslöser der Zeitdokumente-Archivierung im wellenlosen Betrieb wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — **kein Mitglied von [welle-15](../welle-15-re-baseline.md), und der Grund
ist ihr eigener Closure-Trigger.** Der fordert alle Slices der Welle in `done/`, zwei grüne
repo-weite Läufe und den vollzogenen Pin; die Archivierung eines wellenlosen Slice steht in keiner
dieser Bedingungen. Das Welle-Ziel *„jede Pflicht, die die neue Fassung mitbringt, hat einen
verbuchten Ausgang"* ist mit **dieser Datei in `open/`** eingelöst — ein Ausgang ist ein Träger,
kein Vollzug. Ausdrücklich benannt statt stillschweigend weggelassen (`BEO-018`,
[welle-15](../welle-15-re-baseline.md) §4).

**Bezug:**
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (**zwei** ihrer
Re-Evaluierungs-Trigger sind mit diesem Sprung gefeuert — §1),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(dieses Repo führt Wellen **und** wellenlose Slices — ohne diese Doppelnatur hätte die neue Regel
hier keinen Gegenstand),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Pflicht kommt aus
dem auf einen Tag gepinnten Baum),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate meldet einen nicht archivierten Slice — die Lücke gehört benannt, nicht behauptet).

**Berührte Spec-Stellen:** `—`. Der Slice entscheidet eine Prozess-Frage; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Wann ein wellenlos geschlossener Slice seine Zeitdokumente archiviert — und was mit dem Bestand
geschieht, der vor der Regel geschlossen wurde — steht als angenommene Entscheidung auf Rang 4 der
Source Precedence.**

**Der Anlass ist gemessen, nicht vermutet.** `v6.0.0` gibt dem Fall einen Träger, den `v5.18.0`
ausdrücklich offen ließ: `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht bekommt eine
sechste Zeile in der Träger-Tabelle — *Zeitdokumente archivieren (Closure-Schritt 4) ·
Slice-Closure · nach den Paarungen*, Schlüssel `done/slice-<NNN>-archiv.zip` **flach** neben dem
Stub —, und `modul-05` wie `modul-10` ziehen nach (Position **P-06** des Katalogs in
[slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9).

**Damit feuern zwei Re-Evaluierungs-Trigger von
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) gleichzeitig** — der erste
(*„wenn die Baseline … ihren Träger selbst benennt"*) und der zweite (*„wenn ein Repo ohne
Wellen-Betrieb die Archivierung braucht … der **Auslöser** ist neu zu entscheiden, nicht der
Träger"*). Der Träger bleibt das Produkt-Binär (jene Festlegung 1 ist unberührt); offen ist der
Auslöser.

**Der Gegenstand ist nicht klein, und das ist gemessen:** 47 der geschlossenen Slices tragen
`**Welle:** ohne Welle`, und archiviert ist bislang keiner.

```sh
n=0; for f in docs/plan/planning/done/slice-*.md; do \
  grep -q '^\*\*Welle:\*\* ohne Welle' "$f" && n=$((n+1)); done; echo "$n"   # 47
ls -d docs/plan/planning/done/welle-*/ 2>/dev/null | wc -l                   #  0
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Was dieser Slice nicht tut.** Er baut den Einzel-Slice-Modus des Werkzeugs nicht. Dessen
Zuschnitt hängt an der Entscheidung hier — ihn vorab zu erfinden wäre genau der Schnitt vor der
Messung, gegen den `BEO-010` steht.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die ADR liegt und entscheidet den Auslöser** — ob und ab wann die Slice-Closure eines
      wellenlosen Slice archiviert, und was mit den 47 bereits geschlossenen geschieht. Die
      Ziel-Fassung stellt den **Wellen**-Altbestand ausdrücklich frei (*„Kein Zwang zum
      Nachrüsten — und kein Verbot"*, zwischen den Tags byte-gleich); ob dieselbe Freistellung den
      **wellenlosen** Altbestand trägt, sagt sie nicht — genau diese Lücke ist zu schließen. Die
      Entscheidung nennt ihren `Status`; bei `Proposed` steht der Acceptance-Trigger daneben
      (Präzedenz [slice-171](slice-171-adr-0031-acceptance-trigger.md)).
- [ ] **Das Verhältnis zu [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
      ist ausgesprochen:** kein `Supersedes` — deren Festlegung 1 (Träger = Produkt-Binär) bleibt
      unberührt, gefeuert sind zwei ihrer Trigger, und ein gefeuerter Trigger ändert die
      Entscheidung nicht, sondern verlangt eine daneben. Was sie über den Auslöser sagt, ist
      wörtlich *„Diese Entscheidung sagt über ihn nichts."*
- [ ] **Der Sensor-Stand ist benannt statt behauptet.** Kein Gate dieses Repos meldet einen
      geschlossenen Slice ohne Archiv; welche Kandidaten es gibt und warum sie es nicht messen,
      steht in der Fitness-Function-Sektion — ein Sensor, der dort als vorhanden ausgegeben würde,
      wäre [`AGENTS.md`](../../../../AGENTS.md) §3.1 eine Ebene tiefer.
- [ ] `make gates` grün.
- [ ] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue
      Zeile ([`AGENTS.md`](../../../../AGENTS.md) §5). Ein öffentlicher Vertrag ist nicht berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
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

**Der Werkzeug-Slice entsteht aus dieser Entscheidung, nicht neben ihr.** Fällt sie so aus, dass
der Einzel-Slice-Modus gebraucht wird, benennt sie ihn als Folgepflicht; die Datei in `open/`
schneidet dann der Planner. Die Präzedenz im Nachbar-Repo ist dieselbe Reihenfolge —
`unzip -p /Development/d-check/docs/plan/planning/done/welle-88/archiv.zip
docs/plan/planning/done/slice-193-baseline-v600-bump.md` §3 hält die Regelwerks-Adoption und die
Werkzeug-Umsetzung getrennt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-182](slice-182-baum-tausch-v600-pins-ziehen.md) liegt in `done/`. Der Grund ist tragend:
Bis zum Tausch ist `v5.18.0` der Ist-Maßstab
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und die Regel,
die hier entschieden wird, steht erst danach im vendored Baum — eine ADR, die einen Text zitiert,
der netzlos nicht vorliegt, hätte keine belegbare Quelle.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Frage nach dem **Altbestand**
  eine eigene Abwägung mit eigenen Alternativen verlangt — 47 Vorgänge sind kein Anhang zu einer
  Auslöser-Entscheidung. Dann trennt der Schnitt den laufenden Betrieb vom Altbestand.
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
  Quelle das sagt** (`BEO-027`, 1× — *ein lebendes Plan-Artefakt fasst eine Entscheidung stärker
  zusammen als die Quelle*). Der freistellende Satz spricht von *„Wellen, die vor der Einführung
  schlossen"*; für den wellenlosen Fall gab es vor `v6.0.0` gar keine Regel, von der man
  freigestellt sein könnte. Die Analogie ist zu **prüfen**, nicht zu unterstellen. —
  **Ausgang:** <…>
- **Die Archivierung nimmt einem vorhandenen Sensor seinen Geltungsbereich, ohne dass er rot wird**
  (`BEO-025`, 2×). Die Ziel-Fassung sagt das selbst: *„Ein Sensor, der auf `done/*.md` keilt, sieht
  die archivierten Stubs im Unterverzeichnis nicht mehr und bleibt grün, ohne noch etwas zu
  prüfen."* Für den wellenlosen Fall liegt das Archiv **flach** neben dem Stub, nicht in einem
  Unterverzeichnis — ob die Warnung damit entfällt oder sich nur verschiebt, gehört gemessen. —
  **Ausgang:** <…>
- **Die ADR steht auf `Proposed` und bindet keinen Durchgang.** Drei Slice-Kennungen in `open/`
  tragen heute diese Restpflicht für ältere Entscheidungen
  ([slice-171](slice-171-adr-0031-acceptance-trigger.md),
  [slice-152](slice-152-adr-0029-acceptance-trigger.md) — und
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) selbst steht auf
  `Proposed`). Der Acceptance-Trigger gehört darum in die ADR selbst. — **Ausgang:** <…>

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
- **Drei Paarungen:** dieser Slice läuft **ohne Welle** — Anker, Folge-Slice und Register sind
  hier zu prüfen, nach dem `git mv` nach `done/`.

## 8. Sub-Area-Modus-Begründung

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

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand, keine erreicht mit
ihm 3×:

- `BEO-010` (2×) — *Re-Baseline ohne vorgeschalteten Inventur-Slice, Form-Pflichten kommen als
  Nachzügler*. Dieser Slice ist ein **Ergebnis** der Inventur, nicht ein Nachzügler; er bindet §3
  (der Werkzeug-Slice wird nicht vorab erfunden).
- `BEO-025` (2×) — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*. Steht als
  Risiko in §6 und bindet DoD 3.
- `BEO-027` (1×) — *ein lebendes Plan-Artefakt fasst eine Entscheidung stärker zusammen als die
  Quelle*. Steht als Risiko in §6.
- `BEO-016` (1×) — *Slice-Pläne tragen ein Vielfaches der nötigen Zeilenzahl*. Bindet diesen Plan
  selbst; er ist deshalb knapp gehalten.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

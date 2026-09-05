# Welle welle-15: Re-Baseline — der vendored Baum zieht auf `v6.0.0`

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<NN>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug — Harness-Wartung, keine Nutzer-Fähigkeit des
Werkzeugs.

**Verantwortlich:** Planner. **Datum:** 2026-09-04.

---

## 1. Welle-Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

**Regelwerk und Templates, nach denen dieses Repo arbeitet, stehen auf `v6.0.0` — und jede Pflicht,
die die neue Fassung mitbringt, hat einen verbuchten Ausgang, statt einzeln als Nachzügler
zurückzukommen.**

**Der Schnitt beginnt mit einer Inventur, nicht mit einer Schätzung** (`BEO-ALL/re-baseline-ohne-inventur-slice` im
[Register](observations/README.md), 2×). Wie viele Mitglieder diese Welle bekommt, beantwortet
[slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md): **sieben**, dazu ein
ausdrücklich ausgeschlossener Folge-Slice (§4). Die Zahl steht seit dem Katalog fest und nicht
seit der Eröffnung. **Ein achtes Mitglied kam danach hinzu** — nicht aus dem Katalog, sondern aus
dem vollzogenen Umzug, und genau das ist die Grenze, die ein Diff-Katalog seiner Bauart nach hat
(§4, Zeile 8). Gezählt wird die Tabelle in §4, nicht dieser Satz:
`sed -n '/^| Slice | Titel | Bezug |/,/^$/p' docs/plan/planning/welle-15-re-baseline.md | grep -c '^| \[slice-'`
→ **8**.

**Zwei Fragen entscheidet diese Datei nicht.** Wer den Zielstand bewegt, steht in
[`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt*; **wo**
die Setzung verbucht wird, in
[`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 —
§Baseline von [`harness/conventions.md`](../../../harness/conventions.md), drei Teile, und die
Datei gehört dem Architect ([`AGENTS.md`](../../../AGENTS.md) §3.8). Welche Fassung die
Migrations-Prozedur **dieses** Sprungs stellt, ist offen: Festlegung 1 jener ADR gilt nur für
`v5.12.0` → `v5.18.0`, ihr erster Re-Evaluierungs-Trigger verlangt für den nächsten Sprung eine
neue Messung. Die Messung liegt vor
([slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) §9, zweistufig); die **Wahl**
ist offen und trägt [slice-178](done/slice-178-regierende-fassung-des-sprungs-v600.md). Beide
Posten stehen als Übergaben in §5.

## 2. Trigger (Welle startet)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Regeln — ein Trigger ist **beobachtbar** dann, wenn ein *anderer*
Mensch ohne Rückfrage sagen kann, ob er eingetreten ist; ein Datum darf erwähnt
werden, aber nie Trigger sein. Und der **Start**-Trigger ist **kein Ergebnis
dieser Welle**: Steht er in der Slice-Liste unten, ist er falsch platziert.

- **`make baseline-freshness` meldet VERALTET.** Gefahren am 2026-09-04: `gepinnt: v5.18.0`,
  `latest: v6.0.0`, Exit ≠ 0. Beide Angaben wandern mit dem Upstream-Stand und sind keine
  Erwartungswerte
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beobachtbar ist der Ausgang des Kommandos, nicht die Zahl.
- **[welle-14](done/welle-14-re-baseline.md) liegt in `done/`.** Beobachtbar ohne Rückfrage: die
  Plan-Datei liegt neben ihrer Ergebnis-Notiz. Der Grund ist **ordnend**: Der Sprung geht vom
  adoptierten Stand `v5.18.0` aus, und den hat jene Welle gesetzt.

## 3. Closure-Trigger (Welle schließt)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — der Trigger muss das *Mehr* gegenüber den
einzelnen Slice-DoDs benennen; kann er das nicht, liegt keine Welle vor.

- Alle Slices dieser Welle liegen in `done/`.
- `make gates` grün.
- `make full-smoke` grün.
- Der Pin ist vollzogen: `make baseline-verify` meldet `v6.0.0 OK`, und §Baseline von
  [`harness/conventions.md`](../../../harness/conventions.md) nennt denselben Tag.
- Closure-Notiz geschrieben.

**Das *Mehr* sind die zwei repo-weiten Läufe und der Pin-Beleg** — sie stehen in keiner einzelnen
Slice-DoD, weil keine einzelne über den ganzen Baum urteilt. `make full-smoke` ist genannt, weil
der Baum-Tausch von [welle-10](done/welle-10-re-baseline.md) genau dort brach und für
`make gates` unsichtbar blieb ([slice-133](done/slice-133-emittierter-baum-ohne-platzhalter-links.md)).

## 4. Slices in dieser Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine — der Zustand eines Slice ist sein
Lifecycle-Verzeichnis und wird hier **nicht** gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) | Inventur vor dem Schnitt — der Form- und Regel-Diff `v5.18.0` → `v6.0.0` | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) |
| [slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) | Das Beobachtungs-Register läuft in der Verzeichnis-Form | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) |
| [slice-178](done/slice-178-regierende-fassung-des-sprungs-v600.md) | Die regierende Fassung dieses Sprungs wird entschieden (Architect) | [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md), [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) |
| [slice-179](done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) | Die Form des Beobachtungs-Registers wird entschieden — vor dem Umzug (Architect) | [`ADR-0030`](../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-182](done/slice-182-baum-tausch-v600-pins-ziehen.md) | Der vendored Baum steht auf `v6.0.0` — Pins gezogen, Setzung verbucht | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) |
| [slice-184](done/slice-184-register-form-im-bestand-nachziehen.md) | Die Form-Beschreibung des Beobachtungs-Registers zieht im Bestand nach | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0028`](../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), [`ADR-0034`](../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) |
| [slice-185](done/slice-185-adaptions-durchgang-gegen-v600.md) | Der Adaptions-Durchgang gegen `v6.0.0` — jeder Eintrag mit eigenem Ausgang (Architect) | [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md), [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| [slice-186](in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) | Jede zitierte Beobachtungs-Kennung löst wieder auf | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0034`](../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md), [`ADR-0016`](../adr/0016-verweis-traegt-tag-und-zitat.md) |

**Acht Mitglieder — sieben stehen seit dem Katalog fest, das achte seit dem Vollzug.** `BEO-ALL/re-baseline-ohne-inventur-slice`
([Register](observations/README.md)) misst an einer Re-Baseline den Abstand zwischen geschnittenen und
geschlossenen Slices, und die Ursache war der Schnitt **vor** der Inventur; die Zeilen 5 bis 7
sind darum aus [slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 hervorgegangen und
nicht vorab gesetzt. Jede Umplanung trägt das Drift-Log der [Roadmap](in-progress/roadmap.md).

**Zeile 8 folgt nicht dem Katalog, sondern dem vollzogenen Umzug** — dieselbe Ausnahme, die
[welle-14](done/welle-14-re-baseline.md) §4 für zwei ihrer Zeilen führt, und sie ist gemessen statt
vermutet. Der Katalog weist Position **P-02** (*Kennung: `BEO-<NNN>` → `BEO-<KUERZEL>/<slug>`*)
[slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) zu und vermerkt
ausdrücklich *„kein neuer Slice"*. Diese Zuordnung deckt die **Verzeichnisse**; sie deckt nicht die
**Zitate** der abgeschafften Nummer, die seit dem Umzug in **23** lebenden Dateien stehen und
nirgends mehr auflösen (Kommandos in
[slice-186](in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) §1). Ein Katalog ordnet
**Positionen** einen Träger zu; eine Position kann mehrere Konsumenten haben — genau die Erfahrung,
die [`BEO-ALL/re-baseline-ohne-inventur-slice`](observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md)
führt.

**Mitglied aus Gleichzeitigkeit, wie Zeile 6.** Die toten Zitate sind mit dem Umzugs-Commit dieser
Welle entstanden; ein Ausgang in `open/` wäre hier kein **verbuchter** Ausgang, sondern der
Nachzügler, gegen den das Welle-Ziel steht. Das unterscheidet Zeile 8 von
[slice-183](open/slice-183-ausloeser-der-wellenlosen-archivierung.md), der aus demselben Katalog
kommt und **draußen** bleibt: Dort entscheidet der Slice eine offene Frage, und nichts im Baum ist
gebrochen, solange er wartet.

**Zeile 5 löst zwei Closure-Bedingungen dieser Welle ein**, die keine andere einlösen kann (§3):
`make baseline-verify` meldet `v6.0.0 OK`, und §Baseline von
[`harness/conventions.md`](../../../harness/conventions.md) nennt denselben Tag. Sie trägt darum
auch die **Zielstand-Buchung** nach
[`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 — den
Platz dafür hielt der letzte Absatz dieser Sektion, jetzt hat er seinen Slice.

**Zeile 6 ist Mitglied aus Gleichzeitigkeit, nicht aus Nähe.** Sobald
[slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) die Ablage umzieht, weisen
zehn lebende Slice-Pläne und vier Anweisungssatz-Dateien einen Vorgang an, den es nicht mehr gibt.
Ein Ausgang in `open/` wäre hier gerade **kein** verbuchter Ausgang: Der Nachzügler, gegen den das
Welle-Ziel steht, wäre mit dem Umzug schon da.

**Zeile 7 ist keine Katalog-Position, sondern eine Eigenschaft der Prozedur** — und steht deshalb
in [slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 in einem eigenen Abschnitt
neben der Tabelle. Der Adaptions-Durchgang stellt seine Frage **pro Eintrag**, nicht pro Hunk; ein
Katalog kann ihn strukturell nicht finden. Er ist Mitglied, weil beide Fassungen die Prozedur
byte-gleich führen und er eine ihrer sieben Eigenschaften ist — Präzedenz
[slice-157](done/slice-157-adaptions-durchgang-v5180.md) in
[welle-14](done/welle-14-re-baseline.md).

**Ein Katalog-Slice ist ausdrücklich kein Mitglied**, und der Grund gehört hierher statt in ein
stilles Weglassen (`BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich`):
[slice-183](open/slice-183-ausloeser-der-wellenlosen-archivierung.md) — *Der Auslöser der
Zeitdokumente-Archivierung im wellenlosen Betrieb wird entschieden* (Architect). Der
Closure-Trigger dieser Welle (§3) nennt ihn in keiner seiner fünf Bedingungen, und das Welle-Ziel
verlangt einen **verbuchten Ausgang**, keinen Vollzug — die Datei in `open/` ist er. Position
**P-06** des Katalogs.

**Zeile 2 folgt nicht dem Katalog, sondern einer Messung neben ihm** — dieselbe Ausnahme, die
[welle-14](done/welle-14-re-baseline.md) §4 für zwei ihrer Zeilen führt. Die Position ist einzeln
gemessen (`git diff --name-status v5.18.0 v6.0.0 -- lab/templates/docs/plan/planning` am lokalen
Kurs-Klon: die Register-Vorlage wird durch eine Vorlage je **Beobachtung** ersetzt), und der Anlass
kommt von außerhalb des Sprungs: eine flache Datei, in die **jede** Slice-Closure schreibt, ist ein
Kollisions-Punkt für parallel arbeitende Rolleninhaber — begründet in
[slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) §1. Der Katalog weist diese
Position jenem Slice zu, statt einen zweiten zu erzeugen.

**Zeile 3 und 4 sind die zwei Entscheidungen, ohne die diese Welle kein Konformitäts-Urteil
fällen darf.** [slice-178](done/slice-178-regierende-fassung-des-sprungs-v600.md) löst Übergabe 1
aus §5 ein — die Präzedenz ist derselbe Gegenstand eine Runde früher
([slice-163](done/slice-163-regierende-fassung-des-sprungs.md), Mitglied von
[welle-14](done/welle-14-re-baseline.md)).
[slice-179](done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) geht Zeile 2 voraus: Die
Ziel-Form nimmt dem Register seine flache Datei, und
[`ADR-0030`](../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4 verlangt
für genau diesen Fall die Entscheidung **vor** dem Move.

**Die Reihenfolge ist eine Kette, keine Liste** — und die Kette trägt hier keine eigene Zahl, damit
sie nicht gegen die Tabelle driftet. Zeile 5 (Baum-Tausch) geht Zeile 2
voraus, weil die Vorlage, aus der die neue Ablage per `cp` entsteht, netzlos erst danach vorliegt;
Zeile 6 folgt Zeile 2, weil sie deren Ziel-Wortlaut übernimmt. Zeile 8 folgt Zeile 2 aus einem
anderen Grund als Zeile 6 — nicht wegen eines Wortlauts, sondern weil die Plan-Datei von Zeile 2
selbst in ihrer Bezugsmenge steht und mit dem `git mv` nach `done/` ein Zeitdokument wird. Zeile 1
geht allen voraus — sie liefert den Katalog, auf dem 5 und 6 überhaupt geschnitten sind. Die
tragenden Kanten stehen einzeln in §5.

## 5. Abhängigkeiten

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Struktur: fünf Abschnitte.

- **Wird blockiert von: keiner.** Der Start-Trigger ist gefahren und eingetreten (§2).
- **Blockiert: eine Kante, und sie hängt an einem Slice statt an dieser Welle.** Der Katalog
  ([slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) §9) misst die zwei Kandidaten
  von damals einzeln, statt sie zu vermuten. **Die benannten Gegenstände sind byte-gleich:**
  §Freshness-Audit der vendored Baseline (Schritt 2) — der Gegenstand von
  [slice-090](open/slice-090-freshness-audit-im-ziel.md) — trägt zwischen den Tags kein Delta
  (`git diff --name-only v5.18.0 v6.0.0 -- lab/regelwerk/modul-02-harness-bootstrap.md` → leer), und
  §Roadmap-Struktur: fünf Abschnitte — der Gegenstand von
  [slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) — liegt zwischen zwei
  Hunks statt in einem (`git diff v5.18.0 v6.0.0 -- lab/regelwerk/modul-06-roadmap.md | grep '^@@'`
  gegen `git show v5.18.0:lab/regelwerk/modul-06-roadmap.md | grep -n '^### '`). **Was doch
  bewegt wird, ist die Register-Hälfte** — P-09 und P-11 schreiben die Ablage und die
  Register-Paarung (c) neu, und die berührt
  [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md). Dazu wechselt jede Präsens-Aussage
  über den vendored Baum mit dem Tausch ihren Gegenstand
  ([slice-091](open/slice-091-vendored-baum-ohne-anspruch.md),
  [slice-092](open/slice-092-traeger-inventur.md), [`MR-040`](../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)).
  Die Kante ist damit nicht *`welle-15` blockiert beide Wellen*, sondern
  **[slice-182](done/slice-182-baum-tausch-v600-pins-ziehen.md) blockiert
  [slice-091](open/slice-091-vendored-baum-ohne-anspruch.md),
  [slice-092](open/slice-092-traeger-inventur.md) und
  [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md)** — drei Slices, nicht zwei Wellen.
- **Zwei Übergaben an den Architect** stehen in
  [slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) §6 und haben jetzt beide einen
  Träger. Übergabe 1 — die **regierende Fassung dieses Sprungs** — ist **erledigt**: sie steht als
  [`ADR-0036`](../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) (`Accepted`,
  `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0036-*.md`), entschieden von
  [slice-178](done/slice-178-regierende-fassung-des-sprungs-v600.md) auf der zweistufigen
  Messung in jenem §9. Übergabe 2 — die **Buchung der Zielstand-Setzung** nach
  [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 —
  trägt [slice-182](done/slice-182-baum-tausch-v600-pins-ziehen.md) als dessen dritter
  Liefer-Punkt, mit dem **Datum des Vollzugs**. Sie blockieren die **Eröffnung** nicht — ein
  Diff-Katalog ist eine Messung und fällt kein Konformitäts-Urteil —, wohl aber jeden Durchgang,
  der eines fällt.
- **Eine dritte Übergabe ist mit dem Katalog entstanden und liegt außerhalb dieser Welle:** der
  **Auslöser der wellenlosen Zeitdokumente-Archivierung**
  ([slice-183](open/slice-183-ausloeser-der-wellenlosen-archivierung.md), Position P-06). Zwei
  Re-Evaluierungs-Trigger von
  [`ADR-0033`](../adr/0033-wellen-archivierung-als-unterkommando.md) sind mit diesem Sprung
  gefeuert; der Träger bleibt entschieden, der Auslöser nicht.
- **Vier Kanten innerhalb der Welle sind tragend, eine ist ordnend.** Tragend:
  [slice-179](done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) →
  [slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) — ohne die entschiedene
  Kennungs- und Index-Gestalt hat der Umzug kein Ziel, und
  [`ADR-0030`](../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
  verlangt die Entscheidung vor dem Move.
  [slice-182](done/slice-182-baum-tausch-v600-pins-ziehen.md) →
  [slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) — die Vorlage, aus der die
  Ablage per `cp` entsteht, liegt netzlos erst nach dem Tausch vor.
  [slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) →
  [slice-184](done/slice-184-register-form-im-bestand-nachziehen.md) — der Ziel-Wortlaut, den der
  Bestand übernimmt, entsteht dort.
  [slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) →
  [slice-186](in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) — die vierte tragende
  Kante, und sie trägt aus einem anderen Grund als die dritte: Die Plan-Datei von
  [slice-177](done/slice-177-beobachtungs-register-verzeichnis-form.md) ist selbst eines der
  Artefakte, die eine abgeschaffte Kennung zitieren, und verlässt die Bezugsmenge mit ihrem `git mv`
  nach `done/` ([`ADR-0016`](../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4). Ein Nachzug
  davor zöge eine Datei mit, die danach ausdrücklich nicht mehr dazugehört. Ordnend:
  [slice-176](done/slice-176-inventur-vor-dem-schnitt-v600.md) →
  [slice-178](done/slice-178-regierende-fassung-des-sprungs-v600.md), weil die Wahl auf der
  zweistufigen Messung jenes Slice steht.

## 6. Out-of-Scope für diese Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Eröffnung Schritt 1 — Out-of-Scope gehört zur
Zielsetzung: Was nicht ausdrücklich ausgeschlossen ist, dehnt die Welle, bis
der Closure-Trigger unerreichbar wird.

- **Sensor-Neubauten** — sie tragen [welle-13](welle-13-regeln-bekommen-ihren-sensor.md).
- **Die Archivierung des Altbestands** — der Wellen, die vor der Einführung des
  Archivierungs-Schritts schlossen. **Der Katalog hat die offene Hälfte beantwortet:** Der
  freistellende Satz (*„Kein Zwang zum Nachrüsten — und kein Verbot"*) ist zwischen den Tags
  byte-gleich und spricht unverändert von **Wellen**. Was `v6.0.0` neu bringt, ist der wellenlose
  Fall (Position P-06) — und für den gab es vorher keine Regel, von der man freigestellt sein
  könnte. Diese Welle schließt beides aus; **ob** die Freistellung sich auf den wellenlosen
  Altbestand überträgt, entscheidet
  [slice-183](open/slice-183-ausloeser-der-wellenlosen-archivierung.md) und nicht diese Zeile.
- **Der d-check-Pin** ([slice-135](open/slice-135-d-check-pin-v0661.md)) — eigene Linie, eigener
  Trigger; er hängt an keiner Baseline-Version.
- **Jede Senkung einer bestehenden Schwelle.** Wird ein Gate nur durch eine Lockerung grün, ist das
  ein ADR ([`AGENTS.md`](../../../AGENTS.md) §3.5) und ein Rückführungs-Grund, kein Zwischenschritt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker für Steering-Loop-Regeln — dort die **Ruheort-Regel**: Die
beiden Zeiger unten sind so zu schreiben, wie sie vom Ruheort `done/` auflösen,
nicht vom Schreibort.

Die Ergebnis-Notiz ist `welle-15-results.md` — Geschwister im Ruheort `done/`; der Zähler ist das
Beobachtungs-Register eine Ebene darüber. Beide Zeiger werden bei der Closure als Link gesetzt und
lösen dann vom Ruheort auf; vom Schreibort aus zeigen sie ins Leere.

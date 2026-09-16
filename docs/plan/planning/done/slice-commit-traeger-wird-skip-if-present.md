# Slice slice-commit-traeger-wird-skip-if-present: Der emittierte Commit-Träger verliert die konvergente Klasse

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case; die Kennung ist die, die
[`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Folgepflicht 1 vergibt.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt —
kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle entscheidet
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist **kein** Mitglied
von [welle-emittierte-werkzeuge](../done/welle-emittierte-werkzeuge.md): deren vier Mitglieder liegen oder
lagen bei ihrer Eröffnung fest, und dieser Vorgang entstand erst aus dem Architect-Lauf, der sie
schließt.

**Bezug:**
[`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) (**Accepted** — ihre
Festlegung 1 entscheidet die Klasse des Träger-Pfades, ihre Folgepflicht 1 übergibt genau diesen
Vorgang an den Planner; mit ihrem Accept-Übergang bindet sie nach
[ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), und der
Start-Trigger unten ist damit eingetreten),
[ADR-0007](../../adr/0007-bootstrap-phasen.md) (**Accepted** — ihre Festlegung 3 führt die
Idempotenz-Klassifikation **je Datei** und die Wurzeln, unter die dieser Pfad nicht fällt; ihre
Zweifelsregel entscheidet ihn, die Tabelle selbst bleibt eingefroren),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (der Adopter ist ein
**bestehendes** Git-Repo: ein Lauf, der dessen Träger überschreibt, stellt ihn schlechter als er
war),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Lauf, der „Adopter-Inhalt wird geschont" meldet, ohne den Pfad zu prüfen, sagt mehr zu als er hält),
[`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(der Grund, warum dieser Slice **einen** Pfad bindet und die `.claude/`-Zeilen der Tabelle nicht
mitzieht).

**Berührte Spec-Stellen:** `—`. Der Slice zieht eine Emissions-Klasse und die Sätze an ihren
Stellen; kein Zielelement der Spec-Straten wird angefasst.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der emittierte Commit-Träger `.githooks/commit-msg` wird **skip-if-present** abgelegt
statt konvergent: ein Ziel, das an diesem Pfad seine eigene Zusage führt, behält seinen Träger, und
der Lauf **sagt**, daß er ihn stehenläßt. Die Aufzählung, die ihn heute mit den zwei Nachbar-Dateien
in einer Klasse führt, und die Sätze, die am Pfad die Urheberschaft des Werkzeugs behaupten, sind
auf das gezogen, was gilt.

**Der Gegenstand ist entschieden, nicht gesucht.** Die Klasse, ihre Alternativen und ihre Messung
stehen in [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) §Kontext und
§Verglichene Alternativen — je Zahl mit dem Kommando, das sie liefert. Dieser Plan wiederholt sie
nicht (§3.7: die Abwägung steht in der ADR) und fügt **keine** zweite Fassung derselben Tabelle
hinzu.

**Die zwei Fassungen der Klasse fallen heute auseinander, und beide sind wahr:** die Lieferung
schreibt unbedingt, die ADR entscheidet skip-if-present. Der Vorgang ist damit **terminiert**, nicht
stillgelegt — er zieht die eine Hälfte auf die andere, sobald die ADR bindet (Start-Trigger §4).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die zwei Nachbar-Dateien des Trägers** — die Prüfung `tools/harness/commit-msg-traceability.sh`
  und die Aktivierung `harness/mk/hooks-install.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->. Ihre Klassen sind in
  [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1
  **bestätigt**, nicht geändert; ein Vorgang daneben wäre eine zweite Fassung derselben Tabelle.
- **Die `.claude/`-Zeilen der Tabelle in [ADR-0007](../../adr/0007-bootstrap-phasen.md).** Festlegung
  4 der ADR nimmt sie ausdrücklich aus: dieselbe Frage ist dort nicht gemessen, und aus einer
  Messung an einer Stelle folgt nichts über eine Eigenschaft
  ([`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
- **Die Erkennungs-Seite der Kennung.** Welche Formen die Werkzeuge dieses Repos erkennen, ist ein
  eigener Gegenstand und liegt nach
  [`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
  Setzung 2 in dem Vorgang, der die Fundliste führt — dieser Slice zieht keine Erkennung.
- **Die Feststellungs-Zeile im emittierten `close-welle.md`.** Sie ist der ehrliche Ausgang für ein
  Ziel ohne ein Werkzeug und bleibt wörtlich stehen; dieser Slice zieht eine **Klasse**, nicht eine
  Antwort des Regelwerks.
- **Der Laufzeitpfad des Werkzeugs.** Diese Eröffnung schneidet an der emittierten Ebene: ihr
  Gegenstand sind `internal/emit/` samt den Vorlagen, die es ablegt. Die CLI (`cmd/`), der Generator
  (`internal/gen`) und die Verdrahtung (`internal/wire`) werden von ihr nicht angefasst — dieselbe
  Grenze, die das Vorgänger-Mitglied gezogen hat.
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

- [x] **Ein Pfad, eine Klasse — und die Klasse steht an einer Stelle.** Die Aufzählung, die den
      Träger führt, und **jeder** Nachbar, der über „jede emittierte Datei wird konvergent
      geschrieben" fährt, trennen `.githooks/commit-msg` von den zwei übrigen Träger-Dateien; keine
      zweite Fassung der Klassifikation entsteht daneben. Der Beleg ist `make test`, nicht eine
      Zeile Prosa ([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)
      §Fitness Function).
- [x] **Skip-if-present heißt dreierlei, und jede Richtung ist gelesen:** der Pfad ist **frei** →
      der Träger wird geschrieben; der Pfad ist **belegt** → die liegende Datei bleibt unberührt
      **und der Lauf sagt es**, mit dem Hinweis auf die mitgelieferte Prüfung; die **Prüfung**
      selbst bleibt konvergent. Der Beleg ist die gefahrene Ausgabe im gebootstrappten Ziel
      (leeres Ziel und belegter Pfad), nicht die Zeile, die die Meldung baut.
- [x] **Die Sätze am Pfad sind gezogen.** Der Kopf und die Fehlermeldung des Aktivierungs-Fragments,
      der Commit-Absatz des emittierten Anweisungssatzes und die Prosa in
      [`harness/README.md`](../../../../harness/README.md) behaupten an keiner Stelle mehr, der
      Träger sei der des Werkzeugs oder werde kanonisch neu geschrieben — jeder beschreibt, was an
      diesem Pfad gilt ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die Prosa, die den Träger führt, nennt seine **Klasse** und den Ausgang für den
      belegten Pfad, soweit dieser Slice diese Prosa wachsen lässt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Dieses Repo fährt Wellen-Betrieb:** der Kasten bleibt darum offen — sein Träger ist die nächste Welle-Closure (Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 3c, der auch Slices ohne Wellen-Zugehörigkeit liest), nicht dieser Lauf. Was er prüft, liegt vor: der Zielort der Register-Zeile, die Plandatei des Folge-Slice und der Beleg unter `evidence/`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/enforce.go` | update | dort liegt die Aufzählung `enforceFiles()` und der Schreib-Pfad: der Träger wird bei belegtem Pfad nicht geschrieben, die zwei Nachbar-Dateien bleiben konvergent |
| `internal/emit/commitmsg.go` | update | dort steht die Klasse des Trägers (`UNBEDINGT wie die uebrigen Fragmente`) und die Begründung der drei Einträge — sie trägt künftig beide Klassen |
| `internal/emit/templates/enforce/hooks-install.mk` | update | Kopf und Fehlermeldung des Aktivierungs-Fragments behaupten am Pfad die Urheberschaft des Werkzeugs |
| `internal/emit/templates/commands/implement-slice.md` | update | der Commit-Absatz des emittierten Anweisungssatzes sagt `.githooks/commit-msg` dem Ziel zu, ohne dessen Zustand zu nennen |
| [`harness/README.md`](../../../../harness/README.md) | update | die Prosa, die den Träger des Ziels führt — Klasse und Ausgang des belegten Pfades (DoD-Punkt „Doku-Update") |
| `internal/emit/enforce_test.go` | update | der Ganz-Mengen-Test ist die Stelle, an der die zwei Klassen aufeinandertreffen: er fällt mit dem Vorgang aus oder wird auf beide Klassen gezogen (DoD 1) mit beiden Richtungen |
| `test/…` + `test/mutations/*` | neu | der belegte Pfad (DoD 2, Meldung gelesen) und je Fall ein gelisteter Zahn, der ihn rot färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | der Beleg aus DoD 2: der E2E fährt beide Richtungen im gebootstrappten Ziel — leeres Ziel (Träger liegt) und belegter Pfad (bleibt und wird gemeldet) |

**Der Unterschied ist der des Gegenstands, nicht des Inhalts.** Der Träger ist ein **Delegator** an
einem Namen, den `git` fixiert, in einem Verzeichnis des Adopters; die zwei Nachbar-Dateien liegen
an Pfaden, die die Emission bestimmt. Deshalb **eine** Datei wechselt die Klasse
([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 2) — und
deshalb ist der teure Teil dieses Slice nicht das Schreiben, sondern **das Finden der Sätze, die
die alte Klasse behaupten**: sie stehen in `enforce_test.go`, im Fragment-Kopf, in dessen
Fehlermeldung, im Command-Absatz und in der README.

**Die Meldung ist Ausgabe, kein Sensor.** Sie zu bauen ist Liefergegenstand; sie zu **bewachen**
ist es nicht — kein Modul des Doku-Gates liest sie und `make mutate` kennt keine Fehlschlag-Form
dafür. Was DoD 2 belegt, ist die **gelesene** Ausgabe, nicht ein Eintrag in einer Gate-Liste
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **[`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)
ist `Accepted`** — beobachtbar ohne Rückfrage:

```sh
grep -n '^\*\*Status:\*\*' docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md
```

Dazu die zwei gewöhnlichen Bedingungen: der Slice ist priorisiert (`Verantwortlich:` gesetzt) und
das WIP-Limit frei. **Warum die Bedingung nicht ordnend ist:** Ihr Gegenstand ist die Klasse eines
Pfades, und die Klasse bindet erst mit dem Accept-Übergang — sie zu vollziehen, bevor er sie trägt,
schriebe eine Setzung in den Code, die niemand ausgesprochen hat
([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)).

**Reihenfolge:** unabhängig von jedem anderen offenen Slice; die Fläche — `internal/emit/` und die
vier Sätze neben dem Pfad — fasst kein laufender Vorgang an. **Der eine Vorgang, der sie
mit-fasst, ist serialisiert:**
[`slice-aktivierung-reist-nicht-mit-dem-klon`](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md)
berührt `harness/tools/full-smoke.sh` (dort die neue Stufe) und nimmt dem Fragment
`internal/emit/templates/enforce/hooks-install.mk` die `test -f`-Zeile — beide stehen auch in §3
dieses Plans. Er liegt in `open/` **hinter** [welle-11](../welle-11-traeger-aussage.md) und damit
nach diesem Slice; die Anordnung trägt die Serialisierung, nicht die Ungleichzeitigkeit der
Flächen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Klassen-Trennung, die Meldung
  samt beiden Richtungen **und** die vier Sätze am Pfad zusammen nicht in einer Review-Sitzung
  prüfbar sind — dann ist an der Satz-Hälfte zu schneiden.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, daß die Klasse nicht ohne
  Eingriff in den **Abbruch-Vertrag** des Emits zu haben ist (die Phasen-Ordnung, die `Enforce`
  heute fährt) — dann gehört erst diese Entscheidung, und sie gehört dem Architect.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; beide Richtungen des belegten Pfades mit **gelesener** Ausgabe belegt (DoD 2);
`make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Klasse bindet nicht, wenn die ADR nicht `Accepted` wird** (oder mit geändertem Inhalt).
  Der Start-Trigger hängt daran; wird die ADR unterwegs zurückgezogen oder umgeschrieben, vollzieht
  der Slice eine Setzung, die es so nicht mehr gibt, und die zwei Fassungen fallen wieder
  auseinander. — **Ausgang: entfallen.** Die Bedingung ist eingetreten statt ausgefallen:
  [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) ist `Accepted`
  (`0ec7e7b9`), ihre Festlegungen 1 bis 4 stehen unverändert, und der Teil-`Supersedes` der
  [`ADR-0055`](../../adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
  nimmt **eine** Deckungs-Begründung ihrer §Fitness Function, keine Festlegung; die Klasse bindet
  damit so, wie dieser Slice sie vollzogen hat.
- **Der Träger wird nach dem ersten Schreiben nicht mehr geheilt.** Das ist die benannte negative
  Konsequenz der gewählten Klasse
  ([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) §Konsequenzen): eine
  spätere Änderung an seinem Inhalt erreicht ein Ziel nicht mehr. Gebrochen wird laut (der `exec`
  auf einen verschobenen Prüfpfad endet im Commit-Pfad mit Exit ≠ 0), geheilt nicht. — **Ausgang:
  entfallen.** Sie ist die benannte negative Konsequenz der getroffenen Entscheidung und kein offener
  Posten: [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 3,
  dritter Spiegelstrich, führt sie im Wortlaut (*„sein Veralten bricht laut …, es heilt nicht von
  selbst"*). Ein Risiko, das die Entscheidung selbst ist, fällt aus der Liste statt in den Zähler;
  der laute Bruch ist dort ein Satz der Entscheidung — ein Sensor trägt ihn nicht.
- **Die zwei Klassen treffen sich im Ganz-Mengen-Test, und dort ist ein stilles Grün möglich.** Der
  Test hält heute für **jeden** Pfad der Aufzählung die konvergente Klasse fest; wer ihn auf die
  zwei Klassen zieht, kann die Modi- und Inhalts-Hälfte für den Träger verlieren, ohne daß ein
  Zeichen rot wird. — **Ausgang: entfallen.** Der Test ist mit dem Vorgang auf beide Klassen gezogen
  (`TestEnforce_IdempotenzKlasseJePfad`): je Pfad fährt er die Richtung **seiner** Klasse, seine
  Vorbedingung *beide Klassen besetzt* fällt, wenn eine leer läuft, und die Modus-/Inhalts-Hälfte des
  Trägers liegt nicht bei ihm, sondern in `TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet`
  (Teil 1 und 3) und in `TestEnforce_ScriptsExecutable` — beide im Review gelesen und **nicht** als
  verloren befunden. Was bleibt, ist enger als dieses Risiko und steht als **V-1** benannt: eine
  **zweite** Klassen-Liste daneben sieht der Test nicht, weil er seine Erwartung aus derselben
  Aufzählung ableitet, die der Writer liest.
- **Die Fitness-Zeile in [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) §Fitness Function nennt
  einen Träger, der die Klasse nur entartet hält, und sie steht dort unbeschränkt.** *„ein Test
  koppelt jede emittierte Datei an ihre Klasse (konvergent vs. skip-if-present); eine Fehl-Klasse
  färbt rot"* — den vollständigen Ist-Bestand hält der Vorlagen-Emitter, der Enforce-Emitter
  verlangt für **jeden** Pfad seiner Aufzählung die konvergente Klasse; für einen korrekt
  skip-if-present geführten Pfad ist das ein Rot, kein erkennbarer Zustand
  ([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) §Fitness Function:
  *benannt, nicht bewacht*). Fällt der Ganz-Mengen-Test mit diesem Vorgang aus, nennt die Zeile einen
  Sensor, den es nicht mehr gibt; wird er auf beide Klassen gezogen, trägt sie ihn. Der erste Fall braucht
  beides: eine Folge-ADR mit **Teil-`Supersedes`** auf die Zeile und einen Implementer-Vorgang —
  benannt als `slice-klassifikations-zeile-nennt-ihren-traeger`, der mit der Anlage seiner Datei
  auflöst. — **Ausgang: entfallen.** Die zweite Verzweigung ist eingetreten: der Ganz-Mengen-Test
  **fiel** nicht, er ist umbenannt und auf beide Klassen gezogen, und die Fitness-Zeile hält damit
  einen Sensor, der läuft — Klasse und Richtung je gelistetem Pfad, und ein Pfad **ohne** Klasse
  färbt rot (`test/mutations/361-traeger-ohne-klasse.sh`). Die erste Verzweigung ist nicht
  eingetreten; der dort genannte Vorgang `slice-klassifikations-zeile-nennt-ihren-traeger` hat damit
  **kein Objekt und keine Datei** — er wird nicht angelegt und ist kein Folge-Slice dieses Vorgangs.
  Die **Mengen**-Richtung (kein geschriebener Pfad ohne Listeneintrag) hat mit diesem Vorgang eine
  **neue**, gemessene Grenze bekommen; sie ist in
  [`ADR-0055`](../../adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
  benannt und dort als eigener Re-Evaluierungs-Trigger geführt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Der Schnitt hat getragen. Der teure Teil war der **Fund** der Sätze, nicht
  ihr Schreiben — fünf der sechs Stellen, die die alte Klasse behaupteten, kamen aus dem Sweep über
  die zwei Formen. DoD 2 ist im **gebootstrappten Ziel** an der **gelesenen** Ausgabe belegt, nicht an
  der Zeile, die die Meldung baut; der Verifikations-Lauf hat das in eigener Messung nachgefahren
  (leeres Ziel · belegter Pfad · driftende Prüfung). Und der Rollenwechsel hat genau das geleistet,
  wofür er existiert: der HIGH dieses Vorgangs — vier entwaffnete Mutations-Fälle — ist für **kein**
  Gate des Push-Pfads sichtbar, gefunden hat ihn der Review.
- **Was ging anders als geplant:** fünf Dinge, und keine davon war im Plan.
  (1) Die Lieferung kam in **zwei divergenten Läufen mit demselben Betreff** (`2f82b466`,
  `d7fd8227`); der zweite zieht zwei Dateien des ersten nach.
  (2) **F-1 (HIGH):** der Umbau entwaffnete vier gelistete Mutations-Fälle — zwei griffen nicht mehr,
  zwei fielen aus einem fremden Grund; nachgezogen in `65b78423`, jeder mit seinem `# expect:`.
  (3) Die Umbenennung des Ganz-Mengen-Tests ließ eine **abgeschaffte Kennung** in der `Accepted`
  [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) stehen → die
  [`ADR-0055`](../../adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
  (Teil-`Supersedes`). Genau diese Klasse hatte §6/**Risiko 4** nur für die **namensfreie** Zeile der
  [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) formuliert.
  (4) **F-3:** der Zahl-Beleg der Commit-Message trifft die Fundmenge nicht (s. u.).
  (5) **Sechs gebaute Stellen stehen nicht in §3** — fünf Emitter-Einträge als Folge des
  fail-closed-Writers, die Go-Test-Hälfte des Belegs, ein Namens-Nachzug, vier Anker aus Review-F-1;
  **keine** nimmt einen §1-Ausschluss mit, und keine ist ein Zuviel.
  Dazu ein **Ertrag, den kein DoD-Punkt trägt:** dieser Slice hat **drei** ADRs ausgelöst —
  [`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md),
  [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md),
  [`ADR-0055`](../../adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
  —, alle heute `Accepted`.
- **F-3 — der eingefrorene Zahl-Beleg, als benannte Grenze:** die Message von `d7fd8227` sagt *„Dazu
  vier Stellen, die der Plan nicht nannte"*. Die Fundmenge ist **fünf**: `Enforce`-Doc,
  `writeFileMode`-Doc, `captureFiles`-Doc, `EnforcePaths`-Doc, `hooksInstallMkFile`-Doc; eine sechste
  ist nur in der Lesart **ohne** die §3-Tabelle unbenannt, eine siebte trägt keine Klassen-Aussage.
  Die Rückgabe desselben Laufs nannte **sieben**:

  ```sh
  git diff -U0 77b927c7 d7fd8227 | grep -E '^-[^-]' | grep -icE 'konvergent|kanonisch|unbedingt'   # 22 Zeilen
  ```

  Die 22 sind **Zeilen**, nicht Stellen — die fünf sind an ihnen gelesen. Die Message ist gepusht und
  unveränderlich; **kein Gate liest eine Commit-Message**
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 1). Die „vier" bleibt darum stehen, wo sie steht; die Closure-Notiz ist die Stelle, die die
  Fundmenge daneben trägt — eine Reparatur gibt es nicht.
- **Steering-Loop-Eintrag:** **geplant, nicht verkörpert** — der Lese-Schritt hat den Eintrag
  [`BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md)
  mit diesem Vorgang bei **3×** gelesen und ihm seinen Ausgang gegeben: `geplant`, Träger
  [`slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form`](../open/slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form.md)
  — die **Form** für die Präsens-Aussage über ein lebendes Artefakt in einem einfrierenden Text. Der
  Norm-Text entsteht nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 in der **Architect**-Rolle; die
  Teil-Zeile `— liegt in …` entfällt, weil mit diesem Slice nichts verkörpert wurde.
  Auslöser: `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (slice-145,
  slice-offene-wellen-liste-hat-einen-waechter, dieser Vorgang — 3×).

  **Warum der Ausgang hier steht und nicht erst in der nächsten Welle-Closure:** der Eintrag ist mit
  diesem Vorgang **neu** über die Schwelle getreten, und ein `geplant`-Ausgang ohne auflösende
  Kennung wäre ein Vorsatz — die Plandatei musste darum mit ihm entstehen. `offen` wäre nach
  [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 3 zwischen zwei
  Lese-Schritten zulässig gewesen; keiner der zwei offenen Wellen trägt den Eintrag (weder
  [welle-09](../welle-09-modul-15-konformitaet.md) noch
  [welle-11](../welle-11-traeger-aussage.md) nennt ihn). Die nächste Welle-Closure liest ihn als
  Eintrag über der Schwelle ohnehin wieder und bestätigt oder verschiebt den Ausgang.
- **Beobachtungs-Register (`../observations/`):** **fünf** Belege in bestehende Einträge gelegt und
  **ein** Verzeichnis neu angelegt; die Stände sind gemessen, nicht abgelesen
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2):

  ```sh
  for s in mutations-fall-wird-von-berechtigter-aenderung-entwaffnet \
           praesens-aussage-in-einzufrierendem-artefakt-ohne-form \
           extensionale-zahl-unterschreitet-die-eigene-fundmenge \
           zusage-neben-geaenderter-ableitung-bleibt-stehen \
           kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle \
           rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet; do
    printf '%-64s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
  done
  # mutations-fall-wird-von-berechtigter-aenderung-entwaffnet          4
  # praesens-aussage-in-einzufrierendem-artefakt-ohne-form             3   (= Schwelle)
  # extensionale-zahl-unterschreitet-die-eigene-fundmenge              2
  # zusage-neben-geaenderter-ableitung-bleibt-stehen                  26
  # kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle    11
  # rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet  1
  ```

  Der **eine neue** Eintrag ist `rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet`
  — die einzige Finding-Klasse des Reviews ohne vorhandene Kennung; sie zu erfinden, wo eine
  existiert, wäre der Verstoß, den die Register-Regel **zitieren statt neu formulieren** verbietet.
  Sein `state.md` steht auf `offen` (1×, unter der Schwelle). **Kein Zähler wurde gesetzt.**
- **Folge-Slices:** [`slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form`](../open/slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form.md)
  — ist eine Datei in `open/`; er ist der Träger des `geplant`-Ausgangs oben. Sonst keiner: der in
  §6/**Risiko 4** für die erste Verzweigung genannte Vorgang ist **nicht** eingetreten und wird nicht
  angelegt.
- **Risiken aus §6:** **vier**, jeder mit genau einem Ausgang — alle vier `entfallen`; die Gründe
  stehen je am Risiko in §6. Keines wandert ins Register, keines bleibt offen.
- **Drei Paarungen:** dieses **Repo** fährt Wellen — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas: `*` (gesamtes Repo) für
`internal/emit/**` und [`harness/README.md`](../../../../harness/README.md) — die **emittierte**
Ebene ist keine Sub-Area dieses Repos, sie ist ein anderer Vertrag — und `harness/tools/`
(Kürzel `TOOLS`) für den E2E-Beleg, dessen Pfad dort liegt. Beide stehen in der Modus-Deklaration
von [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area);
`*` ist der Bereich, dessen Sätze dieser Slice zieht, `TOOLS` die Pfad-Familie des Belegs.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; die Stände sind
gemessen, nicht abgelesen
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2):

```sh
for s in neuer-waechter-ohne-mutations-fall zusage-neben-geaenderter-ableitung-bleibt-stehen \
         lebendes-register-traegt-eine-ueberholte-fundliste; do
  printf '%-52s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
done
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Drei berühren diesen
Slice; **keine** erreicht mit ihm erstmals 3×:

- **`neuer-waechter-ohne-mutations-fall` (7×, `verkörpert`)** — die zwei Richtungen des belegten
  Pfades sind neue Wächter; DoD 2 bindet ihre Belege, und der Mutations-Fall ist die Hälfte, die
  `make gates` nicht fährt. Der E2E-Beleg ist die Stelle, an der ein Zahn ohne gelisteten Fall
  stehenbleiben kann.
- **`zusage-neben-geaenderter-ableitung-bleibt-stehen` (25×, `geplant`)** — die Klasse, die diesen
  Vorgang umgibt: eine Zusage bleibt neben der geänderten Ableitung stehen. Hier in **beiden**
  Richtungen zu lesen — die Sätze am **emittierten** Pfad und die Prosa der Dogfood-README, die von
  derselben Klasse handelt.
- **`lebendes-register-traegt-eine-ueberholte-fundliste` (1×, `offen`)** — berührt als Warnung, nicht
  als Gegenstand: jeder Satz, den dieser Slice zieht, ist eine Bestands-Aussage in einem lebenden
  Artefakt; ihn stehen zu lassen, während die Klasse wandert, ist genau der Fall, den der Eintrag
  beschreibt.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` und `TOOLS` stehen in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation
`n/a`.

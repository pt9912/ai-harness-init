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
[`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) (**Proposed** — ihre
Festlegung 1 entscheidet die Klasse des Träger-Pfades, ihre Folgepflicht 1 übergibt genau diesen
Vorgang an den Planner; sie bindet nach [ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
erst mit ihrem Accept-Übergang, und der Start-Trigger unten hängt daran),
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

**Verantwortlich:** `—` — bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine: der Übergang `open→next` setzt sie).

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

- [ ] **Ein Pfad, eine Klasse — und die Klasse steht an einer Stelle.** Die Aufzählung, die den
      Träger führt, und **jeder** Nachbar, der über „jede emittierte Datei wird konvergent
      geschrieben" fährt, trennen `.githooks/commit-msg` von den zwei übrigen Träger-Dateien; keine
      zweite Fassung der Klassifikation entsteht daneben. Der Beleg ist `make test`, nicht eine
      Zeile Prosa ([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)
      §Fitness Function).
- [ ] **Skip-if-present heißt dreierlei, und jede Richtung ist gelesen:** der Pfad ist **frei** →
      der Träger wird geschrieben; der Pfad ist **belegt** → die liegende Datei bleibt unberührt
      **und der Lauf sagt es**, mit dem Hinweis auf die mitgelieferte Prüfung; die **Prüfung**
      selbst bleibt konvergent. Der Beleg ist die gefahrene Ausgabe im gebootstrappten Ziel
      (leeres Ziel und belegter Pfad), nicht die Zeile, die die Meldung baut.
- [ ] **Die Sätze am Pfad sind gezogen.** Der Kopf und die Fehlermeldung des Aktivierungs-Fragments,
      der Commit-Absatz des emittierten Anweisungssatzes und die Prosa in
      [`harness/README.md`](../../../../harness/README.md) behaupten an keiner Stelle mehr, der
      Träger sei der des Werkzeugs oder werde kanonisch neu geschrieben — jeder beschreibt, was an
      diesem Pfad gilt ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Prosa, die den Träger führt, nennt seine **Klasse** und den Ausgang für den
      belegten Pfad, soweit dieser Slice diese Prosa wachsen lässt.
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
Pfades, und die Klasse ist heute entschieden, aber nicht bindend — sie zu vollziehen, bevor der
Accept-Übergang sie trägt, schriebe eine Setzung in den Code, die niemand ausgesprochen hat
([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)).

**Reihenfolge:** unabhängig von jedem anderen offenen Slice; die Fläche — `internal/emit/` und die
zwei Sätze neben dem Pfad — fasst kein laufender Vorgang an.

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
  auseinander. — **Ausgang:** <…>
- **Der Träger wird nach dem ersten Schreiben nicht mehr geheilt.** Das ist die benannte negative
  Konsequenz der gewählten Klasse
  ([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) §Konsequenzen): eine
  spätere Änderung an seinem Inhalt erreicht ein Ziel nicht mehr. Gebrochen wird laut (der `exec`
  auf einen verschobenen Prüfpfad endet im Commit-Pfad mit Exit ≠ 0), geheilt nicht. — **Ausgang:** <…>
- **Die zwei Klassen treffen sich im Ganz-Mengen-Test, und dort ist ein stilles Grün möglich.** Der
  Test hält heute für **jeden** Pfad der Aufzählung die konvergente Klasse fest; wer ihn auf die
  zwei Klassen zieht, kann die Modi- und Inhalts-Hälfte für den Träger verlieren, ohne daß ein
  Zeichen rot wird. — **Ausgang:** <…>

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

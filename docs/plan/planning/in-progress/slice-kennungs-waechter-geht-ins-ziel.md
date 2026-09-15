# Slice slice-kennungs-waechter-geht-ins-ziel: Der Traceability-Constraint bekommt im Ziel einen Träger

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md). Die Welle trägt das
*Mehr* über dieser DoD: ihr Closure-Trigger fährt die neu emittierten Werkzeuge im gebootstrappten
Ziel einmal durch (`make full-smoke`) — einen Beleg, den kein Punkt dieser DoD führt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
emittierte Durchsetzungsschicht — Command-Guard und `settings.json`),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (der
Anweisungssatz trägt die Konvention, auf der ein Vor-Commit-Sensor hängt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter, dessen Reichweite nicht neben seiner Zusage steht, behauptet mehr als er misst),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (kein neuer
Host-Bedarf),
[ADR-0004](../../adr/0004-durchsetzungs-emission.md) (der Stolperdraht-Charakter eines Guards),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wer den
Anweisungssatz schreiben darf).

**Berührte Spec-Stellen:** `—`. Der Slice ändert die Emissions-Vorlage; kein Zielelement der
Spec-Straten wird angefasst.

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

**Ziel:** Der **Traceability-Constraint**, den das mitgelieferte Regelwerk dem Ziel vorschreibt, hat
dort einen Träger — oder das Ziel sagt an derselben Stelle, welchen Teil es nicht trägt.

### Der Anlass ist am Baum gemessen

Das Regelwerk verlangt, dass keine relevante Änderung ohne Bezug zu einer Kennung stattfindet; sein
Träger ist ein Commit-Wächter. Dieses Repo führt ihn — das Ziel nicht:

```sh
ls .claude/hooks/ | wc -l                                      # 4 — die drei emittierten plus der lokale
git grep -c 'commit-msg' -- internal/ | wc -l                  # 0 — das Ziel kennt ihn nicht
grep -c '\.sh", "\.claude/hooks/' internal/emit/enforce.go      # 3 — so viele Hooks gehen hinaus
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei wandern mit dem Baum. Der lokale Träger hat drei Hälften: den
PreToolUse-Hook (`.claude/hooks/pretooluse-commit-msg-guard.sh`), das Kommando
`make commit-msg-check`, das dieselbe Prüfung ohne Agenten fährt, und den git-eigenen Hook
`.githooks/commit-msg`, den
[slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) für den
Dogfood entschieden hat. Die ersten zwei erreichen das Ziel nicht; die dritte ist die Form, die es
bekommt. Auch die Modul-Liste der emittierten Gate-Konfiguration führt den Constraint nicht: sie
liest `modules: [links, anchors, ids, matrix, spans]`.

**Der Träger ist die Entscheidung, nicht ein Artefakt.** Ein Wächter kann am **Agenten** hängen (wie
hier) oder am **Commit**; die zwei erreichen verschiedene Mengen. Eine Commit-Message ohne Kennung
ist die eine Hälfte des Constraints — die andere, ein Doku-Update bei berührtem öffentlichem
Vertrag, ist von keinem der zwei Kanäle erreichbar. Was das Ziel nicht trägt, steht darum **neben**
dem, was es trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Träger-Wahl des Dogfoods für sich.** [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md)
  hat entschieden, wo der Wächter **dieses** Repos hängt, wenn der Aufruf nicht als Kommando
  erscheint; die emittierte Fassung erbt diese Entscheidung, statt sie vorwegzunehmen (§5 der
  Welle).
- **Der `commits`-Modulblock als solcher.** Sein Zustand am gepinnten Stand ist ein Befund des
  Nachbar-Werkzeugs und steht im Register
  ([`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md));
  dieser Slice entscheidet den **Träger**, nicht das Modul.
- **Die zweite Hälfte des Constraints — das Doku-Update.** Sie ist von einem Commit-Gate nicht
  mechanisch prüfbar; sie wird **benannt**, nicht gebaut. Sie zu bauen wäre ein anderer Vorgang.
- **Der Produkt-Code außerhalb der Emission.** Diese Eröffnung schneidet an der **emittierten**
  Ebene: ihr Gegenstand ist `internal/emit/` samt den Vorlagen, die es ablegt. Der
  **Laufzeitpfad** des Werkzeugs — die CLI (`cmd/`), der Generator (`internal/gen`), die
  Verdrahtung (`internal/wire`) — wird von ihr nicht angefasst.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Was hier steht, ist die Grenze, an der ein wachsender Slice sich
messen lässt: Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den
Plan **geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Das Ziel hat einen Träger an einer benannten Stelle, und der Anweisungssatz trägt die
      Konvention mit, an der er hängt** — oder die Lücke ist an derselben Stelle als Satz benannt.
      Der Beleg ist `make full-smoke` über einem gebootstrappten Ziel, nicht eine Zeile im Emit-Code.
- [x] **Der Fall ist rot gesehen:** eine Commit-Message **ohne** Kennung fällt im Ziel, eine **mit**
      Kennung nicht; Ausgabe und Exit-Code gelesen. Ist der Träger nicht gebaut, ist der Rot-Beleg
      die gelesene Ausgabe des benannten Satzes.
- [x] **Reichweite und Abhängigkeit stehen neben der Zusage:** benannt ist beides — was der Träger
      **nicht** erreicht (die zweite Hälfte des Constraints: ein Doku-Update bei berührtem
      öffentlichem Vertrag) und was er **erreicht und abbricht** (die Commits der Repo-Werkzeuge:
      er hängt am Commit und sieht jede Klasse, die `git` erzeugt — ihre Messages tragen mit einer
      benannten Kennung aber keine aus der Menge und fallen darum an ihm); der Träger braucht
      nichts über `bash + git` bzw. das gepinnte Gate-Bild hinaus
      ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die Prosa, die den Träger führt, nennt die Fassung, die im Ziel liegt — ihren Ort
      und ihre Verdrahtung —, soweit dieser Slice diese Prosa wachsen lässt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/` (Hook, Prüfung, Aktivierungs-Fragment) + `internal/emit/commitmsg.go` + `internal/emit/enforce.go` | neu/update | die drei Vorlagen des Trägers, ihre Ziel-Zuordnung und ihr Eintrag in `enforceFiles()` — **nicht** in die emittierte `settings.json`: ein git-eigener Hook hat dort keinen Eintrag |
| `internal/emit/templates/commands/` | update | der Anweisungssatz nennt den Träger, den Schritt, der ihn aktiviert, und seine Grenzen — die Konvention „Commit via Message-Datei" trägt ihn nicht: er liest die Datei, die `git` ihm übergibt |
| `harness/tools/full-smoke.sh` | update | der Beleg aus DoD (1)/(2): die E2E-Sektion `kennungs_traeger_im_ziel` fährt die Kette im gebootstrappten Ziel |
| `harness/README.md` | update | die Prosa, die den Träger des Ziels führt — Ort, Verdrahtung, Grenzen (DoD-Punkt „Doku-Update") |
| `test/…` + `internal/emit/*_test.go` | neu/update | Happy/Negative nach DoD (2), die Reichweiten-Zeile aus DoD (3) und die Konvergenz-Menge der emittierten Durchsetzungs-Dateien |

**Der Träger wird nicht neu erfunden.** Dieses Repo führt seine drei Hälften — den PreToolUse-Hook,
das Kommando, das dieselbe Prüfung ohne Agenten fährt, und den git-eigenen Hook, den
[slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) für den
**Dogfood** entschieden hat. Die Emission übernimmt dessen Form: der git-eigene Hook ist der Träger
im Ziel, der PreToolUse-Kanal bleibt hier. **Seine Grenze wandert mit:** `core.hooksPath` ist lokale
Konfiguration, die kein Bootstrap setzt; der emittierte Wächter ist damit **optional**, und was er
nicht erreicht, sagt die Reichweiten-Zeile aus DoD (3) — ohne sie ist der Slice nicht fertig.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`Verantwortlich:` gesetzt) und das
WIP-Limit frei. **Der Träger des Dogfoods ist entschieden**
([slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md)); dieser
Slice erbt die Form (§3) — die Richtung „erst die ausgeführte Fassung, dann die emittierte" (Welle
§5) ist eine Ordnung, keine Sperre.

**Reihenfolge innerhalb der Welle:** unabhängig von den drei übrigen Mitgliedern; die Flächen sind
disjunkt — dieses Mitglied fasst die Hook-Vorlagen an, kein anderes tut das.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Träger-Entscheidung und die
  Angleichung der **drei** emittierten Command-Vorlagen zusammen nicht in einer Review-Sitzung
  prüfbar sind — dann ist an der Kanal-Hälfte zu schneiden.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, dass kein Kanal den
  Constraint im Ziel tragen kann, ohne den Durchsetzungsvertrag der emittierten
  `settings.json` zu ändern — dann gehört erst diese Entscheidung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über einem gebootstrappten Ziel; der Rot-Fall aus DoD (2) im
Closure-Eintrag zitiert; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der emittierte Wächter erbt eine Entscheidung, die noch nicht gefallen ist.**
  [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) bewegt den Träger des
  Dogfoods; eine emittierte Form, die davor geschrieben wird, ist mit seinem Ergebnis zu
  vergleichen und gegebenenfalls nachzuziehen. — **Ausgang: eingetreten —
  `slice-commit-traeger-wird-skip-if-present`** (eine Datei in `open/`, in diesem Closure-Lauf
  angelegt). Der Vergleich ist gefahren: die Form des Ziels ist die, die
  [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) entschieden
  hat, und das **Nachziehen** betrifft nicht den Kanal, sondern die **Klasse** des Pfades — sie ist
  in [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1
  entschieden und ihrer Folgepflicht 1 übergeben. Kein Carveout: kein Gate steht rot.
- **Der Träger des Ziels hängt am Commit, nicht am Agenten-Kanal — seine Reichweite fällt darum
  anders aus als die des Dogfoods: er erreicht die Commits der Repo-Werkzeuge und bricht sie ab,
  solange deren Messages keine Kennung aus der Menge tragen.** `make slice-mv` und
  `make archive-welle` committen intern mit dem Slice- bzw. Welle-Namen, und eine benannte Kennung
  trifft kein Muster der Menge. Die DoD (3) verlangt, die Reichweite **neben** die Zusage zu
  schreiben. — **Ausgang: entfallen.** Die Reichweite steht an der Stelle der Zusage — im
  Aktivierungs-Fragment als eigener Block („WAS ER MITNIMMT"), in der
  [`harness/README.md`](../../../../harness/README.md)-Prosa und als Prüfung im E2E; der Abbruch
  der Werkzeug-Commits ist damit benannt und nicht mehr die stille Nebenfolge, die das Risiko
  beschreibt. Für die Reparatur auf der **Dogfood**-Seite trägt die README-Tabelle bereits ihre
  Adresse ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 4); sie ist **nicht** Gegenstand dieses Slice.
- **Die Konvention, an der der Wächter hängt, wird nicht von allen Anweisungssätzen getragen.** Der
  Hook greift nur bei einer Message-**Datei**; ein Anweisungssatz, der den Commit anders beschreibt,
  fällt durch. — **Ausgang: entfallen.** Für den Träger **dieses** Slice gilt der Satz nicht: er
  hängt am Commit und liest die Message-Datei, die `git` ihm übergibt, gleichgültig welcher Aufruf
  sie erzeugt hat ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 2; im Ziel ohne jeden Anweisungssatz feuern gesehen). Die Form-Abhängigkeit bleibt die
  des **Agenten-Kanals dieses Klons** — sie ist Gegenstand des Registers
  ([`BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md),
  offen) und **kein** Ausgang dieses Risikos; dieser Vorgang bewegt ihren Zähler nicht, weil sein
  Gegenstand die emittierte Ebene ist (§8).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die Träger-Entscheidung lag vor, und die Emission hat sie geerbt
  statt sie zu wiederholen.** Der Träger des Ziels ist der git-eigene Hook — die Form hat
  [slice-215](../done/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) für den
  Dogfood entschieden, und dieser Slice hat sie übernommen; ein zweiter Kanal daneben wäre eine
  zweite Fassung derselben Zusage geworden. **Getragen hat zweitens der E2E:** die Sektion
  `kennungs_traeger_im_ziel` fährt die Kette im gebootstrappten Ziel — ein Commit **ohne** Kennung
  fällt mit der Meldung der Prüfung und entsteht nicht, einer **mit** Kennung geht durch,
  `--no-verify` umgeht den Träger. Damit ist
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) an dieser Stelle
  eingelöst statt behauptet. **Drittens hat die Reichweiten-Zusage ihre zweite Richtung bekommen**
  — der Träger nimmt die Commits der Repo-Werkzeuge mit und bricht sie ab; ohne diese Hälfte läse
  er sich als Zaun für Agenten-Commits.
- **Was ging anders als geplant:** **Vier Dinge.** (1) Der **Anlass-Block in §1 ist mit dem Vollzug
  im Präsens falsch geworden**: er nennt *„das Ziel kennt ihn nicht"* und belegt das mit
  `git grep -c 'commit-msg' -- internal/ | wc -l` → `0` — nach der Lieferung ist die Zahl nicht mehr
  null. Er bleibt als **Messung vor dem Vollzug** stehen (der Plan ist vom 2026-09-14 datiert); ihn
  umzuschreiben hieße, den Gegenstand aus seinem eigenen Anlass zu entfernen, und die ausführende
  Rolle schreibt ihren Maßstab nicht um ([`AGENTS.md`](../../../../AGENTS.md) §3.10). (2) **Die
  Lieferung weicht an drei Stellen von
  [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) ab, und alle drei Sätze
  sind heute wahr:**
  `harness/README.md`, der Kommentar unmittelbar über `HOOKS_DIR ?= .githooks` im
  Aktivierungs-Fragment und `internal/emit/commitmsg.go` sagen konvergent zu, was die ADR
  (`Proposed`) als `skip-if-present` entscheidet; `TestEnforce_Convergent` hält die Aussage, Fall
  `49` färbt ihn rot. Die Abweichung ist **entschieden und terminiert** — ihr Träger ist
  [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Folgepflicht 1, und sie
  bindet erst mit dem Accept-Übergang
  ([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)); bis dahin ist
  das ein **Zustand**, nicht „erledigt". (3) **Zwei Abweichungen zwischen §3 und dem Vollzug**,
  beide keine DoD-Verletzung: §3 nennt `Makefile` (`full-smoke`) als geändertes Artefakt — geändert
  wurde `harness/tools/full-smoke.sh`, das Rezept ist unberührt; und `harness/README.md` und
  `internal/emit/enforce_test.go` sind gebaut, ohne in der Datei-Tabelle zu stehen (die erste
  verlangt der Doku-Punkt, die zweite der Review-Befund F-4). (4) **§8 nannte einen bewegten Zähler
  und einen Satz, der im Ziel nicht gilt** — beides ist gezogen.
- **Steering-Loop-Eintrag:** **Neuer Sensor — gezählt, nicht verkörpert.** Die Zusage *„der Träger
  nimmt die Commits der Repo-Werkzeuge mit und bricht sie ab"* hat **vier Träger, und ihre Deckung
  ist ungleich.** Das **Aktivierungs-Fragment** trägt sie bewacht:
  `TestHooksInstallFragment_TraegtDieReichweite` führt unter anderen die zwei Marker der Mitnahme
  (*„sieht jede Klasse, die `git` erzeugt"*, *„gibt seinen Werkzeug-Messages darum eine Kennung"*),
  Fall `357` färbt ihn rot, und der E2E prüft den Satz im Ziel — beide Kanäle dieses Repos melden
  ihn also. Die **Command-Vorlage** und die **README-Prosa** sagen dieselbe Zusage noch einmal in
  eigenen Worten; sie tragen **keine** eigene Prüfung, und keine hält sie gegen das Fragment —
  dieselbe Lücke, die Welle §6 für das Paar aus ausgeführter und emittierter Fassung benennt. Der
  **vierte** ist der Eintrag `'auch die Commits der Repo-Werkzeuge'` in der `for noetig`-Liste des
  E2E ([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)): er ist **selbst**
  ein Wächter der Zusage, `make full-smoke` läuft in **keinem** Gate, und kein gelisteter Fall nennt
  die Datei — er kann seine Zähne verlieren, ohne daß ein Lauf davon spricht. Von den vier ist er
  der einzige **Wächter**, den weder `make gates` noch `make mutate` meldet; die zwei Wiederholungen
  haben kein Zahn-Verlust-Risiko, weil sie keine Zähne haben.

  ```sh
  grep -l '^# files:.*full-smoke.sh' test/mutations/*.sh    # nur 190 — anderer Gegenstand
  ```

  **Kein `liegt in`-Feld:** mit diesem Vorgang ist **keine** Regel dieses Repos verkörpert worden —
  Fall `357` ist Liefergegenstand, keine Antwort auf einen Schwellen-Übertritt; der Eintrag ist
  damit gezählt, nicht verkörpert. **Auslöser:**
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — der Eintrag ist seit seiner Einführung verkörpert ([`AGENTS.md`](../../../../AGENTS.md) §3.6);
  dieser Vorgang zählt ihn nicht auf 3×, er belegt ihn. **Die Adresse dieser Grenze ist sein
  Beleg** `evidence/slice-kennungs-waechter-geht-ins-ziel.md`; bis dahin stand sie nur in einer
  Übergabe und in einem Zeitdokument.
- **Beobachtungs-Register (`../observations/`):** **Zwei Belege an vorhandenen Einträgen, kein neues
  Verzeichnis.** `evidence/slice-kennungs-waechter-geht-ins-ziel.md` liegt danach in
  [`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  — die **Apposition** im Liefer-Punkt 3 setzte zwei Dinge gleich, die nicht dasselbe sind (die
  Werkzeug-Commits als etwas, das der Träger *nicht* erreicht, während er sie erreicht **und**
  abbricht); der Vorgang hat sie widerlegt, und der Punkt war nur unter der Lesart *Beispiel-Liste*
  abhakbar. **Urteil: eigene Klasse? Nein** — die Klasse deckt den Fall, die Nachbarn sind enger
  (der eine nennt eine wahre, nichtssagende Zusage, der andere eine Bezugsmenge), und ein zweiter
  Name daneben wäre eine zweite Fassung derselben Beobachtung. **Mitbenannt, nicht mitgezählt:** der
  **Anlass-Block** aus §1 ist derselbe Fehler an einem zweiten Träger (Plan-Prosa statt
  Abnahmekriterium) und derselbe Vorgang — er bekommt darum keine zweite Datei. Und in
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — von **18** neuen Wächtern dieses Slice (**7** Go-Wächter, **10** bats-Fälle, **eine**
  E2E-Sektion) nennt ein gelisteter Fall **10**, **8** keinen. **Gemessen ist die Zuordnung, die
  ein `# expect:`-Kopf herstellt** — der Verifikations-Report zu diesem Vorgang zählt eine Zeile
  mehr („11"), weil er die Kopplungs-Gruppe der zwei bash-Fassungen über `340`/`341`/`342` als
  gedeckt führt; deren `# expect:` nennt aber `test/commit-msg-hook.bats`, nicht die Gruppe der
  emittierten Fassung. Von den acht ohne Fall trägt die Kopplungs-Gruppe der Betreff-Ausnahme Zähne
  (in einer eigenen Sonde: einseitig geänderte `exempt=`-Zeile färbt zwei bats-Fälle rot), und der
  E2E-Eintrag aus dem Steering-Loop-Eintrag oben ist der **zusätzliche** Wächter der
  Mitnahme-Zusage — die Zusage selbst hält der Go-Marker samt Fall `357`, sein eigener Verlust ist
  es, den kein Lauf meldet. Die Kommandos, **kein gespeicherter Wert**:

  ```sh
  grep -c '^func Test' internal/emit/commitmsg_test.go   # 7 Go-Waechter, jeder von einem Fall genannt
  grep -c '^@test' test/commit-msg-emission.bats         # 10 bats-Faelle der emittierten Fassung
  # je Waechter die Zahl der gelisteten Faelle, die ihn nennen (0 = keiner):
  for t in 'rot: eine Message ohne' 'kopplung: die Klassen-Aufzaehlung' 'rot: der Grund nennt den Ort' \
           'gruen: jede der vier' 'gruen: die Kennung darf' 'gruen: die Merge-' \
           'rot: eine Kennung in einer Kommentarzeile' 'fail-closed: fehlende Datei' \
           'kopplung: die zwei bash-Fassungen' 'kopplung: die Betreff-Ausnahme' \
           'kennungs_traeger_im_ziel'; do
    printf '%s  %s\n' "$(grep -rlF -- "$t" test/mutations/ | wc -l)" "$t"; done
  # 3x 1 (die ersten drei) und 8x 0 (die uebrigen acht, darunter die E2E-Sektion)
  for s in abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt neuer-waechter-ohne-mutations-fall; do
    printf '%-58s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
  done
  ```

  **Zwei Kandidaten tragen nicht, und das ist ebenfalls eine Antwort:**
  `lebendes-register-traegt-eine-ueberholte-fundliste` — kein lebender Norm-Eintrag dieses Vorgangs
  zählt eine Fundliste namentlich auf, die seine Messung nicht mehr führt; der Satz, den die
  Lieferung richtigstellt, ist keine Aufzählung. `waechter-abdeckung-haengt-an-uninstruierter-konvention`
  — der Träger des Ziels hängt am Commit und liest die Message-Datei, die `git` ihm übergibt,
  gleichgültig welcher Aufruf sie erzeugt hat
  ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 2); dieser Vorgang bewegt den Zähler nicht.
- **Folge-Slices:** **einer, und er ist eine Datei:** `slice-commit-traeger-wird-skip-if-present`
  (Der emittierte Commit-Träger verliert die konvergente Klasse) — in diesem Closure-Lauf unter
  `open/` angelegt, weil [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)
  Folgepflicht 1 ihn namentlich übergibt und eine Kennung **ohne** Datei durch die
  Folge-Slice-Paarung der Wellen-Closure fällt.
- **Risiken aus §6:** drei Risiken, drei Ausgänge — **einmal *eingetreten*** (mit der Kennung des
  Folge-Slices), **zweimal *entfallen***, jeder mit seiner Begründung in §6.
- **Drei Paarungen:** von der [welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md)-Closure
  getragen (dieser Slice ist ihr Mitglied), **hier nicht geprüft**. Was sie vorfindet, ist gelegt:
  **ein** Folge-Slice genannt und als Datei vorhanden (Zeile darüber); keine `liegt in`-Zeile —
  nichts verkörpert, also keine Anker-Paarung; und jede hier genannte Beobachtung existiert als
  Verzeichnis mit nicht leerem `evidence/`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
die Hook-Vorlagen und `internal/emit/` liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area). Die
**emittierte** Ebene ist keine Sub-Area dieses Repos: sie ist ein anderer Vertrag.

**Vorgelagert — offene Beobachtungen sichten:** das Register durchgegangen, zwei Treffer für diese
Fläche, jeder mit seinem Zähler-Stand (die Zahl der Dateien unter `evidence/`, abgelesen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` — kein gespeicherter Wert):

- [`BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
  — **2×, offen.** Berührt: der Wächter greift nur bei einer Message-Datei, und vier von sechs
  Agenten-Briefings nennen die Konvention nicht. **Im Ziel gilt die Abhängigkeit nicht:** der Träger
  des Ziels hängt am Commit und liest die Message-Datei, die `git` ihm übergibt, gleichgültig
  welcher Aufruf sie erzeugt hat — die Form-Abhängigkeit bleibt die dieses Klons; sie steht als
  Risiko in §6 und als Out-of-Scope-Punkt in §1.
- [`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md)
  — **1×, offen.** Berührt: der `commits`-Modulblock ist am gepinnten Stand unbedienbar, und dieser
  Slice wählt Träger, die nicht auf ihm beruhen müssen. Der Zähler bewegt sich nur, wenn der Slice
  die Klasse **beobachtet** statt sie zu umgehen.

Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

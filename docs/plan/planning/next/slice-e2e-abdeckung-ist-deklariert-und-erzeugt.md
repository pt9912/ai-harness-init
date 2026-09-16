# Slice slice-e2e-abdeckung-ist-deklariert-und-erzeugt: Die E2E-Abdeckung ist an jeder Stufe deklariert und als Tabelle erzeugt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Begründung in §1 *Warum wellenlos* — geprüft gegen
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(tragend — eine Zuordnung, die über ihrer Fundmenge schweigt, ist dieselbe Klasse wie ein Gate
über leerem Prüfbereich), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(der E2E ist sein Beleg), [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben ihrem Kommando),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne benanntes und rot gesehenes Gegenbeispiel).

**Berührte Spec-Stellen:** — . Der Slice richtet eine Zuordnung auf den **Bestand** von
[`spec/lastenheft.md`](../../../../spec/lastenheft.md) und auf die **Stufen** des E2E; er ändert
keine Spec-Aussage. Die Spec ist Prüfgegenstand, nicht Änderungsziel.

**Verantwortlich:** — .

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jede Stufe des Voll-E2E `harness/tools/full-smoke.sh` nennt die Anforderung, die sie
trägt, an der Stufe selbst, und `make e2e-abdeckung` erzeugt daraus die Abdeckungs-Tabelle
docs/user/e2e-abdeckung.md — eine **stabile Deklaration**, kein Lauf-Beleg; eine Lücke in
**beiden** Richtungen (Deklaration ohne Stufe, Stufe ohne Deklaration) fällt dabei laut aus.

### Der Befund, gemessen

Alle Zahlen sind über den Baum vom 2026-09-15 genommen und **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die erste Handlung der Umsetzung ist, sie neu zu fahren. Jede Zahl steht neben dem
Kommando, das sie liefert:

```sh
grep -cE '^### LH-' spec/lastenheft.md                                                        # 14 Anforderungen
grep -cE '^echo "full-smoke: .* \.\.\."$' harness/tools/full-smoke.sh                         # 15 E2E-Stufen
grep -oE 'LH-(FA|QA)-[0-9]+' harness/tools/full-smoke.sh | sort -u | wc -l                     #  9 Anforderungen
```

1. **Der E2E kennt keine Anforderung, er nennt sie nur.** Neun der vierzehn Anforderungen stehen
   als Kommentar irgendwo im Skript; **welche** Stufe **welche** Anforderung trägt, steht an keiner
   Stelle. Fünf ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
   [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
   [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2),
   [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
   [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) nennt das Skript
   überhaupt nicht — ob das eine Lücke ist oder Absicht, sagt nichts.
2. **Die Stufen sind benannt, aber nicht adressierbar.** Das Skript gliedert sich in fünfzehn
   `full-smoke: … ...`-Kopfzeilen (die Zahl darüber); die Zähne und Prüfungen darunter (etwa
   `Zieldefinition`, `matrix-Zahn`, die zwei hexagonal-Zähne) tragen keine Adresse, unter der eine
   Deklaration sie erreichen könnte.
3. **Die repo-weite Matrix antwortet über eine andere Beziehung.** `make doc-trace` gibt die
   Requirements-Traceability-Matrix auf stdout, `make doc-complete` fällt bei einer Waise
   (`d-check.mk`, beide **advisory**, kein Gate). Beide kennen die Beziehung *Anforderung → ADR /
   Slice*; die Beziehung *Anforderung → E2E-Stufe* kennt keines von beiden, und keine der zwei
   Ausgaben nennt einen `Ort` im Skript. Ein Leser, der dort nach dem E2E-Beleg sucht, findet ihn
   nicht.
4. **Die Form ist in einem Nachbar-Repo erprobt, das dieselbe Baseline fährt.** Dort ist die
   Abdeckung *je Spec-Kennung* in einer erzeugten Tabelle abgelegt: die Zeilen leitet der Erzeuger
   aus dem Quelltext ab, jede Phase deklariert sich an Ort und Stelle über einen Anker, die Datei
   ändert sich mit den Deklarationen statt mit jedem Lauf, und die Beschreibungsspalte trägt keine
   Kennungen. Was hier abgeschrieben wird, ist diese **Form** (Erzeugung, Ortsfestigkeit, stabile
   Deklaration) — nicht ihr Ergebnis und nicht ihre Zweiteilung (dort *Go-Zeilen aus dem Quelltext +
   Bash-Zeilen*; hier gibt es keine Go-Hälfte des E2E, s. §1 *NICHT*).

### Warum wellenlos

Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht: Eine Welle liegt vor,
wenn ein Closure-Trigger **mehr** beobachtet, als die DoDs ihrer Slices ohnehin belegen. Hier ist
es ein Slice; sein Closure-Trigger schriebe seine eigene DoD ab — der dort benannte Regelfall für
wellenlose Arbeit.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Waisen-Urteil** (*welche Anforderung hat gar keine E2E-Stufe*) — **anderer Vorgang.** Diese
  Richtung ist der Gegenstand von `doc-complete` (Bezug *Anforderung → ADR/Slice*), und
  [slice-192](slice-192-rtm-sieht-alle-anforderungen.md) gibt ihrem Vollständigkeits-Urteil
  gerade einen Leser. Ein zweiter Waisen-Richter neben dem ersten wäre eine **zweite Quelle** für
  dieselbe Frage, und genau das ist die Klasse
  [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md).
  Die erzeugte Tabelle **zeigt** die deklarierten Paare; ob eine fehlende Zeile eine Lücke ist,
  urteilt der Leser gegen den Bestand von
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) — und das ist die Matrix, nicht diese Datei.
- **Ein Gate, und damit ein Platz in `make gates`** — **anderer Vorgang, und der Gegenstand trägt
  ihn nicht.** Die Tabelle ändert sich mit den **Deklarationen**, nicht mit jedem Lauf; ein Gate
  darüber urteilte über den Quelltext eines Skripts, nicht über den Zustand des Baums. Sie tritt
  darum neben `smoke`, `full-smoke` und `doc-trace` in die advisory-Ziele (`kein Gate`).
- **Ein zweiter Halbzug aus Go** — **anderer Vorgang.** Die Nachbar-Form (*Go-Zeilen aus dem
  Testpaket, Bash-Zeilen aus dem Runner*) setzt ein Go-E2E-Testpaket voraus. Dieses Repo hat keines:
  sein Voll-E2E **ist** das Bash-Skript. Eine Go-Hälfte zu bauen hieße, einen Gegenstand zu
  erfinden, den der E2E nicht hat.
- **Eine Änderung daran, was der E2E prüft** — **Schicht-Abgrenzung, kein Produkt-Code.** Der Slice
  setzt **Deklarationen** an die vorhandenen Stufen und ändert keine einzige Prüfung, keine
  Erwartung und keinen Exit-Code des Skripts; das Werkzeug, das er hinzufügt, ist ein Bash-Helfer
  unter `harness/tools/` und ein `make`-Ziel daneben.

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

**Drei Liefer-Punkte, und sie bauen aufeinander:** (1) gibt jeder Stufe einen Ort für ihre
Anforderung, (2) macht daraus die erzeugte Tabelle, (3) hält beide Lücken laut.

- [ ] **(1) Jede Stufe trägt ihre Deklaration, und die Deklarations-Form ist eine.** Eine
  Funktion `e2e_abdeckung <Kennungen> <Kurzbeschreibung> <Anker>` steht in `harness/tools/full-smoke.sh`;
  **jede** der fünfzehn Stufen (Zahl aus §1) führt mindestens einen Aufruf, der die Anforderung(en)
  nennt, die diese Stufe trägt, und einen **Anker** — einen wörtlichen Ausschnitt aus einer Zeile
  **innerhalb** der Stufe. Der Aufruf läuft auch **im E2E selbst** und bricht ab, wenn sein Anker
  nicht mehr auflöst (die Stufe wurde umgebaut). Die Form ist eine **Entscheidung dieses Slice**:
  der Anker ist eine *bestehende* Zeile der Stufe, nicht eine neue Marke — so trägt die Deklaration
  ihren Ort aus dem Skript, das sie beschreibt.
- [ ] **(2) `make e2e-abdeckung` erzeugt docs/user/e2e-abdeckung.md aus dem Quelltext, nicht aus
  einem Lauf.** Das Ziel fährt einen Helfer unter `harness/tools/`, der `harness/tools/full-smoke.sh`
  als **Text** liest (Docker-frei, keine E2E-Ausführung), je Deklaration den Anker auf eine Zeile
  auflöst und die Tabelle rendert. **Kein Gate** — das Ziel steht **nicht** in `make gates` und wird
  in [`harness/README.md`](../../../../harness/README.md) §Werkzeuge als `kein Gate` geführt, mit
  Eintrag in `targets.exempt-targets` ([`.d-check.yml`](../../../../.d-check.yml)). Der Kopf der
  Datei sagt, was sie ist: **stabile Abdeckungs-Deklaration, kein Lauf-Beleg** — sie ändert sich mit
  den Deklarationen, nicht mit jedem Lauf; der Erzeuger schreibt nur bei inhaltlicher Abweichung
  (Temp-Datei + Vergleich). Die Kennungsspalte trägt je Kennung den Anker-Link in
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md); die Beschreibungsspalte trägt keine
  Kennungen. **Rot gesehen:** eine Deklaration, deren Anker gelöscht ist, endet mit Exit ≠ 0 und
  nennt Anker und Nachweis (Ausgabe im Umsetzungs-Commit).
- [ ] **(3) Beide Richtungen fallen laut aus, und ihr Rot ist hergestellt.** Der Erzeuger bricht ab
  (a) bei einer **Deklaration ohne Stufe** (Anker löst nirgends auf, Klammer aus Punkt 2) und (b) bei
  einer **Stufe ohne Deklaration** — die Stufen-Menge ist über ein **Kriterium** abgegrenzt, nicht
  über eine Aufzählung: eine Zeile `echo "full-smoke: … ..."` eröffnet eine Stufe (Zahl aus §1), und
  ihre Region bis zur nächsten solchen Zeile muss mindestens eine Deklaration tragen. **Rot gesehen,
  beide:** ein `test/mutations/`-Fall nimmt einer Stufe ihre Deklaration (Richtung b) und ein
  bats-Fall in `test/e2e-abdeckung.bats` fährt den Erzeuger über einer **mutierten Kopie** des
  Skripts für beide Richtungen; `make mutate` meldet den Fall als bewacht. Der Erzeuger nimmt
  Quelle und Ziel als Argumente, damit ein Test ihn über einer Kopie fahren kann, ohne den
  geprüften Baum zu berühren.
- [ ] `make gates` grün.
- [ ] `make e2e-abdeckung` geschrieben und der generierte Stand von docs/user/e2e-abdeckung.md
  committet (der Erzeuger meldet „unverändert" bei einem zweiten Lauf — belegt).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: der E2E-Sensor [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
  nennt die Deklarations-Form, und [`harness/README.md`](../../../../harness/README.md) §Werkzeuge
  führt das neue Ziel.
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
| `harness/tools/full-smoke.sh` | update | der Funktionskopf `e2e_abdeckung` und je ein Aufruf an jeder der fünfzehn Stufen (Liefer-Punkt 1). Die Prüfungen, Erwartungen und Exit-Codes des Skripts bleiben unberührt |
| harness/tools/e2e-abdeckung.sh | neu | der Erzeuger: liest `harness/tools/full-smoke.sh` als Text, löst Anker auf, prüft beide Richtungen, rendert die Tabelle (Liefer-Punkte 2 und 3). Nimmt Quelle und Ziel als Argumente |
| `Makefile` | update | das advisory-Ziel `e2e-abdeckung` (`kein Gate`), nach der Form von `smoke`/`full-smoke`/`archive-welle` |
| docs/user/e2e-abdeckung.md | neu (erzeugt) | die Abdeckungs-Tabelle, mit dem Kopf *stabile Deklaration, kein Lauf-Beleg* (Liefer-Punkt 2) |
| [`harness/README.md`](../../../../harness/README.md) §Werkzeuge | update | die Zeile des neuen Ziels in der `kein Gate`-Tabelle, sonst listet es nur `make help` |
| [`.d-check.yml`](../../../../.d-check.yml) `targets.exempt-targets` | update | das neue Ziel trägt keinen Anker in §Sensors — dieselbe Einordnung wie `smoke`/`full-smoke` |
| [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md) | update | die Prosa des E2E nennt die Deklarations-Form und den Erzeuger |
| `test/e2e-abdeckung.bats` | neu | die zwei Richtungen, je über einer mutierten **Kopie** des Skripts — Happy Path, Boundary (Stufe ohne Deklaration) und Negative (Deklaration ohne Stufe) nach [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `test/mutations/` | neu | der Fall, der einer Stufe ihre Deklaration nimmt und den bats-Fall daraus rot färbt (Liefer-Punkt 3) |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Die fünfzehn Deklarationen folgen **einer** Form; sie sind eine mechanische
  Wiederholung an fünfzehn Orten, nicht fünfzehn verschiedene Änderungen. Der Anker ist je Stufe
  eine **vorhandene** Ausgabe- oder Kommentarzeile der Stufe — es wird keine neue Marke erfunden.
- Die Kennungen der Tabelle kommen aus dem **Lastenheft-Kopf** selbst: der Erzeuger leitet den
  Anker-Slug aus der `### LH-…`-Überschrift ab, statt ihn zu pflegen. Eine Kennung ohne
  auflösenden Anker ist ein harter Abbruch, kein leerer Link.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **kein Vorgänger** — der Slice ist einzeln lieferbar, er ändert
`harness/tools/full-smoke.sh` additiv und berührt keine Datei, die ein anderer offener Slice
gleichzeitig schreibt. Der Übergang wartet allein auf die Priorisierung (`Verantwortlich:` gesetzt).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Deklarations-Form erweist sich als
  nicht auf **alle** Stufen anwendbar — etwa weil eine Stufe keine stabile, wörtliche Ankerzeile
  führt und die Stufen-Menge stattdessen eine Form-Marke bräuchte. Dann wird die Form zuerst
  getrennt geschnitten (Deklaration) und der Erzeuger danach.
- `in-progress` → `open` (blockiert — Carveout?): `make docs-check` fällt über der erzeugten
  Tabelle aus einem Grund rot, der eine Gate-Entscheidung braucht — etwa weil `codepaths`
  eine `file:NNN`-Ortsspalte anders prüft als erwartet und die Form der Spalte eine
  Konfigurations-Änderung verlangt, die nicht in diesen Schnitt gehört.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

- **Beobachtbar 1:** `make e2e-abdeckung` läuft zweimal grün — der zweite Lauf meldet
  *„unverändert"*. Die erzeugte Tabelle docs/user/e2e-abdeckung.md nennt zu jeder der fünfzehn
  Stufen mindestens eine Anforderung, jede Kennung mit auflösendem Anker-Link.
- **Beobachtbar 2:** beide Lücken-Richtungen sind **je einmal rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md)
  §3.6): eine entfernte Deklaration (Stufe ohne Deklaration) und ein gebrochener Anker (Deklaration
  ohne Stufe) — je mit dem Kommando, das sie rot färbt, im Umsetzungs-Commit. `make mutate` führt den
  `test/mutations/`-Fall als **bewacht**.
- `make gates` grün; die Tabelle ist committet und im zweiten Lauf stabil.
- **Review** durch einen Lauf, der die Umsetzung nicht geschrieben hat; danach **Verifikation**
  gegen diese DoD.
- Closure-Notiz §7 mit Lerneintrag, geschrieben vom **Planner** in frischem Kontext
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10), und jedes Risiko aus §6 mit genau einem Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Risiko 1 — die Stufen-Menge hängt an einer Textform des Skripts.** Das Kriterium aus
  Liefer-Punkt 3 (`echo "full-smoke: … ..."`) sieht eine künftige Stufe nur, wenn ihre Kopfzeile
  dieser Form folgt. Eine Stufe, die anders eröffnet wird, ist für den Erzeuger keine — die
  Lücke fiele in die Richtung *Stufe ohne Deklaration* nicht auf. Die Grenze wird in
  [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md) benannt, statt sie
  zu behaupten. — **Ausgang:** <offen>
- **Risiko 2 — die `Ort`-Spalte ist möglicherweise unbewacht.** Ob `codepaths.check-lines` des
  gepinnten d-check eine **einzelne** `file:NNN`-Referenz prüft oder nur die Bereichsform
  `file:N-M`, entscheidet, ob `make docs-check` die Zeilennummern der Tabelle überhaupt hält.
  Gemessen wird das in der Umsetzung; fällt die Antwort *nein*, ist die Spalte eine **benannte
  Lücke** — der Erzeuger garantiert die Nummer durch Konstruktion, kein Gate prüft sie gegen das
  Skript. — **Ausgang:** <offen>
- **Risiko 3 — eine Deklaration kann veralten, ohne rot zu werden.** Der Anker bleibt auflösbar,
  während die Stufe ihre Aussage ändert: der Erzeuger sieht nur, **dass** der Anker existiert,
  nicht ob die genannte Anforderung noch zu ihr gehört. Der Text bleibt damit ein **Urteil**, das
  der Review hält — kein Sensor. — **Ausgang:** <offen>
- **Risiko 4 — eine erzeugte Datei unter `docs/user/` ist neu in diesem Baum.** Alles unter
  `docs/user/` liegt im Prüfbereich von `docs-check` (roots `["."]`); eine nicht verlinkte Kennung
  oder ein Toter-Anker-Link färbt es rot. Der Erzeuger muss die Link-Form des Hauses treffen (Anker
  mit Fragment), sonst ist `make gates` rot, nicht die Tabelle. — **Ausgang:** <offen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas. `*` (gesamtes Repo),
Kürzel `ALL`: die Aussage des Slice ist die **Anforderungs-Abdeckung des Repos** — welche Stufe
welche Anforderung trägt —, und sie hängt weder an einer Modul-Grenze noch an einer Sprach-Achse.
`harness/tools/`, Kürzel `TOOLS`: der **Träger** (die Erweiterung von `full-smoke.sh` und der neue
Erzeuger) liegt dort, und diese Sub-Area ist in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) geführt. Beide erfüllen die Schwelle
≥ 2 von 3 Achsen; eine feinere Sub-Area *„E2E"* auszudifferenzieren hätte weder eigene
Konventionen-Dichte noch eigenen Reifegrad gegenüber `*` und unterbliebe darum.

**Vorgelagert — offene Beobachtungen sichten:** Gesichtet ist der **gemergte** Stand vom 2026-09-15:
**117** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein
Erwartungswert). Alle Einträge dieses Repos führen dieselbe Sub-Area `*`, die Sichtung ist also
nach **Gegenstand** geschnitten, nicht nach Sub-Area. **Vier Einträge berühren diesen Slice**, je
mit ihrem Zähler-Stand aus `ls <eintrag>/evidence/*.md | wc -l`:

| Beobachtung | Stand | berührt |
|---|---|---|
| [`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md) | **3×**, offen | die Deklaration sitzt an der **Stufe** (*vor* ihr, im Skript), der ausgewertete Lauf ist der **Erzeuger** (*nach* ihr) — die Zusage dieses Slice muss sagen, welche der zwei Kanten welcher Träger sieht |
| [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md) | **3×**, *verkörpert* | die Tabelle ist eine Vollständigkeits-Aussage über die E2E-Stufen; §1 grenzt ab, dass das **Waisen-Urteil** nicht hier fällt, sondern bei `doc-complete` |
| [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md) | **2×**, offen | eine erzeugte Zeile kann als *„diese Stufe lief grün"* gelesen werden; der Kopf der Datei sagt *stabile Deklaration, kein Lauf-Beleg* — dieselbe Klasse, hier als ihre Antwort behandelt |
| [`rotierender-pruef-gegenstand-ohne-ort`](../observations/BEO-ALL/rotierender-pruef-gegenstand-ohne-ort/observation.md) | **1×**, offen | dieser Slice gibt einem Prüf-Gegenstand einen **Ort** (die `Ort`-Spalte mit Zeilennummer) — für einen **anderen** Gegenstand als den der Beobachtung; ob daraus ein Beleg wird, ist ein Urteil und fällt bei der Closure, nicht beim Schnitt |

**Keine der vier erreicht mit diesem Slice die Schwelle 3×** (eine steht schon darüber, eine ist
`verkörpert`); der Schnitt löst darum **keinen** Folge-Slice aus. Ob ein Eintrag einen **Beleg**
bekommt, ist ein Urteil beim Schreiben und fällt bei der Slice-Closure — nicht beim Schnitt; zwei
der vier sind so geschnitten, dass dieser Slice ihre **Antwort** ist, nicht ihr Auftreten.

**Modus-Begründungsblock — Umfang.** Bei reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*.

**Alle berührten Sub-Areas GF** — der Block unten steht trotzdem, weil das Evidenz-Kriterium hier
eine Antwort trägt, die über *„GF, also niedrig"* hinausgeht.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** **hoch für die Form, dünn für den Gegenstand.** Die Ablage
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) führt ihre Kennungen selbst, das Doku-Gate
  hält die Link-Form (`link-policy: always`) und die Zeilen-Referenzen (`codepaths.check-lines`),
  und [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  bindet jede Zahl an ihr Kommando. **Dünn ist der Gegenstand:** *welche Stufe welche Anforderung
  trägt* ist nirgends verankert — genau die Lücke, die dieser Slice schließt.
- **Phase-Reife:** **Phase 5.** Das Lastenheft, das Doku-Gate und der Voll-E2E laufen seit vielen
  Slices; verändert wird eine **Beziehung auf einem reifen Bestand**, nicht ein Bestand eingeführt.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig, mit einer benannten Kante.** Der Bestand wird nicht
  angefasst (die Tabelle ist erzeugt, das Skript nur additiv erweitert). Die Kante ist die
  **Reichweite der Zusage**: die Stufen-Menge hängt an einer Textform (Risiko 1), und die
  `Ort`-Spalte ist möglicherweise unbewacht (Risiko 2) — beides ist benannt, nicht geschlossen.
- **Reconciliation-Aufwand:** **keiner** — GF, es gibt keine Inventur-Linie. Gemessen statt
  behauptet: `ls docs/plan/planning/reconciliation.md` → *nicht vorhanden*; dieses Repo hat keinen
  Brownfield-Bootstrap und führt darum kein Inventur-Register. Deshalb trägt §2 das
  Reconciliation-Item der Vorlage nicht — es entfällt, wie die Vorlage es für Repos ohne
  Brownfield-Bootstrap vorsieht. **Graduation:** entfällt (GF).

### Sub-Area: `harness/tools/`

- **Modus:** GF
- **Konventionen-Dichte:** **hoch.** Die Sub-Area ist in der Modus-Deklaration von
  [`harness/conventions.md`](../../../../harness/conventions.md) geführt; `make shell-lint` deckt
  jedes Skript dort, und die Prosa je Werkzeug liegt unter
  [`harness/sensors/`](../../../../harness/sensors/) — die neue Datei tritt in dieselbe Form.
- **Phase-Reife:** **Phase 5.** Die Werkzeug-Ablage ist etabliert; der neue Erzeuger folgt der Form
  der vorhandenen Helfer.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig.** Kein Bestand wird inventarisiert; die neue Datei ist
  additiv.
- **Reconciliation-Aufwand:** **keiner** — GF. **Graduation:** entfällt (GF).
# Slice slice-lifecycle-werkzeuge-tragen-die-kennung: Archiv-Stub, Vorschau und Werkzeug-Commits nennen ihre Vorgänge bei der Kennung, die dieses Repo führt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht beobachtet keine Closure-Bedingung mehr, als diese DoD belegt.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Werkzeug, das an den Commits des eigenen Prozesses bricht, trägt seine Klasse nicht),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 3 — die Kennung einer Beobachtung **ist** der Pfad `BEO-<KUERZEL>/<slug>`),
[`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) (Festlegung 1
setzt den Träger, Festlegung 4 führt die vier Stellen namentlich),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Kennungs-Form neuer Slices und Wellen ist der Name),
[`MR-059`](../../../../harness/conventions.md#mr-059) (Setzung 1 — jede Kennungs-Erkennung trägt
die zugelassenen Formen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — die Zahlen unten wandern und sind keine Erwartungswerte).

**Berührte Spec-Stellen:** — Der Slice baut Werkzeug-Fähigkeiten; er schreibt keine Spec-Stelle.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die drei Stellen, an denen die Lifecycle-Werkzeuge dieses Repos eine Kennung führen,
führen die Kennung, die dieses Repo **heute** führt: Der Archiv-Stub erkennt die Register-Kennung
`BEO-<KUERZEL>/<slug>` und baut daraus einen Link, der auflöst; jeder am ruhenden Baum
beobachtbare Ausgang des schreibenden Archiv-Laufs trägt eine Kennung und erscheint in der
Vorschau; und die Commit-Messages der eigenen Werkzeuge nennen den Vorgang, den sie abschließen.

**Übernimmt:** `slice-188-archiv-stub-kennt-die-register-verzeichnis-form`,
`slice-220-plan-ausgang-traegt-eine-kennung`, `slice-werkzeug-commits-tragen-eine-kennung`.

**Warum die drei ein Slice sind.** Sie haben denselben Gegenstand — die Kennung, unter der ein
Werkzeug dieses Repos einen Vorgang anspricht —, dieselbe Fehlerrichtung (die Kennung fällt durch
oder fehlt, statt laut zu brechen) und denselben Bestand: `internal/archive/` und die Skripte, die
es aufrufen. Getrennt geschnitten fassen sie dasselbe Paket dreimal nacheinander an.

**Die Ausgangslage, gemessen statt geschätzt** — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); die dritte Zahl wandert mit jedem Lifecycle-Wechsel, also auch mit diesem Slice:

```sh
# (a) der Stub erkennt die abgeloeste Form und verlinkt auf die abgeloeste Datei
grep -cE 'BEO-\[0-9\]\{3\}|observations\.md' internal/archive/stub.go     # 2
# (b) der Plan-Ausgang des schreibenden Laufs traegt keine Kennung
grep -nE '^\s*(switch|if) len\(b\.Plaene\)' internal/archive/vorschau.go internal/archive/anwenden.go
grep -c 'Kennung: "' internal/archive/vorschau.go
# (c) Werkzeug-Commits ohne eine Kennung, die ein Muster aus .d-check.yml sieht
git log --format='%s' | grep '^slice-mv:' \
  | grep -vcE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'   # 94
```

**Die Fehlerrichtung von (a) ist die schlechtere von zweien: still, nicht laut.** Eine
Closure-Notiz, die `BEO-ALL/<slug>` nennt, fällt durch den Ausdruck **durch** — der Stub verliert
die Zeile, statt einen toten Link zu zeigen. Bei (b) laufen zwei Fassungen derselben Bedingung
auseinander: Unter einer Welle-Kennung stimmen Vorschau und schreibender Lauf überein, unter dem
Schlüssel ohne Welle schweigt die Vorschau und der Lauf bricht ab. Bei (c) bricht der Träger aus
[`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 1
**nach** dem `git mv` und hinterlässt einen gestagten Rename ohne Commit — in einem Aufruf, den
jede Rolle bei jedem Lifecycle-Wechsel fährt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Menge der zugelassenen Kennungs-Formen wird nicht erweitert.** Welche Formen eine
  Erkennung trägt, setzt
  [`MR-059`](../../../../harness/conventions.md#mr-059); dieser Slice schreibt Messages **in** einer
  bereits zugelassenen Form. Eine neue Form wäre eine Norm-Änderung und damit ein **anderer
  Vorgang** (Architect, [`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Der Bestand der 94 kennungslosen Messages wird nicht umgeschrieben.** Er ist Historie und
  bleibt als **Bestand** stehen; `git` trägt sie, und ein Rewrite bräche jede Adresse, die auf
  einen dieser Commits zeigt.
- **`make slice-mv` bekommt keine neue Fähigkeit.** Der Slice ändert, was in der Betreffzeile
  steht, nicht was das Werkzeug tut — **Schicht-Abgrenzung** gegen den Verweis-Nachzug selbst.
- **Die Archivierung des Altbestands wird nicht gefahren.** Ob und wie geschlossene Wellen
  nachträglich archiviert werden, ist eine Planungs-Entscheidung und ein **anderer Vorgang**;
  hier wird nur der Ausgang benannt, an dem der schreibende Lauf heute abbricht.

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

**Drei Liefer-Punkte**, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) `Hervorgegangen:` erkennt die heutige Register-Kennung und baut einen Link, der
      auflöst.** Eine Closure-Notiz, die `BEO-<KUERZEL>/<slug>` nennt, erscheint im Stub; das
      Linkziel existiert im Arbeitsbaum. Ob die abgelöste dreistellige Form daneben erkannt bleibt,
      ist eine Entscheidung dieses Slice und wird im Doc-Kommentar der Funktion begründet.
      **Rot:** `make test` — die Erwartung in `stub_test.go` und `anwenden_test.go` steht auf der
      heutigen Kennung; der Ausdruck auf die alte Form zurückgesetzt färbt sie rot. Der Zahn misst
      damit die **Eigenschaft**, nicht die abgelöste Form.
- [ ] **(2) Jeder am ruhenden Baum beobachtbare Ausgang des schreibenden Laufs trägt eine Kennung
      und erscheint in der Vorschau.** Beide in §1 gemessenen Stellen sind gemeint. Vorschau und
      schreibender Lauf lesen **dieselbe** Bedingung, statt sie zweimal zu führen; für einen echten
      Welle-Schlüssel erscheint der neue Ausgang **nicht** (dort trägt `planSperre` den Fall
      bereits).
      **Rot:** ein `test/mutations/`-Fall, der dem neuen Ausgang die Bedingung nimmt — die Vorschau
      meldet dann wieder zu wenig —, mit dem fallenden Wächter in seiner `# expect:`-Zeile.
- [ ] **(3) Die Commit-Messages der eigenen Werkzeuge tragen im Betreff die Kennung des Vorgangs,
      den sie abschließen** — beim Lifecycle-Move und beim Verweis-Nachzug die des bewegten Slice,
      bei den Archiv-Commits die der Welle —, in einer Form, die die Erkennung dieses Repos trägt.
      **Rot:** vor dem Fix und **nach** `make hooks-install` endet ein `make slice-mv` am Träger und
      hinterlässt einen gestagten Rename ohne Commit; die **gelesene** Meldung nennt den Grund.
      Nach dem Fix läuft derselbe Aufruf durch, und der Commit trägt die Kennung im Betreff.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] **Doku-Update — teils Ergänzung, teils Streichung.** Die Prosa in
      [`harness/README.md`](../../../../harness/README.md#traceability) §Traceability nennt die
      Werkzeug-Klasse nicht mehr als offen, sobald sie es nicht mehr ist; und die zwei Stellen, die
      den Ausgang ohne Kennung heute in Prosa erklären — der `ABGRENZUNG`-Block in
      [`internal/archive/vorschau.go`](../../../../internal/archive/vorschau.go) und §Grenze Punkt
      7 in [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) —
      fallen mit ihrem Gegenstand weg ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
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
| [`internal/archive/stub.go`](../../../../internal/archive/stub.go) | update | Kennungs-Erkennung und Linkziel von `Hervorgegangen:` |
| [`internal/archive/vorschau.go`](../../../../internal/archive/vorschau.go) · [`internal/archive/anwenden.go`](../../../../internal/archive/anwenden.go) | update | die Bedingung steht einmal, der Ausgang trägt eine Kennung |
| [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh) | update | Betreffzeile von Move- und Nachzug-Commit |
| `internal/archive` (Archiv-Commits) | update | Betreffzeile der zwei Werkzeug-Commits, Kennung der Welle |
| [`test/mutations/`](../../../../test/mutations) | neu | ein Fall für den neuen Ausgang aus DoD 2 |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Reihenfolge: zuerst (3), weil ohne Kennung in der Werkzeug-Message jeder eigene Lifecycle-Wechsel
  dieses Slice am Träger bricht, sobald `make hooks-install` gelaufen ist; danach (1) und (2).

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei, und die drei
übernommenen Slices liegen in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Ausgang aus (2) verlangt, die
  Bedingung an einer dritten Stelle zusammenzuführen, oder (3) verlangt eine neue Kennungs-Form.
  Dann wird neu geschnitten statt in diesem Slice zu wachsen.
- `in-progress` → `open` (blockiert — Carveout?): Die Werkzeug-Message kann die Kennung des
  Vorgangs nicht kennen, weil der Aufrufer sie nicht übergibt — dann fehlt eine Schnittstelle, und
  die gehört vor die Arbeit.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und ein `make slice-mv` auf einem Klon **mit** `make hooks-install` läuft
   durch; sein Commit trägt die Kennung im Betreff.
2. Die drei Rot-Belege aus §2 stehen mit gelesener Ausgabe im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der eigene Lifecycle-Wechsel bricht am Träger, bevor (3) gebaut ist.** *Absehbar:* entfallen,
   wenn (3) zuerst gebaut wird (§3); sonst eingetreten mit einem gestagten Rename ohne Commit als
   Symptom.
2. **Die Kennung des Vorgangs steht dem Werkzeug nicht zur Verfügung.** *Absehbar:* entfallen,
   wenn Move und Nachzug die bewegte Slice-Kennung ohnehin als Argument führen; sonst
   Rückführung nach §4.
3. **Die Bedingung aus (2) wird an zwei Stellen geschrieben statt an einer**, und die zwei laufen
   erneut auseinander. *Absehbar:* entfallen, wenn ein Test je Richtung über einem synthetischen
   Baum beide Stellen gegen dieselbe Quelle hält.
4. **Der Stub erkennt die alte Form nicht mehr, und ein Altbestands-Stub verliert seine Zeile.**
   *Absehbar:* entfallen, wenn die Entscheidung aus (1) im Doc-Kommentar begründet ist und ein
   Test die gewählte Richtung hält.

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/archive/` und `test/mutations/` in
`*` sowie `harness/tools/` (`TOOLS`) für den Skript-Träger des Lifecycle-Wechsels. `.codex/`
(`CODEX`) ist nicht berührt. Beide berührten Sub-Areas erfüllen das Inklusionskriterium;
ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md) | 4 | verkörpert | DoD 3 in einem Satz |
| [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md) | 20 | geplant | der Lifecycle-Wechsel ist der Aufruf, an dem DoD 3 gemessen wird |
| [`verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md) | 6 | verkörpert | DoD 1 — das Linkziel des Stubs muss auflösen |
| [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md) | 14 | verkörpert | der Nachzug-Commit aus DoD 3 ist derselbe Vorgang |

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

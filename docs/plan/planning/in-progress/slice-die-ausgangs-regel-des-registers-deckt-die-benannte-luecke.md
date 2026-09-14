# Slice slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke: Eine Beobachtung über der 3×-Schwelle trägt einen Ausgang — auch wenn ihr Inhalt eine benannte Lücke ist

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Der Abschluss-Gegenstand ist die DoD unten — **eine** Regel an **einem**
Ort plus ihr ADR. Es gibt kein *Mehr*, das eine Welle beobachtete: Was die Menge der
Register-Einträge angeht, so ist sie kein Wellen-Trigger, sondern der Prüfgegenstand des
Folge-Slice ([`slice-register-ueber-der-schwelle-bekommt-seinen-waechter`](../next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md)),
dessen Sensor sie mechanisch hält (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind das Beobachtungs-Register **dieses** Repos und
seine zwei Leser. Was ein emittiertes Repo an Ausgangs-Regeln bekommt, entscheidet der Slice, der
die Tool-Ebene entscheidet — die zwei Ebenen tragen verschiedene Verträge.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Sensor, der mehr Ausgänge aufhebt als die benannten, erzeugt ein stilles Grün an einer
fail-closed-Stelle),
[ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 3 — die Kennung **ist** der Pfad `BEO-<KUERZEL>/<slug>`; die Verzeichnis-Form trägt die
Zählregel strukturell),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (eine Zusage ist fertig, wenn benannt ist, was sie
brechen müsste),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 1 und 2 — jede Zahl dieses Plans steht neben dem Kommando, das sie liefert),
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 — ein Register-Zähler ist eine datierte Messung, kein Wert im Text),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist das Register
dieses Repos und die Regel, die seine Leser bindet).

**Verantwortlich:** Architect. Der Liefergegenstand ist eine **normative** Entscheidung — welchen
Ausgang ein Registereintrag tragen darf und was der Lese-Schritt liest. Wem das **Schreiben**
gehört, sagt Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung:
Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*;
[`AGENTS.md`](../../../../AGENTS.md) §3.8 bindet daneben **die Hard Rules dieser Datei und den
Adaptions-Block** und trägt hier nicht: der Ausgang ist keine Hard Rule und kein Adaptions-Eintrag.
Dieselbe Zuschnitt-Wahl trägt
[`slice-183`](../done/slice-183-ausloeser-der-wellenlosen-archivierung.md). Der Planner schneidet
den Slice, er entscheidet ihn nicht.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Für eine Beobachtung, die die 3×-Schwelle überschritten hat und deren `state.md` auf
`offen` steht, ist entschieden und aufgeschrieben, welchen der Ausgänge sie trägt — oder es steht
begründet da, daß die geschlossene Menge der drei Ausgänge sie nicht faßt und was stattdessen
gilt.**

### Der Befund, und warum er einen Träger braucht

Der **Lese-Schritt** der Wellen-Closure weist jedem Eintrag ab 3× genau **einen** von drei
Ausgängen zu — *verkörpert · geplant · gestrichen* (Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register; die Menge steht auch in
[`observations/README.md`](../observations/README.md)). Am gemergten Stand stehen **18** Einträge
über der Schwelle und tragen **keinen**:

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn | wc -l                                            #  18  über der Schwelle und offen
for d in docs/plan/planning/observations/BEO-*/*/; do
  printf '%s\n' "$(ls "$d"evidence 2>/dev/null | wc -l)"
done | awk '$1 >= 3' | wc -l                                       #  31  über der Schwelle
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l           # 114  Einträge gesamt
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, geschärft durch [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2) — die drei Zahlen wandern mit dem Baum; tragend ist die **Differenz**: 31 über der
Schwelle, 18 ohne Ausgang.

**Der Grund ist nicht Vergessen, sondern eine Form-Lücke — und die achtzehn sind keine eine
Klasse.** Gemessen:

```sh
cd docs/plan/planning/observations/BEO-ALL
n=0; tl=0; gap=0; kenn=0
for d in */; do
  c=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$c" -ge 3 ] || continue
  grep -q '^\*\*Stand:\*\* offen' "$d/state.md" || continue
  n=$((n+1))
  grep -qE 'Träger ist der Lauf' "$d/state.md" && tl=$((tl+1))
  grep -qE 'Wächter besteht nicht|kein Sensor|kein Modul|Kein Modul|Träger ist' "$d/state.md" && gap=$((gap+1))
  grep -qE 'slice-[0-9]|slice-[a-z]' "$d/state.md" && kenn=$((kenn+1))
done
printf '%s offen, %s woertlich "Traeger ist der Lauf", %s mit Luecken-Aussage, %s mit Slice-Kennung\n' "$n" "$tl" "$gap" "$kenn"
# 18 offen, 5 woertlich "Traeger ist der Lauf", 14 mit Luecken-Aussage, 3 mit Slice-Kennung
```

**Keine Erwartungswerte** — die vier Zahlen wandern mit dem Baum, und **die dritte ist ein
Muster, die Klasse dahinter ein Urteil**: ob eine Zeile eine Lücken-Aussage *trägt*, entscheidet
kein `grep` ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Tragend ist darum nicht die Zahl, sondern
die **Heterogenität** — eine benannte Lücke, ein bereits genannter Träger und ein Rumpf ganz ohne
Aussage stehen nebeneinander. Genau das ist der Grund, warum die Antwort **eine Regel** sein muß
und keine Handliste von achtzehn Ausgängen.

Für die Lücken-Form hat die geschlossene Menge der drei Ausgänge keinen offensichtlichen Platz:

- **verkörpert** verlangt einen **Zielort** und einen Herkunfts-Anker. Eine Lücke nennt einen
  **Lauf** als Träger; ob sie *zugleich* einen Zielort hat, ist genau die Frage.
- **geplant** verlangt die Kennung eines Slice oder einer Welle, die die Regel schreibt. Drei
  Einträge nennen eine; für die übrigen gibt es keine — und eine erfundene behauptete eine Datei,
  die es nicht gibt ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **gestrichen** verlangt, daß die Beobachtung nicht mehr auftreten kann. Bei Einträgen, die
  weiter Belege sammeln, ist das nachweislich falsch.

**Und der zweite Teil des Befundes ist eine Datums-Aussage — in der Gegenrichtung.** Der Eintrag
[`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
ist **nach** dem Lauf angelegt, der die Results-Notiz der
[`welle-15`](../done/welle-15-results.md) auf ihre Messungen zog, und stand damit nie unter dessen
Blick:

```sh
git log --diff-filter=A --format='%ci %h' -- docs/plan/planning/observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md
# 2026-09-05 20:43:05 +0200 8c9e3710
git log -1 --format='%ci %h %s' 86349419
# 2026-09-05 18:13:10 +0200 86349419 Rolle Planner: welle-15-Results -- drei Aussagen auf ihre Messung gezogen
```

Er ist damit **kein Durchfall jenes Laufes, sondern Zuwachs danach** — und stellt die zweite Frage
aus der anderen Richtung: ob der Gegenstand des Lese-Schritts der Bestand **zu seinem Zeitpunkt**
ist oder der seit dem letzten Lauf **hinzugekommene**. Der Befund trägt die Frage, nicht die
Antwort; **welche gilt, entscheidet dieser Slice.**

### Was der Slice entscheidet, und was er dafür nicht anfassen muß

Die vier Nachbareinträge sind **enger** und decken den Fall nicht — sie sind die Prüfliste, an der
die Entscheidung sich messen lassen muß:

| Nachbar | Zähler | was er mißt | warum er nicht deckt |
|---|---|---|---|
| [`BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle`](../observations/BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle/observation.md) | 2× | der Ausgang verlangt eine Handlung, die der Rolle der Closure **nicht zusteht** | eine **Rollen**-Frage; hier fehlt der Ausgang selbst, nicht seine Zuständigkeit |
| [`BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser`](../observations/BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser/observation.md) | 2× | ein Eintrag **mit** Ausgang, dessen weitere Belege keinen Leser haben | setzt einen Ausgang voraus |
| [`BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt`](../observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md) | 2× | die **Form** des Ausgangs ist prüfbar, sein **Tragen** nicht | setzt einen Ausgang voraus |
| [`BEO-ALL/benannte-luecke-ohne-ausgang`](../observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md) | 1× | wohin eine erledigte Grenz-Beschreibung wieder **verschwindet** | Prosa-Umfang in lebenden Artefakten, nicht der Register-Ausgang |

```sh
for s in schwellen-uebertritt-ohne-zustaendige-rolle beleg-nach-dem-ausgang-findet-keinen-leser \
         ausgang-nennt-traeger-der-nicht-traegt benannte-luecke-ohne-ausgang; do
  printf '%s  %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Sensor und keine Gate-Änderung.** Ein Wächter, der *„über der Schwelle ohne Ausgang"* rot
  färbt, ist der Liefergegenstand von
  [`slice-register-ueber-der-schwelle-bekommt-seinen-waechter`](../next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md)
  und hängt an der Regel, die hier erst entsteht. Rollen-Trennung nach Baseline-Regelwerk
  `modul-08-agentenrollen.md` §Rollen-Regeln: wer die Norm entscheidet, baut ihren Wächter nicht im
  selben Kontext. *Es wäre ein anderer Vorgang.*
- **Kein Nachzug der 18 Einträge.** Er ist mechanisch, sobald die Regel steht, und gehört damit
  hinter sie — ebenfalls in den Folge-Slice und, für die Einträge, die unter der neuen Regel einen
  bestehenden Zielort tragen, in den **Lese-Schritt** der nächsten Wellen-Closure. *Folge-Slice
  übernimmt es, mit Kennung.*
- **Keine Änderung an der vendored Baseline.** `modul-06-roadmap.md` liegt unverändert unter
  [`.harness/baseline/v6.8.0/`](../../../../.harness/baseline/v6.8.0/regelwerk/modul-06-roadmap.md#das-beobachtungs-register-modul-6)
  und ist nicht dieses Repos Arbeitsfläche; die Auslegung sitzt an dem Ort, der dieses Repo gehört.
  *Bestand bleibt bewusst stehen.*
- **Keine Änderung an der Verzeichnis-Form des Registers** (drei Dateien, ein Verzeichnis je
  Beobachtung, `evidence/<vorgangs-id>.md`). Sie ist in
  [ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  entschieden und trägt die Zählregel strukturell — „ein Vorgang zählt einmal" ist eine Eigenschaft
  des Dateisystems. *Es wäre ein anderer Vorgang.*
- **Kein Nachzug der Einträge *unter* der Schwelle.** Ihr Leser ist der Sichtungs-Schritt in §8
  jedes Slice-Plans, nicht der Lese-Schritt. *Schicht-Abgrenzung.*
- **Keine Änderung an [`welle-13`](../welle-13-regeln-bekommen-ihren-sensor.md) und keine
  Wiederholung ihres Lese-Schritts.** Diese Entscheidung ist die **Vorbedingung** dafür, nicht ihr
  Teil: Die Welle schließt nach diesem Slice, und ihr Lese-Schritt führt die Regel aus, statt sie zu
  erfinden. *Es wäre ein anderer Vorgang.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Zwei Liefer-Punkte:**

- [ ] **(1) Die Entscheidung steht und ist `Accepted`** — je eine Antwort auf die zwei offenen
      Fragen, mit der **Gegenposition** in §Verglichene Alternativen:
      **(a)** welchen Ausgang trägt eine Beobachtung über der Schwelle, deren Inhalt eine benannte
      Lücke ohne Träger ist — einer der drei, ein vierter, oder keiner (mit der Folge, die dann
      gilt)? **(b)** liest der Lese-Schritt **alle** Einträge über der Schwelle oder nur die **neu
      übergetretenen**? Beide Antworten sind am Befund oben gemessen, nicht am Wortlaut allein.
      *Ist die Antwort „ein vierter Ausgang" oder „nur die neu übergetretenen", ist das eine
      Änderung an einer geschlossenen Menge bzw. am Lese-Gegenstand und damit nach
      [`AGENTS.md`](../../../../AGENTS.md) §3.5 ADR-pflichtig — genau der Träger, den dieser
      Punkt verlangt.*
- [ ] **(2) Die Regel steht an ihrem Ort und trägt ihren Herkunfts-Anker** — die Ausgangs-Tabelle
      in [`observations/README.md`](../observations/README.md) (und, falls die Entscheidung dort
      sitzt, [`harness/conventions.md`](../../../../harness/conventions.md)) sagt, was gilt;
      der Anker ist `seit slice-<Kennung>` nach `grundlagen-traceability.md` §Herkunfts-Anker.
      **Zwei Ausgänge erfüllen den Punkt:** die nachgezogene Regel, oder — wenn die Entscheidung
      ergibt, daß der Wortlaut bereits trägt — ein Satz, der das **belegt** und den Befund als
      Vollzugs-Lücke benennt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Liefer-Punkt (2) **ist** dieses Item — der Träger ist die Register-Regel.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein
      Erwartungswert), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne
      Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/<NNNN>-…` | neu | Liefer-Punkt (1) — die Entscheidung; Kennung und Titel vergibt der Architect |
| [`docs/plan/planning/observations/README.md`](../observations/README.md) | update | Liefer-Punkt (2) — die Ausgangs-Tabelle ist der Ort, an dem dieses Repo die Regel führt |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update *(nur falls)* | nur wenn die Entscheidung eine Abweichung von der Baseline setzt und damit einen Adaptions-Eintrag braucht |
| `docs/plan/adr/README.md` | update | der ADR-Index folgt der neuen ADR (`AGENTS.md` §5) |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Liefergegenstand ist eine **Regel** für zwei
inferentielle Leser; die maschinelle Hälfte — der Sensor — ist ausdrücklich der Folge-Slice (§1).
Ein Test daneben hielte den Regeltext gegen eine zweite Fassung seiner selbst.

**Und keine Gate-Zusage.** Dieser Slice darf in keinem Satz behaupten, die Klasse sei bewacht; die
Prüfung *„über der Schwelle ohne Ausgang"* hat bis zum Folge-Slice keinen Träger, und das steht
benannt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice** (WIP frei), und der
Lese-Schritt der [`welle-13`](../welle-13-regeln-bekommen-ihren-sensor.md) ist **angehalten** — er
kann seinen Gegenstand nicht abschließen, solange diese Regel fehlt. Beobachtbar ohne Rückfrage:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'        # 0  (WIP frei)
ls docs/plan/planning/done/welle-13-results.md                # existiert nicht -> Welle offen
```

**Der Trigger ist kein Ergebnis dieses Slice** — die zweite Bedingung spricht über den Bestand
*vor* der Arbeit und über eine **andere** Einheit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Die Entscheidung verlangt mehr als eine
  Regel-Zeile** — etwa weil die Ausgangs-Menge selbst, die Verzeichnis-Form oder die zwei Leser
  zusammen neu zu schneiden sind. Dann ist das ein eigener Gegenstand und dieser Schnitt falsch.
- `in-progress` → `open` (blockiert — Carveout?): **Eine Quelle spricht gegen die Zuständigkeit** —
  etwa weil ein Nachbar-Repo (`/Development/d-check`, `/Development/a-check`) dieselbe Frage
  bereits entschieden hat und die Übernahme vor der eigenen Entscheidung zu klären ist; oder weil
  die Frage nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 einer anderen schreibenden Rolle gehört
  als der hier benannten.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Der Lauf, der den Befund erhob, ist nach der Entscheidung wiederholbar** — dieselben drei
   Kommandos aus §1 liefern danach **null** Einträge über der Schwelle ohne Ausgang *oder* die
   Zahl, die die neue Regel zuläßt; die Zahl steht im Commit mit ihrem Kommando
   ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
   Setzung 1), und `make gates` meldet Exit 0.
2. **Die Entscheidung nennt ihre Gegenposition und einen Auflösungs-Trigger** — eine `Accepted`-ADR
   ohne Re-Evaluierungs-Trigger ist nach Baseline-Regelwerk `modul-04-adrs.md` unvollständig; ist
   der Ausgang *keine* ADR, trägt §7 den Grund und den Träger, der die Frage stattdessen hält.

**Lerneintrag:** die Form entscheidet die Closure und nicht dieser Plan. Wurde mit diesem Slice
eine Regel aus der 3×-Schwelle verkörpert, trägt der Eintrag `liegt in <Zielort>`; ein Satz, der
aus dem Wortlaut der Baseline folgt, trägt bereits seine ID und braucht keinen zweiten Anker.
Die **Auslöser-Beobachtung** ist
[`BEO-ALL/benannte-luecke-ohne-ausgang`](../observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md)
— sie ist zu **zitieren**, nicht neu zu formulieren.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Entscheidung wird zur stillen Senkung.** Führt sie einen vierten Ausgang ein oder
  verengt sie den Lese-Gegenstand auf „nur neu übergetretene", ist das eine Lockerung der
  geschlossenen Menge bzw. des Prüfumfangs und nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 ADR-pflichtig. **Gegenmittel im Plan:** Liefer-Punkt
  (1) verlangt die ADR für genau diese zwei Antworten ausdrücklich.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Die Entscheidung wird aus dem Wortlaut abgeleitet, statt am Befund gemessen.** Beide
  Antworten hängen an denselben 18 Einträgen und dem einen datierten Durchfall; wer die Zahlen
  nicht neu fährt, entscheidet über einen Bestand, den er nicht gesehen hat. **Gegenmittel im
  Plan:** Liefer-Punkt (1) verlangt die Messung am Befund, und beide Kommandos stehen in §1.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) Die Nachbar-Repos haben die Frage bereits entschieden, und die Antwort fällt anders aus.**
  `/Development/d-check` und `/Development/a-check` fahren dieselbe Baseline und dieselbe
  Rollen-Sequenz; eine übernommene **Form** ohne eigene Messung wäre eine Zusammenfassung, die
  stärker ist als ihre Quelle — die gemessene Klasse
  [`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md).
  **Gegenmittel im Plan:** §4 nennt den Fall als Rückführung `in-progress → open`.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes der drei mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln
(Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register, hier verkörpert in
[`observations/README.md`](../observations/README.md)), eigener Prüfbereich (der Lese-Schritt der
Wellen-Closure und der Sichtungs-Schritt in §8 jedes Slice-Plans) und eigene Fehlermodi (ein
Eintrag über der Schwelle ohne Ausgang). **`TOOLS` und `CODEX` sind geprüft und nicht berührt:**
Keine Aussage über `harness/tools/` oder `.codex/` ändert sich.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**114** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. **Zehn Einträge** berühren diesen Slice — vier davon sind die
Nachbar-Klassen aus §1, sechs der Gegenstand selbst:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `benannte-luecke-ohne-ausgang` | 1× | offen | §1 — die Klasse, die die Form-Lücke benennt; zitierter Auslöser in §5 |
| `schwellen-uebertritt-ohne-zustaendige-rolle` | 2× | offen | §1 — die Rollen-Hälfte derselben Übertritts-Frage |
| `beleg-nach-dem-ausgang-findet-keinen-leser` | 2× | offen | §1 — was nach einem Ausgang gilt; die Entscheidung berührt ihn |
| `ausgang-nennt-traeger-der-nicht-traegt` | 2× | offen | §1 — die Form-Hälfte; eine neue Form darf sie nicht wiederholen |
| `register-paarung-ohne-gate-modul` | 1× | offen | §1 — die maschinelle Hälfte; der Sensor des Folge-Slice ist der nächste Anlauf |
| `registerzeile-ohne-traeger-spalte` | 1× | offen | §2 Liefer-Punkt (2) — was die Regel tragen muß, damit ein Träger in sie paßt |
| `ueberholter-offener-plan-ohne-genormten-ausgang` | 1× | offen | §1 — dieselbe Form-Lücke für **Pläne** statt Einträge; bleibt dort |
| `unbelegter-register-eintrag-faellt-durch-die-paarung` | 1× | offen | §1 — die Beleg-Hälfte, nicht der Ausgang |
| `sichtungs-schritt-zitiert-falschen-zaehler-stand` | 3× | verkörpert | §8 — der Zähler-Stand dieser Sichtung trägt Kommando und Maß ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 2) |
| `zaehler-label-nennt-falsche-einheit` | 3× | offen | §1 — einer der 18; die Entscheidung bestimmt seinen Ausgang mit |

```sh
for s in benannte-luecke-ohne-ausgang schwellen-uebertritt-ohne-zustaendige-rolle \
         beleg-nach-dem-ausgang-findet-keinen-leser ausgang-nennt-traeger-der-nicht-traegt \
         register-paarung-ohne-gate-modul registerzeile-ohne-traeger-spalte \
         ueberholter-offener-plan-ohne-genormten-ausgang unbelegter-register-eintrag-faellt-durch-die-paarung \
         sichtungs-schritt-zitiert-falschen-zaehler-stand zaehler-label-nennt-falsche-einheit; do
  printf '%s  %s  %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" \
    "$(grep -m1 -oE '(offen|verkörpert|geplant|gestrichen)' docs/plan/planning/observations/BEO-ALL/$s/state.md)" "$s"
done
```

**Keiner der zehn erreicht mit diesem Slice 3×** — vier stehen bei 1×, vier bei 2×, zwei bereits
darüber. **Ein eigener Folge-Slice entsteht aus der Sichtung also nicht**; der eine Träger, den
dieser Plan schneidet, ist der Folge-Slice der DoD, nicht der Sichtung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — was einen Eintrag ausmacht, wer schreibt, wer liest und welche
  drei Ausgänge es gibt, steht ausgeschrieben in
  [`observations/README.md`](../observations/README.md); die Kennung als Pfad in
  [ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 3; der Baseline-Wortlaut in `modul-06-roadmap.md` §Das Beobachtungs-Register.
- **Phase-Reife:** Phase 4 für die Register-Doku — Form, Leser und Schwellen-Folgerung sind
  dekretiert; der Ausgangs-Rand ist der offene Teil, und genau er ist dieser Slice.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig, aber nicht null.** Es gibt keine Inventur-Lücke: die
  18 sind ein `ls`, kein Urteil. Das Risiko ist ein anderes — die Entscheidung könnte den eigenen
  Befund schon für erledigt halten. Deshalb verlangt Liefer-Punkt (1) die Messung am Befund.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund; die Datei `reconciliation.md`
  existiert in diesem Repo nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das
  zugehörige DoD-Item entfällt deshalb in §2. Graduation entfällt (n/a bei GF).

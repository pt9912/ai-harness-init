# ADR-0041: Der wellenlose Altbestand geht in ein einzelnes Sammel-Archiv — keine Welle sammelt ihn ein

**Status:** Proposed

**Datum:** 2026-09-12

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
dieses Repos meldet einen geschlossenen Slice ohne Archiv — die Lücke wird benannt, nicht
behauptet),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Pflicht kommt aus dem
auf einen Tag gepinnten vendored Baum; welcher Tag gemessen ist, steht an jeder Zitatstelle),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — der Träger der
Archivierung; diese Entscheidung lässt ihn unberührt und beantwortet eine Frage daneben),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — woran der
Lauf sich hält, der diese Datei auf `Accepted` setzt),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (**Accepted** — Festlegung 4:
die Entscheidung über eine eingefrorene Adresse gehört **vor** den vorgeschriebenen Ortswechsel;
der Ortswechsel, den diese Entscheidung anordnet, fällt darunter),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form, in der hier aus dem
Regelwerk zitiert wird),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum, aus dem die zitierte Regel stammt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Aussage über die Baseline nennt ihren Tag).

**Schärft:** `—` — Prozess-Entscheidung ohne Spec-Stratum. Sie ordnet die Zeitdokumente des
Planning-Lifecycle, nicht eine Eigenschaft des Produkts.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

### Was die Entscheidung auslöst

Die adoptierte Baseline `v6.5.0` delegiert in `modul-06-roadmap.md` §Wellen-Closure-Prozedur,
Schritt 4, **genau eine** Frage an das Repo — und benennt zwei Formen, zwischen denen es wählt:

> *„Kein Zwang zum Nachrüsten — und kein Verbot: Wellen, die vor der Einführung schlossen, müssen
> nicht archiviert werden; ein Repo bleibt ohne das konform. Wer den Altbestand loswerden will,
> führt die Archivierung als eigenen Vorgang aus, je geschlossener Welle einmal. Sie braucht dafür
> eine Entscheidung, die die laufende Regel nicht liefert: welche Welle die Slices einsammelt, die
> keiner angehören. Das Repo benennt die Zuordnung — die chronologisch nächste geschlossene Welle
> oder ein einzelnes Sammel-Archiv für den Bestand vor der Einführung."*

Nachzulesen mit

```sh
grep -n 'welche Welle die Slices einsammelt' .harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md
```

Die Quelle sagt *„benennt"*, nicht *„wägt ab"*. **Eine Abwägung liegt trotzdem vor, und sie ist
gemessen statt vermutet** (§Was heute gemessen ist): Die zwei benannten Formen unterscheiden sich
in diesem Repo nicht in Geschmack, sondern in **Ausführbarkeit** — eine von ihnen ist mit dem
gebauten Werkzeug nicht darstellbar. Dazu tritt die dritte Option, die jede ADR führen muss und
die die Quelle hier ausdrücklich offenhält: nichts tun.

### Wann die Frage fällig wurde

Der Zustand ist beobachtbar und braucht keine Erzählung: Dieses Repo fährt Wellen, und **keine**
seiner geschlossenen Wellen hat Schritt 4 je ausgeführt.

```sh
ls docs/plan/planning/welle-*.md | wc -l                        #  3  flach = offen/geschnitten
ls docs/plan/planning/done/welle-*-results.md | wc -l           # 12  geschlossen
ls -d docs/plan/planning/done/welle-*/ 2>/dev/null | wc -l      #  0  archiviert
```

**Keine Erwartungswerte** — jede Zahl wandert mit dem Bestand. Damit hat **kein** wellenlos
geschlossener Slice dieses Repos je eine Closure gehabt, die ihn hätte einsammeln können; der
Altbestand ist nicht liegengeblieben, sondern hatte nie einen Adressaten.

### Was heute gemessen ist

**(1) Der Altbestand.**

```sh
n=0; for f in docs/plan/planning/done/slice-*.md; do \
  grep -q '^\*\*Welle:\*\* ohne Welle' "$f" && n=$((n+1)); done; echo "$n"   #  57
ls docs/plan/planning/done/slice-*.md | wc -l                                # 148
```

**(2) Das Werkzeug sammelt wellen-unabhängig ein — der tragende Befund.** `internal/archive`
entscheidet die Klasse eines Slice allein am Kopf-Feld `**Welle:**`; einen Zeitfilter führt es
nicht. Gemessen an der **ersten** geschlossenen Welle, deren Ergebnisnotiz vier eigene Slices
trägt, mit dem Träger aus [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 1
(`make host-bin` davor):

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau welle-01
#   Mitglieder (Welle-Feld nennt welle-01):   4
#   wellenlos (seit der letzten Closure):    57
#   fremd (andere Welle, bleibt liegen):     87
#   Review-Reports (ohne Stub):             150
#   Sperren: 2 — der schreibende Lauf braeche ab.   (Exit 3)
```

Dieselben **57** stehen in der Vorschau jeder anderen Welle. Die Grenze *„seit der letzten
Closure"* entsteht **strukturell** und nicht rechnerisch: Ein archivierter Slice liegt als Stub
unter `done/<schlüssel>/` und damit nicht mehr flach, wo der Einsammel-Lauf sucht. Solange nichts
archiviert ist, gibt es diese Grenze nicht — und genau darauf sperrt der Lauf fail-closed
(`[untergrenze]`).

**(3) Die Sperre trifft jede Welle, nicht eine bestimmte.** Sie feuert, solange mindestens ein
wellenloser Slice flach liegt und kein `done/*/archiv.zip` existiert. Beide Bedingungen sind heute
für **jede** der 12 geschlossenen Wellen erfüllt. Die erste Archivierung dieses Repos ist damit
nicht verzögert, sondern **verschlossen**, bis diese Frage entschieden ist.

**(4) Was die erste benannte Form in diesem Repo bedeutete.** *„Die chronologisch nächste
geschlossene Welle"* ist eine Zuordnung je Slice. Sie ist rekonstruierbar — aber nur aus `git`,
nicht aus einem Artefakt:

```sh
closures=$(for f in docs/plan/planning/done/welle-*-results.md; do \
  printf '%s %s\n' "$(git log --diff-filter=A --format=%as -- "$f"|tail -1)" \
                   "$(basename "$f" -results.md)"; done | sort)
for f in docs/plan/planning/done/slice-*.md; do \
  grep -q '^\*\*Welle:\*\* ohne Welle' "$f" || continue; \
  d=$(git log --diff-filter=A --format=%as -- "$f"|tail -1); \
  echo "$closures" | awk -v d="$d" '$1>=d{print $2;exit}'; done | sort | uniq -c
#   6 welle-01 · 6 welle-02 · 1 welle-03 · 1 welle-05 · 1 welle-06
#   2 welle-07 · 7 welle-08 · 11 welle-10 · 10 welle-12 · 3 welle-15
```

**48** der 57 bekämen so einen Adressaten, verteilt über **10** der 12 Wellen; **9** blieben ohne,
weil sie nach der letzten Closure geschlossen wurden. Und die Reihenfolge trägt nicht: Die Wellen
dieses Repos schließen **nicht** in ihrer Nummern-Folge —

```sh
for f in docs/plan/planning/done/welle-*-results.md; do \
  printf '%s  %s\n' "$(git log --diff-filter=A --format=%as -- "$f"|tail -1)" "${f##*/}"; done | sort | tail -4
#   2026-08-27  welle-12-results.md
#   2026-09-03  welle-10-results.md
#   2026-09-03  welle-14-results.md
#   2026-09-05  welle-15-results.md
```

**Keine Erwartungswerte**, alle vier Blöcke wandern mit dem Bestand.

**(5) Die Vorbedingung, die diese Entscheidung nicht löst.** Die zweite Sperre des Laufs oben ist
`[haenger]`: Ein Review-Report soll verschwinden, auf den noch verwiesen wird. Der Bestand solcher
Ziele ist groß und liegt auch in Artefakten, die [`AGENTS.md`](../../../AGENTS.md) §3.4 einfriert —
angenommene ADRs, aufgelöste Carveouts, Zeitdokumente unter `done/`:

```sh
n=0; for r in docs/reviews/*.md; do rb="${r##*/}"; \
  h=$(git grep -lF -e "]($rb)" -e "](docs/reviews/$rb)" -e "](../reviews/$rb)" \
        -e "](../../reviews/$rb)" -- ':!.harness/baseline' | grep -vxF "$r" | wc -l); \
  [ "$h" -gt 0 ] && n=$((n+1)); done; echo "$n von $(ls docs/reviews/*.md|wc -l)"   # 153 von 347
```

Ob der Verweis-Nachzug in ein eingefrorenes Artefakt schreiben darf, ist eine offene Norm-Frage mit
eigenem Zähler im Beobachtungs-Register
([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md);
`ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/*.md | wc -l`
→ **12**, kein Erwartungswert). Sie gehört nach [`AGENTS.md`](../../../AGENTS.md) §3.8 dem
Architect und wird **hier nicht** beantwortet — diese Entscheidung ordnet die Zuordnung, nicht den
Vollzug. Festlegung 4 bindet beides aneinander, statt den Widerspruch offenzulassen.

**(6) Was ein Schlüssel ohne Welle heute tut.** Gemessen mit demselben Träger, gegen den Schlüssel,
den Festlegung 2 setzt:

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand
#   Mitglieder (Welle-Feld nennt altbestand):   0
#   wellenlos (seit der letzten Closure):      57
#   Review-Reports (ohne Stub):               144
#   Sperren: 5 — der schreibende Lauf braeche ab.   (Exit 3)
#     [unsauber] [ergebnisnotiz] [kein-plan] [untergrenze] [haenger]
```

Die Einsammel-Zahlen sind bereits richtig: Der Schlüssel zieht **keine** Mitglieder und genau den
wellenlosen Bestand. Von den fünf Sperren hängen drei an der Welle-Form und eine an der fehlenden
Untergrenze — sie sind der Gegenstand von Folgepflicht 1; `[unsauber]` ist der Arbeitsbaum des
messenden Laufs und keine Eigenschaft des Schlüssels, und `[haenger]` ist die Vorbedingung aus (5),
die stehen bleiben **muss**.

### Annahmen, auf denen diese Entscheidung steht

Kippt eine, kippt die Entscheidung; beide stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Dieses Repo fährt Wellen. Fällt das, ist die Träger-Tabelle für den Betrieb *ohne* Wellen
  einschlägig (`v6.5.0`, `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht), und die
  Archivierung bekommt einen anderen Auslöser und einen anderen Schlüssel.
- **(b)** Der Ortswechsel unter `done/` bleibt überhaupt zulässig — die Vorbedingung aus (5) findet
  einen Ausgang. Fällt das, fällt der Vollzug, und die Zuordnung hat keinen Gegenstand mehr.

## Entscheidung

**Wir wählen Alternative B: der wellenlose Altbestand geht in ein einzelnes Sammel-Archiv. Keine
Welle sammelt ihn ein.** Fünf Festlegungen.

**1. Der wellenlose Altbestand dieses Repos wird archiviert, und keine Welle ist sein Schlüssel.**
Die Freistellung der Quelle wird damit **nicht** in Anspruch genommen und auch nicht ausgelegt: Ob
*„Wellen, die vor der Einführung schlossen"* auch den wellenlosen Bestand freistellt, sagt die
Quelle nicht — und diese Entscheidung muss es nicht wissen, weil sie archiviert statt freizustellen.
Wer den anderen Weg wählte, müsste die Freistellung über ihren Wortlaut hinaus ausdehnen; das ist
die Fehlform, die
[`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
führt.

**2. Der Schlüssel ist `altbestand`; das Archiv liegt unter
[`docs/plan/planning/done/`](../planning/done) in dem Verzeichnis, das diesen Schlüssel trägt, als
`archiv.zip` neben den Stubs der eingesammelten Slices.**
Dieselbe Form, die die Ziel-Fassung für `done/<welle-id>/` vorschreibt — Archiv, gekürzte Stubs aus
der vendored Vorlage, Verweis-Nachzug —, nur mit einem Schlüssel, der keine Welle **ist** und
keine behauptet. Der Schlüssel ist ortsfest und wird nicht wiederverwendet: Er trägt genau einen
Lauf.

**3. Die Grenze ist der Lauf, nicht ein Datum.** Eingesammelt wird jeder wellenlos geschlossene
Slice, der zum Zeitpunkt des Laufs **flach** in `docs/plan/planning/done/` liegt. Das ist dieselbe
Grenze, die die laufende Regel schon trägt: *„wellenlos seit der letzten Closure"* ist im Werkzeug
kein Zeitvergleich, sondern die Verzeichnis-Position (§Was heute gemessen ist, Punkt 2). Ein
Datums-Schnitt setzte eine **zweite** Definition derselben Grenze daneben, und sie wäre nach dem
Move nicht mehr nachrechenbar — die Add-Zeit einer Datei unter `done/` wandert mit dem Move, aus
dem sie gelesen würde. Der Preis steht in §Konsequenzen: Das Sammel-Archiv nimmt auch die Slices
mit, die nach dem Erscheinen der Regel schlossen. Sie hatten nach §Wann die Frage fällig wurde
keinen anderen Adressaten.

**4. Der Vollzug ist an den Ausgang der eingehenden Verweise auf Review-Reports gebunden.** Diese
Entscheidung ordnet die Zuordnung; sie eröffnet den schreibenden Lauf **nicht**. Solange die
Norm-Frage aus §Kontext (5) offen ist, bleibt die `[haenger]`-Sperre stehen, und das ist die
richtige Reihenfolge — [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
Festlegung 4 verlangt die Entscheidung über eine eingefrorene Adresse **vor** dem vorgeschriebenen
Ortswechsel, [`AGENTS.md`](../../../AGENTS.md) §3.11 trägt dieselbe Linie repo-weit.

**5. Nach dem Sammel-Archiv trägt die laufende Regel ohne weitere Zuordnung.** Das Archiv aus
Festlegung 2 ist die beobachtbare Untergrenze, die heute fehlt; von da an sammelt jede
Welle-Closure die seither wellenlos geschlossenen Slices mit ihren Mitgliedern ein, wie die
Ziel-Fassung es vorschreibt. **Diese Entscheidung wiederholt sich nicht:** Sie gilt dem Bestand
ohne Adressaten, und den gibt es nach ihrem Vollzug nicht mehr.

**Was diese Entscheidung nicht tut.**

- **Kein `Supersedes` auf [ADR-0033](0033-wellen-archivierung-als-unterkommando.md).** Deren
  Festlegung 1 — Träger ist das Produkt-Binär — bleibt unberührt und ist die Voraussetzung, auf der
  Festlegung 2 oben steht. Von ihren Re-Evaluierungs-Triggern ist einer gefeuert (die Baseline
  benennt den Träger für den wellenlosen Fall selbst); ein gefeuerter Trigger verlangt eine
  Entscheidung **daneben**, nicht eine Änderung an der eingefrorenen Datei
  ([`AGENTS.md`](../../../AGENTS.md) §3.4). Ihr zweiter Trigger — *„wenn ein Repo ohne
  Wellen-Betrieb die Archivierung braucht"* — trifft dieses Repo nicht; die Messung dazu steht in
  §Wann die Frage fällig wurde.
- **Sie baut keine Werkzeug-Fähigkeit und schneidet keinen Slice.** Was fehlt, steht als
  Folgepflicht in §Konsequenzen — beschrieben über die Eigenschaft, nicht über eine Kennung, die
  ein Re-Schnitt bewegt.
- **Sie entscheidet nicht, ob ein Verweis-Nachzug in ein eingefrorenes Artefakt schreiben darf.**
  Festlegung 4 wartet auf jene Entscheidung, statt sie vorwegzunehmen.
- **Sie sagt nichts über ein emittiertes Repo.** Der Geltungsbereich ist dieses Repo; was ein
  Zielrepo an Zuordnungs-Aussagen bekommt, entscheidet der Vorgang, der die Tool-Ebene entscheidet.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) und die zitierte Stelle der
adoptierten Baseline `v6.5.0` auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund
in `docs/reviews/` liegt.** Meldet eine Runde einen blockierenden Befund, ist der Beleg nach
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 eine **erneute**
Runde derselben prüfenden Rolle; die Nachmessung durch den Kontext, der den Befund auflöste, ist
keiner. Die Accept-Zeile der §Geschichte nennt diesen Beleg als Kennung
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1).

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon.
Eine ADR ohne Alternativen ist ein Postulat, kein Entscheidungsprotokoll, und im Review nicht
verteidigbar (Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — Die chronologisch nächste geschlossene Welle sammelt ein | Von der Quelle benannt. Jeder wellenlose Slice läge am Ende neben der Welle, die nach seiner Closure schloss; kein neuer Schlüssel unter `done/` | **Gemessen nicht darstellbar.** Das Werkzeug klassifiziert allein am Kopf-Feld und kennt keinen Zeitfilter: Die erste Archivierung nähme **alle** 57 mit, gleich welche Welle sie nennt (§Kontext, Punkt 2). Die Zuordnung lebte in `git` statt in einem Artefakt und wäre nach dem Move nicht mehr nachrechenbar; **9** der 57 hätten gar keinen Adressaten, und die Wellen schließen nicht in Nummern-Folge, so dass die entstehende Archiv-Folge nicht datums-monoton wäre. Verlangt eine Werkzeug-Fähigkeit, deren Urteil je Slice im Werkzeug säße |
| **B — Ein einzelnes Sammel-Archiv für den Bestand ohne Adressaten (gewählt)** | Ein Schlüssel, ein Lauf, kein Urteil je Slice. Das Archiv behauptet nichts über eine Welle, der die Vorgänge nicht angehören. Es setzt die Untergrenze, die die laufende Regel braucht, und macht sich damit selbst überflüssig (Festlegung 5). Die Freistellung der Quelle muss nicht ausgelegt werden (Festlegung 1) | Braucht einen Schlüssel unter `done/`, der keine Welle ist — das Werkzeug verlangt heute zu seiner Kennung einen Welle-Plan und eine Ergebnisnotiz in `done/` und sperrt sonst (gemessen, §Kontext Punkt 6). Die Betriebsart fehlt und steht als Folgepflicht. Und die Grenze *Lauf statt Datum* nimmt Slices mit, die nach dem Erscheinen der Regel schlossen |
| C — Nichts tun: der wellenlose Altbestand bleibt flach liegen | Von der Quelle ausdrücklich freigestellt (*„ein Repo bleibt ohne das konform"*). Kostet nichts und schreibt in kein eingefrorenes Artefakt — die offene Norm-Frage aus §Kontext (5) bliebe unberührt | **Ist nicht „an einer Stelle nichts tun", sondern „nie archivieren".** Die `[untergrenze]`-Sperre feuert für **jede** Welle, solange ein wellenloser Slice flach liegt (§Kontext, Punkt 3): Der unter [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) gebaute Träger bliebe in diesem Repo dauerhaft unbenutzbar. Und die Freistellung trägt die Last nicht, die diese Option ihr auflädt — sie spricht von *Wellen*, nicht vom wellenlosen Bestand |
| D — Je wellenlosem Slice ein eigenes Archiv in einer stehenden Ablage | Löst die Zuordnungs-Frage auf, statt sie zu beantworten: Schlüssel ist der Slice, keine Welle muss einen fremden Vorgang beanspruchen. Es ist die Form, die die Ziel-Fassung dem Betrieb **ohne** Wellen gibt, und ein Nachbar-Repo desselben Nutzers hat sie gebaut | Dieses Repo fährt Wellen (§Wann die Frage fällig wurde); die Träger-Tabelle, aus der diese Form stammt, gilt ausdrücklich dem Repo *ohne* Wellen — sie hier zu übernehmen wäre die transitive Vereinfachung, vor der dieselbe Quelle warnt. Sie vervielfacht den Preis der offenen Vorbedingung: **57** Läufe mit je eigenem Verweis-Nachzug statt einem. Und sie verlangt eine zweite Werkzeug-Betriebsart neben der, die B braucht |

## Konsequenzen

- **Positiv:** Die erste Archivierung dieses Repos wird überhaupt erreichbar — heute ist sie
  fail-closed verschlossen, und zwar für jede Welle. Nach dem Sammel-Lauf trägt die laufende Regel
  ohne weitere Entscheidung, und der Vorgang wiederholt sich nicht.
- **Positiv:** Kein Archiv behauptet eine Zugehörigkeit, die es nicht gibt. Der Stub eines
  Welle-Plans trägt nach der Ziel-Fassung *„die Zahl der archivierten Vorgänge"*; unter Option A
  stünde dort eine Zahl, die zum Ziel und zum Inhalt jener Welle nichts sagt.
- **Negativ:** `done/` bekommt einen Schlüssel, den das Regelwerk nicht kennt. Er ist einmalig und
  ortsfest, aber er ist eine Repo-Form neben der Ziel-Form, und ein Sensor, der `done/<welle-id>/`
  als Muster führte, sähe ihn nicht.
- **Negativ:** Die Grenze *Lauf statt Datum* nimmt auch die wellenlosen Slices mit, die nach dem
  Erscheinen der Regel schlossen. Der Gegenposten ist die einzige Alternative — ein Datums-Schnitt
  mit zweiter Grenz-Definition und einer Rekonstruktion aus `git`, die der Move selbst zerstört.
- **Negativ:** Mit dem Move verlassen die eingesammelten Slice-Dateien den Prüfbereich der
  `closure`-Fähigkeit des Doku-Gates. Er greift nicht rekursiv
  (`sed -n '/^planning:/,/^[a-z]/p' .d-check.yml` → `closure.dir: docs/plan/planning/done`), und
  der Gate bliebe darüber **grün, ohne noch etwas zu prüfen**. Die Ziel-Fassung verlangt an dieser
  Stelle, den Geltungsbereich mitzuziehen **oder** zu benennen, dass die Zusage für Stubs nicht
  mehr gilt; welche der beiden, entscheidet der Vorgang, der archiviert. Die Lage ist in
  [`harness/README.md`](../../../harness/README.md) bereits geführt und wird von dieser
  Entscheidung nicht geschlossen.
- **Folgepflicht 1 (Werkzeug):** Ein Slice gibt dem Unterkommando die Betriebsart für einen
  Schlüssel ohne Welle. Sie hebt genau die Ausgänge auf, die an der Welle-Form hängen — die zwei um
  den Welle-Plan und den um die Ergebnisnotiz — sowie `untergrenze`, dem Festlegung 3 den
  Gegenstand nimmt; die übrigen bleiben stehen, **einschließlich `haenger`**, denn der ist der
  Träger von Festlegung 4 und darf nicht mit aufgehen. Wie viele Ausgänge es insgesamt sind, sagt
  `grep -c 'Kennung: "' internal/archive/vorschau.go` (**8**, kein Erwartungswert). Die Kennung des
  Slice steht hier **nicht**: Ein Re-Schnitt bewegt sie, und diese Datei friert ab `Accepted` ein
  ([`AGENTS.md`](../../../AGENTS.md) §3.11).
- **Folgepflicht 2 (Reihenfolge):** Der Vollzug setzt den Ausgang der Norm-Frage aus §Kontext (5)
  voraus. Wird dort entschieden, dass der Nachzug in eingefrorene Artefakte nicht schreiben darf,
  ohne dass ein anderer Weg eröffnet wird, fällt Annahme (b) — siehe Re-Evaluierungs-Trigger.
- **Folgepflicht 3 (Sensor-Geltungsbereich):** Vor dem ersten schreibenden Lauf wird der
  Prüfbereich der `closure`-Fähigkeit nachgezogen oder seine Grenze an der Stelle benannt, an der
  die Zusage heute steht.

## Fitness Function (falls maschinell prüfbar)

**Keine Zeile ist eingelöst, und das ist ein gemessener Zustand, keine Absicht.** Kein Modul des
Doku-Gates meldet einen geschlossenen Slice ohne Archiv oder ein zweites Sammel-Archiv
(`grep -n '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans, planning,
targets`), und `make mutate` kennt keine Fehlschlag-Form dafür. Eine Zeile, die hier einen
vorhandenen Wächter behauptete, wäre
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
tiefer.

| Tooling | Regel | Make-Target |
| --- | --- | --- |
| `ai-harness-init archive-welle --vorschau` | **Festlegung 3 — die Grenze ist beobachtbar.** Solange kein `done/*/archiv.zip` liegt, sperrt jeder Lauf mit `[untergrenze]`; danach sperrt keiner mehr aus diesem Grund. **Vorhanden, aber kein Gate** und in keiner Prerequisite-Kette — die Vorschau prüft die Vorbedingungen *einer Operation*, nicht den Zustand des Repos. Rot gesehen ist die Sperre am ruhenden Baum (§Kontext, Punkte 2 und 6); die Gegenrichtung ist erst nach dem Sammel-Lauf beobachtbar | — |
| `make test` · `make mutate` | **Festlegung 2 und 4 — der Schlüssel ohne Welle trägt, und `haenger` bleibt stehen.** Die Betriebsart aus Folgepflicht 1 hebt die vier welle- bzw. untergrenzen-gebundenen Ausgänge auf und keinen weiteren. **Rot zu sehen wäre:** `haenger` mit aufheben — dann muss ein Fall fallen, denn Festlegung 4 hängt allein an ihm. **Geschuldet, nicht geliefert** — die Betriebsart existiert nicht (§Kontext, Punkt 6) | `make test`, `make mutate` |
| `make docs-check` | **Folgepflicht 3 — der Prüfbereich der `closure`-Fähigkeit deckt, was er zusagt.** **Geschuldet, nicht geliefert** — `closure.dir` greift nicht rekursiv, und die Zusage gilt heute nur dem flachen Bestand | `make docs-check` |
| — | **Nicht maschinell prüfbar, und darum hier ohne Zeile:** dass der Schlüssel aus Festlegung 2 nur einen Lauf trägt. Ein zweiter Lauf über demselben Schlüssel bricht an `archiviert` ab — dass niemand einen **dritten** Schlüssel erfindet, bewacht nichts; es wird ausgesprochen, nicht bewacht | — |

## Re-Evaluierungs-Trigger

- **Wenn die Baseline die Zuordnung selbst festlegt oder Schritt 4 aus der Wellen-Closure
  entfernt** *(feedforward — fremder Vertrag, sichtbar beim Freshness-Audit der nächsten
  Re-Baseline)*: Der Gegenstand dieser Entscheidung wechselt oder entfällt.
- **Wenn dieses Repo aufhört, Wellen zu fahren** — beobachtbar daran, dass keine flache
  `docs/plan/planning/welle-*.md` mehr liegt und die Roadmap unter *Nächste Wellen* keine Zeile
  mehr führt: Annahme (a) fällt. Dann ist die Träger-Tabelle für den Betrieb ohne Wellen
  einschlägig, und Schlüssel wie Auslöser sind neu zu stellen; Alternative D steht dafür bereit.
- **Wenn die Norm-Frage aus §Kontext (5) den Verweis-Nachzug in eingefrorene Artefakte untersagt,
  ohne einen anderen Weg zu eröffnen** *(feedforward — an jener Entscheidung selbst ablesbar)*:
  Annahme (b) fällt, der Vollzug ist unmöglich, und zwischen Option C und einer noch nicht
  benannten ist neu zu wählen.
- **Wenn die Betriebsart aus Folgepflicht 1 am Werkzeug nicht darstellbar ist** *(feedback — an
  einem Implementations-Lauf ablesbar, der sie misst)*: Der tragende Contra-Punkt von Alternative A
  gilt dann auch für die gewählte, und die Abwägung ist neu zu führen.
- **Wenn das Sammel-Archiv aus Festlegung 2 liegt** *(feedback — an `done/` ablesbar)*: Die
  Festlegungen 1 bis 4 haben ihren Gegenstand verloren; was bleibt, ist Festlegung 5, und die ist
  die laufende Regel. Zu prüfen ist dann nur noch, ob sie ohne weitere Zuordnung trägt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-12 | **Proposed** | Architect-Lauf. Anlass ist die Delegation in `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4 der adoptierten Baseline `v6.5.0`, fällig geworden mit der ersten Welle-Closure unter dieser Fassung; der Acceptance-Trigger steht in §Der Acceptance-Trigger |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0041` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

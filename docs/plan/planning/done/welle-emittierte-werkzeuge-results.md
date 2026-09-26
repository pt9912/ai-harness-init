# Welle welle-emittierte-werkzeuge — Jede vorgeschriebene Operation hat im Ziel ein Werkzeug — Closure-Notiz

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis).* Dieses Artefakt friert ein; was es zitiert, bewegt
> sich weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads,
> `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle als
> `v6.8.0` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link.

**Welle:** welle-emittierte-werkzeuge
**Abschluss:** 2026-09-15
**Verantwortlich:** Planner

## Was wurde geliefert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — *was gelernt wurde*: geliefert · was
funktionierte · was anders lief. Mit ID-Bezug, wo es einen gibt.

**Ziel der Welle:** *jede Operation, die der emittierte Anweisungssatz und das emittierte Regelwerk
dem Ziel vorschreiben, hat dort ein Werkzeug — oder einen Satz, der die Lücke benennt.* Vier Slices
haben je eine Operation ins Ziel gebracht; der Zustand ist der des gebootstrappten Ziels, nicht der
des Emit-Codes.

- **Der Vorlauf-Wächter der zwei history-lesenden Targets geht ins Ziel** —
  `slice-vorlauf-waechter-geht-ins-ziel`, zu [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).
- **Der Lifecycle-Move zieht seine Verweise im Ziel nach** —
  `slice-lifecycle-move-geht-ins-ziel`, zu [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren).
- **Ein gebootstrapptes Ziel erreicht die Wellen-Archivierung** — `slice-174-archivierung-emittieren`,
  zu [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren).
- **Der Traceability-Constraint bekommt im Ziel einen Träger** —
  `slice-kennungs-waechter-geht-ins-ziel`, zu [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).

**Der Zustand ist am Ziel gemessen, nicht am Emit-Baum** — und die vier Zusagen sind am selben Ort
belegt: `make full-smoke` fährt **alle vier** Werkzeuge über einem gebootstrappten Ziel durch, keines
ist bloß angelegt (§Verifikation). **Zwei Sätze des Wellen-Ziels sind damit eingelöst:** „hat dort
ein Werkzeug" für die vier Mitglieder, und „oder einen Satz, der die Lücke benennt" für die in §6
geführten Nicht-Mitglieder.

## Was hat funktioniert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3.

- **Der Schnitt nach Lieferwert hat getragen.** Vier Slices, vier **verschiedene** Operations-Klassen
  (Vorlauf-Wächter · Lifecycle-Move · Archivierung · Kennungs-Träger), je eine Sprache und je ein
  Ziel-Ort. Kein Mitglied musste zurückgeführt werden, keines hing an einem anderen: sie sind
  einzeln lieferbar geblieben.
- **Der Schritt 1 ging einer anderen Rolle voraus, und das hat den Lauf entlastet.** Der Verifier
  hat die vier Trigger-Punkte **vor** diesem Lauf geprüft — `make gates` und `make full-smoke` je
  Exit 0, mit den Vollzugs-Markern je Werkzeug. Was der Planner nicht mehr messen musste, konnte er
  lesen; die Rollen-Trennung nach Modul 8 hat hier *Zeit* gespart, nicht nur blinde Flecken.
- **Die vier Mitglieder standen über ihr Kopf-Feld fest, nicht über die §4-Tabelle.** Der
  Verifier hat beide Quellen gegeneinander gehalten und sie deckungsgleich gefunden; die Tabelle
  führt nach, sie vergibt nicht — genau so hat sie sich verhalten.
- **Der Trigger-Audit hat einen ausgeführten ADR-Trigger gefunden — und seine Folge war schon
  eingelöst** (siehe *Was ging anders als geplant*). Ein Audit, der nur *fällige* Trigger sucht,
  hätte das nicht gesehen.

## Was ging anders als geplant?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — jede Zeile möglichst mit der Konsequenz,
die daraus schon gezogen wurde (Folge-Slice, Spec-Version).

- **Vier Messwerte in §1 standen gegen den Baum, und die Regel dafür war beim Schreiben in Kraft.**
  Der Plan führte vier Beträge (`0`) samt gegenwartsformiger Glosse *„kein Ziel kennt …"*; gemessen
  am Stand **nach** den vier Mitgliedern liefern dieselben vier Kommandos `5 · 6 · 5 · 7`. Die
  Klasse ist [`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
  Setzung 2: der schreibende Vorgang bewegt seine eigene Bezugsmenge. **Konsequenz:** die vier
  Beträge sind **gefallen**, an ihrer Stelle steht die **Eigenschaft** (*dass kein Ziel die vier
  Werkzeuge kannte*), die Kommandos sind geblieben. Setzung 3 derselben Regel schließt den Ausweg
  *„kein Erwartungswert"* — eine Kennzeichnung hätte aus einem falschen Betrag einen falschen Betrag
  mit Disclaimer gemacht. Der Befund kam vom Verifier (§Verifikation V-1), nicht aus diesem Lauf.
- **Der Lese-Schritt traf fünf Einträge über der Schwelle, nicht einen.** Die Übergabe nannte einen
  (`zusage-ohne-herstellbares-gegenbeispiel`); gemessen standen fünf auf `offen` — alle fünf sind
  **seit dem Lese-Schritt der `welle-13`** übergetreten, und drei davon über Evidenzen **dieser**
  Welle (siehe §Steering-Loop-Einträge). **Konsequenz:** der Schritt liest nach
  [ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 3 **alle** Einträge
  über der Schwelle *zu seinem Zeitpunkt*, nicht die seit dem letzten Lauf neu übergetretenen; die
  volle Menge ist damit bearbeitet und nicht die übergebene.
- **Schritt 4 (Archivierung) ist nicht ausgeführt — der Lauf bricht an zwei stehenden Sperren.** Die
  Vorschau vor Schritt 3 meldet **vier** Sperren; zwei davon (`ergebnisnotiz`, `kein-plan`) löst
  Schritt 3 selbst auf, die zwei übrigen stehen unabhängig vom Bestand:
  `[untergrenze]` — **73** wellenlose Slices liegen flach in `done/`, aber kein
  `docs/plan/planning/done/*/archiv.zip` setzt eine Untergrenze —, und `[haenger]` — auf
  verschwindende Review-Reports wird aus eingefrorenen ADRs, aus Carveouts, aus `spec/lastenheft.md`
  und quer zwischen Reports verwiesen. **Konsequenz:** die Welle schließt **ohne** Schritt 4, so wie
  es die Prozedur für diesen Fall vorsieht; archiviert ist nichts. Der Grund ist im Sensor selbst
  benannt (`make archive-welle` §Grenze Punkt 4: *„auf eine Welle dieses Repos ist das Werkzeug noch
  nicht anwendbar"*) — dieser Lauf hat ihn nicht widerlegt, sondern mit seinen vier Sperren bestätigt.
- **Der Geltungsbereich der Sensoren trägt die Stub-Ebene nicht vollständig — und das ist ein
  Befund, der vor der ersten Archivierung gehört.** Geprüft sind die zwei Hälften getrennt:
  `scan.roots: ["."]` und die `matrix`-Klasse `slice` (`docs/plan/planning/**/slice-*.md`) **reichen**
  die Stubs; das Modul `planning` in seiner Fähigkeit `closure` liest `dir: docs/plan/planning/done`
  dagegen **flach und nicht rekursiv** (`grep -n -A 3 'closure:' .d-check.yml` — die Begründung steht
  als Kommentar darüber). Die Slice-Pläne dieser Welle lägen nach einer Archivierung unter
  `done/<welle-id>/`; die Closure-Form-Prüfung erreichte sie nicht mehr, und ihr Grün wäre über
  diesen Slices vakuos. **Konsequenz:** benannt und **nicht** geschlossen; die Zusage „jeder flache
  Slice-Plan in `done/` trägt eine wohlgeformte §7" gilt für archivierte Stubs nicht mehr. Weil
  Schritt 4 nicht läuft, ist die Lücke heute **gegenstandslos** — sie wird mit der ersten
  ausführbaren Archivierung fällig.
- **Der Trigger-Audit hat [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Trigger 4 als ausgeführt gefunden — und seine Folge ist eingelöst.** *„Die emittierte Ebene bekommt
  einen Commit-Wächter"* ist mit `slice-kennungs-waechter-geht-ins-ziel` eingetreten
  (`internal/emit/commitmsg.go` und drei Vorlagen unter `internal/emit/templates/enforce/`); die vom
  Trigger verlangte Folge — die zwei Grenzen **dort genannt**, nicht stillschweigend mitgeliefert —
  ist am emittierten Träger selbst gelesen: `commit-msg-hook.sh` nennt die nicht reisende Aktivierung
  und `--no-verify`, `hooks-install.mk` wiederholt beide im Kopf **und** in der Ausgabe des Targets.
  **Konsequenz:** bestätigt, keine Folge-ADR. Die drei übrigen Trigger derselben ADR sind geprüft und
  **nicht** ausgeführt (kein Automatismus für `core.hooksPath`; der Kandidat nicht gearbeitet; die
  Formen-Menge unverändert — [`MR-059`](../../../../harness/conventions.md#mr-059) löst allein das
  Feld `Grenze` von [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  ab, nicht seine Setzungen 1 und 2, damit auch nicht die Kennungs-Formen).
  [ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) hat **keinen** ausgeführten
  Trigger (das Werkzeug entscheidet die Herkunft nicht, gebaute Ziele sind nicht gemessen, `git`
  aktiviert aus dem Baum nichts) — ihr Accept-Übergang samt Konsistenz-Runde steht noch aus.
- **Die zwei in §6 benannten Lücken stehen hier — das ist die Bedingung, unter der §6 ins Archiv
  darf.** Namentlich: **(1)** es gibt **keinen Sensor**, der den *lokalen* Anweisungssatz gegen die
  *emittierte* Vorlage hält — die zwei sind getrennte Artefakte, und keines nennt das andere als
  Quelle; die zwei Träger des Nachzugs (`slice-153` in `open/`, `slice-226` in `done/`) decken das
  **Paar** nicht, sondern reparieren je eine Fassung gegen das Regelwerk. **(2)** die zwei
  `close-welle.md` weichen in Schritt 2 ab: die lokale Fassung führt einen **Carveout**-Audit über
  *eine* Klasse, die emittierte einen **Trigger-Audit über drei** (Carveout · bootstrap-aware Gate ·
  ADR) und nennt fünf Module statt drei — der Posten hatte **keine Kennung**, und diese Welle hat
  keinen vierten Slice dafür geschnitten, weil ein Nachzug über zwei Ebenen desselben Ablaufs ein
  eigener Vorgang ist. **Die Adresse für beide ist heute eine Vorschau-Zeile und kein Slice:** die
  Roadmap führt `welle-anweisungssatz-und-emittierter-satz` unter *Nächste Wellen*, ihr Trigger ist
  der Eintritt **dieser** Welle in `done/` — er ist mit diesem Abschluss eingetreten. Daß eine
  Welle-Kennung in der Vorschau **keine** Plandatei hat, ist die Entscheidung
  [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 und **kein**
  offener Folge-Slice; die Zeile wird darum hier geführt und **nicht** in §Folge-Slices.
- **Der eigene Lauf hat drei Adressen zu Plandateien gemacht, die vorher nur in Norm-Text
  auflösten.** [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 2 und
  [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 nennen
  je eine Kennung, „bis der Slice im Planning-Lifecycle liegt"; der Lese-Schritt hat für beide einen
  Träger geschnitten (§Steering-Loop-Einträge), weil eine genannte Kennung ohne Datei an der
  Folge-Slice-Paarung fällt.
- **Die Frist aus [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 5 hängt an einem
  Werkzeug-Zustand, den dieser Lauf nicht herstellt.** Setzung 2 verlangt, dass die *Erkennung* jeder
  Dogfood-Stelle alle drei Formen trägt; gemessen trägt sie heute die **Nummernform** —
  `.d-check.yml` führt `slice-\d+`, und die Prüfung des Commit-Trägers führt dasselbe Muster:

  ```sh
  git log --format='%s' | grep -c '^slice-mv:'
  git log --format='%s' | grep '^slice-mv:' | grep -vcE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
  ```

  **Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beide wandern mit jedem Lifecycle-Wechsel. Die zweite Zeile zählt die
  Werkzeug-Commits, deren Betreff keine *erkannte* Kennung trägt: der Beleg dafür, dass die
  Erkennungs-Lücke nicht theoretisch ist, sondern den Commit-Pfad dieses Repos trifft.

## Steering-Loop-Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 (hier stehen **nur** Beobachtungen, die im
Register 3× erreicht haben; jeder Eintrag nennt seine `BEO-<KUERZEL>/<slug>`) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Der Lese-Schritt ([ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 3)
liest alle Einträge über der Schwelle, zu seinem Zeitpunkt.** Am Beginn dieses Schritts standen
**fünf** auf `offen` — gezählt über den abgeleiteten Zähler, nicht über ein Feld:

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn
```

**Keine Erwartungswerte** — die Menge wandert mit dem Baum. **Vier haben hier ihren Ausgang als
*verkörpert* bekommen, einer als *geplant* mit Kennung.** Die Verteilung des Registers nach dem Lauf:

```sh
grep -h '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/*/state.md | sort | uniq -c
```

**Warum die vier *verkörpert* keinen zweiten Herkunfts-Anker tragen:** Bei ihnen stand die Regel
**schon** an einem Norm-Artefakt — die Beobachtung ist eine *benannte Lücke*, kein fehlender Satz
([ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1). Ihre Zielorte tragen
darum ihre **eigene** Kennung oder Stelle (`grundlagen-traceability.md` §Herkunfts-Anker,
Geltungsbereich), und die fehlende Bewachung steht im jeweiligen `state.md` als Abschnitt *Grenze der
Verkörperung, benannt*. **Auch in diesem Lauf ist keine einzige Regel neu entstanden** — die Arbeit
war das **Suchen** des Zielorts; ein `seit welle-emittierte-werkzeuge` setzt er darum nirgends.

- **Hard Rule getragen** — eine Zusage über eine strukturelle Eigenschaft wird auf das eingeschränkt,
  was der Bau selbst hält, und die Lücke wird an ihrer Stelle benannt
  — liegt in [`AGENTS.md`](../../../../AGENTS.md) §3.6
  (*„benennen, was wirklich deckt — oder dass nichts deckt"*). Auslöser:
  `BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel` (3×: `slice-123`, `slice-177`,
  `slice-lifecycle-move-geht-ins-ziel`).
- **Hard Rule getragen** — ein Abnahmekriterium, das der laufende Vorgang widerlegt, wird nicht im
  laufenden Kontext geheilt, sondern als Übergabe-Artefakt an den Planner geführt
  — liegt in [`AGENTS.md`](../../../../AGENTS.md) §3.10. Auslöser:
  `BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` (5×, davon **drei** Evidenzen
  aus Mitgliedern dieser Welle: `slice-174-archivierung-emittieren`,
  `slice-vorlauf-waechter-geht-ins-ziel`, `slice-kennungs-waechter-geht-ins-ziel`).
- **Hard Rule getragen** — eine Zusage nennt die **Kante**, die ihr Sensor deckt, nicht die Regel
  — liegt in [`AGENTS.md`](../../../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt"*). Auslöser:
  `BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine` (3×: `slice-129`,
  `slice-offene-wellen-liste-hat-einen-waechter`, `slice-vorlauf-waechter-geht-ins-ziel`).
- **Zusage getragen** — jede Commit-Message nennt mindestens eine Kennung; die zwei Träger und ihre
  Reichweiten-Grenzen stehen in einer Tabelle
  — liegt in [`AGENTS.md`](../../../../AGENTS.md) §5 und `harness/README.md` §Traceability. Auslöser:
  `BEO-ALL/commit-message-ohne-traceability-kennung` (3×: `slice-129`, `slice-140`,
  `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits`).

**Der eine *geplant* hat einen Träger bekommen** — sein Zielort fehlte, und
[ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 2 verlangt für diesen
Fall einen **Schnitt**, keine Auslegung:

| Beobachtung | Zähler | Träger |
|---|---|---|
| `BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung` | 3× | [`slice-beleglose-register-eintraege-bekommen-eine-lesart`](../done/slice-beleglose-register-eintraege-bekommen-eine-lesart.md) |

**Zwei Adressen aus Norm-Text sind im selben Zug zu Plandateien geworden** — sie lösten vorher nur
dort auf, und die Folge-Slice-Paarung fällt über eine genannte Kennung ohne Datei:

| Norm-Text | Träger |
|---|---|
| [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 2 und 5 | [`slice-kennungs-erkennung-traegt-die-zugelassenen-formen`](../open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md) |
| [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 | [`slice-werkzeug-commits-tragen-eine-kennung`](../done/slice-werkzeug-commits-tragen-eine-kennung.md) |

**Der Zähler ist eine datierte Messung**
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2) — jeder Betrag oben wandert mit dem Baum.

## Beobachtungs-Register (Zeiger)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — der Zähler wird **nicht** hier gepflegt; diese
Sektion ist ein Zeiger und trägt keine Daten.

Der Zähler steht in [`../observations/`](../observations) (Verzeichnis-Form, ein Verzeichnis je
Beobachtung; der Mechanismus in [`../observations/README.md`](../observations/README.md)). Was in
dieser Welle **3×** erreicht hat, steht oben unter *Steering-Loop-Einträge*.

## Folge-Slices

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — **derivativ**: Diese Liste zeigt nur, das Original ist die
Slice-Datei. Jeder genannte Folge-Slice muss als Datei im Planning-Lifecycle existieren; genannt
ohne angelegt ist dieselbe Klasse wie ein halluziniertes Gate.

**Drei Träger, aus diesem Lauf geschnitten** (jeder liegt in `open/`):

- [`slice-beleglose-register-eintraege-bekommen-eine-lesart`](../done/slice-beleglose-register-eintraege-bekommen-eine-lesart.md)
  (Architect) — der Träger des einzigen `geplant`-Ausgangs dieses Lese-Schritts.
- [`slice-kennungs-erkennung-traegt-die-zugelassenen-formen`](../open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md)
  — die Fundliste aus [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 2.
- [`slice-werkzeug-commits-tragen-eine-kennung`](../done/slice-werkzeug-commits-tragen-eine-kennung.md)
  — der Kandidat aus [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 4.

**Kein weiterer Folge-Slice ist aus dieser Welle entstanden.** Insbesondere ist
`welle-anweisungssatz-und-emittierter-satz` **keiner**: sie steht als Welle-Kennung in der Vorschau
der Roadmap und hat nach [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
Festlegung 1 keine Plandatei (siehe *Was ging anders als geplant*).

## Verifikation

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 1 — keine Behauptung ohne nachprüfbaren
Anker (Hash, Lauf, Zahl).

- **Schritt 1 — Trigger geprüft (Verifier → Planner).** Beleg: der Report
  `2026-09-15-welle-emittierte-werkzeuge-trigger` (`docs/reviews/`, gefahren über `071cc2f1`).
  Verdikt: **alle vier** Punkte des §3-Triggers erfüllt — `make gates` Exit 0 mit deckungsgleichem
  Stempel, `make full-smoke` Exit 0, **alle vier** Werkzeuge im gebootstrappten Ziel **gefahren**
  (Belegzeile je Werkzeug), vier von vier Mitgliedern in `done/` samt Kopf-Feld. Drei Grenzen des
  Belegs stehen dort benannt: die vier E2E-Abschnitte laufen über der `--lang go`-Variante; die rot
  färbenden Gegenbeispiele liegen im nicht gefahrenen `make mutate`; und die vier Messwerte, die
  dieser Lauf gezogen hat (V-1).
- **Schritt 2 — Trigger-Audit (Planner) — drei Klassen, alle drei geprüft.**
  *Carveout:* **zwei** offen. `CO-001` (`shell-lint` deckt die bats-Dateien nicht ab) —
  Auflösungs-Trigger **weiterhin eingetreten**, Ausgang **verlängert mit Folge-Slice**
  (`slice-141` entscheidet vor, `slice-113` führt aus); die Fundstelle steht unverändert. `CO-002`
  (Token-Achse je Rolle) — **permanent**, übergeführt in
  [ADR-0021](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md); keine Schwelle, die
  wieder eintreten könnte. *Bootstrap-aware Gate:* **kein solches Gate vorhanden** — die Suche über
  `Makefile`, `d-check.mk` und `harness/` ist leer; der Reifestufen-Zweig hat keinen Gegenstand.
  *ADR:* der Befund steht oben unter *Was ging anders als geplant* —
  [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Trigger 4
  **ausgeführt und seine Folge eingelöst** (keine Folge-ADR), die drei übrigen nicht ausgeführt;
  [ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) ohne ausgeführten
  Trigger. **Kein stiller roter Gate, keine stehengebliebene Reifestufe.**
- **Die drei Paarungen** (Schritt 3, zum Schluss — sie prüfen die gerade entstandenen Einträge).
  **(a) Anker-Paarung:** ausgelöst allein durch das Pflichtfeld `liegt in <Zielort>`; **vier**
  Einträge tragen es, ihre Zielorte (`AGENTS.md` §3.6 und §3.10, `AGENTS.md` §5 mit
  `harness/README.md` §Traceability) existieren ab Repo-Wurzel und tragen **ihre eigene** Adresse
  statt eines Wellen-Ankers — die Lesart, die
  [ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1 für eine *benannte
  Lücke* vorsieht. **(b) Folge-Slice-Paarung:** **drei** genannt, **drei** liegen als Dateien im
  Planning-Lifecycle (`open/`). **(c) Register-Paarung:** jede genannte Beobachtung existiert als
  Verzeichnis, und jede Registerzeile trägt mindestens einen Beleg — **mit einer benannten
  Ausnahme**, die diese Welle nicht entscheidet, sondern führt
  (`BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung`); die Umkehrung *„jede Zeile ist
  irgendwo zitiert"* wird nicht geprüft. **Kein Rot.**
- **`make gates`** grün über dem Abschluss-Stand, **nach** dem letzten Commit erneut.
- **Schritt 4 — Archivierung — nicht ausgeführt**, die Vorschau endet mit **Exit 3** an den zwei
  stehenden Sperren `[untergrenze]` und `[haenger]`; die Feststellung samt ihren Zahlen steht unter
  *Was ging anders als geplant*.

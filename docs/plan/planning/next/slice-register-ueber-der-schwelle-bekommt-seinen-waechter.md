# Slice slice-register-ueber-der-schwelle-bekommt-seinen-waechter: „Über der 3×-Schwelle ohne Ausgang" färbt rot — und der Bestand ist danach ohne Befund

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Die Menge, über die dieser Slice urteilt — jeder Registereintrag über der
Schwelle trägt einen Ausgang —, ist **kein** Wellen-*Mehr*: Sein Liefer-Punkt (2) prüft genau sie,
sie steht also in der DoD selbst und nicht daneben (Baseline-Regelwerk `modul-06-roadmap.md` §Wann
Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Der Sensor prüft das Register **dieses** Repos und die Ausgänge
seiner Einträge. Ob ein emittiertes Repo einen solchen Wächter bekommt — das gepinnte Image führt
mit `planning.observations` eine verwandte, aber andere Fähigkeit —, entscheidet der Slice, der die
Tool-Ebene entscheidet.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate
ohne seinen Prüfbereich ist ein halluziniertes Gate),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage braucht das rot gesehene Gegenbeispiel),
[`AGENTS.md`](../../../../AGENTS.md) §3.1 (kein Gate ohne laufenden Beleg),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 1 und 2),
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 — ein Register-Zähler ist eine datierte Messung),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Sensor läuft netzlos
und hermetisch wie jeder andere dieses Repos).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein Wächter über
dem Register dieses Repos).

**Verantwortlich:** Implementer (pt9912). Der Liefergegenstand ist ein **Werkzeug** — ein Gate, das
den Register-Bestand hält —, und die Norm, die es prüft, ist nicht seine: sie kommt aus
[`slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke`](../done/slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md)
und wird hier **gelesen**, nicht entschieden (Baseline-Regelwerk `modul-08-agentenrollen.md`
§Welche Rolle braucht welche Artefaktklasse: wer die Norm entscheidet, baut ihren Wächter nicht im
selben Kontext).

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Ein Registereintrag, der die 3×-Schwelle überschritten hat und keinen Ausgang trägt, färbt
einen Gate-Lauf rot — und der Bestand, der heute so dasteht, ist nach diesem Slice ohne Befund.**

### Warum das ein eigener Slice ist und nicht ein Nachzug am Register

Die Klasse ist **gezählt und wiederkehrend**, nicht einmalig: Am gemergten Stand stehen **18**
Einträge über der Schwelle auf `offen`, bei **31** über der Schwelle und **114** Einträgen
insgesamt.

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn | wc -l                                            #  18  ohne Ausgang
for d in docs/plan/planning/observations/BEO-*/*/; do
  printf '%s\n' "$(ls "$d"evidence 2>/dev/null | wc -l)"
done | awk '$1 >= 3' | wc -l                                       #  31  über der Schwelle
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l           # 114  Einträge gesamt
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, geschärft durch [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2); **die Zahlen sind vor dem ersten Lauf des Slice neu zu fahren** und dann die, gegen die
er arbeitet. Der Zähler läuft mit **jedem** geschlossenen Slice weiter — der Bestand ist damit
schon während dieses Slice in Bewegung, und genau deshalb trägt der Nachzug einen Sensor und keine
Handliste.

**Der Träger ist ein Gate, weil die Aussage eine ist, die immer gelten muß.** *„Jeder Eintrag über
der Schwelle trägt einen Ausgang"* ist keine Absicht für einen Lauf, sondern eine Bedingung an
jeden Stand (Baseline-Regelwerk `modul-13-quality-gates.md` §Kernidee). Der Sensor ist damit
**kein** Werkzeug im Sinne der dritten Lage, sondern ein Gate: er gehört in
[`harness/README.md`](../../../../harness/README.md) §Sensors **und** in `make gates`, und das
Modul `targets` prüft beide Richtungen (`grep -m1 '^modules:' .d-check.yml`, kein Erwartungswert).

### Ausdrücklich NICHT in diesem Slice — je Punkt mit Begründung:

- **Keine Entscheidung über den Ausgang selbst.** Welchen der Ausgänge eine benannte Lücke trägt und
  was der Lese-Schritt liest, entscheidet
  [`slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke`](../done/slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md)
  als `Accepted`-ADR. Ein Sensor, der die Regel vor ihr festlegt, prüfte eine Entscheidung, die
  niemand getroffen hat. *Es wäre ein anderer Vorgang — und dieser Slice startet erst danach (§4).*
- **Keine Änderung an der Verzeichnis-Form oder den drei Datei-Lebensdauern.** Sie sind in
  [ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  entschieden; der Sensor **liest** sie, er formt sie nicht. *Bestand bleibt bewusst stehen.*
- **Kein zweiter Lese-Gegenstand.** Der Sensor prüft **über** der Schwelle; was **darunter** steht,
  ist Sache des Sichtungs-Schritts in §8 jedes Slice-Plans und wird hier nicht angefaßt.
  *Schicht-Abgrenzung.*
- **Keine Ausweitung auf andere Register oder auf Prosa.** Nicht der Adaptions-Block, nicht der
  ADR-Index, nicht die Roadmap: jedes hat seine eigene Deckungs-Frage und seinen eigenen Träger.
  *Schicht-Abgrenzung.*
- **Kein Produkt-Code und keine emittierte Vorlage.** `internal/emit/` bleibt unberührt; dieser
  Wächter ist Dogfood. *Schicht-Abgrenzung.*
- **Kein Nachzug der Einträge unter der Schwelle und keine Räumung des Registers** — gestrichen
  wird nur mit Begründung, und die ist ein Urteil je Eintrag (Baseline-Regelwerk
  `modul-06-roadmap.md` §Das Beobachtungs-Register). *Es wäre ein anderer Vorgang.*

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

- [ ] **(1) Die Klasse färbt rot, und zwar aus dem richtigen Grund** — der Sensor ist an einem
      **hinzugefügten** Fall rot gesehen worden (ein künstlich über die Schwelle gehobener Eintrag
      ohne Ausgang), mit der Meldung, die die Stelle nennt; **und** er ist über dem unveränderten
      Bestand **still**, nachdem Punkt (2) ihn gezogen hat. Beide Läufe stehen mit ihrem Kommando im
      Umsetzungs-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.6: das Rot muß die **behauptete**
      Ursache tragen, nicht irgendeine). Der Sensor ist in
      [`harness/README.md`](../../../../harness/README.md) §Sensors **und** in `make gates`
      verdrahtet, netzlos wie jeder andere
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] **(2) Der Bestand ist nach der Regel aus dem Träger-Slice ohne Befund** — die zu diesem
      Zeitpunkt über der Schwelle stehenden Einträge tragen einen Ausgang; **die Zahl ist vorher
      neu gefahren** und steht als datierte Messung mit ihrem Kommando in §7
      ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
      Setzung 2). Wo kein Ausgang zulässig ist, sagt §7 nach der neuen Regel, warum — ein leerer
      `state.md`-Rumpf ist kein Nachzug.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Liefer-Punkt (1) **ist** dieses Item — der Träger ist der Gate-Index.
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
| `harness/tools/` — ein neuer Prüfer (Hausform der Sensoren) **oder** ein Schritt im Werkzeug | neu | der Sensor aus Liefer-Punkt (1); der Ort ist entschieden, der Träger nicht: erst nach der Regel aus dem Vormerk-Slice |
| `Makefile` | update | ein Gate-Target, das den Prüfer im gepinnten Image bzw. als Host-freies Rezept fährt |
| [`harness/README.md`](../../../../harness/README.md) | update | §Sensors — ein Gate ohne Zeile im Index ist nach `modul-13-quality-gates.md` §Hard Rule ein behauptetes Gate ohne Deckung |
| [`docs/plan/planning/observations/BEO-ALL/*/state.md`](../observations/README.md) | update | Liefer-Punkt (2) — der Nachzug nach der Regel des Träger-Slice |
| `test/*.bats` | neu | Liefer-Punkt (1) — der rot gesehene Fall und der stille Bestand als Test |
| `test/mutations/*.sh` | update | der neue Wächter gehört in den kuratierten Fall-Satz (`make mutate`), sonst ist er unbewacht (`AGENTS.md` §3.6) |

**Die Reihenfolge steht fest:** erst die Regel lesen (Träger-Slice, `done/`), dann den Sensor
schreiben, dann rot sehen, dann den Bestand ziehen, dann still sehen. Wer (2) vor (1) zieht,
mischt den Nachzug mit einer unfertigen Regel.

**Und der Sensor prüft die Eigenschaft, nicht ihre heutige Implementierung.** Er liest den
**Stand** aus `state.md` und die **Zahl** aus `evidence/` — beide aus dem Dateisystem, keiner aus
einer zweiten Quelle; ein Sensor, der eine Liste erwarteter Einträge führt, wäre die zweite Fassung,
die driftet.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke`
liegt in `done/`**, und `in-progress/` trägt keinen Slice. Beobachtbar ohne Rückfrage, auf dem
**Hauptzweig**:

```sh
ls docs/plan/planning/done/ | grep -c '^slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke\.md$'  # 1
ls docs/plan/planning/in-progress/ | grep -c '^slice-'                                                        # 0
```

**Der Trigger ist kein Ergebnis dieses Slice** — beide Bedingungen sprechen über den Bestand *vor*
der Arbeit, die erste über einen **anderen** Slice.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Der Sensor verlangt eine Änderung an
  einer gemeinsamen Fläche** — etwa weil die Ausgangs-Prüfung nur mit einem neuen `d-check`-Modul
  sauber wird und damit denselben Schnitt wie der Pin berührt. Dann ist das ein eigener Gegenstand.
- `in-progress` → `open` (blockiert — Carveout?): **Das Rot ist nicht herstellbar** — der Sensor
  ließe sich nur so bauen, daß er die Form statt der Eigenschaft prüft (§6 Risiko 1). Dann gilt die
  Werkzeug-Triade: nicht verdrahten, sondern als Carveout führen (Baseline-Regelwerk
  `modul-13-quality-gates.md` §Bootstrap-aware Gates), nie still grün.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Beide Läufe des Liefer-Punkts (1) stehen im Umsetzungs-Commit** — der rote mit dem
   hinzugefügten Fall, der stille über dem gezogenen Bestand —, und `make gates` meldet Exit 0.
2. **Der Nachzug nennt seinen Bezugsstand als datierte Messung** — die Zahl aus Liefer-Punkt (2)
   trägt ihr Kommando und ist als **kein** Erwartungswert gekennzeichnet
   ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
   Setzung 2).

**Lerneintrag:** die Form entscheidet die Closure und nicht dieser Plan. Wurde mit diesem Slice ein
Sensor verkörpert, trägt der Eintrag `liegt in <Zielort>` — beim Make-Target auf dessen Target-Zeile
(Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Der Sensor prüft die Form und nicht die Eigenschaft.** Ein Muster auf die Wörter
  *verkörpert / geplant / gestrichen* im `state.md` färbt grün, sobald irgendeines davon dasteht —
  auch wenn der Ausgang materiell leer ist. Genau die Klasse
  [`BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt`](../observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md).
  **Gegenmittel im Plan:** Liefer-Punkt (1) verlangt das **Rot aus dem richtigen Grund** und den
  stillen Bestand danach; §7 benennt die Grenze des Sensors ausdrücklich.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Der Nachzug wird zur Formalie.** Achtzehn Einträge sind nicht achtzehnmal derselbe Text; wer
  die Rümpfe vereinheitlicht, löscht den Befund, statt ihn zu beantworten. **Gegenmittel im Plan:**
  Liefer-Punkt (2) verlangt, daß der Rumpf den Ausgang **trägt**; ein leerer `state.md`-Rumpf ist
  ausdrücklich kein Nachzug.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) Der Zähler läuft schneller als der Nachzug.** Jede Slice-Closure kann neue Einträge über die
  Schwelle heben; ein Nachzug, der einmal läuft, ist am Tag danach unvollständig.
  **Gegenmittel im Plan:** Genau deshalb ist der Sensor der erste Liefer-Punkt und keine Handliste —
  nach ihm ist der Nachzug eine Schleife bis grün, nicht eine Zahl.
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
ist allein der Modus-Begründungsblock am Ende; deshalb nennt Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas, und die Wahl ist gegen die
Schwelle ≥ 2 von 3 Achsen geprüft:

- **`*` (gesamtes Repo, Kürzel `ALL`)** — erfüllt: eigene Regeln (`observations/README.md`,
  Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register), eigener Prüfbereich
  (`make docs-check` und `make gates`), eigene Fehlermodi (Eintrag über der Schwelle ohne Ausgang).
- **`harness/tools/` (Kürzel `TOOLS`)** — erfüllt: eigene Regel-Form (die Hausform der Prüfer unter
  `harness/tools/`, [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)),
  eigener Prüfbereich (`make shell-lint`, `make test`), eigene Fehlermodi (ein Prüfer, der seine
  Ausgabe nicht auf den Prüfgegenstand bezieht). **`CODEX` ist geprüft und nicht berührt.**

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**114** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2); alle führen dieselbe Sub-Area `*`. **Acht Einträge** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `zaehler-label-nennt-falsche-einheit` | 3× | offen | §3 — ein Label gegen seinen Zähler; der Sensor liest beide aus dem Dateisystem |
| `register-paarung-ohne-gate-modul` | 1× | offen | §1 — die maschinelle Hälfte der Register-Deckung; dieser Sensor ist der nächste Anlauf |
| `ausgang-nennt-traeger-der-nicht-traegt` | 2× | offen | §6 Risiko 1 — genau die Grenze, die dieser Sensor nicht schließen kann |
| `beleg-nach-dem-ausgang-findet-keinen-leser` | 2× | offen | §1 — was **nach** einem Ausgang gilt; nicht sein Gegenstand |
| `unbelegter-register-eintrag-faellt-durch-die-paarung` | 1× | offen | §3 — die Beleg-Hälfte; der Sensor liest `evidence/`, er urteilt nicht über sie |
| `neuer-waechter-ohne-mutations-fall` | 6× | offen | §3 — der neue Wächter gehört in `test/mutations/`, sonst ist er unbewacht |
| `sichtungs-schritt-zitiert-falschen-zaehler-stand` | 3× | verkörpert | §2 Liefer-Punkt (2) — der Zähler-Stand trägt Kommando und Maß |
| `rotierender-pruef-gegenstand-ohne-ort` | 1× | offen | §6 Risiko 3 — der Bestand bewegt sich unter dem Sensor |

```sh
for s in zaehler-label-nennt-falsche-einheit register-paarung-ohne-gate-modul \
         ausgang-nennt-traeger-der-nicht-traegt beleg-nach-dem-ausgang-findet-keinen-leser \
         unbelegter-register-eintrag-faellt-durch-die-paarung neuer-waechter-ohne-mutations-fall \
         sichtungs-schritt-zitiert-falschen-zaehler-stand rotierender-pruef-gegenstand-ohne-ort; do
  printf '%s  %s  %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" \
    "$(grep -m1 -oE '(offen|verkörpert|geplant|gestrichen)' docs/plan/planning/observations/BEO-ALL/$s/state.md)" "$s"
done
```

**Keiner der acht erreicht mit diesem Slice 3×** — fünf stehen bei 1× oder 2×, drei bereits
darüber. **Ein eigener Folge-Slice entsteht aus der Sichtung also nicht.**

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
zwei Sub-Areas.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — die Ausgangs-Regel steht in
  [`observations/README.md`](../observations/README.md), die Kennung als Pfad in
  [ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 3, der Baseline-Wortlaut in `modul-06-roadmap.md` §Das Beobachtungs-Register.
- **Phase-Reife:** Phase 4 für die Register-Doku, Phase 5 für die Gate-Tabelle — sie ist die
  Autoritäts-Doku des Moduls `targets` und wird in beide Richtungen geprüft.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig.** Es gibt keine Inventur-Lücke: Zähler und Stand sind
  ein `ls` und ein `grep`, kein Urteil. Das Risiko liegt im Sensor selbst (§6), nicht im Bestand.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund; `reconciliation.md` existiert in
  diesem Repo nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2), das zugehörige DoD-Item
  entfällt deshalb in §2. Graduation entfällt (n/a bei GF).

### Sub-Area: `harness/tools/` (Kürzel `TOOLS`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Ort der ausführbaren Harness-Tools ist
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)/[`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)
  entschieden, die Hausform der Prüfer und die Nicht-Gate-Markierung in
  [`harness/README.md`](../../../../harness/README.md) §Werkzeuge.
- **Phase-Reife:** Phase 4 — die Werkzeug-Fläche hat Form und Sensoren (`make shell-lint`,
  `make test`), ihre Vollständigkeit ist bewacht (`targets`).
- **Evidenz-/Diskrepanz-Risiko:** **niedrig.** Der Prüfgegenstand ist neu; es gibt keinen
  gewachsenen Bestand, gegen den der Sensor laufen könnte, außer dem einen, den er selbst zieht.
- **Reconciliation-Aufwand:** keiner — GF; Graduation entfällt.

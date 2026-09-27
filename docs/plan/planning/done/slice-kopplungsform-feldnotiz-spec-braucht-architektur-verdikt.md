# Slice slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt: Ob und wie die Feldnotiz im Träger und die Tabellenzeile in Spec §5 gekoppelt werden, ist eine Architektur-Entscheidung, keine Planungs-Entscheidung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die von der DoD
dieses Slice verschieden ist (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
(Rang 1 — Redaktion des emittierten Dokuments),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Accepted —
Festlegung 1 macht [`spec/spezifikation.md`](../../../../spec/spezifikation.md)
§5 zum Rang-2-Zielort derselben Tatsache, über die auch die Trägerfassung
spricht — **welche Form** dieser Zielort trägt, entscheidet dieser Slice
nicht, er holt die Entscheidung ein),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
(Accepted — Festlegung 7: das Dokument entsteht aus dem Träger),
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(misst die vierte Spalte von §5 als Feedforward — kein Gate hält sie; genau
das ist einer der Kosten-Punkte, die die Antwort auf diesen Slice mitträgt),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(Vorbild für eine "erzeugt"-Antwort: tool-generiert, verbatim),
Baseline-Regelwerk `modul-11-verification.md` §Fitness Function ohne
Standard-Tool (die Sensor-Schicht-Tabelle Pre-commit-Hook /
Make-Target / Doku-Konsistenz-Agent, nach der die Antwort greift),
Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln (*"Warum
Architect und nicht Planner allein: Regel-Verkörperung … sind
Entscheidungen, keine Planung"*).

**Verantwortlich:** Architect. Der Liefergegenstand ist eine **normative** Entscheidung — welche
der drei vorgezeichneten Lesarten (oder eine vierte) trägt; das Verdikt liegt vor
([`docs/reviews/2026-09-27-verdikt-kopplungsform-feldnotiz-spec.md`](../../../reviews/2026-09-27-verdikt-kopplungsform-feldnotiz-spec.md)).
Wem das **Schreiben** gehört, sagt Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Regeln (*„Warum Architect und nicht Planner allein: Regel-Verkörperung … sind
Entscheidungen, keine Planung"*). Dieselbe Zuschnitt-Wahl tragen
[slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke](../done/slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md)
und
[slice-beleglose-register-eintraege-bekommen-eine-lesart](../done/slice-beleglose-register-eintraege-bekommen-eine-lesart.md) —
beide liefen für dieselbe Konstellation (Architect liefert die Norm-Entscheidung, kein Code) den
vollen Lifecycle `open → next → in-progress → done`; dieser Slice folgt demselben Pfad, anders als
die separat gemessenen `open → done`-Kanten, die ausschließlich die Stilllegungsform (§Ein Slice,
dessen Gegenstand ein anderer übernimmt) tragen — hier ist der Gegenstand geliefert, nicht
übernommen oder entfallen.

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Architect entscheidet, **in welcher Form** die Frage je Feld im
Träger (`internal/span/fieldlist.go`, `SchemaNotes()`) und die
Incident-Frage je Zeile in [`spec/spezifikation.md`](../../../../spec/spezifikation.md)
§5 zusammengehalten werden — oder ob sie bewusst zwei unabhängige Texte
bleiben. Das Ergebnis ist ein ADR-Bezug (bestätigte Lesart von
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) oder eine
Folge-ADR) und, darauf aufbauend, ein oder mehrere schneidbare Folge-Slices
für die Umsetzung. **Dieser Slice liefert selbst keine Code- oder
Spec-Änderung.**

**Herkunft der Frage:** Ursprünglich Teil von
[slice-109](../done/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) §1
("Die Frage vor dem Code: wer leitet von wem ab", Frage A/B). slice-109
bleibt bestehen und liefert die zwei kleinen, von dieser Frage unabhängigen
Korrekturen (Zutat-Satz, `program`-Notiz); dieser Slice übernimmt **nicht**
den ganzen Gegenstand von slice-109 — er ist kein `Übernimmt:` im Sinne von
Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice, dessen
Gegenstand ein anderer übernimmt, weil slice-109 selbst nicht endet,
sondern nur enger geschnitten wird.

**Warum das jetzt eine Architektur-Frage ist, und nicht mehr nur eine
Planungs-Frage:** Es gibt **26** Datenzeilen in Spec §5
(`sed -n '/^| ID | Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep -c '^| \`'`)
für dieselben **32** Felder des Trägers
(`grep -c '{Field: "' internal/span/fieldlist.go`) — **6** Zeilen führen zwei
Feld-Literale
(`sed -n '/^| ID | Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep '^| \`' | awk -F'|' '{n=gsub(/\`[a-z_0-9]+\`/,"&",$3); if(n>1) c++} END{print c}'`). Ein Wächter, der Wortgleichheit über allen 26 Zeilen prüft,
existiert nicht (das ist selbst der Sensor-Gegenstand von DoD (1) in
slice-109, dort keine Spec-Zeile mehr berührend); die folgende Zahl ist darum
ein **berichtetes**, nicht ein hier gefahrenes Ergebnis: Ein erster
Implementer-Durchgang meldete **4 von 26** wortgleiche Zeilen (`ts`, `tool`,
`tool_use_id`, `status`), die übrigen **22** wortverschieden. Die
Planner-Prüfung dieser Neuplanung (2026-09-27) verifizierte das an einer
**Stichprobe von acht** Zeilen manuell nach — reproduzierbar durch Lesen der
genannten Zeilen in beiden Dateien, nicht durch ein Kommando — und bestätigt
die Richtung, differenziert aber die Kategorie: ein Teil der Nicht-Wortgleichen
ist reine Umformulierung derselben Aussage (`seq`, `slice`), ein Teil ist
strukturell verschieden — die Spec fasst `session`/`agent` in **eine** Frage
("Welcher Lauf war es?"), der Träger stellt für `agent` eine **zweite**,
eigene Frage ("Welcher Agent innerhalb des Laufs?"), die in der Spec-Zeile
nicht auftaucht — und ein Teil trägt in der Spec deutlich mehr **Substanz**
als im Träger (`program`/`argc`: die Spec-Zeile SPEC-021 beschreibt die
Wortgrenzen-Regel über mehrere hundert Wörter inklusive aller Rand-Fälle;
die Trägerfassung ist bewusst terser Adopter-Text). Eine reine
"erzeugt"-Antwort (Vorbild [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert))
kürzt entweder die Spec auf Adopter-Kürze (Substanzverlust im Rang-2-Stratum)
oder bläht den emittierten Text mit interner Governance-Prosa auf; eine
"verglichen, wortgleich"-Antwort verlangt einen Parser über der Markdown-
Tabelle, der bei unbekannter Zeilenform fail-closed abbricht
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
und würde bei der heutigen Divergenz sofort und dauerhaft rot laufen, bis
alle 32 Fragen händisch angeglichen sind; eine dritte, bisher nicht in Frage A
enthaltene Antwort — "verglichen, mit einem Wächter unterhalb von
Wort-Identität, der dieselbe **Kernaussage** prüft" — verlangt eine
**inferentielle** statt einer computational Prüfung (Baseline-Regelwerk
`modul-11-verification.md` §Fitness Function ohne Standard-Tool, Zeile
"Doku-Konsistenz-Agent … wenn semantische Prüfung nötig ist"). Welche der
drei Antworten trägt, hängt an einer Kosten-Nutzen-Abwägung über eine
Sensor-Schicht — das ist eine Entscheidung, die [`modul-08-agentenrollen.md`](../../../../.harness/baseline/v6.9.0/regelwerk/modul-08-agentenrollen.md)
§Rollen-Regeln dem Architect zuweist, nicht dem Planner und nicht dem
Implementer, der sonst eine Sensor-Architektur "nebenbei" im Diff entscheidet.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Die eigentliche Umsetzung (Kopplungs-Code, Spec-Umbau, neuer Wächter) —
  **ein Folge-Slice übernimmt es**, geschnitten erst nach dem Verdikt; seine
  Form (ein Slice oder mehrere) hängt selbst an der Antwort und lässt sich
  vorher nicht sinnvoll benennen. Ein hier vorab geschnittener Umsetzungs-
  Slice hätte eine Existenzberechtigung, die von der noch offenen Antwort
  abhängt — genau das vermeidet dieser Zuschnitt.
- Die zwei kleinen, unabhängigen Korrekturen (Zutat-Satz `limitStore`,
  `program`-Notiz) — **bleiben bei slice-109**, weil sie ohne diese
  Architektur-Entscheidung entscheidbar und umsetzbar sind; sie hier
  mitzuführen verzögerte eine bereits fällige Korrektur um die Dauer der
  Architektur-Frage.
- Eine Entscheidung über die vierte Spalte von §5 (Sensor-Bindung) als
  eigener Punkt — **Bestand bleibt stehen**: Sie ist laut
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  bereits als Feedforward gemessen und ungebunden; dieser Slice trägt sie nur
  als **Kostenfaktor** der Antwort auf Frage A, entscheidet sie aber nicht
  gesondert.

## 2. Definition of Done

Ein slice-eigener Punkt (Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: ≤ 3).

- [x] **(1) Frage A/B aus slice-109 §1 ist mit einem ADR-Bezug beantwortet**
      **— erfüllt mit einer `Proposed`-, nicht `Accepted`-ADR:** Der Wortlaut verlangt „mit einem
      ADR-Bezug beantwortet", nicht „mit einer `Accepted`-ADR"; `ADR-0071` trifft die Entscheidung
      neu und ist damit der verlangte Bezug. Die **Annahme** von `ADR-0071` bleibt eine offene
      Handlung des Auftraggebers ([`AGENTS.md`](../../../../AGENTS.md) §3.4) und bindet erst den
      Folge-Slice (siehe dort §4 Trigger), nicht diesen DoD-Punkt.
      — entweder bestätigt [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md)
      eine der drei Lesarten (erzeugt / verglichen wortgleich / verglichen
      auf Kernaussage), oder eine Folge-ADR (`supersedes` bzw. ergänzend,
      [`AGENTS.md`](../../../../AGENTS.md) §3.4) trifft die Entscheidung neu.
      Das Verdikt benennt zusätzlich, **welcher Umsetzungsaufwand** daran
      hängt (ein Folge-Slice reicht, oder es sind mehrere — Kopplung
      getrennt von Wortlaut-Angleichung, Baseline-Regelwerk
      `modul-05-planning-harness.md` §4-Rückführungs-Vorbild "Dann sind es
      zwei Slices").
      **Rot:** kein Kommando färbt diesen Punkt rot — die Prüfung ist
      inferentiell (Modul 8 Rollen-Sequenz "Planner→Architect→Planner",
      Übergabe-Artefakt ist das Verdikt selbst, kein Test).

Standard-Punkte der Vorlage gelten mit einer Einschränkung: **kein**
`make gates`-Punkt (dieser Slice ändert keinen Code und keine Spec-Zeile),
**kein** Reviewer-Diff (nichts zu diffen). Was bleibt: Closure-Notiz mit
Steering-Loop-Lerneintrag, Beobachtungs-Register fortgeschrieben, jedes
Risiko aus §6 trägt einen Ausgang.

## 3. Plan (vor Code)

Kein Code-Plan — der einzige "Artefakt" ist das Architect-Verdikt.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/0013-technik-stratum-als-zielort.md`](../../adr/0013-technik-stratum-als-zielort.md) | **gelesen, nicht editiert** (Accepted — [`AGENTS.md`](../../../../AGENTS.md) §3.4) | Bezugspunkt des Verdikts |
| neue Folge-ADR, falls das Verdikt keine Lesart von [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) bestätigt | neu | trägt die Entscheidung über die Sensor-Schicht |

## 4. Trigger

**Start** (`open` → `next` → `in-progress`): Dieser Slice kann formal jederzeit
begonnen werden — es gibt kein WIP-Limit-Hindernis. Er liegt trotzdem bewusst
in `open/`, nicht in `next/`: Priorisierung (`Verantwortlich:` setzen) ist eine
eigene Planungs-Entscheidung, die diese Übergabe nicht vorwegnimmt.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich beim
  Formulieren der Optionen für den Architect zeigt, dass mehr als eine
  Kosten-Nutzen-Abwägung ansteht (z. B. eine zusätzliche Frage über die
  vierte Spalte von §5, die eine eigene Verdikt-Runde braucht). Signal: die
  Übergabe an den Architect trägt mehr als eine offene Entscheidung.
- `in-progress` → `open` (blockiert): wenn das Architect-Verdikt selbst eine
  Vorentscheidung braucht, die nicht in diesem Repo liegt (z. B. eine
  externe Norm-Frage). Signal: der Architect kann ohne zusätzliche externe
  Klärung nicht entscheiden.

## 5. Closure-Trigger

ADR-Bezug (bestätigt oder Folge-ADR) liegt vor; Closure-Notiz mit
Steering-Loop-Eintrag; jedes Risiko aus §6 trägt einen Ausgang;
Folge-Slice(s) für die Umsetzung sind benannt (derivativ — die Datei selbst
entsteht als eigener Planungs-Zug, nicht als Teil dieser Closure).

## 6. Risiken und offene Punkte

- **Eine Kopplung kann zirkulär werden, und dann misst sie nichts.** Wer §5
  aus dem Träger erzeugt **und** den Wächter gegen die erzeugte Datei hält,
  vergleicht zwei Ausgaben derselben Funktion — dieselbe Bauart, die
  [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) §7 schon einmal
  gemessen hat. Das Verdikt muss benennen, **an welchen zwei verschiedenen
  Artefakten** ein Vergleich hängt. — **Ausgang: entfallen.** Das Verdikt (§4 Risiko 1)
  adressiert es durch die Wahl selbst: Option E kombiniert **nicht** „erzeugt" mit einem
  nachgelagerten Vergleich, sondern hängt an zwei echt unabhängigen, von Hand gepflegten
  Artefakten (`fieldlist.go`, `spec/spezifikation.md` §5) plus einem dritten, dem Skript selbst,
  das keines der beiden erzeugt — genau die Bauart, die [slice-096](../done/slice-096-traeger-liegt-im-ziel.md)
  §7 als zirkulär entlarvt hat, bleibt vermieden.
- **Die vierte Spalte von §5 ist der teuerste Teil und der leiseste.** Sie
  bindet je Zeile einen Wächter, und kein Gate hält sie
  ([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)).
  Eine Erzeugung, die sie überschreibt, löscht eine Bindung, die niemand
  vermisst. — **Ausgang: entfallen.** Das Verdikt (§4 Risiko 2) lehnt Option 1 („erzeugt") ab;
  der gewählte Existenz-Sensor generiert nichts und überschreibt nichts, die vierte Spalte bleibt
  exakt, was sie heute ist — von Hand gepflegt, ungebunden ([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  unverändert, im Verdikt §0/§5 selbst nachgemessen).
- **Der Wortlaut zweier Fassungen anzugleichen heißt, einen davon zu
  wählen.** Die Fassung im Träger geht ins Repo des Adopters, die in §5 ist
  für uns. Wer sie zusammenzieht, schreibt entweder Adopter-Sprache in ein
  normatives Dokument oder Repo-Sprache in ein fremdes. — **Ausgang: entfallen.** Das Verdikt
  (§4 Risiko 3) löst es, statt es weiter offen zu lassen: Es wird **keiner** der beiden Wortlaute
  an den anderen angeglichen — die Kopplung bindet Existenz, nicht Formulierung; beide Register
  (Adopter-terse im Träger, Rang-2-normativ in §5) bleiben unangetastet.
- **`make gates` sieht den Gegenstand nur zum Teil.** Der Doku-Gate prüft
  Kennungen, Anker und Pfade; zwei Fassungen derselben Aussage sind grün,
  unabhängig davon, ob sie dieselbe Aussage tragen. — **Ausgang: weiter offen →
  Beobachtungs-Register.** Das Verdikt (§4 Risiko 4) adressiert die erste Hälfte nur
  **teilweise**: Der benannte Existenz-Sensor ([slice-feldabdeckung-existenz-sensor](../open/slice-feldabdeckung-existenz-sensor.md))
  deckt, sobald gebaut, die Teilmenge *„ein Feld fehlt komplett auf einer Seite"*, nicht die
  Kernaussage-Teilmenge — bewusst als akzeptiertes Negativ in `ADR-0071` §Konsequenzen benannt.
  Die zweite Hälfte — Zuordnung zur bestehenden Beobachtung
  [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md) —
  ist **entschieden, nicht mehr offen**: Das Verdikt urteilt **NICHT dieselbe Beobachtung**
  (dort sollen zwei Fassungen identisch sein, hier dürfen sie in Form und Detailgrad divergieren
  und sollen nur in der Kernaussage übereinstimmen — eine dritte, eigene Fehlerrichtung). Diese
  Closure legt darum eine **neue** Beobachtung an statt einen dritten Beleg an die bestehende zu
  hängen: [`feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`](../observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/observation.md)
  (1×, unter der Schwelle; Beleg `evidence/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md`).

## 7. Closure-Notiz

- **Was hat funktioniert:** Der Zuschnitt trug — der Slice lieferte ausschließlich die
  Architektur-Frage, ohne einen Umsetzungs-Slice vorwegzunehmen (§1: *„Ein hier vorab
  geschnittener Umsetzungs-Slice hätte eine Existenzberechtigung, die von der noch offenen
  Antwort abhängt"*). Das Verdikt beantwortet alle vier Risiken aus §6 einzeln und benennt den
  Umsetzungsaufwand korrekt als **einen** Folge-Slice, nicht zwei — anders als das im Slice
  selbst benannte Vorbild („Dann sind es zwei Slices") befürchtete, weil Option E keine
  Wortlaut-Angleichung verlangt und der teure zweite Schnitt strukturell entfällt.
- **Was ging anders als geplant:** DoD (1) ist mit einer **`Proposed`-**, nicht
  `Accepted`-ADR erfüllt — der Wortlaut verlangt nur „mit einem ADR-Bezug beantwortet", die
  Annahme von `ADR-0071` bleibt eine offene Handlung des Auftraggebers. Der bindende ADR-Bezug
  des Folge-Slice hängt daran (dort §4 Trigger). Außerdem bestätigte das Verdikt **keine** der
  drei im Slice vorgezeichneten Lesarten unverändert, sondern wählte eine vierte (Option E,
  bidirektionaler Existenz-Abgleich) — der Slice hatte die Optionsmenge nicht vollständig
  vorweggenommen.
- **Steering-Loop-Eintrag (Form: neuer Sensor, geplant — nicht verkörpert).** Die Regel *„die
  Kopplung zwischen Feldliste im Träger und Spec §5 ist ein bidirektionaler Existenz-Abgleich,
  keine Wortgleichheit, keine Erzeugung"* steht in `ADR-0071` (Proposed). Ihre Verkörperung als
  Sensor ist mit [slice-feldabdeckung-existenz-sensor](../open/slice-feldabdeckung-existenz-sensor.md)
  benannt, aber weder die ADR angenommen noch der Sensor gebaut — **kein** `liegt in`-Feld, weil
  nichts verkörpert ist (Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker: das
  Feld steht nur, wenn mit diesem Slice wirklich etwas verkörpert wurde). Auslöser ist die
  Architekturfrage aus [slice-109](../done/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md)
  §1 (Frage A/B), kein 3×-Register-Eintrag.
- **Beobachtungs-Register (`../observations/`):** `BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/`
  neu angelegt, Beleg `evidence/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md`
  — Zähler steht bei 1×. Empfehlung des Architect-Verdikts (§4 Risiko 4) befolgt: **kein** dritter
  Beleg an `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`, weil die Fehlerrichtung
  eine andere ist (dort: zwei Fassungen sollen identisch sein; hier: zwei Fassungen dürfen in Form
  divergieren, sollen aber in der Kernaussage übereinstimmen).
- **Folge-Slices:** [slice-feldabdeckung-existenz-sensor](../open/slice-feldabdeckung-existenz-sensor.md)
  (Bidirektionaler Existenz-Abgleich zwischen Feldliste im Träger und Spec §5) — ist eine Datei in
  `open/`, blockiert bis `ADR-0071` `Accepted` ist (dort §4 Trigger).
- **Risiken aus §6:** vier, je ein Ausgang — drei *entfallen* mit Begründung (Risiko 1 zirkuläre
  Kopplung vermieden, Risiko 2 vierte Spalte unverändert, Risiko 3 Wortlaut-Frage gelöst statt
  angeglichen), eines *weiter offen* → Beobachtungs-Register (Risiko 4, erste Hälfte —
  Doku-Gate-Blindheit für die Kernaussage-Achse bleibt bestehen; die zweite Hälfte des Risikos,
  die Register-Zuordnungsfrage, ist mit der neuen Beobachtung oben entschieden, nicht mehr offen).
- **Drei Paarungen** (nach dem Move gegen `done/` von Hand geprüft, 2026-09-27; ein Wächter dafür
  existiert nicht): **(a) Anker** — §7 trägt kein Feld `liegt in <Zielort>` (nichts wurde mit
  diesem Slice verkörpert, siehe Steering-Loop-Eintrag oben); die Paarung hat für diesen Slice
  keinen Gegenstand und ist **nicht** als getragen behauptet. **(b) Folge-Slice** — genannt:
  `slice-feldabdeckung-existenz-sensor` existiert als Datei im Planning-Lifecycle
  (`ls docs/plan/planning/*/slice-feldabdeckung-existenz-sensor.md` → Treffer in `open/`).
  **(c) Register, erste Hälfte** — die neu angelegte Beobachtung
  `BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor` existiert
  als Verzeichnis und trägt ein nicht leeres `evidence/`
  (`ls docs/plan/planning/observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/evidence/*.md | wc -l`
  → 1). **(c) Register, zweite Hälfte: 4 Verzeichnisse ohne Beleg, unverändert gegenüber der
  letzten Messung, namentlich `ci-rennt-gegen-die-publikation-des-gepinnten-releases`,
  `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet**
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`;
  das Register führt 193 Verzeichnisse,
  `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`; keine Erwartungswerte). Nennen ist
  keine Tilgung: dieser Slice liefert keinen Beleg für sie.
  Wahr ist die DoD-Zeile damit für (b) und die erste Hälfte von (c), nicht für (a) und nicht für
  die zweite Hälfte von (c) — dieser Slice führt keine eigene Paarungs-DoD-Zeile in §2 (die
  Standard-Vorlage-Einschränkung dort nennt sie nicht namentlich), das Ergebnis steht deshalb hier,
  nicht als Häkchen.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Eine Sub-Area ist berührt:
`internal/span/` und `spec/` (Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md)). Für die
Zwecke dieses Slice (kein Code, keine Spec-Änderung) ist die Berührung
mittelbar — der Architect entscheidet über künftige Arbeit an diesen
Sub-Areas.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen,
2026-09-27. Ein Treffer:
[`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
(`ls docs/plan/planning/observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/evidence/*.md | wc -l`
→ **2** Belege, unter der Schwelle 3×) — Zuordnung als *dieselbe Beobachtung* ist ein
Urteil, das §6 dieses Slice ausdrücklich offen lässt statt vorwegzunehmen.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (siehe
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md));
kein BF/Hybrid-Block nötig.

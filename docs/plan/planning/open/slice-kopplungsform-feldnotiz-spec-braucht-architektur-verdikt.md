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

**Verantwortlich:** — (noch nicht priorisiert; dieser Slice liegt in `open/`,
weil ihn kein Implementer beginnen kann, bevor der Architect-Zug unten
gelaufen ist).

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
[slice-109](../in-progress/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) §1
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

- [ ] **(1) Frage A/B aus slice-109 §1 ist mit einem ADR-Bezug beantwortet**
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
  Artefakten** ein Vergleich hängt. — **Ausgang:** weiter offen: geht als
  Kriterium in dieselbe Architect-Übergabe ein, kein eigenständiges Risiko
  mehr, sobald das Verdikt vorliegt; bis dahin **weiter offen** →
  Beobachtungs-Register (§7 dieses Slice trägt den Beleg beim Closure).
- **Die vierte Spalte von §5 ist der teuerste Teil und der leiseste.** Sie
  bindet je Zeile einen Wächter, und kein Gate hält sie
  ([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)).
  Eine Erzeugung, die sie überschreibt, löscht eine Bindung, die niemand
  vermisst. — **Ausgang:** weiter offen → Beobachtungs-Register, als
  Kostenfaktor der Architect-Übergabe benannt.
- **Der Wortlaut zweier Fassungen anzugleichen heißt, einen davon zu
  wählen.** Die Fassung im Träger geht ins Repo des Adopters, die in §5 ist
  für uns. Wer sie zusammenzieht, schreibt entweder Adopter-Sprache in ein
  normatives Dokument oder Repo-Sprache in ein fremdes. — **Ausgang:**
  weiter offen → Beobachtungs-Register; das ist der Kern der Architect-Frage
  selbst, kein Nebenrisiko.
- **`make gates` sieht den Gegenstand nur zum Teil.** Der Doku-Gate prüft
  Kennungen, Anker und Pfade; zwei Fassungen derselben Aussage sind grün,
  unabhängig davon, ob sie dieselbe Aussage tragen. — **Ausgang:** weiter
  offen → Beobachtungs-Register. Ob dies dieselbe Beobachtung ist wie
  [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  (Stand 2026-09-27: `ls docs/plan/planning/observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/evidence/*.md | wc -l`
  → **2** Belege, unter der Schwelle 3×) ist ein Urteil, das
  dieser Slice nicht vorwegnimmt — dort geht es um eine Regel, die zweimal
  als *Code* liegt (Dogfood-Fassung/Emissions-Vorlage), hier um eine Frage,
  die zweimal als *Prosa* liegt (Träger/Spec). Wer diesen Slice schließt,
  entscheidet das explizit, statt es implizit mitzuzählen.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

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

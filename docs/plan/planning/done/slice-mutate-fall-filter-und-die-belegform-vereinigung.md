# Slice slice-mutate-fall-filter-und-die-belegform-vereinigung: `make mutate` fährt auf Nachfrage nur die genannten Fälle, und die Vereinigung zweier Läufe hat eine Regel

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057) Setzung 1 — ein freier Slug in
lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt:
kein repo-weiter Beleg über die Slice-DoDs hinaus, kein Replay; damit fehlt das *Mehr*, an dem sich
eine Welle entscheidet (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Der Schwester-Slice
[slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar](../open/slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar.md)
ist einzeln lieferbar und bildet mit diesem kein Bündel.

**Ebene: Dogfood, nicht emittiert.** `harness/tools/mutate.sh` ist Werkzeug **dieses** Repos
(`grep -rl 'mutate\.sh' internal | wc -l` → 0); kein Zielrepo bekommt es.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Zusage *jeder gelistete Wächter färbt rot* hat einen
Beleg; wo er sich nur aus mehreren Läufen zusammensetzt, sagt die Regel, unter welchen Bedingungen
das eine Aussage bleibt und kein Beleg wird),
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (**Proposed** —
die Fitness-Zeile *ein Lauf mit Befund hinterlässt keinen Beleg* und die Festlegung 4 (der Rest, den
kein Schlüssel deckt, bleibt benannt); die Annahme der ADR ist keine Bedingung des Slice),
[`MR-025`](../../../../harness/conventions.md#mr-025) (jede Zahl dieses Plans steht neben dem
Kommando, das sie liefert),
[`MR-071`](../../../../harness/conventions.md#mr-071) (die Fall-Anlage misst ihr `sed`-Muster gegen
den Quell-Bestand).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein Werkzeug
dieses Repos).

**Verantwortlich:** Implementer (pt9912).
<!-- BEDIENHINWEIS: Verantwortlich hält die Arbeit — der Rolleninhaber der
Implementer-Rolle, gesetzt beim Übergang open→next (Baseline-Regelwerk
modul-05-planning-harness.md §Lifecycle als State Machine). Der Autor schrieb
den Plan; zwei Felder, zwei Fragen. Kein Statuswert: der Zustand bleibt das
Verzeichnis. Kein Sensor prüft das Feld — es ist Deklaration. -->

**Autor:** Planner. **Datum:** 2026-09-25.

---

## 1. Ziel und Abgrenzung

<!-- BEDIENHINWEIS: Ziel = ein Satz, Liefer-Fokus, kein "wir machen
aufraeumen". Abgrenzung = je Punkt eine Begruendung, nicht nur eine Nennung:
ein Ausschluss ohne Grund ist eine Behauptung. Keine Mindestzahl — ein echter
Ausschluss ist besser als vier erfundene. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `MUTATE_CASES=<Namen…>` fährt nur die genannten Fälle, ohne den Beleg-Slot zu schreiben oder
zu löschen und ohne sich als Beleg auszugeben; das Sensor-Doc nennt die Vereinigung zweier Läufe am
identischen Prüfgegenstand als zulässige Aussage des Verifiers — mit ihren Bedingungen und ihrer
Grenze.

**Der Befund, an dem der Schnitt hängt.** Ein voller Lauf, der Bilder baut und Container startet,
endete zweimal am selben Baum mit Befunden aus der Infrastruktur: `425 ok, 8 Befund(e)` (acht
Zeitüberschreitungen beim Bild-Bau) und `432 ok, 1 Befund(e)` (ein Container „marked for removal");
kein einzelner Lauf war grün, die Vereinigung der `ok`-Mengen deckte alle Fälle
(`ls docs/plan/planning/observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/evidence | wc -l`
→ 1, unter der Schwelle). Der Sensor führt keinen Fall-Filter; wer *einen* Befund nachsehen will,
fährt den ganzen Satz erneut (`ls test/mutations/*.sh | wc -l` → 440; keine Erwartungswerte). Ein
Nachsehen-Lauf zerstört dabei einen stehenden Beleg: `main()` löscht den Slot bedingungslos, sobald
der Lauf nicht übersprungen wird (`grep -n '^  clear_belief$' harness/tools/mutate.sh` → 1559; die
Zeile wandert) — auch ein Nachsehen ohne Absicht, einen Beleg zu widerlegen.

**Was der Teillauf mit dem Slot tut, ist hier entschieden, nicht dem Implementer überlassen:**
*nichts.* Der Slot trägt die Aussage „der letzte **volle** Lauf über diesem Schlüssel war grün"; nur
ein voller Lauf schreibt sie, und nur ein voller Lauf löscht sie. Ein Teillauf, der über
identischem Schlüssel rot wird, widerlegt den Slot nicht von selbst — die Ursache kann dieselbe
Infrastruktur sein, um die es geht —, und er meldet seinen Befund laut über Exit und Ausgabe (§6, R2).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Belegform *Teil-Beleg*: ein Teillauf schreibt den Slot** — *es wäre die falsche Aussage:* ein
  grüner Teillauf beantwortet weniger als der Slot behauptet
  ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md), Fitness-Zeile
  *ein Lauf mit Befund hinterlässt keinen Beleg* und Festlegung 2). Ein kumulativer Beleg über
  mehrere Läufe ist eine neue Entscheidung des Architects (Folge-ADR); hier keine Adresse.
- **Ein Auto-Retry** — *es wäre eine Änderung des Verdikts:* ein Retry-Muster, das einen roten Fall
  wiederholt, verdeckt den echten Befund, und eine Muster-Liste hat keine Zähne, die sie bewachen.
- **Die Vereinigung als Mechanismus** (ein Sammler, der zwei Läufe verrechnet) — *sie bleibt eine
  Aussage:* ein Mechanismus wäre ein zweiter Beleg-Slot, wo der Treiber genau einen führt
  (`harness/tools/mutate.sh` Kopf: *EIN Beleg-Slot, nicht einer je Schlüssel*).
- **Die Ursache der Infrastruktur-Rots** (Registry-Zeitüberschreitung, Daemon-Zustand) — *sie liegt
  außerhalb des Repos*; die Beobachtung nennt sie als Ursache jenseits eines Wächters.
- **Die Beleg-Prüfung ohne Lauf und die Verengung der Bezugsmenge** — *ein Folge-Slice übernimmt es:*
  [slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar](../open/slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar.md)
  führt beides; die Reihenfolge der beiden Slices ist frei.

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

<!-- BEDIENHINWEIS: je Zeile ein pruefbares Kriterium. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei Liefer-Punkte; jedes Gegenbeispiel steht beim Punkt, den es bewacht, und ist **rot zu sehen**,
mit gelesener Meldung ([`AGENTS.md`](../../../../AGENTS.md) §3.6), nicht nur als Name im Bericht.

- [x] **Liefer-Punkt 1 — der Filter, fail-closed.** `MUTATE_CASES=<Namen…>` fährt nur die genannten
      Fälle. Ein Name ist der Fall-Name, wie ihn `mutate: BEFUND  <fall>` nennt (ein Name aus der
      Ausgabe ist ohne Umformung wieder eingebbar); ein **unbekannter** Name, ein **leerer** Wert
      (gesetzt, aber ohne Namen) und ein **doppelter** Name enden mit `mutate: ABBRUCH — …` und dem
      Namen, **bevor** eine Isolationskopie entsteht — der Treiber führt nach `make` dieselben
      Sperren-Exits wie alle übrigen (Skript 1, über `make` 2). **Gegenbeispiele:** (a) ein Fall in
      `test/mutate-driver.bats` je Form (unbekannt, leer, doppelt): Exit 1, Meldung nennt den Namen,
      keine Isolationskopie; die Mutation *der Filter überspringt unbekannte Namen still* färbt den
      Fall *unbekannt* rot. (b) Ein Teillauf fährt **trotz** stehendem Beleg zum aktuellen Schlüssel —
      der Filter ist explizit, kein Übersprung; die Mutation *der Übersprung greift auch mit Filter*
      färbt den Fall rot.
- [x] **Liefer-Punkt 2 — der Teillauf ist erkennbar keiner Beleg und berührt den Slot nie.** Die
      Ausgabe eines Teillaufs nennt `TEILLAUF <n> von <total> — kein Beleg`, den Prüfgegenstand-Schlüssel
      (`belief_key`; ist er nicht berechenbar, sagt die Meldung das statt ihn zu erfinden) und die Namen
      der `ok`-Fälle. Ein Teillauf **schreibt** den Slot nie (auch bei grün nicht), **löscht** ihn nie
      (auch bei Befund nicht) und führt die Sofort-Entwertung nicht aus; sein Exit ist der eines Laufs
      (0: jeder gewählte Fall `ok`; 1: mindestens ein Befund). **Gegenbeispiele:** (c) ein Fall je
      Schreiben und Löschen: bei grünem Teillauf bleibt ein fehlender Slot fehlend, bei Teillauf mit
      Befund bleibt ein stehender Slot **byte-gleich**; die Mutation *`finalize_belief` schreibt auch im
      Teillauf* und die Mutation *die Sofort-Entwertung läuft auch im Teillauf* färben je ihren Fall rot.
      (d) Die Zeile `TEILLAUF … kein Beleg` ist der einzige Wächter gegen ein zitiertes Grün: ein Fall
      liest die **Ausgabe** eines grünen Teillaufs; die Mutation *die Meldung sagt „Beleg"* färbt ihn rot,
      und die gelesene Meldung nennt das fehlende „kein Beleg" — nicht irgendeinen Fehler.
- [x] **Liefer-Punkt 3 — die Regel der Vereinigung.** `harness/sensors/mutate.md` nennt, wann zwei
      Läufe zusammen eine Aussage im Verifikationsbericht tragen — **zulässig nur, wenn** (i) beide
      Läufe denselben Prüfgegenstand-Schlüssel nennen, (ii) jeder nicht-`ok` Fall des Hauptlaufs eine
      **gelesene** Ursache trägt, die nicht dem Fall entstammt (Rot aus dem falschen Grund: die
      Fehler-Form passt nicht zum erwarteten Wächter), und im Teillauf `ok` ist, (iii) die Aussage im
      Bericht steht, nie im Slot. **Grenze, im selben Abschnitt:** sie sagt etwas über den Ausschnitt
      jedes Laufs, nicht über einen einzelnen grünen Vollauf; der Docker-Cache-Rest von
      [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4
      gilt weiter; und die Kosten des Teillaufs nennt sein eigener Bericht (`report_times`), keine Zahl
      im Text. Ein Absatz im Sensor-Doc zum Filter (Aufruf, Sperren) gehört dazu. **Gegenbeispiel:**
      (e) `make docs-check` grün — die Regel ist Prosa, und kein Doku-Modul hält ihren Inhalt; der
      Träger ist die Rolle, die den Beleg liest, und das steht im Absatz.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

<!-- BEDIENHINWEIS: Datei- oder Komponenten-Ebene reicht; der
Implementer-Agent erweitert die Liste in seinem ersten Lauf, inklusive
einer Testdatei-Zeile mit der Akzeptanzkriterien-ID in `Begründung`
(Modul 9 §Minimal Agent Workflow). -->

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Filter auf die Fall-Aufzählung in `main()` (vor `total`); Teillauf-Zweig an Übersprung, Sofort-Entwertung und `finalize_belief`; die `TEILLAUF`-Zeile |
| `test/mutate-driver.bats` | update | Sperren-Fälle (a), Übersprung-Fall (b), Slot-Fälle (c), Meldungs-Fall (d) |
| `test/mutations/` | neu | je ein Fall für *schreibt im Teillauf*, *entwertet im Teillauf* und *sagt „Beleg"* (Anlage nach [`MR-071`](../../../../harness/conventions.md#mr-071)) |
| `harness/sensors/mutate.md` | update | Filter, Sperren, `TEILLAUF`-Ausgabe, Regel der Vereinigung samt Grenze (Punkt 3) |
| `Makefile` | nur falls nötig | das Rezept `mutate` reicht heute allein `MUTATE_JOBS` explizit durch; ob `MUTATE_CASES` das Skript über `make mutate MUTATE_CASES=…` erreicht, belegt der Implementer an einem Aufruf |

Ansatz als Liste:

- Der Filter wirkt auf die Fall-Liste, nicht auf die Worker: was danach `total` heißt, ist die Zahl
  der gewählten Fälle, und `merge_report` prüft gegen sie — der Teillauf behält die
  Vollständigkeits-Prüfung über *seine* Menge.
- Der Teillauf verzweigt an **drei** Stellen von `main()` (Übersprung, Sofort-Entwertung,
  `finalize_belief`); jede bekommt ihr Gegenbeispiel in Punkt 2.

**Stand der Closure (2026-09-26): gebaut über die Tabelle hinaus.** `harness/tools/mutate.sh` nennt den
Prüfgegenstand-Schlüssel auch im **vollen** Lauf (`report_key`, nach dem Bericht, auch bei einem Befund;
`grep -n 'report_key' harness/tools/mutate.sh`), damit Bedingung 1 der Vereinigungsregel für den Hauptlauf
erfüllbar ist; die Zeile ändert weder Verdikt noch Slot noch Exit noch die Bezugsmenge des Schlüssels.
`test/mutations/` trägt sechs Fälle statt der drei der Tabelle (`ls test/mutations/45[3-8]*.sh | wc -l` → 6:
schreibt, entwertet, sagt „Beleg", Übersprung mit Filter, unbekannter Name still, Schlüssel im vollen Lauf), und
`test/mutate-driver.bats` trägt elf Tests für Filter, Teillauf und Schlüssel (`grep -c '^@test' test/mutate-driver.bats`
→ 68 insgesamt, Nummern 58 bis 68 sind die neuen; keine Erwartungswerte). Das `Makefile` blieb unberührt:
`MUTATE_CASES` erreicht das Skript über `make mutate` ohne Änderung.

## 4. Trigger

<!-- BEDIENHINWEIS: Beispiele — "Wenn Welle X done." / "Wenn Carveout CO-NN
aufgeloest." -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Auftraggeber priorisiert (`open → next`) und setzt
`Verantwortlich:`; kein anderer Slice liegt in `in-progress/` (WIP-Limit). Keine Vorbedingung aus
einem anderen Slice; die Annahme von
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist keine.

**Adress-Messung vor dem Move** ([`AGENTS.md`](../../../../AGENTS.md) §3.11): kein eingefrorenes
Artefakt (`docs/plan/adr/**`, `docs/reviews/**`, `done/**`) nennt diese Datei als Pfad, weder mit
`open/` als Code-Span noch als Markdown-Link
(`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-mutate-fall-filter-und-die-belegform-vereinigung\.md|open/slice-mutate-fall-filter-und-die-belegform-vereinigung|\]\(slice-mutate-fall-filter-und-die-belegform-vereinigung' . | grep -v 'planning/done/slice-mutate-fall-filter-und-die-belegform-vereinigung.md' | wc -l`
→ **2**, gemessen 2026-09-26). Beide Treffer stehen im Schwester-Slice in `open/`, einem änderbaren
Artefakt: `make slice-mv` zieht den präfixlosen Link dort nach.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Teillauf-Zweig verzweigt an mehr als
  den drei Stellen, die §3 nennt, oder eine Review-Sitzung prüft ihn nicht in einem Zug; dann
  trägt der Filter (Punkt 1) allein und der Teillauf-Zweig (Punkt 2) wird ein eigener Slice.
- `in-progress` → `open` (blockiert): die Vereinigungsregel (Punkt 3) braucht eine Entscheidung, die
  der Architect nicht geben kann, ohne die Belegform selbst zu ändern (ein Mechanismus statt einer
  Aussage) — dann ist zuerst die Folge-ADR zu schreiben, und der Plan wird geändert, nicht
  weitergebaut.

## 5. Closure-Trigger

<!-- BEDIENHINWEIS: z.B. "DoD vollstaendig + PR gemerged + Closure-Notiz
geschrieben." -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die Gegenbeispiele (a) bis (d) sind rot gesehen; ein realer Teillauf
(`make mutate MUTATE_CASES=<ein bekannter Fall>`) endet grün mit der Zeile `TEILLAUF … kein Beleg` und
lässt den Slot unverändert (gelesen an der Ausgabe und an der Schlüsseldatei
`.harness/state/mutate-passed.key`); Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben. Der
Lerneintrag ist die **Regel der Vereinigung** (`liegt in` `harness/sensors/mutate.md`); die
Beobachtung `BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt` bekommt bei
der Closure ihren Beleg nur, wenn der Slice selbst einen weiteren Vorgang dieser Klasse erlebt hat —
ihr Zähler wird nicht durch das Schließen dieses Slice erhöht.

## 6. Risiken und offene Punkte

<!-- BEDIENHINWEIS: Was koennte schief gehen? Welche Carveouts entstehen
ggf.? Die drei Ausgaenge stehen als Form in der Zeile darunter. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **R1 — ein grüner Teillauf wird als Beleg zitiert.** Die Zeile `TEILLAUF … kein Beleg` und die
  Regel in `harness/sensors/mutate.md` sind der einzige Wächter; ein Test hält sie (Gegenbeispiel (d)),
  ein Leser, der die Ausgabe nicht liest, wird davon nicht erreicht. — **Ausgang:** *weiter offen* →
  [`BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`](../observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/observation.md)
  (Träger ist der Lauf, der den Beleg liest; ein Wächter besteht nicht). Die Zeile ist gehalten und rot gesehen: Fall 455
  färbt Test 66 mit der gelesenen Meldung *„die Ausgabe nennt kein 'TEILLAUF 1 von 3 — kein Beleg'"*. Das Register führt
  keinen neuen Beleg: kein Vorgang zitierte einen Teillauf als Beleg.
- **R2 — ein Teillauf mit Befund über identischem Schlüssel lässt einen stehenden Slot stehen.** Der
  Slot sagt weiter *„der letzte volle Lauf war grün"*, und das bleibt als Aussage über den früheren
  Lauf wahr; der widersprechende Befund steht allein im Exit und in der Ausgabe des Teillaufs. Die
  Alternative — der Teillauf löscht — machte jedes Nachsehen zu dem Vorgang, den die Beobachtung
  beschreibt. — **Ausgang:** *weiter offen* →
  [`BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/observation.md)
  (Stand `geplant`; der Slot bleibt bei einem Befund im Teillauf stehen, gehalten von Test 65 und den Fällen 453 und 454).
  Gebunden an R5 und an die Übergabe R-6 des Reviews an den Architect (Fitness-Zeile der ADR, §7).
- **R3 — ein Fall-Name in einem Bericht veraltet** (Fall umbenannt oder entfernt). Der Filter bricht
  fail-closed mit dem Namen ab (Punkt 1), und der Teillauf, der nichts lief, meldet kein Grün. —
  **Ausgang:** *entfallen* — der Filter bricht fail-closed mit dem Namen ab: acht echte `make`-Läufe (unbekannt, leer,
  doppelt, Pfad-Form, `*`, `-x`, `….sh`, Namen mit Leerraum) enden mit Skript-Exit 1 und `make`-Exit 2, das `TMPDIR` bleibt
  leer, der Slot unberührt (Verifier); Test 58 und Fall 457 halten es.
- **R4 — der Teillauf spart weniger als er verspricht.** Isolationskopie und Grün-Vorlauf fallen je
  Worker an; gespart wird der Fall-Anteil. Was der Teillauf kostet, sagt sein eigener Bericht
  (`report_times`), keine Zahl im Text. — **Ausgang:** *weiter offen* →
  [`BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`](../observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/observation.md)
  (ob das Nachsehen über den Teillauf trägt, hängt an seinen Kosten). Ein Messwert: der reale Teillauf
  `make mutate MUTATE_JOBS=1 MUTATE_CASES=10-ci-workflow-syntax` (Modus `ci-lint`) dauerte 9,559 s; für Fälle im Modus
  `test` (Docker-Stage) ist nichts gemessen.
- **R5 — [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) steht auf
  `Proposed`.** Ändert der Architect bei der Annahme die Fitness-Zeile *ein Lauf mit Befund
  hinterlässt keinen Beleg* oder Festlegung 4, ist der Plan nachzuziehen. — **Ausgang:** *weiter offen* →
  [`BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/observation.md)
  (dieselbe Beobachtung trägt die Annahme der ADR als Bedingung; die ADR steht weiter auf `Proposed`, und nirgends im Diff
  ist sie als `Accepted` behauptet). Eingetreten ist nichts; die Formulierungsfrage der Fitness-Zeile geht an den Architect (§7).

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

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

Geschrieben von der Rolle Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review und
Verifikation. Alle Kommandos gemessen am 2026-09-26, keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025)).

- **Was hat funktioniert:** Der Schnitt hielt: drei Liefer-Punkte, zwei Schichten, keine der beiden Rückführungen aus §4
  ausgelöst. Der Verifier bestätigte Liefer-Punkt 1 und 2 und Liefer-Punkt 3 **mit Vorbehalt** (Stand `a5542c2e`). Am echten
  Treiber gemessen: acht Sperren-Läufe über `make` (Skript-Exit 1, `make` 2, `TMPDIR` leer, Slot unberührt) und ein realer
  Teillauf `make mutate MUTATE_JOBS=1 MUTATE_CASES=10-ci-workflow-syntax` mit Exit 0, `TEILLAUF 1 von 446 — kein Beleg`,
  Schlüssel, `ok-Faelle:` ohne Leerzeichen am Ende, Slot vorher und nachher byte-gleich (`cmp`), 9,559 s. Die Fälle 453 bis 458 und der
  nachgezogene Anker von Fall 263 färben je ihren Test aus dem behaupteten Grund rot (Meldung gelesen); sechs neue Schwächungen
  waren rot und fünf Gegenproben (Assertion geschwächt, Mutation aktiv) grün, also **bindend**. Der Review schloss R-2, R-3 und R-4
  mit Tests, die er vorher überleben sah. **Ergebnis-Fakten:** `grep -c '^@test' test/mutate-driver.bats` → **68**;
  `ls test/mutations/*.sh | wc -l` → **446**; `grep -l '^# files:.*harness/tools/mutate\.sh' test/mutations/*.sh | wc -l` → **33**;
  `git diff --shortstat 09159a4a..4760a5f4 -- harness/tools/mutate.sh test/mutate-driver.bats test/mutations harness/sensors/mutate.md harness/README.md`
  → **11** Dateien, **478** Einfügungen, **14** Löschungen.
- **Was ging anders als geplant:** Der Review (Runde 1; 0 HIGH, 2 MEDIUM, 3 LOW, 4 INFO) fand: R-1 (Bedingung 1 der Regel war für einen
  vollen Lauf mit Befund nicht erfüllbar, weil er keinen Schlüssel nannte), R-2 (die Sperren-Tests prüften ein `TMPDIR`, das der Trap
  leert), R-3 und R-4 (Zähne fehlten), R-5 (Konjunktiv im Kommentar). Der Implementer zog sie in `219fc551`, `b40b06ed` und
  `a5542c2e`; der Verifier fand V-1 bis V-4 (LOW: der Worker-Vorlauf-Abbruch, der Anlass mit zwei vollen Läufen, „Schnittmenge",
  Konjunktive in Kommentaren), gezogen in `4504191a` (Sensor-Doc) und `4760a5f4` (Kommentare). **Wer was gelesen hat:** der Review las bis
  `d20ebcfc`; `219fc551`, `b40b06ed` und `a5542c2e` hat nur der Verifier gelesen und gefahren; **`4504191a` und `4760a5f4` hat weder ein
  Reviewer noch der Verifier gelesen** — der Implementer belegte sie mit den Gates und der Emulation (siehe *Mutate*). Eine zweite
  Review-Runde ist nicht gelaufen und wird nicht behauptet; das Häkchen *Review durchgeführt* bestätigt Runde 1 samt gezogener Findings.
- **Gebaut, nicht geplant — das Urteil.** `report_key` im Zweig des vollen Laufs (Fall 458, Tests 67 und 68) steht weder in der
  §3-Tabelle noch in der DoD. Der Verifier wertete es als im Rahmen: Punkt 3 (i) der DoD verlangt, dass **beide** Läufe den Schlüssel
  nennen, der volle Lauf tat es nicht, also war der Wortlaut der Regel oder die Ausgabe zu ändern; §1 schließt keine Ausgabezeile am
  vollen Lauf aus, und Verdikt-Funktion, Slot, Exit und Bezugsmenge sind unberührt. **Der Planner schließt sich an.** Der DoD-Wortlaut
  bleibt unverändert, weil der Verifier-Befund keine Änderung verlangt — Punkt 3 (i) ist mit der Zeile erfüllt, nicht umgedeutet;
  der Nachzug steht als Zustandsaussage in §3 (*Stand der Closure*). Die Ausgabezeile des vollen Laufs ist Bestandteil des Ausgabe-Vertrags,
  den der Schwester-Slice `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar` mitliest: sein §3 trägt den Abgleich
  als Zustandsaussage; ein Liefer-Punkt dort ändert sich nicht.
- **Ungeprüfte Verallgemeinerung an der Regel — Übergabe.** Der Plan fasste Bedingung 2 asymmetrisch (*jeder nicht-`ok` Fall des Hauptlaufs
  trägt eine gelesene, fall-fremde Ursache und ist im Teillauf `ok`*). Im letzten Nachzug (`4504191a`) fasst `harness/sensors/mutate.md`
  sie **symmetrisch** (*jeder Fall, der in einem der beiden Läufe nicht `ok` ist, trägt dort eine gelesene, fall-fremde Ursache und ist im
  anderen Lauf `ok`*) und lässt die Regel auch für zwei volle Läufe gelten. Das deckt den Anlass (zwei volle Läufe, `425 ok, 8 Befund(e)` und
  `432 ok, 1 Befund(e)`), den der Plan-Wortlaut nicht deckte (V-2); ob die **drei** Bedingungen die Symmetrie tragen, hat **kein Reviewer und kein
  Verifier gelesen**. Der Implementer nennt es selbst eine Verallgemeinerung. Der Wortlaut einer Regel in einem Sensor-Doc ist Architect-Sache, und
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) steht auf `Proposed`: **Übergabe an den Architect und an
  einen Reviewer**. Das Häkchen für Liefer-Punkt 3 gilt dem Stand `a5542c2e` samt Vorbehalt; der Nachzug ist nicht mitbestätigt.
- **Mutate: Teilmessung, keine Gesamtaussage.** *Verifier (Stand `a5542c2e`):* die 33 Bestandsfälle mit `# files:` auf `harness/tools/mutate.sh`
  je einzeln in einer Kopie angewandt und den `# expect:`-Test gefahren: 33 von 33 rot. *Implementer (Stand `4760a5f4`, nach dem Verifier;
  seine Angabe, von keiner anderen Rolle nachgefahren):* die 33 Fälle in Kopien am HEAD angewandt, **9 einzeln bis zum roten Test gefahren,
  24 nur statisch** (der Anker trifft). **Nicht gefahren:** ein voller `make mutate`; **der Beleg-Slot ist nicht geschrieben** (der Verifier fand
  `.harness/state/mutate-passed.key` vorher wie nachher fehlend). Real gefahren ist genau ein Teillauf (`10-ci-workflow-syntax`, 9,559 s,
  `TEILLAUF 1 von 446`). Eine Aussage über das grüne Ganze trägt diese Closure nicht.
- **Nicht gemessen (aus dem Verifikationsbericht):** der Signal-Pfad (`on_signal` nennt keinen Schlüssel — nur `grep`, kein Lauf); der
  Worker-Vorlauf-Abbruch am echten Treiber (V-1: aus dem Code gelesen, kein Test, kein Lauf; die Regel sagt es im Text); die Ordnung der
  `ok`-Namen (sortiert wie das Verzeichnis, gelesen); die Kosten eines Falls im Modus `test`; ein Lauf mit **echtem** Befund am echten Treiber
  (der Befund-Zweig ist nur am Fake-Repo der Tests 65 und 67 gemessen); der volle Lauf und damit *„ein grüner voller Lauf schreibt den Slot mit
  dem Schlüssel"* am echten Satz (nur Test 68); der Docker-Cache-Rest aus
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4, den kein Sensor dieses Slice deckt und
  den die Regel nicht behauptet.
- **Steering-Loop-Eintrag (Form: neuer Sensor).** Der Sensor `make mutate` ist nachsehbar geworden, und die Nachsehen-Bilanz ist lesbar:
  der Filter `MUTATE_CASES` bricht bei unbekanntem, leerem, doppeltem und Pfad-förmigem Namen fail-closed mit dem Namen ab, **bevor** eine
  Isolationskopie entsteht; der Teillauf-Bericht sagt `TEILLAUF <n> von <total> — kein Beleg`, den Prüfgegenstand-Schlüssel und die `ok`-Fälle und
  berührt den Slot nie; `report_key` nennt den Schlüssel im vollen Lauf. Die Zähne: die Fälle 453 bis 458 (schreibt, entwertet, sagt „Beleg",
  Übersprung mit Filter, unbekannter Name still, Schlüssel im vollen Lauf), der nachgezogene Anker von 263 und die Tests 58 bis 68 in
  `test/mutate-driver.bats`, darunter die PATH-Wrapper-Sonde für *„keine Isolationskopie"*. **Kein Sensor hält die Vereinigungsregel:** sie steht als
  Prosa in `harness/sensors/mutate.md` §Zwei Läufe, eine Aussage; kein Doku-Modul liest ihren Inhalt, der Träger ist die Rolle, die den Beleg liest
  (der Verifier). Ein Feld `liegt in` mit Herkunfts-Anker steht hier **nicht**: der Zielort trägt kein `seit slice-…`, und die Regel entstand nicht aus einem
  3×-Übertritt (die auslösende Beobachtung steht bei 1×) — die Paarung (a) hätte nichts, gegen das sie prüft, und der §5 dieses Plans hatte sie als
  `liegt in` angesagt. Ob der Zielort den Anker bekommen soll, ist eine Übergabe (unten), keine Behauptung.
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-mutate-fall-filter-und-die-belegform-vereinigung.md`; Zähler gelesen mit
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Ergänzt:**
  [`negation-mitten-im-bats-fall-ohne-wirkung`](../observations/BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung/observation.md) (**2×**; ein Fund im
  Bestand von `test/mutate-driver.bats`, der Code des Slice meidet die Form),
  [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md) (**3×**, Urteil des Planners:
  der Trap leert die Menge, statt dass sie wegfällt),
  [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  (**4×**, Stand `geplant` für die Instanz `sync`; *leer*, *doppelt*, *Filter wählt alle* und der Pfad-Zweig tragen weiter keinen Fall) und
  [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  (**10×**, Stand `geplant` unverändert; der Vorgang ist der Claim-Commit `372c0ea2`, der den Ruhe-Marker der Roadmap entfernte; der Planner stellt ihn mit dieser Closure wieder her).
  **Neu angelegt (1×, `offen`):**
  [`regel-verlangt-einen-beleg-inhalt-den-die-ausgabe-des-werkzeugs-nicht-liefert`](../observations/BEO-ALL/regel-verlangt-einen-beleg-inhalt-den-die-ausgabe-des-werkzeugs-nicht-liefert/observation.md)
  (R-1). **Nicht gezählt:** die zwei Konjunktiv-Kommentare (R-5, V-4): sie fallen unter [`AGENTS.md`](../../../../AGENTS.md) §3.7, und
  [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  ist bei 17× verkörpert — ob der Konjunktiv über die verworfene Alternative dieselbe Beobachtung ist wie die Erzählung der Entstehung, ist nicht geprüft und
  wird nicht zu ihrem Beleg. Auch **nicht** gezählt:
  [`sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`](../observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/observation.md)
  (**1×**; der Slice erlebte keinen weiteren Vorgang der Klasse, §5), `mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` (**3×**, `geplant`)
  und `baum-hash-deckt-nicht-jeden-pruefgegenstand` (**1×**): der Teillauf fasst den Schlüssel nicht an.
  **Lese-Schritt:** Mit diesem Slice erreicht **ein** Eintrag die Schwelle **3×**, `zusicherung-ueber-der-leeren-menge-wahr`. Ein Ausgang ist ohne Regel-Schreiben nicht
  zuweisbar: `geplant` verlangt die Kennung eines Slice, der die Regel schreibt — keiner besteht —, und `verkörpert` ein Norm-Artefakt des Architect. Der Eintrag bleibt
  `offen` über der Schwelle, mit der Übergabe in seinem `state.md`. Die zwei Einträge über der Schwelle, die dieser Slice ergänzt hat, tragen ihren Ausgang schon
  (`zusage-mit-bats-bindung-…` und `eigentums-frage-…`, beide `geplant`).
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** kein eingefrorenes Artefakt nennt den Slice als Pfad; das Kommando aus §4 trifft außerhalb
  dieser Datei genau die zwei Zeilen im Schwester-Slice in `open/` (ein änderbares Artefakt, `make slice-mv` zieht den Verweis nach). Die Reports nennen die Kennung
  ohne Pfad.
- **Folge-Slices:** keiner neu. Der Schwester-Slice `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar` (`open/`) bleibt, mit dem
  Abgleich in seinem §3. Offen und ohne Slice: die Fälle für *leer*, *doppelt*, *Filter wählt alle* und den Pfad-Zweig (R-7, V-5) — benannt, im Register unter
  `zusage-mit-bats-bindung-…`; der Bestand an `! grep` mitten im Test (`negation-mitten-…`).
- **Risiken aus §6:** fünf, je ein Ausgang — *entfallen* mit Grund: R3; *weiter offen → Register:* R1 und R4
  (`sensor-lauf-endet-rot-…`), R2 und R5 (`mutate-beleg-verfaellt-…`). Keines ist *eingetreten*.
- **Übergaben:** *An den Architect:* (1) R-6 des Reviews: bei der Annahme von
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) die Fitness-Zeile *„ein Lauf mit mindestens einem Befund hinterlässt
  keinen Beleg"* gegen die Slice-Entscheidung *„ein Teillauf mit Befund lässt den Beleg des letzten vollen Laufs stehen"* fassen (Test 65 und die Fälle 453 und
  454 halten sie schon); (2) die symmetrische Bedingung 2 und die Geltung für zwei volle Läufe (oben); (3) der Ausgang für
  `zusicherung-ueber-der-leeren-menge-wahr` (3×, Urteil des Planners) und ob `zusage-mit-bats-bindung-…` die Instanz allein trägt; (4) ob die Vereinigungsregel in
  `harness/sensors/mutate.md` einen Herkunfts-Anker bekommt. *An einen Reviewer:* `4504191a` und `4760a5f4`. *An den Auftraggeber:* der Accept von
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md); ein voller `make mutate` am Endstand, der den Beleg-Slot schreibt.
- **Drei Paarungen:** folgen nach dem Move; ihr Ergebnis steht unten.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `harness/tools/` (`TOOLS`, `mutate.sh`) und
`*` (`ALL`: `test/`, `harness/sensors/`); beide führt die
[Modus-Deklaration](../../../../harness/conventions.md#modus-deklaration-pro-sub-area), beide sind
GF. Keine neue und keine zu grobe Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`); alle Beobachtungen führen die
Sub-Area `*`. Treffer, Zähler-Stand je `ls <Verzeichnis>/evidence | wc -l`:
`BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt` **1** — unter der
Schwelle, `offen` ist der Normalzustand; dieser Slice ist ihr vorgeschlagener Träger, und der Stand
bleibt `offen`, bis die Schwelle einen Ausgang verlangt ·
`BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` **3** — Ausgang `geplant`
beim Schwester-Slice; dieser Slice berührt seine zweite Eigenschaft (ein Nachsehen-Lauf löscht den
Slot) über den Teillauf, ohne sie zu tragen ·
`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand` **1** — die Gegenrichtung (der Schlüssel deckt
zu wenig); der Teillauf fasst den Schlüssel nicht an.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

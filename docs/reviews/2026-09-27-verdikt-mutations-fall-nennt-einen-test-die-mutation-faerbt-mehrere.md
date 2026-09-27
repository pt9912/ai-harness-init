# Architect-Verdikt: `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` — vierter Beleg, 3×-Übertritt — 2026-09-27

**Rolle:** Architect (Modul 8), Zug „Planner → Architect → Planner" (Lese-Schritt/Verkörperung,
wellenlos — Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, Tabelle
*Träger im Repo ohne Wellen*). Kein Review, keine Verifikation; dieses Verdikt ist das
**Übergabe-Artefakt** an Planner und Reviewer.

**Gelesen:** `AGENTS.md` §3 (§3.4, §3.6, §3.7, §3.8); `modul-06-roadmap.md` §Das
Beobachtungs-Register; `modul-08-agentenrollen.md`;
[`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); die beiden
Vorgänger-Verdikte
[`2026-09-27-verdikt-drei-uebertritte-und-register-fragen.md`](2026-09-27-verdikt-drei-uebertritte-und-register-fragen.md)
(Gegenstand 1 als Form-Präzedenz: dieselbe Art Übertritt, dieselbe Zielort-Wahl) und
[`2026-09-27-verdikt-kopplungsform-feldnotiz-spec.md`](2026-09-27-verdikt-kopplungsform-feldnotiz-spec.md);
`.harness/skills/reviewer.md` @ 2.2.0 vollständig; `harness/tools/mutate.sh` (Kopf-Parsing,
`report_fail`, die Exklusivitäts-Frage an der Stelle, die gegen `$expect` prüft);
`docs/plan/planning/observations/README.md` (§Ab 3× trägt `state.md` genau einen von drei
Ausgängen, §Der Zielort ist ein Norm-Artefakt — ein Lauf ist keiner); der Gegenstand selbst
vollständig — `observation.md`, `state.md`, alle vier `evidence/*.md` — sowie die vier
zugrundeliegenden Reviewer-/Verifier-Reports:
[`2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-gegenprobe.md`](2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-gegenprobe.md),
[`2026-09-27-review-slice-204-das-programm-feld-nennt-das-programm.md`](2026-09-27-review-slice-204-das-programm-feld-nennt-das-programm.md),
[`2026-09-27-review-slice-fall-406-trifft-die-umgebaute-zerlegung.md`](2026-09-27-review-slice-fall-406-trifft-die-umgebaute-zerlegung.md),
[`2026-09-27-verify-slice-071-bilanz-nennt-ihren-bestand.md`](2026-09-27-verify-slice-071-bilanz-nennt-ihren-bestand.md).
Die Mutations-Fälle selbst gelesen: `test/mutations/404-*.sh`, `406-*.sh`,
`476-span-program-navigation-nicht-uebersprungen.sh`,
`495-span-report-cli-ausgabe-falscher-writer.sh`.

---

## (a) Dieselbe Klasse — bei allen vier Belegen?

**Ja, mechanisch identisch.** `observation.md` definiert die Klasse an einem einzigen Merkmal:
ein Fall nennt in `# expect:` **einen** Test, und dieselbe Mutation färbt **einen zweiten Test**
rot, der **dieselbe Quell-Stelle bindet**. Alle vier Belege erfüllen genau dieses Merkmal, geprüft
am jeweiligen Bericht, nicht an der Zusammenfassung:

| Beleg | Fall(e) | Benannter Test | Mitgefärbter Test | Quell-Stelle geteilt? |
|---|---|---|---|---|
| `slice-204` | 476 | `TestCommandProgramSkipsNavigationSegments` | `TestCommandProgramNeverEmitsValueBehindNavigation` | ja — dieselbe `isNavigation`-Mutation, Messbeleg-Tabelle des Reviews, Zeile „Gegenprobe 476" |
| `slice-program-feld-…` | 404–407 | je einer (`…NamesAProgram…` bzw. `…Fragments`) | je der jeweils andere | ja — Gegenprobe-Bericht 2026-09-24, Tabelle „Fälle 404 bis 408", Spalte „Entfernte Zeilen"; beide Testfunktionen verlieren erst gemeinsam ihr Rot |
| `slice-fall-406-…` | 406 (repariert) | `TestCommandProgramNeverEmitsAssignmentValueFragments` | `TestCommandProgramNamesAProgramNotAnOperator` | ja — Review-Report Punkt 4, `t.Skip` nur im benannten Test, weiterhin Exit 2 über den zweiten |
| `slice-071` | 495 | `TestSpanReport_NichtExistierenderPfadAlsArgumentMeldetSichAlsFehlend` | `TestSpanReport_SchreibtBilanzUndGibtNullZurueck` (+ 2 weitere) | ja — Verifikationsbericht, Abschnitt „Nachrunde zum MEDIUM": ein isolierter Lauf nur dieses einen Tests färbt unter derselben Mutation |

Keine Überlappung mit den Nachbarklassen, die der Auftrag nennt: `regel-rand-ohne-benannte-luecke`
fehlt eine **genannte Grenze** in Kommentar/Spec — hier ist jede Grenze benannt, es fehlt keine
Aussage über den Code, sondern die **Exklusivität** einer Test-Bindung. Bei
`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` fehlt ein **Zahn ganz** — hier sind in allen
vier Belegen **zwei** Zähne vorhanden und binden beide, das Problem ist nicht Abwesenheit, sondern
Überschuss an Bindung gegenüber der `# expect:`-Aussage. `observation.md` grenzt selbst korrekt
gegen `zeichenmenge-mitglied-ohne-eigenen-zahn` ab (dort: kein eigener Zahn; hier: ein eigener Zahn
plus ein Mitbinder) — diese Abgrenzung trägt, selbst nachgeprüft an allen vier Belegen.

**Beleg 4 (`slice-071`) ist trotzdem eine Facette, keine neue Klasse — und die Facette ist der
eigentliche Grund, warum die Klasse einen Zielort braucht.** Der Verifikationsbericht trennt zwei
Fragen, die in den Belegen 1–3 zusammenfielen:

1. *Bindet der Sensor exklusiv?* — Bei allen vieren: **nein**. Mechanisch identisch.
2. *Ist der neue/geänderte Test deshalb redundant zu einem bereits vorhandenen?* — Bei 1–3 stellt
   sich diese Frage nicht separat, weil beide mitfärbenden Tests **neu oder Teil desselben
   Feature-Diffs** sind (bei 404–407 zwei Testfunktionen derselben Testdatei-Erweiterung, bei 476
   zwei Testfunktionen desselben Slice-Diffs); die Redundanz-Frage kollabiert dort mit der
   Exklusivitäts-Frage. Bei Beleg 4 ist der mitgefärbte Test **älter** als der Slice, der den
   neuen Test einführt, und der Verifier zeigt explizit, dass der neue Test trotzdem etwas bindet,
   das keiner der drei älteren Tests bindet (`args[0]`-Passthrough eines fehlenden Pfades **und**
   die Fehler-Wortwahl „existiert nicht" in Kombination) — **kein** Befund, weil kein
   Redundanz-Fall vorliegt, sondern „struktureller Nebeneffekt einer einzelnen Output-Senke"
   (Zitat Verifikationsbericht).

Diese zweite Frage ist eine **Anwendungs-Unterscheidung derselben Klasse**, kein eigenständiges
Muster mit eigenem Symptom: Das beobachtbare Ereignis — ein Fall nennt einen Test, die Mutation
färbt mehr — ist in allen vier Fällen identisch; nur das **Urteil**, ob das ein Befund ist, hängt
an einer zusätzlichen Prüfung (ist der neue Test redundant zum mitgefärbten, oder bindet er etwas
Eigenes). `observation.md` selbst formuliert die Klasse bereits ergebnisoffen — sie behauptet
nicht, dass jedes Auftreten ein Befund ist, sondern nur, dass die Zusage „ein Fall, der bei
geschwächter Zusicherung noch rot wird, deckt einen anderen Zweig" am einzelnen Test nicht ablesbar
ist. Das trifft auf Beleg 4 identisch zu wie auf 1–3; nur folgt in 4 daraus kein MEDIUM/INFO,
sondern die explizite Feststellung „kein Befund". Antwort auf (d) unten.

**Übertritt steht — ausgelöst mit dem dritten Beleg.** `state.md` hält korrekt fest, dass der
3×-Übertritt mit `slice-fall-406-trifft-die-umgebaute-zerlegung` erreicht wurde
(„Dritter Vorgang dieser Klasse, 3×-Übertritt.", `evidence/slice-fall-406-…md`); der vierte Beleg
(`slice-071`) ändert daran nichts, liefert aber das entscheidende Gegenbeispiel für die
Grenzen-Frage in (b) und die Facetten-Frage in (d).

---

## (b) `make mutate`: Grenze oder Fehler?

**Selbst am Skript geprüft — bestätigt, keine Exklusivitäts-Prüfung:**

```
sed -n '805,815p' harness/tools/mutate.sh
```

```
  if ! grep -E -- "$form" "$out" | grep -qF -- "$expect"; then
    report_fail "$name" "rot, aber '$expect' faellt nicht — falscher Grund"
    return 1
  fi

  printf 'mutate: ok      %-42s %s\n' "$name" "-> $expect rot"
```

Der einzige Test auf den Inhalt der roten Ausgabe ist `grep -qF -- "$expect"` gegen die mit `$form`
gefilterten Fehlschlag-Zeilen — eine **Teilmengen-Prüfung** (steht `$expect` unter den Treffern?),
keine **Mengengleichheits-Prüfung** (sind das *nur* Treffer für `$expect`?). Kein Aufruf im
gesamten Skript zählt die Zahl der roten Testnamen oder vergleicht sie gegen eine erwartete Menge;
`report_fail` an dieser Stelle feuert ausschließlich, wenn `$expect` **fehlt**, nie, wenn **mehr**
als `$expect` rot ist. Bestätigt.

**Das ist eine Grenze, kein Fehler — Abwägung:**

| | Kosten einer Exklusivitäts-Prüfung im Treiber | Nutzen |
|---|---|---|
| Was sie bräuchte | für **jeden** der (Stand `slice-fall-406`) 478 Fälle eine vollständige „das UND NUR das darf rot werden"-Zusicherung — bei mehrteiligen `# expect:`-Listen oder Tabellen-Tests eine Enumeration aller erlaubten Mitbinder, gepflegt bei jeder Testdatei-Änderung | verhindert, dass ein Fall unbemerkt redundant zu einem vorhandenen Test wird |
| Was sie kostet, falsch bemessen | **Beleg 4 ist der reale Gegenbeweis:** Fall 495 bindet real etwas Neues, und trotzdem würde eine pauschale Exklusivitäts-Prüfung ihn als Befund melden — ein **false positive**, der bei jeder Codeform mit gemeinsamer Ausgabesenke (hier: eine einzelne `out`-Schreibstelle für mehrere Erfolgsfälle) systematisch auftritt, nicht nur einmal | — |
| Wer die Unterscheidung heute schon trifft | der Reviewer/Verifier, mit Gegenprobe und Redundanz-Prüfung (Belege 1–4 zeigen: das Urteil ist an keiner Stelle blind gefallen, jeder Beleg hat die Unterscheidung tatsächlich vorgenommen) | — |

Eine automatisierte Prüfung müsste pro Fall eine **deklarierte** erlaubte Mitbinder-Menge führen,
um Beleg-4-artige Fälle nicht fälschlich zu blockieren — das ist ein Sonderfall derselben
Erkenntnis, die schon Gegenstand 1 des Vorgänger-Verdikts für „Mehrteilige Regel-Zusage" traf
(„eine mechanisch prüfbare Eigenschaft über beliebige Prosa" gibt es hier nicht): eine
Exklusivitäts-Aussage ist keine Eigenschaft des Falls allein, sondern eine Aussage über die
Code-Architektur (teilt sich die Stelle eine Senke mit anderen Pfaden oder nicht) — das ist Urteil,
nicht Mechanik. **Verdikt: Grenze, bewusst benannt, kein Nachrüsten am Treiber.** Träger bleibt der
Reviewer, fallweise, mit Gegenprobe.

---

## (c) Ausgang: **verkörpert**, Reviewer-Skill

`docs/plan/planning/observations/README.md` §Der Zielort ist ein Norm-Artefakt hält für genau
diesen Fall fest: „Ist der Inhalt der Beobachtung eine **benannte Lücke** (die Klasse ist benannt,
kein Wächter fängt sie), trägt sie `verkörpert`, sobald die Regel **und** die Aussage über ihre
fehlende Bewachung an **einem** Zielort stehen." (b) hat die fehlende Bewachung als Grenze
bestätigt, nicht als Fehler — die Regel ist also die Prüf-Pflicht des Reviewers, nicht ein
Treiber-Umbau.

**Gegen die Alternativen:**

| Ausgang | Warum nicht |
|---|---|
| Treiber-Umbau (`mutate.sh` exklusivitätsprüfend machen) | (b): Kosten/Nutzen negativ, Beleg 4 als realer False-Positive-Fall |
| Hard Rule (`AGENTS.md` §3.6 erweitern) | dieselbe Erwägung wie bei Gegenstand 1 des Vorgänger-Verdikts: die Klasse wird zuverlässig vom Review gefunden, bevor sie den Bestand erreicht (alle vier Belege sind Review-/Verifikations-Funde, keiner ein unentdeckter Merge); ein Hard-Rule-Eintrag kostet Kontext in jedem Lauf jeder Rolle, ohne dass ein Missverhältnis zum bisherigen Schaden belegt ist |
| `MR`-Eintrag | keine Abweichung von der Baseline (`MR-000`) |
| *geplant* (Folge-Slice) | keine Lieferung nötig — eine Prüf-Disziplin des Reviewers ist eine Doku-Zeile, kein Code |
| *gestrichen* | die Klasse ist am HEAD lebend: `test/mutations/476-*.sh` behauptet in der eigenen Kopf-Prosa „und nur sie" (Exklusivität) und ist an dieser Stelle nachweislich falsch (I-2, slice-204-Review) — ein unbehobener, aktueller Fall |

**Zielort:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md), Abschnitt
**LOW/INFO mit Eskalation**, neue Zeile direkt nach der bestehenden Zeile „Mehrteilige
Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil" — engste thematische Nachbarschaft
(beide prüfen die Deckung einer Mutations-/Test-Zusage gegen die tatsächliche Bindung), aber eine
andere Achse: dort fehlt einer genannten **Teil-Grenze** ein eigener Zahn; hier hat der Fall einen
Zahn, der **mehr** bindet, als sein Kopf behauptet. Anweisungssatz gehört der ausführenden Rolle
([ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); die Zeile
schreibt der **Reviewer**, hier nur der Wortlaut als Übergabe-Artefakt.

**Herkunfts-Anker:** `seit slice-fall-406-trifft-die-umgebaute-zerlegung` — dieser Slice trug den
**dritten** Beleg und löste den 3×-Übertritt aus (`state.md`: „Dritter Vorgang dieser Klasse,
3×-Übertritt."), dieselbe Regel wie im Vorgänger-Verdikt Gegenstand 1: der Anker nennt den Slice,
dessen Closure die Schwelle überschritt, nicht den ersten, der das Muster etablierte, und nicht den
vierten, der nur zusätzliche Evidenz nachlieferte. Sein §7 nennt die Beobachtung namentlich:

```
grep -c 'mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere' docs/plan/planning/done/slice-fall-406-trifft-die-umgebaute-zerlegung.md
```

→ **1** (gelesen 2026-09-27, keine Erwartung — die Zahl wandert nicht, die Datei ist `done/` und
eingefroren, aber der Beleg gehört ans Kommando, nicht in eine Behauptung).

---

## Textvorschlag (wörtlich, Übergabe an den Reviewer)

Neue Zeile in `.harness/skills/reviewer.md`, Abschnitt **LOW/INFO mit Eskalation**, direkt nach
der Zeile „Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil"
(`… slice-204-das-programm-feld-nennt-das-programm)`):

```markdown
- **Mutations-Fall nennt einen Test, die Mutation färbt mehrere** — der `# expect:`-Kopf eines
  neuen oder geänderten Falls nennt einen Test; `make mutate` prüft nur, ob dieser Test unter der
  Mutation rot wird, nicht, ob er der einzige ist (`harness/tools/mutate.sh`: `grep -qF --
  "$expect"` gegen die gefilterte Fehlerausgabe, keine Exklusivitäts-Prüfung). Der Reviewer fährt
  für jeden neuen oder geänderten Fall die Gegenprobe mit ausgeschriebener Polarität — `t.Skip(...)`
  **ausschließlich** im benannten Test, Mutation weiterhin angewandt — und liest, ob die Suite grün
  wird (der benannte Test bindet allein) oder rot bleibt (ein zweiter Test bindet dieselbe
  Quell-Stelle mit). Bleibt sie rot, trennt er zwei Fragen: Bindet der neue oder geänderte Test
  etwas, das kein mitgefärbter Test bindet (kein Befund — struktureller Nebeneffekt einer
  gemeinsamen Stelle, etwa einer einzelnen Ausgabe-Senke für mehrere Erfolgsfälle), oder dupliziert
  er nur, was der mitgefärbte Test bereits allein bindet (LOW — `# expect:` zeigt auf einen
  überflüssigen oder falsch gewählten Test, der Fall trägt nichts Eigenes bei)? Behauptet der
  Fall-Kopf selbst Exklusivität („und nur sie", „ausschließlich"), die die Gegenprobe widerlegt:
  mindestens LOW, unabhängig vom Redundanz-Ausgang — die Behauptung selbst ist falsch (§3.7). Gilt
  für Fälle, die der Diff anlegt oder ändert, nicht für den Bestand. Kein Gate fängt das — eine
  Exklusivitäts-Prüfung im Treiber bräuchte für jeden Fall eine vollständige „das UND NUR das darf
  rot werden"-Zusicherung und träfe legitimes Mitfärben (gemeinsame Ausgabe-Senke) systematisch als
  falschen Befund; Träger ist dieser Review ([`AGENTS.md`](../../AGENTS.md) §3.6)
  (seit slice-fall-406-trifft-die-umgebaute-zerlegung)
```

Versionierung: 2.2.0 → 2.3.0, Datum des Reviewer-Laufs, der die Zeile schreibt.

---

## Kennzeichnung (§3.6/§3.7)

**Grenze der Verkörperung, benannt.** Kein Wächter existiert: `make mutate` prüft die Anwesenheit
des genannten Fehlschlags, nicht seine Exklusivität, und `make comment-claims` prüft nur, ob ein
genannter Sensor existiert, nicht, worüber ein Kommentar spricht. Träger ist der Review, der bei
jedem neuen oder geänderten Mutations-Fall die Gegenprobe mit ausgeschriebener Polarität fährt; die
Zeile deckt Fälle, die der Diff anlegt oder ändert, nicht den Bestand — Fall 476s eigene, falsche
Exklusivitäts-Behauptung im Kopf-Kommentar bleibt bis zu einer künftigen Änderung dieses Falls ein
**akzeptiertes Negativ**.

**Was passieren müsste, damit die Zeile bricht:** ein Review-Report zu einem Diff, der einen neuen
oder geänderten Mutations-Fall anlegt, bei dem die Gegenprobe (benannter Test übersprungen,
Mutation aktiv) rot bleibt, meldet das weder als „kein Befund, struktureller Nebeneffekt" noch als
LOW, sondern übergeht die Mitbindung stillschweigend. **Gegenprobe, die der Reviewer beim Schreiben
fährt** (von mir nicht gefahren, kein Reviewer-Lauf): die Zeile auf Fall 476 angewandt muss die dort
falsche „und nur sie"-Behauptung als mindestens LOW ausweisen — der Bestand liefert damit das
Gegenbeispiel, ohne dass ein neuer Fall konstruiert werden muss.

---

## (d) Sub-Klasse für Beleg 4?

**Nein — kein neues Register-Verzeichnis, kein Randfall außerhalb der Klasse.** Die Unterscheidung
„legitimes Mitfärben ohne Redundanz" vs. „echte Mehrfachbindung ohne eigenen Beitrag" ist keine
zweite **beobachtbare Form** (das Symptom — Fall nennt einen Test, Mutation färbt mehr — ist in
beiden Ausprägungen identisch und an der Mutations-Ausgabe allein nicht unterscheidbar), sondern
ein **Bewertungs-Schritt innerhalb derselben Klasse**: dieselbe Gegenprobe, ein zusätzliches Urteil
danach. Eine zweite Beobachtung würde denselben Beleg-Pool erneut aufspalten und liefe der
Ökonomie-Regel zuwider (kleinster tragender Schnitt vor sauberstem Schnitt); sie hätte zudem keine
eigene Belegkette — alle vier bisherigen Belege gehören inhaltlich weiter zur bestehenden Klasse,
nur Beleg 4 durchläuft ihr Bewertungs-Ende mit dem Ergebnis „kein Befund" statt „Befund". Der
Textvorschlag oben trägt die Unterscheidung deshalb **als Kriterium innerhalb der einen
verkörperten Zeile**, nicht als zweiter Zielort: „Bindet der neue Test etwas Eigenes? → kein
Befund. Dupliziert er nur? → LOW." Das ist exakt die Prüfung, die der Verifier in Beleg 4 bereits
von Hand durchgeführt hat — die Zeile macht sie zur Regel für künftige Fälle, statt sie bei jedem
Vorkommen neu zu erfinden.

---

## Übergaben

- **An den Reviewer** (ADR-0028, nächster eigener Lauf): Textvorschlag oben in
  `.harness/skills/reviewer.md` einfügen, Version 2.2.0 → 2.3.0.
- **An den Planner** (Closure/Register-Fortschreibung, nicht Teil dieses Laufs):
  `state.md` von `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` auf Ausgang
  `verkörpert` setzen — Zielort `.harness/skills/reviewer.md` §LOW/INFO mit Eskalation (nach
  Ausführung durch den Reviewer), Herkunfts-Anker `seit slice-fall-406-trifft-die-umgebaute-zerlegung`,
  Abschnitt „Grenze der Verkörperung, benannt" wie oben unter Kennzeichnung formuliert.

## Was offen bleibt

- Die Reviewer-Zeile ist erst wirksam, sobald der Reviewer sie tatsächlich schreibt (ADR-0028) —
  dieses Verdikt liefert den Wortlaut, nicht die Ausführung.
- `state.md` trägt bis zur Ausführung weiterhin `offen`; das ist nach
  `docs/plan/planning/observations/README.md` zwischen Lese-Schritt und Verkörperung zulässig und
  vorübergehend.
- Fall 476s eigene Kopf-Behauptung „und nur sie" bleibt bis zu einer künftigen Änderung dieses
  Falls unkorrigiert — benannt oben als akzeptiertes Negativ, kein eigener Folge-Slice: Der Fall
  ist mechanisch korrekt verdrahtet (bindet den benannten Test), nur seine Prosa ist zu stark.

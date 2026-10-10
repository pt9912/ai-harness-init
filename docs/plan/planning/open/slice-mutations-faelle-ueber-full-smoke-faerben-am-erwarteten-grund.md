# Slice slice-mutations-faelle-ueber-full-smoke-faerben-am-erwarteten-grund: Mutations-Fälle über `full-smoke` werden am erwarteten Grund rot, nicht an einer früheren Stufe

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese
Datei aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`AGENTS.md`](../../../../AGENTS.md) §3.6,
[`MR-063`](../../../../harness/conventions.md#mr-063),
[`MR-091`](../../../../harness/conventions.md#mr-091).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jeder `# verify: full-smoke`-Fall in `test/mutations/` färbt `full-smoke` an der Stufe rot,
deren Text sein `# expect:` nennt; ein Fall, den eine frühere Stufe abfängt, wird so angesetzt, dass
die erwartete Stufe erreicht wird, oder auf die Stufe umgestellt, die ihn tatsächlich trägt.

**Anlass** (Auftrag des Auftraggebers 2026-10-10): im nächtlichen `make mutate` (Lauf 38038163361,
`main`, `1c67a31b`) sind zwei Fälle „rot, aber falscher Grund".
`171-feldliste-ausserhalb-des-geprueften-bereichs` bricht in der Stufe Handbuch-Baum ab
(*„im Handbuch genannt, vom Lauf nicht angelegt: harness/erfassung-feldliste.md; vom Lauf angelegt, im
Handbuch nicht genannt: .harness/erfassung-feldliste.md"*), sein `# expect:` fällt nie.
`305-rollenachse-ziel-verliert-rolle-fullsmoke` bricht dort mit *„.claude/agents/validator.md im
Handbuch genannt, nicht angelegt"* ab; *„FEHLER — Rollen-Typ fehlt"* fällt nie. Beide mutieren, was ein
Bootstrap anlegt, und die Handbuch-Stufe (`handbuch_baum_pruefen`, vor `rollen_typen_im_ziel` in
`harness/tools/full-smoke.sh`) misst genau diese Pfad-Menge zuerst.

**Dritter Messpunkt, gleiche Meldung, andere Stufe** (selber Nachtlauf):
`111-span-korrelationsfeld-verschwindet` (`# verify:` ist `test-go`, nicht `full-smoke`) ist „rot, aber
`TestMandatoryFieldsAlwaysPresent` fällt nicht". Lokal gefahren (`make mutate MUTATE_CASES=…`,
2026-10-10): es fällt `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation`
(`fieldlist_test.go:269`, *„die Feldliste nennt "branch" als Feld mit Kennzeichnung, der Traeger fuehrt
es nicht als Pflichtfeld"*), `TestMandatoryFieldsAlwaysPresent` bleibt grün. **Nicht dieselbe Klasse:**
keine früher fallende Stufe fängt den Fall ab, `go test` fährt beide Tests; der benannte Test hat die
Mutation `omitempty` an `branch` nicht mehr als Zahn. Gemeinsam ist nur die Meldung „falscher Grund".
Der Slice führt `111` als Fall der Liste aus DoD (1) und (2) — Menge: alle Fälle mit „falscher Grund",
nicht nur `full-smoke`; die Ursache je Fall bleibt zu messen. Die Liefer-Punkte bleiben drei.

**Zu klären, gemessen und nicht geschätzt:**

- Reihenfolge der Stufen: welche Stufe fällt vor welcher erwarteten; `git log -S'handbuch-baum.sh'`
  nennt die Einführung der Handbuch-Stufe (`36cd07c3`, 2026-10-08), ein Grün am 07.10. und Rot ab dem
  08.10. passen dazu. **Die Läufe vom 05. und 06.10. liegen davor** — ihre Ursache ist offen und wird
  nicht vorweggenommen.
- Menge: `MUTATE_CASES` über alle `# verify: full-smoke`-Fälle (`grep -l '^# verify: full-smoke'
  test/mutations/*.sh | wc -l`, 2026-10-10, kein Erwartungswert); ab neun Fällen über den CI-Branch nach
  [`MR-091`](../../../../harness/conventions.md#mr-091).
- Fall oder Stufe: umgeht der Fall die Handbuch-Stufe (zweite Datei in `# files:`, die das Handbuch
  mitzieht), oder ist die Mutation falsch angesetzt (Zahn bindet seine Zusicherung nicht,
  [`MR-063`](../../../../harness/conventions.md#mr-063)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein Release-Blocker: `make mutate` läuft nächtlich und ist kein Gate (`harness/README.md`
  §Werkzeuge); ein rotes Nachtlauf-Ergebnis hält weder `make gates` noch den Release. Der Slice wartet
  nicht auf den Release und hält ihn nicht auf.
- Der Treiber-Umbau („Fall bindet Zusicherung", Zähler „Wächter ohne Fall") —
  `slice-der-mutations-treiber-sieht-bindung-und-abdeckung`: Treiber-Code, hier dagegen Instanzen;
  mit dessen drei Liefer-Punkten wäre die Größenregel gebrochen.
- Neue Wächter ohne Mutations-Fall — Klasse `BEO-ALL/neuer-waechter-ohne-mutations-fall`, ausgewiesen
  auf dem Treiber-Slice; hier nur Bestand, der schon einen Fall trägt.
- Eine Änderung der Handbuch-Stufe selbst — sie hält ihre Zusage (Pfad-Menge frischer Ziele in beide
  Richtungen) und fällt zu Recht.

## 2. Definition of Done

- [ ] **(1) Ursache und Menge stehen fest.** Alle `# verify: full-smoke`-Fälle sind gefahren, dazu
      `111` und jeder weitere Fall, den der Nachtlauf mit „falscher Grund" meldet; die
      Fälle, die an einer anderen Stufe oder einem anderen Test als dem erwarteten rot werden, sind mit Stufe und Meldung
      aufgelistet; die Läufe vom 05./06.10. haben eine gemessene Ursache oder die benannte Lücke.
      **Rot:** ein Fall der Liste, dessen `# expect:` im Lauf nicht erscheint.
- [ ] **(2) Jeder Fall der Liste bindet seinen Grund.** Angesetzt wird so, dass die erwartete Stufe
      erreicht wird, oder umgestellt auf die Stufe, die den Fall trägt; `171` und `305` eingeschlossen.
      **Rot:** pro Fall der gelesene Lauf mit dem erwarteten Text; ein Gegenversuch, der die
      Handbuch-Stufe wieder vor die erwartete Stufe stellt, färbt `make mutate` für diesen Fall mit
      „falscher Grund".
- [ ] **(3) Die Klasse hat einen Träger.** Dass eine neue, früh fallende Stufe Fälle derselben Klasse
      still entzahnt, ist entweder durch einen Sensor gedeckt oder als benannte Lücke mit Adresse
      geführt; wird eine Norm daraus, liegt die Übergabe an den Architect vor
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: `harness/sensors/mutate.md`, falls die Stufen-Reihenfolge für Fälle eine Zusage
      wird.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/171-*.sh`, `test/mutations/305-*.sh` und die weiteren Fälle der Liste aus (1) | update | Ansatz oder `# verify:`/`# expect:` je Fall, (2) |
| `harness/tools/full-smoke.sh` | nur lesen, ggf. update | Reihenfolge der Stufen als Messgegenstand; geändert nur, wenn die Messung die Stufe selbst als Ursache zeigt |
| `harness/sensors/mutate.md` | update (bedingt) | Zusage zur Stufen-Reihenfolge, (3) |

- Reihenfolge: (1) vor (2). Der Vollauf über die Fall-Menge läuft über den CI-Branch
  ([`MR-091`](../../../../harness/conventions.md#mr-091)); `make mutate-auswahl` nennt den Weg.

## 4. Trigger

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice, der Slice ist priorisiert.

**Rückführungen:**

- `in-progress` → `next`: die Menge aus (1) ist so groß, dass (2) nicht in einer Review-Sitzung
  prüfbar ist — dann trennt ein Re-Slice nach Stufe.
- `in-progress` → `open`: die Ursache der Läufe vom 05./06.10. liegt außerhalb der Fälle (etwa im
  CI-Branch-Weg) und braucht einen eigenen Befund.

## 5. Closure-Trigger

DoD (1)–(3) mit gelesenen roten Läufen je Fall der Liste; der Nachtlauf nach dem Merge führt weder
`171` noch `305` als „falscher Grund"; Review konform, Verifikation bestätigt; `make gates` grün;
Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Fall-Menge reicht über die Handbuch-Stufe hinaus (weitere früh fallende Stufen). — **Ausgang:** bei Closure.
- Ein Fall, der die Handbuch-Stufe umgeht, entzahnt den Zahn für die Stufe selbst. — **Ausgang:** bei Closure.
- Das Rot vom 05./06.10. hat eine andere Ursache als die Handbuch-Stufe. — **Ausgang:** bei Closure.
- Der Vollauf über den CI-Branch ist kostspielig (`full-smoke` je Fall). — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `harness/tools/` (`TOOLS`, `full-smoke.sh` als Messgegenstand)
und `*` (`ALL`, für `test/mutations/` und `harness/sensors/`); beide erfüllen die Schwelle (eigene
Regel-Form, eigener Prüfbereich, eigene Fehlermodi). `CODEX` nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Register gelesen (Zähler:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, 2026-10-10, keine
Erwartungswerte). Treffer: `neuer-waechter-ohne-mutations-fall` (20, `geplant` auf dem Treiber-Slice;
dieser Slice betrifft Bestand, nicht Neuanlage, und erhöht ihn nicht);
`mutations-fall-deckt-den-lauten-statt-den-stillen-pfad` (2, `offen`; die Klasse „Fall trifft eine
andere Stelle als die Zusicherung" ist nahe, der Mechanismus hier ist eine früher fallende Stufe);
`neue-isolation-entzahnt-bestehende-waechter` (1, `offen`; dieselbe Familie: eine neue Stufe entzahnt
bestehende Fälle). Erreicht eine der beiden `offen`-Einträge mit diesem Slice 3×, braucht sie einen
Folge-Slice — das Urteil trifft die Closure. Kein Eintrag steht auf 3× ohne Ausgang.

**Modus:** alle berührten Sub-Areas GF.

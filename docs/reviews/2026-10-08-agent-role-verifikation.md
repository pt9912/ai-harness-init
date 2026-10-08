# Verifikations-Bericht: slice-agent-role-traegt-nicht-bekannt — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Modell:** claude-opus-5-5 · **Gegenstand:** `ac429eec`, `79e0c4b9`
(Review `2026-10-08-agent-role-review`, F-1..F-3 in `79e0c4b9` eingearbeitet) · **Maßstab:** DoD des
Slice, `LH-FA-13`/`LH-FA-15` in Lastenheft 0.25.1, `spec/spezifikation.md` §5.

> Zitier-Form wie im Review-Report: Kennung statt Adresse.

## Verdikte je DoD-Punkt

- **1 — Spezifikation: bestätigt.** `grep -c '(Abweichung 3)' spec/spezifikation.md` → `0`;
  `grep -n 'sonst bleibt das Feld leer' spec/spezifikation.md` → kein Treffer. `SPEC-087` nennt die
  Fälle abschließend (Cache-Zähler, `agent_role`/`agent_type`, `branch`/`commit`/`.git/HEAD`,
  Listen bei unlesbarem Verzeichnis bzw. unlesbarer Slice-Datei) und deckt sich mit `agentRole`,
  `gitRef`/`readGitRef`, `correlation` (gelesen). `SPEC-010/011/012/014/043/044/055/056` nachgezogen,
  `SPEC-009` (F-2) ebenso. Gegen Lastenheft 0.25.1: *Rolle besetzt*, *Rolle wird abgeleitet*,
  *Lesevorschrift*, *Zweig und Stand*, *Leer heißt keiner, unbekannt ist gekennzeichnet* getragen.
- **2 — Erfassung und Tests: bestätigt.**
  `make mutate MUTATE_CASES='137-… 593-… 597-… 598-… 599-… 600-… 601-… 602-… 603-…'` → EXIT 0,
  `mutate: 9 ok, 0 Befund(e)`, je Fall der benannte Wächter rot (597 → `TestAgentRoleFromKnownTypes`,
  598/599 → `TestUnresolvableGitRefIsMarkedNotKnown`, 600 → `TestCorrelationUnreadableSliceIsMarkedNotKnown`,
  601 → `TestCorrelationUnreadableDirIsMarkedNotKnown`, 603 → `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation`,
  593 → `TestCurrentRuleVersionIsTheLastSpecFassung`, 137 → `TestFailedAgentCallCapturesNothing`).
  Meldungswortlaut und Allein-Bindung von 593/597–602 hat der Review gemessen; hier nicht wiederholt.
  **Gegenprobe 603** (Kopie per `git archive HEAD`, `make test-go`): Mutation allein → EXIT 2, genau
  ein `--- FAIL`, Meldung `die Feldliste nennt die Felder mit Kennzeichnung nicht abschliessend (Satz
  "Die Kennzeichnung *nicht bekannt* tragen abschließend diese Felder:" fehlt)`; Mutation plus `t.Skip`
  im benannten Test → EXIT 0, 0 FAIL: **bindet allein**.
  **`make full-smoke` selbst gefahren** → EXIT 0; Rollen-Stufe in beiden Zielen:
  `Rolle im Ziel (golang): 8 Payloads … general-purpose und ein fremder Typ die Kennzeichnung "nicht
  bekannt: agent_type" (LH-FA-15)`, dieselbe Zeile für `(sprachlos)`. Die zwei `FEHLER`-Zeilen im Log
  sind Selbstprüfungs-Gegenproben (`selbstpruefung`, `e2e-abdeckung`), kein Stufen-Abbruch.
  **Grenze:** `full-smoke` misst im Ziel nur `agent_role`; `branch`/`commit` und die Listen tragen
  allein die Unit-Tests samt Fällen 598–601.
- **3 — Auswertung: bestätigt, am echten Bestand nur trivial.** Rot-Beleg über Fall 602 (oben).
  `make span-report` → EXIT 0, `Fassung 4: 178 · Fassung 5: 73 · Fassung nicht bekannt: 65152 Zeile(n)`,
  `Keine Bilanz: der Bestand traegt keine Verbrauchs-Zaehler`, keine Rolle *nicht bekannt* in der
  Ausgabe (`grep -ci 'nicht bekannt'` → 1, die Fassungs-Zeile). Der Bestand trägt die Kennzeichnung real
  (`grep -rhoE '"agent_role":"[^"]*"' .harness/state/spans | sort | uniq -c` → 4× `nicht bekannt:
  agent_type`, 7437× `""`), aber ohne Verbrauchs-Zähler entsteht keine Rollen-Zeile — die Zusage
  „keine Rolle *nicht bekannt*" ist am Bestand nicht gegenprüfbar, getragen allein von
  `TestAggregiere_KennzeichnungIstKeineRolle`.
  **Zusatz-Rot (`SPEC-098` „Zeile mit gekennzeichneter Liste bleibt lesbar"):** in Kopie den
  Zeichenketten-Zweig von `IDList.UnmarshalJSON` abgeschaltet → EXIT 2,
  `TestAggregiere_KennzeichnungIstKeineRolle: lesbare Zeilen = 4, erwartet 5` und
  `TestIDListRoundTrip: … cannot unmarshal string into Go value of type []string`. Die Zusage hat Zähne,
  aber keinen Fall in `test/mutations/` (s. offene Punkte).
- **`make gates` grün: bestätigt.** Einmal am Ende auf `79e0c4b9` (Stempel stand auf `7da23130`) →
  EXIT 0, 171 s; `d-check: 2524 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 86 … 0 Befund(e)`,
  bats 498 ok / 0 not ok; `.harness/state/gates-passed.head` → `79e0c4b9`.
- **Review durchgeführt: bestätigt.** Report liegt vor; F-1 (`fieldlist.go` + Wächter + Fall 603),
  F-2 (`SPEC-009`), F-3 (Kopf Fall 137) in `79e0c4b9` eingearbeitet (gelesen).
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: nicht Gegenstand** — Planner-Arbeit
  (`AGENTS.md` §3.10); §7 steht leer, wie es vor der Closure sein muss.

## Plan-vs-Code

- **Abweichungen aus §3, gegen Code und Lastenheft:** `slice` bleibt bei unlesbarer Slice-Datei
  bekannt (`correlation`: Name aus dem Verzeichnis-Eintrag) — die Lastenheft-Zeile spricht von
  *unbekanntem* Wert, der Slice-Name ist bekannt; getragen. Abgekoppelter `HEAD` → nur `branch`
  gekennzeichnet (`readGitRef` liefert den Stand aus `HEAD`) — `LH-FA-13` „beide" bindet den Fall ohne
  mögliche Ableitung; `commit` ist hier ableitbar, `SPEC-056` präzisiert je Feld; getragen.
  `.git` als Datei (Worktree/Submodul) → beide gekennzeichnet, obwohl git ihn auflösen könnte —
  in `SPEC-056` ausdrücklich so festgelegt, kein Widerspruch.
- **Gebautes ohne Plan:** Fall 603 und `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation`
  stehen nicht in §3 (dort Fälle 597–602) — Review-Nachlauf, Verhalten unverändert; kein Befund.
- **Geplantes ohne Code:** keines gefunden.
- **Weitere Leser von `agent_role`** (Rückführungs-Trigger §4): `grep -rn 'agent_role\|AgentRole'`
  außerhalb `internal/span` → `internal/report/report.go:169` und `span-check.sh`/`full-smoke.sh`
  (nur Schlüssel-Anwesenheit bzw. Erwartung); Trigger nicht eingetreten.

## Offene Punkte für den Planner

- **`SPEC-098` Lesbarkeits-Hälfte ohne Mutations-Fall** (INFO): rot gesehen (oben), aber kein Fall in
  `test/mutations/` hält die Haltbarkeit; Entscheidung, ob ein Fall nachkommt, beim Planner.
- **Risiko §6 „Bedeutung wechselt ohne Fassungs-Angabe":** der Wechsel trägt Fassung 5 (`SPEC-096`,
  `CurrentRuleVersion = 5`), am Bestand sichtbar (`Fassung 5: 73 Zeile(n)`) — Beleg für den Ausgang.
- **Risiko §6 „Kennzeichnung als Rolle gelesen":** kein weiterer Leser gefunden (s. oben).
- **Bestand ohne Verbrauchs-Zähler** (`0 von 1229 Agent-Laeufen`): außerhalb dieses Slice, macht aber
  DoD 3 am echten Bestand unprüfbar.

## Negativbefunde

- Kennzeichnungs-Draht-Form (`IDList.MarshalJSON`, `[]` nie `null`): ohne Befund.
- `report.go`: Kennzeichnung und `""` fallen an derselben Stelle aus dem Nenner; `SpawnedRole` unberührt: ohne Befund.
- Fassung 5 gegen `SPEC-089`: vom Review gemessen, nicht wiederholt.

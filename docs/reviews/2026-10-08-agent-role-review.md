# Review-Report: slice-agent-role-traegt-nicht-bekannt — 2026-10-08

**Review-Art:** Code — gegen Plan + Lastenheft-Wortlaut + Konventionen.

**Gegenstand:** `ac429eec` (Claim `8aaec3d0`, `c1527abe`, `34eeeb57`)

**Skill:** `.harness/skills/reviewer.md` @ `78381a2b` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-agent-role-traegt-nicht-bekannt` (Plan §1–§3, §6, Abweichungen in §3)
- `LH-FA-13` (*Zweig und Stand*, *Leer heißt keiner, unbekannt ist gekennzeichnet*), `LH-FA-15`
  (alle vier Kriterien) — Lastenheft 0.25.1
- `spec/spezifikation.md` §5: `SPEC-009` bis `SPEC-014`, `SPEC-043`, `SPEC-044`, `SPEC-055`,
  `SPEC-056`, `SPEC-087`, `SPEC-089`, `SPEC-093` bis `SPEC-098`
- `MR-071`, `MR-075`; `AGENTS.md` §3.6, §3.7

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die emittierte Feldliste sagt jedem Pflichtfeld zu, dessen Wert die Quelle nicht liefert: „nie `""`". Die geschriebene Zeile eines Haupt-Kontext-Spans trägt weiter `"agent":""`, `"agent_type":""`, `"tool_use_id":""`, `"event":""` (gesehen in der Ausgabe von `TestUnresolvableGitRefIsMarkedNotKnown` unter Fall 598). Ein Adopter, der die Feldliste liest, hält diese Werte für einen Defekt; `SPEC-087` begrenzt die Fälle dagegen „abschließend". | `LH-FA-13`, `SPEC-087`, `SPEC-009` | `internal/span/fieldlist.go:190-192` | nein | Allgemeine Zusage überdeckt die abschließende Fall-Liste der Spezifikation |
| F-2 | LOW | `SPEC-009` sagt weiter, die vier Felder `session`/`agent`/`agent_type`/`agent_role` seien ein Block, „und leer ist dort eine Aussage (Haupt-Kontext)". Für `agent_role` widerspricht das `SPEC-010`/`SPEC-043`/`SPEC-087` desselben Diffs: im Haupt-Kontext trägt es jetzt die Kennzeichnung. Die Zeile liegt in der Tabelle, die der Diff nachzieht (`MR-075`), steht aber nicht in den „Berührten Spec-Stellen". | `LH-FA-15`, `MR-075` | `spec/spezifikation.md:119` | nein | Nachbarzeile einer nachgezogenen Spec-Festlegung bleibt stehen |
| F-3 | INFO | Der Kopf von Fall 137 (unverändert, Bestand) sagt: „`agent_role` ist Pflicht und steht als `""` in jeder Zeile". Das ist seit diesem Diff falsch; der Fall selbst (Anker `spawned_role,omitempty`) bindet weiter. Bestand, kein Auftrag nach §3.7-Cutoff — hier nur genannt, weil der Diff die Aussage falsch gemacht hat. | `AGENTS.md` §3.7 | `test/mutations/137-span-rollenfeld-praesent-leer.sh:10-11` | nein | Kommentar über ein Nachbarfeld bleibt beim Wechsel der Draht-Form stehen |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Kennzeichnung `agent_role` gegen `LH-FA-15` *Rolle besetzt*/*Rolle wird abgeleitet* | geprüft, ohne Befund: `agentRole` liefert die Rolle oder `nicht bekannt: agent_type` für `general-purpose`, fremden Typ und `""` (Haupt-Kontext); `spawned_role` bleibt optional und abwesend (`SPEC-083`), `RoleFromAgentType` bleibt Normalisierer für beide (Fall 128 unverändert). |
| `branch`/`commit` gegen `LH-FA-13` *Zweig und Stand* samt Abweichung „abgekoppelter HEAD nur `branch`" | geprüft, ohne Befund: `readGitRef` liefert je Feld `""` genau dann, wenn dieses Feld nicht ableitbar ist (inkl. `packed-refs`-Auflösung, `shortSha` < 12 Zeichen); `gitRef` kennzeichnet je Feld. Bei abgekoppeltem HEAD ist der Stand ableitbar — die Zeile des Lastenhefts („beide") bindet den Fall, in dem keine Ableitung möglich ist; `SPEC-056` präzisiert je Feld, ohne ihr zu widersprechen. |
| Korrelations-Listen (`IDList`) gegen *Leer heißt keiner* samt Abweichung „`slice` bleibt bekannt" | geprüft, ohne Befund: fehlendes Verzeichnis → `[]` (keiner), vorhanden und unlesbar → alle drei gekennzeichnet, unlesbare Slice-Datei → `requirement`/`adr` gekennzeichnet, `slice` aus dem Verzeichnis-Eintrag; `[]` wird nie `null` (`MarshalJSON`). `slice` stammt nicht aus dem Datei-Inhalt — die Lastenheft-Zeile („statt `[]`") trifft die Listen, die aus der Datei kommen. |
| `span-report`-Lesevorschrift (`SPEC-044`, `SPEC-098`) | geprüft, ohne Befund: `AgentRole` wird in `internal/report` an genau einer Stelle gelesen (`report.go:169`, `grep -n AgentRole internal/report/*.go`); Kennzeichnung und `""` fallen dort gleich aus dem Nenner, eine Rolle *nicht bekannt* entsteht nicht; die Listen liest die Auswertung nicht, eine gekennzeichnete Liste macht die Zeile nicht unlesbar (`TestAggregiere_KennzeichnungIstKeineRolle`, 5 lesbare Zeilen). Weitere Leser von `agent_role`: `harness/tools/span-check.sh` prüft nur die Anwesenheit des Schlüssels. |
| Fassung 5 gegen `SPEC-089` (Zählregel je Release) | geprüft, ohne Befund: `notknown.go` (Fassung 4, Cache-Status) liegt in `v0.3.0` (`git show v0.3.0:internal/span/notknown.go`), `ruleversion.go` entstand nach `v0.5.0` (`git log -- internal/span/ruleversion.go`, `v0.5.0` vom 2026-10-07); dieser Wechsel kommt mit dem nächsten Release → 5, Tabelle lückenlos 1–5, `CurrentRuleVersion = 5`. |
| Spec-Zeilen `SPEC-010`–`014`, `043`, `044`, `055`, `056`, `087`, `096`–`098` (`MR-075`) | geprüft, ohne Befund außer F-2: jede nachgezogene Zeile führt ihr Lastenheft-Element in *Präzisiert*; `SPEC-087` nennt die Fälle abschließend und deckt sich mit dem Code (fünf Quellen-Lagen); `grep -c '(Abweichung 3)' spec/spezifikation.md` → 0. |
| Mutations-Fälle 593, 597–602 (`MR-071`, Exklusivität) | gefahren in Kopien unter dem Scratchpad (`git archive HEAD`, `make test-go`): jede Mutation ändert genau eine Zeile (Anker repo-weit je 1×, `git grep -F -c`), färbt den benannten Test rot mit einer Meldung über genau das Feld (z. B. `agent_type "general-purpose" -> agent_role "", erwartet "nicht bekannt: agent_type"`; 593: `die letzte Fassung der Spezifikation ist 5, der Traeger schreibt 6`); Gegenprobe `t.Skip` **ausschließlich** im benannten Test bei angewandter Mutation → Suite grün (rc 0) für alle sieben: der benannte Test bindet allein. 593 bindet fassungsunabhängig (`\1 + 1`). Modus `100755`. Kein Fall-Kopf behauptet Exklusivität. |
| Meldungswortlaut der neuen Tests | gelesen in der Rot-Ausgabe oben, ohne Befund: jede Meldung nennt Feld, erwarteten Wert und die geschriebene Zeile. |
| `full-smoke`-Erwartung | gelesen, nicht gefahren: Zerlegung `${typ%%:*}`/`${typ#*:}` trennt am ersten `:`, die Erwartung `nicht bekannt: agent_type` überlebt; die Erwartung entspricht dem, was `agentRole` schreibt. Ob die Stufe grün läuft, belegt nur der Lauf (Verifier). |
| Doku `docs/user/rollen-laeufe.md` (Ist-Zustand) | geprüft, ohne Befund: beschreibt Kennzeichnung und Lesart des Altbestands, keine Chronik, keine Prognose. |
| Kommentare (§3.7) im Diff (`emit.go`, `notknown.go`, `report.go`, Fall-Köpfe) | geprüft, ohne Befund: Indikativ, Klassen Zusage/Kopplung/Abgrenzung, Sensoren benannt; keine Chronik, keine Befund-Kennung. Der gelöschte Absatz an `RoleFromAgentType` trug Chronik und ist ersetzt, nicht ergänzt. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Allgemeine Zusage überdeckt die abschließende Fall-Liste der
Spezifikation · Nachbarzeile einer nachgezogenen Spec-Festlegung bleibt stehen · Kommentar über
ein Nachbarfeld bleibt beim Wechsel der Draht-Form stehen

## Verdikt

**Merge-blockierend:** nein. F-1 bis F-3 gehen an den Implementer zur Entscheidung (akzeptieren
oder begründen); kein Rollen-Konflikt.

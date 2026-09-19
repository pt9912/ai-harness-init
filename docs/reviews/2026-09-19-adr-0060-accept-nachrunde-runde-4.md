# Review-Report: ADR-0060 — Accept-Nachrunde (Runde 4) — 2026-09-19

**Review-Art:** Konsistenz — der Accept-Beleg nach
[`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 (die erneute Runde derselben prüfenden Rolle; die blockierende Runde 3 kann ihn
nicht tragen). **Enger Auftrag: allein der Fix-Commit, kein Neu-Review des Slices.**

**Gegenstand:** allein Commit `06991d30` — Trigger 2 des Re-Evaluierungs-Abschnitts, der
Supersedes-Gegenstand (iii) und die Trigger-Listen-Reparatur des Zeilen-Griffs (1 Datei, 5+/5-,
zwei Hunks). Der Re-Schnitt `6228cbd5` ist durch die Runde 3 abgehandelt
(`docs/reviews/2026-09-19-adr-0060-accept-nachrunde-runde-3.md`); `06991d30` ist der einzige
Commit an der Datei seit `6228cbd5` (`git log 6228cbd5..HEAD -- <ADR-Datei>` → genau dieser
Commit).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** glm-5.3-flash (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-19

Zitier-Form wie in der Runde 3: Kennung statt Adresse für Commits, Pfad-Link zu den ADRs (deren
Ort ortsfest ist), Zeilennummern gegen den Stand `c1853faf`.

**Eingangs-Kontext:** [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
(Proposed, Stand `06991d30`), Runde-3-Report (F-1 HIGH, F-2 LOW),
[`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2, [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) /
[`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md) /
[`ADR-0008`](../../docs/plan/adr/0008-arch-achse-emittiertes-skelett.md) (Accepted),
[`AGENTS.md`](../../AGENTS.md) §3.4/§3.7.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Zwei von der Festlegung-4-Umstellung abhängige Stellen behalten den Vorteilungs-Kanten-Namen: Trigger 3 („Wenn die `adapters→app`-Kante gebraucht wird", :274) und die Option-A-Zeile (:207) nennen die Direkt-Import-Kante mit dem Namen der einen Adapter-Schicht vor der Teilung, während die normative Benennung (Festlegung 4, :176-182), die Referenz-Zeile (:91) und die Fitness-Zeile (:259) `driving_adapters→app` führen — nach der Teilung kann unter inward-only nur ein treibender Adapter app direkt importieren. Versagens-Szenario: ein Leser, der Trigger 3 oder die Option-Zeile gegen Festlegung 4 verifiziert, findet die genannte Kante unter keinem Layer-Namen der neuen Config; die normative Stelle steuert aber eindeutig, deshalb kein Block. Nicht gemeldet sind :79-80 — dort zitiert der Text die ADR-0009-Namen für ADR-0009-Inhalt („verbatim fort"), und [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) :68 führt genau diese Kanten-Namen. | [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Festlegung 4 | `docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md:207,274` | nein — String-Vergleich gegen die Festlegung-4-Liste; kein Gate liest den ADR-Text | Re-Schnitt läßt abhängige ADR-Abschnitte am alten Stand |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Runde-3 F-1 (HIGH) — Trigger 2 gezogen | geprüft, ohne Befund — alle drei Befund-Elemente der Runde 3 sind im Fix enthalten: (a) die Bedingung steht auf dem neuen Zustand („portScope-Fix sich zurücknimmt oder das Grading wieder infrage gestellt wird", konkretisiert als a-check-Downgrade oder Config-Drift) statt auf der durch die Emission bereits erfüllten Grading-Einschaltung; (b) die portScope-Klammer („oder der a-check scopet das Richtungs-Segment weg") ist entfallen — die zwei Rück-Pfade benennen dieselbe Gefahr ohne das entfallene Werkzeug-Verhalten; (c) die Konsequenz ist Zukunfts-conditional („ein Zurück auf die Inert-Form wäre eine Neufassung mit eigenem Beleg") statt der Forderung nach der Neufassung, die der Re-Schnitt selbst vollzog, und nennt den Zustand, den es nicht mehr gibt, nicht mehr als vorhandenen. Der Zustands-Satz („sie ist mit a-check v0.20.0 gesetzt und nicht opt-in") deckt Festlegung 3 („lebend", „nicht opt-in") — der Widerspruch Trigger-gegen-Festlegung ist aufgelöst, und der Trigger ist kein Spent-Trigger mehr: Seine Bedingung trifft heute nicht zu. |
| Runde-3 F-2 (LOW) — Supersedes-Gegenstand (iii) gezogen | geprüft, ohne Befund — :46-47 nennt `driving_adapters→ports_inbound` (die kommende Port-Kante) und `driving_adapters→app` (die abgelöste Kante), deckungsgleich mit der Festlegung-4-Benennung (:176-182) und der Fitness-Zeile (:259). |
| Fünf Trigger — vollständig, keiner fragmentiert | selbst gelesen, :264-281 — der Architect meldete, sein Zeilen-Griff habe zwei Fragmente hinterlassen (Rest des alten Trigger 2; Trigger 3 ohne erste Zeile) und sie manuell repariert; die Liste trägt genau fünf Trigger, je mit Bedingung und Konsequenz: 1 Upstream-Nachzug des ADR-0009-Autors · 2 portScope-Fix-Rücknahme/Grading infrage · 3 Direkt-Import-Kante gebraucht · 4 Rollen-Namen im Bestand (`internal/gen/arch.go`) · 5 drittes hexslice-Layout. Kein Fragment, kein abgebrochener Satz, Trigger 3 trägt seine erste Zeile wieder. `docs-check` sieht diese Prosa-Struktur nicht — die Prüfung war darum nur lesend möglich und ist gefahren. |
| Konsistenz gegen [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md)/[`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md)/[`ADR-0008`](../../docs/plan/adr/0008-arch-achse-emittiertes-skelett.md) (Acceptance-Trigger) | geprüft, ohne Befund für den Gegenstand dieser Runde — `06991d30` ist der einzige Commit an der Datei seit dem Runde-3-Stand `6228cbd5` (selbst gefahren), die Runde-3-Negativbefunde zu den drei Accepted-ADRs tragen für den unveränderten Text; die zwei geänderten Hunks (Supersedes iii, Trigger 2) berühren keine Aussage der drei: der Supersedes-Gegenstand (iii) bleibt derselbe dritte Gegenstand, nur benannt; Trigger 2 ist ADR-0060-eigene Reife-Steuerung. Die ADR-0009-Namen in :79-80 sind Zitat, nicht Rest (Begründung bei F-1). |
| [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 — Form dieses Belegs | erfüllt — die Runde 3 meldete einen blockierenden Befund (F-1 HIGH); der Beleg für den Accept ist damit eine erneute Runde derselben prüfenden Rolle. Dieser Lauf ist sie: eigener Reviewer-Kontext, erster Lauf nach der Behebung, Report ohne blockierenden Befund in `docs/reviews/`. Der auflösende Architect-Kontext trägt den Beleg nach jener Festlegung nicht — die Nachmessung wäre keine gewesen. |
| Commit-Zuschnitt | geprüft, ohne Befund — `06991d30` berührt allein die ADR-Datei (5+/5-, zwei Hunks: :46, :270-273), keine Berührung von `AGENTS.md`/`harness/conventions*` (§3.8); der Status bleibt Proposed, kein vorzeitiger Index-Zusatz. |
| MR-025 | geprüft, ohne Befund — die geänderten Hunks führen keine Zahl; die Stand-Angabe „a-check v0.20.0" ist eine Versions-Pinnung, kein Messwert. |
| Fremd-Kennungen | geprüft, ohne Befund — der Fix-Diff zitiert keine fremde ADR-/Slice-Kennung; „portScope-Fix" bleibt Werkzeug-Bezeichnung ohne Kennung. |
| Gate-Belege dieser Runde | nicht neu gefahren — der Beleg „make docs-check 1752/0, make gates EXIT 0" steht in der Message von `06991d30` (Architect-Angabe, hier nicht wiederholt); die zwei geänderten Hunks führen keine Links/Anker, der docs-check-Vertrag ist davon nicht berührt. Die Struktur-Prüfung der Trigger-Liste ist Prosa und von keinem Gate erreicht — deshalb selbst gelesen (Punkt 3 oben). |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klasse dieses Laufs:** Re-Schnitt läßt abhängige ADR-Abschnitte am alten Stand —
zweiter Vorgang derselben Klasse (Runde 3: zwei Funde in einem Vorgang; diese Runde: ein Fund
im zweiten Vorgang, zwei Stellen :207/:274, eine Klasse).

## Verdikt

**Merge-blockierend: nein.** Die zwei Runde-3-Befunde sind gezogen und in der Form geprüft:
Trigger 2 steht auf dem neuen Zustand, seine Bedingung ist nicht mehr bereits erfüllt, die
portScope-Klammer ist entfallen, und die Konsequenz fordert die Neufassung nicht mehr ein, die
der Re-Schnitt selbst vollzog — der Widerspruch zwischen Trigger und Festlegung 3 ist weg, und
der Accept-Übergang friert keinen Spent-Trigger ein. Der Supersedes-Gegenstand (iii) nennt die
Kanten-Namen deckungsgleich mit Festlegung 4. Die fünf Trigger sind vollständig (selbst gelesen,
keiner fragmentiert).

**Ready for Accept: ja.** Die Accept-Zeile der §Geschichte nennt diesen Beleg nach
[`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2: erneute Runde derselben prüfenden Rolle nach der blockierenden Runde 3, Report
ohne blockierenden Befund in `docs/reviews/`. Der LOW-Befund (F-1, :207/:274) blockiert nicht —
will der Architect ihn vor dem Umschlag nachziehen, geht das in einem Inhalts-Commit bei weiter
`Proposed`-Status ohne weitere Runde (Festlegung 2 verlangt eine weitere Runde nur nach einem
blockierenden Befund); nach dem Accept friert die Stelle nach [`AGENTS.md`](../../AGENTS.md)
§3.4 ein und ist nur über Folge-ADR heilbar — der Accept-Übergang ist der letzte Moment, in dem
der Nachzug nichts kostet. Für den **Slice** ändert diese Runde nichts: kein Code-Befund, der
Weg zur Verifikation und Closure bleibt frei (Runde-3-Verdikt, unverändert).

Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen und
muß es nicht. Er ersetzt keine Verifikation; DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11).
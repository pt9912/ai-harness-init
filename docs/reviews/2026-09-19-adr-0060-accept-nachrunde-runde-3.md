# Review-Report: ADR-0060 — Accept-Nachrunde (Runde 3) — 2026-09-19

**Review-Art:** Konsistenz — der Accept-Beleg nach
[`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 (die erneute Runde derselben prüfenden Rolle; die blockierende Runde 2 kann ihn
nicht tragen). **Enger Auftrag: allein der Re-Schnitt, kein Neu-Review des Slices.**

**Gegenstand:** allein Commit `6228cbd5` — die Festlegungen 3 und 4, die Option-C-Zeile, der
neue §Kontext-Abschnitt „Die zweite Anpassung — a-check v0.20.0" und die History-Zeile des
Architects (1 Datei, 56+/32-). Der Code (`34c9e446`) ist nicht Gegenstand dieser Runde.
Runde 2 (`docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-runde-2.md`)
ist abgehandelt.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** glm-5.3-flash (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-19

Zitier-Form wie in der Runde 2 (dort als Norm ausgeführt): Kennung statt Adresse, Baseline-Stelle
als Tag + Pfad in Inline-Code — dieser Report friert ein, was er zitiert, bewegt sich weiter.

**Eingangs-Kontext:** [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
(Proposed, Stand `6228cbd5`), Runde-2-Report, [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 (Accept-Beleg), [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) /
[`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md) /
[`ADR-0008`](../../docs/plan/adr/0008-arch-achse-emittiertes-skelett.md) (Accepted),
[`AGENTS.md`](../../AGENTS.md) §3.7, kanonische Referenz (fremdes Repo, **nur gelesen**, Kennung
nicht zitiert): `lab/examples/go/.a-check.yml` und `lab/examples/kotlin/.a-check.yml`, Stand
`4153098` (2026-09-19 18:59, „track a-check v0.20.0 …").

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Re-Schnitt zieht seine abhängige Stelle im selben Dokument nicht nach: der Re-Evaluierungs-Trigger 2 (:270-272) steht unverändert auf der Inert-Welt der ersten Fassung. Seine Bedingung („wenn das hexslice-Gate die `port-direction-mismatch`-Grading einschaltet") ist durch die neue Festlegung 3 („— **lebend**"; „Die Richtung ist gesetzt, nicht opt-in") und die von der Runde 2 gemessene Emission bereits erfüllt; seine Konsequenz („dann wird die Adapter-Hälfte aus Festlegung 3 enforceable, und die Inert-Entscheidung ist neu zu fassen") fordert die Neufassung, die dieser Re-Schnitt selbst bereits vollzogen hat, und nennt einen Zustand („Inert-Entscheidung"), den die neue Festlegung 3 ausdrücklich abschafft; der Klammer-Zusatz („oder der a-check scopet das Richtungs-Segment weg") benennt das portScope-Verhalten, dessen Entfallen Festlegung 3 („Dieser Grund ist mit der Referenz-Anpassung entfallen") und der Kopf der Referenz-Config selbst dokumentieren. Versagens-Szenario: Nach dem Accept friert der Widerspruch ein ([`AGENTS.md`](../../AGENTS.md) §3.4) und ist nur über Folge-ADR heilbar — der Accept-Übergang ist der letzte Moment, in dem die Korrektur noch etwas kostet ([`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) §Konsequenzen); der nächste Trigger-Audit-Lauf (`v6.9.0` · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 2) liest einen Trigger, dessen Bedingung bereits erfüllt ist und dessen Konsequenz einen Zustand zur Neufassung auffordert, den es nicht mehr gibt; und ein Leser des Triggers allein schließt auf „Grading noch inert, opt-in" — gegen Festlegung 3 und die emittierte Config. | [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Festlegung 3 (:158-171) gegen Trigger 2 (:270-272); [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) §Konsequenzen (Einfrieren-Kosten) | `docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md:270-272` | nein — kein Gate liest ADR-Text; die Widerspruchs-Stellen sind textlich gegenläufig wiederholbar (Trigger-Zeile gegen Festlegungs-Zeile desselben Dokuments) | Re-Schnitt läßt abhängige ADR-Abschnitte am alten Stand |
| F-2 | LOW | Der Supersedes-Gegenstand (iii) nennt die neue Port-Kante noch mit dem alten Namen der einen Ports-Schicht: „`driving_adapters→ports` kommt" (:46). Nach dem Re-Schnitt heißen die Schichten `ports_inbound`/`ports_outbound` und die Kante `driving_adapters→ports_inbound` (Festlegung 4). Versagens-Szenario: ein Leser, der Gegenstand (iii) gegen Festlegung 4 verifiziert, findet die genannte Kante unter keinem Layer-Namen der neuen Config. | [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Festlegung 4 | `docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md:46` | nein — String-Vergleich gegen die Festlegung-4-Liste; kein Gate liest den ADR-Text | Re-Schnitt läßt abhängige ADR-Abschnitte am alten Stand |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Festlegung 3 — trägt die Runde-2-Befund-Breite? | geprüft, ohne Befund — der neue §Kontext-Abschnitt „Die zweite Anpassung" (:111-125) trägt die Runde-2-Messung vollständig (6 Layer, `direction:` auf Port- **und** Adapter-Schichten, Port-Globs am Richtungs-Segment, 6 Kanten-Zeilen, drei Abwesenheiten) samt Zähl-Kommando (MR-025); Festlegung 3 nennt den entfallenen portScope-Grund der ersten Fassung, seine Aufhebung durch die Referenz-Anpassung und den neuen Zustand („nicht opt-in"); Konsequenzen-Zeile (:225-227), Option-C-Zeile und Fitness-Zeilen (:259-260) ziehen mit. |
| Festlegung 4 — Referenz selbst gefahren | geprüft, ohne Befund — Stand `4153098` („track a-check v0.20.0 …", 2026-09-19 18:59): 6 Layer in den Festlegung-4-Namen (`domain`, `ports_inbound`, `ports_outbound`, `app`, `driving_adapters`, `driven_adapters`), 6 Kanten (`grep -c 'from:'` → 6) in derselben Reihenfolge wie Festlegung 4, drei bewusst abwesende Kanten mit genau den drei genannten Referenz-Gründen als Kommentare (Interface-Erfüllung + Composition Root · plain types · „Add the edge in the same commit"), die Richtungs-Kommentare („offered by the core …"/„needed by the core …") und die Kanten-Kommentare wörtlich deckungsgleich; die C++-Zusatz-Kante `driven_adapters→ports_outbound` steht in der Kotlin-Nominal-Referenz („Kotlin is nominal: the adapter names its port"). |
| Rot-Probe (Festlegung 3: „eine Config ohne `direction: inbound` auf der Ports-Schicht färbt den Gate-Test rot") | **bestätigt gegen die Runde 2 mit Begründung** — der selbst gefahrene Docker-Lauf blieb in dieser Runde am Tool-Ausfall hängen (s. Hinweis unten im Verdikt). Begründung der Übernahme: (1) der Zahn ist in dieser Runde **lesend selbst verifiziert** — `TestArchImagePin_CouplesToDirectionPorts` (`internal/gen/archgate_test.go:233-252`) verlangt `direction: inbound` in der emittierten Go- und C++-Config und färbt sonst rot mit „Config ohne "direction: inbound" — die Pin-Kopplung haelt an einer Config-Form, die es nicht gibt"; (2) die Emission ist seit dem Runde-2-Gegenstand **unverändert** (`git log 34c9e446..HEAD -- internal/gen/ internal/emit/` → leer, selbst gefahren); (3) der Re-Schnitt `6228cbd5` berührt nur die ADR-Datei. Die Runde 2 fuhr die Mutation selbst (Wegwerf-Änderung, zurückgenommen) mit benannten Test-Zeilen — derselbe Code-Stand, gegen den der Zahn bindet. |
| Option-C-Zeile (:209) | geprüft, ohne Befund — der Zustand „seit dem Re-Schnitt getragen (Festlegung 3)" ist wahr: der portScope-Grund der ersten Ablehnung ist entfallen (der Kopf der Referenz-Config dokumentiert den Fix), der `port-direction-mismatch` läuft (Referenz: „verified by injection, so the direction dimension is not a declaration into the void"); die Auflösung läuft über Festlegung 3 und die History-Zeile. |
| History-Zeile (:289) | geprüft, ohne Befund — Zustand („Festlegungen 3 und 4 sind gegen die v0.20.0-Referenz neu geschnitten", weiter Proposed) mit Kennungen statt Pfade (`936b1d84`, `929f288e`, `34c9e446`), keine Slice-Kennung (eine ADR nennt keine Slices), der Accept-Beleg-Anspruch nennt [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2; die Zeitlinie mit den zwei Re-Schnitten und der Referenz-Anpassung steht in §Kontext, nicht als Chronik im Kopf. Runden-Verweise im ADR-Rumpf sind Bestands-Form ([`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md), Accepted, trägt „Runde 3"/„Runde 4" im Rumpf). |
| [`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md) (Acceptance-Trigger nennt sie) | geprüft, ohne Befund — ihre Re-Evaluierungs-Trigger-Liste (:248-249) trägt die direction-Neubewertung an ihren eigenen Trigger („Wenn das emittierte Skelett seine Ports **teilt** … und ihr Weglassen ist neu zu bewerten"); der Trigger feuert mit dieser Entscheidung, die Neubewertung steht in ADR-0060 Festlegung 3 — Verbrauch durch den gefeuerten Trigger, keine Konkurrenz zweier Accepted-ADRs; die hexagonale Achse der ADR-0010-Festlegung 1 und die hexslice-Form dieser Entscheidung sind getrennte Emissionen. Kein Supersedes-Gegenstand nötig. |
| [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) | geprüft, ohne Befund — der Supersedes-Gegenstand trägt die drei Gegenstände (Ordner-Namen, Ports-Gliederung, Kanten-Menge) und bindet bis zum Accept unverändert fort; die Abweichung der Emission von ihm ist dieselbe, die die Teil-Ablösung trägt (Runde-2-Verdikt, hier nicht neu gemessen). |
| Emission seit der Runde 2 | geprüft, ohne Befund — `git log 34c9e446..HEAD -- internal/gen/ internal/emit/` → leer; die Runde-2-Messung (emittierte Config = Referenz exakt) trägt über den Re-Schnitt hinweg. |
| MR-025 | geprüft, ohne Befund — die Layer-/Kanten-Zahlen im neuen Kontext-Abschnitt stehen neben `grep -c 'from:'`; die Zeit-Angaben (16:49/19:20) stehen neben den Commit-Kennungen, über die git sie liefert ([`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung): der Zahl-Beleg bindet die Commit-Message). |
| Runde-2 F-2 (Handbuch `:298`) | unverändert offen — Implementer-Arbeit; der Re-Schnitt berührt das Handbuch nicht. |
| Runde-2 F-3 (INFO, Digest↔Tag nicht gebunden) | unverändert offen — dieselbe Beobachtung im selben Vorgang wird nicht doppelt gezählt; die Konsequenzen-Zeile „der Pin-Digest ist gemessen" (:227) trägt dieselbe Lücke, die F-3 (INFO) benennt. |
| Fremd-Kennungen | geprüft, ohne Befund — der Re-Schnitt-Diff zitiert keine fremde ADR-/Slice-Kennung; das Referenz-Repo ist als kanonische Quelle benannt (Bezug über [`ADR-0005`](../../docs/plan/adr/0005-ziel-repo-distribution.md)), die fremde Werkzeug-Mechanik nur als „portScope-Fix" benannt. |
| Commit-Zuschnitt | geprüft, ohne Befund — `6228cbd5` berührt allein die ADR-Datei (56+/32-), keine Berührung von `AGENTS.md`/`harness/conventions*` (§3.8); der Status bleibt Proposed, kein vorzeitiger Index-Zusatz an der ADR-0009-Zeile (Folgepflicht 2 bindet ihn an den Accept-Übergang). |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klasse dieses Laufs:** Re-Schnitt läßt abhängige ADR-Abschnitte am alten Stand (zwei
Funde im selben Vorgang — eine Klasse).

## Verdikt

**Merge-blockierend: ja — F-1, am Accept-Übergang.** Die zwei geschnittenen Festlegungen selbst
sind sauber: Festlegung 4 deckt die v0.20.0-Referenz exakt (Referenz in dieser Runde selbst
gezählt — Layer, Kanten, drei Abwesenheits-Gründe, C++-Analog), Festlegung 3 trägt die
Runde-2-Befund-Breite (entfallener portScope-Grund, Aufhebung, neuer Zustand) samt Rot-Probe,
die Option-C-Zeile nimmt die Ablehnung wahr zurück, und die History-Zeile hält Zustand und
auflösbare Kennungen ohne Chronik im Kopf. Der Befund sitzt außerhalb der gezogenen Hunks, aber
in der Reichweite des Re-Schnitts: Wer die Festlegung 3 vom Inert-Zustand auf „lebend" schneidet,
muß den Re-Evaluierungs-Trigger mitziehen, der genau diesen Zustand zum Gegenstand hat — ein
Spent-Trigger ohne Vermerk in einer ADR, die mit dem Accept einfriert.

**Ready for Accept: nein.** Der Accept bleibt blockiert, bis der Architect Trigger 2 nachzieht
(und im selben Commit die Supersedes-Namensstelle, F-2). Danach trägt die nächste Runde dieser
Rolle den Beleg ([`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2) — sie kann auf die zwei Stellen geschnitten sein. Für den **Slice** ändert diese
Runde nichts: kein Code-Befund, der Weg zur Verifikation und Closure bleibt frei (Runde-2-Verdikt).

**Einschränkung dieses Laufs:** Die Rot-Probe wurde von der Runde 2 übernommen statt selbst
gefahren — drei Werkzeug-Ausfälle verhinderten den Docker-Lauf. Die Begründung steht im
Negativbefund-Block (Zahn lesend verifiziert, Emission unverändert, Re-Schnitt nur ADR-Datei);
der Accept-Lauf nach dem Nachzug sollte den Zahn einmal selbst rot gesehen haben.

Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen und
muß es nicht. Er ersetzt keine Verifikation; DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11).
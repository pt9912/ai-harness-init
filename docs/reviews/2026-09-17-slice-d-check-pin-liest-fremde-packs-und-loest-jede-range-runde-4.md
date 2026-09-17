# Review `slice-d-check-pin-liest-fremde-packs-und-loest-jede-range` (Runde 4) — 0 HIGH · 0 MEDIUM · 0 LOW · 1 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `0c8e1942` (HEAD), **lokal**,
Basis `1426af7d` · **Gegenstand:** allein dieser Commit — Setzung 4 und die dritte Zeile von
Setzung 2 in `MR-067` samt mitgezogenen Stellen · **Review-Art:** Nachprüfung von H-1 und H-2 aus
Runde 3 · **Nicht Gegenstand:** die DoD-Abhakung und die Befunde der Runden 1 bis 3.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:** Report Runde 3 (H-1, H-2) · `AGENTS.md` §3.6, §3.7, §3.8 als Vorbilder der
Cutoff-Form · `MR-032`, `MR-055`, `MR-060`, `MR-064` §Grenze · `LH-QA-01`, `LH-QA-03`.

---

## Nachprüfung

| Befund aus Runde 3 | Stand | Beleg |
|---|---|---|
| H-1 LOW — Setzung ohne Cutoff über einem append-only-Bestand | **erledigt** | Setzung 4 trägt alle vier Bestandteile der Vorbilder: die zeitliche Grenze („ab diesem Eintrag, kein Nachrüsten"), den gebundenen Gegenstand („die Aufbau-Anleitung, die **geschrieben oder geändert** wird"), die ausdrückliche Entlastung des Bestands („kein Arbeitsauftrag") und die Begründung „ein Maßstab darüber wäre dauerhaft rot und entwertete die Setzung". Dazu der Absatz *Eine Zahl steht hier nicht* mit der Einordnung Urteil/Muster und dem Verweis auf `AGENTS.md` §3.6 — genau die Bauform, die §3.7 für seine Zustandsfeld-Hälfte führt. Der Geltungsbereich ist mitgezogen, und der Auflösungs-Trigger sagt, dass Setzung 4 keinen hat, mit Grund |
| H-2 INFO — Bedingung prüft nur Abwesenheit | **aufgenommen** | Setzung 2 trägt jetzt drei Zeilen; die dritte prüft Anwesenheit. Der Eintrag begründet daneben, warum sie dasteht, obwohl ihr Fehlen laut scheitert — „sie kostet keine Deckung, sondern spricht aus, was die zwei anderen voraussetzen" — und nimmt damit die Einordnung aus Runde 3 auf, statt sie zu überdehnen |

**Konsistenz der mitgezogenen Stellen — geprüft, ohne Rest.** Die Überschrift nennt „zwei
Abwesenheiten und eine Anwesenheit", der Schlusssatz „ist eine der **drei** verletzt", Setzung 3
heißt jetzt „warum `count: 0` trägt" und spricht von *Pack-Zeile* und `count:` statt von Hälften,
der Satz nach der Tabelle trennt „die zwei Abwesenheiten … und die dritte Zeile ist gefahren", die
Grenze sagt „jeder Weg, der die Zeilen aus Setzung 2 erfüllt" und „die Kommandos brauchen nur
`git`" ohne stehengebliebene Zahl. Eine Suche nach den alten Formulierungen
(`zweiteilig`, `beide zusammen`, `erste/zweite Hälfte`, `zwei Zeilen`, `die drei Kommandos`)
findet **keine** Fundstelle. Die Aussage in *Schritt 5 ist kein Zierrat* — „wer hier aufhört, hat
die erste Zeile erfüllt und die zweite verletzt" — stimmt gegen Zeile 4 der Tabelle.

**Die dritte Zeile ist wahr.** In der eigenen Reproduktion aus Runde 3 (fremdes Wegwerf-Repo,
git 2.43.0) liefert `git cat-file -t` nach Schritt 5 `commit`, während im Pack-Verzeichnis nur
`loose-<hash>.{idx,pack,rev}` liegt — das Host-`git` liest das Pack unter fremdem Präfix, genau
wie die Zeile es voraussetzt. Neu gefahren ist dafür nichts; die Messung deckt die Zeile bereits.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| I-1 | INFO | Die dritte Zeile heißt „die Objekte der Range sind da" und prüft mit `git cat-file -t <Range-Basis>` **ein** Objekt. Ein Klon, dessen Basis-Commit lesbar ist und dessen Unterbaum es nicht ist, erfüllt sie und ist trotzdem nicht die gemeinte Lage — dieser Fall ist nicht hypothetisch, `MR-064` §Grenze misst ihn (Meldung `nicht lesbarer Unterbaum`). Folgenlos bleibt die Lücke aus demselben Grund wie H-2: Ein solcher Aufbau bricht unter beiden Ständen laut ab. Zuständig: Architect, als Won't-Fix vertretbar. | `MR-055` (eine Stellen-Prüfung trägt keine Aussage über die Menge) · `MR-064` §Grenze | `harness/conventions/MR-067-aufbau-anleitung-nennt-ihre-pruef-bedingung-vor-ihren-kommandos.md`, Feld `Setzung 2`, dritte Zeile | ja: ein Klon mit lesbarem Commit und unlesbarem Unterbaum erfüllt die Zeile | Anwesenheits-Prüfung an einem Objekt, benannt für die Menge |

Kein HIGH, kein MEDIUM, kein LOW. Kein Rollen-Konflikt.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Cutoff-Form gegen `AGENTS.md` §3.7/§3.8 | geprüft, ohne Befund: gleiche vier Bestandteile, gleiche Begründung, gleicher Urteil/Muster-Absatz; die Setzung behauptet keinen Wächter |
| `MR-060`/`MR-032` als genannte Träger | geprüft, ohne Befund: `MR-060` schließt das Nachtragen einer neuen Pflicht am Bestand aus, `MR-032` ist der Weg für eine wirklich abgelöste Anleitung — beide Verweise treffen, was sie behaupten |
| `MR-025` | geprüft, ohne Befund: die neuen Absätze führen keine neue Zahl ein; `2.43.0` und die Tabellenwerte stehen unverändert mit Kommando und Nicht-Erwartungswert-Vermerk |
| `AGENTS.md` §3.7 (Chronik) | geprüft, ohne Befund: kein Absatz erzählt die Entstehung, keine Befund-Kennung, kein Verweis auf einen Report; Setzung 4 begründet im Indikativ über den Zustand |
| `AGENTS.md` §3.5 | geprüft, ohne Befund: Setzung 4 **begrenzt** die Reichweite einer Setzung zeitlich, sie senkt keine Schwelle; die dritte Zeile ist eine Verschärfung |
| `AGENTS.md` §3.8 | geprüft, ohne Befund: `0c8e1942` berührt genau eine Datei unter `harness/conventions/` und nennt die Rolle |
| Eintrag noch nicht angenommen | geprüft, ohne Befund: `MR-067` ist nicht gepusht; die Änderung am eigenen, noch nicht angenommenen Eintrag ist der vorgesehene Weg und kein Überschreiben |
| Index- und §Baseline-Zeile | geprüft, ohne Befund: unverändert und weiter zutreffend — Titel und Geltungsbereichs-Anfang sind nicht berührt |

## Summary

**0 HIGH · 0 MEDIUM · 0 LOW · 1 INFO.** H-1 ist erledigt, H-2 aufgenommen, und die Umschrift auf
drei Zeilen ist an allen fünf mitgezogenen Stellen konsistent durchgeführt — eine Suche nach den
alten Formulierungen bleibt leer. Keine neue wiederkehrende Klasse für die Closure §7.

## Verdikt

**Push frei — aus Reviewer-Sicht abgeschlossen.** Über die vier Runden sind alle Befunde
aufgelöst: F-1 bis F-5 behoben, H-1 behoben, H-2 aufgenommen; offen bleiben F-6, F-7 und I-1, alle
INFO und alle Won't-Fix-fähig. **Closure unverändert offen** — sie liegt beim Planner
(`AGENTS.md` §3.10) und setzt die Verifikation voraus.

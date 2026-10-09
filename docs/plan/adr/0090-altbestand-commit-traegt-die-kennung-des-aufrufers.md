# ADR-0090: Der Altbestand-Commit von `archive-welle` trägt die Kennung, die der Aufrufer nennt — das Werkzeug bringt keine mit

**Status:** Proposed

**Datum:** 2026-10-09

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md),
[ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md),
[ADR-0065](0065-emittierte-kennungs-form-folgt-dem-regelwerk.md),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md)

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

**Schärft:** — keine Spec-Stelle. Die Entscheidung füllt zwei offen gelassene Stellen:
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) §Konsequenzen (*„Sie sagt
nichts über ein emittiertes Repo"*) und [ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegung 4 (entschieden ist, *dass* Werkzeug-Commits eine Kennung tragen, nicht *welche Form*).
Keine Accepted-Aussage fällt; kein `Supersedes`.

---

## Kontext

`kennungSuffix` (`internal/archive/anwenden.go`) hängt an beide Commit-Messages des Schlüssels
`altbestand` den Text `, ADR-0041`. Der git-eigene Träger lehnt eine Message ohne Kennung ab — im
Dogfood und im Ziel dieselbe Menge:

```text
$ grep -h '^patterns=' harness/tools/commit-msg-traceability.sh internal/emit/templates/enforce/commit-msg-traceability.sh
patterns='(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+)'
patterns='(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+)'
```

Im Ziel löst `ADR-0041` nicht auf; der Auftraggeber will keine Kennung dieses Repos im Ziel
(Auftrag zu `slice-ziel-traegt-keine-kennung-dieses-repos`). Der Schlüssel `altbestand` selbst trifft
kein Muster, und keine Kennung des Ziels ist dem Werkzeug als *zutreffend* bekannt: warum ein Ziel
seinen Altbestand archiviert, entscheidet das Ziel.

## Entscheidung

**1. Die Kennung kommt vom Aufrufer.** `archive-welle` nimmt eine Kennung als Argument
(`--kennung <K>`; im Make-Ziel `KENNUNG=<K>`) und hängt sie an beide Commit-Messages an. Für den
Schlüssel `altbestand` ist sie **Pflicht**: fehlt sie, bricht der Lauf in der Vorprüfung ab —
**vor** dem ersten `git mv` — und die Meldung nennt das Argument und dass eine Kennung des eigenen
Repos gemeint ist. Für eine Welle-Kennung ist sie **optional**. Das Werkzeug prüft die Kennung nicht
gegen `patterns=`: Richter bleibt der Träger des Ziels, die Menge steht an einer Stelle
([ADR-0065](0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 4).

**2. Keine Voreinstellung im Werkzeug, eine im Dogfood-Makefile.** Binär und emittiertes
`archivierung.mk` tragen keinen Default. Das Dogfood-`Makefile` setzt für `WELLE=altbestand` die
Kennung `ADR-0041` als Voreinstellung — sie löst hier auf und ist dort der Grund des Laufs; das
`Makefile` verlässt das Repo nicht.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — eine Saat-Kennung aus dem Lastenheft des Ziels | kein neues Argument | trifft eine Anforderung, die mit dem Archivieren nichts zu tun hat; ein Adopter, der seine Saat umbenennt, bricht den Commit — eine erfundene Traceability |
| B — `archive-welle:` in `patterns=` aufnehmen | kein Aufrufer-Aufwand | ein Werkzeug-Wort ist keine Kennung; genau die Ausnahme-Zeile, die [ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 als Senkung benennt (§3.5) |
| **C — der Aufrufer nennt die Kennung, Pflicht für `altbestand` (gewählt)** | die Kennung nennt den Grund, den nur das Ziel kennt; nichts dieses Repos im Ziel; Abbruch vor dem Move statt gestagtem Rename | ein Argument mehr für einen Lauf, der je Repo einmal stattfindet |
| D — `altbestand` im Ziel nicht anbieten | kein Argument | nimmt einem Adopter mit wellenlosem Bestand eine gelieferte Fähigkeit (`slice-emittierte-archivierung-kennt-den-altbestand`) |

## Konsequenzen

- Positiv: der Träger enthält keine Kennung dieses Repos mehr; der Altbestand-Commit trägt im Ziel
  eine Kennung, die dort auflöst — sofern der Aufrufer eine nennt, die sein Träger annimmt.
- Negativ (akzeptiert): eine Kennung, die das Ziel-Muster nicht trifft, fällt erst am Träger, also
  nach dem `git mv` — derselbe Fehlerpfad wie heute bei jeder abgelehnten Message; eine eigene
  Muster-Prüfung im Werkzeug wäre eine zweite Fassung der Menge. Ein Lauf je Repo rechtfertigt
  keinen weiteren Sensor.
- Negativ (benannt, nicht Gegenstand): Commits einer Welle-Kennung tragen im Ziel und im Dogfood
  heute kein Muster (`welle-` fehlt in `patterns=`); das schließt
  [ADR-0065](0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 4, deren Nachzug
  aussteht. Bis dahin kann der Aufrufer dort dieselbe optionale Kennung nennen.
- Folgepflicht (Implementer, `slice-ziel-traegt-keine-kennung-dieses-repos`):
  `kennungSuffix` liest die Aufrufer-Kennung statt der Konstante; Argument in
  `parseArchiveWelle` samt Hilfe; Vorprüfungs-Abbruch für `altbestand` ohne Kennung;
  `archivierung.mk` (emittiert) reicht `$(KENNUNG)` durch, ohne Default; Dogfood-`Makefile`
  `archive-welle` reicht `--kennung` durch mit der Voreinstellung aus Festlegung 2; Handbuch und
  `close-welle.md`-Vorlage nennen das Argument, wo sie den Altbestand-Lauf zeigen.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test in `internal/archive` bzw. `cmd/ai-harness-init` | `altbestand` ohne Kennung → Abbruch, Arbeitsbaum unverändert, kein Commit; mit Kennung `K` → beide Messages enthalten `K`, keine enthält `ADR-0041` | `make test` |
| `make full-smoke` (Ziel) | der Altbestand-Lauf mit einer Saat-Kennung des Ziels passiert den aktivierten Träger | kein Gate |

Rot zu sehen vom Implementer: Konstante `ADR-0041` zurück in `kennungSuffix` → Test 1 rot; Pflicht-
Prüfung entfernt → Test 1 rot am unveränderten Baum.

## Re-Evaluierungs-Trigger

- [ADR-0065](0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 4 ist nachgezogen und
  ein Adopter meldet, dass die Pflicht-Kennung beim Altbestand stört → Festlegung 1 neu wägen.
- Ein zweites Werkzeug-Kommando braucht eine Commit-Kennung ohne eigene Kennung im Gegenstand →
  dieselbe Form übernehmen oder hier verallgemeinern.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-09 | Proposed | Übergabe aus `slice-ziel-traegt-keine-kennung-dieses-repos` §4/§6 |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0090` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

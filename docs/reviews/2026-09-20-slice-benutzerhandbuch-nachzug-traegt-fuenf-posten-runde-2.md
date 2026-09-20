# Review-Report (Runde 2): slice-benutzerhandbuch-nachzug-traegt-fuenf-posten — 2026-09-20

**Review-Art:** Nachzugs-Review — prüft ausschließlich, ob der Implementer-Commit `26bdaa15` die
drei Runde-1-Findings (F-1 HIGH, F-2 MEDIUM, F-3 MEDIUM aus
[`2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md`](2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md))
tatsächlich behebt, und ob dabei neue Fehler entstanden sind. Kein erneutes Von-Null-Review des
ganzen Slice.

**Gegenstand:** `git show 26bdaa15` — ausschließlich `docs/user/benutzerhandbuch.md` (+8/-8, vier
Hunks).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0
**Modell:** claude-sonnet-5 (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-20

**Eingangs-Kontext:**

- Runde-1-Report (siehe oben) — Findings F-1/F-2/F-3 im Wortlaut
- Slice-Plan `slice-benutzerhandbuch-nachzug-traegt-fuenf-posten`
- [`ADR-0060`](../plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) (Accepted)
  §Konsequenzen
- Git-Historie: `v0.2.1`-Tag, Fix-Commit `366c8837`, Einführungs-Commits `8d77b91c`
  (span-report/span-clean), `3e535c3c` (archive-welle), `dff4a8f3` (traeger-fetch)
- Realer Code-Bestand:
  `internal/emit/templates/enforce/{erfassung,archivierung,traeger}.mk`,
  `internal/emit/templates/enforce/traeger-fetch.sh`

---

## F-1 (HIGH, Runde 1) — Prüfung

**Behauptung des Fix:** Die Rollen-Namensform (`driving`/`driven`, `ports_inbound`/
`ports_outbound`) ist „aktueller Quellstand" (ADR-0060, Accepted), aber **nicht** im
veröffentlichten `v0.2.1` enthalten; sie kommt erst mit dem nächsten Release-Schnitt.

**Verifikation:**

```
git merge-base --is-ancestor 366c8837 v0.2.1  → Exit 1 (false)
```

Der ADR-0060-Fix-Commit ist **kein** Vorfahre von `v0.2.1` — die neue Formulierung trifft zu:
`v0.2.1` trägt die Rollen-Namensform nicht. Beide geänderten Stellen (Software-Stand-Kopf Zeile 3,
§„Wichtig für die Pflege" Zeile 297) formulieren das jetzt konsistent: aktueller Quellstand via
ADR-0060-Link + Accepted-Status, `v0.2.1` liefert noch die alte, flache Form ohne `direction:`.
Beide neu verlinkten `ADR-0060`-Referenzen lösen auf (`docs/plan/adr/0060-…md` existiert, Status
`Accepted`, `git log` zeigt den Accept-Commit `387b5210`).

**Ergänzend geprüft:** Der Commit behauptet, die Bindung der vier Betriebs-Operationen an `v0.2.1`
sei bereits korrekt gewesen und brauche keine Änderung:

```
git merge-base --is-ancestor 8d77b91c v0.2.1  → Exit 0 (true)
git merge-base --is-ancestor 3e535c3c v0.2.1  → Exit 0 (true)
git merge-base --is-ancestor dff4a8f3 v0.2.1  → Exit 0 (true)
```

Alle drei Einführungs-Commits sind Vorfahren von `v0.2.1` — die Behauptung trägt, die
unveränderte Zeile „Seit `v0.1.1` (Juli) kamen vier Betriebs-Operationen hinzu" bleibt korrekt.

**Urteil F-1: geschlossen.** Die neue Formulierung ist faktisch korrekt und durch reproduzierbare
Kommandos belegt, nicht nur umformuliert.

## F-2/F-3 (MEDIUM, Runde 1) — Prüfung

Gegen `internal/emit/templates/enforce/{erfassung,archivierung,traeger}.mk` geprüft:

- `span-report` (`erfassung.mk:19-25`): prüft den Träger, meldet bei Fehlen „der Traeger liegt
  nicht … dieses Repo liest gerade nichts". Neuer Text nennt `span-report` korrekt als
  trägerabhängig und meldend.
- `span-clean` (`erfassung.mk:36-37`): reines `rm -rf $(SPAN_DIR)`, keine Träger-Referenz, kein
  Docker-Bezug. Neuer Text: „`span-clean` prüft den Träger gar nicht — sein Rezept löscht
  bedingungslos" und „`span-clean` braucht weder den Träger noch Docker" — beides trifft zu.
- `archive-welle` (`archivierung.mk:27-32`): prüft den Träger, meldet bei Fehlen „der Traeger liegt
  nicht … dieses Repo archiviert seine Wellen nicht". Neuer Text nennt `archive-welle` korrekt.
- `traeger-fetch` (`traeger.mk:30-31`, `traeger-fetch.sh:146`): ruft `docker run` auf (Transport im
  gepinnten `curlimages/curl`-Image); die drei übrigen Rezepte enthalten kein `docker`. Neuer Text:
  „Docker braucht nur `traeger-fetch`" — trifft zu.

**Urteil F-2/F-3: geschlossen für die ursprünglich gemeldeten Sätze.** Die konkret bemängelten
Pauschal-Aussagen sind präzisiert und stimmen jetzt mit dem Code überein. Der Fix hat dabei jedoch
zwei neue Ungenauigkeiten **derselben Fehlerklasse** eingeführt (siehe unten, F-5/F-6) — beide
liegen in Sätzen, die dieser Commit selbst umformuliert hat.

---

## Neue Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-5 | MEDIUM | Der neue Vorspann zu „Betriebs-Operationen" lautet: „Docker braucht nur `traeger-fetch` … Die drei übrigen rufen den bereits abgelegten **Träger** … direkt auf; `span-clean` braucht weder den Träger noch Docker …". Der erste Halbsatz behauptet, alle drei übrigen Operationen (`archive-welle`, `span-report`, `span-clean`) riefen den Träger direkt auf; der unmittelbar folgende Halbsatz desselben Satzes widerspricht dem für `span-clean` explizit. Tatsächlich rufen nur zwei der drei (`archive-welle`, `span-report`) den Träger auf (`archivierung.mk:28`, `erfassung.mk:20-21`); `span-clean`s Rezept (`erfassung.mk:36-37`) enthält keinen Träger-Aufruf. Derselbe Fehlermuster-Typ wie F-2 aus Runde 1 (pauschale Aussage über eine Gruppe, die nicht für alle Mitglieder gilt), diesmal innerhalb desselben Satzes selbst widerlegt. | Maintainability | `docs/user/benutzerhandbuch.md:363` | ja — `grep -n 'SPAN_CARRIER\|ARCHIV_CARRIER' internal/emit/templates/enforce/erfassung.mk` zeigt die Variable nur im `span-report`-Rezept, nicht im `span-clean`-Rezept | Selbstwiderspruch: Gruppenaussage im selben Satz durch Ausnahme für ein Gruppenmitglied widerlegt |
| F-6 | MEDIUM | Der Absatz „Was dabei fehlt" listet `traeger-fetch` unter den Operationen, „die das Repository … braucht" (den Träger): „… die das Repository für drei der vier Betriebs-Operationen (`archive-welle`, `span-report`, `traeger-fetch`) braucht …". Tatsächlich ist `traeger-fetch` die Operation, die den Träger **anlegt**, nicht eine, die ihn als Voraussetzung **braucht** — sie prüft seine Existenz nicht vorab und schreibt ihn unbedingt (`traeger-fetch.sh:38,141-142`, keine `-x $TRAEGER_CARRIER`-Prüfung vor dem Schreiben). Das Skript selbst nennt im Kopfkommentar nur „archive-welle, span-report u. a." als „Konsumenten" (`traeger-fetch.sh:6`), und zwei Sätze weiter im selben Handbuch-Absatz heißt es korrekt: „danach funktionieren `archive-welle` und `span-report` ebenfalls" — ohne `traeger-fetch` zu nennen. Richtig wäre „zwei der vier (`archive-welle`, `span-report`)"; die „drei"-Zählung ist ein Rest der Vorfassung (dort noch `span-clean` statt `traeger-fetch` im Vierer-Satz enthalten), bei dem der Fix `span-clean` entfernt, aber `traeger-fetch` fälschlich stehen gelassen hat, statt auf zwei zu kürzen. | Maintainability | `docs/user/benutzerhandbuch.md:315` | ja — `grep -n 'TRAEGER_CARRIER' internal/emit/templates/enforce/traeger-fetch.sh` zeigt nur Schreib-, keine Lese-Prüfung vor der Ablage; Kopfkommentar Zeile 6 nennt die Konsumenten explizit ohne `traeger-fetch` | Zähl-/Zuordnungsfehler: eine erzeugende Operation wird der Gruppe der konsumierenden zugerechnet |

Beide neuen Findings entstehen exakt an den Stellen, die dieser Fix-Commit umformuliert hat — sie
sind keine vorbestehenden, unberührten Aussagen, sondern Nebenprodukt der F-2/F-3-Korrektur selbst.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| F-1: `v0.2.1`/ADR-0060-Ancestor-Verifikation | geprüft, ohne Befund — `git merge-base --is-ancestor 366c8837 v0.2.1` liefert false, die neue Formulierung ist faktisch korrekt |
| F-1: Bindung der vier Betriebs-Operationen an `v0.2.1` (unverändert gelassen) | geprüft, ohne Befund — alle drei Einführungs-Commits (`8d77b91c`, `3e535c3c`, `dff4a8f3`) sind Vorfahren von `v0.2.1`, die Nicht-Änderung ist korrekt |
| Zwei neu verlinkte `ADR-0060`-Stellen | geprüft, ohne Befund — Datei existiert, Status `Accepted`, beide Anker lösen auf |
| F-2/F-3: Tabellenzeilen zu `traeger-fetch`/`archive-welle`/`span-report` in der Betriebs-Operationen-Tabelle | geprüft, ohne Befund — stimmen mit den `.mk`-Rezepten überein |
| F-2/F-3: „Ergebnis"-Satz am Ende des Betriebs-Operationen-Abschnitts | geprüft, ohne Befund — „danach funktionieren `archive-welle` und `span-report`" und „`span-clean` funktioniert unabhängig davon" sind beide korrekt |
| ADR-/Gate-Bezug, Gate-Lockerung, halluziniertes Gate | geprüft, ohne Befund — keine aktive ADR wird gebrochen, kein Gate gelockert oder erfunden |
| `make gates`/`make docs-check` selbst gefahren | nicht selbst gefahren (Docker-only, kein Docker-Zugriff in dieser Sitzung); Commit-Message nennt `docs-check 1775/0`, Link-Gate deckt aber keinen der hier gemeldeten Befunde (F-5/F-6 sind Tatsachen-, keine Link-Fehler) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Selbstwiderspruch: Gruppenaussage im selben Satz durch Ausnahme
für ein Gruppenmitglied widerlegt · Zähl-/Zuordnungsfehler: eine erzeugende Operation wird der
Gruppe der konsumierenden zugerechnet.

## Verdikt

**Merge-blockierend: nein.** F-1 (HIGH) ist geschlossen und mit reproduzierbaren
`git merge-base`-Kommandos verifiziert, nicht nur umformuliert. F-2/F-3 (MEDIUM) sind für die
ursprünglich zitierten Sätze geschlossen. Der Fix hat dabei zwei neue MEDIUM-Ungenauigkeiten
derselben Fehlerklasse (pauschale/falsche Gruppen-Zuordnung bei genau denselben vier
Betriebs-Operationen) an den von ihm selbst bearbeiteten Stellen hinterlassen: F-5 (Vorspann
„Voraussetzung", Selbstwiderspruch in einem Satz) und F-6 („Was dabei fehlt", `traeger-fetch`
fälschlich als Träger-Konsument statt -Erzeuger gezählt). Beide sind Präzisierungen ohne
Norm-/Gate-Bezug und blockieren den Merge nicht, gehören aber vor Closure behoben, da sie
denselben Nutzer-Irrtum riskieren, den F-2/F-3 bereits benannten (falsche Erwartung, welche
Operation Docker/den Träger braucht).

**Übergabe:** F-5/F-6 gehen als Präzisierungs-Findings an den Implementer. Die Finding-Klassen
gehen in die Slice-Closure §7 und von dort in den Steering-Loop-Zähler — dieselbe Klasse wie F-2/F-3
aus Runde 1, jetzt zum dritten/vierten Mal in derselben Textpassage aufgetreten (Steering-Loop-Signal:
diese Passage wird bei jeder Bearbeitung neu falsch gezählt). Dieser Report ist ein Lauf-Beleg und
wird über Läufe hinweg nicht erneut gelesen. Verifikation (DoD-/Spec-Konformität, inkl.
`make gates`) ist Aufgabe des Verifiers, nicht dieses Reports.

---

## Runde 3

**Review-Art:** Eng skopierter Nachzugs-Review — prüft ausschließlich, ob Fix-Commit `02670bed`
F-5 und F-6 aus Runde 2 tatsächlich behebt, mit gezielter Suche nach einer dritten
fehlklassifizierten Stelle in denselben zwei Textbereichen. Kein erneutes Von-Null-Review.

**Gegenstand:** `git show 02670bed` — ausschließlich `docs/user/benutzerhandbuch.md`, zwei Hunks
(Zeile ~315-321, Zeile ~361-367).

**Referenz-Klassifikation unabhängig verifiziert** gegen
`internal/emit/templates/enforce/{erfassung,archivierung,traeger}.mk` und
`harness/tools/traeger-fetch.sh`:

- Docker: `traeger.mk:30` ruft `bash tools/harness/traeger-fetch.sh`, dessen Zeile 146 `docker
  run --rm …` startet. `erfassung.mk` und `archivierung.mk` enthalten kein `docker`-Token (grep
  bestätigt: kein Treffer). → Docker-Bedarf: **nur `traeger-fetch`**, bestätigt.
- Träger-Voraussetzung mit Fehlend-Meldung: `erfassung.mk:19-25` (`span-report`) und
  `archivierung.mk:27-32` (`archive-welle`) prüfen je `[ -x "$$c" ]` und emittieren bei Fehlen
  eine Meldung, ohne zu schreiben. `erfassung.mk:36-37` (`span-clean`) ist ein bedingungsloses
  `rm -rf`, keine Träger-Referenz. `traeger.mk`/`traeger-fetch.sh` prüfen die Existenz des
  Trägers **vor** der Ablage nicht (kein `-x "$TRAEGER_CARRIER"`-Test vor `cp` in
  `traeger-fetch.sh:141`). → **nur `archive-welle`, `span-report`**, bestätigt.
- Träger-Unabhängigkeit: `span-clean` (kein Bezug) und `traeger-fetch` (legt ihn erst ab, keine
  Vorbedingungsprüfung) — bestätigt.

Die im Auftrag vorgegebene Referenz-Klassifikation ist damit unabhängig reproduziert, nicht nur
übernommen.

### F-5 — Prüfung

Zeile 364 (neu): „Docker braucht nur `traeger-fetch` — der Transport läuft im gepinnten Bild. Von
den drei übrigen rufen `archive-welle` und `span-report` den bereits abgelegten **Träger** …
direkt auf; `span-clean` braucht weder den Träger noch Docker, es räumt nur den lokalen
Erfassungs-Bestand weg."

Der Selbstwiderspruch aus Runde 2 ist aufgelöst: Der Satz benennt jetzt explizit nur zwei der
drei übrigen Operationen (`archive-welle`, `span-report`) als trägeraufrufend, statt eine
Gruppenaussage über alle drei zu treffen und sie im selben Satz für `span-clean` zu widerrufen.
Zahlenprobe: 2 von 3 „übrigen" (nach Abzug von `traeger-fetch`) rufen den Träger auf —
deckungsgleich mit der Referenz-Klassifikation.

**Urteil F-5: geschlossen.**

### F-6 — Prüfung

Zeile 318 (neu): „Der **Träger** … die das Repository für zwei der vier
`[Betriebs-Operationen](#betriebs-operationen)` (`archive-welle`, `span-report`) braucht …"

Die fälschliche Dritt-Zählung von `traeger-fetch` als Träger-Konsument ist entfernt; die Zeile
nennt jetzt exakt die zwei Operationen, die den Träger als Vorbedingung führen. Der Folgesatz
„danach funktionieren `archive-welle` und `span-report` ebenfalls" (Zeile 320, unverändert)
bleibt konsistent dazu — er nannte `traeger-fetch` schon vorher nicht.

**Urteil F-6: geschlossen.**

### Satz-für-Satz-Durchgang (dritte Stelle gesucht)

Jeder Satz in den Bereichen „Das aufgesetzte Repository prüfen" (Zeile ~305-320) und
„Betriebs-Operationen" (Zeile ~362-376, inkl. Tabelle), der eines der vier Kommandos nennt,
einzeln gegen die verifizierte Referenz-Klassifikation geprüft:

| Zeile | Satz (gekürzt) | Klassifikations-Aussage | Referenz | Treffer? |
|---|---|---|---|---|
| 318 | „Träger … für zwei der vier … (`archive-welle`, `span-report`) braucht" | 2 von 4 brauchen Träger | archive-welle, span-report | ✅ |
| 318 | „`make span-clean`, das den Träger gar nicht anfasst" | span-clean trägerunabhängig | trägerunabhängig | ✅ |
| 318 | „`make archive-welle`/`make span-report` melden … der Traeger liegt nicht" | beide melden Fehlen | beide melden Fehlen | ✅ |
| 320 | „danach funktionieren `archive-welle` und `span-report` ebenfalls" | nur diese zwei profitieren vom Fetch | korrekt, `traeger-fetch` nicht mitgezählt | ✅ |
| 364 | „Docker braucht nur `traeger-fetch`" | Docker nur bei traeger-fetch | bestätigt | ✅ |
| 364 | „Von den drei übrigen rufen `archive-welle` und `span-report` … direkt auf" | 2 von 3 übrigen rufen Träger auf | bestätigt | ✅ |
| 364 | „`span-clean` braucht weder den Träger noch Docker" | span-clean unabhängig von beidem | bestätigt | ✅ |
| 366 | „`archive-welle` und `span-report` melden fehlenden Träger" (unverändert von diesem Fix) | beide melden | bestätigt | ✅ |
| 366 | „`traeger-fetch` legt ihn bei Bedarf erst ab" | traeger-fetch = Erzeuger, nicht Konsument | bestätigt | ✅ |
| 366 | „`span-clean` prüft den Träger gar nicht" | span-clean unabhängig | bestätigt | ✅ |
| 370 (Tabelle) | „`archive-welle` und `span-report` setzen ihn voraus" | nur diese zwei setzen voraus | bestätigt | ✅ |
| 371 (Tabelle) | „Fehlt der Träger, schreibt das Kommando nichts und sagt das" (archive-welle) | korrekt | bestätigt | ✅ |
| 372 (Tabelle) | „Fehlt der Träger, meldet das Kommando das …" (span-report) | korrekt | bestätigt | ✅ |
| 373 (Tabelle) | span-clean-Zeile ohne Träger-Bezug | korrekt (keine Aussage nötig) | bestätigt | ✅ |
| 375 | „`make traeger-fetch` legt ihn ab, danach funktionieren `archive-welle` und `span-report`" | nur diese zwei profitieren | bestätigt | ✅ |
| 375 | „`span-clean` funktioniert unabhängig davon, mit oder ohne Träger" | korrekt | bestätigt | ✅ |

Keine dieser Zeilen wurde durch den Fix-Commit selbst berührt außer 318 und 364 (siehe Diff); die
übrigen waren bereits vor diesem Fix korrekt (bestätigt in Runde 2 als Negativbefund bzw. hier neu
gegenprobiert) und sind es weiterhin. **Kein drittes Fehlklassifikations-Finding gefunden** —
trotz gezielter Suche über den vollständigen Satzbestand beider Bereiche, nicht nur der beiden in
Runde 2 benannten Stellen.

### Negativbefunde (Runde 3)

| Bereich | Ergebnis |
|---|---|
| F-5 (Selbstwiderspruch Zeile 364) | geprüft, behoben — Satz benennt jetzt exakt 2 von 3, kein Widerspruch mehr |
| F-6 (Zähl-/Zuordnungsfehler Zeile 318) | geprüft, behoben — `traeger-fetch` nicht mehr als Träger-Konsument gezählt |
| Alle 16 Sätze/Tabellenzeilen mit Kommando-Nennung in beiden Bereichen | geprüft, ohne Befund — siehe Tabelle oben |
| Referenz-Klassifikation selbst | unabhängig gegen `.mk`-Dateien und `traeger-fetch.sh` nachgerechnet, ohne Abweichung |
| Neue ADR-/Gate-Verstöße durch diesen Fix | geprüft, ohne Befund — reine Textkorrektur, keine Code-/Gate-Änderung |
| `make gates`/`make docs-check` selbst gefahren | nicht selbst gefahren (Docker-only, kein Docker-Zugriff in dieser Sitzung) |

### Summary (Runde 3)

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 0 |

### Verdikt (Runde 3)

**Merge-blockierend: nein. F-5 und F-6 sind geschlossen.** Beide Korrekturen sind durch
unabhängige Gegenprobe gegen den Code-Bestand bestätigt, nicht nur gegenläufig umformuliert. Ein
vollständiger Satz-für-Satz-Durchgang über beide betroffenen Textbereiche (16 Einzelaussagen,
nicht nur die zwei ursprünglich benannten) findet **keine dritte Fehlklassifikation** — die
Vier-Wege-Klassifikation der Betriebs-Operationen ist an dieser Stelle des Handbuchs jetzt
durchgängig konsistent mit `internal/emit/templates/enforce/{erfassung,archivierung,traeger}.mk`
und `traeger-fetch.sh`. Kein neues Finding, kein HIGH.

**Übergabe:** Keine offenen Findings aus dieser Runde. Verifikation (DoD-/Spec-Konformität, inkl.
`make gates`) bleibt Aufgabe des Verifiers, nicht dieses Reports.

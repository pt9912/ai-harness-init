# Review-Report: slice-benutzerhandbuch-nachzug-traegt-fuenf-posten — 2026-09-20

**Review-Art:** Doku — geprüft gegen den Slice-Plan, die referenzierten LH-/ADR-IDs und den
tatsächlichen Code-/Werkzeug-Bestand (Modul 10 §Drei Review-Arten). Ein Doku-Nachzug wird gegen
die reale Mechanik geprüft, nicht nur gegen sich selbst — falsche Tatsachenbehauptungen sind hier
der Hauptgegenstand, nicht Formatierung.

**Gegenstand:** `git show be39594a`, ein Commit, nur `docs/user/benutzerhandbuch.md` (+27/-5). Der
Commit setzt fünf im Slice benannte „pausierte Nachzug-Posten" um: (1) Software-Stand-Metadaten
auf `v0.2.1`, (2) neuer Abschnitt „Betriebs-Operationen" für `traeger-fetch`/`archive-welle`/
`span-report`/`span-clean`, (3) Klon-Fall-Absätze in „Das aufgesetzte Repository prüfen", (4)
Zielordner-Form — laut Commit bereits aktuell, keine Änderung, (5) Ports-Form auf
`ports_inbound`/`ports_outbound` mit `direction:`.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0
**Modell:** claude-sonnet-5 (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-20

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-benutzerhandbuch-nachzug-traegt-fuenf-posten`
  (`docs/plan/planning/in-progress/`, §1 Ziel/Abgrenzung, §2 DoD, §6 Risiken vollständig gelesen)
- [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
- [`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  (Träger-Fetch-Mechanik)
- [`ADR-0060`](../plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) (Accepted —
  die Ports-/Adapter-Rollen-Namen, im Slice-Kopf als Verifikations-Report-Bezug zitiert)
- `AGENTS.md` §3 (Hard Rules), v. a. §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel)
- Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice,
  `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
- Realer Code-/Config-Bestand: `internal/emit/templates/enforce/{traeger,archivierung,erfassung}.mk`,
  `internal/emit/templates/enforce/traeger-fetch.sh`, `internal/gen/golang.go`,
  `cmd/ai-harness-init/main.go`, git-Tag-Historie (`v0.1.0` … `v0.2.1`)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Die neue Software-Stand-Zeile bindet die `driving`/`driven`- und `ports_inbound`/`ports_outbound`-Namensform an den als „aktuell ausgeliefert" bezeichneten Stand `v0.2.1` (`docs/user/benutzerhandbuch.md:3`: „Seit `v0.1.1` (Juli) kamen … und die geschichtete Bauform benennt Adapter- und Ports-Ordner nach ihren Rollen …"), und Posten 5 verstärkt dieselbe Bindung an derselben Adresse (Zeile 298: „unter `ports_inbound` bzw. `ports_outbound`"). Das widerspricht [ADR-0060](../plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) §Konsequenzen wörtlich: „Das published Release `v0.2.1` emittiert die alten Ordner und den alten Kanten-Set — wie geschnitten, unberührt; Ziele heilen über einen Re-Lauf mit der neuen Fassung, nicht über einen Re-Publish." Gemessen: der Tag `v0.2.1` ist Vorfahre des ADR-0060-Implementierungscommits `366c8837f` (`git rev-list --count v0.2.1..366c8837f` → 60 Commits danach); der Fix liegt **nach** dem Tag, den die Handbuch-Zeile selbst als aktuell ausgeliefert benennt. Ein Anwender, der dem empfohlenen Weg A (Download `v0.2.1`) folgt und `--arch hexslice` aufsetzt, bekommt die alte Struktur — nicht die im Handbuch beschriebene — und würde beim Nachtragen eines Ports laut §„Wichtig für die Pflege" `ports_inbound`/`ports_outbound`-Einträge anlegen, die im tatsächlich erzeugten `.a-check.yml` von `v0.2.1` keine Entsprechung haben. Kein Gate fängt das: `make docs-check` (Modul `links`) prüft nur, dass die Anker auflösen, nicht, ob die Aussage zutrifft. | ADR-0060 | `docs/user/benutzerhandbuch.md:3`, `:298` | ja — `git rev-list --count v0.2.1..366c8837f` (60, >0) belegt, dass der Renderer-Fix nach dem zitierten Release-Tag liegt; kein automatisierter Sensor hält Handbuch-Versionsaussagen gegen den Release-Stand | Handbuch bindet neue Renderer-Fähigkeit an einen Release-Stand, der sie laut eigener ADR-Konsequenz nicht trägt |
| F-2 | MEDIUM | Der neue Abschnitt „Betriebs-Operationen" verallgemeinert das Trägerlos-Verhalten über alle vier Kommandos: „jede meldet fehlenden Träger, statt rot zu färben" und (im Klon-Absatz) „`make archive-welle`/`make span-report`/`make span-clean` melden nach einem frischen Klon: „der Traeger liegt nicht … dieses Repo … nicht"". Tatsächlich prüft nur `archive-welle` und `span-report` den Träger und geben diese Meldung aus (`internal/emit/templates/enforce/archivierung.mk:28-32`, `erfassung.mk:20-25`). `span-clean` referenziert den Träger überhaupt nicht — sein Rezept ist ein bedingungsloses `rm -rf $(SPAN_DIR) && echo "span-clean: … entfernt"` (`erfassung.mk:36-37`) und meldet auf einem frischen Klon **keine** Träger-Meldung, sondern immer „entfernt". Die eigene Tabellenzeile zu `span-clean` behauptet diese Meldung korrekterweise nicht — der Widerspruch liegt zwischen dem einleitenden Satz/dem Klon-Absatz und der Tabelle selbst. | Maintainability | `docs/user/benutzerhandbuch.md:315` (Klon-Absatz), `:365` (Betriebs-Operationen-Vorspann) vs. `internal/emit/templates/enforce/erfassung.mk:36-37` | ja — Diff des Rezepts von `span-clean` zeigt keine Träger-Prüfung; ein Lauf auf frischem Klon ohne Träger meldet nur „span-clean: .harness/state/spans entfernt" | Verhaltensbehauptung über eine Kommandogruppe gilt nicht für alle Mitglieder der Gruppe |
| F-3 | MEDIUM | Der Vorspann zum neuen Abschnitt „Betriebs-Operationen" setzt „Docker läuft" als Voraussetzung für alle vier Operationen. Tatsächlich ruft nur `traeger-fetch` Docker auf (`docker run …` in `internal/emit/templates/enforce/traeger-fetch.sh:146`, Transport im gepinnten Curl-Image); `archive-welle` und `span-report` `exec`en den nativen Host-Träger direkt (`archivierung.mk:29`, `erfassung.mk:21`), `span-clean` ist ein reines `rm -rf` ohne Träger- oder Docker-Bezug. Ein Anwender ohne laufenden Docker-Daemon könnte dem Handbuch nach annehmen, `span-report`/`span-clean` seien ihm verwehrt, obwohl beide ohne Docker funktionieren (sobald der Träger einmal per `traeger-fetch` da ist). | Maintainability | `docs/user/benutzerhandbuch.md:363` | ja — `grep -n docker internal/emit/templates/enforce/{traeger,archivierung,erfassung}.mk` zeigt den Aufruf nur in `traeger.mk`/`traeger-fetch.sh` | Pauschale Docker-Voraussetzung für eine Kommandogruppe, die nur teilweise Docker braucht |
| F-4 | INFO | Der Commit-Trailer nennt `(LH-FA-01, LH-QA-04, ADR-0059)`, obwohl Posten 5 (Ports-Form) inhaltlich [ADR-0060](../plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) nachzieht (im Slice-Kopf selbst nur über den Verifikations-Report referenziert, nicht direkt über die ADR-ID). Die Traceability-Pflicht (§Traceability-Constraint: „mindestens eine ID") ist mit den drei genannten IDs formal erfüllt; die fehlende ADR-0060-Nennung ist eine Präzisions-Lücke, kein Verstoß. | Maintainability | Commit-Trailer `be39594a` | nein — kein Gate zählt, ob *alle* inhaltlich einschlägigen IDs im Trailer stehen, nur ob mindestens eine vorhanden ist | Commit-Trailer nennt nicht alle inhaltlich einschlägigen IDs |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Vier Betriebs-Operationen — Tabellenzeilen einzeln geprüft | geprüft, ohne Befund — die vier Zeilen selbst (`traeger-fetch`, `archive-welle`, `span-report`, `span-clean`) stimmen wörtlich mit den Meldungen/Kommentaren in `internal/emit/templates/enforce/{traeger,archivierung,erfassung}.mk` überein (u. a. die exakte Formulierung „das ist KEINE Aussage über den Bestand, sondern über den Leser" für `span-report`) |
| Posten 4 — Zielordner-Form | geprüft, ohne Befund — der Commit ändert hier nichts; `cmd/ai-harness-init/main.go` (positionales Ziel-Argument als `os.Args[1]`/Rest) und der bereits geschlossene `docs/plan/planning/done/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md` belegen, dass die Aufruf-Beispiele (Zeilen 209/221) schon vorher aktuell waren |
| Ports-Form — Feld-/Ordnernamen selbst | geprüft, ohne Befund — `ports_inbound`/`ports_outbound` und `direction:` sind gegen [ADR-0060](../plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) §Entscheidung Festlegung 2–4 und gegen `internal/gen/golang.go` (Zeilen 565–610, u. a. `direction: inbound`/`direction: outbound`) exakt bestätigt — nur die Versions-Bindung ist falsch (F-1), nicht die Namen |
| §6-Risiko des Slice-Plans („Die Adressen wandern mit dem Handbuch") | geprüft, ohne Befund — durch diesen Diff nicht ausgelöst; alle neu gesetzten/geänderten Zeilen-Adressen und Anker (`#betriebs-operationen`, `#ein-geschichtetes-grundgerüst-wählen---arch`, `#das-aufgesetzte-repository-prüfen`) lösen im geänderten Stand auf |
| AGENTS.md §3.6 bei reiner Doku-Änderung | anwendbar und ausgelöst — die einzige überprüfbare, unbelegte Tatsachenbehauptung dieses Diffs ist F-1 (bereits gemeldet); sonstige neue Aussagen (Betriebs-Operationen-Tabelle, Klon-Fall) sind entweder korrekt (siehe oben) oder unter F-2/F-3 gefasst |
| Anchor-/Link-Auflösung der neuen Abschnitte | geprüft, ohne Befund — alle neuen internen Links lösen auf reale Überschriften auf (`make docs-check` Modul `links` würde hier grün bleiben) |
| ADR-/Gate-Bezug, Gate-Lockerung, halluziniertes Gate | geprüft, ohne Befund — keine aktive ADR wird gebrochen (Verstoß ist eine Tatsachen-, keine Norm-Verletzung, siehe F-1-Einordnung), kein Gate wird gelockert oder erfunden; die Betriebs-Operationen sind im Diff selbst korrekt als „KEIN Gate" gekennzeichnet |
| `make gates` / `make docs-check` selbst gefahren | **nicht** selbst gefahren (Docker-only, Reviewer-Lauf ohne Docker-Zugriff in dieser Sitzung) — der Implementer-Commit nennt `docs-check 1774/0`, `comment-claims 72/0`; ein Link-Gate deckt jedoch keinen der hier gemeldeten Befunde (F-1 bis F-3 sind Tatsachen-, keine Link-Fehler) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Handbuch bindet neue Renderer-Fähigkeit an einen Release-Stand,
der sie laut eigener ADR-Konsequenz nicht trägt · Verhaltensbehauptung über eine Kommandogruppe
gilt nicht für alle Mitglieder der Gruppe · Pauschale Docker-Voraussetzung für eine Kommandogruppe,
die nur teilweise Docker braucht · Commit-Trailer nennt nicht alle inhaltlich einschlägigen IDs

## Verdikt

**Merge-blockierend: ja (F-1).** Die vier übrigen geprüften Posten (Software-Stand-Zahl,
Klon-Fall-Mechanik im Kern, Zielordner-Form, Namen der Ports-Form) sind sachlich korrekt und gegen
den realen Code-/Werkzeug-Bestand verifiziert. F-1 ist jedoch kein Stil-Nit: Der Diff verankert die
neue Rollen-Namensform explizit am Stand `v0.2.1` — genau dem Stand, den derselbe Diff als
„aktuell ausgeliefert" und über den empfohlenen Download-Weg beschreibt —, während die zugehörige,
Accepted-und-immutable ADR-0060 im eigenen Konsequenzen-Abschnitt das Gegenteil festhält. Das ist
keine Kategorisierungsfrage am Rand, sondern eine Tatsachenbehauptung, die ein Anwender auf dem
empfohlenen Pfad direkt widerlegt vorfindet. F-2/F-3 sind vor Closure klärungswürdig, aber nicht
für sich merge-blockierend.

**Übergabe:** F-1 geht an den Implementer (oder, falls strittig, über den Konflikt-Pfad aus
Modul 8 an den Architect, da es die Auslegung von ADR-0060 §Konsequenzen betrifft) — entweder die
Versions-Bindung wird auf einen künftigen Release-Stand verschoben/als „im Quellcode, noch nicht
im Release v0.2.1" präzisiert, oder ein neuer Release-Tag zieht ADR-0060 nach, bevor das Handbuch
es als Stand von `v0.2.1` behauptet. F-2/F-3 gehen als Präzisierungs-Findings an den Implementer.
Die Finding-Klassen gehen in die Slice-Closure §7 und von dort in den Steering-Loop-Zähler. Dieser
Report ist ein Lauf-Beleg und wird über Läufe hinweg nicht erneut gelesen. Verifikation
(DoD-/Spec-Konformität, inkl. `make gates`) ist Aufgabe des Verifiers, nicht dieses Reports.

# Review: slice-lifecycle-werkzeuge-tragen-die-kennung

**Rolle:** Reviewer · **Datum:** 2026-09-22
**Commit-Bereich:** `84db94b3..HEAD` (ein Implementer-Commit `59650366`)
**Plan:** [`docs/plan/planning/done/slice-lifecycle-werkzeuge-tragen-die-kennung.md`](../plan/planning/done/slice-lifecycle-werkzeuge-tragen-die-kennung.md)
**Bezug:** [`ADR-0053`](../plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md),
[`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer),
[`MR-059`](../../harness/conventions.md#mr-059)

Kontext gelesen: Plan (vollständig), `ADR-0053` (vollständig), `MR-059` (Setzung 1–5),
`docs/plan/planning/open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md` (vollständig),
`docs/plan/planning/done/slice-werkzeug-commits-tragen-eine-kennung.md` (vollständig), der volle
Diff des Commits `59650366`, `AGENTS.md` §3.

---

## Findings

### HIGH-1 — DoD (3) liefert Erkennungs-Arbeit, die zwei Planner-Dokumente einem anderen, noch offenen Slice zuweisen

- **kategorie:** HIGH
- **quelle:** [`ADR-0053`](../plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Folgepflicht 1 · Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice
  (Ausschluss-Disziplin) · [`MR-059`](../../harness/conventions.md#mr-059) Setzung 2
- **pfad:** `harness/tools/commit-msg-traceability.sh:59-68`,
  `internal/emit/templates/enforce/commit-msg-traceability.sh:57`, `.d-check.yml:487-493`;
  Plan-Diff in `docs/plan/planning/done/slice-lifecycle-werkzeuge-tragen-die-kennung.md`
  §3 (Zeilen zu `commit-msg-traceability.sh`/`.d-check.yml`)
- **befund:**
  DoD (3) erweitert die **Erkennung** in `commit-msg-traceability.sh` und `.d-check.yml` um den
  freien Slug für `slice-`/`welle-`. Das ist exakt der Gegenstand, den zwei bereits vom Planner
  geschriebene Dokumente einem anderen, weiterhin offenen Slice zuweisen:
  - `docs/plan/planning/open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md` führt
    in seiner eigenen §3-Plan-Tabelle genau `harness/tools/` und `.d-check.yml`
    (`commits.id-patterns`) als seinen Änderungs-Gegenstand und schließt in §1 explizit aus, dass
    die *Nachricht* (das absorbierte `slice-werkzeug-commits-tragen-eine-kennung`) diese Arbeit
    mitübernimmt: *„er schreibt die Nachricht, jener [dieser Slice] die Erkennung, die sie
    liest."*
  - `docs/plan/planning/done/slice-werkzeug-commits-tragen-eine-kennung.md` — das von der aktuellen
    Datei laut `Übernimmt:` absorbierte Dokument — schließt „Die Kennungs-Erkennung" in §1
    ausdrücklich aus derselben Begründung aus und macht in §4 **den Abschluss von
    `slice-kennungs-erkennung-traegt-die-zugelassenen-formen` zur Start-Bedingung**: *„die
    Erkennung trägt die Form, in der die Kennung geschrieben wird"*.
  - `ADR-0053` Folgepflicht 1 überträgt dem Kandidaten-Slice nur, *„welche Form jede der vier
    Messages trägt"* zu entscheiden — nicht, die Erkennungs-Seite zu erweitern; genau diese
    Trennung wiederholt der zitierte Ausschluss oben.

  Weder erfüllt der aktuelle Diff diese Start-Bedingung (der Sibling-Slice liegt weiterhin in
  `open/`, nicht in `done/`), noch nennt die aktuelle Datei ihn unter `Übernimmt:`. Die Arbeit ist
  außerdem **unvollständig** gegenüber dem, was der eigentlich zuständige Slice verlangt hätte:
  Der Diff deckt nur zwei der drei in `MR-059` Setzung 1 zugelassenen Formen ab (Nummernform,
  freier Slug); die dritte — das **Anker-Präfix** (`slice-<Anker>-<Aspekt-slug>`) — bleibt
  unimplementiert und besteht die Gegenprobe nicht wirklich:

  ```
  $ echo 'slice-mv: slice-ADR-0053-anker-praefix-form.md  open/ -> next/ (reiner Move)' \
      | harness/tools/commit-msg-traceability.sh /dev/stdin   # exit 0 — aber nur, weil
                                                                # "ADR-0053" als Teilstring
                                                                # unabhängig matcht
  $ echo 'slice-mv: slice-CO-anker-praefix-form.md  open/ -> next/ (reiner Move)' \
      | harness/tools/commit-msg-traceability.sh /dev/stdin   # exit 1 — dieselbe Form, kein
                                                                # Anker mit erkanntem Präfix
  ```
  (`.d-check.yml`/`commit-msg-traceability.sh` führen ohnehin kein `CO-`-Muster — das
  Anker-Präfix ist also für die CO-Klasse strukturell nicht erkennbar, unabhängig von diesem
  Diff.) Genau diese Lücke — vollständige, **gelesene** Fundliste je Erkennungsstelle und ein
  roter Fall je Form, inklusive Anker-Präfix — ist der eigentliche Liefer-Punkt (1)/(2) des
  Sibling-Slice (`MR-059` Setzung 2/3). Der aktuelle Diff hat einen Teil dieses Gegenstands
  bereits „nebenbei" konsumiert, ohne die dortige Disziplin (Fundliste, Rot-Beleg je Form) zu
  tragen — wenn `slice-kennungs-erkennung-traegt-die-zugelassenen-formen` künftig gearbeitet
  wird, misst er gegen einen bereits veränderten Bestand, ohne dass dieser Diff das dokumentiert.

  Der Implementer rechtfertigt die Erweiterung im Plan-Diff mit §1 Ausschluss 1 des *aktuellen*
  Slice („die Erweiterung bleibt innerhalb der von MR-059 bereits erklärten Menge"). Das
  beantwortet nur die Frage *„ist die Form neu?"* (nein) — nicht die eigentlich strittige Frage
  *„gehört die Erkennungs-Änderung in diesen Slice?"*, die von zwei anderen, bereits existierenden
  Planner-Dokumenten explizit verneint wird.
- **verifizierbar:** ja — Vergleich der drei genannten Plan-Dateien plus die zwei
  `commit-msg-traceability.sh`-Aufrufe oben
- **klasse:** „Erkennungs-Arbeit eines fremden, noch offenen Sibling-Slice wird im absorbierenden
  Slice piecemeal miterledigt, ohne Übernahme-Vermerk und ohne dessen Vollständigkeits-Disziplin"

Dies ist ein Rollen-/Prozess-Konflikt im Sinne von Modul 8 §Konflikt-Pfad (die eigene
Scope-Einschätzung des Implementers steht gegen zwei geschriebene Planner-Artefakte). Nach
Modul 8 gehört die Auflösung nicht in eine Herabstufung des Findings, weil der Implementer
widerspricht, sondern in eine Sequenz mit Übergabe-Artefakt: Der Planner entscheidet, ob (a) DoD
(3) rückgängig gemacht und tatsächlich an `slice-kennungs-erkennung-traegt-die-zugelassenen-formen`
delegiert wird, (b) dieser Slice nachträglich auch den Sibling per `Übernimmt:` aufnimmt und die
dort verlangte Vollständigkeits-Disziplin (Fundliste, Rot-Beleg je Form inkl. Anker-Präfix)
nachliefert, oder (c) eine dritte, hier nicht antizipierte Lösung — aber nicht durch eine
Herabstufung dieses Findings, weil der Implementer-Kommentar im Plan-Diff „vertretbar klingt".

---

## Weitere Prüfpunkte

### §1-Ausschluss-Prüfung (Punkt 2 des Auftrags)

- Ausschluss 1 („keine neue Kennungs-Form") — **eingehalten**: Es wird keine vierte Form erfunden,
  nur die bereits in `MR-059` Setzung 1 erklärten Formen werden (teilweise, s. HIGH-1) in der
  Erkennung nachgezogen.
- Ausschluss 2 („Bestand der 94 kennungslosen Messages wird nicht umgeschrieben") —
  **eingehalten**: kein Git-History-Rewrite im Diff.
- Ausschluss 3 („`make slice-mv` bekommt keine neue Fähigkeit") — **eingehalten**:
  `harness/tools/slice-mv.sh` ist im Diff unverändert (§3-Tabelle korrekt auf „keine Änderung"
  aktualisiert).
- Ausschluss 4 („Archivierung des Altbestands wird nicht gefahren") — **eingehalten**, nicht
  berührt.
- Der eigentliche Scope-Bruch (HIGH-1) liegt **außerhalb** der vier expliziten
  §1-Ausschlusspunkte dieses Slice selbst — er entsteht dadurch, dass die Arbeit in ein Gebiet
  hineinreicht, das zwei **andere** Plan-Dokumente exklusiv beanspruchen, nicht dadurch, dass eine
  eigene Ausschlusszeile verletzt wäre. Das ändert an der Einordnung nichts: „Wer später etwas
  mitnimmt, das [in einem verwandten Dokument] ausgeschlossen war, hat den Plan geändert, nicht
  nur ergänzt" (Modul 5).

### Rot→Grün-Beleg, selbst nachgebaut (Punkt 3)

DoD (3) real reproduziert, ohne Docker (der Hook liegt bewusst außerhalb von `make`,
[ADR-0053](../plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) §Kontext):

```
$ printf 'slice-mv: slice-lifecycle-werkzeuge-tragen-die-kennung.md  open/ -> next/ (reiner Move)\n' > msg.txt
$ bash harness/tools/commit-msg-traceability.sh msg.txt; echo $?          # mit Fix: 0
$ # patterns= auf die alte Muster-Menge zurückgesetzt (ADR-.../LH-.../MR-.../slice-[0-9]+ ohne Slug-Alternativen)
$ bash harness/tools/commit-msg-traceability.sh msg.txt; echo $?          # ohne Fix:
commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):
            slice-mv: slice-lifecycle-werkzeuge-tragen-die-kennung.md  open/ -> next/ (reiner Move)
1
```
Rot trägt die behauptete Ursache, Grün stellt sich mit dem Fix wieder ein — Datei danach
unverändert restauriert (`git status --porcelain` leer). Für DoD (1)/(2) wurde **nicht**
eigenständig rot→grün nachgebaut (Docker-Go-Testlauf, Zeitbudget); stattdessen Code+Test
gelesen und geprüft, dass `make gates` (führt `make test` inklusive der drei genannten Tests
sowie `test/mutations/395…`) grün durchläuft. Das ist eine schwächere Bestätigung als ein
selbst gefahrener Rot-Pol für diese zwei Punkte — wird hier transparent benannt, nicht verdeckt.

### AGENTS.md §3.7 — Kommentar-Klassen (Punkt 4)

- `beoRE`-Kommentar (`internal/archive/stub.go`): beschreibt den Ist-Zustand (was die Regex
  matcht), begründet die Grenze (alte Form nicht mehr erkannt) im Indikativ, nennt die deckenden
  Tests namentlich. Keine Chronik, kein Commit-Hash, kein Review-Befund-Zeiger. **Eine leichte
  Unschärfe:** Der letzte Satz spricht von „Risiko 4 des auslösenden Slice" ohne dessen Kennung zu
  nennen — grenzwertig zwischen zulässiger Selbstreferenz und vager Herkunftsangabe, aber ohne
  Bezug auf ein Zeitdokument außerhalb der neun Ränge. Kein eigenständiger Befund, nur vermerkt.
- `kein-schreib-pfad`-Sperre (`internal/archive/vorschau.go`): Kommentar beschreibt die
  Bedingung und ihre Konsequenz im Indikativ, referenziert die gemeinsame Quelle
  (`EinPlanVorhanden`) — trägt die Kopplungs-Klasse sauber.
- `commit-msg-traceability.sh`-Kommentar zur `(-[a-z0-9]+)+`-Pflicht: erklärt eine **Grenze**
  (warum ein einzelnes Wort nicht reicht — Kollision mit Tool-Namen `slice-mv`/`archive-welle`)
  im Indikativ. Sauber.
- `test/mutations/395…`-Kopfkommentar zitiert „slice-lifecycle-werkzeuge-tragen-die-kennung DoD
  (2)" — das ist die etablierte Repo-Konvention für Mutationsfälle (Zusage-Klasse, vgl.
  [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
  kein Befund.

### Alte `BEO-NNN`-Form (Punkt 5)

Risiko 4 als „entfallen" für den **Stub-Link-Mechanismus** ist tragfähig begründet: Frozen
`done/`-Notizen behalten die alte Form (AGENTS.md §3.11 nimmt eingefrorene Artefakte aus), und
der Doc-Kommentar an `beoRE` benennt genau diesen Fall und seine Konsequenz (stille Zeile beim
künftigen Archivieren) explizit.

**Aber:** Mindestens zwei **lebende** (nicht eingefrorene) Slice-Pläne führen noch die veraltete
Platzhalter-Notation `BEO-<NNN>` in ihrem §7-Regelhinweis — unter anderem die hier geprüfte Datei
selbst (`docs/plan/planning/done/slice-lifecycle-werkzeuge-tragen-die-kennung.md` §7:
„vorhandene `BEO-<NNN>` **zitieren** statt neu formulieren") und
`docs/plan/planning/next/slice-218-harness-einstieg-behaelt-seine-index-form.md:231`. Das ist
Boilerplate-Prosa (kein tatsächlich zitierter Kennungs-Wert, den `Hervorgegangen()` verarbeiten
würde — eine Stichprobe über `open/`, `next/`, `in-progress/` fand **keine** echte `BEO-[0-9]{3}`
-Kennung als tatsächlichen Registerverweis, nur diese Platzhalter-Phrase), aber sie könnte einen
künftigen Closure-Autor in die falsche Notation führen. Das liegt außerhalb der Doku-Update-DoD
dieses Slice (die nennt nur `harness/README.md` und `harness/sensors/archive-welle.md`) und ist
vorbestehend, nicht durch diesen Diff verursacht — siehe LOW-1.

### Mengen-Messung (Punkt 6)

Nachgemessen mit dem im Diff verwendeten (erweiterten) Muster:
```
$ RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+|slice-[a-z][a-z0-9]*(-[a-z0-9]+)+|welle-[0-9]+|welle-[a-z][a-z0-9]*(-[a-z0-9]+)+'
$ git log --format='%s' | grep -c '^slice-mv:'                          # 594
$ git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"           # 1
```
Stimmt mit der Commit-Message-Behauptung „44 von 411, jetzt 1 von 594" überein (44/411 war die
Messung mit dem **alten** Muster gegen den damaligen Bestand, in `ADR-0053` selbst belegt — beide
Zahlen sind Momentaufnahmen, keine Erwartungswerte). Der einzig verbleibende Treffer ist exakt der
in der Commit-Message benannte Altfall ohne eingebettete Kennung.

### Doku-Nachzug (Punkt 7)

`harness/README.md` §Traceability: Zeile aktualisiert, nennt jetzt korrekt, dass `$base`/`b.Welle`
die Kennung bereits trugen und nur die Erkennung fehlte; die referenzierte Zahl (1 von 594) stimmt
(s. o.).

`harness/sensors/archive-welle.md`: `§Grenze Punkt 7` umformuliert (nicht gestrichen — anders als
in der Commit-Message suggeriert „ehemals §Grenze Punkt 7"; der Abschnitt trägt weiterhin einen
Punkt 7, jetzt mit neuem Inhalt zur `kein-schreib-pfad`-Sperre). Die Zahl „neun" Sperren
(`grep -c 'Kennung: "' internal/archive/vorschau.go`) nachgemessen: **9** — stimmt. Der
Doppel-Kreuz-Verweis (`††`) auf den umgekehrten Geltungsbereich ist konsistent mit dem Text unter
`altbestand`.

### `make gates` (Punkt 8)

Selbst gestartet und grün durchgelaufen (`baseline-verify`, `docs-check`, `lint`, `test`
inklusive `test/mutations/395…`, `build`, `comment-claims`, `host-bin`, `span-check` — Exit 0).

---

## Negativbefunde (geprüft, ohne Befund)

- `internal/archive/stub.go`/`stub_test.go` (DoD 1, `beoRE`/`Hervorgegangen`) — geprüft, kein
  Befund außer der leichten Unschärfe unter §3.7 oben.
- `internal/archive/collect.go`/`vorschau.go`/`anwenden.go` (DoD 2, `EinPlanVorhanden`/
  `kein-schreib-pfad`) — geprüft, kein Befund; Kopplung sauber auf eine Quelle gezogen.
- `test/commit-msg-hook.bats`, `test/commit-msg-emission.bats` (Kopplungs-Proben) — geprüft, kein
  Befund; neue Beispiel-Tokens decken die neuen Muster-Alternativen.
- `.d-check.yml`-Diff — geprüft, kein Befund an der Form der neuen Patterns selbst (nur am
  Scope, s. HIGH-1).
- Git-Historie / `AGENTS.md` §3.3 (Move vs. Inhalt getrennt) — dieser Slice hat bislang nur einen
  Implementer-Commit; kein `git mv` in diesem Commit enthalten, daher nicht anwendbar.
- Halluzinierte Gates / stilles Grün — geprüft, kein Befund; keine Gate-Config gelockert, keine
  neue Ausnahme in `scan.ignore` o. ä.

---

## Zusammenfassung

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 0 |

### LOW-1 — Emittierte Vorlage ohne die Design-Begründung der Dogfood-Fassung

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `internal/emit/templates/enforce/commit-msg-traceability.sh:57`
- **befund:** Die Dogfood-Fassung erklärt in einem Kommentar, warum die neuen Alternativen
  mindestens ein zweites Segment verlangen (Kollision mit den Tool-Namen `slice-mv`/
  `archive-welle`); die inhaltsgleiche Änderung an der emittierten Vorlage bekommt diesen
  Kommentar nicht. Ein Zielrepo-Maintainer, der die Vorlage liest, hat den Grund für die Form
  nicht vor Augen.
- **verifizierbar:** ja — Diff-Vergleich beider Dateien
- **klasse:** „Design-Kommentar zieht nicht auf die parallel gepflegte Emissions-Vorlage nach"

### LOW-2 — Boilerplate-Phrase `BEO-<NNN>` in lebenden §7-Regelhinweisen

- **kategorie:** LOW
- **quelle:** Maintainability / AGENTS.md §3.7 (angrenzend, nicht direkt verletzt — Prosa, kein
  Zustandsfeld)
- **pfad:** `docs/plan/planning/done/slice-lifecycle-werkzeuge-tragen-die-kennung.md:242-244`
  (§7 dieser Datei selbst), `docs/plan/planning/next/slice-218-harness-einstieg-behaelt-seine-index-form.md:231`
- **befund:** Mehrere lebende, nicht eingefrorene Slice-Pläne zitieren in ihrem §7-Regelhinweis
  weiterhin die vor `ADR-0034`/`slice-177` gültige Notation `BEO-<NNN>`, obwohl die tatsächliche
  Kennungs-Form seither `BEO-<KUERZEL>/<slug>` ist. Vorbestehend, nicht durch diesen Diff
  verursacht, aber von dessen Doku-Update-DoD nicht mit erfasst; Risiko einer künftigen
  Fehlnotation in einer echten Closure-Notiz.
- **verifizierbar:** ja — `grep -rn 'BEO-<NNN>' docs/plan/planning/{open,next,in-progress}/`
- **klasse:** „Regelhinweis-Boilerplate zitiert eine abgelöste Kennungs-Notation weiter"

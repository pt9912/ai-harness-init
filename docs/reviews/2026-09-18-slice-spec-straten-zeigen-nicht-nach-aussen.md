# Review-Report: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18

**Review-Art:** Code — geprüft wird der Diff gegen Plan, aktive ADRs und die Hard Rules
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: die prüft der Verifier
(Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).

**Gegenstand:** `7dee6676..bfd05e97`, drei Implementer-Commits
(`8cabca1e` Dogfood · `7c9a2741` Emission · `bfd05e97` erzeugte E2E-Sicht), Runde 1.

**Skill:** `.harness/skills/reviewer.md` v2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert,
> bewegt sich weiter. Deshalb **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle
> als Tag + Pfad in Inline-Code (`v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt>) statt als Link.
> Ortsfeste Ablagen (`.d-check.yml`, `internal/emit/templates/`, `test/mutations/`) stehen als
> Pfad, weil der Prozess sie nicht bewegt (`AGENTS.md` §3.11).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- der Slice-Plan `slice-spec-straten-zeigen-nicht-nach-aussen` (§1 Ziel und Abgrenzung, §3 Plan,
  §4 Trigger, §6 Risiken)
- das Architect-Verdikt vom 2026-09-18 zu demselben Slice — seine Antworten (a)/(b)/(c) und die
  sechs Punkte seines *Auftrags an den Implementer*
- `ADR-0013` (`Accepted`), `ADR-0034` (`Accepted`)
- `MR-001`, `MR-017`, `MR-025`, `MR-054`, `MR-055`
- `LH-FA-03`, `LH-QA-01`, `LH-QA-02`
- `AGENTS.md` §3.4 · §3.5 · §3.6 · §3.7 · §3.11
- `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)

**Eigene Messungen dieses Laufs.** Alle Sonden liefen in Wegwerf-Kopien im Scratchpad gegen den
**gepinnten** Stand `ghcr.io/pt9912/d-check@sha256:2f2f2460…` (`v0.76.3`), netzlos; der
Arbeitsbaum wurde nicht verändert. Keine Zahl unten ist ein Erwartungswert (`MR-025` Setzung 2).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | In der **emittierten** Konfiguration trägt die Klasse `welle` den Pfad `docs/plan/planning/**/welle-*.md`; der neu aufgenommene `exempt-paths`-Eintrag `docs/plan/planning/done/welle-*.md` nimmt sie damit aus der Status-Prüfung. Die vom Verdikt verbindlich gemachte Zwei-Stand-Sonde ergibt auf dieser Ebene *heute zurückgewiesen, nachher durchgelassen*: eine `done/welle-*.md`, die eine `Superseded`-ADR nennt, meldet unter der heutigen emittierten Fassung `matrix-inactive` und unter der vorgeschlagenen nichts mehr. Die Sonde im Umsetzungs-Commit ist nur gegen die Dogfood-Klassen gefahren, wo `welle` keine Klasse ist. | `AGENTS.md` §3.5 · `MR-017` · Architect-Verdikt 2026-09-18 §(b) und Auftrag 2/3 | `internal/emit/templates/d-check.yml:87` (gegen `:54`) | ja — dieselbe Zwei-Stand-Sonde auf der emittierten Klassenliste; **kein Gate dieses Repos fängt es**: `make full-smoke` misst, dass ein Verstoß rot färbt, nicht dass ein zuvor gefangener Zustand weiter gefangen wird | Exempt-Pfad aus der einen Ebene in die andere kopiert, ohne die Zwei-Stand-Sonde dort neu zu fahren |
| F-2 | MEDIUM | Die zwei neuen emittierten `matrix`-Positionen (Klasse `aussen` samt Regel, Klasse `adaptionsblock` samt `token:` und Regel) haben weder eine Zusicherung in `internal/emit/emit_test.go` noch einen Fall in `test/mutations/`. Die drei Geschwister-Positionen desselben Blocks haben beides (`emit_test.go:26/48/51` gegen `test/mutations/295-…`, `296-…`, `297-…`). Wird eine der neuen Positionen aus dem Template gelöscht, bleibt `make gates` grün; Träger ist allein `make full-smoke`, das die Sensors-Tabelle als `kein Gate` führt. Die Plan-Tabelle §3 Produkt-Ebene nennt die Zeile *„Test der emittierten Konfiguration … update"*. | `AGENTS.md` §3.6 (*wer keinen Fall in `test/mutations/` hat, ist unbewacht*) · Plan §3 · `LH-FA-03` | `internal/emit/templates/d-check.yml:59` und `:66`; fehlend in `internal/emit/emit_test.go` und `test/mutations/` | ja — Klasse `aussen` aus dem Template entfernen, `make gates` bleibt grün, `make mutate` meldet nichts | neuer-waechter-ohne-mutations-fall |
| F-3 | LOW | Zwei Stellen in `spec/spezifikation.md` tragen nach der Teil-Entfernung eine gebrochene Einrückung: Zeile 174 steht ohne Einrückung im Listenpunkt 5 (dessen übrige Zeilen drei Leerzeichen tragen), die Zeilen 253/254 tragen drei statt der zwei Leerzeichen ihres Aufzählungspunkts. Die Absätze bleiben durch die Lazy-Continuation lesbar; die Einrückung ist Rest des Schnitts. | Maintainability | `spec/spezifikation.md:174`, `:253` | nein — kein Modul der `.d-check.yml` prüft Einrückung | Teil-Entfernung lässt die Einrückung des Absatzes gebrochen zurück |
| F-4 | LOW | `matrix.exempt-paths` schreibt `docs/reviews/*.md`, während `ids.exempt-paths` und `codepaths.exempt-paths` in derselben Datei für dieselbe Begründung `docs/reviews/**` führen. Dass `*` keine `/`-Grenze überquert, ist in diesem Lauf gemessen — ein Unterverzeichnis unter `docs/reviews/` fiele damit nur bei `matrix` aus der Ausnahme. Heute ist das Verzeichnis flach, der Unterschied kostet also nichts und ist fail-closed gerichtet. | Maintainability | `.d-check.yml:365` (gegen `:334` im `ids`-Block und `:378` im `codepaths`-Block) | ja — ein Unterverzeichnis unter `docs/reviews/` anlegen und `make docs-check` fahren | drei Module derselben Config schreiben dieselbe Ausnahme in zwei Glob-Formen |
| F-5 | LOW | Der Kopfkommentar des Zahn-Blocks sagt *„matrix traegt drei gepruefte Aussagen und drei eigene Zaehne (…) und ein viertes"*; der Block führt danach vier `matrix`-Zähne, und die Gesamtzahl im Satz darüber lautet sechs. Die Zählung im Satz widerspricht der Aufzählung dahinter. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `harness/tools/full-smoke.sh:806` | nein — kein Gate liest Kommentar-Zählungen | Kommentar-Zählung widerspricht der Aufzählung dahinter |
| F-6 | LOW | Beide Konfigurationen begründen die Begrenzung des `MR`-Fangs damit, dass er *„nur eine klassifizierte Quelle trifft"*. Mit `aussen: ["**"]` **ist jede Datei eine klassifizierte Quelle**; was den Fang begrenzt, ist die Regel `spec-straten → adaptionsblock`, nicht die Klassifikation. Gemessen: eine blanke `MR-001` in `harness/conventions.md` des Ziels bleibt still, eine im Spec-Stratum färbt rot — beide sind klassifizierte Quellen. | `AGENTS.md` §3.7 | `internal/emit/templates/d-check.yml:48` und `:61` | ja — die Sonde dieses Laufs (blanke `MR-001` in beiden Dateien) | Kommentar begründet eine Begrenzung mit der Klassifikation statt mit der Regel |
| F-7 | INFO | `docs/user/e2e-abdeckung.md` steht in keiner der zwei Tabellen von §3, wird aber im Diff geändert. Die Änderung ist mechanisch erzwungen — die zwei neuen Zähne verschieben die Zeilennummern, und `test/e2e-abdeckung.bats` hält die Tabelle gegen den Ausgang ihres Erzeugers. Der Plan nennt den Erzeugnis-Pfad nicht. | Plan §3 | `docs/user/e2e-abdeckung.md` | ja — `make gates` (der Halter-Fall) | Plan-Tabelle nennt den Erzeugnis-Pfad eines mitwandernden Artefakts nicht |
| F-8 | INFO | §1 schließt aus: *„Der Slice fügt genau **eine** Regel hinzu, und ihre Quelle ist `spec-straten`"*. Die emittierte Hälfte trägt zwei neue Regeln plus eine neue Klasse. Die **Substanz** des Ausschlusses ist unberührt (beide Regeln haben `spec-straten` als Quelle, keine ein Planungs-Artefakt), die **Zählaussage** ist es nicht — DoD 3 desselben Plans sieht die Zusatz-Klasse ausdrücklich vor. | Plan §1 gegen Plan §2 DoD 3 | `internal/emit/templates/d-check.yml:70` | nein | Zählaussage im Ausschluss-Abschnitt wird von einem DoD-Punkt desselben Plans überholt |
| F-9 | INFO | Die Spezifikation sagt nach dem Schnitt *„Damit ist die Verbrauchs-Achse ohne Quelle"*, ohne offenzulegen, dass dieser Zustand als Carveout geführt wird. Die Führung bleibt bestehen (der Carveout-Index und vier ADRs nennen ihn, gemessen), die Spec selbst nennt sie nicht mehr. Das ist die vom Verdikt (c) gedeckte Folge der Setzung, aber sie ist nirgends im Stratum als solche benannt. | `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) | `spec/spezifikation.md:174` | nein | getilgter Verweis nimmt die Sichtbarkeit der Nachverfolgung mit |

### Belege zu F-1

Zwei-Stand-Sonde auf der **emittierten** Klassenliste, gepinnter Stand, netzlos; Quelldatei
`docs/plan/planning/done/welle-01-x.md` mit einem Verweis auf eine `Superseded`-ADR:

```text
heute (ohne aussen/adaptionsblock, ohne exempt-paths):
  docs/plan/planning/done/welle-01-x.md:3  ../../adr/0001-alt.md  matrix-inactive  Referenz auf inaktives Dokument (Status: Superseded)
vorgeschlagen (mit exempt-paths: [… , "docs/plan/planning/done/welle-*.md"]):
  (kein Befund zu dieser Datei)
```

Die Slice-Datei daneben bleibt in beiden Ständen rot — die Verengung gegenüber `done/**` trägt
also, sie deckt nur die falsche Hälfte. Im **Dogfood** ist derselbe Pfad unauffällig, weil dort
keine `welle`-Klasse existiert; genau diesen Unterschied benennt das Verdikt in §(b)
(*„die Welle-Dateien tragen heute keine Klasse — `welle` gibt es nur in der emittierten
Hälfte"*), und auf der emittierten Ebene kehrt er sich um.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Dogfood-`exempt-paths`, alle drei Pfade, Zwei-Stand-Sonde selbst gefahren | geprüft, ohne Befund — `docs/plan/adr/README.md`, `docs/reviews/*.md` und `docs/plan/planning/done/welle-*.md` sind in **beiden** Ständen frei; keine Senkung |
| Gegenprobe zur weiten Fassung im Dogfood (`docs/plan/planning/done/**`) | geprüft, ohne Befund an der Umsetzung — dieselbe Slice-Datei ist heute rot und unter der weiten Fassung frei; die weite Fassung **wäre** eine Senkung, und sie steht nicht in der Config |
| Enge `slice`-Klasse: überquert `*` eine `/`-Grenze? | geprüft, ohne Befund — selbst gemessen über die Klassen-Zuordnung in der Meldung: `done/welle-x/slice-tief.md` → `spec-straten → slice`, `done/a/b/slice-tief2.md` → `spec-straten → aussen`, `observations/<slug>/evidence/slice-*.md` → `spec-straten → aussen`. `*` matcht genau ein Segment; die Enge trägt |
| Treffen die fünf Pfade den Bestand? | geprüft, ohne Befund — `open` 75 · `next` 10 · `in-progress` 1 · `done` 195 · `done/<welle-id>/` 0 (keine Erwartungswerte). Der fünfte Pfad ist heute leer und darum eine Zusage nach vorn, wie §1 ihn ausweist, kein Befund |
| Rechtsverlust durch die Verengung | geprüft, ohne Befund — die 400 Beleg-Dateien des Registers wechseln von `slice` nach `aussen`; beide sind verbotene Ziele, und die Status-Prüfung trifft sie weiter. Die Verengung nimmt nichts weg |
| Die drei stehengebliebenen Dateinamen (`docs/user/claude-hooks-referenz.md`) | geprüft, ohne Befund — sie sind weder Link noch Kennung, treffen die Setzung des Auftraggebers also nicht; ihre **Existenz** bleibt bewacht: `codepaths` (`roots: [spec, docs, harness]`) meldet `codepath-missing`, sobald das Ziel verschwindet — selbst gemessen. Sie treten in eine bestehende, große Population derselben Form in denselben Dateien ein |
| Ebenen-Asymmetrie beim `MR`-Fang | geprüft, ohne Befund an der Sache — selbst gemessen: blanke `MR-001` im Stratum ergibt im Dogfood `id-unlinked` (auch **in** der Historie-Tabelle, die `ids` nicht ausnimmt) und in der emittierten Fassung `matrix-forbidden` über das `token:`; `harness/conventions.md` bleibt in beiden erlaubt. Die Begründung trägt und steht an der Stelle (Kopfkommentar des emittierten `matrix`-Blocks, §Modul `matrix` der Sensor-Doku) — ihre **Formulierung** ist F-6 |
| `slice`/`welle` bleiben im Template auf `**` | geprüft, ohne Befund — die Verengung im Dogfood stützt sich auf gezählten Bestand (681 → 281); im frischen Ziel ist dieser Bestand leer, eine engere Liste wäre dort eine Zusage über nicht messbaren Bestand (`MR-055`). Die Entscheidung steht als Kommentar im Template, nicht nur im Commit — das ist die unbequemere Hälfte, nicht die bequemere |
| Die 13 aufgelösten Fundstellen, Aussage-Erhalt | geprüft, ohne Befund — zwei Sätze waren reine Zeiger („Die Folge für die Erfassung führt …", „Die Ausfall-Achse führt …") und sind ganz entfallen; die übrigen tragen ihre Aussage aus dem umgebenden Text. Kein Rückbezug ohne Ziel mehr, und in den drei Straten steht keine blanke `MR-`/`ADR-`/`CO-`-Kennung (gemessen) |
| §1-Ausschlüsse 1 bis 6 | geprüft, ohne Befund — `exclude-sections` unverändert, der Abweichungs-Abschnitt bleibt in §5, keine Gliederungs-Änderung, keine Festlegung der schreibenden Rolle, keine Gegenrichtungs-Regel, kein `ignore-refs`-Paar. Der siebte ist F-8 |
| Größenregel (`≤ 3` Liefer-Punkte) | geprüft, ohne Befund — drei Liefer-Punkte, die Closure-Pflichten zählen nicht mit |
| Nachbar-Repo-Spuren im Diff (Pfade, fremde Slice-/Welle-Kennungen) | geprüft, ohne Befund — keine; die `DC-FA-*`-Kennungen sind Anforderungs-IDs des gepinnten Werkzeugs und in diesem Repo etablierte Zitierform (`d-check.mk`) |
| `AGENTS.md` §3.4 (`ADR-0013` unangetastet), §3.11 (keine bewegliche Adresse in einem einfrierenden Artefakt) | geprüft, ohne Befund |
| `make docs-check` über dem Arbeitsbaum | geprüft, ohne Befund — `1684 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 4 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** Exempt-Pfad aus der einen Ebene in die andere kopiert, ohne die
Zwei-Stand-Sonde dort neu zu fahren · neuer-waechter-ohne-mutations-fall · Teil-Entfernung lässt
die Einrückung des Absatzes gebrochen zurück · drei Module derselben Config schreiben dieselbe
Ausnahme in zwei Glob-Formen · Kommentar-Zählung widerspricht der Aufzählung dahinter · Kommentar
begründet eine Begrenzung mit der Klassifikation statt mit der Regel · Plan-Tabelle nennt den
Erzeugnis-Pfad eines mitwandernden Artefakts nicht · Zählaussage im Ausschluss-Abschnitt wird von
einem DoD-Punkt desselben Plans überholt · getilgter Verweis nimmt die Sichtbarkeit der
Nachverfolgung mit

## Verdikt

**Merge-blockierend: ja** — ein HIGH und ein MEDIUM.

F-1 ist der Fall, den das Architect-Verdikt **vorab** benannt hat: *„Ergibt die Sonde für einen
Pfad heute zurückgewiesen, nachher durchgelassen, ist dieser Pfad eine Senkung: Dann nicht
verengen und weiterlaufen, sondern die Rückführung `in-progress` → `open` aus §4 ziehen und das
Verdikt hier neu einholen — eine Senkung ist eine ADR-Frage, und die entscheidet nicht der bauende
Lauf."* Die Entscheidung über den emittierten Pfad gehört damit nicht in diesen Review und nicht in
den Implementations-Kontext; sie geht über die Rückkante an den Architect. Der Reviewer trägt hier
die **Messung**, nicht das Verdikt: dass der Pfad die Bedingung erfüllt, ist gemessen; ob die
Ausnahme trotzdem gerechtfertigt ist, ist eine ADR-Frage (`AGENTS.md` §3.5).

F-2 ist keine Zusage ohne Gegenbeispiel — das Gegenbeispiel läuft im E2E und ist dort benannt —,
sondern eine **Träger**-Frage: der einzige Wächter der beiden neuen emittierten Positionen liegt
außerhalb von `make gates` und außerhalb von `make mutate`, während die drei Geschwister-Positionen
desselben Blocks in beiden stehen. Die Beobachtung zählt auf `neuer-waechter-ohne-mutations-fall`,
deren `state.md` als Träger ausdrücklich *„das Review, das die neue Verdrahtung gegen den Fall-Satz
hält"* benennt.

Die LOW- und INFO-Befunde blockieren nicht; F-5 und F-6 liegen im Gate-Pfad und sind darum
benannt, obwohl sie nur Kommentartext betreffen.

**Übergabe:** Findings an den Implementer; F-1 zusätzlich über die Rückkante Review → Architect
(Rollen-Konflikt liegt nicht vor — der Implementer hat die Sonde auf der Dogfood-Ebene korrekt
gefahren und ihr Ergebnis korrekt berichtet; gemessen wurde die falsche Ebene). Die
**Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein
**Lauf-Beleg** und ersetzt keine Verifikation — DoD- und Spec-Konformität prüft der Verifier
separat (Modul 11).

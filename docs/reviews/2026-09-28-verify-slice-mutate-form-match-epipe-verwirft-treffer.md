# Verifikations-Report: slice-mutate-form-match-epipe-verwirft-treffer — 2026-09-28

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner.
Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan/ADR/Hard
Rules) und nicht der Validator.

**Gegenstand:** Slice `slice-mutate-form-match-epipe-verwirft-treffer`
(`docs/plan/planning/in-progress/slice-mutate-form-match-epipe-verwirft-treffer.md`, §1–§8
vollständig gelesen). Commits `91475e32` (slice-mv, reiner Move) und `de4ecb13`
(Implementierung). Review-Report `docs/reviews/2026-09-28-slice-mutate-form-match-epipe-verwirft-treffer.md`
gelesen (0 HIGH, 0 MEDIUM, 1 LOW F-1, 2 INFO F-2/F-3) — keine seiner Zahlen ungeprüft übernommen;
jede unten berichtete Messung ist selbst gefahren.

**Maßstab:** DoD (§2 des Slice-Plans, drei Liefer-Punkte), `LH-QA-01`, `AGENTS.md` §3.2/§3.3/§3.6/
§3.7, Baseline-Regelwerk Modul 11 (Bewusstes Brechen für DoD-Testbehauptungen), Modul 5 (Offene
Risiken werden bei Closure aufgelöst), MR-071 (Fall-Anlage misst gegen den Quell-Bestand).

## Ergebnis

| Punkt | Verdikt |
|---|---|
| DoD-Liefer-Punkt 1 — Zeile 808 gehärtet, Semantik erhalten, rot-vor/grün-nach | **bestätigt, unabhängig reproduziert** |
| DoD-Liefer-Punkt 2 — Mutations-/Test-Zahn bindet den Mehrfachtreffer-Fall | **bestätigt, unabhängig reproduziert** |
| DoD-Liefer-Punkt 3 — `harness/sensors/mutate.md` geprüft, kein Nachzug nötig | **bestätigt, unabhängig geprüft — Entscheidung war richtig** |
| `make gates` grün | **mit Einschränkung — siehe unten** |
| Review durchgeführt, Report liegt vor | bestätigt (Datei existiert, gelesen) |
| F-1 (LOW, Reviewer) — 0-Byte-`$out`-Grenzfall | **kein Korrektheitsrisiko — eigenständig verifiziert; Coverage-Lücke bleibt, nicht closure-blockierend** |
| §6-Risiko 1 (Grenzfall) | Empfehlung: **entfallen** (Semantik-Änderung widerlegt) + Coverage-Lücke separat als **weiter offen** |
| §6-Risiko 2 (generelle EPIPE-Klasse) | Empfehlung: **weiter offen** (Register, mit F-2 als erstem Datenpunkt) |

## DoD-Liefer-Punkt 1 — Härtung von Zeile 808

**Bricht, wenn:** die neue `form_matched()`-Form ändert das Ergebnis für den Leer-/Kein-Treffer-Fall,
oder das reale SIGPIPE-Verhalten der alten Form lässt sich nicht reproduzieren.

Eigenständig reproduziert, **ohne** auf den Reviewer-Beleg oder die CI-Log-Zeile zu vertrauen:
zwei Skript-Varianten in einer Scratch-Kopie gebaut (Alt: Zeile 808 als Live-Pipe
`grep -E … | grep -qF …`; Neu: unverändertes `harness/tools/mutate.sh` aus dem Arbeitsbaum) und
je 10× gegen ein Log mit einer Treffer-Zeile + 20 000 weiteren zur Form passenden Zeilen gefahren
(exakt die Konstruktion aus dem neuen `test/mutate-driver.bats`-Fall):

```
ALT:  10/10 Läufe → "fällt nicht" (Bug reproduziert)
NEU:  10/10 Läufe → Treffer erkannt (exit 0)
```

Zusätzlich mit einer direkteren Sonde (Bedingung als `if !`-Ausdruck im eigenen Wrapper, Exit-Code
statt bats-Bool) bestätigt: Alt 10/10 „fällt nicht", Neu 10/10 „trifft". `set -euo pipefail` steht
tatsächlich im Skriptkopf (Zeile 144, wie im Plan behauptet).

**Semantik-Erhalt eigenständig geprüft** (nicht nur den Reviewer-Beleg übernommen):

- Kein Treffer im Log (`ok 1 alles gut`) → `form_matched` liefert exit 1 („kein Treffer") — korrekt.
- 0-Byte-`$out` → `form_matched` liefert exit 1 — korrekt.
- **Wichtiger Zusatzbefund:** Ich habe geprüft, ob die alte (Live-Pipe-)Form den 0-Byte-Fall
  überhaupt jemals falsch behandelt hat — Ergebnis: **nein**, auch die alte Form lieferte für
  `$out` leer bereits korrekt „fällt nicht" (kein SIGPIPE möglich, da `grep -E` auf leerer Eingabe
  ohnehin ohne Ausgabe endet). Der 0-Byte-Grenzfall ist damit **kein** durch diesen Fix berührtes
  Verhalten — er war vorher wie nachher korrekt. Das schärft die Einordnung von F-1 (siehe unten).

**Verdikt: bestätigt, unabhängig reproduziert.**

## DoD-Liefer-Punkt 2 — Mutations-/Test-Zahn bindet den Mehrfachtreffer-Fall

**Bricht, wenn:** eine Rücknahme des Fixes den designierten Test nicht mit der behaupteten
Fehlermeldung rot färbt, oder der `sed`-Anker des Mutations-Falls trifft nicht eindeutig.

Eigenständig geprüft (nicht die Reviewer-Reproduktion übernommen):

1. **Anker-Eindeutigkeit (MR-071):** `grep -c '^  grep -qF -- "\$expect" <<<"\$matched"$' harness/tools/mutate.sh`
   → genau **1** Treffer, exakt die vom Mutations-Fall `496-…` per `sed` ersetzte Zeile.
2. **Mutation real angewendet** (Scratch-Kopie des committeten `harness/tools/mutate.sh`, exakt
   der `sed`-Ausdruck aus `test/mutations/496-mutate-form-matched-live-pipe-verwirft-treffer.sh`)
   und gegen dieselbe Log-Konstruktion wie im neuen bats-Test gefahren:
   `form_matched` liefert **Exit 141** — die SIGPIPE-Signatur (128+13), exakt der im Slice-Plan,
   der Commit-Message und dem Reviewer-Report behauptete Mechanismus, nicht nur irgendein Rot.
   Gegen dieselbe Konstruktion liefert das unveränderte, committete `harness/tools/mutate.sh`
   Exit 0. Das erfüllt AGENTS.md §3.6 („Das Rot muss die behauptete Ursache tragen, nicht
   irgendeine") **eigenständig**, nicht nur durch Übernahme der Reviewer-Aussage.
3. **`harness/sensors/mutate.md`**: kein Nachzug behauptet — siehe DoD-Liefer-Punkt 3 unten.

**Nicht selbst gefahren:** der volle `make mutate MUTATE_CASES=496-…`-Lauf über Docker (Zeit-
budget/Weisung „`make gates` nicht neu fahren"). Die obige bash-native Reproduktion prüft
denselben Mechanismus (Quelle sourcen, Funktion direkt mit denselben Argumenten aufrufen, die der
bats-Test und `run_case()` verwenden) und ist als Ersatz für den vollen Docker-Lauf hinreichend,
weil der Effekt (SIGPIPE unter `pipefail` bei Live-Pipe) auf Bash-Prozess-Ebene liegt, nicht auf
Docker- oder Isolationsebene.

**Verdikt: bestätigt, unabhängig reproduziert.**

## DoD-Liefer-Punkt 3 — `harness/sensors/mutate.md` geprüft

Eigenständig gelesen (vollständige Datei) und maschinell geprüft: `grep -niE 'grep|pipe|epipe|bedingung 4' harness/sensors/mutate.md`
→ **0 Treffer**. Die Datei trägt tatsächlich keinen Aussage-Satz über die interne Form von
Bedingung 4 — die Begründung „kein Nachzug nötig" ist zutreffend, nicht nur plausibel behauptet.

**Verdikt: bestätigt.**

## `make gates` — Stempel-Prüfung mit Einschränkung

`.harness/state/gates-passed.diffsha` → `2294c426…` (deckt sich mit der Reviewer-Aussage).
`bash harness/tools/working-tree-hash.sh` liefert **jetzt jedoch einen anderen Hash** und dabei
sogar **instabil zwischen zwei Aufrufen im Sekundenabstand** (`e9bf0b50…` → `151025cc…`,
identischer Dateibestand laut `git ls-files -z --cached --others --exclude-standard`).

**Ursache identifiziert, nicht spekuliert:** Der einzige Unterschied zwischen den Läufen ist die
Datei `docs/plan/planning/next/slice-mutate-workflow-laeuft-in-parallelen-shards.md` — ein
untracked Draft für einen **anderen, künftigen** Slice (anderes Thema: paralleles Sharding von
`make mutate`), der zu diesem Zeitpunkt **aktiv von einem parallel laufenden Prozess geschrieben
wird** (Inhalt ändert sich innerhalb von Sekunden, ohne dass ich ihn berühre). Das ist exakt die
Lage „nicht in laufende Agenten hineinmessen": Der Werkzeug-Hash misst gerade fremde,
gleichzeitige Schreibarbeit, nicht den Zustand dieses Slice.

**Für diesen Slice selbst ist die Lage klar:** `git diff --stat HEAD` ist leer — **kein** getrackter
Datei-Inhalt weicht vom commiteten Stand (`b61df668`, dem Review-Commit) ab. Die einzige Abweichung
vom gestempelten Baum ist die genannte, thematisch fremde Datei. Der Stempel `2294c426…` deckt
damit den Stand der **Liefer-Dateien dieses Slice** unverändert; er deckt **nicht** den aktuellen
Gesamtbaum, weil dieser gerade durch eine dritte, unabhängige Aktivität bewegt wird.

**Empfehlung an den Planner:** Vor dem finalen `git mv` nach `done/` und vor jedem neuen
`make gates`/`record-gates`-Lauf sicherstellen, dass keine parallele Schreibarbeit mehr läuft
(die Hash-Instabilität ist ein direktes Signal dafür) — sonst re-stempelt der nächste Lauf einen
Baum, der nicht der ist, den der Verifier/Reviewer geprüft hat. Das ist kein Befund gegen dieses
Slice, sondern eine Nebenwirkung eines nebenläufigen Planungsvorgangs, der derzeit im selben
Arbeitsbaum läuft.

**Verdikt: DoD-Liefer-Bedingung „`make gates` grün" ist für den Stand von `de4ecb13`/`b61df668`
erfüllt (Stempel deckungsgleich zum Zeitpunkt des Reviews); der *jetzige* Gesamtbaum ist wegen
externer, themenfremder Nebenläufigkeit vorübergehend nicht gestempelt — kein Handeln an diesem
Slice erforderlich, aber vor Closure zu beachten.**

## F-1 (LOW, Reviewer) — 0-Byte-`$out`-Grenzfall: eigene Einordnung

Frage laut Auftrag: Ist das sicherheits-/korrektheitskritisch genug, dass der Verifier selbst
einen bindenden Beleg nachträgt (Modul 11), oder genügt „weiter offen" bei der Closure?

**Eigene Prüfung, zwei Teile:**

1. Verhält sich der **jetzige** Code für `$out` leer korrekt? Ja — eigenständig verifiziert
   (Exit 1, „kein Treffer").
2. Ändert **dieser Fix** das Verhalten für diesen Grenzfall gegenüber vorher? **Nein** — die alte
   Live-Pipe-Form lieferte für ein leeres `$out` bereits dasselbe korrekte Ergebnis (kein SIGPIPE
   möglich, da nichts geschrieben wird). Das ist ein Befund, den weder Slice-Plan noch
   Review-Report explizit machen: **die Semantik-Zusage für den Leerfall war nie durch diesen Bug
   gefährdet.**

**Einordnung:** `mutate.sh` ist explizit **kein Gate** (`harness/sensors/mutate.md` §Vertrag,
Post-integration, nur nächtlich) — ein unentdeckter Rückfall in diesem einen Zweig würde frühestens
beim nächsten `mutate.yml`-Lauf sichtbar, nicht bei einem Merge oder Push blockierend. Kombiniert
mit dem Befund, dass der Code für diesen Zweig bereits vor und nach dem Fix korrekt ist (keine neue
Verwundbarkeit eingeführt), stufe ich das **nicht** als sicherheits-/korrektheitskritisch im Sinne
von Modul 11 ein — dort geht es um DoD-Punkte, deren Fehlen eine reale, durch den Diff eingeführte
oder unentdeckte Korrektheitslücke wäre. Hier ist es eine reine **Automatisierungs-/
Coverage-Lücke** (kein Test bindet das Verhalten für künftige Refactorings von `form_matched`),
kein akutes Risiko.

**Ich trage deshalb keinen eigenen bindenden Test nach** (das wäre ohnehin Implementer-Arbeit,
nicht Verifier-Arbeit) und akzeptiere „weiter offen" als korrekten Ausgang für die
Coverage-Teilfrage — siehe Risiko-Empfehlung unten.

## §6-Risiken — Ausgangs-Empfehlung

**Risiko 1** („Fix ändert die Semantik von Bedingung 4 in einem Grenzfall, den der neue Zahn nicht
direkt prüft"): Die im Risiko-Text konkret benannte Sorge — *„ändert der Fix die Semantik in
diesem Grenzfall?"* — ist durch meine Prüfung **widerlegt** (siehe oben: identisches Verhalten vor
und nach dem Fix). Empfehlung: **entfallen**, mit Begründung „Verifier hat eigenständig belegt,
dass Alt- und Neu-Form für `$out` leer identisch und korrekt sind (kein SIGPIPE-Risiko in diesem
Zweig); die Semantik-Änderungssorge trifft nicht zu." Die **davon getrennte** Beobachtung — es
existiert kein bindender Test für diesen Zweig — ist neu und sollte, falls der Planner sie
festhalten will, als eigener, kleiner Register-Eintrag (Sub-Area `TOOLS`) laufen, nicht als
Fortführung dieses Risikos (das Risiko, wie geschrieben, bezog sich auf eine Semantik-*Änderung*,
nicht auf fehlende Coverage an sich).

**Risiko 2** („EPIPE-Fehlurteil-Bug ist eine allgemeine Klasse, dieser Slice behebt nur die eine
gemessene Stelle"): Der Reviewer hat mit F-2 bereits eine zweite, strukturell verwandte Stelle
gefunden (`harness/tools/comment-claims.sh:105`, unverändert, außerhalb des Scopes). Das ist ein
erster realer Datenpunkt für genau dieses Risiko. Empfehlung: **weiter offen** → Beobachtungs-
Register, Sub-Area `TOOLS`, mit F-2 als erstem Beleg (Zähler-Stand 1, noch nicht bei 3×). Kein
Folge-Slice zwingend nötig, solange das Muster in `comment-claims.sh` nicht real feuert (INFO-
Charakter des Reviewer-Fundes).

## Was nur gelesen, nicht gemessen ist

- `test/mutate-driver.bats` insgesamt (Isolations-Tests, Teillauf-Tests) — nur die zwei neuen
  Testfälle wurden inhaltlich geprüft/reproduziert, der Rest der Datei nur gelesen (unverändert
  laut Diff).
- Der volle `make mutate`-Lauf über Docker — nicht gefahren (Weisung + Zeitbudget); durch
  bash-native Reproduktion des exakten Mechanismus ersetzt (siehe DoD-Punkt 2).
- CI-Lauf `mutate.yml` selbst — nicht neu angestoßen; der im Slice-Plan zitierte historische
  Befund wurde nicht erneut aus der GitHub-API gezogen, da die Ursache bash-nativ vollständig
  reproduzierbar war.

## Plan-vs-Code-Diff

Der Diff (`de4ecb13`) deckt sich mit dem in §3 „Plan-Ausgabe" dokumentierten Vorgehen: eigene
Funktion `form_matched()` statt Inline-Härtung (im Plan als zulässige Implementer-Entscheidung
vorgesehen), Here-String-Form analog Zeile 1280–1283, ein neuer Mutations-Fall statt Erweiterung
eines bestehenden. Keine Abweichung zwischen Plan-Zusage und Code gefunden, die nicht bereits im
Plan selbst als Freiheitsgrad vorgesehen war. Kein Gebautes-aber-nicht-Geplantes gefunden (Diff
begrenzt sich auf die drei im Plan §3 genannten Dateien plus den Ruhe-Marker-Fix in `roadmap.md`,
der als Nebeneffekt des `slice-mv`-Timings entstand und vom Reviewer bereits als F-3 eingeordnet
ist — kein Verifier-Befund zusätzlich dazu).

## Übergabe an den Planner

**DoD erfüllt: ja**, mit einer Einschränkung (siehe „`make gates`"-Abschnitt) und einer Empfehlung
zur Risiko-Zuweisung (siehe oben). Kein Punkt in diesem Bericht ist merge- oder closure-blockierend
im Sinne einer Korrektheitslücke; die eine Einschränkung betrifft ausschließlich die Reihenfolge
der nächsten Schritte (Stempel-Aktualität vor dem `git mv` nach `done/` prüfen, wegen
nebenläufiger, themenfremder Schreibarbeit im selben Baum).

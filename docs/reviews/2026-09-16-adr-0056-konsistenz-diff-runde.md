# Review-Report: Diff-Runde zu `ADR-0056` — 2026-09-16

**Review-Art:** Dritte Konsistenzrunde, eng begrenzt auf die Behebung der Befunde der
Bestätigungsrunde (Beleg-Kennung `2026-09-16-adr-0056-konsistenz-bestaetigung`). Sie läuft auf
Entscheidung des Auftraggebers und nicht auf einen blockierenden Befund hin. Maßstab sind
[`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegungen 1 und 2,
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md),
[`AGENTS.md`](../../AGENTS.md) §3.7/§3.8/§3.11,
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
und `ADR-0052` (kein Host-Pfad). **Nicht Teil dieser Runde:** die Messungen der Vorrunden, die der
Diff nicht berührt, das Verdikt über die Wahl von `v6.9.0`, die Setzungen des Auftraggebers
(Übernahme-Vorgabe und ihre Reichweite) und der Accept-Übergang.

**Gegenstand:** `git diff 98908f51 2187ae22`, davon der Commit `2187ae22` (`Rolle Architect`,
`docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md` Blob `be3274e2..24696315`,
`harness/migration.md` Blob `08b28a71..642ae237`). Der zweite Commit der Range, `9a0f07d0`, ist der
Report der Bestätigungsrunde und nicht Gegenstand. `HEAD` war beim Start `2187ae22`, der Baum
sauber.

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ `0565f274` (2.0.0) ·
**Modell:** claude-opus-5 · **Datum:** 2026-09-16

**Kein Self-Review:** Dieser Lauf hat an keinem Artefakt der Range geschrieben. Die einzige Datei,
die er schreibt, ist dieser Report. Die Commit-Message von `2187ae22` ist Prüfgegenstand und
keine Quelle: Jede tragende Aussage unten ist selbst gemessen oder am Zielartefakt gelesen.

---

## Eigene Messungen

`K` ist der lokale Kurs-Klon (nur gelesen), `F` steht für `lab/regelwerk/modul-02-harness-bootstrap.md`,
`A` für die ADR-Datei.

```sh
P='/Eine Stichprobe gegen den Bestand/,/^#### Gate-Fragment/p'
diff <(git -C "$K" show v6.8.0:$F | sed -n "$P") <(git -C "$K" show v6.9.0:$F | sed -n "$P") | wc -l   # 0
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | sed -n "$P" | wc -l; done                          # 31 / 31
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | grep -n 'Eine Stichprobe gegen den Bestand' | cut -d: -f1; done
#   290 / 308 — je genau ein Treffer, der Bereich öffnet also nur einmal
for t in v6.8.0 v6.9.0; do git -C "$K" show $t:$F | grep -n '^#### Gate-Fragment' | cut -d: -f1; done   # 320 / 338
git -C "$K" diff -U0 v6.8.0..v6.9.0 -- $F | grep '^@@'     # @@ -282,3 +282,21 @@  → der Hunk liegt vor beiden Startzeilen
git -C "$K" show v6.9.0:$F | sed -n "$P"                   # Auswahlkriterium gelesen (Zitat unten)
git -C "$K" diff --numstat v6.8.0..v6.9.0 -- lab/regelwerk
#   1 1 README.md · 21 3 modul-02 · 96 5 modul-05 · 1 1 modul-06
git -C "$K" diff -U0 v6.8.0..v6.9.0 -- lab/regelwerk/README.md | grep -E '^[-+][^-+]'   # nur die **Stand:**-Zeile
grep -nE 'MR-039|\bneuen? Gegenst|Register-Zeile|bestehende[n]? Instanz|Stichprobe' "$A"
#   bestehende Instanz(en): 176, 178, 260, 309 · Register-Zeilen: 178, 260, 276, 309, 361 · „neue(n) Gegenst…": kein Treffer
grep -nE '/Development|/home/|/tmp/|~/' "$A"               # kein Treffer, Exit 1
git show --stat --format= 2187ae22                         # 2 files changed, 25 insertions(+), 21 deletions(-)
git log -1 --format=%B 2187ae22 | grep -nE '[0-9]'         # Zeile 15: „… in beiden Tags wortgleich (Diff 0) …"
```

---

## Urteil je Befund der Bestätigungsrunde

| Befund | Urteil | Belegstelle |
|---|---|---|
| **B-M-1** Trigger 3 greift auch im invarianten Fall | **behoben**; Rest siehe D-I-1 | `…v690.md:411-415` gegen `:163-169`, `:244-247` |
| **B-M-2** Stichprobe als dritter Durchgang ungezeigt | **behoben**; Rest siehe D-L-1 | `…v690.md:151-153`, `:159-180`, `:244-247`, `:259-261`, `:301-311` |
| **B-L-1** §6 enger als die Kopplung | **behoben** | `harness/migration.md:334-336` gegen `…v690.md:41-46`, `:349-351` |
| **B-L-2** Bezug des Folgesatzes in §5 | **behoben** | `harness/migration.md:205` |
| **B-L-3** Zahl ohne Kommando | **behoben**; Rest siehe D-I-2 | `…v690.md:199` |
| **B-L-4** „neue" im einfrierenden Text | **behoben** | `…v690.md:299` |
| **I-2** (erste Runde), Begründung jetzt in der Message | **trägt** | `harness/migration.md` §1 *Prozedur ≠ Ist-Maßstab*, §5 a letzter Absatz |

**B-M-1.** Der neue Hauptsatz (*„ein Schritt, eine Frage oder eine Einordnung, die allein der
Prozedur-Text von `v6.9.0` verlangt“*) ist die Verneinung von Grund 1 (*„dieselben Fragen an
dieselben Gegenstände“*). Der Trigger greift also genau dann, wenn Grund 1 wegfällt. Der
Ausschluss gilt nur für einen Ausgang, den die Klausel *„als Teil des geprüften Deltas“* trägt, und
das ist der Fall, den `:163-169` für jede Fassung gleich erklärt. Einen Ausgang, den die Klausel als
**Prozedur-Text** bestimmt, schließt der Wortlaut nicht aus. Ein echter Prozedur-Unterschied an
einem `MR`-Eintrag bleibt damit ein Auslöser.

**B-M-2.**
- **Die Messung trägt.** Der Bereich `P` öffnet in jedem Tag genau einmal, bei 290 bzw. 308, und
  schließt am nächsten Abschnitt bei 320 bzw. 338. Der einzige Hunk beginnt bei 282, also vor
  beiden Startzeilen. Diff 0 über je 31 Zeilen belegt deshalb einen wortgleichen Text und nicht
  einen Bereich, der den Hunk verschluckt.
- **Die Aussage „zieht nur Abschnitte ohne Delta“ trägt am Wortlaut:** *„**Auswahlkriterium:** aus
  den Baseline-Abschnitten ziehen, die seit dem adoptierten `<tag>` **kein Delta** hatten“*. Der
  Freshness-Audit-Abschnitt hat den Hunk und gehört damit nicht dazu.
- **Die Zuordnung passt zu `ADR-0018` Festlegung 2.** Dort ist die gepinnte Fassung *„für **jede
  Konformitäts-Frage** maßgeblich“*, bis der Baum getauscht ist. Eine Stichproben-Antwort, die an
  einer Klassen-Aussage hängt, ist eine solche Frage.
- **Die offene Stelle aus B-M-2 ist geschlossen.** Die Festlegung selbst (`:259-261`) bindet jetzt
  die Folgen *„für die Register-Zeilen und bestehenden Instanzen“* an den Tausch. Damit bindet sie
  den Durchgang und nicht mehr nur *„Stellen der ADR“*.
- **Die Zahl „drei Durchgänge“** folgt der Lesart von `ADR-0018` Festlegung 1 (Adaptions-Liste,
  Form-Vergleich, Stichprobe). Sie ist dort ausdrücklich als Lesart ausgewiesen und kein Messwert.

**B-L-3.** Das Zahlwort ist ersetzt. Stattdessen stehen die Dateinamen da, und das
`numstat`-Kommando gibt genau diese vier Dateien aus.

**I-2.** `harness/migration.md` §1 sagt: Bis der vendored Baum getauscht ist, *„bleibt die
gepinnte Fassung für **jede Konformitäts-Frage** maßgeblich, unabhängig davon, welche Fassung die
Prozedur des laufenden Sprungs stellt“*. Damit trägt §1 den Wirkungszeitpunkt. Der zitierte Satz
aus §5 a steht dort, wenn auch über einen Zeilenumbruch verteilt. Ein zweiter Zeitpunkt im Absatz
wäre eine zweite Fassung derselben Regel. Die Begründung trägt. Die Reichweite selbst ist eine
Setzung des Auftraggebers und nicht beurteilt.

---

## Neue Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| D-M-1 | MEDIUM | **Die Commit-Message von `2187ae22` nennt einen Messwert ohne sein Kommando:** *„ihr Abschnitt ist in beiden Tags wortgleich (Diff 0)“*. Das Kommando steht nur in der ADR (`:152-153`). Nach Setzung 1 trägt die Message es im Klartext, und ein Verweis ist dort keine Form. | `MR-051` Setzung 1 · `MR-025` Setzung 1 | `git log -1 --format=%B 2187ae22`, Zeile 15 | nein (kein Träger prüft Messwerte in Messages; der `commit-msg`-Träger prüft nur die Kennung) | `Zahl-Beleg außerhalb des Absatzes seines Kommandos` |
| D-L-1 | LOW | **Die Erweiterung auf „bestehende Instanzen“ steht an drei Stellen (`:178`, `:259-261`, `:309`), aber nicht in der Folgepflicht *„mit dem Tausch“*.** Diese nennt weiter nur die Register-Zeilen in §4 bis §6 (`:361-364`). Außerdem trägt nur `:178` den Zusatz *„von Vorlagen **ohne** Delta“*. | Maintainability | `docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md:178`, `:259-261`, `:309`, `:361-364` | ja: `grep -nE 'bestehende[n]? Instanz' <ADR>`; `sed -n '361,364p' <ADR>` | `Erweiterung einer Zuordnung nicht an allen Stellen der Datei gezogen` |
| D-I-1 | INFO | **Ob ein Ausgang an einem `MR`-Eintrag Trigger 3 auslöst, hängt davon ab, in welcher Rolle die Klausel ihn trägt: als Delta-Gegenstand oder als Prozedur-Text.** Beide Rollen hat derselbe Wortlaut. Ablesbar *„am Report des Durchgangs“* ist der Trigger deshalb nur, wenn der Report die Rolle nennt. | `ADR-0056` §Re-Evaluierungs-Trigger, §Fitness Function | `…v690.md:411-415`, `:401-402` | nein | `Trigger-Merkmal setzt eine Rollen-Angabe im beobachteten Report voraus` |
| D-I-2 | INFO | **Das Kommando in `:199` belegt für `README.md` eine geänderte Zeile (`1 1`), aber nicht, dass es die Stand-Zeile ist.** Das zeigt erst `diff -U0`, und diesen Aufruf führt die ADR nicht. | `MR-025` Setzung 1 (sinngemäß; kein Zahlwort betroffen) | `…v690.md:199` | ja: `git -C "$K" diff -U0 v6.8.0..v6.9.0 -- lab/regelwerk/README.md` | `Kommando deckt die Zeilenzahl, nicht die Identität der Zeile` |

**Warum D-M-1 MEDIUM ist.** Die Klasse ist in diesem Vorgang zum dritten Mal aufgetreten:
L-2 in der ersten Runde, B-L-3 in der Bestätigungsrunde und jetzt diese Stelle, ein anderer Träger
mit demselben Muster. Der Skill stuft *„Wiederholung eines Musters, das schon zweimal LOW war“* als
MEDIUM ein.

**Warum D-L-1 nicht höher ist.** Die drei Vorlagen, die die Klassen-Aussagen betreffen, haben kein
Delta. Keine ihrer bestehenden Instanzen bekommt mit dem Tausch eine neue Form. Für die Stichprobe
bindet die Festlegung den Durchgang bereits an `v6.8.0`. Es fehlt also keine Pflicht. Unklar ist
nur, wie weit die Zuordnung reicht.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `AGENTS.md` §3.7 in den geänderten Zeilen | **Geprüft, ohne Befund.** Die geänderten Zeilen enthalten weder eine Befund-Kennung noch einen Runden-Verweis noch eine Spur der Überarbeitung. §Geschichte ist unverändert. |
| `AGENTS.md` §3.11 | **Geprüft, ohne Befund.** Neu verlinkt ist nur `ADR-0018` (`:161`), eine ortsfeste ADR-Datei. `harness/migration.md` verlinkt nur ADR-Dateien. |
| `ADR-0052` | **Geprüft, ohne Befund.** Die ADR enthält keinen Host-Pfad (Exit 1). `K` ist in `:60` als Host-Voraussetzung eingeführt. |
| `MR-025` in den geänderten Zeilen der ADR | **Geprüft, ohne Befund**, abgesehen von D-I-2. „Diff 0“ steht in `:153` neben seinem Kommando. „drei Durchgänge“ ist die Lesart aus `ADR-0018` und kein Messwert. |
| `MR-033` | **Geprüft, ohne Befund.** Beide neuen Kommandos nennen `v6.8.0`/`v6.9.0`. *„in beiden Tags“* steht in einem Abschnitt, der beide Tags nennt. |
| `AGENTS.md` §3.8: Zuschnitt von `2187ae22` | **Geprüft, ohne Befund.** Der Commit berührt zwei Dateien: die ADR und `harness/migration.md`. Die zweite ist nach dem Kopplungs-Feld und `ADR-0024` eine Projektion des Architect-Originals. Die Message nennt die Rolle und `ADR-0056`. |
| Wahl, Setzungen, unberührter Text | **Nicht beurteilt**, auftragsgemäß. §Verglichene Alternativen und die Verbuchung der Vorgabe berührt der Diff nicht. |
| Rollen-Konflikt | **Keiner.** Alle Befunde der Bestätigungsrunde sind in der vom Befund gelassenen Richtung aufgelöst. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 neu (B-M-1 und B-M-2 behoben) |
| LOW | 1 neu (B-L-1 bis B-L-4 behoben) |
| INFO | 2 neu |

**Finding-Klassen dieses Laufs:**
`Zahl-Beleg außerhalb des Absatzes seines Kommandos` (drittes Auftreten: L-2, B-L-3, D-M-1) ·
`Erweiterung einer Zuordnung nicht an allen Stellen der Datei gezogen` ·
`Trigger-Merkmal setzt eine Rollen-Angabe im beobachteten Report voraus` ·
`Kommando deckt die Zeilenzahl, nicht die Identität der Zeile`

## Verdikt

**Annahmefähig ohne blockierenden Befund.** B-M-1, B-M-2 und B-L-1 bis B-L-4 sind behoben. Die
neue Stichproben-Messung trägt, und die Zuordnung zum Ist-Maßstab stimmt mit `ADR-0018`
Festlegung 2 überein. Der Diff führt keinen Befund ein, der die Wahl oder einen eingefrorenen Satz
falsch macht.

**D-M-1 blockiert die Annahme nicht.** Der Befund betrifft die Commit-Message und nicht den Text,
den §3.4 einfriert. MEDIUM heißt *„vor Merge zu klären“*; die Range ist noch nicht gepusht, und
nach `MR-051` ist eine Message nach dem Push nicht mehr änderbar. Ob die Klärung vor dem Push
geschieht und in welcher Form, entscheidet der Architect. Wird `2187ae22` umformuliert, ändern sich
sein Hash und die Hashes aller Commits darüber, auch der Commit dieses Reports. Die oben genannten
Blobs bleiben dabei gleich, und dieser Report deckt weiter denselben Inhalt. D-L-1 ist zu beheben
oder zu beantworten, verhindert die Annahme aber nicht.

**Reichweite des Belegs:** Dieser Report deckt nur den Diff `98908f51..2187ae22`, also die Blobs
`24696315` und `642ae237` gegenüber ihren Vorgängern. Den unveränderten Text deckt die
Bestätigungsrunde am Stand `98908f51`. Beleg-Kennung dieser Runde:
**`2026-09-16-adr-0056-konsistenz-diff-runde`**. Welche Reports die Accept-Zeile nennt,
entscheidet der annehmende Lauf (`ADR-0040` Festlegung 1).

**Nicht geprüft:**
- (a) Die Messungen der Vorrunden außerhalb des Diffs.
- (b) Der Wortlaut des Vorgaben-Zitats in `harness/migration.md` §5 a; der Diff berührt es nicht.
- (c) `make mutate`; für eine Prozess-ADR ohne Fitness Function trägt es nichts.

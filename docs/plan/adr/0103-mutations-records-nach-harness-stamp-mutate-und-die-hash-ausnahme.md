# ADR-0103: Mutations-Records ziehen nach `.harness/stamp/mutate/`, und der Working-Tree-Hash nimmt `.harness/stamp/**` aus

**Status:** Accepted

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Supersedes:** [`ADR-0102`](0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md)
(in vollem Umfang: Ergebnis-Form, Konsum-Reihenfolge lesen → committen → räumen,
Granularität je abgeschlossenem Lauf-Urteil und Namensform mit der vollen Slice-Kennung
bleiben unverändert; einziges Delta ist der Ablageort).

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(beide Hälften: die Records verfallen nicht, und der Hash zieht keine Fläche in seinen
Prüfgegenstand, die kein Gate urteilt),
[`ADR-0102`](0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md)
(die eingecheckte Beleg-Datei, deren Ablageort hier wechselt),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 3 (die Form der deklarierten Ausnahme obenauf auf einer Definition),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(der Gate-Nachweis-Stempel in `.harness/state/` — die andere Stempel-Klasse),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(das fail-closed-Muster der Ausnahmeliste),
[`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
(die Nennungs-Pflicht der Begründung neben einem Ausnahme-Eintrag)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Die Mutations-Records liegen außerhalb
jeder Spec-Stelle; `harness/sensors/mutate.md` §CI-Branch trägt die Form-Zeile.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

[`ADR-0102`](0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md)
hat die Ergebnis-Fassung eines Mutations-CI-Laufs zur eingecheckten Beleg-Datei
gemacht und sie unter den Review-Zeitdokumenten abgelegt — in der Prosa-Fassung
unter `docs/reviews/mutate/`. Zwei Eigenschaften dieses Ablageorts driften gegen
das, was die Records sind:

- **Sie sind keine Review-Reports.** `docs/reviews/**` ist das Verzeichnis der
  Zeitdokumente der Review-Rolle; seine Ausnahmen im Doc-Gate (`exempt-paths`)
  frieren den Stand eines Review-Laufs ein. Die Mutations-Records frieren nichts
  ein — je abgeschlossenem Lauf-Urteil kommt eine Datei hinzu, ein Zuwachs, kein
  Verlauf. Ihr Platz neben den Zeitdokumenten war die Namensform
  ([`MR-072`](../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form)),
  nicht eine übereinstimmende Lifecycle-Zusage.
- **Sie sind Stempel, nicht Doku.** Dieselbe Klasse wie der
  Gate-Nachweis-Stempel: nur dass dieser nicht committet wird
  (`.harness/state/`, gitignored, [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)),
  während die Records committete Lauf-Urteile sind.

Daran hängt der zweite Befund: Der Working-Tree-Hash
([`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh))
hasht jede getrackte und untracked Datei — auch die Records. Ein Record-Commit
bewegt ihn daher mit jedem Lauf, ohne dass ein Gate einen Prüfgegenstand
verliert: kein Gate-Machtbefund liegt unter diesem Baum. Der Fast-Pfad der Gates
([`harness/tools/gates-fast.sh`](../../../harness/tools/gates-fast.sh)) und der
Stop-Hook vergleichen denselben Hash — eine Fläche ohne Urteile darin ist eine
Fläche, die jedem Nachweis mitläuft.

## Entscheidung

Wir wählen: **Die Mutations-Records sind die zweite Stempel-Klasse und ziehen in
einen eigenen committeten Baum; der Working-Tree-Hash nimmt diesen Baum aus.**
Vier Festlegungen:

1. **Ablageort.** `.harness/stamp/mutate/<slice-kennung>-<sha8-des-geprüften-commits>-<form>.txt`
   — supersedes
   [`ADR-0102`](0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md)
   in vollem Umfang; die dortigen Festlegungen 2–4
   (Kopf-Pflichten inkl.
   [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form,
   Träger = der Konsum-Schritt mit der Reihenfolge lesen → committen → räumen,
   Retro-Belege mit Cut-off) bleiben unverändert in Kraft, nur der Ort wechselt.
   **Namens-Kontrast-Zeile:** Es gibt zwei Stempel-Klassen —
   `.harness/state/` ist der **nicht-committete** Baum-Hash-Stempel der
   record-gates (gitignored, [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)),
   `.harness/stamp/mutate/` trägt das **committete** Lauf-Urteil eines
   Mutations-CI-Laufs. Beide sind Ausgaben ihres Laufs, beide trägt kein Prüfgegenstand.
2. **Hash-Ausnahme.** [`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh)
   nimmt `.harness/stamp/` aus — eine **deklarierte Ausnahme obenauf** auf der
   ls-files-Menge, in der
   [ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 3-Form: an genau dieser Stelle deklariert, mit genanntem Grund,
   als Rest gezählt statt als Deckung. **Grund:** Records sind Ausgaben jedes
   Konsum-Laufs und Prüfgegenstand keines Gates; nichts, worüber geurteilt wird,
   liegt darunter. **Wirkung:** eine Änderung, die allein unter `.harness/stamp/`
   liegt, bewegt den Hash nicht — der Nachweis des letzten grünen Laufs deckt
   sie weiter, auch bei neuem HEAD (der Stop-Hook-Zweig „Hash gleich"). Der
   Fast-Pfad
   ([`harness/tools/gates-fast.sh`](../../../harness/tools/gates-fast.sh))
   erbt dieselbe Wirkung, er vergleicht denselben Hash. **Fail-closed**
   ([`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Form):
   die Ausnahme trägt eine explizite Liste der ausgenommenen Unterbäume; Inhalt
   unter `.harness/stamp/` außerhalb dieser Liste beendet den Hash-Lauf mit
   Meldung rot, statt ihn still zu hashten oder still auszunehmen — wächst die
   Liste, ist das der sichtbare Ort, wie bei
   `ISOLATION_KEY_EXEMPT` in
   [`harness/tools/mutate.sh`](../../../harness/tools/mutate.sh).
3. **Scan und gewanderte Adressen.** `.harness/stamp/**` geht in `scan.ignore`
   der [`.d-check.yml`](../../../.d-check.yml) (Begründung: Roh-Ergebniskörper
   der Mutations-CI-Läufe — kein Doku-Material), und die gewanderten Adressen
   gehen als Tombstones in `codepaths.ignore-refs` — genau die gelöschten
   Pfade, keine breite Liste, mit den Nennungs-Bäumen im Kommentar
   ([`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)-Form).
   Die Record-Dateien selbst sind `.txt` und tragen heute keinen Doku-Scan; die
   `scan.ignore`-Zeile schließt den Baum, nicht nur den heutigen Inhalt.
4. **Fitness Function.** Die Ausnahme wird gezeigt, nicht angenommen —
   ADR-0035-Beweisrichtung, hier angewendet:

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/working-tree-hash-abnahme.bats` | Ein Pfad unter der deklarierten Ausnahme bewegt den Hash nicht; der unveränderte Baum bleibt unverändert; ein Pfad unter `.harness/stamp/` außerhalb der Liste endet rot mit Meldung | `make test` (in `make gates`) |
| `test/mutations/791-working-tree-stamp-ausnahme-ohne-zaehne.sh` | Nimmt der Ausnahme-Prefix seine Zahn-Funktion, färbt der zweite bats-Fall über dem realen Skript rot | `make mutate` |

   **Was kein Wächter hält, und das gehört dazu:** ob die Ausnahme
   **berechtigt** ist — ob wirklich kein Gate unter `.harness/stamp/` urteilt —,
   ist ein Urteil, kein Testfall; die Begründung in Festlegung 2 trägt es.
   Ein zweiter Rest ist der **emittierte Baum**: das Ziel bezieht
   `tools/harness/working-tree-hash.sh` aus der Vorlage
   `internal/emit/templates/enforce/working-tree-hash.sh`, die dieses Konzept
   nicht trägt und unverändert bleibt — ein Adopter, der Records committet,
   hat seine Hash-Nabe dort nicht, und der Lauf hier misst allein diesen Repo-Baum.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — ADR-0102 unverändert (Records unter den Review-Zeitdokumenten) | Kein zweiter Ablageort, kein Hash-Griff | Namens-Lücke bleibt: Records sind keine Review-Reports, ihre Ausnahme im Doc-Gate reitet auf Regeln, die über Zeitdokumente urteilen; jeder Record-Commit bewegt den Hash und entwertet den Fast-Pfad, ohne einen Prüfgegenstand zu verlieren |
| B — Records committet lassen, Hash weiter über alles | Keine Ausnahme im Hash-Skript | Die Fläche ohne Urteil bleibt im Prüfgegenstand des Nachweises: ein Nachweis behauptet Deckung über Inhalten, über die kein Gate geurteilt hat ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer) |
| **C — eigener Stempel-Baum .harness/stamp/mutate/ und Hash-Ausnahme mit fail-closed-Liste (gewählt)** | Namens-Kontrast zu .harness/state/ ist sichtbar; die Hash-Nabe schrumpft auf die Fläche, über die Gates urteilen; die Ausnahme steht deklariert, begründet und fail-closed statt still | Zwei Bäume mehr in der Konfiguration; die gewanderten Adressen brauchen Tombstones |

## Konsequenzen

- Positiv: Die Records haben ihren ehrlichen Ort; der Nachweis über der Hash
  behauptet Deckung nur über der Fläche, über die Gates urteilen; eine
  Record-Änderung allein unter `.harness/stamp/` hält den Nachweis gültig.
- Negativ: Die Ausnahme ist ungewächtert in ihrer Berechtigung (oben benannt);
  die emittierte Vorlage des Hash-Skripts trägt das Konzept nicht (oben benannt).
- Folgepflicht: die Form-Zeile in
  [`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md) §CI-Branch
  nennt den neuen Ort; die `git mv`s der vier bestehenden Records landen als
  reine Move-Commits, die Kopf-Zeilen-Züge folgen getrennt
  ([`AGENTS.md`](../../../AGENTS.md) §3.3).
- Abgrenzung: kein zweiter Träger des Handoff-Gate-Zustands
  ([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md))
  — der Stempel in `.harness/state/` bleibt der einzige Nachweis-Mechanismus;
  die Ausnahme macht ihn nicht schwächer, sie nimmt die urteilsfreie Fläche aus
  seiner Vergleichsmenge.

## Re-Evaluierungs-Trigger

Permanent in der Form „gilt unbefristet" — bis eine dieser Bedingungen eintritt:

1. **Ein Gate urteilt unter `.harness/stamp/`** — dann deckt die Ausnahme einen
   Prüfgegenstand aus, sie ist zurückzunehmen; Folge-ADR mit `supersedes`.
2. **Der Treiber trägt die Form selbst** — ein `mutate`-Toolstand, der die
   Records auf `main` schreibt (wie ADR-0102 Trigger 1), verlagert auch hier;
   Folge-ADR mit `supersedes`.
3. **Eine Baseline- bzw. Upstream-Regel übernimmt den Lauf-Beleg** — dann ist
   die hier liegende Setzung gegen den neuen Wortlaut neu zu begründen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | Accepted; supersedes [`ADR-0102`](0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md) — Ablageort `.harness/stamp/mutate/` und Hash-Ausnahme `.harness/stamp/` | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| 2026-11-26 | Festlegung 4 abgelöst durch [ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md) — die Fall-Beleg-Zeile trägt die erste-bats-Fall-Fassung; der übrige Kern bleibt unverändert | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| 2026-11-26 | Die vier Supersedes-Verweis-Zeilen und die Prosa-Zeile `docs/reviews/mutate/` je [ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md) auf den Accept-Stand `075b84a4` zurück — der in-place Nachzug `c030e4c8` entfällt | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

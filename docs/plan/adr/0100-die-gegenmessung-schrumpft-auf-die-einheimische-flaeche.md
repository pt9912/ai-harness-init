# ADR-0100: Upstream testet das Werkzeug — die Gegenmessung eines d-check-Sprungs schrumpft auf die einheimische Fläche

**Status:** Accepted

**Datum:** 2026-11-25

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Digest und Pin-Kette bleiben die Reproduzierbarkeits-Zusage, unverändert),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4 (Wortlaut-Präzedenz für benannte Reste),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)
([`AGENTS.md`](../../../AGENTS.md) §3 — die Artefakte dieses Zugs gehören dem Architect),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
[`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Die Pin-Kette
([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
`TestDefaultDigest_MatchesCanonical`) und die Ordnungskanten des
[`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
bleiben von dieser Entscheidung unberührt; geändert wird nur die Bilanz-Methodik, die ein
d-check-Sprung verlangt ([`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
→ [`MR-094`](../../../harness/conventions.md#mr-094--die-gegenmessung-eines-d-check-sprungs-schrumpft-auf-die-einheimische-flaeche)).

---

## Kontext

[`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
verlangt für jeden d-check-Sprung eine Gegenmessung auf Nicht-Null-Basis: `git archive`-Kopie,
entwertete Marker mit Symlink-Schutz, je **aktivem** Modul eine Sonde, je Stufe Verteilungen über
Modul und Grund-Code. Der Sprung `v0.86.1 → v0.93.0`
([`slice-d-check-sprung-v0930`](../planning/done/slice-d-check-sprung-v0930.md), in `done/`)
hat sie das letzte Mal in voller Form gefahren — und der Auslöser-Trigger von [`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
(*„wenn ein Werkzeug dieses Repos die Messung fährt oder d-check je Befund das Modul
ausgibt"*) ist nicht eingetreten; die Ablösung setzt **heute** der Auftraggeber
(Mehrfach-Bestätigung, 2026-11-25), nicht ein Trigger.

**Die Beobachtung, die den Beschluss trägt: d-check testet das Werkzeug selbst upstream.** Die
Testsuite des Werkzeugs deckt Module und Prüfverhalten an der Quelle ab; eine lokale Sonde, die
dasselbe Verhalten über einer Kopie nachmisst, ist Redundanz gegen diese Suite. Was **nicht**
upstream gesehen wird, ist die einheimische Fläche — der Werkzeug-Lauf über **unseren** Eingaben:

1. **Unser Konfigurations-Input** — ein `make docs-check`-Lauf über der `.d-check.yml` dieses
   Repos, Befund 0. Er liegt ohnehin in `make gates`; als Bilanz-Zeile nennt ihn der Sprung,
   statt einen zweiten Lauf zu bauen.
2. **Unser Baum als Input** — die Baseline-Zeiger unter `.claude/rules/`
   (`git ls-files -s .claude/rules/ | grep -c "^120000"` → **7**; die drei repo-eigenen Zeiger derselben
   Zeile sind keine Baseline-Zeiger, [`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)). Upstream-Fixtures tragen keine solche Verzeichnis-Struktur; bricht ein Zeiger, meldet es kein Werkzeug-Test.
3. **Die Digest-Pin-Kopplung** — kein eigener Mechanismus: Der Digest ist an die Pin-Kette
   gekoppelt ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), deren
   Wächter ohnehin laufen.

## Entscheidung

Wir wählen: **Die Gegenmessung eines d-check-Sprungs besteht aus der einheimischen Fläche —
drei Zeilen je Sprung — und keinem weiteren Mechanismus.** Der Eintrag des Blocks ist
[`MR-094`](../../../harness/conventions.md#mr-094--die-gegenmessung-eines-d-check-sprungs-schrumpft-auf-die-einheimische-flaeche);
[`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
wird vollständig aufgelöst.

**1. Konfigurations-Input.** Ein `make docs-check`-Lauf über der `.d-check.yml` dieses Repos,
Befund 0, Exit 0 — gemessen an der gepinnten Fassung des Sprungs.

**2. Symlink-Smoke.** Eine Prüfezeile an der Baseline-Zeiger-Struktur, netzlos, fail-closed,
Träger ist der Lauf, der den Sprung bilanziert — kein `make`-Target, also kein Gate:

```sh
err=0
for sym in .claude/rules/*; do
  ziel=$(readlink -f "$sym") || { echo "$sym: Auflösung fehlgeschlagen"; err=1; continue; }
  case "$ziel" in
  */.harness/baseline/v6.18.1/*) test -f "$ziel" || { echo "$sym: Ziel unter der vendored Baseline fehlt: $ziel"; err=1; } ;;
  esac
done
exit $err   # → 0; die Baseline-Version in der Zeile wandert mit dem Baseline-Sprung mit
```

Der `case`-Träger bindet die Prüfung an den Zielprefix `.harness/baseline/v6.18.1/`: Ein Zeiger,
der nicht in die vendored Baseline aufgelöst ist, ist kein ihr unterliegendes Verhalten —
die repo-eigenen Zeiger derselben Verzeichnis-Struktur
([`MR-035`](../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl))
schweigen. Bricht ein Baseline-Zeiger — Ziel umbenannt oder gelöscht —, meldet die Zeile und
der Lauf endet nicht auf 0; gelangt dieselbe Umformulierung als reguläre Datei in den Baum
(das `sed`-i-Gefahr, der [`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen) Setzung 2 seinen Symlink-Schutz verdankt), schweigt die
Prefix-Zeile nicht: eine reguläre Datei löst nie in die Baseline auf und wird im
`case`-Zweig gemeldet.

**3. Pin-Kopplung.** Kein neuer Mechanismus: Der Digest ist an
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) gekoppelt, die
Pin-Wächter laufen ohnehin.

**Beleg-Träger je Sprung** ist künftig die Commit-Message
([`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)),
nicht eine Konventions-Notiz: Drei Zeilen bilanzieren drei Werte, die ohne Notiz lesbar sind.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — [`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen) unverändert fort | keine Änderung; Form ist erprobt ([`MR-092`](../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Messung) | Die Sonden messen Werkzeug-Verhalten, das die Werkzeug-Testsuite upstream ohnehin fährt — Redundanz an der Quelle; ihr Inventar wächst je neuem Modul, ohne einen lokalen Gegenstand zu messen, den nicht auch `docs-check` sähe |
| B — ganz löschen, keine Bilanz | minimaler Aufwand | der Symlink-Schutz ist einheimisch: kein Mechanismus fängt den Bruch eines Baseline-Zeigers; keine der drei einheimischen Symptomatiken hätte einen Träger, und ein Befund des Sprungs bliebe unbeobachtet |
| **C — einheimische Fläche (gewählt)** | kein je-Modul-Ritual, kein Sonden-Inventar; jede der drei Zeilen misst einen Gegenstand, den Upstream-Fixtures strukturell nicht sehen | der benannte Rest unten: wo Upstream das Verhalten eines Moduls gegen unsere Konfiguration testet, trägt kein lokaler Beweis mehr — der Rest hängt an einem Upstream-Beleg und ist hier nicht mechanisch fasst |

## Konsequenzen

- Positiv: Ein Sprung bilanziert drei einheimische Zeilen statt eines je-Modul-Sonden-Systems;
  die Form ist je Sprung gleich und hängt an keinem Modul-Inventar. Die Belege tragen
  Commit-Message ([`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))
  und die Übergabe der Slice-Datei — keine Konventions-Notiz mehr, kein zweiter Mechanismus.
- Negativ (benannter Rest, nach
  [ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4): Wo
  Upstream das Verhalten eines Moduls gegen **unsere** Konfiguration testet, misst lokal kein
  Beweis — [`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)-Sonden-Form
  trug das als Fassung, hier tritt sie ab. Der Rest steht nicht in einem Mechanismus, sondern in
  der Aussage dieser ADR, mit Trigger unten.
- Der Sprung [`slice-d-check-sprung-v0930`](../planning/done/slice-d-check-sprung-v0930.md)
  bleibt, wie er geschlossen ist: Seine Setzungen F-1/F-2 (Summen-Form statt je-Modul-Bilanz,
  keine Kopie-Integritäts-Zeile) gelten für **Zukunfts**-Fassungen als die hier beschlossene
  Form — er wird nicht nachgearbeitet.
- Folge-Schärfe: Ein neu **aktiviertes** Modul — eine Stufe der
  [`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) — braucht keine Sonden-Zeile mehr; sein
  einheimisches Verhalten fährt `make docs-check` ohnehin, und das Aktivieren bleibt
  ein eigener Vorgang mit eigener ADR.

## Fitness Function

| Regel | Werkzeug / Trigger | Anmerkung |
|---|---|---|
| `docs-check` färbt bei Konfigurations-Bruch | [`make docs-check`](../../../harness/sensors/docs-check.md), in `make gates` | Exit 0 am gesunden Bestand; Bruch der `.d-check.yml`-Deklarationen färbt — bereits der laufende Sensor, kein Neubau |
| Symlink-Smoke Setzung 2: Exit 0; Baseline-Zeiger, der nicht oder nicht in die Baseline auflöst → Meldung, Exit 1 | Bilanz-Lauf je d-check-Sprung (Rückwärts-Nachweis: einmal Ziel umbenennen, Zeile fällt auf Exit 1; danach zurücknehmen) | kein `make`-Target — bewusst: der Smoke misst einen Punkt an, kein Bestand ([Modul 13](../../../.harness/baseline/v7.0.0/regelwerk/modul-13-quality-gates.md) §Die dritte Lage) |
| Pin-Kopplung | `TestDefaultDigest_MatchesCanonical` o. dgl. | bereits Wächter der Pin-Kette, hier nur Zeile der Bilanz |

**Lücke (benannt):** Dass die einheimische Fläche *strukturell* die Upstream-Fixtures nicht
sieht, ist keine Messung — es ist die Aussage dieser ADR; ein Wächter gegen den Upstream-Test-
Nachweis existiert nicht und ist hier nicht baubar (Upstream-Lauf, kein Repo-Zustand). Träger
ist der Re-Evaluierungs-Trigger unten.

## Re-Evaluierungs-Trigger

Trigger 1 — *aufgelöst*: Werkzeug testet das Werkzeug selbst upstream (2026-11-25, Beschluss des
Auftraggebers). Nicht permanent in der Form *„gilt unbefristet"*, sondern an zwei Bedingungen
gekoppelt, jede einzeln auslösend:

1. **Ein Upstream-Tests-Nachweis übernimmt die einheimische Fläche** — die Testsuite des
   Werkzeugs stellt ein Konfigurations-Fixture bereit, das die `.d-check.yml`-Eingabe eines
   Adopters (und mit ihm die Baseline-Zeiger-Struktur) strukturell prüft; dann entfallen
   Setzungen 1 und 2 als lokale Zeilen, [`MR-094`](../../../harness/conventions.md#mr-094--die-gegenmessung-eines-d-check-sprungs-schrumpft-auf-die-einheimische-flaeche)
   schrumpft auf die Pin-Kopplung — Folge-ADR mit `supersedes`.
2. **Ein Modul verhält sich gegen die einheimische Fläche struktur-unterschiedlich** — falls
   ein Sprung zeigt, dass die drei Zeilen (`docs-check`, Symlink-Smoke, Pin-Kopplung) eine
   lokale Symptomatik nicht ausdrücken, die die [`MR-063`](../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
   Sonden-Form gesehen hätte: der Eintrag wird zurückgenommen
   ([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft))
   und die Form neu entschieden (Folge-ADR mit `supersedes`), nicht die Sonden still reaktiviert.

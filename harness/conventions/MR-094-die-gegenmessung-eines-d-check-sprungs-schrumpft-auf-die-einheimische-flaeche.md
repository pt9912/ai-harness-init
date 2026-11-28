# MR-094 — Die Gegenmessung eines d-check-Sprungs schrumpft auf die einheimische Fläche

- **Datum:** 2026-11-25
- **Wirksamkeits-Anlass:** Auftraggeber-Entscheidung 2026-11-25 (keine Slice-Kennung — Architect-Zug,
  [`AGENTS.md`](../../AGENTS.md) §3.8); letzter Sprung unter der aufgelösten Form:
  [`slice-d-check-sprung-v0930`](../../docs/plan/planning/done/altbestand/slice-d-check-sprung-v0930.md),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Geltungsbereich:** die **Bilanz eines d-check-Sprungs** — das, was ein Sprung von
  `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`) und dem emittierten Default-Pin
  (`internal/emit/emit.go`) an Belegen verlangt. **Nicht** der Pin selbst, sein Digest und die
  Quell-Differenz — die Pin-Kette gilt fort
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); **nicht** die emittierte
  Ebene.
- **Löst auf:** [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  **vollständig** — die Gegenmessung auf Nicht-Null-Basis mit je-Modul-Sonden, die Stufen-Tabelle,
  die Verteilung je Grund-Code, die Kopie-Integritäts-Bedingung samt Symlink-Schutz und der
  Schluss als Gate-Aussage (kein ADR nach
  [`AGENTS.md`](../../AGENTS.md) §3.5) entfallen als Form künftiger Sprünge. Sein eigener
  [`Auflösungs-Trigger`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  trat nicht ein; die Ablösung ist eine Auftrags-Entscheidung
  (`ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: die Setzungen stehen unverändert in der Teil-supersededten ADR-0100, ADR-0101 Supersedes-Feld) -->),
  kein Trigger-Artefakt.
- **Ausgelöst durch Baseline-Stand:** keiner — dieselbe Lage wie
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  und [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff).
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  selbst: Die Baseline kennt keine Gegenmessung für einen Pin-Sprung, und dieser Fork legt fest,
  **dass** es keine mehr braucht.
- **Adaption — die einheimische Fläche, drei Zeilen je Sprung.** Ein d-check-Sprung bilanziert
  seine Einheit über die Fläche, die Upstream-Fixtures strukturell nicht sehen:
  1. **Unser Konfigurations-Input** — ein `make docs-check`-Lauf über der `.d-check.yml` dieses
     Repos, Befund 0; er liegt ohnehin in `make gates`, ein zweiter Lauf wird nicht gebaut.
  2. **Unser Baum als Input** — ein Symlink-Smoke an den Baseline-Zeigern von `.claude/rules/`,
     netzlos, fail-closed, ein Kommando:

     ```sh
     err=0
     for sym in .claude/rules/*; do
       ziel=$(readlink -f "$sym") || { echo "$sym: Auflösung fehlgeschlagen"; err=1; continue; }
       case "$ziel" in
       */.harness/baseline/v6.18.1/*) test -f "$ziel" || { echo "$sym: Ziel unter der vendored Baseline fehlt: $ziel"; err=1; } ;;
       esac
     done
     exit $err   # → 0; die Baseline-Form der Zeile wandert mit dem Baseline-Sprung mit
     ```

     Der `case`-Zweig bindet die Prüfung an den Zielprefix `.harness/baseline/v6.18.1/`: Bricht
     ein Baseline-Zeiger (Ziel umbenannt oder gelöscht) oder wurde er durch eine reguläre Datei
     ersetzt, meldet die Zeile und der Lauf endet nicht auf 0; die drei repo-eigenen Zeiger des
     Verzeichnisses ([`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl))
     lösen nie in die Baseline auf und schweigen. **Die Baseline-Form der Zeile ist kein
     Erwartungswert** und wandert mit dem Baseline-Sprung mit (dort gemessen, nicht hier).
  3. **Die Digest-Pin-Kopplung** — kein neuer Mechanismus; der Digest ist an
     [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) gekoppelt, seine Wächter
     laufen ohnehin — Zeile der Bilanz, keine Arbeit je Sprung.
- **Beleg-Träger je Sprung:** die Commit-Message
  ([`MR-051`](../conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))
  — drei Werte, die ohne Konventions-Notiz lesbar sind; die Übergabe der Slice-Datei trägt sie
  daneben wie zuvor.
- **Grenze.** Wo Upstream das Verhalten eines Moduls gegen **unsere** Konfiguration testet, misst
  lokal kein Beweis — die Sonden-Form von `MR-063` trug das als Fassung, hier entfällt sie. Der
  Rest hängt an einem Upstream-Beleg und ist hier nicht mechanisch fassbar; den Nachweis, dass das
  Werkzeug upstream testet, liest der Lauf aus der Werkzeug-Suiten-Lage am Sprung, und die
  Re-Evaluierungs-Bedingungen von `ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: die Setzungen stehen unverändert in der Teil-supersededten ADR-0100, ADR-0101 Supersedes-Feld) -->
  fangen den Fall, dass ein Modul gegen die einheimische Fläche struktur-unterschiedlich bleibt.
  Kein `make`-Target trägt den Symlink-Smoke — bewusst: der Smoke misst einen Punkt am Sprung,
  kein Bestand. **Ein Wächter für die Bilanz selbst existiert nicht:** Träger ist der Lauf, der
  den Sprung bilanziert.
- **Begründung.** d-check testet das Werkzeug selbst upstream; die je-Modul-Sonden missten
  Werkzeug-Verhalten, das die Werkzeug-Testsuite an der Quelle fährt, und ihr Inventar wuchs mit
  jedem Modul. `ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: die Setzungen stehen unverändert in der Teil-supersededten ADR-0100, ADR-0101 Supersedes-Feld) -->
  trägt die Abwägung.
- **Auflösungs-Trigger:** permanent bis ein Upstream-Tests-Nachweis die einheimische Fläche
  übernimmt (Bedingung 1 von `ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: die Setzungen stehen unverändert in der Teil-supersededten ADR-0100, ADR-0101 Supersedes-Feld) -->);
  fängt ein Modul gegen die einheimische Fläche struktur-unterschiedlich zu bleiben
  (Bedingung 2), tritt die Form zur Neuentscheidung — Folge-ADR mit `supersedes`.

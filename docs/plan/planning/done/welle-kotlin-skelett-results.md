# Welle welle-kotlin-skelett — Kotlin als drittes Sprachskelett — Closure-Notiz

> **Zitier-Form** *(bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieses
> Artefakt friert ein; was es zitiert, bewegt sich weiter. Deshalb: **Kennung,
> nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>`
> statt eines Links auf die Sensor-Datei, eine Baseline-Stelle als
> `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link
> (Baseline-Regelwerk `grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — beim Ausfüllen mit dem adoptierten Tag schreiben).

**Welle:** welle-kotlin-skelett
**Abschluss:** 2026-10-09
**Verantwortlich:** pt9912

## Was wurde geliefert?

- Kotlin ist ein Sprachskelett wie Go und C++
  ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
  [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)):
  flaches JVM-Gradle-Skelett mit Code-Gate und Guard
  ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)):
  `slice-kotlin-flaches-skelett`; hexslice mit emittiertem Arch-Gate und `core-impurity`-Zahn
  ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)):
  `slice-kotlin-hexslice-mit-arch-gate`; One-Shot am Root
  ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)):
  `slice-kotlin-root-bootstrap`; `freshness-kotlin` meldet einen neueren Gradle-Image-Tag
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): `slice-kotlin-freshness`.
- Das *Mehr*: `make full-smoke` trägt alle Kotlin-Stufen zugleich neben Go und C++, `make gates` grün
  auf demselben Commit (§Verifikation).

## Was hat funktioniert?

- Die Binnen-Kanten aus §5 des Welle-Plans hielten: jeder Slice startete auf dem Baum seines
  Vorgängers, keiner wartete auf einen späteren.
- Das rote Gegenbeispiel (`core-impurity`) steht als Stufe im E2E und nicht nur im Slice-Bericht —
  Subdir und Root nennen dieselbe Fundstelle, der Verifier las die Meldung.

## Was ging anders als geplant?

- **Schritt 4 nicht ausgeführt:** kein `done/*/archiv.zip`, `[untergrenze]` sperrt fail-closed wie bei
  den vier Vorgänger-Wellen. Die Vorschau sperrt nicht sofort, sie rechnet: `ZaehlePraefix` kompiliert
  je Aufruf neu, 3545 Dateien × 203 bewegte Namen — Register-Eintrag
  `BEO-ALL/archiv-vorschau-rechnet-im-produkt-aus-dateien-und-bewegten-namen` (1 Beleg).
- **[ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) Trigger 2 eingetreten, bestätigt:** der Fund liegt in den Spec-Straten, die
  [ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)
  ausnimmt; Träger ist `slice-151`, keine Folge-ADR.
- **Offen aus einem Review:** `test-kotlin` am gemischten Root baut das Go-`Dockerfile` (MEDIUM-2 aus
  einem Slice-Review, im Slice nicht behoben) — Register
  `BEO-ALL/emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` (1 Beleg).
- **Bestands-Lese-Schritt — Vorschläge an den Auftraggeber,** nichts stillgelegt, kein Slice-Zustand
  geändert:
  - `slice-151-spec-straten-haben-eine-schreibende-rolle` bestätigt, Priorität hoch (Träger für
    [ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) Trigger 2 und für `spec-zeile-enger-…`).
  - `slice-181-grenzen-liste-vollstaendig-oder-fail-closed`,
    `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`,
    `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` bestätigt.
  - Mutations-Gruppe prüfen, Konsolidierungs-Kandidat: `slice-069-zahn-bindet-zusicherung`,
    `slice-119-zusage-ohne-fall-wird-sichtbar`, `slice-sync-waechter-tragen-mutations-faelle`,
    `slice-pin-kopplung-bekommt-ihren-mutations-fall`, `slice-der-mutations-lauf-ist-begrenzbar`,
    `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`.
  - Spezifikations-Gruppe: prüfen, ob `slice-hook-festlegungen-ziehen-in-die-spezifikation` und
    `slice-festlegungen-waechter-und-hooks-ziehen-in-die-spezifikation` denselben Gegenstand tragen;
    die übrigen `slice-festlegungen-*` bestätigt.
  - `slice-113-co-001-ist-faellig` / `slice-141-co-001-aufloesung-ist-vorher-entschieden` bestätigt
    (`CO-001` *Auflösung fällig*).
  - Folge-Slice für `emittiertes-gate-am-gemischten-root-…`?
    ([ADR-0076](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md)
    Festlegung 7, Auslöser 2).

## Steering-Loop-Einträge

Kein Eintrag erreicht im Fenster erstmals 3×; kein Zielort-Feld. Wiederauftreten nach Verkörperung
(4×-Regel, Architect-Verdikt `docs/reviews/2026-10-09-welle-kotlin-skelett-architect-verdikt.md`):

- **Sensor benannt, Slice geschnitten:** `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`
  (10 Belege, 6 nach `seit welle-15`). Abschnitts-Wächter über die Rolle im Commit-Subject, Werkzeug
  über `RANGE=<claim>..HEAD`, fasst 9 von 10 Belegen. Ausgang wechselt auf *geplant*:
  `slice-rollen-grenze-eines-commits-hat-ein-werkzeug` (Auftraggeber: Option A).
- **Kein Sensor angemessen, neue Begründung:** `BEO-ALL/plan-abweichung-landet-im-commit-bericht-statt-im-plan`
  — §3-Spalte 1 hat keine geschlossene Pfad-Form; Träger Plan-vs-Code-Diff des Verifiers.
- **Kein Sensor möglich, Begründung unverändert oder auf die Unterklasse erweitert:**
  `BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` (Bedingung 4 des Treibers
  hält die Nennung), `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`
  (Unterklasse Stufen-Kurzbeschreibung, Bedeutungsvergleich).
- **Geplanter Träger, Unterklasse ohne eigenen Ausgang:**
  `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` (Fremd-Werkzeug-Verhalten; Halter ist
  die `full-smoke`-Stufe in CI).
- **ADR-Zählregel:** `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` —
  für Trigger 2 von [ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) zählen nur Belege im Residuum von Festlegung 1.

## Beobachtungs-Register (Zeiger)

- Ablage: [`../observations/`](../observations/README.md). Lese-Schritt: `make register-ausgang` →
  `237 Eintraege, 67 ueber der Schwelle, 0 Befund(e)` (vor dem Self-Close-Commit). Neu angelegt:
  `BEO-ALL/archiv-vorschau-rechnet-im-produkt-aus-dateien-und-bewegten-namen` (Beleg
  `2026-10-09-welle-kotlin-skelett-audit-vorlage`). `state.md` ergänzt nach dem Architect-Verdikt:
  die sechs Einträge aus §Steering-Loop-Einträge.
- **Paarungen nach dem Move, 2026-10-09:** (a) diese Notiz trägt kein Zielort-Feld; im Fenster seit `d82ac7be` trägt eines allein `slice-kotlin-flaches-skelett`, Zielort [`MR-089`](../../../../harness/conventions.md#mr-089) existiert und trägt `seit slice-kotlin-flaches-skelett` (`grep -l`). (b) jeder genannte Slice existiert genau einmal im Lifecycle (`ls docs/plan/planning/{open,next,in-progress,done}/<kennung>*.md`), `slice-rollen-grenze-eines-commits-hat-ein-werkzeug` in `open/`. (c) erste Hälfte: jede genannte `BEO-ALL/<slug>` existiert mit 1–13 Belegen. Register-Paarung (c), zweite Hälfte: 2 Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`). `make register-ausgang` → `237 Eintraege, 67 ueber der Schwelle, 0 Befund(e)`.

## Folge-Slices

- Neu in `open/`: `slice-rollen-grenze-eines-commits-hat-ein-werkzeug` (Sensor B-4, Auftraggeber-Entscheidung
  Option A vom 2026-10-09). Die übrigen *geplant*-Ausgänge tragen `slice-181-grenzen-liste-vollstaendig-oder-fail-closed`,
  `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` und
  `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`; [ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) Trigger 2 trägt
  `slice-151-spec-straten-haben-eine-schreibende-rolle`.
- **Offen beim Auftraggeber:** Folge-Slice für das gemischte-Root-Gate; ein Slice
  entsteht erst nach der Entscheidung.

## Verifikation

- Schritt 1: Verifier-Beleg `docs/reviews/2026-10-09-welle-kotlin-skelett-trigger.md` auf
  `11b35f68` — die vier Slices in `done/`; `make gates` Exit 0 (191 s); `make full-smoke` Exit 0
  (256 s, warm) mit den Kotlin-Stufen flat, gemischter Root, hexslice und Root samt
  `core-impurity`-Gegenbeispiel (`Greeting.kt:4`). Ein Replay-Set führt dieses Repo nicht.
- Schritt 2: `CO-001` *Auflösung fällig* mit Folge-Slices `slice-113`, `slice-141`; `CO-002`
  permanent; kein bootstrap-aware Gate (Audit-Vorlage
  `docs/reviews/2026-10-09-welle-kotlin-skelett-audit-vorlage.md`). [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md), [ADR-0089](../../adr/0089-span-dateien-sind-nur-fuer-den-eigentuemer-lesbar.md), [ADR-0063](../../adr/0063-das-werkzeug-sagt-seine-fassung.md),
  [`MR-089`](../../../../harness/conventions.md#mr-089) ohne eingetretenen Trigger; [ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) Trigger 2 bestätigt, keine Folge-ADR
  (Architect-Verdikt `docs/reviews/2026-10-09-welle-kotlin-skelett-architect-verdikt.md`).

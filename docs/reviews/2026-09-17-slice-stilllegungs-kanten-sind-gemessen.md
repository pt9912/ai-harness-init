# Review `slice-stilllegungs-kanten-sind-gemessen` — 0 HIGH · 2 MEDIUM · 3 LOW · 2 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `b97bc8e1` (Umsetzung, Basis
`5655d3a0`, 3 Dateien, +109), dazu der Claim `cbb49bf2` und der Planner-Commit `5655d3a0` ·
**Review-Art:** Code-Review gegen Plan, Konventionen und Hard Rules (`v6.9.0` ·
`regelwerk/modul-10-review-harness.md`) · **Nicht Gegenstand:** die DoD-Abhakung, denn die prüft
die Verifikation (`v6.9.0` · `regelwerk/modul-11-verification.md`).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` (`1b643a87`) · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Slice-Plan `slice-stilllegungs-kanten-sind-gemessen`: §1 Ziel und Abgrenzung, §2 DoD, §3 Plan,
  §6 Risiken, §8.
- `ADR-0056` (§Was diese Festlegung nicht tut) und `LH-QA-01`.
- Maßstab `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein
  anderer übernimmt.
- `v6.9.0` · `templates/harness/sensors/gate.template.md`, für die Pflichtgliederung.
- `AGENTS.md` §3.1, §3.6, §3.7, §3.9, §3.10 und §3.11; dazu `MR-025`, `MR-033` und `MR-051`.
- Die Setzungen des Auftraggebers:
  - Pflichtgliederung: `##` genau wie in der Vorlage, eigener Stoff als `###`.
  - Ein wörtlicher Umzug nur innerhalb derselben Datei.
  - Exit-Aussagen trennen Skript und `make`; `make` endet bei jedem Fehlschlag mit 2.
- Frühere Reports zu `make slice-mv` und `make docs-check` in `docs/reviews/`, gesichtet über den
  Dateinamen.

---

## Eigene Messung

Die Angaben des Implementers sind nicht übernommen. Nachgemessen ist an einer eigenen
Wegwerf-Kopie außerhalb des Repos (`git archive HEAD` am Stand `61be4d3a`, dann `git init` mit
lokal gesetzter Identität, kein `core.hooksPath`). Gemessen ist gegen d-check
`@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`; das ist der Wert von
`DCHECK_DIGEST` in `d-check.mk`. Gemessen ist die Kante **`next → done`**, mit Absicht die
andere als die, an der der Implementer die dritte Grenze beschreibt. Der Geber ist
`slice-103-traeger-waechter-decken-was-sie-sagen`: `slice-108-feldlisten-waechter-tragen-ihren-fall`
verweist zweimal präfixlos auf ihn, `slice-110-erfassungs-waechter-fall-meldung-grenze` einmal.
Vor dem Wechsel ist in §7 eine Zeile `Gegenstand:` committet.

| Lage | Kommando | Ergebnis |
|---|---|---|
| Ausgangsstand der Kopie | `make docs-check` | Exit 0, `1524 Datei(en) geprüft, 0 Befund(e)` |
| Kante über das Werkzeug | `make slice-mv SLICE=… TO=done; echo $?` | `0`; `eingehend: 4 Datei(en)`, `ausgehend: 0` |
| Move-Commit | `git show --numstat --format= -M HEAD~1` | `0	0	docs/plan/planning/{next => done}/…` |
| nach dem Werkzeug | `make docs-check` | make-Exit 2 (`d-check.mk:79 … Fehler 1`), **3 × `target-missing`**: `slice-108-…` Z. 114 und 193, `slice-110-…` Z. 63, Ziel jeweils der blanke Dateiname |
| Gegenbeispiel: `Gegenstand:` gelöscht | `make docs-check` | dieselben 3 Befunde, **keiner** zum stillgelegten Slice |
| Gegenbeispiel: §7 auf einen Satz | `make docs-check` | zusätzlich `closure-note-thin` auf der §7-Überschrift (Z. 184) |
| Gegenbeispiel: bloßer `git mv` statt Werkzeug (zweite Kopie) | `make docs-check` | make-Exit 2, **13 × `target-missing`**: 10 Präfix-Formen (`done/**`, `open/`) und die 3 präfixlosen aus `next/` |
| Umfang der Grenze am Arbeitsstand | Zählschleife aus `harness/sensors/slice-mv.md` Z. 112–116 | `open: 56`, `next: 8`; Selbstverweise darunter: 0 (eigene Erweiterung der Schleife) |
| Konfigurations-Vorlage des gepinnten Stands | `docker run --rm --network none ghcr.io/pt9912/d-check@<digest> --print-config` | Block `structure`: `require-pattern`, `require-all` und `max-open-tasks` gelten je Abschnitt ohne Bedingung; eine Regel, die eine Zeile an eine Bedingung in einem anderen Abschnitt knüpft, führt die Vorlage nicht |

Die Lagen D und E (Platzhalter bei ausgeschaltetem bzw. eingeschaltetem `placeholder`) sind nicht
nachgemessen. B (erfundene Kennung) und G (abgehakter Liefer-Punkt) ebenfalls nicht.

## Findings

Schema: `.harness/skills/reviewer.md` §Output-Schema (`v6.9.0` ·
`regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Datei bindet die Grenze „präfixlose Verweise aus unbewegten Geschwistern" an die Kante `open → done`, und die Zeile `next → done` meldet „ebenso". Die eigene Messung zeigt dieselbe Grenze an `next → done`: nach dem Werkzeug bleiben 3 × `target-missing` aus `next/`. Die Zählschleife der Datei nennt selbst `next: 8`. | `AGENTS.md` §3.6 (die Aussage reicht so weit wie die Messung) · Maintainability | `harness/sensors/slice-mv.md:107`, dazu `:99` und `harness/sensors/docs-check.md:186` („in `open/`") | ja: `make slice-mv SLICE=slice-103-… TO=done`, dann `make docs-check` an einer Kopie | Stellen-Messung als Kanten-Eigenschaft ausgegeben |
| F-2 | MEDIUM | §3 knüpfte an eine Zusage in einer Sensor-Datei, dass der Umsetzungs-Lauf ihren Wächter ergänzt (Z. 152–154). Die Verfeinerung erklärt den Text im ausführenden Kontext zur Messung und legt den Wächter unter Verweis auf §1 in einen „eigenen Vorgang am Werkzeug". §1 schließt aber nur die „Behebung einer gefundenen Lücke" aus (Z. 73), und für den Wächter nennt die Verfeinerung keine Adresse. | Slice-Plan §1/§3; berührt die Grenze aus `AGENTS.md` §3.10 (Übergabe statt Umschrift) | `slice-stilllegungs-kanten-sind-gemessen` §3, Z. 156–164 | nein: kein Modul liest Plan-Bedingungen | Plan-Bedingung im ausführenden Kontext umgedeutet |
| F-3 | LOW | Die Messtabelle nennt keinen Stand des gemessenen Werkzeugs, die Schwester-Datei nennt ihren Digest. Ob „wer `harness/tools/slice-mv.sh` ändert, misst sie neu" eingehalten ist, kann ein Leser darum nicht prüfen. Der Folge-Slice `slice-mv-zieht-praefixlose-geschwister-verweise-nach` ändert genau dieses Skript. | Maintainability (dieselbe Überlegung wie `MR-033`/`MR-053`; deren Geltungsbereich erfasst die Datei nicht) | `harness/sensors/slice-mv.md:85-99` | nein | Messung ohne Stand des gemessenen Werkzeugs |
| F-4 | LOW | Das Rezept setzt eine globale git-Identität voraus, ohne sie zu nennen. Auf dem Review-Host endet `git commit -qm basis` mit `fatal`; der folgende `make slice-mv` hält an der Sperre „Arbeitsbaum nicht sauber" (make-Exit 2). Der Abbruch ist laut, nicht still. | Maintainability | `harness/sensors/slice-mv.md:90` | ja: das Rezept auf einem Host ohne globale `user.email` | Mess-Rezept setzt unbenannte Host-Konfiguration voraus |
| F-5 | LOW | Die Adresse der Werkzeug-Lücke heißt „eine Anforderung an das d-check-Repo" und trägt keine Kennung. Ein Leser der Sensor-Datei kann ihr nicht folgen. | `LH-QA-01` (eine Adresse muss auflösen) | `harness/sensors/docs-check.md:197-198` | nein | Adresse ohne auflösbare Kennung |
| F-6 | INFO | Die Datei ordnet „ob die genannte Kennung auflöst" als Grenze ohne Adresse ein. Die Ziel-Fassung nennt dieselbe Prüfung urteilsfrei und lässt „Urteil oder ein eigener Sensor" offen (`v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt, *Was Maschine hier kann*). Die Wahl „Urteil" ist damit eine Setzung, die nirgends als solche steht. Zuständig: Architect bzw. Planner. | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` | `harness/sensors/docs-check.md:198-200` | nein | undeklarierte Setzung in einer Grenz-Einordnung |
| F-7 | INFO | Liefer-Punkt 2 zählt „Risiken mit Ausgang" zur gemessenen Form; die Tabelle führt keine Lage „Risiko ohne Ausgang". Ob das den DoD-Punkt trifft, prüft die Verifikation. Zuständig: Verifier. | Slice-Plan §2 | `harness/sensors/docs-check.md:175-183` | nein | — |

**Warum F-2 nicht HIGH ist.** Liefer-Punkt 3 der DoD verlangt keinen Wächter, nur das rot
gesehene Gegenbeispiel. Die Verfeinerung von §3 steht dem Implementer offen (`v6.9.0` ·
`regelwerk/modul-09-implementierung.md`, „Plan verfeinern" schreibt in §3; ebenso der
Bedienhinweis der Slice-Vorlage). Ein Abnahmekriterium im Sinne von §3.10 ist damit nicht
umgeschrieben, wohl aber die Umfangsgrenze, die §3 selbst gezogen hatte. Ob sie so steht,
entscheidet der Planner. Einen Rollen-Konflikt gibt es nicht, der Konflikt-Pfad aus Modul 8
greift darum nicht.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pflichtgliederung beider Sensor-Dateien | geprüft, ohne Befund: `##` genau wie in `v6.9.0` · `templates/harness/sensors/gate.template.md`, beide neuen Abschnitte als `###` unter §Grenze |
| wörtlicher Umzug | geprüft, ohne Befund: der Diff verschiebt keinen Text |
| Exit-Aussagen | geprüft, ohne Befund: Skript und `make` getrennt; `Fehler 1` von d-check → make-Exit 2 nachgemessen |
| `AGENTS.md` §3.1: behaupteter Wächter | geprüft, ohne Befund: beide Dateien sagen, dass kein Wächter hält. `harness/tools/full-smoke.sh` Z. 1452, 1527, 1569, 1596 nachgelesen (`TO=done` nur in den zwei Sperr-Fällen). `test/slice-mv.bats` läuft ohne Repository (Kopfkommentar) |
| `AGENTS.md` §3.6: Gegenbeispiele | geprüft, ohne Befund für H (bloßer `git mv`), C (`closure-note-thin`) und A (fehlende `Gegenstand:`-Zeile bleibt still), je an der Kante `next → done` nachgemessen. D, E, B und G nicht nachgemessen |
| Aussage über die Konfigurations-Vorlage von d-check | geprüft, ohne Befund: Block `structure` gelesen, keine Regel mit Bedingung. Grenze: Die Vorlage ist eine Trefferliste, keine Schema-Auskunft |
| Umschreibungen der Ziel-Fassung | geprüft, ohne Befund: `harness/sensors/docs-check.md:159-162` und `:193-195` gegen `v6.9.0` · `regelwerk/modul-05-planning-harness.md` |
| `AGENTS.md` §3.7 | geprüft, ohne Befund: kein Code-, Konfigurations- oder Skript-Kommentar berührt. `5655d3a0` streicht nur den Ruhe-Marker |
| `AGENTS.md` §3.9 | geprüft, ohne Befund: die Rezepte nennen `git`, `tar`, `make` und `grep`, keine Host-Toolchain |
| `AGENTS.md` §3.11 | geprüft, ohne Befund: der Folge-Slice steht bei seiner Kennung. Die Plan-Links zeigen auf ortsfeste Sensor-Dateien |
| `MR-025`, `MR-033` | geprüft, ohne Befund: jede Zahl steht neben ihrem Kommando, die Zählschleife trägt „kein Erwartungswert", Baseline-Aussagen nennen `v6.9.0` |
| `MR-051`: Commit-Message `b97bc8e1` | geprüft, ohne Befund: Digest mit Kommando. `open: 56` / `next: 8` am Stand des Commits, mit Verweis auf das Kommando in der Datei; am Stand `61be4d3a` reproduziert |
| `ADR-0056` | geprüft, ohne Befund: nicht berührt, keine Aussage widerspricht ihr |
| Claim `cbb49bf2` | geprüft, ohne Befund: reiner Move |
| Adresse der Lücke im Werkzeug | geprüft, ohne Befund: `slice-mv-zieht-praefixlose-geschwister-verweise-nach` liegt ab `61be4d3a` in `open/`. Sein Inhalt ist nicht Gegenstand |

## Summary

0 HIGH · 2 MEDIUM · 3 LOW · 2 INFO. Wiederkehrende Klasse für die Closure §7: **Stellen-Messung
als Kanten-Eigenschaft ausgegeben** (F-1). Sie liegt nahe an
`BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine`; ob die Closure den Eintrag zitiert oder
einen neuen anlegt, entscheidet sie.

## Verdikt

**Nacharbeit vor der Closure, kein Merge-Block.** Die Kernaussagen tragen, nachgemessen an der
Kante `next → done`:
- Beide Kanten laufen durch `make slice-mv` mit reinem Move.
- `closure` liest den stillgelegten Slice.
- Die Form der Stilllegung liest kein aktives Modul.

F-1 ist eine sachlich falsche Eingrenzung in einer Grenz-Aussage und gehört an den Implementer.
F-2 ist eine Umfangsfrage an den Planner. F-3 bis F-5 sind nachrangig, F-6 und F-7 gehen an die
genannten Rollen.

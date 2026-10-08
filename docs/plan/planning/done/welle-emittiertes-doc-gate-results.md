# Welle welle-emittiertes-doc-gate — Das emittierte Doc-Gate ist entschieden — Closure-Notiz

> **Zitier-Form** *(bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieses
> Artefakt friert ein; was es zitiert, bewegt sich weiter. Deshalb: **Kennung,
> nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>`
> statt eines Links auf die Sensor-Datei, eine Baseline-Stelle als
> `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link
> (Baseline-Regelwerk `grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — beim Ausfüllen mit dem adoptierten Tag schreiben).

**Welle:** welle-emittiertes-doc-gate
**Abschluss:** 2026-10-08
**Verantwortlich:** pt9912

## Was wurde geliefert?

- Die Startkonfiguration des Doc-Gates, die das Werkzeug ins Ziel schreibt ([`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)), trägt für `planning`, `codepaths`, `targets` und `reviews` je eine Entscheidung nach den drei Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054): `slice-emittierte-gate-vorlage-traegt-targets-und-reviews`, `slice-210-planning-modul-im-emittierten-doc-gate`, `slice-211-codepaths-im-emittierten-doc-gate`, `slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand`.
- Das *Mehr* der Welle: im frisch gebootstrappten Ziel läuft `docs-check` mit neun Modulen out-of-the-box grün (`make full-smoke`, §Verifikation).

## Was hat funktioniert?

- Ein gemeinsamer Maßstab für vier Modul-Entscheidungen: jede misst an denselben drei Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054), keine braucht eine eigene Begründungsform.
- Die Closure lief in getrennten Kontexten mit je einem Artefakt: Verifier-Beleg, Audit-Vorlage, Architect-Verdikt, Rückgabe ins Register, Bestands-Entscheidung des Auftraggebers.

## Was ging anders als geplant?

- **Bestands-Lese-Schritt** (Auftraggeber-Entscheidung vom 2026-10-08): von zwölf vorgeschlagenen Gruppen trugen fünf eine Übernahme unter der Größenregel (≤ 3 Liefer-Punkte beim Nehmer). Neun Slices gingen an fünf Nehmer — `slice-199-adr-0038-bekommt-ihre-bestaetigungsrunde` (← `slice-152`, `slice-171`), `slice-227-reviewer-skill-nennt-den-vorhandenen-stand` (← `slice-reviewer-skill-zieht-die-findings-form-nach`, `slice-die-vorgangs-grenze-erreicht-den-reviewer-skill`), `slice-208-dogfood-wert-von-exclude-sections` (← `slice-212`), `slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung` (← `slice-189`), `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle` (← `slice-zaehler-label-nennt-seine-einheit`, `slice-zitat-pruefung-liest-statt-greppt`, `slice-plan-umfang-bleibt-beim-gegenstand`). Sieben Gruppen (1, 2, 4, 8, 9, 10, 11) und die übrigen Glieder von 5, 6, 7, 12 bleiben unverändert: ihre Glieder schöpfen je zwei bis drei Liefer-Punkte aus, Gruppe 1 ist selbst das Ergebnis einer Teilung nach Review-Größe. Entfallen: `slice-offene-plaene-gegen-den-neuen-stand`, `slice-baseline-wird-je-release-adoptiert`, `slice-112`, `slice-101`, `slice-146`. Bestand `open/` + `next/`: 72 + 18 vorher, 59 + 17 nachher (`ls docs/plan/planning/open | wc -l`, `ls docs/plan/planning/next | wc -l`).
- **Schritt 4 nicht ausgeführt:** `.harness/state/bin/ai-harness-init archive-welle --vorschau welle-emittiertes-doc-gate` sperrt mit `[untergrenze]` (kein `done/*/archiv.zip`, der wellenlose Altbestand liegt flach in `done/`) und `[haenger]`. Der Altbestand-Lauf `archive-welle altbestand` ist ein eigener Vorgang (Auftraggeber-Entscheidung vom 2026-10-08).

## Steering-Loop-Einträge

- **Geschärfte Regel, gezählt, nicht verkörpert:** Ein Gruppen-Vorschlag für den Bestands-Lese-Schritt zählt die Liefer-Punkte seiner Glieder, bevor er vorgelegt wird — eine Gruppe, deren Summe die Größenregel des Nehmers sprengt, ist keine Konsolidierung, sondern eine Neuzerlegung. Beleg `welle-emittiertes-doc-gate` in `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; ohne Zielort, den Ausgang weist der Lese-Schritt bei 3× zu.
- **3b — Wiederauftreten nach der Verkörperung:** Das Architect-Verdikt (`docs/reviews/2026-10-08-welle-emittiertes-doc-gate-architect-verdikt.md`) setzt keine neue Regel; kein Zielort trägt `seit welle-emittiertes-doc-gate` (`git grep -n 'seit welle-emittiertes-doc-gate' -- ':!docs/reviews'` → ein Treffer, Register-Prosa).

## Beobachtungs-Register (Zeiger)

- Ablage: [`../observations/`](../observations/README.md). Lese-Schritt: `make register-ausgang` → `233 Eintraege, 66 ueber der Schwelle, 0 Befund(e)` (vor dem Self-Close-Commit).
- Neuer Beleg `welle-emittiertes-doc-gate` in `BEO-ALL/geplanter-slice-wird-nie-gearbeitet` (vierzehn Stilllegungen, eine Gelegenheit) und `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`. Gestrichen als Ablehnung, nicht als Wegfall: `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`, `BEO-ALL/baseline-sprungweite-treibt-kosten`. Drei Ausgänge *geplant* tragen die Kennung des Nehmers `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle`.
- **Paarungen:** (a) kein Eintrag dieser Notiz trägt `liegt in` — kein Gegenstand. (b) jeder genannte Slice existiert im Lifecycle (`ls docs/plan/planning/*/<kennung>.md`). (c) erste Hälfte: ein Befund — `slice-plan-umfang-bleibt-beim-gegenstand` nennt `BEO-ALL/eine-stellen-messung-traegt-keine-folgerung-ueber-eine-eigenschaft`, das Verzeichnis existiert nicht; nicht als getragen behauptet. Register-Paarung (c), zweite Hälfte: 2 Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`).

## Folge-Slices

- Kein neuer Slice. Die fünf Nehmer aus §Was ging anders als geplant tragen die übernommenen Gegenstände.
- **An den Architect:** [`MR-048`](../../../../harness/conventions.md#mr-048) §Geltungsbereich nennt `slice-146` als Träger der zwei Regeln aus `regelwerk/modul-14-docker-harness.md` §Multi-Stage-Build; der Slice ist entfallen. Dazu die Form *gestrichen als Ablehnung* der zwei Register-Einträge, die die Ziel-Form für *gestrichen* (die Beobachtung kann nicht mehr auftreten) nicht deckt.

## Verifikation

- Schritt 1: Verifier-Beleg `docs/reviews/2026-10-08-welle-emittiertes-doc-gate-trigger.md` auf `b58401d3` — die vier Slices in `done/`; `make gates` rc=0; `make full-smoke` rc=0 (25 Zeilen `full-smoke: OK`); CI-Lauf `37734942602` success. Ein Replay-Set führt dieses Repo nicht.
- Schritt 2: `CO-001` verlängert mit Folge-Slice `slice-113`, `CO-002` permanent; kein bootstrap-aware Gate; ADR- und Hard-Rule-Zweig im Architect-Verdikt.


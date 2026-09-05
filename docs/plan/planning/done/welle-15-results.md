# Welle 15 — Re-Baseline: der vendored Baum zieht auf `v6.0.0` — Closure-Notiz

**Welle:** welle-15-re-baseline
**Abschluss:** 2026-09-05
**Verantwortlich:** Planner

## Was wurde geliefert?

<!-- BEDIENHINWEIS: Ergebnis, nicht Taetigkeit. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — *was gelernt wurde*: geliefert · was
funktionierte · was anders lief. Mit ID-Bezug, wo es einen gibt.

- **Der Pin steht auf `v6.0.0`** — Baum getauscht, alle Pins gezogen, und die
  Zielstand-Setzung ist am Ort verbucht, den
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2 dafür nennt
  ([slice-182](slice-182-baum-tausch-v600-pins-ziehen.md),
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
- **Der Form- und Regel-Diff `v5.18.0` → `v6.0.0` liegt als Katalog vor** — je
  Position Träger und Ausgang, und aus ihm sind die Zeilen 5 bis 7 der
  Slice-Tabelle geschnitten
  ([slice-176](slice-176-inventur-vor-dem-schnitt-v600.md) §9).
- **Das Beobachtungs-Register läuft in der Verzeichnis-Form** — je Beobachtung
  ein Verzeichnis `BEO-<KUERZEL>/<slug>/` aus `observation.md`, `state.md` und
  `evidence/`, der Zähler abgeleitet statt geführt
  ([slice-177](slice-177-beobachtungs-register-verzeichnis-form.md),
  [`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)).
- **Die regierende Fassung dieses Sprungs ist entschieden** —
  [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) auf der
  zweistufigen Messung aus dem Katalog, ohne `Supersedes`
  ([slice-178](slice-178-regierende-fassung-des-sprungs-v600.md),
  [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)).
- **Die Ortsfestigkeit des Registers ist vor dem Move entschieden** —
  Kennungs-Gestalt, Index-Form und das vierte Referenz-Ventil in
  [`.d-check.yml`](../../../../.d-check.yml) stehen als
  [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
  wie [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  Festlegung 4 es für diesen Fall verlangt
  ([slice-179](slice-179-register-ortsfestigkeit-vor-dem-umzug.md),
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Die Form-Beschreibung des Registers zieht im lebenden Bestand nach** — die
  Anweisungssätze und die Plan-Vorlage sprechen von Verzeichnis und Beleg-Datei
  statt von Registerzeile und Zähler-Feld
  ([slice-184](slice-184-register-form-im-bestand-nachziehen.md),
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- **Adaptions-Durchgang gegen `v6.0.0`, jeder Eintrag mit eigenem Ausgang**
  ([slice-185](slice-185-adaptions-durchgang-gegen-v600.md),
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)) — der
  Durchgang läuft pro Eintrag und nicht pro Hunk; ein Diff-Katalog kann ihn
  strukturell nicht finden.
- **Jede zitierte Beobachtungs-Kennung löst wieder auf** — die mit dem Umzug tot
  gewordene Nummern-Form ist in den Artefakten nachgezogen, die dem Planner
  gehören ([slice-186](slice-186-beobachtungs-kennungen-loesen-wieder-auf.md),
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md)); die
  Architect-Hälfte steht als Folge-Slice unten.

## Was hat funktioniert?

<!-- BEDIENHINWEIS: was du im naechsten Zyklus bewusst wieder so machen wuerdest. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3.

- **Inventur vor dem Schnitt, zweite Anwendung — und nach dem Katalog kam genau
  ein Mitglied dazu.** Die Mitglieder-Zahl der Slice-Tabelle über alle Stände der
  Welle-Datei ist **2 → 4 → 7 → 8**: eröffnet mit zwei, dann die zwei
  Entscheidungs-Slices, dann der Katalog, dann der eine Nachzügler aus dem
  vollzogenen Umzug. Kommando:

  ```sh
  for r in $(git log --format=%h --reverse --follow \
               -- docs/plan/planning/done/welle-15-re-baseline.md); do
    for p in docs/plan/planning/welle-15-re-baseline.md \
             docs/plan/planning/done/welle-15-re-baseline.md; do
      git show "$r:$p" 2>/dev/null
    done | awk '/^## 4\. Slices/,/^## 5\./' | grep -c '^| \[slice-'
  done | uniq
  ```

  **Keine Erwartungswerte** — die Reihe wächst mit jedem weiteren Stand der Datei
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die entsprechende Reihe der Vorgänger-Welle steht mit ihrem eigenen
  Kommando in [welle-14-results.md](welle-14-results.md) §*Was hat
  funktioniert?*; sie wird hier nicht abgeschrieben.
- **Die zwei Entscheidungs-Slices standen vor ihren Konsumenten, und die Kette
  hat gehalten.**
  [slice-179](slice-179-register-ortsfestigkeit-vor-dem-umzug.md) entschied die
  Ziel-Gestalt, bevor
  [slice-177](slice-177-beobachtungs-register-verzeichnis-form.md) die Ablage
  bewegte; [slice-182](slice-182-baum-tausch-v600-pins-ziehen.md) legte die
  Vorlage netzlos vor demselben Move bereit. Keine der vier tragenden
  Binnen-Kanten musste im Lauf umgehängt werden.
- **Der Adaptions-Durchgang lief gegen Delta *und* Volltext.** Das ist dieselbe
  Anlage wie in [welle-14](welle-14-re-baseline.md) und deckt die
  Fehlerrichtung, die
  [`BEO-ALL/delta-durchgang-uebersieht-deckung`](../observations/BEO-ALL/delta-durchgang-uebersieht-deckung/observation.md)
  führt: ein Eintrag bleibt *gültig*, obwohl die neue Fassung seine Setzung
  wörtlich führt und er damit gegenstandslos ist.
- **`make slice-mv` hat jeden Lifecycle-Wechsel dieser Welle selbst
  nachgezogen** (`git log --oneline --grep='^slice-mv:'`). Wo es *nicht* griff,
  war es die benannte Grenze und keine Überraschung — die eingehende Hälfte der
  präfixlosen Verweis-Form, einmal von Hand repariert
  ([`BEO-ALL/verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)).

## Was ging anders als geplant?

<!-- BEDIENHINWEIS: Beobachtungen, keine Schuldzuweisung. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — jede Zeile moeglichst mit der Konsequenz,
die daraus schon gezogen wurde (Folge-Slice, Spec-Version).

- **Ein achtes Mitglied kam nach dem Katalog dazu** —
  [slice-186](slice-186-beobachtungs-kennungen-loesen-wieder-auf.md), und der
  Grund ist der bekannte: Ein Katalog ordnet **Positionen** einen Träger zu, eine
  Position kann mehrere Konsumenten haben. Position **P-02** wies die
  Kennungs-Änderung
  [slice-177](slice-177-beobachtungs-register-verzeichnis-form.md) zu und deckte
  damit die *Verzeichnisse*, nicht die *Zitate* der abgeschafften Nummer. **Das
  ist kein drittes Auftreten von**
  [`BEO-ALL/re-baseline-ohne-inventur-slice`](../observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md):
  jene Beobachtung beschreibt eine Re-Baseline **ohne** vorgeschalteten
  Inventur-Slice; diese Welle hatte ihn, und der Zugang stammt aus dem
  vollzogenen Umzug. Der Zähler bleibt bei 2×.
- **Vier Registerzeilen haben in dieser Welle die Schwelle erreicht und ihren
  Ausgang bekommen** — anders als bei der Closure von
  [welle-14](welle-14-re-baseline.md), wo jede Zeile über der Schwelle bereits
  einen trug und keine Verkörperung entstand. Die Übergabe *Planner → Architect →
  Planner* (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für
  eine Welle, Schritt 3b) lief damit in dieser Closure zum ersten Mal seit
  [welle-10](welle-10-re-baseline.md) wieder mit Inhalt; die vier Ausgänge stehen
  unten.
- **Zwei Re-Evaluierungs-Trigger von**
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) **sind
  mit diesem Sprung gefeuert**, und der Ausgang liegt außerhalb dieser Welle:
  [slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md)
  entscheidet den Auslöser der Zeitdokumente-Archivierung im wellenlosen
  Betrieb. Der Träger der Operation bleibt entschieden, der Auslöser nicht.
- **Der Register-Umzug hat mehr Zitate gebrochen, als der Katalog kannte**, und
  die Reparatur ist zweigeteilt worden, weil das Eigentum es ist:
  [slice-186](slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) zieht, was
  dem Planner gehört,
  [slice-189](../open/slice-189-abgeschaffte-kennung-in-architect-artefakten.md)
  das, was in ADR und Adaptions-Block steht
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8).

## Steering-Loop-Einträge

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 (hier stehen **nur** Beobachtungen, die im
Register 3× erreicht haben; jeder Eintrag nennt seine Kennung) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (Feld
und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der Backticks; die
**Spec-Lücke** trägt statt `liegt in` ihre `LH-*`-ID — das ist kein Versehen).

**Zehn Einträge des Registers stehen bei ≥ 3×**, alle übrigen darunter — gezählt
über die abgeleiteten Zähler, nicht über ein Feld:

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  printf '%s %s\n' "$(ls "$d/evidence" | wc -l)" "$d"
done | sort -rn | awk '$1 >= 3' | wc -l
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, geschärft durch
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2 — ein Zähler-Stand ist eine datierte Messung). **Vier davon standen
beim Lese-Schritt auf `offen` und haben hier ihren Ausgang bekommen:**

- **Hard Rule ergänzt** — den Slice schließt der Planner, nicht der Lauf, der ihn
  gebaut hat; der Commit-Zuschnitt macht die Rollen-Grenze im Nachhinein ablesbar,
  `Verantwortlich:` überträgt die Abnahme nicht, und eine Änderung am eigenen
  Abnahmekriterium ist ein Übergabe-Artefakt
  — liegt in `AGENTS.md §3.10` (`seit welle-15`).
  Auslöser: [`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  (slice-177, slice-178, slice-185, slice-186 — 4×). Die Sektion benennt ihre
  Wächter-Lücke selbst: kein Modul des Doku-Gates liest Commits, Träger ist der
  Rollen-Wechsel vor dem Abschluss.
- **Hard Rule ergänzt** — eine Adresse, die der Prozess bewegt, steht nicht in
  einem einfrierenden Artefakt; gebunden ist die Eigenschaft *wandert auf
  Anweisung* statt die Aufzählung der Bäume
  — liegt in `AGENTS.md §3.11` (`seit welle-15`).
  Auslöser: [`BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
  (slice-154, slice-156, slice-179 — 3×). Keine der extensionalen
  Aufnahme-Grenzen für die Referenz-Ventile in
  [`.d-check.yml`](../../../../.d-check.yml) wird dadurch erweitert.
- **Adaptions-Eintrag neu** — ein Zähler-Stand des Beobachtungs-Registers ist
  eine datierte Messung und kein Wert im Text: er trägt das ableitende Kommando,
  ist kein Erwartungswert, und die Schwellen-Folgerung kommt aus dem Lauf
  — liegt in [`harness/conventions/MR-051-zahl-beleg-bindet-commit-message-und-register-zaehler.md`](../../../../harness/conventions/MR-051-zahl-beleg-bindet-commit-message-und-register-zaehler.md)
  (Setzung 2, Feld `Wirksamkeits-Anlass: welle-15`).
  Auslöser: [`BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand`](../observations/BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand/observation.md)
  (slice-175, slice-180, slice-182 — 3×). Der Wächter fehlt und ist hier
  **baubar**; was fehlt, ist die Entscheidung über seinen Prüfbereich.
- **Adaptions-Eintrag neu** — die Commit-Message dieses Repos steht im
  Geltungsbereich des Zahl-Belegs
  — liegt in [`harness/conventions/MR-051-zahl-beleg-bindet-commit-message-und-register-zaehler.md`](../../../../harness/conventions/MR-051-zahl-beleg-bindet-commit-message-und-register-zaehler.md)
  (Setzung 1, Feld `Wirksamkeits-Anlass: welle-15`);
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  trägt dafür die Kopf-Marke nach
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 3, sein Rumpf bleibt wörtlich.
  Auslöser: [`BEO-ALL/zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  (slice-147, slice-148, slice-182 — 3×).

**Die übrigen sechs über der Schwelle trugen ihren Ausgang schon vor dieser
Closure** und werden hier nicht neu zugewiesen — zwei *verkörpert*
([`BEO-ALL/dritter-risiko-ausgang-ohne-ort`](../observations/BEO-ALL/dritter-risiko-ausgang-ohne-ort/observation.md)
`seit slice-137`,
[`BEO-ALL/verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
`seit slice-144`), vier *geplant* mit Kennung
([`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
→ `slice-153`,
[`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
→ `slice-181`,
[`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
→ `slice-151`/`slice-152`,
[`BEO-ALL/adaptions-block-spricht-ueber-sich-selbst`](../observations/BEO-ALL/adaptions-block-spricht-ueber-sich-selbst/observation.md)
→ `slice-168`). Die erste dieser vier ist in dieser Welle um vier Belege
gewachsen — der Anstieg ist selbst der Befund: die Klasse wächst schneller als
ihr Träger.

<!-- Gegenstück am Ziel, nicht vergessen — es ist die andere Hälfte des Paares:
     noqa-gate:  ## LH-QA-SUP-002 · seit welle-<NN>
     ### 3.3 <Hard Rule>   (seit welle-<NN>)
     Entfernen oder Lockern dieser Regel setzt später den Retirement-Check
     voraus: „seit welle-<NN> — ist die Beobachtung wieder aufgetreten?" -->

## Beobachtungs-Register (Zeiger)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — der Zähler wird **nicht** hier gepflegt; diese
Sektion ist ein Zeiger und trägt keine Daten.

Der Zähler steht in [`../observations/`](../observations/README.md) — je
Beobachtung ein Verzeichnis, der Zähler ist die Zahl der Dateien unter
`evidence/`. Was in dieser Welle **3×** erreicht hat, steht oben unter
*Steering-Loop-Einträge*.

## Folge-Slices

<!--
DERIVATIV: der Folge-Slice selbst ist eine Datei in `open/`; diese Liste
zeigt nur darauf. Deshalb braucht sie keinen eigenen Konsumenten — wohl
aber eine Deckung: jeder genannte Folge-Slice MUSS als Datei im
Planning-Lifecycle existieren (`open/`, `next/`, `in-progress/`, `done/` —
nicht nur `open/`, er kann bis zur Prüfung weitergewandert sein).
Folge-Slice-Paarung, geprüft am Ende von Schritt 3 der Closure-Prozedur.
Genannt ohne angelegt ist dieselbe Klasse wie ein halluziniertes Gate.
-->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — **derivativ**: Diese Liste zeigt nur,
das Original ist die Slice-Datei. Jeder genannte Folge-Slice muss als Datei im
Planning-Lifecycle existieren; genannt ohne angelegt ist dieselbe Klasse wie
ein halluziniertes Gate.

- [slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md) — der
  Auslöser der Zeitdokumente-Archivierung im wellenlosen Betrieb (Architect).
  Position **P-06** des Katalogs, von §6 dieser Welle ausdrücklich außerhalb
  gehalten.
- [slice-188](../open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md)
  — der Archiv-Stub kennt die Kennungs-Form des Registers; hervorgegangen aus
  [slice-184](slice-184-register-form-im-bestand-nachziehen.md).
- [slice-189](../open/slice-189-abgeschaffte-kennung-in-architect-artefakten.md)
  — die Architect-Hälfte des Kennungs-Nachzugs; hervorgegangen aus
  [slice-186](slice-186-beobachtungs-kennungen-loesen-wieder-auf.md).

**Zwei Slices sind in dieser Welle entstanden und sind trotzdem keine Folge von
ihr:** [slice-187](../open/slice-187-d-check-pin-v0741.md) trägt den d-check-Pin
`v0.65.0` → `v0.74.1` und tritt an die Stelle von
[slice-135](../open/slice-135-d-check-pin-v0661.md). Sein Trigger ist
`make freshness-dcheck` und hängt an keiner Baseline-Version; §6 dieser Welle
nennt die Linie namentlich als Out-of-Scope. Beide bleiben in `open/`.

## Verifikation

<!--
Die Belege aus Schritt 1 der Closure-Prozedur. Keine Behauptung ohne
nachprüfbaren Anker (Hash, Lauf, Zahl).
-->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 1 — keine Behauptung ohne nachprüfbaren
Anker (Hash, Lauf, Zahl).

**Schritt 1 — Trigger geprüft.** Die vier repo-weiten Bedingungen aus §3 der
Welle-Datei sind vom **Verifier** in eigenem Kontext einzeln gefahren worden;
der Beleg ist
[`docs/reviews/2026-09-05-welle-15-re-baseline-verify.md`](../../../reviews/2026-09-05-welle-15-re-baseline-verify.md).
Das ist das Übergabe-Artefakt *Verifier → Planner* aus
`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 1.

- **Alle Mitglieder liegen in `done/`** — die Slice-Tabelle der Welle führt acht
  Zeilen
  (`sed -n '/^| Slice | Titel | Bezug |/,/^$/p' docs/plan/planning/done/welle-15-re-baseline.md | grep -c '^| \[slice-'`),
  und zu jeder Nummer findet `find docs/plan/planning/done -iname "slice-<NNN>-*.md"`
  genau einen Treffer.
- **`make gates` grün** — EXIT 0 im Verifier-Lauf; nach dem Self-Close-Commit
  erneut bestätigt, weil der Stempel des Stop-Hooks am Tree hängt.
- **`make full-smoke` grün** — EXIT 0. Das ist das *Mehr* dieser Welle: der Lauf
  steht **nicht** im CI-pro-Push-Satz
  ([`harness/README.md`](../../../../harness/README.md) §Sensors) und ist
  zugleich der, an dem der Baum-Tausch von
  [welle-10](welle-10-re-baseline.md) brach.
- **Der Pin ist vollzogen** — `make baseline-verify` meldet
  `v6.0.0 OK — 53 Dateien (Integritaet + Vollstaendigkeit, netzlos)`, und
  §Baseline von
  [`harness/conventions.md`](../../../../harness/conventions.md#baseline) nennt
  denselben Tag.
- **Closure-Notiz geschrieben** — diese Datei.

**Schritt 2 — Trigger-Audit, alle drei Artefaktklassen:**

- **Carveouts — zwei aktive Dateien** (`ls docs/plan/carveouts/CO-*.md | wc -l`
  → **2**; keine Erwartungswerte).
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) (Gate `shell-lint`):
  Trigger **weiterhin eingetreten**, Ausgang unverändert *verlängert mit
  Folge-Slice* — die Datei nennt
  [slice-113](../open/slice-113-co-001-ist-faellig.md) als Folge-Slice, und
  [slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md)
  entscheidet vorher. Der Bestand ist gewachsen — `ls test/*.bats | wc -l` →
  **22**, keine Erwartungswerte —, die tragende Fundstelle des Carveouts ist
  unverändert.
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md): *permanent*,
  übergeführt in
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md); beide
  Zeiger bestätigt, keiner betrifft ein Gate dieser Welle. **Kein stilles rotes
  Gate:** `make gates` ist mit beiden Carveouts an Ort und Stelle grün.
- **Bootstrap-aware Gates** — keine Reifestufe dieser Welle stand zum
  Hochschalten an; die Stufung von
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) ist oben behandelt und
  hängt an `slice-141`, nicht an dieser Closure.
- **ADRs mit Re-Evaluierungs-Trigger** — **5** stehen auf `Proposed`
  (`grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md | wc -l`; keine
  Erwartungswerte). Drei tragen einen benannten Annahme-Träger, der als Datei
  existiert:
  [`ADR-0025`](../../adr/0025-register-mit-gemischten-originalen.md) und
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
  → [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md),
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  → [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md).
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) trägt
  ihren Acceptance-Trigger **in der Datei** (§Der Acceptance-Trigger: eine
  Reviewer-Runde gegen drei benannte ADRs, deren Report in `docs/reviews/`
  liegt) — der Report liegt heute nicht vor, ein Slice ist dafür nach dem
  Wortlaut jener Sektion nicht vorgesehen. **Ein Befund bleibt:**
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  trägt weder eine Acceptance-Sektion noch einen Träger
  (`git grep -l '0035-beleg-statt-lauf' -- docs/plan/planning/open docs/plan/planning/next`
  ist leer, Exit 1). Die Eintrags-Vorlage der Baseline verlangt keine solche
  Sektion — der Befund ist damit kein Norm-Verstoß, sondern eine offene
  Trägerfrage, und sie geht als **Übergabe an den nächsten Planungs-Akt**, nicht
  in diese Closure. Ihre drei Re-Evaluierungs-Trigger sind **nicht** gefeuert:
  diese Welle hat `harness/tools/mutate.sh` nicht berührt
  (`git log --oneline --since=2026-09-04 -- harness/tools/mutate.sh` ist leer).
  Die zwei gefeuerten Trigger von
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) tragen
  [slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md).

**Schritt 4 — Archivierung: gefahren, fail-closed an zwei Sperren abgebrochen.**
Träger ist `make archive-welle WELLE=welle-15`
([`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
Festlegung 1); von Hand archiviert niemand, denn die Vollständigkeit des Archivs
bezeugt allein der Archivierungs-Commit. Der **schreibende** Lauf ist über dem
sauberen Baum nach den Move-Commits gefahren und hat nichts geschrieben — das
Unterkommando endete mit Status 3, `make` mit 2, und `git status --porcelain`
danach ist leer. Seine Vorprüfung meldet:

```text
  Mitglieder (Welle-Feld nennt welle-15): 8
  wellenlos (seit der letzten Closure): 47
  fremd (andere Welle, bleibt liegen):  77
  Review-Reports (ohne Stub):           121
  Sperren: 2 — der schreibende Lauf braeche ab.
    [untergrenze] 47 wellenlose(r) Slice(s) liegen flach in docs/plan/planning/done/,
                  aber kein docs/plan/planning/done/*/archiv.zip setzt eine Untergrenze
    [haenger]     ein Review-Report soll verschwinden, auf den noch verwiesen wird
```

**Keine Erwartungswerte** — die vier Bestandszahlen wandern mit dem Baum
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Beide Sperren sind unabhängig von dieser Welle:

- `[untergrenze]` — solange kein `docs/plan/planning/done/*/archiv.zip` existiert
  (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l` → **0**), hat
  *wellenlos seit der letzten Closure* keine beobachtbare Untergrenze; die Klasse
  umfasste den gesamten Altbestand, und der Lauf rät nicht. Die Archivierung des
  Altbestands ist ein eigener Vorgang und braucht die Entscheidung, die
  [slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md)
  trägt — §6 dieser Welle hält beides ausdrücklich außerhalb.
- `[haenger]` — Review-Reports sollen ins Archiv, auf die noch verwiesen wird;
  der Lauf listet **42** Verweis-Paare auf (`… -> docs/reviews/…`-Zeilen der
  Sperren-Ausgabe), darunter Verweise aus `Accepted`-ADRs, die
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 einfriert.

**Diese Welle schließt damit ohne Schritt 4.** Das ist die im Anweisungssatz
vorgesehene Feststellung und kein Mangel: *„Bricht der Lauf an einer Sperre,
gehört das als Feststellung in die Results-Notiz, und die Welle schließt ohne
Schritt 4."* Die Zeitdokumente dieser Welle bleiben flach in `done/`.

**Die drei Paarungen (Ende Schritt 3):**

- **(a) Anker-Paarung** — vier Einträge oben tragen ein `liegt in`. Zwei zeigen
  auf `AGENTS.md` §3.10 und §3.11; beide Sektionen existieren und tragen den
  Herkunfts-Anker (`grep -c 'seit welle-15' AGENTS.md` → **2**, keine
  Erwartungswerte). Zwei zeigen auf die Rumpf-Datei von
  [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung);
  sie existiert und trägt die Herkunft in der Feld-Form der Eintrags-Vorlage
  statt als `· seit welle-15` — **das ist die Form, die ein Adaptions-Eintrag
  für Herkunft hat**, und sie ist hier benannt statt stillschweigend
  gleichgesetzt:

  ```sh
  grep -c 'Wirksamkeits-Anlass:\*\* welle-15' \
    harness/conventions/MR-051-zahl-beleg-bindet-commit-message-und-register-zaehler.md   # 1
  ```

  Die sechs übrigen Einträge über der Schwelle tragen kein `liegt in` in dieser
  Notiz und sind kein Gegenstand der Paarung.
- **(b) Folge-Slice-Paarung** — alle genannten Folge-Slices existieren im
  Planning-Lifecycle
  (`for s in 183 188 189 187 135 113 141 151 152 153 168 171 181; do ls docs/plan/planning/*/slice-$s-*.md; done`
  → je genau ein Treffer).
- **(c) Register-Paarung** — jede oben zitierte Kennung existiert als
  Verzeichnis unter `docs/plan/planning/observations/`, und jedes Verzeichnis des
  Registers trägt ein nicht leeres `evidence/`
  (`for d in docs/plan/planning/observations/BEO-*/*/; do [ -n "$(ls -A "$d/evidence" 2>/dev/null)" ] || echo "LEER: $d"; done`
  → keine Ausgabe). Die Umkehrung *„jede Zeile ist irgendwo zitiert"* wird nach
  Modul 6 nicht geprüft.

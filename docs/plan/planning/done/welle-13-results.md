# Welle welle-13 — Regeln bekommen ihren Sensor — Closure-Notiz

**Welle:** welle-13
**Abschluss:** 2026-09-14
**Verantwortlich:** Planner

## Was wurde geliefert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — *was gelernt wurde*: geliefert · was
funktionierte · was anders lief. Mit ID-Bezug, wo es einen gibt.

- **Vier Regeln des gepinnten Doku-Gates haben ihren Sensor.** Drei Module und zwei Fähigkeiten
  sind verdrahtet — `targets` ([slice-124](slice-124-gate-tabelle-hat-einen-waechter.md)),
  `planning` mit Überschrift/Ruhe-Marker
  ([slice-125](slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)) und mit `planning.closure`
  ([slice-129](slice-129-closure-notiz-hat-einen-sensor.md)), `commits`
  ([slice-126](slice-126-commit-message-traegt-eine-kennung.md)) und `vcs`
  ([slice-127](slice-127-adr-immutabilitaet-hat-einen-sensor.md)). `commits` und `vcs` laufen
  bewusst **außerhalb** `make gates` und haben je einen benannten Aufrufer (PreToolUse-Hook bzw.
  eigener CI-Job mit `fetch-depth: 0`, [slice-123](slice-123-ci-sieht-die-historie.md)).
- **Jedes der neu verdrahteten Module ist einmal rot gesehen worden** — fünf Nachweise, vier davon
  mit dem Kommando im Umsetzungs-Commit; der fünfte (`targets`) trägt ihn im Repo und in der
  Verifikation (§Verifikation, *Was ging anders als geplant*).
- **Alle dreizehn `docs?-*`-Ziele tragen eine Entscheidung über ihren Prüfbereich**, und die zwei
  Ziele ohne Config-Block sagen ihre Inertheit in Ausgabe **und** Hilfetext
  ([slice-217](slice-217-doc-ziel-nennt-seinen-pruefbereich.md),
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Das Beobachtungs-Register hat zum ersten Mal einen vollständigen Lese-Schritt getragen:**
  **18** Einträge standen über der Schwelle und trugen `offen`; **neun** sind *verkörpert*, **neun**
  *geplant* mit benannter Kennung. Der Gegenstand ist an seinem Zeitpunkt gemessen, nicht geschätzt:

  ```sh
  for d in docs/plan/planning/observations/BEO-*/*/; do
    n=$(ls "$d"evidence 2>/dev/null | wc -l)
    if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
  done | sort -rn | wc -l
  ```

  **Keine Erwartungswerte** — die Zahl wandert mit dem Baum. Die Verteilung des ganzen Registers
  nach dem Lauf:

  ```sh
  grep -h '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/*/state.md | sort | uniq -c
  ```

## Was hat funktioniert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3.

- **Der geteilte Schnitt hat getragen.** Die Welle ist der Schnitt-Vorschlag zu vier Achsen des
  Roadmap-Kandidaten, und jede Achse hat genau einen Slice bekommen; keiner der vier war zu groß,
  keiner musste zurückgeführt werden.
- **Die Trennung von Pin und Adoption.** §1 und §6 der Welle sind gegen **beide** Digests gefahren
  (Pin-Wirkung und Baum-Wirkung getrennt) — die Lesart aller Zahlen dieser Welle steht damit fest,
  statt nachträglich rekonstruiert zu werden.
- **Die zwei Träger, die die Welle nicht in ihrer §4 nannte, kamen über ihr Kopf-Feld.** Mitglied
  ist, wer `**Welle:** welle-13` trägt — der Lese-Schritt der Closure hat am Feld gezählt und nicht
  an der Tabelle gezählt.
- **Der Lese-Schritt des Registers hat getragen:** Weil [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) die benannte
  Lücke trägt, brauchte die Mehrzahl der achtzehn **keinen** neuen Träger — der Zielort stand.

## Was ging anders als geplant?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — jede Zeile möglichst mit der Konsequenz,
die daraus schon gezogen wurde (Folge-Slice, Spec-Version).

- **Das Abnahmekriterium trug zwei Bestandswerte ohne Kommando, und beide waren gewandert.** §3
  nannte **zwölf** `docs?-*`-Ziele (gemessen **dreizehn**,
  `grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk`) und **sechs** Slices (gemessen **sieben** Träger,
  `grep -lE '^\*\*Welle:\*\*.*welle-13' docs/plan/planning/done/*.md | wc -l`). **Konsequenz:**
  §3 trägt jetzt dreizehn samt Kommando, §4 führt
  [slice-217](slice-217-doc-ziel-nennt-seinen-pruefbereich.md) mit seiner Kennung. Der Fall ist als
  Beleg ins Register eingetragen
  ([`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md),
  Vorgang `2026-09-14-welle-13-verify`).
- **Der Rot-Nachweis zu `targets` steht nicht dort, wo das Kriterium ihn verlangt.** Der
  Umsetzungs-Commit `6f454e15` nennt weder Kommando noch Grund-Code noch Exit; der Nachweis liegt im
  Repo (`harness/README.md` §Sensors, Teil desselben Commits) und der Verifier hat ihn reproduziert
  (`gate-phantom`, Exit 1) — **die Sache trägt, die Beleg-Form nicht**. Ein Nachtrag ist nicht
  möglich: Ein Commit ist eingefroren, und das Kriterium verlangt eine Angabe *in* ihm.
  **Konsequenz:** Der Befund steht hier; die Welle schließt über die Substanz des Kriteriums, und
  die Form-Forderung „das Kommando **im Umsetzungs-Commit**" ist als Kriteriums-Form zu schärfen —
  sie ist retroaktiv unerfüllbar.
- **`commits` und `vcs` liegen bewusst außerhalb der Modul-Liste `make gates`.** Das Kriterium
  *„mit den neu aufgenommenen Modulen **in** der Modul-Liste"* ist für sie wörtlich nicht erfüllt;
  die Klasse, gegen die es geschrieben ist (ein Modul, das „daneben" liegt und nie läuft), ist
  **nicht** eingetreten — beide haben einen Aufrufer. Der Grund steht in der Gate-Config selbst.
- **Der Trigger-Audit fand einen ausgeführten ADR-Trigger ohne Ausgang**, und er war nicht der
  übergebene: [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  Trigger 2 ist erfüllt, der `scan.ignore`-Eintrag ruht auf einer widerlegten Werkzeug-Aussage.
  **Konsequenz:** Folge-ADR
  [`ADR-0050`](../../adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) (`Proposed`,
  Teil-`Supersedes`) mit Zeile im [ADR-Index](../../adr/README.md).
- **Der übergebene Fall [`ADR-0048`](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Trigger 3 ist *nicht* ausgeführt** — kein Vorgang stellt die
  Eigentums-Frage für ein zweites Planungs-Artefakt. Die Verengung auf den Welle-Plan trägt weiter.
- **Eine Zahlendrift im Carveout `CO-001`:** Geltungsbereich **16**, letzte Prüfung **20**, Bestand
  heute **30** (`git ls-files 'test/*.bats' | wc -l`). Der **Ausgang** des Carveouts ist davon nicht
  berührt; betroffen ist das Zahl-Feld. Als Beleg eingetragen (Vorgang
  `2026-09-14-welle-13-trigger-audit`).
- **[`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) steht auf `Proposed` und hat weder Acceptance-Trigger noch Träger-Slice.** Aus dem
  Befund ist ein Träger geschnitten (§Steering-Loop-Einträge).
- **Die `Proposed`-Lage von [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) und die Zahl `16`/`20`/`30` sind die zwei Übergaben des
  Trigger-Audits an diesen Lauf**; er hat sie beide aufgenommen, die eine als Träger-Slice, die
  andere als Register-Beleg.
- **Schritt 4 (Archivierung) ist **nicht** ausgeführt — der Lauf bricht an einer Sperre.**
  `archive-welle --vorschau welle-13` endet mit **Exit 3** und nennt fünf Sperren; nach Schritt 3
  lösen sich zwei davon selbst auf (`[ergebnisnotiz]` — die Notiz existiert jetzt; `[kein-plan]` —
  der Plan liegt nach dem `git mv` in `done/`), die dritte ist der Prüf-Zustand des Arbeitsbaums
  (`[unsauber]`) und verschwindet mit den Commits. **Es bleiben zwei:** `[untergrenze]` — **71**
  wellenlose Slices liegen flach in `docs/plan/planning/done/`, aber kein
  `docs/plan/planning/done/*/archiv.zip` setzt eine Untergrenze — und `[haenger]` — ein
  Review-Report soll verschwinden, auf den noch verwiesen wird. Der Lauf meldete **7** Mitglieder,
  **71** wellenlose und **177** Review-Reports. **Konsequenz:** Die **Wellen-Archivierung dieses
  Repos ist noch nicht ausführbar**; sie braucht zuerst den wellenlosen Altbestand als eigenen
  Vorgang ([`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)) und
  die Auflösung der toten Review-Verweise. Die Welle schließt **ohne** Schritt 4 — so steht es in
  der Prozedur, und archiviert ist nichts.
- **Der Breiten-Wächter der `ignore-refs`-Ausnahmen hat die Zielort-Form mitentschieden.** Zwei
  Zielorte in `state.md` und ein Link in der bewegten Welle-Datei zeigten als Markdown-Link in den
  vendored Baum. Die drei Baum-Paare aus
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) deklarieren ihre
  Deckung per `# Deckung: N`, und **jede** Verbreiterung ist eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 — der Wächter `test/ignore-refs-restbreite.bats` fiel
  rot (`docs/plan/planning/done/** → .harness/baseline/**`: 5 auflösende Links, deklariert 4;
  `…/observations/**`: 4 gegen 2). **Konsequenz:** Die drei Stellen nennen ihre Baseline-Stelle
  seither als **Kennung** (`v6.8.0 · regelwerk/<datei>.md` §<Abschnitt>) statt als Link — die Form,
  die [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  Setzung 2 für ein lebendes Artefakt ohnehin verlangt. **Keine** Deklaration wurde angefasst.
- **Die Register-Paarung (c) hat einen beleglosen Eintrag gefunden — und ihn benannt statt
  geschlossen.** **Ein** Verzeichnis führt kein `evidence/`
  ([`BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md));
  sein `observation.md` nennt den Grund selbst (*„aufgefallen in einer Koordinations-Sitzung, nicht
  in einem abgeschlossenen Vorgang"*). **Konsequenz:** kein Verzeichnis wurde angelegt, um die
  Paarung zu befriedigen; der Befund steht als Beleg beim Träger der Klasse
  ([`BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung`](../observations/BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung/observation.md),
  Vorgang `welle-13`) und wartet auf die Norm-Entscheidung, die jene Beobachtung registriert.

## Steering-Loop-Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 (hier stehen **nur** Beobachtungen, die im
Register 3× erreicht haben; jeder Eintrag nennt seine `BEO-<KUERZEL>/<slug>`) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Achtzehn Einträge standen über der Schwelle und trugen `offen`** — gezählt über den abgeleiteten
Zähler, nicht über ein Feld:

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn
```

**Zehn davon waren kein Gegenstand dieses Schritts** und standen bereits auf einem Ausgang, als der
Lese-Schritt lief (sieben *verkörpert*, drei *geplant*). **Neun haben hier ihren Ausgang als
*verkörpert* bekommen, neun als *geplant* mit Kennung.**

**Warum die neun *verkörpert* keinen zweiten Herkunfts-Anker tragen:** Bei ihnen stand die Regel
**schon** an einem Norm-Artefakt — die Beobachtung ist eine *benannte Lücke*, kein fehlender Satz
([`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1). Ihre Zielorte
tragen darum ihre **eigene** Kennung oder Stelle
(`grundlagen-traceability.md` §Herkunfts-Anker, Geltungsbereich), und die fehlende Bewachung steht
im jeweiligen `state.md` als Abschnitt *Grenze der Verkörperung, benannt*. **Was diesen Wellen-Lauf
von `welle-15` unterscheidet:** dort sind vier Regeln **neu geschrieben** worden (zwei Hard Rules,
zwei `MR`-Setzungen) — hier ist keine einzige neu entstanden; die Arbeit war das **Suchen** des
Zielorts.

- **Adaptions-Eintrag getragen** — eine Zahl ohne ihr Kommando trifft ihren Gegenstand nicht
  — liegt in [`MR-025`](../../../../harness/conventions/MR-025-eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert.md) Setzung 1 und 2.
  Auslöser:
  [`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  (11×, zuletzt `2026-09-14-welle-13-verify` und `-trigger-audit`).
- **Hard Rule getragen** — ein Kommentar beschreibt, was da ist, und trägt Herkunft nur als ein
  auflösbares Feld — liegt in `AGENTS.md §3.7`.
  Auslöser:
  [`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  (9×).
- **Regel der adoptierten Baseline getragen** — jede Rollen-Übergabe trägt ein benanntes Artefakt
  — liegt in `v6.8.0 · regelwerk/modul-08-agentenrollen.md` §Die neun Übergaben.
  Auslöser:
  [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  (6×).
- **Hard Rule getragen** — wer keinen Fall in `test/mutations/` hat, ist unbewacht
  — liegt in `AGENTS.md §3.6`. Auslöser:
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (6×).
- **Adaptions-Eintrag getragen** — eine Messung, die ihr eigener Vorgang bewegt, wird nach dem
  Vorgang genommen — liegt in [`MR-058`](../../../../harness/conventions/MR-058-eine-messung-die-ihr-eigener-vorgang-bewegt-wird-danach-genommen.md) Setzung 2.
  Auslöser:
  [`BEO-ALL/mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md)
  (5×).
- **Entscheidung getragen** — der Verweis-Nachzug ersetzt eine Adresse und ändert keine Aussage;
  die mechanisch trennbare Gegenform ist die im Code-Block
  — liegt in [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4
  und 5. Auslöser:
  [`BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md)
  (4×).
- **Adaptions-Eintrag getragen** — eine Aussage über die Baseline nennt den Tag, gegen den sie
  gemessen ist — liegt in [`MR-033`](../../../../harness/conventions/MR-033-eine-aussage-ueber-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist.md) Setzung 1.
  Auslöser:
  [`BEO-ALL/baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md)
  (4×).
- **Regel der adoptierten Baseline getragen** — ein Gate ohne seine Grenze behauptet zu viel; eine
  Vollständigkeits-Zeile ist die Stelle, an der es auffliegt
  — liegt in `v6.8.0 · regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin).
  Auslöser:
  [`BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  (3×).
- **Hard Rule getragen** — ein Mutations-Fall, dessen Mutation nicht greift, färbt `make mutate`
  fail-closed rot — liegt in `AGENTS.md §3.6` mit Träger `Makefile:mutate`.
  Auslöser:
  [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  (3×).

**Die neun *geplant* haben je einen Träger bekommen** — ihr Zielort fehlte, und [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md)
Festlegung 2 verlangt für diesen Fall einen Schnitt, keine Auslegung:

| Beobachtung | Zähler | Träger |
|---|---|---|
| [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md) | 20× | `slice-ortswechsel-zieht-sein-zustandsfeld-nach` |
| [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md) | 8× | `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle` |
| [`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md) | 6× | `slice-offene-plaene-gegen-den-neuen-stand` |
| [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md) | 3× | `slice-zitat-pruefung-liest-statt-greppt` |
| [`zaehler-label-nennt-falsche-einheit`](../observations/BEO-ALL/zaehler-label-nennt-falsche-einheit/observation.md) | 3× | `slice-zaehler-label-nennt-seine-einheit` |
| [`slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md) | 3× | `slice-plan-umfang-bleibt-beim-gegenstand` |
| [`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md) | 3× | `slice-gate-ausgang-schreibt-die-adresse-aus` |
| [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md) | 3× | `slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung` |
| [`gate-modul-erreicht-den-vendored-baum-nicht`](../observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/observation.md) | 3× | `slice-202` (bestand bereits) |

**Der Zähler ist eine datierte Messung**
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2) — jeder Betrag oben wandert mit dem Baum.

**Zwei Belege sind aus den Schritten 1 und 2 dazugekommen** — der Vorgang zählt je Eintrag einmal,
der Dateiname **ist** die Kennung: `2026-09-14-welle-13-verify` und
`2026-09-14-welle-13-trigger-audit` für
[`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md),
`2026-09-14-welle-13-trigger-audit` für
[`proposed-adr-annahme-ohne-repo-internen-traeger`](../observations/BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger/observation.md).

**Ein Posten bleibt benannt und nicht gezählt:** Der Closure-Lauf selbst hat einen Zielort
**gesucht** statt einen geschrieben — keine der achtzehn Regeln ist in diesem Lauf entstanden. Ob
das die Ausnahme oder der Regelfall eines Lese-Schritts ist, entscheidet die zweite Instanz; die
Frage gehört in den Re-Evaluierungs-Trigger 2 von
[`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md).

## Beobachtungs-Register (Zeiger)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — der Zähler wird **nicht** hier gepflegt; diese Sektion ist ein Zeiger
und trägt keine Daten.

Der Zähler steht in
[`../observations/`](../observations) (Verzeichnis-Form, ein Verzeichnis je Beobachtung). Was in
dieser Welle **3×** erreicht hat, steht oben unter *Steering-Loop-Einträge*.

## Folge-Slices

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — **derivativ**: Diese Liste zeigt nur, das Original ist die
Slice-Datei. Jeder genannte Folge-Slice muss als Datei im Planning-Lifecycle existieren; genannt
ohne angelegt ist dieselbe Klasse wie ein halluziniertes Gate.

**Neun Träger, aus diesem Lauf geschnitten** (jeder liegt in `open/`):

- `slice-ortswechsel-zieht-sein-zustandsfeld-nach`
- `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle`
- `slice-offene-plaene-gegen-den-neuen-stand`
- `slice-zitat-pruefung-liest-statt-greppt`
- `slice-zaehler-label-nennt-seine-einheit`
- `slice-plan-umfang-bleibt-beim-gegenstand`
- `slice-gate-ausgang-schreibt-die-adresse-aus`
- `slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung`
- [`slice-202`](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
  (bestand bereits)

## Verifikation

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 1 — keine Behauptung ohne nachprüfbaren Anker (Hash, Lauf, Zahl).

- **Schritt 1 — Trigger geprüft.** Beleg:
  [`docs/reviews/2026-09-14-welle-13-verify.md`](../../../reviews/2026-09-14-welle-13-verify.md),
  gefahren über `cb5646dd`. Verdikt: die vier prüfbaren Kriterien sind erfüllt — Kriterium 3 in der
  Sache (fünf von fünf Modulen hier rot gefahren), seine Beleg-Form bei `targets` nicht (§Was ging
  anders als geplant).
- **Schritt 2 — Trigger-Audit.** Beleg:
  [`docs/reviews/2026-09-14-welle-13-trigger-audit.md`](../../../reviews/2026-09-14-welle-13-trigger-audit.md),
  gefahren über `0fa065f9`. Verdikt: kein bootstrap-aware Gate vorhanden; ein ausgeführter
  ADR-Trigger ohne Ausgang → [`ADR-0050`](../../adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md) (`Proposed`); [`ADR-0048`](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Trigger 3 **nicht** ausgeführt;
  beide Carveouts bestätigt.
- **`make gates` grün** über dem Abschluss-Stand; die neu aufgenommenen Module stehen in der
  Modul-Liste der Gate-Config
  (`grep -m1 '^modules:' .d-check.yml` → acht Module, darunter `planning` und `targets`).
- **Die zwei offenen Carveouts tragen ihren Stand** — `CO-001` *verlängert mit Folge-Slice*
  ([slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) entscheidet vor,
  [slice-113](../open/slice-113-co-001-ist-faellig.md) führt aus), `CO-002` *permanent* (in
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) übergeführt). Ein
  Zahl-Befund in `CO-001` ist benannt und als Register-Beleg eingetragen.
- **Schritt 4 — Archivierung — nicht ausgeführt**, der Vorschau-Lauf endet mit **Exit 3** an zwei
  stehenden Sperren (`[untergrenze]`, `[haenger]`); die Feststellung steht unter *Was ging anders
  als geplant*.

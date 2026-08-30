# CO-005: Ein datierter Beleg im Adaptions-Block hat kein auflösbares Ziel

**Status:** **Aufgelöst** — der Modul-7-Übergang ist vollzogen, und der Ort sagt es: diese Datei
liegt in `done/`, der Index führt sie unter *Aufgelöst*. Der Auflösungs-Trigger ist eingetreten:
[`.d-check.yml`](../../../../.d-check.yml) trägt den Top-Level-`ignore-refs`-Eintrag, den
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) autorisiert, die
Befund-Zeile wird nicht mehr gemeldet, und die Dateizahl steht mit und ohne den Eintrag auf
demselben Wert. Welcher Haken unten aus welchem Grund offen steht, sagt der Absatz nach der
Checkliste.

**Datum angelegt:** 2026-08-28. **Letzte Prüfung:** 2026-08-30 (Auflösung durch
[slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md): Eintrag
gesetzt, Restbreite bewacht, Befund fort — s. §Geschichte). **Vorherige Prüfung:** 2026-08-30
(derselbe Tag, Werkzeug-Aussage korrigiert).

**Betroffenes Gate:** `docs-check` (Modul `links`) und damit `gates`.

**Geltungsbereich:** **genau eine Referenz** — der Beleg auf
`modul-08-agentenrollen.md §Rollen-Sequenz für einen Slice` in
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2. **Extensional geschlossen:** jede weitere unauflösbare Referenz in
`harness/conventions.md` oder anderswo fällt **nicht** unter diesen Carveout. Die heutige Menge
liefert ein Kommando, keine Zahl im Text
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): `grep -cE '\]\([^)]*v3\.5\.2[^)]*\)' harness/conventions.md` — die **Markdown-Links**
in den abgelösten Baum, denn nur sie erzeugen den Befund. Eine Zählung der bloßen **Nennungen**
(`grep -c 'v3\.5\.2' harness/conventions.md`) trifft eine andere und größere Menge: Inline-Pfade
unter `.harness/` liegen außerhalb von `codepaths.roots` (`[spec, docs, harness]`) und bleiben
still — `make docs-check` meldet **1** Befund, während die zweite Zählung am 2026-08-30 **14**
liefert.

**Folge-Slice:** [slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) — er
trägt die Entscheidung an ihre schreibende Rolle und löst diesen Carveout mit seinem Abschluss auf.

Regeln: Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout — ein
Carveout braucht immer einen Auflösungs-Trigger **und** einen Folge-Slice.

---

## Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — technische Begründung, keine
„noch nicht geschafft"-Aussagen.

**Die Referenz ist rot, weil ihr Satz nur über den abgelösten Stand wahr ist.**
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2 hält fest, dass die Baseline die dritte Rolle *Implementation* nennt, während dieses Repo
den Bezeichner `implementer` führt. Gemessen an derselben Zeile beider Bäume — `participant I as
Implementation` gegen `participant I as Implementer` — sagt der gepinnte Stand das Gegenteil. Ein
Nachziehen des Tags machte aus dem toten Link ein **falsches Zitat** bei grünem Gate: genau die
Verwandlung, gegen die [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) geschrieben ist.
Der Eintrag steht zugleich unter der Append-only-Regel des gepinnten Stands
(`grundlagen-harness-dateien.md`: *„Einträge werden nie überschrieben"*).

**Ein referenz-weites Ventil existiert am heutigen Pin `v0.65.0`, zwei weitere Auswege tragen
nicht — alle drei gegen diesen Pin gemessen, nicht aus
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) übernommen (deren
Messung lief gegen `v0.62.0`):**

- **Top-Level `ignore-refs` trägt.** Der d-check-CHANGELOG führt es unter `[0.49.0] — 2026-07-18`
  als *„querschnittliche Top-Level-Fähigkeit, die `links`, `anchors` und `codepaths` gemeinsam
  honorieren"*, mit `in` (Glob auf die Quelldatei), `refs` (Globs auf das aufgelöste Ziel) und
  `keep`; der modul-lokale `codepaths.ignore-refs` bleibt Alias
  (`grep -n 'ignore-refs' /Development/d-check/CHANGELOG.md`, lokaler Klon). Sonde in
  [`.d-check.yml`](../../../../.d-check.yml) mit `in: "harness/conventions.md"` und
  `refs: [".harness/baseline/v3.5.2/**"]`, ein `make docs-check`, danach zurückgenommen:
  `468 Datei(en) geprüft, 0 Befund(e)` — **dieselbe Dateizahl** wie ohne Sonde, das Ventil sitzt
  auf der Referenz-Achse. Beide Skopen sind rot gegengeprobt: mit `in: "AGENTS.md"` und mit
  `refs: [".harness/baseline/v9.9.9/**"]` kehrt der Befund je zurück.
  **Wer unter `links:` nach `ignore-refs` sucht, findet nichts und schließt falsch** —
  `--print-config` gibt eine kommentierte Beispiel-Config aus, keine Schema-Liste.
- Sonde in einer eigenen Plandatei (zwei gebrochene Links, einer mit `d-check:ignore` im echten
  HTML-Kommentar, ein `make docs-check`, danach zurückgenommen): **beide** als `target-missing`
  gemeldet. Das Zeilen-Ventil deckt `links` nicht.
- `scan.ignore` wirkt **datei-weit** (*„prunt den Abstieg"*, Config-Kommentar) und nähme den
  gesamten Konventionsspeicher aus dem Prüfbereich — eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5, die einen sichtbaren Befund gegen einen blinden Fleck
  tauscht.

**Beide Ventile sind Senkungen, sie unterscheiden sich in der Reichweite.** Auch der
`ignore-refs`-Eintrag lockert die Prüfung und braucht nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 sein eigenes Gefäß — nur nimmt er, was `in` **und** `refs`
gemeinsam treffen, statt einer Datei mit allen ihren Verweisen.

**Werkzeug-Wahl (Modul 7 §Werkzeug-Wahl bei Diskrepanz), beide Fragen beantwortet.**
*Granularität:* eine einzelne Referenz, kein Cluster über eine Sub-Area — Modul 7 ordnet den
punktuellen Fund aus einem Freshness-Audit ausdrücklich diesem Werkzeug zu (*„Punktuell behandelt
der Trichter ihn richtig: Übernahme im nächsten Slice, oder Carveout mit Auflösungs-Trigger"*);
eine BF-Markierung setzte *Code führt, Doku folgt* und trifft nicht zu. *Temporalität:* der
Trigger hängt an genau einer Entscheidung mit benannter schreibender Rolle, nicht an einem
unabsehbaren Umbau — also Carveout und keine ADR. **Sollte die Klasse wachsen**, kippt die erste
Antwort; das führt [slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) §6
als Risiko mit Ausgang.

**Warum die Ausnahme und nicht das schnelle Grün.** Der Befund ist **richtig**: er meldet, dass
eine lebende Datei einen Verweis trägt, der nicht mehr auflöst. Ihn zum Verschwinden zu bringen,
ohne die dahinterliegende Frage zu entscheiden, hieße, den einzigen Sensor abzuschalten, der die
Klasse überhaupt sichtbar macht.

## Auflösungs-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — konkret und prüfbar. „Wenn Zeit ist" ist kein Trigger.

**[slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) liegt in `done/`** —
und damit gilt beides zugleich, geprüft mit **zwei** Läufen von `make docs-check` — einem mit dem
Config-Stand nach der Auflösung, einem mit dem davor: die Zeile wird nicht mehr gemeldet, **und**
beide Läufe melden dieselbe Dateizahl. Prüfbar ohne Rückfrage, ohne eine gemerkte Zahl.

**Was den Trigger nicht auslöst:** ein Grün, das durch einen `scan.ignore`-Eintrag entstanden ist —
es fiele an der Dateizahl auf. **Ein leerer Config-Diff ist hier kein Kriterium**: das
Referenz-Ventil aus der Begründung ändert die Config und lässt den Prüfbereich stehen; ein Trigger,
der auf den leeren Diff bestünde, schlösse den einzigen gemessen tragfähigen Weg aus. Der Trigger
fragt nach der entschiedenen Frage und nach dem unverschobenen Prüfbereich, nicht nach der Farbe.

## Geltungs-Konfiguration

**Es ist keine gesetzt, und sie ist auch nicht mehr zu setzen.** Modul 7 verlangt die `CO-<NNN>`
im Gate-Output, damit eine wirkende Ausnahme ihre Begründung trägt — *„sonst ist die Ausnahme eine
stille Senkung ohne Begründung"*. Der Top-Level-`ignore-refs`-Eintrag in
[`.d-check.yml`](../../../../.d-check.yml) ist **nicht** das Gefäß dieses Carveouts: er steht
unter [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md), und jene
Entscheidung nennt ihn ausdrücklich dauerhaft und keinen Carveout. Der Carveout ist damit nicht
konfiguriert, sondern **fort**; eine Kennung im Gate-Output hätte nichts mehr zu begründen.

**Über die ganze Standzeit war keine gesetzt, und das ist der Befund an dieser Datei.** Solange der
Eintrag fehlte, blieb `make docs-check` rot, und diese Datei war der einzige Träger der Begründung:
wer den roten Lauf sah, fand den Grund über die
Befund-Zeile → [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
→ diesen Carveout. Das ist ein lauter Ausschluss und kein leiser — aber die Modul-7-Pflicht blieb
über die Standzeit offen, so wie bei [`CO-004`](CO-004-emitter-klassifikation-offen.md) auch.

| Datei | Zeile/Section | Wert |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | Top-Level `ignore-refs` | **gesetzt, aber nicht als Geltungs-Konfiguration dieses Carveouts.** Der Eintrag nennt `CO-005` nicht; sein Config-Kommentar zeigt auf [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md), die ihn als dauerhafte Ausnahme trägt |

## Verifikation (nach Auflösung)


- [x] `make docs-check` meldet die Zeile nicht mehr — **und** seine Dateizahl ist dieselbe wie die
      eines Laufs ohne den neuen Config-Eintrag. Beide zusammen, nicht das erste allein; verglichen
      wird gegen den zweiten Lauf, nicht gegen eine notierte Zahl. Gefahren 2026-08-30, zwei Läufe
      über demselben Baum: mit Eintrag `469 Datei(en) geprüft, 0 Befund(e)`, ohne Eintrag
      `469 Datei(en) geprüft, 1 Befund(e)`. Dieselbe erste Zahl — das Ventil sitzt auf der
      Referenz-Achse.
- [x] `scan.ignore` in [`.d-check.yml`](../../../../.d-check.yml) trägt keinen neuen Eintrag
      (`git diff` auf die Config). Ein Top-Level-`ignore-refs`-Eintrag darf dort stehen, wenn ihn
      eine ADR trägt ([`AGENTS.md`](../../../../AGENTS.md) §3.5) und `in` wie `refs` je eine rote
      Gegenprobe haben. Gefahren 2026-08-30: der Config-Diff ist rein additiv und berührt die
      `ignore:`-Zeile nicht; beide Skopen sind rot gegengeprobt (`in: "AGENTS.md"` und
      `refs: [".harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md"]` liefern je
      `469 Datei(en) geprüft, 1 Befund(e)`), und die Ausnahme trägt
      [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md).
- [ ] `make gates` grün ohne Ausnahme.
- [x] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`) — vollzogen am
      2026-08-30: der Move als eigener Commit, der Link-Abgleich der Verweise als zweiter
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
- [x] Index-Zeile in [`README.md`](../README.md) von *Aktiv* nach *Aufgelöst* umgehängt, mit Datum und
      auflösendem Slice (2026-08-30). Ihr Link zeigt auf `done/`, wie die übrigen Verweise auf diese
      Datei — der Move und ihr Nachziehen liegen in getrennten Commits.
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

**Warum vier Haken stehen und zwei nicht.** Gehakt ist, was über **diesem** Baum wahr ist und je mit
seinem Kommando belegt. Offen ist der Folge-Slice: die Closure von
[slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) schreibt der
**Planner**, nicht der Lauf, der die Config geschrieben hat (Baseline-Regelwerk
`modul-08-agentenrollen.md`). Offen ist auch `make gates` — und der Grund liegt **nicht** in diesem
Carveout: `make docs-check` meldet eine Zeile in
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) selbst, deren
Adresse auf den alten Ort dieser Datei zeigt. Der `git mv` oben hat sie gebrochen; heilen darf sie
nur die Rolle, der eine *Accepted* ADR gehört ([`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.8).
Der Gegenstand dieses Carveouts — der Beleg in
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2 — ist fort und kehrt nicht zurück.
## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-28 | Angelegt — der Baum-Tausch macht einen datierten Beleg im Adaptions-Block unauflösbar, und keiner der drei Werkzeug-Auswege trägt | [slice-081](../../planning/done/slice-081-baum-tauschen-pin-ziehen.md) |
| 2026-08-30 | **Aufgelöst.** [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) autorisiert das geschnittene Referenz-Ventil, [`.d-check.yml`](../../../../.d-check.yml) trägt es (`in` und `refs` je auf einen Dateinamen), und `test/ignore-refs-restbreite.bats` bewacht seine Restbreite in `make gates`. Zwei Läufe über demselben Baum belegen den Trigger: `469 Datei(en) geprüft, 0 Befund(e)` mit Eintrag gegen `469 Datei(en) geprüft, 1 Befund(e)` ohne — dieselbe Dateizahl, kein geschrumpfter Prüfbereich | [slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) |
| 2026-08-30 | **Vollzogen**: `git mv` nach `done/` als eigener Commit, der Link-Abgleich der 77 gebrochenen Verweise als zweiter, Index-Zeile unter *Aufgelöst*. Status-Kopf, Checkliste und Index-Zelle sagen seither dasselbe wie der Ort | [slice-132](../../planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) |

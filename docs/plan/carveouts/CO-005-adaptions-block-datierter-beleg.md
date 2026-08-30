# CO-005: Ein datierter Beleg im Adaptions-Block hat kein auflösbares Ziel

**Status:** Aktiv.

**Datum angelegt:** 2026-08-28. **Letzte Prüfung:** 2026-08-30 — der Befund steht unverändert
(`make docs-check` → `468 Datei(en) geprüft, 1 Befund(e)`), die Werkzeug-Aussage der Begründung
nicht.

**Betroffenes Gate:** `docs-check` (Modul `links`) und damit `gates`.

**Geltungsbereich:** **genau eine Referenz** — der Beleg auf
`modul-08-agentenrollen.md §Rollen-Sequenz für einen Slice` in
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2. **Extensional geschlossen:** jede weitere unauflösbare Referenz in
`harness/conventions.md` oder anderswo fällt **nicht** unter diesen Carveout. Die heutige Menge
liefert ein Kommando, keine Zahl im Text
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): `grep -cE '\]\([^)]*v3\.5\.2[^)]*\)' harness/conventions.md` — die **Markdown-Links**
in den abgelösten Baum, denn nur sie erzeugen den Befund. Eine Zählung der bloßen **Nennungen**
(`grep -c 'v3\.5\.2' harness/conventions.md`) trifft eine andere und größere Menge: Inline-Pfade
unter `.harness/` liegen außerhalb von `codepaths.roots` (`[spec, docs, harness]`) und bleiben
still — `make docs-check` meldet **1** Befund, während die zweite Zählung am 2026-08-30 **14**
liefert.

**Folge-Slice:** [slice-132](../planning/next/slice-132-adaptions-block-ohne-totes-ziel.md) — er
trägt die Entscheidung an ihre schreibende Rolle und löst diesen Carveout mit seinem Abschluss auf.

Regeln: Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout — ein
Carveout braucht immer einen Auflösungs-Trigger **und** einen Folge-Slice.

---

## Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — technische Begründung, keine
„noch nicht geschafft"-Aussagen.

**Die Referenz ist rot, weil ihr Satz nur über den abgelösten Stand wahr ist.**
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2 hält fest, dass die Baseline die dritte Rolle *Implementation* nennt, während dieses Repo
den Bezeichner `implementer` führt. Gemessen an derselben Zeile beider Bäume — `participant I as
Implementation` gegen `participant I as Implementer` — sagt der gepinnte Stand das Gegenteil. Ein
Nachziehen des Tags machte aus dem toten Link ein **falsches Zitat** bei grünem Gate: genau die
Verwandlung, gegen die [`ADR-0016`](../adr/0016-verweis-traegt-tag-und-zitat.md) geschrieben ist.
Der Eintrag steht zugleich unter der Append-only-Regel des gepinnten Stands
(`grundlagen-harness-dateien.md`: *„Einträge werden nie überschrieben"*).

**Ein referenz-weites Ventil existiert am heutigen Pin `v0.65.0`, zwei weitere Auswege tragen
nicht — alle drei gegen diesen Pin gemessen, nicht aus
[`ADR-0017`](../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) übernommen (deren
Messung lief gegen `v0.62.0`):**

- **Top-Level `ignore-refs` trägt.** Der d-check-CHANGELOG führt es unter `[0.49.0] — 2026-07-18`
  als *„querschnittliche Top-Level-Fähigkeit, die `links`, `anchors` und `codepaths` gemeinsam
  honorieren"*, mit `in` (Glob auf die Quelldatei), `refs` (Globs auf das aufgelöste Ziel) und
  `keep`; der modul-lokale `codepaths.ignore-refs` bleibt Alias
  (`grep -n 'ignore-refs' /Development/d-check/CHANGELOG.md`, lokaler Klon). Sonde in
  [`.d-check.yml`](../../../.d-check.yml) mit `in: "harness/conventions.md"` und
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
  [`AGENTS.md`](../../../AGENTS.md) §3.5, die einen sichtbaren Befund gegen einen blinden Fleck
  tauscht.

**Beide Ventile sind Senkungen, sie unterscheiden sich in der Reichweite.** Auch der
`ignore-refs`-Eintrag lockert die Prüfung und braucht nach
[`AGENTS.md`](../../../AGENTS.md) §3.5 sein eigenes Gefäß — nur nimmt er, was `in` **und** `refs`
gemeinsam treffen, statt einer Datei mit allen ihren Verweisen.

**Werkzeug-Wahl (Modul 7 §Werkzeug-Wahl bei Diskrepanz), beide Fragen beantwortet.**
*Granularität:* eine einzelne Referenz, kein Cluster über eine Sub-Area — Modul 7 ordnet den
punktuellen Fund aus einem Freshness-Audit ausdrücklich diesem Werkzeug zu (*„Punktuell behandelt
der Trichter ihn richtig: Übernahme im nächsten Slice, oder Carveout mit Auflösungs-Trigger"*);
eine BF-Markierung setzte *Code führt, Doku folgt* und trifft nicht zu. *Temporalität:* der
Trigger hängt an genau einer Entscheidung mit benannter schreibender Rolle, nicht an einem
unabsehbaren Umbau — also Carveout und keine ADR. **Sollte die Klasse wachsen**, kippt die erste
Antwort; das führt [slice-132](../planning/next/slice-132-adaptions-block-ohne-totes-ziel.md) §6
als Risiko mit Ausgang.

**Warum die Ausnahme und nicht das schnelle Grün.** Der Befund ist **richtig**: er meldet, dass
eine lebende Datei einen Verweis trägt, der nicht mehr auflöst. Ihn zum Verschwinden zu bringen,
ohne die dahinterliegende Frage zu entscheiden, hieße, den einzigen Sensor abzuschalten, der die
Klasse überhaupt sichtbar macht.

## Auflösungs-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — konkret und prüfbar. „Wenn Zeit ist" ist kein Trigger.

**[slice-132](../planning/next/slice-132-adaptions-block-ohne-totes-ziel.md) liegt in `done/`** —
und damit gilt beides zugleich, geprüft mit **zwei** Läufen von `make docs-check` — einem mit dem
Config-Stand nach der Auflösung, einem mit dem davor: die Zeile wird nicht mehr gemeldet, **und**
beide Läufe melden dieselbe Dateizahl. Prüfbar ohne Rückfrage, ohne eine gemerkte Zahl.

**Was den Trigger nicht auslöst:** ein Grün, das durch einen `scan.ignore`-Eintrag entstanden ist —
es fiele an der Dateizahl auf. **Ein leerer Config-Diff ist hier kein Kriterium**: das
Referenz-Ventil aus der Begründung ändert die Config und lässt den Prüfbereich stehen; ein Trigger,
der auf den leeren Diff bestünde, schlösse den einzigen gemessen tragfähigen Weg aus. Der Trigger
fragt nach der entschiedenen Frage und nach dem unverschobenen Prüfbereich, nicht nach der Farbe.

## Geltungs-Konfiguration

**Es ist keine gesetzt, und der Ort dafür existiert.** Das ist die genaue Aussage: Modul 7
verlangt, dass die Gate-Konfiguration die `CO-<NNN>` im Gate-Output nennt — *„sonst ist die
Ausnahme eine stille Senkung ohne Begründung"* —, und ein Top-Level-`ignore-refs`-Eintrag in
[`.d-check.yml`](../../../.d-check.yml) wäre dieser Ort (Messung oben). **Ob er gesetzt wird,
entscheidet dieser Carveout nicht:** er lockert die Prüfung auf der Referenz-Achse und ist damit
eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5, die eine ADR braucht — das ist der
Gegenstand von DoD (1) in
[slice-132](../planning/next/slice-132-adaptions-block-ohne-totes-ziel.md), nicht dieser Datei.

**Solange keiner gesetzt ist, gilt das Gegenteil eines leisen Ausschlusses:** **`make docs-check`
bleibt rot**, und diese Datei ist der einzige Träger der Begründung. Wer den roten Lauf sieht,
findet den Grund über die
Befund-Zeile → [`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
→ diesen Carveout.

| Datei | Zeile/Section | Wert |
|---|---|---|
| [`.d-check.yml`](../../../.d-check.yml) | Top-Level `ignore-refs` | **nicht gesetzt.** Der Schlüssel trägt die Ausnahme (`in` + `refs`, gemessen); ihn zu setzen ist eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 und verlangt die ADR aus [slice-132](../planning/next/slice-132-adaptions-block-ohne-totes-ziel.md) DoD (1) |

## Verifikation (nach Auflösung)


- [ ] `make docs-check` meldet die Zeile nicht mehr — **und** seine Dateizahl ist dieselbe wie die
      eines Laufs ohne den neuen Config-Eintrag. Beide zusammen, nicht das erste allein; verglichen
      wird gegen den zweiten Lauf, nicht gegen eine notierte Zahl.
- [ ] `scan.ignore` in [`.d-check.yml`](../../../.d-check.yml) trägt keinen neuen Eintrag
      (`git diff` auf die Config). Ein Top-Level-`ignore-refs`-Eintrag darf dort stehen, wenn ihn
      eine ADR trägt ([`AGENTS.md`](../../../AGENTS.md) §3.5) und `in` wie `refs` je eine rote
      Gegenprobe haben.
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`).
- [ ] Index-Zeile in [`README.md`](README.md) von *Aktiv* nach *Aufgelöst* umgehängt, mit Datum und
      auflösendem Slice.
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-28 | Angelegt — der Baum-Tausch macht einen datierten Beleg im Adaptions-Block unauflösbar, und keiner der drei Werkzeug-Auswege trägt | [slice-081](../planning/done/slice-081-baum-tauschen-pin-ziehen.md) |
| 2026-08-30 | Geprüft — der Befund steht (`468 … 1 Befund(e)`), die Werkzeug-Aussage der Zeile darüber nicht: ein **referenz-weites** Ventil trägt am Pin `v0.65.0`, seit `[0.49.0]` als Top-Level-Schlüssel. Geltungsbereich auf die Markdown-Links verengt, Geltungs-Konfiguration von *existiert nicht* auf *nicht gesetzt*, Auflösungs-Trigger vom leeren Config-Diff auf die unverschobene Dateizahl | [slice-132](../planning/next/slice-132-adaptions-block-ohne-totes-ziel.md) |

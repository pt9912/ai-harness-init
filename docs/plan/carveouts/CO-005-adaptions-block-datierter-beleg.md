# CO-005: Ein datierter Beleg im Adaptions-Block hat kein auflösbares Ziel

**Status:** Aktiv.

**Datum angelegt:** 2026-08-28. **Letzte Prüfung:** 2026-08-28 (angelegt).

**Betroffenes Gate:** `docs-check` (Modul `links`) und damit `gates`.

**Geltungsbereich:** **genau eine Referenz** — der Beleg auf
`modul-08-agentenrollen.md §Rollen-Sequenz für einen Slice` in
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2. **Extensional geschlossen:** jede weitere unauflösbare Referenz in
`harness/conventions.md` oder anderswo fällt **nicht** unter diesen Carveout. Die heutige Menge
liefert ein Kommando, keine Zahl im Text
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): `git grep -c 'baseline/v3\.5\.2/' harness/conventions.md`.

**Folge-Slice:** [slice-132](../planning/open/slice-132-adaptions-block-ohne-totes-ziel.md) — er
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

**Es ist keine Werkzeug-Lücke, die man umkonfigurieren könnte — dreimal gegen den heutigen Pin
`v0.65.0` gemessen, nicht aus [`ADR-0017`](../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
übernommen (deren Messung lief gegen `v0.62.0`):**

- `--print-config` des gepinnten Digests zeigt für `links` **genau eine** Option (`resolve-from`).
  `ignore-refs` existiert, aber unter `codepaths`; `exempt-paths` unter `ids`, `matrix`, `diagrams`
  und `versions`. Für `links` gibt es **keine** Referenz-Ausnahme.
- Sonde in einer eigenen Plandatei (zwei gebrochene Links, einer mit `d-check:ignore` im echten
  HTML-Kommentar, ein `make docs-check`, danach zurückgenommen): **beide** als `target-missing`
  gemeldet. Das Zeilen-Ventil deckt `links` nicht.
- `scan.ignore` wirkt **datei-weit** (*„prunt den Abstieg"*, Config-Kommentar) und nähme den
  gesamten Konventionsspeicher aus dem Prüfbereich — eine Senkung nach
  [`AGENTS.md`](../../../AGENTS.md) §3.5, die einen sichtbaren Befund gegen einen blinden Fleck
  tauscht.

**Werkzeug-Wahl (Modul 7 §Werkzeug-Wahl bei Diskrepanz), beide Fragen beantwortet.**
*Granularität:* eine einzelne Referenz, kein Cluster über eine Sub-Area — Modul 7 ordnet den
punktuellen Fund aus einem Freshness-Audit ausdrücklich diesem Werkzeug zu (*„Punktuell behandelt
der Trichter ihn richtig: Übernahme im nächsten Slice, oder Carveout mit Auflösungs-Trigger"*);
eine BF-Markierung setzte *Code führt, Doku folgt* und trifft nicht zu. *Temporalität:* der
Trigger hängt an genau einer Entscheidung mit benannter schreibender Rolle, nicht an einem
unabsehbaren Umbau — also Carveout und keine ADR. **Sollte die Klasse wachsen**, kippt die erste
Antwort; das führt [slice-132](../planning/open/slice-132-adaptions-block-ohne-totes-ziel.md) §6
als Risiko mit Ausgang.

**Warum die Ausnahme und nicht das schnelle Grün.** Der Befund ist **richtig**: er meldet, dass
eine lebende Datei einen Verweis trägt, der nicht mehr auflöst. Ihn zum Verschwinden zu bringen,
ohne die dahinterliegende Frage zu entscheiden, hieße, den einzigen Sensor abzuschalten, der die
Klasse überhaupt sichtbar macht.

## Auflösungs-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — konkret und prüfbar. „Wenn Zeit ist" ist kein Trigger.

**[slice-132](../planning/open/slice-132-adaptions-block-ohne-totes-ziel.md) liegt in `done/`** —
und damit gilt beides zugleich: `make docs-check` meldet die Zeile nicht mehr, **und** `git diff`
auf [`.d-check.yml`](../../../.d-check.yml) ist leer. Prüfbar ohne Rückfrage, mit zwei Kommandos.

**Was den Trigger nicht auslöst:** ein Grün, das durch einen `scan.ignore`-Eintrag entstanden ist.
Der Trigger fragt nach der entschiedenen Frage, nicht nach der Farbe — deshalb steht der leere
Config-Diff als zweite Hälfte daneben und nicht als Fußnote.

## Geltungs-Konfiguration

**Es gibt keine.** Das ist der Befund, nicht eine Auslassung: Modul 7 verlangt, dass die
Gate-Konfiguration die `CO-<NNN>` im Gate-Output nennt — *„sonst ist die Ausnahme eine stille
Senkung ohne Begründung"*. Für das Modul `links` existiert am gepinnten Pin **kein** Ort, an dem
das ginge (Begründung oben, dreifach gemessen). Die Folge ist ausdrücklich **nicht** ein leiser
Ausschluss, sondern das Gegenteil: **`make docs-check` bleibt rot**, und diese Datei ist der
einzige Träger der Begründung. Wer den roten Lauf sieht, findet den Grund über die
Befund-Zeile → [`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
→ diesen Carveout.

| Datei | Zeile/Section | Wert |
|---|---|---|
| — | — | keine Gate-Konfiguration; das Modul `links` trägt keine Referenz-Ausnahme, und `scan.ignore` wäre datei-weit |

## Verifikation (nach Auflösung)


- [ ] `make docs-check` meldet die Zeile nicht mehr — **und** `git diff` auf
      [`.d-check.yml`](../../../.d-check.yml) ist leer. Beide zusammen, nicht das erste allein.
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`).
- [ ] Index-Zeile in [`README.md`](README.md) von *Aktiv* nach *Aufgelöst* umgehängt, mit Datum und
      auflösendem Slice.
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-28 | Angelegt — der Baum-Tausch macht einen datierten Beleg im Adaptions-Block unauflösbar, und keiner der drei Werkzeug-Auswege trägt | [slice-081](../planning/done/slice-081-baum-tauschen-pin-ziehen.md) |

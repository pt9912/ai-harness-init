# ADR-0087: Der Fingerabdruck gilt auch für das Emittierte — die Erfassung folgt dem Lastenheft, nicht der Ebenen-Schärfe

**Status:** Proposed

**Datum:** 2026-10-08

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang)
(§Redaktion: *„eine Ableitung (Pfad, Länge, Fingerabdruck)"*; *„Ausdrücklich nicht zugesagt ist
… dass der Bestand geschützt ist"*),
[ADR-0011](0011-telemetrie-erfassung-policy.md) und
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (teilweise abgelöst, siehe
§Supersedes),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)

**Schärft:** [`SPEC-018`, `SPEC-029`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
(`sha256_16` aus dem Dateisystem für die Schreib-Werkzeuge — ohne Ebenen-Vorbehalt, auf beiden
Ebenen).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR);
`modul-08-agentenrollen.md` §Rollen-Regeln.

**Supersedes (Teil):** [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2 in allen drei Stellen, die den Hash an die Ebene binden — die Überschriften-Wendung *„und die Schärfe ist je Ebene verschieden"*, die Tabellenzelle *„Pfad + Länge; im Repo zusätzlich ein Inhalts-Hash"* (geltende Fassung: *Pfad + Länge + Inhalts-Hash, auf beiden Ebenen*) und die Wendung *„und ohne Inhalts-Hash"* samt dem Satz über das Bestätigungs-Orakel —, und Festlegung 5, die Wendung *„abgeleitete Werte **ohne** Inhalts-Hash"*; [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6, die Wendung *„**ohne** Inhalts-Hash"*. Alles Übrige beider Dateien gilt fort — auch *„bleibt die Länge"*.

---

## Kontext

Gemessen am Stand dieses Commits (keine Erwartungswerte,
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
sed -n '/^### .* — Redaktion und Erfassungs-Umfang$/,/^### .* — Rolle der Erfassung$/p' spec/lastenheft.md | grep -c 'Fingerabdruck'  # 1
grep -c 'sha256_16' spec/spezifikation.md                                    # 5
grep -c 'ohne Inhalts-Hash' docs/plan/adr/0011-telemetrie-erfassung-policy.md # 1
grep -c 'Ebene' internal/span/emit.go                                         # 0
```

Rang 1, Rang 2 und der Träger setzen den Fingerabdruck für Schreib-Werkzeuge, zwei
*Accepted*-Entscheidungen schließen ihn für das Emittierte aus. Der Träger ist auf beiden Ebenen
**dasselbe Binär** ([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 1); eine Lesart, die die Schärfe je Ebene trennt, hätte keinen Code, der sie hält.
Gegenstand ist allein der Fingerabdruck — Länge und erstes Token behält ADR-0011 für das
Emittierte ausdrücklich. Die Frage stellt `slice-107-inhalts-hash-traegt-eine-entscheidung`.

## Entscheidung

**1. Der Fingerabdruck (`sha256_16`) wird für Schreib-Werkzeuge auf beiden Ebenen erfasst, wie
Lastenheft, Spezifikation und Träger es tun.** Kein Laufzeit-Schalter je Ebene; das Binär bleibt
eines.

**2. Grund.** Das Lastenheft nennt den Fingerabdruck als Ableitung und schließt die Schutz-Zusage
für den Bestand **ausdrücklich** aus; ein Verbot auf Entscheidungs-Ebene läge dagegen, ohne dass
die Vertrags-Ebene es trägt. Das Orakel-Argument aus ADR-0011 trägt schwächer, als es dort steht:
der Hash ist ein 64-bit-Präfix über den **ganzen Dateiinhalt** aus dem Dateisystem, kein Hash eines
Argument-Werts; er bestätigt einen Verdacht nur, wo der ganze Inhalt erratbar ist. Der typische
Fall ist genau das: eine Datei, die nur ein Secret trägt (`KEY=<wert>`), macht „Inhalt erraten"
zu „Secret erraten", und vor einer Rotation bestätigt der Hash einen gültigen Wert. Dieses Restrisiko ist ein **akzeptiertes Negativ**
(§Konsequenzen), kein offener Posten.

**3. Was die Entscheidung nicht ändert.** Kein Code, keine Spezifikation, keine Feldliste — sie
zieht zwei Entscheidungs-Sätze auf den Stand, den der Vertrag schon führt. Das Lastenheft bleibt
unberührt ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).

**Offene Entscheidung des Auftraggebers** (nicht vorentschieden):

- **Annehmen** (Empfehlung) — diese ADR wird `Accepted`, der Widerspruch ist geschlossen.
- **Ablehnen zugunsten des Hash-Verbots** — dann ist das Lastenheft falsch, und der Weg ist ein
  Change Request, den nur der Auftraggeber annimmt ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)). Text dafür: [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang) §Redaktion: *„
  ‚eine Ableitung (Pfad, Länge, Fingerabdruck)' wird zu ‚eine Ableitung (Pfad, Länge); ein
  Fingerabdruck des Inhalts wird nicht erfasst'."* Diese ADR wird dann `Rejected`, und ein Slice
  entfernt `sha256_16` aus Träger, Feldliste und `SPEC-018`/`SPEC-029`. Weil das Binär eines ist,
  fällt der Hash dabei **auch im Repo** weg, den ADR-0011 Festlegung 2 dort setzt; dieser Weg
  braucht darum zusätzlich eine eigene ADR, die die Repo-Hälfte von Festlegung 2 ablöst — sonst
  liefe der Entfern-Slice gegen eine aktive Entscheidung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| **A — Entscheidung folgt Rang 1 (diese ADR)** | null Code; vier Quellen sagen dasselbe; Adopter-Vertrag seit der Feldliste im Ziel unverändert | Orakel-Restrisiko bei erratbarem ganzem Dateiinhalt (akzeptiert) |
| B — Hash fällt (CR am Lastenheft) | kein Orakel im Ziel | CR + Änderung an Träger, Feldliste, Spezifikation; „hat sich der Inhalt geändert" bei gleicher Länge nicht mehr beantwortbar |
| C — Lesart „Schärfe je Ebene" | keine neue ADR | der Träger kennt keine Ebene; die Lesart wäre eine Behauptung ohne Code |
| D — Laufzeit-Schalter je Ebene | beide Sätze wahr | neues Verhalten desselben Binärs; Dogfood belegte das Ziel nicht mehr ([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 1) |

## Konsequenzen

- Positiv: eine geltende Fassung; kein Diff außerhalb der Entscheidungs-Ablage.
- Negativ (akzeptiert): wer den Span-Bestand eines Ziels liest, kann für eine geschriebene Datei
  einen vollständig erratenen Inhalt bestätigen — im typischen Fall einer Ein-Secret-Datei
  (`KEY=<wert>`) also einen geratenen, noch gültigen Secret-Wert. Angenommen dennoch, weil
  (1) das Lastenheft den Bestand ausdrücklich nicht schützt und die Grenze dort steht, (2) der
  Hash nur einen **Kandidaten** bestätigt und nichts preisgibt — gegen ein Secret voller Entropie
  ist Raten aussichtslos, das Restrisiko trifft schwache Secrets —, und (3) wer die Span-Datei am
  Ort lesen kann, die Datei selbst lesen kann (ADR-0011 §Bedrohungsmodell); offen bleibt die
  Weitergabe des Bestands. Kippen würde die Abwägung, wenn der Hash über einen Argument-Wert statt
  den ganzen Inhalt liefe (§Re-Evaluierungs-Trigger).
- Folgepflicht beim Accept: Marke in den Index-Zeilen von ADR-0011 und ADR-0022.

## Fitness Function (falls maschinell prüfbar)

| Aussage | Sensor | Rot herstellbar |
|---|---|---|
| der Träger setzt `sha256_16` für ein Schreib-Werkzeug | `TestWriteToolGetsFingerprintFromFilesystem` (`internal/span/span_test.go`, in `make test`) | Zuweisung von `Sha256Prefix` in `internal/span/emit.go` entfernt → `make test-go` rc=2, `--- FAIL: TestWriteToolGetsFingerprintFromFilesystem`, `sha256_16 = ""` |

Lücke: dass **kein Ebenen-Schalter** entsteht, hält kein Sensor; ein Test, der ihn verbietet,
hielte eine Formulierung. Träger ist diese Datei. Ein Fall in `test/mutations/` für die Zeile
besteht nicht.

## Re-Evaluierungs-Trigger

- Ein Change Request ändert die Redaktions-Zeile von [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang).
- Der Fingerabdruck wird über etwas anderes als den ganzen Dateiinhalt gebildet (etwa über einen
  Argument-Wert) — dann trifft das Orakel-Argument voll.
- Das Lastenheft nimmt eine Schutz-Zusage für den Span-Bestand auf.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-08 | Proposed | `slice-107-inhalts-hash-traegt-eine-entscheidung` |

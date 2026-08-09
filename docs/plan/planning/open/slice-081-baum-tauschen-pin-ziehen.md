# Slice slice-081: Baum tauschen, Pin ziehen, Verweise nachziehen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
[ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) (dieser Slice ist ihre Folgepflicht 1).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

`.harness/baseline/v5.3.1/` ist der **einzige** vendored Baum, der Tag steht an jedem Ort, der ihn
mechanisch trägt — **und kein lebender Verweis zeigt mehr in den alten.**

Der mechanische Teil ist klein und eng gekoppelt: `BASELINE_TAG` und `BASELINE_ZIP_SHA256` im
[`Makefile`](../../../../Makefile), `DefaultTag` und `DefaultBaselineSHA256` in
`internal/fetch/baseline.go`, die `sources`-URL des gepinnten Assets in `.d-check.yml`. Die beiden
Go-Konstanten hängen per Test am `Makefile` (`TestDefaultTag_MatchesBaseline`,
`TestDefaultBaselineSHA256_MatchesMakefile`) — eine halbe Migration fällt dort auf.

Der große Teil sind die Verweise, und sie zerfallen in Klassen, die verschieden behandelt werden
([ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md)). **Gate-sichtbar sind 21**
Markdown-Links — gefahren, nicht hochgerechnet: Baum auf `v5.3.0` umbenannt, `make docs-check`,
zurückbenannt, Ergebnis `309 Datei(en) geprüft, 21 Befund(e)`, alle `target-missing` (2026-08-09).
Die Sonde lief gegen den damaligen Zielnamen; der Befund hängt am **alten** Tag, nicht am neuen —
unter jedem anderen Zielnamen fällt dieselbe Zahl.

- **16 werden nachgezogen** —
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) 12,
  [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) 4.
- **1 bleibt byte-gleich** — [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) ist
  Accepted und damit unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Sie wird nicht
  repariert; ihre Datei tritt als einziger neuer `scan.ignore`-Eintrag aus dem Doku-Gate.
- **4 verlieren ihre Adresse, nicht ihren Text** — zwei in
  `docs/plan/planning/done/slice-076-mr-018-umzug-technik-stratum.md`, je eine in
  `docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md` und
  `docs/reviews/2026-07-26-slice-050-verification.md`.

Dazu **17 stumme** Inline-Nennungen. **11 davon sind lebend** und werden gezogen
([`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) 7, je 1 in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder),
[ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md),
[slice-071](slice-071-cache-zaehler-getrennt.md) und
[welle-09](../welle-09-modul-15-konformitaet.md) — die letzten beiden liegen zum
Ausführungszeitpunkt in `done/` und sind dann Zeitdokumente, dann sind es 9). Die übrigen **6**
stehen in Accepted-ADRs ([ADR-0011](../../adr/0011-telemetrie-erfassung-policy.md) 1,
[ADR-0012](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) 3,
[ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) 2) und bleiben unberührt.

Dazu drei Fixture-Namen in `test/sessionstart.bats`, die `grundlagen-konventionen.md` heißen.

## 2. Definition of Done

- [ ] `.harness/baseline/v5.3.1/` ist das **einzige** `<tag>`-Verzeichnis, und `make baseline-verify`
      meldet `v5.3.1 OK — 51 Dateien` (heute: `v3.5.2 OK — 42 Dateien`). Der alte Tag steht danach
      an **keiner** der fünf mechanischen Stellen mehr (`Makefile` ×2, `internal/fetch` ×2,
      `.d-check.yml`). **Nicht** in Scope: die auf `v3.5.2` gepinnten Kurs-URLs in den
      Lifecycle-Köpfen bestehender Slices — sie sind Instanzen einer alten Vorlage und werden nach
      der Append-only-Logik nicht rückwirkend umgeschrieben.
- [ ] Die **21** gate-sichtbaren Befunde tragen je den Ausgang ihrer Klasse aus
      [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md): **16** Links zeigen auf den neuen
      Baum — neuer Tag **und** neuer Dateiname, **jeder Anker einzeln gegen die Zieldatei geprüft,
      kein `sed` über den Tag-String**; **1** ([`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md))
      bleibt byte-gleich und ihre Datei ist **der einzige neue** `scan.ignore`-Eintrag in
      `.d-check.yml` — mit Begründung und ADR-Zeiger im Config-Kommentar, und
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
      führt Zahl, Klassifikation und die Aufnahme-Grenze nach; **4** Adressen in drei Zeitdokumenten
      entfallen, während ihr sichtbarer Text Zeichen für Zeichen stehen bleibt. Die lebenden
      Inline-Nennungen sind ebenso gezogen, die **6** in Accepted-ADRs unberührt — sie sieht kein
      Gate, also zählt dort die Liste, nicht das Grün.
- [ ] **Alle vier** Kopplungs-Zähne sind **rot gesehen**: je eine Sonde bumpt nur eine Seite, und
      der zugehörige Sensor fällt ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — zwei Go-Tests
      (`TestDefaultTag_MatchesBaseline`, `TestDefaultBaselineSHA256_MatchesMakefile`) und zwei
      bats-Fälle über `.d-check.yml` ↔ `Makefile` (`sources-url` trägt den aktuellen
      `BASELINE_TAG`, `sources-sha256` gleicht `BASELINE_ZIP_SHA256` —
      [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)).
- [ ] `make gates` grün.
- [ ] Doku-Update: die Baseline-Zeilen in `harness/conventions.md` §Baseline und der
      Herkunfts-Absatz in `docs/user/benutzerhandbuch.md` nennen den neuen Tag.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/` | ersetzen (alt raus, neu rein, `SHA256SUMS` neu) | ein Tag zur Zeit ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| [`Makefile`](../../../../Makefile) | update | `BASELINE_TAG`, `BASELINE_ZIP_SHA256` — die kanonische Quelle des Tag-Strings |
| `internal/fetch/baseline.go` | update | `DefaultTag`, `DefaultBaselineSHA256`; per Test ans `Makefile` gekoppelt |
| `.d-check.yml` | update | `sources`-URL des gepinnten Assets (`make regelwerk-check`); **und** der eine `scan.ignore`-Eintrag aus [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 — eine namentlich genannte Datei, jeder weitere Eintrag ist eine eigene Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und gehört nicht in diesen Slice |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder), [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) | update | die 16 nachziehbaren Links und die lebenden Inline-Nennungen; dazu [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) als Zähl- und Klassifikations-Ort der `scan.ignore`-Einträge |
| [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) | update | *Proposed*, fällt nicht unter [`AGENTS.md`](../../../../AGENTS.md) §3.4 — eine lebende Inline-Nennung. Die vier Accepted-ADRs bleiben byte-gleich |
| `docs/plan/planning/done/slice-076-mr-018-umzug-technik-stratum.md`, `docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md`, `docs/reviews/2026-07-26-slice-050-verification.md` | update (nur Adresse) | Festlegung 5: der Markdown-Link wird zur reinen Nennung. Wer hier einen Satz ändert, verstößt gegen ihre Begründung |
| `test/sessionstart.bats` | update | drei Fixture-Namen heißen `grundlagen-konventionen.md` |

## 4. Trigger

[slice-080](slice-080-verweis-ueberlebt-tagwechsel.md) liegt in `done/` und
[ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) ist *Accepted* — die Festlegung, wie ein
Verweis den Tag-Wechsel übersteht, liegt vor dem Wechsel. Der Status ist tragend, nicht formal:
die `scan.ignore`-Aufnahme ist eine Gate-Senkung, und die trägt nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 eine Entscheidung, keinen Vorschlag.

Rückführungen: `in-progress` → `next`, wenn das Nachziehen der Verweise für sich eine Sitzung
sprengt (dann trennt der Schnitt Mechanik und Verweise). `in-progress` → `open`, wenn die
Anker-Einzelprüfung ergibt, dass die Ziel-Fassung eine belegte Aussage nicht mehr trägt — das ist
eine Inhaltsfrage für [slice-082](slice-082-adaptions-durchgang.md), kein Pfad-Tausch. Die zwei
Sensoren aus der Fitness Function von [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md)
sind **nicht** die Bedingung: sie sind dort ausdrücklich einem eigenen Slice zugewiesen.

## 5. Closure-Trigger

DoD vollständig, `make gates` nach dem Tausch grün, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Zwischenzustand ist real und gehört benannt.** Nach diesem Slice steht der Pin auf
  `v5.3.1`, während [`AGENTS.md`](../../../../AGENTS.md) §3.7,
  [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  und [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  weiter über `v3.5.2` sprechen. Diese Sätze sind **datierte Messungen**, keine Links — kein Gate
  sieht sie. Sie fallen mit [slice-082](slice-082-adaptions-durchgang.md). Der Preis dafür, den
  Adaptions-Durchgang nicht in denselben Slice zu packen: das Repo trägt zwischen 081 und 082 eine
  Aussage, deren Bezug gewechselt hat.
- **Nach diesem Slice liegt die alte Form nur noch in der Historie — das ist die Zusage von
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
  nicht ihr Preis.** *„Ein Tag zur Zeit (Ersetzen), Historie liegt in git"*: der Form-Vergleich aus
  [slice-083](slice-083-form-vergleich-pflichtfelder.md) holt die alte Seite dort, mit
  Tree-Operanden statt zwei Verzeichnissen. Was er dafür braucht, ist **der Commit, der den Baum
  getauscht hat** — er steht als jüngster Eintrag in `git log --oneline -- .harness/baseline/`,
  derselben Abfrage, die heute die drei bisherigen Re-Vendors auflistet.
  `harness/tools/baseline-verify.sh` bricht bei mehr als einem `<tag>`-Verzeichnis ab und schützt
  damit die Eindeutigkeit, auf der dieser Zugriff beruht.
- **Der mechanische Tag-Tausch macht aus einem toten Link ein falsches Zitat.** Gemessen an
  Zeile 129 von `modul-07-carveouts.md`: bei `v3.5.2` steht dort *„Slice schlägt Memo"*, bei
  `v5.3.1` ein unverwandter Satz über die Aufgaben des Implementers. Ein `sed` über den Tag-String
  färbt den Gate grün und verschiebt den Fehler von *laut* nach *stumm* — deshalb verlangt die DoD
  die Anker-Einzelprüfung. `grundlagen-konventionen.md` ist der Fall, an dem das auffällt (bei
  `v5.3.1` in sechs Dateien zerlegt); die 15 Links auf `modul-15-observability.md` und
  `modul-08-agentenrollen.md` sind der Fall, an dem es nicht auffällt.
- **`BASELINE_ZIP_SHA256` kommt aus dem Asset, nicht aus dem Baum.** Ein aus dem entpackten
  Verzeichnis gerechneter Hash belegt die Herkunft nicht; die Gegenprobe ist
  `make regelwerk-check` (Netz, außerhalb der Gates).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/`, `harness/`,
`docs/`, `internal/fetch/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
`.harness/baseline/` ist ein vendored Fremd-Blob und wird ersetzt, nicht gepflegt.

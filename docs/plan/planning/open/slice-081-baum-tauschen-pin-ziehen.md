# Slice slice-081: Baum tauschen, Pin ziehen, Verweise nachziehen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline-v5-3-0.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

`.harness/baseline/v5.3.0/` ist der **einzige** vendored Baum, der Tag steht an jedem Ort, der ihn
mechanisch trägt — **und kein lebender Verweis zeigt mehr in den alten.**

Der mechanische Teil ist klein und eng gekoppelt: `BASELINE_TAG` und `BASELINE_ZIP_SHA256` im
[`Makefile`](../../../../Makefile), `DefaultTag` und `DefaultBaselineSHA256` in
`internal/fetch/baseline.go`, die `sources`-URL des gepinnten Assets in `.d-check.yml`. Die beiden
Go-Konstanten hängen per Test am `Makefile` (`TestDefaultTag_MatchesBaseline`,
`TestDefaultBaselineSHA256_MatchesMakefile`) — eine halbe Migration fällt dort auf.

Der große Teil sind die Verweise: **17 gate-sichtbare** Markdown-Links in drei Dateien
([`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) 12,
[`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) 4,
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) 1) und **17 stumme** Inline-Nennungen,
dazu drei Fixture-Namen in `test/sessionstart.bats`, die `grundlagen-konventionen.md` heißen.

## 2. Definition of Done

- [ ] `.harness/baseline/v5.3.0/` ist das **einzige** `<tag>`-Verzeichnis, und `make baseline-verify`
      meldet `v5.3.0 OK — 51 Dateien` (heute: `v3.5.2 OK — 42 Dateien`). Der alte Tag steht danach
      an **keiner** der fünf mechanischen Stellen mehr (`Makefile` ×2, `internal/fetch` ×2,
      `.d-check.yml`). **Nicht** in Scope: die auf `v3.5.2` gepinnten Kurs-URLs in den
      Lifecycle-Köpfen bestehender Slices — sie sind Instanzen einer alten Vorlage und werden nach
      der Append-only-Logik nicht rückwirkend umgeschrieben.
- [ ] Alle **17** gate-sichtbaren Verweise zeigen auf den neuen Baum, **Datei und Anker aufgelöst**;
      die 17 stummen Inline-Nennungen sind nach der Festlegung aus
      [slice-080](slice-080-verweis-ueberlebt-tagwechsel.md) behandelt — ein Gate sieht sie nicht,
      also zählt hier die Liste, nicht das Grün.
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
| `.d-check.yml` | update | `sources`-URL des gepinnten Assets (`make regelwerk-check`) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder), [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage), `docs/plan/adr/` | update | die 17 gate-sichtbaren Verweise |
| `test/sessionstart.bats` | update | drei Fixture-Namen heißen `grundlagen-konventionen.md` |

## 4. Trigger

[slice-080](slice-080-verweis-ueberlebt-tagwechsel.md) liegt in `done/` — die Festlegung, wie ein
Verweis den Tag-Wechsel übersteht, liegt vor dem Wechsel.

Rückführungen: `in-progress` → `next`, wenn das Nachziehen der Verweise für sich eine Sitzung
sprengt (dann trennt der Schnitt Mechanik und Verweise). `in-progress` → `open`, wenn die
Festlegung aus 080 einen Sensor verlangt, den es noch nicht gibt.

## 5. Closure-Trigger

DoD vollständig, `make gates` nach dem Tausch grün, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Zwischenzustand ist real und gehört benannt.** Nach diesem Slice steht der Pin auf
  `v5.3.0`, während [`AGENTS.md`](../../../../AGENTS.md) §3.7,
  [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  und [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  weiter über `v3.5.2` sprechen. Diese Sätze sind **datierte Messungen**, keine Links — kein Gate
  sieht sie. Sie fallen mit [slice-082](slice-082-adaptions-durchgang.md). Der Preis dafür, den
  Adaptions-Durchgang nicht in denselben Slice zu packen: das Repo trägt zwischen 081 und 082 eine
  Aussage, deren Bezug gewechselt hat.
- **Die Ziel-Prozedur will beide Bäume nebeneinander, dieses Repo lässt das nicht zu.**
  `harness/tools/baseline-verify.sh` bricht bei mehr als einem `<tag>`-Verzeichnis ab
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache):
  ein Tag zur Zeit). Der Form-Vergleich aus [slice-083](slice-083-form-vergleich-pflichtfelder.md)
  läuft deshalb **außerhalb des Arbeitsbaums**. Der Konflikt ist benannt, nicht aufgelöst — wer ihn
  auflösen will, tut das in einem eigenen Slice.
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

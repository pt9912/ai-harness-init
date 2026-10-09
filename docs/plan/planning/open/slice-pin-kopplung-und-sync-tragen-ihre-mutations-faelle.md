# Slice slice-pin-kopplung-und-sync-tragen-ihre-mutations-faelle: Die d-check-Pin-Kopplung und die `sync`-eigenen Wächter tragen ihre Mutations-Fälle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(§Fitness Function: die Wächter von `sync` fallen unter `make mutate`),
[`MR-061`](../../../../harness/conventions.md#mr-061),
[`MR-071`](../../../../harness/conventions.md#mr-071),
[`MR-025`](../../../../harness/conventions.md#mr-025),
[`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `test/mutations/` bekommt die fehlenden Fälle für zwei Wächter-Gruppen, die heute nur an
einmal rot gesehenen Tests hängen — die Kopplung des d-check-Pins (`TestDefaultImage_MatchesCanonical`,
`TestDefaultDigest_MatchesCanonical` in `internal/emit/emit_test.go`) und die `sync`-eigenen Wächter
von `harness/tools/tap-nachzug.sh` und `harness/tools/tap-nachzug-nutzlast.sh`. Beides sind Daten im
Fall-Satz, kein Treiber-Code.

**Übernimmt:** `slice-pin-kopplung-bekommt-ihren-mutations-fall`,
`slice-sync-waechter-tragen-mutations-faelle`. Die Wächter-Liste von `sync` (Schritte b–g) und die Naht
zwischen ihnen stehen in deren §1/§4 in `done/`.

**Stand vor dem Slice** (2026-10-09, keine Erwartungswerte):
`grep -rln 'DCHECK_DIGEST\|DefaultDigest\|MatchesCanonical' test/mutations/ | wc -l` → 0;
`grep -l 'sync' test/mutations/*.sh | wc -l` → 0. Der Greift-Modus `make mutate-greift`
(`slice-mutations-anker-greift-in-den-gates`) hält, ob vorhandene Fälle greifen; fehlende legt er
nicht an.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Ein Sensor, der Wächter ohne Fall zählt — Folge-Slice
  `slice-der-mutations-treiber-sieht-bindung-und-abdeckung`.
- Kopplung der Fallbacks und des Digests gegen den Tag —
  `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`, anderer Gegenstand.
- `internal/emit/emit_test.go`, `harness/tools/mutate.sh` und das Verhalten von `sync` bleiben
  unverändert — Schicht-Abgrenzung; ein Fall, der ein fehlendes Verhalten fordert, ist ein Befund.
- Der Schreib-Pfad am realen Tap — ohne Schreibzugriff auf ein Fremd-Repo nicht herstellbar
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  §Grenze); die Fälle fahren die nachgebildete Schnittstelle der bats-Fälle.

## 2. Definition of Done

Jeder Fall: `# files:`, `# expect:`, `# verify:`, `sed`-Anker gegen den Quell-Bestand gemessen
([`MR-071`](../../../../harness/conventions.md#mr-071)), einmal rot gesehen mit gelesener Meldung,
Gegenprobe *Zusicherung entfernen, Schwächung bleibt* (grün heißt bindet). Wo ein Bestandsfall den
Wächter schon bindet, entsteht kein zweiter.

- [ ] **(1) Pin-Kopplungs-Fall:** die Mutation setzt nur die Pin-Zeilen in `d-check.mk` auf einen
      fremden Tag und Digest; `# expect:` nennt beide Kopplungs-Tests. **Rot:** kein Name färbt, oder
      der Fall färbt auch ohne einen der beiden Namen unverändert.
- [ ] **(2) `sync`-Fälle für die Schritte b–e:** Fehlt-Nachweis, Tag-Formprüfung, Vorwärts-Schutz,
      Gleichstands-Vergleich, Feldform der `version`-Zeile, Idempotenz-Zweig — je Wächter ein Fall,
      `# expect:` nennt den rot werdenden Fall in `test/tap-nachzug.bats`.
- [ ] **(3) `sync`-Fälle für die Schritte f–g und der Absatz *Grenze*:** Optimistik-Stand,
      Nachkontrolle, Header am Schreibaufruf, Meldung nach vollzogenem Schreiben, *abgelehnt* gegen
      *Ausgang ungewiss*; der Absatz *Grenze* in Schritt 7 von `docs/user/releasing.md` nennt die
      Zusagen, die `make mutate` jetzt hält, und die übrigen — jede Zahl neben ihrem Kommando
      ([`MR-025`](../../../../harness/conventions.md#mr-025)). Kein Gate hält `releasing.md` gegen den
      Fall-Bestand; Träger sind Review und Verifier.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/` | neu | die Fälle aus (1)–(3), Nummern im Anschluss an die höchste vergebene |
| `docs/user/releasing.md` | update | Absatz *Grenze* in Schritt 7 (3) |

## 4. Trigger

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice, der Slice ist priorisiert.

**Rückführungen:**

- `in-progress` → `next`: der Review trägt (1)–(3) nicht in einer Sitzung — Naht zwischen (2) und (3).
- `in-progress` → `open`: ein `sync`-Wächter lässt sich nur mit einer Verhaltensänderung an `sync`
  binden.

## 5. Closure-Trigger

DoD (1)–(3) mit gelesenen roten Läufen und Gegenproben; die neuen Fälle als Teillauf
(`make mutate MUTATE_CASES=…`) ohne Befund; Review konform, Verifikation bestätigt; `make gates`
grün; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Pin-Mutation greift zu breit und färbt den Baseline-Pin-Zahn statt der d-check-Kopplung. — **Ausgang:** bei Closure.
- Ein Fall verletzt die Form des Fall-Satzes (Benennung, `# verify:`). — **Ausgang:** bei Closure.
- Ein neuer Fall bindet seine Zusicherung nicht, weil ein zweiter Zweig fängt. — **Ausgang:** bei Closure.
- Der Slice ist für eine Review-Sitzung zu groß. — **Ausgang:** bei Closure.
- Der Absatz *Grenze* altert mit einem weiteren Wächter von `sync` (`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`). — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`) für `test/` und `docs/user/`; erfüllt die
Schwelle. `TOOLS` und `CODEX` nicht berührt (`harness/tools/` bleibt unverändert).

**Vorgelagert — offene Beobachtungen sichten** (2026-10-09, Zähler über `evidence/`, keine
Erwartungswerte): `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` (6) steht für die Instanz
`sync` `geplant` auf diesem Slice; `neuer-waechter-ohne-mutations-fall` (19) führt die Pin-Kopplung als
Instanz, Ausgang beim Folge-Slice oben; `pin-digest-ohne-waechter` (4) hat einen anderen Träger;
`zusage-neben-geaenderter-ableitung-bleibt-stehen` (39) trifft DoD (3). Kein weiterer Folge-Slice.

**Modus:** alle berührten Sub-Areas GF.

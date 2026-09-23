# Welle welle-v021-faehigkeit: Die v0.2.1-Fähigkeit — Zielordner, Release-Prozedur, Skeleton-Struktur und Fall-Anlage-Rule zusammen ziehen

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** —. **Datum:** 2026-09-20.

---

## 1. Welle-Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

**Ziel:** die v0.2.1-Fähigkeit — der Stand, den die Kette seit dem
Zielordner-Slice gezogen hat, zusammen ziehen: der Zielordner-Parameter am
Werkzeug-Dispatch, die `SHA256SUMS`-Emission im Release-Lauf, die
Release-Prozedur in `releasing.md`, die Skeleton-Struktur (Adapter- und
Ports-Ordner unter ihren Rollen-Namen), die Fall-Anlage-Regel
([`MR-071`](../../../../harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md)),
die Mono-Repo-Komposition der unscoped Targets, der Handbuch-Nachzug und die
Tap-Verteilung. Die **Belegbasis** sind die sieben geschlossenen Slices in
`done/`: `slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`,
`slice-release-schnitt-koppelt-pin-und-fassung`,
`slice-releasing-doku-traegt-den-release-vorgang`,
`slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen`,
`slice-stumme-mutations-faelle-folgen-der-config-form`,
`slice-mutations-faelle-pruefen-ihre-ziel-stellen`,
`slice-fall-anlage-misst-gegen-den-quell-bestand`.

### Maschinen-Wechsel

**Was mit `git` reist:** die Historie — Code, Pläne, die `done/`-Slices, das
Beobachtungs-Register, ADRs, MR-Einträge, diese Welle-Datei; ein frischer
Klon trägt den Stand. **Was maschinen-lokal bleibt** (gitignored):
`.harness/state/gates-passed.diffsha` (der Stop-Hook-Stempel) und
`.harness/state/bin/ai-harness-init` (der Träger). Der Stop-Hook bricht auf
dem frischen Klon fail-closed ab — kein Gates-Lauf deckt den Klon; die
Behebung ist einmal `make gates`. Der Träger meldet laut, wenn er fehlt, und
`make traeger-fetch` holt ihn aus dem Release. **Der laufende Agent-Zug
stirbt mit der Session:** der Mono-Repo-Implementier-Lauf ist in-flight —
vor dem Maschinen-Wechsel committet und pusht er; der neue Klon läuft einmal
`make gates`, und die Kette läuft weiter.

## 2. Trigger (Welle startet)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Regeln — ein Trigger ist **beobachtbar** dann, wenn ein *anderer*
Mensch ohne Rückfrage sagen kann, ob er eingetreten ist; ein Datum darf
erwähnt werden, aber nie Trigger sein.

- Die v0.2.1-Release-Kette trägt ihre sieben Slices in `done/` —
  `ls docs/plan/planning/done/ | grep -cE "zielordner|release-schnitt|releasing|adapter-und-ports|stumme-mutations|mutations-faelle-pruefen|fall-anlage"`
  → **7** (gemessen 2026-09-20 bei der Eröffnung).
- Setzung des Auftraggebers vom 2026-09-20: „leg eine Welle an" — die
  restliche Kette läuft als Bündel.

## 3. Closure-Trigger (Welle schließt)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — der Trigger muss das *Mehr* gegenüber den
einzelnen Slice-DoDs benennen.

- Alle Slices der Welle (§4) liegen in `done/`.
- `make gates` grün.
- `make full-smoke` grün (repo-weiter Beleg über die Slice-DoDs hinaus).
- Closure-Notiz in `welle-v021-faehigkeit-results.md`.

## 4. Slices in dieser Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine — der Zustand eines Slice ist sein
Lifecycle-Verzeichnis und wird hier **nicht** gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| slice-unscoped-ziele-kollidieren-nicht-im-mono-repo | Die unscoped-Ziele kollidieren nicht im gemischten Mono-Repo | [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-benutzerhandbuch-nachzug-traegt-fuenf-posten | Der Handbuch-Nachzug trägt die fünf Posten | [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| slice-tap-verteilt-die-release-assets | Das Tap verteilt die Release-Assets | [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) |
| slice-waechter-der-erfassungsschicht-decken-was-sie-sagen | Die Wächter der Erfassungsschicht decken, was sie sagen | [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| slice-lifecycle-werkzeuge-tragen-die-kennung | Die Lifecycle-Werkzeuge tragen die Kennung | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt | Emitter-Aussagen über den Vorlagensatz sind gedeckt | [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) |
| slice-leser-und-aufraeum-waechter-decken-was-sie-sagen | Der Leser- und der Aufräum-Wächter treffen ihre Meldung und sagen ihre Menge | [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

**Nicht Mitglied:** `slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang` trägt in seinem
eigenen Kopf „**Welle:** ohne Welle" mit Begründung — sein Closure-Trigger fordert nichts, was
seine DoD nicht schon belegt (kein repo-weiter Beleg, kein Replay). Die Aufnahme in diese Tabelle
war ein Widerspruch zu dieser Festlegung und ist zurückgenommen; die Korrektur steht im Drift-Log
der Roadmap (`docs/plan/planning/in-progress/roadmap.md` §Historische Trigger-Verschiebungen).

## 5. Abhängigkeiten

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Struktur: fünf Abschnitte.

- Blockiert: die Tap-Verteilung hängt an
  `slice-benutzerhandbook-nachzug-traegt-fuenf-posten` (drei Abhängigkeiten:
  das Tap-Repo als Auftraggeber-Commit, der Workflow-Schritt, der
  Handbuch-Weg — Reihenfolge im Slice-Plan §4).
- Wird blockiert von: keine offene Welle; die sieben Belegbasis-Slices sind
  geschlossen.

## 6. Out-of-Scope für diese Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Eröffnung Schritt 1 — Out-of-Scope gehört zur
Zielsetzung: Was nicht ausdrücklich ausgeschlossen ist, dehnt die Welle, bis
der Closure-Trigger unerreichbar wird.

- **Kein Re-Publish von `v0.2.1`** — die Tag-Kopplung
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2) würde für denselben Stand zweimal vollziehen; der nächste
  Release-Schnitt trägt die Fähigkeit.
- **Keine hexslice-Berührung** — die ist geschlossen
  ([`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
  `Accepted` trägt die Struktur); ein Griff wäre ein zweiter Vorgang.
- **Kein zweiter Fetch-Weg** — der Fetch
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 1) bleibt der Träger-Weg; die Tap-Verteilung ersetzt keinen
  Fetch.
- **Kein Release-Schnitt in dieser Welle** — der Release-Schnitt ist
  geschlossen; ein neuer folgt als eigener wellenloser Posten.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker für Steering-Loop-Regeln — dort die **Ruheort-Regel**: Die
beiden Zeiger unten sind so zu schreiben, wie sie vom Ruheort `done/` auflösen,
nicht vom Schreibort.

Ergebnis: [`welle-v021-faehigkeit-results.md`](welle-v021-faehigkeit-results.md) — Geschwister im
Ruheort `done/`.
Zähler: [`../observations/`](../observations) (Verzeichnis-Form) — eine Ebene über dem Ruheort.
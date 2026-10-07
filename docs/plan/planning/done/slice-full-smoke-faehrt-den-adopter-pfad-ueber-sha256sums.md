# Slice slice-full-smoke-faehrt-den-adopter-pfad-ueber-sha256sums: `full-smoke` fährt den Verifizierungs-Kanal des Adopters über `SHA256SUMS`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md), [ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md). Anlass: LOW-1 zu
`slice-full-smoke-misst-den-emittierten-traeger-pin` ([Review](../../../reviews/2026-10-07-traeger-pin-review.md)).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Stufe 5 von `make full-smoke` (`make traeger-fetch im frischen Klon`) läuft ohne die
geerbten `TRAEGER_SHA256_*` des Dogfood-`Makefile`, nimmt damit den Kanal des Adopters (Laden und
Prüfen der `SHA256SUMS` des Release), und ihre Stufen-Deklaration nennt diesen Kanal.

**Lage** (keine Erwartungswerte): `grep -n 'TRAEGER_SHA256' Makefile` zeigt die Exporte;
`grep -n 'quelle=' internal/emit/templates/enforce/traeger-fetch.sh` die zwei Zweige `Pin` und
Manifest; `grep -n 'klon_traeger_fetch' harness/tools/full-smoke.sh` den Aufruf, der heute nur
`TRAEGER_TAG` entfernt. Den Manifest-Kanal fährt bisher allein `test/traeger-fetch.bats` mit Stubs.
Weil Stufe 5 die Pins erbt, nimmt das emittierte Skript dort den Pin-Zweig; Fall (c) verdreht
genau diesen Pin. Das gepinnte Release trägt `SHA256SUMS` mit allen sechs Einträgen
(`curl -fsSL https://github.com/pt9912/ai-harness-init/releases/download/v0.5.0/SHA256SUMS`).

**Umbau von Fall (c).** Eine Digest-Abweichung im Manifest-Kanal lässt sich am realen Release
nicht herstellen (Asset und `SHA256SUMS` kommen aus demselben Tag). Darum misst (c) den Pin-Kanal
**ausdrücklich**: der Aufruf setzt allein den Pin der Host-Plattform (die übrigen fünf entfernt
`env -u`), und die Meldung muss `aus Pin` nennen. (b) misst den Manifest-Kanal, (c) dass ein
gesetzter Pin ihn schlägt ([ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 3).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Pin-Kanal im Dogfood.** *Bestand bleibt:* `make traeger-fetch` im Dogfood braucht die
  Digest-Pins; entkoppelt wird am Aufruf im Ziel.
- **`TRAEGER_CARRIER` und weitere Exporte.** *Anderer Vorgang:* gemessen wird hier nur der
  Digest-Kanal; ein weiterer Fund geht ins Register (§6).
- **Das Rennen gegen die Publikation.** *Folge-Slice:* `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`.

## 2. Definition of Done

- [x] **1 — Adopter-Kanal:** `klon_traeger_fetch` entfernt zusätzlich die sechs
      `TRAEGER_SHA256_*`; (b) verifiziert damit gegen die `SHA256SUMS` des gepinnten Release.
      **Rot-Werkzeug:** neuer Fall in `test/mutations/` (`files:` das emittierte
      `traeger-fetch.sh`, `verify: full-smoke`), der die Manifest-Adresse bricht
      (`/SHA256SUMS"` → `/SHA256SUMSX"`); `make mutate MUTATE_CASES=<nr>` meldet ihn gebunden, die
      FEHLER-/AUSGANG-Zeile ist gelesen und als `expect:` eingetragen. Gegenprobe: mit
      zurückgenommenem `env -u TRAEGER_SHA256_*` meldet derselbe Lauf den Fall als BEFUND.
- [x] **2 — Fall (c) misst den Pin-Kanal ausdrücklich:** nur der Host-Pin gesetzt, die Prüfung
      verlangt `aus Pin` in der Meldung. **Rot-Werkzeug:** neuer Fall (`verify: full-smoke`), der
      im emittierten Skript den Pin übergeht (`erwartet="$TRAEGER_SHA256"` → `erwartet=""`); (c)
      endet dann mit 0, `make mutate` meldet ihn gebunden, Meldung gelesen.
- [x] **3 — Sicht und Kopf-Sätze:** Deklaration von Stufe 5 und der `GRENZE`-Kommentar von
      `klon_traeger_fetch` nennen beide Kanäle; `make e2e-abdeckung` zieht
      [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) nach; der Laufzeit-Satz in
      `test/mutations/553-…` und `554-…` (und in den zwei neuen Fällen) nennt statt „läuft fast
      voll durch" die Grenze — der Lauf bricht an der Träger-Stufe ab, früh im Lauf — **ohne
      Zahl**: eine Dauer ist das Protokoll eines Laufs und nach `AGENTS.md` §3.7 kein
      Kommentar-Inhalt (INFO-1 des
      [Reviews](../../../reviews/2026-10-07-traeger-pin-review.md)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | `klon_traeger_fetch` ohne Digest-Pins, (c) mit `aus Pin`, Deklaration, `GRENZE` (Liefer-Punkte 1–3) |
| `test/mutations/` | neu ×2, update ×2 | Manifest-Adresse und Pin-Vorrang, `verify: full-smoke`; Laufzeit-Satz in 553/554 — [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | Liefer-Punkt 3 |

Kein Produkt-Code: das emittierte `traeger-fetch.sh` bleibt unverändert, es ist nur Ziel der Mutationen.

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: ohne geerbte Pins erreicht der Kommandozeilen-Pin von (c) das Skript
  nicht (Make-Export), und die Abhilfe verlangt eine Änderung am emittierten Fragment — dann
  getrennt schneiden.
- `in-progress` → `open`: der Manifest-Abruf scheitert am gepinnten Release (Asset fehlt oder
  Eintrag weicht ab) — Übergabe an den Architect.

## 5. Closure-Trigger

1. `make gates` und `make full-smoke` grün, beide neuen Fälle als gebunden gemeldet.
2. Die Meldungen beider Fälle und die Gegenprobe zu Liefer-Punkt 1 gelesen (§7).

## 6. Risiken und offene Punkte

- **Weitere geerbte Exporte** (`TRAEGER_CARRIER`) an derselben Stufe. — **Ausgang:** entfallen — der
  geerbte Wert gleicht dem Default des emittierten Fragments und Skripts
  (`grep -n 'TRAEGER_CARRIER' Makefile internal/emit/templates/enforce/traeger.mk internal/emit/templates/enforce/traeger-fetch.sh`),
  und `make -C "$klon"` löst den relativen Pfad im Klon auf; die Stufe fährt damit den Pfad des
  Adopters. Der `GRENZE`-Kommentar von `klon_traeger_fetch` nennt das Erben.
- **Die Erfolgsmeldung von (b) unterscheidet die Kanäle nicht:** (b) prüft `Digest verifiziert`,
  das in beiden Kanälen gleich lautet; dass (b) den Manifest-Kanal fährt, hält allein der
  Mutationsfall 556 unter `make mutate`, nicht `make gates` (INFO-1 des
  [Reviews](../../../reviews/2026-10-07-sha256sums-review.md)). Grenze, kein Liefer-Punkt.
  — **Ausgang:** weiter offen — Register
  [`BEO-ALL/erfolgs-meldung-nennt-einen-kanal-den-die-ausgabe-nicht-traegt`](../observations/BEO-ALL/erfolgs-meldung-nennt-einen-kanal-den-die-ausgabe-nicht-traegt/observation.md).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** Liefer-Punkte 1–3 bestätigt
  ([Verifikation](../../../reviews/2026-10-07-sha256sums-verifikation.md)); `make full-smoke` EXIT 0.
  Fälle 556 und 557 binden (`make mutate MUTATE_CASES=…` → `2 ok, 0 Befund(e)`); die Gegenprobe ohne
  `env -u TRAEGER_SHA256_*` meldet 556 als BEFUND, die 404 stammt nachweislich vom Manifest-Abruf
  ([Review](../../../reviews/2026-10-07-sha256sums-review.md), Belege).
- **Was ging anders als geplant:** Liefer-Punkt 3 bestellte Messwerte eines Laufs in Kommentaren
  (HIGH-1, [`AGENTS.md`](../../../../AGENTS.md) §3.7); Plan-Korrektur `48a91848`, behoben in `96db3cc1`.
- **Steering-Loop-Eintrag:** benannte Grenze — dass (b) den Manifest-Kanal fährt, hält allein Fall 556
  unter `make mutate`, nicht `make gates`. Gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** neu
  [`BEO-ALL/plan-bestellt-was-eine-hard-rule-verbietet`](../observations/BEO-ALL/plan-bestellt-was-eine-hard-rule-verbietet/observation.md)
  und
  [`BEO-ALL/erfolgs-meldung-nennt-einen-kanal-den-die-ausgabe-nicht-traegt`](../observations/BEO-ALL/erfolgs-meldung-nennt-einen-kanal-den-die-ausgabe-nicht-traegt/observation.md)
  (je 1 Beleg); Beleg an
  [`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  (Stand *verkörpert*, Zielort §3.7 trägt weiter *Ein Wächter existiert nicht*).
- **Folge-Slices:** keine neuen; genannt bleibt `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab` (§1).
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR:
  [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
  [ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) —
  kein Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine entfernt.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-07** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  nichts zu prüfen. (b) *Folge-Slice*: `ls docs/plan/planning/*/<kennung>.md` nennt eine Datei in
  `open/`. (c) *Register*: die drei genannten Pfade existieren, `evidence/` trägt 1, 1 und 20 Dateien.
  Zweite Hälfte über das ganze Register: 3 Verzeichnisse ohne Beleg, namentlich
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `TOOLS` (`harness/tools/full-smoke.sh`) und `*`
(`test/`, `docs/user/`).

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert) — Liefer-Punkt 3
trägt die Teilmessung.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

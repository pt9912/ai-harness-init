# Slice slice-012: Quellen-Wahrheit — tote Pointer und Baseline-Stand

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` — v3.1.0-Konvention
(`modul-05`). Das frühere `**Status:**`-Feld ist bei der Closure entfernt; slice-013
verallgemeinert das und kann diese Datei auslassen.

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-16. **Umgesetzt:** 2026-07-17.

---

## 1. Ziel

Das Repo benennt seine **kanonische Quelle** korrekt und pinnt den adoptierten
Baseline-Stand. Beide externen Pointer sind heute **tot** (am 2026-07-16 per
`curl` verifiziert, HTTP 404):

| Stelle | Aussage heute | Realität |
|---|---|---|
| `AGENTS.md:15`, `harness/conventions.md:18` | „Betriebsregelwerk der adoptierten Baseline" → `raw.githubusercontent.com/…/main/kurs/de/agents-regelwerk.md` | **404** — die Monolith-Datei existiert upstream nicht mehr; als Release-Asset zuletzt in v1.4.0, ab v2.0.0 nicht mehr geliefert; v3.1.0 referenziert sie nirgends |
| `AGENTS.md:33-34` | „Skelett-Vorlagen der Baseline als ZIP" → `releases/latest/download/lab-templates.zip` | **404** — v3.0.0 und v3.1.0 liefern nur noch *ein* login-freies Asset (`lab-regelwerk.zip`); `lab-templates.zip` gibt es zuletzt in v2.0.0 |

Ein Repo, dessen deklarierte Source of Truth 404 liefert, kann seine eigene
Konfliktregel („bei Konflikt gilt die kanonische Quelle") nicht anwenden. Neues
Ziel ist der Kurs unter `/kurs/de/`, gepinnt auf **`v3.1.0`** (Erreichbarkeit vor
dem Commit per `curl` zu belegen); die präsente Form ist die vendored Baseline aus
slice-011.

Dazu bekommt `harness/conventions.md` §Baseline den fehlenden **Adoptions-Bezugspunkt**:
die Stand-Zeile des Regelwerks („Kurs-Welle 26 · 2026-07-17", `regelwerk/README.md:3`)
und den Tag `v3.1.0` — heute steht dort nur „Templates: templates-v4".

**Abgrenzung.** Die Absätze, die die *Cache-/Vendoring-Mechanik* beschreiben,
gehören zu slice-011. Der mechanische Nachzug an Vorlagen und Slice-Köpfen ist
slice-013, die inhaltlichen Nachzüge sind slice-014. Der „wortgleich"-Satz in der
Begründung von [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) wird **nicht** angefasst — er war für v1.2.0
zutreffend und steht nach slice-011 als **Historie**; historische MR-Einträge werden
nicht umgeschrieben.

## 2. Definition of Done

- [x] **`AGENTS.md` §1 — bereits durch slice-011 erledigt** (beim §1-Umschreiben auf
      die vendored Form): beide toten Pointer (`main`-Monolith-URL **und**
      `lab-templates.zip`) sind entfernt; §1 verweist auf „den Kurs, den
      `regelwerk/README.md` nennt", und diese Kette führt auf
      `blob/v3.1.0/kurs/de/README.md` (curl HTTP 200 belegt). Hier daher **nichts mehr
      zu tun** — der Punkt bleibt als Nachweis stehen, dass er abgedeckt ist.
- [x] `harness/conventions.md` §Adoptierte Konventions-Quellen: die tote
      `raw…/main/…/agents-regelwerk.md`-URL (curl **404**) ersetzt durch den auf
      `v3.1.0` gepinnten Kurs `/kurs/de/` (curl **200**) + Zeiger auf die vendored
      Baseline als verkörperte Form ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [x] `harness/conventions.md` §Baseline trägt Stand („Kurs-Welle 26 · 2026-07-17")
      und Tag (`v3.1.0`); „Templates: templates-v4" nachgezogen (als historisches
      Adoptionsdatum erhalten, Re-Baseline-Zeile ergänzt).
- [x] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| ~~`AGENTS.md` (§1)~~ | — | **entfällt** — slice-011 hat die toten Pointer beim §1-Umschreiben schon entfernt (s. DoD) |
| `harness/conventions.md` (§Baseline, §Adoptierte Konventions-Quellen) | update | tote URL → gepinnter Kurs; Stand + Tag als Adoptions-Bezugspunkt |

## 4. Trigger

Nach slice-011 (`in-progress` → möglich, sobald die vendored Baseline existiert —
die neuen Pointer zeigen auf sie).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Upstream-Verifikation ist Pflicht, nicht Kür.** Jeder neu eingetragene Link
  wird vor dem Commit per `curl` geprüft. Genau dieser Schritt fehlte beim
  Entstehen der jetzigen 404-Pointer — ein Link, der beim Schreiben stimmte, ist
  kein Link, der stimmt.
- **`main` vs. Tag.** Die alte URL zeigte auf `main` (floating) — das stand schon
  in Spannung zu [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), die für Templates/Skelett/d-check-Image
  ausdrücklich Tag- oder Digest-Pinning verlangt. Der Ersatz wird auf `v3.1.0`
  gepinnt; das Template stützt das („für harte Reproduzierbarkeit das Asset eines
  Tags ziehen statt `latest`"). **Beleg für die Dringlichkeit:** zwischen v3.0.0 und
  v3.1.0 lagen neun Stunden (2026-07-16 19:01 → 2026-07-17 03:54 UTC) — ein
  `latest`-Verweis hätte in dieser Zeit lautlos das Ziel gewechselt.
- **Kein Nachziehen von Historie.** [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) und der Cache-Teil von
  [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) behalten ihren Wortlaut (inkl. „wortgleich") als Historie —
  sie beschreiben, was zum Zeitpunkt der Adaption galt.

## 7. Closure-Notiz (nach `done/`)

**Abschluss 2026-07-17.** Commits: Move nach `in-progress/` (reiner `git mv`),
Implementierung + Closure (dieser), Move nach `done/`.

**Geliefert.** `harness/conventions.md` §Adoptierte Konventions-Quellen: die tote
`raw…/main/…/agents-regelwerk.md`-URL (curl **404**, der Monolith existiert upstream
seit v2.0.0 nicht mehr) ersetzt durch den auf `v3.1.0` gepinnten Kurs `/kurs/de/`
(curl **200**) + Zeiger auf die vendored Baseline als verkörperte Form. §Baseline:
Regelwerks-Stand („Kurs-Welle 26 · 2026-07-17") + Tag `v3.1.0`; „templates-v4" als
historisches Adoptionsdatum erhalten, Re-Baseline-Zeile ergänzt (Historie nicht
überschrieben).

**Kleiner als geplant — bewusst, kein übersehener Rest.** DoD 1 und 2 für `AGENTS.md`
waren bei Slice-Start bereits erfüllt: slice-011 hatte beim §1-Umschreiben auf die
vendored Form beide toten Pointer mitentfernt. Der Slice-Plan war dafür geschrieben,
als `AGENTS.md` §1 noch die Cache-Ära beschrieb. Statt die Arbeit doppelt zu
behaupten, sind die AGENTS-DoD-Punkte als „durch slice-011 abgedeckt" markiert und
per curl gegenbelegt. Verbleibende reale Arbeit: nur `harness/conventions.md`.

**Zwei beobachtbare Closure-Kriterien.**
1. **`make gates` grün**: baseline-verify OK, d-check 36 / 0 Befunde, bats 47/47,
   shellcheck clean.
2. **Erreichbarkeit per `curl` belegt** (die DoD-eigene Messmethode): der Ersatz-Link
   liefert HTTP 200, die entfernte URL 404 — beide am 2026-07-17 gemessen.

**Steering-Loop-Lerneintrag — geschärfte Regel.** *Ein Slice-Plan altert zwischen
Planung und Umsetzung, wenn ein vorheriger Slice denselben Bereich anfasst.* slice-011
hat slice-012s AGENTS-Arbeit als Nebeneffekt vorweggenommen. Die Lehre ist **nicht**
„enger abgrenzen" (die Abgrenzung war korrekt formuliert), sondern: **bei Slice-Start
den Ist-Zustand gegen den Plan messen, nicht den Plan blind abarbeiten** — sonst
behauptet die Closure Arbeit, die ein anderer Commit schon tat (eine Harness-Lüge in
Zeitlupe). Hier gefangen, indem der erste Schritt ein Grep auf die toten Pointer war,
nicht ein Edit.

**Restrisiko.** Die neue gepinnte URL kann altern wie jede — genau die Klasse, die den
404 erzeugte. Anders als vorher ist sie tag-gepinnt (nicht `main`-floating) und
curl-belegt; das Re-Pinnen bei einem Baseline-Bump ist im selben Vorgang wie
`BASELINE_TAG` fällig ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)), aber **nicht** mechanisch erzwungen — dieselbe offene
Freshness-Lücke wie beim Regelwerk selbst.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
reine Doku-Adaption an der adoptierten Harness ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)); GF (Doc führt).

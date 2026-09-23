# Welle welle-v021-faehigkeit — Die v0.2.1-Fähigkeit — Closure-Notiz

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis).* Dieses Artefakt friert ein; was es zitiert, bewegt
> sich weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads,
> `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle als
> `v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link.

**Welle:** welle-v021-faehigkeit
**Abschluss:** 2026-09-23
**Verantwortlich:** Planner

## Was wurde geliefert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — *was gelernt wurde*: geliefert · was
funktionierte · was anders lief. Mit ID-Bezug, wo es einen gibt.

**Ziel der Welle:** die v0.2.1-Fähigkeit — der Stand, den die Kette seit dem Zielordner-Slice
gezogen hat, zusammen ziehen. Alle sieben Slices der Welle (§4 des Welle-Plans) liegen in `done/`
(`ls docs/plan/planning/done/ | grep -cE "zielordner|release-schnitt|releasing|adapter-und-ports|stumme-mutations|mutations-faelle-pruefen|fall-anlage|unscoped|benutzerhandbuch|tap-verteilt|waechter-der-erfassung|lifecycle-werkzeuge|emitter-aussagen|leser-und-aufraeum"` → **13** — die sieben Belegbasis-Slices aus §1 und die sieben Mitglieder der Tabelle, zwei Slices doppelt gezählt, keine Erwartungswerte):

- [`slice-unscoped-ziele-kollidieren-nicht-im-mono-repo`](slice-unscoped-ziele-kollidieren-nicht-im-mono-repo.md) — [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
- [`slice-benutzerhandbuch-nachzug-traegt-fuenf-posten`](slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md) — [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
- [`slice-tap-verteilt-die-release-assets`](slice-tap-verteilt-die-release-assets.md) — [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
- [`slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`](slice-waechter-der-erfassungsschicht-decken-was-sie-sagen.md) — [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
- [`slice-lifecycle-werkzeuge-tragen-die-kennung`](slice-lifecycle-werkzeuge-tragen-die-kennung.md) — [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt`](slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt.md) — [`LH-FA-12`](../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
- [`slice-leser-und-aufraeum-waechter-decken-was-sie-sagen`](slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md) — [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)

Jeder der sieben trägt seine DoD-Belege in seiner eigenen Datei in `done/`; der
repo-weite Beleg steht unten unter *Verifikation*.

## Was hat funktioniert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3.

- **Der Welle-Zuschnitt trug.** Die sieben Slices blieben einzeln lieferbar und
  in einer Review-Sitzung prüfbar; der Übergangs-Rhythmus (eröffnen →
  beanspruchen → schließen) lief ohne Nacharbeit am Bündel.
- **Der Verifier-Nachzug hielt die Rot-Belege unabhängig.** Beim letzten
  Mitglied (`slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt`) sah
  der Reviewer wegen Budgets zwei der drei Mutationsfälle nur aus der
  Test-Logik; der Verifier fuhr beide selbst und bestätigte den zweifachen
  Fehlschlag des Wächters (`AGENTS.md` §3.6, Modul 11 §Bewusstes Brechen).
- **Das Register arbeitete als Ausgang statt als Aufschub.** Die Slice-Closures
  dieser Welle schickten Beobachtungen in den Zähler (darunter zwei Neueinträge
  des letzten Slices), statt für jede einen Folge-Slice zu schneiden; der
  Lese-Schritt dieser Closure fand genau einen Eintrag über der Schwelle.

## Was ging anders als geplant?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — jede Zeile möglichst mit der Konsequenz,
die daraus schon gezogen wurde.

- **Drei der sieben Mitglieder trugen im Kopf „ohne Welle"**
  (`slice-unscoped-ziele-kollidieren-nicht-im-mono-repo`,
  `slice-lifecycle-werkzeuge-tragen-die-kennung`,
  `slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt`) — sie wurden
  vor der Welle (2026-09-20) geschnitten, und die Köpfe wurden nie nachgezogen.
  Die Begründung in den Köpfen (*„beobachtet keine Closure-Bedingung mehr, als
  diese DoD belegt"*) ist damit nicht mehr richtig — der Welle-Trigger beobachtet
  mehr (`make full-smoke`). Die Einsammlung bleibt von der Diskrepanz unberührt:
  die wellenlosen Slices, die seit der letzten Closure schlossen, sammelt die
  Welle-Closure ohnehin ein (Baseline-Regelwerk `modul-06-roadmap.md`
  §Wellen-Closure-Prozedur, Schritt 4). Die Köpfe bleiben, wie sie sind; `git`
  trägt ihre Geschichte.
- **Die Archivierung (Schritt 4) steht aus** — die Vorschau
  (`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-v021-faehigkeit`)
  meldet vier Sperren, davon die tragende `[untergrenze]`: **110** wellenlose
  Slices liegen flach in `done/`, und kein `done/*/archiv.zip` setzt eine
  Untergrenze — *„die Archivierung des Altbestands ist ein eigener Vorgang —
  danach ist die Grenze beobachtbar"*. Das Repo hat **keine** Welle archiviert;
  die vierzehn geschlossenen Wellen liegen unarchiviert. Der Posten gehört dem
  Auftraggeber: Er entscheidet die Zuordnung (chronologisch nächste geschlossene
  Welle oder ein einzelnes Sammel-Archiv für den Bestand), danach trägt die
  Grenze, und die Archivierung dieser Welle folgt als eigener Vorgang.
- **Die Fenster-Prämisse der 3×-Messung war unpräzise und ist präzisiert:** der
  erste Beleg des 3×-Eintrags (`slice-flache-welle-ist-eroeffnet-nicht-geplant`,
  2026-09-14) liegt vor der letzten Welle-Closure und stand bei deren Lese-Schritt
  unter der Schwelle; der Übertritt über 3× fiel mit dem zweiten und dritten
  Beleg (2026-09-17, 2026-09-18) in das Fenster dieser Welle. Die Präzisierung
  steht in `ADR-0062` §Kontext; das Audit dieser Welle bleibt der richtige Träger.
- **Die Audit-Formel zu `ADR-0057` Trigger 2 ist präzisiert:** der Sprung
  `v6.8.0` → `v6.9.0` (2026-09-16) ist **eingetreten**; der Trigger verlangt
  zusätzlich eine Vorlagen-Art außerhalb der vier Mengen, und die fehlt — die
  Template-Pfadlisten sind über den Vendor-Commit identisch (28 = 28, `diff`
  leer). Sprung eingetreten, kein Vorlagen-Delta — Trigger 2 nicht gefeuert.

## Steering-Loop-Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 (hier stehen **nur** Beobachtungen, die im
Register 3× erreicht haben; jeder Eintrag nennt seine `BEO-<NNN>`) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (Feld
und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der Backticks; die
**Spec-Lücke** trägt statt `liegt in` ihre `LH-*`-ID — das ist kein Versehen).

- **[`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)**
  — die allgemeine Eigentums-Regel ist entschieden: `ADR-0062`
  (*Eigentums-Frage ohne Quelle wird im laufenden Vorgang nicht beantwortet*),
  `Proposed`, drei Festlegungen, **kein `Supersedes`** — die vier Instanz-ADRs
  (`ADR-0015`, `ADR-0024`, `ADR-0028`, `ADR-0048`) bleiben in Kraft. Der
  Ausgang im Register ist **`geplant`**, Kennung `ADR-0062` — mit dem Accept
  (Acceptance-Trigger der ADR, eigene Reviewer-Runde) wird derselbe Ausgang
  **`verkörpert`**; der Anker `· seit welle-v021-faehigkeit` trägt die ADR
  selbst. Kein `liegt in`-Feld: Der Eintrag ist **gezählt, nicht verkörpert** —
  die Anker-Paarung ist damit nicht ausgelöst.
  Auslöser: `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`
  (`slice-flache-welle-ist-eroeffnet-nicht-geplant`,
  `slice-stilllegungs-kanten-sind-gemessen`,
  `slice-spec-straten-zeigen-nicht-nach-aussen` — 3×).

## Beobachtungs-Register (Zeiger)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — der Zähler wird **nicht** hier gepflegt; diese
Sektion ist ein Zeiger und trägt keine Daten.

Der Zähler steht in [`../observations/`](../observations) (Verzeichnis-Form, ein
Verzeichnis je Beobachtung; der Mechanismus in
[`../observations/README.md`](../observations/README.md)). Was in dieser Welle
**3×** erreicht hat, steht oben unter *Steering-Loop-Einträge*.

## Folge-Slices

Keine neuen. Die zwei `CO-001`-Ausgänge aus dem Trigger-Audit stehen unverändert:
`slice-141-co-001-aufloesung-ist-vorher-entschieden` in `next/` und
`slice-113-co-001-ist-faellig` in `open/` (verlängert, nicht aufgelöst). Die zwei
weiterhin offenen Eigentums-Fragen (`docs/plan/planning/README.md`, Spec-Straten —
[`slice-151-spec-straten-haben-eine-schreibende-rolle`](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)
in `open/`) fallen unter `ADR-0062` Festlegung 2 **erst ab deren Annahme**; bis
dahin beantwortet die ADR sie nicht.

## Verifikation

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 1 — der repo-weite Beleg über die Slice-DoDs
hinaus.

- Alle sieben Slices in `done/` (gemessen, siehe *Was wurde geliefert*).
- `make gates` → EXIT 0 (Lauf vom 2026-09-23; `docs-check` 1810 Datei(en), 0
  Befunde; Aufzeichnung `.harness/state/gates-passed.diffsha`).
- `make full-smoke` → EXIT 0 (Lauf vom 2026-09-23; 35 `full-smoke: OK`-Stufen,
  `grep -c 'full-smoke: OK'` über das Protokoll des Laufs) — der repo-weite
  Beleg, den keine einzelne Slice-DoD trägt.
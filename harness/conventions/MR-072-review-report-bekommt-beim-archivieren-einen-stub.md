# MR-072 — Ein Review-Report bekommt beim Archivieren einen Stub, entgegen dem Wortlaut der Ziel-Form

- **Datum:** 2026-09-22
- **Wirksamkeits-Anlass:** [ADR-0061](../../docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  (`Proposed`) — Architect-Lauf zu `slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang`.
  Der Bestand widerspricht der Baseline-Annahme messbar: **171** von **520** Report-Dateien sind
  Ziel eines eingehenden Links (`for r in docs/reviews/*.md; do rb="${r##*/}"; git grep -lF -e
  "]($rb)" -- ':!.harness/baseline' | grep -vxF "$r" | sed "s|.*|$rb|"; done | sort -u | wc -l`),
  und der erste Archiv-Lauf (`archive-welle --vorschau welle-13`) meldet **58** `[haenger]`-Fundstellen,
  ohne die diese Frage nur eine Notiz bliebe.
- **Geltungsbereich:** `internal/archive/` (die Archivierungs-Operation aus
  [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md)) und
  `docs/plan/planning/` (eine neue, repo-eigene Ausfüll-Vorlage für den Report-Stub, Nachbar der
  vendored `archiv-stub-slice.template.md`/`archiv-stub-welle.template.md`). **Nicht** die
  Stub-Form von Slice und Welle selbst — die bleiben vendored und unverändert. **Nicht** der
  Verweis-Nachzug in Zeitdokumenten ([ADR-0042](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md));
  ein Report-Stub am unveränderten Pfad braucht keinen Nachzug.
- **Ersetzt-Baseline-Regel:**
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-06-roadmap.md#wellen-closure-prozedur-modul-6)
  §Wellen-Closure-Prozedur (Modul 6), Schritt 4 — *„Review-Reports bekommen keinen Stub; sie haben
  keine Identität jenseits ihres Slice."*
- **Adaption:** Ein Review-Report bekommt beim Archivieren, wie Slice und Welle, einen gekürzten
  Stub (Überschrift, Archiv-Zeiger, Zustand) — **an seinem unveränderten Pfad**
  `docs/reviews/<datei>.md`, nicht in einem Wellen-Unterverzeichnis. Der Report wird nicht mehr
  ersatzlos gelöscht (`g.Rm(b.Reviews)` in `internal/archive/anwenden.go`); an seiner Stelle
  verbleibt der Stub, der volle Inhalt wandert wie bisher ins Archiv-Zip. Die Stub-Vorlage entsteht
  repo-eigen, weil der Kurs diese Artefaktklasse nicht führt und
  [`MR-041`](../conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
  nur **vendored, wiederkehrende** Vorlagen referenziert.
- **Begründung:** Die Baseline-Annahme *„niemand zeigt einzeln auf einen Report"* trägt in diesem
  Repo nicht — 122 der 171 Fundstellen sind Report-zu-Report-Verweise, bereits von
  [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) §Kontext gemessen
  und der Grund, warum jene Entscheidung `docs/reviews/**` bewusst nicht aus dem Verweis-Suchraum
  nimmt. Ein Stub am unveränderten Pfad löst **alle** 58 Hänger-Fundstellen des Report-Anteils, ohne
  einen der 171 bestehenden Verweise anzufassen — auch die zehn in `Accepted`-ADRs, einem
  aufgelösten Carveout, einem append-only-Konventionseintrag, zwei ab Merge eingefrorenen
  Evidence-Dateien und `spec/lastenheft.md` bleiben unberührt, weil nichts nachgezogen werden muss. Die Alternativen
  (Verweise umschreiben, Referenz-Ventil, `docs/reviews/` von der Archivierung ausnehmen) sind
  teurer oder scheitern an [`AGENTS.md`](../../AGENTS.md) §3.4/§3.5 — Details in
  [ADR-0061](../../docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  §Verglichene Alternativen.
- **Grenze.** Drei Gegenformen bleiben ungelöst, dieselben wie bei Slice-Stubs
  ([ADR-0042](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4):
  ein Zustandssatz neben der Adresse, ein Operand in einem Mess-Kommando, ein künftiger
  Abschnitts-Anker auf einen gekürzten Stub. Heute gemessen leer für Anker-Links
  (`git grep -ohE '\]\([^)]*docs/reviews/[^)]*\.md#[^)]*\)' -- '*.md' ':!.harness/baseline' | wc -l`
  → **0**), aber kein Sensor hält das für die Zukunft.
- **Auflösungs-Trigger:**
  - **Wenn [ADR-0061](../../docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
    zu `Superseded` wird** — dieser Eintrag folgt ihrem Status.
  - **Wenn die adoptierte Baseline eine eigene Stub-Form für Review-Reports einführt** — ein
    Re-Baseline-Lauf prüft, ob sie die repo-eigene Vorlage aus dieser Adaption ablöst.

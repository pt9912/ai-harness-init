# Slice slice-sprung-auf-v690-wird-vollzogen: Jeder Träger des Tags steht auf `v6.9.0`, der Adaptions-Block ist gegen das Delta gelesen, und der Vorlagen-Bericht hält auch die bestehenden Instanzen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht fällt negativ aus: Keine Closure-Bedingung beobachtet mehr als die
DoD dieses Slice — `make gates` und `make baseline-verify` stehen in §2. Die Buchung des Vollzugs
in §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md) ist kein
Bündel-Trigger: [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
§Konsequenzen weist sie dem Lauf zu, der den Vollzug ausführt, und überlässt dem Planner, ob aus
den zwei Gegenständen ein Slice wird oder zwei (§1). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037) steht wellenlose Arbeit nicht in der
Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood und emittierter Pin, nicht emittierter Inhalt.** Gegenstand sind der vendored
Baum dieses Repos, die fünf gekoppelten Pin-Stellen, die Adressen in lebenden Artefakten und die
Instanzen der Vorlagen. Zwei Pin-Stellen liegen in `internal/fetch/baseline.go` und wandern ins
Zielrepo. Was ein emittiertes Repo an **Inhalt** bekommt, entscheidet
[`MR-054`](../../../../harness/conventions.md#mr-054) und nicht diese Datei (§1).

In den Kommandos steht `K` für einen Klon des Kurs-Repos, eine Host-Voraussetzung und kein
Artefakt dieses Repos ([`ADR-0052`](../../adr/0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md)).
Vergleicht ein Kommando zwei Tags, ist seine Zahl fest; zählt es im Arbeitsbaum, ist sie **kein
Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Tag-Klammer, in
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Entscheidung der tragende
Grund der regierenden Fassung),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)
(`DefaultTag`/`DefaultBaselineSHA256` schicken dasselbe Asset ins Zielrepo),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(`make vendor-baseline` stellt her und prüft nicht; der Beleg ist `make baseline-verify` nach
demselben Lauf, und für den Vorgang selbst existiert kein Sensor, §6),
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (die regierende Fassung
dieses Sprungs. Ihre Folgepflicht *Planner, vor dem Vollzug* ordnet Liefer-Punkt 1 und 3 an,
*Architect, im Durchgang* Liefer-Punkt 2, *Architect, mit dem Tausch* die Register-Zuordnung, die
Liefer-Punkt 3 liest; ihre Übernahme-Vorgabe schließt *bewusst abweichend* aus),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (§Wer den Zielstand bewegt —
die Setzung auf `v6.9.0` ist die des Auftraggebers; Festlegung 1 nennt die Durchgänge der
Prozedur, Festlegung 2 trennt Prozedur und Ist-Maßstab, Festlegung 4 hält die fünf Ausgänge),
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2 — die
Delta-Basis `v6.8.0` wird gelesen, nicht gesetzt),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2 —
die Form der Buchung; die ADR steht auf `Proposed`, §6),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (eingefrorene Adresse
auf den abgelösten Tag: *Bestand bleibt bewusst stehen*),
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
(`harness/migration.md` gehört dem Architect),
[`MR-007`](../../../../harness/conventions.md#mr-007) (committet vendored, netzlos),
[`MR-035`](../../../../harness/conventions.md#mr-035) und
[`MR-056`](../../../../harness/conventions.md#mr-056) (die sieben Symlinks: umgehängt; der
Auswahl-Maßstab ist Frage an Liefer-Punkt 2),
[`MR-025`](../../../../harness/conventions.md#mr-025),
[`MR-033`](../../../../harness/conventions.md#mr-033) und
[`MR-051`](../../../../harness/conventions.md#mr-051) (jede Zahl steht neben ihrem Kommando und
nennt den Tag, gegen den sie gemessen ist — im Plan, im Bericht und in der Commit-Message).

**Berührte Spec-Stellen:** — (keine Spec-Stelle wird normativ berührt. Trägt ein Spec-Stratum
eine Adresse in den vendored Baum, zählen die Kommandos in §1 sie mit; ihr Nachzug ist Adresse,
keine Spec-Änderung).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-16.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Sprung `v6.8.0` → `v6.9.0` ist vollzogen. Der vendored Baum, die fünf gekoppelten
Pin-Stellen, die sieben tag-tragenden Symlinks in `.claude/rules/` und jede Adresse in einem
**lebenden** Artefakt stehen auf `v6.9.0`. Der Adaptions-Block ist gegen das Regelwerks-Delta
gelesen, und jeder betroffene Eintrag trägt einen der fünf Ausgänge; übernommen wird die
Ziel-Fassung vollständig. Der Vorlagen-Bericht zum Tag `v6.9.0` unter `docs/migrations/` liegt
vor und berichtet neben den Vorlagen mit Delta auch die **bestehenden Instanzen**, die die
Klassen-Aussagen der Ziel-Fassung erreichen.

### Ein Slice, nicht zwei

[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen nennt dem
Planner zwei Gegenstände — Baum-Tausch und Instanz-Durchgang — und lässt den Schnitt offen. Drei
Gründe tragen **einen** Slice:

1. **Die Setzung des Auftraggebers bindet die Instanzen an diesen Slice.** Der Accept-Übergang
   von [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (§Geschichte) hält
   fest: *„die bestehenden Instanzen trägt die DoD des Slice, der den Tausch vollzieht"*. Ein
   eigener Durchgangs-Slice nähme sie aus dieser DoD heraus.
2. **Der Maßstab entsteht mit dem Tausch.** Die Klassen-Aussagen sind Ist-Maßstab und werden mit
   dem Tausch fällig; bis dahin gilt `v6.8.0`
   ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2). Ein
   Durchgang vor dem Tausch hätte keinen Maßstab. Ein Tausch ohne Durchgang wäre zwar für sich
   lieferbar, ließe das Repo aber eine Konformität zu `v6.9.0` behaupten, deren Instanzen niemand
   gehalten hat.
3. **Die Größenregel hält.** Drei Liefer-Punkte auf drei Achsen, dieselbe Aufteilung wie beim
   Vorgänger
   [slice-sprung-auf-v680-wird-vollzogen](../done/slice-sprung-auf-v680-wird-vollzogen.md), der in
   einer Review-Sitzung prüfbar war. Berührt sind zwei Schichten: der vendored Fremd-Blob samt
   Pin-Konfiguration und die Doku- und Planungs-Artefakte; Produkt-Code nur in zwei Konstanten.
   Den Zuwachs gegenüber dem Vorgänger trägt allein Liefer-Punkt 3, und seine Obergrenze ist als
   Rückführung in §4 verdrahtet.

### Drei Achsen, und sie werden nicht ineinander übersetzt

[`harness/migration.md`](../../../../harness/migration.md) §5 setzt, dass die Ausgänge über die
**Vorlage** nicht die fünf Ausgänge über den **Adaptions-Eintrag** sind. Die dritte Achse, die
**Adresse**, urteilt nicht; sie bewegt Bytes.

| Achse | Gegenstand | Ausgangs-Menge | Liefer-Punkt |
|---|---|---|---|
| Adresse | Baum · Pin · Symlink · Markdown-Link · Inline-Pfad | keine | 1 |
| Adaptions-Eintrag (`MR-<NNN>`) | die aktiven Einträge unter [`harness/conventions/`](../../../../harness/conventions/) — `ls harness/conventions/*.md \| wc -l` → **56** | fünf: gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist entfallen · widerspricht | 2 |
| Vorlage | die Vorlagen des vendored Baums — `find .harness/baseline/v6.8.0/templates -name '*.template.md' \| wc -l` → **25**, gemessen gegen `v6.8.0` | Buchstabe a: übernommen · schon erfüllt · keine Instanz (*bewusst abweichend* entfällt); Buchstabe b: append-only | 3 |

### Der Adress-Nachzug ist gemessen

Über dem Arbeitsbaum, der diesen Plan enthält:

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.8\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 126 Markdown-Links
git grep -lE '\]\([^)]*\.harness/baseline/v6\.8\.0[^)]*\)' -- "${PS[@]}" | wc -l   #  58 Dateien
git grep -oE '`[^`]*\.harness/baseline/v6\.8\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 108 Inline-Code-Pfade
git grep -lE '`[^`]*\.harness/baseline/v6\.8\.0[^`]*`'     -- "${PS[@]}" | wc -l   #  16 Dateien
git grep -l 'v6\.8\.0' -- ':!*.md' ':!.harness/baseline' | wc -l                   #   3 Nicht-Markdown-Dateien
git grep -c '\.harness/baseline/v6\.8\.0/' -- harness/migration.md                  #  44
```

Die 126 Links sind gate-sichtbar und fallen in dem Moment, in dem das `v6.8.0`-Verzeichnis
verschwindet; Tausch- und Nachzugs-Commit gehören darum in denselben Push (Baseline-Regelwerk
`grundlagen-traceability.md` §Herkunfts-Anker). Die 108 Inline-Pfade sieht kein Gate
([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul
`codepaths`). Die drei Nicht-Markdown-Dateien sind die Pin-Träger aus Liefer-Punkt 1
(`.d-check.yml`, `Makefile`, `internal/fetch/baseline.go`). Die 44 Treffer in
`harness/migration.md` zieht der Architect-Commit nach
([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Messung, ob `make slice-mv` und `make docs-check` die neuen Kanten `open → done` und
  `next → done` tragen.** *Ein Folge-Slice übernimmt sie:* `slice-stilllegungs-kanten-sind-gemessen`
  — sein §1 führt genau diese Messung als Ziel. *Es wäre ein anderer Vorgang:* Dieser
  Slice arbeitet am Gegenstand, jener misst Werkzeuge, und sein Maßstab — der Abschnitt *Ein
  Slice, dessen Gegenstand ein anderer übernimmt* in `modul-05-planning-harness.md` — liegt erst
  nach diesem Slice vendored vor. Dieser Plan sagt deshalb **nichts** darüber, ob die Werkzeuge
  die Kanten tragen (§8).
- **Keine Anwendung der Kanten auf Slices dieses Repos.**
  [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Was diese Festlegung
  nicht tut schließt sie aus, und sie setzt die Messung aus dem Punkt davor voraus — *anderer
  Vorgang*, in der Reihenfolge des Auftraggebers nach der Messung.
- **Keine Zuordnung von Register-Zeilen im Implementations-Kontext.** Ob `welle-results`, `gate`
  und `MR-NNN-titel` unter Buchstabe a oder b fallen, klärt die Folgepflicht *Architect, mit dem
  Tausch* ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen).
  Liefer-Punkt 3 **liest** die Zuordnung — *Schicht-Abgrenzung zwischen Durchgang und
  Entscheidung*.
- **Keine eingefrorene Adresse wird berührt.** Was in `docs/reviews/**`,
  `docs/plan/planning/done/**`, `docs/plan/carveouts/done/**`, im Beobachtungs-Register und in
  einer `Accepted`-ADR auf `v6.8.0` zeigt, bleibt stehen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.11;
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)) — *Bestand bleibt
  bewusst stehen*. Die Pathspec in §1 bildet genau diesen Ausschluss ab.
- **Kein zweites Referenz-Ventil in [`.d-check.yml`](../../../../.d-check.yml).** Jedes weitere
  Paar ist eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener ADR; die
  Links werden nachgezogen — *anderer Vorgang*.
- **Keine Änderung am Auswahl-Maßstab für `.claude/rules/` im Implementations-Kontext.** Die
  sieben Symlinks werden umgehängt. Ob der neue Inhalt von `modul-05` und `modul-06` den Maßstab
  aus [`MR-035`](../../../../harness/conventions.md#mr-035) und
  [`MR-056`](../../../../harness/conventions.md#mr-056) berührt, ist die Freshness-Frage an genau
  diese zwei Einträge; sie gehört in Liefer-Punkt 2 und an den Architect — *anderer Vorgang einer
  anderen Rolle*.
- **Kein Inhalt der emittierten Ebene.** Die Pin-Hälfte gehört hierher. Was ein Zielrepo an
  Vorlagen und Modulen bekommt, liegt bei [`MR-054`](../../../../harness/conventions.md#mr-054)
  und [`MR-017`](../../../../harness/conventions.md#mr-017) — *Schicht-Abgrenzung*.
- **Keine Sichtung der offenen Pläne gegen den neuen Stand.** Der Bestand in `open/` und `next/`
  bleibt stehen. Den Schritt dafür schreibt `slice-offene-plaene-gegen-den-neuen-stand`; eine
  Adresse für die Sichtung **dieses** Sprungs ist er nicht, denn er bindet die Sichtung, die der
  nächste Sprung nach ihm auslöst — *Bestand bleibt bewusst stehen*, mit Risiko in §6.
- **Kein neuer Wächter für den Vorgang.**
  [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Fitness Function stellt
  fest, dass kein Gate liest, nach welcher Fassung ein Durchgang lief — *anderer Vorgang*.
- **Keine neue ADR und kein Carveout geplant.** Die Übernahme-Vorgabe nimmt dem Ausgang
  *widerspricht* die Entscheidung: Der Eintrag tritt zurück. Den Rückbau schreibt der Architect in
  Liefer-Punkt 2; zieht er mehr nach als den Eintrag selbst, greift die Rückführung in §4.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte, einer je Achse aus §1.

- [ ] **1 — Jeder Träger des Tags steht auf `v6.9.0`, und keine lebende Adresse bleibt auf dem
      abgelösten Tag.** Fünf Träger-Klassen, eine Eigenschaft; ein halb getauschtes Repo ist rot.

      1. **Der vendored Baum.** `.harness/baseline/v6.9.0/{regelwerk,templates}` samt
         `SHA256SUMS` liegt committet, das `v6.8.0`-Verzeichnis existiert nicht mehr, und
         `make baseline-verify` meldet
         `baseline-verify: v6.9.0 OK — <N> Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
         Tragend ist das `OK`, die Dateizahl ist kein Erwartungswert. Der Baum entsteht über
         [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md) aus dem
         verifizierten Release-Asset, nicht per Hand-Kopie aus dem Kurs-Klon.
      2. **Die fünf gekoppelten Pin-Stellen.** `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im `Makefile`
         (kanonisch), das `sources`-Paar in [`.d-check.yml`](../../../../.d-check.yml) und
         `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go`. Die drei Wächter
         `test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline` und
         `TestDefaultBaselineSHA256_MatchesMakefile` laufen grün in `make gates`, und
         `make regelwerk-check` (Netz, nicht in `make gates`) meldet `0 Befund(e)`, EXIT 0.
         **Der sha256 wird am Release-Asset gemessen.**
         [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) nennt keinen, und
         dieser Plan nennt ihn aus demselben Grund nicht: ohne sein Kommando daneben wäre er eine
         Zahl ohne Beleg. Steht er im Umsetzungs-Lauf nicht neben dem Kommando, das ihn liefert,
         ist dieser Punkt offen.
      3. **Die sieben Symlinks in `.claude/rules/`.** Die Mitglieder-Zahl bleibt, und kein Zeiger
         in den vendored Baum nennt einen anderen Tag als den neuen:

         ```sh
         readlink .claude/rules/*.md | grep -c '\.harness/baseline/'          # unverändert
         readlink .claude/rules/*.md | grep '\.harness/baseline/' \
           | grep -vc 'baseline/v6\.9\.0/'                                    # 0
         ```

         Die erste Zahl ist kein Erwartungswert; tragend ist die zweite. Die Zusage ist über den
         **neuen** Tag formuliert, damit sie den Nachzug aus Klasse 5 übersteht.
      4. **Die 126 Markdown-Links**, gate-sichtbar (§1).
      5. **Die 108 Inline-Code-Pfade**, gate-unsichtbar (§1).

      Für 4 liefern die zwei Link-Kommandos aus §1 über dem Ergebnis-Stand **0**. Für 5 sind
      **null Adressen** zugesagt, nicht null Treffer: Eine Inline-Nennung ist entweder Adresse —
      dann gehört sie auf den neuen Tag — oder Teil einer Aussage, die den Stand nennt, gegen den
      sie gemessen ist ([`MR-033`](../../../../harness/conventions.md#mr-033)). Welche von beiden,
      ist ein Urteil je Treffer; der Rest steht im Umsetzungs-Lauf benannt und abgezählt daneben.
      Der Nachzug läuft **je Eigentümer in einem eigenen Commit**, der die Rolle nennt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Planungs- und Sensor-Artefakte im
      Implementations-Kontext; [`AGENTS.md`](../../../../AGENTS.md),
      [`harness/conventions.md`](../../../../harness/conventions.md) samt
      [`harness/conventions/`](../../../../harness/conventions/) und
      [`harness/migration.md`](../../../../harness/migration.md) im Architect-Lauf;
      [`.claude/commands/`](../../../../.claude/commands/) und
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) bei der Rolle, die
      sie ausführt ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
      die Roadmap beim Planner.
- [ ] **2 — Die Freshness-Review des Adaptions-Blocks ist über alle 56 aktiven Einträge
      gefahren, jeder betroffene trägt einen der fünf Ausgänge, und die Stichprobe gegen den
      Bestand ist gelaufen.** Die Frage je Eintrag: Regelt eine der im Sprung geänderten
      Regelwerks-Dateien das, wofür dieser Eintrag angelegt wurde?

      ```sh
      git -C "$K" diff --name-only v6.8.0..v6.9.0 -- lab/regelwerk
      # -> README.md, modul-02-harness-bootstrap.md, modul-05-planning-harness.md,
      #    modul-06-roadmap.md unter lab/regelwerk/   (Tag-Vergleich, feste Zahl 4)
      ```

      Gelesen wird der **Volltext** der geänderten Datei am Tag `v6.9.0`, nicht allein ihr Hunk
      (§8, `delta-durchgang-uebersieht-deckung`). Die Prozedur ist die der Ziel-Fassung
      ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Entscheidung), die
      Ausgänge sind die geschlossene Fünf-Menge
      ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4). **Die
      Übernahme-Vorgabe gilt ohne Ausnahme:** Trifft ein Eintrag *widerspricht*, tritt er zurück,
      und die neue Fassung wird übernommen
      ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen). Der
      Rückbau ist ein neuer Eintrag, kein Edit (Baseline-Regelwerk
      `modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline;
      [`MR-020`](../../../../harness/conventions.md#mr-020),
      [`MR-032`](../../../../harness/conventions.md#mr-032)).

      **Die Grundgesamtheit ist die volle Liste:** `ls harness/conventions/*.md | wc -l` →
      **56**, kein Erwartungswert. Die Suchhilfen ersetzen den Durchgang nicht.

      **Suchhilfe 1 — Datei-Bezug.** Zwanzig Einträge nennen mindestens eine der vier Dateien;
      ein Name ist ein Treffer im Suchraum, kein Betroffensein:

      ```sh
      git grep -lE 'modul-02-harness-bootstrap\.md|modul-05-planning-harness\.md|modul-06-roadmap\.md|regelwerk/README\.md' \
        -- 'harness/conventions/*.md' | grep -oE 'MR-[0-9]+'
      # -> MR-004 MR-006 MR-007 MR-008 MR-009 MR-010 MR-012 MR-013 MR-024 MR-027
      #    MR-029 MR-035 MR-037 MR-038 MR-040 MR-041 MR-047 MR-051 MR-052 MR-053   (20, kein Erwartungswert)
      ```

      **Suchhilfe 2 — Auto-Kontext.** [`MR-035`](../../../../harness/conventions.md#mr-035) und
      [`MR-056`](../../../../harness/conventions.md#mr-056) führen `modul-05` und `modul-06` als
      Mitglieder, und beide Module ändern sich. Berührt ist ihr Inhalt; ob auch der
      Auswahl-Maßstab, prüft der Durchgang. Die Zahlen beider Einträge werden gegen den neuen Baum
      nachgemessen.

      **Suchhilfe 3 — Kandidaten aus dem einzigen Hunk in `modul-02`.** Der Hunk liegt im Punkt
      *„Der Review vergleicht auch die Form"*
      ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Stufe (b)).
      Derselbe Punkt führt den Satz *„Das alte Verzeichnis fällt erst, wenn der Review durch
      ist"*, während `make vendor-baseline` bei einem anderen vorliegenden Tag vor jedem Zugriff
      abbricht ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md));
      Kandidat ist [`MR-007`](../../../../harness/conventions.md#mr-007). Die neuen
      Klassen-Aussagen nennen `MR`-Einträge; Kandidaten sind
      [`MR-039`](../../../../harness/conventions.md#mr-039), das
      [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) eigens nennt, und
      [`MR-045`](../../../../harness/conventions.md#mr-045), das die Form des Blocks setzt. Hier
      stehen Kandidaten, keine Urteile.

      **Die Stichprobe gegen den Bestand** läuft nach der Prozedur unabhängig vom Delta
      (Baseline-Regelwerk `modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline,
      Punkt *„Eine Stichprobe gegen den Bestand, nicht gegen das Delta"*) und prüft die Aussage
      von [`MR-000`](../../../../harness/conventions.md#mr-000). Hängt ihre Antwort an einer
      Klassen-Aussage, gehört sie in Liefer-Punkt 3
      ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Der Unterschied nennt
      offene Vorlagen).

      **Erfüllt ist der Punkt, wenn die Liste vollständig abgearbeitet ist, auch ohne einen
      betroffenen Eintrag**; das Ergebnis steht in §7. Das **Schreiben** eines Ausgangs ist
      Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der Implementations-Lauf
      liefert das Übergabe-Artefakt: die abgearbeitete Liste mit je einem Ausgang, das Ergebnis
      der Stichprobe, dazu Tag, Datum und den gemessenen sha256 für die Buchung in §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) in der Form von
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Festlegung 2.
- [ ] **3 — Der Vorlagen-Bericht zum Tag `v6.9.0` liegt unter `docs/migrations/` vor, in der
      Report-Form aus [`harness/migration.md`](../../../../harness/migration.md) §5, und hält die
      bestehenden Instanzen.**

      1. **Je Vorlage eine Zeile**
         (`find .harness/baseline/v6.9.0/templates -name '*.template.md' | wc -l` → die
         Zeilenzahl, kein Erwartungswert). Der Buchstabe folgt der Klasse, die das Register der
         Vorlage zuweist, und zwar **nach** der Zuordnung, die der Architect-Lauf mit dem Tausch
         trifft.
      2. **Das Delta ist zwischen den zwei vendorten Bäumen gemessen**, am Tausch-Commit und
         seinem Vorgänger, nicht allein im Kurs-Klon.
         [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Außerhalb der
         Prozedur misst im Klon drei geänderte Vorlagen: `README`, `roadmap` und `slice` unter
         `docs/plan/planning/`. Jede weitere Vorlage, die sich zwischen den vendorten Bäumen
         unterscheidet, bekommt ihren Ausgang und steht im Bericht als Befund (§6, Risiko 2).
      3. **Die Vorlagen mit Delta.** Die zwei einmaligen — Planungs-README und Roadmap, je eine
         Instanz — tragen *übernommen* (Commit-Hash) oder *schon erfüllt* (Fundstelle).
         *Bewusst abweichend* steht nicht zur Verfügung, auch nicht mit einem bestehenden
         `MR`-Eintrag als Beleg ([`harness/migration.md`](../../../../harness/migration.md) §5 a).
         Die wiederkehrende Slice-Vorlage trägt *append-only* mit dem Sprung-Datum.
      4. **Die bestehenden Instanzen**, gehalten gegen die Klassen-Aussagen der Ziel-Fassung
         (Ist-Maßstab, [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
         Festlegung 2) — so gesetzt vom Auftraggeber
         ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Geschichte,
         Zeile *Accepted*). Für jede Register-Zeile, die der Architect-Lauf mit dem Tausch gegen
         diese Aussagen einordnet, sind ihre Instanzen unter dem zugewiesenen Buchstaben geprüft
         und berichtet: unter Buchstabe b mit dem Befund, dass sie unverändert bleiben; unter
         Buchstabe a mit einem der drei verfügbaren Ausgänge. Die Kandidaten nennt
         [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Kontext; ihre
         Instanzen, keine Erwartungswerte:

         ```sh
         find docs/plan/planning/done -maxdepth 1 -iname 'welle-*-results.md' | wc -l   # 14  welle-results
         ls harness/sensors/*.md | wc -l                                                 # 15  gate
         ls harness/conventions/*.md harness/conventions/done/*.md | wc -l               # 60  MR-NNN-titel
         ```

         Eine Register-Zeile, die die Ziel-Fassung nicht nennt (`observation.template.md`),
         bleibt in `harness/migration.md` §6 offen und im Bericht ausgenommen.

      Der Bericht wird von `docs-check` gescannt; jede `LH-`/`ADR-`/`MR-`-Kennung darin ist ein
      Anker-Link ([`MR-001`](../../../../harness/conventions.md#mr-001)).
- [ ] `make gates` grün über dem Liefer-Stand, gedeckt durch den Stempel
      `.harness/state/gates-passed.diffsha`. Nicht gedeckt sind die Commits danach
      (Architect-Buchung, Closure).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und
      §Adoptierte Konventions-Quellen tragen den neuen Stand, und
      [`harness/migration.md`](../../../../harness/migration.md) trägt die Register-Zuordnung —
      **als Architect-Commit**, aus dem Übergabe-Artefakt von Liefer-Punkt 2.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`) | update | kanonisches Pin-Paar; `make vendor-baseline` liest es und läuft deshalb danach |
| [`.d-check.yml`](../../../../.d-check.yml) (`sources`-`url`/`sha256`) | update | fail-closed an das Makefile-Paar gekoppelt |
| `internal/fetch/baseline.go` (`DefaultTag`, `DefaultBaselineSHA256`) | update | dasselbe Asset wandert ins Zielrepo ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) |
| `.harness/baseline/` — der abgelöste Tag-Ordner | entfällt | `make vendor-baseline` bricht bei einem anderen vorliegenden Tag ab |
| `.harness/baseline/v6.9.0/{regelwerk,templates}/` + `SHA256SUMS` | neu | der vendored Baum aus dem verifizierten Release-Asset |
| `.claude/rules/*.md` — die sieben Zeiger in den vendored Baum | update | der Tag steht im Symlink-Ziel |
| 58 lebende `.md` mit 126 Markdown-Links ins Tag-Segment | update | gate-sichtbar (§1) |
| 16 lebende `.md` mit 108 Inline-Code-Pfaden | update, je Treffer geurteilt | gate-unsichtbar (§1) |
| [`harness/conventions/`](../../../../harness/conventions/) — die betroffenen Einträge | neu / Kopf-Marke | Ausgang der Freshness-Review; **Architect-Commit** |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline, §Adoptierte Konventions-Quellen | update | Buchung des Vollzugs; **Architect-Commit** |
| [`harness/migration.md`](../../../../harness/migration.md) §1, §4 bis §6 | update | 44 tag-tragende Pfade und die Register-Zuordnung mit dem Tausch; **Architect-Commit** |
| `docs/plan/planning/README.md` | update, falls *übernommen* | einzige Instanz der Planungs-README-Vorlage; schreibende Rolle offen (§6) |
| `docs/plan/planning/in-progress/roadmap.md` | update, falls *übernommen* | einzige Instanz der Roadmap-Vorlage; **Planner-Commit** |
| Instanzen einer Register-Zeile unter Buchstabe a | update, falls *übernommen* | Obergrenze in §4 |
| Vorlagen-Bericht zum Tag `v6.9.0` unter `docs/migrations/` | neu | Report-Form aus `harness/migration.md` §5 |
| Übergabe-Artefakt an den Architect (Ausgangs-Liste · Stichprobe · Tag · Datum · sha256) | neu | Einträge und Buchung hängen daran |

**Keine Testdatei-Zeile.** Der Slice ändert keine Zusage eines Sensors. Die drei vorhandenen
Wächter der Pin-Kopplung laufen unverändert mit und färben rot, wenn eine der fünf Stellen stehen
bleibt.

**Reihenfolge, weil sie hier trägt:**

- Erst die Pins, dann `make vendor-baseline`: das Ziel liest `BASELINE_TAG` und
  `BASELINE_ZIP_SHA256` als Argumente. Der sha256 steht vor dem Vendoring-Lauf fest; weicht er vom
  berechneten ab, bricht der Lauf vor jedem Schreibzugriff ab
  ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)).
- Der abgelöste Baum weicht vor dem Vendoring. Den Form-Vergleich, den die Prozedur über die zwei
  vendorten Bäume verlangt, fährt Liefer-Punkt 3.2 über das Commit-Paar des Tauschs. Ob das den
  Satz *„Das alte Verzeichnis fällt erst, wenn der Review durch ist"* erfüllt, ist die Frage aus
  Suchhilfe 3 und wird hier nicht entschieden.
- Die Register-Zuordnung des Architect-Laufs steht vor Liefer-Punkt 3.4.
- Tausch-Commit und Adress-Nachzug gehen in **denselben Push**.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei,
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) auf `Accepted`, und der
Lauf hat einmal Netz für `make vendor-baseline` und `make regelwerk-check`. Die ersten zwei
Bedingungen sind am Datum dieses Plans erfüllt: `ls docs/plan/planning/in-progress/*.md` nennt nur
die Roadmap, und
`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md` liefert
`Accepted`. Der `git mv` nach `in-progress/` landet auf dem Hauptzweig, vor der Arbeit, und
derselbe Zug nimmt den Ruhe-Marker der Roadmap zurück (§6, Risiko 8).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Über die Inline-Treffer aus
  Liefer-Punkt 1 sind mehr Urteile zu fällen (Adresse gegen datierte Mess-Aussage) als
  mechanische Ersetzungen. Dann wird der Nachzug je Eigentümer geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Drei Bedingungen, jede für sich hinreichend.
  **(a)** Die Freshness-Review trifft *widerspricht*, und der Rückbau zieht mehr nach als den
  Eintrag selbst — ein Werkzeug, ein Gate oder eine Hard Rule, etwa die Sperre von
  `make vendor-baseline` (Suchhilfe 3). Das ist eine Übergabe an den Architect, der Slice wartet.
  **(b)** Liefer-Punkt 3.4 findet unter Buchstabe a eine Instanz-Gruppe, die weder *schon erfüllt*
  noch *keine Instanz* ist, und ihre Umschrift reicht über die zwei Einzel-Instanzen hinaus. Weil
  die Setzung des Auftraggebers diese DoD bindet, entscheidet er zwischen Folge-Slice und
  Carveout; der Slice wartet. **(c)** Der am Asset gemessene sha256 weicht vom Upstream-Release
  ab, oder `make vendor-baseline` bricht an seiner Sperre ab — dann ist die Provenienz der Befund.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make baseline-verify` meldet `v6.9.0 OK`, und die drei Pin-Wächter in `make gates` sind grün
   über dem Liefer-Stand; die zwei Link-Kommandos aus §1 und das Symlink-Kommando aus §2
   Liefer-Punkt 1 liefern **0**.
2. Der Vorlagen-Bericht trägt je Vorlage eine Zeile und den Abschnitt zu den bestehenden
   Instanzen aus Liefer-Punkt 3.4.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke), §7. Die Form ist nicht vorweggenommen; sie hängt am Ergebnis der Durchgänge.

**Die Closure schreibt der Planner, nicht der ausführende Lauf**
([`AGENTS.md`](../../../../AGENTS.md) §3.10), in einem eigenen Commit und in frischem Kontext.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Den Ausgang setzt die Closure. *Absehbar* nennt, welcher Ausgang unter welcher Bedingung eintritt.

1. **Der Adress-Nachzug ersetzt eine Mess-Aussage, die ihren Tag richtig nennt.** Ein `sed` über
   `v6.8.0` trifft auch Sätze, die eine Messung gegen `v6.8.0` datieren
   ([`MR-033`](../../../../harness/conventions.md#mr-033)); kein Gate sieht es. Diese Datei ist
   selbst betroffen: Die Kommandos in §1 messen den Vorzustand und behalten den abgelösten Tag.
   *Absehbar:* entfallen, wenn je Treffer geurteilt ist; sonst eingetreten, Beleg in
   `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`.
2. **Das Vorlagen-Delta zwischen den vendorten Bäumen ist größer als das im Klon.** Beim
   vorigen Sprung unterschieden sich zwei Vorlagen nur im vendorten Baum
   ([slice-sprung-auf-v680-wird-vollzogen](../done/slice-sprung-auf-v680-wird-vollzogen.md) §7).
   *Absehbar:* entfallen, wenn Liefer-Punkt 3.2 vendored misst und jede weitere Vorlage einen
   Ausgang trägt; misst der Lauf nur im Klon, eingetreten, Beleg in
   `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum`.
3. **Die Sperre von `make vendor-baseline` steht neben dem Satz, dass das alte Verzeichnis erst
   nach dem Review fällt** — und dieser Satz liegt in dem einzigen Punkt, den `modul-02` ändert.
   Unter der Übernahme-Vorgabe hätte *widerspricht* hier eine Werkzeug-Änderung zur Folge.
   *Absehbar:* entfallen bei *bleibt gültig* oder *gegenstandslos* für
   [`MR-007`](../../../../harness/conventions.md#mr-007); sonst eingetreten, Rückführung (a) und
   ein Folge-Slice für das Werkzeug.
4. **Unter Buchstabe a fehlt das Ventil *bewusst abweichend*.** Ordnet der Architect eine
   Register-Zeile mit vielen Instanzen dort ein, muss jede abweichende Instanz *übernommen*
   werden. *Absehbar:* entfallen bei *schon erfüllt* oder Buchstabe b; sonst eingetreten,
   Rückführung (b).
5. **Kein Sensor deckt die Kopplung Baum ↔ Pin.** `make baseline-verify` entdeckt das
   Tag-Verzeichnis, statt `BASELINE_TAG` zu lesen, und `test/sources-pin.bats` koppelt die Pins
   nur untereinander. *Absehbar:* entfallen, sobald Baum und alle fünf Pins `v6.9.0` tragen; die
   Werkzeug-Eigenschaft bleibt benannt
   ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Fitness Function).
6. **Die Provenienz Asset → vendored Baum hält nichts**
   ([`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
   Konventions-Quellen). *Absehbar:* weiter offen, Register-Eintrag
   `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`; erhöht nur, wenn der Baum per
   Hand-Kopie entsteht.
7. **[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) steht auf
   `Proposed`** und bindet trotzdem die Form der Buchung. *Absehbar:* entfallen, wenn die Buchung
   in der Form steht und die Frage nicht gestellt wird; sie zu beantworten wäre Architect-Arbeit.
8. **Die Lifecycle-Züge machen den Ruhe-Marker der Roadmap falsch.** Der Zug nach
   `in-progress/` und die Closure nach `done/` kippen ihn, und `make slice-mv` zieht Pfade nach,
   keine Zustandssätze. *Absehbar:* entfallen, wenn beide Züge ihn mitziehen; sonst eingetreten,
   Beleg in `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`.
9. **Die offenen Pläne werden gegen den neuen Stand nicht gehalten.** Die neuen Kanten verschieben,
   was aus einem Plan in `open/` oder `next/` werden darf (`ls docs/plan/planning/open/*.md | wc -l`
   → **66**, `ls docs/plan/planning/next/*.md | wc -l` → **23**, keine Erwartungswerte).
   *Absehbar:* weiter offen, Register-Eintrag
   `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`.
10. **Für die Planungs-README nennt keine Quelle die schreibende Rolle.** Ihre Zeile zu `done/`
    trägt den Text von `v6.8.0` (``grep -n '^| `done/`' docs/plan/planning/README.md``), und
    *übernommen* ändert sie. [`AGENTS.md`](../../../../AGENTS.md) §3.8 lässt die Frage offen.
    *Absehbar:* entfallen, wenn der Architect sie vor dem Commit beantwortet.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Freshness-Durchgang und Stichprobe (Liefer-Punkt 2):** offen bis zur Closure. Für den
  Ausgang *bleibt gültig* sieht die Baseline keinen Vermerk im Eintrag vor; ist das das Ergebnis,
  steht der Durchgang nur an dieser Stelle.
- **Steering-Loop-Eintrag:** offen bis zur Closure; die Form ist nicht vorweggenommen (§5).
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure. Die Messung der neuen Kanten hat ihre Adresse bereits:
  `slice-stilllegungs-kanten-sind-gemessen` (§1).
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** entfällt hier — dieses Repo fährt Wellen (§2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo). Der
Tag steht in `Makefile`, `.d-check.yml`, `internal/fetch/`, `.claude/rules/`, `harness/`, `docs/`
und in der Planungs-Ablage; keine engere Sub-Area umschließt ihn. `harness/tools/` (`TOOLS`) und
`.codex/` (`CODEX`), die zwei anderen deklarierten Sub-Areas
([`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro
Sub-Area), sind nicht berührt: `git grep -l 'v6\.8\.0' -- harness/tools .codex | wc -l` → **0**,
kein Erwartungswert. `*` erfüllt die Schwelle ≥ 2 von 3 Achsen als deklarierte Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, am gemergten Stand
(`git status -sb` meldet `## main...origin/main` ohne Vor- oder Nachlauf).
`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **121** Einträge. Alle führen die
Sub-Area `*`; gesichtet ist deshalb nach Gegenstand. Der Zähler je Treffer ist
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, der Stand die erste
Zeile seiner `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | 20 | geplant, `slice-ortswechsel-zieht-sein-zustandsfeld-nach` | §6, Risiko 8 |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 14 | verkörpert | jede Zahl dieses Plans steht neben ihrem Kommando |
| `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` | 14 | verkörpert | der Nachzug aus Liefer-Punkt 1 lässt eingefrorene Artefakte aus (§1) |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 6 | geplant, `slice-offene-plaene-gegen-den-neuen-stand` | §6, Risiko 9 |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | 4 | verkörpert | §6, Risiko 1 |
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4 | verkörpert | der Tausch ist ein Ortswechsel des Baums; eingefrorene Adressen hält [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) |
| `baseline-aussage-ohne-mess-tag` | 4 | verkörpert | jede Messung dieses Slice nennt ihren Tag |
| `gate-modul-erreicht-den-vendored-baum-nicht` | 3 | geplant, `slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer` | die 108 Inline-Pfade aus §1 |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan (unten) |
| `re-baseline-ohne-inventur-slice` | 2 | offen | kein Auftreten: das Delta ist in [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Kontext dateigenau erhoben, und die Form-Pflichten sind in Liefer-Punkt 3 gebündelt statt als Nachzügler |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 2 | offen | kein Auftreten: dieser Plan sagt nichts darüber, ob `make docs-check` die neuen Kanten trägt (§1) |
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 2 | offen | die drei geänderten Vorlagen nennen im Klon nur einen Abschnitt von `modul-05`; Liefer-Punkt 3 prüft das am vendorten Baum |
| `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum` | 1 | offen | §6, Risiko 2 |
| `delta-durchgang-uebersieht-deckung` | 1 | offen | Liefer-Punkt 2 liest den Volltext |
| `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` | 1 | offen | §6, Risiko 6 |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 1 | offen | außerhalb von Markdown tragen nur die drei Pin-Dateien den Tag (§1) |

**Keiner der Einträge erreicht mit diesem Slice zum ersten Mal 3×.** Die drei bei 2× träfe er nur
auf einem Weg, den §1 und §2 ausschließen: mit Form-Pflichten als Nachzüglern, mit einer
ungemessenen Werkzeug-Aussage oder mit einer übernommenen Vorlage, die einen fehlenden Pfad
nennt. Tritt einer davon doch ein, ist der Eintrag bei 3× eine Lücke mit eigenem Folge-Slice.
**Kein Eintrag über der Schwelle steht auf `offen`:** Alle aufgeführten mit mindestens drei
Belegen tragen `geplant` oder `verkörpert`, und jede genannte Kennung liegt als Datei in `open/`.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF.** Der Block steht trotzdem, weil das Evidenz-Risiko dieses Slice
nicht niedrig ist:

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF, deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
  §Modus-Deklaration pro Sub-Area.
- **Konventionen-Dichte:** hoch. `ls harness/conventions/*.md | wc -l` → **56** aktive Einträge,
  kein Erwartungswert. Der Gegenstand ist in [`MR-007`](../../../../harness/conventions.md#mr-007),
  [`MR-033`](../../../../harness/conventions.md#mr-033),
  [`MR-035`](../../../../harness/conventions.md#mr-035) und
  [`MR-056`](../../../../harness/conventions.md#mr-056) verankert, und der Block selbst ist
  Liefer-Punkt 2.
- **Phase-Reife:** Phase 5.
  [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen bucht
  *„die Zeile des achten Sprungs"* in `harness/migration.md` §1; Prozedur und Träger sind erprobt.
- **Evidenz-/Diskrepanz-Risiko:** mittel. Die Tausch-Hälfte ist mechanisch und durch drei
  Pin-Wächter gedeckt. Das Risiko sitzt in drei Urteilen: Adresse gegen datierte Mess-Aussage
  über 108 Inline-Treffer, die Sperre neben dem geänderten Punkt in `modul-02`, und die
  bestehenden Instanzen ohne das Ventil *bewusst abweichend*.
- **Reconciliation-Aufwand:** keiner — GF, keine *reconciliation.md*. Graduation entfällt; die
  Folge-Trigger sind die Rückführungen (a) und (b) in §4.

### Zur Bemessung dieses Slice

Der Plan ist größer als der des Vorgängers, und der Zuwachs sitzt in einer Achse: den bestehenden
Instanzen aus Liefer-Punkt 3.4, die der Auftraggeber an diese DoD gebunden hat. Der Eintrag
`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` steht bei 3× und trifft die Plan-Klasse selbst.
Der Plan führt Suchhilfen deshalb als Suchhilfen und nimmt kein Ergebnis vorweg. Wächst die
Umsetzung über §1 hinaus, ist das eine Plan-Änderung und eine Rückführung, kein Nachtrag.

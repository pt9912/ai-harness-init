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

In den Kommandos steht `K` für einen Klon des Kurs-Repos, eine Host-Voraussetzung und kein
Artefakt dieses Repos ([`ADR-0052`](../../adr/0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md)).
Vergleicht ein Kommando zwei Tags, ist seine Zahl fest; zählt es im Arbeitsbaum, ist sie **kein
Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Tag-Klammer),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (zwei Pins wandern
ins Zielrepo),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (regierende Fassung;
§Konsequenzen und §Kopplung verteilen die Folgepflichten),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegungen 1, 2, 4),
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2, Delta-Basis),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2,
Form der Buchung; `Proposed`),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md),
[`MR-007`](../../../../harness/conventions.md#mr-007),
[`MR-035`](../../../../harness/conventions.md#mr-035),
[`MR-056`](../../../../harness/conventions.md#mr-056),
[`MR-025`](../../../../harness/conventions.md#mr-025),
[`MR-033`](../../../../harness/conventions.md#mr-033),
[`MR-051`](../../../../harness/conventions.md#mr-051).

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
gelesen, und jeder betroffene Eintrag trägt einen der fünf Ausgänge. Der Vorlagen-Bericht zum
Tag `v6.9.0` unter `docs/migrations/` liegt vor und berichtet neben den Vorlagen mit Delta auch
die **bestehenden Instanzen**, die die Klassen-Aussagen der Ziel-Fassung erreichen.

**Reichweite der Übernahme-Vorgabe: delta-gebunden**, so wie
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen sie verbucht
(Setzung des Auftraggebers, 2026-09-16). Was das Delta berührt, übernimmt der Slice vollständig:
Ein Eintrag mit *widerspricht* tritt zurück, und *bewusst abweichend* entfällt im
Instanz-Durchgang — auch für Instanzen, die eine neue Klassen-Aussage erreicht. Eine Abweichung,
deren Baseline-Text das Delta nicht berührt, bleibt stehen; so
[`MR-007`](../../../../harness/conventions.md#mr-007) Setzung 4, die den Satz *„Das alte
Verzeichnis fällt erst, wenn der Review durch ist"* aus `modul-02-harness-bootstrap.md` ersetzt
(Feld `Ersetzt-Baseline-Regel`).

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
   ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2); ein
   Durchgangs-Slice vor dem Tausch hätte keinen.
3. **Die Größenregel hält:** drei Liefer-Punkte, zwei Schichten (vendored Baum mit
   Pin-Konfiguration; Doku- und Planungs-Artefakte). Die Obergrenze des Zuwachses steht als
   Rückführung in §4.

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
git grep -oE '`[^`]*\.harness/baseline/v6\.8\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 108 Inline-Code-Pfade
```

Die 126 Links sind gate-sichtbar und fallen in dem Moment, in dem das `v6.8.0`-Verzeichnis
verschwindet; Tausch- und Nachzugs-Commit gehören darum in denselben Push (Baseline-Regelwerk
`grundlagen-traceability.md` §Herkunfts-Anker). Die 108 Inline-Pfade sieht kein Gate
([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul
`codepaths`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Messung, ob `make slice-mv` und `make docs-check` die neuen Kanten `open → done` und
  `next → done` tragen.** *Ein Folge-Slice übernimmt sie:* `slice-stilllegungs-kanten-sind-gemessen`
  — sein §1 führt genau diese Messung als Ziel. *Es wäre ein anderer Vorgang:* Dieser
  Slice arbeitet am Gegenstand, jener misst Werkzeuge, und sein Maßstab — der Abschnitt *Ein
  Slice, dessen Gegenstand ein anderer übernimmt* in `modul-05-planning-harness.md` — liegt erst
  nach diesem Slice vendored vor. Dieser Plan sagt deshalb **nichts** darüber, ob die Werkzeuge
  die Kanten tragen (§8).
- **Keine Anwendung der Kanten auf Slices dieses Repos** — *anderer Vorgang*, nach der Messung
  ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Was diese Festlegung
  nicht tut).
- **Keine Zuordnung von Register-Zeilen im Implementations-Kontext** — sie ist der
  Architect-Schritt aus §3; Liefer-Punkt 3 liest sie (*Schicht-Abgrenzung*).
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
- **Kein neuer Wächter für den Vorgang** — *anderer Vorgang*
  ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Fitness Function).

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

- [x] **1 — Jeder Träger des Tags steht auf `v6.9.0`, und keine lebende Adresse bleibt auf dem
      abgelösten Tag.** Fünf Träger-Klassen, eine Eigenschaft. **Rot ist ein halb getauschtes
      Repo nur in zwei Fällen, gezogen bei der Closure:** wenn eine Pin-Stelle von den übrigen
      abweicht und wenn ein Markdown-Link auf einen fehlenden Baum zeigt. **Grün bleibt es in drei
      Fällen:** alle fünf Pins stehen auf dem alten Tag und der Baum auf dem neuen; ein Symlink
      zeigt ins Leere; ein Inline-Pfad ist veraltet (Verifikation
      `docs/reviews/2026-09-17-slice-sprung-auf-v690-wird-vollzogen-verify.md` §2 V-3 und §5,
      Fall C). Der erste Grün-Fall ist die unbewachte Hälfte der Provenienz-Kette, die
      [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
      Konventions-Quellen ausweist. Den Zustand belegen deshalb die direkten Messungen der
      Verifikation, nicht die Gates.

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
         **Der sha256 wird am Release-Asset gemessen und steht im Umsetzungs-Lauf neben dem
         Kommando, das ihn liefert**; sonst ist dieser Punkt offen.
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
      **Der Rest, bei der Closure abgezählt:** 27 Treffer am Stand `b31d5179`
      (`git grep -cE "$I" b31d5179 -- "${PS[@]}"`, mit dem Pathspec aus §1 und dem Inline-Muster
      der zweiten Zeile dort als `I`). Davon stehen 25 in `docs/migrations/v6.8.0.md`: Sie sind
      datierte Aussagen des Berichts über den damaligen Baum
      ([`MR-033`](../../../../harness/conventions.md#mr-033)) und keine Adressen. Je 1 Treffer steht
      in diesem Plan (die Kommandos in §1 messen den Vorzustand) und in
      `slice-der-mutations-lauf-ist-begrenzbar`. Alle drei Gruppen bleiben stehen.
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
- [x] **2 — Die Freshness-Review des Adaptions-Blocks ist über alle 56 aktiven Einträge
      gefahren, jeder betroffene trägt einen der fünf Ausgänge, und die Stichprobe gegen den
      Bestand ist gelaufen.** Die Frage je Eintrag: Regelt eine der im Sprung geänderten
      Regelwerks-Dateien das, wofür dieser Eintrag angelegt wurde?

      ```sh
      git -C "$K" diff --name-only v6.8.0..v6.9.0 -- lab/regelwerk
      # -> README.md, modul-02-harness-bootstrap.md, modul-05-planning-harness.md,
      #    modul-06-roadmap.md unter lab/regelwerk/   (Tag-Vergleich, feste Zahl 4)
      ```

      Gelesen wird der **Volltext** der geänderten Datei am Tag `v6.9.0`, nicht allein ihr Hunk
      (§8, `delta-durchgang-uebersieht-deckung`). Prozedur und Ausgänge:
      [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Entscheidung,
      [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4; die
      Übernahme gilt in der Reichweite aus §1. Die Grundgesamtheit ist die volle Liste
      (`ls harness/conventions/*.md | wc -l` → **56**, kein Erwartungswert).
      [`MR-039`](../../../../harness/conventions.md#mr-039) nennt
      [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) eigens als Gegenstand.
      Die Stichprobe gegen den Bestand läuft nach der Prozedur und prüft die Aussage von
      [`MR-000`](../../../../harness/conventions.md#mr-000).

      **Erfüllt ist der Punkt, wenn die Liste vollständig abgearbeitet ist, auch ohne einen
      betroffenen Eintrag**; das Ergebnis steht in §7. Das **Schreiben** eines Ausgangs ist
      Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der Implementations-Lauf
      liefert das Übergabe-Artefakt: die abgearbeitete Liste mit je einem Ausgang, das Ergebnis
      der Stichprobe, dazu Tag, Datum und den gemessenen sha256 für die Buchung in §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) in der Form von
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Festlegung 2.
- [x] **3 — Der Vorlagen-Bericht zum Tag `v6.9.0` liegt unter `docs/migrations/` vor, in der
      Report-Form aus [`harness/migration.md`](../../../../harness/migration.md) §5, und hält die
      bestehenden Instanzen.**

      1. **Je Vorlage eine Zeile**
         (`find .harness/baseline/v6.9.0/templates -name '*.template.md' | wc -l` → die
         Zeilenzahl, kein Erwartungswert). Der Buchstabe folgt der Klasse, die das Register der
         Vorlage zuweist, **nach** dem Architect-Schritt aus §3.
      2. **Das Delta ist zwischen den zwei vendorten Bäumen gemessen**, am Tausch-Commit und
         seinem Vorgänger, nicht allein im Kurs-Klon. Jede Vorlage, die sich dort unterscheidet,
         bekommt ihren Ausgang (§6, Risiko 2).
      3. **Die Vorlagen mit Delta.** Die zwei einmaligen tragen je einen Ausgang nach
         Buchstabe a, *bewusst abweichend* entfällt
         ([`harness/migration.md`](../../../../harness/migration.md) §5 a). Die Planungs-README
         ist eine Singleton-Instanz und weicht schon in den Zeilen `next/` und `in-progress/` von
         der Vorlage ab; *schon erfüllt* scheidet aus, sie wird *übernommen* (§6, Risiko 6). Bei
         der Roadmap steht das Delta in einem Hinweis-Kommentar, den die Instanz nicht führt; die
         Regel steht dort als Prosa unter §Historische Trigger-Verschiebungen, und *übernommen*
         heißt, diese Prosa zu ergänzen. Die wiederkehrende Slice-Vorlage trägt *append-only* mit
         dem Sprung-Datum.
      4. **Die bestehenden Instanzen** — so gesetzt vom Auftraggeber
         ([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Geschichte,
         Zeile *Accepted*). Für jede Register-Zeile, die der Architect-Schritt aus §3 einordnet,
         sind ihre Instanzen unter dem zugewiesenen Buchstaben geprüft und berichtet: unter
         Buchstabe b mit dem Befund, dass sie unverändert bleiben; unter Buchstabe a mit einem der
         drei verfügbaren Ausgänge. **Der Bericht weist diesen Abschnitt als Ist-Maßstab aus**
         ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), nicht
         als Schritt der Prozedur; so bleibt Re-Evaluierungs-Trigger 3 von
         [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) unberührt. Eine
         Register-Zeile, die die Ziel-Fassung nicht nennt (`observation.template.md`), bleibt in
         `harness/migration.md` §6 offen und im Bericht ausgenommen.

      Der Bericht wird von `docs-check` gescannt; jede `LH-`/`ADR-`/`MR-`-Kennung darin ist ein
      Anker-Link ([`MR-001`](../../../../harness/conventions.md#mr-001)).
- [x] `make gates` grün über dem Liefer-Stand, gedeckt durch den Stempel
      `.harness/state/gates-passed.diffsha`. Nicht gedeckt sind die Commits danach
      (Architect-Buchung, Closure).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und
      §Adoptierte Konventions-Quellen tragen den neuen Stand (**Architect-Commit** aus dem
      Übergabe-Artefakt von Liefer-Punkt 2); [`harness/migration.md`](../../../../harness/migration.md)
      trägt die Register-Zuordnung (**Architect-Commit** aus dem Schritt in §3).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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
| lebende `.md` mit den 126 Markdown-Links ins Tag-Segment | update | gate-sichtbar (§1) |
| lebende `.md` mit den 108 Inline-Code-Pfaden | update, je Treffer geurteilt | gate-unsichtbar (§1) |
| [`harness/conventions/`](../../../../harness/conventions/) — die betroffenen Einträge | neu / Kopf-Marke | Ausgang der Freshness-Review; **Architect-Commit** |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline, §Adoptierte Konventions-Quellen | update | Buchung des Vollzugs; **Architect-Commit** |
| [`harness/migration.md`](../../../../harness/migration.md) §1, §4 bis §6 | update | tag-tragende Pfade und Register-Zuordnung; **Architect-Commit** |
| `docs/plan/planning/README.md` | update | Singleton-Instanz, *übernommen* im Instanz-Durchgang (§6, Risiko 6) |
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
- **Register-Zuordnung, Architect-Kontext:** nach dem Tausch-Commit und vor Liefer-Punkt 3.4
  ordnet der Architect die Register-Zeilen `welle-results`, `MR-NNN-titel` und `gate` ein. Die
  Ziel-Fassung ordnet alle drei selbst ein; der Schritt liest den Wortlaut von `v6.9.0` ab
  (Folgepflicht *Architect, mit dem Tausch*,
  [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen). Eigener
  Architect-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- Tausch-Commit und Adress-Nachzug gehen in **denselben Push**.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei,
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) auf `Accepted`, und der
Lauf hat einmal Netz für `make vendor-baseline` und `make regelwerk-check`. Der `git mv` nach
`in-progress/` landet auf dem Hauptzweig, vor der Arbeit, und derselbe Zug nimmt den Ruhe-Marker
der Roadmap zurück (§6, Risiko 4).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Über die Inline-Treffer aus
  Liefer-Punkt 1 sind mehr Urteile zu fällen (Adresse gegen datierte Mess-Aussage) als
  mechanische Ersetzungen. Dann wird der Nachzug je Eigentümer geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Drei Bedingungen, jede für sich hinreichend.
  **(a)** Die Freshness-Review trifft *widerspricht*, und der Rückbau zieht mehr nach als den
  Eintrag selbst — ein Werkzeug, ein Gate oder eine Hard Rule. Das ist eine Übergabe an den
  Architect, der Slice wartet.
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
   `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`. — **Ausgang: entfallen.** Jeder
   Inline-Treffer ist geurteilt. Die Verifikation hat die Zahl am Ausgangsstand aufgeteilt (§2
   des Berichts): Den Nachzug trugen die Rollen-Commits, die Spezifikation verlor ihre Treffer,
   und der Rest steht abgezählt in §2, Liefer-Punkt 1. Kein Treffer, der eine Messung gegen
   `v6.8.0` datiert, wurde ersetzt.
2. **Das Vorlagen-Delta zwischen den vendorten Bäumen ist größer als das im Klon.** Beim
   vorigen Sprung unterschieden sich zwei Vorlagen nur im vendorten Baum
   ([slice-sprung-auf-v680-wird-vollzogen](../done/slice-sprung-auf-v680-wird-vollzogen.md) §7).
   *Absehbar:* entfallen, wenn Liefer-Punkt 3.2 vendored misst und jede weitere Vorlage einen
   Ausgang trägt; misst der Lauf nur im Klon, eingetreten, Beleg in
   `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum`. — **Ausgang: entfallen.**
   Liefer-Punkt 3.2 hat zwischen `63e0964e^` und `63e0964e` gemessen: fünf Vorlagen mit Delta
   statt drei im Klon, jede mit Ausgang (Verifikation §4). Die zwei zusätzlichen,
   `conventions.template.md` und `AGENTS.template.md`, deckt dieses Risiko. Die Zahl im Klon
   stand in diesem Plan als Vormessung mit Risiko; eine Beleg-Datei entsteht nicht.
3. **Unter Buchstabe a fehlt das Ventil *bewusst abweichend*.** `v6.9.0` nimmt
   Sensor-Gate-Dateien ausdrücklich von der Append-only-Logik aus. Landet `gate` damit im
   Architect-Schritt unter Buchstabe a, wiegt das schwer: Schon der Überschriften-Vergleich
   gegen `gate.template.md` zeigt
   Abschnitte, die die Vorlage nicht kennt — in `full-smoke.md`, `history-range-guard.md` und
   `slice-mv.md` unter `harness/sensors/`. Jede abweichende Instanz muss *übernommen* werden;
   Rückführung (b) ist damit realistisch. *Absehbar:* entfallen bei *schon erfüllt*; sonst
   eingetreten, Rückführung (b). — **Ausgang: eingetreten.** Der Architect-Schritt ordnete `gate`
   unter Buchstabe a ein (`3c566c9a`), und das Gliederungs-Kriterium traf 14 Sensor-Dateien
   (das Kommando steht im Beleg zu
   [`BEO-ALL/instanz-umfang-vor-seinem-kriterium-gemessen`](../observations/BEO-ALL/instanz-umfang-vor-seinem-kriterium-gemessen/observation.md)).
   Die Bedingung von Rückführung (b) war damit erfüllt. **Der Weg war keiner der zwei, die §4
   nennt:** Die Gruppe wurde **im Slice übernommen** (`5ea9a75d`, `42276db5`, `42a2164e`,
   `3b84a873`, `56a86a77`). Die Quelle dafür sind Setzungen des Auftraggebers vom 2026-09-16
   (Übernahme vollständig und delta-gebunden, Pflichtgliederung mit Freiraum nur innerhalb der
   Abschnitte) und vom 2026-09-17 (wörtlicher Umzug nur innerhalb derselben Datei). Alle drei
   stehen in [`harness/migration.md`](../../../../harness/migration.md) §5. Von der Gruppe
   bleibt nichts offen. Den angrenzenden Rest, die fünf Instanzen ohne Vorlagen-Delta, trägt der
   Folge-Slice `slice-gliederung-der-instanzen-ohne-vorlagen-delta`.
4. **Die Lifecycle-Züge machen den Ruhe-Marker der Roadmap falsch.** Der Zug nach
   `in-progress/` und die Closure nach `done/` kippen ihn, und `make slice-mv` zieht Pfade nach,
   keine Zustandssätze. *Absehbar:* entfallen, wenn beide Züge ihn mitziehen; sonst eingetreten,
   Beleg in `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`. — **Ausgang: entfallen.**
   Beide Züge ziehen den Marker mit: Der Claim nahm ihn zurück (`1aee7739`), und die Closure setzt
   ihn in einem eigenen Commit direkt nach dem Move, im selben Push.
5. **Die offenen Pläne werden gegen den neuen Stand nicht gehalten**, obwohl die neuen Kanten
   verschieben, was aus einem Plan in `open/` oder `next/` werden darf. *Absehbar:* weiter offen,
   Register-Eintrag `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`. — **Ausgang:
   weiter offen.** Der Beleg dieses Vorgangs steht in
   [`BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md)
   (`slice-212` und `slice-222`, siehe §7). Der Eintrag steht auf `geplant` mit
   `slice-offene-plaene-gegen-den-neuen-stand`, die Datei liegt in `open/`.
6. **Für die Planungs-README nennt keine Norm-Quelle die schreibende Rolle.** — **Ausgang:
   entfallen.** Setzung des Auftraggebers vom 2026-09-16: Die Datei ist die Singleton-Instanz
   einer Vorlage, die einmal beim Bootstrap angelegt wird (Baseline-Vorlagen-Index `v6.8.0`,
   `templates/README.md` §Ein- vs. wiederkehrende Templates). Der Instanz-Durchgang zieht sie wie
   jede einmalige Vorlage unter Buchstabe a nach; eine Eigentums-Frage stellt sich dafür nicht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), am Stand
`b31d5179`. Die Setzungen des Auftraggebers, auf die sich diese Notiz stützt, stammen vom
2026-09-16 und vom 2026-09-17.

- **Was hat funktioniert:**
  - Der Baum entstand über `make vendor-baseline` aus dem verifizierten Asset (`63e0964e`). Die
    drei Pin-Wächter hat die Verifikation aus dem richtigen Grund rot gesehen (Bericht §5, Fälle
    A und B).
  - Den Nachzug trug jeder Eigentümer in einem eigenen Commit: Implementer `a12a75ae`, Reviewer
    `1b643a87`, Architect `f599169f`, Planner `76e84171`. Tausch und Nachzug gingen in
    denselben Push.
  - Die Register-Zuordnung lag nach dem Tausch und vor dem Instanz-Durchgang (`3c566c9a`). Das
    Delta ist am vendorten Baum gemessen, und der Instanz-Abschnitt ist als Ist-Maßstab
    ausgewiesen.
- **Was ging anders als geplant:**
  - **Rückführung (b) feuerte, und der Slice wartete nicht** (§6 Risiko 3, Verifikation V-4).
    Die Gruppe `gate` wurde im Slice übernommen. Quelle dafür sind die Setzungen des
    Auftraggebers; bis zu dieser Notiz stand der gewählte Weg in keinem Artefakt.
  - **Eine Spec-Stelle ist berührt, obwohl der Kopf `—` führt.** `072c330c`, `b3dbb770` und
    `fcb88b9b` änderten `spec/spezifikation.md`: Die Verweise nach außen und zwei
    Herkunfts-Sätze sind entfernt, der Satz zum Sammelposten ist neu gefasst, und §7 Historie hat
    eine Zeile vom 2026-09-17. Quelle ist die Setzung vom 2026-09-16: Die Spezifikation zeigt
    nicht nach außen und nennt ihre Herkunft nicht, und ihre Verweise zieht in diesem Slice der
    Implementer nach. Der Kopf bleibt, wie er geplant war.
  - **Der DoD-Satz *„ein halb getauschtes Repo ist rot"* reichte weiter als seine Sensoren**
    (V-3). §2 schränkt ihn ein. Liefer-Punkt 1 ist über die direkten Messungen abgehakt, nicht
    über die Gates.
  - **Die Abzählung des Inline-Rests fehlte** (V-2); §2 Liefer-Punkt 1 trägt sie jetzt.
  - **Die Buchung des Vollzugs (`44f5c034`) lag vor vier Commits des Durchgangs** (`42a2164e`,
    `3b84a873`, `952aed15`, `56a86a77`; V-6). Ihre Bedingung war, dass die Report-Datei existiert,
    nicht dass der Durchgang abgeschlossen ist. Tag, Datum und ADR der Buchung berührt das nicht.
  - **Das Übergabe-Artefakt von Liefer-Punkt 2 entstand erst nach der Verifikation** (`77eae68b`,
    V-1). Den Durchgang fuhr der Architect selbst, wie
    [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen es ihm
    zuweist.
  - **Das Gliederungs-Kriterium und die Umzugs-Regel entstanden erst im Vorgang**
    ([`harness/migration.md`](../../../../harness/migration.md) §5 a: `3c566c9a`, `58f2156f`,
    `267d380a`, `fabe5188`, `b31d5179`). §3 hatte für die Datei nur tag-tragende Pfade und die
    Register-Zuordnung vorgesehen.
- **Freshness-Durchgang und Stichprobe (Liefer-Punkt 2):** Das vollständige Ergebnis steht im
  Architect-Artefakt `docs/reviews/2026-09-17-slice-sprung-auf-v690-wird-vollzogen-freshness.md`.
  Hier stehen nur die Ausgänge außer *bleibt gültig* und das, was an ihnen hängt.
  - **Grundgesamtheit: 56 Einträge**
    (`git ls-tree --name-only 0b7bcd2e^ harness/conventions/ | grep -c '/MR-[0-9]*-.*\.md$'`).
    [`MR-039`](../../../../harness/conventions.md#mr-039) *widerspricht* und ist durch
    [`MR-060`](../../../../harness/conventions.md#mr-060) mit Kopf-Marke übernommen (`0b7bcd2e`).
    Die übrigen 55 *bleiben gültig*; jeder trägt seine Begründung im Artefakt, §2.
  - **[`MR-035`](../../../../harness/conventions.md#mr-035) und
    [`MR-056`](../../../../harness/conventions.md#mr-056):** Der Tag-Wechsel-Trigger hat mit
    `63e0964e` gefeuert. Setzung 2 greift nicht, weil die Menge der sieben Zeiger gleich bleibt,
    und der Auswahl-Maßstab ist nicht berührt (Artefakt §3). **Die Annahme aus [`MR-056`](../../../../harness/conventions.md#mr-056)
    Setzung 4 deckt den Auto-Kontext von 119270 Zeichen.** Das ist die Setzung des Auftraggebers
    vom 2026-09-17 auf die offene Frage aus Artefakt §3, wo auch Zahlen und Kommandos stehen. Ob
    die Setzung in den Eintrag gehört, entscheidet der Architect
    ([`AGENTS.md`](../../../../AGENTS.md) §3.8); diese Notiz schreibt ihn nicht.
  - **Stichprobe:** Baseline `v6.9.0` · `modul-07-carveouts.md` §Ziel-Form: Carveout. 4 von 5
    Regeln sind im Bestand erfüllt. Gefunden wurde: Die Gate-Konfiguration nennt `CO-001` nicht.
    Adresse ist `slice-113-co-001-ist-faellig`, dessen §1 den Fund führt. Urteil: Die Aussage
    von [`MR-000`](../../../../harness/conventions.md#mr-000) hält. Einen Nebenbefund liefert
    `modul-13-quality-gates.md`: Die `shell-lint`-Zeile in
    [`harness/README.md`](../../../../harness/README.md) trägt
    [`ADR-0003`](../../adr/0003-go-native-binaries.md), aber nicht `CO-001`. Er hängt am
    selben Carveout und hat dieselbe Adresse.
  - Offene Posten aus Artefakt §5: (a) ist durch die Setzung oben beantwortet; (b) und (c) stehen
    im Register (unten).
- **Steering-Loop-Eintrag:** **Geschärfte Regel.** Für den Instanz-Durchgang eines Sprungs gelten
  jetzt ein Gliederungs-Kriterium und eine Umzugs-Regel:
  - Die Pflichtgliederung einer Vorlage ist vollständig zu übernehmen; Freiraum gibt es nur
    innerhalb der Abschnitte.
  - Ein Abschnitt fehlt nur, wenn die Vorlage ihn als bedingt kennzeichnet und die Bedingung
    nicht zutrifft.
  - Stoff zieht nur wörtlich und nur innerhalb derselben Datei um.

  Die Regel steht in [`harness/migration.md`](../../../../harness/migration.md) §5 a und wurde im
  Architect-Kontext aus den Setzungen des Auftraggebers geschrieben. **Kein `liegt in`-Feld:**
  Auslöser war keine Beobachtung über der Schwelle, sondern eine Setzung, und die Regel ist eine
  Lieferung dieses Vorgangs.
- **Beobachtungs-Register (`../observations/`):** Der Beleg heißt in jedem Fall
  `evidence/slice-sprung-auf-v690-wird-vollzogen.md`. Den Zähler liefert
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`; keine der Zahlen ist ein
  Erwartungswert.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`verweis-nachzug-bricht-tree-operand`](../observations/BEO-ALL/verweis-nachzug-bricht-tree-operand/observation.md) | Claim-Nachzug `b04d0ae7`, zurückgenommen per `3c069894` | 2 | offen |
  | [`rotierender-pruef-gegenstand-ohne-ort`](../observations/BEO-ALL/rotierender-pruef-gegenstand-ohne-ort/observation.md) | Freshness-Artefakt §5 (c) | 2 | offen |
  | [`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md) | `slice-212`, `slice-222`; Risiko 5 | 7 | geplant |
  | [`abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md) | V-3 | 6 | verkörpert |
  | [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md) | N-3 | 15 | verkörpert |
  | [`inline-zaehlmuster-paart-backticks-ueber-zellgrenzen`](../observations/BEO-ALL/inline-zaehlmuster-paart-backticks-ueber-zellgrenzen/observation.md) | Message von `072c330c` | 1, neu | offen |
  | [`instanz-umfang-vor-seinem-kriterium-gemessen`](../observations/BEO-ALL/instanz-umfang-vor-seinem-kriterium-gemessen/observation.md) | Risiko 3 | 1, neu | offen |
  | [`zahl-in-commit-message-ohne-kommando`](../observations/BEO-ALL/zahl-in-commit-message-ohne-kommando/observation.md) | F-8 | 1, neu | offen |
  | [`umschrift-eines-zitats-aendert-die-aussage`](../observations/BEO-ALL/umschrift-eines-zitats-aendert-die-aussage/observation.md) | F-2 | 1, neu | offen |
  | [`exit-zusage-aus-anderem-aufruf-abgeleitet`](../observations/BEO-ALL/exit-zusage-aus-anderem-aufruf-abgeleitet/observation.md) | F-4 | 1, neu | offen |
  | [`spec-aenderung-ohne-historie-zeile`](../observations/BEO-ALL/spec-aenderung-ohne-historie-zeile/observation.md) | F-6, Kopf-Feld | 1, neu | offen |
  | [`zuordnung-haengt-an-der-lage-statt-am-inhalt`](../observations/BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt/observation.md) | F-7, N-1, N-2 | 1, neu | offen |
  | [`stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen`](../observations/BEO-ALL/stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen/observation.md) | Kopf von `.harness/skills/reviewer.md` | 1, neu | offen |

  **Kein Eintrag erreicht mit diesem Slice zum ersten Mal 3×**, der Lese-Schritt hat also keinen
  Gegenstand. Die zwei Einträge über der Schwelle mit `verkörpert` treten innerhalb ihrer
  benannten Grenze wieder auf, und ihr Ausgang bleibt stehen. **Nicht getragen, mit Urteil:**
  - `verweis-nachzug-schreibt-in-eingefrorenes-artefakt`: Seine Verkörperung
    ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)) hält den Nachzug
    in `docs/reviews/**` für richtig und nimmt die Gegenformen, in denen die Adresse die Aussage
    trägt, ausdrücklich ohne Wächter hin. Der Tree-Operand ist eine dieser Gegenformen und hat
    den engeren Eintrag oben. Der Ausgang *verkörpert* bleibt.
  - `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum`: Gemessen wurde am vendorten
    Baum. Die Zahl aus dem Klon stand in diesem Plan nur als Vormessung, begleitet von
    Risiko 2.
  - `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`: Die zwei Pfade, die
    `modul-02-harness-bootstrap.md` am neuen Stand nennt, liegen innerhalb des vendorten
    Vorlagen-Baums und existieren dort (Baseline `v6.9.0` · `templates/harness/sensors/gate.template.md`
    und `templates/harness/conventions/MR-NNN-titel.template.md`). Außerdem wird das Regelwerk
    nicht kopiert. Den Mechanismus des Eintrags gibt es hier also nicht: Keine Kopie trägt einen
    Pfad ins Gate. Es entsteht kein dritter Beleg und kein Lese-Schritt.
  - Finding-Klassen ohne Eintrag:
    - *Inhaltsumzug beim Angleichen der Gliederung* (F-1): Die Umzugs-Regel, die den Fall
      entscheidet, ist im Vorgang gesetzt (`b31d5179`).
    - *Ausgang außerhalb der geschlossenen Menge* (F-3): Der sprungbezogene Ausschluss steht seit
      `267d380a` in §5 a.
    - *Teil-Entfernung eines Verweises* (F-5): Sie ist Gegenstand des Matrix-Slice
      `slice-spec-straten-zeigen-nicht-nach-aussen`.
- **Trigger-Audit** (wellenlos, bei der Slice-Closure):
  - **Carveout:** `CO-001` hat den Fund aus der Stichprobe; Adresse ist
    `slice-113-co-001-ist-faellig`. `CO-002` steht auf *permanent*, und dieser Slice berührt
    seine Bedingung nicht.
  - **Bootstrap-aware Gate:** keines berührt.
  - **ADR:**
    - [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) Trigger 2 hat gefeuert;
      beantwortet ist er durch
      [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md).
    - [`ADR-0048`](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Trigger 3 hat
      nicht gefeuert. Nach der Setzung vom 2026-09-16 ist die Planungs-README eine
      Singleton-Instanz, und eine Eigentums-Frage stellt sich nicht.
    - [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) Trigger 3 ist unberührt, denn der Instanz-Abschnitt ist als Ist-Maßstab
      ausgewiesen (Verifikation §7).
  - **[`MR-035`](../../../../harness/conventions.md#mr-035)/[`MR-056`](../../../../harness/conventions.md#mr-056):** siehe oben.
- **Folge-Slices:**
  - `slice-gliederung-der-instanzen-ohne-vorlagen-delta` (`8ee9b1f2`): die fünf Instanzen ohne
    Vorlagen-Delta.
  - `slice-stilllegungs-kanten-sind-gemessen`: misst die neuen Kanten (§1).
  - `slice-spec-straten-zeigen-nicht-nach-aussen`: die Matrix-Regel. Er übernimmt Review F-5 und
    wird im Commit nach dieser Closure angelegt.
  - `slice-113-co-001-ist-faellig`: der Stichproben-Fund und der Nebenbefund.
  - **Kein neuer Schnitt für `slice-222-sensor-datei-traegt-die-form-ihrer-vorlage`.** Sein Titel
    nennt den Gegenstand, den die Gruppe `gate` hier umgeschrieben hat. Ob der Gegenstand ganz
    übernommen ist, prüft der Lauf, der ihn beansprucht oder über die neue Kante stilllegt;
    diese Kante misst zuerst `slice-stilllegungs-kanten-sind-gemessen`.
  - **Übergaben ohne Slice:**
    - Das Kopffeld `v6.7.2` in `.harness/skills/reviewer.md` geht an den Reviewer, dem die Datei
      gehört ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
      der Register-Eintrag dazu steht oben.
    - Die Setzung zu [`MR-056`](../../../../harness/conventions.md#mr-056) geht an den Architect.
    - Dass [`MR-000`](../../../../harness/conventions.md#mr-000) als eigene Datei statt in der Index-Datei steht, braucht keine Handlung: Die
      Form ist durch [`MR-045`](../../../../harness/conventions.md#mr-045) deklariert, und das
      `##`-Kriterium aus §5 a erfasst den Unterabschnitt nicht.
    - Fall C aus V-3 ist ein Kandidat für einen Sensor: `make baseline-verify` hält den Tag des
      Verzeichnisses nicht gegen `BASELINE_TAG`. Die Lücke bleibt in
      [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
      Konventions-Quellen deklariert; ein Schnitt ist hier nicht gesetzt.
- **Risiken aus §6:** Jedes hat genau einen Ausgang: 1, 2, 4 und 6 sind entfallen, 3 ist
  eingetreten, 5 bleibt weiter offen.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht
  (`ls docs/plan/planning/done/*.zip docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l`
  → 0), und die Vorbild-Closure hat es ebenso gehalten.
- **Drei Paarungen**, obwohl die nächste Welle-Closure sie ebenfalls prüft (§2):
  - (a) Kein Gegenstand: Diese Notiz führt kein `liegt in`-Feld.
  - (b) Getragen: Jeder genannte Folge-Slice liegt als Datei im Lifecycle. Der Matrix-Slice
    entsteht im selben Push.
  - (c) Getragen: Jede genannte Beobachtung existiert als Verzeichnis, und jedes trägt einen
    Beleg.

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

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Alle Einträge führen die
Sub-Area `*`; gesichtet ist deshalb nach Gegenstand. Der Zähler je Treffer ist
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, der Stand die erste
Zeile seiner `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | 20 | geplant, `slice-ortswechsel-zieht-sein-zustandsfeld-nach` | §6, Risiko 4 |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 14 | verkörpert | jede Zahl dieses Plans steht neben ihrem Kommando |
| `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` | 14 | verkörpert | der Nachzug aus Liefer-Punkt 1 lässt eingefrorene Artefakte aus (§1) |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 6 | geplant, `slice-offene-plaene-gegen-den-neuen-stand` | §6, Risiko 5 |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | 4 | verkörpert | §6, Risiko 1 |
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4 | verkörpert | der Tausch ist ein Ortswechsel des Baums; eingefrorene Adressen hält [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) |
| `baseline-aussage-ohne-mess-tag` | 4 | verkörpert | jede Messung dieses Slice nennt ihren Tag |
| `gate-modul-erreicht-den-vendored-baum-nicht` | 3 | geplant, `slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer` | die 108 Inline-Pfade aus §1 |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |
| `re-baseline-ohne-inventur-slice` | 2 | offen | kein Auftreten: das Delta ist in [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Kontext dateigenau erhoben, und die Form-Pflichten sind in Liefer-Punkt 3 gebündelt statt als Nachzügler |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 2 | offen | kein Auftreten: dieser Plan sagt nichts darüber, ob `make docs-check` die neuen Kanten trägt (§1) |
| `vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` | 2 | offen | die drei geänderten Vorlagen nennen im Klon nur einen Abschnitt von `modul-05`; Liefer-Punkt 3 prüft das am vendorten Baum |
| `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum` | 1 | offen | §6, Risiko 2 |
| `delta-durchgang-uebersieht-deckung` | 1 | offen | Liefer-Punkt 2 liest den Volltext |
| `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` | 1 | offen | Liefer-Punkt 1.1 schließt die Hand-Kopie aus |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 1 | offen | die Tag-Träger außerhalb von Markdown zählt Liefer-Punkt 1.2 auf |

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

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

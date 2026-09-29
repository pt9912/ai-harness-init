# Slice slice-sprung-auf-v6130-wird-vollzogen: Jeder Träger des Tags steht auf `v6.13.0`, der Adaptions-Block ist gegen das Delta gelesen, und der Vorlagen-Bericht hält auch die bestehenden Instanzen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht fällt negativ aus: Keine Closure-Bedingung beobachtet mehr als die
DoD dieses Slice — `make gates`, `make baseline-verify` und `make full-smoke` stehen in §2. Die
Buchung des Vollzugs in §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md)
ist kein Bündel-Trigger: [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
§Konsequenzen weist sie dem Lauf zu, der den Vollzug ausführt
([`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2).
Nach [`MR-037`](../../../../harness/conventions.md#mr-037) steht wellenlose Arbeit nicht in der
Roadmap; ihr Zustand ist das Verzeichnis.

In den Kommandos steht `K` für einen Klon des Kurs-Repos, eine Host-Voraussetzung und kein
Artefakt dieses Repos ([`ADR-0052`](../../adr/0052-host-lokaler-pfad-in-eingefrorenen-artefakten.md)).
Vergleicht ein Kommando zwei Tags, ist seine Zahl fest; zählt es im Arbeitsbaum, ist sie **kein
Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Tag-Klammer),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (Pins wandern ins
Zielrepo; ein Träger steht im emittierten Block),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (Prozedur-Form des letzten
Sprungs; sein Re-Evaluierungs-Trigger 1 gilt — *der nächste Sprung misst neu*),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegungen 1, 2, 4),
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2, Delta-Basis),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2,
Form der Buchung; `Proposed`),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md),
[`MR-007`](../../../../harness/conventions.md#mr-007) (Vendoring, Setzung 4),
[`MR-033`](../../../../harness/conventions.md#mr-033),
[`MR-057`](../../../../harness/conventions.md#mr-057) (Namensform der Kennung),
[`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen) (Gegenmessung),
[`MR-025`](../../../../harness/conventions.md#mr-025).

**Berührte Spec-Stellen:** — (keine Spec-Stelle wird normativ berührt. Trägt ein Spec-Stratum
eine Adresse in den vendored Baum, zählen die Kommandos in §1 sie mit; ihr Nachzug ist Adresse,
keine Spec-Änderung).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-29.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Sprung `v6.9.0` → `v6.13.0` ist vollzogen — die breiteste Minor-Sprungweite bisher
(vier Releases), kein Major-Sprung. Der vendored Baum, die fünf gekoppelten Pin-Stellen, die
sieben tag-tragenden Symlinks in `.claude/rules/`, der emittierte Mess-Tag in
`internal/emit/baumaussage.go` und jede Adresse in einem **lebenden** Artefakt stehen auf
`v6.13.0`. Der Adaptions-Block ist gegen das Regelwerks-Delta gelesen, und jeder betroffene
Eintrag trägt einen der fünf Ausgänge. Der Vorlagen-Bericht zum Tag `v6.13.0` unter
`docs/migrations/` liegt vor und berichtet neben den Vorlagen mit Delta die **bestehenden
Instanzen**, die die Klassen-Aussagen der Ziel-Fassung erreichen. Die Delta-Inventur je Release
ist im Übergabe-Artefakt dokumentiert; der Regelwerk-Stand selbst steht im neuen
`regelwerk/README.md`.

**Delta, gemessen im Klon** (`K` = Kurs-Klon; Tag-Vergleiche, feste Zahlen):

```sh
git -C "$K" log --oneline v6.9.0..v6.13.0 -- lab/regelwerk lab/templates | wc -l   # 13 Welle-Commits
git -C "$K" diff --numstat v6.9.0..v6.13.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'            # 27 Dateien  +313  -80
git -C "$K" diff --name-status v6.9.0..v6.13.0 -- lab/regelwerk lab/templates \
  | grep -cE '^[AD]'                                                               # 0  (keine Datei neu, keine entfallen)
git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/regelwerk | wc -l              # 19 (von 26)
git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/templates | wc -l              # 8  (von 25)
```

Release-Partition nach Kopf-Commit: `v6.10.0` Wellen 138–142 · `v6.11.0` Wellen 143–147 ·
`v6.12.0` Wellen 148–150 · `v6.13.0` Wellen 151–153. **Keine neue und keine entfallene
Regelwerks- oder Vorlagen-Datei** — das Delta ist anpassend, nicht strukturell. Berührt sind
unter anderem `modul-05` und `modul-06` (beide als Symlink in `.claude/rules/` in jedem
Claude-Lauf im Kontext), `modul-02` (Freshness-Audit-Prozedur), `modul-03`, `modul-04`,
`modul-08`, `modul-09`, `modul-11`, `modul-13` und alle fünf `grundlagen-*`-Dateien.

**Reichweite der Übernahme-Vorgabe: delta-gebunden**, so wie sie
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen für die drei
Sprünge davor verbucht (*„Der Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung
wird nicht gesetzt"*). Was das Delta berührt, übernimmt der Slice vollständig: Ein Eintrag mit
*widerspricht* tritt zurück, und *bewusst abweichend* entfällt im Instanz-Durchgang. Eine
Abweichung, deren Baseline-Text das Delta nicht berührt, bleibt stehen
([`MR-007`](../../../../harness/conventions.md#mr-007) Setzung 4 als Muster).

### Drei Achsen, und sie werden nicht ineinander übersetzt

[`harness/migration.md`](../../../../harness/migration.md) §5 setzt, dass die Ausgänge über die
**Vorlage** nicht die fünf Ausgänge über den **Adaptions-Eintrag** sind. Die dritte Achse, die
**Adresse**, urteilt nicht; sie bewegt Bytes.

| Achse | Gegenstand | Ausgangs-Menge | Liefer-Punkt |
|---|---|---|---|
| Adresse | Baum · Pin · Symlink · emittierter Mess-Tag · Markdown-Link · Inline-Pfad | keine | 1 |
| Adaptions-Eintrag (`MR-<NNN>`) | die aktiven Einträge unter [`harness/conventions/`](../../../../harness/conventions/) — `ls harness/conventions/*.md \| wc -l` → **71** | fünf: gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist entfallen · widerspricht | 2 |
| Vorlage | die Vorlagen des vendored Baums — `find .harness/baseline/v6.13.0/templates -name '*.template.md' \| wc -l` → **25**, gemessen gegen `v6.13.0`; mit Delta im Klon `git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/templates \| wc -l` → **8** | Buchstabe a: übernommen · schon erfüllt · keine Instanz (*bewusst abweichend* entfällt); Buchstabe b: append-only | 3 |

### Der Adress-Nachzug ist gemessen

Über dem Arbeitsbaum, der diesen Plan enthält:

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.9\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 133 Markdown-Links
git grep -oE '`[^`]*\.harness/baseline/v6\.9\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 111 Inline-Code-Pfade
```

Die 133 Links sind gate-sichtbar und fallen in dem Moment, in dem das `v6.9.0`-Verzeichnis
verschwindet; Tausch- und Nachzugs-Commit gehören darum in denselben Push (Baseline-Regelwerk
`grundlagen-traceability.md` §Herkunfts-Anker). Die 111 Inline-Pfade sieht kein Gate
([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul `codepaths`).

**Sechster Träger, emittierte Ebene.** `internal/emit/baumaussage.go` trägt
`const InventurMessTag = "v6.9.0"` — der Mess-Tag der Inventur-Aussage im emittierten Block, per
`TestInventurMessTag_IstDerGefetchteStand` fail-closed an den gefetchten Stand gekoppelt. Er ist
Adresse und zieht mit. Die zwei Kommentar-Stellen in `internal/emit/templates.go` (Zeilen 926,
927, 1005) nennen `v6.9.0` in Kommando-Belegen — je Treffer wird geurteilt (Adresse gegen
datierte Mess-Aussage, [`MR-033`](../../../../harness/conventions.md#mr-033)). `test/` trägt
keinen Tag: `git grep -lE 'v6\.9\.0' -- test/ | wc -l` → **0**.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Entscheidung, welche Fassung den Sprung regiert.** *Es wäre ein anderer Vorgang einer
  anderen Rolle:* [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
  Re-Evaluierungs-Trigger 1 ordnet an, dass der nächste Sprung neu misst; die regierende Fassung
  für `v6.9.0` → `v6.13.0` benennt der Architect in einer eigenen Sprung-ADR. §4 setzt sie als
  Start-Voraussetzung; dieser Plan sagt nichts darüber, welchen Ausgang sie nimmt.
- **Kein Umbau der MR-Formen über das nötige Maß hinaus.** *Schicht-Abgrenzung:* Anpassung oder
  Bestätigung je Eintrag ist delta-gebunden (Liefer-Punkt 2); eine Neufassung ohne
  Delta-Berührung fällt in den Architect-Lauf, nicht in diesen Slice.
- **Kein Inhalt der emittierten Ebene außer dem Mess-Tag.** *Schicht-Abgrenzung:* Was ein
  Zielrepo an Vorlagen und Modulen bekommt, liegt bei [`MR-054`](../../../../harness/conventions.md#mr-054)
  und [`MR-017`](../../../../harness/conventions.md#mr-017). Der d-check-Pin in `d-check.mk` und
  `internal/emit/emit.go` bindet an eine **andere** Version (Werkzeug, nicht Baseline) und wird
  hier nicht berührt.
- **Keine eingefrorene Adresse wird berührt.** Was in `docs/reviews/**`,
  `docs/plan/planning/done/**`, `docs/plan/carveouts/done/**`, im Beobachtungs-Register und in
  einer `Accepted`-ADR auf `v6.9.0` zeigt, bleibt stehen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.11;
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)) — *Bestand bleibt
  bewusst stehen*. Die Pathspec in §1 bildet genau diesen Ausschluss ab.
- **Keine Sichtung der offenen Pläne gegen den neuen Stand.** *Bestand bleibt bewusst stehen:*
  Der Bestand in `open/` und `next/` bleibt stehen; die Pflicht liegt bei
  `slice-offene-plaene-gegen-den-neuen-stand` (Register-Eintrag
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`, 7 Belege).
- **Keine produktiven LH-FA-Slices in diesem Slice.** *Es wäre ein anderer Vorgang:* Setzung des
  Auftraggebers (2026-09-28) — erst der Sprung, danach die LH-FA-Slices. Dieser Slice belegt
  ihre Grundlage, nicht ihren Inhalt.

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
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte, einer je Achse aus §1.

**Beleg-Zeiger je Häkchen** — Quelle für die Punkte 1–7 ist der
[`Verifikations-Report`](../../../reviews/2026-09-29-slice-sprung-auf-v6130-wird-vollzogen-verify.md)
(2026-09-29):

| Punkt | Beleg |
|---|---|
| 1 | Verifier-Report DoD 1a–1f; Tausch-Commit `ad5b56d6`, Nachzüge je Eigentümer |
| 2 | Verifier-Report DoD 2; Übergabe-Artefakt (Freshness-Report, Commit `7f2fb68d`) |
| 3 | Verifier-Report DoD 3; [`docs/migrations/v6.13.0.md`](../../../migrations/v6.13.0.md), Register-Zuordnung `3ef54b82` |
| 4 | Verifier-Report DoD 4 (Stempel deckungsgleich über `3ef54b82`); der Abschluss-Lauf nach der Closure deckt die Commits danach |
| 5 | Verifier-Report DoD 5 — eigener Lauf 2026-09-29, EXIT 0, alle neun `baseline-verify`-Zeilen `v6.13.0 OK` |
| 6 | Verifier-Report DoD 6; Report `f758e6c0`, Merge-Blocker aufgelöst |
| 7 | Verifier-Report DoD 7; Architect-Commit `9b10fda9` (`3ef54b82`) |
| Closure-Notiz · Register · Risiken · Paarungen | diese Closure — §6 und §7 |

- [x] **1 — Jeder Träger des Tags steht auf `v6.13.0`, und keine lebende Adresse bleibt auf dem
      abgelösten Tag.** Sechs Träger-Klassen, eine Eigenschaft. **Rot ist ein halb getauschtes
      Repo nur in zwei Fällen, gezogen bei der Closure:** wenn eine Pin-Stelle von den übrigen
      abweicht und wenn ein Markdown-Link auf einen fehlenden Baum zeigt. **Grün bleibt es**, wenn
      alle sechs Pins stehen, ein Symlink ins Leere zeigt oder ein Inline-Pfad veraltet ist — die
      unbewachte Hälfte der Provenienz-Kette, die
      [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
      Konventions-Quellen ausweist. Den Zustand belegen deshalb die direkten Messungen der
      Verifikation, nicht die Gates.

      1. **Der vendored Baum.** `.harness/baseline/v6.13.0/{regelwerk,templates}` samt
         `SHA256SUMS` liegt committet, das `v6.9.0`-Verzeichnis existiert nicht mehr, und
         `make baseline-verify` meldet
         `baseline-verify: v6.13.0 OK — <N> Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
         Tragend ist das `OK`, die Dateizahl ist kein Erwartungswert. Der Baum entsteht über
         [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md) aus dem
         verifizierten Release-Asset, nicht per Hand-Kopie aus dem Kurs-Klon
         ([`MR-007`](../../../../harness/conventions.md#mr-007), einmal Netz).
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
           | grep -vc 'baseline/v6\.13\.0/'                                   # 0
         ```

         Die erste Zahl ist kein Erwartungswert; tragend ist die zweite. Die Zusage ist über den
         **neuen** Tag formuliert, damit sie den Nachzug aus Klasse 5 übersteht.
      4. **Die 133 Markdown-Links**, gate-sichtbar (§1): die zwei Link-Kommandos aus §1 liefern
         über dem Ergebnis-Stand **0**.
      5. **Die 111 Inline-Code-Pfade**, gate-unsichtbar (§1): **null Adressen** zugesagt, nicht
         null Treffer. Eine Inline-Nennung ist entweder Adresse — dann gehört sie auf den neuen
         Tag — oder Teil einer Aussage, die den Stand nennt, gegen den sie gemessen ist
         ([`MR-033`](../../../../harness/conventions.md#mr-033)). Welches von beiden, ist ein
         Urteil je Treffer; der Rest steht im Umsetzungs-Lauf benannt und abgezählt daneben.
      6. **Der emittierte Mess-Tag.** `InventurMessTag` in `internal/emit/baumaussage.go` steht
         auf `v6.13.0`, und `TestInventurMessTag_IstDerGefetchteStand` ist grün. Die zwei
         Kommentar-Stellen in `internal/emit/templates.go` sind je Treffer geurteilt (Zusage wie
         in Klasse 5).

      Der Nachzug läuft **je Eigentümer in einem eigenen Commit**, der die Rolle nennt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Planungs- und Sensor-Artefakte im
      Implementations-Kontext; [`AGENTS.md`](../../../../AGENTS.md),
      [`harness/conventions.md`](../../../../harness/conventions.md) samt
      [`harness/conventions/`](../../../../harness/conventions/) und
      [`harness/migration.md`](../../../../harness/migration.md) im Architect-Lauf;
      [`.claude/commands/`](../../../../.claude/commands/) und
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) bei der Rolle, die
      sie ausführt ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- [x] **2 — Die Freshness-Review des Adaptions-Blocks ist über alle 71 aktiven Einträge
      gefahren, jeder betroffene trägt einen der fünf Ausgänge, und die Delta-Inventur je Release
      ist dokumentiert.** Die Frage je Eintrag: Regelt eine der im Sprung geänderten
      Regelwerks-Dateien das, wofür dieser Eintrag angelegt wurde?

      ```sh
      git -C "$K" diff --name-only v6.9.0..v6.13.0 -- lab/regelwerk
      # -> 19 Dateien (Tag-Vergleich, feste Zahl; die Liste selbst ist die Grundgesamtheit
      #    des Durchgangs)
      ```

      Gelesen wird der **Volltext** der geänderten Datei am Tag `v6.13.0`, nicht allein ihr Hunk
      (§8, `delta-durchgang-uebersieht-deckung`). Prozedur und Ausgänge:
      [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Entscheidung als
      Form-Vorbild, [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
      Festlegung 4; die Übernahme gilt in der Reichweite aus §1. Die Grundgesamtheit ist die
      volle Liste (`ls harness/conventions/*.md | wc -l` → **71**, kein Erwartungswert). Die
      **Stichprobe gegen den Bestand** läuft nach der Prozedur und prüft die Aussage von
      [`MR-000`](../../../../harness/conventions.md#mr-000).

      **Erfüllt ist der Punkt, wenn die Liste vollständig abgearbeitet ist, auch ohne einen
      betroffenen Eintrag**; das Ergebnis steht in §7. Das **Schreiben** eines Ausgangs ist
      Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der Implementations-Lauf
      liefert das Übergabe-Artefakt: die **Delta-Inventur je Release** (13 Welle-Commits, die
      Release-Partition aus §1, thematische Zuordnung der 27 geänderten Dateien), die
      abgearbeitete Liste mit je einem Ausgang, das Ergebnis der Stichprobe, dazu Tag, Datum und
      den gemessenen sha256 für die Buchung in §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) in der Form von
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Festlegung 2.
- [x] **3 — Der Vorlagen-Bericht zum Tag `v6.13.0` liegt unter `docs/migrations/` vor, in der
      Report-Form aus [`harness/migration.md`](../../../../harness/migration.md) §5, und hält die
      bestehenden Instanzen.**

      1. **Je Vorlage eine Zeile**
         (`find .harness/baseline/v6.13.0/templates -name '*.template.md' | wc -l` → die
         Zeilenzahl, kein Erwartungswert). Der Buchstabe folgt der Klasse, die das Register der
         Vorlage zuweist, **nach** dem Architect-Schritt aus §3.
      2. **Das Delta ist zwischen den zwei vendorten Bäumen gemessen**, am Tausch-Commit und
         seinem Vorgänger, nicht allein im Klon (Register:
         `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum`). Jede Vorlage, die sich
         dort unterscheidet, bekommt ihren Ausgang (§6, Risiko 2). Die acht Vorlagen mit Delta im
         Klon sind Vormessung, kein Maßstab.
      3. **Die bestehenden Instanzen.** Für jede Register-Zeile, die der Architect-Schritt aus §3
         einordnet, sind ihre Instanzen unter dem zugewiesenen Buchstaben geprüft und berichtet:
         unter Buchstabe b mit dem Befund, dass sie unverändert bleiben; unter Buchstabe a mit
         einem der drei verfügbaren Ausgänge (*bewusst abweichend* entfällt — §1). **Der Bericht
         weist den Instanz-Abschnitt als Ist-Maßstab aus**
         ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), nicht
         als Schritt der Prozedur.

      Der Bericht wird von `docs-check` gescannt; jede `LH-`/`ADR-`/`MR-`-Kennung darin ist ein
      Anker-Link ([`MR-001`](../../../../harness/conventions.md#mr-001)).
- [x] `make gates` grün über dem Liefer-Stand, gedeckt durch den Stempel
      `.harness/state/gates-passed.diffsha`. Nicht gedeckt sind die Commits danach
      (Architect-Buchung, Closure).
- [x] `make full-smoke` endet EXIT 0 (Voll-E2E über das gebootstrappte Ziel; der emittierte Satz
      erbt den neuen Stand über Liefer-Punkt 1.6).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und
      §Adoptierte Konventions-Quellen tragen den neuen Stand (**Architect-Commit** aus dem
      Übergabe-Artefakt von Liefer-Punkt 2); [`harness/migration.md`](../../../../harness/migration.md)
      trägt die Sprung-Zeile und die Register-Zuordnung (**Architect-Commit**).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md` → **2** Dateien), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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
| `internal/emit/baumaussage.go` (`InventurMessTag`) | update | emittierter Träger, fail-closed an den gefetchten Stand gekoppelt (§1) |
| `internal/emit/templates.go` (Kommentar-Stellen) | update, je Treffer geurteilt | Kommando-Belege nennen den alten Tag (§1) |
| `.harness/baseline/` — der abgelöste Tag-Ordner | entfällt | [`MR-007`](../../../../harness/conventions.md#mr-007) Setzung 4: ein Tag zur Zeit; `make vendor-baseline` bricht bei einem anderen vorliegenden Tag ab |
| `.harness/baseline/v6.13.0/{regelwerk,templates}/` + `SHA256SUMS` | neu | der vendored Baum aus dem verifizierten Release-Asset |
| `.claude/rules/*.md` — die sieben Zeiger in den vendored Baum | update | der Tag steht im Symlink-Ziel |
| lebende `.md` mit den 133 Markdown-Links ins Tag-Segment | update | gate-sichtbar (§1) |
| lebende `.md` mit den 111 Inline-Code-Pfaden | update, je Treffer geurteilt | gate-unsichtbar (§1) |
| [`harness/conventions/`](../../../../harness/conventions/) — die betroffenen Einträge | neu / Kopf-Marke | Ausgang der Freshness-Review; **Architect-Commit** |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline, §Adoptierte Konventions-Quellen | update | Buchung des Vollzugs; **Architect-Commit** |
| [`harness/migration.md`](../../../../harness/migration.md) | update | Sprung-Zeile, tag-tragende Pfade, Register-Zuordnung; **Architect-Commit** |
| Vorlagen-Bericht zum Tag `v6.13.0` unter `docs/migrations/` | neu | Report-Form aus `harness/migration.md` §5 |
| Übergabe-Artefakt an den Architect (Delta-Inventur · Ausgangs-Liste · Stichprobe · Tag · Datum · sha256) | neu | Einträge und Buchung hängen daran |

**Keine Testdatei-Zeile.** Der Slice ändert keine Zusage eines Sensors. Die vorhandenen Wächter
der Pin-Kopplung (drei in `make gates`, der Mess-Tag-Wächter im Go-Test) laufen unverändert mit
und färben rot, wenn eine Träger-Stelle stehen bleibt.

**Reihenfolge, weil sie hier trägt:**

- Erst die Pins, dann `make vendor-baseline`: das Ziel liest `BASELINE_TAG` und
  `BASELINE_ZIP_SHA256` als Argumente. Der sha256 steht vor dem Vendoring-Lauf fest; weicht er vom
  berechneten ab, bricht der Lauf vor jedem Schreibzugriff ab
  ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)).
- **Register-Zuordnung, Architect-Kontext:** nach dem Tausch-Commit und vor Liefer-Punkt 3.3
  ordnet der Architect die Register-Zeilen gegen die Klassen-Aussagen der Ziel-Fassung. Die
  Ziel-Fassung ordnet sie selbst ein; der Schritt liest den Wortlaut am neuen Tag ab
  (Folgepflicht *Architect, mit dem Tausch*, Form aus
  [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen). Eigener
  Architect-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- Tausch-Commit und Adress-Nachzug gehen in **denselben Push**.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei; die regierende Fassung für diesen Sprung ist
benannt — durch eine Architect-ADR zu `v6.9.0` → `v6.13.0` oder durch eine Setzung des
Auftraggebers, die sie vertritt
([`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) Re-Evaluierungs-Trigger 1:
*der nächste Sprung misst neu*); und der Lauf hat einmal Netz für `make vendor-baseline` und
`make regelwerk-check`. Der `git mv` nach `in-progress/` landet auf dem Hauptzweig, vor der
Arbeit, und derselbe Zug nimmt den Ruhe-Marker der Roadmap zurück (§6, Risiko 5).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Über die Inline-Treffer aus
  Liefer-Punkt 1 sind mehr Urteile zu fällen (Adresse gegen datierte Mess-Aussage) als
  mechanische Ersetzungen — bei 111 Treffern und 27 geänderten Regelwerks-Dateien realistisch.
  Dann wird der Nachzug je Eigentümer geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Vier Bedingungen, jede für sich hinreichend.
  **(a)** Die Freshness-Review trifft *widerspricht*, und der Rückbau zieht mehr nach als den
  Eintrag selbst — ein Werkzeug, ein Gate oder eine Hard Rule. Das ist eine Übergabe an den
  Architect, der Slice wartet. **(b)** Liefer-Punkt 3.3 findet unter Buchstabe a eine
  Instanz-Gruppe, die weder *schon erfüllt* noch *keine Instanz* ist, und ihre Umschrift reicht
  über die Einzel-Instanzen hinaus; der Slice wartet auf die Entscheidung zwischen Folge-Slice
  und Carveout. **(c)** Der am Asset gemessene sha256 weicht vom Upstream-Release ab, oder
  `make vendor-baseline` bricht an seiner Sperre ab — dann ist die Provenienz der Befund.
  **(d)** `TestInventurMessTag_IstDerGefetchteStand` bleibt rot, obwohl beide Seiten gesetzt
  sind — dann stimmt die Kopplungs-Aussage über den emittierten Block nicht, und die Lücke geht
  als Befund an den Architect, bevor der Tausch gemergt wird.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make baseline-verify` meldet `v6.13.0 OK`, die drei Pin-Wächter und der Mess-Tag-Wächter in
   `make gates` sind grün über dem Liefer-Stand; die zwei Link-Kommandos aus §1 und das
   Symlink-Kommando aus §2 Liefer-Punkt 1.3 liefern **0**; `make full-smoke` endet EXIT 0.
2. Der Vorlagen-Bericht trägt je Vorlage eine Zeile und den Abschnitt zu den bestehenden
   Instanzen aus Liefer-Punkt 3.3.

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

**Ausgänge der Closure (2026-09-29):**

1. **entfallen** — die Durchgänge sind ohne Rückführung (a) durch: 6 von 71 Einheiten betroffen,
   jeder mit einem der fünf Ausgänge, kein *widerspricht*, kein *Bezug ist entfallen*. Beleg:
   [`Verifikations-Report`](../../../reviews/2026-09-29-slice-sprung-auf-v6130-wird-vollzogen-verify.md) DoD 2.
2. **entfallen** — `test/` trägt keinen Tag, `internal/` nach dem Tausch ebenfalls nicht; der
   Mess-Tag ist gezogen, die `templates.go`-Proben sind als Adressen geurteilt und mitgezogen
   (Tausch-Commit `ad5b56d6`).
3. **entfallen** — der sha256 ist am Release-Asset gemessen, drei Quellen ein Wert, Kontrolle
   gegen `v6.9.0` byte-gleich; das Kommando steht im Tausch-Commit, die
   `vendor-baseline`-Sperre als zweites Netz (Verifier-Report DoD 1b).
4. **weiter offen** — Register
   [`BEO-ALL/baseline-sprungweite-treibt-kosten`](../observations/BEO-ALL/baseline-sprungweite-treibt-kosten/observation.md),
   2 Belege, Stand `offen`; bei 3× Lücke mit eigenem Folge-Slice.
5. **entfallen** — der Zug nach `in-progress/` hat den Ruhe-Marker entfernt (`b8597a22`), der
   Abschluss-Zug nach `done/` stellt ihn wieder her; beide Züge tragen die Roadmap-Zeile.
6. **entfallen** — der Tausch-Commit `ad5b56d6` trägt die Gegenmessung auf Nicht-Null-Basis:
   d-check-Pin unberührt, alle 9 aktiven Module des Doku-Gates behalten Basis und Konfiguration.

1. **Der Adaptions-Block berührt mehr MRs als erwartbar.** 71 Einträge gegen 19 von 26
   geänderte Regelwerk-Dateien; `modul-05`/`modul-06` stehen in jedem Claude-Lauf im Kontext
   (Symlinks), `modul-02` regelt die Prozedur selbst, `modul-13` die Gate-Disziplin — die
   Trefferwahrscheinlichkeit je Eintrag ist höher als bei den Sprüngen davor. *Absehbar:*
   eingetreten, wenn die Durchgänge ohne Rückführung (a) nicht durch sind; sonst entfallen, wenn
   die Liste vollständig abgearbeitet ist und die betroffenen Ausgänge stehen.
2. **Emittierte Vorlagen oder Fixtures referenzieren `v6.9.0`-Pfade.** Gemessen (§1): `test/`
   null Treffer, `internal/emit/` drei Dateien. Der Mess-Tag ist Träger und zieht mit; die zwei
   Kommentar-Stellen sind Urteils-Fälle. *Absehbar:* entfallen, wenn je Treffer geurteilt ist;
   sonst eingetreten, Beleg in `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`.
3. **Der sha256 wird falsch übernommen.** Aus dem Klon oder aus einer Notiz statt am Asset
   gemessen — dann lügt die Provenienz-Kette, und die drei Pin-Wächter grünen gegen den falschen
   Wert. *Absehbar:* entfallen, wenn die Messung am Asset steht (`make regelwerk-check`
   `0 Befund(e)` und die vendor-baseline-Sperre als zweites Netz) und das Kommando im
   Umsetzungs-Lauf daneben steht; sonst eingetreten → Rückführung (c).
4. **Die Sprungweite lässt Deckungslücken im Adaptions-Durchgang.** Vier Releases an einem Stück
   sind die breiteste Minor-Weite bisher; Register: `baseline-sprungweite-treibt-kosten` (1
   Beleg, offen) — der Beleg dieses Vorgangs erhöht ihn. *Absehbar:* weiter offen, Register; bei
   3× ist der Eintrag eine Lücke mit eigenem Folge-Slice.
5. **Die Lifecycle-Züge machen den Ruhe-Marker der Roadmap falsch.** Der Zug nach
   `in-progress/` und die Closure nach `done/` kippen ihn. *Absehbar:* entfallen, wenn beide
   Züge ihn mitziehen; sonst eingetreten, Beleg in
   `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (24 Belege, geplant).
6. **Der Umsetzungs-Commit trägt die Strenge-Bilanz nicht.** Ein Pin-Sprung ohne Gegenmessung
   auf Nicht-Null-Basis verletzt [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen);
   Register: `strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` (1 Beleg, offen).
   *Absehbar:* entfallen, wenn der Tausch-Commit die Gegenmessung nennt; sonst eingetreten,
   Beleg im Register.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

**Rolle:** Planner · **Datum:** 2026-09-29

- **Was hat funktioniert:** Die Drei-Achsen-Trennung aus §1 — Adresse, Adaptions-Eintrag, Vorlage —
  hat den Durchgang tragfähig gemacht: Alle sechs Träger-Klassen des Tags sind im Tausch-Commit
  (`ad5b56d6`) und den Eigentümer-Nachzügen auf `v6.13.0` gezogen, ohne dass eine Klasse in eine
  andere übersetzt wurde. Die fail-closed Kopplungen (drei Pin-Wächter, Mess-Tag-Wächter) haben
  die bewachte Hälfte der Träger von selbst gehalten; Symlinks und Inline-Pfade bleiben direkte
  Messungen ([`Verifikations-Report`](../../../reviews/2026-09-29-slice-sprung-auf-v6130-wird-vollzogen-verify.md) DoD 1).
- **Was ging anders als geplant:** Die Rückführung (b)-Lage aus §4 (Register-Zuordnung vor
  Liefer-Punkt 3.3) löste sich im Vollzug als Reihenfolge Tausch → Review → Architect-Buchung
  (`3ef54b82`); der Review-Report hatte sie als Blocker geführt, und sie ist geräumt. Der für
  DoD 5 angebotene Beleg war ein Alt-Protokoll vom 2026-09-23 — der Verifier fuhr
  `make full-smoke` selbst (DoD 5 desselben Reports); die Klasse steht im Register.
- **Ergebnis Freshness-Durchgang und Stichprobe (Liefer-Punkt 2):** 71 Einträge gelesen, 6
  betroffene Einheiten ([`MR-000`](../../../../harness/conventions.md#mr-000) ·
  [`MR-002`](../../../../harness/conventions.md#mr-002) ·
  [`MR-060`](../../../../harness/conventions.md#mr-060) ·
  [`MR-057`](../../../../harness/conventions.md#mr-057)/[`MR-059`](../../../../harness/conventions.md#mr-059) ·
  [`MR-063`](../../../../harness/conventions.md#mr-063) ·
  [`MR-035`](../../../../harness/conventions.md#mr-035)/[`MR-056`](../../../../harness/conventions.md#mr-056)), 65
  nicht betroffen; kein Ausgang *widerspricht*, kein *Bezug ist entfallen*. Stichprobe des
  Verifiers: 3 von 6 Einheiten gegen den Volltext am Tag `v6.13.0` nachgelesen
  ([`MR-000`](../../../../harness/conventions.md#mr-000),
  [`MR-060`](../../../../harness/conventions.md#mr-060),
  [`MR-063`](../../../../harness/conventions.md#mr-063)), alle bestätigt. Delta-Inventur je
  Release im Übergabe-Artefakt (13 Welle-Commits, 27 Dateien, 0 neu, 0 entfallen).
- **Steering-Loop-Eintrag:** *geschärfte Regel.* Ein vorgefundenes Protokoll belegt den Stand zum
  Laufzeitpunkt, nie den aktuellen; der Beleg über dem aktuellen Stand ist der frische Lauf. Ein
  `liegt in`-Feld steht hier nicht: nichts ist mit diesem Slice verkörpert — die Verkörperung
  gehört in diesem Repo dem Lese-Schritt der Welle-Closure. Die Beobachtung steht als
  [`BEO-ALL/lauf-beleg-ist-zeitgebunden`](../observations/BEO-ALL/lauf-beleg-ist-zeitgebunden/observation.md)
  im Register (1 Beleg).
- **Anlass der Lastenheft-Änderung** ([`MR-042`](../../../../harness/conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz)):
  die §4-Umbenennung („… und Randbedingungen") in `spec/lastenheft.md` ist die Instanz-Umschrift
  aus dem Register-Durchgang der Ziel-Fassung `v6.13.0`
  (`.harness/baseline/v6.13.0/templates/spec/lastenheft.template.md` §4) —
  Form-Nachzug der Vorlage, keine Inhaltsänderung am Vertrag, keine eingefrorene Adresse
  betroffen.
- **Beobachtungs-Register** (`../observations/`): drei Belege, ein Vorgang zählt je Klasse
  einmal — [`BEO-ALL/baseline-sprungweite-treibt-kosten`](../observations/BEO-ALL/baseline-sprungweite-treibt-kosten/observation.md)
  (2 Belege, Stand `offen`) ·
  [`BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht`](../observations/BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht/observation.md)
  (2 Belege, Stand `offen`) ·
  [`BEO-ALL/lauf-beleg-ist-zeitgebunden`](../observations/BEO-ALL/lauf-beleg-ist-zeitgebunden/observation.md)
  (**neu angelegt**, 1 Beleg). Kein Eintrag erreicht 3×.
- **Trigger-Audit:** Carveouts — kein neuer; CO-001 und CO-002 hängen nicht am Baseline-Stand und
  sind von diesem Vorgang nicht berührt. Bootstrap-aware Gates — keine berührt. ADR —
  [`ADR-0072`](../../adr/0072-ziel-fassung-regiert-den-sprung-v6130.md) (`Accepted`); ihr
  Re-Evaluierungs-Trigger (*der nächste Sprung misst neu*) ist nicht eingetreten. Hard Rules —
  keine mit Auflösungs-Trigger aus diesem Vorgang.
- **Folge-Slices:** keine. Die Rest-Lücken der Verifikation tragen ihre bestehenden Träger: die
  Pin→Asset-Hälfte der Provenienz beruht auf dem Dreifach-Beleg des Übergabe-Artefakts statt
  eines eigenen Netzlaufs (`make regelwerk-check`); die Freshness-Stichprobe liest 3 von 6
  Einheiten, die übrigen beruhen auf der Lesung des Übergabe-Laufs; `make full-smoke` belegt den
  Stand zum Laufzeitpunkt, Träger ist der Lauf (Stop-Hook, CI); der Rollen-Zuschnitt der Commits
  ist `git`-Lesung — die Lücke ist in [`AGENTS.md`](../../../../AGENTS.md) §3.8 benannt.
- **Paarungen:** (a) *Anker* — §7 trägt kein `liegt in`-Feld, nichts zu prüfen. (b)
  *Folge-Slice* — §7 nennt keine Kennung; der in §1 genannte
  [`slice-offene-plaene-gegen-den-neuen-stand`](../open/slice-offene-plaene-gegen-den-neuen-stand.md)
  liegt in `open/`. (c) *Register* — alle zitierten Pfade existieren mit nicht leerem
  `evidence/`; zweite Hälfte über das ganze Register: 4 Verzeichnisse ohne Beleg, namentlich
  `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`,
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

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
Tag steht in `Makefile`, `.d-check.yml`, `internal/fetch/`, `internal/emit/`, `.claude/rules/`,
`harness/`, `docs/` und in der Planungs-Ablage; keine engere Sub-Area umschließt ihn.
`harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`), die zwei anderen deklarierten Sub-Areas
([`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro
Sub-Area), sind nicht berührt: `git grep -lE 'v6\.9\.0' -- harness/tools .codex | wc -l` → **0**,
kein Erwartungswert. `*` erfüllt die Schwelle ≥ 2 von 3 Achsen als deklarierte Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergten Stand (65
Verzeichnisse mit Beleg, `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`). Alle
Einträge führen die Sub-Area `*`; gesichtet ist deshalb nach Gegenstand. Der Zähler je Treffer
ist `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, der Stand die
erste Zeile seiner `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `baseline-sprungweite-treibt-kosten` | 1 | offen | §6, Risiko 4 — breiteste Minor-Sprungweite bisher |
| `strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` | 1 | offen | §6, Risiko 6 — [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)-Gegenmessung in den Tausch-Commit |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 1 | offen | die 133 + 111 Adressen aus §1 |
| `re-baseline-ohne-inventur-slice` | 2 | offen | kein Auftreten: dieser Sprung fährt den Inventur-Slice — dieser Plan |
| `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` | 1 | offen | kein Auftreten: der Baum entsteht über `make vendor-baseline` aus dem verifizierten Asset (§2, 1.1) |
| `baseline-aussage-ohne-mess-tag` | 5 | verkörpert | jede Messung dieses Plans nennt ihren Tag |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 7 | geplant, `slice-offene-plaene-gegen-den-neuen-stand` | §1, Out-of-Scope; Risiko weiter offen |
| `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum` | 1 | offen | §2, Liefer-Punkt 3.2 misst vendored |
| `delta-durchgang-uebersieht-deckung` | 1 | offen | Liefer-Punkt 2 liest den Volltext |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 2 | offen | kein Auftreten: die Kopplung `TestInventurMessTag_IstDerGefetchteStand` zieht den emittierten Träger mit dem Dogfood-Pin |
| `kennung-traegt-den-stand-den-ein-release-ueberholt` | 1 | offen | kein Auftreten bei sauberem Nachzug; tritt es doch ein, ist das §6, Risiko 2 |
| `stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen` | 1 | offen | Kopf von `.harness/skills/reviewer.md` — die Datei berührt dieser Slice nicht; der Zustand bleibt, wie er ist |
| `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` | 14 | verkörpert | der Nachzug aus Liefer-Punkt 1 lässt eingefrorene Artefakte aus (§1) |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | 6 | verkörpert | §6, Risiko 2 |
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4 | verkörpert | der Tausch ist ein Ortswechsel des Baums; eingefrorene Adressen hält [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) |
| `gate-modul-erreicht-den-vendored-baum-nicht` | 3 | geplant, `slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer` | die 111 Inline-Pfade aus §1 |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |

**Keiner der Einträge erreicht mit diesem Slice zum ersten Mal 3×:** Die drei bei 1× mit
Berührung werden 2×, die drei bei 2× mit Berührung bleiben unter der Schwelle. Tritt einer doch
auf 3×, ist der Eintrag eine Lücke mit eigenem Folge-Slice und geht in §7. **Kein Eintrag über
der Schwelle steht auf `offen`:** Alle aufgeführten mit mindestens drei Belegen tragen `geplant`
oder `verkörpert`, und jede genannte Kennung liegt als Datei im Lifecycle.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte Sub-Area
BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

# Slice slice-081: Baum tauschen, Pin ziehen, Verweise nachziehen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
[ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) (dieser Slice ist ihre Folgepflicht 1),
[ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (ihre Folgepflichten 1
und 2 — der `scan.ignore`-Eintrag und der Nachtrag in
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
[ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) (ihre **Folgepflicht 1** —
neuer Tag **und** neuer Dateiname, Anker einzeln, die Ausnahme aus
[ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) dabei vollzogen; und
ihre **Folgepflicht 3** — die Klassen sind eine **Sortier-Aufgabe je Treffer**, keine Liste, die
zwischen Schnitt und Ausführung altert).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

`.harness/baseline/v5.12.0/` ist der **einzige** vendored Baum, der Tag steht an jedem Ort, der ihn
mechanisch trägt — **und kein lebender Verweis zeigt mehr in den alten.**

Der mechanische Teil ist klein und eng gekoppelt: `BASELINE_TAG` und `BASELINE_ZIP_SHA256` im
[`Makefile`](../../../../Makefile), `DefaultTag` und `DefaultBaselineSHA256` in
`internal/fetch/baseline.go`, die `sources`-URL des gepinnten Assets in `.d-check.yml`. Die beiden
Go-Konstanten hängen per Test am `Makefile` (`TestDefaultTag_MatchesBaseline`,
`TestDefaultBaselineSHA256_MatchesMakefile`) — eine halbe Migration fällt dort auf.

Der große Teil sind die Verweise, und sie zerfallen in Klassen, die verschieden behandelt werden
([ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md)). **Gate-sichtbar sind 21**
Markdown-Links — gefahren, nicht hochgerechnet: Baum auf `v5.3.0` umbenannt, `make docs-check`,
zurückbenannt, Ergebnis `309 Datei(en) geprüft, 21 Befund(e)`, alle `target-missing` (2026-08-09).
Die Sonde lief gegen den damaligen Zielnamen; der Befund hängt am **alten** Tag, nicht am neuen —
unter jedem anderen Zielnamen fällt dieselbe Zahl.

**Der Betrag ist datiert und wandert; die Klassen binden.** Am 2026-08-28 sind es **24** über
**vier** statt drei Fundorte — der Zuwachs liegt vollständig in einer **lebenden Plandatei**, die
es zum Zeitpunkt der Sonde nicht gab. Erhoben ohne Gate-Lauf, weil `target-missing` genau diese
Form findet:
`git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- ':!.harness/baseline' | wc -l`
→ **24**, mit `| cut -d: -f1 | sort | uniq -c | sort -rn` die Verteilung. **Kein Erwartungswert**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beim Lauf neu zu erheben, wie bei den stummen Nennungen unten.

- **Die Links in lebende Artefakte werden nachgezogen** —
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) 12,
  [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) 4 und
  eine lebende Plandatei mit 3.
- **1 bleibt byte-gleich** — [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) ist
  Accepted und damit unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Sie wird nicht
  repariert; ihre Datei tritt als einziger neuer `scan.ignore`-Eintrag aus dem Doku-Gate
  ([ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)).
- **4 verlieren ihre Adresse, nicht ihren Text** — zwei in
  `docs/plan/planning/done/slice-076-mr-018-umzug-technik-stratum.md`, je eine in
  `docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md` und
  `docs/reviews/2026-07-26-slice-050-verification.md`.

Dazu die **stummen** Inline-Nennungen — die, die keinen Link tragen und deshalb von keinem
`target-missing` gefunden werden. **Ihre Menge wandert mit jedem Schnitt und steht deshalb nicht
als Zahl hier, sondern als Kommando**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), zu fahren beim Lauf, nicht beim Schnitt:
`grep -rn '\.harness/baseline/v3\.5\.2/' --include='*.md' . | grep -v '^\./\.harness/' | grep -v ']('`.
**Was mit einem Treffer geschieht, entscheidet seine Klasse, und die vier Klassen sind fest:**
[`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) und
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) werden
**gezogen** (lebende Norm-Artefakte). **Unberührt** bleiben Accepted-ADRs
([ADR-0011](../../adr/0011-telemetrie-erfassung-policy.md),
[ADR-0012](../../adr/0012-haupt-kontext-ohne-token-bilanz.md),
[ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md);
[`AGENTS.md`](../../../../AGENTS.md) §3.4) und alles unter `done/` und `docs/reviews/` —
Zeitdokumente. **Unberührt bleibt auch**
[slice-083](../next/slice-083-form-vergleich-pflichtfelder.md): er nennt den alten Tag als
**Tree-Operanden der Vor-Tausch-Seite** — genau die Adresse, die der Tausch nicht anfassen darf.

**Und diese Ausnahme ist keine Einzelfall-Ausnahme, sondern eine Klasse.** Eine lebende Plandatei
nennt den Tag meist als **Operanden eines Kommandos, dessen Ergebnis im selben Satz zitiert wird**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Für sie gilt: **Adresse und Ergebnis hängen zusammen und werden gemeinsam gezogen
oder gemeinsam stehen gelassen** — ein `sed` über den Tag-String allein ließe das Kommando gegen
einen anderen Baum laufen als die Zahl daneben behauptet, und macht damit aus einem toten Link ein
falsches Zitat (dasselbe Muster wie unter §6, nur ohne Link).

**Damit trägt der Tausch eine Klasse, nach der keine der vier fragt: die Adresse hält, das Zitat
oder die Folgerung bricht.** Sie ist gemessen, nicht vermutet — drei Fälle in `slice-114`, dazu
**vier** von sechs nachgefahrenen Operanden-Messungen in lebenden Plandateien, deren Ergebnis sich
gegen den neuen Baum bewegt. Ihr Ausgang ist **kein** Teil dieses Slice: er ist als
[slice-131](../in-progress/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) geschnitten, der die
Sortierung je Treffer führt und die Regel dahinter an einen Ort bringt. Was **hier** bleibt, ist
die Feststellung, dass die vier Klassen die Frage nach der Auflösbarkeit stellen und nicht die
nach der Wahrheit.

Dazu drei Fixture-Namen in `test/sessionstart.bats`, die `grundlagen-konventionen.md` heißen.

## 2. Definition of Done

- [x] `.harness/baseline/v5.12.0/` ist das **einzige** `<tag>`-Verzeichnis, und `make baseline-verify`
      meldet `v5.12.0 OK — 51 Dateien` (heute: `v3.5.2 OK — 42 Dateien`). Der alte Tag steht danach
      an **keiner** der fünf mechanischen Stellen mehr (`Makefile` ×2, `internal/fetch` ×2,
      `.d-check.yml`). **Nicht** in Scope: die auf `v3.5.2` gepinnten Kurs-URLs in den
      Lifecycle-Köpfen bestehender Slices — sie sind Instanzen einer alten Vorlage und werden nach
      der Append-only-Logik nicht rückwirkend umgeschrieben.
- [x] **Jeder** gate-sichtbare Befund trägt den Ausgang seiner Klasse aus
      [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) — die **Menge** wird beim Lauf
      erhoben, nicht aus §1 übernommen: die Links in **lebende** Artefakte zeigen auf den neuen
      Baum — neuer Tag **und** neuer Dateiname, **jeder Anker einzeln gegen die Zieldatei geprüft,
      kein `sed` über den Tag-String**; **1** ([`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md))
      bleibt byte-gleich und ihre Datei ist **der einzige neue** `scan.ignore`-Eintrag in
      `.d-check.yml` ([ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md))
      — mit Begründung und Zeiger auf sie im Config-Kommentar, und **der Adaptions-Block führt
      Zahl, Klassifikation und die Aufnahme-Grenze nach**; **4** Adressen in drei Zeitdokumenten
      entfallen, während ihr sichtbarer Text Zeichen für Zeichen stehen bleibt.

      **Der Ort dieser Nachführung ist der Nachfolge-Eintrag, nicht das Original.**
      [ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) §Konsequenzen
      Folgepflicht 2 nennt
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids);
      die Append-only-Disziplin des Blocks verbietet, dort hineinzuschreiben — jene Zahl ist die
      historisch richtige Aussage über ihren Tag. Erfüllt ist der Punkt deshalb durch einen
      **neuen** Eintrag, der die überholte Zensus-Aussage benennt und den geltenden Stand mit dem
      Kommando trägt, das ihn ausgibt; die Begründung des Ortswechsels steht an ihm und ist
      Architect-Sache ([`AGENTS.md`](../../../../AGENTS.md) §3.8). **Nicht** Bedingung dieses
      Punktes ist, ob das Original einen Zeiger auf seinen Nachfolger bekommt — dafür führt der
      Block zwei verschiedene Präzedenzien, und die Wahl gehört in den Adaptions-Durchgang
      ([slice-082](../done/slice-082-adaptions-durchgang.md) §2).

      **Die stummen Inline-Nennungen zerfallen in drei Ausgänge, nicht in einen** — kein Gate
      sieht sie, also zählt dort die Liste, nicht das Grün. **Gezogen**, wo die Zieldatei die
      Aussage weiter trägt; **begründet stehen gelassen**, wo der Zug ein Zitat fabrizierte, weil
      die zitierte Zeile am neuen Stand nicht mehr existiert — der Grund steht am Fundort, nicht
      hier; **abgegeben** an [slice-082](../done/slice-082-adaptions-durchgang.md) Achse 1, wo
      nicht die Adresse offen ist, sondern ob die Messung daneben gegen den gepinnten Stand noch
      reproduziert. Ein pauschales *„alle gezogen"* erfüllt den Punkt damit **nicht**: verlangt
      ist die Restmenge mit **einem** dieser drei Ausgänge je Treffer.
      `grep -n '\.harness/baseline/v3\.5\.2/' harness/conventions.md | grep -v ']('` listet sie,
      `grep '\.harness/baseline/v3\.5\.2/' harness/conventions.md | grep -vc ']('` zählt sie — am
      2026-08-29 **8**, und das ist **kein** Erwartungswert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). Die stummen Nennungen in Accepted-ADRs bleiben unberührt:
      `grep -rh '\.harness/baseline/v3\.5\.2/' --include='*.md' docs/plan/adr/ | grep -vc ']('`
      → am 2026-08-29 **6**.
- [x] **Alle vier** Kopplungs-Zähne sind **rot gesehen**: je eine Sonde bumpt nur eine Seite, und
      der zugehörige Sensor fällt ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — zwei Go-Tests
      (`TestDefaultTag_MatchesBaseline`, `TestDefaultBaselineSHA256_MatchesMakefile`) und zwei
      bats-Fälle über `.d-check.yml` ↔ `Makefile` (`sources-url` trägt den aktuellen
      `BASELINE_TAG`, `sources-sha256` gleicht `BASELINE_ZIP_SHA256` —
      [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)).
- [x] **Jeder rote Sensor dieses Slice trägt einen benannten Ausgang — Carveout *oder* Slice —,
      und keiner bleibt unzugeordnet.** Das ist der Abnahme-Punkt, nicht *„`make gates` grün"* —
      und der Unterschied ist gemessen, nicht formuliert: die Farbe hängt nach dem Tausch an
      Entscheidungen, die außerhalb dieses Slice liegen und anderen Rollen gehören. **Der Punkt
      zählt vier Sensoren, nicht einen** — dass er zuerst nur `make gates` nannte, war die Lücke,
      durch die der Bruch unten unbemerkt blieb:
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
      führt als **Messmethode** wörtlich den Smoke-Test, und der läuft ausdrücklich **nicht** in
      `make gates`. **Die Menge der Sensoren ist keine Aufzählung nach Gefühl, sondern gegen zwei
      Quellen gezählt:** [welle-10](../welle-10-re-baseline.md) §3 führt drei Ziele außerhalb der
      Gates, und dieselben drei bleiben im Makefile übrig —
      `grep -nE '^[a-z][a-z0-9-]*:.*NICHT in gates' Makefile` → am 2026-08-29 **12** Zeilen, davon
      weisen sich **9** selbst als etwas anderes als ein Sensor aus (dasselbe Kommando mit
      `| grep -cE 'Maintenance/CI|Bericht, kein Sensor|Messung, kein Sensor|Compile-Feedback'`);
      übrig bleiben `smoke`, `full-smoke`, `mutate`. `make gates` ist der vierte. Die
      Zahlen wandern mit dem Makefile und sind keine Erwartungswerte
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).
      1. **`make gates`** — zwei Befunde, beide mit **extensional geschlossenem** Carveout:
         [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) (zwei Fälle in
         `test/courseset-fixture.bats`; ihr Grün setzt die Klassen-Entscheidung über vier neue
         Vorlagen voraus — [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md))
         und [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) (**eine**
         Referenz in
         [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
         Punkt 2, deren Satz nur über den abgelösten Stand wahr ist —
         [slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md)). Der Weg ist der, den
         Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln
         ausdrücklich offenlässt: *„Ein Slice darf bei rotem Gate nur mit dokumentiertem Carveout
         (Modul 7) in `done/` landen, der den roten Gate-Status auf Trigger schaltet."*
      2. **`make smoke` / `make full-smoke`** — **10** Befunde im emittierten Baum, gemessen und
         gegen den Vor-Stand gehalten (§6). Sie brechen
         [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
         [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) und
         tragen **keinen** Carveout — eine Rang-1-Zusage wird nicht ausgenommen, sondern repariert
         (Begründung über den Trichter aus Modul 7 §Werkzeug-Wahl in
         [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §1). Zugeordnet
         sind sie zwei Slices derselben Welle: **7** an
         [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md), **3** an
         [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md), aufgeteilt je
         Befund an seiner Vorlagen-Zeile. [welle-10](../welle-10-re-baseline.md) §3 führt beide
         Läufe im Closure-Kriterium — die Welle schließt nicht über diesem Rot.
      3. **Die Modul-7-Pflicht von `CO-004` ist offen und benannt.** Die Gate-Ausgabe nennt die
         Kennung nicht (`git grep -c 'CO-004' -- test/ .d-check.yml Makefile` → kein Treffer); die
         Verdrahtung liegt in `test/` und ist Implementer-Arbeit. Offen **benannt** erfüllt diesen
         Punkt, offen **verschwiegen** nicht.
      4. **`make mutate` — rot, und nicht teilweise: er läuft gar nicht.** Der Treiber fährt vor
         der ersten Mutation je Sensor-Modus einen **Grün-Vorlauf** und bricht den Worker ab, wenn
         der Modus in **seiner** Kopie schon ohne Mutation rot ist (`harness/tools/mutate.sh`,
         `worker_main`: *„ABBRUCH — Worker …: der Gruen-Vorlauf 'make …' ist in SEINER Kopie ohne
         Mutation rot."*); die Warteschlange gibt die teuersten Modi zuerst aus (`mode_rank`), und
         ein abbrechender Worker lässt seinen Rest liegen. Rot sind genau die Modi, die die
         Sensoren 1 und 2 tragen — alles, was `test-bats` fährt (die zwei Fälle aus
         [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md); auch der
         fail-closed-Voll-Satz `test` enthält sie) und alles, was den emittierten Baum fährt
         (`smoke`, `full-smoke`). Am Stand `06a640a` endet der Lauf deshalb mit `0 ok` und
         `vollstaendigkeit … 0 von 198 Fall-Dateien haben ein Ergebnis` (`make mutate`; die
         Fall-Zahl wandert — `ls test/mutations/*.sh | wc -l` → am 2026-08-29 **198**, kein
         Erwartungswert).
         **Sein Ausgang ist kein eigener, und genau das ist die Feststellung:** dieser Sensor hat
         keine eigene Ursache, sondern die der Sensoren 1 und 2. Er ist damit denselben zwei
         Slices zugeordnet — [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)
         und [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) —, nicht
         einem dritten Artefakt daneben. **Kein weiterer Carveout**, und das folgt aus dem
         Trichter, nicht aus Bequemlichkeit: Frage 1 (Granularität) trifft auf dieselbe Häufung im
         selben Geltungsbereich wie bei Sensor 2, und Baseline-Regelwerk `modul-07-carveouts.md`
         sagt dazu *„Eine Diskrepanz-**Häufung** … gehört nicht in eine Carveout-Kaskade"*; dazu
         stünde eine Ausnahme, die den Bruch von
         [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
         mitträgt, in keinem Rang der Source Precedence und dürfte nichts festlegen.
         **Was das kostet, ist benannt statt weggerechnet:** bis beide Slices in `done/` liegen,
         läuft die Haltbarkeits-Prüfung aus [`AGENTS.md`](../../../../AGENTS.md) §3.6 über
         **keinen** ihrer Fälle — sie schweigt, aber sie schweigt **laut** (der Treiber meldet die
         Unvollständigkeit in jedem Lauf, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
         ist damit gewahrt). Der Preis der Reihenfolge steht in
         [welle-10](../welle-10-re-baseline.md) §4. **Dass der Sensor mit den beiden Slices
         zurückkehrt, ist Vorhersage, nicht Beleg**; geprüft wird sie im Closure-Kriterium der
         Welle, das `make mutate` bereits führt ([welle-10](../welle-10-re-baseline.md) §3). Bleibt
         er danach rot, ist das ein **neuer** Befund mit eigenem Ausgang und kein Nachziehen
         dieser Zeile.

      **Jeder Befund außerhalb dieser vier bleibt Bedingung dieses Punktes.** **Warum nicht die
      Rückführung:** `→ next` trifft nicht (die Verweis-Arbeit hat keine Sitzung gesprengt, sie ist
      gefahren und belegt), und `→ open` fröre bei einem WIP-Limit von 1 die ganze Welle auf
      Entscheidungen ein, die andere Slices tragen.
- [x] Doku-Update: die Baseline-Zeilen in `harness/conventions.md` §Baseline und der
      Herkunfts-Absatz in `docs/user/benutzerhandbuch.md` nennen den neuen Tag.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/` | ersetzen (alt raus, neu rein, `SHA256SUMS` neu) | ein Tag zur Zeit ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| [`Makefile`](../../../../Makefile) | update | `BASELINE_TAG`, `BASELINE_ZIP_SHA256` — die kanonische Quelle des Tag-Strings |
| `internal/fetch/baseline.go` | update | `DefaultTag`, `DefaultBaselineSHA256`; per Test ans `Makefile` gekoppelt |
| `.d-check.yml` | update | `sources`-URL des gepinnten Assets (`make regelwerk-check`); **und** der eine `scan.ignore`-Eintrag aus [ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) — eine namentlich genannte Datei, extensional geschlossen: jeder weitere Eintrag ist eine eigene Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und gehört nicht in diesen Slice |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder), [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) | update | die nachziehbaren Links — die Menge erhebt der Lauf, nicht dieser Plan (§2) — und die stummen Inline-Nennungen, jede mit **einem** der drei Ausgänge aus §2 (gezogen · begründet stehen gelassen · an [slice-082](../done/slice-082-adaptions-durchgang.md) Achse 1 abgegeben). Dazu der **Adaptions-Block** als Zähl- und Klassifikations-Ort der `scan.ignore`-Einträge, und zwar als **neuer** Eintrag: [ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) Folgepflicht 2 nennt [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), dessen Append-only-Disziplin das Hineinschreiben sperrt (§2) |
| [ADR-0011](../../adr/0011-telemetrie-erfassung-policy.md), [ADR-0012](../../adr/0012-haupt-kontext-ohne-token-bilanz.md), [ADR-0013](../../adr/0013-technik-stratum-als-zielort.md), [ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md), [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) | **unberührt** | alle fünf *Accepted* und damit unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4); [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 1 heilt den Bestand nicht. Die letztgenannte nennt den Baum ohnehin an keiner Stelle |
| `docs/plan/planning/done/slice-076-mr-018-umzug-technik-stratum.md`, `docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md`, `docs/reviews/2026-07-26-slice-050-verification.md` | update (nur Adresse) | [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4: der Markdown-Link wird zur reinen Nennung. Wer hier einen Satz ändert, verstößt gegen ihre Begründung |
| `test/sessionstart.bats` | update | drei Fixture-Namen heißen `grundlagen-konventionen.md` |

## 4. Trigger

[slice-080](../done/slice-080-verweis-ueberlebt-tagwechsel.md) liegt in `done/`, und
[ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) **wie**
[ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) sind *Accepted* — die
Festlegung, wie ein Verweis den Tag-Wechsel übersteht, und die Ausnahme, die den Doku-Gate dabei
grün hält, liegen beide vor dem Wechsel. Der Status ist tragend, nicht formal:
die `scan.ignore`-Aufnahme ist eine Gate-Senkung, und die trägt nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 eine Entscheidung, keinen Vorschlag.

Rückführungen: `in-progress` → `next`, wenn das Nachziehen der Verweise für sich eine Sitzung
sprengt (dann trennt der Schnitt Mechanik und Verweise). `in-progress` → `open`, wenn die
Anker-Einzelprüfung ergibt, dass die Ziel-Fassung eine belegte Aussage nicht mehr trägt — das ist
eine Inhaltsfrage für [slice-082](../done/slice-082-adaptions-durchgang.md), kein Pfad-Tausch. Die zwei
Sensoren aus der Fitness Function von [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md)
sind **nicht** die Bedingung: sie sind dort ausdrücklich einem eigenen Slice zugewiesen.

## 5. Closure-Trigger

DoD vollständig — insbesondere §2 (4) in seiner Fassung mit **vier** Sensoren —, und Closure-Notiz
mit Steering-Loop-Lerneintrag geschrieben. **Nicht** *„`make gates` grün"*: dieser Slice schließt
über zwei Carveouts mit Folge-Slice und über einem Rot in `smoke`, `full-smoke` und `mutate`, das
zwei Slices derselben Welle tragen. Ein Closure-Kriterium, das hier Grün verlangte, verlangte etwas, das die DoD ausdrücklich
verwirft — und der Abschluss richtete sich danach, welche der beiden Stellen zuerst gelesen wird.
Das Grün ist Kriterium der **Welle**, nicht dieses Slice
([welle-10](../welle-10-re-baseline.md) §3).

## 6. Risiken und offene Punkte

- **Der Zwischenzustand ist real und gehört benannt.** Nach diesem Slice steht der Pin auf
  `v5.12.0`, während [`AGENTS.md`](../../../../AGENTS.md) §3.7,
  [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  und [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  weiter über `v3.5.2` sprechen. Diese Sätze sind **datierte Messungen**, keine Links — kein Gate
  sieht sie. Sie fallen mit [slice-082](../done/slice-082-adaptions-durchgang.md). Der Preis dafür, den
  Adaptions-Durchgang nicht in denselben Slice zu packen: das Repo trägt zwischen 081 und 082 eine
  Aussage, deren Bezug gewechselt hat.
  — **Ausgang:** eingetreten, für die drei genannten Stellen aber innerhalb der Kette dieses Slice
  geschlossen und nicht erst durch 082: [`AGENTS.md`](../../../../AGENTS.md) §3.7 nennt jetzt
  `v5.12.0` als Mess-Stand, und der einzige verbliebene Treffer des alten Tags in jener Datei sitzt
  in §3.8 mit seinem eigenen Mess-Tag daneben (`grep -c 'v3\.5\.2' AGENTS.md` → **1**);
  [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  und [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  sind auf Kopf und Zeiger zurückgenommen
  (`awk '/^### MR-[0-9]+ — Kommentar-Regel als Vorgriff/,/^### MR-[0-9]+ — d-check-Pin/' harness/conventions.md | wc -l`
  → **11** Zeilen für beide Einträge zusammen, Überschriften eingerechnet). Beide Zahlen wandern und sind keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Offen bleibt nicht dieser Satz, sondern die **Klasse** über die übrigen Einträge des
  Blocks — sie trägt [slice-082](../done/slice-082-adaptions-durchgang.md) Achse 1.
- **Ein Träger des Zwischenzustands ist kein Dokument, sondern ein Werkzeug: `.harness/skills/reviewer.md`.**
  Sein Kopf erklärt *„Agents-Regelwerk v3.5.2 (Kurs-Welle 34)"* zur Baseline (`grep -c 'v3\.5\.2'
  .harness/skills/reviewer.md` → **4** Zeilen), und sein Output-Schema führt **fünf** Felder, wo
  `modul-10-review-harness.md` am gepinnten Stand **sechs** verlangt (`klasse`, Z. 72). Das ist
  dieselbe Klasse wie die Sätze oben — Präsens-Aussage gegen einen Stand, den es nicht mehr gibt —,
  aber es wiegt schwerer: die anderen werden gelesen, dieser **steuert die Rolle, die die übrigen
  Befunde dieser Welle findet**. Kein Gate sieht ihn; `.d-check.yml` liest keine Skill-Metadaten.
  — **Ausgang:** eingetreten → [slice-083](../next/slice-083-form-vergleich-pflichtfelder.md) §2 (1),
  dem Form-Durchgang dieser Welle. **Nicht** slice-085: dort geht es um das **emittierte** Repo,
  hier um ein ausgefülltes Artefakt dieses — zwei Ebenen, zwei Verträge. Der Preis bis dahin ist
  benannt und nicht wegverhandelt: jeder Review zwischen 081 und 083 läuft auf einem Skill, dessen
  Kopf über seine eigene Grundlage irrt, und muss das im Report selbst ausweisen.
- **Nach diesem Slice liegt die alte Form nur noch in der Historie — das ist die Zusage von
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
  nicht ihr Preis.** *„Ein Tag zur Zeit (Ersetzen), Historie liegt in git"*: der Form-Vergleich aus
  [slice-083](../next/slice-083-form-vergleich-pflichtfelder.md) holt die alte Seite dort, mit
  Tree-Operanden statt zwei Verzeichnissen. Was er dafür braucht, ist **der Commit, der den Baum
  getauscht hat** — er steht als jüngster Eintrag in `git log --oneline -- .harness/baseline/`,
  derselben Abfrage, die heute die drei bisherigen Re-Vendors auflistet.
  `harness/tools/baseline-verify.sh` bricht bei mehr als einem `<tag>`-Verzeichnis ab und schützt
  damit die Eindeutigkeit, auf der dieser Zugriff beruht.
  — **Ausgang:** eingetreten wie zugesagt, und der Zugriffsweg steht: der Tausch-Commit ist der
  jüngste Eintrag der Abfrage (`git log --oneline -1 -- .harness/baseline/` → `b902b60`), und der
  Baum ist eindeutig (`make baseline-verify` → `v5.12.0 OK — 51 Dateien`). Träger der alten Seite
  ist [slice-083](../next/slice-083-form-vergleich-pflichtfelder.md), der sie über Tree-Operanden
  holt; ein zweites vendored Verzeichnis entsteht dafür nicht.
- **Der mechanische Tag-Tausch macht aus einem toten Link ein falsches Zitat.** Gemessen an
  Zeile 129 von `modul-07-carveouts.md`: bei `v3.5.2` steht dort *„Slice schlägt Memo"*, bei
  `v5.12.0` ein unverwandter Satz über die Aufgaben des Implementers
  (`for t in v3.5.2 v5.12.0; do git show $t:lab/regelwerk/modul-07-carveouts.md | sed -n '129p'; done`
  gegen einen lokalen Kurs-Klon). Ein `sed` über den Tag-String
  färbt den Gate grün und verschiebt den Fehler von *laut* nach *stumm* — deshalb verlangt die DoD
  die Anker-Einzelprüfung. `grundlagen-konventionen.md` ist der Fall, an dem das auffällt (bei
  `v5.12.0` in sechs Dateien zerlegt,
  `comm -13 <(git ls-tree -r --name-only v3.5.2 -- lab/regelwerk | xargs -n1 basename | sort) <(git ls-tree -r --name-only v5.12.0 -- lab/regelwerk | xargs -n1 basename | sort) | grep -c grundlagen`
  → **6**); die 15 Links auf `modul-15-observability.md` und
  `modul-08-agentenrollen.md` sind der Fall, an dem es nicht auffällt.
  — **Ausgang:** entfallen, weil die Gegenmaßnahme gefahren wurde: sortiert wurde je Treffer, nicht
  per `sed` über den Tag-String (`b902b60`). Der Beleg ist negativ und trägt gerade deshalb — die
  Zieldateien heißen am neuen Stand anders, ein Pfad-`sed` hätte den Doku-Gate rot gelassen, und
  `make docs-check` schweigt über sämtliche gezogenen Dateien (`452 Datei(en) geprüft,
  1 Befund(e)`, und der eine ist
  [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md)). **Nicht** entfallen ist
  die verwandte Klasse *Adresse hält, Aussage bricht* — sie steht als letzter Punkt dieser Liste
  mit eigenem Ausgang.
- **`BASELINE_ZIP_SHA256` kommt aus dem Asset, nicht aus dem Baum.** Ein aus dem entpackten
  Verzeichnis gerechneter Hash belegt die Herkunft nicht; die Gegenprobe ist
  `make regelwerk-check` (Netz, außerhalb der Gates).
  — **Ausgang:** entfallen, weil der Ladeweg belegt statt behauptet ist: `b902b60` hält fest, dass
  der Extrakt des containerisiert geladenen `v3.5.2`-Assets byte-identisch zum damals vendored Baum
  war und dessen `BASELINE_ZIP_SHA256` exakt reproduzierte, und dass `v5.12.0` zweimal unabhängig
  geladen denselben Hash lieferte. Was der netzlose Teil trägt, misst `make baseline-verify`
  (Integrität **und** Vollständigkeit); `make regelwerk-check` bleibt die netzgebundene Gegenprobe
  außerhalb der Gates und ist keine Bedingung dieses Slice.
- **Der vendored Baum ist nicht nur Verweis-Ziel, sondern Eingabe eines Gates.** `make test`
  liest über `test/courseset-fixture.bats` den **Inhalt** des Template-Satzes, nicht seinen Pfad;
  der Tausch stellt dort vier Klassen-Fragen, die dieser Slice nicht beantwortet. — **Ausgang:**
  eingetreten → [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) mit Folge-Slice
  [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md).
- **Der vendored Baum ist zugleich die Eingabe des Emissions-Kanals, und der trägt eine
  Rang-1-Zusage.** `internal/fetch/baseline.go` `DefaultTag` zeigt nach dem Tausch auf den neuen
  Satz; was ein frisch gebootstrapptes Zielrepo bekommt, wechselt damit **ohne** eine Zeile in
  `internal/emit/`. Gemessen, nicht befürchtet: `make smoke` meldet am Stand `26aec2c`
  `23 Datei(en) geprüft, 10 Befund(e)`, über dem Vor-Tausch-Stand
  (`T=$(mktemp -d); git archive c6cc56f | tar -x -C "$T"; cd "$T" && make smoke`)
  `19 Datei(en) geprüft, 0 Befund(e)` bei Exit 0 — **keine Erwartungswerte**
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Damit brechen
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3).
  **Dieses Risiko stand vor dem Lauf nicht hier** — der Plan hat den Baum als Verweis-Ziel und als
  Test-Eingabe inventarisiert, nicht als Emissions-Eingabe; dieselbe Lücke, die
  [welle-10](../welle-10-re-baseline.md) §4 für die drei Nachzügler benennt, eine Ebene weiter.
  — **Ausgang:** eingetreten → **kein Carveout, sondern Reparatur** (eine Rang-1-Zusage wird nicht
  ausgenommen; der Trichter aus Modul 7 §Werkzeug-Wahl führt bei dieser Häufung nicht auf
  Carveout — Begründung in
  [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §1): **7** Befunde →
  [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md), **3** →
  [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md).
- **Der einzige Sensor dieser Klasse liegt außerhalb von `make gates`, und das steht seit
  slice-028 im Code.** Der Doc-Kommentar von `NeutralizeRoadmap` sagt es selbst: *„diese reale
  Drift faengt allein `make smoke` (Tier-2, NICHT in make gates)"*. Ein Abnahme-Punkt, der nur
  `make gates` nennt, kann den Bruch darum nicht sehen — er hat ihn hier auch nicht gesehen.
  — **Ausgang:** eingetreten → §2 DoD (4) zählt vier Sensoren statt einen; ob ein Wächter
  **innerhalb** der Gates baubar ist, entscheidet
  [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §2 (3).
- **Ein roter Sensor kann einen zweiten mitreißen, und der zweite sieht dann gar nichts mehr.**
  `make mutate` hat keine eigene Ursache: sein Grün-Vorlauf fährt dieselben Modi, die die zwei
  Befund-Klassen oben rot halten, und bricht fail-closed ab, bevor die erste Mutation läuft. Die
  Wirkung ist nicht *„ein Sensor weniger"*, sondern *„die Haltbarkeits-Prüfung sämtlicher **gelisteter**
  Wächter aus [`AGENTS.md`](../../../../AGENTS.md) §3.6 läuft über null Fälle"* — und sie steht
  seit diesem Slice, nicht seit einem der Folge-Slices. **Dass ein Folgefehler dieser Art beim
  Schnitt nicht inventarisiert war, ist dieselbe Lücke wie oben, eine Ebene weiter:** der Plan
  hat je Sensor gefragt, ob er rot wird, nicht, welcher Sensor einen anderen als **Vorbedingung**
  fährt. — **Ausgang:** eingetreten → §2 DoD (4) Sensor 4, zugeordnet
  [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) und
  [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md); die Rückkehr prüft
  [welle-10](../welle-10-re-baseline.md) §3, den Preis der Reihenfolge benennt dort §4.
- **Ein Verweis, der bewusst nicht gezogen wird, hat am Doku-Gate keinen Ort.** Der Beleg in
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 2 ist nur über den abgelösten Stand wahr und steht unter der Append-only-Regel des
  Blocks; das Modul `links` kennt am Pin `v0.65.0` **keine** Referenz-Ausnahme, und `scan.ignore`
  wirkt datei-weit. — **Ausgang:** eingetreten →
  [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) mit Folge-Slice
  [slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md).
- **Die vier Verweis-Klassen aus §1 fragen nach Auflösbarkeit, nicht nach Wahrheit.** Ein Verweis,
  dessen Datei und Anker halten, kann ein Zitat oder eine daraus gezogene Zahl tragen, die der
  neue Stand nicht mehr deckt — bei grünem Gate. — **Ausgang:** eingetreten → Folge-Slice
  [slice-131](../in-progress/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md); die drei
  gate-sichtbaren Fälle in `slice-114` sind in diesem Zug bereits behoben.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-29.
**Gegenstand:** die Kette über dem Vor-Stand `c6cc56f` — `e4a4909` (Move `open` → `in-progress`),
`3871da4` · `b902b60` (Implementer), `d72e6dd` · `d6f3ae8` (Architect), `26aec2c` (Planner),
`2b0d741` · `eaccc4d` (Architect), `ff2a1dd` (Review-Ablage), `db855a1` · `d12b938` (Planner),
`62bc866` · `06a640a` (Architect), `c17a473` · `16d5b0d` (Architect), `27f2794` (Verifikation),
`1a9c2b0` (Planner, Fix-Runde), `4defddb` (Planner), `3360c2e` (Review-Ablage), `b1b1ab7`
(Architect), `b6c51dc` (Planner).

Jede Zahl unten ist **in diesem Lauf** erhoben; die Zahlen aus Review und Verifikation waren
Eingabe, kein Beleg
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Alle Läufe Docker-only ([`AGENTS.md`](../../../../AGENTS.md) §3.9).

### DoD-Stand — sechs Punkte, davon **drei** slice-eigen (Modul 5 §Ziel-Form: ≤ 3)

Slice-eigen sind (1), (2) und (3); (4) ist Gate-Lauf und Risiko-Ausgang, (5) Doku-Nachzug, (6) die
Closure — Modul 5 zählt diese drei ausdrücklich nicht zum Umfang.

**(1) Ein Tag, fünf mechanische Stellen — ERFÜLLT.** `make baseline-verify` meldet wörtlich
`baseline-verify: v5.12.0 OK — 51 Dateien (Integritaet + Vollstaendigkeit, netzlos)` bei Exit 0;
`ls -1 .harness/baseline/ | wc -l` → **1**. Der alte Tag steht an keiner der fünf Stellen:
`grep -c 'v3\.5\.2' Makefile internal/fetch/baseline.go .d-check.yml` → je **0**, während
`BASELINE_TAG`, `DefaultTag` und die `sources`-URL den neuen tragen und beide Hash-Konstanten
zeichengleich sind. Die Nicht-Scope-Klausel hält: die auf den alten Tag gepinnten Kurs-URLs in den
Lifecycle-Köpfen bestehender Slices sind unangetastet.

**(2) Jeder gate-sichtbare Befund trägt den Ausgang seiner Klasse — ERFÜLLT.** Gate-sichtbar bleiben
**2** Links in den alten Baum
(`git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- ':!.harness/baseline' | wc -l`),
und beide sind zugeordnet: [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) bleibt
byte-gleich und ist der einzige neue `scan.ignore`-Eintrag (der Config-Kommentar trägt Begründung,
ADR-Zeiger und die extensionale Grenze), die zweite ist
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md). `make docs-check` bestätigt
die Menge: `452 Datei(en) geprüft, 1 Befund(e)`, und der eine ist genau jene Referenz.

**Die Restmenge der stummen Nennungen trägt je Treffer einen der drei Ausgänge, nicht einen
pauschalen.** `grep '\.harness/baseline/v3\.5\.2/' harness/conventions.md | grep -vc ']('` → **8**;
welcher Eintrag sie hält, gibt
`awk '/^### MR-/{h=$0} /\.harness\/baseline\/v3\.5\.2\//{if($0!~/\]\(/) print NR": "h}' harness/conventions.md`
aus. Beide Beträge wandern und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

| Ausgang | Treffer | Warum |
|---|---|---|
| **begründet stehen gelassen** | **5** — [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler), [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence), [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf), [`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt), [`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage) | Sie zitieren eine Zeile, die es am neuen Stand nicht gibt — `grundlagen-konventionen.md` existiert dort nicht mehr (`ls .harness/baseline/v5.12.0/regelwerk/ \| grep -c grundlagen-konventionen` → **0**), und der zitierte Kommentar über dem Adaptions-Block ist entfallen. Ein Tag-Nachzug fabrizierte hier ein Zitat. Sie nennen ihren Mess-Tag und erfüllen damit [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) Setzung 1 |
| **abgegeben** an [slice-082](../done/slice-082-adaptions-durchgang.md) Achse 1 | **3** — [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ×1, [`MR-026`](../../../../harness/conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung) ×2 | Nicht die Adresse ist offen, sondern ob die Messung daneben noch reproduziert. Gemessen: das Kommando in [`MR-026`](../../../../harness/conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung) Setzung 1 liefert über den alten Pfad **0** und über den neuen **2**, wo der Satz **1** behauptet (`for t in v3.5.2 v5.12.0; do comm -12 <(grep -E '^### 3\.' AGENTS.md \| sort) <(grep -E '^### 3\.' .harness/baseline/$t/templates/AGENTS.template.md 2>/dev/null \| sort) \| wc -l; done`). Der Ausgang ist Achse 1, nicht dieser Slice: über den Eintrag entscheidet die Rolle, die ihn schreibt ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| **entfallen** | **2**, außerhalb der heutigen Menge | Die zwei Nennungen in den Rümpfen von [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) sind mit dem Rumpf gefallen (`16d5b0d`), nicht gezogen worden |

Die stummen Nennungen in Accepted-ADRs bleiben unberührt
(`grep -rh '\.harness/baseline/v3\.5\.2/' --include='*.md' docs/plan/adr/ | grep -vc ']('` → **6**;
[`AGENTS.md`](../../../../AGENTS.md) §3.4). Die **4** Adressen in **3** Zeitdokumenten sind
entfallen, während der sichtbare Text Zeichen für Zeichen steht
([ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4). Die Nachführung von
Zahl, Klassifikation und Aufnahme-Grenze steht im **Nachfolge**-Eintrag
[`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage),
nicht im Original — die Append-only-Disziplin des Blocks verbietet das Hineinschreiben, und der
Punkt verlangt seit `1a9c2b0` genau diesen Ort.

**(3) Alle vier Kopplungs-Zähne rot gesehen — ERFÜLLT.** Vier Sonden, jede bumpt eine Seite, jede
färbt genau ihren Sensor und lässt die andere Seite grün: `DefaultTag` →
`--- FAIL: TestDefaultTag_MatchesBaseline`, `DefaultBaselineSHA256` →
`--- FAIL: TestDefaultBaselineSHA256_MatchesMakefile`, `sources`-URL → `not ok … sources-url`,
`sources`-sha256 → `not ok … sources-sha256`. Gefahren wurden sie über isolierten Kopien außerhalb
des Repos, mit Kontrolllauf nach Rücknahme — vom Implementer und unabhängig davon in der
Verifikation. Die halbe Migration fällt damit an vier getrennten Stellen auf
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**(4) Jeder rote Sensor trägt einen benannten Ausgang — ERFÜLLT**, und die Menge der roten Sensoren
ist heute neu erhoben statt übernommen. `make -k gates` (keep-going, damit der Abbruch nach
`docs-check` nicht die übrigen zehn Ziele verdeckt) liefert **genau zwei** rote Ziele:
`docs-check` mit `452 Datei(en) geprüft, 1 Befund(e)` =
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) und `test-bats` mit
`not ok 40` / `not ok 41` bei **189** Fällen (`grep -cE '^(ok|not ok)'` über dieselbe Ausgabe) =
[`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md). Grün sind
`baseline-verify` · `lint` · `build` · `shell-lint` · `ci-lint` · `host-bin` · `span-check` und
`comment-claims` (`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`). **Ein dritter Rot-Zustand
innerhalb der Gates existiert nicht.**
`make smoke` → `d-check: 23 Datei(en) geprüft, 10 Befund(e)`, Exit 2; die Aufteilung **7 + 3 = 10**
geht ohne Rest auf, und sie trifft je Befund an seiner Vorlagen-Zeile: **7** stammen aus **vor**
diesem Slice emittierten Vorlagen — der Roadmap-, der Harness-Einstiegs- und der
Konventionsspeicher-Vorlage
([slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)) —, **3** aus zweien der
vier neuen, der Wellen-Ergebnis- und der Adaptions-Eintrags-Vorlage
([slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md)); die Fundorte stehen
Zeile für Zeile in der Smoke-Ausgabe. `make full-smoke` zeigt dieselben zehn und endet mit
`full-smoke: FEHLER — make gates im emittierten Repo ist NICHT Exit 0`, wobei die Meldung
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) als verletzte Zusage nennt.
`make mutate` → `0 ok, 7 Befund(e)` und `0 von 198 Fall-Dateien haben ein Ergebnis`
(`ls test/mutations/*.sh | wc -l` → **198**, kein Erwartungswert); die Abbruchgründe nennen die
Ursache wörtlich und es ist keine eigene: *„der Gruen-Vorlauf 'make full-smoke' ist in SEINER Kopie
ohne Mutation rot"* (Worker 1) und *„… 'make test-bats' …"* (Worker 2 bis 4) — also die Sensoren 2
und 1. Die Modul-7-Pflicht von [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md)
ist offen **und benannt**: `git grep -c 'CO-004' -- test/ .d-check.yml Makefile` findet nichts, und
der Carveout sagt das über sich selbst.

**(5) Doku-Update — ERFÜLLT.** `harness/conventions.md` §Baseline nennt den neuen Tag in Herkunft,
Ablage und Verifikations-Zeile; die Beispielausgabe im Benutzerhandbuch spiegelt `DefaultTag`
(`grep -c 'Baseline v5\.12\.0 vendored' docs/user/benutzerhandbuch.md` → **1**). Die beiden
`COURSE_TAG=v3.5.2`-Beispiele dort bleiben richtig: sie zeigen, wie man **einen anderen** als den
voreingestellten Stand zieht, und brauchen dafür einen Tag, der nicht der voreingestellte ist.

**(6) Closure-Notiz mit Steering-Loop-Lerneintrag — ERFÜLLT**, diese Notiz.

**Rückführungen nach §4 — keine ausgelöst.** `in-progress` → `next` traf nicht: die Verweis-Arbeit
lief in einem Lauf und ist je Treffer belegt. `in-progress` → `open` traf nicht: die
Anker-Einzelprüfung hat keine Ziel-Fassung gefunden, die eine belegte Aussage nicht mehr trägt, ohne
dass ein Ausgang dafür bereitstünde — der eine Fall dieser Art
([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2) ist ein Carveout mit Folge-Slice, keine offene Priorität.

### Was funktionierte

**Die Sortierung je Treffer, und sie ist am negativen Beleg messbar.** Kein `sed` über den
Tag-String, sondern eine Entscheidung pro Verweis — und weil die Zieldateien am neuen Stand anders
heißen, wäre ein Pfad-`sed` am Doku-Gate sofort rot geblieben. Dass `make docs-check` über sämtliche
gezogenen Dateien schweigt, ist damit kein Nebenbefund, sondern der Sensor für *„Tag **und**
Dateiname gezogen"*.

**Der Schnitt hat die Entscheidungen nicht in den Slice gezogen, die ihm nicht gehören.** Der
Tausch hat vier Klassenfragen über neue Vorlagen, eine Rang-1-Verletzung im emittierten Baum und
eine unauflösbare Referenz im Adaptions-Block **erzeugt** — und keine davon in diesem Slice
entschieden. Zwei Carveouts mit Folge-Slice, drei neue Slices, kein stilles Rot.

**Die Rollen-Kette hat gehalten, wo eine Rolle allein nicht gereicht hätte.** Der Review fand drei
HIGH außerhalb von `make gates`; die Verifikation fand danach den vierten roten Sensor, den der
Review nicht sehen konnte, weil sein Lauf dort untersagt war. Beide Befunde sind vor dieser Closure
geschlossen worden, nicht in sie hinein verschoben.

### Was anders lief

**Der Zwischenzustand, den §6 als Preis bis 082 ankündigte, ist zur Hälfte in dieser Kette
gefallen.** Der Plan hat ihn den Adaptions-Durchgang tragen lassen; tatsächlich haben zwei
Architect-Läufe derselben Kette die drei benannten Stellen geschlossen —
[`AGENTS.md`](../../../../AGENTS.md) §3.7 misst gegen `v5.12.0`, die Rümpfe von
[`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
und [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
sind zurückgenommen. Was der Slice als *Preis einer Reihenfolge* geführt hat, war in Wahrheit ein
Posten mit einem früheren Fälligkeitszeitpunkt, als der Plan ihm gab.

**Der Slice hat fünf Rollen und zwei Prüfrunden gebraucht, und beide Prüfrunden haben an derselben
Kante gefunden: außerhalb von `make gates`.** Vier davon nennen sich in der Commit-Message
(`git log --format='%s' c6cc56f..HEAD | sed -n 's/^Rolle \([A-Za-z]*\):.*/\1/p' | sort -u` →
Architect · Planner · Reviewer · Verifier), die fünfte trägt die Lifecycle- und
Implementations-Commits ohne Rollen-Präfix. Drei HIGH des Reviews und der blockierende Befund der
Verifikation liegen sämtlich bei Sensoren, die die Gate-Liste nicht führt. Das ist kein Zufall des
Slice, sondern seine Bauart: er tauscht die Eingabe eines Emissions-Kanals, dessen einziger Wächter
`make smoke` ist — und `make smoke` steht ausdrücklich nicht in `make gates`.

### Steering-Loop-Eintrag — **benannte Spec-Lücke:** eine Zahl *neben* ihrem Kommando ist noch keine Zahl *aus* ihrem Kommando

**Die Klasse.** *Eine Aussage wird aus einem zweiten Artefakt übernommen — mitsamt dem Kommando,
das sie belegt — und im Zielzustand nicht nachgefahren. Das mitgereiste Kommando sieht dabei aus wie
der Beleg, den es nicht mehr liefert.*

**Vier Instanzen in dieser einen Kette, jede gemessen:**

1. Das Commit-Log wurde als Begründung einer Commit-Form ausgegeben; normativ sind
   [`AGENTS.md`](../../../../AGENTS.md) §3.3, §3.8 und §5, nicht der Bestand.
2. *„d-check trägt den Fall bereits"* — der Beleg traf d-checks **eigenen** Index, nicht unseren.
3. Der Zensus in [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
   behauptete *„Repo-Praxis, alle 24 ADRs"*; gemessen waren es 19 von 24, und die Datei selbst
   gehörte zu den fünf Ausnahmen.
4. **Und eine Instanz betrifft die DoD dieses Slice selbst.** Die Verifikation maß **10** stumme
   Nennungen gegen `06a640a`; diese Zahl wanderte mit ihrem Kommando in §2 (2) und bekam dort das
   Datum des 2026-08-29. Dazwischen lag `16d5b0d`, der zwei der zehn mit einem Eintrags-Rumpf
   löschte — dasselbe Kommando gibt **8** aus, und §2 (2) trägt diesen Wert. Die Zahl war am Tag
   ihres eigenen Datums falsch, und ihr Kommando stand daneben.

**Warum die geltenden Regeln das nicht fangen.**
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 verlangt **Nachbarschaft** — die Zahl steht neben dem Kommando, das genau sie ausgibt —,
und Setzung 2 verbietet, sie als Erwartungswert zu lesen. Instanz 4 erfüllt beide dem Wortlaut nach
und ist trotzdem falsch: **Nachbarschaft ist nicht Übereinstimmung.** Was fehlt, ist die Setzung,
dass eine übernommene Zahl gegen den Zustand nachgefahren wird, **in den** sie geschrieben wird —
nicht gegen den, aus dem sie stammt. Dieselbe Lücke eine Ebene weiter trägt Instanz 3: in einem
Artefakt, das ab *Accepted* einfriert, altert eine Zahl an genau dem Commit, der sie festschreibt,
wenn ihr Kommando keine gepinnte Mess-Basis nennt. Repariert wurde jene Instanz, indem die Basis
ins Kommando gezogen wurde (`b1b1ab7`) — als Einzelfall, nicht als Regel.

**Kein Wächter, und das gehört dazu.** `modules:` der `.d-check.yml` führt
`[links, anchors, ids, matrix, codepaths, spans]`; keines davon führt ein Kommando aus und
vergleicht seine Ausgabe mit der Ziffer daneben. `make comment-claims` hat keine Markdown-Datei im
Prüfbereich. Ob ein solches Modul **baubar** ist, ist keine Frage an dieses Repo, sondern an
d-check; der Pin-Zug [slice-135](../open/slice-135-d-check-pin-v0661.md) ist der Ort, an dem diese
Frage ohnehin gestellt wird.

**Der Träger, und er ist zweigeteilt — weil der Gegenstand es ist.**

- **Die Regel-Hälfte gehört dem Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8): sie
  schärft [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 um die Übereinstimmungs-Pflicht und um die gepinnte Mess-Basis für einfrierende
  Artefakte. Dieser Lauf schreibt sie **nicht**; er benennt sie und übergibt sie unten.
- **Die Bestands-Hälfte hat bereits einen Träger:**
  [slice-131](../in-progress/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) §2 (2) verlangt
  wörtlich *„Keine Zahl ist mitgewandert"* für jede nachgemessene Aussage und §2 (3) einen **Ort**
  für die Sortier-Regel. Sein Auslöser ist allerdings der **Tag-String** — Instanz 4 fiele darunter,
  die Instanzen 1 bis 3 nicht. Diese Verengung steht hier als benannter Rest, nicht als gelöst.

**Was ausdrücklich *kein* Steering-Loop-Eintrag ist, weil es schon verkörpert ist.** Dass ein roter
Sensor einen zweiten mitreißt — `make mutate` hat keine eigene Ursache, sein Grün-Vorlauf fährt die
Modi, die die Sensoren 1 und 2 rot halten — ist in dieser Kette bereits eingebaut: §2 DoD (4) zählt
vier Sensoren statt einen, §6 führt den Folgefehler mit Ausgang, und
[welle-10](../welle-10-re-baseline.md) §3 prüft die Rückkehr, §4 benennt den Preis. Es als Lehre zu
notieren, hieße einen geschlossenen Kreis ein zweites Mal aufzuschreiben.

### Risiken aus §6 — jedes mit genau einem Ausgang

Alle **elf** Punkte tragen ihre `— **Ausgang:**`-Zeile in §6 selbst
(`sed -n '/^## 6\./,/^## 7\./p' <diese Datei> | grep -c '\*\*Ausgang:\*\*'` → **11**):
**sieben eingetreten** mit Carveout oder Folge-Slice — einmal
[`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) mit
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md), einmal
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) mit
[slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md), dreimal
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) (zweimal davon zusammen
mit slice-130), einmal [slice-083](../next/slice-083-form-vergleich-pflichtfelder.md), einmal
[slice-131](../in-progress/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) —,
**zwei entfallen** mit Begründung (der `sed`-Fabrikations-Fall und die Hash-Herkunft),
**eines eingetreten und in dieser Kette geschlossen** (der Zwischenzustand der drei Norm-Stellen),
**eines eingetreten wie zugesagt** (die alte Form liegt in `git`, der Zugriffsweg steht). **Keines
bleibt ohne Ausgang** — der dritte Modul-5-Ausgang *weiter offen* wäre der Eintrag ins
Beobachtungs-Register und ist hier nicht gezogen worden, weil kein Punkt ihn braucht.

### Beobachtungs-Register — das Repo führt keines, und das ist die Antwort

Eine `observations.md` unter `docs/plan/planning/` existiert nicht
(`ls docs/plan/planning/observations.md` → kein Treffer). Der Ort ist ein Delta der neuen Baseline
und als Posten geführt, nicht vergessen: [slice-083](../next/slice-083-form-vergleich-pflichtfelder.md)
§6 trägt ihn samt der zwei Lese-Schritte, die ihn von einer bloßen Schreibpflicht unterscheiden.
Bis dahin zählt der Steering Loop dieses Repos über die Closure-Notizen, und die Verengung steht
oben benannt.

### Folge-Slices — jeder ist eine Datei in `open/`

[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) (vier neue Vorlagen
klassifizieren; löst [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) und drei der
zehn Smoke-Befunde) · [slice-131](../in-progress/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md)
(Präsens-Aussage gegen den gepinnten Stand) ·
[slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) (löst
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md)) ·
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) (sieben der zehn
Smoke-Befunde; läuft **vor** slice-130). Vorbestehend und unverändert zuständig:
[slice-082](../done/slice-082-adaptions-durchgang.md) (Adaptions-Durchgang) und
[slice-083](../next/slice-083-form-vergleich-pflichtfelder.md) (Form-Durchgang).

### Übergabe an andere Rollen

- **An den Architect** — drei Posten, jeder gemessen. (a) Die **Regel-Hälfte** des
  Steering-Loop-Eintrags oben. (b)
  [`MR-026`](../../../../harness/conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung)
  Setzung 1 behauptet **1** deckungsgleiche Überschrift; das Kommando liefert über den alten Pfad
  **0** und über den neuen **2** (Kommando in der Tabelle zu DoD (2) oben). (c)
  [`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  und [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  führen das Pflichtfeld `Ersetzt-Baseline-Regel` der neuen Vorlage nicht, die drei jüngeren
  Einträge führen es — der Form-Durchgang
  [slice-083](../next/slice-083-form-vergleich-pflichtfelder.md) ist der Ort, an dem das entschieden
  wird, nicht ein Nachzug hier.
- **An den Implementer:** der `scan.ignore`-Kommentar in `.d-check.yml` beziffert die Reichweite mit
  *„über alle fuenf Module"*, während `modules:` **sechs** führt
  (`grep -n 'fuenf Module' .d-check.yml` gegen `grep -n '^modules:' .d-check.yml`). Der Review führt
  es als LOW-1; es besteht fort.
- **An den Planner, eigene Sitzung:** [welle-09](../welle-09-modul-15-konformitaet.md) §3/§4 stehen
  auf dem Stand vor [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md).
  Derselbe Befund-Typ wie oben — eine überholte Aussage in einem **lebenden** Plan-Artefakt —, aber
  eine eigene Sitzung.

### Verifikation dieser Closure

In diesem Lauf gefahren, alle über `make`: `baseline-verify` (grün) · `docs-check`
(`452 Datei(en) geprüft, 1 Befund(e)` = [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md)) ·
`-k gates` (zwei rote Ziele, beide mit Carveout) · `smoke` (10 Befunde) · `full-smoke` (dieselben
10, dann die Meldung über
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)) ·
`mutate` (`0 ok, 7 Befund(e)`). **`make gates` ist rot, und das ist
nach §5 kein Closure-Hindernis:** der Slice schließt über zwei extensional geschlossene Carveouts
mit Folge-Slice und über einem Rot im emittierten Baum, das zwei Slices derselben Welle tragen. Das
Grün ist Kriterium der **Welle** ([welle-10](../welle-10-re-baseline.md) §3), nicht dieses Slice.
**Kein `git push`.**

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/`, `harness/`,
`docs/`, `internal/fetch/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
`.harness/baseline/` ist ein vendored Fremd-Blob und wird ersetzt, nicht gepflegt.

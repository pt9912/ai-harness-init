# Slice slice-130: Der Emitter entscheidet über jedes neue Template

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — sie trägt eine Closure-Bedingung, die von
dieser DoD verschieden ist (die drei Durchgänge der Ziel-Prozedur), und dieser Slice ist einer
ihrer Zugänge.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(die zweiklassige Ablage und ihre Zusage *out-of-the-box gate-sicher* — der Vertrag, den vier
unklassifizierte Vorlagen brechen),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0005`](../../adr/0005-ziel-repo-distribution.md) (wiederkehrende Vorlagen werden
referenziert, nicht co-located emittiert),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede der vier Entscheidungen nennt, was sie rot färbt).

**Berührte Spec-Stellen:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — ihre
namentliche Aufzählung der wiederkehrenden Vorlagen ist die Stelle, an der eine
Klassen-Entscheidung sichtbar wird oder still bleibt (§6). Der Verweis zeigt **aufwärts**: das
Lastenheft nennt diesen Slice nie.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jede Vorlage des gepinnten Satzes trägt eine begründete Klasse, und was ein frisch
gebootstrapptes Zielrepo bekommt, ist bei seinem ersten Gate-Lauf grün.**

### Der Anlass ist ein Wächter, der seine Frage stellt

`test/courseset-fixture.bats` hält die Emit-Fixture am realen Template-Satz fest und formuliert
seinen Zweck selbst: ein neuer Eintrag ist *„die Frage, die der geloeschte skel-drift-Waechter
stellte: gehoert er in scope, und wenn ja, ist er Singleton oder wiederkehrend
(`emit.isRecurring`)?"* — gestellt, *„statt das Neue still als Singleton zu behandeln"*. Mit dem
Baum-Tausch aus [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) ist sie gestellt:
die Zahl der in-scope-Vorlagen geht von **17** auf **21**.

```
find .harness/baseline/*/templates -type f | sed 's|.*/templates/||' \
  | grep '\.template\.md$' | grep -v '^project-readme\.template\.md$' | wc -l    # -> 21
```

**Der Betrag wandert mit dem Satz und ist kein Erwartungswert**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); tragend sind die **vier** Zugänge, nicht die Ziffer — und jede von ihnen sagt über
ihre eigene Vervielfältigung etwas anderes:

| Neu im Satz | Was ihr Template-Hinweis über ihre Vervielfältigung sagt |
|---|---|
| `.harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md` | *„Kopiere nach eine `observations.md` unter `docs/plan/planning/` (flach, neben den offenen Wellen)"* — **eine** je Repo |
| `.harness/baseline/v5.12.0/templates/docs/plan/planning/reconciliation.template.md` | *„Vorlage für das Reconciliation-Register eines Repos im **Brownfield-Bootstrap** … Ein reines Greenfield-Repo braucht die Datei nicht"* |
| `.harness/baseline/v5.12.0/templates/docs/plan/planning/welle-results.template.md` | *„Kopiere nach `docs/plan/planning/done/welle-<NN>-results.md`"* — **eine je Welle** |
| `.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md` | *„Vorlage für **einen** Adaptions-Eintrag … Ein Eintrag je Datei"* — **eine je Adaption** |

### Das Tool emittiert die vier bereits als gestempelte Singletons — und zwei davon sind kaputt

`emit.inScope` ist bewusst **Regel statt Allowlist**: *„ein upstream neu hinzugekommenes Template
fliesst damit automatisch mit"*. Das trägt die **Vollständigkeit** und beantwortet die
Klassen-Frage nicht — `isRecurring` und `isDerivativeIndex` zählen namentlich auf, alles übrige
wird Singleton. Die Regel wirkt am **realen** Vorlagen-Satz, nicht an `courseSet()`; die vier neuen
`.md`-Ziele stehen deshalb **seit dem Tausch** im Bootstrap-Ergebnis, ohne dass eine Entscheidung
gefallen wäre.

**Zwei Befunde hängen daran, und sie sind gemessen, nicht hochgerechnet.** `make smoke` am Stand
`26aec2c` meldet `23 Datei(en) geprüft, 10 Befund(e)`; über dem Vor-Tausch-Stand
(`T=$(mktemp -d); git archive c6cc56f | tar -x -C "$T"; cd "$T" && make smoke`) sind es
`19 Datei(en) geprüft, 0 Befund(e)` bei Exit 0. Beide Zahlen wandern mit dem Vorlagen-Satz und sind
**keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **Der Anlauf-Stand ist nicht der Schnitt-Stand:** dasselbe Kommando liefert am Stand
`66459c7` `23 Datei(en) geprüft, 2 Befund(e)` — gleicher Nenner, also ist nichts aus dem
Prüfbereich gefallen. Von den zehn gehören heute **zwei** hierher, und die dritte Zeile der Tabelle
unten ist mit
[slice-133](../in-progress/slice-133-emittierter-baum-ohne-platzhalter-links.md) gefallen:

`<ziel>/` meint das **gebootstrappte Zielrepo**, nicht dieses — die Ebenen-Trennung aus dem
Abschnitt unten, schon in der Tabelle:

| Emittierte Datei · Ziel | Vorlage |
|---|---|
| `<ziel>/docs/plan/planning/welle-results.md:67` → `](observations.template.md)` | `welle-results.template.md` |
| `<ziel>/docs/plan/planning/welle-results.md:83` → `](../observations.md)` | `welle-results.template.md` |
| ~~`<ziel>/harness/conventions/MR-NNN-titel.md:15` → `](…/baseline/<tag>/regelwerk/grundlagen-referenz-richtung.md#…)`~~ — **gefallen** mit [slice-133](../in-progress/slice-133-emittierter-baum-ohne-platzhalter-links.md): sein Ziel-Pfad trug `<tag>`, und die dortige Neutralisierung kennt die **Form** und keine Namen | `MR-NNN-titel.template.md` |

Am vorgesehenen Ort `planning/done/` löst `](../observations.md)` auf; als flaches
`planning/welle-results.md` zeigt er auf eine `observations.md` neben `docs/plan/`, die es nicht
gibt. Der `<tag>`-Platzhalter im Baseline-Pfad des Adaptions-Eintrags stand daneben und ist fort;
**die Klassen-Frage von `MR-NNN-titel.template.md` ist davon unberührt** — die Vorlage wird
weiterhin als Singleton emittiert, und die Weichen `inScope`/`isRecurring`/`isDerivativeIndex` sind
über die ganze slice-133-Kette unangetastet
(`git diff 3ea5ae2^ 66459c7 -- internal/emit/templates.go | grep -cE '^[+-][^+-].*func (inScope|isRecurring|isDerivativeIndex)'`
→ **0**). Was dieser Slice dadurch verliert, ist ein Befund, kein Entscheidungs-Gegenstand. Das **emittierte**
Doku-Gate liest beides: `internal/emit/templates/d-check.yml` führt `modules: [links, anchors]` und
nimmt per `scan.ignore` nur `**/*.template.md`, `.tmp/**` und `.harness/**` aus — die
transformierten `.md`-Ziele stehen im Prüfbereich.

**Die Zusage aus
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), der
emittierte Stand sei *„out-of-the-box gate-sicher"*, ist damit gebrochen** — dieselbe Klasse, die
der Voll-Smoke von slice-024 an den derivativen Indexen gefunden hat. Sie wird **repariert, nicht
ausgenommen**: eine Rang-1-Zusage wird von keinem Carveout suspendiert, und der Trichter aus
Baseline-Regelwerk `modul-07-carveouts.md` §Werkzeug-Wahl führt bei dieser Häufung ohnehin nicht
auf Carveout (Begründung in
[slice-133](../in-progress/slice-133-emittierter-baum-ohne-platzhalter-links.md) §1).

**Diese zwei lösen sich mit der Klassen-Entscheidung, nicht durch Link-Arbeit.** Fällt
`welle-results.template.md` auf *wiederkehrend*, wird sie als `.template.md` emittiert und fällt
unter `scan.ignore` des emittierten Gates — beide Befunde verschwinden, ohne dass ein Link
angefasst wurde. Genau deshalb liegen sie hier und nicht in slice-133.

### Die anderen acht gehören nicht hierher

**7** der zehn Befunde stammen aus **drei Vorlagen, die schon vor dem Tausch im
Satz lagen und schon vor dem Tausch als Singletons emittiert wurden** — `roadmap.template.md`,
`…/harness/README.template.md`, `…/harness/conventions.template.md`. Ihre Rümpfe tragen neuerdings
**Platzhalter-Links** (`](<pfad>)`, `](../<welle-NN-titel>.md)`,
`](conventions/MR-<NNN>-<titel>.md)`); keine Klassen-Entscheidung bewegt sie, weil
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) alle drei
namentlich als Singletons führt. **Weggenommen hat
[slice-133](../in-progress/slice-133-emittierter-baum-ohne-platzhalter-links.md) acht** — die
sieben plus den einen der Tabelle oben, dessen Ziel-Pfad dieselbe Form trug; seine
Neutralisierung kennt die Form und keine Namen, und darum reicht ihre Wirkung über die
Ursachen-Einteilung hinaus. Ein Lauf hier, der eine dieser Fundstellen mitnimmt, hat den Schnitt
verlassen, nicht ihn erfüllt.

### Die Ebene ist die Pointe

Was in **diesem** Repo gilt, ist keine Aussage über das emittierte. Der Baum-Tausch hat den
Emissions-Kanal mitverschoben (`internal/fetch/baseline.go` `DefaultTag`); die **Klasse** jeder
Vorlage ist davon unberührt und wird hier entschieden. Ob dieses Repo selbst ein Beobachtungs-
oder Reconciliation-Register führt, ist eine Dogfood-Frage mit eigenem Eigentümer und steht
**nicht** in diesem Slice.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Jede der vier Vorlagen trägt eine Klasse, und die Begründung steht am Code.**
      `emit.isRecurring` / `emit.isDerivativeIndex` / `emit.inScope` sind so gefasst, dass die
      Entscheidung je Vorlage am Kommentar der Weiche ablesbar ist, nicht nur in diesem Plan
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Der Ausgang ist hier **nicht** vorgegeben — er
      wird je Vorlage aus ihrer eigenen Aussage über ihre Vervielfältigung (§1, Tabelle)
      abgeleitet und im Kommentar mit ihr belegt.
- [ ] **(2) Jede der vier Entscheidungen ist rot gesehen, und der emittierte Bestand ist
      vollständig geprüft.** `TestTemplates_EmittierterBestandVollstaendig` hält den **Ist-Bestand**
      gegen die Erwartung (kein Abwesenheits-Stichprobenspiel auf geratene Namen); je Entscheidung
      ist benannt und einmal gefahren, welche Mutation sie rot färbt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). `test/courseset-fixture.bats` ist grün, und
      seine Zahl ist die des realen Satzes.
- [ ] **(3) Die Gate-Sicherheit des Bootstrap-Ergebnisses ist gemessen, nicht behauptet.**
      `make smoke` **und** `make full-smoke` sind grün; der zweite ist der einzige Lauf, der ein
      emittiertes Repo gegen sein eigenes Doku-Gate hält. Beide ziehen das Asset aus dem Netz und
      stehen darum außerhalb von `make gates` — sie gehören an den DoD-Verify. **Dieser Punkt trägt
      den gemeinsamen Nachweis für beide Ursachen** und ist damit der Ort, an dem
      [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
      [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) wieder
      eingelöst sind; er setzt [slice-133](../in-progress/slice-133-emittierter-baum-ohne-platzhalter-links.md)
      voraus (§4). Bleibt er rot, ist **vor** dem Nachziehen einer Erwartung zu prüfen, welche der
      beiden Ursachen die Befunde trägt — ein Grün durch Anpassen einer Zahl ist keines.
- [ ] `make gates` grün — **ohne** die Ausnahme aus
      [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md); der Carveout ist damit
      aufgelöst und seine Datei per `git mv` in `carveouts/done/`, die Index-Zeile umgehängt.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (die `observations.md` neben den Wellen): das Repo führt **keines** — ob es entsteht,
      hängt an derselben Dogfood-Frage, die dieser Slice ausdrücklich nicht entscheidet (§3). Das
      Item entfällt hier nicht still, sondern mit diesem Grund; er wird in §7 notiert. Dasselbe
      gilt für das Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der [welle-10](../welle-10-re-baseline.md)-Closure
      geprüft, nicht hier.

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | `isRecurring` / `isDerivativeIndex` tragen die namentlichen Aufzählungen; hier fällt je Zugang die Entscheidung und wird am Kommentar belegt |
| `internal/emit/templates_test.go` | update | `courseSet()` spiegelt den realen Satz; `TestTemplates_EmittierterBestandVollstaendig` trägt den vollständigen Soll-Bestand |
| `test/courseset-fixture.bats` | update | der Wächter, der die Frage gestellt hat: Fixture-Abgleich und in-scope-Zahl |
| `test/mutations/` | ggf. neu | je Entscheidung ein rot färbender Fall, soweit die vorhandenen ihn nicht schon tragen ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md) | **auflösen** (`git mv` nach `done/`) | die Ausnahme fällt mit der Entscheidung; Auflösen ohne Verschiebung wäre die zweite Lüge (Modul 7) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Rang 1 der Source Precedence. Berührt eine Entscheidung die Aufzählung in [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), verlässt sie den Slice als Übergabe (§6), statt hier geschrieben zu werden |
| `internal/emit/templates/commands/`, `.harness/skills/` | **unverändert** | der **Text** der emittierten Artefakte ist Gegenstand von [slice-085](slice-085-emittierte-ebene-zieht-nach.md); hier geht es um die **Menge** |
| eine `observations.md` unter `docs/plan/planning/`, `…/reconciliation.md` | **unverändert** | ob **dieses** Repo die Register führt, ist eine Dogfood-Frage mit eigenem Eigentümer |

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) **und**
[slice-133](../in-progress/slice-133-emittierter-baum-ohne-platzhalter-links.md) liegen in `done/`. Der erste
stellt den Satz fest, über den entschieden wird; der zweite räumt die **acht** Befunde weg, die
nicht an der Klassen-Frage hängen — ohne ihn ist DoD (3) unerfüllbar, weil `make smoke` dann auch
bei vier richtig entschiedenen Vorlagen rot bliebe. Sein Beitrag ist gefahren und gemessen —
`make smoke` am Stand `66459c7` meldet `23 Datei(en) geprüft, 2 Befund(e)`, und beide Befunde
stehen in `<ziel>/docs/plan/planning/welle-results.md`; DoD (3) ist damit erreichbar geworden. Die
Trigger-Bedingung selbst bleibt die **Verzeichnis-Position**, nicht diese Messung. Ein Kriterium, das unter keiner korrekten
Ausführung dieses Slice grün werden kann, ist keine Abnahme, sondern eine Falle
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Gate-Sicherheits-Nachweis aus
  DoD (3) einen Fehler im Bootstrap-Pfad **selbst** zeigt, der über die vier Klassen hinausgeht —
  dann trennt der Schnitt Klassifikation und Nachweis.
- `in-progress` → `open` (blockiert — Carveout?): wenn eine der vier Entscheidungen die
  Aufzählung in [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  ändern müsste. Das Lastenheft ist Rang 1 und wird nicht im Implementations-Kontext
  fortgeschrieben; die Frage geht dann hinaus, und
  [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md) bleibt bis zur Antwort
  bestehen — mit nachgetragener *Letzte Prüfung*, nicht stillschweigend.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **`make gates` grün ohne die `CO-004`-Ausnahme**, und **`make smoke`
wie `make full-smoke` grün**. Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko
aus §6 genau ein Ausgang. Der Carveout liegt danach in `carveouts/done/` — die Auflösung ist der
`git mv`, nicht die Statuszeile.

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) zählt
  die wiederkehrenden Vorlagen namentlich auf** (*„ADR · slice · welle · carveout ·
  review-report"*). Fällt eine der vier Entscheidungen auf *wiederkehrend*, ist diese Aufzählung
  unvollständig — und die Lücke sieht kein Gate, weil `docs-check` Kennungen und Links prüft, nicht
  die Vollständigkeit einer Aufzählung. — **Ausgang:** <eingetreten: Übergabe an die schreibende
  Rolle des Lastenhefts, Slice-ID nachtragen | entfallen: keine Entscheidung fällt auf
  *wiederkehrend*, je Vorlage belegt>
- **Eine „unklassifiziert, nicht emittiert"-Liste wäre der Rückfall.** `emit.inScope` ist
  ausdrücklich Regel statt Allowlist, um die Klasse *„Baseline gebumpt, Emit nicht nachgezogen"*
  strukturell abzuschaffen; eine Warteliste brächte sie zurück. — **Ausgang:** <entfallen: der
  Slice entscheidet je Vorlage, statt eine Liste zu führen | eingetreten: CO-NNN mit
  Auflösungs-Trigger>
- **`reconciliation.template.md` ist nach eigener Aussage nur für Brownfield-Bootstraps.** Ein
  Bootstrap kennt den Modus des Zielrepos nicht; jede Klasse für diese Vorlage ist deshalb für
  einen Teil der Adopter falsch. — **Ausgang:** <eingetreten: benannte Entscheidung mit Begründung
  am Code, nach dem Fehlerbild aus
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  — laut falsch schlägt leise falsch | weiter offen: → Beobachtung, sobald das Repo ein Register
  führt>
- **`make full-smoke` läuft nicht offline.** Der einzige Nachweis für DoD (3) hängt am Netz und
  damit an einer Bedingung außerhalb des Repos. — **Ausgang:** <entfallen: der Lauf gelingt und ist
  protokolliert | eingetreten: CO-NNN, solange der Nachweis nicht führbar ist>

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `internal/emit/` (eigener
Zuschnitt, eigene Tests, eigene Ziel-Form — drei von drei Achsen) und `test/` (eigener
Zuschnitt, eigene Werkzeugkette — zwei von drei). Beide erfüllen die Schwelle ≥ 2; keine
ist zu grob geschnitten.

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein**
Beobachtungs-Register — eine `observations.md` unter `docs/plan/planning/` existiert nicht, und ob es
entsteht, hängt an derselben Dogfood-Frage, die dieser Slice ausdrücklich nicht
entscheidet (§3). Keine Treffer, und der Grund ist die fehlende Datei, nicht ein leeres
Register.

Alle berührten Sub-Areas GF: `internal/emit/` und `test/` gehören zum
Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md). Der
Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz oben.

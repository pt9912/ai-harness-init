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

**Verantwortlich:** Implementer (pt9912).

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
git ls-tree -r --name-only c6cc56f -- .harness/baseline | sed 's|.*/templates/||' \
  | grep '\.template\.md$' | grep -v '^project-readme\.template\.md$' | wc -l    # -> 17
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
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) gefallen:

`<ziel>/` meint das **gebootstrappte Zielrepo**, nicht dieses — die Ebenen-Trennung aus dem
Abschnitt unten, schon in der Tabelle:

| Emittierte Datei · Ziel | Vorlage |
|---|---|
| `<ziel>/docs/plan/planning/welle-results.md:67` → `](observations.template.md)` | `welle-results.template.md` |
| `<ziel>/docs/plan/planning/welle-results.md:83` → `](../observations.md)` | `welle-results.template.md` |
| ~~`<ziel>/harness/conventions/MR-NNN-titel.md:15` → `](…/baseline/<tag>/regelwerk/grundlagen-referenz-richtung.md#…)`~~ — **gefallen** mit [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md): sein Ziel-Pfad trug `<tag>`, und die dortige Neutralisierung kennt die **Form** und keine Namen | `MR-NNN-titel.template.md` |

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
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §1).

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
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) acht** — die
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

- [x] **(1) Jede der vier Vorlagen trägt eine Klasse, und die Begründung steht am Code.**
      `emit.isRecurring` / `emit.isDerivativeIndex` / `emit.inScope` sind so gefasst, dass die
      Entscheidung je Vorlage am Kommentar der Weiche ablesbar ist, nicht nur in diesem Plan
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Der Ausgang ist hier **nicht** vorgegeben — er
      wird je Vorlage aus ihrer eigenen Aussage über ihre Vervielfältigung (§1, Tabelle)
      abgeleitet und im Kommentar mit ihr belegt.
- [x] **(2) Jede der vier Entscheidungen ist rot gesehen, und der emittierte Bestand ist
      vollständig geprüft.** `TestTemplates_EmittierterBestandVollstaendig` hält den **Ist-Bestand**
      gegen die Erwartung (kein Abwesenheits-Stichprobenspiel auf geratene Namen); je Entscheidung
      ist benannt und einmal gefahren, welche Mutation sie rot färbt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). `test/courseset-fixture.bats` ist grün, und
      seine Zahl ist die des realen Satzes.
- [x] **(3) Die Gate-Sicherheit des Bootstrap-Ergebnisses ist gemessen, nicht behauptet.**
      `make smoke` **und** `make full-smoke` sind grün; der zweite ist der einzige Lauf, der ein
      emittiertes Repo gegen sein eigenes Doku-Gate hält. Beide ziehen das Asset aus dem Netz und
      stehen darum außerhalb von `make gates` — sie gehören an den DoD-Verify. **Dieser Punkt trägt
      den gemeinsamen Nachweis für beide Ursachen** und ist damit der Ort, an dem
      [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
      [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) wieder
      eingelöst sind; er setzt [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)
      voraus (§4). Bleibt er rot, ist **vor** dem Nachziehen einer Erwartung zu prüfen, welche der
      beiden Ursachen die Befunde trägt — ein Grün durch Anpassen einer Zahl ist keines.
- [x] `make gates` grün — **ohne** die Ausnahme aus
      [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md); der Carveout ist damit
      aufgelöst und seine Datei per `git mv` in `carveouts/done/`, die Index-Zeile umgehängt.
      **Der Haken ruht auf der Ausnahme-Hälfte, nicht auf dem Wort *grün*:** `make -k gates` ist
      rot, an genau einem Ziel, und dessen Ursache ist
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) — ein fremder,
      dokumentierter Carveout mit eigenem Träger
      ([slice-132](../open/slice-132-adaptions-block-ohne-totes-ziel.md)), den dieser Slice nicht
      auflösen kann. Warum der Satzanfang unter keiner korrekten Ausführung dieses Slice erreichbar
      war und worauf der Haken stattdessen gesetzt ist, steht in §7 (*Der Haken zu (4)*).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (die `observations.md` neben den Wellen): das Repo führt **keines** — ob es entsteht,
      hängt an derselben Dogfood-Frage, die dieser Slice ausdrücklich nicht entscheidet (§3). Das
      Item entfällt hier nicht still, sondern mit diesem Grund; er wird in §7 notiert. Dasselbe
      gilt für das Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
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
| [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) | **auflösen** (`git mv` nach `done/`) | die Ausnahme fällt mit der Entscheidung; Auflösen ohne Verschiebung wäre die zweite Lüge (Modul 7) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Rang 1 der Source Precedence. Berührt eine Entscheidung die Aufzählung in [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), verlässt sie den Slice als Übergabe (§6), statt hier geschrieben zu werden |
| `internal/emit/templates/commands/`, `.harness/skills/` | **unverändert** | der **Text** der emittierten Artefakte ist Gegenstand von [slice-085](../open/slice-085-emittierte-ebene-zieht-nach.md); hier geht es um die **Menge** |
| eine `observations.md` unter `docs/plan/planning/`, `…/reconciliation.md` | **unverändert** | ob **dieses** Repo die Register führt, ist eine Dogfood-Frage mit eigenem Eigentümer |

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) **und**
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) liegen in `done/`. Der erste
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
  [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) bleibt bis zur Antwort
  bestehen — mit nachgetragener *Letzte Prüfung*, nicht stillschweigend.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **`make gates` grün ohne die `CO-004`-Ausnahme**, und **`make smoke`
wie `make full-smoke` grün**. Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko
aus §6 genau ein Ausgang. Der Carveout liegt danach in `carveouts/done/` — die Auflösung ist der
`git mv`, nicht die Statuszeile.

**Erfüllt ist das erste Kriterium in seiner Ausnahme-Hälfte, nicht in seinem Satzanfang** — es
teilt die Grenze von DoD (4) oben, und der Grund steht an einem Ort: §7 (*Der Haken zu (4)*).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) zählt
  die wiederkehrenden Vorlagen namentlich auf** (*„ADR · slice · welle · carveout ·
  review-report"*). Fällt eine der vier Entscheidungen auf *wiederkehrend*, ist diese Aufzählung
  unvollständig — und die Lücke sieht kein Gate, weil `docs-check` Kennungen und Links prüft, nicht
  die Vollständigkeit einer Aufzählung. — **Ausgang: eingetreten.** Zwei der vier Entscheidungen
  fielen auf *wiederkehrend*; `emit.isRecurring` führt heute **sieben** Namen
  (`awk '/^func isRecurring\(/{f=1} f&&/^}/{f=0} f' internal/emit/templates.go | grep -oE '"[^"]+\.template\.md"' | wc -l`
  → **7**; `grep -c` zählte hier Zeilen und gäbe **3**), die Aufzählung fünf. Die Übergabe an die schreibende Rolle des Lastenhefts trägt
  [slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md) — als Change Request,
  weil weder ADR noch Slice `LH-*` ändern dürfen
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  Derselbe Slice führt [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md), die dieselbe
  Menge nennt und ab `Accepted` immutabel ist.
- **Eine „unklassifiziert, nicht emittiert"-Liste wäre der Rückfall.** `emit.inScope` ist
  ausdrücklich Regel statt Allowlist, um die Klasse *„Baseline gebumpt, Emit nicht nachgezogen"*
  strukturell abzuschaffen; eine Warteliste brächte sie zurück. — **Ausgang: entfallen.** Je
  Vorlage ist entschieden, keine Warteliste entstanden, und `emit.inScope` ist über die ganze
  Kette unangetastet
  (`git diff 7e6eb0b^..3f12358 -- internal/emit/templates.go | grep -cE '^[+-][^+-].*func inScope'`
  → **0**). Die Prüfung, ob eine Klasse getroffen ist, liegt beim Vollständigkeits-Test über den
  **ganzen** emittierten Baum, nicht bei einer Namensliste daneben.
- **`reconciliation.template.md` ist nach eigener Aussage nur für Brownfield-Bootstraps.** Ein
  Bootstrap kennt den Modus des Zielrepos nicht; jede Klasse für diese Vorlage ist deshalb für
  einen Teil der Adopter falsch. — **Ausgang: eingetreten.** Die Entscheidung heißt
  `emit.isBrownfieldOnly`, die Vorlage wird **gar nicht** emittiert, und die Begründung steht am
  Kommentar der Weiche (`grep -n '^func isBrownfieldOnly(' internal/emit/templates.go` → Zeile
  **120**): die Baseline-Prozedur legt das Register im Rückbau an, also nach dem Vendoren, und die
  mitemittierte `docs/plan/planning/README.md` spricht dem Greenfield-Repo die Datei ab. Rot
  gefärbt wird sie von `test/mutations/217-reconciliation-als-singleton.sh`.
- **`make full-smoke` läuft nicht offline.** Der einzige Nachweis für DoD (3) hängt am Netz und
  damit an einer Bedingung außerhalb des Repos. — **Ausgang: entfallen.** Der Lauf gelingt und ist
  protokolliert: Exit **0**, **16** Zeilen `full-smoke: OK`, **0** `FEHLER` (Kommandos unter DoD (3)
  in §7).

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-30.
**Gegenstand:** `HEAD` = `3f12358` (`git rev-parse --short HEAD`); der Arbeitsbaum war vor dieser
Closure sauber (`git status --porcelain | wc -l` → **0**) und trägt danach genau eine geänderte
Datei — diese. **Die Gate-Läufe unten sind über dem Baum dieser Closure gefahren**, nicht über dem
sauberen davor: `docs-check` meldet vorher wie nachher `468 Datei(en) geprüft, 1 Befund(e)`.
`make smoke` und `make full-smoke` liefen davor; ihr Gegenstand ist der Emit, und der liest keine
Datei unter `docs/plan/planning/`. Die Kette (`git log --oneline 7e6eb0b~2..HEAD`): `856eb20`
(Link-Abgleich nach dem Lifecycle-Move) · `7e6eb0b` (Implementer) · `a880c84`
(`git mv` `CO-004` → `done/`, reiner Move) ·
`5cf8245` (Link-Abgleich) · `4d02b6e` (Review 1, NICHT KONFORM, 2 HIGH) · `add5f43` (Architect,
§3.7-Quellen-Klausel) · `722e272` (Fix 1) · `a6d436c` (Architect,
[`ADR-0025`](../../adr/0025-register-mit-gemischten-originalen.md) + `isBrownfieldOnly` ist keine
Abweichung) · `92d9c50` (Review 2, NICHT KONFORM, 4 MEDIUM über zwei Rollen) · `7ce375a`
(Planner-Fix) · `4da4f64` (Implementer-Fix) · `3f12358` (Verifikation, DoD-konform).

Jede Zahl unten ist **in diesem Lauf** erhoben; Umsetzung, Reviews und Verifikation waren
**Eingabe, kein Beleg**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Wo ich eine Messung **nicht** wiederholt habe, steht es dabei.

### DoD-Stand — die drei slice-eigenen Punkte

**(1) Jede der vier Vorlagen trägt eine Klasse, die Begründung steht am Code — ERFÜLLT.** Die vier
Ausgänge und der Ort ihrer Begründung, beides am Code nachgelesen
(`grep -nE '^func (isRecurring|isDerivativeIndex|isBrownfieldOnly|inScope)\(' internal/emit/templates.go`
→ Zeilen **47**, **65**, **120**, **215**):

| Vorlage (vendored Pfad) | Klasse | Weiche |
|---|---|---|
| `.harness/baseline/v5.12.0/templates/docs/plan/planning/welle-results.template.md` | wiederkehrend | `isRecurring` |
| `.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md` | wiederkehrend | `isRecurring` |
| `.harness/baseline/v5.12.0/templates/docs/plan/planning/reconciliation.template.md` | gar nicht emittiert | `isBrownfieldOnly` (neu) |
| `.harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md` | Singleton | keine Weiche — die Voreinstellung, als solche kommentiert |

Der Plan gibt den Ausgang nicht vor, sondern verlangt die Ableitung je Vorlage aus ihrer eigenen
Aussage. Die ersten drei Zeilen folgen je aus dem Template-Hinweis der Vorlage; die vierte ist die
schwierige, weil eine
**Nicht**-Eintragung nichts sagt. Sie ist trotzdem gedeckt: `planTemplates` trägt den
Voreinstellungs-Kommentar, und rot gefärbt wird sie in der **Gegenrichtung**
(`test/mutations/218-beobachtungsregister-nicht-emittiert.sh` trägt `observations` **in**
`isRecurring` ein) — der einzige Bau, der eine Voreinstellung überhaupt bewachen kann.

**Die einzige Entscheidung, die gegen eine ausdrückliche Aussage der adoptierten Baseline steht,
trägt ihre Abgrenzung am Ort.** Der Set-Index des vendored Satzes führt `reconciliation` unter den
Singletons; der Kommentar an `isBrownfieldOnly` nennt ihn, benennt die Achsen-Differenz (die zwei
Eimer beantworten, **wie** sich eine Vorlage vervielfältigt, nicht **ob** ein gegebenes Repo das
Ziel hat) und zeigt für die Abweichungs-Frage auf den Adaptions-Block statt sie selbst zu
beantworten. Nachgemessen: der Satz führt **22** Vorlagen
(`find .harness/baseline/v5.12.0/templates -type f -name '*.template.md' | wc -l` → **22**), die
zwei Eimer des Set-Index **15** (`sed -n '77,87p' .harness/baseline/v5.12.0/templates/README.md`,
10 + 5) — **7** stehen in keinem, die Liste ist also keine geschlossene Taxonomie. Und im
Adaptions-Block steht zu dieser Weiche nichts
(`grep -c 'isBrownfieldOnly\|reconciliation.template.md' harness/conventions.md` → **0**), wo
keiner steht, gilt die Baseline unverändert
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)).

**(2) Vier Entscheidungen rot gesehen, Ist-Bestand vollständig geprüft — ERFÜLLT.** Der
Vollständigkeits-Test vergleicht den **ganzen** emittierten Baum gegen eine Liste, nicht gegen eine
Zahl (`grep -n 'observations.md' internal/emit/templates_test.go` → Zeile **267**, in `want`); die
sechs Fälle dieser Kette liegen ausführbar im Treiber-Format vor
(`git ls-files -s test/mutations/21[5-9]*.sh test/mutations/220*.sh` → je `100755`, **6** Zeilen)
bei **213** Fällen insgesamt (`git ls-files test/mutations/*.sh | wc -l`). Unmutiert grün ist der
Bestand in meinem eigenen Gate-Lauf: `test-bats` meldet `1..196` mit
`grep -cE '^not ok' <log>` → **0**, darunter `ok 40`–`ok 44`, die fünf Fixture-Achsen.

**Was ich nicht wiederholt habe, und warum es dasteht:** den `make mutate`-Lauf. Er ist über
demselben Baum-Inhalt gefahren und protokolliert (`213 ok, 0 Befund(e)`, mit der
Vollständigkeits-Schranke des Treibers); mein Zug ändert keine Zeile Code
(`git diff --name-only HEAD -- internal/ test/ | wc -l` → **0**). Für das **Rot** der sechs Fälle
ist damit das Protokoll der Verifikation Eingabe, für das **Grün** ihrer Sensoren mein eigener
Gate-Lauf. Die Präzedenz für diese Teilung ist
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7.

**(3) Die Gate-Sicherheit des Bootstrap-Ergebnisses ist gemessen — ERFÜLLT, beide Läufe selbst
gefahren.**

- `make smoke` → Exit **0**, `d-check: 20 Datei(en) geprüft, 0 Befund(e)`.
- `make full-smoke` → Exit **0**, `grep -c '^full-smoke: OK' <log>` → **16**,
  `grep -c 'FEHLER' <log>` → **0**; darin **7** Läufe des emittierten `docs-check`, jeder mit
  `20 Datei(en) geprüft, 0 Befund(e)`.

**Die Falle, vor der der Punkt selbst warnt, ist ausgeschlossen — und nicht von mir**, sondern auf
einer Achse, die dieser Lauf nicht noch einmal herstellen musste: die Verifikation hat denselben
Bootstrap über dem Vor-Stand `856eb20` gefahren und die Prüfbereiche als **Mengendifferenz**
gehalten. Drei Dateien verlassen ihn, und es sind genau die drei nicht mehr emittierten; beide
Befunde des Vor-Stands lagen in **einer** davon; die verbleibenden 20 waren vorher wie nachher
befundfrei. Das ist der Beleg, den DoD (3) verlangt — *„ein Grün durch Anpassen einer Zahl ist
keines"* —, und er ist eine Mengenaussage, keine Plausibilität. Ich habe ihn **nicht** wiederholt;
was ich stattdessen geprüft habe, ist die Eigenschaft, die ihn tragfähig macht: `harness/tools/smoke.sh`
führt keinen Erwartungswert für die Dateizahl
(`grep -cE '\b(19|20|23)\b' harness/tools/smoke.sh` → **0**), die `20` ist Ausgabe und nicht Vorgabe.

**Damit ist [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) eingelöst** —
`make -j gates` im emittierten Repo ist Exit 0, in beiden Bootstrap-Varianten —, und
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) **in seiner
tragenden Zusage**: *out-of-the-box gate-sicher*, zum ersten Mal seit dem Baum-Tausch wieder
gemessen. Seine **Aufzählung** läuft dem Code nach; das ist ein Rang-1-Textrückstand mit eigenem
Träger (§6, Risiko 1) und kein Mangel dieses Slice.

#### Der Haken zu (4)

**Das vierte DoD-Kriterium ist, wie es dasteht, unter keiner korrekten Ausführung dieses Slice
erreichbar, und der Haken behauptet es nicht.** Gemessen: `make -k gates` (keep-going; ohne `-k`
verdeckt der erste Abbruch die übrigen zehn Ziele), Exit **2**, und genau **ein** rotes Ziel
(`grep -cE '^make(\[[0-9]+\])?: \*\*\*' <log>` → **1**, nämlich
`make: *** [d-check.mk:66: docs-check] Fehler 1`). Der eine Befund ist
`harness/conventions.md:1019 → ../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#rollen-sequenz-für-einen-slice · target-missing`
bei `d-check: 468 Datei(en) geprüft, 1 Befund(e)` — Zeichen für Zeichen der Geltungsbereich von
[`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md), dessen Träger
[slice-132](../open/slice-132-adaptions-block-ohne-totes-ziel.md) in `open/` liegt. Ein Slice, der
diesen Befund mitnähme, hätte den Schnitt verlassen.

**Worauf der Haken stattdessen ruht** — die Ausnahme-Hälfte des Satzes, und die ist ganz erfüllt:
`CO-004` ist aufgelöst, seine zwei Fälle sind grün (`ok 40`, `ok 41` in meinem Lauf) und **ohne**
jede Konfigurations-Ausnahme (`git grep -c 'CO-004' -- test/ .d-check.yml Makefile` → kein Treffer,
Exit **1**); der Vollzug liegt formgerecht in zwei Commits (`a880c84` reiner Move, `5cf8245`
Link-Abgleich, [`AGENTS.md`](../../../../AGENTS.md) §3.3), und die Index-Zeile steht in
`docs/plan/carveouts/README.md` unter `## Aufgelöst`. Grün und selbst gesehen sind die übrigen zehn
Ziele: `baseline-verify: v5.12.0 OK — 51 Dateien`, `lint`, `build`, `test-bats`, `test-go`,
`shell-lint`, `ci-lint`, `comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`, `host-bin`,
`span-check`.

**Die Deckung dafür steht in Modul 5, nicht in einer Auslegung dieses Satzes:** *„Ein Slice darf bei
rotem Gate nur mit dokumentiertem Carveout (Modul 7) in `done/` landen, der den roten Gate-Status
auf Trigger schaltet."* Genau das liegt vor. Der **Schnitt-Fehler** bleibt trotzdem einer und wird
nicht weggedeutet: `CO-005` bestand bereits am Autoren-Datum dieses Plans, und die tragfähige
Formulierung stand eine Datei weiter —
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §2 schreibt
*„`make gates` grün, soweit die Welle es zulässt"* und nennt **beide** Carveouts. Ein Kriterium, das
den Gesamt-Gate-Zustand einfordert, macht jeden Slice von jedem fremden roten Ziel abhängig — dieselbe
Falle, die §4 dieses Plans für den **Start**-Trigger ausdrücklich benennt. Die Konsequenz gehört
in die Ziel-Form des Slice-Plans und damit zum Planner; ihr Ort ist der zweite Steering-Loop-Eintrag
unten, nicht ein nachträglich umgeschriebener DoD-Text.

### Die fünf Standard-Punkte

Die DoD führt **9** Haken (`grep -c '^- \[x\]' <diese Datei>`): drei Liefer-Punkte oben, der
Gate-Punkt in *Der Haken zu (4)*, die restlichen fünf hier.

**Doku-Update — ERFÜLLT, kein Trigger.** Berührt ist genau ein öffentlicher Vertrag,
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), und er ist
korrekt **nicht** angefasst worden: `git diff --name-only 7e6eb0b^..HEAD -- spec/ | wc -l` → **0**.
Der Weg hinaus ist ein Change Request
([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)),
sein Träger [slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md). Der gesamte
Code-Eingriff bleibt in zwei Dateien
(`git diff --name-only 7e6eb0b^..HEAD -- internal/` → `internal/emit/templates.go`,
`internal/emit/templates_test.go`).

**Closure-Notiz mit Steering-Loop-Lerneintrag — ERFÜLLT**, unten: zwei Einträge und eine gezählte
Klasse.

**Beobachtungs-Register — es existiert nicht, und die DoD verlangt genau das hier zu notieren.**
`ls docs/plan/planning/observations.md` → `Datei oder Verzeichnis nicht gefunden`. Das ist keine
Auslassung, sondern die Folge einer Dogfood-Entscheidung, die dieser Slice ausdrücklich nicht
trifft (§1, §3); ihr Träger ist
[slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md). **Die Folge ist nicht
bloß buchhalterisch:** beide Lerneinträge unten und die gezählte Klasse gehörten dorthin, und die
Klasse hat mit diesem Slice ihre fünfte Review-Runde erreicht, ohne dass ein Zähler sie hält. Sie stehen
deshalb hier, wo ein späterer Lauf sie nur findet, wenn er diesen Slice liest. **Ohne Register gibt
es auch keinen dritten Ausgang** — Modul 5 nennt *weiter offen → wandert ins Beobachtungs-Register*;
für die vier Risiken aus §6 war er nicht nötig, denn keines endet dort.

**Reconciliation-Register — entfällt**, dauerhaft und aus einem Grund außerhalb dieses Slice: das
Repo hat keinen Brownfield-Bootstrap (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden).
Die Pointe der Ebenen-Trennung steht daneben: das **Werkzeug** entscheidet mit diesem Slice, dass
es die Vorlage nicht emittiert — über das **eigene** Repo sagt das nichts.

**Jedes Risiko aus §6 trägt einen Ausgang — ERFÜLLT**, vier von vier, je genau einer, jeder mit
seiner Messung in §6 selbst. Bilanz: **zwei eingetreten**, **zwei entfallen**, **keines weiter
offen**.

**Die drei Paarungen — nicht hier fällig.** Dieses Repo fährt Wellen-Betrieb; Anker, Folge-Slice und
Register prüft die [welle-10](../welle-10-re-baseline.md)-Closure. Was sie von hier erbt, steht in
einem Satz: **zwei** Steering-Loop-Einträge ohne `liegt in` (gezählt, nicht verkörpert), **null**
*weiter offen*-Ausgänge in §6, **zwei** neue Folge-Slices in `open/` — und dieselbe Ursache wie bei
[slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md) für alles, was ohne Zähler
bleibt.

### Was funktionierte

**Der gebaute Unterscheider misst den realen Satz, nicht die Fixture — und das ist die Antwort auf
die Frage, die §1 als Anlass führt.** `test/courseset-fixture.bats` hat eine dritte Achse bekommen,
die je Vorlage den Kopiere-Satz ihres Template-Hinweises liest und die abgeleitete Menge gegen den
Rumpf von `emit.isRecurring` hält. Sie steht **in** `make gates` (`ok 43` in meinem Lauf) und hat
zwei Zähne (`test/mutations/219`, `220`). Der Plan hatte sie nicht zugesagt; sie ist mehr als
geplant, nicht anderes.

**Die Ebenen-Trennung hat über die ganze Kette gehalten.** Das Werkzeug entscheidet, was ein
Zielrepo bekommt; ob **dieses** Repo ein Beobachtungs- oder Reconciliation-Register führt, hat
kein Commit dieser Kette beantwortet, und beide Dateien existieren hier nicht. Der emittierte Stand
widerspricht sich dabei nicht selbst: die mitemittierte `docs/plan/planning/README.md` nennt
`reconciliation.md` samt der Bedingung, unter der sie entsteht, und emittiert wird sie nicht.

**Die Rollen-Trennung hat zweimal gegriffen, und beide Male sichtbar.** Review 2 hat seine vier
MEDIUM ausdrücklich nach Rolle sortiert; die zwei Planner-Posten sind in einem eigenen Commit
(`7ce375a`) gelaufen, die zwei Implementer-Posten in einem zweiten (`4da4f64`). Kein
Implementer-Commit dieser Kette fasst ein Norm-Artefakt an — gemessen je Commit:

```
for c in $(git log --format=%h 7e6eb0b^..HEAD); do
  n=$(git show --pretty=format: --name-only "$c" \
        | grep -cE '^(AGENTS\.md|harness/conventions\.md|docs/plan/adr/)')
  [ "$n" -gt 0 ] && echo "$c  $n"
done                              # -> a6d436c 2  /  add5f43 2
```

Zwei Commits, und beide tragen die Rolle in ihrer Message.

### Was ging anders als geplant

**Der vorformulierte Ausgang von §6, Risiko 3 ist nicht übernommen worden, und das ist eine
Entscheidung.** Er verlangte die Begründung *„nach dem Fehlerbild aus
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)"*.
Dessen Geltungsbereich ist wörtlich *„jede vom Tool **emittierte** Gate-Konfiguration, die ein
Adopter danach selbst pflegt"* — die Frage, **ob** eine Vorlage überhaupt emittiert wird, fällt
nicht darunter, und eine Register-Vorlage ist keine Gate-Konfiguration. **Der Kommentar an der
Weiche trägt den Verweis nicht** — die Kennung steht **3**× in der Datei, keinmal in seinem Block:

```
awk '/^\/\/ isBrownfieldOnly/{f=1} f&&/^func /{f=0} f' internal/emit/templates.go \
  | grep -c 'MR-017'                                   # -> 0
grep -n 'MR-017' internal/emit/templates.go | cut -d: -f1 | tr '\n' ' '   # -> 437 506 581
```

Die drei Treffer liegen an anderen Weichen, alle über **emittierte Gate-Konfigurationen** — also
im Geltungsbereich. Ein wörtlich abgeschriebener Ausgang
setzte damit eine Begründung in ein lebendes Artefakt, die der Code nicht hält. Der Ausgang steht
deshalb als *eingetreten* mit der Begründung, die am Ort wirklich steht: Prozedur-Reihenfolge der
Baseline und Selbstwiderspruch des emittierten Stands. **Die Sache, die
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
meint, bleibt richtig** — nicht emittiert ist die laute Richtung —, sie trägt hier nur nicht als
Quelle.

**§4 und §6 decken denselben Auslöser mit unvereinbarer Folge; gewählt ist §6, und die Wahl steht
hier, damit sie nicht als übergangene Kante gelesen wird.** §4 nennt als Rückführung
`in-progress` → `open`: *„wenn eine der vier Entscheidungen die Aufzählung in
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ändern
müsste"*, mit `CO-004` bis zur Antwort bestehend. §6, Risiko 1 nennt für denselben Fall die
Übergabe. Eingetreten ist der Fall (zwei Entscheidungen auf *wiederkehrend*); der Lauf ist §6
gefolgt, hat den Slice in `in-progress` gehalten und `CO-004` aufgelöst. **Das ist der einzige
zulässige Weg**, und zwar aus einem Grund, der die §4-Kante zugleich als tot ausweist: nach
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
darf ein Slice `LH-*` **nie** ändern, weshalb die Bedingung *„ändern müsste"* von keinem Slice je
erfüllbar ist. Eine Rückführung wäre hier keine Disziplin gewesen, sondern eine Blockade ohne
Auflösungsweg — der Change Request braucht einen umsetzenden Slice, und der entsteht in `open/`
([slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md)), nicht durch Zurücklegen
dieses Slice. **§4 bleibt unangetastet:** die Sektion beschreibt die vorab benannte Bedingung, und
die drei Zeitdokumente dieser Kette (`ls docs/reviews/*slice-130* | wc -l` → **3**) haben gegen
genau diesen Text gemessen.

**Zwei Review-Runden, und beide tragenden Befunde lagen neben der Mechanik, nicht in ihr.** Die
Klassen-Entscheidungen selbst hat kein Befund gekippt: der Fix-Commit `722e272` enthält **0**
Nicht-Kommentarzeilen an `internal/emit/templates.go`
(`git show 722e272 -- internal/emit/templates.go | grep -E '^[+-]' | grep -vE '^[+-][+-]' | grep -cvE '^[+-][[:space:]]*(//|$)'`),
und `4da4f64` bewegt an derselben Datei ebenfalls keine Anweisung (dieselbe Kette → **0**). Was zwei
Runden gekostet hat, war eine ungelesene Quelle und eine abgezählte Grenze — beides Text neben dem
Code.

**Der Bestand des `isBrownfieldOnly`-Kommentars ist über die Kette gewachsen statt geschrumpft**
(`awk '/^\/\/ isBrownfieldOnly/{f=1} f&&/^func /{f=0} f' internal/emit/templates.go | wc -l` →
**47** Zeilen). Das ist die Spannung, die Review 2 als INFO führt: DoD (1) verlangt die Begründung
**am Code**, [`AGENTS.md`](../../../../AGENTS.md) §3.7 legt die Abwägung in die ADR. Sie ist keine
DoD-Verletzung — der Code erfüllt die DoD, die zum Schnitt galt —, aber sie ist auch nicht
aufgelöst: [`ADR-0025`](../../adr/0025-register-mit-gemischten-originalen.md) steht auf `Proposed`
und nennt Brownfield nicht. Der Ort für die Auflösung ist ein Architect-Lauf, nicht dieser.

### Steering-Loop-Einträge — zwei, und eine gezählte Klasse

#### (I) Bei einem Extraktor über Prosa wird die Lesart gewählt, deren Fehlermodus **leer** ist — nicht die, deren Fehlermodus **falsch** ist

**Die Klasse:** Ein Wächter, der seinen Vergleichswert aus Fließtext zieht, hat zwei Fehlerformen.
Liefert er bei veränderter Eingabe **etwas Falsches**, ist sein Urteil still grün — der Vergleich
geht auf, weil beide Seiten denselben Fehler tragen oder weil der falsche Wert zufällig
unauffällig ist. Liefert er **nichts**, ist die Leere ein Ereignis, das der Wächter melden kann.
Die zweite Form ist die teurere im Alltag (sie färbt auch bei harmlosen Umformulierungen rot) und
die einzige, die den Fall trägt, für den der Wächter gebaut wurde. **Die Wahl fällt an der
Extraktion, nicht an der Beschreibung** — ein Grenzsatz neben einer stillen Lesart bleibt ein
Grenzsatz neben einer stillen Lesart.

**Der gemessene Anlass.** Der neue Unterscheider las zunächst *den ersten Backtick-Ausdruck hinter
dem Wort „Kopiere"*. Über den heutigen Satz stimmte das für alle **21** in-scope-Vorlagen. Auf
einer Drift-Form, die einen zweiten Inline-Code-Ausdruck vor das Ziel stellt
(``Kopiere per `git mv` nach `…/observations.md` ``), liest diese Lesart `git mv`, findet darin
keinen Platzhalter, hält die Vorlage still für nicht wiederkehrend — und der Vergleich ist grün.
Die geltende Lesart ankert hinter dem Wort *nach* und verlangt die `.md`-Endung
(`sed -n '/^kopiere_ziel() {/,/^}/p' test/courseset-fixture.bats | grep -c 'nach '` → **1**); auf
derselben Drift-Form liefert sie **nichts**, und der Wächter macht daraus die laute
`OHNE-ZIEL:`-Zeile. `test/mutations/220-kopiere-satz-verstellt.sh` fährt genau diese Umformulierung
bei Zeichen für Zeichen gleichem Ziel-Pfad.

**Warum das eine Regel ist und kein Sensor.** Ob der Fehlermodus einer Extraktion *leer* oder
*falsch* ist, hängt an der Eingabe, die es noch nicht gibt; ein Gate müsste die zukünftige
Formulierung kennen. Was die Regel **hat**, ist eine billige und hier vorgemachte Prozedur: die
Drift-Form einmal von Hand bauen, beide Lesarten darüber laufen lassen und die Ausgabe vergleichen
— nicht die Beschreibung.

**Adressat und Grenze.** Der Regeltext gehörte an [`AGENTS.md`](../../../../AGENTS.md) §3.6, neben
*„die Zusage auf das einschränken, was der Code hält"* — dort steht heute, dass eine Zusage ihr
Gegenbeispiel braucht, nicht, dass ein Wächter seinen **Fehlermodus** wählen kann. Damit gehört er
dem **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8); den Termin trägt
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), der genau diese Klasse von
Postens führt. **Dieser Lauf hat ihn dort nicht eingetragen** — das Feld `liegt in` entfällt darum
ersatzlos, der Eintrag ist **gezählt, nicht verkörpert**
(`grundlagen-traceability.md` §Herkunfts-Anker).

#### (II) Ein Abnahme-Kriterium nennt den Zustand, den **dieser** Slice herstellt — nie den Gesamtzustand eines Gate-Laufs

**Die Klasse:** Ein DoD-Punkt *„`make gates` grün"* macht die Abnahme eines Slice von jedem fremden
roten Ziel abhängig, das im Repo offensteht. Der Fehler ist nicht die Strenge, sondern die
**Zurechnung**: das Kriterium prüft eine Eigenschaft des Repos statt einer Eigenschaft der
Lieferung. Es ist genau dann erfüllbar, wenn zufällig kein fremder Carveout offensteht — und genau
dann unerfüllbar, wenn einer offensteht, gleichgültig wie gut der Slice ist. Die tragfähige Form
nennt die Zurechnung: *kein rotes Ziel, das diesem Slice zuzurechnen ist*, plus die namentlich
benannten fremden Carveouts.

**Der gemessene Anlass.** DoD (4) und §5 dieses Plans verlangen *„`make gates` grün — ohne die
Ausnahme aus `CO-004`"*. `CO-005` bestand zu diesem Zeitpunkt bereits
(`git log --format='%h %ad' --date=short --diff-filter=A -1 -- docs/plan/carveouts/CO-005-adaptions-block-datierter-beleg.md`
→ `26aec2c 2026-08-28`, dasselbe Datum wie das Autoren-Feld dieses Plans) und wird von
[slice-132](../open/slice-132-adaptions-block-ohne-totes-ziel.md) getragen, nicht von hier. Die
beiden Nachbar-Slices zeigen, dass die Form verfügbar war:
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §2 schreibt *„soweit die
Welle es zulässt"* und nennt beide Carveouts,
[slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md) §2 schreibt *„keinen Befund
hervor, der diesem Slice zuzurechnen ist"*. Gemessen über die drei: **einer von drei** trägt die
untragfähige Form.

**Warum das eine Regel ist und kein Sensor.** Ob ein Kriterium mehr verlangt als der Gegenstand des
Slice hergibt, ist ein Urteil über zwei Texte — kein Modul des Doku-Gates liest DoD-Punkte, und
`make mutate` kennt keine Fehlschlag-Form, in der ein Abnahme-Satz rot wird. Ein behaupteter
Wächter wäre genau das stille Grün aus
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).

**Adressat und Grenze — und hier liegt dieselbe Sperre wie bei
[slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md) §7 (II).** Der Regeltext gehört
in die **Ziel-Form des Slice-Plans**, also zum **Planner**; sein natürlicher Ort wäre
`slice.template.md` der Baseline, und das ist committet vendored Fremd-Bestand
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)),
den dieses Repo spiegelt statt schreibt. Ein repo-eigener Ort für Planner-Ziel-Form existiert nicht,
und ihn zu erfinden ist kein Closure-Zug. **Gezählt, nicht verkörpert**, `liegt in` entfällt. Dass
dieselbe Sperre zum zweiten Mal in Folge einen Planner-Eintrag ohne Ort lässt, ist selbst der
Befund — er steht unten bei den Folge-Posten.

#### Gezählt, nicht neu formuliert: *Grenz-/Vollständigkeitsaussage ohne gemessene Menge*

Die Bezeichnung ist die des Reviewers und bleibt stabil, damit die Zuordnung gelingt (Modul 6
§Beobachtungs-Register). **Fundorte, je einzeln gelesen — vier Slices, fünf Review-Runden, sechs
Befunde:** [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) `LOW-1` (ein Kommentar zählt
fünf Module, die Konfiguration führt sechs) ·
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) `MEDIUM-1` (vier lebende
Artefakte führen eine Aufteilung, die derselbe Commit widerlegt) ·
[slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md) `MEDIUM-1` (eine
Grenz-Aufzählung zählt ihre Menge und trifft sie nicht) · dieser Slice, Runde 1 `INFO-2` (drei
Kommentare zählen die Nicht-Emit-Gründe zu dritt, es sind vier) · Runde 2 `MEDIUM-2` und `LOW-1`
(der neu gebaute Wächter zählt seine eigenen Grenzen ab und trifft sie nicht). **Die Zuordnung ist
ein Urteil, kein Muster** — ein `grep` zählte Formulierungen, nicht Verstöße; gezählt sind die
Fundorte, die ich gelesen habe.

**Ein siebter Befund derselben Klasse ist in diesem Lauf entstanden und vor der Ablage
gefallen.** Die Zahl **7**
in §6 steht neben einem Kommando, das erst gefahren und dann geschrieben wurde: `grep -c` zählt
Zeilen und gibt über demselben Rumpf **3** aus. Gefunden hat das nicht Sorgfalt, sondern das
Fahren — dieselbe Setzung, die
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 verlangt und die auf eine **Nachbarschaft** von Zahl und Kommando nicht reduzierbar ist.

**Der Träger, den der Reviewer vorschlägt, ist eine Checklisten-Zeile vor jeder Formulierung
„N-fach", nicht mehr Sorgfalt.** Er ist hier **nicht** eingerichtet: eine Checkliste ohne Ort ist
eine Ablage ohne Leser, und der Ort für Planner- und Reviewer-Ziel-Formen ist genau die Lücke, die
Eintrag (II) oben benennt. Die **Antwort**-Regel auf die Klasse ist bereits formuliert und
gezählt — [slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md) §7 (I): *auf „die
Aussage reicht weiter als ihr Beleg" antwortet man, indem man die Aussage einschränkt*. Sie hat in
`4da4f64` ihre erste gemessene Wirkung: die Zählung *„GRENZE, zweifach"* ist **ersatzlos**
gestrichen worden, und keine vierte ist an ihre Stelle getreten
(`grep -c 'GRENZE, zweifach' test/courseset-fixture.bats` → **0**, Exit 1;
`sed -n '200,240p' test/courseset-fixture.bats | grep -c '^# GRENZE'` → **2** an diesem
Block, beide unnummeriert).

### Ausgänge — jeder Posten hat einen, *„genannt"* ist keiner

| Posten | Herkunft | Ausgang |
|---|---|---|
| Der Set-Index der adoptierten Baseline ist nicht gelesen worden und widerspricht einer Entscheidung | Review 1 `HIGH-1` | **erledigt** in `722e272` — die Quelle steht am Code (`grep -c 'Ein- vs. wiederkehrende' internal/emit/templates.go` → **1**), mit Achsen-Differenz und Nicht-Geschlossenheits-Beleg; die Abweichungs-Frage ging an den Architect und ist mit `a6d436c` beantwortet |
| Der Re-Evaluierungs-Trigger von [`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) ist eingetreten und nirgends vermerkt | Review 1 `HIGH-2` | **erledigt** — `a6d436c` legt [`ADR-0025`](../../adr/0025-register-mit-gemischten-originalen.md) an (`Proposed`); kein Satz dieses Slice hängt an ihr |
| Kopf und Index-Zelle von `CO-004` sagen, der Move stehe aus | Review 1 `MEDIUM-1` | **erledigt** in `722e272`, an vier statt drei Stellen |
| Der neue Unterscheider ist eine Zusage ohne Sensor | Review 1 `MEDIUM-2` | **erledigt** in `722e272` — die dritte bats-Achse, heute `ok 43`, mit den Zähnen `219`/`220` |
| Vier Posten stehen nur in Commit-Messages | Review 1 `MEDIUM-3`, Review 2 `MEDIUM-3` | **erledigt** in `7ce375a` — zwei lebende Träger: [slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md) und [slice-140](../open/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md) |
| [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) außerhalb seines Geltungsbereichs zitiert | Review 1 `LOW-1` | **erledigt** in `722e272` am Code; für den Plan **hier entschieden** (*Was ging anders als geplant*, §6 Risiko 3) |
| Der Grenz-Absatz behauptet eine Offenheit, die `a6d436c` beendet hat | Review 2 `MEDIUM-1` | **erledigt** in `4da4f64` — der Satz nennt einen Register-**Zustand** statt einer Entscheidung |
| Der Wächter zählt seine Grenzen ab; die dritte lässt still grün | Review 2 `MEDIUM-2` | **erledigt** in `4da4f64` — die Extraktion ist geändert, die Zählung ersatzlos gestrichen; Lerneintrag (I) |
| Zwei lebende Planungs-Register sagen, `CO-004` halte den `test`-Gate | Review 2 `MEDIUM-4` | **erledigt** in `7ce375a` — vier Absätze gezogen, zwei mehr als der Befund nannte |
| Konjunktiv, Treiber-Meldung, Absatz-Trennung | Review 2 `LOW-1`–`LOW-3` | **erledigt** in `4da4f64` |
| Der `isBrownfieldOnly`-Kommentar wächst, §3.7 legt die Abwägung in die ADR | Review 2 `INFO-2` | **weiter offen, ohne Träger** — unten, zweiter Folge-Posten |
| DoD (4)/§5 verlangen mehr, als jede korrekte Ausführung liefern kann | Verifikation `V-1` | **entschieden: Haken auf der Ausnahme-Hälfte, Kriterium unangetastet** (*Der Haken zu (4)*), Regel als Lerneintrag (II) |
| Der Ausgangs-Text von §6 Risiko 3 zitiert eine Quelle, auf der die Code-Begründung nicht ruht | Verifikation `V-2` | **entschieden: Ausgang ohne den Verweis** (§6, Begründung unter *Was ging anders als geplant*) |
| §4 und §6 decken denselben Auslöser mit unvereinbarer Folge | Verifikation `V-3` | **entschieden: §6 gefolgt, §4-Kante als nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) unerfüllbar vermerkt** (*Was ging anders als geplant*); §4 unangetastet |
| Zwei Zeilen in `TestTemplates_RecurringNichtEmittiert` können unter keiner Mutation rot werden | Verifikation `V-4` | **weiter offen, ohne Träger** — unten, erster Folge-Posten; keine DoD-Verletzung, das Muster ist geerbt |
| Zwei bats-Fälle ohne kuratierten Mutations-Fall | Verifikation `V-5` | **weiter offen, ohne Träger** — unten, erster Folge-Posten (dieselbe Ursache) |
| Das emittierte `observations.md` trägt zwei `BEDIENHINWEIS`-Blöcke, die von sich selbst sagen, sie fielen beim Kopieren weg | Review 1 `LOW-2` | **erledigt** in `7ce375a` — Träger [slice-140](../open/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md); gate-neutral (HTML-Kommentar, kein Link) |
| `<ziel>/harness/conventions/` entsteht im emittierten Baum nicht mehr, ohne `.gitkeep` | Review 1 `INFO-1` | **entschieden: so gewollt** — das Verzeichnis entstand allein aus der falschen Singleton-Einordnung; die Erwartung des Vollständigkeits-Tests führt `harness/conventions.md` als Datei und kein Verzeichnis darunter (`sed -n '/want := \[\]string{/,/^\t}/p' internal/emit/templates_test.go \| grep -c 'conventions/'` → **0**) |
| Drei Kommentare zählen die Nicht-Emit-Gründe zu dritt | Review 1 `INFO-2` | **weiter offen, unter dem Cutoff** — keine der Zeilen ist im Diff angefasst, [`AGENTS.md`](../../../../AGENTS.md) §3.7 bindet sie damit nicht; als Fundort der gezählten Klasse oben geführt |
| Kein Sensor prüft die vier Entscheidungen am realen emittierten Baum | Verifikation `V-6` | **weiter offen, mit vorbereitetem Ort** — unten, dritter Folge-Posten |

### Folge-Slices

**Zwei neu, beide in `open/` und beide aus dieser Kette:**
[slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md) (Lastenheft deckt die
Emit-Disposition — Change Request nach
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
trägt zugleich [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md)) und
[slice-140](../open/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md) (der emittierte Stand ohne
Vorlagen-Hilfen — die `BEDIENHINWEIS`-Blöcke, die von sich selbst sagen, sie fielen beim Kopieren
weg). Beide sind in `7ce375a` entstanden, also **vor** dieser Closure und im Planner-Kontext; diese
Notiz legt keinen dritten an.

### Folge-Posten ohne Träger — vier, benannt statt gelöst

Keiner ist hier geschnitten: eine Closure-Notiz gebiert keinen Slice-Plan; der entsteht im
Planungs-Lauf (Präzedenz
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7). Sie stehen hier,
damit der nächste Planner-Lauf sie findet.

1. **Zwei Abwesenheits-Zusicherungen ohne erreichbaren Pfad, und zwei geänderte bats-Zusagen ohne
   eigenen Zahn.** `TestTemplates_RecurringNichtEmittiert` führt für die zwei neuen Vorlagen auch
   die `.template.md`-Form, die `singletonTarget` gar nicht schreiben kann; und die zwei Fallnamen
   *„genau 21"* / *„die sieben"* haben ihre rot färbende Mutation im **realen Satz**, wo nur `219`
   und `220` greifen (`grep -l 'harness/baseline' test/mutations/*.sh | wc -l` → **2**). Beides ist
   geerbt und außerhalb der vier Entscheidungen, die DoD (2) aufzählt.
2. **Der Ort für die Abwägung einer Emit-Weiche.** DoD (1) verlangt die Begründung am Code, §3.7
   legt die Abwägung in die ADR, und für `isBrownfieldOnly` gibt es keine. Beobachtbarer Trigger:
   *eine zweite Weiche mit derselben Bauart entsteht* — davor wäre eine ADR für einen Einzelfall
   Formalismus.
3. **Ein Lauf, der die vier Entscheidungen am realen emittierten Baum behauptet.** Die Deckung
   entsteht heute über eine Komposition (Fixture-Achse hält `courseSet()` == realer Satz, die
   Emit-Entscheidung hängt ausschließlich am Pfad); sie trägt, aber die Gegenprobe von
   `harness/tools/smoke.sh` führt keinen der vier Namen. Der Ort ist vorbereitet: vier Zeilen in
   der bestehenden Schleife.
4. **Der Planner hat für seine eigene Ziel-Form keinen Ort.** Zum zweiten Mal in Folge endet ein
   Steering-Loop-Eintrag mit *gezählt, nicht verkörpert*, weil `slice.template.md` vendored
   Fremd-Bestand ist. Beobachtbarer Trigger: *ein dritter Eintrag derselben Bauart* — dann ist die
   fehlende Ablage der Befund und nicht mehr der einzelne Eintrag.

### Verifikation dieser Closure

`make -k gates`, `make smoke` und `make full-smoke` sind über dem Arbeitsbaum dieser Closure
gefahren und oben zitiert. **`make gates` grün ist kein Closure-Kriterium dieses Slice** — das eine
rote Ziel gehört [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) und damit
[slice-132](../open/slice-132-adaptions-block-ohne-totes-ziel.md). `make mutate` ist **nicht**
gefahren, mit Grund statt aus Bequemlichkeit: dieser Zug ändert keine Zeile Code
(`git diff --name-only HEAD -- internal/ test/ | wc -l` → **0**), und über demselben Code-Inhalt
liegt ein protokollierter Lauf mit `213 ok, 0 Befund(e)`. Ein dritter Review-Durchgang nach Modul 10
hat **nicht** stattgefunden; was die vier MEDIUM aus `92d9c50` schließt, sind die zwei Fix-Commits
plus die Verifikation über ihnen — das ist die Grenze dieser Closure, und sie steht hier, weil sie
sonst nirgends stünde.

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

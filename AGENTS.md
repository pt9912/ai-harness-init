# AGENTS.md — Briefing für AI-Coding-Agenten

## 1. Was diese Datei ist

Onboarding-Briefing für jede AI-Session, die in diesem Repo Code oder
Doku ändert. Verweist auf die kanonischen Quellen und formuliert die
Hard Rules. Bei Konflikt zwischen dieser Datei und einer kanonischen
Quelle gilt die kanonische Quelle (Source Precedence, §2).

Strukturregeln leben in [`harness/conventions.md`](harness/conventions.md); die Adaptionen selbst
liegen daneben, eine Datei je Eintrag, unter [`harness/conventions/`](harness/conventions/) — die
Datei ist ihr Index ([`MR-045`](harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)).

**Betriebsregelwerk der adoptierten Baseline — committet vendored, netzlos.**
Regelwerk **und** Templates liegen unter `.harness/baseline/<tag>/{regelwerk,templates}/`
(+ `SHA256SUMS`), auf **jedem Checkout präsent** — kein Fetch pro Lauf, kein
Netz. Der Baum ist eine **derivative Sicht** auf den Kurs; bei Konflikt gilt die
kanonische Quelle (§2 und der Kurs selbst, den `regelwerk/README.md` nennt).
**Lektüre vor dem Workflow (§6): der Index** (`.harness/baseline/<tag>/regelwerk/README.md`)
**+ das relevante Modul on-demand**, **nicht** der Volltext am Stück — der `regelwerk/`-Baum
misst am adoptierten Stand `v6.0.0` mehr als das Doppelte von Claudes
150k-Zeichen-Memory-Limit (`cat .harness/baseline/v6.0.0/regelwerk/*.md | wc -c` → **351125**;
**kein Erwartungswert**, die Zahl wandert mit dem Tag. Das Limit selbst ist eine
Werkzeug-Eigenschaft und hier nicht messbar — erhoben in
[`MR-004`](harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).

**Zugriff (pro Agent verschieden) — und vier Module sind davon ausgenommen.** **Codex**
injiziert via SessionStart-Hook nur den **Index** (`.codex/hooks.json` →
`harness/tools/sessionstart-inject-regelwerk.sh`) und liest jedes Modul **on-demand**.
**Claude** liest ebenso on-demand (Pointer: `CLAUDE.md`-Direktive + Source Precedence) —
**außer** den Modulen unter `.claude/rules/`, die als Symlink in den vendored Baum zeigen
und dadurch in **jedem** Claude-Lauf im Kontext stehen, ohne gelesen worden zu sein
(`ls .claude/rules/*.md | wc -l` → **4** von **26**,
`ls .harness/baseline/v6.0.0/regelwerk/*.md | wc -l`; beide **keine Erwartungswerte**).
Ein `@`-Auto-Import besteht nicht — Träger ist das Verzeichnis. Die Menge ist
**geschlossen**, ihre Präsenz **erzwingt nichts**, und für jedes übrige Modul gilt die
On-demand-Pflicht unverändert:
[`MR-035`](harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl).
Die `../templates/…`-Ziel-Form-Verweise des Regelwerks lösen netzlos lokal auf,
weil beide Bäume Geschwister sind (12 eindeutige Ziele, 0 tot — gemessen; roh-`grep`
zählt je nach Muster mehr, s. [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)). Fehlt die Baseline, ist der **Checkout kaputt**
(sie ist committet) — `make baseline-verify` meldet Details; sie **nicht** als
geladen voraussetzen. Mechanik: [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (löst den gefetchten Cache aus
[`MR-004`](harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)/[`MR-006`](harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ab).

**Skelett-Vorlagen der Baseline** liegen im selben vendored Baum
(`.harness/baseline/<tag>/templates/`) — sie kommen **nicht** aus einem zweiten
Asset.

## 2. Kanonische Quellen (Source Precedence)

3-Strata-Spec (Vertrag → Technik → Sicht, [`MR-019`](harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)).
In dieser Reihenfolge:

1. [`spec/lastenheft.md`](spec/lastenheft.md) — vertraglich abnahmebindend.
2. [`spec/spezifikation.md`](spec/spezifikation.md) — technisch verbindlich, ohne Vertragsänderung fortschreibbar.
3. [`spec/architecture.md`](spec/architecture.md) — Komponenten- und Sequenzsicht.
4. [`docs/plan/adr/`](docs/plan/adr/) — Architekturentscheidungen.
5. [`docs/plan/planning/in-progress/roadmap.md`](docs/plan/planning/in-progress/roadmap.md) — aktuelle Welle.
6. [`docs/user/`](docs/user/) *(falls vorhanden)* — Operations, Quality, Releasing.
7. [`README.md`](README.md) — Projekt-Überblick.
8. **AGENTS.md (diese Datei).**
9. [`harness/README.md`](harness/README.md) — Harness-Einstieg.

## 3. Harte Regeln

### 3.1 Keine halluzinierten Gates

Jeder in AGENTS.md, harness/README.md oder im Makefile genannte Gate
muss auf frischem Checkout laufen. Der Gate-Config wächst mit den
Artefakten — `ids`/`codepaths` nur mit existierenden Targets/roots
aktivieren ([`LH-QA-01`](spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

### 3.2 Lint-Suppression-Verbot

Kein `//nolint` (golangci-lint) und kein `# shellcheck disable` ohne
begründeten, zentralen Eintrag in der jeweiligen Lint-Config. Inline-Suppression
bricht den `lint`- bzw. `shell-lint`-Gate.

### 3.3 git mv + Inhaltsänderung = zwei Commits

Move und Rewrite getrennt committen, sonst fällt die Rename-Detection
unter die Similarity-Schwelle.

### 3.4 ADRs sind nach Accepted immutable

Korrekturen entstehen als neue ADR mit Supersedes, nicht durch
Überschreiben.

### 3.5 Gates nicht ohne ADR lockern

Jede Schwellen-Senkung (Modul-Aktivierung, Strenge) ist ein ADR, kein
PR-Kommentar.

### 3.6 Keine Zusage ohne rot gesehenes Gegenbeispiel

Eine Zusage — Doc-Kommentar, Test-Name, DoD-Punkt, Commit-Message — ist erst
fertig, wenn benannt ist, **was passieren müsste, damit sie bricht**, und das
einmal **rot gesehen** wurde. Ein Test, dessen Name eine Eigenschaft behauptet,
muss die Eigenschaft messen, nicht ihre heutige Implementierung.

**Falsch:** ein Test `…AusserScopeNichtEmittiert`, der die **Quell**-Namen
prüft, während der Code **transformierte Ziel**-Namen schreibt — er kann unter
keiner Mutation rot werden.
**Richtig:** den **vollständigen Ist-Bestand** gegen die erwartete Liste prüfen
und die Regel einmal aufheben, bis der Test fällt.

**Falsch:** „Byte-Gleichheit belegt `make smoke`", ohne `smoke` gelesen zu haben.
**Richtig:** benennen, was wirklich deckt — oder dass nichts deckt.

**Falsch:** ein Doc-Kommentar, der „bei jedem Fehler bleibt das Ziel
unverändert" zusagt, während ein `MkdirAll` davor läuft.
**Richtig:** die Zusage auf das einschränken, was der Code hält.

**Feedback:** `make mutate` (Nicht-Gate-Verify, §4) fährt ein kuratiertes Set aus
*(Mutation → erwartet rot färbender Test)* und meldet jeden **gelisteten** Wächter,
der seine Zähne verloren hat — gelistet heißt: wer keinen Fall in `test/mutations/`
hat, ist unbewacht. Es prüft die **Haltbarkeit** vorhandener Zähne, nicht die
**Entstehung** neuer — letztere hängt an der Pre-completion-Checkliste, die zu
jeder Zusage die rot färbende Mutation verlangt.

**Begründung (gemessen, nicht postuliert):** In slice-022a fünf Instanzen dieser
Klasse, in slice-022b vier — gefunden von vier getrennten Rollen-Durchgängen.
Ein Test, der eine Eigenschaft im Namen führt und ein Implementierungsdetail
prüft, ist ein stilles Grün im Gate — §3.1 eine Ebene tiefer. Die Regel ist eine
**Verschärfung** und braucht darum kein ADR (§3.5 gilt für Senkungen; vgl.
[`MR-001`](harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) „Gate-*Anheben* → Steering-Loop").

### 3.7 Ein Kommentar beschreibt, was da ist

Gilt für Code, Konfiguration und Skripte — und für **Zustandsfelder** (unten). Ein
Kommentar trägt eine der fünf Klassen — **Zusage · Kopplung · Abgrenzung ·
Rang-Zeiger · Grenze** — und schreibt an den, der die Stelle *ändert*, nicht an
den, der die Entscheidung *trifft*. Ausgeschrieben — Leser-Modell, Adressaten- und
Zeitform-Test, die drei Klassen, die herausfallen — steht die Regel im
Baseline-Regelwerk `grundlagen-harness-dateien.md` §Was ein Kommentar trägt.

**Beschrieben wird die Stelle, nicht der Vorgang, der sie erzeugt hat.** Die
Source Precedence (§2) ist geschlossen —
`sed -n '/^## 2\. Kanonische Quellen/,/^## 3\. Harte Regeln/p' AGENTS.md | grep -cE '^[0-9]+\. '`
→ **9** Ränge —, und ein Kommentar sitzt in keinem davon. Trägt er trotzdem den
*Grund* einer Entscheidung — eine Befund-Kennung, eine Slice-Nummer als Erzählung,
das Protokoll eines Laufs —, dann liest der nächste Lauf ihn als Beleg und beruft
sich auf eine Quelle, die kein Rang deckt. Herkunft steht darum als **ein**
auflösbares Feld in den Formen der Begründung unten und sonst gar nicht. **Ein
Sensor-Name ist keine Herkunft:** er nennt etwas, das jetzt läuft, und gehört zur
Zusage — das Protokoll seines Laufs gehört nicht dazu.

**Falsch:** „Ohne dieses Feld behauptete die Ausgabe eine Verteilung, die nicht
stattgefunden hat" — Konjunktiv über die verworfene Alternative.
**Richtig:** „Verteilt ist wahr, wenn die Splitting-Regel angewendet werden
konnte" — Indikativ über den Zustand.

**Falsch:** „die frühere Fassung prüfte nur die Länge" — beschreibt abwesenden
Text.
**Richtig:** die geltende Zusage nennen; die vorige hält `git`.

**Falsch:** „… gebrochen, Review-Befund slice-022b N-4. Die Prüfung fällt darum
auf den Satz zurück" — eine Befund-Kennung als Grund. Sie löst nach
`docs/reviews/**` auf, einem Zeitdokument in keinem Rang.
**Richtig:** die Zusage nennen und den Sensor, der sie hält; wer sie ausgelöst
hat, hält `git`.

**Falsch:** „Was hier und heute REAL rot gesehen wurde, ist `core-impurity`" — das
Protokoll eines Laufs, im Perfekt und an ein Datum gebunden.
**Richtig:** „`core-impurity` deckt diesen Fall" — der Sensor im Indikativ; dass
er einmal rot gesehen wurde, verlangt §3.6 als **Handlung**, nicht als Kommentar.

**Zustandsfelder ebenso.** Eine `Stand`- oder `Status`-Zelle — Roadmap-Faden,
Meilenstein-Tabelle, ADR-Index, Register — nennt den **Zustand** und den Beleg als
auflösbaren Anker, nicht die Chronik, wie er zustande kam. Eine Begründung des
Zustands (*gestrichen — tritt nicht mehr auf, weil …*) ist Zustand, keine Chronik.
Das Drift-Log der Roadmap (§Historische Trigger-Verschiebungen) trägt nur
Umplanungen; eine Schließung trägt das Closure-Log (§Abgeschlossene Wellen), und
zwei Logs derselben Sache driften.

**Begründung:** Die Abwägung gehört in die ADR, die Historie in `git`, die
Herkunft in **ein** auflösbares Feld ([`LH-*`](spec/lastenheft.md),
[`ADR-*`](docs/plan/adr/), `· seit welle-<NN>`, wellenlos `· seit slice-<NNN>`).
Was daneben steht, liest jeder Lauf mit und bezahlt es zweifach: mit Kontext, und
mit dem Risiko, als Quelle gelesen zu werden, die in keinem Rang steht.

**Geltungsbereich:** Code, Konfiguration, Skripte **und die Zustandsfelder der
lebenden Register**, soweit **dieses Repo sie besitzt**. Ausgenommen ist
`.harness/baseline/` — ein committet vendored Fremd-Blob, den
[`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) nicht anfasst und den das Doc-Gate aus demselben Grund
per `scan.ignore` ausnimmt. **Lebend** ist ein Register, das der Prozess
fortschreibt; ein Zeitdokument (`docs/reviews/**`, `docs/plan/planning/done/**`)
ist Chronik von Beruf und keines. Was ein **emittiertes** Repo an Regeln bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese Sektion.

**Cutoff — ab Einführung, kein Nachrüsten; für die Quellen-Klausel oben ab dem
2026-08-30.** Gebunden ist der Kommentar, der geschrieben oder geändert wird; der
**Bestand ist kein Arbeitsauftrag dieser Sektion**. Er ist gemessen, nicht
geschätzt — jede Zahl neben dem Kommando, das sie ausgibt, alle über denselben
Pathspec, der den Geltungsbereich oben abbildet (Stand 2026-09-03):

```sh
PS=( '*.go' '*.sh' '*.awk' '*Makefile' 'Dockerfile' ':!internal/emit/templates' ':!.harness/baseline' )
git ls-files "${PS[@]}" | wc -l                                                                   # 296 Dateien im Prüfbereich
git grep -lE '^[[:space:]]*(#|//).*Review-Befund' -- "${PS[@]}" | wc -l                           #  38 mit Befund-Kennung
git grep -cE '^[[:space:]]*(#|//).*Review-Befund' -- "${PS[@]}" | awk -F: '{s+=$NF} END{print s}' #  65 solche Zeilen
git grep -lE '^[[:space:]]*(#|//).*slice-[0-9]'  -- "${PS[@]}" | wc -l                            # 126 mit Slice-Nummer
git grep -cE '^[[:space:]]*(#|//).*slice-[0-9]'  -- "${PS[@]}" | awk -F: '{s+=$NF} END{print s}'  # 472 solche Zeilen
git grep -lE '· seit (welle|slice)-'             -- "${PS[@]}" | wc -l                            #   1 in der zulässigen Feld-Form
```

**Keine Erwartungswerte** ([`MR-025`](harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Baum. **Zwei Klassen sind gezählt, zwei
nicht:** Befund-Kennung und Slice-Nummer sind **Muster** und darum zählbar;
Chronik-Prosa (*„Bis slice-026 hing …"*) und Lauf-Protokoll (*„hier und heute rot
gesehen"*) sind **Urteile** — sie hier zu beziffern hieße, ein Muster als
Kriterium auszugeben, das keines ist (§3.6). Die Zahlen oben sind darum kein
Gesamtmaß des Bestands, sondern der Ausschnitt, den ein `grep` trifft. Schon
dieser Ausschnitt trägt den Cutoff: ein Maßstab über ihn wäre dauerhaft rot und
entwertete die Regel, statt sie zu tragen — dieselbe Begründung trägt ihn in
[`MR-015`](harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
Wer eine solche Zeile ohnehin anfasst, zieht sie nach; wer sie stehen lässt,
bricht nichts. Ob der Bestand darüber hinaus geräumt wird, entscheidet ein
Planungs-Schnitt und nicht diese Sektion: die vier Klassen überlappen in derselben
Zeile, und wer eine Zeile räumt, muss sie lesen.

**Für die Zustandsfeld-Hälfte gilt derselbe Cutoff, ab dem 2026-08-29.** Gebunden
ist die Zelle, die geschrieben oder geändert wird. **Eine Zahl steht hier nicht:**
ob eine Zelle Chronik trägt, ist wie die zwei Urteils-Klassen oben ein Urteil und
kein Muster — ein `grep` zählte Zellen, nicht Verstöße, und gäbe damit ein Muster
als Kriterium aus, das keines ist (§3.6).

**Herkunft, mit Mess-Stand:** die adoptierte Baseline `v5.18.0` **führt** diese
Regel — als Hard Rule mit derselben Nummer und demselben Titel im Hard-Rules-Block
der AGENTS-Vorlage
(`grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' .harness/baseline/v5.18.0/templates/AGENTS.template.md` → **1**)
und ausgeschrieben in
`grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md` → **1**.
Was hier über die Vorlage hinaus steht — Geltungsbereich, Cutoff, Quellen-Klausel
und die Wächter-Aussage —, ergänzt sie, ohne sie einzuschränken. Die
Quellen-Klausel ist die **Anwendung** der Baseline-Hard-Rule *„Wer Herkunft nennt,
nennt sie als **ein** auflösbares Feld … und nie als Absatz"*
(`grep -c 'nennt sie als \*\*ein\*\* auflösbares Feld' .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md` → **1**):
Sie nimmt keine der fünf Klassen weg und keine der dort genannten Anker-Formen —
`· seit slice-<NNN>` steht in der Begründung ausdrücklich, weil
`grundlagen-traceability.md` §Herkunfts-Anker ihn für wellenlos verkörperte Regeln
verlangt. Die Deckung ist gegen den adoptierten Stand gehalten und in
[`MR-031`](harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) protokolliert.
**Ein Wächter existiert nicht:** `make comment-claims` prüft, ob ein genannter
Sensor existiert, nicht, worüber ein Kommentar spricht — und keine Markdown-Datei
liegt in seinem Prüfbereich, also auch kein Zustandsfeld. Für die zwei zählbaren
Klassen wäre ein Sensor **baubar** — die Kommandos oben sind er beinahe schon —,
gebaut ist er nicht; ihn hier zu behaupten wäre §3.1 eine Ebene tiefer. Den
zweiten Träger, den die Baseline nennt, führt
[`MR-031`](harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
als gemessene Lücke.

### 3.8 Hard Rules und Adaptions-Block schreibt der Architect

Die Hard Rules dieser Datei (§3) und der Adaptions-Block — die Index-Datei
[`harness/conventions.md`](harness/conventions.md) samt dem Eintrags-Verzeichnis
[`harness/conventions/`](harness/conventions/) daneben — werden vom **Architect** geschrieben. Eine
Änderung an ihnen landet in einem **eigenen Commit**, der ausschließlich Artefakte derselben
schreibenden Rolle berührt — ADRs, diese Datei und den Konventionsspeicher — und die Rolle in
seiner Message nennt.
Gebunden ist das **Schreiben**; **gelesen** werden beide von jeder Rolle uneingeschränkt.

**Über andere Norm-Artefakte sagt diese Regel nichts.** Wo eine Quelle die schreibende Rolle
benennt, gilt sie unverändert; wo keine sie benennt, bleibt die Frage offen. Eine Übersicht, die
fremde Zuordnungen abschriebe, wäre eine zweite Fassung, die driftet.

**Eine dieser offenen Fragen ist beantwortet, und zwar nicht hier:** ein derivatives Register
gehört der Rolle, die seine Originale schreibt — [ADR-0024](docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md).
Für den ADR-Index ([`docs/plan/adr/README.md`](docs/plan/adr/README.md)) ist das der **Architect**;
er ist damit eines der *Artefakte derselben schreibenden Rolle*, die der Commit-Zuschnitt oben
verlangt, auch wenn dessen Aufzählung ihn nicht nennt. Wo die Ableitung endet und was sie offen
lässt, steht in der Entscheidung — hier steht der Zeiger, nicht ihr Text.

**Eine zweite ist es ebenso:** ein Rollen-Anweisungssatz — ein Command oder eine Skill-Datei, die
den Ablauf **einer** Rolle distilliert — gehört der Rolle, die ihn **ausführt**
([ADR-0028](docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Was sie
ausnimmt (`.claude/agents/*.md`) und was sie offen lässt (eine Norm-Aussage ohne Original), steht
dort; hier steht der Zeiger, nicht ihr Text.

**Falsch:** eine Anweisung im laufenden Implementations-Kontext dadurch erfüllen, dass derselbe
Lauf die Hard Rule und den Adaptions-Eintrag schreibt.
**Richtig:** die Anweisung ist die **Quelle**; was der laufende Kontext liefert, ist ein
**Übergabe-Artefakt**, und der Norm-Text entsteht im Architect-Lauf.

**Falsch:** die Norm-Änderung im Commit des Slice mitnehmen, der sie ausgelöst hat.
**Richtig:** eigener Commit, nur Architect-Artefakte, Rolle in der Message — nachträglich an
`git log --stat` ablesbar.

**Warum diese zwei, und warum der Architect.** Für die ADR spricht das Regelwerk die Dreiteilung
aus (`v3.5.2`, `modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt;
Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*). Der Adaptions-Block ist das
Abweichungs-Register — ob eine Abweichung von der Baseline **besteht**, ist eine
Architektur-Frage —, die Hard Rules sind derselbe Gegenstand eine Ebene allgemeiner; beide sind
normativ wie eine ADR, nur ohne deren Immutabilität (§3.4). Dass für diese zwei **keine** Quelle
eine schreibende Rolle benennt, ist über die adoptierte wie über die Ziel-Fassung gemessen:
[ADR-0015](docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) §Kontext, die auch die
Abwägung trägt. Die Regel füllt damit eine Lücke, statt von der Baseline abzuweichen — deshalb
steht zu ihr **kein** Eintrag im Adaptions-Block
([`MR-000`](harness/conventions.md#mr-000--baseline-aussage)).

**Begründung (gemessen, nicht postuliert):** In einem einzigen Slice wurde dreimal ein Artefakt
einer anderen Rolle im Implementations-Kontext geändert, und die Klasse bewegte sich **aufwärts** —
Definition of Done, Roadmap, repo-weite Norm. Der dritte Fall setzte eine Hard Rule samt
Adaptions-Eintrag in Kraft, die eine Baseline-Abweichung behauptete, die es nicht gibt: gemessen
gegen einen Tag, den zwei Releases überholt hatten, und ohne die Mess-Version zu nennen. Ein
zweiter Kontext hätte das in einem `git show`-Lauf gefunden — genau die Eigenschaft, für die
Rollen-Trennung existiert.

**Cutoff — ab der Annahme von [ADR-0015](docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
kein Nachrüsten.** Gebunden ist die Norm-Änderung, die geschrieben wird; der **Bestand ist kein
Arbeitsauftrag**, und ein Maßstab über ihn wäre dauerhaft rot — gemessen, nicht geschätzt
(Stand 2026-08-09): `git log --format=%H -- AGENTS.md harness/conventions.md | wc -l` → **100**
Commits berühren eine der zwei Dateien; davon tragen **89** daneben Dateien außerhalb der
Architect-Artefakte (dieselbe Commit-Liste, je Commit
`git show --pretty=format: --name-only "$c" | grep -cvE '^(AGENTS|harness/conventions)\.md$|^docs/plan/adr/|^$'`,
gezählt die Nicht-Null-Ausgaben). **Obergrenze, mit Absicht:** `git` sieht Dateien, nicht
Abschnitte — ein Commit, der allein §6 dieser Datei berührt, zählt mit, obwohl die Regel ihn nicht
bindet.

**Geltungsbereich: dieses Repo.** Was ein **emittiertes** Repo an Eigentums-Aussagen bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet — nicht diese Sektion.

**Ein Wächter existiert nicht.** Kein Modul des Doku-Gates liest Commits (`.d-check.yml` führt
`links, anchors, ids, matrix, codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen —
`--- FAIL:` der Go-Stufe, `not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot
wird. Die Regel liegt im Feedforward-Quadranten: benannt, nicht geschlossen; ihr Träger ist der
Rollen-Wechsel vor der Änderung, nicht ein Gate danach.

### 3.9 Docker-only

Kein Host-Paketmanager und keine Host-Toolchain. Checks, Builds und Gates laufen
über `make`, das die gepinnten Images fährt; der Host braucht `git`, `docker` und
GNU `make`, sonst nichts ([`LH-QA-03`](spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`ADR-0003`](docs/plan/adr/0003-go-native-binaries.md)).

**Falsch:** die Go-Toolchain, `pip`, `npm`, `cargo`, `apt` oder `brew` in der
Befehlsposition — auch in einer Sub-Shell, auch nur lesend.
**Richtig:** das `make`-Ziel, das den Schritt fährt. Fehlt eines, ist **das** der
Befund; der Host ist nicht der Ausweg.

**Begründung:** Reproduzierbar ist ein Lauf über das gepinnte Image, nicht über den
Host ([`LH-QA-02`](spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — ein Host-Lauf
liefert ein Ergebnis, das CI nicht wiederholt, und verlegt das Debugging auf den
Unterschied statt auf den Fehler.

**Grenze des Feedback-Quadranten, und sie ist zweifach.** Durchgesetzt wird die Regel
vom PreToolUse-Guard, den `.claude/settings.json` verdrahtet: er prüft die
Befehlsposition jedes Kommando-Segments und schlägt bei Parse-Zweifel fail-closed zu.
Er deckt Paketmanager und Host-Toolchains und benennt seine Grenze selbst — *„Bewusst
NICHT geprueft: andere Interpreter …; der Guard ist ein Stolperdraht …, KEINE
Sandbox"*. Und er hängt an einem Agenten: `.codex/hooks.json` führt allein den
SessionStart-Injektor. Wo der Guard nicht läuft oder nicht greift, trägt allein
dieser Abschnitt.

## 4. Quality Gates

| Target | Zweck |
|---|---|
| `make baseline-verify` | Vendored Baseline netzlos verifizieren (Integrität + Vollständigkeit, [`MR-007`](harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) |
| `make docs-check` | Doku-Referenzen (links/anchors/ids/codepaths) via d-check |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) im gepinnten Image; die Stage erbt von einer **Vorwärm-Stufe** (vorübersetzte Standardbibliothek) und erzwingt die Test-Ausführung mit `-count=1` (slice-057) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) im gepinnten Image |
| `make build` | Go-Binary cross-compilieren (Dockerfile-`build`-Stage) im gepinnten Image |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) im gepinnten Image |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) im gepinnten Image (slice-027) |
| `make comment-claims` | Kommentar-Behauptungen nennen ihren Sensor, und der genannte Test existiert (§3.6, hermetisch: bash+awk). **Prüfbereich = vier Pfad-Muster** (`internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`) **im Index, ohne `_test.go`** — damit in **drei** Achsen enger als der Gate-Stempel, nicht in einer: (1) untrackt zählt nicht (heilt beim ersten `git add`), (2) `Makefile`, `harness/tools/*.awk`, `internal/emit/templates/`, `test/` und jede Markdown-Datei liegen **dauerhaft** außerhalb, (3) Test-Dateien sind ausgenommen. Wie groß der Ausschnitt ist, sagt die „N Datei(en) geprueft"-Zeile selbst (2026-07-30: 38) — Details in [`harness/README.md`](harness/README.md) |
| `make host-bin` | Den **Träger** — das Produkt-Binär — für die **Host**-Plattform bauen und in den gitignorierten Zustands-Bereich legen; der Hook ruft ihn dort als `ai-harness-init span-emit` ([`ADR-0022`](docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2) |
| `make span-check` | Der Träger ist vorhanden **und** sein Unterkommando `span-emit` erzeugt für eine synthetische Payload einen Span, dessen Ablageort `git check-ignore` bestätigt (Schema: [`spec/spezifikation.md`](spec/spezifikation.md#5-metriken-und-tracing-felder) §5) |
| `make gates` | alle aktuell lauffähigen Gates |

Die Beschreibung dieser Ziele — was jedes prüft, was es **nicht** prüft, und welche
außerhalb von `make gates` stehen (`smoke`, `full-smoke`, `mutate`, `span-report`,
`hook-overhead`) — steht in [`harness/README.md`](harness/README.md), dem Harness-Einstieg
(Source Precedence §2, Rang 8). Sie steht dort und nicht hier: Eine Aussage hat einen Ort.

## 5. Dokumentations-Regeln

- Requirement- und ADR-IDs in PRs/Commits referenzieren (als Link oder Inline-Code).
- Neue ADRs aktualisieren den ADR-Index.
- Der Gate-Config wächst mit den Artefakten — keine halluzinierten Gates.

## 6. Minimal Agent Workflow

1. [`harness/README.md`](harness/README.md) lesen.
2. Relevante kanonische Quelle lesen (Source Precedence beachten).
3. Betroffene Requirement-/ADR-IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).
7. Doku/Indizes aktualisieren, falls ein öffentlicher Vertrag berührt.
8. Ausgeführte Sensors und Risiken berichten — keine Erfolgsmeldung ohne Gate-Lauf.

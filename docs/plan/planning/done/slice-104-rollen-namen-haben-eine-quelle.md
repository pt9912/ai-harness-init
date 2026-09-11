# Slice slice-104: Die Rollen-Namen haben eine Quelle — die Fundorte des Produktionsbestands leiten ab, die Test-Tabelle bleibt unabhängig

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — Quelle, Ableitungen und Zähne landen in
**einem** Schnitt; er wartet auf keinen zweiten Slice und keiner wartet auf ihn. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **Auch nicht in
[welle-12](../done/welle-12-erfassungsschicht-emittieren.md):** deren Abdeckungs-Tabelle führt die Zeile
*„Rolle besetzt"* als von [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) geliefert; dieser
Slice füllt keine Zelle und leert keine. **(3) Auslöser reaktiv oder gewollt?** Reaktiv — eine
gemessene Lücke am Dogfood-Sensor, kein Fähigkeits-Sprung: das Werkzeug lernt nichts, was es nicht
schon kann, und das Ziel bekommt keine Datei, die es nicht schon bekommt. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: die Quelle des Werkzeugs — und ein emittierter Text, der die Namen mitschreibt.** Drei
der vier Fundorte liegen im Go-Bestand, der als Produkt-Binär ins Ziel kopiert wird; der eine
außerhalb, [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), geht **nicht**
mit
(`ls internal/emit/templates/full-smoke* internal/emit/templates/*/full-smoke* 2>/dev/null | wc -l`
→ **0**). Der Adopter bekommt weiterhin dieselben sechs Typ-Dateien unter denselben Namen.
**Was hinzukommt:** einer der drei Go-Fundorte schreibt die Namen in einen Satz, der **im Zielrepo
steht** — `grep -n 'planner' internal/span/fieldlist.go` → Zeile **120**, und dieselbe Zeile im
frisch gebootstrappten Ziel:
`b=<scratch>/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); grep -n 'planner' "$p/harness/erfassung-feldliste.md"`
→ Zeile **74**. Eine Ableitung, die die Namen anders formatiert, ändert damit **die Bytes einer
Adopter-Datei**. Das ist keine Sperre — die Datei ist konvergent, und
`TestFeldliste_LiegtVerbatimImZiel` hält Ausdruck und abgelegte Datei zusammen —, aber es gehört
vor Frage C in §3 und nicht hinter sie.

**Bezug:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 3 lässt die Kopplung *„der Träger füllt `agent.role` genau dann, wenn der Agenten-Typ
eine der sechs kanonischen Rollen **nennt**"* ausdrücklich **benannt, nicht geschlossen**. Dieser
Slice **schließt** sie; er erfindet sie nicht, und er trägt darum keine neue Entscheidung nach —
eine *Accepted*-ADR wird gelesen, nicht ergänzt, [`AGENTS.md`](../../../../AGENTS.md) §3.4),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Rollen-Achse und ihre §Benannte Grenze — der Name **ist** der Vertrag, und ein zweiter Ort, an dem
er steht, ist ein zweiter Ort, an dem er falsch werden kann),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse, gegen die Klausel (i) der schließenden Eigenschaft gerichtet ist: ein Wächter über einem
leeren Bestand ist grün und prüft nichts),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (*wer keinen Fall in `test/mutations/` hat, ist
unbewacht* — der Voll-E2E-Sensor hat keinen, gemessen in §1),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert, und wandert mit ihrem Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Der Satz der sechs kanonischen Rollen-Namen steht im Produktionsbestand an genau einer Stelle;
die Abbildung des Trägers und der Voll-E2E-Sensor leiten ihn ab, statt ihn zu wiederholen — und die
Aussage darüber wird über einem nachweislich **nicht-leeren** Bestand gemessen.**

### Die Ausgangslage: vier Fundorte, zwei davon neu

Die Eigenschaft, über die gezählt wird: *eine Zeile im Produktionsbestand, die die sechs Namen als
Literale nebeneinander schreibt.* Kommando und Stand:
`grep -rn 'planner.*architect.*implementer' --include='*.go' --include='*.sh' . | grep -v '_test.go' | sed 's|^\./||' | grep -v '^test/' | cut -d: -f1 | sort | uniq -c`
→ **4** Dateien, mitwandernd. **`test/` fällt heraus, weil der Prüfbereich der
Produktionsbestand ist:** Ein `test/mutations/`-Fall, der eine dieser Listen kürzt, muss sie in
seinem `sed`-Muster zitieren — er ist Wächter über dem Fundort, nicht selbst einer.

| Fundort | Rolle der Zeile |
|---|---|
| [`internal/emit/agents.go`](../../../../internal/emit/agents.go), `canonicalRoles()` | die Quelle der Emission — aus ihr entstehen Dateiname und eingebettete Vorlage je Typ |
| [`internal/span/emit.go`](../../../../internal/span/emit.go), `roleFromAgentType()` | die Abbildung des Trägers — sie entscheidet, ob `agent.role` besetzt ist oder leer |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), die Schleife in `rollen_typen_im_ziel()` | der Voll-E2E-Sensor — er prüft Anwesenheit und Frontmatter-Namen im gebootstrappten Ziel |
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go), der Grenz-Satz `limitAgentGuard` | der **einzige Fundort, dessen Text ins Zielrepo emittiert wird** — er nennt die sechs Namen als Bedingung dafür, wann `agent_role` besetzt ist |

**Der vierte ist zugleich der ungebundenste.** `grep -c "planner" internal/span/fieldlist_test.go internal/emit/fieldlist_test.go`
→ **0** und **0**; der Wächter über diesem Satz (`TestFeldliste_GrenzeAufrufform`) hält drei
Textstücke, von denen keines die Namen enthält
(`sed -n '/func TestFeldliste_GrenzeAufrufform/,/^}/p' internal/emit/fieldlist_test.go | grep -c 'planner'`
→ **0**). Wird eine Rolle umbenannt, bleibt die Liste im Repo des Adopters stehen, und **kein**
Sensor sagt es.

**Den Voll-E2E-Sensor hat [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) selbst
angelegt**, und über seiner Schleife liegt **kein** Fall:
`grep -l '^# files:.*full-smoke' test/mutations/*.sh` → **leer**. Streicht man eine Rolle aus seiner
Schleife, bleiben `make shell-lint`, `make comment-claims`, `make docs-check` und `make test-go`
**alle grün** — gemessen in der [Verifikation zu slice-097](../../../reviews/2026-08-25-slice-097-verify.md)
§1.3 (Sonde P9) und hier als **fremdbelegt** ausgewiesen, nicht als eigener Lauf. Nach
[`AGENTS.md`](../../../../AGENTS.md) §3.6 ist er damit unbewacht.

**Ein fünfter Fundort existiert und bleibt, wo er ist** — die Test-Tabelle, siehe §Die Grenze
unten. Sie fällt nicht unter das Kommando oben, weil es `_test.go` ausnimmt.

### Die schließende Eigenschaft, in drei Klauseln

Nicht der Umbau macht den Slice fertig, sondern diese Eigenschaft. Sie ist **am gebootstrappten
Ziel** formuliert, weil die Fundorte dort zusammenlaufen — drei von ihnen als Datei im Ziel, der
vierte als der Sensor, der über sie liest:

1. **(i) Der Typ-Bestand des Ziels ist nicht leer und deckungsgleich mit dem einen geschriebenen
   Namens-Satz.** Bindet die Quelle **und** die Verdrahtung, die sie aufruft: fällt der Aufruf aus
   `emitAll`, ist der Bestand leer, und die Klausel bricht.
2. **(ii) Jeder Name dieses Bestands normalisiert über die Abbildung des Trägers auf ein
   nicht-leeres Rollen-Feld.** Bindet [`internal/span`](../../../../internal/span).
3. **(iii) Für diese Prüfung führt der Voll-E2E-Sensor keine eigene Namensliste.** Bindet
   [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh).

**Die drei Klauseln sind über drei Fundorten formuliert; der vierte ist von keiner benannt.** Was
ihn dennoch bindet, ist DoD (1): die Zahl aus dieser Sektion muss auf **1** stehen, und ein Satz im
emittierten Dokument, der die sechs Literale schreibt, ist ein Ort des Produktionsbestands wie jeder
andere. **Wie** er ableitet, entscheidet Frage C in §3 — sie steht dort und nicht hier, weil sie
die Bytes einer Adopter-Datei berührt und damit den Schnitt, nicht das Kriterium.

**Warum die naheliegende Ein-Satz-Fassung nicht reicht — zwei gemessene Löcher.** Die Fassung
*„jeder emittierte Typ-Name normalisiert über die Abbildung des Trägers auf ein nicht-leeres
Rollen-Feld"* trifft die Sache, bindet aber nur zwei Fundorte:

- **Sie lässt den Voll-E2E-Sensor frei.** Die Schleife in
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) ist weder ein emittierter
  Typ-Name noch die Abbildung des Trägers; nimmt man ihr eine Rolle, bleibt der Satz wahr. Deshalb
  Klausel (iii).
- **Sie ist über der leeren Menge wahr.** Ohne emittierte Typ-Namen normalisiert jeder von null
  Namen — dieselbe Falle, die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) für
  Gates über leerem Prüfbereich benennt. Gemessen: entfernt man `emit.Agents(targetDir)` aus
  `emitAll`, bleibt `make test` grün (Sonde P6 derselben Verifikation, **fremdbelegt**). Deshalb
  trägt Klausel (i) das Wort *nicht leer*, und zwar vor allem anderen.

### Die Grenze: die Test-Tabelle wird nicht eingesammelt

`TestSpawnedRoleIsNormalised` in
[`internal/span/response_test.go`](../../../../internal/span/response_test.go) führt eine
Literal-Tabelle: `sed -n '/cases := map\[string\]string{/,/^\t}$/p' internal/span/response_test.go | grep -oE ': "[^"]*"' | wc -l`
→ **16** Einträge, davon `… | grep -oE ': "[^"]+"' | wc -l` → **6** mit nicht-leerer Erwartung. Die
übrigen **zehn** sind **Verneinungen** — `general-purpose`, der Leerstring, ein Großbuchstabe, ein
angehängtes Leerzeichen, eine Zahl, `null`, ein Objekt, eine Liste.

**Diese Tabelle ist der fünfte Fundort, und der Träger sammelt sie nicht ein.** Ein Test, der seine
Erwartung aus dem geprüften Code ableitet, ist zirkulär: er kann unter keiner Mutation der Quelle
rot werden, und genau diese Bauart hat dieses Repo schon einmal gemessen — ein Wächter, dessen
Erwartung aus der mutierten Funktion stammte, blieb unter seinem eigenen Fall grün
([slice-096](../done/slice-096-traeger-liegt-im-ziel.md) §7). Die Tabelle hält den **Vertrag** — die
sechs Namen **und** ihre Verneinungen —, nicht den Bestand. Sie darf die Namen darum ein zweites Mal
schreiben; jede andere Stelle darf es nicht.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Sie folgen den drei Klauseln aus §1, in der Reihenfolge,
in der sie tragen.

- [x] **(1) Die Namen stehen einmal; die Abbildung des Trägers leitet ab (Klausel ii).** Nach dem
      Lauf schreibt genau **ein** Ort des Produktionsbestands die sechs Literale; die Zahl aus §1
      steht dann auf **1**, gemessen mit demselben Kommando. Ein Wächter verlangt für **jeden** Namen
      der Quelle ein nicht-leeres Rollen-Feld und für einen Namen daneben ein leeres — beide
      Richtungen, sonst prüft er eine Teilmenge.
      **Rot:** `make test` — dazu ein `test/mutations/`-Fall, der die Quelle um eine Rolle kürzt,
      und einer, der die Abbildung um denselben Namen kürzt; unter jedem muss der Wächter fallen.
- [x] **(2) Der Bestand, über dem gemessen wird, ist nachweislich nicht leer — die Verdrahtung hat
      ihren eigenen Zahn (Klausel i).** Heute deckt sie kein `test/mutations/`-Fall, und `make test`
      bleibt grün, wenn `emit.Agents(targetDir)` aus `emitAll` fällt (§1, fremdbelegt).
      **Rot:** `make full-smoke` — plus ein `test/mutations/`-Fall mit `# verify: full-smoke`, der
      genau diesen Aufruf entfernt. **Die Stufe ist nicht frei wählbar:** ein Go-Test im Paket
      [`internal/emit`](../../../../internal/emit) sieht den Aufruf in
      [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go) nicht.
- [x] **(3) Der Voll-E2E-Sensor führt keine eigene Namensliste und hat erstmals einen Fall über
      sich (Klausel iii).** Nach dem Lauf liefert
      `grep -l '^# verify: full-smoke' test/mutations/*.sh | xargs -r grep -l '^# expect:.*Rollen-Typ'`
      mindestens **einen** Treffer — heute **leer**. **Zwei Achsen, und beide tragen:** `# verify:`
      nennt den Sensor, dessen Rot erwartet wird, `# expect:` das Rot selbst — und der Wortlaut
      `Rollen-Typ` ist der der Schleife
      (`grep -c 'FEHLER — Rollen-Typ' harness/tools/full-smoke.sh` → **2**, beide Zweige von
      `rollen_typen_im_ziel`). Die Zeile `# files:` taugt dafür nicht: sie nennt die Datei, die der
      Fall **patcht**, nicht den Sensor, der rot wird — ein Fall über dieser Schleife patcht
      [`internal/span`](../../../../internal/span), nicht den Sensor.
      **Rot:** `make full-smoke` — ein Fall, der der abgeleiteten Liste ihre Ableitung nimmt (eine
      Rolle im Ziel fehlt, ohne dass der Sensor sie vermisst), muss rot werden. **Was dieser Punkt
      ausdrücklich nicht verlangt:** dass der Sensor seine Liste aus dem **Ziel** liest — das wäre
      die Zirkularität aus §Die Grenze, eine Ebene tiefer.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/agents.go`](../../../../internal/emit/agents.go) | update | die eine Quelle. **Hier bekommt `AgentFile()` seinen Aufrufer oder fällt:** `grep -rn 'AgentFile' --include=*.go . \| wc -l` → **1**, die Definition selbst; ihr Doc-Kommentar nennt eine Nutzung *„(fuer Tests/Inspektion)"*, die es nicht gibt ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Der Bestands-Nachweis aus DoD (1) braucht genau diesen Zugriff — die Zeile steht hier und nicht in §6, weil ein Posten ohne Ort in der Plan-Tabelle in diesem Repo gemessen wirkungslos bleibt |
| [`internal/span/emit.go`](../../../../internal/span/emit.go) | update | `roleFromAgentType` leitet ab statt zu wiederholen. **Nur eine Richtung ist zyklenfrei:** `grep -rn 'ai-harness-init/internal/span' internal/emit/*.go \| wc -l` → **2** und `grep -rn 'ai-harness-init/internal/emit' internal/span/*.go \| wc -l` → **0** (keine Erwartungswerte); die Kante `emit → span` besteht, die Gegenrichtung wäre ein Zyklus. Frage A ist damit an der Messung entschieden, nicht an der Abwägung — der Antwortblock unter dieser Tabelle führt sie aus |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | der Voll-E2E-Sensor verliert seine eigene Liste (Klausel iii) |
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go), der Grenz-Satz `limitAgentGuard` | update | der vierte Fundort (§1) — er schreibt die sechs Literale in einen Text, der **im Zielrepo** steht, und ist an nichts gebunden (`grep -c "planner" internal/span/fieldlist_test.go internal/emit/fieldlist_test.go` → **0** und **0**). Die Form seiner Ableitung ist Frage C, weil sie die Bytes einer Adopter-Datei berührt |
| [`internal/emit/agents_test.go`](../../../../internal/emit/agents_test.go) | update | zwei Ein-Zeilen-Korrekturen aus der Closure von [slice-097](../done/slice-097-rollen-typen-gehen-mit.md): der Klassen-Kommentar beziffert die Emissions-Menge unter `docs/plan/` mit *zwei* (gemessen **3** Inhaltsdateien — `find .harness/baseline/v6.5.0/templates/docs/plan -type f` gegen `sed -n '/^func isRecurring/,/^}/p' internal/emit/templates.go`, die vier `.gitkeep` daneben nennt der Kommentar nicht), und das `richtung`-Feld derselben Klasse sagt *„unter `docs/plan/`"*, während sein Muster nur `planning\|adr` deckt. Die Datei wird für DoD (1) ohnehin angefasst |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die Zähne aus DoD (1)–(3); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| wc -l` → **165**, beim Anlegen neu auszuzählen) |
| [`internal/span/response_test.go`](../../../../internal/span/response_test.go) | **unverändert** | §Die Grenze: die Tabelle hält den Vertrag samt seiner zehn Verneinungen und leitet nichts ab |
| [`docs/plan/adr`](../../adr) | **unverändert** | [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3 lässt die Kopplung *benannt, nicht geschlossen*; sie auszuführen ist keine neue Entscheidung, und eine *Accepted*-ADR wird nicht nachgetragen ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Offen, vor dem Code zu entscheiden — alle drei entscheiden den Schnitt, nicht nur den Stil:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wer leitet von wem ab: liest der Träger die Quelle des Emitters, oder liest der Emitter die Abbildung des Trägers?** | Beide Richtungen sind heute frei (Messung oben). *Emitter → Träger* macht die Emission von der Erfassung abhängig, obwohl die Rollen-Typen ausdrücklich **keinen** Laufzeit-Ausgang haben ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a)); *Träger → Emitter* macht die Erfassung von einer Vorlagen-Liste abhängig. Ein drittes, gemeinsames Paket ist die dritte Antwort und der teuerste Schnitt |
| B | **Woraus leitet der Voll-E2E-Sensor seine Liste ab?** | Aus dem **Ziel** wäre zirkulär (§Die Grenze). Aus `internal/emit/templates/agents/` ist ein Vergleich zweier verschiedener Bäume und damit eine echte Aussage. Aus einem Unterkommando des Trägers wäre die stärkste Fassung — sie kostet aber ein neues Stück öffentlicher Oberfläche, und die gehört begründet, nicht nebenbei |
| C | **In welcher Form leitet der emittierte Grenz-Satz seine Namensliste ab?** | Er ist der einzige Fundort, dessen Text **ins Zielrepo geht**: `grep -n 'planner' internal/span/fieldlist.go` → Zeile **120**, dieselbe Liste im gebootstrappten Ziel → Zeile **74** (Kommando in §Ebene). Eine Ableitung, die anders formatiert — andere Reihenfolge, andere Trenner, andere Auszeichnung —, ändert die **Bytes einer Adopter-Datei**; die ist konvergent, ein Re-Lauf zieht sie nach, und `TestFeldliste_LiegtVerbatimImZiel` hält Ausdruck und Datei zusammen. Die Frage ist damit nicht, **ob** er ableitet (DoD (1) verlangt es), sondern ob der Satz danach noch derselbe Satz ist — und das ist eine Leser-Entscheidung, keine Formatierungsfrage |

**Entschieden, vor dem Code — Frage A drift-korrigiert, B und C wie oben:**

- **Frage A war bei Implementierungsbeginn bereits durch die Messung selbst entschieden, nicht mehr
  offen.** Die Prämisse *„beide Richtungen sind heute frei"* stimmte zum Plan-Zeitpunkt nicht mehr:
  `grep -n 'internal/span"' internal/emit/fieldlist.go` → Zeile **4** — `internal/emit` importiert
  `internal/span` bereits (für `FieldList()`, die Feldlisten-Emission, unabhängig von diesem Slice).
  Ein zweiter Import in der Gegenrichtung (`internal/span` → `internal/emit`) wäre ein Zyklus und
  compiliert nicht. Damit bleibt genau **eine** Richtung technisch möglich: *Träger → Emitter* —
  `span.CanonicalRoles()` ist die eine Quelle, `emit.canonicalRoles()` liest sie
  (`internal/emit/agents.go`). Die in Frage A notierte Sorge zu *Emitter → Träger* (Laufzeit-Kopplung
  nach [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a)) betrifft ohnehin nur diese verworfene Richtung; die gewählte
  Richtung berührt Festlegung 5(a) nicht — `Agents()` schreibt weiterhin unbedingt, unabhängig vom
  Erfolg der Erfassungsschicht, und der Import ist ein reiner Kompilierzeit-Bezug auf eine
  Konstanten-Liste, kein Laufzeit-Ausgang.
- **Frage B: aus `internal/emit/templates/agents/*.md`.** `harness/tools/full-smoke.sh` leitet die
  erwartete Rollen-Liste aus dieser Quelle ab (Glob über den Dateinamen ohne `.md`-Endung), mit
  explizitem `nullglob` + Nicht-leer-Prüfung gegen einen stillen Nulldurchlauf. Rot gesehen:
  `test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh` (eine Rolle verschwindet auf dem
  Weg zum Ziel, die Quelle bleibt unverändert — der Sensor findet sie trotzdem, weil er nicht aus dem
  Ziel selbst liest).
- **Frage C: `backtickJoin(span.CanonicalRoles())`.** Der Grenz-Satz baut die Aufzählung
  `` `planner`, `architect`, … `` aus derselben Liste; die Zielform (Backtick + Komma, keine
  Konjunktion vor dem letzten Element) ist unverändert, `TestFeldliste_LiegtVerbatimImZiel` bleibt
  grün ohne Anpassung. Da die Zusammensetzung eine Funktion braucht (kein Konstantenausdruck),
  wandert `limitAgentGuard` von `const` zu `func` — `golangci-lint`s `gochecknoglobals` verbietet den
  naheliegenden Zwischenschritt (package-level `var`), rot gesehen unter `make lint`.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit — und das ist
der Termin, den dieser Slice trägt.** Frage A und B aus §3 sind ohne Vorarbeit eines anderen Slice
entscheidbar; der Gegenstand liegt vollständig in diesem Repo, berührt keine Anforderung und keine
Entscheidung und hängt an keiner Welle. Er wartet insbesondere **nicht** auf den `done/`-Zug von
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md): die Schleife des Voll-E2E-Sensors liegt bereits im
Baum, und die Messung in §1 gilt über ihm.

**Was dieser Slice ausdrücklich nicht ist: eine Nennung.** Die drei Postens, die er aufnimmt —
dritter Fundort, unbewachte Verdrahtung, aufruferloses `AgentFile()` — sind in einer Closure
gemessen und benannt worden. Ein Träger ohne Termin ist in diesem Repo dreimal vergeben und
nullmal eingelöst worden
([slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) §1, dort mit Kommando); der Termin ist
dieser Schnitt.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn Frage A auf ein **drittes, gemeinsames Paket**
  hinausläuft. Dann sind es zwei Slices — einer, der das Paket schafft und die zwei Go-Fundorte
  zieht, und einer für den Sensor. Ein Paket-Schnitt quer durch
  [`internal/emit`](../../../../internal/emit) und [`internal/span`](../../../../internal/span) ist
  in **einer** Review-Sitzung nicht prüfbar, und das ist die Schwelle aus Modul 5 §Ziel-Form.
- **`in-progress` → `open` (blockiert):** wenn sich zeigt, dass die Ableitungs-Richtung aus Frage A
  eine Aussage von
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) berührt, statt
  sie auszuführen — etwa weil sie den Rollen-Typen doch einen Laufzeit-Ausgang gäbe. Dann wartet
  der Slice auf eine Entscheidung, statt an einer *Accepted*-ADR vorbeizubauen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4).

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; die Zahl der Literal-Fundorte im Produktionsbestand
steht auf **1** (Kommando in §1); Frage A und B sind mit ihrer Begründung im Plan beantwortet;
Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün; `make full-smoke`
grün; `make mutate` grün mit den neuen Fällen; `git mv` nach `done/` als eigener Move-Commit;
Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor ·
benannte Spec-Lücke).

## 6. Risiken und offene Punkte

- **Die schließende Eigenschaft kann formal erfüllt und sachlich leer werden.** Wer Klausel (i) über
  einer Liste misst, die er selbst aus derselben Quelle erzeugt, hat die Zirkularität nur verschoben
  — dieselbe Bauart, die §Die Grenze für die Test-Tabelle ausschließt. Der Prüfpunkt: **an welchen
  zwei verschiedenen Artefakten** der Vergleich hängt. Steht auf beiden Seiten dasselbe Artefakt,
  ist die Klausel keine.
- **Klausel (iii) kann die Aussage des Sensors verkleinern.** Nimmt man
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) die Liste und lässt ihn
  über das lesen, was er im Ziel findet, prüft er hinterher, dass da ist, was da ist. Das ist
  **schlechter** als die heutige Literal-Schleife, nicht besser. Frage B entscheidet das, und sie
  gehört vor den Code.
- **Zwei Zähne kosten `full-smoke`-Laufzeit.** DoD (2) und (3) verlangen Fälle auf der teuersten
  Stufe des Treibers; heute tragen `grep -l '^# verify: full-smoke' test/mutations/*.sh | wc -l` →
  **3** Fälle diesen Modus. Dass das teuer ist, ist kein Grund für eine schmalere Stufe — es ist der
  Gegenstand von [slice-105](../done/slice-105-mutate-messen-dann-teilen.md), und die zwei Slices sind
  voneinander unabhängig: keiner wartet auf den anderen.
- **Der Slice berührt die Rollen-Achse, ohne sie zu verbreitern.** Er schließt eine Kopplung im
  Werkzeug; die Grenze, dass ein umbenannter Typ im Ziel ein **leeres** Feld ergibt, bleibt
  unangetastet und unbewacht — sie ist die von
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) selbst
  ausgesprochene, und ein Wächter darüber wäre einer über einem fremden Vertrag.
- **`make gates` deckt Klausel (i) nicht.** Sie hängt an `make full-smoke`, und der steht
  ausdrücklich **nicht** in `make gates` ([`AGENTS.md`](../../../../AGENTS.md) §4). Wer nach diesem
  Slice nur `make gates` fährt, sieht die Verdrahtung weiterhin nicht — das ist eine Eigenschaft der
  Stufe, keine Lücke des Schnitts, und sie gehört in die Closure-Notiz statt in eine Zusage.

### Ausgänge (einer je Risiko, Modul 5 §Offene Risiken werden bei Closure aufgelöst)

1. **Zirkularität der Klausel (i) — entfallen.** Der Vergleich hängt an zwei verschiedenen Bäumen:
   die Erwartung kommt aus `internal/emit/templates/agents/*.md` im Quell-Baum, der Ist-Bestand aus
   `.claude/agents/*.md` des gebootstrappten Ziels. `test/mutations/305` trennt beide nachweisbar —
   es kürzt `CanonicalRoles()`, lässt die Vorlagen-Dateien unangetastet, und der Sensor vermisst die
   Rolle trotzdem. Eine aus dem Ziel gelesene Erwartung könnte das nicht.
2. **Klausel (iii) verkleinert die Sensor-Aussage — entfallen.** Frage B ist zugunsten der Quelle
   entschieden, nicht zugunsten des Ziels; derselbe Fall `305` ist der Beleg, dass der Sensor eine
   Abweichung zwischen beiden Bäumen sieht statt sie wegzudefinieren.
3. **Zwei Zähne kosten `full-smoke`-Laufzeit — eingetreten.** Der Modus trägt jetzt mehr Fälle
   (`grep -l '^# verify: full-smoke' test/mutations/*.sh | wc -l`, kein Erwartungswert). Ein
   Folge-Slice ist dafür nicht geschuldet, weil der Auffang vor dem Eintritt stand und gemessen ist:
   die Worker-Verteilung aus [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) und der
   Beleg-Mechanismus aus
   [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md), der einen
   Lauf über unverändertem Prüfgegenstand ganz ausfallen lässt.
4. **Verbreiterung der Rollen-Achse — entfallen.** Die Grenze ist unberührt: der Slice ändert
   [`spec/lastenheft.md`](../../../../spec/lastenheft.md) nicht, und
   [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Benannte
   Grenze steht unverändert. Ein Wächter über einem fremden Vertrag ist nicht entstanden.
5. **`make gates` deckt Klausel (i) nicht — entfallen als Risiko, bestehen als benannte Grenze.**
   Was die Formulierung befürchtete — dass die Deckung an der Erinnerung einzelner Läufe hängt —
   tritt nicht ein: `.github/workflows/ci.yml` fährt `make full-smoke` **und** `make mutate` bei
   jedem `push` und `pull_request` (`grep -nE 'make (mutate|full-smoke)' .github/workflows/ci.yml`).
   Der Träger ist mechanisch, nicht disziplinarisch. Die Grenze selbst bleibt wahr und steht in §7.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner (frischer Kontext, [`AGENTS.md`](../../../../AGENTS.md) §3.10) · **Datum:** 2026-09-11

### Geliefert

Der Satz der sechs kanonischen Rollen-Namen steht im Produktionsbestand an **einer** Stelle —
`span.CanonicalRoles()`. Die Abbildung des Trägers, die Emissions-Quelle und der Grenz-Satz, dessen
Text ins Zielrepo geht, lesen sie; der Voll-E2E-Sensor gewinnt seine Erwartung aus einem **zweiten**
Baum, den Typ-Vorlagen, und vergleicht damit zwei Artefakte statt eines mit sich selbst. Die Bytes
der Adopter-Datei sind dabei unverändert geblieben: die Aufzählung entsteht jetzt aus derselben
Liste, in derselben Form.

### Was funktionierte

**Die Ableitungs-Richtung war keine Abwägung, sondern eine Messung.** Eine der zwei Richtungen ist
ein Import-Zyklus und übersetzt nicht; damit blieb genau eine übrig, und die Frage, die der Plan als
offen führte, war es bei Arbeitsbeginn nicht mehr. Wer sie als Abwägung geführt hätte, hätte eine
Entscheidung begründet, die der Compiler ohnehin trifft.

**Der Sensor liest die Quelle, nicht das Ziel, und ist gegen den Nulldurchlauf abgesichert.** Ohne
den `n=0`-Zähler wäre die Schleife über einem leeren Glob still grün — dieselbe Falle, die
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) für Gates
über leerem Prüfbereich benennt und die Klausel (i) mit dem Wort *nicht leer* adressiert.

### Was anders lief

**Zwei der drei Abnahme-Kommandos maßen eine andere Menge als die Eigenschaft, die sie zusagten.**
Beide sind nachgezogen, und beide Korrekturen sind gegen den Baum **vor** der Arbeit gehalten, statt
gegen den danach — eine Messmethode, die erst nach getaner Arbeit grün wird, ist keine Senkung; eine,
die schon vorher grün war, wäre eine. Der Abschnitt *Der Abnahmemaßstab* unten führt beide aus.

**Fünf Mutations-Fälle haben ihre Zähne an einer berechtigten Umbenennung verloren**, und sie
verloren sie auf **zwei** verschiedenen Wegen. Ein Anker, der das alte Symbol sucht, greift nicht
mehr und mutiert nichts. Ein Fall, der Code mit dem alten Symbol **einfügt**, mutiert sehr wohl —
aber der so entstandene Baum übersetzt nicht, und der erwartete Test fällt aus einem anderen Grund.
Nur der erste Weg fällt bei einer No-Op-Prüfung auf.

### Der Abnahmemaßstab: zwei Entscheidungen, beide gegen den Vor-Baum gemessen

**DoD (1) — das Kommando ist nachgezogen, die Eigenschaft unverändert.** Das ursprüngliche Kommando
nahm `_test.go` aus, nicht `test/`. Sein Prüfbereich enthält damit die Mutations-Fälle, die den
Punkt erfüllen — und die müssen die Liste zitieren, sonst könnten sie sie nicht kürzen. Der Maßstab
war dadurch **strukturell unerreichbar**: Jeder Wächter, der DoD (1) einlöst, hebt seine Zahl. Mit
der Verengung auf den Produktionsbestand liefert dasselbe Kommando über dem Baum vor der Arbeit
**4** und heute **1** — es reproduziert also exakt die Ausgangszahl aus §1 und ist damit nicht
weicher geworden, sondern trifft erst jetzt seinen erklärten Gegenstand.

**DoD (3) — das Kommando ist ersetzt, weil es die falsche Achse maß.** `# files:` nennt die Datei,
die ein Fall **patcht**; ein Fall über der Rollen-Schleife patcht
[`internal/span`](../../../../internal/span), nicht den Sensor. Das alte Kommando war deshalb schon
vor Arbeitsbeginn nicht leer und band den gelieferten Fall nicht. Der Vorschlag, allein auf
`# expect:` zu suchen, ist **nicht übernommen**: Er bindet eine Kommentarzeile, nicht den Sensor.
Das nachgezogene Kommando verlangt beide Achsen — `# verify:` nennt den Sensor, dessen Rot erwartet
wird, `# expect:` das Rot der Schleife selbst. Über dem Baum vor der Arbeit ist es **leer**, heute
nennt es zwei Fälle; die Zusage *„heute leer"* wird damit erstmals wahr.

### Steering-Loop-Einträge

1. **Geschärfte Regel — ein Abnahme-Kommando wird gegen den Baum *vor* der Arbeit gehalten.** Ein
   Kriterium, das schon vorher grün ist, misst nicht die Lieferung; eines, dessen Prüfbereich die
   Artefakte enthält, die es erfüllen, ist unerreichbar. Beide Fehlformen fallen auf, sobald dasselbe
   Kommando einmal über dem Eltern-Stand läuft — das kostet einen `git archive` und trennt
   *Messmethode nachziehen* von *Maßstab senken*. Die Regel steht hier als Lerneintrag und noch
   nicht als Norm: ihre zwei Beobachtungen sind unter der Schwelle.
2. **Neuer Sensor — der Voll-E2E-Sensor hat erstmals einen Fall über seiner Rollen-Schleife.** Rot
   gesehen unter `make mutate` sind beide Achsen, die er trägt: eine Rolle verliert sich auf dem Weg
   ins Ziel (`305`), und die Verdrahtung fällt ganz aus (`306`).
3. **Benannte Grenze — Klausel (i) hängt an einer Stufe außerhalb von `make gates`.** Die Stufe ist
   erzwungen, nicht gewählt: ein Go-Test in [`internal/emit`](../../../../internal/emit) sieht den
   Aufruf in [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go) nicht. Wer nur
   `make gates` fährt, hat für diese Klausel keinen Beleg; wer pusht, hat einen, weil CI
   `make full-smoke` und `make mutate` mitführt.

### Beobachtungs-Register

- **Beleg ergänzt:**
  [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  — fünf Fälle in **einem** Vorgang, darum ein Beleg. Der Eintrag erreicht damit seinen dritten
  Vorgang. Seine `state.md` ist um die zweite Bruchform erweitert: Der billige Vorab-Vergleich, den
  sie als Ausweg nennt, trennt *stumpf* von *scharf* nur für den Anker — ein Fall, der das alte
  Symbol **einfügt**, verändert die Datei und fällt durch diesen Vergleich hindurch.
- **Beleg ergänzt:**
  [`mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md)
  — dieselbe Mechanik mit anderem Träger: nicht der Plan liegt in der Bezugsmenge seines eigenen
  Such-Kommandos, sondern der gelieferte Wächter.
- **Beleg ergänzt:**
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — die Unterklasse *Prosa-Zahl*, die seine `state.md` als offen führt: zwei Messungen desselben
  Kommandos standen in §3 nebeneinander, die überholte und ihre Korrektur. Beide Zahlen sind auf den
  Ist-Stand gezogen.
- **Neu angelegt:**
  [`abnahme-kriterium-bindet-das-gelieferte-artefakt-nicht`](../observations/BEO-ALL/abnahme-kriterium-bindet-das-gelieferte-artefakt-nicht/observation.md)
  — ein Beleg. Die Nachbarklasse *Mess-Zusage trifft das eigene Zitat* deckt sie nicht: dort ist der
  Zielwert unerreichbar, hier ist er **schon vor der Arbeit erreicht**.
- **Neu angelegt:**
  [`gepinnter-werkzeug-weg-umgangen-ohne-guard-treffer`](../observations/BEO-ALL/gepinnter-werkzeug-weg-umgangen-ohne-guard-treffer/observation.md)
  — ein Beleg, selbst gemeldet und ohne Code-Folge. Er steht im Register und nicht nur in dieser
  Notiz, weil der Wächter dafür **existiert** und nicht gegriffen hat: Der Guard prüft die
  Befehlsposition, und die trug ein erlaubtes `docker`.
- **Zwei Belege entstehen erst durch den Move** und stehen darum neben ihm statt in dieser Liste
  oben: [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  (vier eingefrorene Artefakte, beide Adress-Formen — s. u.) und
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  (der Ruhe-Marker der Roadmap, laut geworden mit Grund-Code `planning-drift`).
- **Kein Beleg für**
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md):
  Der neue Wächter ist gelistet — `test/mutations/303` und `304` nennen ihn in ihrer `# expect:`-Zeile
  und kürzen die zwei Seiten der Ableitung einzeln.

### Der Lese-Schritt, und warum er hier nicht liegt

Dieses Repo führt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l`, kein Erwartungswert),
und die Welle-Closure liest alles, was seit der letzten Closure in `done/` liegt — **auch Slices
ohne Wellen-Zugehörigkeit** (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Der Lese-Schritt — welcher Eintrag **3×** erreicht hat und welchen Ausgang er bekommt —
gehört damit der Welle-Closure, und der Herkunfts-Anker einer daraus verkörperten Regel lautet
`seit welle-<NN>`.

**Ein Eintrag tritt mit dieser Closure über die Schwelle** und steht bis dahin `offen` — zulässig
und vorübergehend (`modul-06-roadmap.md` §Das Beobachtungs-Register): die Anker-Klasse oben. Ihr
Material für den Lese-Schritt liegt im Eintrag selbst und nicht in dieser Notiz, denn der
Lese-Schritt liest das Register.

**Der stehende Rückstand ist damit nicht aufgelöst und gehört benannt.** Einträge bei ≥ 3× mit Stand
`offen`:

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d/evidence"/*.md 2>/dev/null | wc -l); s=$(head -1 "$d/state.md")
  [ "$n" -ge 3 ] && [ "$s" = "**Stand:** offen" ] && echo "$(basename $d) $n"
done | sort -k2 -rn
```

**Kein Erwartungswert.** Zwei davon berührt dieser Slice — die Anker-Klasse, die er über die
Schwelle hebt, und den Verweis-Nachzug unten; ihre Zahlen steigen, ihr Zustand nicht.

### Die §3.11-Vormessung, über beide Adress-Formen

Vor dem `git mv` ist gemessen worden, welches eingefrorene Artefakt den wandernden Plan-Pfad als
**Pfad** nennt — Markdown-Link und Code-Span getrennt, weil sie auf verschiedene Module des
Doku-Gates fallen:

```sh
F=slice-104-rollen-namen-haben-eine-quelle.md
git grep -lE "\]\([^)]*$F\)"        -- 'docs/plan/planning/done/**' 'docs/reviews/**' 'docs/plan/adr/**'   # 3
git grep -lE "\`[^\`[:space:]]*$F\`" -- 'docs/plan/planning/done/**' 'docs/reviews/**' 'docs/plan/adr/**'  # 1
```

**Keine Erwartungswerte.** Die Link-Form trifft drei eingefrorene Closure-Notizen; die Code-Span-Form
trifft einen **Rollen-Report**, den eine Messung über die Link-Form allein nicht sieht — genau der
Grund, aus dem §3.11 beide verlangt. Entschieden **vor** dem Move, wie die Sektion es vorschreibt:
Der Move wird ausgeführt. Träger dieser Entscheidung ist nach der `state.md` von
[`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
der Lauf, der den Move plant, solange die Norm-Frage beim Architect liegt; der Vorgang bekommt dort
seinen Beleg.

### Zwei Rückführungen, keine gezogen

§4 nennt für `in-progress → next` das **dritte, gemeinsame Paket** als Bedingung. Es ist nicht
entstanden: Die gewählte Richtung nutzt eine Kante, die schon vor der Arbeit bestand
(`grep -c 'ai-harness-init/internal/span' internal/emit/fieldlist.go`), und legt kein Paket an
(`ls -d internal/*/ | wc -l`, kein Erwartungswert, unverändert gegenüber dem Eltern-Stand). Für
`in-progress → open` nennt §4 eine berührte Aussage von
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md): Festlegung 5(a)
betrifft allein die verworfene Gegenrichtung, `Agents()` schreibt weiterhin unbedingt, und der neue
Import ist ein Kompilierzeit-Bezug auf eine Konstanten-Liste. Beide Bedingungen sind geprüft und
nicht eingetreten.

### Verifikation

- **`make gates`** grün, vom Verifier selbst gefahren; `docs-check` meldete dabei `0 Befund(e)` über
  seinem vollen Prüfbereich (`make docs-check`, die Datei-Zahl wandert mit dem Bestand).
- **`make full-smoke`** vollständig durchgelaufen, ohne `FEHLER`-Zeile — die Stufe, an der Klausel (i)
  und (iii) hängen, ist real gefahren und nicht nur zitiert.
- **`make mutate`** ohne Befund über allen Fällen (`ls test/mutations/*.sh | wc -l`, kein
  Erwartungswert); der Beleg ist an den Prüfgegenstand gebunden, und die neun tragenden Fälle sind
  einzeln per Anker-Diff gegen den echten Quellcode nachgerechnet worden, statt aus der
  Gesamtmeldung geschlossen zu werden.
- **Review** nach Modul 10 in einer abgelegten Runde; die drei HIGH sind aufgelöst. **Verifikation**
  nach Modul 11 mit eigenständiger Nachmessung beider Abnahme-Kommandos — sie hat die zwei
  Abweichungen benannt und die Entscheidung darüber ausdrücklich dem Planner überlassen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

### Sub-Area: Rollen-Namen im Werkzeug (Emitter · Träger · Voll-E2E-Sensor)

Eine Sub-Area, kein zweiter Block: drei Dateien, **ein** Gegenstand — der Satz der sechs Namen —
und eine Frage, nämlich wo er geschrieben steht. Das Inklusionskriterium trägt über alle drei
Achsen: eigener Bestand, eigener Sensor, eigene Konvention.

- **Modus:** GF. Alle vier Fundorte sind in diesem Repo entstanden und von Anfang an gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 (wer keinen Fall hat, ist
  unbewacht) trägt DoD (2) und (3),
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) trägt
  die Nicht-Leerheit in Klausel (i), und
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3
  benennt den Gegenstand selbst.
- **Phase-Reife:** Phase 5 (Betrieb). Emitter, Träger und Voll-E2E-Sensor laufen; was fehlt, ist
  nicht Reife, sondern die Zusammenführung der Namensliste.
- **Evidenz-/Diskrepanz-Risiko:** niedrig und gemessen — die Zahl der Fundorte hängt an einem
  Kommando (§1). Das Restrisiko ist ein Urteils-Risiko: das Muster
  `planner.*architect.*implementer` findet nur Zeilen, die die Namen **nebeneinander** schreiben;
  eine über sechs Zeilen verteilte vierte Liste bliebe unentdeckt. Die Zahl ist damit eine
  **Untergrenze**, und der Lauf, der sie senkt, prüft das mit.
- **Reconciliation-Aufwand:** gering, aber nicht null — die Ableitungs-Richtung (Frage A) berührt
  die Paket-Grenze zwischen [`internal/emit`](../../../../internal/emit) und
  [`internal/span`](../../../../internal/span). Graduation-Trigger entfällt; die Sub-Area ist
  bereits GF.

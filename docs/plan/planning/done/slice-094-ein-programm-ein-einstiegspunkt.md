# Slice slice-094: Ein Programm, ein Einstiegspunkt — Schreiber und Auswertung werden Unterkommandos

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — der erste Slice der Welle. Er
geht der Emission voraus, weil
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 1 die
Emission an den Dogfood bindet.

**Bezug:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 2 *„Schreiber und Auswertung sind Unterkommandos desselben Trägers — und der Dogfood
fährt denselben Einstiegspunkt"*; Folgepflichten 1, 2, 3 und 8 sind die Schuld, die dieser Slice
begleicht),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — ihre Festlegung 6 nennt
zwei Eigenschaften des Emitters *nicht verhandelbar*: stdout leer, Exit-Code hart auf 0. Sie sind
der Gegenstand, der beim Umzug des Einstiegspunkts zerbrechen kann),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Accepted** — ihre Folgepflicht 1
*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"* ist nicht abgelöst, sondern
bindend; dieser Slice ist die Stelle, an der sie eingelöst wird),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (sie verlangt
Schreiber **und** Auswertung im Ziel — dieser Slice legt nichts ins Ziel, er stellt den
Einstiegspunkt her, den die späteren Slices dorthin tragen),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (der Emitter läuft am Hook
auf dem **Host**; die Plattform-Schalter des Baus hängen daran und dürfen beim Umbau nicht
verlorengehen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — jede Zahl unten wandert mit ihrem Bestand).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Dieses Repo führt für Erfassung und Auswertung genau ein Programm mit zwei Unterkommandos, und
sein Hook ruft denselben Einstiegspunkt, den ein Zielrepo später bekommt.**

Heute sind es drei Programme. `ls -1 cmd/` nennt `ai-harness-init`, `span-emit` und `span-report`
(die Zahl wandert mit dem Verzeichnis). Der Bau führt dafür zwei eigene Stufen —
`grep -nE '^FROM .* AS (span|report)$' Dockerfile` → **zwei** Zeilen —, und `make` ein Bau-Ziel,
das eine davon auf den Host holt (`grep -c '^span-emit-build:' Makefile` → **1**). Nach diesem
Slice bleibt **ein** Programm; die Konstruktion wird kleiner, nicht größer.

**Warum das vor der Emission steht und nicht danach.** Die Entscheidung bindet beides aneinander:
*„ohne diesen Nachzug emittierte der Beleg einen Einstiegspunkt, den der Dogfood nie ausführt"*.
Der Einstiegspunkt trägt die zwei Eigenschaften, die
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 nicht verhandelbar nennt —
und ein unerprobter Einstiegspunkt ist genau die Stelle, an der eine fail-open-Zusage **still**
bricht: ein Hook, der mit 2 endet, blockt den Tool-Call; ein Hook, der auf stdout schreibt,
entscheidet über Berechtigungen mit, statt zu beobachten. Beides fällt niemandem auf, solange
niemand es mutiert.

**Die Auswertung wechselt dabei vom Container auf den Host.** Sie läuft heute unter `make` im
Container über einem read-only gemounteten Bestand (`sed -n '251,254p' Makefile`). Im Ziel gibt es
keine Bau-Stufe, aus der sie laufen könnte, und ein Adopter soll für einen Bericht keinen Container
starten müssen. Das ist kein Nebeneffekt des Umbaus, sondern eine Festlegung
([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2) —
und sie macht einen heute im Bau stehenden Begründungs-Satz eigenständig falsch (DoD 3).

**Was dieser Slice ausdrücklich nicht tut.** Er legt **nichts** ins Ziel — kein Träger, kein
Wrapper, kein Hook-Eintrag, keine Rollen-Typen. Er ändert auch keine Erfassungs-Policy: Schema,
Redaktion, Ablageort und Strom bleiben, was
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) entschieden hat. Er verschiebt einen
**Einstiegspunkt** und sonst nichts.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt — und wo keines existiert,
steht das dabei (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Schreiber und Auswertung sind Unterkommandos eines Programms, und beide Bau-Stufen
      samt ihrem Bau-Ziel sind fort.** Der Hook dieses Repos ruft den neuen Einstiegspunkt; der
      Emitter läuft weiterhin am Hook auf dem **Host**, mit den Plattform-Schaltern des Baus
      ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) — ohne sie entstünde
      immer ein Linux-ELF und `make gates` scheiterte auf einem macOS-Host.
      **Rot für die Bau-Hälfte:** `make gates` — `span-check` fährt den Schreiber über eine
      synthetische Payload (`grep -n '^span-check:' -A 1 Makefile`); zeigt eine Prerequisite oder
      ein Rezept auf einen Einstiegspunkt, den es nicht mehr gibt, bricht der Lauf, bevor der
      Stempel fällt. Dazu ein `test/mutations/`-Fall mit `# verify: test-go`, der das
      Unterkommando-Routing bricht und das Rot erwartet.
      **Die Hook-Hälfte ist ungelistet** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und das steht
      hier statt einer Zusage. Die Kopplung ist gebaut —
      [`.claude/settings.json`](../../../../.claude/settings.json) nennt den Träger dreimal
      (`grep -c 'state/bin/ai-harness-init span-emit' .claude/settings.json` → **3**), und der
      Ablageort ist derselbe, den der Bau beliefert (`grep -n '^HOST_BIN :=' Makefile`) —, aber
      kein Gate liest sie. Die Eigenschaft, über die gezählt wird: *eine Zeile in einem
      Gate-Träger dieses Repos, die eine `settings.json` liest.* Kommando:
      `git grep -n 'settings\.json' -- Makefile 'harness/tools/*.sh' 'test/*.bats' '*.mk'` → **4**
      Zeilen, alle in `harness/tools/smoke.sh` und alle unter `$tmprepo`, also über der
      **emittierten** Datei eines Ziel-Repos. Wer die drei Einträge auf einen Pfad zurückstellt,
      den es nicht gibt, bekommt `make gates` mit Exit 0. Träger des fehlenden Wächters:
      [slice-078](../open/slice-078-verdrahtung-hat-waechter.md).
- [x] **(2) Die zwei fail-open-Zähne hängen am neuen Einstiegspunkt, nicht am alten.** Klemme
      entfernt ⇒ rot; stdout gebrochen ⇒ rot.
      **Rot:** `make mutate`. **Und der Punkt schuldet die Menge, weil der Sensor Adressen misst und
      der Gegenstand Fälle sind:** die Eigenschaft ist *ein Fall unter `test/mutations/`, dessen
      `# files:`-Zeile eine Datei des umgezogenen Bestands nennt*. Kommando und Zahl, beide
      mitwandernd:
      `grep -lE '^# files:.*cmd/ai-harness-init/span_(emit|report)' test/mutations/*.sh | wc -l`
      → **2**. Ihre **Richtung**: jeder dieser Fälle zeigt auf einen Pfad, den der Umbau bewegt,
      und wird beim Umzug entweder re-verankert oder er läuft ins Leere — ein Fall, der eine Datei
      mutiert, die es nicht mehr gibt, lässt seinen Wächter **nackt** zurück, ohne dass irgendetwas
      rot wird. Genau diese Klasse ist in diesem Repo bereits zweimal real eingetreten und steht als
      Roadmap-Kandidat *Sensor Wächter↔Fall*. Dass keiner nackt zurückbleibt, misst über den
      **ganzen** Bestand statt über die zwei:
      `sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sed '/^$/d' | sort -u | while read -r p; do [ -e "$p" ] || echo "FEHLT: $p"; done`
      → **leer**.
      **Eine Grenze, benannt statt verschwiegen:**
      [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 spricht die Klemme
      auch für die **Kindprozesse** des Trägers aus. Im Go-Träger hat diese Hälfte kein Objekt —
      der Schreiber-Pfad startet keinen Kindprozess
      (`grep -rn 'exec.Command\|"os/exec"' cmd/ai-harness-init/span_emit.go cmd/ai-harness-init/main.go internal/span/*.go | grep -v '_test.go' | wc -l`
      → **0**). Sie ist nicht unerfüllt; sie hat nichts zu erfüllen.
- [x] **(3) Keine lebende Zeile begründet noch die getrennte Konstruktion oder behauptet eine
      Eigenschaft, die Festlegung 2 aufhebt.** Der Sensor misst die **Adresse** (Datei, Zeile), der
      Gegenstand ist die **Aussage** — die Menge steht darum hier, aufgezählt und mit ihrer
      Richtung. Die Eigenschaft, über die gezählt wird: *eine Zeile in einem lebenden Bau- oder
      Quell-Artefakt, die das eigene Binär gegen ein Unterkommando begründet oder eine Eigenschaft
      der getrennten Konstruktion behauptet.* Suchhilfe, kein Kriterium — und die Menge ist die des
      **Vorzustands**, darum steht sie an einem Stand statt an einem wandernden Bestand:
      `git grep -niE 'kein[e]? subkommando|eigenes binary' 9bed2d7^ -- Dockerfile Makefile cmd/ internal/ harness/`
      → **4** Zeilen in **2** Dateien. Dieselbe Suche über den Arbeitsbaum
      (`grep -rniE 'kein[e]? subkommando|eigenes binary' Dockerfile Makefile cmd/ internal/ harness/`)
      → **0** Treffer, Exit 1; das ist die erfüllte Seite des Punktes.
      **(a)** [`Dockerfile`](../../../../Dockerfile), Emitter-Stufe: *„EIGENE Stage und EIGENES
      Binary, KEIN Subkommando von ai-harness-init: ob der EMITTIERTE Harness einen Emitter bekommt,
      entscheidet …"* — Richtung: die Entscheidung **ist gefallen**, die Begründung verliert ihren
      Gegenstand; zusätzlich nennt sie einen Slice als Entscheidungs-Ort, was ohnehin keine
      haltbare Adressierung ist.
      **(b)** `cmd/span-report/main.go`: *„EIGENES Binary,
      KEIN Subkommando von ai-harness-init"* — dieselbe Richtung, ebenfalls mit einem Slice als
      Entscheidungs-Ort. Die Datei verschwindet mit dem Umbau; der Satz darf nicht in das
      Unterkommando mitwandern.
      **(c)** [`Dockerfile`](../../../../Dockerfile), Auswertungs-Stufe: dieselbe Begründung
      **ohne** Slice-Nennung — der Fundort, den ein Sweep über das Erkennungsmerkmal *„nennt einen
      Slice"* verfehlte.
      **(d)** [`Dockerfile`](../../../../Dockerfile), Auswertungs-Stufe, zweiter Satz: *„anders als
      der Emitter laeuft die Auswertung nicht am Hook auf dem Host, sondern unter `make` IM
      Container"* und *„Ein Host-Binary waere ein Artefakt ohne Leser"* (`sed -n '106,109p'
      Dockerfile`) — Richtung: **eigenständig falsch**, nicht bloß gegenstandslos. Festlegung 2
      schickt die Auswertung auf den Host, und im Ziel bekommt sie genau einen Leser. Diese Zeile
      trägt das Erkennungsmerkmal aus (a)/(b) **nicht** und ist der zweite Fundort, vor dessen
      Verfehlen die Entscheidung ausdrücklich warnt.
      **Rot: kein Kommando, für keinen der vier Fundorte.** Für (a), (c) und (d) liest
      `make comment-claims` `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh` und
      `.claude/hooks/*.sh` (`sed -n '134p' Makefile`) — das `Dockerfile` steht nicht darunter —, und
      der Gate prüft ohnehin, ob ein **genannter Sensor existiert**, nicht ob eine Begründung noch
      gilt. Für (b) färbt auch der Bau nicht: `make build` ist `docker build --target build`
      (`sed -n '63,64p' Makefile`), und ein `docker build --target <X>` baut unbeteiligte Stages
      gar nicht erst — eine Referenz auf ein verschwundenes Verzeichnis in einer anderen Stage
      bleibt unbemerkt. Dieser Punkt ist damit im Sinne von
      [`AGENTS.md`](../../../../AGENTS.md) §3.6 **vollständig ungelistet**; er wird im Review
      gelesen, nicht gemessen, und das steht hier statt einer Zusage.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag. **Der Doku-Punkt
ist hier nicht leer:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 3
verlangt den Nachzug von
[`spec/spezifikation.md §5`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) —
deren Gegenstands-Satz nennt das Binär, das mit diesem Slice verschwindet.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`cmd/ai-harness-init`](../../../../cmd/ai-harness-init) — zwei Unterkommandos | update | Festlegung 2: ein Träger trägt beide, ohne dass ein zweites Artefakt entsteht |
| `cmd/span-emit` und `cmd/span-report` | refactor | die Klemme und der Bilanz-Einstieg wandern; die Kommentar-Köpfe wandern **nicht** mit (DoD 3) |
| [`Dockerfile`](../../../../Dockerfile) — die Stufen `span` und `report` | refactor | Festlegung 2: die zwei Stufen entfallen. Die Plattform-Schalter der Emitter-Stufe gehören in die verbleibende Stufe, sonst bricht [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) |
| [`Makefile`](../../../../Makefile) — `span-emit-build`, `span-check`, `span-report` | update | das Bau-Ziel verliert seinen Gegenstand; `span-report` verliert seinen Container und läuft auf dem Host |
| [`.claude/settings.json`](../../../../.claude/settings.json) und [`.claude/hooks`](../../../../.claude/hooks) | update | der Hook dieses Repos ruft denselben Einstiegspunkt wie das Ziel — die Sache, die Folgepflicht 1 verlangt |
| `test/mutations/` — die Fälle über `internal/span` und `internal/report` <!-- d-check:ignore (Bestand, wird re-verankert) --> | update | DoD (2): ein Fall, der eine bewegte Datei mutiert, lässt seinen Wächter sonst nackt zurück |
| [`spec/spezifikation.md §5`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) | update | Folgepflicht 3: der Gegenstands-Satz nennt ein Binär, das es nach diesem Slice nicht mehr gibt |

## 4. Trigger

**`open` → `next`:** der Trigger von [welle-12](../welle-12-erfassungsschicht-emittieren.md) ist
erfüllt — er ist es heute (dort §2, mit Kommandos). Dieser Slice wartet auf keinen anderen.
**`next` → `in-progress`:** WIP-Limit frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn der Umbau eine dritte Schicht
aufreißt — konkret: wenn die Zusammenlegung die Erfassungs-**Policy** berührt statt nur den
Einstiegspunkt (Schema, Redaktion, Ablageort, Strom). Dann ist der Gegenstand kein Umzug mehr,
sondern eine Änderung an [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), und die
gehört vor den Architect, nicht in diesen Slice. `in-progress` → `open`, wenn der Bau der
verbleibenden Stufe die Plattform-Schalter des Emitters nicht gleichzeitig mit denen des
Produkt-Binärs tragen kann — dann steht eine Bau-Entscheidung aus, die dieser Slice nicht
entscheidet. Beide Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` grün mit den
re-verankerten Fällen, `make full-smoke` grün, der Nachzug aus Folgepflicht 3 geschrieben,
Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der teuerste Fehler wäre ein stiller.** Der Emitter ist auf fail-open geklemmt; ein Umzug, der
  ihn kaputt macht, sieht im Betrieb **wie Erfolg aus** — keine Ausgabe, Exit 0, kein Span. Genau
  deshalb hängt DoD (1) an `span-check` (er prüft *vorhanden **und** funktionsfähig*) und nicht am
  bloßen Bau.
- **Ein Bau-Schalter ist leicht zu verlieren.** Die Emitter-Stufe trägt `TARGET_OS`/`TARGET_ARCH`,
  weil der Emitter am Hook auf dem **Host** läuft; die Auswertungs-Stufe trägt sie ausdrücklich
  nicht, weil sie im Container lief. Nach der Zusammenlegung läuft **beides** auf dem Host — die
  Schalter dürfen nicht der Auswertungs-Regel folgen. Ein `exec format error` auf macOS ist hier
  schon einmal als Review-Befund aufgetreten.
- **Der Umbau ist der Hauptaufwand, nicht der Bestand an Mutations-Fällen.** Zwei Fälle zeigen auf
  Pfade, die sich bewegen (DoD 2, mit Kommando); die übrigen mutieren `internal/span/` und
  `internal/report/`, und dort bewegt sich keine Datei
  (`git diff --diff-filter=RD --name-status 9bed2d7^ 9bed2d7 -- internal/span internal/report | wc -l`
  → **0**). Wer die zwei pauschal per Suchen-Ersetzen zieht, riskiert einen Fall, der zwar läuft,
  aber nichts mehr trifft — er wäre grün und leer. Die Gegenprobe ist der Zahnlos-Lauf: den
  Wächter entfernen, der Fall muss melden.
- **`make mutate` ist teuer.** Der Standard-Lauf liegt in der Größenordnung von
  `MUTATE_SECONDS=1128.69` (aus dem Protokoll von `slice-093`, fremdbelegt und als solche
  ausgewiesen). Wer nur die betroffenen Fälle fährt, sieht die Re-Verankerung, nicht die
  Rückwirkung auf den Rest.
- **Offen und nicht in diesem Slice:** ob der zusammengelegte Einstiegspunkt die Schwelle aus
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) hält. Das misst
  [slice-095](../done/slice-095-hook-aufschlag-gemessen.md); fällt die Messung negativ aus, ist die Antwort
  Alternative F — ein getrennter Einstiegspunkt —, und dieser Slice wird teilweise rückgebaut. Das
  ist der bewusst gewählte Preis dafür, dass die Messung erst nach dem Umbau möglich ist: gemessen
  werden kann nur, was läuft.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Dieses Repo führt für Erfassung und Auswertung **ein** Programm: `ls -1 cmd/ | wc -l`
→ **1**. Die zwei Bau-Stufen und ihr Bau-Ziel sind fort
(`grep -cE '^FROM .* AS (span|report)$' Dockerfile` → **0**, `grep -c '^span-emit-build:' Makefile`
→ **0**), an ihrer Stelle steht ein Ziel, das den Träger aus der vorhandenen `build`-Stufe auf den
Host holt (`grep -c '^host-bin:' Makefile` → **1**); der
[`Dockerfile`](../../../../Dockerfile) trägt noch `grep -c '^FROM ' Dockerfile` → **6** Stufen,
keine davon baut ein zweites Binär. Der Hook dieses Repos ruft denselben Einstiegspunkt, den ein
Zielrepo später bekommt (`grep -c 'state/bin/ai-harness-init span-emit' .claude/settings.json` →
**3**). Die zwei fail-open-Zähne hängen am neuen Einstiegspunkt
(`grep -lE '^# files:.*cmd/ai-harness-init/span_(emit|report)' test/mutations/*.sh | wc -l` →
**2**), und keine lebende Zeile begründet mehr die getrennte Konstruktion
(`grep -rniE 'kein[e]? subkommando|eigenes binary' Dockerfile Makefile cmd/ internal/ harness/`
→ **0** Treffer, Exit 1). Alle Zahlen wandern mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Auswertung wechselte dabei vom Container auf den Host**, und das war die Festlegung, nicht
ein Nebeneffekt: im Ziel gibt es keine Bau-Stufe, aus der sie laufen könnte. Der Preis steht in §6
dieser Datei und ist mit dem Umbau **nicht** kleiner geworden — die Plattform-Schalter, die vorher
nur die Emitter-Stufe trug, hängen jetzt an der Stufe, die beide Unterkommandos baut.

**Wo der Liefergegenstand liegt — und wo seine Herkunft nicht mehr steht.**
`git log --oneline --grep='slice-094' cc2ba89 | wc -l` zählt **8** Commits; der Stand gehört ins
Kommando, sonst wandert die Zahl mit jedem weiteren. Die Sache selbst liegt in **einem**:
`9bed2d7` (`git show --stat 9bed2d7` → `21 files changed, 354 insertions(+), 218 deletions(-)`).
`851b1ee`, `957c209` sind reine Lifecycle-Moves, `44e164a` und `d686787` die Link-Züge danach,
`ac5d7ef` und `cc2ba89` die Verdikte, `cf2e5ca` die Re-Verankerung von
[slice-071](../open/slice-071-bilanz-nennt-ihren-bestand.md).

**Die Herkunft von `cmd/ai-harness-init/span_report.go` ist über den neuen Pfad nicht mehr
auffindbar, und deshalb steht sie hier.** Umzug und Umschreiben liegen in demselben Commit; die
Ähnlichkeit fiel unter die Rename-Schwelle, und
[`AGENTS.md`](../../../../AGENTS.md) §3.3 beschreibt genau diesen Ausgang. Der Commit ist
veröffentlicht und wird nicht per Force-Push repariert — die Spur wird also erzählt statt
hergestellt:

- `git log --follow --oneline -- cmd/ai-harness-init/span_report.go` → **1** Commit (`9bed2d7`);
  dort bricht die Spur ab.
- `git log --oneline -- cmd/span-report/main.go` → **3** Commits: `9bed2d7`, `0f41911`
  (*slice-066: F-5 und F-6 behoben, Planner raeumt F-4 ab*) und `edf739d` (*slice-066: Token-Bilanz
  je Rolle — Code, Festlegung und drei Zaehne*). **Das ist die Adresse der Herkunft.**
- Kontrast, damit der Unterschied kein Eindruck bleibt:
  `git log --follow --oneline -- cmd/ai-harness-init/span_emit.go` → **5** Commits, bis `01fe699`
  (slice-059) zurück. Diese Schwester-Datei blieb über der Schwelle.

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(3) erfüllt, jeder mit gefahrenem Kommando.** Bestätigt im
   [Verifikations-Report](../../../reviews/2026-08-25-slice-094-verify.md) §2, samt vier Rot-Proben
   am `span-check` (fehlender · stummer · geschwätziger · mit 2 endender Träger) und einer
   Plattform-Probe, die das Mach-O-Binär am Host auf Exit 126 laufen lässt.
2. **`make gates` grün, `make mutate` grün mit den re-verankerten Fällen, `make full-smoke`
   grün.** Belege unten unter *Gates*.
3. **Der Nachzug aus [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
   Folgepflicht 3 geschrieben.** [`spec/spezifikation.md`
   §5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) nennt jetzt das
   Unterkommando statt des verschwundenen Binärs; dieselbe Korrektur lief über die zwei
   Gate-Tabellen in [`AGENTS.md`](../../../../AGENTS.md) §4 und
   [`harness/README.md`](../../../../harness/README.md), die ein nicht mehr existierendes Target
   führten — eine Tabellenzeile über einem toten Target ist der halluzinierte Gate aus
   [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
4. **Review konform (Modul 10).** [Code-Review](../../../reviews/2026-08-25-slice-094-review.md)
   (`ac5d7ef`): **merge-blockierend**, `grep -c '^### F-' docs/reviews/2026-08-25-slice-094-review.md`
   → **2** — ein HIGH an Hard Rule 3.3 (oben aufgelöst), ein MEDIUM an einem Selbstbericht
   (erledigt in `cf2e5ca`).
5. **Verifikation (Modul 11).** [Bericht](../../../reviews/2026-08-25-slice-094-verify.md)
   (`cc2ba89`): **frei für die Closure**,
   `grep -c '^### V-' docs/reviews/2026-08-25-slice-094-verify.md` → **6** Befunde, keiner
   blockierend, keiner am Gebauten — alle an einer Zusage oder einem Kommentar.
6. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Was anders lief als geplant.** Der Schnitt hielt den **Bestand an Mutations-Fällen** für den
Hauptaufwand und den Umbau für die kleinere Hälfte. Es war umgekehrt, und der Grund ist ein
Mess-Fehler im Schnitt selbst: gezählt wurde über *Fälle, die eine Zeichenkette führen*
(`grep -l 'internal/span' …`), gebraucht wurde *Fälle, deren `# files:`-Zeile eine bewegte Datei
nennt*. Die erste Menge zählt **35**
(`git grep -lE '^# files:.*(internal/span|internal/report)' 9bed2d7^ -- test/mutations/ | wc -l`),
und keine ihrer Zieldateien bewegt sich; die zweite zählt **2**. §2 und §6 tragen jetzt die zweite.
**Die zweite Abweichung liegt in derselben Klasse:** DoD (3) nannte für einen seiner vier Fundorte
`make build` als Rot. Ein `docker build --target <X>` baut unbeteiligte Stages nicht — gemessen an
einem Wegwerf-`Dockerfile` mit defekter, unbeteiligter Stage: `--target good` → Exit 0,
`--target broken` → Exit 1. Der Punkt ist damit vollständig ungelistet, nicht teilweise.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Die Hook-Hälfte von DoD (1) ist unbewacht.** `make gates` liest die
  [`.claude/settings.json`](../../../../.claude/settings.json) dieses Repos an keiner Stelle; die
  vier Zeilen, die eine `settings.json` lesen, liegen sämtlich in `harness/tools/smoke.sh` unter
  `$tmprepo` und gelten dem **emittierten** Ziel (Kommando in DoD 1). Gesehen wurde die Lücke, indem
  sie *nicht* rot wurde: drei Hook-Einträge in einer Kopie außerhalb des Repos auf den alten,
  gelöschten Pfad zurückgestellt → `make gates` Exit 0, mit identischen Zahlen zum ungestörten Lauf.
- **Die Position des Unterkommando-Zweigs ist nicht bewachbar.** Der Zweig steht als erste
  Anweisung von `main()`, und das ist tragend: was vor ihm läge, deckt seine Klemme nicht. Der Fall
  `test/mutations/154-unterkommando-routing-vertauscht.sh` bewacht das **Routing**; verschöbe jemand
  den Zweig hinter `os.Getwd()`, bliebe jeder Test grün, weil `os.Getwd()` in keinem Lauf
  fehlschlägt. Der Kommentar an der Stelle sagt das heute nicht — Träger unten.
- **`recover()` fängt keine Go-*fatal errors*.** Sie sind im Schreiber-Pfad nicht erreichbar
  (die einzige unbegrenzte Quelle ist gedeckelt, es gibt weder Goroutine noch Kanal), aber das ist
  eine Grenze und keine Abdeckung.
- **Ob der zusammengelegte Einstiegspunkt die Schwelle aus
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) hält, ist ungemessen.** Das war schon
  bei Schnitt so gewollt (§6) und ist der Gegenstand von
  [slice-095](../done/slice-095-hook-aufschlag-gemessen.md); fällt die Messung negativ aus, wird
  dieser Slice teilweise rückgebaut.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Ein Rot-Kommando deckt die Zusage, an der es steht — oder die Hälfte, die es nicht erreicht, wird
ausgesprochen.**

**Was [`AGENTS.md`](../../../../AGENTS.md) §3.6 heute leistet und was nicht.** Sie verlangt, dass
benannt ist, *was passieren müsste, damit die Zusage bricht*, und dass das **einmal** rot gesehen
wurde. Eine Zusage mit einem *und* hat aber zwei Bruchstellen. Wer eine davon rot sieht, hat die
Regel **formal erfüllt**; die andere Hälfte ist ungelistet, ohne dass irgendwo etwas fehlt. Genau
das ist hier zweimal passiert: DoD (1) sagt *Unterkommandos **und** der Hook ruft den neuen
Einstiegspunkt* zu und nennt ein Rot, das die Bau-Hälfte erreicht; DoD (3) nennt für einen von vier
Fundorten einen Sensor, der ihn nicht erreicht. Beide in einem Plan, der für die anderen drei
Fundorte ausdrücklich *„kein Kommando färbt rot"* schreibt — die Klasse war dem Schnitt bekannt und
ist ihm trotzdem zweimal durchgegangen.

**Die Prüfmethode, die beides fand, ist die Regel in Handlungsform.** Nicht *„läuft der Sensor?"*,
sondern *„ich breche die Zusage — wird etwas rot?"*. Beim ersten Mal lautete die Antwort **nein**,
bei Exit 0 und identischen Zahlen; beim zweiten Mal brauchte es ein Wegwerf-`Dockerfile`, um zu
sehen, dass das genannte Kommando den Fundort gar nicht anfasst. Beides ist billig, und beides
findet nur, wer die Zusage bricht statt den Sensor zu starten.

**Träger: der Architect, an [`AGENTS.md`](../../../../AGENTS.md) §3.6**
([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1,
[`AGENTS.md`](../../../../AGENTS.md) §3.8). Ein ADR braucht die Schärfung nicht: sie **hebt** eine
Beleg-Anforderung an und senkt keine Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.5). Ein
neuer Termin ebenfalls nicht — [slice-093](../done/slice-093-mutations-treiber-erreicht-full-smoke.md)
hat denselben Adressaten bereits mit einem fälligen Auflösungs-Trigger belegt.

**Und der Eskalations-Trigger jener Closure hätte hier feuern müssen, tat es aber nicht — das ist
der zweite Teil des Eintrags.** Er lautete dort: *ein zweiter Slice, dessen Rot-Rezept eine
Bedingung statt eines Wächters benennt.* Hier benennt das Rezept keinen Bedingungs-Teil, sondern
einen **Wächter, dessen Reichweite kleiner ist als die Zusage** — dieselbe Eigenschaft (*Zusage und
Rot-Rezept decken verschiedene Mengen*), eine andere Gestalt. Ein Trigger, der auf die **Gestalt**
geschnitten ist statt auf die **Eigenschaft**, feuert am zweiten Fall vorbei; er gehört im selben
Architect-Lauf nachgezogen.

**Was die Reparatur toter Verweise ab jetzt heißt: die Adresse wird ersetzt, nicht die Klammer
entfernt.** Wird `[label](pfad)` zu `` `pfad` ``, ist der Doku-Gate wieder grün und die Referenz
weiterhin tot — der `links`-Modul greift auf die Klammer-Form, und der über `docs/` und `harness/`
aktive `codepaths`-Modul (`sed -n '/^codepaths:/,/^ *roots:/p' .d-check.yml`) meldet diese Zeilen
nicht: `make docs-check` → `372 Datei(en) geprüft, 0 Befund(e)`, während unter der Wurzel
`harness/` weiterhin ein Pfad als Inline-Code steht, den es nicht gibt
(`grep -n 'cmd/span-emit' harness/conventions.md` → **1** Zeile; `ls -d cmd/span-emit` → Exit 2).
Wo keine neue Adresse existiert, gehört
die **Aussage** umgeschrieben; wo eine existiert, gehört sie eingesetzt. Ein Sensor für diese Form
ist hier **nicht** vergeben, und der Grund ist die Abgrenzung: Inline-Code trägt in diesen
Artefakten auch Kommandos, Feldnamen, Marker und `make`-Ziele; ein Wächter, der Pfade darunter
erkennen soll, braucht erst ein Kriterium und dann ein Gate — die Frage gehört an den Lauf, der den
d-check-Pin bewegt, nicht in diesen Slice.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die Kopplung `.claude/settings.json` ↔ `HOST_BIN` ist unbewacht; das Gegenbeispiel ist rot gesehen worden, indem es grün blieb | **[slice-078](../open/slice-078-verdrahtung-hat-waechter.md)** — sein DoD (1) fordert genau diesen Wächter samt der Richtung *„Kommando umgebogen"*. Die gemessene Kopplung und ihr Gegenbeispiel stehen jetzt in **seiner** Datei, nicht nur hier |
| Der Positions-Kommentar am Unterkommando-Zweig in `cmd/ai-harness-init/main.go` nennt Fall 154 als Wächter; der bewacht das Routing, nicht die Position | **[slice-095](../done/slice-095-hook-aufschlag-gemessen.md)**, als Kommentar-Nachzug nach [`AGENTS.md`](../../../../AGENTS.md) §3.7 — er fährt genau diesen Einstiegspunkt. Der Satz ist **neu** mit diesem Slice und damit gebunden, kein Bestand. Die Position ist nicht bewachbar; sie gehört als Grenze benannt, wie `harness/tools/span-check.sh` es zweimal vormacht |
| Der Kopf von `span-report` im [`Makefile`](../../../../Makefile) sagt *„fuer einen Bericht soll niemand einen Container starten muessen"*, während das Rezept über `host-bin` einen startet — der Satz gilt dem Ziel, nicht dem Dogfood | **[slice-095](../done/slice-095-hook-aufschlag-gemessen.md)**, derselbe Nachzug |
| [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) nennt `cmd/span-emit/` als Ort des kompilierten Harness-Tools | **Architect** — der Adaptions-Block gehört ihm ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Es ist eine Adresse, keine Begründung der getrennten Konstruktion; DoD (3) trifft sie nicht |
| `docs/plan/planning/in-progress/roadmap.md` nennt `span-emit-build` in einer **datierten** Drift-Beobachtung | **kein Träger, und das ist entschieden** — eine datierte Beobachtung hält den Stand ihres Tages fest, wie [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich es für Zeitdokumente vorsieht |
| Ein verwaistes Binär unter dem alten Namen im Zustands-Bereich derer, die das alte Bau-Ziel gefahren haben | **kein Träger, und das ist entschieden** — der Ort ist gitignoriert (`git check-ignore -v .harness/state/bin` → `.gitignore:5:.harness/state/`), ein erneutes `make host-bin` stellt den Stand her, und kein Rezept und kein Hook liest den alten Namen mehr |
| Die zwei Laufzeit-Zahlen des Umsetzungs-Commits (`MUTATE_SECONDS`, `FULLSMOKE_SECONDS`) sind nicht unabhängig bestätigt | **kein Träger, und das ist entschieden** — die Verifikation hat denselben Lauf mit eigenen Werten gefahren; die Zusagen hängen an keiner der beiden Zahlen |

**Folge-Slices: keine neuen `open/`-Einträge.** Jeder offene Posten oben hat einen bestehenden
Träger oder eine begründete Ablehnung; ein neuer Schnitt entstünde nur, wenn die Messung aus
[slice-095](../done/slice-095-hook-aufschlag-gemessen.md) negativ ausfällt — dann ist die Antwort
Alternative F und damit ein anderer Träger, keine Fortsetzung dieses Slice.

**Gates.** Die [Verifikation](../../../reviews/2026-08-25-slice-094-verify.md) hat sie über dem
Baum bei `cf2e5ca` selbst gefahren, die Exit-Codes getrennt erhoben: `make gates` **Exit 0**
(`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 371 Datei(en) geprüft, 0 Befund(e)`, bats
`1..144` mit **144** `ok` und **0** `not ok`, golangci-lint `0 issues.`, sieben Go-Pakete `ok`,
`comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check: Traeger vorhanden, span-emit hat
einen Span geschrieben, Ablageort git-ignoriert`), `make mutate` **Exit 0** mit
`mutate: 147 ok, 0 Befund(e)` und den drei geschuldeten Fällen (`107`, `112`, `154`) als `ok`,
`make full-smoke` **Exit 0**. Der Stempel band den Lauf an den Baum, nicht an eine Erinnerung:
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` waren danach
byte-gleich, und `record-gates` schreibt ihn nur als **letzter** Prerequisite grüner Gates
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)).
Die Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert.
Diese Notiz, der `done/`-Move und der Link-Zug danach verschieben den Stempel erneut; der Lauf, der
ihn wieder bindet, gehört zu ihnen.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`test/`, der Bau (`Dockerfile`/`Makefile`) und `.claude/` gehören zum Greenfield-Bestand; der Modus
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

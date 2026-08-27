# Slice slice-096: Der Träger liegt im Ziel — oder es liegt begründet nichts

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](welle-12-erfassungsschicht-emittieren.md) — der Wertträger der Welle. Er
läuft nach [slice-095](../done/slice-095-hook-aufschlag-gemessen.md), weil dessen Ausgang den Träger
bestätigt oder ihn durch einen anderen ersetzt.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (**Rang 1**,
abnahmebindend — *„Das gebootstrappte Repo schreibt je Werkzeug-Aufruf seiner Agenten-Läufe einen
Span in einen gitignorierten Zustands-Bereich"*; dieser Slice erfüllt davon Happy Path,
Reproduzierbarkeit, Netzlosigkeit und *Kein Halluzinat*),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Zusage, deren Gegenbeispiel DoD (2) rot sieht: *„kann der Träger nicht emittiert werden, wird
begründet **nichts** abgelegt — kein Hook, der auf ein fehlendes Programm zeigt"*),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (*dieselbe Tool-Version →
derselbe Träger* — bei einer Kopie eine Konstruktions-Eigenschaft, die niemand herstellen und
darum niemand brechen muss),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das Ziel bleibt
über `bash + git + docker` geschlossen — kein Netz, kein Bauschritt, kein zweiter Vertriebskanal),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (der Träger *ist* die
Matrix; er verdoppelt sie nicht),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Schranke, an der ein ziel-seitiger Anwesenheits-Wächter scheitert und an der beide Zweige
gemessen werden),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 1 wählt den Träger, Festlegung 4 den Aufruf-Ort und die Idempotenz-Klassen,
Festlegung 5 koppelt Träger, Wrapper und Hook-Eintrag und schließt den ziel-seitigen Wächter aus;
Folgepflicht 4 begleicht dieser Slice ganz, von Folgepflicht 6 die zwei Anwesenheits-Wächter über
Träger und Wrapper — die über den Rollen-Typen und der Feldliste bringen
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md) und
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) mit),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (**Accepted** — Festlegung 1 gibt die Phase,
Festlegung 3 die Idempotenz-Klassifikation, Festlegung 5 den Checkpoint, durch den ein Re-Lauf den
Träger heilt),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — ihre Festlegungen 1–4
und 6 gelten im Ziel unverändert; dieser Slice ändert an ihnen nichts, er trägt sie hinüber),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(der inhaltsbasierte Gate-Nachweis — er listet mit `--exclude-standard` und bleibt vom wachsenden
Span-Bestand des Ziels unberührt),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(sie entscheidet die **Schärfe** emittierter Prüfbereiche, nicht die **Aufhängung** eines Trägers —
die Abgrenzung, an der DoD (3) hängt).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Ein frisch gebootstrapptes Zielrepo trägt das Produkt-Binär in seinem gitignorierten
Zustands-Bereich, einen committeten Hook-Wrapper und den Hook-Eintrag, der auf ihn zeigt — und
schreibt damit je Werkzeug-Aufruf einen Span; scheitert die Ablage, liegt keines der drei, der
Bootstrap nennt den Grund und endet erfolgreich.**

**Der Oder-Zweig ist kein Rand, sondern die halbe Zusage.** Zwei Fehlerbilder sind zu trennen, und
sie haben verschiedene Adressaten. *(a) Die Emission scheitert:* dann wird **weder** Träger
**noch** Wrapper **noch** Hook-Eintrag geschrieben, und das Ziel ist ohne Erfassung vollständig und
sein `make gates` grün. *(b) Der Träger fehlt später:* er liegt gitignored, ein frischer Klon hat
ihn nicht, ein Aufräum-Lauf kann ihn entfernen. Zeigte die Konfiguration direkt auf ihn, wäre genau
das *„ein Hook, der auf ein fehlendes Programm zeigt"*, nur zeitversetzt — deshalb nennt sie einen
**committeten Wrapper**, und der schweigt und endet erfolgreich, wenn der Träger fehlt.

**Warum Träger, Wrapper und Hook-Eintrag ein Slice sind und nicht drei.** Sie sind **eine**
Entscheidung ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 5): der Hook-Eintrag entsteht **nur** mit dem Träger. Drei Slices wären drei
Emissionsstellen für einen Vertrag — also drei Stellen, an denen er zerfällt, und zwei
Zwischenstände, in denen das Ziel genau den Hook trägt, den
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
ausschließt. Der Schnitt folgt hier dem Lieferwert, nicht der Datei-Zahl.

**Was im Ziel schon liegt und diesen Slice trägt — gelesen, nicht vermutet.** Der Ablageort
existiert: die Durchsetzungs-Emission legt `.harness/.gitignore` mit dem Eintrag `state/`
(`cat internal/emit/templates/enforce/gitignore`), womit die Auflage aus
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 3 — Ablage außerhalb des
versionierten Baums — im Ziel bereits erfüllt ist. Der Hook-Anker existiert: die emittierte
`.claude/settings.json` verdrahtet ihre Hooks über `"$CLAUDE_PROJECT_DIR"`, also repo-relativ. Und
das Präfix, unter dem der Wrapper landet, führt Einträge derselben Bauart — committet abgelegte
Hook-Skripte der Durchsetzungs-Emission, ihrer **3**
(`grep -c '".claude/hooks/' internal/emit/enforce.go`, mitwandernd), darunter der Wrapper. Dieser
Slice legt nichts an, was es nicht ohnehin gibt — er kopiert ein Bild, das gerade läuft.

**Was der Lauf belegt und was nicht.** Belegt ist die Lauffähigkeit auf dem Host, der den Bootstrap
**ausführt**. Gebraucht wird sie dort, wo die **Hooks** laufen, und dass beides derselbe Ort ist,
steht als Annahme (a) mit Re-Evaluierungs-Trigger — nicht als Beweis. Dieser Slice schließt die
Lücke nicht und behauptet nicht, sie zu schließen; er baut den Fall, in dem sie sich zeigt,
sichtbar statt still: ein Träger, der sich nicht ausführen lässt, ist der ablesbare Ausgang des
Triggers.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Der Träger schreibt im Ziel — in beiden Bootstrap-Varianten.** Im frisch
      gebootstrappten tmp-Repo erzeugt der abgelegte Träger aus einer synthetischen Payload einen
      Span mit voller Pflicht-Spalte, und `git check-ignore` im Ziel bestätigt dessen Ablageort —
      der Nachbau dessen, was `span-check` hier für den Dogfood leistet. Die **Varianten-Klammer**
      gehört dazu: die Erfassung ist sprach-agnostisch, ein Zahn in nur einer Variante belegte das
      nicht.
      **Rot:** `make full-smoke` über `tmprepo` **und** `tmprepo_doc`
      ([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)); dazu ein
      `test/mutations/`-Fall mit `# verify: full-smoke`. Der Treiber führt diesen Modus
      (`sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'`
      → **7** Arme, mitwandernd), der Fall läuft also im Standard-`make mutate` mit.
- [x] **(2) Die [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Zusage
      steht mit ihrem rot gesehenen Gegenbeispiel.** Scheitert die Platzierung des Trägers, trägt
      die emittierte `.claude/settings.json` **keinen** Erfassungs-Hook, es liegt **kein** Wrapper,
      der Bootstrap nennt den Grund und endet erfolgreich, und `make gates` des Ziels ist grün.
      **Rot zu sehen ist:** die Kopplung aufheben — den Hook-Eintrag unbedingt schreiben —, dann
      muss der Wächter fallen. **Ohne dieses Rot ist die Zusage eine Absicht**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      **Rot:** `make test` (ein Go-Wächter über dem Fehlerzweig der Emission) und `make mutate`
      (der Fall, der die Kopplung aufhebt, mit `# verify: test-go`).
- [x] **(3) Anwesenheits-Wächter für Träger und Wrapper — die Bedingung steht im Wächter, nicht in
      seinem Namen.** Nach einem Bootstrap, dessen Träger-Platzierung durchläuft, liegen beide im
      Ziel; im Zweig aus Festlegung 5(a) fehlen sie **zulässig**, und ein unbedingt formulierter
      Wächter fiele dort — gegen DoD (2), der genau dieses Ausbleiben zusagt. Die Prüfung hat die
      Gestalt des bestehenden Abwesenheits-Wächters in
      [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go), nur umgekehrt.
      **Der Sensor misst die Adresse, der Gegenstand ist die Aussage — darum die Aussagen-Menge,
      aufgezählt und mit ihrer Richtung.** Die Eigenschaft: *ein Artefakt, dessen Anwesenheit im
      Ziel dieser Slice zusagt*. **(a)** der Träger im gitignorierten Zustands-Bereich — Richtung:
      steht in **keiner** Emit-Pfad-Liste, weil er gitignored ist; seine Adresse ist der Ablageort,
      und geprüft wird er am gebootstrappten Ziel, nicht an einer Liste. **(b)** der Hook-Wrapper
      unter `.claude/hooks/` — Richtung: er wächst in die Liste hinein, die das Präfix führt,
      ihrer **3** (`grep -c '".claude/hooks/' internal/emit/enforce.go`, mitwandernd); die Adresse ist
      das **Präfix samt Bestand**, nie ein geratener Dateiname, denn eine Stichprobe auf einen
      Namen, den der Emit nie schreibt, kann unter keiner Mutation rot werden. **(c)** der
      Hook-Eintrag in `.claude/settings.json` — Richtung: kein neuer Pfad, sondern ein **Block in
      einer bestehenden Datei**; seine Anwesenheit ist eine Inhalts-, keine Existenz-Aussage, und
      ein Existenz-Wächter darüber wäre dauerhaft grün. **Nicht in dieser Menge:** die Rollen-Typen
      (unbedingt, [slice-097](../done/slice-097-rollen-typen-gehen-mit.md)) und die Feldliste (teilt den
      Zweig des Trägers, [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md)) — sie
      bringen ihre Wächter selbst mit.
      **Rot:** `make test` plus je ein `test/mutations/`-Fall mit `# verify: test-go`, der das
      Artefakt probeweise weglässt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag. **Der Doku-Punkt
ist hier nicht leer:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 4
verlangt den Nachzug von
[`spec/architecture.md §5`](../../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume) —
die Emissions-Mechanik legt hier erstmals ein **ausführbares** Artefakt ab, und die Klassen-Tabelle
bekommt eine Zeile außerhalb des versionierten Baums.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit`](../../../../internal/emit) — die Selbst-Kopie des laufenden Bildes in den gitignorierten Zustands-Bereich des Ziels | neu | Festlegung 1 und 4: der Aufruf-Ort ist die Emission der Durchsetzungs-Mechanik, mit der sich die Erfassung die Hook-Konfiguration teilt |
| [`internal/emit/enforce.go`](../../../../internal/emit/enforce.go) — Wrapper-Pfad und Hook-Eintrag, **gekoppelt** an den Ausgang der Ablage | update | Festlegung 5: eine Entscheidung, eine Emissionsstelle. Ein Re-Lauf, der den Block nicht setzen kann, **entfernt** ihn — die Konfiguration beschreibt die Wirklichkeit |
| `internal/emit/templates/enforce/` — der committete Hook-Wrapper <!-- d-check:ignore (geplante Datei) --> | neu | Festlegung 5(b): er schweigt und endet erfolgreich, wenn der Träger fehlt — die Betriebsart, die [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 ohnehin verlangt |
| [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) — die bedingten Anwesenheits-Wächter und der Fehlerzweig-Wächter | update | DoD (2) und (3); Folgepflicht 6: an die Stelle der drei Abwesenheits-Wächter treten Anwesenheits-Wächter — ein Wächter über einer Abwesenheit, die es nicht mehr geben soll, ist kein halber, sondern ein falscher |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD (1): der schreibende Träger und `git check-ignore` im Ziel, über beide Varianten |
| `test/mutations/` — Fälle für DoD (1), (2) und (3) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |
| [`spec/architecture.md §5`](../../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume) | update | Folgepflicht 4: erstmals ein ausführbares Artefakt und eine Klasse außerhalb des versionierten Baums |

## 4. Trigger

**`open` → `next`:** [slice-095](../done/slice-095-hook-aufschlag-gemessen.md) liegt in `done/` **und**
seine Messung hält die Schwelle aus
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md). Beide Hälften sind ohne Rückfrage
beurteilbar: die Plan-Datei liegt in `done/`, und die Zahl steht dort mit ihrem Kommando neben der
Schwelle. **Warum die zweite Hälfte dazugehört:** reißt die Schwelle, ist der Träger dieses Slice
der falsche — die Antwort ist dann Alternative F, und die zu bauen heißt, hier anderes zu kopieren.
**`next` → `in-progress`:** WIP-Limit frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn die Kopplung aus Festlegung 5 mehr
als eine Emissionsstelle braucht — dann trägt der Slice zwei Verträge statt einen und zerfällt
nach Zweig, nicht nach Artefakt. `in-progress` → `open`, wenn der Ablageort im Ziel die Annahme (b)
nicht hergibt (Zustands-Bereich nicht beschreibbar oder nicht gitignored) — dann sind Träger-Ort
**und** Ablageort gemeinsam neu zu wählen, und das ist eine Entscheidung, kein Slice. Beide
Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün über beide
Varianten, `make mutate` grün mit den neuen Fällen, der Nachzug aus Folgepflicht 4 geschrieben,
Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Fehlerzweig ist schwerer zu bauen als der Gelingens-Zweig.** DoD (2) verlangt, dass die
  Ablage **scheitern** kann, ohne dass der Bootstrap scheitert — und dass der Test dieses Scheitern
  herstellen kann. Ein Fehlerzweig, den kein Test erreicht, ist derselbe unerprobte Pfad, an dem
  fail-open-Zusagen still brechen.
- **Die Bytes hängen erstmals an einem Laufzeit-Ausgang, und das ist gewollt.** Zwei Läufe
  derselben Tool-Version erzeugen verschiedene `.claude/settings.json`, wenn die Ablage beim einen
  gelingt und beim anderen nicht.
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bindet die Bytes damit
  an dieselbe Version **und** denselben Ausgang, nicht an die Version allein — wer den Idempotenz-
  oder Reproduzierbarkeits-Test ohne diese Bedingung schreibt, baut einen Wächter, der zufällig
  grün ist.
- **Der abgelegte Träger kann ein Repo bootstrappen.** Der Zugewinn eines konstruktiven
  Ausschlusses wäre gering — wer den Träger startet, hat das Binär ohnehin —, aber er ist **kein
  Nichts**; er ist der Gegenposten, den Alternative F geboten hätte, und er steht hier als
  bewusster Preis, nicht als Versehen.
- **Ein frischer Klon des Adopter-Repos erfasst still nichts.** Der Träger liegt gitignored. Die
  Grenze ist **benannt, nicht geschlossen**: ein ziel-seitiger Anwesenheits-Wächter ist
  ausgeschlossen, weil er jeden Klon out-of-the-box rot machte und
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) bräche. Sichtbar wird
  der Zustand beim **Leser** ([slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)), nicht beim
  Schreiber; wiederhergestellt wird der Träger durch einen erneuten Tool-Lauf.
- **Der `span-check`-Wächter dieses Repos geht nicht mit.** Hier heilt ihn ein Bau, im Ziel könnte
  ihn nichts heilen. Wer ihn mitgibt, baut den Klon-rot-Fall, den der vorige Punkt ausschließt.
- **Annahme (a) bleibt offen, und dieser Slice schließt sie nicht.** Fallen Bootstrap-Host und
  Hook-Plattform auseinander, fällt der tragende Grund von Festlegung 1 — und zwar für Alternative
  F ebenso. Der Ausgang ist dann die Plattform-Frage, nicht dieser Slice; **Alternative H** macht
  sie stellbar und verlangt eine Plattform-Angabe, die
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) heute in keinem seiner
  Akzeptanzkriterien kennt.
- **Berührung mit [slice-092](../open/slice-092-traeger-inventur.md), falls jener zuerst liegt.** Sein
  Wächter färbt rot, sobald das Präfix `.claude/hooks/` über seinen gepinnten Bestand hinauswächst,
  während seine Inventur-Zelle noch Abwesenheit behauptet. Das ist **gewollte Reibung**: sie
  erzwingt den Blick auf die Inventur. Wer sie für einen Fehlalarm hält, hat den Wächter
  missverstanden.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Ein frisch gebootstrapptes Ziel trägt drei Dinge, die zusammen entstehen oder gar
nicht: das laufende Produkt-Binär unter `.harness/state/bin/`, den committeten Wrapper
`.claude/hooks/span-emit.sh` und den Hook-Eintrag in `.claude/settings.json`, der auf den
**Wrapper** zeigt und nicht auf den Träger. Über diesen Weg schreibt ein Werkzeug-Aufruf einen Span
mit voller Pflicht-Spalte an einen Ort, den `git check-ignore` **im Ziel** bestätigt — gefahren in
beiden Bootstrap-Varianten (`grep -c 'Traeger + Wrapper + Hook-Eintrag liegen im Ziel' <full-smoke-Log>`
→ **2**, je einmal `golang` und `sprachlos`). Scheitert die Ablage, liegt keines der drei, der
Grund steht auf `stderr`, und `Enforce` liefert `nil`. Die Kopplung ist eine Code-Zeile und keine
Absprache: `captured := captureErr == nil`, `enforceContent(f.src, captured)` und
`if !captured { return nil }` in [`internal/emit/enforce.go`](../../../../internal/emit/enforce.go)
— **eine** Emissionsstelle, wie
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5 sie
verlangt. Die Eigenschaft, über die unten gezählt wird: **ein committet abgelegtes Hook-Skript der
Durchsetzungs-Emission** — ihrer **3**
(`grep -c '".claude/hooks/' internal/emit/enforce.go`); und **eine Datei in `test/mutations/`** —
ihrer **155** (`ls test/mutations/*.sh | wc -l`), acht davon aus diesem Slice. Alle Zahlen wandern
mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Oder-Zweig ist zu drei Vierteln gemessen und zu einem Viertel begründet.** DoD (2) trägt vier
Teilzusagen. Drei haben ihr Rot: **kein Hook-Eintrag**
([`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go)`:438`), **kein
Wrapper** (`:431`), **der Grund steht da und der Bootstrap endet erfolgreich** (`:407` und `:413`)
— gefallen unter `test/mutations/155`, dem im Plan wörtlich benannten Gegenbeispiel, und unter
`156`. Die vierte, *„und `make gates` des Ziels ist grün"*, ist **konstruktiv belegt, nicht
gelaufen**: im Fehlerzweig ist das Ziel dateigleich mit einem Ziel vor diesem Slice, weil
`captureFiles()` nicht in `EnforcePaths()` steht, die emittierte
[`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) nur
`modules: [links, anchors]` führt und `span-check` nach
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(c)
nicht mitgeht. Die drei Prämissen sind einzeln geprüft
(`grep -rn 'EnforcePaths' --include=*.go .`, `grep -n 'modules' internal/emit/templates/d-check.yml`),
das Argument trägt — ein **Lauf** ist es nicht, und darum steht es hier als Grenze statt als
Messung. Träger unten.

**Die Deckung eines Falls steht nicht in seinem Kopf.** Aus den `# expect:`-Köpfen der Fälle
`155`–`158` folgte im Code-Review, für die Träger- **und** die Wrapper-Abwesenheit im Fehlerzweig
gebe es keinen Fall, und ein verschobener `if !captured`-Guard bliebe unentdeckt. Gemessen ist die
**Klasse** richtig und die **Größe** falsch:

- **Der Guard-Eingriff wird gefangen.** Entfernt man `if !captured { return nil }`, fällt
  `TestEnforce_KeineErfassungOhneTraeger` an `:431`.
- **Die Wrapper-Abwesenheit ist gedeckt, nur nicht deklariert.** Fall `156` macht `captured` im
  Fehlerzweig wahr und färbt `:413`, `:431` **und** `:438` rot; sein Kopf nennt den
  Erfolgszweig-Wächter.
- **Übrig bleibt genau eine Assertion ohne eigenen Fall:** `:425`, die Träger-Abwesenheit im
  Fehlerzweig. Sie hat Zähne — `carrierDir` von `.harness/state/bin` auf `.harness/state/carrier`
  umbenannt färbt sie rot. Ein sauberer Fall dafür ist schwer zu schneiden, weil jeder Eingriff,
  der den Blocker umgeht, `TestCarrierPath_NimmtDieEndungMit` mitreißt. Träger unten.

**Ein `# expect:`-Kopf ist eine Untergrenze über die Wächter-Menge, an jedem der drei Fälle
einzeln gemessen.** Jeder Fall wurde in einer Kopie außerhalb des Repos angewendet
(`git archive HEAD | tar -x -C <kopie>`, Fall angewendet, `make -C <kopie> test-go`); der
Arbeitsbaum blieb dabei unberührt (`git status --short` leer):

| Fall | Kopf nennt | gefallen ist |
|---|---|---|
| `156` | `TestEnforce_ErfassungLiegtMitDemTraeger` | dieser an `:347` **und** `TestEnforce_KeineErfassungOhneTraeger` an `:413`, `:431`, `:438` |
| `157` | `TestEnforce_ErfassungLiegtMitDemTraeger` | dieser an `:359` **und** `TestEnforce_WrapperSuchtDenAblageort` an `:467` |
| `158` | `TestEnforce_ErfassungLiegtMitDemTraeger` | dieser an `:373`, sonst nichts |

**Und nicht jedes zusätzliche Rot ist zusätzliche Deckung.** Bei `156` trifft es drei Assertions
eines **anderen** Vertrags — des Fehlerzweigs. Bei `157` scheitert der zweite Wächter beim
**Lesen** der Datei, die der Eingriff weggenommen hat (`mustReadString` an `:467`); das ist ein
Folgefehler, keine zweite bewachte Aussage. Wer die Deckungs-Menge aus den Köpfen liest, sieht
beides nicht; wer sie aus der Zahl der roten Wächter liest, hält das zweite für das erste. Beide
Male ist das Ergebnis eine Aussage über Deckung, die keine Messung hinter sich hat — hier hat sie
die Lücke **zu groß** geschätzt und damit Folgearbeit erfunden, statt Sicherheit zu behaupten.

**Ein Wächter dieser Menge leitet seine Erwartung aus der Funktion ab, die ihn rot färben soll.**
`TestEnforce_WrapperSuchtDenAblageort` prüft, ob der Wrapper beide Namen sucht, die
`emit.CarrierPath()` erzeugen kann — und holt die Namen aus eben dieser Funktion. Nimmt
`test/mutations/159` der Ziel-Adresse die Endung, kollabieren beide Schleifendurchläufe auf
denselben Namen, und der Wächter bleibt **grün**; rot wird allein
`TestCarrierPath_NimmtDieEndungMit`. Der Kommentar über der Funktion nennt trotzdem `159` als
Rot-Gegenbeispiel; der zutreffende Fall ist `162`. Das ist kein Loch in der Endungs-Achse — die
hält der andere Wächter —, aber es ist eine Kommentar-Zusage ohne Deckung
([`AGENTS.md`](../../../../AGENTS.md) §3.7), und `make comment-claims` sieht sie von Bauart nicht.
Träger unten.

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(3) erfüllt, mit gefahrenen Kommandos.** Bestätigt im
   [Verifikations-Report](../../../reviews/2026-08-25-slice-096-verify.md) §2, dessen Rot-Proben
   auf einer Kopie außerhalb des Repos liefen.
2. **`make gates` grün.** Belege unten unter *Gates*.
3. **`make full-smoke` grün über beide Varianten.** Exit 0, die neue OK-Zeile zweimal (§*Was gilt*).
4. **`make mutate` grün mit den neuen Fällen.** `mutate: 155 ok, 0 Befund(e)`; die acht neuen Fälle
   erscheinen einzeln als `ok` mit ihrem erwarteten Wächter rot.
5. **Der Nachzug aus Folgepflicht 4 geschrieben.**
   [`spec/architecture.md §5`](../../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
   bekommt zwei Bullets: erstmals ein **ausführbares** Artefakt außerhalb des versionierten Baums,
   und ein kanonischer Inhalt, der an einem Laufzeit-Ausgang hängt.
6. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.
7. **Review konform (Modul 10).** [Code-Review](../../../reviews/2026-08-25-slice-096-review.md)
   (`6f860af`): **frei**, `grep -c '^### F-' docs/reviews/2026-08-25-slice-096-review.md` → **3**
   (0 HIGH · 1 MEDIUM · 2 LOW), die MEDIUM-Auflage ausdrücklich dieser Closure zugewiesen.
8. **Verifikation (Modul 11).** [Bericht](../../../reviews/2026-08-25-slice-096-verify.md)
   (`5ef8fb7`): **frei für die Closure**,
   `grep -c '^### V-' docs/reviews/2026-08-25-slice-096-verify.md` → **8**, keiner am Verhalten des
   Gebauten, alle am Text oder an der Dauerhaftigkeit der Mutations-Deckung.

**Wo der Liefergegenstand in der Historie liegt.**
`git log --format='%h %s' 5ef8fb7 | grep -c 'slice-096'` zählt **7** Commits — der Stand gehört ins
Kommando, sonst wandert die Zahl mit jedem weiteren. Die Sache liegt in **einem**: `9239215`
(`git show 9239215 --stat | tail -1` → `16 files changed, 862 insertions(+), 7 deletions(-)`), neu
darin `internal/emit/templates/enforce/span-emit.sh`,
`internal/emit/templates/enforce/settings-capture-hooks.json`,
[`test/span-emit-wrapper.bats`](../../../../test/span-emit-wrapper.bats) und die acht
Mutations-Fälle `155`–`162`. `ab0e855` und `603a6f8` sind die reinen Lifecycle-Moves, `f4b1734` und
`28865bb` die Link-Züge danach, `6f860af` und `5ef8fb7` die Verdikte.

**Was anders lief als geplant.**

- **Drei Posten sind gebaut, die die Plan-Tabelle nicht führt** — alle additiv, alle in der
  Richtung des Plans. **(a)** [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go):
  die Signatur `Enforce(targetDir, notice)` zieht `emitAll(…, notice io.Writer)` und dessen
  Aufrufer nach; die Tabelle führt keine Zeile für `cmd/`. **(b)**
  `internal/emit/templates/enforce/settings-capture-hooks.json`: die Plan-Zeile für dieses
  Verzeichnis nennt nur *„der committete Hook-Wrapper"*, gebaut sind zwei Artefakte. **(c)**
  [`test/span-emit-wrapper.bats`](../../../../test/span-emit-wrapper.bats) mit **6** Fällen
  (`grep -c '^@test' test/span-emit-wrapper.bats`) — der **einzige** Sensor über dem
  Laufverhalten des emittierten Wrappers und damit der gewichtigste der drei. Die Plan-Tabelle
  nennt unter `test/` nur `test/mutations/`; die bats-Ebene kommt in DoD (2) und (3) allein
  mittelbar über `make test` vor.
- **Der `# verify:`-Modus steht in sechs der acht Fälle nicht dran, und das ist wirkungsgleich.**
  DoD (2) und (3) verlangen Fälle *„mit `# verify: test-go`"*; `155`–`159` und `162` tragen keine
  `# verify:`-Zeile. `narrow_sensor()` in [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh)
  leitet aus ihrer `Test[A-Z]*`-Erwartung genau `test-go` ab und ist im Zweifel fail-closed. Die
  Notiz steht hier, damit niemand die Form für einen Befund hält.
- **Von Folgepflicht 6 ist die Hälfte eingelöst, nicht die ganze.** Die Fitness-Function-Zeile
  jener Entscheidung nennt Anwesenheits-Wächter für **Träger, Wrapper, Rollen-Typen und die
  Feldliste**; geliefert sind die ersten beiden plus der Hook-Eintrag. Die anderen zwei schließt
  DoD (3) ausdrücklich aus und verweist auf
  [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) und
  [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md); §Bezug trägt die Teilung
  jetzt. **Ob die Folgepflicht damit als eingelöst gilt, vermerkt nicht diese Notiz** — eine
  *Accepted*-Entscheidung wird gelesen, nicht nachgetragen ([`AGENTS.md`](../../../../AGENTS.md)
  §3.4).
- **Eine gepinnte Zahl dieses Plans war überholt, bevor er schloss.** `.claude/hooks/` führte beim
  Schnitt zwei Einträge, seit der Umsetzung drei — der dritte ist der Wrapper dieses Slice. §1 und
  DoD (3) sind auf den gemessenen Wert gezogen; beide sagten schon vorher *„mitwandernd"*, es war
  also kein Verstoß, aber der `done/`-Move friert den Text ein. Dieselbe Zahl steht in
  [slice-092](../open/slice-092-traeger-inventur.md) §2 und ist dort ebenfalls gezogen — der Slice
  ist sonst unberührt, seine Inventur-Zelle behauptet weiterhin Abwesenheit, und genau diese
  Reibung ist die, die §6 als gewollt führt.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Die Windows-Achse ist abgeleitet, nicht gefahren.** `CarrierPath` nimmt die `.exe`-Endung mit
  und der Wrapper sucht beide Namen; auf einem Linux-Lauf wird der zweite Suchkandidat nie
  genommen. Was hier läuft, belegt, dass es **hier** läuft
  ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)).
- **Dass die Hooks im fremden Repo feuern, belegt kein Lauf.** Emittiert wird eine Konfiguration;
  ob ein Agenten-Werkzeug sie im Adopter-Repo ausführt, ist Annahme (a) mit
  Re-Evaluierungs-Trigger. §1 sagt das vorab, und die Closure hebt es nicht auf.
- **Ein frischer Klon des Adopter-Repos erfasst still nichts.** Der Träger liegt gitignored; ein
  ziel-seitiger Anwesenheits-Wächter ist ausgeschlossen, weil er jeden Klon out-of-the-box rot
  machte und [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) bräche.
  Sichtbar wird der Zustand beim Leser
  ([slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)), nicht beim Schreiber.
- **Zwei Assertions der Träger-Wächter haben kein `test/mutations/`-Gegenstück.** Die
  Träger-Abwesenheit im Fehlerzweig (`:425`) und die sha256-Identität des abgelegten Trägers
  (`:353`). Beide haben Zähne — die zweite fällt unter `io.Copy(out, src)` → `io.CopyN(out, src, 16)`,
  einer Zeile, die eine abgeschnittene und damit **andere** Datei an genau den richtigen Ort legt.
  Ihr Rot ist damit je einmal gesehen; was fehlt, ist die **Dauerhaftigkeit**, denn wer keinen Fall
  hat, gilt nach [`AGENTS.md`](../../../../AGENTS.md) §3.6 als unbewacht. Träger unten.
- **Der Kommentar der emittierten `.harness/.gitignore` nennt als Inhalt von `state/` allein den
  Gate-Nachweis-Stempel.** Seit diesem Slice liegen dort zusätzlich der ausführbare Träger
  (`wc -c < .harness/state/bin/ai-harness-init` → **7577760** Byte, mitwandernd) und die
  Span-Ströme. Das ist **emittierter** Text und steht damit in jedem Adopter-Repo; wer wissen will,
  warum ein 7-MB-Binär in seinem Repo ignoriert wird, findet die Antwort dort nicht. Träger unten.
- **Der emittierte Wrapper hat eine externe Abhängigkeit im seltenen Zweig.** Ohne
  `CLAUDE_PROJECT_DIR` löst er seine Wurzel über `dirname` auf; bei zerstörtem `PATH` schreibt die
  Shell dann `dirname: Befehl nicht gefunden` auf **stderr**. Die zwei tragenden Zusagen halten
  auch dort — Exit 0 und leeres stdout, in drei Läufen außerhalb jedes Repos gemessen —, und die
  emittierte Konfiguration setzt die Variable. Benannt statt übersehen; kein Träger.

**Steering-Loop-Eintrag — neuer Sensor.**

**Nennt ein Kommentar einen Mutations-Fall als Rot-Gegenbeispiel, ist die Rückrichtung mechanisch
prüfbar: der `# expect:`-Kopf jenes Falls muss die Funktion nennen, über der der Kommentar steht.
Heute prüft das nichts.**

**Der gemessene Anlass.** Der Kommentar über `TestEnforce_WrapperSuchtDenAblageort` nennt
`test/mutations/159`; dessen Kopf nennt `TestCarrierPath_NimmtDieEndungMit`
(`sed -n 's/^# expect: //p' test/mutations/159-*.sh`). Die zwei Namen widersprechen einander, das
ist mit zwei `grep` entscheidbar, und gefunden hat es ein Mensch mit den Augen — der Code-Review,
im Handbetrieb, als Nebenbefund. Ein Gate ist darüber nicht gelaufen, weil `make comment-claims`
zwei Verengungen hat, die hier zusammenfallen: es prüft die **Existenz** eines genannten
Testnamens, nicht die Aussage über ihn, und sein Prüfbereich nimmt `_test[.]go` aus — der
Kommentar liegt in genau dieser Datei-Klasse.

**Warum ein Sensor und nicht die sechste Fassung derselben Regel.** Die Regel-Hälfte ist
formuliert und vergeben: *„was ein Eingriff bewegt, wird gemessen, nicht gelesen"*
([slice-100](../done/slice-100-vorlauf-nennt-den-grund.md)), und dieser Slice liefert dazu die
erste unabhängige Instanz aus einer anderen Rolle und mit umgekehrtem Vorzeichen — hier ist die
Lücke **zu groß** geschätzt worden, nicht zu klein. In diesem Repo ist gemessen, was eine weitere
Nennung derselben Regel bewirkt: **3** Closure-Notizen unter `done/` vergeben eine Trägerschaft
wörtlich an den Architect (`git grep -l '^\*\*Träger: der Architect' -- 'docs/plan/planning/done/*.md' | wc -l`),
bewegtes Artefakt keines. Was fehlt, ist kein weiterer Satz, sondern ein Sensor für die Hälfte, die
mechanisch entscheidbar ist.

**Was der Sensor nicht kann, und das gehört dazu.** Er fängt den **falschen Zeiger**, nicht die
**falsche Deckung**. Selbst wenn Kommentar und Kopf einander nennen, bleibt offen, ob das Rot des
Falls die Assertion erreicht, von der der Kommentar spricht — der Fall
`TestEnforce_WrapperSuchtDenAblageort` unter `159` wäre auch dann grün, weil seine Erwartung aus
der mutierten Funktion stammt. Diese zweite Hälfte ist der Gegenstand von
[slice-069](../open/slice-069-zahn-bindet-zusicherung.md), und sie bleibt es.

**Träger: [slice-070](../open/slice-070-comment-claims-pruefbereich.md) — ausdrücklich nicht
*„der Architect"*.** Sein Ziel ist, dass die Zeile *„N Datei(en) geprueft, 0 Befund(e)"* sagt, was
sie behauptet, und seine §1 führt die Ausnahme `grep -v '_test[.]go'` bereits als **permanente**
Verengung. Dieser Slice liefert ihr die erste gemessene Folge: eine Kommentar-Zusage ohne Deckung,
in genau der ausgenommenen Datei-Klasse, von keinem Gate gesehen. Der Posten steht damit in
**seiner** Datei, mit seiner Herkunft und seinem Erkennungsmerkmal. **Der Sensor-Text wird dort
nicht vorentschieden** — ob die Rückrichtung als eigener Modus, als Erweiterung des Prüfbereichs
oder mit Grund gar nicht entsteht, entscheidet der Lauf an dem Skript. Eine Schärfung des Sensors
**hebt** eine Beleg-Anforderung an und braucht darum kein ADR
([`AGENTS.md`](../../../../AGENTS.md) §3.5,
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
*„Gate-Anheben → Steering-Loop"*).

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die Träger-Abwesenheit im Fehlerzweig (`:425`) und die sha256-Identität (`:353`) haben kein `test/mutations/`-Gegenstück; für die zweite ist der Eingriff bekannt (`io.Copy` → `io.CopyN(out, src, 16)`) | **[slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md)** — neu geschnitten. Beide liegen an **einem** Artefakt-Paar und beantworten **eine** Frage |
| `TestEnforce_WrapperSuchtDenAblageort` leitet seine Erwartung aus `emit.CarrierPath()` ab und bleibt darum unter `159` grün; der Kommentar nennt trotzdem `159` | **[slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md)** — dieselbe Frage, dieselbe Datei: ein Wächter, dessen Erwartung aus der mutierten Funktion stammt, misst nicht, was sein Kommentar sagt |
| Der Zeiger vom Kommentar auf den Fall ist mechanisch prüfbar und ungeprüft; `_test[.]go` liegt permanent außerhalb von `make comment-claims` | **[slice-070](../open/slice-070-comment-claims-pruefbereich.md)** — der Steering-Loop-Eintrag oben |
| Ein `# expect:`-Kopf nennt den Wächter, an dem der Treiber misst, nicht die Menge der Wächter, die der Eingriff fällt — an **2** von **3** Fällen gemessen | **[slice-069](../open/slice-069-zahn-bindet-zusicherung.md)** — sein DoD (1) hebt den Kopf von **Wächter**- auf **Zusicherungs**-Granularität; die Messung oben ist eine Eingabe für genau diese Entscheidung, und sie sagt: die Achse *„welcher Wächter"* ist neben der Achse *„welche Assertion"* zu entscheiden |
| *„`make gates` des Ziels ist grün"* ist im Fehlerzweig argumentiert, nicht gelaufen | **[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md)** — seine §3-Zeile zu [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) nennt *„beide Varianten, beide Zweige"*; dahinter steht der Closure-Trigger von [welle-12](welle-12-erfassungsschicht-emittieren.md), der das frische Ziel **in beiden Zweigen** grün sehen will |
| Der Kommentar der emittierten `.harness/.gitignore` nennt nur den Gate-Stempel, während dort der Träger und die Span-Ströme liegen | **[slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)** — er baut das Aufräum-Kommando über genau diesem Bestand; wer sagt, wie man ihn räumt, sagt auch, was er enthält. Es ist **emittierter** Text, also die Tool-Ebene, nicht der Dogfood |
| Die Windows-Achse | **kein Träger, und das ist entschieden** — sie zu fahren hieße, fremde Plattformen zuzusagen; die Grenze ist im Skript-Kopf des Wrappers und hier benannt |
| Annahme (a): Bootstrap-Host und Hook-Plattform sind derselbe Ort | **kein Träger, und das ist entschieden** — [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) führt sie mit Re-Evaluierungs-Trigger; fällt sie, ist der Ausgang die Plattform-Frage (Alternative H), nicht dieser Slice |
| Ein frischer Klon erfasst still nichts | **kein Träger, und das ist entschieden** — §6 dieses Plans und §6 der Welle schließen den ziel-seitigen Wächter aus, weil er [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) bräche |
| Die Formabweichung bei `# verify:` | **kein Träger, und das ist entschieden** — `narrow_sensor()` leitet `test-go` aus der Erwartung ab und ist im Zweifel fail-closed; Wirkung identisch, und ein zweiter Weg zur selben Wirkung ist keine Lücke |

**Folge-Slices: ein neuer `open/`-Eintrag —
[slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md).** Alles Übrige hat einen
bestehenden Träger oder eine begründete Ablehnung. **Warum ein eigener Schnitt und kein Anhängsel
an [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md):** jener trägt bereits
drei DoD-Punkte über einem anderen Gegenstand, und ein Posten ohne eigenen DoD-Punkt ist genau die
Form, die dieses Repo als wirkungslos gemessen hat. **Die Welle bekommt ihn nicht:** er liefert
kein Akzeptanzkriterium von
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), sondern
Sensor-Wartung am Dogfood
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1).

**Die Welle bekommt keinen Fortschritts-Eintrag, und das ist keine Auslassung.** Der Zustand jedes
Slice ist sein Lifecycle-Verzeichnis; §4 der Welle sagt es (*„hier nicht gespiegelt"*) und die
Roadmap sagt es noch einmal (*„Ihr Zustand ist ihr Lifecycle-Verzeichnis und wird hier nicht
gespiegelt"*). Eine Fortschritts-Zeile wäre eine zweite Fassung derselben Aussage, die driftet,
sobald der nächste Move sie nicht mitnimmt. Was die Welle-Datei aus diesem Move bekommt, sind
gezogene Link-Ziele — nichts sonst.

**Gates.** Zwei Läufe über zwei Bäumen, jeder mit seinem Erheber. **Vor der Closure, über dem Baum
bei `6f860af`:** die [Verifikation](../../../reviews/2026-08-25-slice-096-verify.md) fuhr `make gates`
**Exit 0** (`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 381 Datei(en) geprüft, 0 Befund(e)`,
golangci-lint `0 issues.`, bats `1..153` ohne ein einziges `not ok` — darunter `ok 148`–`ok 153`,
die sechs `wrapper:`-Fälle —, `comment-claims: 41 Datei(en) geprueft, 0 Befund(e)`,
`span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`),
dazu `make mutate` **Exit 0** mit `mutate: 155 ok, 0 Befund(e)`, `make full-smoke` **Exit 0** mit
der neuen OK-Zeile über beide Varianten sowie `make test-go`, `make shell-lint` und `make smoke`
**Exit 0**. Die zwei teuren Sensoren stehen damit **fremdbelegt** hier — von einer Rolle mit
frischem Kontext erhoben, nicht von dieser. **Nach der Closure, über dem Baum, den sie
hinterlässt** — Notiz, `done/`-Move und Link-Zug eingerechnet —: `make gates` **Exit 0** mit
`d-check: 383 Datei(en) geprüft, 0 Befund(e)`, `baseline-verify: v3.5.2 OK — 42 Dateien`,
golangci-lint `0 issues.`, `1..153` ohne ein `not ok`,
`comment-claims: 41 Datei(en) geprueft, 0 Befund(e)` und grünem `span-check`; danach sind
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` byte-gleich.
Der Stempel band den Lauf an den Baum, nicht an eine Erinnerung: `record-gates` schreibt ihn nur
als **letzter** Prerequisite grüner Gates
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)),
und der inhaltsbasierte Nachweis listet mit `--exclude-standard`, bleibt vom wachsenden
Span-Bestand also unberührt
([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
Die Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Der Unterschied zwischen **381** und **383** sind zwei Markdown-Dateien: der
Verifikations-Bericht und der mit dieser Closure geschnittene
[slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md). Jede weitere Zeile an
dieser Notiz verschiebt den Stempel erneut; der Lauf, der ihn wieder bindet, gehört zu ihr.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/`, `test/` und `spec/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

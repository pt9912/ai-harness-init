# Slice slice-109: Zwei Aussagen der Feldliste stimmen nicht mit dem Bestand überein — die Zutat über den Speicherschutz und die Notiz zum Feld `program`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung am Wortlaut eines emittierten Artefakts, reaktiv). Die drei Fragen
aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — zwei Aussagen desselben Dokuments, eine Datei,
ein Schnitt; kein zweiter Slice wartet auf ihn. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes
denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv:
zwei gemessen unrichtige Zutaten (§1). Kein Fähigkeits-Sprung — der
Adopter bekommt dasselbe Dokument an derselben Stelle. **Auch nicht in
[welle-12](../done/welle-12-erfassungsschicht-emittieren.md):** deren Zeilen *„Redaktion"* und
*„Benannte Grenze"* sind mit
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) geliefert und bleiben
es — dieser Slice ändert den **Wortlaut** zweier Aussagen, nicht die Frage, ob das Kriterium
erfüllt ist. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: der emittierte Text — und deshalb kein Kosmetik-Schnitt.** Was hier steht, liegt im Repo
jedes Adopters, ist **konvergent** (ein Re-Lauf schreibt es neu) und wird von ihm nicht geheilt.
Eine unrichtige Tatsachenbehauptung darin ist keine Ungenauigkeit in unserem Baum, sondern eine in
seinem.

**Neuplanung 2026-09-27 (Planner):** Dieser Slice lag seit 2026-08-26 in `next/`, ohne dass ein
Implementer geclaimt hatte. Eine erneute Prüfung zeigte: seine ursprüngliche Fassung bündelte zwei
unabhängige Korrekturen (unverändert unten) mit einer dritten, viel größeren Frage — **ob und wie**
die Frage je Feld im Träger und die Zeile in [`spec/spezifikation.md`](../../../../spec/spezifikation.md)
§5 überhaupt gekoppelt werden (die vormalige "Frage A/B"). Diese dritte Frage ist jetzt als eigener
Slice
[`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`](../open/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md)
ausgelagert (§1 nennt die Begründung). Dieser Slice bleibt bestehen und liefert **nur** die zwei
Korrekturen, die von jener Frage unabhängig sind — siehe die geschärfte DoD in §2.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (**Rang 1** —
§Redaktion trägt den dritten Grenz-Satz wörtlich: *„Ausdrücklich nicht zugesagt ist, dass
Pfadnamen unkritisch sind, und dass der Bestand geschützt ist — er ist gitignored, nicht
verschlüsselt und nicht zugriffsbeschränkt."* Die Zutat aus §1 steht dort **nicht**),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 7: das Dokument wird **aus dem Träger erzeugt**; Festlegung 6 Stück 3 verlangt den
dritten Satz als *geschrieben*. Dieser Slice ändert an beiden nichts, er löst ein, was sie über
die Herkunft sagen),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (eine Zusage ist erst fertig, wenn ihr Gegenbeispiel rot
gesehen wurde — die Regel, an der beide DoD-Punkte hängen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie liefert),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-26 (Neuplanung 2026-09-27).

---

## 1. Ziel und Abgrenzung

**Ziel: Kein Satz der Feldliste behauptet über den Bestand oder den Mechanismus mehr, als der
Träger tut.** Zwei konkrete Instanzen, beide unabhängig voneinander behebbar:

### (A) Ein Satz behauptet über den Bestand mehr, als der Träger tut

Der dritte Grenz-Satz trägt eine **Zutat**, die seine Quelle nicht hat:
`grep -n 'Arbeitsverzeichnis lesen kann' --include='*.go' --include='*.sh' -r .` → **1** Treffer
([`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go), Zeile **148**) — *„wer
dieses Arbeitsverzeichnis lesen kann, liest ihn"*. Gemessen am Bestand, den derselbe Träger
schreibt:

- `stat -c '%a' .harness/state/spans` → **755** für das Verzeichnis;
- `stat -c '%a' .harness/state/spans/*.jsonl | sort | uniq -c` → **727**× **600**, ausnahmslos
  (mitwandernd — der Bestand wächst mit jedem Lauf, die Eigenschaft "ausnahmslos" bleibt);
- und der Modus ist **gesetzt**, nicht geerbt: `grep -c '0o600' internal/span/emit.go` → **6**
  Stellen, darunter ein ausdrückliches `Chmod` nach dem Öffnen.

Wer das Arbeitsverzeichnis lesen kann, liest den Bestand also gerade **nicht**, wenn er nicht der
Eigentümer ist. Die Richtung des Fehlers ist die sichere — der Satz sagt **weniger** Schutz zu, als
besteht —, aber es ist eine nachprüfbare Tatsachenbehauptung in einem fremden Repo, und sie stimmt
nicht.

**Der einzige Treffer ist zugleich der Befund über die Bewachung:** die Zutat steht in **keinem**
Wächter. `TestFeldliste_GrenzeUeberDenBestand` hält fünf Textstücke (*„Über den Bestand ist nichts
zugesagt"*, `**gitignored**`, `**nicht verschlüsselt**`, `**nicht zugriffsbeschränkt**`,
`**Pfadnamen sind nicht als unkritisch zugesagt**`), und der Voll-E2E-Sensor prüft leerraum-
normalisiert nur den Satzkopf
(`sed -n '/for satz in/,/done/p' harness/tools/full-smoke.sh | grep -c '"Über den Bestand ist nichts zugesagt"'`
→ **1**). Die Zutat fällt also aus dem Dokument, ohne einen Sensor zu bewegen — genau die
Eigenschaft, die sie unrichtig werden ließ.

**Was ausdrücklich bleibt: die Nicht-Zusage selbst.** Sie steht wörtlich auf Rang 1; dieser Slice
führt die **Zutat** zurück, nicht den Satz.

### (B) Eine Feld-Notiz behauptet eine Regel, die eine spätere Runde widerlegt hat

`SchemaNotes()` sagt zum Feld `program`: *„das erste Token der Kommandozeile, nie die Zeile"*
(`grep -n '{Field: "program"' internal/span/fieldlist.go`). Das ist seit
[slice-204](../done/slice-204-das-programm-feld-nennt-das-programm.md) nachweislich falsch: `cd
/x && make gates` liefert `program="make"`, nicht das erste Token der ganzen Kommandozeile. Die
Closure-Notiz von slice-204 §7 weist genau diese Instanz ausdrücklich diesem Slice zu, **ohne** den
Trägertext selbst zu ändern — Begründung dort: Jede Antwort auf die (jetzt ausgelagerte) Frage
"erzeugt oder verglichen" gleicht den Wortlaut je Feld ohnehin ab, eine vorab hineingeschriebene
Instanz würde mit dem nächsten Nachzug an `commandProgram()` sofort wieder veralten. Die
tatsächlich geltende Regel steht bereits korrekt in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5, Zeile `SPEC-021` (`grep -n
'SPEC-021' spec/spezifikation.md`) — nur die *terse* Trägerfassung ist stehengeblieben.

**Aus dieser Instanz folgt kein Vorgriff auf die Kopplungsfrage.** Dieser Slice entscheidet
**nicht**, ob `SchemaNotes()` künftig aus `spec/spezifikation.md` erzeugt oder gegen sie verglichen
wird ([`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`](../open/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md)
übernimmt diese Frage); er korrigiert nur den heute falschen Satz an seiner einen Stelle, so wie
jede andere faktische Korrektur an diesem Dokument auch ohne Kopplungsmechanismus möglich ist.

**Übernimmt:** *(keine Zeile — dieser Slice übernimmt keinen fremden Gegenstand; er gibt selbst
einen Teil seines ursprünglichen Gegenstands an
[`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`](../open/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md)
ab, siehe §Neuplanung im Kopf.)*

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ob und wie die 32 Feld-Fragen zwischen Träger und Spec §5 gekoppelt werden** — ein Folge-Slice
  übernimmt es:
  [`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`](../open/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md).
  Begründung: eine Stichprobe zeigte substantielle, teils strukturelle Divergenz in einem großen
  Teil der 26 Spec-Zeilen — die Wahl der Sensor-Schicht (erzeugt / wortgleich verglichen /
  auf Kernaussage verglichen) ist eine Architektur-Entscheidung
  (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln), keine, die dieser
  Korrektur-Slice nebenbei träfe.
- **Jede weitere Feld-Notiz, die künftig von ihrer Spec-Zeile abweicht** — Bestand bleibt stehen,
  bis der oben genannte Folge-Slice eine Kopplungsform liefert; ohne sie wäre jede einzelne
  Abweichung ein eigener Korrektur-Slice ohne Ende.
- **Der Umbau von Spec §5** (Gruppierung, vierte Spalte) — wäre ein anderer Vorgang: Er hängt an
  der noch offenen Kopplungsfrage, nicht an den zwei hier behandelten Instanzen.

## 2. Definition of Done

Zwei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Kein Satz des Dokuments behauptet über den Bestand mehr, als der Träger tut — die
      Zutat fällt oder wird messbar. Beides ist zulässig, Schweigen nicht.**
      *Fällt sie*, färbt **kein** Kommando das rot, und das steht dann so da: der Satz sagt danach
      genau, was
      [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
      §Redaktion sagt, und eine Nicht-Zusage hat keine Bruchstelle. *Wird sie messbar* — etwa als
      Aussage über den Modus, den der Träger setzt —, bekommt sie ihren Wächter gegen genau diesen
      Modus, plus einen `test/mutations/`-Fall, der ihn aufweitet.
      **Unverändert bleibt die Nicht-Zusage selbst**, vorher wie nachher:
      `b=<scratch>/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); grep -c 'nicht zugriffsbeschränkt' "$p/harness/erfassung-feldliste.md"`
      → **1**.
- [ ] **(2) Die Notiz zum Feld `program` behauptet keine widerlegte Regel mehr — ein
      `test/mutations/`-Fall, der die Notiz auf den alten Wortlaut zurücksetzt, färbt rot.** Der
      neue Wortlaut bleibt terser Adopter-Text (kein Abschreiben der langen SPEC-021-Herleitung)
      und widerspricht der in `spec/spezifikation.md` SPEC-021 bereits korrekt beschriebenen Regel
      nicht mehr.
      **Rot:** ein neuer `TestFeldliste_...`-Fall, der die alte Formulierung *„das erste Token der
      Kommandozeile"* gegen den `program`-Note-Text sucht und rot läuft, solange sie steht; plus
      ein `test/mutations/`-Fall, der den korrigierten Text auf den alten zurückdreht.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag · Beobachtungs-Register fortgeschrieben · jedes Risiko aus §6 trägt
einen Ausgang · die drei Paarungen (Anker · Folge-Slice · Register) sind getragen. **Der
Doku-Punkt ist hier nicht leer:** das emittierte Dokument **ist** ein Adopter-Vertrag; **die
Spec-Zeile SPEC-021 selbst ändert sich nicht** — sie ist bereits korrekt (§1 (B)).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go) — `limitStore` | update | DoD (1): die Zutat steht in dieser einen Konstante (§1, ein Treffer im ganzen Baum) |
| [`internal/span/fieldlist.go`](../../../../internal/span/fieldlist.go) — `SchemaNotes()`, Eintrag `program` | update | DoD (2): der Notiztext dieser einen Zeile widerspricht der etablierten Regel |
| [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go), [`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) | update | DoD (1) berührt `TestFeldliste_GrenzeUeberDenBestand` **nur**, wenn die Zutat messbar wird — die fünf Textstücke, die er heute hält, enthalten sie nicht (§1); DoD (2) braucht einen neuen Fall gegen den alten Wortlaut |
| `test/mutations/` — ein Fall für DoD (1), soweit sie ein Rot hat, einer für DoD (2) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht. Nummern beim Anlegen neu auszählen (`ls -1 test/mutations/*.sh \| wc -l` → **475**, mitwandernd) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | **unverändert** | er prüft leerraum-normalisiert nur die drei Satz**köpfe** (§1); die Zutat liegt außerhalb seines Vergleichs |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 | **unverändert** | SPEC-021 ist bereits korrekt (§1 (B)); ein Umbau der Kopplung ist Out-of-Scope (§1) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Rang 1 trägt den Satz wörtlich; keine interne Quelle ändert `LH-*` ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) |
| [`docs/plan/adr`](../../adr) | **unverändert** | dieser Slice führt aus, was [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) bereits sagt; eine *Accepted*-ADR wird gelesen, nicht ergänzt ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

## 4. Trigger

**Start** (`next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit. Beide Instanzen
liegen im Baum, sind unabhängig von der ausgelagerten Kopplungsfrage entscheidbar, und keine
andere offene Arbeit muss vorher schließen.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß): Signal, kein Wortlaut — wenn die Umsetzung mehr als die zwei
  benannten Instanzen berührt (z. B. weil ein Wächter für DoD (1) oder (2) eine dritte,
  bisher unbemerkte Stelle mit demselben Muster aufdeckt und die Korrektur dort strukturell anders
  aussieht als hier geplant). Dann ist die dritte Stelle ein eigener Folge-Slice, keine Erweiterung
  dieses Plans.
- `in-progress` → `open` (blockiert): Signal — wenn sich zeigt, dass die Formulierung aus DoD (2)
  ohne einen Blick auf die noch offene Kopplungsfrage nicht stabil ist (z. B. weil jede
  denkbare terse Fassung von einer künftigen `commandProgram()`-Änderung sofort wieder veraltet).
  Dann wartet dieser Punkt auf das Verdikt aus
  [`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`](../open/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md).

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenen Kommandos; `make gates` grün; `make full-smoke` grün über
beide Bootstrap-Varianten (das Dokument ändert seine Bytes, und der Voll-E2E-Sensor liest es);
`make mutate` grün einschließlich jedes neuen Falls; Review konform (Modul 10); Verifikation
bestätigt (Modul 11); `git mv` nach `done/` als eigener Move-Commit; Closure-Notiz mit
Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

## 6. Risiken und offene Punkte

- **DoD (1) hat einen Ausgang ohne Rot, und das ist keine Ausrede, sondern die Sache.** Eine
  gestrichene Behauptung hat keine Bruchstelle. Der Beleg dafür ist negativ und gehört so in die
  Closure-Notiz: welches Kommando **vorher** den alten Text lieferte und danach nichts. —
  **Ausgang:** weiter offen → Beobachtungs-Register (keine passende Beobachtung gefunden,
  2026-09-27 gesichtet).
- **Zwei Sätze des Dokuments beginnen mit derselben Wendung und sind zwei Verträge.**
  `b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); grep -c 'erneuter Lauf' "$p/harness/erfassung-feldliste.md"`
  → **2**. Der erste ist die **Konvergenz-Zusage über das Dokument** (bewacht von
  `TestFeldliste_Konvergent` und `test/mutations/172`), der zweite sagt konditional etwas über die
  **Wiederablage des Trägers** (*„sobald ein erneuter Lauf des Werkzeugs das Programm wieder
  ablegt"*) und liegt im Vertrag von
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1/5,
  also bei [slice-096](../done/slice-096-traeger-liegt-im-ziel.md). Wer an diesen Sätzen arbeitet,
  zieht sie **nicht** zusammen: der eine ist eine Zusage über eine Datei, der andere eine Bedingung
  über ein Programm. — **Ausgang:** eingetreten: keine neue Kennung nötig, die Grenze steht bereits
  hier als Warnung, die die Umsetzung dieses Slice selbst einhält; **entfällt** als offenes Risiko,
  sobald die Umsetzung sie nicht verletzt (Prüfpunkt der Verifikation, nicht des Registers).
- **Eine terse Korrektur der `program`-Notiz kann selbst wieder zu kurz greifen.** `commandProgram()`
  trägt inzwischen viele Rand-Fälle (Zuweisungen, Navigations-Segmente, Operatoren — SPEC-021); eine
  neue Ein-Satz-Notiz, die versucht, das nachzuerzählen, wiederholt genau den Fehler, den DoD (1)
  aus slice-109 heraushalten will (Governance-Prosa im Adopter-Text). — **Ausgang:** weiter offen →
  Beobachtungs-Register (keine passende Beobachtung gefunden, 2026-09-27 gesichtet); der Prüfpunkt
  bei der Umsetzung ist, dass die Korrektur **terser** bleibt als SPEC-021, nicht dass sie
  vollständig ist.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/span/`, `spec/`
und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

**Vorgelagert — offene Beobachtungen sichten (Neuplanung 2026-09-27):** Register durchgegangen —
kein Treffer für "Feld-Notiz widerspricht widerlegter Regel" oder "Zutat behauptet mehr als der
Träger". Verwandt, aber nicht dieselbe Beobachtung:
[`spec-zeile-enger-als-der-code-den-sie-beschreibt`](../observations/BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt/observation.md)
(dort ist die Spec zu eng, hier ist der Träger falsch — umgekehrte Fehlerrichtung).

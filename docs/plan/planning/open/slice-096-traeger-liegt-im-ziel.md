# Slice slice-096: Der Träger liegt im Ziel — oder es liegt begründet nichts

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — der Wertträger der Welle. Er
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
Folgepflichten 4 und 6 sind die Schuld, die dieser Slice begleicht),
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
das Präfix, unter dem der Wrapper landet, führt heute zwei Einträge
(`grep -c '".claude/hooks/' internal/emit/enforce.go` → **2**, mitwandernd). Dieser Slice legt
nichts an, was es nicht ohnehin gibt — er kopiert ein Bild, das gerade läuft.

**Was der Lauf belegt und was nicht.** Belegt ist die Lauffähigkeit auf dem Host, der den Bootstrap
**ausführt**. Gebraucht wird sie dort, wo die **Hooks** laufen, und dass beides derselbe Ort ist,
steht als Annahme (a) mit Re-Evaluierungs-Trigger — nicht als Beweis. Dieser Slice schließt die
Lücke nicht und behauptet nicht, sie zu schließen; er baut den Fall, in dem sie sich zeigt,
sichtbar statt still: ein Träger, der sich nicht ausführen lässt, ist der ablesbare Ausgang des
Triggers.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Der Träger schreibt im Ziel — in beiden Bootstrap-Varianten.** Im frisch
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
- [ ] **(2) Die [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Zusage
      steht mit ihrem rot gesehenen Gegenbeispiel.** Scheitert die Platzierung des Trägers, trägt
      die emittierte `.claude/settings.json` **keinen** Erfassungs-Hook, es liegt **kein** Wrapper,
      der Bootstrap nennt den Grund und endet erfolgreich, und `make gates` des Ziels ist grün.
      **Rot zu sehen ist:** die Kopplung aufheben — den Hook-Eintrag unbedingt schreiben —, dann
      muss der Wächter fallen. **Ohne dieses Rot ist die Zusage eine Absicht**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      **Rot:** `make test` (ein Go-Wächter über dem Fehlerzweig der Emission) und `make mutate`
      (der Fall, der die Kopplung aufhebt, mit `# verify: test-go`).
- [ ] **(3) Anwesenheits-Wächter für Träger und Wrapper — die Bedingung steht im Wächter, nicht in
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
      unter `.claude/hooks/` — Richtung: er wächst in die Liste hinein, die heute **2** Einträge
      führt (`grep -c '".claude/hooks/' internal/emit/enforce.go`, mitwandernd); die Adresse ist
      das **Präfix samt Bestand**, nie ein geratener Dateiname, denn eine Stichprobe auf einen
      Namen, den der Emit nie schreibt, kann unter keiner Mutation rot werden. **(c)** der
      Hook-Eintrag in `.claude/settings.json` — Richtung: kein neuer Pfad, sondern ein **Block in
      einer bestehenden Datei**; seine Anwesenheit ist eine Inhalts-, keine Existenz-Aussage, und
      ein Existenz-Wächter darüber wäre dauerhaft grün. **Nicht in dieser Menge:** die Rollen-Typen
      (unbedingt, [slice-097](slice-097-rollen-typen-gehen-mit.md)) und die Feldliste (teilt den
      Zweig des Trägers, [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md)) — sie
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
  der Zustand beim **Leser** ([slice-099](slice-099-leser-und-aufraeum-kommando.md)), nicht beim
  Schreiber; wiederhergestellt wird der Träger durch einen erneuten Tool-Lauf.
- **Der `span-check`-Wächter dieses Repos geht nicht mit.** Hier heilt ihn ein Bau, im Ziel könnte
  ihn nichts heilen. Wer ihn mitgibt, baut den Klon-rot-Fall, den der vorige Punkt ausschließt.
- **Annahme (a) bleibt offen, und dieser Slice schließt sie nicht.** Fallen Bootstrap-Host und
  Hook-Plattform auseinander, fällt der tragende Grund von Festlegung 1 — und zwar für Alternative
  F ebenso. Der Ausgang ist dann die Plattform-Frage, nicht dieser Slice; **Alternative H** macht
  sie stellbar und verlangt eine Plattform-Angabe, die
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) heute in keinem seiner
  Akzeptanzkriterien kennt.
- **Berührung mit [slice-092](slice-092-traeger-inventur.md), falls jener zuerst liegt.** Sein
  Wächter färbt rot, sobald das Präfix `.claude/hooks/` über seinen gepinnten Bestand hinauswächst,
  während seine Inventur-Zelle noch Abwesenheit behauptet. Das ist **gewollte Reibung**: sie
  erzwingt den Blick auf die Inventur. Wer sie für einen Fehlalarm hält, hat den Wächter
  missverstanden.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/`, `test/` und `spec/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

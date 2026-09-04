# Slice slice-179: Die Form des Beobachtungs-Registers nach dem Sprung wird entschieden — vor dem Umzug

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied** aus demselben Grund wie
[slice-177](../open/slice-177-beobachtungs-register-verzeichnis-form.md), dessen Vorbedingung er
ist: Die Ablage-Form ist eine Pflicht der Ziel-Fassung, und der Slice liefert die Entscheidung, ohne
die jene Pflicht nicht vollzogen werden kann.

**Bezug:**
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 4 —
*ein vom Prozess vorgeschriebener Move wird entschieden, bevor er vollzogen wird*; Festlegung 2 —
der `ignore-refs`-Schlüssel ist extensional auf drei namentliche Paare geschlossen, jedes weitere
ist eine neue Senkung mit eigener ADR; Festlegung 3 führt *die stehende Register-Datei* als
ortsfest),
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) /
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (die Kette, deren Aufnahme-Grenze
diese Entscheidung erfüllen muss),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (die Modus-Deklaration in
`harness/conventions.md` ist Architect-Sache, [`AGENTS.md`](../../../../AGENTS.md) §3.8),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate, dessen Befund unbehebbar ist, erzieht dazu, Rot zu überlesen),
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
(die repo-eigene Präzedenz für den einen Zweig).

**Berührte Spec-Stellen:** `—`. Der Slice entscheidet eine Form- und Verweis-Frage; er schreibt
keine Spec-Stelle.

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Bevor das Beobachtungs-Register seine Ablage wechselt, steht als angenommene Entscheidung fest,
welche Gestalt es bekommt und was mit den Adressen geschieht, die eingefrorene Artefakte darauf
tragen.**

[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
verlangt genau diese Reihenfolge, und der Fall ist ihrer eigenen Klasse: Vor dem Umzug misst der
bewegende Lauf, ob ein nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenes Artefakt das
Ziel als Pfad adressiert. Er tut es — **vier** Vorkommen in ADR-Dateien, zwei davon als
Markdown-Link in einer `Accepted`-ADR:

```sh
git grep -o  'observations\.md'                    -- 'docs/plan/adr/*.md' | wc -l   # 4
git grep -lE '\]\([^)]*observations\.md\)'         -- 'docs/plan/adr/*.md'            # 0028, 0030
grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md   # 1
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Zwei Zweige, beide mit einer battle-getesteten Referenz — und keiner ist der offensichtliche.**

- **Index bleibt.** `docs/plan/planning/observations.md` bleibt als schlanke Index-Datei stehen
  (Tabelle mit Zeiger je Beobachtung, Doppel-Anker), die Einträge wandern ins Verzeichnis. Präzedenz
  ist der eigene Adaptions-Block
  ([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form),
  [slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md)). Keine Adresse stirbt.
  **Der Preis:** Die Ziel-Fassung führt für dieses Register **keine** Index-Datei — ihre Ablage ist
  `observations/README.md` plus je Beobachtung ein Verzeichnis
  (`git show v6.0.0:lab/regelwerk/modul-06-roadmap.md` am lokalen Kurs-Klon, §Das
  Beobachtungs-Register). Der Index wäre damit eine Abweichung und schuldete einen
  Adaptions-Eintrag ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). Die
  Präzedenz trägt nicht von selbst: `harness/conventions.md` steht in der Pflichtgliederung der
  Baseline und **muss** existieren, `observations.md` nicht.
- **Volle Ziel-Form.** Die Datei entfällt. Präzedenz ist das Nachbar-Repo `/Development/d-check`,
  das denselben Sprung bereits vollzogen hat — seine Entscheidung dazu trägt den Titel *Das
  Beobachtungs-Register bekommt einen zweiten, additiven Verzeichnis-Modus* und liegt in
  `/Development/d-check/docs/plan/adr/`. Dort ist
  `observations.md` gelöscht, und die Adressen der eingefrorenen Bestände sind über **fünf**
  `ignore-refs`-Paare stumm geschaltet (`grep -c 'refs: \["docs/plan/planning/observations.md"\]'
  /Development/d-check/.d-check.yml` → **5**). **Der Preis:** Jene fünf Paare sind auf
  **Verzeichnis-Globs** geschnitten — eine Form, die
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 2 für
  dieses Repo ausdrücklich ausschließt (*„jedes zusätzliche Glob in `in` oder `refs` und jede
  Verbreiterung eines der beiden auf ein Verzeichnis ist eine neue Senkung"*). Die Konfiguration des
  Nachbarn ist hier also **kein** übernehmbares Muster, sondern der gemessene Beleg, was der Zweig
  kostet.

**Und eine dritte Frage hängt daran, die keiner der beiden Zweige beantwortet.** Die Ziel-Form
adressiert `BEO-<KUERZEL>/<slug>`; das Kürzel wird *nachgeschlagen, nicht erfunden* — aus der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md). Diese Tabelle
führt **keine** Kürzel-Spalte, und sie begründet das gemessen (§Modus-Deklaration pro Sub-Area,
*„wer ohne Segment zählt, streicht sie"*). Ohne Kürzel gibt es keinen Pfad. Dass das eine
Vorbedingung der Migration ist und nicht ihr Nebeneffekt, hat das Nachbar-Repo in derselben
Entscheidung ausdrücklich festgehalten — *„Ohne Kürzel keine Migration einer Beobachtung dieser
Sub-Area"*.

**Alle drei sind Architect-Fragen** — eine Gate-Senkung
([`AGENTS.md`](../../../../AGENTS.md) §3.5), eine Abweichung von der adoptierten Form (§3.8,
Adaptions-Block) und eine Änderung an der Modus-Deklaration (§3.8).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die ADR liegt und entscheidet drei benannte Fragen** — `Status` steht in ihr, bei
      `Proposed` der Acceptance-Trigger daneben:
      **(a) die Gestalt** — Index-Datei bleibt oder entfällt, mit dem Ausgang für jede der vier
      gemessenen ADR-Adressen, falls sie entfällt; ein weiteres `ignore-refs`-Paar ist dabei die
      Senkung, die [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
      Festlegung 2 mit einer eigenen Entscheidung belegt sehen will;
      **(b) das Kürzel-Segment** — die Modus-Deklaration bekommt ihre Spalte, oder die Pfad-Form
      weicht ab und schuldet einen Adaptions-Eintrag; ein dritter Weg ist zu benennen, nicht zu
      unterstellen;
      **(c) den Commit-Zuschnitt** — ein Commit oder zwei
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3). Das Nachbar-Repo hat für denselben Vorgang
      gemessen, dass keine grüne Zwischenteilung existiert, und dafür eine eigene, auf **einen**
      Commit geschnittene Adaption gebraucht (`/Development/d-check/harness/conventions/`, Eintrag
      *Register-Formatmigration ist ein einziger, deklarierter Commit*) — die Messung ist hier zu
      wiederholen, nicht zu zitieren.
- [ ] **Jeder Zweig ist an einer Sonde gemessen, nicht geschätzt** — je ein `make docs-check` über
      dem probeweise umgezogenen Baum, mit Befundzahl **und** geprüfter Datei-Zahl je Zweig,
      danach zurückgenommen. Das ist die Form, in der
      [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) und
      [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) gemessen
      haben.
- [ ] `make gates` grün.
- [ ] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue
      Zeile ([`AGENTS.md`](../../../../AGENTS.md) §5);
      [slice-177](../open/slice-177-beobachtungs-register-verzeichnis-form.md) §2 nennt die
      entschiedene Gestalt statt der offenen Alternative. Ein öffentlicher Vertrag ist nicht
      berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | neu | die Entscheidung, per `cp` aus der vendored ADR-Vorlage |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | der Index wächst mit der ADR |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration | update | nur im Zweig (b), der die Spalte einführt |
| [slice-177](../open/slice-177-beobachtungs-register-verzeichnis-form.md) §2 | update | die DoD nennt danach die entschiedene Gestalt |

Der Umzug selbst steht **nicht** in dieser Liste: Er ist der Gegenstand von
[slice-177](../open/slice-177-beobachtungs-register-verzeichnis-form.md), und die Entscheidung geht
ihm voraus.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [welle-15](../welle-15-re-baseline.md) ist eröffnet — ihre
Plan-Datei liegt flach in `docs/plan/planning/`, und die Roadmap führt sie unter *Offene Wellen*.
Die Entscheidung braucht den Baum-Tausch nicht: Ihre Grundlage ist die Ziel-Form am lokalen
Kurs-Klon und der Bestand dieses Repos, beides heute messbar.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Kürzel-Frage (b) eine eigene
  Abwägung über den Zählraum verlangt — sie berührt mit `ADR-<KUERZEL>-NNNN` und
  `slice-<KUERZEL>-NNN` zwei weitere Kennungs-Familien, und die stehen hier nicht zur Debatte. Dann
  trennt der Schnitt Verweis-Frage (a/c) und Kennungs-Frage (b).
- `in-progress` → `open` (blockiert — Carveout?): wenn der Katalog aus
  [slice-176](../open/slice-176-inventur-vor-dem-schnitt-v600.md) §9 die Register-Position anders
  zuordnet, als dieser Slice sie vorwegnimmt. Der Katalog ist die Grundlage der Zuordnung, nicht
  ihre Folge.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die ADR trägt `Status:` und, falls `Proposed`, ihren Acceptance-Trigger;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Referenz des Nachbar-Repos wird als Präzedenz gelesen statt als Messung** (`BEO-027` im
  [Register](../observations.md)). Sein Ventil-Regime kennt Verzeichnis-Globs, dieses nicht; sein
  Migrations-Eintrag deckt ausdrücklich **einen** Commit und nennt sich selbst *„keine
  Blankovollmacht"*. Übernommen wird die **Messung**, nicht die Konfiguration. — **Ausgang:** <…>
- **Der vorgeschriebene Ortswechsel macht eine Adresse in einem eingefrorenen Artefakt tot**
  (`BEO-017`, 2× — dieser Slice ist die Antwort auf das dritte Auftreten, nicht seine Notiz). Vier
  gemessene Instanzen kosteten je eine eigene ADR und eine eigene Gate-Senkung; ob diese die fünfte
  wird, entscheidet Zweig (a). — **Ausgang:** <…>
- **Die Kürzel-Entscheidung wirkt über dieses Register hinaus.** Ein vergebenes Kürzel ist
  unveränderlich und stünde danach in Kennungen, Commits und Verweisen; die Modus-Deklaration
  begründet ihre heutige Leere genau damit. Eine Spalte allein für Beobachtungen ist ein dritter
  Weg und als solcher zu benennen. — **Ausgang:** <…>
- **Eine Fähigkeit des Doku-Gates ist unterwegs und wird hier nicht als vorhanden verbucht.** Das
  Nachbar-Repo hat sein `planning`-Modul um einen Verzeichnis-Modus erweitert
  (`observations.dir`, dieselbe Entscheidung wie oben), der genau die maschinelle Hälfte der
  Register-Paarung über der neuen Ablage prüft — die Lücke, die `BEO-006` (1×) führt. Ob der hier gepinnte Stand sie
  trägt, ist **nicht gemessen**; sie hier zu behaupten wäre
  [`AGENTS.md`](../../../../AGENTS.md) §3.1. Der Gegenstand gehört zum Pin-Slice
  [slice-135](../open/slice-135-d-check-pin-v0661.md), nicht hierher. — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations.md`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — sie prüft die Closure von
  [welle-15](../welle-15-re-baseline.md).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area, die
die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
Norm-Artefakte und das Planning-Layout führt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand:

- `BEO-017` (2×) — *ein vorgeschriebener Ortswechsel macht eine Adresse in einem eingefrorenen
  Artefakt tot*. **Dieser Slice ist das dritte Auftreten der Klasse** und zugleich ihr Ausgang: Die
  Zeile bekommt ihn beim Lese-Schritt, wenn die Closure den dritten Beleg schreibt. Steht als
  Risiko in §6.
- `BEO-006` (1×) — *die maschinelle Hälfte der Register-Paarung hat in keinem gepinnten
  Doku-Gate-Stand ein Modul*. Der Zweig, der sie schließen könnte, steht als Risiko in §6 und
  gehört dem Pin-Slice.
- `BEO-027` (1×) — *ein lebendes Plan-Artefakt fasst eine Entscheidung stärker zusammen als die
  Quelle*. Bindet §1: die Referenz des Nachbar-Repos steht als Messung mit Kommando, nicht als
  Autorität.
- `BEO-016` (1×) — *Slice-Pläne tragen ein Vielfaches der nötigen Zeilenzahl*. Bindet diesen Plan
  selbst.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

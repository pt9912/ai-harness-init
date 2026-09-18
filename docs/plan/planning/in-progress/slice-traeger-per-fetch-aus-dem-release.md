# Slice slice-traeger-per-fetch-aus-dem-release: Der Träger eines adoptierten Repos kommt per Fetch aus dem gepinnten Release

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — `make gates` grün und die E2E-Stufe grün sind Belege der
Liefer-Punkte selbst; ein repo-weites Mehr über sie hinaus existiert nicht.

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(der Träger entsteht heute allein im Bootstrap-Lauf — der Fetch macht ihn mit
einem Kommando nachholbar, ohne zweiten Bootstrap von außen),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(der Pin trägt Version + sha256, fail-closed gekoppelt — dasselbe Muster wie
Baseline- und d-check-Pin),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(das Ziel kompiliert nicht — der Host braucht nur `git`, `docker`, `make`; der
Fetch fährt im gepinnten Docker-Bild und braucht damit docker,
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 4),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die Plattform-Matrix der Release-Assets — der Fetch wählt das Asset seiner
Plattform),
[`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
(die neue E2E-Stufe trägt Kopfzeile im Stufen-Muster des Erzeugers und ihre
Deklaration),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
(`archive-welle` ist der Unterkommando-Konsument, dessen Träger die E2E-Stufe
misst; sein Gelingens-Fall ist erst nach dem Release-Schnitt fahrbar —
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(dasselbe Pin-Muster: Netz nur bei dem einen Aufruf, kein Gate);
Setzung des Auftraggebers vom 2026-09-18: Träger per Fetch aus dem gepinnten
Release, E2E-Stufe ausdrücklich als Liefer-Punkt.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein frischer Klon eines adoptierten Repos kann den Träger
(`.harness/state/bin/ai-harness-init`) mit **einem** Kommando aus dem gepinnten
Release nachholen — Version + sha256 gepinnt nach demselben Muster wie
Baseline- und d-check-Pin, fail-closed gekoppelt, Netz nur bei diesem einen
Aufruf. Der Digest wird vor der Ablage verifiziert; eine Digest-Abweichung
bricht ab, ohne den Träger zu legen; der Fehlt-Fall des Trägers bleibt wie
heute benannt (Exit 0, nennt das Fehlende, schreibt nichts). Die E2E-Stufe
misst genau das am realen gebootstrappten Ziel und trägt ihre Kopfzeile im
Stufen-Muster des Erzeugers samt Deklaration. Der Fehlt-Fall ist heute
gemessen und in [`make full-smoke`](../../../../harness/sensors/full-smoke.md)
(Archivierungs-Abschnitt) benannt; mit diesem Slice ist er mit einem Kommando
behebbar, statt nur durch einen erneuten Bootstrap-Lauf von außen.

**Zwei Fragen gehen als Schritte mit Adressat an den Architect** — dieser
Slice entscheidet sie nicht selbst:

1. **Welches Release wird gepinnt, und wo steht der Pin?** Kandidaten:
   als Default im emittierten Fragment, vom Bootstrap-Lauf gestempelt, oder
   als Konstante im Dogfood. Die Frage dahinter: Der Träger eines Ziels sollte
   zur **Werkzeug-Fassung passen, die das Ziel gebootstrapped hat** — ein
   Fetch von `v0.1.1` in ein Repo, das von einer neueren Fassung
   gebootstrapped wurde, legt einen älteren Träger ab. Das Release `v0.1.1`
   (Latest) und `v0.1.0` tragen sechs Plattform-Assets (linux/darwin/windows ×
   amd64/arm64, `.exe` unter Windows) — die Matrix halten
   [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) und
   `test/release-matrix.bats`.
2. **Wo lebt der Fetch?** Ob das Fragment `archivierung.mk` (konvergent)
   erweitert wird oder ein eigenes Fragment entsteht, und ob der Fetch an
   `archive-welle` als Prerequisite hängt oder als eigenes Target steht —
   offene Frage, nicht gesetzt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Deklaration der bestehenden Archivierungs-Stufe** (die Lücke, die den
  Anlass mit gab) — **anderer Vorgang:** sie ist Harness-Selbstbeschreibung
  und ruht unter der Setzung „Nur noch Produkt-Slices"; **diese** neue Stufe
  trägt Kopfzeile und Deklaration von Anfang an.
- **`span-report`/`span-clean`/`hook-overhead` bekommen keinen eigenen
  Fetch-Weg** — **Schicht-Abgrenzung:** sie hängen am selben Träger; wenn der
  Fetch ihn legt, sind alle vier bedient. Ein zweiter Weg wäre ein
  zweiter Träger für denselben Zustand.
- **Kein Signier-Schritt, keine zweite Prüfung der Assets** — **Bestand bleibt
  bewusst stehen:** das Handbuch nennt die Grenze (der Release-Lauf hat keinen
  Signier-Schritt); der Fetch prüft den **Digest**, nicht die Signatur, und
  seine Doku sagt genau das.
- **Kein Release-Schnitt in diesem Slice** — **anderer Vorgang:** das Release
  ist **Voraussetzung**, nicht Lieferung; ein eigener wellenloser Posten für
  den Release-Schnitt folgt danach, falls der Architect ihn für nötig hält.
  (Siehe Risiko 1: pinnt der Slice auf `v0.1.1`, entfällt die
  Voraussetzungs-Abhängigkeit — aber dann trägt der Träger nicht die heutige
  Werkzeug-Fassung.)

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — Fetch mit Pin:** Ein `make`-Target (Name und Ort gemäß
      Architect-Entscheidung, Frage 1 und 2) legt den Träger
      `.harness/state/bin/ai-harness-init` per Fetch aus dem gepinnten Release;
      Version + sha256 sind gepinnt und fail-closed gekoppelt (dieselbe
      Kopplungs-Klasse wie `test/sources-pin.bats`), Netz nur bei diesem
      Aufruf. Der Digest wird vor der Ablage verifiziert; Abweichung bricht ab,
      ohne den Träger zu legen; der Fehlt-Fall bleibt Exit 0 mit Meldung, die
      das Fehlende nennt und nichts schreibt.
      Test: `test/traeger-fetch.bats` (Happy: Träger liegt und läuft ·
      Negative: Digest-Abweichung bricht fail-closed · Fehlt-Fall: Exit 0,
      nennt das Fehlende). Rote Gegenprobe: wird der Digest-Pin in der
      Verifizierung umgangen, färbt der Negative-Fall des bats-Tests rot —
      unter der geschwächten Zusicherung (Abweichung bricht, aber der Träger
      bleibt liegen) muss der zweite Negative-Fall rot bleiben.
- [ ] **Liefer-Punkt 2 — E2E-Stufe am realen Ziel:** Eine Stufe in
      `harness/tools/full-smoke.sh` misst am realen gebootstrappten Ziel:
      frischer Klon ohne Träger → Fetch → Digest verifiziert. Der
      `archive-welle`-Aufruf geht dem Fetch voraus (Klon ohne Träger) und
      endet an der dokumentierten Grenze, nicht in einem Erfolg, der nichts
      belegt; nach dem Fetch wird er nicht gerufen — am gepinnten Stand würde
      er nicht an der Grenze enden, sondern still den Init-Pfad starten, und
      ein solcher Aufruf belegt nichts. Der gepinnte Träger führt das
      Unterkommando nicht — die „läuft"-Hälfte der Kette ist erst nach dem
      Release-Schnitt fahrbar, der ihr den fähigen Träger legt
      ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
      Festlegung 2: am gepinnten Stand bricht der Aufruf still). Die Stufe
      trägt ihren Messbefund in ihrem GRENZE-Abschnitt und in ihrer OK-Zeile;
      Digest-Abweichung bricht fail-closed. Die Stufe trägt ihre **Kopfzeile
      im Stufen-Muster des
      Erzeugers** und ihre **Deklaration** — nach `make e2e-abdeckung` steht
      sie in `docs/user/e2e-abdeckung.md`. Test: der Fall in
      `test/e2e-abdeckung.bats` hält die Deklaration gegen die Stufen. Rote
      Gegenprobe: ohne die Deklarations-Zeile färbt der Fall in
      `test/e2e-abdeckung.bats` rot (eine Stufe, die nur durch ihr Kommentar
      existiert, fällt aus der Sicht heraus, und der Generator meldet das
      nicht — gemessen an der bestehenden Archivierungs-Stufe, die genau so
      außerhalb steht).
- [ ] **Liefer-Punkt 3 — Doku:** [`harness/README.md`](../../../../README.md)
      nennt das neue Target (Gate-Klasse korrekt: kein Gate, mit Halbsatz, was
      es stattdessen tut — Netz-Bedarf benannt), und
      `docs/user/e2e-abdeckung.md` ist regeneriert. Rote Gegenprobe: nennt die
      Werkzeuge-Tabelle ein Target ohne Makefile-Regel, färbt `make docs-check`
      (Modul `targets`, Grund `gate-phantom`) rot — rot gesehen: Sonde
      `make traeger-fetch-halluzination` in der Werkzeuge-Tabelle → 1705/1
      (2026-09-18). Grenze: der Klasse-Stempel selbst ist unbewacht — entfernt
      ein Lauf `kein Gate` aus der Werkzeuge-Zeile, bleibt `docs-check` grün
      (gemessen 1704/0); das Modul liest den Target-Namen gegen das Makefile,
      nicht den Stempel, und `test/targets-modul-wiring.bats` hält eine andere
      Mutation (Makefile-Regel ohne Sensors-Zeile), nicht diese.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für die neue Fetch-Fähigkeit, falls ein öffentlicher Vertrag
      berührt ist (Liefer-Punkt 3).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit` (Fragment-Emission) | update | legt den Pin (Release-Tag + sha256) als Default im emittierten Fragment ab bzw. trägt die Stempel-Logik — je nach Architect-Entscheidung, Frage 1 |
| Dogfood-Makefile bzw. der Fragment-Ort im Ziel | update / neu | der Fetch als Target — je nach Architect-Entscheidung, Frage 2; das emittierte Fragment und der Dogfood brauchen dieselbe Zeile |
| `harness/tools/full-smoke.sh` | update | neue E2E-Stufe am realen Ziel (Liefer-Punkt 2), Kopfzeile im Stufen-Muster |
| `test/traeger-fetch.bats` | neu | Happy/Negative (Digest fail-closed)/Fehlt-Fall — nach Liefer-Punkt 1; Rote Gegenprobe über die Digest-Verifizierung |
| `test/e2e-abdeckung.bats` | update | Fall, der die Deklaration der neuen Stufe gegen die Sicht hält — nach Liefer-Punkt 2 |
| `docs/user/e2e-abdeckung.md` | update | regeneriert via `make e2e-abdeckung` — nicht hand-edited |
| `harness/README.md` | update | Werkzeuge-Tabelle: Target genannt, Klasse „kein Gate", Netz-Bedarf benannt |

**Ansatz als Liste, wo eine Zeile pro Datei nicht trägt:**

- Der Pin folgt dem Muster der drei bestehenden Pin-Stellen (`BASELINE_TAG`/
  `BASELINE_ZIP_SHA256`, `sources`-Paar, `DefaultTag`/`DefaultBaselineSHA256`):
  fail-closed gekoppelt, Test hält jede Stelle gegen das Makefile-Paar. Ob die
  neue Kopplung in ein bestehendes bats-File (`test/sources-pin.bats`) oder ein
  neues wandert, entscheidet der Implementer am Bestand.
- Netz-Bedarf der E2E-Stufe — **Plan-Entscheidung, hier begründet:** Die
  Gates (`make gates`) sind netzlos, und der Fetch ist kein Gate; `full-smoke`
  ist ebenfalls kein Gate und läuft in CI auf frischem Klon mit Netz
  ([`harness/README.md`](../../../../README.md) §Safety and scope boundaries).
  Die Stufe fährt den Fetch daher **real gegen das Release** — ein lokales
  Fixture würde die Zusage („per Fetch aus dem gepinnten Release") nicht
  messen, sondern ihre Nachbildung, und der Digest-Verifizierungs-Schritt
  gegen ein Fixture hätte keinen Beleg. Der Negative-Fall (Digest-Abweichung)
  braucht **keinen** zweiten Download: er verdreht den Digest-Pin gegen dasselbe
  Asset. Der Fehlt-Fall (Exit 0, nennt das Fehlende) ist ohne Netz messbar —
  er wird an einem Klon ohne Träger gemessen, bevor der Fetch läuft.
  Gegen [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit):
  der Pin hält den Lauf reproduzierbar — dasselbe Release, derselbe Digest,
  ein Netz-Ausfall bricht sichtbar statt still grün.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, Architect hat die
zwei Fragen aus §1 entschieden (Release + Pin-Ort, Fragment-Ort),
WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der E2E-Teil wächst
  über die Stufe hinaus — mehr als die eine Stufe samt Deklaration, oder die
  Fetch-Verdrahtung berührt die Bootstrap-Emission inhaltlich (nicht nur den
  Pin). Dann E2E als eigenen wellenlosen Posten schneiden.
- `in-progress` → `open` (blockiert — Carveout?): Kein Release mit Assets ist
  erreichbar (Netz dauerhaft weg oder Assets fehlen in der Matrix von
  [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) — der
  Pin hätte kein Ziel.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig mit roten Gegenproben der drei Liefer-Punkte belegt, und
`make full-smoke` grün über der neuen Stufe (frisches Ziel: Fetch legt den
Träger, der Digest stimmt; die „läuft"-Hälfte von `archive-welle` wird erst
vom Release-Schnitt fahrbar — die Stufe trägt ihre Grenze in GRENZE-Abschnitt
und OK-Zeile).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Fassungs-Drift:** pinnt der Slice auf `v0.1.1` (Latest), trägt der
  abgelegte Träger nicht die Werkzeug-Fassung, die das Ziel gebootstrapped hat
  — ein älterer Träger in einem Repo, das von einer neueren Fassung
  gebootstrapped wurde. Die Spannung ist benannt und wird nicht hier
  entschieden, sondern von der Architect-Entscheidung, Frage 1 — **Ausgang:**
  *offen bis zur Entscheidung; nach ihr* eingetreten → Folge-Slice, der den
  Stempel-/Fit-Mechanismus liefert | entfallen: wenn der gewählte Pin-Ort die
  Fassungs-Frage strukturell auffängt (Stempel durch den Bootstrap-Lauf) |
  weiter offen: → Register.
- **Emission berührt sich selbst:** das Werkzeug emittiert einen Fetch **für
  sich selbst** — der Träger des Ziels ist das eigene Binary; ein Fehler in
  Pin- oder Pfad-Logik fällt erst im Ziel auf, nicht im Dogfood. Gegenbeispiel
  ist der hermetische bats-Test plus die E2E-Stufe am realen Ziel — **Ausgang:**
  weiter offen, falls der Implementer eine Lücke findet, die weder Test noch
  Stufe decken.
- **Der Fehlt-Fall verliert seine Zusage:** heute misst `full-smoke` (Stufe
  der Archivierung), dass der Fehlt-Fall Exit 0 meldet und nichts schreibt.
  Legt der Fetch den Träger, könnte eine spätere Fassung den Fehlt-Fall still
  umdrehen (z. B. automatisch fetchen). Die Zusage „Exit 0, nennt das
  Fehlende, schreibt nichts" wird im bats-Test gehalten — **Ausgang:**
  entfallen, wenn der Negative-/Fehlt-Fall-Test die Zusage misst; sonst
  eingetreten → Folge-Slice.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu
  angelegt, Beleg `evidence/slice-traeger-per-fetch-aus-dem-release.md` |
  `evidence/slice-traeger-per-fetch-aus-dem-release.md` in `BEO-<KUERZEL>/<slug>/`
  ergänzt — Zähler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) — die
Emission (`internal/emit`) und die Doku — und `harness/tools/` —
`full-smoke.sh` und der bats-Test. Beide erfüllen die Schwelle ≥ 2 von 3
Achsen (Inventur-Berührung: ja, beide; mehrere Dateien: ja; Aussage-Berührung:
ja — die Werkzeuge-Tabelle in `harness/README.md`). Keine der beiden ist zu
grob — die Modus-Deklaration in `harness/conventions.md` führt beide namentlich.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-18 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**145**), Verzeichnisse unter `BEO-ALL/`. Treffer für diese Sub-Areas:
`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut` —
**Zählerstand 1×**; dieser Slice ist die gegenläufige Richtung: eine
Fähigkeit bekommt ihren Einstieg als Target, statt von Hand — bzw. statt
durch einen erneuten Bootstrap-Lauf von außen — nachgebaut zu werden; er senkt
das Risiko nicht auf null, sondern gibt dem Muster seinen Träger.
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` —
**Zählerstand 2×**; der Fetch ist eine emittierte Zusage über das Ziel, und
die E2E-Stufe am realen Ziel ist genau der Ort, an dem die Differenz zwischen
Aussage und Gelingens-Zweig messbar wird — dieses Risiko gehört in den
Implementer-Kontext (§6, Risiko 2). Kein Eintrag erreicht mit dieser
Berührung 3× — der Zähler von `emittierte-zusage…` wird durch diesen Plan
nicht hochgeschrieben.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` und
`harness/tools/` stehen in der Modus-Deklaration als Greenfield); kein
BF/Hybrid-Block.
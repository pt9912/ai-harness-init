# Slice slice-sync-waechter-tragen-mutations-faelle: Die `sync`-eigenen Wächter tragen Mutations-Fälle in `test/mutations/`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die von der DoD dieses
Slice verschieden ist, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Ebene: Dogfood, Sensor-Slice.** Gegenstand sind Mutations-Fälle in `test/mutations/` für die Zusagen des Modus
`sync` in `harness/tools/tap-nachzug.sh` und `harness/tools/tap-nachzug-nutzlast.sh`, und der Absatz *Grenze* in
Schritt 7 von [`docs/user/releasing.md`](../../../user/releasing.md), der sie nennt; kein Produkt-Code.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — §Fitness Function, letzte Zeile: die Wächter von `sync` fallen unter `make mutate`),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
(die Fall-Anlage misst ihr `sed`-Muster gegen den Quell-Bestand),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (das Feedback: gelistet heißt bewacht).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-26.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jeder `sync`-eigene Wächter hat einen Fall in `test/mutations/` — *Mutation → erwartet rot färbender
`bats`-Fall* —, sodass `make mutate` seine **Haltbarkeit** hält. Heute hängen die `sync`-Zusagen allein an
`bats`-Fällen, die einmal rot gesehen wurden (`grep -ln 'sync' test/mutations/*.sh` → keine Datei); die Fälle
für gemeinsame Wächter (`452`, `411`, `416`, `428`, `432`, `433`) färben zwar `sync`-Fälle mit, nennen `sync`
aber nicht.

**Die Menge, die dieser Slice abdeckt,** steht in der Fitness Function von
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Vorwärts-Schutz,
Gleichstands-Vergleich, Feldform-Prüfung der `version`-Zeile, Idempotenz-Zweig, Nachkontrolle, Wiederholung des
Lesens, Optimistik-Stand, Tag-Formprüfung, Fehlt-Nachweis); dazu der Header am Schreibaufruf und die Meldung nach
einem vollzogenen Schreiben, die als Zähne der `bats`-Fälle entstanden sind. **Welche davon schon ein Fall
nennt, misst der Lauf an seinem Start** — er legt Fälle nur für die an, die kein bestehender Fall mit seinem
`# expect:`-Text auf die `sync`-Fälle bindet.

**Die Bedingung des Gebers, die dieser Slice trägt:** Der Absatz *Grenze* in Schritt 7 sagt heute, die Wächter
von `sync` trügen `bats`-Fälle und keinen Fall in `test/mutations/`; mit diesem Slice ist die Aussage falsch. Der
Lauf zieht sie, nennt *„die `sync`-eigenen Wächter"* statt *„die Wächter von `sync`"* (die gemeinsamen Wächter
sind durch die Fälle des Bestands gedeckt) und misst die Zahl neben `grep -c '^@test' test/tap-nachzug.bats` neu,
falls er `bats`-Fälle hinzufügt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Release-Job `tap` und der Umbau von Schritt 7 für ihn** — **`slice-release-job-tap-nachzug-und-schritt-7-folgt`**
  (`open/`): anderer Gegenstand (Workflow), und er nimmt den Umbau der Handlung. Dieser Slice ändert am Schritt
  nur den Absatz *Grenze*.
- **Änderungen am Verhalten von `sync`** — **anderer Vorgang:** die Fälle prüfen die Zusagen, die das Skript
  hält; ein Fall, der ein Verhalten fordert, das das Skript nicht hat, ist ein Befund und keine Änderung hier.
- **Der Schreib-Pfad am realen Tap** — **nicht herstellbar ohne Schreibzugriff auf ein Fremd-Repo**
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Grenze);
  die Fälle fahren ihn gegen die nachgebildete Schnittstelle der `bats`-Fälle.
- **Ein voller Lauf `make mutate` als Gate** — **`make mutate` ist kein Gate** (README, §Werkzeuge); der Slice
  fährt ihn als Beleg über seine neuen Fälle, macht ihn nicht zu einer Bedingung von `make gates`.

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — Fälle für die Schritte b bis e** (Fehlt-Nachweis, Tag-Formprüfung, Vorwärts-Schutz,
      Gleichstands-Vergleich, Feldform der `version`-Zeile, Idempotenz-Zweig): je Wächter ein Fall in
      `test/mutations/` mit `# files:`, `# expect:` (Name des rot werdenden `bats`-Falls in `test/tap-nachzug.bats`)
      und `# verify: test-bats`, dessen `sed`-Anker gegen den Quell-Bestand gemessen ist
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
      **Je Fall die Schwächung, die ihn rot färbt; jeder Fall wird einmal rot gesehen, die Ausgabe gelesen, und die
      Gegenprobe (Zusicherung entfernen, Schwächung bleibt) zeigt, ob der eigene Zahn bindet oder ein zweiter Zweig
      fängt.** Wo ein Fall des Bestands den Wächter schon auf `sync` bindet, entsteht kein zweiter.
- [ ] **Liefer-Punkt 2 — Fälle für die Schritte f und g** (Optimistik-Stand gegen den Blob-Stand der verglichenen
      Bytes, Nachkontrolle, Header am Schreibaufruf, Meldung nach einem vollzogenen Schreiben, Zuordnung
      *„abgelehnt"* gegen *„Ausgang ungewiss"*): dieselbe Form und dieselbe Pflicht wie Liefer-Punkt 1. **Die Naht
      dieses Slice** liegt zwischen den beiden Punkten (§4).
- [ ] **Liefer-Punkt 3 — der Absatz *Grenze* in Schritt 7** nennt die Zusagen, die `make mutate` jetzt hält, und die
      übrigen, die nur an `bats`-Fällen hängen, in Zustandsform und mit dem Kommando, das die Menge liefert;
      *„die `sync`-eigenen Wächter"* ersetzt *„die Wächter von `sync`"*. Jede genannte Zahl steht neben ihrem
      Kommando ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
      **Deckung, benannt:** kein Test und kein Gate hält `releasing.md` gegen den Fall-Bestand; Träger sind der
      Review und der Verifier.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: der Absatz *Grenze* ist Liefer-Punkt 3; eine neue Zeile in `harness/README.md` entsteht nicht
      (`make mutate` steht dort).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/<nnn>-…sh` (mehrere) | neu | Liefer-Punkt 1 und 2: je ungedecktem Wächter ein Fall, Anker gegen den Quell-Bestand gemessen |
| `docs/user/releasing.md` | update | Liefer-Punkt 3: der Absatz *Grenze* in Schritt 7 |

- **Schichten: zwei.** Sensor (Fälle) und Nutzer-Doku (ein Absatz). Kein Produkt-Code.
- **Der Bestand wird an der Basis gemessen, nicht aus diesem Plan übernommen:** `grep -l 'tap-nachzug' test/mutations/*.sh`
  nennt die Fälle, die die zwei Skripte berühren; welcher davon einen `sync`-Fall mit seinem `# expect:` färbt,
  misst der Lauf mit der Emulation des Falls am HEAD-Stand.
- **Nummern:** Schritt 7 bleibt Schritt 7; kein Nummernwechsel.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Vor `open` → `next`** (Priorisierung, Entscheidung des Auftraggebers): der bewegende Lauf misst nach
[`AGENTS.md`](../../../../AGENTS.md) §3.11, ob ein eingefrorenes Artefakt diese Datei als Pfad nennt — über beide
Adress-Formen (Code-Span-Pfad und Markdown-Link). Der Befund am Tag des Schnitts steht im Commit, der die Datei
anlegt; die Kennung nennen die Closure-Notiz des Vorgängers und die Übergaben seiner Reports als Text.

**Start** (`next` → `in-progress`): `Verantwortlich:` gesetzt, WIP-Limit frei; der Modus `sync` besteht in
`harness/tools/tap-nachzug.sh` (der Vorgänger dieses Slice hat ihn geliefert).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Review hält die Fälle beider Liefer-Punkte in einer
  Sitzung nicht für prüfbar — jeder Fall trägt eine eigene Anker-Messung. **Die Naht** liegt zwischen den
  Schritten b bis e (Liefer-Punkt 1) und f bis g (Liefer-Punkt 2); jede Hälfte ist einzeln lieferbar, der Rest
  geht als Folge-Slice mit Kennung an den Planner zurück.
- `in-progress` → `open` (blockiert): ein Fall ist nicht herstellbar, weil das Skript die Zusage nicht hält — dann
  ist es ein Befund gegen `sync` und geht an den Architect oder Implementer von `sync`, nicht in diesen Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make mutate` färbt jeden neuen Fall seinen Wächter rot, jeder mit seinem
`# expect:`-Text, und meldet keinen Befund auf einen der neuen Fälle. (2) `make gates` ist grün, und der Absatz
*Grenze* in Schritt 7 nennt keinen Fall-Bestand, den `grep -l 'sync' test/mutations/*.sh` nicht trägt. Dazu der
Lerneintrag in §7 in einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Offene Fragen:** keine.

**Risiken:**

Kein Risiko trägt hier schon seinen Ausgang; er wird bei der Closure zugewiesen, die Kandidaten stehen dabei.

- **Ein neuer Fall bindet seine Zusicherung nicht** — er wird rot, weil ein zweiter Zweig fängt. **Ausgang:**
  Kandidat *entfallen*, wenn die Gegenprobe je Fall zeigt, dass der Zahn allein bindet (*grün heißt bindet*).
- **Der Slice ist für eine Review-Sitzung zu groß.** **Ausgang:** Kandidat *eingetreten* → Folge-Slice mit Kennung
  (Naht in §4); *entfallen*, wenn der Review ihn in einer Sitzung trägt.
- **Der Absatz *Grenze* altert mit einem weiteren Wächter von `sync`.** **Ausgang:** Kandidat *weiter offen* →
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).

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

Wird bei der Closure geschrieben — von der Rolle Planner in frischem Kontext (AGENTS.md §3.10), nach Review und Verifikation, in der Form der Regeln oben.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) für Fälle und Doku, dazu `harness/tools/`
nur lesend (die Skripte sind Gegenstand der Fälle, nicht der Änderung). Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt beide als eigene Zeilen, beide Greenfield;
die Schwelle ≥ 2 von 3 Achsen ist erfüllt, keine Zerlegung ist nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register gelesen am 2026-09-26 auf dem lokalen Stand (nichts
gepusht; das Register ist beim Lesen so alt wie der letzte Merge). Sub-Area aller Einträge ist `*`. Die
Zähler-Stände sind die Zahl der Dateien unter dem `evidence/` des Eintrags, **einschließlich der Belege der
Closure des Vorgängers** (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen
2026-09-26, keine Erwartungswerte). **Treffer:**

- [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  — **3×**, Ausgang *geplant* mit der Kennung dieses Slice: er ist die Instanz, an der die Klasse für `sync`
  schließt. Für die Klasse selbst (jede weitere Zusage mit `bats`-Bindung ohne Fall) bleibt Träger der Review.
- [`BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen`](../observations/BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
  — **1×**, `offen`. Die Gegenprobe je Assertion (Liefer-Punkte 1 und 2) ist ihr Träger; ein Beleg entsteht hier,
  wenn ein neuer Fall zwei Assertions verschiedener Weite führt und die weite die enge verdeckt.
- [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **32×**, Stand *geplant*. Liefer-Punkt 3 zieht eine Aussage, die mit dem Slice falsch wird; sie steht in §1
  im Eingang des Laufs.
- [`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
  — **3×**, über der Schwelle, Ausgang beim Architect; Liefer-Punkt 3 gibt den Fall-Bestand wieder, der Verifier
  fährt ihn gegen `test/mutations/`.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF (`*` und `harness/tools/` stehen in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) als Greenfield) — kein BF/Hybrid-Block.

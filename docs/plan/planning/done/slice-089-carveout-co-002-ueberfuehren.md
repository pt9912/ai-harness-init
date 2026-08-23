# Slice slice-089: Der Carveout wird übergeführt — der Status trägt den Übergang, die Adresse bleibt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiver Nachzug einer Entscheidung) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3. Er ist **kein Mitglied** von
[welle-09](../welle-09-modul-15-konformitaet.md) und ändert an ihrem Plan nichts; was ihn mit ihr
verbindet, ist eine **Reihenfolge**, und die steht in §6.

**Bezug:**
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) — die Entscheidung, deren
Folgepflichten dieser Slice vollzieht: Festlegung 5 lässt den Carveout an seiner Adresse und legt
den Übergang in seinen **Status**. Von den sieben Folgepflichten trägt dieser Slice **drei** — den
geschriebenen Übergang in Stub und Index, die sechs Zeiger, den fälligen Mutations-Fall. Die zwei
weiteren Planner-Posten liegen ausdrücklich außerhalb (§3); die verbleibenden zwei verlangen heute
keine Arbeit und stehen deshalb **benannt** statt weggelassen — die emittierte Ebene ist nicht
berührt (Datei-Tabelle in §3), und ein Adaptions-Eintrag ist ausdrücklich **nicht** angeordnet
(§6). **Der Slice nennt die ADR; die ADR nennt ihn nicht.**
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) — der Gegenstand: ein Carveout, dessen
Trigger nach der Messung nur noch im fremden Vertrag liegt und der damit *de facto* permanent ist.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — der
fällige Mutations-Fall ist ein **Zahn**, kein neuer Gate-Name: er läuft in `make mutate`, nicht in
`make gates`, und behauptet nichts Neues.
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Inhaltsänderung sind zwei Commits — die Auflage
greift hier allein für die Lifecycle-Moves **dieser Plan-Datei**, denn der Carveout wird nicht
bewegt), §3.4 (die ADR ist ab *Accepted* immutabel) und §3.7 (der Kommentar im Hook beschreibt,
was da ist).

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Nach diesem Slice trägt der Carveout an seiner eigenen Adresse den Verdikt-Status, sein
Index-Eintrag steht unter dem permanenten Übergang, und die sechs Stellen, die auf ihn zeigen,
führen die Messung nicht mehr als ausstehend.** Das Verdikt selbst steht an genau einem Ort — in
der ADR.

Ein Carveout sagt zu, temporär zu sein; seinen Trigger führt er als erreichbare Bedingung. Nach der
Messung ist der eine erreichbare Weg ausgefallen, und was bleibt, liegt im fremden Vertrag. Ein
Carveout, der so stehen bliebe, wäre die permanente Ausnahme, die behauptet, temporär zu sein —
genau die Doku-Drift, die Carveouts verhindern sollen. **Träger dieser Aussage ist ab hier der
Status, nicht das Verzeichnis:** der Stub bleibt liegen, wo er liegt, und wird zur **Weiche** auf
das Verdikt.

**Was das Ziel NICHT umfasst — eine Grenze des Schnitts, keine Auslassung.** Eine
`CO-002`-Nennung tragen heute **13** lebende Dateien
(`git ls-files | xargs grep -ln 'CO-002' | grep -vc -e '^docs/reviews/' -e '^docs/plan/planning/done/' -e '^\.harness/baseline/'`;
die Zahl wandert mit dem Bestand und ist **kein** Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Sechs Zeilen in zwei davon deckt DoD (2), Stub und Index deckt DoD (1) — **die übrigen
deckt dieser Slice nicht**, und zwei von ihnen führen die Schwelle nach dem Vollzug weiter als
**offen**: die Roadmap und ein fremder Slice-Plan in `open/`. Beide stehen mit Träger in §6.

**Was er ausdrücklich NICHT tut: entscheiden.** Er ändert keine ADR, er formuliert keine neue
Begründung und er importiert das Verdikt nicht an einen zweiten Ort — *„ein zweiter Ort driftet"*
([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1). Er schreibt einen
Übergang, zieht Aussagen nach und baut einen Zahn.

## 2. Definition of Done

Jeder Punkt nennt das Kommando, das ihn rot färbt — und wo keines existiert, steht **das** dabei.
Eine Zusage reicht nur so weit wie ihr Sensor
([slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7).

- [x] **(1) Der Übergang ist geschrieben, nicht verschoben — vier Änderungen am Stub, eine am
      Index, ein Commit.** An [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md): der Status
      aus Festlegung 5 (`Status: Permanent — übergeführt in` gefolgt von der Kennung
      [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)); ein aktuelles
      `Letzte Prüfung`-Datum samt Geschichte-Zeile; im Abschnitt `## Auflösungs-Trigger` fällt die
      Handlungs-Anweisung *„und nach `done/` zu verschieben"*, und der Abschnitt bekommt einen
      Vorspann-Satz, der auf den Status im Kopf zeigt — **der Abschnitt selbst bleibt**; der
      Abschnitt `## Verifikation (nach Auflösung)` fällt **als Ganzes**, mit allen Haken (heute
      **5**:
      `awk '/^## Verifikation/,/^## Geschichte/' docs/plan/carveouts/CO-002-token-achse-je-rolle.md | grep -c '^- \[ \]'`).
      An [`docs/plan/carveouts/README.md`](../../carveouts/README.md) eine Stelle: der Eintrag
      verlässt §Aktiv und steht in einem eigenen Abschnitt für den permanenten Übergang.
      **Kein `git mv`, ein Commit** — ein `carveouts/done/` entsteht nicht.

      **Rot färbt ihn** — drei Kommandos über
      `docs/plan/carveouts/CO-002-token-achse-je-rolle.md`. **Die ersten zwei decken je die
      Änderung, neben der sie stehen; das dritte ist eine Gegenprobe und deckt seine nicht**
      (Begründung unten). Jedes trifft heute genau **1** Zeile (`grep -c`, dasselbe Muster):
      `grep -n 'zu verschieben'` → **leer (Exit 1)**; `grep -n '^## Verifikation'` → **leer
      (Exit 1)**; `grep -n 'd-check:ignore'` → **leer (Exit 1)** als Gegenprobe **auf einen der
      fünf Haken**. Sie deckt die Streichung des Abschnitts **nicht**: die Direktive steht heute
      auf Zeile **142** (`grep -n 'd-check:ignore'`), der Abschnitt beginnt bei **133** und der
      folgende `## Geschichte` steht bei **145** (`grep -n '^## '`, dieselbe Datei) — ein leeres
      `d-check:ignore` ist also auch mit einem Stand vereinbar, in dem Überschrift und vier Haken
      stehen bleiben. Die Streichung deckt `grep -n '^## Verifikation'`. Dazu `make docs-check` →
      `0 Befund(e)`, Exit 0; die Datei-Zahl derselben Ausgabezeile wandert mit dem
      Markdown-Bestand und ist **kein** Erwartungswert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).

      **Kein Kommando deckt** den Vorspann-Satz, den Status im Kopf und den Abschnitt im Index:
      kein Modul von `.d-check.yml` liest, ob ein Satz **ergänzt** wurde oder welchen Status ein
      Kopf trägt. Ein Gate, das den Stub an seiner Adresse duldet, sagt nichts darüber, dass er
      dort richtig steht. Träger ist die Verifikation am Text (Modul 11).
- [x] **(2) Die sechs Zeiger behalten ihre Adresse; gezogen wird ihre Aussage.** Fünf stehen in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 (fünfter Punkt der
      Erfassungs-Liste, START-KONVENTION, Wächter-Absatz zu deren Bedingung 2, Abweichung 1,
      Abweichung 5), der sechste im Kopf von
      [`.claude/hooks/pretooluse-agent-guard.sh`](../../../../.claude/hooks/pretooluse-agent-guard.sh).
      Es fällt **jeder Satz, der eine Messung als ausstehend führt** oder den Ausfall als offene
      Frage beschreibt; was bleibt, ist der Zustand im Indikativ und ein Zeiger, der auf einen Stub
      mit Verdikt-Status führt.

      **Zwei Formen sind versperrt, und die Schranke ist vorher zu lesen (§3, *Warum die Spec nicht
      auf die ADR zeigt*):** die Stellen ziehen **nicht** auf die ADR (ein Link aus dem
      Spec-Stratum ist `matrix-forbidden`, die bare Kennung `id-unlinked`), und das Verdikt wird
      nicht ausgeschrieben — das wäre der zweite Ort. Der Hook-Kommentar ist kein Spec-Stratum;
      dort bindet [`AGENTS.md`](../../../../AGENTS.md) §3.7, dass der Kommentar beschreibt, was da
      ist.

      **Rot färbt ihn:**
      `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → weiter
      **sechs Zeilen in zwei Dateien**; heute gemessen mit `grep -c` je Datei: **5** in
      `spec/spezifikation.md`, **1** in `.claude/hooks/pretooluse-agent-guard.sh`. Verschwindet
      eine, ist eine Aussage **entfernt** statt nachgezogen. Dazu `make docs-check` grün — er ist
      es nach dem Nachzug, weil sich keine Adresse bewegt, und rot, sobald eine der zwei
      versperrten Formen im Spec-Stratum steht.

      **Kein Kommando deckt den Gegenstand dieses Punktes.** Das Rot-Kommando misst allein die
      **Über**-Löschung: es ist heute grün, nach einem korrekten Nachzug grün — und nach **null**
      Handgriffen ebenfalls grün. `make docs-check` deckt die Verbots-, nicht die Gebots-Seite. Ob
      eine Aussage wirklich gezogen ist, entscheidet allein der Abgleich am Text; Träger ist die
      Verifikation (Modul 11), nicht ein Gate.
- [x] **(3) Der fällige Mutations-Fall färbt den Wächter rot, der die neun Werte hält.**
      Beschrieben als **Eigenschaft, nicht als Adresse**: ein Fall unter `test/mutations/`, der
      einen Eintrag der Positiv-Liste aus `responseKeys()` in `internal/span/response.go`
      **entfernt** und dabei `TestNoResponseFreetextReachesSpan` in
      `internal/span/response_test.go` rot färbt. **Nicht** `TestOnlyAgentToolGetsResponseValues`:
      der hält die **Werkzeug-Achse** und in seiner Gegenprobe **vier** der neun Werte
      (`SpawnedRole`, `TotalTokens`, `InputTokens`, `ModelVersion`) — die zwei Cache-Zähler gehören
      nicht dazu, und ihr Entfernen lässt ihn grün. **Die vier sind an der Gegenprobe gelesen, nicht
      gezählt: kein Kommando trennt sie.** Die **neun** dagegen liefert
      `grep -c 'path: \[\]string' internal/span/response.go` → **9**. Die vorhandenen Fälle
      decken diese Richtung nicht: `grep -ln 'responseKeys' test/mutations/*.sh` → **leer
      (Exit 1)**, und `test/mutations/133-span-werkzeugachse-geweitet.sh` **weitet** die
      Werkzeug-Achse, statt aus der Liste zu entfernen. Die Nummer ist beim Anlegen die nächste
      freie.

      **Rot färbt ihn:** `make mutate` — ein Fall, dessen Mutation grün durchläuft, wird dort als
      Befund gemeldet. **Kein Kommando meldet seine Abwesenheit:** `make mutate` prüft die Fälle,
      die da sind; ohne diesen Fall bleibt alles grün, und Festlegung 2 der ADR bleibt eine Absicht
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Genau deshalb steht er als **eigener** DoD-Punkt
      und nicht als Nebensatz von (1).
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Was der Schnitt aus der Ort-Entscheidung übernimmt — und was er nicht wiederholt

Der Ort ist entschieden: der Stub bleibt liegen, der **Status** trägt den Übergang. Die Begründung
steht in der ADR und wird hier **nicht zweitgeschrieben**. Für den Schnitt folgt daraus dreierlei,
und alles drei ist mechanisch: **kein `git mv`** am Carveout; **ein** Commit statt zwei
([`AGENTS.md`](../../../../AGENTS.md) §3.3 greift bei Move **und** Rewrite — hier gibt es nur den
Rewrite); und ein `carveouts/done/` entsteht nicht, also auch keine `d-check:ignore`-Direktive
dafür.

**Und eine vierte Folge, die man beim Statuswechsel übersieht: die zwei Ort-Anweisungen im Stub
selbst müssen mit.** Sein Auflösungs-Trigger ordnet den Move an, seine Verifikations-Checkliste
führt ihn als Haken. Beides ist kein Regelwerks-Satz, sondern die Erwartung, die der Carveout an
seinen eigenen Ausgang schrieb, als der Ausgang noch offen war. Bleiben sie stehen, trägt die
Weiche die Anweisung, die die Entscheidung verbietet — und **kein Sensor sieht das**, weil sie
keinen Link bricht. Dafür stehen die drei `grep`-Kommandos in DoD (1).

Der Abschnitt `## Auflösungs-Trigger` selbst **bleibt**: die ADR zitiert ihn zweimal verbatim, und
eine Löschung machte Zitate zweier immutabler ADRs quellenlos. Was den Leser trennt, ist der Status
im Kopf desselben Dokuments — und damit er dort nicht erst gesucht werden muss, zeigt der
Vorspann-Satz auf ihn.

### Warum die Spec nicht auf die ADR zeigt — die Schranke, die den Nachzug formt

Die naheliegende Ausführung wäre, die fünf Spec-Stellen auf die ADR zu **verlinken**. Sie ist
versperrt, und zwar mechanisch:

- Das Doku-Gate führt eine **Referenz-Richtung** (SDP): `spec-straten` → `adr` ist **nicht erlaubt**
  ([`.d-check.yml`](../../../../.d-check.yml), `matrix.rules`). Ein Link von
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md) auf die ADR färbt `make docs-check`
  rot.
- Die Kennungs-Regel ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids))
  verlangt für jedes `ADR-`-Token einen Link — **auch in Inline-Code**. Die Kennung dort bar zu
  nennen, ist also ebenfalls rot.
- **Gemessen, nicht angenommen:** `grep -n 'ADR-0' spec/spezifikation.md` liefert genau **einen**
  Treffer, und der steht in §7 Historie — einem der drei Abschnitte, die
  `matrix.exclude-sections` ausnimmt. Die Spec hält die Richtung heute ein.

**Folge für DoD (2):** die fünf Stellen behalten ihren Zeiger und verlieren die **offene Frage** —
der Ausfall im Indikativ, adressiert über den Stub, der mit diesem Slice den Verdikt-Status trägt.
Wer die Begründung sucht, findet sie über den ADR-Index, nicht über einen Abwärts-Link. Das ist
keine Verlegenheit, sondern dieselbe Regel, aus der die Richtung stammt: das Vertrags-Stratum sagt,
**was gilt**, nicht **warum entschieden wurde**.

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Die drei Folgepflichten, die dieser Slice trägt, sind **eine** Bewegung an
   einem Gegenstand: der Stub trägt den Übergang, seine Zeiger verlieren die offene Frage, sein
   Zahn entsteht. Kein zweiter Slice muss mitlanden, damit die Aussage stimmt — im Gegenteil:
   getrennt gelandet, hinterließe jeder Teil einen Zwischenzustand, in dem eine Stelle eine
   entschiedene Frage als offen führt.
2. **Gemeinsames Closure-Kriterium?** Nein. Das Kriterium wäre *„keine Stelle führt die Messung
   mehr als ausstehend"* — und das ist DoD (2), nicht mehr.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv.** Eine Entscheidung ist gefallen und das Repo
   hinkt ihr nach; wiederhergestellt wird Konsistenz, nicht eine neue Fähigkeit. Der fällige
   Mutations-Fall sieht wie ein Zuwachs aus, ist aber der Zahn zu einer **bestehenden** Zusage.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** kein Roadmap-Eintrag, weder jetzt noch beim
Abschluss.

### Die zwei Planner-Posten, die NICHT in diesen Slice gehören — und wohin sie gehen

Die Entscheidung verteilt zwei weitere Folgepflichten an den **Planner**: die zwei Matrix-Zellen der
Repo-Spalte (*Token-Attribution × Repo*, Hintergrund-Teil, und *Cache-Counter × Repo*) tragen
künftig **ADR-Verdikt** statt *deklariert*, und das Carveout-Audit muss den **Status** lesen statt
des Verzeichnisses — sonst zählt es weiter zwei aktive Carveouts und bestätigte eine entschiedene
Sache als offene Frage. Beide liegen **außerhalb** dieses Slice; der erste Grund unten gilt allein
Folgepflicht 3, die zwei folgenden tragen für beide:

- **Die Zellen haben heute keinen Gegenstand — das gilt Folgepflicht 3.** Sie entstehen mit der
  Ergebnis-Notiz der Welle, und die gibt es nicht:
  `ls docs/plan/planning/done/ | grep -c 'welle-09-results'` → **0**. Ein DoD-Punkt darauf zwänge
  diesen Slice, die Closure einer fremden Welle zu eröffnen — oder er wäre nicht prüfbar.
  **Für Folgepflicht 4 trägt der Grund nicht:** die Audit-Regel hat einen Gegenstand, sie steht im
  §3 des Wellen-Plans. Sie liegt aus den zwei folgenden Gründen außerhalb, nicht aus diesem.
- **Ihr Auslöser ist nicht dieser Slice, sondern die Annahme der ADR.** Beide binden mit dem
  Statuswechsel, nicht mit dem Vollzug hier. Was am Wellen-Plan daran hängt, gehört ihm als
  lebendem Planner-Artefakt — nicht einem Slice, der einen anderen Gegenstand vollzieht.
- **Der Slice wäre sonst Quelle und Sensor derselben Aussage.** Das Audit **liest** den Status, den
  DoD (1) **schreibt**. Wer beides in einen Slice legt, prüft seine eigene Änderung mit ihr selbst.

Dazu die harte Schranke aus Modul 5: dieser Slice trägt bereits **drei** slice-eigene DoD-Punkte,
jeder mit seinem Rot-Kommando. Ein vierter hieße nicht, dass die DoD länger sein muss, sondern dass
der Schnitt falsch ist.

**Wo sie landen — und der Träger steht dort, nicht nur hier:** die zwei Zellen und die Audit-Regel
gehören in die **Closure von [welle-09](../welle-09-modul-15-konformitaet.md)**; dort entstehen die
Zellen, dort läuft das Audit. **Der Wellen-Plan führt sie selbst:** sein Closure-Trigger verlangt
das Audit am **Status** statt am Verzeichnis, nennt für die zwei Zellen den Wert *ADR-Verdikt* und
schreibt die **Reihenfolge** — Kopf-Status vor den Zellen — samt Prüfkommando dorthin, wo sie
eingehalten werden muss. Prüfbar statt zugesagt:
`grep -q '0021' docs/plan/planning/welle-09-modul-15-konformitaet.md` → **Exit 0**. Stünde der
Träger nur hier, läge die Reihenfolge nach dem Abschluss allein in einem Zeitdokument unter
`done/`. Die Folge für **diesen** Slice steht in §6.

### Berührte Dateien

| Datei / Komponente | Änderungs-Art | Wer schreibt | Begründung |
|---|---|---|---|
| [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) | update (vier Stellen), **kein** `git mv` | Implementer | Status · `Letzte Prüfung` und Geschichte-Zeile · Handlungs-Anweisung raus und Vorspann-Satz rein · Abschnitt *Verifikation* ganz raus. **Ein** Commit — es gibt nur den Rewrite |
| [`docs/plan/carveouts/README.md`](../../carveouts/README.md) | update (eine Stelle) | Implementer | §Aktiv verliert die Zeile, ein eigener Abschnitt für den permanenten Übergang bekommt sie — der Index ist die Übersicht, nicht eine zweite Quelle |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update (fünf Stellen in §5), Adresse **unverändert** | Implementer; die Eigentumsfrage ist **offen, aber keine Eintritts-Bedingung** | die offene Frage fällt, der Zustand bleibt im Indikativ; keine ADR-Verlinkung (s. o.). Die Folgepflicht nennt einen *Spec-Eigentümer*; `ls .claude/agents/` führt **sechs** Rollen und keine dieses Namens, und [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 weist **zwei** Artefakte zu und lässt die übrigen ausdrücklich offen — *offen* heißt unentschieden, nicht gesperrt. Geschrieben wird das Stratum im Slice; die Messung dazu und die benannte Lücke stehen in §6 |
| [`.claude/hooks/pretooluse-agent-guard.sh`](../../../../.claude/hooks/pretooluse-agent-guard.sh) | update (Kopf-Kommentar), Zeiger **unverändert** | Implementer | ein Kommentar beschreibt, was da ist ([`AGENTS.md`](../../../../AGENTS.md) §3.7): die Messung ist gefahren, nicht ausstehend |
| `test/mutations/` (ein neuer Fall) | neu | Implementer | der Zahn zu Festlegung 2; Eigenschaft in DoD (3), Nummer beim Anlegen die nächste freie |
| `internal/span/response.go`, `internal/span/response_test.go` | **unverändert** | — | der neue Fall mutiert sie zur Laufzeit; wer sie ändert, verschiebt die Zusage, statt ihren Zahn zu bauen |
| [`docs/plan/adr/`](../../adr/) | **unverändert** | — | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4); dieser Slice vollzieht, er entscheidet nicht |
| [welle-09](../welle-09-modul-15-konformitaet.md) | **unverändert durch diesen Slice** | Planner (eigener Vorgang) | die zwei Matrix-Zellen und die Audit-Regel gehören der Closure jener Welle; ihr Träger steht dort (s. o.), und der Vollzug fällt mit der Closure an |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | — | sie führt für slice-071 einen Auflösungs-Trigger, den die Entscheidung aufgehoben hat; der Nachzug ist Planner-Arbeit am lebenden Plan und gehört zur welle-09-Closure (§6) |
| [slice-071](../open/slice-071-cache-zaehler-getrennt.md) | **unverändert** | — | fremder Slice-Plan; seine Rückführung ist ausgelöst, und die Frage dahinter gehört dem Architect (§6) |
| `internal/emit/` | **unverändert** | — | die emittierte Ebene ist von der Entscheidung nicht berührt und führt heute weder Span-Emitter noch Agent-Guard; bekommt sie je einen, gilt die Grenze dort und gehört dort **genannt** |

## 4. Trigger

**`open` → `next`: erfüllt.**
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) ist **Accepted** —
`grep -n '^\*\*Status:' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` gibt
`3:**Status:** Accepted` aus, und die Zeile in
[`docs/plan/adr/README.md`](../../adr/README.md) führt dieselbe Angabe. Solange sie *Proposed*
stand, vollzöge dieser Slice eine Entscheidung, die noch zur Debatte steht; sie steht es nicht
mehr. Dieser Slice ändert an der ADR nichts, auch nicht ihren Status.

**`next` → `in-progress`: WIP-Limit prüfen.** `ls docs/plan/planning/in-progress/` zeigt heute
außer der Roadmap keinen Slice. Die Belegung wandert mit dem Bestand — sie ist beim Eintritt neu zu
fahren, nicht aus dieser Zeile abzuschreiben.

Rückführungen:

- `in-progress` → `open`: die fünf Spec-Stellen lassen sich **nicht** ohne Verweis auf das Verdikt
  formulieren, weil eine von ihnen die Begründung mitträgt statt nur den Zustand. Dann ist zuerst
  zu entscheiden, was das Vertrags-Stratum an dieser Stelle überhaupt sagen soll — kein Nachzug,
  sondern eine **Architektur-Frage**, und ihr Adressat ist der **Architect**. Eine Rollen-Zuweisung
  für das Stratum ist dafür nicht verlangt: die Frage betrifft den **Inhalt** von Rang 2, nicht
  sein Eigentum.
- `in-progress` → `next`: der fällige Mutations-Fall erweist sich als eigener Gegenstand (die
  Mutation trifft mehr als einen Eintrag der Positiv-Liste, oder der Test hält sie nicht). Dann
  trennt ein Re-Schnitt den **geschriebenen Übergang samt Zeigern** vom **Zahn**; beide sind
  einzeln lieferbar und einzeln prüfbar.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation (Modul 11)
bestätigt die DoD; `make gates` und `make mutate` grün; Closure-Notiz mit Steering-Loop-Eintrag.

**Der Link-Zug gehört zu den Moves dieses Slice — und das sind seine eigenen.** Der Carveout wird
nicht bewegt; nach dem Vollzug zeigt kein Verweis auf eine andere Adresse als vorher. Diese
Plan-Datei dagegen wandert dreimal: `open` → `next`, `next` → `in-progress` und am Ende nach
`done/`. Jeder ist ein eigener, **reiner** Move-Commit
([`AGENTS.md`](../../../../AGENTS.md) §3.3); **nach jedem** folgt der
Link-Reconciliation-Commit. Der Eintritts-Move braucht ihn genauso wie der Abgang — dieselbe Lehre,
die [slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7 als Plan-Defekt benannt hat,
nachdem sein §5 den Zug nur für `done/` schrieb und er zweimal gebraucht wurde.

**Betroffen ist die eingehende Menge**, denn sie nennt das Quellverzeichnis im Pfad:
`grep -rn ']([^)]*open/slice-089-carveout-co-002-ueberfuehren\.md)' --include='*.md' docs` → heute
**6** Zeilen in **3** Dateien — zwei Zeitdokumente unter `docs/plan/planning/done/` und der
Wellen-Plan. Das ist eine
**Bestandsaufnahme, kein Erwartungswert** — jedes neue Dokument, das auf diesen Slice zeigt, hebt
die Zahl
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); vor jedem Move ist das Kommando mit dem dann geltenden Quellverzeichnis neu zu fahren.
Die eigenen `../`-Links dieser Datei liegen in allen vier Verzeichnissen auf gleicher Tiefe; ob
deshalb wirklich keiner bricht, entscheidet nicht dieser Satz, sondern **`make docs-check` nach
jedem Move** — solange er rot ist, ist der Zug nicht fertig.

**Der Vollzug selbst hat drei Kommandos und eine Lücke.** Die vier Inhaltsänderungen am Stub
brechen keinen Link und werden von keinem Gate gesehen; die drei `grep`-Kommandos aus DoD (1) sind
ihr einziger Sensor, und der Vorspann-Satz hat auch den nicht. Der Closure-Trigger ist deshalb
nicht mit *grün* erfüllt, sondern erst mit dem Abgleich am Text.

## 6. Risiken und offene Punkte

- **Der Nachzug erzeugt leicht einen zweiten Ort für das Verdikt.** Wer beim Ziehen der fünf
  Spec-Stellen die Begründung mitschreibt, hat die ADR abgeschrieben — und zwei Fassungen driften.
  Die Probe ist eine Frage an den Satz: sagt er, **was gilt**, oder sagt er, **warum**? Das Zweite
  gehört nicht ins Vertrags-Stratum. Derselbe Fehler in der anderen Richtung wäre, den Zeiger
  selbst zu entfernen: dann verliert die Stelle ihre Weiche, und DoD (2) ist rot.
- **Der Stub verliert leicht mehr als die Anweisung.** Ein breites Muster trifft zu viel:
  `grep -c 'done/' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` → heute **5** Zeilen, davon
  **drei** Verweise auf ein abgeschlossenes Planungs-Artefakt, die **bleiben**. Nur das schmale
  Muster aus DoD (1) trifft die Handlungs-Anweisung; und der Abschnitt `## Auflösungs-Trigger`
  bleibt stehen, weil die ADR ihn zitiert.
- **Der Vorspann-Satz ist die eine Zusage ohne Sensor.** Alle drei `grep`-Kommandos können leer
  sein, während er fehlt, und `make docs-check` bleibt dabei grün. Träger ist die Verifikation am
  Text — hier benannt, statt vom Gate erwartet.
- **Reihenfolge gegenüber [welle-09](../welle-09-modul-15-konformitaet.md), nicht
  Mitgliedschaft.** Deren Carveout-Audit liest den Zustand des Stubs. Schlösse die Welle, bevor
  dieser Slice gelandet ist, läse es *Aktiv* und schriebe die zwei Zellen als *deklariert* — falsch
  gegen eine angenommene ADR. Die Bedingung ist prüfbar und schmal: der Kopf des Stubs trägt den
  Verdikt-Status, bevor die Ergebnis-Notiz der Welle die Zellen setzt. Sie steht als Bedingung in
  deren Closure-Trigger und gehört dem Planner jener Closure, nicht diesem Slice.
- **`test/mutations/` ist kein Gate.** Der neue Fall läuft in `make mutate`, nicht in `make gates`;
  er behauptet keinen neuen Wächter, sondern prüft die Zähne eines vorhandenen
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  `make mutate` läuft pro Push in CI
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)).
- **Zwei lebende Planungs-Artefakte führen die Schwelle nach dem Vollzug weiter als offen.** Die
  [Roadmap](../in-progress/roadmap.md) — Source Precedence Rang 5 — schreibt für slice-071 *„die
  Rechnung liegt hinter dem Auflösungs-Trigger von `CO-002`"*, und
  [slice-071](../open/slice-071-cache-zaehler-getrennt.md) nennt den Carveout auf **10** Zeilen
  (`grep -c 'CO-002' docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md`). **Wie viele
  davon die Schwelle als offen führen, trennt kein Kommando** — das ist von Hand zu lesen. Beide
  sind **Planner**-Arbeit am lebenden Plan und keine Zeile dieses Slice; der Wellen-Plan führt sie
  als vor seinem Abschluss zu ziehen.
- **Die Rückführung von slice-071 ist ausgelöst.** Sein §4 nennt für den Fall, dass `CO-002`
  **negativ** entschieden wird, ausdrücklich eine **Architect-Frage**: ob das Spec-Stratum die
  Cache-Festlegung ohne Rechnung trägt, oder ob die Zelle *Cache-Counter × Repo* auf *ADR-Verdikt*
  wechselt. Die Bedingung ist mit der Annahme der ADR erfüllt, die Frage damit **fällig** — und sie
  gehört dem **Architect**. Dieser Slice benennt sie und fasst slice-071 nicht an.
- **Eine Folge in die andere Richtung:** slice-071 §6 zeigt auf die Verifikations-Liste des Stubs
  als den Ort, an den eine fehlende Zeile gehört — DoD (1) streicht diese Liste. Es bricht dabei
  **kein Link**: `grep -rn 'CO-002-token-achse-je-rolle\.md#' --include='*.md' .` → **leer
  (Exit 1)**, kein Verweis zielt auf einen Abschnitt des Stubs. Der Prosa-Verweis zeigt danach
  trotzdem ins Leere und gehört in denselben Architect-Lauf.
- **Für das Technik-Stratum weist keine Quelle eine schreibende Rolle zu — und das hält den Slice
  nicht auf.** [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
  weist **zwei** Artefakte zu und lässt die übrigen ausdrücklich offen; im Regelwerk steht dazu
  nichts (`grep -rniE 'wer (schreibt|pflegt|besitzt).*(spec|stratum)|schreibende rolle' .harness/baseline/v3.5.2/regelwerk/`
  → **leer, Exit 1**). *Offen* heißt **unentschieden, nicht gesperrt**, und die gelebte Praxis ist
  messbar: `git log --oneline -- spec/spezifikation.md` → **16** Commits;
  `git log --format='%s' -- spec/spezifikation.md` davon **9** mit Slice-Präfix
  (`grep -c '^slice-'`) und **0** in der Rollen-Commit-Form (`grep -c '^Rolle '`). Der Slice
  braucht die Zuordnung deshalb **nicht** als Vorbedingung; er nennt die Lücke, und geschlossen
  wird sie, wenn jemand sie entscheidet — als eigene ADR, nicht nebenbei.
- **Der Stub verliert mit `## Verifikation (nach Auflösung)` eine Sektion der vendored Ziel-Form.**
  Die Streichung ordnet die ADR an und ist damit bindend; benannt gehört, was daraus folgt:
  `.d-check.yml` führt kein Modul, das Carveout-Struktur prüft, und die Begründung für den
  fehlenden Adaptions-Eintrag gilt der **Ablage**-Frage, nicht der Sektion. Ein späterer
  Ziel-Form-Abgleich sieht damit eine Abweichung ohne Register-Eintrag. **Dieser Slice entscheidet
  das nicht** — Träger wäre ein Architect-Lauf.
- **Nicht in diesem Slice:** jede Änderung an
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) selbst (immutabel ab
  *Accepted*); die zwei Planner-Posten aus §3 (Matrix-Zellen und Audit-Regel — welle-09-Closure);
  der Eintrag im Adaptions-Block, den die Entscheidung ausdrücklich **nicht** anordnet (Architect —
  nichts zu tun); die Klärung, welche Rolle das Technik-Stratum schreibt — nach
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 offen, und
  **keine Eintritts-Bedingung dieses Slice** (Datei-Tabelle in §3); die
  Erlaubnis-Frage zum Transkript als Quelle (Auftraggeber); und der Geltungsbereich von
  [`AGENTS.md`](../../../../AGENTS.md) §3.7 für verbatim abgelegten Skript-Text (Architect,
  eigener Lauf).

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) trägt an seiner
unveränderten Adresse den Verdikt-Status: `grep -n '^\*\*Status:' docs/plan/carveouts/CO-002-token-achse-je-rolle.md`
gibt `3:**Status:** Permanent — übergeführt in` aus, die Kennung
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) steht in der Folgezeile. Die
zwei Ort-Anweisungen, die der Stub an seinen eigenen Ausgang schrieb, als der Ausgang noch offen
war, sind aufgehoben — `grep -n 'zu verschieben'` und `grep -n '^## Verifikation'` über derselben
Datei sind beide **leer (Exit 1)**. Der Abschnitt `## Auflösungs-Trigger` steht, damit die zwei
ADRs, die ihn verbatim zitieren, ihre Quelle behalten; sein erster Satz zeigt auf den Status im
Kopf. Der Index [`docs/plan/carveouts/README.md`](../../carveouts/README.md) führt den Eintrag in
einem eigenen Abschnitt statt unter `## Aktiv` — `grep -n '^## '` über der Datei zählt **3**
Abschnitte (*Aktiv* · *Permanent — in eine ADR übergeführt* · *Aufgelöst*); die Zahl wandert mit
dem Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

Die sechs Zeiger stehen unverändert an ihrer Adresse —
`grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh | wc -l` → **6**,
je Datei `grep -c` → **5** und **1** — und keiner führt die Messung mehr als ausstehend. Ein
zweiter Ort für das Verdikt ist nicht entstanden: `grep -c 'ADR-0' spec/spezifikation.md` → **1**,
und dieser eine Treffer steht in §7 Historie, einem der Abschnitte, die `matrix.exclude-sections`
in [`.d-check.yml`](../../../../.d-check.yml) ausnimmt. Der fällige Zahn existiert als
`test/mutations/151-span-positivliste-eintrag-entfernt.sh`: er entfernt einen Eintrag der
Positiv-Liste, die `grep -c 'path: \[\]string' internal/span/response.go` → **9** zählt, und färbt
`TestNoResponseFreetextReachesSpan` rot.

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD vollständig.** Die Punkte (1)–(3) sind der Gegenstand, (4)–(6) die Rahmenpunkte; die
   Belege stehen oben und unten.
2. **Review konform (Modul 10), mit ausgestelltem Verdikt in jeder Runde.**
   [Runde 1](../../../reviews/2026-08-22-slice-089-review.md) (`fd4ec7d`): **blockierend**,
   0 HIGH · 3 MEDIUM · 1 LOW · 2 INFO —
   `grep -c '^### F-' docs/reviews/2026-08-22-slice-089-review.md` → **6**.
   [Runde 2](../../../reviews/2026-08-22-slice-089-bestaetigungsrunde.md) (`c2e6851`): **frei**,
   die zwei blockierenden MEDIUM an ihrem Gegenstand erledigt, ein neuer LOW —
   `grep -c '^### B-' docs/reviews/2026-08-22-slice-089-bestaetigungsrunde.md` → **1**. Keine
   Kategorie ist gestiegen.
3. **Verifikation (Modul 11) bestätigt die DoD.**
   [Report](../../../reviews/2026-08-23-slice-089-verify.md) (`7436327`): **DoD (1)–(5) bestätigt,
   ohne Befund.** Der Verifier hat `make gates` und `make mutate` selbst gefahren und vier Sonden
   in einer Wegwerf-Kopie außerhalb des Repos gegen die Abdeckungsgrenzen gesetzt, die der Plan
   für sich selbst zieht.
4. **`make gates` und `make mutate` grün.** Belege unten unter *Gates*.
5. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Wo der Liefergegenstand in der Historie liegt.** `git log --oneline --grep='slice-089' 7436327`
zählt **20** Commits — der Stand gehört ins Kommando, sonst wandert die Zahl mit jedem weiteren
Commit und ist kein Erwartungswert. Die Sache selbst liegt in **drei**: `83b3f83` schreibt den
Übergang, die sechs Zeiger und den Mutations-Fall; `d3409b3` zieht die Gattungs-Behauptung des
Index und die Belegklasse an zwei Fundorten; `89450fa` dieselbe Belegklasse am dritten. Die
Verdikte liegen in `fd4ec7d` und `c2e6851`, die Verifikation in `7436327`. Die Lifecycle-Commits
`d332b9c` (`open → next`) und `7053494` (`next → in-progress`) sind reine Moves, `abbefcb` und
`fa4a05d` die Link-Züge danach. Wer den Slice sucht, findet ihn über diese Commits und **nicht**
in der Roadmap: `grep -c 'slice-089' docs/plan/planning/in-progress/roadmap.md` → **0** (Exit 1),
wie [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 es für wellenlose Arbeit verlangt; Setzung 3 lässt auch die Closure spurlos an ihr
vorbeigehen. Der Zustand ist das Verzeichnis.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst gezogen hat.**

- **Der Vorspann-Satz im Stub hat keinen Sensor.** Alle drei `grep`-Kommandos aus DoD (1) können
  leer sein, während er fehlt, und `make docs-check` bleibt dabei grün. Er steht, und der Beleg
  dafür ist der Abgleich am Text, nicht ein Lauf.
- **Das Rot-Kommando von DoD (2) misst die Über-Löschung, nicht den Nachzug.** Die sechs Zeilen
  sind vor dem Vollzug vollzählig, nach dem Vollzug vollzählig und nach **null** Handgriffen
  ebenfalls. Was der Punkt zusagt, entscheidet allein der Abgleich am Text; der Plan sagt das
  selbst, und genau dort liegt der Steering-Loop-Eintrag.
- **Die zwei Matrix-Zellen und die Audit-Regel liegen außerhalb.** Sie entstehen mit der
  Ergebnis-Notiz von [welle-09](../welle-09-modul-15-konformitaet.md), und ihr Träger steht dort,
  nicht hier: `grep -c '0021' docs/plan/planning/welle-09-modul-15-konformitaet.md` → **7**, und
  die Zeilen der Slice-Tabelle zu slice-071 und slice-068 tragen den Wert *ADR-Verdikt*.
- **Die emittierte Ebene ist nicht berührt.** `grep -rn 'CO-002' internal/emit/` → **leer
  (Exit 1)**; bekommt das emittierte Repo je einen Span-Emitter oder einen Agent-Guard, gilt die
  Grenze dort und gehört dort **genannt**.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Wo der Sensor die Adresse misst und der Gegenstand die Aussage ist, schuldet der DoD-Punkt die
Aussagen-Menge: aufgezählt und mit ihrer Richtung, nicht nur beziffert.** Ein Punkt, der von sich
selbst sagt *„Kein Kommando deckt den Gegenstand"*, hat die Lücke damit **benannt** und noch nichts
über sie **gesagt**. Die Zeiger-Menge zu nennen ist die leichte Hälfte — ein `grep` liefert sie;
die schwere ist die Menge der Sätze, die an diesen Zeigern etwas behaupten, und was mit ihnen
geschehen soll.

**Gemessen an diesem Slice.** DoD (2) nannte die Zeiger-Menge exakt und mit Kommando: sechs Zeilen
in zwei Dateien. Sie stimmte nach dem ersten Vollzug und war in keiner Runde ein Befund. Die
Aussagen-Seite nannte der Punkt in **einer** Richtung — *„Es fällt jeder Satz, der eine Messung als
ausstehend führt"* — und in **keiner** Menge. Sie brauchte drei Durchgänge und drei Rollen:

| Durchgang | Was offen war | Commit |
|---|---|---|
| Vollzug | — die sechs Zeiger stehen, die offene Frage ist weg | `83b3f83` |
| Review Runde 1, F-2 | die Belegklasse fehlt an zwei Fundorten (Erfassungs-Punkt 5, Hook-Kopf) | `d3409b3` |
| Review Runde 2, B-1 | dieselbe Belegklasse fehlt am dritten Fundort (START-KONVENTION) | `89450fa` |
| Verifikation, D-2 | der Plan verlangt für alle drei nur *fallen*; nötig war *fallen und einordnen* | — die Lücke, die dieser Eintrag schließt |

Über die zwei Runden und die Verifikation stehen **neun** Posten:
`grep -c '^### F-' docs/reviews/2026-08-22-slice-089-review.md` → **6**,
`grep -c '^### B-' docs/reviews/2026-08-22-slice-089-bestaetigungsrunde.md` → **1**,
`grep -c '^\*\*D-[12] ' docs/reviews/2026-08-23-slice-089-verify.md` → **2**. **Vier** davon —
F-2, F-4, B-1, D-2 — sitzen auf der Aussagen-Seite, **keiner** auf der Zeiger-Seite. Die Zuordnung
ist ein **Urteil, kein Muster**, und steht deshalb als Untergrenze
([`AGENTS.md`](../../../../AGENTS.md) §3.6); mechanisch ist allein der Nenner.

**Warum die drei Additive kein Ausbruch aus dem Plan waren.** Dazugekommen ist an allen drei
Stellen die Belegklasse: der **Ausgang** des Versuchs ist gemessen, die **Übernahme** der
Hook-Ausgabe ist eine Sicht am Dialog. [`AGENTS.md`](../../../../AGENTS.md) §3.6 lässt keine
Zusage zu, die breiter ist als ihr Beleg, und das Mess-Dokument führt genau diese Grenze selbst
([`2026-08-21-updatedinput-messung.md`](../../../reviews/2026-08-21-updatedinput-messung.md) §7).
Ein DoD-Punkt, der nur vom Fallen spricht, verbietet die Einordnung dem Wortlaut nach — die
höherrangige Quelle setzt sich durch, und der Plan hatte den Konflikt erzeugt, statt ihn zu
entscheiden.

**Dieselbe Regel auf der Reviewer-Seite, ebenfalls gemessen.** Runde 1 zitierte für die Form der
Belegklasse zwei Nachbarsätze derselben Spec-Sektion als Muster der guten Form. Der dritte Fundort
lag fünfundzwanzig Zeilen darunter und trug die ungeteilte Fassung. **Eine Stelle, die ein Review
als Muster zitiert, ist damit nicht geprüft** — der Befund nennt einen **Fundort**, die Sache hat
eine **Fundmenge**.

**Der Träger, den [slice-088](../done/slice-088-dcheck-pin-v0620.md) §7 für genau diesen Fall
vergeben hat, hat zur Hälfte getragen.** Er wies den *Zieh-Fall* seiner Regel — *eine gemessene
Aussage lebt so oft, wie sie geschrieben wurde* — diesem Slice zu, mit DoD (2) als Griff und dessen
Fundort-Suche als Kommando. Für die **Adresse** ist die Zuweisung eingelöst: die Suche hielt alle
sechs Zeiger, ohne einen Befund. Für die **Aussage** hielt sie nichts, weil sie Zeiger zählt. Ein
Träger, der aus einem Kommando besteht, trägt so weit wie das Kommando reicht — dieselbe Grenze,
die [slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7 als *eine Zusage reicht nur
so weit wie ihr Sensor* formuliert, hier auf den **Träger** angewandt statt auf die Zusage.

**Träger dieser Regel — benannt, weil eine Notiz in `done/` keiner ist.** Was in einer
geschlossenen Slice-Datei steht, schlägt kein Lauf wieder auf, und das ist am Bestand messbar: von
den `done/`-Plänen mit einer Closure-Notiz
(`grep -l '^## 7\. Closure-Notiz' docs/plan/planning/done/*.md | wc -l` → **78**) wird der
überwiegende Teil aus keinem lebenden Artefakt heraus überhaupt genannt — **56**, gezählt über
denselben Prüfbereich, den
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
für *lebend* definiert:

```sh
live=$(git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**')
for f in $(grep -l '^## 7\. Closure-Notiz' docs/plan/planning/done/*.md); do
  grep -qF "$(basename "$f")" $live || echo "$f"; done | wc -l
```

Beide Zahlen wandern mit dem Bestand und sind **kein** Erwartungswert; die Aussage ist das
Verhältnis, nicht die Ziffer — und *genannt* ist noch nicht *gelesen*, die Zahl ist damit die
freundliche Obergrenze. Der Gegenstand dieser Regel ist der **Schnitt**; gelesen wird sie nur, wenn
sie dort liegt, wo geschnitten wird. Drei Orte kommen in Frage:

- **Der Adaptions-Block in [`harness/conventions.md`](../../../../harness/conventions.md)** — der
  Ort für eine Verschärfung, die einen Sensor-Vorbehalt trägt. Geschrieben vom **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). **Das ist der
  vergebene Träger.** Ein ADR braucht er nicht: die Regel **hebt** eine Anforderung an und senkt
  keine Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.5).
- **[`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md)** — der
  Anweisungssatz, den ein Planner-Lauf beim Schnitt tatsächlich liest, und damit der wirksamste
  Ort. Er scheidet nicht inhaltlich aus, sondern weil keine Quelle sagt, wer ihn schreibt (s. u.).
- **Der nächste Schnitt derselben Bauart** — die Form, die hier zur Hälfte getragen hat. Als
  **alleiniger** Träger ausgeschlossen, mit dem Grund im Absatz darüber.

**Fällig ist der Eintrag beobachtbar, nicht nach Kalender:** beim nächsten Slice, dessen DoD-Punkt
von sich selbst sagt, dass kein Kommando seinen Gegenstand deckt. Das Ereignis meldet sich —
`grep -rn 'Kein Kommando deckt' docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress docs/plan/planning/*.md`
findet die Punkte, die die Aufzählung schulden. Über den lebenden Plänen ist die Suche mit dem
Abgang dieser Datei **leer (Exit 1)**; ihr erster Treffer danach ist der Auslöser.

**Zweiter Eintrag — eine Prüfhandlung, und wo ihr Träger endet.**

**Eine Sensor-Zahl ist gemeldet, wenn die Zeile vorliegt, die sie ausgibt — nicht, wenn der Lauf
sie ausgeben wird.** Bei `make mutate` trennt die zwei Zustände ein Wort:
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) schreibt eine **Kopf**zeile vor
dem ersten Fall und eine **Summen**zeile nach dem letzten, und beide tragen dieselbe erste Zahl.
Beide Quellzeilen zeigt
`grep -n 'mutate: \${#cases\[@\]} Faelle\|mutate: \$pass_count ok' harness/tools/mutate.sh`; ihre
Ausgabe lautet

```
mutate: 144 Faelle (je ein voller make-test-Zyklus, das dauert)
mutate: 144 ok, 0 Befund(e)
```

Unterscheidend ist erst `grep -nE '^mutate: [0-9]+ ok, [0-9]+ Befund'` über dem Protokoll. Ein
Muster, das beide Zeilen trifft, liest aus einem **laufenden** Protokoll eine Zahl, die über den
Ausgang nichts sagt — und wer daraus grün abnimmt, hat über einem Sensor abgenommen, dessen
verbleibende Fälle noch einen Befund liefern können.

**Träger:** die Sache trägt
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 bereits — *„wer sie schreibt, hat es über dem Baum gefahren, von dem sie spricht"*. Was
sie **nicht** trägt, ist der Fundort: ihr Geltungsbereich sind die lebenden, repo-eigenen
Markdown-Artefakte, und die Zahl stand in einer Übergabe an einen Rollen-Lauf. Der Posten geht an
den **Architect** und braucht keine neue Erinnerung — derselbe Eintrag führt einen
Auflösungs-Trigger, der ohnehin fällig wird (nächster d-check-Pin-Sprung, früher sobald
`grep -c 'structure' .d-check.yml` über **0** steigt). Mitzuentscheiden ist dort: gilt die Setzung
auch für Commit- und Übergabe-Nachrichten? Ihre eigene Begründung zählt einen Fundort in einer
Commit-Message bereits mit, ihr Geltungsbereich nennt die Gattung nicht.

**Keinen Träger bekommt der Weg über das Skript, und der Grund ist gemessen:** die zwei Zeilen sind
bereits unterscheidbar — `Faelle` gegen `ok, … Befund(e)`. Mehrdeutig war nicht die Ausgabe,
sondern der Zeitpunkt des Lesens; ein Handgriff am Skript verschöbe das Problem, statt es zu
treffen.

**Benannte Spec-Lücke — für die Rollen-Anweisungssätze weist keine Quelle eine schreibende Rolle
zu, und diesmal hält das einen Träger auf.** `ls .claude/agents/ | wc -l` → **6** Rollen-Dateien,
`ls .claude/commands/ | wc -l` → **3** Anweisungssätze;
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 weist **zwei**
Artefakte zu — [`AGENTS.md`](../../../../AGENTS.md) §3 und den Adaptions-Block — und sagt über die
übrigen ausdrücklich nichts
(`grep -c 'Über die übrigen Norm-Artefakte trifft diese ADR' docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md`
→ **1**). §6 dieses Plans benennt dieselbe Lücke für das Technik-Stratum; das ist der **zweite**
gemessene Fall in einem Slice — und der erste, in dem die Lücke die Wahl des Trägers bestimmt: der
wirksamste Ort für die Regel oben ist der Anweisungssatz, den ein Planner-Lauf beim Schnitt liest,
und geschrieben wird er nicht, weil ihn niemand besitzt. *Offen* heißt weiter unentschieden, nicht
gesperrt; entschieden wird es in einer **eigenen ADR** (Architect), nicht nebenbei.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die zwei Matrix-Zellen (*Token-Attribution × Repo*, Hintergrund-Teil, und *Cache-Counter × Repo*) auf *ADR-Verdikt*, und das Carveout-Audit liest den **Status** statt des Verzeichnisses | **Closure von [welle-09](../welle-09-modul-15-konformitaet.md)** (Planner). Der Wellen-Plan führt beides selbst, samt der Reihenfolge Kopf-Status vor den Zellen |
| Die Roadmap-Zeile zu slice-071 und [slice-071](../open/slice-071-cache-zaehler-getrennt.md) selbst führen die aufgehobene Schwelle weiter als offen | **Closure von [welle-09](../welle-09-modul-15-konformitaet.md)** (Planner). Kein DoD-Punkt dieses Slice fordert sie. `grep -c 'CO-002' docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md` → **10** Zeilen; wie viele davon die Schwelle als offen führen, trennt kein Kommando |
| Die Architect-Frage aus slice-071 §4 — trägt das Spec-Stratum die Cache-Festlegung ohne Rechnung, oder wechselt die Zelle auf *ADR-Verdikt*? — und der Prosa-Verweis in seinem §6 auf die gestrichene Verifikations-Liste des Stubs | **Architect**, eigener Lauf; ausgelöst mit der Annahme der ADR. Ein Link bricht dabei nicht: `grep -rn 'CO-002-token-achse-je-rolle\.md#' --include='*.md' .` → **leer (Exit 1)** |
| Die geschärfte Regel oben braucht ihren Eintrag im Adaptions-Block | **Architect**; fällig beim nächsten DoD-Punkt, der seinen Gegenstand als ungedeckt ausweist — auffindbar mit der Suche oben |
| Gilt [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) auch für Commit- und Übergabe-Nachrichten? | **Architect**, an dessen bereits fälligem Auflösungs-Trigger — kein neuer Termin |
| Wer die Rollen-Anweisungssätze unter `.claude/` schreibt, und wer das Technik-Stratum | **Architect**, eigene ADR. Zwei gemessene Fälle in diesem Slice |
| Dem Stub fehlt die Sektion `## Verifikation (nach Auflösung)` der vendored Ziel-Form, und [`.d-check.yml`](../../../../.d-check.yml) führt kein Modul, das Carveout-Struktur prüft — ein späterer Ziel-Form-Abgleich sieht eine Abweichung ohne Register-Eintrag | **Architect**, benannt für einen künftigen Schnitt. Der ausdrücklich **nicht** angeordnete Adaptions-Eintrag gilt der **Ablage**-Frage, nicht der Sektion |
| Die Zeitmarke `83cf01d` in der Geltungs-Konfiguration des Stubs benennt den Guard-Stand; die fünf Spec-Stellen tragen seit `89450fa` zusätzlich ein zweites Datum | **kein Träger, und das ist entschieden**: der Satz bleibt wahr, kein DoD-Punkt und keine Folgepflicht adressiert die Zelle. Wer die Tabelle das nächste Mal anfasst, zieht die Marke mit |
| Die *„vier der neun"* in der Begründung des Mutations-Falls tragen ihre Beleg-Grenze nicht mit | **kein Träger, und das ist entschieden**: die vier sind an der Gegenprobe **gelesen**, kein Kommando trennt sie, und DoD (3) sagt das selbst; [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) bindet Shell-Skripte nicht |

**Gates.** Der [Verifikations-Lauf](../../../reviews/2026-08-23-slice-089-verify.md) hat sie über
dem Baum bei `89450fa` selbst gefahren, Exit-Codes getrennt erhoben: `make gates` **Exit 0** und
`make mutate` **Exit 0** mit `mutate: 144 ok, 0 Befund(e)`, Fall 151 unter seiner eigenen Mutation
rot gesehen. Über dem Baum bei `7436327` — den Verifikations-Report eingerechnet — ist `make gates`
hier wiederholt, **Exit 0**: `baseline-verify: v3.5.2 OK — 42 Dateien`,
`d-check: 350 Datei(en) geprüft, 0 Befund(e)`, golangci-lint `0 issues.`, bats `1..143` mit
`grep -cE '^ok [0-9]+'` → **143** und `grep -cE '^not ok'` → **0**,
`comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün. Der Stempel band den Lauf
an den Baum, nicht an eine Erinnerung: `bash harness/tools/working-tree-hash.sh` und
`.harness/state/gates-passed.diffsha` waren danach byte-gleich, und `record-gates` schreibt ihn nur
als **letzter** Prerequisite grüner Gates
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)).
Die Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Diese Notiz, der `done/`-Move und der Link-Zug danach verschieben den Stempel erneut;
der Lauf, der ihn wieder bindet, gehört zu ihnen.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
[`docs/plan/carveouts/`](../../carveouts/), das Technik-Stratum
([`spec/spezifikation.md`](../../../../spec/spezifikation.md)), `.claude/hooks/` und
`test/mutations/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).

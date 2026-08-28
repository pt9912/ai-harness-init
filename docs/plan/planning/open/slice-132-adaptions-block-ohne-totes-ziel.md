# Slice slice-132: Der Adaptions-Block trägt seinen datierten Beleg ohne totes Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — der Befund entsteht durch den Tausch und hält
ihr Closure-Kriterium *„`make gates` grün"* auf. Ihre Closure-Bedingung ist von dieser DoD
verschieden.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate, das strukturell rot bleibt, ist die Kehrseite des halluzinierten: es meldet, ohne dass
jemand handeln kann),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 4 — *Adresse entfällt,
Text bleibt* — ist der eine Kandidat; sie ist für **Zeitdokumente** geschrieben, und ob ein
append-only-Eintrag in einer lebenden Datei einer ist, ist die offene Frage),
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (ihre Feststellung,
es gebe kein `links.ignore-refs`, ist gegen d-check `v0.62.0` gemessen und für den heutigen Pin
**nachgemessen**, nicht übernommen — §1),
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(der Eintrag, der den Beleg trägt),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (den Adaptions-Block schreibt der Architect — dieser
Slice ist geschnitten, nicht ausgeführt vom Planner).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt ein Norm-Artefakt und eine Gate-Config-Frage,
keine Spec-Stelle.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ein Eintrag des Adaptions-Blocks darf einen Beleg tragen, der auf einen abgelösten
Baseline-Stand datiert ist, ohne dass `make docs-check` dauerhaft rot bleibt.**

### Der Befund: ein Link, der bewusst nicht gezogen wurde, und keiner der drei Auswege trägt

[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2 hält fest, dass die Baseline die dritte Rolle *Implementation* nennt, während dieses Repo
den Bezeichner `implementer` führt. **Der Satz ist nur über den abgelösten Stand wahr** — gemessen
an derselben Zeile beider Bäume:

```
git show <Tausch-Commit>^:.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md | grep 'participant I as'
grep 'participant I as' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md
```

→ `participant I as Implementation` gegen `participant I as Implementer`. Der Tag-Tausch zöge
den Link auf eine Quelle, die das Gegenteil der Aussage sagt: aus einem toten Link würde ein
falsches Zitat — genau die Verwandlung, die
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) in ihrer Option C verwirft. Der
Eintrag steht zugleich unter der Append-only-Regel des gepinnten Stands
(`grundlagen-harness-dateien.md` §harness/conventions.md als Konventionsspeicher:
*„Einträge werden nie überschrieben"*), sein **Text** ist also nicht verhandelbar.

**Die drei naheliegenden Auswege sind gemessen, nicht vermutet** — alle drei gegen den heutigen
Pin `v0.65.0`, nicht gegen den Stand, unter dem
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) entschieden hat:

| Ausweg | Messung | Ergebnis |
|---|---|---|
| `links.ignore-refs` je Referenz | `--print-config` des gepinnten Digests | **existiert nicht** — `links` trägt genau eine Option (`resolve-from`); `ignore-refs` und `exempt-paths` stehen unter `codepaths` bzw. `ids`/`matrix`/`diagrams`/`versions` |
| Zeilen-Ventil `<!-- d-check:ignore -->` | Sonde in einer eigenen Plandatei: zwei gebrochene Links, einer mit Marker im echten HTML-Kommentar, ein `make docs-check`, Sonde zurückgenommen | **deckt `links` nicht** — beide Zeilen als `target-missing` gemeldet |
| `scan.ignore` auf die Datei | Config-Kommentar in [`.d-check.yml`](../../../../.d-check.yml): *„prunt den Abstieg"* | wirkt **datei-weit** — nähme den ganzen Konventionsspeicher aus dem Prüfbereich, mit allen Einträgen und deren Links; das ist eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und tauscht einen sichtbaren Befund gegen einen blinden Fleck |

### Zwei Kandidaten, und die Wahl ist eine Architektur-Entscheidung

**(a) Die Adresse entfällt, der Text bleibt.** Der Markdown-Link wird zur reinen Nennung — genau
die Form, die [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 vorsieht:
*„der sichtbare Text bleibt Zeichen für Zeichen stehen, die tag-gepinnte Adresse entfällt … Kein
Satz ändert sich, keine Aussage wird nachgezogen."* Das wäre eine Zeile. **Die Frage, die dabei
offen ist, ist keine Formalie:** Festlegung 4 spricht von **Zeitdokumenten**, und derselbe ADR
erlaubt in Festlegung 2 den lokalen Pfad in `harness/conventions.md` ausdrücklich als
**Navigations-Zeiger** eines *lebenden* Artefakts. Ein append-only-Eintrag ist beides zugleich:
er steht in einer lebenden Datei und ist selbst eingefroren. Welche der zwei Festlegungen ihn
regiert, sagt die ADR nicht.

**(b) Die Verzeichnis-Form.** Der gepinnte Stand nennt sie **Default** — *„Ein Eintrag je Datei …
ist der Auflösungs-Trigger eingetreten, wandert die Datei nach `conventions/done/`"* —, und dort
löst sich die Frage von selbst: der aufgelöste Eintrag liegt in einem `done/`-Verzeichnis und ist
damit **konstruktiv** ein Zeitdokument. Die Vorlage dafür liegt seit dem Tausch vendored
(`.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md`), der Umzug
wäre also regelkonform per `cp`
([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)).

**Was für (b) spricht, ist gemessen; was gegen (b) spricht, auch.** Der Konventionsspeicher misst
**1 836** Zeilen bei **31** Einträgen (`wc -l harness/conventions.md`,
`grep -c '^### MR-' harness/conventions.md`); das Nachbar-Repo d-check fährt die Verzeichnis-Form
mit **30** Einträgen und einem Index von **182** Zeilen
(`wc -l /Development/d-check/harness/conventions.md`,
`ls /Development/d-check/harness/conventions/*.md | wc -l`, lokaler Klon). **Alle vier Zahlen
wandern mit ihrem Bestand und sind keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Dagegen steht die Reichweite: `git grep -oE 'conventions\.md#mr-[a-z0-9-]+' -- '*.md'`
zählt am 2026-08-28 **1 608** Verweise, davon **565** in lebenden Artefakten (dieselbe Suche mit
`':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**'`) und **0** außerhalb
von Markdown (mit `-- ':!*.md'`). **Diese zwei wandern schneller als die vier oben, und das ist
gemessen statt vermutet:** innerhalb eines einzigen Planner-Laufs am 2026-08-28 stand hier
nacheinander 1 585, 1 602, 1 607 und 1 608 — jeder geschnittene Slice, jeder Review-Report und jeder
parallele Lauf einer anderen Rolle bewegt sie, und `git grep` liest den Arbeitsbaum. Wer sie
zitiert, zitiert einen Zeitpunkt; wer sie prüft, fährt das Kommando neu
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 verlangt die Messung über **diesem** Baum, Setzung 2 verbietet, sie als Erwartungswert
zu lesen). [welle-10](../welle-10-re-baseline.md) §6 stellt den Umzug
deshalb ausdrücklich **out-of-scope**.

**Eine Vorfrage, die bisher als ungeprüft galt, ist beantwortet.** Ob der Pin einen expliziten
HTML-Anker als Link-Ziel auflöst, hat
[slice-114](slice-114-jede-aussage-hat-einen-abschnitt.md) §1 als offen benannt. Sonde in einer
eigenen Plandatei, danach zurückgenommen: ein Link auf ein `<a id="…"></a>` mit abweichendem
Überschriften-Text meldet **nichts**, ein erfundener Anker in derselben Datei meldet
`anchor-missing`. Der Anker-Mechanismus, mit dem das Nachbar-Repo seine Index-Zeilen adressierbar
hält, trägt also auch hier — die 1 572 Verweise sind kein Ausschlussgrund für (b), sondern eine
Auflage an seine Ausführung.

### Was dieser Slice nicht ist

Er ist **nicht** der Umzug. Er entscheidet, ob der eine Beleg ohne Umzug tragfähig wird, und wenn
nein, übergibt er den Umzug als eigenen Schnitt mit eigenem Trigger — so, wie
[welle-10](../welle-10-re-baseline.md) §6 ihn vorsieht. Und er ist **nicht** der Ort, an dem ein
Planner-Lauf den Adaptions-Block schreibt: die Ausführung gehört dem Architect
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Die Frage ist entschieden, und die Entscheidung liegt in einem Artefakt ihrer
      schreibenden Rolle.** Regiert Festlegung 2 oder Festlegung 4 von
      [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) einen append-only-Eintrag in
      einer lebenden Datei? Weil jene ADR *Accepted* und damit unveränderlich ist
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4), ist der Ort eine **neue** ADR oder ein
      Adaptions-Eintrag — beides Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). **Ein
      Ergebnis, das nur in diesem Plan steht, erfüllt den Punkt nicht.**
- [ ] **(2) Der Befund ist fort, ohne dass der Prüfbereich geschrumpft ist.** `make docs-check`
      meldet die Zeile nicht mehr, und `scan.ignore` in
      [`.d-check.yml`](../../../../.d-check.yml) trägt **keinen** neuen Eintrag — gegengeprobt mit
      `git diff` auf die Config. Ein Grün, das durch Ausblenden des Konventionsspeichers entstünde,
      verfehlt diesen Punkt ausdrücklich. **Rot färbt genau ein Kommando:** `make docs-check`.
- [ ] **(3) Der Fall ist als Klasse behandelt, nicht als Einzelstück.** Jeder weitere Eintrag des
      Blocks, der einen Beleg auf einen abgelösten Stand datiert, folgt derselben Regel; die Menge
      wird beim Lauf erhoben (`git grep -c 'baseline/v3\.5\.2/' harness/conventions.md`), nicht hier
      behauptet ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). Trifft die Regel heute nur einen Eintrag, steht **das** dabei.
- [ ] `make gates` grün — **ohne** die Ausnahme aus
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md); der Carveout ist damit
      aufgelöst und seine Datei per `git mv` in `carveouts/done/`, die Index-Zeile umgehängt.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-/Reconciliation-Register: das Repo führt keines von beiden; das Item entfällt
      mit diesem Grund und wird in §7 notiert, nicht still übergangen.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die
      [welle-10](../welle-10-re-baseline.md)-Closure, nicht dieser Slice.

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update **durch den Architect** | der Beleg in [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) Punkt 2; Umfang hängt an der Entscheidung aus DoD (1). Der Planner schneidet, er schreibt nicht ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `docs/plan/adr/` | ggf. neu | eine ADR, falls die Entscheidung aus DoD (1) eine ist; [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) selbst bleibt byte-gleich ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) | **auflösen** (`git mv` nach `done/`) | die Ausnahme fällt mit dem Befund |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | kein `scan.ignore`-Eintrag; das ist DoD (2) und keine Nebenbedingung |
| Verzeichnis-Form des Adaptions-Blocks (ein Eintrag je Datei) | **nur bei Ausgang (b)**, und dann als eigener Schnitt | [welle-10](../welle-10-re-baseline.md) §6 stellt den Umzug out-of-scope; er zöge **1 572** Verweise auf einen neuen Pfad und ist keine Fracht dieses Slice |

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit — der Slice ist ohne die
schreibende Rolle des Adaptions-Blocks nicht ausführbar, und das ist keine Formalie, sondern die
Bedingung aus DoD (1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung auf **(b)** fällt.
  Der Umzug ist dann ein eigener Schnitt mit eigenem Trigger
  ([welle-10](../welle-10-re-baseline.md) §6), und dieser Slice zerfällt in *Entscheidung* und
  *Vollzug*. Die Bedingung ist vorab benannt, weil sie der wahrscheinlichere der zwei Ausgänge ist,
  sobald die Klasse aus DoD (3) mehr als einen Eintrag trifft.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Entscheidung aus DoD (1) nicht fällt,
  weil sie eine Frage an eine höher rangierte Quelle aufwirft. Dann bleibt
  [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) bestehen und bekommt eine
  nachgetragene *Letzte Prüfung* — kein stilles Weiterlaufen.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **`make docs-check` meldet die Zeile nicht mehr**, und **`git diff`
auf [`.d-check.yml`](../../../../.d-check.yml) ist leer** — Grün ohne Schrumpfen des Prüfbereichs.
Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang;
[`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) liegt danach in
`carveouts/done/`.

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der billige Ausweg ist derselbe, den DoD (2) verbietet, und er wird unter Zeitdruck
  attraktiv.** Ein `scan.ignore`-Eintrag macht den Gate in einer Zeile grün und nimmt dafür 31
  Einträge samt ihren Links aus dem Prüfbereich. — **Ausgang:** <entfallen: DoD (2) ist erfüllt und
  der Config-Diff leer | eingetreten: die Senkung ist eine eigene Entscheidung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und braucht eine ADR, nicht diesen Slice>
- **Die Klasse kann größer sein als ihr heutiger Vertreter.** Trifft die Regel aus DoD (3) mehrere
  Einträge, ist der punktuelle Ausgang (a) nicht mehr angemessen — Modul 7 verweist bei
  **Häufung** ausdrücklich weg vom Einzelfall. — **Ausgang:** <eingetreten: Rückführung nach §4,
  Umzug als eigener Schnitt | entfallen: die Erhebung aus DoD (3) findet genau einen Eintrag>
- **[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) hat für denselben Gegenstand schon einmal gegen einen überholten Werkzeugstand
  gemessen.** Ihre Feststellung *„es gibt kein `links.ignore-refs`"* stammt von d-check `v0.62.0`;
  der Pin steht seit slice-122 auf `v0.65.0`. Die Nachmessung in §1 hält sie — aber die Klasse
  *„Aussage über ein Werkzeug altert mit dem Pin"* bleibt und trifft jede künftige Runde. —
  **Ausgang:** <weiter offen: Beobachtung, sobald das Repo ein Register führt | eingetreten:
  slice-NNN, der Werkzeug-Aussagen an den Pin koppelt>
- **Der Slice hängt an einer Rolle, nicht an einem Kommando.** Ohne Architect-Lauf ist DoD (1)
  nicht erreichbar, und ein Planner- oder Implementer-Lauf, der ihn trotzdem „erledigt", verstößt
  gegen [`AGENTS.md`](../../../../AGENTS.md) §3.8. — **Ausgang:** <entfallen: die Entscheidung ist
  in einem Architect-Commit sichtbar (`git log --stat`) | eingetreten: Rückführung nach §4>

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist genau eine Sub-Area — `harness/`
(eigener Zuschnitt, eigene Ziel-Form, eigene schreibende Rolle: drei von drei Achsen).
`docs/plan/adr/` kommt nur bei Ausgang (a)/(b) mit **einer** neuen Datei hinzu und ist
keine eigene Berührung im Sinne der Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein**
Beobachtungs-Register; keine Treffer, und der Grund ist die fehlende Datei, nicht ein
leeres Register.

Alle berührten Sub-Areas GF: `harness/` gehört zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
Der Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz oben.

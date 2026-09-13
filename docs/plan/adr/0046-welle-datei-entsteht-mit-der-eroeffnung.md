# ADR-0046: Die flache Welle-Datei entsteht mit der Eröffnung — der frühe Schnitt endet, und weil damit keine Abweichung mehr besteht, bekommt er keinen Eintrag im Adaptions-Block

**Status:** Proposed

**Datum:** 2026-09-13

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) (setzt die regierende Fassung `v6.7.2` und
verbucht die Vorgabe des Auftraggebers, die Ziel-Fassung **vollständig** zu übernehmen — unberührt;
diese Entscheidung wendet sie an, statt sie zu erweitern),
[ADR-0045](0045-authority-wechsel-senkt-eine-richtung.md) (dieselbe Klasse eine Ebene daneben: eine
Gate-Strenge wird entschieden statt vorausgesetzt — unberührt),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Festlegung 1 und 2 binden den
Acceptance-Trigger unten),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (die Welle-Plan-Datei wandert
bei der Closure; darum steht sie hier als Kennung und nicht als Pfad),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (der Wortlaut eines Welle-Plans und der
Roadmap ist Planner-Eigentum; diese Entscheidung ist das Übergabe-Artefakt, nicht der Text),
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (der ADR-Index folgt
dieser Datei),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt Adresse*; jede
Baseline-Aussage unten trägt Tag und Zitat statt eines Pfad-Links),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)
(eine unerklärte Abweichung ist ein Fork — Festlegung 2 unten ist die Erklärung, dass keine
besteht),
[`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
(Form eines Eintrags, der hier gerade **nicht** entsteht),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über eine Arbeitsweise im
Planning-Lifecycle dieses Repos und über die Frage, ob dafür ein Eintrag im Adaptions-Block
entsteht; sie ändert keine Spec-Aussage.

**Kopplung:** [`AGENTS.md`](../../../AGENTS.md) §3.5 ist **nicht** der Anlass — die Aktivierung, die
diese Frage stellt, ist eine Verschärfung, und §3.5 bindet Senkungen. Anlass ist, dass eine
Gate-Aktivierung eine offene Norm-Frage faktisch beantwortet hat, ohne dass die Antwort irgendwo
steht. §3.5 bleibt wörtlich unberührt und bekommt keine zweite Fassung.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

### Die Abweichung, und wo sie stand

Dieses Repo schnitt eine Welle-Plan-Datei, **bevor** ihr Start-Trigger eintrat. Die Datei lag dann
flach unter `docs/plan/planning/`, ohne Zeiger unter *Offene Wellen*, und ihre Kennung stand
verlinkt in der ersten Spalte der Vorschau-Tabelle *Nächste Wellen*.

Diese Arbeitsweise war **nie im Adaptions-Block gebucht**. Gemessen über die aktiven Einträge —
`55` Dateien zum Zeitpunkt dieser Entscheidung, kein Erwartungswert:

```sh
ls harness/conventions/MR-*.md | wc -l                                                   # 55
git grep -l 'waves' -- harness/conventions harness/conventions.md | wc -l                 # 0
git grep -lE 'Welle-Datei|Start-Trigger|Offene Wellen|Nächste Wellen' \
  -- harness/conventions harness/conventions.md | wc -l                                   # 0
```

Null auf beiden Achsen: weder unter dem Namen der Gate-Fähigkeit noch unter dem Vokabular der
Sache. Sie stand stattdessen als Prosa-Block im Abschnitt *Offene Wellen* der Roadmap und ist von
dort mit `1be6be03` entfernt worden, weil eine Aussage einen Ort hat. Damit war sie zwischen jenem
Commit und dieser Entscheidung **an keiner normativen Stelle des Repos** geführt.

### Was die Ziel-Fassung setzt

Die regierende Fassung ist `v6.7.2` ([ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md));
gegen diesen Tag ist gemessen
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
`modul-06-roadmap.md` bindet die Datei an die **Eröffnung** und nicht an den Entschluss, sie zu
schreiben — Schritt 3 der Eröffnung, verbatim: *„Welle-Datei flach anlegen … — ihre Zeile verlässt
*Nächste Wellen*, unter *Offene Wellen* steht der Zeiger auf die Datei."* Der Abschnitt *Offene
Wellen* sagt dazu: *„Die *Liste* folgt den Dateien (ein Zeiger je offener Welle-Datei)"*, und für
die Bijektion: *„ein Zeiger ohne Datei und eine Datei ohne Zeiger sind derselbe Defekt."* Jeder
dieser drei Sätze steht dort einmal — die Kommandos lösen den Tag aus `BASELINE_TAG` auf und
überleben damit den nächsten Sprung:

```sh
B=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/modul-06-roadmap.md"
grep -c 'ihre Zeile verlässt \*Nächste Wellen\*, unter \*Offene Wellen\* steht der' "$B"   # 1
grep -c 'Die \*Liste\* folgt den Dateien (ein Zeiger je offener Welle-Datei)' "$B"         # 1
grep -c 'ein Zeiger ohne Datei und eine Datei ohne Zeiger sind derselbe Defekt' "$B"       # 1
```

Die Vorschau-Tabelle derselben Fassung führt in ihrer Welle-Spalte einen **unverlinkten**
Platzhalter (`roadmap.template.md`, Zeilen `| <welle-id-a> | …`) — eine Welle in der Vorschau hat
kein Ziel, auf das ein Link zeigen könnte. Die Ziel-Form kennt damit keinen Zustand, in dem eine
flache Welle-Datei existiert und die Welle noch in der Vorschau steht. **Der frühe Schnitt war nach
ihr immer die Abweichung.**

### Was die Aktivierung tat

Der wellenlose Slice `slice-offene-wellen-liste-hat-einen-waechter` hat die `waves`-Fähigkeit des
`planning`-Moduls in [`.d-check.yml`](../../../.d-check.yml) aktiviert. Fünf Lagen sind dabei real
gefahren worden — vom umsetzenden und vom prüfenden Lauf unabhängig, gegen eine Kopie außerhalb des
Repos, netzlos, gepinnter Digest, `-disable links` zur Isolation; sie stehen vollständig in
[`harness/sensors/docs-check.md`](../../../harness/sensors/docs-check.md). Die zwei, die diese
Entscheidung tragen:

| Lage | Ergebnis |
|---|---|
| flache Datei + nur in Spalte 1 der Vorschau (kein Zeiger unter *Offene Wellen*) | 2 Befunde (`wave-drift` + `wave-preview-exists`) |
| flache Datei + Zeiger unter *Offene Wellen* **und** verlinkt in Spalte 1 | 1 Befund (`wave-preview-exists`) |

Die erste Zeile **ist** die Abweichung. Sie ist mit der Aktivierung gate-rot — nicht getragen,
sondern verboten. Dass der Bestand heute trotzdem grün ist, hat einen schmalen Grund und keinen
tragenden: In Spalte 1 der Vorschau steht derzeit kein Name, zu dem eine Datei existiert. Die
Zahlen wandern mit dem Baum und sind keine Erwartungswerte:

```sh
ls docs/plan/planning/welle-*.md | wc -l                                                      # 3
sed -n '/^## Offene Wellen/,/^## Nächste Wellen/p' \
  docs/plan/planning/in-progress/roadmap.md | grep -c '^- \[welle-'                           # 3
sed -n '/^## Nächste Wellen/,/^## Meilensteine/p' \
  docs/plan/planning/in-progress/roadmap.md | grep -cE '^\| \[?welle-'                        # 0
```

Drei Dateien, drei Zeiger, keine Vorschau-Zeile mit Welle-Kennung: der Zustand erfüllt die
Ziel-Form bereits. **Der nächste Wellen-Schnitt vor dem Trigger färbt `docs-check` rot.**

### Der Widerspruch, der die Entscheidung erzwingt

`welle-13` — ein offener Welle-Plan und damit ein **lebendes** Planungs-Artefakt — hat die
Anforderung an genau diesen Sensor vorab formuliert: *„Ein Sensor nach `slice-125` muss diese
Abweichung tragen, sonst meldet er einen legitimen Zustand als Drift."* Der gelieferte Sensor trägt
sie nicht. Zwei normative Aussagen dieses Repos stehen damit gegeneinander, und beide können nicht
gelten. Solange keine von beiden zurückgenommen ist, entscheidet der Zufall, welche der nächste
Lauf liest — das ist die Lage, für die eine ADR das Gefäß ist.

### Was den Ausschlag gibt

Die Vorgabe des Auftraggebers, verbucht in
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen: *„Der Adaptions-Durchgang
übernimmt die Ziel-Fassung **vollständig**; eine Abweichung wird nicht gesetzt."* Diese Vorgabe ist
dort auf den **Adaptions-Durchgang** geschnitten, und der hier entschiedene Fall ist keiner seiner
fünf Ausgänge — er stammt nicht aus einem Delta, sondern aus einer Gate-Aktivierung. Sie bindet
diesen Fall darum nicht wörtlich. Sie ist trotzdem das stärkste Argument, das vorliegt: Wenn eine
Abweichung selbst dort nicht gesetzt wird, wo das Delta die Wahl ausdrücklich offenlässt, dann erst
recht nicht dort, wo sie neu erfunden werden müsste und nie gebucht war.

Dazu kommt, dass der frühe Schnitt **nichts trägt**, was die Ziel-Form nicht auch trägt. Was an
einer noch nicht eröffneten Welle festzuhalten ist — Kennung, Trigger als beobachtbare Bedingung,
wichtigste Slices, geschätzter Aufwand —, ist genau der Inhalt einer Zeile in *Nächste Wellen*.
Und die Eröffnung selbst **ist** der Akt, der den Plan schreibt; sie ist nicht die Zeremonie
danach.

## Entscheidung

**Zwei Festlegungen.**

### 1. Die flache Welle-Datei entsteht mit der Eröffnung der Welle und nicht davor — der frühe Schnitt endet

Ausgeschrieben, weil eine Arbeitsweise nur bindet, wenn sie dasteht:

- Solange eine Welle in der Vorschau *Nächste Wellen* steht, trägt sie **keine** Datei unter
  `docs/plan/planning/` und **keinen** Zeiger unter *Offene Wellen*. Ihre Kennung steht dort
  **unverlinkt** — es gibt kein Ziel, auf das ein Link zeigen könnte.
- Die Eröffnung ist **ein** Vorgang mit drei Wirkungen: die Datei entsteht, die Vorschau-Zeile
  entfällt, der Zeiger unter *Offene Wellen* erscheint. Keine der drei steht allein, und keine
  zwei von ihnen liegen sinnvoll in verschiedenen Commits.
- Was vor der Eröffnung über eine Welle festzuhalten ist, hat seinen Ort in ihrer Vorschau-Zeile:
  Welle, Trigger, wichtigste Slices, Aufwand.

Das ist die Ziel-Form der regierenden Fassung `v6.7.2` unverändert. **Dieses Repo übernimmt sie;
eine Abweichung besteht damit nicht mehr.**

### 2. Es entsteht kein Eintrag im Adaptions-Block

Der Adaptions-Block führt **Abweichungen**. Nach Festlegung 1 besteht keine — und gebucht war sie
dort ohnehin nie (Messung in §Kontext, null auf beiden Achsen über `55` aktive Einträge). Ein
Eintrag, der eine beendete Abweichung verzeichnet, wäre eine Zeile in einem Register aktiver
Abweichungen für etwas, das keine ist, und er hätte kein Feld
*Ersetzt-Baseline-Regel* zu füllen.

[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) verlangt, dass eine Abweichung
**erklärt** wird, sonst ist sie ein Fork. Die Erklärung ist diese Datei, und sie lautet: es gibt
keine. Dieselbe Linie zieht [`AGENTS.md`](../../../AGENTS.md) §3.8 für sich selbst — *„Die Regel
füllt damit eine Lücke, statt von der Baseline abzuweichen — deshalb steht zu ihr **kein** Eintrag
im Adaptions-Block"* — und §3.10 wiederholt sie.

### Was diese Entscheidung nicht tut

- **Sie entscheidet nicht, wann ein Start-Trigger eingetreten ist.** Das ist ein Urteil je Welle
  und Planner-Arbeit. Gebunden ist allein die Kopplung *Datei ⟺ Zeiger ⟺ nicht in der Vorschau*.
  Ob die drei heute offenen Wellen ihre Beginn-Bedingung erfüllen, ist hier weder geprüft noch
  behauptet; der Zustand ist formkonform, und das ist eine andere Aussage.
- **Sie verbietet keinen Entwurf.** Verboten ist der Entwurf **als flache Datei unter
  `docs/plan/planning/`** neben einer Vorschau-Zeile — nicht das Vordenken einer Welle.
- **Sie setzt keine allgemeine Regel darüber, dass eine Gate-Aktivierung ihre Norm-Entscheidung
  abwarten muss.** Der Fall ist **einmal** gemessen; die Steering-Loop-Schwelle dieses Repos ist
  3×, und 1× heißt notieren. Die Route dorthin ist das Beobachtungs-Register, und die Closure, die
  es fortschreibt, gehört dem Planner ([`AGENTS.md`](../../../AGENTS.md) §3.10). Eine Regel hier
  wäre eine Norm aus einem Einzelfall.
- **Sie fasst kein fremdes Rollen-Artefakt an.** `welle-13`, die Roadmap und der Sensor-Text
  bekommen Folgepflichten, keinen Schreibzugriff aus diesem Lauf
  ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)).
- **Sie ist keine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5.** Die Aktivierung, die den
  Anlass gab, ist eine Verschärfung; §3.5 bindet Senkungen. Wird `waves` später zurückgenommen
  oder enger gestellt, ist **das** die Senkung und braucht ihre eigene ADR.
- **Sie berührt keinen `ignore-refs`-Eintrag der [`.d-check.yml`](../../../.d-check.yml).** Kein
  Ventil wird geöffnet, keines verbreitert — und diese Datei fügt auch keine Adresse hinzu, die
  eines bräuchte: Jede Nennung eines Artefakts, das der Prozess bewegt, steht hier als Kennung
  ([`AGENTS.md`](../../../AGENTS.md) §3.11), und jeder Verweis in den vendored Baum steht in einem
  Kommando-Block statt als Link oder Code-Span.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Frage offen lassen | kein Schreibaufwand; der Bestand ist heute grün | Der Widerspruch bleibt stehen: `welle-13` §1 verlangt, was das Gate verbietet. Das Grün hängt daran, dass Spalte 1 der Vorschau leer ist (Kommando in §Kontext, **0**) — der nächste Wellen-Schnitt läuft ins Rot, und der Lauf, den es trifft, findet keine Entscheidung vor, an der er sich ausrichten kann. Eine offengelassene Frage, die ein Gate faktisch schon beantwortet, ist keine offene Frage, sondern eine unaufgeschriebene |
| B — Abweichung besteht fort, `waves` wird zurückgenommen | die bisherige Arbeitsweise bliebe möglich; `welle-13` §1 behielte recht | Gibt die Bijektion *Zeiger ↔ flache Datei* auf, also genau die Listen-Hälfte, die die Ziel-Fassung ausdrücklich als bewachungsbedürftig benennt und deren Lücke dieses Repo bis zur Aktivierung als benannte Lücke führen musste. Wäre eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 mit eigener ADR. Und sie erkaufte eine Arbeitsweise, für die kein Bedarf benannt ist: Was der frühe Schnitt festhält, hält die Vorschau-Zeile auch |
| C — Abweichung besteht fort, wird als `MR` gebucht, `waves` eng gestellt | der Adaptions-Block bekäme den Träger, den er heute nicht hat | Die Voraussetzung ist **nicht gemessen**: dass das Modul einen Schlüssel trägt, der die Vorschau-Prüfung allein abschaltet, ist hier weder geprüft noch belegt — der Config-Kommentar in [`.d-check.yml`](../../../.d-check.yml) beschreibt Verhalten, kein Schema. Ohne diese Messung ist die Option ein Vorsatz. Und selbst mit ihr bliebe der Einwand aus B: die Abweichung trägt nichts, und sie neu zu buchen liefe der Vorgabe aus [ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md) entgegen |
| D — Abweichung endet, Buchung als `MR`-Eintrag „beendet" | hielte die Kette im Adaptions-Block auffindbar | Es gibt keine Kette: gemessen war die Abweichung dort **nie** gebucht (§Kontext). Ein Eintrag ohne Vorgänger, der eine Nicht-Abweichung verzeichnet, ist eine Zeile, die bei jedem Delta-Durchgang mitgelesen und mitgeprüft wird, ohne etwas zu setzen — und er füllte das Pflichtfeld *Ersetzt-Baseline-Regel* mit nichts |
| **E — gewählt: Abweichung endet, ADR, kein Eintrag im Adaptions-Block** | Löst den Widerspruch an der Stelle, an der er entstand, und schreibt die Arbeitsweise aus, statt sie dem Gate-Verhalten zu überlassen. Deckt sich mit der Vorgabe des Auftraggebers und mit der Ziel-Form. Lässt den Adaptions-Block frei von einer Zeile, die nichts setzt | Der Preis ist real: Ein bisher möglicher Zug — die Welle-Datei vor dem Trigger schreiben — entfällt, und drei fremde Artefakte müssen nachgezogen werden, bevor das Repo widerspruchsfrei ist. Bis dahin steht in `welle-13` §1 eine Anforderung, die nicht mehr gilt |

## Konsequenzen

- **Positiv:** Der nächste Wellen-Schnitt hat eine Antwort, bevor er das Gate rot färbt. Die
  Listen-Hälfte der Roadmap ist bewacht statt als benannte Lücke geführt, und sie bleibt es, weil
  die Arbeitsweise jetzt zu ihr passt statt gegen sie zu laufen
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Positiv:** Der Adaptions-Block bleibt ein Register **aktiver** Abweichungen. Was nicht abweicht,
  steht nicht darin — und die Aussage darüber ist trotzdem auffindbar, nämlich hier.
- **Negativ:** Eine Arbeitsweise entfällt, die dieses Repo über mehrere Wellen geübt hat. Wer eine
  Welle vordenken will, bekommt dafür eine Tabellenzeile und keine Datei.
- **Negativ:** Zwischen dieser Entscheidung und dem Vollzug der Folgepflichten unten trägt
  `welle-13` §1 eine Anforderung, die nicht mehr gilt. Das ist sichtbar und benannt, aber es ist
  ein Zustand mit zwei Lesarten, und er gehört kurz gehalten.
- **Folgepflicht (Planner), fällig als eigener Vorgang:** `welle-13` §1 nennt als Ansage an die
  eigene Welle, *„ein Sensor nach `slice-125` muss diese Abweichung tragen"*. Die Anforderung ist
  mit Festlegung 1 erledigt und nicht offen — der Sensor **soll** sie nicht tragen. Wie der
  Welle-Plan das abbildet, entscheidet der Planner; diese Entscheidung ist das Übergabe-Artefakt,
  nicht der Text ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)). Die dort
  danebenstehenden Messzahlen sind datierte Messungen und kein Arbeitsauftrag.
- **Folgepflicht (Planner), fällig als eigener Vorgang:** Der Abschnitt *Nächste Wellen* der
  Roadmap trägt den Satz *„Ein verlinkter Name hat eine flache Plan-Datei (geschnitten,
  Start-Trigger nicht eingetreten); ein unverlinkter ist ein Kandidat ohne Datei …"*. Er beschreibt
  genau den Zustand, der nach Festlegung 1 nicht mehr entsteht und den das Gate rot färbt. **Diese
  Folgepflicht ist unabhängig vom Status dieser Datei fällig:** Der Satz ist schon heute eine
  Anleitung in ein rotes Gate.
- **Folgepflicht (Implementer), fällig als eigener Vorgang:**
  [`harness/sensors/docs-check.md`](../../../harness/sensors/docs-check.md) führt die Frage
  ausdrücklich als *„offene Norm-Frage und nicht Gegenstand dieses Sensor-Textes"*. Mit der Annahme
  dieser Datei ist sie es nicht mehr; an die Stelle des Absatzes gehört der Zeiger auf diese
  Entscheidung. Der Sensor-Text selbst — die fünf Lagen, die Grund-Codes, die zwei blinden Flecken
  — bleibt unberührt, er beschreibt das Modul und nicht die Norm.
- **Folgepflicht (Planner), fällig bei der Closure des auslösenden Slice:** Dass eine
  Gate-Aktivierung eine ausdrücklich offengelassene Norm-Frage faktisch beantwortet hat, ist eine
  Beobachtung. Die prüfende Runde hält fest, dass keine vorhandene Kennung passt — das ist ein
  Urteil über eine Klasse und keine Messung; gemessen ist allein der Umfang des Registers, `101`
  Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert).
  Ob die Beobachtung eine neue Kennung bekommt oder unter eine vorhandene fällt, entscheidet die
  Closure; diese Datei entscheidet es nicht und legt nichts an.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0044](0044-ziel-fassung-regiert-den-sprung-v672.md),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und die Ziel-Form von `modul-06-roadmap.md`
in der regierenden Fassung auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund an
der **Substanz** der beiden Festlegungen in `docs/reviews/` liegt.** Ein blockierender Befund an
der **Darstellung** — Adressform, Zahl ohne Kommando, Zitat-Stelle — wird behoben und hindert die
Annahme nicht; die Unterscheidung steht hier, solange die Datei `Proposed` ist
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3). Der Beleg ist
eine Runde der prüfenden Rolle; die Nachmessung des Kontexts, der einen Befund auflöst, ist keiner
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2). Die Accept-Zeile
der §Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).

## Fitness Function

Festlegung 1 ist maschinell geprüft — das ist der seltene Fall, dass der Wächter vor der
Entscheidung dastand. Festlegung 2 ist es nicht, und das gehört benannt
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check, Modul `planning`, Fähigkeit `waves` (`mode: many`) | Eine flache Welle-Datei ohne Zeiger unter *Offene Wellen* — und ein Zeiger ohne Datei — melden `wave-drift` | `make docs-check` |
| d-check, dasselbe Modul | Eine Kennung in Spalte 1 von *Nächste Wellen*, zu der eine flache Datei existiert, meldet `wave-preview-exists` — verlinkt wie unverlinkt | `make docs-check` |
| — | Festlegung 2 (kein Eintrag im Adaptions-Block) hat **keinen** Wächter: Kein Modul der [`.d-check.yml`](../../../.d-check.yml) liest, ob ein Eintrag hätte entstehen müssen, und `make mutate` kennt dafür keine Fehlschlag-Form. Träger ist diese Datei | — |

**Zwei Grenzen des Wächters, aus derselben Messung:** Eine Nennung der Welle-Kennung in Spalte 3
(*Wichtigste Slices*) und ein Vorschau-Zeiger ohne jede Datei bleiben für `waves` unsichtbar; der
zweite fällt allein über das Modul `links` (`target-missing`). Wer die Vorschau-Zeile einer
geschnittenen Welle nur aus Spalte 1 entfernt und die Kennung in Spalte 3 stehen lässt, ist grün
und hat Festlegung 1 trotzdem eingehalten — die Spalte sagt über den Zustand der Welle nichts.

## Re-Evaluierungs-Trigger

- **Wenn `waves` deaktiviert, auf `mode: one` gestellt oder in seinem Prüfumfang gesenkt wird**
  *(beobachtbar am `planning`-Block der [`.d-check.yml`](../../../.d-check.yml))*: Festlegung 1
  verliert ihren Wächter und steht allein als Text. Die Senkung braucht nach
  [`AGENTS.md`](../../../AGENTS.md) §3.5 ohnehin ihre eigene ADR — diese Entscheidung ist dort
  gegenzuhalten, weil Option B dann faktisch eingetreten wäre.
- **Wenn ein Welle-Schnitt an Festlegung 1 scheitert, weil ein Welle-Plan nachweislich vor der
  Eröffnung geschrieben werden muss und die Vorschau-Zeile den Inhalt nicht fasst** *(beobachtbar
  an einem Planner-Vorgang, der genau das als Befund meldet)*: Die Annahme, dass der frühe Schnitt
  nichts trägt, ist widerlegt, und die Wahl zwischen den Optionen ist neu zu halten.
- **Wenn die regierende Fassung die Kopplung Datei ⟺ Zeiger aufgibt** *(beobachtbar daran, dass
  eines der drei `grep -c`-Kommandos aus §Kontext unter einem neuen `BASELINE_TAG` **0** ausgibt)*:
  Festlegung 1 stützt sich dann auf eine Stelle, die es nicht mehr gibt, und der Adaptions-Durchgang
  des Sprungs hält sie neu.
- **Wenn dieselbe Klasse — eine Gate-Aktivierung beantwortet eine ausdrücklich offengelassene
  Norm-Frage — im Beobachtungs-Register 3× erreicht** *(beobachtbar am Zähler ihres
  Verzeichnisses)*: Dann ist die Abgrenzung oben (*keine allgemeine Regel aus einem Einzelfall*)
  aufgebraucht, und die Verkörperung gehört in eine eigene Entscheidung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-13 | **Proposed** | Architect-Lauf. Anlass ist HIGH-2 des Review-Reports zu `slice-offene-wellen-liste-hat-einen-waechter`: Die Aktivierung hat die Frage faktisch entschieden, und das Übergabe-Artefakt an den Architect sagte das Gegenteil. Die Frage, die der Slice-Plan jenes Slice ausdrücklich offenließ, ist damit beantwortet. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0046` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).

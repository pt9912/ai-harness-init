# ADR-0107: Die Mutations-Record-Granularität ist je Fall je Sweep-Lauf — Fall-Files, der Konsum wird ein Treiber-Unterkommando

**Status:** Accepted

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Supersedes:** [`ADR-0103`](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
begrenzt auf die Ablage-**Granularität** — die Form *„je abgeschlossenem Lauf-Urteil“*,
die
ADR-0102 <!-- d-check:ignore (Supersedes-Lineage: die Granularitäts-Formen tragen die ADR-0102-Formen; der Status-Uebergang entsteht hier, ADR-0107 Supersedes-Feld — Marker-Form je ADR-0105 Grenze) -->
in ihrer Entscheidung trägt und die die ADR-0103 in vollem Umfang unverändert nahm.
Neu ist die Granularität **je Fall je Sweep-Lauf** — je Fall ein committetes Fall-File,
je Sweep-Lauf eine angehängte Urteils-Zeile, geleitet von einem Treiber-Unterkommando.
Der übrige Kern der ADR-0103 — der Ablageort `.harness/stamp/mutate/`, die
Hash-Ausnahme, die Scan-Formen und die Retro-Regel — bleibt unverändert regierend.

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Konsum-Form urteilt nicht — sie verwandelt eine Fassung; was sie nicht hält,
ist die Lücke unten, benannt),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(der Supersedens-Vorgänger; Ablageort und Hash-Ausnahme bleiben),
[ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md)
(die Marker-Form der Zeilen-Klasse über einem Supersedes-Übergang, hier angewendet),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Abgrenzung: Fall-Files blocken kein Turn-Ende),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(die Kopf-Zeilen der Fall-Files, Bedarf unten),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
(die Fall-Kennungs-Erkennung trägt die zugelassenen Formen)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Die Mutations-Records liegen außerhalb
jeder Spec-Stelle; die Form-Zeile trägt
[`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md) §CI-Branch.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Die Granularität der Ablage stammt in einem Zug:
ADR-0102 <!-- d-check:ignore (Supersedes-Lineage, Marker-Form je ADR-0105 Grenze) --> legte
*„je abgeschlossenem Lauf-Urteil eine Beleg-Datei“* fest, und die ADR-0103 nahm sie
unverändert mit dem Ablageort-Wechsel. Zwei Läufe haben die Form überfordert, und ein
dritter macht ihren Fortbestand unmöglich:

- **Die Sammel-Läufe.** Der d-check-Sprung-Lauf `slice-d-check-sprung-v0930` trug zwei
  Urteile über denselben geprüften Commit als zwei Dateien — die Paar-Form der ADR-0102
  —, aber die Sammel-Läufe der d-check-Fächer-Züge (`slice-c3-…`, `slice-c7-…`) trugen
  je **87** bzw. **50** Fall-Aussagen in **einer** Datei; das Urteil *je Fall* ist in
  ihnen nur ein Ausschnitt eines Sammel-Texts, den der Lese-Schritt je Frage erst
  herauslesen muss.
- **Die Akkumulation.** Das Lauf-Urteil-File trägt den geprüften Commit im Dateinamen —
  ein Fall, über mehrere geprüfte Commits hinweg gelaufen, verteilt sein Urteil über
  so viele Dateien, wie Läufe es traf. Keine Adresse trägt, was *der Fall* über die
  Zeit tat; der Lese-Schritt des Registers liest die Fall-Geschichte aus keinem Ort.
- **Die Menge.** Der Fall-Bestand misst zur Ablage-Auflösung der ADR-0103
  `ls test/mutations/*.sh | wc -l` → **778** (kein Erwartungswert, die Zahl wandert
  mit dem Bestand). Jede Granularität, die den Konsum von Hand auf Fall-Ebene arbeitet,
  ist dort nicht mehr ausführbar — der Konsum braucht eine Werkzeug-Form.

## Entscheidung

Wir wählen: **Je Fall ein committetes Fall-File unter dem ADR-0103-Ablageort, je
Sweep-Lauf eine angehängte Urteils-Zeile, und der Anhang als Unterkommando des
Mutations-Treibers.** Fünf Festlegungen:

1. **Ablage und Zeile.** Fall-File:
   `.harness/stamp/mutate/<fall-kennung>.txt`. Je Sweep-Lauf, je Fall des
   `mutate-ergebnis.txt`, wird eine Zeile angehängt:
   `<datum> · commit <sha8> · form ok\|befund[ · qualifikator infra\|last] · run <id> attempt <n>`
   — dieselben Werte, die die Lauf-Urteil-Form im Kopf trug, in der Achse Fall statt
   Lauf. Ein Fall-File ohne Zeile entsteht nicht; ein `FEHLT`-Ergebnis ist **kein**
   Urteil und wird nicht angehängt — der Befund steht im Exit und am Kanal, ein
   Anhang würde ein Verdikt behaupten, das der Kanal nicht trägt.
   ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   eine Ebene tiefer.)
2. **Der Fall-File-Name ist die Fall-Kennung.** `<fall-kennung>` löst gegen genau eine
   Datei unter `test/mutations/` auf; unbekannt oder mehrdeutig bricht den Lauf
   fail-closed ([`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Form,
   [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-Werkzeug-Form).
   Die zugelassenen Formen trägt [`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
   — die Fundliste steht im Aufgabensatz des Konsums, die Form-Zeile in
   [`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md) §CI-Branch nennt sie.
3. **Der Konsum ist ein Treiber-Unterkommando.** Form-Vorbild ist der
   dispatch-Schalter des Treibers selbst — `--greift` vor `main`
   ([`harness/tools/mutate.sh`](../../../harness/tools/mutate.sh) Ende) und der
   `--entscheide`-Modus des Fast-Pfades
   ([`harness/tools/gates-fast.sh`](../../../harness/tools/gates-fast.sh) Kopf):
   der Treiber bekommt das Unterkommando `--stamp-records` (verb-Schalter vor `main`,
   `bash harness/tools/mutate.sh --stamp-records <result-file>`). Es liest das
   `mutate-ergebnis.txt`, prüft vollständig (**dann**, nicht je Zeile: fehlendes,
   leeres oder unlesbares Result-File · doppelte Bestimmung — derselbe Fall zweimal im
   Result-File, oder das Paar `(fall, run, attempt)` steht bereits im Fall-File ·
   unbekannte oder mehrdeutige Fall-Kennung) und hängt erst nach der vollständigen
   Prüfung an; jede Grenze bricht mit Meldung, ohne den Fall-File-Bestand anzutasten.
   Es urteilt nicht — der Exit meldet nur die Transformation.
4. **Erstbestand bleibt, Klassen bleiben.** Die vier Lauf-Urteil-Files des heutigen
   Bestands (`slice-d-check-sprung-v0930` Paar, die zwei Kollektiv-Läufe) bleiben als
   datierter Erstbestand in der
   ADR-0102-Retro-Form <!-- d-check:ignore (Supersedes-Lineage, Marker-Form je ADR-0105 Grenze) -->
   (kein Nachrüsten); **neue** Läufe schreiben in der Fall-Form. Die Klassen der
   ADR-0103 bleiben unverändert: Fall-Files sind Stempel, keine Gate-Stempel — sie
   blocken kein Turn-Ende ([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md));
   die Konsum-Reihenfolge lesen → stampen → committen → **dann** räumen bleibt.
   **Die Hash-Ausnahme braucht keinen Nachzug:**
   [`HASH_AUSNMEN`](../../../harness/tools/working-tree-hash.sh)
   trägt den Unterbaum `.harness/stamp/mutate`
   (`grep -n 'HASH_AUSNMEN=' harness/tools/working-tree-hash.sh`), und die Fall-Files
   liegen direkt in ihm — denselben Baum, keine zweite Ausnahme, keine `scan.ignore`-
   oder `codepaths`-Zeile.
5. **Bedarf und Grenze je Fall-File-Kopf.** Bedarf: je Fall-File-Kopf trägt eine
   Form-Zeile mit Run, Attempt und geprüftem Commit — die
   [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Kopf-Form,
   in der Fall-Form statt der Lauf-Form. **Der Wächter, der diese Zeilen-Form hält,
   existiert nicht** — kein Modul des Doku-Gates liest die Record-Bytes und kein Fall
   des Bestands hält sie; so lange gilt die Form als „entsteht mit dem Werkzeug“, nicht
   als bestehend
   ([`AGENTS.md`](../../../AGENTS.md) §3.6). Der Fall, der die Fall-Form hält
   (Anhang-Form inklusive Kopf-Zeile und der drei fail-closed-Grenzen aus
   Festlegung 3), entsteht im Treiber-Zug als Mutations-Fall über dem realen Werkzeug
   (Anlage-Form je
   [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
   / [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
   **Welchen Slice der Treiber-Zug trägt, legt der Planner fest** — der Plan der
   Kennung `slice-gates-pruefgegenstand-stempel-v1` schneidet den Mutations-Treiber
   ausdrücklich aus (§1, Abgrenzung 1, *„anderer Vorgang“*); dieses ADR legt die Form
   und die Grenzen fest, nicht den Träger.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — die Lauf-Urteil-Granularität der ADR-0102 unverändert lassen | ein Konsum-Schritt weniger, die vier Nachzüge entfallen | das Urteil *je Fall* ist nur ein Ausschnitt eines Sammel-Texts; über mehrere geprüfte Commits verteilt ein Fall seine Urteile über mehrere Files, keine Adresse trägt die Fall-Geschichte; der Konsum wird bei 778 Fällen von Hand unmöglich |
| B — Werkzeug, aber Lauf-Urteil-Granularität | der Fall-Bestand ist transformiert, der Index bleibt | transformiert die falsche Achse: das Lauf-File bleibt das Urteil *aller* Fälle eines Laufs; der Lese-Schritt liest weiterhin Sammel-Texte, die Fall-Geschichte bleibt adresslos |
| **C — Fall-Granularität + Treiber-Unterkommando (gewählt)** | je Fall eine Adresse; das Urteil akkumuliert über Läufe; der Anhang ist eine Werkzeug-Transformation, die der Konsum nicht von Hand reproduziert | die Anlage- und Kopf-Form ist bis zum Treiber-Zug ungewächtert (Festlegung 5, ehrlich benannt); der Erstbestand trägt dauerhaft die andere Form — zwei Formen dokumentiert, beide lesbar |

## Konsequenzen

- Positiv: das Urteil eines Falls akkumuliert an einer Adresse und bleibt über die
  geprüften Commits hinweg lesbar; der Konsum ist von der Menge der Fälle entkoppelt;
  die Paar-Form (grün neben Befund, derselbe geprüfte Commit) wird in derselben Datei
  lesbar.
- Negativ: die Anhang- und Kopf-Form ist bis zum Treiber-Zug ungewächtert
  (Festlegung 5); der Erstbestand trägt die Lauf-Form, die Fall-Form die neuen Läufe —
  zwei Formen, beide dokumentiert.
- Folgepflicht (Implementer-Zug, Treiber): das Unterkommando samt Fall-Zug; die
  Granularitäts-Zeile in
  [`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md) §CI-Branch nennt
  die Fall-Form, den Ort, das Unterkommando und seine Grenzen; Index-Zelle und
  Geschichte-Zeile der ADR-0103 tragen die Teil-Ablösung (hier im Architect-Commit,
  je ADR-0104-Muster).
- Abgrenzung: kein zweiter Träger des Handoff-Gate-Zustands
  ([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md));
  die Fall-Files urteilen nicht über den Arbeitsbaum und sind Stempel-Klasse weiter.

## Fitness Function

Der Konsum-Urteil-Zug hat **keinen Wächter im Bestand** — die oben genannte Grenze
(Festlegung 5) trägt: die Fall-Files werden von keinem Modul gelesen, der Fall-Bestand
hält die Form nicht. Die Wächter-Zeile entsteht im Treiber-Zug über dem realen
Werkzeug: bats über der reinen Transformation (Happy: je Fall eine Zeile; Negative je
fail-closed-Grenze aus Festlegung 3) plus ein Mutations-Fall, dessen `sed`-Anker gegen
den Quell-Bestand gemessen ist ([`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-Form).
**Was hier nicht behauptet wird:** der Rot-Beleg steht **nicht** in diesem ADR — die
Wächter entstehen erst im Treiber-Zug, und der Fall-Bestand, der die Form hält,
existiert davor nicht ([`AGENTS.md`](../../../AGENTS.md) §3.6).

## Re-Evaluierungs-Trigger

Permanent in der Form „gilt unbefristet“ — bis eine dieser Bedingungen eintritt:

1. **Der Treiber trägt die Fall-Form selbst** — ein `mutate`-Toolstand, der nach dem
   Sweep direkt auf `main` stempelt (Form der
   [`ADR-0103`](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
   Trigger 2, wie dort der Treiber-Zug aus der ADR-0102-Fassung); das Unterkommando
   verdoppelt seinen Konsum-Schritt. Folge-ADR mit `supersedes`.
2. **Ein Gate urteilt unter den Fall-Files** — dann deckt die Hash-Ausnahme der
   ADR-0103 einen Prüfgegenstand aus, sie ist zurückzunehmen; Folge-ADR mit
   `supersedes`.
3. **Die Fallmenge schrumpft auf Handgröße, oder eine Baseline- bzw.
   Upstream-Regel übernimmt den Lauf-Beleg** — dann ist die Werkzeug-Form gegen den
   neuen Bestand neu zu begründen; der Weg ist derselbe wie in der ADR-0103 (Trigger 3).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | **Accepted**; Architektur-Zug der Stempel-Setzung (Fall-Stempel-Granularität), Annahme durch den Auftraggeber am 2026-11-26 | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

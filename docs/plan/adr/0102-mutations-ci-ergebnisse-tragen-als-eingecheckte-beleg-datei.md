# ADR-0102: Mutations-CI-Ergebnisse tragen als eingecheckte Beleg-Datei in `docs/reviews/mutate/`

**Status:** Superseded by [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Farbungs-Hälfte der Mutations-Zusage — ein Urteil, das mit seinem Kanal verfällt, ist kein Beleg),
[`MR-091`](../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
(der CI-Branch und seine Ergebnis-Fassung),
[`MR-072`](../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form)
(die Namensform: volle Slice-Kennung im Dateinamen),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(der Isolations-Schlüssel — bleibt, was er ist; diese ADR legt die Ergebnis-**Fassung** ab, nicht das Verdikt je Fall),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(die Zahl-Beleg-Form der Kopf-Zeilen),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(die Abgrenzung: kein zweiter Träger des Handoff-Gate-Zustands)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Der Mutations-CI-Weg trägt seine
Aussagen in `harness/sensors/mutate.md` und den Workflows; die Spezifikation
nennt ihn nicht.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

Die Ergebnis-Fassung eines Mutations-CI-Laufs
([`MR-091`](../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt))
lebt nur an zwei Kanälen, und beide verfallen:

- **Die Branch-Wurzel.** `mutate-ergebnis.txt` liegt an der Branch-Spitze
  eines `mutate/<kennung>-<sha8>`-Refs, den der Verifier nach dem Lesen
  löscht (`harness/sensors/mutate.md` §CI-Branch). Sie ist auf `main` nie
  sichtbar, und sie wird überschrieben: der Verlauf von
  `slice-d-check-sprung-v0930` am 2026-11-25 trug einen non-fast-forward-Push
  im `ergebnis`-Job (Versuch 3 des Runs 45625795106, Job 139305369935 —
  `! [rejected] … (non-fast-forward)`, im Job-Log gelesen) und einen
  überschreibenden Folgelauf — die Grün-Fassung (`Urteil: gruen`, 82/82)
  des Runs 45625795106, Attempt 3 existiert **nicht** an der Branch; an
  ihrer Stelle stand nach dem BEFUND-Lauf von Run 45647457778 nur dessen
  Fassung.
- **Das Job-Log.** Das `ergebnis`-Job-Log trägt den Klartext der Fassung,
  aber GitHub löscht Job-Logs nach rund 90 Tagen — für zwei der drei
  heutigen Urteile war das der einzige Träger.

Ohne eingecheckten Beleg verfällt deshalb das Urteil eines laufenden
Pin-Sprungs und jeder künftige Konsum-Schritt hätte das Urteil der Klasse
„beleglos" zu stellen.

## Entscheidung

Wir wählen: **Je abgeschlossenem Lauf-Urteil eines Mutations-CI-Laufs
landet seine Ergebnis-Fassung als eingecheckte Beleg-Datei, geschrieben
vom Konsum-Schritt** (der Rolle, die die Probe liest — Implementer am
Claim oder Verifier am Verifikations-Übergang), **bevor** die Branch geräumt
wird. Vier Festlegungen:

1. **Ablageort und Namensform.** `docs/reviews/mutate/<slice-kennung>-<sha8-des-geprüften-commits>-<form>.txt`
   — die volle Slice-Kennung im Dateinamen, die Namensform der
   [`MR-072`](../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form)-Ablage-Regel;
   `<form>` ist das Urteil, `gruen` oder `befund`, mit optionalen
   Qualifikator (`infra`, `last`), wenn der Befund einer Infra-/Last-Klasse
   entstammt, die das Beobachtungs-Register führt. Zwei Urteile über
   denselben geprüften Commit co-existieren als zwei Dateien (Paar-Fall:
   Grün-Fassung eines Versuchs + BEFUND-Fassung des Folgelaufs).
2. **Kopf-Pflichten je File** (die Zahl-Beleg-Form von
   [`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
   im Klartext): Run-Id und Attempt, geprüfter Commit, der Ausgabe-Kanal
   (Branch-File oder Job-Log) **mit dem Lesekommando, das genau diese Bytes
   ausgibt** (`git show FETCH_HEAD:mutate-ergebnis.txt` bzw.
   `gh api …/actions/jobs/<job-id>/logs`), den Entnahme-**Stand** und —
   wo der Kanal verfällt oder überschrieben wurde — den Grund, warum genau
   dieser Kanal der Träger ist. Darunter byte-gleich die Ergebnis-Fassung
   (`mutate-ergebnis.txt`). Eine Messwert-Zahl im Kopf trägt ihren
   Erwartungswert-Vermerk ([`MR-053`](../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)-Form).
3. **Träger = der Konsum-Schritt; die Reihenfolge lesen → committen → räumen.**
   Der `ergebnis`-Job pusht unverändert nur auf seinen CI-Branch
   (`contents: write` auf `refs/heads/mutate/**`); auf `main` schreibt die
   CI **nicht**. Die Rolle, die die Branch liest, committet die Beleg-Datei
   auf `main` **vor** der Räumung — räumt sie danach, hat der Beleg sie
   nicht mehr nötig. Der Branch-Bestand wird nicht geändert.
4. **Retro-Belege der heutigen Läufe** im selben Zug als Erstbestand:
   die Grün-Fassung des Runs 45625795106 (aus dem Job-Log — die einzige
   noch lebende Stelle vor der Verfallfrist), der BEFUND-Laufs 45647457778
   und der Teil-Urteile der zwei Kollektiv-Läufe 45769037551/45769040893
   (aus den Branch-Fassungen). Kein Nachrüsten weiterer Läufe —
   Cut-off, kein Bestands-Auftrag.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Branch-File und Job-Log als einzige Träger) | Kein Neuartefakt | Beide Kanäle verfallen oder werden überschrieben — gemessen am Vormittag des 2026-11-25: die Grün-Fassung von Run 45625795106 existiert nach dem BEFUND-Push von Run 45647457778 nur noch im Job-Log, und dieses verfällt in ~90 Tagen; das Urteil des Pin-Sprungs `v0.93.0` würde beleglos |
| B — der `ergebnis`-Job pusht die Fassung auf `main` | Automatisch, kein Konsum-Schritt nötig | `contents: write` auf `main` wäre eine eigene Policy-Entscheidung; `ci.yml` läuft auf `mutate/**` nicht, und wer auf `mutate/**` pushen darf, bestimmt den Workflow und damit einen Job mit Schreibrecht auf `main` ([`MR-091`](../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt) §Eingaben); der Lese-Zug des Konsums existiert ohnehin — ein zweiter Schreiber desselben Zustands |
| **C — der Konsum-Schritt committet die Fassung (gewählt)** | Kein neues CI-Schreibrecht; der Beleg liegt getrackt und datiert; die Reihenfolge lesen → committen → räumen braucht nur die Verschiebung der Räumung | Der Konsum-Schritt kann ausgelassen werden — kein Wächter erzwingt ihn (benannt in `harness/sensors/mutate.md` §CI-Branch, §Grenze) |

## Konsequenzen

- Positiv: Ein Urteil überlebt Branch-Räumung und Log-Verfall; die
  Paar-Form (Grün-Versuch neben BEFUND-Folgelauf, derselbe geprüfte Commit)
  trägt die Load-Klasse sichtbar statt still.
- Negativ: Die Ablage ist ungewächtert — kein Modul des Doku-Gates hält
  die Form (`grep -rn 'docs/reviews/mutate' .d-check.yml d-check.mk` → 0);
  der Träger bleibt der Vorgang, der sie schreibt.
- Folgepflicht: die Form-Zeile in `harness/sensors/mutate.md` §CI-Branch
  (Ablageort + Konsum-Reihenfolge + Grenze); das Beobachtungs-Register
  zählt die Befund-Formen seiner Klasse über die Kopf-Zeiger der
  Beleg-Dateien.
- Abgrenzung: kein zweiter Träger des Handoff-Gate-Zustands
  (ADR-0083) und kein zweiter Träger des Fall-Urteils — der
  Isolations-Schlüssel (ADR-0035) trägt die Klassifikation grün/rot je
  Fall weiter, die Beleg-Datei nur die Ergebnis-**Fassung** des Laufs.

## Re-Evaluierungs-Trigger

Permanent in der Form *„gilt unbefristet"* — bis eine dieser Bedingungen
eintritt:

1. **Der Treiber trägt die Form selbst** — ein `mutate`-Toolstand, der die
   Ablage auf `main` schreibt (Workflow-Seite oder lokaler Konsum im
   Treiber), doppelte den Konsum-Schritt; Folge-ADR mit `supersedes`.
2. **Eine Baseline- bzw. Upstream-Regel übernimmt den Lauf-Beleg** — dann
   ist die hier liegende Setzung gegen den neuen Wortlaut neu zu begründen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | Accepted | Slice `slice-mutations-beleg-eingecheckt` §2, Architektur-Frage aus §6 Risiko 3; Ablageort `docs/reviews/mutate/` |
| 2026-11-26 | Berichtigung — die Verweis-Zeile der Accepted-Zeile trägt die Kennung statt eines Pfad-Links in den Planning-Lifecycle; der Plan wandert bei der Closure nach `done/`, und der Verweise-Zug liest eingehende Verweise aus `docs/plan/adr/**` nicht nach. Der Kern bleibt unverändert ([`AGENTS.md`](../../../AGENTS.md) §3.4) | Review [`2026-11-25-slice-mutations-beleg-eingecheckt.md`](../../reviews/2026-11-25-slice-mutations-beleg-eingecheckt.md) F-1 |
| 2026-11-26 | Superseded — [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) nimmt den Gegenstand in vollem Umfang weiter (Ergebnis-Form, Konsum-Reihenfolge, Granularität, Namensform); einziges Delta ist der Ablageort: aus dem Verzeichnis der Review-Zeitdokumente wurde die Stempel-Klasse .harness/stamp/mutate/. Der Kern bleibt unverändert ([`AGENTS.md`](../../../AGENTS.md) §3.4) | [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) |

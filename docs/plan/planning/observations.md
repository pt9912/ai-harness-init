# Beobachtungs-Register

Regeln dieses Registers: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — wer schreibt, wer liest, wann gestrichen wird,
welche Form ein Beleg hat, und dass eine leere Tabelle `— keine —` trägt statt
zu verschwinden.

**Wer schreibt:** die **Slice-Closure** — neue Kennung vergeben **oder** Zähler erhöhen und Beleg
ergänzen. Der Zähler läuft damit mit jedem geschlossenen Slice und nicht mit der Welle. Das ist
hier nicht bloß bequem: dieses Repo führt Wellen-Betrieb **und** wellenlose Slices
([`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)),
und ein wellen-getragener Zähler hätte für die zweite Hälfte keinen Träger.

**Wer liest:** die **Welle-Closure** liest, was **3×** erreicht hat; die **Slice-Planung** liest in
§8 ihres Plans, was darunter steht. Wer nur den ersten Schritt kennt, sieht alles unter 3× nie
wieder an.

**Belege sind formgebunden:** Slice-Kennung `slice-<NNN>`, kein Freitext, so viele wie der Zähler
sagt — und die Slice-Datei liegt in `docs/plan/planning/done/`.

**Die Sub-Area-Spalte** trägt einen Namen, den die Modus-Deklaration in
[`harness/conventions.md`](../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt.
Steht dort ein anderer, ist entweder die Zuordnung falsch oder die Deklaration unvollständig.

| Kennung | Beobachtung | Sub-Area | Zähler | Belege | Stand |
|---|---|---|---|---|---|
| BEO-001 | Der dritte Ausgang für ein offenes Risiko — *weiter offen → Beobachtungs-Register* — hat keinen Ort, also wird jede Beobachtung ein Folge-Slice | `*` (gesamtes Repo) | 6× | slice-080, slice-081, slice-130, slice-132, slice-133, slice-138 | **verkörpert** in dieser Datei und in den drei Anweisungssätzen unter [`.claude/commands/`](../../../.claude/commands/) (`seit slice-137`) — die Schwelle war beim Erstauftreten im Register bereits überschritten, der Lese-Schritt der nächsten Welle-Closure findet die Zeile fertig vor |
| BEO-002 | Eine Registerzeile hat keine Spalte für einen Träger: ein geschnittener Slice mit gemessener DoD, Datei-Plan und benannten Risiken passt nicht in sie | `*` (gesamtes Repo) | 1× | slice-137 | offen — geprüft über den vollen Bestand, nicht über eine Stichprobe: **jeder** Slice in `docs/plan/planning/open/` trägt einen DoD-Liefer-Punkt, eine Plan-Tabelle in §3 und mindestens ein benanntes Risiko in §6, und keiner ist überführbar. Die Zahl dazu steht hier nicht, weil sie mit jedem Schnitt wandert — sie ist ein Kommando (`ls docs/plan/planning/open/slice-*.md \| wc -l`), und der Stand zum Prüfzeitpunkt liegt in der Closure-Notiz von slice-137. Was fehlt, ist ein Ausgang für *real, aber nicht jetzt* zwischen `open/` und diesem Register |
| BEO-003 | Der Abgleich nach einem Lifecycle-`git mv` läuft von Hand, und zwei Formen brechen dabei regelmäßig — der blanke Geschwister-Name und die **ausgehenden** Adressen der bewegten Datei, die eine Zählung der eingehenden gar nicht findet | `*` (gesamtes Repo) | 1× | slice-137 | offen — der Umfang ist die untere Schranke und nicht der Zähler: `git log --format=%h --grep='Link-Abgleich nach dem Move' \| wc -l` zählt die Commits, die die Klasse tragen, und wächst mit jedem Move. Träger ist [slice-144](in-progress/slice-144-lifecycle-move-zieht-seine-verweise-nach.md), der die Frage *übernehmen oder eigenständig bauen* entscheidet |
| BEO-004 | Die Sub-Area-Spalte dieses Registers unterscheidet nichts: die Modus-Deklaration führt `*` (gesamtes Repo), und `*` schließt jede Berührung ein | `*` (gesamtes Repo) | 1× | slice-137 | offen — die Auflösung ist eine Zeile in [`harness/conventions.md`](../../../harness/conventions.md#modus-deklaration-pro-sub-area) und damit Architect-Arbeit ([`AGENTS.md`](../../../AGENTS.md) §3.8). Ein Planner-Slice kann sie benennen, nicht schreiben; bis dahin trägt jede Zeile hier denselben Namen |
| BEO-005 | Der Zähler startet bei null: eine Klasse, die in den geschlossenen Slices schon dreimal aufgetreten ist, erreicht die Schwelle nicht von selbst, sondern erst beim nächsten Auftreten | `*` (gesamtes Repo) | 1× | slice-137 | offen — der Weg steht und ist einmal gegangen (`BEO-001` führt sechs Belege aus `docs/plan/planning/done/`), aber er beginnt jedes Mal mit einem neuen Auftreten. Eine Vollinventur über den Bestand in `docs/plan/planning/done/` ist ausgeschlossen: sie verlangte je Datei das Urteil *ist das dieselbe Beobachtung?* |
| BEO-006 | Die maschinell entscheidbare Hälfte der Register-Paarung — jede in `done/` zitierte `BEO-<NNN>` hat eine Zeile, und jede Zeile trägt mindestens einen Beleg — hat in keinem gepinnten Doku-Gate-Stand ein Modul | `*` (gesamtes Repo) | 1× | slice-137 | offen — netzlos über beide Digests gemessen, den aktiven aus [`.d-check.yml`](../../../.d-check.yml) und das Ziel von [slice-135](open/slice-135-d-check-pin-v0661.md): `docker run --rm --network none ghcr.io/pt9912/d-check@<digest> --print-config \| grep -ci 'observation'` → **0** und **0**. Das ist eine fehlende Fähigkeit eines Fremd-Werkzeugs, keine Grenze dieses Repos; der Eigenbau wiegt schwerer als der Nutzen. Der beobachtbare Trigger ist erreicht (die erste Kennung ist vergeben), der Nutzen über den heutigen Umfang dieses Registers ist es nicht |
| BEO-007 | Wer die Anweisungssätze unter [`.claude/commands/`](../../../.claude/commands/) schreiben darf, sagt keine Quelle | `*` (gesamtes Repo) | 1× | slice-137 | offen — [`ADR-0015`](../adr/0015-rollen-eigentum-an-norm-artefakten.md) besetzt zwei Norm-Artefakte und lässt die Frage für alle übrigen ausdrücklich offen; [`ADR-0024`](../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) zeigt das Muster, in dem dieses Repo eine solche Lücke schließt. Umgangen, nicht gelöst: geschrieben wurde nur in Abschnitten, die die Planner-Rolle bereits im Titel führen |

## Gestrichene Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — wer eine Zeile still löscht, macht sie
ununterscheidbar von einer, die es nie gab.

| Kennung | Beobachtung | Gestrichen am | Warum sie nicht mehr auftreten kann |
|---|---|---|---|
| — keine — | | | |

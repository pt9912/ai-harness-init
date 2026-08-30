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
| BEO-002 | Eine Registerzeile hat keine Spalte für einen Träger: ein geschnittener Slice mit gemessener DoD, Datei-Plan und benannten Risiken passt nicht in sie | `*` (gesamtes Repo) | 1× | slice-137 | offen — geprüft über den vollen Bestand, nicht über eine Stichprobe: `ls docs/plan/planning/open/slice-*.md \| wc -l` → **48**, und ebenso viele tragen je einen DoD-Liefer-Punkt, eine Plan-Tabelle und mindestens ein benanntes Risiko. Keiner ist überführbar. Was fehlt, ist ein Ausgang für *real, aber nicht jetzt* zwischen `open/` und diesem Register |
| BEO-003 | Der Abgleich nach einem Lifecycle-`git mv` läuft von Hand, und zwei Formen brechen dabei regelmäßig — der blanke Geschwister-Name und die **ausgehenden** Adressen der bewegten Datei, die eine Zählung der eingehenden gar nicht findet | `*` (gesamtes Repo) | 1× | slice-137 | offen — der Umfang ist die untere Schranke, nicht der Zähler: `git log --format=%h --grep='Link-Abgleich nach dem Move' \| wc -l` → **63** Commits tragen die Klasse. Träger ist der Folge-Slice, der mit dieser Closure geschnitten wird |
| BEO-004 | Die Sub-Area-Spalte dieses Registers unterscheidet nichts: die Modus-Deklaration führt `*` (gesamtes Repo), und `*` schließt jede Berührung ein | `*` (gesamtes Repo) | 1× | slice-137 | offen — die Auflösung ist eine Zeile in [`harness/conventions.md`](../../../harness/conventions.md#modus-deklaration-pro-sub-area) und damit Architect-Arbeit ([`AGENTS.md`](../../../AGENTS.md) §3.8). Ein Planner-Slice kann sie benennen, nicht schreiben; bis dahin trägt jede Zeile hier denselben Namen |

## Gestrichene Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — wer eine Zeile still löscht, macht sie
ununterscheidbar von einer, die es nie gab.

| Kennung | Beobachtung | Gestrichen am | Warum sie nicht mehr auftreten kann |
|---|---|---|---|
| — keine — | | | |

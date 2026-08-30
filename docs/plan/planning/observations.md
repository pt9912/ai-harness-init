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
| — keine — | | | | | |

## Gestrichene Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — wer eine Zeile still löscht, macht sie
ununterscheidbar von einer, die es nie gab.

| Kennung | Beobachtung | Gestrichen am | Warum sie nicht mehr auftreten kann |
|---|---|---|---|
| — keine — | | | |

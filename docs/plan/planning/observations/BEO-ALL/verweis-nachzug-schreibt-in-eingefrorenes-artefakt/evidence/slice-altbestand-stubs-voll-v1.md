**Vorgang:** slice-altbestand-stubs-voll-v1
**Fund:** Der Altbestand-Lauf (wellenlos, [`ADR-0041`](../../../../../../../docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md))
hat den Verleger der Verleger-Form
([`ADR-0112`](../../../../../../../docs/plan/adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
Festlegung 1–3) vollzogen und damit die Umzugs-Stub-Klasse zum ersten Mal am
realen Baum gefahren. Drei Beobachtungen aus diesem Lauf:

1. **Die Verleger-Form steht am realen Baum:** neun UMZUGEZOGEN-Stubs an der
   flachen alten Adresse, je einer je bewegter Referenz; die zwei
   `##`-Überschriften der erlaubten Fassung
   (`FormOKUmzug` — `## 2. Definition of Done` leer und
   `## 7. Closure-Notiz` mit der `**Gegenstand:**`-Zeile) trägt je Stub die
   Werkzeug-Form. Die Form-Divergenz der Erstablage (Stubs ohne die
   Gegenstand-Zeile) fing der altbestand-Verifier; der Nachzug
   (`5569ea2c`) trug die Zeile nach.

```sh
grep -l 'UMZUGEZOGEN' docs/plan/planning/done/slice-*.md | wc -l
# -> 9
```

2. **Die Vorab-Messung über beide Adress-Formen** (Code-Span und
   Markdown-Link) auf die bewegten Pfade findet sie nur in den Frozen-Bäumen
   (`done/`, Baseline-Baum ausgenommen-Liste) — kein beweglicher Treffer
   bricht beim Move. Diese Messung ist die von
   [`AGENTS.md`](../../../../../../../AGENTS.md) §3.11 Absatz 2 verlangte
   Vorab-Messung je Umzugs-Lauf und ist hier zum ersten Mal vollständig
   über die Frage gefahren, die der Eintrag trägt.

3. **Die Herkunfts-Anker lösen zweistufig:** die fünf
   `seit slice-`-Anker in [`AGENTS.md`](../../../../../../../AGENTS.md) §3
   (slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst,
   slice-mutate-laeuft-ueber-einen-ci-branch,
   slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten,
   slice-release-schnitt-v025-bereitet-vor,
   slice-macos-als-host-plattform-wird-entschieden-und-vollzogen) stehen auf
   Slices, die der Altbestand-Lauf nach `done/altbestand/` bewegt hat; die
   Stubs liegen je an

   `done/altbestand/slice-<Kennung>.md` (mit `Archiviert mit:`- und
   `Hervorgegangen:`-Zeiger) und der Volltext mit §7 liegt im
   `done/altbestand/archive.zip`. Die zweistufige Auflösung ist die
   deklarierte Fassung des Anker-Regelwerks („Nach dem Archivieren ist es
   ein Hop mehr — erst der Stub, dann sein Archiv-Zeiger", Baseline-Regelwerk
   `grundlagen-traceability.md` §Herkunfts-Anker) — kein eigener
   Folge-Slice; die Anker lösen weiter real auf, nur einen Hop tiefer.

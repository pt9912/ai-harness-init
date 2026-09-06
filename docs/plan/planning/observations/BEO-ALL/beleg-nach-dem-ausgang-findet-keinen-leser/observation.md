# Beleg nach dem Ausgang findet keinen Leser

**Sub-Area:** `*` (gesamtes Repo)

Ein Eintrag, der seinen Ausgang bekommen hat, sammelt weiter Belege — und für diese Belege ist
keine Handlung definiert. Das Register hat zwei Leser (Baseline-Regelwerk
[`modul-06-roadmap.md`](../../../../../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md)
§Das Beobachtungs-Register): Der **Lese-Schritt** der Closure fragt, welcher Eintrag **3×**
erreicht hat, und weist ihm einen der drei Ausgänge zu; der **Sichtungs-Schritt** der Slice-Planung
liest, was **darunter** steht. Ein Eintrag oberhalb der Schwelle, der bereits *verkörpert* oder
*geplant* trägt, fällt durch beide: Der Lese-Schritt findet einen Ausgang vor und hat nichts
zuzuweisen, der Sichtungs-Schritt sieht ihn nicht an. Sein Zähler wächst, und die Wiederholung
gegen eine **bereits stehende** Regel wird zu keinem Zeitpunkt zur Frage.

Die drei Ausgänge sind eine geschlossene Menge, und keiner von ihnen bedeutet *die Regel steht und
wird trotzdem gebrochen*. Für zwei der betroffenen Klassen ist das kein Zufall: ihre Zielorte —
[`AGENTS.md`](../../../../../../AGENTS.md) §3.10 und §3.11 — stellen beide für sich selbst fest
*„Ein Wächter existiert nicht"*, und ein Ausgang, dessen Träger ein Rollenwechsel ist, hat im
Zähler keine Rückmeldung.

## Benannt, nicht gezählt

Zwei Nachbarklassen sind enger und decken den Fall nicht.
[`ausgang-nennt-traeger-der-nicht-traegt`](../ausgang-nennt-traeger-der-nicht-traegt/observation.md)
handelt von einem Ausgang, dessen genannter Träger den Befund nicht adressiert — dort ist der
Ausgang materiell leer, hier ist er richtig und trägt trotzdem keine Antwort auf das
Wiederauftreten.
[`schwellen-uebertritt-ohne-zustaendige-rolle`](../schwellen-uebertritt-ohne-zustaendige-rolle/observation.md)
handelt vom Übertritt selbst, an dem die Rolle fehlt — hier ist der Übertritt längst vollzogen.

Gemessen am Bestand: von den Einträgen dieser Ablage tragen zehn einen Ausgang statt `offen`

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do head -1 "$d/state.md"; done \
  | grep -vc 'offen'                                                                  # 10
```

und **vier** von ihnen bekommen allein durch den Vorgang, in dem diese Beobachtung entsteht, einen
weiteren Beleg: `fremdes-rollen-artefakt-im-implementations-kontext` (*verkörpert*),
`vorgeschriebener-ortswechsel-macht-adresse-tot` (*verkörpert*),
`zusage-neben-geaenderter-ableitung-bleibt-stehen` (*geplant*) und
`anweisungssatz-eigentum-ohne-quelle` (*geplant*). **Keine Erwartungswerte** — die Zahl wandert
mit dem Register.

# Tag-tragende Adresse überlebt den Baseline-Tausch nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein **lebendes**, repo-eigenes Artefakt adressiert eine Datei im vendored Baum über deren Tag, und
der vom Prozess vorgeschriebene Baum-Tausch einer Re-Baseline macht die Adresse tot. Die
Fehlerrichtung ist *der Nachzug fällt schon auf*: Er fiel dreimal auf, wurde dreimal von Hand
gefahren und beim vierten Sprung vergessen — es gibt keinen Träger, der ihn erzwingt.

**Zwei Klassen von Tag-Nennung brauchen entgegengesetzte Behandlung, und das macht den
naheliegenden Griff falsch.** Eine **Adresse** muss über jedem Stand auflösen und darf den Tag
darum nicht nennen. Eine **Messung** datiert ihre Aussage und *muss* ihn nennen
([`MR-033`](../../../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist));
sie braucht eine erneute Messung, keinen Nachzug. Ein pauschales Ersetzen des Tag-Strings über
beide — der billigste Reflex nach einem Sprung — fälscht jede Messung still.

**Der Nachbar** [`gate-modul-erreicht-den-vendored-baum-nicht`](../gate-modul-erreicht-den-vendored-baum-nicht/observation.md)
teilt den Auslöser und nicht den Gegenstand: Dort bleibt eine tote Adresse **stumm**, weil
`codepaths.roots` sie nicht erreicht; hier wird sie **laut**, weil ein Sensor über sie stolpert —
nur eben erst in CI und auf jedem Push.

## Benannt, nicht gezählt

Dieselbe Form in einem anderen Baum, gefunden im Review dieses Slice und außerhalb seines Diffs:
`harness/tools/mutate.sh` adressiert das Beobachtungs-Register als `BEO-025` in
`docs/plan/planning/observations.md`. Die Datei gibt es nicht mehr — das Register läuft in
Verzeichnis-Form —, und `BEO-025` ist keine Kennung dieser Form. Bewegt wurde die Ablage von einem
vorgeschriebenen Formwechsel, nicht von einem Baseline-Sprung; der Kommentar gehört zu keinem
abgeschlossenen Vorgang dieses Slice und bewegt den Zähler nicht.

# Mutations-Fall wird von berechtigter Änderung entwaffnet

**Sub-Area:** `*` (gesamtes Repo)

Der `sed`-Anker eines Mutations-Falls zitiert eine Zeile im Wortlaut. Eine berechtigte Änderung an
genau dieser Zeile verschiebt den Wortlaut, der Patch greift nicht mehr, und der Fall mutiert
nichts — der Zahn ist stumpf, während am geprüften Code nichts falsch ist. Der Treiber meldet das
fail-closed (`Mutation hat nicht gegriffen … — Patch veraltet?`), aber erst innerhalb des
Fall-Ablaufs, hinter Isolationskopie und Grün-Vorlauf.

Zwei Nachbarklassen teilen die Ursache — eine Kopplung, die eine Änderung nicht überlebt — und
decken den Fall nicht:
[`mutations-fall-zeigt-auf-falsche-datei`](../mutations-fall-zeigt-auf-falsche-datei/observation.md)
bricht an der `# files:`-Zeile, also an der **Datei**, und bleibt still grün; hier ist die Datei
richtig und der Anker **innerhalb** von ihr verschoben, und der Lauf wird laut.
[`mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md)
bricht an der `# expect:`-Zeile: dort trifft die Mutation weiterhin, hier trifft sie gar nicht mehr.

## Benannt, nicht gezählt

`test/mutations/278-vcs-exclude-sections-ohne-geschichte.sh` ankert auf dem vollständigen
Listen-Literal `exclude-sections: [Geschichte]`. Ein zweiter Abschnitt in dieser Liste entwaffnet
ihn nach derselben Form. Der Fall ist nicht gefallen und gehört zu keinem abgeschlossenen Vorgang.

**Stand:** offen

Die Struktur-Entscheidung steht aus — Träger-Kandidaten: eine begrenzte Wartezeit des Fetch auf
eine frisch gezogene Fassung (Grenze zum fail-closed-Bruch ist zu ziehen) oder eine
Workflow-Anordnung, die die Publikation vor den `full-smoke`-Fetch setzt. Bis dahin ist der
operative Ausgang der Re-Run nach abgeschlossener Publikation; die Lage steht in
[`docs/user/releasing.md`](../../../../../../docs/user/releasing.md) §Prozedur, Schritt 6.

**Ohne Beleg — ein Befund der Register-Paarung (c), keine Ausnahme**
([`ADR-0069`](../../../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)).
Das einzige Vorkommen steht unter *Benannt, nicht gezählt*, und kein abgeschlossener Vorgang trägt es:
Der Release-Schnitt, an dem es auftrat, ist wellenlos und ohne Closure-Notiz. **Weg zum Beleg:** ein
abgeschlossener Vorgang, in dessen Lauf der `traeger-fetch` des `full-smoke` eine noch nicht publizierte
Fassung anfragt und mit 404 fällt — seine Kennung ist der Dateiname unter `evidence/`. Ein Vorgang, der
die Beobachtung nur verwaltet, belegt sie nicht.
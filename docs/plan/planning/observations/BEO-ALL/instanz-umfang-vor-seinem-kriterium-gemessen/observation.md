# Instanz-Umfang vor seinem Kriterium gemessen

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice-Plan schätzt, wie viele Instanzen ein Durchgang umschreiben muss, und misst dafür mit
einem vorläufigen Kriterium; das maßgebliche wird erst im Vorgang festgelegt und trifft mehr
Instanzen. Die vorab benannte Rückführung feuert dann mitten im Durchgang. Die Fehlerrichtung ist
*der Umfang ist klein*.

Die Nachbarklasse
[`rueckfuehrungs-schwelle-misst-nicht-die-eigenschaft-die-sie-bewacht`](../rueckfuehrungs-schwelle-misst-nicht-die-eigenschaft-die-sie-bewacht/observation.md)
misst eine Ersatzgröße. Hier misst die Vormessung die richtige Größe, nur mit einem Kriterium, das
noch nicht feststand.

Ein Wächter besteht nicht: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) liest §6 eines Slice-Plans. Träger ist der Planner-Lauf, der
den Umfang schätzt; er kann das Kriterium als offen benennen, statt eine Zahl zu setzen.

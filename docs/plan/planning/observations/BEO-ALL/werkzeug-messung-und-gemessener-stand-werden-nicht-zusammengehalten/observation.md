# Werkzeug-Messung und gemessener Stand werden nicht zusammengehalten

**Sub-Area:** `*` (gesamtes Repo)

Eine Messung am Verhalten eines Werkzeugs gilt für einen Stand — einen Commit des eigenen Skripts,
einen Digest des gepinnten Bildes —, und die zwei werden nicht zusammengehalten: Die Messung nennt
ihren Stand nicht, oder ein späterer Lauf, der sich auf sie stützt, hält ihn nicht gegen den Stand,
den er fährt. Beide Hälften lesen sich als geltende Aussage über das Werkzeug. Die Fehlerrichtung
ist *die Messung gilt für das, was läuft*.

[`MR-053`](../../../../../../harness/conventions.md#mr-053)
setzt die Schreib-Hälfte für den gepinnten d-check in den Einträgen des Adaptions-Blocks; eine
Sensor-Datei und ein eigenes Werkzeug liegen außerhalb, und für die Lese-Hälfte setzt keine Quelle
etwas.
[`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
fragt, ob die Aussage am gemessenen Stand deckt; hier deckt sie dort und reist ohne ihn weiter.

**Stand:** geplant

Kennung: `slice-162-versions-sensor-baseline-pins` — das `versions`-Modul macht einen vergessenen
Tag-Nachzug zum Befund; §1 des Slice nimmt die Inline-Code-Pfade ohne Link ausdrücklich auf.

Für die Adress-Familie der Mutations-Fälle ist die Ursache beseitigt: ihre `# files:`-Angabe
entdeckt das Tag-Verzeichnis, und `resolve_file_spec` bricht laut ab, wenn eine Angabe nicht auf
genau eine Datei auflöst. Für die übrigen tag-tragenden Adressen hält bis zum Slice kein Wächter.

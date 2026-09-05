# Baum-Hash deckt nicht jeden Prüfgegenstand

**Sub-Area:** `*` (gesamtes Repo)

Ein baum-abgeleiteter Beleg deckt nicht den vollen Prüfgegenstand: Docker-Cache-Zustand und
Host-Werkzeuge liegen strukturell außerhalb jedes Inhalts-Hashs über einem Arbeitsbaum,
Datei-Modi liegen innerhalb des Baums und trotzdem außerhalb — ein wiederverwendeter Beleg
konserviert damit ein Verdikt, das ein anderer, nicht gehashter Zustand widerlegt hätte.

**Stand:** geplant

Kennung: `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`. Er schreibt die Regel, dass eine Aussage über das gepinnte Werkzeug am Quellstand
des Bildes gelesen und nicht aus seiner Dokumentation übernommen wird. Zielort und schreibende
Rolle bestätigt der Architect.

Kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) hält eine
Prosa-Aussage gegen das Verhalten eines Fremd-Bildes, und `make comment-claims` nimmt jede
Markdown-Datei dauerhaft aus seinem Prüfbereich. Träger ist der Lauf, der den Quellstand des
gepinnten Klons öffnet, statt seine Dokumentation zu zitieren.

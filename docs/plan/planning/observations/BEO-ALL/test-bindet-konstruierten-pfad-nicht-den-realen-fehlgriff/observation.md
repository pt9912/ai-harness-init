# Ein Test bindet die Eigenschaft über einem konstruierten Fall, nicht den realen Fehlgriff auf fremder Umgebung

**Sub-Area:** `*` (gesamtes Repo)

Ein Rot-vor-Grün-Test für „Ablageort existiert nicht" legt den fehlenden Pfad selbst im Testlauf an
— er existierte nie. Das bindet die **Eigenschaft** der Ausgabe (Verhalten bei fehlendem Pfad),
nicht den **realen Fall**, den ein Nutzer durch einen vertippten Mount auf einer fremden, diesem
Repo unbekannten Maschine erzeugt — der bleibt strukturell außerhalb der Reichweite eines Tests
dieses Repos. Das ist eine Grenze automatisierter Testbarkeit, kein Mangel des einzelnen Tests.

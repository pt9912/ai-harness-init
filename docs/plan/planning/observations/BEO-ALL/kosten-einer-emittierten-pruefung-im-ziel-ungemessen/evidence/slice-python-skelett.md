**Vorgang:** slice-python-skelett
**Fund:** Der Laufzeit-Zuwachs von `make full-smoke-host` durch die Python-Stufe ist nur mit lokal liegendem Image (`python:3.14.8-slim`) gemessen: Stufe 6 s bis 7 s, Gesamtdifferenz +5 s bis +38 s über zwei Messungen mit Rauschen von rund 25 s; kalter Cache, Image-Pull und PyPI-Zugriff sind ungemessen (§6 Risiko 1, Ausgang weiter offen).

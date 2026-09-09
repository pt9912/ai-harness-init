**Vorgang:** slice-129
**Fund:** Der neue `closure`-Sensor urteilt über Dateien in `done/`; eine fehlende Closure-Notiz
wird also erst sichtbar, **nachdem** das Paket dort liegt. Das ist in diesem Repo der richtige
Moment — der Übergang ist ein reiner `git mv`, und der `make gates`-Lauf danach ist der erste, der
die Datei am neuen Ort sieht. Die engere Kante, die der Prozess tatsächlich verlangt (Notiz **vor**
dem Move: Häkchen und §7 sind nach `modul-05-planning-harness.md` die Bedingung dafür, dass die
Datei überhaupt nach `done/` darf), deckt er nicht und kann er nicht decken. Der Slice-Plan hatte
genau das als Risiko benannt und verlangt, dass es *aufgeschrieben* wird; gemessen steht es nicht in
`harness/README.md` — der Absatz führt den Prüf**bereich** und die Nicht-Rekursion, nicht den
Zeitpunkt. Das Risiko geht damit als *weiter offen* in dieses Register statt still zu verfallen.

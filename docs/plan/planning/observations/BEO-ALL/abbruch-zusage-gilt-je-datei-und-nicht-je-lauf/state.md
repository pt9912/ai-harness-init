**Stand:** offen

Unterhalb der Schwelle; `offen` ist hier der Normalzustand und kein Ausgang. Der Instanz ist die Zusage auf „je
scheiternde Datei" eingeschränkt, und `harness/sensors/slice-mv.md` nennt den späteren Ausfall als ungebundene
Grenze. Ein Wächter besteht nicht: der Go-Test lässt jeden `sed -E` scheitern und trifft den späteren Ausfall
nicht. Der Weg, die Zusage für den Lauf wahr zu machen — den Nachzug erst nach dem letzten Erfolg schreiben —, ist
ein Umbau des Codes und hat keinen Träger; Träger der Klasse ist der Review, der eine Abbruch-Zusage gegen den
Zustand **nach** dem Abbruch liest, nicht gegen die scheiternde Datei.

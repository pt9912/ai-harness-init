**Stand:** offen

Unterhalb der Schwelle; `offen` ist hier der Normalzustand und kein Ausgang. Gemeldet wird die Klasse von
keinem Sensor: kein Modul des Doku-Gates hält den Inhalt einer Regel in einem Sensor-Doc gegen die Ausgabe des
Werkzeugs, über das sie spricht. Träger ist der Review, der die Bedingungen der Regel gegen die Ausgabe eines
echten Laufs hält — die einzige Instanz ist so gefunden und durch eine Werkzeug-Änderung gelöst worden
(`report_key` in `harness/tools/mutate.sh`, Fall 458 in `test/mutations/`).

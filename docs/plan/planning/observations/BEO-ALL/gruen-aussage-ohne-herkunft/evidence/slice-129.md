**Vorgang:** slice-129
**Fund:** Der Standard-DoD-Punkt *„`make mutate` ohne Befund"* stand als erfüllt da, gestützt auf
den Beleg-Slot statt auf einen Lauf — und der Beleg deckte den Baumzustand nicht mehr: gespeichert
war `55a93abb…`, der Schlüssel über `isolation_key_files` lieferte `3db3d84c…`. Die Sach-Hälfte der
Begründung (*reine Kommentar-/Häkchen-Änderung, keine Prüflogik berührt*) war dreifach belegt und
richtig; die **Beleg**-Hälfte trug nicht, und der Wortlaut der Zusage unterscheidet die beiden
Herkünfte nicht. Aufgelöst hat es erst die Verifikation mit einem vollständigen Lauf
(`276 ok, 0 Befund(e)`), nach dem der Schlüssel frisch ist.

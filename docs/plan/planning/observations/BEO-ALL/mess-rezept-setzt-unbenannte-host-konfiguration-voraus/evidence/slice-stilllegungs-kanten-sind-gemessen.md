**Vorgang:** slice-stilllegungs-kanten-sind-gemessen
**Fund:** Das Rezept der Kanten-Messung in der Sensor-Datei von `make slice-mv` setzte eine globale git-Identität voraus. Auf dem Host des Reviewers brach der Basis-Commit ab, und `make slice-mv` hielt danach an der Sperre für einen unsauberen Arbeitsbaum (Review F-4); die Nacharbeit setzt die Identität lokal in der Kopie.

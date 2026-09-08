**Stand:** offen

Der Treiber meldet die Klasse selbst — das ist die funktionierende Hälfte: `make mutate` (Nicht-Gate-Verify)
gibt `BEFUND … rot, aber '<zitierter Titel>' faellt nicht — falscher Grund` aus, statt still
durchzuwinken. Was fehlt, ist die Kopplung **davor**: Kein Wächter hält die `# expect:`-Zeile eines
Falls gegen den Titelbestand seines Sensors, und `make gates` führt den Treiber nicht — die Klasse
wird erst beim nächsten vollen `mutate`-Lauf sichtbar, und der ist an keinen lokalen Auslöser
gebunden.

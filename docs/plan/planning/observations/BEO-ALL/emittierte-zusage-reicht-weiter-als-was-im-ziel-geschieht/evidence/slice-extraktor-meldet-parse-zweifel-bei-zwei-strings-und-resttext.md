**Vorgang:** slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext
**Fund:** Der Kopf der emittierten Extraktor-Fassung nennt „POSIX-awk (busybox/gawk/BSD)"; im Ziel läuft
der awk des Hosts, gemessen sind nur busybox 1.36.1 (`BATS_IMAGE`) und BWK 20200816 (Host des Planners,
kein Normbeleg), gawk und mawk nicht. Zweite Lücke derselben Richtung: `full-smoke` hat keine Stufe, die
einen realen emittierten Guard mit einer Parse-Zweifel-Eingabe fährt; die emittierte Zusage ist nur über
den Vorlagen-Extraktor gedeckt, und der Kopf des Vorlagen-Guards nennt diese Grenze am Ort.

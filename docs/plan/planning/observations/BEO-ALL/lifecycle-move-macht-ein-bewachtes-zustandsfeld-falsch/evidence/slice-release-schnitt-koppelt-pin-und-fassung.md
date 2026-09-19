**Vorgang:** slice-release-schnitt-koppelt-pin-und-fassung

**Fund:** Der Lifecycle-Move der Closure lässt `in-progress/` leer — der
Ruhe-Marker der Roadmap (*Nichts in Arbeit.*) steht damit falsch und wird
vom bewegenden Lauf selbst nachgezogen (eigener Commit dieses Vorgangs nach
dem Move); welcher Schritt das nachzieht, schreibt kein Artefakt des Repos
vor.

**Lage:** Der Vorgang läuft; seine Position im Planning-Lifecycle liest der
Lauf, der diesen Beleg bei der Closure gegen `done/` prüft — die
Lage-Prüfung läuft nach dem Move, der Beleg beansprucht sie hier nicht.
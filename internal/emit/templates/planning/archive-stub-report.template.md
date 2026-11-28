# <Titel>

> **Template-Hinweis.** Vorlage für den gekürzten Stub, der beim Archivieren
> an der Stelle eines Review-Reports liegen bleibt — **am unveränderten Pfad**
> `docs/reviews/<datei>.md`, nicht in einem Wellen-Unterverzeichnis. Kopiere,
> ersetze Platzhalter, lösche diesen Block. Für den Slice-Volltext gilt
> `archive-stub-slice.template.md`, für den Welle-Plan
> `archive-stub-wave.template.md`. Der Stub trägt drei Dinge und sonst nichts:
> Identität (die H1-Zeile des Volltexts), Archiv-Zeiger, Zustand — der Eintrag
> ist die Zuständigkeit, die Welle bzw. der Schlüssel, deren Lauf den Report
> eingesammelt hat; der Volltext liegt byte-genau im Archiv-Zip an dem Pfad,
> den der Zeiger abdruckt. Er trägt keine Abschnittsüberschriften — das
> Merkmal, an dem die Kürzung form-prüfbar ist.

> **Zitier-Form** *(bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieses
> Artefakt friert ein; was es zitiert, bewegt sich weiter. Deshalb: **Kennung,
> nicht Adresse** — `make <target>` statt eines Links auf die Sensor-Datei,
> `ADR-0061` statt eines Links auf die ADR-Datei, eine Baseline-Stelle als
> `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link
> (Baseline-Regelwerk `grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — beim Ausfüllen mit dem adoptierten Tag schreiben).

Regeln dieses Artefakts: ADR-0061 Festlegungen 1 und 2 — der Stub liegt an
derselben Adresse wie der Volltext, sein Inhalt ist Überschrift, Archiv-Zeiger
und Zustand. Der Träger (`archive-welle`, `internal/archive`) liest diese
Vorlage selbst; sie entsteht repo-eigen, weil die Klasse „Report-Stub“ im
Kurs-Satz nicht geführt wird und kein Vorkommen zu referenzieren gibt.

> **ARCHIVIERT** — Volltext:
> `unzip -p done/<wave-id>/archive.zip <pfad-im-archiv>`

**Archiviert mit:** <wave-id | altbestand>

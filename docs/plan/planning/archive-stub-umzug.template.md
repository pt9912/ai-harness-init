# <Titel>

> **Template-Hinweis.** Vorlage für den **Umzugs-Stub**, der beim Archivieren
> an der ALTEN Adresse `done/<base>` eines bewegten Zeitdokuments liegen
> bleibt, wenn ein Baum, den der Verweis-Nachzug nicht erreicht, auf es
> verweist (ADR-0112 Festlegung 1 — das Suchraum-Differenzial). Kopiere,
> ersetze Platzhalter, lösche diesen Block. Der Stub trägt vier Dinge und
> sonst nichts: Identität (die H1-Zeile des Volltexts), den Umzugs-Zeiger auf
> die neue Arbeitsbaum-Adresse (`done/<wave-id>/…` bzw. `done/altbestand/…`),
> den Zustand (`Archiviert mit:` der Schlüssel, dessen Lauf gezogen hat) und
> die Stillgelegt-Fassung im letzten Absatz —
> der Volltext liegt byte-genau an der neuen Adresse, nicht nur im
> Archiv-Zip; darum kein Archiv-Zeiger hier. Er trägt keine
> Abschnittsüberschriften außer der Stillgelegt-Fassung (`## 2. Definition of
> Done` leer und `## 7. Closure-Notiz` mit der `**Gegenstand:**`-Zeile) —
> genau diese zwei erlaubt FormOKUmzug, weil die structure-Regel und das
> planning-Modul des Doku-Gates die Stub-Datei unter
> `done/slice-*.md` als geschlossenen Slice lesen und §2 samt §7 mit
> Kennung oder Grund verlangen. Gegenstück: `archive-stub-report.template.md`
> — derselbe Stub-Mechanismus am unveränderten Pfad eines Review-Reports
> (ADR-0061).

> **Zitier-Form** *(bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieses
> Artefakt friert ein; was es zitiert, bewegt sich weiter. Deshalb: **Kennung,
> nicht Adresse** — `make <target>` statt eines Links auf die Sensor-Datei,
> `ADR-0112` statt eines Links auf die ADR-Datei, eine Baseline-Stelle als
> `v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt> statt als Link
> (Baseline-Regelwerk `grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — beim Ausfüllen mit dem adoptierten Tag schreiben).

Regeln dieses Artefakts: ADR-0112 Festlegungen 1 und 2 — der Stub liegt an der
alten Pfad-Adresse, die Ziel-Klasse ist die bewegte Datei; sein Inhalt ist
Überschrift, Umzugs-Zeiger und Zustand, und `FormOK` hält die Umzugsvariante
dagegen (Zuzugs-Zeiger statt Archiv-Zeiger — ein Stub mit Umzugs-Zeiger und
vollem Text wäre der Umzug, der nicht stattfand). Der Träger (`archive-welle`,
`internal/archive`) liest diese Vorlage selbst; sie entsteht repo-eigen, weil
der Kurs-Satz die Klasse nicht führt und kein Vorkommen zu referenzieren gibt.

> **UMZUGEZOGEN** — der Volltext liegt an der neuen Arbeitsbaum-Adresse:
> `done/<wave-id>/<pfad-im-arbeitsbaum>`

**Archiviert mit:** <wave-id | altbestand>
## 2. Definition of Done
## 7. Closure-Notiz
- **Gegenstand:** <wave-id | altbestand> — der Volltext dieses Slices liegt byte-genau an der Adresse, die der Umzugs-Zeiger nennt. Der Umzugs-Stub behält diese Zeile an der alten Pfad-Adresse, weil ein Baum, den der Verweis-Nachzug nicht erreicht, auf sie verweist. Die Referenz löst nach dem Ablage-Lauf an dieser Adresse weiter auf, statt ins Leere zu zeigen. Der Originaltext liegt in der Archiv-Abgabe des Laufs, der Stub trägt die weiter auflösenden Adressen je eingehender Verweis.

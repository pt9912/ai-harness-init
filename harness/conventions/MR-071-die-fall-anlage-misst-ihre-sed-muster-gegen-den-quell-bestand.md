# MR-071 — Die Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand

- **Datum:** 2026-09-20
- **Wirksamkeits-Anlass:** der 5×-Übertritt des Register-Eintrags
  [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../../docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  — der Vorgänger-Slice (`slice-mutations-faelle-pruefen-ihre-ziel-stellen`, geschlossen) heilte
  die drei Instanzen, nicht die Regel, und der Register-Ausgang löste auf *geplant* mit der
  Kennung `slice-fall-anlage-misst-gegen-den-quell-bestand` (in `open/`); der Gegenstand dieses
  Slices ist dieser Eintrag, und seine Kennung trägt den Herkunfts-Anker unten.
- **Geltungsbereich:** die **Anlage** neuer Mutations-Fälle in `test/mutations/` — der `sed`-Anker
  je Fall gegen den Quell-Bestand. **Nicht** der Treiber (`make mutate` meldet das Verschieben
  fail-closed innerhalb des Fall-Ablaufs, hinter Isolationskopie und Grün-Vorlauf — er bleibt, wie
  er steht). **Nicht** die zwei Nachbar-Klassen des Register-Eintrags:
  [`mutations-fall-zeigt-auf-falsche-datei`](../../docs/plan/planning/observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/observation.md)
  bricht an der `# files:`-Zeile und bleibt still grün,
  [`mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../../docs/plan/planning/observations/BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md)
  bricht an der `# expect:`-Zeile — sie führen eigene Register-Einträge und tragen ihre
  Bruch-Formen dort. **Nicht** die drei vom Vorgänger-Slice geheilten Zähne — sie stehen, wie er
  sie lieferte. **Nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:** keine — der Eintrag zieht eine Anlage-Form nach, die das Regelwerk
  nicht trägt, und tritt an keine Stelle; nach dem Wortlaut der Eintrags-Vorlage damit kein Fork.
  Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:** **Die Regel:** *„Die Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand,
  nicht gegen die Fassung der letzten Fassung"* — **seit
  slice-fall-anlage-misst-gegen-den-quell-bestand**. Wer einen Mutations-Fall anlegt, nimmt den
  Anker aus dem **heutigen** Quell-Bestand — der Zeile, die der Fall verschieben will, wie sie am
  Anlage-Ort liegt — und nicht aus der Fassung, die eine frühere Fassung des Falls oder seines
  Wächters zitierte.
- **Die drei Fundmengen, die den Zähler auf 5 hoben** — je eine berechtigte Änderung, die den
  Wortlaut verschob, auf den der Fall ankerte:
  1. **Die zwei Re-Schnitte der [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)-Emission** — die emittierte Arch-Gate-Config
     (Layer-Namen, Kanten-Menge) änderte sich zweimal berechtigt; die Fälle, die auf die
     alte Config-Form ankerten, griffen nicht mehr.
  2. **Der Quell-Form-Wechsel von `removeStaleDir`/`Neutralize…`** — die Quelle trägt die neuen
     Fassungen (`internal/emit/templates.go:414`/`:428` — die `Neutralize*`-Funktionen; kein
     `Rmdir` in `internal/span/emit.go:344-346` — der Helfer heißt `removeStaleDir`), die
     ankerneden Muster trafen die alten Formen.
  3. **Der `sed`-Anker zitiert den Wortlaut** — dieselbe Form an einer dritten Fundmenge: eine
     berechtigte Änderung an genau der Zeile, die der Anker zitiert, verschiebt den Wortlaut und
     entwaffnet den Fall, ohne am geprüften Code etwas falsch zu machen.
- **Grenze.**
  - **Die Regel verlagert die Prüfung auf die Anlage, nicht auf den Lauf.** Der Treiber meldet
    das Verschieben fail-closed — aber erst innerhalb des Fall-Ablaufs, hinter Isolationskopie
    und Grün-Vorlauf; die Regel verlangt, dass die Anlage den Anker gegen den Quell-Bestand
    misst, **bevor** der Fall existiert.
  - **Kein Sensor hält die Anlage** — die Anlage-Disziplin trägt diesen Eintrag und den
    Review-Lauf über die Case-Diff; ein Struktur-Sensor über sed-Ankern existiert nicht (gemessen
    in der Runde des Register-Eintrags).
  - **Die Regel deckt den `sed`-Anker allein** — die `# files:`- und `# expect:`-Zeilen tragen
    ihre Bruch-Formen in den zwei Nachbar-Klassen, nicht hier.
- **Auflösungs-Trigger:**
  - **Wenn der Treiber das Verschieben schon vor der Isolationskopie meldet** (ein Treiber-Upgrade
    verlagert die Meldung an den Anfang): der Lauf trägt die Anlage-Prüfung selbst, und die
    Regel ist gegen seinen Vertrag neu zu wägen.
  - **Wenn die Fall-Anlage automatisiert wird** — ein Generator legt Mutations-Fälle an: dann
    trägt die Anlage-Form einen anderen Träger (der Generator misst den Anker beim Anlegen), und
    dieser Eintrag ist gegen seine Rolle neu zu fassen.
  - **Wenn die Klasse trotz der Regel wiederkehrt** — ein neuer Beleg im Register-Eintrag, drei
    weitere Vorgänge: dann trägt die Anlage-Disziplin die Form nicht, und ein Sensor oder ein
    Folge-Vorgang ist die Antwort (der Zähler zählt weiter).
- **Begründung:**
  - Die Klasse kostet keinen falschen Code — sie kostet einen **stillen Zahn**: der Wächter wird
    als unbewacht gelistet, während am geprüften Code nichts falsch ist. Die Regel verschiebt die
    Messung an den einzigen Punkt, an dem der Anker billig zu prüfen ist: beim Anlegen, gegen den
    Quell-Bestand.
  - **Kein Vorläufer wird abgelöst** — kein bestehender Eintrag trägt eine Aussage über die
    Fall-Anlage; es gibt darum keine Kopf-Marke nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    /[`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht),
    und die Nachbar-Klassen führen eigene Register-Einträge statt MR-Aussagen, die diese Ablösung
    träfe.
  - Der Treiber ist fail-closed und bleibt es — die Regel nimmt dem Lauf nichts ab, sie
    verlegt die Prüfung dorthin, wo sie billig ist.
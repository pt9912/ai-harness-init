# MR-051 — Der Zahl-Beleg bindet die Commit-Message, und ein Register-Zähler ist eine datierte Messung

- **Datum:** 2026-09-05
- **Wirksamkeits-Anlass:** welle-15 — der Lese-Schritt ihrer Closure. Zwei Einträge des
  Beobachtungs-Registers haben die Schwelle erreicht und bekommen hier ihren Ausgang:
  [`BEO-ALL/zahl-neben-nie-gefahrenem-kommando`](../../docs/plan/planning/observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  und
  [`BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand`](../../docs/plan/planning/observations/BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand/observation.md).
- **Geltungsbereich:** zwei benannte Klassen von Messwerten, die
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  nicht erreicht: die **Commit-Message** dieses Repos (Setzung 1) und der **Zähler-Stand des
  Beobachtungs-Registers**, wo er außerhalb des Registers zitiert wird (Setzung 2). Der
  Geltungsbereich jenes Eintrags — die lebenden, repo-eigenen Markdown-Artefakte — bleibt im
  Übrigen unverändert; dieser Eintrag nimmt ihm nichts weg. **Nicht** die emittierte Ebene: was
  ein emittiertes Repo an Beleg-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene
  entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und die Messung ist am adoptierten Stand `v6.0.0` wiederholt: das Regelwerk führt keine Regel
  über den Beleg einer Zahl in Prosa (`grep -rl 'Erwartungswert' .harness/baseline/v6.0.0/regelwerk/`
  ist leer, Exit 1). Die Klasse kennt es dem Begriff nach als **Harness-Lüge**
  ([`grundlagen-begriffe.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-begriffe.md#kernbegriffe));
  das ist die Umgebung dieser Setzungen, nicht die Regel, an deren Stelle sie träten.
- **Setzung 1 — die Commit-Message steht im Geltungsbereich.** Eine Zahl in einer Commit-Message
  dieses Repos, die als **Messwert** auftritt, bindet
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und 2 wie eine Zahl in einem lebenden Markdown-Artefakt: sie nennt das Kommando, das
  **genau sie** ausgibt, und wer sie schreibt, hat es über dem Baum gefahren, von dem sie spricht.
  Liefert kein Kommando sie, steht **das** dabei. Die Message trägt das Kommando im Klartext; ein
  Link ist dort keine Form.

  **Warum sie und nicht der Rest der Welt.** Sie ist der einzige Zusage-Träger, den
  [`AGENTS.md`](../../AGENTS.md) §3.6 namentlich führt und den nach dem Push **niemand** mehr
  ändern kann. Ein Zeitdokument verliert im Fall des Falles wenigstens seine Adresse
  ([`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4); eine
  Message verliert gar nichts, weil sie niemandes Arbeitsbaum ist. Der Träger muss deshalb
  **vor** dem Commit greifen — dieselbe Begründung, aus der ein Gate über gepushten Messages
  unter [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  fiele.
- **Setzung 2 — ein Zähler-Stand des Beobachtungs-Registers ist eine datierte Messung, kein Wert
  im Text.** Wer ihn außerhalb des Registers zitiert — der Sichtungs-Schritt §8 eines Slice-Plans
  ist der Regelfall —, führt das Kommando, das ihn **ableitet**, kennzeichnet den Wert als
  **keinen** Erwartungswert und zieht die Schwellen-Folgerung aus dem Lauf statt aus dem
  Gedächtnis. Bezugsstand ist der **gemergte** — Baseline-Regelwerk
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-05-planning-harness.md#zwei-schritte-vor-der-modus-begründung)
  §Zwei Schritte vor der Modus-Begründung: *„Gelesen wird der **gemergte** Stand: Das Register ist
  beim Lesen so alt wie der letzte Merge"*.

  **Das ist eine Anwendung, keine zweite Fassung.**
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 nennt die Klasse — eine Zahl, die mit dem Artefakt mitwandert, taugt nicht als
  Erwartungswert. Der Register-Zähler ist ihr reinster Fall, denn er wird abgeleitet und nicht
  geführt: Baseline-Regelwerk
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md#das-beobachtungs-register-modul-6)
  §Das Beobachtungs-Register — *„Es gibt kein Feld, in das man ihn schreibt, und deshalb keines,
  das falsch stehen kann."* Eine Zahl im §8-Block **ist** dieses Feld, nur außerhalb des
  Registers. Dieser Eintrag benennt den Ort; er stellt keine zweite Regel daneben.
- **Begründung (gemessen, nicht postuliert).** Beide Klassen sind über je drei abgeschlossene
  Vorgänge belegt; die Zähler stehen in ihren Verzeichnissen und werden aus den Beleg-Dateien
  abgeleitet:

  ```sh
  ls docs/plan/planning/observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/evidence/*.md          | wc -l   # 3
  ls docs/plan/planning/observations/BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand/evidence/*.md | wc -l   # 3
  ```

  Für Setzung 2 ist die Fläche zusätzlich extensional erhoben. Über den lebenden Plan-Bestand
  gelesen, jede Behauptung der Form *`BEO-ALL/<slug>` (N×…)* gegen den abgeleiteten Stand
  gehalten:

  ```sh
  git grep -hoE 'BEO-ALL/[a-z0-9-]+`\]?(\([^)]*\))?[^(]{0,4}\([0-9]+×' \
      -- 'docs/plan/planning/open/*.md' 'docs/plan/planning/next/*.md' 'docs/plan/planning/*.md' \
    | sed -E 's#^BEO-ALL/([a-z0-9-]+)`.*\(([0-9]+)×#\1 \2#' | sort -u \
    | while read -r s n; do
        printf '%s %s %s\n' "$s" "$n" "$(ls docs/plan/planning/observations/BEO-ALL/"$s"/evidence/*.md 2>/dev/null | wc -l)"
      done | awk '{t++} $2!=$3 {a++} END{print t, a}'
  # -> 11 6
  ```

  **Elf** Behauptungen, **sechs** davon vom abgeleiteten Stand verschieden. **Keine
  Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beide Zahlen wandern mit dem Bestand. Und die zweite Zahl ist **kein Maß für
  Verstöße**: eine Behauptung, die zu ihrem Schreibzeitpunkt wahr war, ist heute verschieden, ohne
  falsch gewesen zu sein. Genau das ist der Befund — der Wert ist eine Kopie einer abgeleiteten
  Größe, und Kopien driften. Die Setzung nimmt ihm darum die Rolle des Werts und gibt ihm die der
  datierten Messung.
- **Der eine Wächter, den
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  für sich ausschließt, liegt hier in Reichweite — gebaut ist er nicht.** Jener Eintrag begründet
  seine Wächterlosigkeit damit, dass die **Messwert-Rolle** einer Zahl ein Urteil ist und kein
  Muster. Für Setzung 2 gilt das nicht: Die Behauptung hat eine Form (`BEO-ALL/<slug>` und eine
  Zahl vor `×`), und ihr Wahrheitswert ist aus dem Dateisystem ableitbar — das Kommando oben
  **ist** der Prüfer, bis auf seinen Prüfbereich. Der Prüfbereich ist die offene Entscheidung: über
  den ganzen lebenden Plan-Bestand liefe er heute an sechs Stellen rot, und die meisten davon
  waren zu ihrem Schreibzeitpunkt wahr — ein Maßstab darüber wäre dauerhaft rot und fiele unter
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6). Diese
  Entscheidung ist ein eigener Vorgang und nicht dieser Eintrag; hier steht sie als **benannte
  Lücke**, nicht als behauptete Deckung. Für Setzung 1 bleibt es beim Urteil: eine Zahl in einer
  Message trägt ihre Rolle nicht an der Form.
- **Warum die Felder `Löst auf` und `Ausgelöst durch Baseline-Stand` fehlen.** Dieser Eintrag löst
  keinen früheren ab; er **erweitert** einen, und das Instrument dafür ist die Kopf-Marke auf dem
  erweiterten Eintrag
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 3, gesetzt in derselben Änderung). Die zwei Felder sind nach der Eintrags-Vorlage
  aneinander gebunden — *„Pflicht zusammen mit ‚Löst auf'"* —, und das zweite hätte hier keinen
  wahren Wert: Ausgelöst hat die Erweiterung kein Baseline-Stand, sondern der Lese-Schritt, und
  der steht im Feld `Wirksamkeits-Anlass`. Ein Tag hineinzuschreiben wäre eine Herkunft, die es
  nicht gibt.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Zahl, die geschrieben oder
  geändert wird; der **Bestand ist kein Arbeitsauftrag**. Die sechs abweichenden Behauptungen oben
  werden von diesem Eintrag **nicht** nachgezogen: sie stehen in Plandateien, die andere Rollen
  schreiben, und wer eine solche Zeile ohnehin anfasst, zieht sie nach. Für die Commit-Message ist
  der Cutoff ohnehin die einzige mögliche Form — gepushte Messages sind unerreichbar. Dieselbe
  Begründung trägt den Cutoff in
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  und in [`AGENTS.md`](../../AGENTS.md) §3.7.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für
  **Senkungen**. Beide Setzungen sind eine **Verschärfung** — ein weiterer Träger im
  Geltungsbereich, eine engere Form für einen abgeleiteten Wert —, und *„Anheben →
  Steering-Loop, kein ADR nötig"* hält
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest.
- **Auflösungs-Trigger:** für Setzung 1 ein Sensor, der eine Message-Datei **vor** dem Commit
  gegen ihre Behauptungen hält, oder eine Baseline, die den Beleg einer Zahl selbst regelt — dann
  ist diese Hälfte gegen den neuen Wortlaut neu zu begründen. Für Setzung 2 ein Wächter über der
  §8-Form mit entschiedenem Prüfbereich; dann trägt die Setzung ihren Sensor statt nur ihre
  Messung. Solange keines von beidem steht, ist der Eintrag aktiv.

# Zeiger-Kommando fängt ein Zitat auf entfernten Wortlaut nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein Kommentar in Code oder Skript zitiert den Wortlaut einer Spec-Passage. Wird die Passage entfernt, findet das Zeiger-Kommando
(`git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools`) Kennungen und Namen, aber kein Zitat; der Kommentar bleibt auf einem Satz stehen,
den es nicht mehr gibt.

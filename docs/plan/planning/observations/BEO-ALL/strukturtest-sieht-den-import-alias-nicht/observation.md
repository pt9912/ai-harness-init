# Strukturtest sieht den Import-Alias nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein go/ast-Strukturtest, der Aufrufe eines Pakets am Selektor-Namen erkennt (`strings.ReplaceAll`),
übersieht denselben Aufruf über einen Import-Alias; der Doc-Kommentar des Tests sagt „jeder" Aufruf
und nennt die Grenze nicht. Auflösbar über `file.Imports` oder als benannte Grenze.

# Persistenz-Zusage ist eine Momentaufnahme, ihr eigener Test widerlegt sie

**Sub-Area:** `*` (gesamtes Repo)

Ein Plan-Abschnitt und mehrere Code-Kommentare behaupten eine Persistenz-Eigenschaft über die
Zeit hinweg ("das Fragment, das zuerst geschrieben hat, behält sein Rezept"), während ein im
selben Diff mitgelieferter Re-Lauf-Test bereits zeigt, dass die Eigenschaft nur direkt nach dem
zweiten Schreibvorgang gilt und bei einem dritten Schreibvorgang selbst für das zuerst
schreibende Fragment nicht mehr stimmt. Die Zusage ist keine Vermutung ohne Beleg — der Beleg
liegt bereits vor, nur ungelesen gegen den eigenen Satz gehalten.

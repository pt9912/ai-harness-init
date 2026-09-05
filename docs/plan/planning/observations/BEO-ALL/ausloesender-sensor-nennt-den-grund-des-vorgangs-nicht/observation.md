# Auslösender Sensor nennt den Grund des Vorgangs nicht

**Sub-Area:** `*` (gesamtes Repo)

Ein Sensor löst einen Vorgang aus und misst dabei eine andere Eigenschaft als die, um derentwillen
der Vorgang läuft: `make freshness-dcheck` meldet *„ein neuer Tag ist da"*, nicht *„der gepinnte
Stand ist verwundbar"*, und kein Gate dieses Repos scannt das gepinnte Fremd-Image. Fällt der
neue Tag aus, bleibt der Grund unbemerkt; der Sensor ist dann grün und die Aussage über den Grund
unbelegt.

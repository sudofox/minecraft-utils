#!/bin/bash

# Puts the playerdata containing parrots back into the world, wipes out backups

rm -f world/playerdata/*backup
cat orig_playerdata/0b5a6ac9-2300-4e42-ad9f-e1650e807bc1.dat > world/playerdata/0b5a6ac9-2300-4e42-ad9f-e1650e807bc1.dat

echo "Successfully reset playerdata, ready to test with ../remove-parrots.sh Morgan_Ladimore"

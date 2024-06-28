docker build -t longjoelhome/ultimate-homebrew-gba -f GBA.Dockerfile . && docker push longjoelhome/ultimate-homebrew-gba
docker build -t longjoelhome/ultimate-homebrew-ps1 -f PS1.Dockerfile . && docker push longjoelhome/ultimate-homebrew-ps1
docker build -t longjoelhome/ultimate-homebrew-ps2 -f PS2.Dockerfile . && docker push longjoelhome/ultimate-homebrew-ps2
docker build -t longjoelhome/ultimate-homebrew-ps3 -f PS3.Dockerfile . && docker push longjoelhome/ultimate-homebrew-ps3
docker build -t longjoelhome/ultimate-homebrew-psp -f PSP.Dockerfile . && docker push longjoelhome/ultimate-homebrew-psp
docker build -t longjoelhome/ultimate-homebrew-gbdk -f GBDK.Dockerfile . && docker push longjoelhome/ultimate-homebrew-gbdk
# oai-gnodeb
## Build with `docker build`
```
# Resolve docker dependency using stagewise build
sudo docker build . -f docker/Dockerfile.base.ubuntu18 -t ran-base:latest
sudo docker build . -f docker/Dockerfile.build.ubuntu18 -t ran-build:latest
# Build actual gnb-base
sudo docker build . -f docker/Dockerfile.gNB.ubuntu18 -t oai-gnb:latest
```
## Run with `docker compose`
```
sudo docker compose -f ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml

```

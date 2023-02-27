## Save the dockers
```
sudo docker save -o ran-base_20.tar ran-base:20
sudo docker save -o ran-build_20.tar ran-build:20
sudo docker save -o oai-gnb_20.tar oai-gnb:latest
```
## Spilt a file
```
split --verbose -b99M oai-gnb_latest.tar oai-gnb_latest.tar.
```
## Recombine
```
cat oai-gnb_latest.tar.a? > oai-gnb_latest_18.tar
```
## Create Docker image
```
sudo docker load --input oai-gnb_latest_18.tar
sudo docker tag <Image-ID> oai-gnb:latest
```


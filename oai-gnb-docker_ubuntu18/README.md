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


# oai-gnodeb
## Download openairinterface
### Git clone
```
git clone -b2023.w08 https://gitlab.eurecom.fr/oai/openairinterface5g/
git clone https://github.com/subhrendu1987/oai-gnodeb
```
### merge the following folders after replacing common files
```
oai-gnodeb/docker/Dockerfile.* -->  openairinterface5g/docker/
oai-gnodeb/ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml  --> openairinterface5g/ci-scripts/yaml_files/sa_b200_gnb/
```
## Resolve docker dependency using stagewise build
Rest of the steps should be performed inside `openairinterface5g` folder
### Build Ran-base
1.  Execute in the host system
	1. Without proxy
		Change `docker/Dockerfile.base.ubuntu20` line 30 `ARG NEEDED_GIT_PROXY`
		```
		sudo docker build . -f docker/Dockerfile.base.ubuntu20 -t ran-base:latest
		```
	1. For systems behing proxy
		Keep `docker/Dockerfile.base.ubuntu20` line 30 `ARG NEEDED_GIT_PROXY="http://172.27.10.67:3128"`
		```
		sudo docker build 
			--build-arg HTTP_PROXY=$http_proxy \
			--build-arg HTTPS_PROXY=$http_proxy \
			--build-arg NO_PROXY="$no_proxy" \
			--build-arg http_proxy=$http_proxy \
			--build-arg https_proxy=$http_proxy \
			--build-arg no_proxy="$no_proxy" \
			----build-arg GIT_PROXY=$http_proxy \
			. -f docker/Dockerfile.base.ubuntu20 \
			-t ran-base:latest
		```
1. Track progress of installation in a separate terminal
	```
	sudo docker exec gnb tail -f /oai-ran/cmake_targets/log/uhd_install_log.txt
	```
1. If build fails then debug inside container
	```
	/bin/sh oaienv
	cd cmake_targets
	./build_oai -I -w USRP --install-optional-packages
	```
1. Exit from the current docker and check 
	1. `sudo docker ps --filter "name=<container name>"`
	1. `sudo docker commit <containerID> <ImageName>`
### Build Ran-build
	```
	sudo docker build . -f docker/Dockerfile.build.ubuntu20 -t ran-build:latest
	# Build actual gnb-base
	sudo docker build . -f docker/Dockerfile.gNB.ubuntu20 -t oai-gnb:latest
	```
## Run with `docker run`
	```
	sudo docker run -it \
		-v /dev:/dev \
		--privileged \
		-e USE_SA_TDD_MONO_B2XX='yes' \
	    -e USE_B2XX='yes' \
	    -e GNB_NAME='gNB-in-docker' \
	    -e MCC='100' \
	    -e MNC='01' \
	    -e MNC_LENGTH=2 \
	    -e TAC=1 \
	    -e NSSAI_SST=1 \
	    -e NSSAI_SD0=1 \
	    -e AMF_IP_ADDRESS='172.21.16.136' \
	    -e GNB_NGA_IF_NAME='eth0' \
	    -e GNB_NGA_IP_ADDRESS='192.168.68.194' \
	    -e GNB_NGU_IF_NAME='eth0' \
	    -e GNB_NGU_IP_ADDRESS='192.168.68.194' \
	    -e USE_ADDITIONAL_OPTIONS='--sa --RUs.[0].sdr_addrs serial=30C51D4 --continuous-tx --log_config.global_log_options level,nocolor,time,line_num,function' \
		oai-gnb:latest \
		--name sa-b200-gnb \
		/bin/bash
	```

## Run with `docker compose`
	```
	sudo docker compose -f ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml up
	```

# oai-gnodeb in a docker
[Architectural diagram](https://app.diagrams.net/#G1q0MFS9GiIhezv8m8cm3Iom4RxhzoIJfL)
### Git clone
```
git clone https://github.com/subhrendu1987/oai-gnodeb
```
### Import oai-gnb
	```	
	cd oai-gnb-docker_ubuntu20 
	cat oai-gnb_20.tar.a? > oai-gnb_20.tar
	sudo docker load --input oai-gnb_20.tar
	sudo docker tag <Image-ID> oai-gnb:latest
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
	    -e USE_ADDITIONAL_OPTIONS='--sa --continuous-tx --log_config.global_log_options level,nocolor,time,line_num,function' \
	    --entrypoint "/bin/bash" \
		oai-gnb:latest \
		--name sa-b200-gnb \
		/bin/bash
	```
## Execute with `docker compose`
Edit `ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml` and modify the following variables as per the core specification:
	1. `AMF_IP_ADDRESS`
	1. `GNB_NGA_IP_ADDRESS`
	1. `GNB_NGU_IP_ADDRESS`
	1. `GNB_NGU_IP_ADDRESS`
	1. `MCC`
	1. `MNC`

### Start service
	`sudo docker compose -f ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml up -d`
### Test and debug
1. `uhd_find_devices`
1. ping test from `GNB` to `AMF` and `AMF` to `GNB`. If ping is not successfull, then try to debug
	1. Commands to be executed in Core-VM
		```
		sudo sysctl net.ipv4.ip_forward=1
		sudo iptables -P FORWARD ACCEPT
		sudo ip route add 192.168.71.194 via <GNB IP>
		```
	1. Check routing tables of `GNB Docker`, `GNB Baremetal`, `Core VM`, `Core Baremetal`
### Execute NR
	1. `sudo docker attach sa-b200-gnb` # Enter into the oai-gnb docker
	1. Inside docker 
		1. `bash bin/entrypoint.sh`
		1. `/opt/oai-gnb/bin/nr-softmodem -O /opt/oai-gnb/etc/gnb.conf $USE_ADDITIONAL_OPTIONS`
	1. `sudo docker compose -f ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml down`

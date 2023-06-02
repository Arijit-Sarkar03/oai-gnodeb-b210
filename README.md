# oai-gnodeb in a docker
## Description
The target [Architectural diagram](https://github.com/subhrendu1987/oaisetup/blob/main/BankOnWheelsPoster.drawio.pdf) has two parts. (a) Virtualized 5G Core[^1] and (b) gNB docker. This tutorial is about how to create gNB docker. We have used Intel Core i7 systems along with Ettus B210. We have used Ubuntu 20.04 and we suggest use of same OS.

[^1]: For Virtualized 5G Core use [this](https://github.com/subhrendu1987/oai-core) repository.
## Docker installation
We have used the following [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04) to install docker engine. Interested readers may go through the given tutorial to avoid `sudo` while using docker along with multiple other useful things.
	```
	
	
	sudo apt update
	
	sudo apt install apt-transport-https ca-certificates curl software-properties-common
	
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	
	apt-cache policy docker-ce
	
	sudo apt install docker-ce
	
	sudo systemctl status docker
	```
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
### Routing table adjustments
1. ping test from `GNB` to `AMF` and `AMF` to `GNB`. If ping is not successfull, then try to debug
	1. Commands to be executed in gNB to enable packet forwarding from Core to the external network via the `Core VM`
		```
		sudo sysctl net.ipv4.ip_forward=1
		sudo iptables -P FORWARD ACCEPT
		sudo ip route add 192.168.70.0 via <Bridge IP of Core VM>
		```
	1. Check routing tables of `GNB Docker`, `GNB Baremetal`, `Core VM`, `Core Baremetal`
	2. For ease of operations use the Google sheet [tool](https://docs.google.com/spreadsheets/d/1n9lvu_eg6hOtkR9DOmAPyxP7QXRWBrLoCCP3OOhmwyw/edit#gid=0)

## Run with `docker run`
	```
	sudo docker run -it \
		-v /dev:/dev \
		--privileged \
		-e USE_SA_TDD_MONO_B2XX='yes' \
	    -e USE_B2XX='yes' \
	    -e GNB_NAME='gNB-in-docker' \
	    -e MCC='001' \
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
2. `GNB_NGA_IP_ADDRESS`
3. `GNB_NGU_IP_ADDRESS`
4. `GNB_NGU_IP_ADDRESS`
5. `MCC`
6. `MNC`

### Start service
	`cd ci-scripts/yaml_files/sa_b200_gnb/; sudo docker compose -f docker-compose.yml up -d`
	### Execute NR
	1. `sudo docker attach sa-b200-gnb` # Enter into the oai-gnb docker
	1. Inside docker 
		1. `bash bin/entrypoint.sh`
		1. `/opt/oai-gnb/bin/nr-softmodem -O /opt/oai-gnb/etc/gnb.conf $USE_ADDITIONAL_OPTIONS`
	1. `sudo docker compose -f ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml down`
files.
### Execute NR after service start
	1. `sudo docker attach sa-b200-gnb` # Enter into the oai-gnb docker
	1. Inside docker 
		1. `bash bin/entrypoint.sh`
		1. `/opt/oai-gnb/bin/nr-softmodem -O /opt/oai-gnb/etc/gnb.conf $USE_ADDITIONAL_OPTIONS`
	1. `sudo docker compose -f ci-scripts/yaml_files/sa_b200_gnb/docker-compose.yml down`
	
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
	1. To test/debug/understand the nr-softmodem configurations use `/custom` folder version of `entrypoint.sh` script and `/custom/conf` configuration 


IMAGE='kd2qar/mercury'


all: build

build:
	#docker build --tag=${IMAGE} .
	docker compose build

shell:
	#docker run --rm --entrypoint /bin/bash --device /dev/snd --group-add audio  -it ${IMAGE}
	docker compose run -i --rm  --entrypoint /bin/bash  mercury -c /bin/bash
up:
	docker compose up  

config:
	docker compose config



FROM debian:trixie-slim AS ruut

#ENV=DEBIAN_FRONTEND=noninteractive

COPY  --chmod=0755 alsa_setup /root/bin/alsa_setup
RUN /root/bin/alsa_setup

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
    libasound2 libpulse0 libhamlib4 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*

FROM ruut AS builder

RUN apt-get update && \
	DEBIAN_FRONTEND="noninteractive" apt-get -y install \
	build-essential libasound2-dev libpulse-dev libhamlib-dev make && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/apt/archives/*

ADD https://github.com/Rhizomatica/mercury.git#v1.9.24 /mercury
#RUN git clone  https://github.com/Rhizomatica/mercury.git /mercury
#ADD mercury-v1.9.24 /mercury

WORKDIR /mercury
RUN make -j$(nproc) && \
	make install && \
	make clean

RUN cp mercury.ini.example mercury.ini

RUN <<-MERC
	#Edit mercury.ini with your callsign and audio devices
	mercury -z # List available sound cards
	mercury -l # List available modem modes
	#mercury # Start Mercury
	MERC
COPY dot.bashrc /root/.bashrc
COPY  --chmod=0755 alsa_setup /root/bin/alsa_setup
RUN /root/bin/alsa_setup

FROM ruut
COPY --from=builder /usr/bin/mercury /usr/bin/mercury
WORKDIR /mercury

#ENTRYPOINT  [ "/bin/bash" ]
ENTRYPOINT ["/usr/bin/mercury","-H","1"]



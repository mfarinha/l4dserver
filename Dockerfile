FROM debian:stretch-slim

# Install, update & upgrade packages
# Create user for the server
# This also creates the home directory we later need
# Clean TMP, apt-get cache and other stuff to make the image smaller
# Create Directory for SteamCMD
# Download SteamCMD
# Extract and delete archive
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		lib32gcc1 \
		wget \
		ca-certificates \
	&& useradd -m steam \
	&& su steam -c \
		"mkdir -p /home/steam/steamcmd \
		&& cd /home/steam/steamcmd \
		&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" \
        && apt-get clean autoclean \
        && apt-get autoremove -y \
        && rm -rf /var/lib/{apt,dpkg,cache,log}


# Switch to user steam
USER steam

# Install L4d2 server
RUN set -x \
 ./home/steam/steamcmd/steamcmd.sh \
        +login anonymous \
        +force_install_dir /home/steam/l4d \
        +app_update 222840 validate \
        +quit 



VOLUME /home/steam/steamcmd

# Set Entrypoint; Technically 2 steps: 1. Update server, 2. Start server
ENTRYPOINT ./home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/l4d +app_update 222840 +quit && \
        ./home/steam/l4d/srcds_run -ip 0.0.0.0 -port 27016 -exec server.cfg

# Expose ports
EXPOSE 0.0.0.0:27016:27016/udp 27016/tcp
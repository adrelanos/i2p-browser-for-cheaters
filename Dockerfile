FROM debian:sid
ARG VERSION

ENV DEBIAN_FRONTEND=noninteractive HOME=/home/anon

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    sed -i.bak 's/sid main/sid main contrib/g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    iceweasel \
    gnupg \
    zenity \
    ca-certificates \
    xz-utils \
    curl \
    sudo \
    --no-install-recommends && \
    localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

RUN groupadd -g 1000 anon
RUN useradd -m -g 1000 -u 1000 -d /home/anon anon
RUN mkdir /home/anon/.local

USER anon

WORKDIR /home/anon

RUN curl -sSL -o /home/anon/tor.tar.xz \
      https://www.torproject.org/dist/torbrowser/${VERSION}/tor-browser-linux64-${VERSION}_en-US.tar.xz

RUN curl -sSL -o /home/anon/tor.tar.xz.asc \
      https://www.torproject.org/dist/torbrowser/${VERSION}/tor-browser-linux64-${VERSION}_en-US.tar.xz.asc

RUN gpg --keyserver ha.pool.sks-keyservers.net \
      --recv-keys "EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290"

RUN gpg --verify /home/anon/tor.tar.xz.asc

RUN tar xf /home/anon/tor.tar.xz

RUN rm -f /home/anon/tor.tar.xz*

RUN curl -sSL -o /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/prefs.js \
    https://github.com/PurpleI2P/i2pdbrowser/raw/master/linux/build/preferences/syspref.js

RUN sed -i 's|i2pd.i2p|i2p-projekt.i2p|g' /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/prefs.js

RUN mv /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js \
    /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/temp.js

RUN grep -v torlauncher /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/temp.js > \
    /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/extension-overrides.js && \
    rm /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/preferences/temp.js

RUN rm -rf /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/extensions/tor*.xpi \
    /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default/extensions/https*.xpi \
    /home/anon/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.meek-http-helper

RUN mv /home/anon/tor-browser_en-US/start-tor-browser.desktop /home/anon/tor-browser_en-US/start-i2p-browser.desktop
RUN mv /home/anon/tor-browser_en-US/Browser/start-tor-browser.desktop /home/anon/tor-browser_en-US/Browser/start-i2p-browser.desktop
RUN mv /home/anon/tor-browser_en-US/Browser/start-tor-browser /home/anon/tor-browser_en-US/Browser/start-i2p-browser

RUN for f in $(find /home/anon/tor-browser_en-US/ -name *.desktop); do sed -i 's|start-tor-browser|start-i2p-browser|g' $f; done

RUN for f in $(find /home/anon/tor-browser_en-US/ -iname *tor*); do echo $f; done

RUN mkdir -p /home/anon/working

RUN cp -r /home/anon/tor-browser_en-US/ /home/anon/working/i2p-browser_en-US/

RUN mv /home/anon/tor-browser_en-US/ /home/anon/i2p-browser_en-US/

RUN cd /home/anon/working/ && tar czf /home/anon/i2p-browser.tar.gz .

USER root

CMD chown -R anon:anon /home/anon/.local/ && \
    chmod -R o+rw /home/anon/.local/ && \
    sudo -u anon /home/anon/i2p-browser_en-US/Browser/start-i2p-browser


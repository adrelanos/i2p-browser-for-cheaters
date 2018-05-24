# Snowflake

[![Build Status](https://travis-ci.org/keroserene/snowflake.svg?branch=master)](https://travis-ci.org/keroserene/snowflake)

Pluggable Transport using WebRTC, inspired by Flashproxy.

### Status

- [x] Transport: Successfully connects using WebRTC.
- [x] Rendezvous: HTTP signaling (with optional domain fronting) to the Broker
  arranges peer-to-peer connections with multitude of volunteer "snowflakes".
- [x] Client multiplexes remote snowflakes.
- [x] Can browse using Tor over Snowflake.
- [ ] Reproducible build with TBB.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Usage](#usage)
  - [Dependencies](#dependencies)
  - [More Info](#more-info)
  - [Building](#building)
- [FAQ](#faq)
- [Appendix](#appendix)
    - [-- Testing Copy-Paste Via Browser Proxy --](#---testing-copy-paste-via-browser-proxy---)
    - [-- Testing directly via WebRTC Server --](#---testing-directly-via-webrtc-server---)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Usage

```
cd client/
go get
go build
tor -f torrc
```
This should start the client plugin, bootstrapping to 100% using WebRTC.

#### Dependencies

Client:
- [go-webrtc](https://github.com/keroserene/go-webrtc)
- Go 1.5+

Proxy:
- [CoffeeScript](coffeescript.org)

---

#### More Info

Tor can plug in the Snowflake client via a correctly configured `torrc`.
For example:

```
ClientTransportPlugin snowflake exec ./client \
-url https://snowflake-reg.appspot.com/ \
-front www.google.com \
-ice stun:stun.l.google.com:19302
-max 3
```

The flags `-url` and `-front` allow the Snowflake client to speak to the Broker,
in order to get connected with some volunteer's browser proxy. `-ice` is a
comma-separated list of ICE servers, which are required for NAT traversal.

For logging, run `tail -F snowflake.log` in a second terminal.

You can modify the `torrc` to use your own broker,
or remove the options entirely which will default to the old copy paste
method (see `torrc-manual`):

```
ClientTransportPlugin snowflake exec ./client --meek
```


#### Building

This describes how to build the in-browser snowflake. For the client, see Usage,
above.

The client will only work if there are browser snowflakes available.
To run your own:

```
cd proxy/
cake build
```
(Type `cake` by itself to see possible commands)

Then, start a local http server in the `proxy/build/` in any way you like.
For instance:

```
cd build/
python -m http.server
```

Then, open a browser tab to `http://127.0.0.1:8000/snowflake.html` to view
the debug-console of the snowflake.,
So long as that tab is open, you are an ephemeral Tor bridge.

### FAQ

**Q: How does it work?**

In the Tor use-case:

1. Volunteers visit websites which host the "snowflake" proxy. (just
like flashproxy)
2. Tor clients automatically find available browser proxies via the Broker
(the domain fronted signaling channel).
3. Tor client and browser proxy establish a WebRTC peer connection.
4. Proxy connects to some relay.
5. Tor occurs.

More detailed information about how clients, snowflake proxies, and the Broker
fit together on the way...

**Q: What are the benefits of this PT compared with other PTs?**

Snowflake combines the advantages of flashproxy and meek. Primarily:

- It has the convenience of Meek, but can support magnitudes more
users with negligible CDN costs. (Domain fronting is only used for brief
signalling / NAT-piercing to setup the P2P WebRTC DataChannels which handle
the actual traffic.)

- Arbitrarily high numbers of volunteer proxies are possible like in
flashproxy, but NATs are no longer a usability barrier - no need for
manual port forwarding!

**Q: Why is this called Snowflake?**

It utilizes the "ICE" negotiation via WebRTC, and also involves a great
abundance of ephemeral and short-lived (and special!) volunteer proxies...

### Appendix

##### -- Testing with Standalone Proxy --

```
cd proxy-go
go build
./proxy-go
```

##### -- Testing Copy-Paste Via Browser Proxy --

Open a browser proxy, passing the `manual` parameter; e.g.
`http://127.0.0.1:8000/snowflake.html?manual=1`,

Open up three terminals for the **client:**

A: `tor -f torrc-manual SOCKSPort auto`

B: `cat > signal`

C: `tail -F snowflake.log`

Then, in the browser proxy:

- Look for the offer in terminal C; copy and paste it into the browser.
- Copy and paste the answer generated in the browser back to terminal B.
- Once WebRTC successfully connects, the browser terminal should turn green.
  Shortly after, the tor client should bootstrap to 100%.

##### -- Testing directly via WebRTC Server --

See server-webrtc/README.md for information on connecting directly to a
WebRTC server transport plugin, bypassing the Broker and browser proxy.

More documentation on the way.

Also available at:
[torproject.org/pluggable-transports/snowflake](https://gitweb.torproject.org/pluggable-transports/snowflake.git/)

# OpenWrt router

## Install packages

For Bitcoin Core to work correctly with PCP / NATPMP, I installed luci-app-upnp + miniupnpd-nftables. The former adds GUI ("Services" menu item with "UPnP IGD & PCP" sub-item), the latter implements the functionality.

## Wipe config

Notable is that I had to do a clean reinstall because the old configuration on the router was adapted for older major versions of OpenWrt, causing errors (the expected nftables were not set up).

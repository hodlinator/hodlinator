# IRC config

Essentially a cheapo version of IRCCloud ($6/month) using:
* Hetzner VM (€4.74/month)
* NixOS (boot the VM using the [ISO](https://nixos.org/download/) and [partition](https://nixos.org/manual/nixos/unstable/index.html#sec-installation-manual-partitioning) and [install](https://nixos.org/manual/nixos/unstable/index.html#sec-installation-manual-installing) by roughly following the linked manual).
* Self-generated certificate (needs to be accepted by browsers, not bothering with Let's Encrypt just for my own services).
* Nginx HTTP proxy to enable TLS.
* TheLounge IRC bouncer with web UI.

~$1 dollar less per month.. and probably worse features.. but more sovereign. 🙂

(Previously used ZNC but didn't feel good with regard to message retention/UI - might have been partially down to user error).

For further details, see [configuration.nix](./configuration.nix).

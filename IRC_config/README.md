# IRC config

Essentially a cheapo version of IRCCloud ($6/month) using:
* Hetzner VM (€4.74/month)
* NixOS
* Self-generated certificate (needs to be accepted by browsers, not bothering with LetsEncrypt).
* Nginx HTTP proxy to enable TLS.
* TheLounge IRC bouncer with web UI.

~$1 dollar less per month.. and probably worse features.. but more sovereign. 🙂

(Previously used ZNC but didn't feel good with regard to message retention/UI - might have been partially down to user error).

For further details, see [configuration.nix](./configuration.nix).

# You have something like the following with the interpreter hard-coded to a FHS
# path but want to use it on NixOS:
# $ file myforeignexecutable
# myforeignexecutable: ELF 64-bit LSB pie executable, x86-64, version 1 (GNU/Linux), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, stripped
#
# Other useful command for listing other runtime-loaded dependencies
# (might partially execute the executable):
# $ ldd myforeignexecutable

if [ -z "$1" ]; then
	echo "Need at least path to executable for later patching"
	exit 1
elif [ -z "$2" ]; then
	echo "Mode 1: List available interpreters for a given executable"
	interpreter_filename=$(file "$1" | sed -E 's/.*interpreter \/([^ ,]+).*/\1/' | sed -E 's/(.*)\/([^\/])/\2/')
	echo "Interpreter: $interpreter_filename"
	echo "Searching /nix/store/ for the interpreter (filtered by glibc)"
	find /nix/store/ -name $interpreter_filename |grep glibc
elif [ -z "$3" ]; then
	echo "Mode 2: Patching ELF with interpreter"
	patchelf --set-interpreter "$2" "$1"
else
	echo "Mode 3: Patching ELF with both interpreter and rpath"
	# Example:
	# ./elf2nix.sh ~/Downloads/bitcoin-qt_27.0 /nix/store/6q2mknq81cyscjmkv72fpcsvan56qhmg-glibc-2.40-66/lib/ld-linux-x86-64.so.2 /nix/store/lqbd7m5hbvhyqs2vha2g60dxfy9mw19z-fontconfig-2.16.0-lib/lib/:/nix/store/ic13kn15vx7wfp0cwizqxxi84ligi93j-freetype-2.13.3/lib/:/nix/store/3b18d0afr22i39grhzc7lvwswnrr72hv-xcb-util-wm-0.4.2/lib/:/nix/store/bihwanc70yfw6fqafwg536ga5hyja0g1-libxcb-1.17.0/lib/:/nix/store/4iyki6wsawj3qyisw3yqqam6x7w50had-libxkbcommon-1.7.0/lib/:/nix/store/525sj2385ns377giypx9p23pf80ihg18-libxcb-1.17.0/lib/:/nix/store/bihwanc70yfw6fqafwg536ga5hyja0g1-libxcb-1.17.0/lib/:/nix/store/nnq0lx0z6ncwsdmsn1prgh1d1m3hdp5i-libxcb-1.17.0/lib/:/nix/store/5d4s33ys70ad8q9smw6brdidblpp0j03-libxcb-1.17.0/lib/:/nix/store/cv6gfvhz8s4fbxri7h297z61dgp4k8nv-libxcb-1.17.0/lib/:/nix/store/2j3c18398phz5c1376x2qvva8gx9g551-libxcb-1.17.0/lib/:/nix/store/525sj2385ns377giypx9p23pf80ihg18-libxcb-1.17.0/lib/:/nix/store/rdkfl7npxnh960cicbcvhjnw53nj1f3b-xcb-util-image-0.4.1/lib/:/nix/store/89ijg6jrypnk09sxlqy9jy6qx96vs173-xcb-util-keysyms-0.4.1/lib/:/nix/store/9wbqazcqh9fp7avl47wvx23f23qadm6x-xcb-util-renderutil-0.3.10/lib/
	patchelf --set-interpreter "$2" --set-rpath "$3" "$1"
fi

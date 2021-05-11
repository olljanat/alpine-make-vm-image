#!/bin/sh

_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2  # bold cyan
}

step 'Set up networking'
cat > /etc/network/interfaces <<-EOF
	auto lo
	iface lo inet loopback

	auto eth0
	iface eth0 inet dhcp
		hostname alpine
EOF
ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

step 'Adjust rc.conf'
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

# TODO: investigate what is needed to enable this one without errors?
# 	-e 's/^[# ](rc_cgroup_mode)=.*/\1=unified/' \

step 'Enable services'
rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add net.eth0 default
rc-update add net.lo boot
rc-update add sshd default
rc-update add termencoding boot

step 'Add users and groups'
passwd -l root
addgroup -g 1100 rancher
addgroup -g 1101 docker
adduser -u 1100 -G rancher -D -h /home/rancher -s /bin/bash rancher
adduser -u 1101 -G docker -D -h /home/docker -s /bin/bash docker
adduser rancher docker
echo 'rancher ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
echo 'docker ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# preperation for https://docs.docker.com/engine/security/userns-remap/
addgroup -g 1200 user-docker
adduser -u 1200 -G user-docker -S -H user-docker
echo 'user-docker:100000:65536' > /etc/subuid
echo 'user-docker:100000:65536' > /etc/subgid

 # FixMe: We shouldn't hardcode password here
echo "rancher:rancher" | chpasswd

#!/bin/sh
random() {
    tr </dev/urandom -dc A-Za-z0-9 | head -c5
    echo
}

array=(1 2 3 4 5 6 7 8 9 0 a b c d e f)
main_interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

gen64() {
    ip64() {
        echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
    }
    echo "$1:$(ip64):$(ip64):$(ip64):$(ip64)"
}
install_3proxy() {
    echo "installing 3proxy"
    mkdir -p /3proxy
    cd /3proxy
    URL="https://github.com/z3APA3A/3proxy/archive/0.9.3.tar.gz"
    wget -qO- $URL | bsdtar -xvf-
    cd 3proxy-0.9.3
    make -f Makefile.Linux
    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    mv /3proxy/3proxy-0.9.3/bin/3proxy /usr/local/etc/3proxy/bin/
    wget https://raw.githubusercontent.com/hoangnammkt/ipv6-proxy/main/script/3proxy.service --output-document=/3proxy/3proxy-0.9.3/scripts/3proxy.service2
    cp /3proxy/3proxy-0.9.3/scripts/3proxy.service2 /usr/lib/systemd/system/3proxy.service
    systemctl link /usr/lib/systemd/system/3proxy.service
    systemctl daemon-reload
#    systemctl enable 3proxy
    echo "* hard nofile 999999" >>  /etc/security/limits.conf
    echo "* soft nofile 999999" >>  /etc/security/limits.conf
    echo "net.ipv6.conf.$main_interface.proxy_ndp=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.proxy_ndp=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.forwarding=1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
    echo "net.ipv6.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
    sysctl -p
    systemctl stop firewalld
    systemctl disable firewalld

    cd $WORKDIR
}

gen_3proxy() {
    cat <<EOF
daemon
maxconn 2000
nserver 1.1.1.1
nserver 1.0.0.1
nserver 2606:4700:4700::1111
nserver 2606:4700:4700::1111
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 6291456 
flush
auth strong
monitor /home/ipsallowlist

users $(awk -F "/" 'BEGIN{ORS="";} {print $1 ":CL:" $2 " "}' ${WORKDATA})

$(awk -F "/" '{print "auth iponly strong\n" \
"allow " $1 "\n" \
"fakeresolve\n" \
"parent 25 connect+ 154.13.201.44 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 154.13.205.41 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 154.13.206.128 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.102.194.138 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.102.194.82 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.102.194.94 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.235.207 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.235.228 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.235.59 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.246.108 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.246.124 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.246.251 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.247.166 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.247.30 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.241.247.57 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.98.185.84 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 172.98.185.88 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 206.232.116.184 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 206.232.116.85 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 23.105.3.124 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 23.226.16.208 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 23.226.16.43 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 45.154.141.94 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 206.232.116.189 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 45.154.143.203 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 154.13.204.204 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 45.154.142.87 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 23.105.3.169 29842 nvuccp JhP6FC2R\n" \
"parent 25 connect+ 23.227.77.233 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 23.234.152.22 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 23.234.152.49 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 23.234.152.72 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 8.18.120.17 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 8.18.120.86 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 8.18.120.92 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 45.146.119.10 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 45.146.119.186 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 45.146.119.200 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 45.146.119.234 29842 eike b3Wpgy0f \n" \
"parent 25 connect+ 23.227.77.233 29842 eike b3Wpgy0f \n" \
"socks -s0 -p" $4 " -i" $3 "\n"\
"flush\n"}' ${WORKDATA})
EOF
}

gen_proxy_file_for_user() {
    cat >proxy.txt <<EOF
$(awk -F "/" '{print $3 ":" $4 ":" $1 ":" $2 }' ${WORKDATA})
EOF
}

gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        echo "$(random)/$(random)/$IP4/$port/$(gen64 $IP6)"
    done
}

gen_iptables() {
    cat <<EOF
    $(awk -F "/" '{print "iptables -I INPUT -p tcp --dport " $4 "  -m state --state NEW -j ACCEPT"}' ${WORKDATA}) 
EOF
}


gen_ifconfig() {
    cat <<EOF
$(awk -F "/" '{print "ifconfig '$main_interface' inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}
echo "installing apps"
yum -y install gcc net-tools bsdtar zip make >/dev/null

install_3proxy

echo "working folder = /home/proxy-installer"
WORKDIR="/home/proxy-installer"
WORKDATA="${WORKDIR}/data.txt"
mkdir $WORKDIR && cd $_

echo "113.169.138.202" >/home/ipsallowlist

IP4=$(curl -4 -s icanhazip.com)
IP6=$(curl -6 -s icanhazip.com | cut -f1-4 -d':')

echo "Internal ip = ${IP4}. Exteranl sub for ip6 = ${IP6}"

FIRST_PORT=10000
LAST_PORT=10001

gen_data >$WORKDIR/data.txt
gen_iptables >$WORKDIR/boot_iptables.sh
gen_ifconfig >$WORKDIR/boot_ifconfig.sh
echo NM_CONTROLLED="no" >> /etc/sysconfig/network-scripts/ifcfg-${main_interface}
chmod +x $WORKDIR/boot_*.sh /etc/rc.local

gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

cat >>/etc/rc.local <<EOF
systemctl start NetworkManager.service
# ifup ${main_interface}
bash ${WORKDIR}/boot_iptables.sh
bash ${WORKDIR}/boot_ifconfig.sh
ulimit -n 65535
/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg &
EOF

bash /etc/rc.local

gen_proxy_file_for_user

WORKDATA="data.txt"
# Tạo file add 
#doi eth0
gen_ifconfig() {
    cat <<EOF
$(awk -F "/" '{print "ifconfig eth0 inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}

# Tao file del
# doi eth0 
gen_ifconfigdel() {
    cat <<EOF
    $(awk -F "/" '{print "ifconfig eth0 inet6 del " $5 "/64"}' ${WORKDATA}) 
EOF
}

# Tao file cau hinh
gen_3proxy() {
    cat <<EOF
daemon
maxconn 2000
nserver 1.1.1.1
nserver 8.8.4.4
nserver 2001:4860:4860::8888
nserver 2001:4860:4860::8844
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 6291456 
flush
auth strong
users $(awk -F "/" 'BEGIN{ORS="";} {print $1 ":CL:" $2 " "}' ${WORKDATA})
$(awk -F "/" '{print "auth strong\n" \
"allow " $1 "\n" \
"proxy -6 -n -a -p" $4 " -i" $3 " -e"$5"\n" \
"flush\n"}' ${WORKDATA})
EOF
}

gen_proxy_file_for_user() {
    cat >proxy.txt <<EOF
$(awk -F "/" '{print $3 ":" $4 ":" $1 ":" $2 }' ${WORKDATA})
EOF
}

# xoa del cu
bash config_del.sh

# Tao file
gen_ifconfigdel >config_del.sh
gen_ifconfig >config_add.sh
gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg  # doi ten

# Cap quyen
chmod +x config_del.sh
chmod +x config_add.sh
chmod +x /usr/local/etc/3proxy/3proxy.cfg # doi ten

# Thuc hien chay
bash config_add.sh
ulimit -n 10048
/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg  # đoi ten 
gen_proxy_file_for_user
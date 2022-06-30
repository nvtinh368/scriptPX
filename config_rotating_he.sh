#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

random() {
	tr </dev/urandom -dc A-Z0-9 | head -c6
	echo
}
# Tao ngau nhien ip6
array=(1 2 3 4 5 6 7 8 9 0 a b c d e f)
gen64() {
	ip64() {
		echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
	}
	ip62() {
                echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
        }
	#echo "2403:6a40:2:16$(ip62):$(ip64):$(ip64):$(ip64):$(ip64)"
	echo "$1:$(ip64):$(ip64):$(ip64):$(ip64)"
}

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


gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        echo "user$port/$(random)/$IP4/$port/$(gen64 $IP6)"
    done
}


gen_ifconfigdel1() {
    cat <<EOF
    $(awk -F "/" '{print "ifconfig he-ipv6 inet6 del " $5 "/64"}' ${WORKDATA}) 
EOF
}

gen_ifconfigdel() {
    cat <<EOF
    $(awk -F "/" '{print "ifconfig he-ipv6 inet6 del " $5 "/64"}' ${WORKDATA1}) 
EOF
}


gen_ifconfig() {
    cat <<EOF
$(awk -F "/" '{print "ifconfig he-ipv6 inet6 add " $5 "/64"}' ${WORKDATA1})
EOF
}

combine_user_ip(){
    # đầu tiên cần làm là xóa thằng data3
	#Sau đó thực hiện copy nó vào trong
	rm -rf data3.txt
	cp data.txt data3.txt
	# Tiếp đến thực hiện xóa thằng data cũ đi vì nó giờ không còn tác dụng
	rm -rf data.txt
	#declare your array
	declare -a ARRAY
	let count=0
	while read LINE; do
		ARRAY[$count]=$LINE
		((count++))
	done < data2.txt

	#echo Number of elements: ${#ARRAY[@]}

	#echo array's content
	#echo ${ARRAY[1]}

	let count2=0
	while read line; do 
		IFS='/' read -r -a array <<< "$line"
		IFS='/' read -r -a arraya <<< "${ARRAY[$count2]}"
		((count2++))
		echo "${array[0]}/${array[1]}/${array[2]}/${array[3]}/${arraya[4]}" >> data.txt;
	done < data3.txt
}



WORKDATA="data.txt"
WORKDATA1="data2.txt"

IP4=$(curl -4 -s icanhazip.com)
IP6=$(curl -6 -s icanhazip.com | cut -f1-4 -d':')

echo "Internal ip = ${IP4}. Exteranl sub for ip6 = ${IP6}"
FIRST_PORT=22500 
LAST_PORT=23000


# tao file
echo "create new data2.txt"
gen_data >data2.txt
echo "config_del with old IPV6"
gen_ifconfigdel1 >config_del1.sh
echo "config_del with new IPV6"
gen_ifconfigdel >config_del.sh
echo "config_del with new IPV6"
gen_ifconfig >config_add.sh
echo "DATA.txt is changing IPV6"
combine_user_ip
echo "create 3proxy.cfg"
gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg # doi ten


# cap quyen
chmod +x config_del1.sh
chmod +x config_del.sh
chmod +x config_add.sh

# run

bash config_add.sh
PIN=$(ps -ax | awk '{print $1";"$6}' |grep 3proxy.cfg ) # doi ten
arrIN=(${PIN//'\n'/ })
for i in ${arrIN[@]}
do
 arrPI=(${i//;/ })
 kill -9 ${arrPI[0]}
done
ulimit -n 10048
/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg # doi ten
bash config_del1.sh

gen_proxy_file_for_user
echo "Proxy Changed!"
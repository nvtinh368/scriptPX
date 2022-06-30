import random
import string

startPort = 23500
endPort = 24300 + 1
ipv4 = '103.214.9.13'


def GeneatorPass():
     return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def GeneratorIPv6Part(n):
    array = 'abcdef0123456789'
    return ''.join(random.choices(array, k=n))

def GeneratorIPv6():
    ipv6 = f'2405:19c0:1{GeneratorIPv6Part(3)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}'
    return ipv6
firewall = open('data\open.txt','w')
proxyFile = open('data\proxy.txt','w')
dataFile = open('data\data.txt','w')
dataFile.write(f'cat <<EOF >data.txt \n')
dataFile.write(f'EOF\n')
dataFile.write(f'\n')
for i in range(startPort,endPort):
    password = GeneatorPass()
    ipv6 = GeneratorIPv6()
    line = f'user{i}/{password}/{ipv4}/{i}/{ipv6}'
    proxy = f'{ipv4}:{i}:user{i}:{password}'
    proxyFile.write(f'{proxy}\n')
    firewall.write(f'firewall-cmd --zone=public --add-port={i}/tcp --permanent\n')
    dataFile.write(f'{line}\n')
    print(line)
firewall.write('firewall-cmd --reload\n')
firewall.close()
proxyFile.close()
dataFile.close()

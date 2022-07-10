import random
import string


# Chỉnh sửa 3 thông số này
startPort = 24500
endPort = 25000 + 1
ipv4 = '103.79.143.78'

def GeneatorPass():
     return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def GeneratorIPv6Part(n):
    array = 'abcdef0123456789'
    return ''.join(random.choices(array, k=n))

# Chỉnh sửa ipv6 cho phù hợp
def GeneratorIPv6():
    ipv6 = f'2400:7ea0:0:8{GeneratorIPv6Part(2)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}'
    return ipv6
firewall = open('openPort.txt','w')
proxyFile = open('proxy.txt','w')
dataFile = open('data.txt','w')
for i in range(startPort,endPort):
    password = GeneatorPass()
    ipv6 = GeneratorIPv6()
    line = f'user{i}/{password}/{ipv4}/{i}/{ipv6}'
    proxy = f'{ipv4}:{i}:user{i}:{password}'
    proxyFile.write(f'{proxy}\n')
    firewall.write(f'firewall-cmd --zone=public --add-port={i}/tcp --permanent\n')
    if i == endPort -1:
         dataFile.write(f'{line}')
    else:
         dataFile.write(f'{line}\n')
    print(line)
firewall.write('firewall-cmd --reload\n')
firewall.close()
proxyFile.close()
dataFile.close()
print("Done")

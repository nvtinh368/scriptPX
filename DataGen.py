import random
import string

startPort = 22610
endPort = 22619 + 1
ipv4 = '143.198.67.182'


def GeneatorPass():
     return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def GeneratorIPv6Part(n):
    array = 'abcdef0123456789'
    return ''.join(random.choices(array, k=n))

def GeneratorIPv6():
    ipv6 = f'2001:470:66:1fa:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}'
    return ipv6

proxyFile = open('data\proxy.txt','w')
dataFile = open('data\data.txt','w')
dataFile.write(f'cat <<EOF >data.txt \n')
for i in range(startPort,endPort):
    password = GeneatorPass()
    ipv6 = GeneratorIPv6()
    line = f'user{i}/{password}/{ipv4}/{i}/{ipv6}'
    proxy = f'{ipv4}:{i}:user{i}:{password}'
    proxyFile.write(f'{proxy}\n')
    dataFile.write(f'{line}\n')
    print(line)
dataFile.write(f'EOF\n')
dataFile.write(f'\n')
proxyFile.close()
dataFile.close()

import random
import string
import shutil
import os
import random
import string

dataOrigin = 'data_origin.txt'
newProxy = open('newProxy.txt','w')
newProxy.close()
oldProxyFile = open('data.txt','r')
expiredFile = open('expiredproxy.txt','r')
expiredProxies = expiredFile.readlines()
oldProxies = oldProxyFile.readlines()
oldProxyFile.close()
expiredFile.close()
portsExpried = []


def GeneatorPass():
     return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def GeneratorIPv6Part(n):
    array = 'abcdef0123456789'
    return ''.join(random.choices(array, k=n))

# Chỉnh sửa ipv6 cho phù hợp
def GeneratorIPv6():
    ipv6 = f'2400:7ea0:0:08{GeneratorIPv6Part(2)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}:{GeneratorIPv6Part(4)}'
    return ipv6

def PortsOfExpried():
     for i in expiredProxies:
          port = i.split(':')[1]
          portsExpried.append(port)

# Thực hiện sao lưu ra file mới phòng trường hợp cần dùng đến
def CopyOriginal():
     if os.path.isfile(dataOrigin):
          os.remove(dataOrigin)
     shutil.copy('data.txt', dataOrigin)


def ChangeUserAndProxy():
     with open('data.txt','w') as newFile:
          newProxy = open('newProxy.txt','w')
          end = len(oldProxies)-1
          for i in oldProxies:
                    arrProxy = i.split('/')
                    if arrProxy[3] in portsExpried:
                         passwd = GeneatorPass()
                         ipvv6 = GeneratorIPv6()
                         newProxy.write(f'{arrProxy[2]}:{arrProxy[3]}:{arrProxy[0]}:{passwd}\n')
                         if i in oldProxies[end]:
                              newFile.write(f'{arrProxy[0]}/{passwd}/{arrProxy[2]}/{arrProxy[3]}/{ipvv6}')
                         else:
                              newFile.write(f'{arrProxy[0]}/{passwd}/{arrProxy[2]}/{arrProxy[3]}/{ipvv6}\n')
                    else:
                         newProxy.write(f'{arrProxy[2]}:{arrProxy[3]}:{arrProxy[0]}:{arrProxy[1]}\n')
                         if i in oldProxies[end]:
                              newFile.write(f'{i.strip()}')
                         else:
                              newFile.write(f'{i.strip()}\n')
          newProxy.close()
CopyOriginal()
PortsOfExpried()
ChangeUserAndProxy()

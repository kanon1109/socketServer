#! /usr/bin/env python
#coding=utf-8
from twisted.protocols.basic import LineReceiver
from twisted.internet.protocol import Factory
from twisted.internet.protocol import Protocol
from twisted.internet import reactor
from ByteArray import ByteArray
import types
#导入协议模块
import Protocols
class SocketServer(Protocol):
    #初始化 构造函数 将类内的属性在此初始化
    def __init__(self):
        return
    #客户端链接成功
    def connectionMade(self):
        print "login", self.transport.client
        self.factory.login(self)
    #客户端链接断开
    def connectionLost(self, reason):
        print "lost", self.transport.client, reason

    def dataReceived(self, data):
        #pass
        print "data", data

class SocketFactory(Factory):
    protocol = SocketServer
    #初始化 构造函数
    def __init__(self):
        #存放客户端mapde
        self.clientMap = {}

    #登录方法
    def login(self, client):
        #pass
        self.clientMap[client] = client
        self.send(client, write_data(1, "akb48"))

    #向客户端发消息
    def send(self, c, msg):
        c.transport.write(msg)

#写入数据
def write_data(id, data):
    #获取协议号 + 内容 以后的长度
    length = getBytesLen(id) + getBytesLen(data)
    print id, length, data
    ba = ByteArray()
    ba.endian = '!'
    ba.writeInt(length)
    ba.writeInt(id)
    #print type(data)
    #根据data类型 写入ba
    if type(data) == types.StringType:
        ba.writeUTFBytes(data)
    elif type(data) == types.IntType:
        ba.writeInt(data)
    elif type(data) == types.BooleanType:
        ba.writeDouble(data)
    return ba.data

#获取数据的字节长度
def getBytesLen(data):
    b = ByteArray()
    if type(data) == types.StringType:
       b.writeUTFBytes(data)
    elif type(data) == types.IntType:
       b.writeInt(data)
    elif type(data) == types.BooleanType:
       b.writeDouble(data)
    return len(b.data)

def main():
    reactor.listenTCP(8000, SocketFactory())
    reactor.run()

if __name__ == "__main__":
    main()
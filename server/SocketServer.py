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
        pass
    #客户端链接成功
    def connectionMade(self):
        print "login", self.transport.client
        self.factory.login(self)
    #客户端链接断开
    def connectionLost(self, reason):
        print "lost", self.transport.client, reason

    def dataReceived(self, data):
        #pass
        read_data(data)

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
        self.send(client, write_multi_data(1, ["akb", 1, 48]))

    #向客户端发消息
    def send(self, c, msg):
        c.transport.write(msg)

#写入数据
#id 协议号
#data 需要写入的数据
def write_data(id, data):
    #获取协议号 + 内容 以后的长度
    length = get_bytes_len(id) + get_bytes_len(data)
    print id, length, data
    ba = ByteArray()
    ba.endian = "!"
    ba.writeInt(length)
    ba.writeInt(id)
    #print type(data)
    #根据data类型 写入ba
    write_data_in_bytes(ba, data)
    return ba.data

#写入多个数据
#id 协议号
#params 一个存放数据的列表
def write_multi_data(id, params):
    length = get_bytes_len(id)
    for i in range(0, len(params)):
        length += get_bytes_len(params[i])
    ba = ByteArray()
    #大端模式标准对齐方式
    ba.endian = "!"
    ba.writeInt(length)
    ba.writeInt(id)
    #根据data类型 写入ba
    for i in range(0, len(params)):
        data = params[i]
        write_data_in_bytes(ba, data)
    return ba.data

#将一个数据写入byteArray
#byteArray  字节数组
#data       需要写入的数据
def write_data_in_bytes(byteArray, data):
    if type(data) == types.StringType:
        byteArray.writeUTFBytes(data)
    elif type(data) == types.IntType:
        byteArray.writeInt(data)
    elif type(data) == types.BooleanType:
        byteArray.writeBoolean(data)
    return byteArray.data


def read_data(data):
    ba = ByteArray(data)
    #大端模式标准对齐方式
    ba.endian = "!"
    length = ba.readInt()

    print "length", length

    print "bytesAvailable", ba.bytesAvailable()

    #只用了1位字节存储 长度-128 - 127
    #业务大类
    actionName = ba.readByte()
    #具体业务类型
    type = ba.readByte()

    print "actionName", actionName
    print "type", type

    str = ba.readUTFBytes(3)
    print str


    i = ba.readInt()
    print i

#获取数据的字节长度
#data 需要获取长度的数据
def get_bytes_len(data):
    b = ByteArray()
    b.endian = "!"
    write_data_in_bytes(b, data)
    return len(b.data)

def main():
    reactor.listenTCP(8000, SocketFactory())
    reactor.run()


if __name__ == "__main__":
    main()
#! /usr/bin/env python
#coding=utf-8
from twisted.protocols.basic import LineReceiver
from twisted.internet.protocol import Factory
from twisted.internet.protocol import Protocol
from twisted.internet import reactor
import struct
import json
from ByteArray import ByteArray
policyStr = '<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0'
clientPolicyStr = '<policy-file-request/>'
#登录协议号
loginProtocol = 1001
#登出协议号
logoutProtocol = 1002
#移动协议号
syncProtocol = 1003
#获取客户端数据的协议号
getClientDataProtocol = 1005

class GameServer(Protocol):
    def __init__(self):
        self.name = ""
    def connectionMade(self):
        print 'new user login', self.transport.client
        self.factory.login(self)
    def connectionLost(self, reason):
        print 'user logout', self.transport.client
        self.factory.logout(self)
    def dataReceived(self, data):
        self.factory.checkData(self, data)

class GameServerFactory(Factory):
    protocol = GameServer
    def __init__(self):
        self.clientList = []
        #保存客户端信息对象 格式为对象 {"ball01":{"name:ball01","x":1,"y":2}}
        self.clientData = {}
        #临时缓存内容
        self.tempDataBuffer = ""
        #临时协议号
        self.id = 0;

    def login(self, client):
        self.clientList.append(client)

    def logout(self, client):
        #写入协议号 长度 内容
        self.clientList.remove(client)
        if client.name == '' and len(self.clientData) == 0:
            return
        if self.clientData.has_key(client.name) == False:
            return
        id = logoutProtocol;
        s = self.clientData[client.name]["name"]
        s = str(s)
        length = len(s)
        print id, length, s
        data = self.writeData(id, s)
        #直接发送ba是否可行？
        self.sendAll(client, data)
        del self.clientData[client.name]
        client.name = ''

    #写入数据
    def writeData(self, id, data):
        length = len(data)
        #print id, length, data
        ba = ByteArray()
        ba.endian = '!'
        ba.writeInt(id)
        ba.writeInt(length)
        ba.writeUTFBytes(data)
        return ba.data

    def sendAll(self, client, data):
        for c in self.clientList:
            if c == client:
                continue
            c.transport.write(data)

    #分解接收的数据，将协议号、长度与内容分开
    #并且将协议号和内容存进一个对象中
    #内容为字符串
    def decode(self, data):
        ba = ByteArray(data)
        ba.endian = "!"
        #判断长度
        #print 'self.tempDataBuffer', self.tempDataBuffer
        if self.tempDataBuffer == "":
            self.id = ba.readInt()
            print self.id
            length = ba.readInt()
            s = ba.readUTFBytes(ba.bytesAvailable())
            print 'length', length, len(s)
            #判断长度
            if len(s) < length:
                self.tempDataBuffer = s
            else:
                print "content", s
                return {"id":self.id, "content":s}
        else:
            s = self.tempDataBuffer + ba.readUTFBytes(ba.bytesAvailable())
            print 'hebing', s
            return {"id":self.id, "content":s}

    #判断数据并格式化数据
    def checkData(self, client, data):
        if type(data) == str and data.find(clientPolicyStr) != -1:
            client.transport.write(policyStr)
        else:
            o = self.decode(data)
            if o:
                self.protocolManager(client, o)
            print type(data)

    #根据接受的对象数据 区分协议号后分别执行各自的功能
    def protocolManager(self, client, obj):
        if obj['id'] == loginProtocol:
            #发送所有人物的数据到当前客户端
            id = loginProtocol
            s = json.dumps(self.clientData)
            data = self.writeData(id, s)
            client.transport.write(data)
            #--------------------------------------
            #将新登录的用户添加进用户对象列表
            #将内容字符串转成对象
            contentObj = json.loads(obj["content"])
            client.name = contentObj["name"]
            #self.clientData.append(contentObj)
            self.clientData[client.name] = contentObj
            #print self.clientData
            #--------------------------------------
            #发送登录的人物数据给所有客户端
            id = getClientDataProtocol;
            s = obj["content"]
            s = str(s)
            data = self.writeData(id, s)
            self.sendAll(client, data)
            print s
        elif obj['id'] == logoutProtocol:
            #登出协议
            pass
        elif obj['id'] == syncProtocol:
            #更新发送者的位置，并且转发所有人。
            if self.clientData.has_key(client.name) == False:
                return
            #print 'obj["content"]', obj["content"]
            try:
                contentObj = json.loads(obj["content"])
                print contentObj
                o = self.clientData[client.name]
                o['x'] = contentObj['x']
                o['y'] = contentObj['y']
                #转发所有人物数据
                id = syncProtocol
                s = obj["content"]
                s = str(s)
                data = self.writeData(id, s)
                self.sendAll(client, data)
            except:
                return

def main():
    reactor.listenTCP(8000, GameServerFactory())
    reactor.run()

if __name__ == "__main__":
    main()

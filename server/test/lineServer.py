#! /usr/bin/env python
#coding=utf-8
from twisted.protocols.basic import LineReceiver
from twisted.internet.protocol import Factory
from twisted.internet import reactor
from ByteArray import ByteArray
class LineEcho(LineReceiver):
    def connectionMade(self):
        print 'new user login', self.transport.client
        #self.transport.write('welcome')
        self.factory.login(self)
    def connectionLost(self, reason):
        print 'user logout'
        self.factory.logout(self)
    def lineReceived(self, line):
        print line
        ba = ByteArray(line)
        print ba.bytesAvailable()
        s = ba.readInt()
        print s
        s = ba.readUTFBytes(ba.bytesAvailable())
        print s
        self.factory.sendAll(self, line)

class lineFactory(Factory):
    protocol = LineEcho
    def __init__(self):
        self.clientList = []

    def login(self, client):
        self.clientList.append(client)

    def logout(self, client):
        self.clientList.remove(client)

    def sendAll(self, client, line):
        #发送安全策略

        for p in self.clientList:
            pass
            #if p == client:
                #continue
            # p.transport.write(line+"\n");

reactor.listenTCP(8000, lineFactory())
reactor.run()


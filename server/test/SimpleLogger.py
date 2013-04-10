#! /usr/bin/env python
#coding=utf-8
from twisted.internet import reactor
from twisted.internet.protocol import Factory
from twisted.protocols.basic import LineReceiver
from twisted.internet.protocol import Protocol
import struct
from ByteArray import ByteArray

class SimpleLogger(Protocol):

    def connectionMade(self):
        print 'Got connection from', self.transport.client
    def connectionLost(self, reason):
        print self.transport.client, 'disconnected'
    #def lineReceived(self, line):
       # print line
    def dataReceived(self, data):
        ba = ByteArray(data)
        print ba.bytesAvailable()
        s = ba.readUnsignedInt()
        print ba.bytesAvailable()
        print s
        s = ba.readUTFBytes(ba.bytesAvailable())
        print s



factory = Factory()
factory.protocol = SimpleLogger
reactor.listenTCP(8000, factory)
reactor.run()

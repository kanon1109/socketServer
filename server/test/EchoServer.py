#! /usr/bin/env python
#coding=utf-8
from twisted.internet.protocol import Protocol, Factory
from twisted.internet import reactor
print "asdasd"
policyStr = '<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0'
class Echo(Protocol):
    def connectionMade(self):
        print 'new user login'
    def connectionLost(self, reason):
        print 'user logout', self.transport.client    
    def dataReceived(self, data):
        #print data.find('<policy-file-request/>')
        if data.find('<policy-file-request/>') != -1:
            print "发送安全策略"
            print policyStr
            self.transport.write(policyStr)
        else:
            self.transport.write("ok")

def main():
   
    f = Factory()
    f.protocol = Echo
    reactor.listenTCP(8000, f)
    reactor.run()

if __name__ == '__main__':
    main()

#! /usr/bin/env python
#coding=utf-8
'''
Created on 2009-9-8
@author: babyfaction
'''

import struct
class ByteArray():
    '''
    classdocs
    '''
    data = ""
    position = 0

    def __init__(self,str_data=''):
        '''
        Constructor
        '''
        self.data = str_data
        self.endian = '@'
    def bytesAvailable(self):
        return len(self.data) - self.position

    def length(self):
        return len(self.data)

    def readByte(self):
        return self._read_data('b')

    def readUnsignedByte(self):
        return self._read_data('B')

    def readInt(self):
        return self._read_data('i')

    def readUnsignedInt(self):
        return self._read_data('I')

    def readShort(self):
        return self._read_data('h')

    def readUnsignedShort(self):
        return self._read_data('H')

    def readFloat(self):
        return self._read_data('f')

    def readDouble(self):
        return self._read_data('d')

    def readUTFBytes(self,length):
        return self._read_data('%ds'%(length))

    def readBoolean(self):
        return self._read_data('?')

#    write
    def writeByte(self,b):
        return self._write_data('b',b)

    def writeUnsignedByte(self,ub):
        return self._write_data('B',ub)

    def writeInt(self,i):
        return self._write_data('i',i)

    def writeUnsignedInt(self,ui):
        return self._write_data('I',ui)

    def writeShort(self,sh):
        return self._write_data('h',sh)

    def writeUnsignedShort(self,us):
        return self._write_data('H',us)

    def writeFloat(self,f):
        return self._write_data('f',f)

    def writeDouble(self,d):
        return self._write_data('d',d)

    def writeUTFBytes(self,s):
        return self._write_data('%ds'%(len(s)),s)

    def writeBoolean(self,b):
        return self._write_data('?',b)

    def _read_data(self,fmt):
        a = struct.unpack_from(self.endian + fmt,self.data,self.position)
        self.position += struct.calcsize(fmt)
        return a[0]

    def _write_data(self,fmt,data):
        a = struct.pack(self.endian + fmt, data)
        self.data += a
        self.position += struct.calcsize(fmt)

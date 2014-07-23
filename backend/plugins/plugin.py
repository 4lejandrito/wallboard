import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import sys
 
class Plugin():
    
    def open(self):
        'STAAAART'
 
    def close(self):
        'CLOOOSE'
    
    def emitMessage(self, message):
        self.write(message)
    
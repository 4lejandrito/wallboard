import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import sys
 
class Plugin(tornado.websocket.WebSocketHandler):
    
    def check_origin(self, origin):
        return True
    
    def open(self):
        self.start()
      
    def on_message(self, message):
        getattr(self, message)()
 
    def on_close(self):
        self.close()
    
    def emitMessage(self, message):
        self.write(message)
    
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import sys
from plugins import *

class WSHandler(tornado.websocket.WebSocketHandler):
    
    def check_origin(self, origin):
        return True
    
    def open(self, plugin):
        plugins = __import__('plugins')
        self.plugin = getattr(plugins, plugin)()
        self.plugin.start()
      
    def on_message(self, message):
        getattr(self.plugin, message)()
 
    def on_close(self):
        self.plugin.close()
    
    def emitMessage(self, message):
        self.plugin.write(message)

if __name__ == "__main__":

    application = tornado.web.Application([(r'/(?P<plugin>[^\/]+)',WSHandler)], debug=True)
    tornado.options.parse_command_line()
    server = tornado.httpserver.HTTPServer(application)
    server.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
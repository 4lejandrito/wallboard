import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
 
 
class WSHandler(tornado.websocket.WebSocketHandler):
    
    def check_origin(self, origin):
        return True
    
    def open(self):
        self.plugin = SamplePlugin()
        #self.plugin.onMessage(self.emitMessage)
        self.plugin.start()
      
    def on_message(self, message):
        getattr(self.plugin, message)()
        #self.plugin[message.method](message.arguments)
 
    def on_close(self):
        self.plugin.close()
    
    def emitMessage(self, message):
        self.write(message)

class Plugin() :
    def start(self):
        print 'PLUGIN STARTED'
    def message(self, message):
        print 'PLUGIN' + message
    def close(self):
        print 'PLUGIN CLOSED'
    def config(self, config):
        print 'CONFIG'
        

application = tornado.web.Application([
    (r'/ws', WSHandler),
], debug=True)
 
 
if __name__ == "__main__":
    tornado.options.parse_command_line()
    server = tornado.httpserver.HTTPServer(application)
    server.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
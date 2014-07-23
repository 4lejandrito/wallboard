import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import sys
from plugins import *

def pluginSub():
    print Plugin.__subclasses__()
    
if __name__ == "__main__":
    handArr = []
    for cl in Plugin.__subclasses__() :
        handArr.append((r'/'+cl.__name__,cl))
    application = tornado.web.Application(handArr, debug=True)
    tornado.options.parse_command_line()
    server = tornado.httpserver.HTTPServer(application)
    server.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
from plugin import Plugin

class TravisPlugin(Plugin) :
    def start(self) :
        print 'Started Travis socket'

#from travispy import TravisPy

#t = TravisPy.github_auth('1f5fe06e1616dacf11606678b841b527d5b4015a')
#user = t.user()
#repos = t.repos(member=user.login)

#for rep in repos :
#    print rep.slug
#    build = t.build(rep.last_build_id)
#    print build.state

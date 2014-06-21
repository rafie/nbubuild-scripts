#!/usr/bin/python

from optparse import OptionParser
import shlex, subprocess

class System:
	@staticmethod
	def command(cmd):
		return System(cmd)
	
	def __init__(self, cmd):
		self.cmd = cmd
		args = shlex.split(cmd)
		


parser = OptionParser()
parser.add_option("-v", "--volume", dest="vol_name",
                  help="crete share for volume VOL", metavar="voL")
parser.add_option("-n", "--name", dest="share_name",
                  help="crete share SHARE", metavar="SHARE")
parser.add_option("-g", "--group", dest="unix_group_name",
                  help="with dominant UNIX group GROUP", metavar="GROUP")


# parser.add_option("-q", "--quiet",
#                   action="store_false", dest="verbose", default=True,
#                   help="don't print status messages to stdout")

(options, args) = parser.parse_args()

share = options.share_name
vol = options.vol_name
q_share = vol + "/" + share
fq_share = "/volumes/" + q_share

jojo = Jojo.make('vivi')

# cmd = System.command("zfs create %s" % (q_share))

"""Request Manager module"""

import sys, thread

from src.util.exception import VDOM_exception
from src.util.semaphore import VDOM_semaphore

class VDOM_request_manager(dict):
	"""Request manager class"""

	def __init__(self):
		"""constructor"""
		dict.__init__(self)
		self.__sem = VDOM_semaphore()

	def __getitem__(self, key):
		raise AttributeError

	def __setitem__(self, key, value):
		raise AttributeError

	def __delitem__(self, key):
		raise AttributeError

	def __contains__(self, key):
		raise AttributeError

	def get_request(self):
		#self.__sem.lock()
		try:
			
			r = self.get(thread.get_ident(),None)
			if r:
				return r
			raise VDOM_exception(_("No request associated with current thread"))
		except:
			raise VDOM_exception(_("No request associated with current thread"))
		#finally:
		#	self.__sem.unlock()

	def set_request(self, request):
		self.__sem.lock()
		#debug("set request")
		try:
			dict.__setitem__(self, thread.get_ident(), request)
		finally:
			self.__sem.unlock()

	def remove_request(self):
		self.__sem.lock()
		#debug("remove request")
		try:
			dict.__delitem__(self, thread.get_ident())
		except:
			pass
		finally:
			self.__sem.unlock()

	current = property(get_request, set_request, remove_request)


internal_request_manager = VDOM_request_manager()
del VDOM_request_manager

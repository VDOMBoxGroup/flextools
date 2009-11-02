package net.vdombox.ide.model
{
	import net.vdombox.ide.interfaces.IApplicationProxy;
	import net.vdombox.ide.interfaces.IPageProxy;
	import net.vdombox.ide.model.business.SOAP;
	import net.vdombox.ide.model.vo.ApplicationVO;
	import net.vdombox.ide.model.vo.PageVO;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ApplicationProxy extends Proxy implements IApplicationProxy
	{
		public static const NAME : String = "ApplicationProxy";

		public function ApplicationProxy( proxyName : String, data : Object = null )
		{
			super( proxyName, data );
		}

		private var _selectedPage : PageVO;

		private var soap : SOAP = SOAP.getInstance();

		private var serverProxy : ServerProxy;

		public function get id() : String
		{
			return applicationVO.id;
		}

		public function get information() : ApplicationVO
		{
			return applicationVO;
		}

		public function get selectedPage() : PageVO
		{
			return _selectedPage;
		}

		public function get selectedPageID() : String
		{
			if ( _selectedPage )
				return _selectedPage.id;
			else
				return null;
		}
		
		public function load( applicationID : String ) : void
		{
			var dummy : * = ""; // FIXME remove dummy
		}

		public function createPage( pageID : String ) : PageVO
		{
			return null;
		}

		public function deletePage( pageVO : PageVO ) : void
		{
		}

		public function deletePageAt( pageID : String ) : void
		{
		}

		public function getPageAt( pageID : String ) : PageVO
		{
			return null;
		}

		public function getPageProxie( pageVO : PageVO ) : IPageProxy
		{
			return null;
		}

		public function getPageProxieAt( pageID : String ) : IPageProxy
		{
			return null;
		}
		
		private function get applicationVO() : ApplicationVO
		{
			return data as ApplicationVO;
		}
	}
}
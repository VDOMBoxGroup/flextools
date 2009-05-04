package net.vdombox.ide.interfaces
{
	import org.puremvc.as3.multicore.interfaces.IProxy;

	public interface IApplicationProxie extends IProxy
	{
		function get id() : String;
		function get information() : XML;
		function get selectedPage() : PageVO;
		function get selectedPageID() : String;
//		function get pagesList() : IPageVO; ???

		function createPage( pageID : String ) : PageVO;
		function deletePage( pageVO : PageVO ) : void;
		function deletePageAt( pageID : String ) : void;
		function getPageAt( pageID : String ) : PageVO;
		function getPageProxie( pageVO : PageVO );
		function getPageProxieAt( pageID : String );
	}
}
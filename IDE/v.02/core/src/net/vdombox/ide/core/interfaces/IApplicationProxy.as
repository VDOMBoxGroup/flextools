package net.vdombox.ide.core.interfaces
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;

	public interface IApplicationProxy extends IProxy
	{
		function get id() : String;
		function get information() : ApplicationVO;
		function get selectedPage() : PageVO;
		function get selectedPageID() : String;
//		function get pagesList() : IPageVO; ???

		function createPage( pageID : String ) : PageVO;
		function deletePage( pageVO : PageVO ) : void;
		function deletePageAt( pageID : String ) : void;
		function getPageAt( pageID : String ) : PageVO;
		function getPageProxie( pageVO : PageVO ) : IPageProxy;
		function getPageProxieAt( pageID : String ) : IPageProxy;
	}
}
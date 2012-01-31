package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CheckSelectedPageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body 	: Object = notification.getBody();
			var pagesVO : Array;
			
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var indexPageID : String = statesProxy.selectedApplication ? statesProxy.selectedApplication.indexPageID : "";
			
			if (!body)
				return;
			
			pagesVO = body.pagesVO;
			
			if ( statesProxy.selectedPage )
			{
				if ( pageExists(pagesVO, statesProxy.selectedPage.id) )
					return;
			}
			
			if ( indexPageID && indexPageID != "" && indexPageID != "None" && pageExists(pagesVO, indexPageID) )	 // IndexPageID exists.
			{
				sendNotification(ApplicationFacade.PAGE_SET_SELECTED, {pageVO: getPageVOByID(pagesVO, indexPageID)});
			} 
			else 		// IndexPageID does not exist.
			{
				if (pagesVO && pagesVO.length > 0)
					sendNotification(ApplicationFacade.PAGE_SET_SELECTED, {pageVO: pagesVO[0]});
				else 
					sendNotification(ApplicationFacade.PAGE_SET_SELECTED, {pageVO: null});
			}
		}
		
		private function getPageVOByID(pagesVO : Array, id : String) : PageVO
		{
			if (!pagesVO || pagesVO.length == 0)
				return null;
				
			for each (var pageVO : PageVO in pagesVO)
			{
				if (pageVO.id == id)
				{
					return pageVO;
				}
			}
			
			return null;
		}
		
		private function pageExists(pagesVO : Array, pageId : String) : Boolean
		{
			if (!pagesVO || pagesVO.length == 0)
				return false;
			
			for each (var pageVO : PageVO in pagesVO)
			{
				if (pageVO.id == pageId)
				{
					return true;
				}
			}
			
			return false;
		}

	}
}
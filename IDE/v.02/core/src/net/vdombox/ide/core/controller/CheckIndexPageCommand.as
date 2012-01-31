package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CheckIndexPageCommand extends SimpleCommand
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
			
			if ( indexPageID && indexPageID != "None")
			{
				if (pageExists(pagesVO, indexPageID))
					return;	
			}
			
			if ( statesProxy.selectedPage && pageExists(pagesVO, statesProxy.selectedPage.id) )	 // selectedPage exists.
			{
				sendNotification(ApplicationFacade.PAGE_SET_AS_INDEX, {pageID: statesProxy.selectedPage.id});
			} 
			else 		// selectedPage does not exist.
			{
				if (pagesVO && pagesVO.length > 0)
					sendNotification(ApplicationFacade.PAGE_SET_SELECTED, {pageID: pagesVO[0].id});
				else 
					sendNotification(ApplicationFacade.PAGE_SET_SELECTED, {pageID: ""});
			}
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
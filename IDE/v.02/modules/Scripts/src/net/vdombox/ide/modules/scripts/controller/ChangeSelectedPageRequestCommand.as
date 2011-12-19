package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedPageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var selectedPageVO : PageVO = notification.getBody() as PageVO;
			
			if( sessionProxy.selectedPage.id == selectedPageVO.id )
			{
				if( sessionProxy.selectedObject )
					sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, null );
				
				return;
			}
			
			var oldPageID : String = sessionProxy.selectedPage ? sessionProxy.selectedPage.id : "";
			var newPageID : String = selectedPageVO ? selectedPageVO.id : "";
			
			if( oldPageID != newPageID )
				sendNotification( ApplicationFacade.SET_SELECTED_PAGE, selectedPageVO );
		}
	}
}
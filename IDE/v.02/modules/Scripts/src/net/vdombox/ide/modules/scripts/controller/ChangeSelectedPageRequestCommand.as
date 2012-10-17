package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedPageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var selectedPageVO : PageVO = notification.getBody() as PageVO;
			
			if( statesProxy.selectedPage.id == selectedPageVO.id )
			{
				if( statesProxy.selectedObject )
					sendNotification( StatesProxy.SET_SELECTED_OBJECT, null );
				
				return;
			}
			
			var oldPageID : String = statesProxy.selectedPage ? statesProxy.selectedPage.id : "";
			var newPageID : String = selectedPageVO ? selectedPageVO.id : "";
			
			if( oldPageID != newPageID )
				sendNotification( StatesProxy.SET_SELECTED_PAGE, selectedPageVO );
		}
	}
}
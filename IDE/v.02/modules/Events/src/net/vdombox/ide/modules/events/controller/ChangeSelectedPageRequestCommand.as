package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
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
					sendNotification( SessionProxy.SET_SELECTED_OBJECT, null );
				
				return;
			}
			
			if( sessionProxy.selectedPage && selectedPageVO && sessionProxy.selectedPage.id == selectedPageVO.id )
				return;
			
			sendNotification( SessionProxy.SET_SELECTED_PAGE, selectedPageVO );
		}
	}
}
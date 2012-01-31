package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	
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
			
			if( sessionProxy.selectedPage && selectedPageVO && sessionProxy.selectedPage.id == selectedPageVO.id )
				return;
			
			sendNotification( ApplicationFacade.SET_SELECTED_PAGE, selectedPageVO );
		}
	}
}
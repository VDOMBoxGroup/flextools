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
			var selectedPageVO : PageVO = notification.getBody() as PageVO;
			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			var currentSelectedPageVO : PageVO = statesObject[ ApplicationFacade.SELECTED_PAGE ];
			
			if( selectedPageVO != currentSelectedPageVO )
			{
				sendNotification( ApplicationFacade.SET_SELECTED_PAGE, selectedPageVO );
			}
		}
	}
}
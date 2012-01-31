package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedDataBaseRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var pageVO : PageVO = notification.getBody() as PageVO;
			
			var oldPageID : String = sessionProxy.selectedBase ? sessionProxy.selectedBase.id : "";
			var newPageID : String = pageVO ? pageVO.id : "";
			
			
			if( oldPageID != newPageID )
				sendNotification( ApplicationFacade.SET_SELECTED_PAGE, pageVO );
		}
	}
}
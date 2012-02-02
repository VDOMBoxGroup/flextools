package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedDataBaseRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var pageVO : PageVO = notification.getBody() as PageVO;
			
			var oldPageID : String = statesProxy.selectedPage ? statesProxy.selectedPage.id : "";
			var newPageID : String = pageVO ? pageVO.id : "";
			
			if( oldPageID != newPageID )
				 statesProxy.selectedPage = pageVO;
		}
	}
}
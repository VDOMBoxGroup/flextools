package net.vdombox.ide.modules.wysiwyg.controller
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
			var pageVO : PageVO = notification.getBody() as PageVO;

			var oldPageID : String = statesProxy.selectedPage ? statesProxy.selectedPage.id : "";
			var newPageID : String = pageVO ? pageVO.id : "";

			if ( statesProxy.selectedPage && pageVO && statesProxy.selectedPage.id == pageVO.id )
			{
				if ( statesProxy.selectedObject )
					sendNotification( StatesProxy.SET_SELECTED_OBJECT, null );

				return;
			}

			if ( oldPageID != newPageID )
				sendNotification( StatesProxy.SET_SELECTED_PAGE, pageVO );
		}
	}
}

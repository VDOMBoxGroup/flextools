package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedPageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var pageVO : PageVO = notification.getBody() as PageVO;
			
			var oldPageID : String = sessionProxy.selectedPage ? sessionProxy.selectedPage.id : "";
			var newPageID : String = pageVO ? pageVO.id : "";
			
			if( sessionProxy.selectedPage && pageVO && sessionProxy.selectedPage.id == pageVO.id )
			{
				if( sessionProxy.selectedObject )
					sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, null );
				
				return;
			}
			
			if( oldPageID != newPageID )
				sendNotification( ApplicationFacade.SET_SELECTED_PAGE, pageVO );
		}
	}
}
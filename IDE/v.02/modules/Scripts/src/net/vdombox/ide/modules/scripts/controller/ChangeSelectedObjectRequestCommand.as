package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var selectedObject : ObjectVO = sessionProxy.selectedObject;
			var selectedPage : PageVO = sessionProxy.selectedPage;

			if ( selectedObject != selectedObjectVO ||
				( selectedObject && selectedObjectVO && selectedObject.id != selectedObjectVO.id ) )
			{
				var pageVO : PageVO; 
				if ( selectedObjectVO is PageVO )
					pageVO = selectedObjectVO as PageVO;
				else if ("pageVO" in selectedObjectVO )
					pageVO =  selectedObjectVO["pageVO"];
				
				if ( (!selectedPage && pageVO ) || ( selectedPage && pageVO && selectedPage.id != pageVO.id ) )
					sendNotification(SessionProxy.SET_SELECTED_PAGE, pageVO);
				
				sendNotification( SessionProxy.SET_SELECTED_OBJECT, selectedObjectVO );
			}
		}
	}
}
package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var selectedObject : ObjectVO = statesProxy.selectedObject;
			var selectedPage : PageVO = statesProxy.selectedPage;

			if ( selectedObject != selectedObjectVO ||
				( selectedObject && selectedObjectVO && selectedObject.id != selectedObjectVO.id ) )
			{
				var pageVO : PageVO; 
				if ( selectedObjectVO is PageVO )
					pageVO = selectedObjectVO as PageVO;
				else if ("pageVO" in selectedObjectVO )
					pageVO =  selectedObjectVO["pageVO"];
				
				if ( (!selectedPage && pageVO ) || ( selectedPage && pageVO && selectedPage.id != pageVO.id ) )
					sendNotification(StatesProxy.SET_SELECTED_PAGE, pageVO);
				
				sendNotification( StatesProxy.SET_SELECTED_OBJECT, selectedObjectVO );
			}
		}
	}
}
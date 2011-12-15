package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			var selectedObject : ObjectVO = sessionProxy.selectedObject;
			var selectedPage : PageVO = sessionProxy.selectedPage;
			
			/*if( sessionProxy.selectedObject && selectedObjectVO && sessionProxy.selectedObject.id == selectedObjectVO.id )
				return;
			
			if( sessionProxy.selectedObject && selectedObjectVO && sessionProxy.selectedPage.id == selectedObjectVO.id )
				return;
			
			sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, selectedObjectVO );*/

			if ( selectedObject != selectedObjectVO ||
				( selectedObject && selectedObjectVO && selectedObject.id != selectedObjectVO.id ) )
			{
				var pageVO : PageVO; 
				if ( selectedObjectVO is PageVO )
					pageVO = selectedObjectVO as PageVO;
				else if ("pageVO" in selectedObjectVO )
					pageVO =  selectedObjectVO["pageVO"];
				
				if ( (!selectedPage && pageVO ) || ( selectedPage && pageVO && selectedPage.id != pageVO.id ) )
					sendNotification(ApplicationFacade.SET_SELECTED_PAGE, pageVO);
				
				sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, selectedObjectVO );
			}
		}
	}
}
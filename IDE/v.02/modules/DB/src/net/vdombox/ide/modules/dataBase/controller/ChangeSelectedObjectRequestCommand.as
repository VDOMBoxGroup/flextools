package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.vo.ObjectVO;
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.common.model.vo.ResourceVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var objectVO : IVDOMObjectVO = notification.getBody() as IVDOMObjectVO; 
			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var selectedObject : ObjectVO = sessionProxy.selectedTable;
			var selectedPage : PageVO = sessionProxy.selectedBase;
			
			if ( selectedObject != objectVO ||
				( selectedObject && objectVO && selectedObject.id != objectVO.id ) )
			{
				var pageVO : PageVO; 
				if ( objectVO is PageVO )
					pageVO = objectVO as PageVO;
				else if ("pageVO" in objectVO )
					pageVO =  objectVO["pageVO"];
				
				if ( (!selectedPage && pageVO ) || ( selectedPage && pageVO && selectedPage.id != pageVO.id ) )
					sendNotification(ApplicationFacade.SET_SELECTED_PAGE, pageVO);
				
				sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, objectVO );
			}
		}
	}
}
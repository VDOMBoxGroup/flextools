package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			if( sessionProxy.selectedObject == selectedObjectVO )
				return;
			
			if( sessionProxy.selectedObject && selectedObjectVO && sessionProxy.selectedPage.id == selectedObjectVO.id )
				return;
				
			sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, selectedObjectVO );
		}
	}
}
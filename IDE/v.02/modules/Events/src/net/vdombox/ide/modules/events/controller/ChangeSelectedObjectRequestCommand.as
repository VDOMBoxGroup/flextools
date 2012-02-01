package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
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
				
			sendNotification( SessionProxy.SET_SELECTED_OBJECT, selectedObjectVO );
		}
	}
}
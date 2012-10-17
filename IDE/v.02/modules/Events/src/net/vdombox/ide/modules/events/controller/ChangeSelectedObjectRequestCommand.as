package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			if( statesProxy.selectedObject == selectedObjectVO )
				return;
			
			if( statesProxy.selectedObject && selectedObjectVO && statesProxy.selectedPage.id == selectedObjectVO.id )
				return;
				
			sendNotification( StatesProxy.SET_SELECTED_OBJECT, selectedObjectVO );
		}
	}
}
package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var selectedObjectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			var currentSelectedObjectVO : ObjectVO = statesObject[ ApplicationFacade.SELECTED_OBJECT ];
			
			if( selectedObjectVO != currentSelectedObjectVO )
			{
				sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, selectedObjectVO );
			}
		}
	}
}
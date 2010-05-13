package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetServerActionsRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var currentContainer : Object = sessionProxy.selectedObject;
			
			if( !currentContainer )
				currentContainer = sessionProxy.selectedPage;
			
			if( !currentContainer )
				currentContainer = sessionProxy.selectedApplication;
			
			if( !currentContainer )
				return;
			
			sendNotification( ApplicationFacade.GET_SERVER_ACTIONS, currentContainer );
		}
	}
}
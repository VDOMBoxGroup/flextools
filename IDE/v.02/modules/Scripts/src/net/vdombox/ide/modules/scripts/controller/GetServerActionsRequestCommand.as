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
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			var currentContainer : Object = statesObject[ ApplicationFacade.SELECTED_OBJECT ];
			
			if( !currentContainer )
				currentContainer = statesObject[ ApplicationFacade.SELECTED_PAGE ];
			
			if( !currentContainer )
				currentContainer = statesObject[ ApplicationFacade.SELECTED_APPLICATION ];
			
			if( !currentContainer )
				return;
			
			sendNotification( ApplicationFacade.GET_SERVER_ACTIONS, currentContainer );
		}
	}
}
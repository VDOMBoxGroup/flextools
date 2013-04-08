package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetServerActionsRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var currentContainer : Object = statesProxy.selectedObject;

			if ( !currentContainer )
				currentContainer = statesProxy.selectedPage;

			if ( !currentContainer )
				currentContainer = statesProxy.selectedApplication;

			if ( !currentContainer )
				return;

			sendNotification( Notifications.GET_SERVER_ACTIONS, currentContainer );
		}
	}
}

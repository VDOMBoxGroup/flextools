package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class UndoRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			if ( statesProxy.selectedApplication )
			{
				facade.sendNotification( Notifications.GET_PAGES, { applicationVO: statesProxy.selectedApplication } );
				facade.sendNotification( Notifications.GET_APPLICATION_STRUCTURE, { applicationVO: statesProxy.selectedApplication } );
			}
		}
	}
}

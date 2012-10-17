package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.modules.events.view.EventsJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class TearDownCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var eventsJunctionMediator : EventsJunctionMediator = facade.retrieveMediator( EventsJunctionMediator.NAME ) as EventsJunctionMediator;

			eventsJunctionMediator.tearDown();

			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
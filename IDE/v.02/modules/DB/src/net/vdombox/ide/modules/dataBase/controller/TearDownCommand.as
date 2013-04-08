package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.dataBase.view.DataBaseJunctionMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class TearDownCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourceBrowserJunctionMediator : DataBaseJunctionMediator = facade.retrieveMediator( DataBaseJunctionMediator.NAME ) as DataBaseJunctionMediator;

			resourceBrowserJunctionMediator.tearDown();

			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}

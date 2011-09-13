package net.vdombox.ide.modules.preview.controller
{
	import net.vdombox.ide.modules.preview.view.ScriptsJunctionMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class TearDownCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var scriptsJunctionMediator : ScriptsJunctionMediator = facade.retrieveMediator( ScriptsJunctionMediator.NAME ) as ScriptsJunctionMediator;

			scriptsJunctionMediator.tearDown();

			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
package net.vdombox.ide.modules.edition.controller
{
	import net.vdombox.ide.modules.edition.view.EditionJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var editionJunctionMediator:EditionJunctionMediator =
				facade.retrieveMediator( EditionJunctionMediator.NAME ) as EditionJunctionMediator;
			
			editionJunctionMediator.tearDown();
			
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
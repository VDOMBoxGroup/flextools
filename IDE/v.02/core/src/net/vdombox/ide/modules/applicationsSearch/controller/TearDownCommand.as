package net.vdombox.ide.modules.applicationsSearch.controller
{	
	import net.vdombox.ide.modules.applicationsSearch.view.ApplicationsSearchJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var applicationsSearchJunctionMediator:ApplicationsSearchJunctionMediator =
				facade.retrieveMediator( ApplicationsSearchJunctionMediator.NAME ) as ApplicationsSearchJunctionMediator;			
			applicationsSearchJunctionMediator.tearDown();
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
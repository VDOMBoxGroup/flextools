package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.applicationsManagment.view.ApplicationsManagmentJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var applicationsManagmentJunctionMediator:ApplicationsManagmentJunctionMediator =
				facade.retrieveMediator( ApplicationsManagmentJunctionMediator.NAME ) as ApplicationsManagmentJunctionMediator;
			
			applicationsManagmentJunctionMediator.tearDown();
			
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
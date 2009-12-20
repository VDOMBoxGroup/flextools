package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.modules.resourceBrowser.view.ResourceBrowserJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var resourceBrowserJunctionMediator:ResourceBrowserJunctionMediator =
				facade.retrieveMediator( ResourceBrowserJunctionMediator.NAME ) as ResourceBrowserJunctionMediator;
			
			resourceBrowserJunctionMediator.tearDown();
			
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
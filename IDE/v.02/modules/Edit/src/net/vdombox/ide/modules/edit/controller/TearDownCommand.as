package net.vdombox.ide.modules.edit.controller
{
	import net.vdombox.ide.modules.edit.view.EditJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var editJunctionMediator:EditJunctionMediator =
				facade.retrieveMediator( EditJunctionMediator.NAME ) as EditJunctionMediator;
			
			editJunctionMediator.tearDown();
			
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
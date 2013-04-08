package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class PipesReadyCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			sendNotification( ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE );
		}
	}
}
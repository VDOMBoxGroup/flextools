package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			sendNotification( ApplicationFacade.OPEN_INITIAL_WINDOW );
		}
	}
}
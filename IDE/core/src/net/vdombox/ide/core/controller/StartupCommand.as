package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.UpdateMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerMediator( new UpdateMediator() );

			sendNotification( ApplicationFacade.OPEN_INITIAL_WINDOW );
		}
	}
}

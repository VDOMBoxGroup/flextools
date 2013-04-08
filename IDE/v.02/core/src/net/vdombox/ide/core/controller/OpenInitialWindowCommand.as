package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.InitialWindowMediator;
	import net.vdombox.ide.core.view.components.InitialWindow;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenInitialWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_INITIAL_WINDOW );
			sendNotification( ApplicationFacade.CLOSE_MAIN_WINDOW );

			var initialWindowMediator : InitialWindowMediator = new InitialWindowMediator( new InitialWindow() );
			facade.registerMediator( initialWindowMediator );
			initialWindowMediator.openWindow();
		}
	}
}

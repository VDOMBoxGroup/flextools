package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.MainWindowMediator;
	import net.vdombox.ide.core.view.components.MainWindow;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenMainWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_INITIAL_WINDOW );
			sendNotification( ApplicationFacade.CLOSE_MAIN_WINDOW );
			
			var mainWindowMediator : MainWindowMediator;
			
			mainWindowMediator = new MainWindowMediator( new MainWindow() );
			facade.registerMediator( mainWindowMediator );
			mainWindowMediator.openWindow();
		}
	}
}
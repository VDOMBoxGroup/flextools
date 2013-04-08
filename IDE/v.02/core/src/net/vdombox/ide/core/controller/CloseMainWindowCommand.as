package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.view.MainWindowMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CloseMainWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			if ( facade.hasMediator( MainWindowMediator.NAME ) )
			{
				var mainWindowMediator : MainWindowMediator = facade.retrieveMediator( MainWindowMediator.NAME ) as MainWindowMediator;
				mainWindowMediator.closeWindow();
				facade.removeMediator( MainWindowMediator.NAME );
			}
		}
	}
}

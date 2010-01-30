package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.view.MainWindowMediator;
	import net.vdombox.ide.core.view.managers.PopUpWindowManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CloseWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
			
			var mainWindowMediator : MainWindowMediator = facade.retrieveMediator( MainWindowMediator.NAME ) as MainWindowMediator;
			
			popUpWindowManager.removePopUp( body );
		}
	}
}
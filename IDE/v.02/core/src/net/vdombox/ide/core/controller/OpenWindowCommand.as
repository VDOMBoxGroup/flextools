package net.vdombox.ide.core.controller
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.core.view.MainWindowMediator;
	import net.vdombox.ide.core.view.managers.PopUpWindowManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenWindowCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var content : UIComponent = body.content as UIComponent;
			var title : String = body.title as String;
			var isModal : Boolean = body.isModal as Boolean;
			
			var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();
			
			var mainWindowMediator : MainWindowMediator = facade.retrieveMediator( MainWindowMediator.NAME ) as MainWindowMediator;
			
			popUpWindowManager.addPopUp( content, title, mainWindowMediator.mainWindow, isModal );
		}
	}
}
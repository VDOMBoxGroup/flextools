package net.vdombox.ide.core.controller
{
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	
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
			
			var nativeWindowInitOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
			
			nativeWindowInitOptions.resizable = body.resizable;
			nativeWindowInitOptions.systemChrome = NativeWindowSystemChrome.NONE;
			nativeWindowInitOptions.transparent = true;
				
			popUpWindowManager.addPopUp( content, title, mainWindowMediator.mainWindow, isModal, null, nativeWindowInitOptions );
		}
	}
}
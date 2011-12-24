package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.AlertWindowEvent;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.model.ObjectProxy;
	import net.vdombox.ide.core.model.PageProxy;
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.TypesProxy;
	import net.vdombox.ide.core.view.components.AlertWindow;
	import net.vdombox.utils.WindowManager;
	import net.vdombox.view.Alert;
	import net.vdombox.view.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class AlertSystemCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			ApplicationProxy.errorWritten = true;
			PageProxy.errorWritten = true;
			ObjectProxy.errorWritten = true;
			GalleryProxy.errorWritten = true;
			ResourcesProxy.errorWritten = true;
			TypesProxy.errorWritten = true;
			
			
			var body : Object = notification.getBody();
			
			var label : String = body as String;
			
			var alertWindow : AlertWindow = new AlertWindow();
			alertWindow.addEventListener( AlertWindowEvent.OK, okHandler );
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.WRITE_ERROR:
				{
					alertWindow.content = label;
					alertWindow.title = "Error!";
					WindowManager.getInstance().addWindow(alertWindow, null, true);
					break;
				}
			}
			
			
			function okHandler( event : AlertWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( alertWindow );
			}
		}
	}
}
package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
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
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class AlertSystemCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var label : String = body as String;

			var alertWindow : AlertWindow = new AlertWindow();

			alertWindow.content = label;
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.WRITE_ERROR:
				{
					alertWindow.title = "Error!";
					alertWindow.state = "normal";
					break;
				}
					
				case ApplicationFacade.WRITE_QUESTION:
				{
					alertWindow.title = "Wanted!";
					alertWindow.state = "question";
					break;
				}
			}
			alertWindow.addEventListener( AlertWindowEvent.OK, okHandler );
			alertWindow.addEventListener( AlertWindowEvent.NO, noHandler );

			WindowManager.getInstance().addWindow(alertWindow, null, true);
			
			function okHandler( event : AlertWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( alertWindow );
				sendNotification( ApplicationFacade.ALERT_WINDOW_CLOSE, true );
			}
			
			function noHandler( event : AlertWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( alertWindow );
				if ( notification.getName() == ApplicationFacade.WRITE_QUESTION )
					sendNotification( ApplicationFacade.ALERT_WINDOW_CLOSE, false );
			}
		}
	}
}
package net.vdombox.ide.core.controller
{
	
	import flash.desktop.NativeApplication;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.view.ApplicationManagerWindowMediator;
	import net.vdombox.ide.core.view.ApplicationPropertiesViewMediator;
	import net.vdombox.ide.core.view.ApplicationsViewMediator;
	import net.vdombox.ide.core.view.MainWindowMediator;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	

	public class CloseApplicationManagerCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			if ( facade.hasMediator( ApplicationsViewMediator.NAME ) )
				facade.removeMediator( ApplicationsViewMediator.NAME );
			
			if ( facade.hasMediator( ApplicationPropertiesViewMediator.NAME ) )
				facade.removeMediator( ApplicationPropertiesViewMediator.NAME );
			
			if ( facade.hasProxy( GalleryProxy.NAME ) )
				facade.removeProxy( GalleryProxy.NAME );
			
			var windowManager : WindowManager = WindowManager.getInstance();

			if ( facade.hasMediator( ApplicationManagerWindowMediator.NAME ) )
			{				
				var applicationManagerWindowMediator : ApplicationManagerWindowMediator = facade.retrieveMediator( ApplicationManagerWindowMediator.NAME) as ApplicationManagerWindowMediator;
				
				facade.removeMediator( ApplicationManagerWindowMediator.NAME );
				windowManager.removeWindow(applicationManagerWindowMediator.applicationManagerWindow);
			}
			
			var logOff : Boolean = notification.getBody().logOff as Boolean;
			var close : Boolean = notification.getBody().close as Boolean;
		
			if ( !logOff )
			{
				if ( !close || facade.hasMediator( MainWindowMediator.NAME ) )
					sendNotification(ApplicationFacade.OPEN_MAIN_WINDOW);
				else
					NativeApplication.nativeApplication.exit();
			}
			else
			{
				if ( facade.hasMediator( MainWindowMediator.NAME ) )
					sendNotification( ApplicationFacade.SIGNOUT );
				else
					sendNotification( ApplicationFacade.REQUEST_FOR_SIGNOUT );
			}
			
			
		}
	}
}

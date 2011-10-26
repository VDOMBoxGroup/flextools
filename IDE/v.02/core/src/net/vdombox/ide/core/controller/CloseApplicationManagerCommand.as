package net.vdombox.ide.core.controller
{
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.view.ApplicationListItemRendererMediator;
	import net.vdombox.ide.core.view.ApplicationManagerWindowMediator;
	import net.vdombox.ide.core.view.ApplicationPropertiesViewMediator;
	import net.vdombox.ide.core.view.ApplicationsViewMediator;
	import net.vdombox.ide.core.view.ApplicationsIconViewMediator;
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
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
			
			if ( facade.hasMediator( ApplicationsIconViewMediator.NAME ) )
				facade.removeMediator( ApplicationsIconViewMediator.NAME );
			
			if ( facade.hasProxy( GalleryProxy.NAME ) )
				facade.removeProxy( GalleryProxy.NAME );
			
			var mainWindowSkin : MainWindowSkin = notification.getBody() as MainWindowSkin;
			var windowManager : WindowManager = WindowManager.getInstance();
//				.addWindow( applicationManagerWindow, mainWindowSkin, true );
			if ( facade.hasMediator( ApplicationManagerWindowMediator.NAME ) )
			{				
				var applicationManagerWindowMediator : ApplicationManagerWindowMediator = facade.retrieveMediator( ApplicationManagerWindowMediator.NAME) as ApplicationManagerWindowMediator;
				
				facade.removeMediator( ApplicationManagerWindowMediator.NAME );
				windowManager.removeWindow(applicationManagerWindowMediator.applicationManagerWindow);
			}
		
			sendNotification(ApplicationFacade.OPEN_MAIN_WINDOW);
			
		}
	}
}

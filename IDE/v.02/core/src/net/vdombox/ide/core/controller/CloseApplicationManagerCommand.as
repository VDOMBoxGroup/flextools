package net.vdombox.ide.core.controller
{
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.ApplicationListItemRendererMediator;
	import net.vdombox.ide.core.view.ApplicationManagerWindowMediator;
	import net.vdombox.ide.core.view.ChangeApplicationViewMediator;
	import net.vdombox.ide.core.view.CreateEditApplicationViewMediator;
	import net.vdombox.ide.core.view.IconChooserMediator;
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	

	public class CloseApplicationManagerCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			if ( facade.hasMediator( ChangeApplicationViewMediator.NAME ) )
				facade.removeMediator( ChangeApplicationViewMediator.NAME );
			
			
			if ( facade.hasMediator( CreateEditApplicationViewMediator.NAME ) )
				facade.removeMediator( CreateEditApplicationViewMediator.NAME );
			
			if ( facade.hasMediator( IconChooserMediator.NAME ) )
				facade.removeMediator( IconChooserMediator.NAME );
			
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

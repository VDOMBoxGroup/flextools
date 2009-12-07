package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.SettingsScreenMediator;
	import net.vdombox.ide.modules.applicationsManagment.view.components.SettingsScreen;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CreateSettingsScreenCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settings : SettingsScreen = new SettingsScreen();
			
			if( facade.hasMediator( SettingsScreenMediator.NAME ) )
				facade.removeMediator( SettingsScreenMediator.NAME );
			
			facade.registerMediator( new SettingsScreenMediator( settings ) )
			
			facade.sendNotification( ApplicationFacade.EXPORT_SETTINGS_SCREEN, settings );
		}
	}
}
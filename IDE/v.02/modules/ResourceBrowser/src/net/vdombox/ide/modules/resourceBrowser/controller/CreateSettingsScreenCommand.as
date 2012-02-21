package net.vdombox.ide.modules.resourceBrowser.controller
{
	import mx.controls.CheckBox;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.resourceBrowser.view.SettingsScreenMediator;
	import net.vdombox.ide.modules.resourceBrowser.view.components.SettingsScreen;
	
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
			
			facade.sendNotification( Notifications.EXPORT_SETTINGS_SCREEN, settings );
		}
	}
}
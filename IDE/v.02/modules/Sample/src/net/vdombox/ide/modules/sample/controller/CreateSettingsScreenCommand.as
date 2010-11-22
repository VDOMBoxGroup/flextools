/*Данная команда используется для создания панели свойств модуля (SettingsScreen) и ее посредника (SettingsScreenMediator), если
они не были созданы ранее, после чего посылается уведомление ApplicationFacade.EXPORT_SETTINGS_SCREEN*/
package net.vdombox.ide.modules.sample.controller
{
	import mx.controls.CheckBox;
	
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	import net.vdombox.ide.modules.sample.view.SettingsScreenMediator;
	import net.vdombox.ide.modules.sample.view.components.main.SettingsScreen;
	
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
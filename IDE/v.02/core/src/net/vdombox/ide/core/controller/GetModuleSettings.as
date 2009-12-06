package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetModuleSettings extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
			
			var settings : Object = settingsStorageProxy.loadSettings( notification.getBody().toString() );
			
			if( settings == "" )
			{
				var modulesProxy : ModulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
				var moduleVO : ModuleVO = modulesProxy.getModuleByID( notification.getBody().toString() );
				moduleVO.module.initializeSettings();
			}
		}
	}
}
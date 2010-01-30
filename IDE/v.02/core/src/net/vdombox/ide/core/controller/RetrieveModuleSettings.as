package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RetrieveModuleSettings extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
			var message : SimpleMessage = notification.getBody() as SimpleMessage;
			var moduleID : String = message.getRecipientKey();
			
			
			var settings : Object = settingsStorageProxy.loadSettings( moduleID );
			
			if( !settings )
			{
				var modulesProxy : ModulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
				var moduleVO : ModuleVO = modulesProxy.getModuleByID( moduleID );
				moduleVO.module.initializeSettings();
			}
			else
			{
				message.setBody( settings );
				message.setAnswerFlag( true );
				sendNotification( ApplicationFacade.MODULE_SETTINGS_GETTED, message );
			}
		}
	}
}
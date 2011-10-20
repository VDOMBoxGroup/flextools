package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class SetSelectedApplicationCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationVO : ApplicationVO;
			var body : ApplicationVO = notification.getBody() as ApplicationVO;
			
			applicationVO = body || lastOpenedApplication ||  firstOfListApplications;
			
			if( !applicationVO )
				return;
				
			statesProxy.selectedApplication = applicationVO;
			
			sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, statesProxy.selectedApplication );	
			
			settingsProxy.settings.lastApplicationID = applicationVO.id;
			
		}
		
		private function get lastOpenedApplication(): ApplicationVO
		{
			settingsProxy.importSettings( settings );
			
			var settingsVO : SettingsVO = settingsProxy.settings;
			
			if ( !settingsVO )
				return null;
			
			for each( var applicationVO : ApplicationVO in applications)
			{
				if ( applicationVO.id == settingsVO.lastApplicationID )
					return  applicationVO;
			}
			
			return null;
		}
		
		private function get firstOfListApplications():  ApplicationVO
		{
			return ( applications.length > 0 ) ? applications[0] : null;
		}
		
		private function get serverProxy():ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}
		
		private function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}
		
		private function get settingsProxy() : SettingsProxy
		{
			return facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
		}
		
		private function get settings() : Object
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
			return settingsStorageProxy.loadSettings( "applicationManagerWindow" );
		}
		
		private function get applications() : Array
		{
			return serverProxy.applications;
		}
	}
}
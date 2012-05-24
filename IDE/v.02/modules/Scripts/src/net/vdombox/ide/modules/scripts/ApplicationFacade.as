package net.vdombox.ide.modules.scripts
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.Scripts;
	import net.vdombox.ide.modules.scripts.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.scripts.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateScriptRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.scripts.controller.DeleteLibraryRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.GetResourceRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.GetScriptRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.SaveScriptRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.StartupCommand;
	import net.vdombox.ide.modules.scripts.controller.TearDownCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessTypesProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.settings.GetSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.settings.InitializeSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.settings.SaveSettingsToProxy;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{

		
		public static function getInstance( key : String ) : ApplicationFacade
		{
			if ( instanceMap[ key ] == null )
				instanceMap[ key ] = new ApplicationFacade( key );
			return instanceMap[ key ] as ApplicationFacade;
		}

		public function ApplicationFacade( key : String )
		{
			super( key );
		}
		
		public function startup( application : Scripts ) : void
		{
			sendNotification( Notifications.STARTUP, application );
		}
		
		override protected function initializeController( ) : void 
		{
			super.initializeController();
			registerCommand( Notifications.STARTUP, StartupCommand );
			
			registerCommand( Notifications.CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( Notifications.CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );
			registerCommand( Notifications.CREATE_BODY, CreateBodyCommand );
			
			registerCommand( SettingsProxy.INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( SettingsProxy.GET_SETTINGS, GetSettingsCommand );
			registerCommand( SettingsProxy.SET_SETTINGS, SetSettingsCommand );
			registerCommand( SettingsProxy.SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );
			
			registerCommand( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( Notifications.PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( Notifications.PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( Notifications.PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );
			
			registerCommand( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );
			
			registerCommand( Notifications.CREATE_SCRIPT_REQUEST, CreateScriptRequestCommand );
			
			registerCommand( Notifications.SAVE_SCRIPT_REQUEST, SaveScriptRequestCommand );
			
			registerCommand( Notifications.GET_SCRIPT_REQUEST, GetScriptRequestCommand );
			
			registerCommand( Notifications.DELETE_LIBRARY_REQUEST, DeleteLibraryRequestCommand );
			
			registerCommand( Notifications.BODY_CREATED, BodyCreatedCommand );
			
			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
			
			registerCommand( Notifications.GET_RESOURCE_REQUEST, GetResourceRequestCommand );
		}
	}
}
package net.vdombox.ide.modules.events
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.Events;
	import net.vdombox.ide.modules.events.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.events.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.events.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.events.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.events.controller.CreateScriptRequestCommand;
	import net.vdombox.ide.modules.events.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.events.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.events.controller.GetResourceRequestCommand;
	import net.vdombox.ide.modules.events.controller.GetServerActionsRequestCommand;
	import net.vdombox.ide.modules.events.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.events.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.events.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.events.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.events.controller.StartupCommand;
	import net.vdombox.ide.modules.events.controller.TearDownCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessTypesProxyMessageCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	/**
	 * 
	 * @author adelfos
	 * Notifications basic fasad 
	 * 
	 */
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

		public function startup( application : Events ) : void
		{
			sendNotification( Notifications.STARTUP, application );
		}

		override protected function initializeController() : void
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
			registerCommand( Notifications.PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( Notifications.PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( Notifications.PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );
			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );

			registerCommand( Notifications.BODY_CREATED, BodyCreatedCommand );

			registerCommand( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );

			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
			
			registerCommand( Notifications.GET_RESOURCE_REQUEST, GetResourceRequestCommand );
			
			registerCommand( Notifications.CREATE_SCRIPT_REQUEST, CreateScriptRequestCommand );
			
			registerCommand( Notifications.GET_SERVER_ACTIONS_REQUEST, GetServerActionsRequestCommand );
		}
	}
}
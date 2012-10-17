package net.vdombox.ide.modules.resourceBrowser
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.modules.ResourceBrowser;
	import net.vdombox.ide.modules.resourceBrowser.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.DeleteResourceRequestCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.ResourceDeletedCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.resourceBrowser.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.StartupCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.TearDownCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessResourcesProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	
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

		public function startup( application : ResourceBrowser ) : void
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
			registerCommand( Notifications.PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );

			registerCommand( StatesProxy.CHANGE_SELECTED_RESOURCE_REQUEST, ChangeSelectedObjectRequestCommand );
			registerCommand( Notifications.DELETE_RESOURCE_REQUEST, DeleteResourceRequestCommand )
			
			registerCommand( Notifications.RESOURCE_DELETED, ResourceDeletedCommand );
			
			registerCommand( Notifications.BODY_CREATED, BodyCreatedCommand );

			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
		}
	}
}
package net.vdombox.ide.modules.dataBase
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.DataBase;
	import net.vdombox.ide.modules.dataBase.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.dataBase.controller.ChangeSelectedDataBaseRequestCommand;
	import net.vdombox.ide.modules.dataBase.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.dataBase.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.dataBase.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.dataBase.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.dataBase.controller.GetResourceRequestCommand;
	import net.vdombox.ide.modules.dataBase.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.dataBase.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.dataBase.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.dataBase.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.dataBase.controller.StartupCommand;
	import net.vdombox.ide.modules.dataBase.controller.TearDownCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessTypesProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.model.StatesProxy;

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

		public function startup( application : DataBase ) : void
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

			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );


			registerCommand( Notifications.BODY_CREATED, BodyCreatedCommand );

			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
			registerCommand( Notifications.CHANGE_SELECTED_DATA_BASE_REQUEST, ChangeSelectedDataBaseRequestCommand );
			registerCommand( Notifications.GET_RESOURCE_REQUEST, GetResourceRequestCommand );

		}
	}
}

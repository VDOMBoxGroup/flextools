package net.vdombox.ide.modules.scripts
{
	import net.vdombox.ide.modules.Scripts;
	import net.vdombox.ide.modules.scripts.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.scripts.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.scripts.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.StartupCommand;
	import net.vdombox.ide.modules.scripts.controller.TearDownCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessServerProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.settings.GetSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.settings.InitializeSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.settings.SaveSettingsToProxy;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
//		main
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN : String = "createSettingsScreen";
		public static const CREATE_BODY : String = "createBody";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN : String = "exportSettingsScreen";
		public static const EXPORT_BODY : String = "exportBody";
		
//		selection
		public static const SELECT_MODULE : String = "selectModule";
		public static const MODULE_SELECTED : String = "moduleSelected";
		public static const MODULE_DESELECTED : String = "moduleDeselected";
		
		public static const PIPES_READY : String = "pipesReady";
		
//		tear down
		public static const TEAR_DOWN : String = "tearDown";
		
//		settings
		public static const INITIALIZE_SETTINGS : String = "initializeSettings";
		
		public static const GET_SETTINGS : String = "getSettings";
		public static const SET_SETTINGS : String = "setSettings";
		
		public static const SETTINGS_GETTED : String = "settingsGetted";
		public static const SETTINGS_CHANGED : String = "settingsChanged";
		
		public static const RETRIEVE_SETTINGS_FROM_STORAGE : String = "retrieveSettingsFromStorage";
		public static const SAVE_SETTINGS_TO_STORAGE : String = "saveSettingsToStorage";
		public static const SAVE_SETTINGS_TO_PROXY : String = "saveSettingsToProxy";
		
//		pipe messages
		public static const PROCESS_SERVER_PROXY_MESSAGE : String = "processServerProxyMessage";
		public static const PROCESS_STATES_PROXY_MESSAGE : String = "processStatesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		
//		server messages
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SELECTED_APPLICATION_GETTED : String = "selectedApplicationGetted";
		
//		other
		public static const DELIMITER : String = "/";
		public static const STATES : String = "states";
		
		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		
		public static const BODY_CREATED : String = "bodyCreated";
		
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		
		public static const PAGES_CHANGED : String = "pagesChanged";
		
		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		
		public static const GET_SELECTED_PAGE : String = "getSelectedPages";
		public static const SET_SELECTED_PAGE : String = "setSelectedPages";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPagesChanged";
		
		
		
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
			sendNotification( STARTUP, application );
		}
		
		override protected function initializeController( ) : void 
		{
			super.initializeController();
			registerCommand( STARTUP, StartupCommand );
			
			registerCommand( CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );
			registerCommand( CREATE_BODY, CreateBodyCommand );
			
			registerCommand( INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( GET_SETTINGS, GetSettingsCommand );
			registerCommand( SET_SETTINGS, SetSettingsCommand );
			registerCommand( SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );
			
			registerCommand( PROCESS_SERVER_PROXY_MESSAGE, ProcessServerProxyMessageCommand );
			registerCommand( PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			
			registerCommand( CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			
			registerCommand( BODY_CREATED, BodyCreatedCommand );
			
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}
package net.vdombox.ide.modules.scripts
{
	import net.vdombox.ide.modules.Scripts;
	import net.vdombox.ide.modules.scripts.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.scripts.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateNewActionRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateNewLibraryRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.scripts.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.scripts.controller.GetServerActionsRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.scripts.controller.StartupCommand;
	import net.vdombox.ide.modules.scripts.controller.TearDownCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessServerProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.scripts.controller.messages.ProcessTypesProxyMessageCommand;
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
		public static const PROCESS_TYPES_PROXY_MESSAGE : String = "processTypesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE : String = "processObjectProxyMessage";
		
//		server messages
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SELECTED_APPLICATION_GETTED : String = "selectedApplicationGetted";
		
//		types
		public static const GET_TYPES : String = "getTypes";
		public static const TYPES_GETTED : String = "typesGetted";
		
//		other
		public static const DELIMITER : String = "/";
		public static const STATES : String = "states";
		
		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		public static const SELECTED_OBJECT : String = "selectedObject";
		
		public static const BODY_CREATED : String = "bodyCreated";
		
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		
		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		public static const CHANGE_SELECTED_OBJECT_REQUEST : String = "changeSelectedObjectRequest";
		
		public static const GET_SELECTED_PAGE : String = "getSelectedPages";
		public static const SET_SELECTED_PAGE : String = "setSelectedPages";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPagesChanged";
		
		public static const GET_SELECTED_OBJECT : String = "getSelectedObject";
		public static const SET_SELECTED_OBJECT : String = "setSelectedObject";
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";
		
		public static const GET_OBJECTS : String = "getObjects";
		public static const OBJECTS_GETTED : String = "objectsGetted";
		
		public static const GET_STRUCTURE : String = "getStructure";
		public static const STRUCTURE_GETTED : String = "structureGetted";
		
		public static const GET_SERVER_ACTIONS_REQUEST : String = "getServerActionsRequest";
		public static const GET_SERVER_ACTIONS : String = "getServerActions";
		public static const SERVER_ACTIONS_GETTED : String = "serverActionsGetted";
		
		public static const GET_LIBRARIES : String = "getLibraries";
		public static const LIBRARIES_GETTED : String = "librariesGetted";
		
		public static const SELECTED_SERVER_ACTION_CHANGED : String = "selectedServerActionChanged";
		public static const SELECTED_LIBRARY_CHANGED : String = "selectedLibraryChanged";
		
		public static const CREATE_NEW_ACTION_REQUEST : String = "createNewActionRequest";
		public static const CREATE_NEW_LIBRARY_REQUEST : String = "createNewLibraryRequest";
		
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
			registerCommand( PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );
			
			registerCommand( CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );
			registerCommand( GET_SERVER_ACTIONS_REQUEST, GetServerActionsRequestCommand );
			
			registerCommand( CREATE_NEW_ACTION_REQUEST, CreateNewActionRequestCommand );
			registerCommand( CREATE_NEW_LIBRARY_REQUEST, CreateNewLibraryRequestCommand );
			
			registerCommand( BODY_CREATED, BodyCreatedCommand );
			
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}
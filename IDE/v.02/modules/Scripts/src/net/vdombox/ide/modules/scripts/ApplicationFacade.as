package net.vdombox.ide.modules.scripts
{
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
	import net.vdombox.ide.modules.scripts.controller.GetServerActionsRequestCommand;
	import net.vdombox.ide.modules.scripts.controller.OpenCreateActionWindowCommand;
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
		
//		pipe messages
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE : String = "processObjectProxyMessage";
		
//		other
		public static const DELIMITER : String = "/";
		
		public static const BODY_CREATED : String = "bodyCreated";
		public static const BODY_START : String = "bodyStart";
		public static const BODY_STOP : String = "bodyStop";
		
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		
		public static const GET_OBJECTS : String = "getObjects";
		public static const OBJECTS_GETTED : String = "objectsGetted";
		
		public static const GET_STRUCTURE : String = "getStructure";
		public static const STRUCTURE_GETTED : String = "structureGetted";
		
		public static const GET_GLOBAL_ACTIONS : String = "getGlobalActions";
		public static const GLOBAL_ACTIONS_GETTED : String = "globalActionsGetted";
		
		public static const GET_SERVER_ACTIONS_REQUEST : String = "getServerActionsRequest";
		public static const GET_SERVER_ACTIONS : String = "getServerActions";
		public static const SERVER_ACTIONS_GETTED : String = "serverActionsGetted";
		
		public static const SET_SERVER_ACTIONS : String = "setServerActions";
		public static const SERVER_ACTIONS_SETTED : String = "serverActionsSetted";
		
		public static const SET_SERVER_ACTION : String = "setServerAction";
		
		public static const GET_LIBRARIES : String = "getLibraries";
		public static const LIBRARIES_GETTED : String = "librariesGetted";
		
		public static const SELECTED_SERVER_ACTION_CHANGED : String = "selectedServerActionChanged";
		public static const SELECTED_LIBRARY_CHANGED : String = "selectedLibraryChanged";
		public static const SELECTED_GLOBAL_ACTION_CHANGED : String = "selectedGlobalActionChanged";
		
		public static const ACTION : String = "action";
		public static const LIBRARY : String = "library";
		
		public static const OPEN_CREATE_ACTION_WINDOW : String = "openCreateActionWindow";
		
		public static const CREATE_SCRIPT_REQUEST : String = "createScriptRequest";
		public static const SAVE_SCRIPT_REQUEST : String = "saveScriptRequest";
		
		public static const CREATE_LIBRARY : String = "createLibrary";
		public static const LIBRARY_CREATED : String = "libraryCreated";
		
		public static const SAVE_LIBRARY : String = "saveLibrary";
		public static const LIBRARY_SAVED : String = "librarySaved";
		
		public static const SAVE_GLOBAL_ACTION : String = "saveGlobalAction";
		public static const GLOBAL_ACTION_SAVED : String = "globalActionSaved";
		
		public static const DELETE_LIBRARY_REQUEST : String = "deleteLibraryRequest";
		
		public static const DELETE_LIBRARY : String = "deleteLibrary";
		public static const LIBRARY_DELETED : String = "libraryDeleted";
		
		public static const OPEN_WINDOW : String = "openWidow";
		public static const CLOSE_WINDOW : String = "closeWidow";
		
		public static const OPEN_ONLOAD_SCRIPT : String = "openOnloadScript";
		
		//		Resource
		public static const GET_RESOURCE_REQUEST 	: String = "getResourceRequest";
		public static const LOAD_RESOURCE 	: String = "loadResource";
		
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
			
			registerCommand( SettingsProxy.INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( SettingsProxy.GET_SETTINGS, GetSettingsCommand );
			registerCommand( SettingsProxy.SET_SETTINGS, SetSettingsCommand );
			registerCommand( SettingsProxy.SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );
			
			registerCommand( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );
			
			registerCommand( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );
			registerCommand( GET_SERVER_ACTIONS_REQUEST, GetServerActionsRequestCommand );
			
			registerCommand( OPEN_CREATE_ACTION_WINDOW, OpenCreateActionWindowCommand );
			
			registerCommand( CREATE_SCRIPT_REQUEST, CreateScriptRequestCommand );
			
			registerCommand( SAVE_SCRIPT_REQUEST, SaveScriptRequestCommand );
			
			registerCommand( DELETE_LIBRARY_REQUEST, DeleteLibraryRequestCommand );
			
			registerCommand( BODY_CREATED, BodyCreatedCommand );
			
			registerCommand( TEAR_DOWN, TearDownCommand );
			
			registerCommand( GET_RESOURCE_REQUEST, GetResourceRequestCommand );
		}
	}
}
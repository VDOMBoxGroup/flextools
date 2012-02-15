package net.vdombox.ide.modules.events
{
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
	 * ApplicationFacade basic fasad 
	 * 
	 */
	public class ApplicationFacade extends Facade implements IFacade
	{
//		main
		public static const STARTUP : String = "startup";

		public static const CREATE_TOOLSET 			: String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN 	: String = "createSettingsScreen";
		public static const CREATE_BODY 			: String = "createBody";

		public static const EXPORT_TOOLSET			: String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN	: String = "exportSettingsScreen";
		public static const EXPORT_BODY 			: String = "exportBody";

//		selection
		public static const SELECT_MODULE 	  : String = "selectModule";
		public static const MODULE_SELECTED   : String = "moduleSelected";
		public static const MODULE_DESELECTED : String = "moduleDeselected";

		public static const PIPES_READY : String = "pipesReady";

//		tear down
		public static const TEAR_DOWN : String = "tearDown";

//		pipe messages
		public static const PROCESS_RESOURCES_PROXY_MESSAGE 	: String = "processResourcesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE	: String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE 			: String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE 		: String = "processObjectProxyMessage";

//		pages
		public static const GET_PAGES 	 : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";

		public static const GET_PAGE_SRUCTURE 	  : String = "getPageStructure";
		public static const PAGE_STRUCTURE_GETTED : String = "pageStructureGetted";

//		objects
		public static const GET_OBJECT		: String = "getObject";
		public static const OBJECT_GETTED	: String = "objectGetted";

		public static const GET_OBJECTS 	: String = "getObjects";
		public static const OBJECTS_GETTED 	: String = "objectsGetted";
		
//		Resource
		public static const GET_RESOURCE_REQUEST 	: String = "getResourceRequest";
		public static const LOAD_RESOURCE 	: String = "loadResource";

//		other
		public static const DELIMITER	 : String = "/";

		public static const BODY_CREATED : String = "bodyCreated";
		public static const BODY_START	 : String = "bodyStart";
		public static const BODY_STOP 	 : String = "bodyStop";
		
		public static const GET_SERVER_ACTIONS_LIST 	: String = "getServerActionsList";
		public static const SERVER_ACTIONS_LIST_GETTED 	: String = "serverActionsListGetted";
		
		public static const GET_APPLICATION_EVENTS 		: String = "getApplicationEvents";
		public static const APPLICATION_EVENTS_GETTED 	: String = "applicationEventsGetted";
		
		public static const SET_APPLICATION_EVENTS 		: String = "setApplicationEvents";
		public static const APPLICATION_EVENTS_SETTED 	: String = "applicationEventsSetted";
		
		public static const GET_CHILDREN_ELEMENTS 	: String = "getChildrenElements";
		public static const CHILDREN_ELEMENTS_GETTED 	: String = "childrenElementsGetted";
		
		public static const STRUCTURE_GETTED 	: String = "structureGetted";
		
//ServerAction
		public static const ACTION : String = "action";
		
		public static const GET_SERVER_ACTIONS_REQUEST : String = "getServerActionsRequest";
		public static const GET_SERVER_ACTIONS : String = "getServerActions";
		public static const SERVER_ACTIONS_GETTED : String = "serverActionsGetted";
		
		public static const SET_SERVER_ACTIONS : String = "setServerActions";
		public static const SERVER_ACTIONS_SETTED : String = "serverActionsSetted";
		
		public static const CREATE_SCRIPT_REQUEST : String = "createScriptRequest";
		
		public static const CHECK_SAVE_IN_WORKAREA : String = "checkSaveInWorkArea";
		public static const SAVE_IN_WORKAREA_CHECKED : String = "saveInWorkAreaChecked";
		
		
// Undo
		public static const UNDO : String = "undo";
		public static const REDO : String = "redo";
		
		public static const SET_MESSAGE : String = "setMessage";
		
		public static const UNDO_REDO_GETTED : String = "undoRedoGetted";
		
		public static const SAVE_CHANGED : String = "saveChanged";
		
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
			sendNotification( STARTUP, application );
		}

		override protected function initializeController() : void
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
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );
			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );

			registerCommand( BODY_CREATED, BodyCreatedCommand );

			registerCommand( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );

			registerCommand( TEAR_DOWN, TearDownCommand );
			
			registerCommand( GET_RESOURCE_REQUEST, GetResourceRequestCommand );
			
			registerCommand( CREATE_SCRIPT_REQUEST, CreateScriptRequestCommand );
			
			registerCommand( GET_SERVER_ACTIONS_REQUEST, GetServerActionsRequestCommand );
		}
	}
}
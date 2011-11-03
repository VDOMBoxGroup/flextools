package net.vdombox.ide.modules.events
{
	import net.vdombox.ide.modules.Events;
	import net.vdombox.ide.modules.events.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.events.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.events.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.events.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.events.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.events.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.events.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.events.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.events.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.events.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.events.controller.StartupCommand;
	import net.vdombox.ide.modules.events.controller.TearDownCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessServerProxyMessageCommand;
	import net.vdombox.ide.modules.events.controller.messages.ProcessStatesProxyMessageCommand;
	
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

//		settings
		public static const INITIALIZE_SETTINGS : String = "initializeSettings";

		public static const GET_SETTINGS : String = "getSettings";
		public static const SET_SETTINGS : String = "setSettings";

		public static const SETTINGS_GETTED  : String = "settingsGetted";
		public static const SETTINGS_CHANGED : String = "settingsChanged";

		public static const RETRIEVE_SETTINGS_FROM_STORAGE 	: String = "retrieveSettingsFromStorage";
		public static const SAVE_SETTINGS_TO_STORAGE 		: String = "saveSettingsToStorage";
		public static const SAVE_SETTINGS_TO_PROXY 			: String = "saveSettingsToProxy";

//		pipe messages
		public static const PROCESS_SERVER_PROXY_MESSAGE 		: String = "processServerProxyMessage";
		public static const PROCESS_TYPES_PROXY_MESSAGE 		: String = "processTypesProxyMessage";
		public static const PROCESS_STATES_PROXY_MESSAGE 		: String = "processStatesProxyMessage";
		public static const PROCESS_RESOURCES_PROXY_MESSAGE 	: String = "processResourcesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE	: String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE 			: String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE 		: String = "processObjectProxyMessage";

//		states
		public static const GET_ALL_STATES 	  : String = "getAllStates";
		public static const ALL_STATES_GETTED : String = "allStatesGetted";

		public static const SET_ALL_STATES 	  : String = "setAllStates";
		public static const ALL_STATES_SETTED : String = "allStatesSetted";

		public static const GET_SELECTED_APPLICATION 	 : String = "getSelectedApplication";
		public static const SELECTED_APPLICATION_GETTED  : String = "selectedApplicationGetted";
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";

		public static const GET_SELECTED_PAGE 	  : String = "getSelectedPage";
		public static const SELECTED_PAGE_GETTED  : String = "selectedPageGetted";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";
		
		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		public static const SET_SELECTED_PAGE 	  : String = "setSelectedPage";
		public static const SELECTED_PAGE_SETTED  : String = "selectedPageSetted";

		public static const GET_SELECTED_OBJECT 	: String = "getSelectedObject";
		public static const SELECTED_OBJECT_GETTED 	: String = "selectedObjectGetted";
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";
		
		public static const CHANGE_SELECTED_OBJECT_REQUEST  : String = "changeSelectedObjectRequest";
		public static const SET_SELECTED_OBJECT 			: String = "setSelectedObject";
		public static const SELECTED_OBJECT_SETTED 			: String = "selectedObjectSetted";

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
		
		
		public static const SET_VISIBLE_ELEMENT_IN_OBJECT_TREE 	: String = "setVisibleElementInObjectTree";
		public static const SET_VISIBLE_ELEMENT_IN_PANEL 		: String = "setVisibleElementInPanel";
		public static const SET_VISIBLE_ELEMENT_WORK_AREA 		: String = "setVisibleElementInWorkArea";
		public static const SET_VISIBLE_ELEMENTS_FOR_OBJECT 	: String = "setVisibleElementsForObject";
		
		public static const GET_ELEMENTS_LIST_IN_WORK_AREA 		: String = "getElementsListInWorkArea";
		public static const ELEMENTS_LIST_IN_WORK_AREA_GETTED 	: String = "ElementsListInWorkAreaGetted";

		
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

			registerCommand( INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( GET_SETTINGS, GetSettingsCommand );
			registerCommand( SET_SETTINGS, SetSettingsCommand );
			registerCommand( SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );

			registerCommand( PROCESS_SERVER_PROXY_MESSAGE, ProcessServerProxyMessageCommand );
			registerCommand( PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );

			registerCommand( BODY_CREATED, BodyCreatedCommand );

			registerCommand( CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );

			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}
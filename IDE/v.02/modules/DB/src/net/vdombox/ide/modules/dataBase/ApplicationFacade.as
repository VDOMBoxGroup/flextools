package net.vdombox.ide.modules.dataBase
{
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.DataBase;
	import net.vdombox.ide.modules.dataBase.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.dataBase.controller.ChangeSelectedDataBaseRequestCommand;
	import net.vdombox.ide.modules.dataBase.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.dataBase.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.dataBase.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.dataBase.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.dataBase.controller.DeleteResourceRequestCommand;
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
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessServerProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.dataBase.controller.messages.ProcessTypesProxyMessageCommand;
	
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
		public static const PROCESS_RESOURCES_PROXY_MESSAGE : String = "processResourcesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE : String = "processObjectProxyMessage";

		//		states
		public static const GET_ALL_STATES : String = "getAllStates";
		public static const ALL_STATES_GETTED : String = "allStatesGetted";

		public static const SET_ALL_STATES : String = "setAllStates";
		public static const ALL_STATES_SETTED : String = "allStatesSetted";

		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SELECTED_APPLICATION_GETTED : String = "selectedApplicationGetted";
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";

		public static const GET_SELECTED_PAGE : String = "getSelectedPage";
		public static const SELECTED_PAGE_GETTED : String = "selectedPageGetted";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";

		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		public static const SET_SELECTED_PAGE : String = "setSelectedPage";
		public static const SELECTED_PAGE_SETTED : String = "selectedPageSetted";

		public static const GET_SELECTED_OBJECT : String = "getSelectedObject";
		public static const SELECTED_OBJECT_GETTED : String = "selectedObjectGetted";
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";

		public static const CHANGE_SELECTED_OBJECT_REQUEST : String = "changeSelectedObjectRequest";
		public static const SET_SELECTED_OBJECT : String = "setSelectedObject";
		public static const SELECTED_OBJECT_SETTED : String = "selectedObjectSetted";
		
		public static const CHANGE_SELECTED_RESOURCE_REQUEST : String = "changeSelectedResourceRequest";
		public static const SELECTED_RESOURCE_CHANGED : String = "selectedResourceChanged";

//		table panel
		public static const GET_DATA_BASES : String = "getDataBases";
		public static const DATA_BASES_GETTED : String = "dataBasesGetted";
		
		public static const GET_DATA_BASE_TABLES : String = "getDataBaseTables";
		public static const DATA_BASE_TABLES_GETTED : String = "dataBaseTablesGetted";
		
		public static const CHANGE_SELECTED_DATA_BASE_REQUEST : String = "changeSelectedDataBaseRequest";
		
		public static const GET_PAGE : String = "getPage";
		public static const PAGE_GETTED : String = "pageGetted";
		public static const GET_TABLE : String = "getTable";
		public static const TABLE_GETTED : String = "tableGetted";
		
		public static const GET_OBJECTS : String = "getObjects";
		public static const OBJECTS_GETTED : String = "objectsGetted";
		

		
		
//		other
		public static const DELIMITER : String = "/";

		public static const BODY_CREATED : String = "bodyCreated";
		public static const BODY_START : String = "bodyStart";
		public static const BODY_STOP : String = "bodyStop";
		
		public static const TABLE_CREATED : String = "tableCreated";
		
		
//		removecall
		
		public static const REMOTE_CALL_REQUEST : String = "removeCallRequest";
		public static const REMOTE_CALL_RESPONSE : String = "removeCallResponse";
		public static const REMOTE_CALL_RESPONSE_ERROR : String = "removeCallResponseError";
		
		public static const COMMIT_DATA_STRUCTURE : String = "commitDataStructure";
		public static const COMMIT_STRUCTURE : String = "commitStructure";
		
		public static const GET_TABLE_STRUCTURE : String = "getTableStructure";
		public static const TABLE_STRUCTURE_GETTED : String = "tableStructureGetted";
		
		
// add Bases and Tables
		public static const CREATE_PAGE : String = "createPage";
		public static const PAGE_CREATED : String = "pageCreate";
		
		public static const CREATE_OBJECT : String = "createObject";
		public static const OBJECT_CREATED : String = "objectCreated";
		
		public static const SET_OBJECT_NAME : String = "setObjectName";
		public static const OBJECT_NAME_SETTED : String = "objectNameSetted";
		public static const PAGE_NAME_SETTED : String = "pageNameSetted";
		
		public static const DELETE_OBJECT : String = "deleteObject";
		public static const OBJECT_DELETED : String = "objectDeleted";
		
// Resources
		public static const GET_RESOURCE_REQUEST 	: String = "getResourceRequest";
		public static const LOAD_RESOURCE 	: String = "loadResource";
		
// Attributes
		public static const GET_OBJECT_ATTRIBUTES 	: String = "getObjectAttributes";
		public static const OBJECT_ATTRIBUTES_GETTED 	: String = "objectAttributesGetted";
		public static const UPDATE_ATTRIBUTES 	: String = "updateAttributes";
		

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
			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );

			registerCommand( CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );
			
			
			registerCommand( BODY_CREATED, BodyCreatedCommand );

			registerCommand( TEAR_DOWN, TearDownCommand );
			registerCommand( CHANGE_SELECTED_DATA_BASE_REQUEST, ChangeSelectedDataBaseRequestCommand );
			registerCommand( GET_RESOURCE_REQUEST, GetResourceRequestCommand );
			
		}
	}
}
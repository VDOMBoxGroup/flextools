package net.vdombox.ide.modules.resourceBrowser
{
	import net.vdombox.ide.common.model.TypesProxy;
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
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessResourcesProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessServerProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.resourceBrowser.controller.messages.ProcessTypesProxyMessageCommand;
	
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

//		resources
		public static const GET_RESOURCES : String = "getResources";
		public static const RESOURCES_GETTED : String = "resourcesGetted";

		public static const LOAD_RESOURCE : String = "loadResource";
		public static const RESOURCE_LOADED : String = "resourceLoadded";

		public static const UPLOAD_RESOURCE : String = "uploadResources";
		public static const RESOURCE_UPLOADED : String = "resourceUploaded";

		public static const DELETE_RESOURCE_REQUEST : String = "deleteResourceRequest";
		public static const DELETE_RESOURCE : String = "deleteResource";
		public static const RESOURCE_DELETED : String = "resourceDeleted";
		
		//		icon
		public static const GET_ICON	: String = "getIcon";
		public static const ICON_GETTED : String = "iconGetted";

//		other
		public static const DELIMITER : String = "/";

		public static const BODY_CREATED : String = "bodyCreated";
		public static const BODY_START : String = "bodyStart";
		public static const BODY_STOP : String = "bodyStop";
		
		public static const WRITE_ERROR : String = "writeError";


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
			registerCommand( PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );
			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );

			registerCommand( CHANGE_SELECTED_RESOURCE_REQUEST, ChangeSelectedObjectRequestCommand );
			registerCommand( DELETE_RESOURCE_REQUEST, DeleteResourceRequestCommand )
			
			registerCommand( RESOURCE_DELETED, ResourceDeletedCommand );
			
			registerCommand( BODY_CREATED, BodyCreatedCommand );

			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}
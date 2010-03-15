package net.vdombox.ide.core
{
	import mx.rpc.events.FaultEvent;
	
	import net.vdombox.ide.core.controller.ApplicationLoadedCommand;
	import net.vdombox.ide.core.controller.ApplicationProxyRequestCommand;
	import net.vdombox.ide.core.controller.ApplicationProxyResponseCommand;
	import net.vdombox.ide.core.controller.CloseWindowCommand;
	import net.vdombox.ide.core.controller.ConnectServerCommand;
	import net.vdombox.ide.core.controller.ConnectionServerSuccessfulCommand;
	import net.vdombox.ide.core.controller.LoadModulesCommand;
	import net.vdombox.ide.core.controller.LogonSuccessfulCommand;
	import net.vdombox.ide.core.controller.ModuleLoadedCommand;
	import net.vdombox.ide.core.controller.ObjectProxyRequestCommand;
	import net.vdombox.ide.core.controller.ObjectProxyResponseCommand;
	import net.vdombox.ide.core.controller.OpenWindowCommand;
	import net.vdombox.ide.core.controller.PageProxyRequestCommand;
	import net.vdombox.ide.core.controller.PageProxyResponseCommand;
	import net.vdombox.ide.core.controller.PreinitalizeMacroCommand;
	import net.vdombox.ide.core.controller.ProcessLogMessage;
	import net.vdombox.ide.core.controller.ProcessSimpleMessageCommand;
	import net.vdombox.ide.core.controller.ProcessUIQueryMessageCommand;
	import net.vdombox.ide.core.controller.ResourcesProxyRequestCommand;
	import net.vdombox.ide.core.controller.ResourcesProxyResponseCommand;
	import net.vdombox.ide.core.controller.RetrieveModuleSettings;
	import net.vdombox.ide.core.controller.SaveModuleSettings;
	import net.vdombox.ide.core.controller.ServerProxyRequestCommand;
	import net.vdombox.ide.core.controller.ServerProxyResponseCommand;
	import net.vdombox.ide.core.controller.StatesProxyRequestCommand;
	import net.vdombox.ide.core.controller.TypesProxyRequestCommand;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const PREINITALIZE : String = "preinitalize";
		public static const STARTUP : String = "startup";
		public static const INITIAL_WINDOW_OPENED : String = "initialWindowOpened";
		public static const MAIN_WINDOW_OPENED : String = "mainWindowOpened";
		public static const SHOW_LOGON_VIEW : String = "showLoginView";
		public static const SHOW_ERROR_VIEW : String = "showErrorView";
		public static const CLOSE_SETTINGS_WINDOW : String = "closeSettingsWindow";
		public static const CHANGE_LOCALE : String = "changeLocale";
		public static const PROCESS_USER_INPUT : String = "processUserInput";
		public static const CONNECT_SERVER : String = "connectServer";
		public static const CONNECTION_SERVER_STARTS : String = "connectionServerStarts";
		public static const CONNECTION_SERVER_SUCCESSFUL : String = "connectionServerSuccessful";
		public static const CONNECTION_SERVER_ERROR : String = "connectionServerError";
		public static const LOGON_STARTS : String = "logonStarts";
		public static const LOGON_SUCCESS : String = "logonSuccess";
		public static const LOGON_ERROR : String = "logonError";

		public static const LOGOFF_STARTS : String = "logoffStarts";
		public static const LOGOFF_SUCCESS : String = "logoffSuccess";
		public static const LOGOFF_ERROR : String = "logoffError";
		public static const APPLICATIONS_LOADING : String = "applicationsLoading";
		public static const APPLICATIONS_LOADED : String = "applicationsLoaded";
		public static const APPLICATION_CREATED : String = "applicationCreated";
		public static const APPLICATION_CHANGED : String = "applicationChanged";
		public static const TYPES_LOADING : String = "typesLoading";
		public static const TYPES_LOADED : String = "typesLoaded";
		public static const CONNECT_MODULE_TO_CORE : String = "connectModuleToCore";

		public static const DISCONNECT_MODULE_TO_CORE : String = "disconnectModuleToCore";
		public static const CONNECT_MODULE_TO_PROXIES : String = "connectModuleToProxies";
		public static const MODULE_TO_PROXIES_CONNECTED : String = "moduleToProxiesСonnected";
		public static const DISCONNECT_MODULE_TO_PROXIES : String = "disconnectModuleToProxies";
		public static const MODULE_TO_PROXIES_DISCONNECTED : String = "moduleToProxiesDisconnected";

//		settings
		public static const RETRIEVE_MODULE_SETTINGS : String = "getModuleSettings";
		public static const MODULE_SETTINGS_GETTED : String = "moduleSettingsGetted";
		public static const SAVE_MODULE_SETTINGS : String = "setModuleSettings";
		public static const MODULE_SETTINGS_SETTED : String = "moduleSettingsSetted";

//		proxies		
		public static const RESOURCES_PROXY_REQUEST : String = "resourcesProxyRequest";
		public static const RESOURCES_PROXY_RESPONSE : String = "resourcesProxyResponse";
		public static const RESOURCES_GETTED : String = "resourcesGetted";
		public static const RESOURCE_LOADED : String = "resourceLoaded";
		public static const RESOURCE_SETTED : String = "resourceSetted";
		public static const RESOURCE_DELETED : String = "resourceDeleted";
		public static const RESOURCE_MODIFIED : String = "resourceModified";
		
		public static const SERVER_PROXY_REQUEST : String = "serverProxyRequest";
		public static const SERVER_PROXY_RESPONSE : String = "serverProxyResponse";
		public static const STATES_PROXY_REQUEST : String = "statesProxyRequest";
		public static const STATES_PROXY_RESPONSE : String = "statesProxyResponse";
		
		public static const TYPES_PROXY_REQUEST : String = "typesProxyRequest";
		public static const TYPES_PROXY_RESPONSE : String = "typesProxyResponse";
		
		public static const APPLICATION_PROXY_REQUEST : String = "applicationProxyRequest";
		public static const APPLICATION_PROXY_RESPONSE : String = "applicationProxyResponse";
		
		public static const PAGE_PROXY_REQUEST : String = "pageProxyRequest";
		public static const PAGE_PROXY_RESPONSE : String = "pageProxyResponse";
		
		public static const OBJECT_PROXY_REQUEST : String = "objectProxyRequest";
		public static const OBJECT_PROXY_RESPONSE : String = "objectProxyResponse";

//		modules
		public static const LOAD_MODULES : String = "loadModules";
		public static const MODULES_LOADED : String = "modulesLoaded";
		public static const LOAD_MODULE : String = "loadModule";
		public static const MODULE_LOADED : String = "moduleLoaded";
		public static const MODULE_READY : String = "moduleReady";
		public static const CHANGE_SELECTED_MODULE : String = "changeSelectedModule";
		public static const SELECTED_MODULE_CHANGED : String = "selectedModuleChanged";

//		simple messages
		public static const PROCESS_SIMPLE_MESSAGE : String = "processSimpleMessage";
		public static const PROCESS_UIQUERY_MESSAGE : String = "processUIQueryMessage";
		public static const PROCESS_LOG_MESSAGE : String = "processLogMessage";

//		pipes messages
		public static const SHOW_MODULE_TOOLSET : String = "showModuleToolset";
		public static const SHOW_MODULE_SETTINGS_SCREEN : String = "showModuleSettingsScreen";
		public static const SHOW_MODULE_BODY : String = "showModuleBody";

//		application
		public static const APPLICATION_STRUCTURE_GETTED : String = "applicationStructureGetted";
		public static const APPLICATION_STRUCTURE_SETTED : String = "applicationStructureSetted";
		
		public static const APPLICATION_PAGES_GETTED : String = "applicationPagesGetted";
		public static const APPLICATION_PAGE_CREATED : String = "applicationPageCreated";
		public static const APPLICATION_PAGE_DELETED : String = "applicationPageDeleted";
		public static const APPLICATION_REMOTE_CALL_GETTED : String = "applicationRemoteCallGetted";
		
		public static const APPLICATION_SERVER_ACTIONS_GETTED : String = "applicationServerActionsGetted";
		public static const APPLICATION_LIBRARIES_GETTED : String = "applicationLibrariesGetted";
		public static const APPLICATION_LIBRARY_CREATED : String = "applicationLibraryCreated";
		public static const APPLICATION_LIBRARY_DELETED : String = "applicationLibraryDeleted";
		
//		page		
		public static const PAGE_STRUCTURE_GETTED : String = "pageStructureGetted";
		public static const PAGE_ATTRIBUTES_GETTED : String = "pageAttributesGetted";
		public static const PAGE_ATTRIBUTES_SETTED : String = "pageAttributesSetted";
		public static const PAGE_OBJECTS_GETTED : String = "pageObjectsGetted";
		public static const PAGE_OBJECT_GETTED : String = "pageObjectGetted";
		public static const PAGE_OBJECT_CREATED : String = "pageObjectCreated";
		public static const PAGE_OBJECT_DELETED : String = "pageObjectDeleted";
		public static const PAGE_SERVER_ACTIONS_GETTED : String = "pageServerActionsGetted";
		public static const PAGE_SERVER_ACTIONS_SETTED : String = "pageServerActionsGetted";
		public static const PAGE_WYSIWYG_GETTED : String = "pageWYSIWYGGetted";

//		object
		public static const OBJECT_ATTRIBUTES_GETTED : String = "objectAttributesGetted";
		public static const OBJECT_ATTRIBUTES_SETTED : String = "objectAttributesSetted";
		public static const OBJECT_SERVER_ACTIONS_GETTED : String = "objectServerActionsGetted";
		public static const OBJECT_OBJECT_CREATED : String = "objectObjectCreated";
		public static const OBJECT_WYSIWYG_GETTED : String = "objectWYSIWYGGetted";

//		window
		public static const OPEN_WINDOW : String = "openWindow";

		public static const CLOSE_WINDOW : String = "closeWindow";

//		log
		public static const SEND_TO_LOG : String = "sendToLog";

		public static function getInstance( key : String ) : ApplicationFacade
		{
			if ( instanceMap[ key ] == null )
				instanceMap[ key ] = new ApplicationFacade( key );
			return instanceMap[ key ] as ApplicationFacade;
		}

		public function ApplicationFacade( key : String )
		{
			super( key );

			soap.addEventListener( FaultEvent.FAULT, soap_faultEvent );
		}

		private var soap : SOAP = SOAP.getInstance();

		public function preinitalize( application : VdomIDE ) : void
		{
			sendNotification( PREINITALIZE, application );
		}

		public function startup( application : VdomIDE ) : void
		{
			sendNotification( STARTUP, application );
		}

		override protected function initializeController() : void
		{
			super.initializeController();

			registerCommand( PREINITALIZE, PreinitalizeMacroCommand );

			registerCommand( CONNECT_SERVER, ConnectServerCommand );
			registerCommand( CONNECTION_SERVER_SUCCESSFUL, ConnectionServerSuccessfulCommand );
			registerCommand( LOGON_SUCCESS, LogonSuccessfulCommand );
			registerCommand( APPLICATIONS_LOADED, ApplicationLoadedCommand );

			registerCommand( LOAD_MODULES, LoadModulesCommand );
			registerCommand( MODULE_LOADED, ModuleLoadedCommand );

			registerCommand( RETRIEVE_MODULE_SETTINGS, RetrieveModuleSettings );
			registerCommand( SAVE_MODULE_SETTINGS, SaveModuleSettings );

			registerCommand( PROCESS_SIMPLE_MESSAGE, ProcessSimpleMessageCommand );
			registerCommand( PROCESS_UIQUERY_MESSAGE, ProcessUIQueryMessageCommand );
			registerCommand( PROCESS_LOG_MESSAGE, ProcessLogMessage );

			registerCommand( TYPES_PROXY_REQUEST, TypesProxyRequestCommand );

			registerCommand( SERVER_PROXY_REQUEST, ServerProxyRequestCommand );
			registerCommand( APPLICATION_CREATED, ServerProxyResponseCommand );

			registerCommand( STATES_PROXY_REQUEST, StatesProxyRequestCommand );

			registerCommand( APPLICATION_PROXY_REQUEST, ApplicationProxyRequestCommand );
			registerCommand( APPLICATION_CHANGED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_STRUCTURE_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_STRUCTURE_SETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_PAGES_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_PAGE_CREATED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_PAGE_DELETED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_SERVER_ACTIONS_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARIES_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARY_CREATED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARY_DELETED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_REMOTE_CALL_GETTED, ApplicationProxyResponseCommand );

			registerCommand( PAGE_PROXY_REQUEST, PageProxyRequestCommand );
			registerCommand( PAGE_STRUCTURE_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_ATTRIBUTES_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_ATTRIBUTES_SETTED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECTS_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECT_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECT_CREATED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECT_DELETED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTIONS_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTIONS_SETTED, PageProxyResponseCommand );
			registerCommand( PAGE_WYSIWYG_GETTED, PageProxyResponseCommand );

			registerCommand( OBJECT_PROXY_REQUEST, ObjectProxyRequestCommand );
			registerCommand( OBJECT_ATTRIBUTES_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_ATTRIBUTES_SETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTIONS_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_OBJECT_CREATED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_WYSIWYG_GETTED, ObjectProxyResponseCommand );

			registerCommand( RESOURCES_PROXY_REQUEST, ResourcesProxyRequestCommand );
			registerCommand( RESOURCES_GETTED, ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_LOADED, ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_SETTED, ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_DELETED, ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_MODIFIED, ResourcesProxyResponseCommand );

			registerCommand( OPEN_WINDOW, OpenWindowCommand );
			registerCommand( CLOSE_WINDOW, CloseWindowCommand );
		}

		private function soap_faultEvent( event : FaultEvent ) : void
		{
			sendNotification( SHOW_ERROR_VIEW, event.fault.faultDetail );
		}
	}
}
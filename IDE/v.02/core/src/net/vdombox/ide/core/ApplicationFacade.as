package net.vdombox.ide.core
{
	import net.vdombox.ide.core.controller.AlertSystemCommand;
	import net.vdombox.ide.core.controller.ChangeLocaleCommand;
	import net.vdombox.ide.core.controller.CheckIndexPageCommand;
	import net.vdombox.ide.core.controller.CheckSelectedPageCommand;
	import net.vdombox.ide.core.controller.CheckUpdateCommand;
	import net.vdombox.ide.core.controller.ClearProxiesStorageCommand;
	import net.vdombox.ide.core.controller.CloseApplicationManagerCommand;
	import net.vdombox.ide.core.controller.CloseIDECommand;
	import net.vdombox.ide.core.controller.CloseInitialWindowCommand;
	import net.vdombox.ide.core.controller.CloseMainWindowCommand;
	import net.vdombox.ide.core.controller.CreateApplicationCommand;
	import net.vdombox.ide.core.controller.CreateFirstPageCommand;
	import net.vdombox.ide.core.controller.DisconnectToServerCommand;
	import net.vdombox.ide.core.controller.EditApplicationInformationCommand;
	import net.vdombox.ide.core.controller.ErrorMacroCommand;
	import net.vdombox.ide.core.controller.GetApplicationListCommand;
	import net.vdombox.ide.core.controller.GetResourceItemRendererCommand;
	import net.vdombox.ide.core.controller.GetApplicationsHostsCommand;
	import net.vdombox.ide.core.controller.GetSelectedApplicationCommand;
	import net.vdombox.ide.core.controller.GetSettingsCommand;
	import net.vdombox.ide.core.controller.GetTypesCommand;
	import net.vdombox.ide.core.controller.InitialWindowCreatedCommand;
	import net.vdombox.ide.core.controller.LoadModulesRequestCommand;
	import net.vdombox.ide.core.controller.ModuleLoadingSuccessfulCommand;
	import net.vdombox.ide.core.controller.ModuleUnloadingStartCommand;
	import net.vdombox.ide.core.controller.OpenApplicationManagerCommand;
	import net.vdombox.ide.core.controller.OpenInitialWindowCommand;
	import net.vdombox.ide.core.controller.OpenMainWindowCommand;
	import net.vdombox.ide.core.controller.OpenPageInExternalBrowserCommand;
	import net.vdombox.ide.core.controller.PreinitalizeMacroCommand;
	import net.vdombox.ide.core.controller.ProcessLogMessage;
	import net.vdombox.ide.core.controller.ProcessSimpleMessageCommand;
	import net.vdombox.ide.core.controller.ProcessUIQueryMessageCommand;
	import net.vdombox.ide.core.controller.RequestForSignoutMacroCommand;
	import net.vdombox.ide.core.controller.RequestForSignupCommand;
	import net.vdombox.ide.core.controller.RetrievModuleSettingsCopy;
	import net.vdombox.ide.core.controller.RetrieveModuleSettings;
	import net.vdombox.ide.core.controller.SaveModuleSettings;
	import net.vdombox.ide.core.controller.SaveModuleSettingsCopy;
	import net.vdombox.ide.core.controller.ServerLoginSuccessfulCommand;
	import net.vdombox.ide.core.controller.SetIndexPageCommand;
	import net.vdombox.ide.core.controller.SetResourceIconCommand;
	import net.vdombox.ide.core.controller.SetSelectedApplicationCommand;
	import net.vdombox.ide.core.controller.SetSelectedPageCommand;
	import net.vdombox.ide.core.controller.SettingsChangedCommand;
	import net.vdombox.ide.core.controller.StartupCommand;
	import net.vdombox.ide.core.controller.requests.ApplicationProxyRequestCommand;
	import net.vdombox.ide.core.controller.requests.ObjectProxyRequestCommand;
	import net.vdombox.ide.core.controller.requests.PageProxyRequestCommand;
	import net.vdombox.ide.core.controller.requests.ResourcesProxyRequestCommand;
	import net.vdombox.ide.core.controller.requests.ServerProxyRequestCommand;
	import net.vdombox.ide.core.controller.requests.StatesProxyRequestCommand;
	import net.vdombox.ide.core.controller.requests.TypesProxyRequestCommand;
	import net.vdombox.ide.core.controller.responses.ApplicationProxyResponseCommand;
	import net.vdombox.ide.core.controller.responses.ObjectProxyResponseCommand;
	import net.vdombox.ide.core.controller.responses.PageProxyResponseCommand;
	import net.vdombox.ide.core.controller.responses.ResourcesProxyResponseCommand;
	import net.vdombox.ide.core.controller.responses.ServerProxyResponseCommand;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	
	
	

	/**
	 * @flowerModelElementId _DHYxQEomEeC-JfVEe_-0Aw
	 * 
	 * 
	 */
	public class ApplicationFacade extends Facade  implements IFacade  
	{
		/*
		@startuml 
		
		
		
		title Взаимодействие между Модулем (M) и Движком (C)
		box "in side Module"
		participant  WorkAreaMediator  
		participant  SaveRequestCommand 
		participant  TreeJunctionMediator  
		end box
		
		participant  Core <<(С, #ADDdB2) >>			
		
		
		WorkAreaMediator -> SaveRequestCommand  : sendNotification(..) 
		note over of SaveRequestCommand:  ApplicationFacade.\nSAVE_REQUEST
		
		SaveRequestCommand -> TreeJunctionMediator :  sendNotification(..) 
		note over of TreeJunctionMediator:  	 ApplicationFacade.\nSET_APPLICATION_STRUCTURE
		
		
		TreeJunctionMediator -> Core : 	junction.sendMessage(..)
		note over of Core:  	 PipeNames.PROXIESOUT,\n message
		
		Core --/  a : 	junction.sendMessage(..)
		
		@enduml
		*/
		public static const DELIMITER : String = "/";
		
		public static const PREINITALIZE : String = "preinitalize";
		public static const STARTUP : String = "startup";
		
		
		
		public static const REQUEST_FOR_SIGNUP : String = "requestForSignUp";
		public static const REQUEST_FOR_SIGNOUT : String = "requestForSignOut";
		
		public static const SIGNOUT : String = "signOut";
		
		public static const DISCONNECT_TO_SERVER : String = "disconnectToServer";
		public static const BACK_TO_INITIAL_WINDOW : String = "backToInitialWindow";
		
		public static const CHANGE_LOCALE : String = "changeLocale";

		
//		windows and views
		
		public static const CLOSE_IDE : String = "closeIDE";
		
		public static const INITIAL_WINDOW_CREATED : String = "initialWindowCreated";
		
		
		public static const OPEN_INITIAL_WINDOW : String = "openInitialWindow";
		public static const INITIAL_WINDOW_OPENED : String = "initialWindowOpened";
		
		public static const CLOSE_INITIAL_WINDOW : String = "closeInitialWindow";
		public static const INITIAL_WINDOW_CLOSED : String = "initialWindowClosed";
		
		public static const OPEN_MAIN_WINDOW : String = "openMainWindow";
		public static const MAIN_WINDOW_OPENED : String = "mainWindowOpened";
		
		public static const CLOSE_MAIN_WINDOW : String = "closeMainWindow";
		public static const MAIN_WINDOW_CLOSED : String = "mainWindowClosed";
		
		public static const SHOW_LOGIN_VIEW_REQUEST : String = "showLoginViewRequest";
		
		public static const SUBMIN_CLICK : String = "submitClick";
//		*****
		public static const CONNECT_MODULE_TO_CORE : String = "connectModuleToCore";
		public static const DISCONNECT_MODULE_TO_CORE : String = "disconnectModuleToCore";
		
		public static const CONNECT_MODULE_TO_PROXIES : String = "connectModuleToProxies";
		public static const MODULE_TO_PROXIES_CONNECTED : String = "moduleToProxiesСonnected";
		
		public static const DISCONNECT_MODULE_TO_PROXIES : String = "disconnectModuleToProxies";
		public static const MODULE_TO_PROXIES_DISCONNECTED : String = "moduleToProxiesDisconnected";
		
//		simple messages
		public static const PROCESS_SIMPLE_MESSAGE : String = "processSimpleMessage";
		public static const PROCESS_UIQUERY_MESSAGE : String = "processUIQueryMessage";
		public static const PROCESS_LOG_MESSAGE : String = "processLogMessage";
		
//		pipes messages
		public static const SHOW_MODULE_TOOLSET : String = "showModuleToolset";
		public static const SHOW_MODULE_SETTINGS_SCREEN : String = "showModuleSettingsScreen";
		public static const SHOW_MODULE_BODY : String = "showModuleBody";
		
//		proxies		
		public static const RESOURCES_PROXY_REQUEST : String = "resourcesProxyRequest";
		public static const RESOURCES_PROXY_RESPONSE : String = "resourcesProxyResponse";
		
		public static const SERVER_PROXY_REQUEST : String = "serverProxyRequest";
		public static const SERVER_PROXY_RESPONSE : String = "serverProxyResponse";
		
		public static const STATES_PROXY_REQUEST : String = "statesProxyRequest";
		public static const STATES_PROXY_RESPONSE : String = "statesProxyResponse";
		
		public static const APPLICATION_PROXY_REQUEST : String = "applicationProxyRequest";
		public static const APPLICATION_PROXY_RESPONSE : String = "applicationProxyResponse";
		
		public static const PAGE_PROXY_REQUEST : String = "pageProxyRequest";
		public static const PAGE_PROXY_RESPONSE : String = "pageProxyResponse";
		
		public static const OBJECT_PROXY_REQUEST : String = "objectProxyRequest";
		public static const OBJECT_PROXY_RESPONSE : String = "objectProxyResponse";

//		modules
		public static const LOAD_MODULES_REQUEST : String = "loadModulesRequest";
		
		public static const MODULES_LOADING_START : String = "modulesLoadingStart";
		public static const MODULES_LOADING_SUCCESSFUL : String = "modulesLoadingSuccessful";
		public static const MODULES_LOADING_ERROR : String = "modulesLoadingError";
		
		public static const MODULES_UNLOADING_START : String = "modulesUnloadingStart";
		
		public static const MODULE_LOADING_START : String = "moduleLoadingStart";
		public static const MODULE_LOADING_SUCCESSFUL : String = "moduleLoadingSuccessful";
		public static const MODULE_LOADING_ERROR : String = "moduleLoadingError";
		
		
//		public static const MODULES_LOADED : String = "modulesLoaded";
		
		
		
//		public static const MODULE_READY : String = "moduleReady";
		
		public static const CHANGE_SELECTED_MODULE : String = "changeSelectedModule";
		public static const SELECTED_MODULE_CHANGED : String = "selectedModuleChanged";

//		settings
		public static const RETRIEVE_MODULE_SETTINGS : String = "getModuleSettings";
		public static const MODULE_SETTINGS_GETTED : String = "moduleSettingsGetted";
		
		public static const SAVE_MODULE_SETTINGS : String = "setModuleSettings";
		public static const SAVE_MODULE_SETTINGS2 : String = "setModuleSettings2";
		public static const MODULE_SETTINGS_SETTED : String = "moduleSettingsSetted";
		
		public static const GET_SETTINGS : String = "getSettings";
		public static const GET_SETTINGS_MANAGER : String = "settingsGettedManager";
		public static const SETTINGS_GETTED : String = "settingsGetted";
		
		public static const SETTINGS_CHANGED : String = "settingsChanged";
		public static const SETTINGS_SETTED : String = "settingsSetted";
		
		public static const MANAGER_SETTINGS_GETTED : String = "managerSettingsSetted";
		
//		server
		public static const SERVER_CONNECTION_START : String = "serverСonnectionStart";
		public static const SERVER_CONNECTION_SUCCESSFUL : String = "serverСonnectionSuccessful";
		public static const SERVER_CONNECTION_ERROR : String = "serverСonnectionError";
		
		public static const SERVER_ERROR : String = "serverError";
		
		public static const SERVER_LOGIN_START : String = "serverLoginStarts";
		public static const SERVER_LOGIN_SUCCESSFUL : String = "serverLoginSuccessful";
		public static const SERVER_LOGIN_ERROR : String = "serverLoginError";
		
		public static const CREATE_APPLICATION : String = "createApplication";
		public static const SERVER_APPLICATION_CREATED : String = "serverApplicationCreated";
		public static const SERVER_APPLICATIONS_GETTED : String = "serverApplicationsGetted";
		
//		resources
		public static const LOAD_RESOURCE : String = "loadResource";
		public static const CHANGE_RESOURCE : String = "changeResource";
		
		public static const RESOURCES_GETTED : String = "resourcesGetted";
		
		public static const RESOURCE_LOADED : String = "resourceLoaded";
		public static const RESOURCE_SETTED : String = "resourceSetted";
		public static const RESOURCE_SETTED_ERROR : String = "resourceSettedError";
		public static const RESOURCE_DELETED : String = "resourceDeleted";
		public static const RESOURCE_MODIFIED : String = "resourceModified";
		
		public static const SET_RESOURCE : String = "setResource";
		
//		icon of resources
		public static const GET_ICON	: String = "getIcon";		
		public static const ICON_GETTED : String = "iconGetted";
		
//		application
		public static const APPLICATION_INFORMATION_UPDATED : String = "applicationInfrmationUpdated";
		
		public static const APPLICATION_STRUCTURE_GETTED : String = "applicationStructureGetted";
		public static const APPLICATION_STRUCTURE_SETTED : String = "applicationStructureSetted";
		
		public static const APPLICATION_PAGES_GETTED : String = "applicationPagesGetted";
		public static const APPLICATION_PAGE_GETTED : String = "applicationPageGetted";
		
		public static const APPLICATION_PAGE_CREATED : String = "applicationPageCreated";
		public static const APPLICATION_PAGE_DELETED : String = "applicationPageDeleted";
		
		public static const APPLICATION_REMOTE_CALL_GETTED : String = "applicationRemoteCallGetted";
		public static const APPLICATION_REMOTE_CALL_ERROR_GETTED : String = "applicationRemoteCallErrorGetted";
		
		public static const APPLICATION_SERVER_ACTIONS_LIST_GETTED : String = "applicationServerActionsGetted";
		public static const APPLICATION_SERVER_ACTIONS_LIST_GETTED_FOR_FIND : String = "applicationServerActionsGettedForFind";
		public static const APPLICATION_SERVER_ACTION_GETTED : String = "applicationServerActionGetted";
		
		public static const APPLICATION_LIBRARIES_GETTED : String = "applicationLibrariesGetted";
		public static const APPLICATION_LIBRARIES_GETTED_FOR_FIND : String = "applicationLibrariesGettedForFind";
		
		public static const APPLICATION_LIBRARY_CREATED : String = "applicationLibraryCreated";
		public static const APPLICATION_LIBRARY_UPDATED : String = "applicationLibraryUpdated";
		public static const APPLICATION_LIBRARY_GETTED : String = "applicationLibraryGetted";
		public static const APPLICATION_LIBRARY_DELETED : String = "applicationLibraryDeleted";
		
		public static const APPLICATION_EVENTS_GETTED : String = "applicationEventsGetted";
		public static const APPLICATION_EVENTS_SETTED : String = "applicationEventsSetted";
		
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SET_SELECTED_APPLICATION : String = "setSelectedApplication";
		
		public static const CLEAR_PROXY_STORAGE : String = "clearProxyStorage";
		
		public static const EDIT_APPLICATION_INFORMATION : String = "editApplicationInformation";
		
		public static const APPLICATION_COPY_CREATED  : String = "applicationCopyCreated";
		
//		page		
		public static const PAGE_STRUCTURE_GETTED : String = "pageStructureGetted";
		public static const PAGE_STRUCTURE_FOR_FIND_GETTED : String = "pageStructureForFindGetted";
		
		public static const PAGE_ATTRIBUTES_GETTED : String = "pageAttributesGetted";
		public static const PAGE_ATTRIBUTES_SETTED : String = "pageAttributesSetted";
		
		public static const PAGE_OBJECTS_GETTED : String = "pageObjectsGetted";
		
		public static const PAGE_OBJECT_GETTED : String = "pageObjectGetted";
		public static const PAGE_OBJECT_CREATED : String = "pageObjectCreated";
		public static const PAGE_OBJECT_DELETED : String = "pageObjectDeleted";
		
		public static const PAGE_CHECK_SELECTED			: String = "pageCheckSelected";
		public static const PAGE_SET_SELECTED 			: String = "pageSetSelected";
		
		public static const PAGE_CHECK_INDEX			: String = "pageCheckIndex";
		public static const PAGE_SET_AS_INDEX 			: String = "pageSetAsIndex";
		
		public static const PAGE_SERVER_ACTIONS_LIST_GETTED : String = "pageServerActionsListGetted";
		public static const PAGE_SERVER_ACTIONS_GETTED : String = "pageServerActionsGetted";
		public static const PAGE_ALL_SERVER_ACTIONS_GETTED : String = "pageAllServerActionsGetted";
		
		public static const PAGE_SERVER_ACTION_GETTED : String = "pageServerActionGetted";
		public static const PAGE_SERVER_ACTION_SETTED : String = "pageServerActionSetted";
		public static const PAGE_SERVER_ACTION_CREATED : String = "pageServerActionCreated";
		public static const PAGE_SERVER_ACTION_RENAMED : String = "pageServerActionRenamed";
		public static const PAGE_SERVER_ACTION_DELETED : String = "pageServerActionDeleted";
		
		public static const PAGE_WYSIWYG_GETTED : String = "pageWYSIWYGGetted";
		
		public static const PAGE_XML_PRESENTATION_GETTED : String = "pageXMLPresentationGetted";
		public static const PAGE_XML_PRESENTATION_SETTED : String = "pageXMLPresentationSetted";
		
		public static const PAGE_NAME_SETTED : String = "pageNameSetted";
		public static const CREATE_FIRST_PAGE : String = "createFirstPage";
		
		public static const PAGE_COPY_CREATED  : String = "pageCopyCreated";
		
		public static const PAGE_REMOTE_CALL_GETTED : String = "pageRemoteCallGetted";
		public static const PAGE_REMOTE_CALL_ERROR_GETTED : String = "pageRemoteCallErrorGetted";
		
//		object
		public static const OBJECT_ATTRIBUTES_GETTED : String = "objectAttributesGetted";
		public static const OBJECT_ATTRIBUTES_SETTED : String = "objectAttributesSetted";
		
		public static const OBJECT_SERVER_ACTIONS_LIST_GETTED : String = "objectServerActionsListGetted";
		public static const OBJECT_SERVER_ACTIONS_GETTED : String = "objectServerActionsGetted";
		public static const OBJECT_ALL_SERVER_ACTIONS_GETTED : String = "objectAllServerActionsGetted";
			
		public static const OBJECT_SERVER_ACTION_GETTED : String = "objectServerActionGetted";
		public static const OBJECT_SERVER_ACTION_SETTED : String = "objectServerActionSetted";
		public static const OBJECT_SERVER_ACTION_CREATED : String = "objectServerActionCreated";
		public static const OBJECT_SERVER_ACTION_RENAMED : String = "objectServerActionRenamed";
		public static const OBJECT_SERVER_ACTION_DELETED : String = "objectServerActionDeleted";
		
		public static const OBJECT_OBJECT_CREATED : String = "objectObjectCreated";
		
		public static const OBJECT_WYSIWYG_GETTED : String = "objectWYSIWYGGetted";
		
		public static const OBJECT_XML_PRESENTATION_GETTED : String = "objectXMLPresentationGetted";
		public static const OBJECT_XML_PRESENTATION_SETTED : String = "objectXMLPresentationSetted";
		
		public static const OBJECT_NAME_SETTED : String = "objectNameSetted";
		
		public static const OPEN_PAGE_IN_EXTERNAL_BROWSER  : String = "openPageInExternalBrowser";
//		public static const OPEN_APPLICATION_IN_EDITOR  : String = "openApplicationInEditor";
		public static const OPEN_APPLICATION_PROPERTY_VIEW  : String = "openApplicationPropertyView";
		public static const OPEN_APPLICATIONS_VIEW  : String = "openApplicationsView";
//		public static const OPEN_APPLICATION_IN_CHANGE_VIEW  : String = "openApplicationInChangeView";
		
		public static const OBJECT_COPY_CREATED  : String = "objectCopyCreated";
		public static const OBJECT_REMOTE_CALL_GETTED : String = "objectRemoteCallGetted";
		public static const OBJECT_REMOTE_CALL_ERROR_GETTED : String = "objectRemoteCallErrorGetted";
		
		public static const GET_APPLICATIONS_HOSTS  : String = "getSelectedApp";
		public static const SELECTED_APP_GETTED  : String = "selectedAppGetted";
		
		
		

//		log
		public static const SEND_TO_LOG : String = "sendToLog";
		
//		update
		
		public static const CHECK_UPDATE : String = "checkUpdate";
		
//		applicationManager
		
		public static const OPEN_APPLICATION_MANAGER : String = "openApplicationManager";
		public static const CLOSE_APPLICATION_MANAGER : String = "closeApplicationManager";
		public static const GET_APPLICATIONS_LIST : String = "getApplicationList";
		
//		errors
		
		public static const WRITE_ERROR : String = "writeError";
		public static const WRITE_QUESTION : String = "writeQuestion";
		
		public static const APPLICATION_CHECK_SAVED : String = "applicationCheckSaved";
		public static const APPLICATION_SAVE_CHECKED : String = "applicationSaveChecked";
		
		public static const APPLICATION_SET_SAVE : String = "applicationSetSave";
		
		public static const ALERT_WINDOW_CLOSE : String = "alertWindowClose";
		
		public static const ERROR_TO_PASTE : String = "errorToPaste";
		

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

//			core
			
			registerCommand( CLOSE_IDE, CloseIDECommand ); 
			registerCommand( PREINITALIZE, PreinitalizeMacroCommand );
			registerCommand( STARTUP, StartupCommand );
			
			registerCommand( DISCONNECT_TO_SERVER, DisconnectToServerCommand );

			registerCommand( INITIAL_WINDOW_CREATED, InitialWindowCreatedCommand );

			registerCommand( OPEN_MAIN_WINDOW, OpenMainWindowCommand );
			registerCommand( OPEN_INITIAL_WINDOW, OpenInitialWindowCommand );
			
			registerCommand( CLOSE_MAIN_WINDOW, CloseMainWindowCommand );
			registerCommand( CLOSE_INITIAL_WINDOW, CloseInitialWindowCommand );
			
			registerCommand( REQUEST_FOR_SIGNUP, RequestForSignupCommand );
			registerCommand( REQUEST_FOR_SIGNOUT, RequestForSignoutMacroCommand );
			
			registerCommand( SERVER_LOGIN_SUCCESSFUL, ServerLoginSuccessfulCommand );
			
			registerCommand( CHANGE_LOCALE, ChangeLocaleCommand );
			
			                       
			
//			registerCommand( CONNECT_SERVER, ConnectServerCommand );
//			registerCommand( CONNECTION_SERVER_SUCCESSFUL, ConnectionServerSuccessfulCommand );
//			registerCommand( LOGON_SUCCESS, LogonSuccessfulCommand );

			registerCommand( LOAD_MODULES_REQUEST, LoadModulesRequestCommand );
			registerCommand( MODULE_LOADING_SUCCESSFUL, ModuleLoadingSuccessfulCommand );

			registerCommand( MODULES_UNLOADING_START, ModuleUnloadingStartCommand );
			
//			message requests & responses
			registerCommand( RETRIEVE_MODULE_SETTINGS, RetrieveModuleSettings );
			registerCommand( SAVE_MODULE_SETTINGS, SaveModuleSettings );
			registerCommand( SAVE_MODULE_SETTINGS2, SaveModuleSettingsCopy );

			registerCommand( PROCESS_SIMPLE_MESSAGE, ProcessSimpleMessageCommand );
			registerCommand( PROCESS_UIQUERY_MESSAGE, ProcessUIQueryMessageCommand );
			registerCommand( PROCESS_LOG_MESSAGE, ProcessLogMessage );

			registerCommand( TypesProxy.TYPES_PROXY_REQUEST, TypesProxyRequestCommand );

			registerCommand( SERVER_PROXY_REQUEST, ServerProxyRequestCommand );
			registerCommand( SERVER_APPLICATION_CREATED, ServerProxyResponseCommand );
			registerCommand( SERVER_APPLICATIONS_GETTED, ServerProxyResponseCommand );
			registerCommand( SELECTED_APP_GETTED, ServerProxyResponseCommand );

			registerCommand( STATES_PROXY_REQUEST, StatesProxyRequestCommand );

			registerCommand( APPLICATION_PROXY_REQUEST, ApplicationProxyRequestCommand );
			registerCommand( APPLICATION_INFORMATION_UPDATED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_STRUCTURE_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_STRUCTURE_SETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_PAGES_GETTED, ApplicationProxyResponseCommand );		
			registerCommand( APPLICATION_PAGE_GETTED, ApplicationProxyResponseCommand );	
			registerCommand( APPLICATION_PAGE_CREATED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_PAGE_DELETED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_SERVER_ACTIONS_LIST_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_SERVER_ACTIONS_LIST_GETTED_FOR_FIND, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_SERVER_ACTION_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARIES_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARIES_GETTED_FOR_FIND, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARY_CREATED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARY_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_LIBRARY_DELETED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_EVENTS_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_EVENTS_SETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_REMOTE_CALL_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_REMOTE_CALL_ERROR_GETTED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_COPY_CREATED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_CHECK_SAVED, ApplicationProxyResponseCommand );
			registerCommand( APPLICATION_SET_SAVE, ApplicationProxyResponseCommand );
			registerCommand( ERROR_TO_PASTE, ApplicationProxyResponseCommand );
			

			registerCommand( PAGE_PROXY_REQUEST, PageProxyRequestCommand );
			
			registerCommand( PAGE_CHECK_SELECTED, CheckSelectedPageCommand );
			registerCommand( PAGE_SET_SELECTED, SetSelectedPageCommand );
			
			registerCommand( PAGE_CHECK_INDEX, CheckIndexPageCommand );
			registerCommand( PAGE_SET_AS_INDEX, SetIndexPageCommand );
			
			registerCommand( PAGE_STRUCTURE_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_STRUCTURE_FOR_FIND_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_ATTRIBUTES_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_ATTRIBUTES_SETTED, PageProxyResponseCommand );
			registerCommand( PAGE_NAME_SETTED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECTS_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECT_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECT_CREATED, PageProxyResponseCommand );
			registerCommand( PAGE_OBJECT_DELETED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTIONS_LIST_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTIONS_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_ALL_SERVER_ACTIONS_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTION_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTION_SETTED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTION_CREATED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTION_RENAMED, PageProxyResponseCommand );
			registerCommand( PAGE_SERVER_ACTION_DELETED, PageProxyResponseCommand );
			registerCommand( PAGE_WYSIWYG_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_XML_PRESENTATION_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_XML_PRESENTATION_SETTED, PageProxyResponseCommand );
			registerCommand( PAGE_REMOTE_CALL_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_REMOTE_CALL_ERROR_GETTED, PageProxyResponseCommand );
			registerCommand( PAGE_COPY_CREATED, PageProxyResponseCommand );

			registerCommand( OBJECT_PROXY_REQUEST, ObjectProxyRequestCommand );
			registerCommand( OBJECT_ATTRIBUTES_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_ATTRIBUTES_SETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_NAME_SETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTIONS_LIST_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTIONS_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_ALL_SERVER_ACTIONS_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTION_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTION_SETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTION_CREATED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTION_RENAMED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_SERVER_ACTION_DELETED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_OBJECT_CREATED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_WYSIWYG_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_XML_PRESENTATION_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_XML_PRESENTATION_SETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_REMOTE_CALL_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_REMOTE_CALL_ERROR_GETTED, ObjectProxyResponseCommand );
			registerCommand( OBJECT_COPY_CREATED, ObjectProxyResponseCommand );
			

			registerCommand( RESOURCES_PROXY_REQUEST,	ResourcesProxyRequestCommand );
			registerCommand( RESOURCES_GETTED,		 	ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_LOADED, 			ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_SETTED, 			ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_SETTED_ERROR, 	ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_DELETED,			ResourcesProxyResponseCommand );
			registerCommand( RESOURCE_MODIFIED, 		ResourcesProxyResponseCommand );

			registerCommand( ICON_GETTED,				ResourcesProxyResponseCommand );
			
//			errors
			registerCommand( SERVER_ERROR, ErrorMacroCommand );
			registerCommand( SERVER_CONNECTION_ERROR, ErrorMacroCommand );
			registerCommand( SERVER_LOGIN_ERROR, ErrorMacroCommand );
			
			registerCommand( OPEN_PAGE_IN_EXTERNAL_BROWSER, OpenPageInExternalBrowserCommand );
			
			registerCommand( OPEN_APPLICATION_MANAGER, OpenApplicationManagerCommand );
			
			registerCommand( GET_APPLICATIONS_LIST, GetApplicationListCommand );
			
			registerCommand( LOAD_RESOURCE, GetResourceItemRendererCommand );
			registerCommand( GET_SELECTED_APPLICATION, GetSelectedApplicationCommand );
			registerCommand( SET_SELECTED_APPLICATION, SetSelectedApplicationCommand );
			
			registerCommand( GET_SETTINGS, GetSettingsCommand );
			registerCommand( SETTINGS_CHANGED, SettingsChangedCommand );
			registerCommand( GET_SETTINGS_MANAGER, RetrievModuleSettingsCopy );
			
			
			registerCommand( EDIT_APPLICATION_INFORMATION, EditApplicationInformationCommand );
			
			registerCommand( SET_RESOURCE, SetResourceIconCommand );
			
			registerCommand( CREATE_APPLICATION, CreateApplicationCommand );
			
			registerCommand( TypesProxy.GET_TYPES, GetTypesCommand );
			
//			registerCommand( OPEN_APPLICATION_IN_EDITOR, OpenAppInEditorCommand );
			
			registerCommand( CREATE_FIRST_PAGE, CreateFirstPageCommand );
//			registerCommand( LOGOFF_REQUEST, LogoffRequestCommand );
			
			registerCommand( CLOSE_APPLICATION_MANAGER, CloseApplicationManagerCommand );
			
			registerCommand( CHECK_UPDATE, CheckUpdateCommand );
			registerCommand( WRITE_ERROR, AlertSystemCommand );
			registerCommand( WRITE_QUESTION, AlertSystemCommand );
			
			registerCommand( CLEAR_PROXY_STORAGE, ClearProxiesStorageCommand );
			
			registerCommand( GET_APPLICATIONS_HOSTS, GetApplicationsHostsCommand );
			
		}
	}
}
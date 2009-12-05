package net.vdombox.ide.core
{
	import mx.rpc.events.FaultEvent;
	
	import net.vdombox.ide.core.controller.ApplicationLoadedCommand;
	import net.vdombox.ide.core.controller.ConnectServerCommand;
	import net.vdombox.ide.core.controller.ConnectionServerSuccessfulCommand;
	import net.vdombox.ide.core.controller.LoadModulesCommand;
	import net.vdombox.ide.core.controller.LogonSuccessfulCommand;
	import net.vdombox.ide.core.controller.ModuleLoadedCommand;
	import net.vdombox.ide.core.controller.PreinitalizeMacroCommand;
	import net.vdombox.ide.core.controller.ResourcesProxyRequestCommand;
	import net.vdombox.ide.core.controller.ServerProxyRequestCommand;
	import net.vdombox.ide.core.controller.TypesProxyRequestCommand;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
//		public static const INVOKE : String = "invoke";

		public static const PREINITALIZE : String = "preinitalize";

		public static const STARTUP : String = "startup";
		
		public static const INITIAL_WINDOW_OPENED : String = "initialWindowOpened";
		public static const MAIN_WINDOW_OPENED : String = "mainWindowOpened";
		
		public static const CHANGE_LOCALE : String = "changeLocale";

		public static const PROCESS_USER_INPUT: String = "processUserInput";
		
		public static const CONNECT_SERVER : String = "connectServer";
		public static const CONNECTION_SERVER_STARTS : String = "connectionServerStarts";
		public static const CONNECTION_SERVER_SUCCESSFUL : String = "connectionServerSuccessful";
		public static const CONNECTION_SERVER_ERROR : String = "connectionServerError";
		
//		public static const LOGGED_ON: String = "loggedOn";
		public static const LOGON_STARTS : String = "logonStarts";
		public static const LOGON_SUCCESS : String = "logonSuccess";
		public static const LOGON_ERROR : String = "logonError";
		
//		public static const LOGOFF : String = "logoff";
		public static const LOGOFF_STARTS : String = "logoffStarts";
		public static const LOGOFF_SUCCESS : String = "logoffSuccess";
		public static const LOGOFF_ERROR : String = "logoffError";
		
		public static const APPLICATIONS_LOADING : String = "applicationsLoading";
		public static const APPLICATIONS_LOADED : String = "applicationsLoaded";
		
		public static const TYPES_LOADING : String = "typesLoading";
		public static const TYPES_LOADED : String = "typesLoaded";
		
		public static const CONNECT_MODULE_TO_CORE : String = "connectModuleToCore";
		public static const DISCONNECT_MODULE_TO_CORE : String = "disconnectModuleToCore";
		
		public static const CONNECT_MODULE_TO_PROXIES : String = "connectModuleToProxies";
		public static const MODULE_TO_PROXIES_CONNECTED : String = "moduleToProxiesСonnected";
		public static const DISCONNECT_MODULE_TO_PROXIES : String = "disconnectModuleToProxies";
		public static const MODULE_TO_PROXIES_DISCONNECTED : String = "moduleToProxiesDisconnected";
		
//		Proxies		
		public static const RESOURCES_PROXY_REQUEST : String = "resourcesProxyRequest";
		public static const RESOURCES_PROXY_RESPONSE : String = "resourcesProxyResponse";
		
		public static const SERVER_PROXY_REQUEST : String = "serverProxyRequest";
		public static const SERVER_PROXY_RESPONSE : String = "serverProxyResponse";
		
		public static const TYPES_PROXY_REQUEST : String = "typesProxyRequest";
		public static const TYPES_PROXY_RESPONSE : String = "typesProxyResponse";
		
//		************
		
		public static const LOAD_MODULES : String = "loadModules";
		public static const MODULES_LOADED : String = "modulesLoaded";
		
		public static const LOAD_MODULE : String = "loadModule";
		public static const MODULE_LOADED : String = "moduleLoaded";
		public static const MODULE_READY : String = "moduleReady";
		
		public static const CHANGE_SELECTED_MODULE : String = "changeSelectedModule";
		public static const SELECTED_MODULE_CHANGED : String = "selectedModuleChanged";

//		pipes messages
		public static const SHOW_MODULE_TOOLSET : String = "showModuleToolset";
		public static const SHOW_MODULE_BODY : String = "showModuleBody";

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
			
			
			
			registerCommand( TYPES_PROXY_REQUEST, TypesProxyRequestCommand );
			registerCommand( RESOURCES_PROXY_REQUEST, ResourcesProxyRequestCommand );
			registerCommand( SERVER_PROXY_REQUEST, ServerProxyRequestCommand );
		}

		private function soap_faultEvent( event : FaultEvent ) : void
		{
			var dummy : * = ""; // TODO soap_faultEvent
		}
	}
}
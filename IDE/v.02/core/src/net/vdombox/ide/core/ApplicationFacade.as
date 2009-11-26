package net.vdombox.ide.core
{
	import mx.rpc.events.FaultEvent;
	
	import net.vdombox.ide.core.controller.ConnectCompleteCommand;
	import net.vdombox.ide.core.controller.InvokeCommand;
	import net.vdombox.ide.core.controller.LoadModuleCommand;
	import net.vdombox.ide.core.controller.ModuleLoadedCommand;
	import net.vdombox.ide.core.controller.PreinitalizeMacroCommand;
	import net.vdombox.ide.core.controller.QuitCommand;
	import net.vdombox.ide.core.controller.RemoveModuleCommand;
	import net.vdombox.ide.core.controller.ResourcesProxyRequestCommand;
	import net.vdombox.ide.core.controller.ServerProxyRequestCommand;
	import net.vdombox.ide.core.controller.SubmitCommand;
	import net.vdombox.ide.core.controller.TypeLoadedCommand;
	import net.vdombox.ide.core.controller.TypesLoadedCommand;
	import net.vdombox.ide.core.controller.TypesProxyRequestCommand;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const INVOKE : String = "invoke";

		public static const PREINITALIZE : String = "preinitalize";

		public static const STARTUP : String = "startup";

		public static const SUBMIT : String = "submit";

		public static const QUIT : String = "quit";
		
		public static const LOGIN_COMPLETE : String = "Login Complete";
		public static const CONNECT_COMPLETE : String = "Connect Complete";
		
		public static const TYPES_LOADED : String = "typesLoaded";
		public static const TYPE_LOADED : String = "typeLoaded";
		
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
		
//		ModulesProxy
		public static const REMOVE_MODULE : String = "removeModule";
		
		public static const LOAD_MODULE : String = "loadModule";
		
		public static const MODULE_LOADED : String = "moduleLoaded";
		
		public static const MODULE_READY : String = "moduleReady";
		
		public static const CHANGE_SELECTED_MODULE : String = "changeSelectedModule";
		
		public static const SELECTED_MODULE_CHANGED : String = "selectedModuleChanged";

//		pipes messages
		public static const SHOW_TOOLSET : String = "showToolset";
		public static const SHOW_BODY : String = "showBody";

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

		public function invoke( arguments : Array ) : void
		{
			sendNotification( INVOKE, arguments );
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

			registerCommand( PREINITALIZE, PreinitalizeMacroCommand );

			registerCommand( INVOKE, InvokeCommand );
			registerCommand( SUBMIT, SubmitCommand );
			registerCommand( CONNECT_COMPLETE, ConnectCompleteCommand );
			registerCommand( LOAD_MODULE, LoadModuleCommand );
			registerCommand( MODULE_LOADED, ModuleLoadedCommand );
			registerCommand( REMOVE_MODULE, RemoveModuleCommand );
			
			registerCommand( TYPES_PROXY_REQUEST, TypesProxyRequestCommand );
			registerCommand( RESOURCES_PROXY_REQUEST, ResourcesProxyRequestCommand );
			registerCommand( SERVER_PROXY_REQUEST, ServerProxyRequestCommand );
			
			registerCommand( TYPE_LOADED, TypeLoadedCommand );
			registerCommand( TYPES_LOADED, TypesLoadedCommand );
			
			registerCommand( QUIT, QuitCommand );
		}

		private function soap_faultEvent( event : FaultEvent ) : void
		{
			var dummy : * = ""; // TODO soap_faultEvent
		}
	}
}
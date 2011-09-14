package net.vdombox.ide.modules.preview
{
	import net.vdombox.ide.modules.Preview2;
	import net.vdombox.ide.modules.preview.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.preview.controller.StartupCommand;
	import net.vdombox.ide.modules.preview.controller.TearDownCommand;
	import net.vdombox.ide.modules.preview.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.preview.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.preview.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.preview.controller.messages.ProcessServerProxyMessageCommand;
	import net.vdombox.ide.modules.preview.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.preview.controller.messages.ProcessTypesProxyMessageCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
//		main
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		
		
		public static const PIPES_READY : String = "pipesReady";
		
//		tear down
		public static const TEAR_DOWN : String = "tearDown";
		
		
//		pipe messages
		public static const PROCESS_SERVER_PROXY_MESSAGE : String = "processServerProxyMessage";
		public static const PROCESS_STATES_PROXY_MESSAGE : String = "processStatesProxyMessage";
		public static const PROCESS_TYPES_PROXY_MESSAGE : String = "processTypesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE : String = "processObjectProxyMessage";
		
		public static const SELECT_MODULE : String = "selectModule";
		
		
		
		
//		other
		public static const DELIMITER : String = "/";
		
		
		
		
		
		
		public static const OPEN_WINDOW : String = "openWidow";
		public static const CLOSE_WINDOW : String = "closeWidow";
		
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
		
		public function startup( application : Preview2 ) : void
		{
			sendNotification( STARTUP, application );
		}
		
		override protected function initializeController( ) : void 
		{
			super.initializeController();
			registerCommand( STARTUP, StartupCommand );
			registerCommand( CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}
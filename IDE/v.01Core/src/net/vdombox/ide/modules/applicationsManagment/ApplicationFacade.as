package net.vdombox.ide.modules.applicationsManagment
{
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.StartupCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.TearDownCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_MAIN_CONTENT : String = "createMainContent";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_MAIN_CONTENT : String = "exportMainContent";
		
		public static const CONNECT_PROXIES_PIPE : String = "connectProxiesPipe";
		
		public static const TEAR_DOWN : String = "tearDown";
		
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
		
		public function startup( application : ApplicationsManagment ) : void
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
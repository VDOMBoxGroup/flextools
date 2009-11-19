package net.vdombox.ide.modules.edition
{
	import net.vdombox.ide.modules.Edition;
	import net.vdombox.ide.modules.edition.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.edition.controller.StartupCommand;
	import net.vdombox.ide.modules.edition.controller.TearDownCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_MAIN_CONTENT : String = "createMainContent";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_MAIN_CONTENT : String = "exportMainContent";
		
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
		
		public function startup( application : Edition ) : void
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
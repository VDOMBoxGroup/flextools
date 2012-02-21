package net.vdombox.ide.modules.preview
{
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.Preview2;
	import net.vdombox.ide.modules.preview.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.preview.controller.StartupCommand;
	import net.vdombox.ide.modules.preview.controller.TearDownCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		
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
			sendNotification( Notifications.STARTUP, application );
		}
		
		override protected function initializeController( ) : void 
		{
			super.initializeController();
			registerCommand( Notifications.STARTUP, StartupCommand );
			registerCommand( Notifications.CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
		}
	}
}
package net.vdombox.ide
{
	import net.vdombox.ide.controller.InvokeCommand;
	import net.vdombox.ide.controller.LoginCommand;
	import net.vdombox.ide.controller.PreinitalizeCommand;
	import net.vdombox.ide.controller.QuitCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const INVOKE : String = "invoke";
		public static const PREINITALIZE : String = "preinitalize";
		public static const STARTUP : String = "startup";
		
		public static const LOGIN : String = "login";
		
		public static const SUBMIT_BEGIN : String = "submitBegin";
		public static const QUIT : String = "quit";

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

		override protected function initializeController() : void
		{
			super.initializeController();
			
			registerCommand( PREINITALIZE, PreinitalizeCommand );
			
			registerCommand( INVOKE, InvokeCommand );
			registerCommand( SUBMIT_BEGIN, LoginCommand );
			registerCommand( QUIT, QuitCommand );
		}

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
	}
}
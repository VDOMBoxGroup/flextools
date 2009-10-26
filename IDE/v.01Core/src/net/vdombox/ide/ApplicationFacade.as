package net.vdombox.ide
{
	import mx.rpc.events.FaultEvent;

	import net.vdombox.ide.controller.ConnectCompleteCommand;
	import net.vdombox.ide.controller.InvokeCommand;
	import net.vdombox.ide.controller.PreinitalizeMacroCommand;
	import net.vdombox.ide.controller.QuitCommand;
	import net.vdombox.ide.controller.SubmitCommand;
	import net.vdombox.ide.controller.TypesLoadedCommand;
	import net.vdombox.ide.model.ServerProxy;
	import net.vdombox.ide.model.TypeProxy;
	import net.vdombox.ide.model.business.SOAP;

	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{

		public function ApplicationFacade( key : String )
		{
			super( key );

			soap.addEventListener( FaultEvent.FAULT, soap_faultEvent );
		}

		public static const INVOKE : String = "invoke";

		public static const PREINITALIZE : String = "preinitalize";

		public static const STARTUP : String = "startup";

		public static const SUBMIT : String = "submit";

		public static const QUIT : String = "quit";

		private var soap : SOAP = SOAP.getInstance();

		public static function getInstance( key : String ) : ApplicationFacade
		{
			if ( instanceMap[ key ] == null )
				instanceMap[ key ] = new ApplicationFacade( key );
			return instanceMap[ key ] as ApplicationFacade;
		}

		override protected function initializeController() : void
		{
			super.initializeController();

			registerCommand( PREINITALIZE, PreinitalizeMacroCommand );

			registerCommand( INVOKE, InvokeCommand );
			registerCommand( SUBMIT, SubmitCommand );
			registerCommand( ServerProxy.CONNECT_COMPLETE, ConnectCompleteCommand );
			registerCommand( TypeProxy.TYPES_LOADED, TypesLoadedCommand );
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

		private function soap_faultEvent( event : FaultEvent ) : void
		{
			var dummy : * = ""; // FIXME remove dummy
		}
	}
}
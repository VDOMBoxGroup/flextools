package net.vdombox.ide.core.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.ErrorView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ErrorViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ErrorViewMediator";
		
		public function ErrorViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
//		private var _errorText : String;
		
		public function get errorText() : String
		{
			return errorView.errorTextLabel.text;
		}
		
		public function set errorText( value : String ) : void
		{
			errorView.errorTextLabel.text = value;
	
		}
		
		override public function onRegister() : void
		{
			errorView.addEventListener( "backButtonClicked", backButtonClickedHandler );
		}
		
		private function backButtonClickedHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.SHOW_LOGON_VIEW );
		}
		
		private function get errorView() : ErrorView
		{
			return viewComponent as ErrorView;
		}
	}
}
package net.vdombox.ide.core.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.SessionProxy;
	import net.vdombox.ide.core.view.components.ErrorView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ErrorViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ErrorViewMediator";
		
		public function ErrorViewMediator( viewComponent : ErrorView )
		{
			super( NAME, viewComponent );
		}
		
		private var sessionProxy : SessionProxy;
		
		public function get errorView() : ErrorView
		{
			return viewComponent as ErrorView;
		}
		
		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			addHandlers();
		}
		
		override public function onRemove():void
		{
			sessionProxy = null;
			
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			errorView.addEventListener( "backButtonClicked", backButtonClickedHandler, false, 0, true );
			errorView.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandlerHandler, false, 0, true );
			errorView.addEventListener( Event.REMOVED_FROM_STAGE, removedToStageHandlerHandler, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			errorView.removeEventListener( "backButtonClicked", backButtonClickedHandler );
			errorView.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandlerHandler );
			errorView.removeEventListener( Event.REMOVED_FROM_STAGE, removedToStageHandlerHandler );
		}
		
		private function addedToStageHandlerHandler( event : Event ) : void
		{
			errorView.errorVO = sessionProxy.errorVO;
		}
		
		private function removedToStageHandlerHandler( event : Event ) : void
		{
			
		}
		
		private function backButtonClickedHandler( event : Event ) : void
		{
			sessionProxy.errorVO = null;
			
			sendNotification( ApplicationFacade.SHOW_LOGIN_VIEW_REQUEST );
		}
	}
}
package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.common.events.CreateActionWindowEvent;
	import net.vdombox.ide.common.components.CreateActionWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class CreateActionWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateActionWindowMediator";
		
		public function CreateActionWindowMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		private var _creationTarget : String;
		
		public function get createActionWindow() : CreateActionWindow
		{
			return viewComponent as CreateActionWindow;
		}
		
		public function set creationTarget( value : String ) : void
		{
			_creationTarget = value;
		}
		
		override public function onRegister() : void
		{
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			createActionWindow.addEventListener( CreateActionWindowEvent.PERFORM_CREATE, performCreateHandler, false, 0, true );
			createActionWindow.addEventListener( CreateActionWindowEvent.PERFORM_CANCEL, performCancelHandler, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			createActionWindow.removeEventListener( CreateActionWindowEvent.PERFORM_CREATE, performCreateHandler );
			createActionWindow.removeEventListener( CreateActionWindowEvent.PERFORM_CANCEL, performCancelHandler );
			
			viewComponent = null;
		}
		
		private function performCreateHandler( event : CreateActionWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_WINDOW, createActionWindow );
			
			var name : String = createActionWindow.nameTextInput.text;
			
			sendNotification( ApplicationFacade.CREATE_SCRIPT_REQUEST, { name : name, target : _creationTarget } );
			
			facade.removeMediator( NAME );
		}
		
		private function performCancelHandler( event : CreateActionWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_WINDOW, createActionWindow );
			facade.removeMediator( NAME );
		}
	}
}
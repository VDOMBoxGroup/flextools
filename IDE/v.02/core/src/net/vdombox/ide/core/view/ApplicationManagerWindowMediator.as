package net.vdombox.ide.core.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.view.components.ApplicationManagerWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationManagerWindowMediator extends Mediator implements IMediator
	{
		public function ApplicationManagerWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get applicationManagerWindow() : ApplicationManagerWindow
		{
			return viewComponent as ApplicationManagerWindow;
		}
		
		override public function onRegister() : void
		{
			facade.registerProxy( new SettingsProxy() );
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			applicationManagerWindow.addEventListener( FlexEvent.CREATION_COMPLETE, createCompleteHandler );
			applicationManagerWindow.addEventListener( ApplicationManagerWindowEvent.CLOSE_WINDOW, closeHandler );
		}
		
		private function removeHandlers() : void
		{
			applicationManagerWindow.removeEventListener( ApplicationManagerWindowEvent.CLOSE_WINDOW, closeHandler );
		}
		
		private function createCompleteHandler ( event : FlexEvent ) : void
		{
			facade.registerMediator( new ChangeApplicationViewMediator ( applicationManagerWindow.changeApplicationView ) );
		}
		
		private function closeHandler ( event : ApplicationManagerWindowEvent ) : void
		{
			WindowManager.getInstance().removeWindow( event.target );
			sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			facade.removeMediator( mediatorName );
			facade.removeProxy( SettingsProxy.NAME );
		}
	}
}
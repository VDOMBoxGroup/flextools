package net.vdombox.ide.core.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.view.components.ApplicationManagerWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationManagerWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationManagerWindowMediator";
		
		public function ApplicationManagerWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get applicationManagerWindow() : ApplicationManagerWindow
		{
			return viewComponent as ApplicationManagerWindow;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW );
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_CREATE_VIEW );
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_CHANGE_VIEW );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW:
				{
					applicationManagerWindow.changeApplicationView.visible = false;
					applicationManagerWindow.createEditApplicationView.visible = true;
					
					break;
				}
					
				case ApplicationFacade.OPEN_APPLICATION_IN_CREATE_VIEW:
				{
					applicationManagerWindow.changeApplicationView.visible = false;
					applicationManagerWindow.createEditApplicationView.visible = true;
					
					break;
				}
					
				case ApplicationFacade.OPEN_APPLICATION_IN_CHANGE_VIEW:
				{
					applicationManagerWindow.changeApplicationView.visible = true;
					applicationManagerWindow.createEditApplicationView.visible = false;
					
					break;
				}
					
			}
		}
		
		override public function onRegister() : void
		{
			facade.registerProxy( new GalleryProxy() );
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			closeWindows();
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
			facade.registerMediator( new CreateEditApplicationViewMediator ( applicationManagerWindow.createEditApplicationView ) );
		}
		
		private function closeHandler ( event : ApplicationManagerWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			closeWindows();
		}
		
		private function closeWindows () : void
		{
			WindowManager.getInstance().removeWindow( applicationManagerWindow );
			
			facade.removeProxy( GalleryProxy.NAME );
		}
	}
}
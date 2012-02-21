package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.view.components.windows.CreatePageWindow;
	import net.vdombox.ide.common.events.ItemRendererEvent;
	import net.vdombox.ide.common.events.WindowEvent;
	import net.vdombox.ide.common.model._vo.AttributeDescriptionVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class CreatePageWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreatePageWindowMediator";
		
		public function CreatePageWindowMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get createPageWindow() : CreatePageWindow
		{
			return viewComponent as CreatePageWindow;
		}
		
		override public function onRegister() : void
		{
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.TOP_LEVEL_TYPES_GETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case Notifications.TOP_LEVEL_TYPES_GETTED:
				{
					createPageWindow.pagesDataProvider = body as Array;
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
			createPageWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );
			
			createPageWindow.addEventListener( ItemRendererEvent.CREATED, pagesItemRenderer_createdHandler, true, 0, true );
			
			createPageWindow.addEventListener( WindowEvent.PERFORM_APPLY, performApplyHandler, true, 0, true );
			createPageWindow.addEventListener( WindowEvent.PERFORM_CANCEL, performCancelHandler, true, 0, true );
		}
		
		private function removeHandlers() : void
		{
			createPageWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			
			createPageWindow.removeEventListener( ItemRendererEvent.CREATED, pagesItemRenderer_createdHandler, true );
			
			createPageWindow.removeEventListener( WindowEvent.PERFORM_APPLY, performApplyHandler, true );
			createPageWindow.removeEventListener( WindowEvent.PERFORM_CANCEL, performCancelHandler, true );
			
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( Notifications.GET_TOP_LEVEL_TYPES );
		}
		
		private function performApplyHandler ( event : WindowEvent ) : void
		{
			var selectedPageType : TypeVO = createPageWindow.selectedPageType;
			
			WindowManager.getInstance().removeWindow( createPageWindow );
			
			addTitle (selectedPageType);
			
			if( selectedPageType )
				sendNotification( Notifications.CREATE_PAGE_REQUEST, selectedPageType );
			
			facade.removeMediator( NAME );
		}
		
		private function addTitle(pageType: TypeVO):void
		{
			for each (var descr: AttributeDescriptionVO in pageType.attributeDescriptions)
			{
				if (descr.defaultValue == "title")
				{
					//descr.defaultValue = pageType.description;					
				}
			}			
		}
		
		private function performCancelHandler ( event : WindowEvent ) : void
		{
			//sendNotification( Notifications.CLOSE_WINDOW, createPageWindow );
			
			WindowManager.getInstance().removeWindow( createPageWindow );
			
			facade.removeMediator( NAME );
		}
		
		private function pagesItemRenderer_createdHandler( event : ItemRendererEvent ) : void
		{
			sendNotification( Notifications.PAGE_TYPE_ITEM_RENDERER_CREATED, event.target );
		}
	}
}
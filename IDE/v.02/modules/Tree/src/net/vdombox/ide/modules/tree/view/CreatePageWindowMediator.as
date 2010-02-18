package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.CreatePageWindowEvent;
	import net.vdombox.ide.modules.tree.events.ItemRendererEvent;
	import net.vdombox.ide.modules.tree.view.components.CreatePageWindow;
	
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

			interests.push( ApplicationFacade.TOP_LEVEL_TYPES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.TOP_LEVEL_TYPES_GETTED:
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
			
			createPageWindow.addEventListener( CreatePageWindowEvent.PERFORM_CREATE, performCreateHandler, false, 0, true );
			createPageWindow.addEventListener( CreatePageWindowEvent.PERFORM_CANCEL, performCancelHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			createPageWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			
			createPageWindow.removeEventListener( CreatePageWindowEvent.PERFORM_CREATE, performCreateHandler );
			createPageWindow.removeEventListener( CreatePageWindowEvent.PERFORM_CANCEL, performCancelHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_TOP_LEVEL_TYPES );
		}
		
		private function performCreateHandler ( event : CreatePageWindowEvent ) : void
		{
			var selectedPageType : TypeVO = createPageWindow.selectedPageType;
			
			sendNotification( ApplicationFacade.CLOSE_WINDOW, createPageWindow );
			
			if( selectedPageType )
				sendNotification( ApplicationFacade.CREATE_PAGE_REQUEST, selectedPageType );
			
			facade.removeMediator( NAME );
		}
		
		private function performCancelHandler ( event : CreatePageWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_WINDOW, createPageWindow );
			
			facade.removeMediator( NAME );
		}
		
		private function pagesItemRenderer_createdHandler( event : ItemRendererEvent ) : void
		{
			sendNotification( ApplicationFacade.PAGE_TYPE_ITEM_RENDERER_CREATED, event.target );
		}
	}
}
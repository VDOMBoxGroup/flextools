package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.business.VdomDragManager;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ItemMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ItemMediator";

		public function ItemMediator( viewComponent : Item )
		{
			var itemVO : ItemVO = viewComponent.data as ItemVO;

			super( NAME + ApplicationFacade.DELIMITER + itemVO.id, viewComponent );
		}

		public function get item() : Item
		{
			return viewComponent as Item;
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

//			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
//				case ApplicationFacade.SELECTED_PAGE_CHANGED:
//				{
//					isSelectedPageVOChanged = true;
//					commitProperties();
//					break;
//				}
			}
		}

		private function addHandlers() : void
		{
//			item.addEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true, 0, true );
			item.addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			item.addEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
			item.addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		}

		

		private function removeHandlers() : void
		{
//			item.removeEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true )
		}


		private function dragEnterHandler( event : DragEvent ) : void
		{
			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );

			if ( !typeDescription )
				return;

			var containersRE : RegExp = /(\w+)/g;
			var aviableContainers : Array = typeDescription.aviableContainers.match( containersRE );

			var currentItemName : String = ItemVO( item.data ).typeVO.name;

			if ( aviableContainers.indexOf( currentItemName ) != -1 )
			{
				var vdomDragManager : VdomDragManager = VdomDragManager.getInstance();
				vdomDragManager.acceptDragDrop( UIComponent( item ) );
				item.skin.currentState = "highlighted";
			}
		}
		
		private function dragDropHandler( event : DragEvent ) : void
		{
			item.skin.currentState = "normal";
			
			var typeVO : TypeVO = TypeItemRenderer( event.dragInitiator ).typeVO;
			
			var objectLeft : Number = item.mouseX - 25 + item.layout.horizontalScrollPosition;
			var objectTop : Number = item.mouseY - 25 + item.layout.verticalScrollPosition;
			
			var attributes : Array = [];
			
			attributes.push( new AttributeVO( "left", objectLeft.toString() ) );
			attributes.push( new AttributeVO( "top", objectTop.toString() ) );
			
			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { parentID : item.itemVO.id ,typeVO : typeVO, attributes : attributes } );
		}
		
		private function dragExitHandler( event : DragEvent ) : void
		{
			item.skin.currentState = "normal";
		}
	}
}
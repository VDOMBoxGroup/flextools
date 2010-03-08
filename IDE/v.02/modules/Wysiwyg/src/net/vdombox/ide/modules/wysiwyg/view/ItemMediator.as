package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
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
		public static var instances : Object = {};

		public function ItemMediator( viewComponent : Item )
		{
			var itemVO : ItemVO = viewComponent.data as ItemVO;

			super( NAME + ApplicationFacade.DELIMITER + itemVO.id, viewComponent );
			instances[ this.mediatorName ] = "";
		}

		public function get item() : Item
		{
			return viewComponent as Item;
		}
		
		public function lock() : void
		{
			item.lock();
		}
		
		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			delete instances[ mediatorName ];
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					if ( body && item.itemVO && item.itemVO.id == body.id )
						item.dispatchEvent( new ItemEvent( ItemEvent.ITEM_CLICKED ) );

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			item.addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true );
			item.addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true );
			item.addEventListener( MouseEvent.CLICK, mouseClickHandler, false, 0, true );
			item.addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
			item.addEventListener( DragEvent.DRAG_EXIT, dragExitHandler, false, 0, true );
			item.addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();
			
				item.dispatchEvent( new ItemEvent( ItemEvent.ITEM_CLICKED ) );
		}

		private function mouseOutHandler( event : MouseEvent ) : void
		{
			if ( item.skin.currentState == "hovered" )
				item.skin.currentState = "normal";
		}

		private function mouseOverHandler( event : MouseEvent ) : void
		{
			if ( item.skin.currentState == "highlighted" )
				return;

			if ( findNearestItem( event.target as DisplayObjectContainer ) == this.item )
				item.skin.currentState = "hovered";
			else
				item.skin.currentState = "normal";
		}

		private function removeHandlers() : void
		{
			item.removeEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
			item.removeEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );
			item.removeEventListener( MouseEvent.CLICK, mouseClickHandler );
			item.removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			item.removeEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
			item.removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
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

			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { parentID: item.itemVO.id, typeVO: typeVO, attributes: attributes } );
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			item.skin.currentState = "normal";
		}

		private function findNearestItem( currentElement : DisplayObjectContainer ) : Item
		{
			var result : Item;

			while ( currentElement && currentElement.parent )
			{
				if ( currentElement is Item )
				{
					result = currentElement as Item;
					break;
				}

				currentElement = currentElement.parent;
			}

			return result;
		}
	}
}
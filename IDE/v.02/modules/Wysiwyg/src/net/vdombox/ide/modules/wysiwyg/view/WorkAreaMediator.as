package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.MouseEvent;

	import mx.core.UIComponent;
	import mx.events.DragEvent;

	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.events.TransformMarkerEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.business.VdomDragManager;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
	import net.vdombox.ide.modules.wysiwyg.view.components.TransformMarker;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;
		private var transformMarker : TransformMarker;

		private var isSelectedPageVOChanged : Boolean;
		private var isSelectedObjectVOChanged : Boolean;

		private var isTransformed : Boolean;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		public function lock() : void
		{
			workArea.lock()
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			transformMarker = new TransformMarker();
			transformMarker.visible = false;

			workArea.upperLayer.addElement( transformMarker );

			addHandlers();

			isSelectedPageVOChanged = true;
			isSelectedObjectVOChanged = true;

			commitProperties();
		}

		override public function onRemove() : void
		{
			sessionProxy = null;

			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.RENDER_DATA_CHANGED );
			interests.push( ApplicationFacade.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					isSelectedPageVOChanged = true;
					commitProperties();
					break;
				}

				case ApplicationFacade.RENDER_DATA_CHANGED:
				{
					var itemMediatorName : String;
					var instances : Object = ItemMediator.instances;

					for ( itemMediatorName in ItemMediator.instances )
					{
						facade.removeMediator( itemMediatorName );
					}

					workArea.itemVO = body as ItemVO;

					if ( transformMarker )
						transformMarker.visible = false;

					sendNotification( ApplicationFacade.SELECT_ITEM_REQUEST, workArea );

					break;
				}

				case ApplicationFacade.MODULE_DESELECTED:
				{
					for ( itemMediatorName in ItemMediator.instances )
					{
						facade.removeMediator( itemMediatorName );
					}

					workArea.itemVO = null;

					workArea.upperLayer.removeAllElements();
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( ItemEvent.CREATED, item_createdHandler, true, 0, true );
			workArea.addEventListener( ItemEvent.REMOVED, item_removedHandler, true, 0, true );
			workArea.addEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true, 0, true );
			workArea.addEventListener( ItemEvent.ITEM_CLICKED, item_itemClickedHandler, true, 0, true );
			workArea.addEventListener( MouseEvent.CLICK, mouseClickHandler, false, 0, true );

			workArea.addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			workArea.addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
			workArea.addEventListener( DragEvent.DRAG_EXIT, dragExitHandler );

			transformMarker.addEventListener( TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler );
		}

		private function transformCompleteHandler( event : TransformMarkerEvent ) : void
		{
			isTransformed = true;

			sendNotification( ApplicationFacade.ITEM_TRANSFORMED, { itemVO: event.item.itemVO, properties: event.properties } );
		}

		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();

			if ( isTransformed )
			{
				isTransformed = false;
				return;
			}

			if ( workArea.itemVO )
				sendNotification( ApplicationFacade.SELECT_ITEM_REQUEST, workArea );

			workArea.upperLayer.removeAllElements();
		}

		private function item_itemClickedHandler( event : ItemEvent ) : void
		{
			var item : Item = event.target as Item;

			if( sessionProxy.selectedObject && sessionProxy.selectedObject.id == item.itemVO.id )
				return;
			
			sendNotification( ApplicationFacade.SELECT_ITEM_REQUEST, item );

			workArea.upperLayer.removeAllElements();
			workArea.upperLayer.addElement( transformMarker );

			switch ( item.itemVO.typeVO.resizable )
			{
				case "0":
				{
					transformMarker.resizeMode = TransformMarker.RESIZE_NONE
					break;
				}

				case "1":
				{
					transformMarker.resizeMode = TransformMarker.RESIZE_WIDTH
					break;
				}

				case "2":
				{
					transformMarker.resizeMode = TransformMarker.RESIZE_HEIGHT
					break;
				}

				case "3":
				{
					transformMarker.resizeMode = TransformMarker.RESIZE_ALL
					break;
				}
			}

			transformMarker.moveMode = item.itemVO.typeVO.moveable == "1" ? TransformMarker.MOVE_TRUE : TransformMarker.MOVE_FALSE;
			transformMarker.item = item;

			transformMarker.visible = true;
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( ItemEvent.CREATED, item_createdHandler, true );
			workArea.removeEventListener( ItemEvent.REMOVED, item_removedHandler, true );
			workArea.removeEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true );
			workArea.removeEventListener( ItemEvent.ITEM_CLICKED, item_itemClickedHandler, true );

			workArea.removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			workArea.removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
			workArea.removeEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
		}

		private function commitProperties() : void
		{
			if ( isSelectedPageVOChanged )
			{
				isSelectedPageVOChanged = false;

				if ( sessionProxy.selectedPage )
					sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
			}

			if ( isSelectedObjectVOChanged )
			{
				isSelectedObjectVOChanged = false;

			}
		}

		private function item_createdHandler( event : ItemEvent ) : void
		{
			if ( event.target != workArea )
				sendNotification( ApplicationFacade.ITEM_CREATED, event.target );
		}

		private function item_removedHandler( event : ItemEvent ) : void
		{
			if ( event.target != workArea )
				sendNotification( ApplicationFacade.ITEM_REMOVED, event.target );
		}

		private function item_getResourceHandler( event : ItemEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.target );
		}

		private function dragEnterHandler( event : DragEvent ) : void
		{
			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );

			if ( !typeDescription || !workArea.itemVO )
				return;

			var containersRE : RegExp = /(\w+)/g;
			var aviableContainers : Array = typeDescription.aviableContainers.match( containersRE );

			var currentItemName : String = ItemVO( workArea.itemVO ).typeVO.name;

			if ( aviableContainers.indexOf( currentItemName ) != -1 )
			{
				var vdomDragManager : VdomDragManager = VdomDragManager.getInstance();
				vdomDragManager.acceptDragDrop( UIComponent( workArea ) );
				workArea.skin.currentState = "highlighted";
			}
		}

		private function dragDropHandler( event : DragEvent ) : void
		{
			workArea.skin.currentState = "normal";

			var typeVO : TypeVO = TypeItemRenderer( event.dragInitiator ).typeVO;

			var objectLeft : Number = workArea.mouseX - 25 + workArea.layout.horizontalScrollPosition;
			var objectTop : Number = workArea.mouseY - 25 + workArea.layout.verticalScrollPosition;

			var attributes : Array = [];

			attributes.push( new AttributeVO( "left", objectLeft.toString() ) );
			attributes.push( new AttributeVO( "top", objectTop.toString() ) );

			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { parentID: workArea.itemVO.id, typeVO: typeVO, attributes: attributes } );
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			workArea.skin.currentState = "normal";
		}
	}
}
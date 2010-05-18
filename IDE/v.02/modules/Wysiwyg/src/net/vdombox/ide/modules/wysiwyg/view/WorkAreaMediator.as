package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;

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

		private var isSelectedPageVOChanged : Boolean;

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		private var isAddedToStage : Boolean;
		
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

			addHandlers();

			isSelectedPageVOChanged = true;
			
			if( workArea && workArea.stage )
				isAddedToStage = true;

			commitProperties();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.RENDER_DATA_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						if ( sessionProxy.selectedPage )
						{
							isSelectedPageVOChanged = true;

							commitProperties();
						}

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					if( !isAddedToStage )
						return;
					
					isSelectedPageVOChanged = true;

					commitProperties();

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					if( !isAddedToStage )
						return;
					
					if ( !sessionProxy.selectedObject )
						workArea.dispatchEvent( new ItemEvent( ItemEvent.ITEM_CLICKED ) );

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

					sendNotification( ApplicationFacade.SELECT_ITEM_REQUEST, workArea );

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			workArea.addEventListener( ItemEvent.CREATED, item_createdHandler, true, 0, true );
			workArea.addEventListener( ItemEvent.REMOVED, item_removedHandler, true, 0, true );
			workArea.addEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true, 0, true );

			workArea.addEventListener( ItemEvent.ITEM_CLICKED, item_itemClickedHandler, false, 0, true );
			workArea.addEventListener( ItemEvent.ITEM_CLICKED, item_itemClickedHandler, true, 0, true );

			workArea.addEventListener( DragEvent.DRAG_DROP, dragDropHandler );

			workArea.transformMarker.addEventListener( TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			workArea.removeEventListener( ItemEvent.CREATED, item_createdHandler, true );
			workArea.removeEventListener( ItemEvent.REMOVED, item_removedHandler, true );
			workArea.removeEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true );

			workArea.removeEventListener( ItemEvent.ITEM_CLICKED, item_itemClickedHandler );
			workArea.removeEventListener( ItemEvent.ITEM_CLICKED, item_itemClickedHandler, true );

			workArea.removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );

			workArea.transformMarker.removeEventListener( TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler );
		}


		private function clearData() : void
		{
			var itemMediatorName : String;

			for ( itemMediatorName in ItemMediator.instances )
			{
				facade.removeMediator( itemMediatorName );
			}

			workArea.itemVO = null;
		}

		private function addedToStageHandler( event : Event ) : void
		{
			isSelectedPageVOChanged = true;
			isAddedToStage = true;

			commitProperties();
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			isAddedToStage = false;
			
			clearData();
		}

		private function transformCompleteHandler( event : TransformMarkerEvent ) : void
		{
			var attributes : Array = [];

			var item : Item = event.item;
			var properties : Object = event.properties;

			var attributeName : String;
			var attributeVO : AttributeVO;

			for ( attributeName in properties )
			{
				for each ( attributeVO in item.itemVO.attributes )
				{
					if ( attributeVO.name == attributeName )
					{
						attributeVO.value = properties[ attributeName ];
						attributes.push( attributeVO );

						break;
					}
				}
			}

			if ( attributes.length > 0 )
				sendNotification( ApplicationFacade.ITEM_TRANSFORMED, { item: item, attributes: attributes } );
		}

		private function item_itemClickedHandler( event : ItemEvent ) : void
		{
			var item : Item = event.target as Item;

			sendNotification( ApplicationFacade.SELECT_ITEM_REQUEST, item );
		}

		private function commitProperties() : void
		{
			if ( isSelectedPageVOChanged )
			{
				isSelectedPageVOChanged = false;

				if ( sessionProxy.selectedPage )
					sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
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

		private function dragDropHandler( event : DragEvent ) : void
		{
			var typeVO : TypeVO = TypeItemRenderer( event.dragInitiator ).typeVO;

			var objectLeft : Number = workArea.mouseX - 25 + workArea.layout.horizontalScrollPosition;
			var objectTop : Number = workArea.mouseY - 25 + workArea.layout.verticalScrollPosition;

			var attributes : Array = [];

			attributes.push( new AttributeVO( "left", objectLeft.toString() ) );
			attributes.push( new AttributeVO( "top", objectTop.toString() ) );

			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { parentID: workArea.itemVO.id, typeVO: typeVO, attributes: attributes } );
		}
	}
}
package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.business.VdomDragManager;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.utils.DisplayUtils;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
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

		private var isSelectedPageVOChanged : Boolean;
		private var isSelectedObjectVOChanged : Boolean;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

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
					workArea.itemVO = body as ItemVO;

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( ItemEvent.CREATED, item_createdHandler, true, 0, true );
			workArea.addEventListener( ItemEvent.GET_RESOURCE, item_getResourceHandler, true, 0, true );
			
			workArea.addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			workArea.addEventListener( DragEvent.DRAG_OVER, dragOverHandler );
			workArea.addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
			workArea.addEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( ItemEvent.CREATED, item_createdHandler, true );
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
			if( event.target != workArea )
				sendNotification( ApplicationFacade.ITEM_CREATED, event.target );
		}
		
		private function item_getResourceHandler( event : ItemEvent ) : void 
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.target );
		}
		
		private function dragEnterHandler( event : DragEvent ) : void
		{
			var vdomDragManager : VdomDragManager = VdomDragManager.getInstance();
//			vdomDragManager.acceptDragDrop( UIComponent( event.currentTarget ) );
//			focusedObject = null
		}
		
		private function dragOverHandler( event : DragEvent ) : void
		{
			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );
			
			if ( !typeDescription )
				return;
			
			var filterFunction : Function = function( item : Item ) : Boolean
			{
//				return !item.isStatic;
				return true;
			}
			
			var stack : Array = DisplayUtils.getObjectsUnderMouse( workArea.parent, "net.vdombox.ide.modules.wysiwyg.view.components::Item",
				filterFunction );
			
			if ( stack.length == 0 )
				return;
			
			var currentItem : Item = stack[ 0 ];
			
			if( currentItem != workArea )
				var d : * = "";
			//trace("WorkArea - dragOverHandler " + stack.length )
			
//			if ( focusedObject == currentItem || IItem( currentItem ).waitMode )
//				return;
			
//			if ( focusedObject )
//				IItem( focusedObject ).drawHighlight( "none" );
//			
//			
//			var containersRE : RegExp = /(\w+)/g;
//			var aviableContainers : Array = typeDescription.aviableContainers.match( containersRE );
//			
//			var currentItemDescription : XML = dataManager.getTypeByObjectId( IItem( currentItem ).objectId );
//			
//			var currentItemName : String = currentItemDescription.Information.Name;
//			
//			
//			if ( aviableContainers.indexOf( currentItemName ) != -1 )
//			{
//				IItem( currentItem ).drawHighlight( "0x00FF00" );
//			}
//			else if ( currentItemDescription.Information.Container != 1 )
//			{
//				IItem( currentItem ).drawHighlight( "0xFF0000" );
//			}
//			else if ( currentItem.parent is IItem )
//			{
//				currentItem = Container( currentItem.parent );
//				
//				currentItemDescription = dataManager.getTypeByObjectId( IItem( currentItem ).objectId );
//				
//				currentItemName = currentItemDescription.Information.Name;
//				
//				if ( aviableContainers.indexOf( currentItemName ) != -1 )
//					
//					IItem( currentItem ).drawHighlight( "0x00FF00" );
//				else
//					IItem( currentItem ).drawHighlight( "0xFF0000" );
//			}
//			
//			focusedObject = currentItem;
		}
		
		private function dragDropHandler( event : DragEvent ) : void
		{
			var filterFunction : Function = function( item : Item ) : Boolean
			{
				//				return !item.isStatic;
				return true;
			}
			
			var stack : Array = DisplayUtils.getObjectsUnderMouse( workArea.parent, "net.vdombox.ide.modules.wysiwyg.view.components::Item",
				filterFunction );
//			resizeManager.itemDrag = false;
//			
//			var typeDescription : Object = event.dragSource.dataForFormat( "typeDescription" );
//			
//			var currentContainer : Container = focusedObject;
//			
//			if ( focusedObject is IItem )
//				IItem( focusedObject ).drawHighlight( "none" );
//			
//			if ( currentContainer )
//				currentContainer.drawFocus( false );
//			else
//				return;
//			
//			var currentItemName : String = dataManager.getTypeByObjectId( IItem( currentContainer ).objectId ).Information.Name;
//			
//			var re : RegExp = /\s+/g;
//			
//			var aviableContainers : Array = typeDescription.aviableContainers.replace( re,
//				"" ).split( "," );
//			
//			var bool : Number = aviableContainers.indexOf( currentItemName );
//			
//			if ( bool != -1 )
//			{
//				
//				var objectLeft : Number = currentContainer.mouseX - 25 + currentContainer.horizontalScrollPosition;
//				var objectTop : Number = currentContainer.mouseY - 25 + currentContainer.verticalScrollPosition;
//				
//				objectLeft = ( objectLeft < 0 ) ? 0 : objectLeft;
//				objectTop = ( objectTop < 0 ) ? 0 : objectTop;
//				
//				var attributes : XML = 
//					<Attributes>
//						<Attribute Name="top">
//					{objectTop}</Attribute>
//				<Attribute Name="left">
//				{objectLeft}</Attribute>
//		</Attributes>
//				
//				var wae : WorkAreaEvent = new WorkAreaEvent( WorkAreaEvent.CREATE_OBJECT )
//				wae.typeId = typeDescription.typeId;
//				wae.objectId = IItem( currentContainer ).objectId;
//				wae.props = attributes;
//				
//				dispatchEvent( wae );
//				
//				focusedObject = null;
//			}
		}
		
		private function dragExitHandler( event : DragEvent ) : void
		{
//			resizeManager.itemDrag = false;
//			
//			if ( focusedObject is IItem )
//				IItem( focusedObject ).drawHighlight( "none" );
		}
	}
}
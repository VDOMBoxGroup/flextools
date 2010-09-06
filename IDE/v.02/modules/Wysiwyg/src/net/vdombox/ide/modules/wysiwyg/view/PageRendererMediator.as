package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.MouseEvent;
	
	import mx.events.DragEvent;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class PageRendererMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ItemMediator";
		
		public static var instances : Object = {};
		
		public function PageRendererMediator( viewComponent : ObjectRenderer )
		{
			//			var renderVO : RenderVO = viewComponent.data as ItemVO;
			//
			//			super( NAME + ApplicationFacade.DELIMITER + itemVO.id, viewComponent );
			//			instances[ this.mediatorName ] = "";
		}
		
		public function get item() : ObjectRenderer
		{
			return viewComponent as ObjectRenderer;
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
					//					if ( body && item.itemVO && item.itemVO.id == body.id )
					//						item.dispatchEvent( new ItemEvent( ItemEvent.ITEM_CLICKED ) );
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
			item.addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			item.removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		}
		
		private function mouseClickHandler( event : MouseEvent ) : void
		{
			event.stopPropagation();
			item.dispatchEvent( new RendererEvent( RendererEvent.ITEM_CLICKED ) );
		}
		
		private function dragDropHandler( event : DragEvent ) : void
		{
			var typeVO : TypeVO = TypeItemRenderer( event.dragInitiator ).typeVO;
			
			var objectLeft : Number = item.mouseX - 25 + item.layout.horizontalScrollPosition;
			var objectTop : Number = item.mouseY - 25 + item.layout.verticalScrollPosition;
			
			var attributes : Array = [];
			
			attributes.push( new AttributeVO( "left", objectLeft.toString() ) );
			attributes.push( new AttributeVO( "top", objectTop.toString() ) );
			
			//			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { parentID: item.itemVO.id, typeVO: typeVO, attributes: attributes } );
		}
	}
}
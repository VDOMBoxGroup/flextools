package net.vdombox.ide.modules.events.view.components
{
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model._vo.EventVO;
	import net.vdombox.ide.common.view.components.EyeImage;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	
	import spark.components.RichEditableText;
	import spark.components.SkinnableContainer;
	
	public class BaseElement extends SkinnableContainer
	{
		private var _data : IEventBaseVO;
		
		[Bindable]
		public var title : String;
		
		protected var parameters : Array;
		
		protected var isNeedUpdateParameters : Boolean;
		
		private var mouseOffcetX : int;
		private var mouseOffcetY : int;
		
		private var moved : Boolean = false;
		
		[Bindable]
		public var selected : Boolean = false;
		
		
		public function BaseElement()
		{
			super();
			
			//addEventListener( FlexEvent.CREATION_COMPLETE, addHandlers, false, 0 , true );
		}
		
		/*private function addHandlers( event : FlexEvent ) : void
		{
			removeEventListener( FlexEvent.CREATION_COMPLETE, addHandlers );
			
			skin.addEventListener( MouseEvent.MOUSE_DOWN, header_mouseDownHandler, true, 0, true );
		}*/
		
		[Bindable]
		public function get data() : IEventBaseVO
		{
			return _data;
		}
		
		public function set data( value : IEventBaseVO ) : void
		{
			_data = value;
			
			title = data ? data.name : null;
			
			isNeedUpdateParameters = true;
			
			updateDisplayList( width, height );
		}
		
		public function get uniqueName() : String
		{
			return data ? (data.name + data.objectID) : "";
		}
		
		public function get objectID() : String
		{
			if ( data )
				return data.objectID;
			else
				return "";
		}
		
		protected function header_mouseDownHandler( event : MouseEvent ) : void
		{
			setFocus();
			moved = false;
			
			if ( event.shiftKey )
			{
				return;
			}
			
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandlerExt, false, 0, true );
			
			mouseOffcetX = mouseX;
			mouseOffcetY = mouseY;
		}
		
		protected function header_skinMouseDownHandler( event : MouseEvent ) : void
		{			
			moved = false;
			
			if ( event.shiftKey )
			{
				if ( event.target is RichEditableText )
					selected = true;
				else
					selected = !selected;
				
				dispatchEvent( new ElementEvent ( ElementEvent.MULTI_SELECTED ) );
			}
			else
			{
				skin.addEventListener( MouseEvent.MOUSE_UP, header_skinMouseClickHandler, true, 0, true );
			}
		}
		
		protected function header_skinMouseClickHandler( event : MouseEvent ) : void
		{		
			skin.removeEventListener( MouseEvent.MOUSE_UP, header_skinMouseClickHandler, true );
			if ( !moved )
				dispatchEvent( new ElementEvent ( ElementEvent.CLICK ) );
		}
		
		protected function stage_mouseMoveHandler( event : MouseEvent ) : void
		{			
			var newX : int = parent.mouseX - mouseOffcetX;
			var newY : int = parent.mouseY - mouseOffcetY;
			
			if ( newX < 0 )
				newX = 0;
			
			if ( newY < 0 )
				newY = 0;
			
			if ( selected )
			{
				var dx : int = int( newX - x );
				var dy : int = int ( newY - y );
				
				var moveEvent : ElementEvent = new ElementEvent ( ElementEvent.MULTI_SELECT_MOVED );
				moveEvent.object = { dx : dx, dy : dy };
				dispatchEvent( moveEvent );
			}
			else
			{
			
				x = newX;
				y = newY;
			
				data.left = x;
				data.top = y;
			}
		}
		
		public function hasMoved( dx : int, dy : int ) : Boolean
		{
			if ( x + dx < 0 || y + dy < 0 )
				return false;
			
			return true;
		}
		
		public function moveElement( dx : int, dy : int ) : void
		{
			x += dx;
			y += dy;
			
			data.left = x;
			data.top = y;
		}
		
		protected function stage_mouseMoveHandlerExt( event : MouseEvent ) : void
		{
			//dispatchEvent( new ElementEvent( ElementEvent.MOVED ) );
			moved = true;
			if ( stage )
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandlerExt );
		}
		
		protected function stage_mouseUpHandler( event : MouseEvent ) : void
		{
			if ( moved )
			{
				dispatchEvent( new ElementEvent( ElementEvent.MOVED ) );
				moved = false;
			}
			
			if ( stage )
			{
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
				stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
			}
		}
		
		protected function skinnablecontainer1_creationCompleteHandler(event:FlexEvent):void
		{
			x = data.left; 
			y = data.top;
			
			skin.addEventListener( MouseEvent.MOUSE_DOWN, header_skinMouseDownHandler, true, 0, true );
		}
		
	}
}
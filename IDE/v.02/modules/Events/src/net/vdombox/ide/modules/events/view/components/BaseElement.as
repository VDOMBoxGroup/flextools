package net.vdombox.ide.modules.events.view.components
{
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model.vo.EventVO;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.ide.common.view.EyeImage;
	
	import spark.components.SkinnableContainer;
	
	public class BaseElement extends SkinnableContainer
	{
		private var _data : IEventBaseVO;
		
		[Bindable]
		public var title : String;
		
		protected var isNeedUpdateParameters : Boolean;
		
		private var mouseOffcetX : int;
		private var mouseOffcetY : int;
		
		
		public function BaseElement()
		{
			super();
		}
		
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
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandlerExt );
			
			mouseOffcetX = mouseX;
			mouseOffcetY = mouseY;
		}
		
		protected function stage_mouseMoveHandler( event : MouseEvent ) : void
		{
			var newX : int = parent.mouseX - mouseOffcetX;
			var newY : int = parent.mouseY - mouseOffcetY;
			
			if ( newX < 0 )
				newX = 0;
			x = newX;
			
			if ( newY < 0 )
				newY = 0;
			y = newY;
			
			data.left = x;
			data.top = y;
		}
		
		protected function stage_mouseMoveHandlerExt( event : MouseEvent ) : void
		{
			dispatchEvent( new ElementEvent( ElementEvent.MOVED ) );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandlerExt );
		}
		
		protected function stage_mouseUpHandler( event : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
		}
		
		protected function skinnablecontainer1_creationCompleteHandler(event:FlexEvent):void
		{
			x = data.left; 
			y = data.top;
		}
		
	}
}
package net.vdombox.ide.modules.events.view.components
{
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.EventVO;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.view.EyeImage;
	
	import spark.components.SkinnableContainer;
	
	public class BaseElement extends SkinnableContainer
	{
		protected var _data : Object;
		
		[SkinPart( required="true" )]
		public var eye : EyeImage;
		
		[Bindable]
		public var title : String;
		
		protected var isNeedUpdateParameters : Boolean;
		
		private var mouseOffcetX : int;
		private var mouseOffcetY : int;
		
		
		public function BaseElement()
		{
			super();
		}
		
		public function get eyeOpened():Boolean
		{
			return _data.eyeOpened;
		}
		
		public function set eyeOpened(value:Boolean):void
		{
			_data.eyeOpened = value;
			
			eye.setOpenState(eyeOpened);
		}
		
		public function set visibleState(showHidden : Boolean):void
		{
			visible = showHidden ? true : eyeOpened;
		}
		
		public function get uniqueName() : String
		{
			if ( _data )
				return _data.name + _data.objectID;
			else
				return "";
		}
		
		public function get objectID() : String
		{
			if ( _data )
				return _data.objectID;
			else
				return "";
		}
		
		public function eyeClickHandler() : void
		{
			eyeOpened = !_data.eyeOpened;
			
			dispatchEvent( new ElementEvent ( ElementEvent.EYE_CLICKED ) );
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
			x = 0;
			else
			x = newX;
			
			if ( newY < 0 )
			y = 0;
			else
			y = newY;
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
			dispatchEvent( new ElementEvent ( ElementEvent.CREATE_ELEMENT ) );
		}
		
	}
}
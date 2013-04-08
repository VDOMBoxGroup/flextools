package net.vdombox.helpeditor.view.components
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.ui.Keyboard;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.core.Application;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	
	public class ResizableTitleWindow extends TitleWindow
	{
		// resize vars
		private const RESIZE_HANDLE_SIZE:int = 14;
		private var _resizable:Boolean;
		private var resizeInitX:Number = 0;
		private var resizeInitY:Number = 0;
		protected var minResizeWidth:Number = 24;
		protected var minResizeHeight:Number = 24;
		
		private var parentBoundsDistance : Number = 10;
		
		// move vars
		private const MOVE_HANDLE_SIZE:int = 10;
		private var _movable:Boolean;
		private var moveInitX:Number = 0;
		private var moveInitY:Number = 0;
		
		private var _resizeHandle:UIComponent;
		private var _moveHandle:UIComponent;
		private var _dotColor:uint = 0x666666;
		
		// store metrics vars : width, height, x, y
		public var shareId					: String;
		private var shObject				: SharedObject;
		
		public function ResizableTitleWindow() 
		{
			super();
			
			_resizable = false;
			_movable = false;
			
			// constrain to the application's bounds
			if (Application.application != null) {
				maxWidth = Application.application.width;
				maxHeight = Application.application.height;
			}
			
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			addEventListener(FlexEvent.INITIALIZE, initializeHandler);
			addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			addEventListener(CloseEvent.CLOSE, closeHandler);
		}
		
		protected function initializeHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.INITIALIZE, initializeHandler);
			
			if (shareId)
				shObject = SharedObject.getLocal( shareId );
		}
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			
			restoreWindowMetrics();
		}
		
		protected function closeHandler(cEvent:CloseEvent):void 
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			removeEventListener(CloseEvent.CLOSE, closeHandler);
			
			PopUpManager.removePopUp(this);
		}
		
		[Inspectable(category="General", defaultValue="0x666666", format="Color", name="Resize/Move handle color")]
		public function get dotColor():uint {
			return _dotColor;
		}
		
		public function set dotColor(color:uint):void {
			_dotColor = color;
			if (resizable || movable) {
				invalidateDisplayList();
			}
		} 
		
		private function get moveHandle():UIComponent {
			if (_moveHandle == null) {
				_moveHandle = new UIComponent();
				_moveHandle.width = 8;
				_moveHandle.height = 14;
			}
			return _moveHandle;
		}
		
		
		private function get resizeHandle():UIComponent {
			if (_resizeHandle == null) {
				_resizeHandle = new UIComponent();
				_resizeHandle.width = 14;
				_resizeHandle.height = 14;
			}
			return _resizeHandle;
		}
		
		[Inspectable(category="General")]
		
		public function get resizable():Boolean {
			return _resizable;
		}
		
		public function set resizable(resize:Boolean):void {
			if (resize != _resizable) {
				_resizable = resize;
				if (_resizable) {
					addEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
					setStyle("roundedBottomCorners", false);    // for the resize graphics
					// set a minimum size for this container
					if (minWidth < minResizeWidth) {
						minWidth = minResizeWidth;
					}
					if (minHeight < minResizeHeight) {
						minHeight = minResizeHeight;
					}
				} else {
					removeChild(resizeHandle);
					removeEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
				}
			}
		}
		
		[Inspectable(category="General")]
		public function get movable():Boolean {
			return _movable;
		}
		
		public function set movable(canMove:Boolean):void {
			if (canMove != _movable) {
				_movable = canMove;
				if (titleBar != null) {
					if (movable) {
						addMoveSupport();
					} else {
						removeMoveSupport();
					}
				}
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			if (movable) {
				addMoveSupport();
			}
		}
		
		private function addMoveSupport():void {
			if (titleBar) {
				titleBar.addChildAt(moveHandle, 0);
				titleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarMouseDown);
			}
		}
		
		private function removeMoveSupport():void {
			if (titleBar) {
				titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, titleBarMouseDown);
				titleBar.removeChild(moveHandle);
			}
		}
		
		protected function keyHandler(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ESCAPE) {
				escapePressed();
			} else if (event.keyCode == Keyboard.ENTER) {
				enterPressed();
			}
		}
		
		protected function escapePressed():void {
			close();
		}
		
		protected function enterPressed():void {
			close();
		}
		
		public function close(detail:uint = 0):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, false, false, detail));
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Draw resize handle                
			if (resizable) {
				drawResizeHandle(unscaledWidth, unscaledHeight);
			}
			if (movable) {
				drawMoveHandle(unscaledWidth, unscaledHeight);
			}
		}
		
		override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void {
			super.layoutChrome(unscaledWidth, unscaledHeight);
			
			if (movable && titleTextField) {
				// the move handle x position defaults to the title textfield's x value
				var moveX:Number = titleTextField.x;
				if (mx_internal::titleIconObject != null) {
					// shift the title icon over, and use it's x value for the move handle
					moveX = mx_internal::titleIconObject.x;
					mx_internal::titleIconObject.x += MOVE_HANDLE_SIZE;
				}
				moveHandle.move(moveX, titleTextField.y);
				titleTextField.x += MOVE_HANDLE_SIZE;
			}
		}
		
		
		/////////////////////
		// RESIZE SUPPORT
		/////////////////////
		
		// draws a 14x14 resize handle like in Windows
		protected function drawResizeHandle(unscaledWidth:Number, unscaledHeight:Number):void {
			// add last
			if (resizeHandle.parent == null) {
				rawChildren.addChild(resizeHandle);
			}
			
			var g:Graphics = resizeHandle.graphics;
			g.clear();
			if ((unscaledWidth >= RESIZE_HANDLE_SIZE) && (unscaledHeight > RESIZE_HANDLE_SIZE)) {
				var offset:int = 4;
				drawResizeDot(g, unscaledWidth - (offset + 8), unscaledHeight - offset);
				drawResizeDot(g, unscaledWidth - (offset + 4), unscaledHeight - offset);
				drawResizeDot(g, unscaledWidth - offset, unscaledHeight - offset);
				drawResizeDot(g, unscaledWidth - (offset + 4), unscaledHeight - (offset + 4));
				drawResizeDot(g, unscaledWidth - offset, unscaledHeight - (offset + 4));
				drawResizeDot(g, unscaledWidth - offset, unscaledHeight - (offset + 8));
			}
		}
		
		protected function drawResizeDot(g:Graphics, xx:Number, yy:Number):void {
			g.lineStyle(0, 0, 0);
			g.beginFill(dotColor);
			g.drawRect(xx, yy, 2, 2);
			g.endFill();
		}
		
		// draws a 7x7 resize handle
		private function drawResizeHandleOld(unscaledWidth:Number, unscaledHeight:Number):void {
			graphics.clear();
			if ((unscaledWidth >= 7) && (unscaledHeight > 7)) {
				graphics.lineStyle(2);
				graphics.moveTo(unscaledWidth - 6, unscaledHeight - 1);
				graphics.curveTo(unscaledWidth - 3, unscaledHeight - 3, unscaledWidth - 1, unscaledHeight - 6);
				graphics.moveTo(unscaledWidth - 6, unscaledHeight - 4);
				graphics.curveTo(unscaledWidth - 5, unscaledHeight - 5, unscaledWidth - 4, unscaledHeight - 6);
			}
		}
		
		// Resize panel event handler
		protected function resizeHandler(event:MouseEvent):void {
			// Determine if the mouse pointer is over the resize handle
			// Lower left corner of panel
			var lowerLeftX:Number = x + width; 
			var lowerLeftY:Number = y + height;
			
			// Upper left corner of 14x14 hit area
			var upperLeftX:Number = lowerLeftX - RESIZE_HANDLE_SIZE;
			var upperLeftY:Number = lowerLeftY - RESIZE_HANDLE_SIZE;
			
			// Mouse positio in Canvas
			var panelRelX:Number = event.localX + x;
			var panelRelY:Number = event.localY + y;
			
			// See if the mousedown is in the resize handle portion of the panel.
			if (upperLeftX <= panelRelX && panelRelX <= lowerLeftX) {
				if (upperLeftY <= panelRelY && panelRelY <= lowerLeftY) {
					event.stopPropagation();
					startResize(event.stageX, event.stageY);
				}
			}                
		}    
		
		protected function startResize(globalX:Number, globalY:Number):void {
			resizeInitX = globalX;
			resizeInitY = globalY;
			
			var distLargerWidth : Number = parent.width - (width + x); 
			maxWidth = width + distLargerWidth - parentBoundsDistance;
			
			var distLargerHeight : Number = parent.height - (height + y); 
			maxHeight = height + distLargerHeight - parentBoundsDistance;
			
			// Add event handlers so that the SystemManager handles the mouseMove and mouseUp events. 
			// Set useCapure flag to true to handle these events 
			// during the capture phase so no other component tries to handle them.
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMoveHandler, true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler, true);
		}
		
		// Resizes this panel as the user moves the cursor with the mouse key down.
		protected function resizeMouseMoveHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();
			
			var newWidth:Number = this.width + event.stageX - resizeInitX; 
			var newHeight:Number = this.height + event.stageY - resizeInitY;
			
			// restrict the width/height
			if ((newWidth >= minWidth) && (newWidth <= maxWidth)) {
				this.width = newWidth;
			}
			if ((newHeight >= minHeight) && (newHeight <= maxHeight)) {
				this.height = newHeight;
			}
			
			resizeInitX = event.stageX;
			resizeInitY = event.stageY;
		}
		
		// Removes the event handlers from the SystemManager.
		protected function resizeMouseUpHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();
			
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMoveHandler, true);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler, true);
			
			if (shObject)
				storeWindowMetrics();
		}
		
		private function storeWindowMetrics () : void
		{
			if (shObject)
			{
				shObject.data["width"] = width;
				shObject.data["height"] = height;
			}
				
		}
		
		public function restoreWindowMetrics () : void
		{
			if (shObject)
			{
				width = storedWindowMetric("width") || minWidth;
				if (width > parent.width - parentBoundsDistance)
					width = parent.width - parentBoundsDistance;
					
				height = storedWindowMetric("height") || minHeight;
				if (height > parent.height - parentBoundsDistance)
					height = parent.height - parentBoundsDistance;
			}
		}
		
		private function storedWindowMetric (metricType: String) : Number
		{
			if (!shObject)
				return NaN;
			
			if (shObject.data.hasOwnProperty(metricType))
				return Number(shObject.data[metricType])
				
			return NaN;
		}
		
		/////////////////////
		// MOVE SUPPORT
		/////////////////////
		
		// draws a 6x14 move/drag handle
		protected function drawMoveHandle(unscaledWidth:Number, unscaledHeight:Number):void {
			var g:Graphics = moveHandle.graphics;
			g.clear();
			var xx:int = 0;
			var yy:int = 4;
			for (var i:int = 0; i < 4; i++) {
				drawResizeDot(g, xx, yy + (i * 4));
				drawResizeDot(g, xx + 4, yy + (i * 4));
			}
		}
		
		private function titleBarMouseDown(event:MouseEvent):void {
			// special case - ignore if the target is a button (e.g. close button)
			if (event.target is Button) {
				return;
			}
			
			moveInitX = event.currentTarget.mouseX; 
			moveInitY = event.currentTarget.mouseY;
			
			parent.addEventListener(DragEvent.DRAG_ENTER, dragEnter);
			parent.addEventListener(DragEvent.DRAG_DROP, dragDrop);
			
			var ds:DragSource = new DragSource();
			ds.addData(this, 'ResizableTitleWindow'); 
			DragManager.doDrag(this, ds, event);  
		}
		
		private function dragEnter(event:DragEvent):void {
			if (event.target is IUIComponent) {
				DragManager.acceptDragDrop((event.target as IUIComponent));
			}
		}
		
		private function dragDrop(event:DragEvent):void {
			// Compensate for the mouse pointer's location in the title bar.
			var newX:int = event.currentTarget.mouseX - moveInitX;
			event.dragInitiator.x = newX;
			var newY:int = event.currentTarget.mouseY - moveInitY;
			event.dragInitiator.y = newY;
			
			// Put the dragged item on top of all other components.
			parent.setChildIndex((event.dragInitiator as DisplayObject), parent.numChildren - 1);
			
			parent.removeEventListener(DragEvent.DRAG_ENTER, dragEnter);
			parent.removeEventListener(DragEvent.DRAG_DROP, dragDrop);    
		}
		
	}
}
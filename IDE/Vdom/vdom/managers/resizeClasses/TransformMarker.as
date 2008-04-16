package vdom.managers.resizeClasses {

import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.containers.Canvas;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.managers.CursorManager;

import vdom.events.TransformMarkerEvent;
import vdom.managers.ResizeManager;

public class TransformMarker extends UIComponent {
	
	public static const RESIZE_NONE:String = '0';
	public static const RESIZE_WIDTH:String = '1';
	public static const RESIZE_HEIGHT:String = '2';
	public static const RESIZE_ALL:String = '3';
	
	private var tl_box:Sprite;
	private var tc_box:Sprite;
	private var tr_box:Sprite;
	private var cl_box:Sprite;
	private var cr_box:Sprite;
	private var bl_box:Sprite;
	private var bc_box:Sprite;
	private var br_box:Sprite;
	private var cc_box:Sprite;
	
	private var CursorID:uint
	
	private var moving:DisplayObject;
	
	private var _moveMode:Boolean;
	private var _resizeMode:String;
	
	private var _selectedItem:Container;
	
	private var mousePosition:Point;
	
	private var modeChanged:Boolean;
	private var boxStyleChanged:Boolean;
	private var itemChanged:Boolean;
	
	private var boxSize:int = 6;
	private var borderColor:uint;
	private var borderAlpha:Number;
	private var backgroundColor:uint
	private var backgroundAlpha:Number;
	
	private var transformation:Boolean;
	
	private var resizeManager:ResizeManager;
		
	public function TransformMarker(rm:ResizeManager) {
		
		super();
		
		/* addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); */
		
		resizeManager = rm;
		
		addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		addEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
	}
	
	public function get resizeMode():String {
		
		return _resizeMode;
	}
	
	public function set resizeMode(modeValue:String):void {
		
		if(_resizeMode != modeValue) {
			
			_resizeMode = modeValue;
			
			modeChanged = true;
			
			invalidateDisplayList();
		}
	}
	
	public function get moveMode():Boolean {
		
		return _moveMode;
	}
	
	public function set moveMode(modeValue:Boolean):void {
		
		_moveMode = modeValue;
		
		modeChanged = true;
			
		invalidateDisplayList();
	}
	
	public function get item():Container {
		
		return _selectedItem;
	}
	
	public function set item(item:Container):void {
		
		//trace('OBJECT CHANGE');
		if(item == null) {
			
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_selectedItem = null;
			return;
		}
		
		if(_selectedItem == item || transformation)
			return;
			
		_selectedItem = item;
		
		moving = this.cc_box;
		
		mousePosition = new Point(_selectedItem.mouseX, _selectedItem.mouseY);
		
		
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		item.addEventListener('refreshComplete', refreshCompleteHandler);
		
		//_selectedItem.addEventListener(FlexEvent.UPDATE_COMPLETE, selectedItem_updateCompleteHandler);
		
		var evt:TransformMarkerEvent = new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_BEGIN);
		
		var prop:Object = {
			left : _selectedItem.x,
			top : _selectedItem.y,
			width : _selectedItem.width,
			height : _selectedItem.height
		};
		
		evt.properties = prop;
		
		dispatchEvent(evt);
		
		itemChanged = true;
		
		invalidateDisplayList();
		invalidateSize();
		
		//_selectedItem.addEventListener(FlexEvent.UPDATE_COMPLETE, selectedItem_updateCompleteHandler);
		//invalidateProperties();
		
		
	}
	
	private function refreshCompleteHandler(event:Event):void {
		
		itemChanged = true;
		invalidateSize();
		invalidateDisplayList();
	}
	
	
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		cc_box = new Sprite();
		cc_box.name = 'cc';
		cc_box.buttonMode = true;
		
		tl_box = createBox("tl");
		tc_box = createBox("tc");
		tr_box = createBox("tr");
		cl_box = createBox("cl");
		cr_box = createBox("cr");
		bl_box = createBox("bl");
		bc_box = createBox("bc");
		br_box = createBox("br");
		
		
		this.addChild(cc_box);
		this.addChild(tl_box);
		this.addChild(tc_box);
		this.addChild(tr_box);
		this.addChild(cl_box);
		this.addChild(cr_box);
		this.addChild(bl_box);
		this.addChild(bc_box);
		this.addChild(br_box);
		
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if(boxStyleChanged) {
			
			boxSize         = this.getStyle("boxSize");
			borderColor     = this.getStyle("borderColor");
			//backgroundColor = this.getStyle("backgroundColor");
			backgroundAlpha = this.getStyle("backgroundAlpha")
			borderAlpha     = this.getStyle("borderAlpha");
			updateBoxes();
			boxStyleChanged = false;
		}
		
		if(modeChanged) {
			
			switch(_resizeMode) {
				
				case RESIZE_ALL:
					tl_box.visible = _moveMode;
					tc_box.visible = _moveMode;
					tr_box.visible = _moveMode;
					cl_box.visible = _moveMode;
					bl_box.visible = _moveMode;
					
					cr_box.visible = true;
					bc_box.visible = true;
					br_box.visible = true;
				break;
				
				case RESIZE_WIDTH:
					tl_box.visible = false;
					tc_box.visible = false;
					tr_box.visible = false;
					cl_box.visible = _moveMode;
					bl_box.visible = false;
					
					cr_box.visible = true;
					bc_box.visible = false;
					br_box.visible = false;
				break;
				
				case RESIZE_HEIGHT:
					tl_box.visible = false;
					tc_box.visible = _moveMode;
					tr_box.visible = false;
					cl_box.visible = false;
					bl_box.visible = false;
					
					cr_box.visible = false;
					bc_box.visible = true;
					br_box.visible = false;
				break;
				
				case RESIZE_NONE:
					tl_box.visible = false;
					tc_box.visible = false;
					tr_box.visible = false;
					cl_box.visible = false;
					cr_box.visible = false;
					bl_box.visible = false;
					bc_box.visible = false;
					br_box.visible = false;
				break;
			}
				
			cc_box.visible = _moveMode
		}
		
		if(itemChanged) {
			//trace(measuredWidth, measuredHeight);
			//measure();
			itemChanged = false
			
			tl_box.x = 0 + boxSize/2;
			tl_box.y = 0 + boxSize/2;
			tc_box.x = measuredWidth/2;
			tc_box.y = 0 + boxSize/2;
			tr_box.x = measuredWidth - boxSize/2;
			tr_box.y = 0 + boxSize/2;
			cl_box.x = 0 + boxSize/2;
			cl_box.y = measuredHeight/2;
			cr_box.x = measuredWidth - boxSize/2;
			cr_box.y = measuredHeight/2;
			bl_box.x = 0 + boxSize/2;
			bl_box.y = measuredHeight - boxSize/2;
			bc_box.x = measuredWidth/2;
			bc_box.y = measuredHeight - boxSize/2;
			br_box.x = measuredWidth - boxSize/2;
			br_box.y = measuredHeight - boxSize/2;
			cc_box.x = 0 + boxSize/2;
			cc_box.y = 0 + boxSize/2;
			
			var g:Graphics = cc_box.graphics;
			g.clear();
			g.lineStyle(6, 0x333333, .0, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			/* if(_resizeMode == RESIZE_NONE)
				g.beginFill(0xffffff, .0); */
			g.drawRect(0, 0, measuredWidth-6, measuredHeight-6);
			g.endFill();
			
			graphics.clear();			
			graphics.lineStyle(1, 0, 1, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);
			graphics.drawRect(0, 0, measuredWidth, measuredHeight);
			graphics.endFill();
		
		}
	}
	
	override protected function measure():void {
		
		super.measure();
		//trace('measure');
		measuredMinHeight = minHeight;
		measuredMinWidth  = minWidth;
		
		//var bm:EdgeMetrics =  Canvas(item.parent).viewMetricsAndPadding;
		
		if(_selectedItem) {
			
			var rect:Rectangle = _selectedItem.getRect(_selectedItem.parent)
			
			measuredWidth  = _selectedItem.width;
			measuredHeight = _selectedItem.height;
			
			var rectangle:Rectangle = getContentRectangle(_selectedItem, this);
			
			//var parent:Object = this.parent;
			//var proxyOrigin:Point = new Point();
			//proxyOrigin = _selectedItem.parent.localToGlobal(
				//new Point(_selectedItem.x, _selectedItem.y));
				
			//proxyOrigin = parent.globalToLocal(proxyOrigin);
			
			move(rectangle.x, rectangle.y);
			//dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
			
			//x = rectangle.x; //rect.x - bm.left;
			//y = rectangle.y; //rect.y - bm.top;
			
		} else {
			//trace('==else')
			//measuredWidth  = maxWidth;
			//measuredHeight = maxHeight;
		}
	}
	
	protected function updateBoxes():void {
		
		graphics.clear();
		graphics.beginFill(backgroundColor, backgroundAlpha);
		graphics.lineStyle(.25, borderColor, 1, true, LineScaleMode.NONE);
		graphics.drawRect(0,0, measuredWidth, measuredHeight);
		graphics.endFill();
	}
	
	protected function createBox(name:String):Sprite {
		
		var b:Sprite = new Sprite();
		b.graphics.beginFill(0xFFFFFF, 1)
		b.graphics.lineStyle(1, 0x00, 1, true, LineScaleMode.NONE);
		b.graphics.drawRect(-boxSize/2, -boxSize/2, boxSize, boxSize);
		b.graphics.endFill();
		b.buttonMode = true
		b.useHandCursor = false;
		b.name = name
		return b;
	}
	
	private function getContentRectangle(sourceContainer:DisplayObject, destinationContainer:DisplayObject):Rectangle {
		
		var pt:Point = new Point(sourceContainer.x, sourceContainer.y);
		var sc:Container = Container(sourceContainer.parent);
		var dc:Container = Container(destinationContainer.parent);
		pt = sc.contentToGlobal(pt);
		pt = dc.globalToContent(pt);
		
		return new Rectangle(pt.x, pt.y, measuredWidth, measuredHeight);
	}
	
	private function mouseDownHandler(event:MouseEvent):void {
		//trace('resbeg');
		
		trace('TransformMarker MD');
		resizeManager.itemTransform = true;
		var rmEvent:TransformMarkerEvent = new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_BEGIN);
		
		var prop:Object = {
			left : _selectedItem.x,
			top : _selectedItem.y,
			width : _selectedItem.width,
			height : _selectedItem.height
		};
		
		rmEvent.properties = prop;
		
		dispatchEvent(rmEvent);
		
		moving = null;
		mousePosition = new Point(mouseX, mouseY);
		
		if(event.target != this)
			moving = DisplayObject(event.target);
		else
			moving = this;
		
		transformation = true;
		
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		
		//event.stopImmediatePropagation();
	}
	
	private function mouseOutHandler(event:MouseEvent):void {
		
		if(_selectedItem)			
			if(!moving){				
				CursorManager.removeAllCursors();
				dispatchEvent(new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_MARKER_UNSELECTED));
			}
	}		
	
	private function mouseOverHandler(event:MouseEvent):void {
		
		if(_selectedItem) {
			
			var target:Sprite = Sprite(event.target);
			CursorManager.removeAllCursors();
			var markerSelected:Boolean = true;
			
			switch(target.name) {
				
				case "bc":
				case "tc":
					CursorID = CursorManager.setCursor(getStyle('topDownCursor'), 2, -6, -8);
				break;
				
				case "cl":
				case "cr":
					CursorID = CursorManager.setCursor(getStyle('leftRightCursor'), 2, -8, -4);
				break;
				
				case "tl":
				case "br":
					CursorID = CursorManager.setCursor(getStyle('topLDownRCursor'), 2, -8, -6);
				break;
				
				case "tr":
				case "bl":
					CursorID = CursorManager.setCursor(getStyle('topRDownLCursor'), 2, -6, -10);
				break;
				
				case "cc":
					CursorID = CursorManager.setCursor(getStyle('moveCursor'), 2, -10, -10);
				break;
				default:
					markerSelected = false;
				break
			}
			
			if(markerSelected)
				dispatchEvent(new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_MARKER_SELECTED));
			else
				dispatchEvent(new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_MARKER_UNSELECTED));
		}
	}		
	
	private function mouseUpHandler(event:MouseEvent):void {
		
		Application.application.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		Application.application.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		
		
		var evt:TransformMarkerEvent = new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_CHANGING);
		dispatchEvent(evt);
		
		moving = null;
		mousePosition = null;
		mouseOutHandler(null);
		transformation = false;		
		//destroyToolTip();
		
		var rectangle:Rectangle = getContentRectangle(this, _selectedItem);
		
		//_selectedItem.x = rectangle.x;
		//_selectedItem.y = rectangle.y;
		//_selectedItem.width  = rectangle.width; //measuredWidth;
		//_selectedItem.height = rectangle.height; //measuredHeight;
		
		var prop:Object = {
			left : rectangle.x,
			top : rectangle.y,
			width : rectangle.width,
			height : rectangle.height
		};
		
		var rmEvent:TransformMarkerEvent = new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_COMPLETE);
		rmEvent.item = _selectedItem;
		rmEvent.properties = prop;
		dispatchEvent(rmEvent);
		resizeManager.itemTransform = false;
		//trace('TM mouseUpHandler');
		//event.stopImmediatePropagation();
		//event.stopPropagation();
	}
	
	
	
	private function mouseMoveHandler(event:MouseEvent):void {
		
		//CursorManager.removeAllCursors();
		if(itemChanged)
			return;
		
		var rect:Rectangle = new Rectangle(x, y, measuredWidth, measuredHeight);
		var rect1:Rectangle = getContentRectangle(this, _selectedItem);
		var rect2:Rectangle = getContentRectangle(_selectedItem.parent, this);
		var allow:Boolean = true;
		
		if(moving && event.buttonDown) {
			
			//var onlyMove:Boolean = false;
			
			var mx:Number = mouseX;
			var my:Number = mouseY;
			
			switch(moving.name) {
				
				case "br":
					rect.width = mouseX;
					rect.height = mouseY;
				break;
				
				case "bc":
					rect.height = mouseY;	
				break;
				
				case "bl":
					if(rect1.x + mx < 0) {rect.width += 0; rect.x = _selectedItem.parent.x;}
						else {rect.x += mx; rect.width -= mx;}	
					rect.height = mouseY;	
				break;
				
				case "cr":
					rect.width = mouseX;	
				break;
				
				case "cl":
					if(rect1.x + mx < 0) {rect.width += 0; rect.x = _selectedItem.parent.x;}
						else {rect.x += mx; rect.width -= mx;}
				break;
				
				case "tl":
					if(rect1.x + mx < 0) {rect.width += 0; rect.x = _selectedItem.parent.x;}
						else {rect.x += mx; rect.width -= mx;}			
					if(rect1.y + my < 0) {rect.height += 0; rect.y = _selectedItem.parent.y;}
						else {rect.y += my; rect.height -= my;}		
				break;
					
				case "tc":
					if(rect1.y + my < 0) {rect.height += 0; rect.y = _selectedItem.parent.y;}
						else {rect.y += my; rect.height -= my;}
				break;
				
				case "tr":
					rect.width = mouseX;
					if(rect1.y + my < 0) {rect.height += 0; rect.y = _selectedItem.parent.y;}
						else {rect.y += my; rect.height -= my;}		
				break;
				
				case "cc":
					if(rect1.x + mx - mousePosition.x < 0) {
						rect.x = rect2.x;
						rect1.x = 0;
					} else {
						rect.x += mx - mousePosition.x;
						rect1.x += mx - mousePosition.x;
					}				
					if(rect1.y + my - mousePosition.y < 0) {
						rect.y = rect2.y;
						rect1.y = 0;
					} else {
						rect.y += my - mousePosition.y;
						rect1.y += my - mousePosition.y;
					}
					//onlyMove = true;
				break;
			}
			
			if(rect.width > maxWidth || rect.width < minWidth) allow = false;
			if(rect.height > maxHeight || rect.height < minHeight) allow = false;
			
			if(rect) {
				
				if(rect.width > maxWidth)   rect.width = maxWidth;
				if(rect.width < minWidth)   rect.width = minWidth;
				if(rect.height > maxHeight) rect.height = maxHeight;
				if(rect.height < minHeight) rect.height = minHeight;
				
				if(allow) {
					
					//trace(mouseX)
					
					//var evt:TransformMarkerEvent = new TransformMarkerEvent(TransformMarkerEvent.TRANSFORM_BEGIN);		
					//dispatchEvent(evt);
					
					move(rect.x, rect.y);
					
					if(_moveMode) {
						
						_selectedItem.x = rect1.x;
						_selectedItem.y = rect1.y;
					}
					
					itemChanged = true;
					
					measuredWidth = rect.width;
					measuredHeight = rect.height;
				}
			}
			
			/* if(tip)
			{
				tip.visible = true;
				tip.x = stage.mouseX + 15;
				tip.y = stage.mouseY +15;
				tip.text = measuredWidth.toString()+"x"+measuredHeight.toString();
			} */
			
			// finally dispatch event
			/* var evt:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_CHANGING);
			
			dispatchEvent(evt); */		
								
			//event.updateAfterEvent();
			invalidateDisplayList();
			
		} else {
			
			mouseUpHandler(null);
		} 
	}
	
	/* private function selectedItem_updateCompleteHandler(event:FlexEvent):void {
		trace('SOURCE OBJECT CHANGE');
		invalidateSize();
		invalidateDisplayList();
	} */
}
}
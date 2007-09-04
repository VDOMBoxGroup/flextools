package vdom.components.editor.managers {
	
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import mx.events.ResizeEvent;
import mx.core.EdgeMetrics;
import mx.core.UIComponent;
import mx.containers.Canvas;
import mx.controls.ToolTip;
import mx.managers.CursorManager;
import mx.managers.ToolTipManager;
import mx.styles.StyleManager;
import mx.styles.CSSStyleDeclaration;

import vdom.components.editor.events.ResizeManagerEvent;
			
[Event(name="RESIZE_COMPLETE", type="vdom.events.ResizeManagerEvent")]

[Style(name="boxSize", type="Number", format="Number", inherit="no")]

[Inspectable(name="minWidth", verbose=1)]	
[Inspectable(name="maxWidth", verbose=1)]	
[Inspectable(name="minHeigh", verbose=1)]	
[Inspectable(name="maxHeigh", verbose=1)]	

[IconFile("ResizeTool.png")]

public class ResizeManager extends UIComponent {
	
	public static const RESIZE_NONE:String = 'resize_none';
	public static const RESIZE_WIDTH:String = 'resize_width';
	public static const RESIZE_HEIGHT:String = 'resize_height';
	public static const RESIZE_ALL:String = 'resize_all';
	
	[Embed(source="/assets/resizeTool/up_down.png")]
	private var verticalCursorClass:Class;
	[Embed(source="/assets/resizeTool/left_right.png")]
	private var horizontalCursorClass:Class;
	[Embed(source="/assets/resizeTool/tl_dr.png")]
	private var tlCursorClass:Class;
	[Embed(source="/assets/resizeTool/tr_dl.png")]
	private var trCursorClass:Class;
	[Embed(source="/assets/resizeTool/move.png")]
	private var ccCursorClass:Class;
	
	private static var classConstructed:Boolean = classConstruct();
	private var CursorID:uint		
			
	private var moving:DisplayObject;
	private var movingItem:DisplayObject;
	private var mItemChanged:Boolean;
	private var modeChanged:Boolean;
	private var bStyleChanged:Boolean
	private var boxSize:int = 6;
	private var borderColor:uint;
	private var borderAlpha:Number;
	private var backgroundColor:uint
	private var backgroundAlpha:Number;
	private var tip:ToolTip;
	private var tl_box:Sprite;
	private var tc_box:Sprite;
	private var tr_box:Sprite;
	private var cl_box:Sprite;
	private var cr_box:Sprite;
	private var bl_box:Sprite;
	private var bc_box:Sprite;
	private var br_box:Sprite;
	private var cc_box:Sprite;
	private var mousePosition:Point;
	private var markerName:String;
	private var _resizeMode:String;
	private var _moveMode:Boolean;
	
	public function ResizeManager() {
		
		super();
		this.addEventListener(MouseEvent.MOUSE_DOWN, down_handler);
		this.addEventListener(ResizeManagerEvent.RESIZE_CHANGING, changingHandler)
		this.addEventListener(MouseEvent.MOUSE_OVER, over_handler);
		this.addEventListener(MouseEvent.MOUSE_OUT,  out_handler);
		modeChanged = false;
		_resizeMode = RESIZE_ALL;
		_moveMode = false;
	}
	
	
	private static function classConstruct():Boolean 
	{
		if (!StyleManager.getStyleDeclaration("ResizeManager")) {
			var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
			newStyleDeclaration.setStyle("boxSize", 6);
			//newStyleDeclaration.setStyle("backgroundColor", 0xFFFFFF);
			newStyleDeclaration.setStyle("borderColor", 0xff0000);
			newStyleDeclaration.setStyle("borderAlpha", 0.0);
			newStyleDeclaration.setStyle("backgroundAlpha", .9);
			StyleManager.setStyleDeclaration("ResizeManager", newStyleDeclaration, true);
		}
		return true;
	}
	
	
	
	private function down_handler(e:MouseEvent):void {
		moving = null;
		mousePosition = new Point(mouseX, mouseY);
		if(e.target != this)
		{
			moving = DisplayObject(e.target);
			createToolTip();
		} else {
			moving = this;
		}
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, move_handler);			
		this.stage.addEventListener(MouseEvent.MOUSE_UP, up_handler);
	}
	
	private function out_handler(e:MouseEvent):void {
		if(item)
		{
			if(!moving)
			{
				CursorManager.removeAllCursors()
			}
		}
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
	}
	
	private function over_handler(e:MouseEvent):void {
		if(item)
		{
			var target:Sprite = Sprite(e.target);
			CursorManager.removeAllCursors();
			//trace(target);
			switch(target.name)
			{
				case "bc":
				case "tc":
					CursorID = CursorManager.setCursor(verticalCursorClass, 2, -6, -8);
					break;
				case "cl":
				case "cr":
					CursorID = CursorManager.setCursor(horizontalCursorClass, 2, -8, -4);
					break;
				case "tl":
				case "br":
					CursorID = CursorManager.setCursor(tlCursorClass, 2, -8, -6);
					break;
				case "tr":
				case "bl":
					CursorID = CursorManager.setCursor(trCursorClass, 2, -6, -10);
					break;
				case "cc":
					CursorID = CursorManager.setCursor(ccCursorClass, 2, -10, -10);
					break;
				default:
					break;
			}
		}
	}		
	
	private function up_handler(event:MouseEvent):void
	{
		var evt:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_CHANGING);
		//trace('asdasdasd');
		
			
		dispatchEvent(evt);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, up_handler);
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, move_handler);
		moving = null;
		mousePosition = null;
		out_handler(null);			
		destroyToolTip();
		//trace('resizeCompl');
		
		var prop:Object = {};
		prop['left'] = x;
		prop['top'] = y;
		prop['width'] = measuredWidth;
		prop['height'] = measuredHeight;
		
		var rmEvent:ResizeManagerEvent = new ResizeManagerEvent(ResizeManagerEvent.RESIZE_COMPLETE);
		rmEvent.properties = prop;
		dispatchEvent(rmEvent);
		event.stopImmediatePropagation();
	}
	
	private function createToolTip():void
	{
		tip = ToolTip(ToolTipManager.createToolTip("", 0, 0, null, this));
		tip.setStyle("backgroundColor", 0xFFFFFF);
		tip.setStyle("fontSize", 9);
		tip.setStyle("cornerRadius", 0);
		tip.visible = false;
	}
	
	private function destroyToolTip():void
	{
		if(tip)
		{
			ToolTipManager.destroyToolTip(tip);
			tip = null;
		}
	}
	
	private function move_handler(event:MouseEvent):void
	{
		CursorManager.removeAllCursors();
		var rect:Rectangle= new Rectangle(x, y, measuredWidth, measuredHeight);
		var allow:Boolean = true;
		if(moving && event.buttonDown)
		{
			var bm:EdgeMetrics =  Canvas(item.parent).borderMetrics;
			
			/* var itemX:Number = item.x;
			var itemY:Number = item.y;
			
			var itemXRight:Number = itemX + item.width;
			var itemYBottom:Number = itemY + item.height;
			
			var contWidth:Number = item.parent.width;
			var contHeight:Number = item.parent.height; */
			
			var mx:Number = mouseX;
			var my:Number = mouseY;
			
			switch(moving.name)
			{
				case "br":
					rect.width = mouseX;
					rect.height = mouseY;
					
					break;
				case "bc":
					rect.height = mouseY;
					
					break;
				case "bl":
					if(rect.x + mx < 0) {rect.width += rect.x; rect.x = 0;}
						else {rect.x += mx; rect.width -= mx;}	
					rect.height = mouseY;
					
					break;
				case "cr":
					rect.width = mouseX;
					
					break;
				case "cl":
					if(rect.x + mx < 0) {rect.width += rect.x; rect.x = 0;}
						else {rect.x += mx; rect.width -= mx;}

					break;
				case "tl":
					if(rect.x + mx < 0) {rect.width += rect.x; rect.x = 0;}
						else {rect.x += mx; rect.width -= mx;}			
					if(rect.y + my < 0) {rect.height += rect.y; rect.y = 0;}
						else {rect.y += my; rect.height -= my;}
						
					break;
				case "tc":
					if(rect.y + my < 0) {rect.height += rect.y; rect.y = 0;}
						else {rect.y += my; rect.height -= my;}

					break;
				case "tr":
					rect.width = mouseX;
					if(rect.y + my < 0) {rect.height += rect.y; rect.y = 0;}
						else {rect.y += my; rect.height -= my;}
						
					break;
				case "cc":
					if(rect.x + mx - mousePosition.x < 0) {rect.x = 0;}
						else {rect.x += mx - mousePosition.x;}				
					if(rect.y + my - mousePosition.y < 0) {rect.y = 0;}
						else {rect.y += my - mousePosition.y;}

					break;
				default:
					break;
			}
			
			if(rect.width > maxWidth || rect.width < minWidth) allow = false;
			if(rect.height > maxHeight || rect.height < minHeight) allow = false;
			
			if(rect)
			{
				
				if(rect.width > maxWidth)   rect.width = maxWidth
				if(rect.width < minWidth)   rect.width = minWidth
				if(rect.height > maxHeight) rect.height = maxHeight
				if(rect.height < minHeight) rect.height = minHeight
				if(allow)
				{
					move(rect.x, rect.y);
					measuredHeight = rect.height;
					measuredWidth  = rect.width;			
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
								
			event.updateAfterEvent();
			invalidateDisplayList()
		} else {
			up_handler(null);
		} 
	}
	
	override protected function createChildren():void
	{
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
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if(bStyleChanged){
			boxSize         = this.getStyle("boxSize");
			borderColor     = this.getStyle("borderColor");
			//backgroundColor = this.getStyle("backgroundColor");
			backgroundAlpha = this.getStyle("backgroundAlpha")
			borderAlpha     = this.getStyle("borderAlpha");
			updateBoxes();
			bStyleChanged = false;
		}
		
		if(modeChanged){
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
		
		if(mItemChanged){
			measure();
			mItemChanged = false
		}
		tl_box.x = 0;
		tl_box.y = 0;
		tc_box.x = measuredWidth/2
		tc_box.y = 0;
		tr_box.x = measuredWidth;
		tr_box.y = 0;
		cl_box.x = 0;
		cl_box.y = measuredHeight/2;
		cr_box.x = measuredWidth;
		cr_box.y = measuredHeight/2;
		bl_box.x = 0;
		bl_box.y = measuredHeight;
		bc_box.x = measuredWidth/2;
		bc_box.y = measuredHeight;
		br_box.x = measuredWidth;
		br_box.y = measuredHeight;
		cc_box.x = 0;
		cc_box.y = 0;
		
		var g:Graphics = cc_box.graphics;
		g.clear();
		g.lineStyle(getStyle('boxSize'), 0, .0, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		g.drawRect(0, 0, measuredWidth, measuredHeight);
		g.endFill();
		graphics.clear();			
		//graphics.beginFill(backgroundColor, backgroundAlpha);
		graphics.lineStyle(1, 0, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		graphics.drawRect(0, 0, measuredWidth, measuredHeight);
		//graphics.lineStyle(this.getStyle('boxSize'), borderColor, borderAlpha, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		//graphics.drawRect(0, 0, measuredWidth, measuredHeight);
		graphics.endFill();

	}
	
	override protected function commitProperties():void
	{
		super.commitProperties();
	}
	
	override protected function measure():void
	{
		//trace('measure');
		super.measure();
		measuredMinHeight = minHeight;
		measuredMinWidth  = minWidth;
		
		var bm:EdgeMetrics =  Canvas(item.parent).viewMetricsAndPadding;
		
		if(item)
		{
			//trace(this.parent);	
			var rect:Rectangle = item.getRect(movingItem.parent)
			measuredWidth  = item.width;
			measuredHeight = item.height;
			x = item.x; //rect.x - bm.left;
			y = item.y; //rect.y - bm.top;
			//trace([rect.x, rect.y]);
			//trace([x, y, item.x, item.y]);
		} else {
			measuredWidth  = maxWidth;
			measuredHeight = maxHeight;
		}
	}
			
	override public function styleChanged(styleProp:String):void {
		super.styleChanged(styleProp);
		bStyleChanged = true;
		invalidateDisplayList()
	}
	
	protected function updateBoxes():void
	{
		graphics.clear();
		graphics.beginFill(backgroundColor, backgroundAlpha);
		graphics.lineStyle(.25, borderColor, 1, true, LineScaleMode.NONE);
		graphics.drawRect(0,0, measuredWidth, measuredHeight);
		graphics.endFill();
	}
	
	
	protected function changingHandler(e:ResizeManagerEvent):void {
		//var pt:Point = new Point(x,y)
		//pt = item.globalToLocal(pt)
		
		item.x = x;
		item.y = y;
		item.width  = measuredWidth;
		item.height = measuredHeight;
	}
	
	protected function createBox(name:String):Sprite {
		var b:Sprite = new Sprite();
		b.graphics.beginFill(0xFFFFFF, 1)
		b.graphics.lineStyle(1, 0x00, 1, true, LineScaleMode.NONE);
		b.graphics.drawRect(-boxSize/2,-boxSize/2, boxSize, boxSize);
		b.graphics.endFill();
		b.buttonMode = true
		b.name = name
		return b;
	}
	
	
	[Inspectable(verbose=1)]
	public function set item(s:DisplayObject):void {
		movingItem = s;
		mItemChanged = true;
		
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}
	
	public function get item():DisplayObject {
		return movingItem;
	}
}
}
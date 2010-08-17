package view
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import org.aswing.Component;
	import org.aswing.EditableComponent;
	import org.aswing.Viewportable;
	import org.aswing.event.InteractiveEvent;
	import org.aswing.geom.IntDimension;
	import org.aswing.geom.IntPoint;
	import org.aswing.geom.IntRectangle;
	
	import ro.victordramba.scriptarea.ScriptAreaEvents;
	
	public class ScriptAreaComponent extends Component implements EditableComponent, Viewportable
	{
		private var area:ScriptAreaEvents;
		private var viewportSizeTesting:Boolean = false;
		private var lineNums:LineNumbers;
		
		
		public function ScriptAreaComponent()
		{
			super();
			
			area = new ScriptAreaEvents;
			addChild(area);
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
				stage.focus = area;
			});
			
//			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:Event):void {
//				e.preventDefault();
//			});
			
			area.addEventListener(Event.SCROLL, function(e:Event):void {
		    	if(viewportSizeTesting)
		    		return;
				if (viewPos.y != area.scrollY)
				{
					viewPos.y = area.scrollY;
					updateNums();
					fireStateChanged(true);
				}
			});
			
			area.addEventListener(Event.CHANGE, function(e:Event):void {
				revalidate();
			});
			
			lineNums = new LineNumbers(area.boxSize, area.textFormat);
			lineNums.y = 2;
			addChild(lineNums);
			lineNums.addEventListener(MouseEvent.MOUSE_DOWN, area.onMouseDown);
		}
		
		public function markLines(lines:Array/*of int*/, tips:Array/*of String*/, color:uint=0xff0000):void
		{
			lineNums.mark(lines, tips, color);
		}
		
	    override public function getInternalFocusObject():InteractiveObject
	    {
	    	return area;
	    }
	    
		public function isEditable():Boolean
		{
			return true;
		}
		
		public function setEditable(value:Boolean):void
		{
			
		}
		
		override protected function paint(b:IntRectangle) : void
		{
			super.paint(b);
			area.x = area.boxSize.x * 5;
			area.y = b.y;
			area.width = 1500;
			area.height = b.height-1;
			//scroll
			area.scrollRect = new Rectangle(viewPos.x, 0, width, height);
			area.scrollY = viewPos.y;
			updateNums();
		}
		
		private function updateNums():void
		{
			lineNums.draw(area.scrollY, area.height/area.boxSize.y, 100000);
		}
		
		public function get scrollH():int
		{
			return -viewPos.x;
		}
		
		
		public function clearFormatRuns():void
		{
			area.clearFormatRuns();
		}
		
		public function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:String):void
		{
			area.addFormatRun(beginIndex, endIndex, bold, italic, color);
		}
		
		
		public function applyFormatRuns():void
		{
			area.applyFormatRuns();
		}
		
		public function get caretIndex():int
		{
			return area.caretIndex;
		}

		public function get selectionBeginIndex():int
		{
			return area.selectionBeginIndex;
		}
		
		public function get selectionEndIndex():int
		{
			return area.selectionEndIndex;
		}
		
		public function getPointForIndex(index:int):Point
		{
			var p:Point = area.getPointForIndex(index);
			p.offset(lineNums.width, 0);
			return p;
		}
		
		
		public function set text(text:String):void
		{
			area.text = text;
			revalidate();
		}
		
		public function get text():String
		{
			return area.text;
		}
		
		public function replaceText(startIndex:int, endIndex:int, text:String):void
		{
			area.replaceText(startIndex, endIndex, text);
		}
		
		public function setSelection(beginIndex:int, endIndex:int):void
		{
			area.setSelection(beginIndex, endIndex);
		}


//------------------------------------------------------------------------------------
// Viewportable
//------------------------------------------------------------------------------------

	    public function getVerticalUnitIncrement():int
	    {
	    	return 1;
	    }
	    
	    public function getVerticalBlockIncrement():int
	    {
	    	return 10;
	    }
	    
	    public function getHorizontalUnitIncrement():int
	    {
	    	return area.boxSize.x;
	    }
	    
	    public function getHorizontalBlockIncrement():int
	    {
	    	return area.boxSize.x * 10;
	    }
	    
	    public function setVerticalUnitIncrement(increment:int):void { }
	    public function setVerticalBlockIncrement(increment:int):void { }
	    public function setHorizontalUnitIncrement(increment:int):void { }
	    public function setHorizontalBlockIncrement(increment:int):void { }
	           
	    public function setViewportTestSize(s:IntDimension):void
	    {
	    	viewportSizeTesting = true;
	    	setSize(s);
	    	paintImmediately();
	    	viewportSizeTesting = false;
	    }
	    
	    public function getExtentSize():IntDimension
	    {
	    	return new IntDimension(width, Math.ceil(height/area.boxSize.y));
	    }
	    
	    public function getViewSize():IntDimension
	    {
	    	return new IntDimension(1500, area.maxscroll + Math.ceil(height/area.boxSize.y));
	    }
	    
	    public function getViewPosition():IntPoint
	    {
	    	return new IntPoint(viewPos.x, viewPos.y);
	    }
	    
	    public function setViewPosition(p:IntPoint, programmatic:Boolean=true):void
	    {
			if(!viewPos.equals(p))
			{
				//restrictionViewPos(p);
				if(viewPos.equals(p)){
					return;
				}
				viewPos.setLocation(p);
				repaint();
				//debug('p.y='+p.y);
				fireStateChanged(programmatic);
			}
	    }
	    
	    public function scrollRectToVisible(contentRect:IntRectangle, programmatic:Boolean=true):void
	    {
			setViewPosition(new IntPoint(contentRect.x, contentRect.y), programmatic);
	    }
	    
	    private var validateTID:int;
	    
	    
		protected function fireStateChanged(programmatic:Boolean=true):void
		{
			dispatchEvent(new InteractiveEvent(InteractiveEvent.STATE_CHANGED, programmatic));
		}
	    
	    
		public function addStateListener(listener:Function, priority:int=0, useWeakReference:Boolean=false):void
		{
			addEventListener(InteractiveEvent.STATE_CHANGED, listener, false, priority);
		}
		public function removeStateListener(listener:Function):void
		{
			removeEventListener(InteractiveEvent.STATE_CHANGED, listener);
		}
	
	    public function getViewportPane():Component { return this }
	    
	    private var viewPos:IntPoint = new IntPoint;
		
	}
}
package DiagramAPI.com.baseClasses
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.Container;
import mx.core.UIComponent;
import mx.events.ResizeEvent;

public class InteractiveContext extends EventDispatcher
{
	public static var movingObj:UIComponent;
	
	public var target:UIComponent;
	
	public function InteractiveContext(displayObject:UIComponent)
	{
		super();
		
		target = displayObject;
		
    	target.addEventListener(MoveEvent.MOVE_STARTING, startingMoveHandler);		
    	target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        target.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        target.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);				
        target.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
        target.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);				
	}
	
	public function removeContext():void
	{
    	target.removeEventListener(MoveEvent.MOVE_STARTING, startingMoveHandler);		
    	target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        target.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        target.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);				
        target.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler);
        target.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);				
	}

 	public var isSnapped:Boolean;
 	public var snappedToObject:Object = {object:null, point:null, flags:null};
 	public var isMovable:Boolean;
 	
    private var _isMoving:Boolean;
    private var _stopMovingMouseEvent:String = MouseEvent.MOUSE_UP;

    private var _regX:Number;
    private var _regY:Number;
    private var _regStopMovingMouseEvent:String;
    
    //----------------------------------
    //  over
    //----------------------------------
    		
	private var _over:Boolean;
	
    public function get over():Boolean
    {
        return _over;
    }

    //----------------------------------
    //  focused
    //----------------------------------
    		
	private var _focused:Boolean;
	
    public function get focused():Boolean
    {
    	if(target.getFocus()==target)
    		_focused = true;
    	else 
    		_focused = false;
    	
        return _focused;
    }
    
	public function get centerX():Number
	{
		return target.x + target.getExplicitOrMeasuredWidth()/2;
	}
	public function set centerX(value:Number):void
	{
		target.x = value - target.getExplicitOrMeasuredWidth()/2;
	}

	public function get centerY():Number
	{
		return target.y + target.getExplicitOrMeasuredHeight()/2;
	}	
	public function set centerY(value:Number):void
	{
		target.y = value - target.getExplicitOrMeasuredHeight()/2;
	}	

	public function get center():Point
	{
		return new Point(centerX, centerY);
	}	
	public function set center(value:Point):void
	{
		centerX = value.x;
		centerY = value.y;
	}
	
	public function bringToFront():void
	{
        // Make sure a parent container exists.
        if(target.parent)
        {
        	try {
           		if (target.parent.getChildIndex(target) < target.parent.numChildren-1)
	   		   		target.parent.setChildIndex(target, target.parent.numChildren-1);
           	} catch(e:*) {
	        	Container(target.parent).rawChildren.setChildIndex(target,
	        		Container(target.parent).rawChildren.numChildren-1) 
           	}
        }		 
	}
	
	public static const LEFT:int = 1;
	public static const TOP:int = 1<<1;
	public static const RIGHT:int = 1<<2;
	public static const BOTTOM:int = 1<<3;

	public function snapTo(object:UIComponent, point:Point=null, flags:int=0):void
	{
		unsnap();
		
       	snappedToObject.object = object;
       	snappedToObject.point = point;
       	snappedToObject.flags = flags==0 ? TOP&LEFT : flags;
       	isSnapped = true;
       	
       	if(object)
       	{
       		//object.addEventListener(Event.ENTER_FRAME, snapTargetUpdatedHandler); 
       		object.addEventListener(ResizeEvent.RESIZE, snapTargetUpdatedHandler); 
       		object.addEventListener("xChanged", snapTargetUpdatedHandler);
       		object.addEventListener("yChanged", snapTargetUpdatedHandler);
       		object.addEventListener(Event.REMOVED, snapTargetUpdatedHandler);
       	}
       	
       	moveToPoint(object, point);
	}

	public function unsnap():void
	{
		if(snappedToObject.object)
		{
       		//snapToObject.object.removeEventListener(Event.ENTER_FRAME, snapTargetUpdatedHandler); 
       		snappedToObject.object.removeEventListener(ResizeEvent.RESIZE, snapTargetUpdatedHandler); 
       		snappedToObject.object.removeEventListener("xChanged", snapTargetUpdatedHandler);
       		snappedToObject.object.removeEventListener("yChanged", snapTargetUpdatedHandler);
       		snappedToObject.object.removeEventListener(Event.REMOVED, snapTargetUpdatedHandler);
  		}

       	snappedToObject.object = null;
       	snappedToObject.point = null;
       	snappedToObject.flags = null;
       	isSnapped = false;
	}
	
	private function snapTargetUpdatedHandler(event:Event):void
	{
		if(!snappedToObject.object || event.type == Event.REMOVED)
			unsnap();			
		else
			moveToPoint(snappedToObject.object, snappedToObject.point);
	}	
	
	private function getDeltaPoint(object1:DisplayObject, point1:Point,
									object2:DisplayObject, point2:Point):Point
	{
	   	var p1:Point = object1.localToGlobal(new Point(object1.width/2, object1.height/2));
	   	var p2:Point = object2.localToGlobal(new Point(object2.width/2, object2.height/2));
       	
       	if(point1)
       		p1 = object1.localToGlobal(point1);
       		 
       	if(point2)
       		p2 = object2.localToGlobal(point2); 

       	return  p2.subtract(p1);		
	} 
	
	public function moveToPoint(object:DisplayObject, point:Point=null):void
	{
       	var dP:Point = getDeltaPoint(target, null, object, point);     	
       	
       	centerX += dP.x;
       	centerY += dP.y;
       	
       	target.dispatchEvent(new MoveEvent(MoveEvent.MOVED));
	}
	
	public function scrollToObject():void
	{
		if(!target.parent)
			return;
			
		if(!(target.parent is Container))
			return;
		
		var cP:Point = new Point(centerX, centerY);  
		
		Container(target.parent).verticalScrollPosition = cP.y - Container(target.parent).height/2;
		Container(target.parent).horizontalScrollPosition = cP.x - Container(target.parent).width/2
	} 
			
    /**
     *  Called when the user starts moving
     */    
    protected function startMove():void
    {	        
	    _regX = target.mouseX;
	    _regY = target.mouseY;
	        	
	    _isMoving = true;
	    movingObj = target;
	            	
        target.systemManager.addEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        if(_stopMovingMouseEvent) {
			_regStopMovingMouseEvent =_stopMovingMouseEvent;
			         	
	       	target.systemManager.addEventListener(
    	       	_regStopMovingMouseEvent, systemManager_stopMovingMouseEventHandler, true);
        }
	    
	    target.systemManager.stage.addEventListener(
	        Event.MOUSE_LEAVE, stage_mouseLeaveHandler, true);
            
        target.dispatchEvent(new MoveEvent(MoveEvent.MOVE_START));
    }

    /**
     *  Called when the user stops moving
     */
    protected function stopMove():void
    {
        target.systemManager.removeEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
		
		if(_regStopMovingMouseEvent) 
        	target.systemManager.removeEventListener(
            	_regStopMovingMouseEvent, systemManager_stopMovingMouseEventHandler, true);
	    
	    target.systemManager.stage.removeEventListener(
	        Event.MOUSE_LEAVE, stage_mouseLeaveHandler, true);
	
    	_isMoving = false;
    	movingObj = null;

		target.dispatchEvent(new MoveEvent(MoveEvent.MOVE_END));
    }    
    
    private function systemManager_mouseMoveHandler(event:MouseEvent):void
    {
    	//event.stopImmediatePropagation();
		target.dispatchEvent(new MoveEvent(MoveEvent.MOVED));
	    
	    var pos:Point;
	    var parentPos:Point = new Point();
	    var parentContainer:Object = target;
	    
	    container_loop: while(parentContainer.parent && parentContainer.parent.parent) {
	    	if(parentContainer.parent is Container)
	    	{
	    		for each(var elm:DisplayObject in Container(parentContainer.parent).getChildren())
	    		{
	    			if(elm == parentContainer)
	    			{
	    				parentContainer = Container(parentContainer.parent);	    		
	    				break container_loop;
	    			}
	    		}
	    	}
	    	
	    	parentContainer = parentContainer.parent;	    	
	    		    	
	    }
	    
	    if(parentContainer is Container)
	    {
	    	parentPos = new Point(
				parentContainer.contentMouseX - _regX,
				parentContainer.contentMouseY - _regY );
			
			parentPos.x = Math.min(parentPos.x, 0);
			parentPos.y = Math.min(parentPos.y, 0);
	    }
	    	    
	    if(target.parent)
	    {
	    	pos = new Point(
				DisplayObject(target.parent).mouseX - _regX,
				DisplayObject(target.parent).mouseY - _regY );
				
			pos.x -= parentPos.x;	    	
			pos.y -= parentPos.y;	    	
	    }
	    
	    if(isSnapped && snappedToObject.object)
	    {
	    	if(!snappedToObject.object.hitTestPoint(target.stage.mouseX, target.stage.mouseY))
	       		unsnap();	    	
	    }
	    			        	
	    if(!isSnapped && pos && isMovable)
	    	target.move(pos.x, pos.y);
	        		
		target.invalidateDisplayList();		    	
    }
        
    private function systemManager_stopMovingMouseEventHandler(event:MouseEvent):void
    {
    	if(_isMoving)
			stopMove();
    }
    	
    protected function stage_mouseLeaveHandler(event:Event):void
    {
    	if(_isMoving)
			stopMove();
    }
    
    protected function mouseDownHandler(event:MouseEvent):void
    {    	
    	if(!movingObj && 
    		(!(event.target is UIComponent) || event.target.hasOwnProperty('_context')) )
    	{
    		event.target.dispatchEvent(new MoveEvent(
    			MoveEvent.MOVE_STARTING, 
    			event.bubbles,
    			true,
    			event.localX,
    			event.localY,
    			event.relatedObject,
    			event.ctrlKey,
    			event.altKey,
    			event.shiftKey,
    			event.buttonDown,
    			event.delta));
    	}
    }	
    
    protected function startingMoveHandler(event:MoveEvent):void
    {	        
		if (target.enabled && isMovable && !event.isDefaultPrevented() && !_isMoving){
			event.preventDefault();
	    	startMove();
		}
    }
    
    protected function rollOverHandler(event:MouseEvent):void
    {
    	_over = true;
		event.updateAfterEvent();
		target.invalidateProperties();
    }	
    
    protected function rollOutHandler(event:MouseEvent):void
    {	
    	_over = false;
		event.updateAfterEvent();
		target.invalidateProperties();	
    }
    
    protected function focusOutHandler(event:FocusEvent):void
    {
    	_focused = false;
        target.invalidateProperties();
    }

    protected function focusInHandler(event:FocusEvent):void
    {
    	_focused = true;
        target.invalidateProperties();
    }		

}
}
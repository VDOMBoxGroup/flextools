package net.vdombox.powerpack.managers
{
import ExtendedAPI.com.utils.ObjectUtils;

import net.vdombox.powerpack.graph.NodeEvent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.core.Container;
import mx.core.UIComponent;
import mx.events.ChildExistenceChangedEvent;
import mx.events.FlexEvent;

public class SelectionManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables and constants
	//
	//--------------------------------------------------------------------------
		
	public static var isLiveDragging:Boolean = true;
	public static var drawShadows:Boolean = true;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *	Constructor
	 */ 
	public function SelectionManager(container:Container)
	{
		super();
		
		_container = container;
		_container.addEventListener(MouseEvent.MOUSE_DOWN, onContainerMouseDown);
		_container.addEventListener(KeyboardEvent.KEY_DOWN, onContainerKeyDown);
		_container.addEventListener(ChildExistenceChangedEvent.CHILD_ADD, onChildAdd);
		_container.addEventListener(FlexEvent.REMOVE, onContainerRemove);
		
		for each(var child:DisplayObject in _container.getChildren())
		{
			addElement(child);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Destructor
	//
	//--------------------------------------------------------------------------

	/**
	 *	Destructor
	 */
	 public function dispose():void
	 {
   		deselectAll();   		
		removeAll();
		
		_container.removeEventListener(MouseEvent.MOUSE_DOWN, onContainerMouseDown);
		_container.removeEventListener(KeyboardEvent.KEY_DOWN, onContainerKeyDown);			 	
		_container.removeEventListener(ChildExistenceChangedEvent.CHILD_ADD, onChildAdd);
		_container.removeEventListener(FlexEvent.REMOVE, onContainerRemove);

		_container = null;
	 }
	  
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------			

	private var _container:Container;

    private var regX:Number;
    private var regY:Number; 
    
    private var regDeltaElmPts:Dictionary;
    
    private var _groupMoved:Boolean;

	private var _group:Dictionary = new Dictionary(true);
	private var _preGroup:Dictionary = new Dictionary(true);
	
	private var rectShape:UIComponent;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	public function get selection():Dictionary
	{
		return _group;	
	}
	
	public function addElement(elm:DisplayObject):void
	{
		if(!elm.hasOwnProperty("selected"))
			return;
		
		elm.addEventListener(MouseEvent.MOUSE_DOWN, onElmMouseDown, true);
		elm.addEventListener(MouseEvent.CLICK, onElmClick);
		elm.addEventListener(KeyboardEvent.KEY_DOWN, onElmKeyDown);
		elm.addEventListener(NodeEvent.SELECTED_CHANGED, onElmSelectedChange);
		elm.addEventListener(FlexEvent.REMOVE, onElmRemove);

		elm.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		elm.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		
		if(elm['selected'])
			select(elm, true);
	}
	
	public function removeElement(elm:DisplayObject):void
	{
		if(!elm.hasOwnProperty("selected"))
			return;

		deselect(elm, true);
		
		elm.removeEventListener(MouseEvent.MOUSE_DOWN, onElmMouseDown);
		elm.removeEventListener(MouseEvent.CLICK, onElmClick);
		elm.removeEventListener(KeyboardEvent.KEY_DOWN, onElmKeyDown);
		elm.removeEventListener(NodeEvent.SELECTED_CHANGED, onElmSelectedChange); 		
		elm.removeEventListener(FlexEvent.REMOVE, onElmRemove);

		elm.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		elm.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
	}
	
	public function removeAll():void
	{
		for(var elm:Object in _group)
			removeElement(DisplayObject(elm));
	}
	
	public function select(elm:DisplayObject, forced:Boolean=false):void
	{
		if(!elm.hasOwnProperty('selected'))
			return;

		elm['selected'] = true;
		
		if(forced)
		{
			_group[elm] = elm;
			   			
   			if(elm is UIComponent && !_group[_container.focusManager.getFocus()])
				UIComponent(elm).setFocus();
		}			 
	}
			
	public function deselect(elm:DisplayObject, forced:Boolean=false):void
	{
		if(!elm.hasOwnProperty('selected'))
			return;
		
		elm['selected'] = false;

		if(forced && _group[elm])
		{	
			delete _group[elm];
		}
	}
	
	private function preSelect(elm:Object):void
	{
		if(elm.hasOwnProperty('selected'))
		{
			_preGroup[elm] = elm;		 
		}
	}

	private function preDeselect(elm:Object):void
	{
		if(elm.hasOwnProperty('selected'))
		{
			if(_preGroup[elm])
				delete _preGroup[elm];
		}
	}
	
	private function addPreselected():void
	{
		for(var elm:Object in _preGroup)
		{
			select(DisplayObject(elm));
		}
	}
	
	private function subtractPreselected():void
	{
		for(var elm:Object in _preGroup)
		{
			deselect(DisplayObject(elm));
		}
	}

	public function selectAll():void
	{
		for each(var child:DisplayObject in _container.getChildren())
			select(child);
	}
	
	public function deselectAll():void
	{
		for(var elm:Object in _group)
			deselect(DisplayObject(elm));
	}
	
	public function isSelected(elm:Object):Boolean
	{
		if(elm.hasOwnProperty('selected') && elm.selected)
			return true;
		
		return false;		
	}

    /**
     *  Called when the user starts dragging
     */
    protected function startDragging(event:MouseEvent):void
    {
        regX = _container.contentMouseX;
        regY = _container.contentMouseY;
        
        _container.systemManager.addEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        _container.systemManager.addEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);

        _container.systemManager.stage.addEventListener(
            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
         
        if(event.currentTarget==_container) //begin draw selection rect
        {   
        	regDeltaElmPts = new Dictionary(true);
        	rectShape = new UIComponent();
        	_container.addChild(rectShape);
        }
        else //begin drag group
        {
        	regDeltaElmPts = new Dictionary(true);
	        for each (var child:Object in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected') && isSelected(child))
	        	{
	        		var rect:Rectangle = new Rectangle(child.x, child.y, child.width, child.height);
        			regDeltaElmPts[child] = {deltaPoint:new Point(child.x-regX, child.y-regY), boundsRect:rect};
		    		
		    		if(isLiveDragging && drawShadows)
		    		{
		    			if(child.hasOwnProperty('dropShadow'))
		    				child.dropShadow = true;
		    			else
		    				child.setStyle("dropShadowEnabled", true);
		    		}
	        	}
	        }    		
        }
    }

    /**
     *  Called when the user stops dragging
     */
    protected function stopDragging():void
    {
    	if(rectShape) // remove selection rect
    	{
    		_container.removeChild(rectShape);
    		rectShape = null;
    		
    		if(ObjectUtils.dictLength(_group)==0)
    			_container.setFocus();
    	}
    	else // stop drag group
    	{
	        for each (var child:Object in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected') && isSelected(child))
	        	{
		    		if(isLiveDragging && drawShadows)
		    		{
		    			if(child.hasOwnProperty('dropShadow'))
		    				child.dropShadow = false;
		    			else
		    				child.setStyle("dropShadowEnabled", false);
		    		}
					
					delete regDeltaElmPts[child];		    		
	        	}
	        }    		
    	}
    	
        _container.systemManager.removeEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        _container.systemManager.removeEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);

        _container.systemManager.stage.removeEventListener(
            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);

        regX = NaN;
        regY = NaN;
        
        regDeltaElmPts = null;	
    }
    
    private function drawSelectionRect(obj:UIComponent, rect:Rectangle):void
    {
        obj.graphics.lineStyle(1, 0x000044, 0.8);
        obj.graphics.beginFill(0xffffff, 0.2);
        obj.graphics.drawRect(0,0,rect.width,rect.height);
        obj.graphics.endFill();
    }
    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
   	
   	private function onContainerRemove(event:Event):void
   	{
   		deselectAll();   		
		removeAll();
   	}
   	
   	private function onChildAdd(event:ChildExistenceChangedEvent):void
   	{
		var child:DisplayObject = event.relatedObject;
		
		addElement(child);
   	}
   		
   	private function onElmRemove(event:FlexEvent):void
   	{
   		var elm:DisplayObject = event.currentTarget as DisplayObject;
   		
   		removeElement(elm);   		
   	}	
   	
   	private function onElmSelectedChange(event:Event):void
   	{
		var elm:Object = event.currentTarget;
		
		if(isSelected(elm))
		{
			_group[elm] = elm;

   			if(!_group[_container.focusManager.getFocus()])
				elm.setFocus();
		}
		else 
		{
			if(_group[elm])
				delete _group[elm];
		}
   	}
   	   	
    private function systemManager_mouseMoveHandler(event:MouseEvent):void
    {
    	event.stopImmediatePropagation();    	
    	
    	var p:Point = new Point(
    		_container.contentMouseX, 
        	_container.contentMouseY);
    	
    	if(rectShape)
    	{
	    	if( p.x < 0 )
	    		p.x = 0;
	    	if( p.y < 0 )
	    		p.y = 0;
	    		        	
			rectShape.graphics.clear();
			
	        rectShape.x = Math.min(p.x, regX);
	        rectShape.y = Math.min(p.y, regY);
	        rectShape.width = Math.max(p.x, regX) - rectShape.x;
	        rectShape.height = Math.max(p.y, regY) - rectShape.y;        

			var rect:Rectangle = new Rectangle(0,0,rectShape.width,rectShape.height);

			drawSelectionRect(rectShape, rect);
			
			_preGroup = new Dictionary(true);
	        
	        for each (var child:DisplayObject in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected'))
	        	{
	        		var rect1:Rectangle = new Rectangle(rectShape.x, rectShape.y, rectShape.width, rectShape.height);
	        		var rect2:Rectangle;
	        		
	        		if(regDeltaElmPts[child])
	        		{
	        			rect2 = regDeltaElmPts[child].boundsRect;
	        		}
	        		else
	        		{
	        			rect2 = new Rectangle(child.x, child.y, child.width, child.height);
	        			regDeltaElmPts[child] = {boundsRect: rect2};
	        		}
	        		
	        		if(!event.shiftKey && !event.commandKey && !event.controlKey && !event.altKey)
	        		{
						if(rect1.intersects(rect2))
							select(child);
						else
							deselect(child);
	        		}
	        		else
	        		{
						if(rect1.intersects(rect2))
							preSelect(child);
						else
							preDeselect(child);
	        		}
	        	}
	        }
	        
    		if(event.shiftKey || event.commandKey || event.controlKey && !event.altKey)
       			addPreselected();
    		else if(!event.shiftKey && !event.commandKey && !event.controlKey && event.altKey)
    			subtractPreselected();
	    }
	    else
	    {
	    	var newP:Point = new Point(p.x, p.y);
				    	
	        for (var elm:Object in _group)
	        {
        		var newX:Number = newP.x+regDeltaElmPts[elm].deltaPoint.x;
        		var newY:Number = newP.y+regDeltaElmPts[elm].deltaPoint.y;
	        		 
				if(newX<0)
					newP.x -= newX;
				
				if(newY<0)
					newP.y -= newY;
	        }
	        
	        for (elm in _group)
	        {
				elm.move(	newP.x+regDeltaElmPts[elm].deltaPoint.x, 
   							newP.y+regDeltaElmPts[elm].deltaPoint.y );
    				
   				_groupMoved = true;
	        }
	    }
	    
        _container.invalidateDisplayList();
    }

    private function systemManager_mouseUpHandler(event:MouseEvent):void
    {
        if (!isNaN(regX))
            stopDragging();
    }
    	    
    private function stage_mouseLeaveHandler(event:Event):void
    {
        if (!isNaN(regX))
            stopDragging();
    } 
   	       	
   	private function onContainerMouseDown(event:MouseEvent):void
   	{
   		// if you press any non-selectable or not selected object on container 
   		if(	(!event.target.hasOwnProperty('selected') || !event.target.selected) && 
   			event.target!=_container)
			deselectAll();
   		
   		if(event.target!=_container)
   			return;
   		
   		if(!event.shiftKey && !event.controlKey && !event.commandKey && !event.altKey)	
   			deselectAll();
   		
   		if(isNaN(regX))
        	startDragging(event);
   	}	
   		
   	private function onElmClick(event:MouseEvent):void
   	{
   		event.stopPropagation();
		
		if (_groupMoved)
		{
			_groupMoved = false;
			return;
	   	}
		 
   		var elm:DisplayObject = event.currentTarget as DisplayObject;
   		
   		if(event.controlKey || event.commandKey)
   		{
   			if(isSelected(elm))
   				deselect(elm);	
   			else
   				select(elm);
   		}
   		else if(event.shiftKey)
   		{
   			select(elm);
   		}
   		else
   		{
   			deselectAll();
   			select(elm);
   		}
   	}

   	private function onElmMouseDown(event:MouseEvent):void
   	{
   		_groupMoved = false;
   		
   		if(event.controlKey || event.commandKey || event.shiftKey)
   		{
   			// prevent from change focus
   			event.stopImmediatePropagation();   			
   		}
   		else if(ObjectUtils.dictLength(_group)>1 && event.currentTarget.selected)
   		{
   			event.stopImmediatePropagation();
   			startDragging(event);
   		}
   	}   
   	
   	private function onContainerKeyDown(event:KeyboardEvent):void
   	{
   		if(event.target != _container)
   			return;
   			
   		if(	event.keyCode == Keyboard.A && 
   			(event.controlKey || event.commandKey))
   		{
   			event.stopImmediatePropagation();
   			
   			if(_container.focusManager.getFocus()!=_container)
   				_container.setFocus();
   			
   			selectAll();
   		}
   		else if(event.keyCode == Keyboard.TAB)
   		{
   			deselectAll();
   		}
   	}
   	
   	private function onElmKeyDown(event:KeyboardEvent):void
   	{
   		if(event.keyCode == Keyboard.TAB)
   		{
   			deselectAll();
   		}
   		else if(ObjectUtils.dictLength(_group)>1)
   		{
   			event.preventDefault();
	   		event.stopImmediatePropagation();
	   		
	   		this.dispatchEvent(event);
   		}
   	}
   	
   	private function onFocusIn(event:FocusEvent):void
   	{
   		var elm:DisplayObject = event.currentTarget as DisplayObject;
		select(elm);
   	}
   	
   	private function onFocusOut(event:FocusEvent):void
   	{
   		var elm:DisplayObject = event.currentTarget as DisplayObject;
   		
   		if(ObjectUtils.dictLength(_group)==1)
   		{
   			deselect(elm);
   		}
   	}
   	
}
}
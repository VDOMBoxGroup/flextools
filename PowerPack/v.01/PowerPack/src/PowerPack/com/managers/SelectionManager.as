package PowerPack.com.managers
{
import PowerPack.com.graph.NodeEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
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
		_container.addEventListener(FlexEvent.REMOVE, onContainerRemove);
		_container.addEventListener(ChildExistenceChangedEvent.CHILD_ADD, onElmAdded);
		_container.addEventListener(KeyboardEvent.KEY_DOWN, onContainerKeyDown);
		
		for each(var child:Object in _container.getChildren())
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
		_container.removeEventListener(FlexEvent.REMOVE, onContainerRemove);
		_container.removeEventListener(ChildExistenceChangedEvent.CHILD_ADD, onElmAdded);
		_container.removeEventListener(KeyboardEvent.KEY_DOWN, onContainerKeyDown);			 	

		_container = null;
	 }
	  
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------			

    private var regX:Number;
    private var regY:Number; 
    
    private var regDeltaElmPts:Dictionary;
    
    private var _groupMoved:Boolean;

	private var _group:Array = [];
	private var _preGroup:Array = [];
	private var _container:Container;
	
	private var rectShape:UIComponent;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	public function getSelection():Array
	{
		return _group;	
	}
	
	public function addElement(elm:Object):void
	{
		if(elm.hasOwnProperty("selected"))
		{
			elm.addEventListener(MouseEvent.MOUSE_DOWN, onElmMouseDown);
			elm.addEventListener(MouseEvent.CLICK, onElmClick);
			elm.addEventListener(KeyboardEvent.KEY_DOWN, onElmKeyDown);
			elm.addEventListener(FlexEvent.REMOVE, onElmRemove);
			elm.addEventListener(NodeEvent.SELECTED_CHANGED, onElmSelected);
			
			if(elm.selected)
				select(elm);
		}		
	}
	
	public function removeElement(elm:Object):void
	{
		if(elm.hasOwnProperty("selected"))
		{
			deselect(elm);
			
	   		elm.selected = false;
	   		
			elm.removeEventListener(MouseEvent.MOUSE_DOWN, onElmMouseDown);
			elm.removeEventListener(MouseEvent.CLICK, onElmClick);
			elm.removeEventListener(KeyboardEvent.KEY_DOWN, onElmKeyDown);
			elm.removeEventListener(FlexEvent.REMOVE, onElmRemove);
			elm.removeEventListener(NodeEvent.SELECTED_CHANGED, onElmSelected); 		
		}		
	}
	
	public function removeAll():void
	{
		for each(var child:Object in _container.getChildren())
			removeElement(child);
	}
	
	public function select(elm:Object):void
	{
		if(elm.hasOwnProperty('selected'))
		{
			elm.selected = true;
			
			var ac:ArrayCollection = new ArrayCollection(_group);
			var index:int = ac.getItemIndex(elm);
		
			if(index<0)
				ac.addItem(elm);			 
		}			 
	}
			
	public function deselect(elm:Object):void
	{
		if(elm.hasOwnProperty('selected'))
		{
			elm.selected = false;	

			var ac:ArrayCollection = new ArrayCollection(_group);
			var index:int = ac.getItemIndex(elm);
		
			if(index>=0)
				ac.removeItemAt(index);
		}
	}
	
	private function preSelect(elm:Object):void
	{
		if(elm.hasOwnProperty('selected'))
		{
			var ac:ArrayCollection = new ArrayCollection(_preGroup);
			var index:int = ac.getItemIndex(elm);
		
			if(index<0)
				ac.addItem(elm);			 
		}
	}

	private function preDeselect(elm:Object):void
	{
		if(elm.hasOwnProperty('selected'))
		{
			var ac:ArrayCollection = new ArrayCollection(_preGroup);
			var index:int = ac.getItemIndex(elm);
		
			if(index>=0)
				ac.removeItemAt(index);
		}
	}
	
	private function addPreselected():void
	{
		for each(var elm:Object in _preGroup)
		{
			select(elm);
		}
	}
	
	private function subtractPreselected():void
	{
		for each(var elm:Object in _preGroup)
		{
			deselect(elm);
		}
	}

	public function selectAll():void
	{
		for each(var child:Object in _container.getChildren())
			select(child);
	}
	
	public function deselectAll():void
	{
		for each(var child:Object in _container.getChildren())
			deselect(child);
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
    	if(rectShape)
    	{
    		_container.removeChild(rectShape);
    		rectShape = null;
    		
    		_container.setFocus();
    	}
    	else
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
   	
   	private function onElmAdded(event:ChildExistenceChangedEvent):void
   	{
		var elm:Object = event.relatedObject;
		
		if(elm.hasOwnProperty('selected'))
		{
			addElement(elm);
		}
   	}
   		
   	private function onElmRemove(event:FlexEvent):void
   	{
   		var elm:Object = event.currentTarget;
   		
   		removeElement(elm);   		
   	}	
   	
   	private function onElmSelected(event:Event):void
   	{
		var elm:Object = event.currentTarget;
		var ac:ArrayCollection = new ArrayCollection(_group);
		var index:int = ac.getItemIndex(elm);
		
		if(isSelected(elm))
		{
			if(index<0)
				ac.addItem(elm);			 
		}
		else
		{
			if(index>=0)
				ac.removeItemAt(index);
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
	        
	        for each (var child:Object in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected'))
	        	{
	        		var rect1:Rectangle = new Rectangle(rectShape.x, rectShape.y, rectShape.width, rectShape.height);
	        		var rect2:Rectangle = new Rectangle(child.x, child.y, child.width, child.height);
	        		
	        		if(!event.shiftKey && !event.commandKey && !event.controlKey)
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
	        
    		if(event.shiftKey && !event.commandKey && !event.controlKey)
       			addPreselected();
    		else if(!event.shiftKey && event.commandKey || event.controlKey)
    			subtractPreselected();
	    }
	    else
	    {
	    	var newP:Point = new Point(p.x, p.y);
				    	
	        for each (child in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected') && isSelected(child))
	        	{
	        		var newX:Number = newP.x+regDeltaElmPts[child].deltaPoint.x;
	        		var newY:Number = newP.y+regDeltaElmPts[child].deltaPoint.y;
	        		 
					if(newX<0)
						newP.x -= newX;
					
					if(newY<0)
						newP.y -= newY;
	        	}
	        }
	        
	        for each (child in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected') && isSelected(child))
	        	{
					child.move(	newP.x+regDeltaElmPts[child].deltaPoint.x, 
    							newP.y+regDeltaElmPts[child].deltaPoint.y );
    				
    				child.invalidateDisplayList();
    				
    				_groupMoved = true;
	        	}
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
   		if((!event.target.hasOwnProperty('selected') || !event.target.selected) && event.target!=_container)
			deselectAll();
   		
   		if(event.target!=_container)
   			return;
   		
   		if(!event.shiftKey && !event.controlKey && !event.commandKey)	
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
		 
   		var elm:Object = event.currentTarget;
   		
   		if(event.controlKey || event.commandKey)
   		{
   			if(isSelected(elm))
   				deselect(elm);	
   			else
   				select(elm);
   		}
   		else
   		{
   			deselectAll();
   			
   			if(_container.focusManager.getFocus()!=elm)
				elm.setFocus();
				
   			select(elm);
   		}
   	}

   	private function onElmMouseDown(event:MouseEvent):void
   	{
   		_groupMoved = false;
   		
   		if(event.controlKey || event.commandKey)
   			event.stopImmediatePropagation();
   		else if(_group.length>1 && event.currentTarget.selected)
   		{
   			event.stopImmediatePropagation();
   			startDragging(event);
   		}
   	}   
   	
   	private function onContainerKeyDown(event:KeyboardEvent):void
   	{
   		if(event.target != _container)
   			return;
   			
   		if(event.keyCode == Keyboard.A)
   		{
   			if(event.controlKey || event.commandKey)
   			{
   				event.stopImmediatePropagation();
   				
   				if(_container.focusManager.getFocus()!=_container)
   					_container.setFocus();
   				
   				selectAll();
   			}
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
   		else if(_group.length>1)
   		{
   			event.preventDefault();
	   		event.stopImmediatePropagation();
	   		
	   		this.dispatchEvent(event);
   		}
   	}
   	
}
}
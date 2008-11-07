package PowerPack.com.managers
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
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
	//  Class variables
	//
	//--------------------------------------------------------------------------
		
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
    
    private var _itemsMoved:Boolean;

	private var _elms:Array = [];
	private var _container:Container;
	
	private var rectShape:UIComponent;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------


	public function addElement(elm:Object):void
	{
		if(elm.hasOwnProperty("selected"))
		{
			elm.addEventListener(MouseEvent.MOUSE_DOWN, onElmMouseDown);
			elm.addEventListener(MouseEvent.CLICK, onElmClick);
			elm.addEventListener(KeyboardEvent.KEY_DOWN, onElmKeyDown);
			elm.addEventListener(FlexEvent.REMOVE, onElmRemove);
			
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
		}		
	}
	
	public function removeAll():void
	{
		for each(var child:Object in _container.getChildren())
			removeElement(child);
	}

	public function deselectAll():void
	{
		for each(var child:Object in _container.getChildren())
			deselect(child);
	}
	
	public function selectAll():void
	{
		for each(var child:Object in _container.getChildren())
			select(child);
	}
		
	public function deselect(elm:Object):void
	{
		var ac:ArrayCollection = new ArrayCollection(_elms);
		
		if(elm.hasOwnProperty('selected'))
		{
			var index:int = ac.getItemIndex(elm);
			
			elm.selected = false;	
		
			if(index>=0)
				ac.removeItemAt(index);			 
		}
	}
	
	public function select(elm:Object):void
	{
		var ac:ArrayCollection = new ArrayCollection(_elms);
		
		if(elm.hasOwnProperty('selected'))
		{
			var index:int = ac.getItemIndex(elm);
	
			elm.selected = true;
		
			if(index<0)
				ac.addItem(elm);
		}			 
	}
	
	public function isSelected(elm:Object):Boolean
	{
		var ac:ArrayCollection = new ArrayCollection(_elms);
		var index:int = ac.getItemIndex(elm);
		
		if(index<0)
			return false;
		
		return true;		
	}

    /**
     *  Called when the user starts dragging a node
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
         
        if(event.currentTarget==_container)
        {   
        	rectShape = new UIComponent();
        	_container.addChild(rectShape);
        }
        else
        {
        	regDeltaElmPts = new Dictionary(true);
	        for each (var child:Object in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected') && isSelected(child))
	        	{
        			regDeltaElmPts[child] = new Point(child.x-regX, child.y-regY);
		    		child.setStyle("dropShadowEnabled", true);
	        	}
	        }    		
        }
    }

    /**
     *  Called when the user stops dragging a node
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
		    		child.setStyle("dropShadowEnabled", false);
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
    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
   	
   	private function onElmAdded(event:ChildExistenceChangedEvent):void
   	{
		var elm:Object = event.relatedObject;
		
		addElement(elm);
   	}
   	
   	private function onContainerRemove(event:Event):void
   	{
   		deselectAll();   		
		removeAll();
   	}
   		
   	private function onElmRemove(event:FlexEvent):void
   	{
   		var elm:Object = event.currentTarget;
   		
   		removeElement(elm);   		
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
	        
	        rectShape.graphics.lineStyle(1, 0x000044, 0.8);
	        rectShape.graphics.beginFill(0xffffff, 0.1);
	        rectShape.graphics.drawRect(0,0,rectShape.width,rectShape.height);
	        rectShape.graphics.endFill();
	        
	        for each (var child:Object in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected'))
	        	{
					if(rectShape.hitTestObject(child as DisplayObject))
						select(child);
					else
						deselect(child);
	        	}
	        }
	    }
	    else
	    {
	    	var newP:Point = new Point(p.x, p.y);
				    	
	        for each (child in _container.getChildren())
	        {
	        	if(child.hasOwnProperty('selected') && isSelected(child))
	        	{
	        		var newX:Number = newP.x+regDeltaElmPts[child].x;
	        		var newY:Number = newP.y+regDeltaElmPts[child].y;
	        		 
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
					child.move(	newP.x+regDeltaElmPts[child].x, 
    							newP.y+regDeltaElmPts[child].y );
					
    				child.invalidateDisplayList();
    				
    				_itemsMoved = true;
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
   		if(event.target!=_container)
   			return;
   			
   		deselectAll();
   		
   		if(isNaN(regX))
        	startDragging(event);
   	}	
   		
   	private function onElmClick(event:MouseEvent):void
   	{
   		event.stopPropagation();
		
		if (_itemsMoved)
		{
			_itemsMoved = false;
			return;
	   	}
		 
   		var elm:Object = event.currentTarget;
   		
   		if(event.controlKey || event.commandKey)
   		{
   			if(isSelected(elm))
   			{
   				deselect(elm);	
   			}	
   			else
   			{
   				select(elm);
   			}
   		}
   		else
   		{
   			deselectAll();
   			
   			select(elm);
   		}
   	}

   	private function onElmMouseDown(event:MouseEvent):void
   	{
   		_itemsMoved = false;
   		
   		if(_elms.length>1)
   		{
   			event.stopImmediatePropagation();
   			startDragging(event);
   		}
   	}   
   	
   	private function onContainerKeyDown(event:KeyboardEvent):void
   	{
   		if(event.keyCode == Keyboard.A)
   		{
   			if(event.controlKey || event.commandKey)
   			{
   				event.stopImmediatePropagation();
   				selectAll();
   			}
   		}
   	}
   	
   	private function onElmKeyDown(event:KeyboardEvent):void
   	{
   		if(_elms.length>1)
   		{
   			event.preventDefault();
	   		event.stopImmediatePropagation();
	   		
	   		this.dispatchEvent(event);
   		}
   	}
   	
}
}
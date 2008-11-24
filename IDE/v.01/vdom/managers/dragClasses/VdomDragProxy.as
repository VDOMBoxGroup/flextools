package vdom.managers.dragClasses
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.DragSource;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.events.DragEvent;
import mx.managers.DragManager;
import mx.managers.ISystemManager;

import vdom.managers.VdomDragManager;

/**
 *  @private
 *  A helper class for DragManager that displays the drag image
 */
public class VdomDragProxy extends UIComponent
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function VdomDragProxy(dragInitiator:IUIComponent,
							  dragSource:DragSource)
    {
		super();

        this.dragInitiator = dragInitiator;
        this.dragSource = dragSource;

        var sm:ISystemManager = dragInitiator.systemManager.
								topLevelSystemManager;

        sm.addEventListener(MouseEvent.MOUSE_MOVE,
							mouseMoveHandler, true);
        
		sm.addEventListener(MouseEvent.MOUSE_UP,
							mouseUpHandler, true);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function initialize():void
	{
		super.initialize();
		// in case we go offscreen
		stage.addEventListener(MouseEvent.MOUSE_MOVE, 
							stage_mouseMoveHandler);

		// in case we go offscreen
		stage.addEventListener(Event.MOUSE_LEAVE, 
							mouseLeaveHandler);

		// Make sure someone has focus, otherwise we
		// won't get keyboard events.
		if (!getFocus())
			setFocus();
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Last Mouse event received
     */
    private var lastMouseEvent:MouseEvent;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public var dragInitiator:IUIComponent;

    /**
     *  @private
     */
    public var dragSource:DragSource;

    /**
     *  @private
     */
    public var xOffset:Number;

    /**
     *  @private
     */
    public var yOffset:Number;

    /**
     *  @private
     */
    public var startX:Number;

    /**
     *  @private
     */
    public var startY:Number;

    /**
     *  @private
     */
    public var target:IUIComponent = null;

    /**
     *  @private
     *  Current drag action - NONE, COPY, MOVE or LINK
     */
    public var action:String;

    /**
     *  @private
     *  whether move is allowed or not
     */
    public var allowMove:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    

    /**
     *  @private
     */
    

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    

    /**
     *  @private
     */
    

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------


    /**
     *  @private
     */
    public function stage_mouseMoveHandler(event:MouseEvent):void
    {
		if (event.target != stage)
			return;

		mouseMoveHandler(event);
	}

	/**
	 *  @private
	 */
	private function dispatchDragEvent(type:String, mouseEvent:MouseEvent, eventTarget:Object):void
	{
		var dragEvent:DragEvent = new DragEvent(type);
		var pt:Point = new Point();
		
		dragEvent.dragInitiator = dragInitiator;
		dragEvent.dragSource = dragSource;
		dragEvent.action = action;
		dragEvent.ctrlKey = mouseEvent.ctrlKey;
		dragEvent.altKey = mouseEvent.altKey;
		dragEvent.shiftKey = mouseEvent.shiftKey;
		pt.x = lastMouseEvent.localX;
		pt.y = lastMouseEvent.localY;
		pt = DisplayObject(lastMouseEvent.target).localToGlobal(pt);
		pt = DisplayObject(eventTarget).globalToLocal(pt);
		dragEvent.localX = pt.x;
		dragEvent.localY = pt.y;
		eventTarget.dispatchEvent(dragEvent);
	}
	
    /**
     *  @private
     */
    public function mouseMoveHandler(event:MouseEvent):void
    {
        var dragEvent:DragEvent;
        var dropTarget:DisplayObject;
        var i:int;

        lastMouseEvent = event;

        var pt:Point = new Point();
        var point:Point = new Point(event.localX, event.localY);
        point = DisplayObject(event.target).localToGlobal(point);
        point = DisplayObject(dragInitiator.systemManager.topLevelSystemManager).globalToLocal(point);
        var mouseX:Number = point.x;
        var mouseY:Number = point.y;
        x = mouseX - xOffset;
        y = mouseY - yOffset;

        // The first time through we only want to position the proxy.
        if (!event)
        {
            return;
        }


		var targetList:Array /* of DisplayObject */ =
			DisplayObjectContainer(dragInitiator.systemManager.topLevelSystemManager).
			getObjectsUnderPoint(new Point(mouseX, mouseY));
		var newTarget:DisplayObject = null;
		
		// targetList is in depth order, and we want the top of the list. However, we
		// do not want the target to be a decendent of us.
		var targetIndex:int = targetList.length - 1;
		while (targetIndex >= 0)
		{
			newTarget = targetList[targetIndex];
			if (newTarget != this && !contains(newTarget))
				break;
			targetIndex--;
		}
			
        // If we already have a target, send it a dragOver event
        // if we're still over it.
        // If we're not over it, send it a dragExit event.
        if (target)
        {
            var foundIt:Boolean = false;
            var oldTarget:IUIComponent = target;

			dropTarget = newTarget;

			while (dropTarget)
			{
				if (dropTarget == target)
				{
					// Dispatch a "dragOver" event
					dispatchDragEvent(DragEvent.DRAG_OVER, event, dropTarget);
					foundIt = true;
					break;
				} 
				else 
				{
					// Dispatch a "dragEnter" event and see if a new object
					// steals the target.
					dispatchDragEvent(DragEvent.DRAG_ENTER, event, dropTarget);
					
					// If the potential target accepted the drag, our target
					// now points to the dropTarget. Bail out here, but make 
					// sure we send a dragExit event to the oldTarget.
					if (target == dropTarget)
					{
						foundIt = false;
						break;
					}
				}
				dropTarget = dropTarget.parent;
			}

            if (!foundIt)
            {
                // Dispatch a "dragExit" event on the old target.
                dispatchDragEvent(DragEvent.DRAG_EXIT, event, oldTarget);

				if (target == oldTarget)
               		target = null;
            }
        }

        // If we don't have an existing target, go look for one.
        if (!target)
        {
            action = DragManager.MOVE;

            // Dispatch a "dragEnter" event.
			dropTarget = newTarget;
			while (dropTarget)
			{
				if (dropTarget != this)
				{
					dispatchDragEvent(DragEvent.DRAG_ENTER, event, dropTarget);
					if (target)
						break;
				}
				dropTarget = dropTarget.parent;
			}

            if (!target)
                action = DragManager.NONE;
        }

    }

    /**
     *  @private
     */
	public function mouseLeaveHandler(event:Event):void
	{
		mouseUpHandler(lastMouseEvent);
	}

    /**
     *  @private
     */
    public function mouseUpHandler(event:MouseEvent):void
    {
        var dragEvent:DragEvent;

        var sm:ISystemManager = dragInitiator.systemManager.
								topLevelSystemManager;

		sm.removeEventListener(MouseEvent.MOUSE_MOVE,
                               mouseMoveHandler, true);

		// in case we go offscreen
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, 
							stage_mouseMoveHandler);

        sm.removeEventListener(MouseEvent.MOUSE_UP,
                               mouseUpHandler, true);

		// in case we go offscreen
		stage.removeEventListener(Event.MOUSE_LEAVE, 
							mouseLeaveHandler);

        if (target && action != DragManager.NONE)
        {
			// Dispatch a "dragDrop" event.
            dragEvent = new DragEvent(DragEvent.DRAG_DROP);
			dragEvent.dragInitiator = dragInitiator;
            dragEvent.dragSource = dragSource;
            dragEvent.action = action;
            dragEvent.ctrlKey = event.ctrlKey;
            dragEvent.altKey = event.altKey;
            dragEvent.shiftKey = event.shiftKey;
            var pt:Point = new Point();
            pt.x = lastMouseEvent.localX;
            pt.y = lastMouseEvent.localY;
            pt = DisplayObject(lastMouseEvent.target).localToGlobal(pt);
            pt = DisplayObject(target).globalToLocal(pt);
            dragEvent.localX = pt.x;
            dragEvent.localY = pt.y;
            target.dispatchEvent(dragEvent);
        }
        else
        {
            action = DragManager.NONE;
        }

        // Do the drop effect.
        // If the drop was accepted, zoom the proxy image into
        // the current mouse location.
        // If the drop was rejected, move the proxy image
        // back to its original location.
       
       VdomDragManager.endDrag();

        // Dispatch a "dragComplete" event.
        dragEvent = new DragEvent(DragEvent.DRAG_COMPLETE);
		dragEvent.dragInitiator = dragInitiator;
        dragEvent.dragSource = dragSource;
        dragEvent.relatedObject = InteractiveObject(target);
        dragEvent.action = action;
        dragEvent.ctrlKey = event.ctrlKey;
        dragEvent.altKey = event.altKey;
        dragEvent.shiftKey = event.shiftKey;
        dragInitiator.dispatchEvent(dragEvent);

        this.lastMouseEvent = null;
    }
}

}

package powerPack.com
{
	import mx.controls.Label;
	import mx.controls.ComboBox;
	import mx.containers.Panel;
	
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import mx.core.Application;
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;
	import mx.styles.StyleManager;
	import mx.core.EdgeMetrics;
	import mx.controls.TextArea;
	import mx.states.SetStyle;
	
	[Event(name="textChanged", type="flash.events.Event")]
	[Event(name="typeChanged", type="flash.events.Event")]
    
	public class graphNode extends Canvas
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
	    private static const DEFAULT_WIDTH:Number = 80;
	    private static const DEFAULT_HEIGHT:Number = 30;
	    private static const OFFSET:Number = 1;
	    
	    public static const NORMAL:int = 0;
	    public static const SUBGRAPH:int = 1;
	    public static const COMMAND:int = 2;
    
	    //--------------------------------------------------------------------------
	    //
	    //  Variables
	    //
	    //--------------------------------------------------------------------------
	    /**
	     *  Horizontal location where the user pressed the mouse button
	     *  on the titlebar to start dragging, relative to the original
	     *  horizontal location of the Panel.
	     */
	    private var regX:Number;
	    
	    /**
	     *  Vertical location where the user pressed the mouse button
	     *  on the titlebar to start dragging, relative to the original
	     *  vertical location of the Panel.
	     */
	    private var regY:Number;  
	
    	private var _textEditing:Boolean = false;
        
		//----------------------------------
	    //  node text
	    //----------------------------------
	
	    /**
	     *  The TextArea sub-control that displays the node text.
	     */
	    protected var nodeTextArea:TextArea;
	    /**
	     * 	Storage for the text property.
	     */ 
    	private var _text:String = "Node";
    	private var _textChanged:Boolean = false;
    	
	    [Bindable("textChanged")]
	    [Inspectable(category="General", defaultValue="Node")]
	
	    /**
	     *  Node text.
	     *
	     *  @default "Node"
	     *
	     */
	    public function get text():String
	    {
	        return _text;
	    }
	
	    public function set text(value:String):void
	    {
	        _text = value;
	        _textChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new Event("textChanged"));
	    }
	    
		private var _type:int = NORMAL;	
    	private var _typeChanged:Boolean = false;
    	    
	    [Bindable("typeChanged")]
	    [Inspectable(category="General", defaultValue=NORMAl, enumeration="0,1,2")]
	
	    /**
	     *  Node type.
	     *
	     *  @default "Normal"
	     *
	     */
	    public function get type():int
	    {
	        return _type;
	    }
	
	    public function set type(value:int):void
	    {
	    	_type = value;
	    	
	        _typeChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new Event("typeChanged"));
	    }	    
    
    	public function graphNode(__type:int = NORMAL)
		{
			super();
			
			type = __type;
			
			doubleClickEnabled = true;
			
			setStyle( "borderStyle", "solid" );
			setStyle( "borderThickness", 0);
			setStyle( "backgroundColor", 0xE2E2E2 );			
			setStyle( "backgroundAlpha", 0.5 );
			
			addEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
			//addEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
			//addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
		}		

	    override public function set enabled(value:Boolean):void
	    {
	        super.enabled = value;
	
	        if (nodeTextArea)
	            nodeTextArea.enabled = value;	
	    }

		override protected function measure():void {
            super.measure();

            measuredWidth=DEFAULT_WIDTH;
            measuredHeight=DEFAULT_HEIGHT;
            
            measuredMinWidth=measuredWidth;
            measuredMinHeight=measuredHeight;
        }

         override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
				
			var vm:EdgeMetrics = viewMetrics;

			var clientWidth:int = unscaledWidth - vm.left - vm.right - (OFFSET + OFFSET);
			var clientHeight:int = unscaledHeight - vm.top - vm.bottom - (OFFSET + OFFSET);
				
			if(nodeTextArea)
			{				
				nodeTextArea.move(OFFSET, OFFSET);
				nodeTextArea.setActualSize(clientWidth, clientHeight);
			}
		}

		/**
	     *  Create child objects.
	     */
	    override protected function createChildren():void
	    {
	        super.createChildren();
	        
	        if (!nodeTextArea)
	        {
	            nodeTextArea = new TextArea();
	            nodeTextArea.editable = false;
	            nodeTextArea.selectable = false;	            
	            nodeTextArea.enabled = enabled;
             	nodeTextArea.text = _text;

	            addChild(nodeTextArea);
	        }
	    }

	    override protected function commitProperties():void
	    {
	        super.commitProperties();
	        
	        if (_textChanged)
	        {
	            _textChanged = false;
	            nodeTextArea.text = _text;
	            nodeTextArea.toolTip = _text;
	            
	            // Don't call layoutChrome() if we  haven't initialized,
	            // because it causes commit/measure/layout ordering problems
	            // for children of the control bar.
	            if (initialized)
	                invalidateDisplayList();
	        }	
	        
	        if (_typeChanged)
	        {
	            _typeChanged = false;
	            switch(_type)
	            {
	            	case NORMAL:
	            		nodeTextArea.setStyle( "borderColor",  0x000000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffffff);
	            		nodeTextArea.setStyle( "color",  0x000000);	            		
	            		break;
	            	case SUBGRAPH:
	            		nodeTextArea.setStyle( "borderColor",  0x000000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffff00);
	            		nodeTextArea.setStyle( "color",  0x000000);
	            		break;	            	
	            	case COMMAND:
	            		nodeTextArea.setStyle( "borderColor",  0xff0000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffffff);
	            		nodeTextArea.setStyle( "color",  0x000000);
	            		break;        		
	            }          
	            if (initialized)
	                invalidateDisplayList();
	        }	
	    }    

		public function bringToFront():void
		{
	        // Make sure a parent container exists.
            if(parent)
            {
                if (parent.getChildIndex(this) < parent.numChildren-1)
                {
		   		   	parent.setChildIndex(this, parent.numChildren-1);
                }
            }		 
		}
        
	    /**
	     *  Called when the user starts dragging a node
	     */
	    protected function startDragging(event:MouseEvent):void
	    {
	        regX = event.stageX - x;
	        regY = event.stageY - y;
	        setStyle("dropShadowEnabled", true);	        
	        
	        systemManager.addEventListener(
	            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
	
	        systemManager.addEventListener(
	            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
	
	        systemManager.stage.addEventListener(
	            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
	    }
	
	    /**
	     *  Called when the user stops dragging a node
	     */
	    protected function stopDragging():void
	    {
	        systemManager.removeEventListener(
	            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
	
	        systemManager.removeEventListener(
	            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
	
	        systemManager.stage.removeEventListener(
	            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
	
	        regX = NaN;
	        regY = NaN;
	        setStyle("dropShadowEnabled", false);
	    }	
	    
		//--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------
	
	    private function mouseDownHandler(event:MouseEvent):void
	    {
	        // A mouseDown on the closeButton will bubble up to the titleBar,
	        // but it shouldn't start a drag; it should simply start the
	        // normal mouse/Button interaction.					
			
			bringToFront();
				        
	        if (!_textEditing && enabled && isNaN(regX))
	            startDragging(event);
	    }
	    
	    private function doubleClickHandler(event:MouseEvent):void
	    {
	        // A doubleClick on the closeButton will bubble up to the titleBar,
	        // but it shouldn't start a drag; it should simply start the
	        // normal mouse/Button interaction.					
			
			bringToFront();
						
			editMode(true);	        
	    }
	    
	    private function editMode(_editing:Boolean):void
	    {
	    	if( !enabled )
				return;
			if( _editing == _textEditing )
				return;
				
	        if(_editing)
	        {
	            _textEditing = true;
	            nodeTextArea.editable = true;
	            nodeTextArea.selectable = true;
	            nodeTextArea.setFocus();
   	            nodeTextArea.setSelection(0, nodeTextArea.text.length);
   	            nodeTextArea.drawFocus(true); 
	        }
	        else
	        {
	            _textEditing = false;
	            nodeTextArea.selectable = false;
	            nodeTextArea.editable = false;
   	            nodeTextArea.setSelection(0, 0); 
   	            nodeTextArea.drawFocus(false); 
	        }		    	
	    }
	
	    private function systemManager_mouseMoveHandler(event:MouseEvent):void
	    {
	    	// during a drag, only the graphNode should get mouse move events
	    	// (e.g., prevent objects 'beneath' it from getting them -- see bug 187569)
	    	// we don't check the target since this is on the systemManager and the target
	    	// changes a lot -- but this listener only exists during a drag.
	    	
	    	event.stopImmediatePropagation();
	    	
	        move(event.stageX - regX, event.stageY - regY);
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
	}
}
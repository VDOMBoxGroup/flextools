package powerPack.com.graph
{	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.events.KeyboardEvent;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.TextArea;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.EdgeMetrics;
	import mx.managers.PopUpManager;	
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.events.CloseEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.FlexEvent;
	import flash.events.FocusEvent
	import flash.geom.Point;
	import flash.text.TextLineMetrics;
	import mx.core.UITextField;
	import mx.core.mx_internal;

	import powerPack.com.graph.graphNodeCategory;
	import powerPack.com.graph.graphNodeType;
	import powerPack.com.graph.graphArrow;
	
	import mx.core.Container;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import mx.core.UIComponent;
	import mdm.Menu;
	import powerPack.com.graph.PowerPackClass;
	
	use namespace mx_internal;
	
	[Event(name="textChanged", type="flash.events.Event")]
	[Event(name="categoryChanged", type="flash.events.Event")]
	[Event(name="typeChanged", type="flash.events.Event")]
	[Event(name="addingTransition", type="flash.events.Event")]
	[Event(name="copyNode", type="flash.events.Event")]	
	[Event(name="destroyNode", type="flash.events.Event")]	
    
	public class graphNode extends Canvas 
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
	    public static const DEFAULT_WIDTH:Number = 30;
	    public static const DEFAULT_HEIGHT:Number = 20;
	    public static const OFFSET:Number = 2;
	    public static const PADDING:Number = 0;
	    
	    private static const ALERT_DELETE_TITLE:String = "Confirmation";
	    private static const ALERT_DELETE_TXT:String = "Are you sure want to delete this node?";
	    private static const DEFAULT_LBL:String = "Node";
	    
	    [ArrayElementType("String")]
	    private static const MENU_ITEM_CAPTIONS:Array = new Array(
	    	"Add Transition", 
	    	"Delete Node", 
	    	"Copy Node",
	    	"Initial",
	    	"Terminal",
	    	"Normal",
	    	"Sub Graph",
	    	"Command" );
	    	    
	    private static const NEED_CONTEXT:Boolean = true;
		
		/**
		 *	Modes
		 */
	    private static const M_NORMAL:Number = 0;
	    private static const M_EDITING:Number = 1;
	    
	    //--------------------------------------------------------------------------
	    //
	    //  Variables and properties
	    //
	    //--------------------------------------------------------------------------
	    
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
            
        // Define a static method.
        private static function classConstruct():Boolean 
        {
            if (!StyleManager.getStyleDeclaration("graphNode"))
            {
                // If there is no CSS definition for graphNode, 
                // then create one and set the default value.
                var newStyleDeclaration:CSSStyleDeclaration;
                
                if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("UIComponent")))
                {
	                newStyleDeclaration = new CSSStyleDeclaration();
	                //newStyleDeclaration.setStyle("themeColor", "haloBlue");
	            }                
                StyleManager.setStyleDeclaration("graphNode", newStyleDeclaration, true);
            }
            return true;
        }        	  
		//--------------------------------------------------------------------------   
		
					    
	    /**
	     *  Horizontal location where the user pressed the mouse button
	     *  on the node.
	     */
	    private var regX:Number;
	    
	    /**
	     *  Vertical location where the user pressed the mouse button
	     *  on the node
	     */
	    private var regY:Number;  
	    
	    [ArrayElementType("graphArrow")]
	    public var inArrows:ArrayCollection;
	    
	    [ArrayElementType("graphArrow")]
	    public var outArrows:ArrayCollection;
	    
	    public static var copyNode:graphNode;
	
    	private var _mode:Number = 0;
        
	    private var contextMenuOld:ContextMenu;
	    
	    //--------------------------------------------------------------------------
	
	    /**
	     *  The TextArea sub-control that displays the node text.
	     */	    
	    protected var nodeTextArea:TextArea;	    
	    //--------------------------------------------------------------------------
	    
	    /**
	     * 	Storage for the text property.
	     */ 
    	private var _text:String = DEFAULT_LBL;
    	private var _textChanged:Boolean = false;
    	
	    [Bindable("textChanged")]
	    [Inspectable(category="General", defaultValue=DEFAULT_LBL)]
	
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
	    	var rePattern:RegExp;
	    	rePattern = /\r/gi;
	        _text = value.replace(rePattern, "\\r");
	        rePattern = /\n/gi;
	        _text = _text.replace(rePattern, "\\n");
	        rePattern = /\t/gi;
	        _text = _text.replace(rePattern, "\\t");	        
	        
	        _textChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("textChanged"));
	    }
	    //--------------------------------------------------------------------------
	    
		private var _category:String = graphNodeCategory.NORMAL;	
    	private var _categoryChanged:Boolean = false;
    	    
	    [Bindable("categoryChanged")]
	    [Inspectable(category="General", defaultValue=graphNodeCategory.NORMAL, enumeration="Normal,Subgraph,Command")]
	
	    /**
	     *  Node category.
	     *
	     *  @default "Normal"
	     *
	     */
	    public function get category():String
	    {
	        return _category;
	    }	
	    public function set category(value:String):void
	    {
	    	_category = value;
	    	
	        _categoryChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new Event("categoryChanged"));
	    }
	    //--------------------------------------------------------------------------

		private var _type:String = graphNodeType.NORMAL;	
    	private var _typeChanged:Boolean = false;

	    [Bindable("typeChanged")]
	    [Inspectable(category="General", defaultValue=graphNodeType.NORMAL, enumeration="Normal,Initial,Terminal")]
	
	    /**
	     *  Node type.
	     *
	     *  @default "Normal"
	     *
	     */
	    public function get type():String
	    {
	        return _type;
	    }	
	    public function set type(value:String):void
	    {
	    	_type = value;
	    	
	        _typeChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new Event("typeChanged"));
	    }
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/** 
		 *	Constructor
		 */
    	public function graphNode(	__category:String = graphNodeCategory.NORMAL, 
    								__type:String = graphNodeType.NORMAL, 
    								__text:String = DEFAULT_LBL)
		{
			super();
			
			category = __category;
			type = __type;
			text = __text;
			
			inArrows = new ArrayCollection();
			outArrows = new ArrayCollection();
			
			doubleClickEnabled = true;
			cacheAsBitmap = true;
			
			setStyle( "borderStyle", "solid" );
			setStyle( "borderThickness", 1);
			setStyle( "borderColor", 0xE2E2E2);			
			setStyle( "backgroundColor", 0xE2E2E2 );0
			setStyle( "backgroundAlpha", 0.5 );
			
			addEventListener(FlexEvent.ADD, addHandler);
		}		
		//--------------------------------------------------------------------------
		//
		//  Destructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *	Destructor
		 */ 
		public function destroy():void
		{			
	        if (contextMenu)
	        {
	        	if(contextMenu.customItems.length>0)     	
		        	contextMenu.customItems[0].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addTransitionHandler);
				if(contextMenu.customItems.length>1)     	
		        	contextMenu.customItems[1].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteNodeHandler);
	        	if(contextMenu.customItems.length>2)     	
		        	contextMenu.customItems[2].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyNodeHandler);

	        	if(contextMenu.customItems.length>3)     	
		        	contextMenu.customItems[3].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setInitialTypeHandler);
	        	if(contextMenu.customItems.length>4)     	
		        	contextMenu.customItems[4].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setTerminalTypeHandler);

	        	if(contextMenu.customItems.length>5)     	
		        	contextMenu.customItems[5].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setNormalCategoryHandler);
	        	if(contextMenu.customItems.length>6)     	
		        	contextMenu.customItems[6].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setSubgraphCategoryHandler);
	        	if(contextMenu.customItems.length>7)     	
		        	contextMenu.customItems[7].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCommandCategoryHandler);
	        }	  				
	  		stopDragging();
   			
			removeEventListener(FlexEvent.ADD, addHandler);

			removeEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
			removeEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
			removeEventListener(KeyboardEvent.KEY_DOWN, keyDown); 
			removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);

			removeEventListener(FocusEvent.FOCUS_IN, nodeFocusInHandler);
			removeEventListener(FocusEvent.FOCUS_OUT, nodeFocusOutHandler);	

			while(inArrows.length)
			{
				inArrows[0].destroy();
			}
			
			while(outArrows.length)
			{
				outArrows[0].destroy();
			}

	        if(parent)
        	{
   	        	parent.removeChild(this);
   	     	}
   	        	
	       	dispatchEvent(new Event("destroyNode"));
		}
				
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
	    override public function set enabled(value:Boolean):void
	    {
	        super.enabled = value;
	
	        if (nodeTextArea)
	            nodeTextArea.enabled = value;	
	    }

		override protected function measure():void {
            super.measure();
			
            var borderThickness:Number = getStyle("borderThickness");            
            var lineMetrics:TextLineMetrics = nodeTextArea.measureText(nodeTextArea.text);

            measuredMinWidth=Math.max(lineMetrics.width + UITextField.TEXT_WIDTH_PADDING, DEFAULT_WIDTH) + 
            	OFFSET*2 + borderThickness*2 + (_mode==M_EDITING?PADDING:0);
            
            measuredMinHeight=lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING + 
            	OFFSET*2 + borderThickness*2;            
			
            measuredWidth=measuredMinWidth;
            measuredHeight=measuredMinHeight;    
            
            setActualSize(measuredWidth, measuredHeight);       
        }        
        
        override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
				
			var vm:EdgeMetrics = viewMetrics;

			var clientWidth:int = unscaledWidth - vm.left - vm.right - (OFFSET + OFFSET);
			var clientHeight:int = unscaledHeight - vm.top - vm.bottom - (OFFSET + OFFSET);			
            
            setActualSize(measuredWidth, measuredHeight); 
            	
			if(nodeTextArea)
			{				
				nodeTextArea.move(OFFSET, OFFSET);
				nodeTextArea.setActualSize(clientWidth, clientHeight);
			}
			
	    	for(var i:int=0; i<inArrows.length; i++)
	    		inArrows[i].callRedraw();
	    	
	    	for(var j:int=0; j<outArrows.length; j++)
	    		outArrows[j].callRedraw();			
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
	           	nodeTextArea.enabled = enabled;
	            nodeTextArea.selectable = false;	
             	nodeTextArea.text = _text;
             	nodeTextArea.wordWrap = false;
				nodeTextArea.addEventListener(FocusEvent.FOCUS_IN, textAreaFocusIn); 
				nodeTextArea.addEventListener(FocusEvent.FOCUS_OUT, textAreaFocusOut); 

	            addChild(nodeTextArea);
	        }
	        if (NEED_CONTEXT && !contextMenu)
	        {
	        	contextMenu = new ContextMenu();
	        	contextMenu.hideBuiltInItems();	        	
	        	
	        	contextMenu.customItems.push(new ContextMenuItem(MENU_ITEM_CAPTIONS[0]));	
	        	contextMenu.customItems[0].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addTransitionHandler);
	        	contextMenu.customItems.push(new ContextMenuItem(MENU_ITEM_CAPTIONS[1]));			
	        	contextMenu.customItems[1].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteNodeHandler);
	        	contextMenu.customItems.push(new ContextMenuItem(MENU_ITEM_CAPTIONS[2]));			
	        	contextMenu.customItems[2].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyNodeHandler);

	        	contextMenu.customItems.push(new ContextMenuItem((_type==graphNodeType.INITIAL?"> ":"  ")+MENU_ITEM_CAPTIONS[3], true));			
	        	contextMenu.customItems[3].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setInitialTypeHandler);
	        	contextMenu.customItems.push(new ContextMenuItem((_type==graphNodeType.TERMINAL?"> ":"  ")+MENU_ITEM_CAPTIONS[4]));			
	        	contextMenu.customItems[4].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setTerminalTypeHandler);

	        	contextMenu.customItems.push(new ContextMenuItem((_type==graphNodeCategory.NORMAL?"> ":"  ")+MENU_ITEM_CAPTIONS[5], true));			
	        	contextMenu.customItems[5].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setNormalCategoryHandler);
	        	contextMenu.customItems.push(new ContextMenuItem((_type==graphNodeCategory.SUBGRAPH?"> ":"  ")+MENU_ITEM_CAPTIONS[6]));			
	        	contextMenu.customItems[6].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setSubgraphCategoryHandler);
	        	contextMenu.customItems.push(new ContextMenuItem((_type==graphNodeCategory.COMMAND?"> ":"  ")+MENU_ITEM_CAPTIONS[7]));			
	        	contextMenu.customItems[7].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCommandCategoryHandler);
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
	        }	
	        if (_categoryChanged)
	        {
	            _categoryChanged = false;
	            
	            if (contextMenu)
	            {
	           		contextMenu.customItems[5].caption = MENU_ITEM_CAPTIONS[5];
    	       		contextMenu.customItems[6].caption = MENU_ITEM_CAPTIONS[6];
        	   		contextMenu.customItems[7].caption = MENU_ITEM_CAPTIONS[7];
        	   	}

	            switch(_category)
	            {
	            	case graphNodeCategory.NORMAL:
	            		nodeTextArea.setStyle( "borderColor",  0x000000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffffff);
	            		nodeTextArea.setStyle( "color",  0x000000);
	            		if (contextMenu)
		            		contextMenu.customItems[5].caption = "> " + contextMenu.customItems[5].caption;
	            		break;
	            	case graphNodeCategory.SUBGRAPH:
	            		nodeTextArea.setStyle( "borderColor",  0x000000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffff00);
	            		nodeTextArea.setStyle( "color",  0x000000);
	            		if (contextMenu)
		            		contextMenu.customItems[6].caption = "> " + contextMenu.customItems[6].caption;
	            		break;	            	
	            	case graphNodeCategory.COMMAND:
	            		nodeTextArea.setStyle( "borderColor",  0xffff00);
	            		nodeTextArea.setStyle( "backgroundColor",  0x333333);
	            		nodeTextArea.setStyle( "color",  0xffff00);
	            		if (contextMenu)
		            		contextMenu.customItems[7].caption = "> " + contextMenu.customItems[7].caption;
	            		break;        		
	            }          
	        }	
	        if (_typeChanged)
	        {
	            _typeChanged = false;
	            if (contextMenu)
	            {
    	       		contextMenu.customItems[3].caption = MENU_ITEM_CAPTIONS[3];
	           		contextMenu.customItems[4].caption = MENU_ITEM_CAPTIONS[4];
        	   	}	
	            switch(_type)
	            {
	            	case graphNodeType.NORMAL:
	            		setStyle( "borderColor", 0xE2E2E2);	
		            	break;
	            	case graphNodeType.INITIAL:
	            		setStyle( "borderColor", 0xff0000);	
	    	       		contextMenu.customItems[3].caption = "> " + contextMenu.customItems[3].caption;
		            	break;
	            	case graphNodeType.TERMINAL:
	            		setStyle( "borderColor", 0x0000ff);	
    		       		contextMenu.customItems[4].caption = "> " + contextMenu.customItems[4].caption;
		            	break;
	            }
	        }		            
            if (initialized)
            {
                invalidateSize();
        		invalidateDisplayList();
            }	                
	    }    

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------		
		
		public function duplicate(target:Container):graphNode		
		{
			if(!parent)
				return null;
			
			if(!(target is Container))
				return null;
				
			if(target is graphNode)
				return null;			
			
			var newNode:graphNode = new graphNode(category, type, text);
			target.addChild(newNode);
			newNode.move( target.mouseX, target.mouseY );			
			return newNode;
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
	        regX = this.mouseX;
	        regY = this.mouseY;
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
	    
	    private function editMode(_editing:Boolean):void
	    {
	    	if( !enabled )
				return;
				
			if( _editing && _mode==M_EDITING )
				return;
				
	        if(_editing)
	        {
	            _mode = M_EDITING;
	            nodeTextArea.editable = true;
	            nodeTextArea.selectable = true;
   	            nodeTextArea.setSelection(0, nodeTextArea.text.length);
	            nodeTextArea.setFocus();
				nodeTextArea.focusManager.showFocus();
				systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, true);
				nodeTextArea.addEventListener(Event.CHANGE, textAreaChange); 
	        }
	        else
	        {
	            _mode = M_NORMAL;
				systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, true);
				nodeTextArea.removeEventListener(Event.CHANGE, textAreaChange); 
	            nodeTextArea.selectable = false;
	            nodeTextArea.editable = false;
   	            nodeTextArea.setSelection(0, 0);
				nodeTextArea.focusManager.hideFocus();
	        }		    	
	    }		
		public function alertDestroy():void
		{			
     		if(parent && _mode==M_NORMAL)
     		{
	     		Alert.show(ALERT_DELETE_TXT,ALERT_DELETE_TITLE,Alert.YES|Alert.NO,this,alertRemoveHandler,null,Alert.NO);			     	
	     	}
		}		    
			    	    
		//--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------	
	    
	    private function addHandler(event:FlexEvent):void
	    {
			addEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
			addEventListener(KeyboardEvent.KEY_DOWN, keyDown); 
			addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);

			addEventListener(FocusEvent.FOCUS_IN, nodeFocusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, nodeFocusOutHandler);
	    }	    
	    
		private function addTransitionHandler(event:ContextMenuEvent):void
		{
			if(parent && parent is graphCanvas)
			{
				var gCanvas:graphCanvas = parent as graphCanvas;
				if(gCanvas.currentArrow)
				{
					gCanvas.currentArrow.destroy();
					gCanvas.currentArrow = null;
				}				
				gCanvas.addingTransition = true;
				gCanvas.currentArrow = new graphArrow();
				gCanvas.addChildAt(gCanvas.currentArrow, 0);
				gCanvas.currentArrow.fromObject = this;
			}					
			dispatchEvent(new Event("addingTransition"));
		}
		private function deleteNodeHandler(event:ContextMenuEvent):void
		{
     		alertDestroy();
     	}
		private function copyNodeHandler(event:ContextMenuEvent):void
		{
			copyNode = this;
			dispatchEvent(new Event("copyNode"));
		}
		private function setInitialTypeHandler(event:ContextMenuEvent):void
		{
			if(_type==graphNodeType.INITIAL)
				type = graphNodeType.NORMAL;
			else
				type = graphNodeType.INITIAL;
		}
		private function setTerminalTypeHandler(event:ContextMenuEvent):void
		{
			if(_type==graphNodeType.TERMINAL)
				type = graphNodeType.NORMAL;
			else
				type = graphNodeType.TERMINAL;
		}
		private function setNormalCategoryHandler(event:ContextMenuEvent):void
		{
			category = graphNodeCategory.NORMAL;
		}
		private function setSubgraphCategoryHandler(event:ContextMenuEvent):void
		{
			category = graphNodeCategory.SUBGRAPH;
		}
		private function setCommandCategoryHandler(event:ContextMenuEvent):void
		{
			category = graphNodeCategory.COMMAND;
		}

		private function mouseOverHandler(event:MouseEvent):void
		{
	    	PowerPackClass.refreshMenu(this);
	    	event.stopPropagation();
			
			contextMenuOld = Application.application.contextMenu;
			if(contextMenu)
				Application.application.contextMenu = contextMenu;	
			
			if(parent && parent is graphCanvas)
			{
				if((parent as graphCanvas).addingTransition)
				{
					setStyle( "backgroundAlpha", 1.0 );
				}
			}
		}
		
		private function mouseOutHandler(event:MouseEvent):void
		{			
	    	if(contextMenuOld)
	    		Application.application.contextMenu = contextMenuOld;						

			if(parent && parent is graphCanvas)
			{
				setStyle( "backgroundAlpha", 0.5 );
			}
		}
		
	    private function mouseDownHandler(event:MouseEvent):void
	    {
	    	if(parent && parent is graphCanvas)
			{
				var gCanvas:graphCanvas = parent as graphCanvas;
				
				if(gCanvas.addingTransition)
				{
					gCanvas.addingTransition = false;					
					
					if(gCanvas.currentArrow.fromObject==this)
					{
						gCanvas.currentArrow = null;
						return;
					}
					
					for each (var arrow:graphArrow in inArrows)
					{
						if(arrow.fromObject == gCanvas.currentArrow.fromObject)
						{
							gCanvas.currentArrow = null;
							return;
						}
					}
					for each (arrow in outArrows)
					{
						if(arrow.toObject == gCanvas.currentArrow.fromObject)
						{
							gCanvas.currentArrow = null;
							return;
						}
					}
					
					if(gCanvas.currentArrow)
					{
						if(gCanvas.currentArrow.parent && gCanvas.currentArrow.fromObject)
						{
							gCanvas.currentArrow.toObject = this;							
							(gCanvas.currentArrow.fromObject as graphNode).outArrows.addItem(gCanvas.currentArrow);
							(gCanvas.currentArrow.toObject as graphNode).inArrows.addItem(gCanvas.currentArrow);
							gCanvas.currentArrow.addEventListener("destroyArrow", destroyArrowHandler);
						}	
					}						
					gCanvas.currentArrow = null;
					return;
				}
			}
					
			bringToFront();
				        
	        if (_mode==M_NORMAL && enabled && isNaN(regX))
	            startDragging(event);
	    }
	    
	    private function mouseDownOutsideHandler(event:MouseEvent):void
	    {	    	
        	if (!nodeTextArea.hitTestPoint(event.stageX, event.stageY, true))
        	{
		    	if(_mode==M_EDITING)
		    	{
				   	text = nodeTextArea.text;
		    		editMode(false);
		    	}
		    }
	    }	    
	    
		private function keyDown(event:KeyboardEvent):void
	    {	    	
			if(parent && parent is graphCanvas)
			{
				if((parent as graphCanvas).addingTransition)
				{					
					return;			
				}
			}
			
			// delete
			if(event.charCode == 127)
	     	{
	     		alertDestroy();
		    }
		    // enter
		    else if(event.charCode == 13)
		    {
		    	if(_mode==M_NORMAL)
		    	{
			    	editMode(true);
			    }
			    else
			    {
			    	text = nodeTextArea.text;
			    	editMode(false);
			    }
		    }
		    // escape
		    else if(event.charCode == 27)
		    {
		    	text = _text;
		    	editMode(false);
		    }		    
		}
	     
	    private function alertRemoveHandler(event:CloseEvent):void 
	    {
        	if(parent && event.detail==Alert.YES)
        	{
				destroy();
   	     	}
		}
	    
	    private function doubleClickHandler(event:MouseEvent):void
	    {
			if(parent && parent is graphCanvas)
			{
				if((parent as graphCanvas).addingTransition)
				{					
					return;			
				}
			}	    	
			bringToFront();						
			editMode(true);	  
	    }
		
		private function textAreaFocusIn(Event:FocusEvent):void
		{
			//
		}		
		private function nodeFocusInHandler(Event:FocusEvent):void
		{
			setStyle( "backgroundColor", getStyle("themeColor") );
		}
		
		private function nodeFocusOutHandler(Event:FocusEvent):void
		{
			setStyle( "backgroundColor", 0xE2E2E2 );
		}

		private function textAreaFocusOut(Event:FocusEvent):void
		{
			if(parent)
			{
	    		text = nodeTextArea.text;
	    		editMode(false);	
	  		}	
		}
	
		private function textAreaChange(event:Event):void
		{
			if(initialized)
			{
				var node:graphNode = event.target.parent;
				node.invalidateProperties();
				node.invalidateSize();
				node.invalidateDisplayList();		
			}
	    }
	
	    private function systemManager_mouseMoveHandler(event:MouseEvent):void
	    {
	    	// during a drag, only the graphNode should get mouse move events
	    	// (e.g., prevent objects 'beneath' it from getting them -- see bug 187569)
	    	// we don't check the target since this is on the systemManager and the target
	    	// changes a lot -- but this listener only exists during a drag.
	    	
	    	event.stopImmediatePropagation();    	
	    	
	    	var pPos:Point = new Point(
	    		(parent as Container).contentMouseX - regX, 
	        	(parent as Container).contentMouseY - regY );
	        	
	    	if( pPos.x < 0 )
	    		pPos.x = 0;
	    	if( pPos.y < 0 )
	    		pPos.y = 0;
	    	
	       	move(	pPos.x, 
	        		pPos.y );
	        		
	        invalidateDisplayList();		
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
	    
	    public function destroyArrowHandler(event:Event):void
	    {
	    	if(!(event.target is graphArrow))
	    		return;
	    	
	    	var arrow:graphArrow = event.target as graphArrow;
	    	
	    	for (var i:int=0; i<(arrow.fromObject as graphNode).outArrows.length; i++)
	    	{	    	
	    		if((arrow.fromObject as graphNode).outArrows[i] == arrow)
	    		{
	    			(arrow.fromObject as graphNode).outArrows.removeItemAt(i);
	    			break;
	    		}
	    	}
	    	
	    	for (i=0; i<(arrow.toObject as graphNode).inArrows.length; i++)
	    	{	    	
	    		if((arrow.toObject as graphNode).inArrows[i] == arrow)
	    		{
	    			(arrow.toObject as graphNode).inArrows.removeItemAt(i);
	    			break;
	    		}
	    	}	    	
	    }
	    		
		//--------------------------------------------------------------------------
	    //
	    //  For MDM Zinc integration
	    //
	    //--------------------------------------------------------------------------
	    
	    /**
	    * Generate context menu
	    */
		public static function generateContextMenu():void
		{
			PowerPackClass.addMenuItemsByType("graphNode");
		}	    
	}
}
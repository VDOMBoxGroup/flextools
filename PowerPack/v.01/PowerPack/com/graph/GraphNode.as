package PowerPack.com.graph
{	
	import PowerPack.com.CustomContextMenu;
	import PowerPack.com.Global;
	import PowerPack.com.NodeTextValidator;
	import PowerPack.com.mdm.*;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextLineMetrics;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mdm.Menu;
	
	import mx.binding.utils.*;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.TextArea;
	import mx.controls.ToolTip;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ValidationResultEvent;
	import mx.managers.PopUpManager;
	import mx.managers.ToolTipManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.utils.ArrayUtil;

	[Event(name="nodeLanguageChanged", type="flash.events.Event")]
	[Event(name="textChanged", type="flash.events.Event")]
	[Event(name="categoryChanged", type="flash.events.Event")]
	[Event(name="typeChanged", type="flash.events.Event")]
	[Event(name="addingTransition", type="flash.events.Event")]
	[Event(name="copyNode", type="flash.events.Event")]	
	[Event(name="destroyNode", type="flash.events.Event")]	
    
	public class GraphNode extends Canvas
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
	    
	    public static const TEXT_WIDTH_PADDING:int = 5;
	    public static const TEXT_HEIGHT_PADDING:int = 4;
	    
	    /**
	    * default minimum node size
	    */
	    public static const DEFAULT_WIDTH:Number = 30;
	    public static const DEFAULT_HEIGHT:Number = 20;
	    
	    /**
	    * border offset
	    */
	    public static const OFFSET:Number = 2;
	    
	    /**
	    * text area right padding
	    */
	    public static const PADDING:Number = 0;
	    		
		/**
		 *	defines current node state values
		 */
	    private static const M_NORMAL:Number = 0;
	    private static const M_EDITING:Number = 1;
	    
	    //--------------------------------------------------------------------------
	    //
	    //  Variables and properties
	    //
	    //--------------------------------------------------------------------------
	    
	    private static var alertDeleteTitle:String = "Confirmation";
	    private static var alertDeleteText:String = "Are you sure want to delete this node?";
	    private static var defaultLbl:String = "Node";
	    
	    [ArrayElementType("String")]
	    private static var menuItemCaptions:Array = new Array(
	    	"Add Transition", 
	    	"Delete Node", 
	    	"Copy Node",
	    	"Initial",
	    	"Terminal",
	    	"Normal",
	    	"Sub Graph",
	    	"Command" );
	   	//--------------------------------------------------------------------------
        
        private static var _langXML:XML;
        	   	    
	    public static function set langXML(value:XML):void
	    {
	    	if(!value)
	    		return;
	    		
	        _langXML = value;

			alertDeleteTitle = _langXML.graphnode.alertdeletetitle;
			alertDeleteText = _langXML.graphnode.alertdeletetext;
			defaultLbl = _langXML.graphnode.defaultlabel;

        	menuItemCaptions = [];
    		        	
	    	menuItemCaptions = new Array(
	    		_langXML.graphnode.menuitemaddtrans, 
    			_langXML.graphnode.menuitemdelete, 
    			_langXML.graphnode.menuitemcopy,
    			_langXML.graphnode.menuiteminitial,
    			_langXML.graphnode.menuitemterminal,
    			_langXML.graphnode.menuitemnormal,
    			_langXML.graphnode.menuitemsubgraph,
    			_langXML.graphnode.menuitemcommand );		   
	        	        
	        Application.application.dispatchEvent(new Event("nodeLanguageChanged"));
	    }
	    public static function get langXML():XML
	    {
	        return _langXML;	        
	    }	
	   	//--------------------------------------------------------------------------
	   		    	       	    
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
            
        // Define a static method.
        private static function classConstruct():Boolean 
        {
            if (!StyleManager.getStyleDeclaration("GraphNode"))
            {
                // If there is no CSS definition for GraphNode, 
                // then create one and set the default value.
                var newStyleDeclaration:CSSStyleDeclaration;
                
                if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("Canvas")))
                {
	                newStyleDeclaration = new CSSStyleDeclaration();
	                newStyleDeclaration.setStyle("themeColor", "haloBlue");
	            }     
			
				newStyleDeclaration.setStyle( "borderStyle", "solid" );
				newStyleDeclaration.setStyle( "borderThickness", 1);
				newStyleDeclaration.setStyle( "borderColor", 0xE2E2E2);			
				newStyleDeclaration.setStyle( "backgroundColor", 0xE2E2E2 );0
				newStyleDeclaration.setStyle( "backgroundAlpha", 0.5 );
				                
                StyleManager.setStyleDeclaration("GraphNode", newStyleDeclaration, true);
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
	    
	    [ArrayElementType("GraphArrow")]
	    public var inArrows:ArrayCollection;
	    
	    [ArrayElementType("GraphArrow")]
	    public var outArrows:ArrayCollection;
	    
	    [Bindable]
	    [ArrayElementType("String")]
	    public var arrTrans:Array; 
	    
   	    [ArrayElementType("ToolTip")]
	    public var arrToolTip:Array;
	   	
	   	public static var copyNode:GraphNode;
	
    	/**
    	* possible values: M_NORMAL, M_EDITING
    	*/
    	private var _mode:int = M_NORMAL;
        
	    private var contextMenuOld:ContextMenu;
	    private var customCM:CustomContextMenu;
	    
		private var validator:NodeTextValidator;
		public var bDataValid:Boolean = true;
	    //--------------------------------------------------------------------------
	
	    /**
	     *  The TextArea sub-control that displays the node text.
	     */	    
	    protected var nodeTextArea:TextArea;	    
	    //--------------------------------------------------------------------------
	    
	    /**
	     * 	Storage for the text property.
	     */ 
    	private var _text:String;
    	private var _textChanged:Boolean = false;
    	
	    [Bindable("textChanged")]
	    [Inspectable(category="General", defaultValue=defaultLbl)]
	
	    /**
	     *  Node text.
	     *
	     *  @default "Node"
	     *
	     */
	    public function set text(value:String):void
	    {
	        _text = value.replace(/\r/g, "\\r");
	        _text = _text.replace(/\n/g, "\\n");
	        _text = _text.replace(/\t/g, "\\t");	        
	        
	        _textChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("textChanged"));
	    }
	    public function get text():String
	    {
	        return _text;
	    }
	    //--------------------------------------------------------------------------
	    
		private var _category:String = GraphNodeCategory.NORMAL;	
    	private var _categoryChanged:Boolean = false;
    	    
	    [Bindable("categoryChanged")]
	    [Inspectable(category="General", defaultValue=GraphNodeCategory.NORMAL, enumeration="Normal,Subgraph,Command")]
	
	    /**
	     *  Node category.
	     *
	     *  @default "Normal"
	     *
	     */
	    public function set category(value:String):void
	    {
	    	_category = value;
	    	
	        _categoryChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new Event("categoryChanged"));
	    }
	    public function get category():String
	    {
	        return _category;
	    }	
	    //--------------------------------------------------------------------------

		private var _type:String = GraphNodeType.NORMAL;	
    	private var _typeChanged:Boolean = false;

	    [Bindable("typeChanged")]
	    [Inspectable(category="General", defaultValue=GraphNodeType.NORMAL, enumeration="Normal,Initial,Terminal")]
	
	    /**
	     *  Node type.
	     *
	     *  @default "Normal"
	     *
	     */
	    public function set type(value:String):void
	    {
	    	_type = value;
	    	
	        _typeChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new Event("typeChanged"));
	    }
	    public function get type():String
	    {
	        return _type;
	    }	
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
    	public function GraphNode(	__category:String = GraphNodeCategory.NORMAL, 
    								__type:String = GraphNodeType.NORMAL, 
    								__text:String = null )
		{
			super();
			
			category = __category;
			type = __type;
			
			if(__text)
				text = __text;
			else
				text = defaultLbl;
			
			inArrows = new ArrayCollection();
			outArrows = new ArrayCollection();
			
			doubleClickEnabled = true;
			cacheAsBitmap = true;
		
			// Binding to out arrows
			BindingUtils.bindSetter(
				function(arr:Array):void 
				{
					for each (var arrow:GraphArrow in outArrows)
					{
						if(!arr || arr.length==0)
						{
							arrow.data = null;
							arrow.label = null;						
						}
						else if(ArrayUtil.getItemIndex(arrow.data, arr)<0)
						{
							arrow.data = arr[0];
							arrow.label = arr[0];
						}
					}				
				}, this, "arrTrans");
								
			Application.application.addEventListener("nodeLanguageChanged", languageChangeHandler);
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
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
			if(customCM)
			{	
				customCM.clear();
	  		}	  				
	  		stopDragging();
   			
   			Application.application.removeEventListener("nodeLanguageChanged", languageChangeHandler);
			removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

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
			
			if(copyNode == this)
			{
				copyNode = null;
				Application.application.dispatchEvent(new Event("copyNode"));
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

            measuredMinWidth=Math.max(lineMetrics.width + TEXT_WIDTH_PADDING, DEFAULT_WIDTH) + 
            	OFFSET*2 + borderThickness*2 + (_mode==M_EDITING?PADDING:0);
            
            measuredMinHeight=lineMetrics.height + TEXT_HEIGHT_PADDING + 
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
            
            setActualSize(measuredWidth + (_mode==M_EDITING?PADDING:0), measuredHeight); 
            	
			if(nodeTextArea)
			{				
				nodeTextArea.move(OFFSET, OFFSET);
				nodeTextArea.setActualSize(clientWidth + (_mode==M_EDITING?PADDING:0), clientHeight);
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
	        if (Global.FLASH_CONTEXT_MENU && !customCM)
	        {
	        	contextMenu = new ContextMenu();
	        	contextMenu.hideBuiltInItems();	  
	        	
	        	customCM = new CustomContextMenu(contextMenu);       	
	        	
	        	customCM.addItem("add", menuItemCaptions[0], addTransitionHandler);
	        	customCM.addItem("delete", menuItemCaptions[1], deleteNodeHandler);
	        	customCM.addItem("copy", menuItemCaptions[2], copyNodeHandler);
	        	
	        	customCM.addItem("initial_type", menuItemCaptions[3], setInitialTypeHandler, true, true, true, type==GraphNodeType.INITIAL, "type", false);
	        	customCM.addItem("terminal_type", menuItemCaptions[4], setTerminalTypeHandler, false, true, true, type==GraphNodeType.TERMINAL, "type", false);

	        	customCM.addItem("normal_category", menuItemCaptions[5], setNormalCategoryHandler, true, true, true, category==GraphNodeCategory.NORMAL, "category");
	        	customCM.addItem("subfraph_category", menuItemCaptions[6], setSubgraphCategoryHandler, false, true, true, category==GraphNodeCategory.SUBGRAPH, "category");
	        	customCM.addItem("command_category", menuItemCaptions[7], setCommandCategoryHandler, false, true, true, category==GraphNodeCategory.COMMAND, "category");
	        }	
	        if (!validator)
	        {
	        	validator = new NodeTextValidator();
				validator.source = this;
				validator.property = "text";
				validator.listener = nodeTextArea;
				validator.required = true;
				validator.addEventListener(ValidationResultEvent.INVALID, invalidDataHandler);
	        }        
	    }

	    override protected function commitProperties():void
	    {
	        super.commitProperties();
	        
	        if (_textChanged)
	        {
	            _textChanged = false;
	            nodeTextArea.text = _text;
	        }	
	        if (_categoryChanged)
	        {
	            _categoryChanged = false;
	            
	            switch(_category)
	            {
	            	case GraphNodeCategory.NORMAL:
	            		nodeTextArea.setStyle( "borderColor",  0x000000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffffff);
	            		nodeTextArea.setStyle( "color",  0x000000);
	            		if(customCM)
	            		{
		            		customCM.getItemById("normal_category").checked = true;
	    	        		customCM.process();
	    	        	}
	            		break;
	            	case GraphNodeCategory.SUBGRAPH:
	            		nodeTextArea.setStyle( "borderColor",  0x000000);
	            		nodeTextArea.setStyle( "backgroundColor",  0xffff00);
	            		nodeTextArea.setStyle( "color",  0x000000);
	            		if(customCM)
	            		{
		            		customCM.getItemById("subfraph_category").checked = true;
	    	        		customCM.process();
	    	        	}
	            		break;	            	
	            	case GraphNodeCategory.COMMAND:
	            		nodeTextArea.setStyle( "borderColor",  0xffff00);
	            		nodeTextArea.setStyle( "backgroundColor",  0x333333);
	            		nodeTextArea.setStyle( "color",  0xffff00);
	            		if(customCM)
	            		{
		            		customCM.getItemById("command_category").checked = true;
	    	        		customCM.process();
	    	        	}
	            		break;        		
	            }          
	        }	
	        if (_typeChanged)
	        {
	            _typeChanged = false;
	            switch(_type)
	            {
	            	case GraphNodeType.NORMAL:
	            		setStyle( "borderColor", 0xE2E2E2);	
	            		if(customCM)
	            		{
		            		customCM.getItemById("initial_type").checked = false;
		            		customCM.getItemById("terminal_type").checked = false;
	    	        		customCM.process();
	    	        	}
		            	break;
	            	case GraphNodeType.INITIAL:
	            		setStyle( "borderColor", 0x00ff00);	
	            		if(customCM)
	            		{
		            		customCM.getItemById("initial_type").checked = true;
	    	        		customCM.process();
	    	        	}
		            	break;
	            	case GraphNodeType.TERMINAL:
	            		setStyle( "borderColor", 0x0000ff);	
	            		if(customCM)
	            		{
		            		customCM.getItemById("terminal_type").checked = true;
	    	        		customCM.process();
	    	        	}
		            	break;
	            }
	        }		            
            if (initialized)
            {
                invalidateSize();
        		invalidateDisplayList();
            }	
    
            if(validator)
	            validator.validate();                
	    }    

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------		
		
		public function duplicate(target:Container):GraphNode		
		{
			if(!parent)
				return null;
			
			if(!(target is Container))
				return null;
				
			if(target is GraphNode)
				return null;			
			
			var newNode:GraphNode = new GraphNode(category, type, text);
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
	    
	    public function edit():void
	    {
	    	editMode(true);
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
	        
	        invalidateDisplayList();		    	
	    }		
		public function alertDestroy():void
		{			
     		if(parent && _mode==M_NORMAL)
     		{
	     		Alert.show(alertDeleteText,alertDeleteTitle,Alert.YES|Alert.NO,this,alertRemoveHandler,null,Alert.NO);			     	
	     	}
		}		    
			    	    
		//--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------	
	    //--------------------------------------------------------------------------
	    
	    private function languageChangeHandler(event:Event):void
	    {
        	_categoryChanged = true;
        	_typeChanged = true;
	    		        	
			for(var i:int=0; i<customCM.items.length; i++)
	    		customCM.items[i].name = menuItemCaptions[i];   
	    	
	    	invalidateProperties();  
	    }
	    	    
	    private function creationCompleteHandler(event:FlexEvent):void
	    {
			addEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
			addEventListener(KeyboardEvent.KEY_DOWN, keyDown); 
			addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
			addEventListener("typeChanged" , typeChangedHandler);

			addEventListener(FocusEvent.FOCUS_IN, nodeFocusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, nodeFocusOutHandler);
	    }	    
	    
	    private function typeChangedHandler(event:Event):void
	    {	    	
	    	if(event.target.type==GraphNodeType.INITIAL && event.target.parent)
	    	{
	    		for each (var child:UIComponent in Container(event.target.parent).getChildren())
	    		{
	    			if(	child is GraphNode && 
	    				child!=event.target && 
	    				GraphNode(child).type==GraphNodeType.INITIAL)
	    			{
	    				GraphNode(child).type = GraphNodeType.NORMAL;
	    			}
	    		}
	    	}
	    }
	    
		private function addTransitionHandler(event:ContextMenuEvent):void
		{
			if(parent && parent is GraphCanvas)
			{
				var gCanvas:GraphCanvas = parent as GraphCanvas;
				if(gCanvas.currentArrow)
				{
					gCanvas.currentArrow.destroy();
					gCanvas.currentArrow = null;
				}				
				gCanvas.addingTransition = true;
				gCanvas.currentArrow = new GraphArrow();
							
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
			Application.application.dispatchEvent(new Event("copyNode"));
		}
		private function setInitialTypeHandler(event:ContextMenuEvent):void
		{
			if(_type==GraphNodeType.INITIAL)
				type = GraphNodeType.NORMAL;
			else
				type = GraphNodeType.INITIAL;
		}
		private function setTerminalTypeHandler(event:ContextMenuEvent):void
		{
			if(_type==GraphNodeType.TERMINAL)
				type = GraphNodeType.NORMAL;
			else
				type = GraphNodeType.TERMINAL;
		}
		private function setNormalCategoryHandler(event:ContextMenuEvent):void
		{
			category = GraphNodeCategory.NORMAL;
		}
		private function setSubgraphCategoryHandler(event:ContextMenuEvent):void
		{
			category = GraphNodeCategory.SUBGRAPH;
		}
		private function setCommandCategoryHandler(event:ContextMenuEvent):void
		{
			category = GraphNodeCategory.COMMAND;
		}

		private function mouseOverHandler(event:MouseEvent):void
		{
	    	MDMContextMenu.refreshMenu(this);
	    	event.stopPropagation();
			
			contextMenuOld = Application.application.contextMenu;
			if(contextMenu)
				Application.application.contextMenu = contextMenu;	
			
			if(parent && parent is GraphCanvas)
			{
				if((parent as GraphCanvas).addingTransition)
				{
					setStyle( "backgroundAlpha", 1.0 );
				}
				else
				{
					arrToolTip = [];
					for each(var arrow:GraphArrow in outArrows)
					{
						var point:Point = Container(parent).contentToGlobal(new Point(arrow.x, arrow.y));
						if(arrow.label)
							arrToolTip.push(ToolTipManager.createToolTip(arrow.label, point.x+arrow.width/2, point.y+arrow.height/2));
						arrow.highlight = true;
					}
				}
			}
		}
		
		private function mouseOutHandler(event:MouseEvent):void
		{			
	    	if(contextMenuOld)
	    		Application.application.contextMenu = contextMenuOld;						

			if(parent && parent is GraphCanvas)
			{
				setStyle( "backgroundAlpha", 0.5 );
			}

			for each(var arrow:GraphArrow in outArrows)
			{
				arrow.highlight = false;
			}

			for each(var toolTip:ToolTip in arrToolTip)
			{
				ToolTipManager.destroyToolTip(toolTip);
			}
			arrToolTip = [];
		}
		
	    private function mouseDownHandler(event:MouseEvent):void
	    {
	    	if(parent && parent is GraphCanvas)
			{
				var gCanvas:GraphCanvas = parent as GraphCanvas;
				
				if(gCanvas.addingTransition)
				{
					gCanvas.addingTransition = false;					
					
					if(gCanvas.currentArrow.fromObject==this)
					{
						gCanvas.currentArrow = null;
						return;
					}
					
					for each (var arrow:GraphArrow in inArrows)
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
							(gCanvas.currentArrow.fromObject as GraphNode).outArrows.addItem(gCanvas.currentArrow);
							(gCanvas.currentArrow.toObject as GraphNode).inArrows.addItem(gCanvas.currentArrow);
							gCanvas.currentArrow.addEventListener("destroyArrow", destroyArrowHandler);
							gCanvas.currentArrow.beginEdit();
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
			if(parent && parent is GraphCanvas)
			{
				if((parent as GraphCanvas).addingTransition)
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
			if(parent && parent is GraphCanvas)
			{
				if((parent as GraphCanvas).addingTransition)
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
				var node:GraphNode = event.target.parent;
				node.invalidateProperties();
				node.invalidateSize();
				node.invalidateDisplayList();		
			}
	    }
	    
	    private function invalidDataHandler(event:ValidationResultEvent):void
	    {
	    	bDataValid = false;
	    	//edit();
	    }
	
	    private function systemManager_mouseMoveHandler(event:MouseEvent):void
	    {
	    	// during a drag, only the GraphNode should get mouse move events
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
	    	if(!(event.target is GraphArrow))
	    		return;
	    	
	    	var arrow:GraphArrow = event.target as GraphArrow;
	    	
	    	for (var i:int=0; i<(arrow.fromObject as GraphNode).outArrows.length; i++)
	    	{	    	
	    		if((arrow.fromObject as GraphNode).outArrows[i] == arrow)
	    		{
	    			(arrow.fromObject as GraphNode).outArrows.removeItemAt(i);
	    			break;
	    		}
	    	}
	    	
	    	for (i=0; i<(arrow.toObject as GraphNode).inArrows.length; i++)
	    	{	    	
	    		if((arrow.toObject as GraphNode).inArrows[i] == arrow)
	    		{
	    			(arrow.toObject as GraphNode).inArrows.removeItemAt(i);
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
			MDMContextMenu.addMenuItemsByType("GraphNode");
		}	    
	}
}
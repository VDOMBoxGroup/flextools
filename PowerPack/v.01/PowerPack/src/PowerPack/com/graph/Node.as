package PowerPack.com.graph
{	
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.controls.SuperTextArea;
import ExtendedAPI.com.ui.SuperNativeMenu;
import ExtendedAPI.com.ui.SuperNativeMenuItem;

import PowerPack.com.managers.ContextManager;
import PowerPack.com.managers.LanguageManager;
import PowerPack.com.validators.NodeTextValidator;

import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;

import mx.binding.utils.*;
import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.ToolTip;
import mx.core.Application;
import mx.core.Container;
import mx.core.ScrollPolicy;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.managers.IFocusManagerComponent;
import mx.managers.ToolTipManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

[Event(name="disposed", type="flash.events.Event")]	

public class Node extends Canvas 
	implements IFocusManagerComponent
{
	//--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    public static const TEXT_WIDTH_PADDING:int = 5+1;
    public static const TEXT_HEIGHT_PADDING:int = 4+1;
    
    /**
    * default minimum node size
    */
    public static const DEFAULT_WIDTH:Number = 30;
    public static const DEFAULT_HEIGHT:Number = 20;
    
    /**
    * text area right padding
    */
    public static const PADDING:Number = 0;
    		
	/**
	 *	defines current node state values
	 */
    private static const M_NORMAL:Number = 0;
    private static const M_EDITING:Number = 1;
    
   	public static var copyNode:Node;

    //--------------------------------------------------------------------------
    //
    //  Variables and properties
    //
    //--------------------------------------------------------------------------
    
    private static var defaultItemCaptions:Object = {
    	node_add_trans:"Add transition", 
    	node_delete:"Delete state", 
    	node_copy:"Copy state",
    	node_initial:"Initial",
    	node_terminal:"Terminal",
    	node_normal:"Normal",
    	node_subgraph:"Subgraph",
    	node_command:"Command", 
    	node_breakpoint:"Toggle breakpoint",
    	node_enabled:"Enabled",
    	node_label:"State",
    	node_alert_delete_title:"Confirmation",
    	node_alert_delete_text:"Are you sure want to delete this state?"};

    // Define a static variable.
    private static var _classConstructed:Boolean = classConstruct();
    
    public static function get classConstructed():Boolean
    {
    	return _classConstructed;
    }
    
    // Define a static method.
    private static function classConstruct():Boolean 
    {
        if (!StyleManager.getStyleDeclaration("Node"))
        {
            // If there is no CSS definition for component, 
            // then create one and set the default value.
            var newStyleDeclaration:CSSStyleDeclaration;
            
            if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("Canvas")))
            {
                newStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("themeColor", "haloBlue");
            }     
		
			newStyleDeclaration.setStyle( "borderStyle", "solid" );
			newStyleDeclaration.setStyle( "borderThickness", 1);
			newStyleDeclaration.setStyle( "margin", 2);			
			newStyleDeclaration.setStyle( "borderColor", 0xE2E2E2);			
			newStyleDeclaration.setStyle( "backgroundColor", 0xE2E2E2 );
			newStyleDeclaration.setStyle( "backgroundAlpha", 0.5 );
			                
            StyleManager.setStyleDeclaration("Node", newStyleDeclaration, true);
        }
	
		LanguageManager.setSentences(defaultItemCaptions);
		    	              
        return true;
    }        
        
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
    private var _over:Boolean;
    private var _focused:Boolean; 
    private var _created:Boolean; 
		
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
    
    [ArrayElementType("Connector")]
    public var inArrows:ArrayCollection = new ArrayCollection();
    
    [ArrayElementType("Connector")]
    public var outArrows:ArrayCollection = new ArrayCollection();
    
    [Bindable]
    public var arrTrans:Array = [];
    
	[ArrayElementType("ToolTip")]
    public var arrToolTip:Array = [];
   	
   	public var canvas:GraphCanvas;

	/**
	* possible values: M_NORMAL, M_EDITING
	*/
	private var _mode:int = M_NORMAL;
    
	private var validator:NodeTextValidator;
	
    //--------------------------------------------------------------------------

    /**
     *  The TextArea sub-control that displays the node text.
     */	    
    public var nodeTextArea:SuperTextArea;	    
    //--------------------------------------------------------------------------
    
    /**
     * 	Storage for the text property.
     */ 
	private var _text:String;
	private var _textChanged:Boolean;
	
    [Bindable("textChanged")]
    [Inspectable(category="General", defaultValue="")]

    /**
     *  Node text.
     *
     *  @default "Node"
     *
     */
    public function set text(value:String):void
    {
    	//value = value.replace(/\r/g, "\\r");
    	//value = value.replace(/\n/g, "\\n");
    	//value = value.replace(/\t/g, "\\t");	        

    	if(_text != value)
    	{
    		_text = value;
    		
        	_textChanged = true;
        
        	invalidateProperties();
        	invalidateSize();
        	invalidateDisplayList();
         
        	dispatchEvent(new NodeEvent(NodeEvent.TEXT_CHANGED));
     	}
    }
    public function get text():String
    {
        return _text;
    }
    //--------------------------------------------------------------------------
    
	private var _category:String = NodeCategory.NORMAL;	
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
    	if(_category != value)
    	{
	    	_category = value;
	    	
	        _categoryChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new NodeEvent(NodeEvent.CATEGORY_CHANGED));
	    }
    }
    public function get category():String
    {
        return _category;
    }	
    //--------------------------------------------------------------------------

	private var _type:String = NodeType.NORMAL;	
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
    	if(_type != value)
    	{
	    	_type = value;
	    	
	        _typeChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new NodeEvent(NodeEvent.TYPE_CHANGED));
	    }
    }
    public function get type():String
    {
        return _type;
    }	
	
	private var _breakpoint:Boolean = false;	
	private var _breakpointChanged:Boolean = false;

    [Bindable("breakpointChanged")]
    [Inspectable(category="Other", defaultValue=false, type=Boolean)]

    /**
     *  Toggle node breakpoint.
     *
     *  @default "false"
     *
     */
    public function set breakpoint(value:Boolean):void
    {
    	if(_breakpoint != value)
    	{
	    	_breakpoint = value;
	    	
	        _breakpointChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	        
	        dispatchEvent(new NodeEvent(NodeEvent.BREAKPOINT_CHANGED));
	    }
    }
    public function get breakpoint():Boolean
    {
        return _breakpoint;
    }	    
	
	//--------------------------------------------------------------------------
	
 	private var _enabledChanged:Boolean = false;

	[Bindable("enabledChanged")]
    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]

    override public function set enabled(value:Boolean):void
    {
        if(super.enabled != value)
        {
	        super.enabled = value;
	
        	_enabledChanged = true;
        	
	        if (nodeTextArea)
	            nodeTextArea.enabled = value;
        	
        	invalidateProperties();
        	invalidateSize();
        	invalidateDisplayList();
        	
	        dispatchEvent(new NodeEvent(NodeEvent.ENABLED_CHANGED));
	   	}	
    }

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function Node(	category:String = 'Normal',//NodeCategory.NORMAL, 
							type:String = 'Normal',//NodeType.NORMAL, 
							text:String = null )
	{
		super();
		
		this.category = category;
		this.type = type;
		
		if(text)
			this.text = text;
		else
			this.text = LanguageManager.sentences['node_label'];
		
		doubleClickEnabled = true;
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
		if(contextMenu)
		{	
        	contextMenu.removeEventListener(Event.SELECT, contextMenuSelectHandler);	
        	SuperNativeMenu(contextMenu).dispose();        	 
  		}
  		
  		if(nodeTextArea)
  			nodeTextArea.removeEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
  			  				
  		stopDragging();   			

		removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
		removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
		removeEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
		removeEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
		removeEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
		
		removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		removeEventListener(NodeEvent.TYPE_CHANGED , typeChangedHandler);
   		//removeEventListener("xChanged", positionChangedHandler);
   		//removeEventListener("yChanged", positionChangedHandler);
       		
		if(copyNode == this)
		{
			copyNode = null;
			Application.application.dispatchEvent(new Event("copyNode"));
		}
		
		while(inArrows.length)
			inArrows[0].dispose();
			
		while(outArrows.length)
			outArrows[0].dispose();

        if(parent)
           	parent.removeChild(this);
           	
       	dispatchEvent(new NodeEvent(NodeEvent.DISPOSED));
	}
			
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if(focusManager)
        {
        	focusManager.showFocusIndicator = false;
        }
        
        if (!nodeTextArea)
        {
            nodeTextArea = new SuperTextArea();
            nodeTextArea.editable = false;
            nodeTextArea.selectable = false;	

           	nodeTextArea.enabled = enabled;
         	nodeTextArea.text = text;
         	nodeTextArea.wordWrap = false;
         	nodeTextArea.horizontalScrollPolicy = ScrollPolicy.OFF;
			nodeTextArea.verticalScrollPolicy = ScrollPolicy.OFF;
			
            addChild(nodeTextArea);
            
            nodeTextArea.addEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
        }
        
        if (ContextManager.FLASH_CONTEXT_MENU && !contextMenu)
        {
        	contextMenu = new SuperNativeMenu();
        	
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_add_trans'], 'add_trans'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_delete'], 'delete'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_copy'], 'copy'));

        	contextMenu.addItem(new SuperNativeMenuItem('separator'));
    	
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_initial'], 'initial', type==NodeType.INITIAL, "type"));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_terminal'], 'terminal', type==NodeType.TERMINAL, "type"));
        	
        	contextMenu.addItem(new SuperNativeMenuItem('separator'));

        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_normal'], 'normal', category==NodeCategory.NORMAL, "category", true));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_subgraph'], 'subgraph', category==NodeCategory.SUBGRAPH, "category", true));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_command'], 'command', category==NodeCategory.COMMAND, "category", true));

        	contextMenu.addItem(new SuperNativeMenuItem('separator'));
        	
        	contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['node_enabled'], 'enabled', enabled));
        	contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['node_breakpoint'], 'breakpoint', breakpoint));

			for each (var item:NativeMenuItem in contextMenu.items) {
	       		//LanguageManager.bindSentence('node_'+item.name, item);
	  		}
			
        	contextMenu.addEventListener(Event.SELECT, contextMenuSelectHandler);        	 
        }	
        
        if (!validator)
        {
        	validator = new NodeTextValidator();
			validator.source = this;
			validator.property = "text";
			validator.listener = nodeTextArea;
			validator.required = true;
        }    
        
        if(!_created) {
    		_created = true;
    		
    		canvas = parent as GraphCanvas;
			
			addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);			
			addEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
			
			addEventListener(KeyboardEvent.KEY_DOWN, keyDown); 
			addEventListener(NodeEvent.TYPE_CHANGED , typeChangedHandler);
       		
       		//addEventListener("xChanged", positionChangedHandler);
       		//addEventListener("yChanged", positionChangedHandler);			
    	} 
    }

    override protected function commitProperties():void
    {
        super.commitProperties();
        
        var _needValidate:Boolean = false;
        
        if (_textChanged)
        {
        	_needValidate = true;
            _textChanged = false;
            
            if(text.length>255)
            {
	        	_needValidate = false;         
	        	nodeTextArea.text = text.substr(0, 255) + '...';   	
            }
            else
            {            
            	nodeTextArea.text = text;
            }
            
            _categoryChanged = true;

            invalidateSize();
    		invalidateDisplayList();
        }
                
        if (_categoryChanged)
        {
        	_needValidate = true;
            _categoryChanged = false;
            
            switch(_category)
            {
            	case NodeCategory.SUBGRAPH:
            		nodeTextArea.setStyle( "borderColor",  0x000000);
            		nodeTextArea.setStyle( "backgroundColor",  0xffff00);
            		nodeTextArea.setStyle( "color",  0x000000);
            		if(contextMenu)
	            		contextMenu.getItemByName("subgraph").checked = true;
            		break;	            	

            	case NodeCategory.COMMAND:
            		nodeTextArea.setStyle( "borderColor",  0xffff00);
            		nodeTextArea.setStyle( "backgroundColor",  0x004e98);
            		nodeTextArea.setStyle( "color",  0xffff00);
            		if(contextMenu)
	            		contextMenu.getItemByName("command").checked = true;
            		break;
            		        		
            	case NodeCategory.NORMAL:
            	default:
            		_category = NodeCategory.NORMAL;
            		nodeTextArea.setStyle( "borderColor",  0x000000);
            		nodeTextArea.setStyle( "backgroundColor",  0xffffff);
            		nodeTextArea.setStyle( "color",  0x000000);
            		if(contextMenu)
	            		contextMenu.getItemByName("normal").checked = true;
            		break;            
            }          
			
			nodeTextArea.styleChanged(null);
			nodeTextArea.validateDisplayList();			
			styleChanged(null);
			
			nodeTextArea.invalidateDisplayList();
    		invalidateDisplayList();
        }	

        if (_typeChanged)
        {
            _typeChanged = false;

            switch(_type)
            {
            	case NodeType.INITIAL:
            		setStyle( "borderColor", 0x00ff00);	
            		if(contextMenu)
	            		contextMenu.getItemByName("initial").checked = true;
	            	break;

            	case NodeType.TERMINAL:
            		setStyle( "borderColor", 0x0000ff);	
            		if(contextMenu)
	            		contextMenu.getItemByName("terminal").checked = true;
	            	break;

            	case NodeType.NORMAL:
            	default:
            		_type = NodeType.NORMAL;
            		setStyle( "borderColor", 0xE2E2E2);	
            		if(contextMenu)
            		{
	            		contextMenu.getItemByName("initial").checked = false;
	            		contextMenu.getItemByName("terminal").checked = false;
    	        	}
	            	break;
            }
			
			styleChanged(null);
			nodeTextArea.styleChanged(null);
    		invalidateDisplayList();
        }	
        
        if(_enabledChanged)
        {
            _enabledChanged = false;
			contextMenu.getItemByName("enabled").checked = enabled;
    		invalidateDisplayList();
        }

        if(_breakpointChanged)
        {
        	_breakpointChanged = false;
        	contextMenu.getItemByName("breakpoint").checked = breakpoint;
    		invalidateDisplayList();
        }	            
        
        if(validator && _needValidate)
        {
        	_needValidate = false;
			validator.validate();                
        }
    }    

	override protected function measure():void 
	{
		var numLines:int = nodeTextArea.field.numLines;
		nodeTextArea.width = DEFAULT_WIDTH;
		
		for (var i:int=0; i<numLines; i++)
		{
	        var lineMetrics:TextLineMetrics = nodeTextArea.measureText(nodeTextArea.field.getLineText(i));
			nodeTextArea.width = Math.max(lineMetrics.width + TEXT_WIDTH_PADDING + (_mode==M_EDITING?PADDING:0), 
				nodeTextArea.width);
		}		
		nodeTextArea.height = lineMetrics.height*numLines + TEXT_HEIGHT_PADDING;
		
        super.measure();
		
        //var borderThickness:Number = getStyle("borderThickness");            
        var margin:Number = getStyle("margin");       

        measuredWidth += margin;        
        measuredHeight += margin;            
		
        measuredMinWidth = measuredWidth;
        measuredMinHeight = measuredHeight;    
        
        setActualSize(measuredWidth, measuredHeight);       
    }        
    
    override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var borderThickness:Number = getStyle("borderThickness");
		var margin:Number = getStyle("margin");
			
		if(nodeTextArea)
		{				
			nodeTextArea.move(margin, margin);
		}
	}


	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------		
	
	public function clone():Node
	{
		var newNode:Node = new Node(category, type, text);
		newNode.enabled = enabled;
		newNode.breakpoint = breakpoint;		
		newNode.x = x;
		newNode.y = y;
		return newNode;		
	}
	
	public function duplicate(target:Container):Node		
	{
		if(!parent)
			return null;
		
		if(!(target is Container))
			return null;
			
		if(target is Node)
			return null;			
		
		var newNode:Node = clone();
		target.addChild(newNode);
		newNode.type = type;
		newNode.move( target.contentMouseX, target.contentMouseY );			
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
			
		if(text.length > 500)
			return;
			
        if(_editing)
        {
            _mode = M_EDITING;
            nodeTextArea.editable = true;
            nodeTextArea.selectable = true;
         	nodeTextArea.setSelection(0, nodeTextArea.text.length);
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, true);
			nodeTextArea.addEventListener(Event.CHANGE, textAreaChange); 
			nodeTextArea.addEventListener(FocusEvent.FOCUS_OUT, textAreaFocusOut);
			
			scrollToNode();			
        }
        else
        {
            _mode = M_NORMAL;
			systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, true);
			nodeTextArea.removeEventListener(Event.CHANGE, textAreaChange); 
            nodeTextArea.removeEventListener(FocusEvent.FOCUS_OUT, textAreaFocusOut);
            nodeTextArea.selectable = false;
            nodeTextArea.editable = false;
        	nodeTextArea.setSelection(0, 0);
        }
        
        nodeTextArea.styleChanged(null);
        styleChanged(null);
        
        nodeTextArea.invalidateDisplayList();
        invalidateDisplayList();     		    	
    }
    
	public function alertDestroy():void
	{			
 		if(parent && _mode==M_NORMAL)
 		{
     		SuperAlert.show(
     			LanguageManager.sentences['node_alert_delete_text'],
     			LanguageManager.sentences['node_alert_delete_title'],
     			Alert.YES|Alert.NO,null,alertRemoveHandler,null,Alert.YES);			     	
     	}
	}	
	
	public function scrollToNode():void
	{
		if(!this.parent)
			return;
			
		if(!(this.parent is Container))
			return;
		
		var cP:Point = new Point(x+width/2, y+height/2);  
		
		Container(this.parent).verticalScrollPosition = cP.y - Container(this.parent).height/2;
		Container(this.parent).horizontalScrollPosition = cP.x - Container(this.parent).width/2
	} 	    
		    	    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
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
        	    
    private function typeChangedHandler(event:Event):void
    {	    	
    	if(event.target.type==NodeType.INITIAL && event.target.parent)
    	{
    		for each (var child:UIComponent in Container(event.target.parent).getChildren())
    		{
    			if(	child is Node && 
    				child!=event.target && 
    				Node(child).type==NodeType.INITIAL)
    			{
    				Node(child).type = NodeType.NORMAL;
    			}
    		}
    	}
    }
    
	private function contextMenuSelectHandler(event:Event):void
	{
		if(event.target.name == "add_trans")
		{
			if(canvas)
			{
				if(canvas.currentArrow)
				{
					canvas.currentArrow.dispose();
					canvas.currentArrow = null;
				}
							
				canvas.addingTransition = true;
				canvas.currentArrow = new Connector();
							
				canvas.addChildAt(canvas.currentArrow, 0);
				canvas.currentArrow.fromObject = this;
				canvas.currentArrow.addEventListener(ConnectorEvent.FROM_OBJECT_CHANGED, onFromObjectChange);
			}
				
			dispatchEvent(new NodeEvent(NodeEvent.ADDING_TRANSITION));
		}
		else if(event.target.name == "delete")
		{
     		alertDestroy();
		}
		else if(event.target.name == "copy")
		{
			copyNode = this;
			Application.application.dispatchEvent(new Event("copyNode"));
		}
		else if(event.target.name == "initial")
		{
			if(_type==NodeType.INITIAL)
				type = NodeType.NORMAL;
			else
				type = NodeType.INITIAL;
		}
		else if(event.target.name == "terminal")
		{
			if(_type==NodeType.TERMINAL)
				type = NodeType.NORMAL;
			else
				type = NodeType.TERMINAL;
		}
		else if(event.target.name == "normal")
		{
			category = NodeCategory.NORMAL;
		}
		else if(event.target.name == "subgraph")
		{
			category = NodeCategory.SUBGRAPH;
		}
		else if(event.target.name == "command")
		{
			category = NodeCategory.COMMAND;
		}
		else if(event.target.name == "enabled")
		{
			enabled = !enabled;
		}
		else if(event.target.name == "breakpoint")
		{
			breakpoint = !breakpoint;
		}
	}

	private function mouseOverHandler(event:MouseEvent):void
	{
    	event.stopPropagation();
    	
    	_over = true;
		
		if(canvas)
		{
			if(canvas.addingTransition)
			{
				setStyle( "backgroundAlpha", 1.0 );
				
				if(canvas.currentArrow.fromObject!=this)
					canvas.currentArrow.toObject = this;
			}
			else
			{
				arrToolTip = [];
				for each(var arrow:Connector in outArrows)
				{
					var point:Point = Container(parent).contentToGlobal(new Point(arrow.x, arrow.y));
					if(arrow.label)
						arrToolTip.push(ToolTipManager.createToolTip(arrow.label, point.x+arrow.width/2, point.y+arrow.height/2));
					arrow.highlighted = true;
				}
			}
		}
	}
	
	private function mouseOutHandler(event:MouseEvent):void
	{	
		_over = false;
		
		if(canvas)
		{
			setStyle( "backgroundAlpha", 0.5 );

			if(canvas.addingTransition)
			{
				canvas.currentArrow.toObject = null;
			}
		}

		for each(var arrow:Connector in outArrows)
		{
			arrow.highlighted = false;
		}

		for each(var toolTip:ToolTip in arrToolTip)
		{
			ToolTipManager.destroyToolTip(toolTip);
		}
		
		arrToolTip = [];
	}
	
    private function mouseDownHandler(event:MouseEvent):void
    {
    	// don't use event.stopPropagation() here. 
    	// textInput must recieve focus    	
    	
    	if(canvas)
		{
			if(canvas.addingTransition)
			{
				canvas.addingTransition = false;					
				
				if(canvas.currentArrow.fromObject==this)
				{
					canvas.currentArrow.dispose();
					canvas.currentArrow = null;
					return;
				}
				
				for each (var arrow:Connector in inArrows)
				{
					if(arrow.fromObject == canvas.currentArrow.fromObject)
					{
						canvas.currentArrow.dispose();
						canvas.currentArrow = null;
						return;
					}
				}
				
				for each (arrow in outArrows)
				{
					if(arrow.toObject == canvas.currentArrow.fromObject)
					{
						canvas.currentArrow.dispose();
						canvas.currentArrow = null;
						return;
					}
				}
				
				canvas.currentArrow.removeEventListener(ConnectorEvent.FROM_OBJECT_CHANGED, onFromObjectChange);
				canvas.currentArrow.toObject = this;
					
				BindingUtils.bindProperty(canvas.currentArrow, 'data',
					canvas.currentArrow.fromObject, 'arrTrans');
				
				(canvas.currentArrow.fromObject as Node).outArrows.addItem(canvas.currentArrow);
				(canvas.currentArrow.toObject as Node).inArrows.addItem(canvas.currentArrow);
				canvas.currentArrow.addEventListener(ConnectorEvent.DISPOSED, destroyArrowHandler);
				
				canvas.currentArrow.beginEdit();
										
				canvas.currentArrow = null;
				return;
			}
		}
				
		bringToFront();
			        
        if (_mode==M_NORMAL && enabled && isNaN(regX))
            startDragging(event);
    }
    
    private function onFromObjectChange(event:Event):void
    {
    	if(!event.target.fromObject)    	
		{
			canvas.addingTransition = false;
			canvas.currentArrow.dispose();
			canvas.currentArrow = null;
		}
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
    	// don't use event.stopPropagation() here. 
    	// textInput must recieve key events
    	
		if(canvas && canvas.addingTransition)
		{
			return;
		}
		
		if(event.keyCode == Keyboard.DELETE)
     	{
     		alertDestroy();
	    }
	    else if(//event.keyCode == Keyboard.ENTER ||
	    	event.keyCode == Keyboard.F2)
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
	    else if(event.keyCode == Keyboard.ESCAPE)
	    {
	    	editMode(false);
	    	nodeTextArea.text = _text;
	    	
	    	invalidateProperties();
	    	invalidateSize();
	    	invalidateDisplayList();
	    }		    
	}
     
    private function alertRemoveHandler(event:CloseEvent):void 
    {
    	if(parent && event.detail==Alert.YES)
    	{
			dispose();
        }
	}
    
    private function doubleClickHandler(event:MouseEvent):void
    {
    	event.stopPropagation();
    	
		if(canvas && canvas.addingTransition)
		{
			return;			
		}	    	

		bringToFront();						
		editMode(true);	  
    }
    
    private function wheelHandler(event:MouseEvent):void
    {
    	if(nodeTextArea.maxVerticalScrollPosition==0)
    	{
    		event.stopPropagation();
    		event.stopImmediatePropagation();
    		event.preventDefault();
    	
    		parent.dispatchEvent(event);
    	}
    }
	
    override protected function focusOutHandler(event:FocusEvent):void
    {
		setStyle( "backgroundColor", 0xE2E2E2 );
    	
    	_focused = false;

        super.focusOutHandler(event);

        invalidateDisplayList();
    }

    override protected function focusInHandler(event:FocusEvent):void
    {
		setStyle( "backgroundColor", getStyle("themeColor") );
    	
    	_focused = true;
    	
        super.focusInHandler(event);

        invalidateDisplayList();
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
			var node:Node = event.target.parent;
			
			node._categoryChanged = true;
			
			node.invalidateProperties();
			node.invalidateSize();
			node.invalidateDisplayList();		
		}
    }
    
    public function destroyArrowHandler(event:Event):void
    {
    	if(!(event.target is Connector))
    		return;
    	
    	var arrow:Connector = event.target as Connector;
		var i:int = -1;
		
		i = (arrow.fromObject as Node).outArrows.getItemIndex(arrow);
		if(i>=0)
			(arrow.fromObject as Node).outArrows.removeItemAt(i);
    	
		i = (arrow.toObject as Node).inArrows.getItemIndex(arrow);
		if(i>=0)
  			(arrow.toObject as Node).inArrows.removeItemAt(i);
    }
    
}
}
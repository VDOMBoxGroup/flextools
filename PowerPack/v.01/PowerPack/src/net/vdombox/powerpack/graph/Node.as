package net.vdombox.powerpack.graph
{	
import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;
import net.vdombox.powerpack.lib.extendedapi.controls.SuperTextArea;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenu;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenuItem;
import net.vdombox.powerpack.lib.extendedapi.utils.ObjectUtils;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

import net.vdombox.powerpack.Template;
import net.vdombox.powerpack.managers.CashManager;
import net.vdombox.powerpack.managers.ContextManager;
import net.vdombox.powerpack.managers.LanguageManager;
import net.vdombox.powerpack.utils.GeneralUtils;
import net.vdombox.powerpack.validators.NodeTextValidator;

import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.NativeMenuItem;
import flash.display.Shape;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.Timer;

import mx.binding.utils.*;
import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.controls.Image;
import mx.controls.ToolTip;
import mx.core.Application;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.ScrollPolicy;
import mx.core.UIComponent;
import mx.effects.Fade;
import mx.effects.Move;
import mx.events.CloseEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.MoveEvent;
import mx.events.ValidationResultEvent;
import mx.graphics.RectangularDropShadow;
import mx.managers.IFocusManagerComponent;
import mx.managers.PopUpManager;
import mx.managers.ToolTipManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.NameUtil;

[Event(name="disposed", type="flash.events.Event")]	

public class Node extends Canvas 
	implements IFocusManagerComponent
{
	//--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    public static const TEXT_WIDTH_PADDING:int = 5+2;
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
    
   	public static var nodes:Dictionary = new Dictionary(); 
   	public static var deleteConfirmation:Boolean = true;

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
    
    private static var defaultItemCaptions:Object = {
    	node_add_trans:"Add transition", 
    	node_jump:"Jump to graph", 
    	node_delete:"Delete state", 
    	
    	node_cut:"Cut", 
    	node_copy:"Copy",
    	
    	node_initial:"Initial",
    	node_terminal:"Terminal",
    	
    	node_normal:"Normal",
    	node_subgraph:"Subgraph",
    	node_command:"Command", 
    	node_resource:"Resource", 
    	
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
		
			newStyleDeclaration.setStyle( "cornerRadius", 3);
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
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *	Constructor
	 */ 
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
		//focusEnabled = true;
		//mouseFocusEnabled = true;
		tabEnabled = true;	
		tabChildren = false;
		styleName = this.className;
		cacheAsBitmap = true;		
		
		addEventListener(FlexEvent.ADD, addHandler);
		
		nodes[this] = this;
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
		destroyTimers();
		
		destroyImageTip();
		
		if(contextMenu)
		{	
        	contextMenu.removeEventListener(Event.SELECT, contextMenuSelectHandler);	
        	SuperNativeMenu(contextMenu).dispose();        	 
  		}
  		
  		if(nodeTextArea)
  		{
  			nodeTextArea.removeEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
			nodeTextArea.removeEventListener(KeyboardEvent.KEY_DOWN, textAreaKeyDown);
  		}
  		
  		if(nodeCB)
  		{
  			nodeCB.removeEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
          	nodeCB.removeEventListener(KeyboardEvent.KEY_DOWN, comboBoxKeyDown);
          	nodeCB.removeEventListener(ListEvent.CHANGE , comboBoxChange);
  		}

		if(validator)
		{
			validator.removeEventListener(ValidationResultEvent.VALID, validatorHandler);
			validator.removeEventListener(ValidationResultEvent.INVALID, validatorHandler);
		}
  			  				
  		systemManager.removeEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        systemManager.removeEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);

        systemManager.stage.removeEventListener(
            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);  			
		
		removeEventListener(FlexEvent.ADD, addHandler);
		removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
		removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
		removeEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
		removeEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
		removeEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
		removeEventListener(MouseEvent.CONTEXT_MENU , contextHandler);
		
		removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		removeEventListener(NodeEvent.TYPE_CHANGED , typeChangedHandler);
   		
   		removeEventListener(MoveEvent.MOVE, moveHandler);
       		
		while(inArrows.length)
			inArrows[0].dispose();
			
		while(outArrows.length)
			outArrows[0].dispose();

        if(parent)
           	parent.removeChild(this);
           	
       	dispatchEvent(new NodeEvent(NodeEvent.DISPOSED));
       	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
       	
       	delete nodes[this];
	}
	        
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
    private var _over:Boolean;
    private var _focused:Boolean; 
    private var _created:Boolean;
    private var _needRefreshStyles:Boolean; 
    private var _isValidText:Boolean;
    private var _rightPadding:int;
    private var _needValidate:Boolean;
		
	/**
	* possible values: M_NORMAL, M_EDITING
	*/
	private var _mode:int = M_NORMAL;
	
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
    
    [ArrayElementType("net.vdombox.powerpack.graph.Connector")]
    public var inArrows:ArrayCollection = new ArrayCollection();
    
    [ArrayElementType("net.vdombox.powerpack.graph.Connector")]
    public var outArrows:ArrayCollection = new ArrayCollection();
    
    [Bindable]
    public var arrTrans:Array = [];
    
	[ArrayElementType("ToolTip")]
    public var arrToolTip:Array = [];
   	
   	public var canvas:GraphCanvas;
    
	private var validator:NodeTextValidator;

    /**
     *  The TextArea sub-control that displays the node text.
     */	    
    public var nodeTextArea:SuperTextArea;	
    
    /**
     *  The ComboBox sub-control that displays the resource.
     */	    
    public var nodeCB:ComboBox;    
    
    private var nodePanel:UIComponent;
    
    private var flagShape:Shape;
    
    private var tipImage:Image;

    private var showTimer:Timer;
    private var hideTimer:Timer;
    
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
    
    //----------------------------------
    //  dropShadow
    //----------------------------------
    
    private var _dropShadow:Boolean;
    
    public function set dropShadow(value:Boolean):void
    {
    	if(_dropShadow != value)
    	{
    		_dropShadow = value;
    		
        	invalidateDisplayList();
     	}
    }
    public function get dropShadow():Boolean
    {
        return _dropShadow;
    }        
	
    //----------------------------------
    //  selected
    //----------------------------------
    
    private var _selected:Boolean;
    private var _selectedChanged:Boolean;
    
    public function set selected(value:Boolean):void
    {
    	if(_selected != value)
    	{
    		_selected = value;
    		
        	_selectedChanged = true;
        
        	invalidateDisplayList();
         
        	dispatchEvent(new NodeEvent(NodeEvent.SELECTED_CHANGED));
     	}
    }
    public function get selected():Boolean
    {
        return _selected;
    }        
    
    //----------------------------------
    //  text
    //----------------------------------
        
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
        	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
     	}
    }
    public function get text():String
    {
        return _text;
    }

    //----------------------------------
    //  category
    //----------------------------------
    
	private var _category:String;	
	private var _categoryChanged:Boolean = false;
	    
    [Bindable("categoryChanged")]
    [Inspectable(category="General", defaultValue=GraphNodeCategory.NORMAL, enumeration="Normal,Subgraph,Command,Resource")]

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
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	    }
    }
    public function get category():String
    {
        return _category;
    }	
    
    //----------------------------------
    //  type
    //----------------------------------

	private var _type:String;	
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
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	    }
    }
    public function get type():String
    {
        return _type;
    }	
	
    //----------------------------------
    //  breakpoint
    //----------------------------------
    	
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
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	    }
    }
    public function get breakpoint():Boolean
    {
        return _breakpoint;
    }	    
	
    //----------------------------------
    //  enabled
    //----------------------------------
	
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
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	   	}	
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
        
        if(!nodeTextArea)
        {
            nodeTextArea = new SuperTextArea();
            nodeTextArea.editable = false;
            nodeTextArea.selectable = false;	
			nodeTextArea.focusEnabled = false;
			
           	nodeTextArea.enabled = enabled;
         	nodeTextArea.text = text;
         	nodeTextArea.wordWrap = false;
         	nodeTextArea.horizontalScrollPolicy = ScrollPolicy.OFF;
			nodeTextArea.verticalScrollPolicy = ScrollPolicy.OFF;
			
			if(category == NodeCategory.RESOURCE)
			{
				nodeTextArea.visible = false;
				nodeTextArea.includeInLayout = false;	
			}			
            addChild(nodeTextArea);
            
            nodeTextArea.addEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
			nodeTextArea.addEventListener(KeyboardEvent.KEY_DOWN, textAreaKeyDown);
        }
        
        if(!flagShape)
        {
			flagShape = new Shape();
			
			flagShape.graphics.lineStyle(1, 0xffffff, 0.5);
			flagShape.graphics.beginFill(0xff0000, 1.0);
			flagShape.graphics.lineTo(7, 3);
			flagShape.graphics.lineTo(1, 6);
			flagShape.graphics.lineTo(1, 9);
			flagShape.graphics.lineTo(0, 9);
			flagShape.graphics.lineTo(0, 0);
			flagShape.graphics.endFill();
			
			var shapeRect:Rectangle = flagShape.getBounds(nodeTextArea);
			
			_rightPadding = shapeRect.width + 3;   	
        }
        
        if(!nodeCB)
        {
        	nodeCB = new ComboBox();
        	nodeCB.setStyle("cornerRadius", 3);
        	nodeCB.focusEnabled = false;
        	
			nodeCB.labelField = '@name';
			
			if(category != NodeCategory.RESOURCE)
			{
				nodeCB.visible = false;
				nodeCB.includeInLayout = false;	
			}
	        addChild(nodeCB);
	        
            nodeCB.addEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
        	nodeCB.addEventListener(KeyboardEvent.KEY_DOWN, comboBoxKeyDown, false, 10);
        	nodeCB.addEventListener(ListEvent.CHANGE , comboBoxChange);
        }
        
        if(!nodePanel)
        {
        	nodePanel = new UIComponent();
        	nodePanel.focusEnabled = false;
        	
        	addChild(nodePanel);
        }
        
        if (ContextManager.FLASH_CONTEXT_MENU && !contextMenu)
        {
        	contextMenu = new SuperNativeMenu();
        	
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_add_trans'], 'add_trans'));
	       	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_jump'], 'jump', false, null, false, false));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_delete'], 'delete'));

        	contextMenu.addItem(new SuperNativeMenuItem('separator'));

        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_cut'], 'cut'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['node_copy'], 'copy'));

        	contextMenu.addItem(new SuperNativeMenuItem('separator'));
    	
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_initial'], 'initial', type==NodeType.INITIAL, "type"));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_terminal'], 'terminal', type==NodeType.TERMINAL, "type"));
        	
        	contextMenu.addItem(new SuperNativeMenuItem('separator'));

        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_normal'], 'normal', category==NodeCategory.NORMAL, "category", true));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_subgraph'], 'subgraph', category==NodeCategory.SUBGRAPH, "category", true));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_command'], 'command', category==NodeCategory.COMMAND, "category", true));
        	contextMenu.addItem(new SuperNativeMenuItem('radio', LanguageManager.sentences['node_resource'], 'resource', category==NodeCategory.RESOURCE, "category", true));

        	contextMenu.addItem(new SuperNativeMenuItem('separator'));
        	
        	contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['node_enabled'], 'enabled', enabled));
        	contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['node_breakpoint'], 'breakpoint', breakpoint));
			
        	contextMenu.addEventListener(Event.SELECT, contextMenuSelectHandler);        	 
        }	
        
        if (!validator)
        {
        	validator = new NodeTextValidator();
			validator.source = this;
			validator.property = "text";
			validator.required = true;
			
			validator.addEventListener(ValidationResultEvent.VALID, validatorHandler);
			validator.addEventListener(ValidationResultEvent.INVALID, validatorHandler);
        }    
        
        if(!_created) {
    		_created = true;
    		
    		canvas = parent as GraphCanvas;
			
			addEventListener(MouseEvent.CONTEXT_MENU , contextHandler);
			addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN , mouseDownHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);			
			addEventListener(MouseEvent.MOUSE_WHEEL , wheelHandler);
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown); 
			addEventListener(NodeEvent.TYPE_CHANGED , typeChangedHandler);
       		
       		addEventListener(MoveEvent.MOVE, moveHandler);
    	} 
    }
	
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (_typeChanged || _needRefreshStyles)
        {
            clearStyle("borderColor");
            
            switch(type)
            {
            	case NodeType.INITIAL:
            		setStyle( "borderColor", 0x00ff00);	
	            	break;

            	case NodeType.TERMINAL:
            		setStyle( "borderColor", 0x0000ff);	
	            	break;

            	case NodeType.NORMAL:
            	default:
            		setStyle( "borderColor", 0xE2E2E2);	
	            	break;
            }
    		invalidateDisplayList();
        }

        if (_categoryChanged || _needRefreshStyles)
        {
            nodeTextArea.clearStyle("borderColor");
            nodeTextArea.clearStyle("backgroundColor");
            nodeTextArea.clearStyle("color");
            
            switch(category)
            {
            	case NodeCategory.RESOURCE:
            		break;            		            	

            	case NodeCategory.SUBGRAPH:
            		nodeTextArea.setStyle( "borderColor",  0x000000);
            		nodeTextArea.setStyle( "backgroundColor",  0xffff00);
            		nodeTextArea.setStyle( "color",  0x000000);
            		break;	            	

            	case NodeCategory.COMMAND:
            		nodeTextArea.setStyle( "borderColor",  0x000000);
            		nodeTextArea.setStyle( "backgroundColor",  0x004e98);
            		nodeTextArea.setStyle( "color",  0xffff00);
            		break;
            		        		
            	case NodeCategory.NORMAL:
            	default:
            		nodeTextArea.setStyle( "borderColor",  0x000000);
            		nodeTextArea.setStyle( "backgroundColor",  0xffffff);
            		nodeTextArea.setStyle( "color",  0x000000);
            		break;            
            }          
    		invalidateDisplayList();
        }	
                
        if (_textChanged)
        {
        	_needValidate = true;
            _textChanged = false;
            
            if(nodeTextArea.text != text)
           		nodeTextArea.text = text;
            
            invalidateSize();
    		invalidateDisplayList();
        }
                
        if (_categoryChanged)
        {
            _categoryChanged = false;
        	_needValidate = true;

            switch(category)
            {
            	case NodeCategory.RESOURCE:
					
					nodeTextArea.visible = false;
					nodeTextArea.includeInLayout = false;

					nodeCB.visible = true;
					nodeCB.includeInLayout = true;

        			var curTplIndex:int = 0;
        			var tpl:Template = ContextManager.templates[curTplIndex];
					var objIndex:XML = CashManager.getIndex(tpl.fullID);
					var objList:XMLList = new XMLList();
					
					if(objIndex) 
						objList = objIndex.resource.(hasOwnProperty('@category') && @category=='image' || @category=='database');
					
					nodeCB.dataProvider = objList;
					nodeCB.selectedIndex = 0;
					
					if(objList && objList.length()>0)
					{
						for each(var item:XML in objList)
						{
							if(item.@ID==text)
							{
								nodeCB.selectedItem = item;
								break;
							}
						}
						
						if(nodeCB.selectedIndex>=0)
							text = nodeCB.selectedItem.@ID;
					}
					
            		if(contextMenu)
	            		contextMenu.getItemByName("resource").checked = true;
            		break;            		            	

            	case NodeCategory.SUBGRAPH:

					nodeCB.visible = false;
					nodeCB.includeInLayout = false;

					nodeTextArea.visible = true;
					nodeTextArea.includeInLayout = true;

            		if(contextMenu)
	            		contextMenu.getItemByName("subgraph").checked = true;
            		break;	            	

            	case NodeCategory.COMMAND:

					nodeCB.visible = false;
					nodeCB.includeInLayout = false;

					nodeTextArea.visible = true;
					nodeTextArea.includeInLayout = true;

            		if(contextMenu)
	            		contextMenu.getItemByName("command").checked = true;
            		break;
            		        		
            	case NodeCategory.NORMAL:
            	default:

					nodeCB.visible = false;
					nodeCB.includeInLayout = false;

					nodeTextArea.visible = true;
					nodeTextArea.includeInLayout = true;

            		_category = NodeCategory.NORMAL;

            		if(contextMenu)
	            		contextMenu.getItemByName("normal").checked = true;
            		break;            
            }          
	
			if(!focusManager.getFocus())
				setFocus();
						
			invalidateSize();
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
        	_needRefreshStyles = true;
        	_needValidate = false;
			validator.validate();                
    		invalidateDisplayList();
        }

        if (_typeChanged)
        {
            _typeChanged = false;

            switch(type)
            {
            	case NodeType.INITIAL:
            		if(contextMenu)
	            		contextMenu.getItemByName("initial").checked = true;
	            	break;

            	case NodeType.TERMINAL:
            		if(contextMenu)
	            		contextMenu.getItemByName("terminal").checked = true;
	            	break;

            	case NodeType.NORMAL:
            	default:
            		_type = NodeType.NORMAL;
            		if(contextMenu)
            		{
	            		contextMenu.getItemByName("initial").checked = false;
	            		contextMenu.getItemByName("terminal").checked = false;
    	        	}
	            	break;
            }
			
    		invalidateDisplayList();
        }
                
         _needRefreshStyles = false;
    }    

	override protected function measure():void 
	{
		if(nodePanel)
		{
			nodePanel.width = 0;
			nodePanel.height = 0;	
		}
		
		if(nodeTextArea && nodeTextArea.visible)
		{
			var numLines:int = nodeTextArea.field.numLines;
			var textW:int = DEFAULT_WIDTH;
			
			for (var i:int=0; i<numLines; i++)
			{	
	       		var lineMetrics:TextLineMetrics = nodeTextArea.measureText(nodeTextArea.field.getLineText(i));
				textW = Math.max(lineMetrics.width + TEXT_WIDTH_PADDING + (_mode==M_EDITING?PADDING:0) + (breakpoint?_rightPadding:0), textW);
			}
			
			nodeTextArea.width = textW;
			nodeTextArea.height = lineMetrics.height*numLines + TEXT_HEIGHT_PADDING;
			
			nodeCB.width = 0;
			nodeCB.height = 0;
		}
		else if(nodeCB && nodeCB.visible)
		{
			// set combobox size

			nodeTextArea.width = 0;
			nodeTextArea.height = 0;

			nodeCB.width = NaN;
			nodeCB.height = NaN;
		}		
		
        super.measure();
		
        var margin:Number = getStyle("margin");       

        measuredWidth += margin;        
        measuredHeight += margin;            
		
        measuredMinWidth = measuredWidth;
        measuredMinHeight = measuredHeight;    
    }        
    
    override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		graphics.clear();
		
		if(dropShadow)
		{
			var rectShadow:RectangularDropShadow = new RectangularDropShadow();
			rectShadow.angle = 90;
			rectShadow.trRadius = getStyle("cornerRadius");
			rectShadow.blRadius = getStyle("cornerRadius");
			rectShadow.drawShadow(graphics, 0, 0, unscaledWidth, unscaledHeight);
		}	

		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var borderThickness:Number = getStyle("borderThickness");
		var margin:Number = getStyle("margin");

		if(_focused || selected)
		{
			setStyle( "backgroundColor", getStyle("themeColor") );
			setStyle( "backgroundAlpha", 0.8 );
		}
		else
		{
			setStyle( "backgroundColor", 0xE2E2E2 );
			setStyle( "backgroundAlpha", 0.8 );
		}
			
		if(nodeTextArea)
		{				
			nodeTextArea.move(margin, margin);
			
			if(_breakpoint)
			{
				if(!flagShape.parent)
				{
					nodeTextArea.addChild(DisplayObject(flagShape));
				}
				var offset:int = nodeTextArea.getStyle("borderThickness") + 2;
				var shapeRect:Rectangle = flagShape.getBounds(nodeTextArea);
				
				flagShape.x = nodeTextArea.width - offset - shapeRect.width; 
				flagShape.y = offset; 
			}
			else
			{
				if(flagShape.parent)
					nodeTextArea.removeChild(DisplayObject(flagShape)); 
			}
			
		}
		
		if(nodeCB)
		{
			nodeCB.move(margin, margin);
		}
		
		if(nodePanel)
		{
			var metrics:EdgeMetrics = viewMetrics;			
			nodePanel.setActualSize(unscaledWidth-metrics.left-metrics.right, unscaledHeight-metrics.top-metrics.bottom);
			
			var g:Graphics = nodePanel.graphics;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(nodePanel.width, nodePanel.height, Math.PI/2);
			
			g.clear();
			
			g.beginGradientFill(
				GradientType.LINEAR, 
				[0xffffff, 0x000000], 
				[0.3, 0.3], 
				[60, 255],
				matrix);
				
			g.lineStyle(0.0, 0x000000, 0.0);
            g.drawRoundRect(0, 0, nodePanel.width, nodePanel.height, 3);
            g.endFill();	
		}
	}

    override public function setFocus():void
    {
        if (nodeTextArea && nodeTextArea.visible)
            nodeTextArea.setFocus();
        else if(nodeCB && nodeCB.visible)
            nodeCB.setFocus();
        else
            super.setFocus();
    }
    
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------		
	
	public static function fromXML(xml:XML):Node
	{
		var newNode:Node = new Node(xml.@category, xml.@type, xml.text);
		newNode.name = Utils.getStringOrDefault(xml.@name, NameUtil.createUniqueName(newNode));
		newNode.enabled = Utils.getBooleanOrDefault(xml.@enabled, true);
		newNode.breakpoint = Utils.getBooleanOrDefault(xml.@breakpoint); 
		newNode.x = Number(xml.@x);
		newNode.y = Number(xml.@y);
		
		return newNode;		
	}
	
	public function toXML():XML
	{
		var nodeXML:XML = new XML(<state/>);
		nodeXML.@name = name;
		nodeXML.@type = type;
		nodeXML.@category = category;
		nodeXML.@enabled = enabled;	
		nodeXML.@breakpoint = breakpoint;	
		nodeXML.@x = x;
		nodeXML.@y = y;
		nodeXML.text = text;	
		
		return nodeXML;	
	}

	public function clone():Node
	{
		var newNode:Node = new Node(category, type, text);
		newNode.enabled = enabled;
		newNode.breakpoint = breakpoint;		
		newNode.x = x;
		newNode.y = y;
		newNode.arrTrans = ObjectUtils.baseClone(arrTrans);
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
    
	public function remove():void
	{			
 		if(parent)
 		{
 			if(deleteConfirmation)
	     		SuperAlert.show(
    	 			LanguageManager.sentences['node_alert_delete_text'],
     				LanguageManager.sentences['node_alert_delete_title'],
     				Alert.YES|Alert.NO,null,alertRemoveHandler,null,Alert.YES);			     	
	     	else
	     		dispose();			     	
     	}
	}
		
	public function bringToFront():void
	{
    	Utils.bringToFront(this);	 
	}
	
	public function scrollToNode():void
	{
		Utils.scrollToObject(this);
	} 	 
	    
    /**
     *  Called when the user starts dragging a node
     */
    protected function startDragging(event:MouseEvent):void
    {
        regX = this.mouseX;
        regY = this.mouseY;
        
       dropShadow = true;	        
        
        systemManager.addEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        systemManager.addEventListener(
            MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);

        systemManager.stage.addEventListener(
            Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
            
        beginHideImageTip();
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
        
        dropShadow = false;
        
        beginShowImageTip();
    }	
    
    public function edit():void
    {
    	setEditMode(true);
    }
    
    private function setEditMode(isEditing:Boolean):void
    {
    	if( !enabled )
			return;
			
		if( isEditing && _mode==M_EDITING ||
			!isEditing && _mode==M_NORMAL)
			return;
			
        if(isEditing)
        {
            _mode = M_EDITING;
            
	       	if(focusManager.getFocus()!=this)	            
	        	setFocus();
	            
            if(nodeTextArea && nodeTextArea.visible)
            {
            	Utils.bringToFront(nodeTextArea);
            	
            	nodeTextArea.editable = true;
	            nodeTextArea.selectable = true;
    	     	nodeTextArea.setSelection(0, nodeTextArea.text.length);
			
				systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, true);
				nodeTextArea.addEventListener(Event.CHANGE, textAreaChange);
				nodeTextArea.addEventListener(FocusEvent.FOCUS_OUT, textAreaFocusOut);
            }
            
            if(nodeCB && nodeCB.visible)
            {
            	Utils.bringToFront(nodeCB);
            	nodeCB.addEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
            	nodeCB.addEventListener(DropdownEvent.OPEN, dropDownOpenHandler);
            	callLater(nodeCB.open);
            }
            
			//scrollToNode();			
        }
        else
        {
            _mode = M_NORMAL;
            
            Utils.bringToFront(nodePanel);
			
			nodeCB.removeEventListener(DropdownEvent.OPEN, dropDownOpenHandler);
            nodeCB.removeEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
			nodeCB.close();
            	            
			systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, true);
			nodeTextArea.removeEventListener(Event.CHANGE, textAreaChange); 
            nodeTextArea.removeEventListener(FocusEvent.FOCUS_OUT, textAreaFocusOut);
            
            nodeTextArea.selectable = false;
            nodeTextArea.editable = false;
        	nodeTextArea.setSelection(0, 0);
        }
        
		_needRefreshStyles = true;			
		invalidateProperties();
    }
    
    public function beginTransition():void
    {
		if(canvas)
		{
			stopTransition();
						
			canvas.addingTransition = true;
			canvas.currentArrow = new Connector();
						
			canvas.addChildAt(canvas.currentArrow, 0);
			canvas.currentArrow.fromObject = this;
			canvas.currentArrow.addEventListener(ConnectorEvent.FROM_OBJECT_CHANGED, onFromObjectChange);
	
			dispatchEvent(new NodeEvent(NodeEvent.ADDING_TRANSITION));    	
		}
    }
    
    public function stopTransition():void
    {
		if(canvas)
		{
			canvas.addingTransition = false;

			if(canvas.currentArrow)
			{
				canvas.currentArrow.removeEventListener(ConnectorEvent.FROM_OBJECT_CHANGED, onFromObjectChange);
	
				canvas.currentArrow.dispose();
				canvas.currentArrow = null;
			}
		}
    }    
    
    private function beginShowImageTip(delay:Number=400, img:Object=null):void
    {
		if(category != NodeCategory.RESOURCE)
			return;
		
		if(!nodeCB.visible || !nodeCB.selectedItem || !nodeCB.selectedItem.hasOwnProperty('@thumb'))
			return;
		
		if(!hideTimer && tipImage && tipImage.parent)
			return;
		
    	destroyTimers(false, true);
    	
    	if(showTimer)
    		return;
    	    	
    	showTimer = new Timer(delay);
    	showTimer.addEventListener(TimerEvent.TIMER, showTimerHandler);
        showTimer.start();
    }
    
    private function beginHideImageTip(delay:Number=100):void
    {
    	if(hideTimer)
    		return;
    		    	
    	hideTimer = new Timer(delay);
    	hideTimer.addEventListener(TimerEvent.TIMER, hideTimerHandler);
        hideTimer.start();
    }
    
    private function destroyTimers(destroyShowTimer:Boolean=true, destroyHideTimer:Boolean=true):void
    {
    	if(showTimer && destroyShowTimer)
    	{
    		showTimer.stop();
    		showTimer.removeEventListener(TimerEvent.TIMER, showTimerHandler);
    		showTimer = null;
    	}
    	if(hideTimer && destroyHideTimer)
    	{
    		hideTimer.stop();
    		hideTimer.removeEventListener(TimerEvent.TIMER, hideTimerHandler);
    		hideTimer = null;
    	}
    }
    
    private function createImageTip():void
    {
    	destroyImageTip();
    	
		tipImage = new Image();
		tipImage.visible = false;
		tipImage.scaleContent = true;
		
		var curTpl:Template = ContextManager.templates[0];
		var index:XML = CashManager.getIndex(curTpl.fullID);
		var thumbFile:File = CashManager.cashFolder.resolvePath(index.@folder).resolvePath(nodeCB.selectedItem.@thumb);
		
		tipImage.load( thumbFile.nativePath );	
		tipImage.addEventListener(Event.COMPLETE, tipImageComplete);    	
    }
        
    private function destroyImageTip():void
    {
    	destroyTimers();
    	
    	if(!tipImage)
    		return;
    		
		if(tipImage.parent)
			PopUpManager.removePopUp(tipImage);
		
		systemManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE, tipImageMoveHandler);
		tipImage.removeEventListener(Event.COMPLETE, tipImageComplete);		
		tipImage.removeEventListener(FlexEvent.CREATION_COMPLETE, tipImageCreationComplete);	

		tipImage.source = null;
		tipImage = null;
    }
    		    	    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

	private function showTimerHandler(event:TimerEvent):void
	{
		destroyTimers(true, false);
		
		var curTpl:Template;		
		if(ContextManager.templates.length>0)
			curTpl =  ContextManager.templates[0];
		
		if(!curTpl || CashManager.objectUpdated(curTpl.fullID, nodeCB.selectedItem.@ID, Number(nodeCB.selectedItem.@lastUpdate)) )
		{
			destroyImageTip();
		}
		
		if(!curTpl)
			return;
		
		if(!tipImage)
		{
			createImageTip();
			return;	
		}
		
		tipImageComplete(null);
	}
	
	private function tipImageComplete(event:Event):void
	{
		tipImage.removeEventListener(Event.COMPLETE, tipImageComplete);			

		tipImage.addEventListener(FlexEvent.CREATION_COMPLETE, tipImageCreationComplete);	
        systemManager.stage.addEventListener(MouseEvent.MOUSE_MOVE, tipImageMoveHandler);
		
		var point:Point = localToGlobal(new Point(mouseX, mouseY));
		
		tipImage.x = point.x+15;
		tipImage.y = point.y+20;

		tipImage.visible = true;

		if(!tipImage.parent)
			PopUpManager.addPopUp(tipImage, this);
			
		var fade:Fade = new Fade(tipImage);
		fade.play();
	}
	
	private function tipImageCreationComplete(event:FlexEvent):void
	{
		tipImage.removeEventListener(FlexEvent.CREATION_COMPLETE, tipImageCreationComplete);
		
		tipImage.graphics.clear();
		
		var tipImageShadow:RectangularDropShadow = new RectangularDropShadow();
		tipImageShadow.angle = 90;
   		tipImageShadow.drawShadow(tipImage.graphics, -1, -1 , tipImage.width+2, tipImage.height+2);
   		
		tipImage.graphics.beginFill(0xffffff, 1.0);
		tipImage.graphics.lineStyle(1, 0xffffff, 0.8);
		tipImage.graphics.drawRect(-1, -1, tipImage.width+2, tipImage.height+2);
	}
	
	private function hideTimerHandler(event:TimerEvent):void
	{
		destroyTimers();
		
		if(tipImage)
		{
			tipImage.endEffectsStarted()
			
			if(tipImage.parent)
				PopUpManager.removePopUp(tipImage);
			
			if(!tipImage.visible)
			{
				destroyImageTip();
			}
		}		
	}
		
	private function tipImageMoveHandler(event:Event):void
	{
		var point:Point = localToGlobal(new Point(mouseX, mouseY));
		
		if(getBounds(systemManager.stage).containsPoint(point))
		{
			tipImage.endEffectsStarted();

			var move:Move = new Move(tipImage);
			move.xTo = point.x+15;
			move.yTo = point.y+15;
		
			move.play();
		}
		else
		{
			beginHideImageTip();
		}
	}

	private function moveHandler(event:MoveEvent):void
	{
        if(tipImage && tipImage.parent)		
        	tipImageMoveHandler(null);
        			
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
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
        	    
    private function addHandler(event:FlexEvent):void
    {
    	var node:Node = event.target as Node;
    	 
    	if(node.type==NodeType.INITIAL && node.parent)
    	{
    		for each (var child:UIComponent in Container(node.parent).getChildren())
    		{
    			if(	child is Node && 
    				child!=node && 
    				Node(child).type==NodeType.INITIAL)
    			{
    				Node(child).type = NodeType.NORMAL;
    			}
    		}
    	}
    }
    
    private function typeChangedHandler(event:Event):void
    {	    	
    	var node:Node = event.target as Node;
    	 
    	if(node.type==NodeType.INITIAL && node.parent)
    	{
    		for each (var child:UIComponent in Container(node.parent).getChildren())
    		{
    			if(	child is Node && 
    				child!=node && 
    				Node(child).type==NodeType.INITIAL)
    			{
    				Node(child).type = NodeType.NORMAL;
    			}
    		}
    	}
    }
    
	private function contextMenuSelectHandler(event:Event):void
	{
		switch(event.target.name)
		{
			case "add_trans":
				beginTransition();
				break;
			
			case "jump":
				dispatchEvent(new Event("jumpToGraph"));
				break;

			case "delete":
	     		remove();
	     		break;
	     		
	     	case "cut": 
				if(parent)
					parent.dispatchEvent(new Event("cut"));
				break;
				
			case "copy": 
				if(parent)
					parent.dispatchEvent(new Event("copy"));
				break;
		
			case "initial":
				if(_type==NodeType.INITIAL)
					type = NodeType.NORMAL;
				else
					type = NodeType.INITIAL;
				break;
			
			case "terminal":
				if(_type==NodeType.TERMINAL)
					type = NodeType.NORMAL;
				else
					type = NodeType.TERMINAL;
				break;
				
			case "normal":
				category = NodeCategory.NORMAL;
				break;
			
			case "subgraph":
				category = NodeCategory.SUBGRAPH;
				break;
				
			case "command":
				category = NodeCategory.COMMAND;
				break;
			
			case "resource":
				category = NodeCategory.RESOURCE;
				break;
				
			case "enabled":
				enabled = !enabled;
				break;
	
			case "breakpoint":
				breakpoint = !breakpoint;
				break;
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
				filters = [];
				var filter:GlowFilter = new GlowFilter(0x0000ff, 0.5, 4, 4, 3);
   				filters = [filter];
        				
				if(canvas.currentArrow.fromObject!=this)
					canvas.currentArrow.toObject = this;
			}
			else
			{
				arrToolTip = [];
				for each(var arrow:Connector in outArrows)
				{
					var visibleRect:Rectangle = arrow._getVisibleRect();
					var point:Point;

					if(visibleRect)
						point = new Point(visibleRect.x + visibleRect.width/2, visibleRect.y + visibleRect.height/2);
					
					if(arrow.label && point)
						arrToolTip.push(ToolTipManager.createToolTip(arrow.label, point.x, point.y));
					arrow.highlighted = true;
				}			
			}
		}
		
		beginShowImageTip();
	}
	
	private function mouseOutHandler(event:MouseEvent):void
	{	
		_over = false;
		
		if(canvas)
		{
   			filters = [];

			if(canvas.addingTransition)
				canvas.currentArrow.toObject = null;
		}

		for each(var arrow:Connector in outArrows)
			arrow.highlighted = false;

		for each(var toolTip:ToolTip in arrToolTip)
			ToolTipManager.destroyToolTip(toolTip);
		
		arrToolTip = [];
		
		beginHideImageTip();
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
					stopTransition();
					return;
				}
				
				for each (var arrow:Connector in inArrows)
				{
					if(arrow.fromObject == canvas.currentArrow.fromObject)
					{
						stopTransition();
						return;
					}
				}
				
				for each (arrow in outArrows)
				{
					if(arrow.toObject == canvas.currentArrow.fromObject)
					{
						stopTransition();
						return;
					}
				}
				
				canvas.currentArrow.removeEventListener(ConnectorEvent.FROM_OBJECT_CHANGED, onFromObjectChange);
				canvas.currentArrow.toObject = this;
				
				canvas.currentArrow.interactive = true;
				
				if(!event.altKey)
				{
					callLater(canvas.currentArrow.beginEdit);
				}
				
				canvas.currentArrow = null;
				
				if(event.altKey)
				{	
					bringToFront();
					beginTransition();
					return;
				}
				
				return;
			}
			else
			{
				if(event.altKey)
				{	
					bringToFront();
					beginTransition();
					return;				
				}			
			}
		}
				
		bringToFront();
			        
        if (_mode==M_NORMAL && isNaN(regX))
            startDragging(event);
    }
    
    private function onFromObjectChange(event:Event):void
    {
    	if(!event.target.fromObject)    	
		{
			stopTransition();
		}
    }
    
	private function onKeyDown(event:KeyboardEvent):void
    {
		if(canvas && canvas.addingTransition)
			return;			

		if(event.keyCode == Keyboard.DELETE)
     	{
     		if(_mode==M_NORMAL)
     		{
				event.stopPropagation();
     			remove();
     		}
	    }
	    else if(	event.keyCode == Keyboard.ENTER ||
	    			event.keyCode == Keyboard.F2)
	    {
			event.stopPropagation();

    	    if(_mode==M_NORMAL)
		    	setEditMode(true);
	    }
	    else if(event.keyCode == Keyboard.A && (event.commandKey || event.controlKey))
	    {
	    	if(_mode==M_NORMAL)
	    	{
	    		event.preventDefault();
	    		event.stopPropagation();
	    		if(parent)
	    			parent.dispatchEvent(new Event("selectAll"))
	    	}
	    }	    
	}
	
	private function dropDownOpenHandler(event:DropdownEvent):void
	{
		var cb:ComboBox = event.target as ComboBox;
		cb.addEventListener(ListEvent.ITEM_ROLL_OVER, dropDownRollOverHandler); 
		cb.addEventListener(ListEvent.ITEM_ROLL_OUT, dropDownRollOutHandler);
	}

	private function dropDownCloseHandler(event:DropdownEvent):void
	{
		var cb:ComboBox = event.target as ComboBox;

		cb.removeEventListener(ListEvent.ITEM_ROLL_OVER, dropDownRollOverHandler);
		cb.removeEventListener(ListEvent.ITEM_ROLL_OUT, dropDownRollOutHandler);

		setEditMode(false);
		
		if(cb.selectedItem)
			text = cb.selectedItem.@ID;
	}
	
	private function dropDownRollOverHandler(event:ListEvent):void
	{
		destroyImageTip();
		beginShowImageTip(100);
	}
	
	private function dropDownRollOutHandler(event:ListEvent):void
	{
		//beginHideImageTip();
	}

	private function textAreaKeyDown(event:KeyboardEvent):void
    {
		if(canvas && canvas.addingTransition)
			return;		

	   	if(_mode == M_EDITING)
	   	{
	    	event.stopPropagation();
			
			// if you use stopPropagation then CTRL+C/V/A/X wouldnt work
			if(GeneralUtils.isCopyCombination(event) ||
				GeneralUtils.isCutCombination(event) ||
				GeneralUtils.isPasteCombination(event) ||
				GeneralUtils.isSelectAllCombination(event))
			{	
				event.preventDefault();
				
				if(GeneralUtils.isCopyCombination(event))
					Application.application.nativeApplication.copy()
				else if(GeneralUtils.isCutCombination(event))
					Application.application.nativeApplication.cut();
				else if(GeneralUtils.isPasteCombination(event))
					Application.application.nativeApplication.paste();
				else if(GeneralUtils.isSelectAllCombination(event))
					Application.application.nativeApplication.selectAll();				
			}
	   	}
	   	
	    if(event.keyCode == Keyboard.ENTER)
	    {
	    	if(_mode==M_EDITING)
	    	{
		    	event.stopPropagation();	    	
    			event.preventDefault();

		    	if(event.controlKey || event.commandKey)
		    	{
					var caretPos:int = nodeTextArea.field.caretIndex; 
	    	
	    			var txt:String = nodeTextArea.text.substr(0, caretPos) +  
	    				'\n' + nodeTextArea.text.substr(caretPos);	    		
	    			nodeTextArea.text = txt;
	    			nodeTextArea.setSelection(caretPos+1, caretPos+1);
		    	}
		    	else
		    	{
			    	setEditMode(false);
	    			text = nodeTextArea.text;
		    	}
		    }
	    }
	    else if(event.keyCode == Keyboard.ESCAPE)
	    {
	    	event.stopPropagation();	    	
	    	event.preventDefault();
	    	
	    	setEditMode(false);
	    	nodeTextArea.text = _text;
	    	
	    	invalidateProperties();
	    	invalidateSize();
	    	invalidateDisplayList();
	    }	    
	    	        	
		if(_mode == M_EDITING)
		{
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}		    	
    }
    
    private function comboBoxKeyDown(event:KeyboardEvent):void
    {
    	beginHideImageTip();
    	
		if(canvas && canvas.addingTransition)
			return;
		
 		event.stopPropagation();
 		
 		if(_mode == M_NORMAL) {
	 		event.stopImmediatePropagation();
	 		event.preventDefault();
	 		dispatchEvent(event);
 		}
    }
    
    private function comboBoxChange(event:ListEvent):void
    {
    	if(ComboBox(event.target).selectedItem)
			text = ComboBox(event.target).selectedItem.@ID;
			
    	var showTipImage:Boolean = tipImage && tipImage.parent;
    	
    	destroyImageTip();
    	
    	if(showTipImage && !hideTimer)
    		beginShowImageTip();
    }
    
    private function alertRemoveHandler(event:CloseEvent):void 
    {
    	if(parent && event.detail==Alert.YES)
    	{
			dispose();
        }
        
        setFocus();
	}
    
    private function doubleClickHandler(event:MouseEvent):void
    {
    	event.stopPropagation();
    	
    	beginHideImageTip();
    	
		if(canvas && canvas.addingTransition)
			return;			

		bringToFront();						
		setEditMode(true);	  
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
    	_focused = false;

        super.focusOutHandler(event);

        invalidateDisplayList();
    }

    override protected function focusInHandler(event:FocusEvent):void
    {
    	_focused = true;
    	
        super.focusInHandler(event);

        invalidateDisplayList();
    } 
    
    private function mouseDownOutsideHandler(event:MouseEvent):void
    {	    	
    	if (!nodeTextArea.hitTestPoint(event.stageX, event.stageY, true))
    	{
	    	if(_mode==M_EDITING)
	    	{
			   	text = nodeTextArea.text;
	    		setEditMode(false);
	    		_needValidate = true;
	    	}
	    }
    }	
    
	private function textAreaFocusOut(Event:FocusEvent):void
	{
		if(parent)
		{
	    	if(_mode==M_EDITING)
	    	{
			   	text = nodeTextArea.text;
	    		setEditMode(false);
	    		_needValidate = true;
	    	}			
  		}	
	}

	private function textAreaChange(event:Event):void
	{
		if(initialized)
		{
			_needRefreshStyles = true;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();		
		}
    }
    
    private function validatorHandler(event:ValidationResultEvent):void
    {
    	if(event.type==ValidationResultEvent.VALID)
    	{    
    		nodeCB.clearStyle("borderColor");
        	_isValidText = true;
     	}
		else
		{
        	nodeTextArea.setStyle("borderColor", getStyle("errorColor"));
        	nodeCB.setStyle("borderColor", getStyle("errorColor"));
			_isValidText = false;
		}
    }
    
    private function contextHandler(event:MouseEvent):void
    {
    	if(category == NodeCategory.SUBGRAPH)
    		contextMenu.getItemByName("jump").enabled = true;
    	else
    		contextMenu.getItemByName("jump").enabled = false;
    	
		for each (var item:NativeMenuItem in contextMenu.items) {
			item.label = LanguageManager.sentences['node_'+item.name];
  		}    	
    }
    
}
}
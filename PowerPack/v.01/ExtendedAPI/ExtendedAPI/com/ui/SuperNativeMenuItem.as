package ExtendedAPI.com.ui
{
import ExtendedAPI.com.utils.Utils;

import flash.display.NativeMenuItem;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.ui.Keyboard;

import mx.core.Application;
import mx.core.EventPriority;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.ISystemManager;
import mx.utils.ArrayUtil;

//--------------------------------------
//  Events
//--------------------------------------

//--------------------------------------
//  Styles
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

public class SuperNativeMenuItem extends NativeMenuItem
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------		

    //--------------------------------------------------------------------------
    //
    //  Class constructor
    //
    //--------------------------------------------------------------------------	

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function SuperNativeMenuItem(
				type:String='normal', 
				label:String="",
				name:String=null,
				toggled:Boolean=false,
				groupName:String=null,		
				isRequired:Boolean=false, 
				enabled:Boolean=true)
	{
		super(label, type=='separator'?true:false);
		
		if(name)
			this.name = name;
			
		this.enabled = enabled;
		
		this.type = type?type:'normal';
		this.groupName = groupName;
		this.checked = toggled;
		this.isRequired = isRequired;
		
   		keyEquivalentModifiers = [];
   		
   		//Application.application.addEventListener(FlexEvent.APPLICATION_COMPLETE, onAppComplete);
	}
	
    //--------------------------------------------------------------------------
    //
    //  Destructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Destructor.
     */

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
    
    //----------------------------------
    //  label
    //----------------------------------

	/**
     *  @private
     */
    private var _labelChanged:Boolean = false;

    /**
     *  @private
     */

    [Bindable("propertyChange")]

    /**
     *  @default ""
     */
    override public function get label():String
    {
        return super.label;
    }

    /**
     *  @private
     */
    override public function set label(value:String):void
    {
       	var oldValue:String = super.label;
       	
        if (oldValue != value)
        {
        	super.label = value;
            _labelChanged = true;
            
            processProperties();
            
            dispatchItemChangedEvent("label", oldValue, value);
        }
    }
    
    //----------------------------------
    //  data
    //----------------------------------

	/**
     *  @private
     */
    private var _dataChanged:Boolean = false;

    /**
     *  @private
     */

    [Bindable("propertyChange")]

    /**
     *  @default null
     */
    override public function get data():Object
    {
        return super.data;
    }

    /**
     *  @private
     */
    override public function set data(value:Object):void
    {
       	var oldValue:Object = super.data;
       	
        if (oldValue != value)
        {
        	super.data = value;
            _dataChanged = true;
            
            processProperties();
            
            dispatchItemChangedEvent("data", oldValue, value);
        }
    }
    	
    //----------------------------------
    //  enabled
    //----------------------------------

	/**
     *  @private
     */
    private var _enabledChanged:Boolean = false;

    /**
     *  @private
     */

    [Bindable("propertyChange")]

    /**
     *  @default true
     */
    override public function get enabled():Boolean
    {
        return super.enabled;
    }

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
       	var oldValue:Boolean = super.enabled;
       	
        if (oldValue != value)
        {
        	super.enabled = value;
            _enabledChanged = true;
            
            processProperties();
            
            dispatchItemChangedEvent("enabled", oldValue, value);
        }
    }

    //----------------------------------
    //  keyEquivalent
    //----------------------------------

	/**
     *  @private
     */
    private var _keyEquivalentChanged:Boolean = false;
    private var _keyEquivalent:String;

    /**
     *  @private
     */

    [Bindable("propertyChange")]

    /**
     *  @default ""
     */
    override public function get keyEquivalent():String
    {
        return _keyEquivalent;
    }

    /**
     *  @private
     */
    override public function set keyEquivalent(value:String):void
    {
       	var oldValue:String = _keyEquivalent;
       	
        if (oldValue != value)
        {
        	super.keyEquivalent = value;
        	_keyEquivalent = value;
            _keyEquivalentChanged = true;
            
            processProperties();
            
            dispatchItemChangedEvent("keyEquivalent", oldValue, value);
        }
    }
        
    //----------------------------------
    //  keyEquivalentModifiers
    //----------------------------------

	/**
     *  @private
     */
    private var _keyEquivalentModifiersChanged:Boolean = false;
    private var _keyEquivalentModifiers:Array;

    /**
     *  @private
     */

    [Bindable("propertyChange")]

    /**
     *  @default []
     */
    override public function get keyEquivalentModifiers():Array
    {
        return _keyEquivalentModifiers;
    }

    /**
     *  @private
     */
    override public function set keyEquivalentModifiers(value:Array):void
    {
       	var oldValue:Array = _keyEquivalentModifiers;
       	
        if (oldValue != value)
        {
        	_keyEquivalentModifiers = value;
            _keyEquivalentModifiersChanged = true;
            
            processProperties();
            
            dispatchItemChangedEvent("keyEquivalentModifiers", oldValue, value);
        }
    }
        
    //----------------------------------
    //  type
    //----------------------------------

	/**
     *  @private
     */
    private var _typeChanged:Boolean = false;

    /**
     *  @private
     */
    private var _type:String = 'normal';

    [Bindable("propertyChange")]
    [Inspectable(category="Data", defaultValue='normal')]

    /**
     *  @default 'normal'
     */
    public function get type():String
    {
        return _type;
    }

    /**
     *  @private
     */
    public function set type(value:String):void
    {
    	value = value.toLowerCase();
    	
    	if(value!='separator' && value!='radio' && value!='check')
    		value = 'normal'; 
    	
    	if(isSeparator && value!='separator' || !isSeparator && value=='separator')
    		return;	
    	
    	var oldValue:String = _type;
    	
        if (oldValue != value)
        {
        	_type = value;
            _typeChanged = true;
            
            processProperties();
            dispatchItemChangedEvent("type", oldValue, value);
        }
    }
        
    //----------------------------------
    //  checked
    //----------------------------------

	/**
     *  @private
     */
    private var _checkedChanged:Boolean = false;

    /**
     *  @private
     */
    private var _checked:Boolean = false;

    [Bindable("propertyChange")]
    [Inspectable(category="Data", defaultValue=false)]

    /**
     *  @default false
     */
    override public function get checked():Boolean
    {
        return _checked;
    }

    /**
     *  @private
     */
    override public function set checked(value:Boolean):void
    {
    	var oldValue:Boolean = _checked;
    	
        if (oldValue != value)
        {
            _checked = value;
            _checkedChanged = true;
            
            processProperties();
            dispatchItemChangedEvent("checked", oldValue, value);
        }
    }
    
    //----------------------------------
    //  group
    //----------------------------------

	/**
     *  @private
     */
    private var _groupNameChanged:Boolean = false;

    /**
     *  @private
     */
    private var _groupName:String = null;

    [Bindable("propertyChange")]
    [Inspectable(category="Data", defaultValue=null)]

    /**
     *  Group determines the radio group for menu item.
     *
     *  @default null
     */
    public function get groupName():String
    {
        return _groupName;
    }

    /**
     *  @private
     */
    public function set groupName(value:String):void
    {
    	var oldValue:String = _groupName;
    	
        if (oldValue != value)
        {
            _groupName = value;
            _groupNameChanged = true;
            
            processProperties();
            dispatchItemChangedEvent("groupName", oldValue, value);
        }
    }
    
    //----------------------------------
    //  isRequired
    //----------------------------------

	/**
     *  @private
     */
    private var _isRequiredChanged:Boolean = false;

    /**
     *  @private
     */
    private var _isRequired:Boolean = false;

    [Bindable("propertyChange")]
    [Inspectable(category="Data", defaultValue=false)]

    /**
     *  Determines that require one checked item in radio group.
     *
     *  @default false
     */
    public function get isRequired():Boolean
    {
        return _isRequired;
    }

    /**
     *  @private
     */
    public function set isRequired(value:Boolean):void
    {
    	var oldValue:Boolean = _isRequired;
    	
        if (oldValue != value)
        {
            _isRequired = value;
            _isRequiredChanged = true;
			
            processProperties();
            dispatchItemChangedEvent("isRequired", oldValue, value);
        }
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    protected function processProperties():void
    {
    	if(_typeChanged)
    	{
            _typeChanged = false;
            
            if(_type=='normal')
            	_checked = false; 
    	}
    	if(_checkedChanged)
    	{
    		_checkedChanged = false;

            if(_type=='normal')
            	_checked = false; 
    	}
    	if(_groupNameChanged)
    	{
    		_groupNameChanged = false;
		}		
    	if(_isRequiredChanged)
    	{
    		_isRequiredChanged = false;
    	}
    	
    	if(_keyEquivalentModifiersChanged)
    	{
    		_keyEquivalentModifiersChanged = false;

			var isWin:Boolean = (Capabilities.os.indexOf("Windows") >= 0);
			var isMac:Boolean = (Capabilities.os.indexOf("Mac OS") >= 0);
			var arr:Array = [];
                
    		for each(var key:uint in keyEquivalentModifiers)
    		{
    			var newKey:uint = key;
    			    			
    			if(!isMac && newKey==Keyboard.COMMAND)
   					newKey = Keyboard.CONTROL;  					
   				
    			else if(isMac && newKey==Keyboard.CONTROL)
    				newKey = Keyboard.COMMAND;    			

   				if(ArrayUtil.getItemIndex(newKey, arr)==-1)
    				arr.push(newKey);
    		}
    		_keyEquivalentModifiers = arr;   		
    		
    		super.keyEquivalentModifiers = arr;
    	}

    	if(_keyEquivalentChanged)
    	{
    		_keyEquivalentChanged = false;
    		
    		//addKeyDownListener();
    	}
    	
    	if(_dataChanged || _enabledChanged || _labelChanged)
    	{
    		_dataChanged = false;
    		_enabledChanged = false;
    		_labelChanged = false;
    	}
    	
    	if(super.checked!=_checked)
   			super.checked = _checked;
    }
    
    
	override public function clone():NativeMenuItem
	{
		var clone:SuperNativeMenuItem = SuperNativeMenuItem(super.clone());		
		clone.type = this.type;
		clone.groupName = this.groupName;
		clone.checked = this.checked;
		clone.isRequired = this.isRequired;
		clone.keyEquivalent = this.keyEquivalent;
		return clone;
	}
	
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function onAppComplete(event:Event):void
    {
    	addKeyDownListener();
    }
    
    private function addKeyDownListener():void
    {
		var stg:Stage = Application.application.stage;
		
		if(stg)
		{	
			stg.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown, true);

			if(super.keyEquivalent) {  		
				stg.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, true, EventPriority.CURSOR_MANAGEMENT);
			}
		}
    }
    
	private function keyDown(event:KeyboardEvent):void
	{
		var isWin:Boolean = (Capabilities.os.indexOf("Windows") >= 0);
		var isMac:Boolean = (Capabilities.os.indexOf("Mac OS") >= 0);		
			
		if(
			event.altKey == ArrayUtil.getItemIndex(Keyboard.ALTERNATE, keyEquivalentModifiers)>=0 &&
			(isMac && event.commandKey == ArrayUtil.getItemIndex(Keyboard.COMMAND, keyEquivalentModifiers)>=0 ||
			!isMac && event.controlKey == ArrayUtil.getItemIndex(Keyboard.CONTROL, keyEquivalentModifiers)>=0) &&
			event.shiftKey == ArrayUtil.getItemIndex(Keyboard.SHIFT, keyEquivalentModifiers)>=0 &&			
			(keyEquivalent && /^[^\w]$/i.test(keyEquivalent) ? keyEquivalent.charCodeAt(0) == event.charCode :
				Utils.keyCodeFromName(keyEquivalent)==event.keyCode) )
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
			event.preventDefault();
		
			dispatchEvent(new Event(Event.SELECT));
		}
	}
	
	/**
	 *  @private
	 */
	private function dispatchItemChangedEvent(prop:String, oldValue:*,
												value:*):void
	{
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
															oldValue, value));
	}       
}
}
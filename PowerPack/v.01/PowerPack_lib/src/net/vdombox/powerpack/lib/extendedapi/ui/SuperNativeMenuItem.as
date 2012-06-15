package net.vdombox.powerpack.lib.extendedapi.ui
{
import flash.display.NativeMenuItem;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.core.Application;
import mx.core.EventPriority;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.ISystemManager;
import mx.utils.ArrayUtil;

import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

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
	
	private static var MNEMONIC_INDEX_CHARACTER:String = "_";
	
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
		super(label, type == 'separator');
		
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
    //  mnemonicLabel
    //----------------------------------

    /**
     *  @private
     */
    public function set mnemonicLabel(value:String):void
    {
    	if(!value)
    		return;
    		
       	mnemonicIndex = parseLabelToMnemonicIndex(value); 

        label = parseLabelToString(value);
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

			var isWin:Boolean = FileUtils.OS == FileUtils.OS_WINDOWS;
			var isMac:Boolean = FileUtils.OS == FileUtils.OS_MAC;
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
	
    private function parseLabelToString(data:String):String
    {
    	const singleCharacter:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER, "g");
    	const doubleCharacter:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER + MNEMONIC_INDEX_CHARACTER, "g");
    	var dataWithoutEscapedUnderscores:Array = data.split(doubleCharacter);
    	
    	// now need to find lone underscores and remove it
    	var len:int = dataWithoutEscapedUnderscores.length;
    	for(var i:int = 0; i < len; i++)
    	{
    		var str:String = String(dataWithoutEscapedUnderscores[i]);
    		dataWithoutEscapedUnderscores[i] = str.replace(singleCharacter, "");
    	}
    	
    	return dataWithoutEscapedUnderscores.join(MNEMONIC_INDEX_CHARACTER);
    }	
    
    private function parseLabelToMnemonicIndex(data:String):int
    {
    	const doubleCharacter:RegExp = new RegExp(MNEMONIC_INDEX_CHARACTER + MNEMONIC_INDEX_CHARACTER, "g");
        var dataWithoutEscapedUnderscores:Array = data.split(doubleCharacter);
    	
    	// now need to find first underscore
    	var len:int = dataWithoutEscapedUnderscores.length;
    	var strLengthUpTo:int = 0; // length of string accumulator
    	for(var i:int = 0; i < len; i++)
    	{
    		var str:String = String(dataWithoutEscapedUnderscores[i]);
    		var index:int = str.indexOf(MNEMONIC_INDEX_CHARACTER);
    		
    		if (index >= 0)
    			return index + strLengthUpTo;
    		
    		strLengthUpTo += str.length + MNEMONIC_INDEX_CHARACTER.length;
    	}
    	
    	return -1;
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
		trace ("[SuperNativeMenuItem] keyDown");
		
		var isWin:Boolean = FileUtils.OS == FileUtils.OS_WINDOWS;
		var isMac:Boolean = FileUtils.OS == FileUtils.OS_MAC;		
			
		
		var altKeyEquivalentModifierExists		: Boolean = ArrayUtil.getItemIndex(Keyboard.ALTERNATE, keyEquivalentModifiers) >= 0;
		var shiftKeyEquivalentModifierExists	: Boolean = ArrayUtil.getItemIndex(Keyboard.SHIFT, keyEquivalentModifiers) >= 0;
		var commandKeyEquivalentModifierExists	: Boolean = ArrayUtil.getItemIndex(Keyboard.COMMAND, keyEquivalentModifiers) >= 0;
		var ctrlKeyEquivalentModifierExists		: Boolean = ArrayUtil.getItemIndex(Keyboard.CONTROL, keyEquivalentModifiers) >= 0;
		
		if(
			event.altKey == altKeyEquivalentModifierExists &&
			(isMac && event.commandKey ==  commandKeyEquivalentModifierExists || !isMac && event.ctrlKey == ctrlKeyEquivalentModifierExists) &&
			event.shiftKey == shiftKeyEquivalentModifierExists &&			
			(keyEquivalent && /^[^\w]$/i.test(keyEquivalent) ? keyEquivalent.charCodeAt(0) == event.charCode :
				Utils.keyCodeFromName(keyEquivalent)==event.keyCode) )
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
			event.preventDefault();
		
			trace ("[SuperNativeMenuItem] keyDown: SELECT");
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
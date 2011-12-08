package ExtendedAPI.com.ui
{
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;

import mx.controls.menuClasses.IMenuDataDescriptor;
import mx.controls.treeClasses.DefaultDataDescriptor;
import mx.events.PropertyChangeEvent;

//--------------------------------------
//  Events
//--------------------------------------

//--------------------------------------
//  Styles
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

public class SuperNativeMenu extends NativeMenu
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
	public function SuperNativeMenu()
	{
		super();
		
		this.addEventListener(Event.SELECT, menuSelectHandler);
	}
	
    //--------------------------------------------------------------------------
    //
    //  Destructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Destructor.
     */
	public function dispose():void
	{
		for each (var item:NativeMenuItem in items)
		{
			if(item)
			{			
				item.removeEventListener("propertyChange", itemPropertyChangeHandler);
				removeItem(item);
			}
		}
		
		this.removeEventListener(Event.SELECT, menuSelectHandler);
	}
	
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
    //  isProcessing
    //----------------------------------

	private var _isProcessing:Boolean = false;

    public function get isProcessing():Boolean
    {
        return topLevelSuperMenu._isProcessing;
    }
	
	//----------------------------------
    //  topLevelMenu
    //----------------------------------

    public function get topLevelMenu():NativeMenu
    {
        var topMenu:NativeMenu = this;
        
        while(topMenu.parent)
        	topMenu = topMenu.parent;
        	
        return topMenu;
    }
	
	//----------------------------------
    //  topLevelSuperMenu
    //----------------------------------

    public function get topLevelSuperMenu():SuperNativeMenu
    {
        var topMenu:SuperNativeMenu = this;
        
        while(topMenu.parent && topMenu.parent is SuperNativeMenu)
        	topMenu = SuperNativeMenu(topMenu.parent);
        	
        return topMenu;
    }    
	
	//----------------------------------
    //  dataDescriptor
    //----------------------------------

    /**
     *  @private
     */
    private var _dataDescriptor:IMenuDataDescriptor =
        new DefaultDataDescriptor();

    /**
     *
     */
    public function get dataDescriptor():IMenuDataDescriptor
    {
        return IMenuDataDescriptor(_dataDescriptor);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	override public function addItem(item:NativeMenuItem):NativeMenuItem
	{
		return addItemAt(item, numItems);
	} 

	override public function addItemAt(item:NativeMenuItem, index:int):NativeMenuItem 
	{
		item = super.addItemAt(item, index);
		
		topLevelSuperMenu.processMenu(item);
			
		item.addEventListener("propertyChange", itemPropertyChangeHandler);
		
		return item;
	}
	
	protected function processMenu(item:NativeMenuItem):void
	{
		if(_isProcessing)
			return;
			
		_isProcessing = true;
		
		var type:String;
		var groupName:String;
		var isRequired:Boolean;

		if(item is SuperNativeMenuItem) {
			type = SuperNativeMenuItem(item).type;
			groupName = SuperNativeMenuItem(item).groupName;
			isRequired = SuperNativeMenuItem(item).isRequired;
		}
		else if(item is NativeMenuItem) {
			type = dataDescriptor.getType(item.data).toLowerCase();
			groupName = dataDescriptor.getGroupName(item.data);
			
			if (item.data is XML)
				isRequired = item.data.@isRequired.toString().toLowerCase() == 'true';
        	else if (item.data is Object)
        	{
            	try {
                	isRequired = item.data.isRequired;
            	} catch(e:Error) {}
         	}
		}

  		if(type=='radio' && item.menu)
  		{
			for each(var elm:NativeMenuItem in item.menu.items)
  			{
  				var needCheck:Boolean = isRequired;
  				var elmGroupName:String = null;
	
				if(elm is SuperNativeMenuItem)
					elmGroupName = SuperNativeMenuItem(elm).groupName;
				else if(elm is NativeMenuItem)
					elmGroupName = dataDescriptor.getGroupName(elm.data);
									
	  			if(item.checked)
  				{
  					if(elmGroupName==groupName && elm!=item) {
  						if(elm.checked)
  							elm.checked = false;
  						if(dataDescriptor.isToggled(elm.data))
  							dataDescriptor.setToggled(elm.data, false);
  					}
  				}
	  			else if(!item.checked && isRequired)
  				{
  					if(elmGroupName==groupName && elm.checked) {
  						needCheck = false;
  						break;
  					}
  				}
  			}
  		}	

		if(!item.checked && needCheck)
			item.checked = true;
		
		if(dataDescriptor.isToggled(item.data) != item.checked)
			dataDescriptor.setToggled(item.data, item.checked);
		
		_isProcessing = false;
	} 

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
	
	private function menuSelectHandler(event:Event):void
	{
		if(parent)
			return;
		
		var type:String;
		
		if(event.target is SuperNativeMenuItem)
			type = SuperNativeMenuItem(event.target).type;
		else if(event.target is NativeMenuItem)
			type = dataDescriptor.getType(event.target.data).toLowerCase();
		
		if(type=='check' || type=='radio') {
			NativeMenuItem(event.target).checked = !NativeMenuItem(event.target).checked;
			if(event.target is NativeMenuItem)
				event.target.dispatchEvent(PropertyChangeEvent.createUpdateEvent(event.target, "checked",
															!event.target.checked, event.target.checked));
		}
	}

	private function itemPropertyChangeHandler(event:PropertyChangeEvent):void
	{
		topLevelSuperMenu.processMenu(NativeMenuItem(event.target));
	}
}
}
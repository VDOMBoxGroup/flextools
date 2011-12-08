package net.vdombox.powerpack.lib.ExtendedAPI.ui
{
import flash.display.InteractiveObject;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;

import mx.collections.ICollectionView;
import mx.collections.errors.ItemPendingError;
import mx.controls.FlexNativeMenu;
import mx.controls.menuClasses.IMenuDataDescriptor;
import mx.core.Application;
import mx.core.EventPriority;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexNativeMenuEvent;
import mx.managers.ISystemManager;
import mx.validators.IValidatorListener;

public class SuperFlexNativeMenu extends FlexNativeMenu
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function SuperFlexNativeMenu()
	{
		super();
		
		_nativeMenu.addEventListener(Event.DISPLAYING, menuDisplayHandler, false, 0, true);
	}
	
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
		
    //----------------------------------
    //  nativeMenu
    //----------------------------------
	
	/**
 	* @private
 	*/
	private var _nativeMenu:NativeMenu = new SuperNativeMenu();
	
    [Bindable("nativeMenuUpdate")]

    /**
      *  Returns the flash.display.NativeMenu managed by this object,
      *  or null if there is not one.
      *
      *  Any changes made directly to the underlying NativeMenu instance
	  *  may be lost when changes are made to the menu or the underlying
	  *  data provider.
      */
	override public function get nativeMenu() : NativeMenu
	{
		return _nativeMenu;
	}	
	
	//----------------------------------
    //  dataDescriptor
    //----------------------------------

	/**
     *  @private
     */
    private var dataDescriptorChanged:Boolean = false;

    [Inspectable(category="Data")]

    /**
     *  The object that accesses and manipulates data in the data provider.
     *  The FlexNativeMenu control delegates to the data descriptor for information
     *  about its data. This data is then used to parse and move about the
     *  data source. The data descriptor defined for the FlexNativeMenu is used for
     *  all child menus and submenus.
     *
     *  <p>When you specify this property as an attribute in MXML, you must
     *  use a reference to the data descriptor, not the string name of the
     *  descriptor. Use the following format for setting the property:</p>
     *
     * <pre>&lt;mx:FlexNativeMenu id="flexNativeMenu" dataDescriptor="{new MyCustomDataDescriptor()}"/&gt;</pre>
     *
     *  <p>Alternatively, you can specify the property in MXML as a nested
     *  subtag, as the following example shows:</p>
     *
     *  <pre>&lt;mx:FlexNativeMenu&gt;
     *  &lt;mx:dataDescriptor&gt;
     *     &lt;myCustomDataDescriptor&gt;
     *  &lt;/mx:dataDescriptor&gt;
     *  ...</pre>
     *
     *  <p>The default value is an internal instance of the
     *  DefaultDataDescriptor class.</p>
     */
    override public function get dataDescriptor():IMenuDataDescriptor
    {
        return super.dataDescriptor;
    }

    /**
     *  @private
     */
    override public function set dataDescriptor(value:IMenuDataDescriptor):void
    {
     	super.dataDescriptor = value;   
        dataDescriptorChanged = true;
    }
    	
	//----------------------------------
    //  dataProvider
    //----------------------------------

	/**
     *  @private
     */
    private var dataProviderChanged:Boolean = false;

    [Bindable("collectionChange")]
    [Inspectable(category="Data")]

    /**
     *  The hierarchy of objects that are used to define the structure
	 *  of menu items in the NativeMenu. Individual data objects define
	 *  menu items, and items with child items become menus and submenus.
     *
     *  <p>The FlexNativeMenu control handles the source data object as follows:</p>
	 *
     *  <ul>
     *    <li>A String containing valid XML text is converted to an XML object.</li>
     *    <li>An XMLNode is converted to an XML object.</li>
     *    <li>An XMLList is converted to an XMLListCollection.</li>
     *    <li>Any object that implements the ICollectionView interface is cast to
     *        an ICollectionView.</li>
     *    <li>An Array is converted to an ArrayCollection.</li>
     *    <li>Any other type object is wrapped in an Array with the object as its sole
     *        entry.</li>
     *  </ul>
     *
     *  @default "undefined"
     */
    override public function get dataProvider():Object
    {
        return super.dataProvider;
    }

    /**
     *  @private
     */
    override public function set dataProvider(value:Object):void
    {
    	super.dataProvider = value;
       	dataProviderChanged = true;
    }

    //----------------------------------
    //  labelField
    //----------------------------------

	/**
     *  @private
     */
    private var labelFieldChanged:Boolean = false;

    [Bindable("labelFieldChanged")]
    [Inspectable(category="Data", defaultValue="label")]

    /**
     *  The name of the field in the data provider that determines the
     *  text to display for each menu item. If the data provider is an Array of
     *  Strings, Flex uses each string value as the label. If the data
     *  provider is an E4X XML object, you must set this property explicitly.
     *  For example, if each XML elementin an E4X XML Object includes a "label"
	 *  attribute containing the text to display for each menu item, set
	 *  the labelField to <code>"&#064;label"</code>.
     *
     *  <p>In a label, you can specify the character to be used as the mnemonic index
     *  by preceding it with an underscore. For example, a label value of <code>"C_ut"</code>
	 *  sets the mnemonic index to 1. Only the first underscore present is used for this
	 *  purpose.  To display a literal underscore character in the label, you can escape it
	 *  using a double underscore. For example, a label value of <code>"C__u_t"</code> would
	 *  result in a menu item with the label "C_ut" and a mnemonic index of 3 (the "t"
	 *  character). If the field defined in the <code>mnemonicIndexField</code> property
	 *  is present and set to a value greater than zero, that value takes precedence over
	 *  any underscore-specified mnemonic index value.</p>
     *
     *  <p>Setting the <code>labelFunction</code> property causes this property to be ignored.</p>
     *
     *  @default "label"
     */
    override public function get labelField():String
    {
        return super.labelField;
    }

    /**
     *  @private
     */
    override public function set labelField(value:String):void
    {
    	if (super.labelField != value) 
    	{
    	    super.labelField = value;
	        labelFieldChanged = true;
    	}
    }

    //----------------------------------
    //  showRoot
    //----------------------------------

    /**
     *  @private
     */
    private var showRootChanged:Boolean = false;

    [Inspectable(category="Data", enumeration="true,false", defaultValue="false")]

    /**
     *  A Boolean flag that specifies whether to display the data provider's
     *  root node.
     *
     *  <p>If the data provider has a root node, and the <code>showRoot</code> property
     *  is set to <code>false</code>, the top-level menu items displayed by the
	 *  FlexNativeMenu control correspond to the immediate descendants of the root node.</p>
     *
     *  <p>This flag has no effect when using a data provider without a root nodes,
     *  such as a List or Array.</p>
     *
     *  @default true
     *  @see #hasRoot
     */
    override public function get showRoot():Boolean
    {
        return super.showRoot;
    }

    /**
     *  @private
     */
    override public function set showRoot(value:Boolean):void
    {
        if (super.showRoot != value)
        {
            super.showRoot = value;
            showRootChanged = true;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
        	
	/**
	 *  Sets the context menu of the InteractiveObject to the underlying native menu.
	 */
	override public function setContextMenu(component:InteractiveObject):void
	{
		component.contextMenu = nativeMenu;
		
		if (component is Application)
		{
			var systemManager:ISystemManager = Application(component).systemManager;
			
			if (systemManager is InteractiveObject)
        		InteractiveObject(systemManager).contextMenu = nativeMenu;
		}
	}

    /**
     *  Processes the properties set on the component.
	 *
	 *  @see mx.core.UIComponent#commitProperties()
     */
    override protected function commitProperties():void
    {
        if (showRootChanged)
        {
            if (!hasRoot)
                showRootChanged = false;
        }
        
        if(SuperNativeMenu(nativeMenu).isProcessing)
        {
        	dataProviderChanged = false;
        }
            	
        if (dataProviderChanged ||showRootChanged ||
        	labelFieldChanged || dataDescriptorChanged)
        {
            var tmpCollection:ICollectionView;

            //reset flags
            dataProviderChanged = false;
            showRootChanged = false;
            labelFieldChanged = false;
            dataDescriptorChanged = false;

	        // are we swallowing the root?
	        if (mx_internal::_rootModel && !showRoot && hasRoot)
	        {
	            var rootItem:* = mx_internal::_rootModel.createCursor().current;
	            if (rootItem != null &&
	                dataDescriptor.isBranch(rootItem, mx_internal::_rootModel) &&
	                dataDescriptor.hasChildren(rootItem, mx_internal::_rootModel))
	            {
	                // then get rootItem children
	                tmpCollection =
	                    dataDescriptor.getChildren(rootItem, mx_internal::_rootModel);
	            }
	        }
	
	        // remove all items first.  This is better than creating a new NativeMenu
	        // as the root since we have the same reference
	        clearMenu(_nativeMenu);
	
	        // make top level items
	        if (mx_internal::_rootModel)
	        {
	            if (!tmpCollection)
	                tmpCollection = mx_internal::_rootModel;
	            // not really a default handler, but we need to
	            // be later than the wrapper
	            tmpCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
	                                           collectionChangeHandler,
	                                           false,
	                                           EventPriority.DEFAULT_HANDLER, true);
	
	         	populateMenu(_nativeMenu, tmpCollection);
	        }
	
	        dispatchEvent(new Event("nativeMenuChange"));
        }
    }
    
    /**
     *  Creates a menu and adds appropriate listeners
     *
     *  @private
     */
    private function createMenu():NativeMenu
    {
        var menu:NativeMenu = new SuperNativeMenu();
        // need to do this in the constructor for the root nativeMenu
        menu.addEventListener(Event.DISPLAYING, menuDisplayHandler, false, 0, true);

        return menu;
    }
 
    /**
     *  Clears out all items in a given menu
     *
     *  @private
     */
    private function clearMenu(menu:NativeMenu):void
    {
        var numItems:int = menu.numItems;
    	for (var i:int = 0; i < numItems; i++)
    	{
    		menu.removeItemAt(0);
    	}
    }    
        	
 
    /**
     *  Populates a menu and the related submenus given a collection
     *
     *  @private
     */
    private function populateMenu(menu:NativeMenu, collection:ICollectionView):NativeMenu
    {
        var collectionLength:int = collection.length;
        for (var i:int = 0; i < collectionLength; i++)
        {
            try
            {
                insertMenuItem(menu, i, collection[i]);
            }
            catch(e:ItemPendingError)
            {
                //we probably dont need to actively recover from here
            }
        }

        return menu;
    }
    
    /**
     *  Adds the SuperNativeMenuItem to the NativeMenu.  This methods looks at the
     *  properties of the data sent in and sets them properly on the NativeMenuItem.
     *
     *  @private
     */
    private function insertMenuItem(menu:NativeMenu, index:int, data:Object):void
    {
        if (dataProviderChanged && !SuperNativeMenu(nativeMenu).isProcessing)
        {
            commitProperties();
            return;
        }

		var type:String = dataDescriptor.getType(data).toLowerCase();
		var isSeparator:Boolean = (type == "separator");
		
		// label changes later, but separator is read-only so need to know here
		var nativeMenuItem:NativeMenuItem = new SuperNativeMenuItem(type, "");
		
		if (!isSeparator)
		{
			if(nativeMenuItem is SuperNativeMenuItem)
			{
				SuperNativeMenuItem(nativeMenuItem).type = type;
				SuperNativeMenuItem(nativeMenuItem).groupName = dataDescriptor.getGroupName(data);
				
				if (data is XML) {
					SuperNativeMenuItem(nativeMenuItem).name = data.@id.toString();
					SuperNativeMenuItem(nativeMenuItem).isRequired = data.@isRequired.toString().toLowerCase() == 'true';
				}
	        	else if (data is Object)
	        	{
	            	try {
						SuperNativeMenuItem(nativeMenuItem).name = data.id;
	                	SuperNativeMenuItem(nativeMenuItem).isRequired = data.isRequired;
	            	} catch(e:Error) {}
	         	}
	 		}
			
			// enabled
			nativeMenuItem.enabled = dataDescriptor.isEnabled(data);
			
			// checked
			nativeMenuItem.checked = (type == "check" || type == "radio") && dataDescriptor.isToggled(data);
			
			// data
			nativeMenuItem.data = dataDescriptor.getData(data, mx_internal::_rootModel);
			
			// key equivalent
			nativeMenuItem.keyEquivalent = itemToKeyEquivalent(data);
			
			// key equivalent modifiers
			nativeMenuItem.keyEquivalentModifiers = itemToKeyEquivalentModifiers(data);
			
			// label and mnemonic index
			var labelData:String = itemToLabel(data);
			var mnemonicIndex:int = itemToMnemonicIndex(data);
			
			if (mnemonicIndex >= 0)
			{
				nativeMenuItem.label = parseLabelToString(labelData);
				nativeMenuItem.mnemonicIndex = mnemonicIndex;
			}
			else
			{
				nativeMenuItem.label = parseLabelToString(labelData);
				nativeMenuItem.mnemonicIndex = parseLabelToMnemonicIndex(labelData);
			}
			
			// event listeners
			nativeMenuItem.addEventListener(flash.events.Event.SELECT, itemSelectHandler, false, 0, true);
			
			menu.addItem(nativeMenuItem);

			// recursive
			if (dataDescriptor.isBranch(data, mx_internal::_rootModel) &&
				dataDescriptor.hasChildren(data, mx_internal::_rootModel))
			{
				nativeMenuItem.submenu = createMenu();
				populateMenu(nativeMenuItem.submenu,
					dataDescriptor.getChildren(data, mx_internal::_rootModel));
			}
		}
		else
		{
			menu.addItem(nativeMenuItem);
		}
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
 	
 	/**
     *  @private
     */
    private function itemSelectHandler(event:Event):void
    {
        var nativeMenuItem:NativeMenuItem = event.target as NativeMenuItem;
        
        var menuEvent:FlexNativeMenuEvent = new FlexNativeMenuEvent(FlexNativeMenuEvent.ITEM_CLICK);
        menuEvent.nativeMenu = nativeMenuItem.menu;
        menuEvent.index = nativeMenuItem.menu.getItemIndex(nativeMenuItem);
        menuEvent.nativeMenuItem = nativeMenuItem;
        menuEvent.label = nativeMenuItem.label;
        menuEvent.item = nativeMenuItem.data;
        dispatchEvent(menuEvent);
    }
        	
    /**
     *  @private
     */
    private function menuDisplayHandler(event:Event):void
    {
        var nativeMenu:NativeMenu = event.target as NativeMenu;

        var menuEvent:FlexNativeMenuEvent = new FlexNativeMenuEvent(FlexNativeMenuEvent.MENU_SHOW);
        menuEvent.nativeMenu = nativeMenu;
        dispatchEvent(menuEvent);
    }	
   	
   	/**
     *  @private
     */
    private function collectionChangeHandler(ce:CollectionEvent):void
    {
    	if(SuperNativeMenu(nativeMenu).isProcessing)
    		return;
    	
        //trace("[FlexNativeMenu] caught Model changed");
        if (ce.kind == CollectionEventKind.ADD)
        {
            dataProviderChanged = true;
            invalidateProperties();
            // should handle elegantly with better performance
            //trace("[FlexNativeMenu] add event");
        }
        else if (ce.kind == CollectionEventKind.REMOVE)
        {
            dataProviderChanged = true;
            invalidateProperties();
            // should handle elegantly with better performance
            //trace("[FlexNativeMenu] remove event at:", ce.location);
        }
        else if (ce.kind == CollectionEventKind.REFRESH)
        {
            dataProviderChanged = true;
            dataProvider = dataProvider; //start over
            invalidateProperties();
            //trace("[FlexNativeMenu] refresh event");
        }
        else if (ce.kind == CollectionEventKind.RESET)
        {
            dataProviderChanged = true;
            invalidateProperties();
            //trace("[FlexNativeMenu] reset event");
        }
        else if (ce.kind == CollectionEventKind.UPDATE)
        {
         	dataProviderChanged = true;
            invalidateProperties();
            // should handle elegantly with better performance
            // but can't right now
            //trace("[FlexNativeMenu] update event");
        }
    }
}
}
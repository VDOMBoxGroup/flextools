package net.vdombox.powerpack.menu
{
import src.net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenu;
import src.net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenuItem;

import net.vdombox.powerpack.managers.ContextManager;
import net.vdombox.powerpack.managers.LanguageManager;

import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

import mx.controls.FlexNativeMenu;
import mx.events.FlexNativeMenuEvent;

public class MenuGeneral extends EventDispatcher
{	
	public static const LANG_FOLDER:String = "assets/lang";
	public static const STATE_NO:String = "noTemplate";
	public static const STATE_NEW:String = "newTemplate";
	public static const STATE_MOD:String = "modifiedTemplate";
	public static const STATE_OPEN:String = "openedTemplate";
	
	public static var state:String;
	public static var menu:FlexNativeMenu;
	private static var memMenu:Dictionary;
	
	
	public static function bindItems():void
	{
		bindItemsRecursive(MenuGeneral.menu.nativeMenu);
	}
	
	private static function bindItemsRecursive(menu:NativeMenu):void
	{
		for each (var item:NativeMenuItem in menu.items)
		{
			LanguageManager.bindSentence('menu_'+item.name, item, 'mnemonicLabel');
			
			if(item.submenu)
				bindItemsRecursive(item.submenu);
		}
	}
	
	public static function enable():void
	{
		if(memMenu)
		{
			for each(var item:NativeMenuItem in menu.nativeMenu.items)
				item.enabled = memMenu[item];
		}
		else
		{
			for each(item in menu.nativeMenu.items)
				item.enabled = true;
		}
	}
	
	public static function disable():void
	{
		memMenu = new Dictionary(true);
		
		for each(var item:NativeMenuItem in menu.nativeMenu.items)
			memMenu[item] = item.enabled;
	}
		
	public static function noTemplate():void
    {    	
    	state = STATE_NO;
    	 
    	// process file menu
		var fileMenu:NativeMenu = MenuGeneral.menu.nativeMenu.getItemByName("file").submenu;
		fileMenu.getItemByName("new_category").enabled = false;
		fileMenu.getItemByName("close").enabled = false;
		fileMenu.getItemByName("save").enabled = false;
		fileMenu.getItemByName("save_as").enabled = false;

    	// process template menu
		var tplItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("template");
		tplItem.enabled = false;
		for each (var item:NativeMenuItem in tplItem.submenu.items)
		{
			item.enabled = false;	
		}

    	// process run menu
		var runItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("run");
		runItem.enabled = false;
		for each (item in runItem.submenu.items)
		{
			item.enabled = false;	
		}
    }

	public static function newTemplate():void
	{
		state = STATE_NEW;
		
    	// process file menu
		var fileMenu:NativeMenu = MenuGeneral.menu.nativeMenu.getItemByName("file").submenu;
		fileMenu.getItemByName("new_category").enabled = true;
		fileMenu.getItemByName("close").enabled = true;
		fileMenu.getItemByName("save").enabled = true;
		fileMenu.getItemByName("save_as").enabled = true;

    	// process template menu
		var tplItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("template");
		tplItem.enabled = true;
		for each (var item:NativeMenuItem in tplItem.submenu.items)
		{
			item.enabled = true;	
		}

    	// process run menu
		var runItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("run");
		runItem.enabled = true;
		for each (item in runItem.submenu.items)
		{
			item.enabled = true;	
		}
		
		runItem.submenu.getItemByName("run").enabled = true;
		runItem.submenu.getItemByName("debug").enabled = true;
		runItem.submenu.getItemByName("step_by_step").enabled = true;
    }
	
	public static function modifiedTemplate():void
    {
    	state = STATE_MOD;
    	
    	// process file menu
		var fileMenu:NativeMenu = MenuGeneral.menu.nativeMenu.getItemByName("file").submenu;
		fileMenu.getItemByName("new_category").enabled = true;
		fileMenu.getItemByName("close").enabled = true;
		fileMenu.getItemByName("save").enabled = true;
		fileMenu.getItemByName("save_as").enabled = true;
		
    	// process template menu
		var tplItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("template");
		tplItem.enabled = true;
		for each (var item:NativeMenuItem in tplItem.submenu.items)
		{
			item.enabled = true;	
		}
    	
    	// process run menu
		var runItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("run");
		runItem.enabled = true;
		for each (item in runItem.submenu.items)
		{
			item.enabled = false;	
		}
		
		runItem.submenu.getItemByName("run").enabled = true;
		runItem.submenu.getItemByName("debug").enabled = true;
		runItem.submenu.getItemByName("step_by_step").enabled = true;
    }
    
    public static function openedTemplate():void
    {
    	state = STATE_OPEN;
    	
    	// process file menu
		var fileMenu:NativeMenu = MenuGeneral.menu.nativeMenu.getItemByName("file").submenu;
		fileMenu.getItemByName("new_category").enabled = true;
		fileMenu.getItemByName("close").enabled = true;
		fileMenu.getItemByName("save").enabled = false;
		fileMenu.getItemByName("save_as").enabled = true;

    	// process template menu
		var tplItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("template");
		tplItem.enabled = true;
		for each (var item:NativeMenuItem in tplItem.submenu.items)
		{
			item.enabled = true;	
		}

    	// process run menu
		var runItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("run");
		runItem.enabled = true;
		for each (item in runItem.submenu.items)
		{
			item.enabled = false;	
		}
		
		runItem.submenu.getItemByName("run").enabled = true;
		runItem.submenu.getItemByName("debug").enabled = true;
		runItem.submenu.getItemByName("step_by_step").enabled = true;	
    }

	public static function updateLangMenu():void
    {
        // get language folder
        var langsDir:File = File.applicationDirectory.resolvePath(LANG_FOLDER);
        
        if(langsDir.exists)
        {
			var fileList:Array = langsDir.getDirectoryListing();					
			
			var settingsItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("settings");
			var langItem:NativeMenuItem = settingsItem.submenu.getItemByName("language");
			
			if(langItem.submenu)
				langItem.submenu.removeAllItems();
			else
			{
				langItem.submenu = new SuperNativeMenu();
				langItem.submenu.addEventListener(Event.SELECT, selectMenu_01);
				
				function selectMenu_01(event:Event):void {
					var item:SuperNativeMenuItem = event.target as SuperNativeMenuItem;
					var clickEvent:FlexNativeMenuEvent = new FlexNativeMenuEvent(
						FlexNativeMenuEvent.ITEM_CLICK,
						false, 
						false,
						item.menu,
						item,
						item.data,
						item.label,
						item.menu.getItemIndex(item));											
						
					MenuGeneral.menu.dispatchEvent(clickEvent);
				}
			}
				
			// get language files
			for (var i:int = 0; i < fileList.length; i++) 
			{	
				var fileStream:FileStream = new FileStream();
				fileStream.open(fileList[i], FileMode.READ);
									
				var langXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();						
				
				if(langXML.name()!="language" || !langXML.@id.toString() || !langXML.@label.toString())
					continue;
				
				var item:SuperNativeMenuItem = new SuperNativeMenuItem(
					"radio", 
					langXML.@label,
					langXML.@id,
					false,
					"language",
					true,
					true);
				
				item.data = fileList[i].name;
				
				if(ContextManager.instance.lang.label.toLowerCase() == langXML.@label.toLowerCase())
				{
					ContextManager.instance.lang.file = fileList[i].name
					item.checked = true;
				}
				
				langItem.submenu.addItem(item);
			}
			
			if(langItem.submenu.numItems==0)
				langItem.enabled = false;	
			else			
				langItem.enabled = true;
        }		    
    }
    
    public static function updateLastFilesMenu():void
    {
        if(ContextManager.instance.files && ContextManager.instance.files.length>0)
        {
        	var fileItem:NativeMenuItem = MenuGeneral.menu.nativeMenu.getItemByName("file");
			var exitItem:NativeMenuItem = fileItem.submenu.getItemByName("exit");
			
			for each(var item:SuperNativeMenuItem in fileItem.submenu.items)
			{
				if(item.groupName=='lastfiles')
					item.menu.removeItem(item);
			} 
			
        	for (var i:int = 0; i < ContextManager.instance.files.length; i++) 
			{
				var label:String = (i+1)+" "+(ContextManager.instance.files[i] as File).name + 
									 " ["+(ContextManager.instance.files[i] as File).parent.nativePath+"]";
				
				item = new SuperNativeMenuItem(
					"normal",
					label,
					"lastfile"+i,
					false,
					"lastfiles");
									
				item.data = (ContextManager.instance.files[i] as File).nativePath;
				
				fileItem.submenu.addItemAt(item, exitItem.menu.getItemIndex(exitItem));
				
				item.addEventListener(Event.SELECT, selectMenuItem_01);
				
				function selectMenuItem_01(event:Event):void {
					var item:SuperNativeMenuItem = event.target as SuperNativeMenuItem;
					var clickEvent:FlexNativeMenuEvent = new FlexNativeMenuEvent(
						FlexNativeMenuEvent.ITEM_CLICK,
						false, 
						false,
						item.menu,
						item,
						item.data,
						item.label,
						item.menu.getItemIndex(item));											
						
					MenuGeneral.menu.dispatchEvent(clickEvent);
				}				
   			}
			
			item = new SuperNativeMenuItem(
				"separator",
				"",
				"lastfile",
				false,
				"lastfiles");
								
			fileItem.submenu.addItemAt(item, exitItem.menu.getItemIndex(exitItem));
        }		    	
    }	
    
}
}
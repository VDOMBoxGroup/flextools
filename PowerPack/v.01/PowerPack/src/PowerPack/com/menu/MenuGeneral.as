package PowerPack.com.menu
{
import PowerPack.com.managers.ContextManager;

import flash.display.NativeMenuItem;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

import mx.controls.FlexNativeMenu;

public class MenuGeneral extends EventDispatcher
{	
	public static const LANG_FOLDER:String = "lang";
	public static const STATE_NO:String = "noTemplate";
	public static const STATE_NEW:String = "newTemplate";
	public static const STATE_MOD:String = "modifiedTemplate";
	public static const STATE_OPEN:String = "openedTemplate";
	
	public static var state:String;
	public static var menu:FlexNativeMenu;
	private static var memMenu:Dictionary;
	
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
		
	public static function noTemplate(menu:XML):void
    {    	
    	state = STATE_NO;
    	 
    	var item:XML;
    	
    	// process file menu
    	var fileItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "file")[0];
    	
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "new_category")[0].@enabled = 'false';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "close")[0].@enabled = 'false';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save")[0].@enabled = 'false';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save_as")[0].@enabled = 'false';

    	// process template menu
    	var templateItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "template")[0];
    	templateItem.@enabled = 'false';
    	for each(item in templateItem.menuitem)
    	{
    		item.@enabled = 'false';
    	}

    	// process run menu
    	var runItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "run")[0];
    	runItem.@enabled = 'false';
    	for each(item in runItem.menuitem)
    	{
    		item.@enabled = 'false';
    	}
    }

	public static function newTemplate(menu:XML):void
	{
		state = STATE_NEW;
		
    	var item:XML;
    	
    	// process file menu
    	var fileItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "file")[0];
    	
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "new_category")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "close")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save_as")[0].@enabled = 'true';

    	// process template menu
    	var templateItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "template")[0];
    	templateItem.@enabled = 'true';
    	for each(item in templateItem.menuitem)
    	{
    		item.@enabled = 'true';
    	}

    	// process run menu
    	var runItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "run")[0];
    	runItem.@enabled = 'true';
    	for each(item in runItem.menuitem)
    	{
    		item.@enabled = 'false';
    	}
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "run")[0].@enabled = 'true';
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "debug")[0].@enabled = 'true';
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "step_by_step")[0].@enabled = 'true';
    }
	
	public static function modifiedTemplate(menu:XML):void
    {
    	state = STATE_MOD;
    	
    	var item:XML;
    	
    	// process file menu
    	var fileItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "file")[0];
    	
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "new_category")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "close")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save_as")[0].@enabled = 'true';

    	// process template menu
    	var templateItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "template")[0];
    	templateItem.@enabled = 'true';
    	for each(item in templateItem.menuitem)
    	{
    		item.@enabled = 'true';
    	}

    	// process run menu
    	var runItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "run")[0];
    	runItem.@enabled = 'true';
    	for each(item in runItem.menuitem)
    	{
    		item.@enabled = 'false';
    	}
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "run")[0].@enabled = 'true';
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "debug")[0].@enabled = 'true';
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "step_by_step")[0].@enabled = 'true';    	
    }
    
    public static function openedTemplate(menu:XML):void
    {
    	state = STATE_OPEN;
    	
    	var item:XML;
    	
    	// process file menu
    	var fileItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "file")[0];
    	
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "new_category")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "close")[0].@enabled = 'true';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save")[0].@enabled = 'false';
    	fileItem.menuitem.(hasOwnProperty('@id') && @id == "save_as")[0].@enabled = 'true';

    	// process template menu
    	var templateItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "template")[0];
    	templateItem.@enabled = 'true';
    	for each(item in templateItem.menuitem)
    	{
    		item.@enabled = 'true';
    	}

    	// process run menu
    	var runItem:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "run")[0];
    	runItem.@enabled = 'true';
    	for each(item in runItem.menuitem)
    	{
    		item.@enabled = 'false';
    	}
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "run")[0].@enabled = 'true';
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "debug")[0].@enabled = 'true';
    	runItem.menuitem.(hasOwnProperty('@id') && @id == "step_by_step")[0].@enabled = 'true';    	
    }

	public static function updateLangMenu(menu:XML):void
    {
        // get language folder
        var langsDir:File = File.applicationDirectory.resolvePath(LANG_FOLDER);
        
        if(langsDir.exists)
        {
			var fileList:Array = langsDir.getDirectoryListing();					
			var langsItemXML:XML = menu..menuitem.(hasOwnProperty('@id') && @id == "language")[0];
			var langList:XML = new XML(<list/>);
			
			// get language files
			for (var i:int = 0; i < fileList.length; i++) 
			{	
				var fileStream:FileStream = new FileStream();
				fileStream.open(fileList[i], FileMode.READ);
									
				var langXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();						
				
				if(langXML.name()!="language" || !langXML.@id.toString() || !langXML.@label.toString())
					continue;
									
				var item:XML = new XML(<menuitem/>);
				item.@label = langXML.@label;
				item.@id = langXML.@id;
				item.@data = fileList[i].name;
				item.@type = "radio";
				item.@tag = "language";
				item.@groupName = "language";
				item.@isRequired = "true";
				
				if(ContextManager.instance.lang.label.toLowerCase() == langXML.@label.toLowerCase())
				{
					ContextManager.instance.lang.file = fileList[i].name
					item.@toggled = "true";
				}
				langList.appendChild(item);						
			}
			
			// fill language submenu
			langsItemXML.setChildren(langList.menuitem);
				
			if(langsItemXML.elements("*").length()==0)
				langsItemXML.@enabled = "false";	
			else			
				langsItemXML.@enabled = "true";	
        }		    
    }
    
    public static function updateLastFilesMenu(menu:XML):void
    {
        if(ContextManager.instance.files && ContextManager.instance.files.length>0)
        {
			var fileMenuXML:XML = menu.menuitem.(hasOwnProperty('@id') && @id == "file")[0];
			var exitItemXML:XML = menu..menuitem.(hasOwnProperty('@id') && @id == "exit")[0];
			
			while(menu..menuitem.(hasOwnProperty('@tag') && @tag == "lastfiles").length()>0) {
				delete menu..menuitem.(hasOwnProperty('@tag') && @tag == "lastfiles")[0];
			}
			
        	for (var i:int = 0; i < ContextManager.instance.files.length; i++) 
			{
				var fileItemXML:XML = new XML(<menuitem/>); 
				fileItemXML.@label = (i+1)+" "+(ContextManager.instance.files[i] as File).name + 
									 " ["+(ContextManager.instance.files[i] as File).parent.nativePath+"]";
				fileItemXML.@id = "lastfile"+i;
				fileItemXML.@data = (ContextManager.instance.files[i] as File).nativePath;
				fileItemXML.@tag = "lastfiles";						

        		fileMenuXML.insertChildBefore(exitItemXML, fileItemXML);
   			}
			fileMenuXML.insertChildBefore(exitItemXML, <menuitem type="separator" tag="lastfiles"/>);
        }		    	
    }	
    
}
}
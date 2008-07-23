package PowerPack.com.menu
{
import PowerPack.com.managers.ContextManager;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class MenuGeneral extends EventDispatcher
{	
	public static const LANG_FOLDER:String = "lang";
	
	public static function updateLangMenu(menu:XML):void
    {
        // get language folder
        var langsDir:File = File.applicationDirectory.resolvePath(LANG_FOLDER);
        
        if(langsDir.exists)
        {
			var fileList:Array = langsDir.getDirectoryListing();					
			var langsItemXML:XML = menu..menuitem.(hasOwnProperty('@id') && @id == "language")[0];
			var langList:XML = new XML(<list></list>);
			
			// get language files
			for (var i:int = 0; i < fileList.length; i++) 
			{	
				var fileStream:FileStream = new FileStream();
				fileStream.open(fileList[i], FileMode.READ);
									
				var langXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();						
				
				if(langXML.name()!="language" || !langXML.@id.toString() || !langXML.@label.toString())
					continue;
									
				var item:XML = new XML(<menuitem></menuitem>);
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
				var fileItemXML:XML = new XML(<menuitem></menuitem>); 
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
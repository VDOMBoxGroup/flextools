package PowerPack.com
{
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.utils.FileToBase64;
import ExtendedAPI.com.utils.FileUtils;
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.managers.CashManager;
import PowerPack.com.managers.ContextManager;
import PowerPack.com.managers.LanguageManager;
import PowerPack.com.managers.ProgressManager;
import PowerPack.com.utils.CryptUtils;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.utils.ByteArray;

import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;
import mx.utils.StringUtil;
import mx.utils.UIDUtil;

/**
 * 
 *	<template ID=''>
 * 		<name/>
 * 		<description/>
 * 		<picture/>
 * 		<encoded> or <structure>
 * 			<graph name='' initial='' category=''>
 * 				<states>
 * 					<state name='' type='' category='' enabled='' breakpoint='' x='' y=''>
 * 						<text/>
 * 					</state>
 * 					...
 * 				</states>
 * 				
 * 				<transitions>
 * 					<transition name='' highlighted='' enabled='' source='' destination=''>
 * 						<label/>
 * 					</transition>
 * 					...
 * 				</transitions>
 * 			</graph>
 * 			...
 *			<categories>
 *				<category name=''/>
 *				...
 *			</categories>
 * 				
 *			<resources>
 *				<resource category='' ID='' type='' name=''/>
 *				...
 *			</resources>
 * 		</encoded> or </structure>
 * 	</template>
 * 
 */ 
 
public class Template extends EventDispatcher
{
	public static var defaultCaptions:Object = {
	};
	
	public static const TYPE_APPLICATION:String = "Application";
	public static const TYPE_MODULE:String = "Module";
			
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *	Constructor
	 */ 
	public function Template(xml:XML=null)
	{
		if(xml && isValidTpl(xml))
		{
			_xml = xml;
			if(!Utils.getStringOrDefault(_xml.@ID, ''))
				_xml.@ID = UIDUtil.createUID();
		}
		else
		{
			_xml = new XML(<template/>);
			_xml.@ID = UIDUtil.createUID();
			modified = true;
		}
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
	 	file = null;
	 	_xml = null;
	 }  
	 
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
	[Bindable]
	public var key:String;
	
	[Bindable]
	public var modified:Boolean;
	
	[Bindable]
	public var file:File;	
	
	public var tplFilter:FileFilter = new FileFilter(
		StringUtil.substitute("{0} ({1})", LanguageManager.sentences['template'], "*.xml"), 
		"*.xml");
	
	public var allFilter:FileFilter = new FileFilter(
		StringUtil.substitute("{0} ({1})", LanguageManager.sentences['all'], "*.*"), 
		"*.*");	

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
    
    //----------------------------------
    //  xml
    //----------------------------------
    
	private var _xml:XML;
			
	public function get xml():XML
	{
		return _xml;
	}

    //----------------------------------
    //  xmlStructure
    //----------------------------------

	private var _xmlStructure:XML;
	
	[Bindable]
	public function set xmlStructure(value:XML):void
	{
		if(_xmlStructure!=value)
		{
			modified = true;
			_xmlStructure=value;		
		}
	}
	public function get xmlStructure():XML
	{
		return _xmlStructure;
	}		

    //----------------------------------
    //  picturePath
    //----------------------------------
	
	private var _picturePath:String;
			
	[Bindable]
	public function set picturePath(value:String):void
	{
		if(_picturePath!=value)
		{
			modified = true;
			_picturePath = value;		
		}
	}
	public function get picturePath():String
	{
		return _picturePath;
	}	
					
    //----------------------------------
    //  name
    //----------------------------------

	[Bindable]
	public function set name(value:String):void
	{
		if(_xml.name != value)
		{
			modified = true;
			_xml.name = value;
		}	
	}		
	public function get name():String
	{
		return Utils.getStringOrDefault(_xml.name, '');	
	}		

    //----------------------------------
    //  description
    //----------------------------------

	[Bindable]
	public function set description(value:String):void
	{
		if(_xml.description != value)
		{
			modified = true;
			_xml.description = value;	
		}
	}		
	public function get description():String
	{
		return Utils.getStringOrDefault(_xml.description, '');	
	}		
	
    //----------------------------------
    //  ID
    //----------------------------------

	[Bindable]
	public function set ID(value:String):void
	{
		if(_xml.@ID != value)
		{
			modified = true;
			_xml.@ID = value;
		}	
	}		
	public function get ID():String
	{
		return _xml.@ID;	
	}		

    //----------------------------------
    //  b64picture
    //----------------------------------

	[Bindable]
	public function set b64picture(value:String):void
	{
		if(_xml.picture != value)
		{
			modified = true;								
			_xml.picture = value;	
		}
	}	
	public function get b64picture():String
	{
		return Utils.getStringOrDefault(_xml.picture[0], '');	
	}		
	
    //----------------------------------
    //  isEncoded
    //----------------------------------

	public function get isEncoded():Boolean
	{
		return _xml.hasOwnProperty('encoded');	
	}		

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	public function isValidTpl(xmlData:XML):Boolean
	{
		return true;
	}
	
	public function save():void
	{
		
		modified = false;
	}
	
	
	public function saveAs():void
	{
		
		modified = false;
	}
	
	public function open():void
	{
		if(!file)
		{
			browseForOpen();
			return;
		}
		
	   	var stream:FileStream = new FileStream();
		
		ProgressManager.source = stream;
		ProgressManager.start();
		
		stream.addEventListener(Event.COMPLETE, openHandler);
		stream.addEventListener(IOErrorEvent.IO_ERROR, openErrorHandler);
		stream.openAsync(file, FileMode.READ);
		
		//ContextManager.updateLastFiles(file);            	
		//MenuGeneral.updateLastFilesMenu(fileMenuData);
	}

	public function browseForOpen():void
	{
        var folder:File = ContextManager.instance.lastDir;
						
		folder.addEventListener(Event.SELECT, openBrowseHandler);
		folder.browseForOpen(LanguageManager.sentences['open_file'], [tplFilter, allFilter])
		
		function openBrowseHandler(event:Event):void {
			var f:File = event.target as File;
			
			if(f.isDirectory)
            	return;
            
            file = f;
         	
         	open();   
		}
	}	

	public function encode():void
	{
		delete _xml.encoded;
		delete _xml.structure;
		
		if(key)
		{
			var bytes:ByteArray = CryptUtils.encrypt(_xmlStructure.toXMLString(), key);
			
			var encoder:Base64Encoder = new Base64Encoder();
		    encoder.encodeBytes(bytes);
		    _xml.encoded = encoder.flush();
		}
		else
			_xml.structure = _xmlStructure;
	}
	
	public function decode():void
	{
		_xmlStructure = null;
		
		if(isEncoded && key)
		{			
			try 
			{	
				var strEncoded:String = _xml.encoded[0]; 
		 		var strDecoded:String;
		 	
				var decoder:Base64Decoder = new Base64Decoder();
			    decoder.decode(strEncoded);				
				var bytes:ByteArray = decoder.flush();	
			
				bytes = CryptUtils.decrypt(bytes, key);	
				bytes.position = 0;
				strDecoded = bytes.readUTFBytes(bytes.length);
			 	_xmlStructure = XML(strDecoded);
			 	
				if(_xmlStructure)
				{
			 		if(_xmlStructure.name().localName!='structure')
			 			_xmlStructure = null;
			 		else
			 			delete _xml.encoded;
			 	}
			} 
			catch(e:*) {
				_xmlStructure = null;
			}				
		}	
		else if(_xml.hasOwnProperty('structure'))
			_xmlStructure = _xml.structure[0];
	}
	
	public function setPictureFromPath():void
	{
		if(!picturePath || !FileUtils.isValidPath(picturePath))
		{
			//throw new BasicError("Not valid filename");
			return;
		}
	
		var file:File = new File(picturePath);
		//file.url = FileUtils.pathToUrl(picturePath);
	
		if(!file.exists)
		{
			//throw new BasicError("File does not exists");
			return;
		}
		
		picturePath = null;
		
		var fileToBase64:FileToBase64 = new FileToBase64(file.nativePath);
		fileToBase64.convert();						
		b64picture = fileToBase64.data.toString();
	}
	
	public function cash():void
	{
		for each (var res:XML in _xml.resources)
		{
			CashManager.setStringObject(ID, 
				XML(
					"<resource " + 
					"category='" +	Utils.getStringOrDefault(res.@category, "") + "' " + 
					"ID='" +		Utils.getStringOrDefault(res.@ID, "") + "' " + 
					"name='" +		Utils.getStringOrDefault(res.@name, "") + "' " + 
					"type='" +		Utils.getStringOrDefault(res.@type, "") + "' />"), 
				res);
		} 
		
		delete _xml.resources;
		
		CashManager.setStringObject(ID, 
			XML(
				"<resource " + 
				"category='template' " + 
				"ID='" + ID + "' " + 
				"name='" + name + "' " + 
				"type='" + TYPE_APPLICATION + "' />"), 
			res);
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function openHandler(event:Event):void 
	{
		var stream:FileStream = event.target as FileStream;
    	
    	try 
    	{
    		ProgressManager.start(ProgressManager.DIALOG_MODE, false);
    		 
    		var strData:String = stream.readUTFBytes(stream.bytesAvailable);
    		var xmlData:XML = XML(strData);
    		
    		if(!isValidTpl(xmlData))
    			throw new Error(LanguageManager.sentences['msg_not_valid_tpl_file']);
			
			_xml = xmlData;
			
			if(isEncoded && key)
			{
				decode();
				
				if(xmlStructure)
					cash();
			}
			
			ProgressManager.complete();

			modified = false;
			dispatchEvent( new Event(Event.COMPLETE) );
    	}
    	catch(e:Error)
    	{
    		ProgressManager.complete();
			stream.close();
	
			var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, true, 
				LanguageManager.sentences['msg_not_valid_tpl_file']);
			 
			dispatchEvent(errEvent);	
			
			if(!errEvent.isDefaultPrevented())
			{
				SuperAlert.show( 
					LanguageManager.sentences['msg_not_valid_tpl_file'],
					LanguageManager.sentences['error']);    		
			}
    	}			
	}
	
	private function openErrorHandler(event:IOErrorEvent):void
	{
		ProgressManager.complete();

		var stream:FileStream = event.target as FileStream;
		file.cancel();
		stream.close();

		var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, true, event.text);
		 
		dispatchEvent(errEvent);
		
		if(!errEvent.isDefaultPrevented())
		{
			SuperAlert.show( 
				LanguageManager.sentences['msg_ioerror_occurs'],
				LanguageManager.sentences['error']);
		}	
	}

}
}
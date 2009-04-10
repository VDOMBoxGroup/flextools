package PowerPack.com
{
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.utils.FileToBase64;
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
import flash.events.OutputProgressEvent;
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
	public static const TYPE_APPLICATION:String = "application";
	public static const TYPE_MODULE:String = "module";
	
	public static const TPL_EXTENSION:String = 'xml';
			
	public static var tplFilter:FileFilter = new FileFilter(
		StringUtil.substitute("{0} ({1})", LanguageManager.sentences['template'], "*."+TPL_EXTENSION), 
		"*."+TPL_EXTENSION);
	
	public static var allFilter:FileFilter = new FileFilter(
		StringUtil.substitute("{0} ({1})", LanguageManager.sentences['all'], "*.*"), 
		"*.*");	

	public static var defaultCaptions:Object = {
	};
	
    private static var _classConstructed:Boolean = classConstruct();
    
    public static function get classConstructed():Boolean
    {
    	return _classConstructed;
    }
        
    // Define a static method.
    private static function classConstruct():Boolean
    {
        LanguageManager.setSentences(defaultCaptions);
        
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
	public function Template(xml:XML=null)
	{
		_xml = new XML(<template/>);
		_xml.@ID = UIDUtil.createUID();

		if(xml && isValidTpl(xml))
		{
			_xml = xml;
			if(!Utils.getStringOrDefault(_xml.@ID, ''))
				_xml.@ID = UIDUtil.createUID();
			
			processOpened();
			return;
		}
		else if(!xml)
		{
			modified = true;
			_completelyOpened = true;
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
	 	_xmlStructure = null;
	 	_picture = null;
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
	public var file:File;
	
	private var _completelyOpened:Boolean;
	
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
    

    //----------------------------------
    //  modified
    //----------------------------------

	private var _modified:Boolean;
	
	[Bindable]
	public function set modified(value:Boolean):void
	{
		if(_modified!=value)
		{
			_modified = value;
			
			var mainIndex:XML = CashManager.getMainIndex();	
			CashManager.updateMainIndexEntry(mainIndex, fullID, 'saved', _modified?'false':'true');
			CashManager.setMainIndex(mainIndex);
		}
	}
	public function get modified():Boolean
	{
		return _modified;
	}


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
			_xmlStructure = value;		
		}
	}
	public function get xmlStructure():XML
	{
		return _xmlStructure;
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
		if(!_xml.hasOwnProperty('@ID'))
			_xml.@ID = UIDUtil.createUID();

		return _xml.@ID;	
	}
	
    //----------------------------------
    //  fullID
    //----------------------------------
    
	private var _fullID:String;
	
	public function get fullID():String
	{
		if(!_fullID)
		{
			_fullID = ID;
			
			if(file && file.exists)
				_fullID += '_' + file.creationDate.getTime() + '_' + file.modificationDate.getTime() + '_' + file.size;
		}

		return _fullID;	
	}		

    //----------------------------------
    //  picture
    //----------------------------------
	
	private var _picture:File;
			
	[Bindable]
	public function set picture(value:File):void
	{
		if(!value || !_picture || _picture.nativePath!=value.nativePath)
		{
			modified = true;
			_picture = value;		
		}
	}
	public function get picture():File
	{
		return _picture;
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
	
	private function isValidTpl(xmlData:XML):Boolean
	{
		if(xmlData.name() != 'template')
			return false;
			
		if(!xmlData.hasOwnProperty('encoded') && !xmlData.hasOwnProperty('structure'))
			return false;
	
		return true;
	}
	
	public function save():void
	{
		if(!_completelyOpened)
			return;
		
		if(!file)
		{
			browseForSave();
			return;
		}		

		try
		{
			ProgressManager.start(null, false);
			
	      	// update tpl UID
	   		_xml.@ID = UIDUtil.createUID();	   		

			// cash template structure
			cashStructure();
				
			/// get resources from cash 
	   		fillFromCash();
	   		
	   		// set (+encrypt) structure and resources data
	   		encode();
	   		
		   	var stream:FileStream = new FileStream();
			
			ProgressManager.source = stream;
			ProgressManager.start();
			
			stream.addEventListener(Event.COMPLETE, saveHandler);
			stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, outputProgressHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, saveErrorHandler);
			stream.openAsync(file, FileMode.WRITE);				
			
			stream.writeUTFBytes(_xml.toXMLString());
		}
		catch(e:Error)
		{
			stream.close();

    		ProgressManager.complete();
	
			var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, true, 
				e.message);
			 
			dispatchEvent(errEvent);	
			
			if(!errEvent.isDefaultPrevented())
			{
				SuperAlert.show( 
					e.message,
					LanguageManager.sentences['error']);    		
			}			
		}
	}
	
	public function open():void
	{
		// check for not saved tpl
		
		if(!file)
		{
			browseForOpen();
			return;
		}
		
		if(!file.exists)
		{
			var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, true, 
				LanguageManager.sentences['msg_file_not_exists']);
			 
			dispatchEvent(errEvent);
			
			if(!errEvent.isDefaultPrevented())
			{
				SuperAlert.show( 
					errEvent.text,
					LanguageManager.sentences['error']);    		
			}
			return;
		}
		
	   	var stream:FileStream = new FileStream();
		
		ProgressManager.source = stream;
		ProgressManager.start();
		
		stream.addEventListener(Event.COMPLETE, openHandler);
		stream.addEventListener(IOErrorEvent.IO_ERROR, openErrorHandler);
		stream.openAsync(file, FileMode.READ);
	}

	public function browseForSave():void
	{
        var folder:File = ContextManager.instance.lastDir;
						
		folder.addEventListener(Event.SELECT, saveBrowseHandler);
		folder.browseForSave(LanguageManager.sentences['save_file']);
		
		function saveBrowseHandler(event:Event):void {
			var f:File = event.target as File;
			f.removeEventListener(Event.SELECT, saveBrowseHandler);
			
			if(f.isDirectory || f.isPackage || f.isSymbolicLink)
            	return;
           	
           	if(!f.extension || f.extension.toLowerCase() != TPL_EXTENSION)            	
            	f = f.parent.resolvePath(f.name+'.'+TPL_EXTENSION);
 
            file = f;
            
         	var evnt:Event = new Event('saving', false, true);
         	dispatchEvent(evnt);
         	
         	if(!evnt.isDefaultPrevented())         	
         		save();   
		}
	}
	
	public function browseForOpen():void
	{
        var folder:File = ContextManager.instance.lastDir;
						
		folder.addEventListener(Event.SELECT, openBrowseHandler);
		folder.browseForOpen(LanguageManager.sentences['open_file'], [tplFilter, allFilter])
		
		function openBrowseHandler(event:Event):void {
			var f:File = event.target as File;
			f.removeEventListener(Event.SELECT, openBrowseHandler);
			
			if(f.isDirectory || f.isPackage || f.isSymbolicLink)
            	return;
            
            file = f;
         	
         	var evnt:Event = new Event('opening', false, true);
         	dispatchEvent(evnt);
         	
         	if(!evnt.isDefaultPrevented())
         		open();   
		}
	}	
	
	public function processOpened():void
	{
		if(!_xml.hasOwnProperty('encoded') && !_xml.hasOwnProperty('structure'))
			return;
		
		decode();
			
		if(_xmlStructure)
			cash();
		
		if(!isEncoded)
			_completelyOpened = true;
	}
	
	private function encode():void
	{
		delete _xml.encoded;
		delete _xml.structure;
		
		var structData:XML = _xmlStructure ? _xmlStructure : new XML(<structure/>);
		
		if(key)
		{
			var bytes:ByteArray = CryptUtils.encrypt(structData.toXMLString(), key);
			
			var encoder:Base64Encoder = new Base64Encoder();
		    encoder.encodeBytes(bytes);
		    _xml.encoded = encoder.flush();
		}
		else
			_xml.structure = structData;
	}
	
	private function decode():void
	{
		_xmlStructure = null;
		
		if(isEncoded && _xml.hasOwnProperty('structure'))
			delete _xml.structure;
		
		if(isEncoded && key)
		{			
			try 
			{	
				var strEncoded:String = XML(_xml.encoded[0]).toString(); 
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
			 		if(_xmlStructure.name().localName=='structure')
			 			delete _xml.encoded;
			 		else
			 			_xmlStructure = null;
			 	}
			} 
			catch(e:*) 
			{
				_xmlStructure = null;
			}				
		}	
		else if(_xml.hasOwnProperty('structure'))
		{
			_xmlStructure = _xml.structure[0];
			delete _xml.structure;
		}
	}
	
	private function setPictureFromFile():Boolean
	{
		if(!picture || !picture.exists)
		{
			return false;
		}
		
		var fileToBase64:FileToBase64 = new FileToBase64(picture.nativePath);
		fileToBase64.convert();						
		b64picture = fileToBase64.data.toString();
		
		_xml.picture[0].@type = file.extension;
		_xml.picture[0].@name = file.name;
		
		picture = null;
		
		return true;
	}
	
	private function cash():Boolean
	{
		if(_xmlStructure==null)
			return false;
		
		// cash all resources
		for each (var res:XML in _xmlStructure.resources.resource)
		{
			CashManager.setStringObject(fullID, 
				XML(
					"<resource " + 
					"category='" +	Utils.getStringOrDefault(res.@category, "") + "' " + 
					"ID='" +		Utils.getStringOrDefault(res.@ID, "") + "' " + 
					"name='" +		Utils.getStringOrDefault(res.@name, "") + "' " + 
					"type='" +		Utils.getStringOrDefault(res.@type, "") + "' />"), 
				res);
		} 
		
		delete _xmlStructure.resources;
		
		// cash tpl picture
		if(b64picture)
		{
			var picXML:XML = _xml.picture[0];
			CashManager.setStringObject(fullID, 
				XML(
					"<resource " + 
					"category='logo' " + 
					"ID='logo' " + 
					"name='" +		Utils.getStringOrDefault(picXML.@name, "") + "' " + 
					"type='" +		Utils.getStringOrDefault(picXML.@type, "") + "' />"), 
				b64picture);
				
			delete _xml.picture;
		}

		cashStructure();
			
		return true;
	}
	
	private function cashStructure():void
	{
		CashManager.setStringObject(fullID, 
			XML(
				"<resource " + 
				"category='template' " + 
				"ID='template' " + 
				"name='" + name + "' " + 
				"type='" + TYPE_APPLICATION + "' />"), 
			_xml.toXMLString());

		CashManager.setStringObject(fullID, 
			XML(
				"<resource " + 
				"category='template' " + 
				"ID='structure' " + 
				"name='" + name + "' " + 
				"type='" + TYPE_APPLICATION + "' />"), 
			_xmlStructure.toXMLString());		
	}

	private function fillFromCash():void
	{
		// get tpl picture
   		delete _xml.picture;

      	if(picture)
      		setPictureFromFile();
      	else
      	{
      		
      		var picObj:Object = CashManager.getObject(fullID, 'logo');
      		if(picObj)
      		{
      			var picData:ByteArray = ByteArray(picObj.data);
      		
      			_xml.picture = picData.readUTFBytes(picData.bytesAvailable);
      			_xml.picture.@name = XML(picObj.entry).@name;       		
      			_xml.picture.@type = XML(picObj.entry).@type;
      		}
      	}
		
		// get resources		
		delete _xmlStructure.resources;

		var index:XML = CashManager.getIndex(fullID);
		if(index)
		{
			var resources:XMLList = index.resource.(hasOwnProperty('@category') && 
						(@category=='image' || @category=='database'));
		
			_xmlStructure.appendChild(<resources/>);

			for each (var res:XML in resources)
			{
				var resObj:Object = CashManager.getObject(fullID, res.@ID);
				var resData:ByteArray = ByteArray(resObj.data);
				var content:String = resData.readUTFBytes(resData.bytesAvailable);
				
				var resXML:XML = XML('<resource><![CDATA['+content+']]></resource>');
				resXML.@category = resObj.entry.@category;
				resXML.@ID = resObj.entry.@ID;
				resXML.@type = resObj.entry.@type;
				resXML.@name = resObj.entry.@name;
				
				_xmlStructure.resources.appendChild(resXML);
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function outputProgressHandler(event:OutputProgressEvent):void
	{
		var stream:FileStream = event.target as FileStream;
		if(event.bytesPending==0)	
			stream.dispatchEvent(new Event(Event.COMPLETE)); 
	}
	
	private function saveHandler(event:Event):void 
	{
		var stream:FileStream = event.target as FileStream;
		
		stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, outputProgressHandler);
		stream.removeEventListener(Event.COMPLETE, saveHandler);
		stream.removeEventListener(IOErrorEvent.IO_ERROR, saveErrorHandler);
				
    	try 
    	{
    		stream.close();
    		
    		ProgressManager.start(ProgressManager.DIALOG_MODE, false);
			
			_xml = XML(CashManager.getStringObject(fullID, 'template'));
			
	      	// update tpl UID
	   		var oldID:String = fullID;
	   		_fullID = null;
	   		CashManager.updateID(oldID, fullID);			
			
			ProgressManager.complete();
			
			modified = false;

			dispatchEvent( new Event(Event.COMPLETE) );
    	}
    	catch(e:Error)
    	{
    		ProgressManager.complete();
	
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
	
	private function openHandler(event:Event):void 
	{
		var stream:FileStream = event.target as FileStream;
		stream.removeEventListener(Event.COMPLETE, openHandler);
		stream.removeEventListener(IOErrorEvent.IO_ERROR, openErrorHandler);
		    	
    	try 
    	{
    		ProgressManager.start(ProgressManager.DIALOG_MODE, false);
    		 
    		var strData:String = stream.readUTFBytes(stream.bytesAvailable);
    		stream.close();
    		
    		var xmlData:XML = XML(strData);
    		
    		if(!isValidTpl(xmlData))
    			throw new Error(LanguageManager.sentences['msg_not_valid_tpl_file']);
			
			_xml = xmlData;
			
			_completelyOpened = false;
			
			_fullID = null;
			
			processOpened();
			
			ProgressManager.complete();

			modified = false;
			
			dispatchEvent( new Event(Event.COMPLETE) );
    	}
    	catch(e:Error)
    	{
			stream.close();

    		ProgressManager.complete();
	
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
	
	private function saveErrorHandler(event:IOErrorEvent):void
	{
		ProgressManager.complete();

		var stream:FileStream = event.target as FileStream;
		stream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, outputProgressHandler);
		stream.removeEventListener(Event.COMPLETE, saveHandler);
		stream.removeEventListener(IOErrorEvent.IO_ERROR, saveErrorHandler);
		file.cancel();
		stream.close();

		var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, true, event.text);
		 
		dispatchEvent(errEvent);
		
		if(!errEvent.isDefaultPrevented())
		{
			SuperAlert.show( 
				errEvent.text,
				LanguageManager.sentences['error']);
		}	
	}
		
	private function openErrorHandler(event:IOErrorEvent):void
	{
		ProgressManager.complete();

		var stream:FileStream = event.target as FileStream;
		stream.removeEventListener(Event.COMPLETE, openHandler);
		stream.removeEventListener(IOErrorEvent.IO_ERROR, openErrorHandler);		
		file.cancel();
		stream.close();

		var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, false, true, event.text);
		 
		dispatchEvent(errEvent);
		
		if(!errEvent.isDefaultPrevented())
		{
			SuperAlert.show( 
				errEvent.text,
				LanguageManager.sentences['error']);
		}	
	}

}
}
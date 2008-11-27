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
	public static var defaultCaptions:Object = {
	};
	
	public static const TYPE_APPLICATION:String = "application";
	public static const TYPE_MODULE:String = "module";
			
	public static var tplFilter:FileFilter = new FileFilter(
		StringUtil.substitute("{0} ({1})", LanguageManager.sentences['template'], "*.xml"), 
		"*.xml");
	
	public static var allFilter:FileFilter = new FileFilter(
		StringUtil.substitute("{0} ({1})", LanguageManager.sentences['all'], "*.*"), 
		"*.*");	

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
			
			if(_modified)
			{
				var mainIndex:XML = CashManager.getMainIndex();	
				CashManager.updateMainIndexEntry(mainIndex, ID, 'saved', 'false');
				CashManager.setMainIndex(mainIndex);
			}		
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
			_xmlStructure=value;		
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
    //  picturePath
    //----------------------------------
	
	private var _picture:File;
			
	[Bindable]
	public function set picture(value:File):void
	{
		if(_picture.nativePath!=value.nativePath)
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
	
	public function isValidTpl(xmlData:XML):Boolean
	{
		if(xmlData.name() != 'template')
			return false;
			
		if(!xmlData.hasOwnProperty('encoded') && !xmlData.hasOwnProperty('structure'))
			return false;
			
		return true;
	}
	
	public function save():void
	{
		if(!file)
		{
			browseForSave();
			return;
		}		
		
		ProgressManager.start(null, false);
		
      	// update tpl UID
   		var oldID:String = ID;
   		delete _xml.@ID;
   		CashManager.updateID(oldID, ID);

		// cash template
		_xml.structure = xmlStructure;
		CashManager.setStringObject(ID, 
			XML(
				"<resource " + 
				"category='template' " + 
				"ID='template' " + 
				"name='" + name + "' " + 
				"type='" + TYPE_APPLICATION + "' />"), 
			_xml);
			
		/// get resources from cash 
   		fromCash();
   		
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
			SuperAlert.show(
				LanguageManager.sentences['msg_file_not_exists'],
				LanguageManager.sentences['error']);
			
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
           	
           	if(!f.extension || f.extension.toLowerCase() != 'xml')            	
            	f = f.parent.resolvePath(f.name+'.xml');
            		            
            file = f;
         	
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
	
	public function setPictureFromFile():void
	{
		if(!picture || !picture.exists)
		{
			//throw new BasicError("Not valid filename");
			return;
		}
		
		var fileToBase64:FileToBase64 = new FileToBase64(picture.nativePath);
		fileToBase64.convert();						
		b64picture = fileToBase64.data.toString();
		
		_xml.picture[0].@type = file.extension;
		_xml.picture[0].@name = file.name;
		
		picture = null;
	}
	
	public function cash():void
	{
		for each (var res:XML in xmlStructure.resources.resource)
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
		
		delete xmlStructure.resources;

		if(b64picture)
		{
			var picXML:XML = _xml.picture[0];
			CashManager.setStringObject(ID, 
				XML(
					"<resource " + 
					"category='logo' " + 
					"ID='logo' " + 
					"name='" +		Utils.getStringOrDefault(picXML.@name, "") + "' " + 
					"type='" +		Utils.getStringOrDefault(picXML.@type, "") + "' />"), 
				b64picture);
				
			delete _xml.picture;
		}

		CashManager.setStringObject(ID, 
			XML(
				"<resource " + 
				"category='template' " + 
				"ID='template' " + 
				"name='" + name + "' " + 
				"type='" + TYPE_APPLICATION + "' />"), 
			_xml);
	}

	public function fromCash():void
	{
      	if(picture)
      		setPictureFromFile();
      	else
      	{
      		delete _xml.picture;
      		
      		var picObj:Object = CashManager.getObject(ID, 'logo');
      		if(picObj)
      		{
      			var picData:ByteArray = ByteArray(picObj.data);
      		
      			_xml.picture = picData.readUTFBytes(picData.bytesAvailable);
      			_xml.picture.@name = XML(picObj.entry).@name;       		
      			_xml.picture.@type = XML(picObj.entry).@type;
      		}
      	}
		
		var index:XML = CashManager.getIndex(ID);
		
		if(index)
		{
			var resources:XMLList = index.resource.(hasOwnProperty('@category') && (@category=='image' || @category=='database'));
		
			delete xmlStructure.resources;
			xmlStructure.appendChild(<resources/>);

			for each (var res:XML in resources)
			{
				var resObj:Object = CashManager.getObject(ID, res.@ID);
				var resData:ByteArray = ByteArray(resObj.data);
				var content:String = resData.readUTFBytes(resData.bytesAvailable);
				
				var resXML:XML = XML('<resource><![CDATA['+content+']]></resource>');
				resXML.@category = resObj.entry.@category;
				resXML.@ID = resObj.entry.@ID;
				resXML.@type = resObj.entry.@type;
				resXML.@name = resObj.entry.@name;
				
				xmlStructure.resources.appendChild(resXML);
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
			
			_xml = XML(CashManager.getStringObject(ID, 'template'));
			
			var mainIndex:XML = CashManager.getMainIndex();	
			CashManager.updateMainIndexEntry(mainIndex, ID, 'saved', 'true');
			CashManager.setMainIndex(mainIndex);
			
			modified = false;

			ProgressManager.complete();
			
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
			
			decode();
				
			if(xmlStructure)
				cash();
			
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
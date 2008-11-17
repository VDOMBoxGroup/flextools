package PowerPack.com.managers
{
	import ExtendedAPI.com.utils.Utils;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Decoder;	

public class CashManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 */
	private static var _instance:CashManager;
	
	public static var expirationPeriod:int = 24*7;// hours

	public static var cashFolder:File = File.applicationStorageDirectory.resolvePath('cash');

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():CashManager
	{
		if (!_instance)
		{
			_instance = new CashManager();
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():CashManager
	{
		return getInstance();
	}	

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function CashManager()
	{
		super();

		if (_instance)
			throw new Error("Instance already exists.");
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------		
		
	private var _initialized:Boolean;	 	 
	public static function get initialized():Boolean
	{
		return instance._initialized;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	private static function initialize():void
	{
		instance._initialized = false;
		
		if(!cashFolder.exists)
		{
			try {
				cashFolder.createDirectory();
				
				if(cashFolder.exists)
					instance._initialized = true;
			} 
			catch (e:*) {}			
		}
	}
	
	public static function getFolderName(ID:String):String
	{
		return ID.replace(/\W/g, '_');
	}
	
	public static function getFolderPath(ID:String):String
	{
		return cashFolder.resolvePath(getFolderName(ID)).nativePath;
	}

	//
	// Main index manipulation
	//
	
	/** 
	 * Main index has following structure:
	 * 	<index>
	 * 		<template ID='' folder='' creationDate='' lastUpdate='' lastRequest='' saved='' />
	 * 		...
	 */
	
	public static function getMainIndex():XML
	{
		var mainIndex:File = cashFolder.resolvePath('index.xml');
		var _xml:XML;
		var xml:XML = new XML(<index/>);				
		
		if(!mainIndex.exists)
			return xml;
		
		var indexStream:FileStream = new FileStream();
		
		try {
			indexStream.open(mainIndex, FileMode.READ);		
			_xml = XML(indexStream.readUTFBytes(indexStream.bytesAvailable));
			xml = _xml;
		} 
		catch(e:*) {}
		
		indexStream.close();
		
		return xml;
	}
	
	private static function setMainIndex(index:XML):void
	{		
		var mainIndex:File = cashFolder.resolvePath('index.xml');
		
		var indexStream:FileStream = new FileStream();
		
	  	indexStream.open(mainIndex, FileMode.WRITE);
		indexStream.writeUTFBytes(index.toXMLString());
		indexStream.close();
	}

	private static function addMainIndexEntry(index:XML, entryXML:XML):void
	{
		removeMainIndexEntry(index, entryXML.@ID);
		index.appendChild(entryXML);
	}

	private static function removeMainIndexEntry(index:XML, tplID:String):void
	{
		delete getMainIndexEntry(index, tplID);		
	}
	
	private static function updateMainIndexEntry(index:XML, tplID:String, attr:String, value:String):void
	{
		var entry:XML = getMainIndexEntry(index, tplID);
		
		if(entry)
			entry['@'+attr] = value;
	}
	
	private static function getMainIndexEntry(index:XML, tplID:String):XML
	{
		var entries:XMLList = index.template.(hasOwnProperty('@ID') && @ID == tplID);
		
		if(entries.length()>0)
			return entries[0];

		return null;
	}
	
	//
	// Template index manipulation
	//
	
	/** 
	 * Template index has following structure:
	 * 	<index ID='' folder=''>
	 * 		<resource category='' ID='' name='' type='' filename='' thumb='' lastUpdate='' lastRequest='' />
	 * 		...
	 */
	
	public static function getIndex(tplID:String, mainIndex:XML=null):XML
	{		
		
		var mIndex:XML = mainIndex ? mainIndex : getMainIndex();
		var entry:XML = getMainIndexEntry(mIndex, tplID);
		
		if(!entry)
			return null;		
		
		var tplDir:File = cashFolder.resolvePath(entry.@folder);
		
		if(!tplDir.exists)
		{
			removeMainIndexEntry(mIndex, tplID);
			setMainIndex(mIndex);
			return null;
		}		
		
		var index:File = tplDir.resolvePath('index.xml');
		var _xml:XML;
		var xml:XML = new XML(<index/>);
		xml.@ID = entry.@ID;				
		xml.@folder = entry.@folder;				
		
		if(!index.exists)
			return xml;
		
		
		var indexStream:FileStream = new FileStream();
		indexStream.open(index, FileMode.READ);		
		
		try {
			_xml = XML(indexStream.readUTFBytes(indexStream.bytesAvailable));
			xml = _xml;
		} catch(e:*) {}
		
		indexStream.close();
		
		return xml;
	}

	private static function setIndex(index:XML):void
	{
		var tplDir:File = cashFolder.resolvePath(index.@folder);		
		var indexFile:File = tplDir.resolvePath('index.xml');
		
		var indexStream:FileStream = new FileStream();

  		indexStream.open(indexFile, FileMode.WRITE);
		indexStream.writeUTFBytes(index.toXMLString());
		indexStream.close();		
	}
	
	private static function addIndexEntry(index:XML, entryXML:XML):void
	{
		removeIndexEntry(index, entryXML.@ID);
		index.appendChild(entryXML)
	}

	private static function removeIndexEntry(index:XML, objID:String):void
	{
		delete getIndexEntry(index, objID);	
	}
	
	private static function updateIndexEntry(index:XML, objID:String, attr:String, value:String):void
	{
		var entry:XML = getIndexEntry(index, objID);
		
		if(entry)
			entry['@' + attr] = value;
	}

	private static function getIndexEntry(index:XML, objID:String):XML
	{
		var entries:XMLList = index.resource.(hasOwnProperty('@ID') && @ID == objID);
		
		if(entries.length()>0)
			return entries[0];

		return null;
	}
		
	//
	// Cash resources manipulation
	//
	
	public static function now():Date
	{
		var localDate:Date = new Date();
		var offsetMilliseconds:Number = localDate.getTimezoneOffset() * 60 * 1000;
		localDate.setTime(localDate.getTime() + offsetMilliseconds);
		
		return localDate;
	}
	
	public static function clear():void
	{
		instance.onProgress(0, 100)
		
		var expirationDate:Date = now();
		var offsetMilliseconds:Number = expirationPeriod * 60 * 60 * 1000;
		expirationDate.setTime(expirationDate.getTime() - offsetMilliseconds);	
				
		initialize();

		var mainIndex:XML = getMainIndex();
		for each(var indexEntry:XML in mainIndex.template)
		{
			if( Number(Utils.getStringOrDefault(indexEntry.@lastRequest,'0')) <= expirationDate.getTime() )
				removeMainIndexEntry(mainIndex, indexEntry.@ID);
		}
		setMainIndex(mainIndex);
		
		var fileList:Array = CashManager.cashFolder.getDirectoryListing();
		for each(var file:File in fileList)
		{
			var isExpired:Boolean = true;
			for each(indexEntry in mainIndex.template)
			{
				if(file.name == indexEntry.@folder)
					isExpired = false;
			}
			
			if(isExpired && !file.isHidden)
			{
				try
				{	
					if(file.isDirectory)
						file.deleteDirectory(true);
					else if(file.name!='index.xml')
						file.deleteFile();
				} 
				catch(e:*) {}
			}
		}
		
		instance.onComplete("clearComplete");
	}
		
	public static function getObjectEntry(tplID:String, objID:String):XML
	{
		initialize();
		
		var mainIndex:XML = getMainIndex();
		var tplEntry:XML = getMainIndexEntry(mainIndex, tplID);
		
		if(!tplEntry)
			return null;		
		
		var index:XML = getIndex(tplID, mainIndex);
		
		if(!index)
			return null;		

		var entry:XML = getIndexEntry(index, objID);
		
		if(!entry)
			return null;
			
		return entry
	}

	public static function isObjectUpdated(tplID:String, objID:String, UTCDate:Number):Boolean
	{
		var entry:XML = getObjectEntry(tplID, objID);
		
		if(!entry)
			return false;
			
		if( Number(Utils.getStringOrDefault(entry.@lastUpdate,'0')) != UTCDate )
			return true;
			
		return false;		
	}
		
	/**
	 * 
	 * @param tplID
	 * @param objID
	 * @return	{entry:XML, data:ByteArray} 
	 * 
	 */
	public static function getObject(tplID:String, objID:String):Object 
	{		
		initialize();
		
		var mainIndex:XML = getMainIndex();
		var tplEntry:XML = getMainIndexEntry(mainIndex, tplID);
		
		if(!tplEntry)
			return null;		
		
		var index:XML = getIndex(tplID, mainIndex);
		
		if(!index)
			return null;		

		var entry:XML = getIndexEntry(index, objID);
		
		if(!entry)
			return null;		
		
		var tplDir:File = cashFolder.resolvePath(tplEntry.@folder);
		var objFile:File = tplDir.resolvePath(entry.@filename);
		
		if(!objFile.exists)
		{
			removeIndexEntry(index, objID);
			setIndex(index);
			return null;
		}
		
		// get data
		var dataStream:FileStream = new FileStream(); 

		//dataStream.addEventListener(Event.COMPLETE, onLoadData);
		dataStream.open(objFile, FileMode.READ);		
		
		var data:ByteArray;
		dataStream.readBytes(data);
		dataStream.close();
		
		updateIndexEntry(index, objID, 'lastRequest', now().getTime().toString());
		updateMainIndexEntry(mainIndex, tplID, 'lastRequest', now().getTime().toString());
		
		setIndex(index);
		setMainIndex(mainIndex);
		
		return { entry: entry, data: data };		
	}
	
	/**
	 * 
	 * @param tplID
	 * @param objEntry {category, ID, name, type}
	 * @param data
	 * @return 
	 * 
	 */
	public static function setObject(tplID:String, objEntry:XML, data:ByteArray):XML
	{
		initialize();		
		
		var mainIndex:XML = getMainIndex();				
		var tplEntry:XML = getMainIndexEntry(mainIndex, tplID);
		if(!tplEntry)
		{
			tplEntry = new XML(<template/>);
			tplEntry.@ID = tplID;
			tplEntry.@folder = getFolderName(tplID);
			tplEntry.@creationDate = now().getTime().toString();
			tplEntry.@lastUpdate = now().getTime().toString();
			tplEntry.@lastRequest = now().getTime().toString();
			
			addMainIndexEntry(mainIndex, tplEntry);
		}
		
		updateMainIndexEntry(mainIndex, tplID, 'lastUpdate', now().getTime().toString());
		updateMainIndexEntry(mainIndex, tplID, 'lastRequest', now().getTime().toString());
		
		//--------------------
		
		var tplDir:File = cashFolder.resolvePath(tplEntry.@folder);
		
		if(!tplDir.exists)
			tplDir.createDirectory();

		var index:XML = getIndex(tplID, mainIndex);
		if(!index)
			return null;					
		var entry:XML = getIndexEntry(index, objEntry.@ID);
		if(!entry)
		{
			entry = new XML(<resource/>);
			entry.@category = objEntry.@category; 
			entry.@ID = objEntry.@ID;
			entry.@name = objEntry.@name;
			entry.@type = objEntry.@type;
			entry.@lastUpdate = now().getTime().toString();
			entry.@lastRequest = now().getTime().toString();
			entry.@filename = String(objEntry.@ID).replace(/\W/g, '_');
			
			if(entry.@category == 'image')
				entry.@thumb = 'thumb_'+entry.@filename+'.png';
							
			addIndexEntry(index, entry);
		}
		
		updateIndexEntry(mainIndex, entry.@ID, 'lastUpdate', now().getTime().toString());
		updateIndexEntry(mainIndex, entry.@ID, 'lastRequest', now().getTime().toString());
		
		//---------------------
		
		try {
			var dataFile:File = tplDir.resolvePath(entry.@filename); 
        	var fileStream:FileStream = new FileStream();
			
			data.position = 0;
			
			fileStream.open(dataFile, FileMode.WRITE);
			fileStream.writeBytes(data);
			fileStream.close();
		
			instance.createThumb(entry, tplDir, data);
			
			setIndex(index);
			setMainIndex(mainIndex);
		} 
		catch(e:*) {
			return null;			
		}		
			
		return entry;
	}
	
	private function createThumb(entry:XML, folder:File, b64Data:ByteArray):void
	{
		if(entry.@category != 'image')
			return;
		
		try	{			
			b64Data.position = 0;
			
			var decoder:Base64Decoder = new Base64Decoder();
			decoder.decode( b64Data.readUTFBytes(b64Data.bytesAvailable) );
			var byteArray:ByteArray = decoder.flush();
			byteArray.position = 0;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderBytesLoaded );
			loader.loadBytes( byteArray );

		}
		catch (error:Error)	{
			return;
		}		
		
		function onLoaderBytesLoaded( event:Event ):void {
			try {
				var thumbSize:Object = {w:100, h:100};

				var content:DisplayObject = LoaderInfo( event.target ).content;
				var newW:Number = thumbSize.w * content.width/Math.max(content.width, content.height);
				var newH:Number = thumbSize.h * content.height/Math.max(content.width, content.height);

				var matrix:Matrix = new Matrix();
				matrix.scale(newW/content.width, newH/content.height);
				
				var bitmapData:BitmapData = new BitmapData( newW, newH, true, 0x00ffffff );
				bitmapData.draw( content, matrix );
					
				var pngEncoder:PNGEncoder = new PNGEncoder();
				var data:ByteArray = pngEncoder.encode(bitmapData);	
				data.position = 0;
	        
				var thumbFile:String = 'thumb_'+entry.@filename+'.png'; 
	        
	        	var file:File = folder.resolvePath(thumbFile); 
		        var fileStream:FileStream = new FileStream();

				fileStream.openAsync(file, FileMode.WRITE);
				fileStream.addEventListener(Event.COMPLETE, thumbCompleteHandler)
				fileStream.writeBytes(data);
			} 
			catch(e:*) {}
		}
		
		function thumbCompleteHandler(event:Event):void {
    		event.target.close();
		}		
	}
	
	public static function updateObject(tplID:String, objID:String, data:ByteArray):XML
	{
		initialize();		
		
		var mainIndex:XML = getMainIndex();
		var tplEntry:XML = getMainIndexEntry(mainIndex, tplID);
		if(!tplEntry)
			return null;

		var index:XML = getIndex(tplID, mainIndex);
		if(!index)
			return null;

		var entry:XML = getIndexEntry(index, objID);
		if(!entry)
			return null;

		return setObject(tplID, entry, data);
	}

	    	
	private function onComplete(eventType:String):void
	{
		dispatchEvent(new Event(Event.COMPLETE));
		if(eventType)
			dispatchEvent(new Event(eventType));
	}	

	private function onProgress(current:Number, total:Number):void
	{
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, current, total));
	}
	
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
	
}
}
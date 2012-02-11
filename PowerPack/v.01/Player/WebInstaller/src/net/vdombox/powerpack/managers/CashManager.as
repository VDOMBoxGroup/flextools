package net.vdombox.powerpack.managers
{

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
import flash.utils.ByteArray;

import mx.graphics.codec.PNGEncoder;
import mx.utils.Base64Decoder;

import net.vdombox.powerpack.lib.extendedapi.utils.Utils;

public class CashManager extends EventDispatcher
{

	/**
	 * Resource categories:
	 * 1. template
	 *	 a) application
	 *	 b) module
	 * 3. image
	 *	 a) png, bmp, jpg...
	 * 4. database
	 *	 a) sqlite
	 *	 b) xml
	 * 5. logo
	 *	 a) png, bmp, jpg...
	 */

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

	public static var typeCategoryMap : Object = {
		png : 'image',
		gif : 'image',
		jpg : 'image',
		bmp : 'image',
		sqlite : 'database',
		xml : 'database'
	}

	/**
	 *  @private
	 */
	private static var _instance : CashManager;

	public static var expirationPeriod : int = 24 * 7;// hours

	public static var cashFolder : File = File.applicationStorageDirectory.resolvePath( 'cash' );

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance() : CashManager
	{
		if ( !_instance )
		{
			_instance = new CashManager();
		}

		return _instance;
	}

	/**
	 *  @private
	 */
	public static function get instance() : CashManager
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

		if ( _instance )
			throw new Error( "Instance already exists." );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------		

	private var _initialized : Boolean;
	public static function get initialized() : Boolean
	{
		return instance._initialized;
	}

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	private static function initialize() : void
	{
		instance._initialized = false;

		if ( !cashFolder.exists )
		{
			try
			{
				cashFolder.createDirectory();

				if ( cashFolder.exists )
					instance._initialized = true;
			}
			catch ( e : * )
			{
			}
		}
	}

	public static function getFolderName( ID : String ) : String
	{
		return ID.replace( /\W/g, '_' );
	}

	public static function getFolderPath( ID : String ) : String
	{
		return cashFolder.resolvePath( getFolderName( ID ) ).nativePath;
	}

	//
	// Main index manipulation
	//

	/**
	 * Main index has following structure:
	 *	 <index>
	 *		 <instance ID='' folder='' creationDate='' lastUpdate='' lastRequest='' saved='' />
	 *		 ...
	 */

	public static function getMainIndex() : XML
	{
		var mainIndex : File = cashFolder.resolvePath( 'index.xml' );
		var _xml : XML;
		var xml : XML = new XML( <index/> );

		if ( !mainIndex.exists )
			return xml;

		var indexStream : FileStream = new FileStream();

		try
		{
			indexStream.open( mainIndex, FileMode.READ );
			_xml = XML( indexStream.readUTFBytes( indexStream.bytesAvailable ) );
			xml = _xml;
		}
		catch ( e : * )
		{
		}

		indexStream.close();

		return xml;
	}

	public static function setMainIndex( index : XML ) : void
	{
		var mainIndex : File = cashFolder.resolvePath( 'index.xml' );

		var indexStream : FileStream = new FileStream();

		indexStream.open( mainIndex, FileMode.WRITE );
		indexStream.writeUTFBytes( index.toXMLString() );
		indexStream.close();
	}

	public static function addMainIndexEntry( index : XML, entryXML : XML ) : void
	{
		removeMainIndexEntry( index, entryXML.@ID );
		index.appendChild( entryXML );
	}

	public static function removeMainIndexEntry( index : XML, ID : String ) : void
	{
		delete getMainIndexEntry( index, ID );
	}

	public static function updateMainIndexEntry( index : XML, ID : String, attr : String, value : String ) : void
	{
		var entry : XML = getMainIndexEntry( index, ID );

		if ( entry )
			entry['@' + attr] = value;
	}

	public static function getMainIndexEntry( index : XML, ID : String ) : XML
	{
		var entries : XMLList = index.instance.(hasOwnProperty( '@ID' ) && @ID == ID);

		if ( entries.length() > 0 )
			return entries[0];

		return null;
	}

	//
	// Instance index manipulation
	//

	/**
	 * Instance index has following structure:
	 *	 <index ID='' folder=''>
	 *		 <resource category='' ID='' name='' type='' filename='' thumb='' lastUpdate='' lastRequest='' deleted=''/>
	 *		 ...
	 */

	public static function getIndex( ID : String, mainIndex : XML = null ) : XML
	{

		var mIndex : XML = mainIndex ? mainIndex : getMainIndex();
		var entry : XML = getMainIndexEntry( mIndex, ID );

		if ( !entry )
			return null;

		var folder : File = cashFolder.resolvePath( entry.@folder );

		if ( !folder.exists )
		{
			removeMainIndexEntry( mIndex, ID );
			setMainIndex( mIndex );
			return null;
		}

		var index : File = folder.resolvePath( 'index.xml' );
		var _xml : XML;
		var xml : XML = new XML( <index/> );
		xml.@ID = entry.@ID;
		xml.@folder = entry.@folder;

		if ( !index.exists )
			return xml;

		var indexStream : FileStream = new FileStream();
		indexStream.open( index, FileMode.READ );

		try
		{
			_xml = XML( indexStream.readUTFBytes( indexStream.bytesAvailable ) );
			xml = _xml;
		}
		catch ( e : * )
		{
		}

		indexStream.close();

		return xml;
	}

	public static function setIndex( index : XML ) : void
	{
		var folder : File = cashFolder.resolvePath( index.@folder );
		var indexFile : File = folder.resolvePath( 'index.xml' );

		var indexStream : FileStream = new FileStream();

		indexStream.open( indexFile, FileMode.WRITE );
		indexStream.writeUTFBytes( index.toXMLString() );
		indexStream.close();
	}

	public static function addIndexEntry( index : XML, entryXML : XML ) : void
	{
		removeIndexEntry( index, entryXML.@ID );
		index.appendChild( entryXML )
	}

	public static function removeIndexEntry( index : XML, objID : String ) : void
	{
		delete getIndexEntry( index, objID );
	}

	public static function updateIndexEntry( index : XML, objID : String, attr : String, value : String ) : void
	{
		var entry : XML = getIndexEntry( index, objID );

		if ( entry )
			entry['@' + attr] = value;
	}

	public static function getIndexEntry( index : XML, objID : String ) : XML
	{
		var entries : XMLList = index.resource.(hasOwnProperty( '@ID' ) && @ID == objID);

		if ( entries.length() > 0 )
			return entries[0];

		return null;
	}

	//
	// Cash resources manipulation
	//

	public static function UTCNow() : Date
	{
		var localDate : Date = new Date();
		var offsetMilliseconds : Number = localDate.getTimezoneOffset() * 60 * 1000;
		localDate.setTime( localDate.getTime() + offsetMilliseconds );

		return localDate;
	}

	public static function clear( ...args ) : void
	{
		instance.onProgress( 0, 100 )
		initialize();

		var expirationDate : Date = UTCNow();
		var offsetMilliseconds : Number = expirationPeriod * 60 * 60 * 1000;
		expirationDate.setTime( expirationDate.getTime() - offsetMilliseconds );

		var mainIndex : XML = getMainIndex();

		if ( !args || args.length == 0 )
		{
			for each( var indexEntry : XML in mainIndex.instance )
			{
				if ( Number( Utils.getStringOrDefault( indexEntry.@lastRequest, '0' ) ) <= expirationDate.getTime() )
					removeMainIndexEntry( mainIndex, indexEntry.@ID );
			}
		}
		else
		{
			for each( var ID : String in args )
			{
				removeMainIndexEntry( mainIndex, ID );
			}
		}

		setMainIndex( mainIndex );

		var fileList : Array = CashManager.cashFolder.getDirectoryListing();
		for each( var file : File in fileList )
		{
			var isExpired : Boolean = true;
			for each( indexEntry in mainIndex.instance )
			{
				if ( file.name == indexEntry.@folder )
					isExpired = false;
			}

			if ( isExpired && !file.isHidden )
			{
				try
				{
					if ( file.isDirectory )
						file.deleteDirectory( true );
					else if ( file.name != 'index.xml' )
						file.deleteFile();
				}
				catch ( e : * )
				{
				}
			}
		}

		instance.onComplete( "clearComplete" );
	}

	public static function exists( ID : String ) : Boolean
	{
		initialize();

		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );

		return (entry != null ? true : false);
	}

	public static function objectExists( ID : String, objID : String ) : Boolean
	{
		var entry : XML = getObjectEntry( ID, objID );

		return (entry != null ? true : false)
	}

	public static function getFolder( ID : String ) : File
	{
		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );

		if ( !entry )
			return null;

		var folder : File = cashFolder.resolvePath( entry.@folder );
		return folder;
	}

	public static function getObjectEntry( ID : String, objID : String ) : XML
	{
		initialize();

		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );

		if ( !entry )
			return null;

		var index : XML = getIndex( ID, mainIndex );

		if ( !index )
			return null;

		var objEntry : XML = getIndexEntry( index, objID );

		if ( !objEntry )
			return null;

		return objEntry;
	}

	public static function objectUpdated( ID : String, objID : String, UTCDate : Number ) : Boolean
	{
		var entry : XML = getObjectEntry( ID, objID );

		if ( !entry )
			return false;

		if ( Number( Utils.getStringOrDefault( entry.@lastUpdate, '0' ) ) != UTCDate )
			return true;

		return false;
	}

	public static function getStringObject( ID : String, objID : String ) : String
	{
		var resObj : Object = CashManager.getObject( ID, objID );
		var resData : ByteArray = ByteArray( resObj.data );
		var content : String = resData.readUTFBytes( resData.bytesAvailable );

		return content;
	}

	/**
	 *
	 * @param ID
	 * @param objID
	 * @return	{entry:XML, data:ByteArray}
	 *
	 */
	public static function getObject( ID : String, objID : String ) : Object
	{
		initialize();

		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );

		if ( !entry )
			return null;

		var index : XML = getIndex( ID, mainIndex );

		if ( !index )
			return null;

		var objEntry : XML = getIndexEntry( index, objID );

		if ( !objEntry )
			return null;

		var folder : File = cashFolder.resolvePath( entry.@folder );
		var objFile : File = folder.resolvePath( objEntry.@filename );

		if ( !objFile.exists )
		{
			removeIndexEntry( index, objID );
			setIndex( index );
			return null;
		}

		// get data
		var dataStream : FileStream = new FileStream();

		//dataStream.addEventListener(Event.COMPLETE, onLoadData);
		dataStream.open( objFile, FileMode.READ );

		var data : ByteArray = new ByteArray();
		dataStream.readBytes( data, 0, dataStream.bytesAvailable );
		data.position = 0;
		dataStream.close();

		updateIndexEntry( index, objID, 'lastRequest', UTCNow().getTime().toString() );
		updateMainIndexEntry( mainIndex, ID, 'lastRequest', UTCNow().getTime().toString() );

		setIndex( index );
		setMainIndex( mainIndex );

		return { entry : objEntry, data : data };
	}

	public static function setStringObject( ID : String, objEntry : XML, strData : String ) : XML
	{
		var data : ByteArray = new ByteArray();
		data.writeUTFBytes( strData );
		data.position = 0;

		return setObject( ID, objEntry, data );
	}

	/**
	 *
	 * @param ID
	 * @param objEntry {category, ID, name, type}
	 * @param data
	 * @return
			*
	 */
	public static function setObject( ID : String, objEntry : XML, data : ByteArray ) : XML
	{
		initialize();

		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );
		if ( !entry )
		{
			entry = new XML( <instance/> );
			entry.@ID = ID;
			entry.@folder = getFolderName( ID );
			entry.@creationDate = UTCNow().getTime().toString();
			entry.@lastUpdate = UTCNow().getTime().toString();
			entry.@lastRequest = UTCNow().getTime().toString();

			addMainIndexEntry( mainIndex, entry );
		}

		updateMainIndexEntry( mainIndex, ID, 'lastUpdate', UTCNow().getTime().toString() );
		updateMainIndexEntry( mainIndex, ID, 'lastRequest', UTCNow().getTime().toString() );

		//--------------------

		var folder : File = cashFolder.resolvePath( entry.@folder );

		if ( !folder.exists )
			folder.createDirectory();

		var index : XML = getIndex( ID, mainIndex );
		if ( !index )
			return null;
		var newEntry : XML = getIndexEntry( index, objEntry.@ID );
		if ( !newEntry )
		{
			newEntry = new XML( <resource/> );
			newEntry.@category = objEntry.@category;
			newEntry.@ID = objEntry.@ID;
			newEntry.@name = objEntry.@name;
			newEntry.@type = objEntry.@type;
			newEntry.@lastUpdate = UTCNow().getTime().toString();
			newEntry.@lastRequest = UTCNow().getTime().toString();
			newEntry.@filename = String( objEntry.@ID ).replace( /\W/g, '_' );

			if ( newEntry.@category == 'image' || newEntry.@category == 'logo' )
				newEntry.@thumb = 'thumb_' + newEntry.@filename + '.png';

			addIndexEntry( index, newEntry );
		}

		updateIndexEntry( mainIndex, newEntry.@ID, 'lastUpdate', UTCNow().getTime().toString() );
		updateIndexEntry( mainIndex, newEntry.@ID, 'lastRequest', UTCNow().getTime().toString() );

		//---------------------

		try
		{
			var dataFile : File = folder.resolvePath( newEntry.@filename );
			var fileStream : FileStream = new FileStream();

			data.position = 0;

			fileStream.open( dataFile, FileMode.WRITE );
			fileStream.writeBytes( data );
			fileStream.close();

			instance.createThumb( newEntry, folder, data );

			setIndex( index );
			setMainIndex( mainIndex );
		}
		catch ( e : * )
		{
			return null;
		}

		return newEntry;
	}

	private function createThumb( entry : XML, folder : File, b64Data : ByteArray ) : void
	{
		if ( entry.@category != 'image' &&
				entry.@category != 'logo' )
			return;

		try
		{
			b64Data.position = 0;

			var decoder : Base64Decoder = new Base64Decoder();
			decoder.decode( b64Data.readUTFBytes( b64Data.bytesAvailable ) );
			var byteArray : ByteArray = decoder.flush();
			byteArray.position = 0;

			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderBytesLoaded );
			loader.loadBytes( byteArray );

		}
		catch ( error : Error )
		{
			return;
		}

		function onLoaderBytesLoaded( event : Event ) : void
		{
			try
			{
				var thumbSize : Object = {w : 100, h : 100};

				var content : DisplayObject = LoaderInfo( event.target ).content;
				var newW : Number = thumbSize.w * content.width / Math.max( content.width, content.height );
				var newH : Number = thumbSize.h * content.height / Math.max( content.width, content.height );

				var matrix : Matrix = new Matrix();
				matrix.scale( newW / content.width, newH / content.height );

				var bitmapData : BitmapData = new BitmapData( newW, newH, true, 0x00ffffff );
				bitmapData.draw( content, matrix );

				var pngEncoder : PNGEncoder = new PNGEncoder();
				var data : ByteArray = pngEncoder.encode( bitmapData );
				data.position = 0;

				var thumbFile : String = 'thumb_' + entry.@filename + '.png';

				var file : File = folder.resolvePath( thumbFile );
				var fileStream : FileStream = new FileStream();

				fileStream.openAsync( file, FileMode.WRITE );
				fileStream.addEventListener( Event.COMPLETE, thumbCompleteHandler )
				fileStream.writeBytes( data );
			}
			catch ( e : * )
			{
			}
		}

		function thumbCompleteHandler( event : Event ) : void
		{
			event.target.close();
			instance.onComplete( "thumbComplete" );
		}
	}

	public static function updateID( ID : String, newID : String ) : void
	{
		initialize();

		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );
		if ( !entry )
			return;

		var index : XML = getIndex( ID, mainIndex );
		if ( !index )
			return;

		index.@ID = newID;
		index.@folder = getFolderName( newID );

		var folder : File = getFolder( ID );
		var newFolder : File = folder.parent.resolvePath( index.@folder );

		updateMainIndexEntry( mainIndex, ID, 'folder', index.@folder );
		updateMainIndexEntry( mainIndex, ID, 'ID', newID );

		try
		{
			folder.moveTo( newFolder, true );
		}
		catch ( e : * )
		{
		}

		setIndex( index );
		setMainIndex( mainIndex );
	}

	public static function updateObject( ID : String, objID : String, data : ByteArray ) : XML
	{
		initialize();

		var mainIndex : XML = getMainIndex();
		var entry : XML = getMainIndexEntry( mainIndex, ID );
		if ( !entry )
			return null;

		var index : XML = getIndex( ID, mainIndex );
		if ( !index )
			return null;

		var objEntry : XML = getIndexEntry( index, objID );
		if ( !objEntry )
			return null;

		return setObject( ID, objEntry, data );
	}

	private function onComplete( eventType : String ) : void
	{
		dispatchEvent( new Event( Event.COMPLETE ) );
		if ( eventType )
			dispatchEvent( new Event( eventType ) );
	}

	private function onProgress( current : Number, total : Number ) : void
	{
		dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, current, total ) );
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

}
}
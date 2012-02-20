package net.vdombox.powerpack.lib.player
{

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
//import flash.events.OutputProgressEvent;
//import flash.filesystem.File;
//import flash.filesystem.FileMode;
//import flash.filesystem.FileStream;
import flash.net.FileFilter;
import flash.utils.ByteArray;

import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;
import mx.utils.StringUtil;
import mx.utils.UIDUtil;

//import net.vdombox.powerpack.lib.extendedapi.utils.FileToBase64;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
//import net.vdombox.powerpack.managers.CashManager;
import net.vdombox.powerpack.lib.player.managers.ContextManager;
import net.vdombox.powerpack.lib.player.managers.LanguageManager;
import net.vdombox.powerpack.lib.player.popup.AlertPopup;
import net.vdombox.powerpack.lib.player.utils.CryptUtils;

/**
 *
 *	<template ID=''>
 *		 <name/>
 *		 <description/>
 *		 <picture/>
 *		 <encoded> or <structure>
 *			 <graph name='' initial='' category=''>
 *				 <states>
 *					 <state name='' type='' category='' enabled='' breakpoint='' x='' y=''>
 *						 <text/>
 *					 </state>
 *					 ...
 *				 </states>
 *
 *				 <transitions>
 *					 <transition name='' highlighted='' enabled='' source='' destination=''>
 *						 <label/>
 *					 </transition>
 *					 ...
 *				 </transitions>
 *			 </graph>
 *			 ...
 *			<categories>
 *				<category name=''/>
 *				...
 *			</categories>
 *
 *			<resources>
 *				<resource category='' ID='' type='' name=''/>
 *				...
 *			</resources>
 *		 </encoded> or </structure>
 *	 </template>
 *
 */

public class Template extends EventDispatcher
{
	private static const BROWSE_TYPE_OPEN : String = "browseForOpen";
	private static const BROWSE_TYPE_SAVE : String = "browseForSave";
	private static const BROWSE_TYPE_NONE : String = "browseNone";
	
	private var browseType : String = BROWSE_TYPE_NONE;
	
	public static const TYPE_APPLICATION : String = "application";
	public static const TYPE_MODULE : String = "module";

	public static const TPL_EXTENSION : String = 'xml';

	public static var tplFilter : FileFilter = new FileFilter(
			StringUtil.substitute( "{0} ({1})", LanguageManager.sentences['template'], "*." + TPL_EXTENSION ),
			"*." + TPL_EXTENSION );

	public static var allFilter : FileFilter = new FileFilter(
			StringUtil.substitute( "{0} ({1})", LanguageManager.sentences['all'], "*.*" ),
			"*.*" );

	public static var defaultCaptions : Object = {
	};

	private static var _classConstructed : Boolean = classConstruct();
	
//	private var fileStream : FileStream = new FileStream();

	
	public static function get classConstructed() : Boolean
	{
		return _classConstructed;
	}

	// Define a static method.
	private static function classConstruct() : Boolean
	{
		LanguageManager.setSentences( defaultCaptions );

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
	public function Template( xml : XML = null )
	{
		_xml = new XML( <template/> );
		_xml.@ID = UIDUtil.createUID();

		if ( xml && isValidTpl( xml ) )
		{
			_xml = xml.copy();
			if ( !Utils.getStringOrDefault( _xml.@ID, '' ) )
				_xml.@ID = UIDUtil.createUID();

			processOpened();
			return;
		}
		else if ( !xml )
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
//	public function dispose() : void
//	{
//		_xmlStructure = null;
//		_pictureFile = null;
//		file = null;
//		_xml = null;
//	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	[Bindable]
	public var key : String;

	/**
	 *
	 * template file (XML)
	 */
//	[Bindable]
//	public var file : File;

	private var _completelyOpened : Boolean;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  modified
	//----------------------------------

	private var _modified : Boolean;

	public function set modified( value : Boolean ) : void
	{
		if ( _modified != value )
		{
			_modified = value;

//			var mainIndex : XML = CashManager.getMainIndex();
//
//			CashManager.updateMainIndexEntry( mainIndex, fullID, 'saved', _modified ? 'false' : 'true' );
//			CashManager.setMainIndex( mainIndex );
		}
	}

	[Bindable]
	public function get modified() : Boolean
	{
		return _modified;
	}

	//----------------------------------
	//  xml
	//----------------------------------

	private var _xml : XML;

	public function get xml() : XML
	{
		return _xml;
	}

	//----------------------------------
	//  xmlStructure
	//----------------------------------

	private var _xmlStructure : XML;

//	public function set xmlStructure( value : XML ) : void
//	{
//		if ( _xmlStructure != value )
//		{
//			modified = true;
//			_xmlStructure = value;
//		}
//	}

	[Bindable]
	public function get xmlStructure() : XML
	{
		return _xmlStructure;
	}

	//----------------------------------
	//  name
	//----------------------------------

	public static const DEFAULT_NAME			: String = 'installer';
	public static const DEFAULT_INSTALLER_ID	: String = 'installer';
//	public static const DEFAULT_OUTPUT_FOLDER		: String = File.documentsDirectory.nativePath;
	public static const DEFAULT_OUTPUT_FILE_NAME	: String = "appInstaller";
	public static const DEFAULT_APP_PATH			: String = "";
	
	
//	public function set installerId( value : String ) : void
//	{
//		if (!value)
//			value = DEFAULT_INSTALLER_ID;
//
//		if ( _xml.id != value )
//		{
//			modified = true;
//			_xml.id = value;
//		}
//	}
	
	[Bindable]
	public function get installerId() : String
	{
		return Utils.getStringOrDefault( _xml.id, DEFAULT_INSTALLER_ID );
	}
	
//	public function set installerAppPath( value : String ) : void
//	{
//		if (!value)
//			value = DEFAULT_APP_PATH;
//
//		if ( _xml.appPath != value )
//		{
//			modified = true;
//			_xml.appPath = value;
//		}
//	}
	
	[Bindable]
	public function get installerAppPath() : String
	{
		return Utils.getStringOrDefault( _xml.appPath, DEFAULT_APP_PATH );
	}
	
//	public function set installerFolderPath( value : String ) : void
//	{
////		if (!value)
////			value = DEFAULT_OUTPUT_FOLDER;
////
//		if ( _xml.outputFolder != value )
//		{
//			modified = true;
//			_xml.outputFolder = value;
//		}
//	}
	
	[Bindable]
	public function get installerFolderPath() : String
	{
//		return Utils.getStringOrDefault( _xml.outputFolder, DEFAULT_OUTPUT_FOLDER );
		return Utils.getStringOrDefault( _xml.outputFolder, "")
	}
	
//	public function set installerFileName( value : String ) : void
//	{
//		if (!value)
//			value = DEFAULT_OUTPUT_FILE_NAME;
//
//		if ( _xml.outputFileName != value )
//		{
//			modified = true;
//			_xml.outputFileName = value;
//		}
//	}
	
	[Bindable]
	public function get installerFileName() : String
	{
		return Utils.getStringOrDefault( _xml.outputFileName, DEFAULT_OUTPUT_FILE_NAME );
	}

	public function set name( value : String ) : void
	{
		if (!value)
			value = DEFAULT_NAME;
		
		if ( _xml.name != value )
		{
			modified = true;
			_xml.name = value;
		}
	}

	[Bindable]
	public function get name() : String
	{
		return Utils.getStringOrDefault( _xml.name, DEFAULT_NAME );
	}

	//----------------------------------
	//  description
	//----------------------------------

//	public function set description( value : String ) : void
//	{
//		if ( _xml.description != value )
//		{
//			modified = true;
//			_xml.description = value;
//		}
//	}

	[Bindable]
	public function get description() : String
	{
		return Utils.getStringOrDefault( _xml.description, '' );
	}

	//----------------------------------
	//  ID
	//----------------------------------

	public function set ID( value : String ) : void
	{
		if ( _xml.@ID != value )
		{
			modified = true;
			_xml.@ID = value;
		}
	}

	[Bindable]
	public function get ID() : String
	{
		if ( !_xml.hasOwnProperty( '@ID' ) )
			_xml.@ID = UIDUtil.createUID();

		return _xml.@ID;
	}

	//----------------------------------
	//  fullID
	//----------------------------------

//	private var _fullID : String;

//	public function get fullID() : String
//	{
//		if ( !_fullID )
//		{
//			_fullID = ID;
//
////			if ( file && file.exists )
////				_fullID += '_' + file.creationDate.getTime() + '_' + file.modificationDate.getTime() + '_' + file.size;
//		}
//
//		return _fullID;
//	}

	//----------------------------------
	//  picture
	//----------------------------------

//	private var _pictureFile : File;

//	public function set pictureFile( value : File ) : void
//	{
//		if ( !value || !_pictureFile || _pictureFile.nativePath != value.nativePath )
//		{
//			modified = true;
//			_pictureFile = value;
//		}
//	}

//	[Bindable]
//	public function get pictureFile() : File
//	{
//		return _pictureFile;
//	}

	//----------------------------------
	//  b64picture
	//----------------------------------

//	public function set b64picture( value : String ) : void
//	{
//		if ( _xml.picture[0] != value )
//		{
//			modified = true;
//			if (value)
//				_xml.picture = value;
//			else
//				delete _xml.picture;
//		}
//	}

	[Bindable]
	public function get b64picture() : String
	{
		return Utils.getStringOrDefault( _xml.picture[0], '' );
	}
	
	//----------------------------------
	//  isEncoded
	//----------------------------------

	public function get isEncoded() : Boolean
	{
		return _xml.hasOwnProperty( 'encoded' );
	}

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	private function isValidTpl( xmlData : XML ) : Boolean
	{
		if ( xmlData.name() != 'template' )
			return false;

		if ( !xmlData.hasOwnProperty( 'encoded' ) && !xmlData.hasOwnProperty( 'structure' ) )
			return false;

		return true;
	}

//	public function save() : void
//	{
//		if ( !_completelyOpened )
//			return;
//
//		if ( !file )
//		{
//			browseForSave();
//			return;
//		}

//		try
//		{
//			//ProgressManager.start( null, false );
//
//			// update tpl UID
//			_xml.@ID = UIDUtil.createUID();
//
//			// cash template structure
//			cashStructure();
//
//			/// get resources from cash 
//			fillFromCash();
//
//			// set (+encrypt) structure and resources data
//			encode();
//
//			ProgressManager.source = fileStream;
//			ProgressManager.start();
//
//			fileStream.addEventListener( Event.COMPLETE, saveHandler );
//			fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
//			fileStream.addEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
//			
//			fileStream.openAsync( file, FileMode.WRITE );
//			fileStream.writeUTFBytes( _xml.toXMLString() );
//		}
//		catch ( e : Error )
//		{
//			fileStream.removeEventListener( Event.COMPLETE, saveHandler );
//			fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
//			fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
//			
//			file.cancel();
//			fileStream.close();
//			
//			ProgressManager.complete();
//			
//			showError(e.message);
//		}
//	}

	public function open() : void
	{
//		if ( !file )
//		{
//			browseForOpen();
//			return;
//		}
//
//		if ( !file.exists )
//		{
//			showError(LanguageManager.sentences['msg_file_not_exists']);
//			return;
//		}
//		
//		ProgressManager.source = fileStream;
//		ProgressManager.start();
//
//		fileStream.addEventListener( Event.COMPLETE, openHandler );
//		fileStream.addEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
//		
//		fileStream.openAsync( file, FileMode.READ );
	}

	public function browseForSave() : void
	{
//		var folder : File = ContextManager.instance.lastDir;
//
//		folder.addEventListener( Event.SELECT, fileBrowseHandler );
//		
//		browseType = BROWSE_TYPE_SAVE;
//		folder.browseForSave( LanguageManager.sentences['save_file'] );
	}

	public function browseForOpen() : void
	{
//		var folder : File = ContextManager.instance.lastDir;
//
//		folder.addEventListener( Event.SELECT, fileBrowseHandler );
//		
//		browseType = BROWSE_TYPE_OPEN;
//		folder.browseForOpen( LanguageManager.sentences['open_file'], [tplFilter, allFilter] )
	}
	
	public function processOpened() : void
	{
		if ( !_xml.hasOwnProperty( 'encoded' ) && !_xml.hasOwnProperty( 'structure' ) )
			return;

		decode();

//		if ( _xmlStructure )
//			cash();

		if ( !isEncoded )
			_completelyOpened = true;
	}

	private function encode() : void
	{
		delete _xml.encoded;
		delete _xml.structure;

		var structData : XML = _xmlStructure ? _xmlStructure : new XML( <structure/> );

		if ( key )
		{
			var bytes : ByteArray = CryptUtils.encrypt( structData.toXMLString(), key );

			var encoder : Base64Encoder = new Base64Encoder();
			
			encoder.encodeBytes( bytes );
			
			_xml.encoded = encoder.flush();
		}
		else
			_xml.structure = structData;
	}

	public function decode() : void
	{
		_xmlStructure = null;

		if ( isEncoded && _xml.hasOwnProperty( 'structure' ) )
			delete _xml.structure;

		if ( isEncoded && key )
		{
			try
			{
				var strEncoded : String = XML( _xml.encoded[0] ).toString();
				var strDecoded : String;

				var decoder : Base64Decoder = new Base64Decoder();
				decoder.decode( strEncoded );
				
				var bytes : ByteArray = decoder.flush();

				bytes = CryptUtils.decrypt( bytes, key );
				bytes.position = 0;
				
				strDecoded = bytes.readUTFBytes( bytes.length );
				
				_xmlStructure = XML( strDecoded );

				if ( _xmlStructure )
				{
					if ( _xmlStructure.name().localName == 'structure' )
						delete _xml.encoded;
					else
						_xmlStructure = null;
				}
			}
			catch ( e : * )
			{
				_xmlStructure = null;
			}
		}
		else if ( _xml.hasOwnProperty( 'structure' ) )
		{
			_xmlStructure = _xml.structure[0];
			delete _xml.structure;
		}
	}

//	private function setPictureFromFile() : Boolean
//	{
//		if ( !pictureFile || !pictureFile.exists )
//		{
//			return false;
//		}
//
//		var fileToBase64 : FileToBase64 = new FileToBase64( pictureFile.nativePath );
//		fileToBase64.convert();
//		b64picture = fileToBase64.data.toString();
//
//		_xml.picture[0].@type = pictureFile.extension;
//		_xml.picture[0].@name = pictureFile.name;
//
//		return true;
//	}

//	private function getPictureFromCash() : void
//	{
//		var picObj : Object = CashManager.getObject( fullID, 'logo' );
//		if ( picObj )
//		{
//			var picData : ByteArray = ByteArray( picObj.data );
//
//			_xml.picture = picData.readUTFBytes( picData.bytesAvailable );
//			_xml.picture.@name = XML( picObj.entry ).@name;
//			_xml.picture.@type = XML( picObj.entry ).@type;
//		}
//	}

//	private function cash() : Boolean
//	{
//		if ( _xmlStructure == null )
//			return false;

		// cash all resources
//		for each ( var res : XML in _xmlStructure.resources.resource )
//		{
//			CashManager.setStringObject( fullID,
//					XML(
//							"<resource " +
//									"category='" + Utils.getStringOrDefault( res.@category, "" ) + "' " +
//									"ID='" + Utils.getStringOrDefault( res.@ID, "" ) + "' " +
//									"name='" + Utils.getStringOrDefault( res.@name, "" ) + "' " +
//									"type='" + Utils.getStringOrDefault( res.@type, "" ) + "' />" ),
//					res );
//		}

//		delete _xmlStructure.resources;

		// cash tpl picture
//		if ( b64picture )
//		{
//			var picXML : XML = _xml.picture[0];
//			CashManager.setStringObject( fullID,
//					XML(
//							"<resource " +
//									"category='logo' " +
//									"ID='logo' " +
//									"name='" + Utils.getStringOrDefault( picXML.@name, "" ) + "' " +
//									"type='" + Utils.getStringOrDefault( picXML.@type, "" ) + "' />" ),
//					b64picture );
//
//			//delete _xml.picture;
//		}

//		cashStructure();
//
//		return true;
//	}

//	private function cashStructure() : void
//	{
//		CashManager.setStringObject( fullID,
//				XML(
//						"<resource " +
//								"category='template' " +
//								"ID='template' " +
//								"name='" + name + "' " +
//								"type='" + TYPE_APPLICATION + "' />" ),
//				_xml.toXMLString() );
//
//		CashManager.setStringObject( fullID,
//				XML(
//						"<resource " +
//								"category='template' " +
//								"ID='structure' " +
//								"name='" + name + "' " +
//								"type='" + TYPE_APPLICATION + "' />" ),
//				_xmlStructure.toXMLString() );
//	}
//	private function fillFromCash() : void
//	{
		// get tpl picture
//		if ( pictureFile )
//		{
//			delete _xml.picture;
//			setPictureFromFile();
//		}
//		
//		if (!b64picture)
//			delete _xml.picture;
//		
//		
//		// get resources		
//		delete _xmlStructure.resources;
//
//		var index : XML = CashManager.getIndex( fullID );
//		if ( index )
//		{
//			var resources : XMLList = index.resource.(hasOwnProperty( '@category' ) &&
//					(@category == 'image' || @category == 'database'));
//
//			_xmlStructure.appendChild( <resources/> );
//
//			for each ( var res : XML in resources )
//			{
//				var resObj : Object = CashManager.getObject( fullID, res.@ID );
//				var resData : ByteArray = ByteArray( resObj.data );
//				var content : String = resData.readUTFBytes( resData.bytesAvailable );
//
//				var resXML : XML = XML( '<resource><![CDATA[' + content + ']]></resource>' );
//				resXML.@category = resObj.entry.@category;
//				resXML.@ID = resObj.entry.@ID;
//				resXML.@type = resObj.entry.@type;
//				resXML.@name = resObj.entry.@name;
//
//				_xmlStructure.resources.appendChild( resXML );
//			}
//		}
//	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

//	private function fileBrowseHandler (event : Event) : void
//	{
//		var f : File = event.target as File;
//		
//		f.removeEventListener( Event.SELECT, fileBrowseHandler );
//		
//		if ( f.isDirectory || f.isPackage || f.isSymbolicLink )
//		{
//			browseType = BROWSE_TYPE_NONE;
//			return;
//		}
//		
//		switch (browseType)
//		{
//			case BROWSE_TYPE_OPEN:
//			{
//				browseType = BROWSE_TYPE_NONE;
//				
//				file = f;
//				
//				open();
//				
//				/*var evnt : Event = new Event( 'opening', false, true );
//				dispatchEvent( evnt );
//				
//				if ( !evnt.isDefaultPrevented() )
//					open();*/
//				break;
//			}
//			case BROWSE_TYPE_SAVE:
//			{
//				browseType = BROWSE_TYPE_NONE;
//				
//				if ( !f.extension || f.extension.toLowerCase() != TPL_EXTENSION )
//					f = f.parent.resolvePath( f.name + '.' + TPL_EXTENSION );
//				
//				file = f;
//				
//				save();
//				
//				/*var evnt : Event = new Event( 'saving', false, true );
//				dispatchEvent( evnt );
//				
//				if ( !evnt.isDefaultPrevented() )
//					save();*/
//				break;
//			}
//			default:
//			{
//				browseType = BROWSE_TYPE_NONE;
//				break;
//			}
//		}
//	}
	
//	private function fileStreamOutputProgressHandler( event : OutputProgressEvent ) : void
//	{
//		if ( event.bytesPending == 0 )
//			fileStream.dispatchEvent( new Event( Event.COMPLETE ) );
//	}

//	private function saveHandler( event : Event ) : void
//	{
//		fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
//		fileStream.removeEventListener( Event.COMPLETE, saveHandler );
//		fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
//
//		try
//		{
//			fileStream.close();
//
//			ProgressManager.start( ProgressManager.DIALOG_MODE, false );
//
//			_xml = XML( CashManager.getStringObject( fullID, 'template' ) );
//
//			// update tpl UID
//			var oldID : String = fullID;
//			_fullID = null;
//			CashManager.updateID( oldID, fullID );
//
//			ProgressManager.complete();
//
//			modified = false;
//
//			dispatchEvent( new Event( Event.COMPLETE ) );
//		}
//		catch ( e : Error )
//		{
//			ProgressManager.complete();
//
//			showError(LanguageManager.sentences['msg_not_valid_tpl_file']);
//		}
//	}

//	private function openHandler( event : Event ) : void
//	{
////		fileStream.removeEventListener( Event.COMPLETE, openHandler );
//		fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
//
//		try
//		{
//			ProgressManager.start( ProgressManager.DIALOG_MODE, false );
//
//			var strData : String = fileStream.readUTFBytes( fileStream.bytesAvailable );
//			fileStream.close();
//
//			var xmlData : XML = XML( strData );
//
//			if ( !isValidTpl( xmlData ) )
//				throw new Error( LanguageManager.sentences['msg_not_valid_tpl_file'] );
//
//			_xml = xmlData;
//
//			_completelyOpened = false;
//
//			_fullID = null;
//
//			processOpened();
//
//			ProgressManager.complete();
//
//			modified = false;
//
//			dispatchEvent( new Event( Event.COMPLETE ) );
//		}
//		catch ( e : Error )
//		{
//			fileStream.close();
//
//			ProgressManager.complete();
//
//			showError(LanguageManager.sentences['msg_not_valid_tpl_file']);
//		}
//	}

//	private function fileStreamIOErrorHandler( event : IOErrorEvent ) : void
//	{
////		browseType = BROWSE_TYPE_NONE;
//		
//		fileStream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOutputProgressHandler );
//		
//		fileStream.removeEventListener( Event.COMPLETE, saveHandler );
//		fileStream.removeEventListener( Event.COMPLETE, openHandler );
//		
//		fileStream.removeEventListener( IOErrorEvent.IO_ERROR, fileStreamIOErrorHandler );
//		
//		file.cancel();
//		fileStream.close();
//		
//		ProgressManager.complete();
//
//		showError(event.text);
//	}
	
//	private function showError(errorText : String) : void
//	{
//		AlertPopup.show( errorText,  LanguageManager.sentences['error']);
//	}
//

}
}
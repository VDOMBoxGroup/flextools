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
	public function dispose() : void
	{
		_xmlStructure = null;
		_xml = null;
	}

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

	protected var _completelyOpened : Boolean;

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

	protected var _xml : XML;

	public function get xml() : XML
	{
		return _xml;
	}

	//----------------------------------
	//  xmlStructure
	//----------------------------------

	protected var _xmlStructure : XML;

	public function set xmlStructure( value : XML ) : void
	{
		if ( _xmlStructure != value )
		{
			modified = true;
			_xmlStructure = value;
		}
	}

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
	public static const DEFAULT_OUTPUT_FILE_NAME	: String = "appInstaller";
	public static const DEFAULT_APP_PATH			: String = "";
	
	
	public function set installerId( value : String ) : void
	{
		if (!value)
			value = DEFAULT_INSTALLER_ID;

		if ( _xml.id != value )
		{
			modified = true;
			_xml.id = value;
		}
	}
	
	[Bindable]
	public function get installerId() : String
	{
		return Utils.getStringOrDefault( _xml.id, DEFAULT_INSTALLER_ID );
	}
	
	public function set installerAppPath( value : String ) : void
	{
		if (!value)
			value = DEFAULT_APP_PATH;

		if ( _xml.appPath != value )
		{
			modified = true;
			_xml.appPath = value;
		}
	}
	
	[Bindable]
	public function get installerAppPath() : String
	{
		return Utils.getStringOrDefault( _xml.appPath, DEFAULT_APP_PATH );
	}
	

	
	public function set installerFileName( value : String ) : void
	{
		if (!value)
			value = DEFAULT_OUTPUT_FILE_NAME;

		if ( _xml.outputFileName != value )
		{
			modified = true;
			_xml.outputFileName = value;
		}
	}
	
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

	public function set description( value : String ) : void
	{
		if ( _xml.description != value )
		{
			modified = true;
			_xml.description = value;
		}
	}

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

	protected var _fullID : String;

	public function get fullID() : String
	{
		if ( !_fullID )
		{
			_fullID = ID;

//			if ( file && file.exists )
//				_fullID += '_' + file.creationDate.getTime() + '_' + file.modificationDate.getTime() + '_' + file.size;
		}

		return _fullID;
	}

	//----------------------------------
	//  b64picture
	//----------------------------------
	
	public function set b64picture( value : String ) : void
	{
		if ( _xml.picture[0] != value )
		{
			modified = true;
			if (value)
				_xml.picture = value;
			else
				delete _xml.picture;
		}
	}
	
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

	protected function isValidTpl( xmlData : XML ) : Boolean
	{
		if ( xmlData.name() != 'template' )
			return false;

		if ( !xmlData.hasOwnProperty( 'encoded' ) && !xmlData.hasOwnProperty( 'structure' ) )
			return false;

		return true;
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

	protected function encode() : void
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
	
	protected function showError(errorText : String) : void
	{
		AlertPopup.show( errorText,  LanguageManager.sentences['error']);
	}


}
}
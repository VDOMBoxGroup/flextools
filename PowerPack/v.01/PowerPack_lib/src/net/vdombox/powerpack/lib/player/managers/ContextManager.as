package net.vdombox.powerpack.lib.player.managers
{

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.core.Application;
import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;

import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.lib.player.gen.TemplateStruct;
import net.vdombox.powerpack.lib.player.template.Template;
import net.vdombox.powerpack.lib.player.utils.CryptUtils;

public class ContextManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 * This flag is responsible for extending flash built-in context menu
	 */
	public static const FLASH_CONTEXT_MENU : Boolean = true;
	public static const FILE_NUM_STORE : uint = 5;

	/**
	 *  @private
	 */
	private static var _instance : ContextManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance() : ContextManager
	{
		if ( !_instance )
		{
			_instance = new ContextManager();
		}

		return _instance;
	}

	/**
	 *  @private
	 */
	public static function get instance() : ContextManager
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
	public function ContextManager()
	{
		super();

		if ( _instance )
			throw new Error( "Instance already exists." );

		if ( Application.application.className == "Generator" )
		{
			_context = 'generator';
		}
		else if ( Application.application.className == "Builder" )
		{
			_context = 'builder';
		}

	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------	

	[Embed(source="/assets/icons/icon_16.png")]
	[Bindable]
	public static var iconClass : Class;

	[Embed(source="/assets/icons/info_16.png")]
	[Bindable]
	public static var infoClass : Class;

	[Embed(source="/assets/icons/warning_16.png")]
	[Bindable]
	public static var warnClass : Class;

	[Embed(source="/assets/icons/error_16.png")]
	[Bindable]
	public static var errClass : Class;

	[Embed(source="/assets/icons/expand_16.png")]
	[Bindable]
	public static var expandClass : Class;

	[Embed(source="/assets/icons/helptip_16.png")]
	[Bindable]
	public static var helpTipClass : Class;

	[Embed(source="/assets/icons/add_16.png")]
	[Bindable]
	public static var addClass : Class;
	
	[Embed(source="/assets/icons/add_disabled_16.png")]
	[Bindable]
	public static var addDisabledClass : Class;
	
	[Embed(source="/assets/icons/add_category16.png")]
	[Bindable]
	public static var addCategoryClass : Class;
	
	[Embed(source="/assets/icons/add_categoryDisabled.png")]
	[Bindable]
	public static var addCategoryDisabledClass : Class;

	[Embed(source="/assets/icons/copy_16.png")]
	[Bindable]
	public static var copyClass : Class;
	
	[Embed(source="/assets/icons/copy_disabled.png")]
	[Bindable]
	public static var copyDisabledClass : Class;

	[Embed(source="/assets/icons/edit_16.png")]
	[Bindable]
	public static var editClass : Class;
	
	[Embed(source="/assets/icons/edit_disabled.png")]
	[Bindable]
	public static var editDisabledClass : Class;
	
	[Embed(source="/assets/icons/export_graph_disabled.png")]
	[Bindable]
	public static var exportGraphDisabledClass : Class;

	[Embed(source="/assets/icons/export_graph_enabled.png")]
	[Bindable]
	public static var exportGraphEnabledClass : Class;
	
	[Embed(source="/assets/icons/delete_16.png")]
	[Bindable]
	public static var deleteClass : Class;
	
	[Embed(source="/assets/icons/delete_disabled.png")]
	[Bindable]
	public static var deleteDisabledClass : Class;

	[Embed(source="/assets/icons/help_16.png")]
	[Bindable]
	public static var helpClass : Class;

	[Embed(source="/assets/icons/bug_16.png")]
	[Bindable]
	public static var problemsClass : Class;

	[Embed(source="/assets/icons/search.png")]
	[Bindable]
	public static var searchClass : Class;
		
	[Embed(source="/assets/icons/variable_16.png")]
	[Bindable]
	public static var variablesClass : Class;

	protected var _context : String = 'builder';

	protected var _appContext : Object = {
		builder : { settingsFolder : "Builder" },
		generator : { settingsFolder : "Generator" }
	};

	[Bindable]
	public var settingsXML : XML;

	protected var _templates : ArrayCollection = new ArrayCollection();
	protected var _templateStruct : TemplateStruct;

	public var files : Array = [];
	public var lastFile : Boolean;
	public var lang : Object = {label : "english", file : "english.xml"};

	[Bindable]
	public var saveToFile : Boolean;
	[Bindable]
	public var saveToServer : Boolean;

	[Bindable]
	public var host : String = "http://localhost";
	[Bindable]
	public var default_port : String = "80";
	[Bindable]
	public var port : String = "80";
	[Bindable]
	public var use_def_port : Boolean = true;

	[Bindable]
	public var login : String = "root";
	[Bindable]
	public var pass : String = "root";
	[Bindable]
	public var save_pass : Boolean = false;

	// [ui todo]
	// window state, size, position
	// hdividedbox slider position
	// active tab
	// active graph

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------			

	//----------------------------------
	//  context
	//----------------------------------

	public static function get context() : String
	{
		return instance._context;
	}

	//----------------------------------
	//  appContext
	//----------------------------------

	public static function get appContext() : Object
	{
		return instance._appContext;
	}

	//----------------------------------
	//  templates
	//----------------------------------

	public static function get templates() : ArrayCollection
	{
		return instance._templates;
	}
	
	public static function get currentTemplate () : Template
	{
		if ( !ContextManager.templates || ContextManager.templates.length == 0 )
			return null;
		
		return ContextManager.templates.getItemAt( 0 ) as Template;
	}

	//----------------------------------
	//  templateStruct
	//----------------------------------

	public static function get templateStruct() : TemplateStruct
	{
		return instance._templateStruct;
	}

	public static function set templateStruct( value : TemplateStruct ) : void
	{
		if ( instance._templateStruct != value )
			instance._templateStruct = value;
	}

}
}
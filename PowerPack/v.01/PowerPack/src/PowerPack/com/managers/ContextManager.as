package PowerPack.com.managers
{
import ExtendedAPI.com.utils.FileUtils;
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.TemplateStruct;
import PowerPack.com.utils.CryptUtils;

import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.core.Application;
import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;

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
    public static const FLASH_CONTEXT_MENU:Boolean = true;
    public static const FILE_NUM_STORE:uint = 5;

	/**
	 *  @private
	 */
	private static var _instance:ContextManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():ContextManager
	{
		if (!_instance)
		{
			_instance = new ContextManager();
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():ContextManager
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

		if (_instance)
			throw new Error("Instance already exists.");
				
		if(Application.application.className == "Generator")
		{
			_context = 'generator';
		}
		else if(Application.application.className == "Builder")
		{
			_context = 'builder';
		}
		
    	dataStorage = new File();
    	dataStorage.url = FileUtils.pathToUrl(File.applicationStorageDirectory.nativePath);
	    
	    settingStorage = dataStorage.resolvePath(_appContext[_context]['settingsFolder']);
    
	    try {
	    	lastDir = File.documentsDirectory.resolvePath("PowerPack");
	    }
	    catch(e:Error) {
	    	lastDir = new File();
	    	lastDir.url = FileUtils.pathToUrl(File.applicationDirectory.nativePath);
	    }
	    
	    files = [];
	    
	    file = File.documentsDirectory.resolvePath("app.xml");
	    
	    lang = {label:"english", file:"english.xml"};
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------			
	[Embed(source="assets/icons/icon_16.png")]
	[Bindable]
 	public static var iconClass:Class;

	[Embed(source="assets/icons/info_16.png")]
	[Bindable]
 	public static var infoClass:Class;

	[Embed(source="assets/icons/warning_16.png")]
	[Bindable]
 	public static var warnClass:Class;

	[Embed(source="assets/icons/error_16.png")]
	[Bindable]
 	public static var errClass:Class;

	[Embed(source="assets/icons/expand_16.png")]
	[Bindable]
 	public static var expandClass:Class;

	[Embed(source="assets/icons/helptip_16.png")]
	[Bindable]
 	public static var helpTipClass:Class;

	[Embed(source="assets/icons/add_16.png")]
	[Bindable]
 	public static var addClass:Class;

	[Embed(source="assets/icons/copy_16.png")]
	[Bindable]
 	public static var copyClass:Class;

	[Embed(source="assets/icons/edit_16.png")]
	[Bindable]
 	public static var editClass:Class;

	[Embed(source="assets/icons/delete_16.png")]
	[Bindable]
 	public static var deleteClass:Class;

	[Embed(source="assets/icons/help_16.png")]
	[Bindable]
 	public static var helpClass:Class;
 	
	[Embed(source="assets/icons/expand_16.png")]
	[Bindable]
 	public static var problemsClass:Class;

	[Embed(source="assets/icons/variable_16.png")]
	[Bindable]
 	public static var variablesClass:Class;

 	//
 	//
 	//

	private var _context:String = 'builder';
	private var _appContext:Object = {
		builder:{ settingsFolder:"Builder" },
		generator:{ settingsFolder:"Generator" }
	};
	
	public var templateStruct:TemplateStruct;

   	[Bindable]
    public var settingsXML:XML;
    
    [Bindable]
    public var templates:ArrayCollection = new ArrayCollection();
    
    public var dataStorage:File;
    public var settingStorage:File;
    public var genSettingStorage:File;
    
    public var files:Array;	    
    public var lastFile:Boolean;
    public var lastDir:File;
    public var lang:Object;
    
    [Bindable]
	public var file:File;
	
	[Bindable]
	public var saveToFile:Boolean;	
	[Bindable]
	public var saveToServer:Boolean;
	
	[Bindable]
	public var host:String = "http://192.168.0.24";
	[Bindable]
	public var default_port:String = "80";
	[Bindable]
	public var port:String = "80";
	[Bindable]
	public var use_def_port:Boolean = true;

	[Bindable]
	public var login:String = "root";
	[Bindable]
	public var pass:String = "root";
	[Bindable]
	public var save_pass:Boolean = false;
    
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

	public static function get context():String
	{
		return instance._context;
	}

    //----------------------------------
	//  appContext
    //----------------------------------

	public static function get appContext():Object
	{
		return instance._appContext;
	}

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
            
    public static function updateLastFiles(file:File):void
    {
    	ContextManager.instance.lastFile = true;            		
    	ContextManager.instance.lastDir = file.parent;
    	
    	var files:ArrayCollection = new ArrayCollection(ContextManager.instance.files);

    	for(var i:int=0; i<files.length; i++)
    	{
    		if(files.getItemAt(i).nativePath == file.nativePath)
    		{
    			files.removeItemAt(i);
    			i--;
    		}
    	}
    	
    	ContextManager.instance.files.unshift(file);
    	if(ContextManager.instance.files.length>ContextManager.FILE_NUM_STORE)
    		ContextManager.instance.files.pop();
	}
            
    public static function loadSettings():void
    {
		var file:File;
		var fileStream:FileStream = new FileStream();
		var tmpStr:String;
		
		// load settings
		file = instance.settingStorage.resolvePath("settings.xml");
		if(!file.exists)
			return;	
					
		fileStream.open(file, FileMode.READ);
		instance.settingsXML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
		fileStream.close();					
	
		// get language
		tmpStr = Utils.getStringOrDefault(instance.settingsXML.language, null);
		if(tmpStr)
		{
			instance.lang.label = tmpStr;
			instance.lang.file = tmpStr + ".xml";
		}   
		
		// get lastdir 
		tmpStr = Utils.getStringOrDefault(instance.settingsXML.lastdir, instance.lastDir ? instance.lastDir.nativePath : null);
		if(FileUtils.isValidPath(tmpStr))
		{
			instance.lastDir = new File();
			instance.lastDir.url = FileUtils.pathToUrl(tmpStr);
 		}
 		
		// get app file 
		tmpStr = Utils.getStringOrDefault(instance.settingsXML.appfile, instance.file ? instance.file.nativePath : null);
		if(FileUtils.isValidPath(tmpStr))
		{
			instance.file = new File();
			instance.file.url = FileUtils.pathToUrl(tmpStr);
 		}
 		
 		// get files and last open file
 		tmpStr = (Utils.getStringOrDefault(instance.settingsXML.lastfile, "false")).toString();
 		instance.lastFile = tmpStr.toLowerCase()=="true"?true:false;
		
		tmpStr = Utils.getStringOrDefault(instance.settingsXML.files, null);
		if(tmpStr)
		{
			var fileArr:Array = tmpStr.split(",");
			
			if(!instance.files || instance.files.length==0) 
				instance.files = [];
				
			for(var i:int=0; i<fileArr.length; i++)
			{
				if(instance.files.length>=FILE_NUM_STORE)
					break;
					
				if(FileUtils.isValidPath(fileArr[i]))
				{
					file = new File();
					file.url = FileUtils.pathToUrl(fileArr[i]);
					instance.files.push(file);
	 			}
 			}
 		}

 		// save to file option
 		tmpStr = (Utils.getStringOrDefault(instance.settingsXML.savetofile, "false")).toString();
 		instance.saveToFile = tmpStr.toLowerCase()=="true"?true:false;
 		
 		// save to server option
 		tmpStr = (Utils.getStringOrDefault(instance.settingsXML.savetoserver, "false")).toString();
 		instance.saveToServer = tmpStr.toLowerCase()=="true"?true:false;
 		 		
		// get connection params 
		instance.host = Utils.getStringOrDefault(instance.settingsXML.host, instance.host);
		instance.port = Utils.getStringOrDefault(instance.settingsXML.port, instance.port);

		instance.default_port = Utils.getStringOrDefault(instance.settingsXML.defaulthost, instance.default_port);

 		tmpStr = (Utils.getStringOrDefault(instance.settingsXML.usedefport, "true")).toString();
 		instance.use_def_port = tmpStr.toLowerCase()=="true"?true:false;

		// get authentication params 
		instance.login = Utils.getStringOrDefault(instance.settingsXML.login, instance.login);

		tmpStr = Utils.getStringOrDefault(instance.settingsXML.pass, '');
		if(tmpStr)
		{
			var base64Dec:Base64Decoder = new Base64Decoder();	
			base64Dec.decode(tmpStr);
			
			var bytes:ByteArray = CryptUtils.decrypt(base64Dec.flush());	
			bytes.position = 0;
			tmpStr = bytes.readUTFBytes(bytes.length);					
			instance.pass = instance.pass ? instance.pass : tmpStr;
		} 
		 
 		tmpStr = (Utils.getStringOrDefault(instance.settingsXML.savepass, "false")).toString();
 		instance.save_pass = tmpStr.toLowerCase()=="true"?true:false;
		
 		// get ...        	
    }	
        
   	public static function saveSettings():void
   	{
		var file:File;
		var fileStream:FileStream = new FileStream();
		var tmpStr:String;
		       		
		file = instance.settingStorage.resolvePath("settings.xml");
   		instance.settingsXML = new XML(<settings></settings>);
   		
   		// fill XML
   		instance.settingsXML.language = (instance.lang.label ? instance.lang.label : "");
   		
   		instance.settingsXML.lastdir = (instance.lastDir && instance.lastDir.nativePath ? instance.lastDir.nativePath : "");
   		
   		instance.settingsXML.lastfile = (instance.lastFile ? "true" : "false");

   		instance.settingsXML.appfile = (instance.file && instance.file.nativePath ? instance.file.nativePath : "");

   		instance.settingsXML.savetofile = (instance.saveToFile ? "true" : "false");

   		instance.settingsXML.savetoserver = (instance.saveToServer ? "true" : "false");
   		
   		instance.settingsXML.host = (instance.host ? instance.host : "");

   		instance.settingsXML.port = (instance.port ? instance.port : "");

   		instance.settingsXML.defaultport = (instance.default_port ? instance.default_port : "80");

   		instance.settingsXML.usedefport = (instance.use_def_port ? "true" : "false");

   		instance.settingsXML.login = (instance.login ? instance.login : "");

		if(instance.save_pass && instance.pass)
		{
			var bytes:ByteArray = CryptUtils.encrypt(instance.pass);	
			bytes.position = 0;
			var base64Enc:Base64Encoder = new Base64Encoder();			
			base64Enc.encodeBytes(bytes, 0, bytes.length);
			instance.settingsXML.pass = base64Enc.flush();
		}

   		instance.settingsXML.savepass = (instance.save_pass ? "true" : "false");

   		tmpStr = "";
   		if(instance.files)
   		{
   			for(var i:int=0; i<instance.files.length; i++)
   				tmpStr += (i>0?",":"") + instance.files[i].nativePath;
   		}
   		instance.settingsXML.files = tmpStr;
   		
		// save settings
   		if(file.parent.exists)
   		{ 
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(instance.settingsXML.toXMLString());
			fileStream.close();
   		}
   	}	

}
}
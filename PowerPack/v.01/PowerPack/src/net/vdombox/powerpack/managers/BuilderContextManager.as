package net.vdombox.powerpack.managers
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.gen.TemplateStruct;
	import net.vdombox.powerpack.lib.player.managers.ContextManager;
	import net.vdombox.powerpack.lib.player.utils.CryptUtils;
	import net.vdombox.powerpack.template.BuilderTemplate;
	
	public class BuilderContextManager extends EventDispatcher
	{
		public var dataStorage : File = File.applicationStorageDirectory;
		public var settingStorage : File;
		public var genSettingStorage : File;
		
		public var lastDir : File = File.desktopDirectory;
		
		[Bindable]
		public var file : File = File.documentsDirectory.resolvePath( "app.xml" );
		
		public function BuilderContextManager()
		{
			super();
			
			settingStorage = dataStorage.resolvePath( appContext[context]['settingsFolder'] );
			
			try
			{
				lastDir = File.documentsDirectory.resolvePath( "powerpack" );
			}
			catch ( e : Error )
			{
				lastDir = File.desktopDirectory;
			}
		}
	
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		private static var _instance : BuilderContextManager;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		public static function getInstance() : BuilderContextManager
		{
			if ( !_instance )
			{
				_instance = new BuilderContextManager();
			}
			
			return _instance;
		}
		
		/**
		 *  @private
		 */
		
		public static function get instance() : BuilderContextManager
		{
			return getInstance();
		}
		
		public static function updateLastFiles( file : File ) : void
		{
			if (!file)
				return;
			
			ContextManager.instance.lastFile = true;
			instance.lastDir = file.parent;
	
			var files : ArrayCollection = new ArrayCollection( ContextManager.instance.files );
	
			for ( var i : int = 0; i < files.length; i++ )
			{
				if ( files.getItemAt( i ).nativePath == file.nativePath )
				{
					files.removeItemAt( i );
					i--;
				}
			}
	
			ContextManager.instance.files.unshift( file );
	
			if ( ContextManager.instance.files.length > ContextManager.FILE_NUM_STORE )
				ContextManager.instance.files.pop();
		}
	
		public static function loadSettings() : void
		{
			var file : File;
			var fileStream : FileStream = new FileStream();
			var tmpStr : String;
	
			// load settings
			file = instance.settingStorage.resolvePath( "settings.xml" );
	
			if ( !file.exists )
				return;
	
			try
			{
				fileStream.open( file, FileMode.READ );
				ContextManager.instance.settingsXML = XML( fileStream.readUTFBytes( fileStream.bytesAvailable ) );
				fileStream.close();
			}
			catch ( e : * )
			{
				return;
			}
			;
	
			// get language
			tmpStr = Utils.getStringOrDefault( ContextManager.instance.settingsXML.language, null );
			if ( tmpStr )
			{
				ContextManager.instance.lang.label = tmpStr;
				ContextManager.instance.lang.file = tmpStr + ".xml";
			}
	
			// get lastdir 
			tmpStr = Utils.getStringOrDefault( ContextManager.instance.settingsXML.lastdir, instance.lastDir ? instance.lastDir.nativePath : null );
			if ( tmpStr )
			{
				instance.lastDir = new File( tmpStr );
			}
	
			// get app file 
			tmpStr = Utils.getStringOrDefault( ContextManager.instance.settingsXML.appfile, instance.file ? instance.file.nativePath : null );
			if ( tmpStr )
			{
				instance.file = new File( tmpStr );
			}
	
			// get files and last open file
			ContextManager.instance.lastFile = Utils.getBooleanOrDefault( ContextManager.instance.settingsXML.lastfile );
	
			tmpStr = Utils.getStringOrDefault( ContextManager.instance.settingsXML.files, null );
			if ( tmpStr )
			{
				var fileArr : Array = tmpStr.split( "," );
	
				ContextManager.instance.files = [];
	
				for ( var i : int = 0; i < fileArr.length; i++ )
				{
					if ( ContextManager.instance.files.length >= ContextManager.FILE_NUM_STORE )
						break;
	
					if ( fileArr[i] )
					{
						file = new File( fileArr[i] );
						ContextManager.instance.files.push( file );
					}
				}
			}
	
			// save to file option
			ContextManager.instance.saveToFile = Utils.getBooleanOrDefault( ContextManager.instance.settingsXML.savetofile );
	
			// save to server option
			ContextManager.instance.saveToServer = Utils.getBooleanOrDefault( ContextManager.instance.settingsXML.savetoserver );
	
			// get connection params 
			ContextManager.instance.host = Utils.getStringOrDefault( ContextManager.instance.settingsXML.host, ContextManager.instance.host );
			ContextManager.instance.port = Utils.getStringOrDefault( ContextManager.instance.settingsXML.port, ContextManager.instance.port );
	
			ContextManager.instance.default_port = Utils.getStringOrDefault(ContextManager.instance.settingsXML.defaulthost, ContextManager.instance.default_port );
			ContextManager.instance.use_def_port = Utils.getBooleanOrDefault( ContextManager.instance.settingsXML.usedefport );
	
			// get authentication params 
			ContextManager.instance.login = Utils.getStringOrDefault( ContextManager.instance.settingsXML.login, ContextManager.instance.login );
	
			tmpStr = Utils.getStringOrDefault( ContextManager.instance.settingsXML.pass, '' );
			if ( tmpStr )
			{
				var base64Dec : Base64Decoder = new Base64Decoder();
				base64Dec.decode( tmpStr );
	
				var bytes : ByteArray = CryptUtils.decrypt( base64Dec.flush() );
				bytes.position = 0;
				tmpStr = bytes.readUTFBytes( bytes.length );
				ContextManager.instance.pass = tmpStr ? tmpStr : ContextManager.instance.pass;
			}
	
			ContextManager.instance.save_pass = Utils.getBooleanOrDefault( ContextManager.instance.settingsXML.savepass );
	
			// get ...
		}
	
		public static function saveSettings() : void
		{
			var file : File;
			var fileStream : FileStream = new FileStream();
			var tmpStr : String;
	
			file = instance.settingStorage.resolvePath( "settings.xml" );
			ContextManager.instance.settingsXML = new XML( <settings/> );
	
			// fill XML
			ContextManager.instance.settingsXML.language = (ContextManager.instance.lang.label ? ContextManager.instance.lang.label : "english");
	
			ContextManager.instance.settingsXML.lastdir = (instance.lastDir && instance.lastDir.nativePath ? instance.lastDir.nativePath : File.desktopDirectory.nativePath);
	
			ContextManager.instance.settingsXML.lastfile = (ContextManager.instance.lastFile ? "true" : "false");
	
			ContextManager.instance.settingsXML.appfile = (instance.file && instance.file.nativePath ? instance.file.nativePath : File.documentsDirectory);
	
			ContextManager.instance.settingsXML.savetofile = (ContextManager.instance.saveToFile ? "true" : "false");
	
			ContextManager.instance.settingsXML.savetoserver = (ContextManager.instance.saveToServer ? "true" : "false");
	
			ContextManager.instance.settingsXML.host = (ContextManager.instance.host ? ContextManager.instance.host : "http://localhost");
	
			ContextManager.instance.settingsXML.port = (ContextManager.instance.port ? ContextManager.instance.port : "80");
	
			ContextManager.instance.settingsXML.defaultport = (ContextManager.instance.default_port ? ContextManager.instance.default_port : "80");
	
			ContextManager.instance.settingsXML.usedefport = (ContextManager.instance.use_def_port ? "true" : "false");
	
			ContextManager.instance.settingsXML.login = (ContextManager.instance.login ? ContextManager.instance.login : "root");
	
			if ( ContextManager.instance.save_pass && ContextManager.instance.pass )
			{
				var bytes : ByteArray = CryptUtils.encrypt( ContextManager.instance.pass );
				bytes.position = 0;
				var base64Enc : Base64Encoder = new Base64Encoder();
				base64Enc.encodeBytes( bytes, 0, bytes.length );
				ContextManager.instance.settingsXML.pass = base64Enc.flush();
			}
	
			ContextManager.instance.settingsXML.savepass = (ContextManager.instance.save_pass ? "true" : "false");
	
			tmpStr = "";
			if ( ContextManager.instance.files )
			{
				for ( var i : int = 0; i < ContextManager.instance.files.length; i++ )
					tmpStr += (i > 0 ? "," : "") + ContextManager.instance.files[i].nativePath;
			}
			ContextManager.instance.settingsXML.files = tmpStr;
	
			// save settings
			try
			{
				fileStream.open( file, FileMode.WRITE );
				fileStream.writeUTFBytes( ContextManager.instance.settingsXML.toXMLString() );
				fileStream.close();
			}
			catch ( e : * )
			{
			}
			;
		}
		
		//----------------------------------
		//  context
		//----------------------------------
		
		public static function get context() : String
		{
			return ContextManager.context;
		}
		
		//----------------------------------
		//  appContext
		//----------------------------------
		
		public static function get appContext() : Object
		{
			return ContextManager.appContext;
		}
		
		//----------------------------------
		//  templates
		//----------------------------------
		
		public static function get templates() : ArrayCollection
		{
			return ContextManager.templates;
		}
		
		public static function get currentTemplate () : BuilderTemplate
		{
			return ContextManager.currentTemplate as BuilderTemplate;
		}
		
		//----------------------------------
		//  templateStruct
		//----------------------------------
		
		public static function get templateStruct() : TemplateStruct
		{
			return ContextManager.templateStruct;
		}
		
		public static function set templateStruct( value : TemplateStruct ) : void
		{
			if ( ContextManager.templateStruct != value )
				ContextManager.templateStruct = value;
		}

		
	}
}
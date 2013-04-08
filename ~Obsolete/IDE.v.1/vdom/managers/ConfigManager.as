package vdom.managers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import vdom.managers.configClasses.Config;
	import vdom.managers.configClasses.ConfigWriter;
	import vdom.managers.configClasses.ConfigXML;
	
public class ConfigManager
{
	private static var instance : ConfigManager;
	
	public const CONFIGURATION_DIRECTORY : String = "/configuration/";
	
	private var _configPath : String;
	private var _configFile : File;
	
	public static function getInstance() : ConfigManager
	{
		if ( !instance )
			instance = new ConfigManager();
		
		return instance;
	}
	
	public function ConfigManager()
	{
		if ( instance )
			throw new Error( "Instance already exists." );
	}
	
	
	public function init() : void
	{
	}
	
	public function createConfig( configName : String ) : Config
	{
		var configName : String = configName.replace( /(^\.+)|(\.+$)|[^\w.]/g, "" ); 
		configName = configName.replace( /\.+/g, "/" );
		
		if( !configName )
			return null;
		
		var config : ConfigXML = new ConfigXML();
		config.setName( configName );
		
		return config;
	}
	
	public function getConfig( configName : String ) : ConfigXML
	{
		var configName : String = configName.replace( /(^\.+)|(\.+$)|[^\w.]/g, "" ); 
		configName = configName.replace( /\.+/g, "/" );
		
		if( !configName )
			return null;
		 
		var path : String = 
			File.applicationStorageDirectory.nativePath + 
			CONFIGURATION_DIRECTORY + 
			configName +
			".xml";
		
		var config : ConfigXML = new ConfigXML();
		config.setName( configName );
		
		var isLoaded : Boolean = config.loadXMLConfig( path );
		
		if( !isLoaded )
			return null;
			
		return config;
	}
	
	public function saveConfig( config : Config ) : Boolean
	{
		var configWriter : ConfigWriter = new ConfigWriter();
		
		var path : String = config.getName();
		
		if( !path )
			return false;
		
		path = 
			File.applicationStorageDirectory.nativePath + 
			CONFIGURATION_DIRECTORY + 
			path.replace( /\.+/g, "/" ) + 
			".xml";
		
		var isSaved : Boolean = configWriter.write( path, config );
		return isSaved;
	}
	
	public function deleteConfig( configName : String ) : void
	{
		var configName : String = configName.replace( /(^\.+)|(\.+$)|[^\w.]/g, "" ); 
		configName = configName.replace( /\.+/g, "/" );
		
		if( !configName )
			return;
		 
		var path : String = 
			File.applicationStorageDirectory.nativePath + 
			CONFIGURATION_DIRECTORY + 
			configName +
			".xml";
		
		var file : File = new File( path );
		
		if( file.exists )
		{
			try
			{
				file.deleteFile();
			}
			catch( error : Error ){}
		}
	}
}
}
package PowerPack.com.managers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	

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
		
	public var cashDir:File = File.applicationStorageDirectory.resolvePath('cash');
	
	private var _initialized:Boolean;	 	 
	public function get initialized():Boolean
	{
		return _initialized;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	private static function initialize():void
	{
		instance._initialized = false;
		
		if(!instance.cashDir.exists)
		{
			instance.cashDir.createDirectory();
		}
	}
	
	// index manipulation
	
	private function getMainIndex():XML
	{
		
	}
	
	private function setMainIndex(index:XML):void
	{
		
	}

	private function addMainIndexEntry(index:XML, entryXML:XML):void
	{
		
	}

	private function removeMainIndexEntry(index:XML, tplID:String):void
	{
		
	}
	
	private function updateMainIndexEntry(index:XML, tplID:String, arg:String, value:String):void
	{
		
	}
	
	private function getIndex(tplID:String):XML
	{
		
	}

	private function setIndex(index:XML):void
	{
		
	}
	
	private function addIndexEntry(index:XML, entryXML:XML):void
	{
		
	}

	private function removeIndexEntry(index:XML, objID:String):void
	{
		
	}
	
	private function updateIndexEntry(index:XML, objID:String, arg:String, value:String):void
	{
		
	}
	
	//

	public static function getObj(tplID:String, objID:String):Object
	{		
		instance.initialized();
		
		var tplDir:File = instance.cashDir.resolvePath(tplID);
		
		if(!tplDir.exists)
			return null;
		
		// get index
				
		var tplIndex:File = tplDir.resolvePath('index.xml');
		
		if(!tplIndex.exists)
			return null;
		
		var tplIndexXML:XML;
		var indexStream:FileStream = new FileStream(); 

		//indexStream.addEventListener(Event.COMPLETE, completeOpenHandler);
		indexStream.open(tplIndex, FileMode.READ);		
		
		tplIndexXML = XML(indexStream.readUTFBytes(indexStream.bytesAvailable));		
			
	}
	
	public static function setObj(tplID:String, objID:String, obj:Object):Object
	{
		instance.initialized();		
	}
	

	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
	
	    
}
}
package PowerPack.com.managers
{
	import flash.filesystem.File;
	

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
	
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
	
	    
}
}
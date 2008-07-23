package PowerPack.com.managers
{
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class SelectionManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 */
	private static var _instance:SelectionManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():SelectionManager
	{
		if (!_instance)
		{
			_instance = new SelectionManager();
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():SelectionManager
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
	public function SelectionManager()
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

	var private containers:Dictionary = new Dictionary(true);
}
}
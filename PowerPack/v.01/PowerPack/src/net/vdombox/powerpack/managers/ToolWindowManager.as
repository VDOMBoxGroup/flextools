package net.vdombox.powerpack.managers
{
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

public class ToolWindowManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 */
	private static var _instance:ToolWindowManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():ToolWindowManager
	{
		if (!_instance)
		{
			_instance = new ToolWindowManager();
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():ToolWindowManager
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
	public function ToolWindowManager()
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



}
}
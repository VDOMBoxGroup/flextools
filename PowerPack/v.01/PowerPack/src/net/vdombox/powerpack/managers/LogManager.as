package net.vdombox.powerpack.managers
{
import flash.events.EventDispatcher;

public class LogManager extends EventDispatcher
{
	/**
	 *  @private
	 */
	private static var _instance:LogManager;

	/**
	 *  @private
	 */
	public static function getInstance():LogManager
	{
		if (!_instance)
		{
			_instance = new LogManager();
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():LogManager
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
	public function LogManager()
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

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------			

    //----------------------------------
	//  languageXML
    //----------------------------------	

	[Bindable]
	public var _languageXML:XML;
    
    public static function get languageXML():XML
    {
    	return instance._languageXML;
    }	
    
    public static function set languageXML(value:XML):void
    {
    	instance._languageXML = value;
    }	
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

}
}
package PowerPack.com.managers
{
import flash.events.EventDispatcher;

import generated.webservices.Vdom;

public class ConnectionManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 */
	private static var _instance:ConnectionManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():ConnectionManager
	{
		if (!_instance)
		{
			_instance = new ConnectionManager();
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():ConnectionManager
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
	public function ConnectionManager()
	{
		super();

		if (_instance)
			throw new Error("Instance already exists.");
			
		instance.vdom = new Vdom(null, instance.host + ":" + 
			(instance.use_def_port ? instance.default_port : instance.port) + "/SOAP");		
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------			

    [Bindable]
    public var ws:WebService = new WebService();
    
    [Bindable]
    public var vdom:Vdom = new Vdom();
    
    public var loggedIn:Boolean;    
	
}
}
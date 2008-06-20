package vdom.managers {
	
	import flash.events.EventDispatcher;
	
	import vdom.connection.soap.Soap;
	import vdom.connection.soap.SoapEvent;
	

public class CacheManager {
	
	private static var instance:CacheManager;
	
	private var dispatcher:EventDispatcher;
	
	public static function getInstance():CacheManager {
		
		if (!instance) {
			
			instance = new CacheManager();
		}

		return instance;
	}
	
	public function CacheManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
	} 
}
}
package vdom.managers
{
	public class ModuleManager
	{

		public function ModuleManager()
		{
		}

	}
	
	private static var instance : ModuleManager;
	
	public static function getInstance() : ModuleManager
	{
		if ( !instance )
		{

			instance = new ModuleManager();
		}

		return instance;
	}
}
package vdom.components.editor.managers
{
public class Proxy
{
	private static var instance:Proxy;
	
	public static function getInstance():Proxy
	{
		if (!instance) {

			instance = new Proxy();
		}

		return instance;
	}
}
}
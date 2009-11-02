package net.vdombox.ide.core.interfaces
{	
	import org.puremvc.as3.multicore.interfaces.IProxy;

	public interface IObjectProxy extends IProxy
	{
		function get id() : String;
		function get attributes() : XMLList;
	}
}
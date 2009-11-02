package net.vdombox.ide.interfaces
{
	import net.vdombox.ide.model.vo.PageVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;

	public interface IObjectProxy extends IProxy
	{
		function get id() : String;
		function get attributes() : XMLList;
	}
}
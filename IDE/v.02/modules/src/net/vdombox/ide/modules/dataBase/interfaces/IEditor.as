package net.vdombox.ide.modules.dataBase.interfaces
{
	import flash.events.IEventDispatcher;
	
	import net.vdombox.ide.common.vo.ObjectVO;

	public interface IEditor extends IEventDispatcher
	{
		function get objectVO():ObjectVO
		function get editorName():String
		function get editorID():String

	}
}
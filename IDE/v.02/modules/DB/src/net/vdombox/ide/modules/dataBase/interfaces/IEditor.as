package net.vdombox.ide.modules.dataBase.interfaces
{
	import flash.events.IEventDispatcher;
	
	import net.vdombox.ide.common.model._vo.ObjectVO;

	public interface IEditor extends IEventDispatcher
	{
		function get objectVO():Object
		function get editorName():String
		function get editorID():String

	}
}
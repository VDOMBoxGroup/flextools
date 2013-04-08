package net.vdombox.ide.modules.dataBase.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IEditor extends IEventDispatcher
	{
		function get objectVO() : Object
		function get editorName() : String
		function get editorID() : String
	}
}

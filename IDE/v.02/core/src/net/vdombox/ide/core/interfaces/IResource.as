package net.vdombox.ide.core.interfaces
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public interface IResource extends IEventDispatcher
	{
		function get resourceID() : String;
		
		function get data() : ByteArray;
		
		function load() : void;
	}
}
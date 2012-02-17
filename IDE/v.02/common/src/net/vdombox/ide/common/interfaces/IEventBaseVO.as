package net.vdombox.ide.common.interfaces
{
	public interface IEventBaseVO
	{		
		function get name() : String;
		
		function get id() : String;
		
		function get objectID() : String;
		
		function get objectName() : String;
			
		function get parameters() : Array;
		
		function set state(value : Boolean) : void;
			
		function get state() : Boolean;
		
		function set left(value : int) : void;
			
		function get left() : int;
		
		function set top(value : int) : void;
		
		function get top() : int;
	}
}
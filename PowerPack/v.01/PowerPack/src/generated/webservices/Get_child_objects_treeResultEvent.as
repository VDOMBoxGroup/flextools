/**
 * Get_child_objects_treeResultEvent.as
 * This file was auto-generated from WSDL
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package generated.webservices
{

import flash.events.Event;

/**
 * Typed event handler for the result of the operation
 */

public class Get_child_objects_treeResultEvent extends Event
{
	/**
	 * The event type value
	 */
	public static var Get_child_objects_tree_RESULT : String = "Get_child_objects_tree_result";

	/**
	 * Constructor for the new event type
	 */
	public function Get_child_objects_treeResultEvent()
	{
		super( Get_child_objects_tree_RESULT, false, false );
	}

	private var _headers : Object;
	private var _result : String;
	public function get result() : String
	{
		return _result;
	}

	public function set result( value : String ) : void
	{
		_result = value;
	}

	public function get headers() : Object
	{
		return _headers;
	}

	public function set headers( value : Object ) : void
	{
		_headers = value;
	}
}
}
/**
 * Delete_objectResultEvent.as
 * This file was auto-generated from WSDL
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package generated.webservices
{

import flash.events.Event;

/**
 * Typed event handler for the result of the operation
 */

public class Delete_objectResultEvent extends Event
{
	/**
	 * The event type value
	 */
	public static var Delete_object_RESULT : String = "Delete_object_result";

	/**
	 * Constructor for the new event type
	 */
	public function Delete_objectResultEvent()
	{
		super( Delete_object_RESULT, false, false );
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
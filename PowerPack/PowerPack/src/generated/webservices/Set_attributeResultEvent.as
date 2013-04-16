/**
 * Set_attributeResultEvent.as
 * This file was auto-generated from WSDL
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package generated.webservices
{

import flash.events.Event;

/**
 * Typed event handler for the result of the operation
 */

public class Set_attributeResultEvent extends Event
{
	/**
	 * The event type value
	 */
	public static var Set_attribute_RESULT : String = "Set_attribute_result";

	/**
	 * Constructor for the new event type
	 */
	public function Set_attributeResultEvent()
	{
		super( Set_attribute_RESULT, false, false );
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
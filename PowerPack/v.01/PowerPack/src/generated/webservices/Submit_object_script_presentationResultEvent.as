/**
 * Submit_object_script_presentationResultEvent.as
 * This file was auto-generated from WSDL
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package generated.webservices
{

import flash.events.Event;

/**
 * Typed event handler for the result of the operation
 */

public class Submit_object_script_presentationResultEvent extends Event
{
	/**
	 * The event type value
	 */
	public static var Submit_object_script_presentation_RESULT : String = "Submit_object_script_presentation_result";

	/**
	 * Constructor for the new event type
	 */
	public function Submit_object_script_presentationResultEvent()
	{
		super( Submit_object_script_presentation_RESULT, false, false );
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
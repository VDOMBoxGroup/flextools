/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 10.12.11
 * Time: 11:18
 */
package net.vdombox.powerpack.events.TemplateLibEvents
{

import flash.events.Event;

public class TemplateLibEvent extends Event
{
	public static var RESULT_GETTED : String = "rusulGetted";

	public var result : *;

	public function TemplateLibEvent( type : String, result : *, bubbles : Boolean = false, cancelable : Boolean = false )
	{
		this.result = result;

		super( type, bubbles, cancelable );
	}
}
}

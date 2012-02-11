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
	
	public static var SET_PROGRESS : String = "setProgerss";

	public var result : Object;

	public function TemplateLibEvent( type : String, result : Object, bubbles : Boolean = false, cancelable : Boolean = false )
	{
		this.result = result;

		super( type, bubbles, cancelable );
	}
	
	override public function clone():Event
	{
		return new TemplateLibEvent( type, result,  bubbles,  cancelable );
	}
	
	
}
}

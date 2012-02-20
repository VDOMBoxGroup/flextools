/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 10.12.11
 * Time: 11:18
 */
package net.vdombox.powerpack.lib.player.events
{

import flash.events.Event;

public class TemplateLibEvent extends Event
{
	static  public const   RESULT_GETTED : String = "rusulGetted";
	
	static  public const  SET_PROGRESS : String = "setProgeress";

	public var result : Object;
	public var transition : String;
	

	public function TemplateLibEvent( type : String, result : Object, transition : String = null,  bubbles : Boolean = false, cancelable : Boolean = false )
	{
		this.result = result;
		this.transition = transition;

		super( type, bubbles, cancelable );
	}
	
	override public function clone():Event
	{
		return new TemplateLibEvent( type, result, transition,   bubbles,  cancelable );
	}
	
	
}
}

/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 16.07.12
 * Time: 17:46
 */
package net.vdombox.proshare.Event
{
import flash.events.Event;

public class FilesProxyEvent   extends Event
{
	public var message : String;

	public static var MESSAGE : String = "message";

	public function FilesProxyEvent(type : String, message : String = null,
								   bubbles : Boolean = false, cancelable : Boolean = true  )
	{
		super( type, bubbles, cancelable );

		this.message = message;
	}

	override public function clone():Event
	{
		return new FilesProxyEvent (type, message, bubbles, cancelable );
	}
}
}

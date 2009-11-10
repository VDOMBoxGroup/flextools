package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class DataMessage extends Message
	{
		public static const CREATE : String = "create";

		public static const DELETE : String = "delete";

		public static const READ : String = "read";

		public static const UPDATE : String = "update";

		public function DataMessage( type : String, action : String, parameters : Object = null )
		{
			var headers : Object = { type : type, action : action };
			super( Message.NORMAL, headers, parameters );
		}
	}
}
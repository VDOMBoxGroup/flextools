package net.vdombox.ide.common.controller.messages
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import net.vdombox.ide.common.MessageTypes;

	public class SimpleMessage extends Message
	{
		public function SimpleMessage( header : String, body : Object = null, recepientKey : String = null, answerFlag : Boolean = false )
		{
			super( MessageTypes.SIMPLE_MESSAGE, header, body );
			
			setRecipientKey( recepientKey );
			
			setAnswerFlag( answerFlag );
		}
		
		protected var recepientKey : String;
		
		protected var answerFlag : Boolean;
		
		public function getRecipientKey() : String
		{
			return recepientKey;
		}
		
		public function setRecipientKey( value : String ) : void
		{
			recepientKey = value;
		}
		
		public function getAnswerFlag() : Boolean
		{
			return answerFlag;
		}
		
		public function setAnswerFlag( value : Boolean ) : void
		{
			answerFlag = value;
		}
	}
}
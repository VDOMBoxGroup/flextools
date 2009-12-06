package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public class SimpleMessage extends Message
	{
		public function SimpleMessage( header : String, body : Object = null, recepientKey : String = null, answerFlag : Boolean = false )
		{
			var messageBody : Object = { body : body, recepientKey : recepientKey, answerFlag : answerFlag };
			
			super( type = Message.NORMAL, header, messageBody );
			
			setRecepientKey( recepientKey );
			
			setAnswerFlag( answerFlag );
		}
		
		protected var recepientKey : String;
		
		protected var answerFlag : Boolean;
		
		public function getRecepientKey() : String
		{
			return recepientKey;
		}
		
		public function setRecepientKey( value : String ) : void
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
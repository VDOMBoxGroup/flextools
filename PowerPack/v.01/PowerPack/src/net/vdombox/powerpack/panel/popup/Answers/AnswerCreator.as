package net.vdombox.powerpack.panel.popup.Answers
{
	import mx.controls.Button;
	
	import net.vdombox.powerpack.BasicError;
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;

	public class AnswerCreator
	{
		public static function create( data : String ) : Answer
		{
			var type : String = ListParser.getElm( data , 1);
			var answer : *;
		
			switch (type)
			{	
				case "'text'":
				case "\"text\"":
				{
					answer = new AnswerText (data);
					break;
				}
				case "'textArea'":
				case "\"textArea\"":
				{
					answer = new AnswerTextArea (data);
					break;
				}
				case "'radioButtons'":
				case "\"radioButtons\"":
				{
					answer = new AnswerRadioButtons (data);
					break;
				}
				case "'browseFile'":
				case "\"browseFile\"":
				{
					answer = new AnswerBrowseFile (data);
					break;
				}
				case "'comboBox'":
				{
					
					break;
				}	
				case "'checkBox'":
				{
					
					break;
				}
				default:
				{
					throw Error("Wrong type of answer");
					break;
				}
			}
			
			return answer;
		}
	}
		
}
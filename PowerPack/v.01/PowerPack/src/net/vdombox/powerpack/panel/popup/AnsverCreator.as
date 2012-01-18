package net.vdombox.powerpack.panel.popup
{
	import mx.controls.Button;
	
	import net.vdombox.powerpack.BasicError;
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;

	public class AnsverCreator
	{
		public static function create( data : String ) : Answer
		{
			var type : String = ListParser.getElm( data , 1); 
			
			var answer : *;
		
			switch( type)
			{
				case "'text'":
				{
					answer = new TextAnswer( data );
					
					break;
				}
				case "textArray":
				{
					
					break;
				}
					
				case "checkBox":
				{
					
					break;
				}
				case "radioButton":
				{
					
					break;
				}
					
					
				default:
				{
					//answer = new Button();
					//throw new BasicError( "Wrong answer type" );
					
					break;
				}
			}
			
			return answer;
		}
	}
}
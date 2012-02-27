package net.vdombox.powerpack.lib.player.popup.Answers
{
	import mx.controls.Button;
	
	import net.vdombox.powerpack.lib.player.BasicError;
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;

	public class AnswerCreator
	{
		
		public static const ANSWER_TYPE_TEXT			: String = "text";
		public static const ANSWER_TYPE_TEXT_AREA		: String = "textArea";
        public static const ANSWER_TYPE_TEXT_PASSWORD	: String = "password";
		public static const ANSWER_TYPE_RADIO_BUTTONS	: String = "radioButtons";
		public static const ANSWER_TYPE_BROWSE_FILE		: String = "browseFile";

		public static const ANSWER_TYPE_COMBO_BOX		: String = "comboBox";
		public static const ANSWER_TYPE_CHECK_BOX		: String = "checkBox";
		
		
		public static function create( data : *) : Answer
		{
			var type : String = ListParser.getElmValue( data , 1, Answer.context).toString();
			
			var answer : Answer;
		
			switch (type)
			{	
				case ANSWER_TYPE_TEXT :
				{
					answer = new TextAnswer (data);
					break;
				}
				case ANSWER_TYPE_TEXT_AREA :
				{
					answer = new TextAreaAnswer (data);
					break;
				}
				case ANSWER_TYPE_RADIO_BUTTONS :
				{
					answer = new RadioButtonsAnswer (data);
					break;
				}
//			Browse file type - temporary not supported
//				case ANSWER_TYPE_BROWSE_FILE :
//				{
//					answer = new BrowseFileAnswer (data);
//					break;
//				}
				case ANSWER_TYPE_COMBO_BOX :
				{
					answer = new ComboBoxAnswer (data);
					break;
				}	
				case ANSWER_TYPE_CHECK_BOX :
				{
					answer = new CheckBoxAnswer (data);
					break;
				}

                case ANSWER_TYPE_TEXT_PASSWORD :
                {
                    answer = new PasswordAnswer (data);
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
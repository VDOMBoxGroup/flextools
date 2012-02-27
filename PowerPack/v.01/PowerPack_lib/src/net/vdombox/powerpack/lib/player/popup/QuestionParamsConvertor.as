package net.vdombox.powerpack.lib.player.popup
{
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.popup.Answers.AnswerCreator;

	public class QuestionParamsConvertor
	{
		private static var params : Array = [];
		
		public static const QT_NONE		: int = -1;
		public static const QT_INPUT	: int = 0;
		public static const QT_SELECT	: int = 1;
		public static const QT_BROWSE	: int = 2;
		
		public function QuestionParamsConvertor()
		{
		}
		
		public static function convertToArrayOfLists (questionParams : Array) : Array
		{
			if (!questionParams || questionParams.length == 0)
				throw new Error("No question params declared!");
			
			params = questionParams;
			
			return isList(params[0]) ? questionParams : [paramsToList];
		}
		
		private static function isList (value : String) : Boolean
		{
			try
			{
				var elm : String = ListParser.getElm( value , 1);
			}
			catch (e:Error)
			{
				return false;
			}
			
			return Boolean(elm); 
		}
		
		private static function get questionMode () : int
		{
			
			if ( params.length == 1 && params[0].toString() == "*")
				return QT_INPUT;
			
//			Browse file type - temporary not supported		
//			if ( params.length == 1 && isFileMask(params[0].toString()) )
//				return QT_BROWSE;
			
			if ((params.length > 1) ||
				(params.length == 1 && String(params[0]).split(",").length > 0))
				return QT_SELECT;
			
			return QT_NONE;
		}
		
		private static const regExpFileMask : RegExp = /#\((\*.([\w]+|\*)(;[ ]*(\*.([\w]+|\*))+)*)*\)/g;
		
		private static function isFileMask(param : String) : Boolean
		{
			var arrMatch : Array = param.match(regExpFileMask);
			
			if (!arrMatch || arrMatch.length != 1)
				return false;
			
			return true;
		}
		
		private static function getFileMask(param : String) : String
		{
			if (!isFileMask(param))
				return null;
			
			var arrMatch : Array = param.match(regExpFileMask);
			
			var maskGroup : String = String(arrMatch[0]).substring(2, String(arrMatch[0]).length-1);
			
			return maskGroup;

		}
		
		private static function get paramsToList() : String
		{
			var listParamsArr : Array = [];
			
			switch(questionMode)
			{
				case QT_INPUT:
				{
					listParamsArr.push(AnswerCreator.ANSWER_TYPE_TEXT); // ans type
					break;
				}
				case QT_SELECT:
				{
					listParamsArr.push(AnswerCreator.ANSWER_TYPE_RADIO_BUTTONS); // ans type
					listParamsArr.push(""); // ans label
					
					if (params.length > 1) // ans variants
						listParamsArr = listParamsArr.concat(params);
					else
						listParamsArr = listParamsArr.concat(String(params[0]).split(","));
						
					break;
				}
				case QT_BROWSE:
				{
					listParamsArr.push(AnswerCreator.ANSWER_TYPE_BROWSE_FILE); // ans type
					listParamsArr.push(""); // ans label
					
					listParamsArr.push(getFileMask(params[0].toString()));
					break;
				}
				default:
				{
					throw Error("parameters do not correspond to any answer type!");
					break;
				}
			}
			
			return ListParser.array2List(listParamsArr);
		}
		
		
	}
}
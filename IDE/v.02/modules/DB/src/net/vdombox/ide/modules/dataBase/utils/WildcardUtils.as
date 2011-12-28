package net.vdombox.ide.modules.dataBase.utils
{
	public class WildcardUtils
	{
		/**
		 * The WildcardUtils class is an all-static class with methods for working with wildcards.
		 * You do not create instances of WildcardUtils; instead you simply call static methods such as the WildcardUtils.wildcardToRegExp() method.
		 */ 
		
		/**
		 * Convert wildcard string to regular expression.
		 * 
		 * @param wildcard wildcard string to be converted to regular expression
		 * @param flags flags used to create regular expression (see RegExp documentation)
		 * @param asterisk whether asterisk is interpreted as any character sequence
		 * @param questionMark whether question mark is interpreted as any character
		 * 
		 * @return regular expression equivalent to passed wildcard
		 */
		public static function wildcardToRegExp(wildcard:String, flags:String = "i", asterisk:Boolean = true, questionMark:Boolean = true):RegExp
		{
			var resultStr:String;
			
			//excape metacharacters other than "*" and "?"
			resultStr = wildcard.replace(/[\^\$\\\.\+\(\)\[\]\{\}\|]/g, "\\$&");
			
			//replace wildcard "?" with reg exp equivalent "."
			resultStr = resultStr.replace(/[\?]/g, ".");
			
			//replace wildcard "*" with reg exp equivalen ".*?"
			resultStr = resultStr.replace(/[\*]/g, ".*?");
			
			return new RegExp(resultStr, flags);
		}
	}
}
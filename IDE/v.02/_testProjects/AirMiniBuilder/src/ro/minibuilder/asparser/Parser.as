/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.asparser
{
	import flash.text.*;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import ro.minibuilder.main.editor.ScriptAreaComponent;
	import ro.victordramba.thread.IThread;
	import ro.victordramba.util.HashMap;

	public class Parser implements IThread
	{
		private var tokenizer:Tokenizer;
		private var tokenizer2:Tokenizer;
		

		private var formats:HashMap = new HashMap;
		private var fileName:String;
		
		public function Parser()
		{
			//syntax highlighting
			formats.setValue('default',		new TextFormat(null, null, 0x111111, false, false));
			formats.setValue(Token.KEYWORD,	new TextFormat(null, null, 0x1039FF, true, false));
			formats.setValue(Token.KEYWORD2,new TextFormat(null, null, 0x247ECE, true, false));
			formats.setValue(Token.E4X,		new TextFormat(null, null, 0x613BB9, false, false));
			formats.setValue(Token.COMMENT,	new TextFormat(null, null, 0x109900, false, true));
			formats.setValue(Token.REGEXP, 	new TextFormat(null, null, 0xa3a020, false, false));
			formats.setValue(Token.STRING, 	new TextFormat(null, null, 0xB30000, false, false));
			formats.setValue('topType', 	new TextFormat(null, null, 0x981056, false, false));
		}
		
		public static function addSourceFile(source:String, fileName:String, onComplete:Function):void
		{
			source = source.replace(/(\n|\r\n)/g, '\r');
			var parser:Parser = new Parser;
			parser.load(source, fileName);
			while(parser.runSlice());
			setTimeout(onComplete, 1);
		}
		
		
		//private var typeDB:TypeDB;

		private static const topType:RegExp = /^(:?int|uint|Number|Boolean|RegExp|String|void|Function|Class|Array|Date|ByteArray|Vector|Object|XML|XMLList|Error)$/;

		public function load(source:String, fileName:String):void
		{
			tokenizer2 = new Tokenizer(source);
			this.fileName = fileName;
		}
		
		private function get typeDB():TypeDB
		{
			return tokenizer.typeDB;
		}
		
		
		public function getTypeData():ByteArray
		{
			return typeDB.toByteArray();
		}
		
		/*public function addTypeData(db:TypeDB, name:String):void
		{
			
		}*/
		

		/**
		 * Apply color highliting
		 */
		public function applyFormats(textField:ScriptAreaComponent):void
		{
			//textField.setTextFormat(formats.getValue('default'));
			textField.clearFormatRuns();
			
			for (var i:int=0; i<tokenizer.tokens.length; i++)
			{
				var t:Token = tokenizer.tokens[i];
				var type:String = topType.test(t.string) ? 'topType' : t.type;				
				var fmt:TextFormat = formats.getValue(type);
				if (fmt)
					textField.addFormatRun(t.pos, t.pos+t.string.length, fmt.bold, fmt.italic, Number(fmt.color).toString(16));
					//textField.setTextFormat(fmt, t.pos, t.pos+t.string.length);
				else if (t.string.indexOf('this.') == 0)
				{
					fmt = formats.getValue(Token.KEYWORD);
					textField.addFormatRun(t.pos, t.pos+4, fmt.bold, fmt.italic, Number(fmt.color).toString(16));
					//textField.setTextFormat(formats.getValue(Token.KEYWORD), t.pos, t.pos+4);
				}
			}
			
			textField.applyFormatRuns();
		}
		

		public function get tokenCount():uint
		{
			return tokenizer.tokens ? tokenizer.tokens.length : 0;
		}

		public function get percentReady():Number
		{
			return (tokenizer2 ? tokenizer2 : tokenizer).precentReady;
		}


		public function runSlice():Boolean
		{
			var b:Boolean = tokenizer2.runSlice();
			if (!b)
			{
				tokenizer = tokenizer2;
				tokenizer2 = null;
				TypeDB.setDB(fileName, tokenizer.typeDB);
			}
			return b;
		}

		public function kill():void
		{
			/*if (tokenizer2) 
			{
				tokenizer2.kill();
				tokenizer2 = null;
			}*/
		}

		/*public function getNodeByPos(pos:uint):Token
		{
			if (!tokenizer) return null;
			return tokenizer.tokenByPos(pos);
		}*/
		
		
		
		public function newResolver():Resolver
		{
			return new Resolver(tokenizer);
		}
	}
}
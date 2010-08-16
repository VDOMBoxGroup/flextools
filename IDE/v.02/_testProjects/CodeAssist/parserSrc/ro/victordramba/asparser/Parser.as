/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.asparser
{
	import ro.victordramba.thread.IThread;
	import ro.victordramba.util.HashMap;
	
	import flash.utils.ByteArray;
	import flash.text.*;
	
	import view.ScriptAreaComponent;

	public class Parser implements IThread
	{
		internal var tokenizer:Tokenizer;
		private var tokenizer2:Tokenizer;
		
		public var parentDB:TypeDB;

		//public var tree:Token;

		private var formats:HashMap = new HashMap;
		//private var typeDB:TypeDB;

		private static const topType:RegExp = /^(:?int|uint|Number|Boolean|RegExp|String|void|Function|Class|Array|Date|ByteArray|Vector|Object|XML|XMLList|Error)$/;

		public function load(source:String):void
		{
			tokenizer2 = new Tokenizer(source, parentDB);

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
		
		private function get typeDB():TypeDB
		{
			return tokenizer.typeDB;
		}
		
		private function set typeDB(db:TypeDB):void
		{
			tokenizer.typeDB = db;
		}
		
		public function getTypeData():ByteArray
		{
			return typeDB.toByteArray();
		}
		
		public function addTypeData(db:TypeDB, name:String):void
		{
			//remove from list
			removeTypeData(name);
			//add as first resolver
			db.dbName = name;
			db.parentDB = parentDB;
			parentDB = db;
		}
		
		public function removeTypeData(name:String):void
		{
			var db:TypeDB;
			//remove from list
			for (db = parentDB; db; db = db.parentDB)
			{
				if (db.dbName == name)
					if (db.parentDB) db.childDB = db.parentDB;
			}
		}

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
			return new Resolver(typeDB, tokenizer);
		}
	}
}
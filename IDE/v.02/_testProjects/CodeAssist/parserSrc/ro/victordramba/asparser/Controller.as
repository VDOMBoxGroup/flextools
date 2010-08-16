/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.asparser
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;
	
	import view.ScriptAreaComponent;

	[Event(type="flash.events.Event", name="change")]
	



	public class Controller extends EventDispatcher
	{
		[Embed(source="globals.amf", mimeType="application/octet-stream")]
		private static var GlobalTypesAsset:Class;
		
		[Embed(source="playerglobals.amf", mimeType="application/octet-stream")]
		private static var PlayerglobalAsset:Class;
		
		[Embed(source="aswing.amf", mimeType="application/octet-stream")]
		private static var ASwingAsset:Class;
		
		
		private var parser:Parser;
		private var t0:Number;		
		private var tc:ThreadsController;
		
		public var status:String;
		public var percentReady:Number = 0;
		//public var tokenInfo:String;
		//public var scopeInfo:Array/*of String*/
		//public var typeInfo:Array/*of String*/
		
		private var fld:ScriptAreaComponent;
		
		function Controller(stage:Stage, textField:ScriptAreaComponent)
		{
			fld = textField;
			
			tc = new ThreadsController(stage);
			parser = new Parser;
			
			parser.addTypeData(TypeDB.formByteArray(new GlobalTypesAsset), 'global');
			parser.addTypeData(TypeDB.formByteArray(new PlayerglobalAsset), 'player');
			parser.addTypeData(TypeDB.formByteArray(new ASwingAsset), 'aswing');
			
			tc.addEventListener(ThreadEvent.THREAD_READY, function(e:ThreadEvent):void
			{
				if (e.thread != parser) return;
				parser.applyFormats(textField);
				//cursorMoved(textField.caretIndex);
				status = 'Duration: '+ (getTimer()-t0) + 'ms ('+parser.tokenCount+' tokens)';
				dispatchEvent(new Event('status'));
			});
			
			tc.addEventListener(ThreadEvent.PROGRESS, function(e:ThreadEvent):void
			{
				if (e.thread != parser) return;
				status = '';
				percentReady = parser.percentReady;
				dispatchEvent(new Event('status'));
			});
		}		

		public function saveTypeDB():void
		{
			/*var so:SharedObject = SharedObject.getLocal('ascc-type');
			so.data.typeDB = parser.getTypeData();
			so.flush();*/
			
			var file:FileReference = new FileReference;
			var ret:ByteArray = parser.getTypeData();
			file.save(ret, 'globals.amf');
			
		}
		
		public function restoreTypeDB():void
		{
			var so:SharedObject = SharedObject.getLocal('ascc-type');
			parser.addTypeData(so.data.typeDB, 'restored');
		}
		
		public function sourceChanged(source:String):void
		{
			t0 = getTimer();
			parser.load(source);
			if (tc.isRunning(parser))
				tc.kill(parser);
			tc.run(parser);
			status = 'Processing ...';
		}
		
		public function getMemberList(index:int):Vector.<String>
		{
			return parser.newResolver().getMemberList(fld.text, index);
		}
		
		public function getFunctionDetails(index:int):String
		{
			return parser.newResolver().getFunctionDetails(fld.text, index);
		}
		
		public function getTypeOptions():Vector.<String>
		{
			return parser.newResolver().getAllTypes();
		}
		
		public function getAllOptions(index:int):Vector.<String>
		{
			return parser.newResolver().getAllOptions(index);
		}
		
		public function getMissingImports(name:String, pos:int):Vector.<String>
		{
			return parser.newResolver().getMissingImports(name, pos);
		}
		
		public function isInScope(name:String, pos:int):Boolean
		{
			return parser.newResolver().isInScope(name, pos);
		}
	}
}
package net.vdombox.powerpack.lib.player.popup.Answers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.lib.player.control.BrowseButton;
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;
	import net.vdombox.powerpack.lib.player.managers.LanguageManager;

	public class BrowseFileAnswer extends Answer
	{
		
		private var filePathTextInput	: TextInput;
		private var btnBrowse			: BrowseButton;
		
		private var _browseFilter : String = "*.*";
		
		public var selectedFile : FileReference;
		
		public function BrowseFileAnswer(data:String )
		{
			super(data);
		
			if (dataProvider[2])
				browseFilter = dataProvider[2];
		}
		
		public function set browseFilter (value : String) : void
		{
			_browseFilter = value;
		}
		
		public function get browseFilter () : String
		{
			return _browseFilter;
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createButton();
			createTextInput();
			
			var canvas : Canvas = new Canvas();
			canvas.percentHeight = 100;
			canvas.percentWidth = 100;
			
			canvas.addChild( btnBrowse );
			
			canvas.addChildAt(filePathTextInput, 0);
			
			addChild(canvas);
		}
		
		private function createButton():void
		{
			btnBrowse  = new BrowseButton();
			
			btnBrowse.styleName = "browseBtnStyle";
			btnBrowse.label = LanguageManager.sentences.browse + "...";
			
			btnBrowse.addEventListener( MouseEvent.CLICK, browseClickHandler );
		}
		
		private function  createTextInput():void
		{
			filePathTextInput = new TextInput();
			filePathTextInput.setStyle( 'styleName', "browseFileTextStyle" );
			filePathTextInput.x = 60;
			filePathTextInput.height = 25;
			
			filePathTextInput.text = "";
			filePathTextInput.enabled = false;
			filePathTextInput.editable = false;
			filePathTextInput.percentWidth = 100;
		}
		
		private function browseClickHandler( event : MouseEvent ) : void
		{
			//FIXME: need refactor 
			var filter : FileFilter = new FileFilter(
				StringUtil.substitute( LanguageManager.sentences.file + " ({0})", browseFilter ? browseFilter : '*.*' ),
				browseFilter ? browseFilter : '*.*' );
			
			var file : FileReference = new FileReference();
			
			file.addEventListener(Event.COMPLETE, fileSelectHandler); 
			file.addEventListener( Event.SELECT, fileSelectHandler );
			file.addEventListener(IOErrorEvent.IO_ERROR, fileSelectHandler); 
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileSelectHandler);
			
			if ( browseFilter )
				file.browse([filter]);
			else
				file.browse();
			
			function fileSelectHandler( event : Event ) : void
			{
				
				switch(event.type)
				{
					case Event.SELECT :
						result  = "loading...";
						filePathTextInput.text = filePathTextInput.toolTip = "loading...";
						file.addEventListener(Event.COMPLETE, fileSelectHandler); 
						file.load(); 
						return;
						
				
					case Event.COMPLETE :
						var fileData : ByteArray = file.data;
						result  =  fileData ?  fileData.readUTFBytes(fileData.length) : "";
						filePathTextInput.text = filePathTextInput.toolTip = file.name;
						break;
						
					//TODO: Create cases for  IO_ERROR & SECURITY_ERROR and show error messages :
					default:
					{
						filePathTextInput.text = filePathTextInput.toolTip = "";
					}
						
				}
				file.removeEventListener(Event.COMPLETE, fileSelectHandler); 
				file.removeEventListener( Event.SELECT, fileSelectHandler );
				file.removeEventListener(IOErrorEvent.IO_ERROR, fileSelectHandler); 
				file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fileSelectHandler);
				
			}
		}
		
		private var result :String = "";
		
		
		override public function get value () : String
		{
			return result;
		}
		
	}
}
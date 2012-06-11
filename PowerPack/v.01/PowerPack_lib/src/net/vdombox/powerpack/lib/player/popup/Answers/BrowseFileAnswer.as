package net.vdombox.powerpack.lib.player.popup.Answers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
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
			var filter : FileFilter = new FileFilter(
				StringUtil.substitute( LanguageManager.sentences.file + " ({0})", browseFilter ? browseFilter : '*.*' ),
				browseFilter ? browseFilter : '*.*' );
			
			var file : FileReference = new FileReference();
			
			file.addEventListener( Event.SELECT, fileSelectHandler );
			file.addEventListener(IOErrorEvent.IO_ERROR, fileSelectHandler); 
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileSelectHandler);
			
			if ( browseFilter )
				file.browse([filter]);
			else
				file.browse();
		}
		
		private function fileSelectHandler( event : Event ) : void
		{
			selectedFile = event.target as FileReference;
			
			selectedFile.removeEventListener( Event.SELECT, fileSelectHandler );
			selectedFile.removeEventListener(IOErrorEvent.IO_ERROR, fileSelectHandler); 
			selectedFile.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fileSelectHandler);
			
			if (event.type == IOErrorEvent.IO_ERROR || event.type == SecurityErrorEvent.SECURITY_ERROR)
				filePathTextInput.text = filePathTextInput.toolTip = "";
			else
				filePathTextInput.text = filePathTextInput.toolTip = selectedFile.name;
		}
		
		
		override public function get value () : String
		{
			return StringUtil.trim( filePathTextInput.text );
		}
		
	}
}
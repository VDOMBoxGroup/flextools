package net.vdombox.powerpack.panel.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.control.BrowseButton;
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;
	import net.vdombox.powerpack.managers.LanguageManager;

	public class AnswerBrowseFile extends Answer
	{
		
		private var filePathTextInput	: TextInput;
		private var btnBrowse			: BrowseButton;
		
		public var browseFilter : String = "*.*";
		
		public function AnswerBrowseFile(data:String )
		{
			super(data);
		
			if (dataProvider[2])
				browseFilter = dataProvider[2];
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
			
			var file : File = new File();
			
			file.addEventListener( Event.SELECT, fileSelectHandler );
			
			if ( browseFilter )
				file.browseForOpen( LanguageManager.sentences.select_file + '...', [filter] );
			else
				file.browseForOpen( LanguageManager.sentences.select_file + '...' );
		}
		
		private function fileSelectHandler( event : Event ) : void
		{
			filePathTextInput.text = event.target.nativePath;
			filePathTextInput.toolTip = event.target.nativePath;
		}
		
		override public function get value () : String
		{
			return StringUtil.trim( filePathTextInput.text );
		}
	}
}
package net.vdombox.powerpack.panel.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.control.BrowseButton;
	import net.vdombox.powerpack.managers.LanguageManager;

	public class QuestionBrowse extends QuestionBasePopup
	{
		private var filePathTextInput	: TextInput;
		private var btnBrowse : BrowseButton;
		
		public var browseFilter : String;
		
		
		public function QuestionBrowse()
		{
			super();
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			var btnBrowse : BrowseButton = createButton()
			createTextInput();
			
			answerCanvas.addChild( btnBrowse );
			
			answerCanvas.addChildAt(filePathTextInput, 0);
		}
		
		private function createButton():BrowseButton
		{
			var btnBrowse : BrowseButton = new BrowseButton();
			btnBrowse.styleName = "browseBtnStyle";
			btnBrowse.label = LanguageManager.sentences.browse + "...";
			btnBrowse.addEventListener( MouseEvent.CLICK, browseClickHandler );
			
			return btnBrowse;	
		}
		
		private function  createTextInput():void
		{
			filePathTextInput = new TextInput();
			filePathTextInput.setStyle( 'styleName', "browseFileTextStyle" );
			filePathTextInput.x = 60;
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
		
		override protected function closeDialog() : void
		{
			strAnswer = StringUtil.trim( filePathTextInput.text );
			
			super.closeDialog();
		}
	}
}
package net.vdombox.powerpack.panel.popup
{
	import flash.display.Bitmap;
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.powerpack.control.RoundButton;

	public class QuestionPopup extends PopupBox
	{
		private var question : String = "";
		public var strAnswer : String = "";
		
		private var fCloseHandler : Function;
		
		public var btnOk			: RoundButton;
		public var answerCanvas	: Canvas;
		
		[Embed(source='assets/images/question.png')]
		private var questionImageClass	: Class;
		private var questionImageBitmap	: Bitmap;
		private var questionImage		: Image;
		private var questionText		: Text;
		
		[Embed(source='assets/images/user.png')]
		private var userImageClass		: Class;
		private var userImageBitmap		: Bitmap;
		private var userImage			: Image;
		private var userText			: Text;
		
		public function QuestionPopup(self:QuestionPopup)
		{
			super();
			
			if( self != this)
			{
				//only a subclass can pass a valid reference to self
				throw new IllegalOperationError("Abstract class did not receive reference to self. MyAbstractType cannot be instantiated directly.");
			}
		}
		
		public function setDefaultProperties(question : String, closeHandler : Function):void
		{
			this.question = question;
			fCloseHandler = closeHandler;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			addVisualElements();
		}
		
		protected function addVisualElements () : void
		{
			addQuestionTitle();
			addQuestionAnswer();
		}
		
		protected function addQuestionTitle () : void
		{
			var titleBox : HBox = new HBox();
			titleBox.setStyle("top", 10);
			titleBox.setStyle("bottom", 10);
			titleBox.setStyle("left", 15);
			titleBox.setStyle("right", 15);
			titleBox.setStyle("horisontalGap", 10);
			
			questionImageBitmap = new questionImageClass();
			questionImage = new Image();
			questionImage.autoLoad = true;
			questionImage.source = questionImageBitmap;
			
			questionText = new Text();
			questionText.setStyle("paddingTop", 5);
			questionText.setStyle("paddingBottom", 5);
			questionText.percentHeight = 100;
			questionText.percentWidth = 100;
			questionText.text = question;
			questionText.styleName="infoTextStyle";
			
			titleBox.addChild(questionImage);
			titleBox.addChild(questionText);
			addChild(titleBox);
		}
		
		protected function addQuestionAnswer () : void
		{
			userImageBitmap = new userImageClass();
			userImage = new Image();
			userImage.autoLoad = true;
			userImage.source = userImageBitmap;
			
			var vBox : VBox = new VBox();
			vBox.setStyle("top", 10);
			vBox.setStyle("bottom", 12);
			vBox.setStyle("left", 15);
			vBox.setStyle("right", 18);
			vBox.setStyle("verticalGap", 12);
			
			var answerBox : HBox = new HBox();
			answerBox.percentHeight = 100;
			answerBox.percentWidth = 100;
			
			var canvas : Canvas = new Canvas();
			canvas.percentWidth = 100;
			
			btnOk = new BrowseButton();
			btnOk.label = "OK";
			btnOk.setStyle("bottom", 0);
			btnOk.setStyle("right", 0);
			btnOk.addEventListener(MouseEvent.CLICK, btnOkClickHandler);
			
			canvas.addChild(btnOk);
			
			answerCanvas = new Canvas();
			answerCanvas.percentHeight = 100;
			answerCanvas.percentWidth = 100;
			
			answerBox.addChild(userImage);			
			answerBox.addChild(answerCanvas);
			
			vBox.addChild(answerBox);
			vBox.addChild(canvas);
			
			addChild(vBox);
		}
		
		protected function btnOkClickHandler(evt:MouseEvent) : void
		{
			btnOk.removeEventListener(MouseEvent.CLICK, btnOkClickHandler);
			
			closeDialog();
		}
		
		protected function closeDialog() : void
		{
			if ( fCloseHandler != null )
			{
				addEventListener( CloseEvent.CLOSE, fCloseHandler );
				dispatchEvent( new CloseEvent( CloseEvent.CLOSE ) );
			}
			
			PopUpManager.removePopUp(this);
		}
		
		
	}
}
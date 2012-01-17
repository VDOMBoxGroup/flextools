package net.vdombox.powerpack.panel.popup
{


	public class QuestionMultiType extends Question
	{
		private var _dataProvaider : Array;
		
		public function QuestionMultiType()
		{
			super();
		}
	
		public function set dataProvaider(value:Array):void
		{
			_dataProvaider = value;
		}

	override protected function createChildren () : void
	{
		super.createChildren();
		
		if (!_dataProvaider)
		{
			throw Error("Possible answers are not declared!");
			return;
		}
		
		
		for each (var i:Object in _dataProvaider) 
		{
			trace(i)
		}
		
//		
//		
//		
//		
//		for ( var i : int = 0; i < possibleAnswers.length; i++ )
//		{
//			var radBtn : RadioButton = new RadioButton();
//			
//			vBox.addChild( radBtn );
//		}
//		
//		answerCanvas.addChild( vBox );
	}
	}
}
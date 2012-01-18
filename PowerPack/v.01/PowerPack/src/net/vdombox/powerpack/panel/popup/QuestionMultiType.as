package net.vdombox.powerpack.panel.popup
{
	import mx.containers.VBox;
	import mx.controls.Button;
	
	import net.vdombox.powerpack.gen.parse.ListParser;

	;
	public class QuestionMultiType extends Question
	{
		private var _dataProvaider : Array;
		private var vBox : VBox
		
		public function QuestionMultiType( title: String, data : Array = null)
		{
			super();
			
			_dataProvaider = data;
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
		
		vBox= new VBox();
		vBox.setStyle( "paddingLeft", 10  );
		vBox.maxHeight = 200;
		vBox.percentWidth = 100;
		answerCanvas.addChild( vBox );
		
		
		var valueArray  : Array;
		for each (var value : String in _dataProvaider) 
		{
			trace(value);
			valueArray = ListParser.list2Array( value );
		
			// Simple factory			
//			var answ : IAnswer = AnsverCreator.create(valueArray)
//			vBox.addChild(answ);
			
			// test
			vBox.addChild( new Button());
		}
	}
	
	override protected function closeDialog() : void
	{
		var aas: String = '[1, 12, "Hi, agai\'n", [0, "By sdf"]]'
		var debugResult : Array = [1, 12, "Hi, agai'n", [0, "By sdf"]];
		strAnswer = ListParser.array2List(  ListParser.list2Array(ListParser.array2List(debugResult)) );
		
		super.closeDialog();
	}
}
}
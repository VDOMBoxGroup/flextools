package net.vdombox.powerpack.lib.player.popup.Answers
{
	import mx.containers.VBox;
	import mx.controls.Text;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.listClasses.ElmType;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.CodeFragment;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;
	
	public class Answer extends VBox
	{
		private var _dataProvider : Array;
		private var textLabel : Text;
		private var dataProvaiderString : String;
		
		public static var context : Array;
		
		public function Answer( data : String )
		{
			super();
			
			setStyle("verticalGap", 0);
			
			dataProvider = ListParser.list2Array( data);
			this.data =  data;
			
			validateLabel();
			
			percentWidth = 100;
			
		}
		
		override public function setFocus () : void
		{
			super.setFocus();
		}

		public function get dataProvider() : Array
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value : Array):void
		{
			_dataProvider = [];
			
			var dataList : String = ListParser.array2List(value);
			
			for (var i:uint=0; i<value.length; i++)
			{
				_dataProvider.push( ListParser.getElmValue( dataList, i+1, context) );
			}
			
		}
		
		public function get answerVariants () : Array
		{
			var sourceVariants : Array = dataProvider.slice(2);
			var outputVariants : Array = [];
			
			var variant : AnswerVariant;
			
			if (sourceVariants.length == 1)
			{
				var variantsStr : * = sourceVariants[0];
				
				if ( ListParser.getType(data, 3) == ElmType.LIST || ListParser.getType(data, 3) == ElmType.VARIABLE)
				{
					var multyValue : Array = ListParser.list2Array( variantsStr );
					
					// data like  [ ['app1' 'guid1'] ['app2' 'guid2']  ['app3' 'guid3']]
					
						var dataBt : String; 
						var _value : Object;
						for (var j:int = 0; j < multyValue.length; j++) 
						{
							variant = new AnswerVariant();
							_value = multyValue[j];

							if( _value is CodeFragment)
							{
								dataBt  = ListParser.getElm( variantsStr, j+1 );
								
								variant.label = ListParser.getElmValue( dataBt, 1, context ).toString();
								variant.value = ListParser.getElmValue( dataBt, 2, context ).toString();
							}
							else if( _value is LexemStruct)
							{
								dataBt = Utils.replaceQuotes( LexemStruct( _value ).value.toString() );
								variant.label = variant.value = dataBt;
							} 
							else
							{
								variant.label = variant.value = _value["value"] as String;
							}
							
							outputVariants.push(variant);
						}
						
						return outputVariants;
					
					
				}
				else
					sourceVariants = variantsStr.split(",");
			}
			
			for each (var value : String in sourceVariants) 
			{
				variant = new AnswerVariant();
				
				variant.label = variant.value = value;
				
				outputVariants.push(variant);
			}

			return outputVariants;
			
		}
		
		public function get value():String
		{
			return "";
		}
		
		private function validateLabel():void
		{
			if ( !dataProvider[1] )
				return;
			
			label = dataProvider[1];
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
				
			if ( !dataProvider )
			{
				throw Error("Possible answers are not declared!");
				return;
			}
			
			createLabel();
		}
		
		private function createLabel():void
		{
			if (label == "")
				return;
			
			textLabel = new Text();
			textLabel.percentWidth = 100; 
			
			textLabel.styleName = "infoTextStyle";
			textLabel.selectable = false;
			textLabel.text = label;
			
			addChild(textLabel);
		}
		
	}
}
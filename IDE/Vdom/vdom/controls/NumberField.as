package vdom.controls
{
import mx.controls.NumericStepper;

public class NumberField extends NumericStepper
{
	private var externalData:Object;
	
	public function NumberField()
	{
		super();
	}
	
	override public function get data():Object
	{
		return externalData;
	}
	
	override public function set data(value:Object):void
	{
		externalData = value;
	}
}
}